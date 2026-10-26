# Lab 6: What the PeakGear pipeline delivered

## Introduction

Raw PeakGear retail data became a West-region sales answer. Each medallion tier served a different purpose. Oracle Autonomous AI Lakehouse and Data Studio connected the work.

Estimated Time: 4 minutes.

### Objectives

* Summarize the PeakGear business questions and the data used to answer them.
* Explain how medallion tiers, AI Data Catalog, Data Transforms, and SQL worked together.
* Distinguish the lab exercises from possible architectural extensions.

## PeakGear use case summary

Alex, the data engineer, started with PeakGear sales, product, store, and inventory data. Bronze kept source-faithful Apache Iceberg tables in OCI Object Storage. Data Transforms then joined sales with product and store data. It changed product names to Title case and derived sales, cost, and margin measures. Alex published the curated Silver result as another Iceberg table.

Sam, the data analyst, found Bronze inventory through the catalog and queried it alongside Silver sales. He looked for store and product pairs with recent sales above available-to-promise inventory. A positive gap flags a candidate for replenishment review. It reflects past sales, not a forecast or automatic reorder decision.

Alex published West-region product performance to a native Oracle Gold table in `PG`. Catalog AI Enrichment added a West-only description and tag. Mia, the business user, asked for the top ten products by sales amount in the latest available month. She checked that the generated SQL read Gold, then compared its answer with a reference query.

## What you learned

* **Medallion separates responsibilities.** Bronze retains source data. Silver makes it reusable. Gold presents a focused business product.
* **Open and native tables work together.** Bronze and Silver used cataloged Iceberg tables. Gold used native Oracle tables.
* **Discovery supports analysis.** Sam used the catalog and SQL Worksheet to query across tiers without another data copy.
* **AI answers need verification.** Gold metadata explained its West-only scope. Mia checked generated SQL before trusting the result.

This lab ran entirely on OCI with Oracle SQL. A second cloud, Spark workload, or autonomous agent could extend the architecture. The PeakGear use case needed none of them.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team.
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026.
