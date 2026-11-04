--------------------------------------------------------------------------------
-- PeakGear source-connection reference; not an extra required learner task.
-- Provisioning already creates ADLS_PEAKGEAR_DATA and DBX_PEAKGEAR_OAUTH.
-- Use the assigned PEAKGEAR_USER database session. No source secrets are needed.
-- The guarded mount is the same as scripts/02-unity-sql-reference.sql.
-- Run the mount block, then each sample SELECT separately.
--------------------------------------------------------------------------------

-- SQL reference only; not part of the required Lab 2 workflow.
-- Run as PEAKGEAR_USER with both source credentials already provisioned.
-- This block reuses credentials and mounts only when the catalog is absent.
DECLARE
  l_credential_count PLS_INTEGER;
  l_catalog_count PLS_INTEGER;
BEGIN
  IF USER <> 'PEAKGEAR_USER'
     OR SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'PEAKGEAR_USER' THEN
    RAISE_APPLICATION_ERROR(-20011,
      'Use SQL Worksheet connected as PEAKGEAR_USER in your assigned database.');
  END IF;

  SELECT COUNT(*) INTO l_credential_count
  FROM user_credentials
  WHERE credential_name IN ('ADLS_PEAKGEAR_DATA', 'DBX_PEAKGEAR_OAUTH');

  IF l_credential_count <> 2 THEN
    RAISE_APPLICATION_ERROR(-20014,
      'Provisioned source credentials are missing. Ask the instructor to repair this reservation.');
  END IF;

  SELECT COUNT(*) INTO l_catalog_count
  FROM user_mounted_catalogs
  WHERE catalog_name = 'DBX_UNITY_PEAKGEAR';

  IF l_catalog_count = 0 THEN
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
  ELSE
    DBMS_OUTPUT.PUT_LINE(
      'DBX_UNITY_PEAKGEAR already exists. Continue with the sample reads in Lab 2 Task 3.');
  END IF;
END;
/

-- Both Iceberg tables and the Operations source should return sample rows.
SELECT *
FROM iceberg.products@dbx_unity_peakgear
FETCH FIRST 5 ROWS ONLY;

SELECT *
FROM iceberg.digital_clickstream_events@dbx_unity_peakgear
FETCH FIRST 5 ROWS ONLY;

SELECT *
FROM customer_return_events@peakgear_operations_link
FETCH FIRST 5 ROWS ONLY;

-- Continue with Lab 2 Task 3 for the three local snapshot tables.
-- Product-key uniqueness is checked locally before analytics.
