-- MainFrame.lua - Main UI window for GuildItemScanner-UI

local addonName, addon = ...

local MainFrame = {}
addon:RegisterModule("MainFrame", MainFrame)

-- Panel definitions
local PANELS = {
    {name = "General", title = "General Settings", module = "GeneralPanel"},
    {name = "Alerts", title = "Alert Settings", module = "AlertsPanel"},
    {name = "Professions", title = "Professions", module = "ProfessionsPanel"},
    {name = "Social", title = "Social Features", module = "SocialPanel"},
    {name = "History", title = "Alert History", module = "HistoryPanel"},
    {name = "Admin", title = "Admin Tools", module = "AdminPanel"}
}

function MainFrame:Initialize()
    self:CreateFrame()
    self:CreateTabs()
    self:LoadPosition()
    self.currentPanel = addon:GetSetting("mainFrame", "currentPanel") or "General"
end

function MainFrame:CreateFrame()
    -- Main frame
    local frame = CreateFrame("Frame", "GISUIMainFrame", UIParent, "BasicFrameTemplateWithInset")
    self.frame = frame
    
    frame:SetSize(
        addon:GetSetting("mainFrame", "width") or 600,
        addon:GetSetting("mainFrame", "height") or 500
    )
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    -- Title
    frame.TitleText:SetText("GuildItemScanner Configuration")
    
    -- Make it respond to ESC key
    table.insert(UISpecialFrames, "GISUIMainFrame")
    
    -- Event handlers
    frame:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame:SetScript("OnDragStop", function() 
        frame:StopMovingOrSizing()
        self:SavePosition()
    end)
    
    frame:SetScript("OnSizeChanged", function(self, width, height)
        addon:SetSetting("mainFrame", "width", width)
        addon:SetSetting("mainFrame", "height", height)
    end)
    
    frame:SetScript("OnShow", function()
        self:ShowPanel(self.currentPanel)
    end)
    
    frame:SetScript("OnHide", function()
        self:SavePosition()
    end)
    
    -- Resize grip
    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 7)
    resizeButton:SetSize(16, 16)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizeButton:SetScript("OnMouseDown", function()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    
    resizeButton:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        self:SavePosition()
    end)
    
    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -32)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)
    self.content = content
    
    -- Tab area (left side)
    local tabArea = CreateFrame("Frame", nil, content)
    tabArea:SetPoint("TOPLEFT")
    tabArea:SetPoint("BOTTOMLEFT")
    tabArea:SetWidth(150)
    self.tabArea = tabArea
    
    -- Panel area (right side)
    local panelArea = CreateFrame("Frame", nil, content)
    panelArea:SetPoint("TOPLEFT", tabArea, "TOPRIGHT", 10, 0)
    panelArea:SetPoint("BOTTOMRIGHT")
    self.panelArea = panelArea
    
    -- Separator line
    local separator = panelArea:CreateTexture(nil, "BACKGROUND")
    separator:SetPoint("TOPLEFT", tabArea, "TOPRIGHT", 5, 0)
    separator:SetPoint("BOTTOMLEFT", tabArea, "BOTTOMRIGHT", 5, 0)
    separator:SetWidth(1)
    separator:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    
    -- Status bar removed per user request
end

function MainFrame:CreateStatusBar()
    local statusBar = CreateFrame("Frame", nil, self.frame)
    statusBar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 8, 8)
    statusBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -8, 8)
    statusBar:SetHeight(18)
    self.statusBar = statusBar
    
    -- Background
    local bg = statusBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Status text
    local statusText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("LEFT", 5, 0)
    statusText:SetTextColor(0.8, 0.8, 0.8)
    self.statusText = statusText
    
    -- GIS version info
    local versionText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("RIGHT", -5, 0)
    versionText:SetTextColor(0.6, 0.6, 0.6)
    self.versionText = versionText
    
    self:UpdateStatusBar()
end

function MainFrame:UpdateStatusBar()
    if self.statusText and self.versionText then
        if addon.GIS.IsAvailable() then
            local enabled = addon.GIS.Get("enabled")
            local status = enabled and "|cff00ff00Online|r" or "|cffff0000Disabled|r"
            self.statusText:SetText("GuildItemScanner: " .. status)
            
            local gisVersion = _G.GuildItemScanner and _G.GuildItemScanner.version or "Unknown"
            self.versionText:SetText("GIS v" .. gisVersion .. " | UI v" .. addon.version)
        else
            self.statusText:SetText("|cffff0000GuildItemScanner not found|r")
            self.versionText:SetText("UI v" .. addon.version)
        end
    end
