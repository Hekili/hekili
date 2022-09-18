-- WarriorFury.lua
-- September 2022

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
            return ( state.talent.war_machine.enabled and 1.2 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed / state.haste
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
            return ( state.talent.war_machine.enabled and 1.2 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.offhand_speed * offhand_mod / state.haste
        end,
    },

    battle_trance = {
        aura = "battle_trance",  -- PVP Talent

        last = function ()
            local app = state.buff.battle_trance.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 3 ) * 3
        end,

        interval = 3,

        value = 5,
    },

} )

-- Talents
spec:RegisterTalents( {
    anger_management                = { 77952, 152278, 1 },
    annihilator                     = { 77954, 383916, 1 },
    armored_to_the_teeth            = { 77938, 384124, 2 },
    ashen_juggernaut                = { 77896, 392536, 1 },
    avatar                          = { 77922, 107574, 1 },
    barbaric_training               = { 77931, 390674, 1 },
    berserker_rage                  = { 78009, 18499 , 1 },
    berserker_shout                 = { 77946, 384100, 1 },
    berserker_stance                = { 77990, 386196, 1 },
    bitter_immunity                 = { 77936, 383762, 1 },
    blood_and_thunder               = { 77948, 384277, 1 },
    bloodborne                      = { 77959, 385703, 1 },
    bloodcraze                      = { 77968, 385735, 1 },
    bloodthirst                     = { 77983, 23881 , 1 },
    bounding_stride                 = { 77940, 202163, 1 },
    cacophonous_roar                = { 77942, 382954, 1 },
    cold_steel_hot_blood            = { 77958, 383959, 1 },
    concussive_blows                = { 77900, 383115, 1 },
    crackling_thunder               = { 77948, 203201, 1 },
    critical_thinking               = { 77976, 383297, 2 },
    cruel_strikes                   = { 77894, 392777, 2 },
    cruelty                         = { 77890, 392931, 1 },
    crushing_force                  = { 78000, 382764, 2 },
    dancing_blades                  = { 77956, 391683, 1 },
    defensive_stance                = { 78008, 386208, 1 },
    deft_experience                 = { 77960, 383295, 2 },
    depths_of_insanity              = { 77950, 383922, 1 },
    double_time                     = { 77941, 103827, 1 },
    dual_wield_specialization       = { 77917, 382900, 1 },
    elysian_might                   = { 77923, 386285, 1 },
    endurance_training              = { 77937, 382940, 1 },
    enraged_regeneration            = { 77985, 184364, 1 },
    fast_footwork                   = { 78005, 382260, 1 },
    focus_in_chaos                  = { 77966, 383486, 1 },
    frenzied_flurry                 = { 77961, 383605, 1 },
    frenzy                          = { 77969, 335077, 1 },
    fresh_meat                      = { 77963, 215568, 1 },
    frothing_berserker              = { 78001, 215571, 1 },
    furious_blows                   = { 77993, 390354, 1 },
    hack_and_slash                  = { 77953, 383877, 1 },
    heroic_leap                     = { 77939, 6544  , 1 },
    honed_reflexes                  = { 77996, 391270, 1 },
    hurricane                       = { 77972, 390563, 1 },
    impending_victory               = { 78004, 202168, 1 },
    improved_bloodthirst            = { 77965, 383852, 1 },
    improved_enrage                 = { 77964, 383848, 1 },
    improved_execute                = { 77982, 316402, 1 },
    improved_raging_blow            = { 77981, 383854, 1 },
    improved_whirlwind              = { 77980, 12950 , 1 },
    inspiring_presence              = { 78002, 382310, 1 },
    intervene                       = { 77944, 3411  , 1 },
    intimidating_shout              = { 77943, 5246  , 1 },
    invigorating_fury               = { 77949, 383468, 1 },
    massacre                        = { 77897, 206315, 1 },
    meat_cleaver                    = { 77974, 280392, 1 },
    memory_of_a_tormented_berserker = { 77918, 390123, 1 },
    memory_of_a_tormented_titan     = { 77918, 390135, 1 },
    menace                          = { 77942, 275338, 1 },
    odyns_fury                      = { 77957, 385059, 1 },
    onslaught                       = { 77978, 315720, 1 },
    overwhelming_rage               = { 77994, 382767, 2 },
    pain_and_gain                   = { 77930, 382549, 1 },
    piercing_howl                   = { 77946, 12323 , 1 },
    piercing_verdict                = { 77924, 382948, 1 },
    placeholder_talent              = { 77956, 390376, 1 },
    pulverize                       = { 77977, 388933, 1 },
    quick_thinking                  = { 77928, 382946, 2 },
    raging_armaments                = { 77975, 388049, 1 },
    raging_blow                     = { 77984, 85288 , 1 },
    rallying_cry                    = { 78007, 97462 , 1 },
    rampage                         = { 77987, 184367, 1 },
    ravager                         = { 77973, 228920, 1 },
    reckless_abandon                = { 77952, 202751, 1 },
    recklessness                    = { 77970, 1719  , 1 },
    reinforced_plates               = { 77921, 382939, 1 },
    rumbling_earth                  = { 77914, 275339, 1 },
    second_wind                     = { 78002, 29838 , 1 },
    seismic_reverberation           = { 77932, 382956, 1 },
    shattering_throw                = { 77997, 64382 , 1 },
    shockwave                       = { 77916, 46968 , 1 },
    sidearm                         = { 77901, 384404, 1 },
    singleminded_fury               = { 77962, 81099 , 1 },
    siphoning_strikes               = { 77991, 382258, 1 },
    slaughtering_strikes            = { 77988, 388004, 1 },
    sonic_boom                      = { 77915, 390725, 1 },
    spear_of_bastion                = { 77934, 376079, 1 },
    spell_reflection                = { 77945, 23920 , 1 },
    storm_bolt                      = { 77933, 107570, 1 },
    storm_of_steel                  = { 77972, 382953, 1 },
    storm_of_swords                 = { 77955, 388903, 1 },
    sudden_death                    = { 77979, 280721, 1 },
    swift_strikes                   = { 77971, 383459, 2 },
    thunder_clap                    = { 77947, 6343  , 1 },
    thunderous_roar                 = { 77927, 384318, 1 },
    thunderous_words                = { 77926, 384969, 1 },
    titanic_throw                   = { 77931, 384090, 1 },
    unbridled_ferocity              = { 77951, 389603, 1 },
    uproar                          = { 77925, 391572, 1 },
    vicious_contempt                = { 77967, 383885, 2 },
    war_machine                     = { 77989, 346002, 1 },
    warpaint                        = { 77986, 208154, 1 },
    wrath_and_fury                  = { 77895, 392936, 1 },
    wrecking_throw                  = { 77997, 384110, 1 },
    wrenching_impact                = { 77940, 392383, 1 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    barbarian = 166, -- 280745
    battle_trance = 170, -- 213857
    bloodrage = 172, -- 329038
    death_sentence = 25, -- 198500
    death_wish = 179, -- 199261
    demolition = 5373, -- 329033
    disarm = 3533, -- 236077
    enduring_rage = 177, -- 198877
    master_and_commander = 3528, -- 235941
    rebound = 5548, -- 213915
    slaughterhouse = 3735, -- 352998
    warbringer = 5431, -- 356353
} )


-- Auras
spec:RegisterAuras( {
    annihilator = {
        id = 383915,
        duration = 12,
        max_stack = 5,
    },
    ashen_juggernaut = {
        id = 392537,
        duration = 12,
        max_stack = 5,
    },
    avatar = {
        id = 107574,
        duration = 20,
        max_stack = 1,
    },
	battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1,
        shared = "player", -- check for anyone's buff on the player.
    },
    berserker_rage = {
        id = 18499,
        duration = 6,
        type = "",
        max_stack = 1,
    },
    berserker_stance = {
 		id = 386196,
    },
    berserker_shout = {
        id = 384100,
        duration = 6,
        type = "",
        max_stack = 1,
    },
    bloodcraze = {
        id = 23881,
        duration = 20,
        max_stack = 3,
    },
    bloodrage = {
        id = 329038,
        duration = 4,
        max_stack = 1
    },
    bloodthirst = {
        id = 23881,
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1,
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1,
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1,
    },
	dancing_blades = {
	    id = 391683,
	    duration = 10,
	    max_stack = 1,
    },
    death_wish = {
        id = 199261,
        duration = 15,
        max_stack = 10,
    },
    defensive_stance = {
        id = 386208,
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1,
    }, 
    dual_wield = {
        id = 231842,
    },
    enrage = {
        id = 184362,
        duration = function () return 4 + ( talent.pulverize.enabled and 1 or 0 ) end,
        max_stack = 1,
    },
    enraged_regeneration = {
        id = 184364,
        duration = function () return 8 + ( 8 * (talent.invigorating_fury.enabled and 0.25 or 0 ) ) end,
        max_stack = 1,
    },
    frenzy = {
        id = 335082,
        duration = 12,
        max_stack = 4,
    },
    gushing_wound = {
        id = 385042,
        duration = 6,
        max_stack = 1,
    },
    hamstring= {
        id = 1715,
        duration = 15,
        max_stack = 1,
    },
    hurricane = {
        id = 390581,
        duration = 6,
        max_stack = 6,
    },
	intimidating_shout = {
        id = 5246,
        duration = 8,
        max_stack = 1,
    },
    mastery_unshackled_fury = {
        id = 76856,
    },
    odyns_fury = {
        id = 385060,
        duration = 4,
        max_stack = 1,
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1,
    },
    raging_blow = {
        id = 85288,
    },
    ravager = {
        id = 228920,
    },
    rallying_cry = {
        id = 97463,
        duration = function () return 10 * ( 10 * (talent.inspiring_presence.enabled and 0.25 or 0 ) ) end,
        max_stack = 1,
    },
    recklessness = {
        id = 1719,
	    duration = function () return 12 + ( talent.depths_of_insanity.enabled and 4 or 0 ) end,
        max_stack = 1,
    },
    shockwave = {
        id = 46968,
        duration = 2,
        max_stack = 1,
    },
    slaughterhouse = {
        id = 354788,
        duration = 6,
        max_stack = 5,
    },
    slaughtering_strikes = { 
        id = 85288, -- Labeled as Raging blow in WowHead, but Slaughtering Strikes talent triggers this
        duration = 12,
        max_stack = 5,
    },
    spell_reflection = {
        id = 23920,
        duration = 5,
        max_stack = 1,
    },
    storm_bolt = {
        id = 107570,
        duration = 4,
        max_stack = 1,
    },
    sudden_death = {
        id = 280776,
        duration = 10,
        max_stack = 1,
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1,
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1,
    },
    thunderous_roar = {
        id = 384318,
        duration = function () return 8 + ( talent.thunderous_words.enabled and 2 or 0 ) end,
        max_stack = 1,
    },
    titans_grip = {
        id = 46917,
    },
    victorious = {
        id = 32216,
        duration = 20,
        max_stack = 1,
    },
    whirlwind = {
        id = 85739,
        duration = 20,
        max_stack = function () return talent.meat_cleaver.enabled and 4 or 2 end,
    },
} )

