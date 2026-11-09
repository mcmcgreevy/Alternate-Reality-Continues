extends RefCounted
## One authority for both chapters; views never own copies of the character.
const MAPS = {
	"city": ["#############", "#TTT#..#....#", "#TTT#.......#", "#TTT#..#....#", "###.####.####", "#...........#", "#.###.###.#.#", "#.....#D....#", "#############"],
	"dungeon": ["#############", "#U....#.....#", "#.##..#.###.#", "#.....#...R.#", "###.#####.#.#", "#...........#", "#.#####.###.#", "#...........#", "#############"]
}
var chapter: String = "city"
var position := Vector2i(2, 2)
const DIRECTIONS = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const BEARINGS = ["NORTH", "EAST", "SOUTH", "WEST"]
var facing: int = 0
var character: Dictionary = {"name": "The Stranger", "hp": 24, "max_hp": 24, "strength": 12, "stamina": 12, "gold": 8}
var inventory: Array = ["Worn sword", "Bread"]
var minutes: int = 18 * 60
var flags: Dictionary = {"visited_dungeon": false, "relic_taken": false, "returned": false}
var journal: String = "A brass token waits below. Bring it back to the tavern."

func tile(at: Vector2i) -> String:
	var rows: Array = MAPS[chapter]
	if at.y < 0 or at.y >= rows.size() or at.x < 0 or at.x >= rows[at.y].length():
		return "#"
	return rows[at.y][at.x]

func in_tavern() -> bool:
	return chapter == "city" and tile(position) == "T"

func turn(quarter_turns: int) -> void:
	facing = posmod(facing + quarter_turns, 4)

func step(backward: bool = false) -> bool:
	return move(DIRECTIONS[facing] * (-1 if backward else 1))

func strafe(right: bool) -> bool:
	return move(DIRECTIONS[posmod(facing + (1 if right else -1), 4)])

func move(direction: Vector2i) -> bool:
	if tile(position + direction) == "#":
		journal = "Stone blocks your way."
		return false
	position += direction
	minutes += 1
	if in_tavern() and flags.visited_dungeon and flags.relic_taken:
		flags.returned = true
		journal = "Round trip complete. The same traveller, one world, a story to tell."
	else:
		journal = hint()
	return true

func hint() -> String:
	match tile(position):
		"D": return "Stairs descend into the Dungeon. Press E to enter."
		"U": return "Daylight above. Press E to return to the City."
		"R": return "An old brass token. Press E to collect." if not flags.relic_taken else "The alcove is empty."
		"T": return "The Lantern & the Gate. Press E for a meal (2 gold, 15 minutes)."
	return "Find the brass token and return to the tavern. [Tab] Map" if chapter == "dungeon" else "Find the stone arch and stairs to the Dungeon. [Tab] Map"

func interact() -> void:
	match tile(position):
		"D":
			chapter = "dungeon"
			position = Vector2i(1, 1)
			facing = 1
			flags.visited_dungeon = true
			minutes += 5
			journal = "Beneath the City. Your possessions and time travel with you."
		"U":
			chapter = "city"
			position = Vector2i(7, 7)
			facing = 1
			minutes += 5
			journal = "Back in the City. Return to the Lantern & the Gate. [Tab] Map"
		"R":
			if not flags.relic_taken:
				inventory.append("Brass token")
				flags.relic_taken = true
				minutes += 1
				journal = "Brass token collected. Return to the stairs and press E."
		"T":
			if character.gold >= 2:
				character.gold -= 2
				character.hp = character.max_hp
				minutes += 15
				journal = "Warm bread and stew. Health restored; fifteen minutes pass."
			else:
				journal = "You cannot afford another meal. The music is free."
		_: journal = "Nothing to use here."

func clock_text() -> String:
	return "DAY %02d  /  %02d:%02d" % [minutes / 1440 + 1, (minutes / 60) % 24, minutes % 60]

func save_game(path: String = "user://journey.json") -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version": 2, "chapter": chapter, "position": [position.x, position.y], "facing": facing, "character": character, "inventory": inventory, "minutes": minutes, "flags": flags}))
	return OK

func load_game(path: String = "user://journey.json") -> bool:
	if not FileAccess.file_exists(path): return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary: return false
	if (data.get("version") != 1 and data.get("version") != 2) or not MAPS.has(data.get("chapter", "")): return false
	if not data.get("position") is Array or data.position.size() != 2: return false
	if not data.get("character") is Dictionary or not data.get("inventory") is Array or not data.get("flags") is Dictionary: return false
	for key in character:
		if not data.character.has(key) or typeof(data.character[key]) != typeof(character[key]) and not (data.character[key] is float and character[key] is int): return false
	for key in flags:
		if not data.flags.get(key) is bool: return false
	if not (data.get("minutes") is float or data.get("minutes") is int) or data.minutes < 0: return false
	var saved_facing = data.get("facing", 0)
	if not (saved_facing is float or saved_facing is int): return false
	if saved_facing != int(saved_facing) or saved_facing < 0 or saved_facing > 3: return false
	for coordinate in data.position:
		if not (coordinate is int or coordinate is float) or coordinate != int(coordinate): return false
	var p := Vector2i(int(data.position[0]), int(data.position[1]))
	# The first-person tavern encloses its east wall. Preserve old saves there.
	var migrated: bool = data.version == 1 and data.chapter == "city" and p.x == 4 and p.y in [1, 2, 3]
	if migrated: p.x = 3
	var rows: Array = MAPS[data.chapter]
	if p.y < 0 or p.y >= rows.size() or p.x < 0 or p.x >= rows[p.y].length() or rows[p.y][p.x] == "#": return false
	chapter = data.chapter
	position = p
	facing = int(saved_facing)
	character = data.character
	inventory = data.inventory
	minutes = int(data.minutes)
	flags = data.flags
	journal = "Journey restored. " + hint()
	if migrated: journal = "Old save restored inside the tavern's new east wall."
	return true
