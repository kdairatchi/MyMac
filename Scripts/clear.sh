#!/bin/bash
# ClearTracks v2.0 - Linux Anti-Forensics & Log Cleaner
# Author: Kdairatchi
# Usage: ./clear.sh [--paranoid] [--stealth]

# Configuration
LOGFILE="/var/log/cleartracks.log"
SHRED_ITERATIONS=7  # Gutmann method default
PARANOID=false
STEALTH=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] This script must be run as root${NC}" 
   exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --paranoid)
            PARANOID=true
            SHRED_ITERATIONS=35  # Gutmann maximum
            shift
            ;;
        --stealth)
            STEALTH=true
            shift
            ;;
        *)
            echo -e "${RED}[!] Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

function log() {
    if ! $STEALTH; then
        echo -e "$1"
    fi
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

function clear_bash_history() {
    log "${BLUE}[*] Clearing bash history...${NC}"
    # Overwrite and delete history files
    find /home -name '.bash_history' -exec shred -u -n $SHRED_ITERATIONS {} \;
    find /root -name '.bash_history' -exec shred -u -n $SHRED_ITERATIONS {} \;
    
    # Clear current session history
    history -c
    history -w
    
    # Set future history to null
    export HISTFILE=/dev/null
    export HISTSIZE=0
    export HISTFILESIZE=0
    
    # Alternative method
    ln -sf /dev/null ~/.bash_history
}

function clear_logs() {
    log "${BLUE}[*] Cleaning system logs...${NC}"
    
    # Auth logs
    for logfile in /var/log/auth.log* /var/log/secure*; do
        [ -f "$logfile" ] && shred -u -n $SHRED_ITERATIONS "$logfile"
    done
    
    # System logs
    for logfile in /var/log/syslog* /var/log/messages* /var/log/kern.log*; do
        [ -f "$logfile" ] && shred -u -n $SHRED_ITERATIONS "$logfile"
    done
    
    # Application logs
    for logfile in /var/log/apache2/* /var/log/nginx/* /var/log/mysql/*; do
        [ -f "$logfile" ] && shred -u -n $SHRED_ITERATIONS "$logfile"
    done
    
    # Journald logs
    if command -v journalctl &> /dev/null; then
        journalctl --flush
        journalctl --rotate
        journalctl --vacuum-time=1s
    fi
    
    # Recent files
    rm -f /var/log/wtmp /var/log/btmp /var/log/lastlog
    touch /var/log/wtmp /var/log/btmp /var/log/lastlog
    chmod 660 /var/log/wtmp /var/log/btmp /var/log/lastlog
}

function clear_temp_files() {
    log "${BLUE}[*] Cleaning temporary files...${NC}"
    
    # System temp
    find /tmp -type f -exec shred -u -n $SHRED_ITERATIONS {} \;
    find /var/tmp -type f -exec shred -u -n $SHRED_ITERATIONS {} \;
    
    # User temp
    find /home -type f -name '*.swp' -exec shred -u -n $SHRED_ITERATIONS {} \;
    find /home -type f -name '*.swpx' -exec shred -u -n $SHRED_ITERATIONS {} \;
    find /home -type f -name '*.swo' -exec shred -u -n $SHRED_ITERATIONS {} \;
    find /home -type f -name '*.tmp' -exec shred -u -n $SHRED_ITERATIONS {} \;
    
    # Browser artifacts
    find /home -type d \( -name 'Cache' -o -name 'Cache2' -o -name 'thumbnails' \) -exec rm -rf {} \;
}

function clear_ssh_artifacts() {
    log "${BLUE}[*] Cleaning SSH artifacts...${NC}"
    
    # Known hosts
    find /home -name 'known_hosts' -exec shred -u -n $SHRED_ITERATIONS {} \;
    shred -u -n $SHRED_ITERATIONS /root/.ssh/known_hosts 2>/dev/null
    
    # Auth keys
    find /home -name 'authorized_keys' -exec shred -u -n $SHRED_ITERATIONS {} \;
    shred -u -n $SHRED_ITERATIONS /root/.ssh/authorized_keys 2>/dev/null
    
    # Config files
    find /home -name 'config' -path '*/.ssh/config' -exec shred -u -n $SHRED_ITERATIONS {} \;
}

function clear_system_artifacts() {
    log "${BLUE}[*] Cleaning system artifacts...${NC}"
    
    # Shell history files
    find / -type f \( -name '.bash_history' -o -name '.zsh_history' -o -name '.fish_history' \) -exec shred -u -n $SHRED_ITERATIONS {} \;
    
    # VIM history
    find /home -type f -name '.viminfo' -exec shred -u -n $SHRED_ITERATIONS {} \;
    shred -u -n $SHRED_ITERATIONS /root/.viminfo 2>/dev/null
    
    # MySQL history
    find /home -type f -name '.mysql_history' -exec shred -u -n $SHRED_ITERATIONS {} \;
    shred -u -n $SHRED_ITERATIONS /root/.mysql_history 2>/dev/null
    
    # Python history
    find /home -type f -name '.python_history' -exec shred -u -n $SHRED_ITERATIONS {} \;
}

function clear_metadata() {
    log "${BLUE}[*] Cleaning file metadata...${NC}"
    
    # Extended attributes
    find /home -type f -exec setfattr --remove=user.comment {} \; 2>/dev/null
    find /home -type f -exec setfattr --remove=user.origin_url {} \; 2>/dev/null
    
    # File timestamps
    find /home -type f -exec touch -t 202001010000.00 {} \;
    find /home -type d -exec touch -t 202001010000.00 {} \;
    
    if $PARANOID; then
        # Full disk overwrite (only in paranoid mode)
        log "${YELLOW}[!] Paranoid mode: Overwriting free disk space${NC}"
        dd if=/dev/zero of=/zerofile bs=1M 2>/dev/null
        sync
        rm -f /zerofile
    fi
}

function clear_ram() {
    log "${BLUE}[*] Cleaning RAM artifacts...${NC}"
    
    # Clear swap
    swapoff -a && swapon -a
    
    # Drop caches
    echo 3 > /proc/sys/vm/drop_caches
    
    # Clear slab objects
    echo 2 > /proc/sys/vm/drop_caches
    echo 1 > /proc/sys/vm/compact_memory
}

function clear_network() {
    log "${BLUE}[*] Cleaning network artifacts...${NC}"
    
    # ARP cache
    ip -s -s neigh flush all
    
    # Connection tracking
    if command -v conntrack &> /dev/null; then
        conntrack -F
    fi
    
    # DNS cache
    systemd-resolve --flush-caches 2>/dev/null
}

function clear_package_manager() {
    log "${BLUE}[*] Cleaning package manager logs...${NC}"
    
    # APT
    [ -f /var/log/apt/history.log ] && shred -u -n $SHRED_ITERATIONS /var/log/apt/history.log
    [ -f /var/log/apt/term.log ] && shred -u -n $SHRED_ITERATIONS /var/log/apt/term.log
    [ -f /var/log/dpkg.log ] && shred -u -n $SHRED_ITERATIONS /var/log/dpkg.log
    
    # YUM
    [ -f /var/log/yum.log ] && shred -u -n $SHRED_ITERATIONS /var/log/yum.log
    
    # DNF
    [ -f /var/log/dnf.log ] && shred -u -n $SHRED_ITERATIONS /var/log/dnf.log
    [ -f /var/log/dnf.rpm.log ] && shred -u -n $SHRED_ITERATIONS /var/log/dnf.rpm.log
}

function clear_all() {
    clear_bash_history
    clear_logs
    clear_temp_files
    clear_ssh_artifacts
    clear_system_artifacts
    clear_metadata
    clear_ram
    clear_network
    clear_package_manager
    
    log "${GREEN}[+] All traces cleared successfully${NC}"
    
    if $STEALTH; then
        # Self-destruct if in stealth mode
        shred -u -n $SHRED_ITERATIONS "$0"
    fi
}

# Main execution
echo -e "${RED}"
cat << "EOF"
   _____ _                    _______             _    
  / ____| |                  |__   __|           | |   
 | |    | | ___  __ _ _ __ _ __| |_ __ __ _  ___| | __
 | |    | |/ _ \/ _` | '__| '__| | '__/ _` |/ __| |/ /
 | |____| |  __/ (_| | |  | |  | | | | (_| | (__|   < 
  \_____|_|\___|\__,_|_|  |_|  |_|_|  \__,_|\___|_|\_\
EOF
echo -e "${NC}"

log "${YELLOW}[*] Starting ClearTracks v2.0${NC}"
log "${YELLOW}[*] Mode: ${PARANOID} (Paranoid), ${STEALTH} (Stealth)${NC}"

clear_all

# Final cleanup
sync
log "${GREEN}[+] Operation complete. System traces cleared.${NC}"
