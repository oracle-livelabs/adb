# Configure VPN Connectivity to Your Private Autonomous AI Database Network

## Introduction

Oracle Autonomous AI Database on Dedicated Exadata Infrastructure can be deployed in a private virtual cloud network (VCN) in Oracle Cloud Infrastructure (OCI), without a public IP address. A VPN connection is one approach for providing controlled client connectivity to the databases.

This lab walks you through deploying an OpenVPN Access Server in OCI and creating a VPN connection between a client machine and Autonomous AI Database on Dedicated Exadata Infrastructure. After it is configured, a single VPN server can support multiple users.

Estimated Time: 45 minutes

### Objectives

As a network or fleet administrator:

1. Configure a VPN server in OCI based on OpenVPN software.
2. Configure your VPN client and connect to the VPN server.
3. Launch SQL Developer on the client and connect to a dedicated Autonomous AI Database instance.

### Required Artifacts

- An Oracle Cloud Infrastructure account with privileges to create compute instances and network resources.
- A pre-provisioned dedicated Oracle Autonomous AI Database instance in a private network. Refer to the lab **Provisioning Databases** in the [Autonomous Database Dedicated for Developers and Database Users workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/run-workshop?p210_wid=3197) to provision an Autonomous AI Database.
- A pre-provisioned VCN with public and private subnets configured with appropriate security lists. See [Preparing your private network in Oracle Cloud Infrastructure](?lab=adb-network-prepare).

The following illustration shows a network topology that can be used to provide secure access to an Autonomous AI Database on a Dedicated Exadata Infrastructure.
![Network Topology.](./images/highlevelssl.png " ")

- As shown above, the OCI VCN has two subnets: a private subnet that hosts the Exadata infrastructure and a public subnet that hosts public-facing web and application servers, including the VPN server.

- An internet gateway is attached to the public subnet to allow the required resources in that subnet to communicate over the internet.

- Security lists are configured so that TCP traffic to the private Exadata subnet is allowed only from hosts in the public subnet. Further restrict this access to the required source hosts and ports where possible.

- For detailed instructions on network setup for dedicated Autonomous AI Database infrastructure, see [Preparing your private network in Oracle Cloud Infrastructure](?lab=adb-network-prepare).

## Task 1: Launch a Linux VM for the OpenVPN server

- Sign in to the OCI Console. In the navigation menu, select **Compute**, then **Instances**. See [Overview of Compute Instances](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) for more details.

    ![Navigate OCI Console.](./images/createcompute1.png " ")

- Click **Create instance**.

   ![Create Compute Instance.](./images/createcompute2.png " ")

- Provide the basic information:
    - Name: Enter a name for your instance.
    - Compartment: Select the compartment where you want to create the instance.
    - Placement: Choose the Availability Domain.

    ![Create compute instance basic information.](./images/createcompute3.png " ")

- Image and shape:
    - Image: Select a Linux operating system that is supported by your OpenVPN Access Server release.

    **Review required:** The screenshot shows **CentOS Stream 8**. Confirm that the selected image is supported by the OpenVPN Access Server release you plan to install before publishing.

    ![Image and shape of compute instance.](./images/createcompute4.png " ")

    - Shape: Click **Change shape** to select the instance type and shape series.

    ![Change shape of compute instance.](./images/createcompute5.png " ")

    ![Change shape series of compute instance.](./images/createcompute5a.png " ")

- Optionally, enable **Shielded instances**.

    ![Enable shielded instance.](./images/createcompute6.png " ")

- Networking: Configure the VCN and public subnet. Select **Automatically assign a public IPv4 address** if the instance requires internet access.

    ![Configure primary vnic.](./images/createcompute7.png " ")

    ![Configure subnet.](./images/createcompute7a.png " ")

- Add SSH keys: For Linux instances, generate a new key pair or upload your public key (`.pub` file) to allow secure SSH access.

    ![Configure SSH keys.](./images/createcompute8.png " ")

- Boot volume: Configure the boot volume settings as shown below.

    ![Configure Boot volume.](./images/createcompute9.png " ")

    ![Configure Block volumes.](./images/createcompute9a.png " ")

- Review: Click **Create** after reviewing your settings.

    ![Submit Compute instance creation.](./images/createcompute10.png " ")

Within a few minutes, your Linux server will be ready with a public IP address for SSH access.

![List Compute instance.](./images/createcompute11.png " ")

## Task 2: Install and configure OpenVPN Server

In this task, you install OpenVPN Access Server on the Linux VM, set an administrator password, and configure routing and DNS so VPN clients can reach private subnets, such as the application and Exadata subnets, without routing all internet traffic through the VPN.

