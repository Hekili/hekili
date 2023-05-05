if UnitClassBase( 'player' ) ~= 'ROGUE' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 4 )


-- TODO:  Check gains from Cold Blood, Seal Fate; i.e., guaranteed crits.


spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    adrenaline_rush            = {   205, 1, 13750 },
    aggression                 = {  1122, 5, 18427, 18428, 18429, 61330, 61331 },
    blade_flurry               = {   223, 1, 13877 },
    blade_twisting             = {  1706, 2, 31124, 31126 },
    blood_spatter              = {  2068, 2, 51632, 51633 },
    camouflage                 = {   244, 3, 13975, 14062, 14063 },
    cheat_death                = {  1722, 3, 31228, 31229, 31230 },
    close_quarters_combat      = {   182, 5, 13706, 13804, 13805, 13806, 13807 },
    cold_blood                 = {   280, 1, 14177 },
    combat_potency             = {  1825, 5, 35541, 35550, 35551, 35552, 35553 },
    cut_to_the_chase           = {  2070, 5, 51664, 51665, 51667, 51668, 51669 },
    deadened_nerves            = {  1723, 3, 31380, 31382, 31383 },
    deadliness                 = {  1702, 5, 30902, 30903, 30904, 30905, 30906 },
    deadly_brew                = {  2065, 2, 51625, 51626 },
    deflection                 = {   187, 3, 13713, 13853, 13854 },
    dirty_deeds                = {   265, 2, 14082, 14083 },
    dirty_tricks               = {   262, 2, 14076, 14094 },
    dual_wield_specialization  = {   221, 5, 13715, 13848, 13849, 13851, 13852 },
    elusiveness                = {   247, 2, 13981, 14066 },
    endurance                  = {   204, 2, 13742, 13872 },
    enveloping_shadows         = {  1711, 3, 31211, 31212, 31213 },
    filthy_tricks              = {  2079, 2, 58414, 58415 },
    find_weakness              = {  1718, 3, 31234, 31235, 31236 },
    fleet_footed               = {  1721, 2, 31208, 31209 },
    focused_attacks            = {  2069, 3, 51634, 51635, 51636 },
    ghostly_strike             = {   303, 1, 14278 },
    hack_and_slash             = {   242, 5, 13960, 13961, 13962, 13963, 13964 },
    heightened_senses          = {  1701, 2, 30894, 30895 },
    hemorrhage                 = {   681, 1, 16511 },
    honor_among_thieves        = {  2078, 3, 51698, 51700, 51701 },
    hunger_for_blood           = {  2071, 1, 51662 },
    improved_ambush            = {   263, 2, 14079, 14080 },
    improved_eviscerate        = {   276, 3, 14162, 14163, 14164 },
    improved_expose_armor      = {   278, 2, 14168, 14169 },
    improved_gouge             = {   203, 3, 13741, 13793, 13792 },
    improved_kick              = {   206, 2, 13754, 13867 },
    improved_kidney_shot       = {   279, 3, 14174, 14175, 14176 },
    improved_poisons           = {   268, 5, 14113, 14114, 14115, 14116, 14117 },
    improved_sinister_strike   = {   201, 2, 13732, 13863 },
    improved_slice_and_dice    = {  1827, 2, 14165, 14166 },
    improved_sprint            = {   222, 2, 13743, 13875 },
    initiative                 = {   245, 3, 13976, 13979, 13980 },
    killing_spree              = {  2076, 1, 51690 },
    lethality                  = {   269, 5, 14128, 14132, 14135, 14136, 14137 },
    lightning_reflexes         = {   186, 3, 13712, 13788, 13789 },
    mace_specialization        = {   184, 5, 13709, 13800, 13801, 13802, 13803 },
    malice                     = {   270, 5, 14138, 14139, 14140, 14141, 14142 },
    master_of_deception        = {   241, 3, 13958, 13970, 13971 },
    master_of_subtlety         = {  1713, 3, 31221, 31222, 31223 },
    master_poisoner            = {  1715, 3, 31226, 31227, 58410 },
    murder                     = {   274, 2, 14158, 14159 },
    mutilate                   = {  1719, 1,  1329 },
    nerves_of_steel            = {  1707, 2, 31130, 31131 },
    opportunity                = {   261, 2, 14057, 14072 },
    overkill                   = {   281, 1, 58426 },
    precision                  = {   181, 5, 13705, 13832, 13843, 13844, 13845 },
    premeditation              = {   381, 1, 14183 },
    preparation                = {   284, 1, 14185 },
    prey_on_the_weak           = {  2075, 5, 51685, 51686, 51687, 51688, 51689 },
    puncturing_wounds          = {   277, 3, 13733, 13865, 13866 },
    quick_recovery             = {  1762, 2, 31244, 31245 },
    relentless_strikes         = {  2244, 5, 14179, 58422, 58423, 58424, 58425 },
    remorseless_attacks        = {   272, 2, 14144, 14148 },
    riposte                    = {   301, 1, 14251 },
    ruthlessness               = {   273, 3, 14156, 14160, 14161 },
    savage_combat              = {  2074, 2, 51682, 58413 },
    seal_fate                  = {   283, 5, 14186, 14190, 14193, 14194, 14195 },
    serrated_blades            = {  1123, 3, 14171, 14172, 14173 },
    setup                      = {   246, 3, 13983, 14070, 14071 },
    shadow_dance               = {  2081, 1, 51713 },
    shadowstep                 = {  1714, 1, 36554 },
    sinister_calling           = {  1712, 5, 31216, 31217, 31218, 31219, 31220 },
    slaughter_from_the_shadows = {  2080, 5, 51708, 51709, 51710, 51711, 51712 },
    sleight_of_hand            = {  1700, 2, 30892, 30893 },
    surprise_attacks           = {  1709, 1, 32601 },
    throwing_specialization    = {  2072, 2,  5952, 51679 },
    turn_the_tables            = {  2066, 3, 51627, 51628, 51629 },
    unfair_advantage           = {  2073, 2, 51672, 51674 },
    vigor                      = {   382, 1, 14983 },
    vile_poisons               = {   682, 3, 16513, 16514, 16515 },
    vitality                   = {  1705, 3, 31122, 31123, 61329 },
    waylay                     = {  2077, 2, 51692, 51696 },
    weapon_expertise           = {  1703, 2, 30919, 30920 },
} )


