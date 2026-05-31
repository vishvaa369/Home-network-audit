# Network Topology

## Pre-Audit (Flat Network)

```
                        [Internet / ISP]
                               |
                         [Router/Gateway]
                          192.168.1.1
                               |
              ─────────────────────────────────────
              |          |          |              |
         [Desktop]   [Laptop]  [NAS Device]  [Smart TV]
         .1.2         .1.3      .1.6           .1.7
                                               
              |          |          
         [Android]   [iPhone]   [Smart Plug x2]  [Smart Bulb]
         .1.4         .1.5       .1.8 / .1.9       .1.10
                                               
              |
         [Raspberry Pi]
         .1.11

All devices on same flat subnet: 192.168.1.0/24
⚠️  No VLAN segmentation — IoT has direct access to all devices
```

---

## Post-Audit (Segmented Network)

```
                        [Internet / ISP]
                               |
                         [Router/Gateway]
                          192.168.1.1
                   ┌──────────┴──────────┐
                   │                     │
          ┌────────┴────────┐   ┌────────┴─────────┐
          │  Main LAN VLAN  │   │   IoT VLAN        │
          │  192.168.1.0/24 │   │  192.168.10.0/24  │
          └────────┬────────┘   └────────┬──────────┘
                   │                     │
        ┌──────────┼──────────┐    ┌─────┼──────────┐
        │          │          │    │     │           │
   [Desktop]  [Laptop]    [NAS]  [TV]  [Plugs]  [Bulb]
   [Phones]   [RPi]              
   
   ✅ IoT → Main LAN: BLOCKED (firewall rules)
   ✅ Main LAN → IoT: BLOCKED (firewall rules)  
   ✅ IoT → Internet: ALLOWED
   ✅ Main LAN → Internet: ALLOWED
```

---

## VLAN Configuration Summary

| VLAN | Name | Subnet | SSID | Devices |
|---|---|---|---|---|
| 1 (default) | Main LAN | 192.168.1.0/24 | HomeNet | PCs, phones, NAS, Raspberry Pi |
| 10 | IoT | 192.168.10.0/24 | HomeNet-IoT | Smart TV, plugs, bulbs |

---

## Firewall Rule Summary (Inter-VLAN)

| Source | Destination | Action | Reason |
|---|---|---|---|
| 192.168.10.0/24 | 192.168.1.0/24 | ❌ DROP | Prevent IoT lateral movement |
| 192.168.1.0/24 | 192.168.10.0/24 | ❌ DROP | Bidirectional isolation |
| 192.168.10.0/24 | 0.0.0.0/0 (WAN) | ✅ ALLOW | IoT internet access |
| Any | port 23 (Telnet) | ❌ DROP | Block insecure legacy protocol |
| IoT | port 21 (FTP) | ❌ DROP | Block plaintext credential service |
