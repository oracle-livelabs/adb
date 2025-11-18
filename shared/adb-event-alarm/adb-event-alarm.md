# Set Event and Alarm Notifications for an Autonomous AI Database

## Introduction

>_**Important:** The OCI Notifications service is not supported in the Livelabs hosted sandbox environment. If you are running this workshop in a LiveLabs sandbox, please view the steps in this lab to learn about setting event and alarm notifications. However, please do not attempt to perform the steps._

The Oracle Cloud Infrastructure (OCI) Notifications service broadcasts messages to distributed components through a publish-subscribe pattern, delivering secure, highly reliable, low latency and durable messages for applications hosted on OCI and externally.

The Notifications service enables you to set up communication channels for publishing messages using topics and subscriptions. When a message is published to a topic, the Notifications service sends the message to all of the topic's subscriptions.

This lab shows you how to define events and alarms with conditional rules that will generate email notifications when the state of an Autonomous AI Database changes or an alarm condition has been met.

**An event** is triggered for a lifecycle management (LCM) type operation performed in Oracle Cloud, such as creating a database, stopping a database, and so on.

**An alarm** is triggered over a resource utilization metric, such as a database's CPU utilization going over a certain percentage or Object Storage bucket going over a certain size limit.

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you'll:

- Use the OCI Console to define a notification topic and subscribe to the topic.
- Create a rule for an Autonomous AI Database event that will trigger an email notification.
- Perform an activity that activates the rule and confirm that an email notification was sent.
- Create and test an Autonomous AI Database alarm that will trigger an email notification.

## **PART 1 - Define an Event that Will Email a Notification When a Database Is Stopped**

OCI Notifications service enables you to set up communication channels for publishing messages using topics and subscriptions.

**Topic**: A communication channel for sending messages to the subscriptions in the topic.

**Subscription**: An endpoint for a topic. Published messages are sent to each subscription for a topic.

**Message**: The content that is published to a topic. Each message is delivered at least once per subscription.

In Tasks 1 through 7, you create a notification topic with an email subscription, then create a rule that triggers a message (email) when a database is stopped.

## Task 1: Sign in to OCI Console and Create a Notification Topic

>_**Note:** Again, please note that the OCI Notifications service is not supported in the Livelabs hosted sandbox environment. If you are running this workshop in a LiveLabs sandbox, please view the steps in this lab to learn about setting event and alarm notifications. However, please do not attempt to perform the steps._

1. Create a Notification topic. Click the **Navigation** menu, and then click **Developer Services**. Under **Application Integration**, click **Notifications**.

2. On the **Topics** page, click **Create Topic**.

3. In the **Create Topic** panel, enter a name and an optional description, and then click **Create**.

    ![Click Create](images/click-create.png)

    The new notification is displayed on the **Topics** page.

    ![The new topic is displayed](images/new-topic-displayed.png)

## Task 2: Create a Subscription to the Topic

Now that you have created a notification topic, create a subscription to that topic, so that you can receive email alerts when a condition changes. You will create a rule with conditions in a following task.

In this task, you create an email subscription. Subscriptions can be defined to trigger emails or pager notifications (for on-call staff whose phones will be paged.)

1. On the **Topics** page, click the **Data-Notification** topic. On the **Topics details** page, click the **Subscriptions** tab, and then click **Create subscription**.

    ![Click Create Subscription](images/click-create-subscription.png)

2. On the **Create Subscription** panel, specify the following:
    - **PROTOCOL:** Email
    - **EMAIL:** Enter your email address

    ![Create the subscription](images/create-subscription.png)

3. Click **Create**. The current status of the subscription is **Pending**.

    ![State pending](images/state-pending.png)

## Task 3: Respond to the Verification Email

1. You will receive an email notification of your subscription to the email address that you specified. You need to respond to the email's verification request. Click the **Confirm subscription** link.

    ![Confirm subscription](images/click-confirm-subscription.png)

2. A browser tab opens, confirming that you have subscribed your email account to the **Data-Notification** topic.

    ![The subscription is confirmed](images/subscription-confirmed.png)

