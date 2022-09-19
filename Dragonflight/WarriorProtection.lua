-- WarriorProtection.lua
-- September 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 73 )

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
            return ( state.talent.war_machine.enabled and 1.5 or 1 ) * 2
        end
    },
} )


-- Talents
spec:RegisterTalents( {
    anger_management                = { 78014, 152278, 1 }, -- 
    armored_to_the_teeth            = { 77938, 384124, 2 }, -- 
    avatar                          = { 77922, 107574, 1 }, -- 
    barbaric_training               = { 77929, 390675, 1 }, -- 
    battle_stance                   = { 77903, 386164, 1 }, -- 
    battlescarred_veteran           = { 78047, 386394, 1 }, -- 
    berserker_rage                  = { 78009, 18499 , 1 }, -- 
    berserker_shout                 = { 77946, 384100, 1 }, -- 
    best_served_cold                = { 78026, 202560, 1 }, -- 
    bitter_immunity                 = { 77936, 383762, 1 }, -- 
    blood_and_thunder               = { 77948, 384277, 1 }, -- 
    bloodborne                      = { 78032, 385704, 2 }, -- 
    bloodsurge                      = { 78042, 384361, 1 }, -- 
    bolster                         = { 78031, 280001, 1 }, -- 
    booming_voice                   = { 78024, 202743, 1 }, -- 
    bounding_stride                 = { 77940, 202163, 1 }, -- 
    brace_for_impact                = { 78036, 386030, 1 }, -- 
    brutal_vitality                 = { 78035, 384036, 1 }, -- 
    cacophonous_roar                = { 77942, 382954, 1 }, -- 
    challenging_shout               = { 78023, 1161  , 1 }, -- 
    champions_bulwark               = { 78015, 386328, 1 }, -- 
    concussive_blows                = { 77900, 383115, 1 }, -- 
    crackling_thunder               = { 77948, 203201, 1 }, -- 
    cruel_strikes                   = { 77894, 392777, 2 }, -- 
    crushing_force                  = { 77995, 390642, 2 }, -- 
    defensive_stance                = { 78008, 386208, 1 }, -- 
    demoralizing_shout              = { 78025, 1160  , 1 }, -- 
    devastator                      = { 78011, 236279, 1 }, -- 
    disrupting_shout                = { 78020, 386071, 1 }, -- 
    double_time                     = { 77941, 103827, 1 }, -- 
    elysian_might                   = { 77923, 386285, 1 }, -- 
    endurance_training              = { 77937, 382940, 1 }, -- 
    enduring_alacrity               = { 78018, 384063, 2 }, -- 
    enduring_defenses               = { 78044, 386027, 1 }, -- 
    fast_footwork                   = { 78005, 382260, 1 }, -- 
    focused_vigor                   = { 78030, 384067, 2 }, -- 
    frothing_berserker              = { 77999, 392790, 1 }, -- 
    fueled_by_violence              = { 78035, 383103, 1 }, -- 
    furious_blows                   = { 77993, 390354, 1 }, -- 
    heavy_repercussions             = { 78021, 203177, 1 }, -- 
    heroic_leap                     = { 77939, 6544  , 1 }, -- 
    honed_reflexes                  = { 77893, 391271, 1 }, -- 
    ignore_pain                     = { 78039, 190456, 1 }, -- 
    impending_victory               = { 78004, 202168, 1 }, -- 
    improved_heroic_throw           = { 78019, 386034, 1 }, -- 
    indomitable                     = { 78012, 202095, 1 }, -- 
    inspiring_presence              = { 78002, 382310, 1 }, -- 
    intervene                       = { 77944, 3411  , 1 }, -- 
    intimidating_shout              = { 77943, 5246  , 1 }, -- 
    into_the_fray                   = { 78021, 202603, 1 }, -- 
    juggernaut                      = { 78033, 383292, 1 }, -- 
    last_stand                      = { 78037, 12975 , 1 }, -- 
    massacre                        = { 78044, 281001, 1 }, -- 
    menace                          = { 77942, 275338, 1 }, -- 
    onehanded_weapon_specialization = { 77935, 382895, 1 }, -- 
    outburst                        = { 78017, 386477, 1 }, -- 
    overwhelming_rage               = { 77994, 382767, 2 }, -- 
    pain_and_gain                   = { 77930, 382549, 1 }, -- 
    piercing_howl                   = { 77946, 12323 , 1 }, -- 
    piercing_verdict                = { 77924, 382948, 1 }, -- 
    punish                          = { 78033, 275334, 1 }, -- 
    quick_thinking                  = { 77928, 382946, 2 }, -- 
    rallying_cry                    = { 78007, 97462 , 1 }, -- 
    ravager                         = { 78028, 228920, 1 }, -- 
    reinforced_plates               = { 77921, 382939, 1 }, -- 
    rend                            = { 78013, 772   , 1 }, -- 
    revenge                         = { 78040, 6572  , 1 }, -- 
    rumbling_earth                  = { 77914, 275339, 1 }, -- 
    second_wind                     = { 78002, 29838 , 1 }, -- 
    seismic_reverberation           = { 77932, 382956, 1 }, -- 
    shattering_throw                = { 77997, 64382 , 1 }, -- 
    shield_charge                   = { 78016, 385952, 1 }, -- 
    shield_specialization           = { 78045, 386011, 2 }, -- 
    shield_wall                     = { 78043, 871   , 1 }, -- 
    shockwave                       = { 77916, 46968 , 1 }, -- 
    show_of_force                   = { 78019, 385843, 1 }, -- 
    sidearm                         = { 77901, 384404, 1 }, -- 
    signet_of_tormented_kings       = { 77919, 382949, 1 }, -- 
    siphoning_strikes               = { 77991, 382258, 1 }, -- 
    sonic_boom                      = { 77915, 390725, 1 }, -- 
    spear_of_bastion                = { 77934, 376079, 1 }, -- 
    spell_block                     = { 78046, 392966, 1 }, -- 
    spell_reflection                = { 77945, 23920 , 1 }, -- 
    spiked_shield                   = { 78034, 385888, 1 }, -- 
    storm_bolt                      = { 77933, 107570, 1 }, -- 
    storm_of_steel                  = { 78027, 382953, 1 }, -- 
    strategist                      = { 78041, 384041, 1 }, -- 
    sudden_death                    = { 77898, 29725 , 1 }, -- 
    the_wall                        = { 78029, 384072, 1 }, -- 
    thunder_clap                    = { 77947, 6343  , 1 }, -- 
    thunderlord                     = { 78022, 385840, 1 }, -- 
    thunderous_roar                 = { 77927, 384318, 1 }, -- 
    thunderous_words                = { 77926, 384969, 1 }, -- 
    titanic_throw                   = { 77929, 384090, 1 }, -- 
    unbreakable_will                = { 78029, 384074, 1 }, -- 
    unnerving_focus                 = { 78038, 384042, 1 }, -- 
    unstoppable_force               = { 77919, 275336, 1 }, -- 
    uproar                          = { 77925, 391572, 1 }, -- 
    war_machine                     = { 78010, 316733, 1 }, -- 
    wrecking_throw                  = { 77997, 384110, 1 }, -- 
    wrenching_impact                = { 77940, 392383, 1 }, -- 
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    bodyguard       = 168 , -- 213871
    demolition      = 5374, -- 329033
    disarm          = 24  , -- 236077
    dragon_charge   = 831 , -- 206572
    morale_killer   = 171 , -- 199023
    oppressor       = 845 , -- 205800
    rebound         = 833 , -- 213915
    shield_bash     = 173 , -- 198912
    sword_and_board = 167 , -- 199127
    thunderstruck   = 175 , -- 199045
    warbringer      = 5432, -- 356353
    warpath         = 178 , -- 199086
} )


