extends RefCounted
## Versioned production content boundary for F01. Definitions/actions come from
## code, never from a save. S32's approved normalization grants once and schedules
## an explicit Sub5 at +1800 game seconds; removal itself is not an inverse.
const Timing = preload("res://scripts/effect_timing.gd")
const Stats = preload("res://scripts/character_stats.gd")
const Clock = preload("res://scripts/game_clock.gd")
const OWNER := "character:physical_speed"
const EXPIRY := "city:physical_speed:expiry"
const TEXT := "city:physical_speed:text"
const DURATION_GAME_MICROSECONDS: int = 30 * Clock.GAME_MICROSECONDS_PER_MINUTE
var runtime: RefCounted

static func speed_action(operation: String) -> Dictionary:
	return {"target": "speed_bonus", "operation": operation, "operand_width": 1,
		"block_count": 1, "block_gap": 0, "parameter": 5}

func _init(character: Dictionary, now_game_microseconds: int) -> void:
	runtime = Timing.new(character, now_game_microseconds)
	var comparison := {"effect_type": 3, "interval_raw": 0, "natural_cure_raw": 0,
		"action_raw": 145, "target_offset_raw": 6318, "block_count_raw": 1,
		"block_gap_raw": 0, "parameter_raw": 5}
	runtime.register_definition({"definition_id": EXPIRY, "definition_revision": 1,
		"disallow_multiple": true, "comparison": comparison},
		{"kind": "timer", "initial_timer_raw": 30, "interval_raw": 0,
		"counter_raw": 1, "incubating": false, "action": speed_action("subtract")})
	comparison = comparison.duplicate(true)
	comparison.effect_type = 0
	runtime.register_definition({"definition_id": TEXT, "definition_revision": 1,
		"disallow_multiple": false, "comparison": comparison},
		{"kind": "text", "text": "Physical Speed", "long_text": true, "visible": true})
	runtime.register_entity(OWNER, 0, [
		{"definition_id": EXPIRY, "required_events": 4, "link_to_previous": false},
		{"definition_id": TEXT, "required_events": 4, "link_to_previous": true}])

func activate_physical_speed() -> Dictionary:
	# Preview activation and grant together; H suppression must not grant again or
	# refresh the deadline. No caller can observe half of an activation transaction.
	if runtime._busy:
		return {"ok": false, "error": "runtime_busy"}
	if runtime._events._instances._next_instance_id > Clock.MAX_GAME_MICROSECONDS - 2:
		return {"ok": false, "error": "instance_identity_exhausted"}
	var candidate = runtime._fork()
	var queued: Dictionary = candidate.queue_events(OWNER, 4, candidate._now_game_microseconds)
	if not queued.ok:
		return queued
	var result: Dictionary = candidate.advance_game_microseconds(0)
	if not result.ok:
		return result
	var activated := false
	for entry in result.trace:
		if entry.kind == "event" and not entry.step.created_ids.is_empty():
			activated = true
	if activated:
		var grant: Dictionary = Stats.apply_actions(candidate._character, [speed_action("add")])
		if not grant.ok:
			return grant
	runtime._commit(candidate)
	return {"ok": true, "activated": activated}

func remaining_game_microseconds() -> int:
	for state in runtime.snapshot().active:
		if state.definition_id == EXPIRY:
			return state.due_game_microseconds - runtime._now_game_microseconds
	return 0

func save_payload() -> Dictionary:
	var active: Array = runtime.snapshot().active
	for state in active:
		state["definition_revision"] = 1
	return {"version": 1, "now_game_microseconds": runtime._now_game_microseconds,
		"next_instance_id": runtime._events._instances._next_instance_id, "active": active}

func can_save() -> bool:
	# The production content API has no future owner events or deletion. Reject
	# unsupported externally injected state instead of silently dropping it.
	if runtime._busy or not runtime.snapshot().queued.is_empty():
		return false
	var entity: Dictionary = runtime.entity_snapshot(OWNER).entity
	if entity.deleted or entity.held or entity.pending_events != 0:
		return false
	var validator = get_script().new(runtime._character.duplicate(true), runtime._now_game_microseconds)
	return validator.restore_payload(save_payload())

static func exact_integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) \
		and value >= minimum and value <= maximum and value == int(value)

static func same_saved_value(expected: Variant, actual: Variant) -> bool:
	# JSON parses integers as floats. Compare numeric values exactly while keeping
	# booleans, strings, field sets and array order strict; never round a timer.
	if expected is int:
		return exact_integer(actual, -1, Clock.MAX_GAME_MICROSECONDS) and int(actual) == expected
	if typeof(expected) != typeof(actual):
		return false
	if expected is Dictionary:
		if expected.size() != actual.size():
			return false
		for key in expected:
			if not actual.has(key) or not same_saved_value(expected[key], actual[key]):
				return false
		return true
	if expected is Array:
		if expected.size() != actual.size():
			return false
		for index in range(expected.size()):
			if not same_saved_value(expected[index], actual[index]):
				return false
		return true
	return expected == actual

## Only the reachable F01 content shapes are accepted: empty or one expiry/text
## pair. This is deliberately not a general interpreter for arbitrary saved
## owners/actions. Future content must version and extend this validation.
## Restore metadata using trusted templates without replaying the activation grant.
func restore_payload(payload: Variant) -> bool:
	if runtime._busy or not payload is Dictionary or payload.size() != 4:
		return false
	if payload.get("version") != 1 or payload.get("now_game_microseconds") != runtime._now_game_microseconds:
		return false
	if not exact_integer(payload.get("next_instance_id"), 1, Clock.MAX_GAME_MICROSECONDS):
		return false
	var next_instance_id := int(payload.next_instance_id)
	if next_instance_id % 2 != 1 or not payload.get("active") is Array or payload.active.size() not in [0, 2]:
		return false
	var candidate = get_script().new(runtime._character, runtime._now_game_microseconds)
	if payload.active.size() == 2:
		var root = payload.active[0]
		if not root is Dictionary or not exact_integer(root.get("instance_id"), 1, next_instance_id - 2):
			return false
		var root_id := int(root.instance_id)
		if root_id != next_instance_id - 2 or root_id % 2 != 1:
			return false
		if not exact_integer(root.get("due_game_microseconds"), runtime._now_game_microseconds + 1, mini(Clock.MAX_GAME_MICROSECONDS, runtime._now_game_microseconds + DURATION_GAME_MICROSECONDS)):
			return false
		# Allocate at a safe synthetic origin so a valid near-ceiling save does not
		# require a new full-duration deadline during restoration.
		candidate.runtime._now_game_microseconds = 0
		candidate.runtime._events._instances._next_instance_id = root_id
		candidate.runtime.queue_events(OWNER, 4, 0)
		if not candidate.runtime.advance_game_microseconds(0).ok:
			return false
		candidate.runtime._now_game_microseconds = runtime._now_game_microseconds
		candidate.runtime._timers[root_id].due_game_microseconds = int(root.due_game_microseconds)
	candidate.runtime._events._instances._next_instance_id = next_instance_id
	# Compare every field, including owner/group IDs, revision, slot continuation,
	# counter, incubation and text visibility. Extra executable fields are rejected.
	if not same_saved_value(candidate.save_payload(), payload):
		return false
	runtime = candidate.runtime
	return true
