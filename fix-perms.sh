#!/bin/bash

directory_path="$1"

# Set permissions
sudo chmod 755 "$directory_path"

# Set ownership
sudo chown -R 5196:5196 "$directory_path"

# Set SELinux context
sudo chcon -R -t container_file_t "$directory_path"
