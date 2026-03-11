#!/bin/bash

# Update dotfiles from current system

DOTFILES_DIR="$HOME/dotfiles"

echo "Updating dotfiles from current system..."

# Copy configs
cp ~/.config/hypr/hyprland.conf "$DOTFILES_DIR/hyprland/.config/hypr/"
cp ~/.config/waybar/config "$DOTFILES_DIR/waybar/.config/waybar/"
cp ~/.config/waybar/style.css "$DOTFILES_DIR/waybar/.config/waybar/"
cp -r ~/.config/rofi/styles "$DOTFILES_DIR/rofi/.config/rofi/"
cp -r ~/.config/rofi/scripts "$DOTFILES_DIR/rofi/.config/rofi/"
cp ~/.config/kitty/kitty.conf "$DOTFILES_DIR/kitty/.config/kitty/"
cp -r ~/.config/wallust/* "$DOTFILES_DIR/wallust/.config/wallust/"
cp ~/.config/hypr/hypridle.conf "$DOTFILES_DIR/hypridle/.config/hypr/"
cp ~/.zshrc "$DOTFILES_DIR/zsh/"
cp ~/.zprofile "$DOTFILES_DIR/zsh/" 2>/dev/null || true
cp ~/.local/bin/change-wallpaper "$DOTFILES_DIR/scripts/.local/bin/"

# Update package lists
pacman -Qe > "$DOTFILES_DIR/pkglist.txt"
pacman -Qm > "$DOTFILES_DIR/aurlist.txt"
pacman -Qn > "$DOTFILES_DIR/nativelist.txt"

echo "Dotfiles updated!"
echo "Run 'git add . && git commit && git push' to push changes"
