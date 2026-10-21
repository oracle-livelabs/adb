# Lab 5: Ask business questions of Gold with AI

## Introduction

Mia wants to know which products lead sales in the latest available month, then asks specifically about the West region. You will generate SQL from both questions in Data Studio and verify that both answers come from the native Gold table. Gold already contains only West-region rows, so the two rankings should agree when they use the same month and calculation.

Estimated Time: 8 minutes.

### Objectives

* Ask two natural-language questions in SQL Worksheet.
* Inspect and, if needed, repair the generated SQL before running it.
* Check the Gold source, reporting month, grouping, and totals against reference SQL.

### Prerequisites

Complete Lab 4. The Gold table must be queryable and contain only West-region data. The event's SQL-generation configuration is pre-provisioned.

## Task 1: Open the worksheet AI prompt

1. Open **SQL Worksheet**. Create a worksheet, or rename a blank one, to **Lab 5 - West product sales**.

2. In the worksheet's **Catalog** pane, expand **your connected database → PG → Tables** and select `ailh_gold_west_product_performance` for context. This is the native Gold table, not `PG."ailh_enriched_sales"` or the mounted Silver table.

3. Click the sparkle **Generate SQL with AI** control in the worksheet toolbar. Enter your question in the prompt bar that opens above the SQL editor—not in the SQL editor itself—then click **Generate SQL**.

    ![SQL Worksheet toolbar and separate Generate SQL with AI prompt bar](../assets/images/lab5-worksheet-ai-prompt.png)

## Task 2: Ask and check two questions

1. Generate SQL for the first question:

    ```text
    <copy>
    show the top 10 product names by total sales amount for the latest SALE_MONTH available in this table. Sum TOTAL_SALE_AMOUNT by PRODUCT_NAME and sort from highest to lowest sales amount.
    </copy>
    ```

2. Before running it, inspect **every** `FROM` clause, including any latest-month subquery. Both must read `"PG"."ailh_gold_west_product_performance"`. The query must use `MAX(SALE_MONTH)`, sum `TOTAL_SALE_AMOUNT` by `PRODUCT_NAME`, sort descending, and return ten rows. If the generated SQL uses `PG."ailh_enriched_sales"` or another table, edit the SQL to use the Gold table in both places; check the remaining columns and logic, then run the repaired statement. Never use a plausible-looking result from the wrong source.

3. Use **Generate SQL with AI** again for the second question:

    ```text
    <copy>
    for the west region, show the top 10 product names by total sales amount for the latest SALE_MONTH. Sum TOTAL_SALE_AMOUNT by PRODUCT_NAME and sort from highest to lowest sales amount.
    </copy>
    ```

4. Apply the same source and calculation checks before running it. A `SALES_REGION = 'West'` predicate is acceptable, but this Gold table is West-only already. If generated SQL selects a general sales table instead, repair both its main source and latest-month subquery to Gold before execution.

    ![Reviewed SQL reading native Gold in both the main query and latest-month subquery, with top-ten results](../assets/images/lab5-gold-sql-result.png)

5. Compare the two top-ten results. They should match when the queries use the same Gold table, month, grouping, and ordering. If they differ, compare the generated SQL before interpreting the numbers.

## Task 3: Validate the answer

1. In a separate worksheet, run the reference calculation against Gold:

    ```sql
    <copy>
    SELECT
        a."PRODUCT_NAME" AS product_name,
        SUM(a."TOTAL_SALE_AMOUNT") AS total_sales_amount
    FROM "PG"."ailh_gold_west_product_performance" a
    WHERE a."SALE_MONTH" = (
        SELECT MAX(b."SALE_MONTH")
        FROM "PG"."ailh_gold_west_product_performance" b
    )
    GROUP BY a."PRODUCT_NAME"
    ORDER BY total_sales_amount DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

2. Compare the leading product and sales amount with both AI-generated results. If the worksheet offers a visualization action for the result, open it to chart the top products. Save your worksheets.

3. Explain the answer as: “These are the leading products by sales amount in the latest available month for the West region.” It is not a company-wide ranking. Catalog descriptions and tags provide useful context, but checking the generated SQL is still required.

    **Checkpoint:** both natural-language prompts lead to reviewed, executable Gold SQL, and the results agree with the reference calculation. Running the reference query alone does not complete the AI exercise.

## Learn More

* [Use the AI Assistant in Data Studio](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/use-ai-assistant.html)
* [Select AI concepts](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai-concepts.html)

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
