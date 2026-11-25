extends Control
class_name SovereignImmersiveWorld

signal npc_dialogue_triggered(npc_name: String, era_id: String, scenario_id: String, greeting: String)
signal stage_portal_entered(target_era_id: String)
signal player_moved(stage_id: String, pos_x: float, pos_y: float)
signal chest_looted(chest_id: String, loot_summary: String)
signal battle_won(enemy_name: String, reward_score: int, reward_talents: int)
signal supplies_traded(talents_gained: int)
signal trial_requested()
signal armory_toggled()
signal armory_updated(talents_left: int, sword_lvl: int, armor_lvl: int, boots_lvl: int)

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
		"title": "I. SINAI ENCAMPMENT, OASIS RIVER & WILDERNESS TABERNACLE",
		"sky_top": Color(0.06, 0.05, 0.11),
		"sky_bot": Color(0.22, 0.14, 0.08),
		"ground": Color(0.29, 0.21, 0.12),
		"grass": Color(0.22, 0.28, 0.14),
		"river": Color(0.14, 0.46, 0.68),
		"wall": Color(0.44, 0.36, 0.26),
		"accent": Color(0.96, 0.78, 0.28),
		"river_x": 0.58,
		"village_name": "Kadesh Oasis Encampment",
		"tabernacle_name": "Tabernacle & Trading Post",
		"tabernacle_pos": Vector2(0.22, 0.48),
		"merchant_pos": Vector2(0.14, 0.64),
		"plot_pos": Vector2(0.40, 0.78),
		"npcs": [
			{"name": "Moses", "x": 0.31, "y": 0.58, "color": Color(0.88, 0.68, 0.24), "headgear": "prophet", "scenario": "GEN_001", "greeting": "Defeat raiders [F] to unlock Scripture Trivia, visit the Village Armory [M], or build your House [B]!"},
			{"name": "Caleb", "x": 0.48, "y": 0.65, "color": Color(0.24, 0.68, 0.42), "headgear": "warrior", "scenario": "TOR_005", "greeting": "Spend earned Talents at Eliakim's Traveling Armory [M] to forge stronger blades and armor!"}
		],
		"chests": [
			{"id": "CHEST_TOR_1", "x": 0.10, "y": 0.80, "timber": 140, "stone": 120, "oil": 2, "manna": 30, "relic": "Bronze Altar Ember"},
			{"id": "CHEST_TOR_2", "x": 0.87, "y": 0.46, "timber": 160, "stone": 140, "oil": 1, "manna": 40, "relic": "Ark Cedar Plank"}
		],
		"enemies": [
			{"name": "Amalekite Raider", "archetype": "raider", "ability": "Swift Ambush", "x": 0.72, "y": 0.56, "hp": 95, "max_hp": 95, "atk": 13, "spd": 135.0, "armor": 0, "score": 35, "talents": 35},
			{"name": "Anakite Giant", "archetype": "giant", "ability": "Earthshaker Slam", "x": 0.83, "y": 0.72, "hp": 155, "max_hp": 155, "atk": 22, "spd": 78.0, "armor": 6, "score": 55, "talents": 55}
		]
	},
	"ERA_HISTORY": {
		"title": "II. FORTIFIED WALLS OF JERUSALEM & JORDAN RIVER",
		"sky_top": Color(0.04, 0.08, 0.14),
		"sky_bot": Color(0.14, 0.22, 0.26),
		"ground": Color(0.20, 0.25, 0.17),
		"grass": Color(0.16, 0.30, 0.16),
		"river": Color(0.12, 0.48, 0.72),
		"wall": Color(0.50, 0.46, 0.38),
		"accent": Color(0.45, 0.86, 0.58),
		"river_x": 0.56,
		"village_name": "Gilgal & Jerusalem Village",
		"tabernacle_name": "Shiloh Sanctuary & Supply Post",
		"tabernacle_pos": Vector2(0.21, 0.48),
		"merchant_pos": Vector2(0.14, 0.64),
		"plot_pos": Vector2(0.40, 0.78),
		"npcs": [
			{"name": "Joshua", "x": 0.32, "y": 0.60, "color": Color(0.84, 0.36, 0.24), "headgear": "warrior", "scenario": "HIS_001", "greeting": "Upgrade your Sword of the Spirit at the Village Armory [M] to pierce Iron Bulwark armor!"},
			{"name": "Nehemiah", "x": 0.48, "y": 0.52, "color": Color(0.28, 0.60, 0.88), "headgear": "builder", "scenario": "HIS_005", "greeting": "Walk to the Homestead Plot and press [B] to raise your walls stone by stone!"}
		],
		"chests": [
			{"id": "CHEST_HIS_1", "x": 0.10, "y": 0.80, "timber": 140, "stone": 160, "oil": 2, "manna": 35, "relic": "Gilgal Memorial Stone"},
			{"id": "CHEST_HIS_2", "x": 0.87, "y": 0.78, "timber": 180, "stone": 200, "oil": 2, "manna": 45, "relic": "Nehemiah's Trowel"}
		],
		"enemies": [
			{"name": "Jericho Sentinel", "archetype": "sentinel", "ability": "Iron Bulwark", "x": 0.73, "y": 0.56, "hp": 140, "max_hp": 140, "atk": 17, "spd": 92.0, "armor": 10, "score": 45, "talents": 45},
			{"name": "Sanballat Raider", "archetype": "raider", "ability": "Flanking Dash", "x": 0.82, "y": 0.72, "hp": 115, "max_hp": 115, "atk": 18, "spd": 142.0, "armor": 2, "score": 55, "talents": 55}
		]
	},
	"ERA_WISDOM": {
		"title": "III. CITY OF DAVID, KIDRON STREAM & TEMPLE WALLS",
		"sky_top": Color(0.08, 0.05, 0.15),
		"sky_bot": Color(0.22, 0.14, 0.28),
		"ground": Color(0.24, 0.18, 0.25),
		"grass": Color(0.20, 0.26, 0.18),
		"river": Color(0.16, 0.44, 0.70),
		"wall": Color(0.56, 0.50, 0.40),
		"accent": Color(0.98, 0.84, 0.36),
		"river_x": 0.57,
		"village_name": "Mount Zion Royal Quarter",
		"tabernacle_name": "Golden Temple Sanctuary",
		"tabernacle_pos": Vector2(0.22, 0.47),
		"merchant_pos": Vector2(0.14, 0.64),
		"plot_pos": Vector2(0.40, 0.78),
		"npcs": [
			{"name": "King David", "x": 0.33, "y": 0.60, "color": Color(0.92, 0.72, 0.22), "headgear": "crown", "scenario": "WIS_001", "greeting": "Equip Breastplate Armor and Speed Boots at the Armory [M] before challenging the Philistine Champion!"},
			{"name": "Solomon", "x": 0.49, "y": 0.52, "color": Color(0.68, 0.42, 0.92), "headgear": "crown", "scenario": "WIS_004", "greeting": "Trade cedar timber and hewn stone [T] at the Temple treasury for Talents."}
		],
		"chests": [
			{"id": "CHEST_WIS_1", "x": 0.10, "y": 0.79, "timber": 200, "stone": 180, "oil": 3, "manna": 40, "relic": "Davidic Harp String"},
			{"id": "CHEST_WIS_2", "x": 0.86, "y": 0.47, "timber": 220, "stone": 220, "oil": 2, "manna": 50, "relic": "Seal of Wisdom"}
		],
		"enemies": [
			{"name": "Philistine Champion", "archetype": "giant", "ability": "Goliath Cleave", "x": 0.77, "y": 0.63, "hp": 185, "max_hp": 185, "atk": 24, "spd": 88.0, "armor": 12, "score": 65, "talents": 75}
		]
	},
	"ERA_PROPHETS": {
		"title": "IV. WATCHTOWER CITADEL, EUPHRATES CANAL & VILLAGE",
		"sky_top": Color(0.10, 0.04, 0.06),
		"sky_bot": Color(0.24, 0.10, 0.10),
		"ground": Color(0.24, 0.15, 0.14),
		"grass": Color(0.22, 0.24, 0.15),
		"river": Color(0.14, 0.42, 0.64),
		"wall": Color(0.48, 0.38, 0.32),
		"accent": Color(0.98, 0.56, 0.32),
		"river_x": 0.57,
		"village_name": "Anathoth Watchman Village",
		"tabernacle_name": "Altar of Burning Coals",
		"tabernacle_pos": Vector2(0.21, 0.48),
		"merchant_pos": Vector2(0.14, 0.64),
		"plot_pos": Vector2(0.40, 0.78),
		"npcs": [
			{"name": "Isaiah", "x": 0.32, "y": 0.58, "color": Color(0.90, 0.54, 0.24), "headgear": "prophet", "scenario": "PRO_001", "greeting": "Watchmen stand upon the walls! Cross the canal bridge to repel the Siege Warden."},
			{"name": "Jeremiah", "x": 0.48, "y": 0.65, "color": Color(0.45, 0.70, 0.84), "headgear": "prophet", "scenario": "PRO_004", "greeting": "Buy the field with silver (Talents) and seal the deed!"}
		],
		"chests": [
			{"id": "CHEST_PRO_1", "x": 0.10, "y": 0.80, "timber": 160, "stone": 190, "oil": 3, "manna": 45, "relic": "Prophetic Scroll Cylinder"}
		],
		"enemies": [
			{"name": "Babylonian Siege Warden", "archetype": "sentinel", "ability": "Siege Fire Volley", "x": 0.77, "y": 0.62, "hp": 190, "max_hp": 190, "atk": 23, "spd": 96.0, "armor": 14, "score": 70, "talents": 80}
		]
	},
	"ERA_GOSPELS": {
		"title": "V. CAPERNAUM FISHING VILLAGE, SEA OF GALILEE & STONE HARBOR",
		"sky_top": Color(0.04, 0.09, 0.16),
		"sky_bot": Color(0.09, 0.24, 0.30),
		"ground": Color(0.15, 0.27, 0.20),
		"grass": Color(0.14, 0.32, 0.18),
		"river": Color(0.10, 0.52, 0.76),
		"wall": Color(0.46, 0.44, 0.40),
		"accent": Color(0.42, 0.90, 0.96),
		"river_x": 0.57,
		"village_name": "Capernaum Harbor Village",
		"tabernacle_name": "House of Prayer Sanctuary",
		"tabernacle_pos": Vector2(0.21, 0.48),
		"merchant_pos": Vector2(0.14, 0.64),
		"plot_pos": Vector2(0.40, 0.78),
		"npcs": [
			{"name": "Peter", "x": 0.33, "y": 0.60, "color": Color(0.28, 0.74, 0.92), "headgear": "pilgrim", "scenario": "GOS_001", "greeting": "Welcome to Capernaum! Upgrade your Boots [M] to outrun Shadow Bolts across the harbor bridge."},
			{"name": "Good Samaritan", "x": 0.49, "y": 0.54, "color": Color(0.36, 0.84, 0.54), "headgear": "pilgrim", "scenario": "GOS_004", "greeting": "Visit the Sanctuary whenever your health bar drops low."}
		],
		"chests": [
			{"id": "CHEST_GOS_1", "x": 0.10, "y": 0.79, "timber": 190, "stone": 150, "oil": 3, "manna": 60, "relic": "Five Loaves Basket"}
		],
		"enemies": [
			{"name": "Tempest Shadow Spirit", "archetype": "spirit", "ability": "Shadow Bolt & Drain", "x": 0.77, "y": 0.63, "hp": 195, "max_hp": 195, "atk": 25, "spd": 124.0, "armor": 8, "score": 80, "talents": 90}
		]
	},
	"ERA_EPISTLES": {
		"title": "VI. ANTIOCH WALLED CITY, RIVER ORONTES & UPPER ROOM",
		"sky_top": Color(0.07, 0.06, 0.14),
		"sky_bot": Color(0.16, 0.12, 0.26),
		"ground": Color(0.20, 0.19, 0.26),
		"grass": Color(0.18, 0.26, 0.20),
		"river": Color(0.14, 0.46, 0.72),
		"wall": Color(0.52, 0.48, 0.44),
		"accent": Color(0.98, 0.84, 0.42),
		"river_x": 0.57,
		"village_name": "Antioch Covenant Quarter",
		"tabernacle_name": "Upper Room Flame Sanctuary",
		"tabernacle_pos": Vector2(0.22, 0.48),
		"merchant_pos": Vector2(0.14, 0.64),
		"plot_pos": Vector2(0.40, 0.78),
		"npcs": [
			{"name": "Apostle Paul", "x": 0.33, "y": 0.58, "color": Color(0.92, 0.74, 0.28), "headgear": "prophet", "scenario": "EPI_001", "greeting": "Put on the full Armor of God at the Armory [M] and stand victorious against Principalities!"},
			{"name": "Barnabas", "x": 0.49, "y": 0.65, "color": Color(0.50, 0.82, 0.46), "headgear": "pilgrim", "scenario": "EPI_004", "greeting": "Press [T] to trade chest supplies for Talents."}
		],
		"chests": [
			{"id": "CHEST_EPI_1", "x": 0.86, "y": 0.77, "timber": 250, "stone": 250, "oil": 4, "manna": 75, "relic": "Full Armor of God Seal"}
		],
		"enemies": [
			{"name": "Principalities Vanguard", "archetype": "spirit", "ability": "Fiery Dart & Nova", "x": 0.77, "y": 0.62, "hp": 230, "max_hp": 230, "atk": 28, "spd": 128.0, "armor": 14, "score": 110, "talents": 120}
		]
	}
}

