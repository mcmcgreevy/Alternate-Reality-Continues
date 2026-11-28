extends SceneTree
## Run with the actual renderer, without --headless: environment values alone
## missed an assigned sky leaking through the finite Dungeon neighborhood.
var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("This regression requires a real rendering backend; omit --headless.")
		quit(1)
		return
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	var world = scene.world
	var view = scene.first_person
	for minute in [360, 720, 1380]:
		world.chapter = "city"
		world.position = Vector2i(35, 35)
		world.minutes = minute
		view.sync(world)
		check(view.environment.sky == view.city_sky, "City sky restored before Dungeon entry")
		world.chapter = "dungeon"
		# Screenshot report: 63N 50E, facing west, in zero-based map coordinates.
		world.position = Vector2i(49, 1)
		world.facing = 3
		view.sync(world)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var picture: Image = scene.viewport.get_texture().get_image()
		var darkest_gap := true
		for y in range(280, 296):
			for x in range(504, 520):
				var color := picture.get_pixel(x, y)
				if maxf(color.r, maxf(color.g, color.b)) > 0.02:
					darkest_gap = false
		check(darkest_gap, "Rendered corridor gap is black at minute " + str(minute))
		check(view.environment.sky == null, "Indoor view detaches City sky")
		# Avoid passing on a blank render: nearby geometry must still be visible.
		check(picture.get_pixel(400, 400).get_luminance() > 0.005, "Dungeon geometry remains visible")
		if "--capture" in OS.get_cmdline_user_args():
			picture.save_png("res://tools/reference/dungeon-distance-%d.png" % minute)
	world.chapter = "city"
	world.position = Vector2i(35, 35)
	world.minutes = 720
	view.sync(world)
	check(view.environment.sky == view.city_sky and view.environment.background_mode == Environment.BG_SKY, "Return restores City sky")
	scene.queue_free()
	await process_frame
	await process_frame
	print("Dungeon rendered distance: ", "PASS" if failures == 0 else "FAIL")
	quit(failures)
