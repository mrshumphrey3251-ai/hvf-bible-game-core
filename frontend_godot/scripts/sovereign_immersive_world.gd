extends Control
class_name SovereignImmersiveWorld

signal npc_dialogue_triggered(npc_name: String, era_id: String, scenario_id: String, greeting: String)
signal stage_portal_entered(target_era_id: String)
signal player_moved(stage_id: String, pos_x: float, pos_y: float)
signal chest_looted(chest_id: String, loot_summary: String)
signal battle_won(enemy_name: String, reward_score: int, reward_talents: int)
signal supplies_traded(talents_gained: int)
signal trial_requested()

const ERA_ORDER := [
	"ERA_TORAH",
	"ERA_HISTORY",
	"ERA_WISDOM",
	"ERA_PROPHETS",
	"ERA_GOSPELS",
	"ERA_EPISTLES"
]

const ROBE_PALETTE := {
	"Sapphire": Color(0.18, 0.48, 0.92),
	"Judah Gold": Color(0.94, 0.74, 0.22),
	"Emerald": Color(0.20, 0.75, 0.48),
	"Tyrian Purple": Color(0.62, 0.28, 0.82),
	"Crimson": Color(0.86, 0.24, 0.28),
	"Galilee Cyan": Color(0.22, 0.82, 0.90)
}

