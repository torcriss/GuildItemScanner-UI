-- WTBHistoryPanel.lua - WTB history viewer panel for GuildItemScanner-UI

local addonName, addon = ...

local WTBHistoryPanel = {}
addon:RegisterModule("WTBHistoryPanel", WTBHistoryPanel)

function WTBHistoryPanel:Initialize()
end

function WTBHistoryPanel:GetPanel(parent)
    if not self.panel then
        self:CreatePanel(parent)
    end
    -- Auto-refresh WTB history whenever the panel is accessed
    self:RefreshWTBHistory()
    return self.panel
end

function WTBHistoryPanel:CreatePanel(parent)
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
    title:SetText("WTB History")
    title:SetTextColor(1, 0.8, 0)
    
    -- Refresh button
    local refreshButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshButton:SetSize(70, 25)
    refreshButton:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, yOffset + 5)
    refreshButton:SetText("Refresh")
    refreshButton:SetScript("OnClick", function()
        self:RefreshWTBHistory()
    end)
    self.refreshButton = refreshButton
    
    yOffset = yOffset - 35
    
    -- Clear History button
    local clearButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clearButton:SetSize(100, 25)
    clearButton:SetPoint("TOPLEFT", 10, yOffset)
    clearButton:SetText("Clear History")
    clearButton:SetScript("OnClick", function()
        self:ClearWTBHistory()
    end)
    self.clearButton = clearButton
    
    yOffset = yOffset - 40
    
    -- Add info label about display limit
    local limitInfo = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    limitInfo:SetPoint("TOPLEFT", 10, yOffset)
    limitInfo:SetText("|cff888888Showing latest 20 WTB requests|r")
    self.limitInfo = limitInfo
    
    yOffset = yOffset - 25
    
    -- Add usage info
    local usageInfo = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    usageInfo:SetPoint("TOPLEFT", 10, yOffset)
    usageInfo:SetWidth(380)
    usageInfo:SetJustifyH("LEFT")
    usageInfo:SetText("|cff888888Click entries to whisper players about their WTB requests|r")
    self.usageInfo = usageInfo
    
    yOffset = yOffset - 20
    
    -- WTB history list container
    self.historyContainer = content
    self.historyStartY = yOffset
    
    -- Initial load
    self:RefreshWTBHistory()
    
    panel:Hide()
    return panel
end

