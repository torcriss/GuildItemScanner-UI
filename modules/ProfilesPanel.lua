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
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -25, 0)
    
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(400, 600)
    panel:SetScrollChild(content)
    
    self.panel = panel
    self.content = content
    
    local yOffset = -20
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("Profile Management")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 30
    
    -- Current profile display
    local currentLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", 10, yOffset)
    currentLabel:SetText("Current Profile:")
    yOffset = yOffset - 20
    
    local currentProfile = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentProfile:SetPoint("TOPLEFT", 20, yOffset)
    self.currentProfile = currentProfile
    yOffset = yOffset - 35
    
    -- Save new profile section
    local saveTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    saveTitle:SetPoint("TOPLEFT", 10, yOffset)
    saveTitle:SetText("Save New Profile")
    saveTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    local nameInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    nameInput:SetSize(200, 25)
    nameInput:SetPoint("TOPLEFT", 10, yOffset)
    nameInput:SetText("My Profile")
    nameInput:SetAutoFocus(false)
    self.nameInput = nameInput
    
    local saveButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    saveButton:SetSize(100, 25)
    saveButton:SetPoint("LEFT", nameInput, "RIGHT", 10, 0)
    saveButton:SetText("Save Profile")
    saveButton:SetScript("OnClick", function()
        self:SaveProfile()
    end)
    
    yOffset = yOffset - 50
    
    -- Load profile section
    local loadTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    loadTitle:SetPoint("TOPLEFT", 10, yOffset)
    loadTitle:SetText("Load Profile")
    loadTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    -- Profiles dropdown
    local profileDropdown = self:CreateDropdown(content, "Select Profile", 10, yOffset)
    self.profileDropdown = profileDropdown
    
    local loadButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    loadButton:SetSize(100, 25)
    loadButton:SetPoint("LEFT", profileDropdown, "RIGHT", 10, 0)
    loadButton:SetText("Load Profile")
    loadButton:SetScript("OnClick", function()
        self:LoadProfile()
    end)
    self.loadButton = loadButton
    
    yOffset = yOffset - 50
    
    -- Delete profile section
    local deleteTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deleteTitle:SetPoint("TOPLEFT", 10, yOffset)
    deleteTitle:SetText("Delete Profile")
    deleteTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    local deleteButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    deleteButton:SetSize(120, 25)
    deleteButton:SetPoint("TOPLEFT", 10, yOffset)
    deleteButton:SetText("Delete Selected")
    deleteButton:SetScript("OnClick", function()
        self:DeleteProfile()
    end)
    self.deleteButton = deleteButton
    
    yOffset = yOffset - 35
    
    self:UpdateCurrentProfile()
    self:UpdateProfileDropdown()
    
    panel:Hide()
    return panel
end

function ProfilesPanel:CreateDropdown(parent, text, x, y)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 0)
    label:SetText(text)
    
    UIDropDownMenu_SetWidth(dropdown, 200)
    UIDropDownMenu_SetText(dropdown, "No profiles available")
    
    return dropdown
end

function ProfilesPanel:UpdateProfileDropdown()
    if not self.profileDropdown then return end
    
    -- Auto-save current settings if no profiles exist
    local profiles = addon.GIS.GetProfiles()
    if #profiles == 0 and addon.GIS.IsAvailable() then
        addon.GIS.SaveProfile("Current Settings")
        profiles = addon.GIS.GetProfiles()
    end
    
    local dropdown = self.profileDropdown
    UIDropDownMenu_Initialize(dropdown, function()
        if #profiles == 0 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = "No profiles available"
            info.disabled = true
            UIDropDownMenu_AddButton(info)
            return
        end
        
        for _, profileInfo in ipairs(profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profileInfo.name
            info.value = profileInfo.name
            info.func = function(button)
                UIDropDownMenu_SetSelectedValue(dropdown, button.value)
                UIDropDownMenu_SetText(dropdown, button.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Set default text and select first profile if available
    if #profiles > 0 then
        local defaultProfile = profiles[1].name
        UIDropDownMenu_SetText(self.profileDropdown, defaultProfile)
        UIDropDownMenu_SetSelectedValue(self.profileDropdown, defaultProfile)
    else
        UIDropDownMenu_SetText(self.profileDropdown, "No profiles available")
    end
    
    -- Enable/disable buttons
    local hasProfiles = #profiles > 0
    self.loadButton:SetEnabled(hasProfiles)
    self.deleteButton:SetEnabled(hasProfiles)
end

function ProfilesPanel:UpdateCurrentProfile()
    if not self.currentProfile then return end
    
    if addon.GIS.IsAvailable() then
        local current = addon.GIS.GetCurrentProfile()
        self.currentProfile:SetText("|cff00ff00" .. (current or "DEFAULT") .. "|r")
    else
        self.currentProfile:SetText("|cffff0000Not Available|r")
    end
end

function ProfilesPanel:SaveProfile()
    local profileName = self.nameInput:GetText()
    if not profileName or profileName == "" then
        print("|cffff0000[GIS-UI]|r Please enter a profile name")
        return
    end
    
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local success, msg = addon.GIS.SaveProfile(profileName)
    if success then
        print("|cff00ff00[GIS-UI]|r Profile saved: " .. profileName)
        self.nameInput:SetText("") -- Clear input
        self:UpdateProfileDropdown()
        self:UpdateCurrentProfile()
        
        -- Select the newly saved profile
        UIDropDownMenu_SetText(self.profileDropdown, profileName)
        UIDropDownMenu_SetSelectedValue(self.profileDropdown, profileName)
    else
        print("|cffff0000[GIS-UI]|r Failed to save profile: " .. (msg or "Unknown error"))
    end
end

function ProfilesPanel:LoadProfile()
    local selectedProfile = UIDropDownMenu_GetSelectedValue(self.profileDropdown)
    if not selectedProfile then
        print("|cffff0000[GIS-UI]|r Please select a profile to load")
        return
    end
    
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local success, msg = addon.GIS.LoadProfile(selectedProfile)
    if success then
        print("|cff00ff00[GIS-UI]|r Profile loaded: " .. selectedProfile)
        self:UpdateCurrentProfile()
        
        -- Refresh other panels if they exist
        if addon.modules.GeneralPanel and addon.modules.GeneralPanel.RefreshValues then
            addon.modules.GeneralPanel:RefreshValues()
        end
    else
        print("|cffff0000[GIS-UI]|r Failed to load profile: " .. (msg or "Unknown error"))
    end
end

function ProfilesPanel:DeleteProfile()
    local selectedProfile = UIDropDownMenu_GetSelectedValue(self.profileDropdown)
    if not selectedProfile then
        print("|cffff0000[GIS-UI]|r Please select a profile to delete")
        return
    end
    
    local success, msg = addon.GIS.DeleteProfile(selectedProfile)
    if success then
        print("|cff00ff00[GIS-UI]|r Profile deleted: " .. selectedProfile)
        self:UpdateProfileDropdown()
        -- UpdateProfileDropdown will handle setting default selection
    else
        print("|cffff0000[GIS-UI]|r Failed to delete profile: " .. (msg or "Unknown error"))
    end
end