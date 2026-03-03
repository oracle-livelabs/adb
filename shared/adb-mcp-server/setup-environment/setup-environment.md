# Set up Your Workshop Environment

<!---
comments syntax
--->

## Introduction

This lab focuses on teaching you how to setup your Autonomous AI Database for the workshop.



Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Provision your Autonomous AI Database instance
* Create Autonomous AI Database Users as ADMIN
* Login as schema users and create Human Resource and Sales data


## Task 1: Create the Autonomous AI Database Instance
[](include:adb-provision-body.md)

## Task 2: Create Autonomous AI Database Users
To create a user:
1. If you are not already signed in, sign into your OCI account, click the cloud menu on the left to open the left navigation pane, and click **Oracle AI Database**. On the right, click **Autonomous AI Database**.
    ![Create Autonomous AI Database](./images/select-adb.png =70%x*)

2. Click the Oracle Autonomous AI Database that you have provisioned for this workshop. Here, click the instance `Training-Database`.
    ![Click Training-Database](./images/click-dbinstance.png =70%x*)

3. On the Autonomous AI Database details page, click **Database Actions**, and then select the **SQL** option.
    ![Select SQL](./images/db-actions-sql.png =70%x*)

4. Before you get to the Oracle Database Actions Launchpad page, you might be asked to log in, depending on the browser you are using. If this is the case make sure to enter `ADMIN` and the password you gave the administrator user.
5. In the SQL Worksheet, copy and paste the following code:
    ```
    <copy>
    CREATE USER hrm_user IDENTIFIED BY QwertY#19_95;
    GRANT DWROLE TO hrm_user;
    ALTER USER hrm_user QUOTA UNLIMITED ON users;

    CREATE USER sales_user IDENTIFIED BY QwertY#19_95;
    GRANT DWROLE TO sales_user;
    ALTER USER sales_user QUOTA UNLIMITED ON users;
    </copy>
    ```
6. Click **Run Script**.


## Task 3: Enable ORDS REST Endpoint to the Schema Users
To enable ORDS endpoint to the schema users:

1. Go back to the database instance details page and click **Database Actions** -> **Database Users**.
    ![Select Database Users](./images/db-actions-db-users.png =70%x*)

2. On the User Management page, locate `HRM_USER`. Click the three dots (⋮) next to the user name and click **Enable REST**. 
    ![Enable REST endpoint for `HRM_USER`](./images/db-actions-db-user-enable-rest.png =70%x*)

3. Review the **REST Enable User** dialog and click **REST Enable User**. 
    ![Click REST Enable User](./images/db-actions-db-user-rest-enable-user.png =70%x*)

4. A confirmation dialog displays. Click **X** to close it.

5. Repeat steps 2, 3, and 4 for the `SALES_USER`.


## Task 4: Create HR Tables and Data

1. Go back to the Database Actions tab and on the Database Actions screen, open the user menu. Click **Sign Out**.
    ![Click Sign Out on the User menu](./images/db-actions-sql-signout.png =70%x*)

2. Login as the schema user (`HRM_USER`) and password (`QwertY#19_95`) on the Sign-in page.
    ![Login as `HRM_USER`](./images/db-actions-sql-signin.png =70%x*)
    
3. In the Database Actions Launchpad screen, click **SQL**. 
    ![Click SQL](./images/db-actions-launchpad-sql.png =70%x*)

