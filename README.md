# GuildItemScanner-UI

A graphical user interface addon for configuring [GuildItemScanner](https://github.com/torcriss/GuildItemScanner) in World of Warcraft Classic Era.

## 🎯 Features

- 🎨 **Clean, Intuitive Interface** - Easy-to-use tabbed configuration window with scrollable panels
- 🗺️ **Minimap Button** - Quick access with left-click to open, drag to reposition
- 📋 **Organized Panels** - Four focused tabs for essential settings
- 🔄 **Live Updates** - Changes apply immediately to GuildItemScanner
- 📜 **Safe Integration** - No risk of breaking GuildItemScanner functionality

## 📋 Panels Overview

### General Settings
- Enable/disable addon
- Debug mode toggle
- Sound alerts and whisper mode
- Greed mode and WTB filtering
- Alert duration settings
- Equipment comparison options

### Alert Settings
- Recipe, Material, Bag, and Potion alert toggles
- Material rarity and quantity filters
- Bag size filtering
- Alert customization options

### Professions
- Add/remove professions for recipe and material detection
- View current profession list
- Clear all professions option

### Social Features ⚠️
- Auto-GZ (congratulations) on level ups
- Auto-RIP (condolences) on player deaths
- **Requires Frontier addon**

## 🔧 Requirements

- **World of Warcraft Classic Era** (Interface 11507)
- **GuildItemScanner addon** (required dependency)
- **Frontier addon** (for social features only)

## 📦 Installation

1. **Download** the latest release from GitHub
2. **Extract** the `GuildItemScanner-UI` folder to your `Interface/AddOns/` directory
3. **Ensure** GuildItemScanner is also installed and enabled
4. **Enable** both addons in the WoW addon list
5. **Restart** World of Warcraft

## 🎮 Usage

### Opening the Interface
- **Click** the minimap button (gear icon)
- **Type** `/gisui` or `/gis-ui` in chat

### Navigation
- **Click tabs** on the left to switch between panels
- **Scroll** within panels to access all settings
- **Hover** over controls for helpful tooltips
- **Changes save automatically** - no need to click "Apply"

### Minimap Button
- **Left-click**: Open main configuration window
- **Drag**: Reposition the button around the minimap
- **Hide**: Use the interface settings (use `/gisui` to reopen)

## 🛡️ Safety & Compatibility

- **No interference** with GuildItemScanner functionality
- **Graceful handling** if GuildItemScanner is disabled
- **Safe API usage** - all interactions through public GIS functions
- **Error protection** - UI remains functional even if GIS has issues

## 🐛 Troubleshooting

### "GuildItemScanner not found" Error
- Ensure GuildItemScanner addon is installed and enabled
- Check that both addons are loaded (type `/gis status` to test)
- Restart WoW if needed

### Settings Not Saving
- Changes save automatically when using the UI
- If issues persist, try `/reload` to refresh the interface

### Minimap Button Missing
- Use `/gisui` command to open the interface
- Check if the button was hidden through settings

## 🆕 Recent Updates (v1.1.0)

- **Improved spacing** and visual consistency across all panels
- **Added scrollbars** to all panels for better navigation
- **Fixed minimap button** hover issue (no longer goes black)
- **Removed unused features** (Custom Materials, Alert History, Profile Management)
- **Simplified minimap interaction** (removed right-click menu)
- **Enhanced Social Features** with proper tooltips and helper functions

## 🤝 Support

- **Issues**: Report bugs at [GitHub Issues](https://github.com/torcriss/GuildItemScanner-UI/issues)
- **Main Addon**: [GuildItemScanner Repository](https://github.com/torcriss/GuildItemScanner)
- **Discord**: Join the community for help and updates

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Note**: This is a companion addon for GuildItemScanner. It provides a graphical interface for configuration but does not replace any core functionality. GuildItemScanner continues to work normally with or without this UI addon.