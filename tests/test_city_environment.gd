extends SceneTree
var failures := 0
var scene: Node
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func capture(name: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + name + ".png")
func run() -> void:
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var w = scene.world
	var view = scene.first_person
	check(w.is_inside(w.position) and view.ceiling_cells.has(w.position), "Tavern cell is covered")
	w.leave_tavern()
	w.position = Vector2i(35,35)
	scene.music.set_tavern(false)
	w.facing = 1
	for hour in [12,18,23]:
		w.minutes = hour * 60
		view.sync(w)
		check(view.outdoors and not view.ceiling_cells.has(w.position), "Street has open sky")
		check(view.environment.background_mode == Environment.BG_SKY, "Street uses sky background")
		check(view.daylight > 0.99 if hour == 12 else view.daylight < 0.01 if hour == 23 else view.daylight > 0.0, "Clock controls daylight")
		await capture("city-sky-%02d" % hour)
	var geometry = view.geometry
	w.wait_minutes()
	view.sync(w)
	check(is_same(geometry, view.geometry) and view.last_sky_minute == w.minutes % 1440, "Waiting updates sky without rebuilding geometry")
	w.save_game("user://test_city_sky.json")
	w.minutes = 720
	view.sync(w)
	w.load_game("user://test_city_sky.json")
	view.sync(w)
	check(view.daylight < 0.01, "Loading restores night lighting immediately")
	w.minutes = 1440 + 720
	view.sync(w)
	check(view.daylight > 0.99, "Day cycle repeats after midnight")
	for key in w.maps.city.cells:
		if int(w.maps.city.cells[key].location) == 7:
			var xy = key.split(",")
			w.position = Vector2i(int(xy[0]),int(xy[1]))
			break
	view.sync(w)
	check(not view.outdoors and view.ceiling_cells.has(w.position) and not view.sun.visible, "Secret passage is covered and sunlight is disabled")
	await capture("city-covered-passage")
	w.chapter = "dungeon"
	w.position = Vector2i(49,3)
	view.sync(w)
	check(not view.outdoors and view.ceiling_cells.has(w.position), "Dungeon remains roofed")
	scene.music.stop()
	scene.music.stream = null
	await create_timer(0.15).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	print("City sky, clock, interior ceilings and save restore: ", "PASS" if failures == 0 else "FAIL")
	quit(failures)
