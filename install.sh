#!/bin/bash

# Enable EPEL repository
dnf install epel-release -y

# Update the OS
dnf update -y

# Install packages
dnf install -y vim htop tree net-tools

# Install fail2ban from the EPEL repository
dnf install -y fail2ban fail2ban-systemd

# Enable firewalld
systemctl enable --now firewalld

# Add a new user
if [ $# -ne 2 ]; then
    echo "Please provide the username and password for the new user."
    exit 1
fi

USERNAME=$1
PASSWORD=$2

useradd -m -s /bin/bash $USERNAME
echo "$PASSWORD" | passwd --stdin $USERNAME
usermod -aG wheel $USERNAME

# Enable SSH monitoring in Fail2Ban
touch /etc/fail2ban/jail.d/sshd.local
echo -e "[sshd]\nenabled = true\nport = ssh\nlogpath = %(sshd_log)s\nbackend = %(sshd_backend)s\nmaxretry = 3\nbantime = 1h" > /etc/fail2ban/jail.d/sshd.local

# Restart Fail2Ban
systemctl enable --now fail2ban
systemctl restart fail2ban

# Enable Cockpit
dnf install cockpit -y
systemctl start cockpit
systemctl enable cockpit
systemctl enable --now cockpit.socket
firewall-cmd --permanent --add-service=cockpit
firewall-cmd --reload

# Install Podman and Podman Cockpit
dnf install -y podman cockpit-podman
systemctl start podman
systemctl enable podman

# Enable selinux and reboot
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config 
grubby --update-kernel=ALL --args="enforcing=1" 
grubby --update-kernel=ALL --remove-args selinux
reboot now
