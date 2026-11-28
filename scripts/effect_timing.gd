extends RefCounted
## S30 scheduler for the approved operation set. All timestamps are integer game microseconds.
## S32 supplies ordering/zero semantics; S03 converts time; S08 executes actions.
const Definitions = preload("res://scripts/effect_definitions.gd")
const Events = preload("res://scripts/effect_events.gd")
const Stats = preload("res://scripts/character_stats.gd")
const Clock = preload("res://scripts/game_clock.gd")
const GAME_MICROSECONDS_PER_TIMER_UNIT: int = Clock.GAME_MICROSECONDS_PER_MINUTE
var _definitions = Definitions.new()
var _events = Events.new(_definitions)
var _profiles: Dictionary = {}
var _ranks: Dictionary = {}
var _scheduled: Array = []
var _timers: Dictionary = {}
var _character: Dictionary
var _now_game_microseconds: int
var _busy := false

func _init(character: Dictionary, start_game_microseconds: int = 0) -> void:
	_character = character
	_now_game_microseconds = start_game_microseconds

func _error(reason: String) -> Dictionary:
	return {"ok": false, "error": reason}

## The immutable S29 comparison remains provenance/H evidence. Execution requires
## this separately validated typed profile; opaque native fields are never run.
func register_definition(definition: Dictionary, profile: Dictionary) -> Dictionary:
	if _busy:
		return _error("runtime_busy")
	var validation = Definitions.new()
	var result: Dictionary = validation.register_definition(definition)
	if not result.ok:
		return result
	if definition.comparison.natural_cure_raw != 0:
		return _error("natural_cure_unsupported")
	if profile.get("kind") == "text":
		if profile.size() != 4 or not profile.get("text") is String or not profile.get("long_text") is bool or not profile.get("visible") is bool or definition.comparison.effect_type != 0:
			return _error("invalid_text_profile")
	elif profile.get("kind") == "timer":
		if profile.size() != 6 or not profile.get("incubating") is bool or not profile.get("action") is Dictionary:
			return _error("invalid_timer_profile")
		for key in ["initial_timer_raw", "interval_raw", "counter_raw"]:
			if not profile.get(key) is int or profile[key] < 0 or profile[key] > (255 if key == "counter_raw" else 65535):
				return _error("invalid_timer_domain")
		result = Stats.apply_actions({}, [profile.action])
		if not result.ok:
			return result
		var comparison: Dictionary = definition.comparison
		if comparison.effect_type not in [1, 2, 3] or comparison.interval_raw != profile.interval_raw or comparison.action_raw != (129 if profile.action.operation == "add" else 145) or comparison.target_offset_raw != 6318 or comparison.block_count_raw != 1 or comparison.block_gap_raw != 0 or comparison.parameter_raw != profile.action.parameter:
			return _error("profile_provenance_mismatch")
	else:
		return _error("unsupported_profile_kind")
	result = _definitions.register_definition(definition)
	if result.ok:
		_profiles[definition.definition_id] = profile.duplicate(true)
	return result

func register_entity(owner_id: String, source_rank: Variant, listeners: Array, initially_held: Variant = false) -> Dictionary:
	if _busy or not source_rank is int or source_rank < 0 or source_rank in _ranks.values():
		return _error("invalid_or_duplicate_owner_rank")
	for listener in listeners:
		if not listener is Dictionary or not _profiles.has(listener.get("definition_id", "")):
			return _error("missing_execution_profile")
	var result: Dictionary = _events.register_entity(owner_id, listeners, initially_held)
	if result.ok:
		_ranks[owner_id] = source_rank
	return result

func queue_events(owner_id: String, event_mask: Variant, at_game_microseconds: Variant) -> Dictionary:
	if _busy or not at_game_microseconds is int or at_game_microseconds < _now_game_microseconds or at_game_microseconds > Clock.MAX_GAME_MICROSECONDS:
		return _error("invalid_event_timestamp")
	# Validate against a transaction copy so queuing future events does not set
	# pending bits on the live owner early. Equal-time masks are combined later.
	var check = _events.fork()
	var result: Dictionary = check.queue_events(owner_id, event_mask)
	if result.ok:
		_scheduled.append({"owner_id": owner_id, "mask": event_mask, "at": at_game_microseconds})
	return result

func snapshot() -> Dictionary:
	var states: Array = _timers.values().duplicate(true)
	states.sort_custom(func(a, b): return a.slot < b.slot)
	return {"now_game_microseconds": _now_game_microseconds, "active": states, "queued": _scheduled.duplicate(true)}

func entity_snapshot(owner_id: String) -> Dictionary:
	return _events.entity_snapshot(owner_id)

func _fork() -> RefCounted:
	var copy = get_script().new(_character.duplicate(true), _now_game_microseconds)
	copy._definitions = _definitions
	copy._events = _events.fork()
	copy._profiles = _profiles
	copy._ranks = _ranks.duplicate(true)
	copy._scheduled = _scheduled.duplicate(true)
	copy._timers = _timers.duplicate(true)
	return copy

## Preview and commit are internal transaction boundaries used by the clock
## adapter. The caller cannot mutate a live timer via a returned snapshot.
func _prepare(elapsed_game_microseconds: Variant) -> Dictionary:
	if _busy or not elapsed_game_microseconds is int or _now_game_microseconds < 0 or _now_game_microseconds > Clock.MAX_GAME_MICROSECONDS or elapsed_game_microseconds < 0 or elapsed_game_microseconds > Clock.MAX_GAME_MICROSECONDS - _now_game_microseconds:
		return _error("invalid_elapsed_or_busy")
	var state_check := Stats.apply_actions(_character, [])
	if not state_check.ok:
		return state_check
	var candidate = _fork()
	var result: Dictionary = candidate._run(_now_game_microseconds + elapsed_game_microseconds)
	if result.ok:
		result["candidate"] = candidate
	return result

