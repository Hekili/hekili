-- Hekili.lua
-- April 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local buildUI = ns.buildUI
local callHook = ns.callHook
local checkScript = ns.checkScript
local formatKey = ns.formatKey
local getSpecializationID = ns.getSpecializationID
local getResourceName = ns.getResourceName
local importModifiers = ns.importModifiers
local initializeClassModule = ns.initializeClassModule
local isKnown = ns.isKnown
local isUsable = ns.isUsable
local loadScripts = ns.loadScripts
local refreshBindings = ns.refreshBindings
local refreshOptions = ns.refreshOptions
local restoreDefaults = ns.restoreDefaults
local runHandler = ns.runHandler
local tableCopy = ns.tableCopy

local timeToReady = ns.timeToReady
local clashOffset = ns.clashOffset

local mt_resource = ns.metatables.mt_resource

local trim = string.trim

local AD = ns.lib.ArtifactData


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
            if not display['Single - Minimum'] or type( display['Single - Minimum'] ) ~= 'number' then display['Single - Minimum'] = 0 end
            if not display['Single - Maximum'] or type( display['Single - Maximum'] ) ~= 'number' then display['Single - Maximum'] = 0 end
            if not display['AOE - Minimum'] or type( display['AOE - Minimum'] ) ~= 'number' then display['AOE - Minimum'] = 0 end
            if not display['AOE - Maximum'] or type( display['AOE - Maximum'] ) ~= 'number' then display['AOE - Maximum'] = 0 end
            if not display['Auto - Minimum'] or type( display['Auto - Minimum'] ) ~= 'number' then display['Auto - Minimum'] = 0 end
            if not display['Auto - Maximum'] or type( display['Auto - Maximum'] ) ~= 'number' then display['Auto - Maximum'] = 0 end
            if not display['Range Checking'] then display['Range Checking'] = 'ability' end

            if display['PvE Visibility'] and not display['PvE - Default Alpha'] then
                if display['PvE Visibility'] == 'always' then
                    display['PvE - Default'] = true
                    display['PvE - Default Alpha'] = 1
                    display['PvE - Target'] = false
                    display['PvE - Target Alpha'] = 1
                    display['PvE - Combat'] = false
                    display['PvE - Combat Alpha'] = 1
                elseif display['PvE Visibility'] == 'combat' then
                    display['PvE - Default'] = false
                    display['PvE - Default Alpha'] = 1
                    display['PvE - Target'] = false
                    display['PvE - Target Alpha'] = 1
                    display['PvE - Combat'] = true
                    display['PvE - Combat Alpha'] = 1
                elseif display['PvE Visibility'] == 'target' then
                    display['PvE - Default'] = false
                    display['PvE - Default Alpha'] = 1
                    display['PvE - Target'] = true
                    display['PvE - Target Alpha'] = 1
                    display['PvE - Combat'] = false
                    display['PvE - Combat Alpha'] = 1
                else
                    display['PvE - Default'] = false
                    display['PvE - Default Alpha'] = 1
                    display['PvE - Target'] = false
                    display['PvE - Target Alpha'] = 1
                    display['PvE - Combat'] = false
                    display['PvE - Combat Alpha'] = 1
                end
                display['PvE Visibility'] = nil
            end

            if display['PvP Visibility'] and not display['PvP - Default Alpha'] then
                if display['PvP Visibility'] == 'always' then
                    display['PvP - Default'] = true
                    display['PvP - Default Alpha'] = 1
                    display['PvP - Target'] = false
                    display['PvP - Target Alpha'] = 1
                    display['PvP - Combat'] = false
                    display['PvP - Combat Alpha'] = 1
                elseif display['PvP Visibility'] == 'combat' then
                    display['PvP - Default'] = false
                    display['PvP - Default Alpha'] = 1
                    display['PvP - Target'] = false
                    display['PvP - Target Alpha'] = 1
                    display['PvP - Combat'] = true
                    display['PvP - Combat Alpha'] = 1
                elseif display['PvP Visibility'] == 'target' then
                    display['PvP - Default'] = false
                    display['PvP - Default Alpha'] = 1
                    display['PvP - Target'] = true
                    display['PvP - Target Alpha'] = 1
                    display['PvP - Combat'] = false
                    display['PvP - Combat Alpha'] = 1
                else
                    display['PvP - Default'] = false
                    display['PvP - Default Alpha'] = 1
                    display['PvP - Target'] = false
                    display['PvP - Target Alpha'] = 1
                    display['PvP - Combat'] = false
                    display['PvP - Combat Alpha'] = 1
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
                for hookID, hook in ipairs ( display.Queues ) do
                    if hook[ 'Action List' ] == i then
                        hook[ 'Action List' ] = 0
                        hook.Enabled = false
                    elseif hook[ 'Action List' ] > i then
                        hook[ 'Action List' ] = hook[ 'Action List' ] - 1
                    end
                end
            end
            table.remove( profile.actionLists, i )
        elseif not ns.isDefault( list.Name, "actionLists" ) then
            list.Default = false
        end
            

    end    

