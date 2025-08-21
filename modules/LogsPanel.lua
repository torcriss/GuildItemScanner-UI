-- LogsPanel.lua - Guild message logs viewer panel for GuildItemScanner-UI

local addonName, addon = ...

local LogsPanel = {}
addon:RegisterModule("LogsPanel", LogsPanel)

function LogsPanel:Initialize()
end

function LogsPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    -- Auto-refresh logs whenever the panel is accessed
    self:RefreshLogs()
    return self.panel
end

function LogsPanel:CreatePanel(parent)
    local panel = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -25, 0)
    
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(500, 1200)
    panel:SetScrollChild(content)
    
    self.panel = panel
    self.content = content
    
    local yOffset = -20
    
    -- Title
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, yOffset)
    title:SetText("Guild Message Logs")
    title:SetTextColor(1, 0.8, 0)
    
    -- Refresh button
    local refreshButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshButton:SetSize(70, 25)
    refreshButton:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, yOffset + 5)
    refreshButton:SetText("Refresh")
    refreshButton:SetScript("OnClick", function()
        self:RefreshLogs()
    end)
    self.refreshButton = refreshButton
    
    yOffset = yOffset - 35
    
    -- Statistics display
    local statsLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsLabel:SetPoint("TOPLEFT", 10, yOffset)
    statsLabel:SetText("Statistics:")
    statsLabel:SetTextColor(0.9, 0.9, 0.9)
    
    local statsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statsText:SetPoint("TOPLEFT", 10, yOffset - 15)
    statsText:SetWidth(480)
    statsText:SetJustifyH("LEFT")
    statsText:SetText("Loading statistics...")
    self.statsText = statsText
    
    yOffset = yOffset - 45
    
    -- Message log container
    self.logsContainer = content
    self.logsStartY = yOffset
    
    
    -- Initial load
    self:RefreshLogs()
    
    panel:Hide()
    return panel
end


function LogsPanel:RefreshLogs()
    -- Clear existing log display
    if self.logFrames then
        for _, frame in ipairs(self.logFrames) do
            frame:Hide()
        end
    end
    self.logFrames = {}
    
    if not addon.GIS.IsAvailable() then
        local noGISFrame = self:CreateLogEntry(
            "|cffff0000GuildItemScanner not available|r",
            nil
        )
        noGISFrame:SetPoint("TOPLEFT", self.logsContainer, "TOPLEFT", 10, self.logsStartY)
        table.insert(self.logFrames, noGISFrame)
        return
    end
    
    -- Get message log and stats
    local messageLog = addon.GIS.GetMessageLog()
    local stats = addon.GIS.GetMessageLogStats()
    
    -- Update statistics
    if self.statsText then
        local statsDisplay = string.format(
            "Total: %d/%d messages | Oldest: %s | Newest: %s",
            stats.totalEntries or 0,
            stats.maxEntries or 200,
            stats.oldestEntry or "None",
            stats.newestEntry or "None"
        )
        self.statsText:SetText("|cff888888" .. statsDisplay .. "|r")
    end
    
    if not messageLog or #messageLog == 0 then
        local noLogsFrame = self:CreateLogEntry(
            "|cff808080No message logs found|r",
            nil
        )
        noLogsFrame:SetPoint("TOPLEFT", self.logsContainer, "TOPLEFT", 10, self.logsStartY)
        table.insert(self.logFrames, noLogsFrame)
        return
    end
    
    -- Display entries
    local yOffset = self.logsStartY
    
    for i, entry in ipairs(messageLog) do
        if i <= 200 then -- Display all available logs (up to max storage)
            local frame = self:CreateMessageEntry(entry, i)
            frame:SetPoint("TOPLEFT", self.logsContainer, "TOPLEFT", 10, yOffset)
            table.insert(self.logFrames, frame)
            yOffset = yOffset - 60 -- Space between entries
        end
    end
    
    -- Update content height for scrolling
    local totalHeight = math.abs(yOffset) + 200
    self.content:SetHeight(totalHeight)
end


