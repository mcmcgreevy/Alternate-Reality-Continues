extends "res://scripts/first_person.gd"
## Original cell-edge renderer. Opposite faces are independent, not solid tiles.
var built_center := Vector2i(-999, -999)
var built_revision := -1
const RADIUS := 8

func sync(world) -> void:
	if built_chapter != world.chapter or built_revision != world.revision or absi(world.position.x - built_center.x) > 2 or absi(world.position.y - built_center.y) > 2:
		build(world)
	camera.position = Vector3(world.position.x * CELL, EYE, world.position.y * CELL)
	camera.rotation.y = -world.facing * PI / 2.0

func build(world) -> void:
	if is_instance_valid(geometry):
		remove_child(geometry)
		geometry.queue_free()
	geometry = Node3D.new()
	add_child(geometry)
	lamps.clear()
	relic = null
	built_center = world.position
	built_revision = world.revision
	built_chapter = world.chapter
	var dungeon: bool = world.chapter == "dungeon"
	environment.background_color = Color("151922") if dungeon else Color("596474")
	environment.fog_light_color = Color("151922") if dungeon else Color("596474")
	environment.fog_density = 0.055 if dungeon else 0.028
	environment.ambient_light_energy = 0.45 if dungeon else 0.8
	for y in range(world.position.y - RADIUS, world.position.y + RADIUS + 1):
		for x in range(world.position.x - RADIUS, world.position.x + RADIUS + 1):
			var at := Vector2i(x, y)
			if not world.has_cell(at): continue
			var p := Vector3(x * CELL, 0, y * CELL)
			var tavern: bool = world.chapter == "city" and at == Vector2i(20, 1)
			block(p + Vector3(0, -0.1, 0), Vector3(CELL, 0.2, CELL), "floor" if tavern else "paving")
			if dungeon or tavern:
				block(p + Vector3(0, 3.25, 0), Vector3(CELL, 0.1, CELL), "ceiling" if tavern else "stone")
			for d in range(4):
				boundary(p, d, world.edge(at, d), world.door_open(at, d), dungeon)
			if dungeon and x % 4 == 0 and y % 3 == 0 and world.edge(at, 0) == 13 and lamps.size() < 8:
				torch(p + Vector3(0.8, 2, -1.25))
	if dungeon:
		# The original arrival has a solid east face, not ARX's added return door.
		sign_text("CITY ENTRANCE", Vector3(49 * CELL + 1.42, 2.3, 9), -PI / 2, 22)
	else:
		if absi(world.position.x - 20) <= RADIUS and absi(world.position.y - 1) <= RADIUS:
			tavern_counter()
		if absi(world.position.x - 49) <= RADIUS and absi(world.position.y - 3) <= RADIUS:
			sign_text("THE DUNGEON", Vector3(49 * CELL + 1.42, 2.7, 9), -PI / 2, 25)

func boundary(p: Vector3, direction: int, code: int, opened: bool, dungeon: bool) -> void:
	if code == 0: return
	var offset: Vector3 = [Vector3(0, 0, -1.5), Vector3(1.5, 0, 0), Vector3(0, 0, 1.5), Vector3(-1.5, 0, 0)][direction]
	var yaw: float = [0.0, -PI / 2.0, PI, PI / 2.0][direction]
	var frame := Node3D.new()
	frame.position = p + offset
	frame.rotation.y = yaw
	geometry.add_child(frame)
	var arch: bool = code in [1, 2, 7] or opened
	if not arch:
		var wall := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(3.0, 3.2)
		wall.mesh = quad
		wall.position = Vector3(0, 1.6, 0.002)
		var mat := "stone" if dungeon else "plaster"
		if code in [3, 4]: mat = "wood"
		if code in [8, 9, 10, 11, 12]: mat = "iron"
		wall.material_override = materials[mat]
		frame.add_child(wall)
	# Pillars and lintels leave the same single-cell opening as the source.
	if arch or code in [3, 4, 8, 9, 10, 11, 12]:
		for side in [-1.0, 1.0]:
			block(Vector3(side * 1.4, 1.6, 0.03), Vector3(0.18, 3.2, 0.12), "stone" if dungeon else "beam", frame)
		block(Vector3(0, 2.9, 0.03), Vector3(3, 0.3, 0.12), "stone" if dungeon else "beam", frame)
	elif not dungeon:
		block(Vector3(0, 2.75, 0.02), Vector3(3.0, 0.14, 0.05), "beam", frame)
		block(Vector3(0, 0.25, 0.02), Vector3(3.0, 0.5, 0.05), "stone", frame)

func tavern_counter() -> void:
	# Modern staging inside a service cell, not a claimed original interior map.
	var holder := Node3D.new()
	geometry.add_child(holder)
	holder.position = Vector3(60, 0, 3)
	holder.rotation.y = PI
	block(Vector3(0, 0.45, -1.03), Vector3(2.5, 0.9, 0.45), "wood", holder)
	block(Vector3(0, 0.96, -1.03), Vector3(2.7, 0.12, 0.55), "floor", holder)
	block(Vector3(0, 1.37, -1.20), Vector3(0.45, 0.6, 0.2), "coat", holder)
	block(Vector3(0, 1.82, -1.20), Vector3(0.3, 0.32, 0.25), "skin", holder)
	for x in [-0.08, 0.08]: block(Vector3(x, 1.85, -1.06), Vector3(0.04, 0.04, 0.02), "dark", holder)
	for x in [-0.8, 0.7]: block(Vector3(x, 1.13, -0.95), Vector3(0.16, 0.22, 0.16), "gold", holder)
	sign_text("THE TAVERN", Vector3(60, 2.55, 4.4), PI, 22)
	torch(Vector3(59.0, 2.15, 4.1))
