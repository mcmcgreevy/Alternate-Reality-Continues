@echo off
setlocal
cd /d "%~dp0"
set "APPDATA=%~dp0tools\appdata-s108-playtest"
if not exist "%APPDATA%" mkdir "%APPDATA%"
set "S108_ENGINE=%~dp0tools\godot\Godot_v4.5.1-stable_win64_console.exe"
if not exist "%S108_ENGINE%" set "S108_ENGINE=%~dp0..\..\..\tools\godot\Godot_v4.5.1-stable_win64_console.exe"
if not exist "%S108_ENGINE%" (
  echo Godot 4.5.1 was not found in tools\godot.
  pause
  exit /b 1
)
echo Close any running S108 game before continuing.
echo 0: Resume existing S108 test save without replacing it.
echo 1-6: Three new doorways, each approached from both sides.
echo 7-8: Restored wall, approached from both sides.
echo Selecting 1-8 REPLACES ONLY the isolated S108 test save.
echo Your regular and previous sprint saves are untouched.
choice /c 012345678 /n /m "Choose checkpoint or resume: "
set /a "S108_CHECKPOINT=%ERRORLEVEL%-1"
if %S108_CHECKPOINT% LSS 0 exit /b 1
if %S108_CHECKPOINT% GTR 8 exit /b 1
if not "%S108_CHECKPOINT%"=="0" (
  "%S108_ENGINE%" --headless --path "%~dp0." --script tools/prepare_s108_playtest.gd -- %S108_CHECKPOINT%
  if errorlevel 1 (
    pause
    exit /b 1
  )
)
echo Press F9 in game to load the test save.
start "S108 isolated playtest" "%S108_ENGINE%" --path "%~dp0."
endlocal
