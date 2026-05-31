# Remediation Steps

**Audit Date:** April 2026  
**Engineer:** [Vishvaa369]

All remediation actions below were applied during the audit session. Each finding references the corresponding entry in `findings.md`.

---

## REM-001 — Change Router Default Credentials

**Linked Finding:** FIND-001 (Critical)

**Steps Taken:**
1. Logged into router admin panel at `http://192.168.1.1`
2. Navigated to **Administration > System > Admin Account**
3. Changed username from `admin` to a custom username
4. Set a new strong password (20+ characters, alphanumeric + symbols)
5. Saved settings and confirmed new credentials work
6. Navigated to **Remote Management** settings → confirmed disabled

**Verification:**  
Attempted login with old default credentials — access denied. ✅

---

## REM-002 — Enable WPA3 Wireless Security

**Linked Finding:** FIND-002 (High)

**Steps Taken:**
1. Logged into router admin panel
2. Navigated to **Wireless > Security Settings**
3. Changed security mode from `WPA2-Personal` to `WPA3-Personal / WPA2-WPA3 Transition`
4. Updated Wi-Fi passphrase to a strong 20-character passphrase
5. Reconnected all devices using the new credentials

**Verification:**  
Wi-Fi scan confirmed network now advertises `WPA3` security. Older devices connected successfully via WPA2/WPA3 transition mode. ✅

---

## REM-003 — Block Telnet on IoT Devices via Firewall

**Linked Finding:** FIND-003 (High)

**Steps Taken:**
1. Applied firewall rules to drop all inbound/outbound Telnet (port 23) traffic from IoT VLAN
2. Moved smart plugs to isolated IoT VLAN (see REM-005)
3. Attempted Telnet connection post-remediation — connection timed out

**Firewall rule applied:**
```bash
# Block Telnet from IoT VLAN
iptables -I FORWARD -s 192.168.10.0/24 -p tcp --dport 23 -j DROP
iptables -I FORWARD -d 192.168.10.0/24 -p tcp --dport 23 -j DROP
```

**Verification:**  
`telnet 192.168.1.8` — Connection timed out. Port 23 confirmed closed via nmap. ✅

---

## REM-004 — Mitigate Unencrypted Smart TV Traffic

**Linked Finding:** FIND-004 (Medium)

**Steps Taken:**
1. Confirmed the unencrypted traffic is from vendor telemetry (no credentials in plaintext)
2. Risk formally accepted as vendor firmware cannot be modified
3. Smart TV moved to IoT VLAN (see REM-005) to limit network visibility
4. Firewall rules prevent TV from accessing NAS or personal computers

**Verification:**  
Smart TV has internet access but cannot reach 192.168.1.0/24 devices. ✅

---

## REM-005 — Create IoT VLAN for Network Segmentation

**Linked Finding:** FIND-005 (Medium)

**Steps Taken:**
1. Logged into router admin and enabled VLAN support
2. Created new VLAN: `IoT Network` — SSID: `HomeNet-IoT`, Subnet: `192.168.10.0/24`
3. Connected all IoT devices (smart plugs, bulbs, smart TV) to `HomeNet-IoT`
4. Applied inter-VLAN firewall rules:
   - IoT → Internet: **ALLOW**
   - IoT → Main LAN (192.168.1.0/24): **BLOCK**
   - Main LAN → IoT: **BLOCK** (except specific management IPs)
5. Verified IoT devices retain internet connectivity
6. Verified IoT devices cannot reach main LAN hosts

**Firewall rules applied:**
```bash
# Allow IoT internet access
iptables -I FORWARD -s 192.168.10.0/24 -o eth0 -j ACCEPT

# Block IoT to main LAN
iptables -I FORWARD -s 192.168.10.0/24 -d 192.168.1.0/24 -j DROP

# Block main LAN to IoT (bidirectional isolation)
iptables -I FORWARD -s 192.168.1.0/24 -d 192.168.10.0/24 -j DROP
```

**Verification:**  
`ping 192.168.1.2` from IoT VLAN — Request timed out. ✅

---

## REM-006 — Disable FTP and Telnet on NAS

**Linked Finding:** FIND-006 (Medium)

**Steps Taken:**
1. Logged into Synology DSM admin panel (`https://192.168.1.6:5001`)
2. Navigated to **Control Panel > File Services > FTP**
3. Unchecked "Enable FTP service" → Applied
4. Navigated to **Control Panel > Terminal & SNMP**
5. Unchecked "Enable Telnet service" → Applied
6. Restarted affected services

**Verification:**
```
nmap -p 21,23 192.168.1.6
PORT   STATE  SERVICE
21/tcp closed ftp
23/tcp closed telnet
```
Both ports confirmed closed. ✅

---

## Post-Remediation Scan Summary

Full nmap scan conducted after all remediations were applied:

```
nmap -sV 192.168.1.0/24

# Notable changes:
# 192.168.1.1 (Router)   - Port 23 closed, admin hardened
# 192.168.1.6 (NAS)      - Ports 21, 23 closed
# 192.168.1.8/.9 (Plugs) - Moved to IoT VLAN, port 23 blocked
```

**Overall result: All critical and high findings resolved. Network risk level reduced from HIGH to LOW.**