end


-- OnInitialize()
-- Addon has been loaded by the WoW client (1x).
function Hekili:OnInitialize()
    self.DB = LibStub( "AceDB-3.0" ):New( "HekiliDB", self:GetDefaults() )

    self.Options = self:GetOptions()
    self.Options.args.profiles = LibStub( "AceDBOptions-3.0" ):GetOptionsTable( self.DB )

    -- Add dual-spec support
    ns.lib.LibDualSpec:EnhanceDatabase( self.DB, "Hekili" )
    ns.lib.LibDualSpec:EnhanceOptions( self.Options.args.profiles, self.DB )

    self.DB.RegisterCallback( self, "OnProfileChanged", "TotalRefresh" )
    self.DB.RegisterCallback( self, "OnProfileCopied", "TotalRefresh" )
    self.DB.RegisterCallback( self, "OnProfileReset", "TotalRefresh" )

    ns.lib.AceConfig:RegisterOptionsTable( "Hekili", self.Options )
    self.optionsFrame = ns.lib.AceConfigDialog:AddToBlizOptions( "Hekili", "Hekili" )
    self:RegisterChatCommand( "hekili", "CmdLine" )
    self:RegisterChatCommand( "hek", "CmdLine" )

    if not self.DB.profile.Version or self.DB.profile.Version < 2 or not self.DB.profile.Release or self.DB.profile.Release < 20160000 then
        self.DB:ResetDB()
    end

    initializeClassModule()
    refreshBindings()
    restoreDefaults()
    checkImports()
    refreshOptions()
    loadScripts()

    ns.updateTalents()
    ns.updateGear()

    ns.primeTooltipColors()

    self.DB.profile.Release = self.DB.profile.Release or 20161003.1

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
    checkImports()
    refreshOptions()
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

    Hekili.s = ns.state

    -- May want to refresh configuration options, key bindings.
    if self.DB.profile.Enabled then

        --[[ for i = 1, #self.DB.profile.displays do
            self:ProcessHooks( i )
            updatedDisplays[ i ] = true
        end ]]

        self:UpdateDisplays()
        ns.Audit()

    else
        self:Disable()

    end

end


function Hekili:OnDisable()
    self.DB.profile.Enabled = false
    ns.StopEventHandler()
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
s_textures[GetSpellInfo(115356)] = 1029585  -- Windstrike
s_textures[GetSpellInfo(17364)] = 132314  -- Stormstrike
-- NYI:  Need Chain Lightning/Lava Beam here.

local function GetSpellTexture( spell )
    -- if class.abilities[ spell ].item then return i_textures[ spell ] end
    return ( s_textures[ spell ] )
end


local z_PVP = {
    arena = true,
    pvp = true
}


local palStack = {}

