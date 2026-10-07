# Lab 2: Connect real sources

Estimated Time: 15 minutes

## Introduction

PeakGear does not copy source data into a staging table. It connects two live
systems:

* Databricks Unity Catalog supplies the Iceberg product catalog and digital
  clickstream events.
* The existing Oracle Operations database supplies return events through the
  public database link already provisioned for your LiveLabs reservation.

You will connect Databricks through the Data Studio UI, add a Lake Cache policy
immediately after the mount, and create three participant-owned raw views.

### Objectives

In this lab, you will:

* create the Azure storage and Databricks OAuth credentials in Data Studio;
* mount the Databricks Unity Iceberg catalog;
* add, but not claim performance for, a Lake Cache policy;
* prove access to the two connected sources; and
* create the three raw business objects used by Codex.

## Task 1: Create the Azure storage credential in Data Studio

Open the connected database's **Settings** (gear icon), then select
**Credentials**. This one-off event includes the shared values for copy/paste;
no separate handout is needed. The complete reference is
[Event lab values](../assets/event-lab-values.md).

![In Database Settings, select Credentials and click Create credential.](images/azure-credential-start.png)

| Credential | Purpose | Value type |
|---|---|---|
| ADLS&#95;PEAKGEAR&#95;DATA | Read Iceberg files in Azure Blob Storage | Event Azure storage password |
| DBX&#95;PEAKGEAR&#95;OAUTH | Obtain renewable Unity Catalog access tokens | Databricks OAuth client |

Click **Create credential** and enter:

| Field | Value |
|---|---|
| Credential Name | ADLS&#95;PEAKGEAR&#95;DATA |
| Description | Credential to access data in Azure Storage |
| Credential type | Azure |
| Username | livelab |

Copy this into **Password**:

~~~text
<copy>
tFODcOQJpwaApm/p3wEqAdYIbvq9/N/jlMsbd2EMz6KwAyXps2+7D1TWLOvBQ8fCPOxaCXznM/YD+AStYElH9Q==
</copy>
~~~

Save the credential. Keep the name exactly. Both source credentials must be
owned by PEAKGEAR&#95;USER, not `ADMIN`. Create the OAuth credential in Task 2.

