-- Targets.lua
-- June 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local targetCount = 0
local targets = {}

local myTargetCount = 0
local myTargets = {}

local nameplates = {}
local addMissingTargets = true

local npCount = 0
local lastNpCount = 0

local formatKey = ns.formatKey
local orderedPairs = ns.orderedPairs
local FeignEvent = ns.FeignEvent
local RegisterEvent = ns.RegisterEvent

local tinsert, tremove = table.insert, table.remove


local unitIDs = { "boss1", "boss2", "boss3", "boss4", "boss5" }

for i = 1, 80 do
    unitIDs[ #unitIDs + 1 ] = "nameplate" .. i
end

local RC = LibStub( "LibRangeCheck-2.0" )


-- New Nameplate Proximity System
function ns.getNumberTargets()
    local showNPs = GetCVar( 'nameplateShowEnemies' ) == "1"

    for k,v in pairs( nameplates ) do
        nameplates[k] = nil
    end
    Hekili.TargetDebug = nil

    npCount = 0

    local spec = state.spec.id
    spec = spec and rawget( Hekili.DB.profile.specs, spec )

    if spec and spec.nameplates and showNPs then
        for i, unit in ipairs( unitIDs ) do
            if UnitExists( unit ) then
                local guid = UnitGUID( unit )                
                local _, range = RC:GetRange( unit )

                Hekili.TargetDebug = ( Hekili.TargetDebug or "" ) .. format( "%12s - %2d - %s\n", unit, range or 0, guid )

                if not nameplates[ guid ] and ( unit == "target" or ( range and range < spec.nameplateRange ) ) and ( not UnitIsDead( unit ) ) and UnitCanAttack( "player", unit ) and UnitInPhase( unit ) and ( UnitIsPVP( "player" ) or not UnitIsPlayer( unit ) ) then
                    npCount = npCount + 1
                end

                nameplates[ guid ] = range -- record as seen
            end
        end
    end


    -- check other units in the damage list, but only if we didn't rule them out as nameplates already.
    if not spec or ( spec.damage or not spec.nameplates ) or not showNPs then
        local db = spec and ( spec.myTargetsOnly and myTargets or targets ) or targets -- spec.myTargetsOnly isn't an actual thing; revisit.
        
        for k, v in pairs( db ) do
            if not nameplates[ k ] then
                nameplates[ k ] = true
                npCount = npCount + 1
            end
        end
    end

    return npCount
end

function Hekili:GetNumTargets()
    return ns.getNumberTargets()
end


local forceRecount = false

function ns.forceRecount()
    forceRecount = true
end


function ns.recountRequired()
    return forceRecount
end


function ns.recountTargets()
    lastNpCount = npCount
    npCount = ns.getNumberTargets()
    forceRecount = false
end


function ns.targetsChanged()
    return ( lastNpCount < 2 and npCount > 1 ) or ( npCount < 2 and lastNpCount > 1 )
end


function ns.dumpNameplateInfo()
    return nameplates
end


function ns.updateTarget( id, time, mine )

    if id == state.GUID then return end

    if time then
        if not targets[ id ] then
            targetCount = targetCount + 1
            targets[ id ] = time
            ns.updatedTargetCount = true
        else
            targets[ id ] = time
        end

        if mine then
            if not myTargets[ id ] then
                myTargetCount = myTargetCount + 1
                myTargets[ id ] = time
                ns.updatedTargetCount = true
            else
                myTargets[ id ] = time
            end
        end

    else
        if targets[ id ] then
            targetCount = max(0, targetCount - 1)
            targets[ id ] = nil
        end

        if myTargets[ id ] then
            myTargetCount = max(0, myTargetCount - 1)
            myTargets[ id ] = nil
        end

        ns.updatedTargetCount = true
    end
end


ns.reportTargets = function()
  for k, v in pairs( targets ) do
    Hekili:Print( "Saw " .. k .. " exactly " .. GetTime() - v .. " seconds ago." )
  end
end


ns.numTargets = function() return targetCount > 0 and targetCount or 1 end
ns.numMyTargets = function() return myTargetCount > 0 and myTargetCount or 1 end
ns.isTarget = function( id ) return targets[ id ] ~= nil end
ns.isMyTarget = function( id ) return myTargets[ id ] ~= nil end


-- MINIONS
local minions = {}

ns.updateMinion = function( id, time )
    minions[ id ] = time    
end

ns.isMinion = function( id )
    return minions[ id ] ~= nil or UnitGUID( "pet" ) == id
end

function Hekili:HasMinionID( id )
    for k, v in pairs( minions ) do
        local npcID = tonumber( k:match( "%-(%d+)%-[0-9A-F]+$" ) )

        if npcID == id and v > state.now then
            return true, v
        end
    end
end


function Hekili:DumpMinions()
    local o = ""

    for k, v in orderedPairs( minions ) do
        o = o .. k .. " " .. tostring( v ) .. "\n"
    end

    return o
end
        

local debuffs = {}
local debuffCount = {}
local debuffMods = {}


function ns.saveDebuffModifier( id, val )
    debuffMods[ id ] = val
end


ns.wipeDebuffs = function()
  for k, _ in pairs( debuffs ) do
    table.wipe( debuffs[ k ] )
    debuffCount[ k ] = 0
  end
end


ns.trackDebuff = function( spell, target, time, application )

  debuffs[ spell ] = debuffs[ spell ] or {}
  debuffCount[ spell ] = debuffCount[ spell ] or 0

  if not time then
    if debuffs[ spell ][ target ] then
      -- Remove it.
      debuffs[ spell ][ target ] = nil
      debuffCount[ spell ] = max( 0, debuffCount[ spell ] - 1 )
    end

  else
    if not debuffs[ spell ][ target ] then
      debuffs[ spell ][ target ] = {}
      debuffCount[ spell ] = debuffCount[ spell ] + 1
    end

    local debuff = debuffs[ spell ][ target ]

    debuff.last_seen = time
    debuff.applied = debuff.applied or time

    if application then
        debuff.pmod = debuffMods[ spell ]
    else
        debuff.pmod = debuff.pmod or 1
    end
  end

end


function ns.getModifier( id, target )

    local debuff = debuffs[ id ]
    if not debuff then return 1 end

    local app = debuff[ target ]
    if not app then return 1 end

    return app.pmod or 1

end


ns.numDebuffs = function( spell ) return debuffCount[ spell ] or 0 end


ns.compositeDebuffCount = function( ... )
    local n = 0

    for i = 1, select( "#", ... ) do
        local debuff = debuffs[ spell ]
        if debuff then
            for unit in pairs( debuff ) do
                n = n + 1
            end
        end
    end

    return n
end

ns.conditionalDebuffCount = function( req1, req2, ... )
    local n = 0

    req1 = class.auras[ req1 ] and class.auras[ req1 ].id
    req2 = class.auras[ req2 ] and class.auras[ req2 ].id

    for i = 1, select( "#", ... ) do
        local debuff = select( i, ... )
        debuff = class.auras[ debuff ] and class.auras[ debuff ].id
        debuff = debuff and debuffs[ debuff ]

        if debuff then
            for unit in pairs( debuff ) do
                local reqExp = ( req1 and debuffs[ req1 ] and debuffs[ req1 ][ unit ] ) or ( req2 and debuffs[ req2 ] and debuffs[ req2 ][ unit ] )
                if reqExp then
                    n = n + 1
                end
            end
        end
    end

    return n
end


ns.isWatchedDebuff = function( spell ) return debuffs[ spell ] ~= nil end


ns.eliminateUnit = function( id, force )
  ns.updateMinion( id )
  ns.updateTarget( id )

  if force then
      for k,v in pairs( debuffs ) do
        ns.trackDebuff( k, id )
      end
  end
end


local incomingDamage = {}
local incomingHealing = {}

ns.storeDamage = function( time, damage, damageType ) table.insert( incomingDamage, { t = time, damage = damage, damageType = damageType } ) end
ns.storeHealing = function( time, healing ) table.insert( incomingHealing, { t = time, healing = healing } ) end

ns.damageInLast = function( t )

  local dmg = 0
  local start = GetTime() - min( t, 15 )

  for k, v in pairs( incomingDamage ) do

    if v.t > start then
      dmg = dmg + v.damage
    end

  end

  return dmg

end


function ns.healingInLast( t )
    local heal = 0
    local start = GetTime() - min( t, 15 )

    for k, v in pairs( incomingHealing ) do
        if v.t > start then
            heal = heal + v.healing
        end
    end

    return heal
end


-- Auditor should clean things up for us.
ns.Audit = function ()
    local now = GetTime()
    local spec = state.spec.id and Hekili.DB.profile.specs[ state.spec.id ]
    local grace = spec and spec.damageExpiration or 6

    for aura, targets in pairs( debuffs ) do
        local a = class.auras[ aura ]
        local window = a and a.duration or grace
        local expires = a and a.no_ticks or false

        for unit, entry in pairs( targets ) do
            -- NYI: Check for dot vs. debuff, since debuffs won't 'tick'
            if expires and now - entry.last_seen > window then
                ns.trackDebuff( aura, unit )
            end
        end
    end

    for whom, when in pairs( targets ) do
        if now - when > grace then
            ns.eliminateUnit( whom )
        end
    end

    for i = #incomingDamage, 1, -1 do
        local instance = incomingDamage[ i ]

        if instance.t < ( now - 15 ) then
            table.remove( incomingDamage, i )
        end
    end

    for i = #incomingHealing, 1, -1 do
        local instance = incomingHealing[ i ]

        if instance.t < ( now - 15 ) then
            table.remove( incomingHealing, i )
        end
    end

    if Hekili.DB.profile.enabled then
        C_Timer.After( 1, ns.Audit )
    end
end





do

    local recycleBin = {}    
    local TTD = ns.TTD


    -- Borrowed TTD linear regression model from 'Nemo' by soulwhip (with permission).
    local function InitTTD( unit )

        if not unit then return end
        local GUID = UnitGUID( unit )

        TTD[ GUID ] = TTD[ GUID ] or tremove( recycleBin ) or {}
        TTD[ GUID ].n = 1
        TTD[ GUID ].timeSum = GetTime()
        TTD[ GUID ].healthSum = UnitHealth( unit ) or 0
        TTD[ GUID ].timeMean = TTD[ GUID ].timeSum * TTD[ GUID ].timeSum
        TTD[ GUID ].healthMean = TTD[ GUID ].timeSum * TTD[ GUID ].healthSum
        TTD[ GUID ].name = UnitName( unit )
        TTD[ GUID ].sec = state.boss and 300 or 15

    end


    local function UpdateTTD( unit )
        local guid = UnitExists( unit ) and UnitGUID( unit )
        if not guid then return end

        local health, healthMax = UnitHealth( unit ), UnitHealthMax( unit )

        local now = GetTime()


        if not TTD[ guid ] or health == healthMax or not TTD[ guid ].n then
            InitTTD( unit )
        end

        local ttd = TTD[ guid ]

        ttd.n = ttd.n + 1

        ttd.timeSum = ttd.timeSum + now
        ttd.timeMean = ttd.timeMean + ( now * now )

        ttd.healthSum = ttd.healthSum + health
        ttd.healthMean = ttd.healthMean + ( now * health )

        local projected
        local difference = ( ttd.healthSum * ttd.timeMean - ttd.healthMean * ttd.timeSum )

        if difference > 0 then
            local divisor = ( ttd.healthSum * ttd.timeSum ) - ( ttd.healthMean * ttd.n )

            projected = 0
            if divisor > 0 then projected = difference / divisor - now end
        end

        if not projected or projected <= 0 or ttd.n < 3 then
            return
        else
            projected = ceil( projected )
        end

        ttd.sec = projected
    end
    Hekili.UpdateTTD = UpdateTTD


    local seen  = {}
    local units = { 'target', 'focus', 'focustarget', 'mouseover', 'boss1', 'boss2', 'boss3', 'boss4', 'boss5' }


    local function PulseTTD()

        table.wipe( seen )

        -- Check all nameplates first.
        for i = 1, 30 do
            local np = 'nameplate' .. i
            if UnitExists( np ) then
                local guid = UnitGUID( np )

                if UnitCanAttack( 'player', np ) then
                    if guid and not seen[ guid ] then
                        seen[ guid ] = true
                        UpdateTTD( np )
                    end
                else
                    tinsert( recycleBin, TTD[ guid ] )
                    TTD[ guid ] = nil
                end
            end
        end

        -- Check common units.
        for _, unit in pairs( units ) do
            if UnitExists( unit ) then
                local guid = UnitGUID( unit )
                if UnitCanAttack( 'player', unit ) then
                    if guid and not seen[ guid ] then
                        seen[ guid ] = true
                        UpdateTTD( unit )
                    end
                else
                    tinsert( recycleBin, TTD[ guid ] )
                    TTD[ guid ] = nil
                end
            end
        end
    end

    Hekili.TTDTimer = C_Timer.NewTicker( 1, PulseTTD )


    function Hekili:PurgeTTD( unit )
        for guid, unit in pairs( TTD ) do
            tinsert( recycleBin, unit )
            TTD[ guid ] = nil
        end
    end


    function Hekili:DumpTTDs() 
        for guid, death in pairs( TTD ) do
            DevTools_Dump( death )
        end
    end


    function Hekili:GetTTD( unit )
        local GUID = UnitGUID( unit ) or unit

        if not TTD[ GUID ] then return 15 end

        if state.time < 5 then return max( TTD[ GUID ].sec, 15 - state.time ) end

        return min( 300, TTD[ GUID ].sec or 15 )
    end

    
    function Hekili:GetGreatestTTD()
        local ttd = 15 - state.time

        for k, v in pairs( TTD ) do
            if v.sec > ttd then ttd = v.sec end
        end

        return min( 300, ttd )
    end
end






-- New Target Detection
-- January 2018

-- 1. Nameplate Detection
--    Overall, nameplate detection is really good.  Except when a target's nameplate goes off the screen.  So we need to count other potential targets.
--
-- 2. Damage Detection
--    We need to fine tune this a bit so that we can implement spell_targets.  We will flag targets as being hit by melee damage, spell damage, or ticking
--    damage.

--[[ do

    local RC  = LibStub( "LibRangeCheck-2.0" )

    local targetCount = 0 
       
    local targetPool = {}
    local recycleBin = {}

    local function newTarget( guid, unit )
        if not guid or targetPool[ guid ] then return end

        local target = tremove( recycleBin ) or {}

        target.guid = guid

        target.lastMelee  = 0  -- last SWING_DAMAGE by you.
        target.lastSpell  = 0  -- last SPELL_DAMAGE by you.
        target.lastTick   = 0  -- last SPELL_PERIODIC_DAMAGE by you.
        target.lastAttack = 0  -- last SWING_DAMAGE by target to a friendly.

        tinsert( targetPool, target )
        return target
    end


    local function expireTarget( guid )
        if not guid then return end

        local target = targetPool[ guid ]

        if not target then return end

        targetPool[ guid ] = nil
        tinsert( recycleBin, target )
    end


    local function updateTarget( guid, unit, melee, spell, tick )
        if not guid and not unit then return end
        guid = guid or UnitGUID( unit )

        local target = targetPool[ guid ] or newTarget( guid, unit ) 

        if melee then target.lastMelee = GetTime() end
        if spell then target.lastSpell = GetTime() end
        if tick  then target.lastTick  = GetTime() end
    end


    local function expireTargets( limit )
        local now = GetTime()

        for guid, data in pairs( targetPool ) do
            local latest = max( data.lastMelee, data.lastSpell, data.lastTick )
            if now - latest > limit then
                expireTarget( GUID )
            end
        end
    end


    local lastCount, lastRange, lastLimit, lastTime = 0, 0, 0, 0

    local function getTargetsWithin( x, limit )
        local now = GetTime()
        limit = limit or 5        

        if x == lastRange and limit == lastLimit and now == lastTime then
            return lastCount
        end

        lastRange = x
        lastLimit = limit
        lastTime  = now
        lastCount = 0

        for guid, data in pairs( targetPool ) do
            -- local unit = NPR:GetPlateByGUID( guid )

            if unit then
                local _, distance = RC:GetRange( unit )

                if distance <= x then
                    lastCount = lastCount + 1
                end

            elseif limit <= 8 then
                -- If they're in melee, use the last hit.
                if now - data.lastMelee < limit then
                    lastCount = lastCount + 1
                end
            
            else
                -- Try the cached unit vs. GUIDs.
                -- Consider that target changes may happen really quickly, may have to reconsider this.               
            end
        end

        return lastCount
    end


    local targetFrame = CreateFrame( "Frame" )

    targetFrame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
    targetFrame:SetScript( "OnEvent", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, ... )

        -- Targets 


    end )

end ]]