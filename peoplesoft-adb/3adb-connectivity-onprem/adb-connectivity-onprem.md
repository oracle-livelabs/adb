# ADB connectivity test for PeopleSoft On Premise

## Introduction

This lab walks you through the steps to establish connectivity between PeopleSoft on-premise system and  Oracle Autonomous Database shared

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Establish connectivity between source on-premise PeopleSoft system and ADB-S

### Prerequisites
* PeopleSoft on-premise system or Oracle Marketplace PeopleSoft image (Note: Peoplesoft Marketplcae images for HR system,Financials,Campus Solution etc can also be used in place of an on-premise PeopleSoft application,Refer to link [here](https://docs.oracle.com/en/applications/peoplesoft/peoplesoft-common/tutorial-deploy-demo-image/index.html#before_you_begin) for creation of new environment on OCI) 

* ADB-S wallet file to be downloaded to on-premise PeopleSoft database system or Oracle Marketplace PeopleSoft image
* Root or admin login privileges for the on-premise PeopleSoft database system
* Basic knowledge on Unix/shell commands 


## Task 1: Unzipping and Configuring the ADB-S Wallet
1. Login as root user to the source on-premise PeopleSoft database system

2. Navigate to the path where ADB-S wallet has been downloaded and create a directory and move the wallet to the directory,below are the commands to proceed with


       ```
               <copy>[root@pscs92dmo-lnxdb-2 ~]# ls -ltr Wallet_PSADB.zip
               -rw-rw-r-- 1 opc opc 20550 Apr 22 06:51 Wallet_PSADB.zip
               [root@pscs92dmo-lnxdb-2 ~]# mkdir wallet
               [root@pscs92dmo-lnxdb-2 ~]# mv Wallet_PSADB.zip wallet/ </copy>

       ```

3. Navigate to the new directory where the ADB-S wallet has been moved and unzip the wallet file


       ```
               <copy>[root@pscs92dmo-lnxdb-2 ~]# cd wallet/
               [root@pscs92dmo-lnxdb-2 wallet]# unzip Wallet_PSADB.zip
               Archive: Wallet_PSADB.zip
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
               <copy>[root@pscs92dmo-lnxdb-2 wallet]# pwd
               /root/wallet
               [root@pscs92dmo-lnxdb-2 wallet]# vi sqlnet.ora
               [root@pscs92dmo-lnxdb-2 wallet]# cat sqlnet.ora
               WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/root/wallet")))
               SSL_SERVER_DN_MATCH=yes </copy>
       ```



## Task 2: Testing connectivity between On-premise PeopleSoft Database system and ADB-S

1. Add environment variables for the current root user, get the $ORACLE_HOME path from the current on-prem installation and add in the environment variables


      ```
               <copy>[root@pscs92dmo-lnxdb-2 ~]# cd $HOME
               [root@pscs92dmo-lnxdb-2 ~]# vi .bashrc
               [root@pscs92dmo-lnxdb-2 wallet]# cat .bashrc
               ORACLE_HOME=/u01/app/oracle/product/19.0.0.0/dbhome_1; export ORACLE_HOME
               PATH=$PATH:/u01/app/oracle/product/19.0.0.0/dbhome_1/bin; export PATH
               LD_LIBRARY_PATH=/u01/app/oracle/product/19.0.0.0/dbhome_1/lib; export LD_LIBRARY_PATH
               export TNS_ADMIN=/root/wallet
               [root@pscs92dmo-lnxdb-2 wallet]# source .bashrc </copy>
       ```

2. Do a connectivity test using sqlplus and provide the admin credentials

      ```
               <copy>[root@pscs92dmo-lnxdb-2 wallet]# sqlplus admin@psadb_high
               SQL*Plus: Release 19.0.0.0.0 - Production on Thu Apr 22 07:00:09 2021
               Version 19.10.0.0.0
               Copyright (c) 1982, 2020, Oracle. All rights reserved.
               Enter password:
               Connected to:
               Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
               Version 19.5.0.0.0
               SQL>  </copy>
      ```

You may now **proceed to the next lab.**


## Acknowledgements
* **Authors** - Deepak Kumar M, PeopleSoft Architect
* **Contributors** - Deepak Kumar M, PeopleSoft Architect
* **Last Updated By/Date** - Deepak Kumar M, PeopleSoft Architect, Aug 2021


