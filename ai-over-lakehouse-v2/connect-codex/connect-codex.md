# Lab 3: Connect Codex and ask the raw-data question

Estimated Time: 8 minutes

## Introduction

PeakGear's source tables are ready, so the next step is to ask the business question:

**Which products are customers interested in right now?**

Codex can reach the reserved database through the project-scoped LiveLab MCP server as PEAKGEAR\_USER, not as an administrator. **Azure** and **Databricks** secrets remain in database credentials; the local server does not need them.

In this lab, you set up and check that connection, then ask the question. Codex should stop before ranking products because the raw columns do not say whether interest means events, sessions, or customers, or which period “right now” refers to. That deliberate stop sets up **Lab 4**, where you will save the missing definitions and ask the same question again.

### Objectives

In this lab, you will:

* Connect your laptop to the prepared Data Studio environment;
* Confirm that the active Codex task can reach PEAKGEAR\_USER; and
* See why Codex should stop before the source data has a business definition.

### Prerequisites

* **Lab 1** and **Lab 2** are complete.
* **_Codex is already installed on your PC_**, signed in, and can create a local task. Complete the installation and account check with the event organizer before the workshop.
* Use your own laptop: macOS with Terminal or Windows with Windows PowerShell. The Starter Kit configures a local MCP process; no cloud Linux terminal is needed.
* Data Studio SQL Worksheet is connected to your reservation as PEAKGEAR\_USER. Keep LiveLabs **Environment Details** open for the Database Password.

## Task 1: Set up LiveLab MCP

1. Get your AI Lakehouse URL. In Data Studio, open **SQL Worksheet** connected as PEAKGEAR\_USER and run:

    ~~~sql
    <copy>
    SELECT 'https://' ||
           LOWER(REPLACE(p.name, '_', '-')) || '.' ||
           REGEXP\_REPLACE(j.public\_domain\_name, '[^.]+', 'oraclecloudapps', 1, 3)
             AS adp\_url
    FROM v$pdbs p
    CROSS JOIN JSON\_TABLE(
      p.cloud\_identity,
      '$' COLUMNS (
        public\_domain\_name VARCHAR2(512) PATH '$.PUBLIC\_DOMAIN\_NAME'
      )
    ) j
    WHERE p.con\_id = SYS\_CONTEXT('USERENV', 'CON\_ID');
    </copy>
    ~~~

    - Copy the returned HTTPS value, **ADP\_URL**. You will paste it at the **Lab Data Studio URL** prompt in step 6 of your operating-system path.


    - This is the base URL for your assigned database. Run the query in Data Studio, not Terminal. You do not need to open the URL in a browser.


    - The reservation must permit this read-only lookup for PEAKGEAR\_USER.


    - If the query returns an access error or no URL, stop and contact the instructor. Do not grant privileges or switch to ADMIN.


2. Download the Starter Kit. Click
    [**Download Here — PeakGear LiveLab Starter Kit (.zip)**](../downloads/peakgear-livelab-starter-kit.zip).

    - _**Important:** This kit does not contain the Codex installer. Codex must already be installed and set up on your PC._


    - Save it in **Downloads** as `peakgear-livelab-starter-kit.zip`.


    - If the browser adds a suffix such as `(1)`, rename the file to the exact name above.


    - Keep the ZIP. You will unpack it on your laptop. It contains setup files for macOS and Windows.


Continue with the path for your laptop's operating system. Both paths configure the same LiveLab Python server and database user.

### macOS: Terminal

3. Open Terminal on your Mac.

    - In Finder, choose **Applications > Utilities > Terminal**; or


    - Open Spotlight with Command + Space, type **Terminal**, and press Return.


    - Keep this local window open.


4. Unpack the ZIP and prepare the project folder. Copy and run this block in Terminal:

    ~~~sh
    <copy>
    cd "$HOME/Downloads"
    PEAKGEAR\_KIT\_DIR="$(mktemp -d "$HOME/Downloads/peakgear-starter.XXXXXX")"
    ditto -x -k "peakgear-livelab-starter-kit.zip" "$PEAKGEAR\_KIT\_DIR"
    mkdir -p "$HOME/Documents/peakgear-livelab"
    cd "$PEAKGEAR\_KIT\_DIR/starter-kit"
    </copy>
    ~~~

    - The commands create a fresh extraction, leaving older downloads unchanged.


    - They leave Terminal in the extracted `starter-kit` folder.


