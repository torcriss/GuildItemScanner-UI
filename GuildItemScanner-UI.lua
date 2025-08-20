-- GuildItemScanner-UI: Graphical configuration interface for GuildItemScanner
-- Version: 1.10.0

local addonName, addon = ...
addon = addon or {}

-- Version info
addon.version = "1.10.0"

-- Initialize SavedVariables with defaults
local defaultSettings = {
    minimapButton = {
        hide = false,
        minimapPos = 220,
        radius = 80
    },
    mainFrame = {
        point = "CENTER",
        x = 0,
        y = 0,
        width = 600,
        height = 500
    },
    lastPanel = "General"
}

-- Check if GuildItemScanner is available
local function IsGISAvailable()
    return _G.GuildItemScanner and _G.GuildItemScanner.Config
end

-- Safe wrapper for GIS API calls
local function SafeGISCall(func, ...)
    if not IsGISAvailable() then
        return nil
    end
    
    local success, result = pcall(func, ...)
    if not success then
        print("|cffff0000[GIS-UI Error]|r API call failed: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Expose safe GIS wrapper to modules
addon.GIS = {
    IsAvailable = IsGISAvailable,
    SafeCall = SafeGISCall,
    
    -- Common API wrappers
    Get = function(key)
        return SafeGISCall(function() return _G.GuildItemScanner.Config.Get(key) end)
    end,
    
    Set = function(key, value)
        return SafeGISCall(function() _G.GuildItemScanner.Config.Set(key, value) end)
    end,
    
    Toggle = function(key)
        return SafeGISCall(function() return _G.GuildItemScanner.Config.Toggle(key) end)
    end,
    
    GetProfessions = function()
        return SafeGISCall(function() return _G.GuildItemScanner.Config.GetProfessions() end) or {}
    end,
    
    AddProfession = function(prof)
        return SafeGISCall(function() return _G.GuildItemScanner.Config.AddProfession(prof) end)
    end,
    
    RemoveProfession = function(prof)
        return SafeGISCall(function() return _G.GuildItemScanner.Config.RemoveProfession(prof) end)
    end,
    
    Reset = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner.Config.Reset then
                return _G.GuildItemScanner.Config.Reset()
            end
            return false, "Reset function not available"
        end)
    end,
    
    GetHistory = function()
        return SafeGISCall(function()
            -- Try multiple possible API paths for history
            if _G.GuildItemScanner then
                -- Check if there's a database or saved variables for history
                if _G.GuildItemScannerDB and _G.GuildItemScannerDB.alertHistory then
                    return _G.GuildItemScannerDB.alertHistory
                end
                
                -- Check Databases module
                if _G.GuildItemScanner.Databases and _G.GuildItemScanner.Databases.history then
                    return _G.GuildItemScanner.Databases.history
                end
                
                -- Try accessing the internal history storage
                if _G.GuildItemScanner.History and _G.GuildItemScanner.History.entries then
                    return _G.GuildItemScanner.History.entries
                end
                
                -- Direct history table
                if _G.GuildItemScanner.alertHistory and type(_G.GuildItemScanner.alertHistory) == "table" then
                    return _G.GuildItemScanner.alertHistory
                end
                
                -- Database/saved variables
                if _G.GuildItemScanner.db and _G.GuildItemScanner.db.alertHistory then
                    return _G.GuildItemScanner.db.alertHistory
                end
                
                -- Config module
                if _G.GuildItemScanner.Config and _G.GuildItemScanner.Config.GetHistory then
                    return _G.GuildItemScanner.Config.GetHistory()
                end
            end
            
            return {}
        end) or {}
    end,
    
    ClearHistory = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner then
                -- Method 1: History module - try with proper error handling
                if _G.GuildItemScanner.History and _G.GuildItemScanner.History.ClearHistory then
                    local success, result = pcall(_G.GuildItemScanner.History.ClearHistory)
                    if success then
                        return true
                    end
                    -- Fall through to direct clearing if GIS function fails
                end
                
                -- Method 2: Direct database clear (this should always work)
                if _G.GuildItemScannerDB and _G.GuildItemScannerDB.alertHistory then
                    _G.GuildItemScannerDB.alertHistory = {}
                    return true
                end
                
                -- Method 3: Config module
                if _G.GuildItemScanner.Config and _G.GuildItemScanner.Config.ClearHistory then
                    return _G.GuildItemScanner.Config.ClearHistory()
                end
                
                -- Method 4: Direct addon table clear
                if _G.GuildItemScanner.alertHistory then
                    _G.GuildItemScanner.alertHistory = {}
                    return true
                end
            end
            return false, "Clear history function not available"
        end)
    end,
    
    GetSocialHistory = function()
        return SafeGISCall(function()
            -- Try multiple possible API paths for social history
            if _G.GuildItemScanner then
                -- Check SavedVariables first
                if _G.GuildItemScannerDB and _G.GuildItemScannerDB.socialHistory then
                    return _G.GuildItemScannerDB.socialHistory
                end
                
                -- Check Social module
                if _G.GuildItemScanner.Social and _G.GuildItemScanner.Social.GetSocialHistory then
                    return _G.GuildItemScanner.Social.GetSocialHistory()
                end
            end
            
            return {}
        end) or {}
    end,
    
    ClearSocialHistory = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner then
                -- Method 1: Social module
                if _G.GuildItemScanner.Social and _G.GuildItemScanner.Social.ClearSocialHistory then
                    _G.GuildItemScanner.Social.ClearSocialHistory()
                    return true
                end
                
                -- Method 2: Direct SavedVariables clear
                if _G.GuildItemScannerDB then
                    _G.GuildItemScannerDB.socialHistory = {}
                    return true
                end
            end
            return false, "Clear social history function not available"
        end)
    end,
    
    -- Custom GZ message management
    GetGZMessages = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                return _G.GuildItemScanner.Config.GetGzMessages()
            end
            return {}
        end) or {}
    end,
    
    AddGZMessage = function(message)
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                return _G.GuildItemScanner.Config.AddGzMessage(message)
            end
            -- Fallback: simulate the /gis gz add command
            SlashCmdList["GUILDITEMSCANNER"]("gz add " .. message)
            return true
        end)
    end,
    
    RemoveGZMessage = function(index)
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                return _G.GuildItemScanner.Config.RemoveGzMessage(index)
            end
            -- Fallback: simulate the /gis gz remove command
            SlashCmdList["GUILDITEMSCANNER"]("gz remove " .. tostring(index))
            return true
        end)
    end,
    
    ClearGZMessages = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                _G.GuildItemScanner.Config.ClearGzMessages()
                return true
            end
            -- Fallback: simulate the /gis gz clear command
            SlashCmdList["GUILDITEMSCANNER"]("gz clear")
            return true
        end)
    end,
    
    -- Custom RIP message management
    GetRIPMessages = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                local ripData = _G.GuildItemScanner.Config.GetRipMessages()
                -- Convert to flat array with level info for UI display
                local result = {}
                local levels = {"low", "mid", "high"}
                for _, level in ipairs(levels) do
                    if ripData[level] then
                        for i, message in ipairs(ripData[level]) do
                            table.insert(result, {
                                level = level,
                                message = message,
                                originalIndex = i,
                                displayIndex = #result + 1
                            })
                        end
                    end
                end
                return result
            end
            return {}
        end) or {}
    end,
    
    AddRIPMessage = function(level, message)
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                -- Convert numeric level to category if needed
                local levelCategory
                if tonumber(level) then
                    local numLevel = tonumber(level)
                    if numLevel >= 1 and numLevel <= 39 then
                        levelCategory = "low"
                    elseif numLevel >= 40 and numLevel <= 59 then
                        levelCategory = "mid"
                    else
                        levelCategory = "high"
                    end
                else
                    levelCategory = level -- assume it's already a category
                end
                
                return _G.GuildItemScanner.Config.AddRipMessage(levelCategory, message)
            end
            -- Fallback: simulate the /gis rip add command
            SlashCmdList["GUILDITEMSCANNER"]("rip add " .. tostring(level) .. " " .. message)
            return true
        end)
    end,
    
    RemoveRIPMessage = function(index)
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                -- First, get all messages to find which level/index this display index corresponds to
                local ripData = _G.GuildItemScanner.Config.GetRipMessages()
                local currentIndex = 0
                local levels = {"low", "mid", "high"}
                
                for _, level in ipairs(levels) do
                    if ripData[level] then
                        for i, message in ipairs(ripData[level]) do
                            currentIndex = currentIndex + 1
                            if currentIndex == index then
                                return _G.GuildItemScanner.Config.RemoveRipMessage(level, i)
                            end
                        end
                    end
                end
                return false, "Invalid index"
            end
            -- Fallback: simulate the /gis rip remove command (this won't work well without level)
            SlashCmdList["GUILDITEMSCANNER"]("rip remove " .. tostring(index))
            return true
        end)
    end,
    
    ClearRIPMessages = function()
        return SafeGISCall(function()
            if _G.GuildItemScanner and _G.GuildItemScanner.Config then
                return _G.GuildItemScanner.Config.ClearRipMessages()
            end
            -- Fallback: simulate the /gis rip clear command
            SlashCmdList["GUILDITEMSCANNER"]("rip clear")
            return true
        end)
    end
}