local whirlwind_consumers = {
    bloodthirst       = 1, -- talent
    impending_victory = 1, -- talent
    onslaught         = 1, -- talent
    raging_blow       = 1, -- talent
    rampage           = 1, -- talent
    execute           = 1, -- baseline
    hamstring         = 1, -- baseline
    slam              = 1, -- baseline
    victory_rush      = 1, -- baseline
}

local whirlwind_gained = 0
local whirlwind_stacks = 0

local rageSpent = 0
-- local gloryRage = 0 -- Shadowlands Covenant ability

local fresh_meat_actual = {}
local fresh_meat_virtual = {}

spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName ) --#TODO: DF CHECK

    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]

            if not ability then return end

            -- Whirlwind Stack tracking
            if ability.key == "whirlwind" then
                whirlwind_gained = GetTime()
                whirlwind_stacks = state.talent.meat_cleaver.enabled and 4 or 2 -- #TODO: DF CHECK
            elseif whirlwind_consumers[ ability.key ] and whirlwind_stacks > 0 then
                whirlwind_stacks = whirlwind_stacks - 1
            end

        -- FRESH MEAT Talent tracking 
        elseif state.talent.fresh_meat.enabled and spellID == 23881 and subtype == "SPELL_DAMAGE" and not fresh_meat_actual[ destGUID ] and UnitGUID( "target" ) == destGUID then
            fresh_meat_actual[ destGUID ] = true
        end
    end
