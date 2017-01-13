-- Events.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state
local TTD = ns.TTD

-- local Artifact = ns.lib.LegionArtifacts
local AD = ns.lib.ArtifactData
local RC = ns.lib.RangeCheck

local formatKey = ns.formatKey
local getSpecializationInfo = ns.getSpecializationInfo
local getSpecializationKey = ns.getSpecializationKey

local match = string.match

-- Abandoning AceEvent in favor of darkend's solution from:
-- http://andydote.co.uk/2014/11/23/good-design-in-warcraft-addons.html
-- This should be a bit friendlier for our modules.


local events = CreateFrame( "Frame" )
local handlers = {}
local displayUpdates = {}

function ns.StartEventHandler()

    events:SetScript( "OnEvent", function( self, event, ... )
        local eventHandlers = handlers[ event ]

        if not eventHandlers then return end

        for i, handler in pairs( eventHandlers ) do
            handler( event, ... )
        end
    end )

    events:SetScript( "OnUpdate", function( self, elapsed )
        for i = 1, #Hekili.DB.profile.displays do
            if not displayUpdates[i] or ( GetTime() - displayUpdates[i] >= ( 1 / Hekili.DB.profile['Updates Per Second'] ) ) then
                Hekili:ProcessHooks( i )
            end
        end
        Hekili:UpdateDisplays()
    end )

end


function ns.StopEventHandler()

    events:SetScript( "OnEvent", nil )
    events:SetScript( "OnUpdate", nil )

end


ns.RegisterEvent = function( event, handler )

    handlers[ event ] = handlers[ event ] or {}
    table.insert( handlers[ event ], handler )

    events:RegisterEvent( event )

end
local RegisterEvent = ns.RegisterEvent


-- FIND A BETTER HOME
ns.cacheCriteria = function()

    for key, group in pairs( ns.visible ) do
        for key in pairs( group ) do
            group[ key ] = nil
        end
    end

    for i, display in ipairs( Hekili.DB.profile.displays ) do
        ns.visible.display[ i ] = display.Enabled and ( display.Specialization == 0 or display.Specialization == state.spec.id ) and ( display['Talent Group'] == 0 or display['Talent Group'] == GetActiveSpecGroup() )

        for j, hook in ipairs( display.Queues ) do
            ns.visible.hook[ i..':'..j ] = hook.Enabled and hook['Action List'] ~= 0
        end
    end

    for i, list in ipairs( Hekili.DB.profile.actionLists ) do

        if list.Enabled == nil then list.Enabled = true end

        ns.visible.list[ i ] = list.Enabled and ( list.Specialization == 0 or list.Specialization == state.spec.id )

        for j, action in ipairs( list.Actions ) do
            ns.visible.action[ i..':'..j ] = action.Enabled and action.Ability
        end
    end

end


RegisterEvent( "UPDATE_BINDINGS", function () ns.refreshBindings() end )
RegisterEvent( "DISPLAY_SIZE_CHANGED", function () ns.buildUI() end )
RegisterEvent( "PLAYER_ENTERING_WORLD", function ()
    ns.specializationChanged()
    ns.checkImports()
    ns.updateGear()
    ns.restoreDefaults( nil, true )
end )
RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED", function ()
    ns.specializationChanged()
    ns.checkImports()
end )
RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED", function ( _, unit )
    if unit == 'player' then
        ns.specializationChanged()
        ns.checkImports()
    end
end )


RegisterEvent( "BARBER_SHOP_OPEN", function ()
    Hekili.Barber = true
end )


RegisterEvent( "BARBER_SHOP_CLOSE", function ()
    Hekili.Barber = false
end )


ns.updateTalents = function ()

    for k, _ in pairs( state.talent ) do
        state.talent[k].enabled = false
        state.talent[k].i_enabled = 0
    end

    -- local specGroup = GetSpecialization()

    for i = 1, MAX_TALENT_TIERS do
        for j = 1, NUM_TALENT_COLUMNS do
            local _, name, _, enabled = GetTalentInfo( i, j, 1 )

            for k, v in pairs( ns.class.talents ) do
                if name == v.name then
                    if rawget( state.talent, k ) then
                        state.talent[ k ].enabled = enabled
                        state.talent[ k ].i_enabled = enabled and 1 or 0
                    else state.talent[ k ] = {
                            enabled = enabled,
                            i_enabled = enabled and 1 or 0
                        }
                    end
                    break
                end
            end
        end
    end

end


