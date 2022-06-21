# Provision an Autonomous Database

## Introduction

Deploy a Autonomous Transaction Processing Database.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

-   Provision a new Autonomous Database

### Prerequisites

-   This lab requires completion of the Get Started section in the Contents menu on the left.


## Task 1: Choose Autonomous Database from the Services Menu

1. Log in to the Oracle Cloud Interface.
2. Once you log in, you arrive at the cloud services dashboard where you can see all the services available to you. Click the navigation menu in the upper left to show top level navigation choices and then click **Autonomous Database**.

    ![Oracle home page.](./images/navigation.png " ")

## Task 2: Create the Autonomous Database instance

1. Select your compartment and click **Create Autonomous Database** to start the instance creation process. If you were assigned a compartment, enter it here.

    ![Click Create Autonomous Database.](./images/create-adb-button.png " ")

2.  This brings up the __Create Autonomous Database__ screen where you will specify the configuration of the instance.

<if type="freetier">
    ![](./images/create-adb-screen-freetier-default.png " ")
</if>
<if type="livelabs">
    ![](./images/livelabs-adwconfig.png)
</if>

3. Give basic information for the autonomous database:
    - __Choose a compartment__ - Use the default compartment created for you.
    - __Display Name__ - Enter a memorable name for the database for display purposes. For this lab, use **My-Quick-Start-ADB**.
    - __Database Name__ - Use letters and numbers only, starting with a letter. Maximum length is 14 characters. (Underscores not initially supported.) For this lab, use __POSTOATP__.

    ![Enter the required details.](./images/livelabs-adwname.png " ")

4. Choose __Transaction Processing__ workload type:

    ![Choose a workload type.](./images/adb-workload-type.png " ")

5. Choose __Shared Infrastructure__ deployment type:

    ![Choose a deployment type.](./images/adb-deployment-type.png " ")

6. Configure the database:

    - __Choose database version__ - Select 19c as the database version.
    - __OCPU count__ - Number of CPUs for your service. For this lab, specify __1 CPUs__.
    - __Storage (TB)__ - Select your storage capacity in terabytes. For this lab, specify __1 TB__ of storage.
    - __OCPU Auto Scaling__ - For this lab, keep auto scaling enabled, to enable the system to automatically use up to three times more CPU and IO resources to meet workload demand.
    - __New Database Preview__ - If a checkbox is available to preview a new database version, do NOT select it.

    ![Choose the remaining parameters.](./images/adb-configure.png " ")

7. Create administrator credentials:

    - __Password and Confirm Password__ - Specify the password for ADMIN user of the service instance. The password must meet the following requirements:
    - The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character.
    - The password cannot contain the username.
    - The password cannot contain the double quote (") character.
    - The password must be different from the last 4 passwords used.
    - The password must not be the same password that you set less than 24 hours ago.
    - Re-enter the password to confirm it. Make a note of this password.

    ![Enter password and confirm password.](./images/admin-credential.png " ")

8. Choose network access:
    - For this lab, accept the default, "Secure access from everywhere."
    - If you want to allow traffic only from the IP addresses and VCNs you specify - where access to the database from all public IPs or VCNs is blocked, select "Secure access from allowed IPs and VCNs only" in the Choose network access area.
    - If you want to restrict access to a private endpoint within an OCI VCN, select "Private endpoint access only" in the Choose network access area.
    - If the "Require mutual TLS (mTLS) authentication" option is selected, mTLS will be required to authenticate connections to your Autonomous Database. TLS connections allow you to connect to your Autonomous Database without a wallet, if you use a JDBC thin driver with JDK8 or above. See the [documentation for network options](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/support-tls-mtls-authentication.html#GUID-3F3F1FA4-DD7D-4211-A1D3-A74ED35C0AF5) for options to allow TLS, or to require only mutual TLS (mTLS) authentication.

    ![Choose the network access type.](./images/picture100-26e.png " ")


9. Choose a license type. <if type="freetier">For this lab, choose __License Included__.</if><if type="livelabs">For this lab, choose __Bring Your Own License (BYOL)__.</if> The two license types are:
    - __Bring Your Own License (BYOL)__ - Select this type when your organization has existing database licenses.
    - __License Included__ - Select this type when you want to subscribe to new database software licenses and the database cloud service.

<if type="freetier">
    ![](./images/license.png " ")
</if>
<if type="livelabs">
    ![](./images/livelabs-byol.png)
</if>

10. For this lab, do not provide a contact email address. The "Contact Email" field allows you to list contacts to receive operational notices and announcements as well as unplanned maintenance notifications.

    ![Do not provide a contact email address.](images/contact-email-field.png)

11. Click __Create Autonomous Database__.

12.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Available. At this point, your Autonomous Database is ready to use! Have a look at your instance's details here including its name, database version, OCPU count, and storage size.

    ![Database instance homepage.](./images/adb-provisioning.png " ")
    Provisioning an Autonomous Database instance.

    ![Database instance homepage.](./images/adb-provisioned.png " ")
    Autonomous Database sucessfully provisioned.

You may now **proceed to the next lab**.

## Learn more

See the [documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/autonomous-workflow.html#GUID-5780368D-6D40-475C-8DEB-DBA14BA675C3) on the typical workflow for using Autonomous Data Warehouse.

## Acknowledgements

- **Author** - Goutam Pal, Senior Cloud Engineer, NA Cloud Engineering
- **Last Updated By/Date** - Kamryn Vinson, April 2022