const WORLD_STAGES := {
	"ERA_TORAH": {
		"title": "I. WILDERNESS OF SINAI & TABERNACLE",
		"sky_top": Color(0.05, 0.04, 0.08),
		"sky_bot": Color(0.18, 0.12, 0.07),
		"ground": Color(0.26, 0.18, 0.10),
		"accent": Color(0.96, 0.78, 0.28),
		"tabernacle_name": "Tabernacle & Trading Post",
		"tabernacle_pos": Vector2(0.22, 0.48),
		"npcs": [
			{"name": "Moses", "x": 0.31, "y": 0.58, "color": Color(0.88, 0.68, 0.24), "headgear": "prophet", "scenario": "GEN_001", "greeting": "Gather Timber & Stone from Secret Chests to trade [T] for Talents, or press [E] to answer Covenant Trivia!"},
			{"name": "Caleb", "x": 0.52, "y": 0.68, "color": Color(0.24, 0.68, 0.42), "headgear": "warrior", "scenario": "TOR_005", "greeting": "Defeat the ridge Sentinels [F] to win battle spoils and Talents!"}
		],
		"chests": [
			{"id": "CHEST_TOR_1", "x": 0.14, "y": 0.76, "timber": 120, "stone": 100, "oil": 2, "manna": 30, "relic": "Bronze Altar Ember"},
			{"id": "CHEST_TOR_2", "x": 0.84, "y": 0.46, "timber": 150, "stone": 120, "oil": 1, "manna": 40, "relic": "Ark Cedar Plank"}
		],
		"enemies": [
			{"name": "Amalekite Raider", "x": 0.72, "y": 0.62, "hp": 100, "max_hp": 100, "atk": 14, "score": 35, "talents": 30},
			{"name": "Anakite Giant Scout", "x": 0.81, "y": 0.73, "hp": 130, "max_hp": 130, "atk": 18, "score": 50, "talents": 45}
		]
	},
	"ERA_HISTORY": {
		"title": "II. JERUSALEM WALLS & JORDAN CROSSING",
		"sky_top": Color(0.04, 0.07, 0.12),
		"sky_bot": Color(0.12, 0.18, 0.22),
		"ground": Color(0.17, 0.22, 0.16),
		"accent": Color(0.45, 0.86, 0.58),
		"tabernacle_name": "Shiloh Sanctuary & Supply Post",
		"tabernacle_pos": Vector2(0.21, 0.48),
		"npcs": [
			{"name": "Joshua", "x": 0.32, "y": 0.60, "color": Color(0.84, 0.36, 0.24), "headgear": "warrior", "scenario": "HIS_001", "greeting": "No free tribute?earn your Talents through battle victory [F], supply trade [T], and Scripture Trials [E]!"},
			{"name": "Nehemiah", "x": 0.54, "y": 0.52, "color": Color(0.28, 0.60, 0.88), "headgear": "builder", "scenario": "HIS_005", "greeting": "Trade excess Timber & Stone [T] to fund Jerusalem's restoration!"}
		],
		"chests": [
			{"id": "CHEST_HIS_1", "x": 0.15, "y": 0.77, "timber": 140, "stone": 160, "oil": 2, "manna": 35, "relic": "Gilgal Memorial Stone"},
			{"id": "CHEST_HIS_2", "x": 0.85, "y": 0.77, "timber": 180, "stone": 200, "oil": 2, "manna": 45, "relic": "Nehemiah's Trowel"}
		],
		"enemies": [
			{"name": "Jericho Wall Sentinel", "x": 0.74, "y": 0.60, "hp": 120, "max_hp": 120, "atk": 16, "score": 45, "talents": 40},
			{"name": "Sanballat Mercenary", "x": 0.79, "y": 0.72, "hp": 140, "max_hp": 140, "atk": 20, "score": 55, "talents": 50}
		]
	},
	"ERA_WISDOM": {
		"title": "III. MOUNT ZION & SOLOMON'S TEMPLE COURTS",
		"sky_top": Color(0.08, 0.05, 0.14),
		"sky_bot": Color(0.20, 0.12, 0.26),
		"ground": Color(0.22, 0.16, 0.24),
		"accent": Color(0.98, 0.84, 0.36),
		"tabernacle_name": "Golden Temple Sanctuary",
		"tabernacle_pos": Vector2(0.22, 0.47),
		"npcs": [
			{"name": "King David", "x": 0.33, "y": 0.60, "color": Color(0.92, 0.72, 0.22), "headgear": "crown", "scenario": "WIS_001", "greeting": "Blessed be the Lord my Rock! Vanquish the Philistine Champion [F] or answer Scripture Trivia [E]!"},
			{"name": "Solomon", "x": 0.55, "y": 0.52, "color": Color(0.68, 0.42, 0.92), "headgear": "crown", "scenario": "WIS_004", "greeting": "Trade cedar timber and hewn stone [T] at the Temple treasury for Talents."}
		],
		"chests": [
			{"id": "CHEST_WIS_1", "x": 0.14, "y": 0.76, "timber": 200, "stone": 180, "oil": 3, "manna": 40, "relic": "Davidic Harp String"},
			{"id": "CHEST_WIS_2", "x": 0.84, "y": 0.47, "timber": 220, "stone": 220, "oil": 2, "manna": 50, "relic": "Seal of Wisdom"}
		],
		"enemies": [
			{"name": "Philistine Champion", "x": 0.75, "y": 0.63, "hp": 150, "max_hp": 150, "atk": 20, "score": 60, "talents": 65}
		]
	},
	"ERA_PROPHETS": {
		"title": "IV. PROPHETIC WATCHTOWER & SCROLL HALL",
		"sky_top": Color(0.10, 0.04, 0.06),
		"sky_bot": Color(0.24, 0.10, 0.10),
		"ground": Color(0.22, 0.13, 0.13),
		"accent": Color(0.98, 0.56, 0.32),
		"tabernacle_name": "Altar of Burning Coals",
		"tabernacle_pos": Vector2(0.21, 0.48),
		"npcs": [
			{"name": "Isaiah", "x": 0.32, "y": 0.58, "color": Color(0.90, 0.54, 0.24), "headgear": "prophet", "scenario": "PRO_001", "greeting": "Stand on the watchtower! Defeat the Siege Warden [F] and claim battle Talents."},
			{"name": "Jeremiah", "x": 0.54, "y": 0.66, "color": Color(0.45, 0.70, 0.84), "headgear": "prophet", "scenario": "PRO_004", "greeting": "Test your knowledge of the Prophets [E] to earn covenant rewards!"}
		],
		"chests": [
			{"id": "CHEST_PRO_1", "x": 0.15, "y": 0.77, "timber": 160, "stone": 190, "oil": 3, "manna": 45, "relic": "Prophetic Scroll Cylinder"}
		],
		"enemies": [
			{"name": "Babylonian Siege Warden", "x": 0.75, "y": 0.62, "hp": 165, "max_hp": 165, "atk": 22, "score": 65, "talents": 70}
		]
	},
	"ERA_GOSPELS": {
		"title": "V. SEA OF GALILEE & MOUNT OF OLIVES",
		"sky_top": Color(0.04, 0.09, 0.15),
		"sky_bot": Color(0.08, 0.22, 0.28),
		"ground": Color(0.12, 0.24, 0.20),
		"accent": Color(0.42, 0.90, 0.96),
		"tabernacle_name": "House of Prayer Sanctuary",
		"tabernacle_pos": Vector2(0.21, 0.48),
		"npcs": [
			{"name": "Peter", "x": 0.33, "y": 0.60, "color": Color(0.28, 0.74, 0.92), "headgear": "pilgrim", "scenario": "GOS_001", "greeting": "Use your talents faithfully! Trade supplies [T] or answer Gospel Trivia [E]."},
			{"name": "Good Samaritan", "x": 0.54, "y": 0.54, "color": Color(0.36, 0.84, 0.54), "headgear": "pilgrim", "scenario": "GOS_004", "greeting": "Visit the Sanctuary whenever your Spirit runs low."}
		],
		"chests": [
			{"id": "CHEST_GOS_1", "x": 0.14, "y": 0.76, "timber": 190, "stone": 150, "oil": 3, "manna": 60, "relic": "Five Loaves Basket"}
		],
		"enemies": [
			{"name": "Tempest Shadow Spirit", "x": 0.76, "y": 0.63, "hp": 180, "max_hp": 180, "atk": 24, "score": 75, "talents": 80}
		]
	},
	"ERA_EPISTLES": {
		"title": "VI. APOSTOLIC UPPER ROOM & ROMAN ROAD",
		"sky_top": Color(0.07, 0.06, 0.14),
		"sky_bot": Color(0.16, 0.12, 0.26),
		"ground": Color(0.18, 0.17, 0.25),
		"accent": Color(0.98, 0.84, 0.42),
		"tabernacle_name": "Upper Room Flame Sanctuary",
		"tabernacle_pos": Vector2(0.22, 0.48),
		"npcs": [
			{"name": "Apostle Paul", "x": 0.33, "y": 0.58, "color": Color(0.92, 0.74, 0.28), "headgear": "prophet", "scenario": "EPI_001", "greeting": "Fight the good fight of faith [F]! Every battle victory and Scripture Trial earns Talents."},
			{"name": "Barnabas", "x": 0.55, "y": 0.66, "color": Color(0.50, 0.82, 0.46), "headgear": "pilgrim", "scenario": "EPI_004", "greeting": "Press [T] to trade chest supplies for Talents."}
		],
		"chests": [
			{"id": "CHEST_EPI_1", "x": 0.84, "y": 0.76, "timber": 250, "stone": 250, "oil": 4, "manna": 75, "relic": "Full Armor of God Seal"}
		],
		"enemies": [
			{"name": "Principalities Vanguard", "x": 0.76, "y": 0.62, "hp": 210, "max_hp": 210, "atk": 26, "score": 100, "talents": 110}
		]
	}
}

