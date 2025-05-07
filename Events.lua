-- Events.lua
-- June 2024

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State
local PTR = ns.PTR
local TTD = ns.TTD

local formatKey = ns.formatKey

local abs = math.abs
local lower = string.lower
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe

local CGetItemInfo = C_Item.GetItemInfo
local IsEquippedItem = C_Item.IsEquippedItem
local GetDetailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo
local UA_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local IsUsableItem = C_Item.IsUsableItem
local GetItemSpell = C_Item.GetItemSpell

local GetSpellCooldown = function(spellID)
    local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID);
    if spellCooldownInfo then
        return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;
    end
end

local GetSpellInfo = ns.GetUnpackedSpellInfo

local FindStringInInventoryItemTooltip = ns.FindStringInInventoryItemTooltip
local ResetDisabledGearAndSpells = ns.ResetDisabledGearAndSpells
local WipeCovenantCache = ns.WipeCovenantCache

local RC = LibStub( "LibRangeCheck-3.0" )

-- Abandoning AceEvent in favor of darkend's solution from:
-- http://andydote.co.uk/2014/11/23/good-design-in-warcraft-addons.html
-- This should be a bit friendlier for our modules.

local events = CreateFrame( "Frame" )
Hekili:ProfileFrame( "GeneralEvents", events )
local handlers = {}
local unitHandlers = {}

local itemCallbacks = {}
local spellCallbacks = {}
local activeDisplays = {}


function Hekili:GetActiveDisplays()
    return activeDisplays
end


local handlerCount = {}
Hekili.ECount = handlerCount
Hekili.IC = itemCallbacks

local eventData = {}
Hekili.EData = eventData

local function GenericOnEvent( self, event, ... )
    local eventHandlers = handlers[ event ]

    if not eventHandlers then return end

    for i, handler in ipairs( eventHandlers ) do
        local key = event .. "_" .. i
        local start = debugprofilestop()
        handler( event, ... )
        local finish = debugprofilestop()

        handlerCount[ key ] = ( handlerCount[ key ] or 0 ) + 1

        eventData[ key ] = eventData[ key ] or {}
        eventData[ key ].max = max( eventData[ key ].max or 0, finish - start )
        eventData[ key ].total = ( eventData[ key ].total or 0 ) + ( finish - start )
    end
end

local function UnitSpecificOnEvent( self, event, unit, ... )
    local unitFrame = unitHandlers[ unit ]

    if unitFrame then
        local eventHandlers = unitFrame.events[ event ]

        if not eventHandlers then return end

        for i, handler in ipairs( eventHandlers ) do
            local key = event .. "_" .. unit .. "_" .. i
            local start = debugprofilestop()
            handler( event, unit, ... )
            local finish = debugprofilestop()

            handlerCount[ key ] = ( handlerCount[ key ] or 0 ) + 1

            eventData[ key ] = eventData[ key ] or {}
            eventData[ key ].max = max( eventData[ key ].max or 0, finish - start )
            eventData[ key ].total = ( eventData[ key ].total or 0 ) + ( finish - start )
        end
    end
end

function ns.StartEventHandler()
    events:SetScript( "OnEvent", GenericOnEvent )

    for unit, unitFrame in pairs( unitHandlers ) do
        unitFrame:SetScript( "OnEvent", UnitSpecificOnEvent )
    end

    events:SetScript( "OnUpdate", function( self, elapsed )
        if Hekili.PendingSpecializationChange then
            Hekili:SpecializationChanged()
            Hekili.PendingSpecializationChange = false
            -- Spec updates are expensive; exit and do other work in the next frame.
            return
        end

        if handlers.FRAME_UPDATE then
            for i, handler in pairs( handlers.FRAME_UPDATE ) do
                local key = "FRAME_UPDATE_" .. i
                local start = debugprofilestop()
                handler( event, elapsed )
                local finish = debugprofilestop()

                handlerCount[ key ] = ( handlerCount[ key ] or 0 ) + 1

                eventData[ key ] = eventData[ key ] or {}
                eventData[ key ].max = max( eventData[ key ].max or 0, finish - start )
                eventData[ key ].total = ( eventData[ key ].total or 0 ) + ( finish - start )
            end
        end
    end )

    Hekili:RunSpellCallbacks()
end


function ns.StopEventHandler()
    events:SetScript( "OnEvent", nil )

    for unit, unitFrame in pairs( unitHandlers ) do
        unitFrame:SetScript( "OnEvent", nil )
    end

    events:SetScript( "OnUpdate", nil )
end


Hekili.EventSources = {}

