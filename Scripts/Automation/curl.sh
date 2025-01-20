#!/usr/bin/env bash
# Kdairatchi Automations
# curl.sh
# -------------------
# 1) Creates a local "tools/" dir
# 2) Installs (or updates) nmap, rustscan, sslscan, testssl.sh locally if not found
# 3) Runs quick scans with timeouts on single/multiple domains
#
# Usage:
#   ./install_and_scan.sh -d example.com
#   ./install_and_scan.sh -l domains.txt
#
# Requirements:
#   - bash 4.x or higher
#   - curl, git, tar, unzip (for installing tools)
#   - Standard *nix environment

#######################################
# Color codes
#######################################
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
BOLD="\033[1m"
RESET="\033[0m"

TOOLS_DIR="./tools"   # Directory to store our local binaries
INSTALL_LOG="./install.log"

#######################################
# Print usage
#######################################
usage() {
  echo -e "${BOLD}Usage:${RESET} $0 [options]
  -d <domain>       Single domain
  -l <list_file>    List of domains (one per line)
  -h                Print this help
Examples:
  $0 -d example.com
  $0 -l domains.txt
"
  exit 1
}

#######################################
# Create tools/ dir, if needed
#######################################
prepare_tools_dir() {
  mkdir -p "$TOOLS_DIR"
}

#######################################
# Check if a command is available
# 1) System-wide
# 2) Local tools directory
#######################################
command_exists() {
  local cmd="$1"
  if command -v "$cmd" &>/dev/null; then
    return 0
  elif [[ -f "${TOOLS_DIR}/${cmd}" ]]; then
    return 0
  fi
  return 1
}

#######################################
# Install/Update nmap
#######################################
install_nmap() {
  echo -e "${YELLOW}[+] Installing/Updating nmap locally...${RESET}"
  # Attempt system-level install (macOS: brew, Linux: apt) or fallback to asking user
  if [[ "$(uname -s)" == "Darwin" && -x "$(command -v brew)" ]]; then
    echo -e "${GREEN}[brew] Installing nmap...${RESET}"
    brew install nmap >> "$INSTALL_LOG" 2>&1
    # Symlink to our tools dir
    ln -sf "$(command -v nmap)" "${TOOLS_DIR}/nmap"
  elif [[ -x "$(command -v apt)" ]]; then
    sudo apt update >> "$INSTALL_LOG" 2>&1
    sudo apt install -y nmap >> "$INSTALL_LOG" 2>&1
    ln -sf "$(command -v nmap)" "${TOOLS_DIR}/nmap"
  else
    echo -e "${RED}[-] Could not auto-install nmap. Attempting to download binary...${RESET}"
    echo -e "${RED}[!] On many distros, you can do: sudo apt-get install nmap${RESET}"
    # Fallback: user must install manually or see if there's a generic binary package
    # Nmap doesn't typically provide single binary easily, so let's rely on user
    return 1
  fi
  return 0
}

#######################################
# Install Rustscan
#######################################
install_rustscan() {
  echo -e "${YELLOW}[+] Installing/Updating rustscan locally...${RESET}"
  local latest_url
  # For macOS x86_64 or Linux x86_64
  if [[ "$(uname -s)" == "Darwin" ]]; then
    latest_url="https://github.com/RustScan/RustScan/releases/latest/download/rustscan-x86_64-apple-darwin.tar.gz"
  else
    latest_url="https://github.com/RustScan/RustScan/releases/latest/download/rustscan-x86_64-unknown-linux-gnu.tar.gz"
  fi

  ( 
    cd "$TOOLS_DIR"
    curl -sSL "$latest_url" -o rustscan.tar.gz
    tar -xzf rustscan.tar.gz
    rm rustscan.tar.gz
    # The tar should contain a single binary named "rustscan"
    # If the binary name differs, rename it:
    if [[ -f rustscan ]]; then
      chmod +x rustscan
    else
      # If extracted folder or different name, adjust as needed
      mv *rustscan* rustscan 2>/dev/null
      chmod +x rustscan
    fi
  ) >> "$INSTALL_LOG" 2>&1
  echo -e "${GREEN}[+] rustscan installed in ${TOOLS_DIR}${RESET}"
}

