#!/usr/bin/env python3
import json
import os
import random

class NarrativeEngine:
    def __init__(self, data_file="decision_bank.json"):
        self.data_file = data_file
        self.player_flags = set()
        self.matrix = self.load_data()

    def load_data(self):
        if not os.path.exists(self.data_file):
            return []
        with open(self.data_file, 'r') as f:
            data = json.load(f)
            return data.get("scenarios", [])

    def resolve_decision(self, option):
        # The Chaos Engine: Roll weighted probabilities
        outcomes = option.get("outcomes", [])
        if not outcomes:
            return None
        
        total_weight = sum(o["weight"] for o in outcomes)
        roll = random.uniform(0, total_weight)
        
        current = 0
        for outcome in outcomes:
            current += outcome["weight"]
            if roll <= current:
                return outcome
        return outcomes[-1]

    def run(self):
        print("\n============================================================")
        print(" HVF STOCHASTIC NARRATIVE ENGINE - UNPREDICTABLE MODE ")
        print("============================================================\n")
        
        for scenario in self.matrix:
            print(f"--- ERA: {scenario['era']} | EVENT: {scenario['id']} ---")
            print(f"Context: {scenario['context']}")
            print(f"Decision: {scenario['prompt']}\n")
            
            valid_options = []
            for opt in scenario['options']:
                req_flag = opt.get('flag_required')
                if req_flag is None or req_flag in self.player_flags:
                    valid_options.append(opt)
            
            for idx, opt in enumerate(valid_options):
                print(f"  {idx + 1}. {opt['text']}")
            
            while True:
                try:
                    choice = int(input("\nEnter your executive decision: ")) - 1
                    if 0 <= choice < len(valid_options):
                        break
                    print("Invalid input. Select a valid number.")
                except ValueError:
                    print("Invalid input. Numbers only.")
            
            selected_option = valid_options[choice]
            
            # Execute the Chaos Roll
            result = self.resolve_decision(selected_option)
            if result:
                print(f"\n[SYSTEM: ROLLING HIDDEN PROBABILITIES...]")
                print(f"Outcome Reality: {result['text']}")
                if result.get("flag"):
                    self.player_flags.add(result["flag"])
                    print(f"Consequence Locked -> Trait Acquired: {result['flag']}")
            
            print("\n" + "-"*60 + "\n")

if __name__ == "__main__":
    engine = NarrativeEngine()
    engine.run()
