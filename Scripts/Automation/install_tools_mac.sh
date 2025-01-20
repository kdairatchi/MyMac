#!/bin/bash
#
# install_tools_mac.sh
# --------------------
# A revised macOS installation script for reconnaissance tools.
# Prompts for 'sudo' only once and keeps the session alive.
#
# Usage:
#   chmod +x install_tools_mac.sh
#   ./install_tools_mac.sh
#

set -e  # Exit immediately if a command exits with a non-zero status.

# ------------------------------------------------------------------------------
# 1. Check & Keep Sudo Active
# ------------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "[*] Requesting sudo access..."
    sudo -v
    # Keep-alive: update existing sudo time stamp until this script has finished
    ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &
fi

# ------------------------------------------------------------------------------
# 2. Check System Requirements
# ------------------------------------------------------------------------------
echo "[*] Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "[!] Homebrew not found. Please install from https://brew.sh/ and re-run."
    exit 1
fi

echo "[*] Checking for Go..."
if ! command -v go &> /dev/null; then
    echo "[!] Go not found. Please install using 'brew install go' (or from https://golang.org/) and re-run."
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. Homebrew Update
# ------------------------------------------------------------------------------
echo "[*] Updating Homebrew..."
brew update

# ------------------------------------------------------------------------------
# 4. Safe Install or Upgrade of Basic Tools
# ------------------------------------------------------------------------------
safe_brew_install() {
    local pkg="$1"

    if brew list --versions "$pkg" &>/dev/null; then
        echo "[*] '$pkg' is already installed. Attempting to link and/or upgrade if needed..."
        brew upgrade "$pkg" || true
    else
        echo "[*] Installing '$pkg'..."
        brew install "$pkg" || true
    fi
    # Attempt to link or re-link
    brew link --overwrite "$pkg" || true
}

echo "[*] Installing/Upgrading basic tools via Homebrew..."

safe_brew_install git
safe_brew_install wget
safe_brew_install curl
safe_brew_install python@3.11
safe_brew_install nmap
safe_brew_install jq
safe_brew_install nikto

# ------------------------------------------------------------------------------
# 5. Python Environment
# ------------------------------------------------------------------------------
echo "[*] Ensuring Python 3 pip is installed..."
pip3 install --upgrade pip setuptools wheel || true

# ------------------------------------------------------------------------------
# 6. Installing Recon Tools
# ------------------------------------------------------------------------------
echo -e "\n[*] Installing Recon Tools..."

# 6.1 Sublist3r
if ! command -v sublist3r &>/dev/null; then
    echo "[*] Installing Sublist3r..."
    sudo mkdir -p /opt/Sublist3r || true
    if [ ! -d "/opt/Sublist3r/.git" ]; then
        sudo git clone https://github.com/aboul3la/Sublist3r.git /opt/Sublist3r
    fi
    sudo ln -sf /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r
    sudo pip3 install -r /opt/Sublist3r/requirements.txt
else
    echo "[*] Sublist3r is already installed."
fi

# 6.2 Assetfinder
if ! command -v assetfinder &>/dev/null; then
    echo "[*] Installing Assetfinder..."
    go install github.com/tomnomnom/assetfinder@latest
    sudo cp ~/go/bin/assetfinder /usr/local/bin/assetfinder
else
    echo "[*] Assetfinder is already installed."
fi

# 6.3 Amass
if ! command -v amass &>/dev/null; then
    echo "[*] Installing Amass..."
    safe_brew_install amass
else
    echo "[*] Amass is already installed."
fi

# 6.4 Subfinder
if ! command -v subfinder &>/dev/null; then
    echo "[*] Installing Subfinder..."
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    sudo cp ~/go/bin/subfinder /usr/local/bin/subfinder
else
    echo "[*] Subfinder is already installed."
fi

# 6.5 httprobe
if ! command -v httprobe &>/dev/null; then
    echo "[*] Installing httprobe..."
    go install github.com/tomnomnom/httprobe@latest
    sudo cp ~/go/bin/httprobe /usr/local/bin/httprobe
else
    echo "[*] httprobe is already installed."
fi

# 6.6 Gowitness
if ! command -v gowitness &>/dev/null; then
    echo "[*] Installing Gowitness..."
    go install github.com/sensepost/gowitness@latest
    sudo cp ~/go/bin/gowitness /usr/local/bin/gowitness
else
    echo "[*] Gowitness is already installed."
fi

# 6.7 Dirsearch
if ! command -v dirsearch &>/dev/null; then
    echo "[*] Installing Dirsearch..."
    sudo mkdir -p /opt/dirsearch || true
    if [ ! -d "/opt/dirsearch/.git" ]; then
        sudo git clone https://github.com/maurosoria/dirsearch.git /opt/dirsearch
    fi
    sudo ln -sf /opt/dirsearch/dirsearch.py /usr/local/bin/dirsearch
else
    echo "[*] Dirsearch is already installed."
fi

# 6.8 ffuf
if ! command -v ffuf &>/dev/null; then
    echo "[*] Installing ffuf..."
    safe_brew_install ffuf
else
    echo "[*] ffuf is already installed."
fi

# 6.9 Nuclei
if ! command -v nuclei &>/dev/null; then
    echo "[*] Installing Nuclei..."
    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    sudo cp ~/go/bin/nuclei /usr/local/bin/nuclei
else
    echo "[*] Nuclei is already installed."
fi

# 6.10 getJS
if ! command -v getJS &>/dev/null; then
    echo "[*] Installing getJS..."
    go install github.com/003random/getJS@latest
    sudo cp ~/go/bin/getJS /usr/local/bin/getJS
else
    echo "[*] getJS is already installed."
fi

# 6.11 waybackurls
if ! command -v waybackurls &>/dev/null; then
    echo "[*] Installing waybackurls..."
    go install github.com/tomnomnom/waybackurls@latest
    sudo cp ~/go/bin/waybackurls /usr/local/bin/waybackurls
else
    echo "[*] waybackurls is already installed."
fi

# 6.12 gau
if ! command -v gau &>/dev/null; then
    echo "[*] Installing gau..."
    go install github.com/lc/gau@latest
    sudo cp ~/go/bin/gau /usr/local/bin/gau
else
    echo "[*] gau is already installed."
fi

# 6.13 qsreplace
if ! command -v qsreplace &>/dev/null; then
    echo "[*] Installing qsreplace..."
    go install github.com/tomnomnom/qsreplace@latest
    sudo cp ~/go/bin/qsreplace /usr/local/bin/qsreplace
else
    echo "[*] qsreplace is already installed."
fi

# 6.14 Subjack
if ! command -v subjack &>/dev/null; then
    echo "[*] Installing subjack..."
    go install github.com/haccer/subjack@latest
    sudo cp ~/go/bin/subjack /usr/local/bin/subjack
else
    echo "[*] subjack is already installed."
fi

# ------------------------------------------------------------------------------
# 7. Wrap-Up
# ------------------------------------------------------------------------------
echo "[*] macOS installation script completed successfully!"
echo "[*] All tools installed and/or linked."
echo "[*] If any tool warns about keg-only (like 'curl'), add its bin path:"
echo "    echo 'export PATH=\"/usr/local/opt/<tool>/bin:\$PATH\"' >> ~/.zshrc"
echo "[*] Done!"

# Stop keeping sudo alive
sudo -k
exit 0