4. In the SQL Worksheet, copy and paste the following code to create Human Resource related data:

    ```
    <copy>
    CREATE TABLE departments (
        department_id NUMBER PRIMARY KEY,
        department_name VARCHAR2(100) NOT NULL,
        location VARCHAR2(100)
    );

    INSERT INTO departments VALUES (1, 'Human Resources', 'New York');
    INSERT INTO departments VALUES (2, 'Engineering', 'San Francisco');
    INSERT INTO departments VALUES (3, 'Finance', 'New York');
    INSERT INTO departments VALUES (4, 'Sales', 'Chicago');
    INSERT INTO departments VALUES (5, 'IT Support', 'Austin');

    CREATE TABLE roles (
        role_id NUMBER PRIMARY KEY,
        role_name VARCHAR2(100) NOT NULL
    );

    INSERT INTO roles VALUES (1, 'HR Manager');
    INSERT INTO roles VALUES (2, 'Software Engineer');
    INSERT INTO roles VALUES (3, 'Senior Software Engineer');
    INSERT INTO roles VALUES (4, 'Finance Analyst');
    INSERT INTO roles VALUES (5, 'Sales Executive');
    INSERT INTO roles VALUES (6, 'IT Support Engineer');
    INSERT INTO roles VALUES (7, 'Engineering Manager');
    INSERT INTO roles VALUES (8, 'Accountant');


    CREATE TABLE employees (
        employee_id NUMBER PRIMARY KEY,
        first_name VARCHAR2(50),
        last_name VARCHAR2(50),
        email VARCHAR2(100) UNIQUE,
        hire_date DATE,
        department_id NUMBER,
        role_id NUMBER,
        manager_id NUMBER,
        salary NUMBER(10,2),

        CONSTRAINT fk_emp_dept FOREIGN KEY (department_id)
            REFERENCES departments(department_id),

        CONSTRAINT fk_emp_role FOREIGN KEY (role_id)
            REFERENCES roles(role_id),

        CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id)
            REFERENCES employees(employee_id)
    );

    INSERT INTO employees VALUES
    (1001,'Alice','Johnson','alice.johnson@corp.com',TO_DATE('2016-02-15','YYYY-MM-DD'),1,1,NULL,98000);

    INSERT INTO employees VALUES
    (1002,'Mark','Williams','mark.williams@corp.com',TO_DATE('2015-06-10','YYYY-MM-DD'),2,7,NULL,150000);

    INSERT INTO employees VALUES
    (1003,'Emma','Davis','emma.davis@corp.com',TO_DATE('2017-09-01','YYYY-MM-DD'),3,8,NULL,105000);

    INSERT INTO employees VALUES
    (1004,'James','Wilson','james.wilson@corp.com',TO_DATE('2018-01-20','YYYY-MM-DD'),4,5,NULL,95000);

    INSERT INTO employees VALUES
    (1005,'Daniel','Martinez','daniel.martinez@corp.com',TO_DATE('2019-04-18','YYYY-MM-DD'),5,6,NULL,90000);

    INSERT INTO employees VALUES (1101,'John','Smith','john.smith@corp.com',TO_DATE('2020-01-10','YYYY-MM-DD'),2,3,1002,125000);
    INSERT INTO employees VALUES (1102,'Sarah','Brown','sarah.brown@corp.com',TO_DATE('2020-02-12','YYYY-MM-DD'),2,2,1002,95000);
    INSERT INTO employees VALUES (1103,'Michael','Taylor','michael.taylor@corp.com',TO_DATE('2020-03-15','YYYY-MM-DD'),2,2,1002,97000);
    INSERT INTO employees VALUES (1104,'Olivia','Anderson','olivia.anderson@corp.com',TO_DATE('2020-04-18','YYYY-MM-DD'),2,2,1002,98000);
    INSERT INTO employees VALUES (1105,'William','Thomas','william.thomas@corp.com',TO_DATE('2020-05-20','YYYY-MM-DD'),2,3,1002,120000);
    INSERT INTO employees VALUES (1106,'Sophia','Moore','sophia.moore@corp.com',TO_DATE('2020-06-22','YYYY-MM-DD'),2,2,1002,96000);
    INSERT INTO employees VALUES (1107,'Ethan','Jackson','ethan.jackson@corp.com',TO_DATE('2020-07-25','YYYY-MM-DD'),2,2,1002,94000);
    INSERT INTO employees VALUES (1108,'Isabella','White','isabella.white@corp.com',TO_DATE('2020-08-28','YYYY-MM-DD'),2,3,1002,122000);
    INSERT INTO employees VALUES (1109,'Lucas','Harris','lucas.harris@corp.com',TO_DATE('2020-09-30','YYYY-MM-DD'),2,2,1002,93000);
    INSERT INTO employees VALUES (1110,'Mia','Martin','mia.martin@corp.com',TO_DATE('2020-10-15','YYYY-MM-DD'),2,2,1002,94000);

    INSERT INTO employees VALUES (1111,'Noah','Thompson','noah.thompson@corp.com',TO_DATE('2021-01-10','YYYY-MM-DD'),2,2,1002,95000);
    INSERT INTO employees VALUES (1112,'Ava','Garcia','ava.garcia@corp.com',TO_DATE('2021-02-14','YYYY-MM-DD'),2,3,1002,118000);
    INSERT INTO employees VALUES (1113,'Logan','Martinez','logan.martinez@corp.com',TO_DATE('2021-03-18','YYYY-MM-DD'),2,2,1002,96000);
    INSERT INTO employees VALUES (1114,'Charlotte','Robinson','charlotte.robinson@corp.com',TO_DATE('2021-04-20','YYYY-MM-DD'),2,2,1002,97000);
    INSERT INTO employees VALUES (1115,'Benjamin','Clark','benjamin.clark@corp.com',TO_DATE('2021-05-22','YYYY-MM-DD'),2,3,1002,121000);


    INSERT INTO employees VALUES (1201,'Grace','Lee','grace.lee@corp.com',TO_DATE('2020-06-01','YYYY-MM-DD'),1,1,1001,72000);
    INSERT INTO employees VALUES (1202,'Henry','Walker','henry.walker@corp.com',TO_DATE('2021-07-15','YYYY-MM-DD'),1,1,1001,70000);

    INSERT INTO employees VALUES (1301,'Liam','Hall','liam.hall@corp.com',TO_DATE('2019-03-10','YYYY-MM-DD'),3,4,1003,85000);
    INSERT INTO employees VALUES (1302,'Zoe','Allen','zoe.allen@corp.com',TO_DATE('2020-08-12','YYYY-MM-DD'),3,8,1003,88000);

    INSERT INTO employees VALUES (1401,'Ryan','Young','ryan.young@corp.com',TO_DATE('2019-05-20','YYYY-MM-DD'),4,5,1004,80000);
    INSERT INTO employees VALUES (1402,'Natalie','King','natalie.king@corp.com',TO_DATE('2020-11-10','YYYY-MM-DD'),4,5,1004,82000);

    INSERT INTO employees VALUES (1501,'Aaron','Scott','aaron.scott@corp.com',TO_DATE('2021-01-15','YYYY-MM-DD'),5,6,1005,76000);
    INSERT INTO employees VALUES (1502,'Julia','Green','julia.green@corp.com',TO_DATE('2022-02-20','YYYY-MM-DD'),5,6,1005,74000);

    </copy>
    ```
    ![Click Run Script](./images/create-hr-data.png =70%x*)
