-- Utils.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local format = string.format
local gsub = string.gsub
local lower = string.lower


local errors = {}
local eIndex = {}

ns.Error = function( ... )

local output = format( ... )
    if not errors[ output ] then
        errors[ output ] = {
            n = 1,
            last = date( "%X", time() )
        }
        eIndex[ #eIndex + 1 ] = output

        if Hekili.DB.profile.Verbose then Hekili:Print( output ) end
    else
        errors[ output ].n = errors[ output ].n + 1
        errors[ output ].last = date( "%X", time() )
    end
end


function Hekili:GetErrors()

    for i = 1, #eIndex do
        Hekili:Print( eIndex[i] .. " (n = " .. errors[ eIndex[i] ].n .. "), last at " .. errors[ eIndex[i] ].last .. "." )
    end

end


-- Converts `s' to a SimC-like key: strip non alphanumeric characters, replace spaces with _, convert to lower case.
function ns.formatKey( s )
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
    return s:gsub( "%f[%w]" .. k .. "%f[%W]", repl )
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

local function __genOrderedIndex( t )
    
    for i = #orderedIndex, 1, -1 do
        orderedIndex[i] = nil
    end
    
    for key in pairs( t ) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
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
        if val then result = ( not result or val > result ) and val or result end
    end

    return result or 0
end


--[[
function ns.safeMin( ... )
    local values = {}

    for i = 1, select( "#", ... ) do
        local val = select( i, ... )

        if val ~= nil and type( val ) == 'number' then
            values[ #values + 1 ] = val
        end
    end

    return min( unpack( values ) ) or 0
end


function ns.safeMax( ... )
    local values = {}

    for i = 1, select( "#", ... ) do
        local val = select( i, ... )

        if val ~= nil and type( val ) == 'number' then
            values[ #values + 1 ] = val
        end
    end

    return max( unpack( values ) ) or 0
end ]]
