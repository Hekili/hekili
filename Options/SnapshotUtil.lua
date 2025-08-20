-- Options/SnapshotUtil.lua
-- Snapshot generation utilities and formatters

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local format = string.format
local formatKey = ns.formatKey
local orderedPairs = ns.orderedPairs

local SnapshotUtil = {}
ns.SnapshotUtil = SnapshotUtil

-- Resource formatting rules based on resource type (matches Constants.lua ResourceInfo 1:1)
local resourceFormatting = {
    mana = {
        decimals = 0,
        useK = true,
        kThreshold = 100000
    },
    rage            = { decimals = 0 },
    focus           = { decimals = 0 },
    energy          = { decimals = 2 },
    combo_points    = { decimals = 0 },
    runes           = { decimals = 0 },
    runic_power     = { decimals = 0 },
    soul_shards     = { decimals = 1 },
    astral_power    = { decimals = 0 },
    holy_power      = { decimals = 0 },
    alternate       = { decimals = 0 },
    maelstrom       = { decimals = 0 },
    chi             = { decimals = 0 },
    insanity        = { decimals = 0 },
    obsolete        = { decimals = 2 },
    obsolete2       = { decimals = 2 },
    arcane_charges  = { decimals = 0 },
    fury            = { decimals = 0 },
    pain            = { decimals = 0 },
    essence         = { decimals = 0 },
    none            = { decimals = 2 }
}

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================

-- Formats a number based on resource type
function SnapshotUtil.FormatResourceNumber( value, resourceKey )
    local rules = resourceFormatting[ resourceKey ] or { decimals = 2 }

    -- Handle K formatting for mana
    if rules.useK and rules.kThreshold and value >= rules.kThreshold then
        if value >= 1000000 then
            return format( "%.1fM", value / 1000000 )
        else
            return format( "%.0fK", value / 1000 )
        end
    end

    -- Standard decimal formatting
    if rules.decimals == 0 then
        return format( "%.0f", value )
    else
        return format( "%." .. rules.decimals .. "f", value )
    end
end

-- ==========================================
-- EVENT QUEUE FORMATTING
-- ==========================================

