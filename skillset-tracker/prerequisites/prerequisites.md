# Install and Prepare Prerequisites

## Introduction

In order to complete the following labs you might need to install some of the following tools, if you don't already have them installed on your local machine.

Estimated Lab Time: 30 minutes

### Objectives
In this lab, you will:
* Install SQL Developer.
* Install and configure OCI CLI to connect to OCI.
* Install and configure Docker.
* Install Kubectl.

**Note**: Only if you are going to run the code locally, you should also:
* Install Visual Studio Code.
* Install NodeJS.
* Install OracleJET Tools.
* Install Oracle Instant Client.

### Prerequisites
To complete this lab, you must have:
* Login to Oracle Cloud account.

## Task 1: Installing SQL Developer

Go to [oracle.com](https://www.oracle.com/tools/downloads/sqldev-downloads.html) and download the proper package for your operating system. It is recommended that you choose the version with the JDK included. You might need to login using an Oracle account in order to start downloading the installation files.

## Task 2: Installing OCI CLI

Go to [oracle.com](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm) and follow the steps for installing and configuring the OCI CLI on your local machine. After installing it, you can run the ``oci setup config`` command and follow the steps to configure it. Test your configuration using the command: ``oci os ns get``.

## Task 3: Installing Docker

Go to [docker.com](https://www.docker.com/products/docker-desktop) and download the package suitable for your operating system. Install Docker and Sign In or create a new account.

## Task 4: Installing Kubectl

Go to [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) and download the suitable package for your operating system and install it according to the steps described on their website.

## **Task 5:[Optional]** Installing Visual Studio Code

Go to [visualstudio.com](https://code.visualstudio.com/Download) and download the proper package for your operating system. Install Visual Studio Code according to the steps in the installation window.

## **Task 6:[Optional]** Installing NodeJS

Go to [nodejs.org](https://nodejs.org/en/download/) and download the proper package for your operating system. Install it according to the steps in the installation window.

## **Task 7:[Optional]** Installing OracleJET Tools

After installing **NodeJS** open a command line window and run the following command. You might need administration rights to run them.
  ```
  <copy>
  npm install -g @oracle/ojet-cli
  </copy>
  ```
## **Task 8:[Optional]** Installing Oracle Instant Client
Go to [oracle.com](https://www.oracle.com/database/technologies/instant-client/downloads.html) and download the proper package for your operating system. Create a new folder for it (for example _C:\\oracle_). Extract the downloaded archive and copy the contents into this folder. Now, if you navigate to _C:\\oracle\\instantclient\_19\_9_ you should be able to see a _network\\admin_ folder. This is the folder in which you would need to copy the wallet files to connect to the database. If you don't have these two folders, you need to create them.

You should also add _C:\\oracle\\instantclient\_19\_9_ in your environment variables.

More information about Instant Client can be found [here](https://www.oracle.com/database/technologies/instant-client.html).

You may now [proceed to the next lab](#next).

## Acknowledgements
**Authors** - Giurgiteanu Maria Alexandra, Gheorghe Teodora Sabina
**Contributors** - Minoiu (Paraschiv) Laura Tatiana, Digori Gheorghe, Grama Emanuel
**Last Updated By** - Brianna Ambler, July 2021
