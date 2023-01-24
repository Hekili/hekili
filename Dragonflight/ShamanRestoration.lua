-- ShamanRestoration.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 264 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Shaman
    ancestral_defense           = { 81083, 382947, 1 },
    ancestral_guidance          = { 81102, 108281, 1 },
    astral_bulwark              = { 81056, 377933, 1 },
    astral_shift                = { 81057, 108271, 1 },
    brimming_with_life          = { 81085, 381689, 1 },
    call_of_the_elements        = { 81090, 383011, 1 },
    capacitor_totem             = { 81071, 192058, 1 },
    creation_core               = { 81090, 383012, 1 },
    earth_elemental             = { 81064, 198103, 1 },
    earth_shield                = { 81106, 974   , 1 },
    earthgrab_totem             = { 81082, 51485 , 1 },
    elemental_orbit             = { 81105, 383010, 1 },
    elemental_warding           = { 81084, 381650, 2 },
    enfeeblement                = { 81078, 378079, 1 },
    fire_and_ice                = { 81067, 382886, 1 },
    flurry                      = { 81059, 382888, 1 },
    focused_insight             = { 81058, 381666, 2 },
    frost_shock                 = { 81074, 196840, 1 },
    go_with_the_flow            = { 81089, 381678, 2 },
    graceful_spirit             = { 81065, 192088, 1 },
    greater_purge               = { 81076, 378773, 1 },
    guardians_cudgel            = { 81070, 381819, 1 },
    gust_of_wind                = { 81088, 192063, 1 },
    healing_stream_totem        = { 81100, 5394  , 1 },
    hex                         = { 81079, 51514 , 1 },
    improved_lightning_bolt     = { 81098, 381674, 2 },
    lightning_lasso             = { 81096, 305483, 1 },
    mana_spring_totem           = { 81103, 381930, 1 },
    natures_fury                = { 81086, 381655, 2 },
    natures_guardian            = { 81081, 30884 , 2 },
    natures_swiftness           = { 81099, 378081, 1 },
    planes_traveler             = { 81056, 381647, 1 },
    poison_cleansing_totem      = { 81093, 383013, 1 },
    purge                       = { 81076, 370   , 1 },
    spirit_walk                 = { 81088, 58875 , 1 },
    spirit_wolf                 = { 81072, 260878, 1 },
    spiritwalkers_aegis         = { 81065, 378077, 1 },
    spiritwalkers_grace         = { 81066, 79206 , 1 },
    static_charge               = { 81070, 265046, 1 },
    stoneskin_totem             = { 81095, 383017, 1 },
    surging_shields             = { 81092, 382033, 2 },
    swirling_currents           = { 81101, 378094, 2 },
    thunderous_paws             = { 81072, 378075, 1 },
    thundershock                = { 81096, 378779, 1 },
    thunderstorm                = { 81097, 51490 , 1 },
    totemic_focus               = { 81094, 382201, 2 },
    totemic_projection          = { 81080, 108287, 1 },
    totemic_recall              = { 81091, 108285, 1 },
    totemic_surge               = { 81104, 381867, 2 },
    tranquil_air_totem          = { 81095, 383019, 1 },
    tremor_totem                = { 81069, 8143  , 1 },
    voodoo_mastery              = { 81078, 204268, 1 },
    wind_rush_totem             = { 81082, 192077, 1 },
    wind_shear                  = { 81068, 57994 , 1 },
    winds_of_alakir             = { 81087, 382215, 2 },

    -- Restoration
    acid_rain                   = { 81039, 378443, 1 },
    ancestral_awakening         = { 81043, 382309, 2 },
    ancestral_protection_totem  = { 81046, 207399, 1 },
    ancestral_reach             = { 81031, 382732, 1 },
    ancestral_vigor             = { 81030, 207401, 2 },
    ancestral_wolf_affinity     = { 81029, 382197, 1 },
    ascendance                  = { 81055, 114052, 1 },
    call_of_thunder             = { 81023, 378241, 1 },
    chain_heal                  = { 81063, 1064  , 1 },
    chain_lightning             = { 81061, 188443, 1 },
    cloudburst_totem            = { 81048, 157153, 1 },
    continuous_waves            = { 81034, 382046, 1 },
    deeply_rooted_elements      = { 81051, 378270, 1 },
    deluge                      = { 81028, 200076, 2 },
    downpour                    = { 80976, 207778, 1 },
    earthen_harmony             = { 81054, 382020, 2 },
    earthen_wall_totem          = { 81046, 198838, 1 },
    earthliving_weapon          = { 81049, 382021, 1 },
    echo_of_the_elements        = { 81044, 333919, 1 },
    everrising_tide             = { 81053, 382029, 1 },
    flash_flood                 = { 81020, 280614, 2 },
    flow_of_the_tides           = { 81031, 382039, 1 },
    healing_rain                = { 81040, 73920 , 1 },
    healing_stream_totem_2      = { 81022, 5394  , 1 },
    healing_tide_totem          = { 81032, 108280, 1 },
    healing_wave                = { 81026, 77472 , 1 },
    high_tide                   = { 81042, 157154, 1 },
    improved_earthliving_weapon = { 81050, 382315, 2 },
    improved_primordial_wave    = { 81035, 382191, 2 },
    improved_purify_spirit      = { 81073, 383016, 1 },
    lava_burst                  = { 81062, 51505 , 1 },
    lava_surge                  = { 81017, 77756 , 1 },
    living_stream               = { 81048, 382482, 1 },
    maelstrom_weapon            = { 81060, 187880, 1 },
    mana_tide_totem             = { 81045, 16191 , 1 },
    master_of_the_elements      = { 81019, 16166 , 1 },
    natures_focus               = { 81041, 382019, 1 },
    overflowing_shores          = { 81039, 383222, 1 },
    primal_tide_core            = { 81042, 382045, 1 },
    primordial_wave             = { 81036, 375982, 1 },
    refreshing_waters           = { 81019, 378211, 1 },
    resurgence                  = { 81024, 16196 , 1 },
    riptide                     = { 81027, 61295 , 1 },
    spirit_link_totem           = { 81033, 98008 , 1 },
    stormkeeper                 = { 81029, 383009, 1 },
    tidal_waves                 = { 81021, 51564 , 1 },
    torrent                     = { 81047, 200072, 2 },
    tumbling_waves              = { 81034, 382040, 1 },
    undercurrent                = { 81052, 382194, 2 },
    undulation                  = { 81037, 200071, 1 },
    unleash_life                = { 81037, 73685 , 1 },
    water_shield                = { 81025, 52127 , 1 },
    water_totem_mastery         = { 81018, 382030, 1 },
    wavespeakers_blessing       = { 81038, 381946, 1 },
    wellspring                  = { 81051, 197995, 1 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    ancestral_gift      = 3756, -- (290254)
    cleansing_waters    = 3755, -- (290250)
    counterstrike_totem = 708 , -- (204331)
    electrocute         = 714 , -- (206642)
    grounding_totem     = 715 , -- (204336)
    living_tide         = 5388, -- (353115)
    precognition        = 5458, -- (377360)
    skyfury_totem       = 707 , -- (204330)
    spectral_recovery   = 3520, -- (204261)
    swelling_waves      = 712 , -- (204264)
    tidebringer         = 1930, -- (236501)
    traveling_storms    = 5528, -- (204403)
    unleash_shield      = 5437, -- (356736)
} )


