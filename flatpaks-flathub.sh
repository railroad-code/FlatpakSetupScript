#!/usr/bin/env bash


# Shell safety options
set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace


################### MODIFICATION BELOW THIS LINE ###################
# Use is command line to get the list of installed flatpaks
# flatpak list --app --columns=application


apps=(
app.zen_browser.zen
com.bitwarden.desktop
com.discordapp.Discord
com.github.marhkb.Pods
com.github.tchx84.Flatseal
com.github.wwmm.easyeffects
com.mattjakeman.ExtensionManager
com.protonvpn.www
com.ranfdev.DistroShelf
com.visualstudio.code
io.bassi.Amberol
io.github.flattool.Warehouse
io.github.giantpinkrobots.varia
io.gitlab.adhami3310.Converter
io.gitlab.theevilskeleton.Upscaler
it.mijorus.gearlever
md.obsidian.Obsidian
net.nokyan.Resources
net.pcsx2.PCSX2
org.DolphinEmu.dolphin-emu
org.gnome.Calculator
org.gnome.Decibels
org.gnome.Loupe
org.gnome.Papers
org.gnome.Showtime
org.gnome.Snapshot
org.gnome.TextEditor
org.gnome.World.PikaBackup
org.gnome.baobab
org.keepassxc.KeePassXC
org.libretro.RetroArch
org.ppsspp.PPSSPP
org.qbittorrent.qBittorrent
page.tesk.Refine
)


################### NO MODIFICATION BELOW THIS LINE ###################
function confirm_root_execution() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "\nYou are running this script as ROOT.\n"
        read -r -p "Do you want to proceed with Flatpak installations? (y/n): " choice
        case "$choice" in 
            [yY]|[yY][eE][sS]) echo -e "\nInstallation...";;
            *) echo "Exiting..."; exit 0;;
        esac
    fi
}


function require_flathub() {
    if ! flatpak remotes --columns=name | grep -q "^flathub$"; then
        echo "Error: Flathub repository is not enabled."
        exit 1
    fi
}


function app_install(){
    if [ ${#apps[@]} -eq 0 ]; then
        echo "    No Flatpaks to install."
        echo "Exiting..."
        exit 1
    fi

    echo -e "\n==== Install Flatpaks ====="
    for app in "${apps[@]}"; do
        flatpak install -y flathub "$app" 
    done
}


function app_update(){
    echo -e "\n==== Update Flatpaks ====="
    flatpak update -y
}


function app_clean(){
    echo -e "\n==== Clean ====="
    flatpak uninstall --unused -y
}


function main(){
    confirm_root_execution
    require_flathub
    app_install
    app_update
    app_clean
}


main