- Prerequisites:
    - You have the public IP address of your Linux VM.
    - You can SSH to the VM (security list/NSG allows TCP/22 from your source).
    - Your OpenVPN server VM can reach the internet to download packages.
    - The security list or network security group allows TCP port 22 only from approved administrator source addresses, TCP port 943 for the OpenVPN web interfaces, and UDP port 1194 for VPN client connections. If you use web-service port sharing, also allow TCP port 443.
    - You know the CIDR blocks for the private subnets you want to reach over VPN (for example: App subnet CIDR, Exadata subnet CIDR).

- SSH into the Linux VM. From your terminal, connect to the VM using its public IP address:

    ```bash
    <copy>
    $ ssh opc@<public_ip_address_of_your_linux_vm>
    </copy>
    ```

    ![Instal epel release.](./images/install-epel-release.png " ")

- Download and install the OpenVPN Access Server package for your selected, supported Linux operating system.

    ![Install OpenVPN.](./images/install-openvpn.png " ")

    ![Instal OpenVPN AS.](./images/install-openvpn-as.png " ")

- Set the OpenVPN administrator password. OpenVPN Access Server creates the Linux user `openvpn` for initial administrative access. Set its password:

    ![OpenVPN Change password.](./images/openvpn-changepwd.png " ")

    Record the password securely - you will use it to log in to the Admin UI.

- Sign in to the OpenVPN Admin Web UI (port 943).

    From your local browser, access the Admin Web UI at `https://<public_ip_address_of_your_linux_vm>:943/admin` and sign in with the `openvpn` user and the password you set.

    ![Open VPN Login screen.](./images/openvpn-login.png " ")

- In the Admin Web UI, open the network settings and set the hostname or IP address to the public IP address of the OpenVPN Access Server instance.

    ![OpenVPN Network setting.](./images/openvpn-network.png " ")

    Save the setting before continuing.

- Configure the VPN network settings to allow access to the required private subnets.

    Configure NAT, split tunneling, and DNS so that VPN clients can reach the private application and Exadata subnets.

    In current Access Server releases, use the access-control and VPN-network configuration pages to apply the following settings:

     - Allow access to only the required application and Exadata subnet CIDR blocks.
     - Use NAT for client access to these private subnets.
     - Disable routing of general client internet traffic through the VPN (split tunneling).

       ![Use VPN NAT.](./images/vpn-nat.png " ")

    Configure the DNS settings required to resolve names in the private network.

     ![Configure DNS setting.](./images/vpn-routing2.png " ")

    **Review required:** The current Access Server 3.x Admin Web UI uses different navigation and control labels from the legacy interface shown in the screenshots. Confirm the release in use and update the screenshots or map the settings to the deployed version before publishing. The following legacy setting is not required for client-to-database access; retain it only if VPN clients must communicate directly with one another.

    ![Open VPN Advanced VPN.](./images/openvpn-advancedvpn.png " ")

    **Note:** Save the changes and restart or update the running server, as prompted by the Access Server release in use.

## Task 3: Install OpenVPN Client

- Open the OpenVPN Access Server Client Web UI at `https://<your_vpn_server_public_ip>:943` and download OpenVPN Connect or the connection profile for your platform.

    ![Invoke OpenVPN Client.](./images/openvpn-client.png " ")

- After installation is complete, open OpenVPN Connect and import the downloaded connection profile, if required by your client.

    ![Connect using OpenVPN.](./images/openvpn-conn.png " ")

    ![Enter hostname of OpenVPN Server.](./images/openvpn-client-conn.png " ")

    **Note:** Use the public IP address or hostname of the OpenVPN compute instance.

- Click **Connect**. When prompted, enter the credentials for the `openvpn` user and click **Connect** to establish a VPN tunnel.

    ![OpenVPN Client window.](./images/openvpn-clientwindow.png " ")

You can also configure the VPN server for multiple users. Follow the [OpenVPN Access Server user-management documentation](https://openvpn.net/as-docs/) to set up additional users.

## Task 4: Connect SQL Developer to your Autonomous AI Database on Dedicated Exadata Infrastructure

- Launch SQL Developer and connect using the downloaded client credentials wallet, as shown below.

    **Note:** Oracle recommends using the latest SQL Developer release. SQL Developer 18.3 and later supports the **Cloud Wallet** connection type.

    ![Launch SQL Developer Web.](./images/atpd-conn.png " ")

- For detailed instructions on downloading database client credentials, see the lab **Configure a Development System** in the [Autonomous Database Dedicated for Developers and Database Users workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/run-workshop?p210_wid=3197).

- If APEX is enabled for the database, you can also connect to it directly from your local browser. Obtain the APEX URL from the OCI Console and open it in a browser window.

    ![Open APEX application.](./images/atpd-application-apex.png " ")

*Congratulations! You configured a secure VPN connection to your private Autonomous AI Database infrastructure.*

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Tejus S. & Kris Bhanushali
- **Adapted by** -  Vandana Rajamani, Consulting UA Developer, June 2026
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, July 2026