func _commit(candidate: RefCounted) -> void:
	_events = candidate._events
	_scheduled = candidate._scheduled
	_timers = candidate._timers
	_now_game_microseconds = candidate._now_game_microseconds
	if candidate._character.has("speed_bonus"):
		_character["speed_bonus"] = candidate._character.speed_bonus

func advance_game_microseconds(elapsed_game_microseconds: Variant) -> Dictionary:
	var result := _prepare(elapsed_game_microseconds)
	if result.ok:
		_commit(result.candidate)
		result.erase("candidate")
	return result

func _reconcile(records: Array) -> Dictionary:
	var live := {}
	for record in records:
		live[record.instance_id] = true
	for identifier in _timers.keys():
		if not live.has(identifier):
			_timers.erase(identifier)
	var occupied := {}
	for state in _timers.values():
		for slot in range(state.slot, state.slot + state.slot_count):
			occupied[slot] = true
	for record in records:
		if _timers.has(record.instance_id):
			continue
		var profile: Dictionary = _profiles[record.definition.definition_id]
		var width: int = 2 if profile.kind == "text" and profile.long_text else 1
		var slot := 0
		while occupied.has(slot) or (width == 2 and occupied.has(slot + 1)):
			slot += 1
		for index in range(slot, slot + width):
			occupied[index] = true
		var state := {"instance_id": record.instance_id, "owner_id": record.owner_id,
			"group_id": record.group_id, "definition_id": record.definition.definition_id,
			"slot": slot, "slot_count": width, "kind": profile.kind, "due_game_microseconds": -1}
		if profile.kind == "text":
			state["text"] = profile.text
			state["visible"] = profile.visible
		else:
			var initial_delay_game_microseconds: int = profile.initial_timer_raw * GAME_MICROSECONDS_PER_TIMER_UNIT
			if initial_delay_game_microseconds > Clock.MAX_GAME_MICROSECONDS - _now_game_microseconds:
				return _error("timer_deadline_overflow")
			state["due_game_microseconds"] = _now_game_microseconds + initial_delay_game_microseconds if initial_delay_game_microseconds > 0 else -1
			state["remaining_executions"] = profile.counter_raw
			state["unbounded"] = profile.counter_raw == 0
			state["incubating"] = profile.incubating
		_timers[record.instance_id] = state
	return {"ok": true}

func _run(end_game_microseconds: int) -> Dictionary:
	var trace: Array = []
	while true:
		var next_game_microseconds: int = end_game_microseconds + 1
		for event in _scheduled:
			next_game_microseconds = mini(next_game_microseconds, event.at)
		for state in _timers.values():
			if state.due_game_microseconds >= 0:
				next_game_microseconds = mini(next_game_microseconds, state.due_game_microseconds)
		if next_game_microseconds > end_game_microseconds:
			break
		_now_game_microseconds = next_game_microseconds
		var masks := {}
		var pending: Array = []
		for event in _scheduled:
			if event.at == next_game_microseconds:
				masks[event.owner_id] = masks.get(event.owner_id, 0) | event.mask
			else:
				pending.append(event)
		_scheduled = pending
		var owners: Array = masks.keys()
		owners.sort_custom(func(a, b): return _ranks[a] > _ranks[b])
		for owner in owners:
			if _events.entity_snapshot(owner).entity.deleted:
				trace.append({"at": _now_game_microseconds, "kind": "stale_owner_event", "owner_id": owner})
				continue
			_events.queue_events(owner, masks[owner])
			var dispatch: Dictionary = _events.dispatch_pending(owner, true)
			for step in dispatch.events:
				var reconciliation := _reconcile(step.active_records)
				if not reconciliation.ok:
					return reconciliation
				step.erase("active_records")
				trace.append({"at": _now_game_microseconds, "kind": "event", "owner_id": owner, "step": step})
		var due: Array = []
		for state in _timers.values():
			if state.due_game_microseconds == _now_game_microseconds:
				due.append(state.instance_id)
		due.sort_custom(func(a, b): return _timers[a].slot < _timers[b].slot)
		for identifier in due:
			# A preceding root/counter expiry can invalidate another due record.
			if not _timers.has(identifier):
				continue
			var state: Dictionary = _timers[identifier]
			var profile: Dictionary = _profiles[state.definition_id]
			var repeat_game_microseconds: int = profile.interval_raw * GAME_MICROSECONDS_PER_TIMER_UNIT
			if repeat_game_microseconds > Clock.MAX_GAME_MICROSECONDS - _now_game_microseconds:
				return _error("timer_deadline_overflow")
			state.due_game_microseconds = _now_game_microseconds + repeat_game_microseconds if repeat_game_microseconds > 0 else -1
			if state.incubating:
				state.incubating = false
				for linked in _timers.values():
					if linked.kind == "text" and linked.group_id == identifier:
						linked.visible = true
			var action_result := Stats.apply_actions(_character, [profile.action])
			assert(action_result.ok, "Validated typed actions and state must remain valid")
			trace.append({"at": _now_game_microseconds, "kind": "action", "instance_id": identifier,
				"slot": state.slot, "bonus": action_result.after})
			if not state.unbounded:
				state.remaining_executions -= 1
				if state.remaining_executions == 0:
					var removal: Dictionary = _events.expire_instance(identifier)
					for removed_id in removal.removed_ids:
						_timers.erase(removed_id)
					trace.append({"at": _now_game_microseconds, "kind": "expiry", "removed_ids": removal.removed_ids})
	_now_game_microseconds = end_game_microseconds
	return {"ok": true, "trace": trace, "now_game_microseconds": _now_game_microseconds}
