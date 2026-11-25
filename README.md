# HVF SOVEREIGN BIBLE GAME ENGINE (PHASES 1–13 COMPLETE)
**Chief Architect & CEO:** Jeffery Humphrey — Humphrey Virtual Farms LLC  
**Doctrine:** Zero-Dependency, Offline-First, Cryptographically Sealed, Additive Zero-Rewrite Architecture

## I. Executive Architecture
Bare-metal Python simulation core decoupled from visual clients via a universal JSON TCP Omni-Bridge (`127.0.0.1:65432`), enabling simultaneous **Tier 1 (Unreal Engine 5)** and **Tier 2 (Godot 4 Sovereign Offline Client)** execution.

* `bible_game_engine.py`: Six-era taxonomy (`ERA_TORAH` through `ERA_EPISTLES`), `GameEngineState`, and `ScriptureBankValidator`.
* `narrative_engine.py`: Stochastic Chaos Engine resolving weighted decision matrices (`decision_bank.json`).
* `hvf_state_manager.py`: Offline anti-tamper SHA-256 cryptographic save authentication (`player_state.json`).
* `hvf_3d_bridge.py` & `hvf_omni_dispatcher.py`: Universal TCP JSON router (`127.0.0.1:65432`) with dynamic `register_action()` plugin registry.
* `hvf_bloodline_engine.py` (Phase 9): Generational Bloodline Handoff and infinite Alpha-Omega Loop (`Genesis <-> Revelation`).
* `hvf_covenant_trials.py` (Phase 11): Unified Scripture Mastery Covenant Trials (`COVENANT_SEAL_<ERA>`).
* `hvf_perpetual_pedagogy.py` (Phase 12–13): 10-year anti-memorization engine with cryptographic option shuffling, 4-tier pedagogical mutations, spaced-repetition weighting, and modular `banks/*.json` ingestion.
* `frontend_godot/`: Ready-to-run Godot 4 Sovereign Client (`project.godot`, `scenes/main.tscn`, `scripts/omni_bridge_client.gd`).

## II. Quick-Start Launch Protocol
1. Start the Sovereign Python Omni-Dispatcher: `python hvf_omni_dispatcher.py`
2. Open `frontend_godot/project.godot` in **Godot 4** and press **F5** (Play).

## III. Additive Expansion Protocol (Zero Core Rewrites)
* Drop any valid JSON bank into `banks/*.json` for automatic ingestion on boot.
* Call `dispatcher.register_action("ACTION_NAME", handler_fn)` to mount new modules without touching existing code.