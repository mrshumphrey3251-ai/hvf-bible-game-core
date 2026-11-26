extends Control
class_name SovereignFirstPerson3D

signal npc_dialogue_triggered(npc_name: String, era_id: String, scenario_id: String, greeting: String)
signal stage_portal_entered(target_era_id: String)
signal player_moved(stage_id: String, pos_x: float, pos_y: float)
signal chest_looted(chest_id: String, loot_summary: String)
signal battle_won(enemy_name: String, reward_score: int, reward_talents: int)
signal supplies_traded(talents_gained: int)
signal trial_requested()
signal armory_toggled()
signal armory_updated(talents_left: int, sword_lvl: int, armor_lvl: int, boots_lvl: int)
signal academy_toggled()
signal upgrade_modal_requested(reason: String)

const ERA_ORDER := ["ERA_TORAH", "ERA_HISTORY", "ERA_WISDOM", "ERA_PROPHETS", "ERA_GOSPELS", "ERA_EPISTLES"]

const ROBE_PALETTE := {
	"Sapphire": Color(0.14, 0.34, 0.68),
	"Judah Gold": Color(0.78, 0.58, 0.16),
	"Emerald": Color(0.14, 0.52, 0.32),
	"Tyrian Purple": Color(0.44, 0.18, 0.58),
	"Crimson": Color(0.66, 0.16, 0.18),
	"Galilee Cyan": Color(0.16, 0.58, 0.66)
}

const WORLD_STAGES := {
	"ERA_TORAH": {
		"title": "I. WILDERNESS OF SINAI & TABERNACLE",
		"sky_top": Color(0.12, 0.18, 0.32), "sky_hor": Color(0.68, 0.48, 0.28), "sun_energy": 1.85,
		"ground": Color(0.48, 0.36, 0.22), "river": Color(0.08, 0.34, 0.52), "wall": Color(0.56, 0.48, 0.36), "accent": Color(0.92, 0.72, 0.24),
		"tabernacle_name": "Tabernacle of Meeting", "tabernacle_pos": Vector3(-11.0, 0.0, -6.0), "merchant_pos": Vector3(-14.0, 0.0, 6.5), "plot_pos": Vector3(-5.5, 0.0, 11.5),
		"npcs": [
			{"name": "Moses", "pos": Vector3(-8.5, 0.0, -1.5), "color": Color(0.76, 0.56, 0.18), "scenario": "GEN_001", "greeting": "Cross the stone bridge to battle raiders [Left-Click / F], loot chests [E], or study at the Lectern [L]!"},
			{"name": "Caleb", "pos": Vector3(-3.0, 0.0, 3.5), "color": Color(0.18, 0.52, 0.32), "scenario": "TOR_005", "greeting": "Watch the Anakite Giant across the river?raise Shield of Faith [Q] when he strikes!"}
		],
		"chests": [
			{"id": "CHEST_TOR_1", "pos": Vector3(-15.5, 0.0, 13.0), "timber": 140, "stone": 120, "oil": 2, "manna": 30, "relic": "Bronze Altar Ember"},
			{"id": "CHEST_TOR_2", "pos": Vector3(15.0, 0.0, -9.5), "timber": 160, "stone": 140, "oil": 1, "manna": 40, "relic": "Ark Cedar Plank"}
		],
		"enemies": [
			{"name": "Amalekite Raider", "archetype": "raider", "pos": Vector3(9.5, 0.0, -2.5), "hp": 95, "max_hp": 95, "atk": 13, "spd": 4.4, "armor": 0, "score": 35, "talents": 35},
			{"name": "Anakite Giant", "archetype": "giant", "pos": Vector3(14.0, 0.0, 6.0), "hp": 155, "max_hp": 155, "atk": 22, "spd": 2.6, "armor": 6, "score": 55, "talents": 55}
		]
	},
	"ERA_HISTORY": {
		"title": "II. FORTIFIED WALLS OF JERUSALEM & JORDAN RIVER",
		"sky_top": Color(0.10, 0.22, 0.42), "sky_hor": Color(0.52, 0.64, 0.72), "sun_energy": 1.95,
		"ground": Color(0.26, 0.34, 0.20), "river": Color(0.08, 0.38, 0.58), "wall": Color(0.62, 0.58, 0.48), "accent": Color(0.45, 0.86, 0.58),
		"tabernacle_name": "Shiloh Sanctuary", "tabernacle_pos": Vector3(-11.0, 0.0, -6.0), "merchant_pos": Vector3(-14.0, 0.0, 6.5), "plot_pos": Vector3(-5.5, 0.0, 11.5),
		"npcs": [{"name": "Joshua", "pos": Vector3(-8.5, 0.0, -1.5), "color": Color(0.68, 0.26, 0.18), "scenario": "HIS_001", "greeting": "Cross the Jordan stone bridge and breach the Jericho garrison!"}],
		"chests": [{"id": "CHEST_HIS_1", "pos": Vector3(-15.5, 0.0, 13.0), "timber": 140, "stone": 160, "oil": 2, "manna": 35, "relic": "Gilgal Memorial Stone"}],
		"enemies": [{"name": "Jericho Sentinel", "archetype": "sentinel", "pos": Vector3(10.0, 0.0, -2.0), "hp": 140, "max_hp": 140, "atk": 17, "spd": 3.0, "armor": 10, "score": 45, "talents": 45}]
	},
	"ERA_WISDOM": {
		"title": "III. MOUNT ZION & SOLOMON'S TEMPLE COURTS",
		"sky_top": Color(0.16, 0.12, 0.28), "sky_hor": Color(0.64, 0.44, 0.36), "sun_energy": 1.80,
		"ground": Color(0.36, 0.30, 0.26), "river": Color(0.10, 0.36, 0.56), "wall": Color(0.68, 0.62, 0.50), "accent": Color(0.95, 0.78, 0.28),
		"tabernacle_name": "Golden Temple Sanctuary", "tabernacle_pos": Vector3(-11.0, 0.0, -6.0), "merchant_pos": Vector3(-14.0, 0.0, 6.5), "plot_pos": Vector3(-5.5, 0.0, 11.5),
		"npcs": [{"name": "King David", "pos": Vector3(-8.5, 0.0, -1.5), "color": Color(0.76, 0.56, 0.16), "scenario": "WIS_001", "greeting": "Equip Breastplate Armor at the Armory [M] before facing the Philistine Champion!"}],
		"chests": [{"id": "CHEST_WIS_1", "pos": Vector3(-15.5, 0.0, 13.0), "timber": 200, "stone": 180, "oil": 3, "manna": 40, "relic": "Davidic Harp String"}],
		"enemies": [{"name": "Philistine Champion", "archetype": "giant", "pos": Vector3(12.0, 0.0, 1.5), "hp": 185, "max_hp": 185, "atk": 24, "spd": 2.9, "armor": 12, "score": 65, "talents": 75}]
	},
	"ERA_PROPHETS": {
		"title": "IV. PROPHETIC WATCHTOWER & SCROLL HALL",
		"sky_top": Color(0.18, 0.08, 0.10), "sky_hor": Color(0.68, 0.34, 0.22), "sun_energy": 1.75,
		"ground": Color(0.34, 0.24, 0.20), "river": Color(0.10, 0.34, 0.52), "wall": Color(0.54, 0.44, 0.36), "accent": Color(0.96, 0.52, 0.26),
		"tabernacle_name": "Altar of Burning Coals", "tabernacle_pos": Vector3(-11.0, 0.0, -6.0), "merchant_pos": Vector3(-14.0, 0.0, 6.5), "plot_pos": Vector3(-5.5, 0.0, 11.5),
		"npcs": [{"name": "Isaiah", "pos": Vector3(-8.5, 0.0, -1.5), "color": Color(0.74, 0.42, 0.18), "scenario": "PRO_001", "greeting": "No weapon formed against you shall prosper!"}],
		"chests": [{"id": "CHEST_PRO_1", "pos": Vector3(-15.5, 0.0, 13.0), "timber": 160, "stone": 190, "oil": 3, "manna": 45, "relic": "Prophetic Scroll Cylinder"}],
		"enemies": [{"name": "Babylonian Siege Warden", "archetype": "sentinel", "pos": Vector3(12.0, 0.0, 1.5), "hp": 190, "max_hp": 190, "atk": 23, "spd": 3.2, "armor": 14, "score": 70, "talents": 80}]
	},
	"ERA_GOSPELS": {
		"title": "V. CAPERNAUM VILLAGE & SEA OF GALILEE SHORE",
		"sky_top": Color(0.08, 0.24, 0.46), "sky_hor": Color(0.46, 0.68, 0.78), "sun_energy": 2.0,
		"ground": Color(0.22, 0.34, 0.22), "river": Color(0.06, 0.42, 0.64), "wall": Color(0.56, 0.52, 0.46), "accent": Color(0.38, 0.88, 0.94),
		"tabernacle_name": "House of Prayer Sanctuary", "tabernacle_pos": Vector3(-11.0, 0.0, -6.0), "merchant_pos": Vector3(-14.0, 0.0, 6.5), "plot_pos": Vector3(-5.5, 0.0, 11.5),
		"npcs": [{"name": "Peter", "pos": Vector3(-8.5, 0.0, -1.5), "color": Color(0.22, 0.58, 0.76), "scenario": "GOS_001", "greeting": "Cross the Galilee stone bridge and calm the Tempest Spirit!"}],
		"chests": [{"id": "CHEST_GOS_1", "pos": Vector3(-15.5, 0.0, 13.0), "timber": 190, "stone": 150, "oil": 3, "manna": 60, "relic": "Five Loaves Basket"}],
		"enemies": [{"name": "Tempest Shadow Spirit", "archetype": "spirit", "pos": Vector3(12.0, 0.0, 1.5), "hp": 195, "max_hp": 195, "atk": 25, "spd": 3.9, "armor": 8, "score": 80, "talents": 90}]
	},
	"ERA_EPISTLES": {
		"title": "VI. ANTIOCH WALLED CITY & UPPER ROOM",
		"sky_top": Color(0.12, 0.14, 0.30), "sky_hor": Color(0.54, 0.46, 0.58), "sun_energy": 1.85,
		"ground": Color(0.28, 0.26, 0.32), "river": Color(0.08, 0.38, 0.62), "wall": Color(0.60, 0.56, 0.50), "accent": Color(0.95, 0.80, 0.36),
		"tabernacle_name": "Upper Room Flame Sanctuary", "tabernacle_pos": Vector3(-11.0, 0.0, -6.0), "merchant_pos": Vector3(-14.0, 0.0, 6.5), "plot_pos": Vector3(-5.5, 0.0, 11.5),
		"npcs": [{"name": "Apostle Paul", "pos": Vector3(-8.5, 0.0, -1.5), "color": Color(0.78, 0.60, 0.22), "scenario": "EPI_001", "greeting": "Stand in the full Armor of God against Principalities Vanguard!"}],
		"chests": [{"id": "CHEST_EPI_1", "pos": Vector3(15.0, 0.0, 9.5), "timber": 250, "stone": 250, "oil": 4, "manna": 75, "relic": "Full Armor of God Seal"}],
		"enemies": [{"name": "Principalities Vanguard", "archetype": "spirit", "pos": Vector3(12.0, 0.0, 1.5), "hp": 230, "max_hp": 230, "atk": 28, "spd": 4.1, "armor": 14, "score": 110, "talents": 120}]
	}
}

