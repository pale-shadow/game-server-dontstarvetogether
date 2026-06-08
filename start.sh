#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 | 29 Sept 2023 | franklin <smoooth.y62wj@passmail.net>
# v0.2 | 12/27/2025 | update for common.sh

#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'

LRED='\033[0;31m'
NC='\033[0m' # No Color
SERVER_DIR="/home/dst"
DST_SERVER_DIR="${SERVER_DIR}/Steam/steamapps/common/Don\'t\ Starve\ Together\ Dedicated\ Server"
cluster_name="MyDediServer"
dontstarve_dir="${SERVER_DIR}/.klei/DoNotStarveTogether"

function game_update() {
  log_header "Updating game server files from Steam"
  # /home/dst/steamcmd/linux32/steamcmd +force_install_dir "$install_dir" +login anonymous +app_update 343050 validate +quit
  /home/dst/steamcmd/linux32/steamcmd +login "$STEAM_USER" "$STEAM_PASS" +app_update 343050 validate +quit

  # remove cache and reinstall files (use when corrupted)
  # rm -rf ~/.steam ~/.local/share/Steam ~/.steamcmd && mkdir -p ~/steamcmd && cd ~/steamcmd && wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd\_linux.tar.gz | tar -xzvf - && ./steamcmd.sh +login anonymous +app_update 343050 validate +quit
}

function set_password() {
  # make it so people need a password to get into server
  log_info "sed the server password"
  sed -i "s/cluster_password =/cluster_password = ${CLUSTER_TOKEN}/g" "${dontstarve_dir}/${cluster_name}/cluster.ini"
}

function mod_override(){
  log_header "Installing modoverrides.lua"
  cp ${SERVER_DIR}/saves/modoverrides.lua "${dontstarve_dir}/${cluster_name}/Master"
  # cp ${SERVER_DIR}/saves/modoverrides.lua "${dontstarve_dir}/${cluster_name}/Caves"
  cp ${SERVER_DIR}/saves/modoverrides.lua ${SERVER_DIR}/saves/dedicated_server_mods_setup.lua "${DST_SERVER_DIR}/mods"
}

function config_shards() {
  log_header "COnfigure the shards"
  cp ${SERVER_DIR}/saves/dedicated_server_mods_setup.lua "${dontstarve_dir}/${cluster_name}"
  log_header "Copying worldgenoverride.lua"
  # ${dontstarve_dir}/${cluster_name}/worldgenoverride.lua
  cp ${SERVER_DIR}/saves/worldgenoverride.lua "${dontstarve_dir}/${cluster_name}"
  log_header "Copying cluster token into server files"
  echo "${CLUSTER_TOKEN}" >"${dontstarve_dir}/${cluster_name}/cluster_token.txt"
  check_for_file "$dontstarve_dir/$cluster_name/cluster_token.txt"
  cp "$${SERVER_DIR}/saves/cluster.ini" "${dontstarve_dir}/${cluster_name}/cluster.ini"

}

function main() {
  echo -e "\n" && figlet -f /usr/share/figlet/fonts/pagga dont starve together && echo -e "\n"
  if [ -f "${SERVER_DIR}/bin/common.sh" ]; then
    source "${SERVER_DIR}/bin/common.sh"
  else
    echo -e "${LRED}can not find ${SERVER_DIR}/bin/common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced ${SERVER_DIR}/bin/common.sh" && echo -e "\n"

  log_header "Installing our custom server files"
  # mod_override
  # config_shards
  # set_password

  check_for_file "${dontstarve_dir}/${cluster_name}/cluster.ini"
  check_for_file "${dontstarve_dir}/${cluster_name}/Master/server.ini"
  check_for_file "${dontstarve_dir}/${cluster_name}/Caves/server.ini"

  log_warn "If any players cannot see the server in the list, they should update their game files from Steam and check Java version."
   
  # game_update

  log_header "Starting the server."

  pushd "${SERVER_DIR}/Steam/steamapps/common/Don't Starve Together Dedicated Server/bin64"
  log_info "Start servers"

  run_shared=(./dontstarve_dedicated_server_nullrenderer_x64)
  run_shared+=(-cluster "$cluster_name")
  
  "${run_shared[@]}" -shard Caves | sed 's/^/Caves:  /' &
  "${run_shared[@]}" -shard Master | sed 's/^/Master: /'

  popd >> /dev/null || exit 1
  log_info "done!"

}

main "$@"

