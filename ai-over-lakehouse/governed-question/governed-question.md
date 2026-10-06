# Lab 5: Identify the governed-model gap

Estimated Time: 5 minutes

## Introduction

Lab 4 saved the reviewed descriptions and tags for all three raw views. Reuse
those annotations here; do not run AI Enrichment again. The next question
combines digital behavior, a product hierarchy, and operational returns. A
one-off join would be technically possible but would not be a shared,
reviewable, reusable business model.

### Objectives

In this lab, you will:

* ask a harder question using the source contracts already saved in Lab 4; and
* see why a cross-source recommendation needs Analytic Views.

### Prerequisites

Complete Lab 4, including the saved descriptions and tags for
LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;V, LAB&#95;PRODUCTS&#95;RAW&#95;V, and LAB&#95;RETURNS&#95;RAW&#95;V.
Keep the same Codex task and LiveLab MCP connection open.

## Task 1: Ask the harder business question

In Codex, ask:

~~~text
<copy>
Which product categories should we prioritize, balancing current customer
interest with returns?
</copy>
~~~

## Task 2: Review the governed-model requirements

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

Codex has reused the Data Studio metadata saved in Lab 4, identified the
governed-model requirements, and has not invented a recommendation. Continue
to Lab 6 to create the Analytic Views with Codex.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
