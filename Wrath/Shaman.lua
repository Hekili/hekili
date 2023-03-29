if UnitClassBase( 'player' ) ~= 'SHAMAN' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 7 )

local LastConsumedStackTS, LastSwingTimestamp, last_consumed_stack_ts = 0,0,0
spec:RegisterResource( Enum.PowerType.Mana, {
    mainhand = {
        swing = "mainhand",
        aura = "flurry",

        last = function ()
            local swing = state.combat == 0 and state.now or state.swings.mainhand
            local t = state.query_time

            return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
        end,

        interval = "mainhand_speed",

        stop = function () return state.swings.mainhand == 0 end,
        value = function( now )
            local secsSinceLastConsume = now - last_consumed_stack_ts
            if secsSinceLastConsume >= 0.5 and state.buff.flurry.stack > 0 then
                state.removeStack("flurry")
            end
            return 0
        end,
    },

    offhand = {
        swing = "offhand",
        aura = "flurry",

        last = function ()
            local swing = state.combat == 0 and state.now or state.swings.offhand
            local t = state.query_time

            return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
        end,

        interval = "offhand_speed",

        stop = function () return state.swings.offhand == 0 end,
        value = function( now )
            local secsSinceLastConsume = now - last_consumed_stack_ts
            if secsSinceLastConsume >= 0.5 and state.buff.flurry.stack > 0  then
                state.removeStack("flurry")
            end
            return 0
        end,
    }
} )

-- Talents
spec:RegisterTalents( {
    ancestral_awakening       = {  2061, 3, 51556, 51557, 51558 },
    ancestral_healing         = {   581, 3, 16176, 16235, 16240 },
    ancestral_knowledge       = {   614, 5, 17485, 17486, 17487, 17488, 17489 },
    anticipation              = {   601, 3, 16254, 16271, 16272 },
    astral_shift              = {  2050, 3, 51474, 51478, 51479 },
    blessing_of_the_eternals  = {  2060, 2, 51554, 51555 },
    booming_echoes            = {  2262, 2, 63370, 63372 },
    call_of_flame             = {   561, 3, 16038, 16160, 16161 },
    call_of_thunder           = {   562, 1, 16041 },
    cleanse_spirit            = {  2084, 1, 51886 },
    concussion                = {   563, 5, 16035, 16105, 16106, 16107, 16108 },
    convection                = {   564, 5, 16039, 16109, 16110, 16111, 16112 },
    dual_wield                = {  1690, 1, 30798 },
    dual_wield_specialization = {  1692, 3, 30816, 30818, 30819 },
    earth_shield              = {  1698, 1,   974 },
    earthen_power             = {  2056, 2, 51523, 51524 },
    earths_grasp              = {  2101, 2, 16043, 16130 },
    elemental_devastation     = {  1645, 3, 30160, 29179, 29180 },
    elemental_focus           = {   574, 1, 16164 },
    elemental_fury            = {   565, 5, 16089, 60184, 60185, 60187, 60188 },
    elemental_mastery         = {   573, 1, 16166 },
    elemental_oath            = {  2049, 2, 51466, 51470 },
    elemental_precision       = {  1685, 3, 30672, 30673, 30674 },
    elemental_reach           = {  1641, 2, 28999, 29000 },
    elemental_warding         = {  1640, 3, 28996, 28997, 28998 },
    elemental_weapons         = {   611, 3, 16266, 29079, 29080 },
    enhancing_totems          = {   610, 3, 16259, 16295, 52456 },
    eye_of_the_storm          = {  1642, 3, 29062, 29064, 29065 },
    feral_spirit              = {  2058, 1, 51533 },
    flurry                    = {   602, 5, 16256, 16281, 16282, 16283, 16284 },
    focused_mind              = {  1695, 3, 30864, 30865, 30866 },
    frozen_power              = {  2263, 2, 63373, 63374 },
    guardian_totems           = {   609, 2, 16258, 16293 },
    healing_focus             = {   587, 3, 16181, 16230, 16232 },
    healing_grace             = {  1646, 3, 29187, 29189, 29191 },
    healing_way               = {  1648, 3, 29206, 29205, 29202 },
    improved_chain_heal       = {  1697, 2, 30872, 30873 },
    improved_earth_shield     = {  2059, 2, 51560, 51561 },
    improved_fire_nova        = {   567, 2, 16086, 16544 },
    improved_ghost_wolf       = {   605, 2, 16262, 16287 },
    improved_healing_wave     = {   586, 5, 16182, 16226, 16227, 16228, 16229 },
    improved_reincarnation    = {   589, 2, 16184, 16209 },
    improved_shields          = {   607, 3, 16261, 16290, 51881 },
    improved_stormstrike      = {  2054, 2, 51521, 51522 },
    improved_water_shield     = {   583, 3, 16180, 16196, 16198 },
    improved_windfury_totem   = {  1647, 2, 29192, 29193 },
    lava_flows                = {  2051, 3, 51480, 51481, 51482 },
    lava_lash                 = {  2249, 1, 60103 },
    lightning_mastery         = {   721, 5, 16578, 16579, 16580, 16581, 16582 },
    lightning_overload        = {  1686, 3, 30675, 30678, 30679 },
    maelstrom_weapon          = {  2057, 5, 51528, 51529, 51530, 51531, 51532 },
    mana_tide_totem           = {   590, 1, 16190 },
    mental_dexterity          = {  2083, 3, 51883, 51884, 51885 },
    mental_quickness          = {  1691, 3, 30812, 30813, 30814 },
    natures_blessing          = {  1696, 3, 30867, 30868, 30869 },
    natures_guardian          = {  1699, 5, 30881, 30883, 30884, 30885, 30886 },
    natures_swiftness         = {   591, 1, 16188 },
    purification              = {   592, 5, 16178, 16210, 16211, 16212, 16213 },
    restorative_totems        = {   588, 3, 16187, 16205, 16206 },
    reverberation             = {   575, 5, 16040, 16113, 16114, 16115, 16116 },
    riptide                   = {  2064, 1, 61295 },
    shamanism                 = {  2252, 5, 62097, 62098, 62099, 62100, 62101 },
    shamanistic_focus         = {   617, 1, 43338 },
    shamanistic_rage          = {  1693, 1, 30823 },
    spirit_weapons            = {   616, 1, 16268 },
    static_shock              = {  2055, 3, 51525, 51526, 51527 },
    storm_earth_and_fire      = {  2052, 3, 51483, 51485, 51486 },
    stormstrike               = {   901, 1, 17364 },
    thundering_strikes        = {   613, 5, 16255, 16302, 16303, 16304, 16305 },
    thunderstorm              = {  2053, 1, 51490 },
    tidal_focus               = {   593, 5, 16179, 16214, 16215, 16216, 16217 },
    tidal_force               = {   582, 1, 55198 },
    tidal_mastery             = {   594, 5, 16194, 16218, 16219, 16220, 16221 },
    tidal_waves               = {  2063, 5, 51562, 51563, 51564, 51565, 51566 },
    totem_of_wrath            = {  1687, 1, 30706 },
    totemic_focus             = {   595, 5, 16173, 16222, 16223, 16224, 16225 },
    toughness                 = {   615, 5, 16252, 16306, 16307, 16308, 16309 },
    unleashed_rage            = {  1689, 3, 30802, 30808, 30809 },
    unrelenting_storm         = {  1682, 3, 30664, 30665, 30666 },
    weapon_mastery            = {  1643, 3, 29082, 29084, 29086 },
} )


