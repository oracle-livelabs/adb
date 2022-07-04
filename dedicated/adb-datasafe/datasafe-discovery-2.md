# Verify a Sensitive Data Model with Oracle Data Safe
## Introduction
Using Oracle Data Safe, verify a sensitive data model by using the verification option in the Library and by using the Data Discovery wizard.

Estimated Time: 30 minutes

### Objectives
In this lab, you learn how to do the following:
- Verify a sensitive data model by using the verification option in the Library
- Verify a sensitive data model by using the Data Discovery wizard
- Manually update a sensitive data model stored in the Library

### Challenge
1. Connect to your Autonomous Database as **ADMIN** user with SQL Developer.
2. In SQL Developer, add a column to one of the tables in your target database. For example, add an `AGE` column to the `HCM1.EMPLOYEES` table. Gather schema statistics on your database.
3. Sign in to the Oracle Data Safe Console in your region.
4. In Oracle Data Safe, verify your sensitive data model (**username SDM1**) against your target database by using the verification option on the **Sensitive Data Models** page in the Library. What does the verification test find?
5. If needed, manually add the column to your sensitive data model.
6. In SQL Developer, drop the column from the database.
7. In Oracle Data Safe, run the verification test again against your database, but this time use the Data Discovery wizard. Observe the verification findings. Do you need to do anything to your sensitive data model?
8. If needed, manually update your sensitive data model from the Library so that it accurately reflects your target database.

## Task 1: Connect to ATP-D DB using SQL Developer Web

- Refer to Task 5 from the earlier lab in this workshop, **Assess Users with Oracle Data Safe**.

- Next, in SQL Developer, add a column to the `EMPLOYEES` table in your database.

- On the SQL Worksheet, run the following command to add an `AGE` column to the `EMPLOYEES` table.

    ```
    <copy>ALTER TABLE HCM1.EMPLOYEES ADD AGE NUMBER;</copy>
    ```

- Click the **Refresh** button to view the newly added column.
- Run the following command to gather schema statistics.

    ```
    <copy>EXEC DBMS_STATS.GATHER_SCHEMA_STATS('HCM1');</copy>
    ```

- Keep this tab open because you return to it in a later task.

## Task 2: Verify your sensitive data model

Sign in to Oracle Data Safe with your OCI credentials.

Refer to the earlier lab in this workshop, **Register a Target Database**.

In this task, verify your sensitive data model against your database by using the verification option on the **Sensitive Data Models page**.

- In the Oracle Data Safe Console, click the **Library** tab, and then click **Sensitive Data Models**.

    ![This image shows the result of performing the above step.](./images/img41.png " ")

- Select the check box for your sensitive data model that you created in the earlier lab in this workshop, **Discover Sensitive Data with Oracle Data Safe**.
- Click **Verify Against Target**.

    ![This image shows the result of performing the above step.](./images/img43.png " ")

- On the **Select Target for Data Model Verification** page, select your target database, and click **Continue**. The verification job is started.

    ![This image shows the result of performing the above step.](./images/img44.png " ")

- When the job is finished, notice that the **Detail** column reads `Data model verification job finished successfully`.
- Click **Continue**.
- On the **Data Model Verification Result** page, notice that there are no differences to report. The verification job did not find the new sensitive column, AGE.

*Note: The verification feature checks whether the sensitive columns in the sensitive data model are present in the target database. If there are some present in the sensitive data model, but missing in the target database, it reports them. In addition, it reports new referential relationships for the columns already present in the sensitive data model. It does not, however, discover ALL the relationships.*

- Click **Continue**.

    ![This image shows the result of performing the above step.](./images/img45.png " ")

## Task 3: Change your sensitive data model

Manually add the AGE column to your sensitive data model.

- On the Sensitive Data Model: **SDM1** page, click **Add**. The **Add Sensitive Columns** dialog box is displayed.

    ![This image shows the result of performing the above step.](./images/img46.png " ")

- Scroll down to the **Schema Name**. Expand the `HCM1` schema, and then the `EMPLOYEES` table.

    ![This image shows the result of performing the above step.](./images/img47.png " ")

- Select the **AGE** column.

    ![This image shows the result of performing the above step.](./images/img48.png " ")

- At the top of the dialog box in the **Sensitive Type** field, enter **age**. `AGE` is automatically retrieved as a sensitive type and you can select it.

    ![This image shows the result of performing the above step.](./images/img49.png " ")

- Scroll to the bottom and click **Add to Result**. Your sensitive data model is updated to include the `AGE` column.
- To verify, enter age in the search box.

    ![This image shows the result of performing the above step.](./images/img50.png " ")

- Click **Save and Continue**.
- Click **Exit**.

## Task 4: Drop the AGE column in your database

- Return to SQL Developer Web.
- On the SQL Worksheet, run the following commands to drop the `HCM1.EMPLOYEES.AGE` column.

    ```
    <copy>ALTER TABLE HCM1.EMPLOYEES DROP COLUMN AGE;</copy>
    ```

- Run the following command to gather schema statistics.

    ```
    <copy>EXEC DBMS_STATS.GATHER_SCHEMA_STATS('HCM1');</copy>
    ```

- To verify that the `EMPLOYEES` table no longer has an `AGE` column, run the following script:

    ```
    <copy>SELECT AGE FROM HCM1.EMPLOYEES;</copy>
    ```

- Notice that the `AGE` column is gone and you receive an "Invalid Identifier" message when you run the command.
- If the AGE column is still there, click the **Refresh** button to refresh the table.

## Task 5: Verify your sensitive data model

Verify your sensitive data model against the database again, but this time using the Data Discovery wizard.

- Return to Oracle Data Safe.
- Click the **Home** tab, and then click **Data Discovery**.

    ![This image shows the result of performing the above step.](./images/img25.png " ")

- On the **Select Target for Sensitive Data Discovery** page, select your target database, and then click **Continue**.
- The **Select Sensitive Data Model** page is displayed.
- For **Sensitive Data Model**, select **Pick from Library**, and then click **Continue**. The **Select Sensitive Data Model** page is displayed.

    ![This image shows the result of performing the above step.](./images/img51.png " ")

- Select your sensitive data model, **SDM1**.
- Scroll down to the bottom of the page and select **Verify if SDM is compatible with the target**.

    ![This image shows the result of performing the above step.](./images/img52.png " ")

- To start the verification job, click **Continue**.
- If the job finishes successfully, click **Continue**. The **Data Model Verification Result** page is displayed.
- Expand **Missing sensitive columns**, and then `HCM1`. The Data Discovery wizard identifies the `AGE` column as missing from the database.

    ![This image shows the result of performing the above step.](./images/img53.png " ")

## Task 6: Update your sensitive data model from the Library

You can manually update your sensitive data model while continuing to work in the Data Discovery wizard. In this case, you simply deselect your sensitive column and save your sensitive data model. This part, however, shows you another way to do it from the Library.

- Click **Exit** to exit the Data Discovery wizard.
- Click the **Library** tab, and then click **Sensitive Data Models**.
- Click your sensitive data model to open it.
- Search for **AGE**.

    ![This image shows the result of performing the above step.](./images/img50.png " ")

- In the list of sensitive columns, deselect `HCM1.EMPLOYEES.AGE`.
- Your sensitive data model is now updated and accurate.
- Click **Save** then **Exit**.

You may now **proceed to the next lab**.

## Acknowledgements

*Great Work! You successfully completed the Data Safe Discovery Lab 2*

- **Author** - Jayshree Chatterjee
- **Last Updated By/Date** - Kris Bhanushali, Autonomous Database Product Management, March 2022


## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
