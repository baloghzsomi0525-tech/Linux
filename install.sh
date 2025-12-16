#!/bin/bash
# Show-Off Server Installer - FINAL FIXED EDITION
# Apache2 | SSH | Mosquitto | Node-RED | MariaDB | PHP | UFW
# Debian / Ubuntu / VirtualBox
# ROBUSZTUS + NODE-RED FIX

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
  if [[ "$DRY_RUN" == "true" ]]; then
    warn "[DRY-RUN] $*"
    return 0
  fi
  "$@"
}

############################################
# BANNER
############################################
clear
cat << "EOF"
=========================================
 SHOW-OFF SERVER INSTALLER vFINAL+NODEFIX
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
apt_update() {
  log "APT update"
  run apt-get update -y
}

apt_install() {
  log "APT install: $*"
  run apt-get install -y "$@"
}

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
install_apache() {
  apt_install apache2 || return 1
  run systemctl enable --now apache2 || return 1
}

install_ssh() {
  apt_install openssh-server || return 1
  run systemctl enable --now ssh || return 1
}

install_mosquitto() {
  apt_install mosquitto mosquitto-clients || return 1
  run systemctl enable --now mosquitto || return 1
}

install_mariadb() {
  apt_install mariadb-server || return 1
  run systemctl enable --now mariadb || return 1
}

install_php() {
  apt_install php libapache2-mod-php php-mysql || return 1
  run systemctl restart apache2 || return 1
}

install_ufw() {
  apt_install ufw || return 1
  run ufw allow OpenSSH || true
  run ufw allow 80/tcp || true
  run ufw allow 1880/tcp || true
  run ufw allow 1883/tcp || true
  run ufw --force enable || return 1
}

############################################
# NODE-RED – JAVÍTOTT, BIZTOSAN FUT
############################################
install_node_red() {
  apt_install curl ca-certificates build-essential || return 1

  log "Node-RED hivatalos installer futtatása"
  set +e
  curl -fsSL https://github.com/node-red/linux-installers/releases/latest/download/update-nodejs-and-nodered-deb \
    | bash -s -- --confirm-root --confirm-install --skip-pi
  set -e

  if ! id nodered >/dev/null 2>&1; then
    useradd -m -s /bin/bash nodered
  fi

  run systemctl daemon-reexec || true
  run systemctl daemon-reload || true

  if systemctl list-unit-files | grep -q '^nodered.service'; then
    run systemctl enable --now nodered.service || return 1
    return 0
  fi

  if systemctl list-unit-files | grep -q '^node-red.service'; then
    run systemctl enable --now node-red.service || return 1
    return 0
  fi

  if systemctl list-unit-files | grep -q '^node-red@\.service'; then
    run systemctl enable --now node-red@nodered.service || return 1
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
# FUTTATÁS
############################################
apt_update && ok "APT update kész" || warn "APT update hiba"

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
# HEALTH CHECK
############################################
echo
log "HEALTH CHECK"
for svc in apache2 ssh mosquitto mariadb node-red@nodered; do
  systemctl is-active --quiet "$svc" && ok "$svc RUNNING" || warn "$svc NEM FUT"
done

############################################
# ÖSSZEFOGLALÓ
############################################
echo
echo "=========== ÖSSZEFOGLALÓ ==========="
for k in "${!RESULTS[@]}"; do
  echo "$k : ${RESULTS[$k]}"
done

echo
echo -e "${GREEN}KÉSZ – telepítés befejezve.${NC}"
exit 0
