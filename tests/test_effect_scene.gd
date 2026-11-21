extends SceneTree
var checks := 0
var failures := 0
var scene: Node

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	scene.application_focused = true
	key(KEY_F7)
	check(scene.world.primary_stats_text().ends_with("SPD 18"), "F7 activates production effect and reveals effective Speed")
	check(scene.world.journal.contains("30 game minutes"), "Test activation explains duration")
	scene._process(40)
	check(scene.world.physical_speed_remaining_game_microseconds() == 20 * 60000000, "Real scene frames consume ten game minutes")
	key(KEY_F7)
	check(scene.world.physical_speed_remaining_game_microseconds() == 20 * 60000000 and scene.world.character.speed_bonus == 5, "F7 repeat cannot refresh or stack")
	key(KEY_F5)
	check(scene.world.journal == "Journey saved.", "F5 saves through production handler")
	scene._process(20)
	key(KEY_F9)
	check(scene.world.physical_speed_remaining_game_microseconds() == 20 * 60000000 and scene.world.character.speed_bonus == 5, "F9 restores twenty minutes with one bonus")
	key(KEY_C)
	scene._process(400)
	check(scene.world.physical_speed_remaining_game_microseconds() == 20 * 60000000, "Chapter overview pauses effects")
	key(KEY_ESCAPE)
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	scene._process(400)
	check(scene.world.physical_speed_remaining_game_microseconds() == 20 * 60000000, "Focus loss pauses effects")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	if "--capture" in OS.get_cmdline_user_args():
		scene.queue_redraw()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tools/reference/s31-restored-speed.png")
	scene._process(80)
	check(scene.world.primary_stats_text().ends_with("SPD 13") and scene.world.physical_speed_remaining_game_microseconds() == 0, "Resumed scene expires effect and updates HUD")
	key(KEY_F5)
	key(KEY_F9)
	check(scene.world.character.speed_bonus == 0 and scene.world.physical_speed_remaining_game_microseconds() == 0, "Saving/reloading after expiry cannot resurrect bonus")
	scene.music.stop()
	scene.music.stream = null
	scene.queue_free()
	await process_frame
	await process_frame
	print("S31 integrated keyboard playtest: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
