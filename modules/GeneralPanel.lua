-- GeneralPanel.lua - General settings panel for GuildItemScanner-UI

local addonName, addon = ...

local GeneralPanel = {}
addon:RegisterModule("GeneralPanel", GeneralPanel)

function GeneralPanel:Initialize()
    -- Panel will be created on demand
end

function GeneralPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function GeneralPanel:CreatePanel(parent)
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetAllPoints()
    
    -- Scroll content
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(400, 600)
    panel:SetScrollChild(content)
    
    self.panel = panel
    self.content = content
    
    local yOffset = -20
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("General Settings")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 35
    
    -- Main addon enable/disable
    local enableCheck = self:CreateCheckbox(content, "Enable GuildItemScanner", 10, yOffset, 
        function() return addon.GIS.Get("enabled") end,
        function(checked) addon.GIS.Set("enabled", checked) end,
        "Enable or disable the entire GuildItemScanner addon"
    )
    yOffset = yOffset - 30
    
    -- Debug mode
    local debugCheck = self:CreateCheckbox(content, "Debug Mode", 10, yOffset,
        function() return addon.GIS.Get("debugMode") end,
        function(checked) addon.GIS.Set("debugMode", checked) end,
        "Show detailed debug information in chat"
    )
    yOffset = yOffset - 30
    
    -- Sound alerts
    local soundCheck = self:CreateCheckbox(content, "Sound Alerts", 10, yOffset,
        function() return addon.GIS.Get("soundAlert") end,
        function(checked) addon.GIS.Set("soundAlert", checked) end,
        "Play sound when alerts are shown"
    )
    yOffset = yOffset - 30
    
    -- Whisper mode
    local whisperCheck = self:CreateCheckbox(content, "Whisper Mode", 10, yOffset,
        function() return addon.GIS.Get("whisperMode") end,
        function(checked) addon.GIS.Set("whisperMode", checked) end,
        "Enable whisper mode for item requests"
    )
    yOffset = yOffset - 30
    
    -- Greed mode
    local greedCheck = self:CreateCheckbox(content, "Greed Mode", 10, yOffset,
        function() return addon.GIS.Get("greedMode") end,
        function(checked) addon.GIS.Set("greedMode", checked) end,
        "Show greed button on alerts"
    )
    yOffset = yOffset - 30
    
    -- WTB filtering
    local wtbCheck = self:CreateCheckbox(content, "Filter WTB Messages", 10, yOffset,
        function() return addon.GIS.Get("ignoreWTB") end,
        function(checked) addon.GIS.Set("ignoreWTB", checked) end,
        "Automatically filter out WTB (Want To Buy) messages"
    )
    yOffset = yOffset - 50
    
    -- Sliders section
    local slidersTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    slidersTitle:SetPoint("TOPLEFT", 10, yOffset)
    slidersTitle:SetText("Timing & Duration")
    slidersTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    -- Alert duration slider
    local alertSlider = self:CreateSlider(content, "Alert Duration", 10, yOffset, 1, 60, 
        function() return addon.GIS.Get("alertDuration") or 15 end,
        function(value) addon.GIS.Set("alertDuration", value) end,
        "Duration in seconds that alerts remain visible",
        " seconds"
    )
    yOffset = yOffset - 60
    
    -- Sound duration slider  
    local soundSlider = self:CreateSlider(content, "Sound Duration", 10, yOffset, 1, 10,
        function() return addon.GIS.Get("soundDuration") or 2 end,
        function(value) addon.GIS.Set("soundDuration", value) end,
        "Duration in seconds for sound alerts",
        " seconds"
    )
    yOffset = yOffset - 80
    
    -- Equipment comparison section
    local equipTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    equipTitle:SetPoint("TOPLEFT", 10, yOffset)
    equipTitle:SetText("Equipment Comparison")
    equipTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    -- Stat comparison mode dropdown
    local comparisonDropdown = self:CreateDropdown(content, "Comparison Mode", 10, yOffset,
        {"ilvl", "stats", "both"},
        {"Item Level", "Stat Priorities", "Both"},
        function() return addon.GIS.Get("statComparisonMode") or "ilvl" end,
        function(value) addon.GIS.Set("statComparisonMode", value) end,
        "How to compare equipment for upgrades"
    )
    yOffset = yOffset - 80
    
    -- Reset button
    local resetButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetButton:SetSize(150, 25)
    resetButton:SetPoint("TOPLEFT", 10, yOffset)
    resetButton:SetText("Reset to Defaults")
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("GISUI_CONFIRM_RESET")
    end)
    
    -- Reset confirmation dialog
    StaticPopupDialogs["GISUI_CONFIRM_RESET"] = {
        text = "Reset all GuildItemScanner settings to defaults?",
        button1 = "Reset",
        button2 = "Cancel",
        OnAccept = function()
            if addon.GIS.IsAvailable() and _G.GuildItemScanner.Config.Reset then
                addon.GIS.SafeCall(_G.GuildItemScanner.Config.Reset)
                print("|cff00ff00[GIS-UI]|r Settings reset to defaults.")
                GeneralPanel:RefreshValues()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    -- Store controls for refresh
    self.controls = {
        enableCheck, debugCheck, soundCheck, whisperCheck, greedCheck, wtbCheck,
        alertSlider, soundSlider, comparisonDropdown
    }
    
    panel:Hide()
    return panel
end

function GeneralPanel:CreateCheckbox(parent, text, x, y, getValue, setValue, tooltip)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetSize(24, 24)
    
    local label = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", check, "RIGHT", 5, 0)
    label:SetText(text)
    
    -- Set initial value
    if addon.GIS.IsAvailable() then
        check:SetChecked(getValue())
    else
        check:SetEnabled(false)
    end
    
    check:SetScript("OnClick", function(self)
        if addon.GIS.IsAvailable() then
            setValue(self:GetChecked())
        else
            self:SetChecked(false)
        end
    end)
    
    -- Tooltip
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
    
    check.getValue = getValue
    check.setValue = setValue
    
    return check
end

function GeneralPanel:CreateSlider(parent, text, x, y, minVal, maxVal, getValue, setValue, tooltip, suffix)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetSize(200, 16)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    
    -- Labels
    local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 5)
    label:SetText(text)
    
    local valueLabel = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueLabel:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 5)
    
    -- Min/max labels
    slider.Low:SetText(minVal)
    slider.High:SetText(maxVal)
    
    -- Set initial value
    if addon.GIS.IsAvailable() then
        local value = getValue()
        slider:SetValue(value)
        valueLabel:SetText(value .. (suffix or ""))
    else
        slider:SetEnabled(false)
        valueLabel:SetText("N/A")
    end
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)  -- Round to nearest integer
        valueLabel:SetText(value .. (suffix or ""))
        if addon.GIS.IsAvailable() then
            setValue(value)
        end
    end)
    
    -- Tooltip
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
    
    slider.getValue = getValue
    slider.setValue = setValue
    slider.valueLabel = valueLabel
    slider.suffix = suffix or ""
    
    return slider
