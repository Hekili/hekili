-- Hekili.lua
-- April 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state
local scriptDB = Hekili.Scripts

local buildUI = ns.buildUI
local callHook = ns.callHook
local checkScript = ns.checkScript
local clashOffset = ns.clashOffset
local formatKey = ns.formatKey
local getSpecializationID = ns.getSpecializationID
local getResourceName = ns.getResourceName
local importModifiers = ns.importModifiers
local initializeClassModule = ns.initializeClassModule
local isKnown = ns.isKnown
local isUsable = ns.isUsable
local isTimeSensitive = ns.isTimeSensitive
local loadScripts = ns.loadScripts
local refreshBindings = ns.refreshBindings
local refreshOptions = ns.refreshOptions
local restoreDefaults = ns.restoreDefaults
local runOneTimeFixes = ns.runOneTimeFixes
local convertDisplays = ns.convertDisplays
local runHandler = ns.runHandler
local tableCopy = ns.tableCopy
local timeToReady = ns.timeToReady
local trim = string.trim

local mt_resource = ns.metatables.mt_resource
local ToggleDropDownMenu = L_ToggleDropDownMenu

local updatedDisplays = {}



-- checkImports()
-- Remove any displays or action lists that were unsuccessfully imported.
local function checkImports()
    
    local profile = Hekili.DB.profile
    
    for i = #profile.displays, 1, -1 do
        local display = profile.displays[ i ]
        if type( display ) ~= 'table' or display.Name:match("^@") then
            table.remove( profile.displays, i )
        else
            if not display.minST or type( display.minST ) ~= 'number' then display.minST = 0 end
            if not display.maxST or type( display.maxST ) ~= 'number' then display.maxST = 0 end
            if not display.minAE or type( display.minAE ) ~= 'number' then display.minAE = 0 end
            if not display.maxAE or type( display.maxAE ) ~= 'number' then display.maxAE = 0 end
            if not display.minAuto or type( display.minAuto ) ~= 'number' then display.minAuto = 0 end
            if not display.maxAuto or type( display.maxAuto ) ~= 'number' then display.maxAuto = 0 end
            if not display.rangeType then display.rangeType = 'ability' end
            
            if display['PvE Visibility'] and not display.alphaAlwaysPvE then
                if display['PvE Visibility'] == 'always' then
                    display.alwaysPvE = true
                    display.alphaAlwaysPvE = 1
                    display.targetPvE = false
                    display.alphaTargetPvE = 1
                    display.combatPvE = false
                    display.alphaCombatPvE = 1
                elseif display['PvE Visibility'] == 'combat' then
                    display.alwaysPvE = false
                    display.alphaAlwaysPvE = 1
                    display.targetPvE = false
                    display.alphaTargetPvE = 1
                    display.combatPvE = true
                    display.alphaCombatPvE = 1
                elseif display['PvE Visibility'] == 'target' then
                    display.alwaysPvE = false
                    display.alphaAlwaysPvE = 1
                    display.targetPvE = true
                    display.alphaTargetPvE = 1
                    display.combatPvE = false
                    display.alphaCombatPvE = 1
                else
                    display.alwaysPvE = false
                    display.alphaAlwaysPvE = 1
                    display.targetPvE = false
                    display.alphaTargetPvE = 1
                    display.combatPvE = false
                    display.alphaCombatPvE = 1
                end
                display['PvE Visibility'] = nil
            end
            
            if display['PvP Visibility'] and not display.alphaAlwaysPvP then
                if display['PvP Visibility'] == 'always' then
                    display.alwaysPvP = true
                    display.alphaAlwaysPvP = 1
                    display.targetPvP = false
                    display.alphaTargetPvP = 1
                    display.combatPvP = false
                    display.alphaCombatPvP = 1
                elseif display['PvP Visibility'] == 'combat' then
                    display.alwaysPvP = false
                    display.alphaAlwaysPvP = 1
                    display.targetPvP = false
                    display.alphaTargetPvP = 1
                    display.combatPvP = true
                    display.alphaCombatPvP = 1
                elseif display['PvP Visibility'] == 'target' then
                    display.alwaysPvP = false
                    display.alphaAlwaysPvP = 1
                    display.targetPvP = true
                    display.alphaTargetPvP = 1
                    display.combatPvP = false
                    display.alphaCombatPvP = 1
                else
                    display.alwaysPvP = false
                    display.alphaAlwaysPvP = 1
                    display.targetPvP = false
                    display.alphaTargetPvP = 1
                    display.combatPvP = false
                    display.alphaCombatPvP = 1
                end
                display['PvP Visibility'] = nil
            end
            
        end
    end
end
ns.checkImports = checkImports


function ns.pruneDefaults()
    
    local profile = Hekili.DB.profile
    
    for i = #profile.displays, 1, -1 do
        local display = profile.displays[ i ]
        if not ns.isDefault( display.Name, "displays" ) then
            display.Default = false
        end 
    end
    
    for i = #profile.actionLists, 1, -1 do
        local list = profile.actionLists[ i ]
        if type( list ) ~= 'table' or list.Name:match("^@") then
            for dispID, display in ipairs( profile.displays ) do
                if display.precombatAPL > i then display.precombatAPL = display.precombatAPL - 1 end
                if display.defaultAPL > i then display.defaultAPL = display.defaultAPL - 1 end
            end
            table.remove( profile.actionLists, i )
        elseif not ns.isDefault( list.Name, "actionLists" ) then
            list.Default = false
        end
        
        
    end 
    
end



local hookOnce = false

-- OnInitialize()
-- Addon has been loaded by the WoW client (1x).
function Hekili:OnInitialize()
    self.DB = LibStub( "AceDB-3.0" ):New( "HekiliDB", self:GetDefaults() )
    
    self.Options = self:GetOptions()
    self.Options.args.profiles = LibStub( "AceDBOptions-3.0" ):GetOptionsTable( self.DB )
    
    -- Add dual-spec support
    local DualSpec = LibStub( "LibDualSpec-1.0" )
    DualSpec:EnhanceDatabase( self.DB, "Hekili" )
    DualSpec:EnhanceOptions( self.Options.args.profiles, self.DB )
    
    self.DB.RegisterCallback( self, "OnProfileChanged", "TotalRefresh" )
    self.DB.RegisterCallback( self, "OnProfileCopied", "TotalRefresh" )
    self.DB.RegisterCallback( self, "OnProfileReset", "TotalRefresh" )
    

    local AceConfig = LibStub( "AceConfig-3.0" )
    AceConfig:RegisterOptionsTable( "Hekili", self.Options )

    local AceConfigDialog = LibStub( "AceConfigDialog-3.0" )
    self.optionsFrame = AceConfigDialog:AddToBlizOptions( "Hekili", "Hekili" )
    self:RegisterChatCommand( "hekili", "CmdLine" )
    self:RegisterChatCommand( "hek", "CmdLine" )
    
    local LDB = LibStub( "LibDataBroker-1.1", true )
    local LDBIcon = LDB and LibStub( "LibDBIcon-1.0", true )
    if LDB then
        ns.UI.Minimap = LDB:NewDataObject( "Hekili", {
            type = "launcher",
            text = "Hekili",
            icon = "Interface\\ICONS\\spell_nature_bloodlust",
            OnClick = function( f, button )
                if button == "RightButton" then ns.StartConfiguration()
                else
                    if not hookOnce then 
                        hooksecurefunc("L_UIDropDownMenu_InitializeHelper", function(frame)
                            for i = 1, L_UIDROPDOWNMENU_MAXLEVELS do
                                if _G["L_DropDownList"..i.."Backdrop"].SetTemplate then _G["L_DropDownList"..i.."Backdrop"]:SetTemplate( "Transparent" ) end
                                if _G["L_DropDownList"..i.."MenuBackdrop"].SetTemplate then _G["L_DropDownList"..i.."MenuBackdrop"]:SetTemplate( "Transparent" ) end
                            end
                        end )
                        hookOnce = true
                    end
                    ToggleDropDownMenu( 1, nil, Hekili_Menu, f:GetName(), "MENU" )
                end
                GameTooltip:Hide()
            end,
            OnTooltipShow = function( tt )
                tt:AddDoubleLine( "Hekili", ns.UI.Minimap.text )
                tt:AddLine( "|cFFFFFFFFLeft-click to make quick adjustments.|r" )
                tt:AddLine( "|cFFFFFFFFRight-click to open the options interface.|r" )
            end,
        } )
        
        function ns.UI.Minimap:RefreshDataText()
            local p = Hekili.DB.profile
            local color = "FFFFD100"
            
            self.text = format( "|c%s%s|r %sCD|r %sInt|r %sPot|r",
            color,
            p['Mode Status'] == 0 and "Single" or ( p['Mode Status'] == 2 and "AOE" or ( p['Mode Status'] == 3 and "Auto" or "X" ) ),
            p.Cooldowns and "|cFF00FF00" or "|cFFFF0000",
            p.Interrupts and "|cFF00FF00" or "|cFFFF0000",
            p.Potions and "|cFF00FF00" or "|cFFFF0000" )
        end
        
        ns.UI.Minimap:RefreshDataText()
        
        if LDBIcon then
            LDBIcon:Register( "Hekili", ns.UI.Minimap, self.DB.profile.iconStore )
        end
    end
    
    
    if not self.DB.profile.Version or self.DB.profile.Version < 7 or not self.DB.profile.Release or self.DB.profile.Release < 20161000 then
        self.DB:ResetDB()
    end
    
    self.DB.profile.Release = self.DB.profile.Release or 20170416.0
    
    initializeClassModule()
    refreshBindings()
    restoreDefaults()
    runOneTimeFixes()
    convertDisplays()
    checkImports()
    refreshOptions()
    loadScripts()
    
    ns.updateTalents()
    ns.updateGear()
    
    ns.primeTooltipColors()
    
    callHook( "onInitialize" )
    
    if class.file == 'NONE' then
        if self.DB.profile.Enabled then
            self.DB.profile.Enabled = false
            self.DB.profile.AutoDisabled = true
        end
        for i, buttons in ipairs( ns.UI.Buttons ) do
            for j, _ in ipairs( buttons ) do
                buttons[j]:Hide()
            end
        end
    end
    
end


function Hekili:ReInitialize()
    ns.initializeClassModule()
    refreshBindings()
    restoreDefaults()
    convertDisplays()
    checkImports()
    refreshOptions()
    runOneTimeFixes()
    loadScripts()
    
    ns.updateTalents()
    ns.updateGear()
    
    self.DB.profile.Release = self.DB.profile.Release or 20161003.1
    
    callHook( "onInitialize" )
    
    if self.DB.profile.Enabled == false and self.DB.profile.AutoDisabled then 
        self.DB.profile.AutoDisabled = nil
        self.DB.profile.Enabled = true
        self:Enable()
    end
    
    if class.file == 'NONE' then
        self.DB.profile.Enabled = false
        self.DB.profile.AutoDisabled = true
        for i, buttons in ipairs( ns.UI.Buttons ) do
            for j, _ in ipairs( buttons ) do
                buttons[j]:Hide()
            end
        end
    end
    
end 


function Hekili:OnEnable()
    
    ns.specializationChanged()
    ns.StartEventHandler()
    buildUI()
    ns.overrideBinds()
    ns.ReadKeybindings()
    
    Hekili.s = ns.state
    
    -- May want to refresh configuration options, key bindings.
    if self.DB.profile.Enabled then
        self:UpdateDisplays()
        ns.Audit()
    else
        self:Disable()
    end
    
end


function Hekili:OnDisable()
    self.DB.profile.Enabled = false
    ns.StopEventHandler()
    buildUI()
end


function Hekili:Toggle()
    self.DB.profile.Enabled = not self.DB.profile.Enabled
    if self.DB.profile.Enabled then self:Enable()
else self:Disable() end
end


