<!-- Updated September 11th, 2022 -->

# Low code development with advanced textual analysis in ATP


## Task 2: Create a compartment

1. Compartments are the primary means to organize, segregate, and manage access to OCI resources.  Every tenancy has a root compartment under which you create additional sub-compartments and sub-sub compartments (maximum six levels deep).  Compartments are tenancy-wide across regions. When you create a compartment, it is available in every region that your tenancy is subscribed to. You can get a cross-region view of your resources in a specific compartment with the tenancy explorer. See [Viewing All Resources in a Compartment](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/compartmentexplorer.htm#Viewing_All_Resources_in_a_Compartment).  We will create a compartment called **CareClinics** for this course/workshop and create all related services in this compartment.  Navigate to the menu in the upper left and select Identity and Security, and then Compartments.

    ![Navigate to Identity and Security](./images/task-2/identity-security.png " ")

    ![Navigate to Compartments](./images/task-2/compartments.png " ")

    Create the new compartment.

    ![Create new Compartment](./images/task-2/new-compartment.png " ")

    ![Name the new Compartment and Create](./images/task-2/compartment-name.png " ")


## Task 3: Create autonomous transaction processing database
1.  Login to your Oracle Cloud Tenancy and open the side menu

    
    ![Welcome to the OCI Dashboard](./images/task-3/oci-dashboard.png  " ")

2.  Navigate Autonomous Transaction Processing

    
    ![Autonomous Transaction Processing](./images/task-3/autonomous-database.png  " ")

3.  Select the correct compartment (Ex: Care Clinic) and click **Create an Autonomous Database**

    
    ![Create ATP Database](./images/task-3/initial-create-database.png  " ")

4.  Give a preferred Display Name (Ex: CareClinicsDB) and click **Transaction Processing** for the workload type

    
    ![Give new Database a preferred Display Name](./images/task-3/input-display-name.png " ")

5.  Create the ADMIN password for the DB, following the database password requirements. Leave everything else as default

    **Note:** Make sure to save this password, you will need it later in this lab

    
    ![Set Admin Password](./images/task-3/set-password.png  " ")

6.  Click **Create Autonomous Database**

    
    ![Create Autonomous Database](./images/task-3/create-database.png  " ")

7.  Database provisioning will take about 5 minutes. Once the Lifecycle State is ***Available***, you can continue to the next task

    
    ![Database Provisioning](./images/task-3/database-provisioning.png " ")

## Task 4: Create an APEX workspace
1.  Under Tools, click **Oracle APEX**

    
    ![Navigate to Oracle APEX](./images/task-4/open-apex.png " ")

2.  Enter ADMIN password (Step 5) and sign in

    
    ![Open the Admin Console](./images/task-4/admin-console.png " ")

3. Create a new Workspace

    
    ![Create a new Workspace](./images/task-4/create-workspace.png " ")

4. Create a Database User and new password for this user (Ex: CareClinic)

    **Note:** Make sure to save this database user/password, you will need it later

    
    ![Create a new Database User](./images/task-4/create-database-user.png " ")

5. After creating the workspace, click **CARECLINIC** to sign out of the admin(internal) workspace and into the workspace that you have just created

    
    ![Sign out of Admin Workspace](./images/task-4/navigate-new-workspace.png " ")

## Task 5: Upload sample data 

1. Enter password for new database user (Ex: CareClinic) and sign into the workspace

    
    ![Sign into the New Workspace](./images/task-5/new-workspace.png " ")

2. This is the oracle apex workspace running on the database you created earlier. Let's visit the SQL Workshop!

    
    ![Navigate to SQL Workshop](./images/task-45/workspace-home.png " ")

3. Inside the SQL Workshop > Object Browser to view any objects in the database. 

    **Note:** It should be empty i.e no tables currently in the database. Uploading a DDL script will create the table structure you need, and then you can inset the data from .csv files

    
    ![Object Browser](./images/task-5/object-browser.png " ")

4. Go to SQL Scripts and upload the contents of the [file](https://objectstorage.us-ashburn-1.oraclecloud.com/p/jyHA4nclWcTaekNIdpKPq3u2gsLb00v_1mmRKDIuOEsp--D6GJWS_tMrqGmb85R2/n/c4u04/b/livelabsfiles/o/labfiles/Create_Tables.sql). This will build the table structure of the tables required. 


    
    ![Navigate to SQL Scripts](./images/task-5/sql-scripts.png " ")

5. Upload the script

    
    ![Upload the SQL Script](./images/task-5/upload-sql-script.png " ")

6. Once uploaded, run the script

    
    ![Run the SQL Script](./images/task-5/run-script.png " ")

7. Ensure the statements are processed with no errors 
    
    ![Script Processed](./images/task-5/script-processed.png " ")

8. Return to the object browser. You are now able to view all 8 tables that were just created in the object browser. Now you will need to upload the data into them

    
    ![Tables have been created](./images/task-5/tables-created.png " ")

9. Click **Load Data** and upload the respective .csv file for HEALTHCARE\_FACILITY. The full data set can be found [here].(https://objectstorage.us-ashburn-1.oraclecloud.com/p/jyHA4nclWcTaekNIdpKPq3u2gsLb00v_1mmRKDIuOEsp--D6GJWS_tMrqGmb85R2/n/c4u04/b/livelabsfiles/o/labfiles/CareClinicData.zip)

    
    ![Load Data into HealthCare Facility Table](./images/task-5/load-data-1.png " ")

10. Repeat this step for 5 more tables. All settings can be left as default. (Exclude the **PATIENT\_DOCUMENTS** and the **PATIENT\_INSURANCE** tables)

    **Note:** After each load, click view table to return to the object browser

    ![Loading Data into Tables](./images/task-5/load-data-2.png " ")­­

11. There should now be data in 6/8 tables

    
    ![View Data](./images/task-5/view-data.png " ")

12. Let's create a new application using the Healthcare\_Facility Table

    
    ![Create new application](./images/task-5/create-new-application.png " ")

13. Give your application a name, and click create application. Delete dashboard page by clicking edit and deleting that entry. You can leave everything else as default!

    
    ![Name your application](./images/task-5/application-name.png " ")

14. Run the application and sign in with your database user (Step 11)!

    
    ![Run your new application](./images/task-5/run-application.png " ")

15. These are two sample pages created for you that show the **Health Care Facility** table. Let's click Application 100 and create a page to upload our sample documents to our **Patients Documents** Table

    
    ![Default Application Pages](./images/task-5/default-pages.png " ")

## Task 6: Add pages to application

1. Create new Page!

    **Note:** This is on version APEX 22.1, it may look slightly different to the current version

    
    ![Create new application page](./images/task-6/new-page.png " ") 

2. Select **Classic Report**

    
    ![Select Classic Report](./images/task-6/classic-report.png " ")

3. Select **Include Form Page** and give both the classic report and form page unique names. Select the source for this report as the **PATIENT\_DOCUMENTS** table

    **Note:** Its important to note that the report and form are being created on pages 5 and 6 respectively. These will be referenced later in this lab.

    
    ![Set Classic Report Attributes](./images/task-6/classic-report-attributes.png " ")

4. Keep the Primary Key Column as ID(Number)

    
    ![Set Primary Key](./images/task-6/set-primary-key.png " ")

5. Let's hide some columns we do not want showing in the report. You can Ctrl/Cmd+Click these columns and change their type to Hidden Column

    
    ![Hide Report Columns](./images/task-6/hide-report-columns.png " ")

6. Select the DOCUMENT Column and in the right side panel change the **Mime Type**, **Filename Column**, and **Last Updated Column** to match the columns in our **Patient\_Documents** table!

    **Note:** Don't forget to save!

    
    ![Update Document Column for Report](./images/task-6/update-document-column.png " ")

7. You will need to repeat the same steps for the form page (Page 6). Change the unwanted columns to type **Hidden**

    
    ![Hide Form Columns](./images/task-6/hide-form-columns.png " ")

8. Select the **P6\_Documents** page item, and change the **MIME Type Column**, **Filename Column**, and **BLOB Last Updated Column**, and Save. 

    **Note:** You will need to type these out to match exactly to the database columns.

    
    ![Update Document Column for Form](./images/task-6/update-document-column-form.png " ")

9. Let's create a Popup LOV on our **P6\_PATIENT\_VISIT\_ID**. This will help you assign the correct **Patient Visit ID** for the documents you are going to upload.

    
    ![Change type to Popup LOV](./images/task-6/create-popup-lov.png " ")

10. Scroll down and change the Type to **SQL Query** and add this query under. 
 
    ```
    <copy>
    Select PV.PATIENT_VISIT_ID || ' - ' || P.FIRST_NAME || ' ' || P.LAST_NAME d, PATIENT_VISIT_ID r from PATIENT_VISIT PV, PATIENT P where PV.PATIENT_ID = P.PATIENT_ID
    </copy>
    ```

    
    ![Define List of Values](./images/task-6/define-list-query.png " ")

11. Go back to Page 5 and run the application 

    **Note:** Modal Pages cannot be run directly from the page designer, for example Page 6

    
    ![Run the application to view changes](./images/task-6/view-application-changes.png " ")

12. Sign into the application, if prompted, and click **Create** to inset new record into Patient\_Documents Table. All sample documents can be found [here] (https://objectstorage.us-ashburn-1.oraclecloud.com/p/jyHA4nclWcTaekNIdpKPq3u2gsLb00v_1mmRKDIuOEsp--D6GJWS_tMrqGmb85R2/n/c4u04/b/livelabsfiles/o/labfiles/Patient_Documents.zip)

    
    ![Test Document Upload](./images/task-6/test-pdf-upload.png " ")

13. Upload all 6 PDF documents ensuring that the **Patient Visit ID** matches the document name that is being uploaded

    
    ![Upload all 6 sample documents](./images/task-6/upload-samples.png " ")

14. Now there will be 6 documents in the Patient\_Document Table. 

    
    ![Verify Documents Uploaded Properly](./images/task-6/documents-uploaded.png " ")

15. This will also be reflected in the SQL Workshop -\> Object Browser -\> Patient\_Document !

    
    ![View Table in Object Browser](./images/task-6/view-data-object-browser.png " ")

## Task 7: Explore Oracle Text

1. Return to the Cloud Console, and inside the ATP DB you created, click **Database Actions**

    
    ![View your cloud console](./images/task-7/view-cloud-console.png " ")

2. Click Database Users!

    
    ![Navigate to Database Users](./images/task-7/database-users.png " ")

3. Edit the new user you have created Ex: CareClinic

    
    ![Edit the new user](./images/task-7/edit-new-user.png " ")

4. Under Granted Roles, search for "CTX" and check "CTXAPP" and apply changes

    
    ![Grant User CTXAPP Role](./images/task-7/grant-user-roles.png " ")

5. In order to verify the role was granted, return to Database Actions

    
    ![Navigate to Database Actions](./images/task-7/database-actions.png " ")

6. Under Development, click **SQL**

    
    ![Navigate into SQL Web Developer](./images/task-7/sql-developer.png " ")

7. Execute the following query, ensuring to change the statement to match your database user that was created in Task 2 

    ```
     <copy>
    Select * From DBA_ROLE_PRIVS WHERE GRANTEE = 'CARECLINIC';
     </copy>
    ```

    
    ![Execute SQL Query](./images/task-7/execute-sql-query.png " ")

8. Return to **Database Actions**, and click into **Database Users**. Enable REST on the Database User you created by clicking the more actions and enabling rest

    
    ![Enabling Rest for new Users](./images/task-7/enable-rest-1.png " ")

9. Open a new window by clicking below and sign in with the user that was created (Step 11)

    
    ![Switch Database Users](./images/task-7/switching-db-users.png " ")

10. Open SQL Web Developer

    
    ![Navigate to SQL Web Developer](./images/task-7/navigate-sql-web-developer.png " ")

11. Enable REST on both **PATIENT** and **PATIENT\_INSURANCE** tables by right clicking them. Leave all settings as default!

    
    ![Enable REST for Tables](./images/task-7/enable-rest-1.png " ")

12. Ensure are both tables now have REST Enables, you will need this later for the other labs

    
    ![Verify Last Step](./images/task-7/verify-rest-enabled.png " ")

13. Now visit the APEX workspace. Go to **SQL Commands** under SQL Workshop

    
    ![Visit SQL Commands](./images/task-7/sql-commands.png " ")

14. Create an Index on the Patient\_Documents Table, where the visit summaries are stored

    ```
     <copy>
    CREATE INDEX searchMyDocs ON Patient_Documents(Document) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('DATASTORE CTXSYS.DEFAULT_DATASTORE FILTER CTXSYS.AUTO_FILTER FORMAT COLUMN MIMETYPE sync (every "freq=secondly;interval=60")')
     </copy>
    ```

    
    ![Index Patient Document Table](./images/task-7/create-auto-index.png " ")

15. Run the following query utilizing Oracle Text. Oracle Text returns all documents (previously indexed) that satisfy the expression along with a relevance score for each document. You can use the scores to order the documents in the result set. If you would like to read more about Oracle Text, more information can be found <a href="https://docs.oracle.com/en/database/oracle/oracle-database/21/ccapp/understanding-oracle-text-application-development.html#GUID-CF13C01A-F5E6-4EF5-839B-C09CF0024D5E">here</a>

    In this first example we are looking for all documents who have the work MRN inside the after visit summary. The CONTAINS operator must always be followed by the > 0 syntax, which specifies that the score value returned by the CONTAINS operator must be greater than zero for the row to be returned.

     ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY  FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, 'MRN', 1) > 0;
     </copy>
    ```

    
    ![Run Basic Query](./images/task-7/base-query.png " ")

16. Find all documents that have the word ABC with a score \> 1 and also contains the word Medical Center.

    ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, '(ABC > 1) and Medical Center', 1) > 0;
     </copy>
    ```

    
    ![Document Query - Double Word Search](./images/task-7/abc-medicalcenter.png " ")

17. This is a proximity search to look for the word ADULT near the word EXERCISES

    ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, 'near((ADULT, EXERCISES), 5)', 1) > 0;
     </copy>
    ```

    
    ![Proximity Search](./images/task-7/proximity-search.png " ")

18. Fuzzy Search on a term, this gives the ability to find the work medications in the document without correct spelling. !

    ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, '?medicatis\', 1) > 0;
     </copy>
    ```

    
    ![Fuzzy Search](./images/task-7/fuzzy-search.png " ")

19. Soundex Search on a term, giving the ability to find words that sound like the term provided, in this case "pressure". 

     ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, '!prissuer', 1) > 0;
     </copy>
    ```

    
    ![Soundex Search](./images/task-7/soundex-search.png " ")

20. Stem search on a term. For example if we are looking for documents with that stem of Journal, then it will return words like "journaling"

     ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, '$journal', 1) > 0;
     </copy>
    ```

    
    ![Stem Search](./images/task-7/stem-search.png " ")

21. Accumulation Search on two or more terms. This is looking for both terms in the document and assigning a score. Higher if both terms are present.!

     ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, 'medications ACCUM Medical', 1) > 0 order by Score(1) desc;
     </copy>
    ```

    
    ![Accumulation Search](./images/task-7/accumulation-search.png " ")

22. You can also weight each term as seen here. The word physical carries 3x the weight of the work exercises. 

    ```
     <copy>
    SELECT SCORE(1), ID,PATIENT_VISIT_ID,  TITLE, CREATED_BY   FROM PATIENT_DOCUMENTS WHERE CONTAINS(DOCUMENT, 'exercises ACCUM physical*3', 1) > 0 order by score(1) desc;
     </copy>
    ```

    
    ![Weighted Accumulation Search](./images/task-7/weighted-accumulation-search.png " ")

23. Those are some of the basic queries within Oracle Text. 

    Construct Themes Tables: To build themes for your documents you will first need to create a table to hold the themes. Run each statement individually by highlighting the the statement then click Run.

    ```
    <copy>
    create table themes (query_id number, theme varchar2(2000), weight number);
    </copy>
    ```
  
   ![Creating Themes Table](./images/task-7/themes-table.png " ")

24. Create Themes index for the documents currently in the PATIENT\_DOCUMENTS table

    ```
    <copy>
    begin
	for x in (select ID from PATIENT_DOCUMENTS) loop
    ctx_doc.themes ('searchMyDocs', x.ID, 'themes', x.ID, full_themes => false);
    end loop;
    end;
    </copy>
    ```

    
    ![Create Themes Index](./images/task-7/themes-index.png " ")

25. Query all themes. Show all themes with weight over 25

    ```
     <copy>
	select r.title, r.filename, t.theme, t.weight from PATIENT_DOCUMENTS r, themes t
    where r.id = t.query_id and weight > 25
    order by id asc;
     </copy>
    ```

    
    ![Query Themes Table](./images/task-7/query-themes.png " ")

26. Repeat for the Gist Table. 

    **Note:** Run each of the 3 statements individually

    ```
     <copy>
	create table gists (query_id  number, pov  varchar2(80), gist  CLOB);
     </copy>
    ```
    ```
    <copy>
	begin
	for x in (select ID from PATIENT_DOCUMENTS) loop
    ctx_doc.gist('searchMyDocs', x.ID, 'gists',x.ID,'P', pov =>'GENERIC');
    end loop;
    end;
     </copy>
    ```
    ```
     <copy>
	select * from gists;
     </copy>
    ```
    
    ![Create Gist Table and Index](./images/task-7/gist-table.png " ")

27. Repeat for the Filtered Docs Table

    **Note:** Run each of the 3 statements individually

    ```
     <copy>
    create table filtered_docs(QUERY_ID number, DOCUMENT clob);
     </copy>
    ```
    ```
    <copy>
	begin
	for x in (select ID from PATIENT_DOCUMENTS) loop
    	ctx_doc.filter ('searchMyDocs', x.ID, 'filtered_docs', x.ID, plaintext => true);
    end loop;
    end; 
     </copy>
    ```
    ```
    <copy>
	select r.title, f.document as "Plain Text Summary" from PATIENT_DOCUMENTS r, filtered_docs f
    where r.ID = f.query_id
     </copy>
    ```

    
    ![Create Filtered Docs Table and Index](./images/task-7/filtered-docs.png " ")

28. Finally repeat for the Full Themes tables
    
    **Note:** Run each of the 3 statements individually

    ```
    <copy>
    create table full_themes( QUERY_ID	number, THEME   varchar2(2000),WEIGHT   NUMBER);
    </copy>
    ```
    ```
    <copy>
	begin
	for x in (select ID from PATIENT_DOCUMENTS) loop
    	ctx_doc.themes ('searchMyDocs', x.ID, 'full_themes', x.ID, full_themes => true);
    end loop;
    end; 
    </copy>
    ```
    ```
    <copy>
	select r.title, r.filename, t.theme, t.weight from PATIENT_DOCUMENTS r, full_themes t
    where r.ID = t.query_id
    order by ID asc;
    </copy>
    ```

    
    ![Create Full Themes Table and Index](./images/task-7/full-themes.png " ")

29. We can verify all 4 tables were created by visiting the Object Browser

    
    ![Verify Tables in object browser](./images/task-7/verify-tables-created.png " ")

## Task 8: Implement Oracle Text for End Users

1. Now let's create a new page to let end users view document gists with 1 click. Create Page, and select **Classic Report**

    
    ![Create Classic New Report for Gist ](./images/task-8/create-classic-report.png " ")

2. Give the Classic Report a name, and select Modal Dialog, this will allow the page to be a pop-up instead of a redirect. Finally select the source as SQL Query and enter the query as shown

    ```
    <copy>
	select * from gists where query_id = :P7_QUERY_ID;
    </copy>
    ```
    **Note:** Ensure that this new page is page number 7 in-order for the query to populate properly

    ![Document Gist Creation](./images/task-8/document-gist-creation.png " ")

3. On the new page, rename the Title of the content body on the right pane to 
    **&P7_Title. Gist**.
    Create two page items, **P7\_QUERY\_ID** and **P7\_TITLE**, by right-clicking on the content body region, and selecting **Create Page Item**

    
    ![Adding Page New Items](./images/task-8/page-7-gist-1.png " ")

4. Set the Type of both new page items to **Hidden**

    
    ![Hide Page Unwanted Page Items](./images/task-8/page-7-gist-2.png " ")

5. Save and return to page 5 by using the page navigation. Right-Click Columns and **Create Virtual Column** on your report

    
    ![Create a Virtual Column](./images/task-8/create-virtual-column.png " ")

6. While Selecting the new virtual column you created, change the Heading to **Document Gist**. Under Link, click **No Link Defined** to define a new link for this virtual column. Set the link to page 7. Under Set Items, ensure you add both **P7\_Query\_ID** and **P7\_TITLE**, with values of **\#ID\#** and **\#TITLE\#** respectively. Note: Use the menu to the right of the text box makes this easier.

    
    ![Creating Column Link](./images/task-8/gist-column-link.png " ")

7. Add a Link Text by expanding the menu and selecting any of the default options shown.

    
    ![Create A Link Text for New Column](./images/task-8/link-text.png " ")

8. Save and Run the application. Test this new feature by clicking on the pencil icon under Document Gist.

    
    ![Save and Run your Application](./images/task-8/test-gist-link-1.png " ")

9. You now have a gist of the PDF documents with just one click. Now lets see how we can replicate this to add Filtered Docs in plain text to the table as well.

    
    ![View the Modal Page you have created](./images/task-8/test-gist-link-2.png " ")

10. Navigate to Page 7 using the development tool bar below. Choose the "+" icon and select Page as Copy. Select **Page in this application**

    
    ![Create a Page Copy](./images/task-8/page-copy-1.png " ")

11. Select the new page as page 8, and provide a new page name. On the next page select **Do not associate with a navigation menu entry**

    
    ![Enter new Classic Report Attributes](./images/task-8/page-copy-2.png " ")

12. Give the Page Region a new name and copy

    
    ![Name the new Region Copy](./images/task-8/region-copy.png " ")

13. You now have a new page (Page 8) where you can alter the SQL query to reflect that of Full Text. Let's create another virtual column link to this page

    ```
    <copy>
	select r.title, f.document as "Plain Text Summary" from PATIENT_DOCUMENTS r, filtered_docs f
    where r.ID = f.query_id and f.query_id = :P8_QUERY_ID;
    </copy>
    ```

    ![Update SQL Query](./images/task-8/full-text-query.png " ")

14. Save and return to Page 5. Right- Click columns and Create Virtual Column

    
    ![Create a Virtual Column](./images/task-8/second-virtual-column.png " ")

15. Make changes similar to before in step 6. Set the link to page 8. Under Set Items, ensure you add both **P8\_Query\_ID** and **P8\_TITLE**, with values of **\#ID\#** and **\#TITLE\#** respectively.

    
    ![Create Column Link](./images/task-8/virtual-column-link.png " ")

16. Change the link text to a default icon. Save and run the page

    
    ![Change Column Link Icon](./images/task-8/full-text-icon.png " ")

17. By clicking the magnifying glass icon we can see the full text for that individual document

    
    ![View Application Changes](./images/task-8/completed-application.png " ")

Congratulations! You have successfully completed this lab.








