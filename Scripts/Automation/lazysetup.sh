#!/bin/bash

# Banner for setup
print_setup_banner() {
    echo -e "\e[1;32m#############################################################"
    echo -e "#      Ultimate Security Tools Setup - Automated Installer      #"
    echo -e "#############################################################\e[0m"
}

# Directories to store tools and outputs
TOOLS_DIR="$HOME/security-tools"
OUTPUT_DIR="$TOOLS_DIR/output"
PAYLOADS_DIR="$TOOLS_DIR/payloads"
SECLISTS_DIR="$TOOLS_DIR/seclists"
mkdir -p $TOOLS_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $PAYLOADS_DIR
mkdir -p $SECLISTS_DIR

# Update system and install basic dependencies
install_basic_dependencies() {
    echo "[+] Updating system packages and installing basic dependencies..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y git python3 python3-pip ruby curl nmap proxychains java
    echo "[+] Basic dependencies installed."
}

# Clone necessary GitHub repositories
clone_tools() {
    echo "[+] Cloning all necessary tools from GitHub..."

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

    echo "[+] All tools have been cloned successfully."
}

# Install Python dependencies
install_python_dependencies() {
    echo "[+] Installing Python dependencies for the tools..."

    pip3 install -r $TOOLS_DIR/Sublist3r/requirements.txt
    pip3 install wapiti3

    echo "[+] Python dependencies installed successfully."
}

# Install Ruby dependencies (for WPScan)
install_ruby_dependencies() {
    echo "[+] Installing WPScan dependencies..."
    sudo gem install wpscan
    echo "[+] WPScan dependencies installed successfully."
}

# Install dependencies for BigBountyRecon
install_bigbountyrecon_dependencies() {
    echo "[+] Installing BigBountyRecon dependencies..."
    cd $TOOLS_DIR/BigBountyRecon
    sudo bash install.sh
    cd -
    echo "[+] BigBountyRecon dependencies installed successfully."
}

# Final messages for setup completion
setup_complete_message() {
    echo -e "\e[1;32m#############################################################"
    echo -e "#        Setup Completed Successfully! Ready to Scan!           #"
    echo -e "#############################################################\e[0m"
    echo -e "You can now run the secbounty.sh script to start scanning."
}

# Full Setup Function
full_setup() {
    print_setup_banner
    install_basic_dependencies
    clone_tools
    install_python_dependencies
    install_ruby_dependencies
    install_bigbountyrecon_dependencies
    setup_complete_message
}

# Start the Setup Process
full_setup