var current_stage: String = "ERA_TORAH"
var player_pos: Vector2 = Vector2(360.0, 340.0)
var target_pos: Vector2 = Vector2(360.0, 340.0)
var has_click_target: bool = false
var is_walking: bool = false
var facing_dir: float = 1.0
var move_speed: float = 235.0
var anim_time: float = 0.0
var portal_cooldown: float = 0.0

var spirit_hp: int = 100
var max_spirit_hp: int = 100
var manna_rations: int = 50
var anointing_oil: int = 2
var timber_stock: int = 100
var stone_stock: int = 100
var earned_talents: int = 50
var relics_found: Array = []
var opened_chests: Dictionary = {}
var stage_enemies: Array = []

var shield_active: bool = false
var shield_timer: float = 0.0
var attack_swing_timer: float = 0.0
var attack_cooldown: float = 0.0
var enemy_turn_timer: float = 0.0

var nearby_npc: Dictionary = {}
var nearby_chest: Dictionary = {}
var nearby_enemy_idx: int = -1
var in_tabernacle: bool = false

var banner_text: String = "Earn Talents via Battle [F], Supply Trading [T], or Scripture Trivia [E]! Search for Secret Chests!"
var banner_timer: float = 8.5
var remote_pilgrims: Array = []
var local_pilgrim_name: String = "Pilgrim"
var local_robe_name: String = "Sapphire"
var particles: Array = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(38):
		particles.append({
			"x": rng.randf(),
			"y": rng.randf(),
			"spd": rng.randf_range(0.015, 0.045),
			"rad": rng.randf_range(1.5, 3.8)
		})
	set_stage("ERA_TORAH")
	set_process(true)

func set_stage(era_id: String) -> void:
	if WORLD_STAGES.has(era_id):
		current_stage = era_id
		var w: float = maxf(size.x, 1024.0)
		var h: float = maxf(size.y, 640.0)
		player_pos = Vector2(w * 0.38, h * 0.62)
		target_pos = player_pos
		has_click_target = false
		portal_cooldown = 0.8
		stage_enemies.clear()
		var st: Dictionary = WORLD_STAGES[era_id]
		var raw_enemies: Array = st.get("enemies", [])
		for e_item in raw_enemies:
			var ed: Dictionary = e_item
			stage_enemies.append(ed.duplicate(true))
		_announce("Entered %s" % str(st["title"]), 5.0)
		queue_redraw()

func set_local_pilgrim_name(pname: String) -> void:
	var clean: String = pname.strip_edges()
	local_pilgrim_name = clean if clean != "" else "Pilgrim"
	queue_redraw()

func set_local_robe_color(rname: String) -> void:
	if ROBE_PALETTE.has(rname):
		local_robe_name = rname
		queue_redraw()

func add_trivia_talents(amount: int, source_label: String) -> void:
	earned_talents += amount
	_announce("TRIVIA REWARD: +%d Talents earned from %s! (Total: %d Talents)" % [amount, source_label, earned_talents], 6.0)

func show_coop_blessing(text: String) -> void:
	_announce(text, 7.5)

func set_remote_pilgrims(pilgrims: Array) -> void:
	remote_pilgrims = pilgrims
	queue_redraw()

func _announce(msg: String, duration: float = 5.5) -> void:
	banner_text = msg
	banner_timer = duration
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		grab_focus()
		var click_p: Vector2 = event.position
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_perform_sword_strike()
			accept_event()
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var c_npc: Dictionary = _find_npc_near(click_p, 52.0)
			if not c_npc.is_empty():
				target_pos = _norm_to_screen(float(c_npc["x"]), float(c_npc["y"])) + Vector2(0, 32)
				has_click_target = true
				_interact_with_npc(c_npc)
				accept_event()
				return
			var c_chest: Dictionary = _find_chest_near(click_p, 46.0)
			if not c_chest.is_empty():
				target_pos = _norm_to_screen(float(c_chest["x"]), float(c_chest["y"])) + Vector2(0, 26)
				has_click_target = true
				_open_secret_chest(c_chest)
				accept_event()
				return
			var e_idx: int = _find_enemy_near(click_p, 52.0)
			if e_idx != -1:
				var ed: Dictionary = stage_enemies[e_idx]
				target_pos = _norm_to_screen(float(ed["x"]), float(ed["y"])) + Vector2(-32, 12)
				has_click_target = true
				if player_pos.distance_to(_norm_to_screen(float(ed["x"]), float(ed["y"]))) <= 92.0:
					_perform_sword_strike()
				accept_event()
				return
			target_pos = _clamp_walk_pos(click_p)
			has_click_target = true
			accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if not nearby_chest.is_empty():
				_open_secret_chest(nearby_chest)
			elif not nearby_npc.is_empty():
				_interact_with_npc(nearby_npc)
			elif in_tabernacle:
				_use_tabernacle_sanctuary()
			accept_event()
		elif event.keycode == KEY_F or event.keycode == KEY_SPACE:
			_perform_sword_strike()
			accept_event()
		elif event.keycode == KEY_Q:
			_raise_shield_of_faith()
			accept_event()
		elif event.keycode == KEY_R:
			_consume_manna_ration()
			accept_event()
		elif event.keycode == KEY_T:
			trade_gathered_supplies()
			accept_event()

