#!/bin/bash

# Script: update_dst_perms.sh
# Description: Updates permissions for Don't Starve Together server files on 'chonk' host.
# Sets directories to 2775 (setgid), executables to 775, and regular files to 664.
# Integrates with bin/common.sh for environment configuration.

# --- Integration ---
# Calculate script directory and source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/common.sh" ]]; then
    source "${SCRIPT_DIR}/common.sh"
elif [[ -f "${SCRIPT_DIR}/bin/common.sh" ]]; then
    source "${SCRIPT_DIR}/bin/common.sh"
else
    echo "Warning: bin/common.sh not found. Using default configurations."
fi

# --- Configuration ---
# DST_DIR should point to the root of your server installation (e.g., /home/dst)
DST_DIR="${DST_DIR:-/home/dst}" 
TARGET_GROUP="${TARGET_GROUP:-games}"
SERVICE_USER="${SERVICE_USER:-dst}"

# --- Safety Checks ---
# Must be run as root to change ownership
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root or via sudo."
   exit 1
fi

# Ensure the directory exists
if [ ! -d "$DST_DIR" ]; then
    echo "Error: Target directory $DST_DIR not found."
    exit 1
fi

echo "--- Starting Permission Update on Chonk ---"

# 1. Update Ownership
# Sets the service user as owner and the 'games' group as the group owner
echo "Setting ownership to $SERVICE_USER:$TARGET_GROUP..."
chown -R "$SERVICE_USER:$TARGET_GROUP" "$DST_DIR"

# 2. Update Directories
# Sets 2775: '2' is the setgid bit (new files inherit the 'games' group)
# '775' allows owner/group to read, write, and traverse.
echo "Updating directories to 2775 (drwxrwsr-x)..."
find "$DST_DIR" -type d -exec chmod 2775 {} +

# 3. Update Regular Files (Text/Data)
# Sets 664: Owner/Group can read and write; others can only read.
echo "Updating regular files to 664 (rw-rw-r--)..."
find "$DST_DIR" -type f -exec chmod 664 {} +

# 4. Restore Executables
# Certain files (scripts and binaries) must be 775 to run.
# We look for shell scripts and the specific DST dedicated server binaries.
echo "Restoring 775 permissions to binaries and scripts..."
find "$DST_DIR" -type f \( -name "*.sh" -o -name "dontstarve_dedicated_server_nullrenderer*" \) -exec chmod 775 {} +

echo "--- Permissions Update Complete ---"
echo "Summary:"
echo " - Source: bin/common.sh (if present)"
echo " - Owner: $SERVICE_USER"
echo " - Group: $TARGET_GROUP (with write access)"
echo " - Directory Logic: setgid enabled (2775)"
echo " - Text/Data: 664"
echo " - Executables: 775"
