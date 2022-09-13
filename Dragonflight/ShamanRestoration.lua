-- ShamanRestoration.lua
-- September 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 264 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    acid_rain                     = { 69822, 378443, 1 }, --
    ancestral_awakening           = { 69815, 382309, 2 }, --
    ancestral_defense             = { 69728, 382947, 1 },
    ancestral_guidance            = { 69685, 108281, 1 },
    ancestral_protection_totem    = { 69805, 207399, 1 },
    ancestral_reach               = { 69821, 382732, 1 },
    ancestral_vigor               = { 69820, 207401, 2 },
    ancestral_wolf_affinity       = { 69678, 382197, 1 },
    ascendance                    = { 69810, 114052, 1 },
    astral_bulwark                = { 69723, 377933, 1 },
    astral_shift                  = { 69724, 108271, 1 },
    brimming_with_life            = { 69680, 381689, 1 },
    call_of_the_elements          = { 69687, 108285, 1 },
    call_of_thunder               = { 69817, 378241, 1 },
    capacitor_totem               = { 69722, 192058, 1 },
    chain_heal                    = { 69707, 1064  , 1 },
    chain_lightning               = { 69718, 188443, 1 },
    cloudburst_totem              = { 69809, 157153, 1 },
    continuous_waves              = { 69770, 382046, 1 },
    creation_core                 = { 69686, 383012, 1 },
    deeply_rooted_elements        = { 69801, 378270, 1 },
    deluge                        = { 69824, 200076, 2 },
    downpour                      = { 69811, 207778, 1 },
    earth_elemental               = { 69708, 198103, 1 },
    earth_shield                  = { 69709, 974   , 1 },
    earthen_harmony               = { 69832, 382020, 2 },
    earthen_wall_totem            = { 69805, 198838, 1 },
    earthgrab_totem               = { 69696, 51485 , 1 },
    earthliving_weapon            = { 69803, 382021, 1 },
    earthwarden                   = { 69800, 382315, 2 },
    echo_of_the_elements          = { 69831, 333919, 1 },
    elemental_orbit               = { 69703, 383010, 1 },
    elemental_warding             = { 69729, 381650, 2 },
    enfeeblement                  = { 69679, 378079, 1 },
    everrising_tide               = { 69833, 382029, 1 },
    fire_and_ice                  = { 69727, 382886, 1 },
    flash_flood                   = { 69828, 280614, 2 },
    flow_of_the_tides             = { 69821, 382039, 1 },
    flurry                        = { 69716, 382888, 1 },
    focused_insight               = { 69715, 381666, 2 },
    frost_shock                   = { 69719, 196840, 1 },
    go_with_the_flow              = { 69688, 381678, 2 },
    graceful_spirit               = { 69705, 192088, 1 },
    greater_purge                 = { 69713, 378773, 1 },
    guardians_cudgel              = { 69694, 381819, 1 },
    gust_of_wind                  = { 69690, 192063, 1 },
    healing_rain                  = { 69823, 73920 , 1 },
    healing_stream_totem          = { 69700, 5394  , 1 },
    healing_stream_totem          = { 69826, 5394  , 1 },
    healing_tide_totem            = { 69767, 108280, 1 },
    healing_wave                  = { 69818, 77472 , 1 },
    hex                           = { 69711, 51514 , 1 },
    high_tide                     = { 69771, 157154, 1 },
    improved_call_of_the_elements = { 69686, 383011, 1 },
    improved_lightning_bolt       = { 69698, 381674, 2 },
    improved_primordial_wave      = { 69769, 382191, 2 },
    improved_purify_spirit        = { 69710, 383016, 1 },
    lava_burst                    = { 69726, 51505 , 1 },
    lava_surge                    = { 69830, 77756 , 1 },
    lightning_lasso               = { 69684, 305483, 1 },
    living_stream                 = { 69809, 382482, 1 },
    maelstrom_weapon              = { 69717, 187880, 1 },
    mana_spring_totem             = { 69702, 381930, 1 },
    mana_tide_totem               = { 69806, 16191 , 1 },
    master_of_the_elements        = { 69807, 16166 , 1 },
    natures_focus                 = { 69768, 382019, 1 },
    natures_fury                  = { 69714, 381655, 2 },
    natures_guardian              = { 69697, 30884 , 2 },
    natures_swiftness             = { 69699, 378081, 1 },
    overflowing_shores            = { 69822, 383222, 1 },
    planes_traveler               = { 69723, 381647, 1 },
    poison_cleansing_totem        = { 69681, 383013, 1 },
    primal_tide_core              = { 69771, 382045, 1 },
    primordial_wave               = { 69812, 375982, 1 },
    purge                         = { 69713, 370   , 1 },
    refreshing_waters             = { 69807, 378211, 1 },
    resurgence                    = { 69816, 16196 , 1 },
    riptide                       = { 69825, 61295 , 1 },
    spirit_link_totem             = { 69829, 98008 , 1 },
    spirit_walk                   = { 69690, 58875 , 1 },
    spirit_wolf                   = { 69721, 260878, 1 },
    spiritwalkers_aegis           = { 69705, 378077, 1 },
    spiritwalkers_grace           = { 69706, 79206 , 1 },
    static_charge                 = { 69694, 265046, 1 },
    stoneskin_totem               = { 69682, 383017, 1 },
    stormkeeper                   = { 69678, 383009, 1 },
    surging_shields               = { 69691, 382033, 2 },
    swirling_currents             = { 69701, 378094, 2 },
    thunderous_paws               = { 69721, 378075, 1 },
    thundershock                  = { 69684, 378779, 1 },
    thunderstorm                  = { 69683, 51490 , 1 },
    tidal_waves                   = { 69827, 51564 , 1 },
    torrent                       = { 69804, 200072, 2 },
    totemic_focus                 = { 69693, 382201, 2 },
    totemic_projection            = { 69692, 108287, 1 },
    totemic_surge                 = { 69704, 381867, 2 },
    tranquil_air_totem            = { 69682, 383019, 1 },
    tremor_totem                  = { 69695, 8143  , 1 },
    tumbling_waves                = { 69770, 382040, 1 },
    undercurrent                  = { 69802, 382194, 2 },
    undulation                    = { 69814, 200071, 1 },
    unleash_life                  = { 69814, 73685 , 1 },
    voodoo_mastery                = { 69679, 204268, 1 },
    water_shield                  = { 69819, 52127 , 1 },
    water_totem_mastery           = { 69808, 382030, 1 },
    wavespeakers_blessing         = { 69813, 381946, 1 },
    wellspring                    = { 69801, 197995, 1 },
    wind_rush_totem               = { 69696, 192077, 1 },
    wind_shear                    = { 69725, 57994 , 1 },
    winds_of_alakir               = { 69689, 382215, 2 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    skyfury_totem = 707, -- 204330
    unleash_shield = 5437, -- 356736
    counterstrike_totem = 708, -- 204331
    swelling_waves = 712, -- 204264
    electrocute = 714, -- 206642
    grounding_totem = 715, -- 204336
    tidebringer = 1930, -- 236501
    traveling_storms = 5528, -- 204403
    cleansing_waters = 3755, -- 290250
    ancestral_gift = 3756, -- 290254
    living_tide = 5388, -- 353115
    precognition = 5458, -- 377360
    spectral_recovery = 3520, -- 204261
} )


