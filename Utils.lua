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
ns.formatKey = function( s )

  return ( lower(s):gsub("[^a-z0-9_ ]", ""):gsub("%s", "_") )

end


ns.titleCase = function( s )
  local helper = function( first, rest )
    return first:upper()..rest:lower()
  end

  return s:gsub( "_", " " ):gsub( "(%a)([%w_']*)", helper ):gsub( "[Aa]oe", "AOE" ):gsub( "[Rr]jw", "RJW" ):gsub( "[Cc]hix", "ChiX" ):gsub( "(%W?)[Ss]t(%W?)", "%1ST%2" )
end


ns.titlefy = function( s )
    return s:gsub( "_", " " ):gsub( "[Aa]oe", "AOE" ):gsub( "[Rr]jw", "RJW" ):gsub( "[Cc]hix", "ChiX" ):gsub( "(%W?)[Ss]t(%W?)", "%1ST%2" ):gsub( "[Cc]d", "CD" )
end


ns.escapeMagic = function( s )
  return s:gsub( "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1" )
end


ns.multiUnpack = function( ... )

  local merge = {}

  for i = 1, select( '#', ... ) do
    for _, value in ipairs( select( i, ... ) ) do
      merge[ #merge + 1 ] = value
    end
  end

  return unpack( merge )

end


ns.round = function( num, places )

  return tonumber( format( "%." .. ( places or 0 ) .. "f", num ) )

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
