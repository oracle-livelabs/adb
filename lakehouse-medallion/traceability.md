# Source and asset traceability

Estimated Time: 5 minutes to review.

## Classification

Inputs are user-authored Oracle HOL plans, Oracle application screens, and public Oracle documentation. No third-party images, datasets, copied diagrams, or code are included. No external-source approval gate applies to the materials used. No source bundle's embedded assets were reused. The supplied recording/deck were not reprocessed for this build.

## Content sources

| Source | Classification | Use and boundary |
|---|---|---|
| User's six-lab request and follow-up on peakgear and UI appendices | User-authored Oracle workshop requirements | Persona flow, lab count, scope, UI separation |
| AI World HOL Run-of-Show - PeakGear Medallion Pipeline.md | Supplied Oracle internal source | Timing, tables, fulfillment query, workflows and West metadata; schema still needs final runtime check |
| PeakGear Data Transforms Build Guide.md | Supplied Oracle internal source | Native staging, Silver load, workflow names, Gold dimensions; imported endpoint names are not reused as credentials |
| Signed-in Firefox Data Studio and Data Transforms | Oracle internal event environment | Observed navigation, project and workflow names, existing job status, screenshots |
| Public Oracle documentation linked in learner labs | Oracle-owned public | Product behavior and supported patterns |

Private source URLs and local source paths are intentionally omitted from learner-facing materials and this distributable record. Latest dataset revision remains a deployment check, not a claim established by this build.

## Public documentation

* https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/manage-catalogs-dbms-catalogs.html — SQL catalog discovery and qualified queries.
* https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/manage-catalogs.html — mounted catalog access.
* https://docs.oracle.com/en/database/data-integration/data-transforms/using/view-and-manage-annotations.html — table/column annotation controls and propagation.
* https://docs.oracle.com/en/database/data-integration/data-transforms/releasenotes/whats-new-oracle-data-transforms.html — annotation and connector release context.
* https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai-concepts.html — metadata-assisted natural-language SQL.
* https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/oracle-database-select-ai-users-guide.pdf — profile annotation inclusion and Select AI actions.

## Images and derived content

All PNG screenshots were captured directly from the user's authorized Oracle application session on 23 September 2026. They contain no intentionally exposed credentials. Existing job screenshots are labeled historical, not newly executed results. Tenant identifiers remain visible and need publication review.

* New UI: `catalog.png`, `new-data-studio-home.png`, `new-transform.png`, `new-projects.png`, `new-workflows.png`, `new-silver-workflow.png`, `new-silver-job.png`.
* Legacy UI, referenced only in appendices: `projects.png`, `bronze-silver-workflow.png`, `silver-job-details.png`.
* `medallion-flow.svg`: original code-authored diagram for this workshop, based on the user-provided architecture. No third-party artwork.
* SQL: adapted from the supplied Oracle run-of-show. Changes use the observed mount alias, explicitly verify identifier case, add grain/completeness checks, avoid interpreting null ATP as zero, and label the output as a demand-stock gap rather than proven unfulfilled demand.

No private project ZIP, raw data files, access tokens, client secrets, or model credentials are included.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