#######################################
# Install sslscan
#######################################
install_sslscan() {
  echo -e "${YELLOW}[+] Installing/Updating sslscan locally...${RESET}"
  if command -v brew &>/dev/null; then
    brew install sslscan >> "$INSTALL_LOG" 2>&1
    ln -sf "$(command -v sslscan)" "${TOOLS_DIR}/sslscan"
  elif [[ -x "$(command -v apt)" ]]; then
    sudo apt update >> "$INSTALL_LOG" 2>&1
    sudo apt install -y sslscan >> "$INSTALL_LOG" 2>&1
    ln -sf "$(command -v sslscan)" "${TOOLS_DIR}/sslscan"
  else
    # Attempt build from source or ask user
    echo -e "${RED}[-] Could not auto-install sslscan. Attempting to build from source...${RESET}"
    (
      cd "$TOOLS_DIR"
      git clone https://github.com/rbsec/sslscan.git 2>/dev/null || true
      cd sslscan
      cmake . >> "../../$INSTALL_LOG" 2>&1
      make >> "../../$INSTALL_LOG" 2>&1
      cp sslscan ../
      cd ..
    ) >> "$INSTALL_LOG" 2>&1
    if [[ -f "${TOOLS_DIR}/sslscan" ]]; then
      chmod +x "${TOOLS_DIR}/sslscan"
      echo -e "${GREEN}[+] sslscan built from source in ${TOOLS_DIR}${RESET}"
    else
      echo -e "${RED}[-] Failed to install sslscan. Please install manually.${RESET}"
    fi
  fi
}

#######################################
# Install testssl.sh
#######################################
install_testssl() {
  echo -e "${YELLOW}[+] Installing/Updating testssl.sh locally...${RESET}"
  (
    cd "$TOOLS_DIR"
    if [[ -d testssl.sh ]]; then
      cd testssl.sh && git pull >> "../../$INSTALL_LOG" 2>&1
    else
      git clone https://github.com/drwetter/testssl.sh.git >> "../$INSTALL_LOG" 2>&1
    fi
  )
  chmod +x "${TOOLS_DIR}/testssl.sh/testssl.sh"
  echo -e "${GREEN}[+] testssl.sh is in ${TOOLS_DIR}/testssl.sh${RESET}"
}

#######################################
# Ensure we have all required tools
# in local dir or system-wide
#######################################
install_dependencies() {
  echo -e "${BLUE}[*] Checking or installing dependencies...${RESET}"

  # Nmap
  if ! command_exists "nmap"; then
    install_nmap
  fi
  if ! command_exists "nmap"; then
    echo -e "${RED}[-] nmap is still not installed. Exiting.${RESET}"
    exit 1
  fi

  # Rustscan
  if ! command_exists "rustscan"; then
    install_rustscan
  fi
  if ! command_exists "rustscan"; then
    echo -e "${RED}[-] rustscan is still not installed. Some scans won't run.${RESET}"
  fi

  # sslscan
  if ! command_exists "sslscan"; then
    install_sslscan
  fi
  if ! command_exists "sslscan"; then
    echo -e "${RED}[-] sslscan is still not installed. Some scans won't run.${RESET}"
  fi

  # testssl.sh
  if [[ ! -f "${TOOLS_DIR}/testssl.sh/testssl.sh" ]]; then
    install_testssl
  fi
  if [[ ! -f "${TOOLS_DIR}/testssl.sh/testssl.sh" ]]; then
    echo -e "${RED}[-] testssl.sh is still not installed. Some scans won't run.${RESET}"
  fi

  # Add tools dir to PATH if not already
  if ! echo "$PATH" | grep -q "$TOOLS_DIR"; then
    export PATH="$PWD/$TOOLS_DIR:$PATH"
  fi
}

