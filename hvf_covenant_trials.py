#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: PHASE 11 SCRIPTURE MASTERY COVENANT TRIALS ENGINE
# DOCTRINE: Additive, Zero-Rewrite Plugin uniting scripture_bank.json and
#           scripture_mastery_bank.json with Bloodline & Alpha-Omega Blessings.
# ==============================================================================

import os
from bible_game_engine import ScriptureBankValidator


class CovenantTrialsEngine:
    """Delivers era-matched Scripture Mastery Trials and persistent Covenant Seals."""

    def __init__(self, dispatcher):
        self.dispatcher = dispatcher
        self.mastery_path = os.path.join(dispatcher.base_dir, "scripture_mastery_bank.json")
        self.mastery_bank = ScriptureBankValidator.load_and_validate(self.mastery_path)
        self.covenant_seals = []
        self.completed_references = []
        self.custom_validators = []

        # Combine primary scripture_bank.json + scripture_mastery_bank.json without duplicates
        seen_refs = set()
        self.unified_challenges = []
        for bank in (dispatcher.scripture_bank, self.mastery_bank):
            for ch in bank.get("challenges", []):
                ref = ch.get("reference")
                if ref and ref not in seen_refs:
                    seen_refs.add(ref)
                    self.unified_challenges.append(dict(ch))

    def register_trial_validator(self, validator_fn):
        """Extensible Phase 12+ hook for custom ministry/study deck validators."""
        self.custom_validators.append(validator_fn)

    def _challenges_for_era(self, era):
        era_matches = [c for c in self.unified_challenges if c.get("era") == era]
        return era_matches if era_matches else self.unified_challenges

    def handle_get_covenant_trial(self, payload):
        era = payload.get("era") or self.dispatcher.current_era
        pool = self._challenges_for_era(era)
        if not pool:
            return {"status": "EMPTY", "error": "No scripture challenges available"}
        idx = int(payload.get("index", 0)) % len(pool)
        ch = pool[idx]
        safe_trial = {
            "era": ch.get("era"),
            "reference": ch.get("reference"),
            "prompt": ch.get("prompt"),
            "options": ch.get("options", []),
            "index": idx,
            "pool_size": len(pool),
            "total_unified": len(self.unified_challenges),
        }
        return {"status": "OK", "trial": safe_trial}

    def handle_submit_covenant_trial(self, payload):
        era = payload.get("era") or self.dispatcher.current_era
        pool = self._challenges_for_era(era)
        if not pool:
            return {"status": "ERROR", "error": "No scripture challenges available"}
        idx = int(payload.get("index", 0)) % len(pool)
        answer_index = int(payload.get("answer_index", -1))
        ch = pool[idx]
        is_correct = answer_index == ch.get("correct_index")

        for validator in self.custom_validators:
            is_correct = bool(validator(ch, answer_index, is_correct))

        seal_granted = None
        if is_correct:
            self.dispatcher.engine_state.award_points(ch.get("era", era))
            # Bonus +50 Covenant Mastery points
            self.dispatcher.engine_state.total_score += 50
            if ch.get("era") in self.dispatcher.engine_state.era_mastery:
                self.dispatcher.engine_state.era_mastery[ch["era"]] += 50

            ref = ch.get("reference", "UNKNOWN")
            if ref not in self.completed_references:
                self.completed_references.append(ref)

            seal_granted = f"COVENANT_SEAL_{ch.get('era', era)}"
            if seal_granted not in self.covenant_seals:
                self.covenant_seals.append(seal_granted)

            # Persist Covenant Seal directly into Bloodline Legacy Traits if Phase 9 is mounted
            bl_engine = getattr(self.dispatcher, "bloodline_engine", None)
            if bl_engine and seal_granted not in bl_engine.legacy_traits:
                bl_engine.legacy_traits.append(seal_granted)

        resp = {
            "status": "OK",
            "correct": is_correct,
            "reference": ch.get("reference"),
            "explanation": ch.get("explanation", ""),
            "seal_granted": seal_granted,
            "covenant_seals": list(self.covenant_seals),
            "state": self.dispatcher._build_snapshot(),
        }
        bl_engine = getattr(self.dispatcher, "bloodline_engine", None)
        if bl_engine:
            resp["bloodline"] = bl_engine.snapshot()
        return resp

    def handle_get_covenant_blessings(self, payload):
        return {
            "status": "OK",
            "covenant_seals": list(self.covenant_seals),
            "completed_references": list(self.completed_references),
            "total_unified_challenges": len(self.unified_challenges),
        }


def register_with_dispatcher(dispatcher):
    """Mounts Phase 11 Scripture Mastery Covenant Trials onto OmniClientDispatcher."""
    trials = CovenantTrialsEngine(dispatcher)
    dispatcher.covenant_trials = trials
    dispatcher.register_action("GET_COVENANT_TRIAL", trials.handle_get_covenant_trial)
    dispatcher.register_action("SUBMIT_COVENANT_TRIAL", trials.handle_submit_covenant_trial)
    dispatcher.register_action("GET_COVENANT_BLESSINGS", trials.handle_get_covenant_blessings)
    return trials