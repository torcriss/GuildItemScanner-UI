-- GuildItemScanner-UI: Graphical configuration interface for GuildItemScanner
-- Version: 1.4.1

local addonName, addon = ...
addon = addon or {}

-- Version info
addon.version = "1.4.1"

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