# Deploy a SQL Firewall policy in Data Safe

## Introduction

In this lab, you enable SQL Firewall in Data Safe and create a SQL collection by performing actions in the Glassfish application, which is connected to Oracle Database 23ai on host #2. After reviewing the workload capture, you create a SQL Firewall policy, and then deploy and enforce it. With SQL Firewall configured, you then perform actions in the Glassfish application to test SQL Firewall violations and block them.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Enable SQL Firewall in Data Safe
- Create a SQL Collection in Data Safe
- Set the Glassfish application on host #1 to use Oracle Database 23ai on host #2
- Perform activity in the Glassfish application on host #1
- Review the workload capture in Data Safe
- Create, deploy, and enforce a SQL Firewall policy in Data Safe
- Test SQL violations
- Test context violations
- Block SQL violations
- Test blocking mode


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`
- Prepared your environment
- Registered Oracle Database 23ai on a compute instance and granted the `SQL_Firewall` role to the Data Safe service account on Oracle Database 23ai.

Allow group <group-name> to manage data-safe-sql-firewall-family in compartment
        <compartment-name>

on database: EXECUTE DS_TARGET_UTIL.GRANT_ROLE('DS$SQL_FIREWALL_ROLE'); 


## Task 1: Enable SQL Firewall in Data Safe

1. Under **Security center** in Data Safe, click **SQL Firewall**.

2. Click the name of your target database, and then click **Enable**. Note - you may need to click Refresh if you just granted the role on the target database.

    The **Configuration details** page for your target database is displayed.

3. Notice at the top that you have "Required privileges are not granted on target ocid1.datasafetargetdatabase.oc1.iad.amaa..."

4. Click **Refresh**.

5. Click **Enable**.


## Task 2: Create a SQL Collection in Data Safe

1. Click **Create and start SQL collection**.

2. Select the **EMPLOYEESEARCH_PROD** database user.

3. Leave **User issued SQL commands** selected for the SQL collection level.

4. Click **Create and start SQL collection**.

5. Wait for status to change to **Collecting**.

    Now SQL Firewall is set to capture SQL statements issued by the `EMPLOYEESEARCH_PROD` database user in the Glassfish application.


## Task 3: Set the Glassfish application on host #1 to use Oracle Database 23ai on host #2

1. On the **Application information** tab, click the **Remote Desktop** link to access host #1 in a web browser. 

2. Open a terminal window on your desktop. By default, you are the OS user `oracle`.

3. Change to the scripts directory.

    ```text
    <copy>cd $DBSEC_LABS/sqlfw</copy>
    ```

4. Run the following script to configure the Glassfish application to connect to Oracle Database 23ai on host #2.

    ```text
    <copy>./sqlfw_glassfish_start_db23c.sh</copy>
    ```

5. In the Glassfish browser window on the right, click **Login**. Enter the username `hradmin` and the password `Oracle123`.

6. In the top right hand corner, click **Welcome HR Administrator**. 

    A page with session data shows you how the application is connected to the database. 

7. Scroll down and verify that **DB\_NAME** is set to **FREEPDB1** and **SERVER\_HOST** is set to **dbsec-lab**.



## Task 4: Perform activity in the Glassfish application on host #1

1. In the Glassfish application, click **Search Employees**.

2. Click **Search**.

3. Change criteria and search again. Repeat 2-3 times. (need to document the actions here. It's important to note the 3 things you did here because you do the exact same actions later on.)


## Task 5: Review the workload capture in Data Safe

1. Under **Security center**, click **SQL Firewall**.

2. Under **Related resources**, click **SQL collections**.

3. Click the database user **EMPLOYEESEARCH_PROD**.

    The **SQL collection details** page is displayed.

4. Click the **SQL collection insights** tab.

5. If needed, click **Refresh insights** button to refresh the page.

6. Review the SQL statements captured by SQL Firewall.


## Task 6: Create, deploy, and enforce a SQL Firewall policy in Data Safe

Generate and enable SQL Firewall policy with allow-list for HR Application user

1. Click **Stop** to stop the SQL workload capture.

    Your SQL workload capture, which consists of allowed SQL statements. Collectively, these statements are referred to as the allow-list.

2. Click **Generate firewall policy** to generate the SQL Firewall policy with the allow list.

    A firewall policy is created, but not yet enabled. The message at top of screen says:  Deploy and enforce the SQL Firewall policy to enable SQL Firewall protection for the user EMPLOYEESEARCH_PROD.

3. Scroll down and review the allow-list in the generated SQL Firewall policy.

    Notice that the generated policy remains inactive until you deployed it. You can generate a report of allowed SQL statements for offline review.

4. Click **Deploy and enforce** to deploy the SQL Firewall policy for the `EMPLOYEESEARCH_PROD` user.

    The **Deploy SQL Firewall policy** dialog box is displayed.

5. Select the following options:

    - Enforcement scope: **All (Session contexts and SQL statements)**
    - Action on violations: **Observe (Allow) and log violations**
    - Audit for violations: **Off**.
    
6. Click **Deploy and enforce**.

7. Notice that under **Enforcement information** on the **SQL Firewall policy information** tab, the status of the SQL Firewall policy changes to **Enabled**. 

## Task 7: Test SQL violations

SQL violations represent SQL statements that are initiated on the target database, but are not included in the allowlist in the SQL Firewall policy. In this task, you use SQL Firewall to detect an insider threat of stolen credential access.

1. Return to the Glassfish application on host #1. 

2. Sign in as `hradmin` with the password **Oracle123**.

3. Perform the same actions that you did previous in task 3.

    - Click **Search Employees**.
    - Click **Search**.
    - Set a filter on **Paris**. 
    - Set a filter on **First Name = Victor**.

4. Return to the **SQL Firewall** landing page in Data Safe. If you performed the exact same steps that you performed in task 3, there should not be any violations.

5. Return to the Glassfish application and perform an action that is not part of the SQL collection. For example, 

    - add an action here
    
6. Return to Data Safe and notice that a violation is generated.


## Task 8: Test context violations

Context violations represent session context (client IP address, OS program name, and OS username) from which SQL statements were initiated on the target database that are not included in the allowlist in the SQL Firewall policy. In this task, you use SQL Firewall to detect an insider threat that uses the SQL*Plus application, instead of the allowed Glassfish application, to gain access to the sensitive employee data.

1. Return to the terminal window on your remote desktop (host #1).

2. Change directories.

    ```text
    <copy>cd ~/DBSecLab/livelabs/sqlfw/</copy>
    ```

3. Run the following script that uses SQL*Plus to query sensitive columns in the `EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES` table.

    ```text
    <copy>./sqlfw_select_sensitive_data.sh</copy>
    ```

4. On the SQL Firewall landing page in Data Safe, review the charts. Notice that a context violation is raised because SQL*Plus is not in the allowed OS program allowlist.


## Task 9: Block SQL violations

1. Under **Related resources**, click **SQL Firewall policies**.

2. In the table, click the **EMPLOYEESEARCH_PROD** user.

3. Click **Deploy and enforce**.

    The **Deploy SQL Firewall policy** dialog box is displayed.

4. Select the following options:

    -Enforcement scope: **All (Session contexts and SQL statements)**
    -Action on violations: **Block and log violations**
    -Audit for violations: **On**

5. Click **Deploy and enforce**.

    By blocking violations, users can no longer access data if there is a SQL violation or a context violation. Also, SQL Firewall can now block SQL injection attempts!


## Task 10: Test blocking mode

In this task, you test a context violation and a SQL injection.

1. Return to the terminal window on host #2.

2. Rerun the following script.

    ```text
    <copy>./sqlfw_select_sensitive_data.sh</copy>
    ```

3. Review the output. You should get a SQL Firewall violation.

    ```text
    <copy>
    ==============================================================================
    Select sensitive employee data...
    ==============================================================================
    ERROR:
    ORA-47605: SQL Firewall violation


    ERROR:
    ORA-01017: invalid username/password; logon denied


    SP2-0306: Invalid option.
    Usage: CONN[ECT] [{logon|/|proxy} [AS {SYSDBA|SYSOPER|SYSASM|SYSBACKUP|SYSDG|SYSKM|SYSRAC}] [edition=value]]
    where <logon> ::= <username>[/<password>][@<connect_identifier>]
        <proxy> ::= <proxyuser>[<username>][/<password>][@<connect_identifier>]
    SP2-0157: unable to CONNECT to ORACLE after 3 attempts, exiting SQL*Plus
    </copy>
    ```

4. In the Glassfish application, search all employees again. 

    All rows are returned as normal because, remember, you are allowed to query everything in the application. Are you?!

5. Select the check box **Debug** to view the SQL query behind the form, and then click **Search**.

    The following SQL is returned:

    ```sql
    <copy>select a.USERID, a.FIRSTNAME, a.LASTNAME, a.EMAIL, a.PHONEMOBILE, a.PHONEFIX, a.PHONEFAX, a.EMPTYPE, a.POSITION, a.ISMANAGER, a.MANAGERID, a.DEPARTMENT, a.CITY, a.STARTDATE, a.ENDDATE, a.ACTIVE, a.COSTCENTER, b.FIRSTNAME as MGR_FIRSTNAME, b.LASTNAME as MGR_LASTNAME, b.USERID as MGR_USERID from DEMO_HR_EMPLOYEES a left outer join DEMO_HR_EMPLOYEES b on a.MANAGERID = b.USERID where 1=1 order by a.LASTNAME, a.FIRSTNAME</copy>
    ```

    Now, based on this information, you can create a `UNION`-based SQL Injection query to display all the sensitive data that you want to extract directly from the form. Here, you use the query to extract `USER_ID`, `MEMBER_ID`, `PAYMENT_ACCT_NO`, and `ROUTING_NUMBER` from the `DEMO_HR_SUPPLEMENTAL_DATA` table.

6. Copy the following SQL code and paste it into the **Position** box, and then select **Yes** under **Debug**.

    ```sql
    <copy>' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --</copy>
    ```

    Note:
    Don't forget the single quote before the `UNION` keyword to close the SQL clause `LIKE`.
    Don't forget the two hyphens at the end to disable the rest of the query.

7. Click **Search**.

    You should get a SQL Firewall violation because the `UNION` query has not been added to the allowlist in the SQL Firewall policy.

    ```text
    <copy>java.sql.SQLException: ORA-47605: SQL Firewall violation</copy>
    ```

8. In Data Safe, review the violation report. 

9. Drilldown into the report to analyze the violations. From here, you can take appropriate action.


You may now proceed to the next lab.

## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, Dec 10, 2024