#######################################
# The main recon function
#######################################
run_recon() {
  local domain="$1"
  echo -e "\n${BLUE}===== Recon Starting for: ${domain} =====${RESET}"

  mkdir -p "results/${domain}"
  local outdir="results/${domain}"

  # dig
  echo -e "${YELLOW}[dig]${RESET} Running dig on ${domain}..."
  timeout 10 dig "$domain" ANY +noall +answer > "${outdir}/dig_${domain}.txt" 2>&1

  # nslookup
  echo -e "${YELLOW}[nslookup]${RESET} Running nslookup on ${domain}..."
  timeout 10 nslookup "$domain" > "${outdir}/nslookup_${domain}.txt" 2>&1

  # whois
  echo -e "${YELLOW}[whois]${RESET} Gathering whois info for ${domain}..."
  timeout 15 whois "$domain" > "${outdir}/whois_${domain}.txt" 2>&1

  # nmap (skip ping => -Pn)
  echo -e "${YELLOW}[nmap]${RESET} Scanning common ports on ${domain} with -Pn..."
  timeout 90 nmap -sV -T4 -Pn --max-retries 1 -p80,443,53,8080,5060 \
    --host-timeout 90s \
    -oN "${outdir}/nmap_${domain}.txt" "$domain" 2>&1

  # rustscan (if installed)
  if command_exists "rustscan"; then
    echo -e "${YELLOW}[rustscan]${RESET} Quick port scan on ${domain}..."
    timeout 60 rustscan -a "$domain" --ulimit 5000 \
      --scan-order serial \
      --timeout 500 \
      -- -sV -T4 -Pn -oN "${outdir}/rustscan_${domain}.txt" 2>&1
  else
    echo -e "${RED}[-] rustscan not found; skipping.${RESET}"
  fi

  # sslscan (if installed)
  if command_exists "sslscan"; then
    echo -e "${YELLOW}[sslscan]${RESET} Checking SSL/TLS configuration for ${domain}..."
    sslscan --timeout=5 "$domain" > "${outdir}/sslscan_${domain}.txt" 2>&1
  fi

  # testssl.sh (if installed)
  if [[ -f "${TOOLS_DIR}/testssl.sh/testssl.sh" ]]; then
    echo -e "${YELLOW}[testssl.sh]${RESET} Running testssl.sh on ${domain}..."
    timeout 90 "${TOOLS_DIR}/testssl.sh/testssl.sh" \
      --timeout 5 \
      --openssl-timeout 5 \
      --color 0 \
      --logfile "${outdir}/testssl_${domain}.log" \
      --outfile "${outdir}/testssl_${domain}.txt" \
      "$domain" 2>/dev/null
  fi

  echo -e "${GREEN}[+] Finished recon for ${domain}! See '${outdir}' for results.${RESET}"
}

#######################################
# main
#######################################
main() {
  # parse args
  local domain=""
  local list=""

  while getopts "d:l:h" opt; do
    case "$opt" in
      d) domain="$OPTARG" ;;
      l) list="$OPTARG" ;;
      h|*) usage ;;
    esac
  done

  if [[ -z "$domain" && -z "$list" ]]; then
    usage
  fi

  prepare_tools_dir
  install_dependencies

  if [[ -n "$domain" ]]; then
    run_recon "$domain"
  fi

  if [[ -n "$list" ]]; then
    if [[ ! -f "$list" ]]; then
      echo -e "${RED}[-] '$list' does not exist.${RESET}"
      exit 1
    fi
    while IFS= read -r d; do
      [[ -z "$d" || "$d" =~ ^# ]] && continue
      run_recon "$d"
    done < "$list"
  fi
}

main "$@"
