extends Control

var keep_level: int = 1
var combined_power: int = 1000
var current_era: String = "ERA_TORAH"
var conquered_chapters: Array = []
var active_assignments: Dictionary = {}
var pulse_phase: float = 0.0

const ERA_PALETTES := {
	"ERA_TORAH": Color(0.14, 0.11, 0.07, 1.0),
	"ERA_HISTORY": Color(0.15, 0.09, 0.08, 1.0),
	"ERA_WISDOM": Color(0.11, 0.10, 0.17, 1.0),
	"ERA_PROPHETS": Color(0.16, 0.08, 0.11, 1.0),
	"ERA_GOSPELS": Color(0.08, 0.13, 0.16, 1.0),
	"ERA_EPISTLES": Color(0.10, 0.13, 0.10, 1.0)
}

func _ready() -> void:
	custom_minimum_size = Vector2(0, 132)
	set_process(true)

func _process(delta: float) -> void:
	pulse_phase += delta * 2.2
	queue_redraw()

func update_citadel(sh: Dictionary, gen: Dictionary, era_name: String) -> void:
	current_era = era_name
	combined_power = int(sh.get("total_combined_power", sh.get("dynasty_power", 1000)))
	var blds: Dictionary = sh.get("buildings", {})
	var keep_info: Dictionary = blds.get("sanctuary_keep", {})
	keep_level = int(keep_info.get("level", 1))
	conquered_chapters = sh.get("conquered_chapters", []).duplicate()
	active_assignments = gen.get("assignments", {}).duplicate()
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 10.0 or h <= 10.0:
		return
	var sky: Color = ERA_PALETTES.get(current_era, Color(0.12, 0.10, 0.08, 1.0))
	draw_rect(Rect2(Vector2.ZERO, size), sky)
	# Gold border frame
	var gold := Color(0.86, 0.70, 0.30, 0.95)
	draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), gold, false, 2.0)
	# Ground terrain strip
	var ground_y := h - 24.0
	draw_rect(Rect2(Vector2(4, ground_y), Vector2(w - 8, 20)), Color(0.22, 0.18, 0.12, 1.0))
	# Rampart Walls across Citadel
	var wall_color := Color(0.46, 0.42, 0.36, 1.0)
	draw_rect(Rect2(Vector2(36, ground_y - 26), Vector2(w * 0.48, 26)), wall_color)
	for bx in range(40, int(w * 0.48), 22):
		draw_rect(Rect2(Vector2(bx, ground_y - 33), Vector2(12, 7)), wall_color)
	# Central Sanctuary Keep (height scales dynamically with keep_level)
	var keep_h := clampf(44.0 + float(keep_level - 1) * 10.0, 44.0, h - 34.0)
	var keep_x := w * 0.22
	var keep_w := 68.0
	draw_rect(Rect2(Vector2(keep_x, ground_y - keep_h), Vector2(keep_w, keep_h)), Color(0.62, 0.54, 0.40, 1.0))
	draw_rect(Rect2(Vector2(keep_x, ground_y - keep_h), Vector2(keep_w, keep_h)), gold, false, 1.5)
	# Golden Menorah / Tabernacle Beacon atop Keep
	var glow := 0.72 + 0.28 * sin(pulse_phase)
	draw_circle(Vector2(keep_x + keep_w * 0.5, ground_y - keep_h - 9.0), 6.5, Color(1.0, 0.84, 0.28, glow))
	# Flanking Watchtower & Scriptorium
	draw_rect(Rect2(Vector2(54, ground_y - 54), Vector2(28, 54)), Color(0.52, 0.46, 0.38, 1.0))
	draw_rect(Rect2(Vector2(keep_x + keep_w + 24, ground_y - 46), Vector2(46, 46)), Color(0.42, 0.48, 0.56, 1.0))
	# 6-Era Campaign Conquest Nodes on Right Half of Canvas
	var font := ThemeDB.fallback_font
	var era_tags := ["TORAH", "HISTORY", "WISDOM", "PROPHETS", "GOSPELS", "EPISTLES"]
	var ch_ids := ["CH_01_MAMRE", "CH_02_JERICHO", "CH_03_ZION_COURT", "CH_04_CARMEL", "CH_05_CAPERNAUM", "CH_06_ANTIOCH_MISSION"]
	var map_start_x := w * 0.56
	var step_x := (w * 0.40) / 5.0
	for i in range(6):
		var cx := map_start_x + float(i) * step_x
		var cy := h * 0.52
		if i < 5:
			draw_line(Vector2(cx, cy), Vector2(cx + step_x, cy), Color(0.55, 0.48, 0.34, 0.7), 2.0)
		var conquered := conquered_chapters.has(ch_ids[i])
		var node_col := Color(0.22, 0.78, 0.42, 1.0) if conquered else Color(0.32, 0.30, 0.28, 1.0)
		draw_circle(Vector2(cx, cy), 11.0, node_col)
		draw_circle(Vector2(cx, cy), 11.0, gold, false, 1.5)
		if font:
			draw_string(font, Vector2(cx - 22, cy + 24), era_tags[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.92, 0.88, 0.78, 0.9))
	# Active Commanders & Citadel Status Overlay
	if font:
		var cmd_list := ", ".join(active_assignments.values()) if not active_assignments.is_empty() else "NONE STATIONED"
		draw_string(font, Vector2(14, 20), "COVENANT CITADEL OF ZION [KEEP Lv.%d | POWER %d]  ?  STATIONED COMMANDERS: %s" % [keep_level, combined_power, cmd_list], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, gold)
		draw_string(font, Vector2(map_start_x, 20), "SIX-ERA CAMPAIGN CONQUEST TRACK (%d/6 CONQUERED)" % conquered_chapters.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.92, 0.85, 0.95))
