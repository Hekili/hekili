-- ShamanEnhancement.lua
-- September 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindPlayerAuraByID = ns.FindPlayerAuraByID
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo

local spec = Hekili:NewSpecialization( 263 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    alpha_wolf                    = { 69736, 198434, 1 }, -- x
    ancestral_defense             = { 69728, 382947, 1 }, -- Passive
    ancestral_guidance            = { 69685, 108281, 1 }, -- x
    ancestral_wolf_affinity       = { 69731, 382197, 1 }, -- x
    ascendance                    = { 69751, 114051, 1 }, -- x
    astral_bulwark                = { 69723, 377933, 1 }, -- Passive
    astral_shift                  = { 69724, 108271, 1 }, -- x
    brimming_with_life            = { 69680, 381689, 1 }, -- Passive
    call_of_the_elements          = { 69687, 108285, 1 }, -- Track most recent totem cast with CD < 3 minutes.
    capacitor_totem               = { 69722, 192058, 1 }, -- x
    chain_heal                    = { 69707, 1064  , 1 }, -- x
    chain_lightning               = { 69718, 188443, 1 }, -- x
    cleanse_spirit                = { 69712, 51886 , 1 }, -- x
    crash_lightning               = { 69749, 187874, 1 }, -- x
    crashing_storms               = { 69750, 334308, 1 }, -- x
    creation_core                 = { 69686, 383012, 1 }, -- Make Call of the Elements affect the last 2 totems.
    deeply_rooted_elements        = { 69751, 378270, 1 }, -- Passive
    doom_winds                    = { 69745, 384352, 1 }, -- x
    earth_elemental               = { 69708, 198103, 1 }, -- x
    earth_shield                  = { 69709, 974   , 1 }, -- x
    earthgrab_totem               = { 69696, 51485 , 1 }, -- x
    elemental_assault             = { 69741, 210853, 2 }, -- x
    elemental_blast               = { 69744, 117014, 1 }, -- x
    elemental_orbit               = { 69703, 383010, 1 }, -- x
    elemental_spirits             = { 69736, 262624, 1 }, -- Passive
    elemental_warding             = { 69729, 381650, 2 }, -- Passive
    elemental_weapons             = { 69747, 384355, 2 }, -- Passive
    enfeeblement                  = { 69679, 378079, 1 }, -- Passive
    feral_lunge                   = { 69754, 196884, 1 }, -- x
    feral_spirit                  = { 69748, 51533 , 1 }, -- x
    fire_and_ice                  = { 69727, 382886, 1 }, -- Passive
    fire_nova                     = { 69765, 333974, 1 }, -- x
    flurry                        = { 69716, 382888, 1 }, -- Passive
    focused_insight               = { 69715, 381666, 2 }, -- x
    forceful_winds                = { 69759, 262647, 1 }, -- x
    frost_shock                   = { 69719, 196840, 1 }, -- x
    gathering_storms              = { 69738, 384363, 1 }, -- x
    go_with_the_flow              = { 69688, 381678, 2 }, -- x
    graceful_spirit               = { 69705, 192088, 1 }, -- x
    greater_purge                 = { 69713, 378773, 1 }, -- x
    guardians_cudgel              = { 69694, 381819, 1 }, -- Passive
    gust_of_wind                  = { 69690, 192063, 1 }, -- x
    hailstorm                     = { 69765, 334195, 1 }, -- x
    healing_stream_totem          = { 69700, 5394  , 1 }, -- Check totem registry.
    hex                           = { 69711, 51514 , 1 }, -- x
    hot_hand                      = { 69730, 201900, 2 }, -- x
    ice_strike                    = { 69766, 342240, 1 }, -- x
    improved_call_of_the_elements = { 69686, 383011, 1 }, -- x
    improved_lightning_bolt       = { 69698, 381674, 2 }, -- Passive
    improved_maelstrom_weapon     = { 69755, 383303, 2 }, -- Passive
    lashing_flames                = { 69677, 334046, 1 }, -- x
    lava_burst                    = { 69726, 51505 , 1 }, -- x
    lava_lash                     = { 69762, 60103 , 1 }, -- x
    legacy_of_the_frost_witch     = { 69735, 384450, 2 }, -- Need to track actual MW stacks that are spent; no tracking aura.
    lightning_lasso               = { 69684, 305483, 1 }, -- x
    maelstrom_weapon              = { 69717, 187880, 1 }, -- x
    mana_spring_totem             = { 69702, 381930, 1 }, -- x
    molten_assault                = { 69763, 334033, 2 }, -- x
    natures_fury                  = { 69714, 381655, 2 }, -- Passive
    natures_guardian              = { 69697, 30884 , 2 }, -- Passive
    natures_swiftness             = { 69699, 378081, 1 }, -- x
    overflowing_maelstrom         = { 69676, 384149, 1 }, -- x
    planes_traveler               = { 69723, 381647, 1 }, -- x
    poison_cleansing_totem        = { 69681, 383013, 1 }, -- x
    primal_lava_actuators         = { 69764, 390370, 1 }, -- x
    primal_maelstrom              = { 69740, 384405, 2 }, -- x
    primordial_wave               = { 69743, 375982, 1 }, -- x
    purge                         = { 69713, 370   , 1 }, -- x
    raging_maelstrom              = { 69756, 384143, 1 }, -- x
    refreshing_waters             = { 69731, 337974, 1 }, -- Passive
    spirit_walk                   = { 69690, 58875 , 1 }, -- x
    spirit_wolf                   = { 69721, 260878, 1 }, -- x
    spiritwalkers_aegis           = { 69705, 378077, 1 }, -- Passive
    spiritwalkers_grace           = { 69706, 79206 , 1 }, -- x
    splintered_elements           = { 69739, 382042, 1 }, -- x
    static_accumulation           = { 69734, 384411, 2 }, -- x
    static_charge                 = { 69694, 265046, 1 }, -- Passive
    stoneskin_totem               = { 69682, 383017, 1 }, -- x
    stormblast                    = { 69742, 319930, 1 }, -- Passive
    stormflurry                   = { 69752, 344357, 1 }, -- Passive
    storms_wrath                  = { 69746, 392352, 1 }, -- Passive
    stormstrike                   = { 69761, 17364 , 1 }, -- x
    sundering                     = { 69757, 197214, 1 }, -- x
    surging_shields               = { 69691, 382033, 2 }, -- Passive
    swirling_currents             = { 69701, 378094, 2 }, -- x
    swirling_maelstrom            = { 69732, 384359, 1 }, -- x
    thorims_invocation            = { 69733, 384444, 1 }, -- x
    thunderous_paws               = { 69721, 378075, 1 }, -- x
    thundershock                  = { 69684, 378779, 1 }, -- x
    thunderstorm                  = { 69683, 51490 , 1 }, -- x
    totemic_focus                 = { 69693, 382201, 2 }, -- Increase Earthbind/Earthgrab by 5; minor totems by 1.5.
    totemic_projection            = { 69692, 108287, 1 }, -- x
    totemic_surge                 = { 69704, 381867, 2 }, -- x
    tranquil_air_totem            = { 69682, 383019, 1 }, -- x
    tremor_totem                  = { 69695, 8143  , 1 }, -- x
    unruly_winds                  = { 69758, 390288, 1 }, -- x
    voodoo_mastery                = { 69679, 204268, 1 }, -- x
    wind_rush_totem               = { 69696, 192077, 1 }, -- x
    wind_shear                    = { 69725, 57994 , 1 }, -- x
    windfury_totem                = { 69753, 8512  , 1 }, -- x
    windfury_weapon               = { 69760, 33757 , 1 }, -- x
    winds_of_alakir               = { 69689, 382215, 2 }, -- Passive?
    witch_doctors_wolf_bones      = { 69737, 384447, 2 }, -- x
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    counterstrike_totem = 3489, -- 204331
    ethereal_form = 1944, -- 210918
    grounding_totem = 3622, -- 204336
    ride_the_lightning = 721, -- 289874
    seasoned_winds = 5414, -- 355630
    shamanism = 722, -- 193876
    skyfury_totem = 3487, -- 204330
    spectral_recovery = 3519, -- 204261
    static_field_totem = 5438, -- 355580
    swelling_waves = 3623, -- 204264
    thundercharge = 725, -- 204366
    tidebringer = 5518, -- 236501
    traveling_storms = 5527, -- 204403
    unleash_shield = 3492, -- 356736
} )


-- Auras
spec:RegisterAuras( {
    alpha_wolf = {
        id = 198434,
        duration = 8,
        max_stack = 1,
    },
    ancestral_guidance = {
        id = 108281,
    },
    ascendance = {
        id = 114051,
        duration = 15,
        max_stack = 1,
    },
    astral_shift = {
        id = 108271,
        duration = function () return talent.planes_traveler.enabled and 12 or 8 end,
        max_stack = 1,
    },
    brimming_with_life = {
        id = 381689,
    },
    crackling_surge = {
        id = 224127,
        duration = 3600,
        max_stack = 1,
    },
    crash_lightning = {
        id = 187878,
        duration = 10,
        max_stack = 1,
    },
    crash_lightning_cl = {
        id = 333964,
        duration = 15,
        max_stack = 3
    },
    crashing_lightning = {
        id = 242286,
        duration = 16,
        max_stack = 15,
    },
    crashing_storms = {
        id = 334308,
    },
    doom_winds = {
        id = 384352,
        duration = 8,
        max_stack = 1,
    },
    doom_winds_wft = {
        id = 335903,
        duration = 12,
        max_stack = 1,
        copy = "doom_winds_buff"
    },
    doom_winds_cd = {
        id = 335904,
        duration = 60,
        max_stack = 1,
        copy = "doom_winds_debuff",
        generate = function( t )
            -- TODO: Update to modern GPABSI.
            local name, _, count, debuffType, duration, expirationTime = FindPlayerAuraByID( 335904 )

            if name then
                t.count = count > 0 and count or 1
                t.expires = expirationTime > 0 and expirationTime or query_time + 5
                t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    earth_elemental = {
        id = 198103,
    },
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
    elemental_weapons = {
        id = 384355,
    },
    enfeeblement = {
        id = 378080,
        duration = 4,
        max_stack = 1,
    },
    ethereal_form = {
        id = 210918,
        duration = 14,
        max_stack = 1,
    },
    far_sight = {
        id = 6196,
    },
    feral_spirit = {
        id = 333957,
        duration = 15,
        max_stack = 1,
    },
    fire_of_the_twisting_nether = {
        id = 207995,
        duration = 8,
    },
    flame_shock = {
        id = 188389,
        duration = 18,
        tick_time = function () return 2 * haste end,
        type = "Magic",
        max_stack = 1,
    },
    flurry = {
        id = 382889,
        duration = 15,
        max_stack = 3
    },
    focused_insight = {
        id = 381668,
        duration = 12,
        max_stack = 1
    },
    forceful_winds = {
        id = 262652,
        duration = 15,
        max_stack = 5,
    },
    frost_shock = {
        id = 196840,
        duration = 6,
        type = "Magic",
        max_stack = 1,
    },
    gathering_storms = {
        id = 198300,
        duration = 12,
        max_stack = 10,
    },
    --[[ gathering_storms = {
        id = 198300,
        duration = 12,
        max_stack = 1,
    }, ]]
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    hailstorm = {
        id = 334196,
        duration = 20,
        max_stack = 10,
    },
    hot_hand = {
        id = 215785,
        duration = 8,
        max_stack = 1,
    },
    ice_strike = {
        id = 342240,
        duration = 6,
        max_stack = 1,
    },
    ice_strike_buff = {
        id = 384357,
        duration = 12,
        max_stack = 1,
    },
    icy_edge = {
        id = 224126,
        duration = 3600,
        max_stack = 1,
    },
    improved_maelstrom_weapon = {
        id = 383303,
    },
    lashing_flames = {
        id = 334168,
        duration = 20,
        max_stack = 1,
    },
    legacy_of_the_frost_witch = {
        id = 335901,
        duration = 10,
        max_stack = 1,
    },
    lightning_crash = {
        id = 242284,
        duration = 16
    },
    lightning_lasso = {
        id = 305485,
        duration = 5,
        max_stack = 1,
    },
    lightning_shield = {
        id = 192106,
        duration = 1800,
        type = "Magic",
        max_stack = 1,
    },
    lightning_shield_overcharge = {
        id = 273323,
        duration = 10,
        max_stack = 1,
    },
    maelstrom_weapon = {
        id = 344179,
        duration = 30,
        max_stack = function () return talent.raging_maelstrom.enabled and 10 or 5 end,
    },
    mastery_enhanced_elements = {
        id = 77223,
    },
    molten_weapon = {
        id = 271924,
        duration = 4,
    },
    natures_guardian = {
        id = 30884,
    },
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        max_stack = 1,
    },
    overflowing_maelstrom = {
        id = 384149,
    },
    primal_lava_actuators_sl = {
        id = 335896,
        duration = 15,
        max_stack = 20,
    },
    primal_lava_actuators_df = {
        id = 390371,
        duration = 15,
        max_stack = 8 -- ???
    },
    primal_lava_actuators = {
        alias = { "primal_lava_actuators_df", "primal_lava_actuators_sl" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 15,
    },
    raging_maelstrom = {
        id = 384143,
    },
    reincarnation = {
        id = 20608,
    },
    resonance_totem = {
        id = 262417,
        duration = 120,
        max_stack =1 ,
    },
    shock_of_the_twisting_nether = {
        id = 207999,
        duration = 8,
    },
    sign_of_the_twisting_nether = {
        id = 335148,
        duration = 3600,
        max_stack = 1,
    },
    skyfury_totem = {
        id = 208963,
        duration = 3600,
        max_stack = 1,
    },
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1,
    },
    spirit_wolf = {
        id = 260881,
        duration = 3600,
        max_stack = 4,
    },
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        max_stack = 1,
    },
    splintered_elements = {
        id = 382043,
        duration = 12,
        max_stack = 20,
    },
    static_charge = {
        id = 118905,
        duration = 3,
        type = "Magic",
        max_stack = 1,
    },
    stoneskin = {
        id = 383018,
        duration = 15,
        max_stack = 1,
        shared = "player",
    },
    storm_totem = {
        id = 262397,
        duration = 120,
        max_stack =1 ,
    },
    stormbringer = {
        id = 201845,
        duration = 12,
        max_stack = 1,
    },
    stormkeeper = {
        id = 320137,
        duration = 15,
        max_stack = 2,
    },
    sundering = {
        id = 197214,
        duration = 2,
        max_stack = 1,
    },
    swirling_currents_df = {
        id = 378102,
        duration = 15,
        max_stack = 3,
    },
    swirling_currents = {
        alias = { "swirling_currents_df", "swirling_currents_sl" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 15
    },
    swirling_maelstrom = {
        id = 384359,
    },
    tailwind_totem = {
        id = 262400,
        duration = 120,
        max_stack =1 ,
    },
    thunderous_paws_df = {
        id = 378076,
        duration = 3,
        max_stack = 1,
    },
    thunderous_paws = {
        alias = { "thunderous_paws_df", "thunderous_paws_sl" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3
    },
    tranquil_air = {
        id = 383020,
        duration = 20,
        max_stack = 1,
        shared = "player"
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
    windfury_totem = {
        id = 327942,
        duration = 120,
        max_stack = 1,
        shared = "player",
    },
    winds_of_alakir = {
        id = 382215,
    },
    witch_doctors_wolf_bones = {
        id = 384447,
    },

    -- Azerite Powers
    ancestral_resonance = {
        id = 277943,
        duration = 15,
        max_stack = 1,
    },
    lightning_conduit = {
        id = 275391,
        duration = 60,
        max_stack = 1
    },
    primal_primer = {
        id = 273006,
        duration = 30,
        max_stack = 10,
    },
    roiling_storm = {
        id = 278719,
        duration = 3600,
        max_stack = 1,
    },
    strength_of_earth = {
        id = 273465,
        duration = 10,
        max_stack = 1,
    },
    thunderaans_fury = {
        id = 287802,
        duration = 6,
        max_stack = 1,
    },

    -- Legendaries, Anima Powers, etc.
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
    legacy_oF_the_frost_witch = {
        id = 335901,
        duration = 10,
        max_stack = 1,
    },

    -- PvP Talents
    thundercharge = {
        id = 204366,
        duration = 10,
        max_stack = 1,
    },

    flametongue_weapon = {
        duration = 3600,
        max_stack = 1,
    },
    windfury_weapon = {
        duration = 3600,
        max_stack = 1,
    },

    -- Conduit
    swirling_currents_sl = {
        id = 338340,
        duration = 15,
        max_stack = 1
    },
    thunderous_paws_sl = {
        id = 338036,
        duration = 3,
        max_stack = 1
    },
} )


spec:RegisterStateTable( "feral_spirit", setmetatable( {}, {
    __index = function( t, k )
        return buff.feral_spirit[ k ]
    end
} ) )

spec:RegisterStateTable( "twisting_nether", setmetatable( { onReset = function( self ) end }, {
    __index = function( t, k )
        if k == "count" then
            return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
        end

        return 0
    end
} ) )


local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local vesper_heal = 0
local vesper_damage = 0
local vesper_used = 0

local vesper_expires = 0
local vesper_guid
local vesper_last_proc = 0

local last_totem_actual = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    -- Deaths/despawns.
    if death_events[ subtype ] and destGUID == vesper_guid then
        vesper_guid = nil
        return
    end

    if sourceGUID == state.GUID then
        -- Summons.
        if subtype == "SPELL_SUMMON" and spellID == 324386 then
            vesper_guid = destGUID
            vesper_expires = GetTime() + 30

            vesper_heal = 3
            vesper_damage = 3
            vesper_used = 0

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


local TriggerFeralMaelstrom = setfenv( function()
    gain_maelstrom( 1 )
end, state )

local TriggerStaticAccumulation = setfenv( function()
    gain_maelstrom( 1 )
end, state )

spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5401 then applyBuff( "windfury_weapon" ) end
    if oh and oh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end

    if buff.windfury_totem.down and ( now - action.windfury_totem.lastCast < 1 ) then applyBuff( "windfury_totem" ) end

    if buff.windfury_totem.up and pet.windfury_totem.up then
        buff.windfury_totem.expires = pet.windfury_totem.expires
    end

    if buff.windfury_weapon.down and ( now - action.windfury_weapon.lastCast < 1 ) then applyBuff( "windfury_weapon" ) end
    if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end

    if settings.pad_windstrike and cooldown.windstrike.remains > 0 then
        reduceCooldown( "windstrike", latency * 2 )
    end

    if settings.pad_lava_lash and cooldown.lava_lash.remains > 0 and buff.hot_hand.up then
        reduceCooldown( "lava_lash", latency * 2 )
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

    if buff.feral_spirit.up then
        local next_mw = query_time + 3 - ( ( query_time - buff.feral_spirit.applied ) % 3 )

        while ( next_mw <= buff.feral_spirit.expires ) do
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, next_mw, "AURA_PERIODIC" )
            next_mw = next_mw + 3
        end

        if talent.alpha_wolf.enabled then
            local last_trigger = max( action.chain_lighting.lastCast, action.crash_lightning.lastCast )

            if last_trigger > buff.feral_spirit.applied then
                applyBuff( "alpha_wolf", last_trigger + 8 - now )
            end
        end
    end

    if buff.ascendance.up and talent.static_accumulation.enabled then
        local next_mw = query_time + 1 - ( ( query_time - buff.ascendance.applied ) % 1 )

        while ( next_mw <= buff.ascendance.expires ) do
            state:QueueAuraEvent( "ascendance_maelstrom", TriggerStaticAccumulation, next_mw, "AURA_PERIODIC" )
            next_mw = next_mw + 1
        end
    end
end )


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
                removeBuff( "spirit_wolf" )
            end
        else
            removeBuff( "ghost_wolf" )
            removeBuff( "spirit_wolf" )
        end
    end
