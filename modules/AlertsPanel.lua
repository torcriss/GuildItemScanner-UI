-- AlertsPanel.lua - Alert settings panel for GuildItemScanner-UI

local addonName, addon = ...

local AlertsPanel = {}
addon:RegisterModule("AlertsPanel", AlertsPanel)

function AlertsPanel:Initialize()
    -- Panel will be created on demand
end

function AlertsPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function AlertsPanel:CreatePanel(parent)
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
    title:SetText("Alert Settings")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 30
    
    -- Recipe alerts
    self:CreateCheckbox(content, "Recipe Alerts", 10, yOffset,
        function() return addon.GIS.Get("recipeAlert") end,
        function(checked) addon.GIS.Set("recipeAlert", checked) end,
        "Show alerts for recipes matching your professions"
    )
    yOffset = yOffset - 35
    
    -- Material alerts section
    local matTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    matTitle:SetPoint("TOPLEFT", 10, yOffset)
    matTitle:SetText("Material Alerts")
    matTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    self:CreateCheckbox(content, "Enable Material Alerts", 10, yOffset,
        function() return addon.GIS.Get("materialAlert") end,
        function(checked) addon.GIS.Set("materialAlert", checked) end,
        "Show alerts for crafting materials"
    )
    yOffset = yOffset - 35
    
    -- Material rarity filter
    local rarityDropdown = self:CreateDropdown(content, "Rarity Filter", 30, yOffset,
        {"common", "rare", "epic", "legendary"},
        {"Common+", "Rare+", "Epic+", "Legendary"},
        function() return addon.GIS.Get("materialRarityFilter") or "common" end,
        function(value) addon.GIS.Set("materialRarityFilter", value) end,
        "Minimum rarity for material alerts"
    )
    yOffset = yOffset - 50
    
    -- Material quantity threshold
    self:CreateSlider(content, "Quantity Threshold", 30, yOffset, 1, 20,
        function() return addon.GIS.Get("materialQuantityThreshold") or 1 end,
        function(value) addon.GIS.Set("materialQuantityThreshold", value) end,
        "Minimum stack size for material alerts",
        " items"
    )
    yOffset = yOffset - 60
    
    -- Bag alerts section
    local bagTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bagTitle:SetPoint("TOPLEFT", 10, yOffset)
    bagTitle:SetText("Bag Alerts")
    bagTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    self:CreateCheckbox(content, "Enable Bag Alerts", 10, yOffset,
        function() return addon.GIS.Get("bagAlert") end,
        function(checked) addon.GIS.Set("bagAlert", checked) end,
        "Show alerts for storage bags"
    )
    yOffset = yOffset - 35
    
    -- Bag size filter
    self:CreateSlider(content, "Minimum Bag Size", 30, yOffset, 6, 18,
        function() return addon.GIS.Get("bagSizeFilter") or 6 end,
        function(value) addon.GIS.Set("bagSizeFilter", value) end,
        "Minimum number of slots for bag alerts",
        " slots"
    )
    yOffset = yOffset - 60
    
    -- Potion alerts section
    local potionTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    potionTitle:SetPoint("TOPLEFT", 10, yOffset)
    potionTitle:SetText("Potion Alerts")
    potionTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    self:CreateCheckbox(content, "Enable Potion Alerts", 10, yOffset,
        function() return addon.GIS.Get("potionAlert") end,
        function(checked) addon.GIS.Set("potionAlert", checked) end,
        "Show alerts for potions and consumables"
    )
    yOffset = yOffset - 35
    
    panel:Hide()
    return panel
end

function AlertsPanel:CreateCheckbox(parent, text, x, y, getValue, setValue, tooltip)
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

function AlertsPanel:CreateSlider(parent, text, x, y, minVal, maxVal, getValue, setValue, tooltip, suffix)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetSize(200, 16)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    
    local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 5)
    label:SetText(text)
    
    local valueLabel = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueLabel:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 5)
    
    slider.Low:SetText(minVal)
    slider.High:SetText(maxVal)
    
    if addon.GIS.IsAvailable() then
        local value = getValue()
        slider:SetValue(value)
        valueLabel:SetText(value .. (suffix or ""))
    else
        slider:SetEnabled(false)
        valueLabel:SetText("N/A")
    end
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        valueLabel:SetText(value .. (suffix or ""))
        if addon.GIS.IsAvailable() then
            setValue(value)
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

function AlertsPanel:CreateDropdown(parent, text, x, y, values, labels, getValue, setValue, tooltip)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 0)
    label:SetText(text)
    
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
    
    return dropdown
end