<div align="center">
  <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/tryhackme.png" alt="TryHackMe" width="100"/>
  <h1>🛡️ THM-TUNNEL</h1>
  <p><strong>The Ultimate TryHackMe VPN Configuration Manager</strong></p>

  <p>
    <a href="https://github.com/Harsh-Sonker/THM-TUNNEL/issues"><img src="https://img.shields.io/github/issues/Harsh-Sonker/THM-TUNNEL" alt="Issues"></a>
    <a href="https://github.com/Harsh-Sonker/THM-TUNNEL/stargazers"><img src="https://img.shields.io/github/stars/Harsh-Sonker/THM-TUNNEL" alt="Stars"></a>
    <a href="https://github.com/Harsh-Sonker/THM-TUNNEL/network/members"><img src="https://img.shields.io/github/forks/Harsh-Sonker/THM-TUNNEL" alt="Forks"></a>
  </p>
</div>

---

## 💡 The Problem

If you use [TryHackMe](https://tryhackme.com) regularly, you may have faced this annoying issue:
> **OpenVPN shows as connected, but the target still doesn't ping or respond.**

Sometimes an old OpenVPN process, a stale `tun` interface, or leftover VPN state is the culprit. Manually killing processes and resetting interfaces every time you switch networks is tedious and breaks your flow.

## 🚀 The Solution

I built **THM-TUNNEL** to make switching between TryHackMe VPN configurations completely frictionless. It automatically finds your `.ovpn` files, lets you select the one you want, forcefully cleans up previous OpenVPN sessions and `tun*` interfaces, and starts a fresh, clean connection.

## ✨ Features

- 🔍 **Auto-Discovery**: Finds `.ovpn` files automatically—no more hunting for your configs.
- 🖱️ **Interactive Selection**: Lets you select the desired VPN interactively from a list.
- 🛡️ **Privilege Check**: Automatically verifies `sudo` access before execution.
- 🧹 **Process Cleanup**: Identifies and stops old, lingering OpenVPN processes.
- 🌐 **Interface Reset**: Cleans up old `tun*` network interfaces to prevent conflicts.
- 🌍 **Region Independent**: Works flawlessly with different TryHackMe VPN regions.
- 🎯 **Dynamic**: Doesn't hardcode any target IP or subnet—purely dynamic routing.

## 🛠️ Installation & Usage

Getting started is easy. Just clone the repository and run the script:

```bash
# 1. Clone the repository
git clone https://github.com/Harsh-Sonker/THM-TUNNEL.git

# 2. Navigate into the directory
cd THM-TUNNEL

# 3. Make the script executable
chmod +x thm-tunnel.sh

# 4. Run the manager
sudo ./thm-tunnel.sh
```

> **Note:** Since the script manages network interfaces and processes, it requires root privileges (`sudo`).

---

<div align="center">
  Made by <a href="https://github.com/Harsh-Sonker">Harsh Sonker</a>
</div>
