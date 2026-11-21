extends RefCounted
## Explicit S30 integration boundary. Callers route elapsed time through this
## adapter once; it does not also subscribe to the world's clock signal.
const Clock = preload("res://scripts/game_clock.gd")
var _world: RefCounted
var _runtime: RefCounted
var _busy := false

func _init(world: RefCounted, runtime: RefCounted) -> void:
	_world = world
	_runtime = runtime

func _validate_binding() -> Dictionary:
	if _busy or _world._advancing_clock or _runtime._busy:
		return {"ok": false, "error": "clock_adapter_busy"}
	if _runtime._now_game_microseconds != _world.game_time_boundary() or not is_same(_runtime._character, _world.character):
		return {"ok": false, "error": "clock_adapter_requires_rebinding"}
	return {"ok": true}

func advance_game_microseconds(elapsed: Variant) -> Dictionary:
	var binding := _validate_binding()
	if not binding.ok:
		return binding
	if not elapsed is int:
		return {"ok": false, "error": "invalid_elapsed_type"}
	var preview = Clock.new()
	preview.restore(_world.game_clock.snapshot())
	return _advance(preview, preview.advance_game_microseconds(elapsed))

func advance_real_seconds(seconds: float, mode: String = "ordinary") -> Dictionary:
	var binding := _validate_binding()
	if not binding.ok:
		return binding
	var preview = Clock.new()
	preview.restore(_world.game_clock.snapshot())
	var interval: Dictionary = preview.advance_real_seconds(seconds, mode)
	# Pause accumulates no backlog and does not dispatch queued current-time work.
	if interval.ok and mode == "paused":
		interval["trace"] = []
		return interval
	return _advance(preview, interval)

func _advance(preview: RefCounted, interval: Dictionary) -> Dictionary:
	if not interval.ok:
		return interval
	var prepared: Dictionary = _runtime._prepare(interval.elapsed_game_microseconds)
	if not prepared.ok:
		return prepared
	# No callbacks occur during preview. Commit effects before the world's signal
	# and single metabolism update, with both entry points locked during callbacks.
	_busy = true
	_runtime._busy = true
	_runtime._commit(prepared.candidate)
	_world.game_clock.conversion_remainder = preview.conversion_remainder
	var result: Dictionary = _world._advance_clock_only(interval.elapsed_game_microseconds)
	assert(result.ok, "Prevalidated synchronous clock commit must succeed")
	_runtime._busy = false
	_busy = false
	result["trace"] = prepared.trace
	return result