ns.RegisterEvent = function( event, handler )

    handlers[ event ] = handlers[ event ] or {}
    insert( handlers[ event ], handler )

    if event ~= "FRAME_UPDATE" then events:RegisterEvent( event ) end

    local key = event .. "_" .. #handlers[event]
    Hekili:ProfileCPU( key, handler )

    local stack = debugstack(2)
    local file, line = stack:match([[Hekili/(.-)"%]:(%d+)]])
    Hekili.EventSources[ key ] = file and ( file .. ":" .. ( line or 0 ) ) or stack:match( "^(.*)\n" )
end
local RegisterEvent = ns.RegisterEvent


ns.UnregisterEvent = function( event, handler )
    local hands = handlers[ event ]

    if not hands then return end

    for i = #hands, 1, -1 do
        if hands[i] == handler then
            remove( hands, i )
        end
    end

    if #hands == 0 then events:UnregisterEvent( event ) end
end
local UnregisterEvent = ns.UnregisterEvent


-- For our purposes, all UnitEvents are player/target oriented.
ns.RegisterUnitEvent = function( event, unit1, unit2, handler )
    if not unit1 then unit1 = "player" end

    if not unitHandlers[ unit1 ] then
        unitHandlers[ unit1 ] = CreateFrame( "Frame" )
        Hekili:ProfileFrame( "UnitEvents:" .. unit1, unitHandlers[ unit1 ] )

        unitHandlers[ unit1 ].events = {}
    end

    local unitFrame = unitHandlers[ unit1 ]

    unitFrame.events[ event ] = unitFrame.events[ event ] or {}
    insert( unitFrame.events[ event ], handler )

    local stack = debugstack(2)
    local file, line = stack:match([[Hekili/(.-)"%]:(%d+)]])
    Hekili.EventSources[ event .. "_" .. unit1 .. "_" .. #unitFrame.events[ event ] ] = file and ( file .. ":" .. ( line or 0 ) ) or stack:match( "^(.*)\n" )

    unitFrame:RegisterUnitEvent( event, unit1 )
    Hekili:ProfileCPU( event .. "_" .. unit1 .. "_" .. #unitFrame.events[ event ], handler )

    if unit2 then
        if not unitHandlers[ unit2 ] then
            unitHandlers[ unit2 ] = CreateFrame( "Frame" )
            Hekili:ProfileFrame( "UnitEvents:" .. unit2, unitHandlers[ unit2 ] )

            unitHandlers[ unit2 ].events = {}
        end

        unitFrame = unitHandlers[ unit2 ]

        unitFrame.events[ event ] = unitFrame.events[ event ] or {}
        insert( unitFrame.events[ event ], handler )

        Hekili.EventSources[ event .. "_" .. unit2 .. "_" .. #unitFrame.events[ event ] ] = file and ( file .. ":" .. ( line or 0 ) ) or stack:match( "^(.*)\n" )

        unitFrame:RegisterUnitEvent( event, unit2 )
        Hekili:ProfileCPU( event .. "_" .. unit2 .. "_" .. #unitFrame.events[ event ], handler )
    end
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
Hekili.FeignEvent = ns.FeignEvent


do
    local isUnregistered = false
    local next = _G.next

    local requeued = {}

    local HandleSpellData = function( event, spellID, success )
        local callbacks = spellCallbacks[ spellID ]

        if callbacks then
            for i = #callbacks, 1, -1 do
                callbacks[i]( event, spellID, success )
                remove( callbacks, i )
            end

            if #callbacks == 0 then
                spellCallbacks[ spellID ] = nil
            end
        end

        if spellCallbacks == nil or next( spellCallbacks ) == nil then
            UnregisterEvent( "SPELL_DATA_LOAD_RESULT", HandleSpellData )
            isUnregistered = true
        end
    end

    function Hekili:ContinueOnSpellLoad( spellID, func )
        if C_Spell.IsSpellDataCached( spellID ) then
            func( true )
            return
        end

        local callbacks = spellCallbacks[ spellID ] or {}
        insert( callbacks, func )
        spellCallbacks[ spellID ] = callbacks

        if isUnregistered then
            RegisterEvent( "SPELL_DATA_LOAD_RESULT", HandleSpellData )
            isUnregistered = false
        end

        C_Spell.RequestLoadSpellData( spellID )
    end

    function Hekili:RunSpellCallbacks()
        for spell, callbacks in pairs( spellCallbacks ) do
            for i = #callbacks, 1, -1 do
                if not callbacks[ i ]( true ) == false then remove( callbacks, i ) end
            end

            if #callbacks == 0 then
                spellCallbacks[ spell ] = nil
            end
        end
    end
end


RegisterEvent( "DISPLAY_SIZE_CHANGED", function()
    Hekili:BuildUI()
end )



RegisterEvent( "PLAYER_ENTERING_WORLD", function( event, login, reload )
    if not Hekili.PLAYER_ENTERING_WORLD and ( login or reload ) then
        Hekili.PLAYER_ENTERING_WORLD = true
        Hekili:SpecializationChanged()
        Hekili:RestoreDefaults()

        ns.checkImports()
        ns.updateGear()

        if state.combat == 0 and InCombatLockdown() then
            state.combat = GetTime() - 0.01
        end

        local _, zone, _, _, _, _, _, instanceID = GetInstanceInfo()
        state.bg = zone == "pvp"
        state.arena = zone == "arena"
        state.torghast = IsInJailersTower()
        state.instance_id = instanceID or -1

        Hekili:BuildUI()
    end
end )


do
    if Hekili.IsWrath() then
        RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED", function()
            Hekili:SpecializationChanged()
        end )
    else
        local specializationEvents = {
            ACTIVE_PLAYER_SPECIALIZATION_CHANGED = 1,
            ACTIVE_TALENT_GROUP_CHANGED = 1,
            CONFIRM_TALENT_WIPE = 1,
            PLAYER_TALENT_UPDATE = 1,
            SPEC_INVOLUNTARILY_CHANGED = 1,
            TALENTS_INVOLUNTARILY_RESET = 1
        }

        local function CheckForTalentUpdate( event )
            local specialization = GetSpecialization()
            local specID = specialization and GetSpecializationInfo( specialization )

            if specID and specID ~= state.spec.id then
                Hekili.PendingSpecializationChange = true
            end
        end

        RegisterEvent( "ACTIVE_PLAYER_SPECIALIZATION_CHANGED", CheckForTalentUpdate )

        for event in pairs( specializationEvents ) do
            RegisterEvent( event, CheckForTalentUpdate )
        end
    end
end


do
    local function UpdateZoneInfo()
        local _, zone, _, _, _, _, _, instanceID = GetInstanceInfo()
        state.bg = zone == "pvp"
        state.arena = zone == "arena"
        state.torghast = IsInJailersTower()
        state.instance_id = instanceID or -1
    end

    RegisterEvent( "ZONE_CHANGED", UpdateZoneInfo )
    RegisterEvent( "ARENA_PREP_OPPONENT_SPECIALIZATIONS", UpdateZoneInfo )
end


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

    WipeCovenantCache()
    ResetDisabledGearAndSpells()
end


-- TBD:  Consider making `boss' a check to see whether the current unit is a boss# unit instead.
RegisterEvent( "ENCOUNTER_START", function ( _, id, name, difficulty, groupSize )
    state.encounterID = id
    state.encounterName = name
    state.encounterDifficulty = difficulty
    state.encounterSize = groupSize
end )

RegisterEvent( "ENCOUNTER_END", function ()
    state.encounterID = 0
    state.encounterName = "None"
    state.encounterDifficulty = 0
    state.encounterSize = 0
end )


do
    local loc = ItemLocation:CreateEmpty()

    local GetAllTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo
    local GetPowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo
    local IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
    local IsPowerSelected = C_AzeriteEmpoweredItem.IsPowerSelected

    local MAX_INV_SLOTS = 19

    function ns.updatePowers()
        local p = state.azerite

        for k, v in pairs( p ) do
            v.__rank = 0
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
                                p[ name ] = rawget( p, name ) or { __rank = 0 }
                                p[ name ].__rank = p[ name ].__rank + 1
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
    local AE = C_AzeriteEssence
    local GetMilestoneEssence, GetEssenceInfo = AE.GetMilestoneEssence, AE.GetEssenceInfo
    local milestones = { 115, 116, 117, 119 }

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
        [16] = "unwavering_ward",
        [17] = "everrising_tide",
        [18] = "artifice_of_time",
        [19] = "well_of_existence",
        [20] = "lifebinders_invocation",
        [21] = "vitality_conduit",
        [22] = "vision_of_perfection",
        [23] = "blood_of_the_enemy",
        [24] = "spirit_of_preservation",
        [25] = "aegis_of_the_deep",
        [27] = "memory_of_lucid_dreams",
        [28] = "the_unbound_force",
        [32] = "conflict_and_strife",
        [33] = "touch_of_the_everlasting",
        [34] = "strength_of_the_warden",
        [35] = "breath_of_the_dying",
        [36] = "spark_of_inspiration",
        [37] = "the_formless_void"
    }

    local essenceMajors = {
        -- everrising_tide = "",
        -- lifebinders_invocation = "",
        -- touch_of_the_everlasting = "",
        -- vision_of_perfection = "",
        -- vitality_conduit = "",
        -- well_of_existence = "",
        -- conflict_and_strife = "",
        aegis_of_the_deep = "aegis_of_the_deep",
        anima_of_life_and_death = "anima_of_death",
        artifice_of_time = "standstill",
        azeroths_undying_gift = "azeroths_undying_gift",
        blood_of_the_enemy = "blood_of_the_enemy",
        breath_of_the_dying = "reaping_flames",
        condensed_lifeforce = "guardian_of_azeroth",
        essence_of_the_focusing_iris = "focused_azerite_beam",
        memory_of_lucid_dreams = "memory_of_lucid_dreams",
        nullification_dynamo = "empowered_null_barrier",
        purification_protocol = "purifying_blast",
        ripple_in_space = "ripple_in_space",
        spark_of_inspiration = "moment_of_glory",
        sphere_of_suppression = "suppressing_pulse",
        spirit_of_preservation = "spirit_of_preservation",
        strength_of_the_warden = "vigilant_protector",
        the_crucible_of_flame = "concentrated_flame",
        the_formless_void = "replica_of_knowledge",
        the_unbound_force = "the_unbound_force",
        unwavering_ward = "guardian_shell",
        worldvein_resonance = "worldvein_resonance",
    }

    for _, key in pairs( essenceKeys ) do
        state.essence[ key ] = { __rank = 0, __major = false }
    end


    function ns.updateEssences()
        local e = state.bfa_essence

        for k, v in pairs( e ) do
            v.__rank = 0
        end

        class.active_essence = nil

        if state.equipped[ 158075 ] then
            for i, ms in ipairs( milestones ) do
                local essence = GetMilestoneEssence( ms )

                if essence then
                    local info = GetEssenceInfo( essence )

                    if info then
                        local key = essenceKeys[ info.ID ]

                        e[ key ].__rank = info.rank
                        e[ key ].__minor = true

                        if i == 1 then
                            e[ key ].__major = true
                            class.active_essence = essenceMajors[ key ]
                        end
                    end
                end
            end
        end
    end

    ns.updateEssences()
end


do
    local function itemSorter( a, b )
        local action1, action2 = class.abilities[ a.action ].cooldown, class.abilities[ b.action ].cooldown
        return action1 > action2
    end

    local function buildUseItemsList()
        local itemList = class.itemPack.lists.items
        wipe( itemList )

        if #state.items > 0 then
            for i, item in ipairs( state.items ) do
                if not Hekili:IsItemScripted( item ) then
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

        sort( itemList, itemSorter )

        class.essence_unscripted = ( class.active_essence and not Hekili:IsEssenceScripted( class.active_essence ) ) or false

        Hekili:LoadItemScripts()
    end

    function Hekili:UpdateUseItems()
        if not Hekili.PLAYER_ENTERING_WORLD then
            C_Timer.After( 1, buildUseItemsList )
            return
        end

        buildUseItemsList()
    end


    local GearHooks = {}

    -- This is a simple way to separate expansion-based gear into separate systems.
    function Hekili:RegisterGearHook( r, u )
        insert( GearHooks, {
            reset = r,
            update = u
        } )
    end

    local wasWearing = {}
    local maxItemSlot = Hekili.IsWrath() and INVSLOT_LAST_EQUIPPED or Enum.ItemSlotFilterTypeMeta.MaxValue

    local timer

    local function Update()
        ns.updateGear()
    end

    local function QueueUpdate()
        if timer and not timer:IsCancelled() then timer:Cancel() end
        timer = C_Timer.NewTimer( 1, Update )
    end

    function ns.updateGear()
        if not Hekili.PLAYER_ENTERING_WORLD then
            QueueUpdate()
            return
        end

        wipe( state.set_bonus )

        for _, hook in ipairs( GearHooks ) do
            if hook.reset then hook.reset() end
        end

        wipe( wasWearing )

        for i, item in ipairs( state.items ) do
            wasWearing[ i ] = item
        end

        wipe( state.items )

        for set, items in pairs( class.gear ) do
            state.set_bonus[ set ] = 0
            for item, _ in pairs( items ) do
                if item > maxItemSlot and IsEquippedItem( item ) then
                    state.set_bonus[ set ] = state.set_bonus[ set ] + 1
                end
            end
        end

        for bonus, aura in pairs( class.setBonuses ) do
            if UA_GetPlayerAuraBySpellID( aura ) then
                state.set_bonus[ bonus ] = 1
            end
        end

        -- Trinkets
        -- We want to know:
        -- 1. Which trinket?
        -- 2. Does it have a spell?  (GetItemSpell)
        -- 3. Does it have an on-use?  (IsItemUsable)
        -- 4. ???

        local T1 = GetInventoryItemID( "player", 13 )

        state.trinket.t1.__id = 0
        state.trinket.t1.ilvl = 0
        state.trinket.t1.__ability = "null_cooldown"
        state.trinket.t1.__usable = false
        state.trinket.t1.__has_use_buff = false
        state.trinket.t1.__use_buff_duration = nil

        if T1 then
            state.trinket.t1.__id = T1
            -- So this isn't *truly* accurate, but it's accurate relatively speaking.
            state.trinket.t1.ilvl = GetDetailedItemLevelInfo( T1 )

            local isUsable = IsUsableItem( T1 )
            local name, spellID = GetItemSpell( T1 )
            local tSpell = class.itemMap[ T1 ]

            if tSpell then
                class.abilities.trinket1 = class.abilities[ tSpell ]
                class.specs[ 0 ].abilities.trinket2 = class.abilities[ tSpell ]

                state.trinket.t1.__usable = isUsable
                state.trinket.t1.__ability = tSpell

                local ability = class.abilities[ tSpell ]
                local aura = ability and class.auras[ ability.self_buff or spellID ]

                if spellID and SpellIsSelfBuff( spellID ) and aura then
                    state.trinket.t1.__has_use_buff = not aura.ignore_buff and not ( ability and ability.proc and ( ability.proc == "damage" or ability.proc == "healing" or ability.proc == "mana" or ability.proc == "absorb" or ability.proc == "speed" ) )
                    state.trinket.t1.__use_buff_duration = aura.duration > 0 and aura.duration or 0.01
                elseif ability.self_buff then
                    state.trinket.t1.__has_use_buff = not aura.ignore_buff and not ( ability and ability.proc and ( ability.proc == "damage" or ability.proc == "healing" or ability.proc == "mana" or ability.proc == "absorb" or ability.proc == "speed" ) )
                    state.trinket.t1.__use_buff_duration = aura and aura.duration > 0 and aura.duration or 0.01
                end

                if not isUsable then
                    state.trinket.t1.cooldown = state.cooldown.null_cooldown
                else
                    state.cooldown.trinket1 = state.cooldown[ ability.key ]
                    state.trinket.t1.cooldown = state.cooldown.trinket1
                end
            else
                class.abilities.trinket1 = class.abilities.actual_trinket1
                class.specs[ 0 ].abilities.trinket1 = class.abilities.actual_trinket1
                state.trinket.t1.cooldown = state.cooldown.null_cooldown
            end

            state.trinket.t1.__proc = FindStringInInventoryItemTooltip( "^" .. ITEM_SPELL_TRIGGER_ONEQUIP, 13, true, true )
        end

        local T2 = GetInventoryItemID( "player", 14 )

        state.trinket.t2.__id = 0
        state.trinket.t2.__ability = "null_cooldown"
        state.trinket.t2.__usable = false
        state.trinket.t2.__has_use_buff = false
        state.trinket.t2.__use_buff_duration = nil
        state.trinket.t2.ilvl = 0

        if T2 then
            state.trinket.t2.__id = T2
             -- So this isn't *truly* accurate, but it's accurate relatively speaking.
             state.trinket.t2.ilvl = GetDetailedItemLevelInfo( T2 )

            local isUsable = IsUsableItem( T2 )
            local name, spellID = GetItemSpell( T2 )
            local tSpell = class.itemMap[ T2 ]

            if tSpell then
                class.abilities.trinket2 = class.abilities[ tSpell ]
                class.specs[ 0 ].abilities.trinket2 = class.abilities[ tSpell ]

                state.trinket.t2.__usable = isUsable
                state.trinket.t2.__ability = tSpell

                local ability = class.abilities[ tSpell ]
                local aura = class.auras[ ability.self_buff or spellID ]

                if spellID and SpellIsSelfBuff( spellID ) and aura then
                    state.trinket.t2.__has_use_buff = not aura.ignore_buff and not ( ability and ability.proc and ( ability.proc == "damage" or ability.proc == "healing" or ability.proc == "mana" or ability.proc == "absorb" or ability.proc == "speed" ) )
                    state.trinket.t2.__use_buff_duration = aura.duration > 0 and aura.duration or 0.01
                elseif ability.self_buff then
                    state.trinket.t2.__has_use_buff = true
                    state.trinket.t2.__use_buff_duration = aura and aura.duration > 0 and aura.duration or 0.01
                end

                if not isUsable then
                    state.trinket.t2.cooldown = state.cooldown.null_cooldown
                else
                    state.cooldown.trinket2 = state.cooldown[ ability.key ]
                    state.trinket.t2.cooldown = state.cooldown.trinket2
                end
            else
                class.abilities.trinket2 = class.abilities.actual_trinket2
                class.specs[ 0 ].abilities.trinket2 = class.abilities.actual_trinket2
                state.trinket.t2.cooldown = state.cooldown.null_cooldown
            end

            state.trinket.t2.__proc = FindStringInInventoryItemTooltip( "^" .. ITEM_SPELL_TRIGGER_ONEQUIP, 14, true, true )
        end

        state.main_hand.size = 0
        state.off_hand.size = 0

        local MH = GetInventoryItemID( "player", 16 )

        class.abilities.main_hand = class.abilities.actual_main_hand

        if MH then
            local isUsable = IsUsableItem( MH )
            local name, spellID = GetItemSpell( MH )
            local tSpell = class.itemMap[ MH ]
            local ability = class.abilities[ tSpell ]

            if ability and tSpell then
                class.abilities.main_hand = class.abilities[ tSpell ]
                class.specs[ 0 ].abilities.main_hand = class.abilities[ tSpell ]

                local aura = ability and class.auras[ ability.self_buff or spellID ]

                if spellID and SpellIsSelfBuff( spellID ) and aura then
                    state.trinket.main_hand.__has_use_buff = not aura.ignore_buff and not ( ability and ability.proc and ( ability.proc == "damage" or ability.proc == "healing" or ability.proc == "mana" or ability.proc == "absorb" or ability.proc == "speed" ) )
                    state.trinket.main_hand.__use_buff_duration = aura.duration > 0 and aura.duration or 0.01
                elseif ability.self_buff then
                    state.trinket.main_hand.__has_use_buff = true
                    state.trinket.main_hand.__use_buff_duration = aura and aura.duration > 0 and aura.duration or 0.01
                end

                if not isUsable then
                    state.trinket.main_hand.cooldown = state.cooldown.null_cooldown
                else
                    state.cooldown.main_hand = state.cooldown[ ability.key ]
                    state.trinket.main_hand.cooldown = state.cooldown.main_hand
                end
            else
                class.abilities.main_hand = class.abilities.actual_main_hand
                class.specs[ 0 ].abilities.main_hand = class.abilities.actual_main_hand
                state.trinket.main_hand.cooldown = state.cooldown.null_cooldown
            end

            state.trinket.main_hand.__proc = FindStringInInventoryItemTooltip( "^" .. ITEM_SPELL_TRIGGER_ONEQUIP, 16, true, true )
        end

        for i = 1, 19 do
            local item = GetInventoryItemID( "player", i )

            if item then
                state.set_bonus[ item ] = 1
                local key, _, _, _, _, _, _, _, equipLoc = CGetItemInfo( item )
                if key then
                    key = formatKey( key )
                    state.set_bonus[ key ] = 1
                end

                if i == 16 then
                    if equipLoc == "INVTYPE_2HWEAPON" then
                        state.main_hand.size = 2
                    elseif equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND" then
                        state.main_hand.size = 1
                    elseif equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" then
                        state.set_bonus.ranged = 1
                    end
                elseif i == 17 then
                    if equipLoc == "INVTYPE_2HWEAPON" then
                        state.off_hand.size = 2
                    elseif equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONOFFHAND" then
                        state.off_hand.size = 1
                    elseif equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" then
                        state.set_bonus.ranged = 1
                    elseif equipLoc == "INVTYPE_SHIELD" then
                        state.set_bonus.shield = 1
                    end
                end



                -- Fire any/all GearHooks (may be expansion-driven).
                for _, hook in ipairs( GearHooks ) do
                    if hook.update then hook.update( i, item ) end
                end

                local usable = class.itemMap[ item ]
                if usable then insert( state.items, usable ) end
            end
        end

        -- Improve Pocket-Sized Computronic Device.
        if state.equipped.pocketsized_computation_device then
            local tName = CGetItemInfo( 167555 )
            local redName, redLink = C_Item.GetItemGem( tName, 1 )

            if redName and redLink then
                local redID = tonumber( redLink:match("item:(%d+)") )
                local action = class.itemMap[ redID ]

                if action and class.abilities[ action ] and redID then
                    state.set_bonus[ action ] = 1
                    state.set_bonus[ redID ] = 1
                    class.abilities.pocketsized_computation_device = class.abilities[ action ]
                    class.abilities[ tName ] = class.abilities[ action ]
                    insert( state.items, action )
                end
            else
                if class.abilities.inactive_red_punchcard then
                    class.abilities.pocketsized_computation_device = class.abilities.inactive_red_punchcard
                    class.abilities[ tName ] = class.abilities.inactive_red_punchcard
                end
            end
        end

        ns.updatePowers()
        ns.updateTalents()
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

        Hekili:UpdateUseItems()
        state.swings.mh_speed, state.swings.oh_speed = UnitAttackSpeed( "player" )
    end

    RegisterEvent( "PLAYER_EQUIPMENT_CHANGED", QueueUpdate )
end


do
    local timer

    local function Update()
        ns.updateTalents()
    end

    local function QueueUpdate()
        if timer and not timer:IsCancelled() then timer:Cancel() end
        timer = C_Timer.NewTimer( 0.5, Update )
    end

    local talentEvents = {
        "TRAIT_CONFIG_CREATED",
        "ACTIVE_COMBAT_CONFIG_CHANGED",
        "STARTER_BUILD_ACTIVATION_FAILED",
        "TRAIT_CONFIG_DELETED",
        "TRAIT_CONFIG_UPDATED",
        "CONFIG_COMMIT_FAILED",
        "PLAYER_ALIVE",
        "PLAYER_UNGHOST"
    }

    for _, event in pairs( talentEvents ) do
        RegisterEvent( event, QueueUpdate )
    end
end


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

    local function UpdateEssences()
        local lastEssence = class.active_essence
        ns.updateEssences()

        if class.active_essence ~= lastEssence then
            Hekili:UpdateUseItems()
        end
    end

    --[[ for i, event in pairs( azeriteEvents ) do
        RegisterEvent( event, UpdateEssences )
    end ]]
end


local last_combat, combat_ended = 0, 0
local COMBAT_RESUME_TIME = 5

RegisterEvent( "PLAYER_REGEN_DISABLED", function( event )
    local t = GetTime()

    if t - combat_ended <= COMBAT_RESUME_TIME then
        state.combat = last_combat
    else
        state.combat = GetTime() - 0.01
    end

    if Hekili.Config and not LibStub( "AceConfigDialog-3.0" ).OpenFrames[ "Hekili" ] then
        ns.StopConfiguration()
        Hekili:UpdateDisplayVisibility()
    end

    -- Hekili:ExpireTTDs( true )
    Hekili:ForceUpdate( event ) -- Force update on entering combat since OOC refresh can be very slow (0.5s).
end )


RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    last_combat = state.combat
    combat_ended = GetTime()

    state.combat = 0

    state.swings.mh_actual = 0
    state.swings.oh_actual = 0

    C_Timer.After( 5, function ()
        if not InCombatLockdown() then
            ns.Audit( "combatExit" )
        end
    end )

    Hekili:ReleaseHolds( true )
    Hekili:UpdateDisplayVisibility()
end )


local dynamic_keys = setmetatable( {}, {
    __index = function( t, k )
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


local SpellQueueWindow = 0.4

local function UpdateSpellQueueWindow( event, variable, value )
    if variable == "SpellQueueWindow" then
        SpellQueueWindow = ( tonumber( value ) or 400 ) / 1000
    end
end

RegisterEvent( "CVAR_UPDATE", UpdateSpellQueueWindow )
RegisterEvent( "VARIABLES_LOADED", UpdateSpellQueueWindow )

C_Timer.After( 60, UpdateSpellQueueWindow )


do
    local box, text
    local info = {}

    hooksecurefunc( "ChatEdit_SendText", function( b )
        if box and box == b and text then
            local action, target = SecureCmdOptionParse( text )
            local ability = action and class.abilities[ action ]

            if ability and ability.key then
                local m = info[ ability.key ] or {}

                m.target = UnitGUID( target or "target" )
                m.time   = GetTime()

                info[ ability.key ] = m
            end

            text = nil
            return
        end

        if not box and b ~= DEFAULT_CHAT_FRAME.editBox then
            box = b

            box:HookScript( "OnTextSet", function( self )
                local t = self:GetText()
                if t and t ~= "" then text = t end
            end )
        end
    end )

    function Hekili:GetMacroCastTarget( spell, castTime, source )
        local ability = class.abilities[ spell ]
        local buffer = 0.1 + SpellQueueWindow

        if ability and ability.key then
            local m = info[ ability.key ]

            if m and abs( castTime - m.time ) < buffer then
                return m.target -- This is a GUID.
            end
        end
    end
end


local lowLevelWarned = false
local noClassWarned = false

-- Need to make caching system.
RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", "player", "target", function( event, unit, _, spellID )
    if not noClassWarned and not class.initialized then
        Hekili:Notify( UnitClass( "player" ) .. " does not have any Hekili modules loaded (yet).\nWatch for updates.", 5 )
        noClassWarned = true
    elseif not lowLevelWarned and UnitLevel( "player" ) < 70 then
        Hekili:Notify( "Hekili is designed for current content.\nUse below level 70 at your own risk.", 5 )
        lowLevelWarned = true
    end

    if unit == "player" then
        local ability = class.abilities[ spellID ]

        if ability then
            Hekili:ForceUpdate( event )
            if state.holds[ ability.key ] then Hekili:RemoveHold( ability.key, true ) end
        end
    end
end )


RegisterUnitEvent( "UNIT_SPELLCAST_START", "player", "target", function( event, unit, cast, spellID )
    if unit == "player" then
        local ability = class.abilities[ spellID ]
        if ability then
            Hekili:ForceUpdate( event )
            if state.holds[ ability.key ] then Hekili:RemoveHold( ability.key, true ) end
        end

        Hekili:ForceUpdate( event, true )
    end
end )


do
    local empowerment = state.empowerment
    local stages = empowerment.stages

    RegisterUnitEvent( "UNIT_SPELLCAST_EMPOWER_START", "player", nil, function( event, unit, cast, spellID )
        local ability = class.abilities[ spellID ]
        if not ability then return end

        wipe( stages )
        local start = GetTime()

        empowerment.spell = ability.key
        empowerment.start = start
        empowerment.active = true

        for i = 1, 4 do
            local n = GetUnitEmpowerStageDuration( "player", i - 1 )
            if n == 0 then break end

            if i == 1 then insert( stages, start + n * 0.001 )
            else insert( stages, stages[ i - 1 ] + n * 0.001 ) end
        end

        empowerment.finish = stages[ #stages ]
        empowerment.hold = empowerment.finish + GetUnitEmpowerHoldAtMaxTime( "player" ) * 0.001

        Hekili:ForceUpdate( event, true )
    end )

    RegisterUnitEvent( "UNIT_SPELLCAST_EMPOWER_STOP", "player", nil, function( event, unit, cast, spellID )
        empowerment.spell = "none"

        empowerment.active = false
        empowerment.start = 0
        empowerment.finish = 0
        empowerment.hold = 0

        Hekili:ForceUpdate( event )
    end )
end


RegisterUnitEvent( "UNIT_SPELLCAST_CHANNEL_START", "player", nil, function( event, unit, cast, spellID )
    local ability = class.abilities[ spellID ]

    if ability then
        Hekili:ForceUpdate( event )
        if state.holds[ ability.key ] then Hekili:RemoveHold( ability.key, true ) end
    end
end )


RegisterUnitEvent( "UNIT_SPELLCAST_CHANNEL_STOP", "player", nil, function( event, unit, cast, spellID )
    local ability = class.abilities[ spellID ]
    if ability then
        Hekili:ForceUpdate( event )
        if state.holds[ ability.key ] then Hekili:RemoveHold( ability.key, true ) end
    end
end )


RegisterUnitEvent( "UNIT_SPELLCAST_STOP", "player", nil, function( event, unit, cast, spellID )
    local ability = class.abilities[ spellID ]
    if ability then
        Hekili:ForceUpdate( event )
        if state.holds[ ability.key ] then Hekili:RemoveHold( ability.key, true ) end
    end
end )


RegisterUnitEvent( "UNIT_SPELLCAST_DELAYED", "player", nil, function( event, unit, _, spellID )
    local ability = class.abilities[ spellID ]

    if ability then
        local action = ability.key
        local _, _, _, start, finish = UnitCastingInfo( "player" )
        local target = select( 5, state:GetEventInfo( action, nil, nil, "CAST_FINISH", nil, true ) )

        state:RemoveSpellEvent( action, true, "CAST_FINISH" )
        state:RemoveSpellEvent( action, true, "PROJECTILE_IMPACT", true )

        if start and finish then
            if not target then target = Hekili:GetMacroCastTarget( action, start / 1000, "DELAYED" ) end
            state:QueueEvent( action, start / 1000, finish / 1000, "CAST_FINISH", target, true )

            if ability.isProjectile then
                local travel

                if ability.flightTime then
                    travel = ability.flightTime

                elseif target then
                    local u = Hekili:GetUnitByGUID( target ) or Hekili:GetNameplateUnitForGUID( target ) or "target"

                    if u then
                        local _, maxR = RC:GetRange( u )
                        maxR = maxR or select( 6, GetSpellInfo( ability.id ) ) or 40
                        travel = maxR / ability.velocity
                    end
                end

                if not travel then
                    travel = ( select( 6, GetSpellInfo( ability.id ) ) or 40 ) / ability.velocity
                end

                state:QueueEvent( ability.impactSpell or ability.key, finish / 1000, 0.05 + travel, "PROJECTILE_IMPACT", target, true )
            end
        end

        Hekili:ForceUpdate( event )
    end
end )


-- TODO:  This should be changed to stash this information and then commit it on next UNIT_SPELLCAST_START or UNIT_SPELLCAST_SUCCEEDED.
RegisterEvent( "UNIT_SPELLCAST_SENT", function ( event, unit, target_name, castID, spellID )
    Hekili:ForceUpdate( event )

    if target_name and UnitGUID( target_name ) then
        state.cast_target = UnitGUID( target_name )
        return
    end

    local gubn = Hekili:GetUnitByName( target_name )
    if gubn and UnitGUID( gubn ) then
        state.cast_target = UnitGUID( gubn )
        return
    end

    if UnitName( "target" ) == target_name then
        state.cast_target = UnitGUID( "target" )
        return
    end

    state.cast_target = nil
end )


--[[ This event is too spammy.
RegisterEvent( "CURRENT_SPELL_CAST_CHANGED", function( event, cancelled )
    Hekili:ForceUpdate( event, true )
end ) ]]


--[[ Update due to player totems.
RegisterEvent( "PLAYER_TOTEM_UPDATE", function( event )
    Hekili:ForceUpdate( event )
end ) -- TODO:  Re-evaluate whether this is necessary to force a faster update. ]]


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


local lastPower = {}

local function UNIT_POWER_FREQUENT( event, unit, power )

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

    local newPower = UnitPower( "player", Enum.PowerType[ power ] )

    if lastPower[ power ] and newPower < lastPower[ power ] then
        Hekili:ForceUpdate( event, true )
    end

    lastPower[ power ] = newPower
end
Hekili:ProfileCPU( "UNIT_POWER_FREQUENT", UNIT_POWER_FREQUENT )

RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, UNIT_POWER_FREQUENT )


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


do
    local playerInstances = {}
    local targetInstances = {}

    local instanceDB

    local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
    local ForEachAura = AuraUtil.ForEachAura

    local function StoreInstanceInfo( aura )
        local id = aura.spellId
        local model = class.auras[ id ]

        instanceDB[ aura.auraInstanceID ] = aura.isBossAura or aura.isStealable or model and ( model.shared or model.used and aura.isFromPlayerOrPlayerPet )
    end

    RegisterUnitEvent( "UNIT_AURA", "player", "target", function( event, unit, data )
        local isPlayer = ( unit == "player" )
        instanceDB = isPlayer and playerInstances or targetInstances

        if data.isFullUpdate then
            wipe( instanceDB )

            ForEachAura( unit, "HELPFUL", nil, StoreInstanceInfo, true )
            ForEachAura( unit, "HARMFUL", nil, StoreInstanceInfo, true )

            state[ unit ].updated = true
            Hekili:ForceUpdate( "UNIT_AURA_FULL", true )
            return
        end

        local forceUpdateNeeded = false

        if data.addedAuras and #data.addedAuras > 0 then
            for _, aura in ipairs( data.addedAuras ) do
                local id = aura.spellId
                local model = class.auras[ id ]

                local ofConcern = aura.isBossAura or aura.isStealable or model and ( model.shared or model.used and aura.isFromPlayerOrPlayerPet )
                instanceDB[ aura.auraInstanceID ] = ofConcern

                if ofConcern then
                    forceUpdateNeeded = true
                end
            end
        end

        if data.updatedAuraInstanceIDs and #data.updatedAuraInstanceIDs > 0 then
            for _, instance in ipairs( data.updatedAuraInstanceIDs ) do
                local aura = GetAuraDataByAuraInstanceID( unit, instance )
                local ofConcern = false

                if aura then
                    local id = aura.spellId
                    local model = class.auras[ id ]

                    ofConcern = aura.isBossAura or aura.isStealable or model and ( model.shared or model.used and aura.isFromPlayerOrPlayerPet )
                    instanceDB[ instance ] = ofConcern
                end

                if ofConcern then
                    forceUpdateNeeded = true
                end
            end
        end

        if data.removedAuraInstanceIDs and #data.removedAuraInstanceIDs > 0 then
            for _, instance in ipairs( data.removedAuraInstanceIDs ) do
                if instanceDB[ instance ] then forceUpdateNeeded = true end
                instanceDB[ instance ] = nil
            end
        end

        state[ unit ].updated = true

        if forceUpdateNeeded then Hekili:ForceUpdate( "UNIT_AURA_ITER" ) end
    end )

    RegisterEvent( "PLAYER_TARGET_CHANGED", function( event )
        instanceDB = targetInstances
        wipe( instanceDB )

        if UnitExists( "target" ) then
            ForEachAura( "target", "HELPFUL", nil, StoreInstanceInfo, true )
            ForEachAura( "target", "HARMFUL", nil, StoreInstanceInfo, true )
        end

        state.target.updated = true
        Hekili:ForceUpdate( event, true )
    end )
end



do
    local MOVEMENT_ICD = 0.5

    local lastStart = 0
    local lastEnd = 0

    RegisterEvent( "PLAYER_STARTED_MOVING", function( event )
        local now = GetTime()

        if now - lastStart > MOVEMENT_ICD then
            lastStart = now
            Hekili:ForceUpdate( event )
        end
    end )


    RegisterEvent( "PLAYER_STOPPED_MOVING", function( event )
        local now = GetTime()

        if now - lastEnd > MOVEMENT_ICD then
            lastEnd = now
            Hekili:ForceUpdate( event )
        end
    end )
end


local cast_events = {
    SPELL_CAST_START        = true,
    SPELL_CAST_FAILED       = true,
    SPELL_CAST_SUCCESS      = true,
    SPELL_DAMAGE            = true,
    SPELL_AURA_REMOVED      = true
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
    RANGE_DAMAGE            = true,
    RANGE_MISSED            = true,
    ENVIRONMENTAL_DAMAGE    = true,
    ENVIRONMENTAL_MISSED    = true
}


local direct_dmg_events = {
    SPELL_DAMAGE            = true,
    SPELL_MISSED            = true,
    SWING_DAMAGE            = true,
    SWING_MISSED            = true,
    RANGE_DAMAGE            = true,
    RANGE_MISSED            = true,
    ENVIRONMENTAL_DAMAGE    = true,
    ENVIRONMENTAL_MISSED    = true
}


local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local dmg_filtered = {
    [280705] = true, -- Laser Matrix.
    [450412] = true, -- Sentinel.
    [462952] = true, -- Squall Sailor's Citrine
}


local function IsActuallyFriend( unit )
    if not IsInGroup() then return false end
    if not UnitIsPlayer( unit ) then return false end
    if UnitInRaid( unit ) or UnitInParty( unit ) then return true end
    return false
end


local countDamage = false
local countDots = false
local countPets = false


function Hekili:UpdateDamageDetectionForCLEU()
    local profile = self.DB.profile
    local spec = rawget( profile.specs, state.spec.id )

    countDamage = spec and spec.damage or false
    countDots = spec and spec.damageDots or false
    countPets = spec and spec.damagePets or false
end


-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
local function CLEU_HANDLER( event, timestamp, subtype, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, school, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
    -- This is used by both RegisterCombatLogEvent( x ) and RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", x ).
    ns.callHook( "COMBAT_LOG_EVENT_UNFILTERED", timestamp, subtype, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, school, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

    if death_events[ subtype ] then
        if ns.isTarget( destGUID ) then
            ns.eliminateUnit( destGUID, true )
            -- Hekili:ForceUpdate( subtype )

        elseif ns.isMinion( destGUID ) then
            local npcid = destGUID:match("(%d+)-%x-$")
            npcid = npcid and tonumber( npcid )

            if npcid == state.pet.guardian_of_azeroth.id then
                state.pet.guardian_of_azeroth.summonTime = 0
            end

            ns.updateMinion( destGUID )
        end
        return
    end

    local time = GetTime()

    local amSource  = ( sourceGUID == state.GUID )
    local petSource = ( UnitExists( "pet" ) and sourceGUID == UnitGUID( "pet" ) )
    local amTarget  = ( destGUID   == state.GUID )
    local isSensePower = ( class.auras.sense_power_active and spellID == 361022 )

    if not InCombatLockdown() and not ( amSource or petSource or amTarget ) then return end

    if subtype == 'SPELL_SUMMON' and amSource then
        -- Guardian of Azeroth check.
        -- ID is 152396.
        local npcid = destGUID:match("(%d+)-%x-$")
        npcid = npcid and tonumber( npcid )

        if npcid == state.pet.guardian_of_azeroth.id then
            state.pet.guardian_of_azeroth.summonTime = time
        end

        ns.updateMinion( destGUID, time )
        return
    end

    local hostile = ( bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 ) and not IsActuallyFriend( destName )

    if dmg_events[ subtype ] and not ( amSource or petSource ) and amTarget then
        local damage, damageType

        if subtype:sub( 1, 13 ) == "ENVIRONMENTAL" then
            damageType = 1

            if subtype:sub(-7) == "_DAMAGE" then
                damage = spellName

            elseif spellName == "ABSORB" then
                damage = amount

            end

        elseif subtype:sub( 1, 5 ) == "SWING" then
            damageType = 1

            if subtype == "SWING_DAMAGE" then
                damage = spellID

            else
                if spellID == "ABSORB" then
                    damage = interrupt
                end

            end

        else -- SPELL_x
            if subtype:find( "_MISSED" ) then
                if amount == "ABSORB" then
                    damage = a
                    damageType = school or 1
                end

            else
                damage = amount
                damageType = school

            end

        end

        if damage and damage > 0 then
            ns.storeDamage( time, damage, bit.band( damageType, 0x1 ) == 1 )
        end
    end

    local minion = ns.isMinion( sourceGUID )

    if not ( amSource or petSource or isSensePower ) and not ( state.role.tank and destGUID == state.GUID ) and ( not minion or not countPets ) then
        return
    end

    if amSource then
        if cast_events[ subtype ] then
            local ability = class.abilities[ spellID ]

            if ability then
                if subtype == "SPELL_CAST_START" then
                    local _, _, _, start, finish = UnitCastingInfo( "player" )

                    if destGUID:len() == 0 then
                        destGUID = Hekili:GetMacroCastTarget( ability.key, GetTime(), "START" ) or UnitGUID( "target" )
                    end

                    if start then
                        state:QueueEvent( ability.key, start / 1000, finish / 1000, "CAST_FINISH", destGUID, true )

                        if ability.isProjectile then
                            local travel

                            if ability.flightTime then
                                travel = ability.flightTime

                            elseif destGUID then
                                local unit = Hekili:GetUnitByGUID( destGUID ) or Hekili:GetNameplateUnitForGUID( destGUID ) or "target"

                                if unit then
                                    local _, maxR = RC:GetRange( unit )
                                    maxR = maxR or select( 6, GetSpellInfo( ability.id ) ) or 40
                                    travel = maxR / ability.velocity
                                end
                            end

                            if not travel then travel = ( select( 6, GetSpellInfo( ability.id ) ) or 40 ) / ability.velocity end

                            state:QueueEvent( ability.impactSpell or ability.key, finish / 1000, travel, "PROJECTILE_IMPACT", destGUID, true )
                        end
                    end

                elseif subtype == "SPELL_CAST_FAILED" then
                    if state:RemoveSpellEvent( ability.key, true, "CAST_FINISH" ) then -- remove next cast finish.
                        if ability.isProjectile then state:RemoveSpellEvent( ability.key, true, "PROJECTILE_IMPACT", true ) end -- remove last impact.
                    end
                    -- Hekili:ForceUpdate( "SPELL_CAST_FAILED" ) ]]

                elseif subtype == "SPELL_AURA_REMOVED" and ability.channeled then
                    state:RemoveSpellEvents( ability.key, true ) -- remove ticks, finish, impacts.
                    -- Hekili:ForceUpdate( "SPELL_AURA_REMOVED_CHANNEL" )

                elseif subtype == "SPELL_CAST_SUCCESS" then
                    state:RemoveSpellEvent( ability.key, true, "CAST_FINISH" ) -- remove next cast finish.

                    if ability.channeled then
                        local _, _, _, start, finish = UnitChannelInfo( "player" )

                        if destGUID:len() == 0 then
                            destGUID = Hekili:GetMacroCastTarget( ability.key, GetTime(), "START" ) or UnitGUID( "target" )
                        end

                        if start then
                            start = start / 1000
                            finish = finish / 1000

                            state:QueueEvent( ability.key, start, finish, "CHANNEL_FINISH", destGUID, true )

                            local tick_time = ability.tick_time or ( ability.aura and class.auras[ ability.aura ].tick_time )

                            if tick_time and tick_time > 0 then
                                local tick = tick_time

                                while ( start + tick < finish ) do
                                    state:QueueEvent( ability.key, start, start + tick, "CHANNEL_TICK", destGUID, true )
                                    tick = tick + tick_time
                                end
                            end
                        end
                    end

                    if ability.isProjectile and not state:IsInFlight( ability.key, true ) then
                        local travel

                        if ability.flightTime then
                            travel = ability.flightTime

                        elseif destGUID then
                            local unit = Hekili:GetUnitByGUID( destGUID ) or Hekili:GetNameplateUnitForGUID( destGUID ) or "target"

                            if unit then
                                local _, maxR = RC:GetRange( unit )
                                maxR = maxR or select( 6, GetSpellInfo( ability.id ) ) or 40
                                travel = maxR / ability.velocity
                            end
                        end

                        if not travel then travel = state.target.maxR / ability.velocity end

                        state:QueueEvent( ability.impactSpell or ability.key, time, travel, "PROJECTILE_IMPACT", destGUID, true )
                    end

                    state:AddToHistory( ability.key, destGUID )

                elseif subtype == "SPELL_DAMAGE" then
                    -- Could be an impact.
                    if state:RemoveSpellEvent( ability.key, true, "PROJECTILE_IMPACT" ) then
                        Hekili:ForceUpdate( "PROJECTILE_IMPACT" )
                    end
                end
            end

            state.gcd.lastStart = max( state.gcd.lastStart, ( GetSpellCooldown( 61304 ) ) )
            -- if subtype ~= "SPELL_DAMAGE" then Hekili:ForceUpdate( subtype, true ) end
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
    elseif ( amSource or petSource or isSensePower ) or ( countPets and minion ) or ( sourceGUID == destGUID and sourceGUID == UnitGUID( 'target' ) ) then
        --[[ if aura_events[ subtype ] then
            if subtype == "SPELL_CAST_SUCCESS" or state.GUID == destGUID then
                if class.abilities[ spellID ] or class.auras[ spellID ] then
                    Hekili:ForceUpdate( subtype, true )
                end
            end

            if UnitGUID( 'target' ) == destGUID then
                if class.auras[ spellID ] then Hekili:ForceUpdate( subtype ) end
            end
        end ]]

        local aura = class.auras and class.auras[ spellID ]

        if aura then
            if hostile and sourceGUID ~= destGUID and not aura.friendly then
                -- Aura Tracking
                if subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                    ns.trackDebuff( spellID, destGUID, time, true )
                    if ( not minion or countPets ) and countDots then ns.updateTarget( destGUID, time, amSource, spellID ) end

                    --[[ if spellID == 48108 or spellID == 48107 then
                        Hekili:ForceUpdate( "SPELL_AURA_SUPER", true )
                    end ]]

                elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                    ns.trackDebuff( spellID, destGUID, time )
                    if countDots and ( not minion or countPets ) then
                        ns.updateTarget( destGUID, time, amSource )
                    end

                elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                    ns.trackDebuff( spellID, destGUID )

                end

            elseif ( amSource or petSource or isSensePower ) and aura.friendly then -- friendly effects
                if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                    ns.trackDebuff( spellID, destGUID, time, true )

                elseif subtype == 'SPELL_PERIODIC_HEAL' or subtype == 'SPELL_PERIODIC_MISSED' then
                    ns.trackDebuff( spellID, destGUID, time )

                elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                    ns.trackDebuff( spellID, destGUID )

                end

            end

        end

        if hostile and ( countDots and dmg_events[ subtype ] or direct_dmg_events[ subtype ] ) and not dmg_filtered[ spellID ] then
            -- Don't wipe overkill targets in rested areas (it is likely a dummy).
            -- Interrupt is actually overkill.
            if not IsResting() and ( ( ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) and interrupt > 0 ) or ( subtype == "SWING_DAMAGE" and spellName > 0 ) ) and ns.isTarget( destGUID ) then
                ns.eliminateUnit( destGUID, true )
                -- Hekili:ForceUpdate( "SPELL_DAMAGE_OVERKILL" )
            elseif not ( subtype == "SPELL_MISSED" and amount == "IMMUNE" ) then
                ns.updateTarget( destGUID, time, amSource, spellID )
            end
        end
    end
end
Hekili:ProfileCPU( "CLEU_HANDLER", CLEU_HANDLER )
RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function ( event ) CLEU_HANDLER( event, CombatLogGetCurrentEventInfo() ) end )


do
    local function UNIT_COMBAT( event, unit, action, _, amount )
        if amount > 0 and action == 'HEAL' then
            ns.storeHealing( GetTime(), amount )
        end
    end
    Hekili:ProfileCPU( "UNIT_COMBAT", UNIT_COMBAT )
    RegisterUnitEvent( "UNIT_COMBAT", "player", nil, UNIT_COMBAT )
end


local keys = ns.hotkeys
Hekili.KeybindInfo = keys
local updatedKeys = {}

local bindingSubs = {
    { "CTRL%-", "C" },
    { "ALT%-", "A" },
    { "SHIFT%-", "S" },
    { "STRG%-", "ST" },
    { "%s+", "" },
    { "NUMPAD", "N" },
    { "PLUS", "+" },
    { "MINUS", "-" },
    { "MULTIPLY", "*" },
    { "DIVIDE", "/" },
    { "BUTTON", "M" },
    { "MOUSEWHEELUP", "MwU" },
    { "MOUSEWHEELDOWN", "MwD" },
    { "MOUSEWHEEL", "Mw" },
    { "DOWN", "Dn" },
    { "UP", "Up" },
    { "PAGE", "Pg" },
    { "BACKSPACE", "BkSp" },
    { "DECIMAL", "." },
    { "CAPSLOCK", "CAPS" },
}

local function improvedGetBindingText( binding )
    if not binding then return "" end

    for i, rep in ipairs( bindingSubs ) do
        binding = binding:gsub( rep[1], rep[2] )
    end

    return binding
end


local itemToAbility = {
    [5512]   = "healthstone",
    [177278] = "phial_of_serenity"
}


local function StoreKeybindInfo( page, key, aType, id, console )

    if not key or not aType or not id then return end

    local action, ability

    if aType == "item" then
        local item, link = CGetItemInfo( id )
        ability = item and ( class.abilities[ item ] or class.abilities[ link ] )
        action = ability and ability.key

        if not action then
            if itemToAbility[ id ] then
                action = itemToAbility[ id ]
            else
                for k, v in pairs( class.potions ) do
                    if v.item == id then
                        action = "potion"
                        break
                    end
                end
            end
        end
    else
        ability = class.abilities[ id ]
        action = ability and ability.key
    end

    if action then
        keys[ action ] = keys[ action ] or {
            lower = {},
            upper = {},
            console = {}
        }

        if console == "cPort" then
            local newKey = key:gsub( ":%d+:%d+:0:0", ":0:0:0:0" )
            keys[ action ].console[ page ] = newKey
        else
            keys[ action ].upper[ page ] = improvedGetBindingText( key )
            keys[ action ].lower[ page ] = lower( keys[ action ].upper[ page ] )
        end
        updatedKeys[ action ] = true

        local bind = ability and ability.bind

        if bind then
            if type( bind ) == 'table' then
                for _, b in ipairs( bind ) do
                    keys[ b ] = keys[ b ] or {
                        lower = {},
                        upper = {},
                        console = {}
                    }

                    keys[ b ].lower[ page ] = keys[ action ].lower[ page ]
                    keys[ b ].upper[ page ] = keys[ action ].upper[ page ]
                    keys[ b ].console[ page ] = keys[ action ].console[ page ]

                    updatedKeys[ b ] = true
                end
            else
                keys[ bind ] = keys[ bind ] or {
                    lower = {},
                    upper = {},
                    console = {}
                }

                keys[ bind ].lower[ page ] = keys[ action ].lower[ page ]
                keys[ bind ].upper[ page ] = keys[ action ].upper[ page ]
                keys[ bind ].console[ page ] = keys[ action ].console[ page ]

                updatedKeys[ bind ] = true
            end
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


local slotsUsed = {}

local function ReadKeybindings( event )
        if not Hekili:IsValidSpec() then return end

        for k, v in pairs( keys ) do
            wipe( v.console )
            wipe( v.upper )
            wipe( v.lower )
        end

        -- Bartender4 support; if BT4 bindings are set, use them, otherwise fall back on default UI bindings below.
        -- This will still get viewed as misleading...
        if _G["Bartender4"] then
            table.wipe( slotsUsed )

            for i = 1, 180 do
                local keybind = "CLICK BT4Button" .. i .. ":Keybind"
                local bar = ceil( i / 12 )

                if GetBindingKey( keybind ) then
                    StoreKeybindInfo( bar, GetBindingKey( keybind ), GetActionInfo( i ) )
                    slotsUsed[ i ] = true
                end
            end

        -- Use ElvUI's actionbars only if they are actually enabled.
        elseif _G["ElvUI"] and _G[ "ElvUI_Bar1Button1" ] then
            table.wipe( slotsUsed )

            for i = 1, 15 do
                for b = 1, 12 do
                    local btn = _G["ElvUI_Bar" .. i .. "Button" .. b]

                    if btn then
                        local binding = btn.bindstring or btn.keyBoundTarget or ( "CLICK " .. btn:GetName() .. ":LeftButton" )

                        if i > 6 then
                            -- Checking whether bar is active.
                            local bar = _G["ElvUI_Bar" .. i]

                            if not bar or not bar.db.enabled then
                                binding = "ACTIONBUTTON" .. b
                            end
                        end

                        local action, aType = btn._state_action, "spell"

                        if action and type( action ) == "number" then
                            slotsUsed[ action ] = true

                            binding = GetBindingKey( binding )
                            action, aType = GetActionInfo( action )
                            if binding then StoreKeybindInfo( i, binding, action, aType ) end
                        end
                    end
                end
            end
        end

            for i = 1, 12 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 1, GetBindingKey( "ACTIONBUTTON" .. i ), GetActionInfo( i ) )
                end
            end

            for i = 13, 24 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 2, GetBindingKey( "ACTIONBUTTON" .. i - 12 ), GetActionInfo( i ) )
                end
            end

            for i = 25, 36 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 3, GetBindingKey( "MULTIACTIONBAR3BUTTON" .. i - 24 ), GetActionInfo( i ) )
                end
            end

            for i = 37, 48 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 4, GetBindingKey( "MULTIACTIONBAR4BUTTON" .. i - 36 ), GetActionInfo( i ) )
                end
            end

            for i = 49, 60 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 5, GetBindingKey( "MULTIACTIONBAR2BUTTON" .. i - 48 ), GetActionInfo( i ) )
                end
            end

            for i = 61, 72 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 6, GetBindingKey( "MULTIACTIONBAR1BUTTON" .. i - 60 ), GetActionInfo( i ) )
                end
            end

            for i = 72, 143 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 7 + floor( ( i - 72 ) / 12 ), GetBindingKey( "ACTIONBUTTON" .. 1 + ( i - 72 ) % 12 ), GetActionInfo( i + 1 ) )
                end
            end

            for i = 145, 156 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 13, GetBindingKey( "MULTIACTIONBAR5BUTTON" .. i - 144 ), GetActionInfo( i ) )
                end
            end

            for i = 157, 168 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 14, GetBindingKey( "MULTIACTIONBAR6BUTTON" .. i - 156 ), GetActionInfo( i ) )
                end
            end

            for i = 169, 180 do
                if not slotsUsed[ i ] then
                    StoreKeybindInfo( 15, GetBindingKey( "MULTIACTIONBAR7BUTTON" .. i - 168 ), GetActionInfo( i ) )
                end
            end

        if _G.ConsolePort then
            for i = 1, 180 do
                local action, id = GetActionInfo( i )

                if action and id then
                    local bind = ConsolePort:GetActionBinding( i )
                    local key, mod = ConsolePort:GetCurrentBindingOwner( bind )

                    if key then
                        StoreKeybindInfo( math.ceil( i / 12 ), ConsolePort:GetFormattedButtonCombination( key, mod ), action, id, "cPort" )
                    end
                end
            end
        end

        for k, v in pairs( keys ) do
            local ability = class.abilities[ k ]

            if ability and ability.bind then
                if type( ability.bind ) == 'table' then
                    for _, b in ipairs( ability.bind ) do
                        for page, value in pairs( v.lower ) do
                            keys[ b ] = keys[ b ] or {
                                lower = {},
                                upper = {},
                                console = {}
                            }
                            keys[ b ].lower[ page ] = value
                            keys[ b ].upper[ page ] = v.upper[ page ]
                            keys[ b ].console[ page ] = v.console[ page ]
                        end
                    end
                else
                    for page, value in pairs( v.lower ) do
                        keys[ ability.bind ] = keys[ ability.bind ] or {
                            lower = {},
                            upper = {},
                            console = {}
                        }
                        keys[ ability.bind ].lower[ page ] = value
                        keys[ ability.bind ].upper[ page ] = v.upper[ page ]
                        keys[ ability.bind ].console[ page ] = v.console[ page ]
                    end
                end
            end
        end

        -- This is also the right time to update pet-based target detection.
        Hekili:SetupPetBasedTargetDetection()
end
ns.ReadKeybindings = ReadKeybindings

local function ReadOneKeybinding( event, slot )
    if not Hekili:IsValidSpec() then return end
    if not slot or slot == 0 then return end

    local actionBarNumber = ceil( slot / 12 )
    local keyNumber = slot - ( 12 * ( actionBarNumber - 1 ) )

    local ability
    local completed = false

    -- Bartender4 support; if BT4 bindings are set, use them, otherwise fall back on default UI bindings below.
    -- This will still get viewed as misleading...
    if _G["Bartender4"] then
        local keybind = "CLICK BT4Button" .. slot .. ":Keybind"

        if GetBindingKey( keybind ) then
            StoreKeybindInfo( actionBarNumber, GetBindingKey( keybind ), GetActionInfo( slot ) )
            completed = true
        end

    elseif _G["ElvUI"] and _G["ElvUI_Bar1Button1"] then
        local btn = _G[ "ElvUI_Bar" .. actionBarNumber .. "Button" .. keyNumber ]

        if btn then
            local binding = btn.bindstring or btn.keyBoundTarget or ( " CLICK " .. btn:GetName() .. ":LeftButton" )

            if actionBarNumber > 6 then
                -- Checking whether bar is active.
                local bar = _G[ "ElvUI_Bar" .. actionBarNumber ]

                if not bar or not bar.db.enabled then
                    binding = "ACTIONBUTTON" .. keyNumber
                end
            end

            local action, aType = btn._state_action, "spell"

            if action and type( action ) == "number" then
                binding = GetBindingKey( binding )
                action, aType = GetActionInfo( action )
                if binding then StoreKeybindInfo( actionBarNumber, binding, action, aType ) end
            end
        end
    end

    if not completed then
        if actionBarNumber == 1 or actionBarNumber == 2 or ( actionBarNumber > 6  and actionBarNumber < 13 ) then
            ability = StoreKeybindInfo( keyNumber, GetBindingKey( "ACTIONBUTTON" .. keyNumber ), GetActionInfo( slot ) )

        elseif actionBarNumber > 2 and actionBarNumber < 5 then
            ability = StoreKeybindInfo( actionBarNumber, GetBindingKey( "MULTIACTIONBAR" .. actionBarNumber .. "BUTTON" .. keyNumber ), GetActionInfo( slot ) )

        elseif actionBarNumber == 5 then
            ability = StoreKeybindInfo( actionBarNumber, GetBindingKey( "MULTIACTIONBAR2BUTTON" .. keyNumber ), GetActionInfo( slot ) )

        elseif actionBarNumber == 6 then
            ability = StoreKeybindInfo( actionBarNumber, GetBindingKey( "MULTIACTIONBAR1BUTTON" .. keyNumber ), GetActionInfo( slot ) )

        elseif actionBarNumber == 13 then
            ability = StoreKeybindInfo( actionBarNumber, GetBindingKey( "MULTIACTIONBAR5BUTTON" .. keyNumber ), GetActionInfo( slot ) )

        elseif actionBarNumber == 14 then
            ability = StoreKeybindInfo( actionBarNumber, GetBindingKey( "MULTIACTIONBAR6BUTTON" .. keyNumber ), GetActionInfo( slot ) )

        elseif actionBarNumber == 15 then
            ability = StoreKeybindInfo( actionBarNumber, GetBindingKey( "MULTIACTIONBAR7BUTTON" .. keyNumber ), GetActionInfo( slot ) )

        end
    end

    if _G.ConsolePort then
        local action, id = GetActionInfo( slot )

        if action and id then
            local bind = ConsolePort:GetActionBinding( slot )
            local key, mod = ConsolePort:GetCurrentBindingOwner( bind )

            if key then
                ability = StoreKeybindInfo( actionBarNumber, ConsolePort:GetFormattedButtonCombination( key, mod ), action, id, "cPort" )
            end
        end
    end

    ability = ability and class.abilities[ ability ]

    if ability and ability.bind then
        if type( ability.bind ) == 'table' then
            for _, b in ipairs( ability.bind ) do
                for page, value in pairs( v.lower ) do
                    keys[ b ] = keys[ b ] or {
                        lower = {},
                        upper = {},
                        console = {}
                    }
                    keys[ b ].lower[ page ] = value
                    keys[ b ].upper[ page ] = v.upper[ page ]
                    keys[ b ].console[ page ] = v.console[ page ]
                end
            end
        else
            for page, value in pairs( v.lower ) do
                keys[ ability.bind ] = keys[ ability.bind ] or {
                    lower = {},
                    upper = {},
                    console = {}
                }
                keys[ ability.bind ].lower[ page ] = value
                keys[ ability.bind ].upper[ page ] = v.upper[ page ]
                keys[ ability.bind ].console[ page ] = v.console[ page ]
            end
        end
    end

    -- This is also the right time to update pet-based target detection.
    Hekili:SetupPetBasedTargetDetection()
end


local allTimer

local function DelayedUpdateKeybindings( event )
    if allTimer and not allTimer:IsCancelled() then allTimer:Cancel() end
    allTimer = C_Timer.After( 0.2, function()
        ReadKeybindings( event )
    end )
end

--[[ local function DelayedUpdateOneKeybinding( event, slot )
    if oneTimer and not oneTimer:IsCancelled() then oneTimer:Cancel() end
    oneTimer = C_Timer.After( 0.2, function() ReadOneKeybinding( event, slot ) end )
end ]]

RegisterEvent( "UPDATE_BINDINGS", DelayedUpdateKeybindings )
RegisterEvent( "SPELLS_CHANGED", DelayedUpdateKeybindings )
RegisterEvent( "ACTIONBAR_SHOWGRID", DelayedUpdateKeybindings )
RegisterEvent( "ACTIONBAR_HIDEGRID", DelayedUpdateKeybindings )
-- RegisterEvent( "ACTIONBAR_PAGE_CHANGED", DelayedUpdateKeybindings )
-- RegisterEvent( "UPDATE_SHAPESHIFT_FORM", DelayedUpdateKeybindings )

if Hekili.IsWrath() then
    RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED", DelayedUpdateKeybindings )
else
    RegisterEvent( "ACTIVE_PLAYER_SPECIALIZATION_CHANGED", DelayedUpdateKeybindings )
    RegisterEvent( "TRAIT_CONFIG_UPDATED", DelayedUpdateKeybindings )
end



if select( 2, UnitClass( "player" ) ) == "DRUID" then
    local prowlOrder = { 8, 7, 1, 2, 3, 4, 5, 6, 10, 9, 13, 14, 15 }
    local catOrder = { 7, 8, 1, 2, 3, 4, 5, 6, 10, 9, 13, 14, 15 }
    local bearOrder = { 9, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 14, 15, 1 }
    local owlOrder = { 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 13, 14, 15 }
    local defaultOrder = { 1, 2, 3, 4, 5, 6, 10, 7, 8, 9, 13, 14, 15 }

    function Hekili:GetBindingForAction( key, display, i )
        if not key then return "" end

        local ability = class.abilities[ key ]
        key = ability and ability.key or key

        local override = state.spec.id
        local overrideType = ability and ability.item and "items" or "abilities"

        override = override and rawget( self.DB.profile.specs, override )
        override = override and override[ overrideType ][ key ]
        override = override and override.keybind

        if override and override ~= "" then
            return override
        end

        if not keys[ key ] then return "" end

        local caps, console = true, false

        local queued = ( i or 1 ) > 1 and display.keybindings.separateQueueStyle

        if display then
            caps = not ( queued and display.keybindings.queuedLowercase or display.keybindings.lowercase )
            console = ConsolePort ~= nil and display.keybindings.cPortOverride
        end

        local db = console and keys[ key ].console or ( caps and keys[ key ].upper or keys[ key ].lower )

        local output, source

        local order = defaultOrder
        -- TODO: These checks should use actual aura data rather than potential stale/manipulated virtual state data.
        if class.file == "DRUID" then
            order = ( state.prowling and prowlOrder ) or ( state.buff.cat_form.up and catOrder ) or ( state.buff.bear_form.up and bearOrder ) or ( state.buff.moonkin_form.up and owlOrder ) or order
        end

        if order then
            for _, n in ipairs( order ) do
                output = db[ n ]

                if output then
                    source = n
                    break
                end
            end
        end

        output = output or ""
        source = source or -1

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
    local stealthedOrder = { 7, 8, 1, 2, 3, 4, 5, 6, 9, 10, 13, 14, 15 }
    local defaultOrder = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15 }

    function Hekili:GetBindingForAction( key, display, i )
        if not key then return "" end

        local ability = class.abilities[ key ]
        key = ability and ability.key or key

        local override = state.spec.id
        local overrideType = ability and ability.item and "items" or "abilities"

        override = override and rawget( self.DB.profile.specs, override )
        override = override and override[ overrideType ][ key ]
        override = override and override.keybind

        if override and override ~= "" then
            return override
        end

        if not keys[ key ] then
            return ""
        end

        local queued = ( i or 1 ) > 1 and display.keybindings.separateQueueStyle

        local caps, console = true, false
        if display then
            caps = not ( queued and display.keybindings.queuedLowercase or display.keybindings.lowercase )
            console = ConsolePort ~= nil and display.keybindings.cPortOverride
        end

        local db = console and keys[ key ].console or ( caps and keys[ key ].upper or keys[ key ].lower )

        local output, source
        local order = state.stealthed.all and stealthedOrder or defaultOrder

        for _, n in ipairs( order ) do
            output = db[ n ]

            if output then
                source = n
                break
            end
        end

        output = output or ""
        source = source or -1

        if output ~= "" and console then
            local size = output:match( "Icons(%d%d)" )
            size = tonumber(size)

            if size then
                local margin = floor( size * display.keybindings.cPortZoom * 0.5 )
                output = output:gsub( ":0|t", ":0:" .. size .. ":" .. size .. ":" .. margin .. ":" .. ( size - margin ) .. ":" .. margin .. ":" .. ( size - margin ) .. "|t" )
            end
        end

        return output, source
    end

else
    function Hekili:GetBindingForAction( key, display, i )
        local ability = class.abilities[ key ]
        key = ability and ability.key or key

        local override = state.spec.id
        local overrideType = ability and ability.item and "items" or "abilities"

        override = override and rawget( self.DB.profile.specs, override )
        override = override and override[ overrideType ][ key ]
        override = override and override.keybind

        if override and override ~= "" then
            return override
        end

        if not keys[ key ] then return "" end

        local queued = ( i or 1 ) > 1 and display.keybindings.separateQueueStyle

        local caps, console = true, false
        if display then
            caps = not ( queued and display.keybindings.queuedLowercase or display.keybindings.lowercase )
            console = ConsolePort ~= nil and display.keybindings.cPortOverride
        end

        local db = console and keys[ key ].console or ( caps and keys[ key ].upper or keys[ key ].lower )

        local output, source

        for _, n in ipairs( { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15 } ) do
            output = db[ n ]

            if output then
                source = n
                break
            end
        end

        output = output or ""
        source = source or -1

        if output ~= "" and console then
            local size = output:match( "Icons(%d%d)" )
            size = tonumber(size)

            if size then
                local margin = floor( size * display.keybindings.cPortZoom * 0.5 )
                output = output:gsub( ":0:0:0:0|t", ":0:0:0:0:" .. size .. ":" .. size .. ":" .. margin .. ":" .. ( size - margin ) .. ":" .. margin .. ":" .. ( size - margin ) .. "|t" )
            end
        end

        return output, source
    end
end
