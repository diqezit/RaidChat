local gui = LibStub("AceGUI-3.0")
local view = {
    title = "RaidChat |cff999999by Diqezit|r",
    row = {
        height = 32,
        separator = {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = { left = 0, right = 0, top = 31, bottom = 0 },
        },
    },
    widths = {
        text = 0.79,
        whisper = 0.20,
    },
}

local function line(entry)
    return entry.heading
        .. SecondsToTime(math.max(1, GetTime() - entry.lastSeen), false, false, 1)
        .. "|r\n"
        .. entry.needs
end

-- Render two-line listing with class-colored leader name and whisper button
function RaidChat:Row(entry)
    local row = gui:Create("SimpleGroup")

    row:SetFullWidth(true)
    row:SetLayout("Flow")
    row:SetAutoAdjustHeight(false)
    row:SetHeight(view.row.height)
    row:SetUserData("entry", entry)
    row.frame:SetBackdrop(view.row.separator)
    row.frame:SetBackdropColor(1, 1, 1, 0.12)
    row:SetCallback("OnRelease", function(widget)
        widget.frame:SetBackdrop(nil)
    end)

    local text = gui:Create("InteractiveLabel")

    -- Clamp label height to two lines and show full ad in tooltip on hover
    text:SetRelativeWidth(view.widths.text)
    text.label:SetHeight(26)
    text:SetText(line(entry))
    text:SetCallback("OnRelease", function(widget)
        widget.label:SetHeight(0)

        if GameTooltip:IsOwned(widget.frame) then
            GameTooltip:Hide()
        end
    end)
    text:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(entry.authorText)
        GameTooltip:AddLine(
            entry.raid.display[entry.size] .. "  |cffaaaaaa" .. entry.channel .. "|r",
            1,
            1,
            1
        )
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(entry.message, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    text:SetCallback("OnLeave", GameTooltip_Hide)

    local button = gui:Create("Button")

    button:SetRelativeWidth(view.widths.whisper)
    button:SetText("Whisper")
    button:SetCallback("OnClick", function()
        -- Open chat input box instead of sending auto-whisper so player can type spec and gearscore
        ChatFrame_SendTell(entry.author)
    end)

    row:AddChildren(text, button)
    self.scroll:AddChild(row)
end

-- Reuse rows while only their age changes
function RaidChat:Draw(force)
    if not self.window or not self.window:IsShown() then
        return
    end

    -- Pause auto-refresh while cursor hovers over list so Whisper button never shifts mid-click
    if not force and MouseIsOver(self.scroll.frame) then
        return
    end

    if force then
        self:Trim()
    end

    -- Unchanged listings only need their age text refreshed
    if not force and not self.dirty then
        for _, row in ipairs(self.scroll.children) do
            local entry = row:GetUserData("entry")

            if entry then
                row.children[1]:SetText(line(entry))
            end
        end

        return
    end

    local entries = self:List()

    self.scroll:PauseLayout()
    self.scroll:ReleaseChildren()

    if #entries == 0 then
        local empty = gui:Create("Label")

        empty:SetFullWidth(true)
        empty:SetText("No matching listings.")
        self.scroll:AddChild(empty)
    else
        for _, entry in ipairs(entries) do
            self:Row(entry)
        end
    end

    self.scroll:ResumeLayout()
    self.scroll:DoLayout()
    self.dirty = false
end

-- Delay window creation until first open to save memory on login
function RaidChat:Build()
    local window = gui:Create("Frame")

    self.window = window

    window:SetTitle(view.title)
    window:SetLayout("Flow")
    window:SetStatusTable(self.db.window)
    window:SetCallback("OnClose", function()
        GameTooltip_Hide()
        self:CancelTimer(self.timer)
        self.timer = nil
    end)
    local function refresh()
        if not MouseIsOver(self.scroll.frame) then
            self:Trim()
            self:Draw()
        end
    end

    local function start()
        self.timer = self:ScheduleRepeatingTimer(refresh, self.config.refresh)
    end

    window.frame:HookScript("OnShow", start)
    window.statustext:GetParent():Hide()
    window.frame:SetClampedToScreen(true)
    window.frame:SetMinResize(
        RaidChat.Raid.defaults.window.width,
        RaidChat.Raid.defaults.window.height
    )

    RaidChatFrame = window.frame
    tinsert(UISpecialFrames, "RaidChatFrame")

    -- Clear belongs beside the native Close button outside the listing layout
    local clear = CreateFrame("Button", nil, window.frame, "UIPanelButtonTemplate")

    clear:SetSize(100, 20)
    clear:SetPoint("BOTTOMLEFT", window.frame, "BOTTOMLEFT", 27, 17)
    clear:SetText("Clear")
    clear:SetScript("OnClick", function()
        self:Clear()
    end)

    self:Controls(window)

    self.scroll = gui:Create("ScrollFrame")
    self.scroll:SetFullWidth(true)
    self.scroll:SetFullHeight(true)
    self.scroll:SetLayout("List")
    window:AddChild(self.scroll)
    start()
end

-- Create window on first use and refresh listings whenever opened
function RaidChat:Toggle()
    if not self.window then
        self:Build()
    elseif self.window:IsShown() then
        return self.window:Hide()
    else
        self.window:Show()
    end

    self:Draw(true)
end