-- Auras
spec:RegisterAuras( {
    -- Reduces physical damage taken by $s1%.
    ancestral_fortitude = {
        id = 16237,
        duration = 15,
        max_stack = 1,
        copy = { 16177, 16236, 16237 },
    },
    -- Damage reduced.
    astral_shift = {
        id = 52179,
        duration = 3600,
        tick_time = 1,
        max_stack = 1,
    },
    -- Enabled Cleanse Spirit.
    can_cleanse_spirit = {
        alias = { "dispellable_poison", "dispellable_disease", "dispellable_curse" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Enable Cleanse Toxins.
    can_cure_toxins = {
        alias = { "dispellable_poison", "dispellable_disease" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Your next $n damage or healing spells have their mana cost reduced by $s1%.
    clearcasting = {
        id = 16246,
        duration = 15,
        max_stack = 2,
    },
    -- Reduces casting or channeling time lost when damaged by $s2% and attacks heal the shielded target for $s1.
    earth_shield = {
        id = 49284,
        duration = 600,
        max_stack = 1,
        copy = { 974, 32593, 32594, 49283, 49284 },
    },
    -- Time between attacks increased by $w1%.
    earth_shock = {
        id = 49231,
        duration = 8,
        max_stack = 1,
        copy = { 8042, 8044, 8045, 8046, 10412, 10413, 10414, 25454, 49230, 49231 },
    },
    -- Increases your chance to get a critical strike with melee attacks by $s1%.
    elemental_devastation = {
        id = 30165,
        duration = 10,
        max_stack = 1,
        copy = { 29177, 29178, 30165 },
    },
    -- Makes LB, CL, LvB instant.
    elemental_mastery = {
        id = 16166,
        duration = 30,
        max_stack = 1,
    },
    -- Casting speed of all spells increased by $s1%.
    elemental_mastery_haste = {
        id = 64701,
        duration = 15,
        max_stack = 1,
    },
    -- Cannot move while using Farsight.
    far_sight = {
        id = 6196,
        duration = 60,
        max_stack = 1,
    },
    feral_spirit = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=51533)
        id = 51533,
        duration = 45,
        max_stack = 1,
    },
    -- $s2 Fire damage every $t2 seconds.
    flame_shock = {
        id = 49233,
        duration = 18,
        max_stack = 1,
        copy = { 8050, 8052, 8053, 10447, 10448, 25457, 29228, 49232, 49233 },
    },
    flurry = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=16284)
        id = 16284,
        duration = 3600,
        max_stack = 1,
        copy = { 16284, 16283, 16282, 16281, 16280, 16279, 16278, 16277, 16257, 16256 },
    },
    -- Movement slowed to $s1% of normal speed.
    frost_shock = {
        id = 49236,
        duration = function() return glyph.frost_shock.enabled and 10 or 8 end,
        max_stack = 1,
        copy = { 8056, 8058, 10472, 10473, 25464, 49235, 49236 },
    },
    frost_resistance = {
        id = 58744,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases movement speed by $s2%$?s59289[ and regenerates $59289s1% of your maximum health every 5 sec][].  Effects that reduce movement speed may not bring you below your normal movement speed.
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        max_stack = 1,
    },
    grounding_totem_effect = {
        id = 8178,
        duration = 3600,
        max_stack = 1,
    },
    -- Cannot attack or cast spells.
    hex = {
        id = 51514,
        duration = 30,
        max_stack = 1,
    },
    -- Causes $49279s1 Nature damage to attacker on hit.  $n charges.
    lightning_shield = {
        id = 49281,
        duration = 600,
        max_stack = function() return 3 + talent.static_shock.rank * 2 end,
        copy = { 324, 325, 905, 945, 8134, 8788, 10431, 10432, 25469, 25472, 49280, 49281 },
    },
    -- Reduces the cast time of your next Lightning Bolt, Chain Lightning, Lesser Healing Wave, Healing Wave, Chain Heal, or Hex spell by $s1%.
    maelstrom_weapon = {
        id = 53817,
        duration = 30,
        max_stack = 5,
    },
    -- Your next Nature spell with a casting time less than 10 secs will be an instant cast spell.
    natures_swiftness = {
        id = 16188,
        duration = 3600,
        max_stack = 1,
    },
    -- Heals $s2 every $t2 seconds.  Increases caster's Chain Heal by $s3%.
    riptide = {
        id = 61301,
        duration = function() return glyph.riptide.enabled and 21 or 15 end,
        max_stack = 1,
        copy = { 61295, 61299, 61300, 61301, 66053 },
    },
    -- All damage taken reduced by $s2% and successful melee attacks have a chance to regenerate mana equal to $s1% of your attack power.
    shamanistic_rage = {
        id = 30823,
        duration = 15,
        max_stack = 1,
    },
    -- Any elemental shield is applied.
    shield = {
        alias = { "lightning_shield", "earth_shield", "water_shield" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Increases Nature damage taken from the Shaman by $s1%.
    stormstrike = {
        id = 17364,
        duration = 12,
        max_stack = 4,
    },
    -- Increases the critical effect chance of your Healing Wave, Lesser Healing Wave and Chain Heal by $s1%. Each critical heal reduces the chance by 20%. Lasts $55166d.
    tidal_force = {
        id = 55198,
        duration = 20,
        max_stack = 1,
    },
    -- Cast time of next Healing Wave reduced by $s1%.  Critical effect chance of next Lesser Healing Wave increased by $s2%.
    tidal_waves = {
        id = 53390,
        duration = 15,
        max_stack = 1,
    },
    -- Attack power party buff.
    unleashed_rage = {
        id = 30809,
        duration = 3600,
        max_stack = 1,
    },
    -- Able to breathe underwater.
    water_breathing = {
        id = 131,
        duration = 600,
        max_stack = 1,
    },
    -- $s2 mana per 5 sec.  Attacks and spells used against you restore $57961s1 mana.  $n charges.
    water_shield = {
        id = 57960,
        duration = 600,
        max_stack = function() return glyph.water_shield.enabled and 4 or 3 end,
        copy = { 24398, 33736, 52127, 52129, 52131, 52134, 52136, 52138, 57960 },
    },
    -- Allows walking over water.
    water_walking = {
        id = 546,
        duration = 600,
        max_stack = 1,
    },

    -- Totems.
    earthbind_totem = {
        duration = 45,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 2 )

            if up and texture == 136102 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    earth_elemental_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 2 )

            if up and texture == 136024 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    stoneclaw_totem = {
        duration = 15,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 2 )

            if up and texture == 136097 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    stoneskin_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 2 )

            if up and texture == 136098 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    strength_of_earth_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 2 )

            if up and texture == 136023 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    tremor_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 2 )

            if up and texture == 136108 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    earth_totem = {
        alias = { "earthbind_totem", "stoneclaw_totem", "stoneskin_totem", "strength_of_earth_totem", "earth_elemental_totem", "tremor_totem" },
        aliasMode = "first",
        aliasType = "buff",
    },

    flametongue_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 1 )

            if up and texture == 136040 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    magma_totem = {
        duration = 20,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 1 )

            if up and texture == 135826 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    searing_totem = {
        duration = 50,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 1 )

            if up and texture == 135825 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    frost_resistance_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 1 )

            if up and texture == 135866 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    fire_elemental_totem = {
        duration = 300,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 1 )

            if up and texture == 135790 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    totem_of_wrath = {
        duration = 300,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 1 )

            if up and texture == 135829 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    fire_totem = {
        alias = { "flametongue_totem", "magma_totem", "searing_totem", "frost_resistance_totem", "fire_elemental_totem", "totem_of_wrath" },
        aliasMode = "first",
        aliasType = "buff",
    },

    fire_resistance_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 3 )

            if up and texture == 135832 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    cleansing_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 3 )

            if up and texture == 136019 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    healing_stream_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 3 )

            if up and texture == 135127 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    mana_spring_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 3 )

            if up and texture == 136053 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    mana_tide_totem = {
        duration = 120,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 3 )

            if up and texture == 135861 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    water_totem = {
        alias = { "fire_resistance_totem", "cleansing_totem", "healing_stream_totem", "mana_spring_totem", "mana_tide_totem" },
        aliasMode = "first",
        aliasType = "buff",
    },

    grounding_totem = {
        duration = 45,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 4 )

            if up and texture == 136039 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    nature_resistance_totem = {
        duration = 300,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 4 )

            if up and texture == 136061 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    sentry_totem = {
        duration = 300,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 4 )

            if up and texture == 136082 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    windfury_totem = {
        duration = 300,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 4 )

            if up and texture == 136114 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    wrath_of_air_totem = {
        duration = 300,
        max_stack = 1,
        generate = function( t )
            local up, name, start, duration, texture = GetTotemInfo( 4 )

            if up and texture == 136092 then
                t.count = 1
                t.expires = start + duration
                t.applied = start
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    air_totem = {
        alias = { "grounding_totem", "nature_resistance_totem", "sentry_totem", "windfury_totem", "wrath_of_air_totem" },
        aliasMode = "first",
        aliasType = "buff",
    },
} )


