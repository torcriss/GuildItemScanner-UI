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
    -- Update whisper mode status when panel is accessed
    self:UpdateWhisperModeStatus()
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
    
    -- Whisper mode status indicator
    local whisperStatus = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whisperStatus:SetPoint("TOPLEFT", 10, yOffset)
    whisperStatus:SetWidth(380)
    whisperStatus:SetJustifyH("LEFT")
    self.whisperStatus = whisperStatus
    
    yOffset = yOffset - 25
    
    -- History list container
    self.historyContainer = content
    self.historyStartY = yOffset
    
    -- Initial load
    self:RefreshHistory()
    -- Initial whisper mode status update
    self:UpdateWhisperModeStatus()
    
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
    
    -- Hide the "more entries" label
    if self.moreEntriesLabel then
        self.moreEntriesLabel:Hide()
    end
    
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
    
    -- Display history entries with limit
    local MAX_DISPLAY = 20  -- Limit display to 20 entries for performance
    local totalEntries = #history
    local displayedEntries = math.min(MAX_DISPLAY, totalEntries)
    
    local yOffset = self.historyStartY
    for i = 1, displayedEntries do
        local entry = history[i]
        local frame = self:CreateHistoryEntry(entry, yOffset)
        table.insert(self.historyFrames, frame)
        yOffset = yOffset - 60  -- Space for each entry
    end
    
    -- Add "showing X of Y" message if there are more entries
    if totalEntries > MAX_DISPLAY then
        self:ShowMoreMessage(totalEntries, displayedEntries, yOffset)
        yOffset = yOffset - 30  -- Space for the message
    end
    
    -- Update content size for scrolling
    self.content:SetHeight(math.max(600, math.abs(yOffset) + 50))
end

function HistoryPanel:CreateHistoryEntry(entry, yOffset)
    -- Create as button to make it clickable
    local frame = CreateFrame("Button", nil, self.historyContainer)
    frame:SetSize(350, 55)
    frame:SetPoint("TOPLEFT", 10, yOffset)
    frame:EnableMouse(true)
    
    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Highlight texture for hover effect
    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.2, 0.2, 0.2, 0.5)
    
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
    
    -- Click handler for whisper functionality
    frame:SetScript("OnClick", function()
        self:SendWhisper(entry)
    end)
    
    -- Tooltip for click functionality
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to whisper player")
        GameTooltip:AddLine("Will ask: Is this " .. (entry.item or "item") .. " still available. I could use it, if no one needs.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return frame
end

function HistoryPanel:SendWhisper(entry)
    -- Validate entry data
    if not entry or not entry.player or not entry.item then
        print("|cffff0000[GIS-UI]|r Invalid history entry for whisper")
        return
    end
    
    -- Check if GIS is available to respect whisper settings
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    -- Get whisper mode setting from GIS (same pattern as GIS alerts)
    local whisperMode = addon.GIS.Get("whisperMode")
    local channel = whisperMode and "WHISPER" or "GUILD"
    local target = whisperMode and entry.player or nil
    
    -- Create the whisper message using the requested format
    local msg = "Is this " .. entry.item .. " still available. I could use it, if no one needs."
    
    -- Send the message
    SendChatMessage(msg, channel, nil, target)
    
    -- Provide feedback to user
    if whisperMode then
        print("|cff00ff00[GIS-UI]|r Whispered " .. entry.player .. " about " .. entry.item)
    else
        print("|cff00ff00[GIS-UI]|r Asked guild about " .. entry.item)
    end
end

function HistoryPanel:UpdateWhisperModeStatus()
    if not self.whisperStatus then return end
    
    if addon.GIS.IsAvailable() then
        local whisperMode = addon.GIS.Get("whisperMode")
        if whisperMode then
            self.whisperStatus:SetText("|cff00ff00Request Mode: WHISPER|r (Messages sent directly to player)")
        else
            self.whisperStatus:SetText("|cffffff00Request Mode: GUILD|r (Messages sent to guild channel)")
        end
    else
        self.whisperStatus:SetText("|cffff0000GuildItemScanner not available|r")
    end
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

function HistoryPanel:ShowMoreMessage(totalEntries, displayedEntries, yOffset)
    -- Create or reuse the "more entries" label
    if not self.moreEntriesLabel then
        self.moreEntriesLabel = self.historyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.moreEntriesLabel:SetWidth(350)
        self.moreEntriesLabel:SetJustifyH("CENTER")
    end
    
    local hiddenEntries = totalEntries - displayedEntries
    local message = string.format("|cff888888Showing %d of %d alerts (%d more available)|r", 
                                 displayedEntries, totalEntries, hiddenEntries)
    
    self.moreEntriesLabel:SetText(message)
    self.moreEntriesLabel:ClearAllPoints()
    self.moreEntriesLabel:SetPoint("TOPLEFT", 10, yOffset)
    self.moreEntriesLabel:Show()
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