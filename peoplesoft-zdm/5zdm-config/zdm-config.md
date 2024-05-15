# ZDM user configuration and network connectivity between source & target systems

## Introduction


This lab walks you through the steps  for ZDM user configuration and establishing network connectivity between source and target database systems. Also, you will be generating a list of Oracle Tablespaces created on the on-premises PeopleSoft application and to map it with the DATA  and TEMP tablespace on ADB-S


Estimated Time: 5 minutes

### Objectives
In this lab, you will:

* Establish Oracle TNS and User connectivity
* Gather tablespaces from on-premises PeopleSoft system and map them to ADB-S



## Task 1: Oracle TNS and User connectivity

1. Add the TNS entry for ATP in the source database tnsnames.ora file, make sure to have both source and target database configuration under on tns file and also have the ADB wallet entry files in the same folder. The current folder path is (/psft/hcm9247/db/wallet)

2. As ZDM user, add the  following entries in the bash profile

     ```
     <copy>[zdmuser@psfthcm9247 ~]$ vi .bashrc
     export TNS_ADMIN=/psft/hcm9247/db/wallet
     export PATH=/psft/hcm9247/db/oracle-server/19.3.0.0/bin:$PATH
     </copy>
     ```

3. As zdm user, check connectivity for source and target ATP database

     ```
     <copy> Source Database
     [zdmuser@psfthcm9247 ~]$ sqlplus SYSADM@hcm9247

     SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 20 13:00:00 2023
     Version 19.19.0.0.0

     Copyright (c) 1982, 2022, Oracle.  All rights reserved.

     Enter password:
     Last Successful login time: Mon Nov 20 2023 09:15:28 +00:00

     Connected to:
     Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
     Version 19.19.0.0.0

     SQL>
     </copy>

     ```

     Target Database
     ```
     <copy> Target Database
     [zdmuser@psfthcm9247 ~]$ sqlplus admin@psatp_tpurgent

     SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 20 13:03:34 2023
     Version 19.19.0.0.0

     Copyright (c) 1982, 2022, Oracle.  All rights reserved.

     Enter password:
     Last Successful login time: Mon Nov 20 2023 10:25:34 +00:00

     Connected to:
     Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
     Version 19.21.0.1.0

     SQL>

     </copy>

     ```

4. Ssh keygen pair created for zdm user and Oracle2 user (source database user)

     As ZDM user run the below commands:

     ```
     <copy>
     [zdmuser@psfthcm9247 ~]$ ssh-keygen
     Generating public/private rsa key pair.
     Enter file in which to save the key (/home/zdmuser/.ssh/id_rsa):
     Created directory '/home/zdmuser/.ssh'.
     Enter passphrase (empty for no passphrase):
     Enter same passphrase again:
     Your identification has been saved in /home/zdmuser/.ssh/id_rsa.
     Your public key has been saved in /home/zdmuser/.ssh/id_rsa.pub.
     The key fingerprint is:
     SHA256:G2qwdIdNzW+8mtuRqHIy75UTo4CZWpeMJC0RxN9o6zk zdmuser@psfthcm9247
     The key's randomart image is:
     +---[RSA 3072]----+
     | o+.             |
     |  .o     o       |
     |  o.oo  . o      |
     |   ++*.=   o     |
     |   .O.B S o +    |
     |   +.= + + * o   |
     |  ....o o = +    |
     |    E.+ .o = .   |
     |     . B+ +..    |
     +----[SHA256]-----+
     [zdmuser@psfthcm9247 ~]$
     </copy>
     ```

     As oracle2 (source database user) run the below ssh keygen command:

     ```
     <copy>
     [oracle2@psfthcm9247 ~]$ ssh-keygen
     Generating public/private rsa key pair.
     Enter file in which to save the key (/home/oracle2/.ssh/id_rsa):
     Enter passphrase (empty for no passphrase):
     Enter same passphrase again:
     Your identification has been saved in /home/oracle2/.ssh/id_rsa.
     Your public key has been saved in /home/oracle2/.ssh/id_rsa.pub.
     The key fingerprint is:
     SHA256:Ra4pHo2sfsGVHDpFxzDBTvkYl4hqv9rCcoItrWkzRGU oracle2@psfthcm9247
     The key's randomart image is:
     +---[RSA 3072]----+
     |       +=*o.     |
     |   E  . O=+      |
     |  o  . * Bo      |
     | .  o.oo*+.      |
     |.  . o=oS        |
     | .   o+o         |
     |.+ .. .o         |
     |o==.+.o          |
     |+oo+o+.          |
     +----[SHA256]-----+
     [oracle2@psfthcm9247 ~]$
     </copy>
     ```


