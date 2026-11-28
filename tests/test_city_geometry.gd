extends SceneTree
const World = preload("res://scripts/original_world.gd")
const Geometry = preload("res://scripts/city_geometry.gd")
const Effects = preload("res://scripts/journey_effects.gd")
const PATH := "user://s108-geometry.json"
const FACES := [[10,30,2,3], [10,31,0,3], [11,31,1,3], [12,31,3,3],
	[10,32,1,3], [11,32,3,3], [26,34,2,13], [26,35,0,13]]
var checks := 0
var failures := 0

func new_world():
	var world = World.new()
	world.character.stat_display = {}  # Neutral display is normalized on load.
	return world

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func write_save(data: Dictionary) -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "", true, true))
	file.close()

func follow(world, target: Vector2i) -> bool:
	var path: Array = world.find_route(target)
	if path.is_empty() and world.position != target:
		return false
	for next in path:
		world.facing = world.DIRECTIONS.find(next - world.position)
		if world.facing < 0:
			return false
		if world.examinable_boundary(world.position, world.facing):
			world.interact()
		if not world.step() or world.position != next:
			return false
	return world.position == target

func _initialize() -> void:
	for face in FACES:
		var world = new_world()
		world.position = Vector2i(face[0], face[1])
		world.facing = face[2]
		var start: Vector2i = world.position
		var direction: Vector2i = world.DIRECTIONS[world.facing]
		check(world.edge(start, world.facing) == face[3], "Exact corrected face: " + str(face))
		check(not world.step() and world.position == start, "Closed door/wall rejects initial movement")
		if face[3] == 3:
			check(world.action_text() == "OPEN DOOR", "New face is visibly a door")
			world.interact()
			check(world.step() and world.position == start + direction, "Opened new doorway traverses")
			world.facing = posmod(world.facing + 2, 4)
			check(not world.door_open(world.position, world.facing), "Opposite face stays independently closed")
		else:
			world.doors[world.door_key(start, world.facing)] = true
			world.interact()
			check(not world.step() and world.position == start, "Wall blocks even with stale opened key")
		check(world.save_game(PATH) == OK, "Save on corrected boundary succeeds")
		var restored = new_world()
		check(restored.load_game(PATH) and restored.position == world.position, "Current save preserves position")
		check(Effects.same_saved_value(world.save_snapshot(), restored.save_snapshot()), "Current full state round trip")
		# Every supported old format is exercised at both sides of each boundary.
		for version in range(3, 9):
			var old: Dictionary = world.save_snapshot()
			old.version = version
			old.erase("city_geometry_revision")
			if version < 8: old.erase("gameplay_random")
			if version < 7: old.erase("effects")
			if version < 5: old.erase("clock")
			old.position = [start.x, start.y]
			old.facing = face[2]
			old.doors = {"city:39,35:0": true, "dungeon:26,34:2": true, "unknown:legacy:key": false}
			for key in Geometry.RETIRED_DOOR_KEYS + Geometry.ADDED_DOOR_KEYS:
				old.doors[key] = true
			write_save(old)
			check(restored.load_game(PATH) and restored.position == start, "Legacy position retained v%d" % version)
			check(restored.doors == {"city:39,35:0": true, "dungeon:26,34:2": true, "unknown:legacy:key": false}, "Only changed-face keys normalized")
			check(not restored.step(), "Migrated new door defaults closed; wall remains blocked")
			check(restored.save_game(PATH) == OK and restored.load_game(PATH), "Migrated save resaves and reloads")
	var world = new_world()
	world.position = Vector2i(10,31)
	world.facing = 0
	world.interact()
	world.activate_physical_speed()
	world.advance_game_microseconds(1234567)
	var good: Dictionary = world.save_snapshot()
	write_save(good)
	var restored = new_world()
	check(restored.load_game(PATH) and restored.door_open(Vector2i(10,31), 0), "Revision-aware door state retained")
	check(Effects.same_saved_value(good, restored.save_snapshot()), "Revision-aware clock, effect and RNG retained")
	var before: Dictionary = restored.save_snapshot()
	for revision in [null, false, 0, 2, "1", 1.5]:
		var bad := good.duplicate(true)
		bad.city_geometry_revision = revision
		write_save(bad)
		check(not restored.load_game(PATH) and Effects.same_saved_value(before, restored.save_snapshot()), "Invalid geometry revision rejected atomically")
	var bad := good.duplicate(true)
	bad.erase("city_geometry_revision")
	write_save(bad)
	check(not restored.load_game(PATH), "Version 9 requires geometry revision")
	bad = good.duplicate(true)
	bad.version = 8
	write_save(bad)
	check(not restored.load_game(PATH), "Downgraded revision-aware save rejected")
	bad.erase("city_geometry_revision")
	bad.doors[Geometry.RETIRED_DOOR_KEYS[0]] = "invalid"
	write_save(bad)
	check(not restored.load_game(PATH) and Effects.same_saved_value(before, restored.save_snapshot()), "Invalid retired-key type cannot be hidden by migration")
	# Exercise actual model movement for each newly reachable cell and its return,
	# rather than accepting graph reachability as proof of playable traversal.
	var analysis = JSON.parse_string(FileAccess.get_file_as_string("res://docs/s05/proposed-eight-face-route-review.json"))
	for coords in analysis.gained_start_cells:
		world = new_world()
		world.leave_tavern()
		var target := Vector2i(coords[0], coords[1])
		check(follow(world, target), "Actual route reaches newly accessible cell " + str(target))
		check(world.save_game(PATH) == OK and world.load_game(PATH), "Newly accessible cell saves/loads")
		check(follow(world, World.TAVERN_POSITION), "Actual return route from " + str(target))
	# Existing chapter interaction and southeast non-transition stay unchanged.
	world = new_world()
	world.leave_tavern()
	check(follow(world, Vector2i(49,3)), "North entrance remains reachable")
	world.facing = 1
	world.interact()
	check(world.chapter == "dungeon", "North enters Dungeon")
	world.interact()
	check(world.chapter == "city" and follow(world, World.TAVERN_POSITION), "North returns to tavern")
	world.position = Vector2i(59,62)
	for facing in range(4):
		world.facing = facing
		world.interact()
		check(world.chapter == "city", "Southeast marker does not gain chapter crossing")
	print("S108 geometry and migration: %d checks, %d failures" % [checks, failures])
	quit(failures)
