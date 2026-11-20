extends RefCounted
## Named stat views and bounded effect actions; no raw memory interpreter.
## Kroah ST characterStats.html, plus S29/S32 byte-Speed arithmetic evidence.
const PRIMARY := ["stamina", "charisma", "strength", "intelligence", "wisdom", "skill", "speed"]
# These are storage/input domains, not assertions about original storage widths.
const MAX_VALUE: int = 1000000
const SECONDARY := ["hp", "max_hp", "level", "experience", "required_experience",
	"alignment", "stealth", "unnoticeability", "treasure_finding", "hunger",
	"hunger_rate", "thirst", "thirst_rate", "fatigue", "fatigue_rate", "digestion",
	"alcohol_blood", "alcohol_intestine", "alcohol_digestion_rate", "blackout_duration",
	"coordination", "balance", "warmth", "encumbrance", "clarity", "delusion",
	"invisibility", "paralysis"]
const DAMAGE_TYPES := ["blunt", "sharp", "earth", "air", "fire", "water", "power", "mental", "cleric", "evil"]

static func real_value(value: Variant, maximum: float = MAX_VALUE) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= 0 and value <= maximum

static func integer_value(value: Variant, maximum: int = MAX_VALUE) -> bool:
	return real_value(value, maximum) and value == int(value)

static func primary_snapshot(character: Dictionary, stat: String) -> Dictionary:
	if stat not in PRIMARY:
		return {"ok": false, "error": "unknown_primary_stat"}
	# Only Speed has a documented default here. S07 owns the other creation rolls.
	if not character.has(stat) and stat != "speed":
		return {"ok": false, "error": "uninitialized_primary_stat"}
	var base = character.get(stat, 13)
	var bonus = character.get(stat + "_bonus", 0)
	var penalty = character.get(stat + "_penalty", 0)
	if not real_value(base) or not integer_value(bonus, 255 if stat == "speed" else MAX_VALUE) or not integer_value(penalty):
		return {"ok": false, "error": "invalid_primary_state"}
	if not character.get("speed_revealed", false) is bool:
		return {"ok": false, "error": "invalid_visibility"}
	var effective := int(base) + int(bonus) - int(penalty)
	if not character.get("stat_display", {}) is Dictionary:
		return {"ok": false, "error": "invalid_display_state"}
	var presentation: Dictionary = character.get("stat_display", {})
	if presentation.has(stat) and not presentation[stat] is int:
		return {"ok": false, "error": "invalid_display_state"}
	var displayed: int = presentation.get(stat, effective)
	return {"ok": true, "base": base, "bonus": int(bonus), "penalty": int(penalty),
		"effective": effective, "displayed": displayed,
		"visible": stat != "speed" or character.get("speed_revealed", false)}

static func walking_speed(character: Dictionary) -> int:
	var speed := primary_snapshot(character, "speed")
	if not speed.ok:
		return 0
	# Zero floor is a safe movement boundary, not a clamp of the effective stat.
	return clampi(int((speed.effective + 5) / 6) * 2, 0, 36)

static func set_base(character: Dictionary, stat: String, value: Variant) -> Dictionary:
	if stat not in PRIMARY or not real_value(value):
		return {"ok": false, "error": "invalid_base_stat"}
	character[stat] = value  # Preserve fractional base; never truncate on a write.
	return {"ok": true}

static func set_modifiers(character: Dictionary, stat: String, bonus: Variant, penalty: Variant) -> Dictionary:
	if stat not in PRIMARY or not integer_value(bonus, 255 if stat == "speed" else MAX_VALUE) or not integer_value(penalty):
		return {"ok": false, "error": "invalid_modifier"}
	character[stat + "_bonus"] = int(bonus)
	character[stat + "_penalty"] = int(penalty)
	return {"ok": true}

## Presentation producers supply measured/injected values. Delusion RNG cadence
## and arithmetic belong to its producer, never to a read of the stat snapshot.
static func set_display(character: Dictionary, overrides: Dictionary) -> Dictionary:
	for key in overrides:
		if key not in PRIMARY and key != "hp":
			return {"ok": false, "error": "unknown_display_stat"}
		var value = overrides[key]
		if not (value is int) or value < -MAX_VALUE or value > 2 * MAX_VALUE:
			return {"ok": false, "error": "invalid_display_value"}
	character["stat_display"] = overrides.duplicate(true)
	return {"ok": true}

static func secondary_snapshot(character: Dictionary, stat: String) -> Dictionary:
	if stat == "walking_speed":
		return {"ok": true, "value": walking_speed(character)}
	if stat in ["magical_protection", "protection_efficiencies"]:
		if not character.has(stat):
			return {"ok": false, "error": "uninitialized_secondary_stat"}
		if not valid_protection(character[stat], stat == "protection_efficiencies"):
			return {"ok": false, "error": "invalid_protection_state"}
		return {"ok": true, "value": character[stat].duplicate(true)}
	if stat not in SECONDARY:
		return {"ok": false, "error": "unknown_secondary_stat"}
	if not character.has(stat):
		return {"ok": false, "error": "uninitialized_secondary_stat"}
	if not real_value(character[stat]):
		return {"ok": false, "error": "invalid_secondary_stat"}
	var result := {"ok": true, "value": character[stat]}
	if stat == "hp":
		result["displayed"] = character.get("stat_display", {}).get("hp", character.hp)
	return result

