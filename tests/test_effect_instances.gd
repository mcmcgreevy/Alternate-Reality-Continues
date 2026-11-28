extends SceneTree

const Definitions = preload("res://scripts/effect_definitions.gd")
const Instances = preload("res://scripts/effect_instances.gd")
var checks := 0
var failures := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func definition(identifier: String, block_duplicates: bool, parameter: int = 5) -> Dictionary:
	return {"definition_id": identifier, "definition_revision": 1,
		"disallow_multiple": block_duplicates,
		"comparison": {"effect_type": 3, "interval_raw": 1, "natural_cure_raw": 0,
			"action_raw": 129, "target_offset_raw": 6318, "block_count_raw": 1,
			"block_gap_raw": 0, "parameter_raw": parameter}}

func entry(identifier: String, linked: bool = false) -> Dictionary:
	return {"definition_id": identifier, "link_to_previous": linked}

func _initialize() -> void:
	var definitions = Definitions.new()
	for candidate in [definition("repeatable", false), definition("guarded", true),
		definition("other", false, 6), definition("other_guarded", true, 6)]:
		check(definitions.register_definition(candidate).ok, "register test definition")
	var runtime = Instances.new(definitions)
	var first: Dictionary = runtime.activate_sequence("owner-a", [entry("repeatable", true), entry("other", true)])
	check(first.ok and first.created_ids.size() == 2, "first-00 activation creates two records")
	var records: Array = runtime.snapshot()
	check(records[0].group_id == records[0].instance_id, "first-00 starts own group")
	check(records[1].group_id == records[0].group_id, "00 joins last activated group")
	check(records[0].owner_id == "owner-a", "instance retains owning entity identity")
	records[0].definition.comparison.parameter_raw = 100
	records[0].owner_id = "intruder"
	check(runtime.snapshot()[0].owner_id == "owner-a", "snapshot cannot reassign owner")
	check(runtime.snapshot()[0].definition.comparison.parameter_raw == 5, "snapshot cannot mutate instance")
	check(definitions.definition_snapshot("repeatable").definition.comparison.parameter_raw == 5,
		"activation and snapshot cannot mutate definition")
	var second: Dictionary = runtime.activate_sequence("owner-b", [entry("repeatable"), entry("other", true)])
	check(second.created_ids.size() == 2, "H-off permits fresh copies for another owner")
	check(runtime.snapshot()[2].group_id != runtime.snapshot()[0].group_id, "owners have independent groups")
	var blocked: Dictionary = runtime.activate_sequence("owner-c", [entry("guarded"), entry("other")])
	check(blocked.suppressed_at == 0 and blocked.created_ids.is_empty(), "global H gate suppresses current and tail across owners")
	check(runtime.snapshot().size() == 4, "suppression creates no following record")
	var before: Array = runtime.snapshot()
	var bad: Dictionary = runtime.activate_sequence("owner-a", [entry("repeatable"), entry("missing")])
	check(not bad.ok and runtime.snapshot() == before, "invalid trailing reference rejects without partial allocation")
	bad = runtime.activate_sequence("owner-a", [entry("guarded"), entry("missing")])
	check(not bad.ok, "invalid tail rejected even after an otherwise suppressing match")
	for invalid in [{}, entry("repeatable").merged({"event": "Use"}),
		{"definition_id": "repeatable", "link_to_previous": 1}, null]:
		check(not runtime.activate_sequence("owner-a", [invalid]).ok, "unsupported activation shape rejected")
	check(runtime.snapshot() == before, "all failed requests preserve active state")
	check(not runtime.activate_sequence(" ", [entry("repeatable")]).ok, "blank owner rejected")
	check(not runtime.remove_group("owner-a", 0).ok, "invalid group rejected")
	check(not runtime.remove_owner("").ok, "invalid owner removal rejected")
	var group_a: int = runtime.snapshot()[0].group_id
	check(runtime.remove_group("owner-b", group_a).removed_ids.is_empty(), "wrong owner cannot remove group")
	check(runtime.remove_group("owner-a", group_a).removed_ids == first.created_ids, "remove precisely the linked group")
	check(runtime.snapshot().size() == 2 and runtime.snapshot()[0].owner_id == "owner-b", "unrelated owner survives")
	check(runtime.remove_group("owner-a", group_a).removed_ids.is_empty(), "repeat removal is harmless")
	var replacement: Dictionary = runtime.activate_sequence("owner-a", [entry("repeatable")])
	check(replacement.created_ids[0] == 5, "invalid requests consume no IDs and removed IDs are not reused")
	check(runtime.remove_group("owner-a", group_a).removed_ids.is_empty(), "stale group cannot remove replacement")
	check(runtime.remove_owner("owner-b").removed_ids == second.created_ids, "owner cleanup preserves other owners")
	check(runtime.snapshot().size() == 1 and runtime.snapshot()[0].instance_id == 5, "replacement survives other owner cleanup")
	check(runtime.remove_owner("owner-b").removed_ids.is_empty(), "repeat owner cleanup is harmless")
	runtime.remove_owner("owner-a")
	var prefix: Dictionary = runtime.activate_sequence("owner-a", [entry("repeatable"), entry("guarded"), entry("other")])
	check(prefix.created_ids.size() == 1 and prefix.suppressed_at == 1, "H gate sees earlier records in same sequence and retains valid prefix")
	runtime.remove_owner("owner-a")
	runtime.activate_sequence("owner-b", [entry("repeatable")])
	var unequal: Dictionary = runtime.activate_sequence("owner-a", [entry("other_guarded")])
	check(unequal.created_ids.size() == 1, "same type with differing parameter is not suppressed")
	check(runtime.activate_sequence("owner-a", []).created_ids.is_empty(), "empty eligible sequence is a no-op")
	var same_owner = Instances.new(definitions)
	var group_one: Dictionary = same_owner.activate_sequence("owner", [entry("repeatable"), entry("other", true)])
	var group_two: Dictionary = same_owner.activate_sequence("owner", [entry("repeatable", true)])
	check(group_two.created_ids[0] == same_owner.snapshot()[2].group_id, "first-00 cannot link across activation calls for same owner")
	check(same_owner.remove_group("owner", group_one.created_ids[0]).removed_ids == group_one.created_ids,
		"removal preserves another group belonging to the same owner")
	check(same_owner.snapshot().size() == 1, "second same-owner group survives")
	check(same_owner.remove_owner("owner").removed_ids == group_two.created_ids, "owner cleanup removes remaining group")
	print("Effect instance ownership: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
