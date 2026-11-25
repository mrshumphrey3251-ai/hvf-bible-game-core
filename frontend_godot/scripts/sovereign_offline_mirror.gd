extends RefCounted
class_name SovereignOfflineMirror

const SAVE_PATH := "user://player_state.json"
const OFFLINE_SCENARIO_TITLES := {
	"GEN_001": "Covenant Call & Stewardship of Creation",
	"TOR_002": "Jethro's Counsel at Mount Sinai (Exodus 18)",
	"TOR_003": "The Year of Jubilee & Land Restoration (Leviticus 25)",
	"HIS_001": "Crossing the Jordan & Covenant Memorial Stones",
	"HIS_002": "Gideon's 300 at the Spring of Harod (Judges 7)",
	"HIS_003": "Nehemiah's Wall Builders with Trowel & Sword (Nehemiah 4)",
	"WIS_001": "Solomon's Petition for an Understanding Heart",
	"WIS_002": "Storehouse Preparation of the Ant (Proverbs 6 & 30)",
	"PRO_001": "Elijah's Stand & Prophetic Remnant Fidelity",
	"PRO_002": "King Josiah & the Discovered Book of the Law (2 Kings 22)",
	"GOS_001": "Sermon on the Mount & Kingdom Beatitudes",
	"GOS_002": "House Built on the Rock vs. Shifting Sand (Matthew 7:24-27)",
	"EPI_001": "Apostolic Council & Unity of the Church",
	"TOR_004": "Bezalel & Oholiab ? Spirit-Filled Tabernacle Craftsmanship (Exodus 31)",
	"HIS_004": "Esther's Royal Petition Before King Ahasuerus (Esther 4-5)",
	"WIS_003": "Job's Unshakable Integrity Under Severe Trial (Job 1-2 & 42)",
	"PRO_003": "Daniel & the Three Hebrews in Babylon (Daniel 1 & 3)",
	"GOS_003": "The Great Commission & Galilean Sending (Matthew 28:18-20)",
	"EPI_002": "The Berean Standard of Daily Scripture Verification (Acts 17:11)",
	"EPI_003": "Overcoming by the Blood of the Lamb & Word of Testimony (Revelation 12:11)"
}

const ERAS := [
	"ERA_TORAH", "ERA_HISTORY", "ERA_WISDOM",
	"ERA_PROPHETS", "ERA_GOSPELS", "ERA_EPISTLES"
]

const GENERALS := {
	"MOSES": {"name": "Moses, Shepherd & Lawgiver", "preferred_slot": "sanctuary_keep", "power": 320},
	"JOSHUA": {"name": "Joshua, Commander of the Hosts", "preferred_slot": "campaign_vanguard", "power": 380},
	"DEBORAH": {"name": "Deborah, Prophetess & Judge", "preferred_slot": "watchtower", "power": 310},
	"DAVID": {"name": "David, Sovereign King of Zion", "preferred_slot": "rampart_walls", "power": 360},
	"PAUL": {"name": "Paul, Apostle to the Nations", "preferred_slot": "scriptorium", "power": 340}
}

const CHAPTERS := [
	{"chapter_id": "CH_01_MAMRE", "era": "ERA_TORAH", "title": "Encampment at the Oaks of Mamre", "required_power": 1000, "rewards": {"provision": 250, "timber": 200, "stone": 150, "talents": 60}},
	{"chapter_id": "CH_02_JERICHO", "era": "ERA_HISTORY", "title": "Siege & Trumpet March of Jericho", "required_power": 1450, "rewards": {"provision": 350, "timber": 300, "stone": 350, "talents": 100}},
	{"chapter_id": "CH_03_ZION_COURT", "era": "ERA_WISDOM", "title": "Royal Court & Cedars of Jerusalem", "required_power": 2000, "rewards": {"provision": 450, "timber": 500, "stone": 450, "talents": 160}},
	{"chapter_id": "CH_04_CARMEL", "era": "ERA_PROPHETS", "title": "Altar Showdown on Mount Carmel", "required_power": 2700, "rewards": {"provision": 600, "timber": 550, "stone": 600, "talents": 220}},
	{"chapter_id": "CH_05_CAPERNAUM", "era": "ERA_GOSPELS", "title": "Galilee Harbor & Kingdom Proclamation", "required_power": 3500, "rewards": {"provision": 800, "timber": 700, "stone": 750, "talents": 300}},
	{"chapter_id": "CH_06_ANTIOCH_MISSION", "era": "ERA_EPISTLES", "title": "Antioch Sending & Mediterranean Network", "required_power": 4500, "rewards": {"provision": 1100, "timber": 950, "stone": 1000, "talents": 450}}
]

