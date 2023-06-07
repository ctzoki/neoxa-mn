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
