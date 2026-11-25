extends Control
class_name SovereignWorldStage

signal npc_dialogue_triggered(npc_name: String, era_id: String, scenario_id: String, greeting: String)
signal stage_portal_entered(target_era_id: String)
signal player_moved(stage_id: String, pos_x: float, pos_y: float)

const ERA_ORDER := [
	"ERA_TORAH",
	"ERA_HISTORY",
	"ERA_WISDOM",
	"ERA_PROPHETS",
	"ERA_GOSPELS",
	"ERA_EPISTLES"
]

const ROBE_PALETTE := {
	"Sapphire": Color(0.18, 0.45, 0.88),
	"Judah Gold": Color(0.92, 0.72, 0.20),
	"Emerald": Color(0.20, 0.72, 0.46),
	"Tyrian Purple": Color(0.58, 0.26, 0.78),
	"Crimson": Color(0.84, 0.24, 0.28),
	"Galilee Cyan": Color(0.22, 0.78, 0.86)
}

const STAGE_DATA := {
	"ERA_TORAH": {
		"name": "Stage 1: Sinai & Wilderness Tabernacle",
		"sky": Color(0.11, 0.08, 0.05),
		"ground": Color(0.24, 0.17, 0.09),
		"accent": Color(0.95, 0.78, 0.28),
		"landmark": "Mount Sinai, Golden Menorah & Tabernacle",
		"npcs": [
			{"name": "Moses", "x": 0.34, "y": 0.50, "color": Color(0.88, 0.72, 0.30), "scenario": "GEN_001", "greeting": "Peace be with you, Pilgrim! Step near the Tabernacle or press [E] to walk the Torah covenant trials."},
			{"name": "Caleb", "x": 0.64, "y": 0.56, "color": Color(0.32, 0.76, 0.48), "scenario": "TOR_005", "greeting": "Do not fear the giants in the land! Press [E] to stand with faith at Kadesh-Barnea."}
		]
	},
	"ERA_HISTORY": {
		"name": "Stage 2: Jerusalem Walls & Jordan Crossing",
		"sky": Color(0.08, 0.10, 0.14),
		"ground": Color(0.18, 0.21, 0.16),
		"accent": Color(0.45, 0.82, 0.55),
		"landmark": "Jerusalem Stone Battlements & Jordan Stream",
		"npcs": [
			{"name": "Joshua", "x": 0.36, "y": 0.50, "color": Color(0.85, 0.42, 0.28), "scenario": "HIS_001", "greeting": "Be strong and of good courage! Press [E] to lead Israel across the Jordan."},
			{"name": "Nehemiah", "x": 0.66, "y": 0.48, "color": Color(0.38, 0.68, 0.90), "scenario": "HIS_005", "greeting": "Trowel in one hand, sword in the other! Press [E] to defend Jerusalem's walls."}
		]
	},
	"ERA_WISDOM": {
		"name": "Stage 3: Mount Zion & Temple Courts",
		"sky": Color(0.12, 0.08, 0.16),
		"ground": Color(0.22, 0.16, 0.24),
		"accent": Color(0.96, 0.82, 0.36),
		"landmark": "Solomon's Twin Pillars (Jachin & Boaz) & Golden Dome",
		"npcs": [
			{"name": "King David", "x": 0.35, "y": 0.52, "color": Color(0.95, 0.76, 0.25), "scenario": "WIS_001", "greeting": "The Lord is my Shepherd! Press [E] to tune your heart to covenant worship."},
			{"name": "Solomon", "x": 0.65, "y": 0.50, "color": Color(0.76, 0.55, 0.95), "scenario": "WIS_004", "greeting": "Wisdom is the principal thing! Press [E] to judge with a discerning heart."}
		]
	},
	"ERA_PROPHETS": {
		"name": "Stage 4: Prophetic Watchtower & Scroll Hall",
		"sky": Color(0.14, 0.07, 0.08),
		"ground": Color(0.23, 0.13, 0.13),
		"accent": Color(0.96, 0.55, 0.32),
		"landmark": "Watchman Rampart & Eternal Scroll Brazier",
		"npcs": [
			{"name": "Isaiah", "x": 0.36, "y": 0.50, "color": Color(0.95, 0.62, 0.30), "scenario": "PRO_001", "greeting": "Here am I, send me! Press [E] to proclaim hope and restoration."},
			{"name": "Jeremiah", "x": 0.64, "y": 0.54, "color": Color(0.55, 0.78, 0.88), "scenario": "PRO_004", "greeting": "God writes His New Covenant upon the heart! Press [E] to stand firm."}
		]
	},
	"ERA_GOSPELS": {
		"name": "Stage 5: Sea of Galilee & Olive Grove",
		"sky": Color(0.06, 0.13, 0.18),
		"ground": Color(0.12, 0.24, 0.22),
		"accent": Color(0.42, 0.88, 0.95),
		"landmark": "Galilee Sailboat Harbor & Olive Grove",
		"npcs": [
			{"name": "Peter", "x": 0.35, "y": 0.52, "color": Color(0.40, 0.82, 0.96), "scenario": "GOS_001", "greeting": "Launch out into the deep! Press [E] to walk on faith and follow the Messiah."},
			{"name": "Good Samaritan", "x": 0.66, "y": 0.50, "color": Color(0.48, 0.90, 0.62), "scenario": "GOS_004", "greeting": "Mercy triumphs on the Jericho road! Press [E] to practice Kingdom compassion."}
		]
	},
	"ERA_EPISTLES": {
		"name": "Stage 6: Apostolic Upper Room & Roman Road",
		"sky": Color(0.10, 0.09, 0.16),
		"ground": Color(0.18, 0.17, 0.25),
		"accent": Color(0.98, 0.84, 0.42),
		"landmark": "Pentecost Flame Pillar & Roman Stone Arch",
		"npcs": [
			{"name": "Apostle Paul", "x": 0.36, "y": 0.50, "color": Color(0.96, 0.80, 0.35), "scenario": "EPI_001", "greeting": "Put on the whole armor of God! Press [E] to advance the Gospel across the nations."},
			{"name": "Barnabas", "x": 0.65, "y": 0.54, "color": Color(0.62, 0.88, 0.55), "scenario": "EPI_004", "greeting": "Surrounded by a great cloud of witnesses! Press [E] to run with endurance."}
		]
	}
}

