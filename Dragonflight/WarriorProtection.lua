-- WarriorProtection.lua
-- October 2022
-- Updated for PTR Build 46181
-- Last Modified 10/19/2022 18:15 UTC

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local FindPlayerAuraByID = ns.FindPlayerAuraByID

-- Conduits (Patch 10.0) : In all cases, talents override and disable conduits they share effects with.
-- Talents override the following:
    -- Brutal Vitality
    -- Fueled by Violence
    -- Piercing Verdict
    -- Unnerving Focus
    -- Cacophonous Roar
    -- Inspiring Presence
    -- Merciless Bonegrinder
    -- Show of Force (Protection)
    -- Ashen Juggernaut

-- Conduits that need modeled.
    -- [X] Indelible Victory
    -- [X] Stalwart Guardian
    -- [X] Disturb the Peace

local spec = Hekili:NewSpecialization( 73 )

local base_rage_gen = 2

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time

            return (  swing + floor( ( t - swing ) / state.swings.mainhand_speed )  * state.swings.mainhand_speed )
        end,

        interval = "mainhand_speed",

        stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
        value = function ()
            if state.talent.devastator.enabled then -- 1 Rage for instigate with devastator, 2 rage for instigate with devastate
                return (base_rage_gen * ( state.talent.war_machine.enabled and 1.5 or 1 )) + (state.talent.instigate.enabled and 1 or 0) -- 1 Rage for instigate
            else
                return (base_rage_gen * ( state.talent.war_machine.enabled and 1.5 or 1 )) + (state.talent.instigate.enabled and 2 or 0) -- 2 Rage for instigate
            end
        end
    },

    conquerors_banner = {
        aura = "conquerors_banner",

        last = function ()
            local app = state.buff.conquerors_banner.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,

        value = 4,
    },
})