-- Glyphs
spec:RegisterGlyphs( {
    [56808] = "adrenaline_rush",
    [56813] = "ambush",
    [56800] = "backstab",
    [56818] = "blade_flurry",
    [58039] = "blurred_speed",
    [63269] = "cloak_of_shadows",
    [56820] = "crippling_poison",
    [56806] = "deadly_throw",
    [58032] = "distract",
    [64199] = "envenom",
    [56799] = "evasion",
    [56802] = "eviscerate",
    [56803] = "expose_armor",
    [63254] = "fan_of_knives",
    [56804] = "feint",
    [56812] = "garrote",
    [56814] = "ghostly_strike",
    [56809] = "gouge",
    [56807] = "hemorrhage",
    [63249] = "hunger_for_blood",
    [63252] = "killing_spree",
    [63268] = "mutilate",
    [58027] = "pick_lock",
    [58017] = "pick_pocket",
    [56819] = "preparation",
    [56801] = "rupture",
    [58033] = "safe_fall",
    [56798] = "sap",
    [63253] = "shadow_dance",
    [56821] = "sinister_strike",
    [56810] = "slice_and_dice",
    [56811] = "sprint",
    [63256] = "tricks_of_the_trade",
    [58038] = "vanish",
    [56805] = "vigor",
} )


