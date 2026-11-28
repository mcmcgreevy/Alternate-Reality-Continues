@echo off
setlocal
cd /d "%~dp0"
rem Keep manual sprint saves separate from both the original game and automated tests.
set "APPDATA=%~dp0tools\appdata-sprint-playtest"
if not exist "%APPDATA%" mkdir "%APPDATA%"
set "SPRINT_GODOT=%~dp0tools\godot\Godot_v4.5.1-stable_win64.exe"
if not exist "%SPRINT_GODOT%" set "SPRINT_GODOT=%~dp0..\..\..\tools\godot\Godot_v4.5.1-stable_win64.exe"
if not exist "%SPRINT_GODOT%" (
  echo Godot was not found. Place Godot 4.5.1 in this checkout's tools\godot folder.
  pause
  exit /b 1
)
start "Alternate Reality sprint playtest" "%SPRINT_GODOT%" --path "%~dp0."
endlocal
