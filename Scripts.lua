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

-- Convert SimC syntax to Lua conditionals.
local SimToLua = function( str, modifier )

  -- If no conditions were provided, function should return true.
  if not str or str == '' then return nil end

  -- Strip comments.
  str = str:gsub("^%-%-.-\n", "")

  -- Replace '%' for division with actual division operator '/'.
  str = str:gsub("%%", "/")

  -- Replace '&' with ' and '.
  str = str:gsub("&", " and ")

  -- Replace '|' with ' or '.
  str = str:gsub("||", " or "):gsub("|", " or ")

  if not modifier then
    -- Replace assignment '=' with conditional '=='
    str = str:gsub("=", "==")

    -- Fix any conditional '==' that got impacted by previous.
    str = str:gsub("==+", "==")
    str = str:gsub(">=+", ">=")
    str = str:gsub("<=+", "<=")
    str = str:gsub("!=+", "~=")
    str = str:gsub("~=+", "~=")
  end

  -- Replace '!' with ' not '.
  str = str:gsub("!(.-) ", " not (%1) " )
  str = str:gsub("!(.-)$", " not (%1)" )
  str = str:gsub("!([^=])", " not %1")

  -- Condense whitespace.
  str = str:gsub("%s+", " ")

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
    str = str:gsub( "([!<>=|&()])", " %1 " ):gsub("%s+", " ")

    str = str:gsub( "([<>~!|]) ([|=])", "%1%2" )

    return str
end


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
    else tbl[k] = 'nil' end
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

  for i in Check:gmatch( "[^ ]+" ) do
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
    ModName = true
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

    Lua = Translated and trim( SpaceOutSim( Translated ) ) or nil,
    SimC = node.Script and trim( SpaceOutSim( node.Script ) ) or nil
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

    for m in pairs( specialModifiers ) do
        if node[ m ] then
            Output.SpecialMods = Output.SpecialMods .. " - " .. m .. " : " .. tostring( node[m] )
            local sFunction, Error = loadstring( 'return ' .. tostring( node[ m ] ) )
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
    local tReady = SimToLua( node.ReadyTime, true )
    local rFunction, rError

    if tReady then
        if tReady:sub( 1, 8 ) == 'function' then
            rFunction, rError = loadstring( 'return ' .. tReady )
        else
            rFunction, rError = loadstring( 'return function( wait, spend, resource )\n' ..
            'return max( 0, wait, ' .. tReady .. ' )\n' ..
            'end' )
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

    if action then state.this_action = action end

    local tblScript = scripts[ cat ][ key ]

    if not tblScript then
        return false

    elseif tblScript.Error then
        return false, tblScript.Error

    elseif tblScript.Conditions == nil then
        return true

    else
        local success, value = pcall( tblScript.Conditions )

        if success then

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

    return false

end
local checkScript = ns.checkScript


function ns.checkTimeScript( entry, wait, spend, spend_type )

    local script = scripts.A[ entry ]

    if not entry or not script or not script.Ready then return delay end

    local out = script.Ready( wait, spend, spend_type )

    return out or 0

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
        t.k = k:gsub( "(%S+)%[(%d+)]", "%1.%2" )
        return t.k
    end
})


function ns.getConditionsAndValues( sType, sID )

    local script = scripts[ sType ]
    script = script and script[ sID ]

    if script and script.SimC and script.SimC ~= "" then
        local output = script.SimC

        if script.Elements then
            for k, v in pairs( script.Elements ) do
                local key = key_cache[ k ]
                local value, emsg = pcall( v )

                if emsg then value = emsg end

                if type(value) == 'number' then
                    output = output:gsub( key, format( key .. "[%.2f]", value ) )
                else
                    output = output:gsub( key, format( key .. "[%s]", tostring( value ) ) )
                end
            end
        end

        return output
    end

    return "NONE"

end
