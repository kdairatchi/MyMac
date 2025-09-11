#!/bin/bash
# ==========================================================
#  Nmap Automator – Interactive + Flags
#  Author: kdairatchi 💀
# ==========================================================

TARGET=$1
MODE=$2   # optional: vuln, all, stealth, menu
DATE=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="scans/$TARGET-$DATE"

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

banner() {
    echo -e "${RED}"
    echo "==============================================="
    echo "          🔎 Nmap Automator 🔎"
    echo "==============================================="
    echo -e "${RESET}"
}

usage() {
    banner
    echo -e "${YELLOW}Usage:${RESET} $0 <target> [mode]"
    echo
    echo "Modes:"
    echo "  vuln    = run vuln scripts on open ports"
    echo "  all     = run full 65k port scan"
    echo "  stealth = run stealth/evasion scans only"
    echo "  menu    = interactive mode"
    echo
    exit 1
}

mkdir -p "$OUTPUT_DIR"

# --------------------------
# Smart NSE runner
# --------------------------
run_service_scripts() {
    local PORTS=$1
    for PORT in $(echo "$PORTS" | tr ',' ' '); do
        case $PORT in
            21)   nmap --script ftp-anon,ftp-bounce,ftp-syst -p21 "$TARGET" -oN "$OUTPUT_DIR/ftp_enum.txt" ;;
            22)   nmap --script ssh-hostkey,ssh-auth-methods -p22 "$TARGET" -oN "$OUTPUT_DIR/ssh_enum.txt" ;;
            23)   nmap --script telnet-encryption -p23 "$TARGET" -oN "$OUTPUT_DIR/telnet_enum.txt" ;;
            25)   nmap --script smtp-commands,smtp-enum-users,smtp-open-relay -p25 "$TARGET" -oN "$OUTPUT_DIR/smtp_enum.txt" ;;
            53)   nmap --script dns-recursion,dns-service-discovery,dns-nsid -p53 "$TARGET" -oN "$OUTPUT_DIR/dns_enum.txt" ;;
            80|443|8080|8443)
                  nmap --script http-title,http-headers,http-methods,http-server-header,http-vuln* \
                  -p"$PORT" "$TARGET" -oN "$OUTPUT_DIR/web_$PORT.txt" ;;
            110|143|993|995)
                  nmap --script imap-capabilities,pop3-capabilities -p"$PORT" "$TARGET" -oN "$OUTPUT_DIR/mail_$PORT.txt" ;;
            139|445)
                  nmap --script smb-os-discovery,smb-enum-shares,smb-enum-users,smb-vuln* \
                  -p139,445 "$TARGET" -oN "$OUTPUT_DIR/smb_enum.txt" ;;
            1433) nmap --script ms-sql-info,ms-sql-ntlm-info -p1433 "$TARGET" -oN "$OUTPUT_DIR/mssql_enum.txt" ;;
            3306) nmap --script mysql-info,mysql-users,mysql-databases -p3306 "$TARGET" -oN "$OUTPUT_DIR/mysql_enum.txt" ;;
            3389) nmap --script rdp-enum-encryption,rdp-ntlm-info -p3389 "$TARGET" -oN "$OUTPUT_DIR/rdp_enum.txt" ;;
            389|636) nmap --script ldap-rootdse,ldap-search -p"$PORT" "$TARGET" -oN "$OUTPUT_DIR/ldap_enum.txt" ;;
            161)  nmap --script snmp-info,snmp-processes -p161 "$TARGET" -oN "$OUTPUT_DIR/snmp_enum.txt" ;;
            27017) nmap --script mongodb-info,mongodb-databases -p27017 "$TARGET" -oN "$OUTPUT_DIR/mongo_enum.txt" ;;
            6379) nmap --script redis-info -p6379 "$TARGET" -oN "$OUTPUT_DIR/redis_enum.txt" ;;
            5900) nmap --script vnc-info,vnc-title -p5900 "$TARGET" -oN "$OUTPUT_DIR/vnc_enum.txt" ;;
        esac
    done
}

