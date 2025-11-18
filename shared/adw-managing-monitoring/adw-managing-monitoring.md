# Monitor Your Autonomous AI Database Instance using the Cloud Console

## Introduction

In this lab, you will explore the monitoring capabilities available for your Oracle Autonomous AI Database (ADB).

Oracle provides several facilities for monitoring the performance and activity of your autonomous database. Among them are:
-   **Autonomous AI Database Metrics**
-   **Database Actions - Database Dashboard**
-   **Performance Hub**
-   **OCI Monitoring Console**

The ADB user interface provides dashboards to monitor the real-time and historical CPU and storage utilization, as well as database activity, like the number of running or queued statements. It also provides Real-Time SQL Monitoring to look at current and past long-running SQL statements in your instance and allows you to cancel long-running queries or set thresholds for ADW or ATP to automatically cancel them for you.

Estimated Lab Time: 10 minutes

Watch the video below for a quick walk-through of the lab.

[Monitor Your Autonomous AI Database Instance using the Cloud Console](videohub:1_q9gd2fnw)

### Video Preview

Watch a video demonstration of monitoring an Oracle Autonomous AI Database.

[](youtube:uA6X7bnvaFs)

### Objectives

In this lab, you'll:

- Examine the charts in the Metrics section of the Autonomous AI Database details Page
- Explore the charts in the Database dashboard
- Explore more charts in the Performance hub
- Examine the database monitoring charts in the OCI Monitoring Console

### Prerequisites

- This lab requires completion of the Provision an Autonomous AI Database lab in the **Contents** menu on the left.

## Task 1: Navigate to the Database Monitoring Tab

The first facility that we will look at for monitoring your autonomous database is the Database **Monitoring** tab on the Autonomous AI Database details page.

1. On your **`ADW_Finance_Mart`** Autonomous AI Database details page, scroll to the right of the page to the **Monitoring** tab.

    ![Scroll right to the Monitoring tab ](images/scroll-right-to-monitoring.png =65%x*)

## Task 2: Examine the Database Metrics

The **Monitoring** tab displays an initial set of 8 graphs to examine database metrics. There are links to drill down to many additional graphs.

1. Scroll through the 8 initial graphs: **CPU utilization**, **Storage utilization**, **Sessions**, **Execute count**, **Running statements**, **Queued statements**, **Database availability**, and **Failed connections**.

    ![Scroll down to Metrics eight initial graphs](images/scroll-down-to-metrics-eight-initial-graphs.png =65%x*)

    The time period displayed on the metrics screen can also be easily changed to reflect your desired time period.

    ![Click Applied filters to change time period](images/change-time-period.png =45%x*)

2. Click the **View all database metrics** link to examine many additional graphs of database metrics: Transaction Count, Current Logons, User Calls, Parse Count, Failed Logons, Failed Connections, Connection Latency, Query Latency, CPU Time, User Commits, User Rollbacks, Redo Size, Session Logical Reads, DB Block Changes, Physical Reads, Physical Writes, Physical Read Total Bytes, Physical Write Total Bytes, Parse Count (Hard), Parse Count (Failures), Bytes Received via SQL\*Net from DBLink, Bytes Sent via SQL\*Net to DBLink, Bytes Received via SQL\*Net from Client, Bytes Sent via SQL\*Net to Client, APEX Page Events, and APEX Page Load Time.

    ![Click View all database metrics](images/click-view-all-database-metrics.png =65%x*)

## Task 3: Examine the Database Actions Database Dashboard

You can also view this monitoring information with more detailed tools provided in the **Database Actions Launchpad**.

1. On the Autonomous AI Database details page, click the **Database actions** drop-down list, and then click **View all database actions**.

    ![Click View all database actions.](images/click-view-all-database-actions.png " ")

    >**Note:** If the sign-in dialog box for Database Actions is displayed, enter your database instance's default administrator account username, **`admin`** and the admin password you specified when creating the database. Next, click **Sign in** to display the **Database Actions Launchpad**.

    The **Database Actions Launchpad** page is displayed.

    ![The Launchpad page is displayed.](images/launchpad.png =65%x*)

2. Click the **Monitoring** tab, and then click the **Database Dashboard** tab.

    ![In Database Actions Launchpad, click the Monitoring > Database Dashboard tabs.](images/click-monitoring-database-dashboard.png =65%x*)

3. The **Database Dashboard** is displayed with the **Overview** tab selected by default. This page gives an overview of the storage allocation and usage, CPU utilization, running SQL statements, the number of allocated ECPUs, and SQL statement response time.

    ![Examine the components of Database Dashboard overview tab](images/database-actions-overview-tab.png =65%x*)

4. Select the **Monitor** tab at the top of the page to view this information in real time or for a specific time period. The **Monitor** tab opens initially in the **Real time** view.

    ![Examine the components of Database Dashboard Monitor tab in real time](images/database-actions-monitor-tab-real-time.png =65%x*)

