-- HistoryPanel.lua - Alert history viewer panel

local addonName, addon = ...

local HistoryPanel = {}
addon:RegisterModule("HistoryPanel", HistoryPanel)

function HistoryPanel:Initialize()
end

function HistoryPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    return self.panel
end

function HistoryPanel:CreatePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    self.panel = panel
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -20)
    title:SetText("Alert History")
    title:SetTextColor(1, 0.8, 0)
    
    -- Info text
    local info = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOPLEFT", 10, -60)
    info:SetWidth(350)
    info:SetJustifyH("LEFT")
    info:SetText("View recent alerts and search through alert history.")
    
    -- Coming soon notice
    local notice = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    notice:SetPoint("CENTER", panel, "CENTER", 0, 0)
    notice:SetText("Alert History Viewer\n\nComing Soon!")
    notice:SetTextColor(1, 1, 0)
    
    panel:Hide()
    return panel
end