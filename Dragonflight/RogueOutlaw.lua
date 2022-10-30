-- RogueOutlaw.lua
-- October 2022
-- Contributed to JoeMama.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] ambidexterity
-- [-] count_the_odds
-- [-] sleight_of_hand
-- [-] triple_threat


if UnitClassBase( "player" ) == "ROGUE" then
    local spec = Hekili:NewSpecialization( 260 )

    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy, {
        blade_rush = {
            aura = "blade_rush",

            last = function ()
                local app = state.buff.blade_rush.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 5,
        },

        --vendetta_regen = {            -- as it causes error in Warning tab, turned it off this way
            --aura = "vendetta_regen",

            --last = function ()
                --local app = state.buff.vendetta_regen.applied
                --local t = state.query_time

                --return app + floor( t - app )
            --end,

            --interval = 1,
            --value = 20,
        --},
    },
    nil, -- No replacement model.
    {    -- Meta function replacements.
        base_time_to_max = function( t )
            if buff.adrenaline_rush.up then
                if t.current > t.max - 50 then return 0 end
                return state:TimeToResource( t, t.max - 50 )
            end
        end,
        base_deficit = function( t )
            if buff.adrenaline_rush.up then
                return max( 0, ( t.max - 50 ) - t.current )
            end
        end,
    }
 )
