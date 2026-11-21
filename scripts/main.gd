extends Node2D
## Current-game input controller and immediate-mode HUD. World owns simulation state;
## OriginalView renders it, and TavernMusic owns the independent audio clock.
const World = preload("res://scripts/original_world.gd")
const Music = preload("res://scripts/tavern_music.gd")
const WeatherEffects = preload("res://scripts/weather_effects.gd")
const FirstPerson = preload("res://scripts/original_view.gd")
const INK := Color("d9e0d9")
const DIM := Color("8b9b9b")
const AMBER := Color("e5b569")
const TEAL := Color("73c6bb")
const MOVE_KEYS = [KEY_W, KEY_S, KEY_A, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_Q, KEY_R]
const TURN_KEYS = [KEY_A, KEY_D, KEY_LEFT, KEY_RIGHT]
# Repeat intervals are real seconds, not simulation minutes.
const HOLD_DELAY := 0.35
const STEP_INTERVAL := 0.18
const TURN_INTERVAL := 0.30
var hold_movement := true
var controls_path := "user://controls.cfg"
var rain_time := 0.0
var application_focused := true
var held_key: int = 0
var repeat_remaining := 0.0
var world = World.new()
var music = Music.new()
var weather_effects = WeatherEffects.new()
var font: Font = ThemeDB.fallback_font
var chapters: Dictionary
var show_chapters := false
var show_map := false
var guide_on := true
var show_brief := false
var show_order := false
var order_id := ""
var order_hour := -1
var guide_path: Array[Vector2i] = []
var guide_at := Vector2i(-999, -999)
var guide_chapter := ""
var guide_return := false
var tour_index := 3
var cached_tour_index := -1
const TOUR_POINTS = [Vector2i(0,0), Vector2i(1,32), Vector2i(36,32), Vector2i(49,3)]
const TOUR_NAMES = ["northwest", "southwest", "southeast", "City entrance"]
var tavern_art: Texture2D
var viewport := SubViewport.new()
var first_person = FirstPerson.new()

## Attach one world view and music player; world owns all journey state.
func _ready() -> void:
	var controls := ConfigFile.new()
	if controls.load(controls_path) == OK:
		hold_movement = bool(controls.get_value("movement", "hold", true))
	chapters = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters.json"))
	add_child(weather_effects)
	add_child(music)
	music.set_tavern(true)
	tavern_art = preload("res://assets/art/tavern-grimthorn-v2.png")
	viewport.size = Vector2i(1024, 576)
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	viewport.add_child(first_person)
	first_person.sync(world)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

## Simulation time runs while active; chapter overview and focus loss pause it.
func _process(delta: float) -> void:
	rain_time = fmod(rain_time + delta, 60.0)
	if application_focused and not show_chapters:
		world.advance_real_seconds(delta)
		advance_held_movement(delta)
	weather_effects.advance(world, delta, music.muted)
	first_person.sync(world)
	update_guide()
	queue_redraw()

func cancel_held_movement() -> void:
	held_key = 0
	repeat_remaining = 0.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		application_focused = true
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		application_focused = false
		cancel_held_movement()

func _input(event: InputEvent) -> void:
	# Releases must reach us even when a UI control consumes keyboard input.
	if event is InputEventKey and not event.pressed and event.keycode == held_key:
		cancel_held_movement()

## The map is a live navigation aid, not a blocking menu. Tavern and modal screens block travel.
func movement_allowed() -> bool:
	return not (world.in_tavern() or show_chapters or show_brief or show_order or not order_id.is_empty())

## Dispatch the same action as a tap, then decide whether holding may continue.
## A blocked step, entrance arrival or world revision requires a fresh press.
func perform_movement(key_code: int) -> bool:
	var position_before: Vector2i = world.position
	var chapter_before: String = world.chapter
	var revision_before: int = world.revision
	var event := InputEventKey.new()
	event.keycode = key_code
	event.pressed = true
	_handle_key(event)
	return (
		movement_allowed()
		and world.chapter == chapter_before
		and world.revision == revision_before
		and (key_code in TURN_KEYS or world.position != position_before)
		and world.position != Vector2i(49, 3)
	)

