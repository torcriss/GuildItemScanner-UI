-- SocialHistoryPanel.lua - Social history panel for GuildItemScanner-UI

local addonName, addon = ...

local SocialHistoryPanel = {}
addon:RegisterModule("SocialHistoryPanel", SocialHistoryPanel)

function SocialHistoryPanel:Initialize()
    -- Panel will be created on demand
end

function SocialHistoryPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    -- Auto-refresh social history whenever the panel is accessed
    self:RefreshSocialHistory()
    return self.panel
end

function SocialHistoryPanel:CreatePanel(parent)
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
    title:SetText("Social History")
    title:SetTextColor(1, 0.8, 0)
    
    -- Refresh button
    local refreshButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshButton:SetSize(70, 25)
    refreshButton:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, yOffset + 5)
    refreshButton:SetText("Refresh")
    refreshButton:SetScript("OnClick", function()
        self:RefreshSocialHistory()
    end)
    self.refreshButton = refreshButton
    
    yOffset = yOffset - 35
    
    -- Clear Social History button
    local clearButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearButton:SetSize(120, 25)
    clearButton:SetPoint("TOPLEFT", 10, yOffset)
    clearButton:SetText("Clear Social History")
    clearButton:SetScript("OnClick", function()
        self:ClearSocialHistory()
    end)
    self.clearButton = clearButton
    
    yOffset = yOffset - 40
    
    -- Add info label about display limit
    local limitInfo = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    limitInfo:SetPoint("TOPLEFT", 10, yOffset)
    limitInfo:SetText("|cff888888Showing latest 20 social events|r")
    self.limitInfo = limitInfo
    
    yOffset = yOffset - 20
    
    -- Social history list container
    self.socialHistoryContainer = content
    self.socialHistoryStartY = yOffset
    
    -- Initial load
    self:RefreshSocialHistory()
    
    panel:Hide()
    return panel
end

function SocialHistoryPanel:RefreshSocialHistory()
    -- Clear existing social history display
    if self.socialHistoryFrames then
        for _, frame in ipairs(self.socialHistoryFrames) do
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    self.socialHistoryFrames = {}
    
    -- Hide the "more entries" label
    if self.moreEntriesLabel then
        self.moreEntriesLabel:Hide()
    end
    
    -- Check if GIS is available
    if not addon.GIS.IsAvailable() then
        self:ShowMessage("GuildItemScanner not available")
        return
    end
    
    -- Get social history data
    local socialHistory = addon.GIS.GetSocialHistory()
    
    if not socialHistory or #socialHistory == 0 then
        local message = "No social history found"
        if not addon.GIS.IsAvailable() then
            message = "GuildItemScanner not available"
        end
        self:ShowMessage(message)
        return
    end
    
    -- Hide the message label when we have social history to display
    if self.messageLabel then
        self.messageLabel:Hide()
    end
    
    -- Show the limit info label when we have social history
    if self.limitInfo then
        self.limitInfo:Show()
    end
    
    -- Display social history entries with limit
    local MAX_DISPLAY = 20  -- Limit display to 20 entries for performance
    local totalEntries = #socialHistory
    local displayedEntries = math.min(MAX_DISPLAY, totalEntries)
    
    local yOffset = self.socialHistoryStartY
    for i = 1, displayedEntries do
        local entry = socialHistory[i]
        local frame = self:CreateSocialHistoryEntry(entry, yOffset)
        table.insert(self.socialHistoryFrames, frame)
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

