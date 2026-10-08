# PeakGear: from raw sources to governed answers with Codex

Estimated Time: 60 minutes, plus a 15-minute troubleshooting buffer.

This is a five-module Oracle LiveLabs workshop package, numbered **Labs 1–5**.
Participants begin with an already provisioned reservation, use its OCI and
database credentials to connect Data Studio, connect real Iceberg and Operations
data, and then use Codex with Oracle Data Studio MCP. The same business question
becomes more useful as its governed context improves. There is no participant
ADMIN setup.

## Start here

* Learner entry: `../workshops/sandbox/index.html`.
* Agenda and prerequisites: [workshop-details.md](workshop-details.md).
* TLF submission metadata and agent handoff: [tlf-workshop-submission-handoff.md](tlf-workshop-submission-handoff.md).
* Release checks and runtime gates: [author-review.md](author-review.md).
* Screenshot capture and provenance: [traceability.md](traceability.md).
* Provider-only provisioning boundary: [provisioning.md](provisioning.md).
* Copy-ready event values: [event-lab-values.md](../assets/event-lab-values.md).
* Optional source-connection SQL: [scripts/01-connect-event-sources.sql](../scripts/01-connect-event-sources.sql).
* Participant Codex package: [starter-kit](../starter-kit/).

Lab 3 Task 1 provides the read-only SQL to obtain the database-specific ADP_URL
as PEAKGEAR_USER in Data Studio. The reservation provider must validate access
to this lookup before release; participants stop and contact the instructor if
it fails. The lab then provides one Starter Kit download and an explicit
Terminal sequence: download, open Terminal, extract the ZIP, prepare the project
folder, run setup, answer its prompts with ADP_URL and the reservation's
Database Password, open the project in Codex, and create a fresh task. The URL
is obtained before running
01-setup-peakgear-mcp.command. The ZIP README follows the same sequence. No
separate local-event kit is required.

The reservation already provides the participant user and grants, ORDS access,
network ACL, Operations database link, and AI profile. Participants do not
create or change these. Lab 1 separates OCI Login Credentials from Environment
Details and includes two illustrative reservation screenshots; the database
password is redacted. Values from the learner's own reservation are authoritative.

Lab 4 is the only learner module that runs AI Enrichment. It reviews and saves
the descriptions and tags for digital interactions, the product catalog, and
operational returns. Lab 5 reuses those annotations to ask the harder business
question, identify the governed-model gap, create and validate Analytic Views,
and obtain the final governed answer in one module. It does not repeat enrichment.

The data-caching exercise is temporarily excluded from this version. Lab 2
goes directly from the catalog mount to source and product-key validation,
then creates three local raw tables as snapshots for faster analysis. No learner
step creates, populates, enables,
or disables a data-cache policy. Existing database policies are not changed by
this workshop update. Catalog metadata refresh and browser-preview cache
instructions remain separate from data caching.

## Local preview

Use the launcher from the workshop directory. It only starts the server and
keeps the HTTP log in the Terminal; open the lab yourself in Chrome:

```sh
cd /path/to/ai-over-lakehouse
./scripts/preview-livelabs.command
```

For every source edit, use this manual workflow:

1. In the Terminal running the old preview, press Control-C.
2. In Chrome, open DevTools with Command-Option-I. On the **Network** tab,
   select **Disable cache** and keep DevTools open while testing.
3. Start the server with `./scripts/preview-livelabs.command`.
4. Manually open or reload the required lab, for example:
   `http://localhost:8000/workshops/sandbox/index.html?lab=connect-sources`.
5. Check browser rendering and the HTTP errors in the server Terminal.

**Disable cache** applies only while DevTools is open and does not clear
sessions, history, or unrelated sites. To explicitly remove already cached
files instead, keep DevTools open, hold the browser Reload button, and choose
**Empty Cache and Hard Reload**.

If old lab text still appears, compare with
`http://127.0.0.1:8000/workshops/sandbox/index.html`. It uses the same server
and files but a separate browser origin, useful for isolating stale browser
state. This comparison does not clear the existing `localhost` cache.

If port 8000 is already in use, stop its existing preview with Control-C, or
choose another port:

```sh
./scripts/preview-livelabs.command 8001
```

The standard LiveLabs loader requires internet access. A `404` normally means
the server was started from the wrong directory.

## Event values

The event owner explicitly approved including the supplied shared passwords,
Azure storage password, Databricks client ID, client secret, and endpoints in
this one-off workshop package. Lab 2 source-credential and mount steps are ready
for copy/paste; no private handout is required for these shared values. The
participant database password is instead assigned per reservation and must be
copied from LiveLabs **Environment Details**; it is not published in this package.

Lab 3 Task 1 obtains the actual database-specific HTTPS origin through the
provided read-only SQL query, without an ADMIN login. The reservation provider
must verify PEAKGEAR_USER can run it before release. Do not substitute the
Operations database listener or localhost preview URL. ADMIN login, reservation
passwords, personal credentials, and OCI API private keys are not part of the
approved published values. Use the shared source credentials only for the event
and retire them when it ends.

## Status

Offline helper and package regression tests (no database connection):

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s documentation/tests -v
```

These checks cover local-table ranking safeguards, lab numbering, Copy markup, local links,
image alt text, lowercase filenames, and exact ZIP/source-file agreement.
They do not replace live Oracle execution, browser Copy testing, or a complete
reservation dry run.

Workshop structure and learner flow are drafted. Runtime acceptance and the
UI screenshot set remain release gates recorded in `author-review.md`.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
