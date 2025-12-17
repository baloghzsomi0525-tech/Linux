#!/bin/bash
# SHOW-OFF INSTALLER ARCADE EDITION
# ONE-KEY CONTROL | INSTALL | REMOVE | STATUS | BATMAN

set -u
export DEBIAN_FRONTEND=noninteractive

############################################
# SZÍNEK
############################################
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; MAGENTA="\e[35m"; CYAN="\e[36m"; NC="\e[0m"

############################################
# ROOT CHECK
############################################
[[ $EUID -ne 0 ]] && echo -e "${RED}Root kell!${NC}" && exit 1

############################################
# ÁLLAPOT
############################################
declare -A STATUS

set_status() { STATUS["$1"]="$2"; }

############################################
# SEGÉD
############################################
is_pkg() { dpkg -s "$1" >/dev/null 2>&1; }

key_menu() {
  local name="$1" state="$2"
  clear
  echo -e "${CYAN}=== $name ===${NC}"
  echo -e "Állapot: ${YELLOW}$state${NC}"
  echo
  echo -e "[i] Telepítés"
  echo -e "[d] Törlés"
  echo -e "[s] Kihagyás"
  echo -e "[q] Kilépés"
  echo
  read -rsn1 key
  echo "$key"
}

############################################
# TELEPÍT / TÖRÖL FUNKCIÓK
############################################
install_apache()    { apt install -y apache2 && systemctl enable --now apache2; }
remove_apache()     { systemctl stop apache2 2>/dev/null; apt purge -y apache2; }

install_ssh()       { apt install -y openssh-server && systemctl enable --now ssh; }
remove_ssh()        { systemctl stop ssh 2>/dev/null; apt purge -y openssh-server; }

install_mosquitto() { apt install -y mosquitto mosquitto-clients && systemctl enable --now mosquitto; }
remove_mosquitto()  { systemctl stop mosquitto 2>/dev/null; apt purge -y mosquitto mosquitto-clients; }

install_node_red() {
  curl -fsSL https://github.com/node-red/linux-installers/releases/latest/download/update-nodejs-and-nodered-deb \
    | bash -s -- --confirm-root --confirm-install --skip-pi
}
remove_node_red() {
  systemctl stop node-red@nodered 2>/dev/null
  apt purge -y nodejs nodered
  userdel -r nodered 2>/dev/null
}

install_mariadb()   { apt install -y mariadb-server && systemctl enable --now mariadb; }
remove_mariadb()    { systemctl stop mariadb 2>/dev/null; apt purge -y mariadb-server; }

install_php()       { apt install -y php libapache2-mod-php php-mysql; }
remove_php()        { apt purge -y php libapache2-mod-php php-mysql; }

install_ufw() {
  apt install -y ufw
  ufw allow OpenSSH
  ufw allow 80/tcp
  ufw allow 1880/tcp
  ufw allow 1883/tcp
  ufw --force enable
}
remove_ufw() {
  ufw --force disable
  apt purge -y ufw
}

############################################
# GENERIKUS KEZELŐ
############################################
handle() {
  local NAME="$1" PKG="$2" INSTALL="$3" REMOVE="$4"

  local state="NINCS TELEPÍTVE"
  is_pkg "$PKG" && state="TELEPÍTVE"

  key=$(key_menu "$NAME" "$state")

  case "$key" in
    i) $INSTALL && set_status "$NAME" "TELEPÍTVE" ;;
    d) $REMOVE  && set_status "$NAME" "TÖRÖLVE" ;;
    s) set_status "$NAME" "$state" ;;
    q) exit 0 ;;
    *) set_status "$NAME" "$state" ;;
  esac
}

############################################
# START
############################################
apt update

handle "Apache2"   "apache2"        install_apache   remove_apache
handle "SSH"       "openssh-server" install_ssh      remove_ssh
handle "Mosquitto" "mosquitto"      install_mosquitto remove_mosquitto
handle "Node-RED"  "nodejs"          install_node_red remove_node_red
handle "MariaDB"   "mariadb-server" install_mariadb  remove_mariadb
handle "PHP"       "php"             install_php      remove_php
handle "UFW"       "ufw"             install_ufw      remove_ufw

############################################
# ZENE – SMOOTH
############################################
if command -v yt-dlp >/dev/null && command -v mpv >/dev/null; then
  yt-dlp -f bestaudio -o - "https://www.youtube.com/watch?v=iAzagp0PXSk" \
    | mpv --no-video --really-quiet - &
fi

############################################
# BATMAN + STATUS
############################################
COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)

while true; do
  clear
  C=${COLORS[$RANDOM % ${#COLORS[@]}]}
   echo -e "   ${color}██████╗  █████╗ ████████╗███╗   ███╗ █████╗ ███╗   ██╗${NC}"
    echo -e "  ${color}██╔══██╗██╔══██╗╚══██╔══╝████╗ ████║██╔══██╗████╗  ██║${NC}"
    echo -e "  ${color}██████╔╝███████║   ██║   ██╔████╔██║███████║██╔██╗ ██║${NC}"
    echo -e "  ${color}██╔══██╗██╔══██║   ██║   ██║╚██╔╝██║██╔══██║██║╚██╗██║${NC}"
    echo -e "  ${color}██████╔╝██║  ██║   ██║   ██║ ╚═╝ ██║██║  ██║██║ ╚████║${NC}"
    echo -e "  ${color}╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"

  echo
  for s in Apache2 SSH Mosquitto Node-RED MariaDB PHP UFW; do
    echo -e " ${CYAN}$s${NC} : ${GREEN}${STATUS[$s]:-ISMERETLEN}${NC}"
  done
  sleep 0.5
done
