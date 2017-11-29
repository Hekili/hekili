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


local listIsBad = {}    -- listIsBad uses scriptIDs for keys; all entries after these lists should be excluded if the script returned TRUE.

local listStack = {}    -- listStack for a given index returns the scriptID of its caller (or 0 if called by a display).
local listCache = {}    -- listCache is a table of return values for a given scriptID at various times.
local listValue = {}    -- listValue shows the cached values from the listCache.

local itemTried = {}    -- Items that are tested in a specialization APL aren't reused here.



function Hekili:CheckAPLStack()

    local t = state.query_time

    for scriptID, listID in pairs( listIsBad ) do
        local list = self.DB.profile.actionLists[ listID ]

        if listID and list then
            local cache = listCache[ scriptID ] or {}
            local values = listValue[ scriptID ] or {}

            cache[ t ] = cache[ t ] or checkScript( 'A', scriptID )
            values[ t ] = values[ t ] or ns.getConditionsAndValues( 'A', scriptID )

            if self.ActiveDebug then self:Debug( "The conditions for a previously-run action list ( %d - %s ) would %s at +%.2f.\n - %s", listID, list.Name, cache[ t ] and "PASS" or "FAIL", state.delay, values[ t ] ) end

            listCache[ scriptID ] = cache
            listValue[ scriptID ] = value

            if cache[ t ] then
                if self.ActiveDebug then self:Debug( "Action unavailable as we would not have reached this entry at +%.2f.", state.delay ) end
                return false
            end
        end
    end

    for listID, caller in pairs( listStack ) do
        local list = self.DB.profile.actionLists[ listID ]

        if caller and caller ~= 0 and list then
            local cache = listCache[ caller ] or {}
            local values = listValue[ caller ] or {}

            cache[ t ] = cache[ t ] or checkScript( 'A', caller )
            values[ t ] = values[ t ] or ns.getConditionsAndValues( 'A', caller )

            if self.ActiveDebug then self:Debug( "The conditions for %s (%d), called from %s, would %s at +%.2f.\n - %s", list.Name or "NONAME", listID, caller, cache[ t ] and "PASS" or "FAIL", state.delay, values[ t ] ) end

            listCache[ caller ] = cache
            listValue[ caller ] = values

            if not cache[ t ] then return false end
        end
    end

    return true
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
    elseif listStack[ listID ] then
        if debug then self:Debug( "Action list loop detected. %s was already processed earlier. Aborting.", list.Name ) end
        return 
    else
        if debug then self:Debug( "Adding %s to the list of processed action lists.", list.Name ) end
        listStack[ listID ] = hookID or 0
    end
    
    local chosen_action = action
    local chosen_clash = clash or 0
    local chosen_wait = wait or 60
    local chosen_depth = depth or 0
    
    local stop = false

    table.wipe( itemTried )
    
    if ns.visible.list[ listID ] then
        local actID = 1
        
        while actID <= #list.Actions do
            if chosen_wait <= state.cooldown.global_cooldown.remains then
                if debug then self:Debug( "The last selected ability ( %s ) is available by the next GCD.  End loop.", chosen_action ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end

                local scriptID = listStack[ listID ]
                listStack[ listID ] = nil
                if listCache[ scriptID ] then table.wipe( listCache[ scriptID ] ) end
                if listValue[ scriptID ] then table.wipe( listValue[ scriptID ] ) end

                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            elseif chosen_wait <= 0.2 then
                if debug then self:Debug( "The last selected ability ( %s ) has a very low wait time. End loop.", chosen_action ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end

                local scriptID = listStack[ listID ]
                listStack[ listID ] = nil
                if listCache[ scriptID ] then table.wipe( listCache[ scriptID ] ) end
                if listValue[ scriptID ] then table.wipe( listValue[ scriptID ] ) end

                return chosen_action, chosen_wait, chosen_clash, chosen_depth
            elseif stop then
                if debug then self:Debug( "Returning to parent list after completing Run_Action_List ( %d - %s ).", listID, list.Name ) end
                if debug then self:Debug( "Removing %s from list of processed action lists.", list.Name ) end

                local scriptID = listStack[ listID ]
                listStack[ listID ] = nil
                if listCache[ scriptID ] then table.wipe( listCache[ scriptID ] ) end
                if listValue[ scriptID ] then table.wipe( listValue[ scriptID ] ) end

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
                                --[[ if isTimeSensitive( 'A', scriptID ) then 
                                    -- aScriptPass = self:CheckAPLStack() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "Use Items's conditions will be tested along with each action in the item list." ) end
                                else
                                    aScriptPass = self:CheckAPLStack() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "The conditions for this entry are not time sensitive and %s at ( %.2f + %.2f ).", aScriptPass and "PASS" or "DO NOT PASS", state.offset, state.delay ) end
                                end ]]
                                aScriptPass = self:CheckAPLStack() and checkScript( 'A', scriptID )
                                if debug then self:Debug( "The conditions for this entry are %stime sensitive and %s at ( %.2f + %.2f ).", isTimeSensitive( 'A', scriptID ) and "" or "not ", aScriptPass and "PASS" or "DO NOT PASS", state.offset, state.delay ) end
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
                                --[[ if isTimeSensitive( 'A', scriptID ) and not entry.StrictCheck then 
                                    -- aScriptPass = self:CheckAPLStack() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "The action list's conditions will be tested along with each action." ) end
                                else
                                    aScriptPass = self:CheckAPLStack() and checkScript( 'A', scriptID )
                                    if debug then self:Debug( "Conditions %s: %s", aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                                    if debug then self:Debug( "The conditions for this action list are not time sensitive%s and %s at ( %.2f + %.2f ).", entry.StrictCheck and " (STRICT)" or "", aScriptPass and "PASS" or "DO NOT PASS", state.offset, state.delay ) end
                                end ]]
                                aScriptPass = self:CheckAPLStack() and checkScript( 'A', scriptID )

                                if debug then self:Debug( "The conditions for this entry are %stime sensitive and %s at ( %.2f + %.2f ).", isTimeSensitive( 'A', scriptID ) and "" or "not ", aScriptPass and "PASS" or "DO NOT PASS", state.offset, state.delay ) end
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

                                        local prev_action, prev_wait = chosen_action, chosen_wait

                                        chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, listID .. ':' .. actID, called_list, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
                                        if debug then self:Debug( "The action list ( %s ) returned with recommendation %s after %.2f seconds.", aList, chosen_action or "none", chosen_wait ) end

                                        if entry.Ability == 'run_action_list' then
                                            listIsBad[ scriptID ] = listID
                                        end
                                       
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end
                            
                        else
                            local usable = isUsable( state.this_action )

                            if debug then self:Debug( "Testing at [ %.2f + %.2f ] - Ability ( %s ) is %s.", state.offset, state.delay, entry.Ability, usable and "USABLE" or "NOT USABLE" ) end
                            
                            if ability.item then
                                if list.Name == "Usable Items" then
                                    if itemTried[ entry.Ability ] then
                                        usable = false
                                        if debug then self:Debug( "This ability is item-based and was previously tried by the specialization's APLs; skipping." ) end
                                    end
                                else
                                    itemTried[ entry.Ability ] = true
                                end
                            end
                            
                            if usable then
                                local chosenWaitValue = max( 0, chosen_wait - chosen_clash )
                                local readyFirst = state.delay < chosenWaitValue
                                
                                if debug then self:Debug( " - this ability is %s at %.2f before the previous ability at %.2f.", readyFirst and "READY" or "NOT READY", state.delay, chosenWaitValue ) end
                                
                                if readyFirst then
                                    local hasResources = true
                                    
                                    if hasResources then
                                        local aScriptPass = self:CheckAPLStack()

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

                                        -- NEW:  If the ability's conditions didn't pass, but the ability can report on times when it should recheck, let's try that now.                                        
                                        if not aScriptPass then 
                                            if ability.recheck then
                                                state.recheck( entry.Ability, ability.recheck() )
                                            else
                                                state.recheck( entry.Ability )
                                            end

                                            -- self:Print( entry.Ability .. " has " .. #state.recheckTimes .. " rechecks." )

                                            if #state.recheckTimes == 0 then
                                                if debug then self:Debug( "There were no recheck events to check." ) end
                                            else
                                                local base_delay = state.delay

                                                for i, step in pairs( state.recheckTimes ) do

                                                    if debug then self:Debug( "%d at %.2f", i, step ) end

                                                    if chosenWaitValue <= base_delay + step then
                                                        if debug then self:Debug( "Rechecking stopped at step #%d.  The previously chosen ability is ready before this recheck would occur ( %.2f < %.2f ).", i, chosenWaitValue, base_delay + step ) end
                                                        break
                                                    end

                                                    state.delay = base_delay + step

                                                    if self:CheckAPLStack() then
                                                        aScriptPass = checkScript( 'A', scriptID )
                                                        if debug then self:Debug( "Recheck #%d ( +%.2f ) %s: %s", i, state.delay, aScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'A', scriptID ) ) end
                                                    end

                                                    if aScriptPass then break
                                                    else state.delay = base_delay end
                                                end
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

                                            elseif entry.Ability == 'wait' then
                                                -- local args = ns.getModifiers( listID, actID )
                                                local sec = state.args.WaitSeconds or state.args.sec or 1
                                                if sec > 0 then
                                                    if debug then self:Debug( "Criteria for Wait action were met, advancing by %.2f and restarting this list.", sec ) end
                                                    -- NOTE, WE NEED TO TELL OUR INCREMENT FUNCTION ABOUT THIS...
                                                    state.advance( sec )
                                                    actID = 0
                                                end

                                            elseif entry.Ability == 'pool_resource' then                                                
                                                if entry.PoolForNext or state.args.for_next == 1 then
                                                    if debug then self:Debug( "Pool Resource is not used in the Predictive Engine; ignored." ) end
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

                                                if debug then
                                                    self:Debug( "731 Action Chosen: %s at %f!", chosen_action, state.delay )
                                                end

                                                if entry.CycleTargets and state.active_enemies > 1 and ability and ability.cycle then
                                                    if state.dot[ ability.cycle ].up and state.active_dot[ ability.cycle ] < ( state.args.MaxTargets or state.active_enemies ) then
                                                        slot.indicator = 'cycle'
                                                    end
                                                end
                                            end
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

    local scriptID = listStack[ listID ]
    listStack[ listID ] = nil
    if listCache[ scriptID ] then table.wipe( listCache[ scriptID ] ) end
    if listValue[ scriptID ] then table.wipe( listValue[ scriptID ] ) end

    return chosen_action, chosen_wait, chosen_clash, chosen_depth

