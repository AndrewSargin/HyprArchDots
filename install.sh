#!/usr/bin/bash

#==================================
#   Install script for my needs   #
#==================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

confirm() {
    read -rp "$1 [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

echo "Checking sudo..."
sudo -v

#==================================
#       Basic Installation        #
#==================================

echo "Installing base packages..."

sudo pacman --noconfirm -Syu

echo "System updated."

sudo pacman -S --needed git base-devel

#==================================
#         Yay Installation        #
#==================================

if ! command -v yay &>/dev/null; then
    echo "Installing yay..."

    TMP_DIR=$(mktemp -d)
    CURRENT_DIR=$(pwd)
    cd "$TMP_DIR"

    git clone --depth=1 https://aur.archlinux.org/yay-bin.git
    cd yay-bin

    makepkg -si

    cd "$CURRENT_DIR"
    rm -rf "$TMP_DIR"
fi

#==================================
#      First needed packages      #
#==================================

echo "Installing main packages..."

sudo pacman -S --needed \
    hyprpaper \
    hyprpolkitagent \
    hyprshot \
    hypridle \
    hyprpicker \
    hyprlock \
    hyprshutdown \
    os-prober \
    swaync \
    rofi-wayland \
    wl-clipboard \
    cava \
    network-manager-applet \
    matugen \
    pipewire-pulse

yay -S --needed \
    python-setuptools \
    zscroll \
    waybar-git

#==================================
#            FIREWALL             #
#==================================

echo "Installing firewall..."

sudo pacman -S --needed ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing
sleep 1
sudo ufw allow ssh

sudo systemctl enable --now ufw

if ! sudo ufw status | grep -q "Status: active"; then
    sudo ufw --force enable
fi

#==================================
#         Network Manager         #
#==================================

sudo systemctl enable --now NetworkManager

#==================================
#            Japanese             #
#==================================

sudo pacman -S --needed \
    otf-ipafont \
    fcitx5-im \
    fcitx5-mozc

#==================================
#            GTK Theme            #
#==================================

sudo pacman -S --needed adw-gtk-theme

#==================================
#           SDDM Theme            #
#==================================

if pacman -Q sddm &>/dev/null; then
    echo "Installing SDDM theme..."

    sudo pacman -S --needed gum

    TMP_DIR=$(mktemp -d)
    CURRENT_DIR=$(pwd)
    cd "$TMP_DIR"

    git clone --depth=1 https://github.com/Keyitdev/sddm-astronaut-theme.git
    cd sddm-astronaut-theme

    ./setup.sh

    cd "$CURRENT_DIR"
    rm -rf "$TMP_DIR"
else
    echo "SDDM is not detected, theme won't be installed"
fi 

#==================================
#              Fonts              #
#==================================
echo "Installing fonts..."

yay -S --needed \
    ttf-cascadia-code-nerd \
    ttf-all-the-icons \
    noto-color-emoji-config \
    ttf-nerd-fonts-symbols

sudo pacman -S --needed \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji \
    otf-font-awesome

fc-cache -fv

#==================================
#              Sound              #
#==================================

sudo pacman -S --needed pavucontrol

#==================================
#               OBS               #
#==================================

if confirm "Install OBS?"; then
    yay -S --needed obs-studio
fi

#==================================
#             Spotify             #
#==================================

sudo pacman -S --needed spotify-launcher

#==================================
#               MPV               #
#==================================

sudo pacman -S --needed mpv

#==================================
#               VLC               #
#==================================

if confirm "Install VLC Player?"; then
    sudo pacman -S --needed vlc
fi

#==================================
#       Configuration files       #
#==================================

if confirm "Backup .config and .local folders?"; then

    echo "Making backups..."
    
    BACKUP_DIR="$HOME/old_configs/$(date +%d-%m-%Y_%H-%M)"

    mkdir -p "$BACKUP_DIR" || exit 1

    if [[ -d "$HOME/.config" ]]; then
        cp -a "$HOME/.config" "$BACKUP_DIR/"
    fi

    if [[ -d "$HOME/.local" ]]; then
        cp -a "$HOME/.local" "$BACKUP_DIR/"
    fi

fi
echo "Installing configuration files..."

if [[ -d "$SCRIPT_DIR/.config" ]]; then
    mkdir -p "$HOME/.config"
    cp -rf "$SCRIPT_DIR/.config/." "$HOME/.config/"
fi

if [[ -d "$SCRIPT_DIR/.local" ]]; then
    mkdir -p "$HOME/.local"
    cp -rf "$SCRIPT_DIR/.local/." "$HOME/.local/"
fi

echo
echo "=================================="
echo "    Installation is completed!    "
echo "=================================="