-- Auras
spec:RegisterAuras( {
    -- Energy regeneration increased by $s1%.
    adrenaline_rush = {
        id = 13750,
        duration = function() return glyph.adrenaline_rush.enabled and 21 or 15 end,
        max_stack = 1,
    },
    -- Attack speed increased by $s1%.  Weapon attacks strike an additional nearby opponent.
    blade_flurry = {
        id = 13877,
        duration = 15,
        max_stack = 1,
    },
    -- Dazed.
    blade_twisting = {
        id = 51585,
        duration = 8,
        max_stack = 1,
        copy = { 51585, 31125 },
    },
    -- Disoriented.
    blind = {
        id = 2094,
        duration = 10,
        max_stack = 1,
    },
    -- Stunned.
    cheap_shot = {
        id = 1833,
        duration = 4,
        max_stack = 1,
    },
    cheating_death = {
        id = 45182,
        duration = 3,
        max_stack = 1,
    },
    -- Increases chance to resist spells by $s1%.
    cloak_of_shadows = {
        id = 31224,
        duration = 5,
        max_stack = 1,
    },
    -- Critical strike chance of your next offensive ability increased by $s1%.
    cold_blood = {
        id = 14177,
        duration = 3600,
        max_stack = 1,
    },
    deadly_poison = {
        id = 2818,
        duration = 12,
        max_stack = 5,
        copy = { 2819, 11353, 11354, 25349, 26968, 27187, 57970, 57969 },
    },
    -- Movement slowed by $s2%.
    deadly_throw = {
        id = 48674,
        duration = 6,
        max_stack = 1,
        copy = { 26679, 48673, 48674 },
    },
    -- Detecting traps.
    detect_traps = {
        id = 2836,
        duration = 3600,
        max_stack = 1,
    },
    -- Disarmed.
    dismantle = {
        id = 51722,
        duration = 10,
        max_stack = 1,
    },
    -- Chance to apply Deadly Poison increased by $s3% and frequency of applying Instant Poison increased by $s2%.
    envenom = {
        id = 57993,
        duration = 1,
        max_stack = 1,
        copy = { 32645, 32684, 57992, 57993 },
    },
    -- Dodge chance increased by $s1% and chance ranged attacks hit you reduced by $s2%.
    evasion = {
        id = 26669,
        duration = function() return glyph.evasion.enabled and 20 or 15 end,
        max_stack = 1,
        copy = { 5277, 26669, 67354, 67378, 67380 },
    },
    -- $s2% reduced damage taken from area of effect attacks.
    feint = {
        id = 48659,
        duration = 6,
        max_stack = 1,
        copy = { 48659 },
    },
    -- $s1 damage every $t1 seconds.
    garrote = {
        id = 48676,
        duration = function() return glyph.garrote.enabled and 21 or 18 end,
        tick_time = 3,
        max_stack = 1,
        copy = { 703, 8631, 8632, 8633, 8818, 11289, 11290, 26839, 26884, 48675, 48676 },
    },
    -- Silenced.
    garrote_silence = {
        id = 1330,
        duration = 3,
        max_stack = 1,
    },
    -- Dodge chance increased by $s2%.
    ghostly_strike = {
        id = 14278,
        duration = function() return glyph.ghostly_strike.enabled and 11 or 7 end,
        max_stack = 1,
    },
    -- Incapacitated.
    gouge = {
        id = 1776,
        duration = function() return 4 + 0.5 * talent.improved_gouge.rank end,
        max_stack = 1,
    },
    -- Increases damage taken by $s3.
    hemorrhage = {
        id = 16511,
        duration = 15,
        max_stack = 1,
        copy = { 16511, 17347, 17348, 26864, 48660 },
    },
    hunger_for_blood = {
        id = 63848,
        duration = 60,
        max_stack = 1,
    },
    -- Stunned.
    kidney_shot = {
        id = 8643,
        duration = 1,
        max_stack = 1,
        copy = { 408, 8643, 27615, 30621 },
    },
    -- Attacking an enemy every $t1 sec.  Damage dealt increased by $61851s3%.
    killing_spree = {
        id = 51690,
        duration = 2,
        tick_time = 0.5,
        max_stack = 1,
    },
    master_of_subtlety = {
        id = 31665,
        duration = 6,
        max_stack = 1,
    },
    overkill = {
        id = 58427,
        duration = 20,
        max_stack = 1,
    },
    -- Critical strike chance for your next Sinister Strike, Backstab, Mutilate, Ambush, Hemorrhage, or Ghostly strike increased by $s1%.
    remorseless = {
        id = 14149,
        duration = 20,
        max_stack = 1,
        copy = { 14143, 14149 },
    },
    -- Melee attack speed slowed by $s2%.
    riposte = {
        id = 14251,
        duration = 30,
        max_stack = 1,
    },
    -- Causes damage every $t1 seconds.
    rupture = {
        id = 48672,
        duration = function() return ( glyph.rupture.enabled and 10 or 6 ) + ( 2 * combo_points.current ) end,
        tick_time = 2,
        max_stack = 1,
        copy = { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671, 48672 },
    },
    -- Sapped.
    sap = {
        id = 51724,
        duration = function() return glyph.sap.enabled and 80 or 60 end,
        max_stack = 1,
        copy = { 2070, 6770, 11297, 51724 },
    },
    -- Increases physical damage taken by $s1%.
    savage_combat = {
        id = 58684,
        duration = 3600,
        max_stack = 1,
        copy = { 58683, 58684 },
    },
    -- Can use opening abilities without being stealthed.
    shadow_dance = {
        id = 51713,
        duration = function() return glyph.sap.enabled and 8 or 6 end,
        max_stack = 1,
    },
    shadowstep = {
        id = 36563,
        duration = 10,
        max_stack = 1,
    },
    shadowstep_sprint = {
        id = 36554,
        duration = 3,
        max_stack = 1,
    },
    -- Silenced.
    silenced_improved_kick = {
        id = 18425,
        duration = 2,
        max_stack = 1,
    },
    -- Melee attack speed increased by $s2%.
    slice_and_dice = {
        id = 6774,
        duration = function() return ( ( glyph.slice_and_dice.enabled and 9 or 6 ) + ( 3 * combo_points.current ) ) * ( 1 + 0.25 * talent.improved_slice_and_dice.rank ) end,
        max_stack = 1,
        copy = { 5171, 6434, 6774, 60847 },
    },
    -- Movement speed increased by $w1%.
    sprint = {
        id = 11305,
        duration = 15,
        max_stack = 1,
        copy = { 2983, 8696, 11305, 48594, 56354 },
    },
    -- Stealthed.  Movement slowed by $s3%.
    stealth = {
        id = 1784,
        duration = 3600,
        max_stack = 1,
    },
    -- $s1% increased critical strike chance with combo moves.
    turn_the_tables = {
        id = 52915,
        duration = 8,
        max_stack = 1,
        copy = { 52915, 52914, 52910 },
    },
    vanish = {
        id = 11327,
        duration = 10,
        max_stack = 1,
    },
    -- Time between melee and ranged attacks increased by $s1%.    Movement speed reduced by $s2%.
    waylay = {
        id = 51693,
        duration = 8,
        max_stack = 1,
    },
    -- $s1 damage every $t sec
    lacerate = {
        id = 48568,
        duration = 15,
        tick_time = 3,
        max_stack = 5,
        copy = { 33745, 48567, 48568 },
    },
    -- Bleeding for $s1 damage every $t1 seconds.
    pounce_bleed = {
        id = 49804,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
        copy = { 9007, 9824, 9826, 27007, 49804 },
    },
    -- Bleeding for $s2 damage every $t2 seconds.
    rake = {
        id = 48574,
        duration = function() return 9 + ((set_bonus.tier9_2pc == 1 and 3) or 0) end,
        max_stack = 1,
        copy = { 1822, 1823, 1824, 9904, 27003, 48573, 48574, 59881, 59882, 59883, 59884, 59885, 59886 },
    },
    -- Bleed damage every $t1 seconds.
    rip = {
        id = 49800,
        duration = function() return 12 + ((glyph.rip.enabled and 4) or 0) + ((set_bonus.tier7_2pc == 1 and 4) or 0) end,
        tick_time = 2,
        max_stack = 1,
        copy = { 1079, 9492, 9493, 9752, 9894, 9896, 27008, 49799, 49800 },
    },
    rend = {
        id = 47465,
        duration = 15,
        max_stack = 1,
        shared = "target",
        copy = { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208 }
    },
    deep_wound = {
        id = 43104,
        duration = 12,
        max_stack = 1,
        shared = "target"
    },
    bleed = {
        alias = { "lacerate", "pounce_bleed", "rip", "rake", "deep_wound", "rend", "garrote", "rupture" },
        aliasType = "debuff",
        aliasMode = "longest"
    }
} )


spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )


local stealth = {
    rogue   = { "stealth", "vanish", "shadow_dance" },
    mantle  = { "stealth", "vanish" },
    all     = { "stealth", "vanish", "shadow_dance", "shadowmeld" }
}

