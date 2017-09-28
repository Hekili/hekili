-- Scripts.lua
-- December 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local scripts = ns.scripts
local state = ns.state

local ceil = math.ceil
local orderedPairs = ns.orderedPairs
local roundUp = ns.roundUp
local safeMax = ns.safeMax

local trim = string.trim

Hekili.Scripts = scripts


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


-- Convert SimC syntax to Lua conditionals.
local SimToLua = function( str, modifier )

  -- If no conditions were provided, function should return true.
  if not str or str == '' then return nil end

  -- Strip comments.
  str = str:gsub("^%-%-.-\n", "")

  -- Replace '!' with ' not '.
  str = forgetMeNots( str )

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

  str = str:gsub("prev%.(%d+)", "prev[%1]")
  str = str:gsub("prev_gcd%.(%d+)", "prev_gcd[%1]")
  str = str:gsub("prev_off_gcd%.(%d+)", "prev_off_gcd[%1]")

  return str

end


local SpaceOutSim = function( str )
    str = str:gsub( "([!<>=|&()*%-%+%%])", " %1 " ):gsub("%s+", " ")

    str = str:gsub( "([<>~!|]) ([|=])", "%1%2" )

    str = str:trim()

    return str
end
ns.SpaceOutSim = SpaceOutSim


local storeValues = function( tbl, node )

  for k in pairs( tbl ) do
    tbl[k] = nil
  end

  if not node.Elements then
    return
  end

  for k, v in pairs( node.Elements ) do
    local success, result = pcall( v )

    if success then tbl[k] = result
    elseif type( result ) == 'string' then
      tbl[k] = result:match( "lua:%d+: (.*)" ) or result
    end
    if tbl[k] == nil then tbl[k] = 'nil' end
  end
end
ns.storeValues = storeValues


local function storeReadyValues( tbl, node )

    for k in pairs( tbl ) do
        tbl[k] = nil
    end

    if not node.ReadyElements then
        return
    end

    if node.ReadyElements then
        for k, v in pairs( node.ReadyElements ) do
            local success, result = pcall( v )

            if success then tbl[k] = result
            elseif type( result ) == 'string' then
                tbl[k] = result:match( "lua:%d+: (.*)" ) or result
            else tbl[k] = 'nil' end
        end
    end

end
ns.storeReadyValues = storeReadyValues


local stripScript = function( str, thorough )
  if not str then return 'true' end

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


local getScriptElements = function( script )
  local Elements, Check = {}, stripScript( script, true )

  for i in Check:gmatch( "[^ ,]+" ) do
    if not Elements[i] and not tonumber(i) then
      local eFunction = loadstring( 'return '.. (i or true) )

      if eFunction then setfenv( eFunction, state ) end

      local success, value = pcall( eFunction )

      Elements[i] = eFunction
    end
  end

  return Elements
end


local specialModifiers = {
    CycleTargets = true,
    MaximumTargets = true,
    CheckMovement = true,
    Movement = true,
    ModName = false
}


local convertScript = function( node, hasModifiers )
  local Translated = SimToLua( node.Script )
  local sFunction, Error

  if Translated then
    sFunction, Error = loadstring( 'return ' .. Translated )
  end

  if sFunction then
    setfenv( sFunction, state )
  end

  if Error then
    Error = Error:match( ":%d+: (.*)" )
  end

  local sElements = Translated and getScriptElements( Translated )

  local Output = {
    Conditions = sFunction,
    Error = Error,
    Elements = sElements,
    Modifiers = {},
    SpecialMods = "",

    Lua = Translated and trim( Translated ) or nil,
    SimC = node.Script and trim( node.Script ) or nil
  }

  if hasModifiers then -- and ( node.Args and node.Args ~= '' ) then
    
    if node.Args and node.Args ~= '' then
        local tModifiers = SimToLua( node.Args, true )

        for m in tModifiers:gmatch("[^,|^$]+") do
          local Key, Value = m:match("^(.-)=(.-)$")

          if Key and Value then
            local sFunction, Error = loadstring( 'return ' .. Value )

            if sFunction then
              setfenv( sFunction, state )
              Output.Modifiers[ Key ] = sFunction
            else
              Output.Modifiers[ Key ] = Error
            end
          end
        end
    end

    for m, value in pairs( specialModifiers ) do
        if node[ m ] then
            local o = tostring( node[m] )
            Output.SpecialMods = Output.SpecialMods .. " - " .. m .. " : " .. o
            local sFunction, Error
            if value then
                sFunction, Error = loadstring( 'return ' .. o )
            else
                sFunction, Error = loadstring( 'return "' .. o .. '"' )
            end
            if sFunction then
                setfenv( sFunction, state )
                Output.Modifiers[ m ] = sFunction
            else
                Output.Modifiers[ m ] = Error
            end
        end
    end
  end

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
end


ns.checkScript = function( cat, key, action, recheck )

    local prev_action = state.this_action
    if action then state.this_action = action end

    local tblScript = scripts[ cat ][ key ]

    if not tblScript then
        state.this_action = prev_action
        return false

    elseif tblScript.Error then
        state.this_action = prev_action
        return false, tblScript.Error

    elseif tblScript.Conditions == nil then
        state.this_action = prev_action
        return true

    else
        local success, value = pcall( tblScript.Conditions )

        if success then

            state.this_action = prev_action
            return value

            -- This is presently too CPU expensive to use.

            --[[ if not recheck then recheck = Hekili.DB.profile[ 'Recommendation Window' ] end
            
            if not recheck or recheck == 0 then return value end

            local checks = ceil( recheck * Hekili.DB.profile[ 'Updates Per Second' ] )
            local orig = state.delay

            for i = 1, checks do
                state.delay = orig + ( recheck * i / checks )

                local resuccess, revalue = pcall( tblScript.Conditions )

                if not resuccess or not revalue then
                    state.delay = orig
                    return false
                end
            end

            state.delay = orig
            return true ]]

        end

    end

    state.this_action = prev_action
    return false