var current_stage: String = "ERA_TORAH"
var player_pos_3d: Vector3 = Vector3(-6.5, 0.0, 1.5)
var cam_yaw: float = -1.35
var cam_pitch: float = -0.05
var mouse_captured: bool = false
var anim_time: float = 0.0
var portal_cooldown: float = 0.0

var has_full_game_unlock: bool = false
var has_academy_access: bool = false
var active_tier_label: String = "Free Prologue (Stage 1)"

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

var sword_level: int = 1
var armor_level: int = 1
var boots_level: int = 1

var land_deeds: Dictionary = {}
var house_stages: Dictionary = {}
var labor_credits: int = 0
var trivia_wins: int = 0
var battle_wins_count: int = 0

var shield_active: bool = false
var shield_timer: float = 0.0
var attack_swing_timer: float = 0.0
var attack_cooldown: float = 0.0
var in_tabernacle: bool = false

var banner_text: String = "PBR 3D ENGINE ACTIVE ? Click viewport for Mouse-Look ([ESC] unlock cursor) | [WASD] Move | [F / Left-Click] Sword | [Q] Shield"
var banner_timer: float = 10.0
var remote_pilgrims: Array = []
var local_pilgrim_name: String = "Pilgrim"
var local_robe_name: String = "Sapphire"

var viewport_container: SubViewportContainer
var sub_viewport: SubViewport
var world_root: Node3D
var player_head: Node3D
var camera_3d: Camera3D
var sword_pivot: Node3D
var sword_blade_mesh: MeshInstance3D
var shield_mesh: MeshInstance3D
var world_env: WorldEnvironment
var sky_mat: ProceduralSkyMaterial
var sun_light: DirectionalLight3D
var altar_light: OmniLight3D
var dynamic_group: Node3D
var hud_overlay: Control

var pbr_noise_tex: NoiseTexture2D
var pbr_normal_tex: NoiseTexture2D

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	_init_pbr_textures()
	_build_3d_viewport()
	set_stage("ERA_TORAH")
	set_process(true)

func _init_pbr_textures() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.045
	noise.fractal_octaves = 4

	pbr_noise_tex = NoiseTexture2D.new()
	pbr_noise_tex.width = 256
	pbr_noise_tex.height = 256
	pbr_noise_tex.seamless = true
	pbr_noise_tex.noise = noise

	pbr_normal_tex = NoiseTexture2D.new()
	pbr_normal_tex.width = 256
	pbr_normal_tex.height = 256
	pbr_normal_tex.seamless = true
	pbr_normal_tex.as_normal_map = true
	pbr_normal_tex.bump_strength = 6.5
	pbr_normal_tex.noise = noise

func _make_pbr_material(col: Color, rough: float = 0.82, metal: float = 0.05, uv_tile: float = 6.0, emissive: bool = false) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = col
	mat.albedo_texture = pbr_noise_tex
	mat.normal_enabled = true
	mat.normal_texture = pbr_normal_tex
	mat.normal_scale = 0.85
	mat.roughness = rough
	mat.metallic = metal
	mat.uv1_scale = Vector3(uv_tile, uv_tile, uv_tile)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if emissive:
		mat.emission_enabled = true
		mat.emission = col
		mat.emission_energy_multiplier = 0.85
	return mat

