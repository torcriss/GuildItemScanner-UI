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
- All panels use ScrollFrame with proper scrollbars

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
- **All panels must use ScrollFrame structure**

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
    -- IMPORTANT: Use ScrollFrame structure
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -25, 0)
    
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(400, 500) -- Adjust height as needed
    panel:SetScrollChild(content)
    
    -- Panel creation logic using content frame
    panel:Hide()
    return panel
end
```

## Current Interface Structure

### 6 Core Panels
1. **General Settings** - Core GIS configuration, toggles, and timing
2. **Alert Settings** - Recipe, material, bag, and potion alerts with filters  
3. **Professions** - Add/remove professions for detection
4. **Social Features** - Auto-GZ and Auto-RIP (requires Frontier)
5. **Alert History** - View and manage alert history with timestamps and player info
6. **Admin Tools** - Testing and debugging utilities for GIS

### Removed Features
- **Profile Management** - Removed in v1.2.0 for streamlined experience
- **Custom Materials** - Never fully implemented, removed for simplicity

## File Structure

```
GuildItemScanner-UI/
├── GuildItemScanner-UI.toc         # Addon manifest
├── GuildItemScanner-UI.lua         # Main initialization (streamlined)
├── modules/
│   ├── MinimapButton.lua           # Minimap integration
│   ├── MainFrame.lua               # Core UI framework
│   ├── GeneralPanel.lua            # General settings
│   ├── AlertsPanel.lua             # Alert configuration
│   ├── ProfessionsPanel.lua        # Profession management
│   ├── SocialPanel.lua             # Social features
│   ├── HistoryPanel.lua            # Alert history viewer
│   ├── AdminPanel.lua              # Admin tools and testing
│   ├── MaterialsPanel.lua          # (Inactive)
│   └── ProfilesPanel.lua           # (Inactive)
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
- [ ] Test all 6 panel navigation
- [ ] Test minimap button functionality
- [ ] Test settings persistence
- [ ] Verify no Lua errors in log
- [ ] Test `/gisui` slash command
- [ ] Test ESC key closing
- [ ] Verify scrollbars work on all panels

### Panel-Specific Testing
- [ ] General Panel: All toggles, sliders, and dropdowns work
- [ ] Alerts Panel: Settings apply to GIS, proper spacing
- [ ] Professions Panel: Add/remove functionality, dropdown works
- [ ] Social Panel: Toggles work with Frontier, tooltips clear
- [ ] History Panel: Display history, refresh works, clear history with confirmation
- [ ] Admin Panel: Smoke test button works, status display updates

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

-- History management
addon.GIS.GetHistory()
addon.GIS.ClearHistory()

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
- All panels use ScrollFrame for consistent performance

## Development Workflow

### Adding New Features
1. Create or modify appropriate panel module
2. Ensure ScrollFrame structure is used
3. Test with GIS enabled/disabled
4. Update tooltips and help text
5. Test settings persistence
6. Update documentation if needed

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

## Streamlined Architecture (v1.2.0+)

### Design Philosophy
- **Focus on essentials** - Only features that enhance core GIS usage
- **Consistent UI patterns** - All panels follow same ScrollFrame structure
- **Clean codebase** - Removed complex unused features
- **Fast performance** - Reduced main file size by ~60%

### Code Quality Standards
- Keep modules under 300 lines when possible
- Use consistent naming conventions
- Always include error handling
- Document complex functions
- Test all GIS integration points

## Release Management

### Version Numbering
- Major.Minor.Patch format
- Major: Breaking changes or major feature removal
- Minor: New features, new panels, UI improvements
- Patch: Bug fixes, small improvements

### Release Process
1. Update version in TOC file if needed
2. Test all functionality thoroughly
3. Update README and CLAUDE.md if needed
4. Commit and tag release
5. Create GitHub release with notes
6. **Delete previous release** - Only maintain latest version
7. Deploy and verify

### Release Policy
- **ONLY ONE RELEASE**: Always maintain only the latest release on GitHub
- **Delete previous releases** immediately after creating a new one
- This keeps the download simple and avoids confusion for users
- Users should always get the most current version

## Important Reminders

- **Never modify GIS files directly**
- **Always use GIS public API**
- **Test without GIS to ensure graceful degradation**
- **Follow WoW UI conventions**
- **Keep panels responsive and lightweight**
- **Provide clear user feedback for all actions**
- **All panels must use ScrollFrame structure**
- **Focus on core functionality over feature bloat**

## Commit and Release Policy

- **Auto-approved commits**: User has approved all commit and release messages
- **Auto commit**: Can commit changes without asking for approval
- **Auto release**: Can create releases without requesting permission
- **Standard format**: Use consistent commit message format with Claude Code attribution
- **One release policy**: Always delete previous release when creating new one