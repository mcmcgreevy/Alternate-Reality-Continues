extends Node2D
const World = preload("res://scripts/original_world.gd")
const Music = preload("res://scripts/tavern_music.gd")
const FirstPerson = preload("res://scripts/original_view.gd")
const INK := Color("d9e0d9")
const DIM := Color("8b9b9b")
const AMBER := Color("e5b569")
const TEAL := Color("73c6bb")
var world = World.new()
var music = Music.new()
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
var viewport := SubViewport.new()
var first_person = FirstPerson.new()

func _ready() -> void:
	chapters = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters.json"))
	add_child(music)
	music.set_tavern(true)
	viewport.size = Vector2i(375, 210)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	viewport.add_child(first_person)
	first_person.sync(world)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(_delta: float) -> void:
	first_person.sync(world)
	update_guide()
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if show_chapters and event.keycode not in [KEY_C, KEY_ESCAPE]: return
	if world.in_tavern() and not show_chapters:
		if not order_id.is_empty():
			if event.keycode == KEY_Y:
				world.order_tavern(order_id, order_hour)
				order_id = ""
			elif event.keycode in [KEY_N, KEY_ESCAPE]: order_id = ""
			elif event.keycode == KEY_M: music.toggle_mute()
			return
		if show_map and event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_B, KEY_T]: return
		if show_order and event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_T, KEY_ESCAPE]:
			if event.keycode in [KEY_5, KEY_ESCAPE]: show_order = false
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
				world.journal = "You are visiting The Tavern. Choose an option from the menu."
				return
	match event.keycode:
		KEY_W, KEY_UP: world.step()
		KEY_S, KEY_DOWN: world.step(true)
		KEY_A, KEY_LEFT: world.turn(-1)
		KEY_D, KEY_RIGHT: world.turn(1)
		KEY_Q: world.strafe(false)
		KEY_R: world.strafe(true)
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
		KEY_M: music.toggle_mute()
		KEY_C: show_chapters = not show_chapters
		KEY_F5: world.journal = "Journey saved." if world.save_game() == OK else "Could not save the journey."
		KEY_F9:
			if not world.load_game(): world.journal = "No valid saved journey found."
			tour_index = 3
			show_order = false
			show_brief = false
	music.set_tavern(world.in_tavern())
	if world.chapter != "dungeon": tour_index = 3
	first_person.sync(world)

func label_at(text: String, x: float, y: float, size: int = 18, color: Color = INK) -> void:
	draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func panel(rect: Rect2) -> void:
	draw_style_box(box(Color("101c22"), Color("2d4146")), rect)

