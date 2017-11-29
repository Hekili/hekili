-- Targets.lua
-- June 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local targetCount = 0
local targets = {}

local myTargetCount = 0
local myTargets = {}

local nameplates = {}
local addMissingTargets = true

local npCount = 0
local lastNpCount = 0

local formatKey = ns.formatKey
local FeignEvent = ns.FeignEvent
local RegisterEvent = ns.RegisterEvent


-- New Nameplate Proximity System
function ns.getNumberTargets()
    local showNPs = GetCVar( 'nameplateShowEnemies' ) == "1"

    for k,v in pairs( nameplates ) do
        nameplates[k] = nil
    end

    npCount = 0

    if showNPs and ( Hekili.DB.profile['Count Nameplate Targets'] ) then
        local RC = LibStub( "LibRangeCheck-2.0" )

        for i = 1, 80 do
            local unit = 'nameplate'..i

            local _, maxRange = RC:GetRange( unit )

            if maxRange and maxRange <= ( Hekili.DB.profile['Nameplate Detection Range'] or 5 ) and UnitExists( unit ) and ( not UnitIsDead( unit ) ) and UnitCanAttack( 'player', unit ) and UnitInPhase( unit ) and ( UnitIsPVP( 'player' ) or not UnitIsPlayer( unit ) ) then
                nameplates[ UnitGUID( unit ) ] = maxRange
                npCount = npCount + 1
            end
        end

        for i = 1, 5 do
            local unit = 'boss'..i

            local guid = UnitGUID( unit )

            if not nameplates[ guid ] then
                local maxRange = RC:GetRange( unit )

                if maxRange and maxRange <= ( Hekili.DB.profile['Nameplate Detection Range'] or 5 ) and UnitExists( unit ) and ( not UnitIsDead( unit ) ) and UnitCanAttack( 'player', unit ) and UnitInPhase( unit ) and ( UnitIsPVP( 'player' ) or not UnitIsPlayer( unit ) ) then
                    nameplates[ UnitGUID( unit ) ] = maxRange
                    npCount = npCount + 1
                end
            end
        end
    end

    if Hekili.DB.profile['Count Targets by Damage'] or not Hekili.DB.profile['Count Nameplate Targets'] or not showNPs then
        for k,v in pairs( myTargets ) do
            if not nameplates[ k ] then
                nameplates[ k ] = true
                npCount = npCount + 1
            end
        end
    end

    return npCount
end


function ns.recountTargets()
    lastNpCount = npCount

    npCount = ns.getNumberTargets()

    --[[ if lastNpCount ~= npCount then
        ns.forceUpdate()
    end ]]
end


function ns.dumpNameplateInfo()
    return nameplates
end


ns.updateTarget = function( id, time, mine )

  if time then
    if not targets[ id ] then
      targetCount = targetCount + 1
      targets[id] = time
      ns.updatedTargetCount = true
    else
      targets[id] = time
    end

    if mine then
      if not myTargets[ id ] then
        myTargetCount = myTargetCount + 1
        myTargets[id] = time
      ns.updatedTargetCount = true
      else
        myTargets[id] = time
      end
    end

  else
    if targets[id] then
      targetCount = max(0, targetCount - 1)
      targets[id] = nil
    end

    if myTargets[id] then
      myTargetCount = max(0, myTargetCount - 1)
      myTargets[id] = nil
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

ns.isMinion = function( id ) return minions[ id ] ~= nil end


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
ns.isWatchedDebuff = function( spell ) return debuffs[ spell ] ~= nil end


ns.eliminateUnit = function( id, force )
  ns.updateMinion( id )
  ns.updateTarget( id )

  ns.TTD[ id ] = nil

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


local TTD = ns.TTD

-- Borrowed TTD linear regression model from 'Nemo' by soulwhip (with permission).
ns.initTTD = function( unit )

    if not unit then return end

    local GUID = UnitGUID( unit )

    TTD[ GUID ] = TTD[ GUID ] or {}
    TTD[ GUID ].n = 1
    TTD[ GUID ].timeSum = GetTime()
    TTD[ GUID ].healthSum = UnitHealth( unit ) or 0
    TTD[ GUID ].timeMean = TTD[ GUID ].timeSum * TTD[ GUID ].timeSum
    TTD[ GUID ].healthMean = TTD[ GUID ].timeSum * TTD[ GUID ].healthSum
    TTD[ GUID ].name = UnitName( unit )
    TTD[ GUID ].sec = state.boss and 300 or 15

end


ns.getTTD = function( unit )

  local GUID = UnitGUID( unit ) or unit

  if not TTD[ GUID ] then return 15 end

  return TTD[ GUID ].sec or 15

end


-- Auditor should clean things up for us.
ns.Audit = function ()

  local now = GetTime()
  local grace = Hekili.DB.profile['Audit Targets']

  for aura, targets in pairs( debuffs ) do
    for unit, entry in pairs( targets ) do
      -- NYI: Check for dot vs. debuff, since debuffs won't 'tick'
      local window = class.auras[ aura ] and class.auras[ aura ].duration or grace
      if now - entry.last_seen > window then
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

  if Hekili.DB.profile.Enabled then
    C_Timer.After( 1, ns.Audit )
  end

end