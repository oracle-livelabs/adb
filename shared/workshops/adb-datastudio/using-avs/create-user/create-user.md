# Create a Database User

## Introduction

This lab shows how to create a database user using simple SQL commands.  
**Time required: less than 5 minutes.**

### Objectives

You will:

- Create a database user.

### Prerequisites

- Complete the previous lab.

## Task 1 - Create Database User

Follow these steps:

1. Open SQL Worksheet and connect as **ADMIN**.
2. Run the following commands (you may change the username and password):

~~~SQL
<copy>
CREATE USER moviestream IDENTIFIED BY Welcome#1234 QUOTA UNLIMITED ON DATA;
GRANT dwrole TO moviestream;
BEGIN
    ords.enable_schema(p_schema => 'MOVIESTREAM');
END;
/
</copy>
~~~

- `dwrole` is the default role for all users.
- Enabling the schema for ORDS allows access to Database Actions tools.

You can now **proceed to the next lab**.

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, February 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
