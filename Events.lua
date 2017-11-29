-- Events.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state
local TTD = ns.TTD

local formatKey = ns.formatKey
local getSpecializationInfo = ns.getSpecializationInfo
local getSpecializationKey = ns.getSpecializationKey

local abs = math.abs
local lower, match, upper = string.lower, string.match, string.upper


-- Abandoning AceEvent in favor of darkend's solution from:
-- http://andydote.co.uk/2014/11/23/good-design-in-warcraft-addons.html
-- This should be a bit friendlier for our modules.

local events = CreateFrame( "Frame" )
local handlers = {}
local unitEvents = CreateFrame( "Frame" )
local unitHandlers = {}

ns.displayUpdates = {}

local lastRefresh = {}
local lastRecount = 0
local displayUpdates = ns.displayUpdates
local lastDisplay = 0


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
        local now = GetTime()

        if now - lastRecount >= 0.05 then
            ns.recountTargets()
            lastRecount = now
        end

        local updatePeriod = state.combat == 0 and 0.5 or 0.2

        local numDisplays = #Hekili.DB.profile.displays

        for i = 1, numDisplays do
            local index = lastDisplay + i
            index = index > numDisplays and index - numDisplays or index

            if ns.visible.display[ index ] and ( not displayUpdates[ index ] or ( not lastRefresh[ index ] or now - lastRefresh[ index ] >= updatePeriod ) ) then
                Hekili:ProcessHooks( index )
                lastRefresh[ index ] = now
                lastDisplay = index
                break
            end
        end

        Hekili:UpdateDisplays()
    end )

end


function ns.StopEventHandler()

    events:SetScript( "OnEvent", nil )
    unitEvents:SetScript( "OnEvent", nil )
    events:SetScript( "OnUpdate", nil )

end


ns.RegisterEvent = function( event, handler )

    handlers[ event ] = handlers[ event ] or {}
    table.insert( handlers[ event ], handler )

    events:RegisterEvent( event )

end
local RegisterEvent = ns.RegisterEvent


function ns.UnregisterEvent( event, handler )
    local hands = handlers[ event ]

    if not hands then return end

    for i = #hands, 1, -1 do
        if hands[i] == handler then
            table.remove( hands, i )
        end
    end
end


-- For our purposes, all UnitEvents are player/target oriented.
ns.RegisterUnitEvent = function( event, handler, u1, u2 )

    unitHandlers[ event ] = unitHandlers[ event ] or {}
    table.insert( unitHandlers[ event ], handler )

    unitEvents:RegisterUnitEvent( event, 'player', 'target' )

end
local RegisterUnitEvent = ns.RegisterUnitEvent


function ns.UnregisterUnitEvent( event, handler )
    local hands = unitHandlers[ event ]

    if not hands then return end

    for i = #hands, 1, -1 do
        if hands[i] == handler then
            table.remove( hands, i )
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


-- FIND A BETTER HOME
ns.cacheCriteria = function()

    for key, group in pairs( ns.visible ) do
        for key in pairs( group ) do
            group[ key ] = nil
        end
    end

    for i, display in ipairs( Hekili.DB.profile.displays ) do
        ns.visible.display[ i ] = display.Enabled and ( display.Specialization == 0 or display.Specialization == state.spec.id )
    end

    for i, list in ipairs( Hekili.DB.profile.actionLists ) do
        ns.visible.list[ i ] = ( list.Specialization == 0 or list.Specialization == state.spec.id )

        for j, action in ipairs( list.Actions ) do
            ns.visible.action[ i..':'..j ] = action.Enabled and action.Ability
        end
    end

end


RegisterEvent( "UPDATE_BINDINGS", function () ns.refreshBindings() end )
RegisterEvent( "DISPLAY_SIZE_CHANGED", function () ns.buildUI() end )


local itemAuditComplete = false

function ns.auditItemNames()

    local options = Hekili.Options.args.trinkets.args
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
                class.searchAbilities[ ability.key ] = format( "|T%s:0|t %s", ( ability.texture or 'Interface\\ICONS\\Spell_Nature_BloodLust' ), link )
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


RegisterEvent( "PLAYER_ENTERING_WORLD", function ()
    ns.specializationChanged()
    ns.checkImports()
    ns.updateGear()
    ns.restoreDefaults( nil, true )
    ns.convertDisplays()
    ns.buildUI()

    ns.auditItemNames()
end )

RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED", function ()
    ns.specializationChanged()
    ns.checkImports()
end )

