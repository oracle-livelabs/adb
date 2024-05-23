# Provisioning an Autonomous JSON Database

## Introduction

This lab walks you through the steps to get started using the Oracle Autonomous JSON Database [AJD] on Oracle Cloud. In this lab, you will provision a new AJD instance and connect to the Autonomous Database using JSON.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[Provision an Autonomous JSON Database](videohub:1_13lbdo9h)

### Objectives

In this lab, you will:

* Learn how to provision a new Autonomous Database
* Connect to your Autonomous Database using JSON

### Prerequisites

* Logged into your Oracle Cloud Account

## Task 1: Choose AJD from the Services Menu

1. Login to the Oracle Cloud.

<if type="freetier">

2. If you are using a Free Trial or Always Free account, and you want to use Always Free Resources, you need to be in the home region of the tenancy. Always Free Resources are only available in the home regions. You can see your current default **Region** in the top, right hand corner of the page.

    ![Select region on the far upper-right corner of the page.](./images/region.png " ")

</if>
<if type="livelabs">

2. If you are using a LiveLabs account, you need to be in the region your account was provisioned in. You can see your current default **Region** in the top, right hand corner of the page. Make sure that it matches the region on the LiveLabs Launch page.

    ![Select region on the far upper-right corner of the page.](./images/region.png " ")

</if>

3. Click the navigation menu in the upper left to show top level navigation choices. Click on **Oracle Database** and choose **Autonomous JSON Database**.

    ![Click Autonomous JSON Database](./images/adb-json.png " ")

5. Use the __List Scope__ drop-down menu on the left to select a compartment. Make sure your workload type is __JSON Database__. <if type="livelabs">Enter the first part of your user name, for example `LL185` in the Search Compartments field to quickly locate your compartment.

    ![Check the workload type on the left.](images/livelabs-compartment.png " ")

</if>
<if type="freetier">
    ![Check the workload type on the left.](./images/compartments.png " ")
</if>
    ![choose workload type](./images/workload-type.png " ")

<if type="freetier">
   > **Note:** Avoid the use of the ManagedCompartmentforPaaS compartment as this is an Oracle default used for Oracle Platform Services.
</if>

## Task 2: Create the AJD Instance

1. Click **Create Autonomous Database** to start the instance creation process.

    ![Click Create Autonomous Database.](./images/create-adb.png " ")

2.  This brings up the __Create Autonomous Database__ screen where you will specify the configuration of the instance.

3. Provide basic information for the autonomous database:

<if type="freetier">
    - __Choose a compartment__ - Select a compartment for the database from the drop-down list.
</if>
<if type="livelabs">
    - __Choose a compartment__ - Use the default compartment that includes your user id.
</if>
    - __Display Name__ - Enter a memorable name for the database for display purposes. For this lab, use __JSONDB__.
<if type="freetier">
    - __Database Name__ - Use letters and numbers only, starting with a letter. Maximum length is 14 characters. (Underscores not initially supported.) For this lab, use __JSONDB__.

    ![Enter the required details.](./images/adb-info.png " ")
</if>
<if type="livelabs">
    - __Database Name__ - Use letters and numbers only, starting with a letter. Maximum length is 14 characters. (Underscores not initially supported.) For this lab, use __JSONDB__ and append you LiveLabs user id. For example, __JSONDB7199__.

    ![add a database name](./images/adb-info-livelabs.png)
</if>

4. Choose a workload type: Select the workload type for your database from the choices:

    - __JSON__ - For this lab, choose __JSON__ as the workload type. Note that the MongoDB API is also available on Autonomous Transaction Processing and Autonomous Data Warehouse. However, Autonomous JSON database was purposely build, designed, and priced for JSON and document store workloads.

    ![Choose a workload type.](./images/workload-type2.png " ")

5. Choose a deployment type: Select the deployment type for your database from the choices:

    - __Serverless__ - For this lab, choose __Serverless__ as the deployment type. (Autonomous JSON Database is only available on Serverless)

    ![Choose a deployment type.](./images/workload-type2.png " ")

