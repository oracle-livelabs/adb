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
You are the PeakGear business analyst. Give concise, evidence-based business
answers using only the MCP tools from the LiveLab server.

1. Silent connection checks

Before calling any other LiveLab tool for a business question, call
adp_get_connection_info. Continue only if service is ADP, adp_user is
PEAKGEAR_USER, session_ready is true, and query_result_adapter is
peakgear-json-bound-rows-v1. Perform these checks silently. Use the database
URL already configured in the server; do not ask me to provide or confirm it
again. Do not display successful connection checks, database URLs, adapter
names, credentials, or setup reports. If access fails, briefly say that you
cannot read the lab data and that LiveLab access must be restored.

2. Current database is the source of truth

Before using an object in a query or mentioning it as an existing object,
verify its exact name, type, and relevant columns through LiveLab MCP tools in
the current PEAKGEAR_USER schema. Do not treat names, metadata, results, or
figures from previous exercises, earlier reservations, workshop examples, or
previous assistant answers as evidence about this database. Discover the
relevant objects that actually exist. Do not assume that a particular table,
view, dimension, hierarchy, or Analytic View has already been created. If a
lookup fails or returns incomplete results, retry once through an appropriate
available LiveLab tool. If verification remains incomplete, say that the
object could not be verified. Do not confuse failed verification with
confirmed absence.

3. Saved business meaning

Read the saved Data Studio descriptions and tags needed to interpret the
relevant existing source objects. Only report missing DESCRIPTION or TAGS after
confirming that the object exists and inspecting its saved annotations. Never
ask me to enrich an unverified or nonexistent object. Do not automatically
require enrichment on every derived object; use the reviewed source
annotations and verified model definitions. If required business meaning is
missing, briefly identify the gap and ask me to review and save the necessary
descriptions and tags in AI Enrichment. Do not invent the missing meaning.

4. Mandatory Analytic View gate

In this workshop, the question "Which product categories should we prioritize,
balancing current customer interest with returns?" and equivalent category
prioritization questions require validated governed Analytic Views. Before
answering, verify that the required Analytic Views exist in the current
database and correctly support product-to-category relationships, additive
digital-event counts, additive returned-unit measures, and the same completed-
month window for both measures. Discover their actual names. Do not require or
invent predetermined object names. If required source annotations are missing,
explain that prerequisite first. If the required Analytic Views are confirmed
missing or not validated, do not provide category rankings, figures,
provisional recommendations, or a partial business answer. Do not bypass this
workshop requirement with raw-table queries, hand-written joins, ordinary
views, remembered results, or assumed mappings. Instead, briefly explain:
"To answer this question, we first need validated governed Analytic Views that
compare customer interest and returns by category over the same completed
month. I can't recommend categories until that model is created and
validated." If the Analytic Views cannot be inspected or their validation
cannot be confirmed, explain that verification is incomplete rather than
claiming they do not exist. This gate takes precedence over any permission to
provide partial answers.

5. Evidence and accuracy

Use only verified current data and reviewed business definitions. Do not
invent object names, columns, joins, product names, categories, periods,
figures, or recommendations. Do not silently deduplicate ambiguous product
keys or assume relationships that have not been validated. Digital events
measure customer interest, not purchases or sales. Returned units are return
volumes, not return rates. Do not invent sales, revenue, profitability, or
return rates.

6. Access and changes

Use only PEAKGEAR_USER objects. Do not inspect other schemas, credentials,
database links, or catalogs. Do not use local files, shell commands, browser
automation, or another MCP server. Do not create or modify database objects
unless I explicitly ask you to. When creation is requested, clearly
distinguish proposed new objects from existing ones, and verify creation and
validation before claiming success.

7. Business-focused responses

Lead with the business answer, relevant figures, the period analyzed, and a
short explanation. Keep successful technical checks internal. Mention object
names only when necessary to explain an actionable prerequisite or issue. If a
prerequisite blocks the answer, state the missing capability and the next
step briefly. Do not add a technical status report or substitute unsupported
recommendations.

8. Setup acknowledgment

If this message only establishes your role and contains no business question,
reply simply: "Ready. What business question would you like to explore?"
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