3. On the **Data-Notifications** page, the new subscription is displayed. You might have to refresh the page to display the new subscription. The subscription status is now **Active**.

  ![The new subscription is displayed.](images/subscription-displayed.png)

You are now subscribed to a Notification topic. Next you will define an event with conditions that, when met, will publish messages to this Notification topic.

## Task 5: Define an Event with Rules that Will Publish Messages

Let's define an event that triggers an email notification when an Autonomous AI Database is stopped.

1. In the Oracle Console, click the **Navigation** menu.

2. Click **Observability & Management**. Under **Events Service**, click **Rules**.
  
  ![Click Rules](images/click-rules.png)

2. On the **Rules** page, click **Create Rule**.

  ![Click Create Rule](images/click-create-rule.png)

3. On the **Create Rule** page, specify the following:
    - **DISPLAY NAME:** : Provide a name, such as the event type that you will be choosing; in this lab, the event type will be `Autonomous AI Database - Stop End`.
    - **DESCRIPTION:** Provide a description.

    In the **Rule Conditions** section, specify the following:
    - **Condition:** `Event Type`
    - **SERVICE NAME:** `Database`
    - **EVENT TYPE:** : Choose `Autonomous AI Database - Stop End` from the drop-down list.

    In the **Actions** section, specify the following:

    - **ACTION TYPE:** `Notifications`
    - **NOTIFICATIONS COMPARTMENT:**: Choose your compartment.
    - **TOPIC:** Choose the topic created earlier, **Data-Notification**.

4. Click **Create Rule**.

  ![Click Create Rule](images/click-create-rule-page.png)

  The **Autonomous AI Database - Stop End** page is displayed.

  ![The Stop End page is displayed](images/stop-end-page.png)

You have configured a Notification service and tied an event to it with a specific compartment. When a database is shut down, an email notification will be sent to the email address specified.

## Task 6: Trigger the Event

You will now shut down the Autonomous AI Database to trigger the notification email.

1. Navigate to the **`ADW_Finance_Mart`** **Autonomous AI Database details** page. Click the **More actions** drop-down list, and then select **Stop**.

  ![Stop the database](images/stop-database.png)

2. In the **Confirm stop** dialog box, click **Stop**.

3. The initial status of the database is **Stopping**.

4. Wait until the database status changes to **Stopped**.

## Task 7: Verify that an Email Notification Was Sent

Check the the email account that you specified to verify that a notification email was sent.

1. Go to the specified email account and verify that a notification of the database stoppage has been sent.

  ![The email notification is sent](images/stop-database-email.png)

## **PART 2 - Define an Alarm that Will Email a Notification When CPU Utilization Exceeds a Specific Percentage**

In Tasks 8 through 10, define an alarm that triggers an email when CPU utilization exceeds a percentage level that you set.

>**Note:** For convenience, use the same topic and subscription that you defined in Part 1; however, you could define new ones, if you prefer.

## Task 8:  Define an Alarm for the CPU Utilization Chart

1. Start your `ADW_Finance_Mart` database. Navigate back to your `ADW_Finance_Mart` **Autonomous AI Database details** page, if you are not there already. Click the **More actions** drop-down list, and then select **Start**. In the **Confirm start** dialog box, click **Start**. The initial status of the workshop is **Starting**. In a few minutes, the status changes to **Available**.

2. On the **Autonomous AI Database details** page, click the **Monitoring** tab. 

  ![Click the Monitoring tab](images/click-monitoring-tab.png)

3. In the **CPU utilization** chart section, click the **Actions** (ellipsis) icon, and then select **Create an alarm on this query**.

  ![Define an alarm](images/define-alarm.png)

