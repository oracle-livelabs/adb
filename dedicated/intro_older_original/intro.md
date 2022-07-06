# Workshop Introduction and Overview #

## Introduction to Oracle Autonomous Database Dedicated ##
Oracle's Dedicated Autonomous Database service allows organizations to Rethink Database IT, enabling a customizable private database cloud in the public cloud. The dedicated choice makes it possible to deliver a self-service database capability that aligns with organizational structure. Different lines of business or project teams can have complete autonomy in their individual execution while the company itself gets a fleet wide simplified aggregation of overall health, availability and cost management. This separation of Fleet vs Database administration allows simple budgeting controls and resource isolation without getting in the way of the line of business execution. And a dedicated database deployment will support the entire spectrum of needs from simple apps to apps that require the highest governance, consistent performance and operational controls.

The Oracle Autonomous database on dedicated infrastructure runs on the Exadata platform and is available both in OCI and in a customer's data center as a Cloud @ Customer offering.

Watch the video below for an overview of Autonomous Database Dedicated

[](youtube:fOKSNzDz1pk)

## Workshop Objectives

This collection of hands-on-lab guides is designed to assist customer administrators and developers with setting up and using various features of the **Autonomous Database on dedicated Exadata Infrastructure** service. Since the collection is ever growing and vast, a recommended approach is to try labs based on end user persona.


## Hands-on Lab Breakdown

For simplicity, these hands-on labs may be divided into 3 sections based on the following user personas,

### Fleet Administrator

A fleet administrator is the owner of the Exadata Infrastructure components and Container databases. Fleet admins are responsible for ensuring all provisioning is in line with corporate policies and adhere's to their security and availability standards. 

Fleet administrators may be interested in the following hands-on labs

**Provisioning**


[Lab 1](?lab=lab-1-adb-network-prepare): Prepare Private Network for OCI Implementation  

[Lab 2](?lab=lab-2-adb-provisioning-exadata): Provisioning a Cloud Exadata Infrastructure for ADB on Dedicated Infrastructure  

[Lab 3](?lab=lab-3-adb-provisioning-Cloud-VMC): Provisioning a Cloud Autonomous Exadata VM Cluster for ADB on Dedicated Infrastructure  

[Lab 4](?lab=lab-4-adb-provisioning-exaC@C): Provisioning Exadata Infrastructure for ADB on Exadata Cloud@Customer  

[Lab 5](?lab=lab-5-adb-provisioning-VMC): Provisioning an Autonomous VM Cluster for ADB on Exadata Cloud@Customer  

[Lab 6](?lab=lab-6-aadb-provisioning-autonomous-container): Provisioning an Autonomous Container Database  

[Lab 9](?lab=lab-9-atp-configuring-vpn): Configure VPN Connectivity in your Exadata Network  

[Lab 29](?lab=lab-29-adb-data-guard): Autonomous Data Guard  



**Migration & Monitoring**

[Lab 16](?lab=lab-16-atp-data-pump-migration): Migrate with Data Pump  

[Lab 17](?lab=lab-17-atp-goldengate-replication): Oracle Goldengate Replication  

[Lab 23](?lab=lab-23-adb-event-notifications): OCI Notification Service  

[Lab 25](?lab=lab-25-adb-deploy-oem): Deploy OEM and connect ADB to OEM  

[Lab 25-2](?lab=lab-25-2-adb-AWR-report-with-OEM): Download AWR report from OEM  


### Developer / Database User

A Developer is the owner of an Autonomous Database (ADB) and is responsible for provisioning ADBs on-demand. Developers may also be interested in the performance of their database application. The following developer / ADB user focused labs address provisioning, application development, monitoring, tuning of ADBs as well as recovery from user errors.

[Lab 7](?lab=lab-7-adb-provisioning-databases): Provisioning databases  

[Lab 8](?lab=lab-8-adb-configure-dev-client): Configuring a Development System  