-- Auras
spec:RegisterAuras( {
    ancestral_guidance = {
        id = 108281,
        duration = 10,
    },
    ascendance = {
        id = 114052,
        duration = 15,
    },
    astral_shift = {
        id = 108271,
        duration = 8,
    },
    earth_elemental = {
        id = 198103,
    },
    earthliving_weapon = {
        id = 382021,
        duration = 3600,
    },
    everrising_tide = {
        id = 382029,
        duration = 8,
    },
    far_sight = {
        id = 6196,
    },
    ghost_wolf = {
        id = 2645,
        duration = 3600,
    },
    healing_rain = {
        id = 73920,
    },
    healing_tide_totem = {
        id = 108280,
    },
    lightning_shield = {
        id = 192106,
        duration = 1800,
    },
    mastery_deep_healing = {
        id = 77226,
    },
    natures_swiftness = {
        id = 378081,
    },
    reincarnation = {
        id = 20608,
    },
    spirit_walk = {
        id = 58875,
    },
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
    },
    tidal_waves = {
        id = 53390,
        duration = 15,
        max_stack = 2,
    },
    unleash_life = {
        id = 73685,
        duration = 10,
    },
    water_shield = {
        id = 52127,
        duration = 1800,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    ancestral_guidance = {
        id = 108281,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 538564,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("ancestral_guidance")
        end,
    },
    ancestral_protection_totem = {
        id = 207399,
        cast = 0,
        cooldown = 300,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136080,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("ancestral_protection_totem")
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

        handler = function ()
        end,
    },
    ancestral_vision = {
        id = 212048,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 237576,

        handler = function ()
        end,
    },
    ascendance = {
        id = 114052,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 135791,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("ascendance")
        end,
    },
    astral_recall = {
        id = 556,
        cast = 10,
        cooldown = 600,
        gcd = "spell",

        startsCombat = false,
        texture = 136010,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    astral_shift = {
        id = 108271,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 538565,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("astral_shift")
        end,
    },
    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136013,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff("capacitor_totem")
        end,
    },
    chain_heal = {
        id = 1064,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.3,
        spendType = "mana",

        startsCombat = false,
        texture = 136042,

        handler = function ()
            removeStack("tidal_waves")
        end,
    },
    chain_lightning = {
        id = 188443,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136015,

        handler = function ()
        end,
    },
    cloudburst_totem = {
        id = 157153,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "totem",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 971076,

        handler = function ()
        end,
    },
    counterstrike_totem = {
        id = 204331,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 511726,

        handler = function ()
        end,
    },
    downpour = {
        id = 207778,
        cast = 1.5,
        cooldown = 5,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 1698701,

        handler = function ()
        end,
    },
    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        startsCombat = false,
        texture = 136024,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,
        texture = 136089,

        handler = function ()
            applyBuff("earth_shield")
        end,
    },
    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 136102,

        handler = function ()
            applyDebuff("earthbind_totem")
        end,
    },
    earthen_wall_totem = {
        id = 198838,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136098,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("earthen_wall_totem")
        end,
    },
    earthgrab_totem = {
        id = 51485,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136100,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff("earthgrab_totem")
        end,
    },
    earthliving_weapon = {
        id = 382021,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        startsCombat = false,
        texture = 237578,

        handler = function ()
            applyBuff("earthliving_weapon")
        end,
    },
    everrising_tide = {
        id = 382029,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 132852,

        handler = function ()
            applyBuff("everrising_tide")
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
            applyBuff("far_sight")
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
            applyDebuff("flame_shock")
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
            applyBuff("flametongue_weapon")
        end,
    },
    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 135849,

        handler = function ()
            applyDebuff("frost_shock")
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
            applyBuff("ghost_wolf")
        end,
    },
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = true,
        texture = 451166,

        handler = function ()
        end,
    },
    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 136039,

        handler = function ()
        end,
    },
    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 1029585,

        handler = function ()
        end,
    },
    healing_rain = {
        id = 73920,
        cast = 2,
        cooldown = 10,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = true,
        texture = 136037,

        handler = function ()
        end,
    },
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 2 end
        end,
        cooldown = 30,
        recharge = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 30 end
        end,
        gcd = "totem",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 135127,

        handler = function ()
        end,
    },
    healing_surge = {
        id = 8004,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.24,
        spendType = "mana",

        startsCombat = false,
        texture = 136044,

        handler = function ()
            removeStack("tidal_waves")
            if talent.earthen_harmony.enabled then
                addStack("earth_shield", nil, 1)
            end
        end,
    },
    healing_tide_totem = {
        id = 108280,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 538569,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    healing_wave = {
        id = 77472,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 136043,

        handler = function ()
            removeStack("tidal_waves")
            if talent.earthen_harmony.enabled then
                addStack("earth_shield", nil, 1)
            end
        end,
    },
    heroism = {
        id = 32182,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 132313,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("heroism")
        end,
    },
    hex = {
        id = 51514,
        cast = 1.7,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 237579,

        handler = function ()
            applyDebuff("hex")
        end,
    },
    lava_burst = {
        id = 51505,
        cast = 2,
        charges = 2,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 237582,

        handler = function ()
        end,
    },
    lightning_bolt = {
        id = 188196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
        end,
    },
    lightning_lasso = {
        id = 305483,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,
        texture = 1385911,

        handler = function ()
            applyDebuff("lightning_lasso")
        end,
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

        handler = function ()
            applyBuff("lightning_shield")
        end,
    },
    mana_tide_totem = {
        id = 16191,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        startsCombat = false,
        texture = 4667424,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("mana_tide_totem")
        end,
    },
    natures_swiftness = {
        id = 378081,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 136076,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("natures_swiftness")
        end,
    },
    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136070,

        handler = function ()
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

        startsCombat = true,
        texture = 3578231,

        handler = function ()
            applyBuff("riptide")
            applyDebuff("flame_shock")
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

        handler = function ()
        end,
    },
    purify_spirit = {
        id = 77130,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236288,

        handler = function ()
        end,
    },
    riptide = {
        id = 61295,
        cast = 0,
        charges = 2,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 252995,

        handler = function ()
            applyBuff("riptide")
            if talent.tidal_waves.enabled then
                addStack( "tidal_waves", nil, 2 )
            end
        end,
    },
    skyfury_totem = {
        id = 204330,
        cast = 0,
        cooldown = 40,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135829,

        handler = function ()
        end,
    },
    spirit_link_totem = {
        id = 98008,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 237586,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    spirit_walk = {
        id = 58875,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 132328,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    spiritwalkers_grace = {
        id = 79206,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.14,
        spendType = "mana",

        startsCombat = false,
        texture = 451170,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("spiritwalkers_grace")
        end,
    },
    stoneskin_totem = {
        id = 383017,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 4667425,

        handler = function ()
        end,
    },
    stormkeeper = {
        id = 383009,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",

        startsCombat = false,
        texture = 839977,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("stormkeeper")
        end,
    },
    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 237589,

        handler = function ()
        end,
    },
    totemic_projection = {
        id = 108287,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        startsCombat = false,
        texture = 538574,

        handler = function ()
        end,
    },
    totemic_recall = {
        id = 108285,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 538570,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    tranquil_air_totem = {
        id = 383019,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 538575,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("tranquil_air_totem")
        end,
    },
    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136108,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    unleash_life = {
        id = 73685,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 462328,

        handler = function ()
        end,
    },
    unleash_shield = {
        id = 356736,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 538567,

        handler = function ()
            applyBuff("unleash_life")
        end,
    },
    water_shield = {
        id = 52127,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132315,

        handler = function ()
            applyBuff("water_shield")
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
            applyBuff("water_walking")
        end,
    },
    wellspring = {
        id = 197995,
        cast = 1.5,
        cooldown = 20,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,
        texture = 893778,

        handler = function ()
        end,
    },
    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        startsCombat = false,
        texture = 538576,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("wind_rush_totem")
        end,
    },
    wind_shear = {
        id = 57994,
        cast = 0,
        cooldown = 12,
        gcd = "off",

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },
} )

spec:RegisterPriority( "Restoration", 20221112,
-- Notes
[[

]],
-- Priority
[[

]] )