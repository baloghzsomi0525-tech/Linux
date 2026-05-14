#!/bin/bash

show_menu() {
    clear
    echo "========================================="
    echo "          TERMINAL PRANK MENU"
    echo "========================================="
    echo
    echo "1 - Prank 1"
    echo "2 - Prank 2"
    echo "3 - Prank 3"
    echo "4 - Prank 4"
    echo "5 - Prank 5"
    echo
    echo "Q - Kilépés az aktuális prankból"
    echo
    read -n1 -p "Válassz: " choice
    echo
}

prank1() {
    for i in $(seq 1 100); do

        read -rsn1 -t 0.01 key
        [[ "$key" == "q" ]] && return

        clear
        echo
        echo "   Windows frissítések telepítése..."
        echo
        echo "              $i% kész"
        echo
        echo " Ne kapcsold ki a számítógépet"

        sleep 0.05
    done

    clear
    echo
    echo "A frissítés sikertelen."
    echo "Rendszer-visszaállítás szükséges."
    sleep 3
}

prank2() {

    printf "\e[44m\e[97m"
    clear

    cat << "EOF"

A problem has been detected and Linux has been shut down to prevent damage

to your computer.

KERNEL_PANIC_FAKE_DEMO

Collecting diagnostic information...

*** STOP: 0x0000FAKE (0xDEADBEEF,0xBADF00D)

Beginning dump of physical memory...

EOF

    for i in $(seq 1 80); do
        read -rsn1 -t 0.1 key
        [[ "$key" == "q" ]] && break
    done

    printf "\e[0m"
    clear
    echo "Rendszer helyreállítva."
    sleep 2
}

prank3() {
python3 - << 'PY'
import os
import random
import time
import threading
import sys

chars = '01#$%&@ABCDEFGHIJKLMNOPQRSTUVWXYZ'
running = True

def key_listener():
    global running
    while True:
        key = sys.stdin.read(1)
        if key.lower() == 'q':
            running = False
            break

threading.Thread(target=key_listener, daemon=True).start()

os.system('stty cbreak -echo')
os.system('clear')

try:
    while running:
        line = ''.join(random.choice(chars) for _ in range(120))
        print('\033[92m' + line + '\033[0m')
        time.sleep(0.03)
finally:
    os.system('stty sane')
    os.system('clear')
    print("Matrix demo leállítva.")
    time.sleep(1)
PY
}

prank4() {
python3 - << 'PY'
import os
import random
import time
import sys
import select

iban = 'HU' + ''.join(str(random.randint(0,9)) for _ in range(26))

os.system('clear')

msg = f"""
#########################################################
#                                                       #
#          YOUR FILES HAVE BEEN ENCRYPTED              #
#                                                       #
#########################################################

Minden adat titkosítva lett.

A visszaállításhoz küldj 2 BTC-t a következő számlára:

{iban}

Nyomj Q-t a kilépéshez.
"""

print('\033[91m' + msg + '\033[0m')

os.system('stty cbreak -echo')

try:
    for i in range(60, -1, -1):

        if select.select([sys.stdin], [], [], 0)[0]:
            key = sys.stdin.read(1)
            if key.lower() == 'q':
                break

        mins = i // 60
        secs = i % 60

        print(f'\rHátralévő idő: {mins:02d}:{secs:02d}', end='')
        time.sleep(1)

finally:
    os.system('stty sane')

print('\n\nDEMO vége. Semmi nem történt a géppel.')
time.sleep(2)
PY
}

prank5() {

    for t in 72 74 76 79 82 85 88 91 95 99 103; do

        read -rsn1 -t 0.1 key
        [[ "$key" == "q" ]] && return

        clear
        echo "CPU Hőmérséklet: ${t}°C"
        echo
        echo "Ventilátor fordulatszám: KRITIKUS"
        echo

        sleep 0.5
    done

    clear
    echo "VESZÉLY: Kritikus túlmelegedés!"
    echo "A rendszer védelmi okból leáll."
    sleep 4

    clear
    echo "Demo vége."
    sleep 2
}

while true; do

    show_menu

    case $choice in
        1)
            prank1
            ;;
        2)
            prank2
            ;;
        3)
            prank3
            ;;
        4)
            prank4
            ;;
        5)
            prank5
            ;;
        q|Q)
            clear
            exit 0
            ;;
        *)
            echo
            echo "Érvénytelen választás."
            sleep 1
            ;;
    esac
done