func box(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 768), Color("091216"))
	label_at("A L T E R N A T E   R E A L I T Y", 32, 40, 19, AMBER)
	label_at("THE WAY BACK", 32, 79, 32)
	label_at("CITY + DUNGEON  /  FIRST EXCURSION", 720, 38, 15, DIM)
	label_at(world.clock_text(), 815, 76, 21, TEAL)
	draw_line(Vector2(32, 98), Vector2(1120, 98), Color("35484a"))
	label_at("01 / THE CITY" if world.chapter == "city" else "02 / THE DUNGEON", 32, 134, 20, AMBER)
	label_at("The Tavern" if world.in_tavern() else ("Xebec's Demise / northern streets" if world.chapter == "city" else world.dungeon_region()), 32, 161, 17, DIM)
	panel(Rect2(32, 182, 754, 430))
	if show_map:
		draw_map()
	else:
		draw_texture_rect(viewport.get_texture(), Rect2(34, 184, 750, 420), false)
		draw_rect(Rect2(34, 578, 750, 26), Color(0.03, 0.05, 0.07, 0.88))
		label_at(world.BEARINGS[world.facing] + " / " + world.coordinates(), 48, 597, 15, AMBER)
		label_at("CHOOSE FROM MENU     [TAB] MAP" if world.in_tavern() else "[E] " + context_action() + "     [TAB] MAP", 430, 597, 14, INK)
		if world.in_tavern(): draw_tavern()
	panel(Rect2(810, 115, 310, 217))
	label_at("THE TRAVELLER", 832, 145, 15, AMBER)
	label_at(world.character.name, 832, 180, 25)
	label_at("Health  %d / %d" % [world.character.hp, world.character.max_hp], 832, 215)
	label_at("STR %d     STA %d" % [world.character.strength, world.character.stamina], 832, 247, 17, DIM)
	label_at(world.wallet_text(), 832, 287, 16, AMBER)
	label_at(world.needs_text(), 832, 313, 16, TEAL)
	panel(Rect2(810, 347, 310, 265))
	label_at("SATCHEL", 832, 379, 15, AMBER)
	for i in range(world.inventory.size()):
		label_at("+  " + str(world.inventory[i]), 832, 416 + i * 31, 19, TEAL if world.inventory[i] == "Brass token" else INK)
	label_at("Food Packets: %d" % world.provisions.food, 832, 481, 16, DIM)
	label_at("Water Flasks: %d" % world.provisions.water, 832, 505, 16, DIM)
	label_at("OBJECTIVE", 832, 535, 14, AMBER)
	label_at("Visit the Dungeon entrance.", 832, 563, 17)
	label_at("COMPLETE — welcome home." if world.flags.returned else "Return to The Tavern.", 832, 588, 15, TEAL if world.flags.returned else DIM)
	label_at(world.journal, 32, 642, 16, TEAL)
	if world.in_tavern():
		var song_t: float = music.song_time()
		label_at("TAVERN SONG  /  " + ("MUTED" if music.muted else "ORIGINAL SID-STYLE CUE"), 32, 678, 12, AMBER)
		label_at(music.LYRICS[int(song_t / 4.0) % 4], 32, 710, 23)
		draw_rect(Rect2(540, 692, 230, 3), Color("2d4146"))
		draw_rect(Rect2(540, 692, 230 * fmod(song_t, 4.0) / 4.0, 3), AMBER)
	else:
		label_at(guide_text() if guide_on else "Explore at your own pace. [G] Show guide", 32, 698, 19, DIM)
	label_at("Choose a numbered option  ESC Back  TAB Map  M Mute  F5/F9 Save/Load  C Chapters" if world.in_tavern() else "W/S Step  A/D Turn  E Use  TAB Map  G Guide  M Mute  F5/F9 Save/Load  C Chapters", 32, 748, 15, DIM)
	if show_chapters: draw_chapters()

func draw_tavern() -> void:
	panel(Rect2(65, 216, 680, 334))
	label_at("THE TAVERN  /  TAKE A SEAT", 89, 250, 23, AMBER)
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
		label_at("A warm room, a song, and a moment before the journey.", 89, 287, 18, DIM)
		label_at("[1] Order food or drink", 89, 331, 21)
		label_at("[2] Review the excursion", 89, 371, 21)
		label_at("[3] Leave for the City", 89, 411, 21)
		label_at("[4] Sit a while                 5 minutes", 89, 451, 21)
		label_at("Welcome back. Your round trip is complete." if world.flags.returned else "First excursion: visit the Dungeon and return here.", 89, 493, 18, TEAL)
		label_at("Food and drink are served here. Provisions go in your satchel.", 89, 522, 15, DIM)

func context_action() -> String:
	return world.action_text()

func update_guide() -> void:
	if guide_at == world.position and guide_chapter == world.chapter and guide_return == world.flags.visited_dungeon and cached_tour_index == tour_index: return
	cached_tour_index = tour_index
	guide_at = world.position
	guide_chapter = world.chapter
	guide_return = world.flags.visited_dungeon
	guide_path = world.find_route(TOUR_POINTS[tour_index] if world.chapter == "dungeon" else world.destination())

func guide_text() -> String:
	if world.flags.returned and world.in_tavern(): return "Round trip complete."
	if guide_path.is_empty():
		if world.chapter == "dungeon":
			if world.position != TOUR_POINTS[tour_index]: return "No route with current door rules. [V] Change destination."
			if tour_index != 3: return "Reached %s. [V] Guide to the next quadrant." % TOUR_NAMES[tour_index]
		return world.hint()
	var d: int = world.DIRECTIONS.find(guide_path[0] - world.position)
	var instruction := "Step forward."
	if world.facing != d:
		instruction = "Turn to face " + world.BEARINGS[d].to_lower() + "."
	elif world.edge(world.position, d) in [3, 4, 5, 6] and not world.door_open(world.position, d):
		instruction = "Press E to examine the boundary ahead."
	return "%s  %d steps to %s." % [instruction, guide_path.size(), TOUR_NAMES[tour_index] if world.chapter == "dungeon" else ("The Tavern" if world.flags.visited_dungeon else "the entrance")]

