#!/usr/bin/env bash
set -euo pipefail

ENV_NAME=""
ENV_DIR=""
PROXY=""
PROXY_USER=""
PROXY_PWD=""

usage() {
  cat <<'EOF'
Usage:
  ./update_env.sh --name ENV_NAME

Options:
  --name ENV_NAME    Required. Virtual environment name.
  --dir PATH         Optional. Environment path. Default: current folder/ENV_NAME
  --proxy URL        Optional. Proxy URL for pip. Example: http://proxy.example.com:8080
  --user USERNAME    Optional. Proxy username. Example: DOMAIN\\username
  --pwd PASSWORD     Optional. Proxy password.

Examples:
  ./update_env.sh --name YYY
  ./update_env.sh --name YYY --dir ~/venvs/YYY
  ./update_env.sh --name YYY --proxy http://proxy.example.com:8080
  ./update_env.sh --name YYY --proxy http://proxy.example.com:8080 --user 'DOMAIN\user' --pwd secret
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) ENV_NAME="${2:-}"; shift 2 ;;
    --dir) ENV_DIR="${2:-}"; shift 2 ;;
    --proxy) PROXY="${2:-}"; shift 2 ;;
    --user) PROXY_USER="${2:-}"; shift 2 ;;
    --pwd) PROXY_PWD="${2:-}"; shift 2 ;;
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

PY="$ENV_DIR/bin/python"
if [[ ! -x "$PY" ]]; then
  echo "[ERROR] Virtual environment was not found: $ENV_DIR"
  exit 1
fi

PIP_PROXY_OPT=""
PROXY_DISPLAY=""
if [[ -n "$PROXY" ]]; then
  if [[ -n "$PROXY_USER" ]]; then
    PROTO="${PROXY%%://*}"
    HOST_PORT="${PROXY#*://}"
    FULL_PROXY="${PROTO}://${PROXY_USER}:${PROXY_PWD}@${HOST_PORT}"
    PIP_PROXY_OPT="--proxy $FULL_PROXY"
    PROXY_DISPLAY="${PROTO}://${PROXY_USER}:****@${HOST_PORT}"
  else
    PIP_PROXY_OPT="--proxy $PROXY"
    PROXY_DISPLAY="$PROXY"
  fi
  echo "Proxy: $PROXY_DISPLAY"
fi

"$PY" -m pip install --upgrade $PIP_PROXY_OPT pip setuptools wheel

outdated="$("$PY" -m pip list $PIP_PROXY_OPT --outdated --format=freeze 2>/dev/null || true)"
if [[ -n "$outdated" ]]; then
  echo "$outdated" | cut -d= -f1 | while read -r pkg; do
    [[ -n "$pkg" ]] || continue
    echo "Updating $pkg ..."
    "$PY" -m pip install --upgrade $PIP_PROXY_OPT "$pkg" || echo "[WARN] Failed to update $pkg"
  done
fi

"$PY" -m pip check || true
echo "[OK] Update finished."
