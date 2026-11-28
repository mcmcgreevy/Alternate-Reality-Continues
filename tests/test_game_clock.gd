extends SceneTree
const Clock = preload("res://scripts/game_clock.gd")
const World = preload("res://scripts/original_world.gd")
var failures := 0
var checks := 0
var intervals: Array = []
var reentrant_result: Dictionary = {}

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func write_save(data: Dictionary) -> void:
	var file := FileAccess.open("user://s03-invalid.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func _initialize() -> void:
	var clock = Clock.new()
	var date: Dictionary = clock.calendar()
	check(date.year == 0 and date.month == 5 and date.day == 29 and date.hour == 6 and date.minute == 0, "Canonical ST start date and time")
	check(date.month_name == "Sowings", "Canonical month name")
	clock.advance_game_microseconds((3 * 1440 - 360) * Clock.GAME_MICROSECONDS_PER_MINUTE)
	date = clock.calendar()
	check(date.month_name == "First Fruits" and date.day == 1 and date.hour == 0, "Every month has 31 days")
	clock = Clock.new(0)
	clock.advance_game_microseconds((372 - Clock.START_DAY_OFFSET) * 1440 * Clock.GAME_MICROSECONDS_PER_MINUTE)
	date = clock.calendar()
	check(date.year == 1 and date.month_name == "Rebirth" and date.day == 1, "Twelve months roll to next year")
	for month in range(12):
		clock = Clock.new(0)
		clock.advance_game_microseconds((372 + month * 31 - Clock.START_DAY_OFFSET) * 1440 * Clock.GAME_MICROSECONDS_PER_MINUTE)
		check(clock.calendar().month_name == Clock.MONTHS[month] and clock.calendar().day == 1, "All twelve month boundaries: " + Clock.MONTHS[month])
	clock = Clock.new(0)
	check(clock.advance_real_seconds(4).elapsed_game_microseconds == 60000000, "Ordinary four real seconds are one game minute")
	check(clock.advance_real_seconds(1, "accelerated").elapsed_game_microseconds == 3600000000, "Service one real second is one game hour")
	var before: Dictionary = clock.snapshot()
	check(clock.advance_real_seconds(900, "paused").elapsed_game_microseconds == 0 and clock.snapshot() == before, "Pause stores no backlog")
	clock = Clock.new(0)
	clock.advance_real_seconds(1.0 / 30000000.0)
	check(clock.game_microseconds == 0 and is_equal_approx(clock.conversion_remainder, 0.5), "Sub-microsecond remainder retained")
	clock.advance_real_seconds(1.0 / 30000000.0)
	check(clock.game_microseconds == 1 and clock.conversion_remainder == 0, "Fractional conversion carries exactly once")
	var large = Clock.new(0)
	var small = Clock.new(0)
	large.advance_real_seconds(4)
	for frame in range(4000):
		small.advance_real_seconds(0.001)
	check(large.snapshot() == small.snapshot(), "Ordinary frame partitions preserve elapsed time")
	large.advance_game_microseconds(123456789)
	for part in [1, 456788, 123000000]:
		small.advance_game_microseconds(part)
	check(large.snapshot() == small.snapshot(), "Integer game-time partitions are exact")
	before = clock.snapshot()
	for invalid in [-1.0, INF, NAN]:
		check(not clock.advance_real_seconds(invalid).ok and clock.snapshot() == before, "Invalid real time rejected atomically")
	check(not clock.advance_real_seconds(1, "unknown").ok and clock.snapshot() == before, "Unknown mode rejected")
	check(not clock.advance_game_microseconds(-1).ok and clock.snapshot() == before, "Negative game time rejected")
	check(not clock.advance_game_microseconds(Clock.MAX_GAME_MICROSECONDS).ok and clock.snapshot() == before, "Timestamp overflow rejected")
	check(not clock.advance_real_seconds(1e300).ok and clock.snapshot() == before, "Conversion overflow rejected")
	check(clock.advance_game_microseconds(0).ok and clock.snapshot() == before, "Zero elapsed is a no-op")
	var world = World.new()
	world.game_time_advanced.connect(func(start: int, end: int): intervals.append([start, end, world.needs.hunger]))
	var start: int = world.game_time_boundary()
	var hunger: int = world.needs.hunger
	var thirst: int = world.needs.thirst
	world.advance_service_seconds(1)
	check(world.minutes == 420 and world.needs.hunger == hunger + 1 and world.needs.thirst == thirst + 2, "Service updates clock and crossed needs once")
	check(intervals == [[start, start + 3600000000, hunger]], "Consumer receives interval once before metabolism")
	world.advance_service_seconds(10, true)
	check(intervals.size() == 1, "Paused service emits no elapsed interval")
	world.game_time_advanced.connect(func(_start: int, _end: int): reentrant_result = world.advance_game_microseconds(1))
	world.advance_time(5)
	check(not reentrant_result.ok and world.minutes == 425, "Consumer cannot charge time reentrantly")
	before = world.game_clock.snapshot()
	var needs_before: Dictionary = world.needs.duplicate()
	world.wait_minutes(-1)
	check(world.game_clock.snapshot() == before and world.needs == needs_before, "Invalid wait leaves clock and needs alone")
	world.advance_real_seconds(0.5)
	world.advance_real_seconds(1.0 / 30000000.0)
	check(world.save_game("user://s03-clock.json") == OK, "Save precise clock")
	var restored = World.new()
	check(restored.load_game("user://s03-clock.json"), "Load version 5 clock")
	check(restored.game_clock.snapshot() == world.game_clock.snapshot(), "Timestamp and conversion remainder survive reload")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("user://s03-clock.json"))
	data.erase("effects")  # Legacy fixtures predate the v7 effect payload.
	data.erase("gameplay_random")  # Legacy fixtures predate v8.
	data.erase("city_geometry_revision")  # Legacy fixtures predate v9.
	data.version = 4
	data.erase("clock")
	data.minutes = 1080
	data.minute_fraction = 0.5
	write_save(data)
	check(restored.load_game("user://s03-invalid.json") and restored.minutes == 1080 and restored.minute_fraction == 0.5, "Legacy elapsed minutes/fraction preserved, not reset to start")
	data.version = 3
	data.erase("minute_fraction")
	write_save(data)
	check(restored.load_game("user://s03-invalid.json") and restored.minute_fraction == 0, "Version 3 gains zero fractional clock")
	before = restored.game_clock.snapshot()
	data = JSON.parse_string(FileAccess.get_file_as_string("user://s03-clock.json"))
	data.clock.game_microseconds += 1
	write_save(data)
	check(not restored.load_game("user://s03-invalid.json") and restored.game_clock.snapshot() == before, "Mismatched save clock rejected before live mutation")
	data.clock.game_microseconds = -1
	write_save(data)
	check(not restored.load_game("user://s03-invalid.json") and restored.game_clock.snapshot() == before, "Negative saved timestamp rejected atomically")
	data.clock.game_microseconds = Clock.MAX_GAME_MICROSECONDS + 1
	write_save(data)
	check(not restored.load_game("user://s03-invalid.json"), "Out-of-range save rejected")
	print("S03 clock: %d checks, %d failures" % [checks, failures])
	quit(failures)
