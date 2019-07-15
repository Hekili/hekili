-- Events.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State
local TTD = ns.TTD

local formatKey = ns.formatKey
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local getSpecializationInfo = ns.getSpecializationInfo
local getSpecializationKey = ns.getSpecializationKey
local GroupMembers = ns.GroupMembers

local abs = math.abs
local lower, match, upper = string.lower, string.match, string.upper
local string_format = string.format
local insert, remove, sort, unpack, wipe = table.insert, table.remove, table.sort, table.unpack, table.wipe


local GetItemInfo = ns.CachedGetItemInfo


-- Abandoning AceEvent in favor of darkend's solution from:
-- http://andydote.co.uk/2014/11/23/good-design-in-warcraft-addons.html
-- This should be a bit friendlier for our modules.

local events = CreateFrame( "Frame" )
local handlers = {}
local unitEvents = CreateFrame( "Frame" )
local unitHandlers = {}
local itemCallbacks = {}

local timerRecount = 0

local activeDisplays = {}

function Hekili:GetActiveDisplays()
    return activeDisplays
end


function ns.StartEventHandler()
    events:SetScript( "OnEvent", function( self, event, ... )
        local eventHandlers = handlers[ event ]

        if not eventHandlers then return end

        for i, handler in pairs( eventHandlers ) do
            handler( event, ... )
        end
    end )

    unitEvents:SetScript( "OnEvent", function( self, event, ... )
        local eventHandlers = unitHandlers[ event ]

        if not eventHandlers then return end

        for i, handler in pairs( eventHandlers ) do
            handler( event, ... )
        end
    end )

    events:SetScript( "OnUpdate", function( self, elapsed )
        Hekili.freshFrame = true
        timerRecount = timerRecount - elapsed

        if timerRecount < 0 then
            ns.recountTargets()
            if ns.targetsChanged() then Hekili:ForceUpdate( "TARGET_COUNT_CHANGED" ) end
            timerRecount = 0.1
        end
    end )

    Hekili:RunItemCallbacks()
end


function ns.StopEventHandler()
    events:SetScript( "OnEvent", nil )
    unitEvents:SetScript( "OnEvent", nil )

    events:SetScript( "OnUpdate", nil )
end


ns.RegisterEvent = function( event, handler )

    handlers[ event ] = handlers[ event ] or {}
    insert( handlers[ event ], handler )

    events:RegisterEvent( event )

end
local RegisterEvent = ns.RegisterEvent


function ns.UnregisterEvent( event, handler )
    local hands = handlers[ event ]

    if not hands then return end

    for i = #hands, 1, -1 do
        if hands[i] == handler then
            remove( hands, i )
        end
    end
end


-- For our purposes, all UnitEvents are player/target oriented.
ns.RegisterUnitEvent = function( event, handler )

    unitHandlers[ event ] = unitHandlers[ event ] or {}
    insert( unitHandlers[ event ], handler )

    unitEvents:RegisterUnitEvent( event, 'player', 'target' )

end
local RegisterUnitEvent = ns.RegisterUnitEvent


function ns.UnregisterUnitEvent( event, handler )
    local hands = unitHandlers[ event ]

    if not hands then return end

    for i = #hands, 1, -1 do
        if hands[i] == handler then
            remove( hands, i )
        end
    end
end


ns.FeignEvent = function( event, ... )
    local eventHandlers = handlers[ event ]

    if not eventHandlers then return end

    for i, handler in pairs( eventHandlers ) do
        handler( event, ... )
    end
end


RegisterEvent( "GET_ITEM_INFO_RECEIVED", function( event, itemID, success )
    local callbacks = itemCallbacks[ itemID ]

    if callbacks then
        for i, func in ipairs( callbacks ) do
            func( success )
            callbacks[ i ] = nil
        end

        itemCallbacks[ itemID ] = nil
    end
end )

function Hekili:ContinueOnItemLoad( itemID, func )
    local callbacks = itemCallbacks[ itemID ] or {}
    insert( callbacks, func )
    itemCallbacks[ itemID ] = callbacks

    C_Item.RequestLoadItemDataByID( itemID )        
end

function Hekili:RunItemCallbacks()
    for item, callbacks in pairs( itemCallbacks ) do
        for i = #callbacks, 1, -1 do
            if callbacks[ i ]( true ) then remove( callbacks, i ) end
        end

        if #callbacks == 0 then
            itemCallbacks[ item ] = nil
        end
    end
end


RegisterEvent( "DISPLAY_SIZE_CHANGED", function () Hekili:BuildUI() end )


do    
    local itemAuditComplete = false

    local auditItemNames = function ()
        local failure = false

        for key, ability in pairs( class.abilities ) do
            if ability.recheck_name then
                local name, link = GetItemInfo( ability.item )

                if name then
                    ability.name = name
                    ability.texture = nil
                    ability.link = link
                    ability.elem.name = name
                    ability.elem.texture = select( 10, GetItemInfo( ability.item ) )

                    class.abilities[ name ] = ability
                    ability.recheck_name = nil
                else
                    failure = true
                end
            end
        end

        if failure then
            C_Timer.After( 1, ns.auditItemNames )
        else
            ns.ReadKeybindings()
            itemAuditComplete = true
        end
    end
end


RegisterEvent( "PLAYER_ENTERING_WORLD", function ()
    Hekili.PLAYER_ENTERING_WORLD = true
    Hekili:SpecializationChanged()
    Hekili:RestoreDefaults()

    ns.checkImports()
    ns.updateGear()
    ns.restoreDefaults( nil, true )

    if state.combat == 0 and InCombatLockdown() then
        state.combat = GetTime() - 0.01
        Hekili:UpdateDisplayVisibility()
    end

    Hekili:BuildUI()
end )


