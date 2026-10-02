#!/bin/zsh
# PeakGear LiveLab: first-run setup for a clean macOS laptop.
# This script never receives or prints a database password.

set -euo pipefail

readonly PEAKGEAR_USER="PEAKGEAR_USER"
readonly UV_BIN_DIR="$HOME/.local/bin"
readonly MCP_SERVER_NAME="LiveLab"
readonly STARTER_DIR="${0:A:h}"
readonly LIVELAB_RUNTIME_DIR="$HOME/.local/share/peakgear-livelab"
readonly LIVELAB_WRAPPER_SOURCE="$STARTER_DIR/livelab_mcp.py"
readonly LIVELAB_LAUNCHER_SOURCE="$STARTER_DIR/livelab_mcp_launcher.command"
readonly LIVELAB_ADMIN_SOURCE="$STARTER_DIR/02-peakgear-livelab-admin.command"
readonly LIVELAB_WRAPPER="$LIVELAB_RUNTIME_DIR/livelab_mcp.py"
readonly LIVELAB_LAUNCHER="$UV_BIN_DIR/peakgear-livelab-mcp"
readonly LIVELAB_ADMIN="$LIVELAB_RUNTIME_DIR/peakgear-livelab-admin.command"
readonly PROJECT_PATH_FILE="$LIVELAB_RUNTIME_DIR/project-path"
readonly STARTER_PATH_FILE="$LIVELAB_RUNTIME_DIR/starter-path"

clear
echo "================================================"
echo " PeakGear LiveLab — Codex + Data Studio setup "
echo "================================================"
echo
echo "This will install the local Data Studio MCP package."
echo "No macOS administrator password is required."
echo

if ! command -v uv >/dev/null 2>&1; then
  echo "Installing the user-scoped package runner…"
  curl --proto '=https' --tlsv1.2 -LsSf https://astral.sh/uv/install.sh | sh
fi

export PATH="$UV_BIN_DIR:$PATH"

if ! command -v uv >/dev/null 2>&1; then
  echo
  echo "Setup could not find uv after installation. Close this window and run setup once more."
  exit 1
fi

echo
echo "Installing the Oracle Data Studio MCP package…"
uv tool install --force "oracle-data-studio[mcp]"

if [[ ! -x "$UV_BIN_DIR/oracle-data-studio-config" ]]; then
  echo
  echo "The Data Studio configuration command was not installed. Send this screen to the instructor."
  exit 1
fi

echo
echo "Paste the Lab Data Studio URL from the lab start page, then press Return."
echo "Example: https://example.adb.us-ashburn-1.oraclecloudapps.com"
read "ADP_URL?Lab Data Studio URL: "

if [[ ! "$ADP_URL" =~ '^https://.+\.oraclecloudapps\.com/?$' ]]; then
  echo
  echo "This does not look like a Data Studio URL. Nothing was configured."
  exit 1
fi

echo
echo "Now enter the password for ${PEAKGEAR_USER} when prompted."
echo "The password is not echoed and is stored in the macOS Keychain."
"$UV_BIN_DIR/oracle-data-studio-config" set adp --url "$ADP_URL" --user "$PEAKGEAR_USER"

if [[ ! -f "$LIVELAB_WRAPPER_SOURCE" || ! -f "$LIVELAB_LAUNCHER_SOURCE" || ! -f "$LIVELAB_ADMIN_SOURCE" ]]; then
  echo
  echo "The PeakGear LiveLab diagnostic files are missing. Download a new starter kit and run setup again."
  exit 1
fi

mkdir -p "$LIVELAB_RUNTIME_DIR"
install -m 700 "$LIVELAB_WRAPPER_SOURCE" "$LIVELAB_WRAPPER"
install -m 700 "$LIVELAB_LAUNCHER_SOURCE" "$LIVELAB_LAUNCHER"
install -m 700 "$LIVELAB_ADMIN_SOURCE" "$LIVELAB_ADMIN"

echo
echo "Select your existing Codex project folder in Finder."
echo "This adds the LiveLab MCP to that project; it does not create a new project."

if ! CODEX_PROJECT_DIR="$(osascript -e 'POSIX path of (choose folder with prompt "Select the Codex project folder for PeakGear LiveLab")')"; then
  echo
  echo "No project folder was selected. Data Studio was configured, but no MCP config was written."
  exit 1
fi

readonly PROJECT_MCP_DIR="${CODEX_PROJECT_DIR%/}/.codex"
readonly PROJECT_MCP_CONFIG="${PROJECT_MCP_DIR}/config.toml"

mkdir -p "$PROJECT_MCP_DIR"

# Remove an earlier LiveLab section, while preserving every other project setting.
readonly TEMP_CONFIG="$(mktemp "${PROJECT_MCP_CONFIG}.XXXXXX")"
if [[ -f "$PROJECT_MCP_CONFIG" ]]; then
  awk '
    /^\[mcp_servers\.LiveLab\][[:space:]]*$/ { skip = 1; next }
    skip && /^\[/ { skip = 0 }
    !skip { print }
  ' "$PROJECT_MCP_CONFIG" > "$TEMP_CONFIG"
fi

cat >> "$TEMP_CONFIG" <<'EOF'

# PeakGear LiveLab: project-scoped Oracle Data Studio MCP.
# The server reads the URL and PEAKGEAR_USER password from the macOS Keychain.
# "admin" is the MCP tool profile required to build Analytic Views; it is not a database user.
[mcp_servers.LiveLab]
command = "/bin/zsh"
args = ["-lc", "exec \"$HOME/.local/bin/peakgear-livelab-mcp\" --transport stdio --profile admin"]
enabled = true
startup_timeout_sec = 60
tool_timeout_sec = 180
default_tools_approval_mode = "prompt"
EOF

mv "$TEMP_CONFIG" "$PROJECT_MCP_CONFIG"
print -r -- "${CODEX_PROJECT_DIR%/}" > "$PROJECT_PATH_FILE"
print -r -- "$STARTER_DIR" > "$STARTER_PATH_FILE"

echo
echo "Success. LiveLab MCP was added to:"
echo "$PROJECT_MCP_CONFIG"
echo
echo "Open the selected project if it is not already open."
echo "When Codex asks whether to trust the project, choose Trust."
echo "Create a new task in that project. The LiveLab MCP server starts automatically for that task."
echo "If LiveLab is missing or a call waits too long, double-click this file:"
echo "$LIVELAB_ADMIN"
echo "Choose 'Start LiveLab cleanly — stop PeakGear LiveLab only' for the normal path."
echo "Choose the ALL-MCP option only when you intentionally want to stop other local MCP server processes too."
echo "First checkpoint: ask Codex to call adp_get_connection_info. Continue only when it shows PEAKGEAR_USER, session_ready = true, and query_result_adapter = peakgear-json-bound-rows-v1."
echo
echo "Configured Data Studio connection (no password is shown):"
"$UV_BIN_DIR/oracle-data-studio-config" list
echo
read "?Press Return to close this window."
