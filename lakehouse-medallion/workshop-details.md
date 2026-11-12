# Workshop Details

Estimated Time: 90 minutes for the workshop.

### Objectives

Describe the workshop scope, schedule, prerequisites, and learner outcomes for WMS 12202.

## Short Description

Build a PeakGear medallion pipeline with Bronze and Silver Iceberg tables, a native Oracle Gold product, visual Data Transforms, cross-tier SQL, and natural-language queries in Oracle Autonomous AI Lakehouse.

## Long Description

Follow Alex, Sam, and Mia through a retail analytics scenario. Alex inspects preloaded Bronze data, sets a Title case cleansing rule for product names, and runs Data Transforms workflows to publish enriched Silver sales and a West-region Gold product. Sam finds Bronze inventory in the catalog and queries it alongside Silver sales to investigate inventory coverage. Mia asks two natural-language sales questions, reviews the generated SQL, and checks the results against reference queries.

The workshop uses OCI Object Storage, Apache Iceberg, Oracle AI Data Catalog, and native Oracle data products. It runs on OCI and does not require a second cloud or a Spark deployment. After Gold is loaded, attendees use Catalog AI Enrichment to review and refine descriptions and tags for its West-only scope. Rebuilding the Data Load is an optional extension outside the core agenda.

## Workshop Outline

| Lab | Focus | Minutes |
|---|---|---:|
| 1 | Meet the team, the tiers, and the Data Studio environment | 22 |
| 2 | Inspect Bronze, review transformations, and publish Silver | 27 |
| 3 | Find inventory and compare it with recent sales | 12 |
| 4 | Publish and validate the West-region Gold product | 12 |
| 5 | Generate and check SQL for two sales questions | 8 |
| 6 | Review the PeakGear pipeline and workshop outcomes | 4 |
| Buffer | Troubleshooting and discussion | 5 |
| Total | | 90 |

## Workshop Prerequisites

* Pre-provisioned isolated event database, `PG` schema, Object Storage and AI Catalog mount.
* Current approved PeakGear extract, preloaded Bronze, and imported `peakgear_medallion` Data Transforms project with tested defaults.
* Working connections and event credentials delivered separately from public artifacts.
* Tested, approved model configuration for Catalog AI Enrichment; model credentials remain outside the learner material.
* Select AI profile scoped to the Gold object, with required metadata inclusion and database privileges.
* Current Data Studio UI and the SQL-generation configuration, rehearsed by the facilitator.

## Notes

Primary product: Oracle Autonomous AI Lakehouse. Supporting technologies: Oracle AI Data Catalog, Apache Iceberg, OCI Object Storage, Data Studio, Data Transforms, Oracle SQL, and Select AI.

Runtime acceptance remains open. This package is not yet certified for unattended learner execution.

Learning outcomes match the abstract: modernize raw-to-curated pipelines, use open-table tiers, orchestrate visual transformations, discover and query governed assets, and consume curated data with AI. No second-cloud execution, Spark execution, or autonomous agent action is claimed.

## Acknowledgements

* **Authors** - Ashish Jain, Sofia Arceo
* **Contributors** - Teodor C. Nechita
* **Last Updated By/Date** - Teodor C. Nechita, November 2026
