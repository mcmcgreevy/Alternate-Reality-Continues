extends SceneTree
const World = preload("res://scripts/original_world.gd")
const Store = preload("res://scripts/journey_save_store.gd")
const RandomStream = preload("res://scripts/journey_random.gd")
const Effects = preload("res://scripts/journey_effects.gd")
const SAVE := "user://s02.json"
const BAD := "user://s02-bad.json"
var checks := 0
var failures := 0

class FailingStore extends "res://scripts/journey_save_store.gd":
	var stage := "write"
	func write_temporary(path: String, text: String) -> Error:
		if stage == "write":
			super.write_temporary(path, text.left(12))
			return ERR_FILE_CANT_WRITE
		return super.write_temporary(path, text)
	func move_file(source: String, destination: String) -> Error:
		if stage == "preserve" or (stage in ["replace", "rollback"] and source.ends_with(".pending")) or (stage == "rollback" and source.ends_with(".previous")):
			return ERR_FILE_CANT_WRITE
		return super.move_file(source, destination)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func write_data(data: Variant, path: String = BAD) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "", true, true))
	file.close()

func state(world) -> Dictionary:
	return {"save": world.save_snapshot(), "revision": world.revision, "journal": world.journal,
		"override": world.weather_override_index, "runtime": world.journey_effects.runtime.snapshot()}

func random_step(world) -> bool:
	world.chapter = "dungeon"
	world.position = Vector2i(40, 14)
	world.facing = 2
	if world.edge(world.position, 2) in [3, 4, 5, 6]:
		world.interact()
	return world.step()

