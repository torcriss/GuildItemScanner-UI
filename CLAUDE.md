# CLAUDE.md

Development guidance for Claude Code when working with GuildItemScanner-UI addon.

## Project Overview

GuildItemScanner-UI is a companion addon that provides a graphical user interface for configuring GuildItemScanner. It operates entirely through the GIS public API to ensure no regression or interference with the main addon.

## Core Architecture Principles

### 1. **Dependency Safety**
- **Always check GIS availability** before any API call
- **Graceful degradation** when GIS is not available
- **No direct file access** to GIS internal variables
- **Error handling** for all GIS interactions

### 2. **API Access Pattern**
```lua
-- Safe API wrapper pattern
local function SafeGISCall(func, ...)
    if not IsGISAvailable() then
        return nil
    end
    
    local success, result = pcall(func, ...)
    if not success then
        print("|cffff0000[GIS-UI Error]|r API call failed")
        return nil
    end
    
    return result
end
```

### 3. **Module System**
- Each panel is a separate module in `modules/` directory
- Modules register themselves with main addon
- Lazy loading - panels created only when accessed
- Consistent interface for all modules

## Key Development Guidelines

### Safe GIS Integration
```lua
-- Check availability
if addon.GIS.IsAvailable() then
    -- Safe to use GIS API
end

-- Setting values
addon.GIS.Set("debugMode", true)

-- Getting values with fallback
local value = addon.GIS.Get("enabled") or false

-- Using GIS functions
local professions = addon.GIS.GetProfessions()
```

### UI Framework Standards
- Use standard WoW frame API and templates
- Follow Blizzard UI conventions and styling
- Support ESC key to close main frame
- Make frames movable and save positions
- Consistent tooltip patterns

### Panel Development Pattern
```lua
local Panel = {}
addon:RegisterModule("PanelName", Panel)

function Panel:Initialize()
    -- Module initialization
end

function Panel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function Panel:CreatePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    -- Panel creation logic
    panel:Hide()
    return panel
end
```

## File Structure

```
GuildItemScanner-UI/
├── GuildItemScanner-UI.toc         # Addon manifest
├── GuildItemScanner-UI.lua         # Main initialization
├── modules/
│   ├── MinimapButton.lua           # Minimap integration
│   ├── MainFrame.lua               # Core UI framework
│   ├── GeneralPanel.lua            # General settings
│   ├── AlertsPanel.lua             # Alert configuration
│   ├── ProfessionsPanel.lua        # Profession management
│   ├── MaterialsPanel.lua          # Custom materials
│   ├── SocialPanel.lua             # Social features
│   ├── ProfilesPanel.lua           # Profile management
│   └── HistoryPanel.lua            # History viewer
├── README.md                       # User documentation
├── CLAUDE.md                       # This file
├── LICENSE                         # MIT license
├── .gitignore                      # Git ignore rules
└── deploy.sh                       # Deployment script
```

## Testing Checklist

### Before Every Commit
- [ ] Test with GIS enabled and working
- [ ] Test with GIS disabled/not loaded
- [ ] Test all panel navigation
- [ ] Test minimap button functionality
- [ ] Test settings persistence
- [ ] Verify no Lua errors in log
- [ ] Test `/gisui` slash command
- [ ] Test ESC key closing

### Panel-Specific Testing
- [ ] General Panel: All toggles and sliders work
- [ ] Alerts Panel: Settings apply to GIS
- [ ] Professions Panel: Add/remove functionality
- [ ] Social Panel: Toggles work with Frontier
- [ ] Profiles Panel: Save functionality
- [ ] History Panel: Displays placeholder correctly

## API Reference

### Main Addon Interface
```lua
-- Check if GIS is available
addon.GIS.IsAvailable()

-- Safe API calls
addon.GIS.Get(key)
addon.GIS.Set(key, value)
addon.GIS.Toggle(key)

-- Profession management
addon.GIS.GetProfessions()
addon.GIS.AddProfession(profession)
addon.GIS.RemoveProfession(profession)

-- Safe generic calls
addon.GIS.SafeCall(func, ...)
```

### Settings Management
```lua
-- Get UI settings
addon:GetSetting(category, key)

-- Set UI settings
addon:SetSetting(category, key, value)

-- Settings are automatically saved via SavedVariables
```

## Common Issues & Solutions

### GIS Not Found
- Always check `addon.GIS.IsAvailable()` before GIS calls
- Display appropriate error messages to user
- Disable UI elements gracefully

### Settings Not Applying
- Ensure GIS API calls are successful
- Check for pcall error handling
- Verify GIS is enabled and functional

### UI Performance
- Use lazy loading for panels
- Avoid frequent UI updates
- Cache GIS values when possible

## Development Workflow

### Adding New Features
1. Create or modify appropriate panel module
2. Test with GIS enabled/disabled
3. Update tooltips and help text
4. Test settings persistence
5. Update documentation if needed

### Deployment Process
```bash
# Deploy to WoW directory
./deploy.sh

# Test in-game
# Commit changes
git add .
git commit -m "feature: description"

# Push and release if needed
git push
```

## Version Compatibility

### GIS Version Requirements
- Compatible with GIS v2.0+
- Uses public API only (forwards compatible)
- Graceful handling of missing API functions

### WoW Version Target
- Interface: 11507 (Classic Era)
- Uses only Classic-compatible API calls
- No retail-specific functions

## Future Enhancements

### Planned Features
- Enhanced profile system (load/delete/export)
- Custom materials full implementation
- Alert history with search/filter
- Keybind support
- Theme/appearance options
- Localization support

### Architecture Extensions
- Plugin system for custom panels
- Advanced settings validation
- Real-time GIS status monitoring
- Backup/restore functionality

## Release Management

### Version Numbering
- Major.Minor.Patch format
- Major: Breaking changes or major features
- Minor: New features, new panels
- Patch: Bug fixes, small improvements

### Release Process
1. Update version in TOC file
2. Test all functionality thoroughly
3. Update README if needed
4. Commit and tag release
5. Create GitHub release with notes
6. Deploy and verify

## Important Reminders

- **Never modify GIS files directly**
- **Always use GIS public API**
- **Test without GIS to ensure graceful degradation**
- **Follow WoW UI conventions**
- **Keep panels responsive and lightweight**
- **Provide clear user feedback for all actions**