#!/usr/bin/env bash

# Use the full path to the working binary you just found
STEAM_CMD_PATH="/tmp/steamcmd.sh" 
DST_SERVER_DIR="/home/dst/.local/share/Steam"
DST_APP_ID="343050"

# Ensure these are set in your environment or defined here
STEAM_USER="${STEAM_USER:-anonymous}"
STEAM_PASS="${STEAM_PASS:-}"

# Construct the command
STEAM_COMMAND="+force_install_dir $DST_SERVER_DIR +login $STEAM_USER $STEAM_PASS +app_update $DST_APP_ID validate +quit"

echo "Running: $STEAM_CMD_PATH $STEAM_COMMAND"

# Execute without quotes around the variable so arguments parse correctly
$STEAM_CMD_PATH $STEAM_COMMAND
