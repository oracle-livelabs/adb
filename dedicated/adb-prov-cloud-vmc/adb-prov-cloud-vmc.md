
# Provisioning a Cloud Autonomous Exadata VM Cluster for Autonomous Database on Dedicated Infrastructure

## Introduction

An Autonomous Exadata VM Cluster is a set of symmetrical VMs across all Compute nodes. Autonomous Container Database and Autonomous Databases run all the VMs across all nodes enabling high availability. It consumes all the resources of the underlying Exadata Infrastructure.

**This lab provides steps to set up an Autonomous VM Cluster on your Exadata Infrastructure.**

Estimated Time: 20 minutes

### Objectives

- Create an Autonomous VM Cluster on a pre-provisioned Exadata Infrastructure.

### Required Artifacts
- An Oracle Cloud Infrastructure account with a pre-provisioned instance of Exadata Infrastructure

Watch the video below for step by step directions on creating an Autonomous VM Cluster on your Exadata Infrastructure.

[](youtube:FVw2PfI0UbU)

## Task 1: Create an Autonomous VM Cluster on your Exadata Infrastructure

*Log in to your OCI account as a fleet administrator.*

- Navigate to the **Oracle Database** option in the top left hamburger menu from your OCI home screen and select **Autonomous Database or Autonomous Dedicated Infrastructure**.

    ![This image shows the result of performing the above step.](./images/create-cavm1.png " ")

- Select **Autonomous Exadata VM Cluster** from the menu on the left and click the **Create Autonomous Exadata VM Cluster** button.

    ![This image shows the result of performing the above step.](./images/create-cavm2.png " ")

- Perform the following tasks on the **Create Autonomous Exadata VM Cluster** page.

    ![This image shows the result of performing the above step.](./images/create-cavm3.png " ")

    - Choose a compartment to deploy the Autonomous VM Cluster and provide a display name.

    - Pick the Exadata Infrastructure. Change the compartment if your Exadata Infrastructure was created in a different compartment than shown in the title.

    - Configure network settings. Select the VCN and subnet in which your VM Cluster will be deployed.

    - Choose the license type you wish to use.
      - **Bring your own license:** If you choose this option, make sure you have proper entitlements to use for new service instances that you create.
      - **License included:** With this choice, the cost of the cloud service includes a license for the Database service

- Click **Create Autonomous Exadata VM Cluster**.

Once created, your Autonomous Exadata VM Cluster is ready to deploy Autonomous Container Databases.

*All Done! You have successfully setup your Autonomous VM Cluster on Exadata Cloud @ Customer environment. It is now ready to deploy Autonomous Container Databases*

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Ranganath, S R, Simon Law & Kris Bhanushali
- **Last Updated By/Date** - Kris Bhanushali, March 2022

## See an issue or have feedback?
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
