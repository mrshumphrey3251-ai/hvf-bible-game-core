extends Node
class_name SovereignMultiplayerClient

signal peers_updated(peers: Array, online_count: int, chat_log: Array)

var host: String = "127.0.0.1"
var port: int = 65432
var player_id: String = ""
var player_name: String = "Pilgrim"
var current_stage: String = "ERA_TORAH"
var pos_x: float = 220.0
var pos_y: float = 145.0
var sync_timer: float = 0.0
var sync_interval: float = 0.65
var dirty_pos: bool = true

func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var suffix: int = rng.randi_range(1000, 9999)
	player_id = "PILGRIM_%d" % suffix
	player_name = "Pilgrim-%d" % suffix
	set_process(true)

func update_local_state(stage_id: String, x: float, y: float) -> void:
	current_stage = stage_id
	pos_x = x
	pos_y = y
	dirty_pos = true

func send_fellowship_chat(msg: String) -> void:
	var clean: String = msg.strip_edges()
	if clean == "":
		return
	_send_sync_packet("MULTIPLAYER_CHAT", clean)

func _process(delta: float) -> void:
	sync_timer += delta
	if sync_timer >= sync_interval or (dirty_pos and sync_timer >= 0.25):
		sync_timer = 0.0
		dirty_pos = false
		_send_sync_packet("MULTIPLAYER_SYNC", "")

func _send_sync_packet(action_name: String, chat_msg: String) -> void:
	var peer: StreamPeerTCP = StreamPeerTCP.new()
	var err: Error = peer.connect_to_host(host, port)
	if err != OK:
		return
	peer.poll()
	var spins: int = 0
	while peer.get_status() == StreamPeerTCP.STATUS_CONNECTING and spins < 12:
		peer.poll()
		spins += 1
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		peer.disconnect_from_host()
		return

	var req: Dictionary = {
		"client_type": "GODOT_MP_CLIENT",
		"action": action_name,
		"player_id": player_id,
		"name": player_name,
		"stage": current_stage,
		"x": pos_x,
		"y": pos_y,
		"message": chat_msg
	}
	var raw_line: String = JSON.stringify(req) + "\n"
	peer.put_data(raw_line.to_utf8_buffer())
	peer.poll()

	var resp_buf: PackedByteArray = PackedByteArray()
	var read_spins: int = 0
	while read_spins < 20:
		peer.poll()
		var avail: int = peer.get_available_bytes()
		if avail > 0:
			var chunk: Array = peer.get_data(avail)
			if int(chunk[0]) == OK:
				resp_buf.append_array(chunk[1])
				if resp_buf.get_string_from_utf8().find("\n") != -1:
					break
		read_spins += 1
	peer.disconnect_from_host()

	var text: String = resp_buf.get_string_from_utf8().strip_edges()
	if text == "":
		return
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var d: Dictionary = parsed
		if str(d.get("status", "")) == "OK":
			var peers_arr: Array = d.get("peers", [])
			var online_cnt: int = int(d.get("online_count", 1))
			var chat_arr: Array = d.get("chat_log", [])
			emit_signal("peers_updated", peers_arr, online_cnt, chat_arr)