-- Texture Caching,
local s_textures = setmetatable( {},
{
    __index = function(t, k)
        local a = _G[ 'GetSpellTexture' ](k)
        if a and k ~= GetSpellInfo( 115698 ) then t[k] = a end
        return (a)
    end
} )

local i_textures = setmetatable( {},
{
    __index = function(t, k)
        local a = select(10, GetItemInfo(k))
        if a then t[k] = a end
        return a
    end
} )

-- Insert textures that don't work well with predictions.
s_textures[ 115356 ] = 1029585 -- Windstrike
s_textures[ 17364 ] = 132314 -- Stormstrike
-- NYI: Need Chain Lightning/Lava Beam here.

local function GetSpellTexture( spell )
    -- if class.abilities[ spell ].item then return i_textures[ spell ] end
    return ( s_textures[ spell ] )
end


local z_PVP = {
    arena = true,
    pvp = true
}


local palStack = {}
local cachedResults = {}
local cachedValues = {}


function checkAPLConditions()
    for k, v in pairs( palStack ) do
        if v ~= 0 then
            cachedResults[ k ][ state.delay ] = cachedResults[ k ][ state.delay ] or checkScript( 'A', v )
            cachedValues[ k ][ state.delay ] = cachedValues[ k ][ state.delay ] or ns.getConditionsAndValues( 'A', v )

            if Hekili.ActiveDebug then Hekili:Debug( "The conditions for %s would%s pass at %.2f.\n%s", k, cachedResults[ k ][ state.delay ] and "" or " NOT", state.delay, cachedValues[ k ][ state.delay ] ) end
            if not cachedResults[ k ][ state.delay ] then return false end
        end
    end
    return true
end