![Create the ADLS&#95;PEAKGEAR&#95;DATA Azure credential. The password field is masked.](images/create-azure-storage-credential.png)

Storage path for this event:

~~~text
<copy>
https://livelab.blob.core.windows.net/digital-demand/peakgear-managed/
</copy>
~~~

## Task 2: Mount the Databricks Unity Catalog

In **Catalog**, click **Add**, then choose **Iceberg catalog**.

![In Catalog, click Add and choose Iceberg catalog.](images/add-iceberg-catalog.png)

Enter:

| Field | Value |
|---|---|
| Catalog name | DBX&#95;UNITY&#95;PEAKGEAR |
| Iceberg catalog type | Unity |
| Iceberg catalog credentials | DBX&#95;PEAKGEAR&#95;OAUTH |
| Bucket credentials | ADLS&#95;PEAKGEAR&#95;DATA |
| Catalog endpoint | Copy the endpoint below |

Copy this into **Iceberg catalog endpoint**:

~~~text
<copy>
https://adb-2242907740736663.3.azuredatabricks.net/api/2.1/unity-catalog/iceberg-rest/v1/catalogs/peakgear
</copy>
~~~

![Enter DBX&#95;UNITY&#95;PEAKGEAR, select Unity, paste the event endpoint, and select the Azure bucket credential.](images/mount-iceberg-catalog.png)

When **Iceberg catalog credentials** is required, click the plus sign and
create the OAuth credential with these values:

| Field | Value |
|---|---|
| Credential Name | DBX&#95;PEAKGEAR&#95;OAUTH |
| Description | Credential to authenticate into Unity |
| Credential type | Iceberg OAuth2 |
| Token scope | all-apis |
| Token refresh rate in seconds | 3600 |

**Token endpoint**:

~~~text
<copy>
https://adb-2242907740736663.3.azuredatabricks.net/oidc/v1/token
</copy>
~~~

**Client ID**:

~~~text
<copy>
5c47dc63-f693-4820-a40b-4b08c3709f34
</copy>
~~~

**Client secret**:

~~~text
<copy>
dose7b979ac313c1063af5d4cdf09b1ee8fb
</copy>
~~~

![Create DBX&#95;PEAKGEAR&#95;OAUTH with the event token endpoint and client ID. The UI masks the client secret; its copy-ready value is above.](images/create-iceberg-catalog-credential.png)

Return to the catalog form, select DBX&#95;PEAKGEAR&#95;OAUTH, save the mount, and
refresh its catalog metadata. The catalog must expose the `ICEBERG` schema with
`PRODUCTS` and DIGITAL&#95;CLICKSTREAM&#95;EVENTS.

![The successful DBX&#95;UNITY&#95;PEAKGEAR mount exposes the two PeakGear Iceberg tables.](images/connected-iceberg-tables.png)

The UI is the normal workshop path. For a SQL-only dry run of Tasks 1 and 2,
use [01-connect-event-sources.sql](../scripts/01-connect-event-sources.sql).
It uses the owner-confirmed working mount calls and event values. Run it as
PEAKGEAR&#95;USER, only for missing credentials or a missing catalog; do not
recreate a mount that already works. The required host ACL is already
provisioned for PEAKGEAR&#95;USER. If access is denied, ask the instructor;
participants must not grant ACLs or switch to ADMIN.

## Task 3: Add the Lake Cache policy

Immediately after the mount, inspect the Lake Cache policies as
PEAKGEAR&#95;USER. Copy and run this inspection query **by itself**:

~~~sql
<copy>
SELECT external_table_name,
       cached,
       cache_cur_size / 1024 / 1024 AS cache_size_mb,
       disabled
FROM user_external_tab_caches
ORDER BY external_table_name;
</copy>
~~~

Then run the following **single PL/SQL block** by itself using **Run SQL**.
It creates and populates only missing policies; it leaves an existing policy
and its enabled/disabled state unchanged. Do not add a SQL*Plus `/` separator
in Data Studio's Run SQL editor.

~~~sql
<copy>
DECLARE
  l_exists PLS_INTEGER;
BEGIN
  IF SYS_CONTEXT('USERENV', 'CURRENT_USER') <> 'PEAKGEAR_USER' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Run as PEAKGEAR_USER, not ADMIN.');
  END IF;

  FOR r IN (
    SELECT 'ICEBERG.PRODUCTS@DBX_UNITY_PEAKGEAR' AS table_name FROM dual
    UNION ALL
    SELECT 'ICEBERG.DIGITAL_CLICKSTREAM_EVENTS@DBX_UNITY_PEAKGEAR' FROM dual
  ) LOOP
    SELECT COUNT(*) INTO l_exists
    FROM user_external_tab_caches
    WHERE UPPER(REPLACE(external_table_name, '"', '')) = r.table_name;

    IF l_exists = 0 THEN
      DBMS_EXT_TABLE_CACHE.CREATE_CACHE(
        owner          => 'PEAKGEAR_USER',
        table_name     => r.table_name,
        partition_type => 'FILE'
      );
      DBMS_EXT_TABLE_CACHE.ADD_TABLE(
        owner         => 'PEAKGEAR_USER',
        table_name    => r.table_name,
        percent_files => 100
      );
    END IF;
  END LOOP;
END;
</copy>
~~~

Run the inspection query again. CACHE&#95;CUR&#95;SIZE greater than zero proves that
files were populated. It does not prove that an enabled cache is correct or
faster. In the current lab environment, keep a disabled policy disabled if it
reports the known duplicate-read behavior. Do not claim acceleration without a
verified query plan and runtime comparison.

Before continuing, check the product catalog's required one-row-per-product
grain. Run this **single statement** in SQL Worksheet:

~~~sql
<copy>
SELECT COUNT(*) AS product_rows,
       COUNT(DISTINCT product_id) AS distinct_products
FROM iceberg.products@dbx_unity_peakgear;
</copy>
~~~

The two counts must match. If they do not, do not hide the problem with
`DISTINCT` or continue with inflated event counts. The workshop QA has observed
duplicate reads with enabled Lake Cache policies in a test reservation.
For that case, run the following **single PL/SQL block** as PEAKGEAR&#95;USER,
then rerun the count comparison:

~~~sql
<copy>
BEGIN
  DBMS_EXT_TABLE_CACHE.DISABLE(
    owner      => 'PEAKGEAR_USER',
    table_name => 'ICEBERG.PRODUCTS@DBX_UNITY_PEAKGEAR'
  );
  DBMS_EXT_TABLE_CACHE.DISABLE(
    owner      => 'PEAKGEAR_USER',
    table_name => 'ICEBERG.DIGITAL_CLICKSTREAM_EVENTS@DBX_UNITY_PEAKGEAR'
  );
END;
</copy>
~~~

Disabling these policies retains the cached files; it prevents cache rewrite.
Leave them disabled for the rest of this workshop when that resolves the
duplicate-read issue. If the counts still differ, stop and ask the instructor
to investigate the source. Do not deduplicate or invent a product mapping.

<!-- Screenshot to insert after approved dry run: images/lake-cache-policy.png
     Alt text: SQL Worksheet shows the PeakGear Lake Cache policy and its
     populated or disabled state for the two mounted Iceberg tables. -->

## Task 4: Prove the two live sources

Open SQL Worksheet as PEAKGEAR&#95;USER. Copy and run **each block separately**;
Run SQL executes the current statement, not every statement in a pasted script.

~~~sql
<copy>
SELECT COUNT(*) AS products
FROM iceberg.products@dbx_unity_peakgear;
</copy>
~~~

~~~sql
<copy>
SELECT COUNT(*) AS digital_clickstream_events
FROM iceberg.digital_clickstream_events@dbx_unity_peakgear;
</copy>
~~~

~~~sql
<copy>
SELECT COUNT(*) AS operational_return_events
FROM customer_return_events@peakgear_operations_link;
</copy>
~~~

All three queries must return a count. On a new reservation, create the three
raw, participant-owned views by running **each block separately**. If you are
resuming on the same database and the views already exist, verify them in
Catalog instead of recreating them. Do not replace views after reviewing and
saving their annotations in Lab 4.

~~~sql
<copy>
CREATE VIEW lab_products_raw_v AS
SELECT product_id,
       product_name,
       category AS category_name
FROM iceberg.products@dbx_unity_peakgear;
</copy>
~~~

~~~sql
<copy>
CREATE VIEW lab_digital_intent_raw_v AS
SELECT product_id,
       session_id,
       customer_id,
       CAST(event_ts AS TIMESTAMP) AS event_ts
FROM iceberg.digital_clickstream_events@dbx_unity_peakgear;
</copy>
~~~

~~~sql
<copy>
CREATE VIEW lab_returns_raw_v AS
SELECT product_id,
       store_id,
       return_qty,
       CAST(return_created_at AS TIMESTAMP) AS return_created_at
FROM customer_return_events@peakgear_operations_link;
</copy>
~~~

These views do not copy data and do not add business definitions. They give
PEAKGEAR&#95;USER a small, owned surface for Data Studio and the bounded MCP
server.

### Checkpoint

You can read both Iceberg tables and the Operations return table. The three
raw lab views exist under PEAKGEAR&#95;USER.

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
