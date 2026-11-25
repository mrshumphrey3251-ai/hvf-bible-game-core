extends Control
class_name OmniBridgeClient

signal handshake_verified(state_data: Dictionary)
signal scenario_loaded(scenario_data: Dictionary)
signal decision_resolved(outcome_data: Dictionary, state_data: Dictionary)
signal bloodline_updated(bloodline_data: Dictionary)
signal stronghold_updated(stronghold_data: Dictionary)
signal generals_updated(generals_data: Dictionary)
signal alpha_omega_looped(bloodline_data: Dictionary)
signal perpetual_trial_resolved(trial_result: Dictionary)
signal bridge_error(message: String)

@export var host: String = "127.0.0.1"
@export var port: int = 65432

@onready var audio_synth = $AudioSynth
@onready var status_label: Label = $MarginContainer/ScrollContainer/VBox/HeaderPanel/HeaderVBox/StatusLabel
@onready var telemetry_label: Label = $MarginContainer/ScrollContainer/VBox/HeaderPanel/HeaderVBox/TelemetryLabel
@onready var bloodline_label: Label = $MarginContainer/ScrollContainer/VBox/HeaderPanel/HeaderVBox/BloodlineLabel
@onready var citadel_canvas = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CitadelCanvas
@onready var stronghold_header_label: Label = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/StrongholdHeaderLabel
@onready var resources_label: Label = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/ResourcesLabel
@onready var commanders_label: Label = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CommandersLabel
@onready var collect_tribute_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/StrongholdActionsHBox/CollectTributeBtn
@onready var upgrade_keep_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/StrongholdActionsHBox/UpgradeKeepBtn
@onready var conquer_chapter_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/StrongholdActionsHBox/ConquerChapterBtn
@onready var moses_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CommandersHBox/MosesBtn
@onready var joshua_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CommandersHBox/JoshuaBtn
@onready var deborah_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CommandersHBox/DeborahBtn
@onready var david_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CommandersHBox/DavidBtn
@onready var paul_btn: Button = $MarginContainer/ScrollContainer/VBox/StrongholdPanel/StrongholdVBox/CommandersHBox/PaulBtn
@onready var context_label: RichTextLabel = $MarginContainer/ScrollContainer/VBox/BodyPanel/BodyVBox/ContextLabel
@onready var outcome_label: RichTextLabel = $MarginContainer/ScrollContainer/VBox/BodyPanel/BodyVBox/OutcomeLabel
@onready var option_a_btn: Button = $MarginContainer/ScrollContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionABtn
@onready var option_b_btn: Button = $MarginContainer/ScrollContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionBBtn
@onready var option_c_btn: Button = $MarginContainer/ScrollContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionCBtn
@onready var option_d_btn: Button = $MarginContainer/ScrollContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionDBtn
@onready var connect_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/ConnectBtn
@onready var next_scenario_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/NextScenarioBtn
@onready var trial_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/TrialBtn
@onready var handoff_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/HandoffBtn
@onready var advance_era_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/AdvanceEraBtn
@onready var save_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/SaveBtn
@onready var export_transcript_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/ExportTranscriptBtn
@onready var mute_audio_btn: Button = $MarginContainer/ScrollContainer/VBox/FooterGrid/MuteAudioBtn

const ERA_SCENARIO_MAP := {
	"ERA_TORAH": "GEN_001",
	"ERA_HISTORY": "HIS_001",
	"ERA_WISDOM": "WIS_001",
	"ERA_PROPHETS": "PRO_001",
	"ERA_GOSPELS": "GOS_001",
	"ERA_EPISTLES": "EPI_001"
}

const ERA_SCENARIO_ROSTER := {
	"ERA_TORAH": ["GEN_001", "TOR_002", "TOR_003", "TOR_004", "TOR_005"],
	"ERA_HISTORY": ["HIS_001", "HIS_002", "HIS_003", "HIS_004", "HIS_005"],
	"ERA_WISDOM": ["WIS_001", "WIS_002", "WIS_003", "WIS_004"],
	"ERA_PROPHETS": ["PRO_001", "PRO_002", "PRO_003", "PRO_004"],
	"ERA_GOSPELS": ["GOS_001", "GOS_002", "GOS_003", "GOS_004"],
	"ERA_EPISTLES": ["EPI_001", "EPI_002", "EPI_003", "EPI_004"]
}

