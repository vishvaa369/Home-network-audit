#!/bin/bash
# =============================================================================
# Home Network Hardening - Firewall Rules
# Author: [Your Name]
# Date: June 2025
# Description: Custom iptables rules applied during home network security audit
#              to enforce IoT VLAN segmentation and block insecure services.
# =============================================================================
# WARNING: Review rules before applying. Run as root or with sudo.
# Test in a non-critical environment first.
# =============================================================================

set -e

echo "[*] Starting firewall hardening..."

# -----------------------------------------------------------------------------
# 1. Flush existing rules (start clean)
# -----------------------------------------------------------------------------
echo "[*] Flushing existing iptables rules..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# -----------------------------------------------------------------------------
# 2. Default policies — drop everything, then explicitly allow
# -----------------------------------------------------------------------------
echo "[*] Setting default DROP policies..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# -----------------------------------------------------------------------------
# 3. Allow loopback traffic
# -----------------------------------------------------------------------------
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# -----------------------------------------------------------------------------
# 4. Allow established and related connections
# -----------------------------------------------------------------------------
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# -----------------------------------------------------------------------------
# 5. Allow main LAN (192.168.1.0/24) full access
# -----------------------------------------------------------------------------
echo "[*] Allowing main LAN traffic..."
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.1.0/24 -d 192.168.1.0/24 -j ACCEPT

# -----------------------------------------------------------------------------
# 6. IoT VLAN (192.168.10.0/24) — Internet access ONLY
# -----------------------------------------------------------------------------
echo "[*] Configuring IoT VLAN rules..."

# Allow IoT devices to reach the internet via WAN (eth0)
iptables -A FORWARD -s 192.168.10.0/24 -o eth0 -j ACCEPT

# BLOCK IoT → Main LAN (prevent lateral movement)
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.1.0/24 -j DROP
echo "[+] Blocked IoT VLAN -> Main LAN"

# BLOCK Main LAN → IoT (bidirectional isolation)
iptables -A FORWARD -s 192.168.1.0/24 -d 192.168.10.0/24 -j DROP
echo "[+] Blocked Main LAN -> IoT VLAN"

# Allow IoT DNS queries (port 53) to router only
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.10.1 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.10.1 -p tcp --dport 53 -j ACCEPT

# -----------------------------------------------------------------------------
# 7. Block Telnet (port 23) — insecure legacy protocol
# -----------------------------------------------------------------------------
echo "[*] Blocking Telnet (port 23)..."

# Block inbound Telnet from any source
iptables -A INPUT -p tcp --dport 23 -j DROP

# Block Telnet forwarding to/from IoT VLAN
iptables -A FORWARD -p tcp --dport 23 -j DROP
iptables -A FORWARD -p tcp --sport 23 -j DROP
echo "[+] Telnet (port 23) blocked globally"

# -----------------------------------------------------------------------------
# 8. Block FTP (port 21) — plaintext credential protocol
# -----------------------------------------------------------------------------
echo "[*] Blocking FTP (port 21)..."
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport 21 -j DROP
iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport 20 -j DROP
echo "[+] FTP (ports 20, 21) blocked for IoT VLAN"

# -----------------------------------------------------------------------------
# 9. Block unsolicited inbound traffic from internet
# -----------------------------------------------------------------------------
echo "[*] Blocking unsolicited inbound traffic..."
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# -----------------------------------------------------------------------------
# 10. Allow ICMP (ping) — for diagnostics only from main LAN
# -----------------------------------------------------------------------------
iptables -A INPUT -s 192.168.1.0/24 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# -----------------------------------------------------------------------------
# 11. Allow SSH from main LAN only (if applicable)
# -----------------------------------------------------------------------------
# Uncomment to allow SSH from main LAN to this host
# iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT

# -----------------------------------------------------------------------------
# 12. Log and drop everything else
# -----------------------------------------------------------------------------
iptables -A INPUT -j LOG --log-prefix "IPT-DROP-IN: " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "IPT-DROP-FWD: " --log-level 4
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP

# -----------------------------------------------------------------------------
# 13. NAT masquerading for IoT internet access
# -----------------------------------------------------------------------------
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE

# -----------------------------------------------------------------------------
# 14. Save rules (persistent across reboot)
# -----------------------------------------------------------------------------
echo "[*] Saving rules..."
if command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4
    echo "[+] Rules saved to /etc/iptables/rules.v4"
else
    echo "[!] iptables-save not found — install iptables-persistent to make rules persistent"
fi

echo ""
echo "============================================"
echo " Firewall hardening complete."
echo " Summary:"
echo "   ✅ Default DROP policy set"
echo "   ✅ IoT VLAN isolated from main LAN"
echo "   ✅ Telnet (23) blocked globally"
echo "   ✅ FTP (20/21) blocked for IoT VLAN"
echo "   ✅ Inbound invalid packets dropped"
echo "   ✅ NAT masquerade enabled for IoT internet"
echo "============================================"
