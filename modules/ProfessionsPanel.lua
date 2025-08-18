-- ProfessionsPanel.lua - Professions management panel

local addonName, addon = ...

local ProfessionsPanel = {}
addon:RegisterModule("ProfessionsPanel", ProfessionsPanel)

function ProfessionsPanel:Initialize()
end

function ProfessionsPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function ProfessionsPanel:CreatePanel(parent)
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -25, 0)
    
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(400, 500)
    panel:SetScrollChild(content)
    
    self.panel = panel
    self.content = content
    
    local yOffset = -20
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("Profession Management")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 30
    
    -- Current professions list
    local currentLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", 10, yOffset)
    currentLabel:SetText("Current Professions:")
    yOffset = yOffset - 25
    
    local professionsList = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    professionsList:SetPoint("TOPLEFT", 20, yOffset)
    professionsList:SetWidth(350)
    professionsList:SetJustifyH("LEFT")
    self.professionsList = professionsList
    yOffset = yOffset - 50
    
    -- Add profession section
    local addLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addLabel:SetPoint("TOPLEFT", 10, yOffset)
    addLabel:SetText("Add Profession:")
    yOffset = yOffset - 25
    
    -- Dropdown for available professions
    local dropdown = CreateFrame("Frame", nil, content, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 10, yOffset)
    UIDropDownMenu_SetWidth(dropdown, 150)
    
    local professions = {"Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "First Aid", "Leatherworking", "Tailoring"}
    
    UIDropDownMenu_Initialize(dropdown, function()
        for _, prof in ipairs(professions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = prof
            info.value = prof
            info.func = function(self)
                UIDropDownMenu_SetSelectedValue(dropdown, self.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    UIDropDownMenu_SetText(dropdown, "Select Profession")
    
    -- Add button
    local addButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    addButton:SetSize(80, 25)
    addButton:SetPoint("LEFT", dropdown, "RIGHT", 0, 0)
    addButton:SetText("Add")
    addButton:SetScript("OnClick", function()
        local selected = UIDropDownMenu_GetSelectedValue(dropdown)
        if selected and addon.GIS.IsAvailable() then
            local success, msg = addon.GIS.AddProfession(selected)
            if success then
                print("|cff00ff00[GIS-UI]|r Added profession: " .. selected)
                self:UpdateProfessionsList()
            else
                print("|cffff0000[GIS-UI]|r " .. (msg or "Failed to add profession"))
            end
        end
    end)
    
    yOffset = yOffset - 50
    
    -- Clear all button
    local clearButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearButton:SetSize(120, 25)
    clearButton:SetPoint("TOPLEFT", 10, yOffset)
    clearButton:SetText("Clear All")
    clearButton:SetScript("OnClick", function()
        if addon.GIS.IsAvailable() and _G.GuildItemScanner.Config.ClearProfessions then
            addon.GIS.SafeCall(_G.GuildItemScanner.Config.ClearProfessions)
            print("|cff00ff00[GIS-UI]|r All professions cleared")
            self:UpdateProfessionsList()
        end
    end)
    
    self:UpdateProfessionsList()
    
    panel:Hide()
    return panel
end

function ProfessionsPanel:UpdateProfessionsList()
    if not self.professionsList then return end
    
    if addon.GIS.IsAvailable() then
        local professions = addon.GIS.GetProfessions()
        if #professions > 0 then
            self.professionsList:SetText(table.concat(professions, ", "))
        else
            self.professionsList:SetText("|cff808080No professions set|r")
        end
    else
        self.professionsList:SetText("|cffff0000GuildItemScanner not available|r")
    end
end