var current_scenario: Dictionary = {}
var current_trial: Dictionary = {}
var active_trial_token: String = ""
var trial_mode: bool = false
var cached_total_score: int = 0
var cached_current_era: String = "ERA_TORAH"
var last_stronghold_snapshot: Dictionary = {}
var last_generals_snapshot: Dictionary = {}
var era_scenario_cursor: int = 0
var cached_cmd_bonus: int = 0
var next_campaign_id: String = "CH_01_MAMRE"
const OfflineMirrorScript = preload("res://scripts/sovereign_offline_mirror.gd")
var offline_mirror = OfflineMirrorScript.new()
var using_offline_mirror: bool = false


func _apply_royal_theme() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.08, 0.11, 0.96)
	panel_style.border_color = Color(0.84, 0.68, 0.28, 0.85)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(10)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.18, 0.14, 0.10, 1.0)
	btn_style.border_color = Color(0.84, 0.68, 0.28, 0.9)
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(4)
	btn_style.set_content_margin_all(6)
	var t := Theme.new()
	t.set_stylebox("panel", "PanelContainer", panel_style)
	t.set_stylebox("normal", "Button", btn_style)
	ThemeDB.fallback_base_scale = 1.0
	self.theme = t

func _ready() -> void:
	_apply_royal_theme()
	connect_btn.pressed.connect(_on_connect_pressed)
	next_scenario_btn.pressed.connect(_on_next_scenario_pressed)
	trial_btn.pressed.connect(_on_toggle_trial_mode)
	handoff_btn.pressed.connect(_on_handoff_pressed)
	advance_era_btn.pressed.connect(_on_advance_era_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	export_transcript_btn.pressed.connect(_on_export_transcript_pressed)
	mute_audio_btn.pressed.connect(_on_mute_audio_pressed)
	collect_tribute_btn.pressed.connect(_on_collect_tribute_pressed)
	upgrade_keep_btn.pressed.connect(_on_upgrade_keep_pressed)
	conquer_chapter_btn.pressed.connect(_on_conquer_chapter_pressed)
	moses_btn.pressed.connect(func() -> void: _on_appoint_general_pressed("MOSES", "sanctuary_keep"))
	joshua_btn.pressed.connect(func() -> void: _on_appoint_general_pressed("JOSHUA", "campaign_vanguard"))
	deborah_btn.pressed.connect(func() -> void: _on_appoint_general_pressed("DEBORAH", "watchtower"))
	david_btn.pressed.connect(func() -> void: _on_appoint_general_pressed("DAVID", "rampart_walls"))
	paul_btn.pressed.connect(func() -> void: _on_appoint_general_pressed("PAUL", "scriptorium"))
	option_a_btn.pressed.connect(func() -> void: _handle_option_press(0))
	option_b_btn.pressed.connect(func() -> void: _handle_option_press(1))
	option_c_btn.pressed.connect(func() -> void: _handle_option_press(2))
	option_d_btn.pressed.connect(func() -> void: _handle_option_press(3))
	_set_options_enabled(false)
	_on_connect_pressed()

	# Phase 32: Mount Interactive 6-Stage Walkable World & NPC Dialogue Stage
	var world_script = load("res://scripts/sovereign_world_stage.gd")
	if world_script != null:
		var world_stage = world_script.new()
		world_stage.name = "WalkableWorldStage"
		var root_vbox = get_node_or_null("RootScroll/MainVBox")
		if root_vbox != null:
			root_vbox.add_child(world_stage)
			root_vbox.move_child(world_stage, 1)
			world_stage.set_stage("ERA_TORAH")
			world_stage.npc_dialogue_triggered.connect(func(npc_name: String, era_id: String, scenario_id: String, greeting: String):
				if audio_synth != null and audio_synth.has_method("play_covenant_chime"):
					audio_synth.play_covenant_chime()
				var feed = get_node_or_null("RootScroll/MainVBox/ChronicleScroll/ChronicleFeed")
				if feed != null:
					feed.text = "[b][color=#f5d061]%s[/color][/b]\n%s\n\n[i]Loading Canonical Trial (%s)...[/i]" % [npc_name, greeting, scenario_id]
				if has_method("_request_scenario"):
					call("_request_scenario", scenario_id)
			)
			world_stage.stage_portal_entered.connect(func(target_era_id: String):
				if audio_synth != null and audio_synth.has_method("play_covenant_chime"):
					audio_synth.play_covenant_chime()
				var feed = get_node_or_null("RootScroll/MainVBox/ChronicleScroll/ChronicleFeed")
				if feed != null:
					feed.text = "[b][color=#7de2d1]PORTAL TRANSITION:[/color][/b] Entered [b]%s[/b]. Walk to a Biblical NPC and press [E] to converse!" % target_era_id
			)

	# Phase 33: Attach Real-Time Multiplayer Pilgrim Sync & Fellowship Chat
	var mp_script = load("res://scripts/sovereign_multiplayer_client.gd")
	if mp_script != null:
		var mp_client = mp_script.new()
		mp_client.name = "MultiplayerRelayClient"
		add_child(mp_client)
		var w_node = get_node_or_null("RootScroll/MainVBox/WalkableWorldStage")
		if w_node != null:
			w_node.player_moved.connect(func(stage_id: String, px: float, py: float):
				mp_client.update_local_state(stage_id, px, py)
			)
			w_node.stage_portal_entered.connect(func(target_era_id: String):
				mp_client.update_local_state(target_era_id, 410.0, 148.0)
			)
			mp_client.peers_updated.connect(func(peers: Array, online_cnt: int, chat_log: Array):
				w_node.set_remote_pilgrims(peers)
			)
		# Phase 34: Interactive Pilgrim Name, Online Counter & Fellowship Chat Bar
		var root_vbox_mp = get_node_or_null("RootScroll/MainVBox")
		if root_vbox_mp != null:
			var mp_bar: HBoxContainer = HBoxContainer.new()
			mp_bar.name = "FellowshipBar"
			mp_bar.add_theme_constant_override("separation", 6)

			var online_lbl: Label = Label.new()
			online_lbl.name = "OnlinePilgrimsLabel"
			online_lbl.text = "Online: 1"
			online_lbl.add_theme_color_override("font_color", Color(0.45, 0.92, 0.65))
			mp_bar.add_child(online_lbl)

			var name_edit: LineEdit = LineEdit.new()
			name_edit.name = "PilgrimNameInput"
			name_edit.placeholder_text = "Your Pilgrim Name..."
			name_edit.text = mp_client.player_name
			name_edit.custom_minimum_size = Vector2(130, 0)
			name_edit.text_submitted.connect(func(new_name: String):
				var clean_n: String = new_name.strip_edges()
				if clean_n != "":
					mp_client.player_name = clean_n
					mp_client.dirty_pos = true
					w_node.set_local_pilgrim_name(clean_n)
			)
			mp_bar.add_child(name_edit)
			var robe_picker: OptionButton = OptionButton.new()
			robe_picker.name = "RobeColorPicker"
			for r_opt in ["Sapphire", "Judah Gold", "Emerald", "Tyrian Purple", "Crimson", "Galilee Cyan"]:
				robe_picker.add_item(r_opt)
			robe_picker.item_selected.connect(func(idx: int):
				var chosen: String = robe_picker.get_item_text(idx)
				mp_client.robe_name = chosen
				mp_client.dirty_pos = true
				w_node.set_local_robe_color(chosen)
			)
			mp_bar.add_child(robe_picker)


			var chat_edit: LineEdit = LineEdit.new()
			chat_edit.name = "FellowshipChatInput"
			chat_edit.placeholder_text = "Speak peace to fellow pilgrims across stages..."
			chat_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var send_chat_fn: Callable = func(txt: String):
				var msg_clean: String = txt.strip_edges()
				if msg_clean != "":
					var cur_name: String = name_edit.text.strip_edges()
					if cur_name != "":
						mp_client.player_name = cur_name
						w_node.set_local_pilgrim_name(cur_name)
					mp_client.send_fellowship_chat(msg_clean)
					chat_edit.text = ""
			chat_edit.text_submitted.connect(send_chat_fn)
			mp_bar.add_child(chat_edit)

			var send_btn: Button = Button.new()
			send_btn.text = "Send Peace"
			send_btn.pressed.connect(func():
				send_chat_fn.call(chat_edit.text)
			)
			mp_bar.add_child(send_btn)

			var chat_feed_lbl: Label = Label.new()
			chat_feed_lbl.name = "FellowshipLiveFeed"
			chat_feed_lbl.text = "Room Ready ? Move with WASD/Click or speak with Biblical NPCs!"
			chat_feed_lbl.add_theme_color_override("font_color", Color(0.86, 0.92, 0.98))

			root_vbox_mp.add_child(mp_bar)
			root_vbox_mp.move_child(mp_bar, 2)
			root_vbox_mp.add_child(chat_feed_lbl)
			root_vbox_mp.move_child(chat_feed_lbl, 3)

			w_node.set_local_pilgrim_name(mp_client.player_name)
			mp_client.peers_updated.connect(func(peers: Array, online_cnt: int, chat_log: Array):
				online_lbl.text = "Online: %d" % online_cnt
				if chat_log.size() > 0:
					var last_msg: Dictionary = chat_log[chat_log.size() - 1]
					var l_txt: String = str(last_msg.get("message", ""))
					chat_feed_lbl.text = "[%s @ %s]: %s" % [str(last_msg.get("sender", "Pilgrim")), str(last_msg.get("stage", "ERA_TORAH")), l_txt]
					if l_txt.begins_with("COVENANT BLESSING:"):
						w_node.show_coop_blessing(l_txt)
			)


func _send_command(payload: Dictionary) -> Dictionary:
	var peer := StreamPeerTCP.new()
	var err := peer.connect_to_host(host, port)
	if err != OK:
		using_offline_mirror = true
		return offline_mirror.dispatch(payload)
	var deadline := Time.get_ticks_msec() + 2000
	while Time.get_ticks_msec() < deadline:
		peer.poll()
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			break
		OS.delay_msec(10)
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		peer.disconnect_from_host()
		using_offline_mirror = true
		return offline_mirror.dispatch(payload)
	using_offline_mirror = false
	var wire := JSON.stringify(payload) + "\n"
	peer.put_data(wire.to_utf8_buffer())
	var raw := ""
	deadline = Time.get_ticks_msec() + 3000
	while Time.get_ticks_msec() < deadline:
		peer.poll()
		var avail := peer.get_available_bytes()
		if avail > 0:
			var res := peer.get_utf8_string(avail)
			raw += res
			if raw.find("\n") != -1:
				break
		OS.delay_msec(10)
	peer.disconnect_from_host()
	if raw.is_empty():
		return {"status": "ERROR", "error": "Empty response from OmniDispatcher."}
	var parsed = JSON.parse_string(raw.strip_edges())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"status": "ERROR", "error": "Malformed JSON from OmniDispatcher."}
	return parsed

