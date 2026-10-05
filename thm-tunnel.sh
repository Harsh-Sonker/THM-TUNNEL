#!/bin/bash

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
                         v1.0.0
EOF

echo

# Check sudo privileges
echo "[*] Checking sudo permissions..."

if ! sudo -v; then
    echo
    echo "[!] Sudo authentication failed."
    echo "[!] Root privileges are required to manage the VPN."
    exit 1
fi

echo "[+] Sudo access confirmed."

echo
echo "[*] Searching for OpenVPN configurations..."
echo

mapfile -t CONFIGS < <(
    find "$HOME" -type f -name "*.ovpn" 2>/dev/null
)

if [ ${#CONFIGS[@]} -eq 0 ]; then
    echo "[!] No OpenVPN configuration files found."
    exit 1
fi

echo "Available VPN configurations:"
echo

for i in "${!CONFIGS[@]}"; do
    printf "  [%d] %s\n" "$((i + 1))" "${CONFIGS[$i]}"
done

echo
read -rp "[?] Select VPN [1-${#CONFIGS[@]}]: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || \
   [ "$CHOICE" -lt 1 ] || \
   [ "$CHOICE" -gt "${#CONFIGS[@]}" ]; then
    echo
    echo "[!] Invalid selection."
    exit 1
fi

CONFIG="${CONFIGS[$((CHOICE - 1))]}"

echo
echo "[+] Selected VPN:"
echo "    $CONFIG"

echo
echo "[*] Stopping existing OpenVPN processes..."
sudo pkill -x openvpn 2>/dev/null

sleep 2

echo "[*] Cleaning old VPN interfaces..."

while read -r tun; do
    [ -z "$tun" ] && continue

    echo "[+] Removing $tun"
    sudo ip link delete "$tun" 2>/dev/null

done < <(
    ip -o link show |
    awk -F': ' '$2 ~ /^tun[0-9]+/ {print $2}'
)

echo
echo "[+] Cleanup complete."
echo "[*] Starting OpenVPN..."
echo

sudo openvpn --disable-dco --config "$CONFIG"
