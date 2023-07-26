#!/bin/bash

# Instal jq as the status script depends on it
dnf install -y jq wget

# Define the GitHub repository URL
REPO_URL="https://raw.githubusercontent.com/ctzoki/neoxa-mn"

# Define the target directory
TARGET_DIR="/usr/share/cockpit/smartnode-status"

# Create the target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

# Change to the target directory
cd "$TARGET_DIR" || exit 1

# Download and overwrite the files from the "smartnode-status" folder in the GitHub repository
FOLDER_URL="$REPO_URL/main/smartnode-status"
files=("bootstrap.bundle.min.js" "bootstrap.min.css" "custom.css" "manifest.json" "smartnode-status.html" "smartnode-status.sh")
for file in "${files[@]}"; do
    # Delete existing file if it exists
    if [ -f "$file" ]; then
        rm "$file"
    fi

    # Download the file
    wget -q "$FOLDER_URL/$file"
done

# Make the smartnode-status.sh file executable
chmod +x smartnode-status.sh

# Add cron job to run the script every minute if it doesn't exist
CRON_CMD="cd $TARGET_DIR && bash smartnode-status.sh"
CRON_JOB="* * * * * $CRON_CMD"

(crontab -l 2>/dev/null | grep -Fv "$CRON_CMD"; echo "$CRON_JOB") | crontab -

echo "Files downloaded and installed in $TARGET_DIR"
echo "Cron job added to run the script every minute"
