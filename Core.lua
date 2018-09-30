-- Hekili.lua
-- April 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State
local scripts = Hekili.Scripts

local callHook = ns.callHook
local clashOffset = ns.clashOffset
local formatKey = ns.formatKey
local getSpecializationID = ns.getSpecializationID
local getResourceName = ns.getResourceName
local runHandler = ns.runHandler
local tableCopy = ns.tableCopy
local timeToReady = ns.timeToReady
local trim = string.trim

local string_format = string.format

local mt_resource = ns.metatables.mt_resource
local ToggleDropDownMenu = L_ToggleDropDownMenu

local GetItemInfo = ns.CachedGetItemInfo

local updatedDisplays = {}
local recommendChecks = {}
local recommendChange = {}


-- checkImports()
-- Remove any displays or action lists that were unsuccessfully imported.
local function checkImports()
end
ns.checkImports = checkImports


local function EmbedBlizOptions()
    local panel = CreateFrame( "Frame", "HekiliDummyPanel", UIParent )
    panel.name = "Hekili"

    local open = CreateFrame( "Button", "HekiliOptionsButton", panel, "UIPanelButtonTemplate" )
    open:SetPoint( "CENTER", panel, "CENTER", 0, 0 )
    open:SetWidth( 250 )
    open:SetHeight( 25 )
    open:SetText( "Open Hekili Options Panel" )

    open:SetScript( "OnClick", function ()
        InterfaceOptionsFrameOkay:Click()
        GameMenuButtonContinue:Click()

        ns.StartConfiguration()
    end )

    InterfaceOptions_AddCategory( panel )
end


local hookOnce = false

-- OnInitialize()
-- Addon has been loaded by the WoW client (1x).
function Hekili:OnInitialize()
    self.DB = LibStub( "AceDB-3.0" ):New( "HekiliDB", self:GetDefaults() )
    
    self.Options = self:GetOptions()
    self.Options.args.profiles = LibStub( "AceDBOptions-3.0" ):GetOptionsTable( self.DB )

    -- Reimplement LibDualSpec; some folks want different layouts w/ specs of the same class.
    local LDS = LibStub( "LibDualSpec-1.0" )
    LDS:EnhanceDatabase( self.DB, "Hekili" )
    LDS:EnhanceOptions( self.Options.args.profiles, self.DB )
    
    self.DB.RegisterCallback( self, "OnProfileChanged", "TotalRefresh" )
    self.DB.RegisterCallback( self, "OnProfileCopied", "TotalRefresh" )
    self.DB.RegisterCallback( self, "OnProfileReset", "TotalRefresh" )
    
    _G.onInitStart = self.DB.profile.enabled

    local AceConfig = LibStub( "AceConfig-3.0" )
    AceConfig:RegisterOptionsTable( "Hekili", self.Options )

    local AceConfigDialog = LibStub( "AceConfigDialog-3.0" )
    -- self.optionsFrame = AceConfigDialog:AddToBlizOptions( "Hekili", "Hekili" )
    EmbedBlizOptions()

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
                    ToggleDropDownMenu( 1, nil, Hekili_Menu, "cursor", 0, 0 )
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
            local m = p.toggles.mode.value
            local color = "FFFFD100"
            
            self.text = format( "|c%s%s|r %sCD|r %sInt|r %sPot|r",
            color,
            m == "single" and "ST" or ( m == "aoe" and "AOE" or ( m == "dual" and "Dual" or ( m == "reactive" and "rAOE" or "Auto" ) ) ),
            p.toggles.cooldowns.value and "|cFF00FF00" or "|cFFFF0000",
            p.toggles.interrupts.value and "|cFF00FF00" or "|cFFFF0000",
            p.toggles.potions.value  and "|cFF00FF00" or "|cFFFF0000" )
        end
        
        ns.UI.Minimap:RefreshDataText()
        
        if LDBIcon then
            LDBIcon:Register( "Hekili", ns.UI.Minimap, self.DB.profile.iconStore )
        end
    end
    
    
    --[[ NEED TO PUT VERSION UPDATING STUFF HERE.
    if not self.DB.profile.Version or self.DB.profile.Version < 7 or not self.DB.profile.Release or self.DB.profile.Release < 20161000 then
        self.DB:ResetDB()
    end
    
    self.DB.profile.Release = self.DB.profile.Release or 20170416.0 ]]
    
    -- initializeClassModule()
    self:RestoreDefaults()
    self:RunOneTimeFixes()
    checkImports()
    
    self:RefreshOptions()
    -- self:LoadScripts()
    
    ns.updateTalents()
    ns.updateGear()
    
    ns.primeTooltipColors()

    self:UpdateDisplayVisibility()
    
    callHook( "onInitialize" )
end
    

function Hekili:ReInitialize()
    -- ns.initializeClassModule()
    self:OverrideBinds()
    self:RestoreDefaults()
    
    checkImports()
    self:RunOneTimeFixes()

    -- self:RefreshOptions()
    -- self:LoadScripts()
    self:SpecializationChanged()
    
    ns.updateTalents()
    ns.updateGear()

    self:UpdateDisplayVisibility()
        
    callHook( "onInitialize" )
    
    if self.DB.profile.enabled == false and self.DB.profile.AutoDisabled then 
        self.DB.profile.AutoDisabled = nil
        self.DB.profile.enabled = true
        self:Enable()
    end
    
    --[[ if class.file == 'NONE' then
        self.DB.profile.enabled = false
        self.DB.profile.AutoDisabled = true
        for i, buttons in ipairs( ns.UI.Buttons ) do
            for j, _ in ipairs( buttons ) do
                buttons[j]:Hide()
            end
        end
    end ]]
    
