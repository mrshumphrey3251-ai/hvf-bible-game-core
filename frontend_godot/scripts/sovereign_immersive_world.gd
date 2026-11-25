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
			{"name": "Moses", "x": 0.31, "y": 0.58, "color": Color(0.88, 0.68, 0.24), "headgear": "prophet", "scenario": "GEN_001", "greeting": "Gather Timber & Stone from Secret Chests to trade [T] for Talents, or press [E] for Covenant Trivia!"},
			{"name": "Caleb", "x": 0.50, "y": 0.68, "color": Color(0.24, 0.68, 0.42), "headgear": "warrior", "scenario": "TOR_005", "greeting": "Watch the Anakite Giant's red shockwave ring?raise your Shield of Faith [Q] before he slams!"}
		],
		"chests": [
			{"id": "CHEST_TOR_1", "x": 0.14, "y": 0.76, "timber": 120, "stone": 100, "oil": 2, "manna": 30, "relic": "Bronze Altar Ember"},
			{"id": "CHEST_TOR_2", "x": 0.86, "y": 0.46, "timber": 150, "stone": 120, "oil": 1, "manna": 40, "relic": "Ark Cedar Plank"}
		],
		"enemies": [
			{"name": "Amalekite Raider", "archetype": "raider", "ability": "Swift Ambush", "x": 0.70, "y": 0.58, "hp": 95, "max_hp": 95, "atk": 13, "spd": 135.0, "armor": 0, "score": 35, "talents": 30},
			{"name": "Anakite Giant", "archetype": "giant", "ability": "Earthshaker Slam", "x": 0.82, "y": 0.72, "hp": 155, "max_hp": 155, "atk": 22, "spd": 78.0, "armor": 6, "score": 55, "talents": 50}
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
			{"name": "Joshua", "x": 0.32, "y": 0.60, "color": Color(0.84, 0.36, 0.24), "headgear": "warrior", "scenario": "HIS_001", "greeting": "Armored Sentinels reduce frontal damage?collect relics or strike relentlessly [F] to shatter their guard!"},
			{"name": "Nehemiah", "x": 0.52, "y": 0.52, "color": Color(0.28, 0.60, 0.88), "headgear": "builder", "scenario": "HIS_005", "greeting": "Trade excess Timber & Stone [T] to fund Jerusalem's restoration!"}
		],
		"chests": [
			{"id": "CHEST_HIS_1", "x": 0.15, "y": 0.77, "timber": 140, "stone": 160, "oil": 2, "manna": 35, "relic": "Gilgal Memorial Stone"},
			{"id": "CHEST_HIS_2", "x": 0.86, "y": 0.77, "timber": 180, "stone": 200, "oil": 2, "manna": 45, "relic": "Nehemiah's Trowel"}
		],
		"enemies": [
			{"name": "Jericho Sentinel", "archetype": "sentinel", "ability": "Iron Bulwark", "x": 0.73, "y": 0.58, "hp": 140, "max_hp": 140, "atk": 17, "spd": 92.0, "armor": 10, "score": 45, "talents": 40},
			{"name": "Sanballat Raider", "archetype": "raider", "ability": "Flanking Dash", "x": 0.81, "y": 0.72, "hp": 115, "max_hp": 115, "atk": 18, "spd": 142.0, "armor": 2, "score": 55, "talents": 50}
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
			{"name": "King David", "x": 0.33, "y": 0.60, "color": Color(0.92, 0.72, 0.22), "headgear": "crown", "scenario": "WIS_001", "greeting": "The Philistine Champion unleashes heavy cleave slams?block with [Q] and counter-strike [F]!"},
			{"name": "Solomon", "x": 0.53, "y": 0.52, "color": Color(0.68, 0.42, 0.92), "headgear": "crown", "scenario": "WIS_004", "greeting": "Trade cedar timber and hewn stone [T] at the Temple treasury for Talents."}
		],
		"chests": [
			{"id": "CHEST_WIS_1", "x": 0.14, "y": 0.76, "timber": 200, "stone": 180, "oil": 3, "manna": 40, "relic": "Davidic Harp String"},
			{"id": "CHEST_WIS_2", "x": 0.85, "y": 0.47, "timber": 220, "stone": 220, "oil": 2, "manna": 50, "relic": "Seal of Wisdom"}
		],
		"enemies": [
			{"name": "Philistine Champion", "archetype": "giant", "ability": "Goliath Cleave", "x": 0.76, "y": 0.63, "hp": 185, "max_hp": 185, "atk": 24, "spd": 88.0, "armor": 12, "score": 65, "talents": 70}
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
			{"name": "Isaiah", "x": 0.32, "y": 0.58, "color": Color(0.90, 0.54, 0.24), "headgear": "prophet", "scenario": "PRO_001", "greeting": "No weapon formed against you shall prosper! Quench fiery bolts with Shield of Faith [Q]."},
			{"name": "Jeremiah", "x": 0.52, "y": 0.66, "color": Color(0.45, 0.70, 0.84), "headgear": "prophet", "scenario": "PRO_004", "greeting": "Test your knowledge of the Prophets [E] to earn covenant rewards!"}
		],
		"chests": [
			{"id": "CHEST_PRO_1", "x": 0.15, "y": 0.77, "timber": 160, "stone": 190, "oil": 3, "manna": 45, "relic": "Prophetic Scroll Cylinder"}
		],
		"enemies": [
			{"name": "Babylonian Siege Warden", "archetype": "sentinel", "ability": "Siege Fire Volley", "x": 0.76, "y": 0.62, "hp": 190, "max_hp": 190, "atk": 23, "spd": 96.0, "armor": 14, "score": 70, "talents": 75}
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
			{"name": "Peter", "x": 0.33, "y": 0.60, "color": Color(0.28, 0.74, 0.92), "headgear": "pilgrim", "scenario": "GOS_001", "greeting": "Tempest Spirits cast shadow bolts from afar?advance with your Shield [Q] raised!"},
			{"name": "Good Samaritan", "x": 0.53, "y": 0.54, "color": Color(0.36, 0.84, 0.54), "headgear": "pilgrim", "scenario": "GOS_004", "greeting": "Visit the Sanctuary whenever your Spirit runs low."}
		],
		"chests": [
			{"id": "CHEST_GOS_1", "x": 0.14, "y": 0.76, "timber": 190, "stone": 150, "oil": 3, "manna": 60, "relic": "Five Loaves Basket"}
		],
		"enemies": [
			{"name": "Tempest Shadow Spirit", "archetype": "spirit", "ability": "Shadow Bolt & Drain", "x": 0.76, "y": 0.63, "hp": 195, "max_hp": 195, "atk": 25, "spd": 124.0, "armor": 8, "score": 80, "talents": 85}
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
			{"name": "Apostle Paul", "x": 0.33, "y": 0.58, "color": Color(0.92, 0.74, 0.28), "headgear": "prophet", "scenario": "EPI_001", "greeting": "Take up the whole Armor of God! Principalities Vanguard uses both Shockwave and Shadow Bolts!"},
			{"name": "Barnabas", "x": 0.54, "y": 0.66, "color": Color(0.50, 0.82, 0.46), "headgear": "pilgrim", "scenario": "EPI_004", "greeting": "Press [T] to trade chest supplies for Talents."}
		],
		"chests": [
			{"id": "CHEST_EPI_1", "x": 0.85, "y": 0.76, "timber": 250, "stone": 250, "oil": 4, "manna": 75, "relic": "Full Armor of God Seal"}
		],
		"enemies": [
			{"name": "Principalities Vanguard", "archetype": "spirit", "ability": "Fiery Dart & Nova", "x": 0.76, "y": 0.62, "hp": 230, "max_hp": 230, "atk": 28, "spd": 128.0, "armor": 14, "score": 110, "talents": 120}
		]
	}
}

