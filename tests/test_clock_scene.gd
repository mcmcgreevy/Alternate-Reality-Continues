extends SceneTree
var failures := 0
var checks := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	scene.application_focused = true
	var start: int = scene.world.game_time_boundary()
	scene._process(4)
	check(scene.world.game_time_boundary() == start + 60000000, "Idle frame time advances one game minute")
	scene.show_chapters = true
	scene._process(400)
	check(scene.world.game_time_boundary() == start + 60000000, "Chapter overview pauses")
	scene.show_chapters = false
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	scene._process(400)
	check(scene.world.game_time_boundary() == start + 60000000, "Focus loss pauses without backlog")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	scene.show_map = true
	scene._process(4)
	check(scene.world.game_time_boundary() == start + 120000000, "Live map resumes ordinary time")
	scene.show_map = false
	scene.show_order = true
	scene._process(4)
	check(scene.world.game_time_boundary() == start + 180000000, "Tavern menu remains live")
	var quote: int = scene.world.menu_hour()
	scene.world.advance_service_seconds(1)
	check(not scene.world.order_tavern("pemmican", quote), "Elapsed service time invalidates old menu quote")
	scene.show_order = false
	# Choose a real open edge, without depending on the movement animation design.
	var found := false
	for cell_key in scene.world.maps.city.cells:
		var parts: PackedStringArray = cell_key.split(",")
		var position := Vector2i(int(parts[0]), int(parts[1]))
		if position in scene.world.TAVERN_CELLS:
			continue
		for direction in range(4):
			if scene.world.edge(position, direction) == 0 and scene.world.has_cell(position + scene.world.DIRECTIONS[direction]):
				scene.world.position = position
				scene.world.facing = direction
				found = true
				break
		if found:
			break
	check(found, "Find open City movement edge")
	start = scene.world.game_time_boundary()
	scene.perform_movement(KEY_W)
	check(scene.world.game_time_boundary() == start, "Keyboard movement does not charge action time")
	scene._process(4)
	check(scene.world.game_time_boundary() == start + 60000000, "Moving frame charges elapsed time exactly once")
	# Check the widest month names at the actual HUD font/size, not a guessed width.
	for month in scene.world.GameClock.MONTHS:
		var label := "%s 31, Y280  /  23:59" % month
		check(scene.font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x <= 398, "Calendar label fits header: " + month)
	if "--capture" in OS.get_cmdline_user_args():
		scene.show_order = false
		scene.world.position = scene.world.TAVERN_POSITION
		scene.world.minutes = 360
		scene.queue_redraw()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tools/reference/s03-calendar.png")
	scene.music.stop()
	scene.music.stream = null
	scene.queue_free()
	await process_frame
	await process_frame
	print("S03 scene: %d checks, %d failures" % [checks, failures])
	quit(failures)
