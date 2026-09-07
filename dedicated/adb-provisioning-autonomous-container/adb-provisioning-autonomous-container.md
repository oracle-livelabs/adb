# Provision an Autonomous Container Database

## Introduction

An Autonomous Container Database (ACD) is a logical container service used in Oracle's dedicated cloud infrastructure to house and manage one or more Oracle Autonomous Databases. You can create multiple ACD resources in an Autonomous Exadata VM Cluster, but you must create at least one ACD before you can create any Autonomous AI Database.

Estimated Time: 20 mins

### Objectives

As a fleet administrator:

- Deploy an Autonomous Container Database (ACD) onto an Autonomous Exadata VM Cluster (Applicable to both Autonomous AI Database on Oracle Public Cloud and Exadata Cloud@Customer deployments).

### Required Artifacts

- An Oracle Cloud Infrastructure account with fleet administrator privileges. For a detailed description of required IAM policies, please refer to the [documentation on IAM policies](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbdf/) for Autonomous AI Database.

## Task 1: Create an Autonomous Container Database (ACD)

- Sign in to the OCI Console and Navigate to the **Oracle AI Database** option in the top left hamburger menu from your OCI home screen. Click **Autonomous AI Database on Dedicated Infrastructure**.

- Select **Autonomous Container Database** from the menu on the left. Click **Create Autonomous Container Database**.

  ![Navigate to OCI Console.](./images/create-acd1.png " ")

- On the **Create Autonomous Container Database** dialog box you can choose / modify the compartment to create your ACD. Select the compartment hosting your Exadata Infrastructure and Autonomous Exadata VM Cluster.

- Enter a user-friendly description or other information that helps you easily identify the resource. Enter a name for the container database. It can contain only letters and numbers.

- Choose the Exadata Infrastructure and an Autonomous Exadata VM Cluster to host the new Autonomous Container Database.

- Choose the Oracle Database software version for the Autonomous Container Database.

  ![Create ACD basic information.](./images/create-acd2.png " ")

- You will see an option to modify your ACD's maintenance schedule and the type of update you wish to apply to the container. Optionally, you can configure a maintenance preference or schedule by clicking **Modify maintenance schedule** that launches the **Edit automatic maintenance** dialog.

  ![Automatic maintenance configuration](./images/create-acd3.png " ")

- You can choose between Rolling or Non-rolling maintenance methods. Optionally, you can also select Enable time-zone update. You can change the maintenance schedule from the default to a custom schedule.

  ![Edit automatic maintenance.](./images/create-acd3a.png " ")

- You can specify your ACD's maintenance schedule, picking a month, week, day and time in each quarter when a maintenance operation can be carried out on that container.

  ![Change Maintenance schedule.](./images/create-acd3b.png " ")

- By default, automatic backups are enabled for an ACD. Optionally, you can choose to disable them by deselecting the Enable automatic backups check box. When you enable automatic backups, choose from the following options to determine how long backups are retained after terminating the ACD:
    - Retain backups as per the backup retention period
    - Retain backups for 72 hours, then delete

- You can associate a backup destination for the backups of Autonomous AI Databases created in an ACD. You can choose **Object Storage** or **Autonomous Recovery Service** (recommended option) as the backup destination for Autonomous AI Databases deployed On Oracle Public Cloud.  If creating the Autonomous Container Database on Exadata Cloud@Customer, configure the backup destination to be used for backups of Autonomous AI Databases created in the Autonomous Container Database. Select a Backup Destination Type and then specify options based on the selected type.

- If you choose to retain backups for the duration of the backup retention period, you can also enable retention lock.

- After enabling automatic backups, specify a Backup retention period value to meet your needs. You can choose any value between 7 to 95 days.

- Optionally, select **Enable cross-region backup copy** and specify a region for the backup copies.

  ![Backup configuration.](./images/create-acd4.png " ")

- Optionally, you can add contact emails to receive operational notifications, announcements, and unplanned maintenance notifications regarding your Autonomous Container Database.

  ![Configure contacts.](./images/create-acd5.png " ")

- Optionally, you can define a suitable value for the following resource management attributes to suit your needs. Optionally, select **Enable shared server connections** to support the Net services architecture.

  ![Configure operational notification.](./images/create-acd6.png " ")

- Optionally, you can configure the Autonomous Container Database to use customer-managed encryption keys instead of Oracle-managed encryption keys. Select **Encrypt using customer-managed keys** and then select either the **OCI Vault Service** or  **Oracle Key Vault** to use as the encryption key for the Autonomous Container Database.

- Optionally, you may also enable FIPS-140 security standards.

- If you want to use tags, add tags by selecting a Tag Namespace, Tag Key, and Tag Value.

  ![Configure tags.](./images/create-acd7.png " ")

Click **Create** to deploy your ACD.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Ranganath S R, Tejus S. & Kris Bhanushali
- **Adapted by :** Vandana Rajamani, Consulting UA Developer, June 2026
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, September 2026
