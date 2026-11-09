extends Node3D
## Geometry is a view of World.MAPS; gameplay and collision stay in World.
const CELL := 3.0
const EYE := 1.5
var camera := Camera3D.new()
var geometry: Node3D
var materials: Dictionary = {}
var built_chapter := ""
var relic: Node3D
var lamps: Array[OmniLight3D] = []
var elapsed := 0.0
var environment := Environment.new()

func _ready() -> void:
	make_materials()
	var sky := WorldEnvironment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("c3b7a5")
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.fog_enabled = true
	environment.fog_density = 0.025
	sky.environment = environment
	add_child(sky)
	camera.fov = 66
	camera.near = 0.05
	camera.far = 65
	add_child(camera)
	camera.current = true
	var fill := OmniLight3D.new()
	fill.light_color = Color("ddbb88")
	fill.light_energy = 0.35
	fill.omni_range = 8
	camera.add_child(fill)

func _process(delta: float) -> void:
	elapsed += delta
	for i in range(lamps.size()):
		lamps[i].light_energy = 1.4 + sin(elapsed * 7.0 + i * 2.3) * 0.12
	if is_instance_valid(relic): relic.rotation.y = elapsed * 0.6

func sync(world) -> void:
	if built_chapter != world.chapter:
		build(world)
	# Deliberately instant cell movement and quarter-turns, like a grid crawler.
	camera.position = Vector3(world.position.x * CELL, EYE, world.position.y * CELL)
	camera.rotation.y = -world.facing * PI / 2.0
	if is_instance_valid(relic): relic.visible = not world.flags.relic_taken

func material(color: String, glow: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color)
	m.roughness = 1.0
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	if glow:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

func make_materials() -> void:
	var colors := {"wood": "765039", "beam": "352820", "stone": "69717b", "plaster": "b4a180", "paving": "777169", "floor": "97714b", "ceiling": "554431", "iron": "292d38", "gold": "edbe66", "flame": "ffd891", "coat": "577b81", "skin": "c7a077", "dark": "141b26", "red": "814a45"}
	for key in colors:
		materials[key] = material(colors[key], key == "flame")
	for key in ["stone", "plaster", "paving", "wood", "floor", "ceiling"]:
		var img := Image.create(32, 32, false, Image.FORMAT_RGB8)
		var base: Color = materials[key].albedo_color
		for y in range(32):
			for x in range(32):
				var noise := float((x * 17 + y * 31 + x * y * 7) % 11) / 80.0
				var mortar: bool = y % 8 == 0 or (x + (8 if (y / 8) % 2 else 0)) % 16 == 0
				if key in ["wood", "floor", "ceiling"]: mortar = x % 8 == 0 or (y + x * 3) % 31 == 0
				if key == "plaster": mortar = x < 2 or y < 2
				img.set_pixel(x, y, base.darkened(0.45 if mortar else noise))
		materials[key].albedo_color = Color.WHITE
		materials[key].albedo_texture = ImageTexture.create_from_image(img)

func block(at: Vector3, size: Vector3, mat: String, parent: Node3D = null) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = materials[mat]
	mesh.position = at
	(parent if parent != null else geometry).add_child(mesh)
	return mesh

func sign_text(text: String, at: Vector3, yaw: float = 0.0, text_size: int = 40) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.rotation.y = yaw
	label.font_size = text_size
	label.pixel_size = 0.009
	label.modulate = Color("ffe1a0")
	label.outline_modulate = Color("2c211d")
	label.outline_size = 5
	label.no_depth_test = false
	label.double_sided = false
	geometry.add_child(label)

func torch(at: Vector3) -> void:
	block(at - Vector3(0, 0.4, 0), Vector3(0.12, 0.65, 0.12), "wood")
	block(at, Vector3(0.22, 0.35, 0.22), "gold")
	block(at + Vector3(0, 0.12, 0), Vector3(0.12, 0.30, 0.12), "flame")
	var light := OmniLight3D.new()
	light.position = at + Vector3(0, 0.2, 0)
	light.light_color = Color("ffbf71")
	light.omni_range = 7.0
	light.shadow_enabled = false
	geometry.add_child(light)
	lamps.append(light)

func build(world) -> void:
	if is_instance_valid(geometry):
		remove_child(geometry)
		geometry.queue_free()
	lamps.clear()
	relic = null
	geometry = Node3D.new()
	add_child(geometry)
	built_chapter = world.chapter
	var dungeon: bool = world.chapter == "dungeon"
	environment.background_color = Color("171b2b") if dungeon else Color("4c586b")
	environment.fog_light_color = Color("171b2b") if dungeon else Color("606075")
	environment.fog_density = 0.045 if dungeon else 0.018
	environment.ambient_light_energy = 0.42 if dungeon else 0.8
	var rows: Array = world.MAPS[world.chapter]
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			var t: String = rows[y][x]
			var p := Vector3(x * CELL, 0, y * CELL)
			if t == "#":
				block(p + Vector3(0, 1.6, 0), Vector3(CELL, 3.2, CELL), "stone" if dungeon else "plaster")
				if not dungeon:
					block(p + Vector3(0, 2.65, 0), Vector3(3.04, 0.18, 3.04), "beam")
					block(p + Vector3(0, 0.3, 0), Vector3(3.04, 0.6, 3.04), "stone")
					block(p + Vector3(-1.43, 1.6, -1.43), Vector3(0.2, 3.2, 0.2), "beam")
				continue
			if t not in ["D", "U"]:
				block(p + Vector3(0, -0.1, 0), Vector3(CELL, 0.2, CELL), "floor" if t == "T" else "paving")
			if dungeon or t == "T":
				block(p + Vector3(0, 3.25, 0), Vector3(CELL, 0.1, CELL), "stone" if dungeon else "ceiling")
			if dungeon and x % 3 == 1 and y % 2 == 1 and world.tile(Vector2i(x, y - 1)) == "#":
				torch(p + Vector3(0.9, 2.0, -1.25))
			if t in ["D", "U"]: stairs(p, t == "U")
			if t == "R": treasure(p)
	if not dungeon:
		build_tavern()
		# City windows inset against building faces, with timber mullions.
		for x in [2, 5, 6, 10]:
			var p := Vector3(x * CELL, 1.8, 13.52)
			block(p, Vector3(0.9, 1.0, 0.08), "dark")
			block(p, Vector3(0.08, 1.05, 0.12), "beam")
			block(p, Vector3(0.95, 0.08, 0.12), "beam")
		torch(Vector3(21.9, 2.0, 19.8))
		sign_text("DUNGEON", Vector3(21, 2.5, 22.40))

