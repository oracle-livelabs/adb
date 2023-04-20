# Identity and Access Management (IAM) Service

## Introduction
Oracle Cloud Infrastructure (OCI) Identity and Access Management (IAM) Service lets you control who has access to your cloud resources. You control the types of access a group of users has and to which specific resources. The purpose of this lab is to give you an overview of the IAM Service components and an example scenario to help you understand how they work together.


Estimated Time: 45 minutes

### Objectives

In this lab, you will:

- Create a compartment
- Create a user
- Create a group
- Create a policy associated to the group
- Add a user to the group
- Enable Multi-Factor Authentication


## Task 1: Create a compartment

A compartment is a collection of cloud assets, like compute instances, load balancers, databases, etc. By default, a root compartment was created for you when you created your tenancy (i.e. when you registered for the trial account). It is possible to create everything in the root compartment, but Oracle recommends that you create sub-compartments to help manage your resources more efficiently.

1. Click the Navigation Menu in the upper left, navigate to **Identity & Security** and select **Compartments**.

	![Select compartments](https://oracle-livelabs.github.io/common/images/console/id-compartment.png " ")

   Click **Create Compartment**.
   ![Create a compartment](images/create-compartment.png)

2. Name the compartment **Demo** and provide a short description. Be sure your root compartment is shown as the parent compartment. Press the **Create Compartment** button when ready.

   ![Create compartment](images/compartment-details.png)

3. You have just created a compartment for all of your work in this Test Drive.

## Task 2: Manage Users, Groups, and Policies to Control Access

A user's permissions to access services comes from the groups to which they belong. The permissions for a group are defined by policies. Policies define what actions members of a group can perform, and in which compartments. Users can access services and perform operations based on the policies set for the groups of which they are members.

We'll create a user, a group, and a security policy to understand the concept.

1. Click the **Navigation Menu** in the upper left. Navigate to **Identity & Security** and select **Groups**.

	![Select groups](https://oracle-livelabs.github.io/common/images/console/id-groups.png " ")

2. Click **Create Group**.
   
   In the **Create Group** dialog box, enter the following:

     - **Name:** Enter a unique name for your group, such as **oci-group** 
         >**Note:** the group name cannot contain spaces.

     - **Description:** Enter a description, such as **New group for oci users**
     - Click **Create**

   ![Create Group](images/create-group.png)

3. Click your new group to display it. Your new group is displayed.

   ![New group is shown](images/image006.png)

4. Now, let’s create a security policy that gives your group permissions in your assigned compartment. For example, create a policy that gives permission to members of group **oci-group** in compartment **Demo**:

   a) Click the **Navigation Menu** in the upper left. Navigate to **Identity & Security** and select **Policies**.
   ![Select policies](https://oracle-livelabs.github.io/common/images/console/id-policies.png " ")


   b) On the left side, select **Demo** compartment.
   ![Select ***Demo** compartment](images/demo-compartment.png)

      >**Note:** You may need to click on the + sign next to your main compartment name to be able to see the sub-compartment ***Demo***. If you do, and you still don't see the sub-compartment, ***refresh your browser***. Sometimes your browser caches the compartment information and does not update its internal cache.

   c) After you have selected the **Demo** compartment, click **Create Policy**.
      ![Click create policy](images/img0012.png)

   d) Enter a unique **Name** for your policy (for example, "Policy-for-oci-group").
      >**Note:** the name can NOT contain spaces.

   e) Enter a **Description** (for example, "Policy for OCI Group").

   f) Select **Demo** for compartment.
   
   g) Click **Show manuel editor** and enter the following **Statement**:
     ```
     <copy>Allow group oci-group to manage all-resources in compartment Demo</copy>
     ```

   h) Click **Create**.

   ![Create](images/create-policy.png)

5. Create a New User

   a) Click the **Navigation Menu** in the upper left, navigate to **Identity & Security** and select **Users**.

	![Select users](https://oracle-livelabs.github.io/common/images/console/id-users.png " ")

   b) Click **Create User**.

   In the **Create User** dialog box, enter the following:

      - **Name:** Enter a unique name or email address for the new user (for example, **User01**).
      _This value is the user's login name for the Console and it must be unique across all other users in your tenancy._
      - **Description:** Enter a description (for example, **New oci user**).
      - **Email:**  Preferably use a personal email address to which you have access (GMail, Yahoo, etc).

    Click **Create**.

      ![New user form](images/user-form.png)