-- Auras
spec:RegisterAuras( {
  ashen_juggernaut = {
        id = 335234,
        duration = 8,
        max_stack = 15,
    },
    avatar = {
        id = 107574,
        duration = 20,
        max_stack = 1,
    },
    barbaric_training = {
        id = 390675,
    },
    battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1,
    --    shared = "player", -- check for anyone's buff on the player.
    },
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1,
    },
    battlescarred_veteran = {
        id = 386394,
        duration = 8,
        max_stack = 1,
    },
    berserker_rage = {
        id = 18499,
        duration = 6,
        type = "",
        max_stack = 1,
    },
    berserker_shout = {
        id = 384100,
        duration = 6,
        type = "",
        max_stack = 1,
    },
    bladestorm = {
        id = 227847,
        duration = 3.73,
        max_stack = 1,
    },
    bloodborne = {
        id = 385704,
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1,
    },
    brace_for_impact = {
        id = 386030,
        duration = 9,
        max_stack = 5,
    },
    call_to_arms = {
        id = 161332,
    },
    challenging_shout = {
        id = 1161,
        duration = 6,
        max_stack = 1,
    },
    champions_bulwark = {
        id = 386328,
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
    conquerors_banner = {
        id = 324143,
        duration = 19.5,
        max_stack = 1,
    },  
	crushing_force = {
        id = 390642,
    },
    dark_ritual = {
        id = 322411,
        duration = 6,
        max_stack = 1,
    },
    decanted_warsong = {
        id = 356687,
        duration = 15,
        max_stack = 1,
    },
    deep_wounds = {
        id = 115768,
        duration = 15,
        max_stack = 1,
    },
    defensive_stance = {
        id = 386208,
        max_stack = 1,
    },
    demoralizing_shout = {
        id = 1160,
        duration = 8,
        max_stack = 1,
    },
    devastator = {
        id = 236279,
    },
    disrupting_shout = {
        id = 386071,
        duration = 6,
        max_stack = 1,
    },
    dragon_charge = {
        id = 206572,
    },
    elysian_might = {
        id = 386285,
        duration = 3600,
        max_stack = 1,
    },
    enduring_defenses = {
        id = 386027,
    },
    furious_blows = {
        id = 390354,
    },
    hamstring= {
        id = 1715,
        duration = 15,
        max_stack = 1,
    },
    honed_reflexes = {
        id = 391271,
    },
    ignore_pain = {
        id = 190456,
        duration = 12,
        max_stack = 1
    },
    intimidating_shout = {
        id = 5246,
        duration = 8,
        max_stack = 1,
    },
    into_the_fray = {
        id = 202602,
        duration = 3600,
        max_stack = 5,
    },
    juggernaut = {
        id = 383292,
        duration = 12,
        max_stack = 5,
    },
    improved_heroic_throw = {
        id = 386034,
    },
    last_stand = {
        id = 12975,
        duration = 15,
        max_stack = 1,
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1,
    },
    outburst = {
        id = 386477,
        duration = 30,
        max_stack = 1,
    },
    punish = {
        id = 275335,
        duration = 9,
        max_stack = 10,
    },
    quick_thinking = {
        id = 392778,
        duration = 10,
        max_stack = 1,
    },
    rallying_cry = {
        id = 97463,
        duration = function () return 10 * ( 10 * (talent.inspiring_presence.enabled and 0.25 or 0 ) ) end,
        max_stack = 1,
    },
    ravager = {
        id = 228920,
        duration = 12,
        max_stack = 1,
    },
    recklessness = {
        id = 1719,
        duration = 4,
        max_stack = 1,
    },
    rend = {
        id = 388539,
        duration = 15,
        max_stack = 1,
        tick_time = 3,
    },
    revenge = {
        id = 5302,
        duration = 6,
        max_stack = 1,
    },
    riposte = {
        id = 161798,
    },
    second_wind = {
        id = 351077,
        duration = 3600,
        max_stack = 1,
    },
    seeing_red = {
        id = 364006,
        duration = 30,
        max_stack = 7,
    },
    seismic_reverberation = {
        id = 382956,
    },
    shield_block = {
        id = 132404,
        duration = 6,
        max_stack = 1,
    },
    shield_specialization = {
        id = 386011,
    },
    shield_wall = {
        id = 871,
        duration = 8,
        max_stack = 1,
    },
    show_of_force = {
        id = 385842,
        duration = 12,
        max_stack = 1,
    },
    sidearm = {
        id = 384404,
    },
    shockwave = {
        id = 46968,
        duration = 2,
        max_stack = 1,
    },
    signet_of_tormented_kings = {
        id = 382949,
    },
    sonic_boom = {
        id = 390725,
    },
    spear_of_bastion = {
        id = 376080,
        duration = 8,
        max_stack = 1,
    },
    spell_block = {
        id = 392966,
        duration = 14,
        max_stack = 1,
    },
    spell_reflection = {
        id = 23920,
        duration = 5,
        max_stack = 1,
    },
    spiked_shield = {
        id = 385888,
    },
    storm_bolt = {
        id = 132169,
        duration = 4,
        max_stack = 1,
    },
    storm_of_steel = {
        id = 382953,
    },
    sudden_death = {
        id = 52437,
        duration = 10,
        max_stack = 1,
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1,
    },
    the_wall = {
        id = 384072,
    },
    third_wind = {
        id = 356689,
        duration = 6,
        max_stack = 1,
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1,
    },
    thunderlord = {
        id = 385840,
    },
    thunderous_roar = {
        id = 384318,
        duration = function () return 8 + ( talent.thunderous_words.enabled and 2 or 0 ) end,
        max_stack = 1,
    },
    unbreakable_will = {
        id = 384074,
    },
    undying_rage = {
        id = 356492,
        duration = 23.048,
        max_stack = 5,
    },
    unnerving_focus = {
        id = 337155,
        duration = 15,
        max_stack = 1,
    },
    uproar = {
        id = 391572,
    },
    vanguard = {
        id = 71,
    },
    victorious = {
        id = 32216,
        duration = 20,
        max_stack = 1,
    },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1,
    },
} )