local enchant_ids = {
    [7] = "deadly",
    [8] = "deadly",
    [626] = "deadly",
    [627] = "deadly",
    [3771] = "deadly",
    [2630] = "deadly",
    [2642] = "deadly",
    [2643] = "deadly",
    [3770] = "deadly",
    [323] = "instant",
    [324] = "instant",
    [325] = "instant",
    [623] = "instant",
    [3769] = "instant",
    [624] = "instant",
    [625] = "instant",
    [2641] = "instant",
    [3768] = "instant",
    [2640] = "anesthetic",
    [3774] = "anesthetic",
    [703] = "wound",
    [704] = "wound",
    [705] = "wound",
    [706] = "wound",
    [2644] = "wound",
    [3772] = "wound",
    [3773] = "wound",
    [35] = "mind",
    [22] = "crippling",
}


spec:RegisterStateTable( "stealthed", setmetatable( {}, {
    __index = function( t, k )
        if k == "rogue" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up
        elseif k == "rogue_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains )

        elseif k == "mantle" then
            return buff.stealth.up or buff.vanish.up
        elseif k == "mantle_remains" then
            return max( buff.stealth.remains, buff.vanish.remains )

        elseif k == "all" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.shadowmeld.up
        elseif k == "remains" or k == "all_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.shadowmeld.remains )
        end

        return false
    end
} ) )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "combo_points" and amt * talent.relentless_strikes.rank * 4 >= 100 then
        gain( 25, "energy" )
    end
end )


-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( action )
    local a = class.abilities[ action ]

    if stealthed.all and ( not a or a.startsCombat ) then
        if buff.stealth.up then
            setCooldown( "stealth", 10 )
            if talent.master_of_subtlety.enabled then applyBuff( "master_of_subtlety", 6 ) end
            if talent.overkill.enabled then applyBuff( "overkill", 20 ) end
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )
    end

    if ( not a or a.startsCombat ) then
        if buff.cold_blood.up then removeBuff( "cold_blood" ) end
        if buff.shadowstep.up then removeBuff( "shadowstep" ) end
    end
end )


spec:RegisterHook( "reset_precast", function()
    if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end

    local mh, mh_expires, _, mh_id, oh, oh_expires, _, oh_id = GetWeaponEnchantInfo()

end )


