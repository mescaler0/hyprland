#!/bin/bash

# file da creare ~/dotfiles/scripts/.local/bin/change-wallpaper.sh

WALLPAPER="$1"
CURRENT_WALLPAPER="$HOME/.cache/current_wallpaper"

if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(find ~/wallpapers -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
fi

if [ ! -f "$WALLPAPER" ]; then
    dunstify "Error" "Wallpaper not found: $WALLPAPER" -u critical
    exit 1
fi

echo "$WALLPAPER" > "$CURRENT_WALLPAPER"

# ← SWWW QUI
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos center \
    --transition-duration 2 \
    --transition-fps 60

wallust run "$WALLPAPER"

pkill waybar && waybar &
sleep 0.2
pkill dunst && dunst &

hyprctl reload

filename=$(basename "$WALLPAPER")
dunstify "Wallpaper Changed" "$filename" -i "$WALLPAPER" -t 3000
