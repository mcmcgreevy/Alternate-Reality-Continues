extends AudioStreamPlayer
## Original three-voice chiptune. Pulse lead, triangle bass, pulse arpeggio.
## This evokes SID timbres; it does not emulate a SID or replay original music.
const RATE := 22050
const LENGTH := 16.0
const LYRICS = ["Raise a light beside the door,", "Keep a place for one friend more.", "Down below, where shadows roam,", "Leave a light to guide us home."]
var muted := false

func _ready() -> void:
	var pcm := PackedByteArray()
	pcm.resize(int(RATE * LENGTH) * 2)
	var melody := [64, 67, 69, 67, 64, 62, 60, 62, 64, 67, 72, 71, 69, 67, 64, 62, 60, 64, 67, 69, 67, 64, 62, 60, 62, 64, 67, 62, 60, 59, 60, 60]
	var roots := [48, 45, 53, 43]
	for i in range(int(RATE * LENGTH)):
		var t := float(i) / RATE
		var beat := int(t / 0.5)
		var envelope := minf(fmod(t, 0.5) * 60.0, 1.0) * maxf(0.0, 1.0 - fmod(t, 0.5) / 0.5)
		var lead_phase := fmod(t * hz(melody[beat]), 1.0)
		var lead := (1.0 if lead_phase < 0.25 else -1.0) * envelope
		var root: int = roots[int(t / 4.0)]
		var bass := 1.0 - 4.0 * absf(fmod(t * hz(root - 12), 1.0) - 0.5)
		var chord: int = [0, 4, 7][int(t * 8.0) % 3]
		var arp := (1.0 if fmod(t * hz(root + chord), 1.0) < 0.5 else -1.0) * 0.18
		var fade := minf(t * 100.0, 1.0) * minf((LENGTH - t) * 100.0, 1.0)
		pcm.encode_s16(i * 2, int((lead * 0.24 + bass * 0.20 + arp) * fade * 22000.0))
	var cue := AudioStreamWAV.new()
	cue.format = AudioStreamWAV.FORMAT_16_BITS
	cue.mix_rate = RATE
	cue.data = pcm
	cue.loop_mode = AudioStreamWAV.LOOP_FORWARD
	cue.loop_end = int(RATE * LENGTH)
	stream = cue
	volume_db = -12.0

func hz(note: int) -> float:
	return 440.0 * pow(2.0, (note - 69) / 12.0)

func set_tavern(active: bool) -> void:
	if active and not playing: play()
	if not active and playing: stop()

func song_time() -> float:
	if not playing: return 0.0
	return fposmod(maxf(0.0, get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()), LENGTH)

func toggle_mute() -> void:
	muted = not muted
	volume_db = -80.0 if muted else -12.0