5. Setup ssh connectivity from zdm user to oracle2 user

     As zdm user, run the following commands:

     ```
     <copy>
     [zdmuser@psfthcm9247 ~]$ cd ~/.ssh
     [zdmuser@psfthcm9247 .ssh]$ cat id_rsa.pub >> authorized_keys
     [zdmuser@psfthcm9247 .ssh]$ chmod 600 authorized_keys
     [zdmuser@psfthcm9247 .ssh]$ ssh-keygen -p -m PEM -f id_rsa
     Key has comment 'zdmuser@psfthcm9247'
     Enter new passphrase (empty for no passphrase):
     Enter same passphrase again:
     Your identification has been saved with the new passphrase.
     [zdmuser@psfthcm9247 .ssh]$
     </copy>
     ```

     As oracle2 user, run the following commands:

     ```
     <copy>
     [oracle2@psfthcm9247 ~]$ cd ~/.ssh
     [oracle2@psfthcm9247 .ssh]$ cat id_rsa.pub >> authorized_keys
     [oracle2@psfthcm9247 .ssh]$ chmod 600 authorized_keys
     [oracle2@psfthcm9247 .ssh]$ ssh-keygen -p -m PEM -f id_rsa
     Key has comment 'oracle2@psfthcm9247'
     Enter new passphrase (empty for no passphrase):
     Enter same passphrase again:
     Your identification has been saved with the new passphrase.
     [oracle2@psfthcm9247 .ssh]$
     </copy>
     ```

6. Copy zdmuser public key (id\_rsa.pub) into authorized_key file of oracle2 user

7. Try ssh connection from zdm user to the oracle2 user 

     ```
     <copy>
     [zdmuser@psfthcm9247 ~]$ cd .ssh/
     [zdmuser@psfthcm9247 .ssh]$ ssh -i id_rsa oracle2@psfthcm9247
     Activate the web console with: systemctl enable --now cockpit.socket

     Last login: Mon Nov 20 13:20:19 2023
     [oracle2@psfthcm9247 ~]$
     </copy>
     ```

8. Add sudo priveleges for zdm user and oracle2 user

     Login as root and edit the file ( vi /etc/sudoers) and add the below entries
     ```
     <copy>
     zdmuser    ALL=(ALL)       NOPASSWD: ALL
     oracle2    ALL=(ALL)       NOPASSWD: ALL

     </copy>
     ```



## Task 2: List of Tablespaces and their mapping with ADB-S

Since there are restrictions in creating the tablespaces on ADB-S, the process would be to list down all the tablespaces including temporary tablespace and do a re-map to map them on the target ADB-S database.Run on the source database system

1. The following SQL commands will provide the list of Permanent Tablespaces needed to map with ‘DATA’ Tablespace:

     ```
     <copy>set heading off;
     set echo off;
     set pages 999;
     set linesize 400;
     set long 90000;
     spool permanent_tablespace.txt;
     SELECT 'DATAPUMPSETTINGS_METADATAREMAPS-1=type:REMAP_TABLESPACE,oldValue:' || TABLESPACE_NAME ||
     ',newValue:DATA' FROM USER_TABLESPACES WHERE TABLESPACE_NAME not in ('SYSTEM','SYSAUX') and CONTENTS not in ('UNDO', 'TEMPORARY');
     spool off; </copy>
      ```
    


2. The following SQL commands will provide the list of Temporary Tablespaces needed to map with ‘TEMP’ Tablespace:

     ```
     <copy>set heading off;
     set echo off;
     set pages 999;
     set linesize 400;
     set long 90000;
     spool temporary_tablespace.txt;
     SELECT 'DATAPUMPSETTINGS_METADATAREMAPS-1=type:REMAP_TABLESPACE,oldValue:' || TABLESPACE_NAME ||
     ',newValue:TEMP' FROM USER_TABLESPACES WHERE CONTENTS in ('TEMPORARY');
     spool off; </copy>
      ```



       

You may now **proceed to the next lab.**


## Acknowledgements
* **Authors** - Deepak Kumar M, Principal Cloud Architect
* **Contributors** - Deepak Kumar M, Principal Cloud Architect
* **Last Updated By/Date** - Deepak Kumar M, Principal Cloud Architect, December 2023

