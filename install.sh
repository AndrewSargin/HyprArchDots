#!/bin/bash


#Install script for my needs


#Basic Installation

sudo pacman -S git
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
sudo pacman -S base-devel
makepkg -si
cd ../
rm -rf ./yay-bin

#First needed packages installation
sudo pacman -S hyprpaper hyprpolkitagent hyprshot hyprpicker hyprlock hypridle hyprshutdown os-prober swaync rofi-wayland wl-clipboard cava network-manager-applet matugen pipewire-pulse
yay -S python-setuptools zscroll waybar-git

#FIREWALL

sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo sytemctl enable --now ufw
sudo ufw enable.

#Language

    sudo pacman -S otf-ipafont
    sudo pacman -S fcitx5-im fcitx-mozc

#Font

yay -S ttf-cascadia-coede-nerd
yay -S ttf-all-the-icons
yay -S noto-color-emoji-config
yay -S ttf-nerd-fonts-symbols
sudo pacman -S ttf-jetbrains-mono-nerd
sudo pacman -S noto-fonts-emoji
sudo pacman -S otf-font-awesome
fc-cache -f -v

#Sound (Controls)

sudo pacman -S pavucontrol

#OBS

read -p "Install OBS? [y/n]" obs
if [ "obs" = "y"; then
    yay -S obs-studio
fi

#SOUND (SPOTIFY)

sudo pacman -S spotify-launcher

#Video Player

sudo pacman -S mpv

read -p "Install VLC Player? [y/n]" vlc
if [ "vlc" = "y"; then
    sudo pacman -S vlc
fi
