### Load Data from Local Files

   **Important: **  Your computer may not support downloading files to your local disk. If you are in this situation, please skip forward to next main section **Load Data from Object Store.**

### Preparation

Below are the files that you will be using during this part of the workshop. Before you can begin, you need to download these files to your local computer and make a note of where they are stored, because you will need to use them later in this section. Click each of the links below to download the files.

- Click **[here](https://objectstorage.us-phoenix-1.oraclecloud.com/n/dwcsprod/b/MovieStream-QTEAM-Download/o/Days_Months.xlsx)** to download the **Days\_Months.xlsx** Excel file to your local computer.
- Click **[here](https://objectstorage.us-phoenix-1.oraclecloud.com/n/dwcsprod/b/MovieStream-QTEAM-Download/o/Devices.xlsx)** to download the **Devices.xlsx** Excel file to your local computer.
- Click **[here](https://objectstorage.us-phoenix-1.oraclecloud.com/n/dwcsprod/b/MovieStream-QTEAM-Download/o/Countries.csv)** to download the **Countries.csv** CSV file to your local computer.

    > **Note:** This file might just appear as new tab in your browser rather than just simply downloading. Please use the Save or Save As feature in your browser's File menu to save the file as **Countries.csv**, and *make a note of where you saved it*!

**Before you proceed -**  be sure to take note of the location of the three files that you downloaded to your local computer.

3. To load the files from your local computer, you need to click on the first card in each of the first two rows of cards (in row one - **LOAD DATA** and row two - **LOCAL FILE** ) which will mark each box with a blue tick in the bottom right corner. To move forward to the next step in this process, simply click the blue **Next** button.
  ![Load local files](images/load-local.png)
4. This is where you need to locate the three files (Countries.csv, Days_Months.xlsx and Devices.xlsx) that you downloaded earlier! If they are easily accessible, then you can simply drag **ALL THREE** files at one time, and drop them onto to canvas as stated in the text on the screen.
  ![Drag/Choose local files on the canvas](images/upload.png)
5. An alternative approach is to click **Select Files** button in the middle of the screen, which will open the file explorer on your local computer where you can locate your data files: Countries.csv, Days\_Months.xlsx, and Devices.xlsx.
    >**Note:** Even though you only picked three files, four cards will appear for the data TARGETS to be loaded.

  ![Data load cards for files](images/2879071275.png)
  Why do you have  ***four***  cards listed on the data loading screen? This is because your spreadsheet file **Days\_Months.xlsx** contains two worksheets: one for Days and one for Months. The data loading wizard automatically parsed your spreadsheet and created a separate data loading card for each worksheet. 
  ![Excel multiple workbooks](images/2879071187.png)

6. Before you load any data, let's review what the data loading wizard has discovered about the data within your data files. Let's focus on the **Countries.csv** file. Click the **pencil icon** on the right side of the card to inspect the data loading properties:
  ![Edit data load property for countries](images/inspect-countries.png)
7. In the bar on the left, there are links for Settings, File, Table, and an Error Log. This screenshot shows the **Settings** page. Observe that this shows the structural information and intelligent default values that data wizard has created from simply looking at the file.
  ![Data load settings for countries](images/data-load-settings.png)
8. How does it do this? Most csv files contain structural information about the data within the file in the first row. Notice that there is a tick box selected, **Get from file header**.
  ![Get field names from file header](images/get-from-file-header.png)
9. This has allowed the data loading wizard to discover that your data file contains two columns of data: **COUNTRY** and **CONTINENT**. The default table name has based derived from the filename. Click the drop-down menu under **Option.**
  ![Table options](images/option.png)
10. Notice that various operations are supported. For this part of the lab, accept the default option,  **Create Table**.

  > **Note:**  This wizard creates the table for you during the data load process! Notice also that the wizard has automatically mapped the columns. Column mapping looks sensible, both in terms of column names and data types.

11. Click **Close**  in the bottom right to return to the Data Load card and then click the **green button** in the menu panel to start the Data Load job.
  ![Run data load job](images/green-button.png)
  The time taken to load each file depends on factors including file size and network speed. The progress of the job can be monitored from the status bar and the ring to the left of each job card. When the ring is complete, the file has uploaded successfully.
  ![Data load progress](images/loading.png)

Now let's inspect the tables that were automatically created during the data load process.

### Inspect Your New Data

12. You can use the Catalog tool to view the entities in your schema. You can use the navigation menu on the left side to switch between the various Data tools available.
13. Click the **Catalog** button on the left navigation pane.
  ![Launch the Catalog tool](images/launch-catalog.png)
14. This brings up a list of Entities in this schema of the Autonomous Database. At this stage, locate the **COUNTRIES** table you just loaded.
  ![Data Catalog explore tables](images/explore-tables.png)
15. Click the table **COUNTRIES** and a data preview panel will appear that will allow you to review the data you just loaded. Note that this is a relatively simple table containing a list countries and their continents.
![Explore ountries table](images/countries-data.png)
16. Click the **Close** button in the bottom right corner.

### RECAP: Loading Data from Local Files

In this part of the workshop, you used the new data loading tool to quickly load data into your data warehouse from three local data files simply by dragging and dropping them onto the Data Load canvas. One file was in CSV format and the other two were Excel spreadsheets. One of the spreadsheets contained two worksheets and each one was loaded into its own table. The data loading process automatically created a target table containing the appropriate column structures based on the data within each file.

In a few clicks, you were able to define and load data into four new tables without having to write any SQL code. It was all done with a few mouse clicks.