4. Click **Run Script**.
    ![Click Run Script](./images/create-hr-data-output.png =70%x*)

The data is successfully inserted.

## Task 5: Create Sales Tables and Data

1. On the Database Actions screen, open the user menu. Click **Sign Out**.
2. Login as the schema user (`SALES_USER`) and password (`QwertY#19_95`) on the Sign-in page.
3. In the Database Actions Launchpad screen, click **SQL**. 
    ![Click SQL](./images/db-actions-launchpad-sql.png =70%x*)

4. In the SQL Worksheet, copy and paste the following code to create Sales related data:

    ```
    <copy>
    CREATE TABLE customers (
        customer_id   NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        customer_name VARCHAR2(100),
        email         VARCHAR2(100),
        region        VARCHAR2(50),
        created_date  DATE DEFAULT SYSDATE
    );

    CREATE TABLE products (
        product_id   NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        product_name VARCHAR2(100),
        category     VARCHAR2(50),
        unit_price   NUMBER(10,2)
    );

    CREATE TABLE orders (
        order_id    NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        customer_id NUMBER,
        order_date  DATE,
        status      VARCHAR2(20),
        CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
    );

    CREATE TABLE order_items (
        order_item_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        order_id      NUMBER,
        product_id    NUMBER,
        quantity      NUMBER,
        unit_price    NUMBER(10,2),
        CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
    );

    BEGIN
    FOR i IN 1..20 LOOP
        INSERT INTO customers (customer_name, email, region)
        VALUES (
        'Customer_' || i,
        'customer' || i || '@mail.com',
        CASE MOD(i,4)
            WHEN 0 THEN 'APAC'
            WHEN 1 THEN 'EMEA'
            WHEN 2 THEN 'AMERICAS'
            ELSE 'MEA'
        END
        );
    END LOOP;
    COMMIT;
    END;
    /

    BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO products (product_name, category, unit_price)
        VALUES (
        'Product_' || i,
        CASE
            WHEN i <= 4 THEN 'Electronics'
            WHEN i <= 7 THEN 'Office'
            ELSE 'Accessories'
        END,
        50 * i
        );
    END LOOP;
    COMMIT;
    END;
    /


    BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO orders (customer_id, order_date, status)
        VALUES (
        MOD(i,20) + 1,
        SYSDATE - DBMS_RANDOM.VALUE(1,180),
        CASE MOD(i,3)
            WHEN 0 THEN 'CONFIRMED'
            WHEN 1 THEN 'SHIPPED'
            ELSE 'CANCELLED'
        END
        );
    END LOOP;
    COMMIT;
    END;
    /


    BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (
        MOD(i,50) + 1,
        MOD(i,10) + 1,
        MOD(i,5) + 1,
        (MOD(i,10) + 1) * 50
        );
    END LOOP;
    COMMIT;
    END;
    /

    </copy>
    ```
4. Click **Run Script**.
    ![Click SQL](./images/create-sales-data-output.png =70%x*)

The data is successfully inserted.

You may now proceed to the next lab.

## Learn More

[Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-intro-adb.html)


## Acknowledgements

* **Authors:** Sarika Surampudi, Principal User Assistance Developer
* **Contributors:** Chandrakanth Putha, Senior Product Manager; Mark Hornick, Senior Director, Machine Learning and AI Product Management
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
