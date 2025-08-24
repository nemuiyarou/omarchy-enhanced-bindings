# Omarchy Enhanced Bindings

Enhanced Hyprland keybindings for [Omarchy](https://omarchy.com) that provide better workspace management for desktop users, numpad support, and smoother keybinds for serial workspace switchers.

## 🚀 What's Enhanced

### For Desktop & Numpad Users
- **Full Numpad Support**: Use numpad 1-0 for workspace switching and window moving
- **Desktop-Optimized**: Better keybinds for users with full keyboards (not just laptops)
- **Serial Workspace Switching**: Smooth relative navigation for power users

### Workspace Management
- **Relative Navigation**: Navigate to next/previous/empty workspaces with intuitive shortcuts
- **Consistent Keybindings**: Logical key combinations that work together
- **Smart Window Movement**: Move windows between workspaces relative to current position

### Application & Development
- **VSCode Cline Support**: Proper key bindings for the Cline extension with X11 support
- **Quick App Launchers**: Streamlined app shortcuts (removed web apps, added gaming/development)
- **Browser Configuration**: Changed from Chromium to Brave with optimized settings
- **Optional Enhanced Nightlight**: Richer 3000K orange tone (uses existing binding)

## 📦 Installation

### One-Line Install
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nemuiyarou/omarchy-enhanced-bindings/main/install.sh)
```

> **⚠️ Security Note**: Always inspect scripts before running them with `bash <(curl ...)`. You can review the install script [here](https://raw.githubusercontent.com/nemuiyarou/omarchy-enhanced-bindings/main/install.sh) or download it first to examine locally. If you're not comfortable reviewing bash scripts, ask for help on the [Omarchy Discord](https://discord.com/invite/tXFUdasqhY) or visit [omarchy.org](https://omarchy.org/) for further information.

### Manual Install
1. Clone this repository:
   ```bash
   git clone https://github.com/nemuiyarou/omarchy-enhanced-bindings.git
   cd omarchy-enhanced-bindings
   ```

2. Make the installer executable (this step is not required for the one-line install):
   ```bash
   chmod +x install.sh
   ```

3. Run the installer:
   ```bash
   ./install.sh
   ```

The installer will:
- ✅ Check for Omarchy installation
- ✅ Create automatic backups of your current configuration
- ✅ **Offer Overwrite or Merge** for existing `bindings.conf`
- ✅ Install enhanced tiling bindings with numpad support
- ✅ Install additional app shortcuts (VSCode Cline, Neovim, etc.)
- ✅ **Ask about web app shortcuts** (ChatGPT, Email, YouTube, etc.)
- ✅ Offer optional enhanced nightlight (3000K richer orange)
- ✅ Update your `~/.config/hypr/hyprland.conf` appropriately
- ✅ Preserve all original Omarchy defaults (respecting DHH's design)
- ✅ Reload Hyprland configuration

## 🎯 Key Bindings Overview

### Workspace Switching
| Shortcut | Action | Notes |
|----------|--------|-------|
| `SUPER + 1-0` | Switch to workspace 1-10 | Standard number row |
| `SUPER + Numpad 1-0` | Switch to workspace 1-10 | **NEW**: Numpad support |
| `SUPER + CTRL + Right` | Next workspace | **NEW**: Relative navigation |
| `SUPER + CTRL + Left` | Previous workspace | **NEW**: Relative navigation |
| `SUPER + CTRL + Down` | Empty workspace | **NEW**: Jump to empty |

### Window Management
| Shortcut | Action | Notes |
|---|---|---|
| `SUPER + Q` | Close active window | **ENHANCED**: Changed from `Super+W` |
| `SUPER + W` | Toggle floating | **ENHANCED**: Replaces default `Super+V` |
| `SUPER + ALT + Arrows` | Resize active window | **ENHANCED**: More intuitive directional resizing |
| `SUPER + CTRL + 1-0` | Move window to workspace | **ENHANCED**: Modifier changed from `SHIFT` to `CTRL` |
| `SUPER + CTRL + Numpad 1-0` | Move window to workspace | **NEW**: Numpad support |
| `SUPER + CTRL ALT, Right/Left` | Move window to next/prev workspace | **NEW**: Relative movement |

### Applications
| Shortcut | Action | Notes |
|----------|--------|-------|
| `SUPER + Return` | Terminal | Quick terminal access |
| `SUPER + B` | Browser | Launch default browser |
| `SUPER + V` | VSCode | **NEW**: With Cline support |
| `SUPER + M` | Music (Spotify) | Media player |
| `SUPER + G` | Gemini AI | **NEW**: AI assistant |
| `SUPER + F` | File Manager | Nautilus file browser |
| `SUPER + S` | Steam | **NEW**: Gaming |
| `SUPER + T` | Activity Monitor | System monitor (btop) |

### System Controls
| Shortcut | Action | Notes |
|----------|--------|-------|
| `SUPER + CTRL + N` | Toggle nightlight | **ENHANCED**: Optional 3000K richer orange |
| `SUPER + SPACE` | App launcher | Walker launcher |
| `SUPER + ESCAPE` | Power menu | System power options |

## 🔧 Customization

The enhanced bindings are organized in your personal Hyprland config:

- **`~/.config/hypr/tiling.conf`**: This is the core file for window and workspace management. It includes all tiling, floating, focus, and workspace switching commands, now with numpad support and the `Super+Q`/`Super+W` changes.
- **`~/.config/hypr/bindings.conf`**: This file contains all your application-specific shortcuts, like launching the terminal, browser, VSCode, etc.
- **`webapps.conf`** (Optional): If you choose to install them, the contents of this file are appended to your main `bindings.conf`. It contains DHH's original web application shortcuts (ChatGPT, YouTube, etc.).

This approach respects DHH's Omarchy architecture by:
- 🎯 Keeping original Omarchy defaults untouched (media, utilities, etc.)
- 🎯 Using the intended `~/.config/hypr/` override system
- 🎯 Making upgrades and customizations safe and clean
- 🎯 Only overriding what's actually enhanced

You can customize these files, and they won't be overwritten by Omarchy updates. The nightlight enhancement (if chosen) modifies the existing `omarchy-toggle-nightlight` script for a richer orange tone.

## 🔄 Backup & Restore

The installer automatically creates timestamped backups in:
```
~/.config/hypr/omarchy-enhanced-bindings.backup.YYYYMMDD_HHMMSS/
```

To restore original configuration:
```bash
# Find your backup
ls ~/.config/hypr/omarchy-enhanced-bindings.backup.*

