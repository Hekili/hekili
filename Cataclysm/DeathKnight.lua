if UnitClassBase( 'player' ) ~= 'DEATHKNIGHT' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 6 )

spec:RegisterResource( Enum.PowerType.RuneBlood, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.blood_runes

            if val == 2 then return -1 end
            return r.expiry[ val + 1 ] - time
        end,

        stop = function( x )
            return x == 2
        end,

        value = 1
    },
}, setmetatable( {
    expiry = { 0, 0 },
    cooldown = 10,
    regen = 0,
    max = 2,
    forecast = {},
    fcount = 0,
    times = {},
    values = {},
    resource = "blood_runes",

    reset = function()
        local t = state.blood_runes

        for i = 1, 2 do
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
        local t = state.blood_runes

        for i = 1, amount do
            t.expiry[ 3 - i ] = 0
        end
        table.sort( t.expiry )

        t.actual = nil
    end,

    spend = function( amount )
        local t = state.blood_runes

        for i = 1, amount do
            t.expiry[ 1 ] = ( t.expiry[ 2 ] > 0 and t.expiry[ 2 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.blood_runes, x )
    end,
}, {
    __index = function( t, k, v )
        if k == "actual" then
            local amount = 0

            for i = 1, 2 do
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
            return t.current == 2 and 0 or max( 0, t.expiry[2] - state.query_time )

        elseif k == "add" then
            return t.gain

        elseif k == "regen" then
            return 0

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )

spec:RegisterResource( Enum.PowerType.RuneFrost, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.frost_runes

            if val == 2 then return -1 end
            return r.expiry[ val + 1 ] - time
        end,

        stop = function( x )
            return x == 2
        end,

        value = 1
    },
}, setmetatable( {
    expiry = { 0, 0 },
    cooldown = 10,
    regen = 0,
    max = 2,
    forecast = {},
    fcount = 0,
    times = {},
    values = {},
    resource = "frost_runes",

    reset = function()
        local t = state.frost_runes

        for i = 1, 2 do
            local start, duration, ready = GetRuneCooldown( i + 4 )

            start = start or 0
            duration = duration or ( 10 * state.haste )

            t.expiry[ i ] = ready and 0 or start + duration
            t.cooldown = duration
        end

        table.sort( t.expiry )

        t.actual = nil
    end,

    gain = function( amount )
        local t = state.frost_runes

        amount = min( 2, amount )

        for i = 1, amount do
            t.expiry[ i ] = 0
        end
        table.sort( t.expiry )

        t.actual = nil
    end,

    spend = function( amount )
        local t = state.frost_runes

        amount = min( 2, amount )

        for i = 1, amount do
            t.expiry[ 1 ] = ( t.expiry[ 2 ] > 0 and t.expiry[ 2 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.frost_runes, x )
    end,
}, {
    __index = function( t, k, v )
        if k == "actual" then
            local amount = 0

            for i = 1, 2 do
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
            return t.current == 2 and 0 or max( 0, t.expiry[ 2 ] - state.query_time )

        elseif k == "add" then
            return t.gain

        elseif k == "regen" then
            return 0

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )

spec:RegisterResource( Enum.PowerType.RuneUnholy, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.unholy_runes

            if val == 2 then return -1 end
            return r.expiry[ val + 1 ] - time
        end,

        stop = function( x )
            return x == 2
        end,

        value = 1
    },
}, setmetatable( {
    expiry = { 0, 0 },
    cooldown = 10,
    regen = 0,
    max = 2,
    forecast = {},
    fcount = 0,
    times = {},
    values = {},
    resource = "unholy_runes",

    reset = function()
        local t = state.unholy_runes

        for i = 3, 4 do
            local start, duration, ready = GetRuneCooldown( i )

            start = start or 0
            duration = duration or ( 10 * state.haste )

            t.expiry[ i - 2 ] = ready and 0 or start + duration
            t.cooldown = duration
        end

        table.sort( t.expiry )

        t.actual = nil
    end,

    gain = function( amount )
        local t = state.unholy_runes

        amount = min( amount, 2 )

        for i = 1, amount do
            t.expiry[ i ] = 0
        end
        table.sort( t.expiry )

        t.actual = nil
    end,

    spend = function( amount )
        local t = state.unholy_runes

        amount = min( 2, amount )

        for i = 1, amount do
            t.expiry[ 1 ] = ( t.expiry[ 2 ] > 0 and t.expiry[ 2 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.unholy_runes, x )
    end,
}, {
    __index = function( t, k, v )
        if k == "actual" then
            local amount = 0

            for i = 1, 2 do
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
            return t.current == 2 and 0 or max( 0, t.expiry[2] - state.query_time )

        elseif k == "add" then
            return t.gain

        elseif k == "regen" then
            return 0

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )

spec:RegisterResource( Enum.PowerType.RunicPower )
-- butchery talent should generate 1 RP every 5/2.5 seconds depending on rank.
-- scent_of_blood should generate 10 RP on next attack.


-- Talents
spec:RegisterTalents( {
    abominations_might              = {  2105, 2, 53137, 53138 },
    acclimation                     = {  1997, 3, 49200, 50151, 50152 },
    annihilation                    = {  2048, 3, 51468, 51472, 51473 },
    anticipation                    = {  2218, 5, 55129, 55130, 55131, 55132, 55133 },
    antimagic_zone                  = {  2221, 1, 51052 },
    black_ice                       = {  1973, 5, 49140, 49661, 49662, 49663, 49664 },
    blade_barrier                   = {  2017, 5, 49182, 49500, 49501, 55225, 55226 },
    bladed_armor                    = {  1938, 5, 48978, 49390, 49391, 49392, 49393 },
    blood_gorged                    = {  2034, 5, 61154, 61155, 61156, 61157, 61158 },
    blood_of_the_north              = {  2210, 3, 54639, 54638, 54637 },
    bloodcaked_blade                = {  2004, 3, 49219, 49627, 49628 },
    bloodworms                      = {  1960, 3, 49027, 49542, 49543 },
    bloody_strikes                  = {  2015, 3, 48977, 49394, 49395 },
    bloody_vengeance                = {  1944, 3, 48988, 49503, 49504 },
    bone_shield                     = {  2007, 1, 49222 },
    butchery                        = {  1939, 2, 48979, 49483 },
    chilblains                      = {  2260, 3, 50040, 50041, 50043 },
    chill_of_the_grave              = {  1981, 2, 49149, 50115 },
    corpse_explosion                = {  1985, 1, 49158 },
    crypt_fever                     = {  1962, 3, 49032, 49631, 49632 },
    dancing_rune_weapon             = {  1961, 1, 49028 },
    dark_conviction                 = {  1943, 5, 48987, 49477, 49478, 49479, 49480 },
    death_rune_mastery              = {  2086, 3, 49467, 50033, 50034 },
    deathchill                      = {  1980, 1, 49796 },
    desecration                     = {  2226, 2, 55666, 55667 },
    desolation                      = {  2285, 5, 66799, 66814, 66815, 66816, 66817 },
    dirge                           = {  2011, 2, 49223, 49599 },
    ebon_plaguebringer              = {  2043, 3, 51099, 51160, 51161 },
    endless_winter                  = {  1971, 2, 49137, 49657 },
    epidemic                        = {  1963, 2, 49036, 49562 },
    frigid_dreadplate               = {  1990, 3, 49186, 51108, 51109 },
    frost_strike                    = {  1975, 1, 49143 },
    ghoul_frenzy                    = {  2085, 1, 63560 },
    glacier_rot                     = {  2030, 3, 49471, 49790, 49791 },
    guile_of_gorefiend              = {  2040, 3, 50187, 50190, 50191 },
    heart_strike                    = {  1957, 1, 55050 },
    howling_blast                   = {  1989, 1, 49184 },
    hungering_cold                  = {  1999, 1, 49203 },
    icy_reach                       = {  2035, 2, 55061, 55062 },
    icy_talons                      = {  2042, 5, 50880, 50884, 50885, 50886, 50887 },
    improved_blood_presence         = {  1936, 2, 50365, 50371 },
    improved_death_strike           = {  2259, 2, 62905, 62908 },
    improved_frost_presence         = {  2029, 2, 50384, 50385 },
    improved_icy_talons             = {  2223, 1, 55610 },
    improved_icy_touch              = {  2031, 3, 49175, 50031, 51456 },
    improved_rune_tap               = {  1942, 3, 48985, 49488, 49489 },
    improved_unholy_presence        = {  2013, 2, 50391, 50392 },
    impurity                        = {  2005, 5, 49220, 49633, 49635, 49636, 49638 },
    killing_machine                 = {  2044, 5, 51123, 51127, 51128, 51129, 51130 },
    lichborne                       = {  2215, 1, 49039 },
    magic_suppression               = {  2009, 3, 49224, 49610, 49611 },
    mark_of_blood                   = {  1949, 1, 49005 },
    master_of_ghouls                = {  1984, 1, 52143 },
    merciless_combat                = {  1993, 2, 49024, 49538 },
    might_of_mograine               = {  1958, 3, 49023, 49533, 49534 },
    morbidity                       = {  1933, 3, 48963, 49564, 49565 },
    necrosis                        = {  2047, 5, 51459, 51462, 51463, 51464, 51465 },
    nerves_of_cold_steel            = {  2022, 3, 49226, 50137, 50138 },
    night_of_the_dead               = {  2225, 2, 55620, 55623 },
    on_a_pale_horse                 = {  2039, 2, 49146, 51267 },
    outbreak                        = {  2008, 3, 49013, 55236, 55237 },
    rage_of_rivendare               = {  2036, 5, 50117, 50118, 50119, 50120, 50121 },
    ravenous_dead                   = {  1934, 3, 48965, 49571, 49572 },
    reaping                         = {  2001, 3, 49208, 56834, 56835 },
    rime                            = {  1992, 3, 49188, 56822, 59057 },
    rune_tap                        = {  1941, 1, 48982 },
    runic_power_mastery             = {  2020, 2, 49455, 50147 },
    scent_of_blood                  = {  1948, 3, 49004, 49508, 49509 },
    scourge_strike                  = {  2216, 1, 55090 },
    spell_deflection                = {  2018, 3, 49145, 49495, 49497 },
    subversion                      = {  1945, 3, 48997, 49490, 49491 },
    sudden_doom                     = {  1955, 3, 49018, 49529, 49530 },
    summon_gargoyle                 = {  2000, 1, 49206 },
    threat_of_thassarian            = {  2284, 3, 65661, 66191, 66192 },
    toughness                       = {  1968, 5, 49042, 49786, 49787, 49788, 49789 },
    tundra_stalker                  = {  1998, 5, 49202, 50127, 50128, 50129, 50130 },
    twohanded_weapon_specialization = {  2217, 2, 55107, 55108 },
    unbreakable_armor               = {  1979, 1, 51271 },
    unholy_blight                   = {  1996, 1, 49194 },
    unholy_command                  = {  2025, 2, 49588, 49589 },
    unholy_frenzy                   = {  1954, 1, 49016 },
    vampiric_blood                  = {  2019, 1, 55233 },
    vendetta                        = {  1953, 3, 49015, 50154, 55136 },
    veteran_of_the_third_war        = {  1950, 3, 49006, 49526, 50029 },
    vicious_strikes                 = {  2082, 2, 51745, 51746 },
    virulence                       = {  1932, 3, 48962, 49567, 49568 },
    wandering_plague                = {  2003, 3, 49217, 49654, 49655 },
    will_of_the_necropolis          = {  1959, 3, 49189, 50149, 50150 },
} )


-- Glyphs
spec:RegisterGlyphs( {
    [58623] = "antimagic_shell",
    [59332] = "blood_strike",
    [58640] = "blood_tap",
    [58673] = "bone_shield",
    [58620] = "chains_of_ice",
    [59307] = "corpse_explosion",
    [63330] = "dancing_rune_weapon",
    [58613] = "dark_command",
    [63333] = "dark_death",
    [58629] = "death_and_decay",
    [62259] = "death_grip",
    [59336] = "death_strike",
    [58677] = "deaths_embrace",
    [63334] = "disease",
    [58647] = "frost_strike",
    [58616] = "heart_strike",
    [58680] = "horn_of_winter",
    [63335] = "howling_blast",
    [63331] = "hungering_cold",
    [58625] = "icebound_fortitude",
    [58631] = "icy_touch",
    [58671] = "obliterate",
    [59309] = "pestilence",
    [58657] = "plague_strike",
    [60200] = "raise_dead",
    [58669] = "rune_strike",
    [59327] = "rune_tap",
    [58618] = "strangulate",
    [58686] = "ghoul",
    [58635] = "unbreakable_armor",
    [63332] = "unholy_blight",
    [58676] = "vampiric_blood",
} )


-- Auras
spec:RegisterAuras( {
    -- Spell damage reduced by $s1%.  Immune to magic debuffs.
    antimagic_shell = {
        id = 48707,
        duration = function() return glyph.antimagic_shell.enabled and 7 or 5 end,
        max_stack = 1,
    },
    antimagic_zone = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=51052)
        id = 51052,
        duration = 10,
        max_stack = 1,
    },
    army_of_the_dead = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=42651)
        id = 42651,
        duration = 40,
        max_stack = 1,
        copy = { 42651, 42650 },
    },
    -- $s1% less damage taken.
    blade_barrier = {
        id = 64859,
        duration = 10,
        max_stack = 1,
        copy = { 51789, 64855, 64856, 64858, 64859 },
    },
    -- Deals Shadow damage over $d.
    blood_plague = {
        id = 55078,
        duration = function () return 15 + ( 3 * talent.epidemic.rank ) end,
        tick_time = 3,
        max_stack = 1,
    },
    -- Damage increased by $48266s1%.  Healed by $50371s1% of non-periodic damage dealt.
    blood_presence = {
        id = 48266,
        duration = 3600,
        max_stack = 1,
    },
    -- Blood Rune converted to a Death Rune.
    blood_tap = {
        id = 45529,
        duration = 20,
        max_stack = 1,
    },
    bloodworm = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=50452)
        id = 50452,
        duration = 20,
        max_stack = 1,
    },
    -- Physical damage increased by $s1%.
    bloody_vengeance = {
        id = 50449,
        duration = 30,
        max_stack = 3,
        copy = { 50449, 50448, 50447 },
    },
    -- Damage reduced by $s1%.
    bone_shield = {
        id = 49222,
        duration = 300,
        max_stack = function () return glyph.bone_shield.enabled and 4 or 3 end,
    },
    -- Slowed by frozen chains.
    chains_of_ice = {
        id = 45524,
        duration = 10,
        max_stack = 1,
    },
    -- Increases disease damage taken.
    crypt_fever = {
        id = 50508,
        duration = 15,
        max_stack = 1,
        copy = { 50509, 50510 }
    },
    -- You have recently summoned a rune weapon.
    dancing_rune_weapon = {
        id = 49028,
        duration = function() return glyph.dancing_rune_weapon.enabled and 17 or 12 end,
        max_stack = 1,
    },
    -- Taunted.
    dark_command = {
        id = 56222,
        duration = 3,
        max_stack = 1,
    },
    -- $s1 Shadow damage inflicted every sec
    death_and_decay = {
        id = 49938,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 43265, 49936, 49937, 49938 },
    },
    death_gate = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=50977)
        id = 50977,
        duration = 60,
        max_stack = 1,
    },
    -- Taunted.
    death_grip = {
        id = 49575,
        duration = 3,
        max_stack = 1
    },
    -- Your next Icy Touch, Howling Blast, Frost Strike or Obliterate has a 100% chance to critically hit.
    deathchill = {
        id = 49796,
        duration = 30,
        max_stack = 1,
    },
    -- Standing upon unholy ground.   Movement speed is reduced by $s1%.
    desecration = {
        id = 68766,
        duration = 20,
        max_stack = 1,
        copy = { 68766, 55741 },
    },
    -- Damage dealt is increased by $s1%.
    desolation = {
        id = 66803,
        duration = 20,
        max_stack = 1,
        copy = { 66803, 66802, 66801, 66800, 63583 },
    },
    -- Crypt Fever, improved by Ebon Plaguebringer.
    ebon_plague = {
        id = 51735,
        duration = 15,
        max_stack = 1,
        copy = { 51726, 51734 }
    },
    -- Your next Howling Blast will consume no runes.
    freezing_fog = {
        id = 59052,
        duration = 15,
        max_stack = 1,
        copy = "rime"
    },
    -- Deals Frost damage over $d.  Reduces melee and ranged attack speed.
    frost_fever = {
        id = 55095,
        duration = function () return 15 + ( 3 * talent.epidemic.rank ) end,
        tick_time = 3,
        max_stack = 1,
    },
    -- Stamina increased by $61261s1%.  Armor contribution from cloth, leather, mail and plate items increased by $48263s1%.  Damage taken reduced by $48263s3%.
    frost_presence = {
        id = 48263,
        duration = 3600,
        max_stack = 1,
    },
    -- Decreases the time between attacks by $s2% and heals $s1% every $t1 sec.
    ghoul_frenzy = {
        id = 63560,
        duration = 30,
        tick_time = 3,
        max_stack = 1,
        generate = function ( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 63560 )

            if name then
                t.name = name
                t.count = 1
                t.expires = expires
                t.applied = expires - duration
                t.caster = caster
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Stunned.
    glyph_of_death_grip = {
        id = 58628,
        duration = 1,
        max_stack = 1,
    },
    -- Snare.
    glyph_of_heart_strike = {
        id = 58617,
        duration = 10,
        max_stack = 1,
    },
    -- Damage taken reduced.  Immune to Stun effects.
    icebound_fortitude = {
        id = 48792,
        duration = function () return 12 + ( 3 * talent.guile_of_gorefiend.rank ) end,
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    icy_clutch = {
        id = 50436,
        duration = 10,
        max_stack = 1,
        copy = { 50436, 50435, 50434 },
    },
    -- Your next Icy Touch, Howling Blast or Frost Strike will be a critical strike.
    killing_machine = {
        id = 51124,
        duration = 30,
        max_stack = 1,
    },
    -- Immune to Charm, Fear and Sleep.  Undead.
    lichborne = {
        id = 49039,
        duration = 10,
        max_stack = 1,
    },
    -- Hits by this target restore $s2% health.
    mark_of_blood = {
        id = 49005,
        duration = 20,
        max_stack = 1,
    },
    mind_freeze = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=47528)
        id = 47528,
        duration = 4,
        max_stack = 1,
    },
    -- Grants the ability to walk across water.
    path_of_frost = {
        id = 3714,
        duration = 600,
        max_stack = 1,
    },
    -- Any presence is applied.
    presence = {
        alias = { "blood_presence", "frost_presence", "unholy_presence" },
        aliasMode = "first",
        aliasType = "buff",
    },
    rune_strike = {
        duration = function () return swings.mainhand_speed end,
        max_stack = 1,
    },
    rune_strike_usable = {
        duration = 5,
        max_stack = 1,
    },
    -- Successful attacks generate runic power.
    scent_of_blood = {
        id = 50421,
        duration = 20,
        max_stack = 3,
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 5,
        max_stack = 1,
    },
    -- Runic Power is being fed to the Gargoyle.
    summon_gargoyle = {
        id = 61777,
        duration = 30,
        max_stack = 1,
        copy = { 61777, 50514, 49206 },
    },
    -- Armor increased by $s1%.  Strength increased by $s2%.
    unbreakable_armor = {
        id = 51271,
        duration = 20,
        max_stack = 1,
    },
    unholy_blight = {
        id = 49222,
        duration = 10,
        max_stack = 1,
    },
    -- Enraged.  Physical damage increased by $s1%.  Health equal to $s2% of maximum health lost every sec.
    unholy_frenzy = {
        id = 49016,
        duration = 30,
        max_stack = 1,
    },
    -- Attack speed increased $s1%.  Movement speed increased by $49772s1%.  Global cooldown on all abilities reduced by ${$m2/-1000}.1 sec.
    unholy_presence = {
        id = 48265,
        duration = 3600,
        max_stack = 1,
    },
    -- Healing improved by $s1%  Maximum health increased by $s2%
    vampiric_blood = {
        id = 55233,
        duration = function() return glyph.vampiric_blood.enabled and 15 or 10 end,
        max_stack = 1,
    },

    -- Death Runes
    death_rune_1 = {
        duration = 30,
        max_stack = 1,
    },
    death_rune_2 = {
        duration = 30,
        max_stack = 1,
    },
    death_rune_3 = {
        duration = 30,
        max_stack = 1,
    },
    death_rune_4 = {
        duration = 30,
        max_stack = 1,
    },
    death_rune_5 = {
        duration = 30,
        max_stack = 1,
    },
    death_rune_6 = {
        duration = 30,
        max_stack = 1,
    }
} )