func _build_3d_viewport() -> void:
	viewport_container = SubViewportContainer.new()
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(viewport_container)

	sub_viewport = SubViewport.new()
	sub_viewport.own_world_3d = true
	sub_viewport.msaa_3d = Viewport.MSAA_4X
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(sub_viewport)

	world_root = Node3D.new()
	world_root.name = "World3DRoot"
	sub_viewport.add_child(world_root)

	# Realistic Procedural Atmospheric Sky + ACES Filmic Tone Mapping + Volumetric Haze
	sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.12, 0.18, 0.32)
	sky_mat.sky_horizon_color = Color(0.68, 0.48, 0.28)
	sky_mat.ground_bottom_color = Color(0.18, 0.14, 0.10)
	sky_mat.ground_horizon_color = Color(0.42, 0.32, 0.22)
	sky_mat.sun_angle_max = 28.0

	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat

	world_env = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.ssao_enabled = true
	env.glow_enabled = true
	env.glow_intensity = 0.45
	env.fog_enabled = true
	env.fog_light_color = Color(0.55, 0.42, 0.28)
	env.fog_density = 0.009
	world_env.environment = env
	world_root.add_child(world_env)

	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-42.0, 38.0, 0.0)
	sun_light.light_color = Color(1.0, 0.94, 0.84)
	sun_light.light_energy = 1.85
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_max_distance = 65.0
	world_root.add_child(sun_light)

	player_head = Node3D.new()
	player_head.position = Vector3(-6.5, 1.72, 1.5)
	world_root.add_child(player_head)

	camera_3d = Camera3D.new()
	camera_3d.fov = 72.0
	camera_3d.current = true
	player_head.add_child(camera_3d)

	# Sculpted Metallic First-Person Sword of the Spirit
	sword_pivot = Node3D.new()
	sword_pivot.position = Vector3(0.40, -0.34, -0.56)
	sword_pivot.rotation_degrees = Vector3(14.0, -16.0, 8.0)
	camera_3d.add_child(sword_pivot)

	var hilt_mi: MeshInstance3D = MeshInstance3D.new()
	var hilt_bm: BoxMesh = BoxMesh.new()
	hilt_bm.size = Vector3(0.18, 0.032, 0.036)
	hilt_mi.mesh = hilt_bm
	hilt_mi.material_override = _make_pbr_material(Color(0.88, 0.68, 0.18), 0.25, 0.90, 1.0)
	sword_pivot.add_child(hilt_mi)

	var grip_mi: MeshInstance3D = MeshInstance3D.new()
	var grip_cm: CylinderMesh = CylinderMesh.new()
	grip_cm.top_radius = 0.018
	grip_cm.bottom_radius = 0.020
	grip_cm.height = 0.16
	grip_mi.mesh = grip_cm
	grip_mi.position = Vector3(0.0, -0.09, 0.0)
	grip_mi.material_override = _make_pbr_material(Color(0.28, 0.16, 0.08), 0.85, 0.05, 1.0)
	sword_pivot.add_child(grip_mi)

	sword_blade_mesh = MeshInstance3D.new()
	var blade_pm: PrismMesh = PrismMesh.new()
	blade_pm.size = Vector3(0.055, 0.72, 0.014)
	sword_blade_mesh.mesh = blade_pm
	sword_blade_mesh.position = Vector3(0.0, 0.36, 0.0)
	var blade_mat: StandardMaterial3D = _make_pbr_material(Color(0.86, 0.90, 0.96), 0.18, 0.95, 2.0, true)
	blade_mat.emission = Color(0.22, 0.42, 0.72)
	blade_mat.emission_energy_multiplier = 0.30
	sword_blade_mesh.material_override = blade_mat
	sword_pivot.add_child(sword_blade_mesh)

	# Sculpted Metallic Shield of Faith
	shield_mesh = MeshInstance3D.new()
	var sh_cm: CylinderMesh = CylinderMesh.new()
	sh_cm.top_radius = 0.28
	sh_cm.bottom_radius = 0.26
	sh_cm.height = 0.035
	sh_cm.radial_segments = 24
	shield_mesh.mesh = sh_cm
	shield_mesh.position = Vector3(-0.46, -0.34, -0.50)
	shield_mesh.rotation_degrees = Vector3(82.0, 18.0, 0.0)
	shield_mesh.material_override = _make_pbr_material(Color(0.18, 0.46, 0.78), 0.28, 0.85, 2.0)
	camera_3d.add_child(shield_mesh)

	dynamic_group = Node3D.new()
	dynamic_group.name = "DynamicWorldEntities"
	world_root.add_child(dynamic_group)

	hud_overlay = Control.new()
	hud_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_overlay.draw.connect(_on_draw_hud_overlay)
	add_child(hud_overlay)

func _add_mesh(parent: Node3D, m: Mesh, pos: Vector3, rot_deg: Vector3, mat: StandardMaterial3D, cast_sh: bool = true) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = m
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_sh else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

func _make_sculpted_character_3d(parent: Node3D, pos: Vector3, tunic_col: Color, label_txt: String, scale_f: float = 1.0, is_enemy: bool = false) -> Node3D:
	var root: Node3D = Node3D.new()
	root.position = pos
	parent.add_child(root)

	var cloth_mat: StandardMaterial3D = _make_pbr_material(tunic_col, 0.88, 0.02, 2.0)
	var trim_mat: StandardMaterial3D = _make_pbr_material(Color(0.84, 0.64, 0.18) if not is_enemy else Color(0.55, 0.12, 0.12), 0.35, 0.75, 1.0)
	var skin_mat: StandardMaterial3D = _make_pbr_material(Color(0.76, 0.58, 0.44), 0.78, 0.0, 1.0)
	var boot_mat: StandardMaterial3D = _make_pbr_material(Color(0.24, 0.15, 0.09), 0.85, 0.05, 1.0)

	# Sculpted Cylindrical Legs & Boots
	var leg_m: CylinderMesh = CylinderMesh.new()
	leg_m.top_radius = 0.08 * scale_f
	leg_m.bottom_radius = 0.07 * scale_f
	leg_m.height = 0.75 * scale_f
	_add_mesh(root, leg_m, Vector3(-0.14 * scale_f, 0.38 * scale_f, 0.0), Vector3.ZERO, boot_mat)
	_add_mesh(root, leg_m, Vector3(0.14 * scale_f, 0.38 * scale_f, 0.0), Vector3.ZERO, boot_mat)

	# Tapered Flowing Tunic & Mantle Cloak
	var robe_m: CylinderMesh = CylinderMesh.new()
	robe_m.top_radius = 0.22 * scale_f
	robe_m.bottom_radius = 0.34 * scale_f
	robe_m.height = 0.92 * scale_f
	_add_mesh(root, robe_m, Vector3(0.0, 1.12 * scale_f, 0.0), Vector3.ZERO, cloth_mat)

	# Ornate Belt Ring
	var belt_m: CylinderMesh = CylinderMesh.new()
	belt_m.top_radius = 0.26 * scale_f
	belt_m.bottom_radius = 0.26 * scale_f
	belt_m.height = 0.09 * scale_f
	_add_mesh(root, belt_m, Vector3(0.0, 1.14 * scale_f, 0.0), Vector3.ZERO, trim_mat)

	# Sculpted Capsule Arms
	var arm_m: CapsuleMesh = CapsuleMesh.new()
	arm_m.radius = 0.07 * scale_f
	arm_m.height = 0.64 * scale_f
	_add_mesh(root, arm_m, Vector3(-0.31 * scale_f, 1.22 * scale_f, 0.0), Vector3(0.0, 0.0, 12.0), cloth_mat)
	_add_mesh(root, arm_m, Vector3(0.31 * scale_f, 1.22 * scale_f, 0.0), Vector3(0.0, 0.0, -12.0), cloth_mat)

	# Sculpted Sphere Head & Headpiece/Helm
	var head_m: SphereMesh = SphereMesh.new()
	head_m.radius = 0.17 * scale_f
	head_m.height = 0.36 * scale_f
	_add_mesh(root, head_m, Vector3(0.0, 1.76 * scale_f, 0.0), Vector3.ZERO, skin_mat)

	var helm_m: SphereMesh = SphereMesh.new()
	helm_m.radius = 0.185 * scale_f
	helm_m.height = 0.20 * scale_f
	var helm_mat: StandardMaterial3D = _make_pbr_material(Color(0.22, 0.24, 0.28), 0.30, 0.85, 1.0) if is_enemy else _make_pbr_material(Color(0.86, 0.78, 0.62), 0.85, 0.0, 1.0)
	_add_mesh(root, helm_m, Vector3(0.0, 1.86 * scale_f, 0.0), Vector3.ZERO, helm_mat)

	# Weapon or Shepherd Staff
	if is_enemy:
		var wpn_m: PrismMesh = PrismMesh.new()
		wpn_m.size = Vector3(0.08 * scale_f, 1.05 * scale_f, 0.03 * scale_f)
		_add_mesh(root, wpn_m, Vector3(0.38 * scale_f, 1.28 * scale_f, 0.28 * scale_f), Vector3(25.0, 0.0, 0.0), _make_pbr_material(Color(0.75, 0.18, 0.16), 0.25, 0.90, 1.0, true))
	else:
		var stf_m: CylinderMesh = CylinderMesh.new()
		stf_m.top_radius = 0.024 * scale_f
		stf_m.bottom_radius = 0.028 * scale_f
		stf_m.height = 2.05 * scale_f
		_add_mesh(root, stf_m, Vector3(0.40 * scale_f, 1.02 * scale_f, 0.14 * scale_f), Vector3(6.0, 0.0, 0.0), boot_mat)

	var lbl3d: Label3D = Label3D.new()
	lbl3d.text = label_txt
	lbl3d.position = Vector3(0.0, 2.28 * scale_f, 0.0)
	lbl3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl3d.font_size = 36
	lbl3d.outline_size = 8
	lbl3d.modulate = Color(1.0, 0.76, 0.70) if is_enemy else Color(1.0, 0.96, 0.84)
	root.add_child(lbl3d)
	return root