## Use our own repeat cadence rather than operating-system keyboard autorepeat.
func advance_held_movement(delta: float) -> void:
	if held_key == 0:
		return
	if not hold_movement or not movement_allowed():
		cancel_held_movement()
		return
	repeat_remaining -= delta
	if repeat_remaining > 0:
		return
	if not perform_movement(held_key):
		cancel_held_movement()
		return
	# At most one action per frame: never catch up in a burst after a stall.
	repeat_remaining = TURN_INTERVAL if held_key in TURN_KEYS else STEP_INTERVAL

## Handle releases and control preferences before routing gameplay input.
## Any fresh key cancels the previous hold; releasing a different key cannot cancel the new one.
func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed():
		if event.keycode == held_key:
			cancel_held_movement()
		return
	if event.is_echo():
		return
	cancel_held_movement()
	if event.keycode == KEY_F7 and OS.is_debug_build():
		world.test_physical_speed()
		queue_redraw()
		return
	if event.keycode == KEY_F6:
		world.cycle_test_weather()
		first_person.sync(world)
		queue_redraw()
		return
	if event.keycode == KEY_H:
		hold_movement = not hold_movement
		var controls := ConfigFile.new()
		controls.set_value("movement", "hold", hold_movement)
		controls.save(controls_path)
		return
	if event.keycode in MOVE_KEYS and not world.in_tavern():
		if movement_allowed() and perform_movement(event.keycode) and hold_movement:
			held_key = event.keycode
			repeat_remaining = HOLD_DELAY
		return
	_handle_key(event)

## Route a single press through tavern menus first, then normal exploration controls.
## Repeated movement enters here too; interactions and purchases are never autorepeated.
func _handle_key(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode in [KEY_M, KEY_L, KEY_K]:
		if event.keycode == KEY_M:
			music.toggle_mute()
		elif event.keycode == KEY_L:
			music.toggle_vocals()
		else: music.toggle_subtitles()
		music.set_tavern(world.in_tavern())
		return
	if show_chapters and event.keycode not in [KEY_C, KEY_ESCAPE]:
		return
	if world.in_tavern() and not show_chapters:
		if not order_id.is_empty():
			if event.keycode == KEY_Y:
				world.order_tavern(order_id, order_hour)
				order_id = ""
			elif event.keycode in [KEY_N, KEY_ESCAPE]:
				order_id = ""
			return
		if show_map and event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_B, KEY_T]:
			return
		if show_order and event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_T, KEY_ESCAPE]:
			if event.keycode in [KEY_5, KEY_ESCAPE]:
				show_order = false
			elif event.keycode == KEY_T:
				world.wait_minutes(60 - world.minutes % 60)
			else:
				order_id = world.tavern_menu()[event.keycode - KEY_1]
				order_hour = world.menu_hour()
			return
		match event.keycode:
			KEY_1, KEY_B:
				show_order = true
				show_brief = false
				return
			KEY_2:
				show_brief = not show_brief
				show_map = false
				return
			KEY_3:
				world.leave_tavern()
				show_brief = false
				show_order = false
				show_map = false
				music.set_tavern(world.in_tavern())
				first_person.sync(world)
				return
			KEY_4:
				world.wait_minutes()
				return
			KEY_W, KEY_S, KEY_A, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_Q, KEY_R, KEY_E, KEY_ENTER:
				world.journal = "You are visiting Tail of the Dog Tavern. Choose an option from the menu."
				return
	match event.keycode:
		# Frame-driven keyboard travel must not add a second action-time charge.
		KEY_W, KEY_UP: world.move(world.DIRECTIONS[world.facing], false)
		KEY_S, KEY_DOWN: world.move(-world.DIRECTIONS[world.facing], false)
		KEY_A, KEY_LEFT: world.turn(-1)
		KEY_D, KEY_RIGHT: world.turn(1)
		KEY_Q: world.move(world.DIRECTIONS[posmod(world.facing - 1, 4)], false)
		KEY_R: world.move(world.DIRECTIONS[posmod(world.facing + 1, 4)], false)
		KEY_TAB: show_map = not show_map
		KEY_G: guide_on = not guide_on
		KEY_V:
			if world.chapter == "dungeon":
				tour_index = (tour_index + 1) % TOUR_POINTS.size()
				guide_on = true
		KEY_B: world.meal()
		KEY_ESCAPE:
			show_chapters = false
			show_map = false
			show_brief = false
			show_order = false
		KEY_E, KEY_ENTER: world.interact()
		KEY_SPACE:
			world.wait_minutes()
		KEY_C: show_chapters = not show_chapters
		KEY_F5: world.journal = "Journey saved." if world.save_game() == OK else "Could not save the journey."
		KEY_F9:
			if not world.load_game():
				world.journal = "No valid saved journey found."
			tour_index = 3
			show_order = false
			show_brief = false
	music.set_tavern(world.in_tavern())
	if world.chapter != "dungeon":
		tour_index = 3
	first_person.sync(world)

