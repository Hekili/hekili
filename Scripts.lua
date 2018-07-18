-- Scripts.lua
-- December 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class   = Hekili.Class
local scripts = Hekili.Scripts
local state   = Hekili.State

local GetResourceInfo, GetResourceID = ns.GetResourceInfo, ns.GetResourceID
local SpaceOut = ns.SpaceOut

local ceil = math.ceil
local orderedPairs = ns.orderedPairs
local roundUp = ns.roundUp
local safeMax = ns.safeMax

local trim = string.trim


-- Forgive the name, but this should properly replace ! characters with not, accounting for appropriate bracketing.
-- Why so complex?  Because "! 0 > 1" converted to Lua is "not 0 > 1" which evaluates to "false > 1" -- not the goal.
-- This should convert:
-- example 1:  ! 0 > 1
--             not ( 0 > 1 )
--
-- example 2:  ! ( 0 > 1 & ! ( false | true ) )
--             not ( 0 > 1 & not ( false | true ) )
--
-- example 3:  ! cooldown.x.remains > 1 * ( gcd * ( 8 % 3 ) )
--             not ( cooldown.x.remains > 1 * ( gcd * ( 8 % 3 ) ) )
--
-- Hopefully.

local exprBreak = {
   ["&"] = true,
   ["|"] = true,
}

local function forgetMeNots( str )
   -- First, handle already bracketed "!(X)" -> "not (X)".
   local found = 1
   
   while found > 0 do
      str, found = str:gsub( "%s*!%s*(%b())%s*", " not %1 " )
   end
   
   -- The remaining conditions are not bracketed, but may include brackets.
   -- Such as !5>2+(1*3).
   -- So we'll start from the !, then go through the string until it's time to stop.
   
   local i = 1
   local substring
   
   while( str:find("!") ) do   
      local start = str:find("!")
      
      --while str:sub( start, start ):match("%s") do
      --   start = start + 1
      --      end
      
      local parens = 0
      local finish = -1
      
      for j = start, str:len() do
         local char = str:sub( j, j )
         
         if char == "(" then         
            parens = parens + 1
            
         elseif char == ")" then         
            if parens > 0 then parens = parens - 1
            else finish = j - 1; break end
            
         elseif parens == 0 then
            -- We are not within a bracketed part of the string.  We can end here.
            if exprBreak[ char ] then
               finish = j - 1
               break
            end
         end
      end
      
      if finish == -1 then finish = str:len() end
      
      substring = str:sub( start + 1, finish )
      substring = substring:trim()

      str = format( "%s not ( %s ) %s", str:sub( 1, start - 1 ) or "", substring, str:sub( finish + 1, str:len() ) or "" )

      i = i + 1
      if i >= 100 then self:Debug( "Was unable to convert '!' to 'not' in string [%s].", str ); break end
   end
   
   str = str:gsub( "%s%s", " " )

   return str
end


local invalid = "([^a-zA-Z0-9_.])"


local function extendExpression( str, expr, suffix )
    if str:find( expr ) then
        str = str:gsub( "^" .. expr .. invalid, expr .. "." .. suffix .. "%1" )
        str = str:gsub( invalid .. expr .. "$", "%1" .. expr .. "." .. suffix )
        str = str:gsub( "^" .. expr .. "$", expr .. "." .. suffix )
        str = str:gsub( invalid .. expr .. invalid, "%1" .. expr .. "." .. suffix .. "%2" )
    end

    return str
end



