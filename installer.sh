#!/bin/bash

# Function to install tools using package managers
install_tools() {
    local tools=("$@")
    for tool in "${tools[@]}"; do
        sudo $PKG_MANAGER install -y "$tool"
    done
}

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
        arch)
            PKG_MANAGER="pacman -S --noconfirm"
            TOOLS=(nmap sqlmap hydra john hashcat aircrack-ng wfuzz gobuster nikto metasploit enum4linux smbclient crackmapexec dirb subfinder dnsrecon whatweb ffuf testssl.sh waybackurls seclists feroxbuster impacket wordlists)
            AUR_TOOLS=(naabu-bin nuclei-bin amass httprobe gf puredns)
            ;;
        ubuntu|debian|kali)
            PKG_MANAGER="apt-get"
            TOOLS=(nmap sqlmap hydra john hashcat aircrack-ng wfuzz gobuster nikto metasploit enum4linux smbclient crackmapexec dirb subfinder dnsrecon whatweb ffuf testssl.sh waybackurls seclists feroxbuster impacket wordlists)
            ;;
        fedora)
            PKG_MANAGER="dnf"
            TOOLS=(nmap sqlmap hydra john hashcat aircrack-ng wfuzz gobuster nikto metasploit enum4linux smbclient crackmapexec dirb subfinder dnsrecon whatweb ffuf testssl.sh waybackurls seclists feroxbuster impacket wordlists)
            ;;
        *)
            echo "Unsupported distribution: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

# Update package manager
sudo $PKG_MANAGER update && sudo $PKG_MANAGER upgrade -y

# Install essential dependencies
install_tools git wget curl python3 python3-pip

# Install cybersecurity tools
install_tools "${TOOLS[@]}"

# Special handling for Arch Linux AUR tools
if [[ "$ID" == "arch" ]]; then
    if ! command -v paru &> /dev/null; then
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit
        makepkg -si --noconfirm
        cd ..
        rm -rf paru-bin
    fi
    for aur_tool in "${AUR_TOOLS[@]}"; do
        paru -S --noconfirm "$aur_tool"
    done
fi

# Clean up
if [[ "$ID" == "arch" ]]; then
    sudo pacman -Rns $(pacman -Qdtq) --noconfirm
else
    sudo $PKG_MANAGER autoremove -y && sudo $PKG_MANAGER clean -y
fi

# Display installed tools
echo "\nAll tools installed successfully!"
