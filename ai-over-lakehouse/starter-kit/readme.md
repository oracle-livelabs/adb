# PeakGear: first-time Codex setup on a clean Mac

## What you need

* Codex Desktop installed and signed in.
* Internet access for the one-time package installation.
* The **Lab Data Studio URL** from Lab 1.
* The PEAKGEAR_USER password from the private lab handout.

You do not need Python, uv, Terminal commands, an MCP URL, or a TOML editor.
The setup saves the database password in the macOS Keychain; it does not print
or put the password in a script or configuration file.

## Do this once

1. Download and unzip this starter-kit folder.
2. In Finder, double-click **01-setup-peakgear-mcp.command**. If macOS asks
   whether to open the file, click **Open**. If Gatekeeper blocks it,
   Control-click the file, choose **Open**, then click **Open** again.
3. Paste the **Lab Data Studio URL** from Lab 1 and press Return.
4. Enter the PEAKGEAR_USER password and press Return. Nothing is shown while
   you type; that is expected.
5. When Finder asks for a folder, choose the Codex project in which you will
   run the workshop. The script adds LiveLab only to that project. It does not
   create a new project.
6. Setup displays the configured URL and user, never a password. Compare the
   URL with the Lab 1 value. Open the chosen project in Codex and click
   **Trust** if prompted.
7. Create one new Codex task. LiveLab starts automatically for that task.

LiveLab always connects as PEAKGEAR_USER. The word **admin** in the local MCP
configuration identifies an MCP tool profile required to build Analytic Views;
it is not a database username.

## Required first checkpoint

Before asking a business question, tell Codex to call
**adp_get_connection_info**. Continue only if its non-secret response shows:

| Field | Required value |
|---|---|
| service | ADP |
| adp_user | PEAKGEAR_USER |
| session_ready | true |
| query_result_adapter | peakgear-json-bound-rows-v1 |

The checkpoint never returns a password or token.

## Start a clean retry

For a normal retry, double-click **02-peakgear-livelab-admin.command** and
choose **Start LiveLab cleanly — stop PeakGear LiveLab only**. It stops only
old PeakGear LiveLab processes, refreshes the wrapper and project
configuration, and opens the project.

The **Start LiveLab after stopping ALL local MCP servers** option is a broad
recovery action. It may interrupt other MCP-backed Codex tasks and requires a
typed confirmation. Use it only after the normal clean start fails.

After either start action, create one new Codex task. Do not reuse a task that
already had an MCP failure.

## If it does not work

| Symptom | Action |
|---|---|
| Setup reports an error | Capture the final lines and send them to the instructor. Do not edit TOML manually. |
| LiveLab is missing | Confirm that the selected project is open and trusted. Run the normal clean start, then create a new task. |
| The checkpoint reports an unexpected URL or user | Run 01-setup-peakgear-mcp.command again using the Lab Data Studio URL. |
| session_ready is false | Run the normal clean start and create a new task. Use the broad reset only if the problem persists. |
| Login is failed | Check the Lab Data Studio URL and PEAKGEAR_USER password with the instructor. |

LiveLab is a local stdio MCP process, not a Docker container. Do not use
docker start, docker stop, or docker restart for this workshop.
