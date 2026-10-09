# Lab 3: Connect Codex and ask the raw-data question

Estimated Time: 8 minutes

## Introduction

Codex is connected through the project-scoped LiveLab MCP server. It is not
given a database administrator account. The MCP launcher does not need the
Azure or Databricks secret: those are stored in database-owned credentials.
The first question is intentionally simple. The correct answer
is not a ranking: raw fields alone do not define what customer interest means.

### Objectives

In this lab, you will:

* connect a clean laptop to the prepared Data Studio environment;
* establish a quiet PEAKGEAR&#95;USER connection check; and
* see Codex stop rather than invent a business definition.

### Prerequisites

* Labs 1 and 2 are complete.
* Codex Desktop is installed and signed in.
* Data Studio SQL Worksheet is connected to your reservation as
  PEAKGEAR&#95;USER. Keep LiveLabs **Environment Details** open for the Database
  Password.

## Task 1: Set up LiveLab MCP

1. **Obtain your AI Lakehouse URL.** In the connected Data Studio **SQL
   Worksheet** as PEAKGEAR&#95;USER, run:

~~~sql
<copy>
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
</copy>
~~~

   Copy the HTTPS value returned as **ADP&#95;URL**. This is the base URL for
   your assigned AI Lakehouse database. Run it in **Data Studio**, not Terminal,
   and keep Data Studio connected to your reserved database. The reservation
   must permit this read-only lookup for PEAKGEAR&#95;USER. If it reports an
   access error or returns no URL, stop and contact the instructor; do not
   grant privileges or switch to ADMIN.

2. **Download the Starter Kit.** Click
   <a href="../downloads/peakgear-livelab-starter-kit.zip" download="peakgear-livelab-starter-kit.zip"><strong>Download Here — PeakGear LiveLab Starter Kit (.zip)</strong></a>.
   Save it in **Downloads** as `peakgear-livelab-starter-kit.zip`. Keep the ZIP;
   you will unpack it in Terminal. If the browser adds `(1)` or another suffix,
   rename the downloaded file to the exact name above before continuing.
   There is only one Starter Kit.

3. **Open Terminal.** Press **Command-Space**, type **Terminal**, and press
   **Return**. Keep this Terminal window open for the following steps.

4. **Unpack the ZIP and prepare the project folder.** Copy this entire block
   into Terminal using **Copy**, then press **Return**:

~~~sh
<copy>
cd "$HOME/Downloads"
PEAKGEAR_KIT_DIR="$(mktemp -d "$HOME/Downloads/peakgear-starter.XXXXXX")"
ditto -x -k "peakgear-livelab-starter-kit.zip" "$PEAKGEAR_KIT_DIR"
mkdir -p "$HOME/Documents/peakgear-livelab"
cd "$PEAKGEAR_KIT_DIR/starter-kit"
</copy>
~~~

   You are now in the extracted `starter-kit` folder. A fresh extraction keeps
   older downloaded copies unchanged.

5. **Run setup.** Return to the same Terminal window. Paste this command and
   press **Return**:

~~~sh
<copy>
zsh ./01-setup-peakgear-mcp.command
</copy>
~~~

   Wait while setup installs the required packages. Do not run extra install
   commands. Setup does not require your Mac administrator password.

6. **Answer the setup prompts in order.**

   | Prompt | What to do |
   |---|---|
   | Lab Data Studio URL | Paste the ADP&#95;URL result copied in step 1, then press Return. Do not use localhost:8000. |
   | Password for PEAKGEAR&#95;USER | Copy Database Password from LiveLabs Reservation Information → Environment Details. Paste it into Terminal, then press Return. Nothing appears while you type or paste; this is normal. |
   | Finder folder picker | Open Documents, select peakgear-livelab, then click Choose. This is the folder created in step 4. |
   | Success / Press Return to close this window | Confirm the displayed URL and PEAKGEAR&#95;USER, then press Return. |

   Use your reservation's **Database Password**, not its OCI Login Credentials
   password, a screenshot's example, or your Mac password.

7. **Open the project in Codex.** After setup finishes, run this in Terminal:

~~~sh
<copy>
open -a Codex "$HOME/Documents/peakgear-livelab"
</copy>
~~~

   Click **Trust** if Codex asks whether you trust this project.

8. **Create a new Codex task in the peakgear-livelab project.** Select the
   project opened in step 7, then create the task there. LiveLab starts
   automatically for that new task. Continue with Task 2 in that task; do not
   reuse a task from another project or an older task.

**Setup checkpoint:** entering the credentials and seeing setup succeed are
not yet proof that your Codex task is connected. Task 2 checks the active
connection silently before the business question. Keep this new task open for
Labs 4–5.

The setup stores the connection password in the local macOS Keychain. It does
not write that password or source tokens into the generated project
configuration. The event values are intentionally documented in the workshop.

> Keep the whole extracted `starter-kit` folder. Both numbered scripts and the
> supporting files belong to the same kit. You do not need to edit TOML or
> install Python or uv manually.