5. Run setup in the same Terminal window:

    ~~~sh
    <copy>
    zsh ./01-setup-peakgear-mcp.command
    </copy>
    ~~~

    - Wait for package installation to finish.


    - Do not run extra install commands. Installation is user-scoped.


6. Answer the setup prompts in order.

    - **Lab Data Studio URL:** Paste the **ADP\_URL** from step 1. Do not use `localhost:8000`.


    - **Password for PEAKGEAR\_USER:** Paste **Database Password** from Reservation Information > Environment Details. Nothing appears while you type or paste; this is normal. Do not use the OCI, example, or Mac password.


    - **Finder folder picker:** Open Documents, select `peakgear-livelab`, and click **Choose**. This is the folder created in step 4.


    - **Success:** Confirm the displayed URL and PEAKGEAR\_USER, then press Return to close the window.


7. Open the project in Codex. After setup finishes, run this in Terminal:

    ~~~sh
    <copy>
    open -a Codex "$HOME/Documents/peakgear-livelab"
    </copy>
    ~~~

    - Click **Trust** if Codex asks whether you trust this project.


8. Create a new Codex task in the `peakgear-livelab` project.

    - Select the project opened in step 7, then create a task there.


    - LiveLab starts automatically for the new task. Continue with Task 2 in that task; do not reuse an older task or one from another project.


### Windows: Windows PowerShell

3. Open Windows PowerShell on your laptop.

    - Open the Windows **Start** menu, type **Windows PowerShell**, and open it normally, not **Run as administrator**.


    - Windows Terminal also works if the selected tab is PowerShell, not Command Prompt. Keep the local window open. WSL is not needed.


4. Unpack the ZIP. Copy and run this block in PowerShell:

    ~~~powershell
    <copy>
    Set-Location (Join-Path $env:USERPROFILE 'Downloads')
    $PeakGearKitDir = Join-Path ([IO.Path]::GetTempPath()) ('peakgear-starter-' + [guid]::NewGuid())
    Expand-Archive -LiteralPath '.\peakgear-livelab-starter-kit.zip' -DestinationPath $PeakGearKitDir
    Set-Location (Join-Path $PeakGearKitDir 'starter-kit')
    </copy>
    ~~~

    - This creates a fresh extraction without changing previous downloads.


    - If Downloads is redirected, open the folder containing the ZIP in File Explorer, choose **Open in Terminal** with a PowerShell tab, then run the last three commands in the block.


5. Run the Windows setup script in the same PowerShell window:

    ~~~powershell
    <copy>
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\01-setup-peakgear-mcp.ps1
    </copy>
    ~~~

    - Wait for package installation to finish. The command applies the script policy only to this child process; it does not change machine or user policy.


    - If your organization blocks scripts or downloads, contact the instructor. Do not change organizational security settings.


6. Answer the setup prompts in order.

    - **Lab Data Studio URL:** Paste the **ADP\_URL** from step 1, then press Enter.


    - **Password for PEAKGEAR\_USER:** Paste **Database Password** from Environment Details, not the OCI Login Credentials password. Input is hidden; press Enter.


    - **Codex project folder:** Press Enter to create or use `peakgear-livelab` in Documents, or enter an existing local project folder.


    - **Success:** Note the full project path printed by setup.


7. Open the project in Codex.

    - Open the desktop client from the Start menu.


    - Add or open the local project folder printed by setup, select it, and accept the trust prompt if shown.


    - Use a local project, not a cloud task. Local MCP starts from the project's configuration.


8. Create a new task in that project. Continue with Task 2 in the same task and keep it open through **Labs 4 and 5**.

**Before you continue:**

* Setup success does not confirm that the Codex task is connected. Task 2 checks the active connection before the business question. Keep this task open for Labs 4 and 5.
* Setup confirms that the password was saved in macOS Keychain or Windows Credential Manager. It does not write the password or source tokens to the project configuration. Event values are documented in the workshop.
* Keep the extracted `starter-kit` folder. Both numbered scripts and supporting files belong to it. You do not need to edit TOML or install Python or the package runner manually.
* For restart instructions or setup errors, see **Need Help?** Restarting the local MCP process does not reset database tables or annotations.

## Task 2: Establish the MCP boundary

1. Paste the complete boundary prompt below once into the new task from Task 1. It sets the rules for business questions and the later Analytic View build.

    - Keep this same task open through Labs 4 and 5. You will not paste the prompt again in Lab 5.


    - Setting the boundary does not create objects.


    - Wait for **Ready. What business question would you like to explore?**, then continue to Task 3. Codex keeps its connection checks internal.


