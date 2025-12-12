#!/bin/bash
# Fixed and hardened version of your script
# - avoids stty/read errors when no TTY is present
# - fixes all broken if test syntax
# - uses safe fallbacks if helper scripts/functions are missing
# - small, clear menu for payload selection
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DATE="[2024-11-11]"

# Helper: safe source (only source if file exists)
safe_source() {
    [ -f "$1" ] && . "$1"
}

# Try to source the original helper scripts if available.
# If they're missing, we'll continue with fallbacks.
safe_source /usr/sbin/sh1mmer_gui.sh
safe_source /usr/sbin/sh1mmer_optionsSelector.sh

# If the helper provided setup(), call it; otherwise skip.
if declare -f setup >/dev/null 2>&1; then
    setup
fi

# Build the "goon" password obfuscatedly (keeps intent of original)
afdhkl=s
gsdfjdfjh=l
ffhdsas=d
jkfdfdh=i
seuiweaewiy=o
fygugjffgg=k
ffdgjfdgf=e
# original had nvgfgrtycea and others that were unused; kept minimal
goon="${afdhkl}${fygugjffgg}${jkfdfdh}${ffhdsas}${ffhdsas}${ffdgjfdgf}${ffhdsas}${gsdfjdfjh}${seuiweaewiy}${gsdfjdfjh}"

# Utility: returns 0 if stdin is a real TTY
is_tty() {
    [ -t 0 ]
}

# Safe key read: use readinput() from helper if available and if we have a TTY.
# Otherwise fallback to read -rsn1 (only when TTY). If no TTY, return empty.
safe_readkey() {
    if is_tty; then
        if declare -f readinput >/dev/null 2>&1; then
            # readinput may block internally; call it and echo the result
            read_val="$(readinput 2>/dev/null || true)"
            printf '%s' "$read_val"
            return 0
        else
            # fallback to a one-char read (silent)
            # -n1 read one char; -s silent; no timeout
            IFS= read -rsn1 ch 2>/dev/null || ch=""
            printf '%s' "$ch"
            return 0
        fi
    fi
    # Not a TTY: nothing to read
    return 1
}

# Show disclaimer (use helper showbg if available)
if declare -f showbg >/dev/null 2>&1 && is_tty; then
    showbg Disclaimer.png
else
    printf "\n--- DISCLAIMER ---\n"
fi

# Wait for a keypress only if we have a TTY
if is_tty; then
    safe_readkey >/dev/null 2>&1 || true
fi

# Create lock dir safely
mkdir -p -m 1777 /run/lock || true

# Mount SH1MMER label read-only if present; bind chromebrew if available
mkdir -p /mnt/sh1mmer /usr/local || true
if mount -o ro /dev/disk/by-label/SH1MMER /mnt/sh1mmer >/dev/null 2>&1; then
    mount --bind /mnt/sh1mmer/chromebrew /usr/local >/dev/null 2>&1 || true
fi

# Clear the screen if TTY
is_tty && clear

cat <<'EOF'
who are you?
(1) guest trying to use FMN
(2) A FCPHS chromebook tampering member
EOF

# Read user selection; if no TTY then default to guest (1)
userroot=""
if is_tty; then
    read -rp "Select (1 or 2): " userroot || userroot="1"
else
    userroot="1"
fi

# Helper: launch FMN payload
launch_fmn() {
    if is_tty; then
        echo "sending you to FMN payload, one moment..."
    fi
    sleep 1
    # If payload exists, run it (prefer full path). Use sudo only if necessary.
    if [ -x /payloads/FMN.sh ]; then
        sudo bash /payloads/FMN.sh
    else
        echo "FMN payload not found at /payloads/FMN.sh" >&2
    fi
    exit 0
}

# Validate and branch
case "$userroot" in
    1)
        launch_fmn
        ;;
    2)
        # Prompt for password (only meaningful if TTY)
        if is_tty; then
            echo "Please type in the password; if you went here by accident, type 'fmn' to go to FMN"
            read -rs -p "Password: " userrootpass || userrootpass=""
            echo
        else
            # No TTY — default to FMN to be safe
            launch_fmn
        fi

        # Compare password
        if [ "$userrootpass" = "$goon" ]; then
            # Authenticated; show the menu
            :
        elif [ "$userrootpass" = "fmn" ]; then
            clear
            launch_fmn
        else
            echo "Authentication failed — shutting down for safety in 5s"
            sleep 5
            reboot -f
            exit 1
        fi
        ;;
    *)
        # invalid input -> fallback to FMN
        echo "Invalid selection; going to FMN."
        launch_fmn
        ;;
esac

# -------- Menu area (authenticated) --------
# Provide a simple numeric menu rather than depending on complex key reads
loadmenu() {
    while :; do
        cat <<'MENU'
SH1MMER Menu
0) Payloads
1) Utilities
2) Credits
3) Reboot (and hold)
4) Exit to shell
MENU
        if is_tty; then
            read -rp "Choose an option [0-4]: " selected
        else
            selected="0"
        fi

        case "$selected" in
            0)
                if [ -x /usr/sbin/sh1mmer_payload.sh ]; then
                    bash /usr/sbin/sh1mmer_payload.sh
                else
                    echo "Payload script not found: /usr/sbin/sh1mmer_payload.sh"
                fi
                ;;
            1)
                if [ -x /usr/sbin/sh1mmer_utilities.sh ]; then
                    bash /usr/sbin/sh1mmer_utilities.sh
                else
                    echo "Utilities script not found: /usr/sbin/sh1mmer_utilities.sh"
                fi
                ;;
            2)
                credits
                ;;
            3)
                echo "Rebooting and holding... (tailing /dev/null)"
                reboot
                # tail -f /dev/null is not reached after reboot but kept if you want to debug
                tail -f /dev/null
                ;;
            4)
                echo "Dropping to interactive shell... (type exit to finish)"
                bash --login || true
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
}

credits() {
    if declare -f showbg >/dev/null 2>&1 && is_tty; then
        showbg Credits.png
        printf "\033[H"
    else
        clear
    fi
    echo "Script date: ${SCRIPT_DATE}"
    echo "Credits: (add your credits here)"
    echo "Press Enter to return to menu."
    if is_tty; then
        read -r _dummy
    fi
}

# Start the menu loop
loadmenu

# Cleanup (if helper cleanup exists)
if declare -f cleanup >/dev/null 2>&1; then
    cleanup
fi

# End of script
