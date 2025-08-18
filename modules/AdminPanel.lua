-- AdminPanel.lua - Admin tools and testing panel

local addonName, addon = ...

local AdminPanel = {}
addon:RegisterModule("AdminPanel", AdminPanel)

function AdminPanel:Initialize()
end

function AdminPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    -- Clear status when panel is accessed
    self:SetStatus("Ready")
    return self.panel
end

function AdminPanel:CreatePanel(parent)
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
    title:SetText("Admin Tools")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 30
    
    -- Description
    local desc = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 10, yOffset)
    desc:SetWidth(350)
    desc:SetJustifyH("LEFT")
    desc:SetText("Testing and debugging tools for GuildItemScanner")
    yOffset = yOffset - 40
    
    -- Debug section
    local debugTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugTitle:SetPoint("TOPLEFT", 10, yOffset)
    debugTitle:SetText("Debug Settings")
    debugTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 30
    
    -- Debug mode checkbox
    self:CreateCheckbox(content, "Debug Mode", 10, yOffset,
        function() return addon.GIS.Get("debugMode") end,
        function(checked) addon.GIS.Set("debugMode", checked) end,
        "Show detailed debug information in chat"
    )
    yOffset = yOffset - 40
    
    -- Testing section
    local testTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testTitle:SetPoint("TOPLEFT", 10, yOffset)
    testTitle:SetText("Testing Tools")
    testTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 30
    
    -- Smoketest button
    local smokeTestButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    smokeTestButton:SetSize(150, 30)
    smokeTestButton:SetPoint("TOPLEFT", 10, yOffset)
    smokeTestButton:SetText("Run Smoke Test")
    smokeTestButton:SetScript("OnClick", function()
        self:RunSmokeTest()
    end)
    
    -- Add tooltip
    smokeTestButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(smokeTestButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Run Smoke Test")
        GameTooltip:AddLine("Executes '/gis smoketest' to test GuildItemScanner functionality", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    smokeTestButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    yOffset = yOffset - 50
    
    -- Status display
    local statusTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusTitle:SetPoint("TOPLEFT", 10, yOffset)
    statusTitle:SetText("Status")
    statusTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    local statusText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusText:SetPoint("TOPLEFT", 10, yOffset)
    statusText:SetWidth(350)
    statusText:SetJustifyH("LEFT")
    statusText:SetText("Ready")
    self.statusText = statusText
    
    panel:Hide()
    return panel
end

function AdminPanel:RunSmokeTest()
    if not addon.GIS.IsAvailable() then
        self:SetStatus("|cffff0000GuildItemScanner not available|r")
        return
    end
    
    self:SetStatus("|cffffff00Running smoke test...|r")
    
    -- Execute the smoketest command
    local success = addon.GIS.SafeCall(function()
        -- Try to run the smoketest command
        SlashCmdList["GUILDITEMSCANNER"]("smoketest")
        return true
    end)
    
    if success then
        self:SetStatus("|cff00ff00Smoke test executed successfully|r")
    else
        self:SetStatus("|cffff0000Failed to run smoke test|r")
    end
end

function AdminPanel:SetStatus(message)
    if self.statusText then
        self.statusText:SetText(message)
    end
end

function AdminPanel:CreateCheckbox(parent, text, x, y, getValue, setValue, tooltip)
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
    
    return check
end