-- SocialPanel.lua - Social features configuration panel

local addonName, addon = ...

local SocialPanel = {}
addon:RegisterModule("SocialPanel", SocialPanel)

function SocialPanel:Initialize()
end

function SocialPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    -- Auto-refresh message lists whenever the panel is accessed
    self:RefreshMessageLists()
    return self.panel
end

function SocialPanel:CreatePanel(parent)
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -25, 0)
    
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(400, 1000)
    panel:SetScrollChild(content)
    
    self.panel = panel
    self.content = content
    
    local yOffset = -20
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("Social Features")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 30
    
    -- Warning about Frontier requirement
    local warning = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    warning:SetPoint("TOPLEFT", 10, yOffset)
    warning:SetWidth(350)
    warning:SetJustifyH("LEFT")
    warning:SetText("|cffff8000Warning:|r Social features require the Frontier addon to function.")
    yOffset = yOffset - 35
    
    -- Auto-GZ section
    local gzTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gzTitle:SetPoint("TOPLEFT", 10, yOffset)
    gzTitle:SetText("Auto-Congratulations (GZ)")
    gzTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    self:CreateCheckbox(content, "Enable Auto-GZ", 10, yOffset,
        function() return addon.GIS.Get("autoGZ") end,
        function(checked) addon.GIS.Set("autoGZ", checked) end,
        "Automatically congratulate players on level ups"
    )
    yOffset = yOffset - 35
    
    self:CreateSlider(content, "Auto-GZ Chance", 10, yOffset, 0, 100, 1,
        function() return addon.GIS.Get("gzChance") or 50 end,
        function(value) addon.GIS.Set("gzChance", value) end,
        "Chance (0-100%) of sending automatic congratulations"
    )
    yOffset = yOffset - 45
    
    -- Auto-RIP section
    local ripTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ripTitle:SetPoint("TOPLEFT", 10, yOffset)
    ripTitle:SetText("Auto-Condolences (RIP)")
    ripTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    self:CreateCheckbox(content, "Enable Auto-RIP", 10, yOffset,
        function() return addon.GIS.Get("autoRIP") end,
        function(checked) addon.GIS.Set("autoRIP", checked) end,
        "Automatically send condolences when players die"
    )
    yOffset = yOffset - 35
    
    self:CreateSlider(content, "Auto-RIP Chance", 10, yOffset, 0, 100, 1,
        function() return addon.GIS.Get("ripChance") or 60 end,
        function(value) addon.GIS.Set("ripChance", value) end,
        "Chance (0-100%) of sending automatic condolences"
    )
    yOffset = yOffset - 65
    
    -- Custom GZ Messages section
    local gzCustomTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gzCustomTitle:SetPoint("TOPLEFT", 10, yOffset)
    gzCustomTitle:SetText("Custom GZ Messages")
    gzCustomTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    -- GZ Add message input
    local gzInput = self:CreateEditBox(content, "New GZ Message", 10, yOffset, 300)
    self.gzInput = gzInput
    yOffset = yOffset - 35
    
    -- GZ Add button
    local gzAddButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    gzAddButton:SetSize(80, 25)
    gzAddButton:SetPoint("TOPLEFT", 10, yOffset)
    gzAddButton:SetText("Add GZ")
    gzAddButton:SetScript("OnClick", function()
        self:AddGZMessage()
    end)
    yOffset = yOffset - 35
    
    -- GZ Messages list
    local gzList = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gzList:SetPoint("TOPLEFT", 10, yOffset)
    gzList:SetWidth(350)
    gzList:SetJustifyH("LEFT")
    gzList:SetText("Loading GZ messages...")
    self.gzList = gzList
    yOffset = yOffset - 80
    
    -- GZ Remove controls
    local gzRemoveInput = self:CreateEditBox(content, "Index", 10, yOffset, 60)
    self.gzRemoveInput = gzRemoveInput
    
    local gzRemoveButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    gzRemoveButton:SetSize(80, 25)
    gzRemoveButton:SetPoint("TOPLEFT", 80, yOffset)
    gzRemoveButton:SetText("Remove")
    gzRemoveButton:SetScript("OnClick", function()
        self:RemoveGZMessage()
    end)
    
    local gzClearButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    gzClearButton:SetSize(80, 25)
    gzClearButton:SetPoint("TOPLEFT", 170, yOffset)
    gzClearButton:SetText("Clear All")
    gzClearButton:SetScript("OnClick", function()
        self:ClearGZMessages()
    end)
    yOffset = yOffset - 55
    
    -- Custom RIP Messages section
    local ripCustomTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ripCustomTitle:SetPoint("TOPLEFT", 10, yOffset)
    ripCustomTitle:SetText("Custom RIP Messages")
    ripCustomTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    -- RIP Add level dropdown
    local ripLevelDropdown = self:CreateDropdown(content, "Level Category", 10, yOffset, 120, {
        {text = "Low (1-39)", value = "low"},
        {text = "Mid (40-59)", value = "mid"},
        {text = "High (60)", value = "high"}
    })
    self.ripLevelDropdown = ripLevelDropdown
    yOffset = yOffset - 40
    
    -- RIP Add message input
    local ripInput = self:CreateEditBox(content, "RIP Message", 10, yOffset, 300)
    self.ripInput = ripInput
    yOffset = yOffset - 35
    
    -- RIP Add button
    local ripAddButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ripAddButton:SetSize(80, 25)
    ripAddButton:SetPoint("TOPLEFT", 10, yOffset)
    ripAddButton:SetText("Add RIP")
    ripAddButton:SetScript("OnClick", function()
        self:AddRIPMessage()
    end)
    yOffset = yOffset - 35
    
    -- RIP Messages list
    local ripList = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ripList:SetPoint("TOPLEFT", 10, yOffset)
    ripList:SetWidth(350)
    ripList:SetJustifyH("LEFT")
    ripList:SetText("Loading RIP messages...")
    self.ripList = ripList
    yOffset = yOffset - 80
    
    -- RIP Remove controls
    local ripRemoveInput = self:CreateEditBox(content, "Index", 10, yOffset, 60)
    self.ripRemoveInput = ripRemoveInput
    
    local ripRemoveButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ripRemoveButton:SetSize(80, 25)
    ripRemoveButton:SetPoint("TOPLEFT", 80, yOffset)
    ripRemoveButton:SetText("Remove")
    ripRemoveButton:SetScript("OnClick", function()
        self:RemoveRIPMessage()
    end)
    
    local ripClearButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ripClearButton:SetSize(80, 25)
    ripClearButton:SetPoint("TOPLEFT", 170, yOffset)
    ripClearButton:SetText("Clear All")
    ripClearButton:SetScript("OnClick", function()
        self:ClearRIPMessages()
    end)
    
    -- Initial refresh of message lists
    self:RefreshMessageLists()
    
    panel:Hide()
    return panel