-- Convert SimC syntax to Lua conditionals.
local function SimToLua( str, modifier )
    -- If no conditions were provided, function should return true.
    if not str or str == '' then return nil end
    if type( str ) == 'number' then return str end
    
    str = str:trim()
    
    -- Strip comments.
    str = str:gsub("^%-%-.-\n", "")
    
    -- Replace '!' with ' not '.
    str = forgetMeNots( str )
    
    for k in pairs( GetResourceInfo() ) do
        if str:find( k ) then
            str = extendExpression( str, k, "current" )
        end
    end

    if str:find( "rune" ) then
        str = extendExpression( str, "rune", "current" )
    end

    if str:find( "spell_targets" ) then
        str = extendExpression( str, "spell_targets", "any" )
    end

    -- Replace '%' for division with actual division operator '/'.
    str = str:gsub("%%", "/")
    
    -- Replace '&' with ' and '.
    str = str:gsub("&", " and ")
    
    -- Replace '|' with ' or '.
    str = str:gsub("||", " or "):gsub("|", " or ")
    
    if not modifier then
        -- Replace assignment '=' with comparison '=='
        str = str:gsub("([^=])=([^=])", "%1==%2" )
        
        -- Fix any conditional '==' that got impacted by previous.
        str = str:gsub("==+", "==")
        str = str:gsub(">=+", ">=")
        str = str:gsub("<=+", "<=")
        str = str:gsub("!=+", "~=")
        str = str:gsub("~=+", "~=")
    end
    
    -- Condense whitespace.
    str = str:gsub("%s%s", " ")
    
    -- Condense parenthetical spaces.
    str = str:gsub("[(][%s+]", "("):gsub("[%s+][)]", ")")
    
    -- Address equipped.number => equipped[number]
    str = str:gsub("equipped%.(%d+)", "equipped[%1]")
    str = str:gsub("lowest_vuln_within%.(%d+)", "lowest_vuln_within[%1]")
    str = str:gsub("%.in([^a-zA-Z0-9_])", "['in']%1" )
    
    str = str:gsub("prev%.(%d+)", "prev[%1]")
    str = str:gsub("prev_gcd%.(%d+)", "prev_gcd[%1]")
    str = str:gsub("prev_off_gcd%.(%d+)", "prev_off_gcd[%1]")
    str = str:gsub("time_to_sht%.(%d+)", "time_to_sht[%1]")
    
    return str 
end


local function SimcWithResources( str )
    for k in pairs( GetResourceInfo() ) do
        if str:find( k ) then
            str = extendExpression( str, k, "current" )
        end
    end

    if str:find( "rune" ) then
        str = extendExpression( str, "rune", "current" )
    end

    if str:find( "spell_targets" ) then
        str = extendExpression( str, "spell_targets", "any" )
    end

    return str
end


-- Convert SimC syntax to Lua conditionals.
local function SimCToSnapshot( str, modifier )
    -- If no conditions were provided, function should return true.
    if not str or str == '' then return nil end
    if type( str ) == 'number' then return str end
    
    str = str:trim()
    
    -- Strip comments.
    str = str:gsub("^%-%-.-\n", "")
    
    -- Replace '!' with ' not '.
    -- str = forgetMeNots( str )
    
    for k in pairs( GetResourceInfo() ) do
        if str:find( k ) then
            str = extendExpression( str, k, "current" )
        end
    end

    if str:find( "rune" ) then
        str = extendExpression( str, "rune", "current" )
    end

    if str:find( "spell_targets" ) then
        str = extendExpression( str, "spell_targets", "any" )
    end

    -- Replace '%' for division with actual division operator '/'.
    -- str = str:gsub("%%", "/")
    
    -- Replace '&' with ' and '.
    -- str = str:gsub("&", " and ")
    
    -- Replace '|' with ' or '.
    -- str = str:gsub("||", " or "):gsub("|", " or ")
    
    --[[ if not modifier then
        -- Replace assignment '=' with comparison '=='
        str = str:gsub("([^=])=([^=])", "%1==%2" )
        
        -- Fix any conditional '==' that got impacted by previous.
        str = str:gsub("==+", "==")
        str = str:gsub(">=+", ">=")
        str = str:gsub("<=+", "<=")
        str = str:gsub("!=+", "~=")
        str = str:gsub("~=+", "~=")
    end 
    
    -- Condense whitespace.
    str = str:gsub("%s%s", " ")
    
    -- Condense parenthetical spaces.
    str = str:gsub("[(][%s+]", "("):gsub("[%s+][)]", ")") ]]
    
    -- Address equipped.number => equipped[number]
    str = str:gsub("equipped%.(%d+)", "equipped[%1]")
    str = str:gsub("lowest_vuln_within%.(%d+)", "lowest_vuln_within[%1]")
    str = str:gsub("%.in([^a-zA-Z0-9_])", "['in']%1" )
    
    str = str:gsub("prev%.(%d+)", "prev[%1]")
    str = str:gsub("prev_gcd%.(%d+)", "prev_gcd[%1]")
    str = str:gsub("prev_off_gcd%.(%d+)", "prev_off_gcd[%1]")
    str = str:gsub("time_to_sht%.(%d+)", "time_to_sht[%1]")
    
    return str
    
