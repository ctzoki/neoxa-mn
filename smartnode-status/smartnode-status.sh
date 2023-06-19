#!/bin/bash

# Check if the script is running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo." >&2  # Redirected to stderr
    exit 1
fi

# Execute the command and store the output in a variable
CONTAINER_INFO=$(podman ps --format "{{.ID}}:{{.Names}}:{{.Image}}" | grep "node")

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
</head>
<body>
  <div class='container'>
    <br/>
    <h1>Smartnode Status</h1>
    <br/>"

# Loop through each container info and execute the desired command
while IFS=: read -r CONTAINER_ID CONTAINER_NAME CONTAINER_IMAGE; do
    HTML_CONTENT+="<div class='accordion' id='accordion$CONTAINER_ID'>
      <div class='accordion-item'>
        <h2 class='accordion-header' id='heading$CONTAINER_ID'>
          <button class='accordion-button collapsed' type='button' data-bs-toggle='collapse' data-bs-target='#collapse$CONTAINER_ID' aria-expanded='false' aria-controls='collapse$CONTAINER_ID'>
            Container: $CONTAINER_NAME"

    # Execute the command and capture the output and error
    OUTPUT=$(podman exec "$CONTAINER_ID" /app/neoxa-cli -datadir=/var/lib/neoxa smartnode status 2>&1)
    EXIT_STATUS=$?

    # Check if the command execution was successful
    if [ $EXIT_STATUS -eq 0 ]; then
        # Extract the value of PoSePenalty from the JSON output using jq
        POSE_PENALTY=$(echo "$OUTPUT" | jq -r '.dmnState.PoSePenalty')

        # Check the value of PoSePenalty and determine the icon color
        if [ "$POSE_PENALTY" -eq 0 ]; then
            ICON_COLOR="bg-green"
        else
            ICON_COLOR="bg-red"
        fi
    else
        # Set default values if the command encountered an error
        POSE_PENALTY="N/A"
        ICON_COLOR="bg-grey"
    fi

    # Add the container status and icon to the HTML content
    HTML_CONTENT+="<i class='bi bi-circle-fill $ICON_COLOR'></i>"

    HTML_CONTENT+="        </button>
          </h2>
          <div id='collapse$CONTAINER_ID' class='accordion-collapse collapse' aria-labelledby='heading$CONTAINER_ID' data-bs-parent='#accordion$CONTAINER_ID'>
            <div class='accordion-body'>
              <code><pre>"
    HTML_CONTENT+="$OUTPUT"
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
