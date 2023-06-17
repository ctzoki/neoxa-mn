#!/bin/bash

# Check if the script is running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo." >&2  # Redirected to stderr
    exit 1
fi

# Execute the command and store the output in a variable
CONTAINER_INFO=$(podman ps --format "{{.ID}}:{{.Names}}" | grep "node")

# Check if any containers match the criteria
if [ -z "$CONTAINER_INFO" ]; then
    echo "No containers found matching the criteria." >&2  # Redirected to stderr
    exit 1
fi

# Loop through each container info and execute the desired command
while IFS=: read -r CONTAINER_ID CONTAINER_NAME; do
    echo "Executing command in container: $CONTAINER_NAME"
    podman exec "$CONTAINER_ID" /app/neoxa-cli -datadir=/var/lib/neoxa smartnode status
done <<< "$CONTAINER_INFO"
