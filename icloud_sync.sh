#!/bin/bash

# Variable to enable or disable logging (Y/N)
ENABLE_LOGGING="Y"

# Configuration variables
USER="your_username"
SRC="/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs/YourDocuments/"
SSH_USER="your_ssh_user"
SSH_PASSWORD="your_password"
SSH_HOST="your_ssh_host"
DEST="/path/to/your/destination/."
LOG_FILE="/var/log/icloud_sync.log"
FSWATCH="/opt/homebrew/bin/fswatch"
RSYNC="/opt/homebrew/bin/rsync"
# Exclusion variables (exclude)
EXCLUDE_PATTERNS=(
    "/._*"
    ".DS_Store"
    ".AppleDouble"
    ".Trashes"
    ".TemporaryItems"
    ".Spotlight-V100"
    ".ds_store"
    "@eaDir"
)

# Function for conditional logging
log_message() {
    if [ "$ENABLE_LOGGING" == "Y" ]; then
        echo "$(date): $1" >> "$LOG_FILE"
    fi
}

# Function to execute commands with or without logging
run_command() {
    if [ "$ENABLE_LOGGING" == "Y" ]; then
        "$@" >> "$LOG_FILE" 2>&1
    else
        "$@" > /dev/null 2>&1
    fi
}

# Function to run rsync over SSH with login and password
sync_icloud() {
    log_message "Starting synchronization (rsync call)"

    # Prepare the exclusion list for rsync
    EXCLUDE_STRING=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        EXCLUDE_STRING+="--exclude=$pattern "
    done

    # Execute rsync with exclusions
    run_command sshpass -p "$SSH_PASSWORD" $RSYNC --verbose --recursive --delete-before --whole-file --times --ignore-errors --no-perms \
    --iconv=UTF-8,UTF-8 --protect-args -a $EXCLUDE_STRING \
    --rsh="sshpass -p $SSH_PASSWORD ssh -o StrictHostKeyChecking=no" \
    "$SRC" "$SSH_USER@$SSH_HOST:$DEST"

    log_message "Synchronization completed"
}

# Function to force loading of the iCloud directory
warmup_icloud() {
    log_message "Forcing the loading of the iCloud directory"
    ls "$SRC" > /dev/null 2>&1
}

# Function to check if the destination directory exists, and if not, create it and assign the correct permissions
check_and_create_dest() {
    log_message "Checking if the destination directory exists"
    # Create the directory and assign the correct permissions with chown
    run_command sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" "
        mkdir -p /media/ssd/data/SYS-DOCKER/iCloud/ &&
        chown -R $SSH_USER:$SSH_USER /media/ssd/data/SYS-DOCKER/iCloud/
    "
    log_message "Destination directory checked/created and permissions set"
}

# Start monitoring with fswatch
start_fswatch() {
    log_message "Starting to monitor the directory $SRC"
    $FSWATCH -o "$SRC" | while read; do
        log_message "Change detected by fswatch, starting rsync"
        sync_icloud
    done
}

# Perform the warm-up, check the destination directory, then monitor changes
warmup_icloud
check_and_create_dest  # Check or create the destination directory and set permissions
sync_icloud  # Perform an initial synchronization
start_fswatch  # Activate fswatch to monitor for changes
