-- SQL reference only; not part of the required Lab 2 workflow.
-- Run in SQL Worksheet as PEAKGEAR_USER after creating ADLS_PEAKGEAR_DATA.
-- Fill both placeholders from your active reservation's View Login Info.
-- This replaces only DBX_PEAKGEAR_OAUTH, and only when the catalog is absent.
-- Do not share or commit a filled-in worksheet.
DECLARE
  l_client_id CONSTANT VARCHAR2(4000) := '<DATABRICKS_CLIENT_ID_FROM_VIEW_LOGIN_INFO>';
  l_client_secret CONSTANT VARCHAR2(4000) := '<DATABRICKS_CLIENT_SECRET_FROM_VIEW_LOGIN_INFO>';
  l_exists PLS_INTEGER;
BEGIN
  IF USER <> 'PEAKGEAR_USER'
     OR SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'PEAKGEAR_USER' THEN
    RAISE_APPLICATION_ERROR(-20011,
      'Use SQL Worksheet connected as PEAKGEAR_USER in your assigned database.');
  END IF;

  IF l_client_id IS NULL OR SUBSTR(l_client_id, 1, 1) = '<'
     OR l_client_secret IS NULL OR SUBSTR(l_client_secret, 1, 1) = '<' THEN
    RAISE_APPLICATION_ERROR(-20012,
      'Copy Databricks Client ID and Databricks Client Secret from LiveLabs View Login Info.');
  END IF;

  SELECT COUNT(*) INTO l_exists
  FROM user_mounted_catalogs
  WHERE catalog_name = 'DBX_UNITY_PEAKGEAR';

  IF l_exists > 0 THEN
    RAISE_APPLICATION_ERROR(-20013,
      'DBX_UNITY_PEAKGEAR already exists. Inspect it in Catalog; do not rerun connection setup.');
  END IF;

  SELECT COUNT(*) INTO l_exists
  FROM user_credentials
  WHERE credential_name = 'ADLS_PEAKGEAR_DATA';

  IF l_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20014,
      'Complete Lab 2 Task 1 first: ADLS_PEAKGEAR_DATA is required.');
  END IF;

  SELECT COUNT(*) INTO l_exists
  FROM user_credentials
  WHERE credential_name = 'DBX_PEAKGEAR_OAUTH';

  IF l_exists > 0 THEN
    DBMS_CLOUD.DROP_CREDENTIAL('DBX_PEAKGEAR_OAUTH');
  END IF;

  DBMS_SHARE.CREATE_BEARER_TOKEN_CREDENTIAL(
    credential_name => 'DBX_PEAKGEAR_OAUTH',
    token_endpoint  =>
      'https://adb-2242907740736663.3.azuredatabricks.net/oidc/v1/token',
    client_id       => l_client_id,
    client_secret   => l_client_secret,
    token_scope     => 'all-apis'
  );
END;
/

BEGIN
  DBMS_CATALOG.MOUNT_ICEBERG(
    catalog_name            => 'DBX_UNITY_PEAKGEAR',
    endpoint                =>
      'https://adb-2242907740736663.3.azuredatabricks.net/api/2.1/' ||
      'unity-catalog/iceberg-rest/v1/catalogs/peakgear',
    catalog_credential      => 'DBX_PEAKGEAR_OAUTH',
    data_storage_credential => 'ADLS_PEAKGEAR_DATA',
    enabled                 => TRUE,
    catalog_type            => 'ICEBERG_UNITY'
  );
END;
/
