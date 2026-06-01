# 🔐 Home Network Security Audit

A comprehensive end-to-end security audit of a home network environment — covering device discovery, traffic analysis, vulnerability identification, and hardening implementation.

---

## 📋 Overview

This project documents a full security audit conducted on a home network. The goal was to assess the network's attack surface, identify misconfigurations and weak points, apply targeted hardening measures, and produce a structured report of all findings and remediation steps.

---

## 🎯 Objectives

- Map all devices connected to the home network
- Analyse live traffic patterns for anomalies or unencrypted communication
- Identify open ports and services exposed unnecessarily
- Detect weak or default authentication configurations
- Apply practical hardening measures to reduce the attack surface
- Document all findings in a structured audit report

---

## 🛠️ Tools & Technologies

| Category | Tools Used |
|---|---|
| Network Scanning | `nmap`, `arp-scan` |
| Traffic Analysis | `Wireshark`, `tcpdump` |
| Port Analysis | `nmap`, `netstat` |
| Firewall Management | `iptables` / `ufw` |
| Wireless Security | WPA3 enforcement via router admin |
| Reporting | Markdown / structured audit template |

---

## 🔍 Audit Phases

### 1. Device Discovery & Network Mapping
- Performed ARP scans and active host discovery across the local subnet
- Identified all connected devices (computers, phones, IoT, smart TV, routers, etc.)
- Documented MAC addresses, IP assignments, and device roles

### 2. Traffic Analysis
- Captured live traffic using Wireshark/tcpdump
- Analysed protocols in use — flagged unencrypted HTTP, Telnet, and plain FTP traffic
- Identified unexpected outbound connections and unusual communication patterns

### 3. Open Port & Service Enumeration
- Ran full TCP/UDP port scans across all discovered hosts
- Identified unnecessarily exposed services (remote desktop, file sharing, legacy protocols)
- Assessed each open port for risk level and necessity

### 4. Authentication Review
- Reviewed router and device login credentials
- Identified default credentials and weak passwords
- Assessed Wi-Fi security protocols in use (WEP/WPA/WPA2/WPA3)

### 5. Hardening & Remediation
- Applied custom firewall rules to block unauthorized inbound/outbound traffic
- Enforced WPA3 on the wireless network
- Disabled unnecessary services and closed unused ports
- Updated default credentials across applicable devices
- Segmented IoT devices onto a separate guest VLAN

---

## 📄 Audit Report

A structured report was produced documenting:

- **Executive Summary** — overall security posture before and after audit
- **Device Inventory** — full list of discovered devices with risk classification
- **Findings** — detailed vulnerability descriptions with severity ratings (Critical / High / Medium / Low)
- **Remediation Steps** — specific actions taken or recommended for each finding
- **Post-Hardening Assessment** — verification of applied fixes

---

## 🔒 Key Findings (Summary)

| Finding | Severity | Status |
|---|---|---|
| Router using default admin credentials | 🔴 Critical | ✅ Remediated |
| Wi-Fi network on WPA2 (WPA3 available) | 🟠 High | ✅ Remediated |
| Open Telnet port on IoT device | 🟠 High | ✅ Remediated |
| Unencrypted HTTP traffic from smart TV | 🟡 Medium | ✅ Flagged |
| IoT devices on main network (no segmentation) | 🟡 Medium | ✅ Remediated |
| Unused open ports on home server | 🟡 Medium | ✅ Remediated |

---

## 📁 Repository Structure

```
home-network-audit/
├── README.md                          # Project overview
├── audit-report/
│   ├── executive-summary.md           # High-level findings & posture
│   ├── device-inventory.md            # All discovered devices
│   ├── findings.md                    # Detailed vulnerability report
│   └── remediation-steps.md          # Actions taken / recommended
├── configs/
│   ├── firewall-rules.sh              # Custom iptables/ufw rules
│   └── network-diagram.md            # Network topology description
└── scripts/
    ├── scan-network.sh                # Automated host discovery
    └── port-scan.sh                   # Port enumeration helper
```

---

## ⚠️ Disclaimer

This audit was conducted solely on a private home network with full authorization. All techniques and tools used are intended for **legal, authorized security assessments only**. Performing network scans or traffic analysis on networks you do not own or have explicit permission to test is illegal.

---

## 👤 Author

Vishvaa


