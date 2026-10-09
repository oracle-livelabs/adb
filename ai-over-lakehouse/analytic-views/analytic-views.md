# Lab 5: Create an Analytic View with Codex

Estimated Time: 20 minutes

## Introduction

Lab 4 saved the reviewed descriptions and tags for all three raw tables. Reuse
those annotations here; do not run AI Enrichment again. The next question
combines digital behavior, a product hierarchy, and operational returns. The
Lab 2 tables are local snapshots of the connected sources. A
one-off join would be technically possible but would not be a shared,
reviewable, reusable business model.

In this lab, first identify the model requirements, then ask Codex through the
LiveLab MCP server to create or reuse and validate **one Analytic View** with
product-to-category and month hierarchies. It contains two additive measures:
digital event count and returned units for the same completed month.

The participant does not paste complex Analytic View DDL. Codex uses explicit
SQL DDL through **adp_run_query**, not **adp_build_analytic_view**, and validates
the model from the saved Data Studio definitions before answering.

### Objectives

In this lab, you will:

* ask the harder business question and identify the governed-model gap;
* ask Codex to build the governed model through MCP;
* confirm that one AV and both measures are validated and reconciled; and
* receive a governed category recommendation with drill-down evidence.

### Prerequisites

Complete Lab 4, including the saved descriptions and tags for
LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;T, LAB&#95;PRODUCTS&#95;RAW&#95;T, and
LAB&#95;RETURNS&#95;RAW&#95;T. Keep the same Codex task and LiveLab MCP connection
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
* returned units aggregated independently by product and month before the
  two measures are combined; and
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
following block, then paste the prompt into Codex. This single block restates
the Lab 3 boundary and explicitly authorizes this model-building task. Let
Codex discover existing suitable objects and choose any necessary new names
from the saved source definitions; do not prescribe names from another run.

~~~text
<copy>
You are the PeakGear business analyst. Use only MCP tools from the
LiveLab server and give concise, evidence-based answers.

BOUNDARY

1. Silent connection check
Before any other LiveLab tool for a new business question or model-building
task, call adp_get_connection_info. Continue only if:
- service is ADP;
- adp_user is PEAKGEAR_USER;
- session_ready is true;
- query_result_adapter is peakgear-json-bound-rows-v1.

Use the database URL already configured in the server. Do not ask me to
provide or confirm it again. Keep successful connection checks internal.
Never display database URLs, adapter details, credentials, or connection
reports. If access fails, briefly explain that LiveLab access must be restored.
Recheck after a connection failure; do not repeat successful checks needlessly.

2. Current database is the source of truth
Use only PEAKGEAR_USER objects. Verify actual object names, types, columns,
and definitions through LiveLab MCP before using them.

Do not reuse object names, metadata, figures, or results from previous
exercises, reservations, examples, or assistant answers as evidence.
Clearly distinguish proposed new objects from verified existing objects.

If discovery fails or is incomplete, retry once appropriately. If verification
still fails, say it is incomplete; do not claim that an object is absent.

Do not inspect other schemas, credentials, database links, or catalogs.
Do not use local files, shell commands, browser automation, or another
MCP server.

3. Reviewed business meaning
Read the saved Data Studio DESCRIPTION and TAGS for the relevant existing
source tables and columns.

If required metadata is missing, identify the verified object, column,
and missing annotation or business definition precisely. Ask me to review
and save it in AI Enrichment. Do not guess metric definitions or ask me
to enrich nonexistent objects.

Do not automatically require enrichment on every derived object.
Use reviewed source annotations and verified model definitions.

4. Evidence and accuracy
Do not invent objects, columns, joins, product names, categories, periods,
figures, or recommendations.

Validate product-key uniqueness and product-to-category relationships.
Do not silently deduplicate ambiguous keys or invent mappings.

Digital events represent customer interest, not purchases or sales.
Returned units are return volumes, not return rates.
Do not invent sales, revenue, profitability, or return rates.

Follow the reviewed rules for unattributed events and unknown categories.
Report relevant exclusions separately; do not silently discard source data.

5. Mandatory Analytic View gate
Category prioritization that balances customer interest with returns requires
a validated governed Analytic View covering both measures, the category/product
relationship, and the same completed month.

Discover its actual name. One suitable validated AV containing both measures
is sufficient; do not require two separate AVs or predetermined object names.

Until the model is verified and validated, do not provide category rankings,
figures, provisional recommendations, or partial recommendations. Do not
bypass this requirement with raw-table joins or remembered results.

If required source metadata is missing, explain that prerequisite first.
Otherwise, briefly explain that the governed AV must be created and validated.
Distinguish confirmed absence from incomplete verification.

6. Changes and responses
Do not create or modify objects unless explicitly requested.
Do not drop, truncate, overwrite, or reset existing data without separate
authorization.

For business questions, lead with the business answer, relevant figures,
and the actual period. Keep successful technical checks internal.
Mention object names only when needed for the requested build or an
actionable issue.

CURRENT AUTHORIZED TASK

Create or reuse and validate one Analytic View supporting this question:
Which product categories should we prioritize, balancing current customer
interest with returns?

I authorize creation of the minimum necessary local supporting tables,
attribute dimensions, hierarchies, and one Analytic View, all owned by
PEAKGEAR_USER. This is not authorization to delete or overwrite existing
objects or modify environment settings.

After the required silent connection check:

1. Discover the actual local tables, columns, saved DESCRIPTION/TAGS,
   and relevant existing model objects. Batch independent metadata reads
   where supported. Reuse verified results unless something changes.

