-- PeakGear LiveLab: legacy provider/operator provisioning reference only.
-- Not a learner step. LiveLabs reservations must already be provisioned.
-- Reservation-specific passwords come from provisioning, not the example below.
-- Do not rerun against a prepared reservation. See documentation/provisioning.md.
-- Event-owner-approved shared values are included for copy/paste.
-- Use only in the assigned event database. This script does not reset existing users.

-- 1. Check whether the participant schema already exists.
SELECT username,
       account_status
FROM dba_users
WHERE username = 'PEAKGEAR_USER';

-- 2. Run this statement only when the query above returned no row.
CREATE USER PEAKGEAR_USER
  IDENTIFIED BY "Welcome123456"
  DEFAULT TABLESPACE DATA
  TEMPORARY TABLESPACE TEMP
  QUOTA 2000M ON DATA
  ACCOUNT UNLOCK;

-- 3. Run these grants for a new or existing participant.
-- They allow only the objects built in this lab: local tables, views,
-- attribute dimensions, hierarchies, and analytic views.
GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE ATTRIBUTE DIMENSION,
      CREATE HIERARCHY,
      CREATE ANALYTIC VIEW
TO PEAKGEAR_USER;

-- DWROLE exposes the required Data Studio tools. It includes the Select AI
-- package access required by this lab, so no broad EXECUTE ANY grant is used.
GRANT DWROLE TO PEAKGEAR_USER;

-- 4. Enable the database Resource Principal once per Autonomous AI Database.
-- Run this only if the verification query returns no ADMIN credential row.
SELECT owner,
       credential_name
FROM dba_credentials
WHERE owner = 'ADMIN'
  AND credential_name = 'OCI$RESOURCE_PRINCIPAL';

BEGIN
  DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL();
END;
/

-- 5. Give the participant access to the database-managed credential.
-- Run this only if the verification query returns no PEAKGEAR_USER grant row.
SELECT grantee,
       table_name,
       grantor
FROM all_tab_privs
WHERE grantee = 'PEAKGEAR_USER'
  AND table_name = 'OCI$RESOURCE_PRINCIPAL'
  AND table_schema = 'ADMIN';

BEGIN
  DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL(
    username => 'PEAKGEAR_USER'
  );
END;
/

-- 6. Enable schema-based Data Studio and ORDS access.
-- If PEAKGEAR_USER already has a different ORDS alias, use the targeted
-- disable/enable recovery documented in the LiveLab before running this block.
BEGIN
  ORDS_ADMIN.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => 'PEAKGEAR_USER',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'peakgear_user',
    p_auto_rest_auth      => NULL
  );
  COMMIT;
END;
/

-- 7. Create the shared Operations connection before the participant logs in.
-- Check both objects first. Run each create block only when that object is absent.
SELECT credential_name
FROM user_credentials
WHERE credential_name = 'PEAKGEAR_OPS_CREDENTIAL';

SELECT owner,
       db_link,
       username,
       host
FROM dba_db_links
WHERE db_link = 'PEAKGEAR_OPERATIONS_LINK';

BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'PEAKGEAR_OPS_CREDENTIAL',
    username        => 'PEAKGEAR_OPS',
    password        => 'Welcome123456'
  );
END;
/

BEGIN
  DBMS_CLOUD_ADMIN.CREATE_DATABASE_LINK(
    db_link_name    => 'PEAKGEAR_OPERATIONS_LINK',
    hostname        => 'adb.us-ashburn-1.oraclecloud.com',
    port            => 1522,
    service_name    => 'mqssyowmqvgac1y_operationalstore_low.adb.oraclecloud.com',
    credential_name => 'PEAKGEAR_OPS_CREDENTIAL',
    directory_name  => NULL,
    public_link     => TRUE
  );
END;
/

SELECT *
FROM customer_return_events@peakgear_operations_link
FETCH FIRST 5 ROWS ONLY;

-- 8. Legacy provider-only URL lookup; not a learner task.
-- Learners run this read-only URL query in Lab 3, Task 1 as PEAKGEAR_USER.
-- The provider must verify that the prepared reservation permits this lookup.
SELECT 'https://' ||
       LOWER(REPLACE(p.name, '_', '-')) || '.' ||
       REGEXP_REPLACE(j.public_domain_name, '[^.]+', 'oraclecloudapps', 1, 3)
         AS adp_url
FROM v$pdbs p
CROSS JOIN JSON_TABLE(
  p.cloud_identity,
  '$' COLUMNS (
    public_domain_name VARCHAR2(512) PATH '$.PUBLIC_DOMAIN_NAME'
  )
) j
WHERE p.con_id = SYS_CONTEXT('USERENV', 'CON_ID');

-- 9. Permit this participant to call the Databricks Unity OAuth endpoint.
-- Run only after PEAKGEAR_USER exists. This ACE is not required for OCI
-- Generative AI and must not be granted to ADMIN by using CURRENT_USER.
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host        => 'adb-2242907740736663.3.azuredatabricks.net',
    lower_port  => 443,
    upper_port  => 443,
    ace         => XS$ACE_TYPE(
      privilege_list => XS$NAME_LIST('http', 'http_proxy'),
      principal_name  => 'PEAKGEAR_USER',
      principal_type  => XS_ACL.PTYPE_DB
    )
  );
END;
/

-- If this statement returns ORA-46215, do not run a broad ACL cleanup.
-- Follow the targeted host:443 recovery in the full LiveLab, then retry.

-- 10. Verify database grants. The participant must sign out of Data Studio and
-- sign back in after this provisioning completes.
SELECT granted_role
FROM dba_role_privs
WHERE grantee = 'PEAKGEAR_USER'
  AND granted_role = 'DWROLE';

SELECT privilege
FROM dba_sys_privs
WHERE grantee = 'PEAKGEAR_USER'
ORDER BY privilege;

-- Deliberately not granted: DBA, CREATE ANY, ALTER ANY, DROP ANY,
-- DBMS_NETWORK_ACL_ADMIN, or EXECUTE ANY PROCEDURE.
