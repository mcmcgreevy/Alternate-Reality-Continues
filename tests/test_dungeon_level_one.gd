extends SceneTree
const World = preload("res://scripts/original_world.gd")
var failures := 0
var scene: Node
var capture := false

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)

func visit(target: Vector2i) -> void:
	var path: Array[Vector2i] = scene.world.find_route(target)
	check(not path.is_empty(), "Reachable exploration waypoint %s" % target)
	for entry in path:
		var delta: Vector2i = entry - scene.world.position
		var direction: int = scene.world.DIRECTIONS.find(delta)
		check(direction >= 0, "Guide describes next physical step, including after transitions")
		if direction < 0: return
		while scene.world.facing != direction: key(KEY_D)
		if scene.world.edge(scene.world.position, direction) in [3, 4, 5, 6]: key(KEY_E)
		var expected: Vector2i = scene.world.step_destination(entry)
		key(KEY_W)
		check(scene.world.position == expected, "Guide step and original transition agree")
		if scene.world.position != expected: return
	check(scene.world.position == target, "Arrived at exploration waypoint")

func screenshot(name: String) -> void:
	if not capture: return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + name + ".png")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	var w = World.new()
	w.chapter = "dungeon"
	check(w.maps.dungeon.cells.size() == 4096 and w.dungeon_links.size() == 50, "Full floor and transition table imported")
	# Fixed anchors from runtime byte_3BA7, not generated from the tested movement.
	for sample in [[Vector2i(30,0), 1, Vector2i(33,0)], [Vector2i(33,0), 3, Vector2i(30,0)],
		[Vector2i(0,30), 2, Vector2i(0,33)], [Vector2i(0,33), 0, Vector2i(0,30)],
		[Vector2i(35,30), 2, Vector2i(35,33)], [Vector2i(35,33), 0, Vector2i(35,30)],
		[Vector2i(30,63), 1, Vector2i(33,63)], [Vector2i(33,63), 3, Vector2i(30,63)]]:
		w.position = sample[0]
		w.facing = sample[1]
		var before: int = w.minutes
		if w.edge(w.position, w.facing) in [3,4,5,6]: w.interact()
		check(w.step() and w.position == sample[2], "Original boundary transition %s" % sample[0])
		check(w.facing == sample[1] and w.minutes == before + 1, "Preserved facing and one-step clock at crossing")
	# Every directed physical seam is checked without manufacturing openings.
	var checked := 0
	for i in range(64):
		for sample in [[Vector2i(31,i),1], [Vector2i(32,i),3], [Vector2i(i,31),2], [Vector2i(i,32),0]]:
			w.position = sample[0]
			w.facing = sample[1]
			w.doors.clear()
			var code: int = w.edge(w.position, w.facing)
			var before: int = w.minutes
			var expected: Vector2i = w.step_destination(w.position + w.DIRECTIONS[w.facing])
			if code in [3,4,5,6]: w.interact()
			var moved: bool = w.step()
			check(moved == (code < 8), "Directed seam obeys its raw edge code")
			check(w.position == (expected if moved else sample[0]), "Seam destination is correct")
			check(w.minutes == before + (1 if moved else 0), "Blocked seam costs no time")
			checked += 1
	check(checked == 256, "All 256 directed seam faces tested")
	for sample in [[Vector2i(0,0),3], [Vector2i(63,63),1], [Vector2i(10,0),0], [Vector2i(10,63),2]]:
		w.position = sample[0]
		w.facing = sample[1]
		check(not w.step() and w.position == sample[0], "Outer border never wraps")
	# Source event index 31 forces west, while index 13 randomizes in place once.
	w.position = Vector2i(42,8)
	w.facing = 0
	if w.edge(w.position, 0) in [3,4,5,6]: w.interact()
	check(w.step() and w.position == Vector2i(24,59) and w.facing == 3, "Fixed-facing cross-quadrant teleport")
	check(w.coordinates() == "04N  24E", "Southwest original coordinate conversion")
	w.position = Vector2i(40,14)
	w.facing = 2
	if w.edge(w.position, 2) in [3,4,5,6]: w.interact()
	check(w.step() and w.position == Vector2i(40,15) and w.facing >= 0 and w.facing < 4, "Random-facing self transition terminates")
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.world.position = Vector2i(49,3)
	scene.world.facing = 1
	key(KEY_E)
	var hero: Dictionary = scene.world.character
	var pack: Array = scene.world.inventory
	for target in [Vector2i(0,0), Vector2i(1,32), Vector2i(36,32)]:
		key(KEY_V)
		scene.update_guide()
		check(scene.TOUR_POINTS[scene.tour_index] == target and not scene.guide_path.is_empty(), "V selects the next reachable quadrant tour stop")
		visit(target)
		check(scene.world.save_game("user://test_full_floor.json") == OK, "Save beyond old northeast boundary")
		var restored = World.new()
		check(restored.load_game("user://test_full_floor.json") and restored.position == target, "Load every new quadrant")
		check(scene.first_person.built_center.distance_to(target) <= 3, "Renderer streams new quadrant")
		await screenshot("dungeon-quadrant-%d" % scene.world.cell(target).segment)
	key(KEY_V)
	check(scene.tour_index == 3, "Tour cycles back to City entrance")
	visit(Vector2i(49,3))
	check(is_same(hero, scene.world.character) and is_same(pack, scene.world.inventory), "Full-floor tour retains character and inventory")
	key(KEY_TAB)
	scene.update_guide()
	await screenshot("dungeon-level-one-map")
	key(KEY_TAB)
	key(KEY_E)
	check(scene.world.chapter == "city", "Full-floor tour returns to City")
	scene.music.stop()
	scene.music.stream = null
	await create_timer(0.15).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	print("Dungeon level one: seams, original links, quadrant tour, saves: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	quit(failures)
