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
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    self.panel = panel
    
    local yOffset = -20
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("Social Features")
    title:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 30
    
    -- Warning about Frontier requirement
    local warning = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    warning:SetPoint("TOPLEFT", 10, yOffset)
    warning:SetWidth(350)
    warning:SetJustifyH("LEFT")
    warning:SetText("|cffff8000Warning:|r Social features require the Frontier addon to function.")
    yOffset = yOffset - 40
    
    -- Auto-GZ section
    local gzTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gzTitle:SetPoint("TOPLEFT", 10, yOffset)
    gzTitle:SetText("Auto-Congratulations (GZ)")
    gzTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    local gzCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    gzCheck:SetPoint("TOPLEFT", 10, yOffset)
    gzCheck:SetSize(24, 24)
    
    local gzLabel = gzCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gzLabel:SetPoint("LEFT", gzCheck, "RIGHT", 5, 0)
    gzLabel:SetText("Enable Auto-GZ")
    
    if addon.GIS.IsAvailable() then
        gzCheck:SetChecked(addon.GIS.Get("autoGZ"))
    else
        gzCheck:SetEnabled(false)
    end
    
    gzCheck:SetScript("OnClick", function(self)
        if addon.GIS.IsAvailable() then
            addon.GIS.Set("autoGZ", self:GetChecked())
        end
    end)
    
    yOffset = yOffset - 40
    
    -- Auto-RIP section
    local ripTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ripTitle:SetPoint("TOPLEFT", 10, yOffset)
    ripTitle:SetText("Auto-Condolences (RIP)")
    ripTitle:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 25
    
    local ripCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    ripCheck:SetPoint("TOPLEFT", 10, yOffset)
    ripCheck:SetSize(24, 24)
    
    local ripLabel = ripCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ripLabel:SetPoint("LEFT", ripCheck, "RIGHT", 5, 0)
    ripLabel:SetText("Enable Auto-RIP")
    
    if addon.GIS.IsAvailable() then
        ripCheck:SetChecked(addon.GIS.Get("autoRIP"))
    else
        ripCheck:SetEnabled(false)
    end
    
    ripCheck:SetScript("OnClick", function(self)
        if addon.GIS.IsAvailable() then
            addon.GIS.Set("autoRIP", self:GetChecked())
        end
    end)
    
    yOffset = yOffset - 60
    
    -- More features notice
    local notice = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    notice:SetPoint("TOPLEFT", 10, yOffset)
    notice:SetText("Additional social features (custom messages, chances)\nwill be available in future updates.")
    notice:SetTextColor(1, 1, 0)
    
    panel:Hide()
    return panel
end