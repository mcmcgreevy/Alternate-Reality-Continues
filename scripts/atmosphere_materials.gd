extends RefCounted
## Original procedural surfaces; no recovered game artwork.
static func build(kind: String, base: Color) -> StandardMaterial3D:
	var size := 256
	var albedo := Image.create(size, size, false, Image.FORMAT_RGB8)
	var height := Image.create(size, size, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 47591 + kind.hash()
	for y in range(size):
		for x in range(size):
			var wood := kind in ["wood", "floor", "ceiling"]
			var row := int(y / 64)
			var sx := (x + (64 if row % 2 else 0)) % 128
			var sy := y % 64
			var border := minf(minf(sx, 127 - sx), minf(sy, 63 - sy))
			var grain := rng.randf_range(-0.035, 0.035)
			var stone_variation := sin(float(int((x + (64 if row % 2 else 0)) / 128) * 17 + row * 7)) * 0.07
			var relief := clampf(border / 5.0, 0.0, 1.0)
			var tone := 0.78 + stone_variation + grain
			if wood:
				var plank := x % 64
				relief = clampf(minf(plank, 63 - plank) / 3.0, 0.0, 1.0)
				tone = 0.78 + sin(x * 1.9 + sin(y * 0.047) * 2.0) * 0.075 + grain
			if kind == "plaster":
				relief = 0.8 + grain
				tone = 0.85 + grain
			albedo.set_pixel(x, y, base * (tone * (0.45 + relief * 0.55)))
			height.set_pixel(x, y, Color.WHITE * (relief * 0.6 + 0.15 + grain))
	height.bump_map_to_normal_map(3.0)
	albedo.generate_mipmaps()
	height.generate_mipmaps()
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(albedo)
	mat.normal_enabled = true
	mat.normal_texture = ImageTexture.create_from_image(height)
	mat.normal_scale = 0.65
	mat.roughness = 0.88
	if kind in ["stone", "paving"]: mat.uv1_scale = Vector3(2, 2, 1)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat
