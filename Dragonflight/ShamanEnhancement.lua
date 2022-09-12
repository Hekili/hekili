-- ShamanEnhancement.lua
-- September 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo

local spec = Hekili:NewSpecialization( 263 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    alpha_wolf                    = { 69736, 198434 }, -- x
    ancestral_defense             = { 69728, 382947 }, -- Passive
    ancestral_guidance            = { 69685, 108281 }, -- x
    ancestral_wolf_affinity       = { 69731, 382197 }, -- x
    ascendance                    = { 69751, 114051 }, -- x
    astral_bulwark                = { 69723, 377933 }, -- Passive
    astral_shift                  = { 69724, 108271 }, -- x
    brimming_with_life            = { 69680, 381689 }, -- Passive
    call_of_the_elements          = { 69687, 108285 }, -- Track most recent totem cast with CD < 3 minutes.
    capacitor_totem               = { 69722, 192058 }, -- x
    chain_heal                    = { 69707, 1064   }, -- x
    chain_lightning               = { 69718, 188443 }, -- x
    cleanse_spirit                = { 69712, 51886  }, -- x
    crash_lightning               = { 69749, 187874 }, -- x
    crashing_storms               = { 69750, 334308 }, -- x
    creation_core                 = { 69686, 383012 }, -- Make Call of the Elements affect the last 2 totems.
    deeply_rooted_elements        = { 69751, 378270 }, -- Passive
    doom_winds                    = { 69745, 384352 }, -- x
    earth_elemental               = { 69708, 198103 }, -- x
    earth_shield                  = { 69709, 974    }, -- x
    earthgrab_totem               = { 69696, 51485  }, -- x
    elemental_assault             = { 69741, 210853 }, -- x
    elemental_blast               = { 69744, 117014 }, -- x
    elemental_orbit               = { 69703, 383010 }, -- x
    elemental_spirits             = { 69736, 262624 }, -- Passive
    elemental_warding             = { 69729, 381650 }, -- Passive
    elemental_weapons             = { 69747, 384355 }, -- Passive
    enfeeblement                  = { 69679, 378079 }, -- Passive
    feral_lunge                   = { 69754, 196884 }, -- x
    feral_spirit                  = { 69748, 51533  }, -- x
    fire_and_ice                  = { 69727, 382886 }, -- Passive
    fire_nova                     = { 69765, 333974 }, -- x
    flurry                        = { 69716, 382888 }, -- Passive
    focused_insight               = { 69715, 381666 }, -- x
    forceful_winds                = { 69759, 262647 }, -- x
    frost_shock                   = { 69719, 196840 }, -- x
    gathering_storms              = { 69738, 384363 }, -- x
    go_with_the_flow              = { 69688, 381678 }, -- x
    graceful_spirit               = { 69705, 192088 }, -- x
    greater_purge                 = { 69713, 378773 }, -- x
    guardians_cudgel              = { 69694, 381819 }, -- Passive
    gust_of_wind                  = { 69690, 192063 }, -- x
    hailstorm                     = { 69765, 334195 }, -- x
    healing_stream_totem          = { 69700, 5394   }, -- Check totem registry.
    hex                           = { 69711, 51514  }, -- x
    hot_hand                      = { 69730, 201900 }, -- x
    ice_strike                    = { 69766, 342240 }, -- x
    improved_call_of_the_elements = { 69686, 383011 }, -- x
    improved_lightning_bolt       = { 69698, 381674 }, -- Passive
    improved_maelstrom_weapon     = { 69755, 383303 }, -- Passive
    lashing_flames                = { 69677, 334046 }, -- x
    lava_burst                    = { 69726, 51505  }, -- x
    lava_lash                     = { 69762, 60103  }, -- x
    legacy_of_the_frost_witch     = { 69735, 384450 }, -- Need to track actual MW stacks that are spent; no tracking aura.
    lightning_lasso               = { 69684, 305483 },
    maelstrom_weapon              = { 69717, 187880 },
    mana_spring_totem             = { 69702, 381930 },
    molten_assault                = { 69763, 334033 }, -- x
    natures_fury                  = { 69714, 381655 },
    natures_guardian              = { 69697, 30884  },
    natures_swiftness             = { 69699, 378081 },
    overflowing_maelstrom         = { 69676, 384149 },
    planes_traveler               = { 69723, 381647 },
    poison_cleansing_totem        = { 69681, 383013 },
    primal_lava_actuators         = { 69764, 390370 },
    primal_maelstrom              = { 69740, 384405 },
    primordial_wave               = { 69743, 375982 },
    purge                         = { 69713, 370    },
    raging_maelstrom              = { 69756, 384143 },
    refreshing_waters             = { 69731, 337974 },
    spirit_walk                   = { 69690, 58875  },
    spirit_wolf                   = { 69721, 260878 },
    spiritwalkers_aegis           = { 69705, 378077 },
    spiritwalkers_grace           = { 69706, 79206  },
    splintered_elements           = { 69739, 382042 },
    static_accumulation           = { 69734, 384411 },
    static_charge                 = { 69694, 265046 },
    stoneskin_totem               = { 69682, 383017 },
    stormblast                    = { 69742, 319930 },
    stormflurry                   = { 69752, 344357 },
    storms_wrath                  = { 69746, 392352 },
    stormstrike                   = { 69761, 17364  },
    sundering                     = { 69757, 197214 },
    surging_shields               = { 69691, 382033 },
    swirling_currents             = { 69701, 378094 },
    swirling_maelstrom            = { 69732, 384359 },
    thorims_invocation            = { 69733, 384444 },
    thunderous_paws               = { 69721, 378075 },
    thundershock                  = { 69684, 378779 },
    thunderstorm                  = { 69683, 51490  },
    totemic_focus                 = { 69693, 382201 },
    totemic_projection            = { 69692, 108287 },
    totemic_surge                 = { 69704, 381867 },
    tranquil_air_totem            = { 69682, 383019 },
    tremor_totem                  = { 69695, 8143   },
    unruly_winds                  = { 69758, 390288 },
    voodoo_mastery                = { 69679, 204268 },
    wind_rush_totem               = { 69696, 192077 },
    wind_shear                    = { 69725, 57994  },
    windfury_totem                = { 69753, 8512   },
    windfury_weapon               = { 69760, 33757  },
    winds_of_alakir               = { 69689, 382215 },
    witch_doctors_wolf_bones      = { 69737, 384447 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    spectral_recovery = 3519, -- 204261
    static_field_totem = 5438, -- 355580
    traveling_storms = 5527, -- 204403
    grounding_totem = 3622, -- 204336
    unleash_shield = 3492, -- 356736
    ride_the_lightning = 721, -- 289874
    seasoned_winds = 5414, -- 355630
    tidebringer = 5518, -- 236501
    thundercharge = 725, -- 204366
    shamanism = 722, -- 193876
    ethereal_form = 1944, -- 210918
    swelling_waves = 3623, -- 204264
    skyfury_totem = 3487, -- 204330
    counterstrike_totem = 3489, -- 204331
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
            local name, _, count, debuffType, duration, expirationTime = GetPlayerAuraBySpellID( 335904 )

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
        max_stack = 10,
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
    },
    overflowing_maelstrom = {
        id = 384149,
    },
    --[[ primal_lava_actuators = {
        id = 390370,
    }, ]]
    primal_lava_actuators = {
        id = 335896,
        duration = 15,
        max_stack = 20,
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
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1,
    },
    spirit_wolf = {
        id = 260881,
        duration = 3600,
        max_stack = 1,
    },
    spiritwalkers_grace = {
        id = 79206,
    },
    static_charge = {
        id = 118905,
        duration = 3,
        type = "Magic",
        max_stack = 1,
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
    swirling_maelstrom = {
        id = 384359,
    },
    tailwind_totem = {
        id = 262400,
        duration = 120,
        max_stack =1 ,
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
    swirling_currents = {
        id = 338340,
        duration = 15,
        max_stack = 1
    },
    thunderous_paws = {
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
    addStack( "maelstrom_weapon", nil, 1 )
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
            end
        else
            removeBuff( "ghost_wolf" )
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

spec:RegisterStateFunction( "maelstrom_mod", function( amount )
    local mod = max( 0, 1 - ( 0.2 * buff.maelstrom_weapon.stack ) )
    return mod * amount
end )

spec:RegisterTotem( "windfury_totem", 136114 )
spec:RegisterTotem( "skyfury_totem", 135829 )
spec:RegisterTotem( "counterstrike_totem", 511726 )


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
        cooldown = 45,
        gcd = "spell",

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
        cooldown = 30,
        gcd = "spell",

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
        cooldown = 60,
        gcd = "spell",

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
        cast = function () return maelstrom_mod( 2 ) * haste end,
        cooldown = 12,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "elemental_blast",
        startsCombat = true,
        texture = 651244,

        handler = function ()
            consume_maelstrom()
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

            addStack( "maelstrom_weapon", nil, 1 )
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
            removeBuff( "hailstorm" )
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
            if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws" ) end
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
        cast = function () return maelstrom_mod( 2 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
            consume_maelstrom()

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
        cooldown = 45,
        gcd = "spell",

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
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135829,

        pvptalent = "skyfury_totem",

        handler = function ()
            summonPet( "skyfury_totem" )
            applyBuff( "skyfury_totem" )
        end,

        auras = {
            skyfury_totem = {
                id = 208963,
                duration = 3600,
                max_stack = 1,
            },
        },
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
        cooldown = 30,
        gcd = "spell",

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
                addStack( "maelstrom_weapon", nil, 1 )
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
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "tranquil_air_totem",
        startsCombat = true,
        texture = 538575,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tranquil_air_totem" )
        end,
    },


    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

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
        gcd = "spell",

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

            if talent.elemental_assault.enabled then
                addStack( "maelstrom_weapon", nil, 1 )
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


spec:RegisterPack( "Enhancement", 20220911, [[Hekili:TZvBVnUns4FlbfWngxQpl5K0MdXbOxrXHDrVTaNlWDFYYkY0ocrwYNeDYgGa)B)MHsIIKIdLLTt7h6bSyXUwKdN3NNzeTN7n)3MpBziNn)l(J99hFNN3iFVX3DZ8z832YMpBBy0ZHRH)rA4g4V)50NctJyByPC8zVLKfUejrr2U8i45ZI38tZN94U4e(NsN)OjTHfULfb))BNmF2tXlxYkxeRisJ27xm7PWnHP7)8pUB9Uc4)7p5k4VaYmFwsCbVqCOXPRtyW)6lcXimIhNLoF2RXPll45Xpd8dln8Xe2Y5)95C4uXv18jZIYJ5S84qKHxTA0tz8aGdwoA329lE)99lUC)I8DPSvz5RzJ2MhVjmjij8LWa4K2fYZYlgX(V7I3ULTC)Ib7xiOI91vWb94(fpSFXT7xmSHxflljS4jK)MqYFxurCu0wTl)TaEgNTbyuDPU5ri5UMKCns1YSSnbcfMfrr5HQNubirBQuWWXCZh0XeLdQLGK41pXtbdnEu3(bDuXrSGgb67)GoLIDPlb6ukk)GBFr0lklFzm4j9A4l459AQ4aqFYW4LbSxGWKrHlHZiov4yDTFPxRThFVPFNb9ro6oxEF84ONroxsGvjq(GGINYIEg3S3y3YZMqwcOHr9clCBwQmGy6(f3Oh8Ok2yK4asj26wYzBcJtlQvw1rofBtItboIbekrKJPqgNVc9XcKB8EGN881dtR9cdEmlHleypAVec7Z4g69cdYdM3eQ61vQPW4eryNMd1Q8ScUInGo)XYm(iflgOKwLZkEcxjrUip6ShxOMwSGXwweKTkipCZ2WuEW68Sx5pPevGA4OSSe0fE0kwoyOk2gduRXubANjkANvHSaEEyAXQDf4hGSdDwgEycQQfQNvj7YZFBu16A8Rep8rm2JL7kxMhDgMg68mJT1GmrGbkvpxLhDAKUJiAOCLZkO0EemnLUE05oASl5HRr31khTxYY5SVQNQQsVXcZ5pbUfXSKLAkoi4r1nn4jgWeGGcuV0K5jRs6EDJDfdFzLfsLenogFh4yabIL)PrPGhbkDG(JfUrjmIoh2Fs0mQ8SaYZjNx2k3bp9UXMU)GGb8QWf1No7OZJfZ8oMUCaMcXvszFFvCGQX2gabPZu2TwX4akZgiOQiLPOkt(UTa(ypTZOPYjK5fa3SIREUaa6KhbidJEjljKhNazQZseA9AsGNaDwqBWdBQOHQvxqf9VvvX1uiWqTDkP0obRQJ8DeoNQ1A1GD5FNQGQwavxuNmwDDMqrnwRw3hkyjnwgDnECVVWcmQsRWNX5SG0Sxcf0H25v6eTf6zAh4dXqhrGesNiBEHinVwvektIiR8ykh0oHfmoh0pfJwfNKa5SmfdDmJt6OyRdV5jU8MH4QWSM2cps)vxz3oGQmhtdcw64H2wFAhLwqXH0O4Px1SJsHDxD)qA083r20SulT3S9W7s)SBLqfCTQRfSMRve9wegVNY2eJS6qIKh0zWVGSfSgsz214SYtLJ6hEbgVXD1zRIllu0m5TG8mqlR0qwB3xJqIwt8Ob6(Ha97SCSMTmqJWYSRRQMORXqszoVVL10HTVvN9kfVTzDC036H0MpDQVlKHwnnRQgxD2Kw7mNDHLo9zhbCvptYtymAhbOd7CmgDx05mm1cBJasBrRJw21SnOli0JPr4aMqnmL15zGcno9L41z5HQavkLd5cxHjzXPm8yswrr2Mc91D4JJqHDTmKHoaKyMvqouUJ2OFVoqJ21)7AkcN(HQHeWXOfoxhNr2tn84n8IrJh05yDgusue0r3PvPWewIsmiA5XqNnsxbNgsF6mNvNzs1rkeJI2i27iXUJEADPJMqPJ06iqBELg2Mo6jThJmZVNXFQKtB4LNuJQki8Ap7nh9I2hkBo5aAWlDpUeNQ0jDm)NEa0zcDuJlhmFchSjAZQPJoSNOUwY3VNExS0J)PSd2pYb14O1wRJEVtKmt(EvrZS2LH49dARLEghhPxN12J186UwB6jUhNW1D0K(jmfGLSvH7ainMVGyaer2YKDqeT8CFueg6cTyvw6WIiw6s89uRHULEkPIhlF)hkBxF6Cc8JvDcwJJU(9rREqLwgaOglT2SGfHhQuBko6Ta2Y1m13J9H8ssax9ONl78ExE12RO7sMyfcljCWfBHGkj5RI(LyLBga(Jaynb9nXQwA7Wx7FE82sJYNs)UOSnpgY3VyBg(r7xedl9reyhd1GLpJHtYOXuwUuH3SHXZG4YyDvhgiSaejHxOXURxfiUbqAlmckEDCY)3N4K9jS7kuE7sm1282d9rM1jmcwma0pmcG2JniHtlcyswrRuiYLu8kaELSbkOw1n1CIlYZBpRhznNOWCr7hRG2zy5P476eQaTInFw7jTqU4GRDWJt8C(A(9UL2aulC0CjVJje9si8VGNmcwE6ZmUxqCb4YfNRGtT(riXOrlzHy(0eZhjMwRc7kGghHm9fgLtCmoMlCgWkdvuEyTvWzOkOzVzSrXLaSuKGDCpUL(YokhdlVGL)CDFBhYCzo8JP)sncTti5cUX5fz63bUbFi4rJZUnmrKgX91zOdw6IomfHRXGjWvn6zr2HYrFivnkx5btNvAyIURUOp0dRVaGH1Zs6SpTfZultf52hsdpL7CogUktsNjtAQLAhXXCqdF(WEFjbvf468QxHtX3bVQxi2aoRkXVOtBQKkT5srHzs4WZGs4SGiiXk4BYTCrj0rlTA)IS0K3W)MHqUyBE7kawwECgOoHpEvwss2RG8bfS3V4BlVhMFBP4Ja3WBO5i1A1jjbL)Na8ryVzqWcYhw6IuZVQ82Eguv3sCocK6Mz514)FfyHnaW)4TjvSpqVRQ4wsPim78lcpykc4lMKxpbkjXZ2H4tl7v1(qw0Vydp)MQTvDL4TYnNvcwEE3VbuPBsfSrDyz2AVQCHU7wsqArlT8S017yDs92RvIOxMKnJZHdcNo2BSLVIis5zFno1SBs3mvZSUREZFKSK5kTHfTH4QqPRM1v96ASA6Z8Ho1F35bgqNmHmfGtODDEXbmQqqo7dftQ69lWmTC2wXLfOz51ybX)vYoMe43iU3O4IrgnguYn6lHeuRTf7S7bGxQIwBJYL3(fn2dzXVBzXVpYIF)LfFvzrKV4fiZdY3kxs)xdZrxFy))7F8F9Lp9L)XFB)I9l(nmnz8MTz5Cm5zUmNzoR8GrhKnWAc3XZ2amo8brqZQRzfJ2)5FjgRL4DdqQFklfouXZ)wPl1)biept7tQ9QGNCP)xhkjYKJKi48d(5F9xaQ5jO2(p3H4jlS1dj0)mXCvI61NhQ1POwnRS(jRE3ECCxL1StMswkRFS13FKCLQI)iPHDR4pyqS6ayVgQPKFc)SlNOS97i2UVLT7RU99F(tc9jURR1X2GAleRq2Qymt138naFB77Fd(GwFhCqkxsSIrsB0udmcxfVAQlqg3d1BTqM)Y0)AB4asArJQGMCuqhSVAZc)YJMc7a9bRuXhPcnib7BxVaosHlCIlyazdgeA56k0iPjra8(7Kv9Tt36YFxH1DM2Qe6vIIItBcbAxs8931Ekz1qJ15Oqyp4uFko1wX7goWDDBJ15KtlJ5(5VYI2jcCH2nZFdVAoywprRkGSGPhXXJh(syCckdJKI4u5R3aO0(f9zU6sAakNYfJUgxsoiIbT7h(HP3nEGJz1CV34HV)(LeJZEG1rzdBWCi2nKWY4Rhqm6AGoedT(9317C7bp4iZkkgOn)visVsLw92eu1xnVpb1pTEmLvUy6Ep)jw52wVsPZCeRitn3Aa)MhG)n0hazqRiJ7bmP(wsdiFTTD37DBBfHkxvNPuCS0dA3Yw8TUfFRBro3C1pSzM1ckr6sw5QOnh03F3Hd5d3OzzBgAD)phv6iN2C)jtFyx9Xi)XEwAdrURJ6IoupktCw7Z1NlR70pGpSlWgdhCPJblRaAO1WKnJcM6nutPl5eK)SNd0DGKbUPQrFo17gbb7gbL9rap4sB8YTw4L6mQwqIn4s3q4Q2PTX7oSS0Zzz0SQAlZjBwLuuSVRkhY5urojtRMGFoBJATBwc2Kd(r3fWYevvFS2au1a9u(L3VCF1qX(NO8HVog8c50W2nshYJnimb(CQ2xzezzk7xOMhMEJ2Mr2x)2q1B)w18bvKuE1kpheZ23qdD6687HXahFhmgq(9V4HXMSH6()d44LxNnfVrJRahKGaatr9SRhq9eTBe)qZd24w4EL2fgRm4OScHLRRRbPewyH3UHFH7VPesqGgxEWwEDn3bVpe6lV1N20beF9lgqypUxtPtyAU)2wwdLNww3U6B5HJLzZGXj(YtqXihg32sHPDz)fiaO8b1ZVklZ12lE4acNTbUZ6bfdlrxB9l5GjQ6PE(THvlF46OLTnmn38rzky1V6cTwFB4rhneNd)BKWbK73AWGaoXrO4VVv1gTsdNhkQh2FEOznxEuPHV(auZCx39)kKzw)kG0NKsCxx2)Js0MyUl1syTeB9lRR06OFl9PLikVX27X4YZ3FqqgtpTFBMsoTtGPETkUBZfUBH(Gmy(D4lsxJ2bt2UCtZ0DRhxvPh4bmo3dQILYfzVJmPosmFA2nlgETHpz9Hn3eDBkA9bUBRpo1Hwv2GWmrZshEhcLnxn1MDT8rwd5u(5jdWuEO)WK1uIO9Ak1HQiAKhVL39GnDHAeGCV0G(6zZgskEw7hss1MFPgote8m1JLKEM48PkLsoEIRTazko9ERw8oHX24A2cdzh48OQ)BHJTU0QiUEJx0MyQwCuyMSO1gBt9CWGjLBHivK9qCh)cDzJBAdv9IdhYPYCjT97X1dtSPamIQ76feiEqZV4w2cQ7juKg96XJSqsJpYjyCj9me8Gm3oMWGTiIlfYMTFeO(UjdhAZf)JySi)rlt9CGAeV7StnzgGt0EYm92aSfZq90(dWvjJ9jaXZrLExGE8SQdRtKDQ6xYIfu6xTcUwm5DLkVBSgoXnyJ4D3bqhMsh3fdYGDlqAPkSB93OPt2Vq8vXCh)PS8QFdGXRw48)3d]] )