func _initialize() -> void:
	for path in [SAVE, BAD, SAVE + ".pending", SAVE + ".previous"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	var world = World.new()
	world.character.stat_display = {}
	world.character["custom_note"] = "preserved extension"
	world.weather_seed = 808
	world.gameplay_random = RandomStream.new(-9223372036854775807)
	world.activate_physical_speed()
	world.advance_real_seconds(0.123456789)
	check(world.save_game(SAVE) == OK, "Validated current save succeeds")
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	var loaded = World.new()
	check(loaded.load_game(SAVE), "Current save loads")
	check(Effects.same_saved_value(world.save_snapshot(), loaded.save_snapshot()), "Every persisted field survives JSON round trip")
	check(loaded.character.custom_note == "preserved extension", "Optional character extension survives")
	for i in range(16):
		check(random_step(world), "Source random transition reached")
		for unused in range(13): randi()
		check(random_step(loaded), "Reloaded source transition reached")
		world.advance_game_microseconds(1234567)
		loaded.advance_game_microseconds(1234567)
		check(Effects.same_saved_value(world.save_snapshot(), loaded.save_snapshot()), "Replay unaffected by global draws")
	var first_sequence: Array = []
	for repeat in range(2):
		check(loaded.load_game(SAVE), "Repeated load succeeds")
		var sequence: Array = []
		for i in range(12):
			random_step(loaded)
			sequence.append(loaded.facing)
		if repeat == 0: first_sequence = sequence
		else: check(sequence == first_sequence, "Repeated reload reproduces sequence")
	var random_before: Dictionary = loaded.gameplay_random.snapshot()
	loaded.position = Vector2i(42, 8)
	loaded.facing = 0
	if loaded.edge(loaded.position, 0) in [3,4,5,6]: loaded.interact()
	check(loaded.step() and loaded.facing == 3 and loaded.gameplay_random.snapshot() == random_before, "Fixed facing consumes no draw")
	loaded.position = Vector2i(18, 24)
	loaded.facing = 0
	if loaded.edge(loaded.position, 0) in [3,4,5,6]: loaded.interact()
	check(loaded.step() and loaded.position == Vector2i(16, 1) and loaded.facing == 0 and loaded.gameplay_random.snapshot() == random_before, "Preserve-facing link consumes no draw")
	# No-op and malformed loads must retain full live state, including random stream.
	var before := state(loaded)
	for key in data:
		var bad: Dictionary = data.duplicate(true)
		bad[key] = null
		write_data(bad)
		check(not loaded.load_game(BAD) and state(loaded) == before, "Null field rejects atomically: " + key)
	for mutation in [{"position": [4294967335,34]}, {"position": [1e100,34]}, {"version": true}, {"version": 10}, {"chapter": []}, {"provisions": {"food":1e100,"water":0}}, {"needs":{"hunger":0,"thirst":0,"extra":"bad"}}, {"flags":{"visited_dungeon":false,"returned":false,"extra":12}}, {"inventory":[123]}, {"doors":{"city:39,34:0":12}}, {"facing":1e100}]:
		var bad: Dictionary = data.duplicate(true)
		bad.merge(mutation, true)
		write_data(bad)
		check(not loaded.load_game(BAD) and state(loaded) == before, "Malformed envelope rejects atomically: " + str(mutation))
	for mutation in [{"format":"future"}, {"state":"9223372036854775808"}, {"seed":1701}, {"state":"01"}]:
		var bad: Dictionary = data.duplicate(true)
		bad.gameplay_random.merge(mutation, true)
		write_data(bad)
		check(not loaded.load_game(BAD) and state(loaded) == before, "Invalid random state rejects atomically")
	var file := FileAccess.open(BAD, FileAccess.WRITE)
	file.store_string("{\"version\":")
	file.close()
	check(not loaded.load_game(BAD) and state(loaded) == before, "Truncated JSON rejects atomically")
	check(not loaded.load_game("user://s02-never-created.json") and state(loaded) == before, "Missing file rejects atomically")
	for version in range(3,8):
		var legacy: Dictionary = data.duplicate(true)
		legacy.version = version
		legacy.erase("city_geometry_revision")
		legacy.erase("gameplay_random")
		if version < 7: legacy.erase("effects")
		if version < 5: legacy.erase("clock")
		write_data(legacy)
		check(loaded.load_game(BAD), "Legacy version loads: " + str(version))
		check(loaded.gameplay_random.snapshot() == RandomStream.new(1701).snapshot(), "Legacy random seed is stable")
		check(loaded.character.custom_note == "preserved extension" and loaded.weather_seed == 808, "Legacy optional values preserved")
		check(loaded.save_game(BAD) == OK and loaded.load_game(BAD), "Migrated version resaves/reloads")
	# Saving invalid live data must not overwrite the last good save.
	var good_bytes := FileAccess.get_file_as_bytes(SAVE)
	loaded.provisions.food = -1
	check(loaded.save_game(SAVE) == ERR_INVALID_DATA and FileAccess.get_file_as_bytes(SAVE) == good_bytes, "Invalid live snapshot cannot replace save")
	loaded.provisions.food = 0
	for stage in ["write", "preserve", "replace", "rollback"]:
		var failure := FailingStore.new()
		failure.stage = stage
		loaded.save_store = failure
		check(loaded.save_game(SAVE) != OK, "Injected failure reported: " + stage)
		check(FileAccess.get_file_as_bytes(failure.readable_path(SAVE)) == good_bytes, "Previous committed bytes retained: " + stage)
		check(World.new().load_game(SAVE), "Previous save remains loadable: " + stage)
		loaded.save_store = Store.new()
		# Recover backup without committing different content for the next case.
		if not FileAccess.file_exists(SAVE): DirAccess.rename_absolute(SAVE + ".previous", SAVE)
	check(loaded.save_game("user://s02-missing-directory/save.json") != OK, "Missing destination folder reports failure")
	DirAccess.make_dir_absolute(SAVE + ".pending")
	check(loaded.save_game(SAVE) != OK and FileAccess.get_file_as_bytes(SAVE) == good_bytes, "Unwritable temporary target preserves committed save")
	DirAccess.remove_absolute(SAVE + ".pending")
	# Emulate a crash between preserving old destination and publishing new file.
	DirAccess.rename_absolute(SAVE, SAVE + ".previous")
	write_data({"incomplete":true}, SAVE + ".pending")
	check(loaded.load_game(SAVE), "Interrupted transaction loads committed backup, never pending file")
	check(loaded.save_game(SAVE) == OK and not FileAccess.file_exists(SAVE + ".previous") and not FileAccess.file_exists(SAVE + ".pending"), "Next successful save recovers and cleans transaction")
	print("S02 persistence: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