# Use the uninstall script (recommended)
./uninstall.sh

# Or restore manually (replace TIMESTAMP with your backup timestamp)
cp -r ~/.config/hypr/omarchy-enhanced-bindings.backup.TIMESTAMP/* ~/.config/hypr/

# Reload Hyprland
hyprctl reload
```

### Overwrite vs. Merge Installation
If you have an existing `~/.config/hypr/bindings.conf`, the installer will prompt you to choose between two modes:

- **Overwrite (Default)**: This replaces your `bindings.conf` entirely. It's the recommended option for a clean installation that perfectly matches the features advertised here.
- **Merge**: This intelligently combines the enhanced bindings with your existing ones. It will update any bindings that are part of this package and add any that are missing, while leaving your other custom bindings untouched.

> **⚠️ A Note on Merging**: The merge process is designed to be safe, but it will overwrite any of your custom bindings that use the **same key combination** as one of the enhanced bindings. For example, if you have `SUPER + V` mapped to your own custom script, the merge process will replace it with the enhanced binding for VSCode. Your other custom bindings will be preserved.

> **⚠️ A Note on Uninstalling After a Merge**: The uninstaller works by restoring the backup created during installation. If you choose to merge and then make *additional* changes to your `bindings.conf`, running the uninstaller will revert **all** changes made since the backup was created, including your own. For a clean uninstall, it's always safest to work from the backup.

## 🧪 Testing & Validation

The package includes a comprehensive test script to validate installation integrity:

```bash
# Run all validation tests
./test.sh
```

The test script validates:
- ✅ **Package Structure**: All required files are present
- ✅ **File Permissions**: Scripts are executable
- ✅ **Binding Syntax**: Configuration files are valid
- ✅ **Key Conflicts**: No problematic duplicate bindings
- ✅ **Enhanced Features**: All advertised features are present
- ✅ **Installation Logic**: Install script functions work correctly
- ✅ **Documentation**: README matches actual features

**When to run tests:**
- Before installation (verify package integrity)
- After making custom modifications
- When troubleshooting issues
- Before contributing changes

## 🐛 Troubleshooting

### Bindings Not Working
1. Ensure Hyprland is reloaded: `hyprctl reload`
2. Check for conflicts: `hyprctl binds`
3. Restart Hyprland session

### VSCode Cline Issues
The enhanced bindings include specific support for the Cline extension with X11 mode:
```properties
# VSCode launched with X11 support for proper Cline integration
bindd = SUPER, V, VSCode, exec, env ELECTRON_OZONE_PLATFORM_HINT=x11 code --ozone-platform=x11

# Key passing for Cline extension (requires X11 mode)
bind = , Shift_L, pass, ^(code)$
bind = SHIFT, mouse:272, pass, ^(code)$
bind = SHIFT, mouse:273, pass, ^(code)$
```

**Why X11 mode?** VSCode's Wayland support has Electron bugs that prevent proper shift+drag functionality required by Cline. The X11 mode enables the passthrough that allows Cline to accept shift+drag operations correctly.

### Browser Configuration
The enhanced bindings use Brave instead of Chromium:
```properties
$browser = uwsm app -- brave --password-store=basic
```

**To change your browser:** Edit `~/.config/hypr/bindings.conf` and modify the `$browser` variable:
```properties
# For Firefox
$browser = uwsm app -- firefox --new-window

# For Chromium (original Omarchy default)  
$browser = uwsm app -- chromium --new-window --ozone-platform=wayland

# For other browsers
$browser = uwsm app -- your-browser-here
```

### Hyprland Configuration
The installer modifies your `~/.config/hypr/hyprland.conf` to ensure the new bindings are loaded. Specifically, it looks for the line that sources the default Omarchy tiling bindings and replaces it:

- **It finds**: `source = ~/.local/share/omarchy/default/hypr/bindings/tiling.conf` (even if commented out or with extra spaces).
- **It replaces it with**: `source = ~/.config/hypr/tiling.conf`

If the script fails to update your configuration, you can perform this change manually. This ensures that you load the enhanced tiling bindings while still inheriting all other Omarchy defaults like media and utility keybindings.

### Numpad Not Working
Ensure Num Lock is enabled. The bindings use these numpad key names:
- `KP_End` (1), `KP_Down` (2), `KP_Next` (3)
- `KP_Left` (4), `KP_Begin` (5), `KP_Right` (6) 
- `KP_Home` (7), `KP_Up` (8), `KP_Prior` (9), `KP_Insert` (0)

## 📝 What's Different from Default Omarchy

### Application Changes
| Binding | Original Omarchy | Enhanced Version |
|---------|------------------|------------------|
| `SUPER + G` | Signal | ✅ Gemini AI |
| `SUPER + V` | Not assigned | ✅ VSCode (X11 + Cline support) |
| `SUPER + S` | Not assigned | ✅ Steam |
| `SUPER + D` | Docker (lazydocker) | ❌ Removed |
| `SUPER + /` | 1Password | ❌ Removed |
| **Browser** | Chromium (Wayland) | ✅ Brave (password-store=basic) |
| **Web Apps** | 9 web app shortcuts | ❌ Removed (A, C, E, Y, X, etc.) |

### Workspace & System Features
| Feature | Default Omarchy | Enhanced Version |
|---------|----------------|------------------|
| Numpad support | ❌ | ✅ Full numpad workspace control |
| Relative workspace nav | ❌ | ✅ Next/prev/empty workspace shortcuts |
| VSCode Cline support | ❌ | ✅ Proper key passing for Cline extension |
| Nightlight temperature | 4000K | ✅ Optional 3000K richer orange |
| Relative window moving | ❌ | ✅ Move windows to next/prev workspace |

### Web Apps Removal
**Removed by default:** ChatGPT, Grok, Calendar, Email, YouTube, WhatsApp, Google Messages, X/Twitter

**Installation Choice:** The installer will ask if you want to include DHH's original web app shortcuts. This gives you the best of both worlds:
- **Desktop-focused** (default): Clean, streamlined app shortcuts
- **Hybrid approach**: Desktop apps + DHH's web apps if you choose

**Important:** If you later remove web apps via `SUPER + ALT + SPACE` (Omarchy menu), the keybindings will remain. To fully remove them, edit `~/.config/hypr/bindings.conf` and delete the web app entries, then run `hyprctl reload`.

## 🎯 Target Users

This package is perfect for:
- **Desktop users** with full keyboards and numpads
- **Serial workspace switchers** who frequently navigate between workspaces
- **Developers** using VSCode with the Cline extension
- **Power users** who want smoother, more logical (Sorry DHH) keybindings
- **Anyone** who finds the default laptop-optimized bindings limiting

## 🙏 Credits

- **Claude**: For writing such verbose and overly friendly documentation
- **Vaxry**: For the amazing Wayland compositor (May you find a wife soon)
- **Gemini**: For cleaning up Claude's mess

---

**Happy workspace switching! 🚀**