static func set_secondary(character: Dictionary, stat: String, value: Variant) -> Dictionary:
	if stat in ["magical_protection", "protection_efficiencies"]:
		if not valid_protection(value, stat == "protection_efficiencies"):
			return {"ok": false, "error": "invalid_protection_state"}
		character[stat] = value.duplicate(true)
		return {"ok": true}
	if stat not in SECONDARY or not real_value(value):
		return {"ok": false, "error": "invalid_secondary_stat"}
	if stat in ["hp", "max_hp"] and not integer_value(value):
		return {"ok": false, "error": "invalid_integer_stat"}
	character[stat] = value
	return {"ok": true}

static func valid_protection(value: Variant, efficiency: bool) -> bool:
	if not value is Dictionary:
		return false
	for damage_type in value:
		if damage_type not in DAMAGE_TYPES:
			return false
		if efficiency:
			if value[damage_type] not in ["low", "normal", "high", "immune"]:
				return false
		elif not real_value(value[damage_type]):
			return false
	return true

## Validate a detached save candidate. Keep fractional primary/secondary values;
## normalize only proven integer fields. No live character changes on failure.
static func normalize_character(source: Variant) -> Dictionary:
	if not source is Dictionary:
		return {"ok": false, "error": "invalid_character"}
	var candidate: Dictionary = source.duplicate(true)
	for required in ["name", "hp", "max_hp", "strength", "stamina", "gold", "silver", "copper"]:
		if not candidate.has(required):
			return {"ok": false, "error": "missing_character_field"}
	if not candidate.name is String:
		return {"ok": false, "error": "invalid_name"}
	for stat in PRIMARY:
		if not candidate.has(stat):
			continue
		if not real_value(candidate[stat]):
			return {"ok": false, "error": "invalid_base_stat"}
	# Validate modifiers even when a base is not initialized yet.
	for stat in PRIMARY:
		for suffix in ["_bonus", "_penalty"]:
			var field: String = stat + suffix
			if candidate.has(field):
				if not integer_value(candidate[field], 255 if field == "speed_bonus" else MAX_VALUE):
					return {"ok": false, "error": "invalid_modifier"}
				candidate[field] = int(candidate[field])
	for field in ["hp", "max_hp", "gold", "silver", "copper"]:
		var limit: int = 9000000000000000 if field in ["gold", "silver", "copper"] else MAX_VALUE
		if not integer_value(candidate[field], limit):
			return {"ok": false, "error": "invalid_integer_stat"}
		candidate[field] = int(candidate[field])
	for field in SECONDARY:
		if candidate.has(field) and not real_value(candidate[field]):
			return {"ok": false, "error": "invalid_secondary_stat"}
	for field in ["magical_protection", "protection_efficiencies"]:
		if candidate.has(field) and not valid_protection(candidate[field], field == "protection_efficiencies"):
			return {"ok": false, "error": "invalid_protection_state"}
	if not candidate.get("speed_revealed", false) is bool:
		return {"ok": false, "error": "invalid_visibility"}
	var display = candidate.get("stat_display", {})
	if not display is Dictionary:
		return {"ok": false, "error": "invalid_display_state"}
	for field in display:
		var value = display[field]
		if (field not in PRIMARY and field != "hp") or not (value is int or value is float) or not is_finite(float(value)) or value != int(value) or value < -MAX_VALUE or value > 2 * MAX_VALUE:
			return {"ok": false, "error": "invalid_display_state"}
		display[field] = int(value)
	candidate["stat_display"] = display
	return {"ok": true, "character": candidate}

## A batch is one transaction: validate every command before executing in order.
## Repeated explicit commands are real arithmetic, not a hidden modifier stack.
## S29/S30 own activation/H suppression, scheduling and owner/group cleanup.
static func apply_actions(character: Dictionary, actions: Array) -> Dictionary:
	var bonus = character.get("speed_bonus", 0)
	if not integer_value(bonus, 255):
		return {"ok": false, "error": "invalid_speed_bonus"}
	for action in actions:
		if not action is Dictionary or action.size() != 6:
			return {"ok": false, "error": "invalid_action_shape"}
		if action.get("target") != "speed_bonus" or action.get("operation") not in ["add", "subtract"]:
			return {"ok": false, "error": "unsupported_action"}
		for key in ["operand_width", "block_count", "block_gap", "parameter"]:
			if not action.get(key) is int:
				return {"ok": false, "error": "invalid_action_integer"}
		if action.operand_width != 1 or action.block_count != 1 or action.block_gap != 0 or not integer_value(action.parameter, 255):
			return {"ok": false, "error": "unsupported_action_layout"}
	var next_bonus := int(bonus)
	var trace: Array[int] = []
	for action in actions:
		next_bonus = mini(255, next_bonus + action.parameter) if action.operation == "add" else maxi(0, next_bonus - action.parameter)
		trace.append(next_bonus)
	if not actions.is_empty():
		character["speed_bonus"] = next_bonus
	return {"ok": true, "before": int(bonus), "after": next_bonus, "trace": trace}
