#!/bin/bash

# Omarchy Enhanced Bindings Installer
# Created by: nemui
# Description: Installs enhanced Hyprland bindings for Omarchy with better workspace management,
#              numpad support, and improved window manipulation.
# 
# This script replaces the default Omarchy bindings with enhanced versions that provide:
# - Numpad support for workspace switching and window moving
# - Better relative workspace navigation
# - Advanced window movement for both tiled and floating windows  
# - VSCode Cline extension support
# - Temperature controls and additional app bindings

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Omarchy is installed
check_omarchy() {
    if [ ! -d "$HOME/.local/share/omarchy" ]; then
        print_error "Omarchy installation not found at ~/.local/share/omarchy"
        print_error "Please install Omarchy first: https://omarchy.com"
        exit 1
    fi
    
    # Check for at least one of the default config directories to confirm Omarchy is set up
    if [ ! -d "$HOME/.local/share/omarchy/default/hypr" ] && [ ! -d "$HOME/.local/share/omarchy/config" ]; then
        print_error "Omarchy configuration not found"
        print_error "Please ensure Omarchy is properly installed and configured"
        exit 1
    fi
    
    print_success "Omarchy installation detected"
}

# Function to backup existing bindings
backup_bindings() {
    local backup_dir="$HOME/.config/hypr/omarchy-enhanced-bindings.backup.$(date +%Y%m%d_%H%M%S)"
    
    print_status "Creating backup of existing configuration..."
    mkdir -p "$backup_dir"
    
    # Backup existing ~/.config/hypr/bindings/ directory if it exists
    if [ -d "$HOME/.config/hypr/bindings" ]; then
        cp -r "$HOME/.config/hypr/bindings" "$backup_dir/"
        print_success "Backed up existing ~/.config/hypr/bindings/"
    fi
    
    # Backup existing ~/.config/hypr/bindings.conf if it exists
    if [ -f "$HOME/.config/hypr/bindings.conf" ]; then
        cp "$HOME/.config/hypr/bindings.conf" "$backup_dir/"
        print_success "Backed up existing ~/.config/hypr/bindings.conf"
    fi
    
    # Backup existing ~/.config/hypr/hyprland.conf if it exists
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        cp "$HOME/.config/hypr/hyprland.conf" "$backup_dir/"
        print_success "Backed up existing ~/.config/hypr/hyprland.conf"
    fi
    
    # Backup omarchy-toggle-nightlight script for potential restoration
    if [ -f "$HOME/.local/share/omarchy/bin/omarchy-toggle-nightlight" ]; then
        cp "$HOME/.local/share/omarchy/bin/omarchy-toggle-nightlight" "$backup_dir/omarchy-toggle-nightlight.original"
        print_success "Backed up original omarchy-toggle-nightlight"
    fi
    
    print_success "Backup created at: $backup_dir"
}

# Function to perform a smart merge of binding files
perform_merge() {
    local source_file="$1"
    local target_file="$2"

    print_status "Merging bindings into $target_file..."

    # Process variables first, prepending them if they don't exist.
    grep '^ *\$' "$source_file" | while IFS= read -r line; do
        var_name=$(echo "$line" | cut -d'=' -f1 | sed 's/ //g')
        if ! grep -q "^${var_name}" "$target_file"; then
            # Prepend the variable definition
            echo -e "${line}\n$(cat "$target_file")" > "$target_file"
            print_status "Added variable: ${var_name}"
        else
            # Update existing variable
            sed -i "s|^${var_name}.*|${line}|" "$target_file"
            print_status "Updated variable: ${var_name}"
        fi
    done

    # Process bindings: remove old versions from a copy and append all new ones.
    local temp_target=$(mktemp)
    cp "$target_file" "$temp_target"

    grep '^ *bind' "$source_file" | while IFS= read -r line; do
        # Extract the key combination (e.g., "SUPER, return")
        key_combo=$(echo "$line" | awk -F, '{gsub(/bind[a-z]* *= */, "", $1); print $1 "," $2}' | xargs)
        
        # Escape for sed
        sed_key_combo=$(echo "$key_combo" | sed 's/[]\/$*.^|[]/\\&/g')

        # Remove any existing line with this key combo from the temp file
        sed -i "/bind[a-z]* *= *${sed_key_combo}/d" "$temp_target"
    done

    # Now, append all the new bindings to the cleaned file
    echo "" >> "$temp_target"
    echo "# --- Merged from Omarchy Enhanced Bindings ---" >> "$temp_target"
    cat "$source_file" | grep '^ *bind' >> "$temp_target"

    # Overwrite the original file
    mv "$temp_target" "$target_file"
    print_success "Merge complete."
}

