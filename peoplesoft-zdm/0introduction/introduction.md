# Introduction

## About this Workshop

This hands-on lab provides users with step-by-step instructions for migrating a PeopleSoft database to an Oracle Autonomous Transaction Processing Database Serverless, or **ADB-S**. At a high level, during this procedure, we will use Oracle's **Zero Downtime Migration** to move data to OCI Autonomous Database and referring it in short as **ZDM**.



Estimated Time: 10 hours

Notes:
- The workshop is quite detailed and technical. PLEASE take your time and DO NOT skip any steps.
- Follow all naming conventions (compartment, group, etc..) and passwords as directed.   
- IP addresses and URLs in the screenshots in this workshop may differ from what you use in the labs as these are dynamically generated.
- The user interface for the Oracle Cloud Infrastructure is constantly evolving. As a result the screens depicted in this tutorial may not exactly coincide with the current release. This tutorial is routinely updated for functional changes of Oracle Cloud Infrastructure, at which time any differences in the user interface will be reconciled.

### Objectives

In Labs 1-11, you will :

* Create an Oracle Autonomous Database serverless
* Create a Service Request for PeopleSoft on ADB-S
* ADB connectivity test for PeopleSoft On Premises
* ZDM Download, Install and Pre-requisites
* Source Database, ADB connectivity test and Target ADB-S Configuration
* Configuring  OCI ADB-S Database for PeopleSoft
* ZDM Configuration and ADB Schema Advisor Installation
* ZDM Database migration for PeopleSoft
* PeopleSoft post import scripts for ADB-S
* Validating PeopleSoft Schema Objects on ADB-S
* PeopleSoft Middle Tier Setup & Configuration and Test PeopleSoft login in OCI

### Prerequisites


* An OCI tenancy with administrator user access.
* My Oracle Support (MOS) credentials. Please make sure that you can successfully login to [Oracle Support](https://support.oracle.com).
* PeopleSoft Source Database already existing on an on-premises system with the following server specifications: Oracle Linux 7/8, PeopleSoft HCM 9.2 PI 47 with PeopleTools 8.58.10 or above and Oracle Database version on 19.10. (Note: PeopleSoft Marketplace images for HR system, Financial, Campus Solution etc can also be used in place of an on-premises PeopleSoft application,Refer to link [here](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3208) for creation of new environment on OCI)
* The following should be installed:
    * A different web browser (i.e. Chrome) to connect to OCI web console.
    * If you have a windows machine, please download:
        * Git Bash [https://git-scm.com/download/win](https://git-scm.com/download/win)
        * Putty [https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html). In the Package Files section, click on an installer depending on 32/64 bits.

## Appendix

*Terminology*

The following terms are commonly employed in PeopleSoft cloud operations and used throughout our documentation:

**Availability Domain** – One or more data centers located within a region.

**Bucket** – A logical container used by Object Storage for storing your data and files. A bucket can contain an unlimited number of objects.

**Compartments** – Allows you to organize and control access to your cloud resources. A compartment is a collection of related resources (such as instances, virtual cloud networks, block volumes) that can be accessed only by certain groups.

**Virtual Cloud Network (VCN)** – Networking and compute resources required to run PSFT on Oracle Cloud Infrastructure. The PSFT VCN includes the recommended networking resources (VCN, subnets routing tables, internet gateway, security lists, and security rules) to run Oracle PeopleSoft on OCI.

**Oracle Cloud Infrastructure (OCI)** – Combines the elasticity and utility of public cloud with the granular control, security, and predictability of on-premises infrastructure to deliver high-performance, high availability, and cost-effective infrastructure services.

**Region** – Oracle Cloud Infrastructure are hosted in regions, which are located in different metropolitan areas. Regions are completely independent of other regions and can be separated by vast distances – across countries or even continents. Generally, you would deploy an application in the region where it is most heavily used, since using nearby resources is faster than using distant resources.

**Subnet, Private** - Instances created in private subnets do not have direct access to the Internet. In this lab, we will be provisioning the Cloud Manager stack in Resource Manager, and creating private subnets. We will then choose to create a "jump host", or bastion host, as part of the installation. The IP for a private subnet cannot be accessed directly from the Internet. To access our CM instance in a private subnet, we will set up a jump host to enable SSH tunneling and Socket Secure (SOCKS) proxy connection to the Cloud Manager web server (PIA). The jump host is created using an Oracle Linux platform image, and will be created inside the VCN.

**Subnet, Public** - Instances that you create in a public subnet have public IP addresses, and can be accessed from the Internet.

**Tenancy** – When you sign up for Oracle Cloud Infrastructure, Oracle creates a tenancy for your company, which is a secure and isolated partition within Oracle Cloud Infrastructure where you can create, organize, and administer your cloud resources.



## Acknowledgements
* **Authors** - Deepak Kumar M, Principal Cloud Architect
* **Contributors** - Deepak Kumar M, Principal Cloud Architect
* **Last Updated By/Date** - Deepak Kumar M, Principal Cloud Architect, December 2023

