-- WarriorArms.lua
-- September 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindPlayerAuraByID = ns.FindPlayerAuraByID

local spec = Hekili:NewSpecialization( 71 )

local base_rage_gen, arms_rage_mult = 1.75, 4.000

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time
            if state.mainhand_speed == 0 then
                return 0
            else
                return swing + floor( ( t - swing ) / state.mainhand_speed ) * state.mainhand_speed
            end
        end,

        interval = "mainhand_speed",

        stop = function () return state.swings.mainhand == 0 end,
        value = function ()
            return ( state.talent.war_machine.enabled and 1.5 or 1 ) * base_rage_gen * arms_rage_mult * state.mainhand_speed / state.haste
        end,
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
} )

-- Talents
spec:RegisterTalents( {
    anger_management                = { 88853, 152278, 1 }, -- 
    armored_to_the_teeth            = { 88930, 384124, 2 }, -- 
    avatar                          = { 88929, 107574, 1 }, -- 
    barbaric_training               = { 88897, 383082, 1 }, -- 
    battle_stance                   = { 88891, 386164, 1 }, -- 
    battlelord                      = { 89000, 386630, 1 }, -- 
    berserker_rage                  = { 88936, 18499 , 1 }, -- 
    berserker_shout                 = { 88912, 384100, 1 }, -- 
    bitter_immunity                 = { 88920, 383762, 1 }, -- 
    blademasters_torment            = { 88927, 390138, 1 }, -- 
    bladestorm                      = { 89005, 227847, 1 }, -- 
    blood_and_thunder               = { 88906, 384277, 1 }, -- 
    bloodborne                      = { 88847, 383287, 2 }, -- 
    bloodletting                    = { 89002, 383154, 1 }, -- 
    bloodsurge                      = { 88841, 384361, 1 }, -- 
    blunt_instruments               = { 88851, 383442, 1 }, -- 
    bounding_stride                 = { 88919, 202163, 1 }, -- 
    cacophonous_roar                = { 88947, 382954, 1 }, -- 
    cleave                          = { 88857, 845   , 1 }, -- 
    collateral_damage               = { 88831, 334779, 1 }, -- 
    colossus_smash                  = { 88854, 167105, 1 }, -- 
    concussive_blows                = { 88897, 383115, 1 }, -- 
    crackling_thunder               = { 88906, 203201, 1 }, -- 
    critical_thinking               = { 89008, 389306, 2 }, -- 
    cruel_strikes                   = { 88945, 392777, 2 }, -- 
    crushing_force                  = { 88911, 382764, 2 }, -- 
    dance_of_death                  = { 88827, 390713, 1 }, -- 
    defensive_stance                = { 88894, 386208, 1 }, -- 
    deft_experience                 = { 89001, 389308, 2 }, -- 
    die_by_the_sword                = { 88840, 118038, 1 }, -- 
    double_time                     = { 88946, 103827, 1 }, -- 
    dreadnaught                     = { 88849, 262150, 1 }, -- 
    elysian_might                   = { 88887, 386285, 1 }, -- 
    endurance_training              = { 88902, 382940, 1 }, -- 
    executioners_precision          = { 89009, 386634, 1 }, -- 
    exhilarating_blows              = { 88850, 383219, 1 }, -- 
    fast_footwork                   = { 88935, 382260, 1 }, -- 
    fatality                        = { 89003, 383703, 1 }, -- 
    fervor_of_battle                = { 88836, 202316, 1 }, -- 
    frothing_berserker              = { 88916, 392792, 1 }, -- 
    fueled_by_violence              = { 88839, 383103, 1 }, -- 
    furious_blows                   = { 88900, 390354, 1 }, -- 
    heroic_leap                     = { 88910, 6544  , 1 }, -- 
    honed_reflexes                  = { 88918, 382461, 1 }, -- 
    hurricane                       = { 89004, 390563, 1 }, -- 
    impale                          = { 88856, 383430, 1 }, -- 
    impending_victory               = { 88890, 202168, 1 }, -- 
    improved_execute                = { 88837, 316405, 1 }, -- 
    improved_mortal_strike          = { 89007, 385573, 1 }, -- 
    improved_overpower              = { 88843, 385571, 1 }, -- 
    in_for_the_kill                 = { 88852, 248621, 1 }, -- 
    inspiring_presence              = { 88896, 382310, 1 }, -- 
    intervene                       = { 88893, 3411  , 1 }, -- 
    intimidating_shout              = { 88948, 5246  , 1 }, -- 
    juggernaut                      = { 89010, 383292, 1 }, -- 
    leeching_strikes                = { 88908, 382258, 1 }, -- 
    martial_prowess                 = { 88842, 316440, 1 }, -- 
    massacre                        = { 88855, 281001, 1 }, -- 
    menace                          = { 88947, 275338, 1 }, -- 
    merciless_bonegrinder           = { 88830, 383317, 1 }, -- 
    mortal_strike                   = { 88834, 12294 , 1 }, -- 
    overpower                       = { 88835, 7384  , 1 }, -- 
    overwhelming_rage               = { 88942, 382767, 2 }, -- 
    pain_and_gain                   = { 88917, 382549, 1 }, -- 
    piercing_howl                   = { 88912, 12323 , 1 }, -- 
    piercing_verdict                = { 88943, 382948, 1 }, -- 
    rallying_cry                    = { 88895, 97462 , 1 }, -- 
    reaping_swings                  = { 88858, 383293, 1 }, -- 
    reinforced_plates               = { 88932, 382939, 1 }, -- 
    rend                            = { 88848, 772   , 1 }, -- 
    rumbling_earth                  = { 88938, 275339, 1 }, -- 
    second_wind                     = { 88896, 29838 , 1 }, -- 
    seismic_reverberation           = { 88904, 382956, 1 }, -- 
    sharpened_blades                = { 89011, 383341, 1 }, -- 
    shattering_throw                = { 88915, 64382 , 1 }, -- 
    shockwave                       = { 88939, 46968 , 1 }, -- 
    sidearm                         = { 88941, 384404, 1 }, -- 
    skullsplitter                   = { 88845, 260643, 1 }, -- 
    sonic_boom                      = { 88885, 390725, 1 }, -- 
    spear_of_bastion                = { 88944, 376079, 1 }, -- 
    spell_reflection                = { 88949, 23920 , 1 }, -- 
    storm_bolt                      = { 88901, 107570, 1 }, -- 
    storm_of_swords                 = { 88831, 385512, 1 }, -- 
    storm_wall                      = { 88833, 388807, 1 }, -- 
    sudden_death                    = { 88838, 29725 , 1 }, -- 
    sweeping_strikes                = { 88832, 260708, 1 }, -- 
    tactician                       = { 88846, 184783, 1 }, -- 
    test_of_might                   = { 88852, 385008, 1 }, -- 
    thunder_clap                    = { 88907, 6343  , 1 }, -- 
    thunderous_roar                 = { 88923, 384318, 1 }, -- 
    thunderous_words                = { 88922, 384969, 1 }, -- 
    tide_of_blood                   = { 88844, 386357, 1 }, -- 
    titanic_throw                   = { 88905, 384090, 1 }, -- 
    twohanded_weapon_specialization = { 88886, 382896, 1 }, -- 
    unhinged                        = { 89004, 386628, 1 }, -- 
    uproar                          = { 88921, 391572, 1 }, -- 
    valor_in_victory                = { 89006, 383338, 2 }, -- 
    war_machine                     = { 88892, 262231, 1 }, -- 
    warbreaker                      = { 88851, 262161, 1 }, -- 
    warlords_torment                = { 88927, 390140, 1 }, -- 
    wild_strikes                    = { 88924, 382946, 2 }, -- 
    wrecking_throw                  = { 88915, 384110, 1 }, -- 
    wrenching_impact                = { 88919, 392383, 1 }, -- 
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    death_sentence         = 3522, -- 198500
    demolition             = 5372, -- 329033
    disarm                 = 3534, -- 236077
    duel                   = 34  , -- 236273
    master_and_commander   = 28  , -- 235941
    rebound                = 5547, -- 213915
    shadow_of_the_colossus = 29  , -- 198807
    sharpen_blade          = 33  , -- 198817
    storm_of_destruction   = 31  , -- 236308
    war_banner             = 32  , -- 236320
    warbringer             = 5376, -- 356353
} )


