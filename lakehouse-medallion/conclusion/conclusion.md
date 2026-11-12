# Lab 6: What the PeakGear pipeline delivered

## Introduction

The **PeakGear** team took retail source data from Bronze to reusable Silver and a focused Gold product:

1. Alex prepared the pipeline.
2. Sam compared recent sales with Bronze inventory.
3. Mia reviewed the SQL behind two sales answers.

This final lab brings their work together and separates what the workshop demonstrated from possible architectural extensions.

**Estimated Time:** 4 minutes.

### Objectives

* Summarize the PeakGear business questions and the data used to answer them.
* Explain how medallion tiers, AI Data Catalog, Data Transforms, and SQL worked together.
* Distinguish the lab exercises from possible architectural extensions.

## PeakGear use case summary

**Alex, the data engineer**, started with PeakGear sales, product, store, and inventory data. Bronze kept source-faithful Apache Iceberg tables in OCI Object Storage. Data Transforms joined sales with product and store data, changed product names to Title case, and derived sales, cost, and margin measures. Alex then published the curated Silver result as another Iceberg table.

**Sam, the data analyst**, found Bronze inventory through the catalog and queried it alongside Silver sales. He looked for store and product pairs where recent sales exceeded available-to-promise inventory. A positive gap flags a candidate for replenishment review. It reflects past sales, not a forecast or an automatic reorder decision.

**Alex** published West-region product performance to a native Oracle Gold table in `PG`. Catalog AI Enrichment added a West-only description and tag. Mia, the business user, asked for the top ten products by sales amount in the latest available month. She reviewed the generated SQL and compared the West answer with a reference query.

## What you learned

* **Medallion separates responsibilities.** Bronze retains source data. Silver makes it reusable. Gold presents a focused business product.
* **Open and native tables work together.** Bronze and Silver used cataloged Iceberg tables. Gold used native Oracle tables.
* **Discovery supports analysis.** Sam used the catalog and SQL Worksheet to query across tiers without another data copy.
* **AI answers need verification.** Gold metadata explained its West-only scope. Mia checked generated SQL before trusting the result.

**Note:** This lab ran entirely on OCI with Oracle SQL. A second cloud, Spark workload, or autonomous agent could extend the architecture. The PeakGear use case needed none of them.

## Acknowledgements

* **Authors** - Ashish Jain, Sofia Arceo
* **Contributors** - Teodor C. Nechita
* **Last Updated By/Date** - Teodor C. Nechita, November 2026