RegisterUnitEvent( "PLAYER_SPECIALIZATION_CHANGED", function ( event, unit )
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

    for item, specs in pairs( class.talentLegendary ) do
        local tal = specs[ state.spec.key ]
        if state.equipped[ item ] and tal then
            if rawget( state.talent, tal ) then
                state.talent[ tal ].enabled = true
                state.talent[ tal ].i_enabled = 1
            else state.talent[ tal ] = {
                    enabled = true,
                    i_enabled = 1
                }
            end
        end
    end

end


RegisterEvent( "PLAYER_TALENT_UPDATE", function ( event )
    ns.updateTalents()
    ns.forceUpdate( event )
end )



local artifactInitialized = false

function ns.updateArtifact()

    local artifact = state.artifact
    local AD = LibStub( "LibArtifactData-1.0h" )

    for k in pairs( artifact ) do
        artifact[ k ].rank = 0
    end

    local success, _, data = pcall( AD.GetArtifactInfo, AD )
    
    if success then    
        if data.traits then
            for key, trait in pairs( data.traits ) do
                local id, rank = trait.spellID, trait.currentRank

                local name = class.traits[ id ] or formatKey( trait.name )
                
                artifact[ name ] = rawget( artifact, name ) or {}
                artifact[ name ].rank = rank
            end
            artifactInitialized = true
        else
            C_Timer.After( 3, ns.updateArtifact )
        end
    else
        C_Timer.After( 3, ns.updateArtifact )
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

    for thing in pairs( state.set_bonus ) do
        state.set_bonus[ thing ] = 0
    end

    for set, items in pairs( class.gearsets ) do
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
        end
    end


    for item, specs in pairs( class.talentLegendary ) do
        if item and state.equipped[ item ] then
            local tal = specs[ state.spec.key ]

            if tal then
                if rawget( state.talent, tal ) then
                    state.talent[ tal ].enabled = true
                    state.talent[ tal ].i_enabled = 1
                else state.talent[ tal ] = {
                        enabled = true,
                        i_enabled = 1
                    }
                end
            end
        end
    end


    if not gearInitialized then
        C_Timer.After( 3, ns.updateGear )
    else
        ns.updateArtifact()
        ns.ReadKeybindings()
    end

end


RegisterEvent( "PLAYER_EQUIPMENT_CHANGED", function()
    ns.updateGear()
    ns.updateTalents()
    -- ns.updateArtifact()
end )


RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
    state.combat = GetTime()
end )


RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    ns.updateGear()
    state.combat = 0
end )


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





local function forceUpdate( from, super )

    for i = 1, #Hekili.DB.profile.displays do
        displayUpdates[ i ] = nil
    end

    return

end

ns.forceUpdate = forceUpdate


local function spellcastEvents( event, unit, spell, _, _, spellID )

    local now = GetTime()

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

        local lands = state.latency or 0.05

        -- If we have a hostile target, we'll assume we're waiting for them to get hit.
        if UnitExists( 'target' ) and not UnitIsFriend( 'player', 'target' ) then
            -- Let's presume that the target is at max range.
            local RC = LibStub( "LibRangeCheck-2.0" )
            local _, range = RC:GetRange( 'target' )

            if range then
                lands = range > 0 and ( range / class.abilities[ spellID ].velocity ) or lands
            end
        end

        table.insert( spells_in_flight, 1, {
            spell = class.abilities[ spellID ].key,
            time = now + lands
        } )

    end

end






-- Need to make caching system.
--[[ RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( event, unit, spell, _, _, spellID )
    if unit == 'player' then forceUpdate( event, spell ) end
end ) ]]

-- RegisterUnitEvent( "UNIT_SPELLCAST_START", forceUpdate, 'player' )


--[[ WiP - Fire quicker on UNIT_SPELLCAST_SUCCEEDED, but be prepared to revise the cast queue.

local queueTime = 0

RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( event, unit, spell, _, _, spellID )
    local window = GetCVar( 'spellQueueWindow' ) / 1000
    local latency = state.latency or 50

    -- We need to test to see if our last cast queued something.
... ]]


function ns.removeSpellFromFlight( spell )
    for i = #spells_in_flight, 1, -1 do
        if spells_in_flight[i].spell == spell then
            table.remove( spells_in_flight, i )
        end
    end
end


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