func _on_connect_pressed() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "HANDSHAKE"})
	if resp.get("status") != "CONNECTED":
		var err_msg: String = str(resp.get("error", "Connection failed"))
		status_label.text = "BRIDGE STATUS: OFFLINE (%s)" % err_msg
		bridge_error.emit(err_msg)
		return
	var state: Dictionary = resp.get("state", {})
	status_label.text = "BRIDGE STATUS: STANDALONE MULTI-DEVICE MIRROR (SHA-256 ACTIVE)" if using_offline_mirror else ("BRIDGE STATUS: CONNECTED & VERIFIED (GODOT_4 -> %s:%d)" % [host, port])
	_update_telemetry(state)
	if resp.has("generals") and typeof(resp["generals"]) == TYPE_DICTIONARY:
		_update_generals_telemetry(resp["generals"])
	else:
		_refresh_generals()
	if resp.has("stronghold") and typeof(resp["stronghold"]) == TYPE_DICTIONARY:
		_update_stronghold_telemetry(resp["stronghold"])
	else:
		_refresh_stronghold()
	handshake_verified.emit(state)
	_refresh_bloodline()
	var era_name: String = str(state.get("current_era", "ERA_TORAH"))
	trial_mode = false
	trial_btn.text = "Perpetual Scripture Trial"
	_load_active_scenario(ERA_SCENARIO_MAP.get(era_name, "GEN_001"))