local rageSpent = 0

spec:RegisterStateExpr( "rage_spent", function ()
    return rageSpent
end )


local outburstRage = 0

spec:RegisterStateExpr( "outburst_rage", function ()
    return outburstRage
end )

local RAGE = Enum.PowerType.Rage
    local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )

        if current < lastRage then
            if state.talent.anger_management.enabled then
                rageSpent = ( rageSpent + lastRage - current ) % 10 -- Anger Management
            end

            if state.talent.outburst.enabled then
                outburstRage = ( outburstRage + lastRage - current ) % 30 -- Outburst.
            end
        end

        lastRage = current
    end
end )

-- model rage expenditure reducing CDs...
spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" and amt > 0 then
        if talent.anger_management.enabled then
            rage_spent = rage_spent + amt
            local secs = floor( rage_spent / 10 )
            rage_spent = rage_spent % 10

            cooldown.avatar.expires = cooldown.avatar.expires - secs
            reduceCooldown( "shield_wall", secs )
            -- cooldown.last_stand.expires = cooldown.last_stand.expires - secs
            -- cooldown.demoralizing_shout.expires = cooldown.demoralizing_shout.expires - secs
        end


        if talent.outburst.enabled then
            outburst_rage = outburst_rage + amt
            local stacks = floor( outburst_rage / 30 )
            outburst_rage = outburst_rage % 30

            if stacks > 0 then
                addStack( "seeing_red", nil, stacks )
            end
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

        spend = -20,
        spendType = "rage",

        toggle = "cooldowns",
        
        startsCombat = false,
        texture = 613534,

        talent = "avatar",
        
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


    battle_stance = {
        id = 386164,
        cast = 0,
        cooldown = 3,
        gcd = "off",
        
        talent = "battle_stance",
        startsCombat = true,
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
        gcd = "spell",
        
        talent = "berserker_shout",
        startsCombat = true,
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
        gcd = "spell",
        
        talent = "bitter_immunity",
        startsCombat = true,
        texture = 136088,
        
        toggle = "cooldowns",

        handler = function ()
            gain( health.max * 0.20 , "health" )
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
        charges = function () return talent.double_time.enabled and 2 or nil end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",
        
        startsCombat = true,
        texture = 132337,
        
        handler = function ()
            applyDebuff( "target", "charge" )
            setDistance( 5 )
        end,
    },
    

    defensive_stance = {
        id = 386208,
        cast = 0,
        cooldown = 3,
        gcd = "off",
        
        talent = "defensive_stance",
        startsCombat = true,
        texture = 132341,
        
        handler = function ()            
            applyBuff( "defensive_stance" )
            removeBuff( "battle_stance" )
        end,
    },
    

    demoralizing_shout = {
        id = 1160,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        
        talent = "demoralizing_shout",
        startsCombat = true,
        texture = 132366,
        
        handler = function ()
        end,
    },


    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        startsCombat = true,
        texture = 135291,
        
        handler = function ()
            applyDebuff ( "target", "deep_wounds" )
        end,
    },
    

    disrupting_shout = {
        id = 386071,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        talent = "disrupting_shout",
        startsCombat = true,
        texture = 132091,
        
        toggle = "interrupts",
        debuff = function () return settings.disrupting_shout_interrupt and "casting" or nil end,
        readyTime = function () return settings.disrupting_shout_interrupt and timeToInterrupt() or nil end,

        handler = function ()
            applyDebuff( "target", "disrupting_shout" )
            active_dot.disrupting_shout = active_enemies
            if not target.is_boss then interrupt() end
        end,
    },
    

    execute = {
        id = 163201,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,
        
        spend = 40,
        spendType = "rage",
        
        startsCombat = true,
        texture = 135358,
        
        usable = function () return target.health.pct < (talent.massacre.enabled and 35 or 20 ) end,
        handler = function ()
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
            applyDebuff( "hamstring" )
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
        cooldown = 0,
        gcd = "spell",
        
        startsCombat = true,
        texture = 132453,
        
        handler = function ()
            if talent.improved_heroic_throw.enabled then applyDebuff ( "target", "deep_wounds" ) end
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
        startsCombat = true,
        texture = 589768,
        
        handler = function ()
            gain( health.max * 0.3, "health" )
        end,
    },
    

    intervene = {
        id = 3411,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
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
    

    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = function () return talent.bolster.enabled and 170 or 180 end,
        gcd = "off",
        
        talent = "last_stand",
        startsCombat = true,
        texture = 135871,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "last_stand" )
            if talent.bolster.enabled then
                applyBuff( "shield_block", buff.last_stand.duration )
            end
            if talent.unnerving_focus.enabled then applyBuff( "unnerving_focus" ) end
        end,
    },
    

    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
        talent = "piercing_howl",
        startsCombat = true,
        texture = 136147,
        
        handler = function ()
            applyDebuff( "target", "piercing_howl" )
        end,
    },
    

    pummel = {
        id = 6552,
        cast = 0,
        cooldown = function () return 15 - talent.concussive_blows.enabled and 1 or 0 end,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },
    

    rallying_cry = {
        id = 97462,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        talent = "rallying_cry",
        startsCombat = true,
        texture = 132351,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( (talent.inspiring_presence.enabled and 0.25 or 0.2) * health.max, "health" )
            health.max = health.max * (talent.inspiring_presence.enabled and 1.25 or 1.2)
        end,
    },
    

    ravager = {
        id = 228920,
        cast = 0,
        charges = function() return 1 + (talent.storm_of_steel.enabled and 1 or 0 ) end,
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
        id = 772,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 30,
        spendType = "rage",
        
        talent = "rend",
        startsCombat = true,
        texture = 132155,
        
        handler = function ()
            applyDebuff( "target", "rend" )
        end,
    },
    

    revenge = {
        id = 6572,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = function ()
            if buff.revenge.up then return 0 end
            return 20
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
            if buff.revenge.up then removeBuff( "revenge" ) end
            if talent.show_of_force.enabled then applyBuff( "show_of_force" ) end
            applyDebuff ( "target", "deep_wounds" )
            active_dot.deep_wounds = max( active_dot.deep_wounds, active_enemies )
        end,
    },
    

    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",
        
        talent = "shattering_throw",
        startsCombat = true,
        texture = 311430,
        
        toggle = "cooldowns",

        range = 30,

        handler = function ()
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
            if talent.enduring_defensives.enabled  then
                buff.shield_block.expires = buff.shield_block.expires + 2
            end
        end,
    },
    

    shield_charge = {
        id = 385952,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        
        talent = "shield_charge",
        startsCombat = true,
        texture = 4667427,
        
        handler = function ()
            gain(20, "rage")
            if talent.champions_bulwark.enabled then 
                applyBuff( "shield_block" )
                applyBuff( "revenge" )
                gain(30, "rage")
            end
        end,
    },
    

    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = 9,
        hasteCD = true,
        gcd = "spell",

        spend = function () 
            if buff.last_stand.up then
                return ( ( ( talent.heavy_repercussions.enabled and -18 or -15 ) - ( talent.the_wall.enabled and 5 or 0 ) ) * 1.6 ) 
            else
                return ( ( talent.heavy_repercussions.enabled and -18 or -15 ) - ( talent.the_wall.enabled and 5 or 0 ) ) 
            end
        end,
        spendType = "rage",
        
        startsCombat = true,
        texture = 134951,
        
        handler = function ()
            if talent.heavy_repercussions.enabled  then
                buff.shield_block.expires = buff.shield_block.expires + 1
            end

            if talent.the_wall.enabled and cooldown.shield_wall.remains > 0 then
                reduceCooldown( "shield_wall", 5 )
            end

            if talent.punish.enabled then applyDebuff( "target", "punish" ) end

            if buff.outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "outburst" )
            end
        end,
    },
    

    shield_wall = {
        id = 871,
        cast = 0,
        charges = function () if talent.unbreakable_will.enabled then return 2 end end,
        cooldown = 166,
        recharge = 166,
        gcd = "off",

        toggle = "defensives",
        defensive = true,
        
        talent = "shield_wall",
        startsCombat = false,
        texture = 132362,

        handler = function ()
            applyBuff( "shield_wall" )
        end,
    },
    

    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function () return ( ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 )  end,
        gcd = "spell",

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
        cooldown = 90,
        gcd = "spell",

        spend = function () return -25 + ( talent.piercing_verdict.enabled and -7.5 or 0 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 3565453,

        toggle = "essences",

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
    

    spell_block = {
        id = 392966,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        talent = "spell_block",
        startsCombat = false,
        texture = 132358,
        toggle = "defensives",
        defensive = true,
        
        handler = function ()
            applyBuff( "spell_block" )
        end,
    },
    

    spell_reflection = {
        id = 23920,
        cast = 0,
        cooldown = 20,
        gcd = "off",
        
        talent = "spell_reflection",
        startsCombat = false,
        texture = 132361,
        
        handler = function ()
            applyBuff( "spell_reflection" )
        end,
    },
    

    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 613535,

        talent = "storm_bolt",

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
        end,
    },
    

    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        
        spend = -5,
        spendType = "rage",
        
        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,
        
        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
            if talent.blood_and_thunder.enabled and debuff.rend.up then
                active_dot.rend = min( 5, active_enemies ) -- max 5 enemy spread
            end
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
        id = 1680,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 30,
        spendType = "rage",
        
        startsCombat = true,
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
        startsCombat = true,
        texture = 311430,
        
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
    desc = "If checked AND talented, |T236312:0|t Shockwave will only be recommended when your target is casting.",
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
    name = "Stack |T132110:0|t Shield Block with Reprisal",
    desc = function()
        return "If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage when using the Reprisal legendary.\n\n" ..
        "This setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time.\n\n" ..
        ( state.legendary.reprisal.enabled and "|cFF00FF00" or "|cFFFF0000" ) ..
        "Requires |T236317:0|t Reprisal (legendary)|r"
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterPriority( "Protection", 20220916,
-- Notes
[[

]],
-- Priority
[[

]] )