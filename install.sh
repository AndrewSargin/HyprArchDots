#!/usr/bin/bash

#==================================
#   Install script for my needs   #
#==================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

info() {
    echo -e "\n${BLUE}===== $1 =====${RESET}"
}

success() {
    echo -e "\n${GREEN}===== $1 =====${RESET}"
}

warning() {
    echo -e "\n${YELLOW}===== $1 =====${RESET}"
}

error() {
    echo -e "\n${RED}===== $1 =====${RESET}"
}

confirm() {
    echo -ne "${MAGENTA}$1 [y/N]: ${RESET} "
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

create_tmp() {
    TMP_DIR=$(mktemp -d)
    CURRENT_DIR=$(pwd)
}

error_handler() {
    local exit_code=$?
    error "Command '${BASH_COMMAND}' failed with exit code ${exit_code} on line ${BASH_LINENO[0]}"
}

trap error_handler ERR

cleanup() {
    [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

trap cleanup EXIT

info "Checking sudo"
sudo -v

#==================================
#       Basic Installation        #
#==================================

info "Installing base packages"

sudo pacman -Syu --noconfirm

info "System updated"

sudo pacman -S --needed --noconfirm git base-devel

success "Base packages are installed"

#==================================
#         Yay Installation        #
#==================================

if ! command -v yay &>/dev/null; then
    info "Installing yay"
    
    create_tmp
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

info "Installing main packages"

# Ignored if isn't installed or can't be uninstalled
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
    nautilus \
    nvim \
    stow \
    obsidian \
    tree-sitter \
    tree-sitter-cli \
    pyright

yay -S --needed --noconfirm \
    python-setuptools \
    zscroll \
    waybar-git \
    gvfs-mtp

success "Main packages are installed"

#==================================
#            FIREWALL             #
#==================================

if confirm "Install UFW (firewall)?"; then
    info "Checking if firewall is installed"

    if systemctl is-active --quiet ufw ||
       systemctl is-active --quiet firewalld ||
       systemctl is-active --quiet nftables; then

        warning "An active firewall is detected, skipping firewall setup."

    else

        info "Installing firewall"

        sudo pacman -S --needed --noconfirm ufw

        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sleep 1
        sudo ufw allow ssh

        sudo systemctl enable --now ufw

        if ! sudo ufw status | grep -q "Status: active"; then
            sudo ufw --force enable
        fi
        success "Firewall is ready"
    fi
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
#     SDDM Theme and Numlock      #
#==================================

if pacman -Q sddm &>/dev/null; then
   
    info "Turning in Numlock"

    sudo mkdir -p /etc/sddm.conf.d
    echo "[General]
    Numlock=on" | sudo tee /etc/sddm.conf.d/numlock.conf

    success "Numlock is on by default now"

    info "Installing SDDM theme"

    sudo pacman -S --needed --noconfirm gum

    create_tmp
    cd "$TMP_DIR"
    
    git clone --depth=1 https://github.com/Keyitdev/sddm-astronaut-theme.git
    cd sddm-astronaut-theme

    ./setup.sh

    cd "$CURRENT_DIR"
    rm -rf "$TMP_DIR"

    success "SDDM theme is installed"
else
    warning "SDDM is not detected, theme won't be installed"
fi 

#==================================
#              Fonts              #
#==================================
info "Installing fonts"

yay -S --needed --noconfirm \
    ttf-cascadia-code-nerd \
    ttf-all-the-icons \
    noto-color-emoji-config \
    ttf-nerd-fonts-symbols

sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji \
    otf-font-awesome \
    noto-fonts-cjk \
    noto-fonts

fc-cache -fv

success "Fonts are installed"

#==================================
#              Sound              #
#==================================

sudo pacman -S --needed --noconfirm pavucontrol

#==================================
#               OBS               #
#==================================

if confirm "Install OBS?"; then
    yay -S --needed --noconfirm obs-studio
    success "OBS is installed"
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
    success "VLC is installed"
fi

#==================================
#            UTC time             #
#==================================

if confirm "Set time UTC+3 (Moscow)? Do this only if you 
    set your timezone as UTC in archinstall script."; then
    timedatectl set-timezone Europe/Moscow
    success "Time set to Moscow"
fi
#==================================
#          Creative apps          #
#==================================

if confirm "Install tablet drivers?"; then
    yay -S --noconfirm opentabletdriver
    sudo mkinitcpio -P
    sudo rmmod wacom hid_uclogic || true
    success "Tablet drivers are installed"
fi

if confirm "Install creative apps? (Blender, Krita)"; then
    sudo pacman -S --needed --noconfirm \
        krita \
        blender
    success "Creative apps are installed"
fi

#==================================
#       Configuration files       #
#==================================

if confirm "Backup .config and .local folders?"; then

    info "Making backups"

    BACKUP_DIR="$HOME/old_configs/$(date +%d-%m-%Y_%H-%M)"

    mkdir -p "$BACKUP_DIR/.config"

    for dir in "$SCRIPT_DIR/.config"/*; do
        name=$(basename "$dir")

        if [[ -d "$HOME/.config/$name" ]]; then
            cp -a "$HOME/.config/$name" "$BACKUP_DIR/.config/"
        fi
    done

    mkdir -p "$BACKUP_DIR/.local/share"

    for dir in "$SCRIPT_DIR/.local/share"/*; do
        name=$(basename "$dir")
        
        if [[ -d "$HOME/.local/share/$name" ]]; then
            cp -a "$HOME/.local/share/$name" "$BACKUP_DIR/.local/share"
        fi
    done

    success "Files are backed up"

fi

info "Installing configuration files"

if [[ -d "$SCRIPT_DIR/.config" ]]; then
    mkdir -p "$HOME/.config"
    cp -rf "$SCRIPT_DIR/.config/." "$HOME/.config/"
fi

if [[ -d "$SCRIPT_DIR/.local" ]]; then
    mkdir -p "$HOME/.local"
    cp -rf "$SCRIPT_DIR/.local/." "$HOME/.local/"
fi

success "Configuration files are installed"

#==================================
#      DUAL BOOT (GRUB only)      #
#==================================

if confirm "Enable dual boot (GRUB, os-prober)?"; then
    
    if ! command -v grub-mkconfig &>/dev/null; then
        warning "GRUB not found, skipping"

    else
        sudo pacman -S --needed --noconfirm os-prober

        if grep -q "^GRUB_DISABLE_OS_PROBER=" /etc/default/grub; then
            sudo sed -i "s|^GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|" /etc/default/grub
        elif grep -q "^#GRUB_DISABLE_OS_PROBER=" /etc/default/grub; then
            sudo sed -i "s|^#GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|" /etc/default/grub
        else
            echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub
        fi
        
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        success "Dual boot is enabled"
    fi
fi

#==================================
#           GRUB theme            #
#==================================

if confirm "Install GRUB theme?"; then
    
    if ! command -v grub-mkconfig &>/dev/null; then
        warning "GRUB not found, skipping"

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
        
            sudo mkdir -p /boot/grub/themes
            sudo cp -r "$theme_src" /boot/grub/themes/

            if grep -q "^GRUB_THEME=" /etc/default/grub; then
                sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$theme_dst/theme.txt\"|" /etc/default/grub
            elif grep -q "^#GRUB_THEME=" /etc/default/grub; then
                sudo sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=\"$theme_dst/theme.txt\"|" /etc/default/grub
            else
                echo "GRUB_THEME=\"$theme_dst/theme.txt\"" | sudo tee -a /etc/default/grub
            fi

            sudo grub-mkconfig -o /boot/grub/grub.cfg
            success "Theme $theme_name is installed."
        }
        
        case "$grub_theme" in
            1) install_grub_theme "poly-dark" ;;
            2) install_grub_theme "blackice" ;;
            3) install_grub_theme "astronaut" ;;
            4) install_grub_theme "astronaut_orange" ;;
            0) info "Canceling installation" ;;
            *) info "Canceling installation" ;;
        esac
    fi
fi
    
success "=================================="
success "    Installation is completed!    "
success "       Reboot is required.        "
success "=================================="