-- Talents
spec:RegisterTalents( {
    anger_management                = { 90311, 152278, 1 }, --
    armored_to_the_teeth            = { 90259, 394855, 2 }, --
    avatar                          = { 90365, 107574, 1 }, --
    barbaric_training               = { 90377, 390675, 1 }, --
    battering_ram                   = { 90262, 394312, 1 }, --
    battle_stance                   = { 90261, 386164, 1 }, --
    battlescarred_veteran           = { 90435, 386394, 1 }, --
    berserker_rage                  = { 90372, 18499 , 1 }, --
    berserker_shout                 = { 90348, 384100, 1 }, --
    best_served_cold                = { 90304, 202560, 1 }, --
    bitter_immunity                 = { 90356, 383762, 1 }, --
    blood_and_thunder               = { 90342, 384277, 1 }, --
    bloodborne                      = { 90448, 385704, 2 }, --
    bloodsurge                      = { 90300, 384361, 1 }, --
    bolster                         = { 90264, 280001, 1 }, --
    booming_voice                   = { 90314, 202743, 1 }, --
    bounding_stride                 = { 90355, 202163, 1 }, --
    brace_for_impact                = { 90296, 386030, 1 }, --
    brutal_vitality                 = { 90451, 384036, 1 }, --
    cacophonous_roar                = { 90383, 382954, 1 }, --
    challenging_shout               = { 90309, 1161  , 1 }, --
    champions_bulwark               = { 90316, 386328, 1 }, --
    concussive_blows                = { 90334, 383115, 1 }, --
    crackling_thunder               = { 90342, 203201, 1 }, --
    cruel_strikes                   = { 90381, 392777, 2 }, --
    crushing_force                  = { 90369, 390642, 2 }, --
    dance_of_death                  = { 90260, 393965, 1 }, --
    defensive_stance                = { 90330, 386208, 1 }, --
    demoralizing_shout              = { 90305, 1160  , 1 }, --
    devastator                      = { 90299, 236279, 1 }, --
    disrupting_shout                = { 90307, 386071, 1 }, --
    double_time                     = { 90382, 103827, 1 }, --
    elysian_might                   = { 90323, 386285, 1 }, --
    endurance_training              = { 90339, 382940, 1 }, --
    enduring_alacrity               = { 90433, 384063, 1 }, --
    enduring_defenses               = { 90313, 386027, 1 }, --
    fast_footwork                   = { 90371, 382260, 1 }, --
    focused_vigor                   = { 90318, 384067, 1 }, --
    frothing_berserker              = { 90370, 392790, 1 }, --
    fueled_by_violence              = { 90451, 383103, 1 }, --
    furious_blows                   = { 90336, 390354, 1 }, --
    heavy_repercussions             = { 90319, 203177, 1 }, --
    heroic_leap                     = { 90346, 6544  , 1 }, --
    honed_reflexes                  = { 90361, 391271, 1 }, --
    ignore_pain                     = { 90295, 190456, 1 }, --
    immovable_object                = { 90364, 394307, 1 }, --
    impending_victory               = { 90326, 202168, 1 }, --
    impenetrable_wall               = { 90310, 384072, 1 }, --
    improved_heroic_throw           = { 90306, 386034, 1 }, --
    indomitable                     = { 90434, 202095, 1 }, --
    inspiring_presence              = { 90332, 382310, 1 }, --
    instigate                       = { 90301, 394311, 1 }, --
    intervene                       = { 90329, 3411  , 1 }, --
    intimidating_shout              = { 90384, 5246  , 1 }, --
    into_the_fray                   = { 90319, 202603, 1 }, --
    juggernaut                      = { 90449, 393967, 1 }, --
    last_stand                      = { 90297, 12975 , 1 }, --
    leeching_strikes                = { 90344, 382258, 1 }, --
    massacre                        = { 90313, 281001, 1 }, --
    menace                          = { 90383, 275338, 1 }, --
    onehanded_weapon_specialization = { 90324, 382895, 1 }, --
    overwhelming_rage               = { 90378, 382767, 2 }, --
    pain_and_gain                   = { 90353, 382549, 1 }, --
    piercing_howl                   = { 90348, 12323 , 1 }, --
    piercing_verdict                = { 90379, 382948, 1 }, --
    punish                          = { 90449, 275334, 1 }, --
    rallying_cry                    = { 90331, 97462 , 1 }, --
    ravager                         = { 90432, 228920, 1 }, --
    reinforced_plates               = { 90368, 382939, 1 }, --
    rend                            = { 90302, 394062, 1 }, --
    revenge                         = { 90298, 6572  , 1 }, --
    rumbling_earth                  = { 90374, 275339, 1 }, --
    second_wind                     = { 90332, 29838 , 1 }, --
    seismic_reverberation           = { 90340, 382956, 1 }, --
    shattering_throw                = { 90351, 64382 , 1 }, --
    shield_charge                   = { 90317, 385952, 1 }, --
    shield_specialization           = { 90315, 386011, 2 }, --
    shield_wall                     = { 90312, 871   , 1 }, --
    shockwave                       = { 90375, 46968 , 1 }, --
    show_of_force                   = { 90320, 385843, 1 }, --
    sidearm                         = { 90334, 384404, 1 }, --
    sonic_boom                      = { 90321, 390725, 1 }, --
    spear_of_bastion                = { 90380, 376079, 1 }, --
    spell_block                     = { 90450, 392966, 1 }, --
    spell_reflection                = { 90385, 23920 , 1 }, --
    storm_bolt                      = { 90337, 107570, 1 }, --
    storm_of_steel                  = { 90431, 382953, 1 }, --
    strategist                      = { 90303, 384041, 1 }, --
    sudden_death                    = { 90320, 29725 , 1 }, --
    thunder_clap                    = { 90343, 6343  , 1 }, --
    thunderlord                     = { 90308, 385840, 1 }, --
    thunderous_roar                 = { 90359, 384318, 1 }, --
    thunderous_words                = { 90358, 384969, 1 }, --
    titanic_throw                   = { 90341, 384090, 1 }, --
    tough_as_nails                  = { 90450, 385888, 1 }, --
    unbreakable_will                = { 90310, 384074, 1 }, --
    unnerving_focus                 = { 90452, 384042, 1 }, --
    unstoppable_force               = { 90364, 275336, 1 }, --
    uproar                          = { 90357, 391572, 1 }, --
    violent_outburst                = { 90265, 386477, 1 }, --
    war_machine                     = { 90345, 316733, 1 }, --
    wild_strikes                    = { 90360, 382946, 2 }, --
    wrecking_throw                  = { 90351, 384110, 1 }, --
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bodyguard = 168, -- 213871
    demolition = 5374, -- 329033
    disarm = 24, -- 236077
    dragon_charge = 831, -- 206572
    morale_killer = 171, -- 199023
    oppressor = 845, -- 205800
    rebound = 833, -- 213915
    shield_bash = 173, -- 198912
    sword_and_board = 167, -- 199127
    thunderstruck = 175, -- 199045
    warbringer = 5432, -- 356353
    warpath = 178, -- 199086
} )


