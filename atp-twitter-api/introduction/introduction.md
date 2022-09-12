# Create OML model

## Introduction

This workshop is to educate users on the interoperability of Twitter API, Oracle APEX, and Machine learning to extract the sentiment of tweets. By specifying particular keywords to collect, metadata, such as geo-location and hashtag frequency, are used to generate dynamic and embedded analytics. Using APEX's low code development platform and Twitter API, cx_Oracle is used to create a connection from the user's local execution of the Python library, Tweepy, and a Autonomous Transaction Processing (ATP) database. This data is processed and fed through a machine learning algorithm to capture the sentiment (positive, neutral, or negative) of specific tweets. 

Customers are continuously asking for solutions that utilize data from popular social media platforms (such as Twitter) to analyze their marketing campaigns and overall sentiment of their organizations. In this example, Mexico City's government is interested in what it's people are saying about them.  Using APEX, we can deliver a insightful web application that can give a quick analysis of the general sentiment of the people using word maps, statistics, and even a heat map to illustrate how the people are feeling towards the city.

Estimated Time: 90 minutes

![Lab Architecture](images/roadmap.png)

### Objectives

In this lab, you will complete the following tasks:

- Create Schema
- Extract API
- Review ATP Storage
- Review Data Preprocessing
- Review Machine Learning
- Explore APEX

### Prerequisites

This lab assumes you have:
- An Oracle Always Free/Free Tier, Paid or LiveLabs Cloud Account
- Familiarity with Twitter is desirable, but not required
- Some understanding of cloud and database terms is helpful
- Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
- Basic familiarity with Oracle APEX
- Python 3.9 installed on your computer (Lab won't run properly with newer versions of Python)
- Basic familiarity with Python and SQL language
- IDE of your choice installed on your computer (EX: VSCode or Atom)

## Want to learn more about Autonomous Database?
- [Oracle Autonomous Data Warehouse Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
- [Additional Autonomous Data Warehouse Tutorials](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/tutorials.html)

## Acknowledgements

- **Author**- Nicholas Cusato, Santa Monica Specialists Hub
- **Contributers**- Rodrigo Mendoza, Ethan Shmargad, Thea Lazarova
- **Last Updated By/Date** - Nicholas Cusato, September 2022