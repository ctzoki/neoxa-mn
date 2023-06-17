#!/bin/bash

set -euo pipefail

# Enable EPEL repository
dnf install -y epel-release

# Update the OS
dnf update -y

# Install packages
dnf install -y vim htop tree net-tools

# Install fail2ban from the EPEL repository
dnf install -y fail2ban fail2ban-systemd

# Enable firewalld
systemctl enable --now firewalld

# Add a new user
if [[ $# -ne 2 ]]; then
    echo "Please provide the username and password for the new user."
    exit 1
fi

USERNAME=$1
PASSWORD=$2

useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG wheel "$USERNAME"

# Enable SSH monitoring in Fail2Ban
cat << EOF > /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
bantime = 1h
EOF

# Restart Fail2Ban
systemctl enable --now fail2ban
systemctl restart fail2ban

# Enable Cockpit
dnf install -y cockpit
systemctl enable --now cockpit.socket
firewall-cmd --permanent --add-service=cockpit
firewall-cmd --reload

# Install Podman and Podman Cockpit and Cockpit Navigator
dnf install -y podman cockpit-podman
dnf install https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.8/cockpit-navigator-0.5.8-1.el8.noarch.rpm
systemctl enable --now podman

# Enable SELinux
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
grubby --update-kernel=ALL --args="enforcing=1"
grubby --update-kernel=ALL --remove-args=selinux

# Reboot the system
reboot now