var current_stage: String = "ERA_TORAH"
var player_pos: Vector2 = Vector2(340.0, 340.0)
var target_pos: Vector2 = Vector2(340.0, 340.0)
var has_click_target: bool = false
var is_walking: bool = false
var facing_dir: float = 1.0
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
var enemy_projectiles: Array = []

# Phase 40: Traveling Merchant & Armory Upgrade Levels (Lv.1 -> Lv.5)
var sword_level: int = 1
var armor_level: int = 1
var boots_level: int = 1

var land_deeds: Dictionary = {}
var house_stages: Dictionary = {}
var labor_credits: int = 0
var trivia_wins: int = 0
var battle_wins_count: int = 0
var pending_victory_trivia: bool = false

var shield_active: bool = false
var shield_timer: float = 0.0
var attack_swing_timer: float = 0.0
var attack_cooldown: float = 0.0
var player_hit_flash: float = 0.0

var nearby_npc: Dictionary = {}
var nearby_chest: Dictionary = {}
var nearby_enemy_idx: int = -1
var near_homestead_plot: bool = false
var near_merchant: bool = false
var in_tabernacle: bool = false

var banner_text: String = "Visit the Traveling Merchant Armory [M] in the village to upgrade Sword, Armor & Speed Boots!"
var banner_timer: float = 9.0
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

func get_current_move_speed() -> float:
	return 240.0 + float(boots_level - 1) * 32.0

func get_sword_damage() -> int:
	return 42 + ((sword_level - 1) * 14) + (relics_found.size() * 8)

func get_player_armor() -> int:
	return (armor_level - 1) * 5

func get_upgrade_cost(cur_lvl: int, base_cost: int) -> int:
	if cur_lvl >= 5:
		return 0
	return base_cost + (cur_lvl - 1) * 55

func buy_sword_upgrade() -> void:
	if sword_level >= 5:
		_announce("SWORD OF THE SPIRIT IS ALREADY MAXED AT LV.5!", 4.0)
		return
	var cost: int = get_upgrade_cost(sword_level, 60)
	if earned_talents >= cost:
		earned_talents -= cost
		sword_level += 1
		_announce("ARMORY UPGRADE: Sword of the Spirit forged to Lv.%d (-%d Talents | %d Base DMG)!" % [sword_level, cost, get_sword_damage()], 6.0)
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	else:
		_announce("Need %d Earned Talents for Sword Lv.%d (you have %d Talents)." % [cost, sword_level + 1, earned_talents], 4.5)

func buy_armor_upgrade() -> void:
	if armor_level >= 5:
		_announce("BREASTPLATE OF RIGHTEOUSNESS IS ALREADY MAXED AT LV.5!", 4.0)
		return
	var cost: int = get_upgrade_cost(armor_level, 55)
	if earned_talents >= cost:
		earned_talents -= cost
		armor_level += 1
		max_spirit_hp += 15
		spirit_hp = mini(max_spirit_hp, spirit_hp + 15)
		_announce("ARMORY UPGRADE: Breastplate Armor Lv.%d (-%d Talents | -%d DMG Mitigation & +15 Max HP)!" % [armor_level, cost, get_player_armor()], 6.0)
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	else:
		_announce("Need %d Earned Talents for Breastplate Lv.%d (you have %d Talents)." % [cost, armor_level + 1, earned_talents], 4.5)