end


local function stripScript( str, thorough )
  if not str then return 'true' end
  if type( str ) == 'number' then return str end

  -- Remove the 'return ' that was added during conversion.
  str = str:gsub("^return ", "")

  -- Remove comments and parentheses.
  str = str:gsub("%-%-.-\n", ""):gsub("[()]", "")

  -- Remove conjunctions.
  str = str:gsub("[%s-]and[%s-]", " "):gsub("[%s-]or[%s-]", " "):gsub("%(-%s-not[%s-]", " ")

  if not thorough then
    -- Collapse whitespace around comparison operators.
    str = str:gsub("[%s-]==[%s-]", "=="):gsub("[%s-]>=[%s-]", ">="):gsub("[%s-]<=[%s-]", "<="):gsub("[%s-]~=[%s-]", "~="):gsub("[%s-]<[%s-]", "<"):gsub("[%s-]>[%s-]", ">")
  else
    str = str:gsub("[=+]", " "):gsub("[><~]", " "):gsub("[%*//%-%+]", " ")
  end

  -- Collapse the rest of the whitespace.
  str = str:gsub("[%s+]", " ")

  return ( str )
end


function scripts:StoreValues( tbl, node, mod )
    wipe( tbl )

    if type( node ) == 'string' then node = self.DB[ node ] end
    if not node then return end

    local elems = mod and node.ModElements[ mod ] or node.Elements

    if not elems then return end

    for k, v in pairs( elems ) do
        local s, r = pcall( v )

        if s then tbl[ k ] = r
        elseif type( r ) == 'string' then tbl[ k ] = r:match( "lua:%d+: (.*)" ) or r end
        if tbl[ k ] == nil then tbl[ k ] = 'nil' end
    end
end


function scripts:StoreReadyValues( tbl, node )
    self:StoreValues( tbl, node, "ready" )
end


local function GetScriptElements( script )
    if type( script ) == 'number' then return end

    local e, c = {}, stripScript( script, true )

    for s in c:gmatch( "[^ ,]+" ) do
        if not e[ s ] and not tonumber( s ) then
            local ef = loadstring( 'return '.. ( s or true ) )
            if ef then setfenv( ef, state ) end
      
            local success, v = pcall( ef )
            e[ s ] = ef
        end
    end

    return e
end


local specialModifiers = {
    CycleTargets = true,
    MaximumTargets = true,
    CheckMovement = true,
    Movement = true,
    ModName = false,
    WaitSeconds = true,
    PoolTime = true,
    PoolForNext = true
}


local newModifiers = {
    cycle_targets = true,
    for_next = true,
    max_cycle_targets = true,
    moving = true,
    sec = true,
    set = true,
    setif = true,
    sync = true,
    target_if = true,
    value = true,
    value_else = true,
    wait = true,
}


local nameMap = {
    call_action_list = "list_name",
    run_action_list = "list_name",
    variable = "var_name",
    potion = "potion",
}


-- Need to convert all the appropriate scripts and store them safely...
local function ConvertScript( node, hasModifiers )
    local t = SimToLua( node.criteria )
    local sf, e

    if t then sf, e = loadstring( "return " .. t ) end
    if sf then setfenv( sf, state ) end

    --[[ if sf and not e then
        local pass, val = pcall( sf )
        if not pass then e = val end
    end ]]
    if e then e = e:match( ":(%d+: .*)" ) end
    
    local se = t and GetScriptElements( t )

    local output = {
        Conditions = sf,
        Error = e,
        Elements = se,
        Modifiers = {},
        ModElements = {},
        SpecialMods = "",

        Lua = t and t:trim() or nil,
        SimC = node.criteria and SimcWithResources( node.criteria:trim() ) or nil
    }
    
    if hasModifiers then
        for m, value in pairs( newModifiers ) do
            if node[ m ] then
                local o = SimToLua( node[ m ] )
                output.SpecialMods = output.SpecialMods .. " - " .. m .. " : " .. o

                local sf, e
                if value then
                    sf, e = loadstring( "return " .. o )
                else
                    o = "'" .. o .. "'"
                    sf, e = loadstring( "return " .. o )
                end

                if sf then
                    setfenv( sf, state )
                    output.Modifiers[ m ] = sf
                    output.ModElements[ m ] = GetScriptElements( o )
                else
                    output.Modifiers[ m ] = e
                end
            end
        end

        local name = nameMap[ node.action ]
        if name and node[ name ] then
            local o = tostring( node[ name ] )
            o = "'" .. o .. "'"
            output.SpecialMods = output.SpecialMods .. " - " .. name .. " : " .. o

            local sf, e
            sf, e = loadstring( "return " .. o )

            if sf then
                setfenv( sf, state )
                output.Modifiers[ name ] = sf
                output.ModElements[ name ] = GetScriptElements( o )
            else
                output.Modifiers[ name ] = e
            end
        end
    end

    return output