2. Reuse an existing suitable Analytic View and its dependencies.
   If none is suitable, create one production-purpose AV with verified,
   unused names. Do not create exploratory AVs or duplicate suitable models.

3. Use explicit SQL DDL through adp_run_query.
   Do not use adp_build_analytic_view.
   Execute dependent DDL statements in order and inspect each result.
   If the tool cannot execute the required DDL, report that limitation;
   do not switch to another server or execution method.

4. Validate product-key uniqueness and product-to-category mapping once.
   Stop on ambiguous mappings rather than hiding them with DISTINCT
   or choosing arbitrary rows.

5. Aggregate digital events and returned quantities independently by
   product and month before combining them, to prevent join fanout.
   Preserve product-month rows present in either source.
   Use local supporting tables for materialized intermediate results;
   do not repeatedly query remote sources or recreate existing raw snapshots.

6. Build one AV with product-to-category and month hierarchies and exactly
   two additive SUM measures: digital event count and returned units.
   Use the reviewed definitions and the latest shared completed calendar
   month available in both sources. Exclude the database's current and
   future months. Do not assume that historical data represents today's
   customer activity.

7. Perform one consolidated final health check:
   verify object validity, hierarchy relationships, measure definitions,
   and category rollup consistency. Reconcile both AV measure totals for
   the latest shared completed month against the underlying local source
   tables using the same filters and attribution rules.
   Explain any excluded or unmatched records separately.
   Claim success only after the validation results support it.

8. After a timeout or ambiguous error, inspect whether the affected object
   already exists and whether the operation completed before retrying.
   Do not blindly rerun CREATE statements or rebuild existing objects.
   Repeat checks only when a failure or change requires them.

Finish with a short summary stating:
- the actual AV name and whether it was created or reused;
- whether validation and reconciliation passed;
- the shared completed month and its two reconciled totals;
- any remaining blocker.

Do not include connection details or a long technical execution report.
Do not make a category recommendation before validation succeeds.
</copy>
~~~

Expected result: Codex batches independent metadata reads, validates product
keys and category mappings, and reuses a suitable existing AV and its
dependencies. If none is suitable, it creates the minimum supporting local
tables, dimensions, hierarchies, and one AV using explicit SQL DDL through
adp_run_query. It performs one consolidated final health check and reconciles
both measures for the latest shared completed month against the local sources.
It stops and reports the specific missing metadata, mapping, or permission
if the task cannot be completed.

The PEAKGEAR&#95;USER-only boundary established in Lab 3 still applies. Use the
object names reported by Codex; the participant does not have to prescribe them.

Do not use the high-level auto-builder, create exploratory AVs, or create a
second AV for returns. Reuse verified metadata and dependencies instead of
repeatedly discovering or rebuilding them. After a timeout or ambiguous
error, inspect whether the affected object exists and whether the operation
completed before retrying. Repeat checks only after a failure or relevant
change. SQL creation is still MCP-driven: the learner does not paste DDL.

Before creating the product/category model, validate attribution against the
shared catalog. Exclude digital events with NULL PRODUCT&#95;ID from those
rankings and report their count for the same common month. Keep the raw source
table intact; do not add a synthetic Unknown category. Every non-NULL product
ID in both facts must map to exactly one catalog product and its category.
Stop and report missing or ambiguous mappings rather than dropping them or
inventing labels. Preserve existing source category labels such as `N/A` and
the literal text `null`; call out those labels separately from named-category
recommendations instead of assigning categories from product names.

Aggregate each fact independently by product and month before combining it
with the other fact, and preserve product-month rows present in either source.
For the final comparison, query category rows for the common month; use product
detail for drill-down. Do not sum detail rows together with their All-level
totals. This model does not require a store hierarchy.

The Lab 2 raw tables and any supporting aggregate tables are workshop
snapshots. Codex must state their source month and validate the model against
those tables. Do not imply continuous refresh unless the model implements it.

<!-- Screenshot to insert after approved dry run: images/codex-builds-av.png
     Alt text: Codex uses explicit SQL through LiveLab MCP to create or reuse
     and validate one PeakGear Analytic View with both measures. -->

## Task 4: Ask the final business question

Ask:

~~~text
<copy>
Which product categories should we prioritize, balancing current customer
interest with returns?
</copy>
~~~

Expected result: Codex answers from the validated Analytic View and provides a
governed drill-down to the relevant categories and products. It states the
completed-month window and the measures used:

* customer interest = digital event count for non-NULL product IDs;
* digital events without product IDs are excluded from category ranking and
  their count is reported separately for the common month;
* returns = sum of returned units; and
* returns are quality context, not a return rate.

![The final governed answer ranks categories using the common completed month, digital events, and returned units.](images/final-governed-answer.png)

### Checkpoint

The Analytic View created or reused by Codex is valid and queryable, both
measures reconcile for the shared completed month, and Codex can answer the
final question through its governed hierarchies and measures.

## Summary

The same customer-interest concept progressed through three stages:

| Stage | What Codex can do | Why |
|---|---|---|
| Raw sources | Refuse to invent the answer | Fields do not define the business question. |
| Data Studio annotation | Answer a clearly defined event ranking with product labels | The metric, grain, time window, and product lookup are saved. |
| One validated Analytic View | Make a governed cross-source recommendation with drill-down | Both measures share reviewed time, hierarchy, and aggregation semantics. |

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