6. Set a Temporary Password for the newly created User.

   a) From the list of users, click on the **user that you created** to display its details.

   b) Click **Create/Reset Password**.  

      ![Reset password](images/image009.png)

   c) In the dialog, click **Create/Reset Password**.

      ![Reset password](images/create-password.png)

   d) The new one-time password is displayed.
      Click the **Copy** link and then click **Close**. Make sure to copy this password to your notepad.

      ![Copy password](images/copy-password.png)

   e) Click **Sign Out** from the user menu and log out of the admin user account completely.

      ![Sign out](images/sign-out.png)

7. Sign in as the new user using a different web browser or an incognito window.

   a) Open a supported browser and go to the Console URL:  [https://cloud.oracle.com](https://cloud.oracle.com).

   b) Click on the portrait icon in the top-right section of the browser window, then click **Sign in to Oracle Cloud**.

   c) Enter the name of your cloud account (aka your tenancy name, not your user name), then click the **Next** button.

   ![Enter tenancy name](images/cloud-account-name.png)

   d) This time, you will sign in using **Oracle Cloud Infrastructure Direct Sign-In** box with the user you created. Note that the user you created is not part of the Identity Cloud Services.

   e) Enter the password that you copied. Click **Sign In**.

      ![Enter your password](images/sign-in.png)

      >**Note:** Since this is the first-time sign-in, the user will be prompted to change the temporary password, as shown in the screenshot below.

   f) Set the new password. Click **Save New Password**.
      ![Set the new password](images/image015.png)

8. Verify user permissions.

   a) Click the **Navigation Menu** in the upper left. Click **Compute** and then click **Instances**.

   ![Select Instances](https://oracle-livelabs.github.io/common/images/console/compute-instances.png " ")

   b) Try to select any compartment from the left menu.

   c) The message “**You don’t have permission to view these resources**” appears. This is normal as you did not add the user to the group where you associated the policy.
      ![Error message can be ignored](images/no-permission.png)

   d) Sign out of the Console.

9. Add User to a Group.

      a) Sign back in with the ***admin*** account.
      
      b) Click the **Navigation Menu** in the upper left. Navigate to **Identity & Security** and select **Users**. From the **Users** list, click the user account that you just created (for example, `User01`)  to go to the User Details page.
         ![Select users](https://oracle-livelabs.github.io/common/images/console/id-users.png " ")
      
      c) Scroll down. Under the **Resources** menu on the left, click **Groups**, if it's not already selected.

      d) Click **Add User to Group**.
         ![Add user to group](images/image020.png)

      e) From the **Groups** drop-down list, select the **oci-group** that you created.

      f) Click **Add**.
         ![Press the Add button](images/add-user-to-group.png)

      g) Sign out of the Oracle Cloud website.

10. Verify user permissions when a user belongs to a specific group.

      a) Sign in with the local **User01** account you created. Remember to use the latest password you assigned to this user.

      b) Click the **Navigation Menu**. Click **Compute** and then click **Instances**.

    ![Select instances](https://oracle-livelabs.github.io/common/images/console/compute-instances.png " ")

      c) Select compartment **Demo** from the list of compartments on the left.

      ![Select ***Demo***](images/select-demo.png)

      d) There is no message related to permissions and you are allowed to create new instances.

      e) Click the **Navigation Menu**. click **Identity & Security** and select **Groups**.

	![Select groups](https://oracle-livelabs.github.io/common/images/console/id-groups.png " ")

      f) The message **“Authorization failed or requested resource not found”** appears. This is expected, since your user has no permission to modify groups. 
      >**Note:** You may instead get the "An unexpected error occurred" message instead. That is also fine.

      ![](images/group-error.png)

      g) Sign out.

## Task 3: Multi-Factor Authentication setup

Let's set up Multi-Factor Authentication for our tenancy administrator. Log in to the cloud as the tenancy administrator.

1. Click on the portrait icon in the top-right section of the screen, then click **User Settings**.

      ![Click User Settings](images/user-settings.png)

2. Click Enable Multi-Factor Authentication.

      ![Click Enable Multi-Factor Authentication](images/enable-mfa.png)

3. Install Oracle Mobile Authenticator or a similar authenticator app on your mobile device. Open the app and scan the QR code when prompted. Enter the code displayed by the app and select **Verify**.

      ![Click Verify](images/click-verify.png)

4. Multi-Factor Authentication is now enabled.

      ![Multi-Factor Authentication is enabled](images/mfa-enabled.png)

5. Click **Sign Out** from the user menu.

      ![Sign out](images/sign-out.png)

6. Log in to the cloud as the tenancy administrator.

      ![Sign In](images/oci-login.png)

7. Check your registered mobile device for the temporary passcode. Enter the temporary passcode and click **Sign In**.

      ![Sign In](images/mfa-login.png)

We have now logged in to our account using Multi-Factor Authentication.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Kamryn Vinson, Database Product Management
- **Last Updated By/Date** - Kamryn Vinson, February 2023
