if UnitClassBase( 'player' ) ~= 'HUNTER' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 3 )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    aimed_shot                    = {  1345, 1, 19434 },
    animal_handler                = {  1799, 2, 34453, 34454 },
    aspect_mastery                = {  2138, 1, 53265 },
    barrage                       = {  1347, 3, 19461, 19462, 24691 },
    beast_mastery                 = {  2139, 1, 53270 },
    bestial_discipline            = {  1390, 2, 19590, 19592 },
    bestial_wrath                 = {  1386, 1, 19574 },
    black_arrow                   = {  1322, 1,  3674 },
    careful_aim                   = {  1806, 3, 34482, 34483, 34484 },
    catlike_reflexes              = {  1801, 3, 34462, 34464, 34465 },
    chimera_shot                  = {  2135, 1, 53209 },
    cobra_strikes                 = {  2137, 3, 53256, 53259, 53260 },
    combat_experience             = {  1804, 2, 34475, 34476 },
    concussive_barrage            = {  1351, 2, 35100, 35102 },
    counterattack                 = {  1312, 1, 19306 },
    deflection                    = {  1311, 3, 19295, 19297, 19298 },
    efficiency                    = {  1342, 5, 19416, 19417, 19418, 19419, 19420 },
    endurance_training            = {  1389, 5, 19583, 19584, 19585, 19586, 19587 },
    entrapment                    = {  1304, 3, 19184, 19387, 19388 },
    explosive_shot                = {  2145, 1, 53301 },
    expose_weakness               = {  1812, 3, 34500, 34502, 34503 },
    ferocious_inspiration         = {  1800, 3, 34455, 34459, 34460 },
    ferocity                      = {  1393, 5, 19598, 19599, 19600, 19601, 19602 },
    focused_aim                   = {  2197, 3, 53620, 53621, 53622 },
    focused_fire                  = {  1624, 2, 35029, 35030 },
    frenzy                        = {  1397, 5, 19621, 19622, 19623, 19624, 19625 },
    go_for_the_throat             = {  1818, 2, 34950, 34954 },
    hawk_eye                      = {  1820, 3, 19498, 19499, 19500 },
    hunter_vs_wild                = {  2228, 3, 56339, 56340, 56341 },
    hunting_party                 = {  2144, 3, 53290, 53291, 53292 },
    improved_arcane_shot          = {  1346, 3, 19454, 19455, 19456 },
    improved_aspect_of_the_hawk   = {  1382, 5, 19552, 19553, 19554, 19555, 19556 },
    improved_aspect_of_the_monkey = {  1381, 3, 19549, 19550, 19551 },
    improved_barrage              = {  1821, 3, 35104, 35110, 35111 },
    improved_concussive_shot      = {  1341, 2, 19407, 19412 },
    improved_hunters_mark         = {  1343, 3, 19421, 19422, 19423 },
    improved_mend_pet             = {  1385, 2, 19572, 19573 },
    improved_revive_pet           = {  1625, 2, 24443, 19575 },
    improved_steady_shot          = {  2133, 3, 53221, 53222, 53224 },
    improved_stings               = {  1348, 3, 19464, 19465, 19466 },
    improved_tracking             = {  1623, 5, 52783, 52785, 52786, 52787, 52788 },
    intimidation                  = {  1387, 1, 19577 },
    invigoration                  = {  2136, 2, 53252, 53253 },
    killer_instinct               = {  1321, 3, 19370, 19371, 19373 },
    kindred_spirits               = {  2227, 5, 56314, 56315, 56316, 56317, 56318 },
    lethal_shots                  = {  1344, 5, 19426, 19427, 19429, 19430, 19431 },
    lightning_reflexes            = {  1303, 5, 19168, 19180, 19181, 24296, 24297 },
    lock_and_load                 = {  1306, 3, 56342, 56343, 56344 },
    longevity                     = {  2140, 3, 53262, 53263, 53264 },
    marked_for_death              = {  2134, 5, 53241, 53243, 53244, 53245, 53246 },
    master_marksman               = {  1807, 5, 34485, 34486, 34487, 34488, 34489 },
    master_tactician              = {  1813, 5, 34506, 34507, 34508, 34838, 34839 },
    mortal_shots                  = {  1349, 5, 19485, 19487, 19488, 19489, 19490 },
    noxious_stings                = {  2141, 3, 53295, 53296, 53297 },
    pathfinding                   = {  1384, 2, 19559, 19560 },
    piercing_shots                = {  2130, 3, 53234, 53237, 53238 },
    point_of_no_escape            = {  2142, 2, 53298, 53299 },
    ranged_weapon_specialization  = {  1362, 3, 19507, 19508, 19509 },
    rapid_killing                 = {  1819, 2, 34948, 34949 },
    rapid_recuperation            = {  2131, 2, 53228, 53232 },
    readiness                     = {  1353, 1, 23989 },
    resourcefulness               = {  1809, 3, 34491, 34492, 34493 },
    savage_strikes                = {  1621, 2, 19159, 19160 },
    scatter_shot                  = {  1814, 1, 19503 },
    serpents_swiftness            = {  1802, 5, 34466, 34467, 34468, 34469, 34470 },
    silencing_shot                = {  1808, 1, 34490 },
    sniper_training               = {  2143, 3, 53302, 53303, 53304 },
    spirit_bond                   = {  1388, 2, 19578, 20895 },
    surefooted                    = {  1310, 3, 19290, 19294, 24283 },
    survival_instincts            = {  1810, 2, 34494, 34496 },
    survival_tactics              = {  1309, 2, 19286, 19287 },
    survivalist                   = {  1622, 5, 19255, 19256, 19257, 19258, 19259 },
    the_beast_within              = {  1803, 1, 34692 },
    thick_hide                    = {  1395, 3, 19609, 19610, 19612 },
    thrill_of_the_hunt            = {  1811, 3, 34497, 34498, 34499 },
    tnt                           = {  2229, 3, 56333, 56336, 56337 },
    trap_mastery                  = {  1305, 3, 19376, 63457, 63458 },
    trueshot_aura                 = {  1361, 1, 19506 },
    unleashed_fury                = {  1396, 5, 19616, 19617, 19618, 19619, 19620 },
    wild_quiver                   = {  2132, 3, 53215, 53216, 53217 },
    wyvern_sting                  = {  1325, 1, 19386 },
} )


