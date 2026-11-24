extends Control
class_name OmniBridgeClient

signal handshake_verified(state_data: Dictionary)
signal scenario_loaded(scenario_data: Dictionary)
signal decision_resolved(outcome_data: Dictionary, state_data: Dictionary)
signal bridge_error(message: String)

@export var host: String = "127.0.0.1"
@export var port: int = 65432

@onready var status_label: Label = $MarginContainer/VBox/HeaderPanel/HeaderVBox/StatusLabel
@onready var telemetry_label: Label = $MarginContainer/VBox/HeaderPanel/HeaderVBox/TelemetryLabel
@onready var context_label: RichTextLabel = $MarginContainer/VBox/BodyPanel/BodyVBox/ContextLabel
@onready var outcome_label: RichTextLabel = $MarginContainer/VBox/BodyPanel/BodyVBox/OutcomeLabel
@onready var option_a_btn: Button = $MarginContainer/VBox/BodyPanel/BodyVBox/OptionsHBox/OptionABtn
@onready var option_b_btn: Button = $MarginContainer/VBox/BodyPanel/BodyVBox/OptionsHBox/OptionBBtn
@onready var connect_btn: Button = $MarginContainer/VBox/FooterHBox/ConnectBtn
@onready var save_btn: Button = $MarginContainer/VBox/FooterHBox/SaveBtn

var current_scenario: Dictionary = {}

func _ready() -> void:
connect_btn.pressed.connect(_on_connect_pressed)
save_btn.pressed.connect(_on_save_pressed)
option_a_btn.pressed.connect(func() -> void: _submit_decision(0))
option_b_btn.pressed.connect(func() -> void: _submit_decision(1))
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
_load_active_scenario("GEN_001")

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
if opts.size() >= 1:
option_a_btn.text = "1. " + str(opts[0].get("text", "Option 1"))
if opts.size() >= 2:
option_b_btn.text = "2. " + str(opts[1].get("text", "Option 2"))
_set_options_enabled(true)
scenario_loaded.emit(current_scenario)

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
decision_resolved.emit(outcome, state)

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

func _set_options_enabled(enabled: bool) -> void:
option_a_btn.disabled = not enabled
option_b_btn.disabled = not enabled