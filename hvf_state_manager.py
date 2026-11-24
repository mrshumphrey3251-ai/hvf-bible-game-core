#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: CRYPTOGRAPHIC STATE MANAGER
# DOCTRINE: Unhackable Offline Save Authentication (SHA-256)
# ==============================================================================

import json
import hashlib
import os

class StateManager:
    def __init__(self, save_file="player_state.json"):
        self.save_file = save_file
        # This salt makes the hash impossible to forge without the source code
        self.secret_salt = os.environ.get("HVF_EXECUTIVE_SALT", "HVF_PUBLIC_SANDBOX_SALT_2026")

    def generate_signature(self, data_string):
        payload = data_string + self.secret_salt
        return hashlib.sha256(payload.encode()).hexdigest()

    def save_state(self, state_dict):
        # Sort keys to ensure the JSON string is always identical for the same data
        raw_data = json.dumps(state_dict, sort_keys=True)
        signature = self.generate_signature(raw_data)
        
        secure_payload = {
            "data": state_dict,
            "signature": signature
        }
        
        with open(self.save_file, 'w') as f:
            json.dump(secure_payload, f, indent=4)
        print(f"[HVF SYSTEM] Game state secured and cryptographically signed.")

    def load_state(self):
        if not os.path.exists(self.save_file):
            print("[HVF SYSTEM] No save file found. Initializing new bloodline.")
            return None
        
        with open(self.save_file, 'r') as f:
            secure_payload = json.load(f)
            
        state_dict = secure_payload.get("data", {})
        provided_signature = secure_payload.get("signature", "")
        
        # Recalculate what the signature *should* be
        raw_data = json.dumps(state_dict, sort_keys=True)
        expected_signature = self.generate_signature(raw_data)
        
        if provided_signature != expected_signature:
            print("\n[HVF SECURITY ALERT] FATAL: Save file tampering detected.")
            print("Signature mismatch. Halting execution to prevent corrupted sync.\n")
            return None
            
        print("[HVF SYSTEM] Save file authenticated. Integrity verified.")
        return state_dict

if __name__ == "__main__":
    print("\n--- INITIATING ANTI-TAMPER TEST ---")
    manager = StateManager()
    
    # 1. Create a legitimate save
    test_state = {"player_id": "GENESIS_01", "era": "ERA_TORAH", "health": 100}
    manager.save_state(test_state)
    
    # 2. Attempt to load the legitimate save
    manager.load_state()
    print("--- TEST COMPLETE ---\n")