func buy_boots_upgrade() -> void:
	if boots_level >= 5:
		_announce("SANDALS OF PEACE ARE ALREADY MAXED AT LV.5!", 4.0)
		return
	var cost: int = get_upgrade_cost(boots_level, 50)
	if earned_talents >= cost:
		earned_talents -= cost
		boots_level += 1
		_announce("ARMORY UPGRADE: Gospel Speed Boots Lv.%d (-%d Talents | Speed %d)!" % [boots_level, cost, int(get_current_move_speed())], 6.0)
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	else:
		_announce("Need %d Earned Talents for Speed Boots Lv.%d (you have %d Talents)." % [cost, boots_level + 1, earned_talents], 4.5)

func set_stage(era_id: String) -> void:
	if WORLD_STAGES.has(era_id):
		current_stage = era_id
		var w: float = maxf(size.x, 1024.0)
		var h: float = maxf(size.y, 640.0)
		player_pos = Vector2(w * 0.36, h * 0.62)
		target_pos = player_pos
		has_click_target = false
		portal_cooldown = 0.8
		enemy_projectiles.clear()
		stage_enemies.clear()
		var st: Dictionary = WORLD_STAGES[era_id]
		var raw_enemies: Array = st.get("enemies", [])
		for e_item in raw_enemies:
			var ed: Dictionary = e_item
			var copy_e: Dictionary = ed.duplicate(true)
			copy_e["pos"] = _norm_to_screen(float(copy_e["x"]), float(copy_e["y"]))
			copy_e["home_pos"] = copy_e["pos"]
			copy_e["atk_timer"] = 1.1
			copy_e["ability_timer"] = 2.6
			copy_e["telegraph_timer"] = 0.0
			copy_e["swing_timer"] = 0.0
			copy_e["dir_x"] = -1.0
			stage_enemies.append(copy_e)
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
	trivia_wins += 1
	labor_credits += 1
	pending_victory_trivia = false
	emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	_announce("TRIVIA MASTERED! +%d Talents & +1 Builder Task Credit earned! (Credits: %d | Talents: %d)" % [amount, labor_credits, earned_talents], 6.5)

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
			var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
			var m_norm: Vector2 = st.get("merchant_pos", Vector2(0.14, 0.64))
			var merch_screen: Vector2 = _norm_to_screen(m_norm.x, m_norm.y)
			if click_p.distance_to(merch_screen) <= 56.0:
				target_pos = merch_screen + Vector2(36, 12)
				has_click_target = true
				emit_signal("armory_toggled")
				accept_event()
				return
			var p_norm: Vector2 = st.get("plot_pos", Vector2(0.40, 0.78))
			var plot_screen: Vector2 = _norm_to_screen(p_norm.x, p_norm.y)
			if click_p.distance_to(plot_screen) <= 58.0:
				target_pos = plot_screen + Vector2(0, -34)
				has_click_target = true
				acquire_or_build_homestead()
				accept_event()
				return
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
			var e_idx: int = _find_enemy_near(click_p, 56.0)
			if e_idx != -1:
				var ed: Dictionary = stage_enemies[e_idx]
				var epos: Vector2 = ed.get("pos", _norm_to_screen(float(ed["x"]), float(ed["y"])))
				target_pos = epos + Vector2(-34, 10)
				has_click_target = true
				if player_pos.distance_to(epos) <= 98.0:
					_perform_sword_strike()
				accept_event()
				return
			target_pos = _clamp_walk_pos(click_p)
			has_click_target = true
			accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if near_merchant:
				emit_signal("armory_toggled")
			elif not nearby_chest.is_empty():
				_open_secret_chest(nearby_chest)
			elif not nearby_npc.is_empty():
				_interact_with_npc(nearby_npc)
			elif in_tabernacle:
				_use_tabernacle_sanctuary()
			accept_event()
		elif event.keycode == KEY_M:
			emit_signal("armory_toggled")
			accept_event()
		elif event.keycode == KEY_B:
			acquire_or_build_homestead()
			accept_event()
		elif event.keycode == KEY_Y:
			emit_signal("trial_requested")
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

func acquire_or_build_homestead() -> void:
	var has_deed: bool = bool(land_deeds.get(current_stage, false))
	var cur_lvl: int = int(house_stages.get(current_stage, 0))

	if not has_deed:
		if earned_talents >= 120:
			earned_talents -= 120
			land_deeds[current_stage] = true
			emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
			_announce("LAND DEED PURCHASED (-120 Talents)! Now gather Timber/Stone & win Battles/Trivia to build Stage 1 [B]!", 6.5)
		elif battle_wins_count >= 1 and trivia_wins >= 1:
			land_deeds[current_stage] = true
			_announce("LAND DEED EARNED BY LABOR (Battle + Scripture Trivia)! Press [B] with Timber & Stone to lay the Foundation!", 6.5)
		else:
			_announce("LAND LOCKED: Buy Deed (120 Talents, you have %d) OR earn it via 1 Battle Win (%d/1) + 1 Trivia Win (%d/1)!" % [earned_talents, battle_wins_count, trivia_wins], 6.5)
		return

	if cur_lvl >= 4:
		_announce("COVENANT MANOR COMPLETE (4/4)! Your consecrated homestead grants +25 Max Health & Sanctuary Rest!", 5.5)
		return

	if labor_credits < 1:
		_announce("CONSTRUCTION TASK REQUIRED: Defeat a Sentinel [F] or answer Scripture Trivia [Y] to earn 1 Builder Task Credit!", 6.0)
		return

	if cur_lvl == 0:
		if stone_stock >= 80:
			stone_stock -= 80
			labor_credits -= 1
			house_stages[current_stage] = 1
			_announce("HOUSE STAGE 1/4 BUILT ON-SCREEN: Hewn Stone Foundation laid! (-80 Stone, -1 Task Credit)", 6.0)
		else:
			_announce("Need 80 Stone for Stage 1 Foundation (you have %d Stone). Loot Secret Chests [E]!" % stone_stock, 5.0)
	elif cur_lvl == 1:
		if timber_stock >= 100 and stone_stock >= 60:
			timber_stock -= 100
			stone_stock -= 60
			labor_credits -= 1
			house_stages[current_stage] = 2
			_announce("HOUSE STAGE 2/4 BUILT ON-SCREEN: Cedar Timber Framing & Limestone Walls raised!", 6.0)
		else:
			_announce("Need 100 Timber & 60 Stone for Stage 2 Walls (have %d Timber, %d Stone)." % [timber_stock, stone_stock], 5.0)
	elif cur_lvl == 2:
		if timber_stock >= 120 and stone_stock >= 80:
			timber_stock -= 120
			stone_stock -= 80
			labor_credits -= 1
			house_stages[current_stage] = 3
			_announce("HOUSE STAGE 3/4 BUILT ON-SCREEN: Roof Beams, Watch Lantern & Courtyard completed!", 6.0)
		else:
			_announce("Need 120 Timber & 80 Stone for Stage 3 Roof & Lantern (have %d Timber, %d Stone)." % [timber_stock, stone_stock], 5.0)
	elif cur_lvl == 3:
		if timber_stock >= 100 and stone_stock >= 100 and earned_talents >= 50:
			timber_stock -= 100
			stone_stock -= 100
			earned_talents -= 50
			labor_credits -= 1
			house_stages[current_stage] = 4
			max_spirit_hp += 25
			spirit_hp = max_spirit_hp
			emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
			_announce("HOUSE STAGE 4/4 COMPLETE: CONSECRATED COVENANT MANOR! (+25 Max Health & Full Heal!)", 7.5)
		else:
			_announce("Need 100 Timber, 100 Stone & 50 Talents for Stage 4 Covenant Manor!", 5.0)