var current_stage: String = "ERA_TORAH"
var player_pos: Vector2 = Vector2(220.0, 145.0)
var target_pos: Vector2 = Vector2(220.0, 145.0)
var has_click_target: bool = false
var move_speed: float = 175.0
var anim_time: float = 0.0
var portal_cooldown: float = 0.0
var nearby_npc: Dictionary = {}
var active_dialogue: String = ""
var active_npc_name: String = ""
var active_npc_scenario: String = ""
var remote_pilgrims: Array = []
var local_pilgrim_name: String = "YOU"
var local_robe_name: String = "Sapphire"
var blessing_banner: String = ""
var blessing_timer: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(0, 250)
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)

func set_stage(era_id: String) -> void:
	if STAGE_DATA.has(era_id):
		current_stage = era_id
		var sz: Vector2 = size
		if sz.x < 100.0:
			sz = Vector2(820.0, 250.0)
		player_pos = Vector2(sz.x * 0.5, sz.y * 0.64)
		target_pos = player_pos
		has_click_target = false
		active_dialogue = ""
		portal_cooldown = 0.8
		queue_redraw()

func set_local_pilgrim_name(pname: String) -> void:
	var clean: String = pname.strip_edges()
	local_pilgrim_name = clean if clean != "" else "YOU"
	queue_redraw()

func set_local_robe_color(rname: String) -> void:
	if ROBE_PALETTE.has(rname):
		local_robe_name = rname
		queue_redraw()

func show_coop_blessing(text: String) -> void:
	blessing_banner = text
	blessing_timer = 7.5
	queue_redraw()

func set_remote_pilgrims(pilgrims: Array) -> void:
	remote_pilgrims = pilgrims
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		var click_p: Vector2 = event.position
		var clicked_npc: Dictionary = _find_npc_near(click_p, 44.0)
		if not clicked_npc.is_empty():
			target_pos = _npc_screen_pos(clicked_npc) + Vector2(0, 26)
			has_click_target = true
			_trigger_npc_talk(clicked_npc)
		else:
			target_pos = _clamp_walk_pos(click_p)
			has_click_target = true
		accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if not nearby_npc.is_empty():
				_trigger_npc_talk(nearby_npc)
				accept_event()

