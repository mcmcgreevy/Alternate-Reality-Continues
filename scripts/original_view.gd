extends "res://scripts/first_person.gd"
## Original cell-edge renderer. Opposite faces are independent, not solid tiles.
var built_center := Vector2i(-999, -999)
var built_revision := -1
const RADIUS := 8
const Surfaces = preload("res://scripts/atmosphere_materials.gd")
var sky_material := ShaderMaterial.new()
var daylight := 1.0
var outdoors := false
var last_sky_minute := -1
var last_outdoors := false
var sun := DirectionalLight3D.new()
var ceiling_cells: Array[Vector2i] = []

func _ready() -> void:
	super._ready()
	sky_material.shader = load("res://scripts/city_sky.gdshader")
	var city_sky := Sky.new()
	city_sky.sky_material = sky_material
	city_sky.radiance_size = Sky.RADIANCE_SIZE_128
	environment.sky = city_sky
	sun.shadow_enabled = true
	add_child(sun)

func sync_environment(world) -> void:
	outdoors = not world.is_inside(world.position)
	var minute: int = world.minutes % 1440
	if last_sky_minute == minute and last_outdoors == outdoors: return
	last_sky_minute = minute
	last_outdoors = outdoors
	var elevation := sin((float(minute) / 1440.0 - 0.25) * TAU)
	daylight = smoothstep(-0.18, 0.25, elevation)
	var twilight := (1.0 - smoothstep(0.0, 0.35, absf(elevation)))
	sky_material.set_shader_parameter("clock_minutes", float(minute))
	sky_material.set_shader_parameter("daylight", daylight)
	sky_material.set_shader_parameter("twilight", twilight)
	environment.background_mode = Environment.BG_SKY if outdoors else Environment.BG_COLOR
	environment.ambient_light_color = Color("8298bd").lerp(Color("d0d9e0"), daylight) if outdoors else Color("92a9bb")
	environment.ambient_light_energy = lerpf(0.19, 0.72, daylight) if outdoors else 0.26
	environment.fog_light_color = Color("18253b").lerp(Color("a1b5c5"), daylight) if outdoors else Color("151922")
	environment.fog_density = 0.008 if outdoors else 0.035
	sun.visible = outdoors
	sun.light_energy = daylight * 0.65
	sun.light_color = Color("ffd1a0").lerp(Color("fff2dc"), clampf(elevation,0.0,1.0))
	sun.rotation = Vector3(-maxf(0.1, elevation) * PI / 2.0, -PI / 3.0, 0)
	for child in camera.get_children():
		if child is OmniLight3D: child.light_energy = 0.10 if outdoors else 0.35

func make_materials() -> void:
	super.make_materials()
	var palette := {"stone": "8c8e8a", "wood": "81634b", "paving": "777f80", "plaster": "b2a48d", "floor": "886346", "ceiling": "514a40"}
	for key in palette:
		materials[key] = Surfaces.build(key, Color(palette[key]))
	materials.iron.metallic = 0.65
	materials.iron.roughness = 0.48

func torch(at: Vector3) -> void:
	var handle := block(at - Vector3(0, 0.35, 0), Vector3(0.10, 0.65, 0.10), "wood")
	var bracket := block(at - Vector3(0, 0.08, 0), Vector3(0.22, 0.10, 0.22), "iron")
	handle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bracket.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var fire := MeshInstance3D.new()
	var flame := SphereMesh.new()
	flame.radius = 0.075
	flame.height = 0.34
	fire.mesh = flame
	fire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fire.material_override = materials.flame
	fire.position = at + Vector3(0, 0.12, 0)
	geometry.add_child(fire)
	var light := OmniLight3D.new()
	light.position = at + Vector3(0, 0.25, 0.15)
	light.light_color = Color("ffc18a")
	light.omni_range = 8.0
	light.shadow_enabled = true
	geometry.add_child(light)
	lamps.append(light)

func sync(world) -> void:
	if built_chapter != world.chapter or built_revision != world.revision or absi(world.position.x - built_center.x) > 2 or absi(world.position.y - built_center.y) > 2:
		build(world)
	camera.position = Vector3(world.position.x * CELL, EYE, world.position.y * CELL)
	camera.rotation.y = -world.facing * PI / 2.0
	sync_environment(world)
	camera.rotation.x = deg_to_rad(12.0) if outdoors else 0.0
	camera.fov = 74 if outdoors else 66