function Hekili:ProcessActionList( dispID, hookID, listID, slot  )
    
    local list = self.DB.profile.actionLists[ listID ]
    
    -- the stack will prevent list loops, but we need to keep this from destroying existing data... later.
    if not list or palStack[ list.Name ] then return
    else palStack[ list.Name ] = true end
    
    local chosen_action
    local chosen_clash, chosen_wait = 0, 999
    local stop = false

    if ns.visible.list[ listID ] then
        local actID = 1

        while actID <= #list.Actions do
            if chosen_wait == 0 or stop then
                break
            end

            if ns.visible.action[ listID..':'..actID ] then

                -- Check for commands before checking actual actions.
                local entry = list.Actions[ actID ]
                state.this_action = entry.Ability
                state.this_args = entry.Args
                
                state.delay = nil

                local ability = class.abilities[ entry.Ability ]

                local wait_time = 999
                local clash = 0

                if isKnown( state.this_action ) then
                    -- Used to notify timeToReady() about an artificial delay for this ability.
                    state.script.entry = entry.whenReady == 'script' and ( listID .. ':' .. actID ) or nil

                    wait_time = timeToReady( state.this_action )
                    clash = clashOffset( state.this_action )
                end

                -- implantTimeScriptData( q )

                state.delay = wait_time

                importModifiers( listID, actID )

                if entry.Ability == 'call_action_list' or entry.Ability == 'run_action_list' then

                    stop = entry.Ability == 'run_action_iist'

                    local aList = state.args.ModName or state.args.name

                    if aList then
                        -- check to see if we have a real list name.
                        local called_list = 0
                        for i, list in ipairs( self.DB.profile.actionLists ) do
                            if list.Name == aList then
                                called_list = i
                                break
                            end
                        end
                        if called_list > 0 and checkScript( 'A', listID..':'..actID, nil, nil, wait_time ) then
                            chosen_action, chosen_wait, chosen_clash = Hekili:ProcessActionList( dispID, listID..':'..actID, called_list, slot )
                        end
                    end

                elseif entry.Ability == 'wait' then

                    if checkScript( 'A', listID..':'..actID, nil, nil, wait_time ) then
                        -- local args = ns.getModifiers( listID, actID )
                        if not state.args.sec then state.args.sec = 1 end
                        if state.args.sec > 0 then
                            state.advance( state.args.sec )
                            actID = 0
                        end

                    end

                -- should probably standardize this one, it doesn't need to be a special case...
                elseif entry.Ability == 'potion' then

                    local potionName = state.args.ModName or state.args.name or class.potion
                    local potion = class.potions[ potionName ]

                    if potion and isUsable( state.this_action ) and max( 0, wait_time - clash ) < max( 0, chosen_wait - chosen_clash ) and checkScript( 'A', listID..':'..actID, nil, nil, wait_time ) then
                        -- do potion things
                        
                        slot.scriptType = entry.ScriptType or 'simc'
                        slot.display = dispID
                        slot.button = i

                        slot.wait = wait_time

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
                        chosen_wait = wait_time
                        chosen_clash = clash

                    end

                elseif isUsable( state.this_action ) and max( 0, wait_time - clash ) < max( 0, chosen_wait - chosen_clash ) and ns.hasRequiredResources( state.this_action ) and checkScript( 'A', listID..':'..actID, nil, nil, wait_time ) then

                    slot.scriptType = entry.ScriptType or 'simc'
                    slot.display = dispID
                    slot.button = i

                    slot.wait = wait_time

                    slot.hook = hookID
                    slot.list = listID
                    slot.action = actID

                    slot.actionName = state.this_action
                    slot.listName = list.Name

                    slot.resource = ns.resourceType( chosen_action )
                    
                    slot.caption = entry.Caption
                    slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                    slot.texture = class.abilities[ state.this_action ].texture
                    
                    chosen_action = state.this_action
                    chosen_wait = wait_time
                    chosen_clash = clash

                end

                local ability = class.abilities[ chosen_action ]

                if entry.CycleTargets and state.active_enemies > 1 and ability and ability.cycle then
                    if state.dot[ ability.cycle ].up and state.active_dot[ ability.cycle ] < ( state.args.MaxTargets or state.active_enemies ) then
                        slot.indicator = 'cycle'
                    end
                end

                -- state.delay = nil

            end

            actID = actID + 1

        end

    end
    
    palStack[ list.Name ] = nil
    return chosen_action, chosen_wait, chosen_clash

end


