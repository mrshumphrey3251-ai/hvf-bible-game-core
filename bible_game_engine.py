#!/usr/bin/env python3
import uuid, time, json, os
from typing import Dict, List, Optional, Any

class BiblicalEra:
    TORAH = "ERA_TORAH"
    HISTORY = "ERA_HISTORY"
    WISDOM = "ERA_WISDOM"
    PROPHETS = "ERA_PROPHETS"
    GOSPELS = "ERA_GOSPELS"
    EPISTLES = "ERA_EPISTLES"

class ScriptureChallenge:
    def __init__(self, era: str, reference: str, prompt: str, options: List[str], correct_index: int, explanation: str):
        self.challenge_id = str(uuid.uuid4())
        self.era = era
        self.reference = reference
        self.prompt = prompt
        self.options = options
        self.correct_index = correct_index
        self.explanation = explanation

    def evaluate_answer(self, player_choice_index: int) -> Dict[str, Any]:
        is_correct = (player_choice_index == self.correct_index)
        return {
            "challenge_id": self.challenge_id,
            "reference": self.reference,
            "era": self.era,
            "is_correct": is_correct,
            "correct_answer": self.options[self.correct_index],
            "explanation": self.explanation
        }

class PlayerProfile:
    def __init__(self, player_name: str):
        self.player_id = str(uuid.uuid4())
        self.player_name = player_name
        self.total_score = 0
        self.challenges_completed = 0
        self.era_mastery: Dict[str, int] = {
            BiblicalEra.TORAH: 0, BiblicalEra.HISTORY: 0, BiblicalEra.WISDOM: 0,
            BiblicalEra.PROPHETS: 0, BiblicalEra.GOSPELS: 0, BiblicalEra.EPISTLES: 0
        }

    def record_victory(self, era: str, points: int = 100) -> None:
        self.total_score += points
        self.challenges_completed += 1
        if era in self.era_mastery:
            self.era_mastery[era] += points

class BibleGameEngine:
    def __init__(self, bank_path: str = "scripture_mastery_bank.json"):
        self.engine_id = str(uuid.uuid4())
        self.question_bank: Dict[str, ScriptureChallenge] = {}
        self.active_players: Dict[str, PlayerProfile] = {}
        self.bank_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), bank_path)
        self._ingest_question_bank()

    def _ingest_question_bank(self) -> None:
        if os.path.exists(self.bank_path):
            try:
                with open(self.bank_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                for item in data.get("challenges", []):
                    ch = ScriptureChallenge(
                        era=item["era"], reference=item["reference"], prompt=item["prompt"],
                        options=item["options"], correct_index=item["correct_index"], explanation=item["explanation"]
                    )
                    self.register_challenge(ch)
                print(f"[+] Successfully ingested external bank: {self.bank_path}")
                return
            except Exception as e:
                print(f"[!] Warning: External bank ingestion failed ({e}). Falling back to internal defaults.")
        else:
            print(f"[!] Notice: External bank {self.bank_path} not found. Loading internal defaults.")
        self._load_fallback_defaults()

    def _load_fallback_defaults(self) -> None:
        q1 = ScriptureChallenge(BiblicalEra.TORAH, "Genesis 1:3", "What was created first?", ["Firmament", "Light", "Earth", "Water"], 1, "God said let there be light.")
        self.register_challenge(q1)

    def register_challenge(self, challenge: ScriptureChallenge) -> str:
        self.question_bank[challenge.challenge_id] = challenge
        return challenge.challenge_id

    def register_player(self, player_name: str) -> PlayerProfile:
        player = PlayerProfile(player_name)
        self.active_players[player.player_id] = player
        return player

    def execute_round(self, player_id: str, challenge_id: str, selected_index: int) -> Dict[str, Any]:
        if player_id not in self.active_players or challenge_id not in self.question_bank:
            raise ValueError("Invalid Player ID or Challenge ID.")
        player = self.active_players[player_id]
        challenge = self.question_bank[challenge_id]
        result = challenge.evaluate_answer(selected_index)
        if result["is_correct"]:
            player.record_victory(challenge.era, points=100)
        else:
            player.challenges_completed += 1
        result["player_score"] = player.total_score
        result["player_name"] = player.player_name
        return result

    def generate_executive_scorecard(self, player_id: str) -> str:
        player = self.active_players[player_id]
        lines = [
            "\n=========================================================================",
            "                 EXECUTIVE SCRIPTURE MASTERY SCORECARD                   ",
            "=========================================================================",
            f" Player Name:         {player.player_name}",
            f" Total Score:         {player.total_score} PTS",
            f" Challenges Solved:   {player.challenges_completed} / {len(self.question_bank)}",
            "-------------------------------------------------------------------------",
            " ERA PROFICIENCY BREAKDOWN:",
            f"  [+] TORAH (Law):        {player.era_mastery[BiblicalEra.TORAH]} PTS",
            f"  [+] HISTORY:            {player.era_mastery[BiblicalEra.HISTORY]} PTS",
            f"  [+] WISDOM:             {player.era_mastery[BiblicalEra.WISDOM]} PTS",
            f"  [+] PROPHETS:           {player.era_mastery[BiblicalEra.PROPHETS]} PTS",
            f"  [+] GOSPELS:            {player.era_mastery[BiblicalEra.GOSPELS]} PTS",
            f"  [+] EPISTLES:           {player.era_mastery[BiblicalEra.EPISTLES]} PTS",
            "=========================================================================\n"
        ]
        return "\n".join(lines)

if __name__ == "__main__":
    print("=========================================================================")
    print("      HVF SOVEREIGN BIBLE GAME ENGINE (PHASE 8F - LIVE EXECUTION)        ")
    print("=========================================================================")
    engine = BibleGameEngine()
    player_name = input("\n[>] Enter Executive Credentials (Player Name): ")
    if not player_name.strip():
        player_name = "Jeffery Humphrey [CEO]"
    active_player = engine.register_player(player_name)
    print(f"\n[+] Player Registered: {active_player.player_name}")
    print(f"[+] Question Bank Loaded: {len(engine.question_bank)} Immutable Scripture Challenges\n")
    print("Initiating Live Sequence. Type 1, 2, 3, or 4 for your answer.\n")
    
    for cid, challenge in engine.question_bank.items():
        print("-------------------------------------------------------------------------")
        print(f"ERA: {challenge.era} | REFERENCE: {challenge.reference}")
        print(f"PROMPT: {challenge.prompt}\n")
        for i, option in enumerate(challenge.options):
            print(f"  {i + 1}. {option}")
        while True:
            try:
                choice = input("\n[>] Select Option (1-4): ")
                choice_idx = int(choice) - 1
                if 0 <= choice_idx <= 3:
                    break
                else:
                    print("[!] Invalid selection. Enter a number between 1 and 4.")
            except ValueError:
                print("[!] Invalid input. Enter a number between 1 and 4.")
        outcome = engine.execute_round(active_player.player_id, cid, choice_idx)
        if outcome["is_correct"]:
            print(f"\n[+] CORRECT! Awarded 100 PTS.")
        else:
            print(f"\n[-] INCORRECT.")
        print(f"[*] The correct answer was: {outcome['correct_answer']}")
        print(f"[*] EXPLANATION: {outcome['explanation']}")
        time.sleep(1)

    print(engine.generate_executive_scorecard(active_player.player_id))
    print("[+] Engine Execution Terminated Safely.")