end

function GeneralPanel:CreateDropdown(parent, text, x, y, values, labels, getValue, setValue, tooltip)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 0)
    label:SetText(text)
    
    -- Initialize dropdown
    UIDropDownMenu_SetWidth(dropdown, 120)
    
    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        if addon.GIS.IsAvailable() then
            setValue(values[self:GetID()])
        end
    end
    
    local function Initialize()
        local selectedValue = addon.GIS.IsAvailable() and getValue() or values[1]
        
        for i, value in ipairs(values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = labels[i]
            info.value = value
            info.func = OnClick
            info.checked = (value == selectedValue)
            UIDropDownMenu_AddButton(info)
        end
    end
    
    UIDropDownMenu_Initialize(dropdown, Initialize)
    
    -- Set initial selection
    if addon.GIS.IsAvailable() then
        local currentValue = getValue()
        for i, value in ipairs(values) do
            if value == currentValue then
                UIDropDownMenu_SetSelectedID(dropdown, i)
                break
            end
        end
    else
        UIDropDownMenu_SetText(dropdown, "N/A")
        UIDropDownMenu_DisableDropDown(dropdown)
    end
    
    -- Tooltip
    if tooltip then
        dropdown:SetScript("OnEnter", function()
            GameTooltip:SetOwner(dropdown, "ANCHOR_RIGHT")
            GameTooltip:SetText(text)
            GameTooltip:AddLine(tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        dropdown:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    dropdown.getValue = getValue
    dropdown.setValue = setValue
    dropdown.values = values
    dropdown.labels = labels
    
    return dropdown
end

function GeneralPanel:RefreshValues()
    if not self.controls then return end
    
    for _, control in ipairs(self.controls) do
        if control.getValue then
            if control.SetChecked then
                -- Checkbox
                control:SetChecked(addon.GIS.IsAvailable() and control.getValue() or false)
                control:SetEnabled(addon.GIS.IsAvailable())
            elseif control.SetValue then
                -- Slider
                if addon.GIS.IsAvailable() then
                    local value = control.getValue()
                    control:SetValue(value)
                    control.valueLabel:SetText(value .. control.suffix)
                    control:SetEnabled(true)
                else
                    control:SetEnabled(false)
                    control.valueLabel:SetText("N/A")
                end
            elseif control.values then
                -- Dropdown
                if addon.GIS.IsAvailable() then
                    local currentValue = control.getValue()
                    for i, value in ipairs(control.values) do
                        if value == currentValue then
                            UIDropDownMenu_SetSelectedID(control, i)
                            break
                        end
                    end
                    UIDropDownMenu_EnableDropDown(control)
                else
                    UIDropDownMenu_SetText(control, "N/A")
                    UIDropDownMenu_DisableDropDown(control)
                end
            end
        end
    end
end