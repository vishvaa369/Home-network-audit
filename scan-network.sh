#!/bin/bash
# =============================================================================
# scan-network.sh — Automated Host Discovery
# Author: [Your Name]
# Date: June 2025
# Description: Discovers all active hosts on the local subnet using ARP scan
#              and nmap ping sweep. Outputs a device list with IP, MAC, and
#              vendor information.
# =============================================================================
# Usage: sudo bash scan-network.sh [subnet]
# Example: sudo bash scan-network.sh 192.168.1.0/24
# =============================================================================

set -e

# --- Config ---
SUBNET="${1:-192.168.1.0/24}"
OUTPUT_DIR="./scan-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$OUTPUT_DIR/host-discovery_$TIMESTAMP.txt"

# --- Colours ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Checks ---
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[!] This script must be run as root (sudo)${NC}"
    exit 1
fi

for tool in nmap arp-scan; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${YELLOW}[!] $tool is not installed. Install it with: apt install $tool${NC}"
        exit 1
    fi
done

mkdir -p "$OUTPUT_DIR"

echo ""
echo "=============================================="
echo "  Home Network - Host Discovery Scan"
echo "  Target: $SUBNET"
echo "  Time:   $(date)"
echo "=============================================="
echo ""

# --- ARP Scan ---
echo -e "${GREEN}[*] Running ARP scan on $SUBNET...${NC}"
echo "=== ARP SCAN RESULTS ===" >> "$OUTPUT_FILE"
echo "Target: $SUBNET | Date: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

arp-scan --localnet 2>/dev/null | tee -a "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"

# --- Nmap Ping Sweep ---
echo ""
echo -e "${GREEN}[*] Running nmap ping sweep on $SUBNET...${NC}"
echo "=== NMAP PING SWEEP ===" >> "$OUTPUT_FILE"

nmap -sn "$SUBNET" -oG - 2>/dev/null | grep "Up" | awk '{print $2}' | while read -r ip; do
    echo "  Host Up: $ip"
    echo "  $ip" >> "$OUTPUT_FILE"
done

# --- Nmap OS Detection on discovered hosts ---
echo ""
echo -e "${GREEN}[*] Running OS/version detection on live hosts (this may take a minute)...${NC}"
echo "" >> "$OUTPUT_FILE"
echo "=== NMAP OS/SERVICE DETECTION ===" >> "$OUTPUT_FILE"

nmap -sV -O --osscan-guess "$SUBNET" -T4 2>/dev/null | tee -a "$OUTPUT_FILE"

# --- Summary ---
HOST_COUNT=$(arp-scan --localnet 2>/dev/null | grep -c "^\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" || true)

echo ""
echo "=============================================="
echo -e "  ${GREEN}Scan complete.${NC}"
echo "  Hosts found:   $HOST_COUNT"
echo "  Results saved: $OUTPUT_FILE"
echo "=============================================="
echo ""
