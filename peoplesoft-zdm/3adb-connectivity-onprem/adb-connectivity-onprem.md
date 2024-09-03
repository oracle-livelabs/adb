# Source Database, ADB connectivity test and Target Database (ADB-S) Configuration

## Introduction


This lab walks you through the steps to establish connectivity between PeopleSoft on-premises system and  Oracle Autonomous Database shared, configuring source database and target database (ADB-S) for export using ZDM.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Establish connectivity between source on-premise PeopleSoft system and ADB-S

### Prerequisites

* PeopleSoft on-premises system or Oracle Marketplace PeopleSoft image (Note: PeopleSoft Marketplace images for HR system, Financial, Campus Solution etc can also be used in place of an on-premises PeopleSoft application,Refer to link [here](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3208) for creation of new environment on OCI) 
* ADB-S wallet file to be downloaded to on-premises PeopleSoft database system or Oracle Marketplace PeopleSoft image
* Root or admin login privileges for the on-premises PeopleSoft database system
* Basic knowledge on Unix/shell commands 

## Task 1: Source Database configuration for ZDM migration

1. Set the stream pool size to minimum 1G before we start with the ZDM migration.

       ```
   <copy>SQL> alter system set streams_pool_size=1G scope=spfile sid='*'; </copy>

       ```
2. Make sure to enable Database archive log mode, if not enabled. Connect as sys user and run the following:


       ```
   <copy>SQL> shut immediate
SQL> startup mount
SQL> alter database archivelog;
SQL> alter database open; </copy>

       ```
## Task 2: Getting Source Database Tablespace information

1. We need to get the source tablespace list and do re-map with target database as the target database only uses DATA and TEMP tablespaces.

       ```
           <copy>Permanent Tablespace from source database
            set heading off;
            set echo off;
            set pages 999;
            set linesize 400;
            set long 90000;
            spool permanent_tablespace.txt;
            SELECT 'DATAPUMPSETTINGS_METADATAREMAPS-1=type:REMAP_TABLESPACE,oldValue:' || TABLESPACE_NAME ||
            ',newValue:DATA' FROM USER_TABLESPACES WHERE TABLESPACE_NAME not in ('SYSTEM','SYSAUX') and CONTENTS not in ('UNDO', 'TEMPORARY');
            spool off; 
             </copy>
       ```

       ```
         <copy>Temporary Tablespace from source database
         set heading off;
         set echo off;
         set pages 999;
         set linesize 400;
         set long 90000;
         spool temporary_tablespace.txt;
         SELECT 'DATAPUMPSETTINGS_METADATAREMAPS-1=type:REMAP_TABLESPACE,oldValue:' || TABLESPACE_NAME ||
         ',newValue:TEMP' FROM USER_TABLESPACES WHERE CONTENTS in ('TEMPORARY');
         spool off; 
          </copy>
       
       ```

## Task 3: Unzipping and Configuring the ADB-S Wallet


1. Login as oracle2 user or user configured for the source on-premises PeopleSoft database system

2. Navigate to the path where ADB-S wallet has been downloaded and create a directory and move the wallet to the directory,below are the commands to proceed with


       ```
        <copy>[oracle2@psfthcm9247 db]$ ls -ltr Wallet_PSATP.zip
        -rw-r--r--. 1 oracle2 oinstall 21990 Nov 20 10:12 Wallet_PSATP.zip
        [oracle2@psfthcm9247 db]# mkdir wallet
        [oracle2@psfthcm9247 db]# mv Wallet_PSATP.zip wallet/ </copy>

       ```

3. Navigate to the new directory where the ADB-S wallet has been moved and unzip the wallet file


       ```
        <copy>[oracle2@psfthcm9247 ~]# cd wallet/
        [oracle2@psfthcm9247 wallet]# unzip Wallet_PSATP.zip
        Archive: Wallet_PSATP.zip
        inflating: ewallet.pem
        inflating: README
        inflating: cwallet.sso
        inflating: tnsnames.ora
        inflating: truststore.jks
        inflating: ojdbc.properties
        inflating: sqlnet.ora
        inflating: ewallet.p12
        inflating: keystore.jks </copy>

       ```

4. Using Vi editor, edit the contents of the sqlnet.ora and add the current path of the wallet directory


       ```
        <copy>[oracle2@psfthcm9247 wallet]# pwd
        /psft/hcm9247/db/wallet
        [oracle2@psfthcm9247 wallet]# vi sqlnet.ora
        [oracle2@psfthcm9247 wallet]# cat sqlnet.ora
        WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/psft/hcm9247/db/wallet")))
        SSL_SERVER_DN_MATCH=yes </copy>
       ```



## Task 4: Testing connectivity between On-premises PeopleSoft Database system and ADB-S

1. Add environment variables for the current root user, get the $ORACLE_HOME path from the current on-premises installation and add in the environment variables


      ```
        <copy>[oracle2@psfthcm9247 ~]# cd $HOME
        [oracle2@psfthcm9247 ~]# vi .bashrc
        [oracle2@psfthcm9247 ~]# cat .bashrc
        ORACLE_HOME=/u01/app/oracle/product/19.0.0.0/dbhome_1; export ORACLE_HOME
        PATH=$PATH:/u01/app/oracle/product/19.0.0.0/dbhome_1/bin; export PATH
        LD_LIBRARY_PATH=/u01/app/oracle/product/19.0.0.0/dbhome_1/lib; export LD_LIBRARY_PATH
        export TNS_ADMIN=/psft/hcm9247/db/wallet
        [oracle2@psfthcm9247 ~]# source .bashrc </copy>
       ```

2. Do a connectivity test using sqlplus and provide the admin credentials

      ```
        <copy>[oracle2@psfthcm9247 ~]$ sqlplus admin@psatp_tpurgent
        SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 20 10:25:29 2023
        Version 19.19.0.0.0
        Copyright (c) 1982, 2022, Oracle. All rights reserved.
        Enter password:
        Connected to:
        Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
        Version 19.21.0.1.0
        SQL>  </copy>
      ```

## Task 5: Target Database configuration for ZDM migration

1. Connect to the target database (ADB-S) and run  the following query and update to CHAR

      ```
        <copy>SQL> show parameter nls_length
        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        nls_length_semantics                 string      BYTE
         </copy>
      ```

      ```
        <copy>SQL> alter system set nls_length_semantics=CHAR;
        SQL> commit; </copy>
      ```


You may now **proceed to the next lab.**


## Acknowledgements
* **Authors** - Deepak Kumar M, Principal Cloud Architect
* **Contributors** - Deepak Kumar M, Principal Cloud Architect
* **Last Updated By/Date** - Deepak Kumar M, Principal Cloud Architect, December 2023



