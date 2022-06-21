# Validate the Table

## Introduction

Confirm that the chosen table is a viable candidate for auto partitioning.

Estimated Time: 25mins

### Objectives
- *Validate* a candidate table to check it is suitable for auto partitioning.

### Prerequisites
This lab assumes you have completed the following labs:

- Provision an ADB Instance (19c)
- Create Non-partitioned Table

## Task 1: Validate your newly created nonpartitioned Table as Candidate for Auto Partitioning  

Valid candidate tables for auto partitioning must satisfy certain criteria. We already discussed that candidate tables must have a mimumum size for being eligible. Let's see whether this is sufficient. 

1. Check to see if auto partitioning considers our newly created nonpartitioned table a viable candidate for a partitioning recommendation:

    ````
    <copy>
     set serveroutput on
    
     declare
     ret varchar2(1000);
     begin
         ret := dbms_auto_partition.validate_candidate_table (table_owner=>user,table_name=>'APART');
         dbms_output.put_line(' ');
         dbms_output.put_line(' ');
         dbms_output.put_line('Auto partitioning validation: ' || ret);
     end;
     /
    </copy>
    ````

    Just having a sufficiently large enough nonpartitioned table is obviously not enough. Auto partitioning needs a workload to test against the candidate table. Currently the workload does not exist, so this message is returned:

    `````
    Auto partitioning validation: INVALID: table is referenced by 0 full table scan queries in the SQL tuning set; 5 queries required
    `````
    
## Task 2: Generate a representative Sample Workload - Execute Test Queries

Partitioning improves the performance for your application. Our newly created table was never used yet as part of an application workload. For the purpose of this lab we will emulate your application by running a set of representative sample queries against our newly created table.

1. Generate a workload by executing a series of queries that scan the APART table. Later, auto partitioning retrieve this workload and test exceute it to measure the effect of partitioning the table.

    ````
    <copy>
     select /* TEST_QUERY */ sum(a) from apart 
     where d between to_date('01-MAR-2020') and to_date('05-mar-2020');
     select /* TEST_QUERY */ sum(a) from apart 
     where d = to_date('01-MAR-2020');
     select /* TEST_QUERY */ sum(b) from apart 
     where d between to_date('01-JAN-2020') and to_date('05-JAN-2020');
     select /* TEST_QUERY */ sum(c) from apart 
     where d between to_date('01-APR-2020') and to_date('05-APR-2020');
     select /* TEST_QUERY */ sum(a) from apart 
     where d between to_date('01-JUN-2020') and to_date('02-JUN-2020');
     select /* TEST_QUERY */ sum(b) from apart 
     where d between to_date('01-DEC-2020') and to_date('31-DEC-2020');
     select /* TEST_QUERY */ sum(a) from apart 
     where d between to_date('01-AUG-2020') and to_date('31-AUG-2020');
     select /* TEST_QUERY */ sum(b) from apart 
     where d between to_date('01-OCT-2020') and to_date('01-OCT-2020');
     select /* TEST_QUERY */ sum(c) from apart 
     where d between to_date('01-FEB-2020') and to_date('05-FEB-2020');
     select /* TEST_QUERY */ sum(a) from apart 
     where d between to_date('01-MAY-2020') and to_date('02-MAY-2020');
     select /* TEST_QUERY */ avg(a) from apart 
     where d between to_date('01-JUL-2020') and to_date('02-JUL-2020');
    </copy>
    ````

## Task 3: Wait for Oracle Autonomous Database to automatically collect your Application Workload

Oracle Autonomous Database automatically collects your workload information periodically every 15 minutes. The Auto STS Capture Task is responsible for capturing the workload SQL in a SQL tuning set called SYS\_AUTO\_STS. This is the _automatic SQL tuning set_ or ASTS that is maintained automatically in Autonomous Database environments. 

1. Use the following query to monitor the last schedule time and wait until the task has executed again - i.e. _after_ the workload queries were executed.

    ````
    <copy>
     select current_timestamp now from dual;
     
     select task_name,
            status,
            enabled,
            interval,
            last_schedule_time, 
            systimestamp-last_schedule_time ago 
     from dba_autotask_schedule_control 
     where dbid = sys_context('userenv','con_dbid') 
     and   task_name like '%STS%';
    </copy>
    ````

2. Keep running the query, monitior the LAST\_SCHEDULE\_TIME, and wait for it to change. Alternatively, look at the "AGO" column value and wait for it to show that the task ran a few seconds ago. The interval is 900 seconds by default, so you will need to wait for up to 15 minutes.

    `````
    NOW
    ------------------------------------------
    07-DEC-21 13.37.15.285689000 EUROPE/LONDON

    TASK_NAME                                                        STATUS     ENABL   INTERVAL LAST_SCHEDULE_TIME               AGO                
    ---------------------------------------------------------------- ---------- ----- ---------- -------------------------------- -------------------
    Auto STS Capture Task                                            SUCCEEDED  TRUE         900 07-DEC-21 13.23.14.891000000 GMT +00 00:14:00.492985

    `````

3. Ater a maximum of 15 minutes after generating your workload the Autonomous Database has collected this workload. Confirm that the workload queries have been captured in the automatic SQL tuning set.

    ````
    <copy>
     select sql_text 
     from   dba_sqlset_statements 
     where  sql_text like '%TEST_QUERY%'
     and    sqlset_name = 'SYS_AUTO_STS';
    </copy>
    ````

    `````
    SQL_TEXT                                                                                                                                              
    ---------------------------------------------------
    select /* TEST_QUERY */ sum(b) from apart where d between to_date('01-OCT-2020'                                                                      
    select /* TEST_QUERY */ sum(a) from apart where d = to_date('01-MAR-2020')                                                                           
    select /* TEST_QUERY */ sum(b) from apart where d between to_date('01-JAN-2020'                                                                      
    select /* TEST_QUERY */ avg(a) from apart where d between to_date('01-JUL-2020'   
    ...etc
    `````

## Task 4: Validate your newly created nonpartitioned Table as Candidate again

1. Now that the workload has been captured in the automatic SQL tuning set, validate again:

    ````
    <copy>
     set serveroutput on
     
     declare
     ret varchar2(1000);
     begin
         ret := dbms_auto_partition.validate_candidate_table (table_owner=>user,table_name=>'APART');
         dbms_output.put_line(' ');
         dbms_output.put_line(' ');
         dbms_output.put_line('Auto partitioning validation: ' || ret);
     end;
     /
    </copy>
    ````

    When the following message is returned, we are ready to run the auto partitioning _recommend_ step:

    `````
    Auto partitioning validation: VALID
    ````` 
   
You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Nigel Bayliss, Dec 2021 
* **Last Updated By/Date** - Nigel Bayliss, Dec 2021
