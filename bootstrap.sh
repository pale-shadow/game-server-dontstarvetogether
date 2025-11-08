#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 02/25/2025 initial version


#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.

#IFS=$'\n\t'

cluster_name="MyDediServer"
dontstarve_dir="/home/dst/.klei/DoNotStarveTogether"

function packages() {
  log_header "# --- install packages -------------------------------------------"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install podman containers-storage podman-compose -y
  sudo DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common 
  sudo apt-add-repository non-free; sudo dpkg --add-architecture i386; sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive sudo apt install -y steamcmd

  sudo dpkg --add-architecture i386
  
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libgl1-mesa-dri:amd64 \
    libgl1-mesa-dri:i386 \
    libgl1-mesa-glx:amd64 \
    libgl1-mesa-glx:i386 \
    steam-installer bzip2
}

function dst_user() {
  log_header "# --- dst user setup  ------------------------------------------------------"
  # clone the repo if it does not already exist
  sudo useradd -d /home/dst -g 60 -M -N -s /bin/bash -u 6969
  sudo chown -R dst:games /home/dst
  sudo chmod g+rw /home/dst
  sudo chmod g+rwx /home/dst/bin/*.sh
}

function main() {
  if [ -f "/usr/bin/figlet" ]; then
    figlet -f fonts/pagga "dont starve" && echo -e "\n"
  fi
  
  if [ -f "./bin/common.sh" ]; then
    source "./bin/common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"

  packages
  dst_user

  if [ ! -d "${dontstarve_dir}" ]; then mkdir -p "${dontstarve_dir}"; fi
  log_header "# --- updating dedi server application -------------------------------------------"
  steamcmd +login anonymous +app_update 343050 validate +quit
  # let the run_server script copy files into place and complete the configuration
}

main "$@"
