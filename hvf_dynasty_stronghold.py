"""
HVF Sovereign Bible Game Engine — Phase 15: Evony-Scale Dynasty Stronghold & Campaign Engine
Additive, zero-rewrite strategic layer providing:
  - 5 upgradeable Covenant Stronghold buildings
  - 4 strategic dynasty resources (provision, timber, stone, talents)
  - 6 Biblical Era campaign chapters gated by Dynasty Power & Stronghold level
  - Seamless registration onto OmniClientDispatcher wire protocol
"""
from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from typing import Any, Dict, List, Optional


DEFAULT_RESOURCES: Dict[str, int] = {
    "provision": 500,
    "timber": 400,
    "stone": 400,
    "talents": 150,
}

BUILDING_CATALOG: Dict[str, Dict[str, Any]] = {
    "sanctuary_keep": {
        "name": "Sanctuary Keep",
        "role": "Sovereign command seat; governs max level of all other buildings.",
        "base_power": 250,
        "base_cost": {"provision": 150, "timber": 150, "stone": 200, "talents": 50},
        "max_level": 25,
    },
    "scriptorium": {
        "name": "Royal Scriptorium",
        "role": "Preserves sacred scrolls; boosts resource tribute yield by +15% per level.",
        "base_power": 180,
        "base_cost": {"provision": 100, "timber": 140, "stone": 100, "talents": 40},
        "max_level": 25,
    },
    "granary": {
        "name": "Covenant Granary",
        "role": "Stores harvest reserves; shields dynasty stability against famine events.",
        "base_power": 160,
        "base_cost": {"provision": 120, "timber": 120, "stone": 90, "talents": 25},
        "max_level": 25,
    },
    "watchtower": {
        "name": "Prophetic Watchtower",
        "role": "Extends strategic foresight and boosts campaign conquest power.",
        "base_power": 190,
        "base_cost": {"provision": 90, "timber": 150, "stone": 130, "talents": 35},
        "max_level": 25,
    },
    "rampart_walls": {
        "name": "Sovereign Rampart Walls",
        "role": "Fortifies stronghold defense and unlocks higher Biblical Campaign chapters.",
        "base_power": 220,
        "base_cost": {"provision": 110, "timber": 110, "stone": 220, "talents": 45},
        "max_level": 25,
    },
}

CAMPAIGN_CHAPTERS: List[Dict[str, Any]] = [
    {
        "chapter_id": "CH_01_MAMRE",
        "era": "ERA_TORAH",
        "title": "Encampment at the Oaks of Mamre",
        "required_power": 1000,
        "rewards": {"provision": 250, "timber": 200, "stone": 150, "talents": 60},
    },
    {
        "chapter_id": "CH_02_JERICHO",
        "era": "ERA_HISTORY",
        "title": "Siege & Trumpet March of Jericho",
        "required_power": 1450,
        "rewards": {"provision": 350, "timber": 300, "stone": 350, "talents": 100},
    },
    {
        "chapter_id": "CH_03_ZION_COURT",
        "era": "ERA_WISDOM",
        "title": "Royal Court & Cedars of Jerusalem",
        "required_power": 2000,
        "rewards": {"provision": 450, "timber": 500, "stone": 450, "talents": 160},
    },
    {
        "chapter_id": "CH_04_CARMEL",
        "era": "ERA_PROPHETS",
        "title": "Altar Showdown on Mount Carmel",
        "required_power": 2700,
        "rewards": {"provision": 600, "timber": 550, "stone": 600, "talents": 220},
    },
    {
        "chapter_id": "CH_05_CAPERNAUM",
        "era": "ERA_GOSPELS",
        "title": "Galilee Harbor & Kingdom Proclamation",
        "required_power": 3500,
        "rewards": {"provision": 800, "timber": 700, "stone": 750, "talents": 300},
    },
    {
        "chapter_id": "CH_06_ANTIOCH_MISSION",
        "era": "ERA_EPISTLES",
        "title": "Antioch Sending & Mediterranean Network",
        "required_power": 4500,
        "rewards": {"provision": 1100, "timber": 950, "stone": 1000, "talents": 450},
    },
]


