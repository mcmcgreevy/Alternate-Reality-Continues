extends SceneTree
var scene: Node
var failures := 0
func check(ok: bool, description: String):
    if not ok:
        failures += 1
        push_error(description)
func key(code: int, pressed := true, echo := false):
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = pressed
    event.echo = echo
    scene._unhandled_key_input(event)
func _initialize():
    call_deferred('run')
func corridor():
    scene.cancel_held_movement()
    scene.world.chapter = 'dungeon'
    scene.show_map = false
    scene.show_chapters = false
    scene.hold_movement = true
    for cell_key in scene.world.maps.dungeon.cells:
        var xy = cell_key.split(',')
        var at = Vector2i(int(xy[0]), int(xy[1]))
        for d in range(4):
            var direction: Vector2i = scene.world.DIRECTIONS[d]
            var valid := true
            for n in range(4):
                var p: Vector2i = at + direction * n
                if not scene.world.has_cell(p) or scene.world.edge(p,d) not in [0,1,2,7] or scene.world.dungeon_links.has('%d,%d' % [p.x,p.y]) or p == Vector2i(49,3):
                    valid = false
                    break
            if valid:
                scene.world.position = at
                scene.world.facing = d
                return
    check(false, 'Find real open corridor fixture')
func run():
    scene = load('res://scenes/main.tscn').instantiate()
    scene.controls_path = 'user://test_controls.cfg'
    DirAccess.remove_absolute(scene.controls_path)
    root.add_child(scene)
    scene.set_process(false)
    corridor()
    var start: Vector2i = scene.world.position
    var direction: Vector2i = scene.world.DIRECTIONS[scene.world.facing]
    check(scene.world.effective_speed() == 13 and scene.world.walking_speed() == 6, 'ST initial Speed and walking rate')
    key(KEY_W)
    check(scene.world.position == start and scene.world.is_travelling(), 'Press begins travel without teleporting')
    scene.advance_held_movement(0.5)
    check(scene.world.position == start and scene.world.travel_position().is_equal_approx(Vector2(start) + Vector2(direction) * 0.5), 'Half stride has fractional position')
    scene.first_person.sync(scene.world)
    check(is_equal_approx(scene.first_person.camera.position.x, scene.world.travel_position().x * scene.first_person.CELL), 'Camera follows fractional position')
    check(scene.world.save_game('user://test_midstride.json') == ERR_BUSY, 'No ambiguous mid-stride save')
    key(KEY_W, true, true)
    check(is_equal_approx(scene.world.travel_progress, 0.5), 'OS repeat cannot advance travel')
    key(KEY_W, false)
    scene.advance_held_movement(0.5)
    check(scene.world.position == start + direction and not scene.world.is_travelling(), 'Release finishes one stride without starting another')
    corridor()
    start = scene.world.position
    key(KEY_W)
    scene.advance_held_movement(10)
    check(scene.world.position == start + scene.world.DIRECTIONS[scene.world.facing], 'Stall cannot skip multiple cells')
    check(scene.world.is_travelling(), 'Held movement starts next stride at arrival')
    scene.cancel_held_movement()
    scene.advance_held_movement(1)
    corridor()
    key(KEY_TAB)
    key(KEY_W)
    scene.advance_held_movement(0.25)
    check(scene.show_map and scene.world.travel_progress > 0, 'Map remains live during incremental travel')
    key(KEY_C)
    var progress: float = scene.world.travel_progress
    var minutes: int = scene.world.minutes
    scene._process(8)
    check(scene.world.travel_progress == progress and scene.world.minutes == minutes, 'Chapter overview pauses travel and clock')
    key(KEY_C)
    scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    scene._process(8)
    check(scene.world.travel_progress == progress and scene.world.minutes == minutes, 'Focus loss pauses travel and clock')
    scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
    scene.advance_held_movement(1)
    corridor()
    scene.world.character.speed = 7
    check(scene.world.walking_speed() == 4, 'Integer walking-rate tiers')
    key(KEY_W)
    scene.cancel_held_movement()
    scene.advance_held_movement(0.75)
    check(is_equal_approx(scene.world.travel_progress, 0.5), 'Lower Speed slows actual traversal')
    scene.advance_held_movement(0.75)
    scene.world.character.speed = 25
    scene.world.character.speed_penalty = 12
    check(scene.world.walking_speed() == 6, 'Effective Speed includes penalties')
    scene.world.character.speed_penalty = 0
    check(scene.world.walking_speed() == 10, 'Higher Speed increases walking rate')
    scene.world.character.speed = 999
    check(scene.world.walking_speed() == 36, 'ST maximum walking speed')
    scene.world.character.speed = 0
    check(not scene.world.begin_travel(scene.world.DIRECTIONS[scene.world.facing]), 'Zero Speed prevents travel')
    scene.world.character.speed = 13
    scene.world.minute_fraction = 0
    minutes = scene.world.minutes
    scene._process(2)
    check(scene.world.minutes == minutes and is_equal_approx(scene.world.minute_fraction, 0.5), 'Continuous clock retains fractional minutes while idle')
    check(scene.world.save_game('user://test_speed.json') == OK, 'Speed and fractional clock save')
    scene.world.advance_real_seconds(2)
    check(scene.world.minutes == minutes + 1, 'Four seconds per game minute')
    check(scene.world.load_game('user://test_speed.json') and is_equal_approx(scene.world.minute_fraction, 0.5) and scene.world.character.speed == 13, 'Speed and fractional clock restore')
    var saved = JSON.parse_string(FileAccess.get_file_as_string('user://test_speed.json'))
    saved.version = 4  # Exercise a legacy save, not a malformed version 5 clock.
    saved.erase('effects')  # Legacy fixtures predate v7.
    saved.erase('gameplay_random')  # Legacy fixtures predate v8.
    saved.erase('clock')
    saved.erase('minute_fraction')
    for field in ['speed', 'speed_bonus', 'speed_penalty']:
        saved.character.erase(field)
    var migration_file := FileAccess.open('user://test_speed_migration.json', FileAccess.WRITE)
    migration_file.store_string(JSON.stringify(saved))
    migration_file.close()
    check(scene.world.load_game('user://test_speed_migration.json') and scene.world.effective_speed() == 13 and scene.world.minute_fraction == 0, 'Old saves migrate even after loading a newer save')
    saved.minute_fraction = 1.5
    migration_file = FileAccess.open('user://test_speed_migration.json', FileAccess.WRITE)
    migration_file.store_string(JSON.stringify(saved))
    migration_file.close()
    var position_before: Vector2i = scene.world.position
    check(not scene.world.load_game('user://test_speed_migration.json') and scene.world.position == position_before, 'Malformed fractional clock rejected atomically')
    corridor()
    scene.world.character.speed = 7
    var time_before: float = scene.world.minutes + scene.world.minute_fraction
    check(scene.world.step(), 'Slow stride succeeds')
    check(is_equal_approx(scene.world.minutes + scene.world.minute_fraction - time_before, 0.375), 'Slower travel spends more simulation time')
    scene.world.character.speed = 25
    time_before = scene.world.minutes + scene.world.minute_fraction
    check(scene.world.step(), 'Fast stride succeeds')
    check(is_equal_approx(scene.world.minutes + scene.world.minute_fraction - time_before, 0.15), 'Faster travel spends less simulation time')
    scene.world.character.speed = 13
    corridor()
    key(KEY_H)
    key(KEY_W)
    scene.advance_held_movement(1)
    check(not scene.hold_movement and not scene.world.is_travelling() and scene.held_key == 0, 'Classic mode animates exactly one stride')
    scene.hold_movement = true
    scene.world.chapter = 'dungeon'
    scene.world.position = Vector2i(49,3)
    scene.world.facing = 1
    key(KEY_W)
    check(not scene.world.is_travelling() and scene.held_key == 0, 'Solid boundary blocks travel')
    var tested_link := false
    for link_key in scene.world.dungeon_links:
        var link: Dictionary = scene.world.dungeon_links[link_key]
        if not link.enabled: continue
        var xy = link_key.split(',')
        var entry = Vector2i(int(xy[0]), int(xy[1]))
        for d in range(4):
            var approach: Vector2i = entry - scene.world.DIRECTIONS[d]
            if scene.world.edge(approach,d) not in [0,1,2,3,4,5,6,7]: continue
            scene.world.position = approach
            scene.world.facing = d
            scene.world.doors[scene.world.door_key(approach,d)] = true
            var revision: int = scene.world.revision
            key(KEY_W)
            scene.advance_held_movement(1)
            check(scene.world.revision > revision and scene.held_key == 0, 'Automatic dungeon passage transition cancels repeat')
            tested_link = true
            break
        if tested_link: break
    check(tested_link, 'Exercised an original automatic transition')
    scene.music.stop()
    scene.music.stream = null
    await create_timer(0.3).timeout
    scene.queue_free()
    await process_frame
    DirAccess.remove_absolute('user://test_controls.cfg')
    print('Hold movement and classic controls: ', 'PASS' if failures == 0 else 'FAIL')
    quit(failures)
