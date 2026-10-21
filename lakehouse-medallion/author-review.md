# HOL6091 author review and release gates

Estimated Time: 10 minutes to review; allow a separate full dry-run.

### Objectives

Confirm the event dry-run gates and release boundaries before requesting production approval.

This is an internal author checklist for WMS 12202 / HOL6091. The October 21 revision is under review on draft PR #557. It is not an approval or production acceptance.

## Applied revision

| Area | Change |
|---|---|
| Persona and architecture | Alex, Sam, and Mia remain in the body; lab titles use task names. Gold is described as native Oracle `PG` tables. |
| Setup | Use **View Login Info**, the assigned database region/compartment, and separate OCI and `PG` credentials. No secrets appear in lab screenshots. |
| Bronze and Silver | Avoid duplicate sample browsing; clarify statement execution; teach the `PRODUCT_NAME` Title case cleanse; show derived measures in Silver. |
| Data Load | Document the narrated Oracle-to-Iceberg Data Load as an optional isolated-environment extension. Core workflow remains prepared. |
| Analyst | Keep catalog discovery, join-grain checks, and cross-tier ATP analysis; simplify worksheet instructions. |
| Gold | Show Sample Data and Statistics; attendees add a West-only table description and `west` tag through Catalog AI Enrichment. |
| Mia | Use SQL Worksheet's **Generate SQL with AI** twice. Both prompts must query Gold; inspect and repair generated SQL before execution. |
| Navigation | Remove all legacy UI appendices. |
| Images | Add cropped frames from the new recording for the changed controls; keep raw credential screens out of Git. |

## Event dry-run gates

- [ ] Freeze the approved PeakGear extract and confirm isolated attendee databases/projects.
- [ ] Confirm the imported `peakgear_medallion` project and its workflow/Data Load names match the current environment. The prior screenshot named a final load `dl_silver_enriched_sales_stage`, while the new recording shows `dl_silver_enriched_sales`; reconcile before release.
- [ ] Confirm `wf_01_raw_to_bronze` registers the intended views over preloaded Iceberg tables.
- [ ] Save the Title case rule and run `wf_02_bronze_to_silver` in a clean attendee clone. A validation warning appeared in the recording; do not ask learners to ignore it. Repair the event artifact if it recurs.
- [ ] Verify optional Data Load creation and workflow replacement only in an isolated clone. Exclude it from the 90-minute core if it exceeds time or risks the prepared workflow.
- [ ] Run every worksheet SQL block against the final event catalog and confirm the cross-tier grain and ATP assumptions.
- [ ] Verify that `PG."ailh_enriched_sales_v"` used by Gold reads published Silver, not merely an intermediate native copy.
- [ ] Run `wf_03_silver_to_gold`, confirm West-only rows, inspect Statistics, save/reopen Catalog description and tag, and confirm persistence.
- [ ] Test both exact Mia prompts in the current worksheet UI. Verify the AI-generated and any manually repaired main and latest-month sources use Gold; compare against reference totals.
- [ ] Rehearse the 90-minute schedule with a five-minute buffer. Assess whether setup needs more time; move the optional Data Load out of the event if so.
- [ ] Complete LiveLabs reviewer checks and owner sign-off before any WMS or production submission.

## Scope boundaries

The lab runs on OCI. Spark and a second cloud are architectural extensions, not demonstrated workloads. Catalog metadata provides business context; it neither selects rows nor guarantees AI table choice. The Gold filter and database privileges govern actual scope and access. The AI exercise counts only when a reviewed natural-language-generated query runs against Gold; the reference SQL alone is not a substitute.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