func _refresh_stronghold() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "GET_STRONGHOLD"})
	if resp.get("status") == "OK":
		if resp.has("generals") and typeof(resp["generals"]) == TYPE_DICTIONARY:
			_update_generals_telemetry(resp["generals"])
		var sh: Dictionary = resp.get("stronghold", {})
		_update_stronghold_telemetry(sh)
		stronghold_updated.emit(sh)

func _refresh_generals() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "GET_GENERALS"})
	if resp.get("status") == "OK":
		var gen: Dictionary = resp.get("generals", {})
		_update_generals_telemetry(gen)
		generals_updated.emit(gen)

func _on_appoint_general_pressed(general_id: String, slot: String) -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "APPOINT_GENERAL",
		"general_id": general_id,
		"slot": slot
	})
	if resp.get("status") == "OK":
		var gen: Dictionary = resp.get("generals", {})
		_update_generals_telemetry(gen)
		generals_updated.emit(gen)
		if resp.has("stronghold") and typeof(resp["stronghold"]) == TYPE_DICTIONARY:
			_update_stronghold_telemetry(resp["stronghold"])
		else:
			_refresh_stronghold()
		var syn_tag := " (+25% PREFERRED POST SYNERGY!)" if resp.get("specialty_synergy", false) else ""
		if audio_synth and audio_synth.has_method("play_commander_horn"):
			audio_synth.play_commander_horn()
		outcome_label.text = "[b][COMMANDER APPOINTED: %s -> %s][/b]%s | Total Commander Bonus: +%s" % [
			str(resp.get("general_name", general_id)),
			slot.to_upper(),
			syn_tag,
			str(resp.get("command_power_bonus", 0))
		]
	else:
		outcome_label.text = "[b][APPOINTMENT NOTICE][/b] %s" % str(resp.get("message", resp.get("error", "Failed")))

