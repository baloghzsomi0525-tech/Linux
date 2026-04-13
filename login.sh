#!/bin/bash
 
BASE="$HOME/escape_room"
 
clear
 
echo "========================================="
echo "        DISCORD ADMIN TERMINAL"
echo "========================================="
echo ""
echo "⚠️ Rendszergazda hitelesítés szükséges"
echo ""
echo "Titkos információ:"
echo "Felhasználónév: +>@1M7"
echo "Jelszó: 8O(#\`="
echo ""
echo "-----------------------------------------"
 
# =========================
# LOGIN
# =========================
while true
do
    read -p "Felhasználónév: " user
    read -s -p "Jelszó: " pass
    echo ""
 
    if [[ "$user" == "Balint" && "$pass" == "Bolyai" ]]; then
        echo ""
        echo "✅ Hozzáférés megadva"
        sleep 2
        break
    else
        echo ""
        echo "❌ Hibás adatok! Próbáld újra..."
        sleep 2
        clear
        echo "Titkos információ:"
        echo "Felhasználónév: +>@1M7"
        echo "Jelszó: 8O(#\`="
        echo ""
    fi
done
 
clear
echo "Belépve a rendszerbe..."
sleep 2
 
# =========================
# NODE-RED TELEPÍTÉS
# =========================
if ! command -v node-red &> /dev/null
then
    echo "📦 Node-RED telepítése..."
    sudo apt update
    sudo apt install -y nodejs npm
    sudo npm install -g --unsafe-perm node-red
 
    cd ~/.node-red 2>/dev/null || mkdir ~/.node-red && cd ~/.node-red
    npm install node-red-dashboard
fi
 
# =========================
# NODE-RED INDÍTÁS
# =========================
echo "🚀 Node-RED indítása..."
node-red &
 
sleep 5
 
# =========================
# MAPPÁK + CLUE-K
# =========================
rm -rf "$BASE" 2>/dev/null
mkdir -p "$BASE"
cd "$BASE"
 
mkdir -p Logs Backup Temp Secrets Data Config
mkdir -p Discord/szerverek
 
# =========================
# CLUE FÁJLOK
# =========================
 
# 🌡️ HŐMÉRSÉKLET
echo "WARNING: Server unstable below 15°C" > Logs/system.log
 
# 🔐 SAFE
echo "Backup rotation sequence: 6 -> 15 -> 8" > Secrets/backup.txt
 
# ⚙️ KAPCSOLÓK
echo "Power sequence: ON OFF ON" > Config/power.conf
 
# 🔘 GOMB
echo "Hold button for 5 seconds to confirm override" > Data/button.txt
 
# =========================
# SZERVER LISTA
# =========================
cd Discord/szerverek
 
servers=(
alpha beta gamma delta epsilon zeta theta omega nexus titan
matrix cyber void shadow neon quantum vortex pixel arcadia
szarfos
)
 
for s in "${servers[@]}"
do
    mkdir -p "$s"
done
 
# =========================
# VIZUÁLIS NÉZET
# =========================
cd "$BASE"
 
clear
echo "📂 RENDSZER ELÉRÉS MEGADVA"
echo "========================================="
echo ""
 
if command -v tree &> /dev/null
then
    tree
else
    echo "escape_room/"
    echo "├── Logs"
    echo "├── Backup"
    echo "├── Temp"
    echo "├── Secrets"
    echo "├── Data"
    echo "├── Config"
    echo "└── Discord/"
    echo "    └── szerverek/"
    ls Discord/szerverek
fi
 
echo ""
echo "========================================="
echo "💡 TIPP: Nézz körül a fájlok között!"
echo "📄 Hasznos parancsok: cat, ls, cd"
echo "🎯 Feladat: töröld a hibás szervert"
echo ""
echo "🌐 Dashboard: http://localhost:1880/ui"
echo ""
 
xdg-open http://localhost:1880/ui 2>/dev/null &
 
# =========================
# WATCHER
# =========================
(
TARGET="$BASE/Discord/szerverek/szarfos"
 
while true
do
    if [ ! -d "$TARGET" ]; then
 
        clear
        echo "========================================="
        echo "🚨 SECURITY ALERT 🚨"
        echo "========================================="
        echo ""
        echo "⚠️ BETOLAKODÓ ÉSZLELVE"
        echo "⚠️ RENDSZER LEZÁRÁS AKTIVÁLVA"
        echo ""
        echo "⏳ VISSZASZÁMLÁLÁS ELINDULT (10:00)"
        echo ""
        echo "🌐 Nyisd meg: http://localhost:1880/ui"
        echo ""
 
        seconds=600
 
        while [ $seconds -gt 0 ]
        do
            min=$((seconds / 60))
            sec=$((seconds % 60))
            printf "\r⏳ Hátralévő idő: %02d:%02d " $min $sec
            sleep 1
            ((seconds--))
        done
 
        echo ""
        echo ""
        echo "🚓 ELKAPTAK A RENDŐRÖK!"
        echo "❌ VESZTETTÉL"
        echo ""
        echo "Kilépés 10 másodperc múlva..."
 
        sleep 10
 
        pkill -P $$ 2>/dev/null
        exit
    fi
    sleep 1
done
) &
 
# =========================
# SHELL
# =========================
cd "$BASE"
export PS1="(DISCORD-SERVER) $ "
exec bash
