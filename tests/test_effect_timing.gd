extends SceneTree
const Timing = preload("res://scripts/effect_timing.gd")
const Adapter = preload("res://scripts/effect_clock_adapter.gd")
const World = preload("res://scripts/original_world.gd")
const Stats = preload("res://scripts/character_stats.gd")
const Clock = preload("res://scripts/game_clock.gd")
const M = 60000000
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func action(operation: String = "add") -> Dictionary:
	return {"target": "speed_bonus", "operation": operation, "operand_width": 1,
		"block_count": 1, "block_gap": 0, "parameter": 5}

func definition(id: String, interval: int = 2, operation: String = "add", unique: bool = false) -> Dictionary:
	return {"definition_id": id, "definition_revision": 1, "disallow_multiple": unique,
		"comparison": {"effect_type": 3, "interval_raw": interval, "natural_cure_raw": 0,
		"action_raw": 129 if operation == "add" else 145, "target_offset_raw": 6318,
		"block_count_raw": 1, "block_gap_raw": 0, "parameter_raw": 5}}

func profile(first: int = 3, interval: int = 2, counter: int = 0, operation: String = "add") -> Dictionary:
	return {"kind": "timer", "initial_timer_raw": first, "interval_raw": interval,
		"counter_raw": counter, "incubating": false, "action": action(operation)}

func listener(id: String, linked: bool = false, events: int = 4) -> Dictionary:
	return {"definition_id": id, "required_events": events, "link_to_previous": linked}

func timer(runtime, id: String, first: int = 3, interval: int = 2, counter: int = 0, operation: String = "add", unique: bool = false) -> void:
	check(runtime.register_definition(definition(id, interval, operation, unique), profile(first, interval, counter, operation)).ok, "Register timer " + id)

func owner(runtime, id: String, rank: int, listeners: Array, at: int = 0) -> void:
	check(runtime.register_entity(id, rank, listeners).ok, "Register owner " + id)
	check(runtime.queue_events(id, 4, at).ok, "Queue use " + id)

func text_record(runtime, id: String, long_text: bool = true) -> void:
	var data := definition(id)
	data.comparison.effect_type = 0
	check(runtime.register_definition(data, {"kind": "text", "text": "Physical Speed", "long_text": long_text, "visible": false}).ok, "Register linked text")

func actions(trace: Array) -> Array:
	return trace.filter(func(entry): return entry.kind == "action")

