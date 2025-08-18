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
    -- Auto-refresh history whenever the panel is accessed
    self:RefreshHistory()
    return self.panel
end

function HistoryPanel:CreatePanel(parent)
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
    title:SetText("Alert History")
    title:SetTextColor(1, 0.8, 0)
    
    -- Refresh button
    local refreshButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshButton:SetSize(70, 25)
    refreshButton:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, yOffset + 5)
    refreshButton:SetText("Refresh")
    refreshButton:SetScript("OnClick", function()
        self:RefreshHistory()
    end)
    self.refreshButton = refreshButton
    
    yOffset = yOffset - 35
    
    -- Clear History button
    local clearButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearButton:SetSize(100, 25)
    clearButton:SetPoint("TOPLEFT", 10, yOffset)
    clearButton:SetText("Clear History")
    clearButton:SetScript("OnClick", function()
        self:ClearHistory()
    end)
    self.clearButton = clearButton
    
    yOffset = yOffset - 40
    
    -- History list container
    self.historyContainer = content
    self.historyStartY = yOffset
    
    -- Initial load
    self:RefreshHistory()
    
    panel:Hide()
    return panel
end

function HistoryPanel:RefreshHistory()
    -- Clear existing history display
    if self.historyFrames then
        for _, frame in ipairs(self.historyFrames) do
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    self.historyFrames = {}
    
    -- Check if GIS is available
    if not addon.GIS.IsAvailable() then
        self:ShowMessage("GuildItemScanner not available")
        return
    end
    
    -- Get history data
    local history = addon.GIS.GetHistory()
    
    if not history or #history == 0 then
        local message = "No alert history found"
        if not addon.GIS.IsAvailable() then
            message = "GuildItemScanner not available"
        end
        self:ShowMessage(message)
        return
    end
    
    -- Hide the message label when we have history to display
    if self.messageLabel then
        self.messageLabel:Hide()
    end
    
    -- Display history entries
    local yOffset = self.historyStartY
    for i, entry in ipairs(history) do
        local frame = self:CreateHistoryEntry(entry, yOffset)
        table.insert(self.historyFrames, frame)
        yOffset = yOffset - 60  -- Space for each entry
    end
    
    -- Update content size for scrolling
    self.content:SetHeight(math.max(600, math.abs(yOffset) + 50))
end

function HistoryPanel:CreateHistoryEntry(entry, yOffset)
    local frame = CreateFrame("Frame", nil, self.historyContainer)
    frame:SetSize(350, 55)
    frame:SetPoint("TOPLEFT", 10, yOffset)
    
    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Border
    local border = frame:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetColorTexture(0.3, 0.3, 0.3, 0.5)
    border:SetTexCoord(0, 1, 0, 1)
    
    -- Timestamp
    local timeStr = entry.timestamp and date("%m/%d %H:%M", entry.timestamp) or "Unknown"
    local timestamp = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timestamp:SetPoint("TOPLEFT", 5, -5)
    timestamp:SetText("|cff888888" .. timeStr .. "|r")
    
    -- Item name
    local itemName = entry.itemName or entry.item or "Unknown Item"
    local item = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    item:SetPoint("TOPLEFT", 5, -20)
    item:SetWidth(250)
    item:SetJustifyH("LEFT")
    item:SetText(itemName)
    
    -- Player name
    local playerName = entry.player or entry.sender or "Unknown"
    local player = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    player:SetPoint("TOPRIGHT", -5, -5)
    player:SetText("|cff00ff00" .. playerName .. "|r")
    
    -- Alert type
    local alertType = entry.type or entry.alertType or "Alert"
    local typeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    typeLabel:SetPoint("TOPRIGHT", -5, -35)
    typeLabel:SetText("|cff4488ff" .. alertType .. "|r")
    
    return frame
end

function HistoryPanel:ShowMessage(message)
    -- Clear existing frames
    if self.historyFrames then
        for _, frame in ipairs(self.historyFrames) do
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    self.historyFrames = {}
    
    -- Show message near the top, after the buttons
    if not self.messageLabel then
        self.messageLabel = self.historyContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        -- Position it at the same Y as where history entries would start
        self.messageLabel:SetPoint("TOPLEFT", 10, self.historyStartY)
        self.messageLabel:SetWidth(350)
        self.messageLabel:SetJustifyH("LEFT")
    end
    
    self.messageLabel:SetText(message)
    self.messageLabel:Show()
end

function HistoryPanel:ClearHistory()
    -- Confirmation dialog
    StaticPopupDialogs["GIS_UI_CLEAR_HISTORY"] = {
        text = "Clear all alert history?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            if addon.GIS.IsAvailable() then
                local success = addon.GIS.ClearHistory()
                if success then
                    print("|cff00ff00[GIS-UI]|r Alert history cleared")
                    self:RefreshHistory()
                else
                    print("|cffff0000[GIS-UI]|r Failed to clear history")
                end
            else
                print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    
    StaticPopup_Show("GIS_UI_CLEAR_HISTORY")
end