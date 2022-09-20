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
    acid_rain                     = { 77633, 378443, 1 },
    ancestral_awakening           = { 77637, 382309, 2 },
    ancestral_defense             = { 77677, 382947, 1 },
    ancestral_guidance            = { 77696, 108281, 1 },
    ancestral_protection_totem    = { 77640, 207399, 1 },
    ancestral_reach               = { 77625, 382732, 1 },
    ancestral_vigor               = { 77624, 207401, 2 },
    ancestral_wolf_affinity       = { 77623, 382197, 1 },
    ascendance                    = { 77649, 114052, 1 },
    astral_bulwark                = { 77650, 377933, 1 },
    astral_shift                  = { 77651, 108271, 1 },
    brimming_with_life            = { 77679, 381689, 1 },
    call_of_the_elements          = { 77685, 108285, 1 },
    call_of_thunder               = { 77617, 378241, 1 },
    capacitor_totem               = { 77665, 192058, 1 },
    chain_heal                    = { 77657, 1064  , 1 },
    chain_lightning               = { 77655, 188443, 1 },
    cloudburst_totem              = { 77642, 157153, 1 },
    continuous_waves              = { 77628, 382046, 1 },
    creation_core                 = { 77684, 383012, 1 },
    deeply_rooted_elements        = { 77645, 378270, 1 },
    deluge                        = { 77622, 200076, 2 },
    downpour                      = { 77570, 207778, 1 },
    earth_elemental               = { 77658, 198103, 1 },
    earth_shield                  = { 77700, 974   , 1 },
    earthen_harmony               = { 77648, 382020, 2 },
    earthen_wall_totem            = { 77640, 198838, 1 },
    earthgrab_totem               = { 77676, 51485 , 1 },
    earthliving_weapon            = { 77643, 382021, 1 },
    earthwarden                   = { 77644, 382315, 2 },
    echo_of_the_elements          = { 77638, 333919, 1 },
    elemental_orbit               = { 77699, 383010, 1 },
    elemental_warding             = { 77678, 381650, 2 },
    enfeeblement                  = { 77672, 378079, 1 },
    everrising_tide               = { 77647, 382029, 1 },
    fire_and_ice                  = { 77661, 382886, 1 },
    flash_flood                   = { 77614, 280614, 2 },
    flow_of_the_tides             = { 77625, 382039, 1 },
    flurry                        = { 77653, 382888, 1 },
    focused_insight               = { 77652, 381666, 2 },
    frost_shock                   = { 77668, 196840, 1 },
    go_with_the_flow              = { 77683, 381678, 2 },
    graceful_spirit               = { 77659, 192088, 1 },
    greater_purge                 = { 77670, 378773, 1 },
    guardians_cudgel              = { 77664, 381819, 1 },
    gust_of_wind                  = { 77682, 192063, 1 },
    healing_rain                  = { 77634, 73920 , 1 },
    healing_stream_totem          = { 77694, 5394  , 1 },
    healing_stream_totem_2        = { 77616, 5394  , 1 },
    healing_tide_totem            = { 77626, 108280, 1 },
    healing_wave                  = { 77620, 77472 , 1 },
    hex                           = { 77673, 51514 , 1 },
    high_tide                     = { 77636, 157154, 1 },
    improved_call_of_the_elements = { 77684, 383011, 1 },
    improved_lightning_bolt       = { 77692, 381674, 2 },
    improved_primordial_wave      = { 77629, 382191, 2 },
    improved_purify_spirit        = { 77667, 383016, 1 },
    lava_burst                    = { 77656, 51505 , 1 },
    lava_surge                    = { 77611, 77756 , 1 },
    lightning_lasso               = { 77690, 305483, 1 },
    living_stream                 = { 77642, 382482, 1 },
    maelstrom_weapon              = { 77654, 187880, 1 },
    mana_spring_totem             = { 77697, 381930, 1 },
    mana_tide_totem               = { 77639, 16191 , 1 },
    master_of_the_elements        = { 77613, 16166 , 1 },
    natures_focus                 = { 77635, 382019, 1 },
    natures_fury                  = { 77680, 381655, 2 },
    natures_guardian              = { 77675, 30884 , 2 },
    natures_swiftness             = { 77693, 378081, 1 },
    overflowing_shores            = { 77633, 383222, 1 },
    planes_traveler               = { 77650, 381647, 1 },
    poison_cleansing_totem        = { 77687, 383013, 1 },
    primal_tide_core              = { 77636, 382045, 1 },
    primordial_wave               = { 77630, 375982, 1 },
    purge                         = { 77670, 370   , 1 },
    refreshing_waters             = { 77613, 378211, 1 },
    resurgence                    = { 77618, 16196 , 1 },
    riptide                       = { 77621, 61295 , 1 },
    spirit_link_totem             = { 77627, 98008 , 1 },
    spirit_walk                   = { 77682, 58875 , 1 },
    spirit_wolf                   = { 77666, 260878, 1 },
    spiritwalkers_aegis           = { 77659, 378077, 1 },
    spiritwalkers_grace           = { 77660, 79206 , 1 },
    static_charge                 = { 77664, 265046, 1 },
    stoneskin_totem               = { 77689, 383017, 1 },
    stormkeeper                   = { 77623, 383009, 1 },
    surging_shields               = { 77686, 382033, 2 },
    swirling_currents             = { 77695, 378094, 2 },
    thunderous_paws               = { 77666, 378075, 1 },
    thundershock                  = { 77690, 378779, 1 },
    thunderstorm                  = { 77691, 51490 , 1 },
    tidal_waves                   = { 77615, 51564 , 1 },
    torrent                       = { 77641, 200072, 2 },
    totemic_focus                 = { 77688, 382201, 2 },
    totemic_projection            = { 77674, 108287, 1 },
    totemic_surge                 = { 77698, 381867, 2 },
    tranquil_air_totem            = { 77689, 383019, 1 },
    tremor_totem                  = { 77663, 8143  , 1 },
    tumbling_waves                = { 77628, 382040, 1 },
    undercurrent                  = { 77646, 382194, 2 },
    undulation                    = { 77631, 200071, 1 },
    unleash_life                  = { 77631, 73685 , 1 },
    voodoo_mastery                = { 77672, 204268, 1 },
    water_shield                  = { 77619, 52127 , 1 },
    water_totem_mastery           = { 77612, 382030, 1 },
    wavespeakers_blessing         = { 77632, 381946, 1 },
    wellspring                    = { 77645, 197995, 1 },
    wind_rush_totem               = { 77676, 192077, 1 },
    wind_shear                    = { 77662, 57994 , 1 },
    winds_of_alakir               = { 77681, 382215, 2 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    ancestral_gift      = 3756, -- 290254
    cleansing_waters    = 3755, -- 290250
    counterstrike_totem = 708 , -- 204331
    electrocute         = 714 , -- 206642
    grounding_totem     = 715 , -- 204336
    living_tide         = 5388, -- 353115
    precognition        = 5458, -- 377360
    skyfury_totem       = 707 , -- 204330
    spectral_recovery   = 3520, -- 204261
    swelling_waves      = 712 , -- 204264
    tidebringer         = 1930, -- 236501
    traveling_storms    = 5528, -- 204403
    unleash_shield      = 5437, -- 356736
} )


