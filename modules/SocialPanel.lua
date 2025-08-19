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
    return self.panel
end

function SocialPanel:CreatePanel(parent)
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -25, 0)
    
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(400, 400)
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
    yOffset = yOffset - 45
    
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