# THM-TUNNEL

### TryHackMe VPN Configuration Manager

If you use TryHackMe regularly, you may have faced this annoying issue: **OpenVPN shows as connected, but the target still doesn't ping or respond.** Sometimes an old OpenVPN process, stale `tun` interface, or leftover VPN state is the reason.

I built **THM-TUNNEL** to make switching between TryHackMe VPN configurations easier. It finds your `.ovpn` files, lets you select the one you want, cleans up the previous OpenVPN session and `tun*` interfaces, and starts a fresh connection.

## What it does

- Finds `.ovpn` files automatically
- Lets you select the VPN interactively
- Checks `sudo` access
- Stops old OpenVPN processes
- Cleans up old `tun*` interfaces
- Works with different TryHackMe VPN regions
- Doesn't hardcode any target IP or subnet

## Usage

```bash
git clone https://github.com/YOUR_USERNAME/THM-Tunnel.git
cd THM-Tunnel
chmod +x thm-tunnel.sh
./thm-tunnel.sh

# THM-TUNNEL

### TryHackMe VPN Configuration Manager

If you use TryHackMe regularly, you may have faced this annoying issue: **OpenVPN shows as connected, but the target still doesn't ping or respond.** Sometimes an old OpenVPN process, stale `tun` interface, or leftover VPN state is the reason.

I built **THM-TUNNEL** to make switching between TryHackMe VPN configurations easier. It finds your `.ovpn` files, lets you select the one you want, cleans up the previous OpenVPN session and `tun*` interfaces, and starts a fresh connection.

## What it does

- Finds `.ovpn` files automatically
- Lets you select the VPN interactively
- Checks `sudo` access
- Stops old OpenVPN processes
- Cleans up old `tun*` interfaces
- Works with different TryHackMe VPN regions
- Doesn't hardcode any target IP or subnet

## Usage

```bash
git clone https://github.com/YOUR_USERNAME/THM-Tunnel.git
cd THM-Tunnel
chmod +x thm-tunnel.sh
./thm-tunnel.sh
