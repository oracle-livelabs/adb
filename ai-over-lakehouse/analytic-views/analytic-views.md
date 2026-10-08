# Lab 5: Create Analytic Views with Codex

Estimated Time: 20 minutes

## Introduction

Lab 4 saved the reviewed descriptions and tags for all three raw views. Reuse
those annotations here; do not run AI Enrichment again. The next question
combines digital behavior, a product hierarchy, and operational returns. A
one-off join would be technically possible but would not be a shared,
reviewable, reusable business model.

In this lab, first identify the model requirements, then ask Codex through the
LiveLab MCP server to create and validate two Analytic Views:

* a digital-interest Analytic View for events by time, category, and product;
* a returns Analytic View for returned units by time, category, product, and store.

The participant does not paste complex Analytic View DDL. Codex creates the
model from the saved Data Studio definitions and validates it before answering.

### Objectives

In this lab, you will:

* ask the harder business question and identify the governed-model gap;
* ask Codex to build the governed model through MCP;
* confirm that both Analytic Views are valid; and
* receive a governed category recommendation with drill-down evidence.

### Prerequisites

Complete Lab 4, including the saved descriptions and tags for
LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;V, LAB&#95;PRODUCTS&#95;RAW&#95;V, and
LAB&#95;RETURNS&#95;RAW&#95;V. Keep the same Codex task and LiveLab MCP connection
open. This lab does not repeat AI Enrichment or create an AI profile.

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
* digital events with non-NULL product IDs aggregated by product and month,
  with unattributed events counted and reported separately;
* returned units aggregated by product, store, and month; and
* governed drill-down rather than a one-off cross-source join.

This is not a failure. It is the decision to create a reusable semantic model
instead of making an unreviewed recommendation from ad-hoc SQL.

<!-- Screenshot to insert after approved dry run: images/governed-model-gap.png
     Alt text: Codex identifies the time, hierarchy, and aggregation rules
     required before returning a cross-source recommendation. -->

### Checkpoint

Codex has reused the Data Studio metadata saved in Lab 4 and identified the
governed-model requirements without inventing a recommendation. Continue to
Task 3 in this same lab to build the model.

## Task 3: Ask Codex to build the model

In the existing Codex task, click **Copy** in the upper-right corner of the
following block, then paste the prompt into Codex. Let Codex choose the object
names and model details from the saved source definitions.

~~~text
<copy>
Use LiveLab MCP and the saved Data Studio descriptions and tags to create
and validate Analytic Views for customer interest and returns.

They should help answer: Which product categories should we prioritize,
balancing current customer interest with returns?
</copy>
~~~

Expected result: Codex reads the annotations, creates the supporting semantic
objects that it needs, creates both Analytic Views, and validates that the
views can be queried. It should stop and report a specific missing input if it
cannot create a hierarchy or shared dimension.

The PEAKGEAR&#95;USER-only boundary established in Lab 3 still applies. Use the
object names reported by Codex; the participant does not have to prescribe them.

Codex may use LiveLab MCP's SQL tool to create the supporting dimensions,
hierarchies and Analytic Views when the high-level auto-builder cannot express
the reviewed model. This is still the MCP-driven workflow: the participant
does not paste instructor DDL. Auto-creation alone is not validation; Codex
must query the category roll-up and product drill-down, reconcile totals and
report the common month. If a source definition or permission is missing,
stop and report that specific issue rather than inventing a model.

Before creating the product/category model, validate attribution against the
shared catalog. Exclude digital events with NULL PRODUCT&#95;ID from those
rankings and report their count for the same common month. Keep the raw source
view intact; do not add a synthetic Unknown category. Every non-NULL product
ID in both facts must map to exactly one catalog product and its category.
Stop and report missing or ambiguous mappings rather than dropping them or
inventing labels. Preserve existing source category labels such as `N/A` and
the literal text `null`; call out those labels separately from named-category
recommendations instead of assigning categories from product names.

Each query must select the requested hierarchy levels for the common month.
Use category rows and All Stores for the category comparison; use product and
store detail for a store drill-down. Do not sum detail rows together with
their All-level totals.

If Codex creates local supporting aggregate tables, they are workshop snapshots.
It must state their source month and validate them against the connected sources.
Do not imply continuous refresh unless the model actually implements it.

<!-- Screenshot to insert after approved dry run: images/codex-builds-av.png
     Alt text: Codex uses LiveLab MCP to create and validate the two PeakGear
     Analytic Views, with non-secret validation evidence. -->

## Task 4: Ask the final business question

Ask:

~~~text
<copy>
Which product categories should we prioritize, balancing current customer
interest with returns?
</copy>
~~~

Expected result: Codex answers from the two Analytic Views and provides a
governed drill-down to the relevant categories and products. It states the
completed-month window and the measures used:

* customer interest = digital event count for non-NULL product IDs;
* digital events without product IDs are excluded from category ranking and
  their count is reported separately for the common month;
* returns = sum of returned units; and
* returns are quality context, not a return rate.

![The final governed answer ranks categories using the common completed month, digital events, and returned units.](images/final-governed-answer.png)

### Checkpoint

The Analytic Views created by Codex are valid and queryable, and Codex can
answer the final question through their governed hierarchy and measures.

## Summary

The same customer-interest concept progressed through three stages:

| Stage | What Codex can do | Why |
|---|---|---|
| Raw sources | Refuse to invent the answer | Fields do not define the business question. |
| Data Studio annotation | Answer a clearly defined event ranking with product labels | The metric, grain, time window, and product lookup are saved. |
| Analytic Views | Make a governed cross-source recommendation with drill-down | Time, hierarchy, and aggregation semantics are reusable. |

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
