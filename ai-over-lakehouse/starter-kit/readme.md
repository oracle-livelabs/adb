# PeakGear: first-time Codex setup on a clean Mac

## What you need

* Codex Desktop installed and signed in.
* Internet access for the one-time package installation.
* The actual ADP_URL returned by the read-only SQL query in **Lab 3, Task 1**,
  run as PEAKGEAR_USER in Data Studio. The reservation provider must validate
  access before release; if it fails, stop and contact the instructor.
* **Database User** and **Database Password** from LiveLabs **Reservation
  Information → Environment Details**. This kit expects PEAKGEAR_USER.

Use Terminal to run the copy-ready commands below. You do not need to install
Python or uv manually, enter an MCP URL, or edit TOML.
The setup saves the connection password in the macOS Keychain; it does not
print the entered password or write it into the generated MCP configuration.
The shared event values are intentionally included in the workshop and in
[event-lab-values.md](event-lab-values.md) inside this kit.

## Do this once

1. In **Lab 3**, click **Download Here — PeakGear LiveLab Starter Kit (.zip)**.
   Save it in **Downloads** as `peakgear-livelab-starter-kit.zip`. Keep the ZIP.
   If the browser adds `(1)` or another suffix, rename the downloaded file to
   the exact name above before continuing.
   There is only one kit, containing both numbered scripts and supporting files.

2. **Open Terminal:** press **Command-Space**, type **Terminal**, then press
   **Return**. Keep this window open.

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
   the new task. Paste the Lab 3 boundary prompt; it checks the connection
   silently before each business question.

LiveLab always connects as PEAKGEAR_USER. The word **admin** in the local MCP
configuration identifies an MCP tool profile required to build Analytic Views;
it is not a database username.

## Required connection check

The Lab 3 boundary tells Codex to call **adp_get_connection_info** before any
other LiveLab tool for a business question. Codex checks these fields silently:

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

For a normal retry, open Terminal and run the installed copy of
**02-peakgear-livelab-admin.command**:

```sh
zsh "$HOME/.local/share/peakgear-livelab/peakgear-livelab-admin.command"
```

Choose **1 — Start LiveLab cleanly — stop PeakGear LiveLab only**. It stops only
old PeakGear LiveLab processes, refreshes the wrapper and project
configuration, and opens the project.

Do not select the ALL-MCP cleanup options during the normal workshop. They may
interrupt other MCP-backed Codex tasks and require a typed confirmation.

After either start action, create one new Codex task. Do not reuse a task that
already had an MCP failure.

## When your reservation or database changes

You do not need to uninstall MCP. Before replacing its connection:

1. Open the installed management script above and choose **3 — Stop PeakGear
   LiveLab only**. Do not choose an ALL-MCP option.
2. Obtain the new database-specific ADP_URL by running the query in Lab 3,
   Task 1 as PEAKGEAR_USER, and copy the Database Password from the new
   reservation's Environment Details.
3. Download the current Starter Kit and run `01-setup-peakgear-mcp.command`
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