function Hekili:ProcessHooks( dispID, solo )

    if not self.DB.profile.Enabled then return end

    if not self.Pause then
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

            if ( self.Config or checkScript( 'D', dispID )  ) then

                for i = 1, display['Icons Shown'] do

                    local chosen_action
                    local chosen_wait, chosen_clash = 999, 0

                    Queue[i] = Queue[i] or {}

                    local slot = Queue[i]

                    local attempts = 0

                    while attempts < 2 do
                        for hookID, hook in ipairs( display.Queues ) do

                            if ns.visible.hook[ dispID..':'..hookID ] and hookID and checkScript( 'P', dispID..':'..hookID ) then

                                local listID = hook[ 'Action List' ]
                                local outcome, wait, clash = self:ProcessActionList( dispID, hookID, listID, slot )

                                if outcome then -- and wait < chosen_wait then
                                    chosen_action, chosen_wait, chosen_clash = outcome, wait, clash
                                end

                                if chosen_wait == 0 then break end

                            end

                        end -- end Hook

                        if chosen_action then break end

                        state.advance( 1 )
                        attempts = attempts + 1
                    end


                    if chosen_action then
                        -- We have our actual action, so let's get the script values if we're debugging.

                        if self.DB.profile.Debug then ns.implantDebugData( slot ) end

                        slot.time = state.offset + chosen_wait
                        slot.since = i > 1 and slot.time - Queue[ i - 1 ].time or 0
                        slot.resources = slot.resources or {}

                        for k,v in pairs( class.resources ) do
                            slot.resources[k] = state[k].current
                        end

                        slot.resource_type = ns.resourceType( chosen_action )

                        if i < display['Icons Shown'] then

                            -- Advance through the wait time.
                            state.advance( chosen_wait )

                            local action = class.abilities[ chosen_action ]

                            -- Start the GCD.
                            if action.gcdType ~= 'off' and state.cooldown.global_cooldown.remains == 0 then
                                state.setCooldown( 'global_cooldown', state.gcd )
                            end

                            -- Advance the clock by cast_time.
                            if action.cast > 0 and not action.channeled then
                                state.advance( action.cast )
                            end

                            -- Put the action on cooldown.  (It's slightly premature, but addresses CD resets like Echo of the Elements.)
                            if class.abilities[ chosen_action ].charges and action.recharge > 0 then
                                state.spendCharges( chosen_action, 1 )
                                elseif chosen_action ~= 'global_cooldown' then
                                    state.setCooldown( chosen_action, action.cooldown )
                                end

                            state.cycle = slot.indicator == 'cycle'

                            -- Perform the action.
                            ns.runHandler( chosen_action, slot.list, slot.action ) -- , ns.getModifiers( slot.actionlist, slot.action )  )

                            -- Spend resources.
                            ns.spendResources( chosen_action )

                            -- Advance the clock by cast_time.
                            if action.cast > 0 and action.channeled then
                                state.advance( action.cast )
                            end

                            -- Move the clock forward if the GCD hasn't expired.
                            if state.cooldown.global_cooldown.remains > 0 then
                                state.advance( state.cooldown.global_cooldown.remains )
                            end

                        end

                    else
                        for n = i, display['Icons Shown'] do
                            slot[n] = nil
                        end
                        break
                    end

                end

            end

        end

    end

-- if not solo then C_Timer.After( 1 / self.DB.profile['Updates Per Second'], self[ 'ProcessDisplay'..dispID ] ) end
updatedDisplays[ dispID ] = true
-- Hekili:UpdateDisplay( dispID )

end

Hekili.ud = updatedDisplays


local pvpZones = {
    arena = true,
    pvp = true
}


