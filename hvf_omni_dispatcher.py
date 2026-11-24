#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: PHASE 8F OMNI-CLIENT DISPATCHER
# DOCTRINE: Additive, Zero-Rewrite Extension over OmniBridge, NarrativeEngine,
#           GameEngineState, ScriptureBankValidator, and SHA-256 StateManager.
# ==============================================================================

import json
import os
import socket
from bible_game_engine import BibleEras, GameEngineState, ScriptureBankValidator
from hvf_3d_bridge import OmniBridge
from hvf_state_manager import StateManager
from narrative_engine import NarrativeEngine
from hvf_bloodline_engine import register_with_dispatcher as register_bloodline_plugin
from hvf_covenant_trials import register_with_dispatcher as register_covenant_plugin
from hvf_perpetual_pedagogy import register_with_dispatcher as register_pedagogy_plugin


class OmniClientDispatcher(OmniBridge):
    """Extensible TCP JSON router connecting Godot 4 and Unreal 5 to HVF core engines."""

    def __init__(self, host="127.0.0.1", port=65432, base_dir=None):
        super().__init__(host=host, port=port)
        self.base_dir = base_dir or os.path.dirname(os.path.abspath(__file__))
        self.engine_state = GameEngineState()
        self.narrative = NarrativeEngine(data_file=os.path.join(self.base_dir, "decision_bank.json"))
        self.state_manager = StateManager(save_file=os.path.join(self.base_dir, "player_state.json"))
        self.scripture_bank = ScriptureBankValidator.load_and_validate(
            os.path.join(self.base_dir, "scripture_bank.json")
        )
        self.current_era = BibleEras.TORAH
        self._running = False

        # Extensible Plugin Action Registry (Add future phases without rewriting core)
        self.action_handlers = {
            "HANDSHAKE": self._handle_handshake,
            "GET_STATE": self._handle_get_state,
            "GET_SCENARIO": self._handle_get_scenario,
            "RESOLVE_DECISION": self._handle_resolve_decision,
            "GET_SCRIPTURE": self._handle_get_scripture,
            "SUBMIT_SCRIPTURE": self._handle_submit_scripture,
            "SAVE_STATE": self._handle_save_state,
        }
        register_bloodline_plugin(self)
        register_covenant_plugin(self)
        register_pedagogy_plugin(self)

    def register_action(self, action_name, handler_fn):
        """Public plugin hook for Phase 9+ modules (Bloodline, Alpha-Omega, UE5)."""
        self.action_handlers[action_name.upper()] = handler_fn

    def _build_snapshot(self):
        sorted_flags = sorted(list(self.narrative.player_flags))
        return {
            "current_era": self.current_era,
            "total_score": self.engine_state.total_score,
            "era_mastery": self.engine_state.era_mastery,
            "active_flags": sorted_flags,
            "sha256_seal": self.state_manager.generate_signature(
                json.dumps(
                    {
                        "era": self.current_era,
                        "score": self.engine_state.total_score,
                        "flags": sorted_flags,
                    },
                    sort_keys=True,
                )
            ),
        }

    def _handle_handshake(self, payload):
        raw = json.dumps({"client_type": payload.get("client_type", "GODOT_4")})
        base = json.loads(self.process_handshake(raw))
        base["engine_version"] = "Phase_8f_OmniDispatcher"
        base["state"] = self._build_snapshot()
        return base

    def _handle_get_state(self, payload):
        return {"status": "OK", "state": self._build_snapshot()}

    def _handle_get_scenario(self, payload):
        scenarios = self.narrative.matrix
        scenario_id = payload.get("scenario_id")
        target = None
        if scenario_id:
            target = next((s for s in scenarios if s.get("id") == scenario_id), None)
        if not target and scenarios:
            target = scenarios[0]
        if not target:
            return {"status": "EMPTY", "error": "No scenarios available in decision_bank.json"}

        filtered = dict(target)
        filtered["options"] = [
            opt for opt in target.get("options", [])
            if opt.get("flag_required") is None or opt.get("flag_required") in self.narrative.player_flags
        ]
        return {"status": "OK", "scenario": filtered}

    def _handle_resolve_decision(self, payload):
        scenarios = self.narrative.matrix
        scenario_id = payload.get("scenario_id", "GEN_001")
        option_index = int(payload.get("option_index", 0))
        scenario = next((s for s in scenarios if s.get("id") == scenario_id), scenarios[0] if scenarios else None)
        if not scenario:
            return {"status": "ERROR", "error": "Scenario not found"}

        valid_options = [
            opt for opt in scenario.get("options", [])
            if opt.get("flag_required") is None or opt.get("flag_required") in self.narrative.player_flags
        ]
        if option_index < 0 or option_index >= len(valid_options):
            return {"status": "ERROR", "error": "Invalid option_index"}

        outcome = self.narrative.resolve_decision(valid_options[option_index])
        if not outcome:
            return {"status": "ERROR", "error": "No outcome resolved"}

        flag = outcome.get("flag")
        if flag:
            self.narrative.player_flags.add(flag)
        self.engine_state.award_points(scenario.get("era", self.current_era))
        return {
            "status": "OK",
            "outcome": outcome,
            "state": self._build_snapshot(),
        }

    def _handle_get_scripture(self, payload):
        challenges = self.scripture_bank.get("challenges", [])
        idx = int(payload.get("index", 0))
        if not challenges:
            return {"status": "EMPTY", "error": "No scripture challenges loaded"}
        idx = idx % len(challenges)
        ch = dict(challenges[idx])
        safe_ch = {k: v for k, v in ch.items() if k != "correct_index"}
        safe_ch["index"] = idx
        safe_ch["total"] = len(challenges)
        return {"status": "OK", "challenge": safe_ch}

    def _handle_submit_scripture(self, payload):
        challenges = self.scripture_bank.get("challenges", [])
        idx = int(payload.get("index", 0)) % len(challenges)
        answer_index = int(payload.get("answer_index", -1))
        ch = challenges[idx]
        correct = answer_index == ch.get("correct_index")
        if correct:
            self.engine_state.award_points(ch.get("era", self.current_era))
        return {
            "status": "OK",
            "correct": correct,
            "explanation": ch.get("explanation", ""),
            "state": self._build_snapshot(),
        }

    def _handle_save_state(self, payload):
        snapshot = self._build_snapshot()
        self.state_manager.save_state(snapshot)
        return {"status": "SAVED", "state": snapshot}

    def dispatch_message(self, raw_message):
        try:
            payload = json.loads(raw_message)
            action = str(payload.get("action", "HANDSHAKE")).upper()
            handler = self.action_handlers.get(action)
            if not handler:
                return json.dumps({"status": "ERROR", "error": f"Unknown action: {action}"})
            return json.dumps(handler(payload))
        except Exception as exc:
            return json.dumps({"status": "ERROR", "error": str(exc)})

    def serve_forever(self, max_requests=None):
        self._running = True
        handled = 0
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as srv:
            srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            srv.bind((self.host, self.port))
            srv.listen(5)
            srv.settimeout(1.0)
            print(f"[HVF OMNI-DISPATCHER] Listening on {self.host}:{self.port} (Godot 4 / UE5 Ready)")
            while self._running:
                if max_requests is not None and handled >= max_requests:
                    break
                try:
                    conn, addr = srv.accept()
                except socket.timeout:
                    continue
                with conn:
                    conn.settimeout(5.0)
                    buffer = b""
                    while b"\n" not in buffer:
                        chunk = conn.recv(4096)
                        if not chunk:
                            break
                        buffer += chunk
                    if buffer:
                        line = buffer.split(b"\n", 1)[0].decode("utf-8", errors="replace").strip()
                        response = self.dispatch_message(line) + "\n"
                        conn.sendall(response.encode("utf-8"))
                        handled += 1


if __name__ == "__main__":
    dispatcher = OmniClientDispatcher()
    dispatcher.serve_forever()