# Provision an Autonomous Database

## Introduction

This lab walks you through the steps to get started using the Oracle Autonomous Database (Autonomous Data Warehouse [ADW]) on Oracle Cloud. In this lab, you provision a new ADW instance.

Estimated Lab Time: 5 minutes

### Objectives

In this lab, you will:

*   Navigate to the Oracle Autonomous Data Warehouse cloud service using the Oracle Cloud Infrastructure console.
*   Provision a new Autonomous Data Warehouse database.

### Prerequisites

This lab assumes you have:

- **Note:** The timings and screenshots in this workshop are based on using 8 OCPUs. If you opt to configure fewer OCPUs the response times and query times will be longer.
- Completed the steps in the **Get Started** section seen in the Contents menu on the left.

## Task 1: Choose ADW from the Services Menu

1. Log in to the Oracle Cloud, as shown in the previous lab.
2. Once you are logged in, you are taken to the cloud services dashboard where you can see all the services available to you. Click the navigation menu in the upper left to show top level navigation choices.

    __Note:__ You can also directly access your Autonomous Data Warehouse or Autonomous Transaction Processing service in the __Quick Actions__ section of the dashboard.

    ![Oracle home page.](./images/Picture100-36.png " ")

3. This lab shows provisioning of an Autonomous Data Warehouse database, so click **Oracle Database** and then click **Autonomous Data Warehouse**.

    ![Click Autonomous Data Warehouse.](https://oracle-livelabs.github.io/common/images/console/database-adw.png " ")

4. Make sure your workload type is __Data Warehouse__ or __All__ to see your Autonomous Data Warehouse instances. Use the __List Scope__ drop-down menu to select a compartment. If you are using a LiveLabs environment, be sure to select the compartment provided by the environment from the List Scope drop-down menu.

    ![Check the workload type on the left.](images/livelabs-compartment.png " ")

   *Note: Avoid the use of the ManagedCompartmentforPaaS compartment as this is an Oracle default used for Oracle Platform Services.*

5. This console shows that no databases yet exist. If there were a long list of databases, you could filter the list by the **State** of the databases (Available, Stopped, Terminated, and so on). You can also sort by __Workload Type__. Here, the __Data Warehouse__ workload type is selected.

    ![Autonomous Databases console.](./images/Compartment.png " ")

6. You can see your current default **region** in the top, right hand corner of the page.

    ![Select region on the far upper-right corner of the page.](./images/Region.png " ")

## Task 2: Create the ADB Instance

1. Click **Create Autonomous Database** to start the instance creation process.

    ![Click Create Autonomous Database.](./images/Picture100-23.png " ")

2.  This brings up the __Create Autonomous Database__ screen where you will specify the configuration of the instance.
3. Provide basic information for the autonomous database:

    - __Choose a compartment__ - Select a compartment for the database from the drop-down list.
    - __Display Name__ - Enter a memorable name for the database for display purposes. For this lab, use __MyQuickStartADW__.
    - __Database Name__ - Use letters and numbers only, starting with a letter. Maximum length is 14 characters. (Underscores not initially supported.) For this lab, use __MYQUICKSTART__.

    ![Enter the required details.](./images/Picture100-26.png " ")

4. Choose a workload type. Select the workload type for your database from the choices:

    - __Data Warehouse__ - For this lab, choose __Data Warehouse__ as the workload type.
    - __Transaction Processing__ - Alternatively, you could have chosen Transaction Processing as the workload type.

    ![Choose a workload type.](./images/Picture100-26b.png " ")

5. Choose a deployment type. Select the deployment type for your database from the choices:

    - __Shared Infrastructure__ - For this lab, choose __Shared Infrastructure__ as the deployment type.
    - __Dedicated Infrastructure__ - Alternatively, you could have chosen Dedicated Infrastructure as the deployment type.

    ![Choose a deployment type.](./images/Picture100-26_deployment_type.png " ")

6. Configure the database:

    - __Choose database version__ - Select a database version from the available versions.
    - __OCPU count__ - Number of CPUs for your service<if type="livelabs">, choose __2 OCPUs__ when you are running your workshop in LiveLabs sandbox environment</if>. Our example screenshot uses a database instance with __8 OCPUs__. If you opt to configure fewer OCPUs your response times and query times will be longer<if type="livelabs"> and similarly if you opt to configure more OCPUs your response times and query times will be lesser</if>.
    - __Storage (TB)__ - Select your storage capacity in terabytes. For this lab, specify __1 TB__ of storage.
    - __Auto Scaling__ - For this lab, keep auto scaling enabled, to allow the system to automatically use up to three times more CPU and IO resources to meet workload demand.
    - __New Database Preview__ - If a checkbox is available to preview a new database version, do NOT select it.

    ![Choose the remaining parameters.](./images/Picture100-26c.png " ")

7. Create administrator credentials:

    - __Password and Confirm Password__ - Specify the password for ADMIN user of the service instance. The password must meet the following requirements:
    - The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character.
    - The password cannot contain the username.
    - The password cannot contain the double quote (") character.
    - The password must be different from the last 4 passwords used.
    - The password must not be the same password that is set less than 24 hours ago.
    - Re-enter the password to confirm it. Make a note of this password.

    ![Enter password and confirm password.](./images/Picture100-26d.png " ")
8. Choose network access:
    - For this lab, accept the default, **"Allow secure access from everywhere"**.
    - If you want a private endpoint, to allow traffic only from the VCN you specify - where access to the database from all public IPs or VCNs is blocked, then select "Virtual cloud network" in the Choose network access area.
    - You can control and restrict access to your Autonomous Database by setting network access control lists (ACLs). You can select from 4 IP notation types: IP Address, CIDR Block, Virtual Cloud Network, Virtual Cloud Network OCID).


9. Choose a license type. For this lab, choose __License Included__. The two license types are:

    - __Bring Your Own License (BYOL)__ - Select this type when your organization has existing database licenses.
    - __License Included__ - Select this type when you want to subscribe to new database software licenses and the database cloud service.

10. Click __Create Autonomous Database__.

    ![Click Create Autonomous Database.](./images/Picture100-27.png " ")

11.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Available. At this point, your Autonomous Data Warehouse database is ready to use! Have a look at your instance's details here including its name, database version, OCPU count, and storage size.

    ![Database instance homepage.](./images/Picture100-32.png " ")

Please *proceed to the next lab*.

## Learn More

- Click [here](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/autonomous-workflow.html#GUID-5780368D-6D40-475C-8DEB-DBA14BA675C3) for documentation on the typical workflow for using Autonomous Data Warehouse.

## Acknowledgements

- **Author** - Nilay Panchal, ADB Product Management
- **Adapted for Cloud by** - Richard Green, Principal Developer, Database User Assistance
- **Contributors** - Oracle LiveLabs QA Team (Jeffrey Malcolm Jr, Intern | Arabella Yao, Product Manager Intern)
- **Last Updated By/Date** - Anoosha Pilli, April 2022