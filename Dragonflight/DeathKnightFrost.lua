-- DeathKnightFrost.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

local spec = Hekili:NewSpecialization( 251 )

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

    empower_rune = {
        aura = "empower_rune_weapon",

        last = function ()
            return state.buff.empower_rune_weapon.applied + floor( ( state.query_time - state.buff.empower_rune_weapon.applied ) / 5 ) * 5
        end,

        stop = function ( x )
            return x == 6
        end,

        interval = 5,
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

        state.gain( amount * 10, "runic_power" )

        if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
            state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
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
    abomination_limb            = { 76049, 383269, 1 }, --
    absolute_zero               = { 76094, 377047, 1 }, --
    acclimation                 = { 76047, 373926, 1 }, --
    anticipation                = { 76045, 378848, 1 }, --
    antimagic_barrier           = { 76046, 205727, 1 }, --
    antimagic_shell             = { 76070, 48707 , 1 }, --
    antimagic_zone              = { 76065, 51052 , 1 }, --
    asphyxiate                  = { 76064, 221562, 1 }, --
    assimilation                = { 76048, 374383, 1 }, --
    avalanche                   = { 76105, 207142, 1 }, --
    biting_cold                 = { 76036, 377056, 1 }, --
    blinding_sleet              = { 76044, 207167, 1 }, --
    blood_draw                  = { 76079, 374598, 2 }, --
    blood_scent                 = { 76066, 374030, 1 }, --
    bonegrinder                 = { 76122, 377098, 2 }, --
    breath_of_sindragosa        = { 76093, 152279, 1 }, --
    brittle                     = { 76061, 374504, 1 }, --
    chains_of_ice               = { 76081, 45524 , 1 }, --
    chill_streak                = { 76098, 305392, 1 }, --
    cleaving_strikes            = { 76073, 316916, 1 }, --
    clenching_grasp             = { 76062, 389679, 1 }, --
    cold_heart                  = { 76110, 281208, 1 }, --
    coldblooded_rage            = { 76123, 377083, 2 }, --
    control_undead              = { 76059, 111673, 1 }, --
    death_pact                  = { 76077, 48743 , 1 }, --
    death_strike                = { 76071, 49998 , 1 }, --
    deaths_echo                 = { 76056, 356367, 1 }, --
    deaths_reach                = { 76057, 276079, 1 }, --
    empower_rune_weapon         = { 76099, 47568 , 1 }, --
    empower_rune_weapon_2       = { 76050, 47568 , 1 }, --
    enduring_chill              = { 76097, 377376, 1 }, --
    enduring_strength           = { 76100, 377190, 2 }, --
    enfeeble                    = { 76060, 392566, 1 }, --
    everfrost                   = { 76107, 376938, 1 }, --
    frigid_executioner          = { 76120, 377073, 1 }, --
    frost_strike                = { 76115, 49143 , 1 }, --
    frostreaper                 = { 76089, 317214, 1 }, --
    frostscythe                 = { 76096, 207230, 1 }, --
    frostwhelps_aid             = { 76106, 377226, 2 }, --
    frostwyrms_fury             = { 76095, 279302, 1 }, --
    gathering_storm             = { 76109, 194912, 1 }, --
    glacial_advance             = { 76092, 194913, 1 }, --
    gloom_ward                  = { 76052, 391571, 1 }, --
    grip_of_the_dead            = { 76057, 273952, 1 }, --
    horn_of_winter              = { 76035, 57330 , 1 }, --
    howling_blast               = { 76114, 49184 , 1 }, --
    icebound_fortitude          = { 76084, 48792 , 1 }, --
    icebreaker                  = { 76033, 392950, 2 }, --
    icecap                      = { 76034, 207126, 1 }, --
    icy_talons                  = { 76051, 194878, 2 }, --
    improved_death_strike       = { 76067, 374277, 1 }, --
    improved_frost_strike       = { 76103, 316803, 2 }, --
    improved_obliterate         = { 76119, 317198, 2 }, --
    improved_rime               = { 76111, 316838, 2 }, --
    inexorable_assault          = { 76037, 253593, 1 }, --
    insidious_chill             = { 76088, 391566, 1 }, --
    invigorating_freeze         = { 76108, 377092, 2 }, --
    killing_machine             = { 76117, 51128 , 1 }, --
    march_of_darkness           = { 76069, 391546, 1 }, --
    merciless_strikes           = { 76085, 373923, 1 }, --
    might_of_thassarian         = { 76076, 374111, 1 }, --
    might_of_the_frozen_wastes  = { 76090, 81333 , 1 }, --
    mind_freeze                 = { 76082, 47528 , 1 }, --
    murderous_efficiency        = { 76121, 207061, 1 }, --
    obliterate                  = { 76116, 49020 , 1 }, --
    obliteration                = { 76091, 281238, 1 }, --
    permafrost                  = { 76083, 207200, 1 }, --
    piercing_chill              = { 76097, 377351, 1 }, --
    pillar_of_frost             = { 76104, 51271 , 1 }, --
    proliferating_chill         = { 76086, 373930, 1 }, --
    rage_of_the_frozen_champion = { 76120, 377076, 1 }, --
    raise_dead                  = { 76072, 46585 , 1 }, --
    remorseless_winter          = { 76112, 196770, 1 }, --
    rime                        = { 76113, 59057 , 1 }, --
    rune_mastery                = { 76080, 374574, 2 }, --
    runic_attenuation           = { 76087, 207104, 1 }, --
    runic_command               = { 76102, 376251, 2 }, --
    sacrificial_pact            = { 76074, 327574, 1 }, --
    shattering_strike           = { 76101, 207057, 1 }, --
    soul_reaper                 = { 76053, 343294, 1 }, --
    suppression                 = { 76075, 374049, 1 }, --
    unholy_bond                 = { 76055, 374261, 2 }, --
    unholy_endurance            = { 76063, 389682, 1 }, --
    unholy_ground               = { 76058, 374265, 1 }, --
    unleashed_frenzy            = { 76118, 376905, 1 }, --
    veteran_of_the_third_war    = { 76068, 48263 , 2 }, --
    will_of_the_necropolis      = { 76054, 206967, 2 }, --
    wraith_walk                 = { 76078, 212552, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill     = 5435, -- 356470
    dark_simulacrum  = 3512, -- 77606
    dead_of_winter   = 3743, -- 287250
    deathchill       = 701 , -- 204080
    delirium         = 702 , -- 233396
    necrotic_aura    = 5512, -- 199642
    rot_and_wither   = 5510, -- 202727
    shroud_of_winter = 3439, -- 199719
    spellwarden      = 5424, -- 356332
    strangulate      = 5429, -- 47476
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
    breath_of_sindragosa = {
        id = 152279,
        duration = 3600,
        tick_time = 1,
        max_stack = 1
    },
    chains_of_ice = {
        id = 45524,
        duration = 8,
        max_stack = 1
    },
    cold_heart = {
        id = 281209,
        duration = 3600,
        max_stack = 20
    },
    control_undead = {
        id = 111673,
        duration = 300,
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
    dark_succor = {
        id = 101568,
        duration = 20,
        max_stack = 1
    },
    death_and_decay = { -- Buff.
        id = 188290,
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
    enduring_strength = {
        id = 377192,
        duration = 20,
        max_stack = 20
    },
    everfrost = {
        id = 376974,
        duration = 8,
        max_stack = 10
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    frostwhelps_aid = {
        id = 377253,
        duration = 15,
        max_stack = 1
    },
    frostwyrms_fury = { -- Snare.
        id = 279303,
        duration = 10,
        max_stack = 1
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
    killing_machine = {
        id = 51124,
        duration = 10,
        max_stack = 1
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
    obliteration = {
        id = 207256,
        duration = 3600,
        max_stack = 1
    },
    path_of_frost = {
        id = 3714,
        duration = 600,
        tick_time = 0.5,
        max_stack = 1
    },
    pillar_of_frost = {
        id = 51271,
        duration = 12,
        max_stack = 1
    },
    raise_dead = { -- TODO: Is a pet.
        id = 46585,
        duration = 60,
        max_stack = 1
    },
    remorseless_winter = {
        id = 196770,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    rime = {
        id = 59052,
        duration = 15,
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
    unleashed_frenzy = {
        id = 376907,
        duration = 6,
        max_stack = 3
    },
    voidtouched = { -- Battle rez debuff.
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


    breath_of_sindragosa = {
        id = 152279,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0,
        spendType = "runic_power",

        talent = "breath_of_sindragosa",
        startsCombat = false,
        texture = 1029007,

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
        startsCombat = true,
        texture = 135834,

        handler = function ()
        end,
    },


    chill_streak = {
        id = 305392,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 40,
        spendType = "runic_power",

        talent = "chill_streak",
        startsCombat = false,
        texture = 429386,

        handler = function ()
        end,
    },


    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "control_undead",
        startsCombat = false,
        texture = 237273,

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
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        texture = 136144,

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
        cooldown = 25,
        recharge = 25,
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
        startsCombat = false,
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


    frost_strike = {
        id = 49143,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 25,
        spendType = "runic_power",

        talent = "frost_strike",
        startsCombat = false,
        texture = 237520,

        handler = function ()
        end,
    },


    frostscythe = {
        id = 207230,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "frostscythe",
        startsCombat = false,
        texture = 1060569,

        handler = function ()
        end,
    },


    frostwyrms_fury = {
        id = 279302,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "frostwyrms_fury",
        startsCombat = false,
        texture = 341980,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    glacial_advance = {
        id = 194913,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        talent = "glacial_advance",
        startsCombat = false,
        texture = 537514,

        handler = function ()
        end,
    },


    horn_of_winter = {
        id = 57330,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "horn_of_winter",
        startsCombat = false,
        texture = 134228,

        handler = function ()
        end,
    },


    howling_blast = {
        id = 49184,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "howling_blast",
        startsCombat = false,
        texture = 135833,

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


    obliterate = {
        id = 49020,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "obliterate",
        startsCombat = false,
        texture = 135771,

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


    pillar_of_frost = {
        id = 51271,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "pillar_of_frost",
        startsCombat = false,
        texture = 458718,

        toggle = "cooldowns",

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


    remorseless_winter = {
        id = 196770,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "remorseless_winter",
        startsCombat = false,
        texture = 538770,

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

spec:RegisterPriority( "Frost", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )