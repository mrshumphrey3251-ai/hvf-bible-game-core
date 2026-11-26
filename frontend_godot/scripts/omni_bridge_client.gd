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



	# Phase 36: Full-Screen Immersive Action-Adventure World + Floating Bottom HUD + Toggleable Campaign Drawer
	var margin_ui: Control = get_node_or_null("MarginContainer")
	var world_script = load("res://scripts/sovereign_immersive_world.gd")
	var mp_script = load("res://scripts/sovereign_multiplayer_client.gd")
	if world_script != null:
		if margin_ui != null:
			margin_ui.visible = false
			margin_ui.z_index = 20

		var world_node = world_script.new()
		world_node.name = "ImmersiveBibleWorld"
		add_child(world_node)
		move_child(world_node, 0)

		# Floating Bottom Multiplayer, Combat & Campaign HUD Dock
		var hud_panel: PanelContainer = PanelContainer.new()
		hud_panel.name = "BottomActionHUD"
		hud_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		hud_panel.offset_top = -62.0
		hud_panel.offset_left = 14.0
		hud_panel.offset_right = -14.0
		hud_panel.offset_bottom = -10.0
		hud_panel.z_index = 10

		var hud_hbox: HBoxContainer = HBoxContainer.new()
		hud_hbox.add_theme_constant_override("separation", 6)

		var toggle_drawer_btn: Button = Button.new()
		toggle_drawer_btn.text = "Covenant Trials & Ledger"
		toggle_drawer_btn.pressed.connect(func():
			if margin_ui != null:
				margin_ui.visible = not margin_ui.visible
		)
		hud_hbox.add_child(toggle_drawer_btn)

		var strike_btn: Button = Button.new()
		strike_btn.text = "Sword [F]"
		strike_btn.pressed.connect(func():
			world_node._perform_sword_strike()
		)
		hud_hbox.add_child(strike_btn)

		var shield_btn: Button = Button.new()
		shield_btn.text = "Shield [Q]"
		shield_btn.pressed.connect(func():
			world_node._raise_shield_of_faith()
		)
		hud_hbox.add_child(shield_btn)

		var trade_btn: Button = Button.new()
		trade_btn.text = "Trade [T]"
		trade_btn.pressed.connect(func():
			world_node.trade_gathered_supplies()
		)
		hud_hbox.add_child(trade_btn)

		var build_btn: Button = Button.new()
		build_btn.text = "Build [B]"
		build_btn.pressed.connect(func():
			world_node.acquire_or_build_homestead()
		)
		hud_hbox.add_child(build_btn)
		var armory_btn: Button = Button.new()
		armory_btn.text = "Armory [M]"
		hud_hbox.add_child(armory_btn)

		# Phase 40: Interactive Traveling Merchant & Armory Modal Panel
		var armory_panel: PanelContainer = PanelContainer.new()
		armory_panel.name = "ArmoryShopPanel"
		armory_panel.visible = false
		armory_panel.z_index = 18
		armory_panel.set_anchors_preset(Control.PRESET_CENTER)
		armory_panel.offset_left = -240.0
		armory_panel.offset_right = 240.0
		armory_panel.offset_top = -135.0
		armory_panel.offset_bottom = 135.0

		var arm_vbox: VBoxContainer = VBoxContainer.new()
		arm_vbox.add_theme_constant_override("separation", 8)

		var arm_title: Label = Label.new()
		arm_title.text = "ELIAKIM'S TRAVELING MERCHANT & VILLAGE ARMORY"
		arm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arm_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
		arm_vbox.add_child(arm_title)

		var arm_wallet: Label = Label.new()
		arm_wallet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arm_vbox.add_child(arm_wallet)

		var btn_sword: Button = Button.new()
		var btn_armor: Button = Button.new()
		var btn_boots: Button = Button.new()
		var btn_close_arm: Button = Button.new()
		btn_close_arm.text = "Close Armory [M]"

		var refresh_armory_ui: Callable = func():
			arm_wallet.text = "Earned Talents Available: %d" % world_node.earned_talents
			var sc: int = world_node.get_upgrade_cost(world_node.sword_level, 60)
			btn_sword.text = "Forge Sword of the Spirit (Lv.%d -> Lv.%d | +14 DMG) ? %s" % [world_node.sword_level, mini(5, world_node.sword_level + 1), ("%d Talents" % sc) if sc > 0 else "MAXED"]
			var ac: int = world_node.get_upgrade_cost(world_node.armor_level, 55)
			btn_armor.text = "Temper Breastplate Armor (Lv.%d -> Lv.%d | +5 Armor & +15 HP) ? %s" % [world_node.armor_level, mini(5, world_node.armor_level + 1), ("%d Talents" % ac) if ac > 0 else "MAXED"]
			var bc: int = world_node.get_upgrade_cost(world_node.boots_level, 50)
			btn_boots.text = "Craft Gospel Speed Boots (Lv.%d -> Lv.%d | +32 Speed) ? %s" % [world_node.boots_level, mini(5, world_node.boots_level + 1), ("%d Talents" % bc) if bc > 0 else "MAXED"]

		btn_sword.pressed.connect(func():
			world_node.buy_sword_upgrade()
			refresh_armory_ui.call()
		)
		btn_armor.pressed.connect(func():
			world_node.buy_armor_upgrade()
			refresh_armory_ui.call()
		)
		btn_boots.pressed.connect(func():
			world_node.buy_boots_upgrade()
			refresh_armory_ui.call()
		)
		btn_close_arm.pressed.connect(func():
			armory_panel.visible = false
		)

		arm_vbox.add_child(btn_sword)
		arm_vbox.add_child(btn_armor)
		arm_vbox.add_child(btn_boots)
		arm_vbox.add_child(btn_close_arm)
		armory_panel.add_child(arm_vbox)
		add_child(armory_panel)

		var academy_btn: Button = Button.new()
		academy_btn.text = "Bible Academy [L]"
		hud_hbox.add_child(academy_btn)

		# Phase 41B: Scripture & Covenant Law Academy + $4.99 / $14.99 Entitlement Store
		var acad_panel: PanelContainer = PanelContainer.new()
		acad_panel.name = "ScriptureAcademyPanel"
		acad_panel.visible = false
		acad_panel.z_index = 22
		acad_panel.set_anchors_preset(Control.PRESET_CENTER)
		acad_panel.offset_left = -340.0
		acad_panel.offset_right = 340.0
		acad_panel.offset_top = -215.0
		acad_panel.offset_bottom = 215.0

		var acad_vbox: VBoxContainer = VBoxContainer.new()
		acad_vbox.add_theme_constant_override("separation", 6)

		var acad_title: Label = Label.new()
		acad_title.text = "SOVEREIGN SCRIPTURE & COVENANT LAW ACADEMY (ULTIMATE LAW EDITION)"
		acad_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		acad_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
		acad_vbox.add_child(acad_title)

		var tier_status_lbl: Label = Label.new()
		tier_status_lbl.text = "ACTIVE TIER: Free Playable Prologue (Stage 1 Sinai)"
		tier_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tier_status_lbl.add_theme_color_override("font_color", Color(0.45, 0.94, 0.65))
		acad_vbox.add_child(tier_status_lbl)

		var store_hbox: HBoxContainer = HBoxContainer.new()
		store_hbox.add_theme_constant_override("separation", 6)

		var buy_499_btn: Button = Button.new()
		buy_499_btn.text = "Unlock Full Game ($4.99)"
		buy_499_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var buy_1499_btn: Button = Button.new()
		buy_1499_btn.text = "Unlock Bible Academy ($14.99/mo)"
		buy_1499_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		store_hbox.add_child(buy_499_btn)
		store_hbox.add_child(buy_1499_btn)
		acad_vbox.add_child(store_hbox)

		var module_tabs: HBoxContainer = HBoxContainer.new()
		module_tabs.add_theme_constant_override("separation", 6)
		var btn_lexicon: Button = Button.new()
		btn_lexicon.text = "1. Hebrew/Greek Lexicon"
		btn_lexicon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn_cov_law: Button = Button.new()
		btn_cov_law.text = "2. Covenant Law Case Studies"
		btn_cov_law.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn_mastery: Button = Button.new()
		btn_mastery.text = "3. Complete Study Lesson (+50T)"
		btn_mastery.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		module_tabs.add_child(btn_lexicon)
		module_tabs.add_child(btn_cov_law)
		module_tabs.add_child(btn_mastery)
		acad_vbox.add_child(module_tabs)

		var study_reader: RichTextLabel = RichTextLabel.new()
		study_reader.bbcode_enabled = true
		study_reader.custom_minimum_size = Vector2(0, 210)
		study_reader.size_flags_vertical = Control.SIZE_EXPAND_FILL
		study_reader.text = "[b][color=#f5d061]FREE PROLOGUE PREVIEW ? SCRIPTURE & COVENANT LAW ACADEMY[/color][/b]\n? [b]Free Prologue (Stage 1):[/b] Explore Sinai, battle Raiders, loot Secret Chests & play Multiplayer.\n? [b]Full Covenant Pilgrim Edition ($4.99 One-Time):[/b] Unlocks all 6 Biblical Eras, Land Deeds, 4-Stage Homestead Construction & Lv.5 Armory.\n? [b]Scripture & Covenant Law Academy ($14.99/mo):[/b] Unlocks full 66-Book Exegesis, Original Hebrew/Greek Lexicons, Ultimate-Law Covenant Case Studies & SHA-256 Academic Transcripts."
		acad_vbox.add_child(study_reader)

		var btn_close_acad: Button = Button.new()
		btn_close_acad.text = "Close Academy & Store [L]"
		btn_close_acad.pressed.connect(func():
			acad_panel.visible = false
		)
		acad_vbox.add_child(btn_close_acad)

		acad_panel.add_child(acad_vbox)
		add_child(acad_panel)

		var activate_tier_fn: Callable = func(key_code: String, full_ok: bool, acad_ok: bool, tier_lbl: String):
			world_node.set_entitlement_tier(full_ok, acad_ok, tier_lbl)
			tier_status_lbl.text = "ACTIVE TIER: %s [VERIFIED]" % tier_lbl
			if audio_synth != null and audio_synth.has_method("play_covenant_chime"):
				audio_synth.play_covenant_chime()
			var p_tcp: StreamPeerTCP = StreamPeerTCP.new()
			if p_tcp.connect_to_host(host, port) == OK:
				p_tcp.poll()
				var sp: int = 0
				while p_tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING and sp < 10:
					p_tcp.poll()
					sp += 1
				if p_tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
					var req_s: String = JSON.stringify({"action": "ENTITLEMENT_ACTIVATE", "player_id": "PILGRIM_LOCAL", "license_key": key_code}) + "\n"
					p_tcp.put_data(req_s.to_utf8_buffer())
					p_tcp.poll()
				p_tcp.disconnect_from_host()

		buy_499_btn.pressed.connect(func():
			activate_tier_fn.call("HVF-PILGRIM-499", true, false, "Full Pilgrim ($4.99)")
			study_reader.text = "[b][color=#7de2d1]FULL COVENANT PILGRIM EDITION ($4.99) ACTIVATED![/color][/b]\nAll 6 Biblical Era Portals, Land Deeds, 4-Stage On-Screen House Construction, and Lv.5 Armory Upgrades are now unlocked!\n\n[i]Upgrade to the $14.99/mo Scripture & Covenant Law Academy above to unlock full Hebrew/Greek Lexicon & Covenant Law Case Studies.[/i]"
		)

		buy_1499_btn.pressed.connect(func():
			activate_tier_fn.call("HVF-ACADEMY-1499", true, true, "Scripture Academy ($14.99/mo)")
			study_reader.text = "[b][color=#f5d061]SCRIPTURE & COVENANT LAW ACADEMY ($14.99/MO) ACTIVATED![/color][/b]\nWelcome, Scholar! You now have full access to the 66-Book Curriculum, Original Hebrew/Greek Lexicons, Ultimate-Law Covenant Case Studies, and SHA-256 Academic Transcripts."
		)

		btn_lexicon.pressed.connect(func():
			if not world_node.has_academy_access:
				study_reader.text = "[b][color=#ff8a80]ACADEMY TIER REQUIRED ($14.99/mo):[/color][/b] Click [b]Unlock Bible Academy ($14.99/mo)[/b] above to study original Hebrew & Greek roots!\n\n[i]Sample Entry:[/i] [b]BERIT (??????? ? Hebrew):[/b] Covenant, solemn binding oath ratified by blood and sacrifice (Gen 15:18; Exod 24:8)."
			else:
				study_reader.text = "[b][color=#f5d061]ORIGINAL HEBREW & GREEK ROOT LEXICON (66-BOOK CONCORDANCE)[/color][/b]\n? [b]BERIT (???????):[/b] Covenant / Solemn Treaty ? Unilateral & bilateral divine oath (Gen 15; Jer 31:31).\n? [b]CHESED (?????):[/b] Steadfast Covenant Loyalty & Mercy ? Faithful love anchored in promise (Ps 136).\n? [b]TORAH (???????):[/b] Instruction / Covenant Law ? Divine direction for justice, worship & life (Deut 6).\n? [b]LOGOS (?????):[/b] Eternal Word & Reason ? Pre-existent divine self-expression incarnate (John 1:1).\n? [b]DIKAIOSYNE (??????????):[/b] Covenant Righteousness & Judicial Standing (Rom 3:21-26)."
		)

		btn_cov_law.pressed.connect(func():
			if not world_node.has_academy_access:
				study_reader.text = "[b][color=#ff8a80]ACADEMY TIER REQUIRED ($14.99/mo):[/color][/b] Click [b]Unlock Bible Academy ($14.99/mo)[/b] above to open Ultimate-Law Covenant Case Studies!\n\n[i]Preview Case #01:[/i] [b]Cities of Refuge & Due Process (Num 35:9-34)[/b] ? Separation of accidental manslaughter from premeditated murder."
			else:
				study_reader.text = "[b][color=#f5d061]COVENANT LAW CASE STUDIES (ULTIMATE LAW JURISPRUDENCE)[/color][/b]\n? [b]CASE 01 ? Due Process & Two-Witness Rule (Deut 19:15):[/b] Establishes evidentiary burden of proof before judicial conviction.\n? [b]CASE 02 ? Restitution Over Retaliation (Exod 22:1-15):[/b] Restorative property law requiring multi-fold restitution to make victims whole.\n? [b]CASE 03 ? Jubilee Land Redemption (Lev 25:8-28):[/b] Anti-monopoly agrarian inheritance protection ensuring family land reverts every 50th year.\n? [b]CASE 04 ? New Covenant Heart Inscription (Jer 31:31-34; Heb 8):[/b] Transition from external stone tablets to Spirit-empowered obedience."
		)

		btn_mastery.pressed.connect(func():
			if not world_node.has_academy_access:
				study_reader.text = "[b][color=#ff8a80]ACADEMY TIER REQUIRED ($14.99/mo):[/color][/b] Activate the Scripture Academy tier above to complete accredited lessons for +50 Talents & Builder Credits!"
			else:
				world_node.add_trivia_talents(50, "Scripture & Covenant Law Academy")
				study_reader.text = "[b][color=#7de2d1]ACADEMY STUDY MODULE COMPLETED![/color][/b]\nAwarded [b]+50 Earned Talents[/b] and [b]+1 Builder Task Credit[/b]! Your mastery progress is sealed for SHA-256 Academic Transcript export."
		)

		var toggle_acad_fn: Callable = func():
			acad_panel.visible = not acad_panel.visible

		academy_btn.pressed.connect(toggle_acad_fn)
		world_node.academy_toggled.connect(toggle_acad_fn)
		world_node.upgrade_modal_requested.connect(func(reason_txt: String):
			acad_panel.visible = true
			study_reader.text = "[b][color=#f5d061]UPGRADE REQUIRED:[/color][/b] %s\n\nChoose your tier above:\n? [b]Full Covenant Pilgrim Edition ($4.99 One-Time)[/b] ? All 6 Stages, Homestead Building & Lv.5 Armory.\n? [b]Scripture & Covenant Law Academy ($14.99/mo)[/b] ? Everything above + Full 66-Book Study, Lexicon & Covenant Law Case Studies." % reason_txt
		)


		var toggle_arm_fn: Callable = func():
			armory_panel.visible = not armory_panel.visible
			if armory_panel.visible:
				refresh_armory_ui.call()

		armory_btn.pressed.connect(toggle_arm_fn)
		world_node.armory_toggled.connect(toggle_arm_fn)
		world_node.armory_updated.connect(func(_t: int, _s: int, _a: int, _b: int):
			if armory_panel.visible:
				refresh_armory_ui.call()
		)


		var online_lbl: Label = Label.new()
		online_lbl.text = "Online: 1"
		online_lbl.add_theme_color_override("font_color", Color(0.45, 0.94, 0.65))
		hud_hbox.add_child(online_lbl)

		var name_edit: LineEdit = LineEdit.new()
		name_edit.placeholder_text = "Pilgrim Name..."
		name_edit.custom_minimum_size = Vector2(120, 0)
		hud_hbox.add_child(name_edit)

		var robe_picker: OptionButton = OptionButton.new()
		for r_opt in ["Sapphire", "Judah Gold", "Emerald", "Tyrian Purple", "Crimson", "Galilee Cyan"]:
			robe_picker.add_item(r_opt)
		hud_hbox.add_child(robe_picker)

		var chat_edit: LineEdit = LineEdit.new()
		chat_edit.placeholder_text = "Fellowship chat across stages..."
		chat_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hud_hbox.add_child(chat_edit)

		var send_btn: Button = Button.new()
		send_btn.text = "Send"
		hud_hbox.add_child(send_btn)

		hud_panel.add_child(hud_hbox)
		add_child(hud_panel)

		world_node.npc_dialogue_triggered.connect(func(npc_name: String, era_id: String, scenario_id: String, greeting: String):
			if audio_synth != null and audio_synth.has_method("play_covenant_chime"):
				audio_synth.play_covenant_chime()
			if has_method("_request_scenario"):
				call("_request_scenario", scenario_id)
			if margin_ui != null:
				margin_ui.visible = true
		)

		world_node.chest_looted.connect(func(chest_id: String, loot_summary: String):
			if audio_synth != null and audio_synth.has_method("play_covenant_chime"):
				audio_synth.play_covenant_chime()
		)

		perpetual_trial_resolved.connect(func(trial_res: Dictionary):
			if bool(trial_res.get("correct", false)):
				world_node.add_trivia_talents(30, "Scripture Trial")
		)

		world_node.battle_won.connect(func(enemy_name: String, reward_score: int, reward_talents: int):
			if audio_synth != null and audio_synth.has_method("play_covenant_chime"):
				audio_synth.play_covenant_chime()
		)

		world_node.trial_requested.connect(func():
			if margin_ui != null:
				margin_ui.visible = true
			if has_method("_on_trial_pressed"):
				call("_on_trial_pressed")
		)

		if mp_script != null:
			var mp_client = mp_script.new()
			mp_client.name = "MultiplayerRelayClient"
			add_child(mp_client)
			name_edit.text = mp_client.player_name
			world_node.set_local_pilgrim_name(mp_client.player_name)

			name_edit.text_submitted.connect(func(new_name: String):
				var clean_n: String = new_name.strip_edges()
				if clean_n != "":
					mp_client.player_name = clean_n
					mp_client.dirty_pos = true
					world_node.set_local_pilgrim_name(clean_n)
			)

			robe_picker.item_selected.connect(func(idx: int):
				var chosen: String = robe_picker.get_item_text(idx)
				mp_client.robe_name = chosen
				mp_client.dirty_pos = true
				world_node.set_local_robe_color(chosen)
			)

			var send_chat_fn: Callable = func(txt: String):
				var msg_clean: String = txt.strip_edges()
				if msg_clean != "":
					var cur_name: String = name_edit.text.strip_edges()
					if cur_name != "":
						mp_client.player_name = cur_name
						world_node.set_local_pilgrim_name(cur_name)
					mp_client.send_fellowship_chat(msg_clean)
					chat_edit.text = ""

			chat_edit.text_submitted.connect(send_chat_fn)
			send_btn.pressed.connect(func():
				send_chat_fn.call(chat_edit.text)
			)

			world_node.player_moved.connect(func(stage_id: String, px: float, py: float):
				mp_client.update_local_state(stage_id, px, py)
			)
			world_node.stage_portal_entered.connect(func(target_era_id: String):
				mp_client.update_local_state(target_era_id, 420.0, 340.0)
			)
			world_node.battle_won.connect(func(enemy_name: String, reward_score: int, reward_talents: int):
				mp_client.broadcast_covenant_blessing("Defeated %s" % enemy_name, reward_score)
			)
			mp_client.peers_updated.connect(func(peers: Array, online_cnt: int, chat_log: Array):
				world_node.set_remote_pilgrims(peers)
				online_lbl.text = "Online: %d" % online_cnt
				if chat_log.size() > 0:
					var last_msg: Dictionary = chat_log[chat_log.size() - 1]
					var l_txt: String = str(last_msg.get("message", ""))
					world_node.show_coop_blessing("[%s @ %s]: %s" % [str(last_msg.get("sender", "Pilgrim")), str(last_msg.get("stage", "ERA_TORAH")), l_txt])
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
		"action": "TRADE_SUPPLIES",
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
