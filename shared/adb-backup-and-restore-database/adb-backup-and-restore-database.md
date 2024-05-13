
# Backup and Restore Your Autonomous Database

## Introduction

Data is one of the most important assets of any organization today. Whether you're a small business or a large enterprise, your data is critical to your success. In turn, data corruption or data loss that may be caused by disasters, hardware failures, human error or even malicious attacks can have a major impact. It is crucial to have an effective backup and recovery strategy in place. Autonomous Database Serverless provides some of the best and most user-friendly backup and restore options, made reliable by being fully managed by Oracle automation.

This lab shows where to examine automatic backups, how to restore a backup, and how to configure a long-term backup schedule.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you'll:

- Identify where to examine automatic daily database backups
- Restore your Oracle Autonomous Database from a specific point in time.
- Configure a long-term backup schedule.

## Task 1: Examine the Automatic Backups

Autonomous Database automatically backs up your database for you daily. The retention period for backups is 60 days. You can restore and recover your database to any point-in-time in this retention period.

Let's examine where to find available backups of your Autonomous Database.

1. On the **Autonomous Database details** page, scroll down to the **Backup** section, and note the backup information.

    ![Examine the Backup section of Autonomous Database details page](images/examine-backup-section-details-page.png)

2. Scroll down further to the **Resources** section, and then click the **Backups** link. This link lists the backups that have been automatically created for you daily.

    ![Click the Backups link.](images/click-backups-link.png)

    > **Note:** In this workshop, your newly-created Autonomous Database will not yet have a list of daily backups.

    ![Examine the list of daily automatic backups of your Autonomous Database](images/list-of-daily-backups.png)

## Task 2: Restore a Backup

You can restore any of the daily backups listed, or you can restore from a point in time by entering a timestamp within the **last 60 days**.

1. To restore a specific backup in the list of backups, you simply click the 3-dot ellipsis icon next to one of the backups, and then click **Restore**; However, in this workshop, you may not yet have a list of backups. So let us instead move on to Step 2.

    ![Click Restore from ellipsis menu alongside a listed backup](images/click-restore-from-list-of-backups.png)

2. On the **Autonomous Database details** page, click the **More actions** drop-down list, and then select **Restore**.

    ![Select Restore from the More actions drop-down menu](images/select-restore-from-more-actions-dropdown-menu.png)

3. The **Restore** dialog box has a **Select Backup** choice that lets you restore from a list of daily backups similar to the previous step, but let's use the default choice, **Enter Timestamp**. Click the **calendar icon** in the **Enter timestamp** field.

    ![Click the calendar icon at the Side of the Enter Timestamp field in the Restore dialog](images/click-calendar-icon-to-enter-timestamp.png)