end 


function Hekili:OnEnable()
    ns.StartEventHandler()
   
    self:TotalRefresh()

    ns.ReadKeybindings()
    self:ForceUpdate()
    ns.Audit()    

    if not self.DB.profile.enabled then 
        self:Disable()
    end 
end

ns.cpuProfile.StartEventHandler = ns.StartEventHandler
ns.cpuProfile.BuildUI = Hekili.BuildUI
ns.cpuProfile.SpecializationChanged = Hekili.SpecializationChanged
ns.cpuProfile.OverrideBinds = Hekili.OverrideBinds
ns.cpuProfile.TotalRefresh = Hekili.TotalRefresh

function Hekili:OnDisable()
    self:UpdateDisplayVisibility()
    self:BuildUI()

    ns.StopEventHandler()
end


function Hekili:Toggle()
    self.DB.profile.enabled = not self.DB.profile.enabled

    if self.DB.profile.enabled then
        self:Enable()
    else
        self:Disable() 
    end
    
    self:UpdateDisplayVisibility()
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
local listBlock = {}    -- Run Action List entries go in here.  If criteria passes for the RAL, entries that follow cannot be used.

local listStack = {}    -- listStack for a given index returns the scriptID of its caller (or 0 if called by a display).
local listCache = {}    -- listCache is a table of return values for a given scriptID at various times.
local listValue = {}    -- listValue shows the cached values from the listCache.

local itemTried = {}    -- Items that are tested in a specialization APL aren't reused here.


local Stack = {}
local Block = {}
local InUse = {}


function Hekili:AddToStack( script, list, parent, run )
    if self.ActiveDebug then self:Debug( "Adding " .. list .. " to stack, parent is " .. ( parent or "(none)" ) .. " (RAL = " .. tostring( run ) .. ".") end
    
    table.insert( Stack, {
        script = script,
        list   = list,
        parent = parent,
        run    = run
    } )
    
    InUse[ list ] = true
end


