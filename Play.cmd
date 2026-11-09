@echo off
cd /d "%~dp0"
if exist "tools\godot\Godot_v4.5.1-stable_win64.exe" (
  start "" "tools\godot\Godot_v4.5.1-stable_win64.exe" --path "%~dp0."
) else (
  echo Open project.godot in Godot 4.5.1 or newer and press F5.
  pause
)
