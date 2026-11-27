extends SceneTree
const Stats = preload("res://scripts/character_stats.gd")
const World = preload("res://scripts/original_world.gd")
const Definitions = preload("res://scripts/effect_definitions.gd")
const Instances = preload("res://scripts/effect_instances.gd")
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func action(operation: String = "add", parameter: int = 5) -> Dictionary:
	return {"target": "speed_bonus", "operation": operation, "operand_width": 1,
		"block_count": 1, "block_gap": 0, "parameter": parameter}

func write_save(data: Dictionary) -> void:
	var file := FileAccess.open("user://s08-invalid.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "", true, true))
	file.close()

func _initialize() -> void:
	var world = World.new()
	for stat in Stats.PRIMARY:
		check(world.set_stat_base(stat, 13.75).ok, "Set fractional " + stat)
		check(world.set_stat_modifiers(stat, 5, 2).ok, "Set modifiers " + stat)
		var view: Dictionary = world.stat_snapshot(stat)
		check(view.base == 13.75 and view.effective == 16 and view.displayed == 16, "Separate base/effective/displayed " + stat)
	check(not world.stat_snapshot("speed").visible, "Speed hidden until revealed")
	check(world.primary_stats_text().contains("SPD"), "Remake HUD shows Speed before a reveal event")
	world.character.speed_revealed = true
	check(world.stat_snapshot("speed").visible and world.primary_stats_text().contains("SPD"), "Reveal makes Speed available to HUD")
	var original: Dictionary = world.character.duplicate(true)
	check(world.set_stat_display({"strength": 255, "hp": 65000}).ok, "Injected display values accepted")
	check(world.stat_snapshot("strength").effective == 16 and world.stat_snapshot("strength").displayed == 255, "Displayed illusion cannot change effective stat")
	check(world.displayed_hit_points() == 65000 and world.character.hp == original.hp, "Displayed HP cannot change real HP")
	world.set_stat_display({})
	check(world.stat_snapshot("strength").displayed == 16 and world.displayed_hit_points() == original.hp, "Clearing display restores actual readings")
	var snapshot: Dictionary = world.character.duplicate(true)
	for value in [-1, NAN, INF, 1000001]:
		check(not world.set_stat_base("strength", value).ok and world.character == snapshot, "Invalid base rejected atomically")
	check(not world.set_stat_base("bogus", 13).ok and world.character == snapshot, "Unknown base rejected")
	check(not world.set_stat_modifiers("speed", 256, 0).ok and world.character == snapshot, "Speed byte range enforced")
	check(not world.set_stat_display({"strength": 1, "bogus": 5}).ok and world.character == snapshot, "Display batch validates before mutation")
	world.character.speed = 13
	world.character.speed_penalty = 0
	world.character.speed_bonus = 253
	var result: Dictionary = world.apply_stat_actions([action(), action("subtract")])
	check(result.ok and result.trace == [255, 250], "Saturating Add then Sub preserves source order")
	world.character.speed_bonus = 253
	check(world.apply_stat_actions([action("subtract"), action()]).trace == [248, 253], "Sub then Add is not reordered")
	world.character.speed_bonus = 2
	check(world.apply_stat_actions([action("subtract")]).after == 0, "Unsigned subtraction saturates at zero")
	world.character.speed_bonus = 0
	check(world.apply_stat_actions([action(), action("subtract")]).trace == [5, 0], "Physical Speed explicit action pair restores zero")
	world.apply_stat_actions([action(), action()])
	check(world.character.speed_bonus == 10, "Repeated explicit actions are arithmetic; activation suppression belongs to S29")
	var other = World.new()
	check(other.stat_snapshot("speed").bonus == 0, "No cross-character state mutation")
	var definitions = Definitions.new()
	definitions.register_definition({"definition_id": "s08", "definition_revision": 1, "disallow_multiple": false,
		"comparison": {"effect_type": 3, "interval_raw": 1, "natural_cure_raw": 0, "action_raw": 129,
		"target_offset_raw": 6318, "block_count_raw": 1, "block_gap_raw": 0, "parameter_raw": 5}})
	var instances = Instances.new(definitions)
	var activated: Dictionary = instances.activate_sequence("owner-a", [{"definition_id": "s08", "link_to_previous": false}])
	instances.remove_group("owner-a", activated.created_ids[0])
	check(world.character.speed_bonus == 10, "Removing effect records does not invent inverse stat action")
	snapshot = world.character.duplicate(true)
	for mutation in [{"target": "strength"}, {"operation": "multiply"}, {"parameter": -1}, {"parameter": 256},
		{"parameter": 5.0}, {"operand_width": 2}, {"block_count": 2}, {"block_gap": 1}, {"owner_id": "other"}]:
		var invalid := action()
		invalid.merge(mutation, true)
		check(not world.apply_stat_actions([action(), invalid]).ok and world.character == snapshot, "Invalid trailing action rejects whole batch " + str(mutation))
	check(world.apply_stat_actions([]).ok and world.character == snapshot, "Empty action batch is a no-op")
	world.character.speed_bonus = 0
	world.apply_stat_actions([action()])
	var expected: Dictionary = snapshot.duplicate(true)
	expected.speed_bonus = 5
	check(world.character == expected, "Speed action leaves every unrelated field unchanged")
	check(Stats.walking_speed({"speed": 13}) == 6 and Stats.walking_speed({"speed": 255}) == 36, "Derived walking rate and cap")
	check(Stats.primary_snapshot({"speed": 1, "speed_penalty": 5}, "speed").effective == -4, "Formula does not silently clamp effective stat")
	check(Stats.walking_speed({"speed": 1, "speed_penalty": 50}) == 0, "Movement safely floors a nonpositive walking rate")
	check(not Stats.primary_snapshot({}, "charisma").ok, "Missing creation roll is not invented")
	for stat in Stats.SECONDARY:
		var state := {}
		check(Stats.set_secondary(state, stat, 2).ok and Stats.secondary_snapshot(state, stat).value == 2, "Named secondary state " + stat)
	check(world.secondary_stat_snapshot("hunger").value == world.needs.hunger, "Needs keep their authoritative store")
	world.character.magical_protection = {"fire": 3}
	world.character.protection_efficiencies = {"fire": "immune"}
	var protection: Dictionary = world.secondary_stat_snapshot("magical_protection")
	protection.value.fire = 99
	check(world.character.magical_protection.fire == 3, "Protection snapshots cannot mutate live state")
	world.set_stat_base("strength", 12.999999999999998)
	world.set_stat_display({"strength": 200, "hp": 60000})
	check(world.save_game("user://s08-stats.json") == OK, "Save version 6 stats")
	var restored = World.new()
	check(restored.load_game("user://s08-stats.json"), "Load version 6 stats")
	var primary_preserved := true
	for stat in Stats.PRIMARY:
		var before_view: Dictionary = world.stat_snapshot(stat)
		var after_view: Dictionary = restored.stat_snapshot(stat)
		for field in ["base", "bonus", "penalty", "effective", "displayed", "visible"]:
			primary_preserved = primary_preserved and before_view[field] == after_view[field]
	check(primary_preserved and restored.displayed_hit_points() == 60000 and restored.character.magical_protection.fire == 3 and restored.character.protection_efficiencies.fire == "immune", "Fractions, modifiers, display and hidden/protection state survive exactly")
	check(int(restored.character.strength) == 12, "Saving cannot round a fractional base across an integer boundary")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("user://s08-stats.json"))
	for version in [3, 4, 5]:
		var legacy: Dictionary = data.duplicate(true)
		legacy.version = version
		legacy.erase("effects")  # Legacy fixtures predate v7.
		legacy.erase("gameplay_random")  # Legacy fixtures predate v8.
		for field in ["speed", "speed_bonus", "speed_penalty", "speed_revealed", "stat_display"]:
			legacy.character.erase(field)
		write_save(legacy)
		check(restored.load_game("user://s08-invalid.json") and restored.stat_snapshot("speed").base == 13 and not restored.stat_snapshot("speed").visible, "Legacy stat migration " + str(version))
	var before: Dictionary = restored.character.duplicate(true)
	for mutation in [{"speed_bonus": 256}, {"strength": -1}, {"stat_display": {"hp": 2.5}},
		{"speed_revealed": "yes"}, {"protection_efficiencies": {"fire": "maximum"}}]:
		var malformed: Dictionary = data.duplicate(true)
		malformed.character.merge(mutation, true)
		write_save(malformed)
		check(not restored.load_game("user://s08-invalid.json") and restored.character == before, "Malformed save rejects atomically " + str(mutation))
	print("S08 stats: %d checks, %d failures" % [checks, failures])
	quit(failures)
