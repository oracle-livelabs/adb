# Apply the Recommendation

## Introduction

Use automatic indexing to implement the recommended partitioning scheme.

Estimated Time: 10mins

### Objectives
- Accept the partitioning recommendation and create the partitioned table.

### Prerequisites
This lab assumes you have completed the following labs:

- Provision an ADB instance (19c)
- Create non-partitioned table
- Validate the table
- Execute recommend task
- View recommendation

## Task 1: Apply the Recommendation to Implement Partitioning

In the previous lab, the PL/SQL procedure displayed a recommendation ID similar to this example:

`````
=============================================
ID:     D28FC3CF09DF1E1DE053D010000AF8F8
Method: LIST(SYS_OP_INTERVAL_HIGH_BOUND("D", INTERVAL '2' MONTH, TIMESTAMP '2020-01-01 00:00:00')) AUTOMATIC 
Key   : D
=============================================
`````

The "ID" is a *recommendation ID*, and is used to identify which recommendation you want to apply. It is displayed at the top of the recommendation report too.

1. Execute the following command to initiate the partitioned table build, using your recomendation ID:

    ````
    <copy>
       exec dbms_auto_partition.apply_recommendation('<your recommendation ID>');
    </copy>
    ````
    For example:

    ````
    exec dbms_auto_partition.apply_recommendation('D28FC3CF09DF1E1DE053D010000AF8F8');
    ````


A partitioned version of the table will be build on-line using an ALTER TABLE MODIFY PARTITION ONLINE command. Your original table will not be impacted or locked throughout this process. It will take approximately 10 minutes for a 5GB table in a 19c instance.

## Task 2: Confirm That Table is Partitioned

After the successful modification to a partitioned table your old nonpartitioned table is no longer existent. You can verify the successful modification by querying the data dictionary.

1. Check that APART is now a partitioned table:

    ````
    <copy>
    set trims on
    set linesize 300
    column partition_name format a20
    column segment_name format a15
    
    select segment_name,
           partition_name,
           segment_type,
           bytes/(1024*1024) mb
    from   user_segments
    order by partition_name;
    </copy>
    ````
    The output will look similar than the following one:

    `````
    SEGMENT_NAME  PARTITION_NAME       SEGMENT_TYPE               MB
    ------------- -------------------- ------------------ ----------
    APART         P_NULL               TABLE PARTITION         .0625
    APART         SYS_P1576            TABLE PARTITION           936
    APART         SYS_P1577            TABLE PARTITION           952
    APART         SYS_P1578            TABLE PARTITION           952
    APART         SYS_P1579            TABLE PARTITION           968
    APART         SYS_P1580            TABLE PARTITION           952
    APART         SYS_P1581            TABLE PARTITION           816
    `````

In our case, the table has a total of seven partitions, each approximately 9MB in size except for a partition intended to receive NULL partition keys. The partition sizes vary because compression factors are very sensitive to data content and data ordering.

Without manual human analysis of your workload and schema, auto partitioning has identified the optimal partitioning scheme for your schema and application, transparently improving the performance without your intervention. The larger your candidate table, the bigger performance benefits you will experience with your application.    

This concludes the workshop.

## Acknowledgements
* **Author** - Nigel Bayliss, Dec 2021 
* **Last Updated By/Date** - Nigel Bayliss, Dec 2021
