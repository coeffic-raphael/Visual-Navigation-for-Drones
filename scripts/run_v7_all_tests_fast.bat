@echo off
setlocal

REM ============================================================
REM Fast preview runner for V7 Spread Consistency.
REM Writes to outputs\realtime_fast\ so final outputs\realtime\ are not overwritten.
REM Extra arguments are passed through, for example:
REM   scripts\run_v7_all_tests_fast.bat --only DJI_Test1_100m
REM ============================================================

cd /d "%~dp0\.."

if exist ".venv-anyloc\Scripts\activate.bat" (
    call ".venv-anyloc\Scripts\activate.bat"
) else (
    echo ERROR: .venv-anyloc was not found.
    exit /b 1
)

python tools\run_v7_all_tests_fast.py %*

endlocal
