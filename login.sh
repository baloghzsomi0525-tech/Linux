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

while true
do
    read -p "Felhasználónév: " user
    read -s -p "Jelszó: " pass
    echo ""

    if [[ "$user" == "Balint" && "$pass" == "Bolyai" ]]; then
        echo ""
        echo "✅ Hozzáférés megadva"
        sleep 2
        clear
        echo "Belépve a rendszerbe..."
        sleep 2

        # =========================
        # MAPPÁK LÉTREHOZÁSA
        # =========================
        mkdir -p "$BASE"
        cd "$BASE"

        mkdir -p Logs Backup Temp Secrets Data

        mkdir -p Discord/szerverek

        cd Discord/szerverek

        # =========================
        # 20 SZERVER GENERÁLÁSA
        # =========================
        servers=(
        alpha beta gamma delta epsilon zeta theta omega nexus titan
        matrix cyber void shadow neon quantum vortex pixel arcadia
        szarfos
        )

        for s in "${servers[@]}"
        do
            mkdir -p "$s"
        done

        clear
        echo "📂 Hozzáférés megadva a rendszerhez"
        echo "📁 Navigálj és keresd meg a hibás szervert..."
        echo ""
        echo "TIPP: cd, ls, rm"
        echo ""

        # =========================
        # FIGYELÉS A TÖRLÉSRE
        # =========================
        TARGET="$BASE/Discord/szerverek/szarfos"

        while true
        do
            if [ ! -d "$TARGET" ]; then
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
