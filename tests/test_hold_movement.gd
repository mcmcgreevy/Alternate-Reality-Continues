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
    var minutes: int = scene.world.minutes
    var direction: Vector2i = scene.world.DIRECTIONS[scene.world.facing]
    key(KEY_W)
    check(scene.world.position == start + direction and scene.world.minutes == minutes, 'Keyboard step adds no action-time charge')
    scene.advance_held_movement(0.34)
    check(scene.world.position == start + direction, 'Initial repeat delay')
    scene.advance_held_movement(0.02)
    check(scene.world.position == start + direction * 2, 'Holding repeats after delay')
    key(KEY_W, true, true)
    check(scene.world.position == start + direction * 2, 'OS echo does not add moves')
    key(KEY_W, false)
    scene.advance_held_movement(10)
    check(scene.world.position == start + direction * 2, 'Release stops immediately')
    corridor()
    key(KEY_W)
    minutes = scene.world.minutes
    start = scene.world.position
    direction = scene.world.DIRECTIONS[scene.world.facing]
    scene.advance_held_movement(10)
    check(scene.world.position == start + direction and scene.world.minutes == minutes, 'Frame stall cannot burst multiple steps or charge clock')
    key(KEY_E)
    check(scene.held_key == 0, 'Interaction clears held movement')
    corridor()
    key(KEY_A)
    check(scene.repeat_remaining == scene.HOLD_DELAY, 'Turning has initial delay')
    scene.advance_held_movement(0.36)
    check(scene.repeat_remaining == scene.TURN_INTERVAL, 'Turning repeats more slowly')
    key(KEY_TAB)
    check(scene.held_key == 0, 'Map cancels repeat')
    var facing: int = scene.world.facing
    key(KEY_D)
    check(scene.show_map and scene.world.facing == posmod(facing + 1, 4), 'Map remains open while turning')
    corridor()
    key(KEY_TAB)
    start = scene.world.position
    minutes = scene.world.minutes
    key(KEY_W)
    scene.advance_held_movement(0.36)
    check(scene.show_map and scene.world.position != start and scene.world.minutes == minutes, 'Map remains live during held movement')
    key(KEY_W, false)
    key(KEY_C)
    facing = scene.world.facing
    key(KEY_D)
    check(scene.world.facing == facing and scene.held_key == 0, 'Chapter overlay still blocks movement')
    corridor()
    key(KEY_W)
    scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    check(scene.held_key == 0, 'Focus loss cancels repeat')
    corridor()
    key(KEY_H)
    start = scene.world.position
    direction = scene.world.DIRECTIONS[scene.world.facing]
    minutes = scene.world.minutes
    key(KEY_W)
    scene.advance_held_movement(1)
    check(not scene.hold_movement and scene.world.position == start + direction and scene.world.minutes == minutes and scene.held_key == 0, 'Classic mode only steps once')
    var config := ConfigFile.new()
    check(config.load(scene.controls_path) == OK and not config.get_value('movement','hold',true), 'Classic preference saved')
    scene.hold_movement = true
    scene.world.chapter = 'city'
    scene.world.position = Vector2i(39,34)
    key(KEY_W)
    check(scene.held_key == 0 and scene.world.in_tavern(), 'Tavern does not arm movement')
    scene.world.chapter = 'dungeon'
    scene.world.position = Vector2i(49,3)
    key(KEY_E)
    check(scene.held_key == 0 and scene.world.chapter == 'city', 'Chapter transition leaves movement stopped')
    scene.world.chapter = 'dungeon'
    scene.world.position = Vector2i(49,3)
    scene.world.facing = 1
    minutes = scene.world.minutes
    key(KEY_W)
    scene.advance_held_movement(1)
    check(scene.held_key == 0 and scene.world.minutes == minutes, 'Solid boundary stops repeat without spending time')
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
