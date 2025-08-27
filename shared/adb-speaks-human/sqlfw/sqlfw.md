# Create and enforce a SQL Firewall policy in Data Safe

## Introduction

In this lab, you create and enforce a SQL Firewall policy for the `APP_USER` database user. **Oracle SQL Firewall** is a robust security feature built into the Oracle Database 23ai, designed to provide real-time protection against common database attacks by restricting access to only authorized SQL statements or connections.

You begin by using Data Safe and Database Actions to create a collection of allowed SQL statements for `APP_USER`. This collection is referred to as the *allow-list*. Next, you test that `APP_USER` cannot run any other statement on the target database.  Lastly, you add a SQL statement from the violation log to the allow-list.

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:

- Grant the SQL Firewall role on your target database
- Enable SQL Firewall in Data Safe
- Create a SQL collection for `APP_USER`
- Deploy the SQL Firewall policy for `APP_USER`
- Test the SQL Firewall policy
- Add a SQL statement from the violation log to the allow-list


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`
- Prepared your environment
- A target database that is Oracle Database 23ai

## Task 1: Grant the SQL Firewall role on your target database

Perform this task only if you are working in your own tenancy. If you are using a LiveLabs sandbox, you do not need to perform this task.

1. Return to the SQL worksheet in Database Actions. If you are prompted to sign in to your target database, sign in as the `ADMIN` user. Clear the worksheet and the **Script Output** tab using the **Clear** icons.

2. On the SQL worksheet, enter the following command to grant the SQL Firewall role to the Oracle Data Safe service account on your target database. Next, click the **Run Script** icon in the toolbar to execute the command.

    ```
    <copy>
    EXECUTE DS_TARGET_UTIL.GRANT_ROLE('DS$SQL_FIREWALL_ROLE');
    </copy>
    ```

    ![Click Run Script](images/click-run-script.png " ")

3. Verify that the script output shows the following message:

    `PL/SQL procedure successfully completed.`
    
    You are now able to use the SQL Firewall feature with your target database.

4. Clear the worksheet and script output sections. Click the **Clear** icons.  

5. Return to the **Data Safe | Oracle Cloud Infrastructure** browser tab.

## Task 2: Enable SQL Firewall in Data Safe

1. Make sure you are on the **Data Safe | Oracle Cloud Infrastructure** browser tab.

    ![Data Safe browser](images/data-safe-browser.png " ")

2. In the **Security center** section in Data Safe, click **SQL Firewall**.

3. In the **List Scope** section, select your assigned compartment.

    ![Click SQL Firewall](images/click-sql-firewall.png " ")

4. On the **Target summary** tab, click the name of your target database. The SQL Firewall status should currently show as **Disabled**.

5. Click **Refresh**, and then click **Enable**.

    ![Click Refresh and Enable](images/click-refresh-enable.png " ")

6. Wait for the status to change to **ACTIVE**.

    ![Status Active](images/status-active.png " ")

## Task 3: Create a SQL collection for APP_USER

1. In the **SQL collections** section, click **Create and start SQL collection**. The **Create and start SQL collection** dialog box is displayed.

2. From the **Database user** drop-down list, select **`APP_USER`**.

    If `APP_USER` is not listed in the **Database user** drop-down list, click the **Refresh** icon, and then select the user.

3. Leave **User issued SQL commands** selected.

4. Click **Create and start SQL collection**.

   ![Create and start SQL collection dialog box](images/create-start-sql-collection.png " ")

5. Wait for the status to change to **COLLECTING**.

    SQL Firewall is now set to capture SQL statements issued by the `APP_USER` database user.

6. From the navigation menu, select **Oracle Database**, and then **Autonomous Database**.

7. Click the name of your database.

8. On the **Autonomous Database details** page, from the **Database actions** menu, select **Database Users**.

9. On the **`APP_USER`** tile, click the three dots, and select **Edit**.

10. In the **Password** and **Confirm Password** boxes, enter a database password for `APP_USER`.

    Note: The password must be 12 to 30 characters and contain at least one uppercase letter, one lowercase letter, and one number. It cannot contain the double quote (") character or the username "admin".

11. At the bottom, enable **Web Access**.

   ![Enable web access](images/enable-web-access.png "Enable web access")

12. Click **Apply Changes**.

13. Click the three dots again, and select **Enable REST**.

14. To the right of the URL in the `APP_USER` tile, click the **Open in new tab** icon.

    The sign-in page for Database Actions is opened in a new tab.

15. Sign in as `APP_USER` and enter the password.

16. Click the **SQL** tab.

17. Close any tip dialog boxes.

18. Copy and paste the following query in the SQL Worksheet, and then click the **Run Statement** icon on the toolbar.

    ```sql
    <copy>
    SELECT FIRST_NAME, LAST_NAME, EMPLOYEE_ID 
    FROM HCM1.EMPLOYEES;
    </copy>
    ```

19. Copy and paste the following query in the SQL Worksheet, and then click the **Run Statement** icon on the toolbar.

    ```sql
    <copy>
    SELECT LOCATION_ID, STREET_ADDRESS, CITY 
    FROM HCM1.LOCATIONS 
    ORDER BY LOCATION_ID;
    </copy>
    ```

20. Copy and paste the following query in the SQL Worksheet, and then click the **Run Statement** icon on the toolbar.

    ```sql
    <copy>
    SELECT LOCATION_ID, CITY 
    FROM HCM1.LOCATIONS 
    WHERE LOCATION_ID='1000';
    </copy>
    ```

21. Return to the **Autonomous Database | Oracle Cloud Infrastructure** tab.

22. From the navigation menu, select **Oracle Database**, and then **SQL Firewall** under **Data Safe - Database Security**.

23. Click the name of your target database.

24. Click the SQL collection for `APP_USER`. 

25. To stop the SQL workload capture of allowed SQL statements, click **Stop**, and wait for the status to change to **COMPLETED**.

    The SQL collection is created for `APP_USER`.

## Task 4: Deploy the SQL Firewall policy for APP_USER

1. On the **SQL collection details** page, click **Generate firewall policy**.

    A firewall policy is created, but not yet enabled (deployed). Notice the status of the policy is set to **Disabled**.
    
2. Scroll down and review the collection of SQL statements on the allow-list. 

    Note: Database Actions adds additional SQL statements to the allow-list automatically. The SQL statements that you just collected also have additional code inserted, which you can ignore.

3. To deploy the SQL Firewall policy for the `APP_USER` user, click **Deploy and enforce**.

    The **Deploy SQL Firewall policy** dialog box is displayed.

4. Select the following options:

    - Enforcement scope: **SQL statements only**
    - Action on violations: **Block and log violations**
    - Audit for violations: **Off**. Note: If you select **On**, the audit trail for your target database must be started.

    *Be sure to select these options carefully!*
    
5. Click **Deploy and enforce**.

   ![Deploy SQL Firewall policy dialog box](images/deploy-sql-firewall-policy.png "Deploy SQL Firewall policy dialog box")

6. Notice that the status of the SQL Firewall policy changes to **Enabled**. 

   ![Unique allowed SQL statements](images/enabled-policy.png "Unique allowed SQL statements")

7. To filter the allow-list, under **Unique allowed SQL statements**, click **+ Add filter**, set **SQL text Like HCM1**, and click **Apply**.

    The SQL statements that you collected earlier are listed.

   ![Filtered SQL statements](images/filtered-sql-statements.png "Filtered SQL statements")

## Task 5: Test the SQL Firewall policy

When you run the SQL statements in this task, use the **Run Statement** button in Database Actions because that is how you previously ran the queries when you created the SQL collection. If you use the **Run Script** button instead, SQL Firewall will block the results.

1. Return to Database Actions as `APP_USER` and clear the worksheet.

2. Try running one of the SQL statements on the allow-list such as the following query:

    ```sql
    <copy>
    SELECT FIRST_NAME, LAST_NAME, EMPLOYEE_ID 
    FROM HCM1.EMPLOYEES;
    </copy>
    ```
 
    The query should return data.

3. Clear the worksheet and try running a SQL statement that isn't on the allow-list such as the following query: 

    ```sql
    <copy>
    SELECT * 
    FROM HCM1.EMPLOYEES;
    </copy>
    ```

    You should receive an error message: **`ORA-47605: SQL Firewall violation`**.

4. Clear the worksheet and try running a SQL statement that is on the allow-list with a modified `WHERE` clause such as the following query:

    ```sql
    <copy>
    SELECT LOCATION_ID, CITY 
    FROM HCM1.LOCATIONS 
    WHERE LOCATION_ID='1300';
    </copy>
    ```
    The query should return data. 

5. Clear the worksheet and try running the SQL statement on the allow-list with its columns in a different order such as the following query:

    ```sql
    <copy>SELECT LAST_NAME, FIRST_NAME, EMPLOYEE_ID 
    FROM HCM1.EMPLOYEES;
    </copy>
    ```
    You should receive an error message: **`ORA-47605: SQL Firewall violation`**.

## Task 6: Add a SQL statement from the violation log to the allow-list
    
1. Return to the **SQL Firewall | Oracle Cloud Infrastructure** tab. You may need to wait a couple of minutes for the violations to show up.

2. Under **Unique allowed SQL statements**, click **Add from violations**.

    The **Add from violations** page is displayed showing you Autonomous Database SQL queries.

    ![Add from violations page](images/two-violations.png "Add from violations page")

3. Expand the violations and review.

4. Select the check box for the second SQL violation: `SELECT * FROM HCM1.EMPLOYEES`.

5. Click **Add violations**. 

    You are returned to the **Firewall policy details** page.

6. Under **Unique allowed SQL statements**, notice that your selected SQL statement is now listed at the top.

    ![Add from violations page](images/new-allowed-sql-statement.png "Add from violations page")

7. Return to **Database Actions** as `APP_USER` and run the newly-allowed SQL statement to test that it will run successfully.

    ```sql
    <copy>
    SELECT * 
    FROM HCM1.EMPLOYEES;
    </copy>
    ```
    The query should retrieve data.

Congratulations! You have finished this LiveLabs workshop!

## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Contributor:** Lauran K. Serhal, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date:** - Lauran K. Serhal, August 2025


