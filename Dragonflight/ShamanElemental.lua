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
    aftershock                    = { 77594, 273221, 1 }, --
    ancestral_defense             = { 77677, 382947, 1 }, --
    ancestral_guidance            = { 77696, 108281, 1 },
    ancestral_wolf_affinity       = { 77576, 382197, 1 },
    ascendance                    = { 77597, 114050, 1 },
    astral_bulwark                = { 77650, 377933, 1 },
    astral_shift                  = { 77651, 108271, 1 },
    brimming_with_life            = { 77679, 381689, 1 },
    call_of_fire                  = { 77605, 378255, 1 },
    call_of_the_elements          = { 77685, 108285, 1 },
    call_of_thunder               = { 77581, 378241, 1 },
    capacitor_totem               = { 77665, 192058, 1 },
    chain_heal                    = { 77657, 1064  , 1 },
    chain_lightning               = { 77655, 188443, 1 },
    cleanse_spirit                = { 77669, 51886 , 1 },
    creation_core                 = { 77684, 383012, 1 },
    deeply_rooted_elements        = { 77597, 378270, 1 },
    earth_elemental               = { 77658, 198103, 1 },
    earth_shield                  = { 77700, 974   , 1 },
    earth_shock                   = { 77578, 8042  , 1 },
    earthgrab_totem               = { 77676, 51485 , 1 },
    earthquake                    = { 77579, 61882 , 1 },
    echo_chamber                  = { 77607, 382032, 2 },
    echo_of_the_elements          = { 77593, 333919, 1 },
    echoes_of_great_sundering     = { 77585, 384087, 2 },
    electrified_shocks            = { 77590, 382086, 1 },
    elemental_blast               = { 77588, 117014, 1 },
    elemental_equilibrium         = { 77587, 378271, 2 },
    elemental_fury                = { 77577, 60188 , 1 },
    elemental_orbit               = { 77699, 383010, 1 },
    elemental_warding             = { 77678, 381650, 2 },
    enfeeblement                  = { 77672, 378079, 1 },
    eye_of_the_storm              = { 77589, 381708, 2 },
    fire_and_ice                  = { 77661, 382886, 1 },
    fire_elemental                = { 77575, 198067, 1 },
    flames_of_the_cauldron        = { 77604, 378266, 1 },
    flash_of_lightning            = { 77584, 381936, 1 },
    flow_of_power                 = { 77592, 385923, 1 },
    flurry                        = { 77653, 382888, 1 },
    flux_melting                  = { 77590, 381776, 1 },
    focused_insight               = { 77652, 381666, 2 },
    frost_shock                   = { 77668, 196840, 1 },
    further_beyond                = { 77595, 381787, 1 },
    go_with_the_flow              = { 77683, 381678, 2 },
    graceful_spirit               = { 77659, 192088, 1 },
    greater_purge                 = { 77670, 378773, 1 },
    guardians_cudgel              = { 77664, 381819, 1 },
    gust_of_wind                  = { 77682, 192063, 1 },
    healing_stream_totem          = { 77694, 5394  , 1 },
    heat_wave                     = { 77572, 386474, 1 },
    hex                           = { 77673, 51514 , 1 },
    icefury                       = { 77591, 210714, 1 },
    improved_call_of_the_elements = { 77684, 383011, 1 },
    improved_flametongue_weapon   = { 77603, 382027, 1 },
    improved_lightning_bolt       = { 77692, 381674, 2 },
    inundate                      = { 77580, 378776, 1 },
    lava_burst                    = { 77656, 51505 , 1 },
    lava_surge                    = { 77573, 77756 , 1 },
    lightning_lasso               = { 77690, 305483, 1 },
    lightning_rod                 = { 77586, 210689, 1 },
    liquid_magma_totem            = { 77602, 192222, 1 },
    maelstrom_weapon              = { 77654, 187880, 1 },
    magma_chamber                 = { 77601, 381932, 2 },
    mana_spring_totem             = { 77697, 381930, 1 },
    master_of_the_elements        = { 77598, 16166 , 2 },
    mountains_will_fall           = { 77606, 381726, 1 },
    natures_fury                  = { 77680, 381655, 2 },
    natures_guardian              = { 77675, 30884 , 2 },
    natures_swiftness             = { 77693, 378081, 1 },
    oath_of_the_far_seer          = { 77596, 381785, 2 },
    planes_traveler               = { 77650, 381647, 1 },
    poison_cleansing_totem        = { 77687, 383013, 1 },
    power_of_the_maelstrom        = { 77609, 191861, 2 },
    primal_elementalist           = { 77602, 117013, 1 },
    primordial_bond               = { 77574, 381764, 1 },
    primordial_fury               = { 77576, 378193, 1 },
    primordial_wave               = { 77608, 375982, 1 },
    purge                         = { 77670, 370   , 1 },
    refreshing_waters             = { 77574, 378211, 1 },
    rolling_magma                 = { 77571, 386443, 2 },
    searing_flames                = { 77599, 381782, 2 },
    skybreakers_fiery_demise      = { 77600, 378310, 1 },
    spirit_walk                   = { 77682, 58875 , 1 },
    spirit_wolf                   = { 77666, 260878, 1 },
    spiritwalkers_aegis           = { 77659, 378077, 1 },
    spiritwalkers_grace           = { 77660, 79206 , 1 },
    splintered_elements           = { 77572, 382042, 1 },
    static_charge                 = { 77664, 265046, 1 },
    stoneskin_totem               = { 77689, 383017, 1 },
    storm_elemental               = { 77575, 192249, 1 },
    stormkeeper                   = { 77586, 191634, 1 },
    stormkeeper                   = { 77583, 191634, 1 },
    surge_of_power                = { 77594, 262303, 1 },
    surging_shields               = { 77686, 382033, 2 },
    swelling_maelstrom            = { 77610, 381707, 1 },
    swirling_currents             = { 77695, 378094, 2 },
    thunderous_paws               = { 77666, 378075, 1 },
    thundershock                  = { 77690, 378779, 1 },
    thunderstorm                  = { 77691, 51490 , 1 },
    totemic_focus                 = { 77688, 382201, 2 },
    totemic_projection            = { 77674, 108287, 1 },
    totemic_surge                 = { 77698, 381867, 2 },
    tranquil_air_totem            = { 77689, 383019, 1 },
    tremor_totem                  = { 77663, 8143  , 1 },
    tumultuous_fissures           = { 77580, 381743, 1 },
    unrelenting_calamity          = { 77582, 382685, 1 },
    voodoo_mastery                = { 77672, 204268, 1 },
    wind_rush_totem               = { 77676, 192077, 1 },
    wind_shear                    = { 77662, 57994 , 1 },
    winds_of_alakir               = { 77681, 382215, 2 },
    windspeakers_lava_resurgence  = { 77600, 378268, 1 },
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
        id = 974,
        duration = 600,
        type = "Magic",
        max_stack = 9,
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
        tick_time = function () return 2 * haste end,
        type = "Magic",
        max_stack = 1,
    },
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    hex = {
        id = 51514,
        duration = 60,
        max_stack = 1,
    },
    icefury = {
        id = 210714,
        duration = 15,
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
    static_discharge = {
        id = 342243,
        duration = 3,
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
    unlimited_power = {
        id = 272737,
        duration = 10,
        max_stack = 99,
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
    -- Legendaries
    echoes_of_great_sundering = {
        id = 336217,
        duration = 25,
        max_stack = 1
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
    windspeakers_lava_resurgence = {
        id = 336065,
        duration = 15,
        max_stack = 1,
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

spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5401 then applyBuff( "windfury_weapon" ) end
    if oh and oh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end

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
        cooldown = 180,
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

        startsCombat = true,
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


    call_of_the_elements = {
        id = 108285,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "call_of_the_elements",
        startsCombat = false,
        texture = 538570,

        toggle = "cooldowns", -- Utility?

        handler = function ()
            -- TODO: Reset CD of most recently-used totem with a base CD shorter than 3 minutes.
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
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 ) * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
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
            removeBuff( "natures_swiftness" ) -- TODO: Determine order of instant cast effect consumption.
            removeBuff( "master_of_the_elements" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_ch" )
            end

            -- 4 MS per target, direct.
            -- 3 MS per target, overload.

            gain( ( buff.stormkeeper.up and 7 or 4 ) * min( 5, active_enemies ), "maelstrom" )
            removeStack( "stormkeeper" )

            if pet.storm_elemental.up then
                addStack( "wind_gust", nil, 1 )
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
        cooldown = 45,
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

        handler = function ()
            applyBuff( "earth_shield", nil, 9 )
            removeBuff( "lightning_shield" )
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },


    earth_shock = {
        id = 8042,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            return 60 - 5 * talent.eye_of_the_storm.rank
        end,
        spendType = "maelstrom",

        talent = "earth_shock",
        notalent = "elemental_blast",
        startsCombat = true,
        texture = 136026,

        handler = function ()
            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering" )
            end

            if runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = 30,
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
        cooldown = 60,
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

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    echoing_shock = {
        id = 320125,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 1603013,

        talent = "echoing_shock",

        handler = function ()
            applyBuff( "echoing_shock" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    elemental_blast = {
        id = 117014,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return 2 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 12,
        gcd = "spell",

        spend = function ()
            return 90 - 7.5 * talent.eye_of_the_storm.rank
        end,
        spendType = "maelstrom",

        talent = "elemental_blast",
        startsCombat = true,
        texture = 651244,

        handler = function ()
            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering" )
            end

            if runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            applyBuff( "elemental_blast" )

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
        cooldown = 6,
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

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
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
        end,
    },


    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = 30,
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
        cooldown = 30,
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
        cooldown = 30,
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

            applyBuff( "icefury", 15, 4 )
            gain( 25, "maelstrom" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    lava_beam = {
        id = 114074,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        buff = "ascendance",
        bind = "chain_lightning",

        startsCombat = true,
        texture = 236216,

        handler = function ()
            removeBuff( "echoing_shock" )

            -- 4 MS per target, direct.
            -- 3 MS per target, overload.

            gain( ( buff.stormkeeper.up and 7 or 4 ) * min( 5, active_enemies ), "maelstrom" )
            removeStack( "stormkeeper" )

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
            removeBuff( "echoing_shock" )

            gain( 10, "maelstrom" )

            if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

            if talent.surge_of_power.enabled then
                gainChargeTime( "fire_elemental", 6 )
                removeBuff( "surge_of_power" )
            end

            if buff.primordial_wave.up and state.spec.elemental and legendary.splintered_elements.enabled then
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if set_bonus.tier28_4pc > 0 then
                if pet.fire_elemental.up then
                    pet.fire_elemental.expires = pet.fire_elemental.expires + 1.5
                    buff.fireheart.expires = pet.fire_elemental.expires
                elseif pet.storm_elemental.up then
                    pet.storm_elemental.expires = pet.storm_elemental.expires + 1.5
                    buff.fireheart.expires = pet.storm_elemental.expires
                end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        impact = function () end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.
    },


    lightning_bolt = {
        id = 188196,
        cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
            removeBuff( "echoing_shock" )

            gain( ( buff.stormkeeper.up and 11 or 8 ) + ( buff.surge_of_power.up and 3 or 0 ), "maelstrom" )

            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )

            removeStack( "stormkeeper" )

            if pet.storm_elemental.up then
                addStack( "wind_gust", nil, 1 )
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
            removeBuff( "echoing_shock" )
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
        cooldown = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "liquid_magma_totem",
        startsCombat = false,
        texture = 971079,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "liquid_magma_totem" )
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    mana_spring_totem = {
        id = 381930,
        cast = 0,
        cooldown = 45,
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
        cooldown = 45,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "poison_cleansing_totem",
        startsCombat = false,
        texture = 136070,

        handler = function ()
            summonTotem( "poison_cleaning_totem" )
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
        cooldown = 40,
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
        cooldown = 60,
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
        cooldown = 120,
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


    static_discharge = {
        id = 342243,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = off,
        texture = 135845,

        talent = "static_discharge",
        buff = "lightning_shield",

        handler = function ()
            applyBuff( "static_discharge" )
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    stoneskin_totem = {
        id = 383017,
        cast = 0,
        cooldown = 30,
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
        cooldown = 60,
        gcd = "spell",

        talent = "stormkeeper",
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
        cooldown = 30,
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
        cooldown = 60,
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
        cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
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
        cooldown = 120,
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