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

![command](https://github.com/ctzoki/neoxa-mn/assets/129646348/c7c3a7f6-1ee8-4f8f-a85b-b3c093203dfa)

## 2. Welcome to your new server
Open the cockpit web ui using a browser, don't forget to substitute {ip-of-your-server} with your actual IP 

    https://{ip-of-your-server}:9090
    
![login](https://github.com/ctzoki/neoxa-mn/assets/129646348/26488999-0b70-4963-875c-2252c886eb97)

Click on Limited Access button on the top bar and enter your password again to enable administrative access for your session

![switch](https://github.com/ctzoki/neoxa-mn/assets/129646348/28c8845d-0daf-4438-979b-469077699b1d)
    
#### 2.1. Accounts setup
Head over to the Accounts menu
- There should be only 2 accounts, the username you provided to the installation script and root user
- If there are additional accounts, sometimes created by server providers, delete them
- Change the root password to a strong secure password generated by you

Before
![accounts-1](https://github.com/ctzoki/neoxa-mn/assets/129646348/b33a0890-e94a-424d-94a6-f308244f9b50)

After
![accounts-2](https://github.com/ctzoki/neoxa-mn/assets/129646348/06a2bf36-1cc5-4fea-8405-6b6dceade377)

#### 2.2. Enable metrics collection
Head over to the Overview menu, on the Usage Panel press "View metrics and history", enable the monitoring and collection services, do not enable "Export to network"

Before
![metrics-1](https://github.com/ctzoki/neoxa-mn/assets/129646348/0c89e60c-9c14-4652-90f0-82efeae78016)

Next Step
![metrics-2](https://github.com/ctzoki/neoxa-mn/assets/129646348/2e9c544e-c341-42b3-ba65-c1afe9872cb3)

It will take some time for data to start showing, check it again later

#### 2.3. Enable automatic updates
Head over to the Software Updates menu, install and enable the "Automatic updates" and "Kernel live patching"

Automatic Updates
![software-updates-1](https://github.com/ctzoki/neoxa-mn/assets/129646348/a4f9c6df-a31f-462d-8b92-dbe8ca10d9b5)

Enable automatic updates
![software-updates-2](https://github.com/ctzoki/neoxa-mn/assets/129646348/4b3ce296-f0db-49e0-af38-9ac3c691142e)

Enable kernel live patch
![software-updates-3](https://github.com/ctzoki/neoxa-mn/assets/129646348/e660f54f-dcfa-47d8-b238-9821ee920cd1)

Final state
![software-updates-4](https://github.com/ctzoki/neoxa-mn/assets/129646348/de55737d-c8e2-4c69-b7bd-fd42917bb782)

#### 2.4. Add additional IPs
Head over to the Networking menu, click on the main interface that is online, usually named eno1/eth1, click edit on the IPV4 settings, now a new popup will appear where you can enter all the additional IPs that you have for running masternodes

![network](https://github.com/ctzoki/neoxa-mn/assets/129646348/567ca22b-c752-4343-ba4e-f304ad975b7d)

#### 2.5. Enable Podman
Head over to the Podman menu, enable the podman service, here we will be starting all the nodes as described in the next section.

![podman](https://github.com/ctzoki/neoxa-mn/assets/129646348/1c33d31a-fb03-43de-bc75-1d8cab63dcb7)

## 3 Running MN Containers in Podman

#### 3.1 Preparing your collateral and registering your masternode
Head over to your neoxa-qt wallet and open the debug console, 4 commands need to be executed to register the masternode

    getnewaddress

It will output a new address with 0 balance, use it for the next command

    sendtoaddress "{your-new-address-here}" {number-of-coins}

You are sending coins to the new address, for testnet use 60000.0 for mainnet use 1000000.0, the output will be the transaction id, take note of it

    smartnode outputs

This will list the transactions which outputs match MN requirements, find the one that matches the previoulsy noted, and take note of the sequecence appearing next to it, i.e. 0 or 1
![Screenshot from 2023-06-13 11-00-41](https://github.com/ctzoki/neoxa-mn/assets/129646348/b03dac72-3898-4891-9124-a23cb7ac3d96)

    listaddressgroupings

This command will output all your wallet addresses, find one with a few neox balance to be used as fee for the next transaction, **!DO NOT USE THE ONE WHERE YOU DEPOSITED COLLATERAL AMOUNT!**
![Screenshot from 2023-06-13 11-01-28](https://github.com/ctzoki/neoxa-mn/assets/129646348/43b1d7a5-13bd-4fc0-8889-24361f7ddd49)


    protx quick_setup {your-tx-id} {output-sequence} {your-ip}:{your-port} {your-fee-address}

Substitute all the parameters here with your actual values
![Screenshot from 2023-06-13 11-04-59](https://github.com/ctzoki/neoxa-mn/assets/129646348/5ff1b252-aadb-44b3-a008-45db6471bebe)

Thats all of the commands, the last one outputs the path to your configuration file, the file it generates should look similar to the image below, copy the file contents we will need it on the server.
![Screenshot from 2023-06-13 11-08-09](https://github.com/ctzoki/neoxa-mn/assets/129646348/841731a5-26dc-4700-94c2-506c1a9bc0aa)

#### 3.2 Setting up the config on the server
Open the Navigator and navigate to the /opt folder, here we will create the directories for our containers, i suggest creating first folders "testnet" and "mainnet" to have nice structure on your server, then in the testnet or mainnet folder create folders for your nodes, i.e. node-1, node-2, node-x
![image](https://github.com/ctzoki/neoxa-mn/assets/129646348/866088ef-c697-40c6-baf7-9c1a00cc81a4)

Inside of your node-x folder we will need to create the neoxa.conf file
![image](https://github.com/ctzoki/neoxa-mn/assets/129646348/7d6e4940-9936-4892-adb7-c9ac3d8dc322)

Then edit it by double clicking it to enter your generated neoxa.conf, **ADD testnet=1 AT THE END OF THE CONFIG IF YOU WANT TESTNET**
![image](https://github.com/ctzoki/neoxa-mn/assets/129646348/820fc8f3-aab4-42fc-840f-7d7ddc84b963)

As a last step we need to setup correct permissions for the container to use the directory, the following commands need to run

    sudo chmod 755 {your-directory-path}

    sudo chown -R 5196:5196 {your-directory-path}

    sudo chcon -R -t container_file_t {your-directory-path}

![image](https://github.com/ctzoki/neoxa-mn/assets/129646348/c6a0ab2b-7f82-4fde-a42f-0e46fc69bab9)

Now all the files and permissions are in place to run the containers

#### 3.3 Creating your pod and your container
Head over to the podman menu and click on create pod, enter your details taking care to enter your correct host path volume, i.e. /opt/testnet/node-x and map it to /var/lib/neoxa, also make sure to enter your correct IP and Port
![image](https://github.com/ctzoki/neoxa-mn/assets/129646348/377f0e0b-ad0b-4569-8ae1-00a106ec7d1a)


--TBD--







