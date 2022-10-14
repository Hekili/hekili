-- WarriorFury.lua
-- October 2022
-- Updated for PTR Build 46047 (RC)
-- Last Modified 10/14/2020 4:09 UTC

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 72 )

local base_rage_gen, fury_rage_mult = 1.75, 1.00
local offhand_mod = 0.50

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand_fury = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time

            return swing + floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed
        end,

        interval = "mainhand_speed",

        stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
        value = function ()
             -- annihilator: auto-attacks deal an additional (10% of Attack power) Physical damage and generate 2 Rage.
             -- swift strikes: annihilator generates 2 additional rage
            return ( ( ( state.talent.war_machine.enabled and 1.2 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed )
            + ( state.talent.annihilator.enabled and (state.talent.swift_strikes.rank > 0 and 2 + (state.talent.swift_strikes.rank * 1 ) or 2 ) or 0 )
            )
        end
    },

    offhand_fury = {
        swing = "offhand",

        last = function ()
            local swing = state.swings.offhand
            local t = state.query_time

            return swing + floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed
        end,

        interval = "offhand_speed",

        stop = function () return state.time == 0 or state.swings.offhand == 0 end,
        value = function ()
            -- annihilator: auto-attacks deal an additional (10% of Attack power) Physical damage and generate 2 Rage.
            -- swift strikes: annihilator generates 2 additional rage
            return ( ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.offhand_speed * offhand_mod )
            + ( state.talent.annihilator.enabled and (state.talent.swift_strikes.rank > 0 and 2 + (state.talent.swift_strikes.rank * 1 ) or 2 ) or 0 )
        end,
    },

    battle_trance = {
        aura = "battle_trance",

        last = function ()
            local app = state.buff.battle_trance.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 3 ) * 3
        end,

        interval = 3,
        value = 5,
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

    ravager = {
        aura = "ravager",

        last = function ()
            local app = state.buff.ravager.applied
            local t = state.query_time

            return app + floor( ( t - app ) / state.haste ) * state.haste
        end,

        interval = function () return state.haste end,

        value = function () return state.talent.storm_of_steel.enabled and 15 or 10 end,
    },
} )