end


-- Used to cache reusable criteria in an APL loop.
local criteria = {}

function Hekili:ProcessActionList( dispID, hookID, listID, slot, depth, action, time_ceiling )
    
    if not hookID or hookID == 0 then
        -- This is the entry point for the iterative engine.
        -- Any cache-wiping should happen here.
        table.wipe( listStack )
        table.wipe( listIsBad )
        for k, v in pairs( listCache ) do table.wipe( v ) end
        for k, v in pairs( listValue ) do table.wipe( v ) end

        table.wipe( itemTried )
    end

    local display = self.DB.profile.displays[ dispID ]
    local list = self.DB.profile.actionLists[ listID ]
    
    local debug = self.ActiveDebug
    
    -- if debug then self:Debug( "Testing action list [ %d - %s ].", listID, list and list.Name or "ERROR - Does Not Exist" ) end
    if debug then self:Debug( "WARNING:  We are using our timeline engine instead of our predictive engine. [hekili notice this]" ) end
    -- if debug then self:Debug( "Previous Recommendation: %s at +%.2fs, clash is %.2f.", action or "NO ACTION", wait or 60, clash or 0 ) end
    
    -- the stack will prevent list loops, but we need to keep this from destroying existing data... later.
    if not list then
        if debug then self:Debug( "No list with ID #%d. Should never see.", listID ) end
    elseif listStack[ listID ] then
        if debug then self:Debug( "Action list loop detected. %s was already processed earlier. Aborting.", list.Name ) end
        return 
    else
        if debug then self:Debug( "Adding %s to the list of processed action lists.", list.Name ) end
        listStack[ listID ] = hookID or 0
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
                return chosen_action, chosen_clash, chosen_depth, stop
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

                                        if entry.Ability == 'run_action_list' then
                                            listIsBad[ scriptID ] = listID
                                        end
                                        
                                        stop = entry.Ability == 'run_action_list'
                                        calledList = true
                                    else
                                        if debug then self:Debug( "The action list for %s ( %s ) was not found - %s / %s.", entry.Ability, aList, entry.ModName or "nil", state.args.name or "nil" ) end
                                    end
                                end
                                
                            end
                            
                        else
                            usable = isUsable( state.this_action )
                            
                            if debug then self:Debug( "Ability ( %s ) is %s.", entry.Ability, usable and "USABLE" or "NOT USABLE" ) end

                            if ability.item then
                                if list.Name == "Usable Items" then
                                    if itemTried[ entry.Ability ] then
                                        if debug then self:Debug( "This ability is item-based and was tested by the specialization's APLs; skipping." ) end
                                        usable = false
                                    end
                                else
                                    itemTried[ entry.Ability ] = true
                                end
                            end
                            
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
                                        local sec = state.args.WaitSeconds or state.args.sec or 1
                                        if sec > 0 then
                                            if time_ceiling and state.query_time + sec > time_ceiling then
                                                if debug then self:Debug( "Attemped to wait %.2f seconds, but this would advance past our time ceiling of %.2f.  Skipping.", sec, time_ceiling ) end
                                            else
                                                if debug then self:Debug( "Criteria for Wait action were met, advancing by %.2f.", sec ) end
                                                -- NOTE, WE NEED TO TELL OUR INCREMENT FUNCTION ABOUT THIS...
                                                state.advance( sec )
                                                actID = 0
                                            end
                                        end
                                        
                                    elseif entry.Ability == 'pool_resource' then                                                
                                        if entry.PoolForNext then
                                            -- Pooling for the next entry in the list.
                                            local next_entry  = list.Actions[ actID + 1 ]
                                            local next_action = next_entry and next_entry.Ability
                                            local next_id     = next_action and class.abilities[ next_action ] and class.abilities[ next_action ].id

                                            local next_known  = next_action and isKnown( next_action )
                                            local next_usable = next_action and isUsable( next_action )

                                            if not next_entry then
                                                if debug then self:Debug( "Attempted to Pool Resources for non-existent next entry in the APL.  Skipping." ) end
                                            elseif not next_action or not next_id or next_id < 0 then
                                                if debug then self:Debug( "Attempted to Pool Resources for invalid next entry in the APL.  Skipping." ) end
                                            elseif not next_known then
                                                if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but the next entry is not known.  Skipping.", next_action ) end
                                            elseif not next_usable then
                                                if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but the next entry is not usable.  Skipping.", next_action ) end                                               
                                            else
                                                local next_wait = timeToReady( next_action, true )

                                                if next_wait <= 0 then
                                                    if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but there is no need to wait.  Skipping.", next_action ) end
                                                elseif next_wait >= time_ceiling - state.now - state.offset then
                                                    if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but we would exceed our time ceiling in %.2fs.  Skipping.", next_action, next_wait ) end
                                                elseif next_wait >= 10 then
                                                    if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but we'd have to wait much too long ( %.2f ).  Skipping.", next_action, next_wait ) end
                                                else
                                                    -- Pad the wait value slightly, to make sure the resource is actually generated.
                                                    next_wait = next_wait + 0.01
                                                    state.offset = state.offset + next_wait

                                                    aScriptPass = not next_entry.Script or next_entry.Script == '' or checkScript( 'A', listID .. ':' .. ( actID + 1 ) )

                                                    if not aScriptPass then
                                                        if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but its conditions would not be met.  Skipping.", next_action ) end
                                                        state.offset = state.offset - next_wait
                                                    else
                                                        if debug then self:Debug( "Pooling Resources for Next Entry ( %s ), delaying by %.2f.", next_action, next_wait ) end
                                                        state.offset = state.offset - next_wait
                                                        state.advance( next_wait )
                                                    end
                                                end
                                            end

                                        else
                                            -- Pooling for a Wait Value.
                                            -- NYI.
                                            if debug then self:Debug( "Pooling for a specified period of time is not supported yet.  Skipping." ) end
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
                                            self:Debug( "1982 Action Chosen: %s at %f!", chosen_action, state.offset )
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


    local scriptID = listStack[ listID ]

    listStack[ listID ] = nil
    if listCache[ scriptID ] then table.wipe( listCache[ scriptID ] ) end
    if listValue[ scriptID ] then table.wipe( listValue[ scriptID ] ) end

    return chosen_action, chosen_clash, chosen_depth

