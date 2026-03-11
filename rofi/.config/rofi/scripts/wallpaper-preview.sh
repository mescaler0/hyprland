#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers"
CACHE_DIR="$HOME/.cache/rofi-wallpapers"
CURRENT_WALLPAPER="$HOME/.cache/current_wallpaper"
THEME="$HOME/.config/rofi/styles/wallpaper-preview.rasi"

# Check Wayland
[ -n "$WAYLAND_DISPLAY" ] || { notify-send "Error" "Not in Wayland session"; exit 1; }

# Create cache directory
mkdir -p "$CACHE_DIR"

# Generate thumbnails
echo "Generating thumbnails..." >&2

shopt -s nullglob
for wallpaper in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
    [ -f "$wallpaper" ] || continue
    
    filename=$(basename "$wallpaper")
    thumbnail="$CACHE_DIR/${filename%.*}.png"
    
    # Generate thumbnail if doesn't exist
    if [ ! -f "$thumbnail" ]; then
        convert "$wallpaper" \
            -resize 180x180^ \
            -gravity center \
            -extent 180x180 \
            -quality 90 \
            "$thumbnail" 2>/dev/null
        echo "Created thumbnail: $thumbnail" >&2
    fi
done
shopt -u nullglob

# Get current wallpaper
current_wp=""
[ -f "$CURRENT_WALLPAPER" ] && current_wp=$(cat "$CURRENT_WALLPAPER")

# Build rofi list with icons
cd "$WALLPAPER_DIR" || exit 1

entries=""
for wallpaper in *.{jpg,jpeg,png,webp}; do
    [ -f "$wallpaper" ] || continue
    
    thumbnail="$CACHE_DIR/${wallpaper%.*}.png"
    [ -f "$thumbnail" ] || continue
    
    # Full path
    full_path="$WALLPAPER_DIR/$wallpaper"
    
    # Mark current wallpaper
    if [ "$full_path" = "$current_wp" ]; then
        name="✓ $wallpaper"
    else
        name="$wallpaper"
    fi
    
    # Add to list with icon
    entries+="${name}\0icon\x1f${thumbnail}\n"
done

# Check if we have entries
[ -z "$entries" ] && { notify-send "Error" "No valid wallpapers found"; exit 1; }

# Show rofi and get selection
selected=$(echo -en "$entries" | rofi \
    -dmenu \
    -i \
    -p "Select Wallpaper" \
    -theme "$THEME" \
    -show-icons \
    -selected-row 0)

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Remove checkmark if present
selected="${selected#✓ }"

# Full path to selected wallpaper
wallpaper_path="$WALLPAPER_DIR/$selected"

# Apply wallpaper
if [ -f "$wallpaper_path" ]; then
    # Change wallpaper with swww
    swww img "$wallpaper_path" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 2 \
        --transition-fps 60 2>/dev/null
    
    # Save current wallpaper
    echo "$wallpaper_path" > "$CURRENT_WALLPAPER"
    
    # Generate color palette with wallust
    wallust run "$wallpaper_path"
    
    # Reload applications to apply colors
    sleep 0.3
    pkill waybar && waybar &
    sleep 0.2
    pkill dunst && dunst &
    
    # Reload Hyprland for border colors
    hyprctl reload
    
    # Notify
    notify-send "Wallpaper Changed" "$(basename "$wallpaper_path")" -t 3000
else
    notify-send "Error" "Wallpaper not found: $selected" -u critical
fi
