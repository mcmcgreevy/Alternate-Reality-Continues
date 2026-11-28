extends RefCounted
## ST City calendar and elapsed-time adapter. See docs/S03_CLOCK.md.
## Microseconds and the finite timestamp ceiling are remake representation choices.
const GAME_MICROSECONDS_PER_SECOND: int = 1000000
const GAME_MICROSECONDS_PER_MINUTE: int = 60000000
const MAX_GAME_MICROSECONDS: int = 9000000000000000
const ORDINARY_RATE: int = 15
const ACCELERATED_RATE: int = 3600
const START_DAY_OFFSET: int = 4 * 31 + 28  # Sowings 29, counting from Rebirth 1.
const MONTHS := ["Rebirth", "Awakening", "Winds", "Rains", "Sowings", "First Fruits",
	"Harvest", "Final Reaping", "The Fall", "Darkness", "Cold Winds", "Lights"]
var game_microseconds: int = 360 * GAME_MICROSECONDS_PER_MINUTE
var conversion_remainder := 0.0

func _init(initial_minutes: int = 360) -> void:
	set_minutes(initial_minutes)

func set_minutes(value: int) -> bool:
	if value < 0 or value > MAX_GAME_MICROSECONDS / GAME_MICROSECONDS_PER_MINUTE:
		return false
	var fraction := game_microseconds % GAME_MICROSECONDS_PER_MINUTE
	var whole := value * GAME_MICROSECONDS_PER_MINUTE
	if fraction > MAX_GAME_MICROSECONDS - whole:
		return false
	game_microseconds = whole + fraction
	return true

func whole_minutes() -> int:
	return game_microseconds / GAME_MICROSECONDS_PER_MINUTE

func minute_fraction() -> float:
	return float(game_microseconds % GAME_MICROSECONDS_PER_MINUTE) / GAME_MICROSECONDS_PER_MINUTE

func set_minute_fraction(value: float) -> bool:
	if not is_finite(value) or value < 0.0 or value >= 1.0:
		return false
	var fraction := int(value * GAME_MICROSECONDS_PER_MINUTE)
	var whole := whole_minutes() * GAME_MICROSECONDS_PER_MINUTE
	if fraction > MAX_GAME_MICROSECONDS - whole:
		return false
	game_microseconds = whole + fraction
	return true

func rejected(reason: String) -> Dictionary:
	return {"ok": false, "error": reason, "start_game_microseconds": game_microseconds,
		"end_game_microseconds": game_microseconds, "elapsed_game_microseconds": 0}

## The integer input is exactly partition invariant. Consumers receive one interval,
## not a second real-time conversion. Zero is valid and does not imply an action.
func advance_game_microseconds(elapsed: int) -> Dictionary:
	if elapsed < 0 or elapsed > MAX_GAME_MICROSECONDS - game_microseconds:
		return rejected("Elapsed game time is negative or exceeds the clock range.")
	var before := game_microseconds
	game_microseconds += elapsed
	return {"ok": true, "start_game_microseconds": before,
		"end_game_microseconds": game_microseconds, "elapsed_game_microseconds": elapsed}

## Keep sub-microsecond remainder across frames and mode changes. Pause does not
## collect a backlog; explicit waits already expressed in game time bypass rates.
func advance_real_seconds(seconds: float, mode: String = "ordinary") -> Dictionary:
	if not is_finite(seconds) or seconds < 0.0 or mode not in ["ordinary", "accelerated", "paused"]:
		return rejected("Invalid real-time interval or clock mode.")
	if mode == "paused":
		return advance_game_microseconds(0)
	var rate: int = ACCELERATED_RATE if mode == "accelerated" else ORDINARY_RATE
	var scaled := seconds * rate * GAME_MICROSECONDS_PER_SECOND + conversion_remainder
	if not is_finite(scaled) or scaled > MAX_GAME_MICROSECONDS - game_microseconds:
		return rejected("Converted elapsed time exceeds the clock range.")
	var elapsed := int(floor(scaled))
	var result := advance_game_microseconds(elapsed)
	if result.ok:
		conversion_remainder = scaled - elapsed
	return result

func calendar() -> Dictionary:
	var total_minutes := whole_minutes()
	var day_index: int = total_minutes / 1440 + START_DAY_OFFSET
	return {"year": day_index / (12 * 31), "month": (day_index / 31) % 12 + 1,
		"month_name": MONTHS[(day_index / 31) % 12], "day": day_index % 31 + 1,
		"hour": (total_minutes / 60) % 24, "minute": total_minutes % 60,
		"second": (game_microseconds / GAME_MICROSECONDS_PER_SECOND) % 60}

func snapshot() -> Dictionary:
	return {"version": 1, "game_microseconds": game_microseconds,
		"conversion_remainder": conversion_remainder}

## JSON integers are exact throughout our <= 9e15 timestamp domain. Validate a
## candidate clock before assigning it to the live world during save migration.
func restore(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 1:
		return false
	var elapsed = data.get("game_microseconds")
	var remainder = data.get("conversion_remainder")
	if not (elapsed is int or elapsed is float) or not is_finite(float(elapsed)):
		return false
	if elapsed < 0 or elapsed > MAX_GAME_MICROSECONDS or elapsed != int(elapsed):
		return false
	if not (remainder is int or remainder is float) or not is_finite(float(remainder)):
		return false
	if remainder < 0.0 or remainder >= 1.0:
		return false
	game_microseconds = int(elapsed)
	conversion_remainder = float(remainder)
	return true