-- Auras
spec:RegisterAuras( {
    avatar = {
        id = 107574,
        duration = 20,
        max_stack = 1
    },
    battering_ram = {
        id = 394313,
        duration = 20,
        max_stack = 1,
    },
    battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1
    },
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1
    },
    battlescarred_veteran = {
        id = 386397,
        duration = 8,
        max_stack = 1
    },
    berserker_rage = {
        id = 18499,
        duration = 6,
        max_stack = 1
    },
    berserker_shout = {
        id = 384100,
        duration = 6,
        max_stack = 1
    },
    bodyguard = {
        id = 213871,
        duration = 60,
        tick_time = 1,
        max_stack = 1
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1,
    },
    brace_for_impact = {
        id = 386029,
        duration = 16,
        max_stack = 5
    },
    challenging_shout = {
        id = 1161,
        duration = 6,
        max_stack = 1
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1,
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1
    },
    dance_of_death = {
        id = 393966,
        duration = 180,
        max_stack = 1,
    },
    deep_wounds = {
        id = 115767,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    demoralizing_shout = {
        id = 1160,
        duration = 8,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    disrupting_shout = {
        id = 386071,
        duration = 6,
        max_stack = 1
    },
    dragon_charge = {
        id = 206572,
        duration = 1.2,
        max_stack = 1
    },
    elysian_might = {
        id = 386286,
        duration = 8,
        max_stack = 1
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    ignore_pain = {
        id = 190456,
        duration = 12,
        max_stack = 1
    },
    indelible_victory = {
        id = 336642,
        duration = 8,
        max_stack = 1
    },
    intimidating_shout = {
        id = function () return talent.menace.enabled and 316593 or 5246 end,
        duration = function () return talent.menace.enabled and 15 or 8 end,
        max_stack = 1
    },
    into_the_fray = {
        id = 202602,
        duration = 3600,
        max_stack = 5
    },
    juggernaut = {
        id = 383290,
        duration = 12,
        max_stack = 15
    },
    last_stand = {
        id = 12975,
        duration = 15,
        max_stack = 1
    },
    violent_outburst = { -- Renamed from Outburst to violent Outburst in build 45779
        id = 386478,
        duration = 30,
        max_stack = 1
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    punish = {
        id = 275335,
        duration = 9,
        max_stack = 5
    },
    wild_strikes = { --Renamed from Quick Thinking to Wild Strikes in build 45779,
        id = 382946, --392778 is quick_thinking aura,
        duration = 10,
        max_stack = 1
    },
    rallying_cry = {
        id = 97463,
        duration = function () return 10 + ( talent.inspiring_presence.enabled and 3 or 0 ) end,
        max_stack = 1,
    },
    ravager = {
        id = 228920,
        duration = function () return ( buff.dance_of_death.up and 14 or 12 ) * haste end,
        tick_time = 2,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    revenge = {
        id = 5302,
        duration = 6,
        max_stack = 1
    },
    seeing_red = {
        id = 386486,
        duration = 30,
        max_stack = 8
    },
    shield_bash = {
        id = 198912,
        duration = 8,
        max_stack = 1
    },
    shield_block = {
        id = 132404,
        duration = function () return 6 + ( talent.enduring_defenses.enabled and 2 or 0 ) + ( talent.heavy_repercussions.enabled and 1 or 0 )  end,
        max_stack = 1
    },
    shield_charge = {
        id = 385954,
        duration = 4,
        max_stack = 1,
    },
    shield_wall = {
        id = 871,
        duration = 8,
        max_stack = 1
    },
    shockwave = {
        id = 132168,
        duration = 2,
        max_stack = 1
    },
    show_of_force = {
        id = 385842,
        duration = 12,
        max_stack = 1
    },
    spear_of_bastion = {
        id = 376080,
        duration = function() return talent.elysian_might.enabled and 6 or 4 end,
        tick_time = 1,
        max_stack = 1
    },
    spell_block = {
        id = 392966,
        duration = 20,
        max_stack = 1
    },
    spell_reflection = {
        id = 23920,
        duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
        max_stack = 1
    },
    spell_reflection_defense = {
        id = 385391,
        duration = 5,
        max_stack = 1
    },
    sudden_death = {
        id = 52437,
        duration = 10,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 384318,
        duration = function () return talent.thunderous_words.enabled and 10 or 8 end,
        tick_time = 2,
        max_stack = 1
    },
    unnerving_focus = {
        id = 384043,
        duration = 15,
        max_stack = 1
    },
    victorious = {
        id = 32216,
        duration = 20,
        max_stack = 1
    },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1
    },
} )

-- Tier 28
spec:RegisterSetBonuses( "tier28_2pc", 364002, "tier28_4pc", 364639 )
-- 2-Set - Outburst - Consuming 30 rage grants a stack of Seeing Red, which transforms at 8 stacks into Outburst, causing your next Shield Slam or Thunder Clap to be 200% more effective and grant Ignore Pain.
-- 4-Set - Outburst - Avatar increases your damage dealt by an additional 10% and decreases damage taken by 10%.
spec:RegisterAuras( {
    seeing_red_tier28 = {
        id = 364006,
        duration = 30,
        max_stack = 8,
    },
    outburst = {
        id = 364010,
        duration = 30,
        max_stack = 1
    },
    outburst_buff = {
        id = 364641,
        duration = function () return class.auras.avatar.duration end,
        max_stack = 1,
    }
})

-- Dragonflight Season 1
spec:RegisterSetBonuses( "tier29_2pc", 393710, "tier29_4pc", 393711 ) -- Dragonflight Season 1
-- 2-Set - Revenge grants you Vanguard's Determination, increasing your damage done and reducing damage you take by 4% for 5 sec seconds.
-- 4-Set - During Vanguard's Determination, gain Ignore Pain equal to 5% of damage you deal.
spec:RegisterAuras( {
    vanguards_determination = {
        id = 394056,
        duration = 5,
        max_stack = 1,
    }
})

local rageSpent = 0
local gloryRage = 0
local outburstRage = 0

spec:RegisterStateExpr( "glory_rage", function () return gloryRage end )
spec:RegisterStateExpr( "rage_spent", function () return rageSpent end )
spec:RegisterStateExpr( "outburst_rage", function () return outburstRage end )

local RAGE = Enum.PowerType.Rage
local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )
        if current < lastRage - 3 then -- Spent Rage, -3 is used as a Hack to avoid Rage decaying
            if state.talent.anger_management.enabled or state.talent.indomitable.enabled then
                rageSpent = ( rageSpent + lastRage - current ) % 10 -- Anger Management / Indomitable
            end

            if state.legendary.glory.enabled and FindPlayerAuraByID( 324143 ) then
                gloryRage = ( gloryRage + lastRage - current ) % 10 -- Glory.
            end

            if state.set_bonus.tier28_2pc > 0 or state.talent.violent_outburst.enabled then
                outburstRage = ( outburstRage + lastRage - current ) % 30 -- Outburst T28 or Violent Outburst
            end
        end
        lastRage = current
    end
end )