RegisterUnitEvent( "PLAYER_SPECIALIZATION_CHANGED", function ( event, unit )
    if unit == 'player' then
        Hekili:SpecializationChanged()
        Hekili:ForceUpdate( event )
    end
end )


-- Hide when going into the barbershop.
RegisterEvent( "BARBER_SHOP_OPEN", function ()
    Hekili.Barber = true
end )

RegisterEvent( "BARBER_SHOP_CLOSE", function ()
    Hekili.Barber = false
end )


-- Update visibility when getting on/off a taxi.
RegisterEvent( "PLAYER_CONTROL_LOST", function ()
    Hekili:After( 0.1, Hekili.UpdateDisplayVisibility, Hekili )
end )

RegisterEvent( "PLAYER_CONTROL_GAINED", function ()
    Hekili:After( 0.1, Hekili.UpdateDisplayVisibility, Hekili )
end )


function ns.updateTalents()

    for k, _ in pairs( state.talent ) do
        state.talent[ k ].enabled = false
    end

    -- local specGroup = GetSpecialization()

    for k, v in pairs( class.talents ) do
        local _, name, _, enabled, _, sID, _, _, _, _, known = GetTalentInfoByID( v, 1 )

        if not name then
            -- We probably used a spellID.
            enabled = IsPlayerSpell( v )
        end

        enabled = enabled or known

        if rawget( state.talent, k ) then
            state.talent[ k ].enabled = enabled
        else
            state.talent[ k ] = { enabled = enabled }
        end
    end

    for k, _ in pairs( state.pvptalent ) do
        state.pvptalent[ k ]._enabled = false
    end

    for k, v in pairs( class.pvptalents ) do
        local _, name, _, enabled, _, sID, _, _, _, known = GetPvpTalentInfoByID( v, 1 )

        if not name then
            enabled = IsPlayerSpell( v )
        end

        enabled = enabled or known

        if rawget( state.pvptalent, k ) then
            state.pvptalent[ k ]._enabled = enabled
        else
            state.pvptalent[ k ] = {
                _enabled = enabled
            }
        end
    end

end


--[[ RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED", function ( event )
    ns.updateTalents()

    Hekili:ForceUpdate( event )
end ) ]]



