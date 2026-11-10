extends SceneTree
const World = preload("res://scripts/original_world.gd")
var failures := 0
var scene: Node
var capture := false

func check(ok: bool, description: String) -> void:
	if not ok:
		failures += 1
		push_error(description)

func _initialize() -> void:
	call_deferred("run")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)

func face(bearing: int) -> void:
	while scene.world.facing != bearing: key(KEY_D)

func follow(path: Array) -> void:
	for coords in path:
		var target := Vector2i(int(coords[0]), int(coords[1]))
		if target == scene.world.position: continue
		var d: int = scene.world.DIRECTIONS.find(target - scene.world.position)
		check(d >= 0, "Route consists of neighboring cells")
		if d < 0: return
		face(d)
		if scene.world.edge(scene.world.position, d) in [3, 4, 5, 6]: key(KEY_E)
		key(KEY_W)
		check(scene.world.position == target, "Keyboard traversal follows original edge")
		if scene.world.position != target: return

func screenshot(name: String) -> void:
	if not capture: return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + name + ".png")

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	var w = World.new()
	check(w.coordinates() == "63N  21E", "Handbook Tavern coordinate conversion")
	check(w.maps.city.cells.size() == 4096 and w.maps.dungeon.cells.size() == 4096, "Imported map dimensions")
	w.facing = 0
	check(not w.step(), "Closed secret door blocks movement")
	w.interact()
	check(w.step(), "Examined secret opens north exit")
	w.facing = 1
	w.interact()
	check(w.step(), "One-way secret permits outward traversal")
	w.facing = 3
	check(not w.step(), "Opposite solid face stays blocked")
	check(w.save_game("user://test_original_route.json") == OK, "New map save succeeds")
	var loaded = World.new()
	check(loaded.load_game("user://test_original_route.json"), "New map save loads")
	check(loaded.position == w.position and loaded.doors == w.doors and loaded.facing == w.facing, "Facing and directional door state persist")
	check(not loaded.load_game("user://test_legacy.json"), "Prototype coordinates cannot enter original map save")
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	check(scene.music.playing, "Original tavern uses placeholder cue")
	var start_time: int = scene.world.minutes
	for code in [KEY_W, KEY_S, KEY_A, KEY_D, KEY_Q, KEY_R, KEY_E]: key(code)
	check(scene.world.position == Vector2i(20, 1) and scene.world.facing == 2, "Tavern is a menu, not a walkable room")
	check(scene.world.minutes == start_time and scene.world.character.gold == 8, "Movement and generic use cannot spend time or buy meals in tavern")
	key(KEY_2)
	check(scene.show_brief and scene.world.minutes == start_time, "Excursion briefing is free to read")
	await screenshot("first-excursion-brief")
	key(KEY_2)
	key(KEY_1)
	check(scene.show_order and scene.world.minutes == start_time, "Opening menu is free")
	await screenshot("tavern-food-menu")
	key(KEY_1)
	await screenshot("tavern-order-confirmation")
	key(KEY_N)
	check(scene.world.wallet_copper() == 800, "Cancelling order does not charge")
	key(KEY_1)
	key(KEY_Y)
	check(scene.world.wallet_copper() == 792 and scene.world.minutes == start_time + 15, "Chili costs eight copper and advances time once")
	key(KEY_5)
	check(scene.world.save_game("user://test_tavern_menu.json") == OK, "Save within establishment")
	var hero: Dictionary = scene.world.character
	var pack: Array = scene.world.inventory
	await screenshot("original-tavern")
	key(KEY_TAB)
	scene.update_guide()
	await screenshot("original-route-map")
	key(KEY_TAB)
	key(KEY_3)
	check(scene.world.position == Vector2i(20, 0) and not scene.music.playing, "Leave choice uses original north boundary and stops music")
	check(scene.world.minutes == start_time + 16, "Leaving costs one mapped step")
	check(scene.world.load_game("user://test_tavern_menu.json"), "Restore establishment save")
	hero = scene.world.character
	pack = scene.world.inventory
	key(KEY_M)
	check(scene.world.in_tavern() and scene.music.playing, "Restored tavern resumes menu and music")
	key(KEY_M)
	key(KEY_3)
	follow(scene.world.route.outward.slice(1))
	check(scene.world.position == Vector2i(49, 3), "Route reaches original transfer-front cell")
	check(not scene.music.playing, "Street traversal stops tavern cue")
	face(1)
	await screenshot("original-city-entrance")
	var before: int = scene.world.minutes
	key(KEY_E)
	check(scene.world.chapter == "dungeon" and scene.world.position == Vector2i(49, 3) and scene.world.facing == 3, "Original transfer arrival and facing")
	check(scene.world.minutes == before + 5, "Clock persists through entrance")
	check(is_same(hero, scene.world.character) and is_same(pack, scene.world.inventory), "Same character and inventory objects across chapters")
	check(scene.world.edge(Vector2i(49, 3), 1) == 13, "Original east wall retained; no ARX return-door mutation")
	await screenshot("original-dungeon-arrival")
	key(KEY_W)
	check(scene.world.position == Vector2i(48, 3), "Original west arch is passable")
	check(scene.world.save_game("user://test_original_dungeon.json") == OK, "Save in original Dungeon")
	check(scene.world.load_game("user://test_original_dungeon.json"), "Restore original Dungeon")
	face(1)
	key(KEY_W)
	check(scene.world.position == Vector2i(49, 3), "Return to original arrival")
	key(KEY_E)
	check(scene.world.chapter == "city", "Authorized two-way return")
	follow(scene.world.route["return"])
	check(scene.world.in_tavern() and scene.world.flags.returned, "Original-map round trip completes")
	check(scene.world.wallet_copper() == 792 and scene.world.inventory == pack, "Spending and possessions persist through save and return")
	check(scene.music.playing, "Music restarts on homecoming")
	face(2)
	await screenshot("original-round-trip")
	key(KEY_1)
	check(scene.world.tavern_menu().has("water_flask"), "Homecoming uses new hour's menu")
	await screenshot("tavern-late-menu")
	var hour_before: int = scene.world.menu_hour()
	key(KEY_T)
	check(scene.world.menu_hour() == hour_before + 1 and scene.world.tavern_menu().has("food_packet"), "Wait-menu control advances shared clock and refreshes stock")
	var water_balance: int = scene.world.wallet_copper()
	key(KEY_4)
	key(KEY_Y)
	check(scene.world.wallet_copper() == water_balance and scene.music.playing, "Free water through UI keeps coins and tavern song")
	key(KEY_5)
	scene.music.stop()
	scene.music.stream = null
	await create_timer(0.15).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	print("Original-map route, directional doors, saves and scene: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	quit(failures)
