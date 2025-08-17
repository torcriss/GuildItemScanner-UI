-- MaterialsPanel.lua - Custom materials management panel

local addonName, addon = ...

local MaterialsPanel = {}
addon:RegisterModule("MaterialsPanel", MaterialsPanel)

function MaterialsPanel:Initialize()
end

function MaterialsPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function MaterialsPanel:CreatePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    self.panel = panel
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -20)
    title:SetText("Custom Materials")
    title:SetTextColor(1, 0.8, 0)
    
    -- Info text
    local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOPLEFT", 10, -60)
    info:SetWidth(350)
    info:SetJustifyH("LEFT")
    info:SetText("Custom materials feature allows you to add items not in the default database.")
    
    -- Coming soon notice
    local notice = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    notice:SetPoint("CENTER", panel, "CENTER", 0, 0)
    notice:SetText("Custom Materials Panel\n\nComing Soon!")
    notice:SetTextColor(1, 1, 0)
    
    panel:Hide()
    return panel
end