# HVF Sovereign Bible Game Engine ? Multi-Device Deployment Specification

## 1. Dual-Mode Transport Architecture (PC + Mobile + Web)
The Godot 4 client (`frontend_godot/scripts/omni_bridge_client.gd`) supports automatic dual-mode execution with zero UI changes:
1. **Tier 1 ? Live Python C2 TCP Mode (`127.0.0.1:65432` or Remote Relay):**
   - Used on Windows, macOS, and Linux desktops running `hvf_omni_dispatcher.py`, or mobile/tablet clients pointed at a hosted relay endpoint.
2. **Tier 2 ? Standalone Offline Mobile/Web Mirror (`sovereign_offline_mirror.gd`):**
   - Automatically engages on iOS, Android, HTML5/WebAssembly (Chromebooks/browsers), or offline desktop sessions when TCP `65432` is unreachable.
   - Enforces native SHA-256 cryptographic state sealing (`HashingContext.HASH_SHA256`) on `user://player_state.json`.

## 2. Export Targets Configured in `frontend_godot/export_presets.cfg`
- **Windows Desktop (64-bit):** `builds/windows/HVF_Sovereign_Bible_Engine.exe`
- **macOS Universal:** `builds/macos/HVF_Sovereign_Bible_Engine.dmg`
- **Linux x86_64:** `builds/linux/HVF_Sovereign_Bible_Engine.x86_64`
- **Android (ARM64):** `builds/android/HVF_Sovereign_Bible_Engine.apk` (`com.hvf.sovereignbibleengine`)
- **iOS (Xcode / IPA):** `builds/ios/HVF_Sovereign_Bible_Engine.ipa` (`com.hvf.sovereignbibleengine`)
- **Web (HTML5 / WebAssembly):** `builds/web/index.html`