-- Module registration
addon.modules = {}

function addon:RegisterModule(name, module)
    self.modules[name] = module
    module.addon = self
end

-- Settings management
function addon:LoadSettings()
    if not GuildItemScannerUIDB then
        GuildItemScannerUIDB = {}
    end
    
    -- Apply defaults for missing keys
    for key, value in pairs(defaultSettings) do
        if not GuildItemScannerUIDB[key] then
            if type(value) == "table" then
                GuildItemScannerUIDB[key] = {}
                for k, v in pairs(value) do
                    GuildItemScannerUIDB[key][k] = v
                end
            else
                GuildItemScannerUIDB[key] = value
            end
        else
            -- Apply missing sub-keys
            if type(value) == "table" then
                for k, v in pairs(value) do
                    if GuildItemScannerUIDB[key][k] == nil then
                        GuildItemScannerUIDB[key][k] = v
                    end
                end
            end
        end
    end
end

function addon:SaveSettings()
    -- Settings automatically saved via SavedVariables
end

function addon:GetSetting(category, key)
    return GuildItemScannerUIDB[category] and GuildItemScannerUIDB[category][key]
end

function addon:SetSetting(category, key, value)
    if not GuildItemScannerUIDB[category] then
        GuildItemScannerUIDB[category] = {}
    end
    GuildItemScannerUIDB[category][key] = value
