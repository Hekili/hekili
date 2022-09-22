-- DeathKnightBlood.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

local spec = Hekili:NewSpecialization( 250 )

spec:RegisterResource( Enum.PowerType.Runes, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.runes

            if val == 6 then return -1 end
            return r.expiry[ val + 1 ] - time
        end,

        stop = function( x )
            return x == 6
        end,

        value = 1
    },
}, setmetatable( {
    expiry = { 0, 0, 0, 0, 0, 0 },
    cooldown = 10,
    regen = 0,
    max = 6,
    forecast = {},
    fcount = 0,
    times = {},
    values = {},
    resource = "runes",

    reset = function()
        local t = state.runes

        for i = 1, 6 do
            local start, duration, ready = GetRuneCooldown( i )

            start = start or 0
            duration = duration or ( 10 * state.haste )

            t.expiry[ i ] = ready and 0 or start + duration
            t.cooldown = duration
        end

        table.sort( t.expiry )

        t.actual = nil
    end,

    gain = function( amount )
        local t = state.runes

        for i = 1, amount do
            t.expiry[ 7 - i ] = 0
        end
        table.sort( t.expiry )

        t.actual = nil
    end,

    spend = function( amount )
        local t = state.runes

        for i = 1, amount do
            t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end

        -- TODO:  Rampant Transference
        state.gain( amount * 10 * ( state.buff.rune_of_hysteria.up and 1.2 or 1 ), "runic_power" )

        if state.talent.rune_strike.enabled then state.gainChargeTime( "rune_strike", amount ) end

        if state.buff.dancing_rune_weapon.up and state.azerite.eternal_rune_weapon.enabled then
            if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < state.buff.dancing_rune_weapon.duration + 5 then
                state.buff.eternal_rune_weapon.expires = min( state.buff.dancing_rune_weapon.applied + state.buff.dancing_rune_weapon.duration + 5, state.buff.dancing_rune_weapon.expires + ( 0.5 * amount ) )
            end
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.runes, x )
    end,
}, {
    __index = function( t, k, v )
        if k == "actual" then
            local amount = 0

            for i = 1, 6 do
                if t.expiry[ i ] <= state.query_time then
                    amount = amount + 1
                end
            end

            return amount

        elseif k == "current" then
            -- If this is a modeled resource, use our lookup system.
            if t.forecast and t.fcount > 0 then
                local q = state.query_time
                local index, slice

                if t.values[ q ] then return t.values[ q ] end

                for i = 1, t.fcount do
                    local v = t.forecast[ i ]
                    if v.t <= q then
                        index = i
                        slice = v
                    else
                        break
                    end
                end

                -- We have a slice.
                if index and slice then
                    t.values[ q ] = max( 0, min( t.max, slice.v ) )
                    return t.values[ q ]
                end
            end

            return t.actual

        elseif k == "deficit" then
            return t.max - t.current

        elseif k == "time_to_next" then
            return t[ "time_to_" .. t.current + 1 ]

        elseif k == "time_to_max" then
            return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

        elseif k == "add" then
            return t.gain

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )
spec:RegisterResource( Enum.PowerType.RunicPower )

-- Talents
spec:RegisterTalents( {
    abomination_limb               = { 76049, 383269, 1 }, --
    acclimation                    = { 76047, 373926, 1 }, --
    antimagic_barrier              = { 76046, 205727, 1 }, --
    antimagic_shell                = { 76070, 48707 , 1 }, --
    antimagic_zone                 = { 76065, 51052 , 1 }, --
    asphyxiate                     = { 76064, 221562, 1 }, --
    assimilation                   = { 76048, 374383, 1 }, --
    blinding_sleet                 = { 76044, 207167, 1 }, --
    blood_boil                     = { 76170, 50842 , 1 }, --
    blood_draw                     = { 76079, 374598, 2 }, --
    blood_feast                    = { 76039, 391386, 1 }, --
    blood_scent                    = { 76066, 374030, 1 }, --
    blood_tap                      = { 76142, 221699, 1 }, --
    blooddrinker                   = { 76143, 206931, 1 }, --
    bloodshot                      = { 76125, 391398, 1 }, --
    bloodworms                     = { 76174, 195679, 1 }, --
    bonestorm                      = { 76127, 194844, 1 }, --
    brittle                        = { 76061, 374504, 1 }, --
    chains_of_ice                  = { 76081, 45524 , 1 }, --
    cleaving_strikes               = { 76073, 316916, 1 }, --
    clenching_grasp                = { 76062, 389679, 1 }, --
    coagulopathy                   = { 76038, 391477, 1 }, --
    coldthirst                     = { 76045, 378848, 1 }, --
    consumption                    = { 76143, 274156, 1 }, --
    control_undead                 = { 76059, 111673, 1 }, --
    crimson_scourge                = { 76171, 81136 , 1 }, --
    dancing_rune_weapon            = { 76138, 49028 , 1 }, --
    death_pact                     = { 76077, 48743 , 1 }, --
    death_strike                   = { 76071, 49998 , 1 }, --
    deaths_caress                  = { 76146, 195292, 1 }, --
    deaths_echo                    = { 76056, 356367, 1 }, --
    deaths_reach                   = { 76057, 276079, 1 }, --
    empower_rune_weapon            = { 76050, 47568 , 1 }, --
    enfeeble                       = { 76060, 392566, 1 }, --
    everlasting_bond               = { 76130, 377668, 1 }, --
    foul_bulwark                   = { 76167, 206974, 1 }, --
    gloom_ward                     = { 76052, 391571, 1 }, --
    gorefiends_grasp               = { 76136, 108199, 1 }, --
    grip_of_the_dead               = { 76057, 273952, 1 }, --
    heart_strike                   = { 76169, 206930, 1 }, --
    heartbreaker                   = { 76135, 221536, 2 }, --
    heartrend                      = { 76131, 377655, 1 }, --
    hemostasis                     = { 76137, 273946, 1 }, --
    icebound_fortitude             = { 76084, 48792 , 1 }, --
    icy_talons                     = { 76051, 194878, 2 }, --
    improved_bone_shield           = { 76042, 374715, 1 }, --
    improved_death_strike          = { 76067, 374277, 1 }, --
    improved_heart_strike          = { 76126, 374717, 2 }, --
    improved_vampiric_blood        = { 76140, 317133, 2 }, --
    insatiable_blade               = { 76129, 377637, 1 }, --
    insidious_chill                = { 76088, 391566, 1 }, --
    iron_heart                     = { 76172, 391395, 1 }, --
    leeching_strike                = { 76166, 377629, 1 }, --
    march_of_darkness              = { 76069, 391546, 1 }, --
    mark_of_blood                  = { 76139, 206940, 1 }, --
    marrowrend                     = { 76168, 195182, 1 }, --
    merciless_strikes              = { 76085, 373923, 1 }, --
    might_of_thassarian            = { 76076, 374111, 1 }, --
    mind_freeze                    = { 76082, 47528 , 1 }, --
    ossuary                        = { 76144, 219786, 1 }, --
    permafrost                     = { 76083, 207200, 1 }, --
    perseverance_of_the_ebon_blade = { 76124, 374747, 2 }, --
    proliferating_chill            = { 76086, 373930, 1 }, --
    purgatory                      = { 76133, 114556, 1 }, --
    raise_dead                     = { 76072, 46585 , 1 }, --
    rapid_decomposition            = { 76141, 194662, 1 }, --
    red_thirst                     = { 76132, 205723, 2 }, --
    reinforced_bones               = { 76165, 374737, 1 }, --
    relish_in_blood                = { 76147, 317610, 1 }, --
    rune_mastery                   = { 76080, 374574, 2 }, --
    rune_tap                       = { 76145, 194679, 1 }, --
    runic_attenuation              = { 76087, 207104, 1 }, --
    sacrificial_pact               = { 76074, 327574, 1 }, --
    sanguine_ground                = { 76041, 391458, 1 }, --
    shattering_bone                = { 76128, 377640, 2 }, --
    soul_reaper                    = { 76053, 343294, 1 }, --
    suppression                    = { 76075, 374049, 1 }, --
    tightening_grasp               = { 76134, 206970, 1 }, --
    tombstone                      = { 76139, 219809, 1 }, --
    umbilicus_eternus              = { 76040, 391517, 1 }, --
    unholy_bond                    = { 76055, 374261, 2 }, --
    unholy_endurance               = { 76063, 389682, 1 }, --
    unholy_ground                  = { 76058, 374265, 1 }, --
    vampiric_blood                 = { 76173, 55233 , 1 }, --
    veteran_of_the_third_war       = { 76068, 48263 , 2 }, --
    voracious                      = { 76043, 273953, 1 }, --
    will_of_the_necropolis         = { 76054, 206967, 2 }, --
    wraith_walk                    = { 76078, 212552, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_for_blood  = 607 , -- 356456
    dark_simulacrum  = 3511, -- 77606
    death_chain      = 609 , -- 203173
    decomposing_aura = 3441, -- 199720
    last_dance       = 608 , -- 233412
    murderous_intent = 841 , -- 207018
    necrotic_aura    = 5513, -- 199642
    rot_and_wither   = 204 , -- 202727
    spellwarden      = 5425, -- 356332
    strangulate      = 206 , -- 47476
    walking_dead     = 205 , -- 202731
} )


-- Auras
spec:RegisterAuras( {
    abomination_limb = {
        id = 383269,
        duration = 12,
        tick_time = 1,
        max_stack = 1
    },
    abomination_limb_immune = {
        id = 383312,
        duration = 4,
        max_stack = 1
    },
    antimagic_shell = {
        id = 48707,
        duration = 5,
        max_stack = 1
    },
    antimagic_zone = { -- TODO: Modify expiration based on last cast.
        id = 145629,
        duration = 8,
        max_stack = 1
    },
    asphyxiate = {
        id = 221562,
        duration = 5,
        max_stack = 1
    },
    blinding_sleet = {
        id = 207167,
        duration = 5,
        max_stack = 1
    },
    blood_draw = {
        id = 374609,
        duration = 180,
        max_stack = 1
    },
    blood_plague = {
        id = 55078,
        duration = 24,
        tick_time = 3,
        max_stack = 1
    },
    blooddrinker = {
        id = 206931,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    bloodworm = { -- TODO: Check Aura (https://wowhead.com/beta/spell=196361)
        id = 196361,
        duration = 16,
        max_stack = 1
    },
    bloodworms = { -- TODO: Check Aura (https://wowhead.com/beta/spell=198494)
        id = 198494,
        duration = 15,
        max_stack = 1
    },
    bonestorm = {
        id = 194844,
        duration = 1,
        tick_time = 1,
        max_stack = 1
    },
    chains_of_ice = {
        id = 45524,
        duration = 8,
        max_stack = 1
    },
    coagulopathy = {
        id = 391481,
        duration = 8,
        max_stack = 5
    },
    control_undead = {
        id = 111673,
        duration = 300,
        max_stack = 1
    },
    dancing_rune_weapon = { -- TODO: Check Aura (https://wowhead.com/beta/spell=49028)
        id = 49028,
        duration = 13,
        max_stack = 1
    },
    dark_command = {
        id = 56222,
        duration = 3,
        max_stack = 1
    },
    dark_simulacrum = {
        id = 77606,
        duration = 12,
        max_stack = 1
    },
    death_and_decay = { -- TODO: Double-check aura ID.
        id = 188290,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    death_chain = {
        id = 203173,
        duration = 10,
        max_stack = 1
    },
    death_pact = {
        id = 48743,
        duration = 15,
        max_stack = 1
    },
    deaths_advance = {
        id = 48265,
        duration = 10,
        max_stack = 1
    },
    empower_rune_weapon = {
        id = 47568,
        duration = 20,
        tick_time = 5,
        max_stack = 1
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    gorefiends_grasp = { -- TODO: Check Aura (https://wowhead.com/beta/spell=108199)
        id = 108199,
        duration = 10,
        max_stack = 1
    },
    heart_strike = {
        id = 206930,
        duration = 8,
        max_stack = 1
    },
    hemostasis = {
        id = 273947,
        duration = 15,
        max_stack = 5
    },
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
    icy_talons = {
        id = 194879,
        duration = 6,
        max_stack = 3
    },
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    lichborne = {
        id = 49039,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    march_of_darkness = {
        id = 391547,
        duration = 3,
        max_stack = 1
    },
    mark_of_blood = {
        id = 206940,
        duration = 15,
        max_stack = 1
    },
    mind_freeze = { -- TODO: Check Aura (https://wowhead.com/beta/spell=47528)
        id = 47528,
        duration = 3,
        max_stack = 1
    },
    murderous_intent = { -- TODO: Check Aura (https://wowhead.com/beta/spell=207018)
        id = 207018,
        duration = 300,
        max_stack = 1
    },
    path_of_frost = {
        id = 3714,
        duration = 600,
        tick_time = 0.5,
        max_stack = 1
    },
    raise_dead = { -- TODO: Check Aura (https://wowhead.com/beta/spell=46585)
        id = 46585,
        duration = 60,
        max_stack = 1
    },
    rune_tap = {
        id = 194679,
        duration = 4,
        max_stack = 1
    },
    soul_reaper = {
        id = 343294,
        duration = 5,
        tick_time = 5,
        max_stack = 1
    },
    strangulate = {
        id = 47476,
        duration = 4,
        max_stack = 1
    },
    tombstone = {
        id = 219809,
        duration = 8,
        max_stack = 1
    },
    umbilicus_eternus = {
        id = 391519,
        duration = 10,
        max_stack = 1
    },
    vampiric_blood = {
        id = 55233,
        duration = 10,
        max_stack = 1
    },
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
    },
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    abomination_limb = {
        id = 383269,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "abomination_limb",
        startsCombat = false,
        texture = 3578196,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "antimagic_shell",
        startsCombat = false,
        texture = 136120,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "antimagic_zone",
        startsCombat = false,
        texture = 237510,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    asphyxiate = {
        id = 221562,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "asphyxiate",
        startsCombat = false,
        texture = 538558,

        handler = function ()
        end,
    },


    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = false,
        texture = 135836,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blood_boil = {
        id = 50842,
        cast = 0,
        charges = 2,
        cooldown = 7.5,
        recharge = 7.5,
        gcd = "spell",

        talent = "blood_boil",
        startsCombat = false,
        texture = 237513,

        handler = function ()
        end,
    },


    blood_tap = {
        id = 221699,
        cast = 0,
        charges = 2,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "blood_tap",
        startsCombat = false,
        texture = 237515,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blooddrinker = {
        id = 206931,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "blooddrinker",
        startsCombat = false,
        texture = 838812,

        handler = function ()
        end,
    },


    bonestorm = {
        id = 194844,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 100,
        spendType = "runic_power",

        talent = "bonestorm",
        startsCombat = false,
        texture = 342917,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "chains_of_ice",
        startsCombat = false,
        texture = 135834,

        handler = function ()
        end,
    },


    consumption = {
        id = 274156,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "consumption",
        startsCombat = false,
        texture = 1121487,

        handler = function ()
        end,
    },


    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "control_undead",
        startsCombat = false,
        texture = 237273,

        handler = function ()
        end,
    },


    dancing_rune_weapon = {
        id = 49028,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "dancing_rune_weapon",
        startsCombat = false,
        texture = 135277,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136088,

        handler = function ()
        end,
    },


    dark_simulacrum = {
        id = 77606,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        pvptalent = "dark_simulacrum",
        startsCombat = false,
        texture = 135888,

        handler = function ()
        end,
    },


    death_and_decay = {
        id = 43265,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        texture = 136144,

        handler = function ()
        end,
    },


    death_chain = {
        id = 203173,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        pvptalent = "death_chain",
        startsCombat = false,
        texture = 1390941,

        handler = function ()
        end,
    },


    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = true,
        texture = 136145,

        handler = function ()
        end,
    },


    death_gate = {
        id = 50977,
        cast = 4,
        cooldown = 60,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,
        texture = 135766,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    death_grip = {
        id = 49576,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "off",
        icd = 0.5,

        startsCombat = true,
        texture = 237532,

        handler = function ()
        end,
    },


    death_pact = {
        id = 48743,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "death_pact",
        startsCombat = false,
        texture = 136146,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 45,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,
        texture = 237517,

        handler = function ()
        end,
    },


    deaths_advance = {
        id = 48265,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "off",

        startsCombat = false,
        texture = 237561,

        handler = function ()
        end,
    },


    deaths_caress = {
        id = 195292,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "deaths_caress",
        startsCombat = false,
        texture = 1376743,

        handler = function ()
        end,
    },


    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "empower_rune_weapon",
        startsCombat = false,
        texture = 135372,

        handler = function ()
        end,
    },


    gorefiends_grasp = {
        id = 108199,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "gorefiends_grasp",
        startsCombat = false,
        texture = 538767,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    heart_strike = {
        id = 206930,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "health",

        talent = "heart_strike",
        startsCombat = false,
        texture = 135675,

        handler = function ()
        end,
    },


    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "icebound_fortitude",
        startsCombat = false,
        texture = 237525,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    lichborne = {
        id = 49039,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 136187,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mark_of_blood = {
        id = 206940,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        talent = "mark_of_blood",
        startsCombat = false,
        texture = 132205,

        handler = function ()
        end,
    },


    marrowrend = {
        id = 195182,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = -20,
        spendType = "runic_power",

        talent = "marrowrend",
        startsCombat = false,
        texture = 1376745,

        handler = function ()
        end,
    },


    mind_freeze = {
        id = 47528,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        spend = 0,
        spendType = "runic_power",

        talent = "mind_freeze",
        startsCombat = false,
        texture = 237527,

        handler = function ()
        end,
    },


    murderous_intent = {
        id = 207018,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "murderous_intent",
        startsCombat = false,
        texture = 136088,

        handler = function ()
        end,
    },


    path_of_frost = {
        id = 3714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,
        texture = 237528,

        handler = function ()
        end,
    },


    raise_ally = {
        id = 61999,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = true,
        texture = 136143,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    raise_dead = {
        id = 46585,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "raise_dead",
        startsCombat = false,
        texture = 1100170,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    rune_strike = {
        id = 316239,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        texture = 237518,

        handler = function ()
        end,
    },


    rune_tap = {
        id = 194679,
        cast = 0,
        charges = 2,
        cooldown = 25,
        recharge = 25,
        gcd = "off",

        spend = -10,
        spendType = "runic_power",

        talent = "rune_tap",
        startsCombat = false,
        texture = 237529,

        handler = function ()
        end,
    },


    runeforging = {
        id = 53428,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 237523,

        handler = function ()
        end,
    },


    sacrificial_pact = {
        id = 327574,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 20,
        spendType = "runic_power",

        talent = "sacrificial_pact",
        startsCombat = false,
        texture = 136133,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = false,
        texture = 636333,

        handler = function ()
        end,
    },


    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0,
        spendType = "runes",

        pvptalent = "strangulate",
        startsCombat = false,
        texture = 136214,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tombstone = {
        id = 219809,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "tombstone",
        startsCombat = false,
        texture = 132151,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    vampiric_blood = {
        id = 55233,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "vampiric_blood",
        startsCombat = false,
        texture = 136168,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wraith_walk = {
        id = 212552,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "wraith_walk",
        startsCombat = false,
        texture = 1100041,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Blood", 20220921,
-- Notes
[[

]],
-- Priority
[[

]] )