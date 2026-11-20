extends RefCounted
## Bounded S29 dispatcher: Use/Cast and Unuse for generic effect owners only.
## No inventory, special-use hooks, text layout, stat actions or timer callbacks.
## Get/Drop/Delete and unknown bits are rejected until their extra paths reconcile.

const Definitions = preload("res://scripts/effect_definitions.gd")
const Instances = preload("res://scripts/effect_instances.gd")
const USE := 4
const UNUSE := 8
const SUPPORTED_EVENTS := USE | UNUSE
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
func register_entity(owner_id: String, listeners: Array) -> Dictionary:
	if owner_id.strip_edges().is_empty():
		return {"ok": false, "error": "invalid_owner_id"}
	if _entities.has(owner_id):
		return {"ok": false, "error": "owner_already_registered"}
	for listener in listeners:
		if not listener is Dictionary or listener.size() != 3:
			return {"ok": false, "error": "invalid_listener"}
		for field in ["definition_id", "required_events", "link_to_previous"]:
			if not listener.has(field):
				return {"ok": false, "error": "invalid_listener"}
		if not listener.definition_id is String or not listener.link_to_previous is bool:
			return {"ok": false, "error": "invalid_listener"}
		if not listener.required_events is int or not _supported_mask(listener.required_events):
			return {"ok": false, "error": "unsupported_listener_events"}
		var definition: Dictionary = _definitions.definition_snapshot(listener.definition_id)
		if not definition.ok:
			return definition
	_entities[owner_id] = {"listeners": listeners.duplicate(true), "pending_events": 0}
	return {"ok": true}

func queue_events(owner_id: String, event_mask: int) -> Dictionary:
	if not _entities.has(owner_id):
		return {"ok": false, "error": "unknown_owner"}
	if not _supported_mask(event_mask):
		return {"ok": false, "error": "unsupported_events"}
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

func dispatch_pending(owner_id: String) -> Dictionary:
	if not _entities.has(owner_id):
		return {"ok": false, "error": "unknown_owner"}
	var captured_events: int = _entities[owner_id].pending_events
	# ST module 05 $2840-$2852 captures and clears before processing. This
	# synchronous bounded API invokes no callbacks, so cannot dispatch reentrantly.
	# All references were validated at registration; definitions are immutable.
	_entities[owner_id].pending_events = 0
	var events: Array = []
	for event_mask in [USE, UNUSE]:
		if (captured_events & event_mask) == 0:
			continue
		var opposing_event: int = UNUSE if event_mask == USE else USE
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
			"created_ids": activation.created_ids, "suppressed_at": activation.suppressed_at})
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