func label_at(text: String, x: float, y: float, size: int = 18, color: Color = INK) -> void:
	draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func panel(rect: Rect2) -> void:
	draw_style_box(box(Color(0.045, 0.055, 0.060, 0.86), Color("514b40")), rect)

func box(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 768), Color("091216"))
	label_at("A L T E R N A T E   R E A L I T Y", 24, 30, 15, AMBER)
	label_at("THE WAY BACK", 24, 63, 29)
	label_at("CITY + DUNGEON  /  FIRST EXCURSION", 720, 30, 13, DIM)
	label_at(world.clock_text(), 730, 63, 16, TEAL)
	draw_line(Vector2(24, 76), Vector2(1128, 76), Color("35484a"))
	label_at("Tail of the Dog Tavern" if world.in_tavern() else ("Xebec's Demise / City streets" if world.chapter == "city" else world.dungeon_region()), 24, 102, 18, AMBER)
	label_at("[H] Movement: " + ("HOLD" if hold_movement else "SINGLE STEP"), 650, 102, 14, DIM)
	label_at(world.weather_selector_label(), 430, 102, 13, AMBER if world.weather_override_index >= 0 else DIM)
	label_at(world.weather_label(), 900, 102, 13, DIM)
	panel(Rect2(22, 114, 858, 484))
	if show_map:
		draw_map()
	else:
		draw_texture_rect(tavern_art if world.in_tavern() else viewport.get_texture(), Rect2(24, 116, 854, 480), false)
		if world.weather_exposure().rain:
			draw_rain()
			draw_rect(Rect2(24, 116, 854, 454), Color(0.78, 0.87, 1.0, weather_effects.flash_opacity()))
		draw_rect(Rect2(24, 570, 854, 26), Color(0.03, 0.05, 0.07, 0.88))
		label_at(world.BEARINGS[world.facing] + " / " + world.coordinates(), 40, 589, 15, AMBER)
		label_at("CHOOSE FROM MENU     [TAB] MAP" if world.in_tavern() else "[E] " + context_action() + "     [TAB] MAP", 510, 589, 14, INK)
		if world.in_tavern():
			draw_set_transform(Vector2(0, -8), 0, Vector2(0.85, 0.95))
			draw_tavern()
			draw_set_transform(Vector2.ZERO)
	panel(Rect2(896, 114, 232, 218))
	label_at("THE TRAVELLER", 910, 145, 15, AMBER)
	label_at(world.character.name, 910, 180, 25)
	label_at("Health  %d / %d" % [world.displayed_hit_points(), world.character.max_hp], 910, 215)
	label_at(world.primary_stats_text(), 910, 247, 15, DIM)
	label_at(world.wallet_text(), 910, 287, 13, AMBER)
	label_at(world.needs_text(), 910, 313, 16, TEAL)
	panel(Rect2(896, 347, 232, 251))
	label_at("SATCHEL", 910, 379, 15, AMBER)
	for i in range(world.inventory.size()):
		label_at("+  " + str(world.inventory[i]), 910, 416 + i * 31, 19, TEAL if world.inventory[i] == "Brass token" else INK)
	label_at("Food Packets: %d" % world.provisions.food, 910, 481, 16, DIM)
	label_at("Water Flasks: %d" % world.provisions.water, 910, 505, 16, DIM)
	label_at("OBJECTIVE", 910, 535, 14, AMBER)
	label_at("Explore. Return home.", 910, 563, 16)
	label_at("COMPLETE — welcome home." if world.flags.returned else "Return to Tail of the Dog.", 910, 588, 13, TEAL if world.flags.returned else DIM)
	label_at(world.journal, 32, 642, 16, TEAL)
	if world.in_tavern():
		var song_time_seconds: float = music.song_time()
		label_at("HAIL AND WELCOME  /  GRIMTHORN REDBEARD", 32, 675, 14, AMBER)
		label_at("[L] Lead vocal " + ("ON" if music.vocals_enabled else "OFF") + "   [K] Subtitles " + ("ON" if music.subtitles_enabled else "OFF") + "   [M] " + ("Muted" if music.muted else "Mute"), 650, 675, 13, DIM)
		label_at(music.current_subtitle(), 32, 710, 22)
		draw_rect(Rect2(32, 723, 1088, 3), Color("2d4146"))
		draw_rect(Rect2(32, 723, 1088 * song_time_seconds / music.LENGTH, 3), AMBER)
	else:
		label_at(guide_text() if guide_on else "Explore at your own pace. [G] Show guide", 32, 698, 19, DIM)
	label_at("Choose a numbered option  ESC Back  TAB Map  M Mute  F5/F9 Save/Load  C Chapters" if world.in_tavern() else "W/S Step  A/D Turn  E Use  TAB Map  G Guide  M Mute  F5/F9 Save/Load  C Chapters", 32, 748, 15, DIM)
	if show_chapters:
		draw_chapters()

