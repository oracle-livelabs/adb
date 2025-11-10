# Clean up Resources Used in this Workshop (Optional)

## Introduction

In this lab, you will learn how to delete some or all of the resources that you created in this workshop that you don't need. If you want to re-run all the labs in this workshop again from the beginning, you can delete the entire compartment.

Estimated Time: 5 minutes

### Objectives

* Destroy the created stack and its resources such as the ADB instance.
* Delete your entire compartment if you don't need it.

### Prerequisites
This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu.

## Task 1: Destroy Your Stack

You can destroy (instead of deleting) your stack that you created in Lab 1 in this workshop as follows. Associated resources such as your ADB instance persist after stack deletion. To avoid difficult cleanup later, we recommend that you release associated resources first by running a destroy job. See [Creating a Destroy Job](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-job-destroy.htm) for additional information. _If you prefer to keep your stack, you can terminate your ADB instance as detailed in Task 2._

1. Open the **Navigation** menu and click **Developer Services**. In the **Resource Manager** section, click **Stacks**.

2. Click your stack name.

3. On the **Stack details** page, click **Destroy**. A **Destroy** confirmation box is displayed. Click **Destroy**. The initial status is **Accepted** followed by **In progress** and finally **Succeeded**. The stack resources are released.

## Task 2 (Optional): Delete Your Compartment

If you created an optional compartment for this workshop, you can delete it if you no longer need it. To delete a compartment, it must be empty of all resources. Before you initiate deleting a compartment, be sure that all its resources have been moved, deleted, or terminated, including any policies attached to the compartment. If you want to re-run this entire workshop from the beginning, you must delete all of the resources in your compartment as described in the earlier steps of this lab. Next, you can delete the compartment. See [Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm) in the Oracle Cloud Infrastructure documentation.

1. Click the **Navigation** menu and click **Identity & Security**. Under **Identity**, select **Compartments**. From the list of available compartments, search for your compartment.

2. On the **Compartments** page, in the row for your compartment, click the **Actions** button, and then select **Delete** from the context menu.

3. A confirmation message box is displayed. Click **Delete**. The state of the deleted compartment changes from **Active** to **Deleting** until the compartment is successfully deleted. You can click on the compartment name link in the **Name** column to display the status of this operation.

**This concludes the workshop.**

## Want to Learn More?

* [Creating a Destroy Job](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-job-destroy.htm)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Overview of Oracle Cloud Infrastructure Identity and Access Management](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Last Updated By/Date:** Lauran K. Serhal, November 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
