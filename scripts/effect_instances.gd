extends RefCounted
## S29 non-timed instance storage. The caller supplies an ordered list already
## selected for activation; this module does not interpret entity events.
## Group linkage and H suppression follow Kroah and the bounded ST probes.
## IDs/owner strings and atomic input rejection are reconstruction architecture.

const Definitions = preload("res://scripts/effect_definitions.gd")
var _definitions: RefCounted
var _active: Dictionary = {}
var _next_instance_id: int = 1

func _init(definitions: Definitions) -> void:
	_definitions = definitions

## Each entry has exactly definition_id and link_to_previous (FF=false, 00=true).
## Only eligible definitions belong here; effect_events.gd selects Use/Unuse
## listeners. Linkage starts afresh per call and never crosses an owner/call.
func activate_sequence(owner_id: String, entries: Array) -> Dictionary:
	if owner_id.strip_edges().is_empty():
		return {"ok": false, "error": "invalid_owner_id"}
	var prepared: Array = []
	# Validate the ENTIRE sequence before mutation, even beyond a potential H
	# match. Otherwise a malformed trailing record could be silently accepted.
	for entry in entries:
		if not entry is Dictionary or entry.size() != 2:
			return {"ok": false, "error": "invalid_activation_entry"}
		if not entry.has("definition_id") or not entry.has("link_to_previous"):
			return {"ok": false, "error": "invalid_activation_entry"}
		if not entry.definition_id is String or not entry.link_to_previous is bool:
			return {"ok": false, "error": "invalid_activation_entry"}
		var lookup: Dictionary = _definitions.definition_snapshot(entry.definition_id)
		if not lookup.ok:
			return lookup
		prepared.append({"definition": lookup.definition, "link_to_previous": entry.link_to_previous})
	var comparisons: Array = []
	for instance in _active.values():
		comparisons.append(instance.definition.comparison)
	var created_ids: Array = []
	var current_group_id: int = 0
	var suppressed_at: int = -1
	for index in range(prepared.size()):
		var entry: Dictionary = prepared[index]
		var gate: Dictionary = _definitions.check_duplicate_gate(entry.definition.definition_id, comparisons)
		if gate.suppress_current_and_following:
			suppressed_at = index
			break
		var instance_id := _next_instance_id
		_next_instance_id += 1
		# A first 00 record has no predecessor, so it becomes its own group root.
		# IDs are never recycled: a stale group handle cannot address a new group.
		if current_group_id == 0 or not entry.link_to_previous:
			current_group_id = instance_id
		_active[instance_id] = {
			"instance_id": instance_id, "owner_id": owner_id,
			"group_id": current_group_id, "definition": entry.definition.duplicate(true),
		}
		created_ids.append(instance_id)
		# H sees earlier activations in this sequence as well as all owners' records.
		comparisons.append(entry.definition.comparison)
	return {"ok": true, "created_ids": created_ids, "suppressed_at": suppressed_at}

## Explicit removal only. It never runs an inverse action or touches character
## stats: original removal is slot invalidation, not a general rollback service.
## Owner is required so a group handle from one entity cannot remove another's.
func remove_group(owner_id: String, group_id: int) -> Dictionary:
	if owner_id.strip_edges().is_empty() or group_id < 1:
		return {"ok": false, "error": "invalid_group_reference"}
	return _remove_matching(owner_id, group_id)

func remove_owner(owner_id: String) -> Dictionary:
	if owner_id.strip_edges().is_empty():
		return {"ok": false, "error": "invalid_owner_id"}
	return _remove_matching(owner_id, 0)

func _remove_matching(owner_id: String, group_id: int) -> Dictionary:
	var removed_ids: Array = []
	# Collect keys before deletion; never mutate a dictionary while iterating it.
	for instance in _active.values():
		if instance.owner_id == owner_id and (group_id == 0 or instance.group_id == group_id):
			removed_ids.append(instance.instance_id)
	for instance_id in removed_ids:
		_active.erase(instance_id)
	return {"ok": true, "removed_ids": removed_ids}

func snapshot() -> Array:
	return _active.values().duplicate(true)
