# Lab 4: Connect Codex and ask the raw-data question

Estimated Time: 8 minutes

## Introduction

Codex is connected through the project-scoped LiveLab MCP server. It is not
given a database administrator account, a source-system secret, or access to
other schemas. The first question is intentionally simple. The correct answer
is not a ranking: raw fields alone do not define what customer interest means.

### Objectives

In this lab, you will:

* connect a clean laptop to the prepared Data Studio environment;
* prove the MCP session is connected as PEAKGEAR&#95;USER; and
* see Codex stop rather than invent a business definition.

### Prerequisites

* Labs 1 through 3 are complete.
* Codex Desktop is installed and signed in.
* You have the Lab Data Studio URL and the PEAKGEAR&#95;USER password.

## Task 1: Set up LiveLab MCP

1. Download the complete starter kit: <a href="https://github.com/oracle-livelabs/adb/raw/refs/heads/main/ai-over-lakehouse/downloads/peakgear-livelab-starter-kit.zip"><strong>Download Here — PeakGear LiveLab Starter Kit (.zip)</strong></a>.

   Unzip `peakgear-livelab-starter-kit.zip`. Keep the extracted `starter-kit` folder intact.
2. In the extracted `starter-kit` folder, double-click `01-setup-peakgear-mcp.command`.
3. Paste the Lab Data Studio URL when asked.
4. Enter the PEAKGEAR&#95;USER password at the hidden password prompt.
5. Choose the current Codex project folder when Finder opens.
6. When setup reports **Success**, open that project in Codex and click
   **Trust** if prompted.
7. Create one new Codex task. Do not edit a Codex configuration file or add an
   MCP server manually.

The setup stores the password in the local macOS Keychain. It does not put the
password, an OAuth token, or a credential in a project file.

> `01-setup-peakgear-mcp.command` and `02-peakgear-livelab-admin.command` must remain together with the other files in the unzipped `starter-kit` folder. Always download the complete ZIP above.

## Task 2: Establish the MCP boundary

Paste this once into the new Codex task:

~~~text
You are the PeakGear business analyst.

For every business question, use only the MCP tools from the LiveLab server.
Before calling any other LiveLab tool, call adp_get_connection_info.
Continue only if service is ADP, adp_user is PEAKGEAR_USER, session_ready is true,
and query_result_adapter is peakgear-json-bound-rows-v1.
If a check fails, stop and report the mismatch.

Use only PEAKGEAR_USER objects. Do not list other schemas, credentials,
database links, or catalogs. Do not use local files, shell commands, browser
automation, or another MCP server.

Read saved Data Studio descriptions and tags before answering a business
question. If required business meaning is missing, state exactly what is
missing instead of making an assumption.
~~~

The first tool call must be **adp&#95;get&#95;connection&#95;info**. Continue only if its
non-secret response shows:

| Field | Required value |
|---|---|
| service | ADP |
| adp&#95;user | PEAKGEAR&#95;USER |
| session&#95;ready | true |
| query&#95;result&#95;adapter | peakgear-json-bound-rows-v1 |

If the check fails, open the unzipped `starter-kit` folder and run
`02-peakgear-livelab-admin.command`. Choose **Start LiveLab cleanly**, then
create a new Codex task.

## Task 3: Ask the raw-data question

Ask exactly this:

~~~text
Which products are customers interested in right now?
~~~

Expected result: Codex should explain why it cannot responsibly answer yet. In
particular, LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;V does not define:

* whether interest means events, sessions, or customers;
* the grain of one row;
* the period represented by “right now”; or
* a product name to display to a business user.

Do not repair the answer with a hand-written SQL ranking. A confident top-five
list at this stage is the wrong outcome.

![Before Data Studio annotations are saved, Codex explains that the raw view does not yet define the ranking.](images/raw-question.png)

### Checkpoint

Codex has proven its PEAKGEAR&#95;USER MCP session and has made a controlled stop
for the raw question.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