end )

spec:RegisterStateExpr( "rage_spent", function()
    return rageSpent
end )

local wipe = table.wipe

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" then
        if talent.recklessness.enabled then
            rage_spent = rage_spent + amt
            cooldown.recklessness.expires = cooldown.recklessness.expires - floor( rage_spent / 20 )
            rage_spent = rage_spent % 20
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

    -- BladeStorm doesn't exist for fury anymore in DF.
    --if buff.bladestorm.up and buff.gathering_storm.up then
    --    applyBuff( "gathering_storm", buff.bladestorm.remains + 6, 5 )
    --end

    if buff.whirlwind.up then
        if whirlwind_stacks == 0 then removeBuff( "whirlwind" )
        elseif whirlwind_stacks < buff.whirlwind.stack then
            applyBuff( "whirlwind", buff.whirlwind.remains, whirlwind_stacks )
        end
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
end )


-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "avatar",
        spend = -20,
        spendType = "rage",        
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
        end,
    },


    battle_shout = {
        id = 6673,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        startsCombat = false,
        texture = 132333,

        essential = true,
        nobuff = "battle_shout",

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

        handler = function ()
            applyBuff( "berzerker_stance" )
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
            gain( health.max * 0.20 , "health" )
        end,
    },
    bloodbath = {
        id = 335096,
        known = 23881,
        cast = 0,
        cooldown = 3,
        gcd = "spell",
        hasteCD = true,

        spend = function () return ( (talent.cold_steel_hot_blood.enabled and stat.crit >= 100) and -4 or 0 ) - 8 end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        startsCombat = true,
        texture = 236304,

        bind = "bloodthirst",
        talent = "reckless_abandon",
        buff = "recklessness",
               
        
        handler = function ()
            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ), "health" )

            --removeBuff( "bloody_rage" ) --#TODO: Verify if DF removed bloody_rage ?? 
            removeStack( "whirlwind" )

            if talent.cold_steel_hot_blood.enabled and stat.crit >= 100 then
                -- Gain 4 rage when talented in cold steel, hot blood and critical strike occurs
                applyDebuff( "target", "gushing_wound" )
                gain( 4, "rage" )
            end

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
            applyBuff( "bloodrage" )
        end,
    },


    bloodthirst = {
        id = 23881,
        cast = 0,
        cooldown = function() return (4.5 - (talent.deft_experience.rank * 0.75 ) ) end,
        hasteCD = true,
        gcd = "spell",

        spend = function () return ( (talent.cold_steel_hot_blood.enabled and stat.crit >= 100) and -4 or 0 ) - 8 end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        talent = "bloodthirst",
        startsCombat = true,
        texture = 136012,

        bind = "bloodthirst",
        
        handler = function ()
            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ), "health" )

            removeStack( "whirlwind" )

            if talent.cold_steel_hot_blood.enabled and stat.crit >= 100 then
                -- Gain 4 rage when talented in cold steel, hot blood and critical strike occurs
                applyDebuff( "target", "gushing_wound" )
                gain( 4, "rage" )
            end

            if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                applyBuff( "enrage" )
                applyDebuff( "target", "hit_by_fresh_meat" )
            end

        end,

        auras = {
            hit_by_fresh_meat = {
                duration = 3600,
                max_stack = 1,
            }
        },
    },
    charge = {
        id = 100,
        cast = 0,
        charges = function () return talent.double_time.enabled and 2 or nil end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "spell",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.distance > 10 and ( query_time - action.charge.lastCast > gcd.execute ) end,
        handler = function ()
            applyDebuff( "target", "charge" )
            setDistance( 5 )
        end,
    },
    crushing_blow = {
        id = 335097,
        cast = 0,
        charges = function () 
            return (
                (talent.raging_blow.enabled and 1 or 0)
                +
                (talent.improved_raging_blow.enabled and 1 or 0)
                +
                (talent.raging_armaments.enabled and 1 or 0)
            ) end,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        hasteCD = true,

        spend = -12,
        spendType = "rage",

        startsCombat = true,
        texture = 132215,

        bind = "raging_blow",
        talent = "reckless_abandon",
        buff = "recklessness",

        handler = function ()
            removeStack( "whirlwind" )
            if talent.reckless_abandon.enabled then spendCharges( "raging_blow", 1 ) end
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
            apllyBuff( "defensive_stance" )
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
            applyDebuff( "target", "disarm" )
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

        toggle = "defensives",

        handler = function ()
            applyBuff( "enraged_regeneration" )
        end,
    },


    execute = {
        id = 5308,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,
        
        spend = function() return talent.improved_execute.enabled and -20 or 0 end,
        spendType = "rage",
        
        startsCombat = true,
        texture = 135358,

        usable = function () return buff.sudden_death.up or target.health.pct < (talent.massacre.enabled and 35 or 20 ) end,
        handler = function ()
            if buff.sudden_death.up then removeBuff( "sudden_death" ) end
            removeStack( "whirlwind" )
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
            applyDebuff(  "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        charges = 1,
        cooldown = function () return 45 - ( talent.bounding_stride.enabled and 15 or 0 ) + ( talent.wrenching_impact.enabled and 45 or 0 ) end,
        recharge = function () return 45 - ( talent.bounding_stride.enabled and 15 or 0 ) + ( talent.wrenching_impact.enabled and 45 or 0 ) end,
        gcd = "spell",

        talent = "heroic_leap",
        startsCombat = true,
        texture = 236171,

        usable = function () return ( query_time - action.heroic_leap.lastCast > gcd.execute ) end,
        handler = function ()
            setDistance( 15 ) -- probably heroic_leap + charge combo.
            if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
        end,
    },


    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 6,
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
        startsCombat = true,
        texture = 589768,

        handler = function ()
            gain( health.max * 0.3, "health" )
            removeStack( "whirlwind" )
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
        id = 5246,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "intimidating_shout",
        startsCombat = true,
        texture = 132154,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "intimidating_shout" )
        end,
    },


    odyns_fury = {
        id = 385059,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "odyns_fury",
        startsCombat = true,
        texture = 1278409,

        handler = function ()
            applyDebuff( "target", "odyns_fury" )
            active_dot.odyns_fury = max( active_dot.odyns_fury, active_enemies )
            applyBuff( "dancing_blades" )
        end,
    },


    onslaught = {
        id = 315720,
        cast = 0,
        cooldown = 18,
        hasteCD = true,
        gcd = "spell",

        spend = -20,
        spendType = "rage",
        
        talent = "onslaught",
        startsCombat = true,
        texture = 132364,

        buff = "enrage",
        
        handler = function ()
            removeStack( "whirlwind" )
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
        end,
    },


    pummel = {
        id = 6552,
        cast = 0,
        cooldown = function() return 15 - ( talent.concussive_blows.enabled and 1 or 0 ) end,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        toggle = "interrupts",
        
        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.concussive_blows.enabled then applyDebuff( "concussive_blows" ) end
        end,
    },


    raging_blow = {
        id = 85288,
        cast = 0,
        charges = function () 
            return (
                (talent.raging_blow.enabled and 1 or 0)
                +
                (talent.improved_raging_blow.enabled and 1 or 0)
                +
                (talent.raging_armaments.enabled and 1 or 0)
            ) end,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        bind = "crushing_blow",

        notalent = "annihilator",
        talent = "raging_blow",
        startsCombat = true,
        texture = 589119,

        readyTime = function ()
            if talent.reckless_abandon.enabled then return buff.recklessness.remains end
            return 0
        end,
        
        handler = function ()
            removeStack( "whirlwind" )
            if talent.swift_strikes.enabled then gain( 1 * talent.swift_strikes.rank, "rage" ) end
            if talent.reckless_abandon.enabled then spendCharges( "crushing_blow", 1 ) end
            if talent.slaughtering_strikes.enabled then addStack( "slaughtering_strikes" , nil, 1) end
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

        toggle = "defensives",

        handler = function ()
            applyBuff( "rallying_cry" )
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
        startsCombat = true,
        texture = 132352,

        handler = function ()
            if talent.frenzy.enabled then addStack( "frenzy", nil, 1 ) end
            applyBuff( "enrage" )
            removeStack( "whirlwind" )
            removeBuff( "slaughtering_strikes" )
            -- if pvptalent.slaughterhouse.enabled then addStack ( "slaughterhouse", nil, 1)
        end,
    },


    ravager = {
        id = 228920,
        cast = 0,
        charges = function() return 1 + (talent.storm_of_steel and 1 or 0) end,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",

        talent = "ravager",
        startsCombat = true,
        texture = 970854,

        toggle = "cooldowns",

        handler = function ()
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
            if talent.reckless_abandon.enabled then
                gain( 50, "rage" )
            end
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = function() return (pvptalent.demolition.enabled and 60 or 180) end,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = true,
        texture = 311430,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shield_block = {
        id = 2565,
        cast = 0,
        charges = 1,
        cooldown = 15.115,
        recharge = 15.115,
        gcd = "spell",
        hasteCD = true,

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132110,

        handler = function ()
        end,
    },


    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        hasteCD = true,

        startsCombat = true,
        texture = 134951,

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
            active_dot.shockwave = max( active_dot.shockwave, active_enemies ) -- This isn't quite proper considering Shockwave is a cone, but close enough.
            if not target.is_boss then interrupt() end
        end,
    },


    slam = {
        id = 1464,
        cast = 0,
        cooldown = function() return ( talent.storm_of_swords.enabled and 12 or 0 ) end, 
        gcd = "spell",
        hasteCD = true,

        spend = function() return ( talent.storm_of_swords.enabled and -10 or 20 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
            removeStack( "whirlwind" )
        end,
    },


    spear_of_bastion = {
        id = 376079,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "spear_of_bastion",
        startsCombat = true,
        spend = function () return -25 + ( talent.piercing_verdict.enabled and -7.5 or 0 ) end,
        spendType = "rage",
        texture = 3565453,

        toggle = "cooldowns",
        velocity = 30,

        handler = function ()
            applyDebuff( "target", "spear_of_bastion" )
            if talent.elysian_might.enabled then applyBuff( "elysian_might" ) end
        end,

        auras = {
            spear_of_bastion = {
                id = 376079,
                duration = function () return talent.elysian_might.enabled and 8 or 4 end,
                max_stack = 1
            },
            elysian_might = {
                id = 386285,
                duration = 8,
                max_stack = 1,
            },
        }
    },
    spell_reflection = {
        id = 23920,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "spell",

        talent = "spell_reflection",
        startsCombat = false,
        texture = 132361,

        handler = function ()
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
            applyDebuff ("target", storm_bolt)
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
        cooldown = function() return 90 - (talent.uproar.enabled and 30 or 0) end,
        gcd = "spell",

        talent = "thunderous_roar",
        startsCombat = true,
        texture = 642418,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "thunderous_roar" )
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

        notalent = "impending_victory",
        buff = "victorious",
        handler = function ()
            removeBuff( "victorious" )
            removeStack( "whirlwind" )
        end,
    },


    whirlwind = {
        id = 190411,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        hasteCD = true,

        startsCombat = true,
        texture = 132369,

        usable = function ()
            if settings.check_ww_range and target.outside7 then return false, "target is outside of whirlwind range" end
            return true
        end,

        handler = function ()
            if level > 36 then
                if talent.improved_whirlwind.enabled then
                    gain( min(3 + active_enemies, 8), "rage" ) --Whirlwind generates 3 Rage, plus an additional 1 per target hit. Maximum 8 Rage
                    applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
                end
            end
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = true,
        texture = 311430,
    },
} )


spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt",
    desc = "If checked AND talented, |T236312:0|t Shockwave will only be recommended when your target is casting.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_ww_range", false, {
    name = "Check |T132369:0|t Whirlwind Range",
    desc = "If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "heroic_charge", false, {
    name = "Use Heroic Charge Combo",
    desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use Heroic Leap + Charge together.\n\n" ..
        "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
    type = "toggle",
    width = "full",
} )

spec:RegisterPriority( "Fury", 20220915,
-- Notes
[[

]],
-- Priority
[[

]] )