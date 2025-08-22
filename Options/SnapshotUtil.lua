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

-- Calculates optimal column widths for a table based on content and headers
function SnapshotUtil.CalculateTableWidths( items, columnConfigs, headers )
    local widths = {}

    -- Initialize widths with minimum values from config
    for i, config in ipairs( columnConfigs ) do
        widths[ i ] = config.minWidth or 8
    end

    -- Use header width as minimum baseline if headers provided
    if headers then
        for i, header in ipairs( headers ) do
            if columnConfigs[ i ] then
                local headerWidth = #header + 2  -- +2 for spaces around header in table
                widths[ i ] = math.max( widths[ i ], headerWidth )
            end
        end
    end

    -- Scan all items to find maximum content width for each column
    for _, item in ipairs( items ) do
        for i, value in ipairs( item ) do
            if columnConfigs[ i ] then
                local valueStr = tostring( value or "" )
                local contentWidth = #valueStr

                -- Add padding if specified
                if columnConfigs[ i ].padding then
                    contentWidth = contentWidth + columnConfigs[ i ].padding
                end

                widths[ i ] = math.max( widths[ i ], contentWidth )
            end
        end
    end

    return widths
end

-- Generates table header and separator lines with calculated widths
function SnapshotUtil.GenerateTableHeaders( headers, widths )
    local headerLine = ""
    local separatorLine = ""

    for i, header in ipairs( headers ) do
        local width = widths[ i ] or 8
        local headerStr = " " .. header
        local paddingNeeded = width - #headerStr - 1  -- -1 for trailing space
        if paddingNeeded > 0 then
            headerStr = headerStr .. string.rep( " ", paddingNeeded )
        end
        headerStr = headerStr .. " "
        
        if i > 1 then
            headerLine = headerLine .. "|"
            separatorLine = separatorLine .. "|"
        end
        
        headerLine = headerLine .. headerStr
        separatorLine = separatorLine .. string.rep( "-", width )
    end

    return headerLine, separatorLine
end

-- Generates a table row with calculated widths
function SnapshotUtil.GenerateTableRow( values, widths )
    local row = ""

    for i, value in ipairs( values ) do
        local width = widths[ i ] or 8
        local valueStr = " " .. tostring( value or "" )
        local paddingNeeded = width - #valueStr - 1  -- -1 for trailing space
        if paddingNeeded > 0 then
            valueStr = valueStr .. string.rep( " ", paddingNeeded )
        end
        valueStr = valueStr .. " "
        
        if i > 1 then
            row = row .. "|"
        end
        
        row = row .. valueStr
    end

    return row
end

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

    output[ #output + 1 ] = "### Resources ###"

    -- Collect resources data for width calculation
    local resourcesData = {}
    for k in orderedPairs( class.resources ) do
        local current = state[ k ].current
        local maximum = state[ k ].max
        local usage = maximum > 0 and math.floor( ( current / maximum ) * 100 ) or 0

        -- Use key/token format for resource name (no formatting)
        local resourceName = k

        -- Format numbers for display based on resource type
        local currentStr = SnapshotUtil.FormatResourceNumber( current, k )
        local maxStr = SnapshotUtil.FormatResourceNumber( maximum, k )
        local usageStr = format( "%d%%", usage )

        if includeDeltas and previousResources and previousResources[ k ] then
            local delta = current - previousResources[ k ].current
            local deltaStr = delta > 0 and ( "+" .. SnapshotUtil.FormatResourceNumber( delta, k ) ) or SnapshotUtil.FormatResourceNumber( delta, k )
            resourcesData[ #resourcesData + 1 ] = { resourceName, currentStr, maxStr, usageStr, deltaStr }
        else
            resourcesData[ #resourcesData + 1 ] = { resourceName, currentStr, maxStr, usageStr }
        end
    end

    -- Calculate optimal column widths
    local columnConfigs
    if includeDeltas and previousResources then
        columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Resource name
            { minWidth = 6, padding = 2 },  -- Current
            { minWidth = 5, padding = 2 },  -- Max
            { minWidth = 5, padding = 2 },  -- Usage
            { minWidth = 5, padding = 2 }   -- Delta
        }
    else
        columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Resource name
            { minWidth = 6, padding = 2 },  -- Current
            { minWidth = 5, padding = 2 },  -- Max
            { minWidth = 5, padding = 2 }   -- Usage
        }
    end
    local headers
    if includeDeltas and previousResources then
        headers = { "Resource", "Current", "Max", "Usage", "Delta" }
    else
        headers = { "Resource", "Current", "Max", "Usage" }
    end
    local widths = SnapshotUtil.CalculateTableWidths( resourcesData, columnConfigs, headers )

    -- Generate headers
    local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
    output[ #output + 1 ] = headerLine
    output[ #output + 1 ] = separatorLine

    -- Generate rows
    for _, rowData in ipairs( resourcesData ) do
        output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
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
    local importString = Hekili:GetLoadoutExportString()
    local output = {}

    output[ #output + 1 ] = "### Talents ###"
    output[ #output + 1 ] = ""
    output[ #output + 1 ] = format( "**Import String:** `%s`", importString or "none" )
    output[ #output + 1 ] = ""

    -- Collect talent data for width calculation
    local talentData = {}
    for k, v in orderedPairs( s.talent ) do
        if v.enabled then
            local rankDisplay = ""
            -- Only show rank if max rank > 1
            if v.max > 1 then
                rankDisplay = format( "%d / %d", v.rank, v.max )
            end
            talentData[ #talentData + 1 ] = { k, rankDisplay }
        end
    end

    -- Calculate optimal column widths
    local columnConfigs = {
        { minWidth = 8, padding = 2 },  -- Talent name
        { minWidth = 6, padding = 2 }   -- Rank
    }
    local headers = { "Talent", "Rank" }
    local widths = SnapshotUtil.CalculateTableWidths( talentData, columnConfigs, headers )

    -- Generate headers
    local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
    output[ #output + 1 ] = headerLine
    output[ #output + 1 ] = separatorLine

    -- Generate rows
    for _, rowData in ipairs( talentData ) do
        output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
    end

    output[ #output + 1 ] = ""
    return table.concat( output, "\n" ) .. "\n"
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
    local output = {}

    output[ #output + 1 ] = "### Legacy Content ###"
    output[ #output + 1 ] = ""

    -- Covenant detection
    local covenants = { "kyrian", "necrolord", "night_fae", "venthyr" }
    local covenant = "none"
    for i, v in ipairs( covenants ) do
        if state.covenant[ v ] then
            covenant = v
            break
        end
    end
    output[ #output + 1 ] = format( "**Covenant:** %s", covenant )
    output[ #output + 1 ] = ""

    -- Conduits
    local hasConduits = false
    for k, v in orderedPairs( s.conduit ) do
        if v.enabled then
            hasConduits = true
            break
        end
    end

    if hasConduits then
        -- Collect conduits data for width calculation
        local conduitsData = {}
        for k, v in orderedPairs( s.conduit ) do
            if v.enabled then
                conduitsData[ #conduitsData + 1 ] = { k, tostring( v.rank ) }
            end
        end

        -- Calculate optimal column widths
        local columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Conduit name
            { minWidth = 4, padding = 2 }   -- Rank
        }
        local headers = { "Conduit", "Rank" }
        local widths = SnapshotUtil.CalculateTableWidths( conduitsData, columnConfigs, headers )

        output[ #output + 1 ] = "**Conduits:**"
        local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
        output[ #output + 1 ] = headerLine
        output[ #output + 1 ] = separatorLine

        -- Generate rows
        for _, rowData in ipairs( conduitsData ) do
            output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
        end
        output[ #output + 1 ] = ""
    else
        output[ #output + 1 ] = "**Conduits:** None"
        output[ #output + 1 ] = ""
    end

    -- Soulbinds
    local hasSoulbinds = false
    local activeBind = C_Soulbinds.GetActiveSoulbindID()

    if activeBind then
        hasSoulbinds = true
    else
        for k, v in orderedPairs( s.soulbind ) do
            if v.enabled then
                hasSoulbinds = true
                break
            end
        end
    end

    if hasSoulbinds then
        -- Collect soulbinds data for width calculation
        local soulbindsData = {}

        if activeBind then
            soulbindsData[ #soulbindsData + 1 ] = { "[" .. formatKey( C_Soulbinds.GetSoulbindData( activeBind ).name ) .. "]", "active" }
        end

        for k, v in orderedPairs( s.soulbind ) do
            if v.enabled then
                soulbindsData[ #soulbindsData + 1 ] = { k, tostring( v.rank ) }
            end
        end

        -- Calculate optimal column widths
        local columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Soulbind name
            { minWidth = 6, padding = 2 }   -- Rank
        }
        local headers = { "Soulbind", "Rank" }
        local widths = SnapshotUtil.CalculateTableWidths( soulbindsData, columnConfigs, headers )

        output[ #output + 1 ] = "**Soulbinds:**"
        local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
        output[ #output + 1 ] = headerLine
        output[ #output + 1 ] = separatorLine

        -- Generate rows
        for _, rowData in ipairs( soulbindsData ) do
            output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
        end
        output[ #output + 1 ] = ""
    else
        output[ #output + 1 ] = "**Soulbinds:** None"
        output[ #output + 1 ] = ""
    end

    -- Legendaries
    local hasLegendaries = false
    for k, v in orderedPairs( state.legendary ) do
        if k ~= "no_trait" and v.rank > 0 then
            hasLegendaries = true
            break
        end
    end

    if hasLegendaries then
        -- Collect legendaries data for width calculation
        local legendariesData = {}
        for k, v in orderedPairs( state.legendary ) do
            if k ~= "no_trait" and v.rank > 0 then
                legendariesData[ #legendariesData + 1 ] = { k, tostring( v.rank ) }
            end
        end

        -- Calculate optimal column widths
        local columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Legendary name
            { minWidth = 4, padding = 2 }   -- Rank
        }
        local headers = { "Legendary", "Rank" }
        local widths = SnapshotUtil.CalculateTableWidths( legendariesData, columnConfigs, headers )

        output[ #output + 1 ] = "**Legendaries:**"
        local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
        output[ #output + 1 ] = headerLine
        output[ #output + 1 ] = separatorLine

        -- Generate rows
        for _, rowData in ipairs( legendariesData ) do
            output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
        end
        output[ #output + 1 ] = ""
    else
        output[ #output + 1 ] = "**Legendaries:** None"
        output[ #output + 1 ] = ""
    end

    return table.concat( output, "\n" ) .. "\n"
end

-- Formats the gear and items section
function SnapshotUtil.FormatGearAndItems()
    local s = state
    local output = {}

    output[ #output + 1 ] = "### Gear & Items ###"
    output[ #output + 1 ] = ""

    -- Sets
    local hasSets = false
    for k, v in orderedPairs( class.gear ) do
        if s.set_bonus[ k ] > 0 then
            hasSets = true
            break
        end
    end

    if hasSets then
        -- Collect sets data for width calculation
        local setsData = {}
        for k, v in orderedPairs( class.gear ) do
            if s.set_bonus[ k ] > 0 then
                local countDisplay = ""
                -- Only show count if > 1
                if s.set_bonus[ k ] > 1 then
                    countDisplay = tostring( s.set_bonus[ k ] )
                end
                setsData[ #setsData + 1 ] = { k, countDisplay }
            end
        end

        -- Calculate optimal column widths for sets
        local columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Item name
            { minWidth = 3, padding = 2 }   -- Count
        }
        local headers = { "Item", "#" }
        local widths = SnapshotUtil.CalculateTableWidths( setsData, columnConfigs, headers )

        output[ #output + 1 ] = "**Sets:**"
        local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
        output[ #output + 1 ] = headerLine
        output[ #output + 1 ] = separatorLine

        -- Generate rows
        for _, rowData in ipairs( setsData ) do
            output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
        end
        output[ #output + 1 ] = ""
    else
        output[ #output + 1 ] = "**Sets:** None"
        output[ #output + 1 ] = ""
    end

    -- Gear
    local hasGear = false
    local items = {}
    for k, v in orderedPairs( state.set_bonus ) do
        if type( v ) == "number" and v > 0 then
            if type( k ) == 'string' then
                hasGear = true
            elseif type( k ) == 'number' then
                items[ #items + 1 ] = tostring( k )
            end
        end
    end

    if hasGear then
        -- Collect gear data for width calculation
        local gearData = {}
        for k, v in orderedPairs( state.set_bonus ) do
            if type( v ) == "number" and v > 0 and type( k ) == 'string' then
                local countDisplay = ""
                -- Only show count if > 1
                if v > 1 then
                    countDisplay = tostring( v )
                end
                gearData[ #gearData + 1 ] = { k, countDisplay, "NYI" }
            end
        end

        -- Calculate optimal column widths for gear
        local columnConfigs = {
            { minWidth = 8, padding = 2 },  -- Item name
            { minWidth = 3, padding = 2 },  -- Count
            { minWidth = 8, padding = 2 }   -- Item IDs
        }
        local headers = { "Item", "#", "Item IDs" }
        local widths = SnapshotUtil.CalculateTableWidths( gearData, columnConfigs, headers )

        output[ #output + 1 ] = "**Gear:**"
        local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
        output[ #output + 1 ] = headerLine
        output[ #output + 1 ] = separatorLine

        -- Generate rows
        for _, rowData in ipairs( gearData ) do
            output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
        end
        output[ #output + 1 ] = ""
    else
        output[ #output + 1 ] = "**Gear:** None"
        output[ #output + 1 ] = ""
    end

    -- Item IDs
    output[ #output + 1 ] = format( "**Item IDs:** %s", #items > 0 and table.concat( items, ", " ) or "None" )
    output[ #output + 1 ] = ""

    return table.concat( output, "\n" ) .. "\n"
end

-- Formats the settings section
function SnapshotUtil.FormatSettings()
    local s = state
    local output = {}

    output[ #output + 1 ] = "### Settings ###"

    -- Collect settings data for width calculation
    local settingsData = {}
    local hasSettings = false

    if s.settings.spec then
        for k, v in orderedPairs( s.settings.spec ) do
            if type( v ) ~= "table" then
                hasSettings = true
                settingsData[ #settingsData + 1 ] = { k, tostring( v ) }
            end
        end
        for k, v in orderedPairs( s.settings.spec.settings ) do
            if type( v ) ~= "table" then
                hasSettings = true
                settingsData[ #settingsData + 1 ] = { k, tostring( v ) }
            end
        end
    end

    if not hasSettings then
        settingsData[ #settingsData + 1 ] = { "none", "-" }
    end

    -- Calculate optimal column widths
    local columnConfigs = {
        { minWidth = 8, padding = 2 },  -- Setting name
        { minWidth = 6, padding = 2 }   -- Value
    }
    local headers = { "Setting", "Value" }
    local widths = SnapshotUtil.CalculateTableWidths( settingsData, columnConfigs, headers )

    -- Generate headers
    local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
    output[ #output + 1 ] = headerLine
    output[ #output + 1 ] = separatorLine

    -- Generate rows
    for _, rowData in ipairs( settingsData ) do
        output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
    end

    output[ #output + 1 ] = ""
    return table.concat( output, "\n" ) .. "\n"
end

-- Formats the toggles section
function SnapshotUtil.FormatToggles()
    local output = {}

    output[ #output + 1 ] = "### Toggles ###"

    -- Collect toggles data for width calculation
    local togglesData = {}
    local hasToggles = false

    for k, v in orderedPairs( Hekili.DB.profile.toggles ) do
        if type( v ) == "table" and rawget( v, "value" ) ~= nil then
            hasToggles = true
            local status = tostring( v.value )
            local subsetting = ""

            if v.separate then
                subsetting = "separate"
            elseif k ~= "cooldowns" and v.override and Hekili.DB.profile.toggles.cooldowns.value then
                subsetting = "overridden"
            else
                subsetting = "-"
            end

            togglesData[ #togglesData + 1 ] = { k, status, subsetting }
        end
    end

    if not hasToggles then
        togglesData[ #togglesData + 1 ] = { "none", "-", "-" }
    end

    -- Calculate optimal column widths
    local columnConfigs = {
        { minWidth = 6, padding = 2 },  -- Toggle name
        { minWidth = 6, padding = 2 },  -- Status
        { minWidth = 8, padding = 2 }   -- Sub-setting
    }
    local headers = { "Toggle", "Status", "Sub-setting" }
    local widths = SnapshotUtil.CalculateTableWidths( togglesData, columnConfigs, headers )

    -- Generate headers
    local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
    output[ #output + 1 ] = headerLine
    output[ #output + 1 ] = separatorLine

    -- Generate rows
    for _, rowData in ipairs( togglesData ) do
        output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
    end

    output[ #output + 1 ] = ""
    return table.concat( output, "\n" ) .. "\n"
end

-- Formats the keybinds section
function SnapshotUtil.FormatKeybinds()
    local output = {}

    output[ #output + 1 ] = "### Keybinds ###"

    -- Collect keybinds data for width calculation
    local keybindsData = {}
    local hasKeybinds = false

    for name, data in orderedPairs( Hekili.KeybindInfo ) do
        hasKeybinds = true
        local binds = {}
        for i = 1, 12 do
            local bar = data.upper[ i ]
            if bar then
                binds[ #binds + 1 ] = { bar = bar, slot = i }
            end
        end

        -- Fill up to 3 binds max
        local bind1 = binds[1] and binds[1].bar or "-"
        local bar1 = binds[1] and format( "%02d", binds[1].slot ) or "-"
        local bind2 = binds[2] and binds[2].bar or "-"
        local bar2 = binds[2] and format( "%02d", binds[2].slot ) or "-"
        local bind3 = binds[3] and binds[3].bar or "-"
        local bar3 = binds[3] and format( "%02d", binds[3].slot ) or "-"

        keybindsData[ #keybindsData + 1 ] = { name, bind1, bar1, bind2, bar2, bind3, bar3 }
    end

    if not hasKeybinds then
        keybindsData[ #keybindsData + 1 ] = { "none", "-", "-", "-", "-", "-", "-" }
    end

    -- Calculate optimal column widths
    local columnConfigs = {
        { minWidth = 8, padding = 2 },  -- Action name
        { minWidth = 4, padding = 2 },  -- Bind 1
        { minWidth = 3, padding = 2 },  -- Bar 1
        { minWidth = 4, padding = 2 },  -- Bind 2
        { minWidth = 3, padding = 2 },  -- Bar 2
        { minWidth = 4, padding = 2 },  -- Bind 3
        { minWidth = 3, padding = 2 }   -- Bar 3
    }
    local headers = { "Action", "Bind 1", "Bar 1", "Bind 2", "Bar 2", "Bind 3", "Bar 3" }
    local widths = SnapshotUtil.CalculateTableWidths( keybindsData, columnConfigs, headers )

    -- Generate headers
    local headerLine, separatorLine = SnapshotUtil.GenerateTableHeaders( headers, widths )
    output[ #output + 1 ] = headerLine
    output[ #output + 1 ] = separatorLine

    -- Generate rows
    for _, rowData in ipairs( keybindsData ) do
        output[ #output + 1 ] = SnapshotUtil.GenerateTableRow( rowData, widths )
    end

    output[ #output + 1 ] = ""
    return table.concat( output, "\n" ) .. "\n"
end

-- Formats the warnings section
function SnapshotUtil.FormatWarnings()
    local warnings

    for i, err in ipairs( Hekili.ErrorKeys ) do
        if warnings then
            warnings = format( "%s\n[#%d] %s", warnings, i, err:gsub( "\n\n", "\n" ) )
        else
            warnings = format( "[#%d] %s", i, err:gsub( "\n\n", "\n" ) )
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