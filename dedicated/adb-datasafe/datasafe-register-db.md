# Register a dedicated ADB instance with Data Safe
## Introduction

Oracle Data Safe can connect to an Oracle Cloud database that has a public or private IP address on a virtual cloud network (VCN) in Oracle Cloud Infrastructure (OCI). This workshop describes the difference between public and private endpoints and explains the network connection between Oracle Data Safe and the databases. It also walks you through the steps of creating a private endpoint and registering an Autonomous Database (ADB) on dedicated Exadata Infrastructure with Oracle Data Safe.

Estimated Time: 10 minutes

## Task 1: Register your ADB-D

If your DB system has a private IP address, you need to create a private endpoint for it prior to registering it with Oracle Data Safe. You can create private endpoints on the Data Safe page in OCI. Be sure to create the private endpoint in the same tenancy and VCN as your database. The private IP address does not need to be on the same subnet as your database, although, it does need to be on a subnet that can communicate with the database. You can create a maximum of one private endpoint per VCN.
However, with the Autonomous Database, the entire registration is reduced to a single click operation.

- From your Menu, navigate to Autonomous Transaction Processing, Ensure you are in the right compartment and select the ADB-D instance you wish to register.

    ![This image shows the result of performing the above step.](./images/img1.png " ")

- On the extreme down right corner you would see an option to register your ADB-D database. Click on it and select Confirm.

    ![This image shows the result of performing the above step.](./images/img2.png " ")
    ![This image shows the result of performing the above step.](./images/img3-1.png " ")

- Once registered, click **View Console**. This takes you directly to the Data Safe console in your Region.

    ![This image shows the result of performing the above step.](./images/img3.png " ")

You may now **proceed to the next lab**.

## Acknowledgements

*Great Work! You have successfully Registered your ADB-D with Data Safe.*

- **Author** - Padma Priya Rajan, Navya M S & Jayshree Chatterjee
- **Last Updated By/Date** - Kris Bhanushali, Autonomous Database Product Management, March 2022


## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