func draw_rain() -> void:
	# Foreground rain stays inside the world view, never over maps or indoor art.
	for i in range(100):
		var x := 32.0 + fmod(float(i * 137) + rain_time * 28.0, 830.0)
		var y := 120.0 + fmod(float(i * 79) + rain_time * (320.0 + float(i % 5) * 35.0), 430.0)
		draw_line(Vector2(x, y), Vector2(x - 4.0, y + 15.0), Color(0.64, 0.77, 0.86, 0.35), 1.0)

func draw_tavern() -> void:
	panel(Rect2(65, 216, 680, 334))
	label_at("TAIL OF THE DOG  /  TAKE A SEAT", 89, 250, 23, AMBER)
	if show_order:
		if not order_id.is_empty():
			var item: Dictionary = world.tavern.items[order_id]
			label_at(item.name, 89, 300, 26, TEAL)
			label_at(item.detail, 89, 341, 19)
			label_at("Free of charge" if int(item.copper) == 0 else "Price: %d copper" % item.copper, 89, 386, 21, AMBER)
			label_at("Time: %d minute%s" % [item.minutes, "" if int(item.minutes) == 1 else "s"], 89, 421, 18, DIM)
			label_at("[Y] Order                     [N] Cancel", 89, 500, 22)
		else:
			label_at("FOOD & DRINK   /   %02d:00 MENU" % (world.menu_hour() % 24), 89, 286, 18, TEAL)
			var items: Array = world.tavern_menu()
			for i in range(items.size()):
				var item: Dictionary = world.tavern.items[items[i]]
				label_at("[%d] %s" % [i + 1, item.name], 89, 326 + 36 * i, 21)
				label_at("Free" if int(item.copper) == 0 else "%d copper" % item.copper, 570, 326 + 36 * i, 20, AMBER)
			label_at("[5] Back      [T] Wait for the next hourly menu", 89, 483, 18, TEAL)
			label_at("Select an item to see its details before ordering.", 89, 519, 16, DIM)
	elif show_brief:
		label_at("FIRST EXCURSION — playtest scenario", 89, 287, 20, TEAL)
		label_at("Leave the tavern and follow the guide to the Dungeon.", 89, 321, 18)
		label_at("Enter, walk west into the corridor, then retrace your steps.", 89, 350, 18)
		label_at("Use the arrival point to return to the City and come home.", 89, 379, 18)
		label_at("Try saving below ground and loading before you return.", 89, 413, 17, DIM)
		label_at("Your possessions and the world clock should carry through.", 89, 442, 17, DIM)
		label_at("[2] Back to choices                 [3] Leave the tavern", 89, 511, 19, AMBER)
	else:
		label_at("Grimthorn Redbeard tends the bar and sings by the fire.", 89, 287, 18, DIM)
		label_at("[1] Order food or drink", 89, 331, 21)
		label_at("[2] Review the excursion", 89, 371, 21)
		label_at("[3] Leave for the City", 89, 411, 21)
		label_at("[4] Sit a while                 5 minutes", 89, 451, 21)
		label_at("Welcome back. Your round trip is complete." if world.flags.returned else "First excursion: visit the Dungeon and return here.", 89, 493, 18, TEAL)
		label_at("Food and drink are served here. Provisions go in your satchel.", 89, 522, 15, DIM)