end

--[[ ReadyTime is replaced by rechecks...
if node.ReadyTime and node.ReadyTime ~= '' then
    local tReady = SimToLua( node.ReadyTime )
    local rFunction, rError

    if tReady then
        if tReady:sub( 1, 8 ) == 'function' then
            rFunction, rError = loadstring( format( "return %s", tReady ) )
        else
            rFunction, rError = loadstring( format(
                "return function( wait, spend, resource )\n" ..
                "    return max( 0, wait, %s )\n" ..
                "end", tReady ) )
        end
    end

    if rFunction then
        _, rFunction = pcall( rFunction )
        setfenv( rFunction, state )
    end

    if rError then
        rError = rError:match( ":%d+: (.*)" )
    end

    Output.Ready = rFunction
    Output.ReadyError = rError
    Output.ReadyLua = tReady
    Output.ReadyElements = tReady and getScriptElements( tReady )
  end

  return Output
end ]]


function scripts:CheckScript( scriptID, action, elem )
    local prev_action = state.this_action
    if action then state.this_action = action end

    local script = self.DB[ scriptID ]

    if not script then
        state.this_action = prev_action
        return false
    end

    if not elem then
        if script.Error then
            state.this_action = prev_action
            return false, script.Error

        elseif not script.Conditions then
            state.this_action = prev_action
            return true

        else
            local success, value = pcall( script.Conditions )

            if success then
                state.this_action = prev_action
                return value
            end
        end
    
    else
        if not script.Modifiers[ elem ] then
            state.this_action = prev_action
            return nil, "No such modifier: " .. elem

        else
            local success, value = pcall( script.Modifiers[ elem ] )

            if success then
                state.this_action = prev_action
                return value
            end
        end
    end

    state.this_action = prev_action
    return false
end


function scripts:CheckVariable( scriptID )
    local script = self.DB[ scriptID ]

    if not script then
        return false, "no script"

    elseif script.Error then
        return false, script.Error

    end

    local mods = script.Modifiers
    local op = mods.op and mods.op() or 'set'

    if op == 'set' then
        local s, val = pcall( mods.value )
        if s then return val end
    end

    return false, "no op or error"
end
    


-- Attaches modifiers for the current entry to the state.args table.
function scripts:ImportModifiers( scriptID )
    for k in pairs( state.args ) do
        state.args[ k ] = nil
    end

    local script = self.DB[ scriptID ]
    if not script or not script.Modifiers then return end

    for k, v in pairs( script.Modifiers ) do
        local s, val = pcall( v )
        if s then state.args[ k ] = val end
    end
end


function scripts:IsTimeSensitive( scriptID )
    local s = self.DB[ scriptID ]

    return s and s.TimeSensitive
end


--[[ function ns.checkTimeScript( entry, wait, spend, spendType )

    local script = scripts.A[ entry ]

    if not entry or not script or not script.Ready then return delay end

    local out = script.Ready( wait, spend, spendType )

    out = out or 0

    out = out > 0 and roundUp( out, 2 ) or out

    return out
end ]]


function scripts:GetModifiers( scriptID, out )
    out = out or {}

    local script = self.DB[ scriptID ]

    if not script then return out end

    for k, v in pairs( script.Modifiers ) do
        local success, value = pcall(v)
        if success then out[k] = value end
    end

    return out
end


-- Attaches modifiers for the current entry to the state.args table.
function scripts:ImportModifiers( scriptID )
    for k in pairs( state.args ) do
        state.args[ k ] = nil
    end

    local script = self.DB[ scriptID ]
    if not script or not script.Modifiers then return end

    for k, v in pairs( script.Modifiers ) do
        local s, val = pcall( v )
        if s then state.args[ k ] = val end
    end
