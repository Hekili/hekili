if UnitClassBase( 'player' ) ~= 'DEATHKNIGHT' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 6 )

-- TODO
--- Unholy Presence reduces global cooldown by .5 seconds. (Unsure how to do this)
--- Deathstrike healing calculation

spec:RegisterResource( Enum.PowerType.RunicPower )


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
            local start, duration, ready = GetRuneCooldown( i );

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

-- butchery talent should generate 1 RP every 5/2.5 seconds depending on rank.
-- scent_of_blood should generate 10 RP on next attack.


-- Talents
spec:RegisterTalents( {
    abominations_might         = { 10281, 2, 53137, 53138        },
    annihilation               = { 2048 , 3, 51468, 51472, 51473 },
    anti_magic_zone            = { 2221 , 1, 51052               },
    blade_barrier              = { 2017 , 3, 49182, 49500, 49501 },
    bladed_armor               = { 1938 , 3, 48978, 49390, 49391 },
    blood_caked_blade          = { 5457 , 3, 49219, 49627, 49628 },
    blood_parasite             = { 1960 , 2, 49027, 49542        },
    bone_shield                = { 6703 , 1, 49222               },
    brittle_bones              = { 1980 , 2, 81327, 81328        },
    butchery                   = { 5372 , 2, 48979, 49483        },
    chilblains                 = { 2260 , 2, 50040, 50041        },
    chill_of_the_grave         = { 1981 , 2, 49149, 50115        },
    contagion                  = { 12119, 2, 91316, 91319        },
    crimson_scourge            = { 10289, 2, 81135, 81136        },
    dancing_rune_weapon        = { 5426 , 1, 49028               },
    dark_transformation        = { 2085 , 1, 63560               },
    death_advance              = { 15322, 2, 96269, 96270        },
    desecration                = { 5467 , 2, 55666, 55667        },
    ebon_plaguebringer         = { 5489 , 2, 51099, 51160        },
    endless_winter             = { 1971 , 2, 49137, 49657        },
    epidemic                   = { 1963 , 3, 49036, 49562, 81334 },
    hand_of_doom               = { 11270, 2, 85793, 85794        },
    howling_blast              = { 1989 , 1, 49184               },
    hungering_cold             = { 1999 , 1, 49203               },
    icy_reach                  = { 10147, 2, 55061, 55062        },
    improved_blood_presence    = { 5410 , 2, 50365, 50371        },
    improved_blood_tap         = { 12223, 2, 94553, 94555        },
    improved_death_strike      = { 5412 , 3, 62905, 62908, 81138 },
    improved_frost_presence    = { 2029 , 2, 50384, 50385        },
    improved_icy_talons        = { 2223 , 1, 55610               },
    improved_unholy_presence   = { 2013 , 2, 50391, 50392        },
    killing_machine            = { 2044 , 3, 51123, 51127, 51128 },
    lichborne                  = { 2215 , 1, 49039               },
    magic_suppression          = { 5469 , 3, 49224, 49610, 49611 },
    mangle                     = { 5499 , 1, 33917               },
    merciless_combat           = { 1993 , 2, 49024, 49538        },
    might_of_the_frozen_wastes = { 7571 , 3, 81330, 81332, 81333 },
    morbidity                  = { 5443 , 3, 48963, 49564, 49565 },
    nerves_of_cold_steel       = { 2022 , 3, 49226, 50137, 50138 },
    on_a_pale_horse            = { 11275, 1, 51986               },
    pillar_of_frost            = { 1979 , 1, 51271               },
    rage_of_rivendare          = { 5435 , 3, 51745, 51746, 91323 },
    resilient_infection        = { 7572 , 2, 81338, 81339        },
    rime                       = { 1992 , 3, 49188, 56822, 59057 },
    rune_tap                   = { 5384 , 1, 48982               },
    runic_corruption           = { 5451 , 2, 51459, 51462        },
    runic_power_mastery        = { 2031 , 3, 49455, 50147, 91145 },
    sanguine_fortitude         = { 10299, 2, 81125, 81127        },
    scarlet_fever              = { 10285, 2, 81131, 81132        },
    scent_of_blood             = { 5380 , 3, 49004, 49508, 49509 },
    shadow_infusion            = { 5447 , 3, 48965, 49571, 49572 },
    sudden_doom                = { 5414 , 3, 49018, 49529, 49530 },
    summon_gargoyle            = { 5495 , 1, 49206               },
    threat_of_thassarian       = { 2284 , 3, 65661, 66191, 66192 },
    toughness                  = { 5431 , 3, 49042, 49786, 49787 },
    unholy_blight              = { 5461 , 1, 49194               },
    unholy_command             = { 5445 , 2, 49588, 49589        },
    unholy_frenzy              = { 5408 , 1, 49016               },
    vampiric_blood             = { 5416 , 1, 55233               },
    virulence                  = { 1932 , 3, 48962, 49567, 49568 },
    will_of_the_necropolis     = { 1959 , 3, 52284, 81163, 81164 },


    -- Blood Specific Talents
    veteran_of_the_third_war = { 6713, 1, 50029 },
} )


