#!/bin/bash

# Directory to store tools and outputs
TOOLS_DIR="$HOME/security-tools"
OUTPUT_DIR="$TOOLS_DIR/output"
mkdir -p $TOOLS_DIR
mkdir -p $OUTPUT_DIR

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

# Sanitize domain input to remove protocols
sanitize_domain() {
    domain=$(echo "$1" | sed -e 's/^https\?:\/\///' -e 's/\/$//')
    echo "$domain"
}

# Ensure all required tools are installed
check_tool_dependencies() {
    # Check for Sublist3r
    if [[ ! -d $TOOLS_DIR/Sublist3r ]]; then
        send_telegram_message "Sublist3r not found! Please run setup.sh first."
        echo "Sublist3r not found! Please run setup.sh first."
        exit 1
    fi
    # Check for Java (required for DirBuster)
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

# Run XSS testing using payloads
run_xss() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    payloads=$(cat $TOOLS_DIR/xss-payload-list/xss-payload-list.txt)
    for payload in $payloads; do
        url="$sanitized_domain?q=$payload"
        response=$(curl -s $url)
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
    python3 $TOOLS_DIR/sqlmap/sqlmap.py -u $sanitized_domain --batch --output-dir=$OUTPUT_DIR/sqlmap_$sanitized_domain >> "$OUTPUT_DIR/sqlmap_$sanitized_domain.log" 2>&1
    send_telegram_message "SQLMap scan completed for $sanitized_domain."
}

# Clickjacking Check
run_clickjacking() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    headers=$(curl -s -I $sanitized_domain | grep -i "x-frame-options")
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
    wapiti -u $sanitized_domain -o $OUTPUT_DIR/wapiti_$sanitized_domain.txt
    send_telegram_message "Wapiti scan completed for $sanitized_domain."
}

# Run RFI/LFI testing using payloads
run_rfi_lfi() {
    local domain=$1
    sanitized_domain=$(sanitize_domain "$domain")
    payloads=$(cat $TOOLS_DIR/rfi-lfi-payload-list/payload.txt)
    for payload in $payloads; do
        url="$sanitized_domain$file=$payload"
        response=$(curl -s $url)
        if [[ "$response" == *"root:x:0:0"* ]]; then
            send_telegram_message "RFI/LFI vulnerability found on $sanitized_domain with payload: $payload"
        fi
    done
}

# Function to run all tools automatically
run_all_tools() {
    echo "Enter the domain list file (one domain per line):"
    read domain_list_file

    if [[ ! -f "$domain_list_file" ]]; then
        echo "Domain list file not found!"
        exit 1
    fi

    while IFS= read -r domain; do
        echo -e "\e[1;34m[+] Running full scan on $domain...\e[0m"

        run_sublist3r $domain
        run_xss $domain
        run_sqlmap $domain
        run_clickjacking $domain
        run_wapiti $domain
        run_rfi_lfi $domain

        send_telegram_message "Full scan completed for $domain."
    done < $domain_list_file
}

# Run each tool one by one
run_tools_one_by_one() {
    echo "Enter the domain list file (one domain per line):"
    read domain_list_file

    if [[ ! -f "$domain_list_file" ]]; then
        echo "Domain list file not found!"
        exit 1
    fi

    while IFS= read -r domain; do
        echo -e "\e[1;34m[+] Running tools for $domain...\e[0m"
        echo -e "\e[1;33m1. Subdomain Enumeration (Sublist3r)"
        echo -e "2. XSS Testing"
        echo -e "3. SQL Injection (SQLMap)"
        echo -e "4. Clickjacking Check"
        echo -e "5. Wapiti Scan"
        echo -e "6. RFI/LFI Testing"
        echo -e "7. Run all tools sequentially\e[0m"
        echo "Choose a tool number to run or press 7 to run all tools:"
        read tool_choice

        case $tool_choice in
            1) run_sublist3r $domain ;;
            2) run_xss $domain ;;
            3) run_sqlmap $domain ;;
            4) run_clickjacking $domain ;;
            5) run_wapiti $domain ;;
            6) run_rfi_lfi $domain ;;
            7) run_all_tools_on_domain $domain ;;
            *) echo -e "\e[1;31mInvalid choice. Skipping $domain...\e[0m" ;;
        esac

        echo -e "\e[1;32m[+] Tools run for $domain.\e[0m"
    done < $domain_list_file
}

# Run all tools on a specific domain
run_all_tools_on_domain() {
    domain=$1
    run_sublist3r $domain
    run_xss $domain
    run_sqlmap $domain
    run_clickjacking $domain
    run_wapiti $domain
    run_rfi_lfi $domain
    send_telegram_message "All tools completed for $domain."
}

# Main menu loop
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

# Start the menu
main_menu
