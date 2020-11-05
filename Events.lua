-- Events.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State
local PTR = ns.PTR
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
local RC = LibStub( "LibRangeCheck-2.0" )


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


local function GenericOnEvent( self, event, ... )
    local eventHandlers = handlers[ event ]

    if not eventHandlers then return end

    for i, handler in pairs( eventHandlers ) do
        handler( event, ... )
        handlerCount[ event .. "_" .. i ] = ( handlerCount[ event .. "_" .. i ] or 0 ) + 1
    end
end

local function UnitSpecificOnEvent( self, event, unit, ... )
    local unitFrame = unitHandlers[ unit ]

    if unitFrame then
        local eventHandlers = unitFrame.events[ event ]

        if not eventHandlers then return end

        for i, handler in pairs( eventHandlers ) do
            handler( event, unit, ... )
            handlerCount[ event .. "_" .. unit .. "_" .. i ] = ( handlerCount[ event .. "_" .. unit .. "_" .. i ] or 0 ) + 1
        end
    end
end

function ns.StartEventHandler()
    events:SetScript( "OnEvent", GenericOnEvent )

    for unit, unitFrame in pairs( unitHandlers ) do
        unitFrame:SetScript( "OnEvent", UnitSpecificOnEvent )
    end

    events:SetScript( "OnUpdate", function( self, elapsed )
        Hekili.freshFrame = true
    end )

    Hekili:RunItemCallbacks()
    Hekili:RunSpellCallbacks()
end


function ns.StopEventHandler()
    events:SetScript( "OnEvent", nil )

    for unit, unitFrame in pairs( unitHandlers ) do
        unitFrame:SetScript( "OnEvent", nil )
    end

    events:SetScript( "OnUpdate", nil )
end


ns.RegisterEvent = function( event, handler )

    handlers[ event ] = handlers[ event ] or {}
    insert( handlers[ event ], handler )

    events:RegisterEvent( event )

    Hekili:ProfileCPU( event .. "_" .. #handlers[event], handler )

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


do
    local updatedEquippedItem = false

    local function CheckForEquipmentUpdates()
        if updatedEquippedItem then
            updatedEquippedItem = false
            ns.updateGear()
        end
    end

    RegisterEvent( "GET_ITEM_INFO_RECEIVED", function( event, itemID, success )
        local callbacks = itemCallbacks[ itemID ]

        if callbacks then
            for i, func in ipairs( callbacks ) do
                func( success )
                callbacks[ i ] = nil
            end

            if state.set_bonus[ itemID ] > 0 then
                updatedEquippedItem = true
                C_Timer.After( 0.5, CheckForEquipmentUpdates )
            end

            itemCallbacks[ itemID ] = nil
        end
    end )
end

function Hekili:ContinueOnItemLoad( itemID, func )
    --[[ if C_Item.IsItemDataCachedByID( itemID ) then
        func( true )
        return
    end ]]

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


RegisterEvent( "SPELL_DATA_LOAD_RESULT", function( event, spellID, success )
    local callbacks = spellCallbacks[ spellID ]

    if callbacks then
        for i = #callbacks, 1, -1 do
            if not callbacks[ i ]( true ) == false then remove( callbacks, i ) end
        end

        if #callbacks == 0 then
            spellCallbacks[ spellID ] = nil
        end
    end
end )


function Hekili:ContinueOnSpellLoad( spellID, func )
    --[[ if C_Spell.IsSpellDataCached( spellID ) then
        func( true )
        return
    end ]]

    local callbacks = spellCallbacks[ spellID ] or {}
    insert( callbacks, func )
    spellCallbacks[ spellID ] = callbacks

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
            ns.updateGear()
            itemAuditComplete = true
        end
    end
end


local OnFirstEntrance
OnFirstEntrance = function ()
    Hekili.PLAYER_ENTERING_WORLD = true
    Hekili:SpecializationChanged()
    Hekili:RestoreDefaults()

    ns.checkImports()
    ns.updateGear()

    if state.combat == 0 and InCombatLockdown() then
        state.combat = GetTime() - 0.01
        Hekili:UpdateDisplayVisibility()
    end

    Hekili:BuildUI()
    UnregisterEvent( "PLAYER_ENTERING_WORLD", OnFirstEntrance )
end
RegisterEvent( "PLAYER_ENTERING_WORLD", OnFirstEntrance )


do
    local pendingChange = false

    local updateSpells
    
    updateSpells = function()
        if InCombatLockdown() then
            C_Timer.After( 10, updateSpells )
            return
        end

        if pendingChange then
            for k, v in pairs( class.abilities ) do
                if v.autoTexture then
                    v.texture = GetSpellTexture( v.id )
                end
            end
            pendingChange = false
        end
    end

    RegisterEvent( "SPELLS_CHANGED", function ()
        pendingChange = true
        updateSpells()
    end )
end



-- ACTIVE_TALENT_GROUP_CHANGED fires 2x on talent swap.  Uggh, why?
do
    local lastChange = 0

    RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED", function ( event, from, to )
        local now = GetTime()
        if now - lastChange > 4 then
            Hekili:SpecializationChanged()
            Hekili:ForceUpdate( event )
            lastChange = now
        end
    end )
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

end


