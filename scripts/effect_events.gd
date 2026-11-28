extends RefCounted
## S29 non-timed dispatcher for generic effect owners.
## No inventory, special-use hooks, text layout, stat actions or timer callbacks.
## A-E are supported; unknown bits and Delete listeners are rejected. Delete is
## terminal owner cleanup, not listener activation (ST module 05 $29a6-$29e6).

const Definitions = preload("res://scripts/effect_definitions.gd")
const Instances = preload("res://scripts/effect_instances.gd")
const GET := 1
const DROP := 2
const USE := 4
const UNUSE := 8
const DELETE := 16
const LISTENER_EVENTS := GET | DROP | USE | UNUSE
const SUPPORTED_EVENTS := LISTENER_EVENTS | DELETE
const OPPOSING_EVENTS := {GET: DROP, DROP: GET, USE: UNUSE, UNUSE: USE}
var _definitions: Definitions
var _instances: Instances
var _entities: Dictionary = {}
# Explicit binding replaces ambiguous original template-byte-15 lookup. It is
# reconstruction architecture: each copy retains its originating listener mask.
var _listener_masks: Dictionary = {}

func _init(definitions: Definitions) -> void:
	_definitions = definitions
	_instances = Instances.new(definitions)

## Each ordered listener has definition_id, required_events, link_to_previous.
func register_entity(owner_id: String, listeners: Array, initially_held: Variant = false) -> Dictionary:
	if owner_id.strip_edges().is_empty():
		return {"ok": false, "error": "invalid_owner_id"}
	if _entities.has(owner_id):
		return {"ok": false, "error": "owner_already_registered"}
	if not initially_held is bool:
		return {"ok": false, "error": "invalid_held_state"}
	for listener in listeners:
		if not listener is Dictionary or listener.size() != 3:
			return {"ok": false, "error": "invalid_listener"}
		for field in ["definition_id", "required_events", "link_to_previous"]:
			if not listener.has(field):
				return {"ok": false, "error": "invalid_listener"}
		if not listener.definition_id is String or not listener.link_to_previous is bool:
			return {"ok": false, "error": "invalid_listener"}
		if not listener.required_events is int or listener.required_events <= 0 \
			or (listener.required_events & ~LISTENER_EVENTS) != 0:
			return {"ok": false, "error": "unsupported_listener_events"}
		var definition: Dictionary = _definitions.definition_snapshot(listener.definition_id)
		if not definition.ok:
			return definition
	_entities[owner_id] = {"listeners": listeners.duplicate(true), "pending_events": 0,
		"held": initially_held, "deleted": false}
	return {"ok": true}

func queue_events(owner_id: String, event_mask: Variant) -> Dictionary:
	if not _entities.has(owner_id):
		return {"ok": false, "error": "unknown_owner"}
	if not event_mask is int or not _supported_mask(event_mask):
		return {"ok": false, "error": "unsupported_events"}
	if _entities[owner_id].deleted:
		# Tombstones reserve owner identity: stale queued work cannot affect a new
		# entity that reused its ID. Repeated Delete is a successful no-op.
		if event_mask == DELETE:
			return {"ok": true}
		return {"ok": false, "error": "deleted_owner"}
	_entities[owner_id].pending_events |= event_mask
	return {"ok": true}

func _supported_mask(event_mask: int) -> bool:
	return event_mask > 0 and (event_mask & ~SUPPORTED_EVENTS) == 0

func entity_snapshot(owner_id: String) -> Dictionary:
	if not _entities.has(owner_id):
		return {"ok": false, "error": "unknown_owner"}
	return {"ok": true, "entity": _entities[owner_id].duplicate(true)}

func active_snapshot() -> Array:
	return _instances.snapshot()

func dispatch_pending(owner_id: String, include_step_snapshots: bool = false) -> Dictionary:
	if not _entities.has(owner_id):
		return {"ok": false, "error": "unknown_owner"}
	var captured_events: int = _entities[owner_id].pending_events
	# ST module 05 $2840-$2852 captures and clears before processing. This
	# synchronous bounded API invokes no callbacks, so cannot dispatch reentrantly.
	# All references were validated at registration; definitions are immutable.
	_entities[owner_id].pending_events = 0
	var events: Array = []
	for event_mask in [GET, DROP, USE, UNUSE, DELETE]:
		if (captured_events & event_mask) == 0:
			continue
		if event_mask == DELETE:
			var removal: Dictionary = _instances.remove_owner(owner_id)
			for instance_id in removal.removed_ids:
				_listener_masks.erase(instance_id)
			_entities[owner_id].deleted = true
			_entities[owner_id].held = false
			events.append({"event": DELETE, "removed_ids": removal.removed_ids,
				"created_ids": [], "suppressed_at": -1, "skipped": false})
			if include_step_snapshots:
				events[-1]["active_records"] = _instances.snapshot()
			continue
		# Generic owners have no stackable-item consumption or inventory/floor
		# callbacks. Those belong to later integration; only the ST held guard is
		# represented here. Get runs before Drop when both are captured.
		if event_mask == DROP and not _entities[owner_id].held:
			events.append({"event": DROP, "removed_ids": [], "created_ids": [],
				"suppressed_at": -1, "skipped": true})
			if include_step_snapshots:
				events[-1]["active_records"] = _instances.snapshot()
			continue
		if event_mask == GET:
			_entities[owner_id].held = true
		elif event_mask == DROP:
			_entities[owner_id].held = false
		var opposing_event: int = OPPOSING_EVENTS[event_mask]
		var removed_ids := _remove_opposing(owner_id, opposing_event)
		var selected: Array = []
		var selected_masks: Array = []
		for listener in _entities[owner_id].listeners:
			if (listener.required_events & event_mask) != 0:
				selected.append({"definition_id": listener.definition_id,
					"link_to_previous": listener.link_to_previous})
				selected_masks.append(listener.required_events)
		var activation: Dictionary = _instances.activate_sequence(owner_id, selected)
		assert(activation.ok, "Registered immutable definitions must remain valid")
		for index in range(activation.created_ids.size()):
			_listener_masks[activation.created_ids[index]] = selected_masks[index]
		events.append({"event": event_mask, "removed_ids": removed_ids,
			"created_ids": activation.created_ids, "suppressed_at": activation.suppressed_at,
			"skipped": false})
		if include_step_snapshots:
			events[-1]["active_records"] = _instances.snapshot()
	return {"ok": true, "events": events}

func _remove_opposing(owner_id: String, opposing_event: int) -> Array:
	var groups: Dictionary = {}
	for instance in _instances.snapshot():
		if instance.owner_id == owner_id and (_listener_masks[instance.instance_id] & opposing_event) != 0:
			groups[instance.group_id] = true
	var removed_ids: Array = []
	for group_id in groups:
		var removal: Dictionary = _instances.remove_group(owner_id, group_id)
		for instance_id in removal.removed_ids:
			_listener_masks.erase(instance_id)
			removed_ids.append(instance_id)
	return removed_ids

func expire_instance(instance_id: int) -> Dictionary:
	var result := _instances.expire_instance(instance_id)
	for removed_id in result.removed_ids:
		_listener_masks.erase(removed_id)
	return result

## Snapshots after each event let S30 reproduce transient allocation/removal
## without callbacks or changing S29's public trace format for existing callers.
func fork() -> RefCounted:
	var copy = get_script().new(_definitions)
	copy._instances = _instances.fork()
	copy._entities = _entities.duplicate(true)
	copy._listener_masks = _listener_masks.duplicate(true)
	return copy
