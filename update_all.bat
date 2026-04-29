@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%CD%"
set "INCLUDE_GLOBAL=0"
set "SKIP_PYTHON=0"
set "PROXY="

:parse_args
if "%~1"=="" goto parsed
if /I "%~1"=="--root" (
    set "ROOT=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--include-global" (
    set "INCLUDE_GLOBAL=1"
    shift
    goto parse_args
)
if /I "%~1"=="--skip-python" (
    set "SKIP_PYTHON=1"
    shift
    goto parse_args
)
if /I "%~1"=="--proxy" (
    set "PROXY=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--help" goto help
echo [ERROR] Unknown option: %~1
goto help

:parsed
set "PIP_PROXY_OPT="
set "PROXY_ARG="
if defined PROXY (
    set "PIP_PROXY_OPT=--proxy %PROXY%"
    set "PROXY_ARG=--proxy %PROXY%"
)

echo.
echo ============================================================
echo Update Python itself if possible, then update all venvs
echo   Root           : %ROOT%
echo   Include global : %INCLUDE_GLOBAL%
if defined PROXY echo   Proxy          : %PROXY%
echo ============================================================
echo.

if "%SKIP_PYTHON%"=="0" call :update_python

if "%INCLUDE_GLOBAL%"=="1" call :update_global_user_packages

echo.
echo Searching virtual environments under:
echo   %ROOT%
echo.

set "FOUND=0"

for /d %%D in ("%ROOT%\*") do (
    if exist "%%~fD\Scripts\python.exe" (
        set "FOUND=1"
        echo.
        echo ------------------------------------------------------------
        echo Updating venv: %%~nxD
        echo ------------------------------------------------------------
        call "%~dp0update_env.bat" --name "%%~nxD" --dir "%%~fD" %PROXY_ARG%
    )
)

if "%FOUND%"=="0" (
    echo [WARN] No virtual environments were found under:
    echo        %ROOT%
    echo.
    echo A target folder must contain:
    echo        Scripts\python.exe
)

echo.
echo [OK] update_all finished.
echo.
exit /b 0

:update_python
echo.
echo ------------------------------------------------------------
echo Step 1: Update Python itself when winget is available
echo ------------------------------------------------------------
where winget >nul 2>nul
if errorlevel 1 (
    echo [WARN] winget was not found. Python itself was not updated.
    echo        Please update Python manually if required.
    exit /b 0
)

echo winget found. Trying to update Python...
winget source update >nul 2>nul

winget upgrade --id Python.Python.3 --silent --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo [WARN] Exact winget package id did not update. Trying query-based Python update...
    winget upgrade --query "Python" --silent --accept-source-agreements --accept-package-agreements
    if errorlevel 1 (
        echo [WARN] Python update by winget failed or was not applicable.
        echo        This is common on managed corporate PCs.
    )
)
exit /b 0

:update_global_user_packages
echo.
echo ------------------------------------------------------------
echo Step 2: Update global user-site packages
echo ------------------------------------------------------------

where py >nul 2>nul
if not errorlevel 1 (
    set "BASE_PY=py -3"
) else (
    where python >nul 2>nul
    if errorlevel 1 (
        echo [WARN] Python was not found in PATH. Skipping global package update.
        exit /b 0
    )
    set "BASE_PY=python"
)

%BASE_PY% -m pip install --user --upgrade %PIP_PROXY_OPT% pip setuptools wheel
for /f "skip=2 tokens=1" %%P in ('%BASE_PY% -m pip list --user %PIP_PROXY_OPT% --outdated 2^>nul') do (
    echo Updating global user package %%P ...
    %BASE_PY% -m pip install --user --upgrade %PIP_PROXY_OPT% "%%P"
)
exit /b 0

:help
echo.
echo Usage:
echo   update_all.bat
echo.
echo Options:
echo   --root PATH          Optional. Folder containing venv folders. Default: current folder.
echo   --include-global     Optional. Also update global user-site packages.
echo   --skip-python        Optional. Skip Python executable update attempt.
echo   --proxy URL          Optional. Proxy URL for pip. Example: http://proxy.example.com:8080
echo.
echo Examples:
echo   update_all.bat
echo   update_all.bat --root C:\work\venvs
echo   update_all.bat --include-global
echo   update_all.bat --skip-python
echo   update_all.bat --proxy http://proxy.example.com:8080
echo.
exit /b 1
