extends SceneTree
const World = preload("res://scripts/original_world.gd")
const Effects = preload("res://scripts/journey_effects.gd")
const Clock = preload("res://scripts/game_clock.gd")
const M := 60000000
const SAVE := "user://s31-effects.json"
const INVALID := "user://s31-invalid.json"
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func write_save(data: Dictionary) -> void:
	var file := FileAccess.open(INVALID, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "", true, true))
	file.close()

func state(world) -> Dictionary:
	return {"character": world.character.duplicate(true), "clock": world.game_clock.snapshot(),
		"effects": world.journey_effects.save_payload(), "chapter": world.chapter,
		"position": world.position, "facing": world.facing, "needs": world.needs.duplicate(true),
		"inventory": world.inventory.duplicate(true), "doors": world.doors.duplicate(true),
		"flags": world.flags.duplicate(true), "revision": world.revision, "journal": world.journal}

func _initialize() -> void:
	var world = World.new()
	world.set_stat_base("speed", 13)
	world.set_stat_modifiers("speed", 0, 0)
	world.character.speed_revealed = true
	check(world.walking_speed() == 6 and world.effective_speed() == 13, "Initial Speed 13 / walking 6")
	check(world.activate_physical_speed().activated, "Production activation succeeds")
	check(world.effective_speed() == 18 and world.stat_snapshot("speed").displayed == 18 and world.character.speed == 13 and world.walking_speed() == 6, "Bonus changes effective/displayed Speed only")
	world.advance_game_microseconds(10 * M)
	var expected: Dictionary = world.journey_effects.save_payload()
	check(not world.activate_physical_speed().activated and world.journey_effects.save_payload() == expected and world.character.speed_bonus == 5, "Repeat activation neither stacks nor refreshes")
	check(world.save_game(SAVE) == OK, "Save active effect at minute ten")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	check(data.version == 9 and data.effects.version == 1, "Versioned effect save format")
	var loaded = World.new()
	check(loaded.load_game(SAVE), "Load active effect")
	check(loaded.physical_speed_remaining_game_microseconds() == 20 * M and loaded.character.speed_bonus == 5, "Reload retains twenty minutes and one grant")
	check(loaded.journey_effects.save_payload() == expected, "Identity, links, slot, counter, incubation and deadline survive JSON")
	for interval in [19 * M, M - 1, 1]:
		world.advance_game_microseconds(interval)
		loaded.advance_game_microseconds(interval)
		check(Effects.same_saved_value(world.stat_snapshot("speed"), loaded.stat_snapshot("speed")) and world.character.speed_bonus == loaded.character.speed_bonus and world.journey_effects.save_payload() == loaded.journey_effects.save_payload(), "Reloaded and uninterrupted trajectories agree")
	check(loaded.effective_speed() == 13 and loaded.journey_effects.runtime.snapshot().active.is_empty(), "Explicit Sub5 and linked cleanup at thirty minutes")
	check(loaded.activate_physical_speed().activated and loaded.journey_effects.save_payload().active[0].instance_id == 3, "Recast uses new identity after restored expiry")
	check(loaded.save_game(SAVE) == OK, "Recast saves")
	check(loaded.load_game(SAVE) and loaded.character.speed_bonus == 5, "Repeated reload never replays grant")
	data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	var before: Dictionary = state(loaded)
	for mutation in [{"definition_id": "unknown"}, {"definition_revision": 2}, {"owner_id": "other"},
		{"group_id": 999}, {"instance_id": 1}, {"slot": 1}, {"slot_count": 2},
		{"remaining_executions": 0}, {"unbounded": true}, {"incubating": true},
		{"due_game_microseconds": loaded.game_time_boundary()},
		{"due_game_microseconds": loaded.game_time_boundary() + 30 * M + 1},
		{"action": {"target": "hp"}}, {"due_game_microseconds": 1.5}]:
		var bad := data.duplicate(true)
		bad.effects.active[0].merge(mutation, true)
		write_save(bad)
		check(not loaded.load_game(INVALID) and state(loaded) == before, "Malformed record rejects whole load: " + str(mutation))
	for mutation in [{"version": 2}, {"next_instance_id": 2}, {"next_instance_id": -1},
		{"now_game_microseconds": 0}, {"active": []}, {"extra": true}]:
		var bad := data.duplicate(true)
		bad.effects.merge(mutation, true)
		if mutation == {"active": []}:
			# Empty state is valid independently of stat bytes: legacy or unrelated
			# bonuses must never be reverse-engineered into effects.
			continue
		write_save(bad)
		check(not loaded.load_game(INVALID) and state(loaded) == before, "Malformed envelope rejects whole load")
	for index in [0, 1]:
		var bad := data.duplicate(true)
		bad.effects.active.remove_at(index)
		write_save(bad)
		check(not loaded.load_game(INVALID) and state(loaded) == before, "Partial linked group rejected")
	var bad := data.duplicate(true)
	bad.effects.active[1].visible = false
	write_save(bad)
	check(not loaded.load_game(INVALID) and state(loaded) == before, "Invalid text visibility rejected")
	bad = data.duplicate(true)
	bad.erase("effects")
	write_save(bad)
	check(not loaded.load_game(INVALID) and state(loaded) == before, "Current save requires effect payload")
	for version in [3, 4, 5, 6]:
		var legacy := data.duplicate(true)
		legacy.version = version
		legacy.erase("city_geometry_revision")
		legacy.erase("effects")
		legacy.erase("gameplay_random")  # Legacy fixtures predate v8.
		write_save(legacy)
		check(loaded.load_game(INVALID) and loaded.physical_speed_remaining_game_microseconds() == 0 and loaded.character.speed_bonus == 5, "Legacy save keeps character byte without inventing an effect")
		loaded.advance_game_microseconds(30 * M)
		check(loaded.character.speed_bonus == 5, "Legacy bonus receives no invented expiry")
	bad = data.duplicate(true)
	bad.version = 6
	bad.erase("city_geometry_revision")
	write_save(bad)
	check(not loaded.load_game(INVALID), "Downgraded version cannot silently drop effects")
	var precise = World.new()
	precise.activate_physical_speed()
	precise.advance_game_microseconds(10 * M + 1234567)
	precise.advance_real_seconds(1.0 / 30000000.0)
	check(precise.save_game(SAVE) == OK and loaded.load_game(SAVE), "Fractional deadline save/load")
	check(loaded.physical_speed_remaining_game_microseconds() == precise.physical_speed_remaining_game_microseconds() and loaded.game_clock.snapshot() == precise.game_clock.snapshot(), "Microseconds and conversion remainder survive")
	before = state(loaded)
	loaded.advance_real_seconds(1000, "paused")
	check(state(loaded) == before, "Pause preserves complete effect/clock state")
	loaded.advance_real_seconds(4)
	check(loaded.physical_speed_remaining_game_microseconds() == precise.physical_speed_remaining_game_microseconds() - M, "Ordinary time uses integrated runtime")
	loaded.advance_service_seconds(1.0 / 60.0)
	check(loaded.physical_speed_remaining_game_microseconds() == precise.physical_speed_remaining_game_microseconds() - 2 * M, "Accelerated service uses integrated runtime once")
	var travel = World.new()
	travel.activate_physical_speed()
	travel.position = Vector2i(49, 3)
	travel.facing = 1
	travel.interact()
	check(travel.chapter == "dungeon" and travel.physical_speed_remaining_game_microseconds() == 25 * M and travel.character.speed_bonus == 5, "City to Dungeon retains effect and charges five minutes")
	check(travel.save_game(SAVE) == OK and loaded.load_game(SAVE), "Active effect restores in Dungeon")
	loaded.interact()
	check(loaded.chapter == "city" and loaded.physical_speed_remaining_game_microseconds() == 20 * M and loaded.character.speed_bonus == 5, "Dungeon return preserves same effect")
	loaded.advance_game_microseconds(20 * M)
	check(loaded.character.speed_bonus == 0, "Cross-chapter effect expires normally")
	var saturated = World.new()
	saturated.set_stat_modifiers("speed", 253, 0)
	saturated.activate_physical_speed()
	check(saturated.character.speed_bonus == 255, "Grant uses saturating S08 Add")
	saturated.advance_game_microseconds(30 * M)
	check(saturated.character.speed_bonus == 250, "Expiry uses explicit Sub, not invented rollback")
	var overflow = World.new()
	overflow.game_clock.game_microseconds = Clock.MAX_GAME_MICROSECONDS - M
	var original_character: Dictionary = overflow.character.duplicate(true)
	check(not overflow.activate_physical_speed().ok and overflow.character == original_character and overflow.physical_speed_remaining_game_microseconds() == 0, "Failed activation cannot grant or create partial records")
	var guarded = World.new()
	guarded.activate_physical_speed()
	var observer = func(_start, _end):
		check(not guarded.activate_physical_speed().ok, "Clock observer cannot activate reentrantly")
		check(guarded.save_game(INVALID) == ERR_BUSY, "Clock observer cannot save partial interval")
		check(not guarded.load_game(SAVE), "Clock observer cannot replace state during interval")
		check(not guarded.advance_game_microseconds(1).ok, "Clock observer cannot charge time again")
	guarded.game_time_advanced.connect(observer)
	guarded.advance_game_microseconds(M)
	guarded.game_time_advanced.disconnect(observer)
	check(guarded.physical_speed_remaining_game_microseconds() == 29 * M and guarded.character.speed_bonus == 5, "Reentrant attempts leave effect intact")
	before = state(guarded)
	check(not guarded.advance_real_seconds(-1).ok and state(guarded) == before, "Rejected elapsed interval changes no effect/world state")
	var empty = World.new()
	check(empty.save_game(SAVE) == OK and empty.load_game(SAVE) and empty.physical_speed_remaining_game_microseconds() == 0, "Empty v7 effect set round-trips")
	empty.journey_effects.runtime.queue_events(Effects.OWNER, 4, empty.game_time_boundary() + M)
	check(empty.save_game(SAVE) == ERR_INVALID_DATA, "Unsupported queued work cannot be silently lost in a save")
	var near_ceiling = World.new()
	near_ceiling.game_clock.game_microseconds = Clock.MAX_GAME_MICROSECONDS - 30 * M
	near_ceiling.activate_physical_speed()
	near_ceiling.advance_game_microseconds(20 * M)
	check(near_ceiling.save_game(SAVE) == OK and loaded.load_game(SAVE) and loaded.physical_speed_remaining_game_microseconds() == 10 * M, "Near-ceiling restore preserves deadline without allocating a fresh thirty-minute timer")
	loaded.advance_game_microseconds(10 * M)
	check(loaded.game_time_boundary() == Clock.MAX_GAME_MICROSECONDS and loaded.character.speed_bonus == 0, "Restored effect expires exactly at supported clock ceiling")
	print("S31 journey effects: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