~~~text
<copy>
You are the PeakGear business analyst. Use only MCP tools from the LiveLab server and give concise, evidence-based answers.

BOUNDARY

1. Silent connection check
Before any other LiveLab tool for a new business question or model-building task, call adp_get_connection_info. Continue only if:
- service is ADP;
- adp_user is PEAKGEAR_USER;
- session_ready is true;
- query_result_adapter is peakgear-json-bound-rows-v1.

Use the database URL already configured in the server. Do not ask me to provide or confirm it again. Keep successful connection checks internal.
Never display database URLs, adapter details, credentials, or connection reports. If access fails, briefly explain that LiveLab access must be restored.
Recheck after a connection failure; do not repeat successful checks needlessly.

2. Current database is the source of truth
Use only PEAKGEAR_USER objects. Verify actual object names, types, columns, and definitions through LiveLab MCP before using them.

Do not reuse object names, metadata, figures, or results from previous exercises, reservations, examples, or assistant answers as evidence. Clearly distinguish proposed new objects from verified existing objects.

If discovery fails or is incomplete, retry once appropriately. If verification still fails, say it is incomplete; do not claim that an object is absent.

Do not inspect other schemas, credentials, database links, or catalogs. Do not use local files, shell commands, browser automation, or another MCP server.

3. Reviewed business meaning
Read the saved Data Studio DESCRIPTION and TAGS for the relevant existing source tables and columns.

If essential business meaning is missing, such as metric definitions, row grain, join keys, or the time window, identify the verified object, column, and missing definition precisely. Ask me to review and save it in AI
Enrichment. Do not guess metric definitions or ask me to enrich nonexistent objects. Missing optional wording or an unknown-category rule alone is not a reason to stop; use the explicit default below and continue.

Default for missing category handling
If saved metadata defines how to handle missing categories, follow it. Otherwise, retain products with NULL or blank CATEGORY_NAME in a separate technical bucket labelled "Unknown / Unspecified". Keep their measures in the model and reconciliation, but exclude this bucket from named-category recommendations and report its totals separately. This is an explicit workshop default, not a guessed business category. Do not infer categories from product names or change raw data. If a non-null hierarchy key is needed, use a collision-free technical key only in the derived model.

Preserve existing source labels such as N/A and the literal text null as separate source-labelled buckets; report them separately from recommendations.
Do not require an extra annotation or confirmation just for these cases.
When an AV build is explicitly requested, continue it and mention the default used in one short caveat. This default does not authorize object creation.

Do not automatically require enrichment on every derived object.
Use reviewed source annotations and verified model definitions.

4. Evidence and accuracy
Do not invent objects, columns, joins, product names, categories, periods, figures, or recommendations.

Validate product-key uniqueness and product-to-category relationships.
Do not silently deduplicate ambiguous keys or invent mappings.

Digital events represent customer interest, not purchases or sales.
Returned units are return volumes, not return rates.
Do not invent sales, revenue, profitability, or return rates.

Follow the reviewed rules for unattributed events. For unknown categories, use the saved rule or the explicit default in section 3.
Report relevant exclusions separately; do not silently discard source data.

5. Mandatory Analytic View gate
Category prioritization that balances customer interest with returns requires a validated governed Analytic View covering both measures, the category/product relationship, and the same completed month.

Discover its actual name. One suitable validated AV containing both measures is sufficient; do not require two separate AVs or predetermined object names.

Until the model is verified and validated, do not provide category rankings, figures, provisional recommendations, or partial recommendations. Do not bypass this requirement with raw-table joins or remembered results.

If essential source business meaning is missing, explain that prerequisite first. Missing category handling alone does not block model validation or an explicitly requested AV build: apply the default in section 3.
Otherwise, briefly explain that the governed AV must be created and validated.
Distinguish confirmed absence from incomplete verification.

6. Changes and responses
Do not create or modify objects unless explicitly requested.
Do not drop, truncate, overwrite, or reset existing data without separate
authorization.

For business questions, lead with the business answer, relevant figures, and the actual period. Keep successful technical checks internal.
Mention object names only when needed for the requested build or an actionable issue.

7. Model-building workflow: only when explicitly requested
These rules apply when I explicitly ask you to create or reuse and validate the governed model. They do not authorize creation during boundary setup or while answering a business question.

After the required silent connection check:

a. Discover the actual local tables, columns, saved DESCRIPTION/TAGS, and relevant existing model objects. Batch independent metadata reads where supported. Reuse verified results unless something changes.

