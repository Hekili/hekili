-- RogueOutlaw.lua
-- October 2022
-- Contributed to JoeMama.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

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
        duration = 6,
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
    local Expirebuff_adrenaline_rush = setfenv( function ()
        gain( talent.improved_adrenaline_rush.enabled and combo_points.max or 0, "combo_points" )
    end, state )

    spec:RegisterHook( "reset_precast", function()
        if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end
        if buff.adrenaline_rush.up then
            state:QueueAuraExpiration( "adrenaline_rush", Expirebuff_adrenaline_rush, buff.adrenaline_rush.expires )
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
                
        cp_gain = function ()
            return talent.improved_adrenaline_rush.enabled and combo_points.max or 0
        end,
                
        handler = function ()
            applyBuff( "adrenaline_rush", 20 )
            gain( action.adrenaline_rush.cp_gain, "combo_points" )

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

        talent = "feint",
        spend = function () return talent.nimble_fingers.enabled and 25 or 35 + conduit.nimble_fingers.mod end,
        spendType = "energy",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            applyBuff( "feint", 6 )
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( buff.opportunity.up and 5 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ) ) end,

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


    spec:RegisterPack( "Outlaw", 20220911, [[Hekili:TZtAZTTrY(BXvQIM0sIHhMohLOQkwYoR9BtSFroVSFsGqadjreiaxCyz9kv83(R7EgamNaKYYX7R2TQDJTjMJE6PVpMRgF1hU6Yq)c2v)6KrtMmE00rdNm55Vy83F1Lf3TLD1LB9dUXFf8xs83a)33vwe7F7Uf9Nma)2DXP(H4AKNwMfaFFDrX28F8B)2vrfRlVEyq6MVnpAtzSFruAsqM)Yc8Fh8TxD51LrXfVj5QRTbapF0SRU0VSyDA2vxEz0MZHvokmKXholpObs(T0vLSDV9DbfPxZY2Ty6ODlWLA3B392Zx7NSIL)J7E7j7wCXR3TyBg7KT(fbR3TWp8plZl2WskYV6Y4OC4pqCbBPFzCb8x)vc3Ws8VoMfE1l5BBw0w8GC1L)glVG5hxalu0syDtZZJGbciMK0Dl(yzCclZN(bwcBtelhgxYUfa(4A)ca15hWxhXQCvbC(BB)EtsbllRCBXUfP06KghMEl83kGTZpoofWeaIDtuYkCNGbZ3byFVncHYI1(fnB7nrb3G75uT9mDlasmPb(r)Si8R4FlUe(JSIR9UUC5syHpfq07w0doZ7w8KDlWFD41zabrEuiBy5wPVv4hdi6Hl9t8kwZ8w7VzdlBOyJ3T4(7BwH8BkJJ98tc9cYaS61PjSCAXgiTEzLjSLPzRydJs(y0Q0mG(kzLx(AFaRec3R2x7ISsM31m4mLSQAnhWhI05AU05IFOkZIyHEfzm)8YS6Jg9TvziOUHfZ4)U82zGmCchvRgYob7uyuaFodmi7YsJJ3T4LFy3IJ2T4N)fGCidV5twH0AIdaSWX3bFbq1z0npqN8Yky54Dl(WlROkUSgHDmFLUm58QV9Y4YKqw21L55eDGhxcaIOYiWajGE(btaHSaPEBtbI08Ha7wuqequFghPFunPs0MTzPFeWf(BaiyDZ95rUqUaJw2Q74l1SrselbPjHLrfGWOYKcI(lnmm3GcrSXTnkAJXJo9DoPzgBJFeYNH774rM3zVkbjAaSk8)xXGZ6Ys8k8NOZ1UfN)E4N5Raqjb)NmwYtHrXXXe)85iiHxKWk8oaOQVO9V1)o57goUYdpWr0Md3qZ(SUH4hRGTEB8)Kx(wgcHNy9g4Kg(L0TBtZkktIkUtsmGa)(plbzpEHz(3QIB7qerdNkB5sga6FK51oGQDn86OKieF7dysymYYSXRaKMpTefV(rw2sqEkH5HR4YCUy7uCg4obCkLjXSC43xISmVS4vW0xhrkvIHBe4d5WAfdq91WQp7iChKVMwsGI610lSCnLXCEr5CPUeoXG0)iF8EKRKy41SIBzmoELDhrZ6hEhNPXbYeKTptdb(tIZMFrbBdQicv9uMZeyaeVYpQhJeVR8Zc5iP0LcICgig6wFqJhEE)UdHSCFoTeL3YyWwLyU1gK4CfPRMFTM5foVJBfHqcOAHKAYrCn8etAmCkbPZNFb)0)AP9TMlBmIf((dblqtdiTrXp(GUpq(51XG(cVLXLzz3jPqoZpk0J9rKFYhfIHa2zOzrsIXKNQKqmcp0ig(MisgeWrLbk4QGuv0WFqQlaJ8kI2IStcG7yezebRz1zaqqiV0AwWnihns(eYca5hi7dJRSkpDdYqEHgpu(Djb4CQ0m5Jt61eSltFiFM8W5G44Fqdh3qYim(IfoeSGQbNdgx4X)7EODHCRdf7GK9AJhPTWvZpWhnGXXceeMttw36YgOQcDn0KAFFGq(SO9q3IY9car7YdPPRBCydiYv1o8A)CMNIk8XZiIhX3bPamjO2plWpH5vKMbQ4kOTGmFq77BlJZzYBmoWzYdmoA16ICV)SmCfA)U(yFH8yV2FLx6sW2nqRtU6iHjcu1CtY70G)x9jwqzbJOhbX(SkB5X)9kG1ziOrpiGTfLvKKMCYA)SnGIEq4qLD4PjX3nu60UDB8DO4LCUcaxxwB8Za2fpypbuTpq6jDp4IpFM0jZlNHuqWzhiyTyYVe7aWVDDus4WTG9GLXGUc0HdaiuvuxpSpMII0GXLNgtWqT4HkyFjObyn51xTTI6o(OE3PBSsnYkeiz8bjrmVmWchzO2WEr1H2auwWitTP5TgcJbRWjhrqZXvq7SLGQ51C5Yww2j2uWvZ7Qy(O6Y2OmAQ9BqovlNf1cfBnOZ2MhHR9DbW1JqEmoCf8g(RdlI2GSKWzKXL(ZvdgY4kj0TCOYfNLilONI6ZXACmVeHswwUnI7gWqSrRwNMxa8d5aJ6nmj9YZjCr1btDyTto)K6triAVdPBapanRglyDkQClJTnlAdCtBZJMAsqY2ATZ4FdqdyufIsHT9UgJ6rYpHV5iBoORkcTC(py(3KWnkkJ8ljVev393E3r)uzOFaTeie3iK59GG50y0rT0c5dxJ9084I4jBZDn7ALHp(IvVYNx8gSzfangHE3kanLjlWFQdGh3HbTXUULGAWDCeOvqy)oAV4pd2sKKFdDb)hGCzGiP6Chbw9hg5xWqKgxB)7AoznwEdAatil0FTFLrx)nYJbdtcxvVzE3Y3Rdk0e9C4ttTDuwwFf2IHZeilxYzCJS4gwPFcpwIYrb3u7ztEHpOSJtKHrNc9882i0PtY)ZNFe3GCYDZlA4n42NLKcdb5smeXEOOOE29iKGoU5cgFJCEJ)9AeS83LXSte4vDbTpgWTJGua4UQ440HOf5lvl25BaJTXfl7D8HZQAibZIjXn6nYYaEVqs3eyZpkJvZjqU4SlF5L1HES2GFjNO9Rai4VM3iG8ykcSlHDH4DRNx4D0)opf2wGMfSxGh4kgnvWcO7QgSUa(0IHwaAp83laUryzB1uDRh4dEhm1ZAZc)dajB4Hn4FeieaPb58Xb(B1IkHGD(YKl4SX4v)XIyaEBeUg3WyWKwMLUHM)wcLhSgbAfZq0vTJHtJtewhqblhbI1vSAuWGe)DVLIir7hZxRrdNuVC2yY4rXbJiMsitDgw46i)XDhPYEgsqiAptREc1HIkzTVwvhHsxpx4hW7tlyjbOARukaEyGKO7jo4DS5Ti7taCGSt0WOaNGIS5dRmNUG(VXWLHIP9VvJY8HlDRVkktw(MSNB7w8mH(l1iKcIx2MMSbJKJ6(z)cfV0h7kUTsY26iWG12WiVJpXQbow9E1829s0tzssZLK5K8uRykmJKdDUFa(hxK(b(To9JW0sUbvPICCYI)ZflDJHQfCx)BXOD5GxOBkTCap4G5KJQtTKIpCYHhQoS6sykLW(aG8(yCUSsoU1FQj9rlI4v3R1bYOjLbu0XD4juxgZBD5KZsJEcbOF1zQwAtGc)uvwSgn20dDelkh9dwy(8zuOaRogOCvViqIjpC9T5dXsLabQC6uIfv15YzOGOb4YdUQO8LIgk3ZQVAtPlcBQT0nPxbiBs7ggvckUkW1hxsGNFEo8)Is0zqpGC1PpbkGhO7E0yZ1hOjoRobB(GkA2gVRH5wMb2qKlNqY2rRCQdfN)njP1Z0IQUkZjlNYx6W4f6NeWS5xW)bJ)yJX)OFvirDfugXiS5(1fCmsvUsXWANcdyt0)ltKaiz7WO0CWY85qixtoPQq4ERWYmLW(8Wr(CPZAZQwcTwgDQvf4eLAZtL9kVmC0hqwAp1mpiIyHAF9WF2Aoi(fFU(8FkxSOhZtDWUf)p(8u1WTHZhfkI)aoy8kSkUnHmmZHKHx49hLyRkREfwNvLIpL1GVS)YYlAI45XrlN33zivV)ENHrDqVNOCt3R)tSP5gwbNPc60jdQMLE4qXj6WE5ZWA6rKMPQmN3DgeBH1Ujsth0czYPpWMtRDNRSwYKYNdXzNuMTZyyZF0aZS)yzQ0URbzn61rFRurKMPdZIiXwYevT11g0qswaUNXF30LVArsdChN)28Dtk5cxgvvEuErlfX9Zi7eQX0QVuIm(mZ3rvPj5YkohMElw9oZN7a91X21bvyeT4g8eZ6s5114pHES3Zrd7w8kbEG7PdfqW6dMiodjnoeRMn2oD969POh1zmEfdk26q5OqIrmcDCminhPsWA5HF0G7CGzlH9PcJCzq0GY(PuZmw7QpSVEvBlbMUSsxAz0GDLGLkNF6YCeZGySZVOtd7DPxU)(O3R2z8ArQgJuisvMUHF0ukaIH3KqgkiKq3Yi6jTzkFxPQbgXRrhcZ6kVaM5YKOIdGRPXdN1E(Q0Z1PCHfz6h0PUIgHa71CRKr1pQ(9IALPzu)tJnzNEdgRtQ4S8Xe3uUfT9ijAltyayAcRIJjo9wgwGiF4dxmC3IFVjaFI4GUuygdVY9Wq1xdnPzYrzn5o8ZdjCUR0lyIZnaBSKv5GopUuege3L6cAb55WsRLk(jeEbtD407CVmnbPUZsnwOUNywRkHLvwpRls9HEtTVCb7hrEDEjSxRrCgGdQ6MiBvoCF9uazU(CRaRtdgoZSIMuI8m3Y5)RirviIjKUMeUYEAs6TKz30wiBbKsbe5jmQPQ0CgR7TrDmvKNLTy3H0qJpzIiyCKD68yWj0pjIblfy1xvf)vY8DKo(dhHvWo(FV1QpEdKdeR(PRANgA1SndBUunjZj6OnY9(TNp(AhbTfMoxb6TVLy9YlaxSgEg0TXj81yst5GQ7hQuUMBJeCufpJ760QdKB)on9rksbQjSt5t2zOBSSsuncJSGBKSXsnCUvwXoXvgOSg5buOSi()VrkcoA1RnjiojnBdMAL40vrbC(cqmQWDbKlMQ3oAYB8)tKQ(8lYhA3bO9jArTBNGv7DAp4pAEAQj7TY5qfBJSyNNPzrYdsSoIH0M0BbX4e3ofDyOR2168GXy1NsJsyrrfWlmrl8sdsgJ0Aw9WAvhwCEY8iwR6kj1Aa2M4ozcUCpIooDxH(DuE(d6cXTN5WQ1OqOfd3nmELsoPZkLuTijhnsrUdwLSfODVmFjRARZLkkZrYSdxE)zgL)6v4zeLGe4lTJe8R7juGAj0CDCAAymsAdKnbfDMEHPJAfEL9jJ(teeukWtAd9wwIjcRbSWHPwBNSmGMLNcE1H9DYdBzugJwr9r99YJcdhFErMFSxavnWQdvx5e34MBZ83MJgQXIzbfzG)Qa7DayyAbqJf5lvtXDosm7xU0rG5UcNBqki)ylQxaWnfLzQP(JtlHMVXLXewByRTBOQJqlRncsUsw5TrjH5bGvEyLBNxacmCMfst7garYWvsyJYteiD4LWlg56m8D13cMWcc6UR(5au6Xsp)G)zjhoen2Lj6SEi(FI1cNgwWTIY7ULfhbkDjfv1ToqDcKeatsOh40x4nSSG1rSL2CjwHjXXK0RGLGSswS3k)SmGGtUYyM6kiiicLiyxI6eYaoykx2l1RpgE6xCnyVNxJ1AtErn6Z9UIWQRWkSxW6EbOCrVDB27yYS3Nys1wzebTu2iPfIhT81aExEX9kBFqholC5ht0rh4cz3RTHlSXzlBHY0zUqwc0XPTdcpBVXwUs9hOLeRDtyAHPBIsmYnVJSSpR6G74sEI9Z((FQQDEYKFPrAJnyhpSU8RwuWk6LQ9f8UEMBigzTtUW1(YCCnW4XY2O62qxviUyRgwmE4A)CpWzfpEoqBvyagmuEBk42DW9ENNC47SoMIkL)N7oDnDbl772HajHJVIkvOQUJOLYfcuydwQZnRr5Y8YQoRWId0268q3wSVhDIuyuo1p90vMI5uIYLxXmkxkBaDM(BfvHNru93MXUZlLJBXkB1mrXedAuUhISTOXKWOI2IQT6Vs7ouVgSWymHouZRJskSONNH20xvPRuiFXWr9BVVkgrIGorSsnv9UuhKsldhw5ZX)AEnNLsHHD4EijAALKix0IYIoEoNSSVC0gTub7288QTHnqXHghLCVWdS9BJ7j7TwhdK2uxLRv7K4C1GQvpIm(sJTf1t108pMrMi)2OLfE5X(yzb0wQpnJvTS3LQDEKoRLmNVj7LbNPYyiEHpciqCm0tUXOFa7CNB9ZW(Pai6)JF63(138R)8pUBXUfFaPoJ2GfqQGi(PIhiJNIicUfUvnTPFzr6gFQf5c4V7gd392)o1imt)rSmztG9L(8tBib(hpLtRl)tv4n4t9h)Pb1RYZ1wfboVEjQ(3778RI6q9cu)dMRWU32bEPUBTommZyy9(9K8sQiDPSRsxFWck3FGp1jMSo501hIMFXfE4bUgyKZF17(77pkjim)WqgZEWKjtLoEV4rzv(Uh8QiJQ)(hLv5hEuwLXtEy379NiVipo4LjJECwMXpolJoM5qKmi4P0VPRmcDSK8PglI)hgZx)oUAWtSm)jYZVt2qULphgN4dhVoz)akQfwpmyYadV3I)3923SPs(6lAeXsp6tWNP4vfGbxCe2V45SW3Lu9(sHTHB6YimrTFZ3SBH2Jof(tO381p(u0dp1I(dW9e)4BsIWO7r9VXQ0KLuNRxHliidg0JuRLV7TI)9WADrZLvIy57hn)B1lpGJnA745JhH1YOPFUNnzM91uTiiFi1aP91v4vK9pQfNzlNJPi0SVLRMDaqXWmlBXectjzHO1LrTXhSHX5ldz05PtnitGBbQJ4OSXqEqa7c1SNOdeF0pkg37H0S(8EOYQHFzSprxx85)CKjV44dsMaE)Q8cxjdlvU9EmgKL5nDBYXuPAmV(Lc70j1LMRuRNa)wRDM193ZNJJ(pblC3otXy1AO1CldgC)91q3Ca64aNXRxwpHxAYVCzvlPYrX6UWNT6lv2aof6x2x6k33r65QtCtzRmHoB(KJmKbqt)iZZpp7DNnF2i4wXEskb8wRzM8(75ENA9rd7mq2kh19v(1PYnQvp0pwqTNnx2t2tmqJNWPdvBeXE9D22F3FFRmqivU9xPjvaHWRpEpAvhakkD7C6P7cLI3rLV3Z(j50zguf77dm1baN8RsszdDdzRMi654lvANg74ea8z0r4R7JdLBKHrPejWgT1uf9Szd0ibhUT3tRZgxjRX67OLm0LP(KoXbsHkxYkkLsNqAI6pMt8zc(E35QZPhWf3Dzt05grgYlpm1x5jC1TucAGGVzhPu)zMRa9oqj)7Ap7tYFs5vEsyVu17ptJnyeSoNxbmhReMyotGzawpB84EUdX)93ReEWthpwBVait9fRb3LwFXBoD(uZ1WOiFWL5jwFbkOt(FPVknMGlxDk1)tD(6wWfVi1(2GW9(T9yx0Z5dDbxr6x8hygZZR0JiqTOuRHaVltd7zrpPq6I7xzMthpC2ajrTFDEUy6eRCWh8EMwnqa6zZn(96xngbYYYlgZPtg8faeTAG5Z75I10nJIt(KgBHomMbUXpFLFSwmpXwkXqUSSUFLv2VfZIu99BX5iS)YF4v2VtfCku10mF293VVVglNy(sSC6C8vybxct635IxFLET6MApx9q64gPW)R1RNsNS)hUS5E9TzAJSznpdeo34HOTIo1QmKtNp20B0ArbT4XK(JKI4suw)AZ9ZJ(7FIfIz13bfbB25ck3CUDAkgSR)4M0SMGjTkwTtwflBTo4YrpRTkTYAyg)TgBY07GIQ47y8aNC)91Mm3eFOb67J2ldcrKzzEvXProYd0VynWlUyi5aQTKGp4Sj6qMS)CwLzQ1b6oDqONnBMrxIaqRNM1XtnqqYpfg02UxTavVUdqM8q06lf9URxeJlRpFfTDW5xg6V7eseg6bLQsGQ(umWk8QP)FNXh1gZ(f5X3Wn(EVrsCPfwE4nueNFkiqYD)e0Ck)ppBfFMpBfM3OYH6XYlPG6LDR8wD0p2IWgHHhU9a95KZb94DVNSov0xYJ((DY7o2rgSz1tXc41ZrVcoFuVwAdqTTspxGOOuhKvn(K3vkbvnxg4TfrU)lXZOGP(6)Fn)5XYVphC)3T88CqOZpJNhcDKMYl(WXlfpDevH6ZzNeIqXE9qpOVFslMfBO0vm0VljlGFdD8gpG3gCqWs3fcsvC(TET2Q7GbCd402FfFtd0rUg1PG4LJyo4HLnlynBgbmJt62QEQnVVaeVwxyBpqpQP9ACdk7lW7PqNOdlh5OKZMo6exVVc9EqhY2P46ISseFoB5zAGzayEWV)aTRt0zl4luOTFgDlDyvF7fOJPdLyNnPX77)v4fmWWHvzuJIMAdvUnAJDIpnPW67oxk9S7aUTaS0xjcltoA8SbTP16S(toXQ96uYgCDtnYWYQMg6VdmtFNkcfU8OgxyXpAJPOsN6PZNos7iE2Kg5nFrFQa2hVLC51PBfqAkhD7wPKH1MpnankrTOixw)PXJbqv5UyvuulEK39z2T8Xd4q3D)9F2lKpFYD1Fhrg2SJ(pBIjXEtdUBlCq9DvlmTwkmdCFI7igP7V7psD2oc4QTFpwUnJQcWHst3dyCEqYNpvOJYMbUQXZsmJN9cdGG3w715cuR95TgCSPJCUVMYHQAoEJVu3p8g(pu1c8gEkP0176FTQR04ko7Qh2BF2UB08AeLwZRRJWNoQd4ZOpWncrSQIbT(q)(7Tyb1lgPdgFx7qrlDaE9bvRTY13b56Q12w4SZVDM(lR9)D7BIZUPTXB62BFy705DC0ADx3JnTx)2mey8jpX0VGbdSuxpaXMXVss1mJL(J8bOf4hT(2e(njBRurmDM5rJoeN6EtEwhNpBTCm3HAJ8amRxFli2jMWB3W0aDweE9XTV9TSHwcrBqlL6hRL3tttCi3iXwjSNpXq6uvleVV7YKh0Uu35WDTnUwU66mKQvQVr4lYF5D6AZ5IBCWC9dHdQSPU9QO6y(87VVFJHBMLstTDlU7Z0bcZgSwxpG1lTT81Xq29Y3w270rmhz0hc1swS2hRNQCN3tQ7eAmF2AFRQgWt1ibydQA6lvlFSQDufPa(s9w5qyH58MfrXll3bxwmrPT4GNi3QsBFPPX0TxVGeYZvdQJ37e5AvRPJnF7v)Fd]] )


end