-- model rage expenditure and special effects
spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" and amt < 0 then
        if talent.indomitable.enabled or talent.anger_management.enabled then
            rage_spent = rage_spent + amt
            local activations = floor( rage_spent / 10 )
            rage_spent = rage_spent % 10

            if activations > 0 then
                if talent.anger_management.enabled then
                    if talent.shield_wall.enabled then
                        cooldown.shield_wall.expires = cooldown.shield_wall.expires - activations
                    end
                    if talent.avatar.enabled then
                        cooldown.avatar.expires = cooldown.avatar.expires - activations
                    end
                end
                if talent.indomitable.enabled then
                    gain( (0.1 * activations) * health.max, "health" )
                end
            end
        end

        if legendary.glory.enabled and buff.conquerors_banner.up then
            glory_rage = glory_rage + amt
            local addition = floor( glory_rage / 10 ) * 0.5
            glory_rage = glory_rage % 10

            buff.conquerors_banner.expires = buff.conquerors_banner.expires + addition
        end

        if set_bonus.tier28_2pc > 0 or talent.violent_outburst.enabled then
            outburst_rage = outburst_rage + amt
            local stacks = floor( outburst_rage / 30 )
            outburst_rage = outburst_rage % 30
            if stacks > 0 then
                if set_bonus.tier28_2pc > 0 then
                    addStack( "seeing_red_tier28", nil, stacks ) end
                if talent.violent_outburst.enabled then
                    addStack( "seeing_red", nil, stacks )
                end
            end
        end
    end
end )

spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )

