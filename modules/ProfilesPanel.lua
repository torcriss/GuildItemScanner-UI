-- ProfilesPanel.lua - Profile management panel

local addonName, addon = ...

local ProfilesPanel = {}
addon:RegisterModule("ProfilesPanel", ProfilesPanel)

function ProfilesPanel:Initialize()
end

function ProfilesPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function ProfilesPanel:CreatePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    self.panel = panel
    
    local yOffset = -20
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("Profile Management")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 40
    
    -- Current profile display
    local currentLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", 10, yOffset)
    currentLabel:SetText("Current Profile:")
    yOffset = yOffset - 20
    
    local currentProfile = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentProfile:SetPoint("TOPLEFT", 20, yOffset)
    self.currentProfile = currentProfile
    yOffset = yOffset - 30
    
    -- Auto-save note
    local autoSaveNote = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    autoSaveNote:SetPoint("TOPLEFT", 20, yOffset)
    autoSaveNote:SetText("|cff00ff00Auto-Save: Always Enabled|r - Settings automatically saved to current profile")
    autoSaveNote:SetTextColor(0.8, 0.8, 0.8)
    yOffset = yOffset - 40
    
    -- Save new profile section
    local saveLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    saveLabel:SetPoint("TOPLEFT", 10, yOffset)
    saveLabel:SetText("Save Current Settings as New Profile:")
    yOffset = yOffset - 25
    
    local nameInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    nameInput:SetSize(200, 25)
    nameInput:SetPoint("TOPLEFT", 20, yOffset)
    nameInput:SetText("My Profile")
    nameInput:SetAutoFocus(false)
    yOffset = yOffset - 35
    
    local saveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveButton:SetSize(100, 25)
    saveButton:SetPoint("TOPLEFT", 20, yOffset)
    saveButton:SetText("Save Profile")
    saveButton:SetScript("OnClick", function()
        local profileName = nameInput:GetText()
        if profileName and profileName ~= "" and addon.GIS.IsAvailable() then
            local success, msg = addon.GIS.SaveProfile(profileName)
            if success then
                print("|cff00ff00[GIS-UI]|r Profile saved: " .. profileName)
                self:UpdateCurrentProfile()
                nameInput:SetText("") -- Clear input
            else
                print("|cffff0000[GIS-UI]|r Failed to save profile: " .. (msg or "Unknown error"))
            end
        elseif not profileName or profileName == "" then
            print("|cffff0000[GIS-UI]|r Please enter a profile name")
        else
            print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        end
    end)
    
    yOffset = yOffset - 60
    
    -- More features notice
    local notice = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    notice:SetPoint("TOPLEFT", 10, yOffset)
    notice:SetText("Additional profile features (load, delete, list)\nwill be available in future updates.")
    notice:SetTextColor(1, 1, 0)
    
    self:UpdateCurrentProfile()
    
    panel:Hide()
    return panel
end

function ProfilesPanel:UpdateCurrentProfile()
    if not self.currentProfile then return end
    
    if addon.GIS.IsAvailable() then
        local current = addon.GIS.GetCurrentProfile()
        self.currentProfile:SetText(current or "DEFAULT")
    else
        self.currentProfile:SetText("|cffff0000Not Available|r")
    end
end