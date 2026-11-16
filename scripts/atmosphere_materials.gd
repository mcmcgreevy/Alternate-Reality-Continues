extends RefCounted
## Original procedural surfaces; no recovered game artwork.
## Generate repeatable albedo and relief textures for each surface kind.
## normal_image starts as a height map and is converted in place to tangent-space normals.
static func build(surface_kind: String, base_color: Color) -> StandardMaterial3D:
	var texture_size := 256
	var albedo_image := Image.create(texture_size, texture_size, false, Image.FORMAT_RGB8)
	var normal_image := Image.create(texture_size, texture_size, false, Image.FORMAT_RGB8)
	var texture_random := RandomNumberGenerator.new()
	texture_random.seed = 47591 + surface_kind.hash()
	for y in range(texture_size):
		for x in range(texture_size):
			var is_wood := surface_kind in ["wood", "floor", "ceiling"]
			var brick_row := int(y / 64)
			var brick_local_x := (x + (64 if brick_row % 2 else 0)) % 128
			var brick_local_y := y % 64
			var distance_to_mortar := minf(minf(brick_local_x, 127 - brick_local_x), minf(brick_local_y, 63 - brick_local_y))
			var grain := texture_random.randf_range(-0.035, 0.035)
			var stone_variation := sin(float(int((x + (64 if brick_row % 2 else 0)) / 128) * 17 + brick_row * 7)) * 0.07
			var relief := clampf(distance_to_mortar / 5.0, 0.0, 1.0)
			var tone := 0.78 + stone_variation + grain
			if is_wood:
				var plank_local_x := x % 64
				relief = clampf(minf(plank_local_x, 63 - plank_local_x) / 3.0, 0.0, 1.0)
				tone = 0.78 + sin(x * 1.9 + sin(y * 0.047) * 2.0) * 0.075 + grain
			if surface_kind == "plaster":
				relief = 0.8 + grain
				tone = 0.85 + grain
			albedo_image.set_pixel(x, y, base_color * (tone * (0.45 + relief * 0.55)))
			normal_image.set_pixel(x, y, Color.WHITE * (relief * 0.6 + 0.15 + grain))
	normal_image.bump_map_to_normal_map(3.0)
	albedo_image.generate_mipmaps()
	normal_image.generate_mipmaps()
	var surface_material := StandardMaterial3D.new()
	surface_material.albedo_texture = ImageTexture.create_from_image(albedo_image)
	surface_material.normal_enabled = true
	surface_material.normal_texture = ImageTexture.create_from_image(normal_image)
	surface_material.normal_scale = 0.65
	surface_material.roughness = 0.88
	if surface_kind in ["stone", "paving"]: surface_material.uv1_scale = Vector3(2, 2, 1)
	surface_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return surface_material