-- Formats and displays the event queue at the beginning of recommendations
function SnapshotUtil.FormatEventQueue()
    local events = state:GetQueue()

    if #events == 0 then
        return "### Event Queue ###\nNo events queued.\n"
    end

    local output = {}

    output[ #output + 1 ] = format( "### Event Queue - %d events to review ###", #events )
    output[ #output + 1 ] = "Order | Action          | Type               | Time    | Triggers"
    output[ #output + 1 ] = "------|-----------------|--------------------|---------|--------------------------"

    for i, event in ipairs( events ) do
        local eventTime = event.time - state.now - state.offset
        local action = event.action or "unknown"
        local eType = event.type or "unknown"
        local triggers = SnapshotUtil.GetEventTriggers( event, action, eType )

        output[ #output + 1 ] = format( " #%-3d | %-15s | %-18s | +%6.2f | %s", i, action, eType, eventTime, triggers )
    end

    output[ #output + 1 ] = "" -- Add blank line after events list

    return table.concat( output, "\n" ) .. "\n"
end

-- Determines what gets triggered for a specific event
function SnapshotUtil.GetEventTriggers( event, action, eType )
    local triggers = "unknown"

    if eType == "AURA_EXPIRATION" or eType == "AURA_PERIODIC" then
        if event.func then
            triggers = "Local Class Function"
        else
            triggers = format( "removeBuff( \"%s\" )", action )
        end
    elseif eType == "PROJECTILE_IMPACT" then
        local ability = class.abilities[ action ]
        if ability and ability.impact then
            triggers = action .. ".impact()"
        else
            triggers = "no impact handler"
        end
    elseif eType == "CAST_FINISH" then
        local ability = class.abilities[ action ]
        if ability and ability.handler then
            triggers = action .. ".handler()"
        else
            triggers = "no handler"
        end
    elseif eType == "CHANNEL_TICK" then
        local ability = class.abilities[ action ]
        if ability and ability.tick then
            triggers = action .. ".tick()"
        else
            triggers = "no tick handler"
        end
    elseif eType == "CHANNEL_FINISH" then
        local ability = class.abilities[ action ]
        if ability and ability.finish then
            triggers = action .. ".finish()"
        else
            triggers = "no finish handler"
        end
    end

    return triggers
end

-- ==========================================
-- RESOURCE FORMATTING
-- ==========================================

-- Formats resources in table format for main recommendation display
function SnapshotUtil.FormatResourcesTable( includeDeltas, previousResources )
    local output = {}

    if includeDeltas and previousResources then
        output[ #output + 1 ] = "### Resources ###"
        output[ #output + 1 ] = "| Resource      | Current | Max       | Usage | Delta |"
        output[ #output + 1 ] = "|---------------|---------|-----------|-------|-------|"
    else
        output[ #output + 1 ] = "### Resources ###"
        output[ #output + 1 ] = "| Resource      | Current | Max       | Usage |"
        output[ #output + 1 ] = "|---------------|---------|-----------|-------|"
    end

    for k in orderedPairs( class.resources ) do
        local current = state[ k ].current
        local maximum = state[ k ].max
        local usage = maximum > 0 and math.floor( ( current / maximum ) * 100 ) or 0

        -- Format resource name (capitalize first letter, replace underscores)
        local resourceName = k:gsub( "_", " " ):gsub( "(%a)([%w_']*)", function( first, rest )
            return first:upper() .. rest:lower()
        end )

        -- Format numbers for display based on resource type
        local currentStr = SnapshotUtil.FormatResourceNumber( current, k )
        local maxStr = SnapshotUtil.FormatResourceNumber( maximum, k )

        if includeDeltas and previousResources and previousResources[ k ] then
            local delta = current - previousResources[ k ].current
            local deltaStr = delta > 0 and ( "+" .. SnapshotUtil.FormatResourceNumber( delta, k ) ) or SnapshotUtil.FormatResourceNumber( delta, k )
            output[ #output + 1 ] = format( "| %-13s | %7s | %9s | %4d%% | %5s |", resourceName, currentStr, maxStr, usage, deltaStr )
        else
            output[ #output + 1 ] = format( "| %-13s | %7s | %9s | %4d%% |", resourceName, currentStr, maxStr, usage )
        end
    end

    output[ #output + 1 ] = "" -- Add blank line after table

    return table.concat( output, "\n" ) .. "\n"
end

-- Formats resources in compact format for other debug prints
function SnapshotUtil.FormatResourcesCompact()
    local output = {}

    for k in orderedPairs( class.resources ) do
        local current = state[ k ].current
        local maximum = state[ k ].max

        local currentStr = SnapshotUtil.FormatResourceNumber( current, k )
        local maxStr = SnapshotUtil.FormatResourceNumber( maximum, k )

        if maximum > 0 then
            output[ #output + 1 ] = format( "%s: %s/%s", k, currentStr, maxStr )
        else
            output[ #output + 1 ] = format( "%s: %s", k, currentStr )
        end
    end

    return table.concat( output, ", " )
end

-- Captures current resource state for delta calculations
function SnapshotUtil.CaptureResourceState()
    local resources = {}

    for k in orderedPairs( class.resources ) do
        resources[ k ] = {
            current = state[ k ].current,
            max = state[ k ].max
        }
    end

    return resources
end

-- ==========================================
-- SNAPSHOT SECTION HELPERS
-- ==========================================

-- Formats target information
function SnapshotUtil.FormatTargets()
    return format( "### Targets ###\n\ndetected_targets:  %s", Hekili.TargetDebug or "no data" )
end

-- Formats performance metrics
function SnapshotUtil.FormatPerformance()
    local performance = ""
    local pInfo = HekiliEngine.threadUpdates

    if pInfo then
        performance = format( "### Performance ###\n\nThread Updates: %d", pInfo )
    else
        performance = "### Performance ###\n\nNo performance data available."
    end

    return performance
end

-- ==========================================
-- DISPLAY OUTPUT FUNCTIONS
-- ==========================================

-- Outputs event queue to debug log
function SnapshotUtil.DebugEventQueue()
    local events = state:GetQueue()

    if #events > 0 then
        local eventOutput = SnapshotUtil.FormatEventQueue()
        for line in eventOutput:gmatch( "[^\n]+" ) do
            Hekili:Debug( 1, line )
        end
        Hekili:Debug( 1, "" ) -- Add blank line after event queue
    end
end

-- Outputs resources to debug log in table format
function SnapshotUtil.DebugResourcesTable( includeDeltas, previousResources )
    local resourceOutput = SnapshotUtil.FormatResourcesTable( includeDeltas, previousResources )
    for line in resourceOutput:gmatch( "[^\n]+" ) do
        Hekili:Debug( 1, line )
    end
    Hekili:Debug( 1, "" ) -- Add blank line after resource table
end

-- Outputs resources to debug log in compact format
function SnapshotUtil.DebugResourcesCompact()
    local resourceOutput = SnapshotUtil.FormatResourcesCompact()
    Hekili:Debug( 1, "Resources: " .. resourceOutput )
end

-- ==========================================
-- PROFILE GENERATION FUNCTIONS
-- ==========================================

-- Formats the profile header with build, level, class, spec info
function SnapshotUtil.FormatProfileHeader()
    local s = state
    local spec = s.spec.key
    local heroTree = state.hero_tree.current or "none"

    return format(
        "build: %s\n" ..
        "level: %d (%d)\n" ..
        "class: %s\n" ..
        "spec: %s\n" ..
        "hero tree: %s\n\n",
        Hekili.Version or "no info",
        UnitLevel( 'player' ) or 0,
        UnitEffectiveLevel( 'player' ) or 0,
        class.file or "NONE",
        spec or "none",
        heroTree or "none"
    )
end

-- Formats the talents section with import string and talent list
function SnapshotUtil.FormatTalents()
    local s = state
    local talents = Hekili:GetLoadoutExportString()

    for k, v in orderedPairs( s.talent ) do
        if v.enabled then
            if talents then
                talents = format( "%s\n    %s = %d/%d", talents, k, v.rank, v.max )
            else
                talents = format( "%s = %d/%d", k, v.rank, v.max )
            end
        end
    end

    return format(
        "### Talents ###\n\n" ..
        "In-Game Import: %s\n",
        talents or "none"
    )
end

-- Formats the PvP talents section
function SnapshotUtil.FormatPvPTalents()
    local s = state
    local pvptalents

    for k, v in orderedPairs( s.pvptalent ) do
        if v.enabled then
            if pvptalents then
                pvptalents = format( "%s\n   %s", pvptalents, k )
            else
                pvptalents = k
            end
        end
    end

    return format(
        "\nPvP Talents: %s\n\n",
        pvptalents or "none"
    )
end

-- Formats the legacy content section (covenant, conduits, soulbinds, legendaries)
function SnapshotUtil.FormatLegacyContent()
    local s = state

    -- Covenant detection
    local covenants = { "kyrian", "necrolord", "night_fae", "venthyr" }
    local covenant = "none"
    for i, v in ipairs( covenants ) do
        if state.covenant[ v ] then
            covenant = v
            break
        end
    end

    -- Conduits
    local conduits
    for k, v in orderedPairs( s.conduit ) do
        if v.enabled then
            if conduits then
                conduits = format("%s\n   %s = %d", conduits, k, v.rank)
            else
                conduits = format("%s = %d", k, v.rank)
            end
        end
    end

    -- Soulbinds
    local soulbinds
    local activeBind = C_Soulbinds.GetActiveSoulbindID()
    if activeBind then
        soulbinds = "[" .. formatKey(C_Soulbinds.GetSoulbindData(activeBind).name) .. "]"
    end

    for k, v in orderedPairs(s.soulbind) do
        if v.enabled then
            if soulbinds then
                soulbinds = format("%s\n   %s = %d", soulbinds, k, v.rank)
            else
                soulbinds = format("%s = %d", k, v.rank)
            end
        end
    end

    -- Legendaries
    local legendaries
    for k, v in orderedPairs(state.legendary) do
        if k ~= "no_trait" and v.rank > 0 then
            if legendaries then
                legendaries = format("%s\n    %s = %d", legendaries, k, v.rank)
            else
                legendaries = format("%s = %d", k, v.rank)
            end
        end
    end

    return format(
        "### Legacy Content ###\n\n" ..
        "covenant: %s\n" ..
        "conduits: %s\n" ..
        "soulbinds: %s\n" ..
        "legendaries: %s\n\n",
        covenant or "none",
        conduits or "none",
        soulbinds or "none",
        legendaries or "none"
    )
end

-- Formats the gear and items section
function SnapshotUtil.FormatGearAndItems()
    local s = state

    -- Sets
    local sets
    for k, v in orderedPairs(class.gear) do
        if s.set_bonus[k] > 0 then
            if sets then
                sets = format("%s\n    %s = %d", sets, k, s.set_bonus[k])
            else
                sets = format("%s = %d", k, s.set_bonus[k])
            end
        end
    end

    -- Gear and Items
    local gear, items
    for k, v in orderedPairs(state.set_bonus) do
        if type(v) == "number" and v > 0 then
            if type(k) == 'string' then
                if gear then
                    gear = format("%s\n    %s = %d", gear, k, v)
                else
                    gear = format("%s = %d", k, v)
                end
            elseif type(k) == 'number' then
                if items then
                    items = format("%s, %d", items, k)
                else
                    items = tostring(k)
                end
            end
        end
    end

    return format(
        "### Gear & Items ###\n\n" ..
        "sets:\n    %s\n\n" ..
        "gear:\n    %s\n\n" ..
        "itemIDs: %s\n\n",
        sets or "none",
        gear or "none",
        items or "none"
    )
end

-- Formats the settings section
function SnapshotUtil.FormatSettings()
    local s = state
    local settings

    if s.settings.spec then
        for k, v in orderedPairs(s.settings.spec) do
            if type(v) ~= "table" then
                if settings then
                    settings = format("%s\n    %s = %s", settings, k, tostring(v))
                else
                    settings = format("%s = %s", k, tostring(v))
                end
            end
        end
        for k, v in orderedPairs(s.settings.spec.settings) do
            if type(v) ~= "table" then
                if settings then
                    settings = format("%s\n    %s = %s", settings, k, tostring(v))
                else
                    settings = format("%s = %s", k, tostring(v))
                end
            end
        end
    end

    return format(
        "### Settings ###\n\n" ..
        "Settings:\n    %s\n\n",
        settings or "none"
    )
end

-- Formats the toggles section
function SnapshotUtil.FormatToggles()
    local toggles

    for k, v in orderedPairs(Hekili.DB.profile.toggles) do
        if type(v) == "table" and rawget(v, "value") ~= nil then
            if toggles then
                toggles = format("%s\n    %s = %s %s", toggles, k, tostring(v.value),
                    (v.separate and "[separate]" or
                     (k ~= "cooldowns" and v.override and Hekili.DB.profile.toggles.cooldowns.value and "[overridden]") or ""))
            else
                toggles = format("%s = %s %s", k, tostring(v.value),
                    (v.separate and "[separate]" or
                     (k ~= "cooldowns" and v.override and Hekili.DB.profile.toggles.cooldowns.value and "[overridden]") or ""))
            end
        end
    end

    return format(
        "Toggles:\n    %s\n\n",
        toggles or "none"
    )
end

-- Formats the keybinds section
function SnapshotUtil.FormatKeybinds()
    local keybinds = ""
    local bindLength = 1

    -- Find longest keybind name for alignment
    for name in pairs(Hekili.KeybindInfo) do
        if name:len() > bindLength then
            bindLength = name:len()
        end
    end

    -- Format keybinds
    for name, data in orderedPairs(Hekili.KeybindInfo) do
        local action = format("%-" .. bindLength .. "s =", name)
        local count = 0
        for i = 1, 12 do
            local bar = data.upper[i]
            if bar then
                if count > 0 then action = action .. "," end
                action = format("%s %-4s[%02d]", action, bar, i)
                count = count + 1
            end
        end
        keybinds = keybinds .. "\n    " .. action
    end

    return format(
        "Keybinds:%s\n\n",
        keybinds or "none"
    )
end

-- Formats the warnings section
function SnapshotUtil.FormatWarnings()
    local warnings

    for i, err in ipairs(Hekili.ErrorKeys) do
        if warnings then
            warnings = format("%s\n[#%d] %s", warnings, i, err:gsub("\n\n", "\n"))
        else
            warnings = format("[#%d] %s", i, err:gsub("\n\n", "\n"))
        end
    end

    return format(
        "### Warnings ###\n\n%s\n",
        warnings or "none"
    )
end

-- Main profile generation function that orchestrates all sections
function SnapshotUtil.GenerateProfile()
    return SnapshotUtil.FormatProfileHeader() ..
           SnapshotUtil.FormatTalents() ..
           SnapshotUtil.FormatPvPTalents() ..
           SnapshotUtil.FormatLegacyContent() ..
           SnapshotUtil.FormatGearAndItems() ..
           SnapshotUtil.FormatSettings() ..
           SnapshotUtil.FormatToggles() ..
           SnapshotUtil.FormatKeybinds() ..
           SnapshotUtil.FormatWarnings()
end

return SnapshotUtil