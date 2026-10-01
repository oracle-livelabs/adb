# Source and asset traceability

Estimated Time: 5 minutes to review.

## Source classification

The current sources are Oracle-authored internal peer feedback, user-supplied Oracle workshop SQL, an authorized Oracle application walkthrough with narration, and public Oracle documentation. Embedded assets were inspected separately: the review document contains Oracle application screenshots, including error states and visible credentials. Those review screenshots were not published.

No third-party artwork, copied dataset, or external adapted code is included. No external-source permission gate applies. Private source paths, credentials, raw recordings, review documents, and unredacted frame extracts remain outside the repository.

## Source precedence

| Source | Use |
|---|---|
| Current narrated Oracle application walkthrough | Primary successful procedure, current UI labels, exact project/flow names, real screenshot frames |
| Supplied working SQL | Bronze and Silver identifiers, inventory checks and analysis, Gold sample/scope checks |
| Internal peer review | Navigation clarity, setup simplification, expected results, removed failed edit exercise, scope explanations |
| Workshop owner's Gold decision | Mia remains on native Gold; the final recorded native-Silver query is adapted, not represented as a Gold success |
| Prior workshop plan | Six persona-led labs, 90 minutes, main new UI and legacy appendices |
| Public Oracle documentation | General catalog and Select AI behavior; not proof of event UI runtime success |

## Public documentation reviewed

* [Manage catalogs](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/manage-catalogs.html)
* [Manage catalogs with DBMS_CATALOG](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/manage-catalogs-dbms-catalogs.html)
* [Select AI concepts](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai-concepts.html)
* [Data Transforms annotations](https://docs.oracle.com/en/database/data-integration/data-transforms/using/view-and-manage-annotations.html)

Data Transforms annotation documentation is distinct from the Catalog AI Enrichment UI demonstrated here. The revision does not substitute one feature's documentation as proof of the other.

## Published screenshot provenance

Each PNG below is derived from the supplied October 1 Oracle UI recording. Cropping excludes browser chrome, login/reservation screens, private messages, and irrelevant windows. Where needed, neutral masks cover database identifiers. UI results were not fabricated or changed.

| Image | Recording position | What it establishes |
|---|---|---|
| review-projects.png | 05:00 | peakgear_medallion project |
| review-column-mapping.png | 09:45 | Prepared expressions and Column Mapping tab |
| review-silver-workflow.png | 10:15 | Four-step Silver workflow and Run |
| review-silver-job.png | 13:00 | Child-job monitoring while still running, not final success |
| review-catalog-tiers.png | 21:30 | Mounted Bronze and Silver tables |
| review-inventory-result.png | 19:30 | Successful cross-tier inventory query result |
| review-gold-workflow.png | 20:12 | Silver registration and Gold flow sequence |
| review-gold-enrichment.png | 21:50 | Generated Gold descriptions and tags, before Save |
| review-gold-metadata.png | 22:00 | Gold Overview with saved metadata |
| review-query-with-ai.png | 25:15 | Gold detail pane and Query with AI control only; no successful NLQ result claimed |

The earlier screenshots are superseded by this set. The medallion SVG is original code-authored workshop artwork, revised to distinguish Data Transforms preparation from Catalog enrichment.

## SQL and outcome boundaries

Labs 2–4 retain the supplied SQL, allowing only formatting changes. Lab 5 intentionally changes the native-Silver source to the exact native Gold table and removes redundant West predicates because the owner confirmed Gold contains only West. Its final runtime test remains open.

Sample inventory and Gold counts are examples, not fixed guarantees for every extract. No latest-dataset certification, Spark execution, second-cloud execution, agent action, or measured improvement in NLQ accuracy is claimed.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
