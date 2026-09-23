# Workshop Details

Estimated Time: 90 minutes for the workshop.

## Short Description

Build a PeakGear medallion pipeline with Iceberg Bronze and Silver, native Oracle Gold, visual Data Transforms, cross-tier SQL, and natural-language analytics in Oracle Autonomous AI Lakehouse.

## Long Description

Follow three personas through a retail analytics scenario. As Alex, the data engineer, inspect preloaded Bronze data and run prepared Data Transforms workflows to cleanse Silver and publish a West-region Gold product. As Sam, the analyst, discover inventory data and join it with Silver sales to investigate inventory coverage. As Mia, the business user, use a configured Select AI experience to ask questions of Gold and validate the resulting answer.

The workshop uses OCI Object Storage, Apache Iceberg, Oracle AI Data Catalog, and native Oracle data products. It illustrates a multi-cloud-ready pattern without requiring a second cloud or a Spark deployment. Participants review business metadata that explains Gold's West-only scope. New Data Studio instructions form the main path; legacy UI alternatives are isolated in each affected lab's appendix.

## Workshop Outline

| Lab | Focus | Minutes |
|---|---|---:|
| 1 | Architecture, personas, environment and setup | 22 |
| 2 | Raw-to-Bronze demonstration; query Bronze; cleanse and publish Silver | 24 |
| 3 | Discover inventory and answer a cross-tier business question | 12 |
| 4 | Annotate West scope, publish and validate native Gold | 9 |
| 5 | Ask and validate a natural-language business question | 7 |
| 6 | Conclusion and learning outcomes | 4 |
| Buffer | Troubleshooting and discussion | 12 |
| Total | | 90 |

## Workshop Prerequisites

* Pre-provisioned isolated event database, `PG` schema, Object Storage and AI Catalog mount.
* Current approved PeakGear extract, preloaded Bronze, and imported `peakgear` Data Transforms project.
* Working connections and event credentials delivered separately from public artifacts.
* Approved OpenAI configuration for the event's optional AI metadata-generation feature.
* Select AI profile scoped to the Gold object, with required metadata inclusion and database privileges.
* New UI and legacy URLs, with fallbacks rehearsed by the facilitator.

## Notes

Primary product: Oracle Autonomous AI Lakehouse. Supporting technologies: Oracle AI Data Catalog, Apache Iceberg, OCI Object Storage, Data Studio, Data Transforms, Oracle SQL, and Select AI.

Mode: publish-ready authoring structure; runtime acceptance remains open as recorded in `author-review.md`. This package is not yet certified for unattended learner execution.

Learning outcomes match the abstract: modernize raw-to-curated pipelines, use open-table tiers, orchestrate visual transformations, discover and query governed assets, and consume curated data with AI. No second-cloud execution, Spark execution, or autonomous agent action is claimed.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
