#!/bin/zsh
# Start a local LiveLabs preview server. Open and inspect the lab manually.

set -euo pipefail

WORKSHOP_DIR=${0:A:h:h}
PORT=${1:-8000}

usage() {
  cat <<'EOF'
Usage: ./scripts/preview-livelabs.command [port]

Examples:
  ./scripts/preview-livelabs.command
  ./scripts/preview-livelabs.command 8001
EOF
}

if [[ "$PORT" == '-h' || "$PORT" == '--help' ]]; then
  usage
  exit 0
fi

if [[ ! "$PORT" =~ '^[0-9]+$' ]] || (( PORT < 1 || PORT > 65535 )); then
  print -u2 -- "Port must be a number from 1 through 65535."
  exit 1
fi

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  print -u2 -- "Port $PORT is already in use."
  print -u2 -- "Return to the Terminal that runs the preview server and press Control-C."
  print -u2 -- "This launcher will not stop an existing process."
  exit 1
fi

cd "$WORKSHOP_DIR"

print -- "Preview server: http://localhost:$PORT/workshops/sandbox/index.html"
print -- "Open or reload the required lab manually in Chrome."
print -- "The HTTP log remains in this Terminal. Press Control-C to stop the server."
exec python3 -m http.server "$PORT"