# --------------------------
# Stealth/Evasion scans
# --------------------------
run_stealth() {
    echo -e "${GREEN}[+] Running stealth & evasion scans...${RESET}"
    nmap -sS "$TARGET" -oN "$OUTPUT_DIR/syn_scan.txt"
    nmap -sF "$TARGET" -oN "$OUTPUT_DIR/fin_scan.txt"
    nmap -sN "$TARGET" -oN "$OUTPUT_DIR/null_scan.txt"
    nmap -sX "$TARGET" -oN "$OUTPUT_DIR/xmas_scan.txt"
    nmap -f "$TARGET" -oN "$OUTPUT_DIR/fragmented_scan.txt"
    nmap -D RND:10 "$TARGET" -oN "$OUTPUT_DIR/decoy_scan.txt"
}

# --------------------------
# Main scan routine
# --------------------------
main_scan() {
    local FULLSCAN=$1
    echo -e "${BLUE}[i] Checking if host is alive...${RESET}"
    nmap -sn "$TARGET" -oN "$OUTPUT_DIR/host_discovery.txt" > /dev/null
    if ! grep -q "Host is up" "$OUTPUT_DIR/host_discovery.txt"; then
        echo -e "${RED}[-] Host seems down. Exiting.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}[+] Host is UP!${RESET}"

    if [ "$FULLSCAN" == "true" ]; then
        echo -e "${GREEN}[+] Running full port scan (0-65535)...${RESET}"
        nmap -p- -T4 "$TARGET" -oN "$OUTPUT_DIR/port_scan.txt"
    else
        echo -e "${GREEN}[+] Running quick scan (top 1000 ports)...${RESET}"
        nmap --top-ports 1000 -T4 "$TARGET" -oN "$OUTPUT_DIR/port_scan.txt"
    fi

    OPEN_PORTS=$(grep -E "^[0-9]+/tcp.*open" "$OUTPUT_DIR/port_scan.txt" | cut -d '/' -f1 | tr '\n' ',' | sed 's/,$//')
    if [ -z "$OPEN_PORTS" ]; then
        echo -e "${YELLOW}[!] No open ports detected.${RESET}"
        exit 0
    fi
    echo -e "${GREEN}[+] Open ports found: $OPEN_PORTS${RESET}"

    echo -e "${GREEN}[+] Running service & default NSE scripts...${RESET}"
    nmap -sV -sC -p"$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/service_scan.txt"

    echo -e "${GREEN}[+] Running OS detection & aggressive scan...${RESET}"
    nmap -A -p"$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/aggressive_scan.txt"

    run_service_scripts "$OPEN_PORTS"

    if [ "$MODE" == "vuln" ]; then
        echo -e "${GREEN}[+] Running vulnerability scripts (--script vuln)...${RESET}"
        nmap --script vuln -p"$OPEN_PORTS" "$TARGET" -oN "$OUTPUT_DIR/vuln_scan.txt"
    fi
}

# --------------------------
# Interactive menu
# --------------------------
menu_mode() {
    echo -e "${YELLOW}[?] Choose scan mode:${RESET}"
    echo "1) Quick Scan (top 1000)"
    echo "2) Full Scan (0-65535)"
    echo "3) Vulnerability Scan (top 1000 + vuln scripts)"
    echo "4) Stealth/Evasion Scans"
    echo -n "Enter choice: "
    read CHOICE

    case $CHOICE in
        1) main_scan false ;;
        2) main_scan true ;;
        3) MODE="vuln"; main_scan false ;;
        4) run_stealth ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
}

# --------------------------
# Execution
# --------------------------
banner
case $MODE in
    all) main_scan true ;;
    vuln) main_scan false ;;
    stealth) run_stealth ;;
    menu|"") menu_mode ;;
    *) usage ;;
esac

echo -e "${GREEN}[+] All scans completed! Results saved in: $OUTPUT_DIR${RESET}"
