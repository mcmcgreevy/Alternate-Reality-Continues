extends Node2D
const World = preload("res://scripts/world.gd")
const Music = preload("res://scripts/tavern_music.gd")
const FirstPerson = preload("res://scripts/first_person.gd")
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
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if show_chapters and event.keycode not in [KEY_C, KEY_ESCAPE]: return
	match event.keycode:
		KEY_W, KEY_UP: world.step()
		KEY_S, KEY_DOWN: world.step(true)
		KEY_A, KEY_LEFT: world.turn(-1)
		KEY_D, KEY_RIGHT: world.turn(1)
		KEY_Q: world.strafe(false)
		KEY_R: world.strafe(true)
		KEY_TAB: show_map = not show_map
		KEY_ESCAPE:
			show_chapters = false
			show_map = false
		KEY_E, KEY_ENTER: world.interact()
		KEY_SPACE:
			world.minutes += 5
			world.journal = "You wait five minutes."
		KEY_M: music.toggle_mute()
		KEY_C: show_chapters = not show_chapters
		KEY_F5: world.journal = "Journey saved." if world.save_game() == OK else "Could not save the journey."
		KEY_F9:
			if not world.load_game(): world.journal = "No valid saved journey found."
	music.set_tavern(world.in_tavern())
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
	label_at("CITY + DUNGEON  /  FIRST-PERSON STUDY 02", 720, 38, 15, DIM)
	label_at(world.clock_text(), 815, 76, 21, TEAL)
	draw_line(Vector2(32, 98), Vector2(1120, 98), Color("35484a"))
	label_at("01 / THE CITY" if world.chapter == "city" else "02 / THE DUNGEON", 32, 134, 20, AMBER)
	label_at("The Lantern & the Gate" if world.in_tavern() else ("Streets above the dark" if world.chapter == "city" else "The forgotten undercroft"), 32, 161, 17, DIM)
	panel(Rect2(32, 182, 754, 430))
	if show_map:
		draw_map()
	else:
		draw_texture_rect(viewport.get_texture(), Rect2(34, 184, 750, 420), false)
		draw_rect(Rect2(34, 578, 750, 26), Color(0.03, 0.05, 0.07, 0.88))
		label_at("%s   /   %02d, %02d" % [world.BEARINGS[world.facing], world.position.x, world.position.y], 48, 597, 15, AMBER)
		label_at("[E] " + context_action() + "     [TAB] MAP", 430, 597, 14, INK)
	panel(Rect2(810, 115, 310, 217))
	label_at("THE TRAVELLER", 832, 145, 15, AMBER)
	label_at(world.character.name, 832, 180, 25)
	label_at("Health  %d / %d" % [world.character.hp, world.character.max_hp], 832, 215)
	label_at("STR %d     STA %d" % [world.character.strength, world.character.stamina], 832, 247, 17, DIM)
	label_at("Gold  %d" % world.character.gold, 832, 287, 22, AMBER)
	label_at("One character across every chapter", 832, 313, 14, DIM)
	panel(Rect2(810, 347, 310, 265))
	label_at("SATCHEL", 832, 379, 15, AMBER)
	for i in range(world.inventory.size()):
		label_at("+  " + str(world.inventory[i]), 832, 416 + i * 31, 19, TEAL if world.inventory[i] == "Brass token" else INK)
	label_at("OBJECTIVE", 832, 535, 14, AMBER)
	label_at("Return with the brass token.", 832, 563, 17)
	label_at("COMPLETE — welcome home." if world.flags.returned else "Below, then back to the tavern.", 832, 588, 15, TEAL if world.flags.returned else DIM)
	label_at(world.journal, 32, 642, 17, TEAL)
	if world.in_tavern():
		var song_t: float = music.song_time()
		label_at("TAVERN SONG  /  " + ("MUTED" if music.muted else "ORIGINAL SID-STYLE CUE"), 32, 678, 12, AMBER)
		label_at(music.LYRICS[int(song_t / 4.0) % 4], 32, 710, 23)
		draw_rect(Rect2(540, 692, 230, 3), Color("2d4146"))
		draw_rect(Rect2(540, 692, 230 * fmod(song_t, 4.0) / 4.0, 3), AMBER)
	else:
		label_at("The tavern song fades. Your journey continues.", 32, 698, 20, DIM)
	label_at("W/S Step   A/D Turn   Q/R Strafe   E Use   TAB Map   SPACE Wait   M Mute   F5/F9 Save/Load   C Chapters", 32, 748, 15, DIM)
	if show_chapters: draw_chapters()

func context_action() -> String:
	match world.tile(world.position):
		"T": return "MEAL / 2 GOLD"
		"D": return "DESCEND"
		"U": return "ASCEND"
		"R": return "EMPTY ALCOVE" if world.flags.relic_taken else "TAKE TOKEN"
	return "EXPLORE"

func draw_map() -> void:
	var origin := Vector2(123, 203)
	var cell := 42.0
	var rows: Array = world.MAPS[world.chapter]
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			var tile: String = rows[y][x]
			var r := Rect2(origin + Vector2(x, y) * cell, Vector2(cell - 2, cell - 2))
			var color := Color("253439") if tile == "#" else Color("13282b")
			if world.chapter == "dungeon" and tile != "#": color = Color("20232f")
			if tile == "T": color = Color("57432d")
			draw_rect(r, color)
			if tile == "#":
				draw_line(r.position + Vector2(4, 20), r.position + Vector2(35, 20), Color("34464a"))
			elif tile in ["D", "U", "R"]:
				if tile != "R" or not world.flags.relic_taken:
					label_at(tile, r.position.x + 12, r.position.y + 28, 22, AMBER)
	var center: Vector2 = origin + Vector2(world.position) * cell + Vector2(20, 20)
	draw_circle(center, 13, Color("0b171b"))
	draw_circle(center, 9, TEAL)
	draw_arc(center, 15, 0, TAU, 32, TEAL, 1.5)
	draw_line(center, center + Vector2(world.DIRECTIONS[world.facing]) * 21, AMBER, 3)
	label_at("YOU", 50, 575, 12, TEAL)
	label_at("AMBER: TAVERN     D: DESCEND     U: ASCEND     R: RELIC", 197, 599, 13, DIM)

func draw_chapters() -> void:
	panel(Rect2(245, 145, 660, 464))
	label_at("A WORLD WITH ROOM TO GROW", 275, 188, 24, AMBER)
	var y := 235
	for id in chapters:
		label_at(chapters[id].title, 280, y, 22)
		label_at("PROTOTYPE" if chapters[id].status == "playable" else "PLANNED / NOT IMPLEMENTED", 545, y, 16, TEAL if chapters[id].status == "playable" else DIM)
		y += 43
	label_at("Historical chapter names; this connected slice is a new design.  [C] Close", 275, 580, 14, DIM)
