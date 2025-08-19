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

local GetSpellBookItemInfo = function( index, bookType )
    local spellBank = ( bookType == "spell" or bookType == Enum.SpellBookItemType.Spell ) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet
    local info = C_SpellBook.GetSpellBookItemInfo(index, spellBank)
    if info then return info.name, info.iconID, info.spellID end
end

ns.UnitBuff = function( unit, index, filter )
    return UnpackAuraData( GetBuffDataByIndex( unit, index, filter ) )
end
local UnitBuff = ns.UnitBuff

ns.UnitDebuff = function( unit, index, filter )
    return UnpackAuraData( GetDebuffDataByIndex( unit, index, filter ) )
end
local UnitDebuff = ns.UnitDebuff

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
local SpaceOut = ns.SpaceOut

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
local orderedPairs = ns.orderedPairs


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

    local slot, bank = C_SpellBook.FindSpellBookSlotForSpell( id )
    if not slot then return false end
    local spellInfo = C_SpellBook.GetSpellBookItemInfo( slot, bank )

    local spellID = spellInfo and spellInfo.spellID

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

-- Importer
-- Import/Export
-- Nicer string encoding from WeakAuras, thanks to Stanzilla.

local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
local string_char = string.char

local bytetoB64 = {
    [0]="a","b","c","d","e","f","g","h",
    "i","j","k","l","m","n","o","p",
    "q","r","s","t","u","v","w","x",
    "y","z","A","B","C","D","E","F",
    "G","H","I","J","K","L","M","N",
    "O","P","Q","R","S","T","U","V",
    "W","X","Y","Z","0","1","2","3",
    "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
    a = 0, b = 1, c = 2, d = 3, e = 4, f = 5, g = 6, h = 7,
    i = 8, j = 9, k = 10, l = 11, m = 12, n = 13, o = 14, p = 15,
    q = 16, r = 17, s = 18, t = 19, u = 20, v = 21, w = 22, x = 23,
    y = 24, z = 25, A = 26, B = 27, C = 28, D = 29, E = 30, F = 31,
    G = 32, H = 33, I = 34, J = 35, K = 36, L = 37, M = 38, N = 39,
    O = 40, P = 41, Q = 42, R = 43, S = 44, T = 45, U = 46, V = 47,
    W = 48, X = 49, Y = 50, Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
    ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local encodeB64Table = {}

local function encodeB64(str)
    local B64 = encodeB64Table
    local remainder = 0
    local remainder_length = 0
    local encoded_size = 0
    local l=#str
    local code
    for i=1,l do
        code = string.byte(str, i)
        remainder = remainder + bit_lshift(code, remainder_length)
        remainder_length = remainder_length + 8
        while(remainder_length) >= 6 do
            encoded_size = encoded_size + 1
            B64[encoded_size] = bytetoB64[bit_band(remainder, 63)]
            remainder = bit_rshift(remainder, 6)
            remainder_length = remainder_length - 6
        end
    end
    if remainder_length > 0 then
        encoded_size = encoded_size + 1
        B64[encoded_size] = bytetoB64[remainder]
    end
    return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

local function decodeB64(str)
    local bit8 = decodeB64Table
    local decoded_size = 0
    local ch
    local i = 1
    local bitfield_len = 0
    local bitfield = 0
    local l = #str
    while true do
        if bitfield_len >= 8 then
            decoded_size = decoded_size + 1
            bit8[decoded_size] = string_char(bit_band(bitfield, 255))
            bitfield = bit_rshift(bitfield, 8)
            bitfield_len = bitfield_len - 8
        end
        ch = B64tobyte[str:sub(i, i)]
        bitfield = bitfield + bit_lshift(ch or 0, bitfield_len)
        bitfield_len = bitfield_len + 6
        if i > l then
            break
        end
        i = i + 1
    end
    return table.concat(bit8, "", 1, decoded_size)
end

-- Import/Export Strings
local Compresser = LibStub:GetLibrary("LibCompress")
local Encoder = Compresser:GetChatEncodeTable()

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local ldConfig = { level = 5 }

local Serializer = LibStub:GetLibrary("AceSerializer-3.0")

TableToString = function( inTable, forChat )
    local serialized = Serializer:Serialize( inTable )
    local compressed = LibDeflate:CompressDeflate( serialized, ldConfig )

    return format( "Hekili:%s", forChat and ( LibDeflate:EncodeForPrint( compressed ) ) or ( LibDeflate:EncodeForWoWAddonChannel( compressed ) ) )
end

StringToTable = function( inString, fromChat )
    local modern = false
    if inString:sub( 1, 7 ) == "Hekili:" then
        modern = true
        inString = inString:sub( 8 )
    end

    local decoded, decompressed, errorMsg

    if modern then
        decoded = fromChat and LibDeflate:DecodeForPrint(inString) or LibDeflate:DecodeForWoWAddonChannel(inString)
        if not decoded then return "Unable to decode." end

        decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then return "Unable to decompress decoded string." end
    else
        decoded = fromChat and decodeB64(inString) or Encoder:Decode(inString)
        if not decoded then return "Unable to decode." end

        decompressed, errorMsg = Compresser:Decompress(decoded)
        if not decompressed then return "Unable to decompress decoded string: " .. errorMsg end
    end

    local success, deserialized = Serializer:Deserialize(decompressed)
    if not success then return "Unable to deserialized decompressed string: " .. deserialized end

    return deserialized
end

SerializeActionPack = function( name )
    local pack

    if type( name ) == "string" then
        pack = rawget( Hekili.DB.profile.packs, name )
        pack = pack and tableCopy( pack )
    else
        pack = name
        name = pack.name
    end

    if not pack then return end

    local serial = {
        type = "package",
        name = name,
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = pack
    }

    serial.payload.builtIn = false

    return TableToString( serial, true )
end
Hekili.SerializeActionPack = SerializeActionPack

DeserializeActionPack = function( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == "string" or serial.type ~= "package" then
        return serial or "Unable to restore Priority from the provided string."
    end

    serial.payload.builtIn = false

    return serial
end
Hekili.DeserializeActionPack = DeserializeActionPack

SerializeStyle = function( ... )
    local serial = {
        type = "style",
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = {}
    }

    local hasPayload = false

    for i = 1, select( "#", ... ) do
        local dispName = select( i, ... )
        local display = rawget( Hekili.DB.profile.displays, dispName )

        if not display then return "Attempted to serialize an invalid display (" .. dispName .. ")" end

        serial.payload[ dispName ] = tableCopy( display )
        hasPayload = true
    end

    if not hasPayload then return "No displays selected to export." end
    return TableToString( serial, true )
end
Hekili.SerializeStyle = SerializeStyle

DeserializeStyle = function( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == 'string' or not serial.type == "style" then
        return nil, serial
    end

    return serial.payload
end
Hekili.DeserializeStyle = DeserializeStyle

-- End Import/Export Strings

local Sanitize

-- Begin APL Parsing
do
    local ignore_actions = {
        snapshot_stats = 1,
        flask = 1,
        food = 1,
        augmentation = 1
    }

    local expressions = {
        { "stealthed"                                       , "stealthed.rogue"                         },
        { "rtb_buffs%.normal"                               , "rtb_buffs_normal"                        },
        { "rtb_buffs%.min_remains"                          , "rtb_buffs_min_remains"                   },
        { "rtb_buffs%.max_remains"                          , "rtb_buffs_max_remains"                   },
        { "rtb_buffs%.shorter"                              , "rtb_buffs_shorter"                       },
        { "rtb_buffs%.longer"                               , "rtb_buffs_longer"                        },
        { "rtb_buffs%.will_lose%.([%w_]+)"                  , "rtb_buffs_will_lose_buff.%1"             },
        { "rtb_buffs%.will_lose"                            , "rtb_buffs_will_lose"                     },
        { "rtb_buffs%.total"                                , "rtb_buffs"                               },
        { "buff.supercharge_(%d).up"                        , "supercharge_%1"                          },
        { "hyperthread_wristwraps%.([%w_]+)%.first_remains" , "hyperthread_wristwraps.first_remains.%1" },
        { "hyperthread_wristwraps%.([%w_]+)%.count"         , "hyperthread_wristwraps.%1"               },
        { "cooldown"                                        , "action_cooldown"                         },
        { "covenant%.([%w_]+)%.enabled"                     , "covenant.%1"                             },
        { "talent%.([%w_]+)"                                , "talent.%1.enabled",                      true },
        { "legendary%.([%w_]+)"                             , "legendary.%1.enabled"                    },
        { "runeforge%.([%w_]+)"                             , "runeforge.%1.enabled"                    },
        { "rune_word%.([%w_]+)"                             , "buff.rune_word_%1.up"                    },
        { "rune_word%.([%w_]+)%.enabled"                    , "buff.rune_word_%1.up"                    },
        { "conduit%.([%w_]+)"                               , "conduit.%1.enabled"                      },
        { "soulbind%.([%w_]+)"                              , "soulbind.%1.enabled"                     },
        { "soul_shard%.deficit"                             , "soul_shard_deficit"                      },
        { "pet.[%w_]+%.([%w_]+)%.([%w%._]+)"                , "%1.%2"                                   },
        { "essence%.([%w_]+).rank(%d)"                      , "essence.%1.rank>=%2"                     },
        { "target%.1%.time_to_die"                          , "time_to_die"                             },
        { "time_to_pct_(%d+)%.remains"                      , "time_to_pct_%1"                          },
        { "trinket%.(%d)%.([%w%._]+)"                       , "trinket.t%1.%2"                          },
        --[[ { "trinket%.(t?%d)%.stat%.([%w_]+)%.([%w%._]+)", -- Christ.
                                                              "trinket.%1.has_stat.%2&trinket.%1.%3" }, ]]
        { "trinket%.([%w_]+)%.cooldown"                     , "trinket.%1.cooldown.duration"            },
        { "trinket%.([%w_]+)%.proc%.([%w_]+)%.duration"     , "trinket.%1.buff_duration"                },
        { "trinket%.([%w_]+)%.buff%.a?n?y?%.?duration"      , "trinket.%1.buff_duration"                },
        { "trinket%.([%w_]+)%.proc%.([%w_]+)%.[%w_]+"       , "trinket.%1.has_use_buff"                 },
        { "trinket%.([%w_]+)%.has_buff%.([%w_]+)"           , "trinket.%1.has_use_buff"                 },
        { "trinket%.([%w_]+)%.has_use_buff%.([%w_]+)"       , "trinket.%1.has_use_buff"                 },
        { "min:([%w_]+)"                                    , "%1"                                      },
        { "position_back"                                   , "true"                                    },
        { "max:(%w_]+)"                                     , "%1"                                      },
        { "incanters_flow_time_to%.(%d+)"                   , "incanters_flow_time_to_%.%1.any"         },
        { "exsanguinated%.([%w_]+)"                         , "debuff.%1.exsanguinated"                 },
        { "time_to_sht%.(%d+)%.plus"                        , "time_to_sht_plus.%1"                     },
        { "target"                                          , "target.unit"                             },
        { "player"                                          , "player.unit"                             },
        { "gcd"                                             , "gcd.max"                                 },
        { "howl_summon%.([%w_]+)%.([%w_]+)"                 , "howl_summon.%1_%2"                       },

        { "equipped%.(%d+)", nil, function( item )
            item = tonumber( item )

            if not item then return "equipped.none" end

            if class.abilities[ item ] then
                return "equipped." .. ( class.abilities[ item ].key or "none" )
            end

            return "equipped[" .. item .. "]"
        end },

        { "trinket%.([%w_]+)%.cooldown%.([%w_]+)", nil, function( trinket, token )
            if class.abilities[ trinket ] then
                return "cooldown." .. trinket .. "." .. token
            end

            return "trinket." .. trinket .. ".cooldown." .. token
        end,  },

    }

    local operations = {
        { "=="  , "="  },
        { "%%"  , "/"  },
        { "//"  , "%%" }
    }


    function Hekili:AddSanitizeExpr( from, to, func )
        insert( expressions, { from, to, func } )
    end

    function Hekili:AddSanitizeOper( from, to )
        insert( operations, { from, to } )
    end

    Sanitize = function( segment, i, line, warnings )
        if i == nil then return end

        local operators = {
            [">"] = true,
            ["<"] = true,
            ["="] = true,
            ["~"] = true,
            ["+"] = true,
            ["-"] = true,
            ["%%"] = true,
            ["*"] = true
        }

        local maths = {
            ['+'] = true,
            ['-'] = true,
            ['*'] = true,
            ['%%'] = true
        }

        local times = 0
        local output, pre = "", ""

        for op1, token, op2 in gmatch( i, "([^%w%._ ]*)([%w%._]+)([^%w%._ ]*)" ) do

            if token and token:len() > 0 then
                pre = token
                for _, subs in ipairs( expressions ) do
                    local ignore = type( subs[3] ) == "boolean" and subs[3]
                    if subs[2] then
                        times = 0
                        local s1, s2, s3, s4, s5 = token:match( "^" .. subs[1] .. "$" )
                        if s1 then
                            token = subs[2]
                            token, times = token:gsub( "%%1", s1 )

                            if s2 then token = token:gsub( "%%2", s2 ) end
                            if s3 then token = token:gsub( "%%3", s3 ) end
                            if s4 then token = token:gsub( "%%4", s4 ) end
                            if s5 then token = token:gsub( "%%5", s5 ) end

                            if times > 0 and not ignore then
                                insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. token .. "' (" .. times .. "x)." )
                            end
                        end
                    elseif subs[3] and type( subs[3] ) == "function" then
                        local val, v2, v3, v4, v5 = token:match( "^" .. subs[1] .. "$" )
                        if val ~= nil then
                            token = subs[3]( val, v2, v3, v4, v5 )
                            insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. token .. "'." )
                        end
                    end
                end
            end

            output = output .. ( op1 or "" ) .. ( token or "" ) .. ( op2 or "" )
        end

        local ops_swapped = false
        pre = output

        -- Replace operators after its been stitched back together.
        for _, subs in ipairs( operations ) do
            output, times = output:gsub( subs[1], subs[2] )
            if times > 0 then
                ops_swapped = true
            end
        end

        if ops_swapped then
            insert( warnings, "Line " .. line .. ": Converted operations in '" .. pre .. "' to '" .. output .. "'." )
        end

        return output
    end

    local function strsplit( str, delimiter )
        local result = {}
        local from = 1

        if not delimiter or delimiter == "" then
            result[1] = str
            return result
        end

        local delim_from, delim_to = string.find( str, delimiter, from )

        while delim_from do
            insert( result, string.sub( str, from, delim_from - 1 ) )
            from = delim_to + 1
            delim_from, delim_to = string.find( str, delimiter, from )
        end

        insert( result, string.sub( str, from ) )
        return result
    end

    local parseData = {
        warnings = {},
        missing = {},
    }

    local nameMap = {
        call_action_list = "list_name",
        run_action_list = "list_name",
        variable = "var_name",
        cancel_action = "action_name",
        cancel_buff = "buff_name",
        op = "op",
    }

    function Hekili:ParseActionList( list )
        local line, times = 0, 0
        local output, warnings, missing = {}, parseData.warnings, parseData.missing

        wipe( warnings )
        wipe( missing )

        list = list:gsub( "(|)([^|])", "%1|%2" ):gsub( "|||", "||" )

        local n = 0
        for aura in list:gmatch( "buff%.([a-zA-Z0-9_]+)" ) do
            if not class.auras[ aura ] then
                missing[ aura ] = true
                n = n + 1
            end
        end

        for aura in list:gmatch( "active_dot%.([a-zA-Z0-9_]+)" ) do
            if not class.auras[ aura ] then
                missing[ aura ] = true
                n = n + 1
            end
        end

        -- TODO: Revise to start from beginning of string.
        for i in list:gmatch( "action.-=/?([^\n^$]*)") do
            line = line + 1

            if i:sub(1, 3) == 'jab' then
                for token in i:gmatch( 'cooldown%.expel_harm%.remains>=gcd' ) do

                    local times = 0
                    while (i:find(token)) do
                        local strpos, strend = i:find(token)

                        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                        local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                        local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                        local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                        i = start .. repl .. finish
                        times = times + 1
                    end
                    insert( warnings, "Line " .. line .. ": Removed unnecessary expel_harm cooldown check from action entry for jab (" .. times .. "x)." )
                end
            end

            if i:sub(1, 13) == 'fists_of_fury' then
                for token in i:gmatch( "energy.time_to_max>cast_time" ) do
                    local times = 0
                    while (i:find(token)) do
                        local strpos, strend = i:find(token)

                        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                        local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                        local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                        local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                        i = start .. repl .. finish
                        times = times + 1
                    end
                    insert( warnings, "Line " .. line .. ": Removed unnecessary energy cap check from action entry for fists_of_fury (" .. times .. "x)." )
                end
            end

            local components = strsplit( i, "," )
            local result = {}

            for a, str in ipairs( components ) do
                -- First element is the action, if supported.
                if a == 1 then
                    local ability = str:trim()

                    if ability and ( ability == "use_item" or class.abilities[ ability ] ) then
                        if ability == "pocketsized_computation_device" then ability = "cyclotronic_blast"
                        else result.action = ability end
                    elseif not ignore_actions[ ability ] then
                        insert( warnings, "Line " .. line .. ": Unsupported action '" .. ability .. "'." )
                        result.action = ability
                    end

                else
                    local key, value = str:match( "^(.-)=(.-)$" )

                    if key and value then
                        -- TODO:  Automerge multiple criteria.
                        if key == 'if' or key == 'condition' then key = 'criteria' end

                        if key == 'criteria' or key == 'target_if' or key == 'value' or key == 'value_else' or key == 'sec' or key == 'wait' or key == 'strict_if' then
                            value = Sanitize( 'c', value, line, warnings )
                            value = SpaceOut( value )
                        end

                        if key == 'caption' then
                            value = value:gsub( "||", "|" ):gsub( ";", "," )
                        end

                        if key == 'description' then
                            value = value:gsub( ";", "," )
                        end

                        result[ key ] = value
                    end
                end
            end

            if nameMap[ result.action ] then
                result[ nameMap[ result.action ] ] = result.name
                result.name = nil
            end

            if result.target_if then result.target_if = result.target_if:gsub( "min:", "" ):gsub( "max:", "" ) end

            -- As of 11/11/2022 (11/11/2022 in Europe), empower_to is purely a number 1-4.
            if result.empower_to and ( result.empower_to == "max" or result.empower_to == "maximum" ) then result.empower_to = "max_empower" end
            if result.for_next then result.for_next = tonumber( result.for_next ) end
            if result.cycle_targets then result.cycle_targets = tonumber( result.cycle_targets ) end
            if result.max_energy then result.max_energy = tonumber( result.max_energy ) end

            if result.use_off_gcd then result.use_off_gcd = tonumber( result.use_off_gcd ) end
            if result.use_while_casting then result.use_while_casting = tonumber( result.use_while_casting ) end
            if result.strict then result.strict = tonumber( result.strict ) end
            if result.moving then
                result.enable_moving = true
                result.moving = tonumber( result.moving )
            end

            if result.target_if and not result.criteria then
                result.criteria = result.target_if
                result.target_if = nil
            end

            if result.action == "use_item" then
                if result.effect_name and class.abilities[ result.effect_name ] then
                    result.action = class.abilities[ result.effect_name ].key
                elseif result.name and class.abilities[ result.name ] then
                    result.action = result.name
                elseif ( result.slot or result.slots ) and class.abilities[ result.slot or result.slots ] then
                    result.action = result.slot or result.slots
                end

                if result.action == "use_item" then
                    insert( warnings, "Line " .. line .. ": Unsupported use_item action [ " .. ( result.effect_name or result.name or "unknown" ) .. "]; entry disabled." )
                    result.action = nil
                    result.enabled = false
                end
            end

            if result.action == "wait_for_cooldown" then
                if result.name then
                    result.action = "wait"
                    result.sec = "cooldown." .. result.name .. ".remains"
                    result.name = nil
                else
                    insert( warnings, "Line " .. line .. ": Unable to convert wait_for_cooldown,name=X to wait,sec=cooldown.X.remains; entry disabled." )
                    result.action = "wait"
                    result.enabled = false
                end
            end

            if result.action == 'use_items' and ( result.slot or result.slots ) then
                result.action = result.slot or result.slots
            end

            if result.action == 'variable' and not result.op then
                result.op = 'set'
            end

            if result.cancel_if and not result.interrupt_if then
                result.interrupt_if = result.cancel_if
                result.cancel_if = nil
            end

            insert( output, result )
        end

        if n > 0 then
            insert( warnings, "The following auras were used in the action list but were not found in the addon database:" )
            for k in orderedPairs( missing ) do
                insert( warnings, " - " .. k )
            end
        end

        return #output > 0 and output or nil, #warnings > 0 and warnings or nil
    end
end

local impControl = {
    name = "",
    source = UnitName( "player" ) .. " @ " .. GetRealmName(),
    apl = "Paste your SimulationCraft action priority list or profile here.",

    lists = {},
    warnings = ""
}
Hekili.ImporterData = impControl

ns.packTemplate = {
    spec = 0,
    builtIn = false,

    author = UnitName("player"),
    desc = "This is a package of action lists for Hekili.",
    source = "",
    date = tonumber( date("%Y%M%D.%H%M") ),
    warnings = "",

    hidden = false,

    lists = {
        precombat = {
            {
                enabled = false,
                action = "heart_essence",
            },
        },
        default = {
            {
                enabled = false,
                action = "heart_essence",
            },
        },
    }
}

do
    local function AddWarning( s )
        if impControl.warnings then
            impControl.warnings = impControl.warnings .. s .. "\n"
            return
        end

        impControl.warnings = s .. "\n"
    end


    function Hekili:GetImporterOption( info )
        return impControl[ info[ #info ] ]
    end


    function Hekili:SetImporterOption( info, value )
        if type( value ) == 'string' then value = value:trim() end
        impControl[ info[ #info ] ] = value
        impControl.warnings = nil
    end


    function Hekili:ImportSimcAPL( name, source, apl )
        name   = name   or impControl.name
        source = source or impControl.source
        apl    = apl    or impControl.apl

        impControl.warnings = ""

        local lists = {
            precombat = "",
            default = "",
        }

        local count = 0

        -- Rename the default action list to 'default'
        apl = "\n" .. apl
        apl = apl:gsub( "actions(%+?)=", "actions.default%1=" )

        local comment

        for line in apl:gmatch( "\n([^\n^$]*)") do
            local newComment = line:match( "^# (.+)" )
            if newComment then
                if comment then
                    comment = comment .. ' ' .. newComment
                else
                    comment = newComment
                end
            end

            local list, action = line:match( "^[ +]?actions%.(%S-)%+?=/?([^\n^$]*)" )

            if list and action then
                lists[ list ] = lists[ list ] or ""

                if action:sub( 1, 16 ) == "call_action_list" or action:sub( 1, 15 ) == "run_action_list" then
                    local name = action:match( ",name=(.-)," ) or action:match( ",name=(.-)$" )
                    if name then action:gsub( ",name=" .. name, ",name=\"" .. name .. "\"" ) end
                end

                if comment then
                    -- Comments can have the form 'Caption::Description'.
                    -- Any whitespace around the '::' is truncated.
                    local caption, description = comment:match( "(.+)::(.*)" )
                    if caption and description then
                        -- Truncate whitespace and change commas to semicolons.
                        caption = caption:gsub( "%s+$", "" ):gsub( ",", ";" )
                        description = description:gsub( "^%s+", "" ):gsub( ",", ";" )
                        -- Replace "[<texture-id>]" in the caption with the escape sequence for the texture.
                        caption = caption:gsub( "%[(%d+)%]", "|T%1:0|t" )
                        -- Replace "[h:<text>]" in the caption with the escape sequence for the texture string.
                        caption = caption:gsub( "%[h:(.-)%]", "|TInterface\\AddOns\\Hekili\\Textures\\%1:0|t" )
                        -- Replace "[<text>:<height>:<width>]" in the caption with the escape sequence for the atlas.
                        caption = caption:gsub( "%[(.-):(%d+):(%d+)%]", "|A:%1:%2:%3|a" )
                        action = action .. ',caption=' .. caption .. ',description=' .. description
                    else
                        -- Change commas to semicolons.
                        action = action .. ',description=' .. comment:gsub( ",", ";" )
                    end
                    comment = nil
                end

                lists[ list ] = lists[ list ] .. "actions+=/" .. action .. "\n"
            end
        end

        if lists.precombat:len() == 0 then lists.precombat = "actions+=/heart_essence,enabled=0" end
        if lists.default  :len() == 0 then lists.default   = "actions+=/heart_essence,enabled=0" end

        local count = 0
        local output = {}

        for name, list in pairs( lists ) do
            local import, warnings = self:ParseActionList( list )

            if warnings then
                AddWarning( "The import for '" .. name .. "' required some automated changes." )

                for i, warning in ipairs( warnings ) do
                    AddWarning( warning )
                end

                AddWarning( "" )
            end

            if import then
                output[ name ] = import

                for i, entry in ipairs( import ) do
                    if entry.enabled == nil then entry.enabled = not ( entry.action == 'heroism' or entry.action == 'bloodlust' )
                    elseif entry.enabled == "0" then entry.enabled = false end
                end

                count = count + 1
            end
        end

        local use_items_found = false
        local trinket1_found = false
        local trinket2_found = false

        for _, list in pairs( output ) do
            for i, entry in ipairs( list ) do
                if entry.action == "use_items" then use_items_found = true
                elseif entry.action == "trinket1" then trinket1_found = true
                elseif entry.action == "trinket2" then trinket2_found = true end
            end
        end

        if not use_items_found and not ( trinket1_found and trinket2_found ) then
            AddWarning( "This profile is missing support for generic trinkets.  It is recommended that every priority includes either:\n" ..
                " - [Use Items], which includes any trinkets not explicitly included in the priority; or\n" ..
                " - [Trinket 1] and [Trinket 2], which will recommend the trinket for the numbered slot." )
        end

        if not output.default then output.default = {} end
        if not output.precombat then output.precombat = {} end

        if count == 0 then
            AddWarning( "No action lists were imported from this profile." )
        else
            AddWarning( "Imported " .. count .. " action lists." )
        end

        return output, impControl.warnings
    end
end