-- Auras
spec:RegisterAuras( {
    ancestral_guidance = {
        id = 108281,
        duration = 10,
        tick_time = 0.5,
        max_stack = 1
    },
    ancestral_protection_totem = { -- TODO: Make duration work from totem placement.
        id = 255234,
        duration = 30,
        max_stack = 1
    },
    ancestral_vigor = {
        id = 207400,
        duration = 10,
        max_stack = 1
    },
    ascendance = {
        id = 114052,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    astral_shift = {
        id = 108271,
        duration = 8,
        max_stack = 1
    },
    bloodlust = {
        id = 2825,
        duration = 40,
        max_stack = 1
    },
    cloudburst_totem = { -- TODO: This matches totem duration.
        id = 157153,
        duration = 15,
        max_stack = 1
    },
    cloudburst_totem_healing = {
        id = 157504,
        duration = 15,
        max_stack = 1
    },
    counterstrike_totem = { -- TODO: This is the debuff applied to enemies.
        id = 208997,
        duration = 15,
        max_stack = 1
    },
    earth_shield = {
        id = 974,
        duration = 600,
        max_stack = 1
    },
    earthbind = { -- TODO: Check ID.
        id = 3600, -- 116947?
        duration = 5,
        max_stack = 1
    },
    earthen_wall = { -- TODO: Protective aura.
        id = 198839,
        duration = 15,
        max_stack = 1
    },
    earthgrab = {
        id = 64695,
        duration = 8,
        max_stack = 1
    },
    earthliving_weapon = { -- TODO: Confirm buff on player (vs. actual weapon imbue).  Need HoT buff.
        id = 382022,
        duration = 3600,
        max_stack = 1
    },
    everrising_tide = {
        id = 382029,
        duration = 8,
        max_stack = 1
    },
    far_sight = {
        id = 6196,
        duration = 60,
        max_stack = 1
    },
    flame_shock = {
        id = 188389,
        duration = 18,
        tick_time = 2,
        max_stack = 1
    },
    flurry = {
        id = 382889,
        duration = 15,
        max_stack = 1
    },
    focused_insight = {
        id = 381668,
        duration = 12,
        max_stack = 1
    },
    frost_shock = {
        id = 196840,
        duration = 6,
        max_stack = 1
    },
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        max_stack = 1
    },
    grounding_totem = { -- TODO: This is totem direction; check for aura ID.
        id = 204336,
        duration = 3,
        max_stack = 1
    },
    healing_rain = {
        id = 73920,
        duration = 10,
        tick_time = 2,
        max_stack = 1
    },
    hex = {
        id = 51514,
        duration = 60,
        max_stack = 1
    },
    lightning_shield = {
        id = 192106,
        duration = 1800,
        max_stack = 1
    },
    master_of_the_elements = {
        id = 260734,
        duration = 15,
        max_stack = 1
    },
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        max_stack = 1
    },
    riptide = {
        id = 61295,
        duration = 18,
        tick_time = 3,
        max_stack = 1
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1
    },
    skyfury_totem = {
        id = 208963,
        duration = 15,
        max_stack = 1,
    },
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1,
    },
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        max_stack = 1
    },
    static_charge = {
        id = 118905,
        duration = 3,
        max_stack = 1
    },
    stoneskin = {
        id = 383018,
        duration = 15,
        max_stack = 1,
        shared = "player",
    },
    stormkeeper = {
        id = 383009,
        duration = 15,
        max_stack = 1
    },
    swirling_currents = {
        id = 378102,
        duration = 15,
        max_stack = 1
    },
    thunderous_paws = {
        id = 378076,
        duration = 3,
        max_stack = 1
    },
    thunderstorm = {
        id = 51490,
        duration = 5,
        max_stack = 1
    },
    unleash_life = {
        id = 73685,
        duration = 10,
        max_stack = 1
    },
    earth_unleashed = {
        id = 356738,
        duration = 4,
        max_stack = 1
    },
    storm_unleahed = {
        id = 123599,
        duration = 4,
        max_stack = 1
    },
    water_unleashed = {
        id = 356824,
        duration = 6,
        max_stack = 1
    },
    water_shield = {
        id = 52127,
        duration = 3600,
        max_stack = 1
    },
    water_walking = {
        id = 546,
        duration = 600,
        max_stack = 1
    },
    wind_rush = {
        id = 192082,
        duration = 5,
        max_stack = 1
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
        cast = 10,
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
        cast = 10,
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
        cast = 10,
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
        cast = 2.5,
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
        cast = 2,
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
        charges = function () return talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank end,
        cooldown = 45,
        recharge = 45,
        gcd = "totem",

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
        cast = 1.5,
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
        cast = 2,
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
        cast = 2,
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
        cast = 2,
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
        charges = function () return talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank end,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = function ()
            if talent.healing_stream_totem.enabled then return "healing_stream_totem" end
            if talent.healing_stream_totem_2.enabled then return "healing_stream_totem_2" end
            return "healing_stream_totem"
        end,
        notalent = "cloudburst_totem",
        startsCombat = true,
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
        cast = 2.5,
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
        cast = 1.7,
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
        cast = 2,
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
        cast = 2,
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
        cast = 1.5,
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
        cast = 1.5,
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