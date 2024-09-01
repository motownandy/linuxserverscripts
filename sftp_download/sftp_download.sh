#!/bin/bash

# Variables
REMOTE_SERVER="your.server.com"
REMOTE_USER="your_username"

# Define the remote and local folder pairs
declare -A FOLDER_PAIRS=(
    ["/path/to/remote/folder1"]="/path/to/local/folder1"
    ["/path/to/remote/folder2"]="/path/to/local/folder2"
    ["/path/to/remote/folder3"]="/path/to/local/folder3"
)

# Set to true if you want to download directories recursively
RECURSIVE=false

# Log file
LOG_FILE="sftp_download.log"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to download all files from a remote folder to a local folder
download_all_files() {
    local remote_folder="$1"
    local local_folder="$2"
    local recursive="$3"

    # Create local directory if it doesn't exist
    mkdir -p "$local_folder"

    # Start the SFTP connection
    sftp "$REMOTE_USER@$REMOTE_SERVER" <<EOF
cd "$remote_folder" || { echo "Remote folder $remote_folder does not exist." ; exit 1; }
lcd "$local_folder"
$( [ "$recursive" = true ] && echo "get -r *" || echo "mget *" )
bye
EOF

    if [ $? -eq 0 ]; then
        log "Successfully downloaded from $remote_folder to $local_folder"
    else
        log "Failed to download from $remote_folder to $local_folder"
    fi
}

# Loop through the folder pairs and download files
for remote_folder in "${!FOLDER_PAIRS[@]}"; do
    local_folder="${FOLDER_PAIRS[$remote_folder]}"
    log "Starting download from $remote_folder to $local_folder"
    download_all_files "$remote_folder" "$local_folder" "$RECURSIVE"
done

log "All downloads completed."