function Hekili:PopStack()
    local x = table.remove( Stack, #Stack )

    if self.ActiveDebug then self:Debug( "Removed " .. x.list .. " from stack." ) end

    for i = #Block, 1, -1 do
        if Block[i].parent == x.script then
            if self.ActiveDebug then self:Debug( "Removed " .. Block[i].list .. " from blocklist as " .. x.list .. " was its parent." ) end
            table.remove( Block, i )
        end
    end

    if x.run then
        -- This was called via Run Action List; we have to make sure it DOESN'T PASS until we exit this list.
        if self.ActiveDebug then self:Debug( "Added " .. x.list .. " to blocklist as it was called via RAL." ) end
        table.insert( Block, x )
    end

    InUse[ x.list ] = nil
end


function Hekili:CheckStack()
    local t = state.query_time
    local p = self.ActivePack

    for i, b in ipairs( Block ) do
        local cache = listCache[ b.script ] or {}

        cache[ t ] = cache[ t ] or scripts:CheckScript( b.script )

        if self.ActiveDebug then
            local values = listValue[ b.script ] or {}
            values[ t ] = values[ t ] or scripts:GetConditionsAndValues( b.script )
            self:Debug( "Blocking list ( %s ) called from ( %s ) would %s at %.2f.\n - %s", b.list, b.script, cache[ t ] and "BLOCK" or "NOT BLOCK", state.delay, values[ t ] )
            listValue[ b.script ] = values
        end

        if cache[ t ] then
            return false
        end
    end


    for i, s in ipairs( Stack ) do        
        local cache = listCache[ s.script ] or {}

        cache[ t ] = cache[ t ] or scripts:CheckScript( s.script )

        if self.ActiveDebug then
            local values = listValue[ s.script ] or {}
            values[ t ] = values[ t ] or scripts:GetConditionsAndValues( s.script )
            self:Debug( "List ( %s ) called from ( %s ) would %s at %.2f.\n - %s", s.list, s.script, cache[ t ] and "PASS" or "FAIL", state.delay, values[ t ] )
            listValue[ s.script ] = values
        end

        listCache[ s.script ] = cache

        if not cache[ t ] then return false end
    end

    return true
end


function Hekili:CheckAPLStack()
    local t = state.query_time
    local pack = self.ActivePack

    for scriptID, listID in pairs( listIsBad ) do
        local list = pack.lists[ listID ]

        if listID and list then
            local cache = listCache[ scriptID ] or {}
            local values = listValue[ scriptID ] or {}

            cache[ t ] = cache[ t ] or scripts:CheckScript( scriptID )
            values[ t ] = values[ t ] or scripts:GetConditionsAndValues( scriptID )

            if self.ActiveDebug then self:Debug( "The conditions for a previously-run action list ( %s ) would %s at +%.2f.\n - %s", listID, cache[ t ] and "PASS" or "FAIL", state.delay, values[ t ] ) end

            listCache[ scriptID ] = cache
            listValue[ scriptID ] = value

            if cache[ t ] then
                if self.ActiveDebug then self:Debug( "Action unavailable as we would not have reached this entry at +%.2f.", state.delay ) end
                return false
            end
        end
    end

    for listID, caller in pairs( listStack ) do
        local list = pack.lists[ listID ]   

        if caller and caller ~= 0 and list and scripts:IsTimeSensitive( caller ) then
            local cache = listCache[ caller ] or {}
            local values = listValue[ caller ] or {}

            cache[ t ] = cache[ t ] or scripts:CheckScript( caller )
            values[ t ] = values[ t ] or scripts:GetConditionsAndValues( caller )

            if self.ActiveDebug then self:Debug( "The conditions for %s, called from %s, would %s at +%.2f.\n - %s", listID, caller, cache[ t ] and "PASS" or "FAIL", state.delay, values[ t ] ) end

            listCache[ caller ] = cache
            listValue[ caller ] = values

            if not cache[ t ] then return false end
        end
    end

    return true
end


function Hekili:CheckChannel( ability, prio )
    if not state.channeling then return true end

    local aura = class.auras[ state.channel ]
    if not aura or not aura.tick_time then return true end

    local channel = state.channel
    
    local modifiers = scripts.Channels[ state.system.packName ]
    modifiers = modifiers and modifiers[ channel ]

    local tick_time = aura.tick_time
    local remains = state.channel_remains

    if channel == ability then
        if prio <= remains + 0.01 then
            return false
        end
        if modifiers.early_chain_if then
            return state.cooldown.global_cooldown.up and ( remains < tick_time or ( ( remains - state.delay ) / tick_time ) % 1 <= 0.5 ) and modifiers.early_chain_if()
        end
        if modifiers.chain then
            return state.cooldown.global_cooldown.up and ( remains < tick_time ) and modifiers.chain()
        end

    else
        -- If interrupt_global is flagged, we interrupt for any potential cast.  Don't bother with additional testing.
        -- REVISIT THIS:  Interrupt Global allows entries from any action list rather than just the current (sub) list.
        -- That means interrupt / interrupt_if should narrow their scope to the current APL (at some point, anyway).
        if modifiers.interrupt_global and modifiers.interrupt_global() then
            return true
        end
        
        local act = state.this_action
        state.this_action = channel

        -- We are concerned with chain and early_chain_if.
        if modifiers.interrupt_if and modifiers.interrupt_if() then
            local val = state.cooldown.global_cooldown.up and ( modifiers.interrupt_immediate() or ( remains < tick_time or ( ( remains - state.delay ) / tick_time ) % 1 <= 0.5 ) )
            state.this_action = act
            return val
        end

        if modifiers.interrupt and modifiers.interrupt() then
            local val = state.cooldown.global_cooldown.up and ( remains < tick_time or ( ( remains - state.delay ) / tick_time ) % 1 <= 0.5 )
            state.this_action = act
            return val
        end

        state.this_action = act
    end

    return true
end


do
    local knownCache = {}

    function Hekili:IsSpellKnown( spell )
        knownCache[ spell ] = knownCache[ spell ] or state:IsKnown( spell )
        return knownCache[ spell ]
    end


    local disabledCache = {}

    function Hekili:IsSpellEnabled( spell )
        disabledCache[ spell ] = disabledCache[ spell ] or ( not state:IsDisabled( spell ) )
        return disabledCache[ spell ]
    end


    local table_wipe = table.wipe

    function Hekili:ResetSpellCaches()
        table_wipe( knownCache )
        table_wipe( disabledCache )
    end
end


local waitBlock = {}
local listDepth = 0

function Hekili:GetPredictionFromAPL( dispName, packName, listName, slot, action, wait, depth, caller )

    local display = self.DB.profile.displays[ dispName ]
    
    local specID = state.spec.id
    local spec = rawget( self.DB.profile.specs, specID )
    local module = class.specs[ specID ]

    packName = packName or self.DB.profile.specs[ specID ].package

    local pack
    if ( packName == "UseItems" ) then pack = class.itemPack
    else pack = self.DB.profile.packs[ packName ] end

    local list = pack.lists[ listName ]
    
    local debug = self.ActiveDebug
    
    if debug then self:Debug( "Current recommendation was %s at +%.2fs.", action or "NO ACTION", wait or 60 ) end
    -- if debug then self:Debug( "ListCheck: Success(%s-%s)", packName, listName ) end

    local precombatFilter = listName == "precombat" and state.time > 0

    local rAction = action
    local rWait = wait or 60
    local rDepth = depth or 0

    local strict = false -- disabled for now.
    local force_channel = false
    local stop = false

    if self:IsListActive( packName, listName ) then
        local actID = 1
        
        while actID <= #list do
            -- if not state.channel or rWait >= state.channel_remains then
            if rWait <= state.cooldown.global_cooldown.remains then
                if debug then self:Debug( "The recommended action (%s) would be ready before the next GCD (%.2f < %.2f); exiting list (%s).", rAction, rWait, state.cooldown.global_cooldown.remains, listName ) end
                break

            elseif rWait <= 0.2 then
                if debug then self:Debug( "The recommended action (%s) is ready in less than 0.2s; exiting list (%s).", rAction, listName ) end
                break

            elseif stop then
                if debug then self:Debug( "The action list reached a stopping point; exiting list (%s).", listName ) end
                break

            end
            -- end
            

            if self:IsActionActive( packName, listName, actID ) then
                -- Check for commands before checking actual actions.
                local entry = list[ actID ]

                state.this_action = entry.action
                state.this_args = nil
                state.delay = nil

                rDepth = rDepth + 1
                if debug then self:Debug( "\n[%3d]  Checking %s (%s - %s - %d )...", rDepth, entry.action, packName, listName, actID ) end
                
                local ability = class.abilities[ state.this_action ]

                local wait_time = 60
                local clash = 0
                
                local known = self:IsSpellKnown( state.this_action )
                local enabled = self:IsSpellEnabled( state.this_action )

                if debug then self:Debug( "%s is %sknown and %senabled.", entry.action, known and "" or "NOT ", enabled and "" or "NOT " ) end
                
                if ability and known and enabled then
                    local scriptID = packName .. ":" .. listName .. ":" .. actID
                    
                    -- Used to notify timeToReady() about an artificial delay for this ability.
                    -- state.script.entry = entry.whenReady == 'script' and scriptID or nil
                    scripts:ImportModifiers( scriptID )
                    local script = scripts:GetScript( scriptID )

                    wait_time = state:TimeToReady()
                    clash = state.ClashOffset()

                    state.delay = wait_time

                    if ( rWait - state.ClashOffset( rAction ) ) - ( wait_time - clash ) <= 0.05 then
                        if debug then self:Debug( "The action is not ready in time ( %.2f vs. %.2f ) [ Clash: %.2f vs. %.2f ] - padded by 0.05s.", wait_time, rWait, clash, state.ClashOffset( rAction ) ) end
                    else
                        if state.channeling then
                            if debug then self:Debug( "NOTE:  We are channeling ( %s ) until %.2f.", state.player.channelSpell, state.player.channelEnd - state.query_time ) end
                        end
                        -- APL checks.
                        if entry.action == 'variable' then
                            local name = state.args.var_name
                            
                            if name ~= nil then -- and aScriptValue ~= nil then
                                local aScriptPass = scripts:CheckScript( scriptID )

                                if aScriptPass then
                                    if debug then self:Debug( " - variable.%s will reference this script entry (%s).", name or "MISSING", scriptID ) end
                                    
                                    -- We just store the scriptID so that the variable actually gets tested at time of comparison.
                                    state.variable[ "_" .. name ] = scriptID
                                else
                                    if debug then self:Debug( " - conditions were NOT MET, ignoring (%s).", name ) end
                                end
                            end

                        elseif precombatFilter and not ability.essential then
                            if debug then self:Debug( "We are already in-combat and this pre-combat action is not essential.  Skipping." ) end
                        else
                            if entry.action == 'call_action_list' or entry.action == 'run_action_list' or entry.action == 'use_items' then
                                -- We handle these here to avoid early forking between starkly different APLs.
                                local aScriptPass = true
                                local ts = not strict and scripts:IsTimeSensitive( scriptID )

                                if not entry.criteria or entry.criteria == "" then
                                    if debug then self:Debug( "There is no criteria for %s.", entry.action == 'use_items' and "Use Items" or "this action list." ) end
                                    -- aScriptPass = ts or self:CheckStack()
                                else
                                    aScriptPass = ts or scripts:CheckScript( scriptID ) -- and self:CheckStack() -- we'll check the stack with the list's entries.

                                    if debug then 
                                        self:Debug( "%sCriteria %s at +%.2f - %s", ts and "Time-sensitive " or "", ts and "deferred" or ( aScriptPass and "PASS" or "FAIL" ), state.offset, scripts:GetConditionsAndValues( scriptID ) )
                                    end

                                    -- aScriptPass = ts or aScriptPass
                                end
                                
                                if aScriptPass then

                                    if entry.action == "use_items" then
                                        -- self:AddToStack( scriptID, "items", caller, entry.action == "run_action_list" )
                                        local pAction, pWait = rAction, rWait
                                        rAction, rWait, rDepth = self:GetPredictionFromAPL( dispName, "UseItems", "items", slot, rAction, rWait, rDepth, scriptID )
                                        if debug then self:Debug( "Returned from Use Items; current recommendation is %s (+%.2f).", rAction or "NoAction", rWait ) end
                                        -- self:PopStack()
                                    else
                                        name = state.args.list_name

                                        if InUse[ name ] then
                                            if debug then self:Debug( "Action list (%s) was found, but would cause a loop.", name ) end

                                        elseif name and pack.lists[ name ] then
                                            if debug then self:Debug( "Action list (%s) was found.", name ) end
                                            self:AddToStack( scriptID, name, caller, entry.action == "run_action_list" )

                                            rAction, rWait, rDepth = self:GetPredictionFromAPL( dispName, packName, name, slot, rAction, rWait, rDepth, scriptID )
                                            if debug then self:Debug( "Returned from list (%s), current recommendation is %s (+%.2f).", name, rAction or "NoAction", rWait ) end

                                            self:PopStack()

                                            -- REVISIT THIS:  IF A RUN_ACTION_LIST CALLER IS NOT TIME SENSITIVE, DON'T BOTHER LOOPING THROUGH IT IF ITS CONDITIONS DON'T PASS.
                                            --[[ if entry.action == 'run_action_list' and not ts then
                                                if debug then self:Debug( "This entry was not time-sensitive; exiting loop." ) end
                                                break
                                            end ]]
                                        
                                        else
                                            if debug then self:Debug( "Action list (%s) not found.  Skipping.", name or "no name" ) end

                                        end
                                    end
                                end
                                
                            else
                                local usable = state:IsUsable()
                                if debug then self:Debug( "The action (%s) is %susable at (%.2f + %.2f).", entry.action, usable and "" or "NOT ", state.offset, state.delay ) end
                                
                                --[[ Tweak to avoid trying to use an item via Use Items when it already appears in the APL; not needed in BfA.

                                if ability.item then
                                    if listName == "Usable Items" then                                    
                                        if itemTried[ entry.action ] then
                                            usable = false
                                            if debug then self:Debug( "The action (%s) was previously tested; skipping.", entry.action ) end
                                        end
                                    else
                                        itemTried[ entry.action ] = true
                                    end
                                end ]]
                                
                                if usable then
                                    local waitValue = max( 0, rWait - state:ClashOffset( rAction ) )
                                    local readyFirst = state.delay - clash < waitValue

                                    if debug then self:Debug( " - the action is %sready before the current recommendation (at +%.2f vs. +%.2f).", readyFirst and "" or "NOT ", state.delay, waitValue ) end
                                    
                                    if readyFirst then
                                        local hasResources = true
                                        
                                        if hasResources then
                                            local aScriptPass = self:CheckStack()
                                            local channelPass = self:CheckChannel( entry.action, rWait )

                                            if not aScriptPass then
                                                if debug then self:Debug( " - this entry would not be reached at the current time via the current action list path (%.2f).", state.delay ) end

                                            else
                                                if not entry.criteria or entry.criteria == '' then 
                                                    if debug then
                                                        self:Debug( " - this entry has no criteria to test." ) 
                                                        if not channelPass then self:Debug( "   - however, criteria not met to break current channeled spell." )  end
                                                    end
                                                else 
                                                    aScriptPass = scripts:CheckScript( scriptID )

                                                    if debug then
                                                        self:Debug( " - this entry's criteria %s: %s", aScriptPass and "PASSES" or "FAILS", scripts:GetConditionsAndValues( scriptID ) )
                                                        if not channelPass then self:Debug( "   - however, criteria not met to break current channeled spell." )  end
                                                    end
                                                end
                                                aScriptPass = aScriptPass and channelPass

                                            end

                                            -- NEW:  If the ability's conditions didn't pass, but the ability can report on times when it should recheck, let's try that now.                                        
                                            if not aScriptPass then
                                                state.recheck( entry.action, script, Stack )

                                                if #state.recheckTimes == 0 then
                                                    if debug then self:Debug( "There were no recheck events to check." ) end
                                                else
                                                    local base_delay = state.delay

                                                    if debug then self:Debug( "There are " .. #state.recheckTimes .. " recheck events." ) end

                                                    local first_rechannel = 0

                                                    for i, step in pairs( state.recheckTimes ) do
                                                        local new_wait = base_delay + step

                                                        if new_wait >= 10 then
                                                            if debug then self:Debug( "Rechecking stopped at step #%d.  The recheck ( %.2f ) isn't ready within a reasonable time frame ( 10s ).", i, new_wait ) end
                                                            break
                                                        elseif waitValue <= base_delay + step + 0.05 then
                                                            if debug then self:Debug( "Rechecking stopped at step #%d.  The previously chosen ability is ready before this recheck would occur ( %.2f <= %.2f + 0.05 ).", i, waitValue, new_wait ) end
                                                            break
                                                        end

                                                        state.delay = base_delay + step

                                                        if self:CheckStack() then
                                                            aScriptPass = scripts:CheckScript( scriptID )
                                                            channelPass = self:CheckChannel( entry.action, rWait )

                                                            if debug then
                                                                self:Debug( "Recheck #%d ( +%.2f ) %s: %s", i, state.delay, aScriptPass and "MET" or "NOT MET", scripts:GetConditionsAndValues( scriptID ) )
                                                                if not channelPass then self:Debug( " - however, criteria not met to break current channeled spell." ) end
                                                            end

                                                            aScriptPass = aScriptPass and channelPass
                                                        else
                                                            if debug then self:Debug( "Unable to recheck #%d at %.2f, as APL conditions would not pass.", i, state.delay ) end
                                                        end

                                                        if aScriptPass then
                                                            if first_rechannel == 0 and state.channel and entry.action == state.channel then
                                                                first_rechannel = state.delay
                                                                if debug then self:Debug( "This is the currently channeled spell; it would be rechanneled at this time, will check end of channel.  " .. state.channel_remains ) end
                                                            elseif first_rechannel > 0 and not state.channel then
                                                                if debug then self:Debug( "Appears that the ability would be cast again at the end of the channel, stepping back to first rechannel point.  " .. state.channel_remains ) end
                                                                state.delay = first_rechannel
                                                                break
                                                            else break end
                                                        else state.delay = base_delay end
                                                    end
                                                end
                                            end

                                            -- Need to revisit this, make sure that lower priority abilities are only tested after the channel is over.
                                            if entry.action == state.channel then -- and aScriptPass then
                                                if ( aScriptPass and rWait <= state.player.channelEnd ) or waitValue <= state.player.channelEnd then
                                                    -- If a higher priority ability is selected, we should stop here.
                                                    if debug then self:Debug( "We have selected an ability that can break or finish our channel; stop here." ) end
                                                    stop = true
                                                end
                                            end

                                            if aScriptPass then
                                                if entry.action == 'potion' then
                                                    local potionName = state.args.potion or state.args.name
                                                    if not potionName or potionName == "default" then potionName = class.potion end
                                                    local potion = class.potions[ potionName ]

                                                    if debug then
                                                        if not potionName then self:Debug( "No potion name set." )
                                                        elseif not potion then self:Debug( "Unable to find potion '" .. potionName .. "'." ) end
                                                    end
                                                    
                                                    if potion then
                                                        slot.scriptType = 'simc'
                                                        slot.script = scriptID
                                                        slot.hook = caller

                                                        slot.display = dispName
                                                        slot.pack = packName
                                                        slot.list = listName
                                                        slot.listName = listName
                                                        slot.action = actID
                                                        slot.actionName = state.this_action

                                                        slot.texture = select( 10, GetItemInfo( potion.item ) )
                                                        slot.caption = entry.caption
                                                        slot.item = potion.item
                                                        
                                                        slot.wait = state.delay
                                                        slot.resource = state.GetResourceType( rAction )
                                                        
                                                        -- slot.indicator = ( entry.Indicator and entry.Indicator ~= 'none' ) and entry.Indicator
                                                            
                                                        rAction = state.this_action
                                                        rWait = state.delay

                                                        state.selectionTime = state.delay
                                                    end

                                                elseif entry.action == 'wait' then
                                                    -- local args = scripts:GetModifiers()
                                                    -- local args = ns.getModifiers( listID, actID )
                                                    local sec = state.args.sec or 0.5

                                                    if sec > 0 then
                                                        if waitBlock[ scriptID ] then
                                                            if debug then self:Debug( "Criteria for Wait action (" .. scriptID .. ") were met, but would be a loop.  Skipping." ) end
                                                        else
                                                            if debug then self:Debug( "Criteria for Wait action were met, advancing by %.2f and restarting this list.", sec ) end
                                                            -- NOTE, WE NEED TO TELL OUR INCREMENT FUNCTION ABOUT THIS...
                                                            waitBlock[ scriptID ] = true
                                                            state.advance( sec )
                                                            actID = 0
                                                        end
                                                    end

                                                elseif entry.action == 'pool_resource' then
                                                    if state.args.for_next == 1 then
                                                        -- Pooling for the next entry in the list.
                                                        local next_entry  = list[ actID + 1 ]
                                                        local next_action = next_entry and next_entry.action
                                                        local next_id     = next_action and class.abilities[ next_action ] and class.abilities[ next_action ].id

                                                        local extra_amt   = state.args.extra_amount or 0

                                                        local next_known  = next_action and state:IsKnown( next_action )
                                                        local next_usable = next_action and state:IsUsable( next_action )
                                                        local next_cost   = next_action and state.action[ next_action ].cost or 0
                                                        local next_res    = next_action and state.GetResourceType( next_action ) or class.primaryResource                                                    

                                                        if not next_entry then
                                                            if debug then self:Debug( "Attempted to Pool Resources for non-existent next entry in the APL.  Skipping." ) end
                                                        elseif not next_action or not next_id or next_id < 0 then
                                                            if debug then self:Debug( "Attempted to Pool Resources for invalid next entry in the APL.  Skipping." ) end
                                                        elseif not next_known then
                                                            if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but the next entry is not known.  Skipping.", next_action ) end
                                                        elseif not next_usable then
                                                            if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but the next entry is not usable.  Skipping.", next_action ) end                                               
                                                        else
                                                            local next_wait = max( state:TimeToReady( next_action, true ), state[ next_res ][ "time_to_" .. ( next_cost + extra_amt ) ] )

                                                            if next_wait <= 0 then
                                                                if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but there is no need to wait.  Skipping.", next_action ) end
                                                            elseif next_wait >= rWait then
                                                                if debug then self:Debug( "The currently chosen action ( %s ) is ready at or before the next action ( %.2fs <= %.2fs ).  Skipping.", ( rAction or "???" ), rWait, next_wait ) end
                                                            elseif time_ceiling and next_wait >= time_ceiling - state.now - state.offset then
                                                                if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but we would exceed our time ceiling in %.2fs.  Skipping.", next_action, next_wait ) end
                                                            elseif next_wait >= 10 then
                                                                if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but we'd have to wait much too long ( %.2f ).  Skipping.", next_action, next_wait ) end
                                                            else
                                                                -- Pad the wait value slightly, to make sure the resource is actually generated.
                                                                next_wait = next_wait + 0.01
                                                                state.offset = state.offset + next_wait

                                                                aScriptPass = not next_entry.criteria or next_entry.criteria == '' or scripts:CheckScript( packName .. ':' .. listName .. ':' .. ( actID + 1 ) )

                                                                if not aScriptPass then
                                                                    if debug then self:Debug( "Attempted to Pool Resources for Next Entry ( %s ), but its conditions would not be met.  Skipping.", next_action ) end
                                                                    state.offset = state.offset - next_wait
                                                                else
                                                                    if debug then self:Debug( "Pooling Resources for Next Entry ( %s ), delaying by %.2f ( extra %d ).", next_action, next_wait, extra_amt ) end
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

                                                    --[[ if entry.PoolForNext or state.args.for_next == 1 then
                                                        if debug then self:Debug( "Pool Resource is not used in the Predictive Engine; ignored." ) end
                                                    end ]]

                                                else
                                                    slot.scriptType = 'simc'
                                                    slot.script = scriptID
                                                    slot.hook = caller

                                                    slot.display = dispName
                                                    slot.pack = packName
                                                    slot.list = listName
                                                    slot.listName = listName
                                                    slot.action = actID
                                                    slot.actionName = state.this_action

                                                    slot.caption = entry.caption
                                                    slot.texture = ability.texture
                                                    slot.indicator = ability.indicator

                                                    slot.wait = state.delay

                                                    slot.resource = state.GetResourceType( rAction )
                                                    
                                                    
                                                    rAction = state.this_action
                                                    rWait = state.delay

                                                    state.selectionTime = state.delay

                                                    if debug then
                                                        self:Debug( "Action chosen:  %s at %.2f!", rAction, state.delay )
                                                    end

                                                    if entry.cycle_targets == 1 and state.active_enemies > 1 then
                                                        if not state.settings.cycle then
                                                            if debug then self:Debug( "This entry would cycle through targets but target cycling is disabled." ) end
                                                        else
                                                            if ability and ability.cycle and state.dot[ ability.cycle ].up and state.active_dot[ ability.cycle ] < ( entry.max_cycle_targets or state.active_enemies ) then
                                                                slot.indicator = 'cycle'
                                                            elseif module and module.cycle then
                                                                slot.indicator = module.cycle()
                                                            end
                                                        end
                                                    end
                                                end
                                            end                                                    
                                        end
                                    end
                                end
                                
                                if rWait == 0 or force_channel then break end

                            end
                        end
                    end
                end
            else
                if debug then self:Debug( "\nEntry #%d in list ( %s ) is not set or not enabled.  Skipping.", actID, listName ) end
            end
            
            actID = actID + 1
            
        end
        
    else
        if debug then self:Debug( "ListActive: N (%s-%s)", packName, listName ) end
    end

    local scriptID = listStack[ listName ]
    listStack[ listName ] = nil
    if listCache[ scriptID ] then wipe( listCache[ scriptID ] ) end
    if listValue[ scriptID ] then wipe( listValue[ scriptID ] ) end

    return rAction, rWait, rDepth
end


function Hekili:GetNextPrediction( dispName, packName, slot )
    
    local debug = self.ActiveDebug
    
    -- This is the entry point for the prediction engine.
    -- Any cache-wiping should happen here.
    wipe( Stack )
    wipe( Block )
    wipe( InUse )

    wipe( listStack )    
    wipe( listIsBad )    
    wipe( waitBlock )

    for k, v in pairs( listCache ) do wipe( v ) end
    for k, v in pairs( listValue ) do wipe( v ) end

    self:ResetSpellCaches()

    local display = rawget( self.DB.profile.displays, dispName )
    local pack = rawget( self.DB.profile.packs, packName )

    local action, wait, depth = nil, 60, 0
    
    state.min_recheck = 0
    state.this_action = nil

    state.selectionTime = 60

    if pack.lists.precombat then
        local list = pack.lists.precombat
        local listName = "precombat"
        
        if debug then self:Debug( "\nProcessing precombat action list [ %s - %s ].", packName, listName ) end        
        action, wait, depth = self:GetPredictionFromAPL( dispName, packName, "precombat", slot, action, wait, depth )
        if debug then self:Debug( "Completed precombat action list [ %s - %s ].", packName, listName ) end
    else
        if debug then
            if state.time > 0 then
                self:Debug( "Precombat APL not processed because combat time is %.2f.", state.time )
            end
        end
    end

    if pack.lists.default and wait > 0 then
        local list = pack.lists.default
        local listName = "default"

        if debug then self:Debug("\nProcessing default action list [ %s - %s ].", packName, listName ) end
        action, wait, depth = self:GetPredictionFromAPL( dispName, packName, "default", slot, action, wait, depth )
        if debug then self:Debug( "Completed default action list [ %s - %s ].", packName, listName ) end
    end
    
    if debug then self:Debug( "Recommendation is %s at %.2f + %.2f.", action or "NO ACTION", state.offset, wait ) end
    
    return action, wait, depth
end


local pvpZones = {
    arena = true,
    pvp = true
}


function Hekili:GetDisplayByName( name )
    return rawget( self.DB.profile.displays, name ) and name or nil
end


local tSlot = {}
local iterationSteps = {}

local lastHooks = {}
local lastCount = {}


function Hekili:ProcessHooks( dispName, packName )

    if self.Pause then return end

    dispName = dispName or "Primary"
    local display = rawget( self.DB.profile.displays, dispName )

    local specID = state.spec.id
    if not specID then return end

    local spec = rawget( self.DB.profile.specs, specID )
    if not spec then return end

    local UI = ns.UI.Displays[ dispName ]
    local Queue = UI.Recommendations

    if Queue then
        for k, v in pairs( Queue ) do
            for l, w in pairs( v ) do
                if type( Queue[ k ][ l ] ) ~= 'table' then
                    Queue[ k ][ l ] = nil
                end
            end
        end
    end

    if dispName == "AOE" and self:GetToggleState( "mode" ) == "reactive" then
        if self:GetNumTargets() < ( spec and spec.aoe or 3 ) then
            UI.RecommendationsStr = nil
            UI.NewRecommendations = true
            return
        end
    end

    local checkstr = nil

    local packName = packName or spec.package
    local pack = rawget( self.DB.profile.packs, packName )

    if not pack then
        UI.RecommendationsStr = nil
        UI.NewRecommendations = true 
        return 
    end

    state.system.specID   = specID
    state.system.specInfo = spec
    state.system.packName = packName
    state.system.packInfo = pack
    state.system.display  = dispName
    state.system.dispInfo = display

    state.reset( dispName )

    local debug = self.ActiveDebug
    
    local gcd_length = state.gcd

    if debug then
        self:SetupDebug( dispName )
        self:Debug( "*** START OF NEW DISPLAY: %s ***", dispName ) 
    end

    local numRecs = display.numIcons or 4

    if display.flash.enabled and display.flash.suppress then
        numRecs = 1
    end

    for i = 1, numRecs do

        local chosen_action
        local chosen_depth = 0
        
        Queue[ i ] = Queue[ i ] or {}        
        local slot = Queue[ i ]
        slot.index = i
        
        local attempts = 0
        local iterated = false
        
        if debug then self:Debug( "\n[ ** ] Checking for recommendation #%d ( time offset: %.2f, remaining GCD: %.2f ).", i, state.offset, state.cooldown.global_cooldown.remains ) end
        
        if debug then
            for k in pairs( class.resources ) do
                self:Debug( "[ ** ] %s, %d / %d", k, state[ k ].current, state[ k ].max )
            end
            if state.channeling then
                self:Debug( "[ ** ] Currently channeling ( %s ) until ( %.2f ).", state.player.channelSpell, state.player.channelEnd - state.query_time )
            end
        end

        state.delay = 0

        local action, wait, depth = self:GetNextPrediction( dispName, packName, slot )

        local gcd_remains = state.cooldown.global_cooldown.remains
        state.delay = wait

        -- if debug then self:Debug( "Prediction engine would recommend %s at +%.2fs (%.2fs).\n", action or "NO ACTION", wait or 60, state.offset + state.delay ) end
        if debug then self:Debug( "Recommendation #%d is %s at %.2fs (%.2fs).", i, action or "NO ACTION", wait or 60, state.offset + state.delay ) end
        
        if action then
            if debug then scripts:ImplantDebugData( slot ) end
            
            slot.time = state.offset + wait
            slot.exact_time = state.now + state.offset + wait
            slot.delay = wait
            slot.since = i > 1 and slot.time - Queue[ i - 1 ].time or 0
            slot.resources = slot.resources or {}
            slot.depth = chosen_depth

            checkstr = checkstr and ( checkstr .. ':' .. action ) or action
            
            slot.keybind = self:GetBindingForAction( action, not display.keybindings.lowercase == true )
            slot.resource_type = state.GetResourceType( action )

            for k,v in pairs( class.resources ) do
                slot.resources[ k ] = state[ k ].current 
            end                            
            
            if i < display.numIcons then

                -- Advance through the wait time.
                if state.delay > 0 then state.advance( state.delay ) end

                local ability = class.abilities[ action ]
                
                -- Start the GCD.
                if ability.gcd ~= 'off' and state.cooldown.global_cooldown.remains == 0 then
                    state.setCooldown( 'global_cooldown', state.gcd.execute )
                end

                state.stopChanneling()
                
                -- Advance the clock by cast_time.
                if ability.cast > 0 and not ability.channeled then
                    state.advance( ability.cast )
                end

                local cooldown = ability.cooldown
                
                -- Put the action on cooldown. (It's slightly premature, but addresses CD resets like Echo of the Elements.)
                -- if ability.charges and ability.charges > 1 and ability.recharge > 0 then
                if ability.charges and ability.recharge > 0 then
                    state.spendCharges( action, 1 )
                    
                elseif action ~= 'global_cooldown' then
                    state.setCooldown( action, cooldown )
                end

                state.cycle = slot.indicator == 'cycle'
                
                -- Spend resources.
                ns.spendResources( action )
                
                -- Perform the action.
                ns.runHandler( action )

                if ability.item then
                    state.putTrinketsOnCD( cooldown / 6 )
                end

                -- Complete the channel.
                if ability.cast > 0 and ( ability.channeled and not ability.breakable ) then -- class.resetCastExclusions[ ability ] then
                    state.advance( ability.cast )
                end
                
                -- Move the clock forward if the GCD hasn't expired.
                if state.cooldown.global_cooldown.remains > 0 then
                    state.advance( state.cooldown.global_cooldown.remains )
                end
            end
            
        else
            for n = i, numRecs do
                action = action or ''
                checkstr = checkstr and ( checkstr .. ':' .. action ) or action
                slot[n] = nil
            end
            -- if i == 1 and not self.ActiveDebug then self:TogglePause() end -- use for disappearing display debugging.
            break
        end
        
    end

    UI.NewRecommendations = true
    UI.RecommendationsStr = checkstr
    
end
ns.cpuProfile.ProcessHooks = Hekili.ProcessHooks


function Hekili_GetRecommendedAbility( display, entry )

    entry = entry or 1
    
    if not rawget( Hekili.DB.profile.displays, display ) then
        return nil, "Display not found."
    end
    
    if not ns.queue[ display ] then
        return nil, "No queue for that display."
    end
    
    if not ns.queue[ display ][ entry ] or not ns.queue[ display ][ entry ].actionName then
        return nil, "No entry #" .. entry .. " for that display."
    end
    
    return class.abilities[ ns.queue[ display ][ entry ].actionName ].id
    
end


function Hekili:DumpProfileInfo()
    local output = ""

    for k, v in pairs( ns.cpuProfile ) do
        local usage, calls = GetFunctionCPUUsage( v, true )

        if usage then
            usage = usage / 1000
            output = format(    "%s\n" ..
                                " [ %5d ] %-20s %12.2f %12.2f", output, calls, k, usage, usage / ( calls == 0 and 1 or calls ) )
        else
            output = output(    "%s\nNo information for function `%s'.", output, k )
        end
    end

    print( output )
end
