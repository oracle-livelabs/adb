# Create a Database User

## Introduction

This lab can be run by any database user providing that the user has the required privileges.  A user can be created with a few simple commands.

Estimated Time:  Less than 5 minutes.

### Objectives

In this lab you will:

- Create a database user.

### Prerequisites:

- Complete the previous lab.

## Task 1 - Create Database User

To create the database user for this lab.

1. Using SQL Worksheet, connect to the database using the **ADMIN** user.
2. Run the following commands. You may make substitutions for the username and password.

~~~SQL
<copy>
CREATE USER moviestream IDENTIFIED BY Welcome#1234 QUOTA UNLIMITED ON DATA;
GRANT dwrole, connect, resource TO moviestream;
BEGIN
    ords.enable_schema(p_schema => 'MOVIESTREAM');
END;
/
</copy>
~~~


The DWROLE, CONNECT and RESOURCE roles are the minimum set of roles needed to use this workshop.  Enabling the user (schema) for ORDS allows the user to access the Database Actions tools.

Note that it is also possible to create users and grant them roles from the **Administration - Database Users** section of Database Actions.

You may now **proceed to the next lab**

## Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous AI Database, February 2023
- Last Updated By - Mike Matthews, November 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