RegisterEvent( "PLAYER_TALENT_UPDATE", function ()
    ns.updateTalents()
end )



local artifactInitialized = false

function ns.updateArtifact()

    local artifact = state.artifact

    for k in pairs( artifact ) do
        artifact[ k ].rank = 0
    end

    local success, _, data = pcall( AD.GetArtifactInfo, AD )
    
    if success then    
        if data.traits then
            for key, trait in pairs( data.traits ) do
                local name, rank = formatKey( trait.name ), trait.currentRank
                artifact[ name ] = rawget( artifact, name ) or {}
                artifact[ name ].rank = rank
            end
            artifactInitialized = true
        else
            C_Timer.After( 3, ns.updateArtifact )
        end
    end

end

RegisterEvent( "ARTIFACT_UPDATE", ns.updateArtifact )


--[[ ns.updateGlyphs = function ()

    for k, _ in pairs( state.glyph ) do
        state.glyph[k].enabled = false
    end

    for i=1, NUM_GLYPH_SLOTS do
        local enabled, _, _, gID = GetGlyphSocketInfo(i)

        for k,v in pairs( class.glyphs ) do
            if gID == v.id then
                if enabled and v.name then
                    if rawget( state.glyph, k ) then state.glyph[ k ].enabled = true
                    else state.glyph[ k ] = { enabled = true } end
                    break
                end
            end
        end
    end

end


RegisterEvent( "GLYPH_ADDED", function () ns.updateGlyphs() end )
RegisterEvent( "GLYPH_REMOVED", function () ns.updateGlyphs() end )
RegisterEvent( "GLYPH_UPDATED", function () ns.updateGlyphs() end ) ]]


RegisterEvent( "ENCOUNTER_START", function () state.boss = true end )
RegisterEvent( "ENCOUNTER_END", function () state.boss = false end )


local gearInitialized = false
ns.updateGear = function ()

    for set, items in pairs( class.gearsets ) do
        state.set_bonus[ set ] = 0
        for item, _ in pairs( items ) do
            local itemName = GetItemInfo( item )

            if IsEquippedItem( GetItemInfo( item ) ) then
                state.set_bonus[ set ] = state.set_bonus[ set ] + 1
            end
        end
    end

    ns.Tooltip:SetOwner( UIParent, "ANCHOR_NONE")
    ns.Tooltip:ClearLines()

    local MH = GetInventoryItemLink( "player", 16 )

    if MH then
        ns.Tooltip:SetInventoryItem( "player", 16 )
        local lines = ns.Tooltip:NumLines()

        for i = 2, lines do
            line = _G[ "HekiliTooltipTextRight"..i ]:GetText()

            if line then
                local speed = tonumber( line:match( "%d[.,]%d+" ) )

                if speed then
                    state.mainhand_speed = speed
                    break
                end
            end
        end

        gearInitialized = true
    else
        state.mainhand_speed = 0
    end
    
    ns.Tooltip:ClearLines()

    if OffhandHasWeapon() then
        ns.Tooltip:SetInventoryItem( "player", 17 )
        local lines = ns.Tooltip:NumLines()

        for i = 2, lines do
            line = _G[ "HekiliTooltipTextRight"..i ]:GetText()

            if line then
                local speed = tonumber( line:match( "%d[.,]%d+" ) )

                if speed then
                    state.offhand_speed = speed
                    break
                end
            end
        end
    else
        state.offhand_speed = 0
    end
    
    ns.Tooltip:ClearLines()
    
    local T1 = GetInventoryItemID( "player", 13 )
    
    if T1 then
        local t1buff = ns.lib.LibItemBuffs:GetItemBuffs( T1 )
        
        if type(t1buff) == 'table' then t1buff = t1buff[1] end
        
        class.auras.trinket1 = class.auras[ t1buff ]
        state.trinket.t1.id = T1
    else
        state.trinket.t1.id = 0
    end
    
    local T2 = GetInventoryItemID( "player", 14 )
    
    if T2 then
        local t2buff = ns.lib.LibItemBuffs:GetItemBuffs( T2 )
        
        if type(t2buff) == 'table' then t2buff = t2buff[1] end
        
        class.auras.trinket2 = class.auras[ t2buff ]
        state.trinket.t2.id = T2
    else
        state.trinket.t2.id = 0
    end    

    ns.Tooltip:Hide()

    for i = 1, 19 do
        local item = GetInventoryItemID( 'player', i )

        if item then
            state.set_bonus[ item ] = 1
            local key = GetItemInfo( item )
            if key then
                key = formatKey( key )
                state.set_bonus[ key ] = 1
                state.set_bonus[ item ] = 1
                gearInitCompleted = true
            end
        end
    end

    if not gearInitialized then
        C_Timer.After( 3, ns.updateGear )
    else
        ns.updateArtifact()
    end