function LogsPanel:CreateMessageEntry(entry, index)
    local frame = CreateFrame("Frame", nil, self.logsContainer)
    frame:SetSize(480, 55)
    
    -- Background for clickable area
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Time display
    local timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetPoint("TOPLEFT", 5, -2)
    timeText:SetText("|cff888888" .. (entry.time or "??:??:??") .. "|r")
    
    -- Sender name
    local senderText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    senderText:SetPoint("TOPLEFT", 5, -18)
    senderText:SetWidth(100)
    senderText:SetJustifyH("LEFT")
    senderText:SetText("|cff00ff00" .. (entry.sender or "Unknown") .. "|r")
    
    -- Message preview
    local messageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    messageText:SetPoint("TOPLEFT", 110, -18)
    messageText:SetWidth(280)
    messageText:SetJustifyH("LEFT")
    local messagePreview = self:CleanMessageForDisplay(entry.message or "")
    if string.len(messagePreview) > 60 then
        messagePreview = string.sub(messagePreview, 1, 60) .. "..."
    end
    messageText:SetText("|cffffffff" .. messagePreview .. "|r")
    
    -- Status indicators
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("TOPLEFT", 110, -40)
    statusText:SetWidth(280)
    statusText:SetJustifyH("LEFT")
    
    local statusParts = {}
    if entry.itemCount and entry.itemCount > 0 then
        table.insert(statusParts, "|cffcfe2ffItems:" .. entry.itemCount .. "|r")
    end
    if entry.wasWTB then
        table.insert(statusParts, "|cffffff00WTB|r")
    end
    if entry.wasFiltered then
        table.insert(statusParts, "|cffff8000Filtered|r")
    end
    if entry.alertType then
        local alertColor = self:GetAlertTypeColor(entry.alertType)
        table.insert(statusParts, alertColor .. string.upper(entry.alertType) .. "|r")
    end
    
    statusText:SetText(table.concat(statusParts, " "))
    
    -- Make clickable for tooltip
    frame:EnableMouse(true)
    
    -- Highlight on hover
    frame:SetScript("OnEnter", function()
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
        
        -- Show tooltip with full message
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Guild Message Details:")
        GameTooltip:AddLine("Time: " .. (entry.time or "Unknown"), 1, 1, 1, false)
        GameTooltip:AddLine("Sender: " .. (entry.sender or "Unknown"), 0.5, 1, 0.5, false)
        GameTooltip:AddLine("Message:", 1, 1, 1, false)
        GameTooltip:AddLine(entry.message or "", 1, 1, 1, true)
        if entry.itemCount and entry.itemCount > 0 then
            GameTooltip:AddLine("Items detected: " .. entry.itemCount, 0.5, 0.5, 1, false)
        end
        if entry.wasWTB then
            GameTooltip:AddLine("Identified as WTB request", 1, 1, 0, false)
        end
        if entry.wasFiltered then
            GameTooltip:AddLine("Message was filtered", 1, 0.5, 0, false)
        end
        if entry.alertType then
            GameTooltip:AddLine("Alert triggered: " .. entry.alertType, 1, 0, 0, false)
        end
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        GameTooltip:Hide()
    end)
    
    return frame
end

function LogsPanel:CreateLogEntry(text, data)
    local frame = CreateFrame("Frame", nil, self.logsContainer)
    frame:SetSize(480, 25)
    
    local textDisplay = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textDisplay:SetPoint("TOPLEFT", 5, -5)
    textDisplay:SetWidth(470)
    textDisplay:SetJustifyH("LEFT")
    textDisplay:SetText(text)
    
    return frame
end

function LogsPanel:CleanMessageForDisplay(message)
    if not message or message == "" then
        return ""
    end
    
    -- Convert item links to readable names
    local cleanMessage = message
    -- Convert |H....|h[Item Name]|h to just [Item Name]
    cleanMessage = string.gsub(cleanMessage, "|H([^|]*)|h(%[([^%]]*)%])|h", "%2")
    -- Remove color codes
    cleanMessage = string.gsub(cleanMessage, "|c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]", "")
    cleanMessage = string.gsub(cleanMessage, "|r", "")
    
    return cleanMessage
end

function LogsPanel:GetAlertTypeColor(alertType)
    local colors = {
        recipe = "|cff9d4edd",      -- Purple for recipes
        material = "|cffff6700",   -- Orange for materials
        bag = "|cff40e0d0",        -- Turquoise for bags
        potion = "|cff32cd32",     -- Lime green for potions
        equipment = "|cffff1493"   -- Deep pink for equipment
    }
    return colors[alertType] or "|cffffffff"
end