func _on_collect_tribute_pressed() -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "COLLECT_TRIBUTE",
		"total_score": cached_total_score
	})
	if resp.get("status") == "OK":
		var gained: Dictionary = resp.get("gained", {})
		var sh: Dictionary = resp.get("stronghold", {})
		_update_stronghold_telemetry(sh)
		stronghold_updated.emit(sh)
		if audio_synth and audio_synth.has_method("play_harp_chime"):
			audio_synth.play_harp_chime()
		outcome_label.text = "[b][COVENANT TRIBUTE COLLECTED][/b] +Provision: %s | +Timber: %s | +Stone: %s | +Talents: %s" % [
			str(gained.get("provision", 0)),
			str(gained.get("timber", 0)),
			str(gained.get("stone", 0)),
			str(gained.get("talents", 0))
		]
	else:
		outcome_label.text = "[b][STRONGHOLD NOTICE][/b] %s" % str(resp.get("message", resp.get("error", "Action failed")))

func _on_upgrade_keep_pressed() -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "UPGRADE_BUILDING",
		"building_id": "sanctuary_keep"
	})
	if resp.get("status") == "OK":
		var sh: Dictionary = resp.get("stronghold", {})
		_update_stronghold_telemetry(sh)
		stronghold_updated.emit(sh)
		if audio_synth and audio_synth.has_method("play_upgrade_fanfare"):
			audio_synth.play_upgrade_fanfare()
		outcome_label.text = "[b][SANCTUARY KEEP UPGRADED TO LEVEL %s][/b] Base Stronghold Power now %s!" % [
			str(resp.get("new_level", 1)),
			str(sh.get("dynasty_power", 1000))
		]
	else:
		outcome_label.text = "[b][UPGRADE BLOCKED][/b] %s" % str(resp.get("message", resp.get("error", "Insufficient resources")))

func _on_conquer_chapter_pressed() -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "CONQUER_CAMPAIGN_CHAPTER",
		"chapter_id": next_campaign_id
	})
	if resp.get("status") == "OK":
		var ch: Dictionary = resp.get("conquered", {})
		var sh: Dictionary = resp.get("stronghold", {})
		_update_stronghold_telemetry(sh)
		stronghold_updated.emit(sh)
		if audio_synth and audio_synth.has_method("play_campaign_victory"):
			audio_synth.play_campaign_victory()
		outcome_label.text = "[b][CAMPAIGN VICTORY: %s][/b] Base Power now %s | Spoils added to Stronghold treasury!" % [
			str(ch.get("title", next_campaign_id)),
			str(sh.get("dynasty_power", 1000))
		]
	else:
		outcome_label.text = "[b][CAMPAIGN HALTED][/b] %s" % str(resp.get("message", resp.get("error", "Requirements unmet")))

func _refresh_bloodline() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "GET_BLOODLINE"})
	if resp.get("status") == "OK":
		var bl: Dictionary = resp.get("bloodline", {})
		_update_bloodline_telemetry(bl)
		bloodline_updated.emit(bl)


