extends SceneTree

const Definitions = preload("res://scripts/effect_definitions.gd")
var failures := 0
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func sample(definition_id: String) -> Dictionary:
	return {
		"definition_id": definition_id, "definition_revision": 1,
		"disallow_multiple": true,
		"comparison": {
			"effect_type": 3, "interval_raw": 20, "natural_cure_raw": 0,
			"action_raw": 128, "target_offset_raw": 12, "block_count_raw": 1,
			"block_gap_raw": 0, "parameter_raw": 5,
		},
	}

func _initialize() -> void:
	var definitions = Definitions.new()
	var candidate := sample("first")
	var original := candidate.duplicate(true)
	check(definitions.register_definition(candidate).ok, "register valid comparison definition")
	candidate.comparison.parameter_raw = 99
	check(definitions.definition_snapshot("first").definition == original, "input cannot mutate template")
	var snapshot: Dictionary = definitions.definition_snapshot("first").definition
	snapshot.comparison.parameter_raw = 88
	check(definitions.definition_snapshot("first").definition == original, "snapshot cannot mutate template")
	check(not definitions.register_definition(sample("first")).ok, "duplicate identity rejected")
	check(not definitions.definition_snapshot("missing").ok, "missing identity rejected")
	check(definitions.register_definition(sample("different_id")).ok, "independent definition identity")
	var equal_active := [sample("different_id").comparison]
	check(definitions.check_duplicate_gate("first", equal_active).suppress_current_and_following,
		"ET02: content equality suppresses current and following regardless of identity")
	# Every source field contributes to equality; not just type or parameter.
	for field in Definitions.COMPARISON_FIELDS:
		var changed: Dictionary = original.comparison.duplicate(true)
		changed[field] += 1
		check(not definitions.check_duplicate_gate("first", [changed]).suppress_current_and_following,
			"ET03/generalized: changing %s prevents this match" % field)
	check(not definitions.check_duplicate_gate("first", []).suppress_current_and_following,
		"empty active list does not suppress")
	var allow_multiple := sample("gate_disabled")
	allow_multiple.disallow_multiple = false
	check(definitions.register_definition(allow_multiple).ok, "register H-off definition")
	check(not definitions.check_duplicate_gate("gate_disabled", equal_active).suppress_current_and_following,
		"H-off bypasses this gate only; does not assert stacking or activation")
	check(not definitions.check_duplicate_gate("first", [original.comparison, {}]).ok,
		"malformed entry after match is rejected")
	check(not definitions.check_duplicate_gate("missing", []).ok, "unknown gate definition rejected")
	for invalid_value in [1.0, "1", true, -1]:
		var invalid := sample("bad")
		invalid.comparison.interval_raw = invalid_value
		check(not definitions.register_definition(invalid).ok, "reject noninteger/negative raw encoding")
	var extra := sample("extra")
	extra.required_event = "Use"
	check(not definitions.register_definition(extra).ok, "unsupported event semantics not accepted")
	check(not definitions.definition_snapshot("extra").ok, "failed validation leaves registry unchanged")
	# Use the archived research fixture's reviewed expected outcome, not a captured
	# production result. No timer/expiry or unresolved dispatch traces are executed.
	var traces = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/effect_traces.json"))
	for trace in traces.traces:
		if trace.id == "ET02":
			var gate: Dictionary = definitions.check_duplicate_gate("first", equal_active)
			check(gate.suppress_current_and_following == not trace.expected.current_activated,
				"ET02 fixture current outcome")
			check(gate.suppress_current_and_following == not trace.expected.following_activated,
				"ET02 fixture following outcome")
		if trace.id == "ET03":
			var changed: Dictionary = original.comparison.duplicate(true)
			changed.parameter_raw += 1
			check(definitions.check_duplicate_gate("first", [changed]).suppress_current_and_following
				== trace.expected.blocked_by_this_match, "ET03 fixture changed-parameter outcome")
	print("Effect definition foundation: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
