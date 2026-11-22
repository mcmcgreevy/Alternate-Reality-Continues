extends RefCounted
## Dedicated gameplay stream. Decimal strings preserve all signed 64-bit bits in JSON.
const FORMAT := "godot-4.5-pcg32-v1"
var generator := RandomNumberGenerator.new()

func _init(initial_seed: int = 1701) -> void:
	generator.seed = initial_seed

func next_facing() -> int:
	return generator.randi_range(0, 3)

func snapshot() -> Dictionary:
	return {"format": FORMAT, "seed": str(generator.seed), "state": str(generator.state)}

func restore(data: Variant) -> bool:
	if not data is Dictionary or data.size() != 3 or data.get("format") != FORMAT:
		return false
	for key in ["seed", "state"]:
		var value = data.get(key)
		# Round-trip comparison rejects overflow, whitespace, signs/zero padding and floats.
		if not value is String or not value.is_valid_int() or str(value.to_int()) != value:
			return false
	generator.seed = data.seed.to_int()
	generator.state = data.state.to_int()
	return true
