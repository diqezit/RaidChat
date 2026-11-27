RaidChat.Parser = {}

local left = "%f[%a\128-\255]"
local right = "%f[^%a\128-\255]"

local function hasWord(text, token)
    return text:find(left .. token .. right)
end

local function hasAny(text, tokens)
    for _, token in ipairs(tokens) do
        if hasWord(text, token) then
            return true
        end
    end

    return false
end

local function sortMatches(a, b)
    if a.first == b.first then
        return a.after > b.after
    end

    return a.first < b.first
end

local function findRaids(text, field)
    local found = {}

    for _, raid in ipairs(RaidChat.Raid.list) do
        for _, alias in ipairs(raid[field] or {}) do
            for first, after in text:gmatch("()" .. left .. alias .. right .. "()") do
                found[#found + 1] = { first = first, after = after, raid = raid }
            end
        end
    end

    if #found < 2 then
        return found
    end

    table.sort(found, sortMatches)

    local result = {}
    local lastEnd = 0

    for _, match in ipairs(found) do
        if match.first >= lastEnd then
            local previous = result[#result]
            local gap = previous and text:sub(previous.after, match.first - 1)

            if previous and previous.raid == match.raid and not gap:find("%d") then
                previous.after = match.after
            else
                result[#result + 1] = match
            end

            lastEnd = match.after
        end
    end

    return result
end

local function blank(value)
    return string.rep(" ", #value)
end

local function mask(text)
    if text:find("%d") then
        for _, token in ipairs(RaidChat.Raid.words.format) do
            text = text:gsub(left .. token .. right, blank)
        end
    end

    return text
end

local function sizes(after, before, nextRaid)
    local prefix = mask(before)
    local first, _, preceding = prefix:find("(%d+)%s*[%-%(%[]*%s*$")

    -- A size directly before this raid cannot belong to the following raid
    if RaidChat.Raid.sizes[preceding] then
        return RaidChat.Raid.sizes[preceding], nil, nil, first
    end

    local format = mask(after)

    if
        nextRaid
        and format:match("^%s*[/,;:+&%-]")
        and RaidChat.Raid.sizes[format:match("(%d+)%s*$")]
    then
        return RaidChat.Enum.Size.ANY
    end

    local _, last, value = format:find("^%s*[%(%[%-%:/%.,!]*%s*(%d+)")
    local size = RaidChat.Raid.sizes[value]

    if size then
        local tail = format:sub(last + 1)
        local _, secondEnd, second = tail:find("^%s*[%)/&,+%-]+%s*[%(%[]*%s*(%d+)")
        local other = RaidChat.Raid.sizes[second]

        if other then
            if nextRaid and RaidChat.Raid.sizes[tail:match("(%d+)%s*$")] then
                return size, nil, last
            end

            -- Even repeated 25/25 must be removed from the role text
            return size, other ~= size and other or nil, last + secondEnd
        end

        return size, nil, last
    end

    if not nextRaid then
        local value = after:match("%f[%d](%d+)%s*%-?%s*man%f[^%a]")
            or after:match("%f[%d](%d+)%s*%-?%s*player%f[^%a]")

        return RaidChat.Raid.sizes[value] or RaidChat.Enum.Size.ANY
    end

    return RaidChat.Enum.Size.ANY
end

local function count(text, first, after, used)
    local position, number = text:sub(1, first - 1):match("()(%d+)%s*x?%s*$")
    local suffix = false

    if not number then
        position, number = text:sub(after):match("^%s*x?%s*()(%d+)")
        position = position and after + position - 1
        suffix = true
    end

    if not number or used[position] then
        return
    end

    local value = tonumber(number)
    local previous = text:sub(position - 1, position - 1)
    local tail = text:sub(position + #number)

    if
        value == 0
        or value > RaidChat.Enum.Size.TWENTY_FIVE
        or previous == "."
        or previous == ","
        or previous == "/"
        or tail:match("^[%.,/]%d")
        or tail:match("^%s*k")
        or (suffix and RaidChat.Raid.format[tail:match("^%s*([%a]+)")])
    then
        return
    end

    used[position] = true
    return value
end

local function needs(text)
    local flags, classes, totals, counts, used = {}, {}, {}, {}, {}
    local all = false

    for first, word, after in text:gmatch("()([%a\128-\255]+)()") do
        local info = RaidChat.Raid.tokens[word]

        if not info and word:sub(1, 1) == "x" and text:sub(first - 1, first - 1):match("%d") then
            info = RaidChat.Raid.tokens[word:sub(2)]
            first = first + 1
        elseif not info and word:sub(-1) == "x" and text:sub(after, after):match("%d") then
            info = RaidChat.Raid.tokens[word:sub(1, -2)]
            after = after - 1
        end

        if word == "all" then
            local following = text:sub(after):match("[%a\128-\255]+") or ""
            local blocked = false

            for _, token in ipairs(RaidChat.Raid.words.notRoles) do
                if following:find(token, 1, true) == 1 then
                    blocked = true
                    break
                end
            end

            all = all or not blocked
        elseif info then
            if info.class then
                classes[info.class] = info.roles or info.class.roles
            end

            if info.role then
                flags[info.role] = true
                local number = count(text, first, after, used)

                if number then
                    local values = info.total and totals or counts
                    values[info.role] = (values[info.role] or 0) + number
                end
            end
        end
    end

    local labels = {}

    for _, role in ipairs(RaidChat.Raid.roles) do
        if all then
            flags[role.id] = true
        elseif flags[role.id] then
            local number = totals[role.id] or counts[role.id]
            labels[#labels + 1] = role.name .. (number and (" x" .. number) or "")
        end
    end

    if all then
        labels[1] = "All roles"
    end

    -- A class without a spec can match possible roles without claiming a specific spec
    if not next(flags) then
        for _, roles in pairs(classes) do
            for _, role in ipairs(roles) do
                flags[role] = true
            end
        end
    end

    local classLabels = {}

    for _, class in ipairs(RaidChat.Raid.classes) do
        if classes[class] then
            classLabels[#classLabels + 1] = class.name
        end
    end

    local label = table.concat(labels, ", ")

    if #classLabels > 0 then
        if label ~= "" then
            label = label .. " / "
        end

        label = label .. table.concat(classLabels, ", ")
    end

    return flags, label ~= "" and label or "Not specified"
end

function RaidChat.Parser.Parse(message)
    if #message < 5 then
        return {}
    end

    local text = message

    if text:find("|", 1, true) then
        -- Quest links keep their name because it identifies the raid
        -- Linked achievements describe past kills rather than the advertised group
        text = text:gsub("|Hquest:.-|h%[?(.-)%]?|h", " %1 ")
            :gsub("|H.-|h.-|h", " ")
            :gsub("|c%x%x%x%x%x%x%x%x", "")
            :gsub("|r", "")
            :gsub("|T.-|t", " ")
            :gsub("|+", " ")
    end

    text = text:gsub("[%z\1-\32\127]+", " "):trim():lower()

    if not hasAny(text, RaidChat.Raid.words.recruiting) then
        -- LF must request a role or class, not just name a raid to join
        local wanted = text:match(left .. "lf" .. right .. "%s*(.*)")
            or text:match(left .. "looking for" .. right .. "%s*(.*)")
        local token = wanted and wanted:match("^%d*%s*x?%s*([%a]+)")

        if token ~= "all" and not RaidChat.Raid.tokens[token] then
            return {}
        end
    end

    if hasAny(text, RaidChat.Raid.words.sales) then
        return {}
    end

    if
        not hasWord(text, "lfm")
        and text:find("guild", 1, true)
        and not hasWord(text, "guild run")
    then
        return {}
    end

    local matches = findRaids(text, "aliases")

    -- Weekly raid quest names identify the raid only when the ad does not name it
    if #matches == 0 then
        matches = findRaids(text, "quests")
    end

    local results = {}
    local seen = #matches > 1 and {} or nil
    local consumed = 1

    for index, match in ipairs(matches) do
        local nextMatch = matches[index + 1]
        local after = text:sub(match.after, nextMatch and nextMatch.first - 1)
        local before = text:sub(consumed, match.first - 1)
        local size, second, last, prefix = sizes(after, before, nextMatch)
        local roleText = last and after:sub(last + 1) or after

        if index == 1 then
            local leading = prefix and before:sub(1, prefix - 1) or before
            roleText = leading .. " " .. roleText
        end

        local roles, needText = needs(roleText)

        if needText == "Not specified" then
            roles, needText = needs(text)
        end

        for group = 1, second and 2 or 1 do
            local groupSize = group == 1 and size or second
            local key = seen and match.raid.id .. ":" .. groupSize

            if not seen or not seen[key] then
                if seen then
                    seen[key] = true
                end

                results[#results + 1] = {
                    raid = match.raid,
                    size = groupSize,
                    roles = roles,
                    needs = needText,
                    message = message,
                }
            end
        end

        consumed = match.after + (last or 0)
    end

    return results
end
