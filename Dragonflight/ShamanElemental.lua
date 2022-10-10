-- ShamanElemental.lua
-- September 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local GetWeaponEnchantInfo = GetWeaponEnchantInfo

local spec = Hekili:NewSpecialization( 262 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    aftershock                   = { 81000, 273221, 1 }, -- 
    ancestral_defense            = { 81083, 382947, 1 }, -- 
    ancestral_guidance           = { 81102, 108281, 1 }, -- 
    ancestral_wolf_affinity      = { 80982, 382197, 1 }, -- 
    ascendance                   = { 81003, 114050, 1 }, -- 
    astral_bulwark               = { 81056, 377933, 1 }, -- 
    astral_shift                 = { 81057, 108271, 1 }, -- 
    brimming_with_life           = { 81085, 381689, 1 }, -- 
    call_of_fire                 = { 81011, 378255, 1 }, -- 
    call_of_the_elements         = { 81090, 383011, 1 }, -- 
    call_of_thunder              = { 80987, 378241, 1 }, -- 
    capacitor_totem              = { 81071, 192058, 1 }, -- 
    chain_heal                   = { 81063, 1064  , 1 }, -- 
    chain_lightning              = { 81061, 188443, 1 }, -- 
    cleanse_spirit               = { 81075, 51886 , 1 }, -- 
    creation_core                = { 81090, 383012, 1 }, -- 
    deeply_rooted_elements       = { 81003, 378270, 1 }, -- 
    earth_elemental              = { 81064, 198103, 1 }, -- 
    earth_shield                 = { 81106, 974   , 1 }, -- 
    earth_shock                  = { 80984, 8042  , 1 }, -- 
    earthgrab_totem              = { 81082, 51485 , 1 }, -- 
    earthquake                   = { 80985, 61882 , 1 }, -- 
    echo_chamber                 = { 81013, 382032, 2 }, -- 
    echo_of_the_elements         = { 80999, 333919, 1 }, -- 
    echoes_of_great_sundering    = { 80991, 384087, 2 }, -- 
    electrified_shocks           = { 80996, 382086, 1 }, -- 
    elemental_blast              = { 80994, 117014, 1 }, -- 
    elemental_equilibrium        = { 80993, 378271, 2 }, -- 
    elemental_fury               = { 80983, 60188 , 1 }, -- 
    elemental_orbit              = { 81105, 383010, 1 }, -- 
    elemental_warding            = { 81084, 381650, 2 }, -- 
    enfeeblement                 = { 81078, 378079, 1 }, -- 
    eye_of_the_storm             = { 80995, 381708, 2 }, -- 
    fire_and_ice                 = { 81067, 382886, 1 }, -- 
    fire_elemental               = { 80981, 198067, 1 }, -- 
    flames_of_the_cauldron       = { 81010, 378266, 1 }, -- 
    flash_of_lightning           = { 80990, 381936, 1 }, -- 
    flow_of_power                = { 80998, 385923, 1 }, -- 
    flurry                       = { 81059, 382888, 1 }, -- 
    flux_melting                 = { 80996, 381776, 1 }, -- 
    focused_insight              = { 81058, 381666, 2 }, -- 
    frost_shock                  = { 81074, 196840, 1 }, -- 
    further_beyond               = { 81001, 381787, 1 }, -- 
    go_with_the_flow             = { 81089, 381678, 2 }, -- 
    graceful_spirit              = { 81065, 192088, 1 }, -- 
    greater_purge                = { 81076, 378773, 1 }, -- 
    guardians_cudgel             = { 81070, 381819, 1 }, -- 
    gust_of_wind                 = { 81088, 192063, 1 }, -- 
    healing_stream_totem         = { 81100, 5394  , 1 }, -- 
    heat_wave                    = { 80978, 386474, 1 }, -- 
    hex                          = { 81079, 51514 , 1 }, -- 
    icefury                      = { 80997, 210714, 1 }, -- 
    improved_flametongue_weapon  = { 81009, 382027, 1 }, -- 
    improved_lightning_bolt      = { 81098, 381674, 2 }, -- 
    inundate                     = { 80986, 378776, 1 }, -- 
    lava_burst                   = { 81062, 51505 , 1 }, -- 
    lava_surge                   = { 80979, 77756 , 1 }, -- 
    lightning_lasso              = { 81096, 305483, 1 }, -- 
    lightning_rod                = { 80992, 210689, 1 }, -- 
    liquid_magma_totem           = { 81008, 192222, 1 }, -- 
    maelstrom_weapon             = { 81060, 187880, 1 }, -- 
    magma_chamber                = { 81007, 381932, 2 }, -- 
    mana_spring_totem            = { 81103, 381930, 1 }, -- 
    master_of_the_elements       = { 81004, 16166 , 2 }, -- 
    mountains_will_fall          = { 81012, 381726, 1 }, -- 
    natures_fury                 = { 81086, 381655, 2 }, -- 
    natures_guardian             = { 81081, 30884 , 2 }, -- 
    natures_swiftness            = { 81099, 378081, 1 }, -- 
    oath_of_the_far_seer         = { 81002, 381785, 2 }, -- 
    planes_traveler              = { 81056, 381647, 1 }, -- 
    poison_cleansing_totem       = { 81093, 383013, 1 }, -- 
    power_of_the_maelstrom       = { 81015, 191861, 2 }, -- 
    primal_elementalist          = { 81008, 117013, 1 }, -- 
    primordial_bond              = { 80980, 381764, 1 }, -- 
    primordial_fury              = { 80982, 378193, 1 }, -- 
    primordial_wave              = { 81014, 375982, 1 }, -- 
    purge                        = { 81076, 370   , 1 }, -- 
    refreshing_waters            = { 80980, 378211, 1 }, -- 
    rolling_magma                = { 80977, 386443, 2 }, -- 
    searing_flames               = { 81005, 381782, 2 }, -- 
    skybreakers_fiery_demise     = { 81006, 378310, 1 }, -- 
    spirit_walk                  = { 81088, 58875 , 1 }, -- 
    spirit_wolf                  = { 81072, 260878, 1 }, -- 
    spiritwalkers_aegis          = { 81065, 378077, 1 }, -- 
    spiritwalkers_grace          = { 81066, 79206 , 1 }, -- 
    splintered_elements          = { 80978, 382042, 1 }, -- 
    static_charge                = { 81070, 265046, 1 }, -- 
    stoneskin_totem              = { 81095, 383017, 1 }, -- 
    storm_elemental              = { 80981, 192249, 1 }, -- 
    stormkeeper                     = { 80992, 191634, 1 }, --
    stormkeeper_2                = { 80989, 191634, 1 }, -- 
    surge_of_power               = { 81000, 262303, 1 }, -- 
    surging_shields              = { 81092, 382033, 2 }, -- 
    swelling_maelstrom           = { 81016, 381707, 1 }, -- 
    swirling_currents            = { 81101, 378094, 2 }, -- 
    thunderous_paws              = { 81072, 378075, 1 }, -- 
    thundershock                 = { 81096, 378779, 1 }, -- 
    thunderstorm                 = { 81097, 51490 , 1 }, -- 
    totemic_focus                = { 81094, 382201, 2 }, -- 
    totemic_projection           = { 81080, 108287, 1 }, -- 
    totemic_recall               = { 81091, 108285, 1 }, -- 
    totemic_surge                = { 81104, 381867, 2 }, -- 
    tranquil_air_totem           = { 81095, 383019, 1 }, -- 
    tremor_totem                 = { 81069, 8143  , 1 }, -- 
    tumultuous_fissures          = { 80986, 381743, 1 }, -- 
    unrelenting_calamity         = { 80988, 382685, 1 }, -- 
    voodoo_mastery               = { 81078, 204268, 1 }, -- 
    wind_rush_totem              = { 81082, 192077, 1 }, -- 
    wind_shear                   = { 81068, 57994 , 1 }, -- 
    winds_of_alakir              = { 81087, 382215, 2 }, -- 
    windspeakers_lava_resurgence = { 81006, 378268, 1 }, -- 
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    control_of_lava     = 728 , -- 204393
    counterstrike_totem = 3490, -- 204331
    grounding_totem     = 3620, -- 204336
    precognition        = 5457, -- 377360
    seasoned_winds      = 5415, -- 355630
    skyfury_totem       = 3488, -- 204330
    spectral_recovery   = 3062, -- 204261
    static_field_totem  = 727 , -- 355580
    swelling_waves      = 3621, -- 204264
    tidebringer         = 5519, -- 236501
    traveling_storms    = 730 , -- 204403
    unleash_shield      = 3491, -- 356736
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    unleash_shield = 3491, -- 356736
    counterstrike_totem = 3490, -- 204331
    precognition = 5457, -- 377360
    seasoned_winds = 5415, -- 355630
    spectral_recovery = 3062, -- 204261
    traveling_storms = 730, -- 204403
    control_of_lava = 728, -- 204393
    static_field_totem = 727, -- 355580
    skyfury_totem = 3488, -- 204330
    tidebringer = 5519, -- 236501
    grounding_totem = 3620, -- 204336
    swelling_waves = 3621, -- 204264
} )