-- Auras
spec:RegisterAuras( {
    -- Healing effects reduced by $s2%.
    aimed_shot = {
        id = 19434,
        duration = 10,
        max_stack = 1,
        copy = { 19434, 20900, 20901, 20902, 20903, 20904, 27065, 49049, 49050, 65883 },
    },
    -- Untrackable and melee attack power for the pet and hunter increased by 10%.
    aspect_of_the_beast = {
        id = 13161,
        duration = 3600,
        max_stack = 1,
    },
    -- $s1% increased movement speed.  Dazed if struck.
    aspect_of_the_cheetah = {
        id = 5118,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases ranged attack power by $s1.  Increases dodge chance by $61848s1%.
    aspect_of_the_dragonhawk = {
        id = 61846,
        duration = 3600,
        max_stack = 1,
        copy = { 61846, 61847 },
    },
    -- Increases ranged attack power by $s1.
    aspect_of_the_hawk = {
        id = 13165,
        duration = 3600,
        max_stack = 1,
        copy = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, 27044 },
    },
    -- Increases chance to dodge by $s1%.
    aspect_of_the_monkey = {
        id = 13163,
        duration = 3600,
        max_stack = 1,
    },
    -- $s1% increased movement speed.  Dazed if struck.
    aspect_of_the_pack = {
        id = 13159,
        duration = 3600,
        max_stack = 1,
    },
    -- Your ranged and melee attacks regenerate a percentage of your base mana, but your total damage done is reduced by $s2%.  In addition, you gain $s1% of maximum mana every $t sec.
    aspect_of_the_viper = {
        id = 34074,
        duration = 3600,
        tick_time = 3,
        max_stack = 1,
    },
    -- Nature resistance increased by $s1.
    aspect_of_the_wild = {
        id = 20043,
        duration = 3600,
        max_stack = 1,
        copy = { 20043, 20190, 27045, 49071 },
    },
    -- Lore revealed.
    beast_lore = {
        id = 1462,
        duration = 30,
        max_stack = 1,
    },
    bestial_discipline = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=19592)
        id = 19592,
        duration = 3600,
        max_stack = 1,
        copy = { 19592, 19590 },
    },
    -- Enraged.
    bestial_wrath = {
        id = 19574,
        duration = 10,
        max_stack = 1,
    },
    -- All damage taken increased by $s2%, and $s1 Shadow damage every $t1 seconds.
    black_arrow = {
        id = 3674,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 3674, 63668, 63669, 63670, 63671, 63672 },
    },
    call_pet = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=883)
        id = 883,
        duration = 3600,
        max_stack = 1,
    },
    -- Choose one of your stabled pets to replace your current pet.
    call_stabled_pet = {
        id = 62757,
        duration = 120,
        max_stack = 1,
    },
    -- Pet critical strike chance with abilities increased 100%.
    cobra_strikes = {
        id = 53257,
        duration = 10,
        max_stack = 2,
    },
    -- Dazed.
    concussive_barrage = {
        id = 35101,
        duration = 4,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    concussive_shot = {
        id = 5116,
        duration = 4,
        max_stack = 1,
    },
    -- Immobile.
    counterattack = {
        id = 19306,
        duration = 5,
        max_stack = 1,
        copy = { 19306, 20909, 20910, 27067, 48998, 48999 },
    },
    -- Dazed.
    dazed = {
        id = 15571,
        duration = 4,
        max_stack = 1,
    },
    -- Parry chance increased by $s1%, chance for ranged attacks to miss you increased by $s2%, $s2% chance to deflect spells, and unable to attack.
    deterrence = {
        id = 19263,
        duration = 5,
        max_stack = 1,
    },
    -- Distracted.
    distracting_shot = {
        id = 20736,
        duration = 6,
        max_stack = 1,
        copy = { 20736 },
    },
    -- Vision is enhanced.
    eagle_eye = {
        id = 6197,
        duration = 60,
        max_stack = 1,
    },
    -- Immobile.
    entrapment = {
        id = 64804,
        duration = 4,
        max_stack = 1,
        copy = { 64804, 64803, 19185 },
    },
    -- Taking Fire damage every second.
    explosive_shot = {
        id = 53301,
        duration = 2,
        tick_time = 1,
        max_stack = 1,
        copy = { 53301, 60051, 60052, 60053 },
    },
    explosive_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=13813)
        id = 13813,
        duration = 30,
        max_stack = 1,
    },
    -- $s1% of your Agility as bonus attack power.
    expose_weakness = {
        id = 34501,
        duration = 7,
        max_stack = 1,
    },
    -- Directly controlling pet.
    eyes_of_the_beast = {
        id = 1002,
        duration = 60,
        max_stack = 1,
    },
    -- Increases happiness.
    feed_pet = {
        id = 1539,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Feigning death.
    feign_death = {
        id = 5384,
        duration = 360,
        max_stack = 1,
    },
    ferocity = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=19602)
        id = 19602,
        duration = 3600,
        max_stack = 1,
        copy = { 19602, 19601, 19600, 19599, 19598 },
    },
    -- Hidden and invisible units are revealed.
    flare = {
        id = 1543,
        duration = 20,
        max_stack = 1,
    },
    freezing_arrow = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=60202)
        id = 60202,
        duration = 30,
        max_stack = 1,
    },
    freezing_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=1499)
        id = 1499,
        duration = 30,
        max_stack = 1,
    },
    frenzy = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=19625)
        id = 19625,
        duration = 3600,
        max_stack = 1,
        copy = { 19625, 19624, 19623, 19622, 19621 },
    },
    frost_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=13809)
        id = 13809,
        duration = 30,
        max_stack = 1,
    },
    -- All attackers gain $s2 ranged attack power against this target.
    hunters_mark = {
        id = 1130,
        duration = 300,
        max_stack = 1,
        copy = { 1130, 14323, 14324, 14325, 53338 },
    },
    immolation_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=13795)
        id = 13795,
        duration = 30,
        max_stack = 1,
    },
    improved_revive_pet = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=24443)
        id = 24443,
        duration = 3600,
        max_stack = 1,
        copy = { 24443, 19575 },
    },
    -- Damage done by your Aimed Shot, Arcane Shot or Chimera Shot increased by $s1%, and mana cost reduced by $s2%.
    improved_steady_shot = {
        id = 53220,
        duration = 12,
        max_stack = 1,
    },
    -- Stunned.
    intimidation = {
        id = 24394,
        duration = 3,
        max_stack = 1,
        copy = { 24394, 19577 },
    },
    kill_command = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=34026)
        id = 34026,
        duration = 30,
        max_stack = 1,
    },
    killer_instinct = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=19373)
        id = 19373,
        duration = 3600,
        max_stack = 1,
        copy = { 19373, 19371, 19370 },
    },
    lethal_shots = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=19431)
        id = 19431,
        duration = 3600,
        max_stack = 1,
        copy = { 19431, 19430, 19429, 19427, 19426 },
    },
    lightning_reflexes = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=24297)
        id = 24297,
        duration = 3600,
        max_stack = 1,
        copy = { 24297, 24296, 19181, 19180, 19168 },
    },
    -- Your next Arcane Shot or Explosive Shot spells trigger no cooldown, cost no mana and consume no ammo.
    lock_and_load = {
        id = 56453,
        duration = 12,
        max_stack = 1,
    },
    -- Critical strike chance with all attacks increased by $s1%.
    master_tactician = {
        id = 34837,
        duration = 8,
        max_stack = 1,
        copy = { 34833, 34834, 34835, 34836, 34837 },
    },
    -- Heals $s1 every $t1 sec.
    mend_pet = {
        id = 136,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 136, 3111, 3661, 3662, 13542, 13543, 13544, 27046, 48989, 48990 },
    },
    -- Redirecting threat.
    misdirection = {
        id = 34477,
        duration = 30,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    monkey_speed = {
        id = 60798,
        duration = 6,
        max_stack = 1,
    },
    -- Ranged attack speed increased.
    quick_shots = {
        id = 6150,
        duration = 12,
        max_stack = 1,
    },
    -- Increases ranged attack speed by $s1%.
    rapid_fire = {
        id = 3045,
        duration = 15,
        max_stack = 1,
    },
    -- Damage of your next Aimed Shot, Arcane Shot or Chimera Shot increased by $s1%.
    rapid_killing = {
        id = 35099,
        duration = 20,
        max_stack = 1,
        copy = { 35098, 35099 },
    },
    -- Restoring $58883s1% mana every 3 sec.
    rapid_recuperation_effect = {
        id = 54227,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 54227, 53230 },
    },
    revive_pet = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=982)
        id = 982,
        duration = 3,
        max_stack = 1,
    },
    -- Feared.
    scare_beast = {
        id = 1513,
        duration = 10,
        max_stack = 1,
        copy = { 1513, 14326, 14327 },
    },
    -- Disoriented.
    scatter_shot = {
        id = 19503,
        duration = 4,
        max_stack = 1,
    },
    -- Chance to hit with melee and ranged attacks reduced by $s1%.
    scorpid_sting = {
        id = 3043,
        duration = 20,
        max_stack = 1,
    },
    -- Causes $s1 Nature damage every $t1 seconds.
    serpent_sting = {
        id = 1978,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 27016, 49000, 49001 },
    },
    -- Silenced.
    silencing_shot = {
        id = 34490,
        duration = 3,
        max_stack = 1,
    },
    snake_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=34600)
        id = 34600,
        duration = 30,
        max_stack = 1,
    },
    -- Taming pet.
    tame_beast = {
        id = 1515,
        duration = 20,
        max_stack = 1,
    },
    thick_hide = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=19612)
        id = 19612,
        duration = 3600,
        max_stack = 1,
        copy = { 19612, 19610, 19609 },
    },
    -- Tracking Beasts.
    track_beasts = {
        id = 1494,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Demons.
    track_demons = {
        id = 19878,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Dragonkin.
    track_dragonkin = {
        id = 19879,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Elementals.
    track_elementals = {
        id = 19880,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Giants.
    track_giants = {
        id = 19882,
        duration = 3600,
        max_stack = 1,
    },
    -- Greatly increases stealth detection.
    track_hidden = {
        id = 19885,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Humanoids.
    track_humanoids = {
        id = 19883,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Undead.
    track_undead = {
        id = 19884,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases attack power by $s1%.
    trueshot_aura = {
        id = 19506,
        duration = 3600,
        max_stack = 1,
    },
    -- Drains $m1% mana every $t1 seconds, restoring 300% of the amount drained to the Hunter.
    viper_sting = {
        id = 3034,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
    },
    volley = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=1510)
        id = 1510,
        duration = 6,
        max_stack = 1,
    },
    -- Asleep.
    wyvern_sting = {
        id = 19386,
        duration = 30,
        max_stack = 1,
        copy = { 19386, 24131, 24132, 24133, 24134, 24135, 26748, 27068, 27069, 49009, 49010, 49011, 49012, 65878 },
    },
} )


-- Abilities
spec:RegisterAbilities( {
    -- An aimed shot that increases ranged damage by 5 and reduces healing done to that target by 50%.  Lasts 10 sec.
    aimed_shot = {
        id = 19434,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "aimed_shot",
        startsCombat = true,
        texture = 135130,

        handler = function ()
        end,
    },


    -- An instant shot that causes 65 Arcane damage.
    arcane_shot = {
        id = 3044,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 132218,

        handler = function ()
        end,

        copy = { 14281, 14282, 14283, 14284, 14285, 14286, 14287, 27019, 49044, 49045 },
    },


    -- The hunter takes on the aspects of a beast, becoming untrackable and increasing melee attack power of the hunter and the hunter's pet by 10%.  Only one Aspect can be active at a time.
    aspect_of_the_beast = {
        id = 13161,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 132252,

        handler = function ()
        end,
    },


    -- The hunter takes on the aspects of a cheetah, increasing movement speed by 30%.  If the hunter is struck, she will be dazed for 4 sec.  Only one Aspect can be active at a time.
    aspect_of_the_cheetah = {
        id = 5118,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 132242,

        handler = function ()
        end,
    },


    -- The hunter takes on the aspects of a dragonhawk, increasing ranged attack power by 230 and chance to dodge by 18%.  Only one Aspect can be active at a time.
    aspect_of_the_dragonhawk = {
        id = 61846,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 132188,

        handler = function ()
        end,

        copy = { 61847 },
    },


    -- The hunter takes on the aspects of a hawk, increasing ranged attack power by 20.  Only one Aspect can be active at a time.
    aspect_of_the_hawk = {
        id = 13165,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 136076,

        handler = function ()
        end,

        copy = { 14318, 14319, 14320, 14321, 14322, 25296, 27044 },
    },


    -- The hunter takes on the aspects of a monkey, increasing chance to dodge by 18%.  Only one Aspect can be active at a time.
    aspect_of_the_monkey = {
        id = 13163,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 132159,

        handler = function ()
        end,
    },


    -- The hunter and raid members within 40 yards take on the aspects of a pack of cheetahs, increasing movement speed by 30%.  If you are struck under the effect of this aspect, you will be dazed for 4 sec.  Only one Aspect can be active at a time.
    aspect_of_the_pack = {
        id = 13159,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 132267,

        handler = function ()
        end,
    },


    -- The hunter takes on the aspect of the viper, causing ranged and melee attacks to regenerate mana but reducing your total damage done by 50%.  In addition, you gain 4% of maximum mana every 3 sec.  Mana gained is based on the speed of your ranged weapon. Requires a ranged weapon. Only one Aspect can be active at a time.
    aspect_of_the_viper = {
        id = 34074,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 132160,

        handler = function ()
        end,
    },


    -- The hunter, group and raid members within 30 yards take on the aspect of the wild, increasing Nature resistance by 45.  Only one Aspect can be active at a time.
    aspect_of_the_wild = {
        id = 20043,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = true,
        texture = 136074,

        handler = function ()
        end,

        copy = { 20190, 27045, 49071 },
    },


    -- Gather information about the target beast.  The tooltip will display damage, health, armor, any special resistances, and diet.  In addition, Beast Lore will reveal whether or not the creature is tameable and what abilities the tamed creature has.
    beast_lore = {
        id = 1462,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 132270,

        handler = function ()
        end,
    },


    -- Send your pet into a rage causing 50% additional damage for 10 sec.  While enraged, the beast does not feel pity or remorse or fear and it cannot be stopped unless killed.
    bestial_wrath = {
        id = 19574,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.1,
        spendType = "mana",

        talent = "bestial_wrath",
        startsCombat = true,
        texture = 132127,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Fires a Black Arrow at the target, increasing all damage done by you to the target by 6% and dealing 818 Shadow damage over 15 sec. Black Arrow shares a cooldown with Trap spells.
    black_arrow = {
        id = 3674,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "black_arrow",
        startsCombat = true,
        texture = 136181,

        handler = function ()
        end,
    },


    -- Summons your pet to you.
    call_pet = {
        id = 883,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132161,

        handler = function ()
        end,
    },


    -- Choose one of your stabled pets to replace your current pet.  The selected pet busts out of its stable to join you no matter where you are.  Cannot be used in combat.
    call_stabled_pet = {
        id = 62757,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        startsCombat = true,
        texture = 132599,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- You deal 125% weapon damage, refreshing the current Sting on your target and triggering an effect:    Serpent Sting - Instantly deals 40% of the damage done by your Serpent Sting.    Viper Sting - Instantly restores mana to you equal to 60% of the total amount drained by your Viper Sting.    Scorpid Sting - Attempts to Disarm the target for 10 sec. This effect cannot occur more than once per 1 minute.
    chimera_shot = {
        id = 53209,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "chimera_shot",
        startsCombat = true,
        texture = 236176,

        handler = function ()
        end,
    },


    -- Dazes the target, slowing movement speed by 50% for 4 sec.
    concussive_shot = {
        id = 5116,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135860,

        handler = function ()
        end,
    },


    -- A strike that becomes active after parrying an opponent's attack.  This attack deals 127 damage and immobilizes the target for 5 sec.  Counterattack cannot be blocked, dodged, or parried.
    counterattack = {
        id = 19306,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "counterattack",
        startsCombat = true,
        texture = 132336,

        handler = function ()
        end,
    },


    -- When activated, increases parry chance by 100%, reduces the chance ranged attacks will hit you by 100% and grants a 100% chance to deflect spells.  While Deterrence is active, you cannot attack.  Lasts 5 sec.
    deterrence = {
        id = 19263,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        startsCombat = true,
        texture = 132369,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- You attempt to disengage from combat, leaping backwards. Can only be used while in combat.
    disengage = {
        id = 781,
        cast = 0,
        cooldown = 25,
        gcd = "off",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 132294,

        handler = function ()
        end,
    },


    -- Dismiss your pet.  Dismissing your pet will reduce its happiness by 50.
    dismiss_pet = {
        id = 2641,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 136095,

        handler = function ()
        end,
    },


    -- Distracts the target to attack you, but has no effect if the target is already attacking you. Lasts 6 sec.
    distracting_shot = {
        id = 20736,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 135736,

        handler = function ()
        end,
    },


    -- Zooms in the hunter's vision.  Only usable outdoors.  Lasts 1 min.
    eagle_eye = {
        id = 6197,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 132172,

        handler = function ()
        end,
    },


    -- You fire an explosive charge into the enemy target, dealing 191-219 Fire damage. The charge will blast the target every second for an additional 2 sec.
    explosive_shot = {
        id = 53301,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        talent = "explosive_shot",
        startsCombat = true,
        texture = 236178,

        handler = function ()
        end,
    },


    -- Place a fire trap that explodes when an enemy approaches, causing 138 to 168 Fire damage and burning all enemies for 483 additional Fire damage over 20 sec to all within 10 yards.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    explosive_trap = {
        id = 13813,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.19,
        spendType = "mana",

        startsCombat = true,
        texture = 135826,

        handler = function ()
        end,

        copy = { 14316, 14317, 27025, 49066, 49067 },
    },


    -- Take direct control of your pet and see through its eyes for 1 min.
    eyes_of_the_beast = {
        id = 1002,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 132150,

        handler = function ()
        end,
    },


    -- Feed your pet the selected item.  Feeding your pet increases happiness.  Using food close to the pet's level will have a better result.
    feed_pet = {
        id = 6991,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        startsCombat = true,
        texture = 132165,

        handler = function ()
        end,
    },


    -- Feign death which may trick enemies into ignoring you.  Lasts up to 6 min.
    feign_death = {
        id = 5384,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 132293,

        handler = function ()
        end,
    },


    -- Exposes all hidden and invisible enemies within 10 yards of the targeted area for 20 sec.
    flare = {
        id = 1543,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135815,

        handler = function ()
        end,
    },


    -- Fire a freezing arrow that places a Freezing Trap at the target location, freezing the first enemy that approaches, preventing all action for up to 20 sec.  Any damage caused will break the ice.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    freezing_arrow = {
        id = 60192,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135837,

        handler = function ()
        end,
    },


    -- Place a frost trap that freezes the first enemy that approaches, preventing all action for up to 10 sec.  Any damage caused will break the ice.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    freezing_trap = {
        id = 1499,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135834,

        handler = function ()
        end,

        copy = { 14310, 14311 },
    },


    -- Place a frost trap that creates an ice slick around itself for 30 sec when the first enemy approaches it.  All enemies within 10 yards will be slowed by 50% while in the area of effect.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    frost_trap = {
        id = 13809,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135840,

        handler = function ()
        end,
    },


    -- Places the Hunter's Mark on the target, increasing the ranged attack power of all attackers against that target by 20.  In addition, the target of this ability can always be seen by the hunter whether it stealths or turns invisible.  The target also appears on the mini-map.  Lasts for 5 min.
    hunters_mark = {
        id = 1130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 132212,

        handler = function ()
        end,

        copy = { 14323, 14324, 14325, 53338 },
    },


    -- Place a fire trap that will burn the first enemy to approach for 138 Fire damage over 15 sec.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    immolation_trap = {
        id = 13795,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 135813,

        handler = function ()
        end,

        copy = { 14302, 14303, 14304, 14305, 27023, 49055, 49056 },
    },


    -- Command your pet to intimidate the target, causing a high amount of threat and stunning the target for 3 sec. Lasts 15 sec.
    intimidation = {
        id = 19577,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "intimidation",
        startsCombat = true,
        texture = 132111,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Give the command to kill, increasing your pet's damage done from special attacks by 60% for 30 sec.  Each special attack done by the pet reduces the damage bonus by 20%.
    kill_command = {
        id = 34026,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 132176,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- You attempt to finish the wounded target off, firing a long range attack dealing 200% weapon damage plus 543. Kill Shot can only be used on enemies that have 20% or less health.
    kill_shot = {
        id = 53351,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 236174,

        handler = function ()
        end,

        copy = { 61005, 61006 },
    },


    -- Your pet attempts to remove all root and movement impairing effects from itself and its target, and causes your pet and its target to be immune to all such effects for 4 sec.
    masters_call = {
        id = 53271,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 236189,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Heals your pet for 125 health over 15 sec.
    mend_pet = {
        id = 136,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 132179,

        handler = function ()
        end,

        copy = { 3111, 3661, 3662, 13542, 13543, 13544, 27046, 48989, 48990 },
    },


    -- The current party or raid member targeted will receive the threat caused by your next damaging attack and all actions taken for 4 sec afterwards.
    misdirection = {
        id = 34477,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 132180,

        handler = function ()
        end,
    },


    -- Attack the enemy for 104 damage.
    mongoose_bite = {
        id = 1495,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 132215,

        handler = function ()
        end,

        copy = { 14269, 14270, 14271, 36916, 53339 },
    },


    -- Fires several missiles, hitting 3 targets.
    multishot = {
        id = 2643,
        cast = 0.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 132330,

        handler = function ()
        end,

        copy = { 14288, 14289, 14290, 25294, 27021, 49047, 49048 },
    },


    -- Increases ranged attack speed by 40% for 15 sec.
    rapid_fire = {
        id = 3045,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 132208,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- A strong attack that increases melee damage by 5.
    raptor_strike = {
        id = 2973,
        cast = 0,
        cooldown = 6,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 132223,

        handler = function ()
        end,

        copy = { 14260, 14261, 14262, 14263, 14264, 14265, 14266, 27014, 48995, 48996 },
    },


    -- When activated, this ability immediately finishes the cooldown on your other Hunter abilities except Bestial Wrath.
    readiness = {
        id = 23989,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        talent = "readiness",
        startsCombat = true,
        texture = 132206,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Revive your pet, returning it to life with 15% of its base health.
    revive_pet = {
        id = 982,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        startsCombat = true,
        texture = 132163,

        handler = function ()
        end,
    },


    -- Scares a beast, causing it to run in fear for up to 10 sec.  Damage caused may interrupt the effect.  Only one beast can be feared at a time.
    scare_beast = {
        id = 1513,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 132118,

        handler = function ()
        end,

        copy = { 14326, 14327 },
    },


    -- A short-range shot that deals 50% weapon damage and disorients the target for 4 sec.  Any damage caused will remove the effect.  Turns off your attack when used.
    scatter_shot = {
        id = 19503,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "scatter_shot",
        startsCombat = true,
        texture = 132153,

        handler = function ()
        end,
    },


    -- Stings the target, reducing chance to hit with melee and ranged attacks by 3% for 20 sec.  Only one Sting per Hunter can be active on any one target.
    scorpid_sting = {
        id = 3043,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        startsCombat = true,
        texture = 132169,

        handler = function ()
        end,
    },


    -- Stings the target, causing 87 Nature damage over 15 sec.  Only one Sting per Hunter can be active on any one target.
    serpent_sting = {
        id = 1978,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 132204,

        handler = function ()
        end,

        copy = { 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 27016, 49000, 49001 },
    },


    -- A shot that deals 50% weapon damage and Silences the target for 3 sec.  Non-player victim spellcasting is also interrupted for 3 sec.
    silencing_shot = {
        id = 34490,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = 0.06,
        spendType = "mana",

        talent = "silencing_shot",
        startsCombat = true,
        texture = 132323,

        handler = function ()
        end,
    },


    -- Place a trap that will release several venomous snakes to attack the first enemy to approach.  The snakes will die after 15 sec.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    snake_trap = {
        id = 34600,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 132211,

        handler = function ()
        end,
    },


    -- A steady shot that causes unmodified weapon damage, plus ammo, plus 78.  Causes an additional 175 against Dazed targets.
    steady_shot = {
        id = 56641,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 132213,

        handler = function ()
        end,

        copy = { 34120, 49051, 49052 },
    },


    -- Begins taming a beast to be your companion.  Your armor is reduced by 100% while you focus on taming the beast for 20 sec.  If you lose the beast's attention for any reason, the taming process will fail.  Once tamed, the beast will be very unhappy and disloyal.  Try feeding the pet immediately to make it happy.
    tame_beast = {
        id = 1515,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.48,
        spendType = "mana",

        startsCombat = true,
        texture = 132164,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby beasts on the minimap.  Only one form of tracking can be active at a time.
    track_beasts = {
        id = 1494,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 132328,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby demons on the minimap.  Only one form of tracking can be active at a time.
    track_demons = {
        id = 19878,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 136217,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby dragonkin on the minimap.  Only one form of tracking can be active at a time.
    track_dragonkin = {
        id = 19879,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 134153,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby elementals on the minimap.  Only one form of tracking can be active at a time.
    track_elementals = {
        id = 19880,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 135861,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby giants on the minimap.  Only one form of tracking can be active at a time.
    track_giants = {
        id = 19882,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 132275,

        handler = function ()
        end,
    },


    -- Greatly increases stealth detection and shows hidden units within detection range on the minimap.  Only one form of tracking can be active at a time.
    track_hidden = {
        id = 19885,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 132320,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby humanoids on the minimap.  Only one form of tracking can be active at a time.
    track_humanoids = {
        id = 19883,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 135942,

        handler = function ()
        end,
    },


    -- Shows the location of all nearby undead on the minimap.  Only one form of tracking can be active at a time.
    track_undead = {
        id = 19884,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = true,
        texture = 136142,

        handler = function ()
        end,
    },


    -- Attempts to remove 1 Enrage and 1 Magic effect from an enemy target.
    tranquilizing_shot = {
        id = 19801,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136020,

        handler = function ()
        end,
    },


    -- Increases the attack power of party and raid members within 100 yards by 10%.  Lasts until cancelled.
    trueshot_aura = {
        id = 19506,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "trueshot_aura",
        startsCombat = true,
        texture = 132329,

        handler = function ()
        end,
    },


    -- Stings the target, draining 4% mana over 8 sec (up to a maximum of 8% of the caster's maximum mana), and energizing the Hunter equal to 300% of the amount drained.  Only one Sting per Hunter can be active on any one target.
    viper_sting = {
        id = 3034,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 132157,

        handler = function ()
        end,
    },


    -- Continuously fires a volley of ammo at the target area, causing 80 Arcane damage to enemy targets within 8 yards every 1.00 second for 6 sec.
    volley = {
        id = 1510,
        cast = 6,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = true,
        texture = 132222,

        handler = function ()
        end,

        copy = { 14294, 14295, 27022, 58431, 58434 },
    },


    -- A stinging shot that puts the target to sleep for 30 sec.  Any damage will cancel the effect.  When the target wakes up, the Sting causes 300 Nature damage over 6 sec.  Only one Sting per Hunter can be active on the target at a time.
    wyvern_sting = {
        id = 19386,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "wyvern_sting",
        startsCombat = true,
        texture = 135125,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 2973,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    package = "Arms (IV)",

    package1 = "Arms (IV)",
    package2 = "Fury (IV)",
    package3 = "Protection Warrior (IV)"
} )