-- TBD:  Consider making `boss' a check to see whether the current unit is a boss# unit instead.
RegisterEvent( "ENCOUNTER_START", function () state.inEncounter = true end )
RegisterEvent( "ENCOUNTER_END", function () state.inEncounter = false end )


do
    local loc = ItemLocation.CreateEmpty()

    local GetAllTierInfoByItemID = C_AzeriteEmpoweredItem.GetAllTierInfoByItemID
    local GetAllTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo
    local GetPowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo
    local IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
    local IsPowerSelected = C_AzeriteEmpoweredItem.IsPowerSelected

    local MAX_INV_SLOTS = 19

    function ns.updatePowers()
        local p = state.azerite

        for k, v in pairs( p ) do
            v.rank = 0
        end

        if next( class.powers ) == nil then
            C_Timer.After( 3, ns.updatePowers )
            return
        end

        for slot = 1, MAX_INV_SLOTS do
            local id = GetInventoryItemID( "player", slot )

            if id and IsAzeriteEmpoweredItemByID( id ) then
                loc:SetEquipmentSlot( slot )
                local tiers = GetAllTierInfo( loc )

                for tier, tierInfo in ipairs( tiers ) do
                    for _, power in ipairs( tierInfo.azeritePowerIDs ) do
                        local pInfo = GetPowerInfo( power )

                        if IsPowerSelected( loc, power ) then
                            local name = class.powers[ pInfo.spellID ]
                            if not name then
                                Hekili:Error( "Missing Azerite Power info for #" .. pInfo.spellID .. ": " .. GetSpellInfo( pInfo.spellID ) .. "." )
                            else
                                p[ name ] = rawget( p, name ) or { rank = 0 }
                                p[ name ].rank = p[ name ].rank + 1
                            end
                        end
                    end
                end
            end
        end

        loc:Clear()
    end

    Hekili:ProfileCPU( "updatePowers", ns.updatePowers )


    -- Essences
    if select(4, GetBuildInfo()) >= 80200 then
        local AE = C_AzeriteEssence
        local GetMilestoneEssence, GetEssenceInfo = AE.GetMilestoneEssence, AE.GetEssenceInfo
        local milestones = { 115, 116, 117 }

        local essenceKeys = {
            [2]  = "azeroths_undying_gift",
            [3]  = "sphere_of_suppression",
            [4]  = "worldvein_resonance",
            [5]  = "essence_of_the_focusing_iris",
            [6]  = "purification_protocol",
            [7]  = "anima_of_life_and_death",
            [12] = "the_crucible_of_flame",
            [13] = "nullification_dynamo",
            [14] = "condensed_lifeforce",
            [15] = "ripple_in_space",
            [17] = "everrising_tide",
            [18] = "artifice_of_time",
            [19] = "well_of_existence",
            [20] = "lifebinders_invocation",
            [21] = "vitality_conduit",
            [22] = "vision_of_perfection",
            [23] = "blood_of_the_enemy",
            [25] = "aegis_of_the_deep",
            [27] = "memory_of_lucid_dreams",
            [28] = "the_unbound_force",
            [32] = "conflict_and_strife"
        }

        local essenceMajors = {
            aegis_of_the_deep = "aegis_of_the_deep",
            anima_of_life_and_death = "anima_of_death",
            -- artifice_of_time = "",
            azeroths_undying_gift = "azeroths_undying_gift",
            blood_of_the_enemy = "blood_of_the_enemy",
            condensed_lifeforce = "guardian_of_azeroth",
            --conflict_and_strife = "",
            essence_of_the_focusing_iris = "focused_azerite_beam",
            -- everrising_tide = "",
            -- lifebinders_invocation = "",
            memory_of_lucid_dreams = "memory_of_lucid_dreams",
            nullification_dynamo = "empowered_null_barrier",
            purification_protocol = "purifying_blast",
            ripple_in_space = "ripple_in_space",
            sphere_of_suppression = "suppressing_pulse",
            the_crucible_of_flame = "concentrated_flame",
            the_unbound_force = "the_unbound_force",
            -- vision_of_perfection = "",
            -- vitality_conduit = "",
            -- well_of_existence = "",
            worldvein_resonance = "worldvein_resonance",
        }

        for _, key in pairs( essenceKeys ) do
            state.essence[ key ] = { rank = 0, major = false }
        end


        function ns.updateEssences()
            local e = state.essence

            for k, v in pairs( e ) do
                v.rank = 0
            end

            class.active_essence = nil

            for i, ms in ipairs( milestones ) do
                local essence = GetMilestoneEssence( ms )

                if essence then
                    local info = GetEssenceInfo( essence )

                    if info then
                        local key = essenceKeys[ info.ID ]
                        
                        e[ key ].rank = info.rank
                        e[ key ].minor = true
                        
                        if i == 1 then                            
                            e[ key ].major = true
                            class.active_essence = essenceMajors[ key ]
                        end
                    end
                end
            end
        end

        ns.updateEssences()
    end
end


do
    local gearInitialized = false

    function Hekili:UpdateUseItems()
        local itemList = class.itemPack.lists.items
        wipe( itemList )

        if #state.items > 0 then
            for i, item in ipairs( state.items ) do
                if not self:IsItemScripted( item ) then
                    insert( itemList, {
                        action = item,
                        enabled = true,
                        criteria = "( ! settings.boss || boss ) & " ..
                            "( settings.targetMin = 0 || active_enemies >= settings.targetMin ) & " ..
                            "( settings.targetMax = 0 || active_enemies <= settings.targetMax )"
                    } )
                end
            end
        end
            
        if class.active_essence then
            if not self:IsEssenceScripted( class.active_essence ) then
                insert( itemList, 1, {
                    action = class.active_essence,
                    enabled = true,
                    criteria = "( ! settings.boss || boss ) & " ..
                        "( settings.targetMin = 0 || active_enemies >= settings.targetMin ) & " ..
                        "( settings.targetMax = 0 || active_enemies <= settings.targetMax )"
                } )
            end
        end

        self:LoadItemScripts()
    end


    local wasWearing = {}

    function ns.updateGear()
        for thing in pairs( state.set_bonus ) do
            state.set_bonus[ thing ] = 0
        end

        wipe( wasWearing )

        for i, item in ipairs( state.items ) do
            wasWearing[i] = item
        end

        wipe( state.items )

        for set, items in pairs( class.gear ) do
            state.set_bonus[ set ] = 0
            for item, _ in pairs( items ) do
                if IsEquippedItem( GetItemInfo( item ) ) then
                    state.set_bonus[ set ] = state.set_bonus[ set ] + 1
                end
            end
        end

        local ItemBuffs = LibStub( "LibItemBuffs-1.0", true )
        local T1 = GetInventoryItemID( "player", 13 )

        if ItemBuffs and T1 then
            local t1buff = ItemBuffs:GetItemBuffs( T1 )

            if type(t1buff) == 'table' then t1buff = t1buff[1] end

            class.auras.trinket1 = class.auras[ t1buff ]
            state.trinket.t1.id = T1
        else
            state.trinket.t1.id = 0
        end

        local T2 = GetInventoryItemID( "player", 14 )

        if ItemBuffs and T2 then
            local t2buff = ItemBuffs:GetItemBuffs( T2 )

            if type(t2buff) == 'table' then t2buff = t2buff[1] end

            class.auras.trinket2 = class.auras[ t2buff ]
            state.trinket.t2.id = T2
        else
            state.trinket.t2.id = 0
        end

        for i = 1, 19 do
            local item = GetInventoryItemID( 'player', i )

            if item then
                state.set_bonus[ item ] = 1
                local key = GetItemInfo( item )
                if key then
                    key = formatKey( key )
                    state.set_bonus[ key ] = 1
                    gearInitialized = true
                end

                local usable = class.itemMap[ item ]
                if usable then insert( state.items, usable ) end
            end
        end

        -- Improve Pocket-Sized Computronic Device.
        if state.equipped.pocketsized_computation_device then
            local tName = GetItemInfo( 167555 )
            local redName, redLink = GetItemGem( tName, 1 )
            
            if redName and redLink then
                local redID = tonumber( redLink:match("item:(%d+)") )
                local action = class.itemMap[ redID ]

                if action then
                    state.set_bonus[ action ] = 1
                    state.set_bonus[ redID ] = 1
                    class.abilities.pocketsized_computation_device = class.abilities[ action ]
                    class.abilities[ tName ] = class.abilities[ action ]
                    insert( state.items, "pocketsized_computation_device" )
                end
            else
                class.abilities.pocketsized_computation_device = class.abilities.inactive_red_punchcard
                class.abilities[ tName ] = class.abilities.inactive_red_punchcard
            end
        end

        ns.updatePowers()
        ns.updateTalents()

        local lastEssence = class.active_essence
        ns.updateEssences()

        local sameItems = #wasWearing == #state.items

        if sameItems then
            for i = 1, #state.items do
                if wasWearing[i] ~= state.items[i] then
                    sameItems = false
                    break
                end
            end
        end

        if not sameItems or class.active_essence ~= lastEssence then
            Hekili:UpdateUseItems()
        end

        if not gearInitialized then
            C_Timer.After( 3, ns.updateGear )
        else
            ns.ReadKeybindings()
        end

    end
end


RegisterEvent( "PLAYER_EQUIPMENT_CHANGED", function()
    ns.updateGear()
end )


-- Update Azerite Essence Data.
do
    local azeriteEvents = {
        "AZERITE_ESSENCE_UPDATE",
        "AZERITE_ESSENCE_MILESTONE_UNLOCKED",
        "AZERITE_ESSENCE_FORGE_CLOSE",
        "AZERITE_ESSENCE_CHANGED",
        "AZERITE_ESSENCE_ACTIVATED",
        "AZERITE_ESSENCE_ACTIVATION_FAILED"
    }

    for i, event in pairs( azeriteEvents ) do
        RegisterEvent( event, ns.updateGear )
    end
end


RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
    state.combat = GetTime() - 0.01
    Hekili:ForceUpdate() -- Force update on entering combat since OOC refresh can be very slow (0.5s).
end )


RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    -- ns.updateGear()
    state.combat = 0

    state.swings.mh_actual = 0
    state.swings.oh_actual = 0

    Hekili:ReleaseHolds( true )
end )


local dynamic_keys = setmetatable( {}, {
    __index = function( t, k, v )
        local name = GetSpellInfo( k )
        local key = name and formatKey( name ) or k
        t[k] = key
        return t[k]
    end
} )


ns.castsOff = { 'no_action', 'no_action', 'no_action', 'no_action', 'no_action' }
ns.castsOn = { 'no_action', 'no_action', 'no_action', 'no_action', 'no_action' }
ns.castsAll = { 'no_action', 'no_action', 'no_action', 'no_action', 'no_action' }

local castsOn, castsOff, castsAll = ns.castsOn, ns.castsOff, ns.castsAll


function state:AddToHistory( spellID, destGUID )
    local ability = class.abilities[ spellID ]
    local key = ability and ability.key or dynamic_keys[ spellID ]

    local now = GetTime()
    local player = self.player

    player.lastcast = key
    player.casttime = now

    if ability and not ability.essence then
        local history = self.prev.history
        insert( history, 1, key )
        history[6] = nil

        if ability.gcd ~= "off" then
            history = self.prev_gcd.history
            player.lastgcd = key
            player.lastgcdtime = now
        else
            history = self.prev_off_gcd.history
            player.lastoffgcd = key
            player.lastoffgcdtime = now
        end
        insert( history, 1, key )
        history[6] = nil

        ability.realCast = now
        ability.realUnit = destGUID
    end
end


local lowLevelWarned = false

-- Need to make caching system.
RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( event, unit, _, spellID )
    if UnitIsUnit( unit, "player" ) then
        if lowLevelWarned == false and UnitLevel( "player" ) < 100 then
            Hekili:Notify( "Hekili is designed for current content.\nUse below level 100 at your own risk.", 5 )
            lowLevelWarned = true
        end

        local ability = class.abilities[ spellID ]

        if ability and state.holds[ ability.key ] then
            Hekili:RemoveHold( ability.key, true )
        end
    end
    -- Hekili:ForceUpdate( event )
end )


RegisterEvent( "UNIT_SPELLCAST_SENT", function (self, event, unit, target, castID, spellID)
    state.cast_target = UnitGUID( target )
end )


local power_tick_data = {
    focus_avg = 0.10,
    focus_ticks = 1,

    energy_avg = 0.10,
    energy_ticks = 1,
}


local spell_names = setmetatable( {}, {
    __index = function( t, k )
        t[ k ] = GetSpellInfo( k )
        return t[ k ]
    end
} )


local lastPowerUpdate = 0

local function UNIT_POWER_FREQUENT( event, unit, power )

    if not UnitIsUnit( unit, "player" ) then return end

    if power == "FOCUS" and rawget( state, "focus" ) then
        local now = GetTime()
        local elapsed = now - ( state.focus.last_tick or 0 )

        elapsed = elapsed > power_tick_data.focus_avg * 1.5 and power_tick_data.focus_avg or elapsed

        if elapsed > 0.075 then
            power_tick_data.focus_avg = ( elapsed + ( power_tick_data.focus_avg * power_tick_data.focus_ticks ) ) / ( power_tick_data.focus_ticks + 1 )
            power_tick_data.focus_ticks = power_tick_data.focus_ticks + 1
            state.focus.last_tick = now
        end

    elseif power == "ENERGY" and rawget( state, "energy" ) then
        local now = GetTime()
        local elapsed = min( 0.12, now - ( state.energy.last_tick or 0 ) )

        elapsed = elapsed > power_tick_data.energy_avg * 1.5 and power_tick_data.energy_avg or elapsed

        if elapsed > 0.075 then
            power_tick_data.energy_avg = ( elapsed + ( power_tick_data.energy_avg * power_tick_data.energy_ticks ) ) / ( power_tick_data.energy_ticks + 1 )
            power_tick_data.energy_ticks = power_tick_data.energy_ticks + 1
            state.energy.last_tick = now
        end

    end

    if GetTime() - lastPowerUpdate > 0.1 then
        Hekili:ForceUpdate( event )
        lastPowerUpdate = GetTime()
    end
end
Hekili:ProfileCPU( "UNIT_POWER_UPDATE", UNIT_POWER_FREQUENT )

RegisterUnitEvent( "UNIT_POWER_UPDATE", UNIT_POWER_FREQUENT )


local autoAuraKey = setmetatable( {}, {
    __index = function( t, k )
        local name = GetSpellInfo( k )

        if not name then return end

        local key = formatKey( name )

        if class.auras[ key ] then
            local i = 1

            while ( true ) do 
                local new = key .. '_' .. i

                if not class.auras[ new ] then
                    key = new
                    break
                end

                i = i + 1
            end
        end

        -- Store the aura and save the key if we can.
        if ns.addAura then
            ns.addAura( key, k, 'name', name )
            t[k] = key
        end

        return t[k]
    end
} )


RegisterUnitEvent( "UNIT_AURA", function( event, unit )
    if UnitIsUnit( unit, 'player' ) and state.player.updated then
        Hekili.ScrapeUnitAuras( "player" )
        state.player.updated = false

    elseif UnitIsUnit( unit, "target" ) and state.target.updated then
        Hekili.ScrapeUnitAuras( "target" )
        state.target.updated = false
    
    end
end )


RegisterEvent( "PLAYER_TARGET_CHANGED", function( event )
    Hekili.ScrapeUnitAuras( "target", true )
    state.target.updated = false

    Hekili:ForceUpdate( event, true )
end )


RegisterEvent( "PLAYER_STARTED_MOVING", function( event ) Hekili:ForceUpdate( event ) end )
RegisterEvent( "PLAYER_STOPPED_MOVING", function( event ) Hekili:ForceUpdate( event ) end )


--[[ local function HandleCasts( event, unit )
    Hekili:ForceUpdate( event, unit )
end 

RegisterUnitEvent( "UNIT_SPELLCAST_START", HandleCasts )
RegisterUnitEvent( "UNIT_SPELLCAST_INTERRUPTED", HandleCasts )
RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", HandleCasts )
RegisterUnitEvent( "UNIT_SPELLCAST_STOP", HandleCasts )
RegisterUnitEvent( "UNIT_SPELLCAST_FAILED", HandleCasts )
RegisterUnitEvent( "UNIT_SPELLCAST_FAILED_QUIET", HandleCasts ) ]]


--[[ RegisterEvent( "SPELL_UPDATE_COOLDOWN", function()
    local gcdStart = GetSpellCooldown( 61304 )
    if state.gcd.lastStart ~= gcdStart then
        state.gcd.lastStart = max( state.gcd.lastStart, gcdStart )
        Hekili:ForceUpdate()
    end
end ) ]]


local cast_events = {
    SPELL_CAST_START        = true,
    SPELL_CAST_FAILED       = true,
    SPELL_CAST_SUCCESS      = true
}


local aura_events = {
    SPELL_AURA_APPLIED      = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REFRESH      = true,
    SPELL_AURA_REMOVED      = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_BROKEN       = true,
    SPELL_AURA_BROKEN_SPELL = true,
    SPELL_CAST_SUCCESS      = true -- it appears you can refresh stacking buffs w/o a SPELL_AURA_x event.
}


local dmg_events = {
    SPELL_DAMAGE            = true,
    SPELL_MISSED            = true,
    SPELL_PERIODIC_DAMAGE   = true,
    SPELL_PERIODIC_MISSED   = true,
    SWING_DAMAGE            = true,
    SWING_MISSED            = true,
}


local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES        = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local dmg_filtered = {
    [280705] = true, -- Laser Matrix.
}


local function IsActuallyFriend( unit )
    if not IsInGroup() then return false end
    if not UnitIsPlayer( unit ) then return false end
    if UnitInRaid( unit ) or UnitInParty( unit ) then return true end
    return false
end


-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
local function CLEU_HANDLER( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

    if death_events[ subtype ] then
        if ns.isTarget( destGUID ) then
            ns.eliminateUnit( destGUID, true )
            ns.forceRecount()
            Hekili:ForceUpdate( subtype )
        elseif ns.isMinion( destGUID ) then
            ns.updateMinion( destGUID )
        end
        return
    end

    local time = GetTime()

    if subtype == 'SPELL_SUMMON' and sourceGUID == state.GUID then
        ns.updateMinion( destGUID, time )
        return
    end

    local hostile = ( bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 ) and not IsActuallyFriend( destName )

    if dmg_events[ subtype ] and destGUID == state.GUID then
        local damage, damageType = amount, school

        if subtype == "SWING_DAMAGE" then
            damage = spellID
            damageType = 1
        elseif subtype == "SWING_MISSED" then
            damage = school
            damageType = 1
        elseif subtype == "SPELL_MISSED" or subtype == "SPELL_PERIODIC_MISSED" then
            if amount == "ABSORB" then
                damage = a
                damageType = school or 1
            else
                damage = 0
            end
        end

        if damage and damage > 0 then
            ns.storeDamage( time, damage, bit.band( damageType, 0x1 ) == 1 )
        end
    end

    if sourceGUID ~= state.GUID and not ( state.role.tank and destGUID == state.GUID ) and not ns.isMinion( sourceGUID ) then
        return
    end

    if sourceGUID == state.GUID then
        -- Started a spellcast.
        if cast_events[ subtype ] then
            local ability = class.abilities[ spellID ]

            if subtype == "SPELL_CAST_START" then
                state:QueueEvent( spellID, "hardcast" )

            elseif subtype == "SPELL_CAST_FAILED" then
                state:CancelCastEvent( spellID )

            elseif subtype == "SPELL_CAST_SUCCESS" then
                -- We completed a spellcast, it may have been queued and have data available to us.
                local event = state:RemoveQueuedSpell( spellID )                

                if ability then
                    if ability.isProjectile then state:QueueEvent( spellID, "projectile", event ) end
                    state:AddToHistory( ability.key, destGUID )
                end
            end

            local gcdStart = GetSpellCooldown( 61304 )
            if state.gcd.lastStart ~= gcdStart then
                state.gcd.lastStart = max( state.gcd.lastStart, gcdStart )
            end            

            Hekili:ForceUpdate( subtype )
        end
    end

    if state.role.tank and state.GUID == destGUID and subtype:sub(1,5) == 'SWING' and not IsActuallyFriend( sourceName ) then
        ns.updateTarget( sourceGUID, time, true )

    elseif subtype:sub( 1, 5 ) == 'SWING' and not multistrike then
        if subtype == 'SWING_MISSED' then offhand = spellName end

        local sw = state.swings

        if offhand and time > sw.oh_actual and sw.oh_speed then
            sw.oh_actual = time
            sw.oh_speed = select( 2, UnitAttackSpeed( 'player' ) ) or sw.oh_speed
            sw.oh_projected = sw.oh_actual + sw.oh_speed

        elseif not offhand and time > sw.mh_actual then
            sw.mh_actual = time
            sw.mh_speed = UnitAttackSpeed( 'player' ) or sw.mh_speed
            sw.mh_projected = sw.mh_actual + sw.mh_speed

        end

    -- Player/Minion Event
    elseif sourceGUID == state.GUID or ns.isMinion( sourceGUID ) or ( sourceGUID == destGUID and sourceGUID == UnitGUID( 'target' ) ) then

        if aura_events[ subtype ] then
            if subtype == "SPELL_CAST_SUCCESS" or state.GUID == destGUID then 
                state.player.updated = true
                if class.auras[ spellID ] then Hekili:ForceUpdate( subtype ) end
            end

            if UnitGUID( 'target' ) == destGUID then
                state.target.updated = true
                if class.auras[ spellID ] then Hekili:ForceUpdate( subtype ) end
            end
        end

        local aura = class.auras and class.auras[ spellID ]

        if aura then            
            if hostile and sourceGUID ~= destGUID and not aura.friendly then
                -- Aura Tracking
                if subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                    ns.trackDebuff( spellID, destGUID, time, true )
                    ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

                elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                    if Hekili.currentSpecOpts and Hekili.currentSpecOpts.damageDots then ns.trackDebuff( spellID, destGUID, time ) end

                elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                    ns.trackDebuff( spellID, destGUID )

                end

            elseif sourceGUID == state.GUID and aura.friendly then -- friendly effects
                if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                    ns.trackDebuff( spellID, destGUID, time, subtype == 'SPELL_AURA_APPLIED' )

                elseif subtype == 'SPELL_PERIODIC_HEAL' or subtype == 'SPELL_PERIODIC_MISSED' then
                    ns.trackDebuff( spellID, destGUID, time )

                elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                    ns.trackDebuff( spellID, destGUID )

                end

            end

        end

        local action = class.abilities[ spellID ]

        if subtype ~= 'SPELL_CAST_SUCCESS' and action and action.velocity then
            state:Unqueue( action.key )
        end

        if hostile and dmg_events[ subtype ] and not dmg_filtered[ spellID ] then
            -- Don't wipe overkill targets in rested areas (it is likely a dummy).
            -- Interrupt is actually overkill.
            if not IsResting( "player" ) and ( ( ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) and interrupt > 0 ) or ( subtype == "SWING_DAMAGE" and spellName > 0 ) ) and ns.isTarget( destGUID ) then
                ns.eliminateUnit( destGUID, true )
                ns.forceRecount()
                Hekili:ForceUpdate( "SPELL_DAMAGE_OVERKILL" )
            elseif not ( subtype == "SPELL_MISSED" and amount == "IMMUNE" ) then
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )
            end

            if state.spec.enhancement and spellName == class.abilities.fury_of_air.name then
                state.swings.last_foa_tick = time
                -- Hekili:ForceUpdate( subtype )
            end
        end
    end

    -- This is dumb.  Just let modules used the event handler.
    ns.callHook( "COMBAT_LOG_EVENT_UNFILTERED", event, nil, subtype, nil, sourceGUID, sourceName, nil, nil, destGUID, destName, destFlags, nil, spellID, spellName, nil, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

end
Hekili:ProfileCPU( "CLEU_HANDLER", CLEU_HANDLER )
RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function ( event ) CLEU_HANDLER( event, CombatLogGetCurrentEventInfo() ) end )


local function UNIT_COMBAT( event, unit, action, _, amount )
    if unit ~= 'player' then return end

    if amount > 0 and action == 'HEAL' then
        ns.storeHealing( GetTime(), amount )
    end
end
Hekili:ProfileCPU( "UNIT_COMBAT", UNIT_COMBAT )
RegisterUnitEvent( "UNIT_COMBAT", UNIT_COMBAT )


local keys = ns.hotkeys
Hekili.KeybindInfo = keys
local updatedKeys = {}

local bindingSubs = {
    ["CTRL%-"] = "C",
    ["ALT%-"] = "A",
    ["SHIFT%-"] = "S",
    ["STRG%-"] = "ST",
    ["%s+"] = "",
    ["NUMPAD"] = "N",
    ["PLUS"] = "+",
    ["MINUS"] = "-",
    ["MULTIPLY"] = "*",
    ["DIVIDE"] = "/",
    ["BUTTON"] = "M",
    ["DOWN"] = "Dn",
    ["UP"] = "Up",
    ["MOUSEWHEEL"] = "Mw",
    ["BACKSPACE"] = "BkSp"
}

local function improvedGetBindingText( binding )
    if not binding then return "" end

    for k, v in pairs( bindingSubs ) do
        binding = binding:gsub( k, v )
    end

    return binding
end


local function StoreKeybindInfo( page, key, aType, id, console )

    if not key then return end

    local ability

    if aType == "spell" then
        ability = class.abilities[ id ] and class.abilities[ id ].key

    elseif aType == "macro" then
        local sID = GetMacroSpell( id )
        ability = sID and class.abilities[ sID ] and class.abilities[ sID ].key

    elseif aType == "item" then
        ability = GetItemInfo( id )
        ability = class.abilities[ ability ] and class.abilities[ ability ].key

        if not ability then
            for k, v in pairs( class.potions ) do
                if v.item == id then
                    ability = "potion"
                    break
                end
            end
        end

    end

    if ability then
        keys[ ability ] = keys[ ability ] or {
            lower = {},
            upper = {},
            console = {}
        }

        if console == "cPort" then
            local newKey = key:gsub( ":%d+:%d+:0:0", ":0:0:0:0" )
            keys[ ability ].console[ page ] = newKey
        else
            keys[ ability ].upper[ page ] = improvedGetBindingText( key )
            keys[ ability ].lower[ page ] = lower( keys[ ability ].upper[ page ] )
        end
        updatedKeys[ ability ] = true

        if ability.bind then
            local bind = ability.bind

            keys[ bind ] = keys[ bind ] or {
                lower = {},
                upper = {},
                console = {}
            }

            keys[ bind ].lower[ page ] = keys[ ability ].lower[ page ]
            keys[ bind ].upper[ page ] = keys[ ability ].upper[ page ]
            keys[ bind ].console[ page ] = keys[ ability ].console[ page ]

            updatedKeys[ bind ] = true
        end
    end
end        



local defaultBarMap = {
    WARRIOR = {
        { bonus = 1, bar = 7 },
        { bonus = 2, bar = 8 },
    },
    ROGUE = {
        { bonus = 1, bar = 7 },
        { bonus = 2, bar = 7 },
        { bonus = 3, bar = 7 },
    },
    DRUID = {
        { bonus = 1, stealth = false, bar = 7 },
        { bonus = 1, stealth = true,  bar = 8 },
        { bonus = 2, bar = 8 },
        { bonus = 3, bar = 9 },
        { bonus = 4, bar = 10 },
    },
    MONK = {
        { bonus = 1, bar = 7 },
        { bonus = 2, bar = 8 },
        { bonus = 3, bar = 9 },
    },
    PRIEST = {
        { bonus = 1, bar = 7 },
    },
}



local function ReadKeybindings()

    for k, v in pairs( keys ) do
        wipe( v.upper )
        wipe( v.lower )
    end

    -- Bartender4 support from tanichan.
    if _G["Bartender4"] then
        -- Bartender
        local bt4Button
        local bt4Key

        for i = 1, 12 do
            StoreKeybindInfo( 1, GetBindingKey( "ACTIONBUTTON" .. i ), GetActionInfo( i ) )
        end

        for i = 13, 120 do 
            bt4Key = GetBindingKey( "CLICK BT4Button" .. i .. ":LeftButton" )
            bt4Button = _G[ "BT4Button" .. i ]

            if bt4Button then
                local buttonActionType, buttonActionId = GetActionInfo( i )
                StoreKeybindInfo( 2, bt4Key, buttonActionType, buttonActionId )
            end
        end

    else
        for i = 1, 12 do
            StoreKeybindInfo( 1, GetBindingKey( "ACTIONBUTTON" .. i ), GetActionInfo( i ) )
        end

        for i = 13, 24 do
            StoreKeybindInfo( 2, GetBindingKey( "ACTIONBUTTON" .. i - 12 ), GetActionInfo( i ) )
        end

        for i = 25, 36 do
            StoreKeybindInfo( 3, GetBindingKey( "MULTIACTIONBAR3BUTTON" .. i - 24 ), GetActionInfo( i ) )
        end

        for i = 37, 48 do
            StoreKeybindInfo( 4, GetBindingKey( "MULTIACTIONBAR4BUTTON" .. i - 36 ), GetActionInfo( i ) )
        end

        for i = 49, 60 do
            StoreKeybindInfo( 5, GetBindingKey( "MULTIACTIONBAR2BUTTON" .. i - 48 ), GetActionInfo( i ) )
        end

        for i = 61, 72 do
            StoreKeybindInfo( 6, GetBindingKey( "MULTIACTIONBAR1BUTTON" .. i - 60 ), GetActionInfo( i ) )
        end

        for i = 72, 119 do
            StoreKeybindInfo( 7 + floor( ( i - 72 ) / 12 ), GetBindingKey( "ACTIONBUTTON" .. 1 + ( i - 72 ) % 12 ), GetActionInfo( i + 1 ) )
        end
    end

    if _G.ConsolePort then
        for i = 1, 120 do
            local bind = ConsolePort:GetActionBinding(i)

            if bind then
                local action, id = GetActionInfo( i )
                local key, mod = ConsolePort:GetCurrentBindingOwner(bind)
                StoreKeybindInfo( math.ceil( i / 12 ), ConsolePort:GetFormattedButtonCombination( key, mod ), action, id, "cPort" )
            end
        end
    end 

    for k in pairs( keys ) do
        local ability = class.abilities[ k ]

        if ability and ability.bind then
            for page, value in pairs( keys[ k ].lower ) do
                keys[ ability.bind ] = keys[ ability.bind ] or {
                    lower = {},
                    upper = {},
                    console = {}
                }
                keys[ ability.bind ].lower[ page ] = value
                keys[ ability.bind ].upper[ page ] = keys[ k ].upper[ page ]
                keys[ ability.bind ].console[ page ] = keys[ k ].console[ page ]
            end
        end
    end

end    
ns.ReadKeybindings = ReadKeybindings


RegisterEvent( "UPDATE_BINDINGS", ReadKeybindings )
RegisterEvent( "PLAYER_ENTERING_WORLD", ReadKeybindings )
RegisterEvent( "ACTIONBAR_SLOT_CHANGED", ReadKeybindings )
RegisterEvent( "ACTIONBAR_SHOWGRID", ReadKeybindings )
RegisterEvent( "ACTIONBAR_HIDEGRID", ReadKeybindings )
RegisterEvent( "ACTIONBAR_PAGE_CHANGED", ReadKeybindings )
RegisterEvent( "ACTIONBAR_UPDATE_STATE", ReadKeybindings )
RegisterEvent( "SPELL_UPDATE_ICON", ReadKeybindings )
RegisterEvent( "SPELLS_CHANGED", ReadKeybindings )

RegisterEvent( "UPDATE_SHAPESHIFT_FORM", function ( event )
    ReadKeybindings()
    Hekili:ForceUpdate( event )
end )
-- RegisterUnitEvent( "PLAYER_SPECIALIZATION_CHANGED", ReadKeybindings )
-- RegisterUnitEvent( "PLAYER_EQUIPMENT_CHANGED", ReadKeybindings )


if select( 2, UnitClass( "player" ) ) == "DRUID" then
    function Hekili:GetBindingForAction( key, display )
        if not key then return "" end

        local ability = class.abilities[ key ]

        local override = state.spec.id
        local overrideType = ability and ability.item and "items" or "abilities"

        override = override and self.DB.profile.specs[ override ]
        override = override and override[ overrideType ][ key ]
        override = override and override.keybind

        if override and override ~= "" then
            return override
        end

        if not keys[ key ] then return "" end

        local caps, console = true, false
        if display then
            caps = not display.keybindings.lowercase
            console = ConsolePort ~= nil and display.keybindings.cPortOverride
        end

        local db = console and keys[ key ].console or ( caps and keys[ key ].upper or keys[ key ].lower )

        local output

        if state.prowling then
            output = db[ 8 ] or db[ 7 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 9 ] or db[ 10 ] or db[ 1 ] or ""

        elseif state.buff.cat_form.up then
            output = db[ 7 ] or db[ 8 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 9 ] or db[ 10 ] or db[ 1 ] or ""

        elseif state.buff.bear_form.up then
            output = db[ 9 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 2 ] or db [ 7 ] or db[ 8 ] or db[ 10 ] or db[ 1 ] or ""

        elseif state.buff.moonkin_form.up then
            output = db[ 10 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or db[ 1 ] or ""

        else
            output = db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or db[ 10 ] or ""
        end

        if output ~= "" and console then
            local size = output:match( "Icons(%d%d)" )
            size = tonumber(size)
    
            if size then
                local margin = floor( size * display.keybindings.cPortZoom * 0.5 )
                output = output:gsub( ":0|t", ":0:" .. size .. ":" .. size .. ":" .. margin .. ":" .. ( size - margin ) .. ":" .. margin .. ":" .. ( size - margin ) .. "|t" )
            end
        end

        return output
    end
elseif select( 2, UnitClass( "player" ) ) == "ROGUE" then
    function Hekili:GetBindingForAction( key, display )
        if not key then return "" end

        local ability = class.abilities[ key ]

        local override = state.spec.id
        local overrideType = ability and ability.item and "items" or "abilities"

        override = override and self.DB.profile.specs[ override ]
        override = override and override[ overrideType ][ key ]
        override = override and override.keybind

        if override and override ~= "" then
            return override
        end

        if not keys[ key ] then return "" end

        local caps, console = true, false
        if display then
            caps = not display.keybindings.lowercase
            console = ConsolePort ~= nil and display.keybindings.cPortOverride
        end

        local db = console and keys[ key ].console or ( caps and keys[ key ].upper or keys[ key ].lower )

        local output

        if state.stealthed.all then
            output = db[ 7 ] or db[ 8 ] or db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 9 ] or db[ 10 ] or ""

        else
            output = db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or db[ 10 ] or ""
        
        end

        if output ~= "" and console then
            local size = output:match( "Icons(%d%d)" )
            size = tonumber(size)
    
            if size then
                local margin = floor( size * display.keybindings.cPortZoom * 0.5 )
                output = output:gsub( ":0|t", ":0:" .. size .. ":" .. size .. ":" .. margin .. ":" .. ( size - margin ) .. ":" .. margin .. ":" .. ( size - margin ) .. "|t" )
            end
        end

        return output
    end

else
    function Hekili:GetBindingForAction( key, display )
        if not key then return "" end

        local ability = class.abilities[ key ]

        local override = state.spec.id
        local overrideType = ability and ability.item and "items" or "abilities"

        override = override and self.DB.profile.specs[ override ]
        override = override and override[ overrideType ][ key ]
        override = override and override.keybind

        if override and override ~= "" then
            return override
        end

        if not keys[ key ] then return "" end

        local caps, console = true, false
        if display then
            caps = not display.keybindings.lowercase
            console = ConsolePort ~= nil and display.keybindings.cPortOverride
        end
        
        local db = console and keys[ key ].console or ( caps and keys[ key ].upper or keys[ key ].lower )

        local output = db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or db[ 10 ] or ""

        if output ~= "" and console then
            local size = output:match( "Icons(%d%d)" )
            size = tonumber(size)
    
            if size then
                local margin = floor( size * display.keybindings.cPortZoom * 0.5 )
                output = output:gsub( ":0:0:0:0|t", ":0:0:0:0:" .. size .. ":" .. size .. ":" .. margin .. ":" .. ( size - margin ) .. ":" .. margin .. ":" .. ( size - margin ) .. "|t" )
            end
        end

        return output        
    end

end