4. Click today's date on the calendar, May 6, 2024 in our example. Today's date will appear in the **Enter timestamp** field; However the hours, minutes, and seconds will be zeros. For the purpose of this workshop, we want to change this timestamp to a few minutes prior to the current universal time. Leave this dialog box open.

    ![Click today's date on calendar](images/click-todays-date-on-calendar.png)

5. Open another browser window or tab. Go to https://time.is/UTC and note the current universal time.

     ![Check universal time.](images/check-universal-time.png =60%x*)

6. Go back to the **Restore** dialog box that you left open, and enter a time that is approximately 10 minutes earlier than the current universal time you found. In our example, if the current time is 13:00:46, we would change the time from 00:00:00 to 12:50:00. After you enter a time approximately 10 minutes earlier than the current universal time, click **Restore**.

    ![Enter a time 10 minutes earlier than the current universal time and click Restore](images/enter-time-10-minutes-earlier-than-UTC.png)

    The status of the database instance is **RESTORE IN PROGRESS**.

    ![The instance status.](images/restore-in-progress-status.png =30%x*)

6. Wait a few minutes while the database restores from the point in the timestamp you just entered. When the database instance is restored to your specified timestamp, its status changes to **AVAILABLE**.

    ![The restore is complete.](images/restore-complete.png =30%x*)

## Task 3: Configure a long-term backup schedule

In today's world, regulations, audits, and compliance requirements often demand long-term retention of data. For instance, in the financial or healthcare sector, you may have to keep transactional and patient data for several years, if not decades. You may need long-term backups for compliance and regulatory requirements, legal and contractual obligations, historical analysis, or for business continuity in response to data loss.

It is essential to have a database backup plan that covers both short-term and long-term retention. As with other aspects of Oracle Autonomous Database, the process of long-term backups is completely automated and managed by Oracle.

Using the **long-term backup** feature, you can create a long-term backup as a one-time backup or as scheduled long-term backup. You select the retention period for long-term backups in the range of a minimum of 3 months and a maximum of 10 years.

Autonomous Database takes scheduled long-term backups automatically according to the schedule you create: **one-time**, **weekly**, **monthly**, or **yearly**.

1. Scroll down your **Autonomous Database details** page to the **Resources** section, and then select the the **Backups** link. In the **Backups** section, click **Create long-term backup**.

    ![Select Backups in the Resources section of Autonomous Database details page](images/click-create-long-term-backup.png)

2. The **Create long-term backup** panel is displayed. Backups on Autonomous Database are completely automated. Specify the following:
    * **Retention period:** Accept the default **`1`** Year.
    * **Schedule long-term backup:** Select this checkbox.

        In the **Backup schedule** section, specify the following:

    * **Backup date and time:** Accept the displayed current time.
    * **Repeat:** Select **Yearly** from the drop-down list. The other available choices are: **Weekly**, **Monthly**, and **One-time (does not repeat)**.

        >**Note:** You may also automate long-term backups at your own and personalized cadence by calling long-term backup CLI APIs in your scripts or via Terraform.

    ![Specify the long-term backup details](images/specify-long-term-backup-details.png =65%x*)

3. Click **Create**. Oracle starts an asynchronous job to create a long-term backup for you in the background, so your database is not held up waiting for the backup to complete. You can track this long-term backup and other lifecycle management (LCM) operations triggered on your database by clicking the **Work requests** link. Initially, the state of the backup job creation is **In progress**.

    ![Click the Work requests tab](images/click-work-requests.png " ")

    When the backup job is created, the status changes to **Succeeded**.

    ![Backup job state is successful.](images/backup-job-successful.png " ")

4. When your long-term backup is available, you will see it in your list of backups. Each long-term backup is a standalone backup that can be managed individually. You may edit the retention period of a long-term backup, delete it if you no longer need it, or clone from the backup when you need an instantiated database copy from that long-term backup.

    It is good practice to test your long-term backup after creating it by cloning from it, to ensure your backed up data is as required.

    ![Test your long-term backup by cloning it](images/test-long-term-backup-by-cloning-it.png)

5. From the **Autonomous Database details** page, you can view the details of any scheduled long-term backups and you can edit a long-term backup schedule. Note that the  console also presents the size of backups you are paying for - While 60 day automatic backups are included with OCPU-based databases, long-term backups will be billed additionally at your database storage rate.

    ![View scheduled long-term backups on the Autonomous Database details page](images/view-scheduled-long-term-backups.png)

You may now **proceed to the next lab**.

## Want to Learn More?

- [Backing Up and Restoring Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/backup-restore.html#GUID-9035DFB8-4702-4CEB-8281-C2A303820809)
- [Create Long-Term Backups on Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/backup-long-term.html)
- [Keep backups long-term (up to 10 years!) on Autonomous Database](https://blogs.oracle.com/datawarehousing/post/long-term-backups-autonomous-database)

## Acknowledgements

- **Author:** Lauran K. Serhal, Consulting User Assistance Developer
- **Contributor:** Rick Green, Principal Developer, Database User Assistance
- **Last Updated By/Date:**  Lauran K. Serhal, May 2024
