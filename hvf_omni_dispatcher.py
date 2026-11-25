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
        bl_engine = getattr(self, "bloodline_engine", None)
        cov_engine = getattr(self, "covenant_trials", None)
        ped_engine = getattr(self, "perpetual_pedagogy", None)

        bloodline_data = bl_engine.snapshot() if bl_engine else {}
        seals_data = list(cov_engine.covenant_seals) if cov_engine else []
        mastery_data = dict(ped_engine.mastery_ledger) if ped_engine else {}

        seal_payload = {
            "era": self.current_era,
            "score": self.engine_state.total_score,
            "flags": sorted_flags,
            "epoch": bloodline_data.get("epoch_number", 1),
            "generation": bloodline_data.get("generation_number", 1),
            "leader": bloodline_data.get("current_leader", "Adam_Line_01"),
            "seals": seals_data,
            "mastery": mastery_data,
        }
        return {
            "current_era": self.current_era,
            "total_score": self.engine_state.total_score,
            "era_mastery": self.engine_state.era_mastery,
            "active_flags": sorted_flags,
            "bloodline": bloodline_data,
            "covenant_seals": seals_data,
            "mastery_ledger": mastery_data,
            "sha256_seal": self.state_manager.generate_signature(
                json.dumps(seal_payload, sort_keys=True)
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



# --- Phase 15/16 Direct Stronghold Binding (Active Before __main__) ---
try:
    from hvf_dynasty_stronghold import (
        attach_stronghold_to_dispatcher as _hvf_attach_stronghold,
        bind_stronghold_persistence as _hvf_bind_sh_persist,
    )
    _hvf_base_omni_init = OmniClientDispatcher.__init__
    def _hvf_stronghold_omni_init(self, *args, **kwargs):
        _hvf_base_omni_init(self, *args, **kwargs)
        _hvf_attach_stronghold(self)
        _hvf_bind_sh_persist(self)
    OmniClientDispatcher.__init__ = _hvf_stronghold_omni_init
except Exception as _sh_bind_err:
    print(f"[HVF WARNING] Stronghold bind error: {_sh_bind_err}")



# --- Phase 18 Direct Biblical Generals Binding (Active Before __main__) ---
try:
    from hvf_dynasty_generals import attach_generals_to_dispatcher as _hvf_attach_generals
    _hvf_p16_omni_init = OmniClientDispatcher.__init__
    def _hvf_generals_omni_init(self, *args, **kwargs):
        _hvf_p16_omni_init(self, *args, **kwargs)
        _hvf_attach_generals(self)
    OmniClientDispatcher.__init__ = _hvf_generals_omni_init
except Exception as _gen_bind_err:
    print(f"[HVF WARNING] Generals bind error: {_gen_bind_err}")



# --- Phase 21 Adaptive 6-Era Content Pack Merger (Active Before __main__) ---
try:
    def _hvf_merge_phase21_banks(disp_instance):
        banks_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "banks")
        pack_files = [
            os.path.join(banks_dir, fn)
            for fn in sorted(os.listdir(banks_dir))
            if fn.endswith(".json") and "expansion_pack" in fn
        ] if os.path.isdir(banks_dir) else []
        for pack_path in pack_files:
            with open(pack_path, "r", encoding="utf-8") as _pf:
                pack = json.load(_pf)
            _hvf_apply_single_pack(disp_instance, pack)
        return

    def _hvf_apply_single_pack(disp_instance, pack):

        # Merge scenarios into whatever scenario dictionary attribute the engine/dispatcher holds
        new_scenarios = pack.get("scenarios", {})
        for holder in [disp_instance, getattr(disp_instance, "engine", None), getattr(disp_instance, "game_engine", None)]:
            if holder is None:
                continue
            for attr_name in ["decision_bank", "scenarios", "scenario_bank"]:
                target = getattr(holder, attr_name, None)
                if isinstance(target, dict):
                    if "scenarios" in target and isinstance(target["scenarios"], dict):
                        target["scenarios"].update(new_scenarios)
                    else:
                        target.update(new_scenarios)

        # Merge scripture trials into unified_challenges (supports both list and dict pools)
        ct = getattr(disp_instance, "covenant_trials", None)
        if ct is not None:
            pool = getattr(ct, "unified_challenges", None)
            new_trials = pack.get("scripture_trials", [])
            if isinstance(pool, list):
                existing_ids = {item.get("id") for item in pool if isinstance(item, dict)}
                for tr in new_trials:
                    if tr.get("id") not in existing_ids:
                        pool.append(tr)
            elif isinstance(pool, dict):
                for tr in new_trials:
                    if tr.get("id") not in pool:
                        pool[tr["id"]] = tr

    _hvf_p18_omni_init = OmniClientDispatcher.__init__
    def _hvf_phase21_omni_init(self, *args, **kwargs):
        _hvf_p18_omni_init(self, *args, **kwargs)
        _hvf_merge_phase21_banks(self)
    OmniClientDispatcher.__init__ = _hvf_phase21_omni_init
except Exception as _p21_err:
    print(f"[HVF WARNING] Phase 21 bank merge skipped: {_p21_err}")



# --- Phase 23 Direct Institutional EdTech Exporter Binding (Active Before __main__) ---
try:
    from hvf_edtech_exporter import attach_edtech_exporter_to_dispatcher as _hvf_attach_edtech
    _hvf_p21_omni_init = OmniClientDispatcher.__init__
    def _hvf_phase23_omni_init(self, *args, **kwargs):
        _hvf_p21_omni_init(self, *args, **kwargs)
        _hvf_attach_edtech(self)
    OmniClientDispatcher.__init__ = _hvf_phase23_omni_init
except Exception as _p23_err:
    print(f"[HVF WARNING] Phase 23 EdTech exporter bind skipped: {_p23_err}")


if __name__ == "__main__":
    dispatcher = OmniClientDispatcher()
    dispatcher.serve_forever()

# --- PHASE 33: THREAD-SAFE MULTIPLAYER PILGRIM ROOM RELAY ---
import threading as _mp_threading
import time as _mp_time

_MP_LOCK = _mp_threading.Lock()
_MP_PILGRIMS = {}
_MP_CHAT_LOG = []

def handle_multiplayer_packet(payload: dict) -> dict:
    action = str(payload.get("action", "")).upper()
        if action.startswith("MULTIPLAYER_"):
            return handle_multiplayer_packet(payload)
    now = _mp_time.time()
    pid = str(payload.get("player_id", "")).strip() or "PILGRIM_ANON"
    pname = str(payload.get("name", "Pilgrim")).strip()[:24] or "Pilgrim"
    stage = str(payload.get("stage", "ERA_TORAH")).strip()
    px = float(payload.get("x", 220.0))
    py = float(payload.get("y", 145.0))
    chat_text = str(payload.get("message", "")).strip()[:140]

    with _MP_LOCK:
        # Prune inactive pilgrims (>25 seconds without heartbeat)
        stale = [k for k, v in _MP_PILGRIMS.items() if (now - v.get("last_seen", 0.0)) > 25.0]
        for k in stale:
            del _MP_PILGRIMS[k]

        if action == "MULTIPLAYER_LEAVE":
            _MP_PILGRIMS.pop(pid, None)
        else:
            _MP_PILGRIMS[pid] = {
                "player_id": pid,
                "name": pname,
                "stage": stage,
                "x": round(px, 1),
                "y": round(py, 1),
                "last_seen": now,
            }

        if action == "MULTIPLAYER_CHAT" and chat_text:
            _MP_CHAT_LOG.append({
                "sender": pname,
                "stage": stage,
                "message": chat_text,
                "ts": round(now, 2),
            })
            if len(_MP_CHAT_LOG) > 15:
                del _MP_CHAT_LOG[:-15]

        peers = [v for k, v in _MP_PILGRIMS.items() if k != pid]
        return {
            "status": "OK",
            "action": action,
            "online_count": len(_MP_PILGRIMS),
            "peers": peers,
            "chat_log": list(_MP_CHAT_LOG[-6:]),
        }