func _on_next_scenario_pressed() -> void:
	trial_mode = false
	trial_btn.text = "Perpetual Scripture Trial"
	var roster: Array = ERA_SCENARIO_ROSTER.get(cached_current_era, ["GEN_001"])
	era_scenario_cursor = (era_scenario_cursor + 1) % roster.size()
	var target_id: String = str(roster[era_scenario_cursor])
	_load_active_scenario(target_id)
	outcome_label.text = "[b][ERA SCENARIO ROTATED (%d/%d)][/b] Loaded %s in %s." % [
		era_scenario_cursor + 1,
		roster.size(),
		target_id,
		cached_current_era
	]

func _on_toggle_trial_mode() -> void:
	trial_mode = not trial_mode
	if trial_mode:
		trial_btn.text = "Return to Executive Scenario"
		_load_perpetual_trial()
	else:
		trial_btn.text = "Perpetual Scripture Trial"
		var era_id: String = str(current_scenario.get("id", "GEN_001"))
		_load_active_scenario(era_id)

func _load_perpetual_trial() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "GET_PERPETUAL_TRIAL"})
	if resp.get("status") != "OK":
		context_label.text = "[b]Perpetual Trial Error:[/b] %s" % str(resp.get("error", "Unknown"))
		return
	active_trial_token = str(resp.get("trial_token", ""))
	current_trial = resp.get("trial", {})
	var opts: Array = current_trial.get("options", [])
	context_label.text = "[b][%s | %s | %s][/b]\n\n[i]%s[/i]" % [
		str(current_trial.get("tier_label", "TIER_1")),
		str(current_trial.get("era", "")),
		str(current_trial.get("reference", "")),
		str(current_trial.get("prompt", ""))
	]
	var btns := [option_a_btn, option_b_btn, option_c_btn, option_d_btn]
	for i in range(4):
		if i < opts.size():
			btns[i].visible = true
			btns[i].disabled = false
			btns[i].text = "%d. %s" % [i + 1, str(opts[i])]
		else:
			btns[i].visible = false

func _load_active_scenario(scenario_id: String) -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "GET_SCENARIO", "scenario_id": scenario_id})
	if resp.get("status") != "OK":
		context_label.text = "[b]Scenario Error:[/b] %s" % str(resp.get("error", "Unknown"))
		return
	current_scenario = resp.get("scenario", {})
	var opts: Array = current_scenario.get("options", [])
	context_label.text = "[b][%s | %s][/b]\n%s\n\n[i]%s[/i]" % [
		str(current_scenario.get("id", "")),
		str(current_scenario.get("era", "")),
		str(current_scenario.get("context", "")),
		str(current_scenario.get("prompt", ""))
	]
	var btns := [option_a_btn, option_b_btn, option_c_btn, option_d_btn]
	for i in range(4):
		if i < opts.size():
			btns[i].visible = true
			btns[i].disabled = false
			btns[i].text = "%d. %s" % [i + 1, str(opts[i].get("text", "Option"))]
		else:
			btns[i].visible = false
	scenario_loaded.emit(current_scenario)

func _handle_option_press(option_index: int) -> void:
	if trial_mode:
		_submit_perpetual_trial(option_index)
	else:
		_submit_decision(option_index)

func _submit_perpetual_trial(answer_index: int) -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "SUBMIT_PERPETUAL_TRIAL",
		"trial_token": active_trial_token,
		"answer_index": answer_index
	})
	if resp.get("status") != "OK":
		outcome_label.text = "[b]Trial Error:[/b] %s" % str(resp.get("error", "Unknown"))
		return
	var state: Dictionary = resp.get("state", {})
	_update_telemetry(state)
	if resp.get("correct", false):
		if audio_synth and audio_synth.has_method("play_harp_chime"):
			audio_synth.play_harp_chime()
		outcome_label.text = "[b][MASTERY VERIFIED: %s -> ESCALATED TO %s][/b]\n%s" % [
			str(resp.get("reference", "")),
			str(resp.get("next_tier_label", "")),
			str(resp.get("explanation", ""))
		]
	else:
		outcome_label.text = "[b][SPACED REPETITION REINFORCEMENT: %s][/b]\n%s" % [
			str(resp.get("reference", "")),
			str(resp.get("explanation", ""))
		]
	perpetual_trial_resolved.emit(resp)
	_load_perpetual_trial()

