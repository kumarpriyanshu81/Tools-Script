#!/bin/bash

# Define installation directories
TOOLS_DIR="$HOME/tools"
BIN_DIR="$HOME/.local/bin"

# Create necessary directories
mkdir -p "$TOOLS_DIR" "$BIN_DIR"

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    sudo apt update && sudo apt install -y curl wget git python3-pip nmap ffuf whatweb
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    sudo pacman -Sy --noconfirm curl wget git python-pip nmap ffuf whatweb
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    sudo dnf install -y curl wget git python3-pip nmap ffuf whatweb
else
    echo "Unsupported package manager. Install dependencies manually."
    exit 1
fi

# Install Go
if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O go.tar.gz
    sudo tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    source ~/.bashrc
fi

# Install Subdomain Enumeration Tools
echo "Installing Subdomain Enumeration tools..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/owasp-amass/amass/v4/...@latest

# Install Naabu for Port Scanning
echo "Installing Naabu..."
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# Install Directory Brute-forcing Tools
echo "Installing Dirsearch..."
git clone https://github.com/maurosoria/dirsearch.git "$TOOLS_DIR/dirsearch"
ln -sf "$TOOLS_DIR/dirsearch/dirsearch.py" "$BIN_DIR/dirsearch"

# Install Tech Stack Detection Tools
echo "Installing Wappalyzer..."
git clone https://github.com/AliasIO/wappalyzer.git "$TOOLS_DIR/wappalyzer"
cd "$TOOLS_DIR/wappalyzer" && npm install && cd -

# Install Screenshot Capturing Tools
echo "Installing Gowitness..."
go install -v github.com/sensepost/gowitness@latest

# Install Parameter Discovery Tools
echo "Installing Waybackurls, GF, and Katana..."
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/tomnomnom/gf@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest

# Install JS File Scraping Tools
echo "Installing GetJS and LinkFinder..."
go install -v github.com/003random/getJS@latest
git clone https://github.com/GerbenJavado/LinkFinder.git "$TOOLS_DIR/LinkFinder"
pip3 install -r "$TOOLS_DIR/LinkFinder/requirements.txt"
ln -sf "$TOOLS_DIR/LinkFinder/linkfinder.py" "$BIN_DIR/linkfinder"

# Install Nuclei for Automated Scanning
echo "Installing Nuclei..."
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Add tools to PATH
echo 'export PATH=$PATH:$HOME/.local/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

echo "✅ Installation Complete! Run your tools from anywhere."

