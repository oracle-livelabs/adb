# PeopleSoft post import scripts for ADB-S

## Introduction

This lab walks you through the steps to run post import configuration scripts for  ADB-S database.

Estimated Time: 10 minutes

### Objectives
In this lab, you will:
* Run SQL scripts to post configure ADB-S for PeopleSoft
 
### Prerequisites
* Root login to the on-premise system and connected to ADB-S database using ADB wallet


## Task: Login to ADB-S and perform the SQL execution

Login to the on-premise PeopleSoft system as root and connect to the ADB-S database and execute the following SQL commands for post configuration of  the database after performing the MV2ADB operation

   ```
<copy>[root@pscs92dmo-lnxdb-2 conf]# sqlplus admin@psadb_high
SQL*Plus: Release 19.0.0.0.0 - Production on Thu Apr 22 13:21:00 2021
Version 19.10.0.0.0
Copyright (c) 1982, 2020, Oracle. All rights reserved.
Enter password:
Last Successful login time: Thu Apr 22 2021 12:51:40 +00:00
Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.5.0.0.0
SQL> grant select,insert,update,delete on PS.PSDBOWNER to PSADMIN;
Grant succeeded.
SQL> grant PSADMIN TO SYSADM;
Grant succeeded.
SQL> grant unlimited tablespace to SYSADM;
Grant succeeded.

SQL> delete from PS.PSDBOWNER;
1 row deleted
SQL> insert into PS.PSDBOWNER values('PSADB','SYSADM');
1 row created.
SQL> grant select on SYSADM.PSSTATUS to people;
Grant succeeded.
SQL> grant select on SYSADM.PSOPRDEFN to people;
Grant succeeded.
SQL> grant select on SYSADM.PSACCESSPRFL to people;
Grant succeeded.
SQL> grant select on SYSADM.PSACCESSPROFILE to people;
Grant succeeded.
SQL> GRANT CREATE SESSION to people;
Grant succeeded.
SQL> GRANT CREATE SESSION to SYSADM;
Grant succeeded.
SQL> GRANT SELECT ON PS.PSDBOWNER TO people;
Grant succeeded.
SQL> commit;
Commit complete.
SQL> select * from PS.PSDBOWNER;
DBNAME OWNERID
-------- --------
PSADB SYSADM
</copy>
   ```

You may now **proceed to the next lab.**

## Acknowledgements
* **Authors** - Deepak Kumar M, PeopleSoft Architect
* **Contributors** - Deepak Kumar M, PeopleSoft Architect
* **Last Updated By/Date** - Deepak Kumar M, PeopleSoft Architect, Aug 2021


