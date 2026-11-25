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

const STAGE_DATA := {
	"ERA_TORAH": {
		"name": "Stage 1: Sinai & Wilderness Tabernacle",
		"sky": Color(0.11, 0.08, 0.05),
		"ground": Color(0.24, 0.17, 0.09),
		"accent": Color(0.95, 0.78, 0.28),
		"landmark": "Tabernacle of Meeting & Stone Tablets",
		"npcs": [
			{"name": "Moses", "x": 0.34, "y": 0.48, "color": Color(0.88, 0.72, 0.30), "scenario": "GEN_001", "greeting": "Peace be with you, Pilgrim! Step near the Tabernacle or press [E] to walk the Torah covenant trials."},
			{"name": "Caleb", "x": 0.64, "y": 0.56, "color": Color(0.32, 0.76, 0.48), "scenario": "TOR_005", "greeting": "Do not fear the giants in the land! Press [E] to stand with faith at Kadesh-Barnea."}
		]
	},
	"ERA_HISTORY": {
		"name": "Stage 2: Jerusalem Walls & Jordan Crossing",
		"sky": Color(0.08, 0.10, 0.14),
		"ground": Color(0.18, 0.21, 0.16),
		"accent": Color(0.45, 0.82, 0.55),
		"landmark": "Rebuilt Watchtower & Covenant Stones",
		"npcs": [
			{"name": "Joshua", "x": 0.36, "y": 0.50, "color": Color(0.85, 0.42, 0.28), "scenario": "HIS_001", "greeting": "Be strong and of good courage! Press [E] to lead Israel across the Jordan."},
			{"name": "Nehemiah", "x": 0.66, "y": 0.46, "color": Color(0.38, 0.68, 0.90), "scenario": "HIS_005", "greeting": "Trowel in one hand, sword in the other! Press [E] to defend Jerusalem's walls."}
		]
	},
	"ERA_WISDOM": {
		"name": "Stage 3: Mount Zion & Temple Courts",
		"sky": Color(0.12, 0.08, 0.16),
		"ground": Color(0.22, 0.16, 0.24),
		"accent": Color(0.96, 0.82, 0.36),
		"landmark": "Golden Sanctuary & Harp Pavilion",
		"npcs": [
			{"name": "King David", "x": 0.35, "y": 0.52, "color": Color(0.95, 0.76, 0.25), "scenario": "WIS_001", "greeting": "The Lord is my Shepherd! Press [E] to tune your heart to covenant worship."},
			{"name": "Solomon", "x": 0.65, "y": 0.48, "color": Color(0.76, 0.55, 0.95), "scenario": "WIS_004", "greeting": "Wisdom is the principal thing! Press [E] to judge with a discerning heart."}
		]
	},
	"ERA_PROPHETS": {
		"name": "Stage 4: Prophetic Watchtower & Scroll Hall",
		"sky": Color(0.14, 0.07, 0.08),
		"ground": Color(0.23, 0.13, 0.13),
		"accent": Color(0.96, 0.55, 0.32),
		"landmark": "Watchman Rampart & Scroll Brazier",
		"npcs": [
			{"name": "Isaiah", "x": 0.36, "y": 0.48, "color": Color(0.95, 0.62, 0.30), "scenario": "PRO_001", "greeting": "Here am I, send me! Press [E] to proclaim hope and restoration."},
			{"name": "Jeremiah", "x": 0.64, "y": 0.54, "color": Color(0.55, 0.78, 0.88), "scenario": "PRO_004", "greeting": "God writes His New Covenant upon the heart! Press [E] to stand firm."}
		]
	},
	"ERA_GOSPELS": {
		"name": "Stage 5: Sea of Galilee & Olive Grove",
		"sky": Color(0.06, 0.13, 0.18),
		"ground": Color(0.12, 0.24, 0.22),
		"accent": Color(0.42, 0.88, 0.95),
		"landmark": "Galilee Harbor & Hillside Teaching Stone",
		"npcs": [
			{"name": "Peter", "x": 0.35, "y": 0.52, "color": Color(0.40, 0.82, 0.96), "scenario": "GOS_001", "greeting": "Launch out into the deep! Press [E] to walk on faith and follow the Messiah."},
			{"name": "Good Samaritan", "x": 0.66, "y": 0.48, "color": Color(0.48, 0.90, 0.62), "scenario": "GOS_004", "greeting": "Mercy triumphs on the Jericho road! Press [E] to practice Kingdom compassion."}
		]
	},
	"ERA_EPISTLES": {
		"name": "Stage 6: Apostolic Upper Room & Roman Road",
		"sky": Color(0.10, 0.09, 0.16),
		"ground": Color(0.18, 0.17, 0.25),
		"accent": Color(0.98, 0.84, 0.42),
		"landmark": "Pentecost Flame Pillar & Pilgrim Waystation",
		"npcs": [
			{"name": "Apostle Paul", "x": 0.36, "y": 0.48, "color": Color(0.96, 0.80, 0.35), "scenario": "EPI_001", "greeting": "Put on the whole armor of God! Press [E] to advance the Gospel across the nations."},
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

func _ready() -> void:
	custom_minimum_size = Vector2(0, 240)
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)

func set_stage(era_id: String) -> void:
	if STAGE_DATA.has(era_id):
		current_stage = era_id
		var sz := size
		if sz.x < 100.0:
			sz = Vector2(820.0, 240.0)
		player_pos = Vector2(sz.x * 0.5, sz.y * 0.62)
		target_pos = player_pos
		has_click_target = false
		active_dialogue = ""
		portal_cooldown = 0.8
		queue_redraw()

func set_remote_pilgrims(pilgrims: Array) -> void:
	remote_pilgrims = pilgrims
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		var click_p: Vector2 = event.position
		var clicked_npc := _find_npc_near(click_p, 44.0)
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
		portal_cooldown = max(0.0, portal_cooldown - delta)

	var input_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vec.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vec.x += 1.0

	var moved := false
	if input_vec.length() > 0.01:
		has_click_target = false
		player_pos = _clamp_walk_pos(player_pos + input_vec.normalized() * move_speed * delta)
		moved = true
	elif has_click_target:
		var diff := target_pos - player_pos
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
	var w := max(size.x, 320.0)
	var h := max(size.y, 200.0)
	return Vector2(clamp(p.x, 28.0, w - 28.0), clamp(p.y, 64.0, h - 24.0))

func _npc_screen_pos(npc: Dictionary) -> Vector2:
	var w := max(size.x, 320.0)
	var h := max(size.y, 200.0)
	return Vector2(float(npc.get("x", 0.5)) * w, float(npc.get("y", 0.5)) * h)

func _find_npc_near(origin: Vector2, radius: float) -> Dictionary:
	var st: Dictionary = STAGE_DATA.get(current_stage, STAGE_DATA["ERA_TORAH"])
	for npc in st.get("npcs", []):
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
	var w := max(size.x, 320.0)
	var h := max(size.y, 200.0)
	var left_portal := Vector2(36.0, h * 0.55)
	var right_portal := Vector2(w - 36.0, h * 0.55)
	var idx := ERA_ORDER.find(current_stage)
	if player_pos.distance_to(right_portal) < 30.0:
		var next_era: String = ERA_ORDER[(idx + 1) % ERA_ORDER.size()]
		set_stage(next_era)
		emit_signal("stage_portal_entered", next_era)
	elif player_pos.distance_to(left_portal) < 30.0:
		var prev_era: String = ERA_ORDER[(idx - 1 + ERA_ORDER.size()) % ERA_ORDER.size()]
		set_stage(prev_era)
		emit_signal("stage_portal_entered", prev_era)

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 20.0 or h < 20.0:
		return
	var st: Dictionary = STAGE_DATA.get(current_stage, STAGE_DATA["ERA_TORAH"])
	var sky_col: Color = st["sky"]
	var ground_col: Color = st["ground"]
	var accent_col: Color = st["accent"]

	# Sky & Walkable Terrain
	draw_rect(Rect2(0, 0, w, h * 0.34), sky_col)
	draw_rect(Rect2(0, h * 0.34, w, h * 0.66), ground_col)
	draw_line(Vector2(0, h * 0.34), Vector2(w, h * 0.34), accent_col, 2.0)

	# Subtle Stone Courtyard Grid
	var step_x := 64.0
	var gx := step_x
	while gx < w:
		draw_line(Vector2(gx, h * 0.34), Vector2(gx, h), Color(1, 1, 1, 0.05), 1.0)
		gx += step_x

	# Center Landmark Monument
	var cx := w * 0.5
	var cy := h * 0.34
	draw_rect(Rect2(cx - 46, cy - 36, 92, 36), Color(0.28, 0.24, 0.18))
	draw_rect(Rect2(cx - 34, cy - 52, 68, 16), accent_col)

	# Left & Right Era Portals
	var pulse := 0.65 + 0.35 * sin(anim_time * 4.0)
	var left_p := Vector2(36.0, h * 0.55)
	var right_p := Vector2(w - 36.0, h * 0.55)
	draw_circle(left_p, 22.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.25 * pulse))
	draw_arc(left_p, 22.0, 0.0, TAU, 24, accent_col, 2.0)
	draw_circle(right_p, 22.0, Color(accent_col.r, accent_col.g, accent_col.b, 0.25 * pulse))
	draw_arc(right_p, 22.0, 0.0, TAU, 24, accent_col, 2.0)

	# Draw Stage NPCs
	var font := ThemeDB.fallback_font
	for npc in st.get("npcs", []):
		var npos := _npc_screen_pos(npc)
		var ncol: Color = npc.get("color", Color.GOLD)
		draw_circle(npos + Vector2(0, 12), 14.0, Color(0, 0, 0, 0.35))
		draw_circle(npos, 13.0, ncol)
		draw_arc(npos, 16.0, 0.0, TAU, 20, Color(1, 1, 1, 0.65), 1.5)
		if font != null:
			draw_string(font, npos + Vector2(-28, -20), str(npc.get("name", "")), HORIZONTAL_ALIGNMENT_CENTER, 56, 12, Color(1, 0.96, 0.82))

	# Draw Remote Multiplayer Pilgrims (when connected in Phase 33+)
	for rp in remote_pilgrims:
		if str(rp.get("stage", "")) == current_stage:
			var rpos := Vector2(float(rp.get("x", 150.0)), float(rp.get("y", 150.0)))
			draw_circle(rpos, 12.0, Color(0.35, 0.85, 1.0))
			if font != null:
				draw_string(font, rpos + Vector2(-36, -18), str(rp.get("name", "Pilgrim")), HORIZONTAL_ALIGNMENT_CENTER, 72, 11, Color(0.7, 0.95, 1.0))

	# Draw Local Player Avatar
	var bob := sin(anim_time * 8.0) * 2.0 if has_click_target else 0.0
	var pdraw := player_pos + Vector2(0, bob)
	draw_circle(player_pos + Vector2(0, 13), 15.0, Color(0, 0, 0, 0.45))
	draw_circle(pdraw, 14.0, Color(0.98, 0.85, 0.35))
	draw_circle(pdraw, 8.0, Color(0.16, 0.34, 0.62))
	draw_arc(pdraw, 18.0, 0.0, TAU, 24, Color(1.0, 0.92, 0.55, 0.85), 2.0)

	if font != null:
		# Stage Header & Controls Hint
		draw_string(font, Vector2(14, 22), "%s  |  %s" % [str(st["name"]), str(st["landmark"])], HORIZONTAL_ALIGNMENT_LEFT, int(w - 28), 14, accent_col)
		draw_string(font, Vector2(14, 40), "Move: [WASD / Arrows / Click]  |  Walk into Side Portals to Change Stage  |  Walk to NPC + Press [E] to Talk", HORIZONTAL_ALIGNMENT_LEFT, int(w - 28), 11, Color(0.88, 0.88, 0.92))
		draw_string(font, Vector2(12, h * 0.55 + 34), "< PREV ERA", HORIZONTAL_ALIGNMENT_LEFT, 90, 10, accent_col)
		draw_string(font, Vector2(w - 86, h * 0.55 + 34), "NEXT ERA >", HORIZONTAL_ALIGNMENT_RIGHT, 76, 10, accent_col)
		draw_string(font, pdraw + Vector2(-24, -22), "YOU", HORIZONTAL_ALIGNMENT_CENTER, 48, 11, Color.WHITE)

		if not nearby_npc.is_empty():
			var prompt_txt := "Press [E] or Click to speak with %s" % str(nearby_npc.get("name", ""))
			draw_rect(Rect2(w * 0.5 - 165, h - 54, 330, 22), Color(0.08, 0.08, 0.12, 0.88))
			draw_string(font, Vector2(w * 0.5 - 160, h - 38), prompt_txt, HORIZONTAL_ALIGNMENT_CENTER, 320, 12, Color(1.0, 0.92, 0.45))

		if active_dialogue != "":
			draw_rect(Rect2(14, h - 30, w - 28, 24), Color(0.07, 0.06, 0.10, 0.94))
			draw_string(font, Vector2(20, h - 13), active_dialogue, HORIZONTAL_ALIGNMENT_LEFT, int(w - 40), 12, Color(0.98, 0.95, 0.82))