local dodged_or_parried = 0

local misses = {
    DODGE = true,
    PARRY = true
}

spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, missType, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

    if destGUID == state.GUID and subtype:match( "_MISSED$" ) and misses[ missType ] then
        dodged_or_parried = GetTime()
    end
end )

local finish_rune_strike = setfenv( function()
    spend( 20, "runic_power" )
end, state )

spec:RegisterStateFunction( "start_rune_strike", function()
    removeBuff( "rune_strike_usable" )
    applyBuff( "rune_strike", swings.time_to_next_mainhand )
    state:QueueAuraExpiration( "rune_strike", finish_rune_strike, buff.rune_strike.expires )
end )

local GetRuneType, IsCurrentSpell = _G.GetRuneType, _G.IsCurrentSpell

spec:RegisterPet( "ghoul", 26125, "raise_dead", 3600 )

spec:RegisterHook( "reset_precast", function ()
    for i = 1, 6 do
        if GetRuneType( i ) == 4 then
            applyBuff( "death_rune_" .. i )
        end
    end

    if IsCurrentSpell( class.abilities.rune_strike.id ) then
        start_rune_strike()
        Hekili:Debug( "Starting Rune Strike, next swing in %.2f...", buff.rune_strike.remains )
    elseif IsUsableSpell( class.abilities.rune_strike.id ) and dodged_or_parried > 0 and now - dodged_or_parried < 5 then
        applyBuff( "rune_strike_usable", dodged_or_parried + 5 - now )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Surrounds the Death Knight in an Anti-Magic Shell, absorbing 75% of the damage dealt by harmful spells (up to a maximum of 50% of the Death Knight's health) and preventing application of harmful magical effects.  Damage absorbed by Anti-Magic Shell energizes the Death Knight with additional runic power.  Lasts 5 sec.
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 20,
        spendType = "runic_power",

        startsCombat = false,
        texture = 136120,

        toggle = "defensives",

        handler = function ()
            applyBuff( "antimagic_shell" )
        end,
    },


    -- Places a large, stationary Anti-Magic Zone that reduces spell damage done to party or raid members inside it by 75%.  The Anti-Magic Zone lasts for 10 sec or until it absorbs 14308 spell damage.
    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 1,
        spendType = "unholy_runes",

        talent = "antimagic_zone",
        startsCombat = false,
        texture = 237510,

        toggle = "defensives",

        handler = function ()
            applyBuff( "antimagic_zone" )
        end,
    },


    -- Summons an entire legion of Ghouls to fight for the Death Knight.  The Ghouls will swarm the area, taunting and fighting anything they can.  While channelling Army of the Dead, the Death Knight takes less damage equal to her Dodge plus Parry chance.
    army_of_the_dead = {
        id = 42650,
        cast = 0,
        cooldown = function() return 600 - ( 120 * talent.night_of_the_dead.rank ) end,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",
        spend2 = 1,
        spend2Type = "frost_runes",
        spend3 = 1,
        spend3Type = "blood_runes",

        gain = 15,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237511,

        toggle = "cooldowns",

        timeToReady = function()
            return max( blood_runes.time_to_1, frost_runes.time_to_1, unholy_runes.time_to_1 )
        end,

        start = function ()
            gain( 15, "runic_power" )
            applyBuff( "army_of_the_dead" )
        end,
    },


    -- Boils the blood of all enemies within 10 yards, dealing 180 to 220 Shadow damage.  Deals additional damage to targets infected with Blood Plague or Frost Fever.
    blood_boil = {
        id = 49941,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "blood_runes",

        startsCombat = true,
        texture = 237513,

        handler = function ()
        end,

        copy = { 49939, 49940, 49941 }
    },


    -- Strengthens the Death Knight with the presence of blood, increasing damage by 15% and healing the Death Knight by 4% of non-periodic damage dealt. Only one Presence may be active at a time.
    blood_presence = {
        id = 48266,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 1,
        spendType = "blood_runes",

        startsCombat = false,
        texture = 135770,

        nobuff = "blood_presence",

        handler = function ()
            removeBuff( "presence" )
            applyBuff( "blood_presence" )
        end,
    },


    -- Instantly strike the enemy, causing 40% weapon damage plus 306, total damage increased by 12.5% for each of your diseases on the target.
    blood_strike = {
        id = 45902,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "blood_runes",

        gain = 10,
        gainType = "runic_power",

        startsCombat = true,
        texture = 135772,

        handler = function ()
            if talent.reaping.rank == 3 then
                if blood_runes.current == 0 then applyBuff( "death_rune_1")
                else applyBuff( "death_rune_2" ) end
            end
            if talent.desolation.enabled then applyBuff( "desolation" ) end
        end,

        copy = { 49926, 49927, 49928, 49929, 49930 }
    },


    -- Immediately activates a Blood Rune and converts it into a Death Rune for the next 20 sec.  Death Runes count as a Blood, Frost or Unholy Rune.
    blood_tap = {
        id = 45529,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 487,
        spendType = "health",

        startsCombat = true,
        texture = 237515,

        handler = function ()
            gain( 1, "blood_runes" )
            applyBuff( "blood_tap" )
        end,
    },


    -- The Death Knight is surrounded by 3 whirling bones.  While at least 1 bone remains, she takes 20% less damage from all sources and deals 2% more damage with all attacks, spells and abilities.  Each damaging attack that lands consumes 1 bone.  Lasts 5 min.
    bone_shield = {
        id = 49222,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",

        gain = 10,
        gainType = "runic_power",

        talent = "bone_shield",
        startsCombat = false,
        texture = 132728,

        toggle = "defensives",

        handler = function ()
            applyBuff( "bone_shield", nil, glyph.bone_shield.enabled and 4 or 3 )
        end,
    },


    -- Shackles the target with frozen chains, reducing their movement by 95%, and infects them with Frost Fever.  The target regains 10% of their movement each second for 10 sec.
    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",

        gain = function() return 10 + ( 2.5 * talent.chill_of_the_grave.rank ) end,
        gainType = "runic_power",

        startsCombat = true,
        texture = 135834,

        handler = function ()
            applyDebuff( "target", "frost_fever" )
            applyDebuff( "target", "chains_of_ice" )
        end,
    },


    -- Cause a corpse to explode for 166 Shadow damage to all enemies within 10 yards.  Will use a nearby corpse if the target is not a corpse.  Does not affect mechanical or elemental corpses.
    corpse_explosion = {
        id = 49158,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 40,
        spendType = "runic_power",

        talent = "corpse_explosion",
        startsCombat = false,
        texture = 132099,

        -- TODO:  Determine if I can rely on the UI for usability of Corpse Explosion.

        handler = function ()
        end,
    },


    -- Summons a second rune weapon that fights on its own for 12 sec, doing the same attacks as the Death Knight but for 50% reduced damage.
    dancing_rune_weapon = {
        id = 49028,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 60,
        spendType = "runic_power",

        talent = "dancing_rune_weapon",
        startsCombat = false,
        texture = 135277,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "dancing_rune_weapon" )
        end,
    },


    -- Commands the target to attack you, but has no effect if the target is already attacking you.
    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 136088,

        handler = function ()
            applyDebuff( "target", "dark_command" )
        end,
    },


    -- Corrupts the ground targeted by the Death Knight, causing 62 Shadow damage every sec that targets remain in the area for 10 sec.  This ability produces a high amount of threat.
    death_and_decay = {
        id = 43265,
        cast = 0,
        cooldown = function () return 30 - ( 5 * talent.morbidity.rank ) end,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",
        spend2 = 1,
        spend2Type = "blood_runes",
        spend3 = 1,
        spend3Type = "frost_runes",

        gain = 15,
        gainType = "runic_power",

        startsCombat = false,
        texture = 136144,

        handler = function ()
            applyBuff( "death_and_decay" )
        end,

        copy = { 49936, 49937, 49938 }
    },


    -- Fire a blast of unholy energy, causing 443 Shadow damage to an enemy target or healing 665 damage from a friendly Undead target.
    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "runic_power",

        startsCombat = true,
        texture = 136145,

        handler = function ()
            if talent.unholy_blight.enabled then applyDebuff( "target", "unholy_blight" ) end
        end,

        copy = { 49892, 49893, 49894, 49895 }
    },


    -- Opens a gate which the Death Knight can use to return to Ebon Hold.
    death_gate = {
        id = 50977,
        cast = 10,
        cooldown = 60,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",

        startsCombat = false,
        texture = 135766,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Harness the unholy energy that surrounds and binds all matter, drawing the target toward the death knight and forcing the enemy to attack the death knight for 3 sec.
    death_grip = {
        id = 49576,
        cast = 0,
        cooldown = function () return 35 - ( 5 * talent.unholy_command.rank ) end,
        gcd = "off",

        startsCombat = true,
        texture = 237532,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "death_grip" )
        end,
    },


    -- Sacrifices an undead minion, healing the Death Knight for 40% of her maximum health.  This heal cannot be a critical.
    death_pact = {
        id = 48743,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 40,
        spendType = "runic_power",

        startsCombat = false,
        texture = 136146,

        toggle = "cooldowns",

        handler = function ()
            dismissPet( "ghoul" )
            gain( 0.4 * health.max, "health" )
        end,
    },


    -- A deadly attack that deals 75% weapon damage plus 223 and heals the Death Knight for 5% of her maximum health for each of her diseases on the target.
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",
        spend2 = 1,
        spend2Type = "unholy_runes",

        gain = function() return 15 + ( 2.5 * talent.dirge.rank ) end,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237517,

        healing = function()
            local base = ( 0.05 + ( 0.0125 * talent.improved_death_strike.rank ) ) * health.max
            local amt = 0
            if dot.frost_fever.ticking then amt = amt + base end
            if dot.blood_plague.ticking then amt = amt + base end
            if dot.crypt_fever.ticking then amt = amt + base end
            return amt
        end,

        handler = function ()
            health.current = min( health.max, health.current + action.death_strike.healing )
        end,
        copy = { 49999, 45463, 49923, 49924 }
    },


    -- When activated, makes your next Icy Touch, Howling Blast, Frost Strike or Obliterate a critical hit if used within 30 sec.
    deathchill = {
        id = 49796,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "deathchill",
        startsCombat = false,
        texture = 136213,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "deathchill" )
        end,
    },


    -- Empower your rune weapon, immediately activating all your runes and generating 25 runic power.
    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = -25,
        spendType = "runic_power",

        startsCombat = false,
        texture = 135372,

        toggle = "cooldowns",

        handler = function ()
            gain( 2, "blood_runes" )
            gain( 2, "frost_runes" )
            gain( 2, "unholy_runes" )
        end,
    },


    -- The death knight takes on the presence of frost, increasing Stamina by 8%, armor contribution from cloth, leather, mail and plate items by 60%, and reducing damage taken by 8%.  Increases threat generated.  Only one Presence may be active at a time.
    frost_presence = {
        id = 48263,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 1,
        spendType = "frost_runes",

        startsCombat = false,
        texture = 135773,

        nobuff = "frost_presence",

        handler = function ()
            removeBuff( "presence" )
            applyBuff( "frost_presence" )
        end,
    },


    -- Instantly strike the enemy, causing 55% weapon damage plus 48 as Frost damage.
    frost_strike = {
        id = 49143,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.frost_strike.enabled and 32 or 40 end,
        spendType = "runic_power",

        talent = "frost_strike",
        startsCombat = true,
        texture = 237520,

        handler = function ()
            removeStack( "killing_machine" )
            removeBuff( "deathchill" )
        end,
    },


    -- Grants your pet 25% haste for 30 sec and  heals it for 60% of its health over the duration.
    ghoul_frenzy = {
        id = 63560,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",

        gain = 10,
        gainType = "runic_power",

        talent = "ghoul_frenzy",
        startsCombat = false,
        texture = 132152,

        usable = function()
            if pet.ghoul.down then return false, "requires a living ghoul" end
            return true
        end,

        handler = function ()
            applyBuff( "ghoul_frenzy" )
        end,
    },


    -- Instantly strike the target and his nearest ally, causing 50% weapon damage plus 125 on the primary target, and 25% weapon damage plus 63 on the secondary target.  Each target takes 10% additional damage for each of your diseases active on that target.
    heart_strike = {
        id = 55050,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "blood_runes",

        gain = 10,
        gainType = "runic_power",

        talent = "heart_strike",
        startsCombat = true,
        texture = 135675,

        handler = function ()
            if glyph.heart_strike.enabled then applyDebuff( "target", "glyph_of_heart_strike" ) end
        end,
    },


    -- The Death Knight blows the Horn of Winter, which generates 10 runic power and increases total Strength and Agility of all party or raid members within 30 yards by 155.  Lasts 2 min.
    horn_of_winter = {
        id = 57623,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        startsCombat = false,
        texture = 134228,

        handler = function ()
            applyBuff( "horn_of_winter" )
        end,
    },


    -- Blast the target with a frigid wind dealing 198 to 214 Frost damage to all enemies within 10 yards.
    howling_blast = {
        id = 49184,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function()
            if buff.freezing_fog.up then return 0 end
            return 1
        end,
        spendType = "frost_runes",
        spend2 = function()
            if buff.freezing_fog.up then return 0 end
            return 1
        end,
        spend2Type = "unholy_runes",

        gain = function() return 15 + ( 2.5 * talent.chill_of_the_grave.rank ) end,
        gainType = "runic_power",

        talent = "howling_blast",
        startsCombat = true,
        texture = 135833,

        handler = function ()
            removeBuff( "deathchill" )
            removeBuff( "freezing_fog" )
            removeStack( "killing_machine" )

            if glyph.howling_blast.enabled then
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = active_enemies
            end
        end,
    },


    -- Purges the earth around the Death Knight of all heat.  Enemies within 10 yards are trapped in ice, preventing them from performing any action for 10 sec and infecting them with Frost Fever.  Enemies are considered Frozen, but any damage other than diseases will break the ice.
    hungering_cold = {
        id = 49203,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = function() return glyph.hungering_cold.enabled and 0 or 40 end,
        spendType = "runic_power",

        talent = "hungering_cold",
        startsCombat = true,
        texture = 135152,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "frost_fever" )
            active_dot.frost_fever = active_enemies
        end,
    },


    -- The Death Knight freezes her blood to become immune to Stun effects and reduce all damage taken by 30% plus additional damage reduction based on Defense for 12 sec.
    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 20,
        spendType = "runic_power",

        startsCombat = false,
        texture = 237525,

        toggle = "defensives",

        handler = function ()
            applyBuff( "icebound_fortitude" )
        end,
    },


    -- Chills the target for 227 to 245 Frost damage and  infects them with Frost Fever, a disease that deals periodic damage and reduces melee and ranged attack speed by 14% for 15 sec.  Very high threat when in Frost Presence.
    icy_touch = {
        id = 45477,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",

        gain = function() return 10 + ( 2.5 * talent.chill_of_the_grave.rank ) end,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237526,

        handler = function ()
            removeStack( "killing_machine" )
            applyDebuff( "frost_fever" )
        end,

        copy = { 49896, 49903, 49904, 49909 }
    },


    -- Draw upon unholy energy to become undead for 10 sec.  While undead, you are immune to Charm, Fear and Sleep effects.
    lichborne = {
        id = 49039,
        cast = 0,
        cooldown = 120,
        gcd = "off",


        talent = "lichborne",
        startsCombat = true,
        texture = 136187,

        toggle = "defensives",

        handler = function ()
            applyBuff( "lichborne" )
        end,
    },


    -- Place a Mark of Blood on an enemy.  Whenever the marked enemy deals damage to a target, that target is healed for 4% of its maximum health.  Lasts for 20 sec or up to 20 hits.
    mark_of_blood = {
        id = 49005,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 1,
        spendType = "blood_runes",

        talent = "mark_of_blood",
        startsCombat = true,
        texture = 132205,

        toggle = "defensives",

        handler = function ()
            applyDebuff( "target", "mark_of_blood", nil, 20 )
        end,
    },


    -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec.
    mind_freeze = {
        id = 47528,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        spend = function () return 20 - ( 10 * talent.endless_winter.rank ) end,
        spendType = "runic_power",

        startsCombat = true,
        texture = 237527,

        timeToReady = state.timeToInterrupt,
        debuff = "casting",

        toggle = "interrupts",

        handler = function ()
            interrupt()
        end,
    },


    -- A brutal instant attack that deals 80% weapon damage plus 467, total damage increased 12.5% per each of your diseases on the target, but consumes the diseases.
    obliterate = {
        id = 49020,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",
        spend2 = 1,
        spend2Type = "unholy_runes",

        gain = function() return 15 + ( 2.5 * talent.chill_of_the_grave.rank ) end,
        gainType = "runic_power",

        startsCombat = true,
        texture = 135771,

        handler = function ()
            removeBuff( "deathchill" )
            if talent.annihilation.rank < 3 then
                removeDebuff( "target", "frost_fever" )
                removeDebuff( "target", "blood_plague" )
                removeDebuff( "target", "crypt_fever" )
            end
        end,

        copy = { 51423, 51424, 51425 }
    },


    -- The Death Knight's freezing aura creates ice beneath her feet, allowing her and her party or raid to walk on water for 10 min.  Works while mounted.  Any damage will cancel the effect.
    path_of_frost = {
        id = 3714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",

        startsCombat = false,
        texture = 237528,

        handler = function ()
            applyBuff( "path_of_frost" )
        end,
    },


    -- Spreads existing Blood Plague and Frost Fever infections from your target to all other enemies within 10 yards.
    pestilence = {
        id = 50842,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "blood_runes",

        gain = 10,
        gainType = "runic_power",

        startsCombat = true,
        texture = 136182,

        handler = function ()
            if dot.frost_fever.ticking then
                active_dot.frost_fever = active_enemies
                if glyph.disease.enabled then applyDebuff( "target", "frost_fever" ) end
            end
            if dot.blood_plague.ticking then
                active_dot.blood_plague = active_enemies
                if glyph.disease.enabled then applyDebuff( "target", "blood_plague" ) end
            end

            if talent.reaping.rank == 3 then
                if blood_runes.current == 0 then applyBuff( "death_rune_1" )
                else applyBuff( "death_rune_2" ) end
            end
        end,
    },


    -- A vicious strike that deals 50% weapon damage plus 189 and infects the target with Blood Plague, a disease dealing Shadow damage over time.
    plague_strike = {
        id = 45462,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",

        gain = function() return 10 + ( 2.5 * talent.dirge.rank ) end,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237519,

        handler = function ()
            applyDebuff( "target", "blood_plague" )
            -- TODO: talent.desecration effect?
        end,

        copy = { 49917, 49918, 49919, 49920, 49921 }
    },


    -- Raises the corpse of a raid or party member to fight by your side.  The player will have control over the Ghoul for 5 min.
    raise_ally = {
        id = 61999,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        startsCombat = false,
        texture = 136143,

        handler = function ()
        end,
    },


    -- Raises a Ghoul to fight by your side.  If no humanoid corpse that yields experience or honor is available, you must supply Corpse Dust to complete the spell.  You can have a maximum of one Ghoul at a time.  Lasts 1 min.
    raise_dead = {
        id = 46584,
        cast = 0,
        cooldown = function() return 180 - ( 45 * talent.night_of_the_dead.rank ) - ( 60 * talent.master_of_ghouls.rank ) end,
        gcd = "spell",

        essential = true,

        startsCombat = false,
        texture = 136119,

        item = function()
            if glyph.raise_dead.enabled then return end
            return 37201
        end,
        bagItem = function()
            if glyph.raise_dead.enabled then return end
            return true
        end,

        toggle = function()
            if talent.master_of_ghouls.enabled then return end
            return "cooldowns"
        end,

        usable = function() return not pet.up, "cannot have a pet" end,

        handler = function ()
            summonPet( "ghoul" )
        end,
    },


    -- On next attack..
    rune_strike = {
        id = 56815,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "runic_power",

        startsCombat = true,
        texture = 237518,

        buff = "rune_strike_usable",
        nobuff = "rune_strike",

        handler = function()
            start_rune_strike()
        end
    },


    -- Converts 1 Blood Rune into 10% of your maximum health.
    rune_tap = {
        id = 48982,
        cast = 0,
        cooldown = function () return 60 - ( talent.improved_rune_tap.rank * 10 ) end,
        gcd = "off",

        spend = 1,
        spendType = "blood_runes",

        talent = "rune_tap",
        startsCombat = true,
        texture = 237529,

        toggle = "cooldowns",

        handler = function ()
            gain( ( 0.1 + 0.33 * talent.improved_rune_tap.rank ) * health.max, "health" )
        end,
    },


    -- An unholy strike that deals 70% of weapon damage as Physical damage plus 380.  In addition, for each of your diseases on your target, you deal an additional 12% of the Physical damage done as Shadow damage.
    scourge_strike = {
        id = 55090,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",
        spend2 = 1,
        spend2Type = "unholy_runes",

        gain = function() return 15 + ( 2.5 * talent.dirge.rank ) end,
        gainType = "runic_power",

        talent = "scourge_strike",
        startsCombat = true,
        texture = 237530,

        handler = function ()
            -- TODO: talent.desecration effect?
        end,
    },


    -- Strangulates an enemy, silencing them for 5 sec.  Non-player victim spellcasting is also interrupted for 3 sec.
    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = function() return glyph.strangulate.enabled and 100 or 120 end,
        gcd = "spell",

        spend = 1,
        spendType = "blood_runes",

        gain = 1,
        gainType = "runic_power",

        startsCombat = true,
        texture = 136214,

        toggle = "interrupts",

        timeToReady = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    -- A Gargoyle flies into the area and bombards the target with Nature damage modified by the Death Knight's attack power.  Persists for 30 sec.
    summon_gargoyle = {
        id = 49206,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 60,
        spendType = "runic_power",

        talent = "summon_gargoyle",
        startsCombat = false,
        texture = 132182,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "gargoyle" )
            applyBuff( "summon_gargoyle" )
        end,
    },


    -- Reinforces your armor with a thick coat of ice, increasing your armor by 25% and increasing your Strength by 20% for 20 sec.
    unbreakable_armor = {
        id = 51271,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 1,
        spendType = "frost_runes",

        gain = 10,
        gainType = "runic_power",

        talent = "unbreakable_armor",
        startsCombat = false,
        texture = 132388,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "unbreakable_armor" )
        end,
    },


    -- Induces a friendly unit into a killing frenzy for 30 sec.  The target is Enraged, which increases their physical damage by 20%, but causes them to lose health equal to 1% of their maximum health every second.
    unholy_frenzy = {
        id = 49016,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "unholy_frenzy",
        startsCombat = false,
        texture = 237512,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "unholy_frenzy" )
        end,
    },


    -- Infuses the death knight with unholy fury, increasing attack speed by 15%, movement speed by 15% and reducing the global cooldown on all abilities by 0.5 sec.  Only one Presence may be active at a time.
    unholy_presence = {
        id = 48265,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 1,
        spendType = "unholy_runes",

        startsCombat = false,
        texture = 135775,

        nobuff = "unholy_presence",

        handler = function ()
            removeBuff( "presence" )
            applyBuff( "unholy_presence" )
        end,
    },


    -- Temporarily grants the Death Knight 15% of maximum health and increases the amount of health generated through spells and effects by 35% for 10 sec.  After the effect expires, the health is lost.
    vampiric_blood = {
        id = 55233,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 1,
        spendType = "blood_runes",

        gain = 10,
        gainType = "runic_power",

        talent = "vampiric_blood",
        startsCombat = true,
        texture = 136168,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_blood" )
            health.max = health.max * 1.15
        end,
    },
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 47541,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    package = "Blood (IV)",
    usePackSelector = true
} )


