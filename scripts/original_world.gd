extends "res://scripts/world.gd"
## Original-map exploration slice. Original event/economy simulation is deferred.
# Raw map codes are retained for provenance; these groups describe current support.
const EXAMINABLE_BOUNDARY_CODES := [3, 4, 5, 6]
const ROUTABLE_BOUNDARY_CODES := [0, 1, 2, 3, 4, 5, 6, 7]
const UNSUPPORTED_DOOR_CODES := [8, 9, 10, 11, 12]
const TAVERN_POSITION := Vector2i(39, 34)
const TAVERN_CELLS := [Vector2i(39, 33), TAVERN_POSITION]
const LOST_OASIS_POSITION := Vector2i(20, 1)
const SAVE_PATH := "user://original_route.json"
var maps: Dictionary = {}
var route: Dictionary
var doors: Dictionary = {}
# Increment after door/transition/load changes so the view can invalidate cached geometry.
var revision := 0
const JourneyRandom = preload("res://scripts/journey_random.gd")
const SaveStore = preload("res://scripts/journey_save_store.gd")
var gameplay_random = JourneyRandom.new(randi())
var save_store = SaveStore.new()
var weather_seed: int = randi_range(1, 2147483646)
const WEATHER_CONDITIONS := ["Hot", "Warm", "Cool", "Cold", "Rainy"]
# Session-only playtest override; -1 resumes the saved automatic schedule.
# Keep this out of journey saves so a test condition cannot become permanent.
var weather_override_index := -1
var tavern: Dictionary
var needs := {"hunger": 18, "thirst": 16}
var provisions := {"food": 0, "water": 0}
var dungeon_links: Dictionary
signal game_time_advanced(start_game_microseconds: int, end_game_microseconds: int)
var _advancing_clock := false

const CharacterStats = preload("res://scripts/character_stats.gd")
const JourneyEffects = preload("res://scripts/journey_effects.gd")
const EffectClock = preload("res://scripts/effect_clock_adapter.gd")
var journey_effects: RefCounted

## Compatibility setters/test setup can reposition an empty clock. Once effects
## exist, changing time outside the elapsed API is rejected instead of retiming them.
func _bind_effect_clock() -> bool:
	if _advancing_clock or journey_effects.runtime._busy:
		return false
	var runtime = journey_effects.runtime
	if runtime._now_game_microseconds != game_time_boundary() or not is_same(runtime._character, character):
		if not runtime.snapshot().active.is_empty() or not runtime.snapshot().queued.is_empty():
			return false
		runtime._character = character
		runtime._now_game_microseconds = game_time_boundary()
	return true

func activate_physical_speed() -> Dictionary:
	if not _bind_effect_clock():
		return {"ok": false, "error": "effect_clock_busy_or_misaligned"}
	return journey_effects.activate_physical_speed()

func physical_speed_remaining_game_microseconds() -> int:
	return journey_effects.remaining_game_microseconds()

## Test-only input uses production activation; revealing Speed is presentation,
## not an additional stat grant. Guild acquisition/casting remains later content.
func test_physical_speed() -> void:
	var result := activate_physical_speed()
	if result.ok:
		character.speed_revealed = true
		journal = "Physical Speed: +5 for 30 game minutes." if result.activated else "Physical Speed is already active; its remaining time is unchanged."
	else:
		journal = "Physical Speed could not be activated."


func stat_snapshot(stat: String) -> Dictionary:
	return CharacterStats.primary_snapshot(character, stat)

func apply_stat_actions(actions: Array) -> Dictionary:
	return CharacterStats.apply_actions(character, actions)

func set_stat_base(stat: String, value: Variant) -> Dictionary:
	return CharacterStats.set_base(character, stat, value)

func set_stat_modifiers(stat: String, bonus: Variant, penalty: Variant) -> Dictionary:
	return CharacterStats.set_modifiers(character, stat, bonus, penalty)

func set_stat_display(overrides: Dictionary) -> Dictionary:
	return CharacterStats.set_display(character, overrides)

func secondary_stat_snapshot(stat: String) -> Dictionary:
	# Needs already have an authoritative owner. Never create shadow hunger/thirst.
	if stat in ["hunger", "thirst"]:
		return {"ok": true, "value": needs[stat]}
	return CharacterStats.secondary_snapshot(character, stat)

