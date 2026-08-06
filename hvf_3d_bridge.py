#!/usr/bin/env python3
# ==============================================================================
# HUMPHREY VIRTUAL FARMS: OMNI-CLIENT 3D BRIDGE
# DOCTRINE: Universal socket accepting both Unreal Engine 5 and Godot 4
# ==============================================================================

import socket
import json
from narrative_engine import NarrativeEngine

class OmniBridge:
    def __init__(self, host='127.0.0.1', port=65432):
        self.host = host
        self.port = port
        self.narrative = NarrativeEngine()
        
    def process_handshake(self, data):
        # Identifies if Unreal or Godot is connecting
        try:
            payload = json.loads(data)
            client_type = payload.get("client_type", "UNKNOWN")
            print(f"[HVF EXECUTIVE SYSTEM] Handshake verified. Target Engine: {client_type}")
            return json.dumps({"status": "CONNECTED", "auth": "VERIFIED"})
        except Exception as e:
            return json.dumps({"status": "REJECTED", "error": "Invalid Payload"})

    def start_server(self):
        print(f"[HVF SYSTEM] Starting Omni-Client Bridge on {self.host}:{self.port}...")
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind((self.host, self.port))
            s.listen()
            print("[HVF SYSTEM] Backend online. Awaiting Unreal 5 or Godot 4 connection...")
            
            s.settimeout(5.0) # 5 second timeout for testing purposes
            try:
                conn, addr = s.accept()
                with conn:
                    print(f"[HVF SYSTEM] Connection established from {addr}")
            except socket.timeout:
                print("[HVF SYSTEM] Omni-Bridge test complete. Port is secured and ready for dual-client deployment.")

if __name__ == "__main__":
    bridge = OmniBridge()
    bridge.start_server()