end



function Hekili:GetNextPrediction( dispID, slot )
    
    local debug = self.ActiveDebug
    
    -- This is the entry point for the prediction engine.
    -- Any cache-wiping should happen here.
    table.wipe( listStack )
    table.wipe( listIsBad )
    for k, v in pairs( listCache ) do table.wipe( v ) end
    for k, v in pairs( listValue ) do table.wipe( v ) end

    local display = self.DB.profile.displays[ dispID ]

    local dScriptPass = true
    
    local chosen_action
    local chosen_wait, chosen_clash, chosen_depth = 60, self.DB.profile.Clash or 0, 0

    state.this_action = nil

    for k in pairs( state.variable ) do
        state.variable[ k ] = nil
    end
    
    if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
        -- We have a precombat display and combat hasn't started.
        local list = self.DB.profile.actionLists[ display.precombatAPL ]
        local listName = list and list.Name or "NO LIST FOUND"

        if not list then
            if debug then self:Debug( "Unable to find a precombat APL with index %d.  Skipping.", display.precombatAPL ) end
        else
            if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
            chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
            if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
        end
    else
        if debug then
            if state.time > 0 then
                self:Debug( "Precombat APL not processed because combat time is %.2f.", state.time )
            end
        end
    end
    
    if display.defaultAPL and display.defaultAPL > 0 and chosen_wait > 0 then
        local list = self.DB.profile.actionLists[ display.defaultAPL ]
        local listName = list and list.Name or "NO LIST FOUND"

        if not list then
            if debug then self:Debug( "Unable to find a default APL with index %d.  Skipping.", display.defaultAPL ) end
        else
            if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
            chosen_action, chosen_wait, chosen_clash, chosen_depth = self:GetPredictionFromAPL( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action, chosen_wait, chosen_clash )
            if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
        end 
    end
    
    if debug then self:Debug( "Recommendation is %s at %.2f + %.2f.", chosen_action or "NO ACTION", state.offset, chosen_wait ) end
    
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
    
    if not self.Pause or self.ActiveDebug then
        local display = self.DB.profile.displays[ dispID ]
        
        ns.queue[ dispID ] = ns.queue[ dispID ] or {}
        local Queue = ns.queue[ dispID ]
        
        if display and ns.visible.display[ dispID ] then
            
            state.reset( dispID )
            
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
            
            -- if debug then self:Debug( "Conditions %s: %s", dScriptPass and "MET" or "NOT MET", ns.getConditionsAndValues( 'D', dispID ) ) end

            
            if ( self.Config or dScriptPass > 0 ) then
                
                local debug = self.ActiveDebug
                
                local gcd_length = rawget( state, 'gcd' ) or max( 0.75, 1.5 * state.haste )

                if debug then
                    self:SetupDebug( display.Name )
                    self:Debug( "*** START OF NEW DISPLAY ***\n" ..
                                "Display %d (%s) is %s.", dispID, display.Name, ( self.Config or dScriptPass > 0 ) and "VISIBLE" or "NOT VISIBLE" ) 

                end

                for i = 1, ( display.numIcons or 4 ) do

                    table.wipe( listStack )
                    table.wipe( listIsBad )
                               
                    local chosen_action
                    local chosen_depth = 0
                    
                    Queue[i] = Queue[i] or {}
                    
                    local slot = Queue[i]
                    
                    local attempts = 0
                    local iterated = false
                    
                    if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( time offset: %.2f, remaining GCD: %.2f ).", i, state.offset, state.cooldown.global_cooldown.remains ) end
                    
                    for k in pairs( state.variable ) do
                        state.variable[ k ] = nil
                    end

                    if debug then
                        for k in pairs( class.resources ) do
                            self:Debug( "[ ** ] %s, %d / %d", k, state[ k ].current, state[ k ].max )
                        end
                    end

                    state.delay = 0

                    local predicted_action, predicted_wait, predicted_clash, predicted_depth = self:GetNextPrediction( dispID, slot )
                    if debug then self:Debug( "Prediction engine would recommend %s at +%.2fs.\n", predicted_action or "NO ACTION", predicted_wait or 60 ) end

                    local gcd_remains = state.cooldown.global_cooldown.remains

                    if not self.DB.profile.moreCPU then
                        if debug then self:Debug( "The addon is conserving CPU and will not attempt additional testing to find a better recommendation." ) end
                        chosen_action, state.delay, chosen_clash, chosen_depth = predicted_action, predicted_wait, predicted_clash, predicted_depth
                    
                    elseif ( predicted_action and predicted_wait <= ( gcd_remains + 0.25 ) ) then
                        if debug then self:Debug( "The prediction engine's recommendation [ %s @ %.2f ] is available soon enough ( within GCD + 0.25s ).  Using this recommendation.", predicted_action, predicted_wait ) end
                        chosen_action, state.delay, chosen_clash, chosen_depth = predicted_action, predicted_wait, predicted_clash, predicted_depth
                    
                    else
                        table.wipe( iterationSteps )

                        state.delay = 0
                        local pred_time = state.now + state.offset + predicted_wait

                        iterationSteps[1] = state.now + state.offset + gcd_remains
                        iterationSteps[2] = iterationSteps[1] + state.gcd * 0.5
                        iterationSteps[3] = iterationSteps[2] + state.gcd * 0.5
                        iterationSteps[4] = iterationSteps[3] + state.gcd

                        --[[ if class.setupIterationSteps then
                            class.setupIterationSteps( iterationSteps )
                        end ]]

                        for step, nextFrame in ipairs( iterationSteps ) do

                            if debug then self:Debug( "%.2f vs. %.2f (%d)", pred_time, nextFrame, step ) end

                            if step > 4 then
                                if debug then self:Debug( "Tried 4 times to beat the prediction engine; giving up." ) end
                                break
                            end

                            if nextFrame >= pred_time then
                                if debug then self:Debug( "The next iteration at %.2f is not within our time limit ( %.2f ), aborting.", nextFrame, pred_time ) end
                                break
                            end

                            local amount = nextFrame - state.now - state.offset

                            if step == 1 or amount > 0 then
                                if amount > 0 then state.advance( amount ) end

                                if debug then self:Debug( "\nIteration #%d at +%.2fs ( +%.2f )...\n( %.2f = %.2f ) < %.2f?", step, state.offset, amount, state.query_time, nextFrame, pred_time )
                                    for k, v in pairs( class.resources ) do
                                        self:Debug( " - %s: %.2f", k, state[ k ].current )
                                    end
                                end

                                if display.precombatAPL and display.precombatAPL > 0 and state.time == 0 then
                                    -- We have a precombat display and combat hasn't started.
                                    local listName = self.DB.profile.actionLists[ display.precombatAPL ].Name
                                    
                                    if debug then self:Debug("Processing precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                                    chosen_action, chosen_depth = self:ProcessActionList( dispID, hookID, display.precombatAPL, slot, chosen_depth, chosen_action, pred_time )
                                    if debug then self:Debug( "Completed precombat action list [ %d - %s ].", display.precombatAPL, listName ) end
                                end
                                
                                if display.defaultAPL and display.defaultAPL > 0 then
                                    local listName = self.DB.profile.actionLists[ display.defaultAPL ].Name
                                    
                                    if debug then self:Debug("Processing default action list [ %d - %s ].", display.defaultAPL, listName ) end
                                    chosen_action, chosen_depth = self:ProcessActionList( dispID, hookID, display.defaultAPL, slot, chosen_depth, chosen_action, pred_time )
                                    if debug then self:Debug( "Completed default action list [ %d - %s ].", display.defaultAPL, listName ) end
                                end

                                if chosen_action then
                                    if debug then self:Debug( "Found recommendation for %s at %.2fs (iteration #%d).", chosen_action, state.offset, i ) end
                                    break
                                end
                            end
                        end
                        
                        if self.Testing then self:Print( "Iterator Test for Slot #" .. i .. "." ) end
                        if not chosen_action or chosen_action == predicted_action then -- nothing
                        else 
                            if self.Testing then 
                                self:Print( "Prediction engine recommended " .. predicted_action .. " at " .. pred_time .. "." )
                                self:Print( "Iterator found " .. chosen_action .. " at " .. state.query_time .. ", a difference of " .. pred_time - state.query_time .. "." )
                                if not Hekili.Pause then Hekili:TogglePause() end
                            end
                        end


                        if not chosen_action then
                            -- We didn't find an action w/in 2 GCDs (up to 4 iterations); just use the delayed prediction.
                            state.advance( pred_time - ( state.now + state.offset ) )
                            chosen_action, state.delay, chosen_clash, chosen_depth = predicted_action, 0, predicted_clash, predicted_depth

                            if debug then self:Debug( "No better recommendation found before the prediction engine's recommendation; using the prediction engine's recommendation.\n" ..
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
                        
                        slot.keybind = self:GetBindingForAction( chosen_action, not display.lowercaseKBs == true )
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
                            if state.cooldown.global_cooldown.remains > 0 and not class.NoGCD then
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
    
    if not self.DB.profile.Enabled then
        return
    end
    
    -- for dispID, display in pairs(self.DB.profile.displays) do
    local display = self.DB.profile.displays[ dispID ]
    
    if not ns.UI.Buttons or not ns.UI.Buttons[ dispID ] then return end
    
    if self.Pause and not self.ActiveDebug then
        ns.UI.Buttons[ dispID ][1].Overlay:SetTexture('Interface\\Addons\\Hekili\\Textures\\Pause.blp')
        ns.UI.Buttons[ dispID ][1].Overlay:Show()
    else
        ns.UI.Buttons[ dispID ][1].Overlay:Hide()
    end
    


    flashes[dispID] = flashes[dispID] or 0
    
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
            
            local aKey, caption, indicator, binding = Queue[i].actionName, Queue[i].caption, Queue[i].indicator, Queue[i].keybind
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
                    button.Keybinding:SetText( binding )
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
                    
                    if ( class.file == 'HUNTER' or class.file == 'MONK' or class.file == 'DEATHKNIGHT' or class.file == 'DRUID' or class.file == 'WARRIOR' ) then
                        local exact = Queue[i].exact_time or 0
                        local end_gcd = gcd_start + gcd_duration
                        local diff = abs( exact - end_gcd )

                        if exact > now and diff >= 0.1 then
                            local delay = exact - now
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

function Hekili:UpdateDisplays()
    local now = GetTime()
    
    for display, update in pairs( updatedDisplays ) do
        if now - update > 0.033 then
            Hekili:UpdateDisplay( display )
            updatedDisplays[ display ] = now
        end
    end
end
