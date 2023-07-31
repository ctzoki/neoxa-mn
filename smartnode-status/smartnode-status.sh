#!/bin/bash

# Check if the script is running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo." >&2  # Redirected to stderr
    exit 1
fi

# Get the current date and hour
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_HOUR=$(date +"%H:%M:%S")

# Execute the command and store the output in a variable
CONTAINER_INFO=$(podman ps --format "{{.ID}}:{{.Names}}:{{.Image}}" | grep "ctzoki/neoxa-full-node")

# Check if any containers match the criteria
if [ -z "$CONTAINER_INFO" ]; then
    echo "No containers found matching the criteria." >&2  # Redirected to stderr
    exit 1
fi

# Start generating the HTML content
HTML_CONTENT="<!DOCTYPE html>
<html>
<head>
  <title>Smartnode Status</title>
  <link rel='stylesheet' href='bootstrap.min.css'>
  <link rel='stylesheet' href='custom.css'>
  <script src='bootstrap.bundle.min.js'></script>
  <script src='auto-reload.js'></script>
</head>
<body>
  <div class='container'>
    <br/>
    <h3>Smartnode Status - $CURRENT_DATE $CURRENT_HOUR</h3>
    <br/>"

# Loop through each container info and execute the desired commands
while IFS=: read -r CONTAINER_ID CONTAINER_NAME CONTAINER_IMAGE; do
    HTML_CONTENT+="<div class='accordion' id='accordion$CONTAINER_ID'>
      <div class='accordion-item'>
        <h2 class='accordion-header' id='heading$CONTAINER_ID'>
          <button class='accordion-button collapsed' type='button' data-bs-toggle='collapse' data-bs-target='#collapse$CONTAINER_ID' aria-expanded='false' aria-controls='collapse$CONTAINER_ID'>
            Container: $CONTAINER_NAME"

    # Fetch blockchain info
    OUTPUT_BLOCKCHAININFO=$(podman exec "$CONTAINER_ID" /app/neoxa-cli -datadir=/var/lib/neoxa getblockchaininfo 2>&1)
    if [ $? -eq 0 ]; then
        LAST_SYNCED_BLOCK=$(echo "$OUTPUT_BLOCKCHAININFO" | jq -r '.blocks')
        LAST_SYNCED_HEADER=$(echo "$OUTPUT_BLOCKCHAININFO" | jq -r '.headers')
    else
        LAST_SYNCED_BLOCK="N/A"
        LAST_SYNCED_HEADER="N/A"
    fi

    # Execute the command and capture the output and error
    OUTPUT_NETWORK=$(podman exec "$CONTAINER_ID" /app/neoxa-cli -datadir=/var/lib/neoxa getnetworkinfo 2>&1)
    OUTPUT_SMARTNODE=$(podman exec "$CONTAINER_ID" /app/neoxa-cli -datadir=/var/lib/neoxa smartnode status 2>&1)
    EXIT_STATUS_NETWORK=$?
    EXIT_STATUS_SMARTNODE=$?

    # Check if the command execution was successful and extract the subversion
    if [ $EXIT_STATUS_NETWORK -eq 0 ]; then
        SUBVERSION=$(echo "$OUTPUT_NETWORK" | jq -r '.subversion')
        SUBVERSION=$(echo "$SUBVERSION" | sed 's/\///g') # Remove slashes
    else
        SUBVERSION="N/A"
    fi

    # Check if the command execution was successful
    if [ -n "$EXIT_STATUS_SMARTNODE" ] && [ "$EXIT_STATUS_SMARTNODE" -eq 0 ]; then
        # Extract the value of PoSePenalty from the JSON output using jq
        POSE_PENALTY=$(echo "$OUTPUT_SMARTNODE" | jq -r '.dmnState.PoSePenalty')
    
        # Fetch the balance for the payoutAddress
        PAYOUT_ADDRESS=$(echo "$OUTPUT_SMARTNODE" | jq -r '.dmnState.payoutAddress')
        BALANCE_RESPONSE=$(curl -s --connect-timeout 5 "https://explorer.neoxa.net/ext/getbalance/${PAYOUT_ADDRESS}")

        # Check if the balance response contains "error" or if it's empty (which could mean a timeout or a server error)
        if [[ -z "$BALANCE_RESPONSE" ]] || echo "$BALANCE_RESPONSE" | grep -q "error"; then
                # Balance could not be fetched
                CURRENT_BALANCE="N/A"
        else
                # Balance fetched successfully, format it
                CURRENT_BALANCE=$(printf "%'.2f" "$BALANCE_RESPONSE")
        fi

        # Check if POSE_PENALTY is not null before performing the comparison
        if [ "$POSE_PENALTY" != "null" ] && [ "$POSE_PENALTY" -eq 0 ]; then
            # Value of PoSePenalty is not null and is equal to 0
            ICON_COLOR="bg-green"
        else
            # Value of PoSePenalty is either null or not equal to 0
            ICON_COLOR="bg-red"
        fi
    else
        # Set default values if the command encountered an error
        POSE_PENALTY="N/A"
        ICON_COLOR="bg-grey"
        CURRENT_BALANCE="N/A"
    fi

    # Add the subversion and container status icons to the HTML content
    HTML_CONTENT+=" - Version: $SUBVERSION  - Last Header: $LAST_SYNCED_HEADER - Last Block: $LAST_SYNCED_BLOCK - Balance: $CURRENT_BALANCE <i class='bi bi-circle-fill $ICON_COLOR'></i>"

    HTML_CONTENT+="        </button>
          </h2>
          <div id='collapse$CONTAINER_ID' class='accordion-collapse collapse' aria-labelledby='heading$CONTAINER_ID' data-bs-parent='#accordion$CONTAINER_ID'>
            <div class='accordion-body'>
              <code><pre>"
    HTML_CONTENT+="$OUTPUT_SMARTNODE"
    HTML_CONTENT+="</pre></code>
            </div>
          </div>
        </div>
      </div>"

done <<< "$CONTAINER_INFO"

# Finish generating the HTML content
HTML_CONTENT+="</div>
</body>
</html>"

# Write the HTML content to the file
echo "$HTML_CONTENT" > smartnode-status.html
