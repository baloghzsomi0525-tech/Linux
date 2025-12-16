#!/bin/bash
# Show-Off Server Installer - FINAL + NODE-RED + BATMAN ANIM + YT MUSIC
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
MAGENTA="\e[35m"
CYAN="\e[36m"
NC="\e[0m"

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
mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true
touch "$LOGFILE" 2>/dev/null || true

log() { echo "$(date '+%F %T') | $1" | tee -a "$LOGFILE" >/dev/null; }
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
# EREDMÉNYEK
############################################
declare -A RESULTS
set_result() { RESULTS["$1"]="$2"; }

############################################
# APT
############################################
apt_update() { run apt-get update -y; }
apt_install() { run apt-get install -y "$@"; }

safe_step() {
  local label="$1"; shift
  if "$@"; then
    set_result "$label" "SIKERES"
    return 0
  else
    set_result "$label" "HIBA"
    return 1
  fi
}

############################################
# TELEPÍTŐK
############################################
install_apache()   { apt_install apache2 && run systemctl enable --now apache2; }
install_ssh()      { apt_install openssh-server && run systemctl enable --now ssh; }
install_mosquitto(){ apt_install mosquitto mosquitto-clients && run systemctl enable --now mosquitto; }
install_mariadb()  { apt_install mariadb-server && run systemctl enable --now mariadb; }
install_php()      { apt_install php libapache2-mod-php php-mysql && run systemctl restart apache2; }

install_ufw() {
  apt_install ufw || return 1
  run ufw allow OpenSSH || true
  run ufw allow 80/tcp || true
  run ufw allow 1880/tcp || true
  run ufw allow 1883/tcp || true
  run ufw --force enable
}

############################################
# NODE-RED – FIX
############################################
install_node_red() {
  apt_install curl ca-certificates build-essential || return 1

  set +e
  curl -fsSL https://github.com/node-red/linux-installers/releases/latest/download/update-nodejs-and-nodered-deb \
    | bash -s -- --confirm-root --confirm-install --skip-pi
  set -e

  id nodered >/dev/null 2>&1 || useradd -m -s /bin/bash nodered

  run systemctl daemon-reexec || true
  run systemctl daemon-reload || true

  if systemctl list-unit-files | grep -q '^node-red@\.service'; then
    run systemctl enable --now node-red@nodered.service
    return 0
  fi

  if command -v node-red >/dev/null 2>&1; then
    su - nodered -c "nohup node-red >/home/nodered/node-red.log 2>&1 &"
    sleep 3
    pgrep -f node-red >/dev/null && return 0
  fi

  return 1
}

############################################
# BATMAN VILLOGÁS + YOUTUBE ZENE
############################################
celebrate() {
  local colors=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN")
  local YT_URL="https://www.youtube.com/watch?v=iAzagp0PXSk"

  # Ellenőrzés: yt-dlp és mpv telepítve
  if ! command -v yt-dlp >/dev/null 2>&1 || ! command -v mpv >/dev/null 2>&1; then
    warn "YT lejátszáshoz telepítsd a yt-dlp és mpv csomagot!"
    return
  fi

  # Hang lejátszása háttérben folyamatosan
  (while true; do
     yt-dlp -o - "$YT_URL" | mpv - >/dev/null 2>&1
   done) &

  # Villogó Batman ASCII
  while true; do
    clear
    color=${colors[$RANDOM % ${#colors[@]}]}
    echo -e "\n\n"
    echo -e "   ${color}██████╗  █████╗ ████████╗███╗   ███╗ █████╗ ███╗   ██╗${NC}"
    echo -e "   ${color}██╔══██╗██╔══██╗╚══██╔══╝████╗ ████║██╔══██╗████╗  ██║${NC}"
    echo -e "   ${color}██████╔╝███████║   ██║   ██╔████╔██║███████║██╔██╗ ██║${NC}"
    echo -e "   ${color}██╔══██╗██╔══██║   ██║   ██║╚██╔╝██║██╔══██║██║╚██╗██║${NC}"
    echo -e "   ${color}██████╔╝██║  ██║   ██║   ██║ ╚═╝ ██║██║  ██║██║ ╚████║${NC}"
    echo -e "   ${color}╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo
    echo -e "        ${color}MEGVAN A 3-MAS? XD${NC}"
    sleep 0.4
  done
}

############################################
# FUTTATÁS
############################################
apt_update || warn "APT update hiba"

run_install() {
  local var="$1" label="$2" func="$3"
  echo -e "${BLUE}==> $label${NC}"
  if [[ "${!var}" == "true" ]]; then
    safe_step "$label" "$func" && ok "$label OK" || fail "$label HIBA"
  else
    warn "$label kihagyva"
    set_result "$label" "KIHAGYVA"
  fi
  echo
}

run_install INSTALL_APACHE     "Apache2"   install_apache
run_install INSTALL_SSH        "SSH"       install_ssh
run_install INSTALL_MOSQUITTO  "Mosquitto" install_mosquitto
run_install INSTALL_NODE_RED   "Node-RED"  install_node_red
run_install INSTALL_MARIADB    "MariaDB"   install_mariadb
run_install INSTALL_PHP        "PHP"       install_php
run_install INSTALL_UFW        "UFW"       install_ufw

############################################
# VÉGE 🎬
############################################
echo -e "${GREEN}KÉSZ – telepítés befejezve.${NC}"
sleep 1
celebrate
exit 0