func _apply_damage_to_player(raw_dmg: int, attacker_label: String, tab_pos: Vector2) -> void:
	var armor_mitigated: int = maxi(3, raw_dmg - get_player_armor())
	var final_dmg: int = maxi(2, int(armor_mitigated * 0.22)) if shield_active else armor_mitigated
	spirit_hp = maxi(0, spirit_hp - final_dmg)
	player_hit_flash = 0.25
	if shield_active:
		_announce("SHIELD OF FAITH DEFLECTED %s! (-%d HP)" % [attacker_label, final_dmg], 2.5)
	else:
		_announce("%s hit you for -%d HP (Armor -%d)! Raise Shield [Q] or retreat to Tabernacle!" % [attacker_label, final_dmg, get_player_armor()], 3.2)
	if spirit_hp <= 0:
		spirit_hp = 55
		player_pos = tab_pos + Vector2(0, 42)
		target_pos = player_pos
		has_click_target = false
		enemy_projectiles.clear()
		_announce("RETREATED TO TABERNACLE SANCTUARY ? Health Restored to 55/%d!" % max_spirit_hp, 5.0)

func _update_enemies_ai(delta: float, tab_pos: Vector2) -> void:
	var w: float = maxf(size.x, 800.0)
	var h: float = maxf(size.y, 540.0)
	for i in range(stage_enemies.size()):
		var ed: Dictionary = stage_enemies[i]
		if int(ed.get("hp", 0)) <= 0:
			continue

		var epos: Vector2 = ed.get("pos", _norm_to_screen(float(ed["x"]), float(ed["y"])))
		var home: Vector2 = ed.get("home_pos", epos)
		var spd: float = float(ed.get("spd", 100.0))
		var arch: String = str(ed.get("archetype", "raider"))
		var e_name: String = str(ed.get("name", "Sentinel"))
		var abil_name: String = str(ed.get("ability", "Strike"))
		var raw_atk: int = int(ed.get("atk", 15))

		var sw_t: float = maxf(0.0, float(ed.get("swing_timer", 0.0)) - delta)
		ed["swing_timer"] = sw_t

		var dist_to_player: float = epos.distance_to(player_pos)
		var dist_to_tab: float = player_pos.distance_to(tab_pos)
		var aggro_range: float = 340.0 if arch == "spirit" else 295.0

		if dist_to_tab <= 78.0:
			var to_home: Vector2 = home - epos
			if to_home.length() > 6.0:
				epos += to_home.normalized() * spd * 0.7 * delta
				ed["dir_x"] = 1.0 if to_home.x >= 0.0 else -1.0
			ed["telegraph_timer"] = 0.0
			ed["pos"] = epos
			stage_enemies[i] = ed
			continue

		if dist_to_player <= aggro_range:
			var to_p: Vector2 = player_pos - epos
			if absf(to_p.x) > 2.0:
				ed["dir_x"] = 1.0 if to_p.x > 0.0 else -1.0

			var tele_t: float = float(ed.get("telegraph_timer", 0.0))
			if tele_t > 0.0:
				tele_t -= delta
				ed["telegraph_timer"] = tele_t
				if tele_t <= 0.0:
					ed["swing_timer"] = 0.35
					if arch == "giant":
						if epos.distance_to(player_pos) <= 118.0:
							_apply_damage_to_player(int(raw_atk * 1.45), "%s [%s]" % [e_name, abil_name], tab_pos)
						else:
							_announce("EVADED %s's %s shockwave!" % [e_name, abil_name], 2.5)
					elif arch == "raider":
						epos = _clamp_walk_pos(epos + to_p.normalized() * 88.0)
						if epos.distance_to(player_pos) <= 78.0:
							_apply_damage_to_player(int(raw_atk * 1.25), "%s [%s]" % [e_name, abil_name], tab_pos)
					elif arch == "spirit":
						enemy_projectiles.append({
							"pos": epos,
							"vel": to_p.normalized() * 265.0,
							"dmg": int(raw_atk * 1.15),
							"owner": "%s [%s]" % [e_name, abil_name],
							"life": 2.4
						})
					else:
						if epos.distance_to(player_pos) <= 88.0:
							_apply_damage_to_player(int(raw_atk * 1.30), "%s [%s]" % [e_name, abil_name], tab_pos)
			else:
				var desired_range: float = 155.0 if arch == "spirit" else 48.0
				if dist_to_player > desired_range:
					epos = _clamp_walk_pos(epos + to_p.normalized() * spd * delta)

				var atk_t: float = float(ed.get("atk_timer", 1.2)) - delta
				if atk_t <= 0.0 and dist_to_player <= 68.0:
					atk_t = 1.45
					ed["swing_timer"] = 0.30
					_apply_damage_to_player(raw_atk, e_name, tab_pos)
				ed["atk_timer"] = atk_t

				var ab_t: float = float(ed.get("ability_timer", 3.0)) - delta
				if ab_t <= 0.0:
					ab_t = 4.2
					ed["telegraph_timer"] = 0.95
					_announce("WARNING: %s is charging %s! Raise Shield [Q] or dodge!" % [e_name, abil_name], 2.2)
				ed["ability_timer"] = ab_t
		else:
			var back: Vector2 = home - epos
			if back.length() > 6.0:
				epos += back.normalized() * spd * 0.5 * delta

		ed["pos"] = Vector2(clampf(epos.x, 40.0, w - 40.0), clampf(epos.y, h * 0.35, h - 78.0))
		stage_enemies[i] = ed

	var alive_proj: Array = []
	for p_obj in enemy_projectiles:
		var pr: Dictionary = p_obj
		var p_pos: Vector2 = pr["pos"] + pr["vel"] * delta
		var life: float = float(pr["life"]) - delta
		pr["pos"] = p_pos
		pr["life"] = life
		if p_pos.distance_to(player_pos) <= 24.0:
			_apply_damage_to_player(int(pr["dmg"]), str(pr["owner"]), tab_pos)
		elif life > 0.0 and p_pos.x > 0.0 and p_pos.x < w and p_pos.y > 0.0 and p_pos.y < h:
			alive_proj.append(pr)
	enemy_projectiles = alive_proj

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
	if player_hit_flash > 0.0:
		player_hit_flash = maxf(0.0, player_hit_flash - delta)

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

	var cur_spd: float = get_current_move_speed()
	is_walking = false
	if input_vec.length() > 0.01:
		has_click_target = false
		if absf(input_vec.x) > 0.05:
			facing_dir = 1.0 if input_vec.x > 0.0 else -1.0
		player_pos = _clamp_walk_pos(player_pos + input_vec.normalized() * cur_spd * delta)
		is_walking = true
	elif has_click_target:
		var diff: Vector2 = target_pos - player_pos
		if diff.length() > 5.0:
			if absf(diff.x) > 1.0:
				facing_dir = 1.0 if diff.x > 0.0 else -1.0
			player_pos = _clamp_walk_pos(player_pos + diff.normalized() * cur_spd * delta)
			is_walking = true
		else:
			has_click_target = false

	if is_walking:
		emit_signal("player_moved", current_stage, player_pos.x, player_pos.y)

	nearby_npc = _find_npc_near(player_pos, 64.0)
	nearby_chest = _find_chest_near(player_pos, 58.0)
	nearby_enemy_idx = _find_enemy_near(player_pos, 96.0)

	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var p_norm: Vector2 = st.get("plot_pos", Vector2(0.40, 0.78))
	near_homestead_plot = player_pos.distance_to(_norm_to_screen(p_norm.x, p_norm.y)) <= 68.0

	var m_norm: Vector2 = st.get("merchant_pos", Vector2(0.14, 0.64))
	near_merchant = player_pos.distance_to(_norm_to_screen(m_norm.x, m_norm.y)) <= 62.0

	var tab_norm: Vector2 = st.get("tabernacle_pos", Vector2(0.22, 0.48))
	var tab_pos: Vector2 = _norm_to_screen(tab_norm.x, tab_norm.y)
	var was_in_tab: bool = in_tabernacle
	in_tabernacle = player_pos.distance_to(tab_pos) <= 76.0
	if in_tabernacle and not was_in_tab:
		_use_tabernacle_sanctuary()

	_update_enemies_ai(delta, tab_pos)
	_check_portals()
	queue_redraw()

func _norm_to_screen(nx: float, ny: float) -> Vector2:
	var w: float = maxf(size.x, 800.0)
	var h: float = maxf(size.y, 540.0)
	return Vector2(nx * w, ny * h)

