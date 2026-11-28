extends SceneTree
## Explicitly selected checkpoints only, in the isolated S108 player directory.
const World = preload("res://scripts/original_world.gd")
const Geometry = preload("res://scripts/city_geometry.gd")
const CHECKPOINTS := [[10,30,2], [10,31,0], [11,31,1], [12,31,3],
	[10,32,1], [11,32,3], [26,34,2], [26,35,0]]

func _initialize() -> void:
	var user_directory := OS.get_user_data_dir().replace("\\", "/")
	if not "/tools/appdata-s108-playtest/" in user_directory:
		push_error("Checkpoint preparation requires the isolated Play-S108.cmd save folder.")
		quit(1)
		return
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1 or not arguments[0].is_valid_int():
		quit(1)
		return
	var checkpoint := int(arguments[0])
	if checkpoint < 1 or checkpoint > CHECKPOINTS.size():
		quit(1)
		return
	var location: Array = CHECKPOINTS[checkpoint - 1]
	var world = World.new()
	world.position = Vector2i(location[0], location[1])
	world.facing = location[2]
	world.flags.visited_dungeon = true # Guide these isolated fixtures back to the tavern.
	var fixture: Dictionary = world.save_snapshot()
	fixture.version = 8
	fixture.erase("city_geometry_revision")
	# Intentionally inject stale keys to exercise legacy migration through F9.
	for key in Geometry.RETIRED_DOOR_KEYS + Geometry.ADDED_DOOR_KEYS:
		fixture.doors[key] = true
	fixture.doors["dungeon:26,34:2"] = true
	var error: Error = world.save_store.write(World.SAVE_PATH, JSON.stringify(fixture, "", true, true))
	if error != OK:
		push_error("Could not prepare isolated checkpoint: " + str(error))
		quit(1)
		return
	print("Checkpoint %d ready. Press F9 in game: %s, facing %s." % [checkpoint, world.coordinates(), ["north", "east", "south", "west"][world.facing]])
	quit(0)
