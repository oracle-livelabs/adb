BEGIN
     DBMS_CLOUD_ADMIN.SET_FLASHBACK_ARCHIVE_RETENTION(
           retention_days => 90); // sets the retention time to 90 days
END;
/