-- TBD:  Consider making `boss' a check to see whether the current unit is a boss# unit instead.
RegisterEvent( "ENCOUNTER_START", function ( _, id, name, difficulty )
    state.encounterID = id
    state.encounterName = name
    state.encounterDifficulty = difficulty
end )

RegisterEvent( "ENCOUNTER_END", function ()
    state.encounterID = 0
    state.encounterName = "None"
    state.encounterDifficulty = 0
end )


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
        local e = state.essence

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
                
        class.essence_unscripted = ( class.active_essence and not self:IsEssenceScripted( class.active_essence ) ) or false

        self:LoadItemScripts()
    end


--[[ Corruption Effects:
    bonus_id={ 6537 }, stats={ 100% Cor [25.0000] }, effects={ Twilight Devastation (id=318276, index=2, type=equip) }
    bonus_id={ 6538 }, stats={ 100% Cor [50.0000] }, effects={ Twilight Devastation (id=318477, index=2, type=equip) }
    bonus_id={ 6539 }, stats={ 100% Cor [75.0000] }, effects={ Twilight Devastation (id=318478, index=2, type=equip) }
    bonus_id={ 6540 }, stats={ 100% Cor [15.0000] }, effects={ Void Ritual (id=318286, index=2, type=equip) }
    bonus_id={ 6541 }, stats={ 100% Cor [35.0000] }, effects={ Void Ritual (id=318479, index=2, type=equip) }
    bonus_id={ 6542 }, stats={ 100% Cor [66.0000] }, effects={ Void Ritual (id=318480, index=2, type=equip) }
    bonus_id={ 6543 }, stats={ 100% Cor [10.0000] }, effects={ Twisted Appendage (id=318481, index=2, type=equip) }
    bonus_id={ 6544 }, stats={ 100% Cor [35.0000] }, effects={ Twisted Appendage (id=318482, index=2, type=equip) }
    bonus_id={ 6545 }, stats={ 100% Cor [66.0000] }, effects={ Twisted Appendage (id=318483, index=2, type=equip) }
    bonus_id={ 6546 }, stats={ 100% Cor [15.0000] }, effects={ Glimpse of Clarity (id=318239, index=2, type=equip) }
    bonus_id={ 6547 }, stats={ 100% Cor [12.0000] }, effects={ Ineffable Truth (id=318303, index=2, type=equip) }
    bonus_id={ 6548 }, stats={ 100% Cor [30.0000] }, effects={ Ineffable Truth (id=318484, index=2, type=equip) }
    bonus_id={ 6549 }, stats={ 100% Cor [25.0000] }, effects={ Echoing Void (id=318280, index=2, type=equip) }
    bonus_id={ 6550 }, stats={ 100% Cor [35.0000] }, effects={ Echoing Void (id=318485, index=2, type=equip) }
    bonus_id={ 6551 }, stats={ 100% Cor [60.0000] }, effects={ Echoing Void (id=318486, index=2, type=equip) }
    bonus_id={ 6552 }, stats={ 100% Cor [20.0000] }, effects={ Infinite Stars (id=318274, index=2, type=equip) }
    bonus_id={ 6553 }, stats={ 100% Cor [50.0000] }, effects={ Infinite Stars (id=318487, index=2, type=equip) }
    bonus_id={ 6554 }, stats={ 100% Cor [75.0000] }, effects={ Infinite Stars (id=318488, index=2, type=equip) }
    bonus_id={ 6555 }, stats={ 100% Cor [15.0000] }, effects={ Racing Pulse (id=318266, index=2, type=equip) }
    bonus_id={ 6556 }, stats={ 100% Cor [15.0000] }, effects={ Deadly Momentum (id=318268, index=2, type=equip) }
    bonus_id={ 6557 }, stats={ 100% Cor [15.0000] }, effects={ Honed Mind (id=318269, index=2, type=equip) }
    bonus_id={ 6558 }, stats={ 100% Cor [15.0000] }, effects={ Surging Vitality (id=318270, index=2, type=equip) }
    bonus_id={ 6559 }, stats={ 100% Cor [20.0000] }, effects={ Racing Pulse (id=318492, index=2, type=equip) }
    bonus_id={ 6560 }, stats={ 100% Cor [35.0000] }, effects={ Racing Pulse (id=318496, index=2, type=equip) }
    bonus_id={ 6561 }, stats={ 100% Cor [20.0000] }, effects={ Deadly Momentum (id=318493, index=2, type=equip) }
    bonus_id={ 6562 }, stats={ 100% Cor [35.0000] }, effects={ Deadly Momentum (id=318497, index=2, type=equip) }
    bonus_id={ 6563 }, stats={ 100% Cor [20.0000] }, effects={ Honed Mind (id=318494, index=2, type=equip) }
    bonus_id={ 6564 }, stats={ 100% Cor [35.0000] }, effects={ Honed Mind (id=318498, index=2, type=equip) }
    bonus_id={ 6565 }, stats={ 100% Cor [20.0000] }, effects={ Surging Vitality (id=318495, index=2, type=equip) }
    bonus_id={ 6566 }, stats={ 100% Cor [35.0000] }, effects={ Surging Vitality (id=318499, index=2, type=equip) }
    bonus_id={ 6567 }, stats={ 100% Cor [35.0000] }, effects={ Devour Vitality (id=318294, index=2, type=equip) }
    bonus_id={ 6568 }, stats={ 100% Cor [25.0000] }, effects={ Whispered Truths (id=316780, index=2, type=equip) }
    bonus_id={ 6569 }, stats={ 100% Cor [25.0000] }, effects={ Lash of the Void (id=317290, index=2, type=equip) }
    bonus_id={ 6570 }, stats={ 100% Cor [20.0000] }, effects={ Flash of Insight (id=318299, index=2, type=equip) }
    bonus_id={ 6571 }, stats={ 100% Cor [30.0000] }, effects={ Searing Flames (id=318293, index=2, type=equip) }
    bonus_id={ 6572 }, stats={ 100% Cor [50.0000] }, effects={ Obsidian Skin (id=316651, index=2, type=equip) }
    bonus_id={ 6573 }, stats={ 100% Cor [15.0000] }, effects={ Gushing Wound (id=318272, index=2, type=equip) } ]]

    local shadowlegendaries = {
        -- Mage/Arcane
        [6831] = { "expanded_potential", 1, 62 }, -- 327489
        [6832] = { "disciplinary_command", 1, 62 }, -- 327365
        [6834] = { "temporal_warp", 1, 62 }, -- 327351
        [6926] = { "arcane_infinity", 1, 62 }, -- 332769
        [6927] = { "arcane_bombardment", 1, 62 }, -- 332892
        [6928] = { "siphon_storm", 1, 62 }, -- 332928
        [6936] = { "triune_ward", 1, 62 }, -- 333373
        [6937] = { "grisly_icicle", 1, 62 }, -- 333393
        [7100] = { "echo_of_eonar", 1, 62 }, -- 338477
        [7101] = { "judgment_of_the_arbiter", 1, 62 }, -- 339344
        [7102] = { "norgannons_sagacity", 1, 62 }, -- 339340
        [7103] = { "sephuzs_proclamation", 1, 62 }, -- 339348
        [7104] = { "stable_phantasma_lure", 1, 62 }, -- 339351
        [7105] = { "third_eye_of_the_jailer", 1, 62 }, -- 339058
        [7106] = { "vitality_sacrifice", 1, 62 }, -- 338743
        [7159] = { "maw_rattle", 1, 62 }, -- 340197

        -- Mage/Fire
        [6931] = { "fevered_incantation", 1, 63 }, -- 333030
        [6932] = { "firestorm", 1, 63 }, -- 333097
        [6933] = { "molten_skyfall", 1, 63 }, -- 333167
        [6934] = { "sun_kings_blessing", 1, 63 }, -- 333313

        -- Mage/Frost
        [6823] = { "slick_ice", 1, 64 }, -- 327508
        [6828] = { "cold_front", 1, 64 }, -- 327284
        [6829] = { "freezing_winds", 1, 64 }, -- 327364
        [6830] = { "glacial_fragments", 1, 64 }, -- 327492

        -- Paladin/Holy
        [7053] = { "uthers_devotion", 1, 65 }, -- 337600
        [7054] = { "vanguards_momentum", 1, 65 }, -- 337638
        [7055] = { "from_dusk_till_dawn", 1, 65 }, -- 337746
        [7056] = { "the_magistrates_judgment", 1, 65 }, -- 337681
        [7057] = { "shadowbreaker_dawn_of_the_sun", 1, 65 }, -- 337812
        [7058] = { "inflorescence_of_the_sunwell", 1, 65 }, -- 337777
        [7059] = { "shock_barrier", 1, 65 }, -- 337825
        [7128] = { "maraads_dying_breath", 1, 65 }, -- 234848

        -- Paladin/Protection
        [7060] = { "holy_avengers_engraved_sigil", 1, 66 }, -- 337831
        [7061] = { "the_ardent_protectors_sanctum", 1, 66 }, -- 337838
        [7062] = { "bulwark_of_righteous_fury", 1, 66 }, -- 337847
        [7063] = { "reign_of_endless_kings", 1, 66 }, -- 337850

        -- Paladin/Retribution
        [7064] = { "final_verdict", 1, 70 }, -- 337247
        [7065] = { "the_mad_paragon", 1, 70 }, -- 337594
        [7066] = { "relentless_inquisitor", 1, 70 }, -- 337297
        [7067] = { "tempest_of_the_lightbringer", 1, 70 }, -- 337257

        -- Warrior/Arms
        [6960] = { "battlelord", 1, 71 }, -- 335274
        [6961] = { "exploiter", 1, 71 }, -- 335451
        [6962] = { "enduring_blow", 1, 71 }, -- 335458
        [6970] = { "unhinged", 1, 71 }, -- 335282

        -- Warrior/Fury
        [6955] = { "leaper", 1, 72 }, -- 335214
        [6958] = { "misshapen_mirror", 1, 72 }, -- 335253
        [6959] = { "signet_of_tormented_kings", 1, 72 }, -- 335266
        [6963] = { "cadence_of_fujieda", 1, 72 }, -- 335555
        [6964] = { "deathmaker", 1, 72 }, -- 335567
        [6965] = { "reckless_defense", 1, 72 }, -- 335582
        [6966] = { "will_of_the_berserker", 1, 72 }, -- 335594
        [6971] = { "seismic_reverberation", 1, 72 }, -- 335758

        -- Warrior/Protection
        [6956] = { "thunderlord", 1, 73 }, -- 335229
        [6957] = { "the_wall", 1, 73 }, -- 335239
        [6967] = { "unbreakable_will", 1, 73 }, -- 335629
        [6969] = { "reprisal", 1, 73 }, -- 335718

        -- Druid/Balance
        [7084] = { "oath_of_the_elder_druid", 1, 102 }, -- 338608
        [7085] = { "circle_of_life_and_death", 1, 102 }, -- 338657
        [7086] = { "draught_of_deep_focus", 1, 102 }, -- 338658
        [7087] = { "oneths_clear_vision", 1, 102 }, -- 338661
        [7088] = { "primordial_arcanic_pulsar", 1, 102 }, -- 338668
        [7107] = { "balance_of_all_things", 1, 102 }, -- 339942
        [7108] = { "timeworn_dreambinder", 1, 102 }, -- 339949
        [7110] = { "lycaras_fleeting_glimpse", 1, 102 }, -- 340059

        -- Druid/Feral
        [7089] = { "cateye_curio", 1, 103 }, -- 339144
        [7090] = { "eye_of_fearful_symmetry", 1, 103 }, -- 339141
        [7091] = { "apex_predators_craving", 1, 103 }, -- 339139
        [7109] = { "frenzyband", 1, 103 }, -- 340053

        -- Druid/Guardian
        [7092] = { "luffainfused_embrace", 1, 104 }, -- 339060
        [7093] = { "the_natural_orders_will", 1, 104 }, -- 339063
        [7094] = { "ursocs_fury_remembered", 1, 104 }, -- 339056
        [7095] = { "legacy_of_the_sleeper", 1, 104 }, -- 339062

        -- Druid/Restoration
        [7096] = { "memory_of_the_mother_tree", 1, 105 }, -- 339064
        [7097] = { "the_dark_titans_lesson", 1, 105 }, -- 338831
        [7098] = { "verdant_infusion", 1, 105 }, -- 338829
        [7099] = { "vision_of_unending_growth", 1, 105 }, -- 338832

        -- Death Knight/Blood
        [6940] = { "bryndaors_might", 1, 250 }, -- 334501
        [6941] = { "crimson_rune_weapon", 1, 250 }, -- 334525
        [6942] = { "vampiric_aura", 1, 250 }, -- 334547
        [6943] = { "gorefiends_domination", 1, 250 }, -- 334580
        [6947] = { "deaths_embrace", 1, 250 }, -- 334728
        [6948] = { "grip_of_the_everlasting", 1, 250 }, -- 334724
        [6953] = { "superstrain", 1, 250 }, -- 334974
        [6954] = { "phearomones", 1, 250 }, -- 335177

        -- Death Knight/Frost
        [6944] = { "koltiras_favor", 1, 251 }, -- 334583
        [6945] = { "biting_cold", 1, 251 }, -- 334678
        [6946] = { "absolute_zero", 1, 251 }, -- 334692
        [7160] = { "rage_of_the_frozen_champion", 1, 251 }, -- 341724

        -- Death Knight/Unholy
        [6949] = { "reanimated_shambler", 1, 252 }, -- 334836
        [6950] = { "frenzied_monstrosity", 1, 252 }, -- 334888
        [6951] = { "deaths_certainty", 1, 252 }, -- 334898
        [6952] = { "deadliest_coil", 1, 252 }, -- 334949

        -- Hunter/Beast Mastery
        [7003] = { "call_of_the_wild", 1, 253 }, -- 336742
        [7004] = { "nessingwarys_trapping_apparatus", 1, 253 }, -- 336743
        [7005] = { "soulforge_embers", 1, 253 }, -- 336745
        [7006] = { "craven_strategem", 1, 253 }, -- 336747
        [7007] = { "dire_command", 1, 253 }, -- 336819
        [7008] = { "flamewakers_cobra_sting", 1, 253 }, -- 336822
        [7009] = { "qapla_eredun_war_order", 1, 253 }, -- 336830
        [7010] = { "rylakstalkers_piercing_fangs", 1, 253 }, -- 336844

        -- Hunter/Marksmanship
        [7011] = { "eagletalons_true_focus", 1, 254 }, -- 336849
        [7012] = { "surging_shots", 1, 254 }, -- 336867
        [7013] = { "serpentstalkers_trickery", 1, 254 }, -- 336870
        [7014] = { "secrets_of_the_unblinking_vigil", 1, 254 }, -- 336878

        -- Hunter/Survival
        [7015] = { "wildfire_cluster", 1, 255 }, -- 336895
        [7016] = { "rylakstalkers_confounding_strikes", 1, 255 }, -- 336901
        [7017] = { "latent_poison_injectors", 1, 255 }, -- 336902
        [7018] = { "butchers_bone_fragments", 1, 255 }, -- 336907

        -- Priest/Discipline
        [6976] = { "the_penitent_one", 1, 256 }, -- 336011
        [6978] = { "crystalline_reflection", 1, 256 }, -- 336507
        [6979] = { "kiss_of_death", 1, 256 }, -- 336133
        [6980] = { "clarity_of_mind", 1, 256 }, -- 336067

        -- Priest/Holy
        [6973] = { "divine_image", 1, 257 }, -- 336400
        [6974] = { "flash_concentration", 1, 257 }, -- 336266
        [6977] = { "harmonious_apparatus", 1, 257 }, -- 336314
        [6984] = { "xanshi_return_of_archbishop_benedictus", 1, 257 }, -- 337477

        -- Priest/Shadow
        [6972] = { "vault_of_heavens", 1, 258 }, -- 336470
        [6975] = { "cauterizing_shadows", 1, 258 }, -- 336370
        [6981] = { "painbreaker_psalm", 1, 258 }, -- 336165
        [6982] = { "shadowflame_prism", 1, 258 }, -- 336143
        [6983] = { "eternal_call_to_the_void", 1, 258 }, -- 336214
        [7002] = { "twins_of_the_sun_priestess", 1, 258 }, -- 336897
        [7161] = { "measured_contemplation", 1, 258 }, -- 341804
        [7162] = { "talbadars_stratagem", 1, 258 }, -- 342415

        -- Rogue/Assassination
        [7111] = { "mark_of_the_master_assassin", 1, 259 }, -- 340076
        [7112] = { "tiny_toxic_blades", 1, 259 }, -- 340078
        [7113] = { "essence_of_bloodfang", 1, 259 }, -- 340079
        [7114] = { "invigorating_shadowdust", 1, 259 }, -- 340080
        [7115] = { "dashing_scoundrel", 1, 259 }, -- 340081
        [7116] = { "doomblade", 1, 259 }, -- 340082
        [7117] = { "zoldyck_insignia", 1, 259 }, -- 340083
        [7118] = { "dustwalkers_patch", 1, 259 }, -- 340084

        -- Rogue/Outlaw
        [7119] = { "greenskins_wickers", 1, 260 }, -- 340085
        [7120] = { "guile_charm", 1, 260 }, -- 340086
        [7121] = { "celerity", 1, 260 }, -- 340087
        [7122] = { "concealed_blunderbuss", 1, 260 }, -- 340088

        -- Rogue/Subtlety
        [7123] = { "finality", 1, 261 }, -- 340089
        [7124] = { "akaaris_soul_fragment", 1, 261 }, -- 340090
        [7125] = { "the_rotten", 1, 261 }, -- 340091
        [7126] = { "deathly_shadows", 1, 261 }, -- 340092

        -- Shaman/Elemental
        [6985] = { "ancestral_reminder", 1, 262 }, -- 336741
        [6986] = { "deeptremor_stone", 1, 262 }, -- 336739
        [6987] = { "deeply_rooted_elements", 1, 262 }, -- 336738
        [6988] = { "chains_of_devastation", 1, 262 }, -- 336735
        [6989] = { "skybreakers_fiery_demise", 1, 262 }, -- 336734
        [6990] = { "elemental_equilibrium", 1, 262 }, -- 336730
        [6991] = { "echoes_of_great_sundering", 1, 262 }, -- 336215
        [6992] = { "windspeakers_lava_resurgence", 1, 262 }, -- 336063

        -- Shaman/Enhancement
        [6993] = { "doom_winds", 1, 263 }, -- 335902
        [6994] = { "legacy_of_the_frost_witch", 1, 263 }, -- 335899
        [6995] = { "witch_doctors_wolf_bones", 1, 263 }, -- 335897
        [6996] = { "primal_lava_actuators", 1, 263 }, -- 335895

        -- Shaman/Restoration
        [6997] = { "jonats_natural_focus", 1, 264 }, -- 335893
        [6998] = { "spiritwalkers_tidal_totem", 1, 264 }, -- 335891
        [6999] = { "primal_tide_core", 1, 264 }, -- 335889
        [7000] = { "earthen_harmony", 1, 264 }, -- 335886

        -- Warlock/Affliction
        [7025] = { "wilfreds_sigil_of_superior_summoning", 1, 265 }, -- 337020
        [7026] = { "claw_of_endereth", 1, 265 }, -- 337038
        [7027] = { "relic_of_demonic_synergy", 1, 265 }, -- 337057
        [7028] = { "pillars_of_the_dark_portal", 1, 265 }, -- 337065
        [7029] = { "perpetual_agony_of_azjaqir", 1, 265 }, -- 337106
        [7030] = { "sacrolashs_dark_strike", 1, 265 }, -- 337111
        [7031] = { "malefic_wrath", 1, 265 }, -- 337122
        [7032] = { "wrath_of_consumption", 1, 265 }, -- 337128

        -- Warlock/Demonology
        [7033] = { "implosive_potential", 1, 266 }, -- 337135
        [7034] = { "grim_inquisitors_dread_calling", 1, 266 }, -- 337141
        [7035] = { "forces_of_the_horned_nightmare", 1, 266 }, -- 337146
        [7036] = { "balespiders_burning_core", 1, 266 }, -- 337159

        -- Warlock/Destruction
        [7037] = { "odr_shawl_of_the_ymirjar", 1, 267 }, -- 337163
        [7038] = { "cinders_of_the_azjaqir", 1, 267 }, -- 337166
        [7039] = { "madness_of_the_azjaqir", 1, 267 }, -- 337169
        [7040] = { "embers_of_the_diabolic_raiment", 1, 267 }, -- 337272

        -- Monk/Brewmaster
        [7076] = { "charred_passions", 1, 268 }, -- 338138
        [7077] = { "stormstouts_last_keg", 1, 268 }, -- 337288
        [7078] = { "celestial_infusion", 1, 268 }, -- 337290
        [7079] = { "shaohaos_might", 1, 268 }, -- 337570
        [7080] = { "swiftsure_wraps", 1, 268 }, -- 337294
        [7081] = { "fatal_touch", 1, 268 }, -- 337296
        [7082] = { "invokers_delight", 1, 268 }, -- 337298
        [7184] = { "escape_from_reality", 1, 268 }, -- 343250

        -- Monk/Windwalker
        [7068] = { "keefers_skyreach", 1, 269 }, -- 337334
        [7069] = { "last_emperors_capacitor", 1, 269 }, -- 337292
        [7070] = { "xuens_treasure", 1, 269 }, -- 337481
        [7071] = { "jade_ignition", 1, 269 }, -- 337483

        -- Monk/Mistweaver
        [7072] = { "tear_of_morning", 1, 270 }, -- 337473
        [7073] = { "yulons_whisper", 1, 270 }, -- 337225
        [7074] = { "clouded_focus", 1, 270 }, -- 337343
        [7075] = { "ancient_teachings_of_the_monastery", 1, 270 }, -- 337172

        -- Demon Hunter/Havoc
        [7041] = { "collective_anguish", 1, 577 }, -- 337504
        -- [7042] = { "halfgiant_empowerment", 1, 577 }, -- 337532
        [7043] = { "darkglare_medallion", 1, 577 }, -- 337534
        [7044] = { "darkest_hour", 1, 577 }, -- 337539
        -- [7049] = { "inner_demons", 1, 577 }, -- 337548
        [7050] = { "chaos_theory", 1, 577 }, -- 337551
        [7051] = { "erratic_fel_core", 1, 577 }, -- 337685
        [7052] = { "fel_bombardment", 1, 577 }, -- 337775
        [7218] = { "darker_nature", 1, 577 }, -- 346264
        [7219] = { "burning_wound", 1, 577 }, -- 346279

        -- Demon Hunter/Vengeance
        [7045] = { "spirit_of_the_darkness_flame", 1, 581 }, -- 337541
        [7046] = { "razelikhs_defilement", 1, 581 }, -- 337544
        [7047] = { "cloak_of_fel_flames", 1, 581 }, -- 337545
        [7048] = { "fiery_soul", 1, 581 }, -- 337547
    }

    local dk_runeforges = {
        [6243] = "hysteria",
        [3370] = "razorice",
        [6241] = "sanguination",
        [6242] = "spellwarding",
        [6245] = "apocalypse",
        [3368] = "fallen_crusader",
        [3847] = "stoneskin_gargoyle",
        [6244] = "unending_thirst"
    }

    local wasWearing = {}

    function ns.updateGear()
        if not Hekili.PLAYER_ENTERING_WORLD then return end

        for thing in pairs( state.set_bonus ) do
            state.set_bonus[ thing ] = 0
        end

        for thing in pairs( state.legendary ) do
            state.legendary[ thing ].rank = 0
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


        local dk_forge = class.file == "DEATHKNIGHT" and state.death_knight and state.death_knight.runeforge

        if dk_forge then
            wipe( dk_forge )
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

                local link = GetInventoryItemLink( "player", i )
                local numBonuses = select( 14, string.split( ":", link ) )

                numBonuses = tonumber( numBonuses )
                if numBonuses and numBonuses > 0 then
                    for i = 15, 14 + numBonuses do
                        local bonusID = select( i, string.split( ":", link ) )
                        bonusID = tonumber( bonusID )

                        if shadowlegendaries[ bonusID ] then
                            local name, rank = shadowlegendaries[ bonusID ][ 1 ], shadowlegendaries[ bonusID ][ 2 ]

                            state.legendary[ name ] = rawget( state.legendary, name ) or { rank = 0 }
                            state.legendary[ name ].rank = state.legendary[ name ].rank + rank
                        end
                    end
                end

                if ( i == 16 or i == 17 ) and dk_forge then
                    local enchant = link:match( "item:%d+:(%d+)" )                    

                    if enchant then
                        enchant = tonumber( enchant )
                        local name = dk_runeforges[ enchant ]

                        if name then
                            dk_forge[ name ] = true

                            if name == "razorice" and i == 16 then
                                dk_forge.razorice_mh = true
                            elseif name == "razorice" and i == 17 then
                                dk_forge.razorice_oh = true
                            end
                        end
                    end
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
                    insert( state.items, action )
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

        state.swings.mh_speed, state.swings.oh_speed = UnitAttackSpeed( "player" )

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

RegisterUnitEvent( "UNIT_INVENTORY_CHANGED", "player", nil, function()
    ns.updateGear()
end )

RegisterEvent( "PLAYER_TALENT_UPDATE", function()
    ns.updateTalents()
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

    local function UpdateEssences()
        local lastEssence = class.active_essence
        ns.updateEssences()

        if class.active_essence ~= lastEssence then
            Hekili:UpdateUseItems()
        end
    end

    for i, event in pairs( azeriteEvents ) do
        RegisterEvent( event, UpdateEssences )
    end
end


-- Update Conduit Data.
do
    local conduits = {
        [58081]  = { "kilroggs_cunning", { 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120 }, },
        [334993] = { "stalwart_guardian", { -20000, -22000, -24000, -26000, -28000, -30000, -32000, -35000, -37000, -39000, -41000, -43000, -45000, -47000, -50000 }, },
        [335010] = { "brutal_vitality", { 6, 6.4, 6.9, 7.3, 7.7, 8.1, 8.6, 9, 9.4, 9.9, 10.3, 10.7, 11.1, 11.6, 12 }, },
        [335034] = { "inspiring_presence", { 20, 22, 24, 26, 29, 31, 33, 35, 37, 39, 41, 44, 46, 48, 50 }, },
        [335196] = { "safeguard", { -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24 }, },
        [335225] = { "iron_maiden", { 40, 44, 49, 53, 57, 61, 66, 70, 74, 79, 83, 87, 91, 96, 100 }, },
        [335232] = { "ashen_juggernaut", { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [335242] = { "crash_the_ramparts", { 60, 66, 73, 79, 86, 92, 99, 105, 111, 118, 124, 131, 137, 144, 150 }, },
        [335250] = { "cacophonous_roar", { 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220 }, },
        [335260] = { "merciless_bonegrinder", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [336191] = { "indelible_victory", { 400, 430, 460, 490, 515, 540, 570, 600, 630, 660, 685, 715, 740, 770, 800 }, },
        [336379] = { "harm_denial", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [336452] = { "inner_fury", { 4, 4.4, 4.8, 5.2, 5.6, 6, 6.4, 6.8, 7.2, 7.6, 8, 8.4, 8.8, 9.2, 9.6 }, },
        [336460] = { "unrelenting_cold", { 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 40 }, },
        [336472] = { "shivering_core", { 5, 6.25, 7.5, 8.75, 10, 11.25, 12.5, 13.75, 15, 16.25, 17.5, 18.75, 20, 21.25, 25 }, },
        [336522] = { "icy_propulsion", { 2.5, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }, },
        [336526] = { "calculated_strikes", { 8, 8.8, 9.6, 10.4, 11.2, 12, 12.8, 13.6, 14.4, 15.2, 16, 16.8, 17.6, 18.4, 19.2 }, },
        [336569] = { "ice_bite", { 10, 12, 15, 18, 21, 24, 27, 30, 32, 35, 38, 41, 44, 47, 50 }, },
        [336598] = { "coordinated_offensive", { 7, 7.7, 8.4, 9.1, 9.8, 10.5, 11.2, 11.9, 12.6, 13.3, 14, 14.7, 15.4, 16.1, 16.8 }, },
        [336613] = { "winters_protection", { -30000, -34000, -38000, -43000, -47000, -51000, -55000, -60000, -64000, -68000, -72000, -77000, -81000, -85000, -90000 }, },
        [336616] = { "xuens_bond", { 8, 8.8, 9.6, 10.4, 11.2, 12, 12.8, 13.6, 14.4, 15.2, 16, 16.8, 17.6, 18.4, 19.2 }, },
        [336632] = { "grounding_breath", { 12, 13.2, 14.4, 15.6, 16.8, 18, 19.2, 20.4, 21.6, 22.8, 24, 25.2, 26.4, 27.6, 28.8 }, },
        [336636] = { "flow_of_time", { -1000, -1250, -1500, -1750, -2000, -2250, -2500, -2750, -3000, -3250, -3500, -3750, -4000, -4250, -5000 }, },
        [336773] = { "jade_bond", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [336777] = { "grounding_surge", { 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80 }, },
        [336812] = { "resplendent_mist", { 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96 }, },
        [336821] = { "infernal_cascade", { 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10 }, },
        [336852] = { "master_flame", { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [336853] = { "fortifying_ingredients", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [336873] = { "arcane_prodigy", { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, },
        [336884] = { "lingering_numbness", { 380, 418, 456, 494, 532, 570, 608, 646, 684, 722, 760, 798, 836, 874, 912 }, },
        [336886] = { "nether_precision", { 10, 11, 12, 13, 14.5, 15.5, 16.5, 17.5, 19, 20, 21, 22, 23, 24, 25 }, },
        [336890] = { "dizzying_tumble", { -50, -55, -60, -65, -70, -75, -80, -85, -90, -95, -100, -105, -110, -115, -120 }, },
        [336992] = { "discipline_of_the_grove", { -5, -8, -11, -15, -18, -21, -24, -28, -31, -34, -37, -41, -44, -47, -50 }, },
        [336999] = { "gift_of_the_lich", { 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 }, },
        [337058] = { "ire_of_the_ascended", { 2, 2.4, 2.8, 3.2, 3.6, 4, 4.4, 4.8, 5.2, 5.6, 6, 6.4, 6.8, 7.2, 8 }, },
        [337078] = { "swift_transference", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [337084] = { "tumbling_technique", { 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120 }, },
        [337087] = { "siphoned_malice", { 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4 }, },
        [337099] = { "rising_sun_revival", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [337119] = { "scalding_brew", { 6, 6.6, 7.2, 7.8, 8.4, 9, 9.6, 10.2, 10.8, 11.4, 12, 12.6, 13.2, 13.8, 14.4 }, },
        [337123] = { "cryofreeze", { 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5 }, },
        [337134] = { "celestial_effervescence", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
        [337136] = { "diverted_energy", { 20, 22, 25, 28, 31, 34, 37, 40, 43, 46, 49, 52, 54, 57, 60 }, },
        [337154] = { "unnerving_focus", { 30, 33, 36, 40, 43, 46, 49, 53, 56, 59, 62, 65, 69, 72, 75 }, },
        [337162] = { "depths_of_insanity", { 20, 23, 26, 29, 31, 34, 37, 40, 43, 46, 49, 51, 54, 57, 60 }, },
        [337192] = { "magis_brand", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [337214] = { "hack_and_slash", { 100, 107, 114, 121, 129, 136, 143, 150, 157, 164, 171, 179, 186, 193, 200 }, },
        [337224] = { "flame_accretion", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [337240] = { "artifice_of_the_archmage", { 100, 110, 120, 130, 145, 155, 165, 175, 190, 200, 210, 220, 230, 240, 250 }, },
        [337241] = { "nourishing_chi", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
        [337250] = { "evasive_stride", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [337264] = { "walk_with_the_ox", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [337275] = { "incantation_of_swiftness", { 20, 21, 23, 25, 27, 28, 30, 32, 34, 36, 37, 39, 41, 43, 45 }, },
        [337286] = { "strike_with_clarity", { 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [337293] = { "tempest_barrier", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [337295] = { "bone_marrow_hops", { 32, 35.2, 38.4, 41.6, 44.8, 48, 51.2, 54.4, 57.6, 60.8, 64, 67.2, 70.4, 73.6, 76.8 }, },
        [337301] = { "imbued_reflections", { 29, 31.9, 34.8, 37.7, 40.6, 43.5, 46.4, 49.3, 52.2, 55.1, 58, 60.9, 63.8, 66.7, 69.6 }, },
        [337302] = { "vicious_contempt", { 40, 43, 46, 49, 51, 54, 57, 60, 63, 66, 69, 71, 74, 77, 80 }, },
        [337303] = { "way_of_the_fae", { 4.4, 4.8, 5.3, 5.7, 6.2, 6.6, 7, 7.5, 7.9, 8.4, 8.8, 9.2, 9.7, 10.1, 10.6 }, },
        [337381] = { "eternal_hunger", { 5000, 5500, 6000, 6750, 7500, 8250, 9000, 9750, 10500, 11250, 12000, 12750, 13500, 14250, 15000 }, },
        [337662] = { "translucent_image", { -5, -5.5, -6, 6.5, -7, -7.5, -8, -8.5, -9, -9.5, -10, -10.5, -11, -11.5, -12 }, },
        [337678] = { "move_with_grace", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337704] = { "chilled_resilience", { -15000, -18000, -21000, -25000, -28000, -31000, -34000, -38000, -41000, -44000, -47000, -51000, -54000, -57000, -60000 }, },
        [337705] = { "spirit_drain", { 50, 60, 70, 80, 90, 100, 110, 120, 140, 150, 160, 170, 180, 190, 200 }, },
        [337707] = { "clear_mind", { -20, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35 }, },
        [337715] = { "charitable_soul", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [337748] = { "lights_inspiration", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [337762] = { "power_unto_others", { 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [337764] = { "reinforced_shell", { 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000 }, },
        [337778] = { "shining_radiance", { 33, 36.9, 39.6, 42.9, 46.2, 49.5, 52.8, 56.1, 59.4, 62.7, 66, 69.3, 72.6, 75.9, 79.2 }, },
        [337786] = { "pain_transformation", { 12, 13.2, 14.4, 15.6, 16.8, 18, 19.2, 20.4, 21.6, 22.8, 24, 25.2, 26.4, 27.6, 28.8 }, },
        [337790] = { "exaltation", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337811] = { "lasting_spirit", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337822] = { "accelerated_cold", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [337884] = { "withering_plague", { 10, 11.75, 13.5, 15.25, 17, 18.75, 20.5, 22.25, 24, 25.75, 27.5, 29.25, 31, 32.75, 35 }, },
        [337891] = { "swift_penitence", { 25, 27.5, 30, 32.5, 35, 37.5, 40, 42.5, 45, 47.5, 50, 52.5, 55, 57.5, 60 }, },
        [337914] = { "focused_mending", { 20, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50 }, },
        [337934] = { "eradicating_blow", { 10, 11, 12, 13.5, 14.5, 15.5, 16.5, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337947] = { "resonant_words", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337954] = { "mental_recovery", { 40, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70 }, },
        [337957] = { "blood_bond", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [337964] = { "astral_protection", { -3, -3.5, -4, -4.5, -5, -5.5, -6, -6.5, -7, -7.5, -8, -8.5, -9, -9.5, -10 }, },
        [337966] = { "courageous_ascension", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337972] = { "hardened_bones", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [337974] = { "refreshing_waters", { 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 }, },
        [337979] = { "festering_transfusion", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [337980] = { "embrace_death", { 40, 44, 48, 53, 57, 61, 65, 70, 74, 78, 82, 87, 91, 95, 100 }, },
        [337981] = { "vital_accretion", { 20, 21, 23, 24, 26, 27, 29, 30, 31, 33, 34, 36, 38, 39, 40 }, },
        [337988] = { "biting_cold", { 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9 }, },
        [338033] = { "thunderous_paws", { 10, 12, 14, 16, 19, 21, 23, 25, 27, 29, 31, 34, 36, 38, 40 }, },
        [338042] = { "totemic_surge", { -1000, -2000, -3000, -4000, -5000, -6000, -7000, -8000, -9000, -10000, -11000, -12000, -13000, -14000, -15000 }, },
        [338048] = { "spiritual_resonance", { 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000 }, },
        [338054] = { "crippling_hex", { -8, -8.5, -9, -9.5, -10, -10.5, -11, -11.5, -12, -12.5, -13, -13.5, -14, -14.5, -15 }, },
        [338093] = { "fleeting_wind", { 10, 11, 12, 13.5, 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30 }, },
        [338131] = { "high_voltage", { 30, 32, 34, 36, 39, 41, 43, 45, 47, 49, 51, 54, 56, 58, 60 }, },
        [338252] = { "shake_the_foundations", { 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30 }, },
        [338303] = { "call_of_flame", { 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30 }, },
        [338305] = { "fae_fermata", { 3000, 3300, 3600, 3900, 4200, 4500, 4800, 5100, 5400, 5700, 6000, 6300, 6600, 6900, 7200 }, },
        [338311] = { "unending_grip", { -25, -28, -31, -34, -36, -38, -40, -43, -45, -47, -49, -52, -54, -56, -60 }, },
        [338315] = { "shattered_perceptions", { 20, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35 }, },
        [338318] = { "unruly_winds", { 40, 43, 46, 49, 51, 54, 57, 60, 63, 66, 69, 71, 74, 77, 80 }, },
        [338319] = { "haunting_apparitions", { 25, 27.5, 30, 32.5, 35, 37.5, 40, 42.5, 45, 47.5, 50, 52.5, 55, 57.5, 60 }, },
        [338322] = { "focused_lightning", { 4, 4.4, 4.9, 5.3, 5.7, 6.1, 6.6, 7, 7.4, 7.9, 8.3, 8.7, 9.1, 9.6, 10 }, },
        [338325] = { "chilled_to_the_core", { 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35 }, },
        [338329] = { "embrace_of_earth", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [338330] = { "insatiable_appetite", { 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8 }, },
        [338331] = { "magma_fist", { 25, 27, 29, 30, 32, 34, 36, 38, 39, 41, 43, 45, 47, 49, 50 }, },
        [338332] = { "mind_devourer", { 7, 7.7, 8.4, 9.1, 9.8, 10.5, 11.2, 11.9, 12.6, 13.3, 14, 14.7, 15.4, 16.1, 16.8 }, },
        [338338] = { "rabid_shadows", { 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [338339] = { "swirling_currents", { 20, 21, 23, 24, 26, 28, 29, 30, 31, 33, 34, 36, 37, 39, 40 }, },
        [338342] = { "dissonant_echoes", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
        [338343] = { "heavy_rainfall", { 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300 }, },
        [338345] = { "holy_oration", { 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [338346] = { "natures_reach", { 40, 43, 46, 49, 51, 54, 57, 60, 63, 66, 69, 71, 74, 77, 80 }, },
        [338435] = { "meat_shield", { 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8 }, },
        [338492] = { "unleashed_frenzy", { 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5 }, },
        [338516] = { "debilitating_malady", { 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.75, 5.5, 6.25, 7, 7.75, 8.5, 9.25, 10 }, },
        [338553] = { "convocation_of_the_dead", { 5, 7, 9, 11, 13, 15, 17, 20, 22, 24, 26, 29, 31, 33, 35 }, },
        [338566] = { "lingering_plague", { 250, 500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3250, 3500, 3750 }, },
        [338628] = { "impenetrable_gloom", { 5, 6.75, 8.5, 10.25, 12, 13.75, 15.5, 17.25, 19, 20.75, 22.5, 24.25, 26, 27.5, 30 }, },
        [338651] = { "brutal_grasp", { 50, 55, 61, 66, 71, 77, 82, 87, 93, 98, 103, 109, 114, 119, 125 }, },
        [338664] = { "proliferation", { 2, 2.5, 3, 3.75, 4.25, 4.75, 5.25, 6, 6.5, 7, 7.5, 8.25, 8.75, 9.25, 10 }, },
        [338671] = { "fel_defender", { -5000, -6000, -7000, -8000, -9000, -10000, -11000, -12000, -13000, -14000, -15000, -16000, -17000, -18000, -20000 }, },
        [338741] = { "divine_call", { 30, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15 }, },
        [338787] = { "shielding_words", { 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 }, },
        [338793] = { "shattered_restoration", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25 }, },
        [338799] = { "felfire_haste", { 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20 }, },
        [338835] = { "ravenous_consumption", { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30 }, },
        [339018] = { "enfeebled_mark", { 5, 5.5, 6, 6.75, 7.5, 8.25, 9, 9.75, 10.5, 11.25, 12, 12.75, 13.5, 14.25, 15 }, },
        [339048] = { "demonic_parole", { 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000, 20000 }, },
        [339059] = { "empowered_release", { 5, 6, 7, 8.5, 9.5, 10.5, 11.5, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [339109] = { "spirit_attunement", { 10, 11, 12, 13.5, 14.5, 15.5, 16.5, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [339114] = { "golden_path", { 200, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400, 420, 440, 460, 480 }, },
        [339124] = { "pure_concentration", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [339129] = { "necrotic_barrage", { 15, 16, 17, 18, 19, 20 }, },
        [339130] = { "fel_celerity", { -51000, -54000, -57000, -60000, -63000, -66000, -69000, -72000, -75000, -78000, -81000, -84000, -87000, -90000 }, },
        [339149] = { "lost_in_darkness", { 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 }, },
        [339151] = { "relentless_onslaught", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 10, 11, 12, 13, 14, 15 }, },
        [339182] = { "elysian_dirge", { 100, 107, 114, 121, 129, 136, 143, 150, 157, 164, 171, 179, 186, 193, 200 }, },
        [339183] = { "essential_extraction", { 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30 }, },
        [339185] = { "lavish_harvest", { 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5, 16, 16.5, 17 }, },
        [339186] = { "tumbling_waves", { 200, 210, 230, 240, 260, 270, 290, 300, 310, 330, 340, 360, 370, 390, 400 }, },
        [339228] = { "dancing_with_fate", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 10, 11, 12, 13, 14, 15 }, },
        [339230] = { "serrated_glaive", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25 }, },
        [339231] = { "growing_inferno", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25 }, },
        [339259] = { "piercing_verdict", { 20, 21, 23, 24, 26, 27, 29, 30, 31, 33, 34, 36, 37, 39, 40 }, },
        [339264] = { "markmans_advantage", { -3.5, -4, -4.5, -5, -5.5, -6, -6.5, -7, -7.5, -8, -8.5, -9, -9.5, -10 }, },
        [339265] = { "veterans_repute", { 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 }, },
        [339268] = { "lights_barding", { 50, 55, 60, 64, 67, 70, 74, 77, 80, 84, 87, 90, 94, 97, 100 }, },
        [339272] = { "resolute_barrier", { 0, -1000, -2000, -3000, -4000, -5000, -6000, -7000, -8000, -9000, -10000, -11000, -12000, -13000, -14000 }, },
        [339282] = { "accrued_vitality", { 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100 }, },
        [339292] = { "wrench_evil", { -50, -55, -60, -64, -67, -70, -74, -77, -80, -84, -87, -90, -94, -97, -100 }, },
        [339316] = { "echoing_blessings", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [339370] = { "harrowing_punishment", { 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15 }, },
        [339371] = { "expurgation", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
        [339374] = { "truths_wake", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
        [339377] = { "harmony_of_the_tortollan", { -11500, -13000, -14500, -16000, -17500, -19000, -20500, -23000, -24500, -26000, -27500, -29000, -30500, -32000 }, },
        [339379] = { "shade_of_terror", { 100, 105, 110, 115, 120, 125, 130, 135, 140, 145, 150, 155, 160, 165, 170 }, },
        [339386] = { "mortal_combo", { 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 }, },
        [339399] = { "rejuvenating_wind", { 10, 11, 12, 13.5, 14.5, 16, 17.5, 19, 20.5, 22, 23.5, 25, 26.5, 28, 30 }, },
        [339411] = { "demonic_momentum", { 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58 }, },
        [339423] = { "soul_furnace", { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30 }, },
        [339455] = { "corrupting_leer", { 3, 3.2, 3.4, 3.6, 3.8, 4, 4.2, 4.4, 4.6, 4.8, 5, 5.2, 5.4, 5.6, 5.8 }, },
        [339459] = { "resilience_of_the_hunter", { -3, -3.5, -4, -4.5, -5, -5.5, -6, -6.5, -7, -7.5, -8, -8.5, -9, -9.5, -10 }, },
        [339481] = { "rolling_agony", { 4000, 4300, 4600, 4900, 5200, 5500, 5800, 6200, 6500, 6800, 7100, 7400, 7700, 8000, 8300 }, },
        [339495] = { "reversal_of_fortune", { 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, },
        [339500] = { "focused_malignancy", { 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53 }, },
        [339518] = { "virtuous_command", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [339531] = { "templars_vindication", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [339558] = { "cheetahs_vigor", { -15000, -17000, -19000, -21000, -24000, -26000, -28000, -31000, -33000, -35000, -37000, -39000, -41000, -43000, -45000 }, },
        [339570] = { "enkindled_spirit", { 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96 }, },
        [339576] = { "cold_embrace", { 75 }, },
        [339578] = { "borne_of_blood", { 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 }, },
        [339587] = { "demon_muzzle", { 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20 }, },
        [339644] = { "roaring_fire", { 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 45 }, },
        [339651] = { "tactical_retreat", { -20, -22, -24, -27, -29, -31, -33, -36, -38, -40, -42, -44, -46, -48, -50 }, },
        [339656] = { "carnivorous_stalkers", { 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15 }, },
        [339704] = { "ferocious_appetite", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [339712] = { "resplendent_light", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [339750] = { "one_with_the_beast", { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, },
        [339766] = { "tyrants_soul", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [339818] = { "show_of_force", { 20, 21, 23, 24, 26, 27, 29, 30, 31, 33, 34, 36, 37, 39, 40 }, },
        [339845] = { "fel_commando", { 10, 10.75, 11.5, 12.25, 13, 13.75, 14.5, 15.25, 16, 16.75, 17.5, 18.25, 19, 19.75, 20.5 }, },
        [339890] = { "duplicitous_havoc", { 10, 10.75, 11.5, 12.25, 13, 13.75, 14.5, 15.25, 16, 16.75, 17.5, 18.25, 19, 19.75, 20.5 }, },
        [339892] = { "ashen_remains", { 5, 5.33, 5.66, 6, 6.33, 6.66, 7, 7.33, 7.66, 8, 8.33, 8.66, 9, 9.33, 9.66 }, },
        [339895] = { "repeat_decree", { -55, -54, -53, -52, -51, -50, -49, -48, -47, -46, -45, -44, -43, -42, -40 }, },
        [339896] = { "combusting_engine", { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 }, },
        [339920] = { "sharpshooters_focus", { 20, 22, 24, 27, 29, 31, 33, 36, 38, 40, 42, 44, 46, 48, 50 }, },
        [339924] = { "brutal_projectiles", { 1, 1.25, 1.5, 2, 2.25, 2.5, 2.75, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5 }, },
        [339939] = { "destructive_reverberations", { -16000, -17000, -18000, -19000, -20000, -21000, -22000, -23000, -24000, -25000, -26000, -27000, -28000, -29000, -30000 }, },
        [339948] = { "disturb_the_peace", { -5000, -6000, -7000, -8000, -8500, -9000, -10000, -10500, -11000, -12000, -12500, -13000, -13500, -14000, -15000 }, },
        [339973] = { "deadly_chain", { 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 22, 23, 24, 25 }, },
        [339984] = { "focused_light", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [339987] = { "untempered_dedication", { 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 5 }, },
        [340006] = { "vengeful_shock", { 15, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45 }, },
        [340012] = { "punish_the_guilty", { 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120 }, },
        [340023] = { "resolute_defender", { 25, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 25 }, },
        [340028] = { "increased_scrutiny", { -1000, -2000, -3000, -4000, -5000, -6000, -7000, -8000, -9000, -10000, -11000, -12000, -13000, -14000, -15000 }, },
        [340030] = { "royal_decree", { -15000, -17000, -18000, -19000, -20000, -21000, -22000, -23000, -24000, -25000, -26000, -27000, -28000, -29000, -30000 }, },
        [340033] = { "powerful_precision", { 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [340041] = { "infernal_brand", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [340063] = { "brooding_pool", { 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000, 20000 }, },
        [340185] = { "the_long_summer", { 30, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60 }, },
        [340192] = { "righteous_might", { 100, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250 }, },
        [340212] = { "hallowed_discernment", { 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96 }, },
        [340218] = { "ringing_clarity", { 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96 }, },
        [340229] = { "soul_tithe", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [340268] = { "prolonged_decimation", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [340316] = { "catastrophic_origin", { 50, 54, 58, 62, 66, 70, 74, 78, 34, 82, 86, 90, 94, 98, 102 }, },
        [340348] = { "soul_eater", { 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58 }, },
        [340529] = { "tough_as_bark", { -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24 }, },
        [340540] = { "ursine_vigor", { 12, 13.2, 14.4, 15.6, 16.8, 18, 19.2, 20.4, 21.6, 22.8, 24, 25.2, 26.4, 27.6, 28.8 }, },
        [340543] = { "innate_resolve", { 12, 13.2, 14.4, 15.6, 16.8, 18, 19.2, 20.4, 21.6, 22.8, 24, 25.2, 26.4, 27.6, 28.8 }, },
        [340545] = { "tireless_pursuit", { 3000, 3300, 3600, 3900, 4200, 4500, 4800, 5100, 5400, 5700, 6000, 6300, 6600, 6900, 7200 }, },
        [340549] = { "unstoppable_growth", { 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72 }, },
        [340550] = { "ready_for_anything", { -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24 }, },
        [340552] = { "unchecked_aggression", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [340553] = { "wellhoned_instincts", { 90, 81.818184, 75, 69.23077, 64.28571, 60, 56.25, 52.941177, 50, 47.36842, 45, 42.857143, 40.909092, 39.130436, 37.5 }, },
        [340562] = { "diabolic_bloodstone", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [340605] = { "layered_mane", { 8, 8.8, 9.6, 10.4, 11.2, 12, 12.8, 13.6, 14.4, 15.2, 16, 16.8, 17.6, 18.4, 19.2 }, },
        [340609] = { "savage_combatant", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [340616] = { "flash_of_clarity", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [340621] = { "floral_recycling", { 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72 }, },
        [340682] = { "taste_for_blood", { 3, 3.3, 3.6, 3.9, 4.2, 4.5, 4.8, 5.1, 5.4, 5.7, 6, 6.3, 6.6, 6.9, 7.2 }, },
        [340686] = { "incessant_hunter", { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [340694] = { "sudden_ambush", { 3, 3.3, 3.6, 3.9, 4.2, 4.5, 4.8, 5.1, 5.4, 5.7, 6, 6.3, 6.6, 6.9, 7.2 }, },
        [340705] = { "carnivorous_instinct", { 3, 3.3, 3.6, 3.9, 4.2, 4.5, 4.8, 5.1, 5.4, 5.7, 6, 6.3, 6.6, 6.9, 7.2 }, },
        [340706] = { "precise_alignment", { 4000, 4400, 4800, 5200, 5600, 6000, 6400, 6800, 7200, 7600, 8000, 8400, 8800, 9200, 9600 }, },
        [340708] = { "fury_of_the_skies", { 3, 3.3, 3.6, 3.9, 4.2, 4.5, 4.8, 5.1, 5.4, 5.7, 6, 6.3, 6.6, 6.9, 7.2 }, },
        [340719] = { "umbral_intensity", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [340720] = { "stellar_inspiration", { 8, 8.8, 9.6, 10.4, 11.2, 12, 12.8, 13.6, 14.4, 15.2, 16, 16.8, 17.6, 18.4, 19.2 }, },
        [340876] = { "echoing_call", { 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12 }, },
        [341222] = { "strength_of_the_pack", { 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10 }, },
        [341246] = { "stinging_strike", { 14, 15.5, 17, 18.5, 20, 21.5, 23, 24.5, 26, 27.5, 29, 30.5, 32, 33.5, 35 }, },
        [341264] = { "reverberation", { 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120 }, },
        [341272] = { "sudden_fractures", { 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10 }, },
        [341280] = { "born_anew", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [341309] = { "septic_shock", { 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190 }, },
        [341310] = { "slaughter_scars", { 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40 }, },
        [341311] = { "nimble_fingers", { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20 }, },
        [341312] = { "recuperator", { 1.15, 1.3, 1.45, 1.6, 1.75, 1.9, 2.05, 2.2, 2.35, 2.5, 2.65, 2.8, 2.9, 3 }, },
        [341325] = { "controlled_destruction", { 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20 }, },
        [341344] = { "withering_ground", { 15, 17.5, 20, 22.5, 25, 15, 30, 32.5, 35, 37.5, 40, 42.5, 45, 47.5, 50 }, },
        [341350] = { "deadly_tandem", { 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000 }, },
        [341378] = { "deep_allegiance", { -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24 }, },
        [341383] = { "endless_thirst", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [341399] = { "flame_infusion", { 10, 11, 12, 13, 14, 15, 16, 17.5, 18.5, 19.5, 20.5, 22, 23, 24, 25 }, },
        [341440] = { "bloodletting", { 10, 11, 12, 13, 14, 15, 16, 17.5, 18.5, 19.5, 20.5, 22, 23, 24, 25 }, },
        [341446] = { "conflux_of_elements", { 12, 13.2, 14.4, 15.6, 16.8, 18, 19.2, 20.4, 21.6, 22.8, 24, 25.2, 26.4, 27.6, 28.8 }, },
        [341447] = { "evolved_swarm", { 6, 6.6, 7.2, 7.8, 8.4, 9, 9.6, 10.2, 10.8, 11.4, 12, 12.6, 13.2, 13.8, 14.4 }, },
        [341450] = { "front_of_the_pack", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
        [341451] = { "born_of_the_wilds", { -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24 }, },
        [341529] = { "cloaked_in_shadows", { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [341531] = { "quick_decisions", { 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40 }, },
        [341532] = { "fade_to_nothing", { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25 }, },
        [341534] = { "rushed_setup", { -12.5, -15, -17.5, -20, -22.5, -25, -27.5, -30, -32.5, -35, -37.5, -40, -42.5, -45 }, },
        [341535] = { "prepared_for_all", { 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.4, 2.6, 2.8, 3, 3.2, 3.4, 3.6, 4 }, },
        [341536] = { "poisoned_katar", { 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36 }, },
        [341537] = { "wellplaced_steel", { 1.15, 1.3, 1.45, 1.6, 1.75, 1.9, 2.05, 2.2, 2.35, 2.5, 2.65, 2.8, 2.9, 3 }, },
        [341538] = { "maim_mangle", { 22.85, 25.7, 28.55, 31.4, 34.25, 37.1, 39.95, 42.8, 45.65, 48.5, 51.35, 54.2, 57.05, 60 }, },
        [341539] = { "lethal_poisons", { 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100 }, },
        [341540] = { "triple_threat", { 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 35 }, },
        [341542] = { "ambidexterity", { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }, },
        [341543] = { "sleight_of_hand", { 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21 }, },
        [341546] = { "count_the_odds", { 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21 }, },
        [341549] = { "deeper_daggers", { 38.5, 47, 55.5, 64, 72.5, 81, 89.5, 98, 106.5, 115, 123.5, 132, 140.5, 150 }, },
        [341556] = { "planned_execution", { 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34 }, },
        [341559] = { "stiletto_staccato", { 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.5 }, },
        [341567] = { "perforated_veins", { 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100 }, },
        [344358] = { "unnatural_malice", { 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48 }, },
        [345594] = { "pyroclastic_shock", { 15, 16.5, 18, 19.5, 21, 22.5, 24, 25.5, 27, 28.5, 30, 31.5, 33, 34.5, 36 }, },
    }

    local soulbinds = {
        [320658] = "stay_on_the_move",                   -- Niya
        [320659] = "niyas_tools_burrs",                  -- Niya
        [320660] = "niyas_tools_poison",                 -- Niya
        [320662] = "niyas_tools_herbs",                  -- Niya
        [320668] = "natures_splendor",                   -- Niya
        [320687] = "swift_patrol",                       -- Niya
        [322721] = "grove_invigoration",                 -- Niya
        [342270] = "run_without_tiring",                 -- Niya
        [319191] = "field_of_blossoms",                  -- Dreamweaver
        [319210] = "social_butterfly",                   -- Dreamweaver
        [319211] = "soothing_voice",                     -- Dreamweaver
        [319213] = "empowered_chrysalis",                -- Dreamweaver
        [319214] = "faerie_dust",                        -- Dreamweaver
        [319216] = "somnambulist",                       -- Dreamweaver
        [319217] = "podtender",                          -- Dreamweaver
        [319973] = "built_for_war",                      -- General Draven
        [319978] = "enduring_gloom",                     -- General Draven
        [319982] = "move_as_one",                        -- General Draven
        [332753] = "superior_tactics",                   -- General Draven
        [332754] = "hold_your_ground",                   -- General Draven
        [332755] = "unbreakable_body",                   -- General Draven
        [332756] = "expedition_leader",                  -- General Draven
        [340159] = "service_in_stone",                   -- General Draven
        [323074] = "volatile_solvent",                   -- Plague Deviser Marileth
        [323079] = "kevins_keyring",                     -- Plague Deviser Marileth
        [323081] = "plagueborn_cleansing_slime",         -- Plague Deviser Marileth
        [323089] = "travel_with_bloop",                  -- Plague Deviser Marileth
        [323090] = "plagueys_preemptive_strike",         -- Plague Deviser Marileth
        [323091] = "oozs_frictionless_coating",          -- Plague Deviser Marileth
        [323095] = "ultimate_form",                      -- Plague Deviser Marileth
        [323916] = "sulfuric_emission",                  -- Emeni
        [323918] = "gristled_toes",                      -- Emeni
        [323919] = "gnashing_chompers",                  -- Emeni
        [323921] = "emenis_magnificent_skin",            -- Emeni
        [324440] = "cartilaginous_legs",                 -- Emeni
        [324441] = "hearth_kidneystone",                 -- Emeni
        [341650] = "emenis_ambulatory_flesh",            -- Emeni
        [342156] = "lead_by_example",                    -- Emeni
        [325065] = "wild_hunts_charge",                  -- Korayn
        [325066] = "wild_hunt_tactics",                  -- Korayn
        [325067] = "horn_of_the_wild_hunt",              -- Korayn
        [325068] = "face_your_foes",                     -- Korayn
        [325069] = "first_strike",                       -- Korayn
        [325072] = "vorkai_sharpening_techniques",       -- Korayn
        [325073] = "get_in_formation",                   -- Korayn
        [325601] = "hold_the_line",                      -- Korayn
        [328257] = "let_go_of_the_past",                 -- Pelagos
        [328261] = "focusing_mantra",                    -- Pelagos
        [328263] = "cleansed_vestments",                 -- Pelagos
        [328265] = "bond_of_friendship",                 -- Pelagos
        [328266] = "combat_meditation",                  -- Pelagos
        [329777] = "phial_of_patience",                  -- Pelagos
        [329786] = "road_of_trials",                     -- Pelagos
        [331576] = "agent_of_chaos",                     -- Nadija the Mistblade
        [331577] = "fancy_footwork",                     -- Nadija the Mistblade
        [331579] = "friends_in_low_places",              -- Nadija the Mistblade
        [331580] = "exacting_preparation",               -- Nadija the Mistblade
        [331582] = "familiar_predicaments",              -- Nadija the Mistblade
        [331584] = "dauntless_duelist",                  -- Nadija the Mistblade
        [331586] = "thrill_seeker",                      -- Nadija the Mistblade
        [319983] = "wasteland_propriety",                -- Theotar the Mad Duke
        [336140] = "watch_the_shoes!",                   -- Theotar the Mad Duke
        [336147] = "leisurely_gait",                     -- Theotar the Mad Duke
        [336184] = "exquisite_ingredients",              -- Theotar the Mad Duke
        [336239] = "soothing_shade",                     -- Theotar the Mad Duke
        [336243] = "refined_palate",                     -- Theotar the Mad Duke
        [336245] = "token_of_appreciation",              -- Theotar the Mad Duke
        [336247] = "life_of_the_party",                  -- Theotar the Mad Duke
        [326504] = "serrated_spaulders",                 -- Bonesmith Heirmir
        [326507] = "resourceful_fleshcrafting",          -- Bonesmith Heirmir
        [326509] = "heirmirs_arsenal_ravenous_pendant",  -- Bonesmith Heirmir
        [326511] = "heirmirs_arsenal_gorestompers",      -- Bonesmith Heirmir
        [326512] = "runeforged_spurs",                   -- Bonesmith Heirmir
        [326513] = "bonesmiths_satchel",                 -- Bonesmith Heirmir
        [326514] = "forgeborne_reveries",                -- Bonesmith Heirmir
        [326572] = "heirmirs_arsenal_marrowed_gemstone", -- Bonesmith Heirmir
        [328258] = "ever_forward",                       -- Kleia
        [329776] = "ascendant_phial",                    -- Kleia
        [329778] = "pointed_courage",                    -- Kleia
        [329779] = "bearers_pursuit",                    -- Kleia
        [329781] = "resonant_accolades",                 -- Kleia
        [329784] = "cleansing_rites",                    -- Kleia
        [329791] = "valiant_strikes",                    -- Kleia
        [334066] = "mentorship",                         -- Kleia
        [331609] = "forgelite_filter",                   -- Forgelite Prime Mikanikos
        [331610] = "charged_additive",                   -- Forgelite Prime Mikanikos
        [331611] = "soulsteel_clamps",                   -- Forgelite Prime Mikanikos
        [331612] = "sparkling_driftglobe_core",          -- Forgelite Prime Mikanikos
        [331725] = "resilient_plumage",                  -- Forgelite Prime Mikanikos
        [331726] = "regenerating_materials",             -- Forgelite Prime Mikanikos
        [333935] = "hammer_of_genesis",                  -- Forgelite Prime Mikanikos
        [333950] = "brons_call_to_action",               -- Forgelite Prime Mikanikos
    }

    local soulbindEvents
    
    if PTR then 
        soulbindEvents = {
            "SOULBIND_ACTIVATED",
            "SOULBIND_CONDUIT_CHARGES_UPDATED",
            "SOULBIND_CONDUIT_INSTALLED",
            "SOULBIND_CONDUIT_UNINSTALLED",
            "SOULBIND_FORGE_INTERACTION_STARTED",
            "SOULBIND_FORGE_INTERACTION_ENDED",
            "SOULBIND_NODE_LEARNED",
            "SOULBIND_NODE_UNLEARNED",
            "SOULBIND_NODE_UPDATED",
            "SOULBIND_PATH_CHANGED",
            "SOULBIND_PENDING_CONDUIT_CHANGED",
            "PLAYER_ENTERING_WORLD"
        }
    else
        soulbindEvents = {}
    end

    local GetActiveSoulbindID, GetSoulbindData, GetConduitSpellID = C_Soulbinds.GetActiveSoulbindID, C_Soulbinds.GetSoulbindData, C_Soulbinds.GetConduitSpellID

    function ns.updateConduits()
        for k, v in pairs( state.conduit ) do
            v.rank = 0
            v.mod = 0
        end

        for k, v in pairs( state.soulbind ) do
            v.rank = 0
        end

        local found = false

        local soulbind = GetActiveSoulbindID()
        if not soulbind then return end

        local souldata = GetSoulbindData( soulbind )
        if not souldata then return end

        for i, node in ipairs( souldata.tree.nodes ) do
            if node.conduitID and node.conduitRank then
                if node.state == Enum.SoulbindNodeState.Selected and node.spellID > 0 then
                    local spellID = GetConduitSpellID( node.conduitID, node.conduitRank )

                    if conduits[ spellID ] then
                        found = true

                        local data = conduits[ spellID ]
                        local key = data[ 1 ]

                        local conduit = rawget( state.conduit, key ) or {
                            rank = 0,
                            mod = 0
                        }

                        conduit.rank = node.conduitRank
                        conduit.mod = data[ 2 ][ node.conduitRank ]

                        state.conduit[ key ] = conduit
                    
                    -- This is just soulbind data.
                    elseif soulbinds[ node.spellID ] then
                        local key = soulbinds[ node.spellID ]

                        local soulbind = rawget( state.soulbind, key ) or {}
                        soulbind.rank = 1

                        state.soulbind[ key ] = soulbind
                    end
                end
            end
        end

        return found
    end


    local tries = 30
    function ns.StartConduits()
        if not ns.updateConduits() then
            tries = tries - 1
            
            if tries > 0 then
                C_Timer.After( 1, ns.StartConduits )
            end

            return
        end

        tries = 0
    end

    ns.StartConduits()


    for i, event in pairs( soulbindEvents ) do
        RegisterEvent( event, ns.updateConduits )
    end
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

    Hekili.HasSnapped = false -- some would disagree.
    Hekili:ForceUpdate( event, true ) -- Force update on entering combat since OOC refresh can be very slow (0.5s).
end )


RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    last_combat = state.combat
    combat_ended = GetTime()

    state.combat = 0

    state.swings.mh_actual = 0
    state.swings.oh_actual = 0

    Hekili.HasSnapped = false -- allows the addon to autosnapshot again if preference is set.
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


local SpellQueueWindow = 0.4

local function UpdateSpellQueueWindow()
    SpellQueueWindow = ( tonumber( GetCVar( "SpellQueueWindow" ) ) or 400 ) / 1000
end

RegisterEvent( "CVAR_UPDATE", UpdateSpellQueueWindow )
RegisterEvent( "VARIABLES_LOADED", UpdateSpellQueueWindow )

C_Timer.After( 60, UpdateSpellQueueWindow )


do
    local macroInfo = {}

    RegisterEvent( "EXECUTE_CHAT_LINE", function( event, macroText )
        if macroText then
            local action, target = SecureCmdOptionParse( macroText )

            local ability = action and class.abilities[ action ]

            if ability and ability.key then
                local m = macroInfo[ ability.key ] or {}

                m.target = target and UnitGUID( target ) or UnitGUID( "target" )
                m.time   = GetTime()

                macroInfo[ ability.key ] = m
            end
        end
    end )

    local abs = math.abs

    function Hekili:GetMacroCastTarget( spell, castTime, source )
        local ability = class.abilities[ spell ]
        local buffer = 0.1 + SpellQueueWindow

        if ability and ability.key then
            local m = macroInfo[ ability.key ]

            if m and abs( castTime - m.time ) < buffer then
                return m.target -- This is a GUID.
            end
        end
    end
end


local lowLevelWarned = false

-- Need to make caching system.
RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", "player", nil, function( event, unit, _, spellID )
    if lowLevelWarned == false and UnitLevel( "player" ) < 50 then
        Hekili:Notify( "Hekili is designed for current content.\nUse below level 50 at your own risk.", 5 )
        lowLevelWarned = true
    end

    local ability = class.abilities[ spellID ]

    if ability and state.holds[ ability.key ] then
        Hekili:RemoveHold( ability.key, true )
    end
end )


RegisterUnitEvent( "UNIT_SPELLCAST_CHANNEL_START", "player", nil, function( event, unit, cast, spellID )
    local ability = class.abilities[ spellID ]
    
    if ability and state.holds[ ability.key ] then
        Hekili:RemoveHold( ability.key, true )
    end

    Hekili:ForceUpdate( event, true )
end )


RegisterUnitEvent( "UNIT_SPELLCAST_CHANNEL_STOP", "player", nil, function( event, unit, cast, spellID )
    local ability = class.abilities[ spellID ]
    
    if ability then
        if state.holds[ ability.key ] then
            Hekili:RemoveHold( ability.key, true )
        end

        state:RemoveSpellEvents( ability.key, true )
    end

    Hekili:ForceUpdate( event, true )
end )


RegisterUnitEvent( "UNIT_SPELLCAST_DELAYED", "player", nil, function( event, unit, _, spellID )
    local ability = class.abilities[ spellID ]
    
    if ability then
        local action = ability.key
        local _, _, _, start, finish = UnitCastingInfo( "player" )
        local target = select( 5, state:GetEventInfo( action, nil, nil, "CAST_FINISH", nil, true ) ) or Hekili:GetMacroCastTarget( action, start / 1000, "DELAYED" )

        state:RemoveSpellEvent( action, true, "CAST_FINISH" )
        state:RemoveSpellEvent( action, true, "PROJECTILE_IMPACT", true )

        if start and finish then
            state:QueueEvent( action, start / 1000, finish / 1000, "CAST_FINISH", target, true )

            if ability.isProjectile then
                local travel

                if ability.flightTime then
                    travel = ability.flightTime

                elseif target then
                    local unit = Hekili:GetUnitByGUID( target ) or Hekili:GetNameplateUnitForGUID( target ) or "target"

                    if unit then
                        local _, maxR = RC:GetRange( unit )
                        maxR = maxR or state.target.distance
                        travel = maxR / ability.velocity
                    end
                end

                if not travel then travel = state.target.distance / ability.velocity end

                state:QueueEvent( ability.key, finish / 1000, 0.05 + travel, "PROJECTILE_IMPACT", target, true )
            end
        end

        Hekili:ForceUpdate( event )
    end
end )


RegisterEvent( "UNIT_SPELLCAST_SENT", function ( self, unit, target_name, castID, spellID )
    if not UnitIsUnit( "player", unit ) then return end

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

RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, UNIT_POWER_FREQUENT )


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


-- TODO: Is this undermining throttling?
RegisterUnitEvent( "UNIT_AURA", "player", "target", function( event, unit )
    if UnitIsUnit( unit, "player" ) then
        Hekili.ScrapeUnitAuras( "player" )

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
    local spec = profile.specs[ state.spec.id ]

    countDamage = spec.damage or false
    countDots = spec.damageDots or false
    countPets = spec.damagePets or false
end


-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
local function CLEU_HANDLER( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

    if death_events[ subtype ] then
        if ns.isTarget( destGUID ) then
            ns.eliminateUnit( destGUID, true )
            Hekili:ForceUpdate( subtype )

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

    local amSource = ( sourceGUID == state.GUID )
    local amTarget = ( destGUID   == state.GUID )

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

    if dmg_events[ subtype ] and amTarget then
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

    if sourceGUID ~= state.GUID and not ( state.role.tank and destGUID == state.GUID ) and ( not minion or not countPets ) then
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
                    end

                    if ability.isProjectile then
                        local travel

                        if ability.flightTime then
                            travel = ability.flightTime
                        
                        elseif destGUID then
                            local unit = Hekili:GetUnitByGUID( destGUID ) or Hekili:GetNameplateUnitForGUID( destGUID ) or "target"

                            if unit then
                                local _, maxR = RC:GetRange( unit )
                                maxR = maxR or state.target.distance
                                travel = maxR / ability.velocity
                            end
                        end

                        if not travel then travel = state.target.distance / ability.velocity end

                        state:QueueEvent( ability.key, finish / 1000, travel, "PROJECTILE_IMPACT", destGUID, true )
                    end

                elseif subtype == "SPELL_CAST_FAILED" then
                    state:RemoveSpellEvent( ability.key, true, "CAST_FINISH" ) -- remove next cast finish.
                    state:RemoveSpellEvent( ability.key, true, "PROJECTILE_IMPACT", true ) -- remove last impact.

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
                                maxR = maxR or state.target.distance
                                travel = maxR / ability.velocity
                            end
                        end

                        if not travel then travel = state.target.distance / ability.velocity end

                        state:QueueEvent( ability.key, time, travel, "PROJECTILE_IMPACT", destGUID, true )
                    end

                    state:AddToHistory( ability.key, destGUID )

                elseif subtype == "SPELL_DAMAGE" then
                    -- Could be an impact.
                    local ability = class.abilities[ spellID ]
        
                    if ability then
                        if state:RemoveSpellEvent( ability.key, true, "PROJECTILE_IMPACT" ) then
                            Hekili:ForceUpdate( "PROJECTILE_IMPACT", true )
                        end
                    end
                
                end
            end

            local gcdStart = GetSpellCooldown( 61304 )
            if state.gcd.lastStart ~= gcdStart then
                state.gcd.lastStart = max( state.gcd.lastStart, gcdStart )
            end            

            Hekili:ForceUpdate( subtype, true )

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
    elseif amSource or ( countPets and minion ) or ( sourceGUID == destGUID and sourceGUID == UnitGUID( 'target' ) ) then

        if aura_events[ subtype ] then
            if subtype == "SPELL_CAST_SUCCESS" or state.GUID == destGUID then 
                state.player.updated = true
                if class.abilities[ spellID ] or class.auras[ spellID ] then
                    Hekili:ForceUpdate( subtype, true )
                end
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
                    if ( not minion or countPets ) and countDots then ns.updateTarget( destGUID, time, amSource ) end

                    if spellID == 48108 or spellID == 48107 then 
                        Hekili:ForceUpdate( "SPELL_AURA_SUPER", true )
                    end

                elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                    ns.trackDebuff( spellID, destGUID, time )
                    if countDots and ( not minion or countPets ) then
                        ns.updateTarget( destGUID, time, amSource )
                    end

                elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                    ns.trackDebuff( spellID, destGUID )

                end

            elseif amSource and aura.friendly then -- friendly effects
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

        if hostile and ( countDots and dmg_events[ subtype ] or direct_dmg_events[ subtype ] ) and not dmg_filtered[ spellID ] then
            -- Don't wipe overkill targets in rested areas (it is likely a dummy).
            -- Interrupt is actually overkill.
            if not IsResting( "player" ) and ( ( ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) and interrupt > 0 ) or ( subtype == "SWING_DAMAGE" and spellName > 0 ) ) and ns.isTarget( destGUID ) then
                ns.eliminateUnit( destGUID, true )
                Hekili:ForceUpdate( "SPELL_DAMAGE_OVERKILL" )
            elseif not ( subtype == "SPELL_MISSED" and amount == "IMMUNE" ) then
                ns.updateTarget( destGUID, time, amSource )
            end
        end
    end

    -- This is dumb.  Just let modules used the event handler.
    ns.callHook( "COMBAT_LOG_EVENT_UNFILTERED", event, nil, subtype, nil, sourceGUID, sourceName, nil, nil, destGUID, destName, destFlags, nil, spellID, spellName, nil, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

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

    local ability

    if aType == "spell" then
        ability = class.abilities[ id ] and class.abilities[ id ].key

    elseif aType == "macro" then
        local sID = GetMacroSpell( id ) or GetMacroItem( id )
        ability = sID and class.abilities[ sID ] and class.abilities[ sID ].key

    elseif aType == "item" then
        ability = GetItemInfo( id )
        ability = class.abilities[ ability ] and class.abilities[ ability ].key

        if not ability then
            if itemToAbility[ id ] then
                ability = itemToAbility[ id ]
            else
                for k, v in pairs( class.potions ) do
                    if v.item == id then
                        ability = "potion"
                        break
                    end
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

            if type( bind ) == 'table' then
                for _, b in ipairs( bind ) do
                    keys[ b ] = keys[ b ] or {
                        lower = {},
                        upper = {},
                        console = {}
                    }

                    keys[ b ].lower[ page ] = keys[ ability ].lower[ page ]
                    keys[ b ].upper[ page ] = keys[ ability ].upper[ page ]
                    keys[ b ].console[ page ] = keys[ ability ].console[ page ]
        
                    updatedKeys[ b ] = true
                end
            else
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

    -- Bartender4 support (Original from tanichan, rewritten for action bar paging by konstantinkoeppe).
    if _G["Bartender4"] then
        for actionBarNumber = 1, 10 do
            for keyNumber = 1, 12 do
                local actionBarButtonId = (actionBarNumber - 1) * 12 + keyNumber
                local bindingKeyName = "ACTIONBUTTON" .. keyNumber

                -- Action bar 1 and 7+ use bindings of action bar 1
                if actionBarNumber > 1 and actionBarNumber <= 6 then
                    bindingKeyName = "CLICK BT4Button" .. actionBarButtonId .. ":LeftButton"
                end

                StoreKeybindInfo( actionBarNumber, GetBindingKey( bindingKeyName ), GetActionInfo( actionBarButtonId ) )
            end
        end
    -- Use ElvUI's actionbars only if they are actually enabled.
    elseif _G["ElvUI"] and _G["ElvUI_Bar1Button1"] then
        for i = 1, 10 do
            for b = 1, 12 do
                local btn = _G["ElvUI_Bar" .. i .. "Button" .. b]

                local binding = btn.keyBoundTarget or ( " CLICK " .. btn:GetName() .. ":LeftButton" )

                if i > 6 then
                    -- Checking whether bar is active.
                    local bar = _G["ElvUI_Bar" .. i]

                    if not bar or not bar.db.enabled then
                        binding = "ACTIONBUTTON" .. b
                    end
                end

                local action, aType = btn._state_action, "spell"

                if action and type( action ) == "number" then
                    binding = GetBindingKey( binding )
                    action, aType = GetActionInfo( action )
                    StoreKeybindInfo( i, binding, action, aType )
                end
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
-- RegisterUnitEvent( "PLAYER_SPECIALIZATION_CHANGED", "player", nil, ReadKeybindings )
-- RegisterUnitEvent( "PLAYER_EQUIPMENT_CHANGED", "player", nil, ReadKeybindings )


if select( 2, UnitClass( "player" ) ) == "DRUID" then
    function Hekili:GetBindingForAction( key, display, i )
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

        local queued = ( i or 1 ) > 1 and display.keybindings.separateQueueStyle

        if display then
            caps = not ( queued and display.keybindings.queuedLowercase or display.keybindings.lowercase )
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
    function Hekili:GetBindingForAction( key, display, i )
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

        local queued = ( i or 1 ) > 1 and display.keybindings.separateQueueStyle

        local caps, console = true, false
        if display then
            caps = not ( queued and display.keybindings.queuedLowercase or display.keybindings.lowercase )
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
    function Hekili:GetBindingForAction( key, display, i )
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

        local queued = ( i or 1 ) > 1 and display.keybindings.separateQueueStyle

        local caps, console = true, false
        if display then
            caps = not ( queued and display.keybindings.queuedLowercase or display.keybindings.lowercase )
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