-- Glyphs
spec:RegisterGlyphs( {
    [58058] = "astral_recall",
    [55437] = "chain_heal",
    [55449] = "chain_lightning",
    [63279] = "earth_shield",
    [55439] = "earthliving_weapon",
    [55452] = "elemental_mastery",
    [63271] = "feral_spirit",
    [55455] = "fire_elemental_totem",
    [55450] = "fire_nova",
    [55447] = "flame_shock",
    [55451] = "flametongue_weapon",
    [55443] = "frost_shock",
    [59289] = "ghost_wolf",
    [55456] = "healing_stream_totem",
    [55440] = "healing_wave",
    [63291] = "hex",
    [55454] = "lava",
    [55444] = "lava_lash",
    [55438] = "lesser_healing_wave",
    [55453] = "lightning_bolt",
    [55448] = "lightning_shield",
    [55441] = "mana_tide",
    [58059] = "renewed_life",
    [63273] = "riptide",
    [55442] = "shocking",
    [63298] = "stoneclaw_totem",
    [55446] = "stormstrike",
    [58135] = "arctic_wolf",
    [58134] = "black_wolf",
    [63270] = "thunder",
    [62132] = "thunderstorm",
    [63280] = "totem_of_wrath",
    [58055] = "water_breathing",
    [55436] = "water_mastery",
    [58063] = "water_shield",
    [58057] = "water_walking",
    [55445] = "windfury_weapon",
} )


spec:RegisterStateExpr( "windfury_mainhand", function () return false end )
spec:RegisterStateExpr( "windfury_offhand", function () return false end )
spec:RegisterStateExpr( "flametongue_mainhand", function () return false end )
spec:RegisterStateExpr( "flametongue_offhand", function () return false end )
spec:RegisterStateExpr( "frostbrand_mainhand", function () return false end )
spec:RegisterStateExpr( "frostbrand_offhand", function () return false end )
spec:RegisterStateExpr( "rockbiter_mainhand", function () return false end )
spec:RegisterStateExpr( "rockbiter_offhand", function () return false end )
spec:RegisterStateExpr( "mainhand_imbued", function () return false end )
spec:RegisterStateExpr( "offhand_imbued", function () return false end )

local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo

local enchant_ids = {
    [283]  = "windfury",
    [284]  = "windfury",
    [525]  = "windfury",
    [1669] = "windfury",
    [2636] = "windfury",
    [5]    = "flametongue",
    [4]    = "flametongue",
    [3]    = "flametongue",
    [523]  = "flametongue",
    [1665] = "flametongue",
    [1666] = "flametongue",
    [2634] = "flametongue",
    [2]    = "frostbrand",
    [12]   = "frostbrand",
    [524]  = "frostbrand",
    [1667] = "frostbrand",
    [1668] = "frostbrand",
    [2635] = "frostbrand",
    [3023] = "rockbiter",
    [3026] = "rockbiter",
    [3028] = "rockbiter",
    [3031] = "rockbiter",
    [3034] = "rockbiter",
    [3037] = "rockbiter",
    [3040] = "rockbiter", -- ???
    [3043] = "rockbiter"  -- ???
}

spec:RegisterStateExpr( "mainhand_remains", function()
    local next_swing, real_swing, pseudo_swing = 0, 0, 0
    if now == query_time then
        real_swing = nextMH - now
        next_swing = real_swing > 0 and real_swing or 0
    else
        if query_time <= nextMH then
            pseudo_swing = nextMH - query_time
        else
            pseudo_swing = (query_time - nextMH) % mainhand_speed
        end
        next_swing = pseudo_swing
    end
    return next_swing
end)

spec:RegisterStateExpr( "offhand_remains", function()
    local next_swing, real_swing, pseudo_swing = 0, 0, 0
    if now == query_time then
        real_swing = nextOH - now
        next_swing = real_swing > 0 and real_swing or 0
    else
        if query_time <= nextOH then
            pseudo_swing = nextOH - query_time
        else
            pseudo_swing = (query_time - nextOH) % offhand_speed
        end
        next_swing = pseudo_swing
    end
    return next_swing
end)

spec:RegisterStateExpr( "nextswing_remains", function()
    return max(min(mainhand_remains, offhand_remains), 0)
end)

spec:RegisterStateExpr( "nextswing_speed", function()
    return mainhand_remains < offhand_remains and mainhand_speed or offhand_speed
end)

spec:RegisterStateExpr( "skipswing_remains", function()
    return max(max(mainhand_remains, offhand_remains) - nextswing_remains, 0)
end)

spec:RegisterStateExpr( "skipswing_speed", function()
    return mainhand_remains < offhand_remains and offhand_speed or mainhand_speed
end)

local MainhandHasSpellpower = false
spec:RegisterStateExpr( "mainhand_has_spellpower", function() return MainhandHasSpellpower end )

local AURA_APPLIED_EVENTS = {
    SPELL_AURA_APPLIED      = 1,
    SPELL_AURA_APPLIED_DOSE = 1,
    SPELL_AURA_REFRESH      = 1,
}

local AURA_REMOVED_EVENTS = {
    SPELL_AURA_REMOVED      = 1,
    SPELL_AURA_REMOVED_DOSE = 1,
}

spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, ...)
    if sourceGUID ~= state.GUID then
        return
    end

    local timestamp = GetTime()
    if subtype == "SWING_DAMAGE" then
        LastSwingTimestamp = timestamp
    end

    if spellID == state.buff.flurry.id then
        local _, amount = select(1, ...)
        local secsSinceLastConsume = timestamp - LastConsumedStackTS
        if AURA_APPLIED_EVENTS[subtype] then
            if secsSinceLastConsume > 0.5 then
                LastConsumedStackTS = timestamp
            end
        end

        if AURA_REMOVED_EVENTS[subtype] then
            LastConsumedStackTS = timestamp
        end
    end

end, false )

local reset_gear = function()
    MainhandHasSpellpower = false
end

local update_gear = function(slotId, itemId)
    if slotId == 16 then
        local mhStats = GetItemStats("item:"..itemId)
        local mhSpellPower = mhStats and mhStats["ITEM_MOD_SPELL_POWER"]
        MainhandHasSpellpower = mhSpellPower and tonumber(mhSpellPower) > 0
    end
end

spec:RegisterHook( "reset_precast", function()
    windfury_mainhand = nil
    windfury_offhand = nil
    flametongue_mainhand = nil
    flametongue_offhand = nil
    frostbrand_mainhand = nil
    frostbrand_offhand = nil
    rockbiter_mainhand = nil
    rockbiter_offhand = nil
    mainhand_imbued = nil
    offhand_imbued = nil

    local mh, mh_expires, _, mh_id, oh, oh_expires, _, oh_id = GetWeaponEnchantInfo()

    if mh then
        mainhand_imbued = true

        mh = enchant_ids[ mh ]

        if mh == "windfury" then windfury_mainhand = true
        elseif mh == "flametongue" then flametongue_mainhand = true
        elseif mh == "frostbrand" then frostbrand_mainhand = true
        elseif mh == "rockbiter" then rockbiter_mainhand = true end
    end

    if oh then
        offhand_imbued = true

        oh = enchant_ids[ oh ]

        if oh == "windfury" then windfury_offhand = true
        elseif oh == "flametongue" then flametongue_offhand = true
        elseif oh == "frostbrand" then frostbrand_offhand = true
        elseif oh == "rockbiter" then rockbiter_offhand = true end
    end

    last_consumed_stack_ts = LastConsumedStackTS
    state.swings.mh_pseudo_speed = state.swings.mainhand_speed
end )

spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]

    if ability and ability.totem then
        summonTotem( ability.totem, totem[ action ].remains )
    end
end )

Hekili:RegisterGearHook( reset_gear, update_gear )

