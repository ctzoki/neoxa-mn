#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Define the GitHub repository URL
REPO_URL="https://raw.githubusercontent.com/ctzoki/neoxa-mn/nat-reflection/nat-reflection"

# Create necessary directories
mkdir -p /etc/nat-reflection

# Download and copy scripts
wget -O /usr/bin/nat-reflection "$REPO_URL/nat-reflection.sh"
chmod +x /usr/bin/nat-reflection

wget -O /etc/systemd/system/nat-reflection.service "$REPO_URL/nat-reflection.service"

# Enable and start service
systemctl daemon-reload
systemctl enable nat-reflection.service
systemctl start nat-reflection.service

touch /etc/nat-reflection/rules

echo "NAT reflection setup completed."