func _rebuild_3d_stage_scene() -> void:
	if dynamic_group == null:
		return
	for child in dynamic_group.get_children():
		child.queue_free()

	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	if sky_mat != null:
		sky_mat.sky_top_color = st["sky_top"]
		sky_mat.sky_horizon_color = st["sky_hor"]
	if sun_light != null:
		sun_light.light_energy = float(st.get("sun_energy", 1.85))
	if world_env != null and world_env.environment != null:
		world_env.environment.fog_light_color = st["sky_hor"]

	var ground_mat: StandardMaterial3D = _make_pbr_material(st["ground"], 0.92, 0.0, 18.0)
	var river_mat: StandardMaterial3D = _make_pbr_material(st["river"], 0.12, 0.35, 10.0, true)
	river_mat.emission = st["river"]
	river_mat.emission_energy_multiplier = 0.25
	var stone_mat: StandardMaterial3D = _make_pbr_material(st["wall"], 0.86, 0.04, 8.0)
	var plaster_mat: StandardMaterial3D = _make_pbr_material(Color(0.76, 0.68, 0.54), 0.90, 0.0, 4.0)
	var timber_mat: StandardMaterial3D = _make_pbr_material(Color(0.36, 0.22, 0.11), 0.84, 0.02, 4.0)
	var gold_mat: StandardMaterial3D = _make_pbr_material(st["accent"], 0.24, 0.88, 3.0, true)
	gold_mat.emission = st["accent"]
	gold_mat.emission_energy_multiplier = 0.22
	var foliage_mat: StandardMaterial3D = _make_pbr_material(Color(0.16, 0.38, 0.18), 0.88, 0.0, 3.0)

	# 1. Textured PBR Terrain Ground Plane
	var g_box: BoxMesh = BoxMesh.new()
	g_box.size = Vector3(48.0, 0.5, 40.0)
	_add_mesh(dynamic_group, g_box, Vector3(0.0, -0.25, 0.0), Vector3.ZERO, ground_mat, false)

	# 2. Reflective River & Sculpted Arched Stone Bridge
	var r_box: BoxMesh = BoxMesh.new()
	r_box.size = Vector3(3.8, 0.38, 40.0)
	_add_mesh(dynamic_group, r_box, Vector3(3.5, -0.17, 0.0), Vector3.ZERO, river_mat, false)

	var br_deck: BoxMesh = BoxMesh.new()
	br_deck.size = Vector3(5.2, 0.32, 3.6)
	_add_mesh(dynamic_group, br_deck, Vector3(3.5, 0.16, 0.0), Vector3.ZERO, stone_mat)
	var br_rail: BoxMesh = BoxMesh.new()
	br_rail.size = Vector3(5.2, 0.62, 0.28)
	_add_mesh(dynamic_group, br_rail, Vector3(3.5, 0.58, -1.68), Vector3.ZERO, stone_mat)
	_add_mesh(dynamic_group, br_rail, Vector3(3.5, 0.58, 1.68), Vector3.ZERO, stone_mat)

	# 3. Fortified Limestone Perimeter Walls, Crenellations & Cylindrical Watchtowers
	var wall_m: BoxMesh = BoxMesh.new()
	wall_m.size = Vector3(44.0, 3.4, 1.2)
	_add_mesh(dynamic_group, wall_m, Vector3(0.0, 1.7, -18.0), Vector3.ZERO, stone_mat)
	_add_mesh(dynamic_group, wall_m, Vector3(0.0, 1.7, 18.0), Vector3.ZERO, stone_mat)

	var tower_m: CylinderMesh = CylinderMesh.new()
	tower_m.top_radius = 1.45
	tower_m.bottom_radius = 1.65
	tower_m.height = 6.2
	tower_m.radial_segments = 16
	var brazier_m: SphereMesh = SphereMesh.new()
	brazier_m.radius = 0.42
	for wx in [-20.5, 20.5]:
		for wz in [-17.5, 17.5]:
			_add_mesh(dynamic_group, tower_m, Vector3(wx, 3.1, wz), Vector3.ZERO, stone_mat)
			_add_mesh(dynamic_group, brazier_m, Vector3(wx, 6.4, wz), Vector3.ZERO, _make_pbr_material(Color(1.0, 0.55, 0.14), 0.2, 0.0, 1.0, true), false)

	# 4. Biblical Limestone Houses & Sculpted Trees
	var house_body: BoxMesh = BoxMesh.new()
	house_body.size = Vector3(3.8, 2.9, 3.4)
	var house_trim: BoxMesh = BoxMesh.new()
	house_trim.size = Vector3(4.1, 0.28, 3.7)
	for h_pos in [Vector3(-16.5, 0.0, -11.5), Vector3(-5.0, 0.0, -12.0), Vector3(-16.5, 0.0, 1.0)]:
		var hp: Vector3 = h_pos
		_add_mesh(dynamic_group, house_body, hp + Vector3(0.0, 1.45, 0.0), Vector3.ZERO, plaster_mat)
		_add_mesh(dynamic_group, house_trim, hp + Vector3(0.0, 3.0, 0.0), Vector3.ZERO, timber_mat)

	var trunk_m: CylinderMesh = CylinderMesh.new()
	trunk_m.top_radius = 0.16
	trunk_m.bottom_radius = 0.24
	trunk_m.height = 3.0
	var canopy_m: SphereMesh = SphereMesh.new()
	canopy_m.radius = 1.35
	canopy_m.height = 1.6
	for t_pos in [Vector3(-17.5, 0.0, -4.0), Vector3(-2.0, 0.0, -8.5), Vector3(7.5, 0.0, -12.0), Vector3(16.5, 0.0, 12.5)]:
		var tp: Vector3 = t_pos
		_add_mesh(dynamic_group, trunk_m, tp + Vector3(0.0, 1.5, 0.0), Vector3.ZERO, timber_mat)
		_add_mesh(dynamic_group, canopy_m, tp + Vector3(0.0, 3.2, 0.0), Vector3.ZERO, foliage_mat)

	# 5. Sculpted Tabernacle / Sanctuary with Pitched Canopy, Pillars & Warm Fire PointLight3D
	var tab_p: Vector3 = st["tabernacle_pos"]
	var tab_walls: BoxMesh = BoxMesh.new()
	tab_walls.size = Vector3(5.0, 3.2, 4.4)
	_add_mesh(dynamic_group, tab_walls, tab_p + Vector3(0.0, 1.6, 0.0), Vector3.ZERO, timber_mat)
	var tab_roof: PrismMesh = PrismMesh.new()
	tab_roof.size = Vector3(5.6, 1.35, 5.0)
	_add_mesh(dynamic_group, tab_roof, tab_p + Vector3(0.0, 3.85, 0.0), Vector3.ZERO, gold_mat)

	var pillar_m: CylinderMesh = CylinderMesh.new()
	pillar_m.top_radius = 0.18
	pillar_m.bottom_radius = 0.20
	pillar_m.height = 3.4
	_add_mesh(dynamic_group, pillar_m, tab_p + Vector3(-2.2, 1.7, 2.3), Vector3.ZERO, gold_mat)
	_add_mesh(dynamic_group, pillar_m, tab_p + Vector3(2.2, 1.7, 2.3), Vector3.ZERO, gold_mat)

	altar_light = OmniLight3D.new()
	altar_light.position = tab_p + Vector3(0.0, 2.2, 2.8)
	altar_light.light_color = Color(1.0, 0.72, 0.28)
	altar_light.light_energy = 2.6
	altar_light.omni_range = 14.0
	dynamic_group.add_child(altar_light)

	var tab_lbl: Label3D = Label3D.new()
	tab_lbl.text = "%s
