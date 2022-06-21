# Getting Tablespace information from On-premise PeopleSoft database

## Introduction

This lab walks you through the steps to get the list of Oracle Tablespaces created on the on-premise PeopleSoft application and to map it with the DATA  and TEMP tablespace on ADB-S


Estimated Time: 5 minutes

### Objectives
In this lab, you will:
* Gather tablespaces from on-premise PeopleSoft system and map them to ADB-S


## Task 1: List of Tablespaces and their mapping with ADB-S

Since there are restrictions in creating the tablespaces on ADB-S, the process would be to list down all the tablespaces including temporary tablespace and do a re-map to map them on the target ADB-S database.

1. The following SQL commands will provide the list of Permanent Tablespaces needed to map with ‘DATA’ Tablespace:

     ```
     <copy>set heading off;
     set echo off;
     set pages 999;
     set long 90000;
     spool permanent_tablespace.txt;
     select TABLESPACE_NAME||':DATA' From DBA_TABLESPACES Where TABLESPACE_NAME NOT IN ('SYSTEM','SYSAUX','UNDO','UNDO_1') And CONTENTS <> 'TEMPORARY';
     spool off; </copy>
      ```
    
    ![](./images/table1.png "")

2. The following SQL commands will provide the list of Temporary Tablespaces needed to map with ‘TEMP’ Tablespace:

     ```
     <copy>set heading off;
     set echo off;
     set pages 999;
     set long 90000;
     spool temporary_tablespace.txt;
     select TABLESPACE_NAME||'TEMP' From DBA_TABLESPACES Where TABLESPACE_NAME NOT IN ('SYSTEM','SYSAUX','UNDO','UNDO_1') And CONTENTS = 'TEMPORARY';
     spool off; </copy>
      ```

    ![](./images/table2.png "")

## Task 2: Sorting the list and mapping to DATA and TEMP for MV2ADB configuration


Using notepad or notepad++, do map each of all the list of existing tablespaces from source database to DATA and for temporary tablespace to TEMP to match the target ADB-S database. These commands would be used in the mv2adb configuration file.

*  Sample sorted list mapped to DATA & TEMP:

         
     <copy>TLLARGE:DATA,TLWORK:DATA,WAAPP:DATA,PSGTT01:TEMP,PSTEMP:TEMP</copy>
       

You may now **proceed to the next lab.**


## Acknowledgements
* **Authors** - Deepak Kumar M, PeopleSoft Architect
* **Contributors** - Deepak Kumar M, PeopleSoft Architect
* **Last Updated By/Date** - Deepak Kumar M, PeopleSoft Architect, Aug 2021