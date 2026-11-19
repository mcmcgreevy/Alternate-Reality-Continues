extends RefCounted
## S29 foundation only: immutable definitions and the documented duplicate gate.
## This deliberately does not dispatch events, allocate active slots or undo stats.
## Source: Kroah ST City v2.0 technicalNotes.html, Effect / +02 Required events.

const COMPARISON_FIELDS := [
	"effect_type", "interval_raw", "natural_cure_raw", "action_raw",
	"target_offset_raw", "block_count_raw", "block_gap_raw", "parameter_raw",
]
const DEFINITION_FIELDS := ["definition_id", "definition_revision", "disallow_multiple", "comparison"]
var _definitions: Dictionary = {}

## Values remain opaque nonnegative raw encodings; acceptance here is NOT approval
## to execute a native action/target. The runtime decoder remains blocked by ER12.
func register_definition(candidate: Dictionary) -> Dictionary:
	var error := _definition_error(candidate)
	if not error.is_empty():
		return {"ok": false, "error": error}
	var definition_id: String = candidate.definition_id
	if _definitions.has(definition_id):
		return {"ok": false, "error": "definition_id_already_registered"}
	# Deep copies on entry and exit prevent caller mutation of registered templates.
	_definitions[definition_id] = candidate.duplicate(true)
	return {"ok": true}

func definition_snapshot(definition_id: String) -> Dictionary:
	if not _definitions.has(definition_id):
		return {"ok": false, "error": "unknown_definition_id"}
	return {"ok": true, "definition": _definitions[definition_id].duplicate(true)}

## Pure comparison stage: caller supplies the entire active-list comparison view
## after any resolved opposing removals. No owner filter and no event assumptions.
## The list contains raw eight-field dictionaries, not live mutable instances.
func check_duplicate_gate(definition_id: String, active_comparisons: Array) -> Dictionary:
	if not _definitions.has(definition_id):
		return {"ok": false, "error": "unknown_definition_id"}
	# Validate the full input before producing a result, including entries after a
	# potential match. Malformed evidence is not silently ignored as unequal.
	for comparison in active_comparisons:
		if not comparison is Dictionary or not _comparison_error(comparison).is_empty():
			return {"ok": false, "error": "invalid_active_comparison"}
	var definition: Dictionary = _definitions[definition_id]
	if not definition.disallow_multiple:
		return {"ok": true, "suppress_current_and_following": false}
	for comparison in active_comparisons:
		if _same_comparison(definition.comparison, comparison):
			return {"ok": true, "suppress_current_and_following": true}
	return {"ok": true, "suppress_current_and_following": false}

func _same_comparison(first: Dictionary, second: Dictionary) -> bool:
	for field in COMPARISON_FIELDS:
		if first[field] != second[field]:
			return false
	return true

func _definition_error(candidate: Dictionary) -> String:
	if candidate.size() != DEFINITION_FIELDS.size():
		return "unsupported_definition_fields"
	for field in DEFINITION_FIELDS:
		if not candidate.has(field):
			return "missing_definition_field"
	if not candidate.definition_id is String or candidate.definition_id.strip_edges().is_empty():
		return "invalid_definition_id"
	if not candidate.definition_revision is int or candidate.definition_revision < 1:
		return "invalid_definition_revision"
	if not candidate.disallow_multiple is bool:
		return "invalid_duplicate_flag"
	if not candidate.comparison is Dictionary:
		return "invalid_comparison"
	return _comparison_error(candidate.comparison)

func _comparison_error(comparison: Dictionary) -> String:
	if comparison.size() != COMPARISON_FIELDS.size():
		return "unsupported_comparison_fields"
	for field in COMPARISON_FIELDS:
		if not comparison.has(field):
			return "missing_comparison_field"
		if not comparison[field] is int or comparison[field] < 0:
			return "invalid_raw_encoding"
	return ""