func _submit_decision(option_index: int) -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "RESOLVE_DECISION",
		"scenario_id": current_scenario.get("id", "GEN_001"),
		"option_index": option_index
	})
	if resp.get("status") != "OK":
		outcome_label.text = "[b]Resolution Error:[/b] %s" % str(resp.get("error", "Unknown"))
		return
	var outcome: Dictionary = resp.get("outcome", {})
	var state: Dictionary = resp.get("state", {})
	outcome_label.text = "[b]STOCHASTIC CHAOS OUTCOME:[/b] %s\n[b]FLAG GRANTED:[/b] %s" % [
		str(outcome.get("text", "")),
		str(outcome.get("flag", "NONE"))
	]
	_update_telemetry(state)
	_refresh_bloodline()
	decision_resolved.emit(outcome, state)

func _on_handoff_pressed() -> void:
	var next_gen_heir := "Heir_%d" % (Time.get_ticks_msec() % 1000)
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "TRIGGER_HANDOFF",
		"cause": "OLD_AGE",
		"next_heir": next_gen_heir
	})
	if resp.get("status") == "OK":
		var bl: Dictionary = resp.get("bloodline", {})
		var state: Dictionary = resp.get("state", {})
		_update_telemetry(state)
		_update_bloodline_telemetry(bl)
		outcome_label.text = "[b][BLOODLINE HANDOFF: %s][/b] New Leader: %s (Gen %s) | Legacy Traits: %s" % [
			str(resp.get("transition_type", "")),
			str(bl.get("current_leader", "")),
			str(bl.get("generation_number", 1)),
			str(bl.get("legacy_traits", []))
		]
		bloodline_updated.emit(bl)

func _on_advance_era_pressed() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "ADVANCE_ERA_LOOP"})
	if resp.get("status") == "OK":
		var bl: Dictionary = resp.get("bloodline", {})
		var state: Dictionary = resp.get("state", {})
		_update_telemetry(state)
		_update_bloodline_telemetry(bl)
		var next_era: String = str(bl.get("current_era", "ERA_TORAH"))
		trial_mode = false
		trial_btn.text = "Perpetual Scripture Trial"
		if resp.get("alpha_omega_loop_triggered", false):
			outcome_label.text = "[b][ALPHA-OMEGA LOOP EXECUTED: REVELATION -> GENESIS][/b] Epoch %s Initiated | Mastery & Covenant Seals Preserved!" % str(bl.get("epoch_number", 1))
			alpha_omega_looped.emit(bl)
		else:
			outcome_label.text = "[b][WORLD CLOCK ADVANCED][/b] Active Era: %s" % next_era
		_load_active_scenario(ERA_SCENARIO_MAP.get(next_era, "GEN_001"))


func _on_export_transcript_pressed() -> void:
	var resp := _send_command({
		"client_type": "GODOT_4",
		"action": "EXPORT_EDTECH_TRANSCRIPT",
		"student_alias": "Sovereign_Candidate",
		"institution_name": "HVF Institutional EdTech Network"
	})
	if resp.get("status") == "OK":
		var sig: String = str(resp.get("transcript_sha256", ""))
		var md_text: String = str(resp.get("markdown_certificate", ""))
		var out_path := "user://mastery_transcript.md"
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f:
			f.store_string(md_text)
			f.close()
		var t_obj: Dictionary = resp.get("transcript", {})
		outcome_label.text = "[b][EDTECH MASTERY TRANSCRIPT EXPORTED][/b] Standing: %s | SHA-256: %s... | Saved to %s" % [
			str(t_obj.get("academic_standing", "VERIFIED")),
			sig.left(20),
			ProjectSettings.globalize_path(out_path)
		]
	else:
		outcome_label.text = "[b][TRANSCRIPT ERROR][/b] %s" % str(resp.get("error", resp.get("message", "Export failed")))


func _on_mute_audio_pressed() -> void:
	if audio_synth and audio_synth.has_method("toggle_mute"):
		var is_muted: bool = audio_synth.toggle_mute()
		mute_audio_btn.text = "Audio: MUTED" if is_muted else "Audio: ON"
		if not is_muted and audio_synth.has_method("play_harp_chime"):
			audio_synth.play_harp_chime()

func _on_save_pressed() -> void:
	var resp := _send_command({"client_type": "GODOT_4", "action": "SAVE_STATE"})
	if resp.get("status") == "SAVED":
		var state: Dictionary = resp.get("state", {})
		_update_telemetry(state)
		if resp.has("generals") and typeof(resp["generals"]) == TYPE_DICTIONARY:
			_update_generals_telemetry(resp["generals"])
		if resp.has("stronghold") and typeof(resp["stronghold"]) == TYPE_DICTIONARY:
			_update_stronghold_telemetry(resp["stronghold"])
		outcome_label.text += "\n[b][SHA-256 SEALED SAVE COMMITTED TO PLAYER_STATE.JSON][/b]"