-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = function () return -10 * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.immovable_object.enabled then
                applyBuff("shield_wall", 4)
            end
            if set_bonus.tier28_4pc > 0 then
                applyBuff( "outburst" )
                applyBuff( "outburst_buff" )
            end
        end,
    },


    battle_shout = {
        id = 6673,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        startsCombat = false,
        texture = 132333,

        nobuff = "battle_shout",
        essential = true,

        handler = function ()
            applyBuff( "battle_shout" )
        end,
    },


    battle_stance = {
        id = 386164,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "battle_stance",
        startsCombat = false,
        texture = 132349,

        handler = function ()
            applyBuff( "battle_stance" )
            removeBuff( "defensive_stance" )
        end,
    },


    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_rage",
        startsCombat = false,
        texture = 136009,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "berserker_rage" )
        end,
    },


    berserker_shout = {
        id = 384100,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_shout",
        startsCombat = false,
        texture = 136009,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "berserker_shout" )
        end,
    },


    bitter_immunity = {
        id = 383762,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "bitter_immunity",
        startsCombat = false,
        texture = 136088,

        toggle = "cooldowns",

        handler = function ()
            gain( 0.2 * health.max, "health" )
        end,
    },


    bodyguard = {
        id = 213871,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        pvptalent = "bodyguard",
        startsCombat = false,
        texture = 132359,

        handler = function ()
        end,
    },


    challenging_shout = {
        id = 1161,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "challenging_shout",
        startsCombat = true,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "challenging_shout" )
            active_dot.challenging_shout = active_enemies
        end,
    },


    charge = {
        id = 100,
        cast = 0,
        charges  = function () return talent.double_time.enabled and 2 or 1 end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",

        spend = function () return -20 * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spentType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.minR > 7, "requires 8 yard range or more" end,

        handler = function ()
            applyDebuff( "target", "charge" )
            if legendary.reprisal.enabled then
                applyBuff( "shield_block", 4 )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end
        end,
    },


    defensive_stance = {
        id = 386208,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "defensive_stance",
        startsCombat = false,
        texture = 132341,

        essential = true,

        handler = function ()
            removeBuff( "battle_stance" )
            applyBuff( "defensive_stance" )
        end,
    },


    demoralizing_shout = {
        id = 1160,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = function () return (talent.booming_voice.enabled and -30 or 0) * (buff.unnerving_focus.up and 1.5 or 1) end,
        spendType = "rage",

        talent = "demoralizing_shout",
        startsCombat = false,
        texture = 132366,

        handler = function ()
            applyDebuff( "target", "demoralizing_shout" )
            active_dot.demoralizing_shout = max( active_dot.demoralizing_shout, active_enemies )
        end,
    },


    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 135291,

        notalent = "devastator",

        handler = function ()
            applyDebuff( "target", "deep_wounds" )
        end,
    },


    disarm = {
        id = 236077,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "disarm",
        startsCombat = false,
        texture = 132343,

        handler = function ()
            applyDebuff( "target", "disarm")
        end,
    },


    disrupting_shout = {
        id = 386071,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "disrupting_shout",
        startsCombat = false,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "disrupting_shout" )
            active_dot.disrupting_shout = active_enemie
        end,
    },


    dragon_charge = {
        id = 206572,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        pvptalent = "dragon_charge",
        startsCombat = false,
        texture = 1380676,

        handler = function ()
        end,
    },


    execute = {
        id = function () return talent.massacre.enabled and 281000 or 163201 end,
        known = 163201,
        copy = { 163201, 281000 },
        noOverride = 317485, -- Condemn
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        usable = function ()
            if buff.sudden_death.up then return true end
            if cycle_for_execute then return true end
            return target.health_pct < ( talent.massacre.enabled and 35 or 20 ), "requires < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
        end,

        cycle = "execute_ineligible",

        indicator = function () if cycle_for_execute then return "cycle" end end,

        timeToReady = function()
            -- Instead of using regular resource requirements, we'll use timeToReady to support the spend system.
            if rage.current >= 20 then return 0 end
            return rage.time_to_20
        end,

        handler = function ()
            if not buff.sudden_death.up then
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true)
                gain( cost * 0.2, "rage" ) -- Regain 20% for target not dying (Protection spec)
            else
                removeBuff( "sudden_death" )
            end
            if talent.juggernaut.enabled then addStack( "juggernaut", nil, 1 ) end
        end,
        auras = {
            -- Target Swapping
            execute_ineligible = {
                duration = 3600,
                max_stack = 1,
                generate = function( t, auraType )
                    if buff.sudden_death.down and target.health_pct > ( talent.massacre.enabled and 35 or 20 ) then
                        t.count = 1
                        t.expires = query_time + 3600
                        t.applied = query_time
                        t.duration = 3600
                        t.caster = "player"
                        return
                    end
                    t.count = 0
                    t.expires = 0
                    t.applied = 0
                    t.caster = "nobody"
                end
            }
        }
    },


    hamstring = {
        id = 1715,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 132316,

        handler = function ()
            applyDebuff( "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
        charges = function () return legendary.leaper.enabled and 3 or nil end,
        recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
        gcd = "off",

        talent = "heroic_leap",
        startsCombat = false,
        texture = 236171,

        handler = function ()
            if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
        end,
    },


    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        startsCombat = true,
        texture = 132453,

        handler = function ()
            if talent.improved_heroic_throw.enabled then applyDebuff( "target", "deep_wounds" ) end
        end,
    },


    ignore_pain = {
        id = 190456,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 35,
        spendType = "rage",

        talent = "ignore_pain",
        startsCombat = false,
        texture = 1377132,

        toggle = "defensives",

        readyTime = function ()
            if settings.overlap_ignore_pain then return end

            if buff.ignore_pain.up and buff.ignore_pain.v1 > 0.3 * stat.attack_power * 3.5 * ( 1 + stat.versatility_atk_mod / 100 ) then
                return buff.ignore_pain.remains - gcd.max
            end

            return 0
        end,

        handler = function ()

            applyBuff( "ignore_pain" )
        end,
    },


    impending_victory = {
        id = 202168,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "impending_victory",
        startsCombat = false,
        texture = 589768,

        handler = function ()
            gain( health.max * 0.3, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "intervene",
        startsCombat = false,
        texture = 132365,

        handler = function ()
            if legendary.reprisal.enabled then
                applyBuff( "shield_block", 4 )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end
        end,
    },


    intimidating_shout = {
        id = 316593,
        copy = { 316593, 5246 },
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "intimidating_shout",
        startsCombat = true,
        texture = 132154,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "intimidating_shout" )
            active_dot.intimidating_shout = max( active_dot.intimidating_shout, active_enemies )
        end,
    },


    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = function() return 180 - ( talent.bolster.enabled and 60 or 0 ) end,
        gcd = "off",

        talent = "last_stand",
        startsCombat = false,
        texture = 135871,

        toggle = "cooldowns",

        usable = function()
            if settings.last_stand_offensively and talent.unnerving_focus.enabled then
                return true
            else
                return incoming_damage_3s > 0.3 * health.max, "requires 30% health incoming damage in 3s"
            end
        end,

        handler = function ()
            applyBuff( "last_stand" )

            if talent.bolster.enabled then
                applyBuff( "shield_block", buff.last_stand.duration )
            end

            if talent.unnerving_focus.enabled then
                applyBuff( "unnerving_focus" )
            end
        end,
    },


    oppressor = {
        id = 205800,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "oppressor",
        startsCombat = false,
        texture = 136080,

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end
    },


    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "piercing_howl",
        startsCombat = false,
        texture = 136147,

        handler = function ()
            applyDebuff( "target", "piercing_howl" )
            active_dot.piercing_howl = max( active_dot.piercing_howl, active_enemies )
        end,
    },


    pummel = {
        id = 6552,
        cast = 0,
        cooldown = function () return 15 - (talent.concussive_blows.enabled and 1 or 0) - (talent.honed_reflexes.enabled and 1 or 0) end,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
            readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.concussive_blows.enabled then
                applyDebuff( "target", "concussive_blows" )
            end
        end,
    },


    rallying_cry = {
        id = 97462,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "rallying_cry",
        startsCombat = false,
        texture = 132351,

        toggle = "cooldowns",
        shared = "player",

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( (talent.inspiring_presence.enabled and 0.25 or 0.15) * health.max, "health" )
        end,
    },


    ravager = {
        id = 228920,
        cast = 0,
        charges = function () return (talent.storm_of_steel.enabled and 2 or 1) end,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",

        talent = "ravager",
        startsCombat = true,
        texture = 970854,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ravager" )
        end,
    },


    rend = {
        id = 394062,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        talent = "rend",
        startsCombat = true,
        texture = 132155,

        handler = function ()
            applyDebuff ( "target", "rend" )
        end,
    },


    revenge = {
        id = 6572,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.revenge.up then return 0 end
            return  talent.barbaric_training.enabled and 30 or 20
        end,
        spendType = "rage",

        talent = "revenge",
        startsCombat = true,
        texture = 132353,

        usable = function ()
            if action.revenge.cost == 0 then return true end
            if toggle.defensives and buff.ignore_pain.down and incoming_damage_5s > 0.1 * health.max then return false, "don't spend on revenge if ignore_pain is down and there is incoming damage" end
            if settings.free_revenge and action.revenge.cost ~= 0 then return false, "free_revenge is checked and revenge is not free" end
            return true
        end,

        handler = function ()
            if state.set_bonus.tier29_2pc > 0 then applyBuff( "vanguards_determination" ) end
            if buff.revenge.up then removeBuff( "revenge" ) end
            if talent.show_of_force.enabled then applyBuff( "show_of_force" ) end
            applyDebuff ( "target", "deep_wounds" )
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = false,
        texture = 311430,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shield_bash = {
        id = 198912,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        spend = -3,
        spendType = "rage",

        pvptalent = "shield_bash",
        startsCombat = false,
        texture = 132357,

        handler = function ()
            applyDebuff ( "target", "shield_bash")
        end,
    },


    shield_block = {
        id = 2565,
        cast = 0,
        charges = 2,
        cooldown = 16,
        recharge = 16,
        hasteCD = true,
        gcd = "off",

        toggle = "defensives",
        defensive = true,

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132110,

        nobuff = function()
            if not settings.stack_shield_block or not legendary.reprisal.enabled then return "shield_block" end
        end,

        handler = function ()
            applyBuff( "shield_block" )
        end,
    },


    shield_charge = {
        id = 385952,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        spend = -20,
        spendType = "rage",

        talent = "shield_charge",
        startsCombat = true,
        texture = 4667427,

        handler = function ()
            if talent.battering_ram.enabled then
                applyBuff( "battering_ram" )
            end
            if talent.champions_bulwark.enabled then
                applyBuff( "shield_block" )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end
        end,
    },


    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = function () return 9 - (talent.honed_reflexes.enabled and 1 or 0) end,
        hasteCD = true,
        gcd = "spell",

        spend = function ()
            local reduction = 0
            -- The Wall Legendary overtakes the new Impenetrable Wall talent, they do not stack in 10.0
            if legendary.the_wall.enabled then reduction = -5
            elseif talent.impenetrable_wall.enabled then reduction = -3
            end

            return
            ( -15 + reduction + ( talent.heavy_repercussions.enabled and -2 or 0 ) )
            * ( buff.violent_outburst.up and 1.5 or 1) -- Build 45969
            * ( buff.unnerving_focus.up and 1.5 or 1)
        end,
        spendType = "rage",

        startsCombat = true,
        texture = 134951,

        handler = function ()
            if talent.brace_for_impact.enabled then applyBuff ( "brace_for_impact" ) end

            if talent.punish.enabled then applyDebuff ( "target" , "punish" ) end

            if ( legendary.the_wall.enabled or talent.impenetrable_wall.enabled ) and cooldown.shield_wall.remains > 0 then
                reduceCooldown( "shield_wall", 5 )
            end

            if talent.heavy_repercussions.enabled and buff.shield_block.up then
                buff.shield_block.expires = buff.shield_block.expires + 1
            end

            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end

            if buff.outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "outburst" )
            end
        end,
    },


    shield_wall = {
        id = 871,
        cast = 0,
        charges = function () return 1 + ( talent.shield_wall.enabled and 1 or 0 ) + ( legendary.unbreakable_will.enabled and 1 or 0 ) end,
        cooldown = function() return 210 - ( conduit.stalwart_guardian.enabled and 20 or 0 ) end,
        recharge = function() return 210 - ( conduit.stalwart_guardian.enabled and 20 or 0 ) end,
        gcd = "off",

        talent = "shield_wall",
        startsCombat = false,
        texture = 132362,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "shield_wall" )
            if talent.immovable_object.enabled then applyBuff ( "avatar", 10 ) end
        end,
    },


    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function () return
            ((
                ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40)
                - ( conduit.disturb_the_peace.enabled and 5 or 0 )
            ) end,
        gcd = "spell",

        talent = "shockwave",
        startsCombat = true,
        texture = 236312,

        toggle = "interrupts",
        debuff = function () return settings.shockwave_interrupt and "casting" or nil end,
        readyTime = function () return settings.shockwave_interrupt and timeToInterrupt() or nil end,

        usable = function () return not target.is_boss end,

        handler = function ()
            applyDebuff( "target", "shockwave" )
            active_dot.shockwave = max( active_dot.shockwave, active_enemies )
            if not target.is_boss then interrupt() end
        end,
    },


    slam = {
        id = 1464,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
        end,
    },


    spear_of_bastion = {
        id = 376079,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = function () return (-25 * ( talent.piercing_verdict.enabled and 2 or 1 ) ) * (buff.unnerving_focus.up and 1.5 or 1) end,
        spendType = "rage",

        talent = "spear_of_bastion",
        startsCombat = false,
        texture = 3565453,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff ("target", "spear_of_bastion" )
        end,
    },


    spell_block = {
        id = 392966,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "spell_block",
        startsCombat = false,
        texture = 132358,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "spell_block" )
        end,
    },


    spell_reflection = {
        id = 23920,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "off",

        talent = "spell_reflection",
        startsCombat = false,
        texture = 132361,
        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            applyBuff( "spell_reflection" )
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "storm_bolt",
        startsCombat = true,
        texture = 613535,

        handler = function ()
            applyDebuff( "target", "storm_bolt" )
        end,
    },


    taunt = {
        id = 355,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136080,

        handler = function ()
            applyDebuff( "target", "taunt" )
        end,
    },


    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = function () return haste * ( ( buff.avatar.up and talent.unstoppable_force.enabled ) and 3 or 6 ) end,
        gcd = "spell",
        hasteCD = true,

        spend = function () return -5
            * (buff.violent_outburst.up and 1.5 or 1 ) -- Build xxx
            * (buff.unnerving_focus.up and 1.5 or 1) end,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

            if ( legendary.thunderlord.enabled or talent.thunderlord.enabled ) and cooldown.demoralizing_shout.remains > 0 then
                reduceCooldown( "demoralizing_shout", min( 3, active_enemies ) )
            end

            if talent.blood_and_thunder.enabled and talent.rend.enabled then -- Blood and Thunder now directly applies Rend to 5 nearby targets
                applyDebuff( "target", "rend" )
                active_dot.rend = min( active_enemies, 5 )
            end

            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end

            if buff.outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "outburst" )
            end
        end,
    },


    thunderous_roar = {
        id = 384318,
        cast = 0,
        cooldown = function() return 90 - (talent.uproar.enabled and 30 or 0 ) end,
        gcd = "spell",

        spend = -10,
        spendType = "rage",

        talent = "thunderous_roar",
        startsCombat = true,
        texture = 642418,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff ("target", "thunderous_roar" )
            active_dot.thunderous_roar = max( active_dot.thunderous_roar, active_enemies )
        end,
    },


    titanic_throw = {
        id = 384090,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        talent = "titanic_throw",
        startsCombat = true,
        texture = 132453,

        handler = function ()
            if talent.improved_heroic_throw.enabled then
                applyDebuff( "target", "deep_wounds" )
                active_dot.deep_wounds = min( active_enemies, 5 )
            end
        end,
    },


    victory_rush = {
        id = 34428,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132342,

        buff = "victorious",
        handler = function ()
            removeBuff( "victorious" )
            gain( 0.2 * health.max, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132369,

        handler = function ()
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = false,
        texture = 460959,

        handler = function ()
        end,
    },
} )


