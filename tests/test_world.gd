extends SceneTree
const World = preload("res://scripts/world.gd")
var failures := 0

func check(ok: bool, description: String) -> void:
	if not ok:
		failures += 1
		push_error(description)

func walk(world, target: Vector2i) -> void:
	# Breadth-first pathfinding exercises real movement and collision.
	var queue: Array[Vector2i] = [world.position]
	var parent: Dictionary = {world.position: world.position}
	while not queue.is_empty():
		var p: Vector2i = queue.pop_front()
		if p == target: break
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next: Vector2i = p + d
			if world.tile(next) != "#" and not parent.has(next):
				parent[next] = p
				queue.append(next)
	check(parent.has(target), "Target must be reachable")
	if not parent.has(target): return
	var path: Array[Vector2i] = []
	var cursor := target
	while cursor != world.position:
		path.push_front(cursor)
		cursor = parent[cursor]
	for p in path: check(world.move(p - world.position), "Movement succeeds along path")

func _initialize() -> void:
	var w = World.new()
	var initial_time: int = w.minutes
	w.turn(-1)
	check(w.facing == 3, "Turning left wraps to west")
	w.turn(2)
	check(w.facing == 1 and w.minutes == initial_time, "Turning does not advance time")
	check(w.step() and w.position == Vector2i(3, 2), "Forward follows east bearing")
	check(w.step(true) and w.position == Vector2i(2, 2), "Backward reverses bearing")
	check(w.strafe(true) and w.position == Vector2i(2, 3), "Strafe right follows relative south")
	check(w.strafe(false) and w.position == Vector2i(2, 2), "Strafe left follows relative north")
	w.minutes = initial_time
	w.facing = 0
	var hero: Dictionary = w.character
	w.interact()
	check(w.character.gold == 6 and w.minutes == 1095, "Meal cost and shared clock")
	walk(w, Vector2i(7, 7))
	var before: int = w.minutes
	w.interact()
	check(w.chapter == "dungeon" and w.minutes == before + 5, "Descend advances clock")
	check(is_same(hero, w.character), "Character object survives transition")
	walk(w, Vector2i(10, 3))
	w.interact()
	w.interact()
	check(w.inventory.count("Brass token") == 1, "Relic cannot duplicate")
	check(w.save_game("user://test_journey.json") == OK, "Save succeeds")
	var loaded = World.new()
	check(loaded.load_game("user://test_journey.json"), "Load succeeds")
	check(loaded.chapter == w.chapter and loaded.position == w.position and loaded.minutes == w.minutes and loaded.inventory == w.inventory, "All state survives save/load")
	check(loaded.facing == w.facing, "Facing survives save/load")
	walk(loaded, Vector2i(1, 1))
	loaded.interact()
	walk(loaded, Vector2i(2, 2))
	check(loaded.flags.returned and loaded.in_tavern(), "Full round trip completes after reload")
	check(loaded.character.gold == 6 and loaded.inventory.has("Brass token"), "Inventory and spending persist")
	loaded.position = Vector2i(1, 1)
	before = loaded.minutes
	check(not loaded.move(Vector2i.UP) and loaded.minutes == before, "Walls do not consume time")
	loaded.minutes = 1439
	loaded.move(Vector2i.RIGHT)
	check(loaded.clock_text() == "DAY 02  /  00:00", "Clock rolls over midnight")
	var bad := FileAccess.open("user://test_invalid.json", FileAccess.WRITE)
	bad.store_string("{\"version\":1}")
	bad.close()
	check(not loaded.load_game("user://test_invalid.json"), "Invalid save rejected")
	var legacy = JSON.parse_string(FileAccess.get_file_as_string("user://test_journey.json"))
	legacy.version = 1
	legacy.erase("facing")
	bad = FileAccess.open("user://test_legacy.json", FileAccess.WRITE)
	bad.store_string(JSON.stringify(legacy))
	bad.close()
	check(loaded.load_game("user://test_legacy.json") and loaded.facing == 0, "Old save without facing defaults north")
	legacy.chapter = "city"
	legacy.position = [4, 2]
	bad = FileAccess.open("user://test_legacy.json", FileAccess.WRITE)
	bad.store_string(JSON.stringify(legacy))
	bad.close()
	check(loaded.load_game("user://test_legacy.json") and loaded.position == Vector2i(3, 2), "Old saves in new tavern wall migrate to adjacent floor")
	print("World integration tests: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	quit(failures)
