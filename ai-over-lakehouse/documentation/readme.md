# PeakGear: from raw sources to governed answers with Codex

Estimated Time: 75 minutes, plus a 15-minute troubleshooting buffer.

This is a seven-lab Oracle LiveLabs workshop package. Participants begin as
`ADMIN`, prepare a safe PeakGear participant schema, connect real Iceberg and
Operations data, and then use Codex with Oracle Data Studio MCP. The same
business question becomes more useful as its governed context improves.

## Start here

* Learner entry: `../workshops/sandbox/index.html`.
* Agenda and prerequisites: [workshop-details.md](workshop-details.md).
* TLF submission metadata and agent handoff: [tlf-workshop-submission-handoff.md](tlf-workshop-submission-handoff.md).
* Release checks and runtime gates: [author-review.md](author-review.md).
* Screenshot capture and provenance: [traceability.md](traceability.md).
* ADMIN SQL: [scripts/00-admin-setup.sql](../scripts/00-admin-setup.sql).
* Copy-ready event values: [event-lab-values.md](../assets/event-lab-values.md).
* Optional source-connection SQL: [scripts/01-connect-event-sources.sql](../scripts/01-connect-event-sources.sql).
* Participant Codex package: [starter-kit](../starter-kit/).

Lab 4 provides one Starter Kit download and an explicit Terminal sequence:
download, open Terminal, extract the ZIP, prepare the project folder, obtain the
Data Studio URL with the read-only ADMIN SQL query, sign back in as
PEAKGEAR_USER, run setup, answer its prompts, open the project in Codex, and
create a fresh task. The URL is obtained before running
01-setup-peakgear-mcp.command. The ZIP README follows the same sequence. No
separate local-event kit is required.

The participant performs the `ADMIN` setup in Lab 1. The default AI profile
is preconfigured for the lab: participants do not create, change, or validate
an AI profile.

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
this one-off workshop package. Lab 1 ADMIN SQL and Lab 3 UI steps are ready for
copy/paste; no private handout is required for these values. The default password
for a new PEAKGEAR_USER created in Lab 1 is Welcome123456. Existing accounts are
not reset.

The participant Data Studio URL must still be generated for the assigned
database by the ADMIN query in Lab 1. Do not substitute the Operations database
listener or localhost preview URL. ADMIN login, personal credentials, and OCI
API private keys are not part of the approved published values. Use these shared
credentials only for the event and retire them when it ends.

## Status

Workshop structure and learner flow are drafted. Runtime acceptance and the
UI screenshot set remain release gates recorded in `author-review.md`.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