-- Abilities
spec:RegisterAbilities( {
    -- Increases your Energy regeneration rate by 100% for 15 sec.
    adrenaline_rush = {
        id = 13750,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        talent = "adrenaline_rush",
        startsCombat = false,
        texture = 136206,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "adrenaline_rush" )
            energy.regen = energy.regen * 2
        end,
    },


    -- Ambush the target, causing 275% weapon damage plus 509 to the target.  Must be stealthed and behind the target.  Requires a dagger in the main hand.  Awards 2 combo points.
    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 60 - 4 * talent.slaughter_from_the_shadows.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132282,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            -- TODO: Use fail positioning from Burning Crusade.
            gain( talent.initiative.rank == 3 and 3 or 2, "combo_points" )
            removeBuff( "remorseless" )
            if talent.waylay.rank == 2 then applyDebuff( "target", "waylay" ) end
        end,

        copy = { 8676, 8724, 8725, 11267, 11268, 11269, 27441, 48689, 48690, 48691 },
    },


    -- Backstab the target, causing 150% weapon damage plus 255 to the target.  Must be behind the target.  Requires a dagger in the main hand.  Awards 1 combo point.
    backstab = {
        id = 53,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 60 - 4 * talent.slaughter_from_the_shadows.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132090,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            if glyph.backstab.enabled and debuff.rupture.up then debuff.rupture.expires = debuff.rupture.expires + 2 end
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
            if talent.waylay.rank == 2 then applyDebuff( "target", "waylay" ) end
        end,

        copy = { 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300, 26863, 48656, 48657 },
    },


    -- Increases your attack speed by 20%.  In addition, attacks strike an additional nearby opponent.  Lasts 15 sec.
    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        spend = function() return glyph.blade_flurry.enabled and 0 or 25 end,
        spendType = "energy",

        talent = "blade_flurry",
        startsCombat = false,
        texture = 132350,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "blade_flurry" )
        end,
    },


    -- Blinds the target, causing it to wander disoriented for up to 10 sec.  Any damage caused will remove the effect.
    blind = {
        id = 2094,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.elusiveness.rank end,
        gcd = "totem",

        spend = function() return 30 * ( 1 - 0.25 * talent.dirty_tricks.rank ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 136175,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "blind" )
        end,
    },


    -- Stuns the target for 4 sec.  Must be stealthed.  Awards 2 combo points.
    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 60 - 10 * talent.dirty_deeds.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132092,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            applyDebuff( "tagret", "cheap_shot" )
            gain( talent.initiative.rank == 3 and 3 or 2, "combo_points" )
        end,
    },


    -- Instantly removes all existing harmful spell effects and increases your chance to resist all spells by 90% for 5 sec.  Does not remove effects that prevent you from using Cloak of Shadows.
    cloak_of_shadows = {
        id = 31224,
        cast = 0,
        cooldown = function() return 180 - 15 * talent.elusiveness.rank end,
        gcd = "totem",

        startsCombat = false,
        texture = 136177,

        toggle = "defensives",

        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            applyBuff( "cloak_of_shadows" )
        end,
    },


    -- When activated, increases the critical strike chance of your next offensive ability by 100%.
    cold_blood = {
        id = 14177,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "cold_blood",
        startsCombat = false,
        texture = 135988,

        toggle = "cooldowns",

        nobuff = "cold_blood",

        handler = function ()
            applyBuff( "cold_blood" )
        end,
    },


    -- Finishing move that reduces the movement of the target by 50% for 6 sec and causes increased thrown weapon damage:     1 point  : 223 - 245 damage     2 points: 365 - 387 damage     3 points: 507 - 529 damage     4 points: 649 - 671 damage     5 points: 791 - 813 damage
    deadly_throw = {
        id = 26679,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 135430,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "deadly_throw" )
            spend( combo_points.current, "combo_points" )
            if talent.throwing_specialization.rank == 2 then interrupt() end
        end,

        copy = { 26679, 48673, 48674 },
    },


    -- Disarm the enemy, removing all weapons, shield or other equipment carried for 10 sec.
    dismantle = {
        id = 51722,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 236272,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "dismantle" )
        end,
    },


    -- Throws a distraction, attracting the attention of all nearby monsters for 10 seconds.  Does not break stealth.
    distract = {
        id = 1725,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.filthy_tricks.rank end,
        gcd = "totem",

        spend = function() return 30 - 5 * talent.filthy_tricks.rank end,
        spendType = "energy",

        startsCombat = false,
        texture = 132289,

        handler = function ()
        end,
    },


    -- Finishing move that consumes your Deadly Poison doses on the target and deals instant poison damage.  Following the Envenom attack you have an additional 15% chance to apply Deadly Poison and a 75% increased frequency of applying Instant Poison for 1 sec plus an additional 1 sec per combo point.  One dose is consumed for each combo point:    1 dose:  180 damage    2 doses: 361 damage    3 doses: 541 damage    4 doses: 722 damage    5 doses: 902 damage
    envenom = {
        id = 32645,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 132287,

        usable = function()
            if combo_points.current == 0 then
                return false, "requires combo_points"
            end

            if not debuff.deadly_poison.up then
                return false, "requires deadly_poison debuff"
            end

            return true
        end,

        handler = function ()
            if not ( glyph.envenom.enabled or talent.master_poisoner.rank == 3 ) then
                removeDebuffStack( "target", "deadly_poison", combo_points.current )
            end

            if talent.cut_to_the_chase.rank == 5 and buff.slice_and_dice.up then
                buff.slice_and_dice.expires = query_time + buff.slice_and_dice.duration
            end

            spend( combo_points.current, "combo_points" )
        end,

        copy = { 32645, 32684, 57992, 57993 },
    },


    -- Increases the rogue's dodge chance by 50% and reduces the chance ranged attacks hit the rogue by 25%.  Lasts 15 sec.
    evasion = {
        id = 5277,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0,
        spendType = "energy",

        startsCombat = false,
        texture = 136205,

        toggle = "defensives",

        handler = function ()
            applyBuff( "evasion" )
        end,

        copy = { 5277, 26669 },
    },


    -- Finishing move that causes damage per combo point:     1 point  : 256-391 damage     2 points: 452-602 damage     3 points: 648-813 damage     4 points: 845-1024 damage     5 points: 1040-1235 damage
    eviscerate = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 132292,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            if talent.cut_to_the_chase.rank == 5 and buff.slice_and_dice.up then
                buff.slice_and_dice.expires = query_time + buff.slice_and_dice.duration
            end

            spend( combo_points.current, "combo_points" )
        end,

        copy = { 2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 26865, 31016, 48667, 48668 },
    },


    -- Finishing move that exposes the target, reducing armor by 20% and lasting longer per combo point:     1 point  : 6 sec.     2 points: 12 sec.     3 points: 18 sec.     4 points: 24 sec.     5 points: 30 sec.
    expose_armor = {
        id = 8647,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 25 - 5 * talent.improved_expose_armor.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132354,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            spend( combo_points.current, "combo_points" )
        end,
    },


    -- Instantly throw both weapons at all targets within 8 yards, causing 105% weapon damage with daggers, and 70% weapon damage with all other weapons.
    fan_of_knives = {
        id = 51723,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        texture = 236273,

        handler = function ()
        end,
    },


    -- Performs a feint, causing no damage but lowering your threat by a large amount, making the enemy less likely to attack you.
    feint = {
        id = 1966,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        spend = function() return glyph.feint.enabled and 0 or 20 end,
        spendType = "energy",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            applyBuff( "feint" )
        end,

        copy = { 1966, 6768, 8637, 11303, 25302, 27448, 48658, 48659 },
    },


    -- Garrote the enemy, silencing them for 3 sec causing 768 damage over 18 sec, increased by attack power.  Must be stealthed and behind the target.  Awards 1 combo point.
    garrote = {
        id = 703,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 50 - 10 * talent.dirty_deeds.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132297,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            applyDebuff( "target", "garrote" )
            applyDebuff( "target", "garrote_silence" )
            gain( talent.initiative.rank == 3 and 2 or 1, "combo_points" )
        end,

        copy = { 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884, 48675, 48676 },
    },


    -- Increases dodge by 15% for 7-11 seconds.
    ghostly_strike = {
        id = 14278,
        cast = 0,
        cooldown = function() return glyph.ghostly_strike.enabled and 30 or 20 end,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = true,
        texture = 136136,

        handler = function ()
            applyBuff( "ghostly_strike" )
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
        end,
    },


    -- Causes 79 damage, incapacitating the opponent for 4 sec, and turns off your attack.  Target must be facing you.  Any damage caused will revive the target.  Awards 1 combo point.
    gouge = {
        id = 1776,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        spend = function() return glyph.gouge.enabled and 30 or 45 end,
        spendType = "energy",

        startsCombat = true,
        texture = 132155,

        handler = function ()
            applyDebuff( "target", "gouge" )
            gain( 1, "combo_points" )
        end,
    },


    -- An instant strike that deals 110% weapon damage (160% if a dagger is equipped) and causes the target to hemorrhage, increasing any Physical damage dealt to the target by up to 13.  Lasts 10 charges or 15 sec.  Awards 1 combo point.
    hemorrhage = {
        id = 16511,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 35 - talent.slaughter_from_the_shadows.rank end,
        spendType = "energy",

        talent = "hemorrhage",
        startsCombat = true,
        texture = 136168,

        handler = function ()
            applyDebuff( "target", "hemorrhage", nil, 10 )
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
        end,

        copy = { 16511, 17347, 17348, 26864, 48660 }
    },


    -- Enrages you, increasing all damage caused by 5%.  Requires a bleed effect to be active on the target.  Lasts 1 min.
    hunger_for_blood = {
        id = 63848,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 15,
        spendType = "energy",

        talent = "hunger_for_blood",
        startsCombat = true,
        texture = 236276,

        usable = function()
            return debuff.bleed.up
        end,

        handler = function ()
            applyBuff( "hunger_for_blood" )
        end,
    },


    -- A quick kick that interrupts spellcasting and prevents any spell in that school from being cast for 5 sec.
    kick = {
        id = 1766,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132219,

        toggle = "interrupts",

        debuff = "casting",
        timeToReady = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.improved_kick.rank > 1 then applyDebuff( "target", "silenced_improved_kick" ) end
        end,
    },


    -- Finishing move that stuns the target.  Lasts longer per combo point:     1 point  : 2 seconds     2 points: 3 seconds     3 points: 4 seconds     4 points: 5 seconds     5 points: 6 seconds
    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132298,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "kidney_shot" )
            spend( combo_points.current, "combo_points" )
        end,

        copy = { 408, 8643 },
    },


    -- Step through the shadows from enemy to enemy within 10 yards, attacking an enemy every .5 secs with both weapons until 5 assaults are made, and increasing all damage done by 20% for the duration.  Can hit the same target multiple times.  Cannot hit invisible or stealthed targets.
    killing_spree = {
        id = 51690,
        cast = 0,
        cooldown = function() return glyph.killing_spree.enabled and 75 or 120 end,
        gcd = "totem",

        spend = 0,
        spendType = "energy",

        talent = "killing_spree",
        startsCombat = true,
        texture = 236277,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "killing_spree" )
            setCooldown( "global_cooldown", 2.5 )
        end,
    },


    -- Instantly attacks with both weapons for 100% weapon damage plus an additional 44 with each weapon.  Damage is increased by 20% against Poisoned targets.  Awards 2 combo points.
    mutilate = {
        id = 1329,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return glyph.mutilate.enabled and 55 or 60 end,
        spendType = "energy",

        talent = "mutilate",
        startsCombat = true,
        texture = 132304,

        handler = function ()
            gain( 2, "combo_points" )
            removeBuff( "remorseless" )
        end,

        copy = { 1329, 34411, 34412, 34413, 48663, 48666 },
    },


    -- When used, adds 2 combo points to your target.  You must add to or use those combo points within 20 sec or the combo points are lost.
    premeditation = {
        id = 14183,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = 0,
        spendType = "energy",

        talent = "premeditation",
        startsCombat = false,
        texture = 136183,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            gain( 2, "combo_points" )
        end,
    },


    -- When activated, this ability immediately finishes the cooldown on your Evasion, Sprint, Vanish, Cold Blood and Shadowstep abilities.
    preparation = {
        id = 14185,
        cast = 0,
        cooldown = function() return 480 - 90 * talent.filthy_tricks.rank end,
        gcd = "totem",

        talent = "preparation",
        startsCombat = false,
        texture = 136121,

        toggle = "cooldowns",

        handler = function ()
            setCooldown( "evasion", 0 )
            setCooldown( "sprint", 0 )
            setCooldown( "vanish", 0 )
            setCooldown( "cold_blood", 0 )
            setCooldown( "shadowstep", 0 )

            if glyph.preparation.enabled then
                setCooldown( "blade_flurry", 0 )
                setCooldown( "dismantle", 0 )
                setCooldown( "kick", 0 )
            end
        end,
    },


    -- A strike that becomes active after parrying an opponent's attack.  This attack deals 150% weapon damage and slows their melee attack speed by 20% for 30 sec.  Awards 1 combo point.
    riposte = {
        id = 14251,
        cast = 0,
        cooldown = 6,
        gcd = "totem",

        spend = 10,
        spendType = "energy",

        talent = "riposte",
        startsCombat = true,
        texture = 132336,

        handler = function ()
            applyDebuff( "target", "riposte" )
            gain( 1, "combo_points" )
        end,
    },


    -- Finishing move that causes damage over time, increased by your attack power.  Lasts longer per combo point:     1 point  : 346 damage over 8 secs     2 points: 505 damage over 10 secs     3 points: 685 damage over 12 secs     4 points: 887 damage over 14 secs     5 points: 1111 damage over 16 secs
    rupture = {
        id = 1943,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132302,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "rupture" )
            spend( combo_points.current, "combo_points" )
        end,

        copy = { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671, 48672 },
    },


    -- Incapacitates the target for up to 45 sec.  Must be stealthed.  Only works on Humanoids that are not in combat.  Any damage caused will revive the target.  Only 1 target may be sapped at a time.
    sap = {
        id = 2070,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 65 * ( 1 - 0.25 * talent.dirty_tricks.rank ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 132310,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            applyDebuff( "target", "sap" )
        end,

        copy = { 2070, 6770, 11297, 51724 },
    },


    -- Enter the Shadow Dance for 6 sec, allowing the use of Sap, Garrote, Ambush, Cheap Shot, Premeditation, Pickpocket and Disarm Trap regardless of being stealthed.
    shadow_dance = {
        id = 51713,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "shadow_dance",
        startsCombat = false,
        texture = 236279,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "shadow_dance" )
        end,
    },


    -- Attempts to step through the shadows and reappear behind your enemy and increases movement speed by 70% for 3 sec.  The damage of your next ability is increased by 20% and the threat caused is reduced by 50%.  Lasts 10 sec.
    shadowstep = {
        id = 36554,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.filthy_tricks.rank end,
        gcd = "off",

        spend = function() return 10 - 5 * talent.filthy_tricks.rank end,
        spendType = "energy",

        talent = "shadowstep",
        startsCombat = true,
        texture = 132303,

        handler = function ()
            applyBuff( "shadowstep_sprint" )
            applyBuff( "shadowstep" )
            setDistance( 7.5 )
        end,
    },


    -- Performs an instant off-hand weapon attack that automatically applies the poison from your off-hand weapon to the target.  Slower weapons require more Energy.  Neither Shiv nor the poison it applies can be a critical strike.  Awards 1 combo point.
    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40, -- TODO: Cost is based on weapon speed.
        spendType = "energy",

        startsCombat = true,
        texture = 135428,

        handler = function ()
            -- TODO: Apply offhand poison.
            gain( 1, "combo_points" )
        end,
    },


    -- An instant strike that causes 98 damage in addition to 100% of your normal weapon damage.  Awards 1 combo point.
    sinister_strike = {
        id = 1752,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function()
            if talent.improved_sinister_strike.rank == 2 then return 40 end
            if talent.improved_sinister_strike.rank == 1 then return 42 end
            return 45
        end,
        spendType = "energy",

        startsCombat = true,
        texture = 136189,

        handler = function ()
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
        end,

        copy = { 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294, 26861, 26862, 48637, 48638 },
    },


    -- Finishing move that increases melee attack speed by 40%.  Lasts longer per combo point:     1 point  : 9 seconds     2 points: 12 seconds     3 points: 15 seconds     4 points: 18 seconds     5 points: 21 seconds
    slice_and_dice = {
        id = 5171,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132306,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyBuff( "slice_and_dice" )
            spend( combo_points.current, "combo_points" )
        end,

        copy = { 5171, 6774 },
    },


    -- Increases the rogue's movement speed by 70% for 15 sec.  Does not break stealth.
    sprint = {
        id = 2983,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        startsCombat = false,
        texture = 132307,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "sprint" )
        end,

        copy = { 2983, 8696, 11305 },
    },


    -- Allows the rogue to sneak around, but reduces your speed by 30%.  Lasts until cancelled.
    stealth = {
        id = 1784,
        cast = 0,
        cooldown = function() return 10 - talent.camouflage.rank end,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        usable = function() return time == 0, "cannot be in combat" end,

        handler = function ()
            applyBuff( "stealth" )
        end,
    },


    -- The current party or raid member becomes the target of your Tricks of the Trade.  The threat caused by your next damaging attack and all actions taken for 6 sec afterwards will be transferred to the target.  In addition, all damage caused by the target is increased by 15% during this time.
    tricks_of_the_trade = {
        id = 57934,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.filthy_tricks.rank end,
        gcd = "totem",

        spend = function() return 15 - 5 * talent.filthy_tricks.rank end,
        spendType = "energy",

        startsCombat = false,
        texture = 236283,

        handler = function ()
            applyBuff( "tricks_of_the_trade" )
        end,
    },


    -- Allows the rogue to vanish from sight, entering an improved stealth mode for 10 sec.  Also breaks movement impairing effects.  More effective than Vanish (Rank 2).
    vanish = {
        id = 1856,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.elusiveness.rank end,
        gcd = "off",

        spend = 0,
        spendType = "energy",

        startsCombat = true,
        texture = 132331,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "stealth" )
        end,

        copy = { 1856, 1857, 26889 },

    },
} )

