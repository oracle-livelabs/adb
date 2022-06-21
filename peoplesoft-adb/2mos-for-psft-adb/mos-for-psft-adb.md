# Create a Service Request for PeopleSoft on ADB-S

## Introduction

This lab walks you through the process of optimizing the Oracle Autonomous Database created specifically for PeopleSoft.A Service Request needs to be created on My Oracle Support to have the most optimal application performance. 
 
Estimated Time: 5 minutes

### Objectives
In this lab, you will:
* Create an SR with My Oracle Support for optimal performance of PeopleSoft system on ADB-S

### Prerequisites
* My Oracle Support (MOS) credentials. Please make sure that you can successfully login to [Oracle Support](https://support.oracle.com). 

## Task: Service Request creation for PeopleSoft on ADB-S

- Login to My Oracle Support and click on create technical SR
 
     - PRODUCT: **Autonomous Database on Shared Infrastructure** 
     * ABSTRACT/SUMMARY: **PSFT on ADBS: please set PeopleSoft DB identifier**
        
        * In the SR, please include:
           
           1. Region (Data Center location) 
           2. Tenancy name and OCID 
           3. Autonomous DB name and OCID 
           4. Request to set init.ora parameter: **\_unnest\_subquery=false** 

        
    * Support will then make the change for your environment(s).



You may now **proceed to the next lab.**



## Acknowledgements
* **Authors** - Deepak Kumar M, PeopleSoft Architect
* **Contributors** - Deepak Kumar M, PeopleSoft Architect
* **Last Updated By/Date** - Deepak Kumar M, PeopleSoft Architect, Aug 2021



