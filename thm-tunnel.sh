#!/bin/bash

# THM-TUNNEL - TryHackMe VPN Configuration Manager
# Version: 1.2.0

set -o pipefail

if [[ -z "${BASH_VERSION:-}" ]]; then
    echo "[!] Run this script with Bash: bash $0"
    exit 1
fi

clear

cat << 'EOF'
  _______ _   _ __  __ _______                  _
 |__   __| | | |  \/  |__   __|                | |
    | |  | |_| | \  / |  | |_   _ _ __  _ __   | |
    | |  |  _  | |\/| |  | | | | | '_ \| '_ \  | |
    | |  | | | | |  | |  | | |_| | | | | | | | |_|
    |_|  |_| |_|_|  |_|  |_|\__,_|_| |_|_| |_| (_)

                 T H M - T U N N E L
          TryHackMe VPN Configuration Manager
                         v1.2.0
EOF

echo

# Check required commands
for cmd in sudo find ip openvpn pgrep pkill awk sort; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Required command not found: $cmd"
        exit 1
    fi
done

# Check sudo permissions
echo "[*] Checking sudo permissions..."

if ! sudo -v; then
    echo
    echo "[!] Sudo authentication failed."
    exit 1
fi

echo "[+] Sudo access confirmed."

# Find OpenVPN configurations
echo
echo "[*] Searching for OpenVPN configurations..."
echo

mapfile -d '' -t CONFIGS < <(
    find "$HOME" -type f -name "*.ovpn" -print0 2>/dev/null |
    sort -z
)

if (( ${#CONFIGS[@]} == 0 )); then
    echo "[!] No .ovpn files found under $HOME."
    exit 1
fi

echo "Available VPN configurations:"
echo

for i in "${!CONFIGS[@]}"; do
    printf "  [%d] %s\n" "$((i + 1))" "${CONFIGS[$i]}"
done

echo
read -rp "[?] Select VPN [1-${#CONFIGS[@]}]: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] ||
   (( CHOICE < 1 || CHOICE > ${#CONFIGS[@]} )); then
    echo
    echo "[!] Invalid selection."
    exit 1
fi

CONFIG="${CONFIGS[$((CHOICE - 1))]}"

echo
echo "[+] Selected VPN:"
echo "    $CONFIG"

# Stop existing OpenVPN sessions to avoid conflicting routes.
echo
echo "[*] Checking for existing OpenVPN sessions..."

if pgrep -x openvpn >/dev/null 2>&1; then
    echo "[!] Existing OpenVPN sessions detected."
    echo "[*] Sending termination signal..."

    sudo pkill -TERM -x openvpn || true

    for ((i = 0; i < 10; i++)); do
        if ! pgrep -x openvpn >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    if pgrep -x openvpn >/dev/null 2>&1; then
        echo "[!] OpenVPN did not stop gracefully."
        echo "[*] Sending force-termination signal..."

        sudo pkill -KILL -x openvpn || true
        sleep 1
    fi

    if pgrep -x openvpn >/dev/null 2>&1; then
        echo "[!] OpenVPN processes still exist."
        echo "[!] Check their state using: ps -eo pid,stat,args"
        exit 1
    fi

    echo "[+] Existing OpenVPN sessions stopped."
else
    echo "[+] No existing OpenVPN sessions found."
fi

# Check for tunnel interfaces left behind after OpenVPN exits.
mapfile -t TUN_INTERFACES < <(
    ip -o link show |
    awk -F': ' '{
        name = $2
        sub(/@.*/, "", name)
        if (name ~ /^tun[0-9]+$/) print name
    }'
)

if (( ${#TUN_INTERFACES[@]} > 0 )); then
    echo
    echo "[!] Tunnel interfaces remain:"
    printf '    %s\n' "${TUN_INTERFACES[@]}"
    echo
    echo "[!] Removing these may disconnect another VPN."
    read -rp "[?] Remove these interfaces? [y/N]: " REMOVE_TUN

    if [[ "$REMOVE_TUN" =~ ^[Yy]$ ]]; then
        for tun in "${TUN_INTERFACES[@]}"; do
            echo "[*] Removing $tun..."

            if ! sudo ip link delete "$tun"; then
                echo "[!] Could not remove $tun."
                echo "[!] Check its ownership and state manually."
                exit 1
            fi
        done

        echo "[+] Leftover tunnel interfaces removed."
    else
        echo "[!] Cleanup skipped."
        echo "[!] Existing interfaces may still cause routing conflicts."
        echo "[!] Aborting to avoid starting another conflicting VPN."
        exit 1
    fi
fi

# Start exactly one selected VPN in the foreground.
echo
echo "[*] Starting selected OpenVPN configuration..."
echo "[*] Press Ctrl+C to disconnect."
echo

sudo openvpn --disable-dco --config "$CONFIG"
VPN_STATUS=$?

echo

if (( VPN_STATUS == 0 )); then
    echo "[+] OpenVPN exited normally."
else
    echo "[!] OpenVPN exited with status $VPN_STATUS."
    echo "[!] Check the logs above for errors."
fi

exit "$VPN_STATUS"
