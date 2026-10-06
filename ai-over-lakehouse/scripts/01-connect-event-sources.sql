--------------------------------------------------------------------------------
-- PeakGear event | SQL alternative to the Data Studio credential/mount UI.
-- Run in SQL Worksheet as PEAKGEAR_USER, after Lab 1 ADMIN setup.
-- Event values and mount calls are from the owner's confirmed working script.
-- This worksheet does not drop credentials, unmount catalogs, or change source data.
-- Execute each CREATE block only when its inspection query shows no matching object.
-- The Databricks host:443 ACL belongs in 00-admin-setup.sql as ADMIN for PEAKGEAR_USER.
--------------------------------------------------------------------------------

SELECT USER AS database_user,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;
-- Both values must be PEAKGEAR_USER. Stop if either differs.

-- 1. Inspect, then create only missing source credentials.
SELECT credential_name, username, comments
FROM user_credentials
WHERE credential_name IN ('ADLS_PEAKGEAR_DATA', 'DBX_PEAKGEAR_OAUTH')
ORDER BY credential_name;

-- Run only if ADLS_PEAKGEAR_DATA is absent.
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'ADLS_PEAKGEAR_DATA',
    username        => 'livelab',
    password        => 'tFODcOQJpwaApm/p3wEqAdYIbvq9/N/jlMsbd2EMz6KwAyXps2+7D1TWLOvBQ8fCPOxaCXznM/YD+AStYElH9Q==',
    comments        => 'Event storage credential for PeakGear Unity managed Iceberg'
  );
END;
/

-- Run only if DBX_PEAKGEAR_OAUTH is absent.
BEGIN
  DBMS_SHARE.CREATE_BEARER_TOKEN_CREDENTIAL(
    credential_name => 'DBX_PEAKGEAR_OAUTH',
    token_endpoint  => 'https://adb-2242907740736663.3.azuredatabricks.net/oidc/v1/token',
    client_id       => '5c47dc63-f693-4820-a40b-4b08c3709f34',
    client_secret   => 'dose7b979ac313c1063af5d4cdf09b1ee8fb',
    token_scope     => 'all-apis'
  );
END;
/

-- 2. Validate Azure storage and refresh the renewable OAuth credential.
SELECT object_name
FROM DBMS_CLOUD.LIST_OBJECTS(
  'ADLS_PEAKGEAR_DATA',
  'https://livelab.blob.core.windows.net/digital-demand/peakgear-managed/'
)
FETCH FIRST 5 ROWS ONLY;

BEGIN
  DBMS_SHARE.REFRESH_BEARER_TOKEN_CREDENTIAL(
    credential_name => 'DBX_PEAKGEAR_OAUTH'
  );
END;
/

-- 3. Inspect, then mount only if DBX_UNITY_PEAKGEAR is absent.
SELECT catalog_name, catalog_type, is_enabled
FROM user_mounted_catalogs
WHERE catalog_name = 'DBX_UNITY_PEAKGEAR';

BEGIN
  DBMS_CATALOG.MOUNT_ICEBERG(
    catalog_name            => 'DBX_UNITY_PEAKGEAR',
    endpoint                => 'https://adb-2242907740736663.3.azuredatabricks.net/api/2.1/unity-catalog/iceberg-rest/v1/catalogs/peakgear',
    catalog_credential      => 'DBX_PEAKGEAR_OAUTH',
    data_storage_credential => 'ADLS_PEAKGEAR_DATA',
    enabled                 => TRUE,
    catalog_type            => 'ICEBERG_UNITY'
  );
END;
/

-- 4. Confirm the local credential map and discover both remote tables.
SELECT JSON_QUERY(
  DBMS_CATALOG.GET_LOCAL_CREDENTIAL_MAP('DBX_UNITY_PEAKGEAR', 1, 1),
  '$' PRETTY
) AS credential_mapping
FROM dual;

BEGIN
  DBMS_CATALOG.FLUSH_CATALOG_CACHE('DBX_UNITY_PEAKGEAR');
END;
/

SELECT schema_name
FROM DBMS_CATALOG.GET_SCHEMAS('DBX_UNITY_PEAKGEAR')
ORDER BY schema_name;

SELECT owner, table_name
FROM all_tables@DBX_UNITY_PEAKGEAR
WHERE UPPER(owner) = 'ICEBERG'
ORDER BY owner, table_name;

SELECT COUNT(*) AS digital_clickstream_events
FROM ICEBERG.DIGITAL_CLICKSTREAM_EVENTS@DBX_UNITY_PEAKGEAR;

SELECT COUNT(*) AS products
FROM ICEBERG.PRODUCTS@DBX_UNITY_PEAKGEAR;

-- Expected: ICEBERG schema, PRODUCTS and DIGITAL_CLICKSTREAM_EVENTS,
-- and a positive count for both tables. Continue with Lab 3 Task 3 (Lake Cache).