-- Auras
spec:RegisterAuras( {
    ancestral_guidance = {
        id = 108281,
    },
    ascendance = {
        id = 114052,
    },
    astral_shift = {
        id = 108271,
    },
    earth_elemental = {
        id = 198103,
    },
    earthliving_weapon = {
        id = 382021,
    },
    earthquake = {
        id = 61882,
    },
    everrising_tide = {
        id = 382029,
    },
    far_sight = {
        id = 6196,
    },
    fire_elemental = {
        id = 198067,
    },
    ghost_wolf = {
        id = 2645,
    },
    healing_rain = {
        id = 73920,
    },
    healing_tide_totem = {
        id = 108280,
    },
    icefury = {
        id = 210714,
    },
    lightning_shield = {
        id = 192106,
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
    sign_of_the_twisting_nether = {
        id = 335148,
        duration = 3600,
        max_stack = 1,
    },
    spirit_walk = {
        id = 58875,
    },
    spiritwalkers_grace = {
        id = 79206,
    },
    storm_elemental = {
        id = 192249,
    },
    stormkeeper = {
        id = 383009,
    },
    unleash_life = {
        id = 73685,
    },
    water_shield = {
        id = 52127,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    ancestral_guidance = {
        id = 108281,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "ancestral_guidance",
        startsCombat = true,
        texture = 538564,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ancestral_protection_totem = {
        id = 207399,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        talent = "ancestral_protection_totem",
        startsCombat = true,
        texture = 136080,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ancestral_spirit = {
        id = 2008,
        cast = 9.999683379364,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136077,

        handler = function ()
        end,
    },


    ancestral_vision = {
        id = 212048,
        cast = 9.999683379364,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 237576,

        handler = function ()
        end,
    },


    ascendance = {
        id = 114052,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "ascendance",
        startsCombat = true,
        texture = 135791,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    astral_recall = {
        id = 556,
        cast = 9.999683379364,
        cooldown = 600,
        gcd = "spell",

        startsCombat = true,
        texture = 136010,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    astral_shift = {
        id = 108271,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "astral_shift",
        startsCombat = true,
        texture = 538565,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    bloodlust = {
        id = 2825,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = true,
        texture = 136012,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    call_of_the_elements = {
        id = 108285,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "call_of_the_elements",
        startsCombat = true,
        texture = 538570,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "capacitor_totem",
        startsCombat = true,
        texture = 136013,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chain_heal = {
        id = 1064,
        cast = 2.500210355072,
        cooldown = 0,
        gcd = "spell",

        spend = 0.3,
        spendType = "mana",

        talent = "chain_heal",
        startsCombat = true,
        texture = 136042,

        handler = function ()
        end,
    },


    chain_lightning = {
        id = 188443,
        cast = 1.9999366758728,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,
        texture = 136015,

        handler = function ()
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
        startsCombat = true,
        texture = 236288,

        handler = function ()
        end,
    },


    cloudburst_totem = {
        id = 157153,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "cloudburst_totem",
        startsCombat = true,
        texture = 971076,

        handler = function ()
        end,
    },


    downpour = {
        id = 207778,
        cast = 1.4996629966736,
        cooldown = 5,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "downpour",
        startsCombat = true,
        texture = 1698701,

        handler = function ()
        end,
    },


    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        talent = "earth_elemental",
        startsCombat = true,
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

        talent = "earth_shield",
        startsCombat = true,
        texture = 136089,

        handler = function ()
        end,
    },


    earth_shock = {
        id = 8042,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 60,
        spendType = "maelstrom",

        talent = "earth_shock",
        startsCombat = true,
        texture = 136026,

        handler = function ()
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

        handler = function ()
        end,
    },


    earthen_wall_totem = {
        id = 198838,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        talent = "earthen_wall_totem",
        startsCombat = true,
        texture = 136098,

        toggle = "cooldowns",

        handler = function ()
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

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    earthliving_weapon = {
        id = 382021,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "earthliving_weapon",
        startsCombat = true,
        texture = 237578,

        handler = function ()
        end,
    },


    earthquake = {
        id = 61882,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 60,
        spendType = "maelstrom",

        talent = "earthquake",
        startsCombat = true,
        texture = 451165,

        handler = function ()
        end,
    },


    elemental_blast = {
        id = 117014,
        cast = 1.9999366758728,
        cooldown = 12,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "elemental_blast",
        startsCombat = true,
        texture = 651244,

        handler = function ()
        end,
    },


    everrising_tide = {
        id = 382029,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "everrising_tide",
        startsCombat = true,
        texture = 132852,

        handler = function ()
        end,
    },


    far_sight = {
        id = 6196,
        cast = 1.9999366758728,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 136034,

        handler = function ()
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
        startsCombat = true,
        texture = 135790,

        toggle = "cooldowns",

        handler = function ()
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
        end,
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
        end,
    },


    ghost_wolf = {
        id = 2645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 136095,

        handler = function ()
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

        handler = function ()
        end,
    },


    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "gust_of_wind",
        startsCombat = true,
        texture = 1029585,

        handler = function ()
        end,
    },


    healing_rain = {
        id = 73920,
        cast = 1.9999366758728,
        cooldown = 10,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        talent = "healing_rain",
        startsCombat = true,
        texture = 136037,

        handler = function ()
        end,
    },


    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "healing_stream_totem",
        startsCombat = true,
        texture = 135127,

        handler = function ()
        end,
    },


    healing_surge = {
        id = 8004,
        cast = 1.4996629966736,
        cooldown = 0,
        gcd = "spell",

        spend = 0.24,
        spendType = "mana",

        startsCombat = true,
        texture = 136044,

        handler = function ()
        end,
    },


    healing_tide_totem = {
        id = 108280,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "healing_tide_totem",
        startsCombat = true,
        texture = 538569,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    healing_wave = {
        id = 77472,
        cast = 2.500210355072,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "healing_wave",
        startsCombat = true,
        texture = 136043,

        handler = function ()
        end,
    },


    hex = {
        id = 51514,
        cast = 1.7000040765381,
        cooldown = 30,
        gcd = "spell",

        talent = "hex",
        startsCombat = true,
        texture = 237579,

        handler = function ()
        end,
    },


    icefury = {
        id = 210714,
        cast = 1.9999366758728,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "icefury",
        startsCombat = true,
        texture = 135855,

        handler = function ()
        end,
    },


    lava_burst = {
        id = 51505,
        cast = 1.9999366758728,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "lava_burst",
        startsCombat = true,
        texture = 237582,

        handler = function ()
        end,
    },


    lightning_bolt = {
        id = 188196,
        cast = 1.9999366758728,
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

        talent = "lightning_lasso",
        startsCombat = true,
        texture = 1385911,

        handler = function ()
        end,
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

        handler = function ()
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
        startsCombat = true,
        texture = 971079,

        toggle = "cooldowns",

        handler = function ()
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
        startsCombat = true,
        texture = 136053,

        handler = function ()
        end,
    },


    mana_tide_totem = {
        id = 16191,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "mana_tide_totem",
        startsCombat = true,
        texture = 4667424,

        toggle = "cooldowns",

        handler = function ()
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
        end,
    },


    ph_pocopoc_zone_ability_skill = {
        id = 363942,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 4239318,

        handler = function ()
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
        startsCombat = true,
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

        talent = "primordial_wave",
        startsCombat = true,
        texture = 3578231,

        handler = function ()
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

        startsCombat = true,
        texture = 236288,

        handler = function ()
        end,
    },


    riptide = {
        id = 61295,
        cast = 0,
        charges = 1,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "riptide",
        startsCombat = true,
        texture = 252995,

        handler = function ()
        end,
    },


    spirit_link_totem = {
        id = 98008,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        talent = "spirit_link_totem",
        startsCombat = true,
        texture = 237586,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    spirit_walk = {
        id = 58875,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "spirit_walk",
        startsCombat = true,
        texture = 132328,

        toggle = "cooldowns",

        handler = function ()
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
        startsCombat = true,
        texture = 451170,

        toggle = "cooldowns",

        handler = function ()
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

        handler = function ()
        end,
    },


    stormkeeper = {
        id = 383009,
        cast = 1.4996629966736,
        cooldown = 60,
        gcd = "spell",

        talent = "stormkeeper",
        startsCombat = true,
        texture = 839977,

        toggle = "cooldowns",

        handler = function ()
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
        end,
    },


    totemic_projection = {
        id = 108287,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "totemic_projection",
        startsCombat = true,
        texture = 538574,

        handler = function ()
        end,
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

        toggle = "cooldowns",

        handler = function ()
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
        startsCombat = true,
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

        talent = "unleash_life",
        startsCombat = true,
        texture = 462328,

        handler = function ()
        end,
    },


    water_shield = {
        id = 52127,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "water_shield",
        startsCombat = true,
        texture = 132315,

        handler = function ()
        end,
    },


    water_walking = {
        id = 546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 135863,

        handler = function ()
        end,
    },


    wellspring = {
        id = 197995,
        cast = 1.4996629966736,
        cooldown = 20,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        talent = "wellspring",
        startsCombat = true,
        texture = 893778,

        handler = function ()
        end,
    },


    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "wind_rush_totem",
        startsCombat = true,
        texture = 538576,

        toggle = "cooldowns",

        handler = function ()
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

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Restoration",
    20220911,
-- Notes
[[

]],
-- Priority
[[

]] )