func _process(delta: float) -> void:
	anim_time += delta
	if portal_cooldown > 0.0:
		portal_cooldown = maxf(0.0, portal_cooldown - delta)
	if blessing_timer > 0.0:
		blessing_timer = maxf(0.0, blessing_timer - delta)
		if blessing_timer <= 0.0:
			blessing_banner = ""

	var input_vec: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vec.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vec.x += 1.0

	var moved: bool = false
	if input_vec.length() > 0.01:
		has_click_target = false
		player_pos = _clamp_walk_pos(player_pos + input_vec.normalized() * move_speed * delta)
		moved = true
	elif has_click_target:
		var diff: Vector2 = target_pos - player_pos
		if diff.length() > 4.0:
			player_pos = _clamp_walk_pos(player_pos + diff.normalized() * move_speed * delta)
			moved = true
		else:
			has_click_target = false

	if moved:
		emit_signal("player_moved", current_stage, player_pos.x, player_pos.y)

	nearby_npc = _find_npc_near(player_pos, 52.0)
	_check_portals()
	queue_redraw()

func _clamp_walk_pos(p: Vector2) -> Vector2:
	var w: float = maxf(size.x, 320.0)
	var h: float = maxf(size.y, 200.0)
	return Vector2(clampf(p.x, 28.0, w - 28.0), clampf(p.y, 74.0, h - 24.0))

func _npc_screen_pos(npc: Dictionary) -> Vector2:
	var w: float = maxf(size.x, 320.0)
	var h: float = maxf(size.y, 200.0)
	return Vector2(float(npc.get("x", 0.5)) * w, float(npc.get("y", 0.5)) * h)

func _find_npc_near(origin: Vector2, radius: float) -> Dictionary:
	var st: Dictionary = STAGE_DATA.get(current_stage, STAGE_DATA["ERA_TORAH"])
	var npcs: Array = st.get("npcs", [])
	for item in npcs:
		var npc: Dictionary = item
		if origin.distance_to(_npc_screen_pos(npc)) <= radius:
			return npc
	return {}

func _trigger_npc_talk(npc: Dictionary) -> void:
	active_npc_name = str(npc.get("name", "Guide"))
	active_npc_scenario = str(npc.get("scenario", "GEN_001"))
	active_dialogue = "%s: \"%s\"" % [active_npc_name, str(npc.get("greeting", ""))]
	emit_signal("npc_dialogue_triggered", active_npc_name, current_stage, active_npc_scenario, active_dialogue)

func _check_portals() -> void:
	if portal_cooldown > 0.0:
		return
	var w: float = maxf(size.x, 320.0)
	var h: float = maxf(size.y, 200.0)
	var left_portal: Vector2 = Vector2(36.0, h * 0.56)
	var right_portal: Vector2 = Vector2(w - 36.0, h * 0.56)
	var idx: int = ERA_ORDER.find(current_stage)
	if player_pos.distance_to(right_portal) < 30.0:
		var next_era: String = ERA_ORDER[(idx + 1) % ERA_ORDER.size()]
		set_stage(next_era)
		emit_signal("stage_portal_entered", next_era)
	elif player_pos.distance_to(left_portal) < 30.0:
		var prev_era: String = ERA_ORDER[(idx - 1 + ERA_ORDER.size()) % ERA_ORDER.size()]
		set_stage(prev_era)
		emit_signal("stage_portal_entered", prev_era)

