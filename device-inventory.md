# Device Inventory

**Scan Date:** April 2026 
**Network Range:** 192.168.1.0/24  
**Discovery Tools:** `arp-scan`, `nmap -sn`

---

## Discovered Devices

| # | IP Address | MAC Address | Hostname | Device Type | OS / Firmware | Risk |
|---|---|---|---|---|---|---|
| 1 | 192.168.1.1 | AA:BB:CC:DD:EE:01 | router.local | Router / Gateway | TP-Link Firmware v3.2 | 🔴 Critical |
| 2 | 192.168.1.2 | AA:BB:CC:DD:EE:02 | desktop-pc | Desktop PC | Windows 11 (updated) | 🟢 Low |
| 3 | 192.168.1.3 | AA:BB:CC:DD:EE:03 | macbook-pro | Laptop | macOS Sonoma 14.x | 🟢 Low |
| 4 | 192.168.1.4 | AA:BB:CC:DD:EE:04 | android-phone | Smartphone | Android 14 | 🟢 Low |
| 5 | 192.168.1.5 | AA:BB:CC:DD:EE:05 | iphone | Smartphone | iOS 17.x | 🟢 Low |
| 6 | 192.168.1.6 | AA:BB:CC:DD:EE:06 | nas-device | NAS Storage | Synology DSM 7.x | 🟡 Medium |
| 7 | 192.168.1.7 | AA:BB:CC:DD:EE:07 | smart-tv | Smart TV | Samsung Tizen OS | 🟡 Medium |
| 8 | 192.168.1.8 | AA:BB:CC:DD:EE:08 | smart-plug-1 | IoT Smart Plug | Tuya Firmware | 🟠 High |
| 9 | 192.168.1.9 | AA:BB:CC:DD:EE:09 | smart-plug-2 | IoT Smart Plug | Tuya Firmware | 🟠 High |
| 10 | 192.168.1.10 | AA:BB:CC:DD:EE:10 | smart-bulb | IoT Smart Bulb | Generic Firmware | 🟡 Medium |
| 11 | 192.168.1.11 | AA:BB:CC:DD:EE:11 | raspberry-pi | Home Server | Raspberry Pi OS | 🟡 Medium |

---

## Device Risk Classifications

| Risk Level | Criteria |
|---|---|
| 🔴 Critical | Default credentials, critical services exposed, full network access |
| 🟠 High | Open unauthenticated ports, outdated firmware with known CVEs |
| 🟡 Medium | Minor misconfigurations, unnecessary open ports, unencrypted traffic |
| 🟢 Low | Up to date, properly configured, minimal attack surface |

---

## Network Topology Notes

- All 11 devices were on the same flat subnet (192.168.1.0/24) prior to hardening
- No VLAN segmentation was in place
- IoT devices (smart plugs, bulbs) had direct access to computers and NAS
- Router DHCP leases confirmed no unknown/rogue devices were present
