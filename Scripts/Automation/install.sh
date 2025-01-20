#!/bin/bash
# chmod +x install.sh
# install.sh
# ----------------
# This script installs all the required tools for the reconnaissance process.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "[*] Updating package lists..."
sudo apt-get update -y

echo "[*] Installing essential packages..."
sudo apt-get install -y git wget curl python3 python3-pip nmap snap jq \
    chromium-browser  # (For Gowitness screenshots, if needed)

# --------------------------------------------------
# Install Recon Tools
# --------------------------------------------------

echo "[*] Installing Sublist3r..."
if ! command -v sublist3r &> /dev/null; then
    sudo git clone https://github.com/aboul3la/Sublist3r.git /opt/Sublist3r
    sudo ln -sf /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r
    # Requirements
    sudo pip3 install -r /opt/Sublist3r/requirements.txt
fi

echo "[*] Installing Assetfinder..."
if ! command -v assetfinder &> /dev/null; then
    go install github.com/tomnomnom/assetfinder@latest
    sudo cp ~/go/bin/assetfinder /usr/local/bin/
fi

echo "[*] Installing Amass..."
if ! command -v amass &> /dev/null; then
    sudo snap install amass
fi

echo "[*] Installing Subfinder..."
if ! command -v subfinder &> /dev/null; then
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    sudo cp ~/go/bin/subfinder /usr/local/bin/
fi

echo "[*] Installing httprobe..."
if ! command -v httprobe &> /dev/null; then
    go install github.com/tomnomnom/httprobe@latest
    sudo cp ~/go/bin/httprobe /usr/local/bin/
fi

echo "[*] Installing Gowitness..."
if ! command -v gowitness &> /dev/null; then
    go install github.com/sensepost/gowitness@latest
    sudo cp ~/go/bin/gowitness /usr/local/bin/
fi

# Alternatively, you can install Aquatone if you prefer
# echo "[*] Installing Aquatone..."
# go install github.com/michenriksen/aquatone@latest
# sudo cp ~/go/bin/aquatone /usr/local/bin/

echo "[*] Installing dirsearch..."
if ! [ -d "/opt/dirsearch" ]; then
    sudo git clone https://github.com/maurosoria/dirsearch.git /opt/dirsearch
    sudo ln -sf /opt/dirsearch/dirsearch.py /usr/local/bin/dirsearch
fi

echo "[*] Installing ffuf..."
if ! command -v ffuf &> /dev/null; then
    go install github.com/ffuf/ffuf@latest
    sudo cp ~/go/bin/ffuf /usr/local/bin/
fi

echo "[*] Installing nikto..."
if ! command -v nikto &> /dev/null; then
    sudo apt-get install -y nikto
fi

echo "[*] Installing nuclei..."
if ! command -v nuclei &> /dev/null; then
    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    sudo cp ~/go/bin/nuclei /usr/local/bin/
fi

echo "[*] Installing getJS..."
if ! command -v getJS &> /dev/null; then
    go install github.com/003random/getJS@latest
    sudo cp ~/go/bin/getJS /usr/local/bin/
fi

echo "[*] Installing waybackurls..."
if ! command -v waybackurls &> /dev/null; then
    go install github.com/tomnomnom/waybackurls@latest
    sudo cp ~/go/bin/waybackurls /usr/local/bin/
fi

echo "[*] Installing gau..."
if ! command -v gau &> /dev/null; then
    go install github.com/lc/gau@latest
    sudo cp ~/go/bin/gau /usr/local/bin/
fi

echo "[*] Installing qsreplace..."
if ! command -v qsreplace &> /dev/null; then
    go install github.com/tomnomnom/qsreplace@latest
    sudo cp ~/go/bin/qsreplace /usr/local/bin/
fi

echo "[*] Installing subjack..."
if ! command -v subjack &> /dev/null; then
    go install github.com/haccer/subjack@latest
    sudo cp ~/go/bin/subjack /usr/local/bin/
fi

echo "[*] All tools installed successfully!"

exit 0