-- Talents
spec:RegisterTalents( {
    ace_up_your_sleeve     = { 90670, 381828, 1 }, --
    acrobatic_strikes      = { 90752, 196924, 1 }, --
    adrenaline_rush        = { 90659, 13750 , 1 }, --
    alacrity               = { 90751, 193539, 2 }, --
    ambidexterity          = { 90660, 381822, 1 }, --
    atrophic_poison        = { 90763, 381637, 1 }, --
    audacity               = { 90641, 381845, 1 }, --
    --between_the_eyes       = { 79544, 315341, 1 }, -- this is baseline, we got improved BtE talent instead--
    blade_flurry           = { 90674, 13877 , 1 }, --
    blade_rush             = { 90644, 271877, 1 }, --
    blind                  = { 90684, 2094,   1 }, --
    blinding_powder        = { 90643, 256165, 1 }, --
    cheat_death            = { 90747, 31230 , 1 }, --
    cloak_of_shadows       = { 90697, 31224 , 1 }, --
    cold_blood             = { 90748, 382245, 1 }, --
    combat_potency         = { 90646, 61329,  1 }, --
    combat_stamina         = { 90648, 381877, 1 }, --
    count_the_odds         = { 90655, 381982, 2 }, --
    dancing_steel          = { 90669, 272026, 1 }, --
    deadened_nerves        = { 90743, 231719, 1 }, --
    deadly_precision       = { 90760, 381542, 2 }, --
    deeper_stratagem       = { 90750, 193531, 1 }, --
    deft_maneuvers         = { 90672, 381878, 1 }, --  
    devious_stratagem      = { 90679, 394321, 1 }, --
    dirty_tricks           = { 90645, 108216, 1 }, --
    dispatcher             = { 90653, 381990, 2 }, --
    dreadblades            = { 90664, 343142, 1 }, --
    echoing_reprimand      = { 90639, 385616, 1 }, --
    elusiveness            = { 90743, 79008 , 1 }, --
    evasion                = { 90764, 5277  , 1 }, --
    fan_the_hammer         = { 90666, 381846, 2 }, --
    fatal_flourish         = { 90662, 35551 , 1 }, --
    feint                  = { 90742, 1966  , 1 }, --
    find_weakness          = { 90690, 91023 , 2 }, --
    fleet_footed           = { 90762, 378813, 1 }, --
    float_like_a_butterfly = { 90650, 354897, 1 }, --
    ghostly_strike         = { 90677, 196937, 1 }, --
    gouge                  = { 90741, 1776  , 1 }, --
    grappling_hook         = { 90682, 195457, 1 }, --
    greenskins_wickers     = { 90665, 386823, 1 }, --
    heavy_hitter           = { 90642, 381885, 1 }, --
    hidden_opportunity     = { 90675, 383281, 1 }, --
    hit_and_run            = { 90673, 196922, 1 }, --
    improved_ambush        = { 90692, 381620, 1 }, --
    improved_adrenaline_rush  = { 90654, 395422, 1 }, --
    improved_between_the_eyes = { 90671, 235484, 1 }, --
    improved_main_gauche   = { 90668, 382746, 2 }, --
    improved_sap           = { 90696, 379005, 1 }, --
    improved_sprint        = { 90746, 231691, 1 }, --
    improved_wound_poison  = { 90637, 319066, 1 }, --
    iron_stomach           = { 90744, 193546, 1 }, --
    keep_it_rolling        = { 90652, 381989, 1 }, --
    killing_spree          = { 90664, 51690 , 1 }, --
    leeching_poison        = { 90758, 280716, 1 }, --
    lethality              = { 90749, 382238, 2 }, --
    loaded_dice            = { 90656, 256170, 1 }, --
    --long_arm_of_the_outlaw = { 79532, 381878, 1 }, -- renamed to deft maneuvers--
    marked_for_death       = { 90750, 137619, 1 }, --
    master_poisoner        = { 90636, 378436, 1 }, --
    nightstalker           = { 90693, 14062 , 2 }, -- 
    nimble_fingers         = { 90745, 378427, 1 }, --
    numbing_poison         = { 90763, 5761  , 1 }, --
    opportunity            = { 90683, 279876, 1 }, --
    precise_cuts           = { 90667, 381985, 1 }, --
    prey_on_the_weak       = { 90755, 131511, 1 }, --
    quick_draw             = { 90663, 196938, 1 }, --
    recuperator            = { 90640, 378996, 1 }, --
    resounding_clarity     = { 90638, 381622, 1 }, --
    restless_blades        = { 90658, 79096 , 1 }, --
    --restless_crew_nyi      = { 79522, 382794, 1 }, -- deleted? replaced with improved adrenaline? --
    retractable_hook       = { 90681, 256188, 1 }, --
    riposte                = { 90661, 344363, 1 }, --
    roll_the_bones         = { 90657, 315508, 1 }, --
    rushed_setup           = { 90754, 378803, 1 }, --
    ruthlessness           = { 90680, 14161 , 1 }, --
    sap                    = { 90685, 6770  , 1 }, --
    seal_fate              = { 90757, 14190 , 2 }, -- 
    sepsis                 = { 90677, 385408, 1 }, --
    shadow_dance           = { 90689, 185313, 1 }, --
    shadowrunner           = { 90687, 378807, 1 }, --
    shadowstep             = { 90695, 36554 , 1 }, --
    shiv                   = { 90740, 5938  , 1 }, --
    sleight_of_hand        = { 90651, 381839, 1 }, --
    slicerdicer            = { 90649, 381988, 1 }, --
    soothing_darkness      = { 90691, 393970, 1 }, --
    thiefs_versatility     = { 90753, 381619, 2 }, --
    subterfuge             = { 90688, 108208, 1 }, --
    take_em_by_surprise    = { 90676, 382742, 2 }, --
    thistle_tea            = { 90756, 381623, 1 }, --
    tight_spender          = { 90694, 381621, 1 }, --
    tricks_of_the_trade    = { 90686, 57934 , 1 }, --
    triple_threat          = { 90678, 381894, 2 }, --
    vigor                  = { 90759, 14983 , 1 }, --
    virulent_poisons       = { 90761, 381543, 1 }, --
    weaponmaster           = { 90647, 200733, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    boarding_party       = 853 , -- 209752
    control_is_king      = 138 , -- 354406
    dagger_in_the_dark   = 5549, -- 198675
    death_from_above     = 3619, -- 269513
    dismantle            = 145 , -- 207777
    drink_up_me_hearties = 139 , -- 354425
    enduring_brawler     = 5412, -- 354843
    maneuverability      = 129 , -- 197000
    smoke_bomb           = 3483, -- 212182
    take_your_cut        = 135 , -- 198265
    thick_as_thieves     = 1208, -- 221622
    turn_the_tables      = 3421, -- 198020
    veil_of_midnight     = 5516, -- 198952
} )

    local rtb_buff_list = {
        "broadside", "buried_treasure", "grand_melee", "ruthless_precision", "skull_and_crossbones", "true_bearing", "rtb_buff_1", "rtb_buff_2"
    }

-- Auras
spec:RegisterAuras( {
    adrenaline_rush = {
        id = 13750,
        duration = 20,
        max_stack = 1,
    },
    amplifying_poison = {
        id = 381664,
    },
    atrophic_poison = {
        id = 381637,
    },
    alacrity = {
        id = 193538,
        duration = 15,
        max_stack = 5,
    },
    audacity = {
        id = 386270,
        duration = 10,
        max_stack = 1,
    },
    between_the_eyes = {
        id = 315341,
        duration = function() return 3 * effective_combo_points end,
        max_stack = 1,
    },
    blade_flurry = {
        id = 13877,
        duration = function () return talent.dancing_steel.enabled and 13 or 10 end,
        max_stack = 1,
    },
    blade_rush = {
        id = 271896,
        duration = 5,
        max_stack = 1,
    },
    blind = {
        id = 2094,
        duration = 60,
        max_stack = 1,
    },
    cheap_shot = {
        id = 1833,
        duration = 4,
        max_stack = 1,
    },
    cloak_of_shadows = {
        id = 31224,
        duration = 5,
        max_stack = 1,
    },
    combat_potency = {
        id = 61329,
    },
    cold_blood = {
        id = 382245,
    },
    crimson_vial = {
        id = 185311,
        duration = 4,
        max_stack = 1,
    },
    crippling_poison = {
        id = 3408,
        duration = 3600,
        max_stack = 1,
    },
    crippling_poison_dot = {
        id = 3409,
        duration = 12,
        max_stack = 1,
    },
    deadly_poison = {
        id = 2823,
    },
    death_from_above = {
        id = 269513,
    },
    dreadblades = {
        id = 343142,
        duration = 10,
        max_stack = 1,
    },    
    evasion = {
        id = 5277,
        duration = 10.001,
        max_stack = 1,
    },
    feint = {
        id = 1966,
        duration = 5,
        max_stack = 1,
    }, 
    find_weakness = {
        id = 316220,
        duration = 10,
        max_stack = 1,
    },
    indiscriminate_carnage = {
        id = 381802,
    },
    ghostly_strike = {
        id = 196937,
        duration = 10,
        max_stack = 1,
    },
    gouge = {
        id = 1776,
        duration = 4,
        max_stack = 1,
    },
    instant_poison = {
        id = 315584,
        duration = 3600,
        max_stack = 1,
    },
    kidney_shot = {
        id = 408,
        duration = function() return ( 1 + effective_combo_points ) end,
        max_stack = 1,
    },
    keep_it_rolling = {
        id = 381989,
    },
    killing_spree = {
        id = 51690,
        duration = 2,
        max_stack = 1,
    },
    loaded_dice = {
        id = 256171,
        duration = 45,
        max_stack = 1,
    },
    mastery_main_gauche = {
        id = 76806,
    },
    numbing_poison = {
        id = 5761,
        duration = 3600,
        max_stack = 1,
    },
    marked_for_death = {
        id = 137619,
        duration = 60,
        max_stack = 1,
    },
    roll_the_bones = {
        id = 315508,
    },
    safe_fall = {
        id = 1860,
    },
    subterfuge = {
        id = 115192,
        duration = 3,
        max_stack = 1,
    },
    opportunity = {
        id = 195627,
        duration = 12,
        max_stack = 6,
    },
    pistol_shot = {
        id = 185763,
        duration = 6,
        max_stack = 1,
    },
    prey_on_the_weak = {
        id = 255909,
        duration = 6,
        max_stack = 1,
    },
    restless_blades = {
        id = 79096,
    },
    riposte = {
        id = 199754,
        duration = 10,
        max_stack = 1,
    },
    -- Replaced this with "alias" for any of the other applied buffs.
    -- roll_the_bones = { id = 193316, },
    ruthlessness = {
        id = 14161,
    },
    shadow_dance = {
        id = 185313,
        duration = 6,
        max_stack = 1,
    },
    shadowstep = {
        id = 36554,
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1,
    },
    shadow_blades = {
        id = 121471,
        duration = 20,
        max_stack = 1,
    },
    sharpened_sabers = {
        id = 252285,
        duration = 15,
        max_stack = 2,
    },
    shroud_of_concealment = {
        id = 114018,
        duration = 15,
        max_stack = 1,
    },
    slice_and_dice = {
        id = 315496,
        duration = function () return 6 * ( 1 + effective_combo_points ) end,
        max_stack = 1,
    },
    sprint = {
        id = 2983,
        duration = 8,
        max_stack = 1,
    },
    stealth = {
        id = 1784,
        duration = 3600,
    },
    vanish = {
        id = 11327,
        duration = 3,
        max_stack = 1,
    },
    wound_poison = {
        id = 8679,
        duration = 3600,
        max_stack = 1
    },
    -- Real RtB buffs.
    broadside = {
        id = 193356,
        duration = 30,
    },
    buried_treasure = {
        id = 199600,
        duration = 30,
    },
    grand_melee = {
        id = 193358,
        duration = 30,
    },
    skull_and_crossbones = {
        id = 199603,
        duration = 30,
    },
    take_em_by_surprise = {
        id = 382742,
        duration = 10,
    },
    thistle_tea = {
        id = 381623,
        duration = 6,
        max_stack = 1,
    },
    true_bearing = {
        id = 193359,
        duration = 30,
    },
    ruthless_precision = {
        id = 193357,
        duration = 30,
    },


    -- Fake buffs for forecasting.
    rtb_buff_1 = {
        duration = 30,
    },

    rtb_buff_2 = {
        duration = 30,
    },

    roll_the_bones = {
        alias = rtb_buff_list,
        aliasMode = "longest", -- use duration info from the buff with the longest remaining time.
        aliasType = "buff",
        duration = 30,
    },


    lethal_poison = {
        alias = { "instant_poison", "wound_poison" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600
    },
    nonlethal_poison = {
        alias = { "crippling_poison", "numbing_poison" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600
    },
    -- Legendaries (Shadowlands)
    concealed_blunderbuss = {
        id = 340587,
        duration = 8,
        max_stack = 1
    },

    deathly_shadows = {
        id = 341202,
        duration = 15,
        max_stack = 1,
    },
            
    greenskins_wickers = {
        id = 340573,
        duration = 15,
        max_stack = 1
    },

    master_assassins_mark = {
        id = 340094,
        duration = 4,
        max_stack = 1,
        copy = "master_assassin_any"
    },
    -- T28
    tornado_trigger = {
        id = 364235,
        duration = 3600,
        max_stack = 1
    },
    tornado_trigger_loading = {
        id = 364234,
        duration = 3600,
        max_stack = 6
    },
} )


    spec:RegisterStateExpr( "rtb_buffs", function ()
        return buff.roll_the_bones.count
    end )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        sepsis  = { "sepsis_buff" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
    }


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )

            elseif k == "sepsis" then
                return buff.sepsis_buff.up
            elseif k == "sepsis_remains" then
                return buff.sepsis_buff.remains

            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
            end

            return false
        end
    } ) )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364555, "tier28_4pc", 363592 )


    -- Legendary from Legion, shows up in APL still.
    spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
    spec:RegisterAura( "master_assassins_initiative", {
        id = 235027,
        duration = 3600
    } )

    spec:RegisterStateExpr( "mantle_duration", function ()
        return legendary.mark_of_the_master_assassin.enabled and 4 or 0
    end )

    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not legendary.mark_of_the_master_assassin.enabled then
            return 0
        end

        if stealthed.mantle then
            return cooldown.global_cooldown.remains + 4
        elseif buff.master_assassins_mark.up then
            return buff.master_assassins_mark.remains
        end

        return 0
    end )

    spec:RegisterStateExpr( "cp_gain", function ()
        return ( this_action and class.abilities[ this_action ].cp_gain or 0 )
    end )

    spec:RegisterStateExpr( "effective_combo_points", function ()
        local c = combo_points.current or 0
        if not covenant.kyrian then return c end
        if c < 2 or c > 5 then return c end
        if buff[ "echoing_reprimand_" .. c ].up then return 7 end
        return c
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.all and ( not a or a.startsCombat ) then
            if buff.stealth.up then
                setCooldown( "stealth", 2 )
            end

            if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
                applyBuff( "master_assassins_mark" )
            end

            removeBuff( "stealth" )
            removeBuff( "shadowmeld" )
            removeBuff( "vanish" )
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "combo_points" then
            if amt >= 5 then gain( 1, "combo_points" ) end

            local cdr = amt * ( buff.true_bearing.up and 2 or 1 )

            reduceCooldown( "adrenaline_rush", cdr )
            reduceCooldown( "between_the_eyes", cdr )
            reduceCooldown( "blade_flurry", cdr )
            reduceCooldown( "grappling_hook", cdr )
            reduceCooldown( "roll_the_bones", cdr )
            reduceCooldown( "sprint", cdr )
            reduceCooldown( "blade_rush", cdr )
            reduceCooldown( "killing_spree", cdr )
            reduceCooldown( "vanish", cdr )
            reduceCooldown( "marked_for_death", cdr )
            reduceCooldown( "dreadblades", cdr )
            reduceCooldown( "ghostly_strike", cdr )
            reduceCooldown( "sepsis", cdr )
            reduceCooldown( "keep_it_rolling", cdr )

            if legendary.obedience.enabled and buff.flagellation_buff.up then
                reduceCooldown( "flagellation", amt )
            end
        end
    end )


    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )

        if legendary.toxic_onslaught.enabled then
            applyBuff( "shadow_blades", 10 )
            applyDebuff( "target", "vendetta", 10 )
        end
    end, state )

    spec:RegisterHook( "reset_precast", function()
        if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end

        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    spec:RegisterHook( "runHandler", function ()
        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    spec:RegisterCycle( function ()
        if this_action == "marked_for_death" then
            if cycle_enemies == 1 or active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
            if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
            if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
        end
    end )


-- Abilities
spec:RegisterAbilities( {
    adrenaline_rush = {
        id = 13750,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "adrenaline_rush",
        startsCombat = false,
        texture = 136206,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "adrenaline_rush", 20 )

            energy.regen = energy.regen * 1.6
            energy.max = energy.max + 50

            forecastResources( "energy" )

            if talent.loaded_dice.enabled then
                applyBuff( "loaded_dice", 45 )
            elseif azerite.brigands_blitz.enabled then
                applyBuff( "brigands_blitz" )
            end
        end,
    },


    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        usable = function () return stealthed.all or buff.audacity.up or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,

        cp_gain = function ()
            return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 3 or 2 ) )
        end,

        handler = function ()
            gain( action.ambush.cp_gain, "combo_points" )
            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
        end,
        },

    amplifying_poison = {
        id = 381664,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        talent = "amplifying_poison",
        startsCombat = false,
        texture = 134207,

        handler = function ()
        end,
    },


    atrophic_poison = {
        id = 381637,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        talent = "atrophic_poison",
        startsCombat = false,
        texture = 132300,

        handler = function ()
        end,
    },


    between_the_eyes = {
        id = 315341,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        startsCombat = false,
        texture = 135610,

        usable = function() return combo_points.current > 0 end,

        handler = function ()
            if talent.alacrity.enabled and effective_combo_points > 4 then
                addStack( "alacrity", 15, 1 )
            end

            applyDebuff( "target", "between_the_eyes", 3 * effective_combo_points )

            if azerite.deadshot.enabled then
                applyBuff( "deadshot" )
            end

            if legendary.greenskins_wickers.enabled or talent.greenskins_wickers.enabled and effective_combo_points >= 5 then
                applyBuff( "greenskins_wickers" )
            end

            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )
        end,
    },

    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 15,
        spendType = "energy",

        talent = "blade_flurry",
        startsCombat = false,
        texture = 132350,

        usable = function () return buff.blade_flurry.remains < gcd.execute end,
        handler = function ()
            applyBuff( "blade_flurry" )        
        end,
    },


    blade_rush = {
        id = 271877,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "blade_rush",
        startsCombat = true,
        texture = 1016243,

        handler = function ()
            applyBuff( "blade_rush", 5 )
        end,
    },


    blind = {
        id = 2094,
        cast = 0,
        cooldown = function () return talent.blinding_powder.enabled and 90 or 120 end,
        gcd = "spell",

        talent = "blind",
        startsCombat = true,
        texture = 136175,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "blind", 60 )
        end,
    },


    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( talent.dirty_tricks.enabled and 0 or 40 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 132092,

        cycle = function ()
            if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
        end,

        usable = function ()
            if target.is_boss then return false, "cheap_shot assumed unusable in boss fights" end
            return stealthed.all or buff.subterfuge.up, "not stealthed"
        end,

        nodebuff = "cheap_shot",

        cp_gain = function () return buff.shadow_blades.up and 2 or 1 end,

        handler = function ()
            applyDebuff( "target", "cheap_shot", 4 )

            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

            if talent.prey_on_the_weak.enabled then
                applyDebuff( "target", "prey_on_the_weak", 6 )
            end

            if pvptalent.control_is_king.enabled then
                applyBuff( "slice_and_dice", 15 )
            end

            gain( action.cheap_shot.cp_gain, "combo_points" )
        end,
    },

    cloak_of_shadows = {
        id = 31224,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "cloak_of_shadows",
        startsCombat = false,
        texture = 136177,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "cloak_of_shadows", 5 )
        end,
    },


    cold_blood = {
        id = 382245,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "cold_blood",
        startsCombat = false,
        texture = 135988,

        handler = function ()
            applyBuff( "cold_blood", 45 )
        end,
    },


    crimson_tempest = {
        id = 121411,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "energy",

        talent = "crimson_tempest",
        startsCombat = false,
        texture = 464079,

        handler = function ()
        end,
    },


    crimson_vial = {
        id = 185311,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function () return talent.nimble_fingers.enabled and 10 or 20 + conduit.nimble_fingers.mod end,
        spendType = "energy",

        startsCombat = false,
        texture = 1373904,

        handler = function ()
            applyBuff( "crimson_vial", 4 )
        end,
    },


    deadly_poison = {
        id = 2823,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        talent = "deadly_poison",
        startsCombat = false,
        texture = 132290,

        handler = function ()
        end,
    },


    death_from_above = {
        id = 269513,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 2,

        spend = 25,
        spendType = "energy",

        pvptalent = "death_from_above",
        startsCombat = false,
        texture = 1043573,

        handler = function ()
        end,
    },


    deathmark = {
        id = 360194,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "deathmark",
        startsCombat = false,
        texture = 4667421,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dismantle = {
        id = 207777,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        pvptalent = "dismantle",
        startsCombat = false,
        texture = 236272,

        handler = function ()
        end,
    },


    dispatch = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "energy",

        startsCombat = false,
        texture = 236286,

        usable = function() return combo_points.current > 0 end,
        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 15, 1 )
            end

            removeBuff( "storm_of_steel" )

            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )
        end,
        },

    distract = {
        id = 1725,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function () return 30 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        startsCombat = false,
        texture = 132289,

        handler = function ()
        end,
    },


    dreadblades = {
        id = 343142,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 50,
        spendType = "energy",

        talent = "dreadblades",
        startsCombat = true,
        texture = 1301078,

        toggle = "cooldowns",

        cp_gain = function () return combo_points.max end,

        handler = function ()
            applyDebuff( "player", "dreadblades" )
            gain( action.dreadblades.cp_gain, "combo_points" )
        end,
    },

    echoing_reprimand = {
        id = function() return talent.echoing_reprimand.enabled and 385616 or 323547 end,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 10,
        spendType = "energy",

        talent = function()
            if covenant.kyrian then return end
            return "echoing_reprimand"
        end,
        startsCombat = true,
        texture = 3565450,
        toggle = "cooldowns",

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + 2 ) end,

        handler = function ()
            -- Can't predict the Animacharge, unless you have the legendary.
            if legendary.resounding_clarity.enabled or talent.resounding_clarity.enabled then
                applyBuff( "echoing_reprimand_2", nil, 2 )
                applyBuff( "echoing_reprimand_3", nil, 3 )
                applyBuff( "echoing_reprimand_4", nil, 4 )
                applyBuff( "echoing_reprimand_5", nil, 5 )
            end
            gain( action.echoing_reprimand.cp_gain, "combo_points" )
        copy = { 385616, 323547 }
        end,

        --disabled = function ()
            --return covenant.kyrian and not IsSpellKnownOrOverridesKnown( 323547 ), "you have not finished your kyrian covenant intro"
        --end,

        auras = {
            echoing_reprimand_2 = {
                id = 323558,
                duration = 45,
                max_stack = 6,
            },
            echoing_reprimand_3 = {
                id = 323559,
                duration = 45,
                max_stack = 6,
            },
            echoing_reprimand_4 = {
                id = 323560,
                duration = 45,
                max_stack = 6,
                copy = 354835,
            },
            echoing_reprimand_5 = {
                id = 354838,
                duration = 45,
                max_stack = 6,
            },
            echoing_reprimand = {
                alias = { "echoing_reprimand_2", "echoing_reprimand_3", "echoing_reprimand_4", "echoing_reprimand_5" },
                aliasMode = "first",
                aliasType = "buff",
                meta = {
                    stack = function ()
                        if combo_points.current > 1 and combo_points.current < 6 and buff[ "echoing_reprimand_" .. combo_points.current ].up then return combo_points.current end

                        if buff.echoing_reprimand_2.up then return 2 end
                        if buff.echoing_reprimand_3.up then return 3 end
                        if buff.echoing_reprimand_4.up then return 4 end
                        if buff.echoing_reprimand_5.up then return 5 end

                        return 0
                    end
                }
            }
        }
    },

    evasion = {
        id = 5277,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "evasion",
        startsCombat = false,
        texture = 136205,

        toggle = "defensives",

        handler = function ()
            applyBuff( "evasion", 10 )
        end,
    },


    exsanguinate = {
        id = 200806,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        talent = "exsanguinate",
        startsCombat = false,
        texture = 538040,

        handler = function ()
        end,
    },


    feint = {
        id = 1966,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = function () return talent.nimble_fingers.enabled and 25 or 35 + conduit.nimble_fingers.mod end,
        spendType = "energy",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            applyBuff( "feint", 5 )
        end,
    },
            
    ghostly_strike = {
        id = 196937,
        cast = 0,
        cooldown = 35,
        gcd = "spell",

        spend = 30,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = true,
        texture = 132094,

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) ) end,

        handler = function ()
            applyDebuff( "target", "ghostly_strike", 10 )
            gain( action.ghostly_strike.cp_gain, "combo_points" )
       end,
    },


    gouge = {
        id = 1776,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = function () return talent.dirty_tricks.enabled and 0 or 25 end,
        spendType = "energy",

        talent = "gouge",
        startsCombat = false,
        texture = 132155,

        cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

        handler = function ()
            gain( action.gouge.cp_gain, "combo_points" )
            applyDebuff( "target", "gouge", 4 )
        end,
    },


    grappling_hook = {
        id = 195457,
        cast = 0,
        cooldown = function () return ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( talent.retractable_hook.enabled and 45 or 60 ) end,
        gcd = "off",

        talent = "grappling_hook",
        startsCombat = false,
        texture = 1373906,

        handler = function ()
        end,
    },


    indiscriminate_carnage = {
        id = 381802,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "indiscriminate_carnage",
        startsCombat = false,
        texture = 4667422,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    instant_poison = {
        id = 315584,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        essential = true,

        startsCombat = false,
        texture = 132273,

        readyTime = function () return buff.lethal_poison.remains - 120 end,

        handler = function ()
            applyBuff( "instant_poison" )
        end,
    },


    keep_it_rolling = {
        id = 381989,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "keep_it_rolling",
        startsCombat = false,
        texture = 4667423,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    kick = {
        id = 1766,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 132219,
        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
        end,
    },


    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = function () return talent.rushed_setup.enabled and 20 or 25 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 132298,

        usable = function () 
            if target.is_boss then return false, "kidney_shot assumed unusable in boss fights" end
            return combo_points.current > 0 end,
        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 15, 1 )
            end
            applyDebuff( "target", "kidney_shot", 1 + combo_points.current )
            if pvptalent.control_is_king.enabled then
                gain( 10 * combo_points.current, "energy" )
            end
                spend( combo_points.current, "combo_points" )
        end,
    },


    killing_spree = {
        id = 51690,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "killing_spree",
        startsCombat = false,
        texture = 236277,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "killing_spree", 2 )
            setCooldown( "global_cooldown", 2 )
        end,
    },


    kingsbane = {
        id = 385627,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 35,
        spendType = "energy",

        talent = "kingsbane",
        startsCombat = false,
        texture = 1259291,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    marked_for_death = {
        id = 137619,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "marked_for_death",
        startsCombat = false,
        texture = 236364,

        toggle = "cooldowns",

        usable = function ()
            return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
        end,

        cp_gain = function () return 5 end,

        handler = function ()
            gain( action.marked_for_death.cp_gain, "combo_points" )
        end,
    },


    numbing_poison = {
        id = 5761,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        talent = "numbing_poison",
        startsCombat = false,
        texture = 136066,

        readyTime = function () return buff.nonlethal_poison.remains - 120 end,

        handler = function ()
            applyBuff( "numbing_poison" )
        end,
    },


    ph_pocopoc_zone_ability_skill = {
        id = 363942,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 4239318,

        handler = function ()
        end,
    },


    pick_lock = {
        id = 1804,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        startsCombat = true,
        texture = 136058,

        handler = function ()
        end,
    },


    pick_pocket = {
        id = 921,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",

        startsCombat = true,
        texture = 133644,

        handler = function ()
        end,
    },


    pistol_shot = {
        id = 185763,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return 40 - ( buff.opportunity.up and 20 or 0 ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 1373908,

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( buff.opportunity.up and 3 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ) ) end,

        handler = function ()
            gain( action.pistol_shot.cp_gain, "combo_points" )

            removeBuff( "deadshot" )
            removeBuff( "opportunity" )
            removeBuff( "concealed_blunderbuss" ) -- Generating 2 extra combo points is purely a guess.
            removeBuff( "greenskins_wickers" )

            if set_bonus.tier28_4pc == 1 then
                if buff.tornado_trigger.up then
                    removeBuff( "tornado_trigger" )
                else
                    if buff.tornado_trigger_loading.stack > 4 then
                        applyBuff( "tornado_trigger" )
                            removeBuff( "tornado_trigger_loading" )
                    else
                        addStack( "tornado_trigger_loading", nil, 1 )
                    end
                end
            end
            removeBuff( "tornado_trigger" )
        end,
    },

    roll_the_bones = {
        id = 315508,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        talent = "roll_the_bones",
        startsCombat = false,
        texture = 1373910,

        handler = function ()
            for _, name in pairs( rtb_buff_list ) do
                removeBuff( name )
            end

            if azerite.snake_eyes.enabled then
                applyBuff( "snake_eyes", 12, 5 )
            end

            applyBuff( "rtb_buff_1" )

            if buff.loaded_dice.up then
                applyBuff( "rtb_buff_2"  )
                removeBuff( "loaded_dice" )
            end

            if pvptalent.take_your_cut.enabled then
                applyBuff( "take_your_cut" )
            end
        end,
        },

    sap = {
        id = 6770,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( talent.dirty_tricks.enabled and 0 or 35 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        talent = "sap",
        startsCombat = false,
        texture = 132310,

        handler = function ()
            applyDebuff( "target", "sap", 60 )
        end,
    },


    sepsis = {
        id = 385408,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        talent = "sepsis",
        startsCombat = false,
        texture = 3636848,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    serrated_bone_spike = {
        id = 385424,
        cast = 0,
        charges = 3,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        spend = 15,
        spendType = "energy",

        talent = "serrated_bone_spike",
        startsCombat = false,
        texture = 3578230,

        handler = function ()
        end,
    },


    shadow_dance = {
        id = 185313,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "shadow_dance",
        startsCombat = false,
        texture = 236279,

        toggle = "cooldowns",

        nobuff = "shadow_dance",

        usable = function () return not stealthed.all, "not used in stealth" end,
        handler = function ()
            applyBuff( "shadow_dance" )
            if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
            if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows", 3 ) end
            if azerite.the_first_dance.enabled then
                gain( 2, "combo_points" )
                applyBuff( "the_first_dance" )
            end
        end,
    },

    shadowstep = {
        id = 36554,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        talent = "shadowstep",
        startsCombat = false,
        texture = 132303,

        handler = function ()
        end,
    },


    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = function () return legendary.tiny_toxic_blade.enabled and 0 or 20 end,
        spendType = "energy",

        talent = "shiv",
        startsCombat = true,
        texture = 135428,

        cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

        handler = function ()
            gain( action.shiv.cp_gain, "combo_point" )
        end,
    },

    shroud_of_concealment = {
        id = 114018,
        cast = 0,
        cooldown = 360,
        gcd = "spell",

        startsCombat = false,
        texture = 635350,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sinister_strike = {
        id = 193315,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 45,
        spendType = "energy",

        startsCombat = false,
        texture = 136189,

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) ) end,

        -- 20220604 Outlaw priority spreads bleeds from the trinket.
        cycle = function ()
            if buff.acquired_axe_driver.up and debuff.vicious_wound.up then return "vicious_wound" end
        end,

        handler = function () -- Some azerite power stuff which is irrelevant but generates errors in Warning tab of the addon
            --removeStack( "snake_eyes" )
            gain( action.sinister_strike.cp_gain, "combo_points" )

            --if buff.shallow_insight.up then buff.shallow_insight.expires = query_time + 10 end
            --if buff.moderate_insight.up then buff.moderate_insight.expires = query_time + 10 end
            -- Deep Insight does not refresh, and I don't see a way to track why/when we'd advance from Shallow > Moderate > Deep.
        end,
    },

    slice_and_dice = {
        id = 315496,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        startsCombat = false,
        texture = 132306,

        usable = function() return combo_points.current > 0 end,

        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 15, 1 )
            end
            applyBuff( "slice_and_dice", 6 + 6 * combo_points.current )
            spend( combo_points.current, "combo_points" )
        end,
    },

    smoke_bomb = {
        id = 212182,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        pvptalent = "smoke_bomb",
        startsCombat = false,
        texture = 458733,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sprint = {
        id = 2983,
        cast = 0,
        cooldown = function () return talent.improved_sprint.enabled and 60 or 120 end,
        gcd = "off",

        startsCombat = false,
        texture = 132307,

        toggle = "cooldowns",

        handler = function ()
           applyBuff( "sprint", 8 )
        end,
    },


    stealth = {
        id = 1784,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        usable = function ()
            if time > 0 then return false, "cannot stealth in combat"
            elseif buff.stealth.up then return false, "already in stealth"
            elseif buff.vanish.up then return false, "already vanished" end
            return true
        end,

        handler = function ()
            applyBuff( "stealth" )

            if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
            if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
        end,
    },

    thistle_tea = {
        id = 381623,
        cast = 0,
        charges = 3,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "thistle_tea",
        startsCombat = false,
        texture = 132819,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tricks_of_the_trade = {
        id = 57934,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "tricks_of_the_trade",
        startsCombat = false,
        texture = 236283,

        handler = function ()
            applyBuff( "tricks_of_the_trade" )
        end,
    },


    vanish = {
        id = 1856,
        cast = 0,
        charges = 1,
        cooldown = 120,
        recharge = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132331,

        disabled = function ()
            return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
        end,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "vanish", 3 )
            applyBuff( "stealth" )

            if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
            if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end

            if legendary.invigorating_shadowdust.enabled then
                for name, cd in pairs( cooldown ) do
                    if cd.remains > 0 then reduceCooldown( name, 20 ) end
                end
            end
        end,
    },

    wound_poison = {
        id = 8679,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 134197,

        handler = function ()
            applyBuff( "wound_poison" )
        end,
    },
} )

    -- Override this for rechecking.
    spec:RegisterAbility( "shadowmeld", {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function () return boss and group end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "phantom_fire",

        package = "Outlaw",
    } )

    spec:RegisterSetting( "mfd_points", 3, {
        name = "|T236340:0|t Marked for Death Combo Points",
        desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
        type = "range",
        min = 0,
        max = 5,
        step = 1,
        width = "full"
    } )

    spec:RegisterSetting( "dirty_gouge", false, {
        name = "Use |T132155:0|t Gouge with Dirty Tricks",
        desc = "If checked, the addon will recommend |T132155:0|t Gouge when Dirty Tricks is talented and you do not have " ..
            "enough energy to Sinister Strike.  |cFFFFD100This may be problematic for positioning|r, as you'd need to be in front of your " ..
            "target.\n\nThis setting is unchecked by default.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "allow_shadowmeld", nil, {
        name = "Allow |T132089:0|t Shadowmeld",
        desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
            "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled = not val
        end,
    } )


    spec:RegisterPack( "Outlaw", 20220911, [[Hekili:T31EZTTrs(plUsv0Kwsm8HOCskrvvSKDs8Tj2xK3n7FjqiGHIiceGlEyzDLk(z)6UNbaZtasz549QBRA3KycGz6PN(XVU7zAF14R(Wvxg6xWU63MmAYKXJMoA4OtoE8KJV6YI73WU6Yn(b36Fd8FK4Vg(NVRSi2)oVq2s)Y4IlEd(c3hN6hIduEAzwa8sRkk2K)dF73EtuXQYRhgKU(BZJwxg7xeLMeK5VSa)ZbF7vxEDzuCXVKC11MuXSzNCmqf(LfRsZU6YlJwFomYrHHm(RZYdQiNTl(90BkzBF77cksVMLTDXKVh()WqT9TBF75R8tUHL)dBF7rBxCXB2Uytg7On(fbR2UWp8plZlwZskYV6Y4OC4FHme(Qd(p)nIbXs8VoMfE1R4tBw0gCHC1L)olVG5hxadu0syCtZZJGxC7I(jPBx8XY4ewMp9dSe26iwo8EjBxa8JR9lgaRTa(4igLRkG1FBZ3VKuWYYk3uSDrknoPXHP3b)xfW05hhNcCcGXUok5gCMGxMpdW8ExesLfR8lAM2BJcUfNZPAZz6gGKysV4h9ZIWNI)xXLW)kR4AVRlxUeg4tbg92f9G182fpB7c8xhEDgiqKhfYgwUr6zf(XaJE4s)eVIvmVv(RxZYgkM4TlE4HMri)2Y4yp)KqVGmGREDAclNgSbsJxwzcBzA2nSHrjFm6M0mq(k5gV8v(axje2xTp2fzLmVRzWAk5MQXCa)vKwxZLwx8fvzwel0RiJ5NxMvV0ONDtgsQRzXm(VlpDgmdN0r1OHQtWmfgfW)Mb0oGhxbejXmwwACSHWi(JBx8QpSDXbBx8t)kiKKHYdj3GsGILfmDX3dpb2aYi5bq65vvu4HBx8HxvjRCznB8q(iDzY5vp7vXLjHSSRlZZrbOJ3Bbiufi1BtkiKMpeu3IcIaH6Z4m9dQfvIwVjl9JaVWFnmxRA2ppWfZfu0YU5E(qnBKKWsqAsyzubymQmPGK)sddZnKqetCBVfnXiVMEox0mJT2pc1ZW5D8iT9mo17HKqeNHOSZ96euGc4TW))ggWhwwIBK)i9vBxC(7HFMp6Gug8pYyjphElUuaPRFosU42jmcVdi46TB)78Vh3HM9zTdXxwbB8w7)jV8nmKkoY6oWrn6lPB2KMvuMevCVKzab)9Fvc2E8cZ8VtL32HjIgnv2YLmG0)iZRDcvEByzusulBdVHEmWZaoj89Y2ZXTauYpTen9(rw2sWwlX5HT)YCUj9u8lqQa0xktIz5WVVevCEvXRHpFve5Wjg2rGhKdJvmSIUgg9zhGZaUnDILTPmMZnQDCH9JI50VOGTgDEGUlkZzckdxVCs4quO6g)SqoXNUui8XaJe35dEPaXISiWTsKpkGW9(m8AwXDmgFdJDpPm4hEpxB0XUe40ygUEF5(iw6E1kezh3Yg6Kd4(EjvKyyTawip)c(A8nXaaNyo6e5vijgVu6HKVbft1MpT2saSgh3ktGS2HCHVBF4c0kfeTrZp(GVpW(51XG)cVLXLzz3l5qoZpk0J9ruFYhnIHl)ZqyrsMXK)ujJyeP3yg(2iYodOrLbo4QOuPTe5HXl)(KaTDI)G8AaialI2G6tck)qC)icMWQfiShHktRyb3IQ7OCAilamUG6pmUpR801Og5fAkr4SIFtLdkF8JEdrrip(714XvSwadHh))2dH)jV9lqLXch6JoBXhlwUs41gpYXah4JayKhzPbiiK8BowhD5oqvvSQHMQbsta)H0COJOCNiqexEi956GdBOeUR2Hx7NZ8uCHpEgj8iEoyrbqSxpT(zb(jmVI0mWnwbnfe8bTNVPmoNjpX4lot(fJJUzvrU3FwgEdIFx)Dpr(DV2)gV0La2nWRtU6BcFiivZHK3jG)x)jwqzbJe5at7SkS84F(gq1zi41oiGTbvVtstoALF2AWzoycQchEAs89dLwTB2eFpArih(twG)3WTDPnpRzWw7NbQnEaHb7h(G8zZkZlNHckWAheyTa5xsQhuPUokjC4ga5xzmyshd4agFvh11V2htrRFW7LNgtuxT5HkYAj4nzff1xnwr9aFu370bR0qCgWcdbHiFW2eZltcFOe)v9fSYrMAZZReJNTeCbVIB)TMWJbW5u8jikDRd7eBo4Kh2g)etL08vWvAFhKl1kuXTiYkZVq7SdlIwJACaTYiHMPvOXczCVaMEWBiUJ5B49LJ36gWpqs(TWR4DhOsXYYTcJRTxBGsSqwEtP4O2TjUNma(oErUR6YIvishpKjhLJY4IWTQTBOXy0mhqWNqNu3YyBeylopdndYzSakRnhYZnWV)EUVn6hqqHeYWFQMkLWmsddFNJ)n(xt4ojVHrSHTBNGh(SI4PY25s0SPx9VG4eAeWndwp)UOLGShGyALES6DfHWaNQlvgGQDfbij9UoonnuZsGIXIWOCkRng2VrVPTQgOaxQomtjXpfyqLBKeaKEG(MVmedEczMCqDMEAFtsO3fIiLPPaccMsKJAEu0cYSsJOgcqtUau42A2qA1C)ZCmCYj(qpg72ZEHZu30LAh3FwZYavQ8IazvEuU2s0GY6qbVw1kWjCj6fCyFCCfe50CUkIMsdcTFQclFPAie3haoefYBOGzRo1umWH(WjOkW23AmKRmp)8C4)fLOBPBps)L(hqWdaGh831WgQjNSoNv(3cwcx7Dn8TLzBYIYLZXx7mBBwMmeP1tvIYSB5JLnYqlgVq)eUjg3U0)pC8Ngo(h9RIYOfCopEwa3gP2xvBNulJc120DUWmOBBXOEbF6Qs)j6xofEH1r)pmHpB5u9q5gHL5Z5BqiQvzyG79hDEJ07EhKFvC1CcfelTKTJQ0A2DwyArizqn4U9AGmLzgyLB(RK(eeuuUqJ6qEG6Bx8p855MHhUUpAIf)b8LrMCvUpdziwcktB4SqaUQOubqQQmQPmg8H9xxErtWhhgTCEFNr38WdoJOzqVNPiB2R)ZSbAagbNzL50jdQ(k9qwWpuos6kFraqQZMmWUM0EyYsaJtp0W6iLSKAKUt)ul5GOdz3pNvZoSumYgJL8MyHUOHxBQB82dwwgPk(BjDxMMensUJI)hhYcsia3XyDTHfxymCG74GBlXqsXRFzuvfh9IwkITWiGFeVSAExRhaHjZ3Zv22U41cTnEmrjPfsM9fv3G(rBjXtI)1xk)dFMPPqkquR4hDeHGy07mnSd0hhBB5u9mSBcGJjg3kTLlouhiH9j8rABbVhSrIr2XRiVyBqkCdGzd)Fms1G0CuKbRvgNgSKVf54uQM(AXLnWu5vntn5ZB3rP7YrE)DXawDocQ9Fz8Mc)xWwr1oDaOqL4dJkkjS6(mjNG6pON0ildYxnz5Juu2KyxABlxiVdiN96YCCPGkgNFrtQoTOCAMJpswka2qgpCM(5fyjEchWYb6J5QKY9qEs0gMaLceAwLUwC6DmSOiF4dxmC7I)EoRcot49K33Lcp58kgJvfQoLVPzsfhZp5E8XdBl1LYvd0m(RtvLiAQoSyJUrakJo0h6IqQLt2OOLJPTkBrOnULCaAp5RthrdP(tdlRqeQBy5XsX9AQITnj3DtcTUOp2lP1G2eYmeRWd4cx06UiupM26qPG6ISHgMqweLAluEcqJXfX5HvBkYG7b7vfbjWi7FWCkSmUdBRmlNic45PObQJs9X8eamSugSFuUaSCCW)xrIs4Jz6TwBScDmz2wcenrheFspCclaDmqPOcIXjr3MyBl5mwofpwtSL96frJPCPI2U4fvNceSqsd62vlFmM0CMe0JzuKEPU2tvTIRWF02ij7JOK(4JM8boygk0eEgEfizUlLoMgb(Wp8AAbwfXcQx8by91Fc(pVZAGNdegwjJW6IavZexNrha)oll0VtChsPcqEpv7Kmz3GsdSgUx9PJSSv2aWrlNRvWuN4gs)(LogR(2TciP9KQOf3TMj3QqLvaVyb)KjUf5xsmoYhJmhgTTLpgtR1L5KnMFrInPDaVil0jPzR9JrWa3efWfWbB8ILoAZIQmp9XR9)tu888lY51JWDWo73UKvFCp6nQAMllyvkoRzSnzrRb1tfd(NyUBKZ2KhPSri9Omyna(hXuBdMhIUfiamN3zWSGs1KIu9zTWA(YM4U2aUIeHwoDFg264aSnOlgNGrigM7y(Bst4gnv2NApvqQPKDnJFwcM05zjq9yemAKIvg8OIuGO2y(sqi5SCEy6tLa54kqlZu5xpcVGKeKiFPzKOF3b2iIrmnnmgLObXMGIoRHW0rTsVYHyr)BKeuoce0e6TSeJoUHSWxt90pWYazwuVv)1EP8RTmkJzRiCt(o53cZUEErMFSxaDSyuFvDxrC8r3L5VjhHLXIzbfzqeNGnGaa9BbiJf5h3m6D(MyXS09iioySO(n8LbPGvYnObpGZuuMHbHvxzSwEhTntcPg3QohbJDHNP8JtHU5pX6okjmpaGjIhEP8cWCH0k1YZcSxXst4oGbEyZkSXjksCocs5KrUO9xsKUULiXjuYpaTDS0Zp4FvYNlXbFwID26lPXpRFf)pXArzCcDUaNQBPO6yMbsNGibOKe6bbIgElllyveBPLa6uTOgMcMeZkzXE34NLbstqmNbCncfLjRdosq6Q(IdcgSbsIRlrpczG(RhOBeTu(KI4(vmtiOZx274AEwBgu4mp9Ch80sR7eHYTn3nO9XeO9Nzk8wbUHgkBs2c7NwEAa)WqFM40vovpS(VoSJo4fYb5BJxytbxgcZ0zUywc2XPTtcVOIBPhaUWCWkCMWvyy66OerDURTdy9PYPr0Az2NvTMDS)oX(YE3xq1r9zQQW1uChfDBr5sWSaxj3IRPXdx5N7bWN9418Rvvum3MJKWxWhe9K3Eb)6hXX7rGQYfPcOmhjvmXTS1CG3tDh83oVeM85VeizNJDhQwx0YUoDirsl(ROt(t15hS1t)tlvRQwaw6aiPSvCP7BM1Enb1NDPcTJ(eh(Sgmk34mfWY3KXU3lLZhbi63Aw1psHlk3dzSYkQaEEi0R0cRPaTO6G)AHFwBuKcmYMdx1thfooaUZDWmWyUTVUerSCgCg3((IyeVzfaJeZgeiRER8HHBUYjVu91Q3OCfJMLJWLmKDJaoBFFTFDex8B4ON8TNrEZLJLQm0pO6E10uc)QlpdGSKKksy5QNYcbnR(cC0Tdmfjv2p)zG7J3CYOuGMVVPa9yal8CdqhL5TlEteM7R)qm68Kybke5LyiX)87o4hf0E1zKO6Gu)EiulSMvxIcNfTDEP4BQ2pWO6zEX1fjQItQFjLQdhZY4Ri6nCMcpBdr9cnlZuf2CopbwdF4QpJiaHfgbOgqMhpvGVRHOAovOzLjjuMxEJFvg2)zArHml3vU4rYh61C8)KFeapo4wE05gpJkAb)51Cr5NRGYFhzE8trI(k(qjjkfEv9n3IOdHWhMC27yv1PGouThFaVewuAAvQjhMwvQc0GUCrBhRPhpF1rLFOdAn36DhMwKzxfMhSidASnlkszm6ry2WWMrH5PjXimmlPpZd)DJaYS8I61tHBY5YxD52QRaDLVVC5cm1CESXQExze7q6MGVeMfsVQ(7ev8mpfMwmB9ll4f(KrF6AFeDj)LX1Blh5KNKfS1kv6gSJf8tZ2H8xIkV15b7O6CIHXZqehMvyCSgnCs9WztmMx)s82QQK6U2otWTvbIX7L0GX1BKx8KOIkLFQumkxvtHnGltUO506DO46rFxeog8J2)YS0103VHKneShAVO1m5(4nt03DbZmQwg5nAhtCR99nCVDSRRvTKrIoU3U1at0WJAb1YUy(N8DkdmWQhs0a)5IRH17XefgCFDX3W7QlTRZQkaNUmb7taDGwrOxJUdSn1Dtu3K)BCvJEk8VJ2Y1bgAs0xIrcq2nUKGtYl8TPPjYQY5yA0GHpvukr6hfbwvvPpjfbXq3auLaUdlu8O0Z7GgJoz83nC80XNC8vxENFgcCaqI)h)4V)B)YV9t)aEqy(aohrRr2Oi2YNl66fphp3q8C1vDzl9llsx7t37TaEZ0y423(3iKFt)bK5NaZo94N3uTN)5Z5AIY)uLCb8O(J)0G6r5yTrriovpev)5D97Rkus9au)dMJW232bFP(kyTFCMXW493bukKOkD82OnqyaLV0Fp3jNS(ORvViA(fx8Hh5yGAoV(D)TDNLeeMVFmJzpAXKPslVtEsgLx(Ohfzw939KmkF)tYOmEYJBFV)e5b5PHVmz0tZWm(Pzy05m7JLbHoL(oDvEZglzFQjBG)tJVxFpU6LNy57Ni)9DQgYZ30(Pj(45Rt2nIIYG0(rtgC4D28)23(lRRSVEsJjwQtobpgV)SPlJWtl238naSb1Uff(ttEj8Z1DnkSJrTO)aCCXh(laaJie6l45)M0KL0voVA9sZo8spr3j8TVv8Nhw7VzUSJclp)G5FR(j17qJ7l88XJWB(Gzk2pdqYBDmvVYepMBmH9XvKSw7puR83wwhtrQzxpu82jaLlZKLPycXPKUoSwhg1RxPnooFyOqWoDQHycSlqHqshsecRhmluMkWWr(OFumo3dPV6ZRdJvt)YCFsUU4ZVpIjp4yNetqVFvAcvY0sv24peRC18M706H05fDEDl(60j1xKhPODGFR1y2E4HN1weT418PZd8u1yODfAhm4HhQPU5a1XjoJ2owprckLB5yvdPYsX6SW)A1wm2aUe6x22qL79i9JqKyNYwKQNnFYbg2aOp)aZ1ppMVZMpBeSRy)Stb8TwpWup8anS272xNb2w5SUVYTok3Sw9kszH1E2C5tC(rgSXJ6Bjff967mHap8qRkqOuU9oIKkHq81NUox1EWIs3mN65wOv8oUvK9SVsoDMHuXU2)P2d6KVvsoB45N1YjeTNJNu5DASJvaONrlHVUnUj3mdJZZSGB02vWSNnmqJeA42AewNnUYwJ1gGLm1LP2WM4ePWLlHIs5eDk9H6DHj(xcXx35OZLhWb39P5SZjIaRl)AQTNjC0TKfsWW3SduYcP5iqnWj5FxRFnj)iL2ZKaVuvbKBWGr06CE9NpujT4CLaZYlF24X9Cxw5hEqjz5NoES2CbuMArHXzP1IkF68PMJHrPGXH5zwlYdTY)lTuRMKl3DkDBP7Sas90tSlyCVFB1tQNZAjXDK(fVAPMRxP0pxBk1A1L7cAypl(jfwxCxn5thpC2ajtTFDQ1zNCL9EH3Ze1arONn343RlCSGzzPOXNozWxas0kaZJ75s10TIIt9KgSq7NYah8Zx5QBAUITudoUTSURY5UnywSQVBdoNH9xEba3TvfSku90mF2dpSRLJ9iZsXE6CSmS4qyk)oxu(1ETgMApxDCIXnwH)3R6U1P6)(BBUxFBqBKH18cW4CteI2kPQvBiNoFSz0O1McAjIj9YNk2eL9V2S)8KxIrlcZQLAuOMDUqYnNJttbWUEBqRzmbiTkO2juXYO1Hqo6zTXQOmgM5FRbtM(ToTk)ogTrThEOgYCt(HgOppA9FmsiZY3vLNg5mpq)I1eV4sHKtO26mAdoBIoLjhpNvBM5Q9RgNbi0ZgMzmKiG06PHoEQbdsUHBrt7oDpS71DcYKFfT7YREV4rKJlRnjR2w48nd9UBLKGHEsPQmOQ)jgCf(L87)pZpQbZ(fPzA5MFVZmjU1clnwmfZ5NcgKCFnhBwL)NMC1NztUYChvovpw6xtQB2TQBj8S6Q9XisBeME42t0NtnhmI3D(J1LI(sU03TvE35oYqnR(tSqE9C0FfMpQxl9IaTPsVwGOPuhIvnXK3vjbvHld62Im3)LOxvz6V()tRFEOCxaJh)ULMagXo)m67u6mnL(k1HlfT6QQu9r7526RcivStTzj95tAWSGHs3Xq)USSaXn0rlPIla(vShnPZbmombIwl1CimiBWmnVNIyzH0buEQTqKaUtUA7LXE2yuRn14gw2xG(puNSdll5OKZMo6ixnaQEpQfjvSs1wGHu6cS1IN4y2PujzPgqdmtoYJU3d1U)kNTuiHZMDdqS0IvT5mrlthoyoBstKX)7qJ5XiyszwJIxud3HnEkDYpnfS67Uoh9ShCSTKF0xj7htoy8SbT5r5S(toYkwAQqaU2PgzG6PPJ)0bNPVtNuIWruZzR4hTPuu5V705thPTepBsJzMVOnoNDjsgxreQBHqhEG7i9KW6A27IA8RzX3QSlnJUvu1jqXQfOwcsU7LQH1W9yT2Dda6StKxwYT9NoYrRzl)5SjMI2nDahBjMPVRtLsRhkLbUxXDKTYDpqePwFds4Q9Nh8GVmQkvdkDLhGJZtx98Pcps2GAQMzjXx8ItmicEFVPUQCA9xhRPPA6iNZRPvNQUNJXtQByogi5R6rogXSO0wC0FA11wN7MSRMCt7FT7EytnJsR31OZWNoQd6ZO10yKSwv3aATJMhEWcmPtgPtgVSDQOLMlt9cvRPYOpdYNWvBtHZw(IZcrzThY0(K4S3G0exB7Tpe7Y5DS0ADw3HjTx)2C7p(ONzc(FWalNWgqyZ4xjRAMz1(jEb0c9JqSnPFtX2kxetNzU0OfXPUNKx0X6ZwptHhARrg5N1RVfg7et6TBAAGUkc)KQTRDCedVeIgyIurySEqBAUYeYDAeRc2ZNyyDQQhJSRZYKh1Su3Ar6AACnC1N4p6ul9nIipq0F)L(xpunRlo4G56lchsztDhdr1Y84hEOFdEnZd1snUf3)TV1abSbRNWga9sBdFD2CDp8TvhnDgZbg3iGAllw)RpRtv2Z7jDpbAqnB9VUSut9OA4(2OQMUrJLhw1jzefJ9s9lvHaH58MbrjMk3P5v8HstXE)HCuL2EstJNX(j3JyEU6Qn4(ojUw3pBW4)cFxs9FD0)9tM59()X79gD8OtOMNxa2dehr3m2R(F)d]] )


end