spec:RegisterPack( "Blood (IV)", 20230411, [[Hekili:vEvBVTjsq4FlrvkXUoMaoV0xKDQUEN0PK7uQuDuV7taRH1MvgZYblX1vw7V9Bgadl4DDB(sIHz25LNzMNzX1X9z35Heb19Pj2tU2(ghhlhBhNjV3DUyxk1DEkjynzf8JeYg4VFoMZdL(dE4Bdrz7I5Kq0g58ISaqEKqKM)XRUA72TwSGDJFHYsYTc4BUAlxeVECqmjpNfC1c0oJdPer041jSvrIXcsY6XPVqhNXfebJNmoGZJd5BtYhtwWIzcgn3D(IcwS4He3f6d87GyjLg4(e8JiwyiTstAEG78NJy5s)0mgpJj2j9XNwqYPqcXtK(IiQ0)HaqW3WOw6VQGfsTCNhZYf5yws4u4FpvIAKamgrtd5Ghjj0lKgq25oNMqwetdD)SRacou123mpa8mnJrGZXfwlZ45cVL0xOzwcwWAwYkP)5sFuwjc5Lgtwvq7iCG0h99luVEMq6pQJivli9Ncjywb1RwbAcDdGNs)3k9Ni9h2MqP0CblMMaLtibUUxcCqlO46j4fbrQ50zvHUM0c0Axqm1tqYwrbWeWqW43yW4vXSxUiJTMQXb6Wg9E4wJ4FeLelISsdes)7L(3z3dCBaO7lbO97L(G3feazewWHZe1XNvT57aIvr4colgJI7mgf9DguLUU1kQUbTZ7mANSIewGxkFla5H0LSaMO0ytS73Pguftc85LKIyXrD0ByqZ8Ymk9h0xr382eL4MNL4Xx6TLLaY11g1EsbBtv35K(r6QmwQUUe91WPZWIyFB0ID3QMIf5upWiBY7LG31rPKiE8oejs(r)5AZvcnTpoaNeehbceOBmpuY8Q(ThsWurZ4vrZIenG2V)KShgziosygfsI8i0ovDY)mYhvzkh2ejXhmgNMzeQcKkbauqZTWobGtXBd57LneRcc1X3GOO9pZH6zi0ZVGg0XObRS0VqewPOInnpTu33guKb9wIgEBEILAxlYYexIuGRQpsPN1uK(v2EyE2WX84jqiUkExAuTffK0w(oSaQHgDyzuOIBnjkmJA3hXatwgd3Oo7HNRH)VZKNtNb5omK9u0mR7RMT8jN3P61oL6EE18m7adGYOUJbQVVMcQNGH95lPBkZLs982sjPWllP4tZOWDVwqAj513JxSCPfOBooqB1LlVk0oiS0SGHHEUCumE7Rj2FyYDwq4SLKLa9zaP6)8BF9PhE6p)O0x6)mETkgeHzqOVKdxt5cGE7cPFg9)kyzyJuoh3bqke8nWv6GxeerswbPS8X)MLaIUfS0VZtaVwk(I61W)lyfbx55d9MW7h489HW5Lp(qPRXJD9HXmPF5v6aXqEwiG1vUZBV4hcB8LmKU7nVr6xFL3)a7hK()v5LvXBa3O)q5JOE49qhBFZyhh0Rvok3QPcmA2vDHYlzlNDmWRCw4ekRIvFD39ROHQoARgTBqrPiV10jhlVQdg1ODmE6mygwrZMvLDEP6Qrvb9wQDjUoBguUVSAb4mh0zDxrEVJQbAxSuLw6PYo)uR42V3a745Ny1MAm0SRbdHZmyS97nS7AkSvOtgPUSPXIAxERCkvkMYof9RH67md11AQJrNylZ02nmhHtgrDJboqQJUFGHDh7332WD)D2dpxdX4m7EnwhWWotck8)hJdi7nggA47NoX2eCxno)8x(JV8rCShMW2uscvZa81c8HCMOO8RuTQu3q3ZN(0NuDJgI6syst6psZoHr62hmeNSBjCGHTM8V5Rs7l(4PSxt5(8b1tW9o4iLxREUPA(WZ3ozy)GQf468LCvCgMgdpkZ6mTzYqNSjU2sTFcxxcsOFTbaoqHnz)(Z08PHhLIQcpMjC616lJNUnUCHS7)p]] )

spec:RegisterPack( "Frost DK (IV)", 20221001, [[Hekili:DAvxVrQnu0FlRwP08XczystAsvsEOQQsjRuEzQ2hbBGldwdyJSndAQI8V9ETjDgddKnPVKmCTVN7X3po2XrX)D8QCQgIFz5ILlJwSikm6MLrxFx8k9UgiEvdnBdDn(doTg)7FjfkTH8NF3qo9PFCMD9DvcAUfhLOvMH7PuRBu)(Lx211fYY2fSfyCvyMO(YoHUAtqwfvPyzxwyXkihO6YGnC26s8JgvqZwiqk0untWdYeIQCrhxfqtzvmnduXRsBzv6N4XPtW9OBrI0azXVCdYewEo0VpqLnG9nsMqY07mKuQcYneb3qEkd)(hw6(lgY6wwoeINqPOGvHNRV(vd5)qWsAd57owBtf7D8mZZ29zzuq0IGfrMNnptZShgvyJeW0qkvFXdxMwje5jOffWZGP3tPqYtefjDmUgKFJv8qABrr4qZH28Jxuq)Qz88Kcja)d4BglgjArBwPfPVKl0HUsqsbSfHrZY2W4R9DOu0vHMssXkM2606QDnLHdmhcCAAfKFYhbWMk66wirPLSnWEw8wQWT2KEbknwbW0K1LzcZjZH0jwG2cjJ87cpZ(UD)YZ1sKJVTmWHASPZNoT8ujq3yp1juzTq6VypuAAJRA5(q2YbS)VvkbU((L(7wKI90GeBIN)82NZZzkaBu3NT)0zHth7HeWoevPfUxF9i38w9mFUb1nIoq6oujDaTrWN5KErFWgARLxkQ2nkLC1GSRcsWCs9GuEgTQkP)ZKkg2lAvJEGkGVzBLY0pezjXWs2Jr(i0tMdnEUbPnSkxJCnnRKXHW2M3T735JBSYAUqSEKd9jH(ymxS9Ldq(pomJx0PoMqXX5CiJUZnYul2AlOfwTNejutrzNhrzpSOQqx7LdxC3YBcJIx1rLCC3OQ5tyLtQTsDxzi9rXqSjtvO554vUFzLXXaJ)7f3vd9Bdfs95y8Q3AcJ)Jyngn7gpyzvM02sZOXR(IH0Zvd5edzaFnKhnKBpeGrNtexT1ybTTsFeB8K3(mCzMrMd4UxF0c1vZc17ic6oOFKqnmHIH7x)zmFQH6d4nqy1I31ZI3CY0wQpRASDXP1rnKlgSKV7gY94vHgY5gYeAQESFVGNL634xRpsSDuf)3M9CoHKupFoa(EXAls36h2dcZJI3D)K2Ir607ZQ)VY4NESVE6YgYRVobad2XzZLKJw85sCyrEc9CN9P00Dz6Roe8jU2WXIbZ17L(hLZJMFSEyhLtvbf96VuWQASh7X3G0l4L0)QwRKND7ZpZpZ1fhW3xJ3H18d0tDnY7OmeDTFoY)oMXPPbdodi0GnQTVP9ThzEK26WNL(HLxN7DP(Nl)fD0ajcTvxANPXhqh4E)SZC8)c]] )

spec:RegisterPack( "Frost DK (wowtbc.gg)", 20221003, [[Hekili:vAvxVTTnu0FlffWibPr(RMK1b78WWWaAkq2dQa7njrrDTfHLifiPQHhm4V9DjvSnPSuAhqrJc5LN73NtsMN89K4cIgsEDXSflMpB2YOzF5Zlx(usS(qdKe3qO7iBXp4KA8))lPqPnz)53S3COsqkSiOeTskEBPw3O(9Pt3l2RZPrB3IFPR2nLwruQ732Yka10nwiUVai6Y73XzBl1ttIZBzv6VYtYhmCwSa9rdqtE9r0jSIcOZsqrtI)EjtzYAKmHKPpyYS)worbfMS2gb3KPlbt25qYK9ps01Mmx4eLexXuALRoaBiTvA8ZxD1fcvZe8K4AgViDJeG)ftrGtYRGIK)irJbP1SlNetXiaKmss8hmzfcDKlxt3a)aKrAgDhJV9cUm6HuTOLwAHA5pdQ8kHOiTPISTfUgRUZtvAjBhyX7Z(zqlpxcKDwWtjYAHSxE8GVXnIUFgyXJbWPGum6Qv9m6PrZHUGx2YbveTvkbooeTYKT4cODMOjnwK(nF3jYRS4yhlc93xg1FJu7nztgVy6U8gtM1T)as7bHlCF7kGd1mahZoEmWCFuh1(TvhAkJkykaNrJEl6p57(XTeQjmUYb2dDV)QWVNn3I)ZRzcknRc4u3qX8z))6q3zY6IMRpVLxkQomqlD5fNd1nI9G0zu6EGGBJUOy(Orr)c2ZMS5UAtE7Mnr7yvvyJkTMqlzCiQT5IVkf7D3LJunANxgF5SVxw)l7LUQXLTS5JV26WsYQ)zHzWIAa(Hd7ZdwslfsEQyt6Egh9xOPASTlbQOoNCHmZlgpTGJ0A40HSfH0smC64E8aVlnNljrNPStyrfI98(l0NU8mh3PRLeCfifLbk6LObfeNmrkbjGlak5W7XBHeBhSLeKUFiyFC0Kahpz0u3OAeQbWOmD3K3SrR3Ni7EpotxJyprYX(nYu(vCzqQTR6l6igSstoTNiZlisT6slV8zDkBtuSb3DtI)4hnzNeEbN213C6MiLXzZV18I1SLMS)MQf5wclReQ5fZlDotfDEO4U1t7c4pzf1xp4CWWplSN(j2M1xpbm8lV0Uh((En6HnQFlEyRc7v2GCGo8ZZN9EvgV6gEM3FbG)XNfWT(4dJP549Gav6ZpAqXiVxDL6DaKHDlR5NuN9p8S6QRNDnx)Qf(wFrXnWvN1sSGms6ozSmAYnVr727HRczJpE0ZmFCUYUbfsNCZisORE44XXKox9WT36NOdOBnsz7UbKhVBiPXvl9DqGkGf6WC755tgrjYheFTIRXy9Vegxfi(QwJ5Sqa6XlQts(V)]] )

spec:RegisterPack( "Unholy (IV)", 20220926.3, [[Hekili:TAv0Ujoou0Vf0if1oDskqNYqxb9Hv7lTRuFHzNhtIXXawKehf7aIri)TVx7uc2b72z7oVurJTp3JV(CV3t8O4VhVidjiXVmE44XdFy8KOXJUF49XlehQiXlQq4TO1WpkrfWF)NYnS8dY0RE6hxRw8qodLPWGZAQXWg2iev8)42B3VFFefFiChHwYJWSIB3Ze5BdX5ioNIVTrduygbj2eUTKUEJimRIhwTJewZeibLvgIzS8m2(sEiAjnNkOeE8ILn0CXtLXlDs8Vof4sfbh)YeGm0Sms7ojCC8IVVHYLPv1uwnva3c1)TeXjzYuwPmvSHitFcdl8dfRLPRBOzKO4f5uUGRZuKvOMCb8Zx0zoewXZ4ff0YSKv1eYpHuaPeTmNKf)NXcGCQTD(llWqKj1uu8IbY0mMiAzoJLLuLJw3qIeu8wA5AzAaWgu9AIa(ubjrWsYOa5ECUmD0q9YRuPSKAsbst12voZOwat4IA6wIIi39EezvnJlswr2rQ)nYdqdaNQbVrXHV6LdVfbEZS0vYuvO2rs6bHmDw3sKssbODKPhpATDtuDU)RnsOeUGMtkX6S59EVj9H4riFOzkKMly7oX7(Pnz60ZXsxvKGanvgbJoOc4KFZPovMOhhMzXH2JDw)8nt9ohdL7R7Kx2s(PEPAlM1nLeOLqtDnPuitbbZW(HvGQui9GvmBkkyLjRb5i7qE)GcAoFrTcuVR3WAYJAQodN(lQA2YFQtWJSkOB4Ke48f8(HXF9mCTO4Kk2E4na6tqXu4YntvoCF)xwmJMRrZFr5YMvRI2WQltyRs2tlfkuHwHNHYErnC(RVaXNgXxfd1eUsjdjeTmPfYOEz42sEof2OwCSgd9j)SmDS(mN6nh19If9QsQ)J5POPPO)cNoajf6KOwNKSNGQaQvtqzh0X1RgQTSsxi4B12HoVTaeJaQMNOYwTVcjTt(SeMJ8xoAKMv5e1n6uJkNu)gpK(gF0fEjUZQZKJ8LMJF7xsQ2Hl0cAYqVk1PMvhNBQ3R6WQG1EeuVXIdn3PvVgRnkayQjG9HLOZtD9N37e2DP9ovvFXTwrzuW3MRn1Q(l19eRb)6H7Ykd)TceiySJiQaXHpOQ41TU4rN2ChO1ik02cE4YCnSLbn)4eX5TVdbWVu1jDhkVH8)zsIlpcZATi4EqJYIae)xRTYaEd2W4jST63CGKq85kwA4UlEXEuDjetOdZtGMVwOmUn(u7lzQ2MwK8zLMHTIQUzF6tY0tEw)lLIwM(3AZMklSDo9Uw(SAJQqfo8HWXtKplFUfvEuN(7M532tL8f6Q5xQfcEBrGBKTfeEaEWhb5ZQcfQVJyYneNukFr9Cn3416lALZCpcNaFIMJhVuWmB0WJhTekWxmEhaAy4Y28Zw9zu3Xb(IBWLH9X5Jggyfw1xmHVRzxh0UUQFeKpBPub9)1KyWvVA1S3bNz7a94rJTzItV9DTjZ6zavrp7D)4OGbTUz7DfNAcJzF9pYvSVGWcCBpOxgwy6RUm6YHUZTEf6vkzUKPhrfwMojn3xNBXlZHQbOQJ6WD4S5JU38a2g66Ab4We4LxwZghdC70lO9mVHlVzGdVppoWVZoZ4A4tQTTGvw)9nZf48HjWHxi4RUCcz)k6ioDzqB3ybx5iY34iU34kQZUZrHIRh5x3)JtC3mXBdmF1pWC7gbOfGzFDZT0JkJ)3p]] )



spec:RegisterPackSelector( "blood", "Blood (IV)", "|T135770:0|t Blood",
    "If you have spent more points in |T135770:0|t Blood than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "frost", "Frost DK (IV)", "|T135773:0|t Frost",
    "If you have spent more points in |T135773:0|t Frost than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "unholy", "Unholy (IV)", "|T135775:0|t Unholy",
    "If you have spent more points in |T135775:0|t Unholy than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )