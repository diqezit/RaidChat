RaidChat = {}

RaidChat.Enum = {
    Raid = {
        ALL = "ALL",
        ICC = "ICC",
        RS = "RS",
        TOC = "TOC",
        VOA = "VOA",
        ULD = "ULD",
        NAXX = "NAXX",
        ONY = "ONY",
        OS = "OS",
        EOE = "EOE",
    },
    Role = {
        ANY = "all",
        TANK = "tank",
        HEALER = "heal",
        DPS = "dps",
    },
    Size = {
        ANY = 0,
        TEN = 10,
        TWENTY_FIVE = 25,
    },
}

RaidChat.Raid = {
    list = {
        {
            id = RaidChat.Enum.Raid.ICC,
            label = "|cff80cfffICC|r",
            aliases = { "icecrown citadel", "icecrown", "icc" },
            quests = { "lord marrowgar must die" },
        },
        {
            id = RaidChat.Enum.Raid.RS,
            label = "|cffff8888Ruby Sanctum|r",
            aliases = { "ruby sanctum", "rs" },
        },
        {
            id = RaidChat.Enum.Raid.TOC,
            label = "|cffe8c878ToC / ToGC|r",
            aliases = {
                "trial of the grand crusader",
                "trial of the crusader",
                "togc",
                "toc",
            },
            quests = { "lord jaraxxus must die" },
        },
        {
            id = RaidChat.Enum.Raid.VOA,
            label = "|cffa8b8d8VoA|r",
            aliases = { "vault of archavon", "voa" },
        },
        {
            id = RaidChat.Enum.Raid.ULD,
            label = "|cff88d8c8Ulduar|r",
            aliases = { "ulduar", "uld" },
            quests = {
                "flame leviathan must die",
                "ignis the furnace master must die",
                "razorscale must die",
                "xt%-002 deconstructor must die",
            },
        },
        {
            id = RaidChat.Enum.Raid.NAXX,
            label = "|cffa8d888Naxxramas|r",
            aliases = { "naxxramas", "naxx" },
            quests = {
                "anub'rekhan must die",
                "instructor razuvious must die",
                "noth the plaguebringer must die",
                "patchwerk must die",
            },
        },
        {
            id = RaidChat.Enum.Raid.ONY,
            label = "|cffe8a078Onyxia|r",
            aliases = { "onyxia", "ony" },
        },
        {
            id = RaidChat.Enum.Raid.OS,
            label = "|cffc8a0e8OS|r",
            aliases = { "obsidian sanctum", "sartharion", "os" },
        },
        {
            id = RaidChat.Enum.Raid.EOE,
            label = "|cff90a8ffMalygos|r",
            aliases = { "eye of eternity", "malygos", "eoe" },
        },
    },
    words = {
        format = {
            "m",
            "man",
            "player",
            "hc",
            "h",
            "heroic",
            "hero",
            "lod",
            "bane",
            "nm",
            "n",
            "normal",
            "norm",
        },
        sales = {
            "wts",
            "wtb",
            "selling",
            "boost",
            "boosts",
            "boostrun",
            "boostruns",
            "carry",
        },
        recruiting = {
            "lfm",
            "need",
            "needs",
            "needed",
            "looking for more",
            "spots?",
        },
        notRoles = {
            "boss",
            "spec",
            "reserv",
            "loot",
            "achiev",
        },
    },
    roles = {
        {
            id = RaidChat.Enum.Role.TANK,
            name = "Tank",
            tokens = {
                "tank",
                "tanks",
                "mt",
                "ot",
                "prot",
                "protection",
                "bdk",
                "bear",
            },
        },
        {
            id = RaidChat.Enum.Role.HEALER,
            name = "Healer",
            tokens = {
                "heal",
                "heals",
                "healer",
                "healers",
                "resto",
                "rsham",
                "rshaman",
                "rshammy",
                "rdruid",
                "rdru",
                "rdudu",
                "hpala",
                "hpal",
                "holy",
                "disc",
                "disco",
            },
        },
        {
            id = RaidChat.Enum.Role.DPS,
            name = "DPS",
            tokens = {
                "dps",
                "dd",
                "rdps",
                "mdps",
                "melee",
                "ranged",
                "range",
                "caster",
                "damage",
                "lock",
                "warlock",
                "demo",
                "affli",
                "affl",
                "mage",
                "fmage",
                "hunter",
                "hunt",
                "rogue",
                "ret",
                "retr",
                "retri",
                "retry",
                "fury",
                "fwarr",
                "boomkin",
                "boomie",
                "boomy",
                "shadow",
                "sp",
                "spriest",
                "ele",
                "enha",
                "enhan",
                "enhance",
                "fdk",
                "udk",
                "uh",
            },
        },
    },
    classes = {
        {
            name = "Warlock",
            tokens = { "lock", "warlock", "demo", "affli", "affl" },
            roles = { RaidChat.Enum.Role.DPS },
        },
        {
            name = "Mage",
            tokens = { "mage", "fmage" },
            roles = { RaidChat.Enum.Role.DPS },
        },
        {
            name = "Shaman",
            tokens = {
                "shaman",
                "sham",
                "rsham",
                "rshaman",
                "rshammy",
                "ele",
                "enha",
                "enhan",
                "enhance",
            },
            roles = { RaidChat.Enum.Role.HEALER, RaidChat.Enum.Role.DPS },
        },
        {
            name = "Druid",
            tokens = {
                "druid",
                "rdruid",
                "rdru",
                "rdudu",
                "boomkin",
                "boomie",
                "boomy",
                "bear",
                "feral",
            },
            roles = { RaidChat.Enum.Role.TANK, RaidChat.Enum.Role.HEALER, RaidChat.Enum.Role.DPS },
        },
        {
            name = "Paladin",
            tokens = {
                "paladin",
                "pala",
                "pally",
                "hpala",
                "hpal",
                "ret",
                "retr",
                "retri",
                "retry",
            },
            roles = { RaidChat.Enum.Role.TANK, RaidChat.Enum.Role.HEALER, RaidChat.Enum.Role.DPS },
        },
        {
            name = "Priest",
            tokens = { "priest", "disc", "disco", "sp", "spriest", "shadow" },
            roles = { RaidChat.Enum.Role.HEALER, RaidChat.Enum.Role.DPS },
        },
        {
            name = "Hunter",
            tokens = { "hunter", "hunt" },
            roles = { RaidChat.Enum.Role.DPS },
        },
        {
            name = "Rogue",
            tokens = { "rogue" },
            roles = { RaidChat.Enum.Role.DPS },
        },
        {
            name = "Warrior",
            tokens = { "warrior", "fury", "fwarr" },
            roles = { RaidChat.Enum.Role.TANK, RaidChat.Enum.Role.DPS },
        },
        {
            name = "DK",
            tokens = { "dk", "bdk", "fdk", "udk", "uh" },
            roles = { RaidChat.Enum.Role.TANK, RaidChat.Enum.Role.DPS },
        },
    },
    sizes = {
        ["10"] = RaidChat.Enum.Size.TEN,
        ["25"] = RaidChat.Enum.Size.TWENTY_FIVE,
    },
    defaults = {
        filters = {
            raid = RaidChat.Enum.Raid.ALL,
            size = RaidChat.Enum.Size.ANY,
            role = RaidChat.Enum.Role.ANY,
        },
        window = {
            width = 520,
            height = 370,
        },
        icon = {
            minimapPos = 225,
        },
    },
    tokens = {},
    format = {},
    colors = {},
}