end
local checkScript = ns.checkScript


function ns.isTimeSensitive( cat, key, action )
    local Script = scripts[ cat ][ key ]

    if not Script then
        return false
    end

    return Script.TimeSensitive
end


function ns.checkTimeScript( entry, wait, spend, spend_type )

    local script = scripts.A[ entry ]

    if not entry or not script or not script.Ready then return delay end

    local out = script.Ready( wait, spend, spend_type )

    out = out or 0

    out = out > 0 and roundUp( out, 2 ) or out

    return out

end


ns.getModifiers = function( list, entry )

  local mods = {}

  if not scripts['A'][list..':'..entry].Modifiers then return mods end

  for k,v in pairs( scripts['A'][list..':'..entry].Modifiers ) do
    local success, value = pcall(v)
    if success then mods[k] = value end
  end

  return mods

end
local getModifiers = ns.getModifiers
state.getModifiers = getModifiers


ns.importModifiers = function( list, entry )

  local key = list..':'..entry

  for k in pairs( state.args ) do
    state.args[ k ] = nil
  end

  if not scripts['A'][list..':'..entry].Modifiers then return end

  for k,v in pairs( scripts['A'][list..':'..entry].Modifiers ) do
    local success, value = pcall(v)
    if success then state.args[k] = value end
  end

end


ns.loadScripts = function()

  local Displays, Hooks, Actions = scripts.D, scripts.P, scripts.A
  local Profile = Hekili.DB.profile

  for i, _ in ipairs( Displays ) do
    Displays[i] = nil
  end

  for k, _ in pairs( Hooks ) do
    Hooks[k] = nil
  end

  for k, _ in pairs( Actions ) do
    Actions[k] = nil
  end

  for i, display in ipairs( Hekili.DB.profile.displays ) do
    Displays[ i ] = convertScript( display )

    --[[ for j, priority in ipairs( display.Queues ) do
      local pKey = i..':'..j
      Hooks[ pKey ] = convertScript( priority )
    end ]]
  end

  for i, list in ipairs( Hekili.DB.profile.actionLists ) do
    for a, action in ipairs( list.Actions ) do
      local aKey = i..':'..a
      Actions[ aKey ] = convertScript( action, true )
      if action.Ability == 'call_action_list' or action.Ability == 'run_action_list' then
        -- check for time sensitive conditions.
        local lua = Actions[ aKey ].Lua
        if lua and ( lua:match( "time" ) or lua:match( "cooldown" ) or lua:match( "charge" ) or lua:match( "buff" ) or lua:match( "focus" ) or lua:match( "energy" ) ) then
            Actions[ aKey ].TimeSensitive = true
        else
            Actions[ aKey ].TimeSensitive = false
        end
      end
    end
  end

end
local loadScripts = ns.loadScripts


function ns.implantDebugData( queue )
  if queue.display and queue.hook then
    if type( queue.hook ) == 'string' then
      -- this was a nested action list.
      local scrHook = scripts.A[ queue.hook ]
      local list, action = queue.hook:match( "(%d+):(%d+)" )
      queue.HookHeader = 'Called from ' .. Hekili.DB.profile.actionLists[ tonumber( list ) ].Name .. ' #' .. action
      queue.HookScript = scrHook.SimC
      queue.HookElements = queue.HookElements or {}
      storeValues( queue.HookElements, scrHook )
    else
      local scrHook = scripts.P[ queue.display..':'..queue.hook ]
      queue.HookScript = scrHook.SimC
      queue.HookElements = queue.HookElements or {}
      storeValues( queue.HookElements, scrHook )
    end
  end

  if queue.list and queue.action then
    local scrAction = scripts.A[ queue.list..':'..queue.action ]
    queue.ActScript = scrAction.SimC
    queue.ActElements = queue.ActElements or {}
    storeValues( queue.ActElements, scrAction )

    local delay = ns.state.delay
    ns.state.delay = 0

    queue.ReadyScript = scrAction.ReadyLua
    queue.ReadyElements = queue.ReadyElements or {}
    storeReadyValues( queue.ReadyElements, scrAction )

    ns.state.delay = delay
  end
end


local key_cache = setmetatable( {}, {
    __index = function( t, k )
        t[k] = k:gsub( "(%S+)%[(%d+)]", "%1.%2" )
        return t[k]
    end
})


local checked = {}

function ns.getConditionsAndValues( sType, sID )

    local script = scripts[ sType ]
    script = script and script[ sID ]

    if script and script.SimC and script.SimC ~= "" then
        local output = script.SimC

        if script.Elements then
            table.wipe( checked )
            for k, v in pairs( script.Elements ) do
                if not checked[ k ] then
                    local key = key_cache[ k ]
                    local success, value = pcall( v )

                    -- if emsg then value = emsg end

                    if type(value) == 'number' then
                        output = output:gsub( "([^.]"..key..")", format( "%%1[%.2f]", value ) )
                        output = output:gsub( "^("..key..")", format( "%%1[%.2f]", value ) )
                    else
                        output = output:gsub( "([^.]"..key..")", format( "%%1[%s]", tostring( value ) ) )
                        output = output:gsub( "^("..key..")", format( "%%1[%s]", tostring( value ) ) )
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
