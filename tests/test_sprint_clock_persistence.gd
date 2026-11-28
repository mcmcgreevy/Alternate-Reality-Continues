extends SceneTree
const World = preload("res://scripts/original_world.gd")
const Clock = preload("res://scripts/game_clock.gd")
const Effects = preload("res://scripts/journey_effects.gd")
const SAVE := "user://sprint-calendar-boundary.json"
var checks := 0
var failures := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var world = World.new()
	# Loading normalizes an absent display override to an empty dictionary.
	world.character.stat_display = {}
	# Set up the last minute of year zero before creating any timed effect.
	world.minutes = (372 - Clock.START_DAY_OFFSET) * 1440 - 1
	check(world.calendar().year == 0 and world.calendar().day == 31 and world.calendar().hour == 23 and world.calendar().minute == 59, "Fixture is last minute of year zero")
	check(world.activate_physical_speed().activated, "Effect activates before year boundary")
	world.advance_real_seconds(2)
	check(world.save_game(SAVE) == OK, "Save active effect thirty seconds before year boundary")
	var restored = World.new()
	check(restored.load_game(SAVE), "Restore precise year-boundary save")
	check(restored.game_clock.snapshot() == world.game_clock.snapshot(), "Restore retains sub-minute position")
	var before: Dictionary = restored.game_clock.snapshot()
	restored.advance_real_seconds(300, "paused")
	check(restored.game_clock.snapshot() == before, "Pause cannot cross calendar boundary")
	world.advance_real_seconds(2)
	restored.advance_real_seconds(2)
	var date: Dictionary = restored.calendar()
	check(date.year == 1 and date.month_name == "Rebirth" and date.day == 1 and date.hour == 0 and date.minute == 0, "Resume crosses to Rebirth 1 year one at midnight")
	check(restored.physical_speed_remaining_game_microseconds() == 29 * 60000000, "Calendar rollover consumes one effect minute, not a day/year")
	check(Effects.same_saved_value(world.save_snapshot(), restored.save_snapshot()), "Uninterrupted and restored journeys agree across year rollover")
	world.advance_service_seconds(29.0 / 60.0)
	restored.advance_service_seconds(29.0 / 60.0)
	check(restored.calendar().minute == 29, "Accelerated service crosses exactly twenty-nine minutes")
	check(restored.physical_speed_remaining_game_microseconds() == 0 and restored.character.speed_bonus == 0, "Effect expires once through accelerated service")
	check(Effects.same_saved_value(world.save_snapshot(), restored.save_snapshot()), "Restored and uninterrupted service results agree")
	check(restored.save_game(SAVE) == OK and restored.load_game(SAVE), "Save and reload after year rollover and expiry")
	check(restored.calendar().year == 1 and restored.calendar().minute == 29 and restored.character.speed_bonus == 0, "Post-rollover load cannot resurrect expired effect")
	print("Sprint calendar/persistence: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
