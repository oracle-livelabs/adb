<!--- This is a comment. --->

# Set Up the Workshop Environment

## Introduction

This lab walks you through the steps to set up the workshop environment.

> **Note:** This workshop is directed at administrator users because they are granted the required access permissions. In real life scenarios, you would create a new Data Catalog administrator user and a Data Catalog administrator group, and then add the new administrator user to the new group. Next, you create the Oracle Cloud Infrastructure Identity and Access Management (IAM) policies that are required to create and manage a Data Catalog and Autonomous Database instances.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* (Optional) Create a compartment for your Data Catalog resources.
* Create an Autonomous Warehouse instance.
* (Optional) Create an OCI Data Catalog Instance

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.
* At least one user in your tenancy who wants to work with Data Catalog.

> **Note:** If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. [Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)

## Task 1: Log in to the Oracle Cloud Console

1. Log in to the **Oracle Cloud Console** as the Cloud Administrator. You will complete all the labs in this workshop using this Cloud Administrator.
See [Signing In to the Console](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Tasks/signingin.htm) in the _Oracle Cloud Infrastructure_ documentation.

2. On the **Sign In** page, select your tenancy, enter your username and password, and then click **Sign In**.

   ![The blurred username and masked password are displayed on the OCI Sign in screen. The tenancy's name and username are blurred. The Sign In button is highlighted.](./images/sign-in.png " ")

   The **Oracle Cloud Console** Home page is displayed.

   ![The partial Oracle Cloud Console Home Page is displayed.](./images/oracle-cloud-console-home.png "Partial Oracle Cloud Console is displayed.")

    >**Note:** To zoom in (magnify) a displayed image in this workshop, hover over the image to display the magnifying glass icon, and then then click the image.

   ![An example of magnifying an image. The magnifying glass icon with a plus sign is shown as hoovering over a sample image.](./images/magnify-image.png "Click an image to magnify it.")

## Task 2: (Optional) Create a Compartment

A Cloud Administrator can optionally create a compartment in your tenancy to help organize the Data Catalog resources. In this lab, as a Cloud Administrator, you will create a new compartment that will group all of your Data Catalog resources that you will use in the workshop.

1. Open the **Navigation** menu and click **Identity & Security**. Under **Identity**, click **Compartments**.

       ![The Navigation menu is clicked. The navigation path to Compartments is displayed.](./images/navigate-compartment.png "Click the Navigation menu, and navigate to Compartments.")

    For faster navigation, you can pin items that you use frequently. To pin an item, hover over the menu item and then click pin to the left of the item name.

    ![An example on pinning an item such as Data Lake/Data Catalog for quicker access is shown.](./images/pin-items.png " ")

    The pinned item is displayed in the **Pinned** section of the **Home** tab the next time you use the Navigation menu.

    ![An example that shows the Compartment item pinned.](./images/pinned-item.png " ")

    The **Recently visited** section of the **Home** tab shows recently used navigation items.

    To quickly find navigation menu items, use the **Search** box.

2. On the **Compartments** page, click **Create Compartment**.

   ![The Compartments page is displayed. The Create Compartment button is highlighted.](./images/click-create-compartment.png " ")

3. In the **Create Compartment** dialog box, enter **`training-adw-compartment`** in the **Name** field and **`Training ADW Compartment`** in the **Description** field.

4. In the **Parent Compartment** drop-down list, select your parent compartment, and then click **Create Compartment**.

   ![On the completed Create Compartment dialog box, click Create Compartment.](./images/create-compartment.png " ")

   The **Compartments** page is re-displayed and the newly created compartment is displayed in the list of available compartments.

   ![The newly created compartment is highlighted with its status as Active.](./images/compartment-created.png " ")

## Task 3: Create an Autonomous Data Warehouse Instance

1. Log in to the **Oracle Cloud Console** as the Cloud Administrator, if you are not already logged in. On the **Sign In** page, select your tenancy, enter your username and password, and then click **Sign In**. The **Oracle Cloud Console** Home page is displayed.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Data Warehouse**.

3. On the **Autonomous Databases** page, select your compartment from the **Compartment** drop-down list in the **List Scope** section. In this example, we selected our **`training-adw-compartment`**. Click **Create Autonomous Database**. The **Create Autonomous Database** page is displayed.

4. In the **Provide basic information for the Autonomous Database** section, specify the following:
       * **Compartment:** Select your own compartment.
       * **Display Name:** **`ADW-Data-Lake`**.
       * **Database Name:** **`TrainingADW`**.

       ![The completed "Provide basic information for the Autonomous Database" section is displayed.](./images/adb-basic-info.png " ")

5. In the **Choose a workload type** section, accept the **Data Warehouse** default selection.

       ![The selected Data Warehouse option of the "Choose a workload type" section is displayed and highlighted.](./images/adb-workload-type.png " ")

6. In the **Choose a deployment type** section, accept the **Shared Infrastructure** default selection.

       ![The selected Shared Infrastructure option of the "Choose a deployment type" section is displayed and highlighted.](./images/adb-deployment-type.png " ")

7. In the **Configure the database** section, specify the following:

       * **Always Free:** Disabled. If your Cloud Account is an Always Free account, you can select this option to create an Always Free autonomous database.
       * **Choose database version:** **`19c`**.
       * **OCPU count:** **`1`**.
       * **OCPU auto scaling:** Select this checkbox. This allows the system to automatically use up to three times more CPU and IO resources to meet the workload demand.
       * **Storage (TB):** **`1`** (TB).
       * **Storage auto scaling:** Leave the checkbox unchecked.

       ![The completed "Configure the database" section is displayed.](./images/adb-configure-db.png " ")

       >**Note:** If you are using a Free Trial or Always Free account, and you want to use Always Free Resources, you need to be in a region where Always Free Resources are available. You can see your current default **region** in the top, right hand corner of the page.

8. In the **Create administrator credentials** section, specify the following:

       * **Username:** This read-only field displays the default administrator username, **`ADMIN`**.
       **Important:** Make a note of this _username_ as you will need it to perform later tasks.
       * **Password:** Enter a password for the **`ADMIN`** user of your choice such as **`Training4ADW`**.
       **Important:** Make a note of this _password_ as you will need it to perform later tasks.
       * **Confirm password:** Confirm your password.

       ![The completed "Create administrator credentials" section is displayed.](./images/adb-admin-credentials.png " ")

9. In the **Choose network access** section, select the **Secure access from everywhere** option as the access type.

    ![The selected "Secure access from everywhere" option of the "Choose network access" section is displayed and highlighted.](./images/adb-network-access.png " ")

10. In the **Choose a License and Oracle Database Edition** section, select the __Bring your own license (BYOL)__ option as the license type. The **Choose an Oracle Database Edition** section is displayed. Select the __Oracle Database Enterprise Edition (EE)__ option.

       ![The selected Bring Your Own License (BYOL) option of the "Choose a license type" section is displayed and highlighted. The Create Autonomous Database button is highlighted.](./images/adb-license-type.png " ")

11. Click __Create Autonomous Database__.

12. The **Autonomous Database Details** page is displayed. The status of your ADB instance is **PROVISIONING**.

    ![The breadcrumbs and PROVISIONING Status on the Autonomous Database Details page are highlighted.](./images/adw-provisioning.png " ")

    In a few minutes, the instance status changes to **AVAILABLE**. At this point, your Autonomous Data Warehouse database instance is ready to use! Review your instance's details including its name, database version, OCPU count, and storage size.

    ![The breadcrumbs and AVAILABLE Status on the Autonomous Database Details page are highlighted. The Autonomous Database Information tab displays many details about your provisioned database.](./images/adb-provisioned.png " ")

13. Click the **Autonomous Database** link in the breadcrumbs. The **Autonomous Database** page is displayed. The new Autonomous Database instance is displayed.

    ![The provisioned Autonomous Database instance is displayed on the Autonomous Databases page. The state of the instance is AVAILABLE.](./images/adb-page.png " ")

## Task 4: (Optional) Create a Data Catalog Instance

OCI Data Catalog is a fully managed, self-service data discovery and governance solution for your enterprise data. With Data Catalog, you get a single collaborative environment to manage technical, business, and operational metadata. You can collect, organize, find, access, understand, enrich, and activate this metadata.

* Harvest technical metadata from a wide range of supported data sources that are accessible using public or private IPs.
* Create and manage a common enterprise vocabulary with a business glossary.
* Build a hierarchy of categories, subcategories, and terms with detailed rich text descriptions.
* Enrich the harvested technical metadata with annotations by linking data entities and attributes to the business terms or adding free-form tags.
* Find the information you need by exploring the data assets, browsing the data catalog, or using the quick search bar.
* Automate and manage harvesting jobs using schedules.
* Integrate the enterprise class capabilities of your data catalog with other applications using REST APIs and SDKs.

Watch our short overview video that explains key features in Data Catalog.

[](youtube:nY7mG2u6-Ew)

To learn about getting started with OCI Data Catalog and integrating OCI Data Catalog with ADB, see the [Get started with Oracle Cloud Infrastructure Data Catalog](https://apexapps.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=919) and [Access the Data Lake using Autonomous Database and Data Catalog](https://bit.ly/adb-dcat-datalake) LiveLabs workshops.

You may now proceed to the next lab.

## Learn More

* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous Database on Shared Exadata Infrastructure](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Data Catalog Overview](https://docs.oracle.com/en-us/iaas/data-catalog/using/overview.htm)
* [What Is a Data Catalog and Why Do You Need One?](https://www.oracle.com/big-data/what-is-a-data-catalog/)
* [Get Started with Data Catalog](https://docs.oracle.com/en-us/iaas/data-catalog/using/index.htm)

## Acknowledgements
* **Author:** Lauran Serhal, Consulting User Assistance Developer, Oracle Database and Big Data
* **Last Updated By/Date:** Lauran Serhal, May 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle.github.io/learning-library/data-management-library/autonomous-database/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