end


function scripts:LoadScripts()
    local profile = Hekili.DB.profile

    wipe( self.DB )

    for pack, pData in pairs( profile.packs ) do
        if pData.spec and class.specs[ pData.spec ] then
            for list, lData in pairs( pData.lists ) do
                for action, data in ipairs( lData ) do
                    local scriptID = pack .. ":" .. list .. ":" .. action
                    local script = ConvertScript( data, true )

                    if data.action == "call_action_list" or data.action == "run_action_list" then
                        -- Check for Time Sensitive conditions.
                        script.TimeSensitive = false
                        
                        local lua = script.Lua

                        if lua then 
                            -- If resources are checked, it's time-sensitive.
                            for k in pairs( GetResourceInfo() ) do
                                if lua:find( k ) then script.TimeSensitive = true; break end
                            end

                            if not script.TimeSensitive then
                                -- Check for other time-sensitive variables.
                                if lua:find( "time" ) or lua:find( "cooldown" ) or lua:find( "charge" ) or lua:find( "remain" ) or lua:find( "up" ) or lua:find( "down" ) or lua:find( "ticking" ) or lua:find( "refreshable" ) then
                                    script.TimeSensitive = true
                                end
                            end
                        end
                    end
                    self.DB[ scriptID ] = script
                end
            end
        end
    end
end

function Hekili:LoadScripts()
    self.Scripts:LoadScripts()
    self:UpdateDisplayVisibility()
end


function scripts:ImplantDebugData( data )
    local prev = state.this_action
    state.this_action = data.actionName

    if data.hook then
        local s = self.DB[ data.hook ]
        local pack, list, entry = data.hook:match( "^(.-):(.-):(.-)$" )

        data.HookHeader = "Called from " .. pack .. ", " .. list .. ", " .. "#" .. entry .. "."
        data.HookScript = s.SimC
        data.HookElements = data.HookElements or {}

        self:StoreValues( data.HookElements, s )
    end

    if data.script then        
        local s = self.DB[ data.script ]
        data.ActScript = s.SimC
        data.ActElements = data.ActElements or {}
        self:StoreValues( data.ActElements, s )
    end

    state.this_action = prev
end


local key_cache = setmetatable( {}, {
    __index = function( t, k )
        t[k] = k:gsub( "(%S+)%[(%d+)]", "%1.%2" )
        return t[k]
    end
})


local checked = {}

function scripts:GetConditionsAndValues( scriptID, listName, actID )
    if listName and actID then
        scriptID = scriptID .. ":" .. listName .. ":" .. actID
    end

    local script = self.DB[ scriptID ]

    if script and script.SimC and script.SimC ~= "" then        
        local output = script.SimC

        if script.Elements then
            wipe( checked )

            for k, v in pairs( script.Elements ) do
                if not checked[ k ] then
                    local key = key_cache[ k ]
                    local success, value = pcall( v )

                    -- if emsg then value = emsg end

                    if type( value ) == 'number' then
                        output = output:gsub( "([^a-z0-9_.[])("..key..")([^a-z0-9_.[])", format( "%%1%%2[%.2f]%%3", value ) )
                        output = output:gsub( "^("..key..")([^a-z0-9_.[])", format( "%%1[%.2f]%%2", value ) )
                        output = output:gsub( "([^a-z0-9_.[])("..key..")$", format( "%%1%%2[%.2f]", value ) )
                        -- output = output:gsub( "^("..key..")", format( "%%1[%.2f]", value ) )
                    else
                        output = output:gsub( "([^a-z0-9_.[])("..key..")([^a-z0-9_.[])", format( "%%1%%2[%s]%%3", tostring( value ) ) )
                        output = output:gsub( "^("..key..")([^a-z0-9_.[])", format( "%%1[%s]%%2", tostring( value ) ) )
                        output = output:gsub( "([^a-z0-9_.[])("..key..")$", format( "%%1%%2[%s]", tostring( value ) ) )
                        -- output = output:gsub( "([^.]"..key..")", format( "%%1[%s]", tostring( value ) ) )
                        -- output = output:gsub( "^("..key..")", format( "%%1[%s]", tostring( value ) ) )
                    end

                    checked[ k ] = true
                end
            end
        end

        return output
    end

    return "NONE"
end

Hekili.dumpKeyCache = key_cache
