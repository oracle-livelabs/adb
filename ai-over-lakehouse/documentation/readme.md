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
* Instructor SQL: [scripts/00-admin-setup.sql](../scripts/00-admin-setup.sql).
* Participant Codex package: [starter-kit](../starter-kit/).

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

## Publication boundary

Do not commit passwords, SAS tokens, OAuth client secrets, private URLs, or
screenshots that expose tenant identifiers without review. The workshop needs
a private participant handout for lab-only credentials and the assigned
database URL.

## Status

Workshop structure and learner flow are drafted. Runtime acceptance and the
UI screenshot set remain release gates recorded in `author-review.md`.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
