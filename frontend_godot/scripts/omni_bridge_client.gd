extends Control
class_name OmniBridgeClient

signal handshake_verified(state_data: Dictionary)
signal scenario_loaded(scenario_data: Dictionary)
signal decision_resolved(outcome_data: Dictionary, state_data: Dictionary)
signal bloodline_updated(bloodline_data: Dictionary)
signal alpha_omega_looped(bloodline_data: Dictionary)
signal perpetual_trial_resolved(trial_result: Dictionary)
signal bridge_error(message: String)

@export var host: String = "127.0.0.1"
@export var port: int = 65432

@onready var status_label: Label = $MarginContainer/VBox/HeaderPanel/HeaderVBox/StatusLabel
@onready var telemetry_label: Label = $MarginContainer/VBox/HeaderPanel/HeaderVBox/TelemetryLabel
@onready var bloodline_label: Label = $MarginContainer/VBox/HeaderPanel/HeaderVBox/BloodlineLabel
@onready var context_label: RichTextLabel = $MarginContainer/VBox/BodyPanel/BodyVBox/ContextLabel
@onready var outcome_label: RichTextLabel = $MarginContainer/VBox/BodyPanel/BodyVBox/OutcomeLabel
@onready var option_a_btn: Button = $MarginContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionABtn
@onready var option_b_btn: Button = $MarginContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionBBtn
@onready var option_c_btn: Button = $MarginContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionCBtn
@onready var option_d_btn: Button = $MarginContainer/VBox/BodyPanel/BodyVBox/OptionsGrid/OptionDBtn
@onready var connect_btn: Button = $MarginContainer/VBox/FooterHBox/ConnectBtn
@onready var trial_btn: Button = $MarginContainer/VBox/FooterHBox/TrialBtn
@onready var handoff_btn: Button = $MarginContainer/VBox/FooterHBox/HandoffBtn
@onready var advance_era_btn: Button = $MarginContainer/VBox/FooterHBox/AdvanceEraBtn
@onready var save_btn: Button = $MarginContainer/VBox/FooterHBox/SaveBtn

const ERA_SCENARIO_MAP := {
"ERA_TORAH": "GEN_001",
"ERA_HISTORY": "HIS_001",
"ERA_WISDOM": "WIS_001",
"ERA_PROPHETS": "PRO_001",
"ERA_GOSPELS": "GOS_001",
"ERA_EPISTLES": "EPI_001"
}

var current_scenario: Dictionary = {}
var current_trial: Dictionary = {}
var active_trial_token: String = ""
var trial_mode: bool = false

func _ready() -> void:
connect_btn.pressed.connect(_on_connect_pressed)
trial_btn.pressed.connect(_on_toggle_trial_mode)
handoff_btn.pressed.connect(_on_handoff_pressed)
advance_era_btn.pressed.connect(_on_advance_era_pressed)
save_btn.pressed.connect(_on_save_pressed)
option_a_btn.pressed.connect(func() -> void: _handle_option_press(0))
option_b_btn.pressed.connect(func() -> void: _handle_option_press(1))
option_c_btn.pressed.connect(func() -> void: _handle_option_press(2))
option_d_btn.pressed.connect(func() -> void: _handle_option_press(3))
_set_options_enabled(false)
_on_connect_pressed()

func _send_command(payload: Dictionary) -> Dictionary:
var peer := StreamPeerTCP.new()
var err := peer.connect_to_host(host, port)
if err != OK:
return {"status": "ERROR", "error": "TCP connect failed (code %d). Start hvf_omni_dispatcher.py." % err}
var deadline := Time.get_ticks_msec() + 2000
while Time.get_ticks_msec() < deadline:
peer.poll()
if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
break
OS.delay_msec(10)
if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
peer.disconnect_from_host()
return {"status": "ERROR", "error": "Backend offline at %s:%d — launch hvf_omni_dispatcher.py." % [host, port]}
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
status_label.text = "BRIDGE STATUS: CONNECTED & VERIFIED (GODOT_4 -> %s:%d)" % [host, port]
_update_telemetry(state)
handshake_verified.emit(state)
_refresh_bloodline()
var era_name: String = str(state.get("current_era", "ERA_TORAH"))
trial_mode = false
trial_btn.text = "Perpetual Scripture Trial"
_load_active_scenario(ERA_SCENARIO_MAP.get(era_name, "GEN_001"))

func _refresh_bloodline() -> void:
var resp := _send_command({"client_type": "GODOT_4", "action": "GET_BLOODLINE"})
if resp.get("status") == "OK":
var bl: Dictionary = resp.get("bloodline", {})
_update_bloodline_telemetry(bl)
bloodline_updated.emit(bl)

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
# Immediately load the next mutated perpetual challenge so the player never repeats a static slot
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

func _on_save_pressed() -> void:
var resp := _send_command({"client_type": "GODOT_4", "action": "SAVE_STATE"})
if resp.get("status") == "SAVED":
var state: Dictionary = resp.get("state", {})
_update_telemetry(state)
outcome_label.text += "\n[b][SHA-256 SEALED SAVE COMMITTED TO PLAYER_STATE.JSON][/b]"

func _update_telemetry(state: Dictionary) -> void:
telemetry_label.text = "ERA: %s  |  SCORE: %s  |  FLAGS: %s  |  SHA-256: %s..." % [
str(state.get("current_era", "ERA_TORAH")),
str(state.get("total_score", 0)),
str(state.get("active_flags", [])),
str(state.get("sha256_seal", "")).left(16)
]

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