#!/bin/bash

# Omarchy Enhanced Bindings Uninstaller
# Restores the most recent backup of your original Omarchy bindings

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

# Find the most recent backup
find_latest_backup() {
    local backup_pattern="$HOME/.config/hypr/omarchy-enhanced-bindings.backup.*"
    local latest_backup=$(ls -td $backup_pattern 2>/dev/null | head -n1)
    
    if [ -z "$latest_backup" ]; then
        print_error "No backup found. Cannot restore original configuration."
        print_error "You may need to manually restore your ~/.config/hypr/ files."
        exit 1
    fi
    
    echo "$latest_backup"
}

# Restore bindings from backup
restore_bindings() {
    local backup_dir="$1"
    local hypr_config_dir="$HOME/.config/hypr"
    local omarchy_bin_file="$HOME/.local/share/omarchy/bin/omarchy-toggle-nightlight"
    
    print_status "Restoring configuration from: $(basename "$backup_dir")"
    
    # Remove enhanced bindings directory
    if [ -d "$hypr_config_dir/bindings" ]; then
        rm -rf "$hypr_config_dir/bindings"
        print_success "Removed enhanced bindings directory"
    fi
    
    # Restore bindings directory if it was backed up
    if [ -d "$backup_dir/bindings" ]; then
        cp -r "$backup_dir/bindings" "$hypr_config_dir/"
        print_success "Restored original bindings directory"
    fi
    
    # Restore bindings.conf if it was backed up
    if [ -f "$backup_dir/bindings.conf" ]; then
        cp "$backup_dir/bindings.conf" "$hypr_config_dir/"
        print_success "Restored original bindings.conf"
    else
        # Remove enhanced bindings.conf if no backup exists
        if [ -f "$hypr_config_dir/bindings.conf" ]; then
            rm "$hypr_config_dir/bindings.conf"
            print_success "Removed enhanced bindings.conf"
        fi
    fi
    
    # Restore hyprland.conf if it was backed up
    if [ -f "$backup_dir/hyprland.conf" ]; then
        cp "$backup_dir/hyprland.conf" "$hypr_config_dir/"
        print_success "Restored original hyprland.conf"
    else
        # Revert hyprland.conf to use default Omarchy bindings
        if [ -f "$hypr_config_dir/hyprland.conf" ]; then
            print_status "Reverting hyprland.conf to use default Omarchy tiling bindings..."
            # This regex handles spaces to make the replacement more robust.
            sed -i -E 's|^[[:space:]]*source[[:space:]]*=[[:space:]]*~/\.config/hypr/tiling\.conf|source = ~/.local/share/omarchy/default/hypr/bindings/tiling.conf|' "$hypr_config_dir/hyprland.conf"
            print_success "Reverted hyprland.conf to use default tiling bindings"
        fi
    fi
    
    # Restore omarchy-toggle-nightlight if it was modified
    if [ -f "$backup_dir/omarchy-toggle-nightlight.original" ]; then
        local omarchy_bin_file="$HOME/.local/share/omarchy/bin/omarchy-toggle-nightlight"
        echo ""
        echo -e "${YELLOW}Found modified nightlight script. Would you like to restore the original?${NC}"
        read -p "Restore original omarchy-toggle-nightlight? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$backup_dir/omarchy-toggle-nightlight.original" "$omarchy_bin_file"
            print_success "Restored original omarchy-toggle-nightlight (4000K)"
        else
            print_status "Keeping modified omarchy-toggle-nightlight (3000K)"
        fi
    fi
}

# Reload Hyprland configuration
reload_hyprland() {
    print_status "Reloading Hyprland configuration..."
    
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 && print_success "Hyprland configuration reloaded" || print_warning "Failed to reload Hyprland configuration"
    else
        print_warning "hyprctl not found. Please restart Hyprland to apply changes."
    fi
}

# Main uninstall process
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Omarchy Enhanced Bindings Uninstall ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    # Find latest backup
    local backup_dir=$(find_latest_backup)
    
    echo -e "${YELLOW}This will restore your original Omarchy bindings from:${NC}"
    echo -e "${YELLOW}$(basename "$backup_dir")${NC}"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstall cancelled."
        exit 0
    fi
    
    # Perform uninstallation
    restore_bindings "$backup_dir"
    reload_hyprland
    
    print_success "Original Omarchy bindings restored successfully!"
    print_status "The enhanced bindings have been removed."
    
    echo ""
    print_status "Your backup is still available at: $backup_dir"
}

# Check if script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
