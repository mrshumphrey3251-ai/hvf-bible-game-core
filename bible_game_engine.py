#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: SOVEREIGN BIBLE GAME ENGINE
# AUTHOR: Jeffery Humphrey - CEO / SME
# DOCTRINE: Zero-Dependency, Forward-Compatible, Immutable State
# ==============================================================================

import json
import os
import sys

# --- 1. IMMUTABLE ERA CLASSIFICATIONS ---
class BibleEras:
    TORAH = "ERA_TORAH"
    HISTORY = "ERA_HISTORY"
    WISDOM = "ERA_WISDOM"
    PROPHETS = "ERA_PROPHETS"
    GOSPELS = "ERA_GOSPELS"
    EPISTLES = "ERA_EPISTLES"

    @classmethod
    def get_all_eras(cls):
        return [cls.TORAH, cls.HISTORY, cls.WISDOM, cls.PROPHETS, cls.GOSPELS, cls.EPISTLES]

# --- 2. SECURE ENGINE STATE ---
class GameEngineState:
    def __init__(self):
        self.total_score = 0
        self.era_mastery = {era: 0 for era in BibleEras.get_all_eras()}
        
    def award_points(self, era):
        self.total_score += 100
        if era in self.era_mastery:
            self.era_mastery[era] += 100

# --- 3. SCRIPTURE BANK VALIDATOR ---
class ScriptureBankValidator:
    @staticmethod
    def load_and_validate(json_path):
        fallback_data = {
            "bank_version": "1.0.0",
            "classification": "HVF_SOVEREIGN_SCRIPTURE_BANK_INTERNAL",
            "challenges": [{
                "era": BibleEras.TORAH,
                "reference": "Genesis 1:1",
                "prompt": "In the beginning God created the heavens and the earth.",
                "options": ["True", "False", "Unknown", "None"],
                "correct_index": 0,
                "explanation": "Foundational creation narrative."
            }]
        }
        if not os.path.exists(json_path):
            return fallback_data
        try:
            with open(json_path, 'r') as f:
                data = json.load(f)
            if "bank_version" not in data or "challenges" not in data:
                raise ValueError("Schema invalid.")
            return data
        except:
            return fallback_data

# --- 4. TERMINAL USER INTERFACE (CLI) ---
class GameCLI:
    def __init__(self, state, bank):
        self.state = state
        self.challenges = bank.get("challenges", [])

    def run(self):
        print("\n" + "="*60)
        print(" HVF SOVEREIGN BIBLE GAME - INITIALIZATION SEQUENCE ")
        print("="*60 + "\n")
        
        if not self.challenges:
            print("[!] No challenges loaded. Exiting.")
            return

        for i, challenge in enumerate(self.challenges):
            print(f"--- Challenge {i+1} / {len(self.challenges)} | Era: {challenge['era']} ---")
            print(f"Reference: {challenge['reference']}")
            print(f"Prompt: {challenge['prompt']}\n")
            
            for idx, opt in enumerate(challenge['options']):
                print(f"  {idx + 1}. {opt}")
            
            while True:
                try:
                    choice = int(input("\nEnter your answer (1-4): ")) - 1
                    if 0 <= choice <= 3:
                        break
                    print("Invalid input. Select 1, 2, 3, or 4.")
                except ValueError:
                    print("Invalid input. Numbers only.")

            if choice == challenge['correct_index']:
                print(f"\n[+] CORRECT. {challenge['explanation']}")
                self.state.award_points(challenge['era'])
            else:
                correct_answer = challenge['options'][challenge['correct_index']]
                print(f"\n[-] INCORRECT. The correct answer was: {correct_answer}")
                print(f"Explanation: {challenge['explanation']}")
            
            print("\n" + "-"*60 + "\n")

        self.display_scorecard()

    def display_scorecard(self):
        print("="*60)
        print(" EXECUTIVE SCORECARD ")
        print("="*60)
        print(f"TOTAL SCORE: {self.state.total_score}")
        for era, score in self.state.era_mastery.items():
            if score > 0:
                print(f"{era} MASTERY: {score}")
        print("="*60 + "\n")

if __name__ == "__main__":
    state = GameEngineState()
    bank_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripture_bank.json")
    active_bank = ScriptureBankValidator.load_and_validate(bank_path)
    
    cli = GameCLI(state, active_bank)
    cli.run()
