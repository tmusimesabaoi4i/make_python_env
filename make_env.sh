#!/usr/bin/env bash
set -euo pipefail

ENV_NAME=""
ENV_DIR=""
REQ_FILE="$(cd "$(dirname "$0")" && pwd)/requirements_basic.txt"
PYTHON_CMD=""

usage() {
  cat <<'EOF'
Usage:
  ./make_env.sh --name ENV_NAME

Options:
  --name ENV_NAME       Required. Virtual environment name.
  --dir PATH            Optional. Environment path. Default: current folder/ENV_NAME
  --requirements PATH   Optional. Requirements file.
  --python COMMAND      Optional. Python command. Example: python3.12

Examples:
  ./make_env.sh --name YYY
  ./make_env.sh --name YYY --dir ~/venvs/YYY
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) ENV_NAME="${2:-}"; shift 2 ;;
    --dir) ENV_DIR="${2:-}"; shift 2 ;;
    --requirements) REQ_FILE="${2:-}"; shift 2 ;;
    --python) PYTHON_CMD="${2:-}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "[ERROR] Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$ENV_NAME" ]]; then
  echo "[ERROR] --name is required."
  usage
  exit 1
fi

if [[ -z "$ENV_DIR" ]]; then
  ENV_DIR="$PWD/$ENV_NAME"
fi

if [[ -z "$PYTHON_CMD" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
  elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
  else
    echo "[ERROR] Python was not found."
    exit 1
  fi
fi

echo "Create venv: $ENV_DIR"

if [[ -x "$ENV_DIR/bin/python" ]]; then
  echo "[ERROR] The virtual environment already exists: $ENV_DIR"
  exit 1
fi

$PYTHON_CMD -m venv "$ENV_DIR"
"$ENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel

if [[ -f "$REQ_FILE" ]]; then
  "$ENV_DIR/bin/python" -m pip install --upgrade -r "$REQ_FILE"
else
  "$ENV_DIR/bin/python" -m pip install --upgrade requests beautifulsoup4 lxml tqdm python-dotenv tenacity pandas numpy openpyxl xlsxwriter duckdb pyarrow matplotlib jinja2 markdownify pypdf pymupdf pdfplumber python-docx python-pptx ipykernel jupyterlab
fi

"$ENV_DIR/bin/python" -m ipykernel install --user --name "$ENV_NAME" --display-name "Python ($ENV_NAME)" >/dev/null 2>&1 || true

echo "[OK] Environment created."
echo "Activate:"
echo "  source \"$ENV_DIR/bin/activate\""
