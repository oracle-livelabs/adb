# Clean up Resources Used in this Workshop (Optional)

## Introduction

In this lab, you will learn how to delete some or all of the resources that you created in this workshop that you don't need. If you want to re-run all the labs in this workshop again from the beginning, you can delete the entire compartment.

> **Note:**
If you are using a **Free Trial** account to run this workshop, Oracle recommends that you at delete the Data Catalog instance that you created when you successfully complete this workshop, to avoid unnecessary charges. This deletes the Data Catalog instance and all of the resources in this instance.

Estimated Time: 5 minutes

### Objectives

* Delete the Autonomous Data Warehouse instance.
* Delete any resources that you created in your compartment as part of this workshop.
* Delete your entire compartment if you don't need it.

### Prerequisites
* This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu.

> **Note:**
If you want to list the resources in your compartment, you can use the **Tenancy Explorer** page. From the **Navigation** menu, navigate to **Governance & Administration**. In the  **Governance** section, click **Tenancy Explorer**. On the **Tenancy Explorer** page, in the **Search compartments** field, type your compartment's name, and then select the compartment from the list of compartments. The resources in this compartment are displayed.

## Task 1: Delete Your Autonomous Data Warehouse Instance

You can terminate your ADW instance that you created in this workshop as follows:

1. Open the **Navigation** menu and click **Oracle Databases**. Click **Autonomous Database**.

2. On the **Autonomous Databases** page, in the **List Scope** section, select your compartment from the **Compartment** drop-down list. In the row for the your Autonomous Database instance, click the **Actions** icon (three dots), and then select **Terminate** from the context menu.

3. A **Terminate Autonomous Database** dialog box is displayed. Enter your ADB instance name in the **To confirm, enter the name of the database that you want to terminate** field, and then click **Terminate Autonomous Database**.

    The **State** of the Autonomous Database instance goes into **Terminating**. When the ADB is deleted, the **State** changes to **Terminated**.

## Task 2 (Optional): Delete Your Compartment

If you created an optional compartment for this workshop, you can delete it if you no longer need it. To delete a compartment, it must be empty of all resources. Before you initiate deleting a compartment, be sure that all its resources have been moved, deleted, or terminated, including any policies attached to the compartment. If you want to re-run this entire workshop from the beginning, you can must delete all of the resources in your compartment as described in the earlier steps of this lab. Next, you can delete the compartment. See [Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm) in the Oracle Cloud Infrastructure documentation.

1. Click the **Navigation** menu and click **Identity & Security**. Under **Identity**, select **Compartments**. From the list of available compartments, search for your compartment.

2. On the **Compartments** page, in the row for your compartment, click the **Actions** button, and then select **Delete** from the context menu.

3. A confirmation message box is displayed. Click **Delete**. The state of the deleted compartment changes from **Active** to **Deleting** until the compartment is successfully deleted. You can click on the compartment name link in the **Name** column to display the status of this operation.

This concludes the workshop.

## Want to Learn More?

* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Overview of Oracle Cloud Infrastructure Identity and Access Management](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)

## Acknowledgements

* **Author:** Lauran Serhal, Consulting User Assistance Developer, Oracle Autonomous Database and Big Data
* **Last Updated By/Date:** Lauran Serhal, August 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