func stairs(p: Vector3, up: bool) -> void:
	# Walkable portal tile: steps are visual, interaction performs chapter travel.
	var parent := geometry
	var portal := Node3D.new()
	parent.add_child(portal)
	portal.position = p
	portal.rotation.y = PI / 2.0
	geometry = portal
	p = Vector3.ZERO
	block(Vector3(0, -1.35, 0), Vector3(3.0, 0.2, 3.0), "dark")
	for i in range(7):
		var height := float(i) * 0.17
		var step_y := -0.95 + height if up else -0.08 - height
		block(p + Vector3(0, step_y, 1.3 - i * 0.4), Vector3(2.5, 0.18, 0.42), "stone")
	for side in [-1.0, 1.0]:
		block(p + Vector3(side * 1.34, 1.3, 0), Vector3(0.22, 2.6, 0.3), "stone")
	block(p + Vector3(0, 2.65, 0), Vector3(2.9, 0.3, 0.4), "stone")
	var title := "TO THE CITY" if up else "THE DUNGEON"
	sign_text(title, p + Vector3(0, 2.65, 0.24), 0, 27)
	sign_text(title, p + Vector3(0, 2.65, -0.24), PI, 27)
	torch(p + Vector3(-1.1, 1.8, 0.2))
	geometry = parent

func treasure(p: Vector3) -> void:
	# Offset pedestal towards the wall so the cell center stays unobstructed.
	block(p + Vector3(0, 0.35, -1.0), Vector3(0.85, 0.7, 0.7), "stone")
	relic = Node3D.new()
	relic.position = p + Vector3(0, 1.05, -1.0)
	geometry.add_child(relic)
	var token := block(Vector3.ZERO, Vector3(0.45, 0.45, 0.09), "gold", relic)
	token.rotation.z = PI / 4
	sign_text("BRASS TOKEN", p + Vector3(0, 1.9, -1.3), 0, 24)

func person(at: Vector3, coat: String) -> void:
	block(at + Vector3(0, 0.7, 0), Vector3(0.5, 0.85, 0.3), coat)
	block(at + Vector3(0, 1.3, 0), Vector3(0.36, 0.4, 0.33), "skin")
	block(at + Vector3(0, 1.51, -0.02), Vector3(0.39, 0.14, 0.37), "beam")
	for x in [-0.1, 0.1]:
		block(at + Vector3(x, 1.35, 0.171), Vector3(0.055, 0.05, 0.025), "dark")
		block(at + Vector3(x, 0.15, 0), Vector3(0.16, 0.3, 0.25), "beam")
	for x in [-0.32, 0.32]: block(at + Vector3(x, 0.9, 0), Vector3(0.15, 0.6, 0.2), coat)

func build_tavern() -> void:
	# Counter hugs the north wall, leaving all grid cell centers clear.
	block(Vector3(6, 0.55, 2.15), Vector3(6.8, 1.1, 0.85), "wood")
	block(Vector3(6, 1.14, 2.15), Vector3(7.0, 0.16, 1.0), "floor")
	person(Vector3(6, 0.45, 1.75), "coat")
	person(Vector3(3.1, 0, 2.5), "red")
	person(Vector3(9.2, 0, 2.5), "coat")
	for x in [3.5, 5.3, 7.8, 8.8]:
		block(Vector3(x, 1.34, 2.45), Vector3(0.17, 0.25, 0.17), "gold")
	for x in [3.0, 9.0]:
		block(Vector3(x, 2.0, 1.65), Vector3(2.2, 0.12, 0.25), "wood")
		for offset in [-0.7, -0.2, 0.4, 0.8]: block(Vector3(x + offset, 2.25, 1.65), Vector3(0.18, 0.4, 0.15), "coat" if offset < 0 else "gold")
	sign_text("THE LANTERN & THE GATE", Vector3(6, 2.65, 1.55), 0, 34)
	torch(Vector3(2.0, 2.05, 4.5))
	torch(Vector3(10.0, 2.05, 4.5))
	for z in [4.5, 7.5, 10.4]: block(Vector3(6, 3.03, z), Vector3(9, 0.25, 0.18), "beam")
	# Open door frame leading south onto the City street.
	for x in [7.65, 10.35]: block(Vector3(x, 1.3, 10.5), Vector3(0.22, 2.6, 0.28), "wood")
	block(Vector3(9, 2.65, 10.5), Vector3(2.9, 0.3, 0.3), "wood")
	sign_text("CITY / SOUTH", Vector3(9, 2.6, 10.30), PI, 27)
	sign_text("LANTERN & GATE", Vector3(9, 2.6, 10.70), 0, 27)
