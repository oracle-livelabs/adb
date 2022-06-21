# Integration with Oracle Digital Assistant and Slack

## Introduction

In this lab you are going to go through a series of steps for provisioning an **Oracle Digital Assistant Instance**, download, import and test a Skill, create a **Slack Channel** and Workspace and integrate your Bot with Slack channel. **BotML** was used to create the Skill that you will download for this Demo.

The **Oracle Digital Assistant** makes API calls to the **Skillset Tracking Application** that contains data like names of managers,
their team members names, development areas, skills for each development area and skill value for each skill. All the data exists in a JSON format and the JSON is parsed to retrieve data from it.

In Slack Workspace, the Data will appear like buttons that you can select and what you have selected it will be sent to **Oracle Digital Assistant** as a variable, that will trigger another buttons as effect of the states in Flows that exists in the Digital Assistant. At some states you can choose the button or you can type as input/response the name of the manager/name of the employee/name of the skill/what is written on the button.

### Terminology
**Digital assistants** are virtual devices that help users accomplish tasks through natural language conversations, without having to seek out and wade through various apps and web sites. Each digital assistant contains a collection of specialized skills. When a user engages with the digital assistant, the digital assistant evaluates the user input and routes the conversation to and from the appropriate skills.

### Basic Concepts
  * **Intents** - Categories of actions or tasks users expect your skill to perform for them.
  * **Entities** - Variables that identify key pieces of information from user input that enable the skill to fulfill a task.
    Both intents and entities are common NLP (Natural Language Processing) concepts.
    NLP is the science of extracting the intention of text and relevant information from text.
  * **Components** - Provide your skill with various functions so that it can respond to users. These can be generic functions like outputting text, or they can return information from a backend and perform custom logic.
  * **Flows** - The definition for the skill-user interaction. The dialog flow describes how your skill responds and behaves according to user input.
  * **Channels** - Digital assistants and skills aren’t apps that you download from an app marketplace, like iTunes. Instead, users access them through messaging platforms or through client messaging apps. Channels, which are platform-specific configurations, allow this access. A single digital assistant or skill can have several channels configured for it so that it can run on different services simultaneously. Example of Channels: Slack, Facebook Messenger
  Here is what happens when you use Slack as a channel for your digital assistant:
      * Slack hosts your digital assistant through the intermediary of a Slack app.
      * Users chat with your digital assistant through the Slack app in the Slack user interface.

Estimated Lab Time: 2 hours

### Objectives
In this lab, you will:
  * Create an Oracle Digital Assistant Service Instance
  * Access the Service Instance from the Infrastructure Console
  * Import developed Skill in your Oracle Digital Assistant Service Instance
  * Test the Skill with Conversation Tester
  * Integrate your Digital Assistant with Slack
  * Test the Digital Assistant in Slack