func _draw_era_landmark(w: float, h: float, accent_col: Color) -> void:
	var cx: float = w * 0.5
	var horizon: float = h * 0.36
	if current_stage == "ERA_TORAH":
		# Sinai Peak & Tabernacle Tent
		var peak: PackedVector2Array = PackedVector2Array([Vector2(cx - 110.0, horizon), Vector2(cx - 45.0, horizon - 46.0), Vector2(cx + 20.0, horizon)])
		draw_colored_polygon(peak, Color(0.32, 0.22, 0.12))
		draw_rect(Rect2(cx - 26.0, horizon - 26.0, 74.0, 26.0), Color(0.45, 0.30, 0.14))
		draw_line(Vector2(cx + 11.0, horizon - 38.0), Vector2(cx + 11.0, horizon - 26.0), accent_col, 3.0)
	elif current_stage == "ERA_HISTORY":
		# Jerusalem Stone Battlements & Jordan Stream
		draw_rect(Rect2(cx - 72.0, horizon - 32.0, 144.0, 32.0), Color(0.34, 0.33, 0.28))
		for bx in range(-68, 68, 22):
			draw_rect(Rect2(cx + float(bx), horizon - 40.0, 12.0, 8.0), accent_col)
	elif current_stage == "ERA_WISDOM":
		# Solomon's Twin Pillars (Jachin & Boaz) + Golden Temple Dome
		draw_rect(Rect2(cx - 52.0, horizon - 44.0, 14.0, 44.0), accent_col)
		draw_rect(Rect2(cx + 38.0, horizon - 44.0, 14.0, 44.0), accent_col)
		draw_circle(Vector2(cx, horizon - 26.0), 26.0, Color(0.95, 0.78, 0.26))
		draw_rect(Rect2(cx - 34.0, horizon - 26.0, 68.0, 26.0), Color(0.32, 0.24, 0.36))
	elif current_stage == "ERA_PROPHETS":
		# Watchtower Rampart & Flickering Flame Brazier
		draw_rect(Rect2(cx - 24.0, horizon - 46.0, 48.0, 46.0), Color(0.36, 0.20, 0.18))
		var flame_r: float = 10.0 + 3.0 * sin(anim_time * 9.0)
		draw_circle(Vector2(cx, horizon - 54.0), flame_r, Color(1.0, 0.55, 0.15))
	elif current_stage == "ERA_GOSPELS":
		# Sea of Galilee Cove & Fishing Sailboat
		draw_rect(Rect2(cx - 120.0, horizon + 6.0, 240.0, 24.0), Color(0.10, 0.44, 0.62, 0.75))
		var sail: PackedVector2Array = PackedVector2Array([Vector2(cx, horizon - 36.0), Vector2(cx + 26.0, horizon - 8.0), Vector2(cx, horizon - 8.0)])
		draw_colored_polygon(sail, Color(0.96, 0.94, 0.86))
		draw_rect(Rect2(cx - 22.0, horizon - 6.0, 48.0, 10.0), Color(0.46, 0.28, 0.14))
	else:
		# Pentecost Flame Pillar & Apostolic Archway
		draw_arc(Vector2(cx, horizon), 34.0, PI, TAU, 24, accent_col, 4.0)
		var p_flame: float = 11.0 + 3.5 * cos(anim_time * 10.0)
		draw_circle(Vector2(cx, horizon - 42.0), p_flame, Color(1.0, 0.72, 0.22))

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w < 20.0 or h < 20.0:
		return
	var st: Dictionary = STAGE_DATA.get(current_stage, STAGE_DATA["ERA_TORAH"])
	var sky_col: Color = st["sky"]
	var ground_col: Color = st["ground"]
	var accent_col: Color = st["accent"]

	draw_rect(Rect2(0.0, 0.0, w, h * 0.36), sky_col)
	draw_rect(Rect2(0.0, h * 0.36, w, h * 0.64), ground_col)
	draw_line(Vector2(0.0, h * 0.36), Vector2(w, h * 0.36), accent_col, 2.0)

	var step_x: float = 64.0
	var gx: float = step_x
	while gx < w:
		draw_line(Vector2(gx, h * 0.36), Vector2(gx, h), Color(1.0, 1.0, 1.0, 0.05), 1.0)
		gx += step_x

	_draw_era_landmark(w, h, accent_col)

	var pulse: float = 0.65 + 0.35 * sin(anim_time * 4.0)
	var left_p: Vector2 = Vector2(36.0, h * 0.56)
	var right_p: Vector2 = Vector2(w - 36.0, h * 0.56)
	draw_circle(left_p, 22.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.25 * pulse))
	draw_arc(left_p, 22.0, 0.0, TAU, 24, accent_col, 2.0)
	draw_circle(right_p, 22.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.25 * pulse))
	draw_arc(right_p, 22.0, 0.0, TAU, 24, accent_col, 2.0)

	var font: Font = ThemeDB.fallback_font
	var npcs: Array = st.get("npcs", [])
	for item in npcs:
		var npc: Dictionary = item
		var npos: Vector2 = _npc_screen_pos(npc)
		var ncol: Color = npc.get("color", Color.GOLD)
		draw_circle(npos + Vector2(0.0, 12.0), 14.0, Color(0.0, 0.0, 0.0, 0.35))
		draw_circle(npos, 13.0, ncol)
		draw_arc(npos, 16.0, 0.0, TAU, 20, Color(1.0, 1.0, 1.0, 0.65), 1.5)
		if font != null:
			draw_string(font, npos + Vector2(-28.0, -20.0), str(npc.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 56, 12, Color(1.0, 0.96, 0.82))

	for rp_item in remote_pilgrims:
		var rp: Dictionary = rp_item
		if str(rp.get("stage", "")) == current_stage:
			var rpos: Vector2 = Vector2(float(rp.get("x", 150.0)), float(rp.get("y", 150.0)))
			var r_robe_key: String = str(rp.get("robe", "Galilee Cyan"))
			var r_col: Color = ROBE_PALETTE.get(r_robe_key, Color(0.35, 0.85, 1.0))
			draw_circle(rpos + Vector2(0.0, 12.0), 14.0, Color(0.0, 0.0, 0.0, 0.40))
			draw_circle(rpos, 13.0, Color(0.96, 0.86, 0.45))
			draw_circle(rpos, 8.0, r_col)
			if font != null:
				draw_string(font, rpos + Vector2(-42.0, -20.0), str(rp.get("name", "Pilgrim")), HORIZONTAL_ALIGNMENT_CENTER, 84, 11, Color(0.78, 0.96, 1.0))

	var bob: float = sin(anim_time * 8.0) * 2.0 if has_click_target else 0.0
	var pdraw: Vector2 = player_pos + Vector2(0.0, bob)
	var my_robe: Color = ROBE_PALETTE.get(local_robe_name, Color(0.18, 0.45, 0.88))
	draw_circle(player_pos + Vector2(0.0, 13.0), 15.0, Color(0.0, 0.0, 0.0, 0.45))
	draw_circle(pdraw, 14.0, Color(0.98, 0.85, 0.35))
	draw_circle(pdraw, 8.5, my_robe)
	draw_arc(pdraw, 18.0, 0.0, TAU, 24, Color(1.0, 0.92, 0.55, 0.85), 2.0)

	if font != null:
		draw_string(font, Vector2(14.0, 22.0), "%s  |  %s" % [str(st["name"]), str(st["landmark"])], HORIZONTAL_ALIGNMENT_LEFT, int(w - 28.0), 14, accent_col)
		draw_string(font, Vector2(14.0, 40.0), "Move: [WASD / Arrows / Click]  |  Side Portals Change Stage  |  NPC + [E] to Talk", HORIZONTAL_ALIGNMENT_LEFT, int(w - 28.0), 11, Color(0.88, 0.88, 0.92))
		draw_string(font, Vector2(12.0, h * 0.56 + 34.0), "< PREV ERA", HORIZONTAL_ALIGNMENT_LEFT, 90, 10, accent_col)
		draw_string(font, Vector2(w - 86.0, h * 0.56 + 34.0), "NEXT ERA >", HORIZONTAL_ALIGNMENT_RIGHT, 76, 10, accent_col)
		draw_string(font, pdraw + Vector2(-42.0, -22.0), local_pilgrim_name, HORIZONTAL_ALIGNMENT_CENTER, 84, 11, Color.WHITE)

		if blessing_banner != "":
			draw_rect(Rect2(w * 0.5 - 220.0, 46.0, 440.0, 22.0), Color(0.24, 0.18, 0.04, 0.92))
			draw_string(font, Vector2(w * 0.5 - 214.0, 62.0), blessing_banner, HORIZONTAL_ALIGNMENT_CENTER, 428, 12, Color(1.0, 0.92, 0.42))

		if not nearby_npc.is_empty():
			var prompt_txt: String = "Press [E] or Click to speak with %s" % str(nearby_npc.get("name", ""))
			draw_rect(Rect2(w * 0.5 - 165.0, h - 54.0, 330.0, 22.0), Color(0.08, 0.08, 0.12, 0.88))
			draw_string(font, Vector2(w * 0.5 - 160.0, h - 38.0), prompt_txt, HORIZONTAL_ALIGNMENT_CENTER, 320, 12, Color(1.0, 0.92, 0.45))

		if active_dialogue != "":
			draw_rect(Rect2(14.0, h - 30.0, w - 28.0, 24.0), Color(0.07, 0.06, 0.10, 0.94))
			draw_string(font, Vector2(20.0, h - 13.0), active_dialogue, HORIZONTAL_ALIGNMENT_LEFT, int(w - 40.0), 12, Color(0.98, 0.95, 0.82))
