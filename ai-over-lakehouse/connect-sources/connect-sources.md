# Lab 3: Connect real sources

Estimated Time: 15 minutes

## Introduction

PeakGear does not copy source data into a staging table. It connects two live
systems:

* Databricks Unity Catalog supplies the Iceberg product catalog and digital
  clickstream events.
* The existing Oracle Operations database supplies return events through the
  public database link created in Lab 1.

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
recreate a mount that already works. The host ACL is already granted in Lab 1
by ADMIN for PEAKGEAR&#95;USER.

## Task 3: Add the Lake Cache policy

Immediately after the mount, create and populate a Lake Cache policy for both
mounted tables. Run the following in SQL Worksheet as PEAKGEAR&#95;USER. If the
inspection query already shows a policy, verify it instead of recreating it.

~~~sql
<copy>
SELECT external_table_name,
       cached,
       cache_cur_size / 1024 / 1024 AS cache_size_mb,
       disabled
FROM user_external_tab_caches
ORDER BY external_table_name;

BEGIN
  DBMS_EXT_TABLE_CACHE.CREATE_CACHE(
    owner          => 'PEAKGEAR_USER',
    table_name     => 'ICEBERG.PRODUCTS@DBX_UNITY_PEAKGEAR',
    partition_type => 'FILE'
  );
END;
/

BEGIN
  DBMS_EXT_TABLE_CACHE.CREATE_CACHE(
    owner          => 'PEAKGEAR_USER',
    table_name     => 'ICEBERG.DIGITAL_CLICKSTREAM_EVENTS@DBX_UNITY_PEAKGEAR',
    partition_type => 'FILE'
  );
END;
/

BEGIN
  DBMS_EXT_TABLE_CACHE.ADD_TABLE(
    owner         => 'PEAKGEAR_USER',
    table_name    => 'ICEBERG.PRODUCTS@DBX_UNITY_PEAKGEAR',
    percent_files => 100
  );
END;
/

BEGIN
  DBMS_EXT_TABLE_CACHE.ADD_TABLE(
    owner         => 'PEAKGEAR_USER',
    table_name    => 'ICEBERG.DIGITAL_CLICKSTREAM_EVENTS@DBX_UNITY_PEAKGEAR',
    percent_files => 100
  );
END;
/
</copy>
~~~

Run the inspection query again. CACHE&#95;CUR&#95;SIZE greater than zero proves that
files were populated. It does not prove that an enabled cache is correct or
faster. In the current lab environment, keep a disabled policy disabled if it
reports the known duplicate-read behavior. Do not claim acceleration without a
verified query plan and runtime comparison.

<!-- Screenshot to insert after approved dry run: images/lake-cache-policy.png
     Alt text: SQL Worksheet shows the PeakGear Lake Cache policy and its
     populated or disabled state for the two mounted Iceberg tables. -->

## Task 4: Prove the two live sources

Open SQL Worksheet as PEAKGEAR&#95;USER and run:

~~~sql
<copy>
SELECT COUNT(*) AS products
FROM iceberg.products@dbx_unity_peakgear;

SELECT COUNT(*) AS digital_clickstream_events
FROM iceberg.digital_clickstream_events@dbx_unity_peakgear;

SELECT COUNT(*) AS operational_return_events
FROM customer_return_events@peakgear_operations_link;
</copy>
~~~

All three queries must return a count. Then create the raw, participant-owned
views:

~~~sql
<copy>
CREATE OR REPLACE VIEW lab_products_raw_v AS
SELECT product_id,
       product_name,
       category AS category_name
FROM iceberg.products@dbx_unity_peakgear;

CREATE OR REPLACE VIEW lab_digital_intent_raw_v AS
SELECT product_id,
       session_id,
       customer_id,
       CAST(event_ts AS TIMESTAMP) AS event_ts
FROM iceberg.digital_clickstream_events@dbx_unity_peakgear;

CREATE OR REPLACE VIEW lab_returns_raw_v AS
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
