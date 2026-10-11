#!/bin/bash

# THM-TUNNEL - TryHackMe VPN Configuration Manager
# Version: 1.1.0

if [ -z "${BASH_VERSION:-}" ]; then
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
                         v1.1.0
EOF

echo

# Check required commands
for cmd in sudo find ip openvpn awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Required command not found: $cmd"
        exit 1
    fi
done

# Check sudo privileges
echo "[*] Checking sudo permissions..."

if ! sudo -v; then
    echo
    echo "[!] Sudo authentication failed."
    echo "[!] Root privileges are required to manage the VPN."
    exit 1
fi

echo "[+] Sudo access confirmed."

# Find OpenVPN configurations
echo
echo "[*] Searching for OpenVPN configurations..."
echo

mapfile -t CONFIGS < <(
    find "$HOME" -type f -name "*.ovpn" 2>/dev/null
)

if [ "${#CONFIGS[@]}" -eq 0 ]; then
    echo "[!] No OpenVPN configuration files found under $HOME."
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

# Track only the OpenVPN process started by this script.
VPN_PID=""

cleanup() {
    if [[ -n "$VPN_PID" ]] && kill -0 "$VPN_PID" 2>/dev/null; then
        echo
        echo "[*] Stopping THM-TUNNEL OpenVPN process..."
        sudo kill -TERM "$VPN_PID" 2>/dev/null || true
        wait "$VPN_PID" 2>/dev/null || true
    fi
}

trap cleanup INT TERM

echo
echo "[*] Starting OpenVPN..."
echo "[*] Press Ctrl+C to disconnect."
echo

sudo openvpn --disable-dco --config "$CONFIG" &
VPN_PID=$!

# Wait for OpenVPN to exit.
wait "$VPN_PID"
VPN_STATUS=$?
VPN_PID=""

echo

if (( VPN_STATUS == 0 )); then
    echo "[+] OpenVPN exited normally."
else
    echo "[!] OpenVPN exited with status $VPN_STATUS."
    echo "[!] Check the logs above for the cause."
fi

exit "$VPN_STATUS"
