extends "res://scripts/world.gd"
## Original-map exploration slice. Original event/economy simulation is deferred.
const SAVE_PATH := "user://original_route.json"
var maps: Dictionary = {}
var route: Dictionary
var doors: Dictionary = {}
var revision := 0
var tavern: Dictionary
var needs := {"hunger": 18, "thirst": 16}
var provisions := {"food": 0, "water": 0}
var dungeon_links: Dictionary

func _init() -> void:
	for id in ["city", "dungeon"]:
		maps[id] = JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/" + id + ".json"))
	route = JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/route.json"))
	tavern = JSON.parse_string(FileAccess.get_file_as_string("res://data/tavern.json"))
	dungeon_links = JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/dungeon_links.json")).links
	character.silver = 0
	character.copper = 0
	position = Vector2i(20, 1)
	facing = 2
	flags = {"visited_dungeon": false, "returned": false}
	journal = "The Tavern. Order food or drink, review your excursion, or leave for the City."

func cell(at: Vector2i, map_id: String = "") -> Dictionary:
	if map_id.is_empty(): map_id = chapter
	return maps[map_id].cells.get("%d,%d" % [at.x, at.y], {})

func has_cell(at: Vector2i) -> bool:
	return not cell(at).is_empty()

func edge(at: Vector2i, direction: int) -> int:
	return int(cell(at).edges[direction]) if has_cell(at) else -1

func door_key(at: Vector2i, direction: int) -> String:
	return "%s:%d,%d:%d" % [chapter, at.x, at.y, direction]

func door_open(at: Vector2i, direction: int) -> bool:
	return doors.get(door_key(at, direction), false)

func in_tavern() -> bool:
	return chapter == "city" and position == Vector2i(20, 1)

func tile(at: Vector2i) -> String:
	if not has_cell(at): return "#"
	if chapter == "city" and at == Vector2i(20, 1): return "T"
	if at == Vector2i(49, 3): return "D" if chapter == "city" else "U"
	return "."

func can_route(at: Vector2i, direction: int) -> bool:
	return has_cell(at + DIRECTIONS[direction]) and edge(at, direction) in [0, 1, 2, 3, 4, 5, 6, 7]

func move(direction: Vector2i) -> bool:
	var d := DIRECTIONS.find(direction)
	if d == -1: return false
	var code := edge(position, d)
	if not has_cell(position + direction):
		journal = "This area is outside the current reconstruction."
		return false
	if code in [3, 4, 5, 6] and not door_open(position, d):
		journal = "A boundary blocks your path. Face it and press E to examine."
		return false
	if code not in [0, 1, 2, 3, 4, 5, 6, 7]:
		journal = "The door is barred. Its original mechanism is not implemented." if code in [8, 9, 10, 11, 12] else "Stone blocks your way."
		return false
	position += direction
	advance_time(1)
	var transitioned := false
	if chapter == "dungeon":
		var link: Dictionary = dungeon_links.get("%d,%d" % [position.x, position.y], {})
		if not link.is_empty() and link.enabled:
			position = Vector2i(link.target[0], link.target[1])
			var arrival_facing := int(link.facing)
			if arrival_facing < 128: facing = arrival_facing
			elif arrival_facing != 255: facing = randi_range(0, 3)
			revision += 1
			transitioned = true
	if in_tavern(): facing = 2
	if in_tavern() and flags.visited_dungeon:
		flags.returned = true
		journal = "Round trip complete. You have returned to The Tavern."
	else: journal = "The passage leads onward. " + dungeon_region() if transitioned else hint()
	return true

func dungeon_region() -> String:
	return "Level 1 / " + ["northwest", "northeast", "southwest", "southeast"][int(position.x / 32) + 2 * int(position.y / 32)]

func step_destination(entry: Vector2i) -> Vector2i:
	if chapter == "dungeon":
		var link: Dictionary = dungeon_links.get("%d,%d" % [entry.x, entry.y], {})
		if not link.is_empty() and link.enabled: return Vector2i(link.target[0], link.target[1])
	return entry