-- Talents
spec:RegisterTalents( {
    anger_management          = { 90415, 152278, 1 }, --
    annihilator               = { 90419, 383916, 1 }, --
    armored_to_the_teeth      = { 90258, 384124, 2 }, --
    ashen_juggernaut          = { 90409, 392536, 1 }, --
    avatar                    = { 90365, 107574, 1 }, --
    barbaric_training         = { 90335, 390674, 1 }, --
    berserker_rage            = { 90372, 18499 , 1 }, --
    berserker_shout           = { 90348, 384100, 1 }, --
    berserker_stance          = { 90325, 386196, 1 }, --
    berserkers_torment        = { 90362, 390123, 1 }, --
    bitter_immunity           = { 90356, 383762, 1 }, --
    blood_and_thunder         = { 90342, 384277, 1 }, --
    bloodborne                = { 90401, 385703, 1 }, --
    bloodcraze                = { 90405, 393950, 1 }, --
    bloodthirst               = { 90392, 23881 , 1 }, --
    bounding_stride           = { 90355, 202163, 1 }, --
    cacophonous_roar          = { 90383, 382954, 1 }, --
    cold_steel_hot_blood      = { 90402, 383959, 1 }, --
    concussive_blows          = { 90335, 383115, 1 }, --
    crackling_thunder         = { 90342, 203201, 1 }, --
    critical_thinking         = { 90425, 383297, 2 }, --
    cruel_strikes             = { 90381, 392777, 2 }, --
    cruelty                   = { 90428, 392931, 1 }, --
    crushing_force            = { 90349, 382764, 2 }, --
    dancing_blades            = { 90417, 391683, 1 }, --
    defensive_stance          = { 90330, 386208, 1 }, --
    deft_experience           = { 90421, 383295, 2 }, --
    depths_of_insanity        = { 90413, 383922, 1 }, --
    double_time               = { 90382, 103827, 1 }, --
    dual_wield_specialization = { 90373, 382900, 1 }, --
    elysian_might             = { 90323, 386285, 1 }, --
    endurance_training        = { 90376, 391997, 1 }, --
    enraged_regeneration      = { 90395, 184364, 1 }, --
    fast_footwork             = { 90371, 382260, 1 }, --
    focus_in_chaos            = { 90403, 383486, 1 }, --
    frenzied_flurry           = { 90422, 383605, 1 }, --
    frenzy                    = { 90406, 335077, 1 }, --
    fresh_meat                = { 90399, 215568, 1 }, --
    frothing_berserker        = { 90350, 215571, 1 }, --
    furious_blows             = { 90336, 390354, 1 }, --
    hack_and_slash            = { 90407, 383877, 1 }, --
    heroic_leap               = { 90346, 6544  , 1 }, --
    honed_reflexes            = { 90367, 391270, 1 }, --
    hurricane                 = { 90389, 390563, 1 }, --
    impending_victory         = { 90326, 202168, 1 }, --
    improved_bloodthirst      = { 90397, 383852, 1 }, --
    improved_enrage           = { 90398, 383848, 1 }, --
    improved_execute          = { 90430, 316402, 1 }, --
    improved_raging_blow      = { 90390, 383854, 1 }, --
    improved_whirlwind        = { 90427, 12950 , 1 }, --
    inspiring_presence        = { 90332, 382310, 1 }, --
    intervene                 = { 90329, 3411  , 1 }, --
    intimidating_shout        = { 90384, 5246  , 1 }, --
    invigorating_fury         = { 90393, 383468, 1 }, --
    leeching_strikes          = { 90344, 382258, 1 }, --
    massacre                  = { 90410, 206315, 1 }, --
    meat_cleaver              = { 90391, 280392, 1 }, --
    menace                    = { 90383, 275338, 1 }, --
    odyns_fury                = { 90418, 385059, 1 }, --
    onslaught                 = { 90424, 315720, 1 }, --
    overwhelming_rage         = { 90378, 382767, 2 }, --
    pain_and_gain             = { 90353, 382549, 1 }, --
    piercing_howl             = { 90348, 12323 , 1 }, --
    piercing_verdict          = { 90379, 382948, 1 }, --
    raging_armaments          = { 90426, 388049, 1 }, --
    raging_blow               = { 90396, 85288 , 1 }, --
    rallying_cry              = { 90331, 97462 , 1 }, --
    rampage                   = { 90408, 184367, 1 }, --
    ravager                   = { 90388, 228920, 1 }, --
    reckless_abandon          = { 90415, 202751, 1 }, --
    recklessness              = { 90412, 1719  , 1 }, --
    reinforced_plates         = { 90368, 382939, 1 }, --
    rumbling_earth            = { 90374, 275339, 1 }, --
    second_wind               = { 90332, 29838 , 1 }, --
    seismic_reverberation     = { 90340, 382956, 1 }, --
    shattering_throw          = { 90351, 64382 , 1 }, --
    shockwave                 = { 90375, 46968 , 1 }, --
    sidearm                   = { 90377, 384404, 1 }, --
    singleminded_fury         = { 90400, 81099 , 1 }, --
    slaughtering_strikes      = { 90411, 388004, 1 }, --
    sonic_boom                = { 90321, 390725, 1 }, --
    spear_of_bastion          = { 90380, 376079, 1 }, --
    spell_reflection          = { 90385, 23920 , 1 }, --
    storm_bolt                = { 90337, 107570, 1 }, --
    storm_of_steel            = { 90389, 382953, 1 }, --
    storm_of_swords           = { 90420, 388903, 1 }, --
    sudden_death              = { 90429, 280721, 1 }, --
    swift_strikes             = { 90416, 383459, 2 }, --
    tenderize                 = { 90423, 388933, 1 }, --
    thunder_clap              = { 90343, 6343  , 1 }, --
    thunderous_roar           = { 90359, 384318, 1 }, --
    thunderous_words          = { 90358, 384969, 1 }, --
    titanic_rage              = { 90417, 394329, 1 }, --
    titanic_throw             = { 90341, 384090, 1 }, --
    titans_torment            = { 90362, 390135, 1 }, --
    unbridled_ferocity        = { 90414, 389603, 1 }, --
    uproar                    = { 90357, 391572, 1 }, --
    vicious_contempt          = { 90404, 383885, 2 }, --
    war_machine               = { 90386, 346002, 1 }, --
    warpaint                  = { 90394, 208154, 1 }, --
    wild_strikes              = { 90360, 382946, 2 }, --
    wrath_and_fury            = { 90387, 392936, 1 }, --
    wrecking_throw            = { 90351, 384110, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    barbarian            = 166 , -- 280745
    battle_trance        = 170 , -- 213857
    bloodrage            = 172 , -- 329038
    death_sentence       = 25  , -- 198500
    death_wish           = 179 , -- 199261
    demolition           = 5373, -- 329033
    disarm               = 3533, -- 236077
    enduring_rage        = 177 , -- 198877
    master_and_commander = 3528, -- 235941
    rebound              = 5548, -- 213915
    slaughterhouse       = 3735, -- 352998
    warbringer           = 5431, -- 356353
} )

-- Tier 28
spec:RegisterSetBonuses( "tier28_2pc", 364554, "tier28_4pc", 363738 )
-- 2-Set - Frenzied Destruction - Raging Blow deals 15% increased damage and gains an additional charge.
-- 4-Set - Frenzied Destruction - Raging Blow has a 20% chance to grant Recklessness for 4 sec.
-- Now appropriately grants Crushing Blow and Bloodbath when Reckless Abandon is talented, and no longer grants 50 Rage when Recklessness triggers while Reckless Abandon is talented.

local RAGE = Enum.PowerType.Rage
local lastRage = -1
local rageSpent = 0
local gloryRage = 0
local fresh_meat_actual = {}
local fresh_meat_virtual = {}
local whirlwind_stacks = 0
local last_rampage_target = nil
local whirlwind_consumers = {
    crushing_blow = 1,
    bloodbath = 1,
    bloodthirst = 1,
    execute = 1,
    impending_victory = 1,
    raging_blow = 1,
    rampage = 1,
    victory_rush = 1,
    onslaught = 1
}
local wipe = table.wipe

spec:RegisterStateExpr( "rage_spent", function ()
    return rageSpent
end )

spec:RegisterStateExpr( "glory_rage", function ()
    return gloryRage
end )

local WillOfTheBerserker = setfenv( function()
    applyBuff( "will_of_the_berserker" )
end, state )

local TriggerColdSteelHotBlood = setfenv( function()
    applyDebuff( "target", "gushing_wound" )
    gain( 4, "rage" )
end, state )

local TriggerHurricane = setfenv( function()
    addStack( "hurricane", nil, 1 )
end, state )

TriggerSlaughteringStrikesAnnihilator = setfenv( function()
    addStack( "slaughtering_strikes_annihilator", nil, 1 )
end, state )

RemoveFrenzy = setfenv( function()
    removeBuff( "frenzy" )
end, state )

spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, critical )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]
            if not ability then return end
            if state.talent.improved_whirlwind.enabled and ability.key == "whirlwind" then
                whirlwind_stacks = state.talent.meat_cleaver.enabled and 4 or 2
            elseif whirlwind_consumers[ ability.key ] and whirlwind_stacks > 0 then
                whirlwind_stacks = whirlwind_stacks - 1
            elseif ability.key == "conquerors_banner" then
                rageSinceBanner = 0
            elseif ability.key == "rampage" and last_rampage_target ~= destGUID then
                RemoveFrenzy()
                last_rampage_target = destGUID
            end

        elseif subtype == "SPELL_DAMAGE" and UnitGUID( "target" ) == destGUID then
            local ability = class.abilities[ spellID ]
            if not ability then return end
            if ability.key == "bloodthirst" or ability.key == "bloodbath" then
                if critical and state.talent.cold_steel_hot_blood.enabled then -- Critical boolean is the 21st parameter in SPELL_DAMAGE within CLEU (Ref: https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT#Payload)
                    TriggerColdSteelHotBlood() -- Bloodthirst/bath critical strike occured.
                elseif state.talent.fresh_meat.enabled and not fresh_meat_actual[ destGUID ] then
                    fresh_meat_actual[ destGUID ] = true
                end
            end
        elseif subtype == "SWING_DAMAGE" and UnitGUID( "target" ) == destGUID then
            -- amt is the 12th parameter in SWING_DAMAGE within CLEU (Ref: https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT#Payload)
            local amt = spellID
            if amt > 0 and state.talent.annihilator.enabled and state.talent.slaughtering_strikes.enabled then
                TriggerSlaughteringStrikesAnnihilator()
            end
        end
    end
end )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
    wipe( fresh_meat_actual )
end )

