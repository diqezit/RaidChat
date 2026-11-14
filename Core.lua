LibStub("AceAddon-3.0"):NewAddon(
    RaidChat,
    "RaidChat",
    "AceEvent-3.0",
    "AceTimer-3.0",
    "AceConsole-3.0"
)

local channels = {
    CHAT_MSG_CHANNEL = "Channel",
    CHAT_MSG_YELL = "Yell",
    CHAT_MSG_SAY = "Say",
}

RaidChat.config = {
    ttl = 15 * 60,
    limit = 200,
    refresh = 5,
}

RaidChat.entries = {}
RaidChat.order = 0
RaidChat.count = 0

-- Repeated ads keep their original position
local function sortByOrder(a, b)
    return a.order < b.order
end

-- Expiry and overflow do not need a temporary copy of the listings
function RaidChat:Trim()
    if self.count == 0 then
        return
    end

    local now = GetTime()
    local changed = false

    repeat
        local oldest
        local overflow = self.count > self.config.limit

        for key, entry in pairs(self.entries) do
            if now - entry.lastSeen >= self.config.ttl then
                self.entries[key] = nil
                self.count = self.count - 1
                changed = self:Match(entry) or changed
            elseif
                overflow
                and (
                    not oldest
                    or entry.lastSeen < oldest.lastSeen
                    or (entry.lastSeen == oldest.lastSeen and entry.key > oldest.key)
                )
            then
                oldest = entry
            end
        end

        if self.count > self.config.limit then
            self.entries[oldest.key] = nil
            self.count = self.count - 1
            changed = self:Match(oldest) or changed
        end
    until self.count <= self.config.limit

    self.dirty = self.dirty or changed
end

function RaidChat:List()
    local entries = {}

    for _, entry in pairs(self.entries) do
        if self:Match(entry) then
            entries[#entries + 1] = entry
        end
    end

    table.sort(entries, sortByOrder)

    return entries
end

function RaidChat:Clear()
    table.wipe(self.entries)
    self.order = 0
    self.count = 0
    self.dirty = true

    if self.scroll then
        self.scroll.scrollbar:SetValue(0)
    end

    self:Draw(true)
end

function RaidChat:Chat(event, message, author, _, _, _, _, _, _, channelName, _, _, guid)
    local parsed = RaidChat.Parser.Parse(message)

    if #parsed == 0 then
        return
    end

    local source = event == "CHAT_MSG_CHANNEL" and channelName or channels[event]
    local now = GetTime()
    local authorLower = author:lower()
    local class, checked
    local visible = false

    for _, item in ipairs(parsed) do
        local key = string.format("%s:%s:%s", authorLower, item.raid.id, item.size)
        local entry = self.entries[key]
        local matched = entry and self:Match(entry) or false
        local previousClass = entry and entry.class
        class = class or previousClass

        if (not entry or not entry.class) and not class and guid and guid ~= "" and not checked then
            _, class = GetPlayerInfoByGUID(guid)
            checked = true
        end

        if not entry then
            self.order = self.order + 1
            self.count = self.count + 1

            local authorText = (RaidChat.Raid.colors[class] or HIGHLIGHT_FONT_COLOR_CODE)
                .. author
                .. "|r"

            entry = {
                key = key,
                order = self.order,
                author = author,
                class = class,
                raid = item.raid,
                size = item.size,
                roles = item.roles,
                needs = item.needs,
                message = item.message,
                channel = source,
                lastSeen = now,
                authorText = authorText,
                heading = authorText .. "  " .. item.raid.display[item.size] .. "  |cff999999",
            }
            self.entries[key] = entry
        else
            -- Keep the table captured by the visible row and its callbacks
            entry.lastSeen = now
            entry.roles = item.roles
            entry.needs = item.needs
            entry.message = item.message
            entry.channel = source
            entry.class = entry.class or class

            if entry.class ~= previousClass then
                entry.authorText = (RaidChat.Raid.colors[entry.class] or HIGHLIGHT_FONT_COLOR_CODE)
                    .. entry.author
                    .. "|r"
                entry.heading = entry.authorText
                    .. "  "
                    .. entry.raid.display[entry.size]
                    .. "  |cff999999"
            end
        end

        local matches = self:Match(entry)
        self.dirty = self.dirty or matched ~= matches
        visible = visible or matched or matches
    end

    if self.count > self.config.limit then
        self:Trim()
    end

    if visible or self.dirty then
        self:Draw()
    end
end

function RaidChat:Command(input)
    if input:trim():lower() == "clear" then
        self:Clear()
    else
        self:Toggle()
    end
end

function RaidChat:OnInitialize()
    -- Older versions saved settings outside the AceDB global section
    if RaidChatDB and (RaidChatDB.filters or RaidChatDB.window or RaidChatDB.icon) then
        RaidChatDB = { global = RaidChatDB }
    end

    self.db = LibStub("AceDB-3.0"):New("RaidChatDB", {
        global = RaidChat.Raid.defaults,
    }).global
    self.filters = self.db.filters

    self:RegisterChatCommand("raidchat", "Command")
    self:RegisterChatCommand("rchat", "Command")
end

function RaidChat:OnEnable()
    for event in pairs(channels) do
        self:RegisterEvent(event, "Chat")
    end

    local broker = LibStub("LibDataBroker-1.1", true)
    local icons = LibStub("LibDBIcon-1.0", true)

    if not broker or not icons then
        return
    end

    local launcher = broker:NewDataObject("RaidChat", {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        OnClick = function()
            self:Toggle()
        end,
    })

    icons:Register("RaidChat", launcher, self.db.icon)
end
