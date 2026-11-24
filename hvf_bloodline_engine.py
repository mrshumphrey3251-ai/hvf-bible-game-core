#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: PHASE 9 GENERATIONAL BLOODLINE & ALPHA-OMEGA ENGINE
# DOCTRINE: Additive, Zero-Rewrite Continuity Plugin for OmniClientDispatcher.
#           Implements Section 6 of HVF_LIFE_SIMULATOR_REQUIREMENTS.md:
#             1. Bloodline Handoff (Heir succession or severed-line respawn)
#             2. Alpha-Omega Loop (Torah -> Epistles -> Revelation -> Genesis)
# ==============================================================================

import json
import uuid
from bible_game_engine import BibleEras


class BloodlineAlphaOmegaEngine:
    """Manages generational succession and infinite Alpha-Omega epoch cycles."""

    def __init__(self, dispatcher, founder_name="Adam_Line_01", heir_name="Seth_Line_02"):
        self.dispatcher = dispatcher
        self.era_sequence = BibleEras.get_all_eras()
        self.epoch_number = 1
        self.generation_number = 1
        self.current_leader = founder_name
        self.designated_heir = heir_name
        self.legacy_traits = []
        self.lineage_archive = []
        self.event_hooks = {}

    def register_hook(self, event_name, callback_fn):
        """Extensible Phase 10+ event hook (e.g., ON_HANDOFF, ON_ALPHA_OMEGA_LOOP)."""
        self.event_hooks.setdefault(event_name.upper(), []).append(callback_fn)

    def _emit(self, event_name, context):
        for fn in self.event_hooks.get(event_name.upper(), []):
            fn(context)

    def snapshot(self):
        return {
            "epoch_number": self.epoch_number,
            "generation_number": self.generation_number,
            "current_leader": self.current_leader,
            "designated_heir": self.designated_heir,
            "current_era": self.dispatcher.current_era,
            "legacy_traits": list(self.legacy_traits),
            "lineage_count": len(self.lineage_archive),
            "total_score": self.dispatcher.engine_state.total_score,
            "era_mastery": dict(self.dispatcher.engine_state.era_mastery),
        }

    def handle_get_bloodline(self, payload):
        return {"status": "OK", "bloodline": self.snapshot()}

    def handle_designate_heir(self, payload):
        heir_name = str(payload.get("heir_name", "")).strip()
        if not heir_name:
            return {"status": "ERROR", "error": "heir_name is required"}
        self.designated_heir = heir_name
        return {"status": "OK", "bloodline": self.snapshot()}

    def handle_trigger_handoff(self, payload):
        cause_of_death = str(payload.get("cause", "OLD_AGE"))
        next_heir = payload.get("next_heir")
        self.lineage_archive.append({
            "epoch": self.epoch_number,
            "generation": self.generation_number,
            "leader": self.current_leader,
            "era": self.dispatcher.current_era,
            "cause": cause_of_death,
        })

        # Promote active flags into inherited legacy traits
        for flag in sorted(self.dispatcher.narrative.player_flags):
            if flag not in self.legacy_traits:
                self.legacy_traits.append(flag)

        if self.designated_heir:
            transition_type = "HEIR_SUCCESSION"
            self.current_leader = self.designated_heir
            self.generation_number += 1
            self.designated_heir = str(next_heir).strip() if next_heir else None
        else:
            transition_type = "SEVERED_BLOODLINE_RESPAWN"
            self.generation_number = 1
            self.current_leader = f"Remnant_{uuid.uuid4().hex[:6].upper()}"
            self.designated_heir = str(next_heir).strip() if next_heir else None

        result = {
            "status": "OK",
            "transition_type": transition_type,
            "cause": cause_of_death,
            "bloodline": self.snapshot(),
            "state": self.dispatcher._build_snapshot(),
        }
        self._emit("ON_HANDOFF", result)
        return result

    def handle_advance_era_loop(self, payload):
        current = self.dispatcher.current_era
        if current not in self.era_sequence:
            current = self.era_sequence[0]
        idx = self.era_sequence.index(current)

        if idx + 1 < len(self.era_sequence):
            self.dispatcher.current_era = self.era_sequence[idx + 1]
            loop_triggered = False
            event_label = f"ADVANCED_TO_{self.dispatcher.current_era}"
        else:
            # Eschatological Revelation boundary reached -> Alpha-Omega Loop back to Genesis
            for flag in sorted(self.dispatcher.narrative.player_flags):
                if flag not in self.legacy_traits:
                    self.legacy_traits.append(flag)
            self.dispatcher.narrative.player_flags.clear()
            self.epoch_number += 1
            self.dispatcher.current_era = self.era_sequence[0]
            loop_triggered = True
            event_label = "ALPHA_OMEGA_LOOP_REVELATION_TO_GENESIS"

        result = {
            "status": "OK",
            "event": event_label,
            "alpha_omega_loop_triggered": loop_triggered,
            "bloodline": self.snapshot(),
            "state": self.dispatcher._build_snapshot(),
        }
        if loop_triggered:
            self._emit("ON_ALPHA_OMEGA_LOOP", result)
        return result


def register_with_dispatcher(dispatcher):
    """Mounts Phase 9 Bloodline & Alpha-Omega actions onto an OmniClientDispatcher."""
    engine = BloodlineAlphaOmegaEngine(dispatcher)
    dispatcher.bloodline_engine = engine
    dispatcher.register_action("GET_BLOODLINE", engine.handle_get_bloodline)
    dispatcher.register_action("DESIGNATE_HEIR", engine.handle_designate_heir)
    dispatcher.register_action("TRIGGER_HANDOFF", engine.handle_trigger_handoff)
    dispatcher.register_action("ADVANCE_ERA_LOOP", engine.handle_advance_era_loop)
    return engine