end


RegisterEvent( "PLAYER_EQUIPMENT_CHANGED", function()
        ns.updateGear()
        -- ns.updateArtifact()
end )


RegisterEvent( "PLAYER_REGEN_DISABLED", function () state.combat = GetTime() end )
RegisterEvent( "PLAYER_REGEN_ENABLED", function () state.combat = 0 end )

local dynamic_keys = setmetatable( {}, {
    __index = function( t, k, v )
        local name = GetSpellInfo( k )
        local key = name and formatKey( name ) or k
        t[k] = key
        return t[k]
    end
} )

ns.spells_in_flight = {}
local spells_in_flight = ns.spells_in_flight

ns.castsOff = { 'no_action', 'no_action', 'no_action', 'no_action', 'no_action' }
ns.castsOn = { 'no_action', 'no_action', 'no_action', 'no_action', 'no_action' }
ns.castsAll = { 'no_action', 'no_action', 'no_action', 'no_action', 'no_action' }

local castsOn, castsOff, castsAll = ns.castsOn, ns.castsOff, ns.castsAll


local function spellcastEvents( event, unit, spell, _, _, spellID )

    if unit == 'player' then

        local now = GetTime()

        if event == 'UNIT_SPELLCAST_SUCCEEDED' then

            if not class.castExclusions[ spellID ] then
                state.player.lastcast = class.abilities[ spellID ] and class.abilities[ spellID ].key or dynamic_keys[ spellID ]
                state.player.casttime = now

                local ability = class.abilities[ spellID ]

                if ability then
                    table.insert( castsAll, 1, ability.key )
                    castsAll[ 6 ] = nil

                    if ability.gcdType ~= 'off' then
                        table.insert( castsOn, 1, ability.key )
                        castsOn[ 6 ] = nil

                        state.player.lastgcd = ability.key
                        state.player.lastgcdtime = now
                    else
                        table.insert( castsOff, 1, ability.key )
                        castsOff[ 6 ] = nil

                        state.player.lastoffgcd = ability.key
                        state.player.lastoffgcdtime = now
                    end
                end
            end

            -- This is an ability with a travel time.
            if class.abilities[ spellID ] and class.abilities[ spellID ].velocity then

                local lands = 1

                -- If we have a hostile target, we'll assume we're waiting for them to get hit.
                if UnitExists( 'target' ) and not UnitIsFriend( 'player', 'target' ) then
                    -- Let's presume that the target is at max range.
                    local _, range = RC:GetRange( 'target' )

                    if range then
                        lands = range > 0 and range / class.abilities[ spellID ].velocity or 1
                    end
                end

                table.insert( spells_in_flight, 1, {
                    spell = class.abilities[ spellID ].key,
                    time = now + lands
                } )

            end
        end

        for i = 1, #Hekili.DB.profile.displays do
            displayUpdates[ i ] = now - ( 1 / Hekili.DB.profile['Updates Per Second'] ) + 0.01
        end
    end

end

RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", spellcastEvents )
RegisterEvent( "UNIT_SPELLCAST_START", spellcastEvents )



function ns.removeSpellFromFlight( spell )
    for i = #spells_in_flight, 1, -1 do
        if spells_in_flight[i].spell == spell then
            table.remove( spells_in_flight, i )
        end
    end
end


RegisterEvent( "UNIT_POWER_FREQUENT", function( _, unit, power)
    if unit == 'player' then
        for i = 1, #Hekili.DB.profile.displays do
            displayUpdates[ i ] = GetTime() - ( ( 1 / Hekili.DB.profile['Updates Per Second'] ) / 2 )
        end
    end
end )


