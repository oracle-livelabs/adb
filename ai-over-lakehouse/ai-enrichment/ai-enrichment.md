# Lab 4: Add business meaning with AI Enrichment

Estimated Time: 12 minutes

## Introduction

AI Enrichment can suggest descriptions and tags, but the participant reviews
and saves the business contract. Data Studio persists the reviewed text as
native database annotations. In this lab, you enrich all three local raw tables in
one place: digital interactions, the product catalog, and operational returns.
The saved contracts give Codex a reliable definition for the same simple
question from Lab 3 and prepare the source context for the harder question in
Lab 5. You will not repeat AI Enrichment in Lab 5.

### Objectives

In this lab, you will:

* use Data Studio AI Enrichment without creating an AI profile;
* review and save descriptions and tags for all three raw tables;
* define digital interest, product labels, and returned units; and
* ask exactly the same business question again.

## Task 1: Open AI Enrichment

Continue after Lab 3's connection checkpoint and raw-question stop. Keep the
same Codex task open while editing the metadata in Data Studio.

The default AI profile is already prepared. Do **not** create, select, edit, or
validate a profile.

1. Open **Catalog**.
2. Open the PEAKGEAR&#95;USER schema, then **Tables**.
3. Select LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;T.
4. Click **AI Enrichment**.
5. Wait for generation to finish. Check that both the description and tags are
   populated for the table and for **every column**. AI-generated text is a
   suggestion, not a source of truth. An editable dialog alone does not prove
   that generation succeeded.

If Data Studio reports **invalid column tags** or **did not return column
tags**, retain the error and ask the instructor to repair the prepared AI
profile before continuing. Do not save an empty result, recreate the profile,
or treat existing manually entered tags as proof of fresh generation.

Task 2 provides the definitions for all three tables. Save the digital table
first, then repeat the same **Catalog > Tables > AI Enrichment** flow for
LAB&#95;PRODUCTS&#95;RAW&#95;T and LAB&#95;RETURNS&#95;RAW&#95;T. Each table needs its own **Save**.

Check that the enrichment dialog names the table you selected. Before saving,
turn on **Show code** and confirm that its **ALTER TABLE** target is that same
table under PEAKGEAR&#95;USER. If it targets a different table or object type,
cancel and ask the instructor.

<!-- Re-capture AI Enrichment entry and review screenshots for local tables. -->

## Task 2: Review the business contract

### Digital interactions

For LAB&#95;DIGITAL&#95;INTENT&#95;RAW&#95;T, use the following definitions.

Replace the table-level description with this exact text:

~~~text
<copy>
Each row is one digital interaction. In this lab, customer interest means
the count of digital events with non-NULL PRODUCT_ID. Exclude events without
PRODUCT_ID from product and category rankings and report their count separately
for the same month. "Right now" means the latest completed calendar month
present in EVENT_TS, excluding the database's current and future months. Use
the month available in the data, not a guessed current month. Aggregate events
by PRODUCT_ID, then join LAB_PRODUCTS_RAW_T on PRODUCT_ID to display
PRODUCT_NAME. That catalog must contain one row per product; never multiply
event counts in the label join. Keep unknown product names unknown. This event
table has no product names, returns, revenue, or store. This table is a local
snapshot of the connected source at the time it was created; it does not
refresh automatically.
</copy>
~~~

Set the table tags to:

~~~text
<copy>
digital_intent, event_data, product_popularity, no_store_attribution
</copy>
~~~

Set these column descriptions and tags:

| Column | Description | Tags |
|---|---|---|
| PRODUCT&#95;ID | Business product identifier. Join key to LAB&#95;PRODUCTS&#95;RAW&#95;T.PRODUCT&#95;ID; it is not a measure. | product&#95;key, join&#95;key |
| SESSION&#95;ID | Browsing-session identifier. It is not a customer identifier or additive measure. | session&#95;identifier |
| CUSTOMER&#95;ID | Customer identifier associated with the event. Row count is not a count of unique customers. | customer&#95;identifier |
| EVENT&#95;TS | Timestamp of the interaction. Derive the latest month present in the data that ended before the database's current calendar month. | event&#95;timestamp, time&#95;key |

Replace the AI-suggested tag chips with the tags listed in this task. Enter
each tag separately and press **Enter** after each one; commas in the examples
separate tags. Remove extra suggested tags rather than appending the reviewed
tags to them. Click the dialog heading to close a tag dropdown before moving
to another field, so a suggestion menu does not cover the next field.

For each table, follow this Save sequence:

1. After editing a description, move focus to another field and confirm that
   the complete reviewed text remains visible.
2. Turn on **Show code**. Check the selected table's **ALTER TABLE** target,
   table description, every column description, and all tags against this task.
   If a value is missing, partial, or still AI-suggested, turn **Show code** off
   and correct the field. Use the code for review; save through the dialog.
3. Click **Save once**. Saving may take more than a minute. While **Save**,
   **Cancel**, and **Close** are disabled, wait; do not click Save again or
   refresh the page.
4. Wait for the dialog to close before opening the next table. If it remains
   disabled without a completion message after a reasonable wait, ask the
   instructor to check the operation before retrying.

