-- State.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]

local auras = ns.auras

local formatKey = ns.formatKey
local ResourceRegenerates = ns.ResourceRegenerates

local Error = ns.Error

local orderedPairs = ns.orderedPairs
local round, roundUp, roundDown = ns.round, ns.roundUp, ns.roundDown
local safeMin, safeMax = ns.safeMin, ns.safeMax

local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetItemSpell = C_Item.GetItemSpell
local GetItemCooldown = C_Item.GetItemCooldown
local IsUsableItem = C_Item.IsUsableItem
local GetSpellInfo, GetSpellCharges, GetSpellLossOfControlCooldown = ns.GetUnpackedSpellInfo, C_Spell.GetSpellCharges, C_Spell.GetSpellLossOfControlCooldown
local UnitBuff, UnitDebuff = ns.UnitBuff, ns.UnitDebuff

local GetSpellCharges = function(spellID)
    local spellChargeInfo = GetSpellCharges(spellID);
    if spellChargeInfo then
        return spellChargeInfo.currentCharges, spellChargeInfo.maxCharges, spellChargeInfo.cooldownStartTime, spellChargeInfo.cooldownDuration, spellChargeInfo.chargeModRate;
    end
end
local FindPlayerAuraByID, IsAbilityDisabled, IsDisabledCovenantSpell = ns.FindPlayerAuraByID, ns.IsAbilityDisabled, ns.IsDisabledCovenantSpell

-- Clean up table_x later.
---@diagnostic disable-next-line: deprecated
local insert, remove, sort, tcopy, unpack, wipe = table.insert, table.remove, table.sort, ns.tableCopy, table.unpack, table.wipe
local format = string.format

local Mark, SuperMark, ClearMarks = ns.Mark, ns.SuperMark, ns.ClearMarks

local RC = LibStub( "LibRangeCheck-3.0" )
local LSR = LibStub( "SpellRange-1.0" )

local class = Hekili.Class
local scripts = Hekili.Scripts

local unknown_buff, unknown_debuff


-- This will be our environment table for local functions.
local state = Hekili.State

local PTR = ns.PTR
state.PTR = PTR
state.ptr = PTR and 1 or 0

state.now = 0
state.offset = 0
state.modified = false
state.resetType = "heavy"

state.encounterID = 0
state.encounterName = "None"
state.encounterDifficulty = 0

state.aggro = false
state.tanking = false

state.delay = 0
state.delayMin = 0
state.delayMax = 15

state.false_start = 0
state.latency = 0

state.filter = "none"
state.cast_target = "nobody"

state.arena = false
state.bg = false

state.mainhand_speed = 0
state.offhand_speed = 0

state.min_targets = 0
state.max_targets = 0

state.action = {}
state.active_dot = {}
state.args = {}
state.azerite = {}
state.essence = {}
state.aura = {}
state.auras = auras
state.buff = {}
state.consumable = {}
state.cooldown = {}

state.empowerment = {
    id = 0,
    spell = "none",
    start = 0,
    finish = 0,
    hold = 0,
    stages = {}
}
state.max_empower = 3
state.empowering = {}

state.health = {
    current = 1,
    max = 1,
    percent = 100,
    timeTo = function( amount )
        if state.health.current >= amount then return 0 end
        return 3600
    end,

    initialized = false
}
state.legendary = {}
state.runeforge = state.legendary -- Different APLs use runeforge.X.equipped vs. legendary.X.enabled.
state.debuff = {}
state.dot = {}
state.equipped = {}
state.main_hand = {
    size = 0
}
state.off_hand = {
    size = 0
}

state.gcd = {}

state.hero_tree = setmetatable( {}, { __index = function( t, k ) return state.talent[ k ].enabled end } ) -- TODO: Update hero tree detection for 11.0 launch.

state.history = {
    casts = {},
    units = {}
}

state.holds = {}

state.items = {}
state.pet = {
    fake_pet = {
        name = "Mary-Kate Olsen",
        expires = 0,
        permanent = false,
    }
}
state.player = {
    lastcast = "none",
    lastgcd = "none",
    lastoffgcd = "none",
    casttime = 0,
    updated = true,
    channeling = false,
    channel_start = 0,
    channel_end = 0,
    channel_spell = nil
}
state.prev = {
    meta = "castsAll",
    history = { "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action" }
}
state.prev_gcd = {
    meta = "castsOn",
    history = { "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action" }
}
state.prev_off_gcd = {
    meta = "castsOff",
    history = { "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action", "no_action" }
}
state.predictions = {}
state.predictionsOff = {}
state.predictionsOn = {}
state.purge = {}
state.pvptalent = {}
state.race = {}
state.script = {}
state.set_bonus = {}
state.settings = {}
state.sim = {}
state.spec = {}
state.stance = {}
state.stat = {}
state.swings = {
    mh_actual = 0,
    mh_speed = UnitAttackSpeed( "player" ) > 0 and UnitAttackSpeed( "player" ) or 2.6,
    mh_projected = 2.6,
    oh_actual = 0,
    oh_speed = select( 2, UnitAttackSpeed( "player" ) ) or 2.6,
    oh_projected = 3.9
}
state.system = {}
state.table = table
state.talent = {}
state.target = {
    debuff = state.debuff,
    dot = state.dot,
    health = {},
    updated = true
}

state.movement = {}

setmetatable( state.movement, {
    __index = function( t, k )
        if k == "distance" then
            if state.buff.movement.up then return state.target.maxR end
            return 0
        end

        return state.target[ k ]
    end
} )

state.sim.target = state.target
state.toggle = {}
state.totem = {}


state.trinket = {
    t1 = {
        slot = "t1",

        --[[ has_cooldown = {
            slot = "t1"
        }, ]]

        stacking_stat = {
            slot = "t1"
        },
        has_stacking_stat = {
            slot = "t1"
        },

        stat = {
            slot = "t1"
        },
        has_stat = {
            slot = "t1"
        },

        is = {
            slot = "t1"
        },
    },

    t2 = {
        slot = "t2",

        --[[ has_cooldown = {
            slot = "t2",
        }, ]]

        stacking_stat = {
            slot = "t2"
        },
        has_stacking_stat = {
            slot = "t2"
        },

        stat = {
            slot = "t2"
        },
        has_stat = {
            slot = "t2",
        },

        is = {
            slot = "t2",
        },
    },

    main_hand = {
        slot = "main_hand",

        --[[ has_cooldown = {
            slot = "main_hand",
        }, ]]

        stacking_stat = {
            slot = "main_hand"
        },
        has_stacking_stat = {
            slot = "main_hand"
        },

        stat = {
            slot = "main_hand"
        },
        has_stat = {
            slot = "main_hand",
        },

        is = {
            slot = "main_hand",
        },
    },
    any = {},

    cooldown = {
    },
    has_cooldown = {
    },

    stacking_stat = {
    },
    has_stacking_stat = {
    },

    stacking_proc = {
    },
    has_stacking_proc = {
    },

    stat = {
    },
    has_stat = {
    },
}
state.trinket.proc = state.trinket.stat
state.trinket[1] = state.trinket.t1
state.trinket[2] = state.trinket.t2

state.using_apl = setmetatable( {}, {
    __index = function( t, k )
        return false
    end
} )


state.role = setmetatable( {}, {
    __index = function( t, k )
        return false
    end
} )

local mt_no_trinket_cooldown = {
}

local mt_no_trinket_stacking_stat = {
}

local mt_no_trinket_stat = {
}


local mt_no_trinket = {
    __index = function( t, k )
        if k:sub(1,4) == "has_" then
            return false
        elseif k == "down" then
            return true
        end

        return false
    end
}

local no_trinket = setmetatable( {
    slot = "none",
    cooldown = setmetatable( {}, mt_no_trinket_cooldown ),
    stacking_stat = setmetatable( {}, mt_no_trinket_stacking_stat ),
    stat = setmetatable( {}, mt_no_trinket_stat ),
    is = setmetatable( {}, {
        __index = function( t, k )
            return false
        end
    } )
}, mt_no_trinket )

setmetatable( state.trinket, {
    __index = function( t, k )
        if t.t1.is[ k ] then
            return t.t1
        elseif t.t2.is[ k ] then
            return t.t2
        else
            return no_trinket
        end
    end
} )

state.trinket.stat.any = state.trinket.any


local mt_trinket_any = {
    __index = function( t, k )
        return state.trinket.t1[ k ] or state.trinket.t2[ k ]
    end
}

setmetatable( state.trinket.any, mt_trinket_any )

local mt_trinket_any_stacking_stat = {
    __index = function( t, k )
        if state.trinket.t1.has_stacking_stat[k] then return state.trinket.t1
            elseif state.trinket.t2.has_stacking_stat[k] then return state.trinket.t2 end
        return no_trinket
    end
}

setmetatable( state.trinket.stacking_stat, mt_trinket_any_stacking_stat )
setmetatable( state.trinket.stacking_proc, mt_trinket_any_stacking_stat )

