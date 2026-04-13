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
 
# LOGIN

while true

do

    read -p "Felhasználónév: " user

    read -s -p "Jelszó: " pass

    echo ""
 
    if [[ "$user" == "Balint" && "$pass" == "Bolyai" ]]; then

        echo "✅ Hozzáférés megadva"

        sleep 2

        break

    else

        echo "❌ Hibás adatok!"

        sleep 2

        clear

    fi

done
 
clear

echo "Belépve a rendszerbe..."

sleep 2
 
# NODE-RED

if ! command -v node-red &> /dev/null

then

    sudo apt update

    sudo apt install -y nodejs npm

    sudo npm install -g --unsafe-perm node-red

    mkdir -p ~/.node-red && cd ~/.node-red

    npm install node-red-dashboard

fi
 
node-red &

sleep 5
 
# MAPPÁK

rm -rf "$BASE" 2>/dev/null

mkdir -p "$BASE"

cd "$BASE"
 
mkdir -p Logs Backup Temp Secrets Data Config

mkdir -p Discord/szerverek
 
# =========================

# CLUE-K

# =========================
 
echo "WARNING: Server unstable below 15°C" > Logs/system.log

echo "Backup rotation sequence: 6 -> 15 -> 8" > Secrets/backup.txt

echo "Power sequence: ON OFF ON" > Config/power.conf

echo "Hold button for 5 seconds to confirm override" > Data/button.txt
 
# +4 EXTRA CLUE

echo "Temperature critical threshold: 15" > Logs/temp_hint.txt

echo "Sequence hint: first low then high then medium" > Secrets/hint2.txt

echo "Binary pattern: 101" > Config/binary.txt

echo "Authentication requires patience..." > Data/hint_btn.txt
 
# SZERVEREK

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

# VIZUÁLIS FA

# =========================

cd "$BASE"
 
clear

echo "📂 RENDSZER ELÉRÉS MEGADVA"

echo "========================================="

echo ""
 
echo "escape_room/"

echo "├── Logs/"

echo "│   ├── system.log"

echo "│   └── temp_hint.txt"

echo "├── Secrets/"

echo "│   ├── backup.txt"

echo "│   └── hint2.txt"

echo "├── Data/"

echo "│   ├── button.txt"

echo "│   └── hint_btn.txt"

echo "├── Config/"

echo "│   ├── power.conf"

echo "│   └── binary.txt"

echo "└── Discord/"

echo "    └── szerverek/"

ls Discord/szerverek
 
echo ""

echo "========================================="

echo "💡 TIPP: Az ajtó bezáródott… találd meg a kijutás módját!"

echo "📄 Hasznos parancsok: cat, ls, cd, rmdir"

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

        echo "⚠️ FURCSA TEVÉKENYSÉG ÉSZLELVE"

        echo "========================================="

        echo ""

        echo "🔒 AZ AJTÓ LEZÁRÁSI RENDSZERE AKTIVÁLVA"

        echo ""

        echo "⏳ VISSZASZÁMLÁLÁS ELINDULT (05:00)"

        echo ""

        echo "🌐 Nyisd meg: http://localhost:1880/ui"

        echo ""
 
        seconds=300
 
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

        sleep 10

        pkill -P $$ 2>/dev/null

        exit

    fi

    sleep 1

done

) &
 
# SHELL

cd "$BASE"

export PS1="(DISCORD-SERVER) $ "

exec bash
 