func build(world) -> void:
	if is_instance_valid(geometry):
		remove_child(geometry)
		geometry.queue_free()
	geometry = Node3D.new()
	add_child(geometry)
	lamps.clear()
	ceiling_cells.clear()
	relic = null
	built_center = world.position
	built_revision = world.revision
	built_chapter = world.chapter
	var dungeon: bool = world.chapter == "dungeon"
	environment.background_color = Color("151922")
	last_sky_minute = -1
	for y in range(world.position.y - RADIUS, world.position.y + RADIUS + 1):
		for x in range(world.position.x - RADIUS, world.position.x + RADIUS + 1):
			var at := Vector2i(x, y)
			if not world.has_cell(at): continue
			var p := Vector3(x * CELL, 0, y * CELL)
			var tavern: bool = world.chapter == "city" and at == Vector2i(20, 1)
			block(p + Vector3(0, -0.1, 0), Vector3(CELL, 0.2, CELL), "floor" if tavern else "paving")
			if world.is_inside(at):
				ceiling_cells.append(at)
				block(p + Vector3(0, 3.25, 0), Vector3(CELL, 0.1, CELL), "ceiling" if tavern else "stone")
			for d in range(4):
				boundary(p, d, world.edge(at, d), world.door_open(at, d), dungeon, 3.2 if world.is_inside(at) else 2.6)
			if dungeon and x % 4 == 0 and y % 3 == 0 and world.edge(at, 0) == 13 and at.distance_to(world.position) <= 4 and lamps.size() < 6:
				torch(p + Vector3(0.8, 2, -1.25))
	if dungeon:
		# The original arrival has a solid east face, not ARX's added return door.
		sign_text("CITY ENTRANCE", Vector3(49 * CELL + 1.42, 2.3, 9), -PI / 2, 22)
	else:
		if absi(world.position.x - 20) <= RADIUS and absi(world.position.y - 1) <= RADIUS:
			tavern_counter()
		if absi(world.position.x - 49) <= RADIUS and absi(world.position.y - 3) <= RADIUS:
			sign_text("THE DUNGEON", Vector3(49 * CELL + 1.42, 2.7, 9), -PI / 2, 25)

func boundary(p: Vector3, direction: int, code: int, opened: bool, dungeon: bool, wall_height: float = 3.2) -> void:
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
		quad.size = Vector2(3.0, wall_height)
		wall.mesh = quad
		wall.position = Vector3(0, wall_height / 2.0, 0.002)
		var mat := "stone" if dungeon else "plaster"
		if code in [3, 4]: mat = "wood"
		if code in [8, 9, 10, 11, 12]: mat = "iron"
		wall.material_override = materials[mat]
		frame.add_child(wall)
		if dungeon and code in [3, 4]:
			for height in [0.55, 2.2]:
				block(Vector3(0, height, 0.025), Vector3(2.65, 0.10, 0.05), "iron", frame)
			block(Vector3(0.92, 1.4, 0.08), Vector3(0.12, 0.24, 0.12), "iron", frame)
		elif dungeon and code in [5, 6, 13, 14, 15]:
			block(Vector3(0, 0.13, 0.025), Vector3(3, 0.26, 0.05), "stone", frame)
			block(Vector3(0, 3.05, 0.025), Vector3(3, 0.22, 0.05), "stone", frame)
	# Pillars and lintels leave the same single-cell opening as the source.
	if arch or code in [3, 4, 8, 9, 10, 11, 12]:
		for side in [-1.0, 1.0]:
			block(Vector3(side * 1.4, wall_height / 2.0, 0.03), Vector3(0.18, wall_height, 0.12), "stone" if dungeon else "beam", frame)
		block(Vector3(0, wall_height - 0.3, 0.03), Vector3(3, 0.3, 0.12), "stone" if dungeon else "beam", frame)
	elif not dungeon:
		block(Vector3(0, wall_height - 0.45, 0.02), Vector3(3.0, 0.14, 0.05), "beam", frame)
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
