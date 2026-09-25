# Lab 6: Identify the governed-model gap

Estimated Time: 5 minutes

## Introduction

The first enrichment contract made one raw source answerable. The next question
combines digital behavior, a product hierarchy, and operational returns. A
one-off join would be technically possible but would not be a shared,
reviewable, reusable business model.

### Objectives

In this lab, you will:

* add the remaining source contracts in Data Studio; and
* see why a cross-source recommendation needs Analytic Views.

## Task 1: Enrich the product catalog

In **Catalog**, open LAB&#95;PRODUCTS&#95;RAW&#95;V and run **AI Enrichment**. Review and
save these business definitions:

| Object | Description | Tags |
|---|---|---|
| View | One row per product. Conformed catalog shared by digital intent and returns. Category rolls up product. | product&#95;catalog, conformed&#95;dimension, category&#95;hierarchy |
| PRODUCT&#95;ID | Shared product join key. | product&#95;key, join&#95;key |
| PRODUCT&#95;NAME | Business-facing product name. | product&#95;name |
| CATEGORY&#95;NAME | Category used to aggregate products. | category, hierarchy&#95;level |

## Task 2: Enrich operational returns

In **Catalog**, open LAB&#95;RETURNS&#95;RAW&#95;V and run **AI Enrichment**. Review and
save these business definitions:

| Object | Description | Tags |
|---|---|---|
| View | One operational return event by product, store and timestamp. Aggregate separately before comparing with digital popularity. Returns are a quality context, not a rate. | `returns`, quality&#95;signal, operational&#95;data, no&#95;return&#95;rate |
| PRODUCT&#95;ID | Product join key. Join to LAB&#95;PRODUCTS&#95;RAW&#95;V.PRODUCT&#95;ID. | product&#95;key, join&#95;key |
| STORE&#95;ID | Store identifier for returns analysis. | store&#95;key, join&#95;key |
| RETURN&#95;QTY | Additive number of returned units. Default aggregation is `SUM`. | `measure`, `units`, `additive`, `sum` |
| RETURN&#95;CREATED&#95;AT | Timestamp when the return was recorded. Derive calendar month from it. | event&#95;timestamp, time&#95;key |

Save both objects.

## Task 3: Ask the harder business question

In Codex, ask:

~~~text
Which product categories should we prioritize, balancing current customer
interest with returns?
~~~

Expected result: Codex should state that it needs a governed model before
making the recommendation. It should identify all of these requirements:

* one common, completed-month time window;
* a reusable category-to-product hierarchy;
* digital events aggregated by product and month;
* returned units aggregated by product, store, and month; and
* governed drill-down rather than a one-off cross-source join.

This is not a failure. It is the decision to create a reusable semantic model
instead of making an unreviewed recommendation from ad-hoc SQL.

<!-- Screenshot to insert after approved dry run: images/governed-model-gap.png
     Alt text: Codex identifies the time, hierarchy, and aggregation rules
     required before returning a cross-source recommendation. -->

### Checkpoint

All three raw views have reviewed Data Studio metadata. Codex has identified
the governed-model requirements and has not invented a recommendation.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