b. Reuse an existing suitable Analytic View and its dependencies.
   If none is suitable, create one production-purpose AV with verified, unused names. Do not create exploratory AVs or duplicate suitable models.

c. Use explicit SQL DDL through adp_run_query.
   Do not use adp_build_analytic_view.
   Execute dependent DDL statements in order and inspect each result.
   If the tool cannot execute the required DDL, report that limitation; do not switch to another server or execution method.

d. Validate product-key uniqueness and product-to-category mapping once.
   Stop on ambiguous mappings rather than hiding them with DISTINCT or choosing arbitrary rows.

e. Aggregate digital events and returned quantities independently by product and month before combining them, to prevent join fanout.
   Preserve product-month rows present in either source.
   Use local supporting tables for materialized intermediate results; do not repeatedly query remote sources or recreate existing raw snapshots.

f. Build one AV with product-to-category and month hierarchies and exactly two additive SUM measures: digital event count and returned units.
Use the reviewed definitions and the latest shared completed calendar month available in both sources. Exclude the database's current and future months. Do not assume that historical data represents today's customer activity.

g. Perform one consolidated final health check:
  verify object validity, hierarchy relationships, measure definitions, and category rollup consistency. Reconcile both AV measure totals for the latest shared completed month against the underlying local source tables using the same filters and attribution rules.
  Explain any excluded or unmatched records separately.
  Claim success only after the validation results support it.

h. After a timeout or ambiguous error, inspect whether the affected object already exists and whether the operation completed before retrying.
   Do not blindly rerun CREATE statements or rebuild existing objects.
   Repeat checks only when a failure or change requires them.

For attribution, exclude digital events with NULL PRODUCT_ID from product and category rankings and report their count for the same shared month.
Keep the raw tables intact. Every non-NULL product ID in either fact must map to exactly one catalog product. Report missing products or ambiguous product-key mappings rather than dropping records or inventing mappings.
A missing category on a uniquely mapped product is not an ambiguous product mapping; apply the explicit default in section 3 without blocking the build.

Preserve source category labels such as N/A and the literal text null.
Report those labels separately from named-category recommendations.
Do not assign categories from product names.

For category comparisons, query category rows for the shared month.
Use product detail for drill-down. Do not sum detail rows together with their All-level totals. A store hierarchy is not required.
The raw and supporting tables are snapshots; state their actual source month and do not imply continuous refresh unless it is implemented.

8. Model-building response
After an explicitly requested model-building task, finish with a short summary stating:
- the actual AV name and whether it was created or reused;
- whether validation and reconciliation passed;
- the shared completed month and its two reconciled totals;
- any remaining blocker.

Do not include connection details or a long technical execution report.
Do not make a category recommendation before validation succeeds.

SETUP ACKNOWLEDGMENT

This message establishes the boundary only. It does not authorize object creation or request a business answer. Reply simply:
"Ready. What business question would you like to explore?"
</copy>
~~~

2. If Codex cannot read lab data, restart the local LiveLab process. In macOS Terminal, run:

                ~~~sh
                <copy>
                zsh "$HOME/.local/share/peakgear-livelab/peakgear-livelab-admin.command"
                </copy>
                ~~~

- Choose option **1** to stop and restart only PeakGear LiveLab.


- Create a new Codex task in the same project. If setup used the wrong reservation, first rerun **01-setup-peakgear-mcp.command** with the current database URL and Database Password. Restarting MCP does not replace saved connection details.


- Establish the Task 2 boundary once in the new task before continuing.


- Do not choose the ALL-MCP cleanup options.


## Task 3: Ask the raw-data question

1. In the same Codex task, ask this exact question:

~~~text
<copy>
Which products are customers interested in right now?
</copy>
~~~

2. Check that Codex explains why the raw data cannot answer the question yet. LAB\_DIGITAL\_INTENT\_RAW\_T does not define:

    - Whether interest means events, sessions, or customers.


    - The grain of one row.


    - The period represented by “right now.”


    - A product name to display to a business user.


3. Do not repair the answer with a hand-written SQL ranking. A confident top-five list at this stage is the wrong outcome.

<!-- Re-capture the raw-question screenshot against the local raw tables. -->

### Checkpoint

Codex has proven its PEAKGEAR\_USER MCP session and has made a controlled stop for the raw question.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)
* [Codex project configuration and trust](https://learn.chatgpt.com/docs/config-file/config-basic)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
