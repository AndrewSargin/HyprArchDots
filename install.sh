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
sudo pacman -S hyprpaper hyprpolkitagent hyprshot hyprpicker hyprlock hypridle hyprshutdown waybar os-prober swaync rofi-wayland wl-clipboard

#FIREWALL

sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo sytemctl enable --now ufw
sudo ufw enable.

#Japanese Font

reap -p "Install Japanese? [y/n]" jp
if [ "jp" = "y"; then
    sudo pacman -S otf-ipafont
    sudo pacman -S fcitx5-im fcitx-mozc
    sed -i 's/kb_layout = "us,ru"/kb_layout = "us"/' ~/.config/hypr/modules/input.lua
    sed -i 's/kb_options = "grp:alt_shift_toggle"/kb_options=""/' ~/.config/hypr/modules/input.lua
    sed -i 's/hl.on("hyprland.start", function ()/a\   hl.exec_cmd("fcitx5 -d")'
	#Add logic for copying configs for fcitx
fi

#Font

yay -S ttf-cascadia-coede-nerd
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
