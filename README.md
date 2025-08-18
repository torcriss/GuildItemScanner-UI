# GuildItemScanner-UI

A graphical user interface addon for configuring [GuildItemScanner](https://github.com/torcriss/GuildItemScanner) in World of Warcraft Classic Era.

## 🎯 Features

- 🎨 **Clean, Intuitive Interface** - Easy-to-use tabbed configuration window
- 🗺️ **Minimap Button** - Quick access with left-click to open, right-click for menu
- 📋 **Organized Panels** - Separate tabs for different setting categories
- 💾 **Profile Management** - Save and load different configurations
- 🔄 **Live Updates** - Changes apply immediately to GuildItemScanner
- 📜 **Safe Integration** - No risk of breaking GuildItemScanner functionality

## 📋 Panels Overview

### General Settings
- Enable/disable addon
- Debug mode toggle
- Sound and timing settings
- Equipment comparison options
- WTB filtering controls

### Alert Settings
- Recipe, Material, Bag, Potion, and Equipment alert toggles
- Material rarity and quantity filters
- Bag size filtering
- Equipment upgrade detection
- Alert customization

### Professions
- Add/remove professions for recipe and material detection
- View current profession list
- Clear all professions

### Social Features ⚠️
- Auto-GZ and Auto-RIP toggles
- **Requires Frontier addon**
- Custom message management (coming soon)

### Profile Management
- Auto-save enabled by default
- Save current settings as named profiles
- Load and manage different configurations

### Alert History
- View recent alerts (coming soon)
- Search and filter functionality (coming soon)

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
- **Right-click** minimap button for quick toggles

### Navigation
- **Click tabs** on the left to switch between panels
- **Hover** over controls for helpful tooltips
- **Changes save automatically** - no need to click "Apply"

### Minimap Button
- **Left-click**: Open main configuration window
- **Right-click**: Quick menu with common toggles
- **Drag**: Reposition the button around the minimap
- **Hide**: Use the quick menu option (use `/gisui` to reopen)

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
- Check the General settings panel for button visibility options

## 🔮 Coming Soon

- **Enhanced Social Panel** - Custom GZ/RIP messages and chance settings
- **Full Profile System** - Load, delete, import/export profiles
- **Custom Materials Manager** - Add items not in default database
- **Alert History Viewer** - Search and filter recent alerts
- **Keybind Support** - Hotkeys for quick access
- **Theme Options** - Customize appearance

## 🤝 Support

- **Issues**: Report bugs at [GitHub Issues](https://github.com/torcriss/GuildItemScanner-UI/issues)
- **Main Addon**: [GuildItemScanner Repository](https://github.com/torcriss/GuildItemScanner)
- **Discord**: Join the community for help and updates

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Note**: This is a companion addon for GuildItemScanner. It provides a graphical interface for configuration but does not replace any core functionality. GuildItemScanner continues to work normally with or without this UI addon.