3. On the **Create Alarm** page, specify the following:
    - **Alarm name:** Provide a name, perhaps indicating the metric that will trigger the alarm. In this lab example, the alarm is to `alert unusual CPU usage`.
 
    In the **Metric description** section, specify the following:
    - **Compartment:** Choose the compartment that contains the Autonomous AI Database for which you are creating the alarm.
    - **Metric namespace**: The available options depend on the types of resources that exist in the selected compartment. In this case, choose **`oci_autonomous_database`**.
    - **Metric name** : **`CpuUtilization`**

    In the **Metric dimensions** section, specify the following:
    - Click **+Additional dimension**. Select **resourceId** from the drop-down list as the name. For the **Dimension value**, Select the first value in the drop-down list. This is the OCID for your region. You can find your region's OCID on your **Autonomous AI Database details** page.
    - **DeploymentType:** Select **Shared**

    In the **Trigger rule 1** section, specify the following:
    - **Operator:** `greater than`.
    - **Value:** Specify the value of the condition threshold. In this lab example, specify **30** so that the alarm will trigger if CPU utilization exceeds 30 percent.
    - **Trigger delay minutes:** Specify the number of minutes that the condition must be maintained before the alarm is in a firing state. In this lab example, specify **1** minute.
    - **Alarm severity:** Select `Critical`.

    In the **Define alarm notifications** section, specify the following:

    - **Destination service:** Select **`Notifications`**.
    - **Compartment:** Select your compartment.
    - **Topic:** Select the topic you defined earlier in **Part 1 > Task 1** of this lab, **`Data-Notifications`**.

    ![Click Save alarm](images/save-alarm.png)

4. Click **Save alarm**. The **CPU Usage Alarm** is displayed.

    ![The alarm is created](images/alarm-created.png)

## Task 9: Create a CPU Utilization that Triggers the New Alarm

Re-run the **`test_proc`** procedure in **Lab 6: Apply Auto Scaling > Task 5** again to create a CPU utilization that triggers the alarm that you just created. You will run the `**test_proc**` procedure concurrently in 3 SQL Developer Web query worksheet instances, which should result in CPU utilization greater than the 30% specified as the triggering level in the alarm. 

1. Let's make sure that you'll trigger the CPU alarm. From the **Autonomous AI Database details** page, click the **More actions** drop-down list, and then select **Manager resource allocation**. Change the **ECPU count** for the **`ADW_Finance_Mart`** instance to the original setting from lab 1 to `2`. Make sure that the **Compute auto scaling** slider is disabled. 

2. Navigate to your SQL Worksheet. 

  ![Navigate to SQL Worksheet](images/navigate-sql-worksheet.png " ")

3. Go to your **Query 1**, **Query 2**, and **Query 3** SQL worksheets (re-open 3 instances if you closed the tabs from before). Change the **Consumer group** drop-down list setting to **HIGH**. Copy the following execute command into each worksheet; however, _but do not immediately execute the command_. After you have entered the command into the three worksheets, quickly click **Run Script** to execute the command in each worksheet so that they begin at nearly the same time.

    ```
    <copy>
    exec test_proc;
    </copy>
    ```
    ![Execute command, query 1.](./images/run-query-1.png " ")

    ![Execute command, query 2.](./images/run-query-2.png " ")

    ![Execute command, query 3.](./images/run-query-3.png " ")

## Task 10: Verify that an Email Notification Was Sent

Check the email account you specified to verify that a notification email was sent.

1. Go to the specified email account and verify that a notification of the CPU utilization has been sent. 

  ![CPU Usage Alarm email](images/cpu-usage-alarm-email.png " ")

2. In the body of the email, click the **View Alarm in Console** green button at the bottom of the email. The alarm is displayed in the Console.

  ![CPU Usage Alarm displayed in Console](images/cpu-usage-alarm-console.png " ")

You may now **proceed to the next lab**.

## Want to Learn More?

* [Getting Started with Events](https://docs.cloud.oracle.com/en-us/iaas/Content/Events/Concepts/eventsgetstarted.htm)
* [Overview of Events](https://docs.cloud.oracle.com/en-us/iaas/Content/Events/Concepts/eventsoverview.htm)
* [Notifications Overview](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm)

## Acknowledgements

- **Author:** Lauran K. Serhal, Consulting User Assistance Developer
- **Contributor:** Nilay Panchal, ADB Product Management
- **Last Updated By/Date:** Lauran K. Serhal, October 2025