func _initialize() -> void:
	var large_character := {"speed_bonus": 0}
	var small_character := {"speed_bonus": 0}
	var large = Timing.new(large_character)
	var small = Timing.new(small_character)
	for runtime in [large, small]:
		timer(runtime, "repeat")
		owner(runtime, "owner", 1, [listener("repeat")])
	var result: Dictionary = large.advance_game_microseconds(7 * M)
	var divided: Array = []
	for elapsed in [0, M - 1, 1, M, 2 * M, 3 * M]:
		var part: Dictionary = small.advance_game_microseconds(elapsed)
		check(part.ok, "Partition accepted")
		divided.append_array(part.trace)
	check(result.ok and result.trace == divided and large.snapshot() == small.snapshot() and large_character == small_character, "Large and partitioned traces/state agree")
	check(actions(result.trace).map(func(entry): return entry.at) == [3 * M, 5 * M, 7 * M], "First 3, interval 2 executes at 3/5/7")
	check(large.advance_game_microseconds(0).trace.is_empty(), "Zero elapsed never repeats expiry")
	var before: Dictionary = large.snapshot()
	for invalid in [-1, 0.5, Clock.MAX_GAME_MICROSECONDS]:
		check(not large.advance_game_microseconds(invalid).ok and large.snapshot() == before and large_character.speed_bonus == 15, "Invalid elapsed rejected atomically")
	check(not large.queue_events("owner", 4, 0).ok, "Past events rejected")
	var copy: Dictionary = large.snapshot()
	copy.active[0].due_game_microseconds = 0
	check(large.snapshot() == before, "Snapshots cannot mutate live state")

	for parameters in [[3, 2, 2, 2, 0], [0, 2, 0, 0, 1], [3, 0, 0, 1, 1]]:
		var runtime = Timing.new({})
		timer(runtime, "edge", parameters[0], parameters[1], parameters[2])
		owner(runtime, "edge", 0, [listener("edge")])
		var edge: Dictionary = runtime.advance_game_microseconds(10 * M)
		check(actions(edge.trace).size() == parameters[3] and runtime.snapshot().active.size() == parameters[4], "Finite, dormant and zero-interval semantics")

	var invalid_runtime = Timing.new({})
	var cure := definition("invalid")
	cure.comparison.natural_cure_raw = 1
	check(not invalid_runtime.register_definition(cure, profile()).ok, "Natural cure explicitly rejected")
	for key in ["initial_timer_raw", "interval_raw", "counter_raw"]:
		for value in [-1, 65536, 1.5]:
			var bad := profile()
			bad[key] = value
			check(not invalid_runtime.register_definition(definition("invalid"), bad).ok, "Reject timer domain " + key)
	var bad := profile()
	bad.action.target = "hp"
	check(not invalid_runtime.register_definition(definition("invalid"), bad).ok, "Unsupported target rejected")
	bad = profile()
	bad.action.operand_width = 2
	check(not invalid_runtime.register_definition(definition("invalid"), bad).ok, "Unsupported width rejected")
	timer(invalid_runtime, "invalid")
	check(not invalid_runtime.register_entity("bad", 1, [listener("missing")]).ok, "Missing profile rejected")
	owner(invalid_runtime, "valid", 1, [listener("invalid")])
	check(not invalid_runtime.register_entity("other", 1, []).ok, "Duplicate rank rejected")

	var incubation = Timing.new({})
	var incubating := profile(1, 0)
	incubating.incubating = true
	check(incubation.register_definition(definition("root", 0), incubating).ok, "Incubating profile accepted")
	text_record(incubation, "text")
	owner(incubation, "owner", 0, [listener("root"), listener("text", true)])
	incubation.advance_game_microseconds(M - 1)
	check(not incubation.snapshot().active[1].visible and incubation.snapshot().active[0].incubating, "Incubation remains before deadline")
	check(actions(incubation.advance_game_microseconds(1).trace).size() == 1 and incubation.snapshot().active[1].visible and not incubation.snapshot().active[0].incubating, "Expiry clears incubation, reveals linked text and executes")
	check(incubation.snapshot().active[1].slot_count == 2, "Long text reserves two slots")

	var root_expiry = Timing.new({})
	timer(root_expiry, "root", 1, 0, 1)
	timer(root_expiry, "child", 1, 0, 1)
	text_record(root_expiry, "text")
	owner(root_expiry, "owner", 0, [listener("root"), listener("child", true), listener("text", true)])
	check(actions(root_expiry.advance_game_microseconds(M).trace).size() == 1 and root_expiry.snapshot().active.is_empty(), "Root expiry removes linked due child before it can execute")
	var child_expiry = Timing.new({})
	timer(child_expiry, "root", 0)
	timer(child_expiry, "child", 1, 0, 1)
	text_record(child_expiry, "text", false)
	owner(child_expiry, "owner", 0, [listener("root"), listener("child", true), listener("text", true)])
	child_expiry.advance_game_microseconds(M)
	check(child_expiry.snapshot().active.size() == 2, "Child expiry preserves root and text")

	for event in [8, 16]:
		var tie = Timing.new({})
		timer(tie, "timer", 1)
		owner(tie, "owner", 0, [listener("timer")])
		tie.queue_events("owner", event, M)
		check(actions(tie.advance_game_microseconds(M).trace).is_empty() and tie.snapshot().active.is_empty(), "Owner removal precedes equal-time expiry")

	var ordered_character := {"speed_bonus": 253}
	var ordered = Timing.new(ordered_character)
	timer(ordered, "add", 1, 0)
	timer(ordered, "subtract", 1, 0, 0, "subtract")
	owner(ordered, "low", 1, [listener("subtract")])
	owner(ordered, "high", 2, [listener("add")])
	check(actions(ordered.advance_game_microseconds(M).trace).map(func(entry): return entry.bonus) == [255, 250], "Descending owner ranks establish ascending slot action order")
	# Reuse the first slot for a newer ID; sorting by ID would give 248 then 253.
	ordered.queue_events("high", 16, M)
	ordered.advance_game_microseconds(0)
	owner(ordered, "new", 3, [listener("add")], M)
	ordered.advance_game_microseconds(0)
	check(ordered.snapshot().active[0].instance_id > ordered.snapshot().active[1].instance_id, "Slots reused independently of monotonic identity")
	# New repeating setup makes both records due after reuse.
	var reuse_character := {"speed_bonus": 253}
	var reuse = Timing.new(reuse_character)
	timer(reuse, "add", 2, 0)
	timer(reuse, "subtract", 3, 0, 0, "subtract")
	owner(reuse, "old", 2, [listener("add")])
	owner(reuse, "remaining", 1, [listener("subtract")])
	reuse.queue_events("old", 16, M)
	owner(reuse, "new", 3, [listener("add")], M)
	# Higher rank new owner runs before deletion and cannot use the hole yet;
	# activate it after the deletion batch to make reuse explicit.
	reuse.advance_game_microseconds(M)
	reuse.queue_events("new", 8, M)
	reuse.advance_game_microseconds(0)
	reuse.queue_events("new", 4, M)
	reuse.advance_game_microseconds(0)
	check(actions(reuse.advance_game_microseconds(2 * M).trace).map(func(entry): return entry.bonus) == [255, 250], "Reused slot, not instance ID, determines simultaneous action order")

	var repeated = Timing.new({})
	timer(repeated, "unique", 3, 2, 0, "add", true)
	owner(repeated, "owner", 0, [listener("unique")])
	repeated.queue_events("owner", 4, M)
	check(actions(repeated.advance_game_microseconds(3 * M).trace).size() == 1 and repeated.snapshot().active.size() == 1, "H suppression does not refresh the original deadline")
	var stale = Timing.new({})
	timer(stale, "timer")
	owner(stale, "owner", 0, [listener("timer")])
	stale.queue_events("owner", 16, M)
	stale.queue_events("owner", 4, 2 * M)
	check(stale.advance_game_microseconds(4 * M).ok and stale.snapshot().active.is_empty(), "Future work for deleted owner is discarded")

	var overflow = Timing.new({}, Clock.MAX_GAME_MICROSECONDS - M)
	timer(overflow, "timer", 2)
	owner(overflow, "owner", 0, [listener("timer")], Clock.MAX_GAME_MICROSECONDS - M)
	before = overflow.snapshot()
	check(not overflow.advance_game_microseconds(0).ok and overflow.snapshot() == before, "Activation deadline overflow rolls back all event changes")
	var physical_character := {"speed_bonus": 0}
	var physical = Timing.new(physical_character)
	timer(physical, "expiry", 30, 0, 1, "subtract")
	text_record(physical, "text")
	owner(physical, "spell", 0, [listener("expiry"), listener("text", true)])
	physical.advance_game_microseconds(0)
	Stats.apply_actions(physical_character, [action()])
	physical.advance_game_microseconds(29 * M)
	check(physical_character.speed_bonus == 5, "Explicit Physical Speed grant lasts beyond minute 29")
	physical.advance_game_microseconds(M)
	check(physical_character.speed_bonus == 0 and physical.snapshot().active.is_empty(), "Thirty-minute expiry subtracts and cleans linked text")
	partitioned_cleanup_checks()
	clock_checks()
	print("S30 timing: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func partitioned_cleanup_checks() -> void:
	var large = Timing.new({})
	var small = Timing.new({})
	for runtime in [large, small]:
		timer(runtime, "root", 1, 1, 2)
		timer(runtime, "child", 2, 1)
		text_record(runtime, "text")
		owner(runtime, "owner", 1, [listener("root"), listener("child", true), listener("text", true)])
		runtime.queue_events("owner", 4, 3 * M)
		runtime.queue_events("owner", 8, 4 * M)
		runtime.queue_events("owner", 16, 5 * M)
		runtime.queue_events("owner", 4, 6 * M)
	var combined: Dictionary = large.advance_game_microseconds(7 * M)
	var divided: Array = []
	for elapsed in [M - 1, 1, 0, M, M, M, M, 2 * M]:
		divided.append_array(small.advance_game_microseconds(elapsed).trace)
	check(combined.trace == divided and large.snapshot() == small.snapshot(), "Partition equivalence includes finite root/linked cleanup, event ties and stale events")
	check(actions(combined.trace).size() == 2, "Removed due children and opposed timers never execute")
	# A later overflow must also undo earlier valid actions in the same update.
	var character := {"speed_bonus": 0}
	var start: int = Clock.MAX_GAME_MICROSECONDS - 3 * M
	var runtime = Timing.new(character, start)
	timer(runtime, "good", 1, 0, 1)
	timer(runtime, "overflow", 3)
	owner(runtime, "good", 1, [listener("good")], start)
	owner(runtime, "overflow", 2, [listener("overflow")], start + M)
	var before: Dictionary = runtime.snapshot()
	check(not runtime.advance_game_microseconds(2 * M).ok and runtime.snapshot() == before and character.speed_bonus == 0, "Later failure rolls back earlier actions, allocations and identity counter")
	# Caller-owned profile data cannot alter a registered action or deadline.
	var immutable = Timing.new({})
	var data := definition("immutable", 0)
	var execution := profile(1, 0, 1)
	check(immutable.register_definition(data, execution).ok, "Immutable profile registered")
	execution.action.parameter = 99
	execution.initial_timer_raw = 0
	data.comparison.parameter_raw = 99
	owner(immutable, "owner", 0, [listener("immutable")])
	check(actions(immutable.advance_game_microseconds(M).trace)[0].bonus == 5, "Definition/profile caller mutations are isolated")

func clock_checks() -> void:
	var world = World.new()
	var runtime = Timing.new(world.character, world.game_time_boundary())
	var adapter = Adapter.new(world, runtime)
	timer(runtime, "timer", 1, 0, 1)
	owner(runtime, "owner", 0, [listener("timer")], world.game_time_boundary())
	var observations: Array = []
	world.game_time_advanced.connect(func(_start, _end):
		observations.append(world.character.speed_bonus)
		check(not adapter.advance_game_microseconds(1).ok, "Adapter rejects signal reentry")
		check(not runtime.advance_game_microseconds(1).ok, "Runtime rejects signal reentry"))
	var before: Dictionary = runtime.snapshot()
	check(adapter.advance_real_seconds(100, "paused").ok and runtime.snapshot() == before, "Pause neither advances nor dispatches current-time events")
	var hunger: int = world.needs.hunger
	var thirst: int = world.needs.thirst
	var result: Dictionary = adapter.advance_real_seconds(4)
	check(result.ok and result.elapsed_game_microseconds == M and world.character.speed_bonus == 5, "Ordinary conversion executes exactly one game minute")
	check(observations == [5], "Effect commits before one world clock notification")
	check(world.needs.hunger == hunger and world.needs.thirst == thirst, "No premature metabolism tick")
	check(adapter.advance_real_seconds(1.0 / 60.0, "accelerated").elapsed_game_microseconds == M, "Accelerated conversion uses S03 once")
	adapter.advance_game_microseconds(58 * M)
	check(world.needs.hunger == hunger + 1 and world.needs.thirst == thirst + 2, "Metabolism advances once over one hour")
	before = runtime.snapshot()
	var clock_before: Dictionary = world.game_clock.snapshot()
	for invalid in [-1, 0.5]:
		check(not adapter.advance_game_microseconds(invalid).ok and runtime.snapshot() == before and world.game_clock.snapshot() == clock_before, "Invalid clock input leaves both systems unchanged")
	check(not adapter.advance_real_seconds(1, "unknown").ok, "Unknown clock mode rejected")
	world.character.speed_bonus = -1
	check(not adapter.advance_real_seconds(0.123).ok and world.game_clock.snapshot() == clock_before, "Invalid stat state cannot partially advance clock/remainder")
	world.character.speed_bonus = 5
	for connection in world.game_time_advanced.get_connections():
		world.game_time_advanced.disconnect(connection.callable)
	world.advance_game_microseconds(1)
	check(not adapter.advance_game_microseconds(0).ok, "Out-of-band clock advancement requires rebinding")
	var reloaded = World.new()
	var bound = Timing.new(reloaded.character, reloaded.game_time_boundary())
	var binding = Adapter.new(reloaded, bound)
	reloaded.character = reloaded.character.duplicate(true)
	check(not binding.advance_game_microseconds(0).ok, "Replaced character dictionary requires rebinding")
