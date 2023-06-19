#!/bin/bash

NEOXA_DIR="/var/lib/neoxa"

# Check ownership and permissions for the directory itself
if [[ $(stat -c %U:%G "$NEOXA_DIR") != "neoxa:neoxa" ]]; then
    echo "ERROR: Incorrect ownership for directory $NEOXA_DIR. It should be owned by neoxa:neoxa." >&2
    sleep 60
    exit 1
else
    echo "Directory $NEOXA_DIR has the correct ownership (neoxa:neoxa)."
fi

if [[ $(stat -c %a "$NEOXA_DIR") != "755" ]]; then
    echo "ERROR: Incorrect permissions for directory $NEOXA_DIR. It should have permissions set to 755." >&2
    sleep 60
    exit 1
else
    echo "Directory $NEOXA_DIR has the correct permissions (755)."
fi

# Check SELinux context for the directory itself
if [[ $(stat -c %C "$NEOXA_DIR") != *"container_file_t"* ]]; then
    echo "ERROR: Incorrect SELinux security context for directory $NEOXA_DIR." >&2
    sleep 60
    exit 1
else
    echo "Directory $NEOXA_DIR has the correct SELinux security context."
fi

# Check ownership for all subdirectories and files
if [ -n "$(find "$NEOXA_DIR" -mindepth 1)" ]; then
    while IFS= read -r -d '' file; do
        if [[ $(stat -c %U:%G "$file") != "neoxa:neoxa" ]]; then
            echo "ERROR: Incorrect file ownership for $file. It should be owned by neoxa:neoxa." >&2
            sleep 60
            exit 1
        fi
    done < <(find "$NEOXA_DIR" -mindepth 1 -print0)
else
    echo "No subdirectories or files found in $NEOXA_DIR. Skipping ownership check."
fi

# Check SELinux context for all subdirectories and files
if [ -n "$(find "$NEOXA_DIR" -mindepth 1)" ]; then
    while IFS= read -r -d '' file; do
        if [[ $(stat -c %C "$file") != *"container_file_t"* ]]; then
            echo "ERROR: SELinux permissions are incorrect for $file." >&2
            sleep 60
            exit 1
        fi
    done < <(find "$NEOXA_DIR" -mindepth 1 -print0)
else
    echo "No subdirectories or files found in $NEOXA_DIR. Skipping SELinux context check."
fi

# Check and remove line "daemon=1" from neoxa.conf
neoxa_conf="$NEOXA_DIR/neoxa.conf"
if grep -Fxq "daemon=1" "$neoxa_conf"; then
    sed -i '/^daemon=1$/d' "$neoxa_conf"
    echo "Removed line 'daemon=1' from $neoxa_conf."
else
    echo "Line 'daemon=1' not found in $neoxa_conf. Skipping removal."
fi

# Execute the specified command
echo "Executing the specified command: $@"
exec "$@"
