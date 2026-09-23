# HOL6091 author review and release checklist

Estimated Time: 10 minutes to review this checklist; allow a separate full dry-run.

## Delivery status

GitHub submission: WMS 12202 / LiveLabs 4526, `lakehouse-medallion`, development branch `codex/hol6091-wms-12202`. The owner confirmed public check-in, including the pre-release UI screenshots. Keep the PR in draft and the LiveLabs listing Private until runtime acceptance. The uppercase source folder remains unchanged.

WMS-specific checks still open: separate common Get Started lab (setup is currently integrated into Lab 1); correct sandbox Need Help variant; final screenshot redaction/cropping review; official lint checker; and all runtime checks below. Do not mark these items complete solely because the local structural validator passed. Repository contribution guidance also requests OCA verification and a sign-off. No legal attestation or sign-off is made on behalf of the owner in this draft submission.

Mode: publish-ready structure with explicit runtime gates. Six learner labs, a loader/manifest, screenshots, an editable SVG flow diagram, workshop metadata, and source traceability are included. This is a reviewable workshop package, not a declaration that the event environment passed every exercise.

User requested new-UI instructions first and legacy instructions only in appendices. That separation is applied to Labs 1–5. Lab 6 has no UI operations requiring a fallback. All project references use `peakgear`, not `peakgear_old`.

## Verified during authoring — 23 September 2026

* New UI Home, Catalog, Transform, Projects, project resources, workflow designer, and an existing job-detail page were inspected.
* The connected UI displayed schema `PG`, catalog mount `PG_AICAT`, and namespaces `bronze` and `silver`.
* The `peakgear` project has the three tier workflows and `WF_MEDALLION_ARCHITECTURE`.
* The Silver designer exposes **Run** in the new UI; legacy uses **Start**.
* Existing Silver job 64 was DONE with zero errors. Its final data load reported 80,001 rows; the workflow total was 240,003 because multiple steps processed the rows.
* The Silver workflow includes `Clear Silver table`. No workflow was rerun during authoring and no target was cleared.
* Public documentation supports catalog SQL discovery, catalog-qualified queries, annotation management/propagation, and Select AI metadata use.

## Known limitations and unverified behavior

* The user confirms mounted Bronze/Silver table listing does not work in parts of the new UI. Namespace visibility was observed; table enumeration was not proven. Do not present a screenshot of namespaces as proof of table discovery.
* The new SQL Worksheet showed Connected / Running as PG / AI Profile ready, but its editor layout was not usable for an end-to-end execution check during this review. No supplied SQL result is represented as runtime-tested.
* Opening the AI Assistant exposed an existing conversation with “Assistant planning is unavailable right now.” No new prompt was submitted. Confirm the Gold-query experience rather than assuming that the general assistant invokes Select AI.
* The inspected header displayed SETUP NEEDED. Resolve or explain that status before recording final event screenshots.
* A legacy direct workflow deep link remained loading; use normal Projects navigation and rehearse both interfaces.
* Workflow and data-flow names are verified. Table/column contracts originate in the supplied run-of-show/build guide and still require dictionary verification against the final event extract.
* Gold lineage, effective West filtering, output column names, metadata persistence, and AI-generation controls require a live final check. The guide does not claim that a native intermediate-table read is an Iceberg read.
* The latest Confluence dataset revision was not revalidated in this build. Freeze the latest approved version and record its revision/date in the event deployment record. Do not silently call an older extract current.

## Mandatory pre-event dry-run

- [ ] Record the approved PeakGear revision and provision the four Bronze tables.
- [ ] Confirm whether quoted namespace owners are `bronze` / `silver`; adjust every SQL block consistently if the SQL listing returns another case.
- [ ] Verify `ALL_TABLES@PG_AICAT`, Bronze sample queries, and Silver reads in both worksheet routes.
- [ ] Verify actual field types, especially `SALE_MONTH`; confirm it represents a month as a DATE.
- [ ] Confirm inventory has one row per store/product, inspect null ATP, inventory snapshot date, missing join keys, and date coverage. Adapt the join only with a documented business rule.
- [ ] Run the fulfillment query and record one expected example or a legitimate empty result.
- [ ] Verify project connection remapping and isolated destructive/reset behavior. Never direct the reset task at shared data.
- [ ] Edit the product-name expression in the deployed designer, including its actual source alias. Capture the final expression UI.
- [ ] Execute Silver once, inspect child jobs, compare the final load count with a SQL count, and test a safe rerun in a disposable environment.
- [ ] Inspect Gold's source lineage. If the lab must prove Silver Iceberg → native Gold, configure and verify that source before publication.
- [ ] Confirm the West filter and aggregation definitions, including weighted aggregate margin percentage and transaction-count semantics.
- [ ] Capture the Gold flow, annotation editor, and resulting table metadata. Verify which annotation names are supported and whether automatic AI generation is available.
- [ ] Verify the optional metadata-generation OpenAI connection and allowed data-sharing policy. Keep manual annotations as a separately labeled fallback.
- [ ] Provision the Select AI profile and object list for PG.GOLD_WEST_PRODUCT_PERFORMANCE; enable annotation/comment inclusion as appropriate, including the supported `annotations` profile attribute. Provide the actual profile name in the private handout.
- [ ] Test SHOWSQL/RUNSQL and the new-UI NLQ route, validate one numeric answer, and confirm West-only interpretation.
- [ ] Capture final SQL, Gold, and NLQ screenshots after the above checks. These screenshots are not fabricated or replaced by mock results in this package.
- [ ] Replace or approve tenant-specific screenshot identifiers for public distribution; do not expose credentials.
- [ ] Rehearse 78 minutes of planned content plus 12 minutes recovery time; provision setup ahead if imports exceed the slot.

## Facilitator transitions

* Lab 1: “Bronze retains, Silver refines, and Gold publishes. Each layer serves a different user.”
* Lab 2: “Watch raw ingestion once; then change one expression and execute the existing workflow yourself.”
* Lab 3: “The analyst can investigate with a cross-tier query without asking engineering to build another pipeline.”
* Lab 4: “The West filter selects the rows. Annotations tell people and configured AI consumers what those rows mean.”
* Lab 6: “Open tables and native Oracle data products can coexist. We used OCI today; compatible multi-cloud and Spark workloads are extensions.”

## Quality and validation boundaries

The final structural validator passed required folders, manifest, and Markdown formatting. A local LiveLabs browser preview rendered Labs 1 and 2, including all referenced images and SQL Copy controls. A separate filesystem check resolved every local image reference across the package. No TODO/TBD placeholders remain; event credentials and the AI profile name intentionally come from the private handout.

FreeSQL is intentionally not used: examples depend on private event catalogs, data, and profiles. SQL appears in copyable blocks for the assigned worksheet. The user chose public documentation and live UI checks instead of providing oracle-db-skills.

Self-grade: 4/5 for structure, concise prose, persona continuity, and separation of verified observations from planned actions. Runtime completeness remains below release acceptance until the checklist is complete. See `validation-result.md` for structural validator output; structural checks do not certify SQL or UI execution.

The validator also emits mechanical Lanham scores. Its contraction check includes possessives, its sentence parser includes SQL/Markdown, and its nominalization check counts product terms such as annotations and connections. These scores are advisory, not runtime or structural acceptance. The editorial self-grade above is a separate manual assessment; retain the raw report for review.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
