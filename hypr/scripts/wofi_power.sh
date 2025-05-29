#!/usr/bin/env bash

# Check if wofi is already running
if pgrep -x "wofi" > /dev/null; then
    pkill -x "wofi"
    exit 0
fi

op=$( echo -e " Poweroff\n Reboot\n Suspend\n Lock\n Logout" | \
    wofi -i --conf ~/.config/hypr/wofi/power_buttons/power_buttons.conf --style ~/.config/hypr/wofi/power_buttons/power_buttons.css | \
    awk '{print tolower($2)}' )

case $op in 
        poweroff)
                ;&
        reboot)
                ;&
        suspend)
                systemctl $op
                ;;
        lock)
		swaylock
                ;;
        logout)
                hyprctl dispatch exit
                ;;
esac