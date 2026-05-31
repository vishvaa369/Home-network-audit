#!/bin/bash
# =============================================================================
# port-scan.sh — Port Enumeration Helper
# Author: [Your Name]
# Date: June 2025
# Description: Performs a targeted port scan on a single host or full subnet,
#              identifies open ports and running services, and flags common
#              insecure services (Telnet, FTP, HTTP, etc.)
# =============================================================================
# Usage:
#   sudo bash port-scan.sh <target>
#   sudo bash port-scan.sh 192.168.1.1          # single host
#   sudo bash port-scan.sh 192.168.1.0/24       # full subnet
# =============================================================================

set -e

# --- Config ---
TARGET="${1}"
OUTPUT_DIR="./scan-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$OUTPUT_DIR/port-scan_${TIMESTAMP}.txt"

# Ports commonly associated with insecure/legacy services
INSECURE_PORTS=(21 23 25 110 143 512 513 514 1900 5900)

# --- Colours ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Checks ---
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[!] No target specified.${NC}"
    echo "Usage: sudo bash port-scan.sh <ip or subnet>"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[!] This script must be run as root (sudo)${NC}"
    exit 1
fi

if ! command -v nmap &> /dev/null; then
    echo -e "${YELLOW}[!] nmap is not installed. Install: apt install nmap${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo ""
echo "=============================================="
echo "  Home Network - Port Scan"
echo "  Target: $TARGET"
echo "  Time:   $(date)"
echo "=============================================="
echo ""

# --- Full TCP Port Scan ---
echo -e "${GREEN}[*] Running full TCP port scan on $TARGET...${NC}"
echo "=== PORT SCAN: $TARGET ===" >> "$OUTPUT_FILE"
echo "Date: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

nmap -sV -p- --open -T4 "$TARGET" 2>/dev/null | tee -a "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"

# --- UDP Scan (common ports) ---
echo ""
echo -e "${GREEN}[*] Running UDP scan on common ports...${NC}"
echo "=== UDP SCAN ===" >> "$OUTPUT_FILE"

nmap -sU -p 53,67,68,69,123,161,500,1900,5353 "$TARGET" -T4 2>/dev/null | tee -a "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"

# --- Flag Insecure Open Ports ---
echo ""
echo -e "${CYAN}[*] Checking for insecure/legacy open ports...${NC}"
echo "=== INSECURE PORT CHECK ===" >> "$OUTPUT_FILE"

FLAGGED=0
for port in "${INSECURE_PORTS[@]}"; do
    RESULT=$(nmap -p "$port" --open "$TARGET" 2>/dev/null | grep "open" | head -1)
    if [[ -n "$RESULT" ]]; then
        echo -e "${RED}  [⚠] Port $port OPEN — $(get_service_name $port)${NC}"
        echo "  [FLAGGED] Port $port open" >> "$OUTPUT_FILE"
        FLAGGED=$((FLAGGED + 1))
    fi
done

get_service_name() {
    case $1 in
        21) echo "FTP (plaintext file transfer)" ;;
        23) echo "Telnet (plaintext shell access)" ;;
        25) echo "SMTP (mail relay — may be misconfigured)" ;;
        110) echo "POP3 (plaintext email retrieval)" ;;
        143) echo "IMAP (plaintext email access)" ;;
        512) echo "rexec (remote execution — insecure)" ;;
        513) echo "rlogin (remote login — insecure)" ;;
        514) echo "rsh / syslog (insecure remote shell)" ;;
        1900) echo "UPnP (network auto-discovery — often abused)" ;;
        5900) echo "VNC (remote desktop — ensure password is set)" ;;
        *) echo "Unknown flagged port" ;;
    esac
}

if [[ $FLAGGED -eq 0 ]]; then
    echo -e "${GREEN}  No insecure legacy ports detected on open ports.${NC}"
    echo "  No insecure ports detected." >> "$OUTPUT_FILE"
fi

# --- Summary ---
echo ""
echo "=============================================="
echo -e "  ${GREEN}Port scan complete.${NC}"
echo "  Target:          $TARGET"
echo "  Flagged ports:   $FLAGGED"
echo "  Results saved:   $OUTPUT_FILE"
echo "=============================================="
echo ""
