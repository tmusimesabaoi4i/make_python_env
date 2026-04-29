@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "ENV_NAME="
set "ENV_DIR="
set "REQ_FILE=%~dp0requirements_basic.txt"
set "PYTHON_CMD="
set "PROXY="

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
if /I "%~1"=="--requirements" (
    set "REQ_FILE=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--python" (
    set "PYTHON_CMD=%~2"
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
if /I "%~1"=="--help" goto help
echo [ERROR] Unknown option: %~1
goto help

:parsed
if not defined ENV_NAME (
    echo [ERROR] --name is required.
    goto help
)

if not defined ENV_DIR set "ENV_DIR=%CD%\%ENV_NAME%"

if not defined PYTHON_CMD (
    where py >nul 2>nul
    if not errorlevel 1 (
        set "PYTHON_CMD=py -3"
    ) else (
        where python >nul 2>nul
        if errorlevel 1 (
            echo [ERROR] Python was not found. Install Python first or add it to PATH.
            exit /b 1
        )
        set "PYTHON_CMD=python"
    )
)

set "PIP_PROXY_OPT="
if defined PROXY set "PIP_PROXY_OPT=--proxy %PROXY%"

echo.
echo ============================================================
echo Create Python virtual environment
echo   Name  : %ENV_NAME%
echo   Path  : %ENV_DIR%
echo   Req   : %REQ_FILE%
if defined PROXY echo   Proxy : %PROXY%
echo ============================================================
echo.

if exist "%ENV_DIR%\Scripts\python.exe" (
    echo [ERROR] The virtual environment already exists:
    echo         %ENV_DIR%
    echo.
    echo To update it, run:
    echo   update_env.bat --name %ENV_NAME%
    exit /b 1
)

%PYTHON_CMD% -m venv "%ENV_DIR%"
if errorlevel 1 (
    echo [ERROR] Failed to create virtual environment.
    exit /b 1
)

set "VENV_PY=%ENV_DIR%\Scripts\python.exe"

"%VENV_PY%" -m pip install --upgrade %PIP_PROXY_OPT% pip setuptools wheel
if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip/setuptools/wheel.
    exit /b 1
)

if exist "%REQ_FILE%" (
    "%VENV_PY%" -m pip install --upgrade %PIP_PROXY_OPT% -r "%REQ_FILE%"
) else (
    echo [WARN] requirements_basic.txt was not found. Installing fallback packages.
    "%VENV_PY%" -m pip install --upgrade %PIP_PROXY_OPT% requests beautifulsoup4 lxml tqdm python-dotenv tenacity pandas numpy openpyxl xlsxwriter duckdb pyarrow matplotlib jinja2 markdownify pypdf pymupdf pdfplumber python-docx python-pptx ipykernel jupyterlab
)

if errorlevel 1 (
    echo [ERROR] Failed to install one or more packages.
    exit /b 1
)

"%VENV_PY%" -m ipykernel install --user --name "%ENV_NAME%" --display-name "Python (%ENV_NAME%)" >nul 2>nul
if errorlevel 1 (
    echo [WARN] Jupyter kernel registration was skipped or failed.
)

echo.
echo [OK] Environment created successfully.
echo.
echo Activate:
echo   "%ENV_DIR%\Scripts\activate.bat"
echo.
echo Python:
echo   "%VENV_PY%"
echo.
exit /b 0

:help
echo.
echo Usage:
echo   make_env.bat --name ENV_NAME
echo.
echo Options:
echo   --name ENV_NAME              Required. Virtual environment name.
echo   --dir  PATH                  Optional. Environment path. Default: current folder\ENV_NAME
echo   --requirements PATH          Optional. Requirements file. Default: requirements_basic.txt next to this bat.
echo   --python "COMMAND"           Optional. Python command. Example: "py -3.12" or "C:\Python312\python.exe"
echo   --proxy URL                  Optional. Proxy URL for pip. Example: http://proxy.example.com:8080
echo.
echo Examples:
echo   make_env.bat --name YYY
echo   make_env.bat --name YYY --dir C:\work\venvs\YYY
echo   make_env.bat --name YYY --python "py -3.12"
echo   make_env.bat --name YYY --proxy http://proxy.example.com:8080
echo.
exit /b 1
