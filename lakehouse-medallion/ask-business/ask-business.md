# Lab 5: Mia asks business questions in natural language

## Introduction

Mia wants to understand West-region sales without writing the first SQL statement herself. Use the event's Select AI-enabled experience against the native Gold table, then verify the generated query and scope.

Estimated Time: 7 minutes.

### Objectives

* Ask a natural-language question against curated Gold.
* Inspect generated SQL and validate the answer's scope.
* Understand the role and limits of enriched metadata.

### Prerequisites

Complete Lab 4. Gold must contain West-only data. The facilitator must provision and test the Gold Select AI profile.

## Task 1: Open the configured AI experience in the new UI

1. Return to **Home → AI Assistant** or the **Open AI Assistant** header button. Confirm with the facilitator that the selected database and configured AI profile are the lab's Gold-query profile.

2. Confirm that the profile exposes `PG.GOLD_WEST_PRODUCT_PERFORMANCE` and includes the supported comments/annotations. The facilitator provisions the profile, approved model connection, and required privileges; attendees do not create API credentials.

3. If the assistant is a general helper rather than the event's database-query experience, or cannot use the configured Gold profile, do not treat its answer as a Select AI result. Use the worksheet's configured Select AI capability or Appendix A.

## Task 2: Ask and inspect

1. Submit this prompt in the configured natural-language query experience.

    ```text
    <copy>
    Using GOLD_WEST_PRODUCT_PERFORMANCE, show the top 10 West-region products
    by sales amount in the latest sales month in the data. Include product,
    category, units sold, sales amount, and estimated gross margin.
    </copy>
    ```

2. Inspect the generated SQL when available. It should use the native Gold table, use the latest month in the dataset rather than today's calendar month, and aggregate at product level as requested. It must not infer company-wide performance from a West-only table.

3. Compare at least one reported value with the SQL result. If the interface does not expose generated SQL, use Appendix A's `SHOWSQL` route to inspect it before relying on the response.

4. Ask a follow-up: “Does this dataset cover all regions? Explain its geographic scope.” Check that the explanation matches the West-only metadata and actual data. Do not assume every AI response is correct.

    **Checkpoint:** a database-grounded result from Gold answers the question, and you can explain its geographic scope. This is natural-language analytics, not a demonstration of an autonomous agent taking actions.

## Appendix A: Legacy Select AI SQL fallback

1. Open **legacy Database Actions → SQL** as `PG`. Use the profile name supplied by the facilitator in place of `EVENT_GOLD_PROFILE`. This changes only the session's active profile.

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI.SET_PROFILE('EVENT_GOLD_PROFILE');
    END;
    /
    </copy>
    ```

2. Inspect the generated SQL first.

    ```sql
    <copy>
    SELECT AI SHOWSQL Using GOLD_WEST_PRODUCT_PERFORMANCE show the top 10 West region products by sales amount in the latest sales month in the data including product category units sold sales amount and estimated gross margin;
    </copy>
    ```

3. After reviewing the source and calculation, run the natural-language query.

    ```sql
    <copy>
    SELECT AI RUNSQL Using GOLD_WEST_PRODUCT_PERFORMANCE show the top 10 West region products by sales amount in the latest sales month in the data including product category units sold sales amount and estimated gross margin;
    </copy>
    ```

4. Generated SQL may vary between requests. Inspect the executed statement where available and validate its result. If the model/profile is unavailable, report that blocker; a prepared SQL result is a fallback demonstration, not a successful NLQ run.

## Learn More

* [Select AI concepts](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai-concepts.html)
* [Select AI user guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/oracle-database-select-ai-users-guide.pdf)

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
