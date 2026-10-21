# Workshop Details

Estimated Time: 90 minutes for the workshop.

### Objectives

Capture the workshop scope, schedule, prerequisites, and learner outcomes for WMS 12202.

## Short Description

Build a PeakGear medallion pipeline with Iceberg Bronze and Silver, native Oracle Gold, visual Data Transforms, cross-tier SQL, and natural-language analytics in Oracle Autonomous AI Lakehouse.

## Long Description

Follow three personas through a retail analytics scenario. As Alex, the data engineer, inspect preloaded Bronze data, set a Title case cleansing rule for product names, and run Data Transforms workflows to publish enriched Silver sales and a West-region Gold product. As Sam, the analyst, discover Bronze inventory and join it with Silver sales to investigate inventory coverage. As Mia, the business user, ask two natural-language sales questions, inspect the generated SQL, and validate both Gold answers.

The workshop uses OCI Object Storage, Apache Iceberg, Oracle AI Data Catalog, and native Oracle data products. It illustrates a multi-cloud-ready pattern without requiring a second cloud or a Spark deployment. Attendees use Catalog AI Enrichment after Gold is loaded, reviewing and refining descriptions and tags that explain its West-only scope. A Data Load rebuild is an optional extension outside the core agenda.

## Workshop Outline

| Lab | Focus | Minutes |
|---|---|---:|
| 1 | Architecture, personas, environment and setup | 22 |
| 2 | Ingestion overview; query Bronze; register views; cleanse names and run Silver | 27 |
| 3 | Discover inventory and answer a cross-tier business question | 12 |
| 4 | Publish native Gold, enrich metadata, and validate West scope | 12 |
| 5 | Ask and validate two natural-language Gold questions | 8 |
| 6 | Conclusion and learning outcomes | 4 |
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

Mode: publish-ready authoring structure; runtime acceptance remains open as recorded in `author-review.md`. This package is not yet certified for unattended learner execution.

Learning outcomes match the abstract: modernize raw-to-curated pipelines, use open-table tiers, orchestrate visual transformations, discover and query governed assets, and consume curated data with AI. No second-cloud execution, Spark execution, or autonomous agent action is claimed.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