func _process(delta: float) -> void:
	anim_time += delta
	if portal_cooldown > 0.0:
		portal_cooldown = maxf(0.0, portal_cooldown - delta)
	if banner_timer > 0.0:
		banner_timer = maxf(0.0, banner_timer - delta)
	if shield_timer > 0.0:
		shield_timer = maxf(0.0, shield_timer - delta)
		if shield_timer <= 0.0:
			shield_active = false
	if attack_swing_timer > 0.0:
		attack_swing_timer = maxf(0.0, attack_swing_timer - delta)
	if attack_cooldown > 0.0:
		attack_cooldown = maxf(0.0, attack_cooldown - delta)

	for p_item in particles:
		var pt: Dictionary = p_item
		pt["y"] = float(pt["y"]) - float(pt["spd"]) * delta
		if float(pt["y"]) < 0.0:
			pt["y"] = 1.0

	var input_vec: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vec.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vec.x += 1.0

	is_walking = false
	if input_vec.length() > 0.01:
		has_click_target = false
		if absf(input_vec.x) > 0.05:
			facing_dir = 1.0 if input_vec.x > 0.0 else -1.0
		player_pos = _clamp_walk_pos(player_pos + input_vec.normalized() * move_speed * delta)
		is_walking = true
	elif has_click_target:
		var diff: Vector2 = target_pos - player_pos
		if diff.length() > 5.0:
			if absf(diff.x) > 1.0:
				facing_dir = 1.0 if diff.x > 0.0 else -1.0
			player_pos = _clamp_walk_pos(player_pos + diff.normalized() * move_speed * delta)
			is_walking = true
		else:
			has_click_target = false

	if is_walking:
		emit_signal("player_moved", current_stage, player_pos.x, player_pos.y)

	nearby_npc = _find_npc_near(player_pos, 64.0)
	nearby_chest = _find_chest_near(player_pos, 58.0)
	nearby_enemy_idx = _find_enemy_near(player_pos, 90.0)

	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var tab_norm: Vector2 = st.get("tabernacle_pos", Vector2(0.22, 0.48))
	var tab_pos: Vector2 = _norm_to_screen(tab_norm.x, tab_norm.y)
	var was_in_tab: bool = in_tabernacle
	in_tabernacle = player_pos.distance_to(tab_pos) <= 74.0
	if in_tabernacle and not was_in_tab:
		_use_tabernacle_sanctuary()

	if nearby_enemy_idx != -1:
		enemy_turn_timer += delta
		if enemy_turn_timer >= 1.65:
			enemy_turn_timer = 0.0
			var ed: Dictionary = stage_enemies[nearby_enemy_idx]
			if int(ed.get("hp", 0)) > 0:
				var raw_dmg: int = int(ed.get("atk", 15))
				var final_dmg: int = maxi(2, int(raw_dmg * 0.25)) if shield_active else raw_dmg
				spirit_hp = maxi(0, spirit_hp - final_dmg)
				if shield_active:
					_announce("SHIELD OF FAITH BLOCKED %s! (-%d Spirit)" % [str(ed["name"]), final_dmg], 2.5)
				else:
					_announce("%s struck you (-%d Spirit)! Press [Q] Shield or retreat to the Tabernacle!" % [str(ed["name"]), final_dmg], 3.0)
				if spirit_hp <= 0:
					spirit_hp = 50
					player_pos = tab_pos + Vector2(0, 38)
					target_pos = player_pos
					_announce("RETREATED TO TABERNACLE SANCTUARY ? Spirit Restored to 50!", 5.0)
	else:
		enemy_turn_timer = 0.0

	_check_portals()
	queue_redraw()

func _norm_to_screen(nx: float, ny: float) -> Vector2:
	var w: float = maxf(size.x, 800.0)
	var h: float = maxf(size.y, 540.0)
	return Vector2(nx * w, ny * h)

func _clamp_walk_pos(p: Vector2) -> Vector2:
	var w: float = maxf(size.x, 800.0)
	var h: float = maxf(size.y, 540.0)
	return Vector2(clampf(p.x, 34.0, w - 34.0), clampf(p.y, h * 0.35, h - 78.0))

func _find_npc_near(origin: Vector2, radius: float) -> Dictionary:
	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var npcs: Array = st.get("npcs", [])
	for item in npcs:
		var npc: Dictionary = item
		if origin.distance_to(_norm_to_screen(float(npc["x"]), float(npc["y"]))) <= radius:
			return npc
	return {}

func _find_chest_near(origin: Vector2, radius: float) -> Dictionary:
	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var chests: Array = st.get("chests", [])
	for item in chests:
		var ch: Dictionary = item
		if origin.distance_to(_norm_to_screen(float(ch["x"]), float(ch["y"]))) <= radius:
			return ch
	return {}

func _find_enemy_near(origin: Vector2, radius: float) -> int:
	for i in range(stage_enemies.size()):
		var ed: Dictionary = stage_enemies[i]
		if int(ed.get("hp", 0)) > 0:
			if origin.distance_to(_norm_to_screen(float(ed["x"]), float(ed["y"]))) <= radius:
				return i
	return -1

