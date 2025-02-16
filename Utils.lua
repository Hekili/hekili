-- Utils.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]

local format, gsub, lower = string.format, string.gsub, string.lower
local insert, remove = table.insert, table.remove

local class = Hekili.Class
local state = Hekili.State

local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetBuffDataByIndex, GetDebuffDataByIndex = C_UnitAuras.GetBuffDataByIndex, C_UnitAuras.GetDebuffDataByIndex
local FindAura = AuraUtil.FindAura
local UnpackAuraData = AuraUtil.UnpackAuraData

local GetSpellBookItemInfo = function(index, bookType)
    local spellBank = ( bookType == "spell" or bookType == Enum.SpellBookItemType.Spell ) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet
    local info = C_SpellBook.GetSpellBookItemInfo(index, spellBank)
    if info then return info.name, info.icon, info.spellID end
end

ns.UnitBuff = function( unit, index, filter )
    return UnpackAuraData( GetBuffDataByIndex( unit, index, filter ) )
end

ns.UnitDebuff = function( unit, index, filter )
    return UnpackAuraData( GetDebuffDataByIndex( unit, index, filter ) )
end


ns.UnitBuffByID = function( unitToken, spellID, filter )
    local playerOrPet = UnitIsUnit( "player", unitToken ) or UnitIsUnit( "pet", unitToken )
    filter = filter or "HELPFUL"

    return FindAura( function( _, _, _, ... )
        local id, isFromPlayerOrPet = select( 10, ... ), select( 13, ... )
        return id == spellID and ( not playerOrPet or isFromPlayerOrPet )
    end, unitToken, filter )
end

ns.FindUnitBuffByID = ns.UnitBuffByID

ns.UnitDebuffByID = function( unitToken, spellID, filter )
    local playerOrPet = UnitIsUnit( "player", unitToken ) or UnitIsUnit( "pet", unitToken )
    filter = filter or "HARMFUL"

    return FindAura( function( _, _, _, ... )
        local id, isFromPlayerOrPet = select( 10, ... ), select( 13, ... )
        return id == spellID and ( not playerOrPet or isFromPlayerOrPet )
    end, unitToken, filter )
end

ns.FindUnitDebuffByID = ns.UnitDebuffByID

local UnitBuff, UnitDebuff = ns.UnitBuff, ns.UnitDebuff
local UnitBuffByID, UnitDebuffByID = ns.UnitBuffByID, ns.UnitDebuffByID

local GetItemInfo = C_Item.GetItemInfo
local GetSpellInfo = C_Spell.GetSpellInfo

local errors = {}
local eIndex = {}