-- Abilities
spec:RegisterAbilities( {
    -- Returns the spirit to the body, restoring a dead target to life with 1800 health and 1365 mana.  Cannot be cast when in combat.
    ancestral_spirit = {
        id = 2008,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.72,
        spendType = "mana",

        startsCombat = false,
        texture = 136077,

        handler = function ()
        end,

        copy = { 20609, 20610, 20776, 20777, 25590, 49277 },
    },


    -- Yanks the caster through the twisting nether back to Dalaran.  Speak to an Innkeeper in a different place to change your home location.
    astral_recall = {
        id = 556,
        cast = 10,
        cooldown = function() return glyph.astral_recall.enabled and 450 or 900 end,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 136010,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Increases melee, ranged, and spell casting speed by 30% for all party and raid members.  Lasts 40 sec.    After the completion of this effect, those affected will become Sated and unable to benefit from Bloodlust again for 10 min.
    bloodlust = {
        id = 2825,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.26,
        spendType = "mana",

        startsCombat = false,
        texture = 136012,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bloodlust" )
            applyDebuff( "player", "sated" )
        end,

        copy = { "heroism", 32182 }
    },


    -- Simultaneously places up to 4 totems specified in the Totem Bar. Can call different totems than Call of the Elements.
    call_of_the_ancestors = {
        id = 66843,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 310731,

        handler = function ()
            for i = 138, 141 do
                local _, totemSpell = GetActionInfo( i )
                local spellName = totemSpell and GetSpellInfo( totemSpell )
                local ability = spellName and class.abilities[ spellName ]
                if ability then
                    ability.handler()
                end
            end
        end,
    },


    -- Simultaneously places up to 4 totems specified in the Totem Bar.
    call_of_the_elements = {
        id = 66842,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 310730,

        handler = function ()
            for i = 134, 137 do
                local _, totemSpell = GetActionInfo( i )
                local spellName = totemSpell and GetSpellInfo( totemSpell )
                local ability = spellName and class.abilities[ spellName ]
                if ability then
                    ability.handler()
                end
            end
        end,
    },


    -- Simultaneously places up to 4 totems specified in the Totem Bar. Can call different totems than Call of the Elements or Call of the Ancestors.
    call_of_the_spirits = {
        id = 66844,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 310732,

        handler = function ()
            for i = 142, 145 do
                local _, totemSpell = GetActionInfo( i )
                local spellName = totemSpell and GetSpellInfo( totemSpell )
                local ability = spellName and class.abilities[ spellName ]
                if ability then
                    ability.handler()
                end
            end
        end,
    },


    -- Heals the friendly target for 1055 to 1205, then jumps to heal additional nearby targets.  If cast on a party member, the heal will only jump to other party members.  Each jump reduces the effectiveness of the heal by 40%.  Heals 3 total targets.
    chain_heal = {
        id = 1064,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.19,
        spendType = "mana",

        startsCombat = false,
        texture = 136042,

        handler = function ()
            removeBuff( "riptide" )
        end,

        copy = { 10622, 10623, 25422, 25423, 55458, 55459 },
    },


    -- Hurls a lightning bolt at the enemy, dealing 982 to 1123 Nature damage and then jumping to additional nearby enemies.  Each jump reduces the damage by 30%.  Affects 3 total targets.
    chain_lightning = {
        id = 421,
        cast = function ()
            if buff.elemental_mastery.up then return 0 end
            return 2 * (1 - (buff.maelstrom_weapon.stack * 2) / 10) * haste
        end,
        cooldown = 6,
        gcd = "spell",

        spend = function ()
            return ( buff.clearcasting.up and 0.6 or 1 ) * 0.26
        end,
        spendType = "mana",

        startsCombat = true,
        texture = 136015,

        handler = function ()
            removeBuff( "elemental_mastery" )
            removeBuff( "maelstrom_weapon" )
            removeStack( "clearcasting" )
            removeDebuffStack( "target", "stormstrike" )
        end,

        copy = { 930, 2860, 10605, 25439, 25442, 49270, 49271 },
    },

    -- Cleanse the spirit of a friendly target, removing 1 poison effect, 1 disease effect, and 1 curse effect.
    cleanse_spirit = {
        id = 51886,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        talent = "cleanse_spirit",
        startsCombat = false,
        texture = 236288,

        buff = "can_cleanse_spirit",

        handler = function ()
            removeBuff( "can_cleanse_spirit" )
        end,
    },


    -- Summons a Cleansing Totem with 5 health at the feet of the caster that attempts to remove 1 disease and 1 poison effect from party members within 30 yards every 3 seconds.  Lasts 5 min.
    cleansing_totem = {
        id = 8170,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 136019,

        totem = "water",

        handler = function ()
            removeBuff( "water_totem" )
            summonTotem( "cleansing_totem" )
            applyBuff( "cleansing_totem" )
        end,
    },

    -- Cures 1 poison effect and 1 disease effect on a friendly target.
    cure_toxins = {
        id = 526,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 136067,

        buff = "can_cleanse_toxins",

        handler = function ()
            removeBuff( "can_cleanse_toxins" )
        end,
    },


    -- Summon an elemental totem that calls forth a greater earth elemental to protect the caster and his allies.  Lasts 2 min.
    earth_elemental_totem = {
        id = 2062,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 0.24,
        spendType = "mana",

        startsCombat = false,
        texture = 136024,

        toggle = "cooldowns",

        totem = "earth",

        handler = function ()
            removeBuff( "earth_totem" )
            summonTotem( "earth_elemental_totem" )
            applyBuff( "earth_elemental_totem" )
        end,
    },


    -- Protects the target with an earthen shield, reducing casting or channeling time lost when damaged by 30%  and causing attacks to heal the shielded target for 150.  This effect can only occur once every few seconds.  6 charges.  Lasts 10 min.  Earth Shield can only be placed on one target at a time and only one Elemental Shield can be active on a target at a time.
    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "earth_shield",
        startsCombat = false,
        texture = 136089,

        handler = function ()
            removeBuff( "shield" )
            applyBuff( "earth_shield" )
        end,
    },


    -- Instantly shocks the target with concussive force, causing 862 to 909 Nature damage and reducing melee attack speed by 10% for 8 sec.
    earth_shock = {
        id = 8042,
        cast = 0,
        cooldown = 6,
        gcd = function() return glyph.shocking.enabled and "totem" or "spell" end,

        spend = function ()
            return ( buff.clearcasting.up and 0.6 or 1 ) * 0.18
        end,

        spendType = "mana",

        startsCombat = true,
        texture = 136026,

        handler = function ()
            applyDebuff( "target", "earth_shock" )
            setCooldown( "flame_shock", 6 )
            setCooldown( "frost_shock", 6 )
            removeDebuffStack( "target", "stormstrike" )
        end,

        copy = { 8044, 8045, 8046, 10412, 10413, 10414, 25454, 49230, 49231 },
    },


    -- Summons an Earthbind Totem with 5 health at the feet of the caster for 45 sec that slows the movement speed of enemies within 10 yards.
    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 136102,

        totem = "earth",

        handler = function ()
            removeBuff( "earth_totem" )
            summonTotem( "earthbind_totem" )
            applyBuff( "earthbind_totem" )
        end,
    },


    -- Imbue the Shaman's weapon with earthen life. Increases healing done by 150 and each heal has a 20% chance to proc Earthliving on the target, healing an additional 652 over 12 sec. Lasts 30 minutes.
    earthliving_weapon = {
        id = 51730,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 237575,

        usable = function() return ( equipped.mainhand and not mainhand_imbued ) or ( equipped.offhand and not offhand_imbued ), "must have an unimbued weapon" end,

        handler = function ()
            if equipped.mainhand and not mainhand_imbued then
                mainhand_imbued = true
                earthliving_mainhand = true
            elseif equipped.offhand and not offhand_imbued then
                offhand_imbued = true
                earthliving_offhand = true
            end
        end,

        copy = { 51988, 51991, 51992, 51993, 51994 },
    },


    -- When activated, your next Lightning Bolt, Chain Lightning or Lava Burst spell becomes an instant cast spell. In addition, you gain 15% spell haste for 15 sec. Elemental Mastery shares a cooldown with Nature's Swiftness.
    elemental_mastery = {
        id = 16166,
        cast = 0,
        cooldown = function() return glyph.elemental_mastery.enabled and 150 or 180 end,
        gcd = "spell",

        talent = "elemental_mastery",
        startsCombat = false,
        texture = 136115,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "elemental_mastery" )
            applyBuff( "elemental_mastery_haste" )
            haste = haste + 0.15
        end,
    },


    -- Changes the caster's viewpoint to the targeted location.  Lasts 1 min.  Only useable outdoors.
    far_sight = {
        id = 6196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 136034,

        handler = function ()
            applyBuff( "far_sight" )
        end,
    },


    -- Summons two Spirit Wolves under the command of the Shaman, lasting 45 sec.
    feral_spirit = {
        id = 51533,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "feral_spirit",
        startsCombat = false,
        texture = 237577,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "spirit_wolf" )
        end,
    },


    -- Summons an elemental totem that calls forth a greater fire elemental to rain destruction on the caster's enemies.  Lasts 2 min.
    fire_elemental_totem = {
        id = 2894,
        cast = 0,
        cooldown = function() return glyph.fire_elemental_totem.enabled and 300 or 600 end,
        gcd = "totem",

        spend = 0.23,
        spendType = "mana",

        startsCombat = true,
        texture = 135790,

        toggle = "cooldowns",

        totem = "fire",

        handler = function ()
            removeBuff( "fire_totem" )
            summonTotem( "fire_elemental_totem" )
            applyBuff( "fire_elemental_totem" )
        end,
    },


    -- Causes the shaman's active Fire totem to emit a wave of flames, inflicting 893 to 997 Fire damage to enemies within 10 yards of the totem.
    fire_nova = {
        id = 1535,
        cast = 0,
        cooldown = function() return glyph.fire_nova.enabled and 7 or 10 end,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = true,
        texture = 135824,

        buff = "fire_totem",

        handler = function ()
        end,

        copy = { 8498, 8499, 11314, 11315, 25546, 25547, 61649, 61657 },
    },


    -- Summons a Fire Resistance Totem with 5 health at the feet of the caster for 5 min that increases the fire resistance of party and raid members within 30 yards by 130.
    fire_resistance_totem = {
        id = 8184,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 135832,

        totem = "water",

        handler = function ()
            removeBuff( "water_totem" )
            summonTotem( "fire_resistance_totem" )
            applyBuff( "fire_resistance_totem" )
        end,

        copy = { 10537, 10538, 25563, 58737, 58739 },
    },


    -- Instantly sears the target with fire, causing 505 Fire damage immediately and 842 Fire damage over 16.45 sec. This periodic damage may critically strike and will occur more rapidly based on the caster's spell haste.
    flame_shock = {
        id = 8050,
        cast = 0,
        cooldown = 6,
        gcd = function() return glyph.shocking.enabled and "totem" or "spell" end,

        spend = function ()
            return ( buff.clearcasting.up and 0.6 or 1 ) * 0.17
        end,
        spendType = "mana",

        startsCombat = true,
        texture = 135813,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            setCooldown( "frost_shock", 6 )
            setCooldown( "earth_shock", 6 )
        end,

        copy = { 8052, 8053, 10447, 10448, 29228, 25457, 49232, 49233 },
    },


    -- Summons a Flametongue Totem with 5 health at the feet of the caster.  Party and raid members within 30 yards of the totem have their spell damage and healing increased by up to 144.  Lasts 5 min.
    flametongue_totem = {
        id = 58656,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136040,

        totem = "fire",

        handler = function ()
            removeBuff( "fire_totem" )
            summonTotem( "flametongue_totem" )
            applyBuff( "flametongue_totem" )
        end,

        copy = { 8249, 10526, 16387, 25557, 58649, 58652, 58656 },
    },


    -- Imbue the Shaman's weapon with fire, increasing total spell damage by 211. Each hit causes 89.0 to 274 additional Fire damage, based on the speed of the weapon.  Slower weapons cause more fire damage per swing.  Lasts 30 minutes.
    flametongue_weapon = {
        id = 8024,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        max_rank = 10,

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135814,

        usable = function() return ( equipped.mainhand and not mainhand_imbued ) or ( equipped.offhand and not offhand_imbued ), "must have an unimbued weapon" end,

        handler = function ()
            if equipped.mainhand and not mainhand_imbued then
                mainhand_imbued = true
                flametongue_mainhand = true
            elseif equipped.offhand and not offhand_imbued then
                offhand_imbued = true
                flametongue_offhand = true
            end
        end,

        copy = { 8027, 8030, 16339, 16341, 16342, 25489, 58785, 58789, 58790 },
    },


    -- Summons a Frost Resistance Totem with 5 health at the feet of the caster for 5 min.  The totem increases party and raid members' frost resistance by 130, if within 30 yards.
    frost_resistance_totem = {
        id = 8181,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 135866,

        totem = "fire",

        handler = function ()
            removeBuff( "fire_totem" )
            summonTotem( "frost_resistance_totem" )
            applyBuff( "frost_resistance_totem" )
        end,

        copy = { 10478, 10479, 25560, 58741, 58745 },
    },


    -- Instantly shocks the target with frost, causing 820 to 867 Frost damage and slowing movement speed by 50%.  Lasts 8 sec.  Causes a high amount of threat.
    frost_shock = {
        id = 8056,
        cast = 0,
        cooldown = 6,
        gcd = function() return glyph.shocking.enabled and "totem" or "spell" end,

        spend = function ()
            return ( buff.clearcasting.up and 0.6 or 1 ) * 0.18
        end,
        spendType = "mana",

        startsCombat = true,
        texture = 135849,

        handler = function ()
            applyDebuff( "target", "frost_shock" )
            setCooldown( "flame_shock", 6 )
            setCooldown( "earth_shock", 6 )
        end,

        copy = { 8058, 10472, 10473, 25464, 49235, 49236 },
    },


    -- Imbue the Shaman's weapon with frost.  Each hit has a chance of causing 530 additional Frost damage and slowing the target's movement speed by 50% for 8 sec.  Lasts 30 minutes.
    frostbrand_weapon = {
        id = 8033,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135847,

        usable = function() return ( equipped.mainhand and not mainhand_imbued ) or ( equipped.offhand and not offhand_imbued ), "must have an unimbued weapon" end,

        handler = function( rank )
            if equipped.mainhand and not mainhand_imbued then
                mainhand_imbued = true
                frostbrand_mainhand = true
            elseif equipped.offhand and not offhand_imbued then
                offhand_imbued = true
                frostbrand_offhand = true
            end
        end,

        copy = { 8038, 10456, 16355, 16356, 25500, 58794, 58795, 58796 },
    },


    -- Turns the Shaman into a Ghost Wolf, increasing speed by 40%. As a Ghost Wolf, the Shaman is less hindered by effects that would reduce movement speed. Only useable outdoors.
    ghost_wolf = {
        id = 2645,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 136095,

        handler = function ()
            applyBuff( "ghost_wolf" )
        end,
    },


    -- Summons a Grounding Totem with 5 health at the feet of the caster that will redirect one harmful spell cast on a nearby party member to itself, destroying the totem.  Will not redirect area of effect spells.  Lasts 45 sec.
    grounding_totem = {
        id = 8177,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 136039,

        totem = "air",

        handler = function ()
            removeBuff( "air_totem" )
            summonTotem( "grounding_totem" )
            applyBuff( "grounding_totem" )
        end,
    },


    -- Summons a Healing Stream Totem with 5 health at the feet of the caster for 5 min that heals group members within 30 yards for 25 every 2 seconds.
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135127,

        totem = "water",

        handler = function( rank )
            removeBuff( "water_totem" )
            summonTotem( "healing_stream_totem" )
            applyBuff( "healing_stream_totem" )
        end,

        copy = { 6375, 6377, 10462, 10463, 25567, 58755, 58756, 58757 },
    },


    -- Heals a friendly target for 3034 to 3466.
    healing_wave = {
        id = 331,
        cast = function()
            if buff.natures_swiftness.up then return 0 end
            return 3 * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 136052,

        handler = function ()
            removeBuff( "natures_swiftness" )
        end,

        copy = { 332, 547, 913, 939, 959, 8005, 10395, 10396, 25357, 25391, 25396, 49272, 49273 },
    },


    -- Transforms the enemy into a frog. While hexed, the target cannot attack or cast spells. Damage caused may interrupt the effect. Lasts 30 sec. Only one target can be hexed at a time.  Only works on Humanoids and Beasts.
    hex = {
        id = 51514,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 237579,

        handler = function ()
            applyDebuff( "target", "hex" )
        end,
    },


    -- You hurl molten lava at the target, dealing 1203 to 1534 Fire damage. If your Flame Shock is on the target, Lava Burst will deal a critical strike.
    lava_burst = {
        id = 51505,
        cast = function ()
            if buff.elemental_mastery.up then return 0 end
            return 2 * haste
        end,
        cooldown = 8,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 237582,

        handler = function ()
            removeBuff( "elemental_mastery" )
        end,

        copy = { 60043 },
    },


    -- You charge your off-hand weapon with lava, instantly dealing 100% off-hand Weapon damage. Damage is increased by 25% if your off-hand weapon is enchanted with Flametongue.
    lava_lash = {
        id = 60103,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "lava_lash",
        startsCombat = true,
        texture = 236289,

        handler = function ()
        end,
    },


    -- Heals a friendly target for 1624 to 1852.
    lesser_healing_wave = {
        id = 8004,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 136043,

        handler = function ()
            removeBuff( "natures_swiftness" )
        end,

        { 8008, 8010, 10466, 10467, 10468, 25420, 49275, 49276 },
    },


    -- Casts a bolt of lightning at the target for 726 to 828 Nature damage.
    lightning_bolt = {
        id = 403,
        cast = function ()
            if buff.elemental_mastery.up or buff.natures_swiftness.up then return 0 end
            return 2.5 * (1 - (buff.maelstrom_weapon.stack * 2) / 10) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            return 0.1 * ( buff.clearcasting.up and 0.6 or 1 )
        end,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
            removeStack( "clearcasting" )
            removeBuff( "natures_swiftness" )
            removeBuff( "elemental_mastery" )
            removeBuff( "maelstrom_weapon" )
            removeDebuffStack( "target", "stormstrike" )
        end,

        copy = { 529, 548, 915, 943, 6041, 10391, 10392, 15207, 15208, 25448, 25449, 49237, 49238 },
    },


    -- The caster is surrounded by 3 balls of lightning.  When a spell, melee or ranged attack hits the caster, the attacker will be struck for 380 Nature damage.  This expends one lightning ball.  Only one ball will fire every few seconds.  Lasts 10 min.  Only one Elemental Shield can be active on the Shaman at any one time.
    lightning_shield = {
        id = 324,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136051,

        handler = function ()
            removeBuff( "shield" )
            applyBuff( "lightning_shield", nil, buff.lightning_shield.max_stack )
        end,

        copy = { 325, 905, 945, 8134, 10431, 10432, 25469, 25472, 49280, 49281 },
    },


    -- Summons a Magma Totem with 5 health at the feet of the caster for 20 sec that causes 371 Fire damage to creatures within 8 yards every 2 seconds.
    magma_totem = {
        id = 8190,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.27,
        spendType = "mana",

        startsCombat = true,
        texture = 135826,

        totem = "fire",

        handler = function ()
            removeBuff( "fire_totem" )
            summonTotem( "magma_totem" )
            applyBuff( "magma_totem" )
        end,

        copy = { 10585, 10586, 10587, 25552, 58731, 58734 },
    },


    -- Summons a Mana Spring Totem with 5 health at the feet of the caster for 5 min that restores 91 mana every 5 seconds to all party and raid members within 30 yards.
    mana_spring_totem = {
        id = 5675,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 136053,

        totem = "water",

        handler = function ()
            removeBuff( "water_totem" )
            summonTotem( "mana_spring_totem" )
            applyBuff( "mana_spring_totem" )
        end,

        copy = { 10495, 10496, 10497, 25570, 58771, 58773, 58774 },
    },


    -- Summons a Mana Tide Totem with 10% of the caster's health at the feet of the caster for 12 sec that restores 6% of total mana every 3 seconds to group members within 30 yards.
    mana_tide_totem = {
        id = 16190,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        talent = "mana_tide_totem",
        startsCombat = false,
        texture = 135861,

        toggle = "cooldowns",

        totem = "water",

        handler = function ()
            removeBuff( "water_totem" )
            summonTotem( "mana_tide_totem" )
            applyBuff( "mana_tide_totem" )
        end,
    },


    -- Summons a Nature Resistance Totem with 5 health at the feet of the caster for 5 min that increases the nature resistance of party and raid members within 30 yards by 130.
    nature_resistance_totem = {
        id = 10595,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136061,

        totem = "air",

        handler = function ()
            removeBuff( "air_totem" )
            summonTotem( "nature_resistance_totem" )
            applyBuff( "nature_resistance_totem" )
        end,

        copy = { 10600, 10601, 25574, 58746, 58749 },
    },


    -- When activated, your next Nature spell with a base casting time less than 10 sec. becomes an instant cast spell. Nature's Swiftness shares a cooldown with Elemental Mastery.
    natures_swiftness = {
        id = 16188,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "natures_swiftness",
        startsCombat = false,
        texture = 136076,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "natures_swiftness" )
            setCooldown( "elemental_mastery", 120 )
        end,
    },


    -- Purges the enemy target, removing 2 beneficial magic effects.
    purge = {
        id = 370,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136075,

        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,

        copy = { 8012 },
    },


    -- Heals a friendly target for 639 to 691 and another 665 over 15 sec.  Your next Chain Heal cast on that primary target within 15 sec will consume the healing over time effect and increase the amount of the Chain Heal by 25%.
    riptide = {
        id = 61295,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "riptide",
        startsCombat = false,
        texture = 252995,

        handler = function ()
            applyBuff( "riptide" )
        end,
    },


    -- Imbue the Shaman's weapon, increasing its damage per second by 9.  Lasts 30 minutes.
    rockbiter_weapon = {
        id = 8017,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 136086,

        usable = function() return ( equipped.mainhand and not mainhand_imbued ) or ( equipped.offhand and not offhand_imbued ), "must have an unimbued weapon" end,

        handler = function ()
            if equipped.mainhand and not mainhand_imbued then
                mainhand_imbued = true
                rockbiter_mainhand = true
            elseif equipped.offhand and not offhand_imbued then
                offhand_imbued = true
                rockbiter_offhand = true
            end
        end,

        copy = { 8018, 8019, 10399 },
    },


    -- Summons a Searing Totem with 5 health at your feet for 1 min that repeatedly attacks an enemy within 201 yards for 90 to 120 Fire damage.
    searing_totem = {
        id = 3599,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135825,

        totem = "fire",

        handler = function ()
            removeBuff( "fire_totem" )
            summonTotem( "searing_totem" )
            applyBuff( "searing_totem" )
        end,

        copy = { 6363, 6364, 6365, 10437, 10438, 25533, 58699, 58703, 58704 },
    },


    -- Summons an immobile Sentry Totem with 100 health at your feet for 5 min that allows vision of nearby area and warns of enemies that attack it.  Right-Click on buff to switch back and forth between totem sight and shaman sight.
    sentry_totem = {
        id = 6495,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136082,

        totem = "air",

        handler = function ()
            removeBuff( "air_totem" )
            applyBuff( "sentry_totem" )
        end,

        copy = { 6363, 6364, 6365, 10437, 10438, 25533 },
    },


    -- Reduces all damage taken by 30% and gives your successful melee attacks a chance to regenerate mana equal to 15% of your attack power. This spell is usable while stunned. Lasts 15 sec.
    shamanistic_rage = {
        id = 30823,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "shamanistic_rage",
        startsCombat = false,
        texture = 136088,

        -- Shamanistic Rage is on Defensives toggle unless mana is below the threshold.
        toggle = function ()
            if mana.percent > settings.shaman_rage_threshold then return "defensives" end
        end,

        handler = function ()
            applyBuff( "shamanistic_rage" )
        end,
    },


    -- Summons a Stoneclaw Totem with 1632  health at the feet of the caster for 15 sec that taunts creatures within 8 yards to attack it.  Enemies attacking the Stoneclaw Totem have a 50% chance to be stunned for 3 sec. Stoneclaw totem also protects all your totems, causing them to absorb 1085 damage.
    stoneclaw_totem = {
        id = 5730,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136097,

        totem = "earth",

        handler = function ()
            removeBuff( "earth_totem" )
            summonTotem( "stoneclaw_totem" )
            applyBuff( "stoneclaw_totem" )
        end,

        copy = { 6390, 6391, 6392, 10427, 10428, 25525, 58580, 58581, 58582 },
    },


    -- Summons a Stoneskin Totem with 5 health at the feet of the caster.  The totem protects party and raid members within 30 yards, increasing armor by 1150.  Lasts 5 min.
    stoneskin_totem = {
        id = 8071,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,
        texture = 136098,

        totem = "earth",

        handler = function ()
            removeBuff( "earth_totem" )
            summonTotem( "stoneskin_totem" )
            applyBuff( "stoneskin_totem" )
        end,

        copy = { 8154, 8155, 10406, 10407, 10408, 25508, 25509, 58751, 58753 },
    },


    -- Instantly attack with both weapons.  In addition, the next 4 sources of Nature damage dealt to the target from the Shaman are increased by 20%. Lasts 12 sec.
    stormstrike = {
        id = 17364,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "stormstrike",
        startsCombat = true,
        texture = 132314,

        handler = function ()
            applyDebuff( "target", "stormstrike", nil, 4 )
        end,
    },


    -- Summons a Strength of Earth Totem with 5 health at the feet of the caster.  The totem increases the strength and agility of all party and raid members within 30 yards by 155.  Lasts 5 min.
    strength_of_earth_totem = {
        id = 8075,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136023,

        totem = "earth",

        handler = function ()
            removeBuff( "earth_totem" )
            summonTotem( "strength_of_earth_totem" )
            applyBuff( "strength_of_earth_totem" )
        end,

        copy = { 8160, 8161, 10442, 25361, 25528, 57622, 58643 },
    },


    -- You call down a bolt of lightning, energizing you and damaging nearby enemies within 10 yards. Restores 8% mana to you and deals 571 to 651 Nature damage to all nearby enemies, knocking them back 20 yards. This spell is usable while stunned.
    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = function() return glyph.thunder.enabled and 35 or 45 end,
        gcd = "spell",

        talent = "thunderstorm",
        startsCombat = true,
        texture = 237589,

        handler = function ()
            gain( 0.08 * mana.max, "mana" )
        end,
    },


    -- Increases the critical effect chance of your Healing Wave, Lesser Healing Wave and Chain Heal by 60%. Each critical heal reduces the chance by 20%. Lasts 20 sec.
    tidal_force = {
        id = 55198,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "tidal_force",
        startsCombat = false,
        texture = 135845,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "tidal_force" )
        end,
    },


    -- Summons a Totem of Wrath with 5 health at the feet of the caster.  The totem increases spell power by 100 for all party and raid members, and increases the critical strike chance of all attacks by 3% against all enemies within 40 yards.  Lasts 5 min.
    totem_of_wrath = {
        id = 30706,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.05,
        spendType = "mana",

        talent = "totem_of_wrath",
        startsCombat = false,
        texture = 135829,

        totem = "fire",

        handler = function ()
            removeBuff( "fire_totem" )
            summonTotem( "totem_of_wrath" )
            applyBuff( "totem_of_wrath" )
        end,
    },


    -- Returns your totems to the earth, giving you 25% of the mana required to cast each totem destroyed by Totemic Recall.
    totemic_recall = {
        id = 36936,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 310733,

        handler = function ()
            if buff.earth_totem.up then
                gain( 0.25 * action[ buff.earth_totem.actual ].cost, "mana" )
                removeBuff( "earth_totem" )
            end
            if buff.fire_totem.up then
                gain( 0.25 * action[ buff.fire_totem.actual ].cost, "mana" )
                removeBuff( "fire_totem" )
            end
            if buff.water_totem.up then
                gain( 0.25 * action[ buff.water_totem.actual ].cost, "mana" )
                removeBuff( "water_totem" )
            end
            if buff.air_totem.up then
                gain( 0.25 * action[ buff.air_totem.actual ].cost, "mana" )
                removeBuff( "air_totem" )
            end
        end,
    },


    -- Summons a Tremor Totem with 5 health at the feet of the caster that shakes the ground around it, removing Fear, Charm and Sleep effects from party members within 30 yards.  Lasts 5 min.
    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136108,

        totem = "earth",

        handler = function ()
            removeBuff( "earth_totem" )
            summonTotem( "tremor_totem" )
            applyBuff( "tremor_totem" )
        end,
    },


    -- Allows the target to breathe underwater for 10 min.
    water_breathing = {
        id = 131,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136148,

        handler = function ()
            applyBuff( "water_breathing" )
        end,
    },


    -- The caster is surrounded by 3 globes of water, granting 100 mana per 5 sec.  When a spell, melee or ranged attack hits the caster, 428 mana is restored to the caster. This expends one water globe.  Only one globe will activate every few seconds.  Lasts 10 min.  Only one Elemental Shield can be active on the Shaman at any one time.
    water_shield = {
        id = 52127,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132315,

        handler = function ()
            removeBuff( "shield" )
            applyBuff( "water_shield", nil, glyph.water_shield.enabled and 4 or 3 )
        end,

        copy = { 52129, 52131, 52134, 52136, 52138, 24398, 33736 },
    },


    -- Allows the friendly target to walk across water for 10 min.  Any damage will cancel the effect.
    water_walking = {
        id = 546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135863,

        handler = function ()
            applyBuff( "water_walking" )
        end,
    },


    -- Instantly blasts the target with a gust of wind, causing no damage but interrupting spellcasting and preventing any spell in that school from being cast for 2 sec. Also lowers your threat, making the enemy less likely to attack you.
    wind_shear = {
        id = 57994,
        cast = 0,
        cooldown = 6,
        gcd = "off",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136018,

        debuff = "casting",
        readyTime = timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    -- Summons a Windfury Totem with 5 health at the feet of the caster.  The totem provides 16% melee haste to all party and raid members within 30 yards.  Lasts 5 min.
    windfury_totem = {
        id = 8512,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136114,

        totem = "air",

        handler = function ()
            removeBuff( "air_totem" )
            summonTotem( "windfury_totem" )
            applyBuff( "windfury_totem" )
        end,
    },


    -- Imbue the Shaman's weapon with wind.  Each hit has a 20% chance of dealing additional damage equal to two extra attacks with 1250 extra attack power.  Lasts 30 minutes.
    windfury_weapon = {
        id = 8232,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 136018,

        usable = function() return ( equipped.mainhand and not mainhand_imbued ) or ( equipped.offhand and not offhand_imbued ), "must have an unimbued weapon" end,

        handler = function ()
            if equipped.mainhand and not mainhand_imbued then
                mainhand_imbued = true
                windfury_mainhand = true
            elseif equipped.offhand and not offhand_imbued then
                offhand_imbued = true
                windfury_offhand = true
            end
        end,

        copy = { 8235, 10486, 16362, 25505, 58801, 58803, 58804 },
    },


    -- Summons a Wrath of Air Totem with 5 health at the feet of the caster.  The totem provides 5% spell haste to all party and raid members within 30 yards.  Lasts 5 min.
    wrath_of_air_totem = {
        id = 3738,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136092,

        totem = "air",

        handler = function ()
            removeBuff( "air_totem" )
            summonTotem( "wrath_of_air_totem" )
            applyBuff( "wrath_of_air_totem" )
        end,
    },
} )


