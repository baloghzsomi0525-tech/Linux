#!/bin/bash

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
        
        # Itt indíthatod a következő feladatot
        bash
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
