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
sudo pacman -S hyprpaper hyprpolkitagent hyprshot hyprpicker hyprlock hypridle hyprshutdown waybar os-prober swaync

#FIREWALL

sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo sytemctl enable --now ufw
sudo ufw enable.

#Japanese Font

reap -p "Install Japanese Font? [y/n]" jpFont
if [ "jpFont" = "y"; then
    sudo pacman -S otf-ipafont
    fc-cache -f -v
fi

#Font

yay -S ttf-cascadia-coede-nerd

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