-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

    if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' and ns.isTarget( destGUID ) then
        ns.eliminateUnit( destGUID )
        return
    end

    if subtype == 'SPELL_SUMMON' and sourceGUID == state.GUID then
        ns.updateMinion( destGUID, time )
        return
    end

    local hostile = ( bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 )
    local time = GetTime()

    if sourceGUID ~= state.GUID and not ( state.role.tank and destGUID == state.GUID ) and not ns.isMinion( sourceGUID ) then
        return
    end

    if state.role.tank and state.GUID == destGUID and subtype:sub(1,5) == 'SWING' then
        ns.updateTarget( sourceGUID, time, true )

    elseif subtype:sub( 1, 5 ) == 'SWING' and not multistrike then
        if subtype == 'SWING_MISSED' then offhand = spellName end

        local sw = state.swings

        if offhand and time > sw.oh_actual and sw.oh_speed then
            sw.oh_actual = time
            sw.oh_speed = select( 2, UnitAttackSpeed( 'player' ) )
            sw.oh_projected = sw.oh_actual + sw.oh_speed

        elseif not offhand and time > sw.mh_actual then
            sw.mh_actual = time
            sw.mh_speed = UnitAttackSpeed( 'player' )
            sw.mh_projected = sw.mh_actual + sw.mh_speed

        end

    -- Player/Minion Event
    elseif not class.exclusions[ spellID ] then
        if hostile and sourceGUID ~= destGUID and not ( class.auras[ spellID ] and class.auras[ spellID ].friendly ) then

            -- Aura Tracking
            if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then

                ns.trackDebuff( spellName, destGUID, time, true )
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

            elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                ns.trackDebuff( spellName, destGUID, time )
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

            elseif subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_MISSED' then
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

            elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                ns.trackDebuff( spellName, destGUID )

            end

            if subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

                if state.spec.enhancement and spellName == class.abilities.fury_of_air.name then
                    state.swings.last_foa_tick = time
                end

            end

            local action = class.abilities[ spellID ]
            
            if subtype ~= 'SPELL_CAST_SUCCESS' and action and action.velocity then
                ns.removeSpellFromFlight( class.abilities[ spellID ].key )
            end


        elseif sourceGUID == state.GUID and class.auras[ spellID ] and class.auras[ spellID ].friendly then -- friendly effects

            if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                ns.trackDebuff( spellName, destGUID, time, true )

            elseif subtype == 'SPELL_PERIODIC_HEAL' or subtype == 'SPELL_PERIODIC_MISSED' then
                ns.trackDebuff( spellName, destGUID, time )

            elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                ns.trackDebuff( spellName, destGUID )

            end

        end

    end

    -- This is dumb.  Just let modules used the event handler.
    ns.callHook( "COMBAT_LOG_EVENT_UNFILTERED", event, nil, subtype, nil, sourceGUID, sourceName, nil, nil, destGUID, destName, destFlags, nil, spellID, spellName, nil, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

end )



RegisterEvent( "UNIT_COMBAT", function( event, unitID, action, descriptor, damage, damageType )

        if unitID == 'player' and damage > 0 then
            if action == 'WOUND' then
                ns.storeDamage( GetTime(), damage, damageType )
            elseif action == 'HEAL' then
                ns.storeHealing( GetTime(), damage )
            end
        end
        
end )


-- Time to die calculations.
RegisterEvent( "UNIT_HEALTH", function( _, unit )

    if not unit then return end

    local GUID = UnitGUID( unit )

    if not ns.isTarget( GUID ) then
        return
    end

    if not TTD or not TTD[ GUID ] then ns.initTTD( unit ) end

    if not TTD[ GUID ] and not UnitIsFriend( 'player', unit ) then
        ns.initTTD( unit )
    end

    if ( UnitHealth( unit ) == UnitHealthMax( unit ) ) then
        ns.initTTD( unit )
        return
    end

    local now = GetTime()

    if ( not TTD[ GUID ].n ) then ns.initTTD( unit ) end

    local ttd = TTD[ GUID ]

    ttd.n = ttd.n + 1
    ttd.timeSum = ttd.timeSum + now
    ttd.healthSum = ttd.healthSum + UnitHealth( unit )
    ttd.timeMean = ttd.timeMean + (now * now)
    ttd.healthMean = ttd.healthMean + (now * UnitHealth( unit ))

    local difference = ( ttd.healthSum * ttd.timeMean - ttd.healthMean * ttd.timeSum)
    local projectedTTD = nil

    if difference > 0 then
        local divisor = ( ttd.healthSum * ttd.timeSum ) - ( ttd.healthMean * ttd.n )
        projectedTTD = 0
        if divisor > 0 then
            projectedTTD = difference / divisor - now
        end
    end

    if not projectedTTD or projectedTTD < 0 or ttd.n < 3 then
        return
    else
        projectedTTD = ceil(projectedTTD)
    end

    ttd.sec = projectedTTD

end )