end

function SocialPanel:CreateCheckbox(parent, text, x, y, getValue, setValue, tooltip)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetSize(24, 24)
    
    local label = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", check, "RIGHT", 5, 0)
    label:SetText(text)
    
    if addon.GIS.IsAvailable() then
        check:SetChecked(getValue())
    else
        check:SetEnabled(false)
    end
    
    check:SetScript("OnClick", function(self)
        if addon.GIS.IsAvailable() then
            setValue(self:GetChecked())
        end
    end)
    
    if tooltip then
        check:SetScript("OnEnter", function()
            GameTooltip:SetOwner(check, "ANCHOR_RIGHT")
            GameTooltip:SetText(text)
            GameTooltip:AddLine(tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    return check
end

function SocialPanel:CreateSlider(parent, text, x, y, minValue, maxValue, step, getValue, setValue, tooltip)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetSize(200, 16)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 5)
    label:SetText(text)
    
    local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 5)
    
    if addon.GIS.IsAvailable() then
        local currentValue = getValue()
        slider:SetValue(currentValue)
        valueText:SetText(currentValue .. "%")
    else
        slider:SetEnabled(false)
        valueText:SetText("N/A")
    end
    
    slider:SetScript("OnValueChanged", function(self, value)
        if addon.GIS.IsAvailable() then
            setValue(value)
            valueText:SetText(value .. "%")
        end
    end)
    
    if tooltip then
        slider:SetScript("OnEnter", function()
            GameTooltip:SetOwner(slider, "ANCHOR_RIGHT")
            GameTooltip:SetText(text)
            GameTooltip:AddLine(tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        slider:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    return slider
end

function SocialPanel:CreateEditBox(parent, placeholder, x, y, width)
    local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    editBox:SetSize(width, 20)
    editBox:SetPoint("TOPLEFT", x, y)
    editBox:SetAutoFocus(false)
    editBox:SetText("")
    
    -- Add placeholder text
    local placeholderText = editBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    placeholderText:SetPoint("LEFT", editBox, "LEFT", 8, 0)
    placeholderText:SetText(placeholder)
    
    editBox:SetScript("OnEditFocusGained", function()
        placeholderText:Hide()
    end)
    
    editBox:SetScript("OnEditFocusLost", function()
        if editBox:GetText() == "" then
            placeholderText:Show()
        end
    end)
    
    editBox:SetScript("OnTextChanged", function()
        if editBox:GetText() ~= "" then
            placeholderText:Hide()
        elseif not editBox:HasFocus() then
            placeholderText:Show()
        end
    end)
    
    if not addon.GIS.IsAvailable() then
        editBox:SetEnabled(false)
    end
    
    return editBox
end

function SocialPanel:CreateDropdown(parent, text, x, y, width, options)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    UIDropDownMenu_SetWidth(dropdown, width)
    
    -- Add label
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    label:SetText(text)
    
    -- Store the options and current value
    dropdown.options = options
    dropdown.currentValue = options[1].value
    
    -- Set up the dropdown
    UIDropDownMenu_SetText(dropdown, options[1].text)
    
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for i, option in ipairs(dropdown.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.value = option.value
            info.func = function()
                dropdown.currentValue = option.value
                UIDropDownMenu_SetText(dropdown, option.text)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Add GetValue method
    dropdown.GetValue = function(self)
        return self.currentValue
    end
    
    -- Add SetValue method
    dropdown.SetValue = function(self, value)
        for i, option in ipairs(self.options) do
            if option.value == value then
                self.currentValue = value
                UIDropDownMenu_SetText(self, option.text)
                break
            end
        end
    end
    
    if not addon.GIS.IsAvailable() then
        UIDropDownMenu_DisableDropDown(dropdown)
    end
    
    return dropdown
end

function SocialPanel:RefreshMessageLists()
    if not addon.GIS.IsAvailable() then
        if self.gzList then
            self.gzList:SetText("|cffff0000GuildItemScanner not available|r")
        end
        if self.ripList then
            self.ripList:SetText("|cffff0000GuildItemScanner not available|r")
        end
        return
    end
    
    -- Refresh GZ messages
    if self.gzList then
        local gzMessages = addon.GIS.GetGZMessages()
        if #gzMessages > 0 then
            local displayText = ""
            for i, message in ipairs(gzMessages) do
                displayText = displayText .. i .. ". " .. message .. "\n"
            end
            self.gzList:SetText(displayText)
        else
            self.gzList:SetText("|cff808080No custom GZ messages|r")
        end
    end
    
    -- Refresh RIP messages
    if self.ripList then
        local ripMessages = addon.GIS.GetRIPMessages()
        if #ripMessages > 0 then
            local displayText = ""
            for i, data in ipairs(ripMessages) do
                local level = data.level or "?"
                local message = data.message or data
                displayText = displayText .. i .. ". " .. string.upper(level) .. ": " .. message .. "\n"
            end
            self.ripList:SetText(displayText)
        else
            self.ripList:SetText("|cff808080No custom RIP messages|r")
        end
    end
end

function SocialPanel:AddGZMessage()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local message = self.gzInput:GetText()
    if message and message ~= "" then
        local success = addon.GIS.AddGZMessage(message)
        if success then
            self.gzInput:SetText("")
            self:RefreshMessageLists()
            print("|cff00ff00[GIS-UI]|r Added GZ message: " .. message)
        else
            print("|cffff0000[GIS-UI]|r Failed to add GZ message")
        end
    end
end

function SocialPanel:RemoveGZMessage()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local indexText = self.gzRemoveInput:GetText()
    local index = tonumber(indexText)
    if index then
        local success = addon.GIS.RemoveGZMessage(index)
        if success then
            self.gzRemoveInput:SetText("")
            self:RefreshMessageLists()
            print("|cff00ff00[GIS-UI]|r Removed GZ message #" .. index)
        else
            print("|cffff0000[GIS-UI]|r Failed to remove GZ message")
        end
    else
        print("|cffff0000[GIS-UI]|r Please enter a valid message index")
    end
end

function SocialPanel:ClearGZMessages()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local success = addon.GIS.ClearGZMessages()
    if success then
        self:RefreshMessageLists()
        print("|cff00ff00[GIS-UI]|r Cleared all GZ messages")
    else
        print("|cffff0000[GIS-UI]|r Failed to clear GZ messages")
    end
end

function SocialPanel:AddRIPMessage()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local level = self.ripLevelDropdown:GetValue()
    local message = self.ripInput:GetText()
    
    if level and message and message ~= "" then
        local success = addon.GIS.AddRIPMessage(level, message)
        if success then
            self.ripLevelDropdown:SetValue("low")
            self.ripInput:SetText("")
            self:RefreshMessageLists()
            print("|cff00ff00[GIS-UI]|r Added RIP message for " .. level .. " level: " .. message)
        else
            print("|cffff0000[GIS-UI]|r Failed to add RIP message")
        end
    else
        print("|cffff0000[GIS-UI]|r Please select a level category and enter a message")
    end
end

function SocialPanel:RemoveRIPMessage()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local indexText = self.ripRemoveInput:GetText()
    local index = tonumber(indexText)
    if index then
        local success = addon.GIS.RemoveRIPMessage(index)
        if success then
            self.ripRemoveInput:SetText("")
            self:RefreshMessageLists()
            print("|cff00ff00[GIS-UI]|r Removed RIP message #" .. index)
        else
            print("|cffff0000[GIS-UI]|r Failed to remove RIP message")
        end
    else
        print("|cffff0000[GIS-UI]|r Please enter a valid message index")
    end
end

function SocialPanel:ClearRIPMessages()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local success = addon.GIS.ClearRIPMessages()
    if success then
        self:RefreshMessageLists()
        print("|cff00ff00[GIS-UI]|r Cleared all RIP messages")
    else
        print("|cffff0000[GIS-UI]|r Failed to clear RIP messages")
    end
end