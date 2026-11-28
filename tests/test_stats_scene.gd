extends SceneTree
var checks := 0
var failures := 0

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
	check(scene.world.primary_stats_text() == "STR 12     STA 12  SPD 13", "Existing stat labels use effective values")
	scene.world.set_stat_base("strength", 13.75)
	scene.world.set_stat_modifiers("strength", 5, 2)
	check(scene.world.primary_stats_text().begins_with("STR 16"), "HUD uses effective value, not fractional base")
	scene.world.set_stat_display({"strength": 100, "hp": 500})
	check(scene.world.primary_stats_text().begins_with("STR 100") and scene.world.displayed_hit_points() == 500, "Presentation values reach HUD")
	check(scene.world.stat_snapshot("strength").effective == 16 and scene.world.character.hp == 24, "Presentation leaves gameplay values intact")
	check(scene.world.primary_stats_text().ends_with("SPD 13"), "Approved UI shows Speed before reveal")
	scene.world.character.speed_revealed = true
	scene.world.apply_stat_actions([{"target": "speed_bonus", "operation": "add", "operand_width": 1, "block_count": 1, "block_gap": 0, "parameter": 5}])
	check(scene.world.primary_stats_text().ends_with("SPD 18"), "Revealed Speed reflects typed action")
	check(scene.font.get_string_size(scene.world.primary_stats_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x <= 218, "Revealed stat line fits its panel")
	if "--capture" in OS.get_cmdline_user_args():
		scene.queue_redraw()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tools/reference/s08-stats.png")
	scene.world.set_stat_display({})
	check(scene.world.primary_stats_text().begins_with("STR 16") and scene.world.displayed_hit_points() == 24, "Clearing presentation returns HUD to actual stats")
	scene.music.stop()
	scene.music.stream = null
	scene.queue_free()
	await process_frame
	await process_frame
	print("S08 scene: %d checks, %d failures" % [checks, failures])
	quit(failures)
