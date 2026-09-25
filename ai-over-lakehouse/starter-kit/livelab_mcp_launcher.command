#!/bin/zsh
# Launch the portable PeakGear LiveLab MCP extension.

set -euo pipefail

readonly LIVELAB_RUNTIME_DIR="$HOME/.local/share/peakgear-livelab"
readonly LIVELAB_WRAPPER="$LIVELAB_RUNTIME_DIR/livelab_mcp.py"
readonly STANDARD_MCP="$HOME/.local/bin/oracle-data-studio-mcp"

if [[ ! -x "$STANDARD_MCP" ]]; then
  echo "Oracle Data Studio MCP is not installed. Run 01-setup-peakgear-mcp.command again." >&2
  exit 1
fi

MCP_TARGET="$(readlink "$STANDARD_MCP" 2>/dev/null || true)"
if [[ -z "$MCP_TARGET" ]]; then
  MCP_TARGET="$STANDARD_MCP"
elif [[ "$MCP_TARGET" != /* ]]; then
  MCP_TARGET="${STANDARD_MCP:h}/$MCP_TARGET"
fi
readonly MCP_TARGET
readonly MCP_PYTHON="${MCP_TARGET:h}/python"

if [[ ! -x "$MCP_PYTHON" || ! -f "$LIVELAB_WRAPPER" ]]; then
  echo "PeakGear LiveLab is incomplete. Run 01-setup-peakgear-mcp.command again." >&2
  exit 1
fi

exec "$MCP_PYTHON" "$LIVELAB_WRAPPER" "$@"