func _clamp_walk_pos(p: Vector2) -> Vector2:
	var w: float = maxf(size.x, 800.0)
	var h: float = maxf(size.y, 540.0)
	return Vector2(clampf(p.x, 34.0, w - 34.0), clampf(p.y, h * 0.36, h - 78.0))

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
			var epos: Vector2 = ed.get("pos", _norm_to_screen(float(ed["x"]), float(ed["y"])))
			if origin.distance_to(epos) <= radius:
				return i
	return -1

func trade_gathered_supplies() -> void:
	if timber_stock >= 100 and stone_stock >= 100:
		timber_stock -= 100
		stone_stock -= 100
		earned_talents += 25
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
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
	var summary: String = "SECRET CHEST LOOTED! +%d Timber, +%d Stone, +%d Oil, +%d Manna & [%s] (+8 Sword DMG!)" % [add_t, add_s, add_o, add_m, relic_name]
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
		_announce("%s: Health 100%% & Sacred Oil Anointing Active (12s Shield)!" % t_name, 5.5)
	else:
		_announce("%s: Health Fully Restored to %d/%d!" % [t_name, spirit_hp, max_spirit_hp], 4.5)

func _consume_manna_ration() -> void:
	if manna_rations >= 15 and spirit_hp < max_spirit_hp:
		manna_rations -= 15
		spirit_hp = mini(max_spirit_hp, spirit_hp + 35)
		_announce("Ate Manna Rations (-15 Manna) -> Health Restored to %d/%d!" % [spirit_hp, max_spirit_hp], 3.5)
	else:
		_announce("Visit the Tabernacle or open Secret Chests for more Manna Rations!", 3.0)

func _raise_shield_of_faith() -> void:
	shield_active = true
	shield_timer = 4.5
	_announce("SHIELD OF FAITH RAISED! Incoming damage & abilities reduced by 78%!", 3.0)

func _perform_sword_strike() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.40
	attack_swing_timer = 0.28
	var idx: int = _find_enemy_near(player_pos, 102.0)
	if idx != -1:
		var ed: Dictionary = stage_enemies[idx]
		var base_dmg: int = get_sword_damage()
		var enemy_armor: int = int(ed.get("armor", 0))
		var dmg: int = maxi(14, base_dmg - enemy_armor)
		var new_hp: int = maxi(0, int(ed.get("hp", 100)) - dmg)
		ed["hp"] = new_hp
		var epos: Vector2 = ed.get("pos", _norm_to_screen(float(ed["x"]), float(ed["y"])))
		var push: Vector2 = (epos - player_pos).normalized() * 18.0
		ed["pos"] = _clamp_walk_pos(epos + push)
		stage_enemies[idx] = ed
		if new_hp <= 0:
			var sc: int = int(ed.get("score", 40))
			var t_won: int = int(ed.get("talents", 35))
			earned_talents += t_won
			manna_rations += 20
			timber_stock += 50
			battle_wins_count += 1
			labor_credits += 1
			pending_victory_trivia = true
			emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
			_announce("BATTLE VICTORY! Defeated %s (+%d Talents, +1 Builder Credit) -> SCRIPTURE TRIVIA UNLOCKED!" % [str(ed["name"]), t_won], 7.5)
			emit_signal("battle_won", str(ed["name"]), sc, t_won)
			emit_signal("trial_requested")
		else:
			_announce("SWORD LV.%d! Struck %s for %d DMG (Armor -%d | %d/%d HP left)" % [sword_level, str(ed["name"]), dmg, enemy_armor, new_hp, int(ed["max_hp"])], 2.5)
	else:
		_announce("Sword of the Spirit (Lv.%d) drawn! Approach an adversary to strike." % sword_level, 2.0)

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

func _draw_traveling_merchant(st: Dictionary) -> void:
	var m_norm: Vector2 = st.get("merchant_pos", Vector2(0.14, 0.64))
	var mp: Vector2 = _norm_to_screen(m_norm.x, m_norm.y)
	var accent_col: Color = st.get("accent", Color.GOLD)
	var font: Font = ThemeDB.fallback_font

	# Merchant Caravan Canopy & Wooden Wagon
	draw_rect(Rect2(mp.x - 38.0, mp.y - 12.0, 76.0, 26.0), Color(0.46, 0.28, 0.14))
	draw_circle(mp + Vector2(-24.0, 16.0), 9.0, Color(0.24, 0.16, 0.10))
	draw_circle(mp + Vector2(24.0, 16.0), 9.0, Color(0.24, 0.16, 0.10))
	# Striped Royal Canopy
	var canopy: PackedVector2Array = PackedVector2Array([
		Vector2(mp.x - 44.0, mp.y - 12.0),
		Vector2(mp.x - 32.0, mp.y - 34.0),
		Vector2(mp.x + 32.0, mp.y - 34.0),
		Vector2(mp.x + 44.0, mp.y - 12.0)
	])
	draw_colored_polygon(canopy, Color(0.68, 0.20, 0.24))
	draw_line(Vector2(mp.x - 44.0, mp.y - 12.0), Vector2(mp.x + 44.0, mp.y - 12.0), accent_col, 3.0)
	# Merchant Armorer figure beside caravan
	_draw_humanoid_figure(mp + Vector2(46.0, 2.0), Color(0.78, 0.56, 0.18), Color(0.86, 0.70, 0.54), "pilgrim", -1.0, 0.0, false, 0.0, false, false, 0.92)
	if font != null:
		draw_string(font, mp + Vector2(-85.0, -44.0), "ARMORY MERCHANT [M]", HORIZONTAL_ALIGNMENT_CENTER, 170, 11, Color(1.0, 0.92, 0.45))