@dataclass
class DynastyStrongholdState:
    stronghold_name: str = "Covenant Citadel of Zion"
    resources: Dict[str, int] = field(default_factory=lambda: dict(DEFAULT_RESOURCES))
    buildings: Dict[str, int] = field(
        default_factory=lambda: {k: 1 for k in BUILDING_CATALOG}
    )
    conquered_chapters: List[str] = field(default_factory=list)
    tribute_collections: int = 0

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, raw: Optional[Dict[str, Any]]) -> "DynastyStrongholdState":
        if not raw or not isinstance(raw, dict):
            return cls()
        res = dict(DEFAULT_RESOURCES)
        if isinstance(raw.get("resources"), dict):
            for k, v in raw["resources"].items():
                res[k] = int(v)
        bld = {k: 1 for k in BUILDING_CATALOG}
        if isinstance(raw.get("buildings"), dict):
            for k, v in raw["buildings"].items():
                if k in bld:
                    bld[k] = max(1, int(v))
        chapters = [str(c) for c in raw.get("conquered_chapters", [])]
        return cls(
            stronghold_name=str(raw.get("stronghold_name", "Covenant Citadel of Zion")),
            resources=res,
            buildings=bld,
            conquered_chapters=chapters,
            tribute_collections=int(raw.get("tribute_collections", 0)),
        )


class DynastyStrongholdEngine:
    """Manages Evony-scale stronghold buildings, resource economy, and Biblical campaign progression."""

    def __init__(self, state: Optional[DynastyStrongholdState] = None) -> None:
        self.state = state or DynastyStrongholdState()

    def calculate_dynasty_power(self) -> int:
        power = 0
        for b_key, level in self.state.buildings.items():
            meta = BUILDING_CATALOG.get(b_key, {})
            power += int(meta.get("base_power", 100)) * int(level)
        power += len(self.state.conquered_chapters) * 300
        return power

    def get_upgrade_cost(self, building_id: str) -> Dict[str, int]:
        if building_id not in BUILDING_CATALOG:
            raise ValueError(f"Unknown building_id: {building_id}")
        current_lvl = self.state.buildings.get(building_id, 1)
        base_cost = BUILDING_CATALOG[building_id]["base_cost"]
        multiplier = 1.0 + (current_lvl - 1) * 0.45
        return {res: int(round(amt * multiplier)) for res, amt in base_cost.items()}

    def get_snapshot(self) -> Dict[str, Any]:
        building_details = {}
        for b_key, meta in BUILDING_CATALOG.items():
            lvl = self.state.buildings.get(b_key, 1)
            building_details[b_key] = {
                "name": meta["name"],
                "role": meta["role"],
                "level": lvl,
                "max_level": meta["max_level"],
                "power_contribution": meta["base_power"] * lvl,
                "next_upgrade_cost": self.get_upgrade_cost(b_key),
            }
        return {
            "stronghold_name": self.state.stronghold_name,
            "dynasty_power": self.calculate_dynasty_power(),
            "resources": dict(self.state.resources),
            "buildings": building_details,
            "conquered_chapters": list(self.state.conquered_chapters),
            "available_chapters": CAMPAIGN_CHAPTERS,
            "tribute_collections": self.state.tribute_collections,
        }

    def collect_tribute(self, mastery_score: int = 0) -> Dict[str, Any]:
        scriptorium_lvl = self.state.buildings.get("scriptorium", 1)
        granary_lvl = self.state.buildings.get("granary", 1)
        wisdom_mult = 1.0 + (scriptorium_lvl - 1) * 0.15 + min(mastery_score / 2000.0, 1.0)
        gained = {
            "provision": int(round((120 + granary_lvl * 25) * wisdom_mult)),
            "timber": int(round(100 * wisdom_mult)),
            "stone": int(round(100 * wisdom_mult)),
            "talents": int(round(35 * wisdom_mult)),
        }
        for res, amt in gained.items():
            self.state.resources[res] = self.state.resources.get(res, 0) + amt
        self.state.tribute_collections += 1
        return {
            "status": "OK",
            "gained": gained,
            "stronghold": self.get_snapshot(),
        }

    def upgrade_building(self, building_id: str) -> Dict[str, Any]:
        if building_id not in BUILDING_CATALOG:
            return {"status": "ERROR", "message": f"Invalid building: {building_id}"}
        meta = BUILDING_CATALOG[building_id]
        current_lvl = self.state.buildings.get(building_id, 1)
        keep_lvl = self.state.buildings.get("sanctuary_keep", 1)

        if current_lvl >= meta["max_level"]:
            return {"status": "ERROR", "message": f"{meta['name']} is already at max level."}
        if building_id != "sanctuary_keep" and current_lvl >= keep_lvl:
            return {
                "status": "ERROR",
                "message": f"Upgrade Sanctuary Keep (Lv.{keep_lvl}) first before upgrading {meta['name']}.",
            }

        cost = self.get_upgrade_cost(building_id)
        for res, req in cost.items():
            if self.state.resources.get(res, 0) < req:
                return {
                    "status": "ERROR",
                    "message": f"Insufficient {res}: need {req}, have {self.state.resources.get(res, 0)}.",
                }

        for res, req in cost.items():
            self.state.resources[res] -= req
        self.state.buildings[building_id] = current_lvl + 1

        return {
            "status": "OK",
            "upgraded_building": building_id,
            "new_level": self.state.buildings[building_id],
            "cost_paid": cost,
            "stronghold": self.get_snapshot(),
        }

    def conquer_campaign_chapter(self, chapter_id: str) -> Dict[str, Any]:
        chapter = next((c for c in CAMPAIGN_CHAPTERS if c["chapter_id"] == chapter_id), None)
        if not chapter:
            return {"status": "ERROR", "message": f"Unknown campaign chapter: {chapter_id}"}
        if chapter_id in self.state.conquered_chapters:
            return {"status": "ERROR", "message": f"Chapter {chapter_id} already conquered."}

        current_power = self.calculate_dynasty_power()
        if current_power < chapter["required_power"]:
            return {
                "status": "ERROR",
                "message": f"Dynasty Power {current_power} is below required {chapter['required_power']}.",
            }

        self.state.conquered_chapters.append(chapter_id)
        for res, amt in chapter["rewards"].items():
            self.state.resources[res] = self.state.resources.get(res, 0) + amt

        return {
            "status": "OK",
            "conquered": chapter,
            "stronghold": self.get_snapshot(),
        }


def attach_stronghold_to_dispatcher(dispatcher: Any) -> DynastyStrongholdEngine:
    """Binds Phase 15 Dynasty Stronghold wire actions onto an OmniClientDispatcher instance."""
    engine = DynastyStrongholdEngine()
    setattr(dispatcher, "stronghold_engine", engine)

    def _get_stronghold(payload: Dict[str, Any]) -> Dict[str, Any]:
        return {"status": "OK", "stronghold": engine.get_snapshot()}

    def _collect_tribute(payload: Dict[str, Any]) -> Dict[str, Any]:
        score = int(payload.get("total_score", 0))
        return engine.collect_tribute(mastery_score=score)

    def _upgrade_building(payload: Dict[str, Any]) -> Dict[str, Any]:
        b_id = str(payload.get("building_id", ""))
        return engine.upgrade_building(b_id)

    def _conquer_chapter(payload: Dict[str, Any]) -> Dict[str, Any]:
        c_id = str(payload.get("chapter_id", ""))
        return engine.conquer_campaign_chapter(c_id)

    if hasattr(dispatcher, "register_action"):
        dispatcher.register_action("GET_STRONGHOLD", _get_stronghold)
        dispatcher.register_action("COLLECT_TRIBUTE", _collect_tribute)
        dispatcher.register_action("UPGRADE_BUILDING", _upgrade_building)
        dispatcher.register_action("CONQUER_CAMPAIGN_CHAPTER", _conquer_chapter)

    return engine


if __name__ == "__main__":
    eng = DynastyStrongholdEngine()
    print(json.dumps(eng.get_snapshot(), indent=2))