func set_secondary_stat(stat: String, value: Variant) -> Dictionary:
	if stat in ["hunger", "thirst"]:
		if not CharacterStats.integer_value(value, 100):
			return {"ok": false, "error": "invalid_need"}
		needs[stat] = int(value)
		return {"ok": true}
	return CharacterStats.set_secondary(character, stat, value)

func displayed_hit_points() -> int:
	return int(CharacterStats.secondary_snapshot(character, "hp").displayed)

func primary_stats_text() -> String:
	var text := "STR %d     STA %d" % [stat_snapshot("strength").displayed, stat_snapshot("stamina").displayed]
	var speed := stat_snapshot("speed")
	# Remake HUD choice: show Speed even before a historical reveal event.
	if speed.ok:
		text += "  SPD %d" % speed.displayed
	return text

func effective_speed() -> int:
	var speed := stat_snapshot("speed")
	return speed.effective if speed.ok else 0

func walking_speed() -> int:
	return CharacterStats.walking_speed(character)

func _init() -> void:
	minutes = 360  # Kroah ST City: Sowings 29, Year 0, 06:00.
	journey_effects = JourneyEffects.new(character, game_time_boundary())
	for chapter_id in ["city", "dungeon"]:
		maps[chapter_id] = JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/" + chapter_id + ".json"))
	route = JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/route.json"))
	tavern = JSON.parse_string(FileAccess.get_file_as_string("res://data/tavern.json"))
	dungeon_links = JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/dungeon_links.json")).links
	character.silver = 0
	character.copper = 0
	position = TAVERN_POSITION
	facing = 2
	flags = {"visited_dungeon": false, "returned": false}
	journal = "Tail of the Dog Tavern. Order food or drink, review your excursion, or leave for the City."

## Look up a source-map cell; coordinates use east-positive X and south-positive Y.
func cell(cell_position: Vector2i, map_id: String = "") -> Dictionary:
	if map_id.is_empty():
		map_id = chapter
	return maps[map_id].cells.get("%d,%d" % [cell_position.x, cell_position.y], {})

func has_cell(cell_position: Vector2i) -> bool:
	return not cell(cell_position).is_empty()

func edge(cell_position: Vector2i, direction_index: int) -> int:
	return int(cell(cell_position).edges[direction_index]) if has_cell(cell_position) else -1

## Include the facing direction: the opposite face can have different passage rules.
func door_key(cell_position: Vector2i, direction_index: int) -> String:
	return "%s:%d,%d:%d" % [chapter, cell_position.x, cell_position.y, direction_index]

func door_open(cell_position: Vector2i, direction_index: int) -> bool:
	return doors.get(door_key(cell_position, direction_index), false)

func in_tavern() -> bool:
	return chapter == "city" and position in TAVERN_CELLS

# Presentation schedule, not a reconstruction of the original weather algorithm.
# TODO(stats): consume weather_exposure() for clothing insulation/rain protection,
# heat-driven thirst, and cold-driven fatigue/speed; shelter prevents exposure.
## Derive the hourly condition without advancing shared random state.
## The saved seed and absolute game minute reproduce future weather after loading.
func weather_at(game_minute: int) -> String:
	if weather_override_index >= 0:
		return WEATHER_CONDITIONS[weather_override_index]
	var weather_random := RandomNumberGenerator.new()
	weather_random.seed = weather_seed + int(game_minute / 60) * 104729
	return WEATHER_CONDITIONS[weather_random.randi_range(0, WEATHER_CONDITIONS.size() - 1)]

## Fix the effective weather for equipment/exposure tests without spending game time.
## All consumers use weather_at(), so visuals and future stat inputs stay consistent.
func cycle_test_weather() -> void:
	weather_override_index += 1
	if weather_override_index >= WEATHER_CONDITIONS.size():
		weather_override_index = -1

func weather_selector_label() -> String:
	if weather_override_index < 0:
		return "[F6] Weather: AUTO"
	return "[F6] Test: " + WEATHER_CONDITIONS[weather_override_index]

