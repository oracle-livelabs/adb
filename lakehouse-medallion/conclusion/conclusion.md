# Lab 6: Connect the medallion journey to business value

## Introduction

You have followed PeakGear data from source-faithful Bronze through reusable Silver to a curated Gold business product. Each layer serves a different consumer without requiring every consumer to rebuild the pipeline.

Estimated Time: 4 minutes. Reserve the remaining 12 minutes of the 90-minute session for troubleshooting and discussion.

### Objectives

* Explain the value of medallion and the three personas.
* Distinguish open-table storage, catalog discovery, processing, and AI consumption.
* Identify what you demonstrated and what remains an architectural extension.

### Prerequisites

Work through Labs 1–5 and record any incomplete checkpoints.

## Task 1: Review the completed journey

1. Describe Alex's work: visual Data Transforms joins and cleanses data, workflows orchestrate it, and Jobs provides execution evidence. Bronze and published Silver use Iceberg; native `PG` tables support intermediate processing and Gold.

2. Describe Sam's work: discover Bronze inventory and join it with Silver sales to investigate inventory coverage. The query reads both tiers without creating another pipeline.

3. Describe Mia's work: select the native Gold table, use Query with AI, and check the generated SQL and West-only scope. Catalog AI Enrichment adds business context; filters and permissions enforce data scope and access.

4. Listen to the facilitator: “Medallion separates raw retention, reusable refinement, and business delivery. An open table format allows compatible engines to work with shared data, while Oracle SQL supports the queries and transformations we used today. We have not run Spark or a second cloud in this lab. The Lakehouse can support selected tiers or the full pattern; not every tier needs the same physical storage.”

## Task 2: Check outcomes and finish

1. Confirm which checkpoints you completed: Bronze query and view registration, Silver workflow, cross-tier SQL, Gold workflow and scope check, Catalog metadata review, and a verified Gold natural-language answer. Record an incomplete checkpoint rather than treating reference SQL alone as a successful AI exercise.

2. Sign out of shared browser sessions as instructed. Leave event-resource cleanup to the facilitator; do not drop shared catalogs or delete object-store data.

3. Discuss an extension: add another compatible cloud/catalog, add a Spark workload, or build an agent that consumes the same curated Gold product. These are next steps, not capabilities exercised in this session.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
