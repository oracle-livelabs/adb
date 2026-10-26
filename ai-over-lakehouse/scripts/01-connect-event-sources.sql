--------------------------------------------------------------------------------
-- PeakGear event | SQL alternative to the Data Studio credential/mount UI.
-- Run in SQL Worksheet as PEAKGEAR_USER in the prepared LiveLabs reservation.
-- Template only: obtain protected values from LiveLabs View Login Info.
-- Replace the three placeholders in your private worksheet before execution.
-- Never commit or share a completed worksheet. Public endpoints remain below.
-- This worksheet does not drop credentials, unmount catalogs, or change source data.
-- Execute each CREATE block only when its inspection query shows no matching object.
-- The provider already prepares the Databricks host:443 ACL for PEAKGEAR_USER.
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
-- Copy Azure Storage Password from View Login Info > Environment Details.
DECLARE
  l_storage_password CONSTANT VARCHAR2(32767) := '<AZURE_STORAGE_PASSWORD_FROM_VIEW_LOGIN_INFO>';
BEGIN
  IF l_storage_password IS NULL OR SUBSTR(l_storage_password, 1, 1) = '<' THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Copy Azure Storage Password from LiveLabs View Login Info before running this block.');
  END IF;
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'ADLS_PEAKGEAR_DATA',
    username        => 'livelab',
    password        => l_storage_password,
    comments        => 'Event storage credential for PeakGear Unity managed Iceberg'
  );
END;
/

-- Run only if DBX_PEAKGEAR_OAUTH is absent.
-- Copy both Databricks fields from View Login Info > Environment Details.
DECLARE
  l_client_id CONSTANT VARCHAR2(4000) := '<DATABRICKS_CLIENT_ID_FROM_VIEW_LOGIN_INFO>';
  l_client_secret CONSTANT VARCHAR2(4000) := '<DATABRICKS_CLIENT_SECRET_FROM_VIEW_LOGIN_INFO>';
BEGIN
  IF l_client_id IS NULL OR SUBSTR(l_client_id, 1, 1) = '<'
     OR l_client_secret IS NULL OR SUBSTR(l_client_secret, 1, 1) = '<' THEN
    RAISE_APPLICATION_ERROR(-20002,
      'Copy Databricks Client ID and Databricks Client Secret from LiveLabs View Login Info before running this block.');
  END IF;
  DBMS_SHARE.CREATE_BEARER_TOKEN_CREDENTIAL(
    credential_name => 'DBX_PEAKGEAR_OAUTH',
    token_endpoint  => 'https://adb-2242907740736663.3.azuredatabricks.net/oidc/v1/token',
    client_id       => l_client_id,
    client_secret   => l_client_secret,
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

SELECT *
FROM ICEBERG.DIGITAL_CLICKSTREAM_EVENTS@DBX_UNITY_PEAKGEAR
FETCH FIRST 5 ROWS ONLY;

SELECT *
FROM ICEBERG.PRODUCTS@DBX_UNITY_PEAKGEAR
FETCH FIRST 5 ROWS ONLY;

-- Expected: ICEBERG schema, PRODUCTS and DIGITAL_CLICKSTREAM_EVENTS,
-- and sample rows from both tables. Continue with Lab 2 Task 3
-- (Prove the two live sources) for five-row previews and local table creation.
-- Product-key uniqueness is checked against the local table before analytics.
