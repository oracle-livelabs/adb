# HOL6091 — PeakGear Medallion Pipeline

Estimated Time: 3 minutes to review this handoff.

Six-lab Oracle LiveLabs workshop: **Build a Medallion Data Pipeline with Oracle AI Lakehouse**. WMS ID: **12202**. LiveLabs ID: **4526**. Event session: **HOL6091**.

## Start here

* Learner entry: `workshops/sandbox/index.html`.
* Workshop metadata and 90-minute agenda: [workshop-details.md](workshop-details.md).
* Release checks, limitations, and facilitator notes: [author-review.md](author-review.md).
* Source and screenshot provenance: [traceability.md](traceability.md).

The main path uses the **new Data Studio UI** and the **peakgear** project. Old/legacy UI instructions and screenshots are confined to appendices in the relevant labs. A known new-UI limitation prevents some mounted Bronze/Silver table listings; SQL discovery and legacy routes keep that limitation explicit.

## Preview locally

From this folder, run:

```sh
python3 -m http.server 8000
```

Open `http://localhost:8000/workshops/sandbox/`. Internet access is required for the standard Oracle LiveLabs loader. Stop the server with Control-C.

## GitHub handoff

This `lakehouse-medallion` directory is the GitHub submission copy of the local HOL6091 package. Filenames use lowercase to follow WMS guidance. The manifest title and help alias match WMS. Review the author checklist before requesting a production merge. The six-lab scope and new/legacy UI separation remain unchanged.

Do not commit credentials, project exports containing secrets, attendee handouts, or private dataset URLs. The project ZIP and raw data are provisioned separately and are not embedded in this package. Review tenant identifiers in screenshots before public publication.

## Status

Content and navigation are authored. Existing project/workflow names and an earlier successful Silver job were inspected live. End-to-end execution, cross-tier SQL, persisted Gold annotations, AI generation, and Select AI answers require the event dry-run listed in `author-review.md`.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
