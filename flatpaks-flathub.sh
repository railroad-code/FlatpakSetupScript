#!/usr/bin/env bash

# Shell safety options
set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace


# Use a text file passed as the first argument to get the list of Flatpaks.
# Each line should contain a Flatpak application ID; blank lines and comments are ignored.
# flatpak list --app --columns=application

APPS=()


usage() {
    echo "Usage: $0 <app-list-file>"
    echo "  <app-list-file> should contain one Flatpak application ID per line."
    exit 1
}

load_apps_from_file() {
    if [ $# -ne 1 ]; then
        usage
    fi

    local file="$1"
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        echo "Error: Cannot read app list file '$file'." >&2
        exit 1
    fi

    mapfile -t APPS < <(grep -E -v '^[[:space:]]*(#|$)' "$file")
}

confirm_root_execution() {
	if [[ $EUID -eq 0 ]]; then
		echo -e "\nYou are running this script as ROOT.\n"
		read -r -p "Do you want to proceed with Flatpak installations? (y/n): " choice
		case "$choice" in
		[yY] | [yY][eE][sS]) echo -e "\nInstallation..." ;;
		*)
			echo "Exiting..."
			exit 0
			;;
		esac
	fi
}

require_flathub() {
	if ! flatpak remotes --columns=name | grep -q "^flathub$"; then
		echo "Error: Flathub repository is not enabled."
		exit 1
	fi
}

app_install() {
	if [ ${#APPS[@]} -eq 0 ]; then
		echo "    No Flatpaks to install."
		echo "Exiting..."
		exit 1
	fi

	echo -e "\n==== Install Flatpaks ====="
	for app in "${APPS[@]}"; do
		flatpak install -y flathub "$app"
	done
}

app_update() {
	echo -e "\n==== Update Flatpaks ====="
	flatpak update -y
}

app_clean() {
	echo -e "\n==== Clean ====="
	flatpak uninstall --unused -y
}

main() {
	if [ $# -ne 1 ]; then
		usage
	fi

	load_apps_from_file "$1"
	confirm_root_execution
	require_flathub
	app_install
	app_update
	app_clean
}

main "$@"
