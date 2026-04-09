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
# LOGIN RÉSZ
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
# MAPPÁK LÉTREHOZÁSA
# =========================
rm -rf "$BASE" 2>/dev/null
mkdir -p "$BASE"
cd "$BASE"

mkdir -p Logs Backup Temp Secrets Data
mkdir -p Discord/szerverek

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
    echo "└── Discord/"
    echo "    └── szerverek/"
    ls Discord/szerverek
fi

echo ""
echo "========================================="
echo "💡 TIPP: cd, ls, rm -r"
echo "🎯 Feladat: töröld a hibás szervert"
echo ""

# =========================
# INTERAKTÍV SHELL
# =========================
cd "$BASE"
export PS1="(DISCORD-SERVER) $ "

bash &
SHELL_PID=$!

# =========================
# FIGYELÉS
# =========================
TARGET="$BASE/Discord/szerverek/szarfos"

while true
do
    if [ ! -d "$TARGET" ]; then
        kill $SHELL_PID 2>/dev/null
        break
    fi
    sleep 1
done

# =========================
# RIASZTÁS + COUNTDOWN
# =========================
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
echo "❌ IDŐ LEJÁRT - RENDSZER ZÁROLVA"
exit