func interact() -> void:
	if position == Vector2i(49, 3) and (chapter == "dungeon" or facing == 1):
		chapter = "dungeon" if chapter == "city" else "city"
		facing = 3 if chapter == "dungeon" else 2
		advance_time(5)
		flags.visited_dungeon = true
		revision += 1
		journal = "The Dungeon entrance. Your possessions and clock travel with you." if chapter == "dungeon" else "Back in the City. Follow the return guide to The Tavern."
		return
	var code := edge(position, facing)
	if code in [3, 4, 5, 6]:
		doors[door_key(position, facing)] = true
		# Store only the approached face: one-way boundaries must stay one-way.
		revision += 1
		journal = "A concealed passage opens." if code in [5, 6] else "The door opens."
		return
	if in_tavern():
		meal()
	else:
		journal = "No mechanism here is ready to use."

func meal() -> void:
	# Compatibility entry point: no hidden purchase without a menu selection.
	if in_tavern(): journal = "Choose an item from the food and drink menu."

func advance_time(amount: int) -> void:
	# Slow, nonlethal placeholder needs; original rates remain unverified.
	needs.hunger = mini(100, int(needs.hunger) + int((minutes + amount) / 60) - int(minutes / 60))
	needs.thirst = mini(100, int(needs.thirst) + int((minutes + amount) / 30) - int(minutes / 30))
	minutes += amount

func wallet_copper() -> int:
	return int(character.gold) * 100 + int(character.silver) * 10 + int(character.copper)

func wallet_text() -> String:
	return "%d gold  %d silver  %d copper" % [character.gold, character.silver, character.copper]

func menu_hour() -> int:
	return int(minutes / 60)

func tavern_menu() -> Array:
	return tavern.menus[menu_hour() % tavern.menus.size()]

func order_tavern(id: String, quoted_hour: int) -> bool:
	if not in_tavern(): return false
	if quoted_hour != menu_hour() or id not in tavern_menu():
		journal = "The menu has changed. Please choose again."
		return false
	var item: Dictionary = tavern.items[id]
	var cost := int(item.copper)
	var balance := wallet_copper()
	if balance < cost:
		journal = "You need %d copper for %s; you have %d." % [cost, item.name, balance]
		return false
	if cost > 0:
		balance -= cost
		character.gold = int(balance / 100)
		character.silver = int((balance % 100) / 10)
		character.copper = balance % 10
	advance_time(int(item.minutes))
	needs.hunger = maxi(0, int(needs.hunger) - int(item.hunger))
	needs.thirst = maxi(0, int(needs.thirst) - int(item.thirst))
	provisions.food += int(item.food)
	provisions.water += int(item.water)
	journal = "%s served. %s" % [item.name, "No charge." if cost == 0 else "%d copper paid." % cost]
	if int(item.food) > 0: journal += " One Food Packet packed."
	if int(item.water) > 0: journal += " One Water Flask packed."
	return true

func wait_minutes(amount: int = 5) -> void:
	advance_time(amount)
	journal = "You wait %d minutes." % amount
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
	if not in_tavern(): return
	# A service screen exits through the existing mapped boundary, not a new shortcut.
	facing = 0
	if edge(position, facing) in [3, 4, 5, 6]: interact()
	step()

func hint() -> String:
	if in_tavern(): return "The Tavern. 1: order. 2: excursion. 3: leave. 4: sit a while."
	if position == Vector2i(49, 3): return "Face east and press E to descend." if chapter == "city" else "E: return to the City. The original arrival faces west."
	return "Explore level one; the guide leads back to the City entrance." if chapter == "dungeon" else "Follow the guide, or use Tab to inspect the map."

func coordinates() -> String:
	if chapter == "city": return "%02dN  %02dE" % [64 - position.y, position.x + 1]
	return "%02dN  %02dE" % [63 - position.y, position.x]

