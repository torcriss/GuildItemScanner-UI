# GuildItemScanner-UI

A comprehensive graphical user interface addon for configuring [GuildItemScanner](https://github.com/torcriss/GuildItemScanner) in World of Warcraft Classic Era.

## 🎯 Features

- 🎨 **Complete Interface** - 9-panel design covering all GuildItemScanner functionality
- 🗺️ **Minimap Integration** - Quick access via minimap button, drag to reposition  
- ⚡ **Lightweight & Fast** - Optimized codebase for excellent performance
- 🔄 **Live Configuration** - Changes apply immediately to GuildItemScanner
- 🛡️ **Safe Integration** - No risk of breaking GuildItemScanner functionality
- 💬 **Smart Social Interaction** - Time-based contextual messaging with clickable history panels

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
- **Equipment Alerts**: Quality filter and legendary item override controls

### ⚒️ Professions
- **Manage Professions**: Add/remove professions for recipe and material detection
- **Current List**: View all configured professions
- **Quick Clear**: Clear all professions option

### 🎉 Social Features
- **Auto-GZ**: Automatically congratulate players on level ups with configurable chance (0-100%)
- **Auto-RIP**: Send condolences when players die with configurable chance (0-100%)
- **Chance Sliders**: Fine-tune probability of automatic responses with visual percentage display
- **Custom GZ Messages**: Add, remove, and manage personalized congratulation messages
- **Custom RIP Messages**: Add level-specific condolence messages (Low 1-39, Mid 40-59, High 60)
- **Message Management**: Full UI for managing custom messages with clear all functionality
- ⚠️ **Requires**: [Frontier addon](https://github.com/torcriss/frontier) for functionality

### 📜 Alert History
- **View History**: Browse latest 20 alerts with timestamps and details
- **Clickable Entries**: Click any alert to whisper the player about item availability
- **Sent Indicators**: Visual [Sent] markers prevent duplicate messages
- **Whisper Mode Support**: Respects GIS whisper settings for messaging behavior
- **Player Information**: See which players linked items and when
- **Alert Types**: Identify what type of alert was triggered
- **Clear History**: Remove all history entries with confirmation

### 🎉 Social History  
- **Auto-GZ/RIP Tracking**: View automatic congratulations and condolences sent
- **Achievement Details**: See specific achievements that triggered congratulations
- **Smart Time-Based Messages**: Click entries for contextual responses based on event age
  - Recent (< 1 min): Quick "GZ" or "F"
  - Medium (1-3 min): Personal "GZ [player]" or "RIP [player]"
  - Older (> 3 min): Detailed with achievement info or "Go agane"
- **Sent Indicators**: [Sent] and [Auto] markers prevent duplicate messages
- **Message Mode Selection**: Choose between guild messages and private whispers
- **Dynamic Tooltips**: Preview exact message before sending
- **Visual Distinction**: Color-coded entries (green for GZ, red for RIP)
- **Latest 20 Events**: Performance-optimized display of recent social interactions
- ⚠️ **Requires**: [Frontier addon](https://github.com/torcriss/frontier) for data

### 💰 WTB History
- **Request Tracking**: View latest 20 Want-To-Buy requests with detailed information
- **Smart Display**: Shows player, item, quantity, price, and original message
- **Clickable Entries**: Click any WTB request to whisper the player with clickable item links
- **Sent Tracking**: Visual [Sent] indicators prevent duplicate messages
- **Price Analysis**: Parse and display extracted prices and quantities from messages
- **Clear History**: Remove all WTB history entries with one click
- **Tooltips**: Hover over entries to see complete original messages

### 📊 Guild Logs
- **Message History**: View up to 200 guild messages processed by GuildItemScanner
- **Chronological Display**: Simple, clean timeline of all guild messages without filtering complexity
- **Detailed Information**: See sender, timestamp, item count, WTB status, and alert types
- **Color-Coded Display**: Visual indicators for different alert types and message status
- **Statistics**: View total entries, oldest/newest messages, and storage capacity
- **Hover Details**: Full message content and processing details in tooltips
- **Complete History Access**: Displays all 200 stored messages with smooth scrolling
- **Simplified Interface**: Clean design focused on message content without filter clutter

### 🔧 Admin Tools
- **Smoke Test**: Run GuildItemScanner diagnostic tests
- **Status Display**: Shows test results and system status
- **Debug Tools**: Testing and troubleshooting utilities with advanced controls

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

### v1.15.0 - Simplified Guild Logs
- **🧹 Interface Simplification**: Removed all filter buttons from Guild Logs panel for cleaner design
- **📊 Streamlined Display**: Shows all guild messages chronologically without filtering complexity
- **⚡ Better Performance**: No filtering overhead when loading messages
- **🎯 Improved Focus**: More space for actual message content and statistics
- **📉 Reduced Complexity**: Removed 100+ lines of filter-related code

### v1.14.0 - Guild Logs Panel
- **📊 New Guild Logs Panel**: Complete guild message history tracking and analysis
- **🔍 Advanced Filtering**: Filter by All, WTB, Filtered, or specific alert types (removed in v1.15.0)
- **🎨 Color-Coded Display**: Visual indicators for different alert types and message status
- **📈 Statistics**: Shows total entries, oldest/newest messages, and storage capacity
- **⚡ Performance Optimized**: Displays latest 50 entries for smooth UI performance

### v1.13.0 - WTB History Tracking
- **💰 WTB History Panel**: New dedicated panel for tracking Want-To-Buy requests from guild members
- **📊 Smart Parsing**: Automatically extracts player names, items, quantities, and prices from WTB messages
- **🎯 Clickable Interaction**: Click any WTB entry to whisper the player about item availability
- **🔗 Item Link Whispers**: Whisper messages include clickable item links for easy interaction
- **📋 Detailed Display**: Shows time, player, item links, parsed quantities and prices
- **💬 Tooltip Messages**: Hover to see complete original WTB messages for context
- **✅ Sent Tracking**: [Sent] indicators prevent duplicate whispers to the same player
- **🧹 History Management**: Clear all WTB history with confirmation and refresh functionality
- **🔗 GIS Integration**: Direct integration with `/gis wtblist` and `/gis wtbclear` commands

### v1.12.0 - Custom Message Management
- **🎯 Custom GZ Messages**: Add, edit, and manage personalized congratulation messages through intuitive UI
- **📝 Custom RIP Messages**: Create level-specific condolence messages with dropdown selector (Low 1-39, Mid 40-59, High 60)
- **🗂️ Message Organization**: Visual list display showing all custom messages with index numbers for easy management
- **🧹 Bulk Operations**: "Clear All" functionality to quickly remove all custom messages
- **🔧 Individual Control**: Remove specific messages by index with simple input field
- **🎛️ Level Categories**: Smart level categorization system matching GuildItemScanner's internal structure
- **✨ Clean UI**: Improved spacing and layout for better user experience

### v1.11.0 - Social Features Chance Control
- **🎛️ Auto-GZ Chance Slider**: Control probability (0-100%) of automatic congratulations
- **🎛️ Auto-RIP Chance Slider**: Control probability (0-100%) of automatic condolences  
- **📊 Real-Time Display**: Visual percentage indicators show current chance settings
- **🔗 GIS Integration**: Direct integration with /gis gz chance and /gis rip chance commands
- **💡 Smart Tooltips**: Clear explanations of chance mechanism functionality
- **⚙️ Default Values**: GZ defaults to 50%, RIP defaults to 60% for balanced interaction

### v1.10.0 - Equipment Quality Filtering
- **⚙️ Equipment Alerts Section**: New dedicated equipment alerts in Alert Settings panel
- **🎛️ Quality Filter Control**: Dropdown to set minimum quality (Common+ through Legendary)
- **✨ Legendary Override**: Checkbox to always alert legendary items regardless of filter
- **🔗 Full Integration**: UI access to GuildItemScanner's /gis equipquality command functionality
- **📏 Smart Layout**: Dynamic panel sizing to accommodate new controls

### v1.9.0 - Smart Time-Based Social Messages
- **🕐 Intelligent Messaging**: Social History clicks now send different messages based on event timing
- **⚡ Quick Responses**: Recent events (< 1 min) get instant reactions: "GZ" or "F"
- **🎯 Targeted Messages**: Medium age events (1-3 min) get personalized: "GZ [player]" or "RIP [player]"
- **📝 Detailed Responses**: Older events (> 3 min) get full context: achievement details or "Go agane"
- **💬 Dynamic Tooltips**: Preview exact message that will be sent before clicking

### v1.8.1 - Auto-Sent Detection Fix
- **🔧 Bug Fix**: Fixed [Auto] indicator not showing for GuildItemScanner auto-sent messages
- **🎯 Improved Detection**: Analyzes GIS social history data to properly identify auto-sent vs manual messages
- **✅ Reliable Indicators**: [Auto] markers now correctly appear for auto-congratulations and condolences

### v1.8.0 - Sent Message Indicators
- **✅ Duplicate Prevention**: Both Alert and Social History panels now show [Sent] indicators
- **🎯 Visual Feedback**: Green [Sent] markers for manually clicked messages, yellow [Auto] for automatic
- **💾 Persistent Tracking**: Sent status saved across game sessions in SavedVariables
- **🔄 Smart Refresh**: Display updates immediately when messages are sent
- **⚠️ Click Protection**: Prevents accidental duplicate messaging with warning alerts

### v1.7.0 - Social History Message Mode Selection
- **🎛️ Message Mode Selection**: Choose between guild messages and whispers in Social History
- **📻 Radio Button Controls**: Clear "Send to Guild" vs "Whisper Player" options
- **💾 Settings Persistence**: Your selection is saved across game sessions
- **🎯 Dynamic Tooltips**: Shows exactly what will be sent based on selected mode

### v1.6.0 - Social History Panel Added
- **🎉 New Social History Panel**: View and interact with Auto-GZ and Auto-RIP history
- **🎯 Clickable Social Events**: Click entries to send guild messages for congratulations/condolences
- **🎨 Visual Event Distinction**: Color-coded backgrounds (green for GZ, red for RIP)
- **🏆 Full Achievement Details**: Shows specific achievement names like "Reach Level 30"

### v1.5.0 - Clickable Alert History
- **🎯 Clickable History Entries**: Click any item in Alert History to whisper the player
- **💬 Smart Whisper System**: Uses same whisper logic as GIS greed/request buttons
- **⚙️ Respects Settings**: Automatically uses WHISPER or GUILD channel based on GIS settings
- **📝 Clear Message Format**: "Is this [item] still available. I could use it, if no one needs."

### v1.4.0 - Enhanced Interface
- **🔧 Admin Tools Panel**: Added smoke test functionality and debug controls
- **📊 Performance Optimizations**: Limited history displays to 20 entries for better performance
- **✨ Visual Improvements**: Better status indicators and consistent styling
- **7-Panel Interface**: Complete coverage of all GuildItemScanner functionality

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

**Perfect for**: Players who want an intuitive, visual way to configure GuildItemScanner and interact with guild members through alert and social history.

**Key Features**: 8-Panel Interface • WTB History Tracking • Custom Message Management • Social Chance Controls • Equipment Quality Filtering • Smart Time-Based Messages • Clickable History • Social Interaction • Sent Indicators • Performance Optimized

**Compatible with**: WoW Classic Era • All GuildItemScanner versions • Lightweight & Fast