# Lab 4: Alex publishes an AI-ready West-region Gold product

## Introduction

Publish native Oracle Gold data and document its business scope. The West filter determines which rows belong in Gold; annotations explain that scope to consumers. An annotation is not a filter or a security policy.

Estimated Time: 9 minutes, including the facilitator's metadata demonstration.

### Objectives

* Review the West-region aggregation and source lineage.
* Add and review business metadata in Data Transforms.
* Run `WF_03_SILVER_GOLD` and validate native `PG` Gold data.

### Prerequisites

Complete Labs 1–3. Confirm access to the `peakgear` Gold workflow and the assigned native `PG` target.

## Task 1: Inspect the Gold flow in the new UI

1. Open **Transform → Projects → peakgear → Data Flows → DF_03_GOLD_WEST_PRODUCT_PERFORMANCE**.

2. Inspect the source. Identify whether the imported flow reads the mounted Silver table, a bridge view, or the native cleansed intermediate table. If it uses the intermediate table, explain that it shares Silver's curated data but does not prove an Iceberg read. Do not change its source during this timed exercise.

3. Inspect the actual filter and confirm the condition selects `West` in `SALES_REGION`. A table name or annotation does not enforce this rule. If no effective West filter exists, stop and ask the facilitator to correct the prepared flow before execution.

4. Review the grouping: sales month, product, category, state, channel, and region. Review the measures for quantity, sales, estimated cost, gross margin, and transaction count. Calculate aggregate margin percentage from aggregate margin divided by aggregate revenue, not by averaging transaction percentages.

## Task 2: Watch and review metadata enrichment

1. The facilitator selects the Gold target component in the data-flow canvas and opens its annotations controls. In builds exposing the documented controls, use **Properties → Annotations → Manage Annotations**. If absent in the new UI, use Appendix A; do not look for legacy controls in the new screen.

2. Add or review these proposed business annotations using the supported names/values in the event build.

    | Metadata | Business meaning |
    |---|---|
    | Description | Product-performance metrics for the West sales region |
    | Region | West |
    | Grain | Sales month, product, category, state, channel, sales region |
    | Estimated gross margin | Sales amount less quantity multiplied by the product cost used by this lab; not an audited profit measure |

3. If the event supports AI metadata generation, the facilitator uses the configured OpenAI connection/profile to draft a description. Review its interpretation of the flow and filter before applying it. Use only approved lab metadata. Never enter an API key into a prompt.

    AI generation is conditional on the deployed event feature. Manual annotation editing is the documented fallback, not a claim that AI generation occurred. Do not promise that a filter is automatically captured unless the generated metadata actually shows it.

4. Save the flow and its annotations. The facilitator explains: “The filter controls membership. The metadata tells a consumer that this is West-only data. Select AI can use supported metadata when its profile includes it. Metadata does not replace access controls.”

## Task 3: Run the Gold workflow

1. Open **Workflows → WF_03_SILVER_GOLD** in `peakgear`. Verify that it includes `DF_03_GOLD_WEST_PRODUCT_PERFORMANCE`.

2. Use **Run** when available in the new workflow designer. Submit once in your assigned environment and record its job ID. If the new UI cannot execute, use Appendix A.

3. Open **Jobs** and inspect the run and child data flow. Confirm successful completion before querying Gold. Do not run the full master workflow for this step.

## Task 4: Check the native Gold table

1. Open **Catalog → your database (PG) → PG**. Gold belongs to the native schema, not the mounted `silver` namespace. Open **SQL Worksheet** and run:

    ```sql
    <copy>
    SELECT * FROM PG.GOLD_WEST_PRODUCT_PERFORMANCE
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

2. Verify data and region scope.

    ```sql
    <copy>
    SELECT SALES_REGION, COUNT(*) AS gold_rows
    FROM PG.GOLD_WEST_PRODUCT_PERFORMANCE
    GROUP BY SALES_REGION;
    </copy>
    ```

    Expected: nonzero data and only the intended West region. Any other region or null requires investigation before Lab 5.

3. Reopen the target metadata and verify the West annotation persisted. A saved editor entry alone is not proof that metadata reached the database target. The facilitator verifies persisted annotations and the Select AI profile before the event.

    **Checkpoint:** Gold contains data in `PG`, its rows are West-only, and metadata describes its scope. If enrichment is unavailable, state the limitation and use the approved manual metadata route.

## Appendix A: Legacy Data Transforms annotations and execution

1. Open legacy **Projects → peakgear → Data Flows → DF_03_GOLD_WEST_PRODUCT_PERFORMANCE**.

2. Select the target component. In its **Properties** panel, use **Annotations → Manage Annotations** to add or review the metadata. Alternatively, open the target under **Data Entities**, edit it, and use **Manage Annotations**. Exact availability depends on the event release.

3. Save. Open **Workflows → WF_03_SILVER_GOLD**, select **Start**, and follow the job link or **Jobs** to check completion. Run only once.

4. If the new worksheet is unavailable, open legacy **Database Actions → SQL** and run Task 4's checks. Return to the new UI for Lab 5.

## Learn More

* [View and manage Data Transforms annotations](https://docs.oracle.com/en/database/data-integration/data-transforms/using/view-and-manage-annotations.html)

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