func action_text() -> String:
	if position == Vector2i(49, 3) and (chapter == "dungeon" or facing == 1): return "RETURN TO CITY" if chapter == "dungeon" else "ENTER DUNGEON"
	var code := edge(position, facing)
	if code in [3, 4]: return "OPEN DOOR" if not door_open(position, facing) else "DOOR OPEN"
	if code in [5, 6]: return "EXAMINE WALL" if not door_open(position, facing) else "PASSAGE OPEN"
	return "FOOD AND DRINK" if in_tavern() else "EXAMINE"

func find_route(target: Vector2i) -> Array[Vector2i]:
	var queue: Array[Vector2i] = [position]
	var parents: Dictionary = {position: position}
	var cursor := 0
	while cursor < queue.size():
		var p := queue[cursor]
		cursor += 1
		if p == target: break
		for d in range(4):
			var entry: Vector2i = p + DIRECTIONS[d]
			var n := step_destination(entry)
			if can_route(p, d) and not parents.has(n):
				parents[n] = [p, entry]
				queue.append(n)
	var path: Array[Vector2i] = []
	if not parents.has(target): return path
	var p := target
	while p != position:
		path.push_front(parents[p][1])
		p = parents[p][0]
	return path

func destination() -> Vector2i:
	return Vector2i(20, 1) if chapter == "city" and flags.visited_dungeon else Vector2i(49, 3)

func save_game(path: String = SAVE_PATH) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version": 4, "map_set": "original-route-1", "chapter": chapter,
		"position": [position.x, position.y], "facing": facing, "character": character,
		"inventory": inventory, "minutes": minutes, "flags": flags, "doors": doors,
		"needs": needs, "provisions": provisions}))
	return OK

func load_game(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path): return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary or data.get("map_set") != "original-route-1": return false
	if data.get("version") != 3 and data.get("version") != 4: return false
	if not maps.has(data.get("chapter", "")): return false
	if not data.get("position") is Array or data.position.size() != 2: return false
	for n in data.position:
		if not (n is float or n is int) or n != int(n): return false
	var p := Vector2i(data.position[0], data.position[1])
	if cell(p, data.chapter).is_empty(): return false
	for key in ["character", "flags", "doors"]:
		if not data.get(key) is Dictionary: return false
	if data.version == 3:
		data.character["silver"] = 0
		data.character["copper"] = 0
		data["needs"] = {"hunger": 0, "thirst": 0}
		data["provisions"] = {"food": 0, "water": 0}
	for group in ["needs", "provisions"]:
		if not data.get(group) is Dictionary: return false
		for key in (needs if group == "needs" else provisions):
			var value = data[group].get(key)
			if not (value is int or value is float) or not is_finite(float(value)) or value != int(value) or value < 0: return false
			if group == "needs" and value > 100: return false
	for key in character:
		if not data.character.has(key): return false
		if key == "name":
			if not data.character[key] is String: return false
		elif not (data.character[key] is float or data.character[key] is int): return false
		elif not is_finite(float(data.character[key])) or data.character[key] != int(data.character[key]) or data.character[key] < 0: return false
	for key in flags:
		if not data.flags.get(key) is bool: return false
	for key in data.doors:
		if not data.doors[key] is bool: return false
	if not data.get("inventory") is Array: return false
	for item in data.inventory:
		if not item is String: return false
	for key in ["minutes", "facing"]:
		if not (data.get(key) is int or data.get(key) is float) or data[key] != int(data[key]): return false
	if data.minutes < 0 or data.facing < 0 or data.facing > 3: return false
	chapter = data.chapter
	position = p
	facing = int(data.facing)
	character = data.character
	for key in character:
		if key != "name": character[key] = int(character[key])
	inventory = data.inventory
	minutes = int(data.minutes)
	flags = data.flags
	doors = data.doors
	needs = data.needs
	provisions = data.provisions
	for key in needs: needs[key] = int(needs[key])
	for key in provisions: provisions[key] = int(provisions[key])
	revision += 1
	journal = "Journey restored. " + hint()
	return true
