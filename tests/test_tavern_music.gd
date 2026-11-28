extends SceneTree
const Music = preload("res://scripts/tavern_music.gd")
var failures := 0

func check(ok: bool, text: String) -> void:
	if not ok:
		failures += 1
		push_error(text)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var music = Music.new()
	music.settings_path = "user://test_music_options.cfg"
	DirAccess.remove_absolute(music.settings_path)
	root.add_child(music)
	check(music.synchronized.stream_count == 2, "Both approved mixes share a clock")
	for track in [Music.FULL, Music.INSTRUMENTAL, Music.VOCAL]:
		check(absf(track.get_length() - Music.LENGTH) < 0.03, "All three assets preserve matching duration")
	check(music.vocals_enabled and music.subtitles_enabled, "Default vocals and subtitles enabled")
	music.set_tavern(true)
	await create_timer(0.35).timeout
	check(music.playing and music.song_time() > 0.1, "Song clock advances")
	music.seek(60.0)
	await create_timer(0.1).timeout
	var before: float = music.song_time()
	music.toggle_vocals()
	await create_timer(0.1).timeout
	check(music.song_time() >= before - 0.05 and music.song_time() < before + 0.5, "Vocal switch preserves playhead")
	check(music.synchronized.get_sync_stream_volume(0) <= -80 and music.synchronized.get_sync_stream_volume(1) == 0, "Instrumental only, without double mixing")
	check(music.subtitles_enabled, "Vocal toggle leaves subtitles enabled")
	music.seek(Music.LENGTH - 0.15)
	await create_timer(0.4).timeout
	check(music.playing and music.song_time() < 1.0, "Complete recording loops on the shared clock")
	check(music.cues.size() == 34, "Revised performance has cues for all supplied lyric lines")
	check(music.subtitle_at(63.0) == "Hail and welcome traveler", "Restored second chorus has revised timing")
	var last_end := 0.0
	for cue in music.cues:
		check(float(cue.start) >= last_end and float(cue.end) > float(cue.start) and float(cue.end) <= Music.LENGTH, "Ordered nonoverlapping cues within track")
		check(music.subtitle_at((float(cue.start) + float(cue.end)) / 2) == cue.text, "Cue resolves from playback time")
		last_end = float(cue.end)
	music.toggle_subtitles()
	check(music.subtitle_at(25) == "", "Subtitle off hides words")
	music.toggle_mute()
	check(music.playing and music.volume_db <= -80, "Mute keeps clock running")
	music.set_tavern(false)
	check(not music.playing and music.current_subtitle() == "", "Leaving stops audio and subtitles")
	music.set_tavern(true)
	check(music.playing and music.song_time() < 1, "Returning starts song at beginning")
	var restored = Music.new()
	restored.settings_path = music.settings_path
	root.add_child(restored)
	check(not restored.vocals_enabled and not restored.subtitles_enabled and restored.muted, "Preferences persist independently of journey saves")
	music.stop()
	music.stream = null
	restored.stream = null
	await create_timer(0.3).timeout
	music.queue_free()
	restored.queue_free()
	await process_frame
	await process_frame
	DirAccess.remove_absolute("user://test_music_options.cfg")
	print("Approved song, synchronized modes, captions and preferences: ", "PASS" if failures == 0 else "FAIL")
	quit(failures)