end

function MainFrame:CreateTabs()
    self.tabs = {}
    
    for i, panelInfo in ipairs(PANELS) do
        local tab = self:CreateTab(panelInfo, i)
        self.tabs[panelInfo.name] = tab
    end
end

function MainFrame:CreateTab(panelInfo, index)
    local tab = CreateFrame("Button", nil, self.tabArea)
    tab:SetSize(140, 30)
    tab:SetPoint("TOPLEFT", 5, -(index - 1) * 35 - 10)
    
    -- Background
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    tab.bg = bg
    
    -- Highlight
    local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.3, 0.3, 0.3, 0.5)
    
    -- Text
    local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(panelInfo.title)
    tab.text = text
    
    -- Click handler
    tab:SetScript("OnClick", function()
        self:ShowPanel(panelInfo.name)
    end)
    
    -- Tooltip
    tab:SetScript("OnEnter", function()
        GameTooltip:SetOwner(tab, "ANCHOR_RIGHT")
        GameTooltip:SetText(panelInfo.title)
        if panelInfo.name == "Social" then
            GameTooltip:AddLine("Requires Frontier addon", 1, 1, 0)
        end
        GameTooltip:Show()
    end)
    
    tab:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    tab.panelName = panelInfo.name
    return tab
end

function MainFrame:ShowPanel(panelName)
    -- Find panel info
    local panelInfo = nil
    for _, info in ipairs(PANELS) do
        if info.name == panelName then
            panelInfo = info
            break
        end
    end
    
    if not panelInfo then
        panelName = "General"
        panelInfo = PANELS[1]
    end
    
    -- Hide current panel
    if self.currentPanelFrame then
        self.currentPanelFrame:Hide()
    end
    
    -- Update tab appearance
    for name, tab in pairs(self.tabs) do
        if name == panelName then
            tab.bg:SetColorTexture(0.15, 0.35, 0.15, 0.9)  -- Darker green for active
            tab.text:SetTextColor(0.9, 1, 0.9)
        else
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)  -- Gray for inactive
            tab.text:SetTextColor(0.8, 0.8, 0.8)
        end
    end
    
    -- Show new panel
    local module = addon.modules[panelInfo.module]
    if module and module.GetPanel then
        local panel = module:GetPanel(self.panelArea)
        if panel then
            panel:Show()
            self.currentPanelFrame = panel
        end
    else
        -- Create placeholder if module not loaded
        self:CreatePlaceholderPanel(panelInfo.title)
    end
    
    self.currentPanel = panelName
    addon:SetSetting("mainFrame", "currentPanel", panelName)
end

function MainFrame:CreatePlaceholderPanel(title)
    if not self.placeholderPanel then
        local panel = CreateFrame("Frame", nil, self.panelArea)
        panel:SetAllPoints()
        
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("CENTER")
        text:SetText("Panel '" .. title .. "' not yet implemented")
        
        self.placeholderPanel = panel
    end
    
    self.placeholderPanel:Show()
    self.currentPanelFrame = self.placeholderPanel
end

function MainFrame:LoadPosition()
    local point = addon:GetSetting("mainFrame", "point")
    local x = addon:GetSetting("mainFrame", "x")
    local y = addon:GetSetting("mainFrame", "y")
    
    if point and x and y then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(point, UIParent, point, x, y)
    end
end

function MainFrame:SavePosition()
    local point, _, _, x, y = self.frame:GetPoint()
    addon:SetSetting("mainFrame", "point", point)
    addon:SetSetting("mainFrame", "x", x)
    addon:SetSetting("mainFrame", "y", y)
end

function MainFrame:Show(panelName)
    self.frame:Show()
    if panelName then
        self:ShowPanel(panelName)
    end
end

function MainFrame:Hide()
    self.frame:Hide()
end

function MainFrame:Toggle()
    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function MainFrame:IsShown()
    return self.frame and self.frame:IsShown()
end