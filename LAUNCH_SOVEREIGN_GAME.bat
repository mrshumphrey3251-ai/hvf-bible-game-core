@echo off
title HVF Sovereign Bible Game Engine - Launcher
cd /d "%~dp0"

echo ============================================================================
echo   HVF SOVEREIGN BIBLE GAME ENGINE // STARTING OMNI-BRIDGE & GODOT 4 CLIENT
echo ============================================================================

start "HVF Omni-Client Dispatcher (127.0.0.1:65432)" cmd /k "python hvf_omni_dispatcher.py"
timeout /t 2 /nobreak >nul

if exist "C:\hvf_c2\tools\godot\Godot_v4.exe" (
    start "" "C:\hvf_c2\tools\godot\Godot_v4.exe" --path "%~dp0frontend_godot"
) else (
    echo [!] Godot_v4.exe not found at C:\hvf_c2\tools\godot\Godot_v4.exe
    pause
)