6. Configure the database:

    <if type="freetier">
    - __Always Free__ - If your Cloud Account is an Always Free account, you can select this option to create an always free autonomous database. An always free database comes with 1 CPU and 20 GB of storage. For this lab, we recommend you leave Always Free unchecked.
    </if>
    <if type="livelabs">
    - __Always Free__ - For this lab, we recommend you leave Always Free unchecked.
    </if>
    - __Choose database version__ - Select 19c from the database version. Note: This lab should work on 21c AJD database as well.
    - __ECPU count__ - Number of ECPUs for your service. For this lab, leave the default __2 ECPU__. If you choose an Always Free database, it comes with preconfigured and fixed cpu capabilities.
    - __Storage__ - Select your storage capacity in gigabytes. For this lab you can reduce the storage to the minimum of __20 GB__ of storage. If you choose an Always Free database, it comes with 20 GB of storage by default.
    - __Auto Scaling__ - For this lab, keep auto scaling enabled, to allow the system to automatically use up to three times more CPU and IO resources to meet workload demand. (While this will not happen as part of the workshop, we don't know what else you are going to experiment with.)

    *Note: You cannot scale up/down an Always Free autonomous database.*

    If you are planning to use this autonomous database solely for the purpose of this workshop, you can reduce the backup retention also to the minimum of __1 day__.

    ![Choose the remaining parameters.](./images/configuration.png " ")

7. Create administrator credentials:

    - __Password and Confirm Password__ - Specify the password for ADMIN user of the service instance and confirm the password.

    The password must meet the following requirements:
    - The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character.
    - The password cannot contain the username.
    - The password cannot contain the double quote (") character.
    - The password must be different from the last 4 passwords used.
    - The password must not be the same password that is set less than 24 hours ago.
    - Re-enter the password to confirm it. Make a note of this password.

    Later stages of this LiveLab will be easier if you avoid any of the characters / : ? # [ ] and @ in your password.
    
    ![Enter password and confirm password.](./images/administration.png " ")

8. Set network access:

    In order to use the Database API for MongoDB, you must set the database up with an access control rule. So choose __Secure access from allowed IPs and VCNs only__.

    You can then click "Add My IP Address" to allow access from your current IP address. You should avoid any VPN or proxy server access which may mask or change your actual IP address. 

    If you are behind a proxy setup and have issues with access from your local IP address, you can set the CIDR block access to 0.0.0.0/0, which allows access from **everywhere**. This is not recommended for systems used in any production configuration, but sufficient for a workshop.

    ![add your IP address](./images/network-access.png " ")

9. Choose a license type:

    For Autonomous JSON Database, only __License Included__ is available. For other Autonomous Database workloads, you have these options:
    - __Bring Your Own License (BYOL)__ - Select this type when your organization has existing database licenses.
    - __License Included__ - Select this type when you want to subscribe to new database software licenses and the database cloud service.

    ![select license type](./images/license-type.png " ")

10. Click __Create Autonomous Database__.

    ![Click Create Autonomous Database.](./images/create-adb-final.png " ")

11.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Available. At this point, your Autonomous JSON database is ready to use! Have a look at your instance's details here including the Database Name, Database Version, OCPU Count, and Storage.

    ![Database instance homepage.](./images/provisioning.png " ")

## Task 3: Find MongoDB API Connection URL

These will be needed in later labs.

1. Go to Tool Configuration

    On the Autonomous Database Information page, click on the __Tool configuration__ tab.

    ![Database Actions button](./images/tool-configuration-tab.png " ")

    The Database Actions Console will open in a new browser tab.

2. Find MongoDB API

    Scroll down the page until you find the section __MongoDB API__. For Autonomous JSON databases, it should be enabled by default. For Autonomous Transaction Processing or Autonomous Data Warehouse, it will be disabled by default and you will need to click __Edit Tool Configuration__ at the top of the page to enable it. If you have not correctly set __Secure access from allowed IPs and VCNs only__ in the previous Task, you will not be able to enable the MongoDB API.

    ![URL for MongoDB API](./images/mdb-api-url.png " ")

3. Save the URL for __Oracle Database API for MongoDB__

    Click on the __Copy__ button to copy the access URL, and save it to a text file for later use.

You may now **proceed to the next lab**.

## Learn More

* [Provision Autonomous JSON Database](https://docs.oracle.com/en/cloud/paas/autonomous-json-database/ajdug/autonomous-provision.html#GUID-0B230036-0A05-4CA3-AF9D-97A255AE0C08)

## Acknowledgements

- **Author** - Roger Ford, Principal Product Manager, Oracle Database
- **Contributors** - Kamryn Vinson, Andres Quintana
- **Last Updated By/Date** - Hermann Baer, April 2024
