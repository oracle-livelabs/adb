# Lab 3: Sam investigates inventory coverage across tiers

## Introduction

Sam asks: “Which store and product combinations sold more units in the latest two dataset months than their available-to-promise inventory?” Combine curated Silver sales with Bronze inventory without building another pipeline or copying inventory into Silver.

Estimated Time: 12 minutes, including a four-minute discovery demonstration.

### Objectives

* Discover the inventory asset needed for a business question.
* Check join grain before combining Bronze and Silver.
* Use SQL to identify candidates for replenishment review.

### Prerequisites

Complete Lab 2. Silver must contain queryable enriched sales, and Bronze must contain the assigned inventory extract.

## Task 1: Find the inventory asset in the new UI

1. As Sam, open **Catalog → Locally Mounted Catalogs → PG_AICAT**. Inspect `bronze` and `silver`. When table listing/search is available, find `STORE_INVENTORY` and `HOL2026_ENRICHED_SALES`. Do not use the header **Ask AI** field as a catalog-search substitute unless the facilitator demonstrates that behavior.

2. If the new UI cannot list tables, open **SQL Worksheet** and discover them directly.

    ```sql
    <copy>
    SELECT owner, table_name
    FROM all_tables@PG_AICAT
    WHERE UPPER(table_name) LIKE '%INVENTORY%'
       OR UPPER(table_name) LIKE '%ENRICHED_SALES%'
    ORDER BY owner, table_name;
    </copy>
    ```

3. Confirm the namespace and table case returned by discovery. Use that exact spelling in the quoted identifiers below. If the new worksheet cannot execute, use Appendix A.

    Facilitator: “Discovery lets Sam find another governed asset and query it with Silver. This exercise joins across tiers in place. It does not silently promote raw inventory into a curated Silver product.”

## Task 2: Check the join grain

1. Run this check. The prepared inventory extract must have at most one row per store and product for this exercise.

    ```sql
    <copy>
    SELECT "STORE_ID", "PRODUCT_ID", COUNT(*) AS row_count
    FROM "bronze"."STORE_INVENTORY"@PG_AICAT
    GROUP BY "STORE_ID", "PRODUCT_ID"
    HAVING COUNT(*) > 1
    FETCH FIRST 20 ROWS ONLY;
    </copy>
    ```

    Expected: no rows. If rows appear, stop and ask the facilitator to select the appropriate inventory snapshot or complete join key. Do not remove duplicates arbitrarily or sum repeated inventory snapshots.

2. Check the sales period and inventory completeness.

    ```sql
    <copy>
    SELECT MIN("SALE_MONTH") AS first_month, MAX("SALE_MONTH") AS latest_month
    FROM "silver"."HOL2026_ENRICHED_SALES"@PG_AICAT;
    </copy>
    ```

    ```sql
    <copy>
    SELECT COUNT(*) AS inventory_rows,
           SUM(CASE WHEN "AVAILABLE_TO_PROMISE_QTY" IS NULL THEN 1 ELSE 0 END)
               AS missing_atp_rows
    FROM "bronze"."STORE_INVENTORY"@PG_AICAT;
    </copy>
    ```

    Missing ATP is unknown, not zero. The analysis below excludes those rows. The facilitator must confirm that `SALE_MONTH` is a date representing the sales month.

## Task 3: Answer the inventory question

1. Execute this query in **SQL Worksheet**. It first aggregates sales, then joins inventory at store/product grain to avoid multiplying transaction-level sales.

    ```sql
    <copy>
    WITH latest_month AS (
        SELECT MAX("SALE_MONTH") AS sale_month
        FROM "silver"."HOL2026_ENRICHED_SALES"@PG_AICAT
    ), recent_demand AS (
        SELECT "STORE_ID", "PRODUCT_ID",
               MAX("PRODUCT_NAME") AS product_name,
               SUM("QTY_SOLD") AS units_sold_recently,
               SUM("TOTAL_SALE_AMOUNT") AS revenue_recently
        FROM "silver"."HOL2026_ENRICHED_SALES"@PG_AICAT
        WHERE "SALE_MONTH" >= ADD_MONTHS(
            (SELECT sale_month FROM latest_month), -1)
        GROUP BY "STORE_ID", "PRODUCT_ID"
    )
    SELECT d."STORE_ID", d."PRODUCT_ID", d.product_name,
           d.units_sold_recently, d.revenue_recently,
           i."STOCK_ON_HAND", i."AVAILABLE_TO_PROMISE_QTY",
           i."REORDER_LEVEL", i."INVENTORY_STATUS",
           d.units_sold_recently - i."AVAILABLE_TO_PROMISE_QTY"
               AS demand_stock_gap
    FROM recent_demand d
    JOIN "bronze"."STORE_INVENTORY"@PG_AICAT i
      ON i."STORE_ID" = d."STORE_ID"
     AND i."PRODUCT_ID" = d."PRODUCT_ID"
    WHERE i."AVAILABLE_TO_PROMISE_QTY" IS NOT NULL
      AND d.units_sold_recently > i."AVAILABLE_TO_PROMISE_QTY"
    ORDER BY demand_stock_gap DESC, d.revenue_recently DESC
    FETCH FIRST 20 ROWS ONLY;
    </copy>
    ```

2. Read one result aloud: identify the store, product, recent units sold, ATP, and gap. If no rows appear, report that no matching rows satisfy this rule; do not invent a shortage.

3. Explain the limits: past sales are a demand proxy, not a forecast or an unfulfilled-order count. Compare the inventory snapshot date with the sales period before making an operational decision. The inner join also excludes sales keys without a matching inventory row.

4. Save the worksheet with a descriptive name, if supported. **Checkpoint:** you answered a question using both tiers without publishing another physical table.

## Appendix A: Legacy SQL and discovery fallback

1. Open the assigned **legacy Database Actions → SQL** session as `PG`. Use legacy **Data Studio → Catalog** for browsing if available.

2. Run Task 1's catalog query, Task 2's checks, and Task 3's analysis unchanged after confirming identifier case and mount alias.

3. Record the result and return to the new Data Studio tab for Lab 4. Do not create or reload catalog tables to work around a UI listing problem.

## Learn More

* [Query mounted catalogs](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/manage-catalogs.html)

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
