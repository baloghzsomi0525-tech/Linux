#!/bin/bash
# Show-Off Server Installer - FINAL + CHECK + PROMPT
# Apache | SSH | Mosquitto | Node-RED | MariaDB | PHP | UFW
# Batman ASCII + YouTube Music 🎵🦇

set -u
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

############################################
# KONFIG
############################################
CONFIG_FILE="./config.conf"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

: "${DRY_RUN:=false}"
: "${LOGFILE:=/var/log/showoff_installer.log}"

############################################
# SZÍNEK
############################################
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; MAGENTA="\e[35m"; CYAN="\e[36m"; NC="\e[0m"

############################################
# ROOT CHECK
############################################
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo -e "${RED}Root jogosultság szükséges.${NC}"
  exit 1
fi

############################################
# LOG
############################################
mkdir -p "$(dirname "$LOGFILE")"
touch "$LOGFILE"

log()  { echo "$(date '+%F %T') | $1" >> "$LOGFILE"; }
ok()   { echo -e "${GREEN}✔ $1${NC}"; log "OK: $1"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; log "WARN: $1"; }
fail() { echo -e "${RED}✖ $1${NC}"; log "FAIL: $1"; }

run() {
  [[ "$DRY_RUN" == "true" ]] && { warn "[DRY-RUN] $*"; return 0; }
  "$@"
}

############################################
# BANNER
############################################
clear
cat << "EOF"
=========================================
 SHOW-OFF SERVER INSTALLER
 Apache | Node-RED | MQTT | MariaDB | PHP
=========================================
EOF
echo -e "${BLUE}Logfile:${NC} $LOGFILE"
echo

############################################
# APT
############################################
apt_update()  { run apt-get update -y; }
apt_install() { run apt-get install -y "$@"; }

############################################
# ELLENŐRZŐK
############################################
is_installed_pkg() {
  dpkg -s "$1" >/dev/null 2>&1
}

is_active_service() {
  systemctl list-unit-files | grep -q "^$1"
}

ask_install() {
  read -rp "👉 Telepítsem? (y/n): " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

############################################
# TELEPÍTŐK
############################################
install_apache() {
  is_installed_pkg apache2 && { ok "Apache már telepítve van"; return 0; }
  ask_install || { warn "Apache kihagyva"; return 0; }
  apt_install apache2 && run systemctl enable --now apache2
}

install_ssh() {
  is_installed_pkg openssh-server && { ok "SSH már telepítve van"; return 0; }
  ask_install || { warn "SSH kihagyva"; return 0; }
  apt_install openssh-server && run systemctl enable --now ssh
}

install_mosquitto() {
  is_installed_pkg mosquitto && { ok "Mosquitto már telepítve van"; return 0; }
  ask_install || { warn "Mosquitto kihagyva"; return 0; }
  apt_install mosquitto mosquitto-clients && run systemctl enable --now mosquitto
}

install_mariadb() {
  is_installed_pkg mariadb-server && { ok "MariaDB már telepítve van"; return 0; }
  ask_install || { warn "MariaDB kihagyva"; return 0; }
  apt_install mariadb-server && run systemctl enable --now mariadb
}

install_php() {
  is_installed_pkg php && { ok "PHP már telepítve van"; return 0; }
  ask_install || { warn "PHP kihagyva"; return 0; }
  apt_install php libapache2-mod-php php-mysql && run systemctl restart apache2
}

install_ufw() {
  is_installed_pkg ufw && { ok "UFW már telepítve van"; return 0; }
  ask_install || { warn "UFW kihagyva"; return 0; }
  apt_install ufw
  run ufw allow OpenSSH
  run ufw allow 80/tcp
  run ufw allow 1880/tcp
  run ufw allow 1883/tcp
  run ufw --force enable
}

############################################
# NODE-RED (SPECIÁLIS)
############################################
install_node_red() {
  command -v node-red >/dev/null 2>&1 && { ok "Node-RED már telepítve van"; return 0; }
  ask_install || { warn "Node-RED kihagyva"; return 0; }

  apt_install curl ca-certificates build-essential || return 1

  curl -fsSL https://github.com/node-red/linux-installers/releases/latest/download/update-nodejs-and-nodered-deb \
    | bash -s -- --confirm-root --confirm-install --skip-pi

  id nodered >/dev/null 2>&1 || useradd -m -s /bin/bash nodered

  systemctl daemon-reload

  if systemctl list-unit-files | grep -q '^node-red@\.service'; then
    run systemctl enable --now node-red@nodered.service
  else
    su - nodered -c "nohup node-red >/home/nodered/node-red.log 2>&1 &"
  fi
}

############################################
# YT + MPV
############################################
install_yt_deps() {
  command -v mpv >/dev/null 2>&1 || apt_install mpv
  command -v yt-dlp >/dev/null 2>&1 || apt_install python3-pip && pip3 install yt-dlp
}

############################################
# BATMAN + ZENE
############################################
celebrate() {
  local colors=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN")
  local YT_URL="https://www.youtube.com/watch?v=iAzagp0PXSk"

  if command -v yt-dlp && command -v mpv; then
    (while true; do yt-dlp -o - "$YT_URL" | mpv - >/dev/null 2>&1; done) &
  fi

  while true; do
    clear
    color=${colors[$RANDOM % ${#colors[@]}]}
    echo -e "   ${color}██████╗  █████╗ ████████╗███╗   ███╗ █████╗ ███╗   ██╗${NC}"
    echo -e "   ${color}██╔══██╗██╔══██╗╚══██╔══╝████╗ ████║██╔══██╗████╗  ██║${NC}"
    echo -e "   ${color}██████╔╝███████║   ██║   ██╔████╔██║███████║██╔██╗ ██║${NC}"
    echo -e "   ${color}██╔══██╗██╔══██║   ██║   ██║╚██╔╝██║██╔══██║██║╚██╗██║${NC}"
    echo -e "   ${color}██████╔╝██║  ██║   ██║   ██║ ╚═╝ ██║██║  ██║██║ ╚████║${NC}"
    echo -e "   ${color}╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo
    echo -e "        ${color}MEGVAN A 4-ES? XD${NC}"
    sleep 0.4
  done
}

############################################
# FUTTATÁS
############################################
apt_update

install_apache
install_ssh
install_mosquitto
install_node_red
install_mariadb
install_php
install_ufw
install_yt_deps

echo -e "${GREEN}🎬 TELEPÍTÉS BEFEJEZVE!${NC}"
sleep 1
celebrate
