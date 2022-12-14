#!/bin/bash
PTERODACTYL_PATH="/var/www/pterodactyl"
WINGS_PATH="/usr/local/bin/wings"
UPDATE_PANEL=1 # 0 to disable
UPDATE_WINGS=1 # 0 to disable

check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be executed with root privileges." 1>&2
    exit 1
  fi
}

check_command() {
  if ! [ -x "$(command -v $1)" ]; then
    echo "Error: $1 is not installed." >&2
    exit 1
  fi
}

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

get_current_wings_release() {
  $WINGS_PATH version | sed -nE 's/wings (.+)/\1/p'
}

get_current_panel_release() {
  grep "'version'" "$PTERODACTYL_PATH/config/app.php" | cut -c18-25 | sed "s/[',]//g"
}

check_root
check_command curl
check_command grep
check_command cut

if [ $UPDATE_PANEL -eq 1 ]; then
  echo "Checking For Panel Updates..."
  latest_panel_release=$(get_latest_release "pterodactyl/panel")
  current_panel_release=$(get_current_panel_release)
  if [ "$latest_panel_release" != "v$current_panel_release" ]; then
    echo "Updating to $latest_panel_release..."
    cd $PTERODACTYL_PATH && php artisan p:upgrade -qn
    echo "Panel updated successfully."
  fi
fi

if [ $UPDATE_WINGS -eq 1 ]; then
  echo "Checking For Wings Updates..."
  latest_wings_release=$(get_latest_release "pterodactyl/wings")
  current_wings_release=$(get_current_wings_release)
  if [ "$latest_wings_release" != "$current_wings_release" ]; then
    echo "Updating to $latest_wings_release..."
    curl -L --silent -o $WINGS_PATH "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
    chmod u+x $WINGS_PATH
    systemctl restart wings
    echo "Wings updated successfully."
  fi
fi