func trade_gathered_supplies() -> void:
	if timber_stock >= 100 and stone_stock >= 100:
		timber_stock -= 100
		stone_stock -= 100
		earned_talents += 25
		_announce("SUPPLY TRADE COMPLETED: -100 Timber & -100 Stone -> +25 Talents! (Total: %d Talents)" % earned_talents, 5.5)
		emit_signal("supplies_traded", 25)
	else:
		_announce("Need at least 100 Timber & 100 Stone to trade! Open Secret Chests [E] to gather supplies.", 4.5)

func _open_secret_chest(ch: Dictionary) -> void:
	var cid: String = str(ch.get("id", ""))
	if opened_chests.has(cid):
		_announce("Secret Chest already gathered (%s)." % str(ch.get("relic", "Relic")), 3.0)
		return
	opened_chests[cid] = true
	var add_t: int = int(ch.get("timber", 100))
	var add_s: int = int(ch.get("stone", 100))
	var add_o: int = int(ch.get("oil", 1))
	var add_m: int = int(ch.get("manna", 25))
	var relic_name: String = str(ch.get("relic", "Covenant Relic"))
	timber_stock += add_t
	stone_stock += add_s
	anointing_oil += add_o
	manna_rations += add_m
	if not relics_found.has(relic_name):
		relics_found.append(relic_name)
	var summary: String = "SECRET CHEST LOOTED! +%d Timber, +%d Stone, +%d Oil, +%d Manna & [%s] (Press [T] to Trade for Talents)" % [add_t, add_s, add_o, add_m, relic_name]
	_announce(summary, 6.5)
	emit_signal("chest_looted", cid, summary)

func _use_tabernacle_sanctuary() -> void:
	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var t_name: String = str(st.get("tabernacle_name", "Tabernacle Sanctuary"))
	spirit_hp = max_spirit_hp
	if anointing_oil > 0:
		anointing_oil -= 1
		shield_active = true
		shield_timer = 12.0
		_announce("%s: Spirit 100/100 & Sacred Oil Anointing Active (12s Shield)!" % t_name, 5.5)
	else:
		_announce("%s: Spirit Fully Restored to 100/100!" % t_name, 4.5)

func _consume_manna_ration() -> void:
	if manna_rations >= 15 and spirit_hp < max_spirit_hp:
		manna_rations -= 15
		spirit_hp = mini(max_spirit_hp, spirit_hp + 35)
		_announce("Ate Manna Rations (-15 Manna) -> Spirit Restored to %d/%d!" % [spirit_hp, max_spirit_hp], 3.5)
	else:
		_announce("Visit the Tabernacle or open Secret Chests for more Manna Rations!", 3.0)

func _raise_shield_of_faith() -> void:
	shield_active = true
	shield_timer = 4.5
	_announce("SHIELD OF FAITH RAISED! Incoming damage reduced by 75%!", 3.0)

func _perform_sword_strike() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.42
	attack_swing_timer = 0.28
	var idx: int = _find_enemy_near(player_pos, 98.0)
	if idx != -1:
		var ed: Dictionary = stage_enemies[idx]
		var dmg: int = 38 + (relics_found.size() * 8)
		var new_hp: int = maxi(0, int(ed.get("hp", 100)) - dmg)
		ed["hp"] = new_hp
		stage_enemies[idx] = ed
		if new_hp <= 0:
			var sc: int = int(ed.get("score", 40))
			var t_won: int = int(ed.get("talents", 35))
			earned_talents += t_won
			manna_rations += 20
			timber_stock += 50
			_announce("BATTLE VICTORY! Defeated %s (+%d Talents, +%d Score, +20 Manna)!" % [str(ed["name"]), t_won, sc], 6.5)
			emit_signal("battle_won", str(ed["name"]), sc, t_won)
		else:
			_announce("SWORD OF THE SPIRIT! Struck %s for %d DMG (%d/%d HP left)" % [str(ed["name"]), dmg, new_hp, int(ed["max_hp"])], 2.5)
	else:
		_announce("Sword of the Spirit drawn! Approach a Shadow Sentinel to strike.", 2.0)

func _interact_with_npc(npc: Dictionary) -> void:
	var n_name: String = str(npc.get("name", "Guide"))
	var sc_id: String = str(npc.get("scenario", "GEN_001"))
	var greet: String = str(npc.get("greeting", ""))
	_announce("%s: \"%s\"" % [n_name, greet], 7.0)
	emit_signal("npc_dialogue_triggered", n_name, current_stage, sc_id, greet)

func _check_portals() -> void:
	if portal_cooldown > 0.0:
		return
	var w: float = maxf(size.x, 800.0)
	var h: float = maxf(size.y, 540.0)
	var left_portal: Vector2 = Vector2(44.0, h * 0.56)
	var right_portal: Vector2 = Vector2(w - 44.0, h * 0.56)
	var idx: int = ERA_ORDER.find(current_stage)
	if player_pos.distance_to(right_portal) < 36.0:
		var next_era: String = ERA_ORDER[(idx + 1) % ERA_ORDER.size()]
		set_stage(next_era)
		emit_signal("stage_portal_entered", next_era)
	elif player_pos.distance_to(left_portal) < 36.0:
		var prev_era: String = ERA_ORDER[(idx - 1 + ERA_ORDER.size()) % ERA_ORDER.size()]
		set_stage(prev_era)
		emit_signal("stage_portal_entered", prev_era)

