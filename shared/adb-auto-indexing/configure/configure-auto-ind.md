# Configuring and Controlling Automatic Indexing

## Introduction

Automatic indexing is designed to require minimal configuration, but some settings that are useful to know.

Estimated Time: 10mins

### Objectives
- Understand how to configure automatic indexing.

### Prerequisites
This lab assumes you have completed the following lab:

- Provision an Autonomous Database Instance
- Create an Application Schema and Prepare for Auto Indexing
- Execute an Application Workload
- View the Auto Index Report
- View Auto Index Details

## Task 1: Specify Schemas for Automatic Indexing

1. Schemas can be added to an inclusion or exclustion list by setting ALLOW to TRUE or FALSE. Schema names are specified using _parameter\_value_ and NULL means 'all'.
	
	```
    <copy>
    begin
        dbms_auto_index.configure(
            parameter_name  => 'AUTO_INDEX_SCHEMA', 
            parameter_value => 'ADMIN',
            allow           => FALSE);
    end;
    /
    </copy>
	```

2. Inspect the current parameter settings.

    ```
    <copy>
    column parameter_name format a40
    column parameter_value format a40
    SELECT parameter_name, 
           parameter_value 
    FROM   dba_auto_index_config 
    ORDER BY 1, 2;
    </copy>
    ```

3. The easiest way to understand the inclusion and exclusion logic is to experiment with some combinations and inspect the AUTO\_INDEX\_SCHEMA parameter value. For example, in the example below, you will simply see _schema NOT IN (ADMIN)_.

	```
    <copy>
    begin
        dbms_auto_index.configure(
            parameter_name  => 'AUTO_INDEX_SCHEMA', 
            parameter_value => NULL,
            allow           => TRUE);

        dbms_auto_index.configure(
            parameter_name  => 'AUTO_INDEX_SCHEMA', 
            parameter_value => 'ADMIN',
            allow           => FALSE);
    end;
    /
    </copy>
	```

    ```
    <copy>
    column parameter_name format a40
    column parameter_value format a40
    SELECT parameter_name, 
           parameter_value 
    FROM   dba_auto_index_config 
    WHERE  parameter_name = 'AUTO_INDEX_SCHEMA'
    ORDER BY 1, 2;
    </copy>
    ```

4. Clear the inclusion and exclusion lists.

	```
    <copy>
    begin
        dbms_auto_index.configure(
            parameter_name  => 'AUTO_INDEX_SCHEMA', 
            parameter_value => NULL,
            allow           => NULL);
    end;
    /
    </copy>
	```

5. Confirm that all rules have been cleared (the AUTO_INDEX_SCHEMA parameter value should be NULL).

    ```
    <copy>
    column parameter_name format a40
    column parameter_value format a40
    SELECT parameter_name, 
           parameter_value 
    FROM   dba_auto_index_config 
    WHERE  parameter_name = 'AUTO_INDEX_SCHEMA'
    ORDER BY 1, 2;
    </copy>
    ```

## Task 2: Drop Automatic Indexes

1. Use the following query and choose an index to drop.
	
    ````
    <copy>
    set linesize 250 trims on
    column column_name format a20
    column table_name format a25
    column table_owner format a30
    column index_name format a30

    break on index_name
    SELECT c.index_name,c.table_name,c.column_name,c.column_position, i.visibility, i.status
    FROM   user_ind_columns c , user_indexes i
    WHERE  c.index_name = i.index_name
    AND    i.auto = 'YES'
    ORDER BY c.table_name,c.index_name,c.column_position;
    </copy>
    ````

2.  You can drop individual or multiple auto indexes using the DBMS\_AUTO\_INDEX API. You cannot use the DROP INDEX DDL command. Drop the index, and prevent it from being created again (FALSE in parameter three prevents the index from being recreated).

	```
	<copy>
	exec dbms_auto_index.drop_auto_indexes(user,'"<indexname>"',false)
	</copy>
	```

	```
    -- For example...
    -- You will need to change the index name to match those created in your database)
    --
	exec dbms_auto_index.drop_auto_indexes(user,'"SYS_AI_gdu3958w4jtrf"',false)

    -- You can change your mind and allow the index to be 
    -- recreated later on (even if you have already dropped the index)
    --
	exec dbms_auto_index.drop_auto_indexes(user,'"SYS_AI_gdu3958w4jtrf"',true)
	```

2. To complete this lab, drop all remaining auto indexes. If you set _allow\_recreate_ to TRUE (the third parameter), this will allow the same column indexes to be created again if the workload benefits. You will need to do this if you want to run the lab again. If you use FALSE now, you can change your mind and use TRUE later on.

	```
	<copy>
	exec dbms_auto_index.drop_auto_indexes(user,null,true)
	</copy>
	```

## Task 3: Turn On DML Awareness

1. If you are using Oracle Database 23ai, return the DML cost setting to its default value.

	```
	<copy>
	-- If using Oracle Database 23ai only - not required for Oracle Database 19c
	exec dbms_auto_index.configure('auto_index_include_dml_cost', 'ON')
	</copy>
	```

## Task 4: Disable Automatic Indexing

1. Disable automatic indexing.
	
	```
	<copy>
	exec dbms_auto_index.configure('AUTO_INDEX_MODE', 'OFF')
	</copy>
	```    	

## Acknowledgements
* **Author** - Nigel Bayliss, Jul 2022
* **Last Updated By/Date** - Nigel Bayliss, Jan 2025