func _draw_player_homestead_onscreen(w: float, h: float, st: Dictionary) -> void:
	var p_norm: Vector2 = st.get("plot_pos", Vector2(0.40, 0.78))
	var hp: Vector2 = _norm_to_screen(p_norm.x, p_norm.y)
	var has_deed: bool = bool(land_deeds.get(current_stage, false))
	var lvl: int = int(house_stages.get(current_stage, 0))
	var accent_col: Color = st.get("accent", Color.GOLD)
	var font: Font = ThemeDB.fallback_font

	var plot_rect: Rect2 = Rect2(hp.x - 46.0, hp.y - 30.0, 92.0, 52.0)
	var border_col: Color = accent_col if has_deed else Color(0.65, 0.58, 0.44, 0.75)
	draw_rect(plot_rect, Color(0.16, 0.14, 0.10, 0.35))
	draw_rect(plot_rect, border_col, false, 2.0)

	for sx in [plot_rect.position.x, plot_rect.position.x + plot_rect.size.x]:
		for sy in [plot_rect.position.y, plot_rect.position.y + plot_rect.size.y]:
			draw_circle(Vector2(sx, sy), 3.5, border_col)

	if lvl == 0:
		draw_line(hp + Vector2(0.0, 10.0), hp + Vector2(0.0, -14.0), Color(0.54, 0.36, 0.18), 3.5)
		draw_rect(Rect2(hp.x - 16.0, hp.y - 18.0, 32.0, 14.0), Color(0.68, 0.50, 0.24))
		if font != null:
			var sign_txt: String = "YOUR LAND: BUILD FOUNDATION [B]" if has_deed else "LAND FOR SALE (120T) OR EARN [B]"
			draw_string(font, hp + Vector2(-95.0, -24.0), sign_txt, HORIZONTAL_ALIGNMENT_CENTER, 190, 10, accent_col if has_deed else Color(0.95, 0.88, 0.70))
	elif lvl == 1:
		draw_rect(Rect2(hp.x - 36.0, hp.y - 8.0, 72.0, 22.0), Color(0.52, 0.50, 0.46))
		draw_rect(Rect2(hp.x - 36.0, hp.y - 8.0, 72.0, 22.0), Color(0.75, 0.72, 0.66), false, 2.0)
		if font != null:
			draw_string(font, hp + Vector2(-95.0, -18.0), "STAGE 1/4: FOUNDATION [B] BUILD WALLS", HORIZONTAL_ALIGNMENT_CENTER, 190, 10, accent_col)
	elif lvl == 2:
		draw_rect(Rect2(hp.x - 36.0, hp.y - 24.0, 72.0, 38.0), Color(0.82, 0.74, 0.58))
		draw_line(Vector2(hp.x - 36.0, hp.y - 24.0), Vector2(hp.x - 36.0, hp.y + 14.0), Color(0.45, 0.28, 0.12), 4.0)
		draw_line(Vector2(hp.x + 36.0, hp.y - 24.0), Vector2(hp.x + 36.0, hp.y + 14.0), Color(0.45, 0.28, 0.12), 4.0)
		draw_rect(Rect2(hp.x - 8.0, hp.y - 4.0, 16.0, 18.0), Color(0.28, 0.18, 0.10))
		if font != null:
			draw_string(font, hp + Vector2(-95.0, -32.0), "STAGE 2/4: WALLS UP [B] BUILD ROOF", HORIZONTAL_ALIGNMENT_CENTER, 190, 10, accent_col)
	elif lvl == 3:
		draw_rect(Rect2(hp.x - 38.0, hp.y - 26.0, 76.0, 40.0), Color(0.84, 0.76, 0.60))
		var roof_p: PackedVector2Array = PackedVector2Array([Vector2(hp.x - 44.0, hp.y - 26.0), Vector2(hp.x, hp.y - 48.0), Vector2(hp.x + 44.0, hp.y - 26.0)])
		draw_colored_polygon(roof_p, Color(0.58, 0.28, 0.16))
		draw_rect(Rect2(hp.x - 8.0, hp.y - 4.0, 16.0, 18.0), Color(0.30, 0.18, 0.10))
		draw_circle(Vector2(hp.x + 22.0, hp.y - 12.0), 5.0, Color(1.0, 0.85, 0.28))
		if font != null:
			draw_string(font, hp + Vector2(-95.0, -56.0), "STAGE 3/4: ROOF & LANTERN [B] CONSECRATE", HORIZONTAL_ALIGNMENT_CENTER, 190, 10, accent_col)
	else:
		draw_rect(Rect2(hp.x - 42.0, hp.y - 32.0, 84.0, 46.0), Color(0.88, 0.80, 0.64))
		var manor_roof: PackedVector2Array = PackedVector2Array([Vector2(hp.x - 48.0, hp.y - 32.0), Vector2(hp.x, hp.y - 58.0), Vector2(hp.x + 48.0, hp.y - 32.0)])
		draw_colored_polygon(manor_roof, accent_col)
		draw_rect(Rect2(hp.x - 10.0, hp.y - 6.0, 20.0, 20.0), Color(0.32, 0.20, 0.10))
		draw_rect(Rect2(hp.x - 28.0, hp.y - 18.0, 11.0, 10.0), Color(1.0, 0.86, 0.32))
		draw_rect(Rect2(hp.x + 17.0, hp.y - 18.0, 11.0, 10.0), Color(1.0, 0.86, 0.32))
		if font != null:
			draw_string(font, hp + Vector2(-105.0, -66.0), "%s'S COVENANT MANOR (4/4)" % local_pilgrim_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 210, 11, Color(1.0, 0.95, 0.55))

func _draw_world_environment(w: float, h: float, horizon: float, st: Dictionary) -> void:
	var grass_col: Color = st.get("grass", Color(0.18, 0.28, 0.14))
	var river_col: Color = st.get("river", Color(0.12, 0.48, 0.72))
	var wall_col: Color = st.get("wall", Color(0.48, 0.44, 0.36))
	var accent_col: Color = st.get("accent", Color.GOLD)

	draw_rect(Rect2(0.0, horizon, w * 0.52, h - horizon), Color(grass_col.r, grass_col.g, grass_col.b, 0.45))

	var wall_y: float = horizon - 14.0
	draw_rect(Rect2(60.0, wall_y, w - 120.0, 22.0), wall_col)
	draw_line(Vector2(60.0, wall_y + 11.0), Vector2(w - 60.0, wall_y + 11.0), wall_col.darkened(0.28), 1.5)
	var crenel_x: float = 64.0
	while crenel_x < w - 72.0:
		draw_rect(Rect2(crenel_x, wall_y - 7.0, 12.0, 7.0), wall_col.lightened(0.08))
		crenel_x += 24.0

	for tx in [76.0, w - 108.0]:
		draw_rect(Rect2(tx, wall_y - 34.0, 32.0, 56.0), wall_col.lightened(0.05))
		draw_rect(Rect2(tx - 4.0, wall_y - 40.0, 40.0, 7.0), accent_col)
		draw_circle(Vector2(tx + 16.0, wall_y - 46.0), 5.0 + 1.5 * sin(anim_time * 9.0), Color(1.0, 0.62, 0.16))

	var rx_norm: float = float(st.get("river_x", 0.57))
	var river_top_x: float = w * rx_norm
	var river_bot_x: float = w * (rx_norm + 0.04)
	var river_w: float = 58.0
	var river_poly: PackedVector2Array = PackedVector2Array([
		Vector2(river_top_x - river_w * 0.42, horizon),
		Vector2(river_top_x + river_w * 0.42, horizon),
		Vector2(river_bot_x + river_w * 0.65, h),
		Vector2(river_bot_x - river_w * 0.65, h)
	])
	draw_colored_polygon(river_poly, river_col)
	draw_line(Vector2(river_top_x - river_w * 0.42, horizon), Vector2(river_bot_x - river_w * 0.65, h), Color(0.76, 0.68, 0.48), 3.0)
	draw_line(Vector2(river_top_x + river_w * 0.42, horizon), Vector2(river_bot_x + river_w * 0.65, h), Color(0.76, 0.68, 0.48), 3.0)
	for rip_i in range(6):
		var t_rip: float = fmod((float(rip_i) / 6.0) + anim_time * 0.18, 1.0)
		var ry: float = lerpf(horizon + 12.0, h - 82.0, t_rip)
		var rx_c: float = lerpf(river_top_x, river_bot_x, t_rip)
		draw_line(Vector2(rx_c - 16.0, ry), Vector2(rx_c + 16.0, ry), Color(0.75, 0.94, 1.0, 0.55), 2.0)

	var bridge_y: float = h * 0.60
	var bridge_x: float = lerpf(river_top_x, river_bot_x, 0.42)
	draw_rect(Rect2(bridge_x - 48.0, bridge_y - 18.0, 96.0, 36.0), Color(0.58, 0.52, 0.42))
	draw_rect(Rect2(bridge_x - 48.0, bridge_y - 22.0, 96.0, 5.0), wall_col.lightened(0.15))
	draw_rect(Rect2(bridge_x - 48.0, bridge_y + 17.0, 96.0, 5.0), wall_col.lightened(0.15))

	draw_line(Vector2(w * 0.14, h * 0.56), Vector2(bridge_x - 48.0, bridge_y), Color(0.54, 0.46, 0.34, 0.65), 16.0)
	draw_line(Vector2(bridge_x + 48.0, bridge_y), Vector2(w * 0.84, h * 0.62), Color(0.54, 0.46, 0.34, 0.55), 14.0)

	var houses: Array = [
		Vector2(w * 0.10, h * 0.45),
		Vector2(w * 0.38, h * 0.43)
	]
	for h_pos in houses:
		var hp: Vector2 = h_pos
		draw_rect(Rect2(hp.x - 28.0, hp.y - 22.0, 56.0, 34.0), Color(0.76, 0.68, 0.54))
		draw_rect(Rect2(hp.x - 31.0, hp.y - 26.0, 62.0, 6.0), Color(0.60, 0.50, 0.38))
		draw_rect(Rect2(hp.x - 6.0, hp.y - 4.0, 12.0, 16.0), Color(0.22, 0.15, 0.10))
		draw_rect(Rect2(hp.x + 11.0, hp.y - 12.0, 9.0, 8.0), Color(0.95, 0.78, 0.32, 0.75))

	var trees: Array = [
		Vector2(w * 0.06, h * 0.52),
		Vector2(w * 0.33, h * 0.41),
		Vector2(w * 0.46, h * 0.44),
		Vector2(w * 0.68, h * 0.43),
		Vector2(w * 0.91, h * 0.58)
	]
	for t_pos in trees:
		var tp: Vector2 = t_pos
		draw_line(tp + Vector2(0.0, 14.0), tp + Vector2(0.0, -14.0), Color(0.42, 0.28, 0.15), 4.5)
		draw_circle(tp + Vector2(0.0, -18.0), 15.0, Color(0.18, 0.42, 0.20))
		draw_circle(tp + Vector2(-9.0, -14.0), 11.0, Color(0.22, 0.48, 0.24))
		draw_circle(tp + Vector2(9.0, -14.0), 11.0, Color(0.22, 0.48, 0.24))

	_draw_traveling_merchant(st)
	_draw_player_homestead_onscreen(w, h, st)