func _draw_humanoid_figure(base_pos: Vector2, tunic_col: Color, skin_col: Color, headgear: String, dir_x: float, stride_phase: float, has_sword: bool, swing_t: float, has_shield: bool, is_enemy: bool) -> void:
	# Ground drop shadow
	draw_circle(base_pos + Vector2(0.0, 22.0), 15.0, Color(0.0, 0.0, 0.0, 0.48))

	# Animated Legs & Sandals
	var leg_swing: float = sin(stride_phase) * 5.0
	var left_foot: Vector2 = base_pos + Vector2(-5.0 + leg_swing, 21.0)
	var right_foot: Vector2 = base_pos + Vector2(5.0 - leg_swing, 21.0)
	draw_line(base_pos + Vector2(-4.0, 8.0), left_foot, Color(0.24, 0.16, 0.10), 3.5)
	draw_line(base_pos + Vector2(4.0, 8.0), right_foot, Color(0.24, 0.16, 0.10), 3.5)

	# Flowing Tunic / Robe Body (Trapezoid)
	var robe_poly: PackedVector2Array = PackedVector2Array([
		base_pos + Vector2(-8.0, -10.0),
		base_pos + Vector2(8.0, -10.0),
		base_pos + Vector2(12.0, 12.0),
		base_pos + Vector2(-12.0, 12.0)
	])
	draw_colored_polygon(robe_poly, tunic_col)
	# Golden / Royal Sash Belt
	draw_line(base_pos + Vector2(-9.5, 0.0), base_pos + Vector2(9.5, 0.0), Color(0.95, 0.78, 0.26) if not is_enemy else Color(0.25, 0.05, 0.05), 3.0)

	# Arms
	var arm_off: float = -leg_swing * 0.6
	draw_line(base_pos + Vector2(-8.0, -7.0), base_pos + Vector2(-13.0, 3.0 + arm_off), tunic_col.lightened(0.15), 3.2)
	draw_line(base_pos + Vector2(8.0, -7.0), base_pos + Vector2(13.0, 3.0 - arm_off), tunic_col.lightened(0.15), 3.2)

	# Head & Hair / Beard
	var head_c: Vector2 = base_pos + Vector2(0.0, -18.0)
	draw_circle(head_c, 7.5, skin_col)
	if headgear == "prophet":
		# White/Grey Patriarchal Beard & Headcloth
		draw_arc(head_c, 8.2, PI, TAU, 16, Color(0.92, 0.88, 0.78), 3.0)
		var beard: PackedVector2Array = PackedVector2Array([head_c + Vector2(-5.0, 2.0), head_c + Vector2(5.0, 2.0), head_c + Vector2(0.0, 11.0)])
		draw_colored_polygon(beard, Color(0.86, 0.86, 0.88))
	elif headgear == "crown":
		# Royal Gold Crown
		draw_rect(Rect2(head_c.x - 7.0, head_c.y - 10.0, 14.0, 4.5), Color(0.98, 0.82, 0.22))
	elif headgear == "warrior":
		# Bronze Battle Helm
		draw_arc(head_c, 8.2, PI, TAU, 16, Color(0.76, 0.56, 0.24), 3.5)
	elif is_enemy:
		# Dark Iron Helmet & Glowing Eyes
		draw_arc(head_c, 8.5, PI, TAU, 16, Color(0.22, 0.22, 0.26), 4.0)
		draw_circle(head_c + Vector2(-2.5, -1.0), 1.6, Color(1.0, 0.25, 0.20))
		draw_circle(head_c + Vector2(2.5, -1.0), 1.6, Color(1.0, 0.25, 0.20))
	else:
		# Pilgrim Headband
		draw_line(head_c + Vector2(-7.0, -4.0), head_c + Vector2(7.0, -4.0), Color(0.95, 0.82, 0.35), 2.2)

	# Staff or Sword of the Spirit
	if has_sword:
		var sw_angle: float = -0.9 + (1.8 * (1.0 - swing_t / 0.28)) if swing_t > 0.0 else -0.35
		var hilt: Vector2 = base_pos + Vector2(dir_x * 12.0, -2.0)
		var tip: Vector2 = hilt + Vector2(dir_x * cos(sw_angle) * 26.0, sin(sw_angle) * 26.0)
		draw_line(hilt, tip, Color(0.92, 0.96, 1.0), 3.2)
		draw_line(hilt + Vector2(-3.0, 0.0), hilt + Vector2(3.0, 0.0), Color(0.98, 0.80, 0.24), 3.0)
	else:
		# Wooden Pilgrim Staff
		var sx: float = dir_x * 13.0
		draw_line(base_pos + Vector2(sx, -22.0), base_pos + Vector2(sx, 21.0), Color(0.54, 0.36, 0.18), 2.6)

	# Shield of Faith
	if has_shield:
		var sh_c: Vector2 = base_pos + Vector2(-dir_x * 13.0, 0.0)
		draw_circle(sh_c, 10.0, Color(0.24, 0.68, 0.96, 0.85))
		draw_arc(sh_c, 10.0, 0.0, TAU, 20, Color(0.98, 0.86, 0.36), 2.0)

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w < 40.0 or h < 40.0:
		return
	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var sky_top: Color = st["sky_top"]
	var sky_bot: Color = st["sky_bot"]
	var ground_col: Color = st["ground"]
	var accent_col: Color = st["accent"]
	var horizon: float = h * 0.34

	draw_rect(Rect2(0.0, 0.0, w, horizon * 0.55), sky_top)
	draw_rect(Rect2(0.0, horizon * 0.55, w, horizon * 0.45), sky_bot)
	draw_rect(Rect2(0.0, horizon, w, h - horizon), ground_col)
	draw_line(Vector2(0.0, horizon), Vector2(w, horizon), accent_col, 2.5)

	var sun_pos: Vector2 = Vector2(w * 0.78, horizon * 0.45)
	draw_circle(sun_pos, 46.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.14))
	draw_circle(sun_pos, 22.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.32))

	for m_i in range(6):
		var mx: float = (float(m_i) / 5.0) * w
		var ridge: PackedVector2Array = PackedVector2Array([
			Vector2(mx - 150.0, horizon),
			Vector2(mx, horizon - 54.0 - float(m_i % 2) * 28.0),
			Vector2(mx + 160.0, horizon)
		])
		draw_colored_polygon(ridge, Color(sky_bot.r * 0.85, sky_bot.g * 0.85, sky_bot.b * 0.85))

	var step_x: float = 96.0
	var gx: float = step_x
	while gx < w:
		draw_line(Vector2(gx, horizon), Vector2(gx, h), Color(1.0, 1.0, 1.0, 0.04), 1.0)
		gx += step_x

	for p_item in particles:
		var pt: Dictionary = p_item
		var p_xy: Vector2 = Vector2(float(pt["x"]) * w, float(pt["y"]) * h)
		draw_circle(p_xy, float(pt["rad"]), Color(accent_col.r, accent_col.g, accent_col.b, 0.28))

	var font: Font = ThemeDB.fallback_font

	# 1. TABERNACLE / SANCTUARY & TRADING POST
	var tab_norm: Vector2 = st.get("tabernacle_pos", Vector2(0.22, 0.48))
	var tab_pos: Vector2 = _norm_to_screen(tab_norm.x, tab_norm.y)
	var tab_pulse: float = 0.75 + 0.25 * sin(anim_time * 3.5)
	draw_circle(tab_pos, 72.0, Color(1.0, 0.85, 0.30, 0.14 * tab_pulse))
	draw_arc(tab_pos, 72.0, 0.0, TAU, 32, accent_col, 2.0)
	draw_rect(Rect2(tab_pos.x - 48.0, tab_pos.y - 38.0, 96.0, 44.0), Color(0.38, 0.24, 0.12))
	var roof: PackedVector2Array = PackedVector2Array([
		Vector2(tab_pos.x - 56.0, tab_pos.y - 38.0),
		Vector2(tab_pos.x, tab_pos.y - 68.0),
		Vector2(tab_pos.x + 56.0, tab_pos.y - 38.0)
	])
	draw_colored_polygon(roof, accent_col)
	var flame_sz: float = 8.0 + 3.0 * sin(anim_time * 11.0)
	draw_circle(tab_pos + Vector2(0.0, -14.0), flame_sz, Color(1.0, 0.62, 0.15))
	if font != null:
		draw_string(font, tab_pos + Vector2(-95.0, -74.0), str(st.get("tabernacle_name", "Tabernacle Sanctuary")), HORIZONTAL_ALIGNMENT_CENTER, 190, 12, Color(1.0, 0.94, 0.55))
		draw_string(font, tab_pos + Vector2(-95.0, 22.0), "[HEAL & TRADE SUPPLIES (T)]", HORIZONTAL_ALIGNMENT_CENTER, 190, 10, accent_col)

	# 2. SECRET CHESTS
	var chests: Array = st.get("chests", [])
	for c_item in chests:
		var ch: Dictionary = c_item
		var cpos: Vector2 = _norm_to_screen(float(ch["x"]), float(ch["y"]))
		var is_open: bool = opened_chests.has(str(ch.get("id", "")))
		draw_circle(cpos + Vector2(-14.0, 4.0), 16.0, Color(0.18, 0.22, 0.15))
		var box_col: Color = Color(0.35, 0.30, 0.24) if is_open else Color(0.76, 0.52, 0.16)
		draw_rect(Rect2(cpos.x - 14.0, cpos.y - 10.0, 28.0, 20.0), box_col)
		draw_rect(Rect2(cpos.x - 14.0, cpos.y - 10.0, 28.0, 6.0), Color(0.55, 0.55, 0.60) if is_open else Color(1.0, 0.86, 0.30))
		if not is_open:
			draw_arc(cpos, 22.0, 0.0, TAU, 20, Color(1.0, 0.88, 0.35, 0.55 * tab_pulse), 1.5)
		if font != null:
			var c_lbl: String = "OPENED" if is_open else "SECRET CHEST [E]"
			draw_string(font, cpos + Vector2(-60.0, -16.0), c_lbl, HORIZONTAL_ALIGNMENT_CENTER, 120, 10, Color(1.0, 0.92, 0.48) if not is_open else Color(0.65, 0.65, 0.68))

	# 3. SHADOW SENTINELS (HUMANOID WARRIORS)
	for e_item in stage_enemies:
		var ed: Dictionary = e_item
		var ehp: int = int(ed.get("hp", 0))
		if ehp > 0:
			var epos: Vector2 = _norm_to_screen(float(ed["x"]), float(ed["y"]))
			var emax: int = maxi(1, int(ed.get("max_hp", 100)))
			_draw_humanoid_figure(epos, Color(0.42, 0.10, 0.14), Color(0.62, 0.48, 0.42), "enemy", -1.0, anim_time * 2.0, true, 0.0, false, true)
			var bar_w: float = 56.0
			var pct: float = float(ehp) / float(emax)
			draw_rect(Rect2(epos.x - bar_w * 0.5, epos.y - 36.0, bar_w, 6.0), Color(0.15, 0.05, 0.05))
			draw_rect(Rect2(epos.x - bar_w * 0.5, epos.y - 36.0, bar_w * pct, 6.0), Color(0.95, 0.28, 0.24))
			if font != null:
				draw_string(font, epos + Vector2(-70.0, -42.0), "%s [F]" % str(ed.get("name", "Sentinel")), HORIZONTAL_ALIGNMENT_CENTER, 140, 11, Color(1.0, 0.72, 0.68))

	# 4. BIBLICAL NPCs (HUMANOID FIGURES)
	var npcs: Array = st.get("npcs", [])
	for n_item in npcs:
		var npc: Dictionary = n_item
		var npos: Vector2 = _norm_to_screen(float(npc["x"]), float(npc["y"]))
		var ncol: Color = npc.get("color", Color.GOLD)
		var hgear: String = str(npc.get("headgear", "prophet"))
		_draw_humanoid_figure(npos, ncol, Color(0.86, 0.70, 0.54), hgear, 1.0, 0.0, false, 0.0, false, false)
		if font != null:
			draw_string(font, npos + Vector2(-52.0, -34.0), "%s [E]" % str(npc.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 104, 12, Color(1.0, 0.96, 0.84))

	# 5. REMOTE MULTIPLAYER PILGRIMS (HUMANOID FIGURES)
	for rp_item in remote_pilgrims:
		var rp: Dictionary = rp_item
		if str(rp.get("stage", "")) == current_stage:
			var rpos: Vector2 = Vector2(float(rp.get("x", 200.0)), float(rp.get("y", 200.0)))
			var r_robe_key: String = str(rp.get("robe", "Galilee Cyan"))
			var r_col: Color = ROBE_PALETTE.get(r_robe_key, Color(0.35, 0.85, 1.0))
			_draw_humanoid_figure(rpos, r_col, Color(0.88, 0.72, 0.56), "pilgrim", 1.0, anim_time * 4.0, false, 0.0, false, false)
			if font != null:
				draw_string(font, rpos + Vector2(-54.0, -34.0), str(rp.get("name", "Pilgrim")), HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color(0.78, 0.96, 1.0))

	# 6. LOCAL PLAYER AVATAR (ARTICULATED HUMANOID PILGRIM / WARRIOR)
	var stride: float = anim_time * 12.0 if is_walking else 0.0
	var my_robe: Color = ROBE_PALETTE.get(local_robe_name, Color(0.18, 0.48, 0.92))
	var in_combat: bool = (nearby_enemy_idx != -1 or attack_swing_timer > 0.0)
	_draw_humanoid_figure(player_pos, my_robe, Color(0.90, 0.74, 0.58), "pilgrim", facing_dir, stride, in_combat, attack_swing_timer, shield_active, false)

	# 7. LEFT & RIGHT STAGE PORTALS
	var left_p: Vector2 = Vector2(44.0, h * 0.56)
	var right_p: Vector2 = Vector2(w - 44.0, h * 0.56)
	draw_circle(left_p, 26.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.26 * tab_pulse))
	draw_arc(left_p, 26.0, 0.0, TAU, 28, accent_col, 2.5)
	draw_circle(right_p, 26.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.26 * tab_pulse))
	draw_arc(right_p, 26.0, 0.0, TAU, 28, accent_col, 2.5)

	# 8. DIEGETIC TOP HUD (SHOWING EARNED TALENTS, SPIRIT, SUPPLIES & CONTROLS)
	if font != null:
		draw_rect(Rect2(12.0, 10.0, w - 24.0, 52.0), Color(0.05, 0.05, 0.08, 0.86))
		draw_string(font, Vector2(22.0, 30.0), "%s   |   TALENTS: %d   |   SPIRIT: %d/%d   |   MANNA: %d [R]   |   OIL: %d   |   TIMBER: %d   |   STONE: %d" % [str(st["title"]), earned_talents, spirit_hp, max_spirit_hp, manna_rations, anointing_oil, timber_stock, stone_stock], HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 13, accent_col)
		draw_string(font, Vector2(22.0, 50.0), "Earn Talents: Battle Sentinels [F]  |  Trade Supplies [T] (-100 Timber/Stone = +25 Talents)  |  Answer Trivia [E]  |  Shield [Q]", HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 11, Color(0.88, 0.90, 0.95))

		draw_string(font, player_pos + Vector2(-54.0, -34.0), local_pilgrim_name, HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color.WHITE)
		draw_string(font, Vector2(14.0, h * 0.56 + 40.0), "< PREV ERA", HORIZONTAL_ALIGNMENT_LEFT, 96, 11, accent_col)
		draw_string(font, Vector2(w - 96.0, h * 0.56 + 40.0), "NEXT ERA >", HORIZONTAL_ALIGNMENT_RIGHT, 84, 11, accent_col)

		if banner_timer > 0.0 and banner_text != "":
			draw_rect(Rect2(16.0, h - 98.0, w - 32.0, 28.0), Color(0.06, 0.05, 0.09, 0.92))
			draw_string(font, Vector2(24.0, h - 79.0), banner_text, HORIZONTAL_ALIGNMENT_LEFT, int(w - 48.0), 13, Color(1.0, 0.94, 0.58))
