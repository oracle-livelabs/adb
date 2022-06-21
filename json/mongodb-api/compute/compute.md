# Provisioning a Compute Node

## Introduction

This lab walks you through the steps to provision a Compute Node. This is where we will run MongoDB utilities to connect to the Autonomous Database.

Estimated Time: 10 minutes


Watch the video below for an overview of the provision a compute node lab.
[Youtube video of lab](youtube:yU3uW5hFNtc)

### Objectives

In this lab, you will:

* Learn how to provision a new Compute Node
* Install MongoDB Shell

### Prerequisites

* Logged into your Oracle Cloud Account

## Task 1: Choose Compute Instances Services Menu

1. Login to the Oracle Cloud.

<if type="freetier">

2. If you are using a Free Trial or Always Free account, and you want to use Always Free Resources, you need to be in a region where Always Free Resources are available. You can see your current default **Region** in the top, right hand corner of the page.

    ![Select region on the far upper-right corner of the page.](./images/region.png " ")

</if>
<if type="livelabs">

2. If you are using a LiveLabs account, you need to be in the region your account was provisioned in. You can see your current default **Region** in the top, right hand corner of the page. Make sure that it matches the region on the LiveLabs Launch page.

    ![Select region on the far upper-right corner of the page.](./images/region.png " ")

</if>

3. Click the navigation menu in the upper left to show top level navigation choices.

    ![Oracle home page.](./images/navigation.png " ")

4. Click on **Compute** and choose **Instances**.

    ![Click Autonomous JSON Database](./images/compute-instances.png " ")

5. Use the __List Scope__ drop-down menu on the left to select a compartment. <if type="livelabs">Enter the first part of your user name, for example `LL185` in the Search Compartments field to quickly locate your compartment.

    ![Check the workload type on the left.](images/livelabs-compartment.png " ")

</if>
<if type="freetier">
   > **Note:** Avoid the use of the ManagedCompartmentforPaaS compartment as this is an Oracle default used for Oracle Platform Services.
</if>

## Task 2: Create the Compute Node

1. Click **Create Instance** to start the instance creation process.

    ![Click Create Autonomous Database.](./images/create-instance.png " ")

2.  This brings up the __Create Instance__ screen where you will specify the configuration of the instance.

3. Provide basic information for the autonomous database:

<if type="freetier">
    - __Choose a compartment__ - Select a compartment for the database from the drop-down list.
</if>
<if type="livelabs">
    - __Choose a compartment__ - Use the default compartment that includes your user id.
</if>
    - __Name__ - Enter a memorable name for the database for the Compute Node. For this lab, use __JSON__.
    - Placement, Image and Shape, and Networking can be left at their default values (but make sure that Assign a public IPv4 address is selected in Networking).

    ![Enter the required details.](./images/compute-info.png " ")

4. Scroll down to the "Add SSH keys" section. Make sure __Generate a key pair for me__ is selected and click __Save Private Key__:

    Your browser will download an ssh key file called "ssh-key-YYYY-MM-DD.key" to your local computer (where YYYY-MM-DD represents the current date). We will need that later so make sure you know where it has been saved.

    ![Save Private Key.](./images/save-key.png " ")

5. Click on __Create__ at the bottom of the screen:

    ![Instance creation.](./images/final-create.png " ")


5.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Running. At this point, your Compute Node is ready for use.

    ![Database instance homepage.](./images/provisioning.png " ")

## Task 3: Check IP address of the Compute Node

1. On the Autonomous Database Details page, Public IP address value. Press the __Copy__ button to copy it to the clipboard, and save it somewhere (write it down or save it in a text file) for later use.

    ![Copy IP address](./images/ip-address.png)

## Task 4: Use the Cloud Shell to connect to your instance

Cloud Shell is a Linux command prompt provided for your user. You can upload files to it and run commands from it.

1. Start the Cloud Shell console by clicking on the square icon with ">" in it at the top right.

	![start cloud shell](./images/open-console.png)

2. The console will open at the bottom of your screen. It may take a minute or so to do so first time round. You should see a Linux command prompt. If you wish, you can expand the console window to fill your browser screen by clicking on the diagonal double-arrow. You can resize the font if needed using your browser's normal zoom operation (e.g. CMD-+ on a Mac)

	![cloud shell](./images/cloud-shell.png)

3. Upload the key file you saved earlier to the cloud shell, and set the right permissions.

    There is an additional menu at the top left of the Cloud Shell window. Open this and select __Upload__.

	![upload button](./images/cloud-shell-upload.png)

    Select the key file ssh-key-YYYY-MM-DD.key that you saved earlier either by dropping it onto the window of using the file selector. Then click the __Upload__ button.

	![upload file](./images/upload-key.png)

    To use ssh you must set the file permissions correctly for the key file. Run the following command (this will set file permissions for all such key files, if there is more than one present):

    ```
	<copy>
    chmod 400 ssh-key-*.key
    </copy>
	```
	![chmod command](./images/chmod.png)

4. Connect to your Compute Node from Cloud Shell

    We can now use ssh to connect to our Compute Node. We will need to know the name of the ssh file we just uploaded, and the IP address of the 
    Compute Node that we saved earlier. Run the following command, altering the file name and IP address (shown as 11.22.33.44) as necessary. 
    "opc" is the pre-installed username for the node and should not be changed. 

    ```
    <copy>
    ssh -i ssh-key-YYYY-MM-DD.key opc@11.22.33.44
    </copy>
    ```

    Answer "yes" when prompted to continue connecting.

    ![Connection](./images/ssh-connect.png)

## Task 5: Download and install MongoDB shell and MongoDB tools

1. On your compute node, enter the following commands to download and install MongoDB Shell

    ```
    <copy>
    wget https://downloads.mongodb.com/compass/mongosh-1.3.1-linux-x64.tgz
    tar -xvf mongosh-1.3.1-linux-x64.tgz
    </copy>
    ```

    ![Download Mongo Shell](./images/mongosh-download.png)

3. Finally set the PATH variable so it includes the mongosh executable.

	The PATH variable must include the 'bin' directory, which you can see in the output from the unzip command. 
    You can set the PATH variable manually, or use the following shell magic to set it up automatically, and add it to the .bashrc startup file for next time you log in to the Compute instance. Make sure to cut and paste this carefully, do not try to retype it, as a mistake here may damage your 
    .bashrc file:

    ```
	<copy>
    echo export PATH=$(dirname `find /home/opc -name mongosh`):\$PATH >> .bashrc && . .bashrc
	</copy>
	```

    If that command doesn't work for some reason, you can use this command instead, but you'll need to re-run it each time you log into the compute instance:

    ```
    <copy>
    # Alternate command - would need to be run each time you log in
    export PATH=/home/opc/mongosh-1.3.1-linux-x64/bin:$PATH
    </copy>
    ```



Our Compute instance is now set up. We will later use it to connect to Autonomous Database. Remember the "ssh" command you used to connect from Cloud Shell to the instance.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Roger Ford, Principal Product Manager, Oracle Database
- **Contributors** - Kamryn Vinson, Andres Quintana
- **Last Updated By/Date** - Roger Ford, March 2022