4. When you click the **Time period** view, you can use the **calendar** to look at a specific time period. You can also use the **time slider** to change the period for which performance data is shown.

    ![Examine the components of Database Dashboard Monitor tab in a time period](images/database-actions-monitor-tab-time-period.png =65%x*)

## Task 4: View Performance Data from the Performance Hub
You can view real-time and historical performance data from the Performance Hub. Performance Hub shows information about Active Session History (ASH) analytics and SQL monitoring.

1. Click the **Database Actions | Database Dashboard** in the banner to display the **Launchpad** page. Click the **Monitoring** tab, and then click the **Performance Hub** tab.

    ![Access Performance Hub from the Database Actions Launchpad Monitoring section](images/click-performance-hub-in-database-actions.png =65%x*)

    >**Note:** You can also access the **Performance Hub** from the **Autonomous AI Database details** page.

    ![Access Performance Hub from the Autonomous AI Database details](images/click-performance-hub-in-details-page.png =65%x*)

2. The **Performance Hub** page is displayed. At the top of the page you can select the time range to display, followed by the Activity Summary, which is displayed in Database Time in units of average active sessions.

    ![Examine the top of the Performance hub page](images/top-of-performance-hub-page.png =65%x*)

3. Continuing down the page, you can view Active sessions history analytics and SQL monitoring.

    The **ASH Analytics** tab shows the average active sessions.

    ![Examine the ASH Analytics tab](images/performance-hub-ash-analytics.png =65%x*)

4. Click the **SQL Monitoring** tab. Each SQL statement can be inspected for further details. Here you can see the status, duration, SQL ID, SQL Plan Hash, and the user who created the statement. You can also see if parallelism was used, the resources consumed, and the SQL text.

    You can select the link in the **SQL ID** column to go to the corresponding **Real-time SQL Monitoring** page. This page provides additional details to help you tune the selected SQL statement.

    To terminate a running or queued SQL statement, click **Kill Session**.

    ![Examine the SQL Monitoring tab](images/performance-hub-sql-monitoring.png =65%x*)

5. If you open the Performance Hub from the **Autonomous AI Database details** page rather than from the **Database Actions Launchpad** like in our example, some additional information is available.

    The Automatic Workload Repository (AWR) collects, processes, and maintains performance statistics for problem detection and self-tuning purposes. This data is stored in both memory and the database. From the Performance Hub, you can generate and download a report of the gathered data.

    From the **Reports** drop-down list, select **Automatic Workload Repository**.

    ![Select Automatic Workload Repository from Reports drop-down list](images/select-awr-from-reports-menu.png =65%x*)

6. In the **Generate Automatic Workload Repository Report** dialog, select the Start Snapshot and End Snapshot time range. After you select the time range, click **Download**.

    ![Select a time range and generate the report](images/generate-awr-report.png =65%x*)

7. On our MS-Windows machine and Chrome browser, the report is downloaded to our downloads folder. Click the downloaded HTML file to view the lengthy, detailed report.

    ![Download and view the report](images/view-amr-report.png =65%x*)

## Task 5: Examine the OCI Monitoring Console

Another facility for monitoring your autonomous database is the OCI Monitoring Console.

1. Go back to the Console. Click the **Navigation** menu.

    ![Go to OCI dashboard navigation menu](images/click-navigation-menu.png =40%x*)

2. Click **Observability & Management**. Under **Monitoring**, click **Service Metrics**.

    ![Navigate to OCI service metrics](images/click-service-metrics.png =65%x*)

3. Choose a **Compartment** that you have permission to work in. Choose a **Metric Namespace** in the drop-down menu to the right of the compartment. If you're not sure which compartment and namespace to use, contact an administrator. Click the **Add** (pencil) icon next to **Dimensions**.

    ![Click the edit button for dimensions](images/click-add-dimensions-icon.png " ")

4. In the **Edit Dimensions** dialog box, select **Shared** as the **Deployment Type**. Click **Done**.

    ![Select a deployment type](images/select-a-deployment-type.png " ")

5. The page updates to display only the resources in that compartment and namespace. Scroll down this very long page. It shows the following metrics:
    - CPU Utilization
    - Storage utilization
    - Sessions
    - Execute Count
    - Running Statements
    - Queued Statements
    - Transaction Count
    - Current Logons
    - User Calls
    - Parse Count
    - Failed Logons
    - Failed Connections
    - Connection Latency
    - Query Latency
    - CPU Time

    ![Scroll down the service metrics page](images/scroll-down-service-metrics-page.png =65%x*)

6. In addition to these service metrics, you can also perform queries on the metrics by using **Metrics Explorer**, creating **Alarms**, and creating **Health Checks**, to ensure that users will become immediately aware of any availability issues.

    ![You can create alarms and health checks](images/metrics-explorer-alarms-health-checks.png " ")

You may now **proceed to the next lab**.

## Want to Learn More?

* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/manage-service.html#GUID-759EFFFA-9FAC-4439-B47F-281E470E01DE)

## Acknowledgements

- **Author:** Lauran K. Serhal, Consulting User Assistance Developer
- **Last Updated By/Date:** Lauran K. Serhal, October 2025