## Task 2: Establish the MCP boundary

In the new task created in Task 1, paste this boundary prompt once. Wait for
**Ready. What business question would you like to explore?**, then continue to
Task 3. The connection checks remain internal to Codex.

~~~text
<copy>
You are the PeakGear business analyst. Use only MCP tools from the
LiveLab server and give concise, evidence-based answers.

BOUNDARY

1. Silent connection check
Before any other LiveLab tool for a new business question or model-building
task, call adp_get_connection_info. Continue only if:
- service is ADP;
- adp_user is PEAKGEAR_USER;
- session_ready is true;
- query_result_adapter is peakgear-json-bound-rows-v1.

Use the database URL already configured in the server. Do not ask me to
provide or confirm it again. Keep successful connection checks internal.
Never display database URLs, adapter details, credentials, or connection
reports. If access fails, briefly explain that LiveLab access must be restored.
Recheck after a connection failure; do not repeat successful checks needlessly.

2. Current database is the source of truth
Use only PEAKGEAR_USER objects. Verify actual object names, types, columns,
and definitions through LiveLab MCP before using them.

Do not reuse object names, metadata, figures, or results from previous
exercises, reservations, examples, or assistant answers as evidence.
Clearly distinguish proposed new objects from verified existing objects.

If discovery fails or is incomplete, retry once appropriately. If verification
still fails, say it is incomplete; do not claim that an object is absent.

Do not inspect other schemas, credentials, database links, or catalogs.
Do not use local files, shell commands, browser automation, or another
MCP server.

3. Reviewed business meaning
Read the saved Data Studio DESCRIPTION and TAGS for the relevant existing
source tables and columns.

If required metadata is missing, identify the verified object, column,
and missing annotation or business definition precisely. Ask me to review
and save it in AI Enrichment. Do not guess metric definitions or ask me
to enrich nonexistent objects.

Do not automatically require enrichment on every derived object.
Use reviewed source annotations and verified model definitions.

4. Evidence and accuracy
Do not invent objects, columns, joins, product names, categories, periods,
figures, or recommendations.

Validate product-key uniqueness and product-to-category relationships.
Do not silently deduplicate ambiguous keys or invent mappings.

Digital events represent customer interest, not purchases or sales.
Returned units are return volumes, not return rates.
Do not invent sales, revenue, profitability, or return rates.

Follow the reviewed rules for unattributed events and unknown categories.
Report relevant exclusions separately; do not silently discard source data.

5. Mandatory Analytic View gate
Category prioritization that balances customer interest with returns requires
a validated governed Analytic View covering both measures, the category/product
relationship, and the same completed month.

Discover its actual name. One suitable validated AV containing both measures
is sufficient; do not require two separate AVs or predetermined object names.

Until the model is verified and validated, do not provide category rankings,
figures, provisional recommendations, or partial recommendations. Do not
bypass this requirement with raw-table joins or remembered results.

If required source metadata is missing, explain that prerequisite first.
Otherwise, briefly explain that the governed AV must be created and validated.
Distinguish confirmed absence from incomplete verification.

6. Changes and responses
Do not create or modify objects unless explicitly requested.
Do not drop, truncate, overwrite, or reset existing data without separate
authorization.

For business questions, lead with the business answer, relevant figures,
and the actual period. Keep successful technical checks internal.
Mention object names only when needed for the requested build or an
actionable issue.

SETUP ACKNOWLEDGMENT

This message establishes the boundary only. It does not authorize object
creation or request a business answer. Reply simply:
"Ready. What business question would you like to explore?"
</copy>
~~~

If Codex says that it cannot read lab data, open Terminal and run:

~~~sh
<copy>
zsh "$HOME/.local/share/peakgear-livelab/peakgear-livelab-admin.command"
</copy>
~~~

Choose **1 — Start LiveLab cleanly — stop PeakGear LiveLab only**, then create a
new Codex task in the same project. If setup used the wrong reservation, rerun
**01-setup-peakgear-mcp.command** with the current database URL and Database
Password first. A process restart does not replace saved connection details.
Do not choose the ALL-MCP cleanup options.

## Task 3: Ask the raw-data question

Ask exactly this:

~~~text
<copy>
Which products are customers interested in right now?
</copy>
~~~

Expected result: Codex should explain why it cannot responsibly answer yet. In
particular, LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;T does not define:

* whether interest means events, sessions, or customers;
* the grain of one row;
* the period represented by “right now”; or
* a product name to display to a business user.

Do not repair the answer with a hand-written SQL ranking. A confident top-five
list at this stage is the wrong outcome.

<!-- Re-capture the raw-question screenshot against the local raw tables. -->

### Checkpoint

Codex has proven its PEAKGEAR&#95;USER MCP session and has made a controlled stop
for the raw question.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)
* [Codex project configuration and trust](https://learn.chatgpt.com/docs/config-file/config-basic)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