func context_action() -> String:
	return world.action_text()

## Cache pathfinding until position, chapter, return objective or tour destination changes.
func update_guide() -> void:
	if guide_at == world.position and guide_chapter == world.chapter and guide_return == world.flags.visited_dungeon and cached_tour_index == tour_index:
		return
	cached_tour_index = tour_index
	guide_at = world.position
	guide_chapter = world.chapter
	guide_return = world.flags.visited_dungeon
	guide_path = world.find_route(TOUR_POINTS[tour_index] if world.chapter == "dungeon" else world.destination())

func guide_text() -> String:
	if world.flags.returned and world.in_tavern():
		return "Round trip complete."
	if guide_path.is_empty():
		if world.chapter == "dungeon":
			if world.position != TOUR_POINTS[tour_index]:
				return "No route with current door rules. [V] Change destination."
			if tour_index != 3:
				return "Reached %s. [V] Guide to the next quadrant." % TOUR_NAMES[tour_index]
		return world.hint()
	var direction_index: int = world.DIRECTIONS.find(guide_path[0] - world.position)
	var instruction := "Step forward."
	if world.facing != direction_index:
		instruction = "Turn to face " + world.BEARINGS[direction_index].to_lower() + "."
	elif world.examinable_boundary(world.position, direction_index) and not world.door_open(world.position, direction_index):
		instruction = "Press E to examine the boundary ahead."
	return "%s  %d steps to %s." % [instruction, guide_path.size(), TOUR_NAMES[tour_index] if world.chapter == "dungeon" else ("Tail of the Dog Tavern" if world.flags.visited_dungeon else "the entrance")]

