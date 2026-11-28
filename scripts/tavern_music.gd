extends AudioStreamPlayer
## Approved full and no-lead mixes share one playback clock.
const LENGTH := 186.96
const FULL = preload("res://assets/audio/hail-and-welcome/full.ogg")
const INSTRUMENTAL = preload("res://assets/audio/hail-and-welcome/instrumental.ogg")
const VOCAL = preload("res://assets/audio/hail-and-welcome/vocal.ogg")
var muted := false
var vocals_enabled := true
var subtitles_enabled := true
var settings_path := "user://music_settings.cfg"
var cues: Array = []
var synchronized := AudioStreamSynchronized.new()

## Duplicate imported streams before enabling loops; keep both mixes on one audio clock.
func _ready() -> void:
	var settings := ConfigFile.new()
	if settings.load(settings_path) == OK:
		vocals_enabled = bool(settings.get_value("music", "vocals", true))
		subtitles_enabled = bool(settings.get_value("music", "subtitles", true))
		muted = bool(settings.get_value("music", "muted", false))
	cues = JSON.parse_string(FileAccess.get_file_as_string("res://data/music/hail-and-welcome/subtitles.json"))
	synchronized.stream_count = 2
	for mix_index in range(2):
		var looping_track: AudioStreamOggVorbis = [FULL, INSTRUMENTAL][mix_index].duplicate()
		looping_track.loop = true
		synchronized.set_sync_stream(mix_index, looping_track)
	stream = synchronized
	apply_mix()

## Select exactly one complete mix. The isolated vocal asset is retained for production.
func apply_mix() -> void:
	# Never add the vocal stem to the full mix: it would double the singer.
	synchronized.set_sync_stream_volume(0, 0.0 if vocals_enabled else -80.0)
	synchronized.set_sync_stream_volume(1, -80.0 if vocals_enabled else 0.0)
	volume_db = -80.0 if muted else -8.0

func save_settings() -> void:
	var settings := ConfigFile.new()
	settings.set_value("music", "vocals", vocals_enabled)
	settings.set_value("music", "subtitles", subtitles_enabled)
	settings.set_value("music", "muted", muted)
	settings.save(settings_path)

func toggle_vocals() -> void:
	vocals_enabled = not vocals_enabled
	apply_mix()
	save_settings()

func toggle_subtitles() -> void:
	subtitles_enabled = not subtitles_enabled
	save_settings()

func toggle_mute() -> void:
	muted = not muted
	apply_mix()
	save_settings()

## Leaving stops playback; returning starts the recording from its beginning.
func set_tavern(active: bool) -> void:
	if active and not playing:
		play()
	if not active and playing:
		stop()

## Correct the audio playhead for mixer timing/output latency, then wrap at the recording length.
func song_time() -> float:
	if not playing:
		return 0.0
	return fposmod(maxf(0.0, get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()), LENGTH)

## Cue intervals are start-inclusive and end-exclusive; gaps deliberately display no text.
func subtitle_at(playback_seconds: float) -> String:
	if not subtitles_enabled:
		return ""
	for cue in cues:
		if playback_seconds >= float(cue.start) and playback_seconds < float(cue.end):
			return str(cue.text)
	return ""

func current_subtitle() -> String:
	return subtitle_at(song_time()) if playing else ""
