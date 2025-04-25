#!/bin/bash

# Define the source and destination paths
SOURCE_PATH="./bin/ozw672_script.pl"
DESTINATION_PATH="/usr/local/bin/ozw672_script.pl"
LOG_FILE="/opt/loxberry/log/plugins/ozw672_plugin/log.txt"

# Log the start of the script
echo "$(date '+%Y-%m-%d %H:%M:%S') - Running MyPlugin Script" >> "$LOG_FILE"

# # Copy the Perl script to the destination path
# if cp "$SOURCE_PATH" "$DESTINATION_PATH"; then
#     echo "$(date '+%Y-%m-%d %H:%M:%S') - ozw672_script.pl has been copied to $DESTINATION_PATH" >> "$LOG_FILE"
# else
#     echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to copy ozw672_script.pl to $DESTINATION_PATH" >> "$LOG_FILE"
#     exit 1
# fi

# # Set the correct permissions to make the script executable
# if chmod +x "$DESTINATION_PATH"; then
#     echo "$(date '+%Y-%m-%d %H:%M:%S') - Permissions set to make ozw672_script.pl executable" >> "$LOG_FILE"
# else
#     echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to set permissions on $DESTINATION_PATH" >> "$LOG_FILE"
#     exit 1
# fi

# # Log the end of the script
# echo "$(date '+%Y-%m-%d %H:%M:%S') - MyPlugin Script completed" >> "$LOG_FILE"