local function CheckDisplayCriteria( dispID )

    local display = Hekili.DB.profile.displays[ dispID ]
    local _, zoneType = IsInInstance()

    -- if C_PetBattles.IsInBattle() or Hekili.Barber or UnitInVehicle( 'player' ) or not ns.visible.display[ dispID ] then
    if C_PetBattles.IsInBattle() or UnitOnTaxi( 'player' ) or Hekili.Barber or HasVehicleActionBar() or not ns.visible.display[ dispID ] then
        return 0

    elseif not pvpZones[ zoneType ] then
        if display['PvE - Target'] and UnitExists( 'target' ) and not ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
            return display['PvE - Target Alpha']

        elseif display['PvE - Combat'] and UnitAffectingCombat( 'player' ) then
            return display['PvE - Combat Alpha']

        elseif display['PvE - Default'] then
            return display['PvE - Default Alpha']

        end

        return 0

    elseif pvpZones[ zoneType ] then
        if display['PvP - Target'] and UnitExists( 'target' ) and not ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
            return display['PvP - Target Alpha']

        elseif display['PvP - Combat'] and UnitAffectingCombat( 'player' ) then
            return display['PvP - Combat Alpha']

        elseif display['PvP - Default'] then
            return display['PvP - Default Alpha']

        end

        return 0

    elseif not Hekili.Config and not ns.queue[ dispID ] then
        return 0

    elseif not checkScript( 'D', dispID ) then
        return 0

    end

    return 0

