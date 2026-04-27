@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "ENV_NAME="
set "ENV_DIR="

:parse_args
if "%~1"=="" goto parsed
if /I "%~1"=="--name" (
    set "ENV_NAME=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--dir" (
    set "ENV_DIR=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--help" goto help
echo [ERROR] Unknown option: %~1
goto help

:parsed
if not defined ENV_NAME (
    echo [ERROR] --name is required.
    goto help
)

if not defined ENV_DIR set "ENV_DIR=%CD%\%ENV_NAME%"
set "VENV_PY=%ENV_DIR%\Scripts\python.exe"

if not exist "%VENV_PY%" (
    echo [ERROR] Virtual environment was not found:
    echo         %ENV_DIR%
    echo.
    echo Create it first:
    echo   make_env.bat --name %ENV_NAME%
    exit /b 1
)

echo.
echo ============================================================
echo Update Python packages in virtual environment
echo   Name : %ENV_NAME%
echo   Path : %ENV_DIR%
echo ============================================================
echo.

"%VENV_PY%" -m pip install --upgrade pip setuptools wheel
if errorlevel 1 (
    echo [ERROR] Failed to update pip/setuptools/wheel.
    exit /b 1
)

echo.
echo Checking outdated packages...
echo.

set "UPDATED_COUNT=0"

for /f "skip=2 tokens=1" %%P in ('"%VENV_PY%" -m pip list --outdated 2^>nul') do (
    echo Updating %%P ...
    "%VENV_PY%" -m pip install --upgrade "%%P"
    if errorlevel 1 (
        echo [WARN] Failed to update %%P
    ) else (
        set /a UPDATED_COUNT+=1
    )
)

echo.
"%VENV_PY%" -m pip check
if errorlevel 1 (
    echo [WARN] pip check found dependency warnings. Review the messages above.
) else (
    echo [OK] Dependency check passed.
)

echo.
echo [OK] Update finished. Updated packages: !UPDATED_COUNT!
echo.
exit /b 0

:help
echo.
echo Usage:
echo   update_env.bat --name ENV_NAME
echo.
echo Options:
echo   --name ENV_NAME     Required. Virtual environment name.
echo   --dir  PATH         Optional. Environment path. Default: current folder\ENV_NAME
echo.
echo Examples:
echo   update_env.bat --name YYY
echo   update_env.bat --name YYY --dir C:\work\venvs\YYY
echo.
exit /b 1