Annotations may appear gradually while Save is running. After all three saves,
use Task 3 to verify every description and tag. If Save reports a connection
error, refresh Catalog and perform that same verification before retrying;
the operation may have saved only part of the contract. A changed table
description alone does not confirm a complete save.

### Product catalog

In **Catalog**, open LAB&#95;PRODUCTS&#95;RAW&#95;T and click **AI Enrichment**. Review
and save these business definitions:

| Object | Description | Tags |
|---|---|---|
| Table | One row per product. Conformed catalog shared by digital intent and returns. Category rolls up product. Local snapshot of the connected source. | product&#95;catalog, conformed&#95;dimension, category&#95;hierarchy |
| PRODUCT&#95;ID | Shared product join key. | product&#95;key, join&#95;key |
| PRODUCT&#95;NAME | Business-facing product name. | product&#95;name |
| CATEGORY&#95;NAME | Category used to aggregate products. | category, hierarchy&#95;level |

Click **Save** before moving to the next table.

### Operational returns

In **Catalog**, open LAB&#95;RETURNS&#95;RAW&#95;T and click **AI Enrichment**. Review
and save these business definitions:

| Object | Description | Tags |
|---|---|---|
| Table | One operational return event by product, store and timestamp. Aggregate separately before comparing with digital popularity. Returns are a quality context, not a rate. Local snapshot of the connected source. | `returns`, quality&#95;signal, operational&#95;data, no&#95;return&#95;rate |
| PRODUCT&#95;ID | Product join key. Join to LAB&#95;PRODUCTS&#95;RAW&#95;T.PRODUCT&#95;ID. | product&#95;key, join&#95;key |
| STORE&#95;ID | Store identifier for returns analysis. | store&#95;key, join&#95;key |
| RETURN&#95;QTY | Additive number of returned units. Default aggregation is `SUM`. | `measure`, `units`, `additive`, `sum` |
| RETURN&#95;CREATED&#95;AT | Timestamp when the return was recorded. Derive calendar month from it. | event&#95;timestamp, time&#95;key |

Click **Save**. All three tables must be saved before Task 3.

## Task 3: Verify the saved annotations

After all three Save operations have finished, reopen each table in Catalog.
Compare its table-level and every column's description and tags with Task 2.
Check the full values, including the product-name and join-key definitions.
The digital table's Overview description must begin with:

~~~text
<copy>
Each row is one digital interaction
</copy>
~~~

Optionally verify the saved database metadata:

~~~sql
<copy>
SELECT object_type,
       object_name,
       column_name,
       annotation_name,
       annotation_value
FROM user_annotations_usage
WHERE object_name IN (
        'LAB_DIGITAL_INTENT_RAW_T',
        'LAB_PRODUCTS_RAW_T',
        'LAB_RETURNS_RAW_T'
      )
  AND annotation_name IN ('DESCRIPTION', 'TAGS')
ORDER BY object_name,
         column_name NULLS FIRST,
         annotation_name;
</copy>
~~~

Each table and **every column** must have non-empty `DESCRIPTION` and `TAGS`
annotations. In this workshop that is 10 annotation rows for Digital Intent,
8 for Products, and 10 for Returns: **28 rows in total**. A row count is only
a completeness check; also review the values, including CATEGORY&#95;NAME's
`category, hierarchy_level` tags and the product-name and join-key definitions.
If any field is missing or differs from the reviewed contract, reopen that
table's metadata, correct it, save once, and repeat this verification before
continuing to Task 4.

<!-- Screenshot to insert after approved dry run: images/ai-enrichment-saved.png
     Alt text: Data Studio Catalog shows the saved description and tags for
     the Digital Intent table. -->

## Task 4: Repeat the same question

In the same Codex task, ask exactly the same question from Lab 3:

~~~text
<copy>
Which products are customers interested in right now?
</copy>
~~~

Expected result: Codex uses the saved contract to calculate the latest-month
digital-event ranking. It can join to LAB&#95;PRODUCTS&#95;RAW&#95;T only to present the
corresponding business-facing product names; that lookup does not change the
metric, time window, or result grain.

The current Starter Kit includes that safe label lookup against the new local
tables. If an older installed kit still refers to raw views or returns only
IDs, download the current kit, rerun setup with this reservation's URL and
Database Password, and create a fresh Codex task with the Lab 3 boundary. Do
not create Analytic Views early just to display product names.

The words in the business question did not change. The answer improved because
the definition, time period, and result grain are now saved in Data Studio.

If the ranking tool reaches its read timeout, Codex may use LiveLab MCP SQL
after reading the saved contracts and checking product-key uniqueness. Derive
the actual completed snapshot month first, then run the ranking for that bounded
month with the same metric and product-label rules. Report the count of events
without PRODUCT&#95;ID separately. A timeout is not an empty ranking, and it does
not require creating Analytic Views early.

State the actual month returned by MCP. The local tables are snapshots of the
source data when Lab 2 ran; the workshop uses historical data;
the result need not be the month immediately before today's date. Do not
relabel historical events as current live demand.

<!-- Re-capture the enriched-answer screenshot against the local raw tables. -->

### Checkpoint

All three raw tables have reviewed, saved `DESCRIPTION` and `TAGS` annotations,
and Codex has answered the same question with the defined metric, time window,
and product grain. Lab 5 reuses these annotations; it does not run AI Enrichment
again.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