local mt_trinket_any_stat = {
    __index = function( t, k )
        --[[ if k == "any" then
        return ( state.trinket.has_stat[
    end ]]

        if state.trinket.t1.has_stat[k] then return state.trinket.t1
        elseif state.trinket.t2.has_stat[k] then return state.trinket.t2 end
        return no_trinket
    end
}

setmetatable( state.trinket.stat, mt_trinket_any_stat )


local mt_trinket = {
    __index = function( t, k )
        local isEnabled = ( not rawget( t, "__usable" ) ) or ( rawget( t, "__ability" ) and not state:IsDisabled( t.__ability ) or false )

        if k == "id" then
            return isEnabled and t.__id or 0
        elseif k == "ability" then
            return rawget( t, "__ability" ) or "null_cooldown"
        elseif k == "usable" then
            return rawget( t, "__usable" ) or false
        elseif k == "has_use_buff" or k == "use_buff" then
            return isEnabled and t.__has_use_buff or false
        elseif k == "use_buff_duration" or k == "buff_duration" then
            return isEnabled and t.__has_use_buff and t.__use_buff_duration or 0.01
        elseif k == "has_proc" or k == "proc" then
            return isEnabled and t.__proc or false
        end

        if k == "up" or k == "ticking" or k == "active" then
            return isEnabled and class.trinkets[ t.id ].buff and state.buff[ class.trinkets[ t.id ].buff ].up or false
        elseif k == "react" or k == "stack" or k == "stacks" then
            return isEnabled and class.trinkets[ t.id ].buff and state.buff[ class.trinkets[ t.id ].buff ][ k ] or 0
        elseif k == "remains" then
            return isEnabled and class.trinkets[ t.id ].buff and state.buff[ class.trinkets[ t.id ].buff ].remains or 0
        elseif k == "has_cooldown" then
            return isEnabled and ( GetItemSpell( t.id ) ~= nil ) or false
        elseif k == "ready_cooldown" then
            if isEnabled and t.usable and t.ability then
                return t.cooldown.ready
            end
            return true
        elseif k == "cooldown" then
            if t.usable and t.ability and state.cooldown[ t.ability ] then
                return state.cooldown[ t.ability ]
            end
            return state.cooldown.null_cooldown

        elseif k == "cast_time" or k == "cast_time" then
            return t.usable and t.ability and class.abilities[ t.ability ] and class.abilities[ t.ability ].cast or 0
        end

        return k
    end
}

setmetatable( state.trinket.t1, mt_trinket )
setmetatable( state.trinket.t2, mt_trinket )
setmetatable( state.trinket.main_hand, mt_trinket )


local mt_trinket_is = {
    __index = function( t, k )
        local item = state.trinket[ t.slot ]

        if item.usable and item.ability == k then return true end
        if item.__id and class.gear[ k ] and class.gear[ k ][ 1 ] == item.__id then return true end

        return false
    end,
}

setmetatable( state.trinket.t1.is, mt_trinket_is )
setmetatable( state.trinket.t2.is, mt_trinket_is )
setmetatable( state.trinket.main_hand.is, mt_trinket_is )


--[[ local mt_trinket_cooldown = {
    __index = function(t, k)
        if k == "duration" or k == "expires" then
            -- Refresh the ID in case we changed specs and ability is spec dependent.
            local start, duration = GetItemCooldown( state.trinket[ t.slot ].id )

            t.duration = duration or 0
            t.expires = start and ( start + duration ) or 0

            return t[k]

        elseif k == "remains" then
            return max( 0, t.expires - ( state.query_time ) )

        elseif k == "up" then
            return t.remains == 0

        elseif k == "down" then
            return t.remains > 0

        end

        -- return Error( "UNK: " .. k )

    end
}

setmetatable( state.trinket.t1.cooldown, mt_trinket_cooldown )
setmetatable( state.trinket.t2.cooldown, mt_trinket_cooldown ) ]]

local mt_trinket_has_stacking_stat = {
    __index = function( t, k )
        local trinket = state.trinket[ t.slot ]
        trinket = trinket and trinket.__ability
        trinket = trinket and class.abilities[ trinket ]

        if not trinket then return false end

        local buff = trinket.self_buff
        buff = buff and class.auras[ buff ]

        if not buff or buff.max_stack == 1 then return false end

        if k == "any" then return true end

        local proc = trinket.proc or "none"
        if not proc then return false end

        if k == "any_dps" then return not ( proc == "damage" or proc == "healing" or proc == "health" or proc == "absorb" or proc == "mana" or proc == "speed" or proc == "leech" or proc == "avoidance" ) end
        return proc == k
    end
}

setmetatable( state.trinket.t1.has_stacking_stat, mt_trinket_has_stacking_stat )
setmetatable( state.trinket.t2.has_stacking_stat, mt_trinket_has_stacking_stat )
setmetatable( state.trinket.main_hand.has_stacking_stat, mt_trinket_has_stacking_stat )


local mt_trinket_has_stat = {
    __index = function( t, k )
        local trinket = state.trinket[ t.slot ]
        trinket = trinket and trinket.__ability
        trinket = trinket and class.abilities[ trinket ]

        if not trinket then
            return false
        end

        local buff = trinket.self_buff
        buff = buff and class.auras[ buff ]

        if not buff then
            return false
        end

        if k == "any" then return true end

        local proc = trinket.proc or "none"
        if not proc then
            return false
        end

        if k == "any_dps" then return not ( proc == "damage" or proc == "healing" or proc == "absorb" or proc == "mana" or proc == "speed" or proc == "leech" or proc == "avoidance" ) end
        return proc == k
    end
}

setmetatable( state.trinket.t1.has_stat, mt_trinket_has_stat )
setmetatable( state.trinket.t2.has_stat, mt_trinket_has_stat )
setmetatable( state.trinket.main_hand.has_stat, mt_trinket_has_stat )


local mt_trinkets_has_stat = {
    __index = function( t, k )
        return state.trinket.t1.has_stat[ k ] or state.trinket.t2.has_stat[ k ]
    end
}

setmetatable( state.trinket.has_stat, mt_trinkets_has_stat )


local mt_trinkets_has_stacking_stat = {
    __index = function( t, k )
        return state.trinket.t1.has_stacking_stat[ k ] or state.trinket.t2.has_stacking_stat[ k ]
    end
}

setmetatable( state.trinket.has_stacking_stat, mt_trinkets_has_stacking_stat )


state.max = safeMax
state.min = safeMin
state.abs = safeAbs

if Hekili.Version:match( "^Dev" ) then
    state.print = print
else
    state.print = function() end
end

state.Enum = Enum
state.FindPlayerAuraByID = ns.FindPlayerAuraByID
state.FindUnitBuffByID = ns.FindUnitBuffByID
state.FindUnitDebuffByID = ns.FindUnitDebuffByID
state.FindRaidBuffByID = ns.FindRaidBuffByID
state.FindRaidBuffLowestRemainsByID = ns.FindRaidBuffLowestRemainsByID
state.FindLowHpPlayerWithoutBuffByID = ns.FindLowHpPlayerWithoutBuffByID
state.GetActiveLossOfControlData = C_LossOfControl.GetActiveLossOfControlData
state.GetActiveLossOfControlDataCount = C_LossOfControl.GetActiveLossOfControlDataCount
state.GetNumGroupMembers = GetNumGroupMembers
-- state.GetItemCooldown = GetItemCooldown
state.GetItemCount = C_Item.GetItemCount
state.GetItemGem = GetItemGem
state.GetItemInfo = GetItemInfo
state.GetPlayerAuraBySpellID = GetPlayerAuraBySpellID
state.GetShapeshiftForm = GetShapeshiftForm
state.GetShapeshiftFormInfo = GetShapeshiftFormInfo
state.GetSpellCount = C_Spell.GetSpellCastCount
state.GetSpellInfo = ns.GetUnpackedSpellInfo
state.GetSpellLink = GetSpellLink
state.GetSpellTexture = C_Spell.GetSpellTexture
state.GetStablePetInfo = GetStablePetInfo
state.GetTime = GetTime
state.GetTotemInfo = GetTotemInfo
state.InCombatLockdown = InCombatLockdown
state.IsActiveSpell = ns.IsActiveSpell
state.IsPlayerSpell = IsPlayerSpell
state.IsSpellKnown = IsSpellKnown
state.IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
state.IsUsableItem = C_Item.IsUsableItem
state.IsUsableSpell = C_Spell.IsSpellUsable
state.UnitAura = UnitAura
state.UnitAuraSlots = C_UnitAuras.GetAuraSlots
state.UnitBuff = UnitBuff
state.UnitCanAttack = UnitCanAttack
state.UnitCastingInfo = UnitCastingInfo
state.UnitChannelInfo = UnitChannelInfo
state.UnitClassification = UnitClassification
state.UnitDebuff = UnitDebuff
state.UnitExists = UnitExists
state.UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
state.UnitGUID = UnitGUID
state.UnitHealth = UnitHealth
state.UnitHealthMax = UnitHealthMax
state.UnitName = UnitName
state.UnitIsFriend = UnitIsFriend

local UnitIsUnit = _G.UnitIsUnit

state.UnitIsUnit = function( a, b )
    return a == b or UnitIsUnit( a, b )
end

state.UnitIsPlayer = UnitIsPlayer
state.UnitLevel = UnitLevel
state.UnitPower = UnitPower
state.UnitPartialPower = UnitPartialPower
state.UnitPowerMax = UnitPowerMax
state.abs = math.abs
state.ceil = math.ceil
state.floor = math.floor
state.format = string.format
state.ipairs = ipairs
state.pairs = pairs
state.rawget = rawget
state.rawset = rawset
state.select = select
state.tinsert = table.insert
state.insert = table.insert
state.remove = table.remove
state.tonumber = tonumber
state.tostring = tostring
state.type = type

state.safenum = function( val )
    if type( val ) == "number" then return val end
    return val == true and 1 or 0
end

state.safebool = function( val )
    if type( val ) == "boolean" then return val end
    if val == nil then return false end
    if val == 0 then return false end
    return true
end

state.combat = 0
state.faction = UnitFactionGroup( "player" )
state.race[ formatKey( UnitRace("player") ) ] = true

state.class = Hekili.Class
state.targets = ns.targets

state._G = 0


-- Place an ability on cooldown in the simulated game state.
local function setCooldown( action, duration )
    local cd = state.cooldown[ action ] or {}
    cd.duration = duration > 0 and duration or cd.duration
    cd.expires = state.query_time + duration

    cd.charge = 0
    cd.recharge_began = state.query_time
    cd.next_charge = cd.expires
    cd.recharge = duration > 0 and duration or cd.recharge

    state.cooldown[ action ] = cd
end
state.setCooldown = setCooldown


local function spendCharges( action, charges )
    local ability = class.abilities[ action ]

    if not ability.charges or ability.charges == 1 then
        setCooldown( action, ability.cooldown )
        return
    end

    if not state.cooldown[ action ] then state.cooldown[ action ] = {} end
    local cd = state.cooldown[ action ]

    if cd.next_charge <= state.query_time then
        cd.recharge_began = state.query_time
        cd.next_charge = state.query_time + ( ability.recharge or ability.cooldown )
        cd.recharge = ability.recharge > 0 and ability.recharge or cd.recharge
    end

    cd.charge = max( 0, cd.charge - charges )

    local dur = ability.recharge or ability.cooldown
    cd.duration = dur > 0 and dur or cd.duration
    cd.expires = cd.charge == 0 and cd.next_charge or 0
end
state.spendCharges = spendCharges


local function gainCharges( action, charges )

    if class.abilities[ action ].charges then
        state.cooldown[ action ].charge = min( class.abilities[ action ].charges, state.cooldown[ action ].charge + charges )

        -- resolve cooldown state.
        if state.cooldown[ action ].charge > 0 then
            -- state.cooldown[ action ].duration = 0
            state.cooldown[ action ].expires = 0
        end

        if state.cooldown[ action ].charge == class.abilities[ action ].charges then
            state.cooldown[ action ].next_charge = 0
            -- state.cooldown[ action ].recharge = 0
            state.cooldown[ action ].recharge_began = 0
        end

    else
        -- Error-proof gaining charges for abilities without charges.
        if charges >= 1 then
            setCooldown( action, 0 )
        end
    end

end
state.gainCharges = gainCharges


function state.gainChargeTime( action, time, debug )
    local ability = class.abilities[ action ]
    if not ability then return end

    local cooldown = state.cooldown[ action ]

    if not ability.charges then
        -- Error-proof gaining charge time on chargeless abilities.
        cooldown.expires = cooldown.expires - time
        return
    end

    if cooldown.charge == ability.charges then return end

    cooldown.next_charge = cooldown.next_charge - time
    cooldown.recharge_began = cooldown.recharge_began - time

    if cooldown.expires > 0 then cooldown.expires = max( 0, cooldown.expires - time ) end

    if cooldown.next_charge <= state.query_time then
        cooldown.charge = min( ability.charges, cooldown.charge + 1 )

        -- We have a charge, reset cooldown.
        -- cooldown.duration = 0
        cooldown.expires = 0

        if cooldown.charge == ability.charges then
            cooldown.next_charge = 0
            -- cooldown.recharge = 0
            cooldown.recharge_began = 0
        else
            cooldown.recharge_began = cooldown.next_charge
            cooldown.next_charge = cooldown.next_charge + ability.recharge
            -- cooldown.recharge = ability.recharge
        end
    end
end


function state.reduceCooldown( action, time )
    local ability = class.abilities[ action ]
    if not ability then return end

    if ability.charges then
        state.gainChargeTime( action, time )
        return
    end

    state.cooldown[ action ].expires = max( 0, state.cooldown[ action ].expires - time )
end


-- Cycling System...
do
    local cycle = {}
    local debug = function( ... ) if Hekili.ActiveDebug then Hekili:Debug( ... ) end end

    function state.SetupCycle( ability, quiet )
        wipe( cycle )

        if not ability and not quiet then
            debug( " - no ability provided to SetupCycle." )
            return
        end

        local aura = ability.cycle

        if not aura then
            -- Fallback check, is there an aura with the same name as the ability?
            aura = class.auras[ ability.key ] and ability.key
        end

        if not aura and not quiet then
            debug( " - no aura identified for target-cycling and no aura matching " .. ability.key .. " found in ability / spec module; target cycling disabled." )
            return
        end

        local cDebuff = class.auras[ aura ] and state.debuff[ aura ]

        if not cDebuff then
            debug( " - the debuff '%s' was not found in our database.", aura )
            return
        end

        if cDebuff.up and not ability.cycle_to then
            -- We want to target enemies with this debuff.
            cycle.expires = cDebuff.expires
            cycle.minTTD  = max( state.settings.cycle_min, ability.min_ttd or 0, cDebuff.duration / 2 )
            cycle.maxTTD  = ability.max_ttd

            cycle.aura = aura

            if state.active_dot[ aura ] >= state.cycle_enemies then
                if not quiet then debug( " - we do not have another valid target for " .. aura .. ": " .. state.active_dot[ aura ] .. " vs " .. state.cycle_enemies .. "." ) end
                state.ClearCycle()
                return
            end

            if not quiet then
                debug( " - we will use the ability on a different target, if available, until %s expires at %.2f [+%.2f].", cycle.aura, cycle.expires, cycle.expires - state.query_time )
            end
        elseif cDebuff.down and ability.cycle_to and state.active_dot[ aura ] > 0 and state.query_time < state.now + ( 2 * state.gcd.max ) then
            cycle.expires = state.query_time + ( 2 * state.gcd.max ) -- Assume the aura is available for 2 GCDs (don't forecast a slow target swap).
            cycle.minTTD  = max( state.settings.cycle_min, ability.min_ttd or 0, cDebuff.duration / 2 )
            cycle.maxTTD  = ability.max_ttd

            cycle.aura = aura

            if not quiet then
                debug( " - we will use the ability on a target with %s, if available, .", cycle.aura )
            end
        else
            if not quiet then debug( " - cycle aura appears to be down, so we're sticking with our current target." ) end
        end

        --[[ Possible future version:
            local debuffIsUp = cDebuff.up

            cycle.expires = cDebuff.duration + state.query_time

            cycle.minTTD  = max( state.settings.cycle_min, ability.min_ttd or 0, cDebuff.duration / 2 )
            cycle.maxTTD  = ability.max_ttd
            cycle.aura = aura

            if debuffIsUp and not ability.cycle_to and state.active_dot[ aura ] >= state.cycle_enemies then
                debug( " - we will not use the ability on a different target, as we have enough targets with %s.", cycle.aura )
                state.ClearCycle()
                return
            end

            if not debuffIsUp and not ability.cycle_to then
                debug( " - we will not use the ability on a different target, as current target does not have %s.", cycle.aura )
                state.ClearCycle()
                return
            end

            if not debuffIsUp and ability.cycle_to and active_dot[ aura ] == 0 then
                debug( " - we will not use the ability on a different target, as no other target has %s applied.", cycle.aura)
                state.ClearCycle()
                return
            end
        ]]
    end

    function state.GetCycleInfo()
        return cycle.expires, cycle.minTTD, cycle.maxTTD, cycle.aura
    end

    function state.SetCycleInfo( expires, minTTD, maxTTD, aura )
        cycle.expires = expires
        cycle.minTTD  = minTTD
        cycle.maxTTD  = maxTTD
        cycle.aura    = aura
    end

    function state.HasCyclingDebuff( aura )
        if not cycle.aura then return false end
        if aura and aura ~= cycle.aura then return false end
        return true
    end

    function state.IsCycling( aura, quiet )
        if not cycle.aura then
            return false, "cycle.aura is nil"
        end
        if aura and cycle.aura ~= aura then
            if not quiet then debug( "cycle.aura ~= '%s'", aura ) end
            return false, format( "cycle aura (%s) is not '%s'", cycle.aura or "none", aura )
        end
        if state.cycle_enemies == 1 then
            return false, "cycle_enemies == 1"
        end
        if cycle.expires < state.query_time then
            return false, format( "cycle aura (%s) expires before current time", cycle.aura )
        end
        if state.active_dot[ cycle.aura ] >= state.cycle_enemies then
            return false, format( "active_dot[%d] >= cycle_enemies[%d]", state.active_dot[ cycle.aura ], state.cycle_enemies )
        end

        return true
    end

    function state.ClearCycle()
        if cycle.aura then wipe( cycle ) end
        state.cycle = nil
    end

    state.cycleInfo = cycle
end


-- Apply a buff to the current game state.
local function applyBuff( aura, duration, stacks, value, v2, v3, applied )
    if not aura then
        Error( "Attempted to apply/remove a nameless aura '%s'.\n\n%s", aura or "nil", debugstack() )
        return
    end

    local auraInfo = class.auras[ aura ]

    if not auraInfo then
        local spec = class.specs[ state.spec.id ]
        if spec then
            spec:RegisterAura( aura, { ["duration"] = duration } )
            class.auras[ aura ] = spec.auras[ aura ]
        end

        auraInfo = class.auras[ aura ]
        if not auraInfo then return end
    end

    if auraInfo.alias then
        aura = auraInfo.alias[1]
    end

    if state.cycle then
        if duration == 0 then state.active_dot[ aura ] = max( 0, state.active_dot[ aura ] - 1 )
        else state.active_dot[ aura ] = max( state.active_enemies, state.active_dot[ aura ] + 1 ) end
        return
    end

    local b = state.buff[ aura ]
    if not b then return end

    duration = duration or auraInfo.duration or 15

    if duration == 0 then
        b.last_expiry = b.expires or 0
        b.expires = 0

        b.lastCount = b.count
        b.count = 0

        b.lastApplied = b.applied
        b.last_application = b.applied or 0

        b.v1 = value or 0
        b.v2 = 0
        b.v3 = 0
        b.applied = 0
        b.caster = "unknown"

        state.active_dot[ aura ] = max( 0, state.active_dot[ aura ] - 1 )

        if auraInfo.funcs.onRemove then auraInfo.funcs.onRemove() end

    else
        if not b.up then state.active_dot[ aura ] = state.active_dot[ aura ] + 1 end

        b.lastCount = b.count
        b.lastApplied = b.applied

        b.applied = applied or state.query_time
        b.last_application = b.applied or 0

        -- b.duration = duration

        b.expires = b.applied + duration
        b.last_expiry = b.expires

        b.count = max( 0, min( class.auras[ aura ].max_stack or 1, stacks or 1 ) )
        b.v1 = value or 0
        if v2 == nil then b.v2 = 0
        else b.v2 = v2 end
        if v3 == nil then b.v3 = 0
        else b.v3 = v3 end
        b.caster = "player"
    end

    for resource, auras in pairs( class.resourceAuras ) do
        if auras[ aura ] then
            state.forecastResources( resource )
        end
    end

    if aura ~= "potion" and class.auras.potion and class.auras[ aura ].id == class.auras.potion.id then
        applyBuff( "potion", duration, stacks, value )
    end
end
state.applyBuff = applyBuff


local function removeBuff( aura )
    local auraInfo = class.auras[ aura ]
    if auraInfo and auraInfo.alias then
        for _, child in ipairs( auraInfo.alias ) do
            applyBuff( child, 0 )
        end
    else
        applyBuff( aura, 0 )
    end
end
state.removeBuff = removeBuff


-- Apply stacks of a buff to the current game state.
-- Wraps around Buff() to check for an existing buff.
local function addStack( aura, duration, stacks, value )

    local a = class.auras[ aura ]

    duration = duration or ( a and a.duration or 15 )
    stacks = stacks or 1

    local max_stack = a and a.max_stack or 1

    local b = state.buff[ aura ]

    if b.remains > 0 then
        applyBuff( aura, duration, min( max_stack, b.count + stacks ), value )
    else
        applyBuff( aura, duration, min( max_stack, stacks ), value )
    end

end
state.addStack = addStack


local function removeStack( aura, stacks )
    stacks = stacks or 1

    local b = state.buff[ aura ]

    if b.count > stacks then
        b.lastCount = b.count
        b.count = max( 1, b.count - stacks )
    else
        state.removeBuff( aura )
    end
end
state.removeStack = removeStack


-- Add a debuff to the simulated game state.
-- Needs to actually use "unit" !
local function applyDebuff( unit, aura, duration, stacks, value, noPandemic )
    if not aura then aura = unit; unit = "target" end

    if not class.auras[ aura ] then
        Error( "Attempted to apply unknown aura '%s'.", aura )
        local spec = class.specs[ state.spec.id ]
        if spec then
            spec:RegisterAura( aura, { ["duration"] = duration } )
            class.auras[ aura ] = spec.auras[ aura ]
        end

        if not class.auras[ aura ] then return end
    end

    if state.cycle then
        if duration == 0 then
            if Hekili.ActiveDebug then Hekili:Debug( "Removed an application of '%s' while target-cycling.", aura ) end
            state.active_dot[ aura ] = state.active_dot[ aura ] - 1
        else
            if Hekili.ActiveDebug then Hekili:Debug( "Added an application of '%s' while target-cycling.", aura ) end
            state.active_dot[ aura ] = state.active_dot[ aura ] + 1
        end
        return
    end

    local d = state.debuff[ aura ]
    duration = duration or class.auras[ aura ].duration or 15

    if duration == 0 then
        d.expires = 0

        d.lastCount = d.count
        d.lastApplied = d.lastApplied

        d.count = 0
        d.value = 0
        d.applied = 0
        d.unit = unit

        state.active_dot[ aura ] = max( 0, state.active_dot[ aura ] - 1 )
    else
        if d.down or state.active_dot[ aura ] == 0 then
            state.active_dot[ aura ] = state.active_dot[ aura ] + 1
            -- TODO: Aura scraping utility may want to populate active_dot table when it sees an aura that wasn't tracked.
        end

        -- state.debuff[ aura ] = state.debuff[ aura ] or {}
        if not noPandemic then duration = min( 1.3 * duration, d.remains + duration ) end

        -- d.duration = duration
        d.expires = state.query_time + duration

        d.lastCount = d.count or 0
        d.lastApplied = d.applied or 0

        d.count = min( class.auras[ aura ].max_stack or 1, stacks or 1 )
        d.value = value or 0
        d.applied = state.query_time
        d.unit = unit or "target"
    end

end
state.applyDebuff = applyDebuff


local function removeDebuff( unit, aura )
    applyDebuff( unit, aura, 0 )
end
state.removeDebuff = removeDebuff


local function removeDebuffStack( unit, aura, stacks )
    stacks = stacks or 1

    local d = state.debuff[ aura ]

    if not d then return end

    if d.count > stacks then
        d.lastCount = d.count
        d.count = max( 1, d.count - stacks )
    else
        removeDebuff( unit, aura )
    end
end
state.removeDebuffStack = removeDebuffStack


local function setStance( stance )
    for k in pairs( state.stance ) do
        state.stance[ k ] = false
    end
    state.stance[ stance ] = true
end
state.setStance = setStance


local function interrupt()
    state.removeDebuff( "target", "casting" )
end
state.interrupt = interrupt


-- Use this for readyTime in an interrupt action; will interrupt casts at end of cast and channels ASAP.
local function timeToInterrupt()
    local casting = state.debuff.casting
    if casting.down or casting.v2 == 1 then return 3600 end
    if casting.v3 == 1 then return 0 end
    return max( 0, casting.remains - 0.25 )
end
state.timeToInterrupt = timeToInterrupt


-- Pet stuff.
local function summonPet( name, duration, spec )
    state.pet[ name ] = rawget( state.pet, name ) or {}
    state.pet[ name ].name = name
    state.pet[ name ].expires = state.query_time + ( duration or 3600 )

    local model = class.pets[ name ]

    if model then
        state.pet[ name ].id = type( model.id ) == "function" and model.id() or id
        if ( type( model.duration ) == "function" and model.duration() or model.duration ) == 3600 then
            state.pet.alive = true
        end
    end

    if spec then
        state.pet[ name ].spec = spec

        for k, v in pairs( state.pet ) do
            if type(v) == "boolean" then state.pet[k] = false end
        end

        state.pet[ spec ] = state.pet[ name ]
    end
end
state.summonPet = summonPet


local function dismissPet( name )
    local pet = rawget( state.pet, name ) or {}
    pet.name = name
    pet.expires = 0
    if pet.spec then
        rawset( state.pet, pet.spec, nil )
    end
    state.pet[ name ] = pet
end
state.dismissPet = dismissPet


local function summonTotem( name, elem, duration )

    if elem then
        state.totem[ elem ] = rawget( state.totem, elem ) or {}
        state.totem[ elem ].name = name
        state.totem[ elem ].expires = state.query_time + duration
        summonPet( elem, duration )
    end

    summonPet( name, duration )
end
state.summonTotem = summonTotem


-- Useful for things like leap/charge/etc.
local function setDistance( minimum, maximum )
    state.target.minR = minimum or 5
    state.target.maxR = maximum or minimum or 5
    state.target.distance = ( state.target.minR + state.target.maxR ) / 2
end
state.setDistance = setDistance


-- For tracking if we are currently channeling.
function state.channelSpell( name, start, duration, id )
    if name then
        local ability = class.abilities[ name ]

        start = start or state.query_time

        if ability then
            duration = duration or ability.cast
        end

        if not duration or duration == 0 then return end

        applyBuff( "casting", duration, nil, id or ( ability and ability.id ) or 0, nil, 1, start )
    end
end

function state.stopChanneling( reset, action )
    if not reset then
        local spell = state.channel
        local ability = spell and class.abilities[ spell ]

        if spell then
            if Hekili.ActiveDebug then Hekili:Debug( "Breaking channel of %s.", spell ) end
            if ability and ability.breakchannel then ability.breakchannel() end
            state:RemoveSpellEvents( spell )
            state.removeBuff( "casting" )
        end
    end

    -- This will lock in gains from channeling before the channel ends.
    for resource, auras in pairs( class.resourceAuras ) do
        if auras.casting then state[ resource ].actual = state[ resource ].current end
    end

    removeBuff( "casting" )
end
-- See mt_state for 'isChanneling'.


-- Spell Targets, so I don't have to convert it in APLs any more.
-- This will also factor in target caps and TTD restrictions.
state.spell_targets = setmetatable( {}, {
    __index = function( t, k )
        if state.active_enemies == 1 then return 1 end
        if k == "any" then return state.active_enemies end

        local ability = class.abilities[ k ]
        if not ability then return state.active_enemies end

        local n = state.active_enemies
        if ability.max_ttd then n = min( n, Hekili:GetNumTTDsBefore( ability.max_ttd + state.offset + state.delay ) ) end
        if ability.min_ttd then n = min( n, Hekili:GetNumTTDsAfter( ability.min_ttd + state.offset + state.delay ) ) end
        if ability.max_targets then n = min( n, ability.max_targets ) end

        return n
    end
} )


local raid_event_filter = {
    ["in"] = 3600,
    amount = 0,
    duration = 0,
    remains = 0,
    cooldown = 0,
    exists = false,
    distance = 0,
    max_distance = 0,
    min_distance = 0,
    to_pct = 0,
    up = false,
    down = true
}

state.raid_event = setmetatable( {}, {
    __index = function( t, k )
        return raid_event_filter[ k ] or raid_event_filter
    end
} )


-- We'll pretend we're in an active raid_event.adds when there are multiple targets.
state.raid_event.adds = setmetatable( {
    ["in"] = 3600, -- raid_event.adds.in appears to return time to the next add event, so we can just always say it's waaaay in the future.
}, {
    __index = function( t, k )
        if k == "up" or k == "exists" then
            return state.active_enemies > 1
        elseif k == "down" then
            return state.active_enemies <= 1
        elseif k == "count" then
            return max( 0, state.active_enemies - 1 )
        elseif k == "in" then
            return state.active_enemies > 1 and 0 or 3600
        elseif k == "duration" or k == "remains" then
            return state.active_enemies > 1 and state.fight_remains or 0
        elseif raid_event_filter[k] ~= nil then return raid_event_filter[k] end

        return 0
    end
} )


-- Resource Modeling!
local forecastResources

do
    local events = {}
    local remains = {}

    local function resourceModelSort( a, b )
        return b == nil or ( a.next < b.next )
    end


    -- Increase max forecast duration because Assassination is pooling hard this tier.
    local FORECAST_DURATION = 10.01

    forecastResources = function( resource )

        if not resource then return end

        wipe( events )
        wipe( remains )

        local now = state.now + state.offset -- roundDown( state.now + state.offset, 2 )

        local timeout = FORECAST_DURATION * state.haste -- roundDown( FORECAST_DURATION * state.haste, 2 )

        if state.class.file == "DEATHKNIGHT" and state.runes then
            timeout = max( timeout, 0.01 + 2 * state.runes.cooldown )
        elseif state.spec.assassination then
            timeout = 15.01
        end

        timeout = timeout + state.gcd.remains

        local r = state[ resource ]

        -- We account for haste here so that we don't compute lots of extraneous future resource gains in Bloodlust/high haste situations.
        remains[ resource ] = timeout

        wipe( r.times )
        wipe( r.values )
        r.forecast[1] = r.forecast[1] or {}
        r.forecast[1].t = now
        r.forecast[1].v = r.actual
        r.forecast[1].e = "actual"
        r.fcount = 1

        local models = r.regenModel

        if models then
            for k, v in pairs( models ) do
                if  ( not v.resource  or v.resource == resource ) and
                    ( not v.spec      or state.spec[ v.spec ] ) and
                    ( not v.equip     or state.equipped[ v.equip ] ) and
                    ( not v.talent    or state.talent[ v.talent ].enabled ) and
                    ( not v.pvptalent or state.pvptalent[ v.pvptalent ].enabled ) and
                    ( not v.aura      or state[ v.debuff and "debuff" or "buff" ][ v.aura ].remains > 0 ) and
                    ( not v.set_bonus or state.set_bonus[ v.set_bonus ] > 0 ) and
                    ( not v.setting   or state.settings[ v.setting ] ) and
                    ( not v.swing     or state.swings[ v.swing .. "_speed" ] and state.swings[ v.swing .. "_speed" ] > 0 ) and
                    ( not v.channel   or state.buff.casting.up and state.buff.casting.v3 == 1 and state.buff.casting.v1 == class.abilities[ v.channel ].id ) then

                    local l = v.last()
                    local i = type( v.interval ) == "number" and v.interval or ( type( v.interval ) == "function" and v.interval( now, r.actual ) or ( type( v.interval ) == "string" and state[ v.interval ] or 0 ) )
                    -- local i = roundDown( type( v.interval ) == "number" and v.interval or ( type( v.interval ) == "function" and v.interval( now, r.actual ) or ( type( v.interval ) == "string" and state[ v.interval ] or 0 ) ), 2 )

                    v.next = l + i
                    v.name = k

                    if i > 0 and v.next >= 0 then
                        table.insert( events, v )
                    end
                end
            end
        end

        sort( events, resourceModelSort )

        local finish = now + timeout

        local prev = now
        local iter = 0
        local regen = r.regen > 0.001 and r.regen or 0

        while( #events > 0 and now <= finish and iter < 20 ) do
            local e = events[1]

            iter = iter + 1

            if e.next > finish or not r or not r.actual then
                table.remove( events, 1 )

            else
                now = e.next

                local bonus = regen * ( now - prev )

                local stop = e.stop and e.stop( r.forecast[ r.fcount ].v )
                local aura = e.aura and state[ e.debuff and "debuff" or "buff" ][ e.aura ].expires < now
                local channel = ( e.channel and state.buff.casting.expires < now )

                if stop or aura or channel then
                    table.remove( events, 1 )

                    local v = max( 0, min( r.max, r.forecast[ r.fcount ].v + bonus ) )
                    local idx

                    if r.forecast[ r.fcount ].t == now then
                        -- Reuse the last one.
                        idx = r.fcount
                    else
                        idx = r.fcount + 1
                    end

                    r.forecast[ idx ] = r.forecast[ idx ] or {}
                    r.forecast[ idx ].t = now
                    r.forecast[ idx ].v = v
                    r.forecast[ idx ].e = ( e.name or "none" ) .. ( stop and "-stop" or aura and "-aura" or channel and "-channel" or "-unknown" )
                    r.fcount = idx
                else
                    prev = now

                    local val = r.fcount > 0 and r.forecast[ r.fcount ].v or r.actual

                    local v = max( 0, min( r.max, val + bonus ) )
                    v = max( 0, min( r.max, v + ( type( e.value ) == "number" and e.value or e.value( now ) ) ) )

                    local idx

                    if r.forecast[ r.fcount ].t == now then
                        -- Reuse the last one.
                        idx = r.fcount
                    else
                        idx = r.fcount + 1
                    end

                    r.forecast[ idx ] = r.forecast[ idx ] or {}
                    r.forecast[ idx ].t = now
                    r.forecast[ idx ].v = v
                    r.forecast[ idx ].e = e.name or "none"
                    r.fcount = idx

                    -- interval() takes the last tick and the current value to remember the next step.
                    local step = roundDown( type( e.interval ) == "number" and e.interval or ( type( e.interval ) == "function" and e.interval( now, v ) or ( type( e.interval ) == "string" and state[ e.interval ] or 0 ) ), 3 )

                    remains[ e.resource ] = finish - e.next
                    e.next = e.next + step

                    if e.next > finish or step < 0 or ( e.aura and state[ e.debuff and "debuff" or "buff" ][ e.aura ].expires < e.next ) or ( e.channel and state.buff.casting.expires < e.next ) then
                        table.remove( events, 1 )
                    end
                end
            end

            if #events > 1 then sort( events, resourceModelSort ) end
        end

        if regen > 0 and r.forecast[ r.fcount ].v < r.max then
            for k, v in pairs( remains ) do
                local val = r.fcount > 0 and r.forecast[ r.fcount ].v or r.actual
                local idx = r.fcount + 1

                r.forecast[ idx ] = r.forecast[ idx ] or {}
                r.forecast[ idx ].t = finish
                r.forecast[ idx ].v = min( r.max, val + ( v * regen ) )
                r.fcount = idx
            end
        end
    end
    ns.forecastResources = forecastResources
    state.forecastResources = forecastResources
    Hekili:ProfileCPU( "forecastResources", forecastResources )
end


function state:ForecastSwingbasedResources()
    for k, v in pairs( class.resources ) do
        if v and v.state and v.state.swingGen then
            forecastResources( k )
        end
    end
end


local resourceChange = function( amount, resource, overcap )
    if amount == 0 then return false end

    local r = state[ resource ]
    local pre = r.current

    if amount < 0 and r.spend then r.spend( -amount, resource, overcap )
    elseif amount > 0 and r.gain then r.gain( amount, resource, overcap )
    else
        r.actual = max( 0, r.current + amount )
        if not overcap then r.actual = min( r.max, r.actual ) end
    end

    return true
end


-- Noteworthy hooks for gain/spend:
-- pregain - the hook is expected to return modified values for the resource (i.e., special cost reduction or refunds).
-- gain    - the hook can do whatever it wants, but if it changes the same resource again it will cause another forecast.

local gain = function( amount, resource, overcap, noforecast )
    amount, resource, overcap = ns.callHook( "pregain", amount, resource, overcap )
    resourceChange( amount, resource, overcap )
    if not noforecast and resource ~= "health" then forecastResources( resource ) end
    ns.callHook( "gain", amount, resource, overcap )
end

local rawGain = function( amount, resource, overcap )
    resourceChange( amount, resource, overcap )
    forecastResources( resource )
end


local spend = function( amount, resource, noforecast )
    amount, resource = ns.callHook( "prespend", amount, resource )
    resourceChange( -amount, resource, overcap )
    if not noforecast and resource ~= "health" then forecastResources( resource ) end
    ns.callHook( "spend", amount, resource, overcap, true )
end

local rawSpend = function( amount, resource )
    resourceChange( -amount, resource, overcap )
    forecastResources( resource )
end


state.gain = gain
state.rawGain = rawGain

state.spend = spend
state.rawSpend = rawSpend


do
    -- Rechecking System
    -- Setup on a per-ability basis, this gives the prediction engine a head's up that the ability may become ready in a short time.

    local workTable = {}
    state.recheckTimes = {}

    local function recheckHelper( t, ... )
        local n = select( "#", ... )

        for i = 1, n do
            local x = select( i, ... )
            if type( x ) == "number" then
                if x > 0 and x >= state.delayMin and x <= state.delayMax then
                    t[ x ] = true
                -- elseif x < 60 then
                --     if Hekili.ActiveDebug then Hekili:Debug( "Excluded %.2f recheck time as it is outside our constraints ( %.2f - %.2f ).", x, state.delayMin or -1, state.delayMax or -1 ) end
                end
            end
        end
    end


    local function channelInfo( ability )
        if state.system.packName and scripts.Channels[ state.system.packName ] then
            return scripts.Channels[ state.system.packName ][ state.channel ], class.auras[ state.channel ]
        end
    end


    function state.recheck( ability, script, stack, block )
        local times = state.recheckTimes
        wipe( workTable )

        -- local debug = Hekili.ActiveDebug
        -- local steps = {}

        if script then
            if script.Recheck then
                recheckHelper( workTable, script.Recheck() )
            end

            -- This can be CPU intensive but is needed for some APLs (i.e., Unholy).
            if script.Variables then
                -- if Hekili.ActiveDebug then table.insert( steps, debugprofilestop() ) end
                for i, var in ipairs( script.Variables ) do
                    local varIDs = state:GetVariableIDs( var )

                    if varIDs then
                        for _, entry in ipairs( varIDs ) do
                            local vr = scripts.DB[ entry.id ].VarRecheck
                            if vr then
                                recheckHelper( workTable, vr() )
                            end
                        end
                    end
                    -- if Hekili.ActiveDebug then table.insert( steps, debugprofilestop() ) end
                end
            end
        end

        -- if Hekili.ActiveDebug then table.insert( steps, debugprofilestop() ) end

        local data = class.abilities[ ability ]
        if data and data.aura then
            local a = state.buff[ data.aura ]
            if a and a.up then
                recheckHelper( workTable, a.remains )
            end

            a = state.debuff[ data.aura ]
            if a and a.up then
                recheckHelper( workTable, a.remains )
            end
        end

        -- if Hekili.ActiveDebug then table.insert( steps, debugprofilestop() ) end

        if stack and #stack > 0 then
            for i, caller in ipairs( stack ) do
                local callScript = caller.script
                callScript = callScript and scripts:GetScript( callScript )

                if callScript and callScript.Recheck then
                    recheckHelper( workTable, callScript.Recheck() )
                end
            end
        end

        if block and #block > 0 then
            for i, caller in ipairs( block ) do
                local callScript = caller.script
                callScript = callScript and scripts:GetScript( callScript )

                if callScript and callScript.Recheck then
                    recheckHelper( workTable, callScript.Recheck() )
                end
            end
        end

        -- if Hekili.ActiveDebug then table.insert( steps, debugprofilestop() ) end

        --[[ if state.channeling then
            local aura = class.auras[ state.channel ]
            local remains = state.channel_remains

            if aura and aura.tick_time then
                -- Put tick times into recheck.
                local i = 1
                while ( true ) do
                    if remains - ( i * aura.tick_time ) > 0 then
                        workTable[ roundUp( remains - ( i * aura.tick_time ), 3 ) ] = true
                    else break end
                    i = i + 1
                end

                for time in pairs( workTable ) do
                    if ( ( remains - time ) / aura.tick_time ) % 1 <= 0.5 then
                        workTable[ time ] = nil
                    end
                end
            end

            workTable[ remains ] = true
        end ]]

        --[[ if #steps > 0 then
            -- table.insert( steps, debugprofilestop() )
            local str = string.format( "RECHECK: %.2f", steps[#steps] - steps[1] )

            for i = 2, #steps do
                str = string.format( "%s, %.2f ", str, steps[i] - steps[i-1] )
            end

            print( str )
        end ]]

        wipe( times )

        for k, v in pairs( workTable ) do
            -- if Hekili.ActiveDebug then Hekili:Debug( "%s - %s", tostring( k ), tostring( v ) ) end
            times[ #times + 1 ] = k
        end

        ns.callHook( "recheck", times )

        sort( times )
    end
end



--------------------------------------
-- UGLY METATABLES BELOW THIS POINT --
--------------------------------------
ns.metatables = {}


-- Returns false instead of nil when a key is not found.
local mt_false = {
    __index = function(t, k)
        return false
    end
}
ns.metatables.mt_false = mt_false


do
    local a = class.knownAuraAttributes

    -- Populate table of known aura attributes so we know if we should bother looking in buffs/debuffs for this information.

    a.applied = true
    a.caster = true
    a.cooldown_remains = true
    a.count = true
    a.down = true
    a.duration = true
    a.expires = true
    a.i_up = true
    a.id = true
    a.key = true
    a.lastApplied = true
    a.lastCount = true
    a.last_application = true
    a.last_expiry = true
    a.max_stack = true
    a.max_stacks = true
    a.mine = true
    a.name = true
    a.rank = true
    a.react = true
    a.refreshable = true
    a.remains = true
    a.stack = true
    a.stack_pct = true
    a.stacks = true
    a.tick_time_remains = true
    a.ticking = true
    a.ticks = true
    a.ticks_remain = true
    a.time_to_refresh = true
    a.timeMod = true
    a.unit = true
    a.up = true
    a.v1 = true
    a.v2 = true
    a.v3 = true
end




-- Gives calculated values for some state options in order to emulate SimC syntax.
local mt_state
do
    local logged_state_errors = {}

    local autoReset = setmetatable( {
        -- Internal processing stuff.
        display = 1,
        latency = 1,
        resetting = 1,
        scriptID = 1,
        whitelist = 1,

        -- Timings.
        delay = 1,
        expected_combat_length = 1,
        false_start = 1,
        fight_remains = 1,
            interpolated_fight_remains = 1,
            time_to_die = 1,
        index = 1,
        longest_ttd = 1,
        now = 1,
        offset = 1,
        query_time = 1,
        shortest_ttd = 1,
        time = 1,

        -- Current ability in question, or selected ability when testing the next.
        current_action = 1,
        modified = 1,
        selected_action = 1,
        selection = 1,
        selection_time = 1,
        this_action = 1,

        -- Calculated from event data.
        aggro = 1,
        boss = 1,
        encounter = 1,
        group = 1,
        group_members = 1,
        level = 1,
        mounted = 1,
            is_mounted = 1,
        moving = 1,
        raid = 1,
        solo = 1,
        tanking = 1,

        -- Number of enemies.
        active_enemies = 1,
        cycle_enemies = 1,
        desired_targets = 1,
        max_targets = 1,
        min_targets = 1,
        my_enemies = 1,
        stationary_enemies = 1,
        true_active_enemies = 1,
            true_stationary_enemies = 1,
        true_my_enemies = 1,

        -- Stats (that really come from state.stat )
        crit = 1,
            attack_crit = 1,
            spell_crit = 1,
        haste = 1,
            spell_haste = 1,
        melee_haste = 1,
            attack_haste = 1,
        mastery_value = 1,

        -- ???
        -- Information may be "real" and durable, so we want to leave it be.
        -- active = 1,
        -- hardcast = 1,
        -- miss_react = 1,
        -- ranged = 1,
        -- wait_for_gcd = 1,

        -- Spec State Expressions (probably redundant here).
        effective_combo_points = 1,
        prowling = 1,

        -- Real incoming damage/healing information (handled by autoReset metatable).
        -- incoming_damage = 1,
        -- incoming_heal = 1,
        -- incoming_magic = 1,
        -- incoming_physical = 1,
        -- time_to_pct = 1,

        -- Channels.
        channel = 1,
        channel_breakable = 1,
        channel_remains = 1,
        channeling = 1,

        -- Abilities/Cooldowns.
        action_cooldown = 1,
        cast_delay = 1,
        cast_regen = 1,
        cast_time = 1,
        charges = 1,
        charges_fractional = 1,
        charges_max = 1,
            max_charges = 1,
        cooldown_react = 1,
            cooldown_up = 1,
        cost = 1,
        -- These two belong with ability data because individual abilities have modeled crit modifiers.
        crit_pct_current = 1,
            crit_percent_current = 1,
        execute_remains = 1,
        execute_time = 1,
        executing = 1,
        full_recharge_time = 1,
            time_to_max_charges = 1,
        hardcast = 1,
        in_flight = 1,
        in_flight_remains = 1,
        in_range = 1,
        recharge = 1,
        recharge_time = 1,
        travel_time = 1,

        -- Auras.
        down = 1,
        duration = 1,
        refreshable = 1,
        remains = 1,
        tick_time = 1,
        tick_time_remains = 1,
        ticking = 1,
            up = 1,
        ticks = 1,
        ticks_remain = 1,
        time_to_refresh = 1,

        --[[ Macro conditionals.
        advflyable = 1,
        canexitvehicle = 1,
        -- channeling = 1, -- already exists.
        -- combat = 1, -- already exists.
        flyable = 1,
        flying = 1,
        -- group = 1, -- already exists.
        indoors = 1,
        outdoors = 1,
        -- mounted = 1, -- already exists.
        petbattle = 1,
        pvpcombat = 1,
        resting = 1,
        bonusbar = 1,
        cursor = 1,
        extrabar = 1,
        mod = 1,
        modifier = 1,
        overridebar = 1,
        possessbar = 1,
        shapeshift = 1,
        vehicleui = 1, ]]
    }, {
        __index = function ( t, k )
            -- Make sure to get anything that should be dynamic, in case it was set (via newindex).
            if class.stateExprs[ k ] then return 1 end
            if class.knownAuraAttributes[ k ] then return 1 end
            if k:match( "^time_to_pct" ) then return 1 end
            if k:match( "^incoming_damage" ) then return 1 end
            if k:match( "^incoming_physical" ) then return 1 end
            if k:match( "^incoming_magic" ) then return 1 end
            if k:match( "^incoming_heal" ) then return 1 end

            -- I should reorder this file to avoid this.
            local x = rawget( t, "GetVariableIDs" )
            if x and x( t, k ) ~= nil then return 1 end

            x = rawget( t, "settings" )
            if x and x[ k ] ~= nil then return 1 end

            x = rawget( t, "toggle" )
            if x and x[ k ] ~= nil then return 1 end
        end
    } )

    mt_state = {
        __index = function( t, k )
            -- Simple rules for a resettable table.
            -- If the information won't change (unless explicitly set), assign the value so it's more efficient when used multiple times.
            -- If the information will change and is time-sensitive, just return the calculated value.
            -- If something externally will set the value and it needs to persist, do not include in the reset table.
            -- If it's possible that something will set a value during recommendations generation, the key should also be in the reset table so it'll get wiped for each new set of recommendations.
            if class.stateExprs[ k ] then return class.stateExprs[ k ]()

            -- Internal processing stuff.
            elseif k == "display" then t[k] = "Primary"
            elseif k == "latency" then t[k] = select( 4, GetNetStats() ) / 1000
            elseif k == "resetting" then t[k] = false
            elseif k == "scriptID" then t[k] = "NilScriptID"
            elseif k == "whitelist" then return nil
            elseif k == "cycle" then t[k] = false

            -- Timings.
            elseif k == "delay" then t[k] = 0
            elseif k == "expected_combat_length" then
                if not t.boss then t[k] = 3600 end
                t[k] = t.longest_ttd + t.time -- + t.offset + t.delay
            elseif k == "false_start" then return 0
            elseif k == "fight_remains" or k == "interpolated_fight_remains" or k == "time_to_die" then
                local n = t.longest_ttd
                if not n then Hekili:Error( "longest_ttd was nil, GetGreatestTTD is " .. ( Hekili:GetGreatestTTD() or "nil" ) .. "." ) end
                return max( 1, t.longest_ttd - ( t.offset + t.delay ) )
            elseif k == "index" then t[k] = 0
            elseif k == "longest_ttd" then t[k] = Hekili:GetGreatestTTD()
            elseif k == "now" then t[k] = GetTime()
            elseif k == "offset" then t[k] = 0
            elseif k == "query_time" then  return t.now + t.offset + t.delay
            elseif k == "shortest_ttd" then t[k] = Hekili:GetLowestTTD()
            elseif k == "time" then
                -- Calculate time in combat.
                local c, fs = t.combat, t.false_start
                if c == 0 and fs == 0 then return 0 end
                return t.query_time - max( c, fs )
            elseif type(k) == "string" and k:sub(1, 12) == "time_to_pct_" then
                local percent = tonumber( k:sub( 13 ) ) or 0
                return Hekili:GetGreatestTimeToPct( percent ) - ( t.offset + t.delay )

            -- Current ability in question, or selected ability to compare to ability in question.
            elseif k == "current_action" then return t.this_action
            elseif k == "modified" then t[k] = false
            elseif k == "selected_action" then return
            elseif k == "selection" then return t.selection_time < 60
            elseif k == "selection_time" then t[k] = 60
            elseif k == "this_action" then t[k] = "wait"

            -- Calculated from real event data.
            elseif k == "aggro" then t[k] = ( UnitThreatSituation( "player" ) or 0 ) > 1
            elseif k == "boss" then
                t[k] = t.encounterID > 0 or UnitCanAttack( "player", "target" ) and ( UnitClassification( "target" ) == "worldboss" or UnitLevel( "target" ) == -1 )
            elseif k == "encounter" then t[k] = t.encounterID > 0
            elseif k == "group" then t[k] = t.group_members > 1
            elseif k == "group_members" or k == "active_allies" then t[k] = max( 1, GetNumGroupMembers() )
            elseif k == "level" then t[k] = UnitEffectiveLevel("player") or MAX_PLAYER_LEVEL
            elseif k == "mounted" or k == "is_mounted" then t[k] = IsMounted()
            elseif k == "moving" then t[k] = ( GetUnitSpeed("player") > 0 )
            elseif k == "raid" then t[k] = IsInRaid() and t.group_members > 5
            elseif k == "solo" then t[k] = t.group_members == 1
            elseif k == "tanking" then t[k] = t.role.tank and t.aggro

            -- Enemy counting.
            elseif k == "active_enemies" then
                local n = t.true_active_enemies
                if t.min_targets > 0 then n = max( t.min_targets, n ) end
                if t.max_targets > 0 then n = min( t.max_targets, n ) end
                t[k] = max( 1, n or 1 )

            elseif k == "cycle_enemies" then
                if not t.settings.cycle or t.active_enemies == 1 then return 1 end

                local targets = t.true_active_enemies
                local timeframe = t.delay + t.offset

                local minTTD = timeframe + min( t.cycleInfo.minTTD or 10, t.settings.cycle_min )
                local maxTTD = t.cycleInfo.maxTTD

                if not t.HasCyclingDebuff() and t.settings.cycleDebuff then
                    -- See if the specialization has a default aura to use for cycling (i.e., Unholy using Festering Wound).
                    minTTD = max( minTTD, t.debuff[ t.settings.cycleDebuff ].duration / 2 )
                end

                targets = targets - Hekili:GetNumTTDsBefore( minTTD )

                if maxTTD then
                    targets = targets - Hekili:GetNumTTDsAfter( maxTTD )
                end

                -- So the reason we're stuck here is that we may need "cycle_enemies" when we *aren't* cycling targets.
                -- I.e., we would cycle Festering Strike (festering_wound) but if we've already dotted our valid adds, we'd hit Death and Decay.

                -- testing: don't force minimum targets for cycling purposes, since they may objectively not exist.
                -- if t.min_targets > 0 then targets = max( t.min_targets, targets ) end

                -- cap cycle_targets if forced into single-target model.
                if t.max_targets > 0 then targets = min( t.max_targets, targets ) end

                -- if Hekili.ActiveDebug then Hekili:Debug( "cycle min:%.2f, max:%.2f, ae:%d, before:%d, after:%d, cycle_enemies:%d", minTTD or 0, maxTTD or 0, t.active_enemies, minTTD and Hekili:GetNumTTDsBefore( minTTD ) or 0, maxTTD and Hekili:GetNumTTDsAfter( maxTTD ) or 0, max( 1, targets ) ) end

                return max( 1, targets )

            elseif k == "desired_targets" then t[k] = 1
            elseif k == "max_targets" then t[k] = 0
            elseif k == "min_targets" then t[k] = 0
            elseif k == "my_enemies" then
                local n = t.true_my_enemies
                if t.min_targets > 0 then n = max( t.min_targets, n ) end
                if t.max_targets > 0 then n = min( t.max_targets, n ) end
                t[k] = max( 1, n )

            elseif k == "stationary_enemies" then
                local n = t.true_stationary_enemies
                if t.min_targets > 0 then n = max( t.min_targets, n ) end
                if t.max_targets > 0 then n = min( t.max_targets, n ) end
                t[k] = max( 1, n )

            elseif k == "true_active_enemies" or k == "true_stationary_enemies" then
                local n, s = ns.getNumberTargets()
                t.true_active_enemies = max( 1, n or 1 )
                t.true_stationary_enemies = max( 1, s or 1 )

            elseif k == "true_my_enemies" then t[k] = max( 1, ns.numTargets() )

            -- Stats (that refer to state.stat, generally)
            elseif k == "crit" or k == "spell_crit" or k == "attack_crit" then return ( t.stat.crit / 100 )
            elseif k == "haste" or k == "spell_haste" then return ( 1 / ( 1 + t.stat.spell_haste ) )
            elseif k == "raw_haste_pct" then return t.stat.haste
            elseif k == "melee_haste" or k == "attack_haste" then return ( 1 / ( 1 + t.stat.melee_haste ) )
            elseif k == "mastery_value" then return t.stat.mastery_value

            -- ???; assume it's "durable" and don't expect it to get reset.
            elseif k == "active" then return false
            elseif k == "cast_target" then return "nobody"
            elseif k == "miss_react" then return false
            elseif k == "ranged" then return false
            elseif k == "wait_for_gcd" then return false

            -- Specialization State Expressions
            elseif k == "effective_combo_points" then return 0
            elseif k == "prowling" then return t.buff.prowl.up or ( t.buff.cat_form.up and t.buff.shadowform.up )

            -- Durable stuff; should get manually set if/when needed.
            -- Don't reset.

            -- Channels.
            elseif k == "channel" then
                if t.buff.casting.down or t.buff.casting.v3 ~= 1 then return nil end
                local chan = class.abilities[ t.buff.casting.v1 ]

                if chan then return chan.key end
                return tostring( t.buff.casting.v1 )

            elseif k == "channel_breakable" then t[k] = false
            elseif k == "channel_remains" then return t.buff.casting.up and t.buff.casting.v3 == 1 and t.buff.casting.remains or 0
            elseif k == "channeling" then return t.buff.casting.up and t.buff.casting.v3 == 1

            -- Workaround for Evoker resource (Essence)
            elseif k == "essence" then return t.bfa_essence

            -- Real incoming damage/healing information.
            elseif type(k) == "string" and k:sub(1, 15) == "incoming_damage" then
                local remains = k:sub(17)
                local time = remains:match("^(%d+)[m]?s")

                if not time then
                    return 0
                    -- Error("ERR: " .. remains )
                end

                time = tonumber( time )

                if time > 100 then
                    t[k] = ns.damageInLast( time / 1000 )
                else
                    t[k] = ns.damageInLast( min( 15, time ) )
                end

                return t[ k ]

            elseif type(k) == "string" and k:sub(1, 17) == "incoming_physical" then
                local remains = k:sub(18, 24) == "_damage" and k:sub(26) or k:sub(19)
                local time = remains:match("^(%d+)[m]?s")

                if not time then
                    return 0
                    -- Error("ERR: " .. remains )
                end

                time = tonumber( time )

                if time > 100 then
                    t[k] = ns.damageInLast( time / 1000, true )
                else
                    t[k] = ns.damageInLast( min( 15, time ), true )
                end

                return t[ k ]

            elseif type(k) == "string" and k:sub(1, 14) == "incoming_magic" then
                local remains = k:sub(15, 21) == "_damage" and k:sub(23) or k:sub(16)
                local time = remains:match("^(%d+)[m]?s")

                if not time then
                    return 0
                    -- Error("ERR: " .. remains )
                end

                time = tonumber( time )

                if time > 100 then
                    t[k] = ns.damageInLast( time / 1000, false )
                else
                    t[k] = ns.damageInLast( min( 15, time ), false )
                end

                return t[ k ]

            elseif type(k) == "string" and k:sub(1, 13) == "incoming_heal" then
                local remains = k:sub(15)
                local time = remains:match("^(%d+)[m]?s")

                if not time then
                    return 0
                    -- Error("ERR: " .. remains)
                end

                time = tonumber( time )

                if time > 100 then
                    t[ k ] = ns.healingInLast( time / 1000 )
                else
                    t[ k ] = ns.healingInLast( min( 15, time ) )
                end

                return t[ k ]

            end

            -- If we successfully calculated during the above, return it.
            local value = rawget( t, k )
            if value ~= nil then return value end

            -- The next block are values that reference an ability.
            local action = t.this_action
            local model = t.action[ action ]
            local ability = class.abilities[ action ]
            local cooldown = t.cooldown[ action ]

            if k == "action_cooldown" then return ability and ability.cooldown or 0
            elseif k == "cast_delay" then return 0
            elseif k == "cast_regen" then
                local resType = class.primaryResource
                local amount, resource

                if ability then
                    amount, resource = ability.spend

                    if not resource and ability.spendType then
                        resource = ability.spendType
                    end
                end

                resType = resource or resType

                local regen = t[ resType ].regen
                if regen == 0.001 then regen = 0 end

                if not amount then return t.gcd.execute * regen end
                return ( max( t.gcd.execute, ability.cast or 0 ) * regen ) - ( ability.spend or 0 )

            elseif k == "cast_time" then return ability and ability.cast or 0
            elseif k == "charges" then return cooldown.charges
            elseif k == "charges_fractional" then return cooldown.charges_fractional
            elseif k == "charges_max" or k == "max_charges" then return ability and ability.charges or 1
            elseif k == "cooldown_duration" then return cooldown.duration
            elseif k == "cooldown_react" or k == "cooldown_up" then return cooldown.remains == 0
            elseif k == "cooldown_remains" then return cooldown.remains
            elseif k == "cost" then
                if not ability then return 0 end

                local c = ability.cost
                if c then return c end

                c = ability.spend
                if c and c > 0 and c < 1 then
                    c = c * t[ ability.spendType or class.primaryResource ].modmax
                end
                return c or 0

            elseif k == "crit_pct_current" or k == "crit_percent_current" then return ability and ability.critical or t.stat.crit
            elseif k == "execute_remains" then
                -- TODO:  Check out if this is functioning as expected.
                -- Should buff.casting already suffice for a cast?  A queued cast should already trigger a casting buff.
                return ( t:IsCasting( action ) and max( t:QueuedCastRemains( action ), t.gcd.remains ) ) or ( t.prev[1][ action ] and t.gcd.remains ) or 0

            elseif k == "execute_time" then return max( t.gcd.execute, ability and ability.cast or 0 )
            elseif k == "executing" then return t:IsCasting( action ) or ( t.prev[ 1 ][ action ] and t.gcd.remains > 0 )
            elseif k == "full_recharge_time" or k == "time_to_max_charges" then return cooldown.full_recharge_time
            elseif k == "hardcast" then return false -- will set to true if/when a spell is hardcast.
            elseif k == "in_flight" then return model and model.in_flight or false
            elseif k == "in_flight_remains" then return model and model.in_flight_remains or 0
            elseif k == "in_range" then return model.in_range
            elseif k == "recharge" then return cooldown.recharge
            elseif k == "recharge_time" then return cooldown.recharge_time
            elseif k == "travel_time" then
                local f, v = ability.flightTime or 0, ability.velocity or 0
                if f > 0 then return f end
                if v == 0 then return 0 end
                return t.target.maxR / v

            end

            --[[ None of the Abilities/Actions/Cooldowns block currently sets a value, so there's no need for this.
            value = rawget( t, k )
            if value ~= nil then return value end ]]

            local aura_name = ability and ability.aura or t.this_action
            local aura = aura_name and class.auras[ aura_name ]
            local app = aura and ( ( t.buff[ aura_name ].up and t.buff[ aura_name ] ) or ( t.debuff[ aura_name ].up and t.debuff[ aura_name ] ) or t.buff[ aura_name ] )

            if not app then
                if ability and ability.startsCombat then
                    app = unknown_debuff
                else
                    app = unknown_buff
                end
            end

            if aura and class.knownAuraAttributes[ k ] then
                -- Buffs, debuffs...

                value = app and app[ k ]
                if value ~= nil then return value end

                -- This uses the default aura duration (if available) to keep pandemic windows accurate.
                -- local duration = aura and aura.duration or 15

                -- This allows for overridden tick times on a particular application of an aura (i.e., Exsanguinate).
                -- local tick_time = app and app.tick_time or ( aura and aura.tick_time ) or ( 3 * t.haste )

                if k == "up" or k == "ticking" then return false
                elseif k == "down" then return true
                elseif k == "duration" then return ( aura.duration or 15 )
                elseif k == "refreshable" then return true
                    -- When cycling targets, we want to consider that there may be a valid other target.
                    -- if t.isCyclingTargets( action, aura_name ) then return true end
                    -- if app then return app.remains < 0.3 * ( aura.duration or 15 ) end
                    -- return true

                elseif k == "remains" then return 0
                    -- if app then return app.remains end
                    -- return 0
                elseif k == "tick_time" then return aura.tick_time or ( 3 * state.haste )
                elseif k == "tick_time_remains" then return 0
                elseif k == "ticks" then return ( aura.duration or 15 ) / ( aura.tick_time or ( 3 * haste ) )
                elseif k == "ticks_remain" then return 0
                elseif k == "time_to_refresh" then return 0 end
            end

            -- Fallback to action cast time; found in Augmentation APL.
            if k == "duration" then return ability and ability.cast or 0 end

            -- Check if this is a resource table pre-init.
            for key in pairs( class.resources ) do
                if key == k then
                    return nil
                end
            end

            if t:GetVariableIDs( k ) then return t.variable[ k ] end
            if t.settings[ k ] ~= nil then return t.settings[ k ] end
            if t.toggle[ k ]   ~= nil then return t.toggle[ k ] end

            if k ~= "scriptID" and not ( logged_state_errors[ t.scriptID ] and logged_state_errors[ t.scriptID ][ k ] ) then
                Hekili:Error( "Unknown key '" .. k .. "' in emulated environment for [ " .. t.scriptID .. " : " .. t.this_action .. " ].\n\n" .. debugstack() )
                logged_state_errors[ t.script ] = logged_state_errors[ t.script ] or {}
                logged_state_errors[ t.script ][ k ] = true
            end
        end,
        __newindex = function( t, k, v )
            if v ~= nil and autoReset[ k ] then
                Mark( t, k )
            end
            rawset( t, k, v )
        end
    }

    SuperMark( state, autoReset )
end
ns.metatables.mt_state = mt_state


local mt_spec = {
    __index = function(t, k)
        return false
    end
}
ns.metatables.mt_spec = mt_spec


local mt_stat = {
    __index = function(t, k)
        if k == "strength" then
            t[k] = UnitStat( "player", 1 )

        elseif k == "agility" then
            t[k] = UnitStat( "player", 2 )

        elseif k == "stamina" then
            t[k] = UnitStat( "player", 3 )

        elseif k == "intellect" then
            t[k] = UnitStat( "player", 4 )

        elseif k == "spirit" then
            t[k] = UnitStat( "player", 5 )

        elseif k == "health" then
            return state.health and state.health.current or 50000

        elseif k == "maximum_health" then
            return state.health and state.health.max or 50000

        elseif k == "health_pct" then
            return state.health and state.health.pct or 100

        elseif k == "mana" then
            return state.mana and state.mana.current or 0

        elseif k == "maximum_mana" then
            return state.mana and state.mana.max or 0

        elseif k == "rage" then
            return state.rage and state.rage.current or 0

        elseif k == "maximum_rage" then
            return state.rage and state.rage.max or 0

        elseif k == "energy" then
            return state.energy and state.energy.current or 0

        elseif k == "maximum_energy" then
            return state.energy and state.energy.max or 0

        elseif k == "focus" then
            return state.focus and state.focus.current or 0

        elseif k == "maximum_focus" then
            return state.focus and state.focus.max or 0

        elseif k == "runic" or k == "runic_power" then
            return state.runic_power and state.runic_power.current or 0

        elseif k == "maximum_runic" or k == "maximum_runic_power" then
            return state.runic_power and state.runic_power.max or 0

        elseif k == "spell_power" then
            t[k] = GetSpellBonusDamage(7)

        elseif k == "mp5" then
            t[k] = state.mana and state.mana.regen or 0

        elseif k == "attack_power" then
            t[k] = UnitAttackPower("player") + UnitWeaponAttackPower("player")

        elseif k == "crit_rating" then
            t[k] = GetCombatRating(CR_CRIT_MELEE)

        elseif k == "haste_rating" then
            t[k] = GetCombatRating(CR_HASTE_MELEE)

        elseif k == "weapon_dps" or k == "weapon_offhand_dps" then
            local low, high, offlow, offhigh = UnitDamage( "player" )
            t.weapon_dps = 0.5 * ( low + high )
            t.weapon_offhand_dps = 0.5 * ( low + high )

        elseif k == "weapon_speed" or k == "weapon_offhand_speed" then
            local main, off = UnitAttackSpeed( "player" )
            t.weapon_speed = main or 0
            t.weapon_offhand_speed = off or 0

        elseif k == "armor" or k == "bonus_armor" then
            local _, eff, _, bonus = UnitArmor( "player" )
            t.armor = eff or 0
            t.bonus_armor = bonus or 0

        elseif k == "resilience_rating" then
            t[k] = GetCombatRating(CR_CRIT_TAKEN_SPELL)

        elseif k == "mastery_rating" then
            t[k] = GetCombatRating(CR_MASTERY)

        elseif k == "mastery_value" then
            t[k] = GetMasteryEffect() / 100

        elseif k == "versatility_atk_rating" then
            t[k] = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)

        elseif k == "versatility_atk_mod" then
            t[k] = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) / 100

        elseif k == "versatility_def_rating" then
            t[k] = GetCombatRating(CR_VERSATILITY_DAMAGE_TAKEN)

        elseif k == "versatility_def_mod" then
            t[k] = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) / 100

        elseif k == "mod_haste_pct" then
            t[k] = 0

        elseif k == "spell_haste" then
            t[k] = ( UnitSpellHaste( "player" ) + ( t.mod_haste_pct or 0 ) ) / 100

        elseif k == "melee_haste" then
            t[k] = ( GetMeleeHaste() + ( t.mod_haste_pct or 0 ) ) / 100

        elseif k == "haste" then
            t[k] = t.spell_haste or t.melee_haste

        elseif k == "mod_crit_pct" then
            t[k] = 0

        elseif k == "crit" then
            t[k] = ( max( GetCritChance(), GetSpellCritChance( "player" ), GetRangedCritChance() ) + ( t.mod_crit_pct or 0 ) )

        end

        return rawget( t, k )
    end,
    __newindex = function( t, k, v )
        if v == nil then return end
        Mark( t, k )
        rawset( t, k, v )
    end
}
ns.metatables.mt_stat = mt_stat



-- Table of pet data.
local mt_default_pet, mt_pets
do
    local autoReset = {
        expires = 1,
        summonTime = 1,
        id = 1,
        spec = 1,
    }

    -- Table of default handlers for specific pets/totems.
    mt_default_pet = {
        __index = function( t, k )
            if k == "expires" then
                local totemIcon = rawget( t, "icon" )

                if totemIcon then
                    -- This is actually a totem; check them.
                    local present, name, start, duration, icon

                    for i = 1, 5 do
                        present, name, start, duration, icon = GetTotemInfo( i )
                        if duration == 0 then duration = 3600 end

                        if present and ( icon == totemIcon or class.abilities[ name ] and t.key == class.abilities[ name ].key ) then
                            t.expires = start + duration
                            return t.expires
                        end
                    end

                    t.expires = 0
                    return t.expires
                end

                local petSpell = rawget( t, "spell" )
                petSpell = petSpell and state.action[ petSpell ]

                if petSpell then
                    -- We have to track by time since cast.
                    local lastCast = petSpell.lastCast
                    local duration = t.duration

                    if type( duration ) == 'function' then duration = duration() end
                    local expires = lastCast + duration

                    if expires > state.query_time then
                        t.expires = expires
                        return expires
                    end
                end

                local petGUID = UnitGUID( "pet" )
                if petGUID and t.id == tonumber( petGUID:match( "%-(%d+)%-[0-9A-F]+$" ) ) then
                    t.expires = state.query_time + 3600
                    return t.expires
                end

                t.expires = 0
                return 0

            elseif k == "remains" then
                return max( 0, t.expires - ( state.query_time ) )

            elseif k == "up" or k == "active" or k == "alive" or k == "exists" then
                return ( t.expires >= ( state.query_time ) )

            elseif k == "down" then
                return ( t.expires < ( state.query_time ) )

            elseif k == "id" then
                local id = t.model and t.model.id
                if type( id ) == "function" then id = id() end

                return id

            elseif k == "spec" then
                return t.exists and GetSpecialization( false, true )

            elseif k == "key" then
                for pet, v in pairs( state.pet ) do
                    if type( v ) == "table" and t == v then
                        t.key = pet
                    end
                    return pet
                end

            end
        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_default_pet = mt_default_pet

    local petAutoReset = setmetatable( {
        real_pet = 1,
        up = 1,
        exists = 1,
        active = 1,
        alive = 1,
        dead = 1,
        health_pct = 1,
        health_percent = 1,
    }, {
        __index = function( t, k, v )
            if v == nil then return end
            if type( v ) == "boolean" then Mark( t, k ) end
            rawset( t, k, v )
        end
    } )

    mt_pets = {
        __index = function( t, k )
            if not rawget( t, "real_pet" ) then
                local key
                local petID = UnitGUID( "pet" )

                if petID then
                    petID = tonumber( petID:match( "%-(%d+)%-[0-9A-F]+$" ) )
                    local model = class.pets[ petID ]

                    if model then
                        key = model.token
                        local spell = model.spell
                        local ability = spell and class.abilities[ spell ]
                        local lastCast = ability and ability.lastCast or 0
                        local duration = model.duration and ( type( model.duration ) == "function" and model.duration() or model.duration ) or 3600

                        if lastCast > 0 and duration < 3600 then
                            summonPet( key, lastCast + duration - state.now )
                        else
                            summonPet( key )
                        end
                    end
                end

                t.real_pet = key or "fake_pet"
            end

            if k == "up" or k == "exists" or k == "active" then
                for k, v in pairs( t ) do
                    if type(v) == "table" then
                        if v.expires > state.query_time then return true end
                    end
                end
                return UnitExists( "pet" ) and ( not UnitIsDead( "pet" ) )

            elseif k == "alive" then
                return UnitExists( "pet" ) and not UnitIsDead( "pet" ) and UnitHealth( "pet" ) > 0

            elseif k == "dead" then
                return UnitExists( "pet" ) and UnitIsDead( "pet" )

            elseif k == "health_pct" or k == "health_percent" then
                if t.alive then return 100 * UnitHealth( "pet" ) / UnitHealthMax( "pet" ) end
                return 100

            end

            local model = class.pets[ k ]

            if model then
                t[ k ] = {
                    name = k,
                    spell = model.spell,
                    duration = model.duration,
                    expires = nil,
                    spec = model.spec,
                    model = model
                }

                if model.spec then
                    t[ model.spec ] = t[ k ]
                end

                return t[ k ]
            end

            local ttm = class.totems[ k ]

            if ttm then
                t[ k ] = {
                    key = k,
                    icon = ttm
                }

                return t[ k ]
            end

            return t.fake_pet
        end,

        __newindex = function(t, k, v)
            if type(v) == "table" then
                if not v.key then v.key = k end
                rawset( t, k, setmetatable( v, mt_default_pet ) )
                return
            end
            if v == nil then return end
            if petAutoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end

    }
    ns.metatables.mt_pets = mt_pets
end


-- TODO: This may require revision, since other code might change buffs w/o changing stance.
local mt_stances = {
    __index = function( t, k )
        if not class.stances[ k ] or not GetShapeshiftForm() then return false
        elseif GetShapeshiftForm() < 1 then return false
        elseif not select( 5, GetShapeshiftFormInfo( GetShapeshiftForm() ) ) == class.stances[k] then return false end
        rawset(t, k, select( 5, GetShapeshiftFormInfo( GetShapeshiftForm() ) ) == class.stances[k] )
        return t [ k]
    end,
    __newindex = function( t, k, v )
        if v == nil then return end
        Mark( t, k )
        rawset( t, k, v )
    end,
}
ns.metatables.mt_stances = mt_stances

-- Table of supported toggles (via keybinding).
-- Need to add a commandline interface for these, but for some reason, I keep neglecting that.
local mt_toggle = {
    __index = function( t, k )
        if not k then return end

        local db = Hekili.DB
        if not db then return end

        local toggle = db.profile.toggles[ k ]

        if k == "cooldowns" and ( toggle.override and state.buff.bloodlust.up or toggle.infusion and state.buff.power_infusion.up ) then return true end
        if k == "essences" and toggle.override and state.toggle.cooldowns then return true end
        if k == "potions" and toggle.override and state.toggle.cooldowns then return true end

        if toggle then return toggle.value end
    end
}
ns.metatables.mt_toggle = mt_toggle


local mt_settings = {
    __index = function( t, k )
        local ability = state.this_action and class.abilities[ state.this_action ]

        if rawget( t, "spec" ) then
            if t.spec.settings[ k ] ~= nil then return t.spec.settings[ k ] end
            if t.spec[ k ] ~= nil then return t.spec[ k ] end

            if ability then
                if ability.item and t.spec.items[ state.this_action ] ~= nil then return t.spec.items[ state.this_action ][ k ]
                elseif not ability.item and t.spec.abilities[ state.this_action ] ~= nil then return t.spec.abilities[ state.this_action ][ k ] end
            end
        end

        return
    end
}
ns.metatables.mt_settings = mt_settings


-- Table of target attributes. Needs to be expanded.
-- Needs review.
local mt_target
do
    local autoReset = setmetatable( {
        distance = 1,
        in_range = 1,
        maxR = 1,
        minR = 1,
        outside = 1,
        range = 1,
        within = 1,

        adds = 1,
        casting = 1,
        class = 1,
        exists = 1,
        health_current = 1,
        health_max = 1,
        health_pct = 1,
        is_add = 1,
        is_boss = 1,
        is_dead = 1,
        is_demon = 1,
        is_friendly = 1,
        is_in_party = 1,
        is_in_raid = 1,
        is_player = 1,
        is_undead = 1,
        level = 1,
        moving = 1,
        real_ttd = 1,
        time_to_die = 1,
        unit = 1,
    }, {
        __index = function( t, k )
            local expr, value = k:match( "^(.+)_?(%d+)$" )
            if expr and value then
                if expr == "time_to_pct" then return 1 end
                if expr == "within" then return 1 end
            end

            local value2
            expr, value, value2 = k:match( "^(.+)(%d+)to(%d+)$" )
            if expr and value and value2 then
                if expr == "range" then return 1 end
            end
        end
    } )

    local PvpDummies = ns.PvpDummies

    mt_target = {
        __index = function( t, k )
            if k == "distance" then t[k] = UnitCanAttack( "player", "target" ) and ( ( t.minR + t.maxR ) / 2 ) or 7.5
            elseif k == "in_range" then return t.distance <= 8
            elseif k == "minR" or k == "maxR" then
                local minR, maxR = RC:GetRange( "target" )
                t.minR = minR or 5
                t.maxR = maxR or 10

            elseif k:sub(1, 7) == "outside" then
                local minR = k:match( "^outside([0-9.]+)$" )
                if not minR then return false end
                return ( t.minR > tonumber( minR ) )

            elseif k:sub(1, 6) == "within" then
                local maxR = k:match( "^within([0-9.]+)$" )
                if not maxR then return false end
                return ( t.maxR <= tonumber( maxR ) )

            elseif k:sub(1, 5) == "range" then
                local minR, maxR = k:match( "^range([0-9.]+)to([0-9.]+)$" )
                if not minR or not maxR then return false end
                return ( t.minR >= tonumber( minR ) and t.maxR <= tonumber( maxR ) )

            elseif k == "adds" then t[k] = state.active_enemies - 1
            elseif k == "casting" then return state.debuff.casting.up and not state.debuff.casting.v2
            elseif k == "class" then
                if not t.exists then t[k] = "virtual"
                elseif not t.is_player then t[k] = "npc"
                else
                    local c = UnitClassBase( "target" )
                    if c then t[k] = strlower( c )
                    else t[k] = "unknown" end
                end
            elseif k == "exists" then t[k] = UnitExists( "target" )
            elseif k == "health_current" then return t.health.current
            elseif k == "health_max" then return t.health.max
            elseif k == "health_pct" or k == "health_percent" then return t.health.percent
            elseif k == "has_vehicle_ui" then t[k] = UnitInVehicle( "target" )
            elseif k == "is_add" then t[k] = not t.is_boss
            elseif k == "is_boss" then
                if UnitExists( "boss1" ) and UnitIsUnit( "target", "boss1" ) or
                    UnitExists( "boss2" ) and UnitIsUnit( "target", "boss2" ) or
                    UnitExists( "boss3" ) and UnitIsUnit( "target", "boss3" ) or
                    UnitExists( "boss4" ) and UnitIsUnit( "target", "boss4" ) or
                    UnitExists( "boss5" ) and UnitIsUnit( "target", "boss5" ) then t[k] = true
                else
                    t[k] = ( UnitCanAttack( "player", "target" ) and ( UnitClassification( "target" ) == "worldboss" or UnitLevel( "target" ) == -1 ) )
                end
            elseif k == "is_dead" then t[k] = UnitIsDeadOrGhost("target")
            elseif k == "is_demon" then t[k] = UnitCreatureType( "target" ) == PET_TYPE_DEMON
            elseif k == "is_friendly" then t[k] = UnitCanAssist( "player", "target" )
            elseif k == "is_in_party" then t[k] = UnitInParty( "target" )
            elseif k == "is_in_raid" then t[k] = UnitInRaid( "target" ) ~= nil
            elseif k == "is_player" then
                local isPlayer = UnitIsPlayer( "target" )
                if not isPlayer then isPlayer = PvpDummies[ t.npcid ] end
                t[k] = isPlayer or false -- Enables proper treatment of Absolute Corruption and similar modified-in-PvP effects.

            elseif k == "is_undead" then t[k] = UnitCreatureType( "target" ) == BATTLE_PET_NAME_4

            elseif k == "level" then t[k] = UnitLevel( "target" ) or UnitLevel( "player" ) or MAX_PLAYER_LEVEL
            elseif k == "moving" then t[k] = GetUnitSpeed( "target" ) > 0
            elseif k == "real_ttd" then t[k] = Hekili:GetTTD( "target" )
            elseif k == "time_to_die" then
                local ttd = t.real_ttd
                if ttd == 3600 then t[k] = ttd
                else return max( 1, t.real_ttd - ( state.offset + state.delay ) ) end

            elseif k:sub(1, 12) == "time_to_pct_" then
                local percent = tonumber( k:sub( 13 ) ) or 0
                return Hekili:GetTimeToPct( "target", percent ) - ( state.offset + state.delay )

            elseif k == "unit" then
                if state.args.cycle_target == 1 then return UnitGUID( "target" ) .. "c" or "cycle"
                elseif state.args.target then return ( UnitGUID( "target" ) .. '+' .. state.args.target ) or "unknown" end
                return UnitGUID( "target" ) or "unknown"

            elseif k == "npcid" then
                if UnitExists( "target" ) then
                    local id = UnitGUID( "target" )
                    id = id and id:match( "(%d+)-%x-$" )
                    id = id and tonumber( id )

                    return id or -1
                end

                return -1

            end

            return rawget( t, k )
        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_target = mt_target
end


local mt_target_health
do
    local autoReset = {
        actual = 1,
        current = 1,
        max = 1,
        pct = 1,
        percent = 1,
    }

    mt_target_health = {
        __index = function(t, k)
            if k == "current" or k == "actual" then
                return UnitCanAttack("player", "target") and not UnitIsDead( "target" ) and UnitHealth("target") or 100000

            elseif k == "max" then
                return UnitCanAttack("player", "target") and not UnitIsDead( "target" ) and UnitHealthMax("target") or 100000

            elseif k == "pct" or k == "percent" then
                return t.max ~= 0 and ( 100 * t.current / t.max ) or 100
            end
        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_target_health = mt_target_health
end



local mt_consumable = {
    __index = function( t, k )
        return class.potion == k
    end
}
setmetatable( state.consumable, mt_consumable )


local mt_default_cooldown
local mt_cooldowns

do
    local autoReset = {
        charge = 1,
        duration = 1,
        expires = 1,
        next_charge = 1,
        recharge_began = 1,
        true_expires = 1,
        true_remains = 1,
    }

    -- Table of default handlers for specific ability cooldowns.
    mt_default_cooldown = {
        __index = function( t, k )
            local ability = rawget( t, "key" ) and class.abilities[ t.key ] or class.abilities.null_cooldown

            local GetCooldown = function(spellID)
                local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID);
                if spellCooldownInfo then
                    return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;
                end
            end
            local profile = Hekili.DB.profile
            local id = ability.id

            if ability then
                if rawget( ability, "meta" ) and ability.meta[ k ] then
                    return ability.meta[ k ]( t )
                end

                if ability.funcs.cooldown_special then
                    GetCooldown = ability.funcs.cooldown_special
                    id = 999999
                elseif ability.item then
                    GetCooldown = GetItemCooldown
                    id = ability.itemCd or ability.item
                end
            end

            -- We don't cache IDs in cooldown tables to avoid issues with ID and specialization changes.
            if k == "id" then
                return id
            end

            local noFeignCD = rawget( profile.specs, state.spec.id )
            noFeignCD = noFeignCD and noFeignCD.noFeignedCooldown

            local raw = ( state.display ~= "Primary" and state.display ~= "AOE" ) or ( profile.toggles.cooldowns.value and profile.toggles.cooldowns.separate and noFeignCD )

            if k:sub(1, 5) == "true_" then
                k = k:sub(6)
                raw = true
            end


            if k == "duration" or k == "expires" or k == "next_charge" or k == "charge" or k == "recharge_began" then
                local start, duration = 0, 0

                if id > 0 then
                    start, duration = GetCooldown( id )
                    local lossStart, lossDuration = GetSpellLossOfControlCooldown( id )
                    if lossStart and lossStart + lossDuration > start + duration then
                        start = lossStart
                        duration = lossDuration
                    end
                end

                if t.key ~= "global_cooldown" then
                    local gcd = state.cooldown.global_cooldown
                    local gcdStart, gcdDuration = gcd.expires - gcd.duration, gcd.duration
                    if gcdStart == start and gcdDuration == duration then start, duration = 0, 0 end
                end

                local true_duration = duration

                if t.key == "ascendance" and state.buff.ascendance.up then
                    start = state.buff.ascendance.expires - class.auras.ascendance.duration
                    duration = class.abilities[ "ascendance" ].cooldown

                elseif t.key == "potion" then
                    local potion = class.abilities.potion.item
                    if state.toggle.potions and potion then
                        start, duration = GetItemCooldown( potion )

                    else
                        start = state.now
                        duration = 0

                    end

                elseif state.empowerment.active and t.key == state.empowerment.spell then
                    start = 0
                    duration = 0

                end

                t.duration = max( duration or 0, ability.cooldown or 0, ability.recharge or 0 )
                t.expires = start and ( start + duration ) or 0
                t.true_duration = true_duration
                t.true_expires = start and ( start + true_duration ) or 0

                if ability.charges and ability.charges > 1 then
                    local charges, maxCharges
                    charges, maxCharges, start, duration = GetSpellCharges( id )

                    --[[ if class.abilities[ t.key ].toggle and not state.toggle[ class.abilities[ t.key ].toggle ] then
                        charges = 1
                        maxCharges = 1
                        start = state.now
                        duration = 0
                    end ]]

                    if not duration then duration = max( ability.recharge or 0, ability.cooldown or 0 ) end

                    t.true_duration = duration
                    duration = max( duration, ability.recharge )

                    t.charge = charges or 1
                    t.duration = duration
                    t.recharge = duration

                    if charges and charges < maxCharges then
                        t.next_charge = start + duration
                    else
                        t.next_charge = 0
                    end
                    t.recharge_began = start or t.expires - t.duration

                else
                    t.charge = t.expires < state.query_time and 1 or 0
                    t.next_charge = t.expires > state.query_time and t.expires or 0
                    t.recharge_began = t.expires - t.duration
                end

                return t[k]

            elseif k == "charges" then
                if not raw then
                    if ( state:IsDisabled( t.key ) or ability.disabled ) then return 0 end
                    if not state:IsKnown( t.key ) then return ability.charges or 1 end
                end

                return floor( t[ raw and "true_charges_fractional" or "charges_fractional" ] )

            elseif k == "charges_max" or k == "max_charges" then
                return ability.charges or 1

            elseif k == "recharge" then
                return ability.recharge or ability.cooldown or 0

            elseif k == "time_to_max_charges" or k == "full_recharge_time" then
                if not raw then
                    if ( state:IsDisabled( t.key ) or ability.disabled ) then return ( ability.charges or 1 ) * t.duration end
                    if not state:IsKnown( t.key ) then return 0 end
                end

                return ( ( ability.charges or 1 ) - t.true_charges_fractional ) * max( ability.cooldown, t.true_duration )

            elseif k == "remains" then
                if t.key == "global_cooldown" then
                    return max( 0, t.expires - state.query_time )
                end

                -- If the ability is toggled off in the profile, we may want to fake its CD.
                -- Revisit this if I add base_cooldown to the ability tables.
                if not raw then
                    if ( state:IsDisabled( t.key ) or ability.disabled ) then return ability.cooldown end
                    if not state:IsKnown( t.key ) then return 0 end
                end

                local bonus_cdr = 0
                bonus_cdr = ns.callHook( "cooldown_recovery", bonus_cdr ) or bonus_cdr

                return max( 0, t.expires - state.query_time - bonus_cdr )

            elseif k == "charges_fractional" then
                if not raw then
                    if state:IsDisabled( t.key ) or ability.disabled then return 0 end
                    if not state:IsKnown( t.key ) then return ability.charges or 1 end
                end

                if ability.charges and ability.charges > 1 then
                    -- run this ad-hoc rather than with every advance.
                    while t.next_charge > 0 and t.next_charge < state.now + state.offset do
                        -- if class.abilities[ k ].charges and cd.next_charge > 0 and cd.next_charge < state.now + state.offset then
                        t.charge = t.charge + 1
                        if t.charge < ability.charges then
                            t.recharge_began = t.next_charge
                            t.next_charge = t.next_charge + ability.recharge
                        else
                            t.recharge_began = 0
                            t.next_charge = 0
                        end
                    end

                    if t.charge < ability.charges and t.recharge > 0 then
                        return min( ability.charges, t.charge + ( max( 0, state.query_time - t.recharge_began ) / t.recharge ) )
                        -- return t.charges + ( 1 - ( class.abilities[ t.key ].recharge - t.recharge_time ) / class.abilities[ t.key ].recharge )
                    end
                    return t.charge
                end

                return t.remains > 0 and ( 1 - ( t.remains / ability.cooldown ) ) or 1

            elseif k == "recharge_time" then
                if not ability.charges then return t.duration or 0 end
                return t.recharge

            elseif k == "ready" or k == "up" then
                return ( ability.cooldown_ready == nil or ability.cooldown_ready ) and t.remains == 0

            -- Hunters
            elseif k == "remains_guess" or k == "remains_expected" then
                local remains, duration = t.remains, t.duration
                if remains == 0 or remains == duration then return remains end

                local lastCast = state.action[ t.key ].lastCast or 0
                if lastCast == 0 then return remains end

                local reduction = ( state.query_time - lastCast ) / ( duration - remains )
                return remains * reduction

            elseif k == "duration_guess" or k == "duration_expected" then
                local remains, duration = t.remains, t.duration
                if remains == 0 or remains == duration then return duration end

                -- not actually the same as simc here, which tracks when CDs charge.
                local lastCast = state.action[ t.key ].lastCast or 0
                if lastCast == 0 then return duration end

                local reduction = ( state.query_time - lastCast ) / ( duration - remains )
                return duration * reduction

            end

            Error( "UNK: cooldown." .. t.key .. "." .. k )
            return

        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_default_cooldown = mt_default_cooldown


    -- Table for gathering cooldown information. Some abilities with odd behavior are getting embedded here.
    -- Probably need a better system that I can keep in the class modules.
    -- Needs review.
    mt_cooldowns = {
        -- The action doesn't exist in our table so check the real game state, -- and copy it so we don't have to use the API next time.
        __index = function( t, k )
            local entry = class.abilities[ k ]

            if not entry then
                -- Check if this is one of SimC's lovely itemname_spellid type tokens.
                local shortkey = k:match( "^([a-z0-9_])_%d+$" )

                if shortkey and class.abilities[ shortkey ] then
                    class.abilities[ k ] = class.abilities[ shortkey ]
                    entry = class.abilities[ k ]
                else
                    if not rawget( t, "null_cooldown" ) then t.null_cooldown = { key = "null_cooldown", duration = 1 } end
                    return t.null_cooldown
                end
            end

            if k ~= entry.key then
                t[ k ] = t[ entry.key ]
                return t[ k ]
            end

            t[ k ] = { key = k }
            return t[ k ]
        end,
        __newindex = function(t, k, v)
            rawset( t, k, setmetatable( v, mt_default_cooldown ) )
        end
    }
    ns.metatables.mt_cooldowns = mt_cooldowns
end


local mt_dot = {
    __index = function( t, k )
        local a = class.auras[ k ]
        local dotType = a and a.dot
        if not dotType then return state.debuff[ k ] end

        if dotType == "both" then
            if state.buff[ k ].up then return state.buff[ k ] end
            return state.debuff[ k ]
        end

        return state[ dotType ][ k ]
    end,
}
ns.metatables.mt_dot = mt_dot


local one_sec_gcd = {
    DEMONHUNTER = true,
    MONK = true,
    ROGUE = true,
}

local mt_gcd = {
    __index = function( t, k )
        if k == "execute" then
            local ability = state.this_action and class.abilities[ state.this_action ]

            -- We can specify this for any ability, if we want.
            if ability and ability.gcdTime then return ability.gcdTime end

            local gcd = ( state.this_action == "wait" and "spell" ) or ( ability and ability.gcd or "spell" )

            if gcd == "off" then return 0 end
            if gcd == "totem" then return 1 end

            if one_sec_gcd[ class.file ] or class.file == "DRUID" and UnitPowerType( "player" ) == Enum.PowerType.Energy then
                return state.buff.adrenaline_rush.up and max( 0.75, state.haste ) or 1
            end

            return max( 1.5 * state.haste, state.buff.voidform.up and 0.67 or 0.75 )

        elseif k == "remains" then
            return state.cooldown.global_cooldown.remains

        elseif k == "expires" then
            return state.cooldown.global_cooldown.expires

        elseif k == "max" or k == "duration" then
            if one_sec_gcd[ class.file ] or class.file == "DRUID" and UnitPowerType( "player" ) == Enum.PowerType.Energy then
                return state.buff.adrenaline_rush.up and max( 0.75, state.haste ) or 1
            end

            return max( 1.5 * state.haste, state.buff.voidform.up and 0.67 or 0.75 )

        elseif k == "lastStart" then
            return 0

        end

        return
    end
}
ns.metatables.mt_gcd = mt_gcd
setmetatable( state.gcd, mt_gcd )


local mt_prev_lookup = {
    __index = function( t, k )
        local idx = t.index
        local preds, prev

        if     t.meta == "castsAll" then preds, prev = state.predictions   , state.prev
        elseif t.meta == "castsOn"  then preds, prev = state.predictionsOn , state.prev_gcd
        elseif t.meta == "castsOff" then preds, prev = state.predictionsOff, state.prev_off_gcd end

        if k == "spell" then
            -- Return the actual spell for the slot, for lookups.
            if preds[ idx ] then return preds[ idx ] end

            if state.player.queued_ability then
                if idx == #preds + 1 then return state.player.queued_ability end
                return prev.history[ idx - #preds + 1 ]
            end

            if idx == 1 and prev.override then
                return prev.override
            end

            return prev.history[ idx - #preds ]
        end

        if preds[ idx ] then return preds[ idx ] == k end

        if state.player.queued_ability then
            if idx == #preds + 1 then
                return state.player.queued_ability == k
            end
            return prev.history[ idx - #preds + 1 ] == k
        end

        if idx == 1 and prev.override then
            return prev.override == k
        end

        return prev.history[ idx - #preds ] == k
    end,
}

local prev_lookup = setmetatable( {
    index = 1,
    meta = 'castsAll'
}, mt_prev_lookup )


local mt_prev

do
    local autoReset = {
        last = 1,
        override = 1,
    }

    mt_prev = {
        __index = function( t, k )
            if type( k ) == "number" then
                prev_lookup.meta = t.meta -- Which data to use? castsAll, castsOn (GCD), castsOff (offGCD)?
                prev_lookup.index = k
                return prev_lookup
            elseif k == "last" then
                if t.meta == "castAll" then t.last = state.player.lastcast
                elseif t.meta == "castsOn" then t.last = state.player.lastgcd
                elseif t.meta == "castsOff" then t.last = state.player.lastoffgcd end
                return rawget( t, "last" ) or "none"
            end

            if k == t.last then
                return true
            end

            return false
        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_prev = mt_prev
end


local resource_meta_functions = {}

function state:AddResourceMetaFunction( name, f )
    resource_meta_functions[ name ] = f
end


function state:CombinedResourceRegen( t )
    local regen = t.regen
    if regen == 0.001 then regen = 0 end

    local model = t.regenModel
    if not model then return regen end

    for _, source in pairs( model ) do
        local value = type( source.value ) == "function" and source.value() or source.value
        local interval = type( source.interval ) == "function" and source.interval() or source.interval

        local aura = source.aura

        if aura then
            aura = source.debuff and state.debuff[ aura ] or state.buff[ aura ]

            if aura.up then
                regen = regen + ( value / interval )
            end
        end
    end

    return regen
end


function state:TimeToResource( t, amount )
    if not amount or amount > t.max then return 3600
    elseif t.current >= amount then return 0 end

    local pad, lastTick = 0, nil
    if t.resource == "energy" or t.resource == "focus" then
        -- Round any result requiring ticks to the next tick.
        lastTick = t.last_tick
    end

    local regen, slice = t.regen, nil
    if regen == 0.001 then regen = 0 end

    if t.forecast and t.fcount > 0 then
        local q = state.query_time

        if t.times[ amount ] then return t.times[ amount ] - q end

        if regen == 0 then
            for i = 1, t.fcount do
                local v = t.forecast[ i ]
                if v.v >= amount then
                    t.times[ amount ] = v.t
                    return max( 0, t.times[ amount ] - q )
                end
            end
            t.times[ amount ] = q + 3600
            return max( 0, t.times[ amount ] - q )
        end

        for i = 1, t.fcount do
            slice = t.forecast[ i ]
            local after = t.forecast[ i + 1 ]

            if slice.v >= amount then
                t.times[ amount ] = slice.t

                if lastTick then
                    pad = ( slice.t - lastTick ) % 0.1
                    pad = 0.1 - pad
                end

                return max( 0, pad + t.times[ amount ] - q )

            elseif after and after.v >= amount then
                -- Our next slice will have enough resources.  Check to see if we'd regen enough in-between.
                local time_diff = after.t - slice.t
                local deficit = amount - slice.v
                local regen_time = deficit / regen

                if lastTick then
                    pad = ( slice.t - lastTick ) % 0.1
                    pad = 0.1 - pad
                end

                if regen_time < time_diff then
                    t.times[ amount ] = ( pad + slice.t + regen_time )
                else
                    t.times[ amount ] = after.t
                end
                return max( 0, t.times[ amount ] - q )
            end
        end

        t.times[ amount ] = q + 3600
        return max( 0, t.times[ amount ] - q )
    end

    -- This wasn't a modeled resource, just look at regen time.
    if lastTick and slice then
        pad = ( slice.t - lastTick ) % 0.1
        pad = 0.1 - pad
    end

    if regen <= 0 then return 3600 end
    return max( 0, pad + ( ( amount - t.current ) / regen ) )
end



local mt_resource = {
    __index = function( t, k )

        local meta = t.meta[ k ]
        if meta ~= nil then
            local result = meta( t )

            if result ~= nil then
                return result
            end
        end

        if k == "pct" or k == "percent" then
            return 100 * ( t.current / t.max )

        elseif k == "deficit_pct" or k == "deficit_percent" then
            return 100 - t.pct

        elseif k == "current" then
            local regen = t.regen
            if regen == 0.001 then regen = 0 end

            -- If this is a modeled resource, use our lookup system.
            if t.forecast and t.fcount > 0 then
                local q = state.query_time
                local index, slice

                if t.values[ q ] then return t.values[ q ] end

                for i = 1, t.fcount do
                    local v = t.forecast[ i ]
                    if v.t <= q and v.v ~= nil then
                        index = i
                        slice = v
                    else
                        break
                    end
                end

                -- We have a slice.
                if index and slice and slice.v then
                    t.values[ q ] = max( 0, min( t.max, slice.v + ( ( state.query_time - slice.t ) * regen ) ) )
                    return t.values[ q ]
                end
            end

            -- No forecast.
            if regen ~= 0 then
                return max( 0, min( t.max, t.actual + ( regen * state.delay ) ) )
            end

            return t.actual

        elseif k == "deficit" or k == "base_deficit" then
            return t.max - t.current

        elseif k == "max_nonproc" then
            return t.max -- need to accommodate buffs that increase mana, etc.

        elseif k == "time_to_max" or k == "base_time_to_max" then
            return state:TimeToResource( t, t.max )

        elseif k == "time_to_max_combined" then
            if not state.spec.assassination then return t.time_to_max end

            -- Assassination, April 2021
            -- Using the same as time_to_max because our time_to_max uses modeled regen events...
            return state:TimeToResource( t, t.max )

        elseif k:sub(1, 8) == "time_to_" then
            local amount = k:sub(9)
            amount = tonumber(amount)

            if not amount then return 3600 end

            return state:TimeToResource( t, amount )

        elseif k == "regen" then
            return ( state.time > 0 and t.active_regen or t.inactive_regen ) or 0

        elseif k == "regen_combined" then
            local regen = t.regen
            if regen == 0.001 then regen = 0 end
            return max( regen, state:CombinedResourceRegen( t ) )

        elseif k == "modmax" then
            return t.max

        elseif k == "model" then
            return

        elseif k == 'onAdvance' then
            return

        end

    end
}
ns.metatables.mt_resource = mt_resource


local default_buff_values = {
    name = "no_name",
    count = 0,
    lastCount = 0,
    lastApplied = 0,
    expires = 0,
    applied = 0,
    -- duration = 15,
    caster = "nobody",
    timeMod = 1,
    v1 = 0,
    v2 = 0,
    v3 = 0,

    last_application = 0,
    last_expiry = 0,

    unit = "player"
}


function state:AddBuffMetaFunction( aura, key, func )
    local a = class.auras[ aura ]
    if not a then return end

    if not a.meta then a.meta = {} end
    a.meta[ key ] = setfenv( func, self )
end



local requiresLookup = {
    name = true,
    count = true,
    lastCount = true,
    lastApplied = true,
    expires = true,
    applied = true,
    caster = true,
    id = true,
    timeMod = true,
    v1 = true,
    v2 = true,
    v3 = true,

    last_application = true,
    last_expiry = true,

    unit = true
}


-- Table of default handlers for auras (buffs, debuffs).
-- Aliases let a single buff name refer to any of multiple buffs.
local mt_alias_buff
local mt_default_buff
local mt_buffs

do
    local autoReset = setmetatable( {
        applied = 1,
        caster = 1,
        count = 1,
        -- duration = 1,
        expires = 1,
        last_application = 1,
        last_expiry = 1,
        lastApplied = 1,
        lastCount = 1,
        name = 1,
        timeMod = 1,
        unit = 1,
        v1 = 1,
        v2 = 1,
        v3 = 1,
    }, {
        __index = function( t, k )
            if class.knownAuraAttributes[ k ] ~= nil then return 1 end
        end,
    } )

    -- Developed mainly for RtB; it will also report "stack" or "count" as the sum of stacks of multiple buffs.
    mt_alias_buff = {
        __index = function( t, k )
            local aura = class.auras[ t.key ]
            local type = aura.aliasType or "buff"

            if aura.meta and aura.meta[ k ] then return aura.meta[ k ]() end

            if k == "max_stack" then return aura.max_stack or 1
            elseif k == "count" or k == "stack" or k == "stacks" then
                local n = 0

                if type == "any" then
                    for i, child in ipairs( aura.alias ) do
                        if state.buff[ child ].up then n = n + max( 1, state.buff[ child ].stack ) end
                        if state.debuff[ child ].up then n = n + max( 1, state.debuff[ child ].stack ) end
                    end
                else
                    for i, child in ipairs( aura.alias ) do
                        if state[ type ][ child ].up then n = n + max( 1, state[ type ][ child ].stack ) end
                    end
                end

                return n

            end

            local alias
            local mode = aura.aliasMode or "first"

            for i, v in ipairs( aura.alias ) do
                local child

                if type == "any" then
                    child = state.debuff[ v ].up and state.debuff[ v ] or state.buff[ v ]
                else
                    child = state[ type ][ v ]
                end

                if not alias and mode == "first" and child.up then return child[ k ] end

                if child.up then
                    if mode == "shortest" and ( not alias or child.remains < alias.remains ) then alias = child
                    elseif mode == "longest" and ( not alias or child.remains > alias.remains ) then alias = child end
                end
            end

            if type == "any" then type = "buff" end

            if alias then return alias[ k ]
            else return state[ type ][ aura.alias[1] ][ k ] end
        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            class.knownAuraAttributes[ k ] = true
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_alias_buff = mt_alias_buff

    mt_default_buff = {
        mtID = "default_buff",

        __index = function( t, k )
            local aura = class.auras[ t.key ]

            if aura and aura.hidden then
                -- Hidden auras might be detectable with FindPlayerAuraByID.
                local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = FindPlayerAuraByID( aura.id )

                if name then
                    local buff = auras.player.buff[ t.key ] or {}

                    buff.key = t.key
                    buff.id = spellID
                    buff.name = name
                    buff.count = count > 0 and count or 1
                    -- buff.duration = duration
                    buff.expires = expires
                    buff.caster = caster
                    buff.applied = expires - duration
                    buff.caster = caster
                    buff.timeMod = timeMod
                    buff.v1 = v1
                    buff.v2 = v2
                    buff.v3 = v3

                    buff.last_application = buff.last_application or 0
                    buff.last_expiry      = buff.last_expiry or 0

                    buff.unit = "player"

                    auras.player.buff[ t.key ] = buff
                end
            end

            if aura and rawget( aura, "meta" ) and aura.meta[ k ] then
                if not t.metastack[ k ] then
                    t.metastack[ k ] = true
                    local value = aura.meta[ k ]( t, "buff" )
                    t.metastack[ k ] = nil
                    if value ~= nil then return value end
                end
            end

            if requiresLookup[ k ] then
                if aura and aura.generate then
                    for attr, a_val in pairs( default_buff_values ) do
                        t[ attr ] = rawget( t, attr ) or rawget( aura, attr ) or a_val
                    end

                    aura.generate( t, "buff" )
                    t.id = aura and aura.id or t.key

                    return rawget( t, k )
                end

                local real = auras.player.buff[ t.key ] or auras.target.buff[ t.key ]

                if real then
                    t.name = real.name
                    t.count = real.count
                    t.lastCount = real.lastCount or 0
                    t.lastApplied = real.lastApplied or 0
                    -- t.duration = real.duration
                    t.expires = real.expires
                    t.applied = real.applied
                    t.caster = real.caster
                    t.id = real.id or class.auras[ t.key ].id
                    t.timeMod = real.timeMod
                    t.v1 = real.v1
                    t.v2 = real.v2
                    t.v3 = real.v3

                    t.last_application = real.last_application or 0
                    t.last_expiry = real.last_expiry or 0

                    t.unit = real.unit
                else
                    local meta = aura and rawget( aura, "meta" )

                    for attr, a_val in pairs( default_buff_values ) do
                        if not meta or not meta[ attr ] then
                            t[ attr ] = aura and aura[ attr ] or a_val
                        end
                    end

                    t.id = rawget( t, id ) or ( aura and aura.id ) or t.key
                end

                return rawget( t, k )

            elseif k == "up" or k == "ticking" then
                return t.remains > 0

            elseif k == "down" then
                return t.remains == 0

            elseif k == "remains" then
                -- if state.IsCycling( t.key ) then return 0 end
                return t.applied <= state.query_time and max( 0, t.expires - state.query_time ) or 0

            elseif k == "duration" then
                return ( t.remains > 0 and t.expires - t.applied ) or aura.duration or 15

            elseif k == "refreshable" then
                local tr = t.remains
                return tr == 0 or tr < ( 0.3 * ( aura.duration or 30 ) )

            elseif k == "time_to_refresh" then
                local remains = t.remains
                if remains == 0 then return 0 end
                return max( 0, 0.01 + remains - ( 0.3 * ( aura.duration or 30 ) ) )

            elseif k == "cooldown_remains" then
                return state.cooldown[ t.key ] and state.cooldown[ t.key ].remains or 0

            elseif k == "react" or k == "stack" or k == "stacks" then
                if t.remains == 0 then return 0 end
                return t.count

            elseif k == "max_stack" or k == "max_stacks" then
                return max( t.stacks, aura and aura.max_stack or 1 )

            elseif k == "mine" then
                return t.caster == "player"

            elseif k == "v1" then
                return 0

            elseif k == "v2" then
                return 0

            elseif k == "v3" then
                return 0

            elseif k == "value" then
                if t.remains == 0 then return 0 end
                return t.v1 or 0

            elseif k == "stack_value" then
                if t.remains == 0 then return 0 end
                return t.value * t.stack

            elseif k == "stack_pct" then
                if t.remains == 0 then return 0 end
                return ( 100 * t.stack / t.max_stack )

            elseif k == "ticks" then
                if t.remains == 0 then return 0 end
                -- if t.applied <= state.query_time and state.query_time < t.expires then return t.duration / t.tick_time - t.ticks_remain end
                -- if t.up then return 1 + ( ( class.auras[ t.key ].duration or ( 30 * state.haste ) ) / ( class.auras[ t.key ].tick_time or ( 3 * t.haste ) ) ) - t.ticks_remain end
                return t.duration / t.tick_time - t.ticks_remain

            elseif k == "tick_time" then
                if t.remains == 0 then return 0 end
                return aura and aura.tick_time or ( 3 * state.haste ) -- Default tick time will be 3 because why not?

            elseif k == "ticks_remain" then
                if t.remains == 0 then return 0 end
                return t.remains / t.tick_time

            elseif k == "tick_time_remains" then
                if t.remains == 0 then return 0 end
                if t.applied <= state.query_time and state.query_time < t.expires then
                    if not aura.tick_time then return t.remains end
                    return aura.tick_time - ( ( query_time - t.applied ) % aura.tick_time )
                end
                return 0

            elseif k == "last_trigger" then
                if state.combat > 0 then return max( 0, t.last_application - state.combat ) end
                return 0

            elseif k == "last_expire" then
                if state.combat > 0 and t.last_expiry < state.query_time then return max( 0, t.last_expiry - state.combat ) end
                return 0

            else
                if class.auras[ t.key ] and class.auras[ t.key ][ k ] ~= nil then
                    return class.auras[ t.key ][ k ]
                end
            end

            Error( "UNK: buff." .. t.key .. "." .. k .. "\n\n" .. debugstack() )

        end,

        __newindex = function( t, k, v )
            if v == nil then return end

            class.knownAuraAttributes[ k ] = true
            -- Prevent a fixed value from being entered if it is calculated by a meta function.
            -- 20220828:  This was bugged, and fixing it might cause new bugs.  Watch carefully.
            --[[ if t.meta and t.meta[ k ] then
                return
            end ]]

            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_default_buff = mt_default_buff

    unknown_buff = setmetatable( {
        key = "unknown_buff",
        name = "No Name",
        count = 0,
        lastCount = 0,
        lastApplied = 0,
        -- duration = 30,
        expires = 0,
        applied = 0,
        caster = "nobody",
        timeMod = 1,
        v1 = 0,
        v2 = 0,
        v3 = 0,
        unit = "player"
    }, mt_default_buff )




    -- This will currently accept any key and make an honest effort to find the buff on the player.
    -- Unfortunately, that means a buff.dog_farts.up check will actually get a return value.

    local buffs_warned = {}

    -- Fullscan definitely needs revamping, but it works for now.
    mt_buffs = {
        -- The aura doesn't exist in our table so check the real game state, -- and copy it so we don't have to use the API next time.
        __index = function( t, k )
            if k == "__scanned" then
                return false
            end

            local aura = class.auras[ k ]

            if not aura then
                if Hekili.PLAYER_ENTERING_WORLD and not buffs_warned[ k ] then
                    Hekili:Error( "Unknown buff in [" .. state.scriptID .. "]: " .. k .. "\n\n" .. debugstack() )
                    buffs_warned[ k ] = true
                end
                return unknown_buff
            end

            if k ~= aura.key then
                t[ aura.key ] = rawget( t, aura.key ) or {
                    key = aura.key,
                    name = aura.name
                }
                t[ k ] = t[ aura.key ]
            else
                t[k] = {
                    key = aura.key,
                    name = aura.name
                }
            end

            if aura.generate then
                for attr, a_val in pairs( default_buff_values ) do
                    t[ k ][ attr ] = rawget( t[ k ], attr ) or a_val
                end
                aura.generate( t[ k ], "buff" )
                return t[ k ]
            end

            local real = auras.player.buff[ k ] or auras.target.buff[ k ]

            local buff = t[k]

            if real then
                buff.name = real.name
                buff.count = real.count
                buff.lastCount = real.lastCount or 0
                buff.lastApplied = real.lastApplied or 0
                -- buff.duration = real.duration
                buff.expires = real.expires
                buff.applied = real.applied
                buff.caster = real.caster
                buff.id = real.id
                buff.timeMod = real.timeMod
                buff.v1 = real.v1
                buff.v2 = real.v2
                buff.v3 = real.v3

                buff.unit = real.unit
            end

            return t[ k ]

        end,

        __newindex = function( t, k, v )
            local aura = class.auras[ k ]

            if aura then
                aura.used = true
                if aura.meta then rawset( v, "metastack", {} ) end
                if aura.alias then
                    rawset( t, k, setmetatable( v, mt_alias_buff ) )
                    return
                end
            end

            rawset( t, k, setmetatable( v, mt_default_buff ) )
        end
    }
    ns.metatables.mt_buffs = mt_buffs
end


local mt_default_talent = {
    __index = function( t, k )
        if k == "i_enabled" or k == "rank" then return t.enabled and 1 or 0 end
        return k
    end,
}
ns.metatables.mt_default_talent = mt_default_talent


local null_talent = setmetatable( {
    enabled = false,
}, mt_default_talent )
ns.metatables.null_talent = null_talent

local logged_talent_errors = {}

local mt_talents = {
    __index = function( t, k )
        if class.talents[ k ] == nil and not logged_talent_errors[ k ] and #class.specs > 1 then
            Hekili:Error( "Unknown talent in [ " .. state.scriptID .. " ]: " .. k .. "\n\n" .. debugstack() )
            logged_talent_errors[ k ] = true
        end
        return ( null_talent )
    end,

    __newindex = function( t, k, v )
        if type( v ) == "table" then
            rawset( t, k, setmetatable( v, mt_default_talent ) )
            return
        end
        rawset( t, k, v )
    end,
}
ns.metatables.mt_talents = mt_talents


local function IslandPvP()
    local _, instanceType, difficulty = GetInstanceInfo()
    return instanceType == "scenario" and difficulty == 45
end

local mt_default_pvptalent = {
    __index = function( t, k )
        local enlisted = state.bg or state.arena or state.buff.enlisted.up or IslandPvP()

        if k == "enabled" then return enlisted and rawget( t, "_enabled" ) or false
        elseif k == "_enabled" then return false
        elseif k == "i_enabled" or k == "rank" then return enlisted and rawget( t, "_enabled" ) and 1 or 0 end

        return k
    end,
}


local null_pvptalent = setmetatable( {
    _enabled = false
}, mt_default_pvptalent )


local mt_pvptalents = {
    __index = function( t, k )
        return null_pvptalent
    end,

    __newindex = function( t, k, v )
        rawset( t, k, setmetatable( v, mt_default_pvptalent ) )
    end,
}


do
    local mt_default_gen_trait = {
        __index = function( t, k )
            if k == "enabled" or k == "minor" or k == "equipped" then
                return t.rank and t.rank > 0
            elseif k == "time_value" then
                local mod = t.mod

                if mod >= 1000 or mod <= -1000 then
                    return mod / 1000
                end

                return mod
            elseif k == "disabled" then
                return not t.rank or t.rank == 0
            end
        end
    }
    ns.metatables.mt_default_gen_trait = mt_default_gen_trait

    local mt_generic_traits = {
        __index = function( t, k )
            return t.no_trait
        end,

        __newindex = function( t, k, v )
            rawset( t, k, setmetatable( v, mt_default_gen_trait ) )
            return t[ k ]
        end
    }
    ns.metatables.mt_generic_traits = mt_generic_traits

    setmetatable( state.legendary, mt_generic_traits )
    state.legendary.no_trait = { rank = 0 }



    -- Azerite and Essences.
    local mt_default_trait = {
        __index = function( t, k )
            if not state.azerite.active then
                if k == "enabled" or k == "equipped" or k == "major" or k == "minor" then
                    return false
                elseif k == "disabled" then
                    return true
                end
                return 0
            end

            if k == "enabled" or k == "equipped" then
                return t.__rank and t.__rank > 0
            elseif k == "disabled" then
                return not t.__rank or t.__rank == 0
            elseif k == "rank" then
                return t.__rank or 0
            elseif k == "major" then
                return t.__major or false
            elseif k == "minor" then
                return t.__minor or false
            end
        end
    }


    local HEART_OF_AZEROTH_ITEM_ID = 158075

    local mt_artifact_traits = {
        __index = function( t, k )
            if k == "active" then
                local neck = GetInventoryItemID( "player", INVSLOT_NECK )
                if not neck or neck ~= HEART_OF_AZEROTH_ITEM_ID then
                    rawset( t, "active", false )
                    return false
                end

                local item = C_AzeriteItem.FindActiveAzeriteItem()
                rawset( t, "active", item and item:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled( item ) )
                return t.active
            end

            return t.no_trait
        end,

        __newindex = function( t, k, v )
            if v ~= nil then rawset( t, k, setmetatable( v, mt_default_trait ) ) end
        end
    }

    ns.metatables.mt_artifact_traits = mt_artifact_traits

    setmetatable( state.azerite, mt_artifact_traits )
    state.azerite.no_trait = { rank = 0 }
    state.artifact = state.azerite

    setmetatable( state.essence, ns.metatables.mt_artifact_traits )
    state.essence.no_trait = { rank = 0, major = false, minor = false }

    -- DF: essence.X will be used for Evoker resources.
    -- The state metatable will redirect essence -> bfa_essence for non-Evokers.
    state.bfa_essence = state.essence
    rawset( state, "essence", nil )
end


do
    local db = scripts.DB

    -- Args table, make it nicer.
    setmetatable( state.args, {
        __index = function( t, k )
            -- No script selected.
            if not state.scriptID then return end

            local script = db[ state.scriptID ]

            -- No script by that name.
            if not script then return end

            -- Script has no modifiers.
            if not script.Modifiers then return end

            local mod = script.Modifiers[ k ]

            if mod then
                local s, val = pcall( mod )
                if s then return val end
            end
        end,
    } )
end


-- Table for counting active dots.
local mt_active_dot = {
    __index = function(t, k)
        local aura = class.auras[ k ]

        if aura then
            if rawget( t, aura.key ) then return t[ aura.key ] end
            local id = aura.id
            local count = ns.numDebuffs( id )

            if aura.copy then
                if type( aura.copy ) == "table" then
                    for _, v in ipairs( aura.copy ) do
                        if type(v) == "number" and v > 0 and v ~= id then

                            count = count + ns.numDebuffs( v )
                        end
                    end
                elseif type( aura.copy ) == "number" and aura.copy > 0 and aura.copy ~= id then
                    count = count + ns.numDebuffs( aura.copy )
                end
            end

            t[ k ] = count
            return t[ k ]
        else
            return 0

        end
    end,
    __newindex = function( t, k, v )
        if v == nil then return end
        Mark( t, k )
        rawset( t, k, v )
    end
}
ns.metatables.mt_active_dot = mt_active_dot


-- Table of default handlers for a totem. Under-implemented at the moment.
-- Needs review.
local mt_default_totem = {
    __index = function(t, k)
        if k == "expires" then
            local _, name, start, duration = GetTotemInfo( t.totem )

            t.name = name
            t.expires = ( start or 0 ) + ( duration or 0 )

            return t[ k ]

        elseif k == "up" or k == "active" or k == "alive" then
            return ( t.expires > ( state.query_time ) )

        elseif k == "remains" then
            if t.expires > ( state.query_time ) then
                return ( t.expires - ( state.query_time ) )
            else
                return 0
            end

        end

        Error( "UNK: totem." .. name or "no_name" .. "." .. k )
    end,
    __newindex = function( t, k, v )
        if v == nil then return end
        Mark( t, k )
        rawset( t, k, v )
    end
}
Hekili.mt_default_totem = mt_default_totem


-- Table of totems. Currently Shaman-centric.
-- Needs review.
local mt_totem = {
    __index = function(t, k)
        if k == "fire" then
            local _, name, start, duration = GetTotemInfo(1)

            t[k] = {
            key = k, totem = 1, name = name, expires = (start + duration) or 0, }
            return t[k]

        elseif k == "earth" then
            local _, name, start, duration = GetTotemInfo(2)

            t[k] = {
            key = k, totem = 2, name = name, expires = (start + duration) or 0, }
            return t[k]

        elseif k == "water" then
            local _, name, start, duration = GetTotemInfo(3)

            t[k] = {
            key = k, totem = 3, name = name, expires = (start + duration) or 0, }
            return t[k]

        elseif k == "air" then
            local _, name, start, duration = GetTotemInfo(4)

            t[k] = {
            key = k, totem = 4, name = name, expires = (start + duration) or 0, }
            return t[k]
        end

        if state.pet[ k ] ~= nil then return state.pet[ k ] end

        Error( "UNK: totem." .. k )
    end,
    __newindex = function( t, k, v )
        rawset( t, k, setmetatable( v, mt_default_totem ) )
    end
}
ns.metatables.mt_totem = mt_totem


do
    local db = {}
    local cache = {}
    local pathState = {}

    state.varDB = db
    -- state.varCache = cache
    state.varPaths = pathState


    local entryPool = {}

    function state:RegisterVariable( key, scriptID, list, preconditions )
        db[ key ] = db[ key ] or {}
        local data = db[ key ]

        cache[ key ] = cache[ key ] or {}

        local fullPath = scriptID

        local entry = remove( entryPool ) or {
            mustPass = {},
            -- mustFail = {}
        }

        entry.id = scriptID
        entry.list = list

        if preconditions then
            for i, prereq in ipairs( preconditions ) do
                local script = prereq.script
                if script ~= 0 then
                    insert( entry.mustPass, script )
                    fullPath = fullPath .. "+" .. script
                end
            end
        end

        --[[ if preclusions then
            for i, block in ipairs( preclusions ) do
                local script = block.script
                if script ~= 0 then
                    insert( entry.mustFail, script )
                    fullPath = fullPath .. "-" .. script
                end
            end
        end ]]

        entry.fullPath = fullPath
        insert( data, entry )
    end


    function state:PurgeListVariables( list )
        for variable, data in pairs( db ) do
            for i = #data, 1, -1 do
                if data[ i ].list == list then
                    local item = remove( data, i )
                    wipe( item.mustPass )
                    insert( entryPool, item )
                    wipe( cache[ variable ] )
                end
            end
        end
    end


    function state:ResetVariables()
        for k, v in pairs( db ) do
            for i = #v, 1, -1 do
                local x = remove( v, i )
                wipe( x.mustPass )
                -- wipe( x.mustFail )
                insert( entryPool, x )
            end
            wipe( cache[ k ] )
            wipe( self.variable )
        end

        wipe( pathState )
    end


    function state:GetVariableIDs( key )
        return db[ key ]
    end


    local defaultValue = 0

    function state:SetDefaultVariable( value )
        if value == nil then value = 0 end
        defaultValue = value
    end


    state.variable = setmetatable( {
    }, {
        __index = function( t, var )
            local debug = Hekili.ActiveDebug

            if class.variables[ var ] then
                return class.variables[ var ]()
            end

            local now = state.query_time

            if Hekili.LoadingScripts then
                return defaultValue
            end

            if not db[ var ] then
                if debug then Hekili:Debug( "No such variable '%s'.", var ) end
                Hekili:Error( "Variable '%s' referenced in %s but is undefined.", var, state.scriptID )
                return defaultValue
            end

            state.variable[ var ] = defaultValue

            local data = db[ var ]
            local parent = state.scriptID

            -- If we're checking variable with no script loaded, don't bother.
            if not parent or parent == "NilScriptID" then return 0 end

            local value = defaultValue

            local which_mod = "value"

            for i, entry in ipairs( data ) do
                local scriptID = entry.id
                local currPath = entry.fullPath .. ":" .. now

                -- Check the requirements/exclusions in the APL stack.
                if pathState[ currPath ] == nil then
                    pathState[ currPath ] = true

                    for r, prereq in ipairs( entry.mustPass ) do
                        state.scriptID = prereq
                        if not scripts:CheckScript( prereq ) then
                            pathState[ currPath ] = false
                            break
                        end
                    end

                    --[[ if pathState[ currPath ] then
                        for e, excl in ipairs( entry.mustFail ) do
                            state.scriptID = excl
                            if scripts:CheckScript( excl ) then
                                pathState[ currPath ] = false
                                break
                            end
                        end
                    end ]]
                end

                if pathState[ currPath ] then
                    local pathKey = currPath .. "-" .. i

                    if cache[ var ][ pathKey ] ~= nil then
                        value = cache[ var ][ pathKey ]

                    else
                        state.scriptID = scriptID
                        local op = state.args.op or "set"

                        local passed = scripts:CheckScript( scriptID )

                        local conditions = "(none)"
                        local valueString = "(none)"

                        --[[    add = "Add Value",
                                ceil
                                x default = "Set Default Value",
                                div = "Divide Value",
                                floor
                                max = "Maximum Value",
                                min = "Minimum Value",
                                mod = "Modulo Value",
                                mul = "Multiply Value",
                                pow = "Raise Value to X Power",
                                x reset = "Reset to Default",
                                x set = "Set Value",
                                x setif = "Set Value If...",
                                sub = "Subtract Value" ]]

                        if op == "set" or op == "setif" then
                            if passed then
                                local v1 = state.args.value
                                if v1 ~= nil then value = v1
                                else value = state.args.default end
                            else
                                local v2 = state.args.value_else
                                if v2 ~= nil then
                                    value = v2
                                    which_mod = "value_else"
                                end
                            end

                        elseif op == "reset" then
                            if passed then
                                local v = state.args.value
                                if v == nil then v = state.args.default end
                                if v == nil then v = 0 end
                                value = v
                            end

                        elseif passed then
                            -- Math Ops.
                            local currType = type( value )

                            if currType == "number" then
                                -- Operations on existing value.
                                if op == "floor" then
                                    value = floor( value )
                                elseif op == "ceil" then
                                    value = ceil( value )
                                else
                                    -- Operations with two values.
                                    local newVal = state.args.value
                                    local valType = type( newVal )

                                    if valType == "number" then
                                        if op == "add" then
                                            value = value + newVal
                                        elseif op == "div" then
                                            if newVal == 0 then value = 0
                                            else value = value / newVal end
                                        elseif op == "max" then
                                            value = max( value, newVal )
                                        elseif op == "min" then
                                            value = min( value, newVal )
                                        elseif op == "mod" then
                                            if newVal == 0 then value = 0
                                            else value = value % newVal end
                                        elseif op == "mul" then
                                            value = value * newVal
                                        elseif op == "pow" then
                                            value = value ^ newVal
                                        elseif op == "sub" then
                                            value = value - newVal
                                        end
                                    end
                                end
                            end
                        end

                        -- Cache the value in case it is an intermediate value (i.e., multiple calculation steps).
                        if debug then
                            conditions = format( "%s: %s", passed and "PASS" or "FAIL", scripts:GetConditionsAndValues( scriptID ) )
                            valueString = format( "%s: %s", state.args.value ~= nil and tostring( state.args.value ) or "nil", scripts:GetModifierValues( "value", scriptID ) )

                            Hekili:Debug( var .. " #" .. i .. " [" .. scriptID .. "]; conditions = " .. conditions .. "\n - value = " .. valueString )
                        end
                        state.variable[ var ] = value
                        cache[ var ][ pathKey ] = value
                    end
                end
            end

            -- Clear cache and clear the flag that we are checking this variable already.
            state.variable[ var ] = nil

            --[[ if debug then
                Hekili:Debug( "%s Result = %s.", var, tostring( value ) )
            end ]]

            state.scriptID = parent

            return value
        end
    } )
end



-- Table of set bonuses. Some string manipulation to honor the SimC syntax.
-- Currently returns 1 for true, 0 for false to be consistent with SimC conditionals.
-- Won't catch fake set names. Should revise.
local mt_set_bonuses = {
    __index = function(t, k)
        if type(k) == "number" then return 0 end

        -- if ( not class.artifacts[ k ] ) and ( state.bg or state.arena ) then return 0 end

        local set, pieces, class = k:match("^(.-)_"), tonumber( k:match("_(%d+)pc") ), k:match("pc(.-)$")

        if not pieces or not set then
            -- This wasn't a tier set bonus.
            return 0

        else
            if class then set = set .. class end

            if not t[set] then
                return 0
            end

            return t[set] >= pieces and 1 or 0
        end

        return 0

    end
}
ns.metatables.mt_set_bonuses = mt_set_bonuses


local mt_equipped = {
    __index = function(t, k)
        -- if not class.artifacts[ k ] and ( state.bg or state.arena ) then return false end
        return state.set_bonus[k] > 0 or state.legendary[k].rank > 0
    end
}
ns.metatables.mt_equipped = mt_equipped


-- Aliases let a single buff name refer to any of multiple buffs.
-- Developed mainly for RtB; it will also report "stack" or "count" as the sum of stacks of multiple buffs.
local mt_alias_debuff

do
    local autoReset = setmetatable( {
        applied = 1,
        caster = 1,
        count = 1,
        -- duration = 1,
        expires = 1,
        last_application = 1,
        last_expiry = 1,
        lastApplied = 1,
        lastCount = 1,
        name = 1,
        timeMod = 1,
        unit = 1,
        v1 = 1,
        v2 = 1,
        v3 = 1,
    }, {
        __index = function( t, k )
            if class.knownAuraAttributes[ k ] ~= nil then return 1 end
        end,
    } )

    mt_alias_debuff = {
        __index = function( t, k )
            local aura = class.auras[ t.key ]
            local type = aura.aliasType or "debuff"

            if aura.meta and aura.meta[ k ] then return aura.meta[ k ]() end

            if k == "count" or k == "stack" or k == "stacks" then
                local n = 0

                if type == "any" then
                    for i, child in ipairs( aura.alias ) do
                        if state.buff[ child ].up then n = n + max( 1, state.buff[ child ].stack ) end
                        if state.debuff[ child ].up then n = n + max( 1, state.debuff[ child ].stack ) end
                    end
                else
                    for i, child in ipairs( aura.alias ) do
                        if state[ type ][ child ].up then n = n + max( 1, state[ type ][ child ].stack ) end
                    end
                end

                return n
            end

            local alias
            local mode = aura.aliasMode or "first"

            for i, v in ipairs( aura.alias ) do
                local child

                if type == "any" then
                    child = state.buff[ v ].up and state.buff[ v ] or state.debuff[ v ]
                else
                    child = state.debuff[ v ]
                end

                if not alias and mode == "first" and child.up then return child[ k ] end

                if child.up then
                    if mode == "shortest" and ( not alias or child.remains < alias.remains ) then alias = child
                    elseif mode == "longest" and ( not alias or child.remains > alias.remains ) then alias = child end
                end
            end

            if type == "any" then type = "debuff" end

            if alias then return alias[ k ]
            else return state[ type ][ aura.alias[1] ][ k ] end
        end,
        __newindex = function( t, k, v )
            if v == nil then return end
            class.knownAuraAttributes[ k ] = true
            if autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
end


local default_debuff_values = {
    name = "no_name",
    count = 0,
    lastCount = 0,
    lastApplied = 0,
    expires = 0,
    applied = 0,
    -- duration = 15,
    caster = "nobody",
    timeMod = 1,
    v1 = 0,
    v2 = 0,
    v3 = 0,
    unit = "target"
}


local cycle_debuff = {
    name = "cycle",
    count = 0,
    lastCount = 0,
    lastApplied = 0,
    expires = 0,
    applied = 0,
    -- duration = 0,
    caster = "nobody",
    timeMod = 1,
    v1 = 0,
    v2 = 0,
    v3 = 0,
    unit = "target",

    down = true,
    i_up = 0,
    rank = 0,
    react = 0,
    refreshable = true,
    remains = 0,
    stack = 0,
    stack_pct = 0,
    tick_time_remains = 0,
    ticking = false,
    ticks = 0,
    ticks_remain = 0,
    time_to_refresh = 0,
    up = false,
}


-- Table of default handlers for debuffs.
-- Needs review.
local mt_default_debuff, mt_debuffs

do
    local autoReset = {
        applied = 1,
        caster = 1,
        count = 1,
        -- duration = 1,
        expires = 1,
        lastApplied = 1,
        lastCount = 1,
        name = 1,
        timeMod = 1,
        unit = 1,
        v1 = 1,
        v2 = 1,
        v3 = 1,
    }

    mt_default_debuff = {
        mtID = "default_debuff",

        __index = function( t, k )
            local aura = class.auras[ t.key ]

            if state.IsCycling() and state.active_dot[ t.key ] < state.cycle_enemies and cycle_debuff[ k ] ~= nil then
                return cycle_debuff[ k ]
            end

            if aura and rawget( aura, "meta" ) and aura.meta[ k ] then
                if not t.metastack[ k ] then
                    t.metastack[ k ] = true
                    local value = aura.meta[ k ]( t, "debuff" )
                    t.metastack[ k ] = nil
                    if value ~= nil then return value end
                end

            elseif requiresLookup[ k ] then
                if aura and aura.generate then
                    for attr, a_val in pairs( default_debuff_values ) do
                        t[ attr ] = rawget( t, attr ) or rawget( aura, attr ) or  a_val
                    end

                    aura.generate( t, "debuff" )
                    t.id = aura and aura.id or t.key

                    return rawget( t, k )
                end

                local real = auras.target.debuff[ t.key ] or auras.player.debuff[ t.key ]
                if aura and aura.shared and auras[ aura.shared ] then
                    real = auras.player.debuff[ t.key ]
                end

                if real then
                    t.name = real.name or t.key
                    t.count = real.count
                    t.lastCount = real.lastCount or 0
                    t.lastApplied = real.lastApplied or 0
                    -- t.duration = real.duration
                    t.expires = real.expires or 0
                    t.applied = real.applied or 0
                    t.caster = real.caster
                    t.id = real.id
                    t.timeMod = real.timeMod
                    t.v1 = real.v1
                    t.v2 = real.v2
                    t.v3 = real.v3

                    t.unit = real.unit
                else
                    for attr, a_val in pairs( default_debuff_values ) do
                        t[ attr ] = aura and aura[ attr ] or a_val
                    end

                    t.id = aura and aura.id or t.id
                end

                return rawget( t, k )

            elseif k == "up" or k == "ticking" then
                return t.remains > 0

            elseif k == "i_up" or k == "rank" then
                return t.up and 1 or 0

            elseif k == "down" then
                return t.remains == 0

            elseif k == "duration" then
                return ( t.remains > 0 and t.expires - t.applied ) or aura.duration or 30

            elseif k == "remains" then
                return t.applied <= state.query_time and max( 0, t.expires - state.query_time ) or 0

            elseif k == "refreshable" then
                local tr = t.remains
                return tr == 0 or tr < 0.3 * ( aura.duration or 30 )

            elseif k == "time_to_refresh" then
                return t.up and max( 0, 0.01 + t.remains - ( 0.3 * ( aura.duration or 30 ) ) ) or 0

            elseif k == "stack" or k == "stacks" or k == "react" then
                if t.remains == 0 then return 0 end
                return t.count

            elseif k == "max_stack" or k == "max_stacks" then
                return max( t.count, aura and aura.max_stack or 1 )

            elseif k == "stack_pct" then
                if t.remains == 0 then return 0 end
                if aura then
                    return ( 100 * t.count / max( aura and aura.max_stack or 1, t.count ) )
                end
                return 100

            elseif k == "value" then
                if t.remains == 0 then return 0 end
                return t.v1 or 0

            elseif k == "stack_value" then
                return t.value * t.stack

            elseif k == "pmultiplier" then
                if t.remains == 0 then return 0 end

                -- Persistent modifier, used by Druids.
                t[ k ] = ns.getModifier( aura.id, state.target.unit )
                return t[ k ]

            elseif k == "ticks" then
                if t.remains == 0 then return 0 end
                return t.duration / t.tick_time - t.ticks_remain

            elseif k == "tick_time" then
                return aura and aura.tick_time or ( 3 * state.haste )

            elseif k == "ticks_remain" then
                return ceil( t.remains / t.tick_time )

            elseif k == "tick_time_remains" then
                if t.remains == 0 then return 0 end
                if not aura.tick_time then return t.remains end
                return aura.tick_time - ( ( query_time - t.applied ) % aura.tick_time )

            else
                if aura and aura[ k ] ~= nil then
                    return aura[ k ]
                end
            end

            Error ( "UNK: debuff." .. t.key .. "." .. k )
        end,
        __newindex = function( t, k, v )
            if v ~= nil and autoReset[ k ] then Mark( t, k ) end
            rawset( t, k, v )
        end
    }
    ns.metatables.mt_default_debuff = mt_default_debuff


    unknown_debuff = setmetatable( {
        key = "unknown_debuff",
        name = "No Name",
        count = 0,
        lastCount = 0,
        lastApplied = 0,
        -- duration = 30,
        expires = 0,
        applied = 0,
        caster = "nobody",
        timeMod = 1,
        v1 = 0,
        v2 = 0,
        v3 = 0,
        unit = "player"
    }, mt_default_debuff )


    -- Table of debuffs applied to the target by the player.
    local debuffs_warned = {}

    mt_debuffs = {
        -- The debuff/ doesn't exist in our table so check the real game state,
        -- and copy it so we don't have to use the API next time.

        __index = function( t, k )
            local aura = class.auras[ k ]

            if aura then
                if k ~= aura.key then
                    t[ aura.key ] = rawget( t, aura.key ) or {
                        key = aura.key,
                        name = aura.name
                    }
                    t[ k ] = t[ aura.key ]
                else
                    t[ k ] = {
                        key = aura.key,
                        name = aura.name
                    }
                end

                if aura.generate then
                    for attr, a_val in pairs( default_debuff_values ) do
                        t[ k ][ attr ] = rawget( t[ k ], attr ) or a_val
                    end
                    aura.generate( t[ k ], "debuff" )
                    return t[ k ]
                end

            else
                if Hekili.PLAYER_ENTERING_WORLD and not debuffs_warned[ k ] then
                    Hekili:Error( "Unknown debuff in [" .. ( state.scriptID or "unknown" ) .. "]: " .. k .. "\n\n" .. debugstack() )
                    debuffs_warned[ k ] = true
                end

                t[ k ] = {
                    key = k,
                    name = k,
                    id = k
                }
            end

            local real = auras.player.debuff[ k ] or auras.target.debuff[ k ]
            local debuff = t[k]

            if real then
                debuff.name = real.name
                debuff.count = real.count
                debuff.lastCount = real.lastCount or 0
                debuff.lastApplied = real.lastApplied or 0
                -- debuff.duration = real.duration
                debuff.expires = real.expires
                debuff.applied = real.applied
                debuff.caster = real.caster
                debuff.id = real.id
                debuff.timeMod = real.timeMod
                debuff.v1 = real.v1
                debuff.v2 = real.v2
                debuff.v3 = real.v3

                debuff.unit = real.unit

            else
                debuff.name = aura and aura.name or "No Name"
                debuff.count = 0
                debuff.lastCount = 0
                debuff.lastApplied = 0
                -- debuff.duration = aura and aura.duration or 30
                debuff.expires = 0
                debuff.applied = 0
                debuff.caster = "nobody"
                -- debuff.id = nil
                debuff.timeMod = 1
                debuff.v1 = 0
                debuff.v2 = 0
                debuff.v3 = 0

                debuff.unit = aura and aura.unit or "player"
            end

            t[k] = debuff
            return t[ k ]
        end,

        __newindex = function( t, k, v )
            local aura = class.auras[ k ]

            if aura then
                aura.used = true
                if aura.meta then rawset( v, "metastack", {} ) end
                if aura.alias then
                    rawset( t, k, setmetatable( v, mt_alias_debuff ) )
                    return
                end
            end

            rawset( t, k, setmetatable( v, mt_default_debuff ) )
        end
    }
    ns.metatables.mt_debuffs = mt_debuffs
end


-- Table of default handlers for actions.
-- Needs review.
local mt_default_action = {
    __index = function( t, k )
        local ability = t.action and class.abilities[ t.action ]
        local aura = ability and ability.aura or t.action

        if k == "enabled" or k == "known" then
            return state:IsKnown( t.action )

        elseif k == "disabled" then
            return state:IsDisabled( t.action )

        elseif k == "gcd" then
            local queued_action = state.this_action
            state.this_action = t.action

            local value = state.gcd.execute
            state.this_action = queued_action

            return value

        elseif k == "execute_time" then
            local queued_action = state.this_action
            state.this_action = t.action

            local value = state.gcd.execute
            state.this_action = queued_action

            return max( value, t.cast_time )

        elseif k == "charges" then
            return state.cooldown[ t.action ].charges

        elseif k == "charges_fractional" then
            return state.cooldown[ t.action ].charges_fractional

        elseif k == "recharge_time" then
            return state.cooldown[ t.action ].recharge_time

        elseif k == "max_charges" then
            return ability.charges or 0

        elseif k == "time_to_max_charges" or k == "full_recharge_time" then
            return state.cooldown[ t.action ].full_recharge_time

        elseif k == "ready_time" then
            return state:IsUsable( t.action ) and state:TimeToReady( t.action ) or 999

        elseif k == "ready" then
            return state:IsUsable( t.action ) and state:IsReady( t.action )

        elseif k == "cast_time" then
            return ability.cast

        elseif k == "cooldown" then
            return ability.cooldown

        elseif k == "damage" then
            return ability.damage or 1

        elseif k == "crit_pct_current" then
            return ability.critical or state.stat.crit

        elseif k == "ticking" then
            return ( state.dot[ aura ].ticking )

        elseif k == "ticks" then
            return 1 + ( state.dot[ aura ].duration or ( 30 * state.haste ) / class.auras[ aura ].tick_time or ( 3 * state.haste ) ) - t.ticks_remain

        elseif k == "ticks_remain" then
            return state.dot[ aura ].remains / ( class.auras[ aura ].tick_time or ( 3 * state.haste ) )

        elseif k == "remains" then
            return ( state.dot[ aura ].remains )

        elseif k == "tick_time" then
            return class.auras[ aura ].tick_time or ( 3 * state.haste )

        elseif k == "travel_time" then
            -- NYI: maybe capture the last travel time for the spell and use that?
            local f, v = ability.flightTime, ability.velocity
            if f then return f end
            if v and v > 0 then return state.target.maxR / v end
            return 0

        elseif k == "miss_react" then
            return false

        elseif k == "cooldown_react" then
            return state.cooldown[ t.action ].remains == 0

        elseif k == "cast_delay" then
            return 0

        elseif k == "cast_regen" then
            local regen = t.regen
            if regen == 0.001 then regen = 0 end

            return floor( max( state.gcd.execute, t.cast_time ) * regen ) - t.cost

        elseif k == "cost" then
            if ability then
                local c = ability.cost

                if c then return c end

                c = ability.spend

                if c and c > 0 and c < 1 then
                    c = c * state[ ability.spendType or class.primaryResource ].modmax
                end

                return c or 0
            end

            return 0

        elseif k == "cost_type" then
            local a, _ = ability.spendType
            if type( a ) == "string" then return a end

            a = ability.spend
            if type( a ) == "function" then _, a = a() end
            if type( a ) == "string" then return a end
            return class.primaryResource

        elseif k == "in_flight" then
            if ability.flightTime then
                return ability.lastCast + max( ability.flightTime, 0.25 ) > state.query_time
            end

            return state:IsInFlight( t.action ) or ability.isProjectile and ability.lastCast + 0.25 > state.query_time

        elseif k == "in_flight_remains" then
            if ability.flightTime then

                return max( 0, ability.lastCast + max( ability.flightTime, 0.25 ) - state.query_time )
            end
            return max( state:InFlightRemains( t.action ), ability.isProjectile and ability.lastCast + 0.25 - state.query_time or 0 )

        elseif k == "channeling" then
            return state:IsChanneling( t.action )

        elseif k == "channel_remains" then
            return state:IsChanneling( t.action ) and state:QueuedCastRemains( t.action ) or 0

        elseif k == "executing" then
            return state:IsCasting( t.action ) or ( state.prev[ 1 ][ t.action ] and state.gcd.remains > 0 )

        elseif k == "execute_remains" then
            return ( state:IsCasting( t.action ) and max( state:QueuedCastRemains( t.action ), state.gcd.remains ) ) or ( state.prev[1][ t.action ] and state.gcd.remains ) or 0

        elseif k == "last_used" then
            return state.combat > 0 and max( 0, ability.lastCast - state.combat ) or 0

        elseif k == "time_since" then
            return min( 3600, max( 0, state.query_time - ability.lastCast ) )

        elseif k == "in_range" then
            if UnitExists( "target" ) and UnitCanAttack( "player", "target" ) and LSR.IsSpellInRange( ability.rangeSpell or ability.id, "target" ) == 0 then
                return false
            end

            return true

        elseif k == "cycle" then
            return ability.cycle == "cycle"

        else
            local val = ability[ k ]

            if val ~= nil then
                if type( val ) == "function" then return val() end
                return val
            end
        end

        return 0
    end
}
ns.metatables.mt_default_action = mt_default_action


-- mt_actions: provides action information for display/priority queue/action criteria.
-- NYI.
local mt_actions = {
    __index = function(t, k)
        local action = class.abilities[ k ]

        -- Need a null_action table.
        if not action then return nil end

        t[k] = {
            action = k,
            name = action.name,
            gcdType = action.gcd
        }

        local h = state.haste
        state.haste = 0
        t[k].base_cast = action.cast
        state.haste = h

        return ( t[k] )
        end, __newindex = function(t, k, v)
        rawset( t, k, setmetatable( v, mt_default_action ) )
    end
}
ns.metatables.mt_actions = mt_actions



-- mt_swings: used for projecting weapon swing-based resource gains.
local mt_swings = {
    __index = function( t, k )
        if k == "mainhand" then
            return t.mh_pseudo or t.mh_actual

        elseif k == "offhand" then
            return t.oh_pseudo or t.oh_actual

        elseif k == "mainhand_speed" then
            return t.mh_pseudo_speed or t.mh_speed or 0

        elseif k == "offhand_speed" then
            return t.oh_pseudo_speed or t.oh_speed or 0

        end
    end
}


state.swing = {}

local mt_swing_timer = {
    __index = function( t, k )
        local speed = state.swings[ t.type .. "_speed" ]
        if speed == 0 then return 999 end

        local swing = state.time == 0 and state.now or state.swings.mainhand
        if swing == 0 then return speed end

        -- Technically, we didn't even check if this were "remains" but there are no other symbols.
        local t = state.query_time
        return swing + ( ceil( ( t - swing ) / speed ) * speed ) - t
    end,
}

state.swing.mh = setmetatable( { type = "mainhand" }, mt_swing_timer )
state.swing.mainhand = state.swing.mh
state.swing.main_hand = state.swing.mh

state.swing.oh = setmetatable( { type = "offhand" }, mt_swing_timer )
state.swing.offhand = state.swing.oh
state.swing.off_hand = state.swing.oh


local mt_weapon_type = {
    __index = function( t, k )
        local size = t.size

        if k == "two_handed" or k == "2h" or k == "two_hand" then
            return size == 2
        elseif k == "one_handed" or k == "1h" or k == "one_hand" then
            return size == 1
        end

        return false
    end,
}


local mt_aura = {
    __index = function( t, k )
        return rawget( state.buff, k ) or rawget( state.debuff, k )
    end
}


local mt_empowering = {
    __index = function( t, k )
        return state.empowerment.active and state.empowerment.spell == k
    end
}


setmetatable( state, mt_state )
setmetatable( state.action, mt_actions )
setmetatable( state.active_dot, mt_active_dot )
setmetatable( state.aura, mt_aura )
setmetatable( state.buff, mt_buffs )
setmetatable( state.cooldown, mt_cooldowns )
setmetatable( state.debuff, mt_debuffs )
setmetatable( state.dot, mt_dot )
setmetatable( state.empowering, mt_empowering )
setmetatable( state.equipped, mt_equipped )
setmetatable( state.main_hand, mt_weapon_type )
setmetatable( state.off_hand, mt_weapon_type )
-- setmetatable( state.health, mt_resource )
setmetatable( state.pet, mt_pets )
setmetatable( state.pet.fake_pet, mt_default_pet )
setmetatable( state.prev, mt_prev )
setmetatable( state.prev_gcd, mt_prev )
setmetatable( state.prev_off_gcd, mt_prev )
setmetatable( state.pvptalent, mt_pvptalents )
setmetatable( state.race, mt_false )
setmetatable( state.set_bonus, mt_set_bonuses )
setmetatable( state.settings, mt_settings )
setmetatable( state.spec, mt_spec )
setmetatable( state.stance, mt_stances )
setmetatable( state.stat, mt_stat )
setmetatable( state.swings, mt_swings )
setmetatable( state.talent, mt_talents )
setmetatable( state.target, mt_target )
setmetatable( state.target.health, mt_target_health )
setmetatable( state.toggle, mt_toggle )
setmetatable( state.totem, mt_totem )



local all = class.specs[ 0 ]

-- 04072017: Let's go ahead and cache aura information to reduce overhead.
local autoAuraKey = setmetatable( {}, {
    __index = function( t, k )
        local aura_name = GetSpellInfo( k )

        if not aura_name then return end

        local name

        if class.auras[ aura_name ] then
            local i = 1

            while( true ) do
                local new = aura_name .. ' ' .. i

                if not class.auras[ new ] then
                    name = new
                    break
                end

                i = i + 1
            end
        end
        name = name or aura_name

        local key = formatKey( aura_name )

        if class.auras[ key ] then
            local i = 1

            while ( true ) do
                local new = key .. "_" .. i

                if not class.auras[ new ] then
                    key = new
                    break
                end

                i = i + 1
            end
        end

        -- Store the aura and save the key if we can.
        if not all then all = class.specs[ 0 ] end
        if all then
            all:RegisterAura( key, {
                id = k,
                name = name
            } )
        end
        t[k] = key

        return t[k]
    end
} )



do
    local UnitAuraBySlot = UnitAuraBySlot

    function state.StoreMatchingAuras( unit, auras, filter, ... )
        local n = auras.count
        auras.count = nil

        local db = ns.auras[ unit ][ filter == "HELPFUL" and "buff" or "debuff" ]

        for k, v in pairs( auras ) do
            local aura = class.auras[ v ]
            local key = aura.key

            local a = db[ key ] or {}

            a.key              = key
            a.name             = nil
            a.lastCount        = a.count or 0
            a.lastApplied      = a.applied or 0
            a.last_application = max( 0, a.applied or 0, a.last_application or 0 )
            a.last_expiry      = max( 0, a.expires or 0, a.last_expiry or 0 )
            a.count            = 0
            a.expires          = 0
            a.applied          = 0
            -- a.duration         = aura.duration or a.duration
            a.caster           = "nobody"
            a.timeMod          = 1
            a.v1               = 0
            a.v2               = 0
            a.v3               = 0
            a.unit             = unit

            db[ key ] = a
        end

        for i = select( "#", ... ), 1, -1 do
            local slot = select( i, ... )
            local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 = UnitAuraBySlot( unit, slot )

            local key = auras[ spellID ]

            if key and name and ( unit == "player" or caster and ( UnitIsUnit( caster, "player" ) or UnitIsUnit( caster, "pet" ) ) ) then
                local a = db[ key ]

                if expires == 0 then
                    expires = GetTime() + 3600
                    duration = 7200
                end

                a.name     = name
                a.count    = count > 0 and count or 1
                -- a.duration = duration
                a.expires  = expires
                a.applied  = expires - duration
                a.caster   = caster
                a.timeMod  = timeMod
                a.v1       = v1
                a.v2       = v2
                a.v3       = v3
                a.v4       = v4
                a.v5       = v5
                a.v6       = v6
                a.v7       = v7
                a.v8       = v8
                a.v9       = v9
                a.v10      = v10

                n = n - 1
                if n == 0 then break end
            end
        end
    end
    Hekili.StoreMatchingAuras = state.StoreMatchingAuras


    function state.ScrapeUnitAuras( unit, newTarget, why )
        local db = ns.auras[ unit ]

        for k,v in pairs( db.buff ) do
            v.name = nil
            v.lastCount = newTarget and 0 or v.count
            v.lastApplied = newTarget and 0 or v.applied

            v.last_application = max( 0, v.applied, v.last_application )
            v.last_expiry  = max( 0, v.expires, v.last_expiry )

            v.count = 0
            v.expires = 0
            v.applied = 0
            -- v.duration = class.auras[ k ] and class.auras[ k ].duration or v.duration
            v.caster = "nobody"
            v.timeMod = 1
            v.v1 = 0
            v.v2 = 0
            v.v3 = 0
            v.unit = unit
        end

        for k,v in pairs( db.debuff ) do
            v.name = nil
            v.lastCount = newTarget and 0 or v.count
            v.lastApplied = newTarget and 0 or v.applied
            v.count = 0
            v.expires = 0
            v.applied = 0
            -- v.duration = class.auras[ k ] and class.auras[ k ].duration or v.duration
            v.caster = "nobody"
            v.timeMod = 1
            v.v1 = 0
            v.v2 = 0
            v.v3 = 0
            v.unit = unit
        end

        state[ unit ].updated = false
        if not UnitExists( unit ) then return end

        local i = 1
        while ( true ) do
            local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitBuff( unit, i )
            if not name then break end

            local aura = class.auras[ spellID ]
            local shared = aura and aura.shared
            local key = aura and aura.key or autoAuraKey[ spellID ]

            if key and ( shared or caster and ( UnitIsUnit( "pet", caster ) or UnitIsUnit( "player", caster ) ) ) then
                db.buff[ key ] = db.buff[ key ] or {}
                local buff = db.buff[ key ]

                if expires == 0 then
                    expires = GetTime() + 3600
                    duration = 7200
                end

                buff.key = key
                buff.id = spellID
                buff.name = name
                buff.count = count > 0 and count or 1
                buff.expires = expires
                -- buff.duration = duration
                buff.applied = expires - duration
                buff.caster = caster
                buff.timeMod = timeMod
                buff.v1 = v1
                buff.v2 = v2
                buff.v3 = v3

                buff.last_application = buff.last_application or 0
                buff.last_expiry      = buff.last_expiry or 0

                buff.unit = unit
            end

            i = i + 1
        end

        i = 1
        while ( true ) do

            local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitDebuff( unit, i )
            if not name then break end

            local aura = class.auras[ spellID ]
            local shared = aura and aura.shared
            local key = aura and aura.key or autoAuraKey[ spellID ]

            if key and ( shared or caster and ( UnitIsUnit( "pet", caster ) or UnitIsUnit( "player", caster ) ) ) then
                db.debuff[ key ] = db.debuff[ key ] or {}
                local debuff = db.debuff[ key ]

                if expires == 0 then
                    expires = GetTime() + 3600
                    duration = 7200
                end

                debuff.key = key
                debuff.id = spellID
                debuff.name = name
                debuff.count = count > 0 and count or 1
                debuff.expires = expires
                -- debuff.duration = duration
                debuff.applied = expires - duration
                debuff.caster = caster
                debuff.timeMod = timeMod
                debuff.v1 = v1
                debuff.v2 = v2
                debuff.v3 = v3

                debuff.unit = unit
            end

            i = i + 1
        end

        if UnitIsUnit( unit, "player" ) and IsInJailersTower() then
            i = 1
            while ( true ) do
                local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitBuff( unit, i, "MAW" )
                if not name then break end

                local aura = class.auras[ spellID ]
                local key = aura and aura.key

                if not key then key = autoAuraKey[ spellID ] end

                if key then
                    db.buff[ key ] = db.buff[ key ] or {}
                    local buff = db.buff[ key ]

                    if expires == 0 then
                        expires = GetTime() + 3600
                        duration = 7200
                    end

                    buff.key = key
                    buff.id = spellID
                    buff.name = name
                    buff.count = count > 0 and count or 1
                    buff.expires = expires
                    -- buff.duration = duration
                    buff.applied = expires - duration
                    buff.caster = caster
                    buff.timeMod = timeMod
                    buff.v1 = v1
                    buff.v2 = v2
                    buff.v3 = v3

                    if aura and buff.count > aura.max_stack then aura.max_stack = buff.count end

                    buff.last_application = buff.last_application or 0
                    buff.last_expiry      = buff.last_expiry or 0

                    buff.unit = unit
                end

                i = i + 1
            end

            i = 1
            while ( true ) do
                local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitDebuff( unit, i, "MAW" )
                if not name then break end

                local aura = class.auras[ spellID ]
                local key = aura and aura.key

                if not key then key = autoAuraKey[ spellID ] end

                if key then
                    db.debuff[ key ] = db.debuff[ key ] or {}
                    local debuff = db.debuff[ key ]

                    if expires == 0 then
                        expires = GetTime() + 3600
                        duration = 7200
                    end

                    debuff.key = key
                    debuff.id = spellID
                    debuff.name = name
                    debuff.count = count > 0 and count or 1
                    debuff.expires = expires
                    -- debuff.duration = duration
                    debuff.applied = expires - duration
                    debuff.caster = caster
                    debuff.timeMod = timeMod
                    debuff.v1 = v1
                    debuff.v2 = v2
                    debuff.v3 = v3

                    if aura and debuff.count > aura.max_stack then aura.max_stack = debuff.count end

                    debuff.unit = unit
                end

                i = i + 1
            end
        end
    end
    Hekili.ScrapeUnitAuras = state.ScrapeUnitAuras

    Hekili:ProfileCPU( "ScrapeUnitAuras", state.ScrapeUnitAuras )

    Hekili.AuraDB = ns.auras
end
local ScrapeUnitAuras = state.ScrapeUnitAuras


-- Helper functions to query the real aura data that has been scraped.
-- Used for snapshotting projectile data to be handled when a spell impacts.
function state.PlayerBuffUp( buff )
    local aura = state.auras.player.buff[ buff ]
    return aura and aura.expires > GetTime()
end

function state.PlayerDebuffUp( debuff )
    local aura = state.auras.player.debuff[ debuff ]
    return aura and aura.expires > GetTime()
end

function state.TargetBuffUp( buff )
    local aura = state.auras.target.buff[ buff ]
    return aura and aura.expires > GetTime()
end

function state.TargetDebuffUp( debuff )
    local aura = state.auras.target.debuff[ debuff ]
    return aura and aura.expires > GetTime()
end


function state.putTrinketsOnCD( val )
    val = val or 10

    for i, item in ipairs( state.items ) do
        if not class.abilities[ item ].essence and not class.abilities[ item ].no_icd and state.cooldown[ item ].remains < val then
            state.setCooldown( item, val )
        end
    end
end


do
    -- Simpler Queue System
    local realQueue = {}
    state.realQueue = realQueue

    local virtualQueue = {}
    state.queue = virtualQueue

    local byTime = function( a, b )
        return a.time < b.time
    end


    local eventPool = {}

    local function NewEvent()
        if #eventPool > 0 then
            return remove( eventPool, 1 )
        end

        return {}
    end

    local function RecycleEvent( queue, i )
        local e = queue[ i ]

        if e then
            e.action = nil
            e.start  = nil
            e.time   = nil
            e.type   = nil
            e.target = nil
            e.func   = nil

            insert( eventPool, e )
            remove( queue, i )
        end
    end

    function state:QueueEvent( action, start, time, type, target, real )
        local queue = real and realQueue or virtualQueue
        local e = NewEvent()

        if not time then
            local ability = class.abilities[ action ]

            if ability then
                if type == "PROJECTILE_IMPACT" then
                    if ability.flightTime then time = start + 0.05 + ability.flightTime
                    else time = start + 0.05 + ( state.target.maxR / ability.velocity ) end

                elseif type == "CHANNEL_START" then
                    time = start

                elseif not time and ( type == "CHANNEL_FINISH" or type == "CAST_FINISH" ) then
                    time = start + ability.cast

                end
            end
        end

        if action and start and time and type then
            if time < start then time = start + time end

            e.action = action
            e.start  = start
            e.time   = time
            e.type   = type
            e.target = target
            e.func   = nil

            insert( queue, e )
            sort( queue, byTime )

            if real then
                queue[ action ] = ( queue[ action ] or 0 ) + 1
            end

            if Hekili.ActiveDebug and not real then Hekili:Debug( "Queued %s from %.2f to %.2f (%s).", action, start, time, type ) end
        end
    end

    Hekili:ProfileCPU( "QueueEvent", state.QueueEvent )

    function state:QueueAuraEvent( action, func, time, eType, data )
        local queue = virtualQueue
        local e = NewEvent()

        if not time then return end

        e.action = action
        e.func   = func
        e.start  = self.query_time
        e.time   = time
        e.type   = eType
        e.target = "nobody"
        e.data   = data

        insert( queue, e )
        sort( queue, byTime )

        if Hekili.ActiveDebug then Hekili:Debug( "Queued %s %s at +%.2f.", action, eType, time - state.query_time ) end
    end

    function state:RemoveAuraEvent( action, eType )
        local queue = virtualQueue
        eType = eType or "AURA_EXPIRATION"

        Hekili:Debug( "Trying to remove %s %s from queue.", action, eType )

        for i = 1, #queue do
            local e = queue[ i ]

            if e.action == action and e.type == eType then
                RecycleEvent( queue, i )
                Hekili:Debug( "Removed #%d from queue.", i )
                break
            end
        end
    end

    function state:QueueAuraExpiration( action, func, time, data )
        self:QueueAuraEvent( action, func, time, "AURA_EXPIRATION", data )
    end

    function state:RemoveAuraExpiration( action )
        self:RemoveAuraEvent( action, "AURA_EXPIRATION" )
    end

    function state:RemoveEvent( e, real )
        local queue = real and realQueue or virtualQueue

        Hekili:Debug( "Trying to remove %s %s from queue.", ( e.action or "NO_ACTION" ), ( e.type or "NO_TYPE" ) )

        for i = #queue, 1, -1 do
            if queue[ i ] == e then
                Hekili:Debug( "Removing %d from queue.", i )
                RecycleEvent( queue, i )

                if real then
                    queue[ action ] = max( 0, ( queue[ action ] or 0 ) - 1 )
                end
                break
            end
        end
    end

    Hekili:ProfileCPU( "RemoveEvent", state.RemoveEvent )

    function state:GetEventInfo( action, start, time, type, target, real )
        local queue = real and realQueue or virtualQueue

        if real and ( queue[ action ] or 0 ) == 0 then return end

        -- Find the first event that matches the provided criteria and return all the data.
        for i, event in ipairs( queue ) do
            if ( not action or event.action == action ) and
               ( not start  or event.start  == start  ) and
               ( not time   or event.time   == time   ) and
               ( not type   or event.type   == type   ) and
               ( not target or event.target == target ) then

               return event.action, event.start, event.time, event.type, event.target
            end
        end
    end

    function state:RemoveSpellEvent( action, real, eType, reverse )
        local queue = real and realQueue or virtualQueue

        local success = false

        if reverse then
            for i = #queue, 1, -1 do
                local e = queue[ i ]

                if e.action == action and ( eType == nil or e.type == eType ) then
                    RecycleEvent( queue, i )
                    if real then
                        queue[ action ] = ( queue[ action ] or 1 ) - 1
                    end
                    return true
                end
            end
        else
            for i = 1, #queue do
                local e = queue[ i ]

                if e.action == action and ( eType == nil or e.type == eType ) then
                    RecycleEvent( queue, i )
                    if real then
                        queue[ action ] = ( queue[ action ] or 0 ) - 1
                    end
                    return true
                end
            end
        end

        return false
    end

    function state:RemoveSpellEvents( action, real, eType )
        local queue = real and realQueue or virtualQueue

        local success = false
        local impactSpells = class.abilities[ action ] and class.abilities[ action ].impactSpells

        for i = #queue, 1, -1 do
            local e = queue[ i ]

            if ( e.action == action or impactSpells and impactSpells[ action ] ) and ( eType == nil or e.type == eType ) then
                RecycleEvent( queue, i )
                if real then
                    queue[ action ] = ( queue[ action ] or 1 ) - 1
                end
                success = true
            end
        end

        if success then
            for k in pairs( class.resources ) do
                forecastResources( k )
            end
        end

        return success
    end


    local EVENT_EXPIRE_MARGIN = 0.2

    function state:ResetQueues()
        for i = #virtualQueue, 1, -1 do
            RecycleEvent( virtualQueue, i )
        end

        local now = GetTime()

        for i = #realQueue, 1, -1 do
            local e = realQueue[ i ]

            if e.time + EVENT_EXPIRE_MARGIN < now then
                RecycleEvent( realQueue, i )
                if e.action then
                    realQueue[ e.action ] = max( 0, ( realQueue[ e.action ] or 1 ) - 1 )
                end
            end
        end

        for i, r in ipairs( realQueue ) do
            local e = NewEvent()

            e.action = r.action
            e.start  = r.start
            e.time   = r.time
            e.type   = r.type
            e.target = r.target

            virtualQueue[ i ] = e
        end
    end


    local times = {}

    function state:GetQueueTimes( queue )
        wipe( times )

        for i, v in ipairs( queue ) do
            times[ i ] = v.time
        end

        return unpack( times )
    end


    function state:GetQueue( real )
        if real then return realQueue end
        return virtualQueue
    end


    function state:HandleEvent( e )
        if not e then return end

        local action = e.action
        local ability
        local curr_action = self.this_action

        if e.type ~= "AURA_EXPIRATION" and e.type ~= "AURA_PERIODIC" then
            ability = class.abilities[ e.action ]

            if not ability then
                state:RemoveEvent( e )
                return
            end

            self.this_action = action
        end

        if Hekili.ActiveDebug then Hekili:Debug( "\nHandling %s at %.2f (%s).", action, e.time, e.type ) end

        if e.type == "CAST_FINISH" then
            self.hardcast = true
            local cooldown = ability.cooldown

            -- Put the action on cooldown. (It's slightly premature, but addresses CD resets like Echo of the Elements.)
            -- if ability.charges and ability.charges > 1 and ability.recharge > 0 then
            if ability.charges and ability.recharge > 0 then
                self.spendCharges( action, 1 )

            elseif action ~= "global_cooldown" then
                self.setCooldown( action, cooldown )
            end

            -- Spend resources.
            ns.spendResources( action )

            local wasCycling = self.IsCycling( nil, true )
            local expires, minTTD, maxTTD, aura

            if wasCycling then
                expires, minTTD, maxTTD, aura = self.GetCycleInfo()
            end

            if e.target and e.target ~= self.target.unit then
                if Hekili.ActiveDebug then Hekili:Debug( "Using ability on a different target." ) end
                self.SetupCycle( ability )
            end

            -- Perform the action.
            self:RunHandler( action )
            self.hardcast = nil
            self.whitelist = nil
            self.removeBuff( "casting" ) -- TODO: Revisit for Casting while Casting scenarios; check Fire Mage.

            if wasCycling then
                self.SetCycleInfo( expires, minTTD, maxTTD, aura )
            else
                self.ClearCycle()
            end

            if ability.item and not ( ability.essence or ability.no_icd ) then
                self.putTrinketsOnCD( cooldown / 6 )
            end

        elseif e.type == "CHANNEL_TICK" then
            if ability.tick then ability.tick() end

        elseif e.type == "CHANNEL_FINISH" then
            if ability.finish then ability.finish() end
            self.whitelist = nil
            self.removeBuff( "casting" )

        elseif e.type == "PROJECTILE_IMPACT" then
            local wasCycling = self.IsCycling( nil, true )
            local expires, minTTD, maxTTD, aura

            if wasCycling then
                expires, minTTD, maxTTD, aura = self.GetCycleInfo()
            end

            if e.target and e.target ~= self.target.unit then
                if Hekili.ActiveDebug then Hekili:Debug( "Using ability on a different target." ) end
                self.SetupCycle( ability )
            end

            if ability.impact then ability.impact() end
            self:StartCombat()

            if wasCycling then
                self.SetCycleInfo( expires, minTTD, maxTTD, aura )
            else
                self.ClearCycle()
            end
        end

        if e.func then e.func( e.data ) end

        state.this_action = curr_action
        state:RemoveEvent( e )
    end

    Hekili:ProfileCPU( "HandleEvent", state.HandleEvent )


    function state:IsQueued( action, real )
        if real and ( realQueue[ action ] or 0 ) == 0 then return false end

        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if entry.action == action then return true end
        end

        return false
    end


    function state:IsInFlight( action, real )
        if real and ( realQueue[ action ] or 0 ) == 0 then return false end

        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if entry.action == action and entry.type == "PROJECTILE_IMPACT" and entry.start <= self.query_time then return true end
        end

        return false
    end


    function state:InFlightRemains( action, real )
        if real and ( realQueue[ action ] or 0 ) == 0 then return 0 end

        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if entry.action == action and entry.type == "PROJECTILE_IMPACT" and entry.start <= self.query_time then return max( 0, entry.time - self.query_time ) end
        end

        return 0
    end


    local cast_events = {
        CAST_FINISH = true,
        CHANNEL_FINISH = true
    }

    function state:IsCasting( action, real )
        if real and ( realQueue[ action ] or 0 ) == 0 then return false end
        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if entry.type == "CAST_FINISH" and ( action == nil or entry.action == action ) and entry.start <= self.query_time then return true end
        end

        return false
    end


    function state:QueuedCastRemains( action, real )
        if real and ( realQueue[ action ] or 0 ) == 0 then return 0 end

        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if cast_events[ entry.type ] and ( action == nil or entry.action == action ) and entry.start <= self.query_time then return max( 0, entry.time - self.query_time ) end
        end

        return 0
    end


    function state:IsChanneling( action, real )
        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if entry.type == "CHANNEL_FINISH" and ( action == nil or entry.action == action ) and entry.start <= self.query_time then return true end
        end

        return false
    end


    function state:ApplyCastingAuraFromQueue( action, real )
        local queue = real and realQueue or virtualQueue

        for i, entry in ipairs( queue ) do
            if cast_events[ entry.type ] and ( action == nil or entry.action == action ) and entry.start <= self.query_time then
                local casting = self.buff.casting

                casting.applied = entry.start

                if entry.time > entry.start then
                    casting.expires = entry.time
                else
                    casting.expires = entry.start + entry.time
                end

                casting.duration = casting.expires - casting.applied

                casting.v3 = entry.type == "CHANNEL_FINISH" and 1 or 0

                if entry.action then
                    local spell = class.abilities[ entry.action ]
                    if spell and spell.id then
                        casting.v1 = spell.id
                    else
                        casting.v1 = 0
                    end
                else
                    casting.v1 = 0
                end

                return
            end
        end
    end
end


function state:RunHandler( key, noStart )
    local ability = class.abilities[ key ]

    if not ability then
        -- ns.Error( "runHandler() attempting to run handler for non-existant ability '" .. key .. "'." )
        return
    end

    --[[ if self.channeling and not ability.dual_cast then
        self.stopChanneling( false, ability.key )
    end ]]

    -- Any ability handler is likely to modify the game state enough to force a reset later.
    if not state.resetting then state.modified = true end

    if ability.channeled then
        if ability.start then ability.start() end
        self.channelSpell( key, self.query_time, ability.cast, ability.id )
    elseif ability.handler then ability.handler() end

    self.prev.last = key
    self[ ability.gcd == "off" and "prev_off_gcd" or "prev_gcd" ].last = key

    table.insert( self.predictions, 1, key )
    table.insert( self[ ability.gcd == "off" and 'predictionsOff' or 'predictionsOn' ], 1, key )

    self.history.casts[ key ] = self.query_time

    self.predictions[11] = nil
    self.predictionsOn[11] = nil
    self.predictionsOff[11] = nil

    self.prev.override = nil
    self.prev_gcd.override = nil
    self.prev_off_gcd.override = nil

    if self.time == 0 and ability.startsCombat and not noStart then -- and not ability.isProjectile
        -- Assume MH swing at combat start and OH swing half a swing later?
        self:StartCombat()
        ns.callHook( "runHandler_startCombat", key )
    end

    -- state.cast_start = 0
    ns.callHook( "runHandler", key )
end

function state.runHandler( key, noStart )
    state:RunHandler( key, noStart )
end


do
    local firstTime = true

    function state.reset( dispName, full )
        full = full or state.offset > 0

        ClearMarks( firstTime )
        firstTime = nil

        state.ClearCycle()
        state:ResetVariables()
        -- This will be our comprehensive resetter.
        state:ResetQueues()

        -- TODO:  Review.  How many of these are necessary?
        state.resetting = true

        ns.callHook( "reset_preauras" )
        Hekili:Yield( "Reset Pre-Auras" )

        if state.target.updated then
            ScrapeUnitAuras( "target" )
            state.target.updated = false
        end

        if state.player.updated then
            ScrapeUnitAuras( "player" )
            state.player.updated = false
        end

        local p = Hekili.DB.profile

        local display = dispName and p.displays[ dispName ]
        local spec = state.spec.id and p.specs[ state.spec.id ]
        local mode = p.toggles.mode.value

        state.display = dispName
        state.filter = "none"
        state.rangefilter = false

        if display then
            if dispName == 'Primary' then
                if mode == "single" or mode == "dual" or mode == "reactive" then state.max_targets = 1
                elseif mode == "aoe" then state.min_targets = spec and spec.aoe or 3 end
                -- if state.empowerment.active then state.filter = "empowerment" end
            elseif dispName == 'AOE' then
                state.min_targets = spec and spec.aoe or 3
                -- if state.empowerment.active then state.filter = "empowerment" end
            elseif dispName == 'Cooldowns' then state.filter = "cooldowns"
            elseif dispName == 'Interrupts' then state.filter = "interrupts"
            elseif dispName == 'Defensives' then state.filter = "defensives"
            end

            state.rangefilter = display.range.enabled and display.range.type == "xclude"
        end

        -- Trying again to have partial resets for the low-impact (single icon displays).
        if not full then
            state.resetting = false
            return
        end

        -- TODO: Determine if we can Mark/Purge these tables instead of having their own resets.
        for k in pairs( class.stateTables ) do
            if rawget( state[ k ], "onReset" ) then state[ k ].onReset( state[ k ] ) end
        end

        Hekili:Yield( "Reset Post-States" )

        for i = 1, 5 do
            local _, _, start, duration, icon = GetTotemInfo(i)

            if icon and class.totems[ icon ] then
                summonPet( class.totems[ icon ], start + duration - state.now )
            end
        end

        -- TODO: These could be cleaner but also it doesn't matter.
        wipe( state.predictions )
        wipe( state.predictionsOn )
        wipe( state.predictionsOff )
        wipe( state.history.casts )
        wipe( state.history.units )

        if state.time == 0 and InCombatLockdown() then
            local a = state.player.lastcast and class.abilities[ state.player.lastcast ]
            if a and a.startsCombat and state.now - a.lastCast < 1 then
                state.false_start = a.lastCast - 0.01
                if Hekili.ActiveDebug then Hekili:Debug( format( "Starting combat based on %s cast; time is now: %.2f.", state.player.lastcast, state.time ) ) end
            end
        end

        local foundResource = false

        Hekili:Yield( "Reset Pre-Powers" )

        for k, power in pairs( class.resources ) do
            local res = rawget( state, k )

            if res then
                res.actual = UnitPower( "player", power.type )
                res.max = UnitPowerMax( "player", power.type )

                if res.max > 0 then foundResource = true end

                if k == "mana" and state.spec.arcane then
                    res.modmax = res.max / ( 1 + state.mastery_value )
                end

                res.last_tick = rawget( res, "last_tick" ) or 0
                res.tick_rate = rawget( res, "tick_rate" ) or 0.1

                if power.type == Enum.PowerType.Mana then
                    local inactive, active = GetManaRegen()

                    res.active_regen = active or 0
                    res.inactive_regen = inactive or 0
                    res.regen = nil
                else
                    if ResourceRegenerates( k ) then
                        local inactive, active = GetPowerRegenForPowerType( power.type )
                        res.active_regen = active or 0.001
                        res.inactive_regen = inactive or 0.001
                        res.regen = nil
                    else
                        res.regen = 0.001
                    end
                end

                if res.reset then res.reset() end
                forecastResources( k )
            end
        end

        if not foundResource then
            state.resetting = false
            return false, "no available resources"
        end

        Hekili:Yield( "Reset Post-Powers" )

        -- Setting this here because the metatable would pull from UnitPower.
        if not state.health.initialized then
            state.health.resource = "health"
            state.health.meta = {}
            state.health.percent = nil
            setmetatable( state.health, mt_resource )
            state.health.initialized = true
        end
        state.health.current = nil
        state.health.actual = UnitHealth( "player" ) or 10000
        state.health.max = max( 1, UnitHealthMax( "player" ) or 10000 )
        state.health.regen = 0.001

        -- TODO: All of this stuff for swings is terrible.
        state.swings.mh_speed, state.swings.oh_speed = UnitAttackSpeed( "player" )
        state.swings.mh_speed = state.swings.mh_speed or 0
        state.swings.oh_speed = state.swings.oh_speed or 0

        state.mainhand_speed = state.swings.mh_speed or 0
        state.offhand_speed = state.swings.oh_speed or 0

        state.nextMH = ( state.combat > 0 and state.swings.mh_actual > state.combat and state.swings.mh_actual + state.mainhand_speed ) or 0
        state.nextOH = ( state.combat > 0 and state.swings.oh_actual > state.combat and state.swings.oh_actual + state.offhand_speed ) or 0

        state.swings.mh_pseudo = nil
        state.swings.oh_pseudo = nil

        -- Special case spells that suck.
        if class.abilities[ "ascendance" ] and state.buff.ascendance.up then
            state.setCooldown( "ascendance", state.buff.ascendance.remains + 165 )
        end

        --[[ Trinkets that need special handling.
        if state.buff.stormeaters_boon.up and state.debuff.rooted.down then
            state.applyDebuff( "player", "rooted", state.buff.stormeaters_boon.remains )
        end

        -- BUGS: Windscar Whetstone invisibly keeps trinkets on CD for 6 additional seconds.
        local ww_cd_remains = state.action.windscar_whetstone.lastCast + 26 - state.now
        if ww_cd_remains > 0 then
            state.putTrinketsOnCD( ww_cd_remains )
        end

        -- TODO: Move this all to those aura generator functions.
        if state.set_bonus.cache_of_acquired_treasures > 0 then
            -- This required changing how buffs are tracked (that applied time is greater than the query time, which was always just expected to be true before).
            -- If this remains problematic, use QueueAuraExpiration instead.
            if state.buff.acquired_sword.up then
                state.applyBuff( "acquired_axe" )
                state.buff.acquired_axe.expires = state.buff.acquired_sword.expires + 12
                state.buff.acquired_axe.applied = state.buff.acquired_sword.expires
                state.applyBuff( "acquired_wand" )
                state.buff.acquired_wand.expires = state.buff.acquired_axe.expires + 12
                state.buff.acquired_wand.applied = state.buff.acquired_axe.expires
            elseif state.buff.acquired_axe.up then
                state.applyBuff( "acquired_wand" )
                state.buff.acquired_wand.expires = state.buff.acquired_axe.expires + 12
                state.buff.acquired_wand.applied = state.buff.acquired_axe.expires
                state.applyBuff( "acquired_sword" )
                state.buff.acquired_sword.expires = state.buff.acquired_wand.expires + 12
                state.buff.acquired_sword.applied = state.buff.acquired_wand.expires
            elseif state.buff.acquired_wand.up then
                state.applyBuff( "acquired_sword" )
                state.buff.acquired_sword.expires = state.buff.acquired_wand.expires + 12
                state.buff.acquired_sword.applied = state.buff.acquired_wand.expires
                state.applyBuff( "acquired_axe" )
                state.buff.acquired_axe.expires = state.buff.acquired_sword.expires + 12
                state.buff.acquired_axe.applied = state.buff.acquired_sword.expires
            end
        end ]]

        state.empowerment.active = state.empowerment.hold > state.now

        Hekili:Yield( "Reset Pre-Cast Hook" )
        ns.callHook( "reset_precast" )
        Hekili:Yield( "Reset Pre-Casting" )

        if state.empowerment.active then
            local timeDiff = state.now - state.empowerment.start
            if timeDiff > 0 then
                if Hekili.ActiveDebug then Hekili:Debug( "Empowerment is active; turning back time by " .. timeDiff .. "s..." ) end
                state.now = state.now - timeDiff
            end
            removeBuff( "casting" )
        else
            -- TODO: All of this cast-queuing seems like it should be simpler, but that's for another time.
            local cast_time, casting, ability = 0, nil, nil
            state.buff.casting.generate( state.buff.casting, "buff" )

            if state.buff.casting.up then
                cast_time = state.buff.casting.remains

                local castID = state.buff.casting.v1
                ability = class.abilities[ castID ]

                casting = ability and ability.key or formatKey( state.buff.casting.name )

                if castID == class.abilities.cyclotronic_blast.id then
                    -- Set up Pocket-Sized Computation Device.
                    if state.buff.casting.v3 == 1 then
                        -- We are in the channeled part of the cast.
                        setCooldown( "pocketsized_computation_device", state.buff.casting.applied + 120 - state.now )
                        setCooldown( "global_cooldown", cast_time )
                    else
                        -- This is the casting portion.
                        casting = class.abilities.pocketsized_computation_device.key
                        state.buff.casting.v1 = class.abilities.pocketsized_computation_device.id
                    end
                end
            end

            -- Okay, two paths here.
            -- 1.  We can cast while casting (i.e., Fire Blast for Fire Mage), so we want to hand off the current cast to the event system, and then let the recommendation engine sort it out.
            -- 2.  We cannot cast anything while casting (typical), so we want to advance the clock, complete the cast, and then generate recommendations.

            if casting and cast_time > 0 then
                local channeled, destGUID = state.buff.casting.v3 == 1

                if ability then
                    channeled = channeled or ability.channeled
                    destGUID  = Hekili:GetMacroCastTarget( ability.key, state.buff.casting.applied, "RESET" ) or state.target.unit
                end

                if not state:IsCasting() and not channeled then
                    state:QueueEvent( casting, state.buff.casting.applied, state.buff.casting.expires, "CAST_FINISH", destGUID )

                    -- Projectile spells have two handlers, effectively.  An onCast handler, and then an onImpact handler.
                    if ability and ability.isProjectile then
                        state:QueueEvent( ability.key, state.buff.casting.expires, nil, "PROJECTILE_IMPACT", destGUID )
                        -- state:QueueEvent( action, "projectile", true )
                    end

                elseif not state:IsChanneling() and channeled then
                    state:QueueEvent( casting, state.buff.casting.applied, state.buff.casting.expires, "CHANNEL_FINISH", destGUID )

                    if channeled and ability then
                        local tick_time = ability.tick_time or ( ability.aura and class.auras[ ability.aura ].tick_time )

                        if tick_time and tick_time > 0 then
                            local eoc = state.buff.casting.expires - tick_time

                            while ( eoc > state.now ) do
                                state:QueueEvent( casting, state.buff.casting.applied, eoc, "CHANNEL_TICK", destGUID )
                                eoc = eoc - tick_time
                            end
                        end
                    end

                    -- Projectile spells have two handlers, effectively.  An onCast handler, and then an onImpact handler.
                    if ability and ability.isProjectile then
                        state:QueueEvent( ability.key, state.buff.casting.expires, nil, "PROJECTILE_IMPACT", destGUID )
                        -- state:QueueEvent( action, "projectile", true )
                    end
                end

                -- Delay to end of GCD.
                if dispName == "Primary" or dispName == "AOE" then
                    local delay = 0

                    if not state.spec.can_dual_cast and state.buff.casting.up and state.buff.casting.v3 ~= 1 then -- v3=1 means it's channeled.
                        delay = max( delay, state.buff.casting.remains )
                    end

                    delay = ns.callHook( "reset_postcast", delay )

                    if delay > 0 then
                        if Hekili.ActiveDebug then Hekili:Debug( "Advancing by %.2f per GCD or cast or channel or reset_postcast value.", delay ) end
                        state.advance( delay )
                    end
                end

                state.resetType = "none"
            end
        end

        Hekili:Yield( "Reset Post-Casting" )

        state.resetting = false
        return true
    end
end
Hekili:ProfileCPU( "state.reset", state.reset )


function state:SetConstraint( min, max )
    state.delayMin = min or 0
    state.delayMax = max or 15
end


function state:SetWhitelist( t )
    state.whitelist = t
end


function state:StartCombat()
    if self.time == 0 then
        self.false_start = self.query_time - 0.01
        if Hekili.ActiveDebug then Hekili:Debug( format( "Starting combat at %.2f -- time is %.2f.", self.false_start, self.time ) ) end
    end

    local swing = false

    if self.swings.mainhand == 0 and self.swings.mainhand_speed > 0 then
        self.swings.mh_pseudo = self.query_time
        swing = true
    end

    if self.swings.offhand == 0 and self.swings.offhand_speed > 0 then
        self.swings.oh_pseudo = self.query_time + ( self.swings.offhand_speed / 2 )
        swing = true
    end

    if swing then self:ForecastSwingbasedResources() end
end


function state.advance( time )
    if not state.resetting and not state.modified then
        state.modified = true
    end

    time = ns.callHook( "advance", time ) or time
    if not state.resetting then time = roundUp( time, 3 ) end

    state.delay = 0

    local realOffset = state.offset

    if state.player.queued_ability then
        local lands = max( state.now + 0.01, state.player.queued_lands )

        if lands > state.query_time and lands <= state.query_time + time then
            state.offset = lands - state.query_time
            state:RunHandler( state.player.queued_ability, true )

            state.offset = realOffset
        end
    end

    local events = state:GetQueue()
    local event = events[ 1 ]

    local eCount = 0

    while( event ) do
        if event.time <= state.query_time + time then
            state.offset = event.time - state.now

            if Hekili.ActiveDebug then Hekili:Debug( "While advancing by %.2f to %.2f, %s %s occurred at %.2f.", time, realOffset + time, event.action, event.type, state.offset ) end

            state:HandleEvent( event )

            event = events[ 1 ]
            state.offset = realOffset
        else
            break
        end

        eCount = eCount + 1
        if eCount == 10 then break end
    end

    if time <= 0 then
        return
    end

    for k in pairs( class.resources ) do
        local resource = state[ k ]

        if not resource.regenModel then
            local override = ns.callHook( "advance_resource_regen", false, k, time )

            local regen = resource.regen
            if regen == 0.001 then regen = 0 end

            if not override and resource.regen and regen ~= 0 then
                resource.actual = min( resource.max, max( 0, resource.actual + ( regen * time ) ) )
            end
        else
            -- revisit this, may want to forecastResources( k ) instead.
            state.delay = time
            resource.actual = resource.current
            state.delay = 0
        end
    end

    state.offset = state.offset + time

    local bonus_cdr = 0 -- ns.callHook( "advance_bonus_cdr", 0 )

    --[[ for k, cd in pairs( state.cooldown ) do
        if state:IsKnown( k ) then
            if bonus_cdr > 0 then
                if cd.next_charge > 0 then
                    cd.next_charge = cd.next_charge - bonus_cdr
                end
                cd.expires = max( 0, cd.expires - bonus_cdr )
                cd.true_expires = max( 0, cd.expires - bonus_cdr )
            end

            local ability = class.abilities[ k ]

            while ability.charges and ability.charges > 1 and cd.next_charge > 0 and cd.next_charge < state.now + state.offset do
                -- if class.abilities[ k ].charges and cd.next_charge > 0 and cd.next_charge < state.now + state.offset then
                cd.charge = cd.charge + 1
                if cd.charge < class.abilities[ k ].charges then
                    cd.recharge_began = cd.next_charge
                    cd.next_charge = cd.next_charge + class.abilities[ k ].recharge
                else
                    cd.recharge_began = 0
                    cd.next_charge = 0
                end
            end
        end
    end ]]

    time = ns.callHook( "advance_end", time ) or time

    return time
end


function state.GetResourceType( ability )
    local action = class.abilities[ ability ]

    if not action then return end

    if action.spend ~= nil then
        if type( action.spend ) == "number" then
            return action.spendType or class.primaryResource

        elseif type( action.spend ) == "function" then
            return select( 2, action.spend() ) or action.spendType or class.primaryResource

        end
    end

    return nil
end


ns.spendResources = function( ability )
    local action = class.abilities[ ability ]

    if not action then return end

    -- First, spend resources.
    if action.spend ~= nil then
        local cost, resource

        if type( action.spend ) == "number" then
            cost = action.spend
            resource = action.spendType or class.primaryResource
        elseif type( action.spend ) == "function" then
            cost, resource = action.spend()
            resource = resource or action.spendType or class.primaryResource
        else
            cost = cost or 0
            resource = resource or "health"
        end

        if cost > 0 and cost < 1 then
            cost = ( cost * state[ resource ].modmax )
        end

        if cost ~= 0 then
            state.spend( cost, resource )
        end
    end
end
state.SpendResources = ns.spendResources


do
    local HOLD_PERMANENT = 1
    local HOLD_COMBAT    = 2

    function Hekili:PlaceHold( action, combat, verbose )
        if not action then return end

        action = action:trim()
        local ability = class.abilities[ action ]

        if not ability then
            action = action:lower()
            -- Try to auto-complete.
            for k, v in orderedPairs( class.abilities ) do
                if type(k) == "string" and k:sub( 1, action:len() ):lower() == action then
                    action = v.key
                    ability = class.abilities[ action ]
                    break
                end
            end
        end

        if ability then
            state.holds[ ability.key ] = combat and HOLD_COMBAT or HOLD_PERMANENT
            if verbose then Hekili:Print( class.abilities[ ability.key ].name .. " placed on hold" .. ( combat and " until end of combat." or "." ) ) end
            Hekili:ForceUpdate( "HEKILI_HOLD_APPLIED" )
        end
    end

    function Hekili:RemoveHold( action, verbose )
        if not action then return end

        action = action:trim()
        local ability = class.abilities[ action ]

        if not ability then
            action = action:lower()
            -- Try to auto-complete.
            for k, v in orderedPairs( class.abilities ) do
                if type(k) == "string" and k:sub( 1, action:len() ):lower() == action then
                    action = v.key
                    ability = class.abilities[ action ]
                    break
                end
            end
        end

        if ability and state.holds[ ability.key ] then
            state.holds[ ability.key ] = nil
            if verbose then Hekili:Print( class.abilities[ ability.key ].name .. " hold removed." ) end
            Hekili:ForceUpdate( "HEKILI_HOLD_REMOVED" )
        end
    end

    function Hekili:ToggleHold( action, combat, verbose )
        if self:IsHeld( action ) then
            self:RemoveHold( action, verbose )
            return
        end

        self:PlaceHold( action, combat, verbose )
    end

    function Hekili:IsHeld( action )
        action = action and action:trim()
        local ability = class.abilities[ action ]

        if not ability then
            action = action:lower()
            -- Try to auto-complete.
            for k, v in orderedPairs( class.abilities ) do
                if type(k) == "string" and k:sub( 1, action:len() ):lower() == action then
                    action = v.key
                    ability = class.abilities[ action ]
                    break
                end
            end
        end

        if ability and state.holds[ ability.key ] then
            return true, state.holds[ ability.key ]
        end

        return false
    end

    function Hekili:ReleaseHolds( combat )
        local holdRemoved = false

        for k, v in pairs( state.holds ) do
            if not combat or v == HOLD_COMBAT then
                state.holds[ k ] = nil
                holdRemoved = true
            end
        end

        if holdRemoved then Hekili:ForceUpdate( "HEKILI_COMBAT_HOLD_REMOVED" ) end
    end
end


function state:IsKnown( sID )
    local original = sID
    if type(sID) ~= "number" then sID = class.abilities[ sID ] and class.abilities[ sID ].id or nil end

    if not sID then
        return false, "could not find valid ID" -- no ability
    end

    local ability = class.abilities[ sID ]

    if not ability then
        Error( "IsKnown() - " .. tostring( sID ) .. " / " .. original .. " not found in abilities table.\n\n" .. debugstack() )
        return false, format( "%s / %s not found in abilities table", tostring( original ), tostring( sID ) )
    end

    if IsAbilityDisabled( ability ) then return false, "not usable here" end

    if sID < 0 then
        if ability.known ~= nil then
            if type( ability.known ) == "number" then
                return IsUsableItem( ability.known ), "IsUsableItem known"
            end
            return ability.known
        end

        if ability.item and ability.key ~= "potion" then
            return IsUsableItem( ability.item ), "IsUsableItem item " .. ability.item .. " and " .. ( tostring( ability.known ) or "nil" )
        end

        return true
    end

    if IsDisabledCovenantSpell( sID ) then return false, "covenant spells are disabled" end

    if ability.spec and not state.spec[ ability.spec ] then
        return false, "wrong specialization"
    end

    if ability.nospec and state.spec[ ability.nospec ] then
        return false, "spec [ " .. ability.nospec .. " ] disallowed"
    end

    if ability.talent and not state.talent[ ability.talent ].enabled then
        return false, "talent [ " .. ability.talent .. " ] missing"
    end

    if ability.notalent and state.talent[ ability.notalent ].enabled then
        return false, "talent [ " .. ability.notalent .. " ] disallowed"
    end

    if ability.pvptalent and not state.pvptalent[ ability.pvptalent ].enabled then
        return false, "PvP talent [ " .. ability.pvptalent .. " ] missing"
    end

    if ability.nopvptalent and state.pvptalent[ ability.nopvptalent ].enabled then
        return false, "PvP talent [ " ..ability.nopvptalent .. " ] disallowed"
    end

    if ability.trait and not state.artifact[ ability.trait ].enabled then
        return false, "trait [ " .. ability.trait .. " ] missing"
    end

    if ability.equipped and not state.equipped[ ability.equipped ] then
        return false, "equipment [ " .. ability.equipped .. " ] missing"
    end

    if ability.item and not ability.bagItem and not state.equipped[ ability.item ] then
        return false, "item [ " .. ability.item .. " ] missing"
    end

    if ability.noOverride and IsSpellKnownOrOverridesKnown( ability.noOverride ) then
        return false, "override [ " .. ability.noOverride .. " ] disallowed"
    end

    if ability.known ~= nil then
        if type( ability.known ) == "number" then
            return IsPlayerSpell( ability.known ) or IsSpellKnownOrOverridesKnown( ability.known ) or IsSpellKnown( ability.known, true )
        end
        return ability.known
    end

    return IsPlayerSpell( sID ) or IsSpellKnownOrOverridesKnown( sID ) or IsSpellKnown( sID, true )

end



do
    local toggleSpells = {
        potion = true,
        cancel_buff = true,
        phial_of_serenity = true,
    }

    -- If an ability has been manually disabled, don't consider it.
    function state:IsDisabled( spell, strict )
        spell = spell or self.this_action

        local ability = class.abilities[ spell ]
        if not ability then return false end

        spell = ability.key

        if self.holds[ spell ] then return true, "on hold" end

        local profile = Hekili.DB.profile
        local spec = rawget( profile.specs, state.spec.id )
        if not spec then return true end

        if ability.disabled then return true, "disabled per ability function" end

        local option = ability.item and spec.items[ spell ] or spec.abilities[ spell ]

        if option.disabled then return true, "preference" end
        if option.boss and not state.boss then return true, "boss-only" end
        if option.targetMin > 0 and self.active_enemies < option.targetMin then
            return true, "active_enemies[" .. self.active_enemies .. "] is less than ability's minimum targets [" .. option.targetMin .. "]"
        elseif option.targetMax > 0 and self.active_enemies > option.targetMax then
            return true, "active_enemies[" .. self.active_enemies .. "] is more than ability's maximum targets [" .. option.targetMax .. "]"
        end

        if not strict then
            local toggle = option.toggle
            if not toggle or toggle == "default" then toggle = ability.toggle end

            if ( toggle == "potion" or toggle == "essences" ) and profile.toggles[ toggle ].separate and not profile.toggles[ toggle ].value then toggle = "cooldowns" end

            if toggle and toggle ~= "none" and ( not self.toggle[ toggle ] or ( profile.toggles[ toggle ].separate and state.filter ~= toggle ) ) then return true, format( "toggle %s", toggle ) end

            if ability.id < -100 or ability.id > 0 or toggleSpells[ spell ] then
                if self.empowerment.active and self.empowerment.spell and spell ~= self.empowerment.spell then return true, "empowerment: " .. self.empowerment.spell end
                if state.filter ~= "none" and state.filter ~= toggle and not ability[ state.filter ] then return true, "display"
                elseif ability.item and not ability.bagItem and not state.equipped[ ability.item ] then return false
                end
            end
        end

        return false
    end


    -- TODO:  Finish this, need to support toggles that knock spells to their own display vs. toggles that disable an ability entirely.
    function state:IsFiltered( spell )
        spell = spell or self.this_action

        local ability = class.abilities[ spell ]
        if not ability then return false end

        spell = ability.key

        if state.empowerment.active and state.empowerment.spell ~= spell then return true, "empowerment" end
        if state.filter == "none" then return false end

        local profile = Hekili.DB.profile
        local spec = rawget( profile.specs, state.spec.id )
        if not spec then return true end

        local option = ability.item and spec.items[ spell ] or spec.abilities[ spell ]
        local toggle = option.toggle
        if not toggle or toggle == "default" then toggle = ability.toggle end

        if ( toggle == "potion" or toggle == "essences" ) and profile.toggles[ toggle ].separate and not profile.toggles[ toggle ].value then toggle = "cooldowns" end

        if ability.id < -100 or ability.id > 0 or toggleSpells[ spell ] then
            if state.filter ~= "none" and state.filter ~= toggle and not ability[ state.filter ] then return true, "display"
            elseif ability.item and not ability.bagItem and not state.equipped[ ability.item ] then return false, "not equipped"
            elseif toggle and toggle ~= "none" then
                if not self.toggle[ toggle ] or ( profile.toggles[ toggle ].separate and state.filter ~= toggle and not spec.noFeignedCooldown ) then return true, format( "%s filtered", toggle ) end
            end
        end

        return false
    end


    -- Filter out non-resource driven issues with abilities.
    -- Unusable abilities are treated as on CD unless overridden.
    function state:IsUsable( spell )
        spell = spell or self.this_action

        local ability = class.abilities[ spell ]
        if not ability then return true end

        local hook, reason = ns.callHook( "IsUsable", spell )
        if hook == false then
            return false, reason
        end

        if ability.funcs.usable then
            local usable, reason = ability.funcs.usable( self, ability )
            if usable == false then -- Have allowed nil return values for usable to be treated as usable before.
                return false, reason
            end
        else
            local usable = ability.usable
            if type( usable ) == "number" and not IsUsableSpell( usable ) then
                return false, "IsUsableSpell(" .. usable .. ") was false"
            elseif type( usable ) == "boolean" and not usable then
                return false, "ability.usable was false"
            end
        end

        local profile = Hekili.DB.profile

        if self.rangefilter and UnitExists( "target" ) then
            if LSR.IsSpellInRange( ability.rangeSpell or ability.id, "target" ) == 0 then
                return false, "filtered out of range"
            end

            if ability.range then
                local _, dist = RC:GetRange( "target" )

                if dist and dist > ability.range then
                    return false, "not within ability-specified range (" .. ability.range .. ")"
                end
            end
        end

        if ability.item then
            if not ability.bagItem and not self.equipped[ ability.item ] then
                return false, "item not equipped"
            end
        end

        if ability.disabled then
            return false, "ability.disabled returned true"
        end

        if ability.empowered and self.args.empower_to and self.args.empower_to > self.max_empower then
            return false, "empowerment level " .. self.args.empower_to .. " not available"
        end

        if self.args.only_cwc and ( not self.buff.casting.up or self.buff.casting.v3 ~= 1 or not ability.dual_cast ) then
            return false, "only castable while channeling"
        end

        if ability.nomounted and IsMounted() then
            return false, "not recommended while mounted"
        end

        if ability.nocombat and self.time > 0 then
            return false, "not usable in combat"
        end

        if ability.form and not state.buff[ ability.form ].up then
            return false, "required form (" .. ability.form .. ") not active"
        end

        if ability.noform and state.buff[ ability.noform ].up then
            return false, "not usable in current form (" .. ability.noform .. ")"
        end

        if ability.buff and not state.buff[ ability.buff ].up then
            return false, "required buff (" .. ability.buff .. ") not active"
        end

        if ability.debuff and not state.debuff[ ability.debuff ].up then
            return false, "required debuff (" ..ability.debuff .. ") not active"
        end

        if ability.channeling then
            local c = class.abilities[ ability.channeling ] and class.abilities[ ability.channeling ].id

            if not c or state.buff.casting.remains < 0.1 or state.buff.casting.v3 ~= 1 or state.buff.casting.v1 ~= c then
                return false, "required channel (" .. c .. " / " .. ability.channeling .. ") not active or too short [ " .. state.buff.casting.remains .. " / " .. state.buff.casting.applied .. " / " .. state.buff.casting.expires .. " / " .. state.query_time .. " / " .. tostring( state.buff.casting.v3 ) .. " / " .. state.buff.casting.v1 .. " ]"
            end
        end

        if self.args.moving == 1 and state.buff.movement.down then
            return false, "entry requires movement and player is not moving"
        end

        if self.args.moving == 0 and state.buff.movement.up then
            return false, "entry requires no movement and player is moving"
        end

        -- Moved this into TimeToReady; we can see when the buff falls off.
        --[[ if ability.nobuff and state.buff[ ability.nobuff ].up then
            return false
        end ]]

        return true
    end

end

ns.hasRequiredResources = function( ability )
    local action = class.abilities[ ability ]

    if not action then return end

    -- First, spend resources.
    if action.spend and action.spend ~= 0 then
        local spend, resource

        if type( action.spend ) == "number" then
            spend = action.spend
            resource = action.spendType or class.primaryResource
        elseif type( action.spend ) == "function" then
            spend, resource = action.spend()
        end

        if resource == "focus" or resource == "energy" then
            -- Thought: We'll already delay CD based on time to get energy/focus.
            -- So let's leave it alone.
            return true
        end

        if spend > 0 and spend < 1 then
            spend = ( spend * state[ resource ].modmax )
        end

        if spend > 0 then
            return ( state[ resource ].current >= spend )
        end
    end

    return true
end
function state:HasRequiredResources( action )
    return ns.hasRequiredResources( action )
end


local power_tick_rate = 0.115


--[[ Really dumb timing tool to find what was bottlenecking TTR.
local longestTTR = 0

local lastTime, lastName = 0, "nothing"
local longTime, longName = 0, "nothing"

local function profilestop( name, reset )
    local newTime = debugprofilestop()

    if reset then
        lastTime = newTime
        lastName = name

        longTime = 0
        longName = name

        return lastTime
    end

    if newTime - lastTime > longTime then
        longTime = newTime - lastTime
        longName = name
    end

    lastTime = newTime
    return newTime
end ]]


function state:TimeToReady( action, pool )
    local now = self.now + self.offset
    action = action or self.this_action

    local delay = state.delay
    state.delay = 0

    -- Need to ignore the wait for this part.
    local wait = self.cooldown[ action ].remains
    local ability = class.abilities[ action ]

    -- Working variable.
    local z = ability.id

    if z < -99 or z > 0 then
        -- Don't use before the GCD expires, unless:
        -- 1. The "use_off_gcd" flag is set in the priority.
        -- 2. The ability is flagged as an interrupt or defensive.
        local requires = ability.toggle
        if requires ~= "interrupts" and requires ~= "defensives" and not self.safebool( self.args.use_off_gcd ) then
            wait = max( wait, self.cooldown.global_cooldown.remains )
        end

        if not state.channel_breakable and not ability.dual_cast then
            z = self.buff.casting.remains
            if z > wait then
                wait = z
            end
        end
    end

    local spend, resource = ability.spend
    if spend then
        if type( spend ) == "number" then
            resource = ability.spendType or class.primaryResource
        elseif type( spend ) == "function" then
            spend, resource = spend()
            resource = resource or ability.spendType or class.primaryResource
        end

        spend = spend or 0
    end

    if spend and resource and spend > 0 and spend < 1 then
        spend = spend * self[ resource ].modmax
    end

    if not pool then
        z = ability.readyTime
        if z and z > wait then
            wait = z
        end

        z = ability.readySpend
        if z then
            spend = z
        end
    end

    -- Okay, so we don't have enough of the resource.
    z = resource and self[ resource ]
    z = z and z[ "time_to_" .. spend ]
    if spend and z and z > wait then
        wait = max( wait, ceil( z * 100 ) / 100 )
    end

    z = ability.nobuff
    z = z and self.buff[ z ].remains
    if z and z > wait then
        wait = z
    end

    z = ability.nodebuff
    z = z and self.debuff[ z ].remains
    if z and z > wait then
        wait = z
    end

    --[[ Need to house this in an encounter module, really.
    z = self.debuff.repeat_performance.remains
    if z and z > 0 and self.prev[1][ action ] then
        wait = max( wait, z )
    end
    profilestop( "post-repeat" ) ]]


    -- If ready is a function, it returns time.
    -- Ignore this if we are just checking pool_resources.

    --[[ if state.spec.fire and state.buff.casting.up and ( ability.id > 0 or ability.id < -99 ) and ability.gcd ~= "off" and not ability.dual_cast then
        wait = max( wait, state.buff.casting.remains )
    end
    profilestop( "post-casting" ) ]]

    z = ability.timeToReady
    if z and z > wait then
        wait = z
    end

    local lastCast = ability.lastCast

    z = ability.icd
    z = z and z + lastCast - now
    if z and z > wait then
        if Hekili.ActiveDebug then Hekili:Debug( "ICD is " .. z .. ", last cast was " .. lastCast .. ", remaining CD: " .. max( 0, lastCast + z - now ) ) end
        wait = z
    end

    local line_cd = self.args.line_cd
    if self.time > 0 and lastCast > max( self.combat, self.false_start ) and line_cd and type( line_cd ) == "number" then
        if Hekili.ActiveDebug then Hekili:Debug( "Line CD is " .. line_cd .. ", last cast was " .. lastCast .. ", remaining CD: " .. max( 0, lastCast + line_cd - now ) ) end
        wait = max( wait, lastCast + line_cd - now )
    end

    local sync = state.args.sync
    local synced = sync and class.abilities[ sync ]

    if synced and sync ~= action and state:IsKnown( sync ) then
        wait = max( wait, state:TimeToReady( sync ) )
    end

    wait = ns.callHook( "TimeToReady", wait, action )

    if state.empowerment.active and action == state.empowerment.spell then
        wait = max( wait, ( state.empowerment.stages[ state.args.empower_to or state.max_empower ] or 0 ) - now )
    end

    state.delay = delay
    return max( wait, self.delayMin )
end


function state:IsReady( action )
    action = action or self.this_action
    local ability = action and class.abilities[ action ]

    if not ability then
        Hekili:Error( "Failed state:IsReady( " .. ( action or "BLANK" ) .. " )." )
        return false
    end

    if ability.spend then
        local spend, resource

        if type( ability.spend ) == "number" then
            spend = ability.spend
            resource = ability.spendType or class.primaryResource
        elseif type( ability.spend ) == "function" then
            spend, resource = ability.spend()
        end

        if resource == "focus" or resource == "energy" or state.script.entry then
            local ttr = self:TimeToReady( action )

            if ttr < self.delayMin or ttr > self.delayMax then return false, format( "not ready within  time contraint ( %.2f - %.2f )", self.delayMin, self.delayMax )
            elseif ttr >= self.selection_time then return false, format( "not ready [%.2f] before selected action %s [%.2f]", ttr, self.selected_action or "no_action", self.selection_time ) end

            return true
        end

    end

    return self:HasRequiredResources( action ) and self.cooldown[ action ].remains <= self.delay
end


function state:IsReadyNow( action )
    action = action or self.this_action
    local a = class.abilities[ action ]

    if not a then return false end

    action = a.key
    local profile = Hekili.DB.profile
    local spec = rawget( profile.specs, state.spec.id )
    if not spec then return false end

    local option = spec.abilities[ action ]
    local clash = option.clash or 0

    if self.cooldown[ action ].remains - clash > 0 then return false end
    local wait = ns.callHook( "TimeToReady", 0, action )
    if wait and wait > 0 then return false end

    if a.ready and type( a.ready ) == "function" and a.ready() > 0 then return false end

    if a.spend and a.spend ~= 0 then
        local spend, resource

        if type( a.spend ) == "number" then
            spend = a.spend
            resource = a.spendType or class.primaryResource

        elseif type( a.spend ) == "function" then
            spend, resource = a.spend()

        end

        if a.ready and type( a.ready ) == "number" then
            spend = a.ready
        end

        if spend > 0 and spend < 1 then
            spend = ( spend * state[ resource ].modmax )
        end

        if spend > 0 then
            return state[ resource ].current >= spend
        end
    end

    return true
end



function state:ClashOffset( action )
    local a = class.abilities[ action ]
    if not a then return 0 end
    action = a.key

    local spec = rawget( Hekili.DB.profile.specs, state.spec.id )
    if not spec then return 0 end

    local option = spec.abilities[ action ]

    return ns.callHook( "clash", option.clash, action )
end


for k, v in pairs( state ) do
    ns.commitKey( k )
end

ns.attr = { "serenity", "active", "active_enemies", "my_enemies", "active_flame_shock", "adds", "agility", "air", "armor", "attack_power", "bonus_armor", "cast_delay", "cast_time", "casting", "cooldown_react", "cooldown_remains", "cooldown_up", "crit_rating", "deficit", "distance", "down", "duration", "earth", "enabled", "energy", "execute_time", "fire", "five", "focus", "four", "gcd", "hardcasts", "haste", "haste_rating", "health", "health_max", "health_pct", "intellect", "level", "mana", "mastery_rating", "mastery_value", "max_nonproc", "max_stack", "maximum_energy", "maximum_focus", "maximum_health", "maximum_mana", "maximum_rage", "maximum_runic", "melee_haste", "miss_react", "moving", "mp5", "multistrike_pct", "multistrike_rating", "one", "pct", "rage", "react", "regen", "remains", "resilience_rating", "runic", "seal", "spell_haste", "spell_power", "spirit", "stack", "stack_pct", "stacks", "stamina", "strength", "this_action", "three", "tick_damage", "tick_dmg", "tick_time", "ticking", "ticks", "ticks_remain", "time", "time_to_die", "time_to_max", "travel_time", "two", "up", "water", "weapon_dps", "weapon_offhand_dps", "weapon_offhand_speed", "weapon_speed", "single", "aoe", "cleave", "percent", "last_judgment_target", "unit", "ready", "refreshable", "pvptalent", "conduit", "legendary", "runeforge", "covenant", "soulbind", "enabled", "full_recharge_time", "time_to_max_charges", "remains_guess", "execute", "actual", "current", "cast_regen", "boss", "exists", "disabled", "fight_remains", "last_used", "time_since", "max" }
