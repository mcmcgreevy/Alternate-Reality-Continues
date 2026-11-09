extends SceneTree
const World = preload("res://scripts/original_world.gd")
var failures := 0

func check(ok: bool, description: String) -> void:
	if not ok:
		failures += 1
		push_error(description)

func write_save(data: Dictionary) -> void:
	var file := FileAccess.open("user://test_tavern_validation.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func _initialize() -> void:
	var w = World.new()
	w.character.hp = 10
	check(w.order_tavern("chili", w.menu_hour()), "Chili available on opening menu")
	check(w.wallet_copper() == 792 and w.character.gold == 7 and w.character.silver == 9 and w.character.copper == 2, "Change is exact across gold/silver/copper")
	check(w.character.hp == 10 and w.needs.hunger == 12, "Food relieves hunger without magical healing")
	check(w.order_tavern("pemmican", w.menu_hour()), "Pemmican order succeeds")
	check(w.provisions.food == 1 and w.needs.hunger == 8, "Pemmican both feeds and packs provisions")
	var balance: int = w.wallet_copper()
	w.order_tavern("water", w.menu_hour())
	check(w.wallet_copper() == balance and w.needs.thirst == 9, "Free water relieves thirst with no coin mutation")
	w.wait_minutes()
	check(w.provisions.food == 0 and w.needs.hunger == 0, "Sitting consumes a needed food packet")
	w.provisions.food = 1
	w.wait_minutes()
	check(w.provisions.food == 1, "Fed traveller keeps reserves")
	w.minutes = 18 * 60 + 59
	var quoted: int = w.menu_hour()
	w.wait_minutes(1)
	var before: int = w.minutes
	check(not w.order_tavern("chili", quoted), "Old hourly quotation is rejected")
	check(w.wallet_copper() == balance and w.minutes == before, "Stale order has no charge or time side effect")
	check(not w.order_tavern("food_packet", w.menu_hour()), "Unavailable stock cannot be purchased")
	check(w.order_tavern("water_flask", w.menu_hour()), "Odd-hour menu offers flask")
	check(w.provisions.water == 1, "Flask is stored instead of drunk on purchase")
	w.needs.thirst = 16
	w.wait_minutes()
	check(w.provisions.water == 0 and w.needs.thirst == 8, "Sitting consumes needed flask")
	w.character.gold = 0
	w.character.silver = 0
	w.character.copper = 3
	before = w.minutes
	var hunger: int = w.needs.hunger
	check(not w.order_tavern("soup", w.menu_hour()), "Insufficient funds rejected")
	check(w.wallet_copper() == 3 and w.minutes == before and w.needs.hunger == hunger, "Rejected purchase leaves funds, needs and clock alone")
	w.character.copper = 4
	check(w.order_tavern("soup", w.menu_hour()) and w.wallet_copper() == 0, "Exact payment succeeds")
	check(w.order_tavern("water", w.menu_hour()), "Broke traveller can still drink free water")
	w.needs.thirst = 0
	w.order_tavern("water", w.menu_hour())
	check(w.needs.thirst == 0, "Repeated drinks never make thirst negative")
	w.provisions = {"food": 2, "water": 3}
	w.character.copper = 7
	w.save_game("user://test_tavern_services.json")
	var loaded = World.new()
	check(loaded.load_game("user://test_tavern_services.json"), "Services save loads")
	check(loaded.needs == w.needs and loaded.provisions == w.provisions and loaded.wallet_copper() == 7, "Needs, provisions and coin change persist")
	loaded.position = Vector2i(49, 3)
	loaded.facing = 1
	loaded.interact()
	check(loaded.provisions == w.provisions and loaded.wallet_copper() == 7, "Crossing retains reserves and coins")
	before = loaded.minutes
	check(not loaded.order_tavern("water", loaded.menu_hour()) and loaded.minutes == before, "No tavern purchases in Dungeon")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("user://test_tavern_services.json"))
	data.version = 3
	data.character.erase("silver")
	data.character.erase("copper")
	data.character.gold = 6
	data.erase("needs")
	data.erase("provisions")
	write_save(data)
	check(loaded.load_game("user://test_tavern_validation.json"), "Version 3 migration supported")
	check(loaded.wallet_copper() == 600 and loaded.needs.hunger == 0 and loaded.provisions.food == 0, "Migration preserves old gold and initializes neutral needs")
	data.version = 4
	write_save(data)
	check(not loaded.load_game("user://test_tavern_validation.json"), "New saves cannot omit service state")
	check(loaded.wallet_copper() == 600, "Invalid load leaves current state intact")
	data = JSON.parse_string(FileAccess.get_file_as_string("user://test_tavern_services.json"))
	data.provisions.food = -1
	write_save(data)
	check(not loaded.load_game("user://test_tavern_validation.json"), "Negative provisions rejected")
	data.provisions.food = 1
	data.character.copper = 1.5
	write_save(data)
	check(not loaded.load_game("user://test_tavern_validation.json"), "Fractional coins rejected")
	w.minutes = 23 * 60 + 59
	w.wait_minutes(1)
	check(w.menu_hour() == 24 and w.tavern_menu().has("pemmican"), "Hourly menu survives midnight rollover")
	print("Tavern services, transactions, hourly menus and save migration: ", "PASS" if failures == 0 else "FAIL")
	quit(failures)