local totals = {
    tank = true,
    tanks = true,
    heal = true,
    heals = true,
    healer = true,
    healers = true,
    dps = true,
    dd = true,
    damage = true,
}

for _, role in ipairs(RaidChat.Raid.roles) do
    for _, token in ipairs(role.tokens) do
        RaidChat.Raid.tokens[token] = { role = role.id, total = totals[token] }
    end
end

for _, class in ipairs(RaidChat.Raid.classes) do
    for _, token in ipairs(class.tokens) do
        local info = RaidChat.Raid.tokens[token] or {}

        info.class = class
        RaidChat.Raid.tokens[token] = info
    end
end

-- Feral spots can be tank or damage but not healer
RaidChat.Raid.tokens.feral.roles = { RaidChat.Enum.Role.TANK, RaidChat.Enum.Role.DPS }

for _, token in ipairs(RaidChat.Raid.words.format) do
    RaidChat.Raid.format[token] = true
end

for _, raid in ipairs(RaidChat.Raid.list) do
    raid.display = {
        [RaidChat.Enum.Size.ANY] = raid.label .. " ?",
        [RaidChat.Enum.Size.TEN] = raid.label .. " 10",
        [RaidChat.Enum.Size.TWENTY_FIVE] = raid.label .. " 25",
    }
end

for class, color in pairs(RAID_CLASS_COLORS) do
    RaidChat.Raid.colors[class] =
        string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end
