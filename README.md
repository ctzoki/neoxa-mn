# Neoxa Masternode Setup
This is a guide to setup a server for neoxa masternodes, it sets up a reasonably secure server with cockpit for management and podman for running containers

## Requirements for this setup
- Server running Rocky Linux 9.2 or Alma Linux 9.2 ( Tested on Rocky Linux ) 
- Whenever you see something like {parameter} in the commands you need to substitute it with an actual value for your case

#### Official requirements per node
- 2 vCPU
- 4GB Ram
- 80GB SSD

#### Trust me bro estimate:
- 1 Thread
- 2GB Ram
- 20GB SSD

## 1. After server is provisioned
Login with SSH or any other means, and switch to root user using

    sudo su

Download and execute the install.sh script, **Make sure to substitute {username} and {password} with real values, this user will be the one you use, make sure the password is very strong and preferably generated with a password manager**

    curl -sSL https://raw.githubusercontent.com/ctzoki/neoxa-mn/main/install.sh | bash -s {username} {password}
    
Server will reboot after installation is complete

## 2. Welcome to your new server
Open the cockpit web ui using a browser, don't forget to substitute {ip-of-your-server} with your actual IP 

    https://{ip-of-your-server}:9090
    
#### 2.1 Accounts setup
Head over to the Accounts menu
- There should be only 2 accounts, the username you provided to the installation script and root user
- If there are additional accounts, sometimes created by server providers, delete them
- Change the root password to a strong secure password generated by you

#### 2.2 Enable metrics collection
Head over to the Overview menu, on the Usage Panel press "View metrics and history", enable the monitoring and collection services, do not enable "Export to network"

#### 2.3 Enable automatic updates
Head over to the Software Updates menu, install and enable the "Automatic updates" and "Kernel live patching"

#### 2.4 Add additional IPs
Head over to the Networking menu, click on the main interface that is online, usually named eno1/eth1, click edit on the IPV4 settings, now a new popup will appear where you can enter all the additional IPs that you have for running masternodes

#### 2.5 Enable Podman
Head over to the Podman menu, enable the podman service and enable starting on boot, here we will be starting all the nodes as described in the next section.

## 3 Running MN Containers in Podman
-- Instructions will be updated during testnet --
