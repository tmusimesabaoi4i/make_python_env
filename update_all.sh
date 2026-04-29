#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
INCLUDE_GLOBAL=0
SKIP_PYTHON=0
PROXY=""
PROXY_USER=""
PROXY_PWD=""

usage() {
  cat <<'EOF'
Usage:
  ./update_all.sh

Options:
  --root PATH          Optional. Folder containing venv folders. Default: current folder.
  --include-global     Optional. Also update global user-site packages.
  --skip-python        Optional. Skip Python executable update attempt.
  --proxy URL          Optional. Proxy URL for pip. Example: http://proxy.example.com:8080
  --user USERNAME      Optional. Proxy username. Example: DOMAIN\\username
  --pwd PASSWORD       Optional. Proxy password.

Examples:
  ./update_all.sh
  ./update_all.sh --root ~/venvs
  ./update_all.sh --include-global
  ./update_all.sh --proxy http://proxy.example.com:8080
  ./update_all.sh --proxy http://proxy.example.com:8080 --user 'DOMAIN\user' --pwd secret
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    --include-global) INCLUDE_GLOBAL=1; shift ;;
    --skip-python) SKIP_PYTHON=1; shift ;;
    --proxy) PROXY="${2:-}"; shift 2 ;;
    --user) PROXY_USER="${2:-}"; shift 2 ;;
    --pwd) PROXY_PWD="${2:-}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "[ERROR] Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ "$SKIP_PYTHON" -eq 0 ]]; then
  echo "Trying to update Python itself if a package manager is available..."
  if command -v brew >/dev/null 2>&1; then
    brew upgrade python || true
  else
    echo "[WARN] Automatic Python executable update is not configured for this OS."
    echo "       Use your organization's approved installer/package manager."
  fi
fi

PIP_PROXY_OPT=""
PROXY_ARG=""
PROXY_DISPLAY=""
if [[ -n "$PROXY" ]]; then
  if [[ -n "$PROXY_USER" ]]; then
    PROTO="${PROXY%%://*}"
    HOST_PORT="${PROXY#*://}"
    FULL_PROXY="${PROTO}://${PROXY_USER}:${PROXY_PWD}@${HOST_PORT}"
    PIP_PROXY_OPT="--proxy $FULL_PROXY"
    PROXY_ARG="--proxy $PROXY --user $PROXY_USER --pwd $PROXY_PWD"
    PROXY_DISPLAY="${PROTO}://${PROXY_USER}:****@${HOST_PORT}"
  else
    PIP_PROXY_OPT="--proxy $PROXY"
    PROXY_ARG="--proxy $PROXY"
    PROXY_DISPLAY="$PROXY"
  fi
  echo "Proxy: $PROXY_DISPLAY"
fi

if [[ "$INCLUDE_GLOBAL" -eq 1 ]]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user --upgrade $PIP_PROXY_OPT pip setuptools wheel || true
    python3 -m pip list --user $PIP_PROXY_OPT --outdated --format=freeze 2>/dev/null | cut -d= -f1 | while read -r pkg; do
      [[ -n "$pkg" ]] || continue
      python3 -m pip install --user --upgrade $PIP_PROXY_OPT "$pkg" || true
    done
  fi
fi

found=0
for d in "$ROOT"/*; do
  if [[ -x "$d/bin/python" ]]; then
    found=1
    name="$(basename "$d")"
    echo "Updating venv: $name"
    "$(cd "$(dirname "$0")" && pwd)/update_env.sh" --name "$name" --dir "$d" $PROXY_ARG
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "[WARN] No virtual environments were found under: $ROOT"
fi

echo "[OK] update_all finished."