-- Auras
spec:RegisterAuras( {
    ancestral_guidance = {
        id = 108281,
        duration = 10,
        max_stack = 1,
    },
    ascendance = {
        id = 114050,
        duration = 15,
        max_stack = 1,
    },
    astral_shift = {
        id = 108271,
        duration = function () return talent.planes_traveler.enabled and 12 or 8 end,
        max_stack = 1,
    },
    chains_of_devastation_ch = {
        id = 336737,
        duration = 20,
        max_stack = 1
    },
    chains_of_devastation_cl = {
        id = 336736,
        duration = 20,
        max_stack = 1,
    },
    --[[ earth_elemental = {
        id = 198103,
    },
    earthquake = {
        id = 61882,
    }, ]]
    earth_shield = {
        id = function () return talent.elemental_orbit.enabled and 383648 or 974 end,
        duration = 600,
        type = "Magic",
        max_stack = 9,
        dot = "buff",
    },
    earthbind = {
        id = 3600,
        duration = 5,
        type = "Magic",
        max_stack = 1,
    },
    -- might be the debuff on targets
    earthquake = {
        id = 61882,
        duration = 3600,
        max_stack = 1,
    },
    echoing_shock = {
        id = 320125,
        duration = 8,
        max_stack = 1,
    },
    -- buff id is different if not talented.
    echoes_of_great_sundering = {
        id = function () return talent.echoes_of_great_sundering.enabled and 384088 or 336217 end,
        duration = 25,
        max_stack = 1,
    },
    elemental_blast_critical_strike = {
        id = 118522,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    elemental_blast_haste = {
        id = 173183,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    elemental_blast_mastery = {
        id = 173184,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    elemental_blast = {
        alias = { "elemental_blast_critical_strike", "elemental_blast_haste", "elemental_blast_mastery" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 10,
    },
    --[[elemental_fury = {
        id = 60188,
    }, ]]
    far_sight = {
        id = 6196,
        duration = 60,
        max_stack = 1,
    },
    --[[ fire_elemental = {
        id = 198067,
    }, ]]
    flame_shock = {
        id = 188389,
        duration = function () return level > 58 and fire_elemental.up and 36 or 18 end,
        tick_time = function () return 2 * haste * ( talent.flames_of_the_cauldron.enabled and 0.85 or 1 ) end,
        type = "Magic",
        max_stack = 1,
    },
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    heat_wave = { --hidden aura, doesn't track correctly
        id = 387622,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
    },
    hex = {
        id = 51514,
        duration = 60,
        max_stack = 1,
    },
    icefury = {
        id = 210714,
        duration = 25,
        max_stack = 4,
    },
    lava_surge = {
        id = 77762,
        duration = 10,
        max_stack = 1,
    },
    lightning_lasso = {
        id = 305484,
        duration = 5,
        max_stack = 1
    },
    lightning_shield = {
        id = 192106,
        duration = 1800,
        type = "Magic",
        max_stack = 1,
    },
    master_of_the_elements = {
        id = 260734,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    --[[ mastery_elemental_overload = {
        id = 168534,
    }, ]]
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        max_stack = 1
    },
    power_of_the_maelstrom = {
        id = 191877,
        duration = 20,
        max_stack = 2,
    },
    primordial_wave = {
        id = 375986,
        duration = 15,
        max_stack = 1,
    },
    reincarnation = {
        id = 20608,
    },
    sign_of_the_twisting_nether = {
        id = 335148,
        duration = 3600,
        max_stack = 1,
    },
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1
    },
    spirit_wolf = {
        id = 260881,
        duration = 3600,
        max_stack = 4,
    },
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    stoneskin = {
        id = 383018,
        duration = 15,
        max_stack = 1
    },
    stormkeeper = {
        id = 191634,
        duration = 15,
        max_stack = 2,
    },
    surge_of_power = {
        id = 285514,
        duration = 15,
        max_stack = 1,
    },
    surge_of_power_debuff = {
        id = 285515,
        duration = 6,
        max_stack = 1,
    },
    thunderstorm = {
        id = 51490,
        duration = 5,
        max_stack = 1,
    },
    water_walking = {
        id = 546,
        duration = 600,
        max_stack = 1,
    },
    wind_rush = {
        id = 192082,
        duration = 5,
        max_stack = 1,
    },
    --buff id is different if not talented.
    windspeakers_lava_resurgence = {
        id = function () return talent.windspeakers_lava_resurgence.enabled and 378269 or 336065 end,
        duration = 15,
        max_stack = 1,
    },
    wind_gust = {
        id = 263806,
        duration = 30,
        max_stack = 20
    },
    -- Pet aura.
    call_lightning = {
        duration = 15,
        generate = function( t, db )
            if storm_elemental.up then
                local name, _, count, _, duration, expires = FindUnitBuffByID( "pet", 157348 )

                if name then
                    t.count = count
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = "pet"
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- TODO:  Implement like Bloodtalons, but APL doesn't really require it mechanically.
    elemental_equilibrium = {
        id = 347348,
        duration = 10,
        max_stack = 1
    },
    elemental_equilibrium_debuff = {
        id = 347349,
        duration = 30,
        max_stack = 1
    },

    -- Conduit
    crippling_hex = {
        id = 338055,
        duration = 8,
        max_stack = 1
    },
    swirling_currents = {
        id = 338340,
        duration = 15,
        max_stack = 1
    }
} )


local ancestral_wolf_affinity_spells = {
    cleanse_spirit = 1,
    wind_shear = 1,
    purge = 1,
    -- TODO: List totems?
}

spec:RegisterHook( "runHandler", function( action )
    if buff.ghost_wolf.up then
        if talent.ancestral_wolf_affinity.enabled then
            local ability = class.abilities[ action ]
            if not ancestral_wolf_affinity_spells[ action ] and not ability.gcd == "totem" then
                removeBuff( "ghost_wolf" )
            end
        else
            removeBuff( "ghost_wolf" )
        end
    end
end )


-- Pets
spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
spec:RegisterTotem( "greater_fire_elemental", 135790 ) -- Texture ID

spec:RegisterPet( "primal_earth_elemental", 61056, "earth_elemental", 60 )
spec:RegisterTotem( "greater_earth_elemental", 136024 ) -- Texture ID

local elementals = {
    [77942] = { "primal_storm_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
    [61029] = { "primal_fire_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
    [61056] = { "primal_earth_elemental", function () return 60 end, false }
}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local summon = {}
local wipe = table.wipe

local vesper_heal = 0
local vesper_damage = 0
local vesper_used = 0

local vesper_expires = 0
local vesper_guid
local vesper_last_proc = 0

local flash_of_lightning_nature_spells = { "stormkeeper", "ancestral_guidance", "healing_stream_totem", "wind_shear", "gust_of_wind", "earthbind_totem", "tremor_totem", "storm_elemental", "earth_elemental", " astral_shift", "capacitor_totem", "thunderstorm", "totemic_recall", "spiritwalkers_grace", "natures_swiftness", "poison_cleansing_totem", "totemic_projection", "stoneskin_totem", "cleanse_spirit", "hex", "tranquil_air_totem", "lightning_lasso", "reincarnation", "greater_purge", "static_field_totem", "counterstrike_totem", "unleash_shield", "grounding_totem" }

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    -- Deaths/despawns.
    if death_events[ subtype ] then
        if destGUID == summon.guid then
            wipe( summon )
        elseif destGUID == vesper_guid then
            vesper_guid = nil
        end
        return
    end

    if sourceGUID == state.GUID then
        -- Summons.
        if subtype == "SPELL_SUMMON" then
            local npcid = destGUID:match("(%d+)-%x-$")
            npcid = npcid and tonumber( npcid ) or -1
            local elem = elementals[ npcid ]

            if elem then
                summon.guid = destGUID
                summon.type = elem[1]
                summon.duration = elem[2]()
                summon.expires = GetTime() + summon.duration
                summon.extends = elem[3]
            end

            if spellID == 324386 then
                vesper_guid = destGUID
                vesper_expires = GetTime() + 30

                vesper_heal = 3
                vesper_damage = 3
                vesper_used = 0
            end

        -- Tier 28
        elseif summon.extends and state.set_bonus.tier28_4pc > 0 and subtype == "SPELL_ENERGIZE" and ( spellID == 51505 or spellID == 285466 ) then
            summon.expires = summon.expires + 1.5
            summon.duration = summon.duration + 1.5

        -- Vesper Totem heal
        elseif spellID == 324522 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_heal = vesper_heal - 1
            end

        -- Vesper Totem damage; only fires on SPELL_DAMAGE...
        elseif spellID == 324520 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_damage = vesper_damage - 1
            end

        end

        if subtype == "SPELL_CAST_SUCCESS" then
            -- Reset in case we need to deal with an instant after a hardcast.
            vesper_last_proc = 0
        end
    end
end )

spec:RegisterStateExpr( "vesper_totem_heal_charges", function()
    return vesper_heal
end )

spec:RegisterStateExpr( "vesper_totem_dmg_charges", function ()
    return vesper_damage
end )

spec:RegisterStateExpr( "vesper_totem_used_charges", function ()
    return vesper_used
end )

spec:RegisterStateFunction( "trigger_vesper_heal", function ()
    if vesper_totem_heal_charges > 0 then
        vesper_totem_heal_charges = vesper_totem_heal_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterStateFunction( "trigger_vesper_damage", function ()
    if vesper_totem_dmg_charges > 0 then
        vesper_totem_dmg_charges = vesper_totem_dmg_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterTotem( "liquid_magma_totem", 971079 )
spec:RegisterTotem( "tremor_totem", 136108 )
spec:RegisterTotem( "wind_rush_totem", 538576 )

spec:RegisterTotem( "vesper_totem", 3565451 )


spec:RegisterStateTable( "fire_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.fire_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "storm_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.storm_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "earth_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.earth_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

-- Heat wave talent basically acts as a mini Fireheart. The aura for it is hidden, so this is a workaround
local TriggerHeatWave = setfenv( function()
    applyBuff( "lava_surge" )
end, state )

-- Tier 28
spec:RegisterGear( "tier28", 188925, 188924, 188923, 188922, 188920 )
spec:RegisterSetBonuses( "tier28_2pc", 364472, "tier28_4pc", 363671 )
-- 2-Set - Fireheart - While your Storm Elemental / Fire Elemental is active, your Lava Burst deals 20% additional damage and you gain Lava Surge every 8 sec.
-- 4-Set - Fireheart - Casting Lava Burst extends the duration of your Storm Elemental / Fire Elemental by 1.5 sec. If your Storm Elemental / Fire Elemental is not active. Lava Burst has a 20% chance to reduce its remaining cooldown by 10 sec instead.
spec:RegisterAura( "fireheart", {
    id = 364523,
    duration = 30,
    tick_time = 8,
    max_stack = 1
} )

local TriggerFireheart = setfenv( function()
    applyBuff( "lava_surge" )
end, state )

-- Tier 29
spec:RegisterGear( "tier29", 200396, 200398, 200400, 200401, 200399 )
spec:RegisterSetBonuses( "tier29_2pc", 393688, "tier29_4pc", 393690 )

spec:RegisterAura( "seismic_accumulation", {
    id = 394651,
    duration = 15,
    max_stack = 10,
} )

spec:RegisterAura( "elemental_mastery", {
    id = 394670,
    duration = 10,
    max_stack = 1,
} )

spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end

    if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end

    if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
        applyBuff( "master_of_the_elements" )
    end

    if vesper_expires > 0 and now > vesper_expires then
        vesper_expires = 0
        vesper_heal = 0
        vesper_damage = 0
        vesper_used = 0
    end

    vesper_totem_heal_charges = nil
    vesper_totem_dmg_charges = nil
    vesper_totem_used_charges = nil

    if totem.vesper_totem.up then
        applyBuff( "vesper_totem", totem.vesper_totem.remains )
    end

    rawset( state.pet, "earth_elemental", talent.primal_elementalist.enabled and state.pet.primal_earth_elemental or state.pet.greater_earth_elemental )
    rawset( state.pet, "fire_elemental",  talent.primal_elementalist.enabled and state.pet.primal_fire_elemental  or state.pet.greater_fire_elemental  )
    rawset( state.pet, "storm_elemental", talent.primal_elementalist.enabled and state.pet.primal_storm_elemental or state.pet.greater_storm_elemental )

    if talent.primal_elementalist.enabled then
        dismissPet( "primal_fire_elemental" )
        dismissPet( "primal_storm_elemental" )
        dismissPet( "primal_earth_elemental" )

        if summon.expires then
            if summon.expires <= now then
                wipe( summon )
            else
                summonPet( summon.type, summon.expires - now )
            end
        end
    end
    
    -- Heat wave has a hidden aura, so we look at the last cast of primordial wave instead
    if talent.heat_wave.enabled then
        local applied = action.primordial_wave.lastCast
        local remains = 12 -(query_time-applied)
        buff.heat_wave.up = false
        
        if remains > 0 and remains <= 12 then
                
            buff.heat_wave.applied = applied
            buff.heat_wave.remains = remains
            buff.heat_wave.up = true
            
            local next_ls = 3 - ( ( query_time - applied ) % 3 )
            if next_ls < remains then
                state:QueueAuraEvent( "heatwave", TriggerHeatWave, query_time + next_ls, "AURA_PERIODIC" )
                for i = 1, remains / 3 do
                    state:QueueAuraEvent( "heatwave", TriggerHeatWave, query_time + next_ls + i*3, "AURA_PERIODIC" )
                end
            end
        end
    end
    
    if buff.fireheart.up then
        if pet.fire_elemental.up then buff.fireheart.expires = pet.fire_elemental.expires
        elseif pet.storm_elemental.up then buff.fireheart.expires = pet.storm_elemental.expires end

        -- Proc the next Lava Surge from Fireheart.
        local next_ls = 8 - ( ( query_time - buff.fireheart.applied ) % 8 )

        if next_ls < buff.fireheart.remains then
            state:QueueAuraEvent( "fireheart", TriggerFireheart, query_time + next_ls, "AURA_PERIODIC" )
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    ancestral_guidance = {
        id = 108281,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "ancestral_guidance",
        startsCombat = false,
        texture = 538564,

        toggle = "defensives",

        handler = function ()
            applyBuff( "ancestral_guidance" )
        end,
    },


    ancestral_spirit = {
        id = 2008,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 136077,
        nocombat = true,

        handler = function () end,
    },


    ascendance = {
        id = 114050,
        cast = 0,
        cooldown = function () return 180 - 30 * talent.oath_of_the_far_seer.rank end,
        gcd = "spell",

        talent = "ascendance",
        startsCombat = true,
        texture = 135791,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ascendance" )
            -- TODO:  Refresh Flame Shock durations to 18 seconds.
        end,
    },


    astral_recall = {
        id = 556,
        cast = 10,
        cooldown = 600,
        gcd = "spell",

        startsCombat = false,
        texture = 136010,

        handler = function () end,
    },


    astral_shift = {
        id = 108271,
        cast = 0,
        cooldown = function () return talent.planes_traveler.enabled and 90 or 120 end,
        gcd = "off",

        talent = "astral_shift",
        startsCombat = false,
        texture = 538565,

        toggle = "defensives",

        handler = function ()
            applyBuff( "astral_shift" )
        end,
    },


    bloodlust = {
        id = 2825,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 136012,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bloodlust" )
            applyDebuff( "player", "sated" )
        end,
    },


    totemic_recall = {
        id = 108285,
        cast = 0,
        cooldown = function () return talent.call_of_the_elements.enabled and 120 or 180 end,
        gcd = "spell",

        talent = "totemic_recall",
        startsCombat = false,
        texture = 538570,

        toggle = "cooldowns", -- Utility?

        handler = function ()
            -- TODO: Reset CD of most recently-used totem with a base CD shorter than 3 minutes.
            -- iterate over all totems
            -- find totem with lowest .lastcast and reset_precast
            -- reset 2 totems if talent.creation_core.enabled
        end,
    },


    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = function () return 60 - 2 * talent.totemic_surge.rank + conduit.totemic_surge.mod * 0.001 end,
        gcd = "totem",

        spend = 0.1,
        spendType = "mana",

        talent = "capacitor_totem",
        startsCombat = false,
        texture = 136013,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "capacitor_totem" )
        end,
    },


    chain_heal = {
        id = 1064,
        cast = function ()
            if buff.chains_of_devastation_ch.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            return 2.5 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.3 end,
        spendType = "mana",

        talent = "chain_heal",
        startsCombat = false,
        texture = 136042,

        handler = function ()
            removeBuff( "chains_of_devastation_ch" )
            removeBuff( "natures_swiftness" ) -- TODO: Determine order of instant cast effect consumption.

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_cl" )
            end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },


    chain_lightning = {
        id = 188443,
        cast = function ()
            if buff.chains_of_devastation_cl.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 ) * ( 1 - 0.03 * min( 10, buff.wind_gust.stacks ) ) * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,
        texture = 136015,

        nobuff = "ascendance",
        bind = "lava_beam",

        handler = function ()
            removeBuff( "chains_of_devastation_cl" )
            removeBuff( "natures_swiftness" )
            removeBuff( "master_of_the_elements" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_ch" )
            end

            -- 4 MS per target, direct.
            -- 3 MS per target, overload.
            -- stormkeeper guarantees overload on every target hit
            -- power of the maelstrom guarantees 1 extra overload on the initial target
            -- surge of power adds 1 extra target to total potential enemies hit

            gain( ( buff.stormkeeper.up and 4 + ( min( (buff.surge_of_power.up and 6 or 5),active_enemies ) * 3) or 4 ) * min( (buff.surge_of_power.up and 6 or 5), active_enemies ), "maelstrom" )
            if buff.power_of_the_maelstrom.up then
                gain( 3 * min( ( buff.surge_of_power.up and 6 or 5 ), active_enemies ), "maelstrom" )
            end
            
            removeStack( "stormkeeper" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "surge_of_power" )

            if pet.storm_elemental.up then
                addStack( "wind_gust", nil, 1 )
            end
    
            if talent.flash_of_lightning.enabled then
                for i = 1, #flash_of_lightning_nature_spells do
                    reduceCooldown( flash_of_lightning_nature_spells[i], 1 )
                end
            end
            
            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end
            
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    cleanse_spirit = {
        id = 51886,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "cleanse_spirit",
        toggle = "interrupts",
        startsCombat = false,
        texture = 236288,

        buff = "dispellable_curse",

        handler = function ()
            removeBuff( "dispellable_curse" )
        end,
    },


    counterstrike_totem = {
        id = 204331,
        cast = 0,
        cooldown = function () return 45 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "counterstrike_totem",
        startsCombat = false,
        texture = 511726,

        handler = function ()
            summonTotem( "counterstrike_totem" )
        end,
    },


    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = function () return 300 * ( buff.deadened_earth.up and 0.6 or 1 ) end,
        gcd = "spell",

        talent = "earth_elemental",
        startsCombat = false,
        texture = 136024,

        toggle = "defensives",

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 )
            if conduit.vital_accretion.enabled then
                applyBuff( "vital_accretion" )
                health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
            end
        end,

        usable = function ()
            return max( cooldown.fire_elemental.true_remains, cooldown.storm_elemental.true_remains ) > 0, "DPS elementals must be on CD first"
        end,

        timeToReady = function ()
            return max( pet.fire_elemental.remains, pet.storm_elemental.remains, pet.primal_fire_elemental.remains, pet.primal_storm_elemental.remains )
        end,
    },


    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "earth_shield",
        startsCombat = false,
        texture = 136089,

        --This can be fine, as long as the APL doesn't recommend casting both unless elemental orbit is picked.
        handler = function ()
            applyBuff( "earth_shield", nil, 9 )
            if not talent.elemental_orbit.enabled then 
                removeBuff( "lightning_shield" )
            end
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },


    earth_shock = {
        id = 8042,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return 60 - 5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "earth_shock",
        notalent = "elemental_blast",
        startsCombat = true,
        texture = 136026,

        handler = function ()
            removeBuff( "master_of_the_elements" )
            removeBuff( "magma_chamber" )
            
            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.echoes_of_great_sundering.enabled or runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering" )
            end

            if talent.windspeakers_lava_resurgence.enabled or runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.lightning_rod.enabled then
                applyDebuff( "target", "lightning_rod" )
            end
                            
            if talent.further_beyond.enabled and buff.ascendance.up then
                --TODO: increase ascendance duration by 2.5 seconds
            end
            
            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end
            
            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end
            
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = function () return 30 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136102,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthbind_totem" )
        end,
    },


    earthgrab_totem = {
        id = 51485,
        cast = 0,
        cooldown = function () return 60 - 2 * talent.totemic_surge.rank end,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "earthgrab_totem",
        startsCombat = false,
        texture = 136100,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthgrab_totem" )
        end,
    },


    earthquake = {
        id = 61882,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            return 60 - 5 * talent.eye_of_the_storm.rank
        end,
        spendType = "maelstrom",

        talent = "earthquake",
        startsCombat = true,
        texture = 451165,

        handler = function ()
            removeBuff( "echoes_of_great_sundering" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "magma_chamber" )
            
            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.lightning_rod.enabled then
                if debuff.lightning_rod.up then
                    active_dot.lightning_rod = min( active_enemies, active_dot.lightning_rod + 1 )
                else
                    applyDebuff( "target", "lightning_rod" )
                end
            end
            
            if talent.further_beyond.enabled and buff.ascendance.up then
                --TODO: increase ascendance duration by 2.5 seconds
            end
            
            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end
            
            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    elemental_blast = {
        id = 117014,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return 2 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        gcd = "spell",

        spend = function () return 90 - 7.5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "elemental_blast",
        startsCombat = true,
        texture = 651244,

        handler = function ()
            removeBuff( "master_of_the_elements" ) 
            applyBuff( "elemental_blast" )
            removeBuff( "magma_chamber" )
            
            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering" )
            end

            if talent.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.lightning_rod.enabled then
                applyDebuff( "target","lightning_rod" )
            end
            
            if talent.further_beyond.enabled and buff.ascendance.up then
                --TODO: increase ascendance duration by 3.5 seconds
            end
            
            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end
            
            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    far_sight = {
        id = 6196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136034,

        handler = function ()
            applyBuff( "far_sight" )
        end,
    },


    fire_elemental = {
        id = 198067,
        cast = 0,
        charges = 1,
        cooldown = 150,
        recharge = 150,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "fire_elemental",
        startsCombat = false,
        texture = 135790,

        toggle = "cooldowns",

        timeToReady = function ()
            return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.storm_elemental.remains, pet.primal_storm_elemental.remains )
        end,

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental" )

            if set_bonus.tier28_2pc > 0 then
                applyBuff( "fireheart", pet.fire_elemental.remains )
                state:QueueAuraEvent( "fireheart", TriggerFireheart, query_time + 8, "AURA_PERIODIC" )
            end
        end,
    },


    flame_shock = {
        id = 188389,
        cast = 0,
        cooldown = function () return talent.flames_of_the_cauldron.enabled and 4.5 or 6 end,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135813,

        cycle = "flame_shock",
        min_ttd = function () return debuff.flame_shock.duration / 3 end,

        handler = function ()
            applyDebuff( "target", "flame_shock" )

            if buff.surge_of_power.up then
                active_dot.surge_of_power_debuff = min( active_enemies, active_dot.flame_shock + 1 )
                removeBuff( "surge_of_power" )
            end
            
            if talent.magma_chamber.enabled then
                addStack( "magma_chamber" )
            end
            
            if talent.searing_flames.enabled then
                gain( talent.searing_flames.rank, "maelstrom" )
                --TODO: should also gain on every tick of damage
            end
            
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135814,

        handler = function ()
            applyBuff( "flametongue_weapon" )
        end,

        auras = {
            flametongue_weapon = {
                duration = 3600,
                max_stack = 1,
            }
        }
    },


    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = true,
        texture = 135849,

        handler = function ()
            removeBuff( "master_of_the_elements" )
            
            applyDebuff( "target", "frost_shock" )

            if buff.icefury.up then
                gain( 8, "maelstrom" )
                removeStack( "icefury", 1 )
            end

            if buff.surge_of_power.up then
                applyDebuff( "target", "surge_of_power_debuff" )
                removeBuff( "surge_of_power" )
            end
            
            if talent.flux_melting.enabled then
                applyBuff( "flux_melting" )
            end
            
            if talent.electrified_shocks.enabled then
                --TODO: Apply debuff to 3 additional targets if hit
                applyDebuff( "target", "electrified_shocks" )
                active_dot.electrified_shocks = min( active_enemies, active_dot.electrified_shocks + 3 )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    ghost_wolf = {
        id = 2645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136095,

        handler = function ()
            applyBuff( "ghost_wolf" )
        end,
    },


    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        talent = "greater_purge",
        startsCombat = true,
        texture = 451166,

        toggle = "interrupts",
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
            removeDebuff( "target", "dispellable_magic" )
        end,
    },


    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = function () return 30 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        pvptalent = "grounding_totem",
        startsCombat = false,
        texture = 136039,

        handler = function ()
            summonTotem( "grounding_totem" )
        end,
    },


    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = function () return 30 - 5 * talent.go_with_the_flow.rank end,
        gcd = "spell",

        talent = "gust_of_wind",
        startsCombat = false,
        texture = 1029585,

        toggle = "interrupts",

        handler = function () end,
    },


    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = 1,
        cooldown = function () return 30 - 2 * talent.totemic_surge.rank end,
        recharge = 30,
        gcd = "totem",

        spend = 0.09,
        spendType = "mana",

        talent = "healing_stream_totem",
        startsCombat = false,
        texture = 135127,

        handler = function ()
            summonTotem( "healing_stream_totem" )
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if conduit.swirling_currents.enabled then applyBuff( "swirling_currents" ) end
            if talent.swirling_currents.enabled then applyBuff( "swirling_currents" ) end
        end,
    },


    healing_surge = {
        id = 8004,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.24 end,
        spendType = "mana",

        startsCombat = false,
        texture = 136044,

        handler = function ()
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if buff.swirling_currents.up then removeStack( "swirling_currents" ) end
        end,
    },


    hex = {
        id = 51514,
        cast = 1.7,
        cooldown = function () return 30 - 15 * talent.voodoo_mastery.rank end,
        gcd = "spell",

        talent = "hex",
        startsCombat = false,
        texture = 237579,

        handler = function ()
            applyDebuff( "target", "hex" )
        end,
    },


    icefury = {
        id = 210714,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "icefury",
        startsCombat = true,
        texture = 135855,

        handler = function ()
            removeBuff( "master_of_the_elements" )

            applyBuff( "icefury", 25, 4 )
            gain( 25, "maelstrom" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    lava_beam = {
        id = 114074,
        cast = function () return buff.stormkeeper.up and 0 or 1.5 end,            
        cooldown = 0,
        gcd = "spell",

        buff = "ascendance",
        bind = "chain_lightning",

        startsCombat = true,
        texture = 236216,

        handler = function ()
            -- 3 MS per target, direct.
            -- 3 MS per target, overload.
            
            gain( ( buff.stormkeeper.up and 4 + ( min( (buff.surge_of_power.up and 6 or 5),active_enemies ) * 3) or 4 ) * min( (buff.surge_of_power.up and 6 or 5), active_enemies ), "maelstrom" )

            removeStack( "stormkeeper" )
            removeBuff( "surge_of_power" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    lava_burst = {
        id = 51505,
        cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
        charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
        cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
        recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "lava_burst",
        startsCombat = true,
        texture = 237582,

        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeBuff( "windspeakers_lava_resurgence" )
            removeBuff( "lava_surge" )
            removeBuff( "flux_melting" )

            gain( 10 + ( talent.flow_of_power.rank * 2 ) , "maelstrom" )

            if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

            if talent.surge_of_power.enabled then
                gainChargeTime( "fire_elemental", 6 )
                removeBuff( "surge_of_power" )
            end

            if buff.primordial_wave.up and state.spec.elemental and talent.splintered_elements.enabled then
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if talent.rolling_magma.enabled then
                reduceCooldown( "primordial_wave", 0.2 * talent.rolling_magma.rank )
            end

            if set_bonus.tier28_4pc > 0 then
                if pet.fire_elemental.up then
                    pet.fire_elemental.expires = pet.fire_elemental.expires + 1.5
                    buff.fireheart.expires = pet.fire_elemental.expires
                elseif pet.storm_elemental.up then
                    pet.storm_elemental.expires = pet.storm_elemental.expires + 1.5
                    buff.fireheart.expires = pet.storm_elemental.expires
                end
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end
    
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        impact = function () end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.
    },


    lightning_bolt = {
        id = 188196,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 ) * ( 1 - 0.03 * min( 10, buff.wind_gust.stacks ) ) * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
            gain( ( talent.flow_of_power.enabled and ( buff.stormkeeper.up and 14 or 10 ) + ( buff.surge_of_power.up and 8 or 0 ) ) or ( buff.stormkeeper.up and 11 or 8 ) + ( buff.surge_of_power.up and 6 or 0 ), "maelstrom" )
            
            if buff.power_of_the_maelstrom.up then
                gain( talent.flow_of_power.enabled and 4 or 3 , "maelstrom" )
            end
            
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "natures_swiftness" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )

            removeStack( "stormkeeper" )
 
            if pet.storm_elemental.up then
                addStack( "wind_gust", nil, 1 )
            end

            if talent.flash_of_lightning.enabled then
                for i = 1, #flash_of_lightning_nature_spells do
                    reduceCooldown( flash_of_lightning_nature_spells[i], 1 )
                end
            end
            
            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    lightning_lasso = {
        id = 305483,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "lightning_lasso",
        startsCombat = true,
        texture = 1385911,

        pvptalent = function ()
            if essence.conflict_and_strife.major then return end
            return "lightning_lasso"
        end,

        start = function ()
            applyDebuff( "target", "lightning_lasso" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = 305485
    },


    lightning_shield = {
        id = 192106,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136051,

        readyTime = function () return buff.lightning_shield.remains - 120 end,

        handler = function ()
            applyBuff( "lightning_shield" )
        end,
    },


    liquid_magma_totem = {
        id = 192222,
        cast = 0,
        cooldown = function () return 60 - 2 * talent.totemic_surge.rank end,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "liquid_magma_totem",
        startsCombat = false,
        texture = 971079,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "liquid_magma_totem" )
            --TODO: Apply FS to 3 targets
            if active_enemies >= 4 then
                active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 3 )
            else
                applyDebuff( "flame_shock" )
                active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 2 )
            end
            
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    mana_spring_totem = {
        id = 381930,
        cast = 0,
        cooldown = function () return 45 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        talent = "mana_spring_totem",
        startsCombat = false,
        texture = 136053,

        handler = function ()
            summonTotem( "mana_spring_totem" )
        end,
    },


    natures_swiftness = {
        id = 378081,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "natures_swiftness",
        startsCombat = false,
        texture = 136076,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "natures_swiftness" )
        end,
    },


    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = function () return 45 - 2 * talent.totemic_surge.rank end,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "poison_cleansing_totem",
        startsCombat = false,
        texture = 136070,

        handler = function ()
            summonTotem( "poison_cleansing_totem" )
        end,
    },


    primal_strike = {
        id = 73899,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 460956,

        handler = function ()
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    primordial_wave = {
        id = 375982,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "primordial_wave",
        startsCombat = true,
        texture = 3578231,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            applyBuff( "primordial_wave" )
            if talent.heat_wave.enabled then 
                applyBuff( "lava_surge" )
                state:QueueAuraEvent( "heatwave", TriggerHeatWave, query_time + 3, "AURA_PERIODIC" )
                state:QueueAuraEvent( "heatwave", TriggerHeatWave, query_time + 6, "AURA_PERIODIC" )
                state:QueueAuraEvent( "heatwave", TriggerHeatWave, query_time + 9, "AURA_PERIODIC" )
                state:QueueAuraEvent( "heatwave", TriggerHeatWave, query_time + 12, "AURA_PERIODIC" )
            end
        end,
    },


    purge = {
        id = 370,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "purge",
        startsCombat = true,
        texture = 136075,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
        end,
    },


    skyfury_totem = {
        id = 204330,
        cast = 0,
        cooldown = function () return 40 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "skyfury_totem",
        startsCombat = false,
        texture = 135829,

        handler = function ()
            summonTotem( "skyfury_totem" )
        end,
    },


    spirit_walk = {
        id = 58875,
        cast = 0,
        cooldown = function () return 60 - 7.5 * talent.go_with_the_flow.rank end,
        gcd = "spell",

        talent = "spirit_walk",
        startsCombat = false,
        texture = 132328,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spirit_walk" )
        end,
    },


    spiritwalkers_grace = {
        id = 79206,
        cast = 0,
        cooldown = function () return 120 - 30 * talent.graceful_spirit.rank end,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        talent = "spiritwalkers_grace",
        startsCombat = false,
        texture = 451170,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spiritwalkers_grace" )
        end,
    },

    stoneskin_totem = {
        id = 383017,
        cast = 0,
        cooldown = function () return 30 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        talent = "stoneskin_totem",
        startsCombat = false,
        texture = 4667425,

        handler = function ()
            summonTotem( "stoneskin_totem" )
            applyBuff( "stoneskin" )
        end,
    },


    storm_elemental = {
        id = 192249,
        cast = 0,
        charges = 1,
        cooldown = 150,
        recharge = 150,
        gcd = "spell",

        talent = "storm_elemental",
        startsCombat = true,
        texture = 2065626,

        toggle = "cooldowns",

        timeToReady = function ()
            return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.fire_elemental.remains, pet.primal_fire_elemental.remains )
        end,

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )

            if set_bonus.tier28_2pc > 0 then
                applyBuff( "fireheart", pet.storm_elemental.remains )
                state:QueueAuraEvent( "fireheart", TriggerFireheart, query_time + 8, "AURA_PERIODIC" )
            end
        end,
    },


    stormkeeper = {
        id = 191634,
        cast = 1.4996629966736,
        charges = function () return ( talent.stormkeeper.enabled and talent.stormkeeper_2.enabled ) and 2 or nil end,
        cooldown = 60,
        gcd = "spell",

        talent = function () return talent.stormkeeper.enabled and "stormkeeper" or talent.stormkeeper_2.enabled and "stormkeeper_2" end,
        startsCombat = true,
        texture = 839977,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "stormkeeper", nil, 2 )
        end,
    },


    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = function () return 30 - 5 * talent.thundershock.rank end,
        gcd = "spell",

        talent = "thunderstorm",
        startsCombat = true,
        texture = 237589,

        handler = function ()
            if target.within10 then applyDebuff( "target", "thunderstorm" ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    totemic_projection = {
        id = 108287,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "totemic_projection",
        startsCombat = false,
        texture = 538574,

        handler = function () end,
    },


    tranquil_air_totem = {
        id = 383019,
        cast = 0,
        cooldown = function () return 60 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        talent = "tranquil_air_totem",
        startsCombat = false,
        texture = 538575,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tranquil_air_totem" )
        end,
    },


    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = function () return 60 - 2 * talent.totemic_surge.rank + ( conduit.totemic_surge.mod * 0.001 ) end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        talent = "tremor_totem",
        startsCombat = false,
        texture = 136108,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tremor_totem" )
        end,
    },


    water_walking = {
        id = 546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135863,

        handler = function ()
            applyBuff( "water_walking" )
        end,
    },


    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = function () return 120 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        talent = "wind_rush_totem",
        startsCombat = false,
        texture = 538576,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "wind_rush_totem" )
        end,
    },


    wind_shear = {
        id = 57994,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        talent = "wind_shear",
        startsCombat = true,
        texture = 136018,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    -- Pet Abilities
    meteor = {
        id = 117588,
        known = function () return talent.primal_elementalist.enabled and not talent.storm_elemental.enabled and fire_elemental.up end,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = true,
        texture = 1033911,

        talent = "primal_elementalist",

        usable = function () return fire_elemental.up end,
        handler = function () end,
    },

    eye_of_the_storm = {
        id = 157375,
        known = function () return talent.primal_elementalist.enabled and talent.storm_elemental.enabled and storm_elemental.up end,
        cast = 0,
        cooldown = 40,
        gcd = "off",

        startsCombat = true,
        -- texture = ,

        talent = "primal_elementalist",

        usable = function () return storm_elemental.up end,
        handler = function () end,
    },
} )


