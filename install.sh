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

sudo pacman -Syu --noconfirm

echo "System updated."

sudo pacman -S --needed --noconfirm git base-devel

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

    makepkg -si --noconfirm

    cd "$CURRENT_DIR"
    rm -rf "$TMP_DIR"
fi

#==================================
#      First needed packages      #
#==================================

echo "Installing main packages..."

# Ignored if ins't installed or can't be uninstalled
sudo pacman -R --noconfirm pulseaudio pulseaudio-bluetooth 2>/dev/null || true

sudo pacman -S --needed --noconfirm \
    hyprpaper \
    hyprpolkitagent \
    hyprshot \
    hypridle \
    hyprpicker \
    hyprlock \
    hyprshutdown \
    swaync \
    rofi-wayland \
    wl-clipboard \
    cava \
    network-manager-applet \
    matugen \
    pipewire-pulse \
    nautilus

yay -S --needed --noconfirm \
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

sudo pacman -S --needed --noconfirm \
    otf-ipafont \
    fcitx5-im \
    fcitx5-mozc

#==================================
#            GTK Theme            #
#==================================

sudo pacman -S --needed --noconfirm adw-gtk-theme

#==================================
#           SDDM Theme            #
#==================================

if pacman -Q sddm &>/dev/null; then
    echo "Installing SDDM theme..."

    sudo pacman -S --needed --noconfirm gum

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

yay -S --needed --noconfirm \
    ttf-cascadia-code-nerd \
    ttf-all-the-icons \
    noto-color-emoji-config \
    ttf-nerd-fonts-symbols

sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji \
    otf-font-awesome

fc-cache -fv

#==================================
#              Sound              #
#==================================

sudo pacman -S --needed --noconfirm pavucontrol

#==================================
#               OBS               #
#==================================

if confirm "Install OBS?"; then
    yay -S --needed --noconfirm obs-studio
fi

#==================================
#             Spotify             #
#==================================

sudo pacman -S --needed --noconfirm spotify-launcher

#==================================
#               MPV               #
#==================================

sudo pacman -S --needed --noconfirm mpv

#==================================
#               VLC               #
#==================================

if confirm "Install VLC Player?"; then
    sudo pacman -S --needed --noconfirm vlc
fi

#==================================
#          Creative apps          #
#==================================

if confirm "Install tablet drivers?"; then
    yay -S opentabletdriver --noconfirm
    sudo mkinitcpio -P
    sudo rmmod wacom hid_uclogic || true
fi

if confirm "Install creative apps? (Blender, Krita)"
    sudo pacman -S --needed --noconfirm \
        krita \
        blender
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

#==================================
#      DUAL BOOT (GRUB only)      #
#==================================

if confirm "Enable dual boot (GRUB, os-prober)?"; then
    
    if ! command -v grub-mkconfig &>/dev/null; then
        echo "GRUB not found, skipping..."

    else
        sudo pacman -S --needed os-prober

        if grep -q "^GRUB_DISABLE_OS_PROBER=" /etc/default/grub; then
            sudo sed -i "s|^GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|" /etc/default/grub
        else
            echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub
        fi
        
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
fi

#==================================
#           GRUB theme            #
#==================================

if confirm "Install GRUB theme?"; then
    
    if ! command -v grub-mkconfig &>/dev/null; then
        echo "GRUB not found, skipping..."

    else
        echo "Choose GRUB theme:"
        echo "1) Poly-dark"
        echo "2) Blackice"
        echo "3) Astronaut"
        echo "4) Astronaut Orange"
        echo "0) Cancel"
        read -rp "Enter number [0-4]: " grub_theme

        # Used only here
        install_grub_theme() {
        
            local theme_name=$1
            local theme_src="$SCRIPT_DIR/grub/$theme_name"
            local theme_dst="/boot/grub/themes/$theme_name"

            if [[ ! -d "$theme_src" ]]; then
                echo " Theme $theme_name not found in repository..."
                return 1
            fi
        
            sudo cp -r "$theme_src" /boot/grub/themes/

            if grep -q "^GRUB_THEME=" /etc/default/grub; then
                sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$theme_dst/theme.txt\"|" /etc/default/grub
            else
                echo "GRUB_THEME=\"$theme_dst/theme.txt\"" | sudo tee -a /etc/default/grub
            fi

            sudo grub-mkconfig -o /boot/grub/grub.cfg
            echo "Theme $theme_name is installed."
        }
        
        case "$grub_theme" in
            1) install_grub_theme "poly-dark" ;;
            2) install_grub_theme "blackice" ;;
            3) install_grub_theme "astronaut" ;;
            4) install_grub_theme "astronaut_orange" ;;
            0) echo "Canceling installation..." ;;
            *) echo "Canceling installation..." ;;
        esac
    fi
fi
    

echo
echo "=================================="
echo "    Installation is completed!    "
echo "       Reboot is required.        "
echo "=================================="