RegisterUnitEvent( "UNIT_POWER_FREQUENT", function( event, unit, power )
    if unit ~= 'player' then return end

    if power == "FOCUS" and state.focus then
        local now = GetTime()
        local elapsed = now - state.focus.last_tick

        elapsed = elapsed > power_tick_data.focus_avg * 1.5 and power_tick_data.focus_avg or elapsed

        if elapsed > 0.075 then
            power_tick_data.focus_avg = ( elapsed + ( power_tick_data.focus_avg * power_tick_data.focus_ticks ) ) / ( power_tick_data.focus_ticks + 1 )
            power_tick_data.focus_ticks = power_tick_data.focus_ticks + 1
            state.focus.last_tick = now
        end

    elseif power == "ENERGY" and state.energy then
        local now = GetTime()
        local elapsed = min( 0.12, now - state.energy.last_tick )
        elapsed = elapsed > power_tick_data.energy_avg * 1.5 and power_tick_data.energy_avg or elapsed

        if elapsed > 0.075 then
            power_tick_data.energy_avg = ( elapsed + ( power_tick_data.energy_avg * power_tick_data.energy_ticks ) ) / ( power_tick_data.energy_ticks + 1 )
            power_tick_data.energy_ticks = power_tick_data.energy_ticks + 1
            state.energy.last_tick = now
        end

    end

    -- forceUpdate( event )
end )

RegisterUnitEvent( "UNIT_POWER", function( event, unit, power )
    if unit ~= 'player' then return end
    forceUpdate( event )
end )

--[[ RegisterEvent( "UNIT_POWER", function( event, unit, power )
    if unit == 'player' then
        forceUpdate( event )
    end
end ) ]]



-- RegisterEvent( "SPELL_UPDATE_USABLE", forceUpdate )
RegisterEvent( "SPELL_UPDATE_COOLDOWN", forceUpdate )


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
    if unit == 'player' then
        state.player.updated = true
        -- forceUpdate( event, true )
    else
        state.target.updated = true
    end
end )


RegisterEvent( "PLAYER_TARGET_CHANGED", function ( event )
    state.target.updated = true
    forceUpdate( event, true )
end )


-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

    if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' and ns.isTarget( destGUID ) then
        ns.eliminateUnit( destGUID, true )
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

    if sourceGUID == state.GUID and ( subtype == 'SPELL_CAST_SUCCESS' or subtype == 'SPELL_CAST_START' ) then
        if subtype == 'SPELL_CAST_SUCCESS' then
            spellcastEvents( subtype, sourceGUID, spellName, _, _, spellID )
            state.player.queued_ability = nil
            state.player.queued_time = nil
            state.player.queued_tt = nil
            state.player.queued_lands = nil
            state.player.queued_gcd = nil
            state.player.queued_off = nil
        end
        forceUpdate( subtype, true )
    end


    if state.role.tank and state.GUID == destGUID and subtype:sub(1,5) == 'SWING' then
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
    elseif not class.exclusions[ spellID ] then
        local aura = class.auras and class.auras[ spellID ]
        
        if aura and hostile and sourceGUID ~= destGUID and not aura.friendly then

            -- Aura Tracking
            if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                ns.trackDebuff( spellID, destGUID, time, true )
                forceUpdate( subtype )
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

            elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                ns.trackDebuff( spellID, destGUID, time )
                forceUpdate( subtype )
                -- ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

            elseif subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_MISSED' then
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )
                forceUpdate( subtype )

            elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                ns.trackDebuff( spellID, destGUID )
                forceUpdate( subtype )

            end

            if subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
                ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

                if state.spec.enhancement and spellName == class.abilities.fury_of_air.name then
                    state.swings.last_foa_tick = time
                    forceUpdate( subtype )
                end

            end

            local action = class.abilities[ spellID ]
            
            if subtype ~= 'SPELL_CAST_SUCCESS' and action and action.velocity then
                ns.removeSpellFromFlight( action.key )
            end

        elseif sourceGUID == state.GUID and aura and aura.friendly then -- friendly effects

            if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' then
                ns.trackDebuff( spellID, destGUID, time, subtype == 'SPELL_AURA_APPLIED' )
                forceUpdate( subtype )

            elseif subtype == 'SPELL_PERIODIC_HEAL' or subtype == 'SPELL_PERIODIC_MISSED' then
                ns.trackDebuff( spellID, destGUID, time )
                forceUpdate( subtype )

            elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                ns.trackDebuff( spellID, destGUID )
                forceUpdate( subtype )

            end

        end

    end

    -- This is dumb.  Just let modules used the event handler.
    ns.callHook( "COMBAT_LOG_EVENT_UNFILTERED", event, nil, subtype, nil, sourceGUID, sourceName, nil, nil, destGUID, destName, destFlags, nil, spellID, spellName, nil, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

end )



RegisterUnitEvent( "UNIT_COMBAT", function( event, unit, action, descriptor, damage, damageType )

    if unit ~= 'player' then return end

    if damage > 0 then
        if action == 'WOUND' then
            ns.storeDamage( GetTime(), damage, damageType )
        elseif action == 'HEAL' then
            ns.storeHealing( GetTime(), damage )
        end
    end
        
end )