spec:RegisterHook( "UNIT_ELIMINATED", function( id )
    fresh_meat_actual[ id ] = nil
end )

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )
        if current < lastRage then
            -- Glory
            if state.legendary.glory.enabled and state.buff.conquerors_banner.up then
                gloryRage = ( gloryRage + lastRage - current ) % 20
            end
            -- Anger Management
            if state.talent.anger_management.enabled then
                rageSpent = ( rageSpent + lastRage - current ) % 10
            end
        end
        lastRage = current
    end
end )

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" then
        if talent.anger_management.enabled then
            rage_spent = rage_spent + amt
            local reduction = floor( rage_spent / 20 )
            rage_spent = rage_spent % 20

            if reduction > 0 then cooldown.recklessness.expires = cooldown.recklessness.expires - reduction end
        end

        if legendary.glory.enabled and buff.conquerors_banner.up then
            glory_rage = glory_rage + amt
            local reduction = floor( glory_rage / 20 ) * 0.5
            glory_rage = glory_rage % 20

            buff.conquerors_banner.expires = buff.conquerors_banner.expires + reduction
        end
    end
end )

spec:RegisterHook( "reset_precast", function ()
    rage_spent = nil
    rage_since_banner = nil

    if buff.whirlwind.up then
        if whirlwind_stacks == 0 then removeBuff( "whirlwind" )
        elseif whirlwind_stacks < buff.whirlwind.stack then
            applyBuff( "whirlwind", buff.whirlwind.remains, whirlwind_stacks )
        end
    end

    if legendary.will_of_the_berserker.enabled and buff.recklessness.up then
        state:QueueAuraExpiration( "recklessness", WillOfTheBerserker, buff.recklessness.expires )
    end

    wipe( fresh_meat_virtual )
    active_dot.hit_by_fresh_meat = 0

    for k, v in pairs( fresh_meat_actual ) do
        fresh_meat_virtual[ k ] = v

        if k == target.unit then
            applyDebuff( "target", "hit_by_fresh_meat" )
        else
            active_dot.hit_by_fresh_meat = active_dot.hit_by_fresh_meat + 1
        end
    end

    if buff.ravager.up and talent.hurricane.enabled then
        local next_hu = query_time + (1 * state.haste) - ( ( query_time - buff.ravager.applied ) % (1 * state.haste) )

        while ( next_hu <= buff.ravager.expires ) do
            state:QueueAuraEvent( "ravager_hurricane", TriggerHurricane, next_hu, "AURA_PERIODIC" )
            next_hu = next_hu + (1 * state.haste)
        end
    end
end )