spec:RegisterStateExpr( "funneling", function ()
    return false
    -- return active_enemies > 1 and settings.cycle and settings.funnel_damage
end )


spec:RegisterSetting( "stack_buffer", 1.1, {
    name = "|T135855:0|t Icefury and |T839977:0|t Stormkeeper Padding",
    desc = "The default priority tries to avoid wasting |T839977:0|t Stormkeeper and |T135855:0|t Icefury stacks with a grace period of 1.1 GCD per stack.\n\n" ..
            "Increasing this number will reduce the likelihood of wasted Icefury / Stormkeeper stacks due to other procs taking priority, and leave you with more time to react.",
    type = "range",
    min = 1,
    max = 2,
    step = 0.01,
    width = "full"
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Elemental",
} )


spec:RegisterPack( "Elemental", 20220801, [[Hekili:T3Z(VTnoA(3IXcOXUtxx)kPTdIdWm9gCOfZnhW65WD)KLvKzIfQSKxj5Kjag(V99JuViP4hF4hT7I9WUOtIef537NKmlhV8pwUyDqbz5Vpz0KjJ(WOXdhd)ZSjlxu86oYYf7cc)AWtWpKeSf(3FnMSLKueetFZRXPbRPZqE6(Sq4TBkk2L)tV7DpfvSz)dddt3(U8OT7JdkIstcZcESG(7HVB5Ih2hfx85KLpOC5NEdmN7iHWJVfGKnrRxtkhljpKdioUAXMGTbjh)YpV)P95fhxn(ThxrNQJF54x(0MGKNi5)0XV8xpU6ZjHPz7sZGf74QCsrruYt5dZla0Z)H9p(ij74QhtH)5ZHKh3N9kmplksZ2(vczhjBiBo(51RpU6)IuqOJlib(LF9vy2sF84QInKQpaEZtbrjdbcuw6JrXaz5V8xGr2fMPpwfCtFElSt)Tlb8xnpoHdmObgXFsc3xqGXsEMK9kmYOTKQXhewqNPOC4hFoiko4Hyc8DWJbwE(WDzeqk4HGI5KGSIn(KAYWBJECEp4)c)cmOOTbXTVlkVyijHotRzR))toraBoUQzApUAFsmjhw98ukmfSEn8ZVefd058DbVKqFrAIki6hN)UhHpDdtUKcoGuC8drjRhUdyj7Jj(KS97OF0HdnV65uQWm8U804NbGv98M3cR0jUcn5EAn651pliATpHovdPWoOZSpP4UPhoi)IOK7Vz0ae8ikJ0s(upMMx7)qCqEbhCj9Mgyd0aJJ9lcYEIuaa2gqIWpo6PnfjGS3DtzSMFHegSNYE(TN)LJR2eqfdajJSGNjXLYjVTwqz96uGBSloiKaJ6nfBOYmW6M96Ba5p4vF6)OseEkvcpmnHYklsPcwPrGW3609aC9xzReBQ2hhJWyJbzrqTidWZ4OeIF465t5L4oru(WbQQMaJC)o1qG03E2l(9ZN61Z6vFxk9zvQVFoPGKrfLlvZdH1mVLUbJ(fqY2pFdOHY)08DrzrfVee)vswU)tzaF7TBtFgGL5J5hx9A1(eqGWpQGSnN)HpgdoqGvjn8RuIrFduJbE9kIc)kSAE92rQuEALXhsN4NjE9nYXQwMTWCtY8tF0hKgRNN86vdu32NqaHVNidZ)6RpKrcyy9JrG9o)1KTr5KHK)((OD7aqta7bBxPzRJa4)fqO)THVgcwhQGN5Jz8DgBtAGaRZRVgmdS5OhZ8yZkJ1rDHu6k4UjJ4mwftcw7)WR(K)my7oWSSkKDhOFaegYAoAsnEAI6EZ1G6EjH)kfgfJHtXPRSzJK3vHbzKSE9fAr8xaVzBzKbCp5H4001(Sqk4SHfKhsswhKeYXvy4l3l2V7WHW0041PVKW)8mYwaHZb3zcRda6KSVkzR0U1rg3yWS7tJlGl9v5GFUy)WG44R7A9mbeyY8lsbBQcOAayPjlij)X95WJOarykeXqaafjuXjFyeE94KsiK15uXPmqHcgfyvp9LInncjEnwLnj5XqiKbTF3atosDhl(2JeguWbhYGMCdtuuLQHrsTh3mgzdjTdsq7eqv)YFZNgk8BPzEnpiL8wqElkSO0PsPriFscOMtGPWGrL7NiJoLHirc2E)eZREomfnU1eGJE8b3YHB1b1icN3nFI51cSeJUCUVATbibKW5sFiddWTXl8T0yOFLulOW(a6NZeIO2aAj2nm25Jh1zkOPb933dwQB(ys4Mu4Rk9)iesx5NuYk3eKb2bkKFP1PAi)H8(8ue0sg5Xmi5i6N61VFfDDDAXqUV7UjDi4t9AK2Ld4PIOC34B9A1VjHzPXWO0fK3Hdil)yPL)(5Z0gSOvMfgC4qFh8RQBbLMknHQ4HrHNYB(MkOqyM(EcGPc)89jRjzubU2GNqMNz82QW5mv2e7gR6Gbd0jarvJuVY6JE3koIBX5ypnVjmpmCUJUlVIkFc0ckW12I2gqIbtxPBVF(TJ867cB0RXUG6XrDo5KCrhuPnMdo8OBKlAJaEqRN2OYIo1YXkJ8U(XqUo9AK(AFyhOkocG31(BdEABqz4oCqx3xIzAtrU36JhzMN(qbA5L3DJAl6TYeUWwQsqrhJUdjQTYgWIjPSvRjBi8RzMyRmOITs57PycL)zGczLMCxnkbVHgI3AIB2cT06cVE6nJmHNDfzB5hk8IQWrNtOqoPW)H0K95dlaJDt(G)SDHEOCNUMWCdAvmXOLUq5lQDKm9npfI6lspBg9RUqEcNpthl8muPCWhLkoODYQM0cfKLpn8SVHQt4gMAfAr9zB1aDtxfSY5MeJrJXdesM2eY3nKj74aAP)ZDJ()9rsZnZ6w4(USoECj1iyP5nDEnRwBUz87kAQ9Qp7kMitkX6Jaqw0Sks5o856p8c1tPB0dwQjcKGTAJH1G4LgkBD3oqiX1r06dQGHDsmNp9OMjsFI2DMIS08cPPGVGgYvk5KRUH8eXcfVI(aITXTczmKNApyx6ls9FsXKyrZruvkaSGoSQC(QGJZQUnkMpEgtRONusqEYPaj871gWu2k)wJA1dN9w1Duy8h0dRwxNNVvO84HJrqq9mrxn2OD2oH6MPcMCQIanPa3AJPHOmhOigSoo5WbXAkyYX6viai92meCk1hrATsnM1JMy6lGPTAPfSV6WsPLQ3GurC1y1ePwpxxi8Ml9IlerKdwMr2wagHFJmDZZvR8VbYQCrXukIq7zs74(4iXs6zwo2IQQmGVMI01hG7YWOzcwGfrQqiliIQj1mrOHGAOtmJP1nRBS)nMHnOJ1H7RP(QDu0CqNI9TQ7YQ5pgl0ih)qpG2bdl)EoDmSmwU8EV0oJinLrPdyLBYm5DswLuR8J93SFBqsA0AaGEBu9o5XpA7wceBubH6fV5PpfN(qqSWJ0TKgCqcJn0FDuEjtqWlP4RSIfCA7)VMTcHMXyBsdOCrHunl)SMwkn2uJvhJ3y1XUOkRDOpe8etUpdYdl36W9CoTdBNp47HFMrOhcsbfude3FR1AGkZLHF8Z7ALRFhNCwgbDNYcmazrpvZeNFC9Aai9bV3VUfwhoGumjwCLnkrkAWd231xZ2t5hL9nSEFgBlEpWtZxX6bz3W8Q7vKq8GNmfHnvksDuT4U0CBDtXO7RvAamvHTka6C9zTBy(3p6s20mlCGlwXI(og0tniD5A7ZzNuNx)2EX9(r1BXpS4u64tZYK(CEFzZdwZMPdHVOzmARSG75OOzMp3M0EMPJyNmNHo6Qd9Si9k77x8TJUCiULnjPVEGJBdPPYafFkAFSZUgRBgDQOoMeBH0VSDp61mvY2dAMpCpTt0Ph6qlkg7PlFn36l5LB3j6ax0eDO1AKJoi8CX6R2m96BYtJKVrRDdE6zu6j7p22L0(52cliCD60YI0ONd7uPumQ(pWwJsMXaZ2T(3dlt2LeIvaP6uvofNI2xAixugTJuJp5vyMgYuV24YUF6n6z)JoBMIm5UVWdQxiQaWmfPbQ80LzR8Ov2dXhdwbgKjdNsZK0tk5mh1Ohrn)eh9qw0(TDQQRQb5VMWEjnLjdPp0txOW6q8)fOiEsWmwjkVeI26YX6CQBOsFxUx0qwbbLosg014znYLkQfOHWcTnjc70NCVAD2mzrMkvNgPHoN2ZlJSZ5xWSLlEgIkfGOQ7nG3pE6YfVeKrP45lx8)(Z)TF)Z)()5pDC1Xv)b9ShhTDxAwr1Pl(heqIF44QmQLKm6XBV6mKVViDBa78UhwEm8hE8l)wuc8QPJGj9tPjWYZE)p0Ow()9dLNvzUNuJ)WB6p(phWon9gaTMZWRBG1KZcQoR5GEe8)1)7FZEuuU2WoIPZonWSb6(mdyOF6nSlVGi6jjNA8GUglxal9M0SLlw0CTv8jQr)LlydHDxxWd8Wd(D2DOr1kT8xwUimlcSBhfSCr)JR64rVsC)4Q7qVghEZXv0s7q)VD(8Y6fVAaaPmyNcy8MAwwaQeOaKA9ZJR8Qwjo77DE2ja4s6S1qmNrdk4ovcCBgwR5mjIAp6nlq5gsB1Hd0lgaL1Wga15vqeDufy1ZLHR4Zbi8aYH411(4QFScFvurCGvXMETFpSeZQhyTmJ4wHGHa9QELqdDPIccomOcKavDMBuv2eRyBhsbjoNpQxRBmjWHqZ7xFtICpWNUDujwQcfRhTMW3Hj54QrCJTxdhVJ4opXusKVh3IW)kofUwKHI73II7QyJLGMJfzreGXZEJo7wLRGO9JgsjfDEVjwjsC11Owt2wmP633Wq61vfz)UwGqAwPqYhmbjQ2Rw1eyvfVNbrtljMDlIpt(5gEbiruz2mbQg3Itb2pAcyvNUHGLbvY0vgW4iu8ZdDLhp60x6YeQKk8pMKXyC)CfMQ9pV3k5XWMBCxwnWiAHVCqS3ZKoehHUP(Wmau2jLeakT5RmVqSHikHD7iDo1hlBq3vsuFxOs9nd)u1ilShlIMud9FCs5hRn5kgfzslHubb2gfhM6CL1tlXEb8cP0ELZV5OGMiyZqsKc3RPbkdqyhxBuvtFjQhIl17TRZtBixxvrfCciURxNDW6zW9uBj0zRmUxsPn(wl50ensoCBPGoKSfJ7Cubau1YdgzUWCRje8x3coOWIv((SAXS2Ajv24MrcFRo7FyG(eCFN9DvVXAlAdC3ASn4OlMT))niRuTEIXiCuL4SLyHk9BJrjGMZ8edbmHyhts8hpOgfwrSLHHUA4bWOH62touCWg20BStCBKaZUA2zGIXewTTcj91uKKAzUzifeHZ3PSYKBkidWftyUivWp4qE6WEp)WeAfK8iLD8yOScglDWeCVh22yirtK6BpKKKSUKz7j4SStcu4LZc3PcApCuATxxtKaXzUMdPzMfgyD7MwUympNRUZw8JTSju0bsrPX8YhcTvss(y6LO2J4KwCdwf67WeFI7IJGnV4MMALc0Dj1wRWI21jzFonVNT8NvMaYmMMxZMArdaIzvkX6ygbkB5dv5S6T(vpbvxxwPgt7xCXKTJ0zXANLoTVIH33IapTiaDz(O14eNKMiOoZybwSqKU7ZUwLtVGEjz)yW(yL9MGE)zNfTR8dvEVW2oVT3kSmd12sjvCTXkZ85LjlV9yLP58JO52KvAq4An9TYgFtHjB6LGxJsmYbMUYLV5aLNk0YbtoWzvK0(l1brp(Cc)fDlhDdzwS0(sM4yIxiv)VVrIID5omTvhq6a)vMArv5)nD5V2HAP5g(IlzlZW3nxxw21c3Q5EQpv8Qd6cV8fsAdFd59oWP(UPC9bEZsI(5LSn9r(rwEN6kncn1TVN2Ev2K0G4gWtmnzvDzK1FdUW8BUxFzGdEUVNc4WTmnxRVSLbp(WtzzChRBUDGzqdE8KFBGg6lBVeHzGKGRp(l(xz5hC3FDV9CRTuWPhy4s0Lt93b9mtfFQuj3cnCogM4Tdmd1Xl8lcQ)9gVTWkjTqCtv1QB1xSWmrPAFMnJv2kT8GhONUI7xO0CF9HITC(S0GD5q7sbkRgbjyB9qgqtoJEt)YIVSgoZeVIGl3io(L)XOjiTSra4vdVLnktAiCbRlJD0IhnXzOrCJbvytLX)gaus72QYmeA2MzQYrOEALZuvm5bN)BcJZzv3K1HcyJVOfcG1f4pvmkRyJ8Fsye1)nwyNM0EmknCf2qd8f)qyxlmZ64zmwWuDvsZj79stKUCA4RNz1FLxwUyQA5SZe(qRvRK4339)C4yo8(ZMEu5PIp3djssndsrbP(GPC)lknRRDFvQnNejPDXsTzOTjQVoWkr5XCXTjFFIPx9UP3Drk3MnID1wqNuxPwnQsQWCcQLamvmZL1V2cv)gpwsBjbUghQYLwPKutemi3OSSjz8TvJv(gJZMk3q1F1aGJvcGu((mBMDpRdxSQ9N9DmPuZGGYjwBbe8mX1M2nVbBBfUMzDMQOCnX3Bm)QQkvdk))NqXoWatZKBpx6HV71G4uyMsfVbNCPVahADZJUxcL2tb3oQj0fNKD8SARoqPnolwY34F5DrPXi1X3bZMvlLZO8QUFKnVFqpJTPjUlzZXqnRL5A9(85oXYLOiEcnfuYnPdp72MnYPh1UNWW9)JE0cmhRvdDZbbngo0DFN3ZkIVLg0W3zA4Ts1IWkNCAoCCYwCxBvs7KmD1VclQTovJtvokQktLqimoJ1QUvPBvZWLb66vqTVZovAtpAHSQg6UKYxZ7)FABRq1fAXCJAtg(6Rq4oLXpIezIM6TDjmz4uah4Ym2RwzHcKkLputj4rJOJ803MIsEYejlPgTXVz5hCowLACp4UCRr)DCTz0js1aD(iWJ26mK7NFQS0)ztUxZUs2gxOyUO0S7w7ueheRVOhivTHO1zVQQ3jY12NMMD96LCPr4TgofpDxdBnKzBaIi)LDafGnwMPZOsIL76c7aETviEcEhbrZFtgJjbSCCe3lSYIZILGRZUHT8hvUl2qyVIB0A16gcBPTj2VL2UaBtVrwVyy7FUcf9G67tXD78NUc(0Df2yKkQMB9i1SpQWRlPUaGBQHUd7FhdgroNQyBuD)7YMDSDgvT9HGafvkhEw11wnL34XJ(SjpJho(e35Nwu9o1MQ1AA1yLXCPndMlo15DoPT0Pt1(rqDjlTjgRREm3lXlvPMIW1xRsIG5MoxWcnqMGpk0q4nUp)D8uNBdP)oHOBLaiJDx)kaqAJ320b2gRPPD9fPzREzuwcf6WJyYcUGQeAAR4pQmy9(vs84C9XrQ73Hn6tE2v12MfWXdgSe1Jtje3rG5IpuE(T5BmG2tXnErhXn4BOZvDmbOv8d3faBES7SgIB53IqG1N(65FKNrxuJM5SWFpQ)6jt7MQH6E9RjTrJB9ibLK)55mLzoXYt7SCPjvWE2SRZkTtyZ4CoV1UN8RjoTJlhxVMwzFX0oUCSaWPQUnc7vhj7csYNc73DDhGuhYO8cK(QSnJolw7SCoNYmRpBuAYsU8)T8F8]] )