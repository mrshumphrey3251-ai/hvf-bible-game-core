extends Node

var player: AudioStreamPlayer
var generator: AudioStreamGenerator
var sample_rate: float = 22050.0
var muted: bool = false
var note_queue: Array = []
var active_freq: float = 0.0
var active_remaining: int = 0
var active_total: int = 1
var phase: float = 0.0

func _ready() -> void:
	player = AudioStreamPlayer.new()
	generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.15
	player.stream = generator
	player.volume_db = -8.0
	add_child(player)
	player.play()
	set_process(true)

func toggle_mute() -> bool:
	muted = not muted
	if muted:
		note_queue.clear()
		active_remaining = 0
	return muted

func play_harp_chime() -> void:
	_enqueue_notes([[523.25, 0.11], [659.25, 0.13], [783.99, 0.18]])

func play_upgrade_fanfare() -> void:
	_enqueue_notes([[392.00, 0.12], [493.88, 0.12], [587.33, 0.14], [783.99, 0.24]])

func play_campaign_victory() -> void:
	_enqueue_notes([[293.66, 0.14], [440.00, 0.14], [587.33, 0.16], [739.99, 0.16], [880.00, 0.30]])

func play_commander_horn() -> void:
	_enqueue_notes([[220.00, 0.14], [329.63, 0.16], [440.00, 0.24]])

func play_reflection_tone() -> void:
	_enqueue_notes([[329.63, 0.16], [293.66, 0.22]])

func _enqueue_notes(seq: Array) -> void:
	if muted:
		return
	for item in seq:
		note_queue.append(item)

func _process(_delta: float) -> void:
	if muted or player == null:
		return
	if not player.playing:
		player.play()
	var pb = player.get_stream_playback()
	if pb == null or not (pb is AudioStreamGeneratorPlayback):
		return
	var frames_avail: int = pb.get_frames_available()
	while frames_avail > 0:
		if active_remaining <= 0:
			if note_queue.is_empty():
				active_freq = 0.0
				pb.push_frame(Vector2.ZERO)
				frames_avail -= 1
				continue
			var nxt: Array = note_queue.pop_front()
			active_freq = float(nxt[0])
			active_total = max(1, int(float(nxt[1]) * sample_rate))
			active_remaining = active_total
		var progress: float = 1.0 - (float(active_remaining) / float(active_total))
		var env: float = sin(minf(1.0, progress * 8.0) * PI * 0.5) * exp(-progress * 3.2)
		var sample_val: float = (sin(phase * TAU) + 0.35 * sin(phase * 2.0 * TAU)) * env * 0.28
		phase = fmod(phase + (active_freq / sample_rate), 1.0)
		pb.push_frame(Vector2(sample_val, sample_val))
		active_remaining -= 1
		frames_avail -= 1
