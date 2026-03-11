#!/bin/bash

set -e  # Exit on error

DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[→]${NC} $1"
}

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    print_error "This script is designed for Arch Linux only!"
    exit 1
fi

print_info "Starting Hyprland dotfiles installation..."

# ==================== 1. INSTALL YAY (AUR HELPER) ====================
if ! command -v yay &> /dev/null; then
    print_info "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    print_success "yay installed"
else
    print_success "yay already installed"
fi

# ==================== 2. INSTALL CORE PACKAGES ====================
print_info "Installing core packages from official repos..."

CORE_PACKAGES=(
    # Hyprland and Wayland
    hyprland
    hyprpaper
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland
    
    # Status bar and notifications
    waybar
    dunst
    
    # Application launcher
    rofi-wayland
    
    # Terminal
    kitty
    
    # Lock screen and idle
    hyprlock
    hypridle
    
    # Wallpaper daemon
    swww
    
    # Clipboard
    wl-clipboard
    cliphist
    wl-clip-persist
    
    # File managers
    thunar
    thunar-volman
    thunar-archive-plugin
    gvfs
    yazi
    
    # Audio
    pipewire
    wireplumber
    pavucontrol
    
    # Bluetooth
    bluez
    bluez-utils
    blueman
    
    # Network
    networkmanager
    network-manager-applet
    
    # Fonts
    ttf-jetbrains-mono-nerd
    ttf-cascadia-code
    ttf-font-awesome
    noto-fonts
    noto-fonts-emoji
    
    # GTK themes
    arc-gtk-theme
    papirus-icon-theme
    nwg-look
    
    # Image tools
    imagemagick
    
    # System tools
    btop
    htop
    fastfetch
    neovim
    
    # Utilities
    fd
    ripgrep
    fzf
    jq
    
    # Shell
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
)

sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"
print_success "Core packages installed"

# ==================== 3. INSTALL AUR PACKAGES ====================
print_info "Installing AUR packages..."

AUR_PACKAGES=(
    wallust
    sddm-git
    tokyo-night-sddm-git
    oh-my-zsh-git
)

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
print_success "AUR packages installed"

# ==================== 4. INSTALL OH-MY-ZSH ====================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-My-Zsh installed"
else
    print_success "Oh-My-Zsh already installed"
fi

# ==================== 5. INSTALL ZSH PLUGINS ====================
print_info "Installing zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

print_success "Zsh plugins installed"

# ==================== 6. SETUP DOTFILES WITH STOW ====================
print_info "Setting up dotfiles with GNU Stow..."

# Install stow if not present
sudo pacman -S --needed --noconfirm stow

cd "$SCRIPT_DIR"

# Backup existing configs
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for dir in hyprland waybar rofi kitty dunst wallust scripts zsh nvim; do
    if [ -d "$HOME/.config/$dir" ]; then
        print_info "Backing up existing $dir config..."
        mv "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# Stow all configurations in my casde hyprland folder is called hypr
print_info "Stowing configurations..."
STOW_DIRS=(hypr waybar rofi kitty dunst wallust scripts hypridle hyprlock zsh nvim)

for dir in "${STOW_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        stow -t "$HOME" "$dir"
        print_success "Stowed $dir"
    fi
done

# ==================== 7. CREATE NECESSARY DIRECTORIES ====================
print_info "Creating necessary directories..."

mkdir -p "$HOME/wallpapers"
mkdir -p "$HOME/.cache/rofi-wallpapers"
mkdir -p "$HOME/.cache"
mkdir -p "$HOME/.local/bin"

print_success "Directories created"

# ==================== 8. DOWNLOAD SAMPLE WALLPAPER ====================
if [ ! "$(ls -A $HOME/wallpapers)" ]; then
    print_info "Downloading sample wallpaper..."
    curl -L "https://w.wallhaven.cc/full/pk/wallhaven-pkz33l.jpg" -o "$HOME/wallpapers/default.jpg"
    print_success "Sample wallpaper downloaded"
fi

# ==================== 9. SETUP SDDM ====================
print_info "Configuring SDDM..."

sudo systemctl enable sddm

# Copy SDDM config
sudo cp "$SCRIPT_DIR/sddm.conf" /etc/sddm.conf 2>/dev/null || print_info "No sddm.conf to copy"

print_success "SDDM enabled"

# ==================== 10. CHANGE SHELL TO ZSH ====================
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    print_success "Shell changed to zsh (logout required)"
else
    print_success "Shell already set to zsh"
fi

# ==================== 11. ENABLE SERVICES ====================
print_info "Enabling services..."

sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

print_success "Services enabled"

# ==================== 12. FONT CACHE ====================
print_info "Refreshing font cache..."
fc-cache -fv > /dev/null 2>&1
print_success "Font cache refreshed"

# ==================== 13. GENERATE WALLUST COLORS ====================
if [ -f "$HOME/wallpapers/default.jpg" ]; then
    print_info "Generating initial color scheme..."
    wallust run "$HOME/wallpapers/default.jpg" 2>/dev/null || true
    print_success "Color scheme generated"
fi

# ==================== INSTALLATION COMPLETE ====================
echo ""
print_success "=========================================="
print_success "  Installation Complete!"
print_success "=========================================="
echo ""
print_info "Next steps:"
echo "  1. Logout and log back in (or reboot)"
echo "  2. Select Hyprland from the login screen"
echo "  3. Use SUPER+W to change wallpaper"
echo "  4. Use SUPER+D for app launcher"
echo ""
print_info "Your old configs backed up to: $BACKUP_DIR"
echo ""
print_info "Keybindings:"
echo "  SUPER + W       - Wallpaper selector"
echo "  SUPER + D       - App launcher"
echo "  SUPER + Return  - Terminal"
echo "  SUPER + L       - Lock screen"
echo "  SUPER + Q       - Close window"
echo ""
