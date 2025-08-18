-- MinimapButton.lua - Minimap button for GuildItemScanner-UI

local addonName, addon = ...

local MinimapButton = {}
addon:RegisterModule("MinimapButton", MinimapButton)

-- Button creation
function MinimapButton:Initialize()
    self:CreateButton()
    self:UpdatePosition()
end

function MinimapButton:CreateButton()
    -- Create the button
    self.button = CreateFrame("Button", "GISUIMinimapButton", Minimap)
    self.button:SetSize(31, 31)
    self.button:SetFrameStrata("MEDIUM")
    self.button:SetFrameLevel(8)
    
    -- Button icon
    local icon = self.button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 1)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")  -- Gear icon
    self.button.icon = icon
    
    -- Button border
    local overlay = self.button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetPoint("TOPLEFT")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    -- Highlight texture
    local highlight = self.button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetSize(31, 31)
    highlight:SetPoint("CENTER")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    
    -- Make it draggable
    self.button:SetMovable(true)
    self.button:EnableMouse(true)
    self.button:RegisterForDrag("LeftButton")
    
    -- Event handlers
    self.button:SetScript("OnClick", function(button, mouseButton)
        self:OnClick(mouseButton)
    end)
    
    self.button:SetScript("OnDragStart", function()
        self:OnDragStart()
    end)
    
    self.button:SetScript("OnDragStop", function()
        self:OnDragStop()
    end)
    
    self.button:SetScript("OnEnter", function()
        self:OnEnter()
    end)
    
    self.button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Hide/show based on settings
    if addon:GetSetting("minimapButton", "hide") then
        self.button:Hide()
    else
        self.button:Show()
    end
end

function MinimapButton:OnClick(mouseButton)
    if mouseButton == "LeftButton" then
        -- Open main frame
        if addon.modules.MainFrame then
            addon.modules.MainFrame:Toggle()
        end
    end
end

function MinimapButton:OnDragStart()
    self.button:LockHighlight()
    self.button:SetScript("OnUpdate", function()
        self:OnUpdate()
    end)
end

function MinimapButton:OnDragStop()
    self.button:SetScript("OnUpdate", nil)
    self.button:UnlockHighlight()
    
    -- Save new position
    local pos = self:GetPosition()
    addon:SetSetting("minimapButton", "minimapPos", pos)
end

function MinimapButton:OnUpdate()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    
    px, py = px / scale, py / scale
    
    local pos = math.deg(math.atan2(py - my, px - mx)) % 360
    self:SetPosition(pos)
end

function MinimapButton:GetPosition()
    local px, py = self.button:GetCenter()
    local mx, my = Minimap:GetCenter()
    
    local pos = math.deg(math.atan2(py - my, px - mx)) % 360
    return pos
end

function MinimapButton:SetPosition(pos)
    local angle = math.rad(pos or addon:GetSetting("minimapButton", "minimapPos") or 220)
    local radius = addon:GetSetting("minimapButton", "radius") or 80
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    
    self.button:ClearAllPoints()
    self.button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function MinimapButton:UpdatePosition()
    if self.button then
        self:SetPosition()
    end
end

function MinimapButton:OnEnter()
    GameTooltip:SetOwner(self.button, "ANCHOR_LEFT")
    GameTooltip:SetText("|cff00ff00GuildItemScanner UI|r", 1, 1, 1)
    
    if addon.GIS.IsAvailable() then
        local enabled = addon.GIS.Get("enabled")
        GameTooltip:AddLine("GIS Status: " .. (enabled and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))
        
        local professions = addon.GIS.GetProfessions()
        if #professions > 0 then
            GameTooltip:AddLine("Professions: " .. table.concat(professions, ", "), 1, 1, 0.8)
        end
        
        local ignoreWTB = addon.GIS.Get("ignoreWTB")
        GameTooltip:AddLine("WTB Filtering: " .. (ignoreWTB and "|cff00ff00On|r" or "|cffff0000Off|r"))
    else
        GameTooltip:AddLine("|cffff0000GuildItemScanner not found!|r")
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffffff00Left-click:|r Open configuration")
    GameTooltip:AddLine("|cffffff00Drag:|r Reposition button")
    
    GameTooltip:Show()
end


function MinimapButton:Show()
    if self.button then
        self.button:Show()
        addon:SetSetting("minimapButton", "hide", false)
    end
end

function MinimapButton:Hide()
    if self.button then
        self.button:Hide()
        addon:SetSetting("minimapButton", "hide", true)
    end
end

function MinimapButton:Toggle()
    if self.button then
        if self.button:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    end
end