spec:RegisterSetting("rogue_description", nil, {
    type = "description",
    name = "Adjust the settings below according to your playstyle preference. It is always recommended that you use a simulator "..
        "to determine the optimal values for these settings for your specific character."
})

spec:RegisterSetting("rogue_description_footer", nil, {
    type = "description",
    name = "\n\n"
})

spec:RegisterSetting("rogue_general", nil, {
    type = "header",
    name = "General"
})

spec:RegisterSetting("rogue_general_description", nil, {
    type = "description",
    name = "General settings will change the parameters used in the core rotation.\n\n"
})

spec:RegisterSetting("maintain_expose", false, {
    type = "toggle",
    name = "Maintain Expose Armor",
    desc = "When enabled, expose armor will be recommended when there is no major armor debuff up on the boss",
    width = "full",
    set = function( _, val )
        Hekili.DB.profile.specs[ 4 ].settings.maintain_expose = val
    end
})

spec:RegisterSetting("rogue_general_footer", nil, {
    type = "description",
    name = "\n\n"
})


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    package = "Assassination (wowtbc.gg)",
    usePackSelector = true
} )


spec:RegisterPack( "Assassination (wowtbc.gg)", 20230126, [[Hekili:TAvBVTTnq4FmfiVG1i)wR3wwsa6(Yqcg8aQsr)WqLiTeTeHPi1iPIRbc4V9DhLSLKR0YA2qacK5D85EUJhFognl6XOWuQLfTA(05lMoB(YG5tF)YflIcT7lzrHL0KT0m4djTa()hmgQXWLulxjDKl2P2zxNeKLDj66EHIMIqAuv6eW9CRT0C9KjhDd(Yk2ojraOCvwfpLzMq7I5vAvwfBsu46kUWEVmADhcoF20zlb0lzjrREhappnLv7cZKef(yo34iLAUsZT7De8xRPgwQJuvI81MZCKJKXr(SMAZDeprcGmqR2WfaVFZBCKts1pI8Y9aAz2sh5psSQ1mTJG0Y9G7bAc6NjOuZsufRP2F42jwnpzRjwTjgcCSvttzVLV52mTQQC4DuQ8rBqBglJka6oOXmQwRSE4nkHQdJaJBbA093gbpHftLPXPWh4EwxTztq)Ldsv7K9XHMQzsQGlzX6ktoUr04tSyMKvWzM7M1191ciHJ3iQ069VKVBOsSoTvcEyg25UURRkTvAp1TubtAdYRKzmD8gLoETqPsdaMUwWspZNAFJvm5olL5n2u7As42GC6MowOgeTEf4CkSubtK2HHQNy6TCHOpZoU6Py8evYRRXVU9)VQ5d8JjFIjvfOnSBsfxQ4sRjiLTHNWT3oToojkrAt22F)TgghIVJ4DZ8ZUO5CPXtFM98ZqNGoBFGLxazJkUG(1BoXpnRGYLMl7gTIklxqRVymu4UBAuiubnG7DLy2r1sUmZef(5p8Xv3V63U2rCKhr5dErPsBDe403rohGHwjSN7iA2FvX1OwJrva(rRSQciYWcj5uOHXe4E43H7ooY7b0(K0uvIiHouZxaUExdopaB6piQ5LMQ10k4OWeOF1ardzYWsepbK50C5wgKKiPV3wVjVyrbtMIb0MtHLzqMVVNGPmrubAPGjo01OVgia5kh5p)KHHiXkmF5TGcAopjVR3u5(2O6isfc(xlfyfw0IBk(vJk8HG(locW9MW8yneGe7xqqt7U08orEh0W3jJAG0EWvF1WVKSQauP9hkcLfQN3xCOMpVTSl4gSy9quiCOLR0W5)HzerHEJ(5K1h1WNR8ZnR3DuiQUgf2CPm6xJSqJeAVDLWeitHJgkowByH2w46BerBXOO1xK0rUdQCTiDICnc17ELq1vkhX59VsC61FJaTCuGEbDDh5my4(4QXO5H03X1TuDgZg0yUzwYjhdnRIC8h)Npnhm(TaDQzeXF6LY6t16BZ2E69D6AooXbX)N)Fh)6Pri2ZMok4(zlT7zGjqEaMnkadPq7i36itBjyVbrTbRziGpaJF9B8a0IuBa8Gn(TVHb7gV0cW2lo2a2DqMJ88ZG443mmZVXHhO5ixoCEo(T5HP2D9YZdJgbOS4BFBEm5r9T)dhXZ7Qpw)M2tuix01JMx2EIlJND4lCB3DZ1BFAu)x0F)d]] )

spec:RegisterPack( "Combat", 20230211, [[Hekili:Dw1Y2TTnq0VfTrBQRI1d300ALfnBI9cVHoztpbeqGdLWrKa8aaAfTbF7DgsjtqgkDS7cjboZCVdMh8k2C2ZSKmHhypT42flVDX85ZMVC5NUBblXFScyjvc5EXw8GwuIF)ft5gHNmFSWiYi4otTvIUyjBQvf(h0SnJZjgAfizpTILStLLbTbcojl55DkxGtFeb(Pug4MC8zPxz0bEHY5r35gBG)vyVQqnJL0yKUdcdG)8ut5aAXMciJ9pSePv5bRsGbG08cKcAOubipFoWNh4tB5p2X9b(Y2WnASIkezqAErT1EK5Xc69KGiEYf6utE6EngJJiA5aIu5tyj1vDiCfkjKk0zPz4bcYQMc9SBLgRDWM68w1EiMlm07OqL4OYKwzuAVBMeRaqJdU764aEr5KGLMu9G7PPsUOUW)Ap9mK9k5(b56YTKn155Z6xhZYmh0xRih2x6yBR1e3FWYwU3rnv)oi1BX50)NM0OPAsGxx1SDmwpmWxh4rTrBDLV22K9)4IuI7f2Th7OaxZwfXHidnlkuAi1w72rC9XR3xhGywCVz4w7F(EPQP2B8ftvVCGVbIi2M6QSa0U0GNKTYdx9vX32GCr8GSYCAJnE(D5vfNPW0bERWAn(27iElFbSoYER4085FKLCqy1yT4oRdvzn5QcOvqQu5W9OTbURUQYy9N0G2stuLmWX7VEpGRhbEG)GVfutNOe0zqggXobAgWeFK4wzWlkEsPLf1zKwbOWs3(xHhd8FpW)3V5aIjO09JBc8d7uYDXrl0h7YAGRne5)ScFvs5l64nJorjh6s6FJAQ2ZP55wkqHWFqKMfBAruMpGt6Ok6eL(ZH20nAmPRl3awkXUcJFw4XhkPggzy5aHC0joGQ97mwwY3Xfa63tT9Zto3SxxO(T1FyK1KBu5RBwMcpogI2LMX9DANGyGwwWwYRHH)vcgq8EpfvF59ppFAFd3VCib9u8hHHFbqFTqeXK1Xv2PG6ROn0DNI(nJPCT(oQqFfecG0ZJF(xUeRVKiEmQ30S5k3E01jruc2K6QPx623byGOfbSVg79R6f)Wb6Lu(61CIK4UcMPJQusInS)7p]] )


spec:RegisterPackSelector( "assassination", "Assassination (wowtbc.gg)", "|T132292:0|t Assassination",
    "If you have spent more points in |T132292:0|t Assassination than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "combat", "Combat", "|T132090:0|t Combat",
    "If you have spent more points in |T132090:0|t Combat than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "subtlety", nil, "|T132320:0|t Subtlety",
    "If you have spent more points in |T132320:0|t Subtlety than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )