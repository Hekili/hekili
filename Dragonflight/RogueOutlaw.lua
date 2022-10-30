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


    spec:RegisterPack( "Outlaw", 20220911, [[Hekili:T31EZTTrs(plUsv0Kwsm8HPCCkrvvSKDI9Tj2xK3n7FjqiGHKiIeGlEyzDfl(z)6UNbaZtasz549QBRA3ehcGz6PN(XVU7zAF9WR)41xf6NZU(3gny0OHdgpOp8pp95xFv(9ByxF1g)GB9xa)Hy)1W)89f5R8VZlKn3Vyv(LVbFH7xL4hIJtwsrAa8slZZ3K9JF)3VikFzXn9dsw)9zrRlw5NhLehK6pph)Vd((RV6MIOv5Vn(6BmiIHVC8lhE61x5xKVmj96RUkA9fWihfgY4VollOKC2n73twuW29U3hKNCdlD3SrVe()WqT7D7E3fl9JxWY(XDV7KDZU8n7MTjLDYg)8GL7M5h(Nfz5RzX5zxF1QOm4FH8d(Qd(J)gXFyX(3SIfE9R4tBA0gCHC9v)ollN5VkhgOO5W4MKLfbV4UzDJt2n7tfRIzP(0pWIzRJyzW7fVBgWpUXpVhS2c4JJyuUohw)nnFVnoNLMwSjF3SeACswfMCh8NYHPZF1QeGtam21rXlWzcEz(maZ7DrivMV0pVEAVnk4wCohRnNjBasIj9IFYpncFk(Nwva)R08B8UPy(CyGpdy07M1bwZ7M9KDZWFT)nPGarwuiRFXgPNL7Vcy09N7h7LVK5T0F9AwAFXeVB22T1Jq2TfRw55hh6fKcC1BsIzz0G1tA8slIzZtsxW6hf)POfjPG8v8cVSL(axje2xTp25PfmVByWAkEr5y2J)ksRRPsRl(IQinIf6LNY8ZksRwA0ZwKIK6A2kg)3LNodMHt6OC0q1jyMcJc4FtpdXU0KvR2n7vFC3SJ2n7N)vqCif35JxGYAIfamWRUhEcWQtPDEqo5vL0YX7M9XxvkvCvfd7y(iDv8fLp7vRkIdzP3uKLrYbECZaiJkLidua65hSaeQcK4TjbesZ6dQBrbrGq95CM(rvIkrR3KM8jGx4VgOGL17Nh5I5ckAPlUNputgijSeKehweLdgJkIZj5VKWWmdjeXe30BrtmU0PNZfntzR9Jq9mCEhoWCp71XOqdWvH))cgSwNxGBH)eTU2n7Ipa)mFeajj4FKYIFk8wCEmPpFbss4gjmcVhiQQnA)78VxEVHZR8WfCen5Wo0KVODi(YkyJ3A)p7LTHHu4jw3boPwFjzZMK08I4O87Lmdi4V)RcW2JxyQ)DQ82wmruRPYMpNbK(NyEntOABdVjkoc53(aNeEhzB24wakZNuGMx)elDoypL48WwCrg3SDc(f4mbAkfXRyzWVphvzEv(RHpFze5uzfSJapidgRvavFdm6tocNb5TP5ePOUnDQLTPuMZnkNd1vWkgS(h5J7JCNe9VHLFhJX5RS7jzw)W75knoyMGT9jAmWFsS28ZZzRrhrORNImMGdG8v(s9yu4DHFAiNjLmxiKZaZq35dE8W17loeXY9z1ssEZxbawwXrBqMZvSUA(0kLxy9oSrgczGQbrQrhX9WtkPRGvjyD(Il5R(3inVvAzdrUWpCiCb6ZarB08Jp47dSFEZkWFH38vfPP3l5qo1pk0J9juFYhnIHe25iSijZyYFQKrmIpuBg(2iYgeOrLco4kPuv2WFqUlaqE5rBq1jbXDmYmIGXSCnamiuxAjl4wuJgfFczbG9du9HXDwLLSgviVuthk7(4a8Bk9m5JF0BiAxw(qEn5HFdYJFPgpUwKra(If2hqqvZZbWfE8)ShIlKJoumds41goqBGl)(aFeaJJbiimJ(yD0L1uvj7QVP0((qH8VIMdDeL7fbI4YdPpxhCynjYD12)g)mMNIl8HtiHhXZbRamjQ2pnWpM5LNKcU4YPPGGpO98nfRYyYtm(ItKFXvrlwMN59NfHlq876V7PYV7n(l8sMdy3aVozQVj8HGunhsERa(F9Nzbf5msEem7ZkXYJ)3lavN(Gh9Ga2g0wrCs8jl9txdo6bJdL4WtIxDFFPv7MnRUhnVKXDa4AZATFkOU4bZjWQ9brpP9bx65tKwzEzmuccw7GaRfi)sQdG(2nrXH93a4blwb(kWaoaIq1rD1R9Pe0Kg8EzjRiAOY8qjTph8aSKI6RcROEGpQ7D6GvQywHGiJpyjI5LciCKP6sm1AVsPHFd4KAVw1sRJWnFTlqUfFlmYX2CyxTWwbG3P4xqu8k7wS5Gh9LCZ5wg2r28lwPYRG6uDyR9Hn2(gpxyxyzWIKELYIgqbnDaYppA2(wgBJWv3fPOUFid3da4aBoMhq8V)bU1E6hquseuPFgCIeNDlqTsGOOHH7ZG)n(3qaXi)drS(YRv(R1ppAnAhb4WmsGFCjgtoDydWtnp65CX4UYrrUOIW8UdmuWsZScoTPxRNseEwEtPOd3VjUJCyjT8IC0mf5lrEQhkdeLHAU8GiTyErd4KQuRc)AoAT1R6xq4f1cYMX4NDx0Cq2dGaTupe)2cSONtTOs7wvEWaKTE3SkjjuZaIInMWOmkzpgM9rNWnPgibJqxfqg6bpxmJoQkjpkwtLbQvfGRKiIcaSInnVjjeSdrK70hcXot5)rn9lAXMwkYvbPOo4DfUTMXLg9s8ehdNC(s0dnV5KE4mJpTjxZD2vVmqZsErGSkpWzB5NO2ZKmKCLvNcQWY1LtqzcNmwnlnSeVDsgxXrtvcd6ymTreCFa4hviSGcMw8fQqK1wqq8bechy7BngDvQNFwg8)II1nLCaznt)diOhaEf(7AyKYKNvLQl)BbBWR9Ub(2I0nPrzYPgSz2QnltgI0658qz2T8XYgzOfJxOFm3eJUl9)dh)XMJ)j)YGtCHZr8g2IW8sohPmRLigIe4fwh9)We4lKZtdLWbwQpNcHamldoNJubbAGwqvqs9Wz(CRZAFvLfAlalPF3jl9GZnqzeWC2hiwApjjpiHyHJD9arAmBa)knKqmrzIb9yEq87M9p85jnHhkVpAue)b8LXTWY0IgYqmbus4W9pc6zzcTeqklt2MYyWh2FD(L1XECC08PDDgCZ2TodOPxNNOSt3P7tS55ggbNjL5Sr9k)kZau2Uvoq6sVhaGOZh1RkHpL5WU9C51GQDVkmVh0azQP3ZwgvApRvnKtJVeHZwLmBwXWwsCSKhglFkn7AuwTFDq)EGkJ0mXuwmj2qoHAjixfa4ThQRjwCHjPEUJ4UP8jjfM)vrLfQ0lAUi2cJ8eaGDLwBDLsPWxyMhKIcZkkohqVfJERzwTN(4yB7GkrHD1AoEvZke9Mk(NWp2h4SHDZETGpWdQoojxAHjQxe9J2YlQTu4PmTFamfGbZXRDVyQLIWaMa4)JH3hKKHsjyv14lnyphu2IzFgNe1a0jzq54uQuglfx2aZRx50wNgqlcwsdJgTFPmzkNP4ImKZGCSlUSvG9U8l3DF87vfnFLjvJ3uysvwUjaunJ9HHfLBxEFQKHz9h0rAOLJxrnB9d41gRolPw4JM5qKKzdGnLH9Nyj8JgYXOCb9mJ65mvMADbEf8Q69Gu6CBOVlOwryJ6oo0u55TZXZYbwuuFmRSucNYIJ2WeW9GOjl1pwLChdlmZh)4L93n7VNXkXfgEpb0yUa0cVI5ynRQOMKuPse6hFp(4(1zBEV45gKnEur4K(DrOejXbXzPQqsOg2UzJhq5ldPxaydx6MhtPjj1E2HhpGyL6pnSOeRSUb0h6ovlY87NSDv9QSxApUC)bvmrcqYHhqNcjZDABLyDIk4CZci(tYLsLdp()ksu0FmrUvsULGMjt0syRPPqgMJs968eixkRe2q9qkQsCI8xPrJKAck6m8KrFK7hIaJZZURWj0Dj0zwiWh(HxtEikXOJIVF8iqsye(pVZAGC9e6xKUO(QRCM6BfBMbWkvCxozhnjL3qEKLZkL1CXzVYy0ykxuSDZEw55DblzwV2rGWhJr1N(c9GnfzeRnrWbL6mUllAlm3UTIVrkDaYmjTdbLDf6A4tChYJhyH3ibKsnNTLqvh5Q2SwtVaAlUiJ06ERuAA0oEuK934K01(RqxjlIc46fG1trmbOwmvEB6Jx7)NOu9fxM13Euo7tkHSIkWkwMMtSJwuKAMCld8tb3JfmCMqEKFjX4iFc4Cy0USMeUd45W4sw9X8GzuvlowWYeCwtzBsJwdg6um4FQj3iJTjlsHri9OuynaacW0Bd2JIUfiamV3PWSGs1KIu1X0WAoZg5U(aUI4HwoTF83A5SV1RngNGrigM7y(BsI5wHu2NAmXcAPLDnJFmeg16Xqq9eimyGIvg8iOKJGBz(sqx5SCEO6JLaz4kGoZe3xncpJKeKiFPzKOF9GBcuR8gvfRvOeni2eK3AfdgpOr6voml6FJKGYPNGMqV5fyTTQjl81up4eSuqMfnLP)AVq(1MhLYSviUr)G8BHzyplp1FLxaDuBuFvDxrCOm3L6VjdHLXwXcYtHqqbBaba6ZCqglYx6a706BIf0YLhbSCu43gKa2P2GEbaEtErQA184YsiynUntUdF7IgWujwcnm2ij5Q(J3ffhMfay6WJfvwoyWWzHfnrjawIHTKWAxLir6iuGth4An8IQDbtAbjD3hTOa06XCp)G)vbNoeNAAt2z1R4)zwdAA4PzrC2PAyWrIs3sr5HcdKobrcqjj0dISl8wwAWYi2CBX9QOK44JKn6gMawntlyR8w4NMccCq4WK)FIGCLxdKHscSZrFcPGgShODenNzlNFoFzVNxX1AYErf7Z9SI0QRChSx06ErOCtVTdYDibY9jMsTLyhOHYMiTW8OLNgWpc18yW2h2HZJ3ZJj7OfEHCm024f20SLrOmEIlMLGDCwZKWZ2BULRQ5bEjXtSc8zHjRJInk3UJcNpPCH7ytEK91((VQQcvYuFP2AJnAhxSUIIgyhX3YYhQNQs(vkIdeJq7KjcKVidhdmfRS1Qbj0u8NeEn(u1pFy)L(zEqOjE8YA2OXam)M8ZaO7G)27zE0HpZ6Ck6aV9C3vGPnAzFNoKijE810P)P8Oh2Wjas(8fPSzEv5Xw0s4Y2ow)UrSVhhZ3QZVuU2XFIdFwdgLlNnGpt)nqKtj5wsu)Mu29EjCElaB)wZA)skOrzEiZ2IhtIJYpZWnWp5bg1CIMDDiA4wbBtwWYrRrxr8vivcOABEFrmrlwcWiX0RaYQ3kFG4MsNYYYfM6RvTr5kgnlhJlzi7gbC20(APqGYA8xa2aEnhJsGP9(6YPJHiWtqbDUJ3n7nryE7(dylpMFlnOJprCwbge6V8(J(PIq)aAi4Q3LN65pab3GLn6kn5PUvr)XVOMEYxcizHko0pXOlN1Q6ra0icjPrK0u(yb)t9f4yXPmk4ceZgIQfkbMP3S(CPcSe(PRS6CISEnlmcC5HmnE6lFF9kR(uSMwehtP95n(LjV)xORWKbUahhnu90V46IqvYc1VKvvXeAz8vul6prWSCbXXnZIF2o0xHhlj5OWBQUQvaq6GBfczycKVJvwYd6q)(8J4vBHsLSsL9Wu)sf4uTKXpqwuN6JOO8JiQJN9aJNrf1G)8kgS8ZvcurWx1bd9yq3oQ8cDAM5wQBX0I8MAU5HlYGgBslwkJrpavvdly5MNOKA)ggzntVekCZzx9QR2vExOl9ALjxFS6ZOowu7sdKhtxj85WSq6UvFNOGGzjW0IvXyEoVUGm6tx7J4i5VSL4bTq0E4VlfzOZ7oK1f8bpdwppPghVKdGjBCL)41QjkVupMQ8JY1KuOoFv8L1h2UJfxk57IWXGFlcMNMSM((nelxKxn5fTf0Dt2JSRIQUvzP7KQrgdGHw4yA8XXAq)rvdNnLmE1nXRORsIfB6ul3u9r47fUYFsloQK9(A1DeAD9cXft6dy(VcUVQ6C4nBL2NyLvOtFxK9zGoq1j61OBYzDH5evi5)gV)UOzA)70KmF4w366UWzgvnJ8FTN5B2(gkUPp01fjxY2wl3u5kmmAqMTaWH2YB8S4q7UxHrcqwAUIGtYR0VPXmYo0fyYWG9HerrzPFueyvzntL0XfdDnqvc4oirGhNEEZ3yWPd)H(dhpe7ai35NIWza9W)4N(9F7T)2p)J7MTB2hX5iAnU)jcH9PIgMXtXdsepPCLxIt)I8K1(0vMlG3ho6V7D)nch64FeLsJHzNE8tRR2Z)8PCJmY)ujdgEu3HFUx1O8CTrrSVuneL)3773xwOKQbO6hmhHDVRf(s11W6W4mdHX7VdyPiDe6mErBGWakFFbFQtoz1rKRAru)lU4dpWXanX863)32Fwsqy2HXmM8GftglT8o9rzuEXdEuKz1)WJYO8YhLrz4Oh2(E3rYdYJdFz0GhNHz4JZWOZzoeldcDk9D6Y8MnuY(uDs8(NgFV(EC5lpYY3ps(7BvnKNVPdtt8HZxhTFefLbPdJMm4W7T5)DV7TRlTVEATjwQjqbpgVdTjZJWtl239Da(k1gnf(tJEb8ZvnCkSztnRBpCCXh(waztecUeGiTijEoDB1lxV0SdV0J01jF37e)39R83mv2rHLNF00Vx)OjESXDgE6Wb4TMWm97NdyLToMQx3IhYTTW(4kswR9hQv(BlRJXi1SVhmE7eGYfAYYumI4usxjwRdJ6vS0ghNpmuqoNn2qmb2fOGoPdjcH1dMfkFkyKwFYpAfo39PV6lR5Kvr)YCFsUo)lVfKjp4ytitqVFt6QvY0sz24pgR9Z06716X05fDAv3b7SrvxciPWgGFRXGF2U9jnfZiEfHA9apvogAxJ2E92UTI6McuhN4m6yzDe5guUBLvoKklfRZc)Rv7oz94sOFD7UvU3J0pcrIDkBH8D(0rhzydG(8Jmx)8aopF6KbWUI9ZofW3A8atTDlnS2BuyNd2w5SUVXDKk3Sw9kszH1E(u5t89jgSXt6Ajw)oDDgz92TnQaHs527mtQecXxF8AuvhalkzZuQDDHwXB5o21X(k5Sjgsf7BtL6aOt(wj5SHNFwlNqZooEsP3PHowbGEgTe(22qOCZmmopZcUrtxFZo2WanqOHBRhAD(WsBnw7DwYuxQABCItKcxUekkLt0P0hQ3aN4FjeFDRJoxEahC3NMZwNicSU8RP2zNWr3s68adFtosjDEMJa17NK)DTw9K8Ju6Stc8sLL4TgdgrRt51F(yL0IZvcmR685dh2XD1M3UvjD0NnCO2CbuMArHXzPXIkF20XMJHrPGXH5jwlYdTY)lTWVMKl3DkDtRBTasD0ZqkyCVBt1tQJZAjXDK(vVgUMRxP80xzk1AHDBdAyhl(jfwxCxi3Zg2FspjtTFBQiBRCLdEH3Xe1arONp143RkmRGzzPOSNnQ3xbs0kaZN3XLQPBffN6j1yHomLbo4NVX1d1CfBP2CCBzTxiZ9BWSyvF)gCod7V8ABUFRkyvO6Pz6KTB33cEEIzXopBkwOtCimLFNkkWzNgdtTJRUvXWARW)7vbkBv9)WTn3PRnOnYWAEgyCUocrB1M0QnKZMo0mA0ktbneXKEDifBIY(xR3FE0lXOfHz1snkuZUqi5MXXPPayxVnQvpMaKwfu7eQyz06qihDS2uwugdZ8VvJjt)ACwMFhJwP22TvqMRZpup95rRhKrczw(UY80iN5b6xSM4fxkKCc1w3rR35J0Pm545SAZuRx34maHo2WmJHebKwhn0XJnyqYnDlAA3R7HDN2tqM8ROD5y17JpICCzTrz10cNVzO3HRKem0tkvPbv9pXGRWVKF))z(rfy2VkT5l3879MjXTwyPfFPyo)mWGK7R5y9Q8)0GS(cBqwM7OYP6XspBsDZUrDlHNvxD(frAJW0d3CI(CQ5Gr8U3FSUu0xZL((TYBp3rgQzvFIfYRJJgwW0bDAOxeOnv61cenL6qSQoM82kjOkCzq3wK5(VgnSjt)1)FA9ZJL7ey843T0iWi25xqJOsNPP0BPoEUOjvvMQpAp3wFnaPI9QLsPpFsdMfmu6og62MLfiUHw6Mu9OQsP2RdiJjQ)uNg7UoaCTECj5VHDpjDwPXPsq0JQMcXtzdVQ5nIeRVKoY0ZSfRfWMZuB8l2tRJArUgwZY(k05MALDyzjhfF(4bN4Qto15bTiTkF1M0KijC2kMupZSS8G70rn74ZzZ(r41A)qwlTyv7Yt0Y0HNQZhvhI9)o0RKmIkvM1O4o2WVATlxN8ttbRUUlysh7rzBllkDvsJYOJgoPxtUMoV7OtSckNQOGRDQbgWNQBDqTWz660BNiUg1K)k(rBkfLoopB64bAlXZhvBM5RAtjAFcjYvOLgUB0C85oKrjqZMnHOAhKwCsl7B0OTdvEuwSAbQHOTBFPAyn8awRT3jHo)u5LLC)dQLK9A27GoFKPODDR0XwgE6664T04PBPN7vClP9C)JOrQh6GeUAJ(bpbndkZzHs79b4488EpDSWJKnmRQPOs8fp7udIG3aDQkVNwJ6XA(UgpW58AA1PSn8y8KQoVJribLnBhJGFu6Vo6pT8(VZDt2w3YP5V2DlTPIrP1MC0z4Jh0c9z0XzmY6RQBaToEZ2TwGjD6aDY4fntfn0RzQwOAnWg9zq(OYABkC2JzCwrlRDAMMNeN9TJ6aKBUrLyxoVLLwJZ6EmPD62KB)HN8etW)96z5O6acBg)kzvZm94pYlGgOFeITj9Bk2w6Iy8eZLgTioZ9K8SwwF2AUj8yKnsT)KoDTWyhzsVTtt90vr4h5T9TdPy4Lq0WvKQMJ1tSt9DVqULLyvWE6idRtLnRK9Dwg9GMLQEusBtJRHR6Odsh)PVte5bI(7V0)26QEDXbhmvFr4qkBS7yikxMpF72U141mpDmv4wC)3vw9eWgSEuDa0lnn8vPf29W3ub50zmhzC1cQSSy9VlUotzpVJ0foOg1S1)U3snhMQH7BJQQ79nwEyzlPruv3R0VDgceMtRheLyQCNVyXhknfh8hYrvA7j1Tah7hbqI55Qv4G77K4AvtWbJ)l89Xv)vI)lhnX7d)Jp4n45doL6pFbyZuCaDfBV()9]] )


end