## Read-only inputs for future equipment and stat rules; currently applies no penalties.
func weather_exposure() -> Dictionary:
	var condition := weather_at(minutes)
	var exposed := chapter == "city" and not is_inside(position)
	return {"condition": condition, "exposed": exposed,
		"rain": exposed and condition == "Rainy",
		"cold": exposed and condition in ["Cold", "Rainy"],
		"heat": exposed and condition == "Hot"}

func weather_label() -> String:
	if chapter != "city":
		return "Underground / sheltered"
	return weather_at(minutes) + (" / sheltered" if is_inside(position) else " / outdoors")

func is_inside(cell_position: Vector2i) -> bool:
	if chapter == "dungeon":
		return true
	var location_code := int(cell(cell_position).get("location", 0))
	# Presentation classification from ARX descriptions; enclosed yards stay open.
	return location_code == 7 or (location_code >= 16 and location_code <= 59) or location_code == 65 or location_code == 66 or (location_code >= 68 and location_code <= 89)

func tile(cell_position: Vector2i) -> String:
	if not has_cell(cell_position):
		return "#"
	if chapter == "city" and cell_position in TAVERN_CELLS:
		return "T"
	if cell_position == Vector2i(49, 3):
		return "D" if chapter == "city" else "U"
	return "."

## ARX marks exterior tavern doors with code 29; keep the raw map unchanged.
## Only Tail of the Dog is implemented as a service screen.
func examinable_boundary(cell_position: Vector2i, direction_index: int) -> bool:
	var boundary_code := edge(cell_position, direction_index)
	return boundary_code in EXAMINABLE_BOUNDARY_CODES or (
		chapter == "city" and boundary_code == 29
		and cell_position + DIRECTIONS[direction_index] in TAVERN_CELLS
	)

## The guide may plan through examinable doors, even before the player opens them.
## Actual movement still checks the approached face in move().
func can_route(cell_position: Vector2i, direction_index: int) -> bool:
	return has_cell(cell_position + DIRECTIONS[direction_index]) and (edge(cell_position, direction_index) in ROUTABLE_BOUNDARY_CODES or examinable_boundary(cell_position, direction_index))

## Validate one cardinal step, charge time only on success, then resolve any arrival link.
## revision invalidates rendered geometry and stops held input after automatic transitions.
func move(direction: Vector2i, charge_travel_time: bool = true) -> bool:
	var direction_index := DIRECTIONS.find(direction)
	if direction_index == -1:
		return false
	var boundary_code := edge(position, direction_index)
	if not has_cell(position + direction):
		journal = "This area is outside the current reconstruction."
		return false
	if examinable_boundary(position, direction_index) and not door_open(position, direction_index):
		journal = "A boundary blocks your path. Face it and press E to examine."
		return false
	if boundary_code not in ROUTABLE_BOUNDARY_CODES and not examinable_boundary(position, direction_index):
		journal = "The door is barred. Its original mechanism is not implemented." if boundary_code in UNSUPPORTED_DOOR_CODES else "Stone blocks your way."
		return false
	position += direction
	if charge_travel_time:
		advance_time(1)
	var transitioned := false
	if chapter == "dungeon":
		var transition_link: Dictionary = dungeon_links.get("%d,%d" % [position.x, position.y], {})
		if not transition_link.is_empty() and transition_link.enabled:
			position = Vector2i(transition_link.target[0], transition_link.target[1])
			var arrival_facing := int(transition_link.facing)
			if arrival_facing < 128:
				facing = arrival_facing
			elif arrival_facing != 255:
				facing = gameplay_random.next_facing()
			revision += 1
			transitioned = true
	if in_tavern():
		facing = 2
	if in_tavern() and flags.visited_dungeon:
		flags.returned = true
		journal = "Round trip complete. You have returned to Tail of the Dog Tavern."
	else: journal = "The passage leads onward. " + dungeon_region() if transitioned else hint()
	return true

func dungeon_region() -> String:
	return "Level 1 / " + ["northwest", "northeast", "southwest", "southeast"][int(position.x / 32) + 2 * int(position.y / 32)]

func step_destination(entry: Vector2i) -> Vector2i:
	if chapter == "dungeon":
		var link: Dictionary = dungeon_links.get("%d,%d" % [entry.x, entry.y], {})
		if not link.is_empty() and link.enabled:
			return Vector2i(link.target[0], link.target[1])
	return entry

func interact() -> void:
	if position == Vector2i(49, 3) and (chapter == "dungeon" or facing == 1):
		chapter = "dungeon" if chapter == "city" else "city"
		facing = 3 if chapter == "dungeon" else 2
		advance_time(5)
		flags.visited_dungeon = true
		revision += 1
		journal = "The Dungeon entrance. Your possessions and clock travel with you." if chapter == "dungeon" else "Back in the City. Follow the return guide to Tail of the Dog Tavern."
		return
	var boundary_code := edge(position, facing)
	if examinable_boundary(position, facing):
		doors[door_key(position, facing)] = true
		# Store only the approached face: one-way boundaries must stay one-way.
		revision += 1
		journal = "A concealed passage opens." if boundary_code in [5, 6] else "The door opens."
		return
	if in_tavern():
		meal()
	else:
		journal = "No mechanism here is ready to use."

func meal() -> void:
	# Compatibility entry point: no hidden purchase without a menu selection.
	if in_tavern():
		journal = "Choose an item from the food and drink menu."

## Single time-consumer boundary: S30 consumes the timestamp pair before the
## provisional needs update, matching the source effect-before-metabolism order.
## Observers cannot reenter and charge time twice.
func _finish_clock_advance(result: Dictionary) -> Dictionary:
	if result.ok and result.elapsed_game_microseconds > 0:
		var before: int = result.start_game_microseconds / GameClock.GAME_MICROSECONDS_PER_MINUTE
		var after: int = result.end_game_microseconds / GameClock.GAME_MICROSECONDS_PER_MINUTE
		game_time_advanced.emit(result.start_game_microseconds, result.end_game_microseconds)
		# Provisional needs rates remain S09's responsibility.
		needs.hunger = mini(100, int(needs.hunger) + after / 60 - before / 60)
		needs.thirst = mini(100, int(needs.thirst) + after / 30 - before / 30)
	_advancing_clock = false
	return result

func advance_game_microseconds(elapsed: int) -> Dictionary:
	if not _bind_effect_clock():
		return game_clock.rejected("Effect clock is busy or requires rebinding.")
	return EffectClock.new(self, journey_effects.runtime).advance_game_microseconds(elapsed)

func advance_real_seconds(real_seconds: float, mode: String = "ordinary") -> Dictionary:
	if not _bind_effect_clock():
		return game_clock.rejected("Effect clock is busy or requires rebinding.")
	return EffectClock.new(self, journey_effects.runtime).advance_real_seconds(real_seconds, mode)

## Adapter-only commit: conversion/effects have already been validated. Calling
## the public elapsed method here would recurse and execute the interval twice.
func _advance_clock_only(elapsed: int) -> Dictionary:
	if _advancing_clock:
		return game_clock.rejected("Clock consumers cannot advance time reentrantly.")
	_advancing_clock = true
	return _finish_clock_advance(game_clock.advance_game_microseconds(elapsed))

## Future work/sleep/learning scenes use this adapter, never also advance_time().
func advance_service_seconds(real_seconds: float, paused: bool = false) -> Dictionary:
	return advance_real_seconds(real_seconds, "paused" if paused else "accelerated")

## An event stamped here belongs before timers at this exact boundary. S30 owns
## queued event/deadline ordering; this clock never invokes an effect scheduler.
func game_time_boundary() -> int:
	return game_clock.game_microseconds

func calendar() -> Dictionary:
	return game_clock.calendar()

func clock_text() -> String:
	var date := calendar()
	return "%s %d, Y%d  /  %02d:%02d" % [date.month_name, date.day, date.year, date.hour, date.minute]

## Explicit service/wait costs are already game minutes, not accelerated real time.
func advance_time(elapsed_minutes: int) -> bool:
	if elapsed_minutes < 0 or elapsed_minutes > GameClock.MAX_GAME_MICROSECONDS / GameClock.GAME_MICROSECONDS_PER_MINUTE:
		return false
	return advance_game_microseconds(elapsed_minutes * GameClock.GAME_MICROSECONDS_PER_MINUTE).ok

func wallet_copper() -> int:
	return int(character.gold) * 100 + int(character.silver) * 10 + int(character.copper)

func wallet_text() -> String:
	return "%d gold  %d silver  %d copper" % [character.gold, character.silver, character.copper]

func menu_hour() -> int:
	return int(minutes / 60)

func tavern_menu() -> Array:
	return tavern.menus[menu_hour() % tavern.menus.size()]

## Recheck the quoted menu hour before spending coins; stale confirmations cannot buy items.
func order_tavern(item_id: String, quoted_hour: int) -> bool:
	if not in_tavern():
		return false
	if quoted_hour != menu_hour() or item_id not in tavern_menu():
		journal = "The menu has changed. Please choose again."
		return false
	var menu_item: Dictionary = tavern.items[item_id]
	var cost_copper := int(menu_item.copper)
	var balance_copper := wallet_copper()
	if balance_copper < cost_copper:
		journal = "You need %d copper for %s; you have %d." % [cost_copper, menu_item.name, balance_copper]
		return false
	if not advance_time(int(menu_item.minutes)):
		return false
	if cost_copper > 0:
		balance_copper -= cost_copper
		character.gold = int(balance_copper / 100)
		character.silver = int((balance_copper % 100) / 10)
		character.copper = balance_copper % 10
	needs.hunger = maxi(0, int(needs.hunger) - int(menu_item.hunger))
	needs.thirst = maxi(0, int(needs.thirst) - int(menu_item.thirst))
	provisions.food += int(menu_item.food)
	provisions.water += int(menu_item.water)
	journal = "%s served. %s" % [menu_item.name, "No charge." if cost_copper == 0 else "%d copper paid." % cost_copper]
	if int(menu_item.food) > 0:
		journal += " One Food Packet packed."
	if int(menu_item.water) > 0:
		journal += " One Water Flask packed."
	return true

func wait_minutes(elapsed_minutes: int = 5) -> void:
	if not advance_time(elapsed_minutes):
		return
	journal = "You wait %d minutes." % elapsed_minutes
	if in_tavern():
		if needs.hunger >= 8 and provisions.food > 0:
			provisions.food -= 1
			needs.hunger = maxi(0, int(needs.hunger) - 8)
			journal += " You eat a Food Packet."
		if needs.thirst >= 8 and provisions.water > 0:
			provisions.water -= 1
			needs.thirst = maxi(0, int(needs.thirst) - 8)
			journal += " You drink a Water Flask."

func needs_text() -> String:
	return "%s / %s" % ["Hungry" if needs.hunger >= 8 else "Fed", "Thirsty" if needs.thirst >= 8 else "Refreshed"]

func leave_tavern() -> void:
	if not in_tavern():
		return
	# A service screen exits through the existing mapped boundary, not a new shortcut.
	# Both marker-16 cells belong to the same establishment; exit via its south door.
	facing = 2
	if position != TAVERN_POSITION:
		step()
	if examinable_boundary(position, facing):
		interact()
	step()

func hint() -> String:
	if chapter == "city" and position == LOST_OASIS_POSITION:
		return "Lost Oasis. Services here are not implemented; Tail of the Dog is farther south."
	if in_tavern():
		return "Tail of the Dog Tavern. 1: order. 2: excursion. 3: leave. 4: sit a while."
	if position == Vector2i(49, 3):
		return "Face east and press E to descend." if chapter == "city" else "E: return to the City. The original arrival faces west."
	return "Explore level one; the guide leads back to the City entrance." if chapter == "dungeon" else "Follow the guide, or use Tab to inspect the map."

## Convert internal map indices to each chapter's historical displayed coordinates.
func coordinates() -> String:
	if chapter == "city":
		return "%02dN  %02dE" % [64 - position.y, position.x + 1]
	return "%02dN  %02dE" % [63 - position.y, position.x]

func action_text() -> String:
	if position == Vector2i(49, 3) and (chapter == "dungeon" or facing == 1):
		return "RETURN TO CITY" if chapter == "dungeon" else "ENTER DUNGEON"
	var boundary_code := edge(position, facing)
	if boundary_code in [3, 4, 29]:
		return "OPEN DOOR" if not door_open(position, facing) else "DOOR OPEN"
	if boundary_code in [5, 6]:
		return "EXAMINE WALL" if not door_open(position, facing) else "PASSAGE OPEN"
	return "FOOD AND DRINK" if in_tavern() else "EXAMINE"

## Breadth-first search over directional boundaries and enabled Dungeon transitions.
## Parents retain both the pre-transition entry cell and the resulting arrival position,
## so guide arrows lead to the passage entrance instead of drawing a teleport as a step.
func find_route(target: Vector2i) -> Array[Vector2i]:
	var queue: Array[Vector2i] = [position]
	var parents: Dictionary = {position: position}
	var queue_index := 0
	while queue_index < queue.size():
		var route_position := queue[queue_index]
		queue_index += 1
		if route_position == target:
			break
		for direction_index in range(4):
			var entry_position: Vector2i = route_position + DIRECTIONS[direction_index]
			# Do not route through the modal tavern as a street shortcut.
			if chapter == "city" and entry_position in TAVERN_CELLS and target not in TAVERN_CELLS:
				continue
			var arrival_position := step_destination(entry_position)
			if can_route(route_position, direction_index) and not parents.has(arrival_position):
				parents[arrival_position] = [route_position, entry_position]
				queue.append(arrival_position)
	var path: Array[Vector2i] = []
	if not parents.has(target):
		return path
	var route_position := target
	while route_position != position:
		path.push_front(parents[route_position][1])
		route_position = parents[route_position][0]
	return path

func destination() -> Vector2i:
	return TAVERN_POSITION if chapter == "city" and flags.visited_dungeon else Vector2i(49, 3)

## Persist simulation state only; music and movement preferences have their own files.
func save_game(path: String = SAVE_PATH) -> Error:
	if not _bind_effect_clock():
		return ERR_BUSY
	if not journey_effects.can_save():
		return ERR_INVALID_DATA
	var serialized := JSON.stringify(save_snapshot(), "", true, true)
	# Validate the serialized representation too: JSON can change numeric types.
	if _validated_save(JSON.parse_string(serialized)).is_empty():
		return ERR_INVALID_DATA
	return save_store.write(path, serialized)

func save_snapshot() -> Dictionary:
	return {"version": 8, "map_set": "original-route-1", "chapter": chapter,
		"position": [position.x, position.y], "facing": facing, "character": character.duplicate(true),
		"inventory": inventory.duplicate(true), "minutes": minutes, "flags": flags.duplicate(true), "doors": doors.duplicate(true),
		"needs": needs.duplicate(true), "provisions": provisions.duplicate(true), "weather_seed": weather_seed,
		"minute_fraction": minute_fraction, "clock": game_clock.snapshot(),
		"effects": journey_effects.save_payload(), "gameplay_random": gameplay_random.snapshot()}

## Validate and migrate a temporary dictionary before changing the live journey.
## Version 3 gains neutral needs/provisions; older version 4 saves gain a weather seed.
func load_game(path: String = SAVE_PATH) -> bool:
	if _advancing_clock or journey_effects.runtime._busy:
		return false
	var readable_path: String = save_store.readable_path(path)
	if not FileAccess.file_exists(readable_path):
		return false
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(readable_path)) != OK:
		return false
	var candidate := _validated_save(parser.data)
	if candidate.is_empty():
		return false
	var save_data: Dictionary = candidate.data
	# Commit only after every field, including effect references, has passed.
	journey_effects = candidate.effects
	gameplay_random = candidate.random
	game_clock = candidate.clock
	weather_seed = int(save_data.get("weather_seed", 1701))
	chapter = save_data.chapter
	position = Vector2i(save_data.position[0], save_data.position[1])
	facing = int(save_data.facing)
	character = save_data.character
	inventory = save_data.inventory
	minutes = int(save_data.minutes)
	flags = save_data.flags
	doors = save_data.doors
	needs = save_data.needs
	provisions = save_data.provisions
	for key in needs: needs[key] = int(needs[key])
	for key in provisions: provisions[key] = int(provisions[key])
	revision += 1
	journal = "Journey restored. " + hint()
	return true