func _update_telemetry(state: Dictionary) -> void:
	cached_total_score = int(state.get("total_score", 0))
	cached_current_era = str(state.get("current_era", "ERA_TORAH"))
	telemetry_label.text = "ERA: %s  |  SCORE: %s  |  FLAGS: %s  |  SHA-256: %s..." % [
		str(state.get("current_era", "ERA_TORAH")),
		str(cached_total_score),
		str(state.get("active_flags", [])),
		str(state.get("sha256_seal", "")).left(16)
	]

func _update_generals_telemetry(gen: Dictionary) -> void:
	last_generals_snapshot = gen.duplicate(true)
	cached_cmd_bonus = int(gen.get("total_command_power_bonus", 0))
	var assigns: Dictionary = gen.get("assignments", {})
	var posts_label := "NONE"
	if not assigns.is_empty():
		var parts: Array[String] = []
		for slot_key in assigns.keys():
			parts.append("%s=%s" % [str(slot_key).to_upper(), str(assigns[slot_key])])
		posts_label = ", ".join(parts)
	commanders_label.text = "COMMANDERS -> ACTIVE POSTS: %s  |  COMMANDER BONUS: +%d" % [
		posts_label, cached_cmd_bonus
	]

func _update_stronghold_telemetry(sh: Dictionary) -> void:
	last_stronghold_snapshot = sh.duplicate(true)
	if citadel_canvas and citadel_canvas.has_method("update_citadel"):
		citadel_canvas.update_citadel(last_stronghold_snapshot, last_generals_snapshot, cached_current_era)
	var sh_name: String = str(sh.get("stronghold_name", "Covenant Citadel of Zion"))
	var base_power: int = int(sh.get("dynasty_power", 1000))
	var cmd_bonus: int = int(sh.get("commander_power_bonus", cached_cmd_bonus))
	var total_power: int = int(sh.get("total_combined_power", base_power + cmd_bonus))
	var blds: Dictionary = sh.get("buildings", {})
	var keep_info: Dictionary = blds.get("sanctuary_keep", {})
	var keep_lvl: int = int(keep_info.get("level", 1))
	var conquered: Array = sh.get("conquered_chapters", [])
	stronghold_header_label.text = "STRONGHOLD: %s  |  COMBINED POWER: %d (Base %d + Cmd +%d)  |  KEEP: Lv.%d  |  CONQUERED: %s" % [
		sh_name, total_power, base_power, cmd_bonus, keep_lvl, str(conquered)
	]
	var res: Dictionary = sh.get("resources", {})
	resources_label.text = "RESOURCES -> PROVISION: %s  |  TIMBER: %s  |  STONE: %s  |  TALENTS: %s" % [
		str(res.get("provision", 500)),
		str(res.get("timber", 400)),
		str(res.get("stone", 400)),
		str(res.get("talents", 150))
	]
	var chapters: Array = sh.get("available_chapters", [])
	var found_next := false
	for ch in chapters:
		if typeof(ch) == TYPE_DICTIONARY:
			var cid: String = str(ch.get("chapter_id", ""))
			if not conquered.has(cid):
				next_campaign_id = cid
				conquer_chapter_btn.text = "Conquer: %s (Req %s Pwr)" % [
					str(ch.get("title", cid)),
					str(ch.get("required_power", 1000))
				]
				conquer_chapter_btn.disabled = false
				found_next = true
				break
	if not found_next:
		conquer_chapter_btn.text = "All 6 Era Campaigns Conquered!"
		conquer_chapter_btn.disabled = true

func _update_bloodline_telemetry(bl: Dictionary) -> void:
	bloodline_label.text = "EPOCH: %s  |  GEN: %s  |  LEADER: %s  |  HEIR: %s  |  LEGACY & SEALS: %s" % [
		str(bl.get("epoch_number", 1)),
		str(bl.get("generation_number", 1)),
		str(bl.get("current_leader", "Adam_Line_01")),
		str(bl.get("designated_heir", "NONE")),
		str(bl.get("legacy_traits", []))
	]

func _set_options_enabled(enabled: bool) -> void:
	option_a_btn.disabled = not enabled
	option_b_btn.disabled = not enabled
	option_c_btn.disabled = not enabled
	option_d_btn.disabled = not enabled
