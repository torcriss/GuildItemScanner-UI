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
    content:SetSize(400, 800)
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
    
    -- Filter section
    local filterLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    filterLabel:SetPoint("TOPLEFT", 10, yOffset)
    filterLabel:SetText("Filters:")
    filterLabel:SetTextColor(0.9, 0.9, 0.9)
    
    yOffset = yOffset - 25
    
    -- Filter buttons row 1
    self.filterAll = self:CreateFilterButton(content, "All", 10, yOffset, true)
    self.filterWTB = self:CreateFilterButton(content, "WTB", 60, yOffset, false)
    self.filterFiltered = self:CreateFilterButton(content, "Filtered", 110, yOffset, false)
    self.filterAlerts = self:CreateFilterButton(content, "Alerts", 170, yOffset, false)
    
    yOffset = yOffset - 30
    
    -- Filter buttons row 2 (alert types)
    self.filterRecipe = self:CreateFilterButton(content, "Recipe", 10, yOffset, false)
    self.filterMaterial = self:CreateFilterButton(content, "Material", 70, yOffset, false)
    self.filterBag = self:CreateFilterButton(content, "Bag", 140, yOffset, false)
    self.filterPotion = self:CreateFilterButton(content, "Potion", 180, yOffset, false)
    self.filterEquipment = self:CreateFilterButton(content, "Equipment", 230, yOffset, false)
    
    yOffset = yOffset - 40
    
    -- Statistics display
    local statsLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsLabel:SetPoint("TOPLEFT", 10, yOffset)
    statsLabel:SetText("Statistics:")
    statsLabel:SetTextColor(0.9, 0.9, 0.9)
    
    local statsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statsText:SetPoint("TOPLEFT", 10, yOffset - 15)
    statsText:SetWidth(380)
    statsText:SetJustifyH("LEFT")
    statsText:SetText("Loading statistics...")
    self.statsText = statsText
    
    yOffset = yOffset - 45
    
    -- Message log container
    self.logsContainer = content
    self.logsStartY = yOffset
    
    -- Track current filter
    self.currentFilter = "all"
    
    -- Initial load
    self:RefreshLogs()
    
    panel:Hide()
    return panel
end

function LogsPanel:CreateFilterButton(parent, text, x, y, selected)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(50, 20)
    button:SetPoint("TOPLEFT", x, y)
    button:SetText(text)
    
    -- Color based on selection
    if selected then
        button:GetFontString():SetTextColor(1, 1, 0) -- Yellow for selected
    else
        button:GetFontString():SetTextColor(1, 1, 1) -- White for unselected
    end
    
    button:SetScript("OnClick", function()
        self:SetFilter(string.lower(text))
    end)
    
    return button
end

function LogsPanel:SetFilter(filterType)
    -- Update button colors
    local buttons = {
        ["all"] = self.filterAll,
        ["wtb"] = self.filterWTB,
        ["filtered"] = self.filterFiltered,
        ["alerts"] = self.filterAlerts,
        ["recipe"] = self.filterRecipe,
        ["material"] = self.filterMaterial,
        ["bag"] = self.filterBag,
        ["potion"] = self.filterPotion,
        ["equipment"] = self.filterEquipment
    }
    
    for filter, button in pairs(buttons) do
        if filter == filterType then
            button:GetFontString():SetTextColor(1, 1, 0) -- Yellow for selected
        else
            button:GetFontString():SetTextColor(1, 1, 1) -- White for unselected
        end
    end
    
    self.currentFilter = filterType
    self:RefreshLogs()
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
    
    -- Filter messages based on current filter
    local filteredMessages = self:FilterMessages(messageLog)
    
    if #filteredMessages == 0 then
        local noMatchFrame = self:CreateLogEntry(
            "|cff808080No messages match the current filter|r",
            nil
        )
        noMatchFrame:SetPoint("TOPLEFT", self.logsContainer, "TOPLEFT", 10, self.logsStartY)
        table.insert(self.logFrames, noMatchFrame)
        return
    end
    
    -- Display filtered entries
    local yOffset = self.logsStartY
    
    for i, entry in ipairs(filteredMessages) do
        if i <= 50 then -- Limit display to prevent UI lag
            local frame = self:CreateMessageEntry(entry, i)
            frame:SetPoint("TOPLEFT", self.logsContainer, "TOPLEFT", 10, yOffset)
            table.insert(self.logFrames, frame)
            yOffset = yOffset - 35 -- Space between entries
        end
    end
    
    -- Update content height for scrolling
    local totalHeight = math.abs(yOffset) + 200
    self.content:SetHeight(totalHeight)
end

function LogsPanel:FilterMessages(messageLog)
    local filtered = {}
    
    for _, entry in ipairs(messageLog) do
        local include = false
        
        if self.currentFilter == "all" then
            include = true
        elseif self.currentFilter == "wtb" then
            include = entry.wasWTB
        elseif self.currentFilter == "filtered" then
            include = entry.wasFiltered
        elseif self.currentFilter == "alerts" then
            include = entry.alertType ~= nil
        else
            -- Specific alert type
            include = entry.alertType == self.currentFilter
        end
        
        if include then
            table.insert(filtered, entry)
        end
    end
    
    return filtered
end

function LogsPanel:CreateMessageEntry(entry, index)
    local frame = CreateFrame("Frame", nil, self.logsContainer)
    frame:SetSize(380, 30)
    
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
    senderText:SetPoint("TOPLEFT", 5, -15)
    senderText:SetWidth(80)
    senderText:SetJustifyH("LEFT")
    senderText:SetText("|cff00ff00" .. (entry.sender or "Unknown") .. "|r")
    
    -- Message preview
    local messageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    messageText:SetPoint("TOPLEFT", 90, -15)
    messageText:SetWidth(200)
    messageText:SetJustifyH("LEFT")
    local messagePreview = entry.message or ""
    if string.len(messagePreview) > 45 then
        messagePreview = string.sub(messagePreview, 1, 45) .. "..."
    end
    messageText:SetText("|cffffffff" .. messagePreview .. "|r")
    
    -- Status indicators
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("TOPRIGHT", -5, -2)
    statusText:SetWidth(80)
    statusText:SetJustifyH("RIGHT")
    
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
    frame:SetSize(380, 25)
    
    local textDisplay = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textDisplay:SetPoint("TOPLEFT", 5, -5)
    textDisplay:SetWidth(370)
    textDisplay:SetJustifyH("LEFT")
    textDisplay:SetText(text)
    
    return frame
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