extends SceneTree
const World = preload('res://scripts/original_world.gd')
var failures := 0
func check(ok: bool, message: String):
    if not ok:
        failures += 1
        push_error(message)
func _initialize():
    call_deferred('run')
func run():
    var w = World.new()
    w.weather_seed = 12345
    var conditions := {}
    var rainy := -1
    for hour in range(240):
        var condition: String = w.weather_at(hour * 60)
        conditions[condition] = true
        check(condition == w.weather_at(hour * 60 + 59), 'Weather stable within hour')
        if condition == 'Rainy': rainy = hour * 60
    check(conditions.size() == 5, 'Schedule includes all five manual conditions')
    w.minutes = rainy
    w.position = Vector2i(20,0)
    check(not w.is_inside(w.position), 'Outdoor fixture')
    check(w.weather_exposure().rain and w.weather_exposure().cold, 'Outdoor rain exposes character to future rain/cold effects')
    var character: Dictionary = w.character.duplicate(true)
    var needs: Dictionary = w.needs.duplicate(true)
    for i in range(20): w.weather_exposure()
    check(w.character == character and w.needs == needs, 'Weather currently has no stat or needs effects')
    w.save_game('user://test_weather.json')
    var restored = World.new()
    check(restored.load_game('user://test_weather.json'), 'Weather save loads')
    check(restored.weather_seed == w.weather_seed and restored.weather_at(restored.minutes) == 'Rainy', 'Weather restored')
    check(restored.weather_at(w.minutes + 600) == w.weather_at(w.minutes + 600), 'Future weather survives reload')
    w.position = Vector2i(39,34)
    check(not w.weather_exposure().exposed and not w.weather_exposure().rain, 'Tavern shelters from rain')
    w.chapter = 'dungeon'
    check(not w.weather_exposure().exposed, 'Dungeon shelters from weather')
    var data = JSON.parse_string(FileAccess.get_file_as_string('user://test_weather.json'))
    data.erase('weather_seed')
    var file := FileAccess.open('user://test_weather_legacy.json', FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()
    check(restored.load_game('user://test_weather_legacy.json') and restored.weather_seed == 1701, 'Old saves gain stable default weather seed')
    var scene = load('res://scenes/main.tscn').instantiate()
    root.add_child(scene)
    scene.world.weather_seed = 12345
    scene.world.minutes = rainy
    scene.world.position = Vector2i(20,0)
    scene.first_person.sync(scene.world)
    check(scene.first_person.sky_material.get_shader_parameter('overcast') == 1.0, 'Rain overcasts sky')
    check(scene.first_person.environment.fog_density > 0.02, 'Rain adds haze')
    if '--capture' in OS.get_cmdline_user_args():
        # Show rainy daylight for visual review.
        for hour in range(8, 500):
            if hour % 24 in [10,11,12,13,14] and scene.world.weather_at(hour*60) == 'Rainy':
                scene.world.minutes = hour*60
                break
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png('res://docs/city-weather-rain.png')
    scene.world.position = Vector2i(39,34)
    scene.first_person.sync(scene.world)
    check(not scene.first_person.outdoors and not scene.world.weather_exposure().rain, 'Returning indoors suppresses precipitation')
    var seed_before: int = scene.world.weather_seed
    var minutes_before: int = scene.world.minutes
    var automatic_condition: String = scene.world.weather_at(minutes_before)
    scene.show_map = true
    for expected_condition in World.WEATHER_CONDITIONS:
        var selector_key := InputEventKey.new()
        selector_key.keycode = KEY_F6
        selector_key.pressed = true
        scene._unhandled_key_input(selector_key)
        check(scene.world.weather_at(minutes_before) == expected_condition, 'F6 selects ' + expected_condition)
        check(scene.world.weather_at(minutes_before + 600) == expected_condition, 'Forced weather stays fixed over time')
        check(scene.world.minutes == minutes_before and scene.world.weather_seed == seed_before, 'Selector preserves clock and random schedule')
    check(not scene.world.weather_exposure().rain, 'Forced rain still respects indoor shelter')
    scene.world.position = Vector2i(20,0)
    scene.first_person.sync(scene.world)
    check(scene.world.weather_exposure().rain and scene.first_person.sky_material.get_shader_parameter('overcast') == 1.0, 'Forced rain reaches exposure and renderer immediately')
    if '--capture' in OS.get_cmdline_user_args():
        scene.show_map = false
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png('res://docs/weather-selector.png')
    scene.world.save_game('user://test_weather.json')
    var test_save = JSON.parse_string(FileAccess.get_file_as_string('user://test_weather.json'))
    check(not test_save.has('weather_override_index'), 'Test override is not serialized')
    check(restored.load_game('user://test_weather.json') and restored.weather_override_index == -1, 'Fresh world loads automatic weather')
    scene.world.cycle_test_weather()
    check(scene.world.weather_override_index == -1 and scene.world.weather_at(minutes_before) == automatic_condition, 'Full cycle restores original automatic weather')
    scene.music.stop()
    scene.music.stream = null
    await create_timer(0.3).timeout
    scene.queue_free()
    await process_frame
    DirAccess.remove_absolute('user://test_weather.json')
    DirAccess.remove_absolute('user://test_weather_legacy.json')
    print('City weather, shelter, saves and rendering: ', 'PASS' if failures == 0 else 'FAIL')
    quit(failures)
