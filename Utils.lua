-- Utils.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local format, gsub, lower = string.format, string.gsub, string.lower
local insert, remove = table.insert, table.remove

local class = Hekili.Class
local state = Hekili.State

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
    s = LT:Transliterate( s )
    return ( lower( s or '' ):gsub( "[^a-z0-9_ ]", "" ):gsub( "%s", "_" ) )
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
        for i = 1, table.getn( t.__orderedIndex ) do
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

function ns.FindRaidBuffByID(id)

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

-- Duplicate spell info lookup.
function ns.FindUnitBuffByID( unit, id, filter )
    local playerOrPet = false

    if filter == "PLAYER|PET" then
        playerOrPet = true
        filter = nil
    end

    local i = 1
    local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unit, i, filter )

    if type( id ) == "table" then
        while( name ) do
            if id[ spellID ] and ( not playerOrPet or UnitIsUnit( caster, "player" ) or UnitIsUnit( caster, "pet" ) ) then break end
            i = i + 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unit, i, filter )
        end
    else
        while( name ) do
            if spellID == id and ( not playerOrPet or UnitIsUnit( caster, "player" ) or UnitIsUnit( caster, "pet" ) ) then break end
            i = i + 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff( unit, i, filter )
        end
    end

    return name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3
end


function ns.FindUnitDebuffByID( unit, id, filter )
    local playerOrPet = false

    if filter == "PLAYER|PET" then
        playerOrPet = true
        filter = nil
    end

    local i = 1
    local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitDebuff( unit, i, filter )

    if type( id ) == "table" then
        while( name ) do
            if id[ spellID ] and ( not playerOrPet or UnitIsUnit( caster, "player" ) or UnitIsUnit( caster, "pet" ) ) then break end
            i = i + 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitDebuff( unit, i, filter )
        end
    else
        while( name ) do
            if spellID == id and ( not playerOrPet or UnitIsUnit( caster, "player" ) or UnitIsUnit( caster, "pet" ) ) then break end
            i = i + 1
            name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitDebuff( unit, i, filter )
        end
    end

    return name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3
end


function ns.IsActiveSpell( id )
    local slot = FindSpellBookSlotBySpellID( id )
    if not slot then return false end

    local _, _, spellID = GetSpellBookItemName( slot, "spell" )
    return id == spellID
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

    function ns.Mark( table, key )
        local data = remove( pool ) or {}
        data.t = table
        data.k = key
        insert( marked, data )
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
        if super then
            for t, keys in pairs( supermarked ) do
                for key in pairs( keys ) do
                    rawset( t, key, nil )
                end
            end
            return
        end

        local data = remove( marked )
        while( data ) do
            rawset( data.t, data.k, nil )
            insert( pool, data )
            data = remove( marked )
        end
    end

    Hekili.Maintenance = {
        Dirty = marked,
        Cleaned = pool
    }
end