### Prerequisites
To complete this lab, you must have:
  * This lab assumes you have an Oracle Cloud account and compartment, user, groups and policies created into it and you are logged in your account. For an overview of compartments, users, groups, policies etc. see this [link](https://docs.oracle.com/en/cloud/paas/digital-assistant/use-chatbot/users-groups-and-policies1.html#GUID-145DC7BA-2A9B-43BD-90A9-6FDBCAEBB7B0).

## Task 1: Create an Oracle Digital Assistant Service Instance

1. In the Infrastructure Console, click on Hamburger menu on the top left to open the navigation menu, select **Analytics & AI** and select **Digital Assistant** (which appears under the **AI Services** category on the page).

  ![digital assistant menu](./images/digital-assistant-menu.png)

2. From the **Compartments** panel, select a compartment.

  ![select compartment](./images/select-compartment.png)

3. Click **Create Instance**.

  ![create digital assistant instance](./images/create-oda-instance.png)

4. On the **Create Instance** page, fill in the following details:
    * **Compartment**.
    * **Name**. Enter a name that reflects usage of the instance.
    * **Description**. (Optional) Enter a description for your instance.
    * **Instance shape**. Select between the following shapes:
        * **Development**. This is a lightweight option that is geared toward development work.
        * **Production**. This option should be selected for production instances of Digital Assistant. In comparison with the Development shape, this option has higher rate limits and greater database capacity, which enables more Insights data to be collected.
    * **Tag Namespace**. (Optional)

    ![complete the details](./images/complete-the-details.png)

5. Click **Create**.

6. After a few minutes, your instance will go from the status of **Creating** to **Active**, meaning that your instance is ready to use.

  ![instance creating state](./images/creating-state.png)
  ![instance active state](./images/active-state.png)

## Task 2: Access the Service Instance from the Infrastructure Console
Once you have provisioned an instance, you can access it from the **Infrastructure Console** by following these steps:

1. Select your Digital Assistant Instance.

  ![select your instance](./images/select-instance.png)

2. Click **Service Console**. It will open a new page.

  ![select service console](./images/service-console.png)

3. **Sign In** to the Console. Click on the arrow located on the right side of **Oracle Cloud Infrastructure Direct Sign-In** text and enter your **User Name** and **Password**, then click on **Sign In**. A new window with your Digital Assistant will be opened.

  ![login 1](./images/login-1.png)
  ![login 2](./images/login-2.png)

## Task 3: Import Skill

1. In the Infrastructure Console, click on Hamburger menu on the top left to open the navigation menu, select **Development**, then select **Skills**.

  ![skills](./images/skills.png)

2. Download the **Skill** by accessing this [link](https://objectstorage.us-ashburn-1.oraclecloud.com/p/jyHA4nclWcTaekNIdpKPq3u2gsLb00v_1mmRKDIuOEsp--D6GJWS_tMrqGmb85R2/n/c4u04/b/livelabsfiles/o/labfiles/Lab7-SkillTracker_1.0.zip)

3. In the up right corner of the Console, select **Import Skill**.

  ![import skill](./images/import-skill.png)

4. Select the downloaded file from your computer then click **Open**

## Task 4: Integrate the Skill with your App

1. After you import the Skill, you will find it in the Console, under **Development** -> **Skills** category. Now click on it's name, **SkillTracker**.

  ![imported skill](./images/imported-skill.png)

2. In the left panel, click on **Components**.

  ![components](./images/components.png)

3. Under Components page, click on **Download package file**.

  ![download component](./images/download-component.png)

4. Unzip the file named _my-component-service-1.0.0.tgz_, then add this project folder in your code editor (Atom, VSCode etc.).

5. Under package -> components you will find 8 _.js_ files.

  ![folder structure](./images/folder-structure.png)

6. Open each of them and you will find in the code a constant named **restUrl**, for example in the GetAllAreas.js at line 16.

      ```
      const restUrl = "http://your_public_ip:8000/api/skillset";
      ```

  You will need to replace **your\_public\_ip** with the public IP address of your instance created in Lab5, Step 1, in all the 8 _.js_ files. Then save each file.

7. Open a terminal an go in the **package** folder. Run the command:

      ```
      npm pack
      ```

  ![npm pack](./images/npm-pack.png)

8. A new _.tgz_ file will be created inside the **package** folder.

9. Return in the **Components** section in Digital Assistant Console, and update the _my-component-service-1.0.0.tgz_ file with your new one, that will have the same name.

  ![update component](./images/update-component.png)

10. The status will change in **Awaiting Deployment**  then in **Ready**.

## Task 5: Test the Skill with Conversation Tester

1. After you update the Custom Component, click on **Preview** to test the skill, in the up right corner of the console.

  ![test skill](./images/test-skill.png)

2. A window with **Conversation Tester** will pop-up. You can change the **Channel** to **Slack** for the test. Use the **Utterance** section to enter the text.

  ![conversation tester](./images/conversation-tester.png)

3. In the **Utterance** section type _hi_ or _hello_ or how do you want to say hello/wake up the bot, then hit Enter.

  ![first test](./images/first-test.png)

4. You can make now 2 types of testing: _Press the button testing method_ or _User input & Press the button testing method_.

* **I. Press the button testing method**
    After you wake up the bot, you can click on the buttons:

    1. **Managers and teams** to see a list of managers can you can choose a manager -> a list of it's Employees will show up and you can choose one of them -> a list of Skill Areas will show up and you can choose one of them -> a list of Skills and Skill Values of the selected employee will show up and you can select one -> an output message will show up that will have 3 buttons:

      1.1. **Go back to skills** where you can see a list of all the Skills and their Values from all the Skill Areas of the selected employee and you can select one -> then you can choose from the buttons:

          * **Go back to skills** to go back at the list with all the skills and their values
          * **Start again** to start from beginning
          * **Exit** to finish the test

      1.2. **Start again** to start from beginning

      1.3. **Exit** to finish the test

    2. **Areas and Skills** to see a list of Skill Areas and you can choose one -> a list of Skills for the selected Area will show up and you can choose one -> a list of Skill Values between 0-5 will show up and you can choose the desired minimum value for the selected Skill -> a list of Engineers and their level for the selected Skill will show up and you can choose one -> an output message will show up that will have 4 buttons:

        * **Change Skill level** to go back to the state when you choose the Skill Level for the selected skill
        * **Change Area** to go back to the state when you choose the Skill Area
        * **Start from the top** to start from beginning
        * **All good.Bye!** to finish the test

    3. **None. Thanks!** if you changed your mind and want to exit the test.

* **II. User input & Press the button testing method**
  After you wake up the bot, you can click on the buttons described above OR you can type in the **Utterance** field one of the following:

    * the name of the desired Manager
    * the name of the desired Skill
    * the name of the desired Employee
    * show managers
    * show areas
    * bye
    * help
    * restart

  After you enter one of the above, you can then press the buttons depending on what do you want to see next.

## Task 6: Integrate your Digital Assistant with Slack

Below are the steps for creating a Slack channel for Digital Assistant.

### **Get a Slack Workspace**
  To make your digital assistant  available in Slack, you need to have a Slack Workspace available to you where you have the permissions necessary to create a Slack app.
  OBS: If you already have a Slack Workspace you can just Login and skip this step.  


1.  Enter this [link](https://slack.com/create#email).

2.  Enter your **email address** and click **Next**.

    ![email](./images/email.png)

3.  Check your email for a confirmation code.

4.  Enter the 6-digit confirmation code that was sent to your email.

5.  Enter the **name of your company or team**. This will be the name of the Workspace. Click **Next**.

    ![team company](./images/team-company.png)

6.  Enter the **name of a project** your team is working on. This will be the name of the new Channel in Slack. Click **Next**.

    ![project name](./images/project-name.png)

7.  Enter the **email** address of who do you email most about this project and click **Add Teammates** OR you can tap *skip for now*.

    ![teammates](./images/teammates.png)

8.  Click on **See your Channel in Slack**.

    ![see channel](./images/see-channel.png)

9.  The page will look like this.

    ![desktop](./images/desktop.png)

### **Create a Slack App**

1. Go to Slack's [Your Apps](https://api.slack.com/apps) page.

2. Click **Create an App**.

   ![create app](./images/create-app.png)

3. Click **From scratch**.

  ![create app from scratch](./images/from-scratch.png)

4. In the *Create a Slack App* dialog, fill in the **App Name** and **Pick a workspace to develop your app in** fields and click **Create App**. Once the app is created, its Basic Information page appears.

  ![app](./images/app.png)

5. Scroll down to the **App Credentials** section of the page and note the values of the **Client ID**, **Client Secret**, and **Signing Secret**.

  You'll need these credentials when you set up the channel in Digital Assistant.

  ![app credentials](./images/app-credentials.png)

### **Add OAuth Scopes for the Slack App**
You add OAuth scopes for permissions that you want to give to the bot and to the user.

 1. In the left navigation of the web console for your Slack app, within the *Features* section, select **OAuth and Permissions**.

  ![oauth](./images/oauth.png)

 2. Scroll down to the *Scopes* section of the page. The scopes fall into these categories:
    * Bot Token Scopes
    * User Token Scopes

 3. In the *Bot Token Scopes* section, add the scopes that correspond to the bot-level permissions that you want to allow. Click on **Add an OAuth Scope** and fill in with the following bot token scopes that are required:
    * chat:write
    * im:history
    * users:read

 4. In the *User Token Scopes* section, add the scopes that correspond to the user-level permissions that you want to allow. Click on **Add an OAuth Scope** and fill in with the following user token scope that is required:
    * files:write

 5. Your *Scopes* section should look like this:

    ![scopes](./images/scopes.png)

### **Add the App to the Workspace**  

1. Scroll back to the *top* of the **OAuth & Permissions** page.

2. Within the *OAuth Tokens & Redirect URLs* section and click **Install to Workspace**.

  ![install to workspace](./images/install-to-workspace.png)

3. A page will appear showing what the app will be able to do. At the bottom of the page, click **Allow**.  

  ![allow app](./images/allow-app.png)

4. Once you have completed this step, you should be able to see the app in your Slack Workspace by selecting **Apps** in the left navigation.

  ![app in slack 2](./images/app-in-slack-2.png)

### **Create a Channel in Digital Assistant**  

1. In the Oracle Digital Assistant Instance Console, click on Hamburger menu on the top left to open the navigation menu, select **Development** -> **Channels** -> **Users** -> **Add Channel**.

  ![new channel](./images/new-channel.png)

2. Fill in the following:

    * **Name**: give your channel a name.
    * **Description**: give your channel a description.
    * **Channel Type**: Choose **Slack** as the channel type.
    * **Client ID**, **Client Secret**, and **Signing Secret** values that you obtained when you created your Slack app. You can find them in your Slack app page under *Basic Information* section, then scroll down to **App Credentials**.
    * **Success and Error URLs**: you can leave them blank.
    * Click **Create**.

    ![create channel](./images/create-channel.png)

3. In the **Channels** page, copy the **WebHook URL** and paste it somewhere convenient on your system. You’ll need this to finish setting up the Slack app.

  ![webhook](./images/webhook.png)

4. Click on the *Arrow* from the top right of the page and select the **Skill** that you want to associate with the Channel.

  ![select skill](./images/select-skill.png)

5. *Switch on* the **Channel Enabled** control.

  ![enable channel](./images/enable-channel.png)

### **Configure the Webhook URL in the Slack App**  

1. In the left navigation of the web console for your Slack app, select **Interactivity & Shortcuts** and turn the **Interactivity** switch **ON**.

  ![interactivity](./images/interactivity.png)  

2. In both the **Request URL** and **Options Load URL** fields, paste the **webhook URL** that was generated when you created the Channel in Digital Assistant and you pasted it somewhere convenient on your system in a previous step. Then click **Save Changes**.

  ![paste webhookurl](./images/paste-webhookurl.png)  

3. In the left navigation, select **OAuth & Permissions**. In the *Redirect URLs* field, click **Add New Redirect URL**.

  ![redirect url](./images/redirect-url.png)   

4. Paste the **webhook URL** and add at it's end **/authorizeV2**, click **Add** -> **Save URLs**.

  ![redirect url2](./images/redirect-2.png)

5. In the left navigation, select **App Home**. In the *Your App’s Presence in Slack* section and turn on the **Always Show My Bot as Online** switch.

  ![online bot](./images/online-bot.png)

6. In the left navigation, select **Event Subscriptions**. Set the **Enable Events** switch to ON.

  ![events on](./images/events-on.png)

7. In the *Request URL* field, paste the **webhook URL**. A green *Verified* label should appear next to the Request URL label.

  ![events verified](./images/events-verified.png)

8. Expand the *Subscribe to bot events* section of the page and click **Add Bot User Event**.

  ![bot events](./images/bot-events.png)

9. Add the following events:
    * **message.im**
    * **app_mention**
    * **message.mpim**
    * **message.channels**

     ![all events](./images/all-events.png)


10. Click **Save Changes**.

11. In the left navigation, select **App Home**. Scroll down to *Show Tabs* section -> **Messages Tab** and check **Allow users to send Slash commands and messages from the messages tab**.

  ![check messages](./images/check-messages.png)

12. In the left navigation, select **Manage Distribution**. Under the heading *Share Your App with Your Workspace*, click **Add to Slack**.

  ![add to slack](./images/add-to-slack.png)

13. Click **Allow**.

  ![allow slack](./images/allow-slack.png)

14. At this point, you should get the message **You've successfully installed your App in Slack**.

  ![success](./images/success.png)

## Task 7: Test Your Bot in Slack
  With the Slack Channel and messaging configuration complete, you can test your Bot in Slack.

1. Open the Slack Workspace where you have installed the app.

2. You can communicate with your Bot both in Channels and in the App associated with your Skill.

  * **In a Channel**: In the left navigation bar, select one Channel, for example *#general*. In the *Message* field, enter *text @app\_name*, to start communicating with the Digital Assistant. Then you will need to *invite the app in the channel*. After this, the app will respond to you in the thread. Open the thread and continue the test. If you want to respond in message field, type your *text @app\_name*.

    ![test 1](./images/test-1.png)  

    ![test 2](./images/test-2.png)  ![test 3](./images/test-3.png) ![test 4](./images/test-4.png) ![test 5](./images/test-5.png)  ![test 6](./images/test-6.png)

  * **In the App**: In the left navigation bar, select the app that is associated with your Digital Assistant. In the *Message* field, you need to enter just the text to start communicating with the Digital Assistant.

    ![test 7](./images/test-7.png)

You may now [proceed to the next lab](#next).     

## Learn More?
* [Users, Groups, and Policies](https://docs.oracle.com/en/cloud/paas/digital-assistant/use-chatbot/users-groups-and-policies1.html#GUID-145DC7BA-2A9B-43BD-90A9-6FDBCAEBB7B0()
* [Provision an Instance](https://docs.oracle.com/en/cloud/paas/digital-assistant/use-chatbot/order-service-and-provision-instance.html#GUID-EB06833C-7B1C-46F6-B63C-1F23375CEB7E)
* [Skills](https://docs.oracle.com/en/cloud/paas/digital-assistant/use-chatbot/skills-ada.html)
* [Channels](https://docs.oracle.com/en/cloud/paas/digital-assistant/use-chatbot/channels-part-topic.html)
* [Slack](https://docs.oracle.com/en-us/iaas/digital-assistant/doc/slack.html)


## Acknowledgements

**Authors** - Minoiu (Paraschiv) Laura Tatiana, Digori Gheorghe