spec:RegisterSetting( "free_revenge", true, {
    name = "Only |T132353:0|t Revenge when Free",
    desc = "If checked, the |T132353:0|t Revenge ability will only be recommended when it costs 0 Rage to use.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting (and talented).",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "overlap_ignore_pain", false, {
    name = "Overlap |T1377132:0|t Ignore Pain",
    desc = "If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active.  This setting may cause you to spend more Rage on mitigation.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "stack_shield_block", false, {
    name = "Overlap |T132110:0|t Shield Block",
    desc = function()
        return "If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage. \n\n" ..
        "This setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time."
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "last_stand_offensively", false, {
    name = "Use |T135871:0|t Last Stand Offensively",
    desc = function()
        return "If checked, the addon will recommend using |T135871:0|t Last Stand to generate rage.\n\n"
            .. "If unchecked, the addon will only recommend |T135871:0|t Last Stand defensively after taking significant damage.\n\n"
            .. ( state.talent.unnerving_focus.enabled and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires |T571316:0|t Unnerving Focus|r"        
    end,
    type = "toggle",
    width = "full"
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_phantom_fire",

    package = "Protection Warrior",
} )


spec:RegisterPack( "Protection Warrior", 20221026, [[Hekili:1M1EVTTTw8plRfWXg3cfzNy7KI4a0BxXwlcslQhW2FjjAjkBDJSOVuuPldg6Z(ohs9GuVCsxhkQJm55878GhEEy5m153CwhqeuN7NzpB2u7zlSME1u7lx4Sw80bQZ6de)hiBHhsi7Hp)cNjO(IiwsU3Vt48ighP5PygjaXkLLX9b62jehsF75NVnsSlBJLpB)5Pr7ZIjiR(CsOa)U)5oR3Kffl(yIZMUvK5aMhO(o3V8ca1OGaQIuAQFNAt(NMTi37Z(c2gkp3dbl3B80WGnxn76j5Fk)tFmjserIZ9(zozlljmoA7orUx0(dmUWcSgolmkgSHx)6CVoLaUXPKcsZWscPIiHo16aNcUOneX)z15HX00DsxKeNCVp8Nu)mbni3J(iL)uUNiApf(Ch8baaOrErPWJpsIIjBIPwv4cO5VJW3sFtu4kKRv267DiB)EAS(kGRoo2LtbDqz0O8)zAijlgu839L7ode0R(vkNf5N79Ej2VQq85ELRFhLCi3lKfhZ(gQ2BEQKwqRz5EbW)tzOneq2tWvjjazBPjuoecK79vyrdRyNez3yay0usPcruY2uRI1vg5iEwcnKbpzXPh4rPK4r(mwCa7BjwksGn2tIssVzRFq3EPNp0Wz2JwtT0unDeJseu(JGfHGUjlmeye(kaaQoJgdre0BUY(4r5dlxosstmjv4Mka3Hv2HjDivDrKLsDJe09POiQmuimqq4vg6kWspEucEXozg65MyglWnmJ)uLI2nDuEkL)a4AgMUWiovI5WKrs8PPcoj21NehpmTqgKKak31pwD6lPKLj2KXtfaTJgpwUukLcQhe9gybUq)hUDr9XF6UiACGBAmzFPR52ztMyOssz3wai)g3Ay4tTv5JhfyOIWcVO5kyUbr0BMnVX1lc3Lf6UboNLxVQ3Ri8Ov4cAFfaVJsIf7So4lUDge5OUSQ2l1s3lD7ftg00ncu3MW4u3dW6YSeTe1Qz2DPbRUYE0p5ZaLKKiSG)i29eFIkWg2CEFkaj4jvSEXYqWI)ds3NIZf21Cgq3ZGyKO)cpxt3bhjfaiiXGaT2Wy7XTEeUbsTanbY(fuc0snGQUuamxU)L)tfuhxzlXE(8UL9aSuMlWK5E8D6r)d5mVW(LdLH21j6tEdM6Hfg6cjxwn1icxJsmCACB(rLPiJKX6LzSgkWDYOUUkORa1AFprZxBxDrTE5BwzIs74bfAdemiZJVWUdNbAaDM3sYcCCBKgilXv9n34OuXBW2UwryQAtdCH3OAgKsTniYYRq5z9K6KTy2ibS8dgjfiCFscMeJZblgLDr9kdxn2otQ7)lly7EGk9(zafg44rGhUXI155AUSU10Cpn)OUqkmO2cQydGtQQ1PU2Ya02BpCrhJAcAC1Y4Q3kG(ieAID4Ug6Ilf2v1QR91tHEC)gHNGTD4S(3F3xV)J3)lVn3l373Ww8uTlI9tbn6DwGQzSZY940)FguSnOSxksMGTNi7teAAb0IuOfQ7IsGTUeq79SeqUYTpRUVI)4mvlz6lvgsFg2s7FoPcL5)qqzX3lkeWh8HpFxfCqN8spdIYLYoHXkQEyapA5oRLpHdLarrWFUxoSJImN1fbnoRleGZ)1rahigKOomBqYf6KOhL0GUl1PtlyZKmHZ6IqKVhnSi8EinSxjRuW6vw7ZHMj5reCKSMX69yXakZpThBHojAxdA4hkISR8dAQwjZQMXvt)XJoOw8fpEKUPQODvUNDlNRA6Ob9TnMw6eo4s20MyOHP0CslZbT(xAolD3r3t)K7ncs30AwKY7MYT7zqRCVBab6hufQ0za33VyBpewROLYiW(d11NmtI6yqUs)fO8qnpVJh1wy5sjnT7vk3BYju5ADRA8qu9w2R61ZuDGESs6wvQM5Ci1cPAaruixnSpOd2Rhne5)6xo)vJmI8p1(fdq1SKs(BMu408BoKPeKzpZKE4PPkqyCH)T50L5E3cfZmJ97AulKSzYqJj9NfD6fpt9YmzSYMLaCIS51dwlJyApPQm0E2CT0FYXCLypVrspJzyBK0B6Z8UwTdUvZ4kxwX1U(75vs2fLx6g6mODbkurBERR6Qz9aXgvk6qnxP0Z(TJvQ8hab)eQIMdlxQ6vzBKKpFiZbMARo5tJPY0ttHiTW2eP(MXvs1qJ20e4LnawFa3M0E5poLONCUMYB(8H0TNfeMj87c0botAMa55CqDH9)m4Byn9k1jQkcfZTJDzHxd6VUW4UasvJSQQtxtWltLmCoXjfN3DFZVv3Rs4LAB)vH656312gz803(MvMcR2pk7fS)6vNmoTQxHf26D(2m0xkMtuwR5jEb0YOYU7YhbT)YCNkFQwUsZFjc18uUQxdeorfkNMLTQA9QXVaHbZLd8GaymLKXphrZ5E6V7rTw10knA8lyirWyoKg)4fTMgP6nY40CUS63pttMGfGHW3HVsS1vVSR3lPe)NZFd]] )
