# Observability for Oracle Database@AWS Using Amazon CloudWatch and EventBridge

## Introduction

In this hands-on workshop, you will learn how to monitor and manage Oracle Database@AWS workloads using familiar AWS native services. You'll explore how Oracle Autonomous AI Database metrics are automatically integrated with Amazon CloudWatch, enabling you to visualize database performance, build custom monitoring dashboards, and configure proactive alarms to quickly identify operational issues.

The workshop also demonstrates how to capture Oracle Database lifecycle events using Amazon EventBridge, allowing you to build event-driven workflows and automate operational responses using the AWS services you already use.

By the end of this workshop, you will have practical experience integrating Oracle Database@AWS with AWS observability and event management services, helping you improve visibility, streamline operations, and respond more effectively to database events.

This workshop is designed for cloud engineers, database administrators, and DevOps professionals who want to manage their Oracle Database@AWS workloads using familiar AWS native tools.

Estimated Time: 30 minutes

## Task 1: Explore Database Metrics in AWS CloudWatch

Oracle Database@AWS automatically publishes a rich set of performance and health metrics directly to AWS CloudWatch. This allows you to monitor your database using the same tools you use for the rest of your AWS infrastructure. In this task, you'll learn how to find and analyze these metrics.

### Steps

 1. Navigate to the **AWS CloudWatch** service.  

    ![AWS CloudWatch Console](./images/explore-metrics-1.png " ")

    ![AWS CloudWatch](./images/explore-metrics-2.png " ")

 2. Find the **OracleDatabase@AWS** custom metric namespaces.

    ![Custom Metric Namespaces](./images/explore-metrics-3.png " ")

 3. Within **OracleDatabase@AWS** custom metric namespaces find the Autonomous Database metrics.

    ![Autonomous Database metrics](./images/explore-metrics-4.png " ")

 4. Explore the available metrics and their dimensions (e.g., `dbName`, `dbId`).

    ![explore metrics and dimension](./images/explore-metrics-5.png " ")

 5. Graph a key metric like **CPUUtilization** to view its recent activity.

    ![View All metrics](./images/explore-metrics-6.png " ")

    ![Viw CPU Utilization](./images/explore-metrics-7.png " ")

 6. Change the time granularity in the graph.

    ![CPU Utilization with different granularity](./images/explore-metrics-8.png " ")

<<<<<<< HEAD
## Task 2: Visualize Performance with CloudWatch Dashboards
=======
## Task 2: Visualizing Performance with CloudWatch Dashboards
>>>>>>> upstream/main

While viewing individual metrics is useful, a dashboard provides a consolidated, at-a-glance view of your database's health. In this task, you will create a custom CloudWatch Dashboard to monitor the most important metrics for your database.

### Steps

1. Create a new **CloudWatch Dashboard**.  

   ![CloudWatch Dashboards.](./images/visualize-perf-0.png " ")

   ![Create CloudWatch Dashboard](./images/visualize-perf-1.png " ")

   ![New Dashboards name](./images/visualize-perf-2.png " ")

   ![Widget configuration](./images/visualize-perf-3.png " ")

2. Add a widget to display the **CPUUtilization** metric.

   ![Add metric graph](./images/visualize-perf-4.png " ")

   ![Create widget.](./images/visualize-perf-9.png " ")

3. Add widgets for other key metrics, such as **StorageUtilization** and **Sessions**.

   ![Add another widget](./images/visualize-perf-10.png " ")

   ![Storage Util add to graph.](./images/visualize-perf-6.png " ")

   ![Create Storage widget](./images/visualize-perf-9.png " ")

   ![Add another widget](./images/visualize-perf-10.png " ")

   ![Sessions add to graph](./images/visualize-perf-7.png " ")

   ![Create Sessins widget](./images/visualize-perf-9.png " ")

<<<<<<< HEAD
4. View the Dashboard.

   ![View Dashboard](./images/visualize-perf-8.png " ")

   **Note**: You can change the time granularity in the graph (eg. 12h, 1d, etc.)

## Task 3: Monitor Proactively with CloudWatch Alarms

=======
4. View the Dashboard

   ![View Dashboard](./images/visualize-perf-8.png " ")

## Task 3: Proactive Monitoring with CloudWatch Alarms
 
>>>>>>> upstream/main
Dashboards are great for observing performance, but alarms are essential for proactive management. CloudWatch Alarms can automatically notify you when a metric crosses a defined threshold, allowing you to respond to potential issues before they impact users.

### Steps

1. Select a metric to create an alarm for (e.g., **CPUUtilization**).

<<<<<<< HEAD
   Perform Steps 1 to 5 in [Task 1](?lab=observability-aws-native-services&section=task1#Task1:ExploreDatabaseMetricsinAWSCloudWatch) above and then click on the **Create alarm** button.
=======
   Perform Steps 1 to 5 in [Task 1](#task-1-exploring-database-metrics-in-aws-cloudwatch) above and then click on the **Create alarm** button.
>>>>>>> upstream/main

   ![Select a metric](./images/proactive-monitor-1.png " ")

2. Configure the alarm conditions (e.g., trigger when CPU is **above 80% utilization for 5 minutes**).  

   ![Specify metric condition](./images/proactive-monitor-2.png " ")

   ![Create Alarm](./images/proactive-monitor-3.png " ")

3. Create a new **Amazon SNS (Simple Notification Service)** topic to send notifications.

   ![Create a topic](./images/proactive-monitor-4.png " ")

   ![Configure actions for topic](./images/proactive-monitor-5.png " ")

   ![Move to next slide](./images/proactive-monitor-6.png " ")

4. Create the alarm, confirm your SNS email subscription and get the alarm notification when fired.

   ![Add alarm details](./images/proactive-monitor-7.png " ")

   ![Create alarm](./images/proactive-monitor-8.png " ")

   ![List Alarms](./images/proactive-monitor-9.png " ")

   ![Subscribe to AWS](./images/proactive-monitor-10.png " ")

   ![View CPU Utilization](./images/proactive-monitor-11.png " ")

5. *(Optional)* Temporarily lower the alarm threshold to test the notification flow (you'd get an e-mail like the one below).

   ![Lower Alarm threshold](./images/proactive-monitor-12.png " ")

## Acknowledgements

- **Author**: - German Viscuso, Director of Developer Community, Autonomous AI Database
- **Adapted By**: Vandana Rajamani, Consulting UA Developer, July 2026
- **Last Updated By/Date**: - Vandana Rajamani, Consulting UA Developer, August 2026
