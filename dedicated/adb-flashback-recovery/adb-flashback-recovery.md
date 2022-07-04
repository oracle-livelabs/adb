# Recover from user errors using flashback recovery

## Introduction
The Oracle Autonomous Database service comes pre-configured with a set of features collectively known as Flashback Technology that supports viewing past states of data, and winding and rewinding data back and forth in time, without requiring the restore of the database from backup. Depending on the changes to your database, Flashback Technology can often reverse the unwanted changes more quickly and with less impact on database availability.

Estimated Time: 20 minutes

### Objectives
As an administrator,
1. Learn how to set up recovery points in database change scripts.
2. Learn to recover from user errors such as unwanted commits and table drops.

### Required Artifacts
- An Oracle Cloud Infrastructure account.
- A pre-provisioned instance of Oracle Developer Client image in an application subnet. Refer to the earlier lab, **Configuring a Development System**.
- A pre-provisioned Autonomous Transaction Processing instance. Refer to the earlier lab, **Provisioning Databases**.

## Task 1: Log in to the Oracle Cloud Developer image and invoke SQL Developer
- To connect to your Oracle Cloud Developer image please refer to the earlier lab, **Configuring a Development System**. If  you are already connected from the previous lab skip to *Task 2*.  

    *The remainder of this lab assumes you are connected to the image through VNC Viewer and are operating from the image itself and not your local machine (except if noted).*

- Connect to your developer client machine over VNC and invoke SQL Developer. Refer to the earlier lab, **Configuring a Development System** for detailed instructions.

- Next, open a connection to your dedicated autonomous database instance. Once again, refer to the earlier lab, **Configuring a Development System** if you do not know how to do that. Alternatively, you may also use SQLcl or SQL*Plus clients for this lab, but screenshots here are based on SQL Developer.

## Task 2: Recover from erroneous transactions
Let's first see how to recover from an accidental data loss.

- In SQL Developer worksheet, let's first make sure the database is in ARCHIVELOG mode. An autonomous database is always created in ARCHIVELOG mode.

    ````
    <copy>
    select log_mode from v$database;
    </copy>
    ````

    ![This image shows the result of performing the above step.](./images/log_mode.png " ")

    The Query result should indicate the database is in ARCHIVELOG mode.

- Next, let's create a sample table, then insert and commit a row using the following script:

    ````
    <copy>
    create table items(itemid NUMBER(5), qty Number(2), price Number(6,2));
    insert into items values(1, 2, 10);
    commit;
    </copy>
    ````

- Before you can use Flashback Table, you must ensure that row movement is enabled on the table to be flashed back, or returned to a previous state. Row movement indicates that rowids will change after the flashback occurs.

    ````
    <copy>
    Alter table items enable row movement;
    </copy>
    ````

- Now let's insert and commit a row in the items table.

    ````
    <copy>
    insert into items values(1, 2, 10);
    commit;
    </copy>
    ````

- Let's assume a database change requires certain DML operations. As a best practice, you create a restore point at the start of the change.

    ````
    <copy>
    create restore point BEFORE_DML;
    </copy>
    ````

- Confirm your restore point was created.

    ````
    <copy>
    select * from v$restore_point;
    </copy>
    ````

    ![This image shows the result of performing the above step.](./images/restore_point2.png " ")

- Next, execute and commit this delete statement.

    ````
    <copy>
    delete from items;
    commit;
    </copy>
    ````

- The data in table items is all gone. Now let's flashback the table to the restore point to recover the data.

    ````
    <copy>
    flashback table items to restore point BEFORE_DML;
    </copy>
    ````

    ![This image shows the result of performing the above step.](./images/flashback.png " ")

- And we are back in the game!

- Of Course, you can always run a check on the items table with:

    ````
    <copy>
    select count(*) from items;
    </copy>
    ````

You may now **proceed to the next lab**.

## Acknowledgements
*Congratulations! You successfully learned to recover from user errors using Oracle flashback.*

- **Author** - Tejus Subrahmanya & Kris Bhanushali
- **Adapted by** -  Yaisah Granillo, Cloud Solution Engineer
- **Last Updated By/Date** - Kris Bhanushali, Autonomous Database Product Management, March 2022

## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
