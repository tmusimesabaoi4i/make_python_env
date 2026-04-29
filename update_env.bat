@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "ENV_NAME="
set "ENV_DIR="
set "PROXY="
set "PROXY_USER="
set "PROXY_PWD="

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
if /I "%~1"=="--proxy" (
    set "PROXY=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--user" (
    set "PROXY_USER=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--pwd" (
    set "PROXY_PWD=%~2"
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

set "PIP_PROXY_OPT="
set "PROXY_DISPLAY="
if defined PROXY (
    if defined PROXY_USER (
        for /f "tokens=1,2 delims=/" %%A in ("!PROXY!") do (
            set "PROTO=%%A"
            set "REST=%%B"
        )
        set "REST=!REST:~1!"
        set "FULL_PROXY=!PROTO!//!PROXY_USER!:!PROXY_PWD!@!REST!"
        set "PIP_PROXY_OPT=--proxy !FULL_PROXY!"
        set "PROXY_DISPLAY=!PROTO!//!PROXY_USER!:****@!REST!"
    ) else (
        set "PIP_PROXY_OPT=--proxy %PROXY%"
        set "PROXY_DISPLAY=%PROXY%"
    )
)

echo.
echo ============================================================
echo Update Python packages in virtual environment
echo   Name  : %ENV_NAME%
echo   Path  : %ENV_DIR%
if defined PROXY echo   Proxy : !PROXY_DISPLAY!
echo ============================================================
echo.

"%VENV_PY%" -m pip install --upgrade %PIP_PROXY_OPT% pip setuptools wheel
if errorlevel 1 (
    echo [ERROR] Failed to update pip/setuptools/wheel.
    exit /b 1
)

echo.
echo Checking outdated packages...
echo.

set "UPDATED_COUNT=0"

for /f "skip=2 tokens=1" %%P in ('"%VENV_PY%" -m pip list %PIP_PROXY_OPT% --outdated 2^>nul') do (
    echo Updating %%P ...
    "%VENV_PY%" -m pip install --upgrade %PIP_PROXY_OPT% "%%P"
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
echo   --proxy URL         Optional. Proxy URL for pip. Example: http://proxy.example.com:8080
echo   --user USERNAME     Optional. Proxy username. Example: DOMAIN\username
echo   --pwd PASSWORD      Optional. Proxy password.
echo.
echo Examples:
echo   update_env.bat --name YYY
echo   update_env.bat --name YYY --dir C:\work\venvs\YYY
echo   update_env.bat --name YYY --proxy http://proxy.example.com:8080
echo   update_env.bat --name YYY --proxy http://proxy.example.com:8080 --user DOMAIN\user --pwd secret
echo.
exit /b 1
