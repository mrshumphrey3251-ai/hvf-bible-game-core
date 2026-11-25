"""
HVF Sovereign Bible Game Engine — Phase 18: Biblical Patriarch & General Roster
Additive, zero-rewrite commander layer providing:
  - 5 Biblical Leaders (Moses, Joshua, Deborah, David, Paul) with era affinity & specialty bonuses
  - Slot appointments across Stronghold Buildings (`sanctuary_keep`, `scriptorium`, `granary`,
    `watchtower`, `rampart_walls`) and Campaign Vanguard (`campaign_vanguard`)
  - Live wire actions (`GET_GENERALS`, `APPOINT_GENERAL`, `DISMISS_GENERAL`, `LOAD_GENERALS_STATE`)
  - Automatic power & tribute synergy calculation + GET_STATE/SAVE_STATE state envelope embedding
"""
from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from typing import Any, Dict, List, Optional


GENERALS_CATALOG: Dict[str, Dict[str, Any]] = {
    "MOSES": {
        "general_id": "MOSES",
        "name": "Moses, Shepherd & Lawgiver",
        "era": "ERA_TORAH",
        "specialty": "Covenant Governance & Exodus Logistics",
        "preferred_slot": "sanctuary_keep",
        "base_command_power": 320,
        "bonuses": {
            "dynasty_power_bonus": 320,
            "provision_yield_pct": 25,
            "keep_synergy_pct": 20,
        },
        "scripture_anchor": "Exodus 18:21 — Capable, God-fearing leaders over thousands and hundreds",
    },
    "JOSHUA": {
        "general_id": "JOSHUA",
        "name": "Joshua, Commander of the Hosts",
        "era": "ERA_HISTORY",
        "specialty": "Siege Conquest & Stronghold Defense",
        "preferred_slot": "campaign_vanguard",
        "base_command_power": 380,
        "bonuses": {
            "dynasty_power_bonus": 380,
            "campaign_power_bonus": 450,
            "stone_yield_pct": 20,
        },
        "scripture_anchor": "Joshua 1:9 — Be strong and courageous; the Lord your God is with you",
    },
    "DEBORAH": {
        "general_id": "DEBORAH",
        "name": "Deborah, Prophetess & Judge",
        "era": "ERA_HISTORY",
        "specialty": "Prophetic Foresight & Strategic Timing",
        "preferred_slot": "watchtower",
        "base_command_power": 310,
        "bonuses": {
            "dynasty_power_bonus": 310,
            "timber_yield_pct": 20,
            "foresight_bonus_pct": 25,
        },
        "scripture_anchor": "Judges 4:14 — Arise, for this is the day the Lord has given Sisera into your hand",
    },
    "DAVID": {
        "general_id": "DAVID",
        "name": "David, Sovereign King of Zion",
        "era": "ERA_WISDOM",
        "specialty": "Royal Treasury & United Kingdom Command",
        "preferred_slot": "rampart_walls",
        "base_command_power": 360,
        "bonuses": {
            "dynasty_power_bonus": 360,
            "talents_yield_pct": 30,
            "wall_defense_pct": 25,
        },
        "scripture_anchor": "2 Samuel 5:7 — David captured the fortress of Zion—which is the City of David",
    },
    "PAUL": {
        "general_id": "PAUL",
        "name": "Paul, Apostle to the Nations",
        "era": "ERA_EPISTLES",
        "specialty": "Apostolic Epistles & Scriptorium Mastery",
        "preferred_slot": "scriptorium",
        "base_command_power": 340,
        "bonuses": {
            "dynasty_power_bonus": 340,
            "scripture_mastery_bonus_pct": 30,
            "all_tribute_pct": 15,
        },
        "scripture_anchor": "2 Timothy 2:15 — Rightly handling the word of truth as an approved workman",
    },
}

VALID_ASSIGNMENT_SLOTS: List[str] = [
    "sanctuary_keep",
    "scriptorium",
    "granary",
    "watchtower",
    "rampart_walls",
    "campaign_vanguard",
]