## Draw directional source edges and the live player marker from the same world used by movement.
func draw_map() -> void:
	var origin := Vector2(48, 207)
	var scale_px := 6.0
	var cells: Dictionary = world.maps[world.chapter].cells
	for key in cells:
		var parts: PackedStringArray = key.split(",")
		var cell_position := Vector2i(int(parts[0]), int(parts[1]))
		var cell_screen_position := origin + Vector2(cell_position) * scale_px
		draw_rect(Rect2(cell_screen_position, Vector2.ONE * scale_px), Color("18292e"))
		for direction_index in range(4):
			var boundary_code := world.edge(cell_position, direction_index)
			if boundary_code == 0:
				continue
			var edge_start: Vector2 = [Vector2.ZERO, Vector2(scale_px, 0), Vector2(0, scale_px), Vector2.ZERO][direction_index]
			var edge_end: Vector2 = [Vector2(scale_px, 0), Vector2(scale_px, scale_px), Vector2(scale_px, scale_px), Vector2(0, scale_px)][direction_index]
			draw_line(cell_screen_position + edge_start, cell_screen_position + edge_end, AMBER if boundary_code in [3, 4, 5, 6, 29] else Color("5d7075"), 1)
	if guide_on:
		var previous_screen_position: Vector2 = origin + (Vector2(world.position) + Vector2.ONE * 0.5) * scale_px
		for cell_position in guide_path:
			var next_screen_position := origin + (Vector2(cell_position) + Vector2.ONE * 0.5) * scale_px
			draw_line(previous_screen_position, next_screen_position, Color("66bdae"), 2)
			previous_screen_position = origin + (Vector2(world.step_destination(cell_position)) + Vector2.ONE * 0.5) * scale_px
	if world.chapter == "dungeon":
		draw_line(origin + Vector2(192, 0), origin + Vector2(192, 384), TEAL, 1)
		draw_line(origin + Vector2(0, 192), origin + Vector2(384, 192), TEAL, 1)
		for key in world.dungeon_links:
			var parts: PackedStringArray = key.split(",")
			draw_circle(origin + (Vector2(int(parts[0]), int(parts[1])) + Vector2.ONE * 0.5) * scale_px, 2, TEAL)
	var center := origin + (Vector2(world.position) + Vector2.ONE * 0.5) * scale_px
	draw_circle(center, 4, AMBER)
	draw_line(center, center + Vector2(world.DIRECTIONS[world.facing]) * 10, INK, 2)
	for cell_position in [World.TAVERN_POSITION, Vector2i(50, 3) if world.chapter == "city" else Vector2i(49, 3)]:
		if world.chapter == "dungeon" and cell_position == World.TAVERN_POSITION:
			continue
		var cell_screen_position := origin + (Vector2(cell_position) + Vector2.ONE * 0.5) * scale_px
		label_at("T" if cell_position == World.TAVERN_POSITION else "D", cell_screen_position.x - 4, cell_screen_position.y - 7, 13, AMBER)
	label_at("ORIGINAL GEOGRAPHY", 464, 239, 17, AMBER)
	label_at("Teal dots: original transitions" if world.chapter == "dungeon" else "T  Tail of the Dog Tavern", 464, 276, 17)
	label_at("D  Dungeon entrance", 464, 305, 17)
	label_at("Gold edges: doors / secrets", 464, 348, 15, DIM)
	label_at("One-way faces stay one-way.", 464, 375, 15, DIM)
	label_at("[G] Toggle route guide", 464, 421, 16, TEAL)
	if world.chapter == "dungeon":
		label_at("[V] Destination: " + TOUR_NAMES[tour_index], 464, 398, 15, TEAL)
	label_at("[TAB] Return to first person", 464, 450, 16, TEAL)
	label_at("All four level-one quadrants" if world.chapter == "dungeon" else "Other districts remain in progress.", 464, 502, 14, DIM)
	if world.chapter == "dungeon":
		label_at("Other floors and encounters pending", 464, 526, 14, DIM)
	label_at(world.coordinates(), 464, 561, 20, AMBER)

func draw_chapters() -> void:
	panel(Rect2(245, 145, 660, 464))
	label_at("A WORLD WITH ROOM TO GROW", 275, 188, 24, AMBER)
	var row_y := 235
	for chapter_id in chapters:
		label_at(chapters[chapter_id].title, 280, row_y, 22)
		label_at("PROTOTYPE" if chapters[chapter_id].status == "playable" else "PLANNED / NOT IMPLEMENTED", 545, row_y, 16, TEAL if chapters[chapter_id].status == "playable" else DIM)
		row_y += 43
	label_at("Historical chapter names; this connected slice is a new design.  [C] Close", 275, 580, 14, DIM)