-- Glyphs
-- Unused note means it is unused by hekili, not that it unused by players.
spec:RegisterGlyphs( {
    [58623] = "antimagic_shell",
    [59332] = "blood_boil", 
    [58640] = "blood_tap", 
    [58620] = "chains_of_ice", 
    [96279] = "dark_succor", 
    [58629] = "death_and_decay", 
    [63333] = "death_coil", 
    [62259] = "death_grip",
    [58677] = "deaths_embrace",
    [58647] = "frost_strike",
    [58680] = "horn_of_winter",
    [63335] = "howling_blast",
    [63331] = "hungering_cold",
    [58657] = "pestilence",
    [58676] = "vampiric_blood",
} )
    -- [58673] = "bone_shield", -- 15% movement speed unused.
    -- [63330] = "dancing_rune_weapon", -- threat improvement unused.
    -- [60200] = "death_gate", -- death gate cooldown, unused
    -- [59336] = "death_strike", -- Increases damage based on RP. unused.
    -- [58616] = "heart_strike", -- damage of heart_strike by 30%. unused.
    -- [58631] = "icy_touch", -- damage buff, unused
    -- [58671] = "obliterate", -- damage buff, unused
    -- [59307] = "path_of_frost", -- fall damaged, unused
    -- [58635] = "pillar_of_frost", -- cc immune unused.
    -- [58669] = "rune_strike", -- damage buff, unused
    -- [59327] = "rune_tap", -- %5 health to party unused.
    -- [58618] = "strangulate", -- unused


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
        max_stack = 6,
    },
    -- Slowed by frozen chains.
    chains_of_ice = {
        id = 45524,
        duration = 10,
        max_stack = 1,
    },
    -- proc for blood boil
    crimson_scourge = {
        id = 81141,
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
        duration = function() return glyph.death_and_decay.enabled and 15 or 10 end,
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
    -- Standing upon unholy ground.   Movement speed is reduced by $s1%.
    desecration = {
        id = 68766,
        duration = 20,
        max_stack = 1,
        copy = { 68766, 55741 },
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
        duration = function () return 21 + ( 4 * talent.epidemic.rank ) end,
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
    horn_of_winter = {
        id = 57330,
        duration = function() return  glyph.horn_of_winter.enabled and 180 or 120 end,
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
        duration = function() return glyph.vampiric_blood.enabled and 40 or 25 end,
        max_stack = 1,
    },

    will_of_the_necropolis = {
        id = 81164,
        copy = {52284, 81163},
        max_stack = 1,
        duration = 8,
    }

    -- -- Death Runes
    -- death_rune_1 = {
    --     duration = 30,
    --     max_stack = 1,
    -- },
    -- death_rune_2 = {
    --     duration = 30,
    --     max_stack = 1,
    -- },
    -- death_rune_3 = {
    --     duration = 30,
    --     max_stack = 1,
    -- },
    -- death_rune_4 = {
    --     duration = 30,
    --     max_stack = 1,
    -- },
    -- death_rune_5 = {
    --     duration = 30,
    --     max_stack = 1,
    -- },
    -- death_rune_6 = {
    --     duration = 30,
    --     max_stack = 1,
    -- }
} )

local GetRuneType, IsCurrentSpell = _G.GetRuneType, _G.IsCurrentSpell

spec:RegisterPet( "ghoul", 26125, "raise_dead", 3600 )