func draw_map() -> void:
	var origin := Vector2(48, 207)
	var scale_px := 6.0
	var cells: Dictionary = world.maps[world.chapter].cells
	for key in cells:
		var parts: PackedStringArray = key.split(",")
		var at := Vector2i(int(parts[0]), int(parts[1]))
		var p := origin + Vector2(at) * scale_px
		draw_rect(Rect2(p, Vector2.ONE * scale_px), Color("18292e"))
		for d in range(4):
			var code := world.edge(at, d)
			if code == 0: continue
			var a: Vector2 = [Vector2.ZERO, Vector2(scale_px, 0), Vector2(0, scale_px), Vector2.ZERO][d]
			var b: Vector2 = [Vector2(scale_px, 0), Vector2(scale_px, scale_px), Vector2(scale_px, scale_px), Vector2(0, scale_px)][d]
			draw_line(p + a, p + b, AMBER if code in [3, 4, 5, 6] else Color("5d7075"), 1)
	if guide_on:
		var previous: Vector2 = origin + (Vector2(world.position) + Vector2.ONE * 0.5) * scale_px
		for at in guide_path:
			var next := origin + (Vector2(at) + Vector2.ONE * 0.5) * scale_px
			draw_line(previous, next, Color("66bdae"), 2)
			previous = origin + (Vector2(world.step_destination(at)) + Vector2.ONE * 0.5) * scale_px
	if world.chapter == "dungeon":
		draw_line(origin + Vector2(192, 0), origin + Vector2(192, 384), TEAL, 1)
		draw_line(origin + Vector2(0, 192), origin + Vector2(384, 192), TEAL, 1)
		for key in world.dungeon_links:
			var parts: PackedStringArray = key.split(",")
			draw_circle(origin + (Vector2(int(parts[0]), int(parts[1])) + Vector2.ONE * 0.5) * scale_px, 2, TEAL)
	var center := origin + (Vector2(world.position) + Vector2.ONE * 0.5) * scale_px
	draw_circle(center, 4, AMBER)
	draw_line(center, center + Vector2(world.DIRECTIONS[world.facing]) * 10, INK, 2)
	for at in [Vector2i(20, 1), Vector2i(49, 3)]:
		if world.chapter == "dungeon" and at.x == 20: continue
		var p := origin + (Vector2(at) + Vector2.ONE * 0.5) * scale_px
		label_at("T" if at.x == 20 else "D", p.x - 4, p.y - 7, 13, AMBER)
	label_at("ORIGINAL GEOGRAPHY", 464, 239, 17, AMBER)
	label_at("Teal dots: original transitions" if world.chapter == "dungeon" else "T  The Tavern", 464, 276, 17)
	label_at("D  Dungeon entrance", 464, 305, 17)
	label_at("Gold edges: doors / secrets", 464, 348, 15, DIM)
	label_at("One-way faces stay one-way.", 464, 375, 15, DIM)
	label_at("[G] Toggle route guide", 464, 421, 16, TEAL)
	if world.chapter == "dungeon": label_at("[V] Destination: " + TOUR_NAMES[tour_index], 464, 398, 15, TEAL)
	label_at("[TAB] Return to first person", 464, 450, 16, TEAL)
	label_at("All four level-one quadrants" if world.chapter == "dungeon" else "Other districts remain in progress.", 464, 502, 14, DIM)
	if world.chapter == "dungeon": label_at("Other floors and encounters pending", 464, 526, 14, DIM)
	label_at(world.coordinates(), 464, 561, 20, AMBER)

func draw_chapters() -> void:
	panel(Rect2(245, 145, 660, 464))
	label_at("A WORLD WITH ROOM TO GROW", 275, 188, 24, AMBER)
	var y := 235
	for id in chapters:
		label_at(chapters[id].title, 280, y, 22)
		label_at("PROTOTYPE" if chapters[id].status == "playable" else "PLANNED / NOT IMPLEMENTED", 545, y, 16, TEAL if chapters[id].status == "playable" else DIM)
		y += 43
	label_at("Historical chapter names; this connected slice is a new design.  [C] Close", 275, 580, 14, DIM)