-- Auras
spec:RegisterAuras( {
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
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1
    },
    battlelord =  {
        id = 386631,
        duration = 10,
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
    bladestorm = {
        id = 227847,
        duration = function () return 6 * haste end,
        max_stack = 1,
        onCancel = function()
            setCooldown( "global_cooldown", 0 )
        end,
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1
    },
    colossus_smash = {
        id = 208086,
        duration = function () return 10 + (talent.blunt_instruments.enabled and 3 or 0 ) end,
        max_stack = 1,
    },
    crushing_force = {
        id = 382764
    },
    dance_of_death = { --TODO: Implement something similar to Druid's AdaptiveSwarm
        id = 390714,
        duration = 180,
        max_stack = 1,
    },
    deep_wounds = {
        id = 262115,
        duration = function() return 12 + (talent.bloodletting.enabled and 6 or 0) end,
        tick_time = 3,
        max_stack = 1
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    die_by_the_sword = {
        id = 118038,
        duration = 8,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    duel = {
        id = 236273,
        duration = 8,
        max_stack = 1
    },
    elysian_might = {
        id = 386286,
        duration = 8,
        max_stack = 1
    },
    executioners_precision = {
        id = 386633,
        duration = 30,
        max_stack = 2
    },
    fatal_mark = {
        id = 383704,
        duration = 60,
        max_stack = 999
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    hurricane = { --TODO: implement during bladestorm
        id = 390581,
        duration = 6,
        max_stack = 6,
    },
    fatality = {
        id = 383703
    },
    honed_reflexes = {
        id = 382461
    },
    improved_overpower = {
        id = 385571,
    },
    intimidating_shout = {
        id = function () return talent.menace.enabled and 316593 or 5246 end,
        duration = function () return talent.menace.enabled and 15 or 8 end,
        max_stack = 1
    },
    merciless_bonegrinder = {
        id = 383316,
        duration = 9,
        max_stack = 1,
    },
    mortal_wounds = {
        id = 115804,
        duration = 10,
        max_stack = 1
    },
    juggernaut = {
        id = 383290,
        duration = 12,
        max_stack = 15
    },
    overpower = {
        id = 7384,
        duration = 15,
        max_stack = function() return 1 + (talent.martial_prowess.enabled and 1 or 0) end,
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    recklessness = {
        id = 1719,
        duration = 4,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = function() return 15 + (talent.bloodletting.enabled and 6 or 0) end,
        tick_time = 3,
        max_stack = 1
    },
    sharpen_blade = {
        id = 198817,
        duration = 3600,
        max_stack = 1
    },
    spear_of_bastion = {
        id = 376080,
        duration = function() return talent.elysian_might.enabled and 6 or 4 end,
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
    sweeping_strikes = {
        id = 260708,
        duration = 15,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
    },
    test_of_might = {
        id = 385013,
        duration = 3600,
        max_stack = 1
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 384318,
        duration = function () return 8 + (talent.thunderous_words.enabled and 2 or 0) + (talent.bloodletting.enabled and 6 or 0) end,
        tick_time = 2,
        max_stack = 1
    },
    vicious_warbanner = {
        id = 320707,
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
    wild_strikes = { --Renamed from Quick Thinking to Wild Strikes in build 45779, 
        id = 392778,
        duration = 10,
        max_stack = 1
    },
} )

local rageSpent = 0
local gloryRage = 0

spec:RegisterStateExpr( "rage_spent", function ()
    return rageSpent
end )

spec:RegisterStateExpr( "glory_rage", function ()
    return gloryRage
end )

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" then
        if talent.anger_management.enabled then
            rage_spent = rage_spent + amt
            local reduction = floor( rage_spent / 20 )
            rage_spent = rage_spent % 20

            if reduction > 0 then
                cooldown.colossus_smash.expires = cooldown.colossus_smash.expires - reduction
                cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
                cooldown.warbreaker.expires = cooldown.warbreaker.expires - reduction
            end
        end

        if legendary.glory.enabled and buff.conquerors_banner.up then
            glory_rage = glory_rage + amt
            local reduction = floor( glory_rage / 20 ) * 0.5
            glory_rage = glory_rage % 20

            buff.conquerors_banner.expires = buff.conquerors_banner.expires + reduction
        end
    end
end )

local last_cs_target = nil

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" then
        if ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
            last_cs_target = destGUID
        end
    end
end )


local RAGE = Enum.PowerType.Rage
local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )

        if current < lastRage then
            rageSpent = ( rageSpent + lastRage - current ) % 20 -- Anger Mgmt.

            if state.legendary.glory.enabled and FindPlayerAuraByID( 324143 ) then
                gloryRage = ( gloryRage + lastRage - current ) % 20 -- Glory.
            end
        end

        lastRage = current
    end
end )


spec:RegisterHook( "TimeToReady", function( wait, action )
    local id = class.abilities[ action ].id
    if buff.bladestorm.up and ( id < -99 or id > 0 ) then
        wait = max( wait, buff.bladestorm.remains )
    end
    return wait
end )


local cs_actual

spec:RegisterHook( "reset_precast", function ()
    rage_spent = nil

    if not cs_actual then cs_actual = cooldown.colossus_smash end

    if talent.warbreaker.enabled and cs_actual then
        cooldown.colossus_smash = cooldown.warbreaker
    else
        cooldown.colossus_smash = cs_actual
    end


    if prev_gcd[1].colossus_smash and time - action.colossus_smash.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
        -- Apply Colossus Smash early because its application is delayed for some reason.
        applyDebuff( "target", "colossus_smash", 10 + (talent.blunt_instruments.enabled and 3 or 0) )
    elseif prev_gcd[1].warbreaker and time - action.warbreaker.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
        applyDebuff( "target", "colossus_smash", 10 + (talent.blunt_instruments.enabled and 3 or 0) )
    end
end )


spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )

-- Tier 28
spec:RegisterGear( 'tier28', 188942, 188941, 188940, 188938, 188937 )
spec:RegisterSetBonuses( "tier28_2pc", 364553, "tier28_4pc", 363913 )
-- 2-Set - Pile On - Colossus Smash / Warbreaker lasts 3 sec longer and increases your damage dealt to affected enemies by an additional 5%.
-- 4-Set - Pile On - Tactician has a 50% increased chance to proc against enemies with Colossus Smash and causes your next Overpower to grant 2% Strength, up to 20% for 15 sec.
spec:RegisterAuras( {
    pile_on_ready = {
        id = 363917,
        duration = 15,
        max_stack = 1,
    },
    pile_on_str = {
        id = 366769,
        duration = 15,
        max_stack = 4,
        copy = "pile_on"
    }
})
------------------------------------------------------------

-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = -15,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.blademasters_torment.enabled then applyBuff ( "bladestorm", 4) end
            if talent.warlords_torment.enabled then applyBuff ( "recklessness" ) end
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


    bladestorm = {
        id = 227847,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "bladestorm",
        startsCombat = true,
        texture = 236303,
        range = 8,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bladestorm" )
            setCooldown( "global_cooldown", 6 * haste )
            --if talent.hurricane.enabled then addStack( "hurricane", nil, 1 ) end -- Needs logic to add stacks every 1 * haste seconds during BS
            if talent.blademasters_torment.enabled then applyBuff("avatar", 4) end
        end,
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


    cleave = {
        id = 845,
        cast = 0,
        cooldown = function () return 6 - (talent.reaping_swings.enabled and 3 or 0) end,
        gcd = "spell",

        spend = function() return 20 - (buff.battlelord.up and 10 or 0) end,
        spendType = "rage",

        talent = "cleave",
        startsCombat = false,
        texture = 132338,

        handler = function ()
            applyDebuff ( "target" , "deep_wounds" )
            active_dot.deep_wounds = max( active_dot.deep_wounds, active_enemies )
            if buff.overpower.up then removeBuff ( "overpower" ) end
        end,
    },


    colossus_smash = {
        id = 167105,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "colossus_smash",
        startsCombat = false,
        texture = 464973,

        handler = function ()
            applyDebuff( "target", "colossus_smash" )
            applyDebuff( "target", "deep_wounds" )
            if talent.in_for_the_kill.enabled then
                applyBuff( "in_for_the_kill" )
                stat.haste = state.haste + ( target.health.pct < 35 and 0.25 or 0.1 )
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

        handler = function ()
            removeBuff( "battle_stance" )
            applyBuff( "defensive_stance" )
        end,
    },


    die_by_the_sword = {
        id = 118038,
        cast = 0,
        cooldown = function () 
            if valor_in_victory.enabled then
                return 120 - (talent.valor_in_victory.rank * 15)
            else
                return 120
            end
        end,
        gcd = "off",
        
        talent = "die_by_the_sword",
        startsCombat = false,
        texture = 132336,
        
        toggle = "defensives",

        handler = function ()
            applyBuff ( "die_by_the_sword" )
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


    duel = {
        id = 236273,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "duel",
        startsCombat = false,
        texture = 1455893,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff ( "target", "duel" )
            applyBuff ( "duel" )
        end,
    },


    execute = {
        id = 163201,
        cast = 0,
        cooldown = function () return (talent.improved_execute.enabled and 0 or 6) end,
        gcd = "spell",
        noOverride = 317485, -- Condemn

        spend = function () return min(max(rage.current, 20),40) end,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        cycle = "execute_ineligible",

        usable = function () 
            if buff.sudden_death.up then
                return true
            else
                return target.health_pct < (talent.massacre.enabled and 35 or 20), "requires target in execute range" 
            end
        end,
        handler = function ()
            if buff.sudden_death.down and rage.current > 20 then
                local amt = min(max(rage.current, 20),40) -- Min 20, Max 40 spent
                spend( amt, "rage" ) -- Spend Rage
                if talent.improved_execute.enabled then
                    gain( amt * 0.2, "rage" ) -- Regain 20% for target not dying
                end
                if talent.critical_thinking.enabled then
                    gain( amt * (talent.critical_thinking.rank * 0.1), "rage") -- Regain up to another 20% for critical thinking
                end
            end
            if talent.executioners_precision.enabled then applyBuff ( "executioners_precision" ) end
            if talent.juggernaut.enabled then applyBuff("juggernaut") end
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
            applyDebuff ( "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = function () return 45 + (talent.bounding_stride.enabled and -15 or 0) + (talent.wrenching_impact.enabled and 45 or 0) end,
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
        startsCombat = false,
        texture = 589768,

        handler = function ()
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


    mortal_strike = {
        id = 12294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return 30 - (buff.battlelord.up and 10 or 0) end,
        spendType = "rage",

        talent = "mortal_strike",
        startsCombat = true,
        texture = 132355,

        handler = function ()
            if buff.overpower.up then removeBuff ( "overpower" ) end
            if buff.executioners_precision.up then removeBuff( "executioners_precision" ) end
            if buff.battlelord.up then removeBuff ( "battlelord" ) end
        end,
    },


    overpower = {
        id = 7384,
        cast = 0,
        charges = function () return 1 + (talent.dreadnaught.enabled and 1 or 0) end,
        cooldown = function () return 12 - (talent.honed_reflexes.enabled and 1 or 0) end,
        recharge = function () return 12 - (talent.honed_reflexes.enabled and 1 or 0) end,
        gcd = "spell",

        talent = "overpower",
        startsCombat = true,
        texture = 132223,

        handler = function ()
            if talent.martial_prowess.enabled then applyBuff ( "overpower" ) end

            --Tier28
            if buff.pile_on_ready.up then
                addStack( "pile_on_str", nil, 1 )
                removeBuff( "pile_on_ready" )
            end
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

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
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

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( (talent.inspiring_presence.enabled and 0.25 or 0.15) * health.max, "health" )
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
            applyDebuff ( "target", "rend" )
        end,
    },


    sharpen_blade = {
        id = 198817,
        cast = 0,
        cooldown = 25,
        gcd = "off",

        pvptalent = "sharpen_blade",
        startsCombat = false,
        texture = 1380678,

        handler = function ()
            applyBuff ("sharpened_blades")
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = function () return (pvptalent.demolition.enabled and 90 or 180) end,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = true,
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


    skullsplitter = {
        id = 260643,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "skullsplitter",
        startsCombat = false,
        texture = 2065621,

        handler = function ()
            gain(30,"rage")
            if talent.tide_of_blood.enabled then
                removeDebuff("target","rend")
                removeDebuff("target","deep_wounds")
            end
        end,
    },


    slam = {
        id = 1464,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 20 + (talent.barbaric_training.enabled and 5 or 0) end,
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
    

    sweeping_strikes = {
        id = 260708,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 0.75,
        
        
        talent = "sweeping_strikes",
        startsCombat = false,
        texture = 132306,

        handler = function ()
            setCooldown( "global_cooldown", 0.75 )
            applyBuff( "sweeping_strikes" )
            -- TODO: Collateral Damage logic for when SS expires
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
        hasteCD = true,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

            if talent.blood_and_thunder.enabled and debuff.rend.up then
                active_dot.rend = min( active_enemies, 5 )
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
            removeBuff( "victorious" )
            gain( 0.2 * health.max, "health" )
        end,
    },


    war_banner = {
        id = 236320,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        pvptalent = "war_banner",
        startsCombat = false,
        texture = 603532,

        toggle = "cooldowns",

        handler = function ()
            applyBuff ("war_banner")
        end,
    },


    warbreaker = {
        id = 262161,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "warbreaker",
        startsCombat = false,
        texture = 2065633,
        range = 8,

        handler = function ()
            if talent.in_for_the_kill.enabled then applyBuff( "in_for_the_kill" ) end
            applyDebuff( "target", "colossus_smash" )
            active_dot.colossus_smash = max( active_dot.colossus_smash, active_enemies )
            -- TODO: Test of Might Logic for when warbreaker / CS expires
        end,
    },


    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = function () return (talent.storm_of_steel.enabled and 14 or 0) end,
        gcd = "spell",

        spend = function() return 30 + (talent.barbaric_training.enabled and 5 or 0 ) + (talent.storm_of_swords.enabled and 30 or 0) end,
        spendType = "rage",

        startsCombat = false,
        texture = 132369,

        handler = function ()
            removeBuff ( "collateral_damage" )
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

spec:RegisterPriority( "Arms", 20220929,
-- Notes
[[

]],
-- Priority
[[

]] )