spec:RegisterSetting( "st_cl_mana_threshold", 80, {
    type = "range",
    name = "|T136015:0|t Single-Target Chain Lightning Mana %",
    desc = "When below the specified mana percentage, the default priority will not recommend |T136015:0|t Chain Lightning in single-target.\n\n"
        .. "If |T237589:0|t Thunderstorm is known, the default priority may recommend using it to regenerate mana below this threshold.",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "shaman_rage_threshold", 60, {
    type = "range",
    name = "|T136088:0|t Shamanistic Rage Threshold",
    desc = "When below the specified mana percentage, the addon may recommend using Shamanistic Rage to regenerate mana.",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting("maelstrom_weapon_stack_limit", 3, {
    type = "range",
    name = "Minimum Maelstrom Weapon Stacks",
    desc = "Sets the minimum number of Maelstrom Weapon stacks before recommending the player cast a spell",
    width = "full",
    min = 1,
    max = 5,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 7 ].settings.maelstrom_weapon_stack_limit = val
    end
})


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 8017,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    package = "Enhancement (IV)",
    usePackSelector = true
} )


spec:RegisterPack( "Elemental / Resto DPS (IV)", 20220925, [[Hekili:1EvZUnUnq4NLGfWjbnw(NDZUnTj5q72djhcwuVy7njslrzXAksbskl4Ia(S3zOSLLKLtt32CXwIC4W5NVz(gfol8RHlsOww4tZNoF(0BMFDWS5F465FmCHDBblCrbnEnDf8GKMd)(BcwotAPchzIJ87mJv5iF(llCKlE4BxIIVvOOjOAnQsDmCKmRTW8ttMuvvfWJ3oEdJlnbXQ8jvkRy94yb1y4Xty7v9ytgnNkhNuygxSHnwRSulxjhhRuIevL0mMUKl4woZeUyzjxyFqgUCyh5AWqkyXHp9jWs4jjSAjzM4WfFnJBCKcnxP52TWtGVELJaBYxjzjosQs7iTC5lwwADendmEyPKgrAhhOGkRycXLocQ9LudkwzHs6ipaU)3q3)8oQDH3FDKvL8e2ov(hAQnliCHGBSgmCsvm4VN8zmMKUuWsc)LWfXGPZ0Ckgistds5AwKvzz5byKcowmg6cxKtxLtR3j0cbjVk3TN)qs1gABndc9(2c1KEIYPg4k32t4p0w44mkxgj4RYSsUCvprVUNpS)u2SsiOQHyPoVohP5f1BvlIjaIc)WDtAl4v807GOhnOi2E7ntF(zlvVIzdsGahvgZUD20rReBlYc8)gPsJAF8G92rRizpn4i3ENJmBQJmYr2FvWIoYnWAp)CVfnmRf8ztGXgfJrlje3Z0mtgGEb33IUwkTuyBYN7davCzsKjJr19IyhNUoKoQZPVqMR0WIaxl3mugBqOeEYnWDiz5qnMJCp4(TsUuHiQ(LieEwdsJQBqGW09P4xl05JN0qoZrS841EiuJ7lGlcIsQ414H)0jpCIYg0s4anlhqL1UtmyirwU3I3PxbDdnAzjalq1(JNuT5QnG94bd9VHJSvitAZoyR3CcG)rLlDW(pXWoiydMyndAXbp7BCH914ub)V8DhDeLx(Go2AdW8()zG5tZMEsN(TSKy46F0E6uC0eEIwQGANoqi41cFB5Lu7l3L8m004YmkuPXZxwYs6HSSk5QswufJcTSBQ9gkPHLb(UjnvJMEzUViOySAlWeIjqSgeyfsXeiB75AylPcIqubKxt2ISei9JsEoSyfvARZ6q9lCkB9jRyNVH5xdWeu0z(tKU4x)8Uli4ikHAm4bobFoBiYIdBubOm9G7q5TxVPvZ3bHKFnm(vHmDd1pAVKgWdW0(UgDNO2if6D6Jiv0T1RSbmJu85mQ1hYbGOKwaGo41mKN2sxZaNRatthh46AHbLfhcdjSCLKhhbtmyHn8iqadc3ObnRMzqGw6unIzbKXd5fkTfn33d2zCDnRNEpW9iIFvPCb0p6DVBWHdUagEWr8tpCP7rui8sgp9MXZV29O7X9mKn1bap5XaAKT8SEfaG2CK)9q1F()muDyJEO6k0ShempAiq2ObbXJgaapSf0nX3C39lxWW2)J4VHTLoG)gt5iO5OHGLTGfGMomCr7vhAyI273m8q7f7pbWvi3)Da1pAGDhE4(zTp4rtc0XuoWK6HP7ytBlYboAuItqWFFd5ENR(avSFKrpl(OtWG3l3(Q4D7eG6sO3Eg17FrYW2kP)uU9hS9oyY2ot(28YR(k6YP2Uns9G2T(QHtxg09inFmr)noDUFNa9cA1n5oKeQzgGVschJ3S7ZKQZi42vk96aFERRwFd(wH(g(BuIcyalTzk4BbA(Urpnt4F)d]] )

spec:RegisterPack( "Enhancement (IV)", 20230123, [[Hekili:TNvFVTTnt8plffiyRPvZYooPfWoapdBapnROBaAy7)KeTeLfrKefiPJxgc0N9DK6nAA9MJtrhgkkqtc59oV73DI01293DDcrcS7NNpB(Iz2ZxyzpF27NTW1r8yo21jhfCpAl8lzOu4))5SyuwaofNjk8)Up(hFVKIhtOOqPK40DSaGkxNn7ijIpM5UPtX76G2jIPmxNFch93OGyxNysyiUKEmpW15pPIp9lf(yD9XJrPOScFgvGeek8BruwH))hFpjHagcJgrsa1)6c))3V9Pc)hwyDLL97STMBnRW)1f3HcKSXTYz4aA6gK4Y1)WEswy0o2JE7XOCA2BjrRFvkIi1BOhjDZoC4fTleJ4E8CCssoDpM1TeJsGqLGMTDhUwOmu29RlP164TTsr)LNKK3z3P6pxTlLjnkstKDZAczBSiJKT1JhtWjHsg3SlkYQ8pTcP7Z6MZausIhnYteJ9WjQJlEd3yete7jOcCQsexOwnIWWhT4EixHD0QiI(A942sXvPAusj5DtzovL7CxZUvjbGtdwQ0QdXk1gG4ciyyTl)cJvEy(6z6SVJJ9iGc56lwRN2vg0gL7JzWY8CcJigv8LfdeWGcGCNTyPHlqSTyH1EIiMKzpdsCYqw5bIvCSqA4CRsUumahwmmpMMeQlw2UmVY)Ylbe(BLL9RruL4LR)a4bz4ucMFR9O8XfAHzl(H5yBOjIMCKueoHly006scUaaEwV0GBvYnCqrdUxLvdo)9GSUOYXfKuzoLxibF76puVkDNGtcXZnKfxqzPGoj3JBt0BxZixtXskABkQ8CRHfJ8ydocIHAxVgNEe)D1Ylgy3Bx3CmAsGNIaqpPerlCbdl)v(Tvapg2IkB(YeOIll4XlQXhofEu2AmMrj8uOk5CoPpxF7qLnjxBawoNSUEJcTyQqXpGaiDCzXRsUw4m0MeaRVF8wL4kXsBmLqQWsZ6SQDXLp90Xg3ktBtlB30JLj1z0hqNwbqL6xT4fmiuwyOVISBPA13mZYeG4fev8YH3guUTPBIEa5LG4XJvMpPCDDOtaa(Kbt0bpl5)KQipM9tdWSKNtcX854LNlWXlnO4zfZpxN5lfk4rN)MB1bEr1gppOtZy3PdB0vM1iGNv22yqNtkXUgj86xsFAYqHvNxFLWcRC0xuWqxNhWmoi(MVK021zpIjJKCxNpMMtzc47A8VQWV0ok8LZHYTkUd(U0CCG7NVb(Suehh(RzD(DSkYLFfly)Wp(S6BJRogC)rxNayQCmJGKFCBVEtH)6c)LGmu2aW0HqfUcW(FjK7HLTsXUyyXAcu3kkTDKY5QHLJb4DRy0kiKIz5ZZlVfCZjLqu4FrHVjoiWF9XFNG0f(xcPfvOBsbyakEk8p4z81FT9(oG1pfNFe2hkp8gvjuh5wAXdGS3Rtwt7ddI(qVHXxv4xbxRCLJrSldMFqthTi9srBpRxzpaCSszMTz6kAuUTsr9JJ0tdOc)NEQBxA1bEKw7mLIgby54UtkbEDVLW29dPCkHOQC7vhUAtNRc)3u4dDVgjk2pSKrlTQsJY2Ak1oYLFiZRhJeLjARLxB0AvzIptiVvtSMxlav3A1vwX5eIJq7GIVb7zD0DAPIthDVwQ(mZAvv7fJ106QERMBLYOODHorLxcMbfxDuTVXLIzq)YdOx7sYmO76PyE38LkrA4SJ33RALC1ERAkuyTmnJ7vRCmfVYlJxoOshOKtHvUOm3HpsAZznss)astf(wF36RXRxi9)BmbeKNTSfd9l)KcJnNZyJkmj(v(s7nf(TzNgy2PZQGP3IJ(XFoLE5JpUt)JS1ZDvQcDlFUZ8mBAtBwoe2bTC6yCZN5eul(2euJtY)QNGQ55b7QzO(OqApuC5dvZi5L721doBuaB8SUQWS(Yh(6UD1a9GA7dEJ3jOQ(0JJ8LNRL9WVo9WDzFvlSyPAh0GhVr7KXCgjTX89NBRVmVj6MnmFh62Do8TO1AK1XlGF0mPtyw3BgB656)5(pp]] )


spec:RegisterPackSelector( "elemental", "Elemental / Resto DPS (IV)", "|T136048:0|t Elemental",
    "If you have spent more points in |T136048:0|t Elemental than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "enhancement", "Enhancement (IV)", "|T136051:0|t Enhancement",
    "If you have spent more points in |T136051:0|t Enhancement than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "restoration", "Elemental / Resto DPS (IV)", "|T136052:0|t Restoration",
    "If you have spent more points in |T136052:0|t Restoration than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )