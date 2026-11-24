#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: PHASE 12 PERPETUAL ANTI-MEMORIZATION & PEDAGOGY ENGINE
# DOCTRINE: Additive, Zero-Rewrite Engine guaranteeing 10+ years of non-repeatable
#           scriptural instruction through:
#             1. Cryptographic option-order permutation (SystemRandom)
#             2. 4-Tier Escalating Mastery Mutations (Recall -> Inverse Reference ->
#                Cross-Era Synthesis -> Epoch Discernment)
#             3. Spaced-Repetition Adaptive Weighting + Modular banks/*.json Ingestion
# ==============================================================================

import glob
import json
import os
import secrets
import uuid
from bible_game_engine import ScriptureBankValidator


class PerpetualPedagogyEngine:
    """Ensures no scripture challenge can be beaten by rote position memorization."""

    TIER_LABELS = {
        1: "TIER_1_DIRECT_RECALL",
        2: "TIER_2_INVERSE_REFERENCE_DEDUCTION",
        3: "TIER_3_CROSS_ERA_SYNTHESIS",
        4: "TIER_4_EPOCH_COVENANT_MASTERY",
    }

    def __init__(self, dispatcher):
        self.dispatcher = dispatcher
        self.rng = secrets.SystemRandom()
        self.mastery_ledger = {}   # ref -> {"attempts": int, "correct": int, "tier": int}
        self.active_tokens = {}    # token_id -> {"correct_index": int, "reference": str, "era": str, "tier": int, "explanation": str}
        self.mutation_plugins = []

        # Ingest all modular JSON expansion packs in banks/*.json automatically
        self._ingest_modular_banks()

    def _ingest_modular_banks(self):
        banks_dir = os.path.join(self.dispatcher.base_dir, "banks")
        if not os.path.isdir(banks_dir):
            return
        trials_engine = getattr(self.dispatcher, "covenant_trials", None)
        if not trials_engine:
            return
        existing_refs = {c.get("reference") for c in trials_engine.unified_challenges}
        for path in sorted(glob.glob(os.path.join(banks_dir, "*.json"))):
            pack = ScriptureBankValidator.load_and_validate(path)
            for ch in pack.get("challenges", []):
                ref = ch.get("reference")
                if ref and ref not in existing_refs:
                    existing_refs.add(ref)
                    trials_engine.unified_challenges.append(dict(ch))

    def register_mutation_plugin(self, fn):
        """Extensible Phase 13+ hook for custom pedagogical question mutations."""
        self.mutation_plugins.append(fn)

    def _all_challenges(self):
        trials_engine = getattr(self.dispatcher, "covenant_trials", None)
        if trials_engine:
            return trials_engine.unified_challenges
        return self.dispatcher.scripture_bank.get("challenges", [])

    def _select_adaptive_challenge(self, era):
        pool = self._all_challenges()
        if not pool:
            return None
        # Weighted selection: favor unmastered or lower-tier scriptures while allowing cross-era synthesis
        weighted = []
        for ch in pool:
            ref = ch.get("reference", "")
            stats = self.mastery_ledger.get(ref, {"attempts": 0, "correct": 0, "tier": 1})
            tier = stats["tier"]
            era_bonus = 3 if ch.get("era") == era else 1
            novelty_weight = max(1, (5 - tier) * 2) * era_bonus
            weighted.append((ch, novelty_weight))
        total = sum(w for _, w in weighted)
        pick = self.rng.uniform(0, total)
        acc = 0.0
        for ch, w in weighted:
            acc += w
            if pick <= acc:
                return ch
        return weighted[-1][0]

    def _mutate_challenge(self, ch, epoch_number):
        ref = ch.get("reference", "Scripture")
        stats = self.mastery_ledger.get(ref, {"attempts": 0, "correct": 0, "tier": 1})
        tier = min(4, max(stats["tier"], 1 + (epoch_number - 1) // 2))
        options = list(ch.get("options", []))
        correct_text = options[ch.get("correct_index", 0)]
        all_pool = self._all_challenges()

        if tier == 1:
            prompt = ch.get("prompt", "")
            candidate_options = list(options)
            target_answer = correct_text
        elif tier == 2:
            # Inverse Reference Deduction: given the doctrinal truth, identify the exact scripture reference
            other_refs = [c.get("reference") for c in all_pool if c.get("reference") and c.get("reference") != ref]
            self.rng.shuffle(other_refs)
            distractors = other_refs[:3]
            while len(distractors) < 3:
                distractors.append(f"Chronicles {len(distractors)+1}:12")
            prompt = f"[INVERSE DEDUCTION] Which scripture passage establishes this truth: '{correct_text}'?"
            candidate_options = [ref] + distractors
            target_answer = ref
        elif tier == 3:
            # Cross-Era Synthesis: connect the passage's explanation/principle back to its era & witness
            prompt = f"[CROSS-ERA SYNTHESIS | {ch.get('era')}] {ch.get('explanation', '')} — Which core principle anchors this passage?"
            candidate_options = list(options)
            target_answer = correct_text
        else:
            # Tier 4 Epoch Mastery: multi-layered synthesis prompt with scrambled choices
            prompt = f"[EPOCH {epoch_number} MASTERY TRIAL | {ref}] {ch.get('prompt', '')} (Verify doctrinal precision across generations)"
            candidate_options = list(options)
            target_answer = correct_text

        # Cryptographically shuffle answer positions every single time (eliminates slot memorization)
        self.rng.shuffle(candidate_options)
        shuffled_correct_index = candidate_options.index(target_answer)

        mutated = {
            "era": ch.get("era"),
            "reference": ref,
            "tier": tier,
            "tier_label": self.TIER_LABELS.get(tier, "TIER_1"),
            "prompt": prompt,
            "options": candidate_options,
            "correct_index": shuffled_correct_index,
            "explanation": ch.get("explanation", ""),
        }
        for plugin_fn in self.mutation_plugins:
            mutated = plugin_fn(mutated, stats)
        return mutated

    def handle_get_perpetual_trial(self, payload):
        era = payload.get("era") or self.dispatcher.current_era
        bl = getattr(self.dispatcher, "bloodline_engine", None)
        epoch_number = bl.epoch_number if bl else 1

        # Allow deterministic reference targeting for verification/study, otherwise adaptive selection
        target_ref = payload.get("reference")
        ch = None
        if target_ref:
            ch = next((c for c in self._all_challenges() if c.get("reference") == target_ref), None)
        if not ch:
            ch = self._select_adaptive_challenge(era)
        if not ch:
            return {"status": "EMPTY", "error": "No challenges available"}

        mutated = self._mutate_challenge(ch, epoch_number)
        token_id = uuid.uuid4().hex[:12].upper()
        self.active_tokens[token_id] = {
            "correct_index": mutated["correct_index"],
            "reference": mutated["reference"],
            "era": mutated["era"],
            "tier": mutated["tier"],
            "explanation": mutated["explanation"],
        }

        return {
            "status": "OK",
            "trial_token": token_id,
            "trial": {
                "era": mutated["era"],
                "reference": mutated["reference"] if mutated["tier"] != 2 else "DEDUCE_REFERENCE",
                "tier": mutated["tier"],
                "tier_label": mutated["tier_label"],
                "prompt": mutated["prompt"],
                "options": mutated["options"],
                "total_bank_size": len(self._all_challenges()),
            },
        }

    def handle_submit_perpetual_trial(self, payload):
        token_id = str(payload.get("trial_token", "")).strip()
        answer_index = int(payload.get("answer_index", -1))
        record = self.active_tokens.pop(token_id, None)
        if not record:
            return {"status": "ERROR", "error": "Invalid or expired trial_token"}

        ref = record["reference"]
        stats = self.mastery_ledger.setdefault(ref, {"attempts": 0, "correct": 0, "tier": 1})
        stats["attempts"] += 1
        is_correct = answer_index == record["correct_index"]

        if is_correct:
            stats["correct"] += 1
            # Escalate this verse to the next pedagogical tier up to Tier 4
            stats["tier"] = min(4, stats["tier"] + 1)
            bonus = 100 + (record["tier"] * 25)
            self.dispatcher.engine_state.total_score += bonus
            if record["era"] in self.dispatcher.engine_state.era_mastery:
                self.dispatcher.engine_state.era_mastery[record["era"]] += bonus
        else:
            # Gentle reinforcement: keep at current tier for spaced repetition
            stats["tier"] = max(1, stats["tier"])

        return {
            "status": "OK",
            "correct": is_correct,
            "reference": ref,
            "completed_tier": record["tier"],
            "next_tier": stats["tier"],
            "next_tier_label": self.TIER_LABELS.get(stats["tier"], "TIER_1"),
            "explanation": record["explanation"],
            "mastery_stats": dict(stats),
            "state": self.dispatcher._build_snapshot(),
        }

    def handle_get_pedagogy_report(self, payload):
        return {
            "status": "OK",
            "total_unified_scriptures": len(self._all_challenges()),
            "scriptures_studied": len(self.mastery_ledger),
            "mastery_ledger": dict(self.mastery_ledger),
        }


def register_with_dispatcher(dispatcher):
    """Mounts Phase 12 Perpetual Anti-Memorization Engine onto OmniClientDispatcher."""
    pedagogy = PerpetualPedagogyEngine(dispatcher)
    dispatcher.perpetual_pedagogy = pedagogy
    dispatcher.register_action("GET_PERPETUAL_TRIAL", pedagogy.handle_get_perpetual_trial)
    dispatcher.register_action("SUBMIT_PERPETUAL_TRIAL", pedagogy.handle_submit_perpetual_trial)
    dispatcher.register_action("GET_PEDAGOGY_REPORT", pedagogy.handle_get_pedagogy_report)
    return pedagogy