[Lab 10](?lab=lab-10-adb-build-and-deploy-nodejs): Build and Deploy Node.js Application  

[Lab 11](?lab=lab-11-aadb-build-python-apps): Build Python Application Stacks  

[Lab 12](?lab=lab-12-adb-build-java-apps): Build Java Application Stacks  

[Lab 13](?lab=lab-13-adb-using-cli-commands): Using CLI commands  

[Lab 14](?lab=lab-14-adb-sql-developer-web): Database Actions Console  

[Lab 15](?lab=lab-15-adb-build-apex-apps): Build Apex Application  

[Lab 18](?lab=lab-18-aadb-build-always-on-apps): Build Always On Applications  

[Lab 19](?lab=lab-19-adb-performance-hub): Managing Database Performance  

[Lab 20](?lab=lab-20-adb-scaling.md): Zero Downtime Scaling  

[Lab 22](?lab=lab-22-adb-flashback-recovery): Recover Errors Using Flashback Recovery  

[Lab 24](?lab=lab-24-adb-connect-oac): Oracle Analytics Cloud  

[Lab 25-1](?lab=lab-25-1-adb-automatic-indexing): Automatic Indexing  

[Lab 26](?lab=lab-26-MV2ADB): Move to ADB  



### Database Security Administrator

A Database security administrator is responsible for ensuring database environments are built with the right set of security controls and stay within corporate compliance requirements throughout their life-cycle. This function may be combined with the Fleet Admin function in many cases. Autonomous Dedicated is built with security at the forefront and automates most of the database security functions customers adhere to on-premises. The following labs address various database security aspects ranging from encryption key management, DB user security, auditing, sensitive data masking and priviledged user access controls.

[Lab 21](?lab=lab-21-adb-vault): Protect Data With Database Vault  

[Lab 27](?lab=lab-27-datasafe): Data Safe with ATP-D  

[Lab 27-1](?lab=lab-27-1-datasafe-register-db): Register a Target Database  

[Lab 27-2](?lab=lab-27-2-datasafe-assessment-1): Assess Database Configurations with Oracle Data Safe  

[Lab 27-3](?lab=lab-27-3-datasafe-assessment-2): Assess Users with Oracle Data Safe  

[Lab 27-4](?lab=lab-27-4-datasafe-discovery-1): Discover Sensitive Data with Oracle Data Safe  

[Lab 27-5](?lab=lab-27-5-datasafe-discovery-2): Verify a Sensitive Data Model with Oracle Data Safe  

[Lab 27-6](?lab=lab-27-6-datasafe-discovery-3): Update a Sensitive Data Model with Oracle Data Safe  

[Lab 27-7](?lab=lab-27-7-datasafe-discovery-4): Create a Sensitive Type Category with Data Safe  

[Lab 27-8](?lab=lab-27-8-datasafe-masking-1): Discover and Mask Sensitive Data by Using Default Masking Formats in Data Safe  

[Lab 27-9](?lab=lab-27-9-datasafe-masking-2): Explore Data Masking Results and Reports in Data Safe  

[Lab 27-10](?lab=lab-27-10-datasafe-masking-3): Create a Masking Format in Data Safe  

[Lab 27-11](?lab=lab-27-11-datasafe-masking-4): Configure a Variety of Masking Formats with Data Safe  

[Lab 27-12](?lab=lab-27-12-datasafe-auditing-1): Provision Audit and Alert Policies and Configure an Audit Trail in Data Safe  

[Lab 27-13](?lab=lab-27-13-datasafe-auditing-2): Analyze Audit Data with Reports and Alerts in Data Safe  

[Lab 27-14](?lab=lab-27-14-datasafe-auditing-3): Custom Audit Policies Audit Data in Data Safe  

[Lab 28](?lab=lab-28-adb-kms): Customer Controlled Database Encryption Keys  




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
- **Last Updated By/Date** - Kris Bhanushali, Feb 8 2022


## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!