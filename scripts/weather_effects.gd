extends Node
## Outdoor weather presentation. Real seconds animate storms; no stat/time mutations.
## The random storm clock is independent of the world's saved hourly weather schedule.
const AMBIENCE = {
    'Cool': preload('res://assets/audio/weather/cool-breeze.ogg'),
    'Cold': preload('res://assets/audio/weather/cold-wind.ogg'),
    'Rainy': preload('res://assets/audio/weather/rain.ogg'),
}
const THUNDER = [
    preload('res://assets/audio/weather/thunder-1.ogg'),
    preload('res://assets/audio/weather/thunder-2.ogg'),
    preload('res://assets/audio/weather/thunder-3.ogg'),
]
const LEVELS_DB = {'Cool': -17.0, 'Cold': -11.0, 'Rainy': -12.0}
# Half the original linear audio level for every weather sound, including thunder.
const WEATHER_GAIN_DB := -6.0206
const THUNDER_LEVEL_DB := -9.0 + WEATHER_GAIN_DB
const SILENT_DB := -60.0
const FLASH_SECONDS := 0.22
var ambience_players: Dictionary = {}
var thunder_player := AudioStreamPlayer.new()
var storm_random := RandomNumberGenerator.new()
var active_condition := ''
var lightning_remaining := 0.0
var seconds_until_lightning := 0.0
var seconds_until_thunder := -1.0
var muted := false
var lightning_strength := 0.0

func _ready() -> void:
    storm_random.randomize()
    for condition in AMBIENCE:
        var player := AudioStreamPlayer.new()
        var looping_stream: AudioStreamOggVorbis = AMBIENCE[condition].duplicate()
        looping_stream.loop = true
        player.stream = looping_stream
        player.volume_db = SILENT_DB
        add_child(player)
        ambience_players[condition] = player
    thunder_player.volume_db = THUNDER_LEVEL_DB
    add_child(thunder_player)

## Cancel pending thunder as well as current sounds when shelter ends exposure.
func stop_effects() -> void:
    for player in ambience_players.values():
        player.stop()
        player.volume_db = SILENT_DB
    thunder_player.stop()
    lightning_remaining = 0.0
    seconds_until_thunder = -1.0
    seconds_until_lightning = 0.0
    active_condition = ''

## Called by Main after movement, using the same exposure state as future equipment rules.
func advance(world, delta_seconds: float, audio_muted: bool) -> void:
    muted = audio_muted
    var exposure: Dictionary = world.weather_exposure()
    var next_condition: String = exposure.condition if exposure.exposed else ''
    if next_condition not in AMBIENCE:
        stop_effects()
        return
    if next_condition != active_condition:
        # Never let thunder queued in rain follow the player into another condition.
        thunder_player.stop()
        seconds_until_thunder = -1.0
        lightning_remaining = 0.0
        seconds_until_lightning = storm_random.randf_range(4.0, 9.0) if next_condition == 'Rainy' else 0.0
        active_condition = next_condition

    for condition in ambience_players:
        var player: AudioStreamPlayer = ambience_players[condition]
        var selected: bool = condition == active_condition
        if selected and not player.playing:
            player.play()
        var target_db: float = LEVELS_DB[condition] + WEATHER_GAIN_DB if selected else SILENT_DB
        if muted:
            player.volume_db = -80.0
        else:
            # Crossfade changing conditions; fade back in after unmuting.
            player.volume_db = move_toward(player.volume_db, target_db, delta_seconds * 55.0)
        if not selected and player.volume_db <= SILENT_DB:
            player.stop()
    thunder_player.volume_db = -80.0 if muted else THUNDER_LEVEL_DB
    lightning_remaining = maxf(0.0, lightning_remaining - delta_seconds)
    if active_condition != 'Rainy':
        return

    if seconds_until_thunder >= 0.0:
        seconds_until_thunder -= delta_seconds
        if seconds_until_thunder <= 0.0:
            seconds_until_thunder = -1.0
            thunder_player.stream = THUNDER[storm_random.randi_range(0, THUNDER.size() - 1)]
            thunder_player.pitch_scale = storm_random.randf_range(0.92, 1.06)
            thunder_player.play()
    seconds_until_lightning -= delta_seconds
    if seconds_until_lightning <= 0.0:
        lightning_remaining = FLASH_SECONDS
        lightning_strength = storm_random.randf_range(0.13, 0.25)
        seconds_until_thunder = storm_random.randf_range(0.8, 3.0)
        seconds_until_lightning = storm_random.randf_range(12.0, 28.0)

## A single soft flash confined to the first-person view, never menus or the map.
func flash_opacity() -> float:
    return lightning_strength * lightning_remaining / FLASH_SECONDS