# Function to install enhanced bindings
install_bindings() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    local hypr_config_dir="$HOME/.config/hypr"
    local github_base_url="https://raw.githubusercontent.com/nemuiyarou/omarchy-enhanced-bindings/main/bindings"
    
    local source_tiling_file
    local source_bindings_file

    print_status "Installing enhanced bindings..."

    # Detect if we are in a local git clone or running from curl
    if [ -d "$script_dir/bindings" ]; then
        print_status "Local installation detected (running from git clone)"
        source_tiling_file="$script_dir/bindings/tiling.conf"
        source_bindings_file="$script_dir/bindings/bindings.conf"
    else
        print_status "Remote installation detected (running from curl)"
        # Create temporary files to download the bindings
        source_tiling_file=$(mktemp)
        source_bindings_file=$(mktemp)
        
        print_status "Downloading latest bindings from GitHub..."
        if ! curl -fsSL "$github_base_url/tiling.conf" -o "$source_tiling_file" || \
           ! curl -fsSL "$github_base_url/bindings.conf" -o "$source_bindings_file"; then
            print_error "Failed to download binding files from GitHub. Aborting."
            rm -f "$source_tiling_file" "$source_bindings_file"
            exit 1
        fi
        print_success "Downloads complete."
    fi
    
    # Install enhanced tiling.conf directly (always overwrite)
    cp "$source_tiling_file" "$hypr_config_dir/tiling.conf"
    print_success "Installed enhanced tiling.conf to ~/.config/hypr/tiling.conf"

    # Handle the main bindings.conf with Overwrite/Merge logic
    local target_bindings_file="$hypr_config_dir/bindings.conf"
    if [ -f "$target_bindings_file" ]; then
        echo ""
        print_warning "Existing ~/.config/hypr/bindings.conf found."
        echo -e "${YELLOW}You can either (O)verwrite it completely or (M)erge the new bindings into it.${NC}"
        echo "  - (O)verwrite: Recommended for a clean, default setup."
        echo "  - (M)erge: Preserves your custom bindings and updates/adds the enhanced ones."
        read -p "Choose installation mode [O/m]: " -n 1 -r mode
        echo ""
        
        if [[ $mode =~ ^[Mm]$ ]]; then
            perform_merge "$source_bindings_file" "$target_bindings_file"
        else
            cp "$source_bindings_file" "$target_bindings_file"
            print_success "Overwrote ~/.config/hypr/bindings.conf"
        fi
    else
        cp "$source_bindings_file" "$target_bindings_file"
        print_success "Installed new ~/.config/hypr/bindings.conf"
    fi

    # Cleanup temporary files if they were created
    if [ -n "$source_tiling_file" ] && [[ "$source_tiling_file" == /tmp/* ]]; then
        rm -f "$source_tiling_file" "$source_bindings_file"
    fi

    # Ask about web apps (this will append to the new or merged file)
    install_webapps
    
    # Update hyprland.conf to use enhanced bindings
    update_hyprland_config
}

# Function to ask about web apps installation
install_webapps() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    local hypr_config_dir="$HOME/.config/hypr"
    
    echo ""
    echo -e "${YELLOW}Optional: DHH's Original Web App Shortcuts${NC}"
    echo -e "${YELLOW}The original Omarchy includes web app shortcuts (ChatGPT, Email, YouTube, etc.)${NC}"
    echo -e "${YELLOW}This package focuses on desktop apps, but you can include the web apps too.${NC}"
    echo ""
    echo "Web app shortcuts would add:"
    echo "  • SUPER + A: ChatGPT, SUPER + SHIFT + A: Grok"
    echo "  • SUPER + C: Calendar, SUPER + E: Email"
    echo "  • SUPER + Y: YouTube, SUPER + X: X/Twitter"
    echo "  • SUPER + SHIFT + G: WhatsApp, SUPER + ALT + G: Google Messages"
    echo ""
    read -p "Include DHH's web app shortcuts? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$script_dir/bindings/webapps.conf" ]; then
            # Local installation (git clone)
            echo "" >> "$hypr_config_dir/bindings.conf"
            cat "$script_dir/bindings/webapps.conf" >> "$hypr_config_dir/bindings.conf"
            print_success "Added DHH's original web app shortcuts"
        else
            # Remote installation (curl) - download from GitHub
            local github_base_url="https://raw.githubusercontent.com/nemuiyarou/omarchy-enhanced-bindings/main/bindings"
            if command -v curl >/dev/null 2>&1; then
                if curl -fsSL "$github_base_url/webapps.conf" >> "$hypr_config_dir/bindings.conf"; then
                    echo "" >> "$hypr_config_dir/bindings.conf"
                    print_success "Downloaded and added DHH's original web app shortcuts"
                else
                    print_warning "Failed to download webapps.conf from GitHub"
                fi
            else
                print_warning "curl not found and local webapps.conf not available"
            fi
        fi
    else
        print_status "Skipping web app shortcuts (desktop-focused setup)"
    fi
}

# Function to update nightlight temperature (optional enhancement)
update_nightlight_temperature() {
    local omarchy_bin_file="$HOME/.local/share/omarchy/bin/omarchy-toggle-nightlight"
    
    if [ ! -f "$omarchy_bin_file" ]; then
        print_warning "omarchy-toggle-nightlight not found, skipping temperature modification"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Optional: Enhanced Nightlight Temperature${NC}"
    echo -e "${YELLOW}The default Omarchy nightlight uses 4000K (slightly warm).${NC}"
    echo -e "${YELLOW}Would you like to use 3000K instead for a richer, deeper orange tone?${NC}"
    echo ""
    read -p "Modify nightlight to use 3000K? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup the original file
        cp "$omarchy_bin_file" "$omarchy_bin_file.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Update the temperature value
        sed -i 's/ON_TEMP=4000/ON_TEMP=3000/g' "$omarchy_bin_file"
        
        print_success "Updated nightlight temperature to 3000K (richer orange)"
        print_status "Original omarchy-toggle-nightlight backed up with timestamp"
    else
        print_status "Keeping default 4000K nightlight temperature"
    fi
}

# Function to update hyprland.conf to use enhanced bindings
update_hyprland_config() {
    local hypr_config_file="$HOME/.config/hypr/hyprland.conf"
    
    # Create a basic hyprland.conf if it doesn't exist
    if [ ! -f "$hypr_config_file" ]; then
        print_status "Creating ~/.config/hypr/hyprland.conf..."
        cat > "$hypr_config_file" << 'EOF'
# Personal Hyprland Configuration
# This file overrides and extends the default Omarchy configuration

# Source Omarchy defaults (media and utilities use defaults, tiling uses enhanced version)
source = ~/.local/share/omarchy/default/hypr/autostart.conf
source = ~/.local/share/omarchy/default/hypr/bindings/media.conf
source = ~/.local/share/omarchy/default/hypr/bindings/utilities.conf
source = ~/.local/share/omarchy/default/hypr/envs.conf
source = ~/.local/share/omarchy/default/hypr/looknfeel.conf
source = ~/.local/share/omarchy/default/hypr/input.conf
source = ~/.local/share/omarchy/default/hypr/windows.conf
source = ~/.config/omarchy/current/theme/hyprland.conf

# Use enhanced tiling bindings instead of default
source = ~/.config/hypr/tiling.conf

# Additional personal configurations
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/bindings.conf
source = ~/.config/hypr/envs.conf
source = ~/.config/hypr/autostart.conf
EOF
        print_success "Created ~/.config/hypr/hyprland.conf with enhanced tiling bindings"
        return
    fi
    
    # If hyprland.conf exists, check if it needs updating
    if grep -q "~/.local/share/omarchy/default/hypr/bindings/tiling.conf" "$hypr_config_file"; then
        print_status "Updating existing ~/.config/hypr/hyprland.conf to use enhanced tiling bindings..."
        
        # Create backup of existing config
        cp "$hypr_config_file" "$hypr_config_file.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Replace only tiling.conf with enhanced version (keep media and utilities as defaults)
        # This regex handles spaces and commented-out lines to make the replacement more robust.
        sed -i -E 's|^[[:space:]]*#?[[:space:]]*source[[:space:]]*=[[:space:]]*~/\.local/share/omarchy/default/hypr/bindings/tiling\.conf|source = ~/.config/hypr/tiling.conf|' "$hypr_config_file"
        
        print_success "Updated ~/.config/hypr/hyprland.conf to use enhanced tiling bindings"
    elif ! grep -q "source = ~/.config/hypr/tiling.conf" "$hypr_config_file"; then
        print_status "Adding enhanced tiling bindings to existing ~/.config/hypr/hyprland.conf..."
        
        # Create backup of existing config
        cp "$hypr_config_file" "$hypr_config_file.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Add the enhanced tiling line
        echo "" >> "$hypr_config_file"
        echo "# Enhanced tiling bindings (added by omarchy-enhanced-bindings)" >> "$hypr_config_file"
        echo "source = ~/.config/hypr/tiling.conf" >> "$hypr_config_file"
        
        print_success "Added enhanced tiling bindings to ~/.config/hypr/hyprland.conf"
    else
        print_status "hyprland.conf already appears to be using enhanced tiling bindings"
    fi
}

# Function to reload Hyprland configuration
reload_hyprland() {
    print_status "Reloading Hyprland configuration..."
    
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 && print_success "Hyprland configuration reloaded" || print_warning "Failed to reload Hyprland configuration"
    else
        print_warning "hyprctl not found. Please restart Hyprland to apply changes."
    fi
}

# Function to show what's new
show_enhancements() {
    print_status "Enhanced bindings installed! Here's what's new:"
    echo ""
    echo -e "${GREEN}🎯 Workspace Management:${NC}"
    echo "  • Numpad support for switching workspaces: SUPER + Numpad 1-0"
    echo "  • Numpad support for moving windows: SUPER + CTRL + Numpad 1-0"
    echo "  • Relative workspace navigation: SUPER + CTRL + Left/Right"
    echo "  • Jump to empty workspace: SUPER + CTRL + Down"
    echo ""
    echo -e "${GREEN}🪟 Window Management:${NC}"
    echo "  • Advanced window movement (works with floating): SUPER + SHIFT + CTRL + Arrows"
    echo "  • Move windows to relative workspaces: SUPER + CTRL + ALT + Left/Right"
    echo ""
    echo -e "${GREEN}🚀 Application Shortcuts:${NC}"
    echo "  • Quick app launches: SUPER + Return (terminal), SUPER + B (browser), etc."
    echo "  • VSCode with proper Cline support: SUPER + V"
    echo "  • Gemini AI, Obsidian, Steam, and more app shortcuts"
    if grep -q "ChatGPT" "$HOME/.config/hypr/bindings.conf" 2>/dev/null; then
        echo "  • DHH's web app shortcuts: ChatGPT, Email, YouTube, etc."
    fi
    echo ""
    echo -e "${GREEN}📱 Additional Features:${NC}"
    echo "  • Enhanced screenshot and screen recording controls"
    echo "  • Better media controls with OSD"
    echo "  • Notification management improvements"
    echo "  • Optional richer nightlight (3000K) - uses existing SUPER+CTRL+N binding"
    echo ""
    print_success "Installation complete! Restart Hyprland or log out/in to ensure all changes take effect."
}

# Main installation process
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Omarchy Enhanced Bindings         ║${NC}"
    echo -e "${BLUE}║        Installation Script            ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if running with appropriate permissions
    if [[ $EUID -eq 0 ]]; then
        print_error "Don't run this script as root!"
        exit 1
    fi
    
    # Check for Omarchy installation
    check_omarchy
    
    # Ask for confirmation
    echo -e "${YELLOW}This will replace your current Omarchy bindings with enhanced versions.${NC}"
    echo -e "${YELLOW}A backup will be created automatically.${NC}"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled."
        exit 0
    fi
    
    # Perform installation
    backup_bindings
    install_bindings
    update_nightlight_temperature
    reload_hyprland
    show_enhancements
}

# Check if script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