function SocialHistoryPanel:CreateSocialHistoryEntry(entry, yOffset)
    -- Create as button to make it clickable
    local frame = CreateFrame("Button", nil, self.socialHistoryContainer)
    frame:SetSize(350, 55)
    frame:SetPoint("TOPLEFT", 10, yOffset)
    frame:EnableMouse(true)
    
    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Color code based on event type
    local eventType = entry.eventType or "GZ"
    local typeColor = eventType == "GZ" and {0.1, 0.3, 0.1, 0.3} or {0.3, 0.1, 0.1, 0.3}
    bg:SetColorTexture(unpack(typeColor))
    
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
    local timeStr = entry.timestamp and date("%m/%d %H:%M", entry.timestamp) or entry.time or "Unknown"
    local timestamp = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timestamp:SetPoint("TOPLEFT", 5, -5)
    timestamp:SetText("|cff888888" .. timeStr .. "|r")
    
    -- Event type and message
    local eventText = entry.eventType or "Social"
    local message = entry.message or "Unknown message"
    local eventColor = eventType == "GZ" and "|cff00ff00" or "|cffff4040"
    local eventLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    eventLabel:SetPoint("TOPLEFT", 5, -20)
    eventLabel:SetWidth(250)
    eventLabel:SetJustifyH("LEFT")
    eventLabel:SetText(eventColor .. eventText .. "|r: " .. message)
    
    -- Player name
    local playerName = entry.player or "Unknown"
    local player = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    player:SetPoint("TOPRIGHT", -5, -5)
    player:SetText("|cff00ff00" .. playerName .. "|r")
    
    -- Details (achievement or level)
    local detailsText = ""
    if entry.details then
        if eventType == "GZ" and entry.details.achievement then
            detailsText = "Achievement"
        elseif eventType == "RIP" and entry.details.level then
            detailsText = "Level " .. entry.details.level
        end
    end
    
    if detailsText ~= "" then
        local details = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        details:SetPoint("TOPRIGHT", -5, -35)
        details:SetText("|cff4488ff" .. detailsText .. "|r")
    end
    
    -- Click handler for guild message functionality
    frame:SetScript("OnClick", function()
        self:SendSocialMessage(entry)
    end)
    
    -- Tooltip for click functionality
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to send guild message")
        local messageText = eventType == "GZ" and ("GZ " .. playerName .. "!") or ("RIP " .. playerName)
        GameTooltip:AddLine("Will send: " .. messageText, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return frame
end

function SocialHistoryPanel:SendSocialMessage(entry)
    -- Validate entry data
    if not entry or not entry.player or not entry.eventType then
        print("|cffff0000[GIS-UI]|r Invalid social history entry")
        return
    end
    
    -- Check if GIS is available
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    -- Create appropriate guild message based on event type
    local playerName = entry.player
    local eventType = entry.eventType
    local message
    
    if eventType == "GZ" then
        message = "GZ " .. playerName .. "!"
    elseif eventType == "RIP" then
        message = "RIP " .. playerName
    else
        message = "Hey " .. playerName
    end
    
    -- Send the message to guild
    SendChatMessage(message, "GUILD")
    
    -- Provide feedback to user
    print("|cff00ff00[GIS-UI]|r Sent to guild: " .. message)
end

function SocialHistoryPanel:ShowMessage(message)
    -- Clear existing frames
    if self.socialHistoryFrames then
        for _, frame in ipairs(self.socialHistoryFrames) do
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    self.socialHistoryFrames = {}
    
    -- Hide the limit info label when showing error messages
    if self.limitInfo then
        self.limitInfo:Hide()
    end
    
    -- Show message near the top, after the buttons
    if not self.messageLabel then
        self.messageLabel = self.socialHistoryContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        -- Position it at the same Y as where social history entries would start
        self.messageLabel:SetPoint("TOPLEFT", 10, self.socialHistoryStartY)
        self.messageLabel:SetWidth(350)
        self.messageLabel:SetJustifyH("LEFT")
    end
    
    self.messageLabel:SetText(message)
    self.messageLabel:Show()
end

function SocialHistoryPanel:ShowMoreMessage(totalEntries, displayedEntries, yOffset)
    -- Create or reuse the "more entries" label
    if not self.moreEntriesLabel then
        self.moreEntriesLabel = self.socialHistoryContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.moreEntriesLabel:SetWidth(350)
        self.moreEntriesLabel:SetJustifyH("CENTER")
    end
    
    local hiddenEntries = totalEntries - displayedEntries
    local message = string.format("|cff888888Showing %d of %d social events (%d more available)|r", 
                                 displayedEntries, totalEntries, hiddenEntries)
    
    self.moreEntriesLabel:SetText(message)
    self.moreEntriesLabel:ClearAllPoints()
    self.moreEntriesLabel:SetPoint("TOPLEFT", 10, yOffset)
    self.moreEntriesLabel:Show()
end

function SocialHistoryPanel:ClearSocialHistory()
    -- Confirmation dialog
    StaticPopupDialogs["GIS_UI_CLEAR_SOCIAL_HISTORY"] = {
        text = "Clear all social history?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            if addon.GIS.IsAvailable() then
                local success, msg = addon.GIS.ClearSocialHistory()
                if success then
                    print("|cff00ff00[GIS-UI]|r Social history cleared")
                    SocialHistoryPanel:RefreshSocialHistory()
                else
                    print("|cffff0000[GIS-UI]|r Failed to clear social history: " .. (msg or "Unknown error"))
                end
            else
                print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("GIS_UI_CLEAR_SOCIAL_HISTORY")
end