var state: Dictionary = {}
var stronghold: Dictionary = {}
var assignments: Dictionary = {}
var trial_cursor: int = 0

func _init() -> void:
	_reset_defaults()
	load_sealed_save()

func _reset_defaults() -> void:
	state = {
		"current_era": "ERA_TORAH",
		"total_score": 0,
		"active_flags": [],
		"bloodline": {
			"epoch_number": 1,
			"generation_number": 1,
			"current_leader": "Adam_Line_01",
			"designated_heir": "Seth_Line_02",
			"current_era": "ERA_TORAH",
			"legacy_traits": []
		}
	}
	stronghold = {
		"stronghold_name": "Covenant Citadel of Zion",
		"resources": {"provision": 500, "timber": 400, "stone": 400, "talents": 150},
		"buildings": {
			"sanctuary_keep": {"name": "Sanctuary Keep", "level": 1, "base_power": 250},
			"scriptorium": {"name": "Royal Scriptorium", "level": 1, "base_power": 180},
			"granary": {"name": "Covenant Granary", "level": 1, "base_power": 160},
			"watchtower": {"name": "Prophetic Watchtower", "level": 1, "base_power": 190},
			"rampart_walls": {"name": "Sovereign Rampart Walls", "level": 1, "base_power": 220}
		},
		"conquered_chapters": []
	}
	assignments = {}
	state["sha256_seal"] = _compute_sha256(JSON.stringify(state))

func _compute_sha256(text: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(text.to_utf8_buffer())
	return ctx.finish().hex_encode()

func _calc_base_power() -> int:
	var pwr := 0
	var blds: Dictionary = stronghold.get("buildings", {})
	for k in blds.keys():
		pwr += int(blds[k].get("base_power", 100)) * int(blds[k].get("level", 1))
	pwr += stronghold.get("conquered_chapters", []).size() * 300
	return pwr

func _calc_cmd_bonus() -> int:
	var bonus := 0
	for slot in assignments.keys():
		var gid: String = str(assignments[slot])
		if GENERALS.has(gid):
			var p := int(GENERALS[gid]["power"])
			if slot == str(GENERALS[gid]["preferred_slot"]):
				p = int(round(p * 1.25))
			bonus += p
	return bonus

func _stronghold_snapshot() -> Dictionary:
	var base_pwr := _calc_base_power()
	var cmd_bonus := _calc_cmd_bonus()
	return {
		"stronghold_name": stronghold.get("stronghold_name", "Covenant Citadel of Zion"),
		"dynasty_power": base_pwr,
		"commander_power_bonus": cmd_bonus,
		"total_combined_power": base_pwr + cmd_bonus,
		"resources": stronghold.get("resources", {}).duplicate(true),
		"buildings": stronghold.get("buildings", {}).duplicate(true),
		"conquered_chapters": stronghold.get("conquered_chapters", []).duplicate(),
		"available_chapters": CHAPTERS
	}

func _generals_snapshot() -> Dictionary:
	return {
		"assignments": assignments.duplicate(),
		"total_command_power_bonus": _calc_cmd_bonus()
	}

func save_sealed_save() -> void:
	var payload := {"state": state, "stronghold": stronghold, "assignments": assignments}
	var raw_json := JSON.stringify(payload)
	var sig := _compute_sha256(raw_json)
	state["sha256_seal"] = sig
	var envelope := {"data": payload, "signature": sig}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(envelope))
		f.close()

func load_sealed_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return false
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("data") or not parsed.has("signature"):
		return false
	var data_dict: Dictionary = parsed["data"]
	var expected_sig := _compute_sha256(JSON.stringify(data_dict))
	if expected_sig != str(parsed["signature"]):
		return false
	if data_dict.has("state"):
		state = data_dict["state"]
	if data_dict.has("stronghold"):
		stronghold = data_dict["stronghold"]
	if data_dict.has("assignments"):
		assignments = data_dict["assignments"]
	return true

