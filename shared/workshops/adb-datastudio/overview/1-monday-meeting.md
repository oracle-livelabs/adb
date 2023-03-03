# Introduction

Let's go through "a life in a day" of a data analyst. We will start with a fictious team who is assigned a task. We will learn how Data Studio helps in completing the task objectives.


## Meeting notes from the weekly marketing team meeting

Date: Monday 1-09-2023
Attendees: All team members

Patrick wants to send discount offers to high value customers every
week. He also wants movie genre preference based on age groups and
marital status. It is also interesting to know whether these preferences
are different across high value and low value customers.

### Brainstorming:

Bud suggested creating five equal quintiles for customers based on movie
purchases made by a customers. 
We could then send offers only to top quintile customers.

Everyone agreed it is the right strategy.

### Where is the data?

Everyday sales data is being loaded to the object store bucket. Ashish
is going to setup a live feed from object store to **MOVIESALES_CA**
table. This table will have timestamped sales data. There are tables for
customer and movie genre as well.\
(note to myself: confirm the table name. Also livefeed sounds
interesting. Learn how he sets it up in the future).

## TODO:

### Data load:

Check for **MOVIESALES_CA** and other tables needed for this analysis and 
load any additional data needed.

### Data Prep:

Create data flow to aggregate movie sales and
populate quintile column. Schedule this to load every Sunday 9pm.

Also add denormalized columns needed for analysis to this table for
analyzing data. This table should have all the attributes needed for
analysis.

### Analyze:

Create Analytic View to analyze sales data by various dimensions such as
age group, genre, marital status etc.

### Insight:

Is there anything more we learn from the data?