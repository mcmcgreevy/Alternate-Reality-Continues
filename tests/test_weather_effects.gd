extends SceneTree
const World = preload('res://scripts/original_world.gd')
const Effects = preload('res://scripts/weather_effects.gd')
var failures := 0
func check(ok: bool, message: String):
    if not ok:
        failures += 1
        push_error(message)
func _initialize():
    call_deferred('run')
func run():
    var world = World.new()
    world.position = Vector2i(20,0)
    var effects = Effects.new()
    root.add_child(effects)
    effects.storm_random.seed = 1234
    for condition in ['Cool', 'Cold', 'Rainy']:
        world.weather_override_index = World.WEATHER_CONDITIONS.find(condition)
        effects.advance(world, 1.0, false)
        check(effects.ambience_players[condition].playing, condition + ' ambience plays outdoors')
        check(effects.ambience_players[condition].stream.loop, condition + ' ambience loops')
    check(effects.LEVELS_DB.Cold > effects.LEVELS_DB.Cool, 'Cold wind is stronger than cool breeze')
    effects.seconds_until_lightning = 0.01
    var minutes_before: int = world.minutes
    effects.advance(world, 0.02, false)
    check(effects.flash_opacity() > 0 and effects.seconds_until_thunder >= 0.8, 'Lightning precedes delayed thunder')
    check(not effects.thunder_player.playing, 'Thunder is not immediate')
    check(effects.seconds_until_lightning >= 12 and effects.seconds_until_lightning <= 28, 'Random storm interval is bounded')
    effects.advance(world, effects.seconds_until_thunder + 0.01, false)
    check(effects.thunder_player.playing and effects.flash_opacity() == 0, 'Thunder follows flash')
    check(world.minutes == minutes_before, 'Storm clock does not spend simulation time')
    effects.advance(world, 0.01, true)
    check(effects.thunder_player.volume_db <= -80 and effects.ambience_players.Rainy.volume_db <= -80, 'Mute silences rain and thunder')
    world.position = Vector2i(39,34)
    effects.advance(world, 0.01, false)
    check(not effects.thunder_player.playing and effects.active_condition == '' and effects.seconds_until_thunder < 0, 'Shelter cancels active and queued thunder')
    for player in effects.ambience_players.values():
        check(not player.playing, 'Shelter stops all ambience')
    world.position = Vector2i(20,0)
    effects.advance(world, 0.01, false)
    effects.seconds_until_lightning = 0.0
    effects.advance(world, 0.01, false)
    world.weather_override_index = World.WEATHER_CONDITIONS.find('Cool')
    effects.advance(world, 1.0, false)
    check(effects.flash_opacity() == 0 and effects.seconds_until_thunder < 0, 'Changing weather cancels storm')
    check(not effects.ambience_players.Rainy.playing, 'Old ambience fades out after condition switch')
    world.weather_override_index = World.WEATHER_CONDITIONS.find('Hot')
    effects.advance(world, 0.01, false)
    check(effects.active_condition == '', 'Hot weather has no wind/rain loop')
    world.weather_override_index = World.WEATHER_CONDITIONS.find('Rainy')
    world.chapter = 'dungeon'
    effects.advance(world, 0.01, false)
    check(effects.active_condition == '', 'Dungeon remains sheltered')
    effects.stop_effects()
    for player in effects.ambience_players.values(): player.stream = null
    effects.thunder_player.stream = null
    await create_timer(0.3).timeout
    effects.queue_free()
    await process_frame
    print('Weather ambience, storm timing, mute and shelter: ', 'PASS' if failures == 0 else 'FAIL')
    quit(failures)
