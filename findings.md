# Findings Report

**Audit Date:** April 2026  
**Network:** 192.168.1.0/24

---

## Severity Rating Scale

| Severity | Description |
|---|---|
| 🔴 Critical | Immediate risk of full network compromise |
| 🟠 High | Significant risk; exploitation likely with basic skill |
| 🟡 Medium | Moderate risk; requires specific conditions to exploit |
| 🟢 Low | Minor issue; limited impact |

---

## FIND-001 — Router Default Admin Credentials

| Field | Detail |
|---|---|
| **Severity** | 🔴 Critical |
| **Affected Device** | Router (192.168.1.1) |
| **Category** | Authentication |
| **Status** | ✅ Remediated |

**Description:**  
The router's admin web interface was accessible using the factory-default credentials (`admin` / `admin`). These credentials are publicly documented for the device model and would allow any local network attacker to take full administrative control of the router — including redirecting DNS, intercepting traffic, or disabling firewall rules.

**Evidence:**  
Successful login to `http://192.168.1.1/admin` using default credentials confirmed during audit.

**Risk:**  
Full network compromise. An attacker on the network could reconfigure DNS to redirect all traffic, expose internal devices to the internet, or create persistent backdoor access.

**Remediation:**  
Changed admin password to a strong, unique 20+ character passphrase. Disabled remote management interface.

---

## FIND-002 — Wi-Fi Network Using WPA2 (WPA3 Available)

| Field | Detail |
|---|---|
| **Severity** | 🟠 High |
| **Affected Device** | Router / Wi-Fi Network |
| **Category** | Wireless Security |
| **Status** | ✅ Remediated |

**Description:**  
The wireless network was configured with WPA2-Personal security. The router supports WPA3, which provides stronger encryption (SAE handshake) and is resistant to offline dictionary attacks that affect WPA2 (KRACK vulnerability).

**Evidence:**  
Wi-Fi scan confirmed network broadcasting with `RSN: WPA2` security type. Router admin panel confirmed WPA3 was available but not enabled.

**Risk:**  
WPA2 handshakes can be captured and subjected to offline brute-force or dictionary attacks, potentially revealing the Wi-Fi passphrase.

**Remediation:**  
Enabled WPA3-Personal (with WPA2/WPA3 transition mode for older devices) in the router wireless settings.

---

## FIND-003 — Open Telnet Port on IoT Smart Plug

| Field | Detail |
|---|---|
| **Severity** | 🟠 High |
| **Affected Device** | Smart Plug (192.168.1.8, 192.168.1.9) |
| **Category** | Open Ports / Authentication |
| **Status** | ✅ Remediated |

**Description:**  
Both Tuya-based smart plugs had TCP port 23 (Telnet) open and accepting connections with no authentication required. Connecting via `telnet 192.168.1.8` dropped directly into a root shell on the device.

**Evidence:**
```
nmap -p 23 192.168.1.8
PORT   STATE SERVICE
23/tcp open  telnet

$ telnet 192.168.1.8
Connected to 192.168.1.8.
# whoami
root
```

**Risk:**  
Unauthenticated root access to IoT devices. Could be used as a pivot point, for persistent access, or to manipulate connected electrical devices.

**Remediation:**  
Blocked Telnet port (23) at the firewall level for IoT devices. Devices moved to isolated IoT VLAN.

---

## FIND-004 — Unencrypted HTTP Traffic from Smart TV

| Field | Detail |
|---|---|
| **Severity** | 🟡 Medium |
| **Affected Device** | Smart TV (192.168.1.7) |
| **Category** | Traffic / Encryption |
| **Status** | ⚠️ Accepted (vendor limitation) |

**Description:**  
Traffic capture using Wireshark identified the smart TV sending telemetry data and firmware update checks over plain HTTP (port 80). This exposes device information (model, firmware version, usage patterns) to any device on the local network capable of passive sniffing.

**Evidence:**  
Wireshark capture filter `ip.src == 192.168.1.7 && http` showed multiple unencrypted POST requests to Samsung telemetry endpoints.

**Risk:**  
Passive eavesdropping on device telemetry. In a shared network, this could expose usage habits. No user credentials were observed in the captured traffic.

**Remediation:**  
Cannot be directly fixed (vendor firmware limitation). Mitigated by isolating the smart TV to a separate VLAN, limiting lateral network visibility.

---

## FIND-005 — No IoT Network Segmentation

| Field | Detail |
|---|---|
| **Severity** | 🟡 Medium |
| **Affected Device** | Entire Network |
| **Category** | Network Architecture |
| **Status** | ✅ Remediated |

**Description:**  
All devices including IoT gadgets (smart plugs, bulbs, TV) were on the same flat network as computers and the NAS. If any IoT device were compromised, an attacker would have direct network access to sensitive devices.

**Evidence:**  
Successful ping and port scan between IoT devices and the NAS/PCs confirmed unrestricted lateral movement capability.

**Risk:**  
Lateral movement after IoT compromise. An attacker controlling a smart plug could scan and attack the NAS or personal computers.

**Remediation:**  
Created a dedicated IoT VLAN (192.168.10.0/24) via router settings. Moved all IoT devices to this VLAN. Added firewall rules to block IoT-to-LAN traffic while allowing internet access.

---

## FIND-006 — Unnecessary Open Ports on NAS Device

| Field | Detail |
|---|---|
| **Severity** | 🟡 Medium |
| **Affected Device** | NAS (192.168.1.6) |
| **Category** | Open Ports |
| **Status** | ✅ Remediated |

**Description:**  
The Synology NAS had FTP (port 21) and Telnet (port 23) services running and accessible despite these services not being in active use. These legacy protocols transmit credentials in plaintext.

**Evidence:**
```
nmap -p 21,23,80,443,5000,5001 192.168.1.6
PORT     STATE SERVICE
21/tcp   open  ftp
23/tcp   open  telnet
5000/tcp open  http (Synology DSM)
5001/tcp open  https (Synology DSM)
```

**Risk:**  
Exposed plaintext credential services. If either service were accessed, credentials would be transmitted unencrypted.

**Remediation:**  
Disabled FTP and Telnet services in Synology DSM control panel. Confirmed ports closed post-remediation.