end )


spec:RegisterGear( "waycrest_legacy", 158362, 159631 )
spec:RegisterGear( "electric_mail", 161031, 161034, 161032, 161033, 161035 )

-- Tier 28
spec:RegisterSetBonuses( "tier28_2pc", 364473, "tier28_4pc", 363668 )
-- 2-Set - Stormspirit - Spending Maelstrom Weapon has a 3% chance per stack to summon a Feral Spirit for 9 sec.
-- 4-Set - Stormspirit - Your Feral Spirits' attacks have a 20% chance to trigger Stormbringer, resetting the cooldown of your Stormstrike.
-- 2/15/22:  No mechanics require actual modeling; nothing can be predicted.

spec:RegisterStateFunction( "consume_maelstrom", function( cap )
    local stacks = min( buff.maelstrom_weapon.stack, cap or ( talent.overflowing_maelstrom.enabled and 10 or 5 ) )

    if talent.hailstorm.enabled and stacks > buff.hailstorm.stack then
        applyBuff( "hailstorm", nil, stacks )
    end

    removeStack( "maelstrom_weapon", stacks )

    -- TODO: Have to actually track consumed MW stacks.
    if legendary.legacy_oF_the_frost_witch.enabled and stacks > 4 or talent.legacy_of_the_frost_witch.enabled and stacks > 9 then
        setCooldown( "stormstrike", 0 )
        setCooldown( "windstrike", 0 )
        applyBuff( "legacy_of_the_frost_witch" )
    end
end )

spec:RegisterStateFunction( "gain_maelstrom", function( stacks )
    if talent.witch_doctors_wolf_bones.enabled then
        reduceCooldown( "feral_spirits", stacks )
    end

    addStack( "maelstrom_weapon", nil, stacks )
end )

spec:RegisterStateFunction( "maelstrom_mod", function( amount )
    local mod = max( 0, 1 - ( 0.2 * buff.maelstrom_weapon.stack ) )
    return mod * amount
end )

spec:RegisterTotem( "counterstrike_totem", 511726 )
spec:RegisterTotem( "mana_spring_totem", 136053 )
spec:RegisterTotem( "poison_cleansing_totem", 136070 )
spec:RegisterTotem( "skyfury_totem", 135829 )
spec:RegisterTotem( "stoneskin_totem", 4667425 )
spec:RegisterTotem( "windfury_totem", 136114 )

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
        id = 114051,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "ascendance",
        startsCombat = true,
        texture = 135791,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ascendance" )
            if talent.static_accumulation.enabled then
                for i = 1, 15 do
                    state:QueueAuraEvent( "ascendance_maelstrom", TriggerStaticAccumulation, query_time + i, "AURA_PERIODIC" )
                end
            end
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
        cooldown = function () return 120 - 30 * talent.planes_traveler.rank end,
        gcd = "off",

        talent = "astral_shift",
        startsCombat = false,
        texture = 538565,

        toggle = "defensives",
        nopvptalent = "ethereal_form",

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
        cooldown = function () return 180 - 60 * talent.improved_call_of_the_elements.rank end,
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
            consume_maelstrom()

            removeBuff( "chains_of_devastation_ch" )
            removeBuff( "natures_swiftness" ) -- TODO: Determine order of instant cast effect consumption.
            removeBuff( "focused_insight" )

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
            consume_maelstrom()

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

            if buff.feral_spirit.up and talent.alpha_wolf.enabled then
                applyBuff( "alpha_wolf" )
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
            summonPet( "counterstrike_totem" )
        end,
    },


    crash_lightning = {
        id = 187874,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "crash_lightning",
        startsCombat = true,
        texture = 1370984,

        handler = function ()
            if active_enemies > 1 then
                applyBuff( "crash_lightning" )
                applyBuff( "gathering_storms", nil, min( 10, active_enemies ) )
            end

            removeBuff( "crashing_lightning" )
            removeBuff( "crash_lightning_cl" )

            if buff.feral_spirit.up and talent.alpha_wolf.enabled then
                applyBuff( "alpha_wolf" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    doom_winds = {
        id = 384352,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "doom_winds",
        startsCombat = true,
        texture = 1035054,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "doom_winds" )
            -- TODO: See how/if the legacy legendary works in 10.0.
        end,
    },


    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        talent = "earth_elemental",
        startsCombat = false,
        texture = 136024,

        toggle = "defensives",

        handler = function ()
            summonPet( "greater_earth_elemental", 60 )
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
            applyBuff( "earth_shield" )
            if talent.elemental_orbit.rank == 0 then removeBuff( "lightning_shield" ) end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },


    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = function () return 30 - 2 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
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
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        talent = "earthgrab_totem",
        startsCombat = true,
        texture = 136100,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthgrab_totem" )
        end,
    },


    elemental_blast = {
        id = 117014,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 12,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.03 end,
        spendType = "mana",

        talent = "elemental_blast",
        startsCombat = true,
        texture = 651244,

        handler = function ()
            consume_maelstrom()

            removeBuff( "natures_swiftness" )
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


    feral_lunge = {
        id = 196884,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "feral_lunge",
        startsCombat = true,
        texture = 1027879,

        min_range = 8,
        max_range = 25,

        handler = function ()
            setDistance( 5 )
        end,
    },


    feral_spirit = {
        id = 51533,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 120 - ( talent.elemental_spirits.enabled and 30 or 0 ) ) end,
        gcd = "spell",

        talent = "feral_spirit",
        startsCombat = false,
        texture = 237577,

        toggle = "cooldowns",

        handler = function ()
            -- instant MW stack?
            applyBuff( "feral_spirit" )

            gain_maelstrom( 1 )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 3, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 6, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 9, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 12, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 15, "AURA_PERIODIC" )
        end
    },


    fire_nova = {
        id = 333974,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "fire_nova",
        startsCombat = true,
        texture = 459027,

        handler = function ()
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            if talent.focused_insight.enabled then applyBuff( "focused_insight" ) end
            if talent.swirling_maelstrom.enabled then gain_maelstrom( 2 ) end
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

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            if talent.primal_lava_actuators.enabled then addStack( "primal_lava_actuators_df", nil, 1 ) end
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
        essential = true,

        usable = function () return swings.oh_speed > 0, "requires an offhand weapon" end,

        handler = function ()
            applyBuff( "flametongue_weapon" )
        end,
    },


    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = true,
        texture = 135849,

        handler = function ()
            if buff.hailstorm.up then
                if talent.swirling_maelstrom.enabled and buff.hailstorm.stack > 1 then gain_maelstrom( 2 ) end
                removeBuff( "hailstorm" )
            end
            removeBuff( "ice_strike_buff" )

            setCooldown( "flame_shock", 6 * haste )

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
            if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws_sl" ) end
            if talent.thunderous_paws.enabled and query_time - buff.thunderous_paws_df.lastApplied > 60 then
                applyBuff( "thunderous_paws_df" )
            end
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


    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = function () return 30 - 5 * talent.go_with_the_flow.rank end,
        gcd = "spell",

        talent = "gust_of_wind",
        startsCombat = true,
        texture = 1029585,

        toggle = "interrupts",

        handler = function ()
        end,
    },


    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = 1,
        cooldown = function () return 30 - 2 * talent.totemic_surge.rank end,
        recharge = function () return 30 - 2 * talent.totemic_surge.rank end,
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
            if talent.swirling_currents.enabled then applyBuff( "swirling_currents", nil, 3 ) end
        end,
    },


    healing_surge = {
        id = 8004,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 1.5 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or maelstrom_mod( 0.24 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136044,

        handler = function ()
            consume_maelstrom()

            removeBuff( "natures_swiftness" )
            removeBuff( "focused_insight" )

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if buff.swirling_currents.up then removeStack( "swirling_currents" ) end
        end
    },


    heroism = {
        id = function () return pvptalent.shamanism.enabled and 204362 or 32182 end,
        cast = 0,
        cooldown = 300,
        gcd = "spell", -- Ugh.

        spend = 0.215,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "heroism" )
            applyDebuff( "player", "exhaustion", 600 )
        end,

        copy = { 204362, 32182 }
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


    ice_strike = {
        id = 342240,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "ice_strike",
        startsCombat = true,
        texture = 135845,

        handler = function ()
            setCooldown( "frost_shock", 0 )
            setCooldown( "flame_shock", 0 )

            applyDebuff( "target", "ice_strike" )
            applyBuff( "ice_strike_buff" )

            if talent.swirling_maelstrom.enabled then gain_maelstrom( 2 ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    lava_burst = {
        id = 51505,
        cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
        charges = 1,
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


    lava_lash = {
        id = 60103,
        cast = 0,
        cooldown = function () return 18 * ( buff.hot_hand.up and ( 1 - 0.375 * talent.hot_hand.rank ) or 1 ) * haste end,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "lava_lash",
        startsCombat = true,
        texture = 236289,

        cycle = function()
            return talent.lashing_flames.enabled and "lashing_flames" or nil
        end,

        indicator = function()
            return debuff.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeDebuff( "target", "primal_primer" )

            if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

            removeBuff( "primal_lava_actuators" )

            if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
            if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

            -- This is dumb, but technically you don't know if FS will go to a new target or refresh an old one.  Even your current target.
            if talent.molten_assault.enabled and debuff.flame_shock.up then
                active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 2 )
            end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    lightning_bolt = {
        id = 188196,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
            consume_maelstrom()

            removeBuff( "natures_swiftness" )

            if buff.primordial_wave.up and state.spec.enhancement and legendary.splintered_elements.enabled then
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    lightning_lasso = {
        id = 305483,
        cast = 5,
        channeled = true,
        cooldown = 45,
        gcd = "spell",

        talent = "lightning_lasso",
        startsCombat = true,
        texture = 1385911,

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

        startsCombat = true,
        texture = 136051,

        nobuff = "earth_shield",

        timeToReady = function () return buff.lightning_shield.remains - 120 end,

        handler = function ()
            applyBuff( "lightning_shield" )
            if talent.elemental_orbit.rank == 0 then removeBuff( "earth_shield" ) end
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
        startsCombat = true,
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
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        talent = "poison_cleansing_totem",
        startsCombat = false,
        texture = 136070,

        handler = function ()
            summonTotem( "poison_cleaning_totem" )
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
            if talent.primal_maelstrom.enabled then gain_maelstrom( 5 ) end
            if talent.splintered_elements.enabled then applyBuff( "splintered_elements", nil, active_dot.flame_shock ) end
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

        startsCombat = false,
        texture = 135829,

        pvptalent = "skyfury_totem",

        handler = function ()
            summonPet( "skyfury_totem" )
            applyBuff( "skyfury_totem" )
        end,
    },


    spirit_walk = {
        id = 58875,
        cast = 0,
        cooldown = function () return 60 - 7.5 * talent.go_with_the_flow.rank end,
        gcd = "spell",

        talent = "spirit_walk",
        startsCombat = true,
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
        startsCombat = true,
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
        startsCombat = true,
        texture = 4667425,

        handler = function ()
            summonTotem( "stoneskin_totem" )
            applyBuff( "stoneskin" )
        end,
    },


    stormstrike = {
        id = 17364,
        cast = 0,
        cooldown = function() return gcd.execute * 6 end,
        gcd = "spell",

        rangeSpell = 73899,

        spend = 0.02,
        spendType = "mana",

        talent = "stormstrike",
        startsCombat = true,
        texture = 132314,

        bind = "windstrike",
        cycle = function () return azerite.lightning_conduit.enabled and "lightning_conduit" or nil end,
        nobuff = "ascendance",

        handler = function ()
            setCooldown( "windstrike", action.stormstrike.cooldown )

            if buff.stormbringer.up then
                removeBuff( "stormbringer" )
            end

            removeBuff( "gathering_storms" )

            if azerite.lightning_conduit.enabled then
                applyDebuff( "target", "lightning_conduit" )
            end

            removeBuff( "strength_of_earth" )
            removeBuff( "legacy_of_the_frost_witch" )

            if talent.elemetnal_assault.rank > 1 then
                gain_maelstrom( 1 )
            end

            if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
            if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
            if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },


    sundering = {
        id = 197214,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "sundering",
        startsCombat = true,
        texture = 524794,

        handler = function ()
            applyDebuff( "target", "sundering" )

            if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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
        startsCombat = true,
        texture = 538575,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tranquil_air_totem" )
            applyBuff( "tranquil_air" )
        end,
    },


    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = function () return 60 - 2 * talent.totemic_surge.rank end,
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
            applyBuff( "wind_rush" )
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


    windfury_totem = {
        id = 8512,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        icd = 3,

        essential = true,

        spend = 0.12,
        spendType = "mana",

        startsCombat = false,
        texture = 136114,

        nobuff = "doom_winds", -- Don't cast Windfury Totem while Doom Winds is already up, there's some weirdness with Windfury Totem's buff right now.

        handler = function ()
            applyBuff( "windfury_totem" )
            summonTotem( "windfury_totem", nil, 120 )

            if legendary.doom_winds.enabled and debuff.doom_winds_cd.down then
                applyBuff( "doom_winds_wft" )
                applyDebuff( "player", "doom_winds_cd" )
                applyDebuff( "player", "doom_winds_debuff" )
                applyBuff( "doom_winds_cd" ) -- SimC weirdness.
                applyBuff( "doom_winds_debuff" ) -- SimC weirdness.
            end
        end,
    },


    windfury_weapon = {
        id = 33757,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "windfury_weapon",
        startsCombat = false,
        texture = 462329,
        essential = true,

        handler = function ()
            applyBuff( "windfury_weapon" )
        end,
    },


    windstrike = {
        id = 115356,
        cast = 0,
        cooldown = function() return gcd.execute * 2 end,
        gcd = "spell",

        texture = 1029585,
        known = 17364,

        buff = "ascendance",

        bind = "stormstrike",

        handler = function ()
            setCooldown( "stormstrike", action.stormstrike.cooldown )

            if buff.stormbringer.up then
                removeBuff( "stormbringer" )
            end

            removeBuff( "gathering_storms" )
            removeBuff( "strength_of_earth" )
            removeBuff( "legacy_of_the_frost_witch" )

            if talent.thorims_invocation.enabled and buff.maelstrom_weapon.stack > 4 then
                consume_maelstrom( 5 )
                -- Casts Lightning Bolt or Chain Lightning.
            end

            if talent.elemental_assault.enabled then
                gain_maelstrom( 1 )
            end

            if azerite.natural_harmony.enabled then
                if buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
            end


            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_agility",

    package = "Enhancement",
} )


spec:RegisterSetting( "pad_windstrike", true, {
    name = "Pad |T1029585:0|t Windstrike Cooldown",
    desc = "If checked, the addon will treat |T1029585:0|t Windstrike's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Ascendance.",
    type = "toggle",
    width = 1.5
} )

spec:RegisterSetting( "pad_lava_lash", true, {
    name = "Pad |T236289:0|t Lava Lash Cooldown",
    desc = "If checked, the addon will treat |T236289:0|t Lava Lash's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Hot Hand.",
    type = "toggle",
    width = 1.5
} )

spec:RegisterSetting( "filler_shock", true, {
    name = "Filler |T135813:0|t Shock",
    desc = "If checked, the addon's default priority will recommend a filler |T135813:0|t Flame Shock when there's nothing else to push, even if something better will be off cooldown very soon.  " ..
        "This matches sim behavior and is a small DPS increase, but has been confusing to some users.",
    type = "toggle",
    width = 1.5
})


spec:RegisterPack( "Enhancement", 20220912, [[Hekili:TZvBVnUXr4FlgbqXc1r1Ks25UcldKgCO4oKEbOoaTFsu0uRKimfPk5k7Zag63ENzj5YDxUZsrj5eG2ceCWHC5SZ7ZZmCPM5n73M9WIqoB2x9V23)6p65pY3F8hM4p7b(RBzZEyBy0tHRG)inCd8VFkDDyAeBdlLJ371KSWfinkY2Lhb3)H4n)8ShECxCc)ZPZE0oXHLVLfbx92XZEyD8IfSYLYkI02H9ZFyD4MW09F5N2TAxb8)7p(k4FaIn7HK4cEHyRJtxLWG)6RcPjmIhNLo7HxItxuWZJFc4kwA4JjSfZ(RZ4WUIRQ5kpeLhZz5XHiBVC5O1z8aGdwmA329ZF7T9ZVC)88DPSLz5RyJ2MhVjmjij85WayN2fYZYlgX(37I3ULTy)8b7NlOI91vWbT5(53VF(T7NpSHxflljSynYFJj5VlQiokAl3L)AapJZ2amQUu3ClKCtijxJuTilBtGqHzruuUP6ovas0MkfmSn38oTnr5GAjijE1AEkyOXT623PTkoIf0iq)470UuSlDbqNsr5dU9frVOS8fXGN0lHpJ73lPIna9jdJxeWEgctgfUa2J4uHJ1e)sVwB3(ot)od6JC0hD59XJJEc5CjbwMazfckwNf9e(WEx7wE2eYsanmQxyHBZsLbet3p)g9GhvXgJehqkXwFKC2MW40IALvDKtX2K4uGJyaHse5ykKX5lrFSa5dEhWtE(6HP1EHbpMLWfcShTxcH956g69mdYdM3eQ61vQPW4eryNMd1Y8ScUInGo)XIm(iflgOKwMZkwJRKixKhD2JlutlwWylkcYwgKhUzBykpyvE2l81krfOgokllbDHhTKLdgQITXa1AmvG2zSI2zzilGNhMwSCxbEbKDOZYWdtqvTq9SmzxE(RJQwxJFL4MpIXESCx5Y8OZW0qNNySTgKjcmqP65Q8OtJ0DerdLRCwbL2JGPP01Jo3rJDjpCf6Uw5O9CwoN9n9uvv6nwyoFn4weZswOP4GGhv30G1mGjabfOEPjZtwL096U2vm8Lvwivs04y8dGJbeiw(FnkfClqPd0FSWnkHr05W(FenJkplG8CY5LTYDWD)41MU)GGb8QWf1No7OZTfZ8EnD5amfIRKY((Q4avJTnacsNPSBTIXguMnqqv6uMai5KhbabJEoljKhNa5HZse606LRuyfsmdyFwcWSfvSY3Tf(tpXoqNf0g8WMkAOA1fur)BvvCnfcmuBNskTtWQ6iFhHZPATwnyx(FuvqvlGQlQJVwDDMqrnwRw3hkyjnwgDnE8zFMfyuLwHpJZzbPzphkOdTZR0nBl0Z0oWlJHopajC6MH0CIQiuMerw5XuoODclyCoOFkgTmojbYzzkg6ygh3rXwhEZJD5ndrlHznTfEK(RUYUDavzoMgeS0XdTT(02kTGIdPrXtVQzhLc7U6(H0O5VJSPzPwAVz7H3L(z3kHk4AvteSMRve9AegVNY2eJS6qIKhMzWRxKz)G6W9j6ndwLyx5O(HxGXBCxD2Q4YcfntEnipd0YknK1291iKO1epAGUFiq)olBRzldMiSSufLUrSQ(QRHvszHVRLb2H7GSzFBwhh9TEiT5BM6Z26mizz8wthSQbBNn5LqyPtF2rax19KBpgJ2ra6WohJr3fDodtTW2iG0w0QOfDnBd6cc9yAeoGjudtzvEgOqJtFoEvwEOkqLs5qUWLyswCkdpMKvuKTPqFDh(4iuyxldzOdajMzfKdL7On63Pd0OD9)UMIWPVPAibCmAHZ12zK9udpEdVy04bDxSodkjkc6O70QSvclrjgeTuwOZgPRGtdPpvMtRLjQyJKkUqizfnG4TLRZrpTU0rJP0rADeOnVsdBth9K2JrM53Z4pvYPn8YtQrvfeETN9MJEr7dLnNCan4LUhxItv64oM)tpa6mMoQXLdMpHd2yTz10rh2Jvxl573tVlw6X)4Qd2ZZGAA1ABh4K0MhVTO7X)OQOzw7Yq8(G2APNXXr61zT9ynVUjAtpX94eM0rt6NWuawWwgUdG0y(cIbqezls2br0Y99rryOl0IvPKdlIyPlW3tTgqw6PKkUT89FO846tNtGFSQtWAiZ1VpA1nQ0Yaa1yP1MfSi8qLAtXrVgWwSIP(ESpKxsc4lh9uzN37YRE8HAqFLWHBMX9JaEmbjmHJwAEW3SFE82s9(Nt)HOSnpgY3pFBgEP9ZJHL(iIDJHkPY7XWHv0yTkxQWH1W(yqCziOQpb45d(FchnIqs(AwaKzcdsIxfN8)n7hIz3U1U8KIyQq5ThDJm3ryeSyaUEyeaqhBZbN5dWhSIwjcKlP4fackzBqqfNBQ5exKN3EInYkhrH5IMiwcnLWYtX3yjuhzP1XIqU4Gjo4XXEoFz9E3sBaQfoAUK76mma89ZHWFb3zeS80NyCVG4cWRkoxP6w9TqIrJ5XcX8PjMpsmna)7kG2)G81fgffCCCcUWzmPmAq5M1wbNrJGM9MRnkreGfueSJ7HM0x2rzBy5fS8NQ7(IUa0XSn9xQraAcjxWnopos)oWn4nbpACcSHjI0iUpucDWsx0HPiCfgmbUQrpjYouoadPQr5Gly6Ss32I7ci6JUW6y8hwprOZ(mtmtTmvKBFinitUZPr4QsiDMmPPwQDeBJzchcqEQBFFFBiblyvxPJdwfoJEhYGEnydWQQe)IoT1sQ0Mlf1KXr1LYcIGeRGVj3YXDqhq0Y9ZZstEf)xgIQIT51RaKx5XzGAdU8YSKKSxa5akyVF(3xEAk)(sXeXMHNZYrQ1Qtsck)FcWBHDybbliFyPxqn)QYZSzqvDlX(iWBBMLxJ))vGf2aW3J3MuX(a9UQIBjLIWSZViCVPiGVErE9CKKepBhcbTSJt7Jkr)4j80RQ(Y6RuRH3QJuQTEzXZIBoRe58SUFJNs)ZkmK6a4S1ov5cD3DKG0IoB5zPR2X6K6TxReEVmDCgNdBeo6RxzlEbHNYZ(wCQz3JUzQMzBx9M(izjZvAd1AdXvXvxnBR611yF1NXdDrIUZmmGo9czYrNGa78GcyulPxtdXcIXSTIdhqZYRrnI)vYoMeI4iU3O4IrgTquYn6lHe(RTf7SpdGxQIRBJhM3(fl2dzXVBzXVpYIF)LfFvzrKV4zihfY31hnFi12lH5ORp88)ZF6F81p)1)2Fz)89Z)nmHA8MTz5CmnBUm7AoRCJrhKnWAc3XZ2amoCHiOZ1vSIr7)YVeJvD8Ubi1pNLcBQ4(FV0L6FbeINPDLAVk4ox6)THsIm(ijcomHp9R)cqnpb12)LoepzjWEiH(topmxLOo(8qTof1QzJ1pz172JJ7QSMDYuYsz9JT(XJKRuv8hjnSBf)GbXQdG9AOMs(j8Axow5X)iXJ7B5X9vF89F5Zc9j(ut0rbHAleRq2Yymt139DaFB77TbVrRV5gKYLeRyK0gn1aJWvXlN6cKXDq9wlK5pn9p3goGKw0OkOjhf0b7R2SWVCRPWoqVXkv8rQqdsW(JRxahPWfoXfmGSLdcTCDfAK0KiaE7nYQ(2PBD5VRW6otBvc9krrXPnHaTlj(2BA3LSAOX6CuiShCQpfNAR4Ddh4UUTX6CYPLXCF6BSODIaxOb08xXJIdM1t0udily6rCw5HphgNGYWiPiov(6makTFEFgYUKgGYPCXORXLKJSyq7oKVF6hVEGJP6CN31dF7TljMT9aRZ1gEaZjA3qclZYEaXCSb6O3k39EaLZkkgOnqwiGUsZv9geuvlnVdb1Rwp3YkpjDNK)7xh2w9rPAC45lt02AW(MBG)n0BaziOi)5bmH(wsdiFTnr35DBBfHkxvN3tST0dy3YJ4B9r8T(iY5LREXMzvlOePNxLhH28pF7nh(D3FJMLTzy19FFuPJCkZ9Nm9HD1hF877EPn84U2Ql6q9OmPzTRRppw3zzaFyxqhgo4shduwbcqRHiBgfm1BOMsxYji)zpvN7ajduqvJ8CQ3ncc2nEi7J4DWL24LBTWl1joTGRAWLUbKv9K2gF7WYkmNLrYQQTmNOzvsrXZDv5WnNkYjzA1e8ZzBeRDZsWd5GF0DbSmjv1BRn4unimQZjTgy1FhLp81WGhNMg2Ur6qESbViWNt1(GpKLPSFCyUF6nApmY(6NLPE73QMpOIKYdg55Gy2((k0PRZVIIbo(ckgq(1tC)1MSH6Z)hW2lpmAkEJghGnibbGzI6EtgqDhTJU(qZn24m0EL2X9Qm4OScHLdBRbPewyH3UHFH7VZbjwpJJ(xlVUMtq37c9LNztB6aIVuIbe2J70u6eMM7UTL1q5UL1TR(GmCSmBgmoXx5afJCyCBlfM2r1xGaGYhup)QSmxBV4HdiC2g4oRhumSeDT1prbtu1t98BdRwEZvrlAByAo3IYuWQF4bTwFB4rhneNd)7j4aY9BnyqaN4iu831QAJwPHZdf1d7pp0SMlpQ0Wtoa1m31j3VczM1pGJ(KuI76C5FuI2yZNsTewlXw)O2kTo6NXEAjIYBS9ZyC037piiJzH2VhMsoTtGPETkUBZfUBH(Gmy(D4lsxJ2bt2UCtZSARNkvPh4bmC2dQILYjoVJmPosmFA2nlgEJJkUnDP(eYT1QM6CPk7b4br)qhEtaL9pn1MPR8wwJQu(9ddGnEO)YH1ufO9AkvtQGwKBVLxwGnDHQtU8zPX11Z(jKu8S2YJKQn)ukCMi4zQnkj9mHYtvTKCcetSGkko9oRw8orQ24A2cMyhq5OkXBHJTU0QiUEdj0MyQw)tyMSO1U2M65GXlApe2Xprw22T2OnV4WrnQmArB)GyD)yBcOruBxJYxCJMFYRSf02t0eYh8eahiPX75qiUKEmaEqMzhdjWMh)LczZ2Vct)W4HdT5c)EmzJ)OLPEotmI3Y1PMScG6zpzLosEBXmu3T)yuvYiFcO0Cuj3fOgpR6W6ezNQ(LSyaL(vRGQftExPQ7glHtCb2iE3G47Wu64WrqgSBbYkvHBR)ijDY(fIVfYD81z5v)u8IN1Vz)Np]] )