function Hekili:ProcessPredictiveActionList( dispID, hookID, listID, slot, depth, action, wait, clash )
    
    local display = self.DB.profile.displays[ dispID ]
    local list = self.DB.profile.actionLists[ listID ]
    
    local debug = self.ActiveDebug
    
    -- if debug then self:Debug( "Testing action list [ %d - %s ].", listID, list and list.Name or "ERROR - Does Not Exist" ) end
    if debug then self:Debug( "Previous Recommendation: %s at +%.2fs, clash is %.2f.", action or "NO ACTION", wait or 60, clash or 0 ) end
    
    -- the stack will prevent list loops, but we need to keep this from destroying existing data... later.
    if not list then
        if debug then self:Debug( "No list with ID #%d. Should never see.", listID ) end
    elseif palStack[ list.Name ] then
        if debug then self:Debug( "Action list loop detected. %s was already processed earlier. Aborting.", list.Name ) end
        return 
    else
        if debug then self:Debug( "Adding %s to the list of processed action lists.", list.Name ) end
        palStack[ list.Name ] = true
    end
    
    local chosen_action = action
    local chosen_clash = clash or 0
    local chosen_wait = wait or 60
    local chosen_depth = depth or 0
    
    local stop = false
    
    if ns.visible.list[ listID ] then
        local actID = 1
        
        while actID <= #list.Actions do
            if chosen_wait <= state.cooldown.global_cooldown.remains then
                if debug then self:Debug( "The last selected ability ( %s ) is available by the next GCD. End loop.", chosen_action ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            elseif chosen_wait == 0 then
                if debug then self:Debug( "The last selected ability ( %s ) has no wait time. End loop.", chosen_action ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            elseif stop then
                if debug then self:Debug( "Returning to parent list after completing Run_Action_List ( %d - %s ).", listID, list.Name ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            end
            
            if ns.visible.action[ listID..':'..actID ] then
                
                -- Check for commands before checking actual actions.
                local entry = list.Actions[ actID ]
                state.this_action = entry.Ability
                state.this_args = entry.Args
                
                state.delay = nil
                chosen_depth = chosen_depth + 1
                
                -- Need to expand on modifiers, gather from other settings as needed.
                if debug then self:Debug( "\n[ %2d ] Testing entry %s:%d ( %s ) with modifiers ( %s ).", chosen_depth, list.Name, actID, entry.Ability, entry.Args or "NONE" ) end
                
                local ability = class.abilities[ entry.Ability ]

                local wait_time = 60
                local clash = 0
                
                local known = ability and isKnown( state.this_action )
                
                if debug then self:Debug( "%s is %s.", ability and ability.name or entry.Ability, known and "KNOWN" or "NOT KNOWN" ) end
                
                if known then
                    local scriptID = listID .. ':' .. actID
                    
                    -- Used to notify timeToReady() about an artificial delay for this ability.
                    state.script.entry = entry.whenReady == 'script' and scriptID or nil                    
                    importModifiers( listID, actID )

                    wait_time = timeToReady( state.this_action )

                    clash = clashOffset( state.this_action )                    
                    state.delay = wait_time
                    
                    if wait_time >= chosen_wait then
                        if debug then self:Debug( "This action is not available in time for consideration ( %.2f vs. %.2f ). Skipping.", wait_time, chosen_wait ) end
                    else
                        -- APL checks.
                        if entry.Ability == 'variable' then
                            -- local aScriptValue = checkScript( 'A', scriptID )
                            local varName = entry.ModVarName or state.args.name
                            
                            if debug then self:Debug( " - variable.%s will refer to this action's script.", varName or "MISSING" ) end
                            
                            if varName ~= nil then -- and aScriptValue ~= nil then
                                state.variable[ "_" .. varName ] = scriptID
                                -- We just store the scriptID so that the variable actually gets tested at time of comparison.
                            end
                            
                        elseif entry.Ability == 'call_action_list' or entry.Ability == 'run_action_list' then
                            -- We handle these here to avoid early forking between starkly different APLs.
                            local aScriptPass = true
                            
                            if not entry.Script or entry.Script == '' then
                                if debug then self:Debug( "%s does not have any required conditions.", ability.name ) end
                                
                            else
                                aScriptPass = checkScript( 'A', scriptID )
                                if debug then self:Debug( "Conditions %s at ( %.2f + %.2f ): %s", aScriptPass and "MET" or "NOT MET", state.offset, state.delay, ns.getConditionsAndValues( 'A', scriptID ) ) end
                            end
                            
                            if aScriptPass then
                                
                                local aList = entry.ModName or state.args.name
                                
                                if aList then
                                    -- check to see if we have a real list name.
                                    local called_list = 0
                                    for i, list in ipairs( self.DB.profile.actionLists ) do
                                        if list.Name == aList then
                                            called_list = i
                                            break
                                        end
                                    end
                                    
                                    if called_list > 0 then
                                        if debug then self:Debug( "The action list for %s ( %s ) was found.", entry.Ability, aList ) end
                                        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:ProcessPredictiveActionList( dispID, listID .. ':' .. actID , called_list, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                                        if debug then self:Debug( "The action list ( %s ) returned with recommendation %s after %.2f seconds.", aList, chosen_action or "none", chosen_wait ) end
                                        stop = entry == 'run_action_list'
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end
                            
                        else
                            local preservedWait = wait_time
                            local interval = state.gcd / 3
                            local calledList = false
                            
                            -- There is a leak inside here, it worsens with higher testCounts.
                            for testCount = 1, ( self.LowImpact or self.DB.profile['Low Impact Mode'] ) and 2 or 5 do
                                
                                if stop or calledList then break end
                                
                                if testCount == 1 then
                                elseif testCount == 2 then state.delay = preservedWait + 0.1
                                elseif testCount == 3 then state.delay = preservedWait + ( state.gcd / 2 )
                                elseif testCount == 4 then state.delay = preservedWait + state.gcd
                                elseif testCount == 5 then state.delay = preservedWait + ( state.gcd * 2 )
                                end
                                
                                local newWait = max( 0, state.delay - clash )
                                local usable = isUsable( state.this_action )
                                
                                if debug then self:Debug( "Test #%d at [ %.2f + %.2f ] - Ability ( %s ) is %s.", testCount, state.offset, state.delay, entry.Ability, usable and "USABLE" or "NOT USABLE" ) end
                                
                                if usable then
                                    local chosenWaitValue = max( 0, chosen_wait - chosen_clash )
                                    local readyFirst = newWait < chosenWaitValue
                                    
                                    if debug then self:Debug( " - this ability is %s at %.2f before the previous ability at %.2f.", readyFirst and "READY" or "NOT READY", newWait, chosenWaitValue ) end
                                    
                                    if readyFirst then
                                        local hasResources = ns.hasRequiredResources( state.this_action )
                                        if debug then
                                            self:Debug( " - the required resources are %s.", hasResources and "AVAILABLE" or "NOT AVAILABLE" )
                                            self:Debug( "   REQUIRES: %d %s.", ability.spend or 0, ability.spend_type or "NONE" )
                                            local resource = ability.spend_type and state[ ability.spend_type ]
                                            if resource then self:Debug( "   PRESENT:  %d %s.", resource.current, ability.spend_type ) end
                                        end
                                        
                                        if hasResources then
                                            local aScriptPass = true
                                            
                                            if not entry.Script or entry.Script == '' then 
                                                if debug then self:Debug( ' - this ability has no required conditions.' ) end
                                            else 
                                                aScriptPass = checkScript( 'A', scriptID )
                                                if debug then self:Debug( "Conditions %s at ( %.2f + %.2f ): %s", aScriptPass and "MET" or "NOT MET", state.offset, state.delay, ns.getConditionsAndValues( 'A', scriptID ) ) end
                                            end
                                            
                                            if aScriptPass then
                                                if entry.Ability == 'wait' then
                                                    -- local args = ns.getModifiers( listID, actID )
                                                    if not state.args.sec then state.args.sec = 1 end
                                                    if state.args.sec > 0 then
                                                        state.advance( state.args.sec )
                                                        actID = 0
                                                    end
                                                    
                                                elseif entry.Ability == 'potion' then
                                                    local potionName = state.args.ModName or state.args.name or class.potion
                                                    local potion = class.potions[ potionName ]
                                                    
                                                    if potion then
                                                        -- do potion things
                                                        slot.scriptType = entry.ScriptType or 'simc'
                                                        slot.display = dispID
                                                        slot.button = i
                                                        slot.item = nil
                                                        
                                                        slot.wait = state.delay
                                                        
                                                        slot.hook = hookID
                                                        slot.list = listID
                                                        slot.action = actID
                                                        
                                                        slot.actionName = state.this_action
                                                        slot.listName = list.Name
                                                        
                                                        slot.resource = ns.resourceType( chosen_action )
                                                        
                                                        slot.caption = entry.Caption
                                                        slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                                        slot.texture = select( 10, GetItemInfo( potion.item ) )
                                                        
                                                        chosen_action = state.this_action
                                                        chosen_wait = state.delay
                                                        chosen_clash = clash
                                                        break
                                                    end

                                                else
                                                    slot.scriptType = entry.ScriptType or 'simc'
                                                    slot.display = dispID
                                                    slot.button = i

                                                    slot.wait = state.delay

                                                    slot.hook = hookID
                                                    slot.list = listID
                                                    slot.action = actID

                                                    slot.actionName = state.this_action
                                                    slot.listName = list.Name

                                                    slot.resource = ns.resourceType( chosen_action )
                                                    
                                                    slot.caption = entry.Caption
                                                    slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                                    slot.texture = ability.texture
                                                    
                                                    chosen_action = state.this_action
                                                    chosen_wait = state.delay
                                                    chosen_clash = clash
                                                end

                                                if debug then self:Debug( "Action Chosen: %s at %f!", chosen_action, chosen_wait ) end

                                                if entry.CycleTargets and state.active_enemies > 1 and ability and ability.cycle then
                                                    if state.dot[ ability.cycle ].up and state.active_dot[ ability.cycle ] < ( state.args.MaxTargets or state.active_enemies ) then
                                                        slot.indicator = 'cycle'
                                                    end
                                                end

                                                break                                               
                                            end                                                    
                                        end
                                    end
                                end
                            end
                            
                            state.delay = preservedWait

                            if chosen_wait == 0 then break end

                        end
                    end
                end
            end
            
            actID = actID + 1
            
        end
        
    end

    palStack[ list.Name ] = nil
    return chosen_action, chosen_wait, chosen_clash, chosen_depth

end


function Hekili:GetPredictionFromAPL( dispID, hookID, listID, slot, depth, action, wait, clash )
    
    local display = self.DB.profile.displays[ dispID ]
    local list = self.DB.profile.actionLists[ listID ]
    
    local debug = self.ActiveDebug
    
    -- if debug then self:Debug( "Testing action list [ %d - %s ].", listID, list and list.Name or "ERROR - Does Not Exist" ) end
    if debug then self:Debug( "Previous Recommendation: %s at +%.2fs, clash is %.2f.", action or "NO ACTION", wait or 60, clash or 0 ) end
    
    -- the stack will prevent list loops, but we need to keep this from destroying existing data... later.
    if not list then
        if debug then self:Debug( "No list with ID #%d. Should never see.", listID ) end
    elseif palStack[ list.Name ] then
        if debug then self:Debug( "Action list loop detected. %s was already processed earlier. Aborting.", list.Name ) end
        return 
    else
        if debug then self:Debug( "Adding %s to the list of processed action lists.", list.Name ) end
        palStack[ list.Name ] = hookID or 0
        cachedResults[ list.Name ] = cachedResults[ list.Name ] or {}
        cachedValues[ list.Name ] = cachedValues[ list.Name ] or {}
    end
    
    local chosen_action = action
    local chosen_clash = clash or 0
    local chosen_wait = wait or 60
    local chosen_depth = depth or 0
    
    local stop = false
    
    if ns.visible.list[ listID ] then
        local actID = 1
        
        while actID <= #list.Actions do
            if chosen_wait <= state.cooldown.global_cooldown.remains then
                if debug then self:Debug( "The last selected ability ( %s ) is available by the next GCD. End loop.", chosen_action ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                table.wipe( cachedResults[ list.Name ] )
                table.wipe( cachedValues[ list.Name ] )
                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            elseif chosen_wait == 0 then
                if debug then self:Debug( "The last selected ability ( %s ) has no wait time. End loop.", chosen_action ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                table.wipe( cachedResults[ list.Name ] )
                table.wipe( cachedValues[ list.Name ] )
                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            elseif stop then
                if debug then self:Debug( "Returning to parent list after completing Run_Action_List ( %d - %s ).", listID, list.Name ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                table.wipe( cachedResults[ list.Name ] )
                table.wipe( cachedValues[ list.Name ] )
                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            end
            
            if ns.visible.action[ listID..':'..actID ] then
                
                -- Check for commands before checking actual actions.
                local entry = list.Actions[ actID ]
                state.this_action = entry.Ability
                state.this_args = entry.Args
                
                state.delay = nil
                chosen_depth = chosen_depth + 1
                
                -- Need to expand on modifiers, gather from other settings as needed.
                if debug then self:Debug( "\n[ %2d ] Testing entry %s:%d ( %s ) with modifiers ( %s ).", chosen_depth, list.Name, actID, entry.Ability, entry.Args or "NONE" ) end
                
                local ability = class.abilities[ entry.Ability ]

                local wait_time = 60
                local clash = 0
                
                local known = ability and isKnown( state.this_action )
                
                if debug then self:Debug( "%s is %s.", ability and ability.name or entry.Ability, known and "KNOWN" or "NOT KNOWN" ) end
                
                if known then
                    local scriptID = listID .. ':' .. actID
                    
                    -- Used to notify timeToReady() about an artificial delay for this ability.
                    state.script.entry = entry.whenReady == 'script' and scriptID or nil                    
                    importModifiers( listID, actID )

                    wait_time = timeToReady( state.this_action )

                    clash = clashOffset( state.this_action )                    
                    state.delay = wait_time
                    
                    if wait_time >= chosen_wait then
                        if debug then self:Debug( "This action is not available in time for consideration ( %.2f vs. %.2f ). Skipping.", wait_time, chosen_wait ) end
                    else
                        -- APL checks.
                        if entry.Ability == 'variable' then
                            -- local aScriptValue = checkScript( 'A', scriptID )
                            local varName = entry.ModVarName or state.args.name
                            
                            if debug then self:Debug( " - variable.%s will refer to this action's script.", varName or "MISSING" ) end
                            
                            if varName ~= nil then -- and aScriptValue ~= nil then
                                state.variable[ "_" .. varName ] = scriptID
                                -- We just store the scriptID so that the variable actually gets tested at time of comparison.
                            end

                        elseif entry.Ability == 'use_items' then
                            local aScriptPass = true
                            
                            if not entry.Script or entry.Script == '' then
                                if debug then self:Debug( "Use Items does not have any required conditions." ) end
                                
                            else
                                if isTimeSensitive( 'A', scriptID ) then 
                                    -- aScriptPass = checkAPLConditions() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "The Usable Items's conditions will be tested along with each action." ) end
                                else
                                    aScriptPass = checkAPLConditions() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "The conditions for this entry are not time sensitive and %s at ( %.2f + %.2f ).", aScriptPass and "PASS" or "DO NOT PASS", state.offset, state.delay ) end
                                end
                            end

                            if aScriptPass then
                                aList = "Usable Items"
                                if aList then
                                    -- check to see if we have a real list name.
                                    local called_list = 0
                                    for i, list in ipairs( self.DB.profile.actionLists ) do
                                        if list.Name == aList then
                                            called_list = i
                                            break
                                        end
                                    end
                                    
                                    if called_list > 0 then
                                        if debug then self:Debug( "The action list for %s ( %s ) was found.", entry.Ability, aList ) end
                                        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, listID .. ':' .. actID, called_list, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                                        if debug then self:Debug( "The action list ( %s ) returned with recommendation %s after %.2f seconds.", aList, chosen_action or "none", chosen_wait ) end
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end

                            end

                        elseif entry.Ability == 'call_action_list' or entry.Ability == 'run_action_list' then
                            -- We handle these here to avoid early forking between starkly different APLs.
                            local aScriptPass = true
                            
                            if not entry.Script or entry.Script == '' then
                                if debug then self:Debug( "%s does not have any required conditions.", ability.name ) end
                                
                            else
                                if isTimeSensitive( 'A', scriptID ) then 
                                    -- aScriptPass = checkAPLConditions() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "The APL's conditions will be tested along with each action." ) end
                                else
                                    aScriptPass = checkAPLConditions() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "The conditions for this entry are not time sensitive and %s at ( %.2f + %.2f ).", aScriptPass and "PASS" or "DO NOT PASS", state.offset, state.delay ) end
                                end
                            end
                            
                            if aScriptPass then
                                
                                local aList = entry.ModName or state.args.name
                                
                                if aList then
                                    -- check to see if we have a real list name.
                                    local called_list = 0
                                    for i, list in ipairs( self.DB.profile.actionLists ) do
                                        if list.Name == aList then
                                            called_list = i
                                            break
                                        end
                                    end
                                    
                                    if called_list > 0 then
                                        if debug then self:Debug( "The action list for %s ( %s ) was found.", entry.Ability, aList ) end
                                        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, listID .. ':' .. actID, called_list, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                                        if debug then self:Debug( "The action list ( %s ) returned with recommendation %s after %.2f seconds.", aList, chosen_action or "none", chosen_wait ) end
                                        stop = entry == 'run_action_list'
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end
                            
                        else
                            local usable = isUsable( state.this_action )
                            
                            if debug then self:Debug( "Testing at [ %.2f + %.2f ] - Ability ( %s ) is %s.", state.offset, state.delay, entry.Ability, usable and "USABLE" or "NOT USABLE" ) end
                            
                            if usable then
                                local chosenWaitValue = max( 0, chosen_wait - chosen_clash )
                                local readyFirst = state.delay < chosenWaitValue
                                
                                if debug then self:Debug( " - this ability is %s at %.2f before the previous ability at %.2f.", readyFirst and "READY" or "NOT READY", state.delay, chosenWaitValue ) end
                                
                                if readyFirst then
                                    local hasResources = true
                                    --[[ With predictive engine, timeToReady accounts for resources.
                                    
                                    if debug then
                                        self:Debug( " - the required resources are %s.", hasResources and "AVAILABLE" or "NOT AVAILABLE" )
                                        self:Debug( "   REQUIRES: %d %s.", ability.spend or 0, ability.spend_type or "NONE" )
                                        local resource = ability.spend_type and state[ ability.spend_type ]
                                        if resource then self:Debug( "   PRESENT:  %d %s.", resource.current, ability.spend_type ) end
                                    end ]]
                                    
                                    if hasResources then
                                        local aScriptPass = checkAPLConditions()

                                        if not aScriptPass then
                                            if debug then self:Debug( "This action entry is not available as the called action list would not be processed at %.2f.", state.delay ) end

                                        else
                                            if not entry.Script or entry.Script == '' then 
                                                if debug then self:Debug( ' - this ability has no required conditions.' ) end
                                            else 
                                                aScriptPass = checkScript( 'A', scriptID )
                                                if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                                            end
                                        end
                                        
                                        if aScriptPass then
                                            if entry.Ability == 'potion' then
                                                local potionName = state.args.ModName or state.args.name or class.potion
                                                local potion = class.potions[ potionName ]
                                                
                                                if potion then
                                                    slot.scriptType = entry.ScriptType or 'simc'
                                                    slot.display = dispID
                                                    slot.button = i
                                                    slot.item = nil
                                                    
                                                    slot.wait = state.delay
                                                    
                                                    slot.hook = hookID
                                                    slot.list = listID
                                                    slot.action = actID
                                                    
                                                    slot.actionName = state.this_action
                                                    slot.listName = list.Name
                                                    
                                                    slot.resource = ns.resourceType( chosen_action )
                                                    
                                                    slot.caption = entry.Caption
                                                    slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                                    slot.texture = select( 10, GetItemInfo( potion.item ) )
                                                        
                                                    chosen_action = state.this_action
                                                    chosen_wait = state.delay
                                                    chosen_clash = clash
                                                end

                                            else
                                                slot.scriptType = entry.ScriptType or 'simc'
                                                slot.display = dispID
                                                slot.button = i

                                                slot.wait = state.delay

                                                slot.hook = hookID
                                                slot.list = listID
                                                slot.action = actID

                                                slot.actionName = state.this_action
                                                slot.listName = list.Name

                                                slot.resource = ns.resourceType( chosen_action )
                                                
                                                slot.caption = entry.Caption
                                                slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                                slot.texture = ability.texture
                                                
                                                chosen_action = state.this_action
                                                chosen_wait = state.delay
                                                chosen_clash = clash
                                            end

                                            if debug then self:Debug( "Action Chosen: %s at %f!", chosen_action, chosen_wait ) end

                                        end                                                    
                                    end
                                end
                            end
                            
                            if chosen_wait == 0 then break end

                        end
                    end
                end
            end
            
            actID = actID + 1
            
        end
        
    end

    palStack[ list.Name ] = nil
    table.wipe( cachedResults[ list.Name ] )
    table.wipe( cachedValues[ list.Name ] )
    return chosen_action, chosen_wait, chosen_clash, chosen_depth

end


-- Used to cache reusable criteria in an APL loop.
local criteria = {}

function Hekili:ProcessIterativeActionList( dispID, hookID, listID, slot, depth, action, clash )
    
    local display = self.DB.profile.displays[ dispID ]
    local list = self.DB.profile.actionLists[ listID ]
    
    local debug = self.ActiveDebug
    
    -- if debug then self:Debug( "Testing action list [ %d - %s ].", listID, list and list.Name or "ERROR - Does Not Exist" ) end
    if debug then self:Debug( "WARNING:  We are using our linear-time engine instead of our predictive engine." ) end
    if debug then self:Debug( "Previous Recommendation: %s at +%.2fs, clash is %.2f.", action or "NO ACTION", wait or 60, clash or 0 ) end
    
    -- the stack will prevent list loops, but we need to keep this from destroying existing data... later.
    if not list then
        if debug then self:Debug( "No list with ID #%d. Should never see.", listID ) end
    elseif palStack[ list.Name ] then
        if debug then self:Debug( "Action list loop detected. %s was already processed earlier. Aborting.", list.Name ) end
        return 
    else
        if debug then self:Debug( "Adding %s to the list of processed action lists.", list.Name ) end
        palStack[ list.Name ] = true
    end
    
    local chosen_action = action
    local chosen_clash = clash or 0
    local chosen_depth = depth or 0
    
    local stop = false

    if chosen_depth == 0 then
        for k, v in pairs( criteria ) do
            v.known = nil
            v.ready = nil
            v.usable = nil
        end
    end

    
    if ns.visible.list[ listID ] then
        local actID = 1

        while actID <= #list.Actions and not chosen_action do
            if stop then
                if debug then self:Debug( "Returning to parent list after completing Run_Action_List ( %d - %s ).", listID, list.Name ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                return chosen_action, chosen_clash, chosen_depth
            end
            
            if ns.visible.action[ listID..':'..actID ] then
                
                -- Check for commands before checking actual actions.
                local entry = list.Actions[ actID ]
                state.this_action = entry.Ability
                state.this_args = entry.Args
                
                state.delay = nil
                chosen_depth = chosen_depth + 1
                
                criteria[ state.this_action ] = criteria[ state.this_action ] or {}
                local tests = criteria[ state.this_action ]
                
                -- Need to expand on modifiers, gather from other settings as needed.
                if debug then self:Debug( "\n[ %2d ] Testing entry %s:%d ( %s ) with modifiers ( %s ).", chosen_depth, list.Name, actID, entry.Ability, entry.Args or "NONE" ) end
                
                local ability = class.abilities[ entry.Ability ]

                local clash = 0
                
                if tests.known == nil then tests.known = isKnown( state.this_action ) end
                
                if debug then self:Debug( "%s is %s.", ability and ability.name or entry.Ability, tests.known and "KNOWN" or "NOT KNOWN" ) end
                
                if tests.known then
                    local scriptID = listID .. ':' .. actID
                    
                    importModifiers( listID, actID )

                    if tests.ready == nil then tests.ready = ns.isReadyNow( state.this_action ) end

                    if not tests.ready then
                        if debug then self:Debug( "This action is not ready at +%.2f. Skipping.", state.offset ) end
                    else
                        clash = clashOffset( state.this_action )

                        -- APL checks.
                        if entry.Ability == 'variable' then
                            -- local aScriptValue = checkScript( 'A', scriptID )
                            local varName = entry.ModVarName or state.args.name
                            
                            if debug then self:Debug( " - variable.%s will refer to this action's script.", varName or "MISSING" ) end
                            
                            if varName ~= nil then -- and aScriptValue ~= nil then
                                state.variable[ "_" .. varName ] = scriptID
                                -- We just store the scriptID so that the variable actually gets tested at time of comparison.
                            end

                        elseif entry.Ability == 'call_action_list' or entry.Ability == 'run_action_list' then
                            -- We handle these here to avoid early forking between starkly different APLs.
                            local aScriptPass = true
                            
                            if not entry.Script or entry.Script == '' then
                                if debug then self:Debug( "%s does not have any required conditions.", ability.name ) end
                                
                            else
                                aScriptPass = checkScript( 'A', scriptID )
                                if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                            end
                            
                            if aScriptPass then
                                
                                local aList = entry.ModName or state.args.name
                                
                                if aList then
                                    -- check to see if we have a real list name.
                                    local called_list = 0
                                    for i, list in ipairs( self.DB.profile.actionLists ) do
                                        if list.Name == aList then
                                            called_list = i
                                            break
                                        end
                                    end
                                    
                                    if called_list > 0 then
                                        if debug then self:Debug( "The action list for %s ( %s ) was found.", entry.Ability, aList ) end
                                        chosen_action, chosen_clash, chosen_depth = self:ProcessIterativeActionList( dispID, listID .. ':' .. actID , called_list, slot, chosen_depth, chosen_action, chosen_clash )
                                        stop = entry == 'run_action_list'
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end
                            
                        else
                            if tests.usable == nil then tests.usable = isUsable( state.this_action ) end
                            
                            if debug then self:Debug( "Ability ( %s ) is %s.", entry.Ability, usable and "USABLE" or "NOT USABLE" ) end
                            
                            if tests.usable then
                                if debug then
                                    self:Debug( "   REQUIRES: %d %s.", ability.spend or 0, ability.spend_type or "NONE" )
                                    local resource = ability.spend_type and state[ ability.spend_type ]
                                    if resource then self:Debug( "   PRESENT:  %d %s.", resource.current, ability.spend_type ) end
                                end
                                
                                local aScriptPass = true
                                
                                if not entry.Script or entry.Script == '' then 
                                    if debug then self:Debug( ' - this ability has no required conditions.' ) end
                                else 
                                    aScriptPass = checkScript( 'A', scriptID )
                                    if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                                end
                                
                                if aScriptPass then

                                    if entry.Ability == 'wait' then
                                        -- local args = ns.getModifiers( listID, actID )
                                        if not state.args.sec then state.args.sec = 1 end
                                        if state.args.sec > 0 then
                                            if debug then self:Debug( "Criteria for WAIT action were met, advancing by %.2f.", state.args.sec ) end
                                            -- NOTE, WE NEED TO TELL OUR INCREMENT FUNCTION ABOUT THIS...
                                            state.advance( state.args.sec )
                                            actID = 0
                                        end
                                        
                                    elseif entry.Ability == 'potion' then
                                        local potionName = state.args.ModName or state.args.name or class.potion
                                        local potion = class.potions[ potionName ]
                                        
                                        if potion then
                                            -- do potion things
                                            slot.scriptType = entry.ScriptType or 'simc'
                                            slot.display = dispID
                                            slot.button = i
                                            slot.item = nil
                                            
                                            slot.wait = state.delay
                                            
                                            slot.hook = hookID
                                            slot.list = listID
                                            slot.action = actID
                                            
                                            slot.actionName = state.this_action
                                            slot.listName = list.Name
                                            
                                            slot.resource = ns.resourceType( chosen_action )
                                            
                                            slot.caption = entry.Caption
                                            slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                            slot.texture = select( 10, GetItemInfo( potion.item ) )
                                            
                                            chosen_action = state.this_action
                                            chosen_clash = clash
                                            break
                                        end
                                        
                                    elseif entry.Ability == 'use_item' then
                                        local itemName = state.args.ModName or state.args.name
                                        local item = class.usable_items[ itemName ]
                                        
                                        if item then
                                            -- do item things
                                            slot.scriptType = entry.ScriptType or 'simc'
                                            slot.display = dispID
                                            slot.button = i
                                            slot.item = itemName
                                            
                                            slot.wait = state.delay
                                            
                                            slot.hook = hookID
                                            slot.list = listID
                                            slot.action = actID
                                            
                                            slot.actionName = state.this_action
                                            slot.listName = list.Name
                                            
                                            slot.resource = ns.resourceType( chosen_action )
                                            
                                            slot.caption = entry.Caption
                                            slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                            slot.texture = select( 10, GetItemInfo( item.item ) )
                                            
                                            chosen_action = state.this_action
                                            chosen_clash = clash
                                            break
                                        end
                                        
                                    else
                                        slot.scriptType = entry.ScriptType or 'simc'
                                        slot.display = dispID
                                        slot.button = i
                                        slot.item = nil
                                        
                                        slot.wait = state.delay
                                        
                                        slot.hook = hookID
                                        slot.list = listID
                                        slot.action = actID
                                        
                                        slot.actionName = state.this_action
                                        slot.listName = list.Name
                                        
                                        slot.resource = ns.resourceType( chosen_action )
                                        
                                        slot.caption = entry.Caption
                                        slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                        slot.texture = ability.texture
                                        
                                        chosen_action = state.this_action
                                        chosen_clash = clash

                                        if debug then
                                            self:Debug( "Action Chosen: %s at %f!", chosen_action, state.offset )
                                        end

                                        if entry.CycleTargets and state.active_enemies > 1 and ability and ability.cycle then
                                            if state.dot[ ability.cycle ].up and state.active_dot[ ability.cycle ] < ( state.args.MaxTargets or state.active_enemies ) then
                                                slot.indicator = 'cycle'
                                            end
                                        end
                                        
                                        break
                                    end
                                    
                                end
                            end
                            
                            state.delay = 0
                            
                        end
                    end
                end
            end
            
            actID = actID + 1
            
        end
        
    end

    palStack[ list.Name ] = nil
    return chosen_action, chosen_clash, chosen_depth

end


function Hekili:ProcessPredictiveHooks( dispID, solo )
    
    if not self.DB.profile.Enabled then return end
    
    if not self.Pause then
        local display = self.DB.profile.displays[ dispID ]
        
        ns.queue[ dispID ] = ns.queue[ dispID ] or {}
        local Queue = ns.queue[ dispID ]
        
        if display and ns.visible.display[ dispID ] then
            
            state.reset( dispID )
            
            local debug = self.ActiveDebug
            
            if debug then self:SetupDebug( display.Name ) end
            
            for k in pairs( palStack ) do palStack[k] = nil end
            
            if Queue then
                for k, v in pairs( Queue ) do
                    for l, w in pairs( v ) do
                        if type( Queue[ k ][ l ] ) ~= 'table' then
                            Queue[k][l] = nil
                        end
                    end
                end
            end
            
            local dScriptPass = true -- checkScript( 'D', dispID )
            
            if debug then self:Debug( "*** START OF NEW DISPLAY ***\n" ..
                "Display %d (%s) is %s.", dispID, display.Name, ( self.Config or dScriptPass ) and "VISIBLE" or "NOT VISIBLE" ) end
            
            -- if debug then self:Debug( "Conditions %s: %s", dScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'D', dispID ) ) end
            
            if ( self.Config or dScriptPass ) then
                
                for i = 1, ( display.numIcons or 4 ) do
                    
                    local chosen_action
                    local chosen_wait, chosen_clash, chosen_depth = 60, self.DB.profile.Clash or 0, 0
                    
                    Queue[i] = Queue[i] or {}
                    
                    local slot = Queue[i]
                    
                    local attempts = 0
                    
                    if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( time offset: %.2f ).", i, state.offset ) end
                    
                    for k in pairs( state.variable ) do
                        state.variable[ k ] = nil
                    end
                    
                    if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
                        -- We have a precombat display and combat hasn't started.
                        local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
                        
                        if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:ProcessPredictiveActionList( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                        if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                    end
                    
                    if display.defaultAPL and display.defaultAPL > 0 and chosen_wait > 0 then
                        local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
                        
                        if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
                        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:ProcessPredictiveActionList( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                        if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
                    end
                    
                    if debug then self:Debug( "Recommendation #%d is %s at %.2f.", i, chosen_action or "NO ACTION", state.offset + chosen_wait ) end
                    
                    -- Wipe out the delay, as we're advancing to the cast time.
                    state.delay = 0
                    
                    if chosen_action then
                        -- We have our actual action, so let's get the script values if we're debugging.
                        
                        if self.ActiveDebug then ns.implantDebugData( slot ) end
                        
                        slot.time = state.offset + chosen_wait
                        slot.exact_time = state.now + state.offset + chosen_wait
                        slot.since = i > 1 and slot.time - Queue[ i - 1 ].time or 0
                        slot.resources = slot.resources or {}
                        slot.depth = chosen_depth
                        
                        for k,v in pairs( class.resources ) do
                            slot.resources[ k ] = state[ k ].current 
                            if state[ k ].regen ~= 0 then slot.resources[ k ] = min( state[ k ].max, slot.resources[ k ] + ( state[ k ].regen * chosen_wait ) ) end
                        end
                        
                        slot.resource_type = ns.resourceType( chosen_action )
                        
                        if i < display.numIcons then
                            
                            -- Advance through the wait time.
                            state.advance( chosen_wait )
                            
                            local action = class.abilities[ chosen_action ]
                            
                            -- Start the GCD.
                            if action.gcdType ~= 'off' and state.cooldown.global_cooldown.remains == 0 then
                                state.setCooldown( 'global_cooldown', state.gcd )
                            end
                            
                            -- Advance the clock by cast_time.
                            if action.cast > 0 and not action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Put the action on cooldown. (It's slightly premature, but addresses CD resets like Echo of the Elements.)
                            if class.abilities[ chosen_action ].charges and action.recharge > 0 then
                                state.spendCharges( chosen_action, 1 )
                            elseif chosen_action ~= 'global_cooldown' then
                                state.setCooldown( chosen_action, action.cooldown )
                            end
                            
                            state.cycle = slot.indicator == 'cycle'
                            
                            -- Spend resources.
                            ns.spendResources( chosen_action )
                            
                            -- Perform the action.
                            ns.runHandler( chosen_action )

                            -- Complete the channel.
                            if action.cast > 0 and action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Move the clock forward if the GCD hasn't expired.
                            if state.cooldown.global_cooldown.remains > 0 then
                                state.advance( state.cooldown.global_cooldown.remains )
                            end

                            -- state.cooldown.use_item.start = nil
                            -- state.cooldown.use_item.duration = nil
                        end
                        
                    else
                        for n = i, display.numIcons do
                            slot[n] = nil
                        end
                        break
                    end
                    
                end
                
            end
            
        end
        
    end
    
    ns.displayUpdates[ dispID ] = GetTime()
    updatedDisplays[ dispID ] = 0
    
end


local criteriaCheck = {}

function Hekili:ProcessIterativeHooks( dispID, solo )
    
    if not self.DB.profile.Enabled then return end
    
    if not self.Pause then
        local display = self.DB.profile.displays[ dispID ]
        
        ns.queue[ dispID ] = ns.queue[ dispID ] or {}
        local Queue = ns.queue[ dispID ]
        
        if display and ns.visible.display[ dispID ] then
            
            state.reset( dispID )
            
            local debug = self.ActiveDebug
            
            if debug then self:SetupDebug( display.Name ) end
            
            for k in pairs( palStack ) do palStack[k] = nil end
            
            if Queue then
                for k, v in pairs( Queue ) do
                    for l, w in pairs( v ) do
                        if type( Queue[ k ][ l ] ) ~= 'table' then
                            Queue[k][l] = nil
                        end
                    end
                end
            end
            
            local dScriptPass = true -- checkScript( 'D', dispID )
            
            if debug then self:Debug( "*** START OF NEW DISPLAY ***\n" ..
                "Using linear-time system.\n" ..
                "Display %d (%s) is %s.", dispID, display.Name, ( self.Config or dScriptPass ) and "VISIBLE" or "NOT VISIBLE" ) end
            
            -- if debug then self:Debug( "Conditions %s: %s", dScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'D', dispID ) ) end
            
            if ( self.Config or dScriptPass ) then

                if not ( ( display.precombatAPL and display.precombatAPL > 0 and state.time == 0 ) or ( display.defaultAPL and display.defaultAPL > 0 ) ) then

                    if debug then self:Debug( "There are no available APLs attached to this display." ) end

                    for n = 1, ( display.numIcons or 4 ) do
                        Queue[ i ][ n ] = nil
                    end
                    return

                end

                for i = 1, ( display.numIcons or 4 ) do
                    
                    local chosen_action
                    local chosen_clash, chosen_depth = self.DB.profile.Clash or 0, 0
                    local chosen_wait
                    
                    Queue[i] = Queue[i] or {}
                    
                    local slot = Queue[i]
                    
                    local attempts = 0
                    
                    if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( initial time offset: %.2f ).", i, state.offset ) end
                    
                    for k in pairs( state.variable ) do
                        state.variable[ k ] = nil
                    end
                    
                    local iteration = 0

                    local startOffset = state.offset

                    while( chosen_action == nil and iteration <= 4 ) do
                        
                        local delay = 0
                        local step = 0.334

                        if iteration > 0 then
                            state.advance( step )
                            delay = state.offset - startOffset
                        end
                        if debug then self:Debug( "Iteration %d; additional time offset is %.2f; offset is %.2f.", iteration, delay, state.offset ) end

                        if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
                            -- We have a precombat display and combat hasn't started.
                            local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
                            
                            if debug then self:Debug( "Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end

                            chosen_action, chosen_clash, chosen_depth = self:ProcessIterativeActionList( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action, chosen_clash )
                            
                            if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                        
                        end

                        if not chosen_action and display.defaultAPL and display.defaultAPL > 0 then
                            local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
                            
                            if debug then self:Debug("Processing default action list [ %d - %s ].", display.default, listName ) end

                            chosen_action, chosen_clash, chosen_depth = self:ProcessIterativeActionList( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action, chosen_clash )
                            
                            if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.defaultAPL, listName ) end
                        end
                    
                        if debug then
                            if chosen_action then
                                self:Debug( "Recommendation #%d is %s at %.2f ( %.2f ).", i, chosen_action or "NO ACTION", state.offset, delay )
                                break
                            else
                                self:Debug( "No recommendation for slot #%d at %.2f ( %.2f ).", i, state.offset, delay )
                            end
                        end

                        iteration = iteration + 1    

                    end

                    -- The iteration engine failed, so either there was a bug or you're waiting 4+ seconds before your next ability.
                    if not chosen_action then
                        chosen_wait = 60

                        if debug then self:Debug( "WARNING:  No action found w/in 4 seconds by the iterative engine; falling back on projection." ) end

                        if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
                            -- We have a precombat display and combat hasn't started.
                            local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
                            
                            if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                            chosen_action, chosen_wait, chosen_clash, chosen_depth = self:ProcessPredictiveActionList( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                            if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                        end
                        
                        if display.defaultAPL and display.defaultAPL > 0 and chosen_wait > 0 then
                            local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
                            
                            if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
                            chosen_action, chosen_wait, chosen_clash, chosen_depth = self:ProcessPredictiveActionList( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                            if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
                        end
                    
                    end

                    if chosen_action then
                        if debug then ns.implantDebugData( slot ) end
                            
                        chosen_wait = chosen_wait or 0

                        slot.time = state.offset + chosen_wait
                        slot.exact_time = state.now + state.offset + chosen_wait
                        slot.since = ( i > 1 and Queue[ i - 1 ].time ) and ( slot.time - Queue[ i - 1 ].time ) or 0
                        slot.depth = chosen_depth

                        slot.resources = slot.resources or {}

                        for k,v in pairs( class.resources ) do
                            slot.resources[ k ] = state[ k ].current 
                        end
                        
                        slot.resource_type = ns.resourceType( chosen_action )
                        
                        if i < display.numIcons then
                            
                            -- Advance through the wait time.
                            if chosen_wait > 0 then state.advance( chosen_wait ) end
                            
                            local action = class.abilities[ chosen_action ]
                            
                            -- Start the GCD.
                            if action.gcdType ~= 'off' and state.cooldown.global_cooldown.remains == 0 then
                                state.setCooldown( 'global_cooldown', state.gcd )
                            end
                            
                            -- Advance the clock by cast_time.
                            if action.cast > 0 and not action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Put the action on cooldown. (It's slightly premature, but addresses CD resets like Echo of the Elements.)
                            if class.abilities[ chosen_action ].charges and action.recharge > 0 then
                                state.spendCharges( chosen_action, 1 )
                            elseif chosen_action ~= 'global_cooldown' then
                                state.setCooldown( chosen_action, action.cooldown )
                            end
                            
                            state.cycle = slot.indicator == 'cycle'
                            
                            -- Spend resources.
                            ns.spendResources( chosen_action )
                            
                            -- Perform the action.
                            ns.runHandler( chosen_action )

                            -- Advance the clock by cast_time.
                            if action.cast > 0 and action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Move the clock forward if the GCD hasn't expired.
                            if state.cooldown.global_cooldown.remains > 0 then
                                state.advance( state.cooldown.global_cooldown.remains )
                            end

                            -- state.cooldown.use_item.start = nil
                            -- state.cooldown.use_item.duration = nil
                        end
                    
                    else
                        for n = i, ( display.numIcons or 4 ) do
                            slot[n] = nil
                        end
                        break
                    end


                end

            end
            
        end
        
    end
    
    ns.displayUpdates[ dispID ] = GetTime()
    updatedDisplays[ dispID ] = 0
    
end


function Hekili:ProcessActionList( dispID, hookID, listID, slot, depth, action )
    
    local display = self.DB.profile.displays[ dispID ]
    local list = self.DB.profile.actionLists[ listID ]
    
    local debug = self.ActiveDebug
    
    -- if debug then self:Debug( "Testing action list [ %d - %s ].", listID, list and list.Name or "ERROR - Does Not Exist" ) end
    if debug then self:Debug( "WARNING:  We are using our timeline engine instead of our predictive engine." ) end
    -- if debug then self:Debug( "Previous Recommendation: %s at +%.2fs, clash is %.2f.", action or "NO ACTION", wait or 60, clash or 0 ) end
    
    -- the stack will prevent list loops, but we need to keep this from destroying existing data... later.
    if not list then
        if debug then self:Debug( "No list with ID #%d. Should never see.", listID ) end
    elseif palStack[ list.Name ] then
        if debug then self:Debug( "Action list loop detected. %s was already processed earlier. Aborting.", list.Name ) end
        return 
    else
        if debug then self:Debug( "Adding %s to the list of processed action lists.", list.Name ) end
        palStack[ list.Name ] = true
    end
    
    local chosen_action = action
    local chosen_clash = clash or 0
    local chosen_depth = depth or 0
    
    local stop = false

    if chosen_depth == 0 then
        for k, v in pairs( criteria ) do
            v.known = nil
            v.ready = nil
            v.usable = nil
        end
    end
    
    if ns.visible.list[ listID ] then
        local actID = 1

        while actID <= #list.Actions and not chosen_action do
            if stop then
                if debug then self:Debug( "Returning to parent list after completing Run_Action_List ( %d - %s ).", listID, list.Name ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end
                palStack[ list.Name ] = nil
                return chosen_action, chosen_clash, chosen_depth
            end
            
            if ns.visible.action[ listID..':'..actID ] then
                
                -- Check for commands before checking actual actions.
                local entry = list.Actions[ actID ]
                state.this_action = entry.Ability
                state.this_args = entry.Args
                
                chosen_depth = chosen_depth + 1
                
                -- Need to expand on modifiers, gather from other settings as needed.
                if debug then self:Debug( "\n[ %2d ] Testing entry %s:%d ( %s ) with modifiers ( %s ).", chosen_depth, list.Name, actID, entry.Ability, entry.Args or "NONE" ) end
                
                local ability = class.abilities[ entry.Ability ]

                local clash = 0
                
                local known = isKnown( state.this_action )
                
                if debug then self:Debug( "%s is %s.", ability and ability.name or entry.Ability, known and "KNOWN" or "NOT KNOWN" ) end
                
                if known then
                    local scriptID = listID .. ':' .. actID
                    
                    importModifiers( listID, actID )

                    local ready = ns.isReadyNow( state.this_action )

                    if not ready then
                        if debug then self:Debug( "This action is not ready at +%.2f (+%.2f). Skipping.", state.offset, state.delay ) end
                    else
                        clash = clashOffset( state.this_action )

                        -- APL checks.
                        if entry.Ability == 'variable' then
                            -- local aScriptValue = checkScript( 'A', scriptID )
                            local varName = entry.ModVarName or state.args.name
                            
                            if debug then self:Debug( " - variable.%s will refer to this action's script.", varName or "MISSING" ) end
                            
                            if varName ~= nil then -- and aScriptValue ~= nil then
                                state.variable[ "_" .. varName ] = scriptID
                                -- We just store the scriptID so that the variable actually gets tested at time of comparison.
                            end
                            
                        elseif entry.Ability == 'use_items' then
                            -- We handle these here to avoid early forking between starkly different APLs.
                            local aScriptPass = true
                            
                            if not entry.Script or entry.Script == '' then
                                if debug then self:Debug( "%s does not have any required conditions.", ability.name ) end
                                
                            else
                                aScriptPass = checkScript( 'A', scriptID )
                                if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                            end
                            
                            if aScriptPass then
                                
                                local aList = "Usable Items"
                                
                                if aList then
                                    -- check to see if we have a real list name.
                                    local called_list = 0
                                    for i, list in ipairs( self.DB.profile.actionLists ) do
                                        if list.Name == aList then
                                            called_list = i
                                            break
                                        end
                                    end
                                    
                                    if called_list > 0 then
                                        if debug then self:Debug( "The action list for %s ( %s ) was found.", entry.Ability, aList ) end
                                        chosen_action, chosen_clash, chosen_depth = self:ProcessActionList( dispID, listID .. ':' .. actID , called_list, slot, chosen_depth, chosen_action, chosen_clash )
                                        stop = entry == 'run_action_list'
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end

                        elseif entry.Ability == 'call_action_list' or entry.Ability == 'run_action_list' then
                            -- We handle these here to avoid early forking between starkly different APLs.
                            local aScriptPass = true
                            
                            if not entry.Script or entry.Script == '' then
                                if debug then self:Debug( "%s does not have any required conditions.", ability.name ) end
                                
                            else
                                aScriptPass = checkScript( 'A', scriptID )
                                if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                            end
                            
                            if aScriptPass then
                                
                                local aList = entry.ModName or state.args.name
                                
                                if aList then
                                    -- check to see if we have a real list name.
                                    local called_list = 0
                                    for i, list in ipairs( self.DB.profile.actionLists ) do
                                        if list.Name == aList then
                                            called_list = i
                                            break
                                        end
                                    end
                                    
                                    if called_list > 0 then
                                        if debug then self:Debug( "The action list for %s ( %s ) was found.", entry.Ability, aList ) end
                                        chosen_action, chosen_clash, chosen_depth = self:ProcessActionList( dispID, listID .. ':' .. actID , called_list, slot, chosen_depth, chosen_action, chosen_clash )
                                        stop = entry == 'run_action_list'
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end
                            
                        else
                            usable = isUsable( state.this_action )
                            
                            if debug then self:Debug( "Ability ( %s ) is %s.", entry.Ability, usable and "USABLE" or "NOT USABLE" ) end
                            
                            if usable then
                                if debug then
                                    self:Debug( "   REQUIRES: %d %s.", ability.spend or 0, ability.spend_type or "NONE" )
                                    local resource = ability.spend_type and state[ ability.spend_type ]
                                    if resource then self:Debug( "   PRESENT:  %d %s.", resource.current, ability.spend_type ) end
                                end
                                
                                local aScriptPass = true
                                
                                if not entry.Script or entry.Script == '' then 
                                    if debug then self:Debug( ' - this ability has no required conditions.' ) end
                                else 
                                    aScriptPass = checkScript( 'A', scriptID )
                                    if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                                end
                                
                                if aScriptPass then

                                    if entry.Ability == 'wait' then
                                        -- local args = ns.getModifiers( listID, actID )
                                        if not state.args.sec then state.args.sec = 1 end
                                        if state.args.sec > 0 then
                                            if debug then self:Debug( "Criteria for WAIT action were met, advancing by %.2f.", state.args.sec ) end
                                            -- NOTE, WE NEED TO TELL OUR INCREMENT FUNCTION ABOUT THIS...
                                            state.advance( state.args.sec )
                                            actID = 0
                                        end
                                        
                                    elseif entry.Ability == 'potion' then
                                        local potionName = state.args.ModName or state.args.name or class.potion
                                        local potion = class.potions[ potionName ]
                                        
                                        if potion then
                                            -- do potion things
                                            slot.scriptType = entry.ScriptType or 'simc'
                                            slot.display = dispID
                                            slot.button = i
                                            slot.item = nil
                                            
                                            slot.wait = state.delay
                                            
                                            slot.hook = hookID
                                            slot.list = listID
                                            slot.action = actID
                                            
                                            slot.actionName = state.this_action
                                            slot.listName = list.Name
                                            
                                            slot.resource = ns.resourceType( chosen_action )
                                            
                                            slot.caption = entry.Caption
                                            slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                            slot.texture = select( 10, GetItemInfo( potion.item ) )
                                            
                                            chosen_action = state.this_action
                                            chosen_clash = clash
                                            break
                                        end
                                        
                                    elseif entry.Ability == 'use_item' then
                                        local itemName = state.args.ModName or state.args.name
                                        local item = class.usable_items[ itemName ]
                                        
                                        if item then
                                            -- do item things
                                            slot.scriptType = entry.ScriptType or 'simc'
                                            slot.display = dispID
                                            slot.button = i
                                            slot.item = itemName
                                            
                                            slot.wait = state.delay
                                            
                                            slot.hook = hookID
                                            slot.list = listID
                                            slot.action = actID
                                            
                                            slot.actionName = state.this_action
                                            slot.listName = list.Name
                                            
                                            slot.resource = ns.resourceType( chosen_action )
                                            
                                            slot.caption = entry.Caption
                                            slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                            slot.texture = select( 10, GetItemInfo( item.item ) )
                                            
                                            chosen_action = state.this_action
                                            chosen_clash = clash
                                            break
                                        end
                                        
                                    else
                                        slot.scriptType = entry.ScriptType or 'simc'
                                        slot.display = dispID
                                        slot.button = i
                                        slot.item = nil
                                        
                                        slot.wait = state.delay
                                        
                                        slot.hook = hookID
                                        slot.list = listID
                                        slot.action = actID
                                        
                                        slot.actionName = state.this_action
                                        slot.listName = list.Name
                                        
                                        slot.resource = ns.resourceType( chosen_action )
                                        
                                        slot.caption = entry.Caption
                                        slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                        slot.texture = ability.texture
                                        
                                        chosen_action = state.this_action
                                        chosen_clash = clash

                                        if debug then
                                            self:Debug( "Action Chosen: %s at %f!", chosen_action, state.offset )
                                        end

                                        if entry.CycleTargets and state.active_enemies > 1 and ability and ability.cycle then
                                            if state.dot[ ability.cycle ].up and state.active_dot[ ability.cycle ] < ( state.args.MaxTargets or state.active_enemies ) then
                                                slot.indicator = 'cycle'
                                            end
                                        end
                                        
                                        break
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
            
            actID = actID + 1
            
        end
        
    end

    palStack[ list.Name ] = nil
    return chosen_action, chosen_clash, chosen_depth

end


--[[ function Hekili:ProcessHooks( dispID, solo )
    
    if not self.DB.profile.Enabled then return end
    
    if not self.Pause then
        local display = self.DB.profile.displays[ dispID ]
        
        ns.queue[ dispID ] = ns.queue[ dispID ] or {}
        local Queue = ns.queue[ dispID ]
        
        if display and ns.visible.display[ dispID ] then
            
            state.reset( dispID )
            
            local debug = self.ActiveDebug
            
            if debug then self:SetupDebug( display.Name ) end
            
            for k in pairs( palStack ) do palStack[k] = nil end
            
            if Queue then
                for k, v in pairs( Queue ) do
                    for l, w in pairs( v ) do
                        if type( Queue[ k ][ l ] ) ~= 'table' then
                            Queue[k][l] = nil
                        end
                    end
                end
            end
            
            local dScriptPass = true -- checkScript( 'D', dispID )
            
            if debug then self:Debug( "*** START OF NEW DISPLAY ***\n" ..
                "Display %d (%s) is %s.", dispID, display.Name, ( self.Config or dScriptPass ) and "VISIBLE" or "NOT VISIBLE" ) end
            
            -- if debug then self:Debug( "Conditions %s: %s", dScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'D', dispID ) ) end

            local gcd_length = max( 0.75, 1.5 * state.haste )
            
            if ( self.Config or dScriptPass ) then
                
                for i = 1, ( display.numIcons or 4 ) do
                    
                    local chosen_action
                    local chosen_depth = 0
                    
                    Queue[i] = Queue[i] or {}
                    
                    local slot = Queue[i]
                    
                    local attempts = 0
                    
                    if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( time offset: %.2f ).", i, state.offset ) end
                    
                    for k in pairs( state.variable ) do
                        state.variable[ k ] = nil
                    end

                    state.delay = 0
                    local iterations = 1

                    while ( not chosen_action ) do
                        if debug then self:Debug( "Iteration #%d at +%.2fs.", iterations, state.delay )
                            for k, v in pairs( class.resources ) do
                                self:Debug( " - %s: %.2f", k, state[ k ].current )
                            end
                        end

                        if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
                            -- We have a precombat display and combat hasn't started.
                            local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
                            
                            if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                            chosen_action, chosen_depth = self:ProcessActionList( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action )
                            if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                        end
                        
                        if display.defaultAPL and display.defaultAPL > 0 then
                            local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
                            
                            if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
                            chosen_action, chosen_depth = self:ProcessActionList( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action )
                            if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
                        end

                        if not chosen_action then
                            if state.cooldown.global_cooldown.remains > 0 then
                                state.delay = state.delay + min( state.cooldown.global_cooldown.remains, gcd_length / 3 )
                            else
                                state.delay = state.delay + ( gcd_length / 3 )
                            end
                            iterations = iterations + 1
                        end

                        if iterations > 26 then
                            -- Hekili:Print( format( "Reached iteration cap, [%d] %0.2f!", iterations, state.delay ) )
                            -- if not debug then DevTools_Dump( Queue )
                            -- self:TogglePause() end
                            break
                        end
                    end
                    
                    if debug then self:Debug( "Recommendation #%d is %s at %.2f.", i, chosen_action or "NO ACTION", state.offset + state.delay ) end
                    
                    if chosen_action then
                        -- We have our actual action, so let's get the script values if we're debugging.
                        
                        if debug then ns.implantDebugData( slot ) end
                        
                        slot.time = state.offset + state.delay
                        slot.exact_time = state.now + state.offset + state.delay
                        slot.since = i > 1 and slot.time - Queue[ i - 1 ].time or 0
                        slot.resources = slot.resources or {}
                        slot.depth = chosen_depth
                        
                        slot.resource_type = ns.resourceType( chosen_action )
                        
                        if i < display.numIcons then
                            
                            -- Advance through the wait time.
                            state.advance( state.delay )

                            for k,v in pairs( class.resources ) do
                                slot.resources[ k ] = state[ k ].current 
                            end                            
                            
                            local action = class.abilities[ chosen_action ]
                            
                            -- Start the GCD.
                            if action.gcdType ~= 'off' and state.cooldown.global_cooldown.remains == 0 then
                                state.setCooldown( 'global_cooldown', state.gcd )
                            end
                            
                            -- Advance the clock by cast_time.
                            if action.cast > 0 and not action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Put the action on cooldown. (It's slightly premature, but addresses CD resets like Echo of the Elements.)
                            if class.abilities[ chosen_action ].charges and action.recharge > 0 then
                                state.spendCharges( chosen_action, 1 )
                            elseif chosen_action ~= 'global_cooldown' then
                                state.setCooldown( chosen_action, action.cooldown )
                            end
                            
                            state.cycle = slot.indicator == 'cycle'
                            
                            -- Spend resources.
                            ns.spendResources( chosen_action )
                            
                            -- Perform the action.
                            ns.runHandler( chosen_action )

                            -- Complete the channel.
                            if action.cast > 0 and action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Move the clock forward if the GCD hasn't expired.
                            if state.cooldown.global_cooldown.remains > 0 then
                                state.advance( state.cooldown.global_cooldown.remains )
                            end
                        end
                        
                    else
                        for n = i, display.numIcons do
                            slot[n] = nil
                        end
                        break
                    end
                    
                end
                
            end
            
        end
        
    end
    
    ns.displayUpdates[ dispID ] = GetTime()
    updatedDisplays[ dispID ] = 0
    
end]] 



function Hekili:GetNextPrediction( dispID, slot )
    
    local debug = false
    
    for k in pairs( palStack ) do palStack[k] = nil end

    local display = self.DB.profile.displays[ dispID ]

    local dScriptPass = true
    
    local chosen_action
    local chosen_wait, chosen_clash, chosen_depth = 60, self.DB.profile.Clash or 0, 0

    if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( time offset: %.2f ).", i, state.offset ) end
    
    for k in pairs( state.variable ) do
        state.variable[ k ] = nil
    end
    
    if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
        -- We have a precombat display and combat hasn't started.
        local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
        
        if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
        if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
    end
    
    if display.defaultAPL and display.defaultAPL > 0 and chosen_wait > 0 then
        local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
        
        if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
        if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
    end
    
    if debug then self:Debug( "Recommendation #%d is %s at %.2f.", i, chosen_action or "NO ACTION", state.offset + chosen_wait ) end
    
    -- Wipe out the delay, as we're advancing to the cast time.
    state.delay = 0

    return chosen_action, chosen_wait, chosen_clash, chosen_depth

end


local pvpZones = {
    arena = true,
    pvp = true
}


local function CheckDisplayCriteria( dispID )
    
    local display = Hekili.DB.profile.displays[ dispID ]
    local switch, mode = Hekili.DB.profile['Switch Type'], Hekili.DB.profile['Mode Status']
    local _, zoneType = IsInInstance()
    
    -- if C_PetBattles.IsInBattle() or Hekili.Barber or UnitInVehicle( 'player' ) or not ns.visible.display[ dispID ] then
    if C_PetBattles.IsInBattle() or UnitOnTaxi( 'player' ) or Hekili.Barber or HasVehicleActionBar() or not ns.visible.display[ dispID ] then
        return 0
        
    elseif ( switch == 0 and not display.showSwitchAuto ) or ( switch == 1 and not display.showSwitchAE ) or ( mode == 0 and not display.showST ) or ( mode == 3 and not display.showAuto ) or ( mode == 2 and not display.showAE ) then
        return 0
        
    elseif not pvpZones[ zoneType ] then
        
        if display.visibilityType == 'a' then
            return display.alphaShowPvE
            
        else
            if display.targetPvE and UnitExists( 'target' ) and not ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
                return display.alphaTargetPvE
                
            elseif display.combatPvE and UnitAffectingCombat( 'player' ) then
                return display.alphaCombatPvE
                
            elseif display.alwaysPvE then
                return display.alphaAlwaysPvE
                
            end
        end
        
        return 0
        
    elseif pvpZones[ zoneType ] then
        
        if display.visibilityType == 'a' then
            return display.alphaShowPvP
            
        else
            if display.targetPvP and UnitExists( 'target' ) and not ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
                return display.alphaTargetPvP
                
            elseif display.combatPvP and UnitAffectingCombat( 'player' ) then
                return display.alphaCombatPvP
                
            elseif display.alwaysPvP then
                return display.alphaAlwaysPvP
                
            end
        end
        
        return 0
        
    elseif not Hekili.Config and not ns.queue[ dispID ] then
        return 0
        
    end

    return 0
    
end
ns.CheckDisplayCriteria = CheckDisplayCriteria


local tSlot = {}
local iterationSteps = {}

function Hekili:ProcessHooks( dispID, solo )

    if not self.DB.profile.Enabled then return end
    
    if not self.Pause then
        local display = self.DB.profile.displays[ dispID ]
        
        ns.queue[ dispID ] = ns.queue[ dispID ] or {}
        local Queue = ns.queue[ dispID ]
        
        if display and ns.visible.display[ dispID ] then
            
            state.reset( dispID )
            
            for k in pairs( palStack ) do palStack[k] = nil end
            
            if Queue then
                for k, v in pairs( Queue ) do
                    for l, w in pairs( v ) do
                        if type( Queue[ k ][ l ] ) ~= 'table' then
                            Queue[k][l] = nil
                        end
                    end
                end
            end
            
            local dScriptPass = CheckDisplayCriteria( dispID ) or 0 -- checkScript( 'D', dispID )
            
            if debug then self:Debug( "*** START OF NEW DISPLAY ***\n" ..
                "Display %d (%s) is %s.", dispID, display.Name, ( self.Config or dScriptPass > 0 ) and "VISIBLE" or "NOT VISIBLE" ) end
            
            -- if debug then self:Debug( "Conditions %s: %s", dScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'D', dispID ) ) end

            
            if ( self.Config or dScriptPass > 0 ) then
                
                local debug = self.ActiveDebug
                
                if debug then self:SetupDebug( display.Name ) end

                local gcd_length = rawget( state, 'gcd' ) or max( 0.75, 1.5 * state.haste )
                
                for i = 1, ( display.numIcons or 4 ) do
                    
                    local chosen_action
                    local chosen_depth = 0
                    
                    Queue[i] = Queue[i] or {}
                    
                    local slot = Queue[i]
                    
                    local attempts = 0
                    local iterated = false
                    
                    if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( time offset: %.2f ).", i, state.offset ) end
                    
                    for k in pairs( state.variable ) do
                        state.variable[ k ] = nil
                    end

                    if debug then
                        for k in pairs( class.resources ) do
                            self:Debug( "[ ** ] %s %d/%d", k, state[ k ].current, state[ k ].max )
                        end
                    end


                    state.delay = 0

                    local predicted_action, predicted_wait, predicted_clash, predicted_depth = self:GetNextPrediction( dispID, slot )

                    if debug then self:Debug( "Prediction engine would recommend %s at +%.2fs.\n", predicted_action or "NO ACTION", predicted_wait or 60 ) end

                    local gcd_remains = state.cooldown.global_cooldown.remains

                    if predicted_action and predicted_wait <= gcd_remains then
                        if debug then self:Debug( "The prediction engine's recommendation [ %s @ %.2f ] is available within the remaining global cooldown (+%.2f).  Using this recommendation.", predicted_action, predicted_wait, gcd_remains ) end
                        chosen_action, state.delay, chosen_clash, chosen_depth = predicted_action, predicted_wait, predicted_clash, predicted_depth
                    
                    else
                        table.wipe( iterationSteps )

                        local time_remains = predicted_wait
                        local step = 0

                        if gcd_remains > 0 then
                            table.insert( iterationSteps, gcd_remains )
                            time_remains = time_remains - gcd_remains
                        end

                        for j = 1, 3 do
                            if time_remains == 0 then break end

                            local nextStep = gcd_length / ( j < 3 and 2 or 1 )

                            if time_remains < nextStep then break end

                            table.insert( iterationSteps, nextStep )
                            time_remains = time_remains - nextStep
                        end

                        iterated = true

                        -- Backup decision data from the prediction engine.
                        table.wipe( tSlot )
                        for k, v in pairs( slot ) do
                            tSlot[k] = v
                        end

                        state.delay = 0

                        -- Decide our steps.
                        local gcd = gcd_length
                        local progress = 0

                        for j, step in ipairs( iterationSteps ) do

                            state.advance( step )

                            if debug then self:Debug( "Iteration #%d at +%.2fs ( +%.2f ).", j, state.offset, step )
                                for k, v in pairs( class.resources ) do
                                    self:Debug( " - %s: %.2f", k, state[ k ].current )
                                end
                            end

                            if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
                                -- We have a precombat display and combat hasn't started.
                                local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
                                
                                if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                                chosen_action, chosen_depth = self:ProcessActionList( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action )
                                if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                            end
                            
                            if display.defaultAPL and display.defaultAPL > 0 then
                                local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
                                
                                if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
                                chosen_action, chosen_depth = self:ProcessActionList( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action )
                                if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
                            end

                            if chosen_action then
                                if debug then self:Debug( "Found recommendation for %s at %.2fs (iteration #%d).", chosen_action, state.offset, i ) end
                                break
                            end
                        end

                        if not chosen_action then
                            -- We didn't find an action w/in 2 GCDs (up to 4 iterations); just use the delayed prediction.
                            state.advance( time_remains )
                            chosen_action, state.delay, chosen_clash, chosen_depth = predicted_action, 0, predicted_clash, predicted_depth

                            if debug then self:Debug( "No better recommendation found within 2 GCDs; using the prediction engine's recommendation.\n" ..
                                "Selected action [ %s ] at +%.2fs.", chosen_action or "NO ACTION FOUND", state.offset ) end
                        end

                    end
                    
                    if debug then self:Debug( "Recommendation #%d is %s at %.2f.", i, chosen_action or "NO ACTION", state.offset + state.delay ) end
                    
                    if chosen_action then
                        if debug then ns.implantDebugData( slot ) end
                        
                        slot.time = state.offset + state.delay
                        slot.exact_time = state.now + state.offset + state.delay
                        slot.since = i > 1 and slot.time - Queue[ i - 1 ].time or 0
                        slot.resources = slot.resources or {}
                        slot.depth = chosen_depth
                        
                        slot.resource_type = ns.resourceType( chosen_action )

                        for k,v in pairs( class.resources ) do
                            slot.resources[ k ] = state[ k ].current 
                        end                            
                        
                        if i < display.numIcons then
                            
                            -- Advance through the wait time.
                            if state.delay > 0 then state.advance( state.delay ) end

                            local action = class.abilities[ chosen_action ]
                            
                            -- Start the GCD.
                            if action.gcdType ~= 'off' and state.cooldown.global_cooldown.remains == 0 then
                                state.setCooldown( 'global_cooldown', state.gcd )
                            end
                            
                            -- Advance the clock by cast_time.
                            if action.cast > 0 and not action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end

                            local cooldown = action.cooldown
                            
                            -- Put the action on cooldown. (It's slightly premature, but addresses CD resets like Echo of the Elements.)
                            if class.abilities[ chosen_action ].charges and action.recharge > 0 then
                                state.spendCharges( chosen_action, 1 )
                            elseif chosen_action ~= 'global_cooldown' then
                                state.setCooldown( chosen_action, cooldown )
                            end
                            
                            state.cycle = slot.indicator == 'cycle'
                            
                            -- Spend resources.
                            ns.spendResources( chosen_action )
                            
                            -- Perform the action.
                            ns.runHandler( chosen_action )

                            if action.item then
                                state.putTrinketsOnCD( cooldown / 6 )
                            end

                            -- Complete the channel.
                            if action.cast > 0 and action.channeled and not class.resetCastExclusions[ chosen_action ] then
                                state.advance( action.cast )
                            end
                            
                            -- Move the clock forward if the GCD hasn't expired.
                            if state.cooldown.global_cooldown.remains > 0 then
                                state.advance( state.cooldown.global_cooldown.remains )
                            end
                        end
                        
                    else
                        for n = i, display.numIcons do
                            slot[n] = nil
                        end
                        break
                    end
                    
                end
                
            end
            
        end
        
    end
    
    ns.displayUpdates[ dispID ] = GetTime()
    updatedDisplays[ dispID ] = 0
    
end


function Hekili_GetRecommendedAbility( display, entry )
    
    if type( display ) == 'string' then
        local found = false
        for dispID, disp in pairs(Hekili.DB.profile.displays) do
            if not found and disp.Name == display then
                display = dispID
                found = true
            end
        end
        if not found then return nil, "Display name not found." end
    end
    
    if not Hekili.DB.profile.displays[ display ] then
        return nil, "Display not found."
    end
    
    if not ns.queue[ display ] then
        return nil, "No queue for that display."
    end
    
    if not ns.queue[ display ][ entry ] then
        return nil, "No entry #" .. entry .. " for that display."
    end
    
    return class.abilities[ ns.queue[ display ][ entry ].actionName ].id
    
end



local flashes = {}
local checksums = {}
local applied = {}


function Hekili:UpdateDisplay( dispID )
    
    local self = self or Hekili
    
    if not self.DB.profile.Enabled then
        return
    end
    
    -- for dispID, display in pairs(self.DB.profile.displays) do
    local display = self.DB.profile.displays[ dispID ]
    
    if not ns.UI.Buttons or not ns.UI.Buttons[ dispID ] then return end
    
    if self.Pause then
        ns.UI.Buttons[ dispID ][1].Overlay:SetTexture('Interface\\Addons\\Hekili\\Textures\\Pause.blp')
        ns.UI.Buttons[ dispID ][1].Overlay:Show()
        
    else
        flashes[dispID] = flashes[dispID] or 0
        
        ns.UI.Buttons[ dispID ][1].Overlay:Hide()
        
        local alpha = CheckDisplayCriteria( dispID ) or 0

        if alpha > 0 then
            local Queue = ns.queue[ dispID ]
            
            local gcd_start, gcd_duration = GetSpellCooldown( class.abilities.global_cooldown.id )
            local now = GetTime()
            
            _G[ "HekiliDisplay" .. dispID ]:Show()
            
            for i, button in ipairs( ns.UI.Buttons[ dispID ] ) do
                if not Queue or not Queue[i] and ( self.DB.profile.Enabled or self.Config ) then
                    for n = i, display.numIcons do
                        ns.UI.Buttons[dispID][n].Texture:SetTexture( 'Interface\\ICONS\\Spell_Nature_BloodLust' )
                        ns.UI.Buttons[dispID][n].Texture:SetVertexColor(1, 1, 1)
                        ns.UI.Buttons[dispID][n].Caption:SetText(nil)
                        if not self.Config then
                            ns.UI.Buttons[dispID][n]:Hide()
                        else
                            ns.UI.Buttons[dispID][n]:Show()
                            ns.UI.Buttons[dispID][n]:SetAlpha(alpha)
                        end
                    end
                    break
                end
                
                local aKey, caption, indicator = Queue[i].actionName, Queue[i].caption, Queue[i].indicator
                local ability = aKey and class.abilities[ aKey ]
                
                if ability then
                    button:Show()
                    button:SetAlpha(alpha)
                    button.Texture:SetTexture( Queue[i].texture or ability.texture or GetSpellTexture( ability.id ) )
                    local zoom = ( display.iconZoom or 0 ) / 200
                    button.Texture:SetTexCoord( zoom, 1 - zoom, zoom, 1 - zoom )
                    button.Texture:Show()
                    
                    if display.showIndicators and indicator then
                        if indicator == 'cycle' then button.Icon:SetTexture( "Interface\\Addons\\Hekili\\Textures\\Cycle" ) end
                        if indicator == 'cancel' then button.Icon:SetTexture( "Interface\\Addons\\Hekili\\Textures\\Cancel" ) end
                        button.Icon:Show()
                    else
                        button.Icon:Hide()
                    end
                    
                    if display.showCaptions and ( i == 1 or display.queuedCaptions ) then
                        button.Caption:SetText( caption )
                    else
                        button.Caption:SetText( nil )
                    end
                    
                    if display.showKeybindings and ( display.queuedKBs or i == 1 ) then
                        button.Keybinding:SetText( self:GetBindingForAction( aKey, not display.lowercaseKBs == true ) )
                    else
                        button.Keybinding:SetText( nil )
                    end
                    
                    if display.showAuraInfo and i == 1 then
                        if type( display.auraSpellID ) == 'string' or display.auraSpellID > 0 then
                            local aura = class.auras[ display.auraSpellID ]
                            
                            if not aura then 
                                button.Auras:SetText(nil)
                            else
                                if display.auraInfoType == 'count' then
                                    local c = ns.numDebuffs( aura.name )
                                    button.Auras:SetText( c > 0 and c or "" )
                                    
                                elseif display.auraInfoType == 'buff' then
                                    local name, _, _, count = UnitBuff( display.auraUnit, aura.name, nil, display.auraMine and "PLAYER" or "" )
                                    if not name then button.Auras:SetText( nil )
                                else button.Auras:SetText( max( 1, count ) ) end
                                    
                                elseif display.auraInfoType == 'debuff' then
                                    local name, _, _, count = UnitDebuff( display.auraUnit, aura.name, nil, display.auraMine and "PLAYER" or "" )
                                    
                                    if not name then button.Auras:SetText( nil )
                                else button.Auras:SetText( max( 1, count ) ) end
                                    
                                elseif display.auraInfoType == 'buffRem' then
                                    local name, _, _, _, _, _, expires = UnitBuff( display.auraUnit, aura.name, nil, display.auraMine and "PLAYER" or "" )
                                    if not name then button.Auras:SetText( nil )
                                else button.Auras:SetText( format( "%.1f", expires - now ) ) end
                                    
                                elseif display.auraInfoType == 'debuffRem' then
                                    local name, _, _, _, _, _, expires = UnitDebuff( display.auraUnit, aura.name, nil, display.auraMine and "PLAYER" or "" )
                                    if not name then button.Auras:SetText( nil )
                                else button.Auras:SetText( format( "%.1f", expires - now ) ) end
                                    
                                end
                            end
                    else button.Auras:SetText( nil ) end
                    end
                    
                    if i == 1 then
                        if display.showTargets then
                            -- 0 = single
                            -- 2 = cleave
                            -- 2 = aoe
                            -- 3 = auto
                            local min_targets, max_targets = 0, 0
                            local mode = Hekili.DB.profile['Mode Status']
                            
                            if display.displayType == 'a' then -- Primary
                                if mode == 0 then
                                    min_targets = 0
                                    max_targets = 1
                                elseif mode == 2 then
                                    min_targets = display.simpleAOE or 2
                                    max_targets = 0
                                end
                                
                            elseif display.displayType == 'b' then -- Single-Target
                                min_targets = 0
                                max_targets = 1
                                
                            elseif display.displayType == 'c' then -- AOE
                                min_targets = display.simpleAOE or 2
                                max_targets = 0
                                
                            elseif display.displayType == 'd' then -- Auto
                                -- do nothing
                                
                            elseif display.displayType == 'z' then -- Custom, old style.
                                if mode == 0 then
                                    if display.minST > 0 then min_targets = display.minST end
                                    if display.maxST > 0 then max_targets = display.maxST end
                                elseif mode == 2 then
                                    if display.minAE > 0 then min_targets = display.minAE end
                                    if display.maxAE > 0 then max_targets = display.maxAE end
                                elseif mode == 3 then
                                    if display.minAuto > 0 then min_targets = display.minAuto end
                                    if display.maxAuto > 0 then max_targets = display.maxAuto end
                                end
                            end
                            
                            -- local detected = ns.getNameplateTargets()
                            -- if detected == -1 then detected = ns.numTargets() end
                            
                            local detected = max( 1, ns.getNumberTargets() )
                            local targets = detected
                            
                            if min_targets > 0 then targets = max( min_targets, targets ) end
                            if max_targets > 0 then targets = min( max_targets, targets ) end
                            
                            local targColor = ''
                            
                            if detected < targets then targColor = '|cFFFF0000'
                                elseif detected > targets then targColor = '|cFF00C0FF' end
                            
                            if targets > 1 then button.Targets:SetText( targColor .. targets .. '|r' )
                        else button.Targets:SetText( nil ) end
                        else
                            button.Targets:SetText( nil )
                        end
                    end
                    
                    if display.blizzGlow and ( i == 1 or display.queuedBlizzGlow ) and IsSpellOverlayed( ability.id ) then
                        ActionButton_ShowOverlayGlow( button )
                    else
                        ActionButton_HideOverlayGlow( button )
                    end
                    
                    local start, duration
                    if ability.item then
                        start, duration = GetItemCooldown( ability.item )
                    -- elseif not ability.cooldown or ability.cooldown == 0 then
                    --    start, duration = 0, 0
                    else
                        start, duration = GetSpellCooldown( ability.id )
                    end
                    local gcd_remains = gcd_start + gcd_duration - GetTime()
                    
                    if ability.gcdType ~= 'off' and ( not start or start == 0 or ( start + duration ) < ( gcd_start + gcd_duration ) ) then
                        start = gcd_start
                        duration = gcd_duration
                    end
                    
                    if i == 1 then
                        button.Cooldown:SetCooldown( start, duration )

                        local SF = SpellFlash or SpellFlashCore
                        
                        if SF and display.spellFlash and GetTime() >= flashes[dispID] + 0.2 then
                            SF.FlashAction( ability.id, display.spellFlashColor )
                            flashes[dispID] = GetTime()
                        end
                        
                        if ( class.file == 'HUNTER' or class.file == 'MONK' or class.file == 'DEATHKNIGHT' ) then
                            local exact = Queue[i].exact_time
                            local end_gcd = gcd_start + gcd_duration
                            local diff = abs( exact - end_gcd )

                            if Queue[i].exact_time > now and diff >= 0.1 then
                                local delay = Queue[ i ].exact_time - now
                                button.Delay:SetText( format( delay > 1 and "%d" or "%.1f", delay ) )
                            else
                                button.Delay:SetText( nil )
                            end

                        else
                            -- button.Texture:SetDesaturated( false )
                            button.Delay:SetText( nil )
                        end
                        
                    else
                        if start + duration ~= gcd_start + gcd_duration then
                            button.Cooldown:SetCooldown( start, duration )
                        else
                            if ability.gcdType ~= 'off' then
                                button.Cooldown:SetCooldown( gcd_start, gcd_duration )
                            else
                                button.Cooldown:SetCooldown( 0, 0 )
                            end
                        end
                    end
                    
                    if display.rangeType == 'melee' then
                        local RangeCheck = LibStub( "LibRangeCheck-2.0" )
                        local minR = RangeCheck:GetRange( 'target' )
                        
                        if minR and minR >= 5 then 
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 0, 0)
                        elseif i == 1 and select(2, IsUsableSpell( ability.id ) ) then
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(0.4, 0.4, 0.4)
                        else
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
                        end
                    elseif display.rangeType == 'ability' then
                        local rangeSpell = ability.range and GetSpellInfo( ability.range ) or ability.name

                        if ability.item then
                            if UnitExists( "target" ) and UnitCanAttack( "player", "target" ) and IsItemInRange( ability.item, "target" ) == false then
                                ns.UI.Buttons[ dispID ][ i ].Texture:SetVertexColor( 1, 0, 0 )
                            else
                                ns.UI.Buttons[ dispID ][ i ].Texture:SetVertexColor( 1, 1, 1 )
                            end

                        else
                            local SpellRange = LibStub( "SpellRange-1.0" )
                            if SpellRange.IsSpellInRange( rangeSpell, 'target' ) == 0 then
                                ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 0, 0)
                            elseif i == 1 and select(2, IsUsableSpell( ability.id )) then
                                ns.UI.Buttons[dispID][i].Texture:SetVertexColor(0.4, 0.4, 0.4)
                            else
                                ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
                            end
                        end

                    elseif display.rangeType == 'off' then
                        ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
                    end
                    
                else
                    
                    ns.UI.Buttons[dispID][i].Texture:SetTexture( nil )
                    ns.UI.Buttons[dispID][i].Cooldown:SetCooldown( 0, 0 )
                    ns.UI.Buttons[dispID][i]:Hide()
                    
                end
                
            end
            
        else
            
            for i, button in ipairs(ns.UI.Buttons[dispID]) do
                button:Hide()
                
            end
        end
    end
    
end


function Hekili:UpdateDisplays()
    local now = GetTime()
    
    for display, update in pairs( updatedDisplays ) do
        if now - update > 0.033 then
            Hekili:UpdateDisplay( display )
            updatedDisplays[ display ] = now
        end
    end
end
