-- Show multi-role listings whenever any requested role matches selected filter
function RaidChat:Match(entry)
    return (self.filters.raid == RaidChat.Enum.Raid.ALL or entry.raid.id == self.filters.raid)
        and (self.filters.size == RaidChat.Enum.Size.ANY or entry.size == self.filters.size)
        and (self.filters.role == RaidChat.Enum.Role.ANY or entry.roles[self.filters.role] == true)
end

-- Place three equal-width dropdowns across top of window for quick filtering
function RaidChat:Controls(parent)
    local raids = {
        [RaidChat.Enum.Raid.ALL] = "All raids",
    }

    for _, raid in ipairs(RaidChat.Raid.list) do
        raids[raid.id] = raid.label
    end

    local roles = {
        [RaidChat.Enum.Role.ANY] = "Any role",
    }

    for _, role in ipairs(RaidChat.Raid.roles) do
        roles[role.id] = role.name
    end

    local controls = {
        {
            key = "raid",
            name = "Raid",
            values = raids,
        },
        {
            key = "size",
            name = "Size",
            values = {
                [RaidChat.Enum.Size.ANY] = "Any",
                [RaidChat.Enum.Size.TEN] = "10 players",
                [RaidChat.Enum.Size.TWENTY_FIVE] = "25 players",
            },
        },
        {
            key = "role",
            name = "Role",
            values = roles,
        },
    }

    for _, control in ipairs(controls) do
        local dropdown = LibStub("AceGUI-3.0"):Create("Dropdown")

        dropdown:SetRelativeWidth(0.33)
        dropdown:SetLabel(control.name)
        dropdown:SetList(control.values)
        dropdown:SetValue(self.filters[control.key])
        dropdown:SetCallback("OnValueChanged", function(_, _, value)
            self.filters[control.key] = value
            self.scroll.scrollbar:SetValue(0)
            self:Draw(true)
        end)

        parent:AddChild(dropdown)
    end
end
