# HOL6091 — PeakGear Medallion Pipeline

Estimated Time: 3 minutes to review this handoff.

Six-lab Oracle LiveLabs workshop: **Build a Medallion Data Pipeline with Oracle AI Lakehouse**. WMS **12202** / LiveLabs **4526** / session **HOL6091**.

## Start here

* Learner entry: `workshops/sandbox/index.html`.
* Descriptions and 90-minute agenda: [Workshop details](workshop-details.md).
* Revision details, source review, facilitator script, and release gates: [Author review](author-review.md).
* Source and screenshot provenance: [Traceability](traceability.md).

Use the **new Data Studio UI** and `peakgear_medallion` project. Legacy actions appear only in lab appendices. The October revision follows the narrated successful sequence and supplied working SQL. Mia remains on native Gold; the revised Gold NLQ still needs a live dry-run.

## Preview locally

From this folder, run:

```sh
python3 -m http.server 8000
```

Open `http://localhost:8000/workshops/sandbox/`. Internet access is required for the Oracle LiveLabs loader. Stop the server with Control-C.

## GitHub handoff

The earlier submission was merged in PR 540. The October revision is prepared on `codex/hol6091-mike-review-20261001` for later approval. Review the runtime and contributor checks before requesting a merge.

Do not commit private handouts, credentials, project exports containing secrets, raw recordings, or dataset access URLs. These materials are provisioned separately.

## Status

The procedures and screenshots are grounded in the supplied recording; SQL for Labs 2–4 follows the working-query source. No live workflows were rerun during authoring. Gold reference SQL and Gold NLQ require the event dry-run documented in the author checklist.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
