#!/bin/bash
# Show-Off Server Installer - FINAL + NODE-RED FIX + BATMAN LOGO
# Apache | SSH | Mosquitto | Node-RED | MariaDB | PHP | UFW
# Debian / Ubuntu / VirtualBox

set -u
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

############################################
# KONFIG
############################################
CONFIG_FILE="./config.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "WARN: config.conf nem található, alapértelmezett értékekkel futok."
fi

: "${DRY_RUN:=false}"
: "${INSTALL_APACHE:=true}"
: "${INSTALL_SSH:=true}"
: "${INSTALL_NODE_RED:=true}"
: "${INSTALL_MOSQUITTO:=true}"
: "${INSTALL_MARIADB:=true}"
: "${INSTALL_PHP:=true}"
: "${INSTALL_UFW:=true}"
: "${LOGFILE:=/var/log/showoff_installer.log}"

############################################
# SZÍNEK
############################################
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"

############################################
# ROOT CHECK
