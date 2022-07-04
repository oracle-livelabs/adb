# Workshop Introduction and Overview

## Introduction to Oracle Autonomous Database Dedicated for Security Administrators
Oracle's Dedicated Autonomous Database service allows organizations to Rethink Database IT, enabling a customizable private database cloud in the public cloud. The dedicated choice makes it possible to deliver a self-service database capability that aligns with organizational structure. Different lines of business or project teams can have complete autonomy in their individual execution while the company itself gets a fleet wide simplified aggregation of overall health, availability and cost management. This separation of Fleet vs Database administration allows simple budgeting controls and resource isolation without getting in the way of the line of business execution. And a dedicated database deployment will support the entire spectrum of needs from simple apps to apps that require the highest governance, consistent performance and operational controls.

The Oracle Autonomous database on dedicated infrastructure runs on the Exadata platform and is available both in OCI and in a customer's data center as a Cloud @ Customer offering.

Watch the video below for an overview of Autonomous Database Dedicated.

[](youtube:fOKSNzDz1pk)

Estimated Workshop Time: 490 minutes

## Workshop Objectives
This set of hands-on-labs is designed to assist security administrators with setting up and using various features of the **Autonomous Database on dedicated Exadata Infrastructure** service. The labs address various database security aspects ranging from encryption key management, DB user security, auditing, sensitive data masking and privileged user access controls.

## Prerequisites
This workshop requires the Cloud Exadata Infrastructure, VM clusters, and autonomous container databases created in the *Introduction to Oracle Autonomous Database Dedicated for Fleet Administrators* workshop. Either complete that workshop or have these assets created by your fleet administrator.

## Hands-on Lab Breakdown
This is one of 3 workshops introducing the Autonomous Database on Dedicated Exadata Infrastructure Service. The workshops are designed for 3 job roles:
- Fleet administrators
- Developers and database users
- **Security administrators (this workshop)**

###Security Administrator
Security administrator is responsible for ensuring database environments are built with the right set of security controls and stay within corporate compliance requirements throughout their life-cycle. This function may be combined with the Fleet Admin function in many cases. Autonomous Dedicated is built with security at the forefront and automates most of the database security functions customers adhere to on-premises. The following labs address various database security aspects ranging from encryption key management, DB user security, auditing, sensitive data masking and priviledged user access controls.

Lab 1: Protect Data With Database Vault  
Lab 2: Data Safe with ATP-D  
Lab 3: Register a Target Database  
Lab 4: Assess Database Configurations with Oracle Data Safe  
Lab 5: Assess Users with Oracle Data Safe  
Lab 6: Discover Sensitive Data with Oracle Data Safe  
Lab 7: Verify a Sensitive Data Model with Oracle Data Safe  
Lab 8: Update a Sensitive Data Model with Oracle Data Safe  
Lab 9: Create a Sensitive Type Category with Data Safe  
Lab 10: Discover and Mask Sensitive Data by Using Default Masking Formats in Data Safe  
Lab 11: Explore Data Masking Results and Reports in Data Safe  
Lab 12: Create a Masking Format in Data Safe  
Lab 13: Configure a Variety of Masking Formats with Data Safe  
Lab 14: Provision Audit and Alert Policies and Configure an Audit Trail in Data Safe  
Lab 15: Analyze Audit Data with Reports and Alerts in Data Safe  
Lab 16: Custom Audit Policies Audit Data in Data Safe  
Lab 17: Customer Controlled Database Encryption Keys  

## A Private Database Cloud in the Oracle Public Cloud and on premises
With Autonomous Database Dedicated, customers get their own Exadata infrastructure in the Oracle Cloud and on-premise. The customers administrator simply specifies the size, region and availability domain where they want their dedicated Exadata infrastructure provisioned.  They also get to determine the update or patching schedule if they wish. Oracle automatically manages all patching activity but with Autonomous Database Dedicated service, customers have the option to customize the patching schedule.

## ADB Dedicated Architecture
Autonomous Databases on dedicated Exadata infrastructure have a four-level database architecture model that makes use of Oracle multitenant database architecture.  You must create the dedicated Exadata infrastructure resources in the following order:

1. Exadata Infrastructure
2. Autonomous VM Cluster
3. Autonomous Container Database
4. Autonomous Database

### Autonomous Exadata Infrastructure
This is a hardware rack which includes compute nodes and storage servers, tied together by a high-speed, low-latency InfiniBand network and intelligent Exadata software.

**Customer's have a choice to deploy their Exadata Infrastructure in any OCI region or on-premise if they chose to run  Autonomous databases in their data center.**

### Autonomous VM Cluster
An Autonomous VM Cluster is a set of symmetrical Virtual Machines across all Compute nodes. Autonomous Container and Database run all the VMs across all nodes enabling high availability. It consumes all the resources of the underlying Exadata Infrastructure.

### Autonomous Container Database
This resource provides a container for multiple user databases. This resource is sometimes referred to as a CDB, and is functionally equivalent to the multitenant container databases found in Oracle 12c and higher databases.

### Autonomous Database
You can create multiple Autonomous Databases within the same container database. This level of the database architecture is analogous to the pluggable databases (PDBs) found in non-Autonomous Exadata systems. Your Autonomous Database can be configured for either transaction processing or data warehouse workloads.

Please proceed to the next lab.

## Acknowledgements
- **Authors/Contributors** - Global Cloud Solution Hubs, Autonomous Database Product Management
- **Last Updated By/Date** - Kris Bhanushali and Rick Green, March 2022

## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