var current_stage: String = "ERA_TORAH"
var player_pos: Vector2 = Vector2(360.0, 340.0)
var target_pos: Vector2 = Vector2(360.0, 340.0)
var has_click_target: bool = false
var is_walking: bool = false
var facing_dir: float = 1.0
var move_speed: float = 240.0
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

var shield_active: bool = false
var shield_timer: float = 0.0
var attack_swing_timer: float = 0.0
var attack_cooldown: float = 0.0
var player_hit_flash: float = 0.0

var nearby_npc: Dictionary = {}
var nearby_chest: Dictionary = {}
var nearby_enemy_idx: int = -1
var in_tabernacle: bool = false

var banner_text: String = "Enemies actively pursue & use special abilities! Watch telegraphs, raise Shield [Q], and strike [F]!"
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

func _apply_damage_to_player(raw_dmg: int, attacker_label: String, tab_pos: Vector2) -> void:
	var final_dmg: int = maxi(2, int(raw_dmg * 0.22)) if shield_active else raw_dmg
	spirit_hp = maxi(0, spirit_hp - final_dmg)
	player_hit_flash = 0.25
	if shield_active:
		_announce("SHIELD OF FAITH DEFLECTED %s! (-%d Spirit)" % [attacker_label, final_dmg], 2.5)
	else:
		_announce("%s hit you for -%d Spirit! Raise Shield [Q], eat Manna [R], or retreat to Tabernacle!" % [attacker_label, final_dmg], 3.2)
	if spirit_hp <= 0:
		spirit_hp = 55
		player_pos = tab_pos + Vector2(0, 42)
		target_pos = player_pos
		has_click_target = false
		enemy_projectiles.clear()
		_announce("RETREATED TO TABERNACLE SANCTUARY ? Spirit Restored to 55/100!", 5.0)

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

		# Safe Sanctuary Zone: enemies stop pursuing if player enters the sacred Tabernacle circle
		if dist_to_tab <= 78.0:
			var to_home: Vector2 = home - epos
			if to_home.length() > 6.0:
				epos += to_home.normalized() * spd * 0.7 * delta
				ed["dir_x"] = 1.0 if to_home.x >= 0.0 else -1.0
			ed["telegraph_timer"] = 0.0
			ed["pos"] = epos
			stage_enemies[i] = ed
			continue

		# Active Pursuit & Special Ability Execution
		if dist_to_player <= aggro_range:
			var to_p: Vector2 = player_pos - epos
			if absf(to_p.x) > 2.0:
				ed["dir_x"] = 1.0 if to_p.x > 0.0 else -1.0

			# Telegraph wind-up countdown for special abilities
			var tele_t: float = float(ed.get("telegraph_timer", 0.0))
			if tele_t > 0.0:
				tele_t -= delta
				ed["telegraph_timer"] = tele_t
				if tele_t <= 0.0:
					# Execute telegraphed Special Ability!
					ed["swing_timer"] = 0.35
					if arch == "giant":
						# Earthshaker AoE Slam within 118px
						if epos.distance_to(player_pos) <= 118.0:
							_apply_damage_to_player(int(raw_atk * 1.45), "%s [%s]" % [e_name, abil_name], tab_pos)
						else:
							_announce("EVADED %s's %s shockwave!" % [e_name, abil_name], 2.5)
					elif arch == "raider":
						# Swift Ambush Dash toward player
						epos = _clamp_walk_pos(epos + to_p.normalized() * 88.0)
						if epos.distance_to(player_pos) <= 78.0:
							_apply_damage_to_player(int(raw_atk * 1.25), "%s [%s]" % [e_name, abil_name], tab_pos)
					elif arch == "spirit":
						# Fire Ranged Shadow Bolt Projectile
						enemy_projectiles.append({
							"pos": epos,
							"vel": to_p.normalized() * 265.0,
							"dmg": int(raw_atk * 1.15),
							"owner": "%s [%s]" % [e_name, abil_name],
							"life": 2.4
						})
					else:
						# Sentinel Iron Bulwark Counter-Slam
						if epos.distance_to(player_pos) <= 88.0:
							_apply_damage_to_player(int(raw_atk * 1.30), "%s [%s]" % [e_name, abil_name], tab_pos)
			else:
				# Move toward melee range (48px) or ranged standoff (160px for spirit)
				var desired_range: float = 155.0 if arch == "spirit" else 48.0
				if dist_to_player > desired_range:
					epos = _clamp_walk_pos(epos + to_p.normalized() * spd * delta)

				# Standard Melee Attack Timer
				var atk_t: float = float(ed.get("atk_timer", 1.2)) - delta
				if atk_t <= 0.0 and dist_to_player <= 68.0:
					atk_t = 1.45
					ed["swing_timer"] = 0.30
					_apply_damage_to_player(raw_atk, e_name, tab_pos)
				ed["atk_timer"] = atk_t

				# Special Ability Cooldown Trigger (starts visible telegraph!)
				var ab_t: float = float(ed.get("ability_timer", 3.0)) - delta
				if ab_t <= 0.0:
					ab_t = 4.2
					ed["telegraph_timer"] = 0.95
					_announce("WARNING: %s is charging %s! Raise Shield [Q] or dodge!" % [e_name, abil_name], 2.2)
				ed["ability_timer"] = ab_t
		else:
			# Return gently to patrol post when player is out of aggro range
			var back: Vector2 = home - epos
			if back.length() > 6.0:
				epos += back.normalized() * spd * 0.5 * delta

		ed["pos"] = Vector2(clampf(epos.x, 40.0, w - 40.0), clampf(epos.y, h * 0.35, h - 78.0))
		stage_enemies[i] = ed

	# Update Ranged Shadow Bolt Projectiles
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
	nearby_enemy_idx = _find_enemy_near(player_pos, 96.0)

	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
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
			var epos: Vector2 = ed.get("pos", _norm_to_screen(float(ed["x"]), float(ed["y"])))
			if origin.distance_to(epos) <= radius:
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
		_announce("%s: Spirit 100/100 & Sacred Oil Anointing Active (12s Shield)!" % t_name, 5.5)
	else:
		_announce("%s: Spirit Fully Restored to 100/100 (Safe Sanctuary Zone)!" % t_name, 4.5)

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
	_announce("SHIELD OF FAITH RAISED! Incoming damage & abilities reduced by 78%!", 3.0)

