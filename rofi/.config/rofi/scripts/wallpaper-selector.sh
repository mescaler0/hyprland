#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers"
CURRENT_WALLPAPER="$HOME/.cache/current_wallpaper"

# Ensure we're in a Hyprland session
[ -n "$WAYLAND_DISPLAY" ] || { notify-send "Error" "Not running inside Wayland/Hyprland"; exit 1; }

# List wallpapers
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

[ ${#wallpapers[@]} -eq 0 ] && { notify-send "Error" "No wallpapers found in $WALLPAPER_DIR"; exit 1; }

# Rofi menu
selected=$(printf "%s\n" "${wallpapers[@]}" | rofi -dmenu -i -p "Select wallpaper")

[ -z "$selected" ] && exit 0

# Apply wallpaper using swww (make sure swww runs in Wayland session)
if [ -f "$selected" ]; then
    # Using execr to run swww through Hyprland dispatcher
    hyprctl dispatch execr "swww img '$selected' fill"
    echo "$selected" > "$CURRENT_WALLPAPER"
    notify-send "Wallpaper changed" "$selected"
else
    notify-send "Error" "Wallpaper not found: $selected"
fi