[SAFE ZONE: HEAL & TRADE (T)]" % str(st["tabernacle_name"])
	tab_lbl.position = tab_p + Vector3(0.0, 5.1, 0.0)
	tab_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tab_lbl.font_size = 42
	tab_lbl.outline_size = 8
	tab_lbl.modulate = Color(1.0, 0.94, 0.55)
	dynamic_group.add_child(tab_lbl)

	# Sacred Scroll Lectern [L]
	var lec_p: Vector3 = tab_p + Vector3(3.4, 0.0, 1.8)
	var lec_base: CylinderMesh = CylinderMesh.new()
	lec_base.top_radius = 0.22
	lec_base.bottom_radius = 0.32
	lec_base.height = 1.3
	_add_mesh(dynamic_group, lec_base, lec_p + Vector3(0.0, 0.65, 0.0), Vector3.ZERO, timber_mat)
	var scroll_m: BoxMesh = BoxMesh.new()
	scroll_m.size = Vector3(0.85, 0.14, 0.62)
	_add_mesh(dynamic_group, scroll_m, lec_p + Vector3(0.0, 1.36, 0.0), Vector3(18.0, 0.0, 0.0), _make_pbr_material(Color(0.96, 0.90, 0.72), 0.75, 0.0, 1.0, true))
	var lec_lbl: Label3D = Label3D.new()
	lec_lbl.text = "ACADEMY LECTERN [L]"
	lec_lbl.position = lec_p + Vector3(0.0, 2.0, 0.0)
	lec_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lec_lbl.font_size = 34
	lec_lbl.outline_size = 8
	lec_lbl.modulate = Color(0.48, 0.96, 0.72)
	dynamic_group.add_child(lec_lbl)

	# 6. Traveling Merchant Caravan [M]
	var m_p: Vector3 = st["merchant_pos"]
	var wagon_m: BoxMesh = BoxMesh.new()
	wagon_m.size = Vector3(2.8, 1.3, 1.8)
	_add_mesh(dynamic_group, wagon_m, m_p + Vector3(0.0, 0.85, 0.0), Vector3.ZERO, timber_mat)
	var canopy_roof: PrismMesh = PrismMesh.new()
	canopy_roof.size = Vector3(3.2, 0.85, 2.2)
	_add_mesh(dynamic_group, canopy_roof, m_p + Vector3(0.0, 1.95, 0.0), Vector3.ZERO, _make_pbr_material(Color(0.68, 0.18, 0.20), 0.85, 0.0, 2.0))
	_make_sculpted_character_3d(dynamic_group, m_p + Vector3(1.8, 0.0, 0.0), Color(0.76, 0.56, 0.18), "ARMORY MERCHANT [M]", 0.95, false)

	# 7. Homestead Land Plot & 4-Stage 3D House Construction [B]
	var hp: Vector3 = st["plot_pos"]
	var lvl: int = int(house_stages.get(current_stage, 0))
	var plot_pad: BoxMesh = BoxMesh.new()
	plot_pad.size = Vector3(4.6, 0.1, 4.2)
	_add_mesh(dynamic_group, plot_pad, hp + Vector3(0.0, 0.05, 0.0), Vector3.ZERO, gold_mat if bool(land_deeds.get(current_stage, false)) else stone_mat, false)
	if lvl >= 1:
		var f_m: BoxMesh = BoxMesh.new()
		f_m.size = Vector3(3.9, 0.5, 3.5)
		_add_mesh(dynamic_group, f_m, hp + Vector3(0.0, 0.25, 0.0), Vector3.ZERO, stone_mat)
	if lvl >= 2:
		var w_m: BoxMesh = BoxMesh.new()
		w_m.size = Vector3(3.7, 2.2, 3.3)
		_add_mesh(dynamic_group, w_m, hp + Vector3(0.0, 1.5, 0.0), Vector3.ZERO, plaster_mat)
	if lvl >= 3:
		var r_m: PrismMesh = PrismMesh.new()
		r_m.size = Vector3(4.2, 1.1, 3.8)
		_add_mesh(dynamic_group, r_m, hp + Vector3(0.0, 3.15, 0.0), Vector3.ZERO, timber_mat)
	if lvl >= 4:
		var cr_m: CylinderMesh = CylinderMesh.new()
		cr_m.top_radius = 0.6
		cr_m.bottom_radius = 0.8
		cr_m.height = 0.75
		_add_mesh(dynamic_group, cr_m, hp + Vector3(0.0, 4.0, 0.0), Vector3.ZERO, gold_mat)
	var plot_lbl: Label3D = Label3D.new()
	plot_lbl.text = "HOMESTEAD PLOT (STAGE %d/4) [B]" % lvl
	plot_lbl.position = hp + Vector3(0.0, 2.3 + float(lvl) * 0.7, 0.0)
	plot_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plot_lbl.font_size = 34
	plot_lbl.outline_size = 8
	plot_lbl.modulate = Color(1.0, 0.92, 0.48)
	dynamic_group.add_child(plot_lbl)

	# 8. Secret Chests [E]
	var chest_m: BoxMesh = BoxMesh.new()
	chest_m.size = Vector3(1.15, 0.78, 0.78)
	for c_item in st.get("chests", []):
		var ch: Dictionary = c_item
		var cpos: Vector3 = ch["pos"]
		var is_open: bool = opened_chests.has(str(ch["id"]))
		_add_mesh(dynamic_group, chest_m, cpos + Vector3(0.0, 0.39, 0.0), Vector3.ZERO, timber_mat if is_open else gold_mat)
		var clbl: Label3D = Label3D.new()
		clbl.text = "OPENED" if is_open else "SECRET CHEST [E]"
		clbl.position = cpos + Vector3(0.0, 1.35, 0.0)
		clbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		clbl.font_size = 32
		clbl.outline_size = 8
		clbl.modulate = Color(1.0, 0.92, 0.48) if not is_open else Color(0.65, 0.65, 0.68)
		dynamic_group.add_child(clbl)

	# 9. Sculpted Biblical NPCs
	for n_item in st.get("npcs", []):
		var npc: Dictionary = n_item
		_make_sculpted_character_3d(dynamic_group, npc["pos"], npc["color"], "%s [E]" % str(npc["name"]), 1.0, false)

	# 10. Glowing Stage Portals
	var portal_m: CylinderMesh = CylinderMesh.new()
	portal_m.top_radius = 1.4
	portal_m.bottom_radius = 1.4
	portal_m.height = 0.18
	_add_mesh(dynamic_group, portal_m, Vector3(-18.5, 1.9, 0.0), Vector3(0.0, 0.0, 90.0), gold_mat)
	var lp_lbl: Label3D = Label3D.new()
	lp_lbl.text = "< PREV ERA PORTAL"
	lp_lbl.position = Vector3(-18.5, 4.1, 0.0)
	lp_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lp_lbl.font_size = 38
	lp_lbl.outline_size = 8
	lp_lbl.modulate = st["accent"]
	dynamic_group.add_child(lp_lbl)

	_add_mesh(dynamic_group, portal_m, Vector3(18.5, 1.9, 0.0), Vector3(0.0, 0.0, 90.0), gold_mat)
	var rp_lbl: Label3D = Label3D.new()
	rp_lbl.text = "NEXT ERA PORTAL >"
	rp_lbl.position = Vector3(18.5, 4.1, 0.0)
	rp_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rp_lbl.font_size = 38
	rp_lbl.outline_size = 8
	rp_lbl.modulate = st["accent"]
	dynamic_group.add_child(rp_lbl)

	# 11. Sculpted 3D Enemies
	for i in range(stage_enemies.size()):
		var ed: Dictionary = stage_enemies[i]
		if int(ed.get("hp", 0)) > 0:
			var arch: String = str(ed.get("archetype", "raider"))
			var sc: float = 1.38 if arch == "giant" else 1.06
			var enode: Node3D = _make_sculpted_character_3d(dynamic_group, ed["pos3d"], Color(0.46, 0.10, 0.14), "%s (%d/%d HP)" % [str(ed["name"]), int(ed["hp"]), int(ed["max_hp"])], sc, true)
			ed["node3d"] = enode
			stage_enemies[i] = ed