end

-- Initialize addon
local function OnAddonLoaded(self, event, loadedAddon)
    if loadedAddon ~= addonName then 
        return 
    end
    
    -- Load settings
    addon:LoadSettings()
    
    -- Check for GuildItemScanner
    if not IsGISAvailable() then
        print("|cffff0000[GIS-UI]|r |cffffffff" .. addonName .. " requires |cff00ff00GuildItemScanner|r to function.|r")
        print("|cffff0000[GIS-UI]|r |cffffffPlease install and enable GuildItemScanner addon.|r")
        
        -- Still initialize modules for graceful degradation
        for name, module in pairs(addon.modules) do
            if module.Initialize then
                module:Initialize()
            end
        end
        return
    end
    
    -- Initialize modules
    for name, module in pairs(addon.modules) do
        if module.Initialize then
            local success, err = pcall(module.Initialize, module)
            if not success then
                print("|cffff0000[GIS-UI Error]|r Failed to initialize " .. name .. ": " .. tostring(err))
            end
        end
    end
    
    print("|cff00ff00[GIS-UI]|r v" .. addon.version .. " loaded successfully. Use |cffffff00/gisui|r or click the minimap button.")
end

-- Event handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnAddonLoaded)

-- Slash commands
SLASH_GISUI1 = "/gisui"
SLASH_GISUI2 = "/gis-ui"
SlashCmdList["GISUI"] = function(msg)
    if addon.modules.MainFrame then
        if msg and msg ~= "" then
            -- Allow opening to specific panel
            addon.modules.MainFrame:Show(msg)
        else
            addon.modules.MainFrame:Toggle()
        end
    else
        print("|cffff0000[GIS-UI]|r Main frame not available.")
    end
end

-- Global access
_G.GuildItemScannerUI = addon