func _perform_sword_strike() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.40
	attack_swing_timer = 0.28
	var idx: int = _find_enemy_near(player_pos, 102.0)
	if idx != -1:
		var ed: Dictionary = stage_enemies[idx]
		var base_dmg: int = 42 + (relics_found.size() * 8)
		var enemy_armor: int = int(ed.get("armor", 0))
		var dmg: int = maxi(14, base_dmg - enemy_armor)
		var new_hp: int = maxi(0, int(ed.get("hp", 100)) - dmg)
		ed["hp"] = new_hp
		# Knockback enemy slightly on hit
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
			_announce("BATTLE VICTORY! Defeated %s (+%d Talents, +%d Score, +20 Manna)!" % [str(ed["name"]), t_won, sc], 6.5)
			emit_signal("battle_won", str(ed["name"]), sc, t_won)
		else:
			_announce("SWORD OF THE SPIRIT! Struck %s for %d DMG (Armor -%d | %d/%d HP left)" % [str(ed["name"]), dmg, enemy_armor, new_hp, int(ed["max_hp"])], 2.5)
	else:
		_announce("Sword of the Spirit drawn! Approach an adversary to strike.", 2.0)

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
		var tip: Vector2 = hilt + Vector2(dir_x * cos(sw_angle) * 28.0 * scale_f, sin(sw_angle) * 28.0 * scale_f)
		var blade_col: Color = Color(0.98, 0.35, 0.28) if is_enemy else Color(0.92, 0.96, 1.0)
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

	# 1. TABERNACLE / SANCTUARY & TRADING POST (SAFE ZONE)
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

	# 3. ACTIVE ENEMIES WITH ARCHETYPE SCALES, SPECIAL TELEGRAPHS & PROJECTILES
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

			# Special Ability Telegraph Ring!
			if tele_t > 0.0:
				var warn_r: float = 118.0 if arch == "giant" else 64.0
				draw_circle(epos, warn_r, Color(1.0, 0.22, 0.14, 0.22))
				draw_arc(epos, warn_r, 0.0, TAU, 32, Color(1.0, 0.32, 0.20, 0.90), 3.0)

			_draw_humanoid_figure(epos, e_col, Color(0.62, 0.48, 0.42), "enemy", e_dir, anim_time * 6.0, true, e_sw, e_shield, true, e_scale)

			var bar_w: float = 64.0
			var pct: float = float(ehp) / float(emax)
			var y_off: float = 38.0 * e_scale
			draw_rect(Rect2(epos.x - bar_w * 0.5, epos.y - y_off, bar_w, 6.0), Color(0.15, 0.05, 0.05))
			draw_rect(Rect2(epos.x - bar_w * 0.5, epos.y - y_off, bar_w * pct, 6.0), Color(0.95, 0.28, 0.24))
			if font != null:
				draw_string(font, epos + Vector2(-80.0, -y_off - 6.0), "%s (%s)" % [str(ed.get("name", "Sentinel")), str(ed.get("ability", ""))], HORIZONTAL_ALIGNMENT_CENTER, 160, 10, Color(1.0, 0.78, 0.72))

	# Draw Enemy Ranged Shadow Bolts
	for p_obj in enemy_projectiles:
		var pr: Dictionary = p_obj
		var p_pos: Vector2 = pr["pos"]
		draw_circle(p_pos, 9.0, Color(0.85, 0.22, 0.95, 0.45))
		draw_circle(p_pos, 5.0, Color(1.0, 0.45, 0.30))

	# 4. BIBLICAL NPCs
	var npcs: Array = st.get("npcs", [])
	for n_item in npcs:
		var npc: Dictionary = n_item
		var npos: Vector2 = _norm_to_screen(float(npc["x"]), float(npc["y"]))
		var ncol: Color = npc.get("color", Color.GOLD)
		var hgear: String = str(npc.get("headgear", "prophet"))
		_draw_humanoid_figure(npos, ncol, Color(0.86, 0.70, 0.54), hgear, 1.0, 0.0, false, 0.0, false, false, 1.0)
		if font != null:
			draw_string(font, npos + Vector2(-52.0, -34.0), "%s [E]" % str(npc.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 104, 12, Color(1.0, 0.96, 0.84))

	# 5. REMOTE MULTIPLAYER PILGRIMS
	for rp_item in remote_pilgrims:
		var rp: Dictionary = rp_item
		if str(rp.get("stage", "")) == current_stage:
			var rpos: Vector2 = Vector2(float(rp.get("x", 200.0)), float(rp.get("y", 200.0)))
			var r_robe_key: String = str(rp.get("robe", "Galilee Cyan"))
			var r_col: Color = ROBE_PALETTE.get(r_robe_key, Color(0.35, 0.85, 1.0))
			_draw_humanoid_figure(rpos, r_col, Color(0.88, 0.72, 0.56), "pilgrim", 1.0, anim_time * 4.0, false, 0.0, false, false, 1.0)
			if font != null:
				draw_string(font, rpos + Vector2(-54.0, -34.0), str(rp.get("name", "Pilgrim")), HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color(0.78, 0.96, 1.0))

	# 6. LOCAL PLAYER AVATAR
	var stride: float = anim_time * 12.0 if is_walking else 0.0
	var my_robe: Color = Color(1.0, 0.30, 0.30) if player_hit_flash > 0.0 else ROBE_PALETTE.get(local_robe_name, Color(0.18, 0.48, 0.92))
	var in_combat: bool = (nearby_enemy_idx != -1 or attack_swing_timer > 0.0)
	_draw_humanoid_figure(player_pos, my_robe, Color(0.90, 0.74, 0.58), "pilgrim", facing_dir, stride, in_combat, attack_swing_timer, shield_active, false, 1.0)

	# 7. LEFT & RIGHT STAGE PORTALS
	var left_p: Vector2 = Vector2(44.0, h * 0.56)
	var right_p: Vector2 = Vector2(w - 44.0, h * 0.56)
	draw_circle(left_p, 26.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.26 * tab_pulse))
	draw_arc(left_p, 26.0, 0.0, TAU, 28, accent_col, 2.5)
	draw_circle(right_p, 26.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.26 * tab_pulse))
	draw_arc(right_p, 26.0, 0.0, TAU, 28, accent_col, 2.5)

	# 8. DIEGETIC TOP HUD
	if font != null:
		draw_rect(Rect2(12.0, 10.0, w - 24.0, 52.0), Color(0.05, 0.05, 0.08, 0.86))
		draw_string(font, Vector2(22.0, 30.0), "%s   |   TALENTS: %d   |   SPIRIT: %d/%d   |   MANNA: %d [R]   |   OIL: %d   |   TIMBER: %d   |   STONE: %d" % [str(st["title"]), earned_talents, spirit_hp, max_spirit_hp, manna_rations, anointing_oil, timber_stock, stone_stock], HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 13, accent_col)
		draw_string(font, Vector2(22.0, 50.0), "Combat: [F / Right-Click] Sword Strike  |  [Q] Shield of Faith (Blocks Abilities)  |  [R] Eat Manna  |  [T] Trade Supplies  |  [E] Chest / NPC", HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 11, Color(0.88, 0.90, 0.95))

		draw_string(font, player_pos + Vector2(-54.0, -34.0), local_pilgrim_name, HORIZONTAL_ALIGNMENT_CENTER, 108, 12, Color.WHITE)
		draw_string(font, Vector2(14.0, h * 0.56 + 40.0), "< PREV ERA", HORIZONTAL_ALIGNMENT_LEFT, 96, 11, accent_col)
		draw_string(font, Vector2(w - 96.0, h * 0.56 + 40.0), "NEXT ERA >", HORIZONTAL_ALIGNMENT_RIGHT, 84, 11, accent_col)

		if banner_timer > 0.0 and banner_text != "":
			draw_rect(Rect2(16.0, h - 98.0, w - 32.0, 28.0), Color(0.06, 0.05, 0.09, 0.92))
			draw_string(font, Vector2(24.0, h - 79.0), banner_text, HORIZONTAL_ALIGNMENT_LEFT, int(w - 48.0), 13, Color(1.0, 0.94, 0.58))