func set_entitlement_tier(full_unlocked: bool, academy_unlocked: bool, label_txt: String) -> void:
	has_full_game_unlock = full_unlocked
	has_academy_access = academy_unlocked
	active_tier_label = label_txt
	if hud_overlay != null:
		hud_overlay.queue_redraw()

func set_stage(era_id: String) -> void:
	if era_id != "ERA_TORAH" and not has_full_game_unlock:
		portal_cooldown = 1.0
		_announce("STAGE LOCKED: Unlock Full Covenant Pilgrim Edition ($4.99) or Academy ($14.99/mo) [L] to explore Stages 2-6!", 6.5)
		emit_signal("upgrade_modal_requested", "Unlock All 6 Biblical Eras, Homestead Construction & Lv.5 Armory ($4.99)")
		return
	if WORLD_STAGES.has(era_id):
		current_stage = era_id
		player_pos_3d = Vector3(-6.5, 0.0, 1.5)
		cam_yaw = -1.35
		portal_cooldown = 1.0
		stage_enemies.clear()
		var st: Dictionary = WORLD_STAGES[era_id]
		for e_item in st.get("enemies", []):
			var ed: Dictionary = e_item
			var copy_e: Dictionary = ed.duplicate(true)
			copy_e["pos3d"] = copy_e["pos"]
			copy_e["atk_timer"] = 1.1
			stage_enemies.append(copy_e)
		_rebuild_3d_stage_scene()
		_announce("Entered %s" % str(st["title"]), 5.0)

func set_local_pilgrim_name(pname: String) -> void:
	var clean: String = pname.strip_edges()
	local_pilgrim_name = clean if clean != "" else "Pilgrim"

func set_local_robe_color(rname: String) -> void:
	if ROBE_PALETTE.has(rname):
		local_robe_name = rname

func add_trivia_talents(amount: int, source_label: String) -> void:
	earned_talents += amount
	trivia_wins += 1
	labor_credits += 1
	emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	_announce("TRIVIA MASTERED! +%d Talents & +1 Builder Credit earned! (Credits: %d | Talents: %d)" % [amount, labor_credits, earned_talents], 6.5)

func show_coop_blessing(text: String) -> void:
	_announce(text, 7.5)

func set_remote_pilgrims(pilgrims: Array) -> void:
	remote_pilgrims = pilgrims

func _announce(msg: String, duration: float = 5.5) -> void:
	banner_text = msg
	banner_timer = duration
	if hud_overlay != null:
		hud_overlay.queue_redraw()

func get_current_move_speed() -> float:
	return 6.8 + float(boots_level - 1) * 1.1

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
		if sword_blade_mesh != null:
			sword_blade_mesh.scale = Vector3(1.0 + float(sword_level) * 0.12, 1.0 + float(sword_level) * 0.08, 1.0)
		_announce("ARMORY UPGRADE: Sword forged to Lv.%d (-%d Talents | %d DMG)!" % [sword_level, cost, get_sword_damage()], 6.0)
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	else:
		_announce("Need %d Earned Talents for Sword Lv.%d (have %d)." % [cost, sword_level + 1, earned_talents], 4.5)

func buy_armor_upgrade() -> void:
	if armor_level >= 5:
		_announce("BREASTPLATE ARMOR IS ALREADY MAXED AT LV.5!", 4.0)
		return
	var cost: int = get_upgrade_cost(armor_level, 55)
	if earned_talents >= cost:
		earned_talents -= cost
		armor_level += 1
		max_spirit_hp += 15
		spirit_hp = mini(max_spirit_hp, spirit_hp + 15)
		_announce("ARMORY UPGRADE: Breastplate Lv.%d (-%d Talents | +15 Max HP)!" % [armor_level, cost], 6.0)
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	else:
		_announce("Need %d Earned Talents for Breastplate Lv.%d (have %d)." % [cost, armor_level + 1, earned_talents], 4.5)

func buy_boots_upgrade() -> void:
	if boots_level >= 5:
		_announce("SANDALS OF PEACE ARE ALREADY MAXED AT LV.5!", 4.0)
		return
	var cost: int = get_upgrade_cost(boots_level, 50)
	if earned_talents >= cost:
		earned_talents -= cost
		boots_level += 1
		_announce("ARMORY UPGRADE: Gospel Speed Boots Lv.%d (-%d Talents)!" % [boots_level, cost], 6.0)
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
	else:
		_announce("Need %d Earned Talents for Speed Boots Lv.%d (have %d)." % [cost, boots_level + 1, earned_talents], 4.5)

func _set_mouse_capture(enable: bool) -> void:
	mouse_captured = enable
	if enable:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		grab_focus()
		if not mouse_captured:
			_set_mouse_capture(true)
			_announce("Mouse-Look Locked! Move mouse to look around, [WASD] to walk, [ESC] to free cursor.", 3.5)
			accept_event()
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			_perform_sword_strike()
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_raise_shield_of_faith()
			accept_event()

func _input(event: InputEvent) -> void:
	if mouse_captured and event is InputEventMouseMotion:
		cam_yaw -= event.relative.x * 0.0032
		cam_pitch = clampf(cam_pitch - event.relative.y * 0.0028, -1.15, 1.15)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_TAB:
			if mouse_captured:
				_set_mouse_capture(false)
				_announce("Cursor Unlocked ? Click HUD buttons or click 3D viewport to resume Mouse-Look.", 3.5)
				get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_interact_nearest_3d()
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
		elif event.keycode == KEY_B:
			acquire_or_build_homestead()
			accept_event()
		elif event.keycode == KEY_M:
			_set_mouse_capture(false)
			emit_signal("armory_toggled")
			accept_event()
		elif event.keycode == KEY_L:
			_set_mouse_capture(false)
			emit_signal("academy_toggled")
			accept_event()
		elif event.keycode == KEY_Y:
			_set_mouse_capture(false)
			emit_signal("trial_requested")
			accept_event()

func _interact_nearest_3d() -> void:
	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	for c_item in st.get("chests", []):
		var ch: Dictionary = c_item
		if player_pos_3d.distance_to(ch["pos"]) <= 3.6:
			_open_secret_chest(ch)
			return
	for n_item in st.get("npcs", []):
		var npc: Dictionary = n_item
		if player_pos_3d.distance_to(npc["pos"]) <= 3.8:
			_set_mouse_capture(false)
			emit_signal("npc_dialogue_triggered", str(npc["name"]), current_stage, str(npc["scenario"]), str(npc["greeting"]))
			_announce("%s: \"%s\"" % [str(npc["name"]), str(npc["greeting"])], 7.0)
			return
	var lec_p: Vector3 = st["tabernacle_pos"] + Vector3(3.4, 0.0, 1.8)
	if player_pos_3d.distance_to(lec_p) <= 3.5:
		_set_mouse_capture(false)
		emit_signal("academy_toggled")
		return
	if player_pos_3d.distance_to(st["merchant_pos"]) <= 3.8:
		_set_mouse_capture(false)
		emit_signal("armory_toggled")
		return
	if player_pos_3d.distance_to(st["plot_pos"]) <= 4.2:
		acquire_or_build_homestead()
		return

func _open_secret_chest(ch: Dictionary) -> void:
	var cid: String = str(ch["id"])
	if opened_chests.has(cid):
		_announce("Secret Chest already gathered (%s)." % str(ch["relic"]), 3.0)
		return
	opened_chests[cid] = true
	timber_stock += int(ch["timber"])
	stone_stock += int(ch["stone"])
	anointing_oil += int(ch["oil"])
	manna_rations += int(ch["manna"])
	var rel: String = str(ch["relic"])
	if not relics_found.has(rel):
		relics_found.append(rel)
	_rebuild_3d_stage_scene()
	var summary: String = "3D SECRET CHEST LOOTED! +%d Timber, +%d Stone, +%d Oil, +%d Manna & [%s]" % [int(ch["timber"]), int(ch["stone"]), int(ch["oil"]), int(ch["manna"]), rel]
	_announce(summary, 6.5)
	emit_signal("chest_looted", cid, summary)

func trade_gathered_supplies() -> void:
	if timber_stock >= 100 and stone_stock >= 100:
		timber_stock -= 100
		stone_stock -= 100
		earned_talents += 25
		emit_signal("armory_updated", earned_talents, sword_level, armor_level, boots_level)
		_announce("SUPPLY TRADE COMPLETED: -100 Timber & -100 Stone -> +25 Talents! (Total: %d)" % earned_talents, 5.5)
		emit_signal("supplies_traded", 25)
	else:
		_announce("Need 100 Timber & 100 Stone to trade! Open 3D Secret Chests [E].", 4.5)

func acquire_or_build_homestead() -> void:
	if not has_full_game_unlock:
		_set_mouse_capture(false)
		_announce("HOMESTEAD BUILDING LOCKED: Unlock Full Covenant Pilgrim Edition ($4.99) [L]!", 6.5)
		emit_signal("upgrade_modal_requested", "Unlock Land Deeds & 3D Homestead Building ($4.99)")
		return
	var has_deed: bool = bool(land_deeds.get(current_stage, false))
	var cur_lvl: int = int(house_stages.get(current_stage, 0))
	if not has_deed:
		if earned_talents >= 120:
			earned_talents -= 120
			land_deeds[current_stage] = true
			_rebuild_3d_stage_scene()
			_announce("3D LAND DEED PURCHASED (-120 Talents)! Press [B] with Stone & Task Credits to build Foundation!", 6.0)
		elif battle_wins_count >= 1 and trivia_wins >= 1:
			land_deeds[current_stage] = true
			_rebuild_3d_stage_scene()
			_announce("3D LAND DEED EARNED BY LABOR! Press [B] to lay your 3D Stone Foundation!", 6.0)
		else:
			_announce("LAND LOCKED: Need 120 Talents (have %d) OR 1 Battle Win (%d/1) + 1 Trivia Win (%d/1)!" % [earned_talents, battle_wins_count, trivia_wins], 6.0)
		return
	if cur_lvl >= 4:
		_announce("3D COVENANT MANOR COMPLETE (4/4)!", 5.0)
		return
	if labor_credits < 1:
		_announce("Need 1 Builder Task Credit from Battle [F] or Scripture Trivia [Y] to construct next 3D stage!", 5.5)
		return
	if cur_lvl == 0 and stone_stock >= 80:
		stone_stock -= 80
		labor_credits -= 1
		house_stages[current_stage] = 1
		_rebuild_3d_stage_scene()
		_announce("3D HOUSE STAGE 1/4 BUILT: Hewn Stone Foundation laid in 3D!", 6.0)
	elif cur_lvl == 1 and timber_stock >= 100 and stone_stock >= 60:
		timber_stock -= 100
		stone_stock -= 60
		labor_credits -= 1
		house_stages[current_stage] = 2
		_rebuild_3d_stage_scene()
		_announce("3D HOUSE STAGE 2/4 BUILT: Cedar Timber & Limestone Walls raised in 3D!", 6.0)
	elif cur_lvl == 2 and timber_stock >= 120 and stone_stock >= 80:
		timber_stock -= 120
		stone_stock -= 80
		labor_credits -= 1
		house_stages[current_stage] = 3
		_rebuild_3d_stage_scene()
		_announce("3D HOUSE STAGE 3/4 BUILT: Roof Beams & Courtyard completed in 3D!", 6.0)
	elif cur_lvl == 3 and timber_stock >= 100 and stone_stock >= 100 and earned_talents >= 50:
		timber_stock -= 100
		stone_stock -= 100
		earned_talents -= 50
		labor_credits -= 1
		house_stages[current_stage] = 4
		max_spirit_hp += 25
		spirit_hp = max_spirit_hp
		_rebuild_3d_stage_scene()
		_announce("3D HOUSE STAGE 4/4 COMPLETE: CONSECRATED 3D COVENANT MANOR (+25 Max HP)!", 7.5)
	else:
		_announce("Gather more Timber & Stone from Secret Chests [E] for House Stage %d!" % (cur_lvl + 1), 5.0)

func _consume_manna_ration() -> void:
	if manna_rations >= 15 and spirit_hp < max_spirit_hp:
		manna_rations -= 15
		spirit_hp = mini(max_spirit_hp, spirit_hp + 35)
		_announce("Ate Manna Rations (-15 Manna) -> Health Restored to %d/%d!" % [spirit_hp, max_spirit_hp], 3.5)
	else:
		_announce("Visit the 3D Tabernacle or loot Secret Chests for Manna!", 3.0)

func _raise_shield_of_faith() -> void:
	shield_active = true
	shield_timer = 4.5
	_announce("SHIELD OF FAITH RAISED IN FIRST-PERSON! Incoming damage reduced by 78%!", 3.0)

func _perform_sword_strike() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.40
	attack_swing_timer = 0.28
	var best_idx: int = -1
	var best_dist: float = 4.2
	for i in range(stage_enemies.size()):
		var ed: Dictionary = stage_enemies[i]
		if int(ed.get("hp", 0)) > 0:
			var d: float = player_pos_3d.distance_to(ed["pos3d"])
			if d <= best_dist:
				best_dist = d
				best_idx = i
	if best_idx != -1:
		var ed: Dictionary = stage_enemies[best_idx]
		var dmg: int = maxi(14, get_sword_damage() - int(ed.get("armor", 0)))
		var new_hp: int = maxi(0, int(ed["hp"]) - dmg)
		ed["hp"] = new_hp
		var push: Vector3 = (ed["pos3d"] - player_pos_3d).normalized() * 1.1
		push.y = 0.0
		ed["pos3d"] = ed["pos3d"] + push
		stage_enemies[best_idx] = ed
		if new_hp <= 0:
			var sc: int = int(ed.get("score", 40))
			var t_won: int = int(ed.get("talents", 35))
			earned_talents += t_won
			manna_rations += 20
			timber_stock += 50
			battle_wins_count += 1
			labor_credits += 1
			_rebuild_3d_stage_scene()
			_set_mouse_capture(false)
			_announce("3D BATTLE VICTORY! Defeated %s (+%d Talents, +1 Builder Credit) -> TRIVIA UNLOCKED!" % [str(ed["name"]), t_won], 7.0)
			emit_signal("battle_won", str(ed["name"]), sc, t_won)
			emit_signal("trial_requested")
		else:
			_rebuild_3d_stage_scene()
			_announce("SWORD OF THE SPIRIT! Struck %s for %d DMG (%d/%d HP left)" % [str(ed["name"]), dmg, new_hp, int(ed["max_hp"])], 2.5)
	else:
		_announce("Sword of the Spirit swung! Close distance with an enemy across the bridge.", 2.0)

func _apply_damage_to_player(raw_dmg: int, attacker_label: String, tab_pos: Vector3) -> void:
	var armor_mit: int = maxi(3, raw_dmg - get_player_armor())
	var final_dmg: int = maxi(2, int(armor_mit * 0.22)) if shield_active else armor_mit
	spirit_hp = maxi(0, spirit_hp - final_dmg)
	if shield_active:
		_announce("SHIELD OF FAITH BLOCKED %s! (-%d HP)" % [attacker_label, final_dmg], 2.5)
	else:
		_announce("%s hit you for -%d HP! Raise Shield [Q] or retreat to the 3D Tabernacle!" % [attacker_label, final_dmg], 3.2)
	if spirit_hp <= 0:
		spirit_hp = 55
		player_pos_3d = tab_pos + Vector3(0.0, 0.0, 3.2)
		_announce("RETREATED TO 3D TABERNACLE SANCTUARY ? Health Restored to 55/%d!" % max_spirit_hp, 5.0)

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

	if altar_light != null:
		altar_light.light_energy = 2.4 + sin(anim_time * 9.0) * 0.45

	if player_head != null and camera_3d != null:
		player_head.rotation.y = cam_yaw
		camera_3d.rotation.x = cam_pitch

	if sword_pivot != null:
		if attack_swing_timer > 0.0:
			var prog: float = 1.0 - (attack_swing_timer / 0.28)
			sword_pivot.rotation_degrees = Vector3(14.0 - prog * 68.0, -16.0 + prog * 45.0, 8.0 + prog * 35.0)
		else:
			sword_pivot.rotation_degrees = Vector3(14.0 + sin(anim_time * 3.0) * 1.5, -16.0, 8.0)

	if shield_mesh != null:
		if shield_active:
			shield_mesh.position = Vector3(-0.18, -0.14, -0.44)
		else:
			shield_mesh.position = Vector3(-0.46, -0.34, -0.50)

	var forward: Vector3 = Vector3(-sin(cam_yaw), 0.0, -cos(cam_yaw))
	var right: Vector3 = Vector3(cos(cam_yaw), 0.0, -sin(cam_yaw))
	var move_dir: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_dir += forward
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_dir -= forward
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_dir += right
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_dir -= right

	if move_dir.length() > 0.01:
		var spd: float = get_current_move_speed()
		player_pos_3d += move_dir.normalized() * spd * delta
		player_pos_3d.x = clampf(player_pos_3d.x, -18.8, 18.8)
		player_pos_3d.z = clampf(player_pos_3d.z, -15.2, 15.2)
		var bob: float = sin(anim_time * 11.0) * 0.045
		player_head.position = Vector3(player_pos_3d.x, 1.72 + bob, player_pos_3d.z)
		emit_signal("player_moved", current_stage, (player_pos_3d.x + 20.0) * 20.0, (player_pos_3d.z + 18.0) * 16.0)
	else:
		player_head.position = Vector3(player_pos_3d.x, 1.72, player_pos_3d.z)

	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var tab_pos: Vector3 = st["tabernacle_pos"]
	var was_tab: bool = in_tabernacle
	in_tabernacle = player_pos_3d.distance_to(tab_pos) <= 4.2
	if in_tabernacle and not was_tab:
		spirit_hp = max_spirit_hp
		_announce("%s: Health Fully Restored to %d/%d!" % [str(st["tabernacle_name"]), spirit_hp, max_spirit_hp], 4.5)

	for i in range(stage_enemies.size()):
		var ed: Dictionary = stage_enemies[i]
		if int(ed.get("hp", 0)) <= 0:
			continue
		var epos: Vector3 = ed["pos3d"]
		var dist_p: float = epos.distance_to(player_pos_3d)
		if dist_p <= 13.5 and not in_tabernacle:
			var to_p: Vector3 = (player_pos_3d - epos).normalized()
			to_p.y = 0.0
			if dist_p > 2.4:
				epos += to_p * float(ed.get("spd", 3.2)) * delta
				ed["pos3d"] = epos
				if ed.has("node3d") and is_instance_valid(ed["node3d"]):
					var n3d: Node3D = ed["node3d"]
					n3d.position = epos
					n3d.look_at(Vector3(player_pos_3d.x, epos.y, player_pos_3d.z), Vector3.UP)
			var atk_t: float = float(ed.get("atk_timer", 1.2)) - delta
			if atk_t <= 0.0 and dist_p <= 3.0:
				atk_t = 1.65
				_apply_damage_to_player(int(ed.get("atk", 15)), str(ed["name"]), tab_pos)
			ed["atk_timer"] = atk_t
		stage_enemies[i] = ed

	if portal_cooldown <= 0.0:
		var idx: int = ERA_ORDER.find(current_stage)
		if player_pos_3d.distance_to(Vector3(18.5, 0.0, 0.0)) <= 2.6:
			var next_era: String = ERA_ORDER[(idx + 1) % ERA_ORDER.size()]
			set_stage(next_era)
			emit_signal("stage_portal_entered", next_era)
		elif player_pos_3d.distance_to(Vector3(-18.5, 0.0, 0.0)) <= 2.6:
			var prev_era: String = ERA_ORDER[(idx - 1 + ERA_ORDER.size()) % ERA_ORDER.size()]
			set_stage(prev_era)
			emit_signal("stage_portal_entered", prev_era)

	if hud_overlay != null:
		hud_overlay.queue_redraw()

func _on_draw_hud_overlay() -> void:
	var w: float = size.x
	var h: float = size.y
	var font: Font = ThemeDB.fallback_font
	if font == null or w < 40.0:
		return
	var st: Dictionary = WORLD_STAGES.get(current_stage, WORLD_STAGES["ERA_TORAH"])
	var acc: Color = st["accent"]

	hud_overlay.draw_rect(Rect2(12.0, 10.0, w - 24.0, 52.0), Color(0.04, 0.04, 0.07, 0.84))
	hud_overlay.draw_string(font, Vector2(22.0, 30.0), "%s  |  TALENTS: %d  |  HP: %d/%d  |  GEAR: Sword Lv.%d / Armor Lv.%d / Boots Lv.%d  |  HOUSE: %d/4" % [str(st["title"]), earned_talents, spirit_hp, max_spirit_hp, sword_level, armor_level, boots_level, int(house_stages.get(current_stage, 0))], HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 13, acc)
	hud_overlay.draw_string(font, Vector2(22.0, 50.0), "[Click Viewport] Mouse-Look ([ESC] Free Cursor)  |  [WASD] Walk  |  [F / Left-Click] Sword  |  [Q] Shield  |  [E] Interact  |  [L] Academy", HORIZONTAL_ALIGNMENT_LEFT, int(w - 44.0), 11, Color(0.88, 0.90, 0.95))

	var cx: float = w * 0.5
	var cy: float = h * 0.5
	hud_overlay.draw_arc(Vector2(cx, cy), 6.0, 0.0, TAU, 16, Color(1.0, 0.94, 0.65, 0.80), 1.5)
	hud_overlay.draw_circle(Vector2(cx, cy), 2.0, acc)

	if banner_timer > 0.0 and banner_text != "":
		hud_overlay.draw_rect(Rect2(16.0, h - 98.0, w - 32.0, 28.0), Color(0.05, 0.04, 0.08, 0.90))
		hud_overlay.draw_string(font, Vector2(24.0, h - 79.0), banner_text, HORIZONTAL_ALIGNMENT_LEFT, int(w - 48.0), 13, Color(1.0, 0.94, 0.58))
