# PeakGear: first-time Codex setup on a clean Mac

## What you need

* Codex Desktop installed and signed in.
* Internet access for the one-time package installation.
* Your assigned lab database and its ADMIN sign-in from Lab 1, for the
  read-only Data Studio URL lookup below.
* The PEAKGEAR_USER password. Lab 1 uses **Welcome123456** for a new account;
  an existing account keeps its current password.

Use Terminal to run the copy-ready commands below. You do not need to install
Python or uv manually, enter an MCP URL, or edit TOML.
The setup saves the connection password in the macOS Keychain; it does not
print the entered password or write it into the generated MCP configuration.
The shared event values are intentionally included in the workshop and in
[event-lab-values.md](event-lab-values.md) inside this kit.

## Do this once

1. In **Lab 4**, click **Download Here — PeakGear LiveLab Starter Kit (.zip)**.
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

4. **Obtain the Data Studio URL before running setup.** Keep Terminal open.
   In your browser, sign out of Data Studio, then sign in to the **assigned
   lab database as ADMIN**. Open **SQL Worksheet**, confirm that the header
   shows **ADMIN**, and run this SQL with **Run Statement**:

   ```sql
   SELECT 'https://' ||
          LOWER(REPLACE(p.name, '_', '-')) || '.' ||
          REGEXP_REPLACE(j.public_domain_name, '[^.]+', 'oraclecloudapps', 1, 3)
            AS adp_url
   FROM v$pdbs p
   CROSS JOIN JSON_TABLE(
     p.cloud_identity,
     '$' COLUMNS (
       public_domain_name VARCHAR2(512) PATH '$.PUBLIC_DOMAIN_NAME'
     )
   ) j
   WHERE p.con_id = SYS_CONTEXT('USERENV', 'CON_ID');
   ```

   Copy the full HTTPS value from **ADP_URL** and keep it ready for setup.
   This is the same read-only query used in Lab 1. Run it in **Data Studio,
   not Terminal**. Do not grant system-view access to PEAKGEAR_USER. If no URL
   is returned, stop and ask the instructor.

   **Sign out of ADMIN, then sign back in as PEAKGEAR_USER.** Never configure
   MCP with ADMIN. Do not use localhost:8000, the Operations listener, or a
   URL ending in /ords as the Lab Data Studio URL.

5. Return to the same Terminal, paste this command, and press **Return**:

   ```sh
   zsh ./01-setup-peakgear-mcp.command
   ```

   Wait for the package installation to finish. No Mac administrator password
   or additional install command is needed.

6. Answer the prompts:

   | Prompt | Action |
   |---|---|
   | Lab Data Studio URL | Paste the full ADP_URL obtained in step 4, then press Return. Never use localhost:8000. |
   | PEAKGEAR_USER password | Enter Welcome123456 for a new Lab 1 account, or the current password of an existing account. Press Return. Nothing appears while typing or pasting. |
   | Finder folder picker | Open Documents, select peakgear-livelab, then click Choose. |
   | Success / Press Return to close this window | Check the displayed URL and PEAKGEAR_USER, then press Return. |

7. Open the project from Terminal:

   ```sh
   open -a Codex "$HOME/Documents/peakgear-livelab"
   ```

   Click **Trust** if prompted.

8. Create one new Codex task in that project. LiveLab starts automatically for
   the new task. Continue with the Lab 4 connection checkpoint.

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