-- Time to die calculations.
RegisterEvent( "UNIT_HEALTH", function( event, unit )

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



local keys = ns.hotkeys
local updatedKeys = {}

local bindingSubs = {
    ["CTRL%-"] = "c",
    ["ALT%-"] = "a",
    ["SHIFT%-"] = "s",
    ["STRG%-"] = "st",
    ["%s+"] = "",
    ["NUMPAD"] = "n",
    ["PLUS"] = "+",
    ["MINUS"] = "-",
    ["MULTIPLY"] = "*",
    ["DIVIDE"] = "/"
}

local function improvedGetBindingText( binding )
    if not binding then return "" end

    for k, v in pairs( bindingSubs ) do
        binding = binding:gsub( k, v )
    end

    return binding
end


local function StoreKeybindInfo( page, key, aType, id )

    if not key then return end

    local ability

    if aType == "spell" then
        ability = class.abilities[ id ] and class.abilities[ id ].key

    elseif aType == "macro" then
        local _, _, sID = GetMacroSpell( id )

        ability = sID and class.abilities[ sID ] and class.abilities[ sID ].key
    
    elseif aType == "item" then
        ability = GetItemInfo( id )
        ability = class.abilities[ ability ] and class.abilities[ ability ].key

    end

    if ability then
        keys[ ability ] = keys[ ability ] or {
            lower = {},
            upper = {}
        }
        keys[ ability ].lower[ page ] = lower( improvedGetBindingText( key ) )
        keys[ ability ].upper[ page ] = upper( keys[ ability ].lower[ page ] )
        updatedKeys[ ability ] = true

        if ability.bind then
            local bind = ability.bind

            keys[ bind ] = keys[ bind ] or {
                lower = {},
                upper = {}
            }

            keys[ bind ].lower[ page ] = keys[ ability ].lower[ page ]
            keys[ bind ].upper[ page ] = keys[ ability ].upper[ page ]

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
        table.wipe( v.upper )
        table.wipe( v.lower )
    end

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

    for i = 73, 120 do
        StoreKeybindInfo( 7 + floor( ( i - 72 ) / 12 ), GetBindingKey( "ACTIONBUTTON" .. ( i - 72 ) % 12 ), GetActionInfo( i ) )
    end

    --[[ for k in pairs( keys ) do
        if not updatedKeys[ k ] then
            for key in pairs( keys[ k ].lower ) do
                keys[ k ].lower[ key ] = nil
                keys[ k ].upper[ key ] = nil
                keys[ k ].empty = true
            end
        end
    end ]]

    for k in pairs( keys ) do
        local ability = class.abilities[ k ]

        if ability and ability.bind then
            for key, value in pairs( keys[ k ].lower ) do
                keys[ ability.bind ] = keys[ ability.bind ] or {
                    lower = {},
                    upper = {}
                }
                keys[ ability.bind ].lower[ key ] = value
                keys[ ability.bind ].upper[ key ] = keys[ k ].upper[ key ]
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

RegisterEvent( "UPDATE_SHAPESHIFT_FORM", ReadKeybindings )
RegisterUnitEvent( "PLAYER_TALENT_UPDATE", ReadKeybindings )
RegisterUnitEvent( "PLAYER_EQUIPMENT_CHANGED", ReadKeybindings )


if select( 2, UnitClass( "player" ) ) == "DRUID" then
    function Hekili:GetBindingForAction( key, caps )
        if not key or not keys[ key ] then return "" end

        local db = caps and keys[ key ].upper or keys[ key ].lower

        if state.prowling then
            return db[ 8 ] or db[ 7 ] or db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 9 ] or db[ 10 ] or ""

        elseif state.buff.cat_form.up then
            return db[ 7 ] or db[ 8 ] or db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 9 ] or db[ 10 ] or ""

        elseif state.buff.bear_form.up then
            return db[ 9 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 1 ] or db[ 2 ] or db [ 7 ] or db[ 8 ] or db[ 10 ] or ""

        elseif state.buff.moonkin_form.up then
            return db[ 10 ] or db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or ""

        end
    
        return db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or db[ 10 ] or ""
    end
else
    function Hekili:GetBindingForAction( key, caps )
        if not key or not keys[ key ] then return "" end

        local db = caps and keys[ key ].upper or keys[ key ].lower

        return db[ 1 ] or db[ 2 ] or db[ 3 ] or db[ 4 ] or db[ 5 ] or db[ 6 ] or db[ 7 ] or db[ 8 ] or db[ 9 ] or db[ 10 ] or ""
    end

end