extends SceneTree
var scene: Node
var failures := 0
var capture := false

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	if not ok:
		failures += 1
		push_error(description)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)

func face(bearing: int) -> void:
	while scene.world.facing != bearing: key(KEY_D)

func walk(target: Vector2i) -> void:
	var w = scene.world
	var queue: Array[Vector2i] = [w.position]
	var parent: Dictionary = {w.position: w.position}
	while not queue.is_empty():
		var at: Vector2i = queue.pop_front()
		if at == target: break
		for direction in w.DIRECTIONS:
			var next: Vector2i = at + direction
			if w.tile(next) != "#" and not parent.has(next):
				parent[next] = at
				queue.append(next)
	check(parent.has(target), "Reachable target")
	if not parent.has(target): return
	var path: Array[Vector2i] = []
	var cursor := target
	while cursor != w.position:
		path.push_front(cursor)
		cursor = parent[cursor]
	for at in path:
		face(w.DIRECTIONS.find(at - w.position))
		key(KEY_W)
		check(w.position == at, "Keyboard step reaches intended cell")

func screenshot(filename: String) -> void:
	if not capture: return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + filename + ".png")

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	scene = load("res://scenes/prototype.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	check(scene.music.stream.data.size() == 22050 * 16 * 2, "Synthesized cue length")
	check(scene.music.playing, "Tavern audio starts")
	check(scene.viewport.size == Vector2i(375, 210), "Low-resolution viewport")
	await screenshot("prototype")
	key(KEY_C)
	var before: Vector2i = scene.world.position
	key(KEY_W)
	check(scene.world.position == before, "Chapter overlay blocks movement")
	key(KEY_C)
	key(KEY_TAB)
	check(scene.show_map, "Optional map opens")
	key(KEY_TAB)
	key(KEY_E)
	walk(Vector2i(3, 5))
	face(1)
	await screenshot("street-first-person")
	walk(Vector2i(8, 7))
	face(3)
	check(not scene.music.playing, "Leaving tavern stops audio")
	await screenshot("city-first-person")
	walk(Vector2i(7, 7))
	key(KEY_E)
	check(scene.world.chapter == "dungeon" and scene.first_person.built_chapter == "dungeon", "Stairs rebuild Dungeon view")
	check(scene.world.facing == 1, "Dungeon arrival looks into corridor")
	await screenshot("dungeon-first-person")
	walk(Vector2i(9, 3))
	face(1)
	await screenshot("relic-first-person")
	walk(Vector2i(10, 3))
	key(KEY_E)
	check(not scene.first_person.relic.visible, "Collected token disappears")
	check(scene.world.inventory.has("Brass token"), "Keyboard interaction collects token")
	walk(Vector2i(1, 1))
	key(KEY_E)
	check(scene.first_person.built_chapter == "city", "Return rebuilds City view")
	walk(Vector2i(2, 2))
	face(0)
	check(scene.world.flags.returned and scene.music.playing, "Round trip completes and song returns")
	check(scene.world.character.gold == 6, "Spending persists across chapters")
	await screenshot("round-trip-first-person")
	print("First-person input, round trip, view and audio: ", "PASS" if failures == 0 else "FAIL")
	scene.music.stop()
	scene.music.stream = null
	await create_timer(0.15).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	quit(failures)