func _draw_overhead_health_bar(center_top: Vector2, cur_hp: int, max_hp: int, bar_w: float, is_player: bool) -> void:
	var pct: float = clampf(float(cur_hp) / float(maxi(1, max_hp)), 0.0, 1.0)
	var bg_rect: Rect2 = Rect2(center_top.x - bar_w * 0.5, center_top.y, bar_w, 7.0)
	draw_rect(bg_rect, Color(0.08, 0.06, 0.08, 0.90))
	var fill_col: Color = Color(0.92, 0.24, 0.22)
	if is_player:
		if pct > 0.55:
			fill_col = Color(0.24, 0.86, 0.46)
		elif pct > 0.28:
			fill_col = Color(0.96, 0.76, 0.22)
	draw_rect(Rect2(bg_rect.position.x + 1.0, bg_rect.position.y + 1.0, (bar_w - 2.0) * pct, 5.0), fill_col)
	var font: Font = ThemeDB.fallback_font
	if font != null:
		draw_string(font, Vector2(center_top.x - 36.0, center_top.y - 2.0), "%d/%d" % [cur_hp, max_hp], HORIZONTAL_ALIGNMENT_CENTER, 72, 9, Color.WHITE)

func _draw_humanoid_figure(base_pos: Vector2, tunic_col: Color, skin_col: Color, headgear: String, dir_x: float, stride_phase: float, has_sword: bool, swing_t: float, has_shield: bool, is_enemy: bool, scale_f: float = 1.0) -> void:
	draw_circle(base_pos + Vector2(0.0, 22.0 * scale_f), 15.0 * scale_f, Color(0.0, 0.0, 0.0, 0.48))

	var leg_swing: float = sin(stride_phase) * 5.0 * scale_f
	var left_foot: Vector2 = base_pos + Vector2(-5.0 * scale_f + leg_swing, 21.0 * scale_f)
	var right_foot: Vector2 = base_pos + Vector2(5.0 * scale_f - leg_swing, 21.0 * scale_f)
	draw_line(base_pos + Vector2(-4.0 * scale_f, 8.0 * scale_f), left_foot, Color(0.24, 0.16, 0.10), 3.5 * scale_f)
	draw_line(base_pos + Vector2(4.0 * scale_f, 8.0 * scale_f), right_foot, Color(0.24, 0.16, 0.10), 3.5 * scale_f)

	var robe_poly: PackedVector2Array = PackedVector2Array([
		base_pos + Vector2(-8.0 * scale_f, -10.0 * scale_f),
		base_pos + Vector2(8.0 * scale_f, -10.0 * scale_f),
		base_pos + Vector2(12.0 * scale_f, 12.0 * scale_f),
		base_pos + Vector2(-12.0 * scale_f, 12.0 * scale_f)
	])
	draw_colored_polygon(robe_poly, tunic_col)
	draw_line(base_pos + Vector2(-9.5 * scale_f, 0.0), base_pos + Vector2(9.5 * scale_f, 0.0), Color(0.95, 0.78, 0.26) if not is_enemy else Color(0.85, 0.22, 0.18), 3.0 * scale_f)

	var arm_off: float = -leg_swing * 0.6
	draw_line(base_pos + Vector2(-8.0 * scale_f, -7.0 * scale_f), base_pos + Vector2(-13.0 * scale_f, 3.0 * scale_f + arm_off), tunic_col.lightened(0.15), 3.2 * scale_f)
	draw_line(base_pos + Vector2(8.0 * scale_f, -7.0 * scale_f), base_pos + Vector2(13.0 * scale_f, 3.0 * scale_f - arm_off), tunic_col.lightened(0.15), 3.2 * scale_f)

	var head_c: Vector2 = base_pos + Vector2(0.0, -18.0 * scale_f)
	draw_circle(head_c, 7.5 * scale_f, skin_col)
	if headgear == "prophet":
		draw_arc(head_c, 8.2 * scale_f, PI, TAU, 16, Color(0.92, 0.88, 0.78), 3.0 * scale_f)
		var beard: PackedVector2Array = PackedVector2Array([head_c + Vector2(-5.0 * scale_f, 2.0 * scale_f), head_c + Vector2(5.0 * scale_f, 2.0 * scale_f), head_c + Vector2(0.0, 11.0 * scale_f)])
		draw_colored_polygon(beard, Color(0.86, 0.86, 0.88))
	elif headgear == "crown":
		draw_rect(Rect2(head_c.x - 7.0 * scale_f, head_c.y - 10.0 * scale_f, 14.0 * scale_f, 4.5 * scale_f), Color(0.98, 0.82, 0.22))
	elif headgear == "warrior":
		draw_arc(head_c, 8.2 * scale_f, PI, TAU, 16, Color(0.76, 0.56, 0.24), 3.5 * scale_f)
	elif is_enemy:
		draw_arc(head_c, 8.5 * scale_f, PI, TAU, 16, Color(0.22, 0.22, 0.26), 4.0 * scale_f)
		draw_circle(head_c + Vector2(-2.5 * scale_f, -1.0 * scale_f), 1.6 * scale_f, Color(1.0, 0.25, 0.20))
		draw_circle(head_c + Vector2(2.5 * scale_f, -1.0 * scale_f), 1.6 * scale_f, Color(1.0, 0.25, 0.20))
	else:
		draw_line(head_c + Vector2(-7.0 * scale_f, -4.0 * scale_f), head_c + Vector2(7.0 * scale_f, -4.0 * scale_f), Color(0.95, 0.82, 0.35), 2.2 * scale_f)

	if has_sword:
		var sw_angle: float = -0.9 + (1.8 * (1.0 - swing_t / 0.32)) if swing_t > 0.0 else -0.35
		var hilt: Vector2 = base_pos + Vector2(dir_x * 12.0 * scale_f, -2.0 * scale_f)
		var blade_len: float = (28.0 + float(sword_level - 1) * 3.0) if not is_enemy else 28.0
		var tip: Vector2 = hilt + Vector2(dir_x * cos(sw_angle) * blade_len * scale_f, sin(sw_angle) * blade_len * scale_f)
		var blade_col: Color = Color(0.98, 0.35, 0.28) if is_enemy else (Color(1.0, 0.90, 0.42) if sword_level >= 3 else Color(0.92, 0.96, 1.0))
		draw_line(hilt, tip, blade_col, 3.4 * scale_f)
		draw_line(hilt + Vector2(-3.0 * scale_f, 0.0), hilt + Vector2(3.0 * scale_f, 0.0), Color(0.98, 0.80, 0.24), 3.0 * scale_f)
	else:
		var sx: float = dir_x * 13.0 * scale_f
		draw_line(base_pos + Vector2(sx, -22.0 * scale_f), base_pos + Vector2(sx, 21.0 * scale_f), Color(0.54, 0.36, 0.18), 2.6 * scale_f)

	if has_shield:
		var sh_c: Vector2 = base_pos + Vector2(-dir_x * 13.0 * scale_f, 0.0)
		draw_circle(sh_c, 10.5 * scale_f, Color(0.24, 0.68, 0.96, 0.88))
		draw_arc(sh_c, 10.5 * scale_f, 0.0, TAU, 20, Color(0.98, 0.86, 0.36), 2.2 * scale_f)

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

	var sun_pos: Vector2 = Vector2(w * 0.82, horizon * 0.42)
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

	_draw_world_environment(w, h, horizon, st)

	for p_item in particles:
		var pt: Dictionary = p_item
		var p_xy: Vector2 = Vector2(float(pt["x"]) * w, float(pt["y"]) * h)
		draw_circle(p_xy, float(pt["rad"]), Color(accent_col.r, accent_col.g, accent_col.b, 0.28))

	var font: Font = ThemeDB.fallback_font

	# 1. TABERNACLE / SANCTUARY & TRADING POST
	var tab_norm: Vector2 = st.get("tabernacle_pos", Vector2(0.22, 0.48))
	var tab_pos: Vector2 = _norm_to_screen(tab_norm.x, tab_norm.y)
	var tab_pulse: float = 0.75 + 0.25 * sin(anim_time * 3.5)
	draw_circle(tab_pos, 76.0, Color(1.0, 0.85, 0.30, 0.14 * tab_pulse))
	draw_arc(tab_pos, 76.0, 0.0, TAU, 32, accent_col, 2.0)
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
		draw_string(font, tab_pos + Vector2(-95.0, 22.0), "[SAFE ZONE: HEAL & TRADE (T)]", HORIZONTAL_ALIGNMENT_CENTER, 190, 10, accent_col)

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

	# 3. ACTIVE ENEMIES WITH OVERHEAD HEALTH BARS
	for e_item in stage_enemies:
		var ed: Dictionary = e_item
		var ehp: int = int(ed.get("hp", 0))
		if ehp > 0:
			var epos: Vector2 = ed.get("pos", _norm_to_screen(float(ed["x"]), float(ed["y"])))
			var emax: int = maxi(1, int(ed.get("max_hp", 100)))
			var arch: String = str(ed.get("archetype", "raider"))
			var e_dir: float = float(ed.get("dir_x", -1.0))
			var e_sw: float = float(ed.get("swing_timer", 0.0))
			var tele_t: float = float(ed.get("telegraph_timer", 0.0))

			var e_col: Color = Color(0.46, 0.12, 0.16)
			var e_scale: float = 1.0
			var e_shield: bool = false
			if arch == "giant":
				e_col = Color(0.54, 0.14, 0.10)
				e_scale = 1.32
			elif arch == "sentinel":
				e_col = Color(0.28, 0.24, 0.34)
				e_scale = 1.12
				e_shield = true
			elif arch == "spirit":
				e_col = Color(0.32, 0.10, 0.46)
				e_scale = 1.08

			if tele_t > 0.0:
				var warn_r: float = 118.0 if arch == "giant" else 64.0
				draw_circle(epos, warn_r, Color(1.0, 0.22, 0.14, 0.22))
				draw_arc(epos, warn_r, 0.0, TAU, 32, Color(1.0, 0.32, 0.20, 0.90), 3.0)

			_draw_humanoid_figure(epos, e_col, Color(0.62, 0.48, 0.42), "enemy", e_dir, anim_time * 6.0, true, e_sw, e_shield, true, e_scale)

			var y_off: float = 40.0 * e_scale
			_draw_overhead_health_bar(epos + Vector2(0.0, -y_off), ehp, emax, 66.0, false)
			if font != null:
				draw_string(font, epos + Vector2(-80.0, -y_off - 14.0), "%s (%s)" % [str(ed.get("name", "Sentinel")), str(ed.get("ability", ""))], HORIZONTAL_ALIGNMENT_CENTER, 160, 10, Color(1.0, 0.78, 0.72))

	for p_obj in enemy_projectiles:
		var pr: Dictionary = p_obj
		var p_pos: Vector2 = pr["pos"]
		draw_circle(p_pos, 9.0, Color(0.85, 0.22, 0.95, 0.45))
		draw_circle(p_pos, 5.0, Color(1.0, 0.45, 0.30))

	# 4. BIBLICAL NPCs WITH OVERHEAD HEALTH BARS
	var npcs: Array = st.get("npcs", [])
	for n_item in npcs:
		var npc: Dictionary = n_item
		var npos: Vector2 = _norm_to_screen(float(npc["x"]), float(npc["y"]))
		var ncol: Color = npc.get("color", Color.GOLD)
		var hgear: String = str(npc.get("headgear", "prophet"))
		_draw_humanoid_figure(npos, ncol, Color(0.86, 0.70, 0.54), hgear, 1.0, 0.0, false, 0.0, false, false, 1.0)
		_draw_overhead_health_bar(npos + Vector2(0.0, -36.0), 100, 100, 52.0, true)
		if font != null:
			draw_string(font, npos + Vector2(-52.0, -49.0), "%s [E]" % str(npc.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 104, 12, Color(1.0, 0.96, 0.84))

	# 5. REMOTE MULTIPLAYER PILGRIMS
	for rp_item in remote_pilgrims:
		var rp: Dictionary = rp_item
		if str(rp.get("stage", "")) == current_stage:
			var rpos: Vector2 = Vector2(float(rp.get("x", 200.0)), float(rp.get("y", 200.0)))
			var r_robe_key: String = str(rp.get("robe", "Galilee Cyan"))
			var r_col: Color = ROBE_PALETTE.get(r_robe_key, Color(0.35, 0.85, 1.0))
			_draw_humanoid_figure(rpos, r_col, Color(0.88, 0.72, 0.56), "pilgrim", 1.0, anim_time * 4.0, false, 0.0, false, false, 1.0)
			_draw_overhead_health_bar(rpos + Vector2(0.0, -36.0), 100, 100, 56.0, true)
			if font != null:
				draw_string(font, rpos + Vector2(-54.0, -49.0), str(rp.get("name", "Pilgrim")), HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color(0.78, 0.96, 1.0))

	# 6. LOCAL PLAYER AVATAR WITH OVERHEAD HEALTH BAR
	var stride: float = anim_time * 12.0 if is_walking else 0.0
	var my_robe: Color = Color(1.0, 0.30, 0.30) if player_hit_flash > 0.0 else ROBE_PALETTE.get(local_robe_name, Color(0.18, 0.48, 0.92))
	var in_combat: bool = (nearby_enemy_idx != -1 or attack_swing_timer > 0.0)
	_draw_humanoid_figure(player_pos, my_robe, Color(0.90, 0.74, 0.58), "pilgrim", facing_dir, stride, in_combat, attack_swing_timer, shield_active, false, 1.0)
	_draw_overhead_health_bar(player_pos + Vector2(0.0, -36.0), spirit_hp, max_spirit_hp, 64.0, true)

	# 7. LEFT & RIGHT STAGE PORTALS
	var left_p: Vector2 = Vector2(44.0, h * 0.56)
	var right_p: Vector2 = Vector2(w - 44.0, h * 0.56)
	draw_circle(left_p, 26.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.26 * tab_pulse))
	draw_arc(left_p, 26.0, 0.0, TAU, 28, accent_col, 2.5)
	draw_circle(right_p, 26.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.26 * tab_pulse))
	draw_arc(right_p, 26.0, 0.0, TAU, 28, accent_col, 2.5)

	# 8. DIEGETIC TOP HUD (SHOWING TALENTS, GEAR TIERS, RESOURCES & HOUSE STAGE)
	if font != null:
		draw_rect(Rect2(12.0, 10.0, w - 24.0, 52.0), Color(0.05, 0.05, 0.08, 0.86))
		draw_string(font, Vector2(22.0, 30.0), "%s  |  TALENTS: %d  |  HP: %d/%d  |  GEAR: Sword Lv.%d / Armor Lv.%d / Boots Lv.%d  |  HOUSE: %d/4" % [str(st["title"]), earned_talents, spirit_hp, max_spirit_hp, sword_level, armor_level, boots_level, int(house_stages.get(current_stage, 0))], HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 13, accent_col)
		draw_string(font, Vector2(22.0, 50.0), "[M] Village Armory Shop  |  [F] Battle (Unlocks Trivia)  |  [Y] Trivia  |  [B] Land & House  |  [T] Trade (%dT/%dS)  |  [Q] Shield" % [timber_stock, stone_stock], HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 11, Color(0.88, 0.90, 0.95))

		draw_string(font, player_pos + Vector2(-54.0, -50.0), local_pilgrim_name, HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color.WHITE)
		draw_string(font, Vector2(14.0, h * 0.56 + 40.0), "< PREV ERA", HORIZONTAL_ALIGNMENT_LEFT, 96, 11, accent_col)
		draw_string(font, Vector2(w - 96.0, h * 0.56 + 40.0), "NEXT ERA >", HORIZONTAL_ALIGNMENT_RIGHT, 84, 11, accent_col)

		if banner_timer > 0.0 and banner_text != "":
			draw_rect(Rect2(16.0, h - 98.0, w - 32.0, 28.0), Color(0.06, 0.05, 0.09, 0.92))
			draw_string(font, Vector2(24.0, h - 79.0), banner_text, HORIZONTAL_ALIGNMENT_LEFT, int(w - 48.0), 13, Color(1.0, 0.94, 0.58))
