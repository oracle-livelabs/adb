#!/bin/zsh
# PeakGear LiveLab: local MCP maintenance for a configured Codex project.
# This script never reads or prints a database password.

set -euo pipefail

readonly UV_BIN_DIR="$HOME/.local/bin"
readonly RUNTIME_DIR="$HOME/.local/share/peakgear-livelab"
readonly PROJECT_PATH_FILE="$RUNTIME_DIR/project-path"
readonly STARTER_PATH_FILE="$RUNTIME_DIR/starter-path"
readonly RUNTIME_WRAPPER="$RUNTIME_DIR/livelab_mcp.py"
readonly RUNTIME_LAUNCHER="$UV_BIN_DIR/peakgear-livelab-mcp"
readonly SCRIPT_DIR="${0:A:h}"
readonly CURRENT_UID="$(id -u)"

die() {
  echo
  echo "Error: $1"
  echo
  read "?Press Return to close this window."
  exit 1
}

starter_dir() {
  if [[ -f "$SCRIPT_DIR/livelab_mcp.py" && -f "$SCRIPT_DIR/livelab_mcp_launcher.command" ]]; then
    print -r -- "$SCRIPT_DIR"
    return
  fi

  if [[ -f "$STARTER_PATH_FILE" ]]; then
    local saved_dir
    saved_dir="$(< "$STARTER_PATH_FILE")"
    if [[ -f "$saved_dir/livelab_mcp.py" && -f "$saved_dir/livelab_mcp_launcher.command" ]]; then
      print -r -- "$saved_dir"
      return
    fi
  fi

  die "The starter kit files were not found. Keep this file in the unzipped PeakGear starter kit, then run it again."
}

project_dir() {
  [[ -f "$PROJECT_PATH_FILE" ]] || die "No configured Codex project was found. Run 01-setup-peakgear-mcp.command first."
  local configured_project
  configured_project="$(< "$PROJECT_PATH_FILE")"
  [[ -d "$configured_project" ]] || die "The configured Codex project folder no longer exists: $configured_project"
  print -r -- "$configured_project"
}

write_project_config() {
  local configured_project project_mcp_dir project_config temp_config
  configured_project="$(project_dir)"
  project_mcp_dir="$configured_project/.codex"
  project_config="$project_mcp_dir/config.toml"
  mkdir -p "$project_mcp_dir"
  temp_config="$(mktemp "${project_config}.XXXXXX")"

  if [[ -f "$project_config" ]]; then
    awk '
      /^\[mcp_servers\.LiveLab\][[:space:]]*$/ { skip = 1; next }
      skip && /^\[/ { skip = 0 }
      !skip { print }
    ' "$project_config" > "$temp_config"
  fi

  cat >> "$temp_config" <<'EOF'

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

  mv "$temp_config" "$project_config"
  echo "Updated project configuration: $project_config"
}

show_status() {
  clear
  echo "================================================"
  echo " PeakGear LiveLab — MCP maintenance"
  echo "================================================"
  echo
  echo "Data Studio package:"
  if [[ -x "$UV_BIN_DIR/oracle-data-studio-mcp" && -x "$UV_BIN_DIR/oracle-data-studio-config" ]]; then
    echo "  Ready"
    "$UV_BIN_DIR/oracle-data-studio-config" list
  else
    echo "  Missing. Run 01-setup-peakgear-mcp.command."
  fi
  echo
  echo "Configured Codex project:"
  if [[ -f "$PROJECT_PATH_FILE" ]]; then
    echo "  $(< "$PROJECT_PATH_FILE")"
  else
    echo "  Not configured"
  fi
  echo
  echo "Active LiveLab stdio processes:"
  local process_lines
  process_lines="$(pgrep -u "$CURRENT_UID" -fal 'livelab_mcp.py' || true)"
  if [[ -n "$process_lines" ]]; then
    echo "$process_lines"
  else
    echo "  None. A new Codex task starts a new LiveLab process automatically."
  fi
  echo
  echo "All local MCP server processes:"
  local all_mcp_process_lines
  all_mcp_process_lines="$(pgrep -u "$CURRENT_UID" -fal '[mM][cC][pP]' || true)"
  if [[ -n "$all_mcp_process_lines" ]]; then
    echo "$all_mcp_process_lines"
  else
    echo "  None"
  fi
  echo
}

refresh_livelab() {
  local source_dir
  source_dir="$(starter_dir)"
  [[ -x "$UV_BIN_DIR/oracle-data-studio-mcp" ]] || die "The Data Studio MCP package is missing. Run 01-setup-peakgear-mcp.command."

  mkdir -p "$RUNTIME_DIR"
  install -m 700 "$source_dir/livelab_mcp.py" "$RUNTIME_WRAPPER"
  install -m 700 "$source_dir/livelab_mcp_launcher.command" "$RUNTIME_LAUNCHER"
  print -r -- "$source_dir" > "$STARTER_PATH_FILE"
  write_project_config
  echo
  echo "Refresh complete."
  echo
}

stop_all_livelab_sessions() {
  local -a pids
  pids=("${(@f)$(pgrep -u "$CURRENT_UID" -f 'livelab_mcp.py' || true)}")
  if (( ${#pids[@]} == 0 )); then
    echo
    echo "No active PeakGear LiveLab MCP sessions were found."
    echo
    return
  fi

  echo
  echo "Stopping all active PeakGear LiveLab MCP sessions: ${pids[*]}"
  echo "Other MCP servers, Codex, Data Studio, and database data are not changed."
  kill -TERM -- "${pids[@]}"
  echo "All active PeakGear LiveLab MCP sessions were stopped."
  echo
}

stop_all_local_mcp_sessions() {
  local -a pids
  pids=("${(@f)$(pgrep -u "$CURRENT_UID" -f '[mM][cC][pP]' || true)}")
  if (( ${#pids[@]} == 0 )); then
    echo
    echo "No local MCP server processes were found."
    echo
    return
  fi

  echo
  echo "This is a broad cleanup. It will stop every local process whose command contains 'mcp': ${pids[*]}"
  echo "It can interrupt other MCP-backed Codex tasks. It does not delete MCP configuration or database data."
  local confirmation
  read "confirmation?Type STOP ALL MCP to continue: "
  if [[ "$confirmation" != "STOP ALL MCP" ]]; then
    echo "No MCP server processes were stopped."
    echo
    return 1
  fi

  kill -TERM -- "${pids[@]}"
  echo "All local MCP server processes were stopped."
  echo
}

start_clean_livelab() {
  local cleanup_scope="$1"
  echo
  echo "Clean LiveLab start"
  echo "1. Stop existing MCP sessions."
  echo "2. Refresh the PeakGear wrapper and project configuration."
  echo "3. Open the configured Codex project."
  echo
  if [[ "$cleanup_scope" == "all" ]]; then
    stop_all_local_mcp_sessions || return
  else
    stop_all_livelab_sessions
  fi
  refresh_livelab
  open_project
  echo "Clean start is ready. In Codex, create one new task."
  echo "Codex starts a fresh LiveLab stdio session for that task automatically."
  echo
}

open_project() {
  local configured_project
  configured_project="$(project_dir)"
  open -a Codex "$configured_project"
  echo
  echo "Opened the configured project in Codex. Create a new task to start LiveLab."
  echo
}

while true; do
  show_status
  echo "1) Start LiveLab cleanly — stop PeakGear LiveLab only (recommended)"
  echo "2) Start LiveLab after stopping ALL local MCP servers (advanced)"
  echo "3) Stop PeakGear LiveLab MCP sessions only"
  echo "4) Stop ALL local MCP server processes (advanced)"
  echo "5) Show status again"
  echo "6) Refresh LiveLab files and the project configuration"
  echo "7) Open the configured Codex project"
  echo "8) Exit"
  echo
  choice=''
  read "choice?Choose an action [1]: "
  case "$choice" in
    ''|1) start_clean_livelab "peakgear" ;;
    2) start_clean_livelab "all" ;;
    3) stop_all_livelab_sessions ;;
    4) stop_all_local_mcp_sessions ;;
    5) ;;
    6) refresh_livelab ;;
    7) open_project ;;
    8) exit 0 ;;
    *) echo "Choose a number from 1 to 8." ;;
  esac
  read "?Press Return to continue."
done