@dataclass
class DynastyGeneralsState:
    # Maps slot_id -> general_id (e.g., {"sanctuary_keep": "MOSES", "campaign_vanguard": "JOSHUA"})
    assignments: Dict[str, str] = field(default_factory=dict)
    unlocked_generals: List[str] = field(
        default_factory=lambda: list(GENERALS_CATALOG.keys())
    )

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, raw: Optional[Dict[str, Any]]) -> "DynastyGeneralsState":
        if not raw or not isinstance(raw, dict):
            return cls()
        clean_assignments: Dict[str, str] = {}
        if isinstance(raw.get("assignments"), dict):
            for slot, gid in raw["assignments"].items():
                slot_s = str(slot)
                gid_s = str(gid).upper()
                if slot_s in VALID_ASSIGNMENT_SLOTS and gid_s in GENERALS_CATALOG:
                    clean_assignments[slot_s] = gid_s
        unlocked = [
            str(g).upper()
            for g in raw.get("unlocked_generals", list(GENERALS_CATALOG.keys()))
            if str(g).upper() in GENERALS_CATALOG
        ]
        if not unlocked:
            unlocked = list(GENERALS_CATALOG.keys())
        return cls(assignments=clean_assignments, unlocked_generals=unlocked)


class DynastyGeneralsEngine:
    """Manages appointment and bonus synergy of Biblical Patriarchs and Generals."""

    def __init__(self, state: Optional[DynastyGeneralsState] = None) -> None:
        self.state = state or DynastyGeneralsState()

    def calculate_command_power_bonus(self) -> int:
        total_bonus = 0
        for slot, gid in self.state.assignments.items():
            meta = GENERALS_CATALOG.get(gid)
            if not meta:
                continue
            bonus = int(meta["base_command_power"])
            # +25% specialty synergy if appointed to their preferred Biblical post
            if slot == meta["preferred_slot"]:
                bonus = int(round(bonus * 1.25))
            total_bonus += bonus
        return total_bonus

    def get_snapshot(self) -> Dict[str, Any]:
        assigned_lookup = {gid: slot for slot, gid in self.state.assignments.items()}
        roster = {}
        for gid, meta in GENERALS_CATALOG.items():
            current_slot = assigned_lookup.get(gid)
            effective_power = meta["base_command_power"]
            if current_slot == meta["preferred_slot"]:
                effective_power = int(round(effective_power * 1.25))
            roster[gid] = {
                **meta,
                "unlocked": gid in self.state.unlocked_generals,
                "assigned_slot": current_slot,
                "specialty_synergy_active": current_slot == meta["preferred_slot"],
                "effective_command_power": effective_power,
            }
        return {
            "assignments": dict(self.state.assignments),
            "valid_slots": list(VALID_ASSIGNMENT_SLOTS),
            "total_command_power_bonus": self.calculate_command_power_bonus(),
            "roster": roster,
        }

    def appoint_general(self, general_id: str, slot: str) -> Dict[str, Any]:
        gid = str(general_id).strip().upper()
        slot_id = str(slot).strip().lower()
        if gid not in GENERALS_CATALOG:
            return {"status": "ERROR", "message": f"Unknown general_id: {gid}"}
        if slot_id not in VALID_ASSIGNMENT_SLOTS:
            return {
                "status": "ERROR",
                "message": f"Invalid slot '{slot_id}'. Valid slots: {VALID_ASSIGNMENT_SLOTS}",
            }
        if gid not in self.state.unlocked_generals:
            return {"status": "ERROR", "message": f"General {gid} is not unlocked yet."}

        # Unassign general from any previous post so one leader commands one post at a time
        for existing_slot, existing_gid in list(self.state.assignments.items()):
            if existing_gid == gid:
                del self.state.assignments[existing_slot]

        self.state.assignments[slot_id] = gid
        meta = GENERALS_CATALOG[gid]
        synergy = slot_id == meta["preferred_slot"]
        return {
            "status": "OK",
            "appointed_general": gid,
            "general_name": meta["name"],
            "assigned_slot": slot_id,
            "specialty_synergy": synergy,
            "command_power_bonus": self.calculate_command_power_bonus(),
            "generals": self.get_snapshot(),
        }

    def dismiss_general(self, slot: str) -> Dict[str, Any]:
        slot_id = str(slot).strip().lower()
        if slot_id not in self.state.assignments:
            return {"status": "ERROR", "message": f"No general currently assigned to '{slot_id}'."}
        removed = self.state.assignments.pop(slot_id)
        return {
            "status": "OK",
            "dismissed_general": removed,
            "cleared_slot": slot_id,
            "command_power_bonus": self.calculate_command_power_bonus(),
            "generals": self.get_snapshot(),
        }


def attach_generals_to_dispatcher(dispatcher: Any) -> DynastyGeneralsEngine:
    """Binds Phase 18 Biblical Generals actions & state persistence onto OmniClientDispatcher."""
    engine = DynastyGeneralsEngine()
    setattr(dispatcher, "generals_engine", engine)

    if hasattr(dispatcher, "register_action"):
        dispatcher.register_action(
            "GET_GENERALS",
            lambda p: {"status": "OK", "generals": engine.get_snapshot()},
        )
        dispatcher.register_action(
            "APPOINT_GENERAL",
            lambda p: engine.appoint_general(
                str(p.get("general_id", "")),
                str(p.get("slot", "")),
            ),
        )
        dispatcher.register_action(
            "DISMISS_GENERAL",
            lambda p: engine.dismiss_general(str(p.get("slot", ""))),
        )
        dispatcher.register_action(
            "LOAD_GENERALS_STATE",
            lambda p: {"status": "OK", "generals": engine.get_snapshot()},
        )

    orig_dispatch = dispatcher.dispatch_message

    def _generals_persisted_dispatch(raw_msg: str) -> str:
        try:
            req = json.loads(raw_msg) if isinstance(raw_msg, str) else dict(raw_msg)
        except Exception:
            return orig_dispatch(raw_msg)

        action = str(req.get("action", "")).upper()

        if action == "LOAD_GENERALS_STATE" and isinstance(req.get("generals"), dict):
            engine.state = DynastyGeneralsState.from_dict(req["generals"])
            return json.dumps({"status": "OK", "generals": engine.get_snapshot()})

        if action == "SAVE_STATE":
            state_obj = getattr(dispatcher, "game_state", None) or getattr(dispatcher, "engine_state", None)
            if state_obj is not None and hasattr(state_obj, "__dict__"):
                setattr(state_obj, "dynasty_generals", engine.state.to_dict())

        resp_raw = orig_dispatch(raw_msg)

        if action in {"GET_STATE", "HANDSHAKE", "SAVE_STATE", "GET_STRONGHOLD", "APPOINT_GENERAL", "DISMISS_GENERAL"}:
            try:
                resp_obj = json.loads(resp_raw)
                if isinstance(resp_obj, dict):
                    resp_obj["generals"] = engine.get_snapshot()
                    if isinstance(resp_obj.get("state"), dict):
                        resp_obj["state"]["dynasty_generals"] = engine.state.to_dict()
                    # Combine Stronghold Power + Biblical Commander Power Bonus
                    if isinstance(resp_obj.get("stronghold"), dict):
                        base_pwr = int(resp_obj["stronghold"].get("dynasty_power", 1000))
                        cmd_bonus = engine.calculate_command_power_bonus()
                        resp_obj["stronghold"]["commander_power_bonus"] = cmd_bonus
                        resp_obj["stronghold"]["total_combined_power"] = base_pwr + cmd_bonus
                    return json.dumps(resp_obj)
            except Exception:
                pass
        return resp_raw

    dispatcher.dispatch_message = _generals_persisted_dispatch
    return engine


if __name__ == "__main__":
    g_eng = DynastyGeneralsEngine()
    print(json.dumps(g_eng.get_snapshot(), indent=2))