-- spec:RegisterHook( "reset_precast", function ()
--     for i = 1, 6 do
--         if GetRuneType( i ) == 4 then
--             applyBuff( "death_rune_" .. i )
--         end
--     end
-- end )


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
        cooldown = 600,
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
            gain( 30, "runic_power" )
            applyBuff( "army_of_the_dead" )
        end,
    },


    -- Boils the blood of all enemies within 10 yards, dealing 180 to 220 Shadow damage.  Deals additional damage to targets infected with Blood Plague or Frost Fever.
    blood_boil = {
        id = 48721,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            return buff.crimson_scourge.up and 0 or 1
        end,
        spendType = "blood_runes",

        gain = 10,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237513,

        handler = function ()
            removeBuff( "crimson_scourge" )
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

        copy = { 49926, 49927, 49928, 49929, 49930 }
    },


    -- Immediately activates a Blood Rune and converts it into a Death Rune for the next 20 sec.  Death Runes count as a Blood, Frost or Unholy Rune.
    blood_tap = {
        id = 45529,
        cast = 0,
        cooldown = function() return  60 - (15 * talent.improved_blood_tap.rank) end,
        gcd = "off",

        spend = function() return glyph.improved_blood_tap.enabled and 0 or (0.06 * health.max) end, -- technically 6% of base health
        spendType = "health",

        startsCombat = true,
        texture = 237515,

        handler = function ()
            -- gain( 1, "blood_runes" ) -- TODO we actually gain a death rune
            -- I believe the precast check will catch this.
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
        texture = 458717,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bone_shield")
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
        cooldown = 30,
        gcd = "spell",

        spend = 1,
        spendType = "unholy_runes",

        gain = 10,
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

    -- TODO this changed in cata. now heals based on % of damage lost
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "frost_runes",
        spend2 = 1,
        spend2Type = "unholy_runes",

        gain = 20,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237517,

        healing = function()
            -- TODO needs damage taken code?
            local base = ( 0.07) * health.max
            local amt = base * ( 1 + (.15 * talent.improved_death_strike.rank ))
            return amt
        end,

        handler = function ()
            health.current = min( health.max, health.current + action.death_strike.healing )
        end,
        copy = { 49999, 45463, 49923, 49924 }
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
        startsCombat = true,
        texture = 135675,

        handler = function ()
            if glyph.heart_strike.enabled then applyDebuff( "target", "glyph_of_heart_strike" ) end
        end,
    },


    -- The Death Knight blows the Horn of Winter, which generates 10 runic power and increases total Strength and Agility of all party or raid members within 30 yards by 155.  Lasts 2 min.
    horn_of_winter = {
        id = 57330,
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
        cooldown = 180,
        gcd = "off",

        spend = 0,
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
            if talent.annihilation.rank < 3 then
                removeDebuff( "target", "frost_fever" )
                removeDebuff( "target", "blood_plague" )
                removeDebuff( "target", "crypt_fever" )
            end
        end,

        copy = { 51423, 51424, 51425 }
    },

    outbreak = {
        id = 77575,
        cast = 0,
        cooldown = function() return spec.blood and 30 or 60 end,
        gcd = "spell",

        startsCombat = true,
        texture = 348565,

        handler = function ()
            applyDebuff("target", "frost_fever" )
            applyDebuff("target", "blood_plague")
        end,
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

        gain = 10,
        gainType = "runic_power",

        startsCombat = true,
        texture = 237519,

        handler = function ()
            applyDebuff( "target", "blood_plague" )
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


    rune_strike = {
        id = 56815,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = true,
        texture = 237518,
    },


    -- Converts 1 Blood Rune into 10% of your maximum health.
    rune_tap = {
        id = 48982,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 1,
        spendType = "blood_runes",

        talent = "rune_tap",
        startsCombat = true,
        texture = 237529,

        toggle = "cooldowns",

        handler = function ()
            gain((0.1  * health.max), "health" )
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

        gain = 20,
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
        cooldown = function() return  120 - (30 * talent.hand_of_doom.rank) end,
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

        spend = 0,
        spendType = "runic_power",

        talent = "vampiric_blood",
        startsCombat = true,
        texture = 136168,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_blood" )
            if not ( glyph.vampiric_blood.enabled ) then
                health.max = health.max * 1.15
            end
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

    package = "Blood (Beta)",
    usePackSelector = true,
} )


