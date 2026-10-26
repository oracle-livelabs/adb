# PeakGear: first-time Codex setup on macOS or Windows

## What you need

* Codex installed, signed in, and able to create a local task. Arrange account
  access and supported desktop installation with the organizer before the event.
* macOS with Terminal, or native Windows with Windows PowerShell 5.1 or later.
* Internet access for the one-time package installation.
* The actual ADP_URL returned by the read-only SQL query in **Lab 3, Task 1**,
  run as PEAKGEAR_USER in Data Studio. The reservation provider must validate
  access before release; if it fails, stop and contact the instructor.
* **Database User** and **Database Password** from LiveLabs **Reservation
  Information → Environment Details**. This kit expects PEAKGEAR_USER.

Use the local shell for your operating system below. You do not need to install
Python or uv manually, enter an MCP URL, or edit TOML.
The setup verifies password storage in macOS Keychain or Windows Credential
Manager before reporting Success; it does not
print the entered password or write it into the generated MCP configuration.
This kit contains no source credentials. The
[connection field reference](event-lab-values.md) maps Lab 2's protected fields
to LiveLabs **View Login Info → Environment Details**. The MCP launcher needs
only the assigned database password, not the Azure storage password or Databricks
OAuth values.

## macOS: do this once in Terminal

1. In **Lab 3**, click **Download Here — PeakGear LiveLab Starter Kit (.zip)**.
   Save it in **Downloads** as `peakgear-livelab-starter-kit.zip`. Keep the ZIP.
   If the browser adds `(1)` or another suffix, rename the downloaded file to
   the exact name above before continuing.
   There is only one kit, containing both operating-system versions and supporting files.

2. **Open Terminal on your Mac:** Finder > Applications > Utilities > Terminal.
   Or press Command-Space to open Spotlight, type Terminal, and press Return.
   Keep this local window open; no cloud/Linux prompt is needed.

3. Paste this entire block into Terminal and press **Return**:

   ```sh
   cd "$HOME/Downloads"
   PEAKGEAR_KIT_DIR="$(mktemp -d "$HOME/Downloads/peakgear-starter.XXXXXX")"
   ditto -x -k "peakgear-livelab-starter-kit.zip" "$PEAKGEAR_KIT_DIR"
   mkdir -p "$HOME/Documents/peakgear-livelab"
   cd "$PEAKGEAR_KIT_DIR/starter-kit"
   ```

   This extracts a fresh copy without changing earlier downloads.

4. **Have the database-specific URL ready before running setup.** Use the
   ADP_URL result from the SQL query in **Lab 3, Task 1**. Run the query in
   Data Studio as PEAKGEAR_USER and copy its HTTPS result exactly. Do not use
   `datastudio.oracle.com`, localhost:8000, the OCI Console URL, or the
   Operations listener. If the query reports an access error or returns no
   URL, stop and contact the instructor; do not switch to ADMIN.

   Keep LiveLabs **Reservation Information → Environment Details** open for
   the database password. No ADMIN sign-in is needed. If you cannot obtain the
   assigned database URL, ask the instructor before running setup.

5. Return to the same Terminal, paste this command, and press **Return**:

   ```sh
   zsh ./01-setup-peakgear-mcp.command
   ```

   Wait for the package installation to finish. No Mac administrator password
   or additional install command is needed.

6. Answer the prompts:

   | Prompt | Action |
   |---|---|
   | Lab Data Studio URL | Paste the ADP_URL result from Lab 3, Task 1, then press Return. Never use localhost:8000. |
   | PEAKGEAR_USER password | Copy Database Password from LiveLabs Reservation Information → Environment Details. Paste it into Terminal, then press Return. Nothing appears while typing or pasting. |
   | Finder folder picker | Open Documents, select peakgear-livelab, then click Choose. |
   | Success / Press Return to close this window | Check the displayed URL and PEAKGEAR_USER, then press Return. |

   Use **Database Password**, not the OCI **Login Credentials** password,
   a screenshot's example, or your Mac password.

7. Open the project from Terminal:

   ```sh
   open -a Codex "$HOME/Documents/peakgear-livelab"
   ```

   Click **Trust** if prompted.

8. Create one new Codex task in that project. LiveLab starts automatically for
   the new task. Paste the complete Lab 3 Task 2 boundary prompt once, then
   keep the same task for Labs 4–5. It checks the connection silently before
   each business question or model-building task and contains the conditional
   AV build workflow; setup itself does not authorize object creation.

## Windows: do this once in Windows PowerShell

1. Obtain **ADP_URL** in Data Studio using the Lab 3 SQL. Keep that result ready
   for the setup's **Lab Data Studio URL** prompt. Keep LiveLabs **Environment
   Details** open for the separate **Database Password**.
2. Download the same Starter Kit ZIP to Downloads. Open the Windows Start menu,
   search for **Windows PowerShell**, and open it normally, not as administrator.
   A PowerShell tab in Windows Terminal also works; Command Prompt does not.
3. Extract a fresh copy:

   ```powershell
   Set-Location (Join-Path $env:USERPROFILE 'Downloads')
   $PeakGearKitDir = Join-Path ([IO.Path]::GetTempPath()) ('peakgear-starter-' + [guid]::NewGuid())
   Expand-Archive -LiteralPath '.\peakgear-livelab-starter-kit.zip' -DestinationPath $PeakGearKitDir
   Set-Location (Join-Path $PeakGearKitDir 'starter-kit')
   ```

   For a redirected Downloads folder, open the ZIP's actual directory in File
   Explorer using **Open in Terminal**, select PowerShell, then use the last
   three lines above.
4. Run the Windows version:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\01-setup-peakgear-mcp.ps1
   ```

   The script installs its user-scoped package runner and Python runtime.
   This command does not change machine/user execution policy. If organizational
   policy blocks scripts or downloads, ask the instructor; do not disable it.
5. Paste **ADP_URL**, then the reservation **Database Password** when prompted.
   Password input is hidden. Press Enter at **Codex project folder** to use
   peakgear-livelab in Documents, or enter an existing local project path.
6. After Success, open Codex, add/open the printed local project path, and trust
   it if prompted. Create a new local task there. Paste the Lab 3 boundary once
   and keep this task for Labs 4–5. Task 2 verifies the actual live connection.

Windows installs the runtime under `%LOCALAPPDATA%\peakgear-livelab` and uses
an absolute native Python command in the project MCP config. It does not use
zsh, Finder, Keychain, or WSL. The Python LiveLab server is shared with macOS.

LiveLab always connects as PEAKGEAR_USER. The word **admin** in the local MCP
configuration identifies an MCP tool profile required to build Analytic Views;
it is not a database username.

Lab 5 uses a short model-building request and scoped creation authorization;
it does not repeat the boundary. Under the standing Lab 3 rules, Codex creates
or reuses one AV with both measures through SQL DDL in `adp_run_query`; it does
not use `adp_build_analytic_view`. Metadata reads are batched where possible,
facts are aggregated independently by product/month, and one final health
check reconciles the latest shared completed month.

## Required connection check

The Lab 3 boundary tells Codex to call **adp_get_connection_info** before any
other LiveLab tool for a business question or model-building task. Codex checks these fields silently:

| Field | Required value |
|---|---|
| service | ADP |
| adp_url | The actual database-specific URL configured for your current reservation |
| adp_user | PEAKGEAR_USER |
| session_ready | true |
| query_result_adapter | peakgear-json-bound-rows-v1 |

The check never returns a password or token. A successful check is not a
business answer and need not be repeated in the chat.

This Starter Kit queries the local snapshot tables created in Lab 2. An
installed kit from an earlier version may still reference raw views; rerun
setup from the current download and create a new Codex task before testing
the local-table workflow.

## Start a clean retry

On macOS, open Terminal and run the installed copy of
**02-peakgear-livelab-admin.command**:

```sh
zsh "$HOME/.local/share/peakgear-livelab/peakgear-livelab-admin.command"
```

Choose **1 — Start LiveLab cleanly — stop PeakGear LiveLab only**. It stops only
old PeakGear LiveLab processes, refreshes the wrapper and project
configuration, and opens the project.

On Windows, open Windows PowerShell and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\peakgear-livelab\02-peakgear-livelab-admin.ps1" -Action Restart
```

Then open the configured project in Codex and create a new task. Windows
management supports Restart, Stop, Status, and Refresh; it targets only the
current user's installed PeakGear server, not other MCP processes.

Do not select the ALL-MCP cleanup options during the normal workshop. They may
interrupt other MCP-backed Codex tasks and require a typed confirmation.

After either start action, create one new Codex task. Do not reuse a task that
already had an MCP failure.

## When your reservation or database changes

You do not need to uninstall MCP. Before replacing its connection:

1. On macOS, choose **3 — Stop PeakGear LiveLab only** in management. On Windows,
   use the command above with **-Action Stop**. Other MCP servers stay running.
2. Obtain the new database-specific ADP_URL by running the query in Lab 3,
   Task 1 as PEAKGEAR_USER, and copy the Database Password from the new
   reservation's Environment Details.
3. Download the current Starter Kit and run the 01 setup script for your OS
   from its extracted folder. This replaces the local LiveLab connection and
   refreshes the installed supporting files; it does not erase database objects.
4. Open the selected project and create a new Codex task. Verify that
   `adp_get_connection_info` reports the **new** URL, PEAKGEAR_USER, and a ready
   session before asking any business question.

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