-- Auras
spec:RegisterAuras( {
    annihilator = {
        id = 383915
    },
    ashen_juggernaut = {
        id = 392537,
        duration = 12,
        max_stack = 5
    },
    avatar = {
        id = 107574,
        duration = 20,
        max_stack = 1
    },
    battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1
    },
    battle_trance = { --PvP Talent
        id = 213858,
        duration = 18,
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
    berserker_stance = {
        id = 386196,
        duration = 3600,
        max_stack = 1
    },
    bloodcraze = {
        id = 393951,
        duration = 20,
        max_stack = 5
    },
    bloodrage = {
        id = 329038,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    bloodthirst = {
        id = 23881,
        duration = 20,
        max_stack = 1
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1
    },
    crushing_impact = {
        id = 394330,
        duration = 6,
        max_stack = 1
    },
    dancing_blades = {
        id = 391688,
        duration = 10,
        max_stack = 1
    },
    death_wish = {
        id = 199261,
        duration = 15,
        max_stack = 10
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    elysian_might = {
        id = 386286,
        duration = 8,
        max_stack = 1
    },
    enrage = {
        id = 184362,
        duration = 4,
        max_stack = 1
    },
    enraged_regeneration = {
        id = 184364,
        duration = function () return state.talent.invigorating_fury.enabled and 11 or 8 end,
        max_stack = 1
    },
    frenzy = {
        id = 335082,
        duration = 12,
        max_stack = 4,
    },
    gushing_wound = {
        id = 385042,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    hurricane = {
        id = 390581,
        duration = 6,
        max_stack = 6
    },
    intimidating_shout = {
        id = 5246,
        duration = 8,
        max_stack = 1
    },
    odyns_fury = {
        id = 385060,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    quick_thinking = {
        id = 392778,
        duration = 10,
        max_stack = 1
    },
    raging_blow = {
        id = 85288,
        duration = 12,
        max_stack = 1
    },
    ravager = {
        id = 228920,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    recklessness = {
        id = 1719,
        duration = function() return state.talent.depths_of_insanity.enabled and 16 or 12 end,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    slaughtering_strikes_annihilator = {
        id = 393943,
        duration = 12,
        max_stack = 5
    },
    slaughtering_strikes_raging_blow = {
        id = 393931,
        duration = 12,
        max_stack = 5
    },
    spear_of_bastion = {
        id = 376080,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    spell_reflection = {
        id = 23920,
        duration = 5,
        max_stack = 1
    },
    spell_reflection_defense = {
        id = 385391,
        duration = 5,
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
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1
    },
    whirlwind = {
        id = 85739,
        duration = 20,
        max_stack = function ()
            if talent.meat_cleaver.enabled then return 4
            elseif talent.improved_whirlwind.enabled then return 2
            else return 0
            end
        end,
        copy = "meat_cleaver"
    },
} )


-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = -10,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.berserkers_torment.enabled then applyBuff ( "recklessness", 4) end
            if talent.titans_torment.enabled then
                applyBuff ( "odyns_fury" )
                active_dot.odyns_fury = max( active_dot.odyns_fury, active_enemies )
                if talent.titanic_rage.enabled then  applyBuff( "crushing_impact" ) end
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


    berserker_stance = {
        id = 386196,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "berserker_stance",
        startsCombat = false,
        texture = 132275,

        essential = true,

        handler = function ()
            applyBuff( "berserker_stance" )
            removeBuff( "defensive_stance" )
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

    bloodbath = {
        id = 335096,
        cast = 0,
        cooldown = function ()
            if talent.deft.experience.enabled then
                return 3 - talent.deft_experience.rank * 0.75
            else
                return 3
            end
        end,
        hasteCD = true,
        gcd = "spell",

        spend = -8,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        talent = "bloodthirst",
        bind = "bloodthirst",
        startsCombat = true,
        texture = 136012,

        handler = function ()
            removeStack( "whirlwind" )
            if talent.bloodcraze.enabled then addStack( "bloodcraze", nil, 1 ) end
            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ) , "health" )
            if talent.invigorating_fury.enabled then gain ( health.max * 0.2 , "health" ) end
            if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                applyBuff( "enrage" )
                applyDebuff( "target", "hit_by_fresh_meat" )
            end
        end,
    },


    bloodrage = {
        id = 329038,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = 6777,
        spendType = "health",

        pvptalent = "bloodrage",
        startsCombat = false,
        texture = 132277,

        handler = function ()
            applyBuff ( "bloodrage" )
            gain( -0.05 * health.max, "health" )
        end,
    },


    bloodthirst = {
        id = 23881,
        cast = 0,
        cooldown = function ()
            if talent.deft_experience.enabled then
                return 4.5 - talent.deft_experience.rank * 0.75
            else
                return 4.5
            end
        end,
        hasteCD = true,
        gcd = "spell",

        spend = -8,
        spendType = "rage",

        talent = "bloodthirst",
        bind = "bloodbath",
        startsCombat = true,
        texture = 136012,

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        readyTime = function()
            if buff.crushing_impact.up then return buff.crushing_impact.remains end
            if talent.reckless_abandon.enabled then return buff.recklessness.remains end
            return 0
        end,

        handler = function ()
            removeStack( "whirlwind" )
            if talent.bloodcraze.enabled then addStack( "bloodcraze", nil, 1 ) end
            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ) , "health" )
            if talent.invigorating_fury.enabled then gain ( health.max * 0.2 , "health" ) end
            if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                applyBuff( "enrage" )
                applyDebuff( "target", "hit_by_fresh_meat" )
            end
        end,
        auras = {
            hit_by_fresh_meat = {
                duration = 3600,
                max_stack = 1,
            },
        },
    },


    charge = {
        id = 100,
        cast = 0,
        charges  = function () return talent.double_time.enabled and 2 or 1 end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",

        spend = -20,
        spentType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.distance > 8 and ( query_time - action.charge.lastCast > gcd.execute ) end,
        handler = function ()
            setDistance( 5 )
            applyDebuff( "target", "charge" )
        end,
    },


    crushing_blow = {
        id = 335097,
        known = 85288,
        cast = 0,
        charges = function () return
              ( talent.raging_blow.enabled and 1 or 0 )
            + ( set_bonus.tier28_2pc > 0 and 1 or 0 )
            + ( talent.improved_raging_blow and 1 or 0 )
            + ( talent.raging_armaments and 1 or 0 )
        end,
        cooldown = 8,
        recharge = 8,
        hasteCD = true,
        gcd = "spell",

        spend = function ()
            if talent.swift_strikes.rank.enabled then
                return -12 - talent.swift_strikes.rank * 1
            else
                return -12
            end
        end,
        spendType = "rage",

        startsCombat = true,
        texture = 132215,

        notalent = "annihilator",

        bind = "raging_blow",
        buff = "recklessness",

        usable = function () return buff.crushing_impact.up or ( talent.reckless_abandon.enabled and  buff.recklessness.up ) end,
        handler = function ()
            removeStack( "whirlwind" )
            if talent.reckless_abandon.enabled then spendCharges( "raging_blow", 1 ) end

            if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
        end,
    },


    death_wish = {
        id = 199261,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 6777,
        spendType = "health",

        pvptalent = "death_wish",
        startsCombat = false,
        texture = 136146,

        handler = function ()
            addStack( "death_wish", nil, 1 )
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

        handler = function ()
            applyBuff( "defensive_stance" )
            removeBuff( "berserker_stance" )
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


    enraged_regeneration = {
        id = 184364,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "enraged_regeneration",
        startsCombat = false,
        texture = 132345,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "enraged_regeneration" )
        end,
    },


    execute = {
        id = 5308,
        cast = 0,
        cooldown = function () return ( talent.massacre.enabled and 4.5 or 6 ) end,
        gcd = "spell",
        noOverride = 317485, -- Condemn

        spend = function () return ( talent.improved_execute.enabled and -20 or min( max( rage.current, 20 ),40 ) ) end,
        spendType = "rage",

        startsCombat = false,
        texture = 135358,

        usable = function ()
            if buff.sudden_death.up then
                return true
            else
                return target.health_pct < (talent.massacre.enabled and 35 or 20), "requires target in execute range"
            end
        end,

        handler = function ()
            removeStack( "whirlwind" )
            if not talent.improved_execute.enabled and rage.current > 20 and buff.sudden_death.down then
                spend( min(max(rage.current, 20),40), "rage" ) -- Spend Rage
            end
            if talent.ashen_juggernaut.enabled then applyBuff("ashen_juggernaut") end
        end,
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
            applyDebuff ( "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
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
            removeStack( "whirlwind" )
            gain( health.max * 0.3, "health" )
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
        end,
    },


    intimidating_shout = {
        id = 316593,
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


    odyns_fury = {
        id = 385059,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "odyns_fury",
        startsCombat = false,
        texture = 1278409,

        handler = function ()
            applyDebuff( "target", "odyns_fury" )
            active_dot.odyns_fury = max( active_dot.odyns_fury, active_enemies )
            if talent.dancing_blades.enabled then applyBuff( "dancing_blades" ) end
            if talent.titanic_rage.enabled then
                applyBuff( "enrage" )
                applyBuff( "crushing_impact" )
            end
            if talent.titans_torment.enabled then applyBuff( "avatar", 4 ) end
        end,
    },


    onslaught = {
        id = 315720,
        cast = 0,
        cooldown = 18,
        gcd = "spell",

        spend = -20,
        spendType = "rage",

        talent = "onslaught",
        startsCombat = false,
        texture = 132364,

        handler = function ()
            removeStack( "whirlwind" )
            applyBuff( "enrage" , talent.tenderize.enabled and 6 or 5 )
            -- Tenderize increases enrage by 1 second only when using onslaught, weirdly.
        end,
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

        handler = function ()
            if talent.concussive_blows.enabled then
                applyDebuff( "target", "concussive_blows" )
            end
        end,
    },


    raging_blow = {
        id = 85288,
        cast = 0,
        charges = function () return
            ( talent.raging_blow.enabled and 1 or 0 )
          + ( set_bonus.tier28_2pc > 0 and 1 or 0 )
          + ( talent.improved_raging_blow and 1 or 0 )
          + ( talent.raging_armaments and 1 or 0 )
        end,
        cooldown = 8 * state.haste,
        recharge = 8 * state.haste,
        gcd = "spell",

        spend = function ()
            if talent.swift_strikes.rank > 0 then
                return -12 - talent.swift_strikes.rank * 1
            else
                return -12
            end
        end,
        spendType = "rage",

        talent = "raging_blow",
        notalent = "annihilator",
        startsCombat = false,
        texture = 589119,

        handler = function ()
            removeStack( "whirlwind" )
            if talent.slaughtering_strikes.enabled then addStack ( "slaughtering_strikes_raging_blow" ,nil , 1 ) end
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

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( (talent.inspiring_presence.enabled and 0.25 or 0.15) * health.max, "health" )
        end,
    },


    rampage = {
        id = 184367,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 80,
        spendType = "rage",

        talent = "rampage",
        startsCombat = false,
        texture = 132352,

        handler = function ()
            removeStack( "whirlwind" )
            if talent.frenzy.enabled then addStack( "frenzy", nil, 1 ) end
            applyBuff( "enrage" )
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
            -- Hurricane handled in reset_precast
        end,
    },


    recklessness = {
        id = 1719,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "recklessness",
        startsCombat = false,
        texture = 458972,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "recklessness" )
            if talent.berserkers_torment.enabled then applyBuff( "avatar", 4 ) end
        end,

        auras = {
            will_of_the_berserker = { -- Shadowlands Legendary
                id = 335597,
                duration = 12,
                max_stack = 1
            }
        }
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


    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function () return ( ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 ) end,
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
        cooldown = function () return talent.storm_of_swords.enabled and 12 or 0 end,
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

        spend = function () return (-25 * ( talent.piercing_verdict.enabled and 2 or 1 ) ) end,
        spendType = "rage",

        talent = "spear_of_bastion",
        startsCombat = false,
        texture = 3565453,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff ("target", "spear_of_bastion" )
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
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = 30,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
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
        cooldown = 6,
        gcd = "spell",

        talent = "titanic_throw",
        startsCombat = true,
        texture = 132453,

        handler = function ()
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
            removeStack( "whirlwind" )
            removeBuff( "victorious" )
            gain( 0.2 * health.max, "health" )
        end,
    },


    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = function () return talent.storm_of_swords.enabled and 7 or 0 end,
        gcd = "spell",

        spend = -3, -- TODO: Find a way to calculate the extra 1 rage per extra target hit?
        spendType = "rage",

        startsCombat = false,
        texture = 132369,

        handler = function ()
            applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = function () return (pvptalent.demolition.enabled and 45 * 0.5 or 45) end,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = false,
        texture = 460959,

        handler = function ()
        end,
    },
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt (when Talented)",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting.",
    type = "toggle",
    width = "full"
} )

spec:RegisterPriority( "Fury", 20220915,
-- Notes
[[

]],
-- Priority
[[

]] )