function WTBHistoryPanel:RefreshWTBHistory()
    -- Clear existing history display
    if self.historyFrames then
        for _, frame in ipairs(self.historyFrames) do
            frame:Hide()
        end
    end
    self.historyFrames = {}
    
    if not addon.GIS.IsAvailable() then
        local noGISFrame = self:CreateHistoryEntry(
            "|cffff0000GuildItemScanner not available|r",
            nil, nil, nil, nil, nil
        )
        noGISFrame:SetPoint("TOPLEFT", self.historyContainer, "TOPLEFT", 10, self.historyStartY)
        table.insert(self.historyFrames, noGISFrame)
        return
    end
    
    local wtbHistory = addon.GIS.GetWTBHistory()
    
    if not wtbHistory or #wtbHistory == 0 then
        local noHistoryFrame = self:CreateHistoryEntry(
            "|cff808080No WTB history found|r",
            nil, nil, nil, nil, nil
        )
        noHistoryFrame:SetPoint("TOPLEFT", self.historyContainer, "TOPLEFT", 10, self.historyStartY)
        table.insert(self.historyFrames, noHistoryFrame)
        return
    end
    
    -- Display entries (limit to 20)
    local displayCount = math.min(#wtbHistory, 20)
    local yOffset = self.historyStartY
    
    for i = 1, displayCount do
        local entry = wtbHistory[i]
        local frame = self:CreateWTBEntry(entry, i)
        frame:SetPoint("TOPLEFT", self.historyContainer, "TOPLEFT", 10, yOffset)
        table.insert(self.historyFrames, frame)
        yOffset = yOffset - 45 -- Space between entries
    end
    
    -- Update content height for scrolling
    local totalHeight = math.abs(yOffset) + 100
    self.content:SetHeight(totalHeight)
end

function WTBHistoryPanel:CreateWTBEntry(entry, index)
    local frame = CreateFrame("Frame", nil, self.historyContainer)
    frame:SetSize(380, 40)
    
    -- Background for clickable area
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Time display
    local timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetPoint("TOPLEFT", 5, -2)
    timeText:SetText("|cff888888" .. (entry.time or "??:??:??") .. "|r")
    
    -- Player name
    local playerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerText:SetPoint("TOPLEFT", 5, -15)
    playerText:SetText("|cff00ff00" .. (entry.player or "Unknown") .. "|r")
    
    -- Item name/link
    local itemText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemText:SetPoint("TOPLEFT", 120, -15)
    itemText:SetWidth(150)
    itemText:SetJustifyH("LEFT")
    
    if entry.itemLink and string.find(entry.itemLink, "|c%x+|H.-|h%[.-%]|h|r") then
        -- It's a proper item link
        itemText:SetText(entry.itemLink)
    else
        -- It's just a name, color it appropriately
        itemText:SetText("|cffffffff" .. (entry.itemName or entry.itemLink or "Unknown Item") .. "|r")
    end
    
    -- Quantity and Price on second line
    local detailsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    detailsText:SetPoint("TOPLEFT", 120, -28)
    detailsText:SetWidth(200)
    detailsText:SetJustifyH("LEFT")
    
    local qtyText = entry.quantity and ("Qty: " .. entry.quantity) or "Qty: ?"
    local priceText = entry.price and ("Price: " .. entry.price) or "Price: ?"
    detailsText:SetText("|cff888888" .. qtyText .. " | " .. priceText .. "|r")
    
    -- Sent indicator (if applicable)
    local sentText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sentText:SetPoint("TOPRIGHT", -5, -2)
    
    -- Check if we've sent a message for this entry
    local sentKey = self:GetSentKey(entry)
    if self:HasSentMessage(sentKey) then
        sentText:SetText("|cff00ff00[Sent]|r")
    else
        sentText:SetText("")
    end
    
    -- Make clickable
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function()
        self:SendWTBMessage(entry)
    end)
    
    -- Highlight on hover
    frame:SetScript("OnEnter", function()
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
        
        -- Show tooltip with full message
        if entry.rawMessage and entry.rawMessage ~= "" then
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            GameTooltip:SetText("Original Message:")
            GameTooltip:AddLine(entry.rawMessage, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Click to whisper " .. (entry.player or "Unknown"), 0.5, 1, 0.5)
            GameTooltip:Show()
        end
    end)
    
    frame:SetScript("OnLeave", function()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        GameTooltip:Hide()
    end)
    
    return frame
end

function WTBHistoryPanel:CreateHistoryEntry(text, player, time, itemLink, quantity, price)
    local frame = CreateFrame("Frame", nil, self.historyContainer)
    frame:SetSize(380, 25)
    
    local textDisplay = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textDisplay:SetPoint("TOPLEFT", 5, -5)
    textDisplay:SetWidth(370)
    textDisplay:SetJustifyH("LEFT")
    textDisplay:SetText(text)
    
    return frame
end

function WTBHistoryPanel:SendWTBMessage(entry)
    if not entry or not entry.player then
        print("|cffff0000[GIS-UI]|r Cannot send message - missing player information")
        return
    end
    
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    -- Check if already sent
    local sentKey = self:GetSentKey(entry)
    if self:HasSentMessage(sentKey) then
        print("|cffffcc00[GIS-UI]|r Message already sent to " .. entry.player)
        return
    end
    
    -- Create appropriate message with item link if available
    local itemDisplay = entry.itemLink or entry.itemName or "that item"
    -- Check if itemLink is a proper link (contains color codes and hyperlink)
    if entry.itemLink and string.find(entry.itemLink, "|c%x+|H.-|h%[.-%]|h|r") then
        itemDisplay = entry.itemLink  -- Use the full item link
    elseif entry.itemName then
        itemDisplay = "[" .. entry.itemName .. "]"  -- Wrap plain name in brackets
    end
    local message = string.format("Hi %s, are you still looking to buy %s?", entry.player, itemDisplay)
    
    -- Send whisper
    SendChatMessage(message, "WHISPER", nil, entry.player)
    
    -- Mark as sent
    self:MarkMessageSent(sentKey)
    
    -- Refresh display to show sent indicator
    self:RefreshWTBHistory()
    
    print("|cff00ff00[GIS-UI]|r Whispered " .. entry.player .. " about " .. (entry.itemName or "item"))
end

function WTBHistoryPanel:GetSentKey(entry)
    -- Create unique key for this WTB entry
    local player = entry.player or "unknown"
    local item = entry.itemName or entry.itemLink or "unknown"
    local timestamp = entry.timestamp or 0
    return player .. ":" .. item .. ":" .. timestamp
end

function WTBHistoryPanel:HasSentMessage(key)
    if not addon.settings then return false end
    if not addon.settings.wtbSentMessages then
        addon.settings.wtbSentMessages = {}
    end
    return addon.settings.wtbSentMessages[key] == true
end

function WTBHistoryPanel:MarkMessageSent(key)
    if not addon.settings then addon.settings = {} end
    if not addon.settings.wtbSentMessages then
        addon.settings.wtbSentMessages = {}
    end
    addon.settings.wtbSentMessages[key] = true
end

function WTBHistoryPanel:ClearWTBHistory()
    if not addon.GIS.IsAvailable() then
        print("|cffff0000[GIS-UI]|r GuildItemScanner not available")
        return
    end
    
    local success = addon.GIS.ClearWTBHistory()
    if success then
        -- Also clear sent message tracking
        if addon.settings and addon.settings.wtbSentMessages then
            addon.settings.wtbSentMessages = {}
        end
        
        self:RefreshWTBHistory()
        print("|cff00ff00[GIS-UI]|r WTB history cleared")
    else
        print("|cffff0000[GIS-UI]|r Failed to clear WTB history")
    end
end