spec:RegisterPack( "Blood (Beta)", 20240523, [[Hekili:nFvtVnUnq0FllwGIKUzvLSZxfiEpe0dnUa5Ic6rjstnYIWYKcuuRRlwWF7DOKIfLIuC822G9qIT5mZJZm8npkffe9uuycvdrpoZF2L(xnBUN)Tb((3gfQ3xarHfu2g6A8lc6w8)3NlLjgYz3dA65wR7ZL0elkLYkfd9ikCvfpx)GiA1iq7F9LZrFlaw0JxhfMXtsGgpHswu4tz8sdX(h1qA3AdrMI)MP5sHHKZl1O5uPYq(DydpN7ffwVOnjOsa)4X6YQjclYuDwmvKeNam6(OqqqxLdjr3hPXCZ6A3kHmfxdkonk8dgsIu7TYwXXf501vGNMZ2WfRnKFAeJkivbLzwOmKV9ndPfHuLSuhNcFfuVaaxBoX3L9Yk9kfq3yZ15tMRhBBMSioRPZ(viEaegYN6zYfbd5odrRQG4whabSLd4XYpBiZmKZ7s)cOuZZbbYmWc4YJ1ShPg6WIZ2hRLvSmluxDmOgRKDYR61Jl1k(M6u76jXdBrnyPQeqPhRsPaHUU)0KUVC9krMmF)qdNx33M1LeW2c5oqv7x8oGwGlIPYntMkOJCwCDqEjqkNX1ny63bAnyD11Ttc2QQ0up8NBlLI4sgo(Ug8Qk6qQPQxj55wG(1jbkdO56mVcgMmFXqU2FaZ6a7anoVh7O)oe47o2IOQ0pxi9Mz12z6uAvU(fZ6B54yoofb)n8MNZtK7eoBRujILPX74c0(HPUdzS02DZ4qEYGn4YEAoubd5B9oz77(08x325DlmKB8hQLnG1(SXQsigbzB5GTAA(0ihqbO6mcpZEE0Juf389yRwBJIBCZvcwn3xLO9JNq60C5twhQH0EQ19RiefeCmMHRstdmEU8cpRB1TguzOnKT0)A0o1B5EIPzFbtpu9DOufm91BV7sWbtFt1jkBgC1BwuRqbm52vuRSw9c7OkbEaGZZpGPPsdj1xV2aw7Jc5zwAJuMYTK9p(rdP9r0(n7HLH8hc(6mSYp7b2Ed5pbUO8CZsRF4tLn)Z(x95zZnlnlBaT8tl(fhnu3L7lmEbpDHv401dhTr3LhrlSNzhsLf1o5V7wCJF)u7GcN7Id0MUWQkTafLUOrhBrGf1(kDFjWfGNvgS(9H)TkvhBcBcDk385G(YHeAmaDcONgYRxfhVX)oRUm4K0TkMwdXnOrMGTb)FTKrpI(HjC7onHGqVzhNXEhgThYspCqC4fugA(hk6zBo19y9ncbFhN7))92hdt2tBE65k80NPAJ89Mq2UTN(WtBGNgBE0Go13ayiA9VwKwPXlBIcFsMKKxF)N92WO)5d]] )

spec:RegisterPack( "Frost DK (IV)", 20221001, [[Hekili:DAvxVrQnu0FlRwP08XczystAsvsEOQQsjRuEzQ2hbBGldwdyJSndAQI8V9ETjDgddKnPVKmCTVN7X3po2XrX)D8QCQgIFz5ILlJwSikm6MLrxFx8k9UgiEvdnBdDn(doTg)7FjfkTH8NF3qo9PFCMD9DvcAUfhLOvMH7PuRBu)(Lx211fYY2fSfyCvyMO(YoHUAtqwfvPyzxwyXkihO6YGnC26s8JgvqZwiqk0untWdYeIQCrhxfqtzvmnduXRsBzv6N4XPtW9OBrI0azXVCdYewEo0VpqLnG9nsMqY07mKuQcYneb3qEkd)(hw6(lgY6wwoeINqPOGvHNRV(vd5)qWsAd57owBtf7D8mZZ29zzuq0IGfrMNnptZShgvyJeW0qkvFXdxMwje5jOffWZGP3tPqYtefjDmUgKFJv8qABrr4qZH28Jxuq)Qz88Kcja)d4BglgjArBwPfPVKl0HUsqsbSfHrZY2W4R9DOu0vHMssXkM2606QDnLHdmhcCAAfKFYhbWMk66wirPLSnWEw8wQWT2KEbknwbW0K1LzcZjZH0jwG2cjJ87cpZ(UD)YZ1sKJVTmWHASPZNoT8ujq3yp1juzTq6VypuAAJRA5(q2YbS)VvkbU((L(7wKI90GeBIN)82NZZzkaBu3NT)0zHth7HeWoevPfUxF9i38w9mFUb1nIoq6oujDaTrWN5KErFWgARLxkQ2nkLC1GSRcsWCs9GuEgTQkP)ZKkg2lAvJEGkGVzBLY0pezjXWs2Jr(i0tMdnEUbPnSkxJCnnRKXHW2M3T735JBSYAUqSEKd9jH(ymxS9Ldq(pomJx0PoMqXX5CiJUZnYul2AlOfwTNejutrzNhrzpSOQqx7LdxC3YBcJIx1rLCC3OQ5tyLtQTsDxzi9rXqSjtvO554vUFzLXXaJ)7f3vd9Bdfs95y8Q3AcJ)Jyngn7gpyzvM02sZOXR(IH0Zvd5edzaFnKhnKBpeGrNtexT1ybTTsFeB8K3(mCzMrMd4UxF0c1vZc17ic6oOFKqnmHIH7x)zmFQH6d4nqy1I31ZI3CY0wQpRASDXP1rnKlgSKV7gY94vHgY5gYeAQESFVGNL634xRpsSDuf)3M9CoHKupFoa(EXAls36h2dcZJI3D)K2Ir607ZQ)VY4NESVE6YgYRVobad2XzZLKJw85sCyrEc9CN9P00Dz6Roe8jU2WXIbZ17L(hLZJMFSEyhLtvbf96VuWQASh7X3G0l4L0)QwRKND7ZpZpZ1fhW3xJ3H18d0tDnY7OmeDTFoY)oMXPPbdodi0GnQTVP9ThzEK26WNL(HLxN7DP(Nl)fD0ajcTvxANPXhqh4E)SZC8)c]] )

spec:RegisterPack( "Frost DK (wowtbc.gg)", 20221003, [[Hekili:vAvxVTTnu0FlffWibPr(RMK1b78WWWaAkq2dQa7njrrDTfHLifiPQHhm4V9DjvSnPSuAhqrJc5LN73NtsMN89K4cIgsEDXSflMpB2YOzF5Zlx(usS(qdKe3qO7iBXp4KA8))lPqPnz)53S3COsqkSiOeTskEBPw3O(9Pt3l2RZPrB3IFPR2nLwruQ732Yka10nwiUVai6Y73XzBl1ttIZBzv6VYtYhmCwSa9rdqtE9r0jSIcOZsqrtI)EjtzYAKmHKPpyYS)worbfMS2gb3KPlbt25qYK9ps01Mmx4eLexXuALRoaBiTvA8ZxD1fcvZe8K4AgViDJeG)ftrGtYRGIK)irJbP1SlNetXiaKmss8hmzfcDKlxt3a)aKrAgDhJV9cUm6HuTOLwAHA5pdQ8kHOiTPISTfUgRUZtvAjBhyX7Z(zqlpxcKDwWtjYAHSxE8GVXnIUFgyXJbWPGum6Qv9m6PrZHUGx2YbveTvkbooeTYKT4cODMOjnwK(nF3jYRS4yhlc93xg1FJu7nztgVy6U8gtM1T)as7bHlCF7kGd1mahZoEmWCFuh1(TvhAkJkykaNrJEl6p57(XTeQjmUYb2dDV)QWVNn3I)ZRzcknRc4u3qX8z))6q3zY6IMRpVLxkQomqlD5fNd1nI9G0zu6EGGBJUOy(Orr)c2ZMS5UAtE7Mnr7yvvyJkTMqlzCiQT5IVkf7D3LJunANxgF5SVxw)l7LUQXLTS5JV26WsYQ)zHzWIAa(Hd7ZdwslfsEQyt6Egh9xOPASTlbQOoNCHmZlgpTGJ0A40HSfH0smC64E8aVlnNljrNPStyrfI98(l0NU8mh3PRLeCfifLbk6LObfeNmrkbjGlak5W7XBHeBhSLeKUFiyFC0Kahpz0u3OAeQbWOmD3K3SrR3Ni7EpotxJyprYX(nYu(vCzqQTR6l6igSstoTNiZlisT6slV8zDkBtuSb3DtI)4hnzNeEbN213C6MiLXzZV18I1SLMS)MQf5wclReQ5fZlDotfDEO4U1t7c4pzf1xp4CWWplSN(j2M1xpbm8lV0Uh((En6HnQFlEyRc7v2GCGo8ZZN9EvgV6gEM3FbG)XNfWT(4dJP549Gav6ZpAqXiVxDL6DaKHDlR5NuN9p8S6QRNDnx)Qf(wFrXnWvN1sSGms6ozSmAYnVr727HRczJpE0ZmFCUYUbfsNCZisORE44XXKox9WT36NOdOBnsz7UbKhVBiPXvl9DqGkGf6WC755tgrjYheFTIRXy9Vegxfi(QwJ5Sqa6XlQts(V)]] )

spec:RegisterPack( "Unholy (IV)", 20220926.3, [[Hekili:TAv0Ujoou0Vf0if1oDskqNYqxb9Hv7lTRuFHzNhtIXXawKehf7aIri)TVx7uc2b72z7oVurJTp3JV(CV3t8O4VhVidjiXVmE44XdFy8KOXJUF49XlehQiXlQq4TO1WpkrfWF)NYnS8dY0RE6hxRw8qodLPWGZAQXWg2iev8)42B3VFFefFiChHwYJWSIB3Ze5BdX5ioNIVTrduygbj2eUTKUEJimRIhwTJewZeibLvgIzS8m2(sEiAjnNkOeE8ILn0CXtLXlDs8Vof4sfbh)YeGm0Sms7ojCC8IVVHYLPv1uwnva3c1)TeXjzYuwPmvSHitFcdl8dfRLPRBOzKO4f5uUGRZuKvOMCb8Zx0zoewXZ4ff0YSKv1eYpHuaPeTmNKf)NXcGCQTD(llWqKj1uu8IbY0mMiAzoJLLuLJw3qIeu8wA5AzAaWgu9AIa(ubjrWsYOa5ECUmD0q9YRuPSKAsbst12voZOwat4IA6wIIi39EezvnJlswr2rQ)nYdqdaNQbVrXHV6LdVfbEZS0vYuvO2rs6bHmDw3sKssbODKPhpATDtuDU)RnsOeUGMtkX6S59EVj9H4riFOzkKMly7oX7(Pnz60ZXsxvKGanvgbJoOc4KFZPovMOhhMzXH2JDw)8nt9ohdL7R7Kx2s(PEPAlM1nLeOLqtDnPuitbbZW(HvGQui9GvmBkkyLjRb5i7qE)GcAoFrTcuVR3WAYJAQodN(lQA2YFQtWJSkOB4Ke48f8(HXF9mCTO4Kk2E4na6tqXu4YntvoCF)xwmJMRrZFr5YMvRI2WQltyRs2tlfkuHwHNHYErnC(RVaXNgXxfd1eUsjdjeTmPfYOEz42sEof2OwCSgd9j)SmDS(mN6nh19If9QsQ)J5POPPO)cNoajf6KOwNKSNGQaQvtqzh0X1RgQTSsxi4B12HoVTaeJaQMNOYwTVcjTt(SeMJ8xoAKMv5e1n6uJkNu)gpK(gF0fEjUZQZKJ8LMJF7xsQ2Hl0cAYqVk1PMvhNBQ3R6WQG1EeuVXIdn3PvVgRnkayQjG9HLOZtD9N37e2DP9ovvFXTwrzuW3MRn1Q(l19eRb)6H7Ykd)TceiySJiQaXHpOQ41TU4rN2ChO1ik02cE4YCnSLbn)4eX5TVdbWVu1jDhkVH8)zsIlpcZATi4EqJYIae)xRTYaEd2W4jST63CGKq85kwA4UlEXEuDjetOdZtGMVwOmUn(u7lzQ2MwK8zLMHTIQUzF6tY0tEw)lLIwM(3AZMklSDo9Uw(SAJQqfo8HWXtKplFUfvEuN(7M532tL8f6Q5xQfcEBrGBKTfeEaEWhb5ZQcfQVJyYneNukFr9Cn3416lALZCpcNaFIMJhVuWmB0WJhTekWxmEhaAy4Y28Zw9zu3Xb(IBWLH9X5Jggyfw1xmHVRzxh0UUQFeKpBPub9)1KyWvVA1S3bNz7a94rJTzItV9DTjZ6zavrp7D)4OGbTUz7DfNAcJzF9pYvSVGWcCBpOxgwy6RUm6YHUZTEf6vkzUKPhrfwMojn3xNBXlZHQbOQJ6WD4S5JU38a2g66Ab4We4LxwZghdC70lO9mVHlVzGdVppoWVZoZ4A4tQTTGvw)9nZf48HjWHxi4RUCcz)k6ioDzqB3ybx5iY34iU34kQZUZrHIRh5x3)JtC3mXBdmF1pWC7gbOfGzFDZT0JkJ)3p]] )



spec:RegisterPackSelector( "blood", "Blood (Beta)", "|T135770:0|t Blood",
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