func dispatch(req: Dictionary) -> Dictionary:
	var action := str(req.get("action", "")).to_upper()
	if action == "HANDSHAKE":
		return {"status": "CONNECTED", "auth": "OFFLINE_MIRROR_VERIFIED", "state": state, "stronghold": _stronghold_snapshot(), "generals": _generals_snapshot()}
	if action == "GET_STATE":
		return {"status": "OK", "state": state, "stronghold": _stronghold_snapshot(), "generals": _generals_snapshot()}
	if action == "SAVE_STATE":
		save_sealed_save()
		return {"status": "SAVED", "state": state, "stronghold": _stronghold_snapshot(), "generals": _generals_snapshot()}
	if action == "GET_STRONGHOLD":
		return {"status": "OK", "stronghold": _stronghold_snapshot(), "generals": _generals_snapshot()}
	if action == "GET_GENERALS":
		return {"status": "OK", "generals": _generals_snapshot()}
	if action == "APPOINT_GENERAL":
		var gid := str(req.get("general_id", "")).to_upper()
		var slot := str(req.get("slot", "")).to_lower()
		if not GENERALS.has(gid):
			return {"status": "ERROR", "message": "Unknown general: " + gid}
		for s in assignments.keys():
			if assignments[s] == gid:
				assignments.erase(s)
		assignments[slot] = gid
		var meta: Dictionary = GENERALS[gid]
		var syn := (slot == str(meta["preferred_slot"]))
		return {"status": "OK", "general_name": meta["name"], "specialty_synergy": syn, "command_power_bonus": _calc_cmd_bonus(), "generals": _generals_snapshot(), "stronghold": _stronghold_snapshot()}
	if action == "COLLECT_TRIBUTE":
		var res: Dictionary = stronghold["resources"]
		var gained := {"provision": 150, "timber": 120, "stone": 120, "talents": 45}
		for k in gained.keys():
			res[k] = int(res.get(k, 0)) + int(gained[k])
		return {"status": "OK", "gained": gained, "stronghold": _stronghold_snapshot()}
	if action == "UPGRADE_BUILDING":
		var bid := str(req.get("building_id", "sanctuary_keep"))
		var blds: Dictionary = stronghold["buildings"]
		var lvl := int(blds[bid]["level"])
		var cost := int(round(150 * (1.0 + (lvl - 1) * 0.45)))
		var res: Dictionary = stronghold["resources"]
		if int(res.get("stone", 0)) < cost or int(res.get("timber", 0)) < cost:
			return {"status": "ERROR", "message": "Insufficient Stone/Timber (need %d). Collect Covenant Tribute first." % cost}
		res["stone"] = int(res["stone"]) - cost
		res["timber"] = int(res["timber"]) - cost
		blds[bid]["level"] = lvl + 1
		return {"status": "OK", "new_level": lvl + 1, "stronghold": _stronghold_snapshot()}
	if action == "CONQUER_CAMPAIGN_CHAPTER":
		var cid := str(req.get("chapter_id", "CH_01_MAMRE"))
		var conquered: Array = stronghold["conquered_chapters"]
		if conquered.has(cid):
			return {"status": "ERROR", "message": "Chapter already conquered."}
		for ch in CHAPTERS:
			if ch["chapter_id"] == cid:
				var pwr := _calc_base_power() + _calc_cmd_bonus()
				if pwr < int(ch["required_power"]):
					return {"status": "ERROR", "message": "Combined Power %d below required %d." % [pwr, int(ch["required_power"])]}
				conquered.append(cid)
				var rw: Dictionary = ch["rewards"]
				var res: Dictionary = stronghold["resources"]
				for rk in rw.keys():
					res[rk] = int(res.get(rk, 0)) + int(rw[rk])
				return {"status": "OK", "conquered": ch, "stronghold": _stronghold_snapshot()}
		return {"status": "ERROR", "message": "Unknown chapter: " + cid}
	if action == "GET_BLOODLINE":
		return {"status": "OK", "bloodline": state["bloodline"]}
	if action == "TRIGGER_HANDOFF":
		var bl: Dictionary = state["bloodline"]
		bl["generation_number"] = int(bl["generation_number"]) + 1
		bl["current_leader"] = str(req.get("next_heir", "Heir_Next"))
		return {"status": "OK", "transition_type": "COVENANT_SUCCESSION", "bloodline": bl, "state": state}
	if action == "ADVANCE_ERA_LOOP":
		var cur := str(state.get("current_era", "ERA_TORAH"))
		var idx := ERAS.find(cur)
		var looped := false
		var next_era := ERAS[0]
		if idx >= 0 and idx < ERAS.size() - 1:
			next_era = ERAS[idx + 1]
		else:
			looped = true
			state["bloodline"]["epoch_number"] = int(state["bloodline"]["epoch_number"]) + 1
		state["current_era"] = next_era
		state["bloodline"]["current_era"] = next_era
		return {"status": "OK", "alpha_omega_loop_triggered": looped, "bloodline": state["bloodline"], "state": state}
	if action == "GET_SCENARIO":
		var sid := str(req.get("scenario_id", "GEN_001"))
		var s_title: String = str(OFFLINE_SCENARIO_TITLES.get(sid, "Sovereign Biblical Scenario"))
		return {"status": "OK", "scenario": {"id": sid, "era": state["current_era"], "context": "[%s] Sovereign Offline Multi-Device Simulation Mode active." % s_title, "prompt": "How will your dynasty steward %s?" % s_title, "options": [{"text": "Uphold Covenant Law & Wisdom"}, {"text": "Fortify Stronghold & Provisions"}]}}
	if action == "RESOLVE_DECISION":
		state["total_score"] = int(state["total_score"]) + 25
		return {"status": "OK", "outcome": {"text": "Covenant stewardship honored (+25 Wisdom Score).", "flag": "COVENANT_FAITHFUL"}, "state": state}
	if action == "GET_PERPETUAL_TRIAL":
		trial_cursor += 1
		return {"status": "OK", "trial_token": "OFFLINE_%d" % trial_cursor, "trial": {"tier_label": "TIER_1", "era": state["current_era"], "reference": "Joshua 1:8", "prompt": "What is promised when the Book of the Law does not depart from your mouth and you meditate on it day and night?", "options": ["You will make your way prosperous and have good success", "You will never face any trials", "You may ignore the elders", "You no longer need wisdom"]}}
	if action == "SUBMIT_PERPETUAL_TRIAL":
		var correct := (int(req.get("answer_index", -1)) == 0)
		if correct:
			state["total_score"] = int(state["total_score"]) + 50
		return {"status": "OK", "correct": correct, "reference": "Joshua 1:8", "next_tier_label": "TIER_2", "explanation": "Joshua 1:8 anchors leadership prosperity in faithful obedience to Scripture.", "state": state}
	if action == "EXPORT_EDTECH_TRANSCRIPT":
		var score := int(state.get("total_score", 0))
		var standing := "FOUNDATIONAL_INITIATE"
		if score >= 1500:
			standing = "SOVEREIGN_SCHOLAR_DISTINCTION"
		elif score >= 800:
			standing = "COVENANT_HONORS_FELLOW"
		elif score >= 300:
			standing = "VERIFIED_SCRIPTURE_STEWARD"
		var t_body := {"schema_version": "HVF_EDTECH_TRANSCRIPT_V1", "student_alias": str(req.get("student_alias", "Sovereign_Candidate")), "institution_name": str(req.get("institution_name", "HVF Institutional EdTech Network")), "academic_standing": standing, "current_era": state.get("current_era", "ERA_TORAH"), "total_wisdom_score": score}
		var t_sig := _compute_sha256(JSON.stringify(t_body))
		var md := "# HVF SOVEREIGN BIBLE GAME ENGINE ? VERIFIED MASTERY TRANSCRIPT\n\n- **Standing:** %s\n- **Era:** %s\n- **Wisdom Score:** %d\n- **SHA-256 Seal:** `%s`\n" % [standing, str(t_body["current_era"]), score, t_sig]
		return {"status": "OK", "transcript": t_body, "transcript_sha256": t_sig, "markdown_certificate": md}
	return {"status": "ERROR", "message": "Unsupported offline action: " + action}