end
ns.CheckDisplayCriteria = CheckDisplayCriteria


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

            _G[ "HekiliDisplay" .. dispID ]:Show()

            for i, button in ipairs( ns.UI.Buttons[dispID] ) do
                if not Queue or not Queue[i] and ( self.DB.profile.Enabled or self.Config ) then
                    for n = i, display['Icons Shown'] do
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

                if aKey then
                    button:Show()
                    button:SetAlpha(alpha)
                    button.Texture:SetTexture( Queue[i].texture or class.abilities[ aKey ].texture or GetSpellTexture( class.abilities[ aKey ].id ) )
                    local zoom = ( display.Zoom or 0 ) / 200
                    button.Texture:SetTexCoord( zoom, 1 - zoom, zoom, 1 - zoom )
                    button.Texture:Show()

                    if indicator then
                        if indicator == 'cycle' then button.Icon:SetTexture( "Interface\\Addons\\Hekili\\Textures\\Cycle" ) end
                        if indicator == 'cancel' then button.Icon:SetTexture( "Interface\\Addons\\Hekili\\Textures\\Cancel" ) end
                        button.Icon:Show()
                    else
                        button.Icon:Hide()
                    end

                    if display['Action Captions'] then

                        -- 0 = single
                        -- 2 = cleave
                        -- 2 = aoe
                        -- 3 = auto
                        local min_targets, max_targets = 0, 0

                        if Hekili.DB.profile['Mode Status'] == 0 then
                            if display['Single - Minimum'] > 0 then min_targets = display['Single - Minimum'] end
                            if display['Single - Maximum'] > 0 then max_targets = display['Single - Maximum'] end
                        elseif Hekili.DB.profile['Mode Status'] == 2 then
                            if display['AOE - Minimum'] > 0 then min_targets = display['AOE - Minimum'] end
                            if display['AOE - Maximum'] > 0 then max_targets = display['AOE - Maximum'] end
                        elseif Hekili.DB.profile['Mode Status'] == 3 then
                            if display['Auto - Minimum'] > 0 then min_targets = display['Auto - Minimum'] end
                            if display['Auto - Maximum'] > 0 then max_targets = display['Auto - Maximum'] end
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

                        if i == 1 then
                            if display.Overlay and IsSpellOverlayed( class.abilities[ aKey ].id ) then
                                ActionButton_ShowOverlayGlow( button )
                            else
                                ActionButton_HideOverlayGlow( button )
                            end
                            button.Caption:SetJustifyH('RIGHT')
                            -- check for special captions.
                            if display['Primary Caption'] == 'targets' and targets > 1 then -- and targets > 1 then
                                button.Caption:SetText( targColor .. targets .. '|r' )

                            elseif display['Primary Caption'] == 'buff' then
                                if display['Primary Caption Aura'] then
                                    local name, _, _, count, _, _, expires = UnitBuff( 'player', display['Primary Caption Aura'] )
                                    if name then button.Caption:SetText( count or 1 )
                                    else
                                        button.Caption:SetJustifyH('CENTER')
                                        button.Caption:SetText(caption)
                                    end
                                end

                            elseif display['Primary Caption'] == 'debuff' then
                                if display['Primary Caption Aura'] then
                                    local name, _, _, count = UnitDebuff( 'target', display['Primary Caption Aura'] )
                                    if name then button.Caption:SetText( count or 1 )
                                    else
                                        button.Caption:SetJustifyH('CENTER')
                                        button.Caption:SetText(caption)
                                    end
                                end

                            elseif display['Primary Caption'] == 'ratio' then
                                if display['Primary Caption Aura'] then
                                    if ns.numDebuffs( display['Primary Caption Aura'] ) > 1 or targets > 1 then
                                        button.Caption:SetText( ns.numDebuffs( display['Primary Caption Aura'] ) .. ' / ' .. targColor .. targets .. '|r' )
                                    else
                                        button.Caption:SetJustifyH('CENTER')
                                        button.Caption:SetText(caption)
                                    end
                                end

                            elseif display['Primary Caption'] == 'sratio' then
                                if display['Primary Caption Aura'] then
                                    local name, _, _, count, _, _, expires = UnitBuff( 'player', display['Primary Caption Aura'] )
                                    if name and ( ( count or 1 ) > 0 ) then
                                        local cap = count or 1
                                        if targets > 1 then cap = cap .. ' / ' .. targColor .. targets .. '|r' end
                                        button.Caption:SetText( cap )
                                    else
                                        if targets > 1 then button.Caption:SetText( targColor .. targets .. '|r' )
                                        else
                                            button.Caption:SetJustifyH('CENTER')
                                            button.Caption:SetText(caption)
                                        end
                                    end
                                end

                            else
                                button.Caption:SetJustifyH('CENTER')
                                button.Caption:SetText(caption)

                            end
                        else
                            button.Caption:SetJustifyH('CENTER')
                            button.Caption:SetText(caption)

                        end
                    else
                        button.Caption:SetJustifyH('CENTER')
                        button.Caption:SetText(nil)

                    end

                    local start, duration = GetSpellCooldown( class.abilities[ aKey ].id )
                    local gcd_remains = gcd_start + gcd_duration - GetTime()

                    if class.abilities[ aKey ].gcdType ~= 'off' and ( not start or start == 0 or ( start + duration ) < ( gcd_start + gcd_duration ) ) then
                        start = gcd_start
                        duration = gcd_duration
                    end

                    if i == 1 then
                        button.Cooldown:SetCooldown( start, duration )

                        if ns.lib.SpellFlash and display['Use SpellFlash'] and GetTime() >= flashes[dispID] + 0.2 then
                            ns.lib.SpellFlash.FlashAction( class.abilities[ aKey ].id, display['SpellFlash Color'] )
                            flashes[dispID] = GetTime()
                        end

                        if ( class.file == 'HUNTER' or class.file == 'MONK' ) and Queue[i].time and Queue[i].time ~= gcd_remains and Queue[i].time ~= start + duration - GetTime() then
                                -- button.Texture:SetDesaturated( Queue[i].time > 0 )
                                button.Delay:SetText( Queue[i].time > 0 and format( "%.1f", Queue[i].time ) or nil )
                        else
                                -- button.Texture:SetDesaturated( false )
                                button.Delay:SetText( nil )
                        end

                    else
                        if ( start + duration ~= gcd_start + gcd_duration ) then
                            button.Cooldown:SetCooldown( start, duration )
                        else
                            button.Cooldown:SetCooldown( 0, 0 )
                        end
                    end

                    if display['Range Checking'] == 'melee' then
                        local minR = ns.lib.RangeCheck:GetRange( 'target' )
                        
                        if minR and minR >= 5 then 
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 0, 0)
                        elseif i == 1 and select(2, IsUsableSpell( class.abilities[ aKey ].id ) ) then
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(0.4, 0.4, 0.4)
                        else
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
                        end
                    elseif display['Range Checking'] == 'ability' then
                        if ns.lib.SpellRange.IsSpellInRange( class.abilities[ aKey ].name, 'target' ) == 0 then
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 0, 0)
                        elseif i == 1 and select(2, IsUsableSpell( class.abilities[ aKey ].id )) then
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(0.4, 0.4, 0.4)
                        else
                            ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
                        end
                    elseif display['Range Checking'] == 'off' then
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
        for display in pairs( updatedDisplays ) do
                Hekili:UpdateDisplay( display )
                updatedDisplays[ display ] = nil
        end
end
