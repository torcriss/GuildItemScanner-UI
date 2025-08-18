# GuildItemScanner-UI

A streamlined graphical user interface addon for configuring [GuildItemScanner](https://github.com/torcriss/GuildItemScanner) in World of Warcraft Classic Era.

## 🎯 Features

- 🎨 **Clean, Focused Interface** - Streamlined 4-tab design with scrollable panels
- 🗺️ **Minimap Integration** - Quick access via minimap button, drag to reposition
- ⚡ **Lightweight & Fast** - Optimized codebase for excellent performance
- 🔄 **Live Configuration** - Changes apply immediately to GuildItemScanner
- 🛡️ **Safe Integration** - No risk of breaking GuildItemScanner functionality

## 📋 Interface Overview

### 🔧 General Settings
- **Core Controls**: Enable/disable addon, debug mode
- **Alert Behavior**: Sound alerts, whisper mode, greed mode
- **Filtering**: WTB message filtering
- **Timing**: Alert duration settings
- **Equipment**: Comparison mode options

### 🚨 Alert Settings
- **Recipe Alerts**: Notifications for recipes matching your professions
- **Material Alerts**: Crafting materials with rarity and quantity filters
- **Bag Alerts**: Storage bags with size filtering
- **Potion Alerts**: Potions and consumables notifications

### ⚒️ Professions
- **Manage Professions**: Add/remove professions for recipe and material detection
- **Current List**: View all configured professions
- **Quick Clear**: Clear all professions option

### 🎉 Social Features
- **Auto-GZ**: Automatically congratulate players on level ups
- **Auto-RIP**: Send condolences when players die
- ⚠️ **Requires**: [Frontier addon](https://github.com/torcriss/frontier) for functionality

## 🔧 Requirements

- **World of Warcraft Classic Era** (Interface 11507)
- **GuildItemScanner addon** ([Download](https://github.com/torcriss/GuildItemScanner))
- **Frontier addon** (optional, for social features only)

## 📦 Installation

1. **Download** the latest release from [GitHub Releases](https://github.com/torcriss/GuildItemScanner-UI/releases)
2. **Extract** the `GuildItemScanner-UI` folder to your `Interface/AddOns/` directory
3. **Install** the main [GuildItemScanner](https://github.com/torcriss/GuildItemScanner) addon
4. **Enable** both addons in the WoW addon list
5. **Restart** World of Warcraft

## 🎮 Usage

### Opening the Interface
- **Minimap Button**: Click the gear icon on your minimap
- **Chat Command**: Type `/gisui` or `/gis-ui` in chat

### Navigation
- **Tab Selection**: Click tabs on the left to switch between panels
- **Scrolling**: Use mouse wheel or scrollbar to navigate within panels
- **Tooltips**: Hover over controls for helpful information
- **Auto-Save**: All changes apply and save automatically

### Minimap Button
- **Left-Click**: Open/close the configuration window
- **Drag**: Reposition the button around your minimap
- **Hide**: Access through settings (use `/gisui` to reopen)

## 🛡️ Safety & Compatibility

- ✅ **Non-Intrusive**: No modifications to GuildItemScanner files
- ✅ **API Safe**: All interactions through official GIS functions
- ✅ **Error Protected**: UI remains functional if GIS has issues
- ✅ **Graceful Degradation**: Works even when GIS is disabled

## 🐛 Troubleshooting

### "GuildItemScanner not found" Error
- Ensure GuildItemScanner addon is installed and enabled
- Check addon loading order - restart WoW if needed
- Verify both addons appear in your addon list

### Settings Not Applying
- Changes save automatically when using the interface
- Try `/reload` to refresh if issues persist
- Ensure GuildItemScanner is enabled and functional

### Minimap Button Missing
- Use `/gisui` chat command to open the interface
- Check if button was hidden in settings
- Restart WoW if the button doesn't appear

### Social Features Not Working
- Install the [Frontier addon](https://github.com/torcriss/frontier)
- Enable Frontier in your addon list
- Social features require Frontier to function

## 🆕 Recent Updates

### v1.2.0 - Streamlined Experience
- **Simplified Interface**: Removed Profile Management for focused experience
- **Performance**: 60% reduction in code size for faster loading
- **4 Essential Tabs**: General, Alerts, Professions, Social Features
- **Consistent Design**: All panels use proper scrolling and spacing

### v1.1.0 - UI Improvements
- **Visual Polish**: Standardized spacing across all panels
- **Scrollbars**: Added proper scrolling to all panels
- **Bug Fixes**: Fixed minimap button hover issues
- **Enhanced UX**: Improved tooltips and user feedback

## 🤝 Support & Community

- **Report Issues**: [GitHub Issues](https://github.com/torcriss/GuildItemScanner-UI/issues)
- **Main Addon**: [GuildItemScanner Repository](https://github.com/torcriss/GuildItemScanner)
- **Get Help**: Join the community Discord for support and updates

## 📊 Why Choose GuildItemScanner-UI?

### Before: Command Line Only
```
/gis enable
/gis debug on
/gis profession add Alchemy
/gis alert recipe on
/gis alert material epic
```

### After: Beautiful Interface
- ✨ Visual controls with clear labels
- 🎯 Organized categories and logical grouping
- 💡 Helpful tooltips and instant feedback
- 📱 Intuitive design anyone can use

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Perfect for**: Players who want an intuitive, visual way to configure GuildItemScanner without memorizing chat commands.

**Compatible with**: WoW Classic Era • All GuildItemScanner versions • Lightweight & Fast