ns.Error = function( output, ... )
    if ... then
        output = format( output, ... )
    end

    if not errors[ output ] then
        errors[ output ] = {
            n = 1,
            last = date( "%X", time() )
        }
        eIndex[ #eIndex + 1 ] = output
        -- if Hekili.DB.profile.Verbose then Hekili:Print( output ) end
    else
        errors[ output ].n = errors[ output ].n + 1
        errors[ output ].last = date( "%X", time() )
    end
end


function Hekili:Error( ... )
    ns.Error( ... )
end

Hekili.ErrorKeys = eIndex
Hekili.ErrorDB = errors


function Hekili:GetErrors()

    for i = 1, #eIndex do
        Hekili:Print( eIndex[i] .. " (n = " .. errors[ eIndex[i] ].n .. "), last at " .. errors[ eIndex[i] ].last .. "." )
    end

end


function ns.SpaceOut( str )
    str = str:gsub( "([!<>=|&()*%-%+/][?]?)", " %1 " ):gsub("%s+", " ")
    str = str:gsub( "([^%%])([%%]+)([^%%])", "%1 %2 %3" )
    str = str:gsub( "%.%s+%(", ".(" )
    str = str:gsub( "%)%s+%.", ")." )

    str = str:gsub( "([<>~!|]) ([|=])", "%1%2" )
    str = str:trim()
    return str
end


local LT = LibStub( "LibTranslit-1.0" )

-- Converts `s' to a SimC-like key: strip non alphanumeric characters, replace spaces with _, convert to lower case.
function ns.formatKey( s )
    s = s:gsub( "|c........", "" ):gsub( "|r", "" )
    s = LT:Transliterate( s )
    s = lower( s or '' ):gsub( "[^a-z0-9_ ]", "" ):gsub( "%s+", "_" )
    return s
end


ns.titleCase = function( s )
    local helper = function( first, rest )
        return first:upper()..rest:lower()
    end

    return s:gsub( "_", " " ):gsub( "(%a)([%w_']*)", helper ):gsub( "[Aa]oe", "AOE" ):gsub( "[Rr]jw", "RJW" ):gsub( "[Cc]hix", "ChiX" ):gsub( "(%W?)[Ss]t(%W?)", "%1ST%2" )
end


local replacements = {
    ['_'] = " ",
    aoe = "AOE",
    rjw = "RJW",
    chix = "ChiX",
    st = "ST",
    cd = "CD",
    cds = "CDs"
}

ns.titlefy = function( s )
    for k, v in pairs( replacements ) do
        s = s:gsub( '%f[%w]' .. k .. '%f[%W]', v ):gsub( "_", " " )
    end

    return s
end


ns.fsub = function( s, pattern, repl )
    return s:gsub( "%f[%w]" .. s .. "%f[%W]", repl )
end


ns.escapeMagic = function( s )
    return s:gsub( "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1" )
end


local tblUnpack = {}

ns.multiUnpack = function( ... )

    table.wipe( tblUnpack )

    for i = 1, select( '#', ... ) do
        for _, value in ipairs( select( i, ... ) ) do
            tblUnpack[ #tblUnpack + 1 ] = value
        end
    end

    return unpack( tblUnpack )

end


ns.round = function( num, places )

    return tonumber( format( "%." .. ( places or 0 ) .. "f", num ) )

end


function ns.roundUp( num, places )
    num = num or 0
    local tens = 10 ^ ( places or 0 )

    return ceil( num * tens ) / tens
end


function ns.roundDown( num, places )
    num = num or 0
    local tens = 10 ^ ( places or 0 )

    return floor( num * tens ) / tens
end


-- Deep Copy
-- from http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
local function tableCopy( obj, seen )
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[ tableCopy(k, s) ] = tableCopy(v, s) end
    return res
end
ns.tableCopy = tableCopy


local toc = {}
local exclusions = { min = true, max = true, _G = true }

ns.commitKey = function( key )
    if not toc[ key ] and not exclusions[ key ] then
        ns.keys[ #ns.keys + 1 ] = key
        toc[ key ] = 1
    end
end


local orderedIndex = {}

local sortHelper = function( a, b )
    local a1, b1 = tostring(a), tostring(b)

    return a1 < b1
end


local function __genOrderedIndex( t )

    for i = #orderedIndex, 1, -1 do
        orderedIndex[i] = nil
    end

    for key in pairs( t ) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex, sortHelper )
    return orderedIndex
end


local function orderedNext( t, state )
    local key = nil

    if state == nil then
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[ 1 ]
    else
        for i = 1, #t.__orderedIndex do
            if t.__orderedIndex[ i ] == state then
                key = t.__orderedIndex[ i+1 ]
            end
        end
    end

    if key then
        return key, t[ key ]
    end

    t.__orderedIndex = nil
    return
end


function ns.orderedPairs( t )
    return orderedNext, t, nil
end


function ns.safeMin( ... )
    local result

    for i = 1, select( "#", ... ) do
        local val = select( i, ... )
        if val then result = ( not result or val < result ) and val or result end
    end

    return result or 0
end


function ns.safeMax( ... )
    local result

    for i = 1, select( "#", ... ) do
        local val = select( i, ... )
        if val and type(val) == 'number' then result = ( not result or val > result ) and val or result end
    end

    return result or 0
end


function ns.safeAbs( val )
    val = tonumber( val )
    if val < 0 then return -val end
    return val
end


-- Rivers' iterator for group members.
function ns.GroupMembers( reversed, forceParty )
    local unit = ( not forceParty and IsInRaid() ) and 'raid' or 'party'
    local numGroupMembers = forceParty and GetNumSubgroupMembers() or GetNumGroupMembers()
    local i = reversed and numGroupMembers or ( unit == 'party' and 0 or 1 )

    return function()
        local ret

        if i == 0 and unit == 'party' then
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end

        i = i + ( reversed and -1 or 1 )
        return ret
    end
end


-- Use C_Timer.After but allow for function args.
function Hekili:After( time, func, ... )
    local args = { ... }
    local function delayfunc()
        func( unpack( args ) )
    end

    C_Timer.After( time, delayfunc )
end

function ns.FindRaidBuffByID( id )

    local unitName
    local buffCounter = 0
    local buffIterator = 1

    local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3

    if IsInRaid() or IsInGroup() then
        if IsInRaid() then
            unitName = "raid"
            for numGroupMembers=1, GetNumGroupMembers() do
                buffIterator = 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                while( spellID ) do
                    if spellID == id then buffCounter = buffCounter + 1 break end
                    buffIterator = buffIterator + 1
                    name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                end
            end
        elseif IsInGroup() then
            unitName = "party"
            for numGroupMembers=1, GetNumGroupMembers() do
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                while( spellID ) do
                    if spellID == id then buffCounter = buffCounter + 1 break end
                    buffIterator = buffIterator + 1
                    name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                end
            end
            buffIterator = 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( "player", buffIterator )
            while( spellID ) do
                if spellID == id then buffCounter = buffCounter + 1 break end
                buffIterator = buffIterator + 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( "player", buffIterator )
            end

        else
            unitName = "player"
        end

    end

    return buffCounter
end

function ns.FindLowHpPlayerWithoutBuffByID(id)

    local unitName
    local playerWithoutBuff = 0
    local buffFound = false
    local buffIterator = 1
    local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3

    if IsInRaid() or IsInGroup() then
        if IsInRaid() then
            unitName = "raid"
            for numGroupMembers=1, GetNumGroupMembers() do
                buffFound = false
                buffIterator = 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                while( name ) do
                    if spellID == id then buffFound = true break end
                    buffIterator = buffIterator + 1
                    name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                end

                if not buffFound then
                    local player = unitName..numGroupMembers
                    local Health = (UnitHealth(player))/1000
                    local HealthMax = (UnitHealthMax(player))/1000
                    local HealthPercent = (UnitHealth(player)/UnitHealthMax(player))*100

                    if HealthPercent <= 80 and UnitName(player) then
                        playerWithoutBuff = playerWithoutBuff + 1
                    end
                end
            end
        elseif IsInGroup() then
            unitName = "party"
            for numGroupMembers=1, GetNumGroupMembers() do
                buffFound = false
                buffIterator = 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                while( name ) do
                    if spellID == id then buffFound = true break end
                    buffIterator = buffIterator + 1
                    name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                end

                if not buffFound then
                    local player = unitName..numGroupMembers
                    local Health = (UnitHealth(player))/1000
                    local HealthMax = (UnitHealthMax(player))/1000
                    local HealthPercent = (UnitHealth(player)/UnitHealthMax(player))*100

                    if HealthPercent <= 80 and UnitName(player) then
                        playerWithoutBuff = playerWithoutBuff + 1
                    end
                end
            end

            buffFound = false
            buffIterator = 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( "player", buffIterator )
            while( name ) do
                if spellID == id then buffFound = true break end
                buffIterator = buffIterator + 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( "player", buffIterator )
            end

            if not buffFound then
                local player = "player"
                local Health = (UnitHealth(player))/1000
                local HealthMax = (UnitHealthMax(player))/1000
                local HealthPercent = (UnitHealth(player)/UnitHealthMax(player))*100

                if HealthPercent <= 80 then
                    playerWithoutBuff = playerWithoutBuff + 1
                end
            end
        else
            unitName = "player"
        end

    end

    return playerWithoutBuff
end

function ns.FindRaidBuffLowestRemainsByID(id)

    local buffRemainsOld
    local buffRemainsNew
    local buffRemainsReturn
    local unitName = "player"

    local buffIterator = 1
    local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3

    if IsInRaid() or IsInGroup() then
        if IsInRaid() then
            unitName = "raid"
            for numGroupMembers=1, GetNumGroupMembers() do
                buffIterator = 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                while( name ) do
                    if spellID == id then

                        if buffRemainsOld == nil then
                            buffRemainsOld =  expirationTime - GetTime()
                        end

                        local buffRemainsNew = expirationTime - GetTime()

                        if buffRemainsNew < buffRemainsOld then
                            buffRemainsReturn = buffRemainsNew
                        else
                            buffRemainsReturn = buffRemainsOld
                        end

                        break
                    end
                    buffIterator = buffIterator + 1
                    name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                end
            end
        elseif IsInGroup() then
            unitName = "party"
            for numGroupMembers=1, GetNumGroupMembers() do
                buffIterator = 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                while( name ) do
                    if spellID == id then

                        if buffRemainsOld == nil then
                            buffRemainsOld =  expirationTime - GetTime()
                        end

                        local buffRemainsNew = expirationTime - GetTime()

                        if buffRemainsNew < buffRemainsOld then
                            buffRemainsReturn = buffRemainsNew
                        else
                            buffRemainsReturn = buffRemainsOld
                        end

                        break
                    end
                    buffIterator = buffIterator + 1
                    name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unitName..numGroupMembers, buffIterator )
                end
            end

            buffIterator = 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( "player", buffIterator )
            while( name ) do
                if spellID == id then

                    if buffRemainsOld == nil then
                        buffRemainsOld =  expirationTime - GetTime()
                    end

                    local buffRemainsNew = expirationTime - GetTime()

                    if buffRemainsNew < buffRemainsOld then
                        buffRemainsReturn = buffRemainsNew
                    else
                        buffRemainsReturn = buffRemainsOld
                    end

                    break
                end
                buffIterator = buffIterator + 1
                name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( "player", buffIterator )
            end
        end
    end

    return buffRemainsReturn == nil and 0 or buffRemainsReturn
end

local function FindPlayerAuraByID( id )
    local aura = GetPlayerAuraBySpellID( id )

    if aura and aura.name then
        return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, aura.isBossAura, aura.nameplateShowAll, aura.timeMod, unpack( aura.points )
    end
end
ns.FindPlayerAuraByID = FindPlayerAuraByID

-- Duplicate spell info lookup.
function ns.FindUnitBuffByID( unit, id, filter )
    if unit == "player" then return FindPlayerAuraByID( id ) end
    return UnitBuffByID( unit, id, filter )
end


function ns.FindUnitDebuffByID( unit, id, filter )
    if unit == "player" then return FindPlayerAuraByID( id ) end
    return UnitDebuffByID( unit, id, filter )
end


function ns.IsActiveSpell( id )
    local slot = FindSpellBookSlotBySpellID( id )
    if not slot then return false end
    local _, _, spellID = GetSpellBookItemInfo( slot, "spell" )
    return id == spellID
end


function ns.GetUnpackedSpellInfo( spellID )
    if not spellID then
        return nil;
    end

    local spellInfo = GetSpellInfo(spellID);
    if spellInfo then
        return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
    end
end


function Hekili:GetSpellLinkWithTexture( id, size, color )
    if not id then return "" end

    if type( id ) ~= "number" and class.abilities[ id ] then
        id = class.abilities[ id ].id
    end

    local data = GetSpellInfo( id )

    if data and data.name and data.iconID then
        if type( color ) == "boolean" then
            color = color and "ff00ff00" or "ffff0000"
        end

        if color == nil then color = "ff71d5ff" end

        return "|W|T" .. data.iconID .. ":" .. ( size or 0 ) .. ":" .. ( size or "" ) .. ":::64:64:4:60:4:60|t " .. ( color and ( "|c" .. color ) or "" ) .. data.name .. ( color and "|r" or "" ) .. "|w"
    end

    return tostring( id )
end

function Hekili:ZoomedTextureWithText( texture, text )
    if not texture or not text then return end
    return "|W|T" .. texture .. ":0::::64:64:4:60:4:60|t " .. text .. "|w"
end


function state.debugformat( val )
    if val == nil then return "nil" end
    if type( val ) == "number" then return format( "%.2f", val ) end
    return tostring( val )
end


-- Tooltip Parsing Utilities (10.0.2)
do
    local CurrentBuild = Hekili.CurrentBuild
    local tooltip = ns.Tooltip

    local DisableText = {
        _G.SPELL_FAILED_NOT_HERE,
        _G.SPELL_FAILED_INCORRECT_AREA,
        _G.SPELL_FAILED_NOT_IN_MAGE_TOWER,
        _G.TOOLTIP_NOT_IN_MAGE_TOWER,
        _G.LEVEL_LINKED_NOT_USABLE
    }

    local FindStringInTooltip = function( str, id, ttType, reverse, useMatch )
        local data

        if ttType == "spell" then data = C_TooltipInfo.GetSpellByID( id )
        elseif ttType == "item" then data = C_TooltipInfo.GetItemByID( id )
        elseif ttType == "inventory" then data = C_TooltipInfo.GetInventoryItem( "player", id )
        elseif ttType == "conduit" then data = C_TooltipInfo.GetConduit( id, 0 )
        else
            Hekili:Error( "Usage:  FindStringInTooltip( str, id, { spell | item | inventory | conduit }, reverse, useMatch )\n" ..
                "Invalid tooltip type:  '%s'", ttType or "nil" )
            return
        end

        if not data then return end

        if reverse then
            for i = #data.lines, 1, -1 do
                local line = data.lines[ i ]
                if type( str ) == "table" then
                    for _, seek in ipairs( str ) do
                        if ( useMatch and line.leftText:match( seek ) ) or ( not useMatch and line.leftText == seek ) then return true end
                    end
                else
                    if ( useMatch and line.leftText:match( str ) ) or ( not useMatch and line.leftText == str ) then return true end
                end
            end
            return false
        end

        for _, line in ipairs( data ) do
            if type( str ) == "table" then
                for _, seek in ipairs( str ) do
                    if ( useMatch and line.leftText:match( seek ) ) or ( not useMatch and line.leftText == seek ) then return true end
                end
            else
                if ( useMatch and line.leftText:match( str ) ) or ( not useMatch and line.leftText == str ) then return true end
            end
        end

        return false
    end
    ns.FindStringInTooltip = FindStringInTooltip

    local FindStringInSpellTooltip = function( str, spellID, reverse, useMatch )
        return FindStringInTooltip( str, spellID, "spell", reverse, useMatch )
    end
    ns.FindStringInSpellTooltip = FindStringInSpellTooltip

    local FindStringInItemTooltip = function( str, itemID, reverse, useMatch )
        return FindStringInTooltip( str, itemID, "item", reverse, useMatch )
    end
    ns.FindStringInItemTooltip = FindStringInItemTooltip

    -- Note, this is written to assume we're dealing with the player's inventory only; I'm not messing with inspect right now.
    local FindStringInInventoryItemTooltip = function( str, slot, reverse, useMatch )
        return FindStringInTooltip( str, slot, "inventory", reverse, useMatch )
    end
    ns.FindStringInInventoryItemTooltip = FindStringInInventoryItemTooltip

    local FindStringInConduitTooltip = function( str, conduit, reverse, useMatch )
        return FindStringInTooltip( str, conduit, "conduit", reverse, useMatch )
    end
    ns.FindStringInConduitTooltip = FindStringInConduitTooltip

    local DisabledSpells = {}

    local IsSpellDisabled = function( spellID )
        if DisabledSpells[ spellID ] ~= nil then return DisabledSpells[ spellID ] end

        local isDisabled = FindStringInSpellTooltip( DisableText, spellID, true, true )
        DisabledSpells[ spellID ] = isDisabled

        return isDisabled
    end
    ns.IsSpellDisabled = IsSpellDisabled

    local DisabledItems = {}

    local IsItemDisabled = function( itemID )
        if DisabledItems[ itemID ] ~= nil then return DisabledItems[ itemID ] end

        local isDisabled = FindStringInItemTooltip( DisableText, itemID, true, true )
        DisabledItems[ itemID ] = isDisabled

        return isDisabled
    end
    ns.IsItemDisabled = IsItemDisabled

    local DisabledGear = {}

    local IsInventoryItemDisabled = function( slot )
        if DisabledGear[ slot ] ~= nil then return DisabledGear[ slot ] end

        local isDisabled = FindStringInInventoryItemTooltip( DisableText, slot, true, true )
        DisabledGear[ slot ] = isDisabled

        return isDisabled
    end
    ns.IsInventoryItemDisabled = IsInventoryItemDisabled

    local function IsAbilityDisabled( ability )
        if ability.item then return IsItemDisabled( ability.item ) end
        if ability.id > 0 then return IsSpellDisabled( ability.id ) end
        return false
    end
    ns.IsAbilityDisabled = IsAbilityDisabled

    local ResetDisabledGearAndSpells = function()
        wipe( DisabledSpells )
        wipe( DisabledItems )
        wipe( DisabledGear )
    end
    ns.ResetDisabledGearAndSpells = ResetDisabledGearAndSpells

    Hekili.FindStringInTooltip = FindStringInTooltip
    Hekili.FindStringInSpellTooltip = FindStringInSpellTooltip
    Hekili.FindStringInItemTooltip = FindStringInItemTooltip
    Hekili.FindStringInInventoryItemTooltip = FindStringInInventoryItemTooltip
    Hekili.FindStringInConduitTooltip = FindStringInConduitTooltip

    Hekili.IsSpellDisabled = IsSpellDisabled
    Hekili.IsItemDisabled = IsItemDisabled
    Hekili.IsInventoryItemDisabled = IsInventoryItemDisabled


    -- Check Covenant spells to disable them.
    local CovenantSpells = {
        [300728] = 1,
        [304971] = 1,
        [306830] = 1,
        [307443] = 1,
        [307865] = 1,
        [308491] = 1,
        [310454] = 1,
        [311648] = 1,
        [312202] = 1,
        [312321] = 1,
        [314791] = 1,
        [314793] = 1,
        [315443] = 1,
        [316958] = 1,
        [317009] = 1,
        [317485] = 1,
        [320674] = 1,
        [321792] = 1,
        [323546] = 1,
        [323547] = 1,
        [323639] = 1,
        [323654] = 1,
        [323673] = 1,
        [323764] = 1,
        [324128] = 1,
        [324143] = 1,
        [324149] = 1,
        [324220] = 1,
        [324386] = 1,
        [324631] = 1,
        [324724] = 1,
        [325013] = 1,
        [325020] = 1,
        [325028] = 1,
        [325216] = 1,
        [325283] = 1,
        [325289] = 1,
        [325640] = 1,
        [325886] = 1,
        [326059] = 1,
        [326434] = 1,
        [326647] = 1,
        [326860] = 1,
        [327104] = 1,
        [327661] = 1,
        [328204] = 1,
        [328231] = 1,
        [328281] = 1,
        [328282] = 1,
        [328305] = 1,
        [328547] = 1,
        [328620] = 1,
        [328622] = 1,
        [328923] = 1,
        [328930] = 1,
        [330325] = 1,
        [355589] = 1,
        [356532] = 1,
    }

    local IsCovenantSpell = function( spellID )
        return CovenantSpells[ spellID ] == 1
    end
    ns.IsCovenantSpell = IsCovenantSpell

    local covenantsDisabled = nil

    local AreCovenantsDisabled = function()
        if covenantsDisabled == nil then
            if FindStringInConduitTooltip( DisableText, 5, true, true ) then
                covenantsDisabled = true
                return true
            end
            covenantsDisabled = false
            return false
        end
        return covenantsDisabled
    end
    ns.AreCovenantsDisabled = AreCovenantsDisabled

    local IsDisabledCovenantSpell = function( spellID )
        return CovenantSpells[ spellID ] and AreCovenantsDisabled()
    end
    ns.IsDisabledCovenantSpell = IsDisabledCovenantSpell

    local WipeCovenantCache = function()
        covenantsDisabled = nil
    end
    ns.WipeCovenantCache = WipeCovenantCache
end


do
    local itemCache = {}

    function ns.CachedGetItemInfo( id )
        if itemCache[ id ] then
            return unpack( itemCache[ id ] )
        end

        local item = { GetItemInfo( id ) }
        if item and item[ 1 ] then
            itemCache[ id ] = item
            return unpack( item )
        end
    end
end


-- Atlas -> Texture Stuff
do
    local db = {}

    local function AddTexString( name, file, width, height, left, right, top, bottom )
        local pctWidth = right - left
        local realWidth = width / pctWidth
        local lPoint = left * realWidth

        local pctHeight = bottom - top
        local realHeight = height / pctHeight
        local tPoint = top * realHeight

        db[ name ] = format( "|T%s:%%d:%%d:%%d:%%d:%d:%d:%d:%d:%d:%d:%%s|t", file, realWidth, realHeight, lPoint, lPoint + width, tPoint, tPoint + height )
    end

    local function GetTexString( name, width, height, x, y, r, g, b )
        return db[ name ] and format( db[ name ], width or 0, height or 0, x or 0, y or 0, ( r and g and b and ( r .. ":" .. g .. ":" .. b ) or "" ) ) or ""
    end

    local function AtlasToString( atlas, width, height, x, y, r, g, b )
        if db[ atlas ] then
            return GetTexString( atlas, width, height, x, y, r, g, b )
        end

        local a = C_Texture.GetAtlasInfo( atlas )
        if not a then return atlas end

        AddTexString( atlas, a.file, a.width, a.height, a.leftTexCoord, a.rightTexCoord, a.topTexCoord, a.bottomTexCoord )
        return GetTexString( atlas, width, height, x, y, r, g, b )
    end

    local function GetAtlasFile( atlas )
        local a = C_Texture.GetAtlasInfo( atlas )
        return a and a.file or atlas
    end

    local function GetAtlasCoords( atlas )
        local a = C_Texture.GetAtlasInfo( atlas )
        return a and { a.leftTexCoord, a.rightTexCoord, a.topTexCoord, a.bottomTexCoord }
    end

    ns.AddTexString, ns.GetTexString, ns.AtlasToString, ns.GetAtlasFile, ns.GetAtlasCoords = AddTexString, GetTexString, AtlasToString, GetAtlasFile, GetAtlasCoords
end


function Hekili:GetSpec()
    return state.spec.id and class.specs[ state.spec.id ]
end


function Hekili:IsValidSpec()
    return state.spec.id and class.specs[ state.spec.id ] ~= nil
end


local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

function Hekili:GetLoadoutExportString()
    -- Current as of 10.1.0.48480
    local bitWidthHeaderVersion = 8
    local bitWidthSpecID = 16
    local bitWidthRanksPurchased = 6

    -- Cannot force-load as needed without causing taint, so this simply replicates existing Blizzard functionality.
    if IsAddOnLoaded( "Blizzard_ClassTalentUI" ) then
        bitWidthHeaderVersion = ClassTalentImportExportMixin.bitWidthHeaderVersion
        bitWidthSpecID = ClassTalentImportExportMixin.bitWidthSpecID
        bitWidthRanksPurchased = ClassTalentImportExportMixin.bitWidthRanksPurchased
    end

    local es = ExportUtil.MakeExportDataStream()
    local configID = C_ClassTalents.GetActiveConfigID() or -1
    local configInfo = C_Traits.GetConfigInfo( configID )

    if not configInfo then return "Export Unavailable" end

    local currentSpecID = PlayerUtil.GetCurrentSpecID()

    local treeID = configInfo.treeIDs[ 1 ]
    local treeHash = C_Traits.GetTreeHash( treeID )

    local serializationVersion = C_Traits.GetLoadoutSerializationVersion()

    es:AddValue( bitWidthHeaderVersion, serializationVersion )
    es:AddValue( bitWidthSpecID, currentSpecID )

    -- treeHash is a 128bit hash, passed as an array of 16, 8-bit values
    for i, hashVal in ipairs( treeHash ) do
        es:AddValue( 8, hashVal )
    end

	local treeNodes = C_Traits.GetTreeNodes(treeID);
	for i, treeNodeID in ipairs(treeNodes) do
		local treeNode = C_Traits.GetNodeInfo(configID, treeNodeID);

		local isNodeGranted = treeNode.activeRank - treeNode.ranksPurchased > 0;
		local isNodePurchased = treeNode.ranksPurchased > 0;
		local isNodeSelected = isNodeGranted or isNodePurchased;
		local isPartiallyRanked = treeNode.ranksPurchased ~= treeNode.maxRanks;
		local isChoiceNode = treeNode.type == Enum.TraitNodeType.Selection or treeNode.type == Enum.TraitNodeType.SubTreeSelection;

		es:AddValue(1, isNodeSelected and 1 or 0);
		if(isNodeSelected) then
			es:AddValue(1, isNodePurchased and 1 or 0);

			if isNodePurchased then
				es:AddValue(1, isPartiallyRanked and 1 or 0);
				if(isPartiallyRanked) then
					es:AddValue(bitWidthRanksPurchased, treeNode.ranksPurchased);
				end

				es:AddValue(1, isChoiceNode and 1 or 0);
				if(isChoiceNode) then
					local entryIndex = 0

                    for i, entryID in ipairs(treeNode.entryIDs) do
                        if(entryID == treeNode.activeEntry.entryID) then
                            entryIndex = i
                        end
                    end

					if(entryIndex <= 0 or entryIndex > 4) then
						error("Error exporting tree node " .. treeNode.ID .. ". The active choice node entry index (" .. entryIndex .. ") is out of bounds. ");
					end

					-- store entry index as zero-index
					es:AddValue(2, entryIndex - 1);
				end
			end
		end
	end

    return es:GetExportString()
end


do
    local cache = {}

    function Hekili:Loadstring( str )
        if cache[ str ] then return cache[ str ][ 1 ], cache[ str ][ 2 ] end
        local func, warn = loadstring( str )
        cache[ str ] = { func, warn }
        return func, warn
    end
end


do
    local marked = {}
    local supermarked = {}
    local pool = {}

    local seen = {}

    function ns.Mark( t, key )
        if not marked[ t ] then marked[ t ] = {} end
        marked[ t ][ key ] = true
    end

    function ns.SuperMark( table, keys )
        supermarked[ table ] = keys
    end

    function ns.AddToSuperMark( table, key )
        local sm = supermarked[ table ]
        if sm then
            insert( sm, key )
        end
    end

    function ns.ClearMarks( super )
        local count = 0
        local startTime = debugprofilestop()
        if super then
            for t, keys in pairs( supermarked ) do
                for key in pairs( keys ) do
                    rawset( t, key, nil )
                    count = count + 1
                end
            end

            wipe( seen )
        else
            for t, data in pairs( marked ) do
                for key in pairs( data ) do
                    rawset( t, key, nil )
                    data[ key ] = nil

                    count = count + 1
                end
            end
        end

        local endTime = debugprofilestop()
        if Hekili.ActiveDebug then Hekili:Debug( "Purged %d marked values in %.2fms.", count, endTime - startTime ) end
    end

    Hekili.Maintenance = {
        Dirty = marked,
        Cleaned = pool
    }
end