## Build detached candidates; never mutate live state or caller-owned dictionaries.
func _validated_save(input: Variant) -> Dictionary:
	var save_data = input.duplicate(true) if input is Dictionary else input

	if not save_data is Dictionary or save_data.get("map_set") != "original-route-1":
		return {}
	if not CharacterStats.integer_value(save_data.get("version"), 8) or save_data.version < 3:
		return {}
	if not save_data.get("chapter") is String or not maps.has(save_data.chapter):
		return {}
	if not save_data.get("position") is Array or save_data.position.size() != 2:
		return {}
	for coordinate_component in save_data.position:
		if not CharacterStats.integer_value(coordinate_component, 63):
			return {}
	var saved_position := Vector2i(save_data.position[0], save_data.position[1])
	if cell(saved_position, save_data.chapter).is_empty():
		return {}
	for key in ["character", "flags", "doors"]:
		if not save_data.get(key) is Dictionary:
			return {}
	if save_data.version == 3:
		save_data.character["silver"] = 0
		save_data.character["copper"] = 0
		save_data["needs"] = {"hunger": 0, "thirst": 0}
		save_data["provisions"] = {"food": 0, "water": 0}
	for group in ["needs", "provisions"]:
		if not save_data.get(group) is Dictionary:
			return {}
		for key in save_data[group]:
			var value = save_data[group].get(key)
			if not CharacterStats.integer_value(value, 9000000000000000):
				return {}
			if group == "needs" and value > 100:
				return {}
	for key in ["hunger", "thirst"]:
		if not save_data.needs.has(key):
			return {}
	for key in ["food", "water"]:
		if not save_data.provisions.has(key):
			return {}
	var stats_candidate := CharacterStats.normalize_character(save_data.character)
	if not stats_candidate.ok:
		return {}
	save_data.character = stats_candidate.character
	for key in ["visited_dungeon", "returned"]:
		if not save_data.flags.get(key) is bool:
			return {}
	for key in save_data.flags:
		if not save_data.flags[key] is bool:
			return {}
	for key in save_data.doors:
		if not save_data.doors[key] is bool:
			return {}
	if not save_data.get("inventory") is Array:
		return {}
	for item in save_data.inventory:
		if not item is String:
			return {}
	for key in ["minutes", "facing"]:
		if not CharacterStats.integer_value(save_data.get(key), 150000000 if key == "minutes" else 3):
			return {}
	if save_data.minutes < 0 or save_data.facing < 0 or save_data.facing > 3:
		return {}
	var saved_weather_seed = save_data.get("weather_seed", 1701)
	if not (saved_weather_seed is int or saved_weather_seed is float) or not is_finite(float(saved_weather_seed)) or saved_weather_seed != int(saved_weather_seed) or saved_weather_seed < 1 or saved_weather_seed > 2147483646:
		return {}
	var saved_minute_fraction = save_data.get("minute_fraction", 0.0)
	if not (saved_minute_fraction is float or saved_minute_fraction is int) or not is_finite(float(saved_minute_fraction)) or saved_minute_fraction < 0 or saved_minute_fraction >= 1:
		return {}
	var saved_clock = GameClock.new(0)
	if save_data.version >= 5:
		if not saved_clock.restore(save_data.get("clock")):
			return {}
		if saved_clock.whole_minutes() != int(save_data.minutes) or absf(saved_clock.minute_fraction() - float(saved_minute_fraction)) > 0.000000000001:
			return {}
	elif not saved_clock.set_minutes(int(save_data.minutes)) or not saved_clock.set_minute_fraction(float(saved_minute_fraction)):
		return {}
	var saved_effects = JourneyEffects.new(save_data.character, saved_clock.game_microseconds)
	if save_data.version >= 7:
		if not saved_effects.restore_payload(save_data.get("effects")):
			return {}
	elif save_data.has("effects"):
		# A downgraded version must not silently discard an effect payload.
		return {}
	var saved_random = JourneyRandom.new(1701)
	if save_data.version == 8:
		if not saved_random.restore(save_data.get("gameplay_random")):
			return {}
	elif save_data.has("gameplay_random"):
		return {} # Do not silently discard continuation state on a downgraded save.
	return {"data": save_data, "clock": saved_clock, "effects": saved_effects, "random": saved_random}
