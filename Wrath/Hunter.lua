if UnitClassBase( 'player' ) ~= 'HUNTER' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


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
    aspect = {
        alias = { "aspect_of_the_beast", "aspect_of_the_cheetah", "aspect_of_the_dragonhawk", "aspect_of_the_hawk", "aspect_of_the_monkey", "aspect_of_the_pack", "aspect_of_the_viper", "aspect_of_the_wild" },
        aliasMode = "first",
        aliasType = "buff",
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
        id = 61847,
        duration = 3600,
        max_stack = 1,
        copy = { 61846, 61847 },
    },
    -- Increases ranged attack power by $s1.
    aspect_of_the_hawk = {
        id = 27044,
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
        id = 49071,
        duration = 3600,
        max_stack = 1,
        copy = { 20043, 20190, 27045, 49071 },
    },
    auto_shot = {
        id = 75,
        duration = 3600,
        max_stack = 1,
    },
    -- Lore revealed.
    beast_lore = {
        id = 1462,
        duration = 30,
        max_stack = 1,
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
    -- Disarmed.
    chimera_shot_scorpid = {
        id = 53359,
        duration = 10,
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
        duration = function() return 4 + talent.improved_concussive_shot.rank end,
        max_stack = 1,
    },
    -- Immobile.
    counterattack = {
        id = 19306,
        duration = 5,
        max_stack = 1,
        copy = { 19306, 20909, 20910, 27067, 48998, 48999 },
    },
    counterattack_usable = {
        duration = 5,
        max_stack = 1,
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
        duration = function() return 2 * talent.entrapment.rank end,
        max_stack = 1,
        copy = { 64804, 64803, 19185 },
    },
    -- Taking Fire damage every second.
    explosive_shot = {
        id = 60053,
        duration = 2,
        tick_time = 1,
        max_stack = 1,
        copy = { 53301, 60051, 60052, 60053 },
    },
    explosive_trap = {
        id = 49065,
        duration = 20,
        max_stack = 1,
        copy = { 13812, 14314, 14315, 27026, 49064, 49065, "explosive_trap_effect" }
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
    ferocious_inspiration = {
        id = 75447,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        copy = { 75593, 75446, 75447 }
    },
    -- Hidden and invisible units are revealed.
    flare = {
        id = 1543,
        duration = 20,
        max_stack = 1,
    },
    freezing_arrow_effect = {
        id = 60210,
        duration = 20,
        max_stack = 1,
    },
    freezing_trap_effect = {
        id = 14309,
        duration = function() return 20 * ( 1 + 0.1 * talent.trap_mastery.rank ) * ( talent.clever_traps.enabled and 1.3 or 1 ) end,
        max_stack = 1,
        copy = { 3355, 14308, 14309 }
    },
    frenzy_effect = {
        id = 19615,
        duration = 8,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 19615 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    frost_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=13809)
        id = 13809,
        duration = 30,
        max_stack = 1,
    },
    frost_trap_aura = {
        id = 13810,
        duration = function() return 30 * ( 1 + 0.1 * talent.trap_mastery.rank ) end,
        max_stack = 1,
        copy = "frost_trap_effect"
    },
    -- All attackers gain $s2 ranged attack power against this target.
    hunters_mark = {
        id = 53338,
        duration = 300,
        max_stack = 1,
        shared = "target",
        copy = { 1130, 14323, 14324, 14325, 53338 },
    },
    -- glyph.immolation_trap.enabled == duration reduced by 6.
    immolation_trap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=13795)
        id = 49054,
        duration = function() return glyph.immolation_trap.enabled and 24 or 30 end,
        max_stack = 1,
        copy = { 13797, 14298, 14299, 14300, 14301, 27024, 49053, 49054 }
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
    -- TODO: Need to detect on pet?
    kill_command_buff = {
        id = 58914,
        duration = 30,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 58914 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Your next Arcane Shot or Explosive Shot spells trigger no cooldown, cost no mana and consume no ammo.
    lock_and_load = {
        id = 56453,
        duration = 12,
        max_stack = 2,
    },
    -- Critical strike chance with all attacks increased by $s1%.
    master_tactician = {
        id = 34837,
        duration = 8,
        max_stack = 1,
        copy = { 34833, 34834, 34835, 34836, 34837 },
    },
    masters_call = {
        id = 62305,
        duration = function() return 4 + ( 3 * talent.animal_handler.rank ) end,
        max_stack = 1,
        copy = { 54216 }
    },
    -- Heals $s1 every $t1 sec.
    mend_pet = {
        id = 48990,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 136, 3111, 3661, 3662, 13542, 13543, 13544, 27046, 48989, 48990 },
        generate = function( t )
            local name, _, count, _, duration, expires, caster

            for i, spell in ipairs( class.auras.mend_pet.copy ) do
                name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", spell )

                if name then
                    fs.count = 1
                    fs.applied = expires - duration
                    fs.expires = expires
                    fs.caster = "pet"
                    return
                end
            end

            fs.count = 0
            fs.applied = 0
            fs.expires = 0
            fs.caster = "nobody"
        end,
    },
    -- Redirecting threat.
    misdirection = {
        id = 34477,
        duration = 30,
        max_stack = 1,
    },
    mongoose_bite_usable = {
        duration = 5,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    monkey_speed = {
        id = 60798,
        duration = 6,
        max_stack = 1,
    },
    piercing_shots = {
        id = 63468,
        duration = 8,
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
    -- Damage taken reduced by 20%.
    raptor_strike = {
        id = 63087,
        duration = 3,
        max_stack = 1,
    },
    raptor_strike_queued = {
        duration = function () return swings.mainhand_speed end,
        max_stack = 1,
    },
    -- Feared.
    scare_beast = {
        id = 14327,
        duration = 20,
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
    my_scorpid_sting = {
        duration = 20,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 3043, "PLAYER" )

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
    -- Causes $s1 Nature damage every $t1 seconds.
    serpent_sting = {
        id = 49001,
        duration = function() return glyph.serpent_sting.enabled and 21 or 15 end,
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
    sniper_training = {
        id = 64420,
        duration = 15,
        max_stack = 1,
        copy = { 64418, 64419, 64420 }
    },
    spirit_bond = {
        id = 24529,
        duration = 3600,
        max_stack = 1,
        copy = { 19579 }
    },
    stings = {
        alias = { "scorpid_sting", "serpent_sting", "viper_sting", "wyvern_sting" },
        aliasMode = "first",
        aliasType = "debuff",
    },
    -- Taming pet.
    tame_beast = {
        id = 1515,
        duration = 20,
        max_stack = 1,
    },
    the_beast_within = {
        id = 34471,
        duration = 10,
        max_stack = 1,
    },
    track = {
        alias = { "track_beasts", "track_demons", "track_dragonkin", "track_elementals", "track_giants", "track_hidden", "track_humanoids", "track_undead" },
        aliasMode = "first",
        aliasType = "buff",
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
    -- Drains $m1% mana every $t1 seconds, restoring 300% of the amount drained to the Hunter.
    viper_sting = {
        id = 3034,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
    },
    volley = {
        id = 1510,
        duration = 6,
        tick_time = 1,
        max_stack = 1,

        generate = function ( t )
            local applied = action.volley.lastCast

            if applied and now - applied < 6 then
                t.count = 1
                t.expires = applied + 6
                t.applied = applied
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    wing_clip = {
        id = 2974,
        duration = 10,
        max_stack = 1,
        copy = { 2974, 14267, 14268 },
    },
    -- Asleep.
    wyvern_sting = {
        id = 49012,
        duration = 30,
        max_stack = 1,
        copy = { 19386, 24132, 24133, 24135, 26748, 27068, 49011, 49012 },
    },
    wyvern_sting_damage = {
        id = 65878,
        duration = 6,
        max_stack = 1,
        copy = { 24131, 24134, 24135, 26748, 27069, 49090, 49010, 65878 }
    },

    -- Pet auras.
    call_of_the_wild = {
        id = 53434,
        duration = 20,
        max_stack = 1,
        shared = "player",
    },
    demoralizing_screech = {
        id = 55487,
        duration = 10,
        max_stack = 1,
        shared = "target",
        copy = { 24423, 24577, 24578, 24579, 27051, 55487 }
    },
    furious_howl = {
        id = 64495,
        duration = 20,
        max_stack = 1,
        shared = "player",
        copy = { 24604, 64491, 64492, 64493, 64494, 64495 }
    },
    stampede = {
        id = 57393,
        duration = 12,
        max_stack = 1,
        shared = "player",
        copy = { 57386, 57389, 57390, 57391, 57392, 57393 }
    }
} )


-- Glyphs
spec:RegisterGlyphs( {
    [56824] = "aimed_shot",
    [56841] = "arcane_shot",
    [56851] = "aspect_of_the_viper",
    [56830] = "bestial_wrath",
    [63065] = "chimera_shot",
    [56850] = "deterrence",
    [56844] = "disengage",
    [63066] = "explosive_shot",
    [63068] = "explosive_trap",
    [57903] = "feign_death",
    [56845] = "freezing_trap",
    [56847] = "frost_trap",
    [56829] = "hunters_mark",
    [56846] = "immolation_trap",
    [63067] = "kill_shot",
    [57870] = "mend_pet",
    [56833] = "mending",
    [56836] = "multishot",
    [57900] = "possessed_strength",
    [56828] = "rapid_fire",
    [63086] = "raptor_strike",
    [57866] = "revive_pet",
    [57902] = "scare_beast",
    [63069] = "scatter_shot",
    [56832] = "serpent_sting",
    [56849] = "snake_trap",
    [56826] = "steady_shot",
    [56857] = "beast",
    [56856] = "hawk",
    [57904] = "pack",
    [56842] = "trueshot_aura",
    [56838] = "volley",
    [56848] = "wyvern_sting",
} )


local cool_traps = setfenv( function()
    setCooldown( "black_arrow", action.black_arrow.cooldown )
    setCooldown( "explosive_trap", action.explosive_trap.cooldown )
    setCooldown( "freezing_arrow", action.freezing_arrow.cooldown )
    setCooldown( "freezing_trap", action.freezing_trap.cooldown )
    setCooldown( "frost_trap", action.frost_trap.cooldown )
    setCooldown( "immolation_trap", action.immolation_trap.cooldown )
end, state )

local repeating = 0
local last_dodge = 0
local last_parry = 0
local last_crit = 0

spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, missType, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

    -- print( subtype, sourceGUID, sourceName, destGUID, destName, destFlags, "A", spellID, "B", spellName, "C", missType )
    if destGUID == state.GUID and subtype:match( "_MISSED$" ) then
        if missType == "DODGE" then
            last_dodge = GetTime()
        elseif missType == "PARRY" then
            last_parry = GetTime()
        end
    elseif sourceGUID == state.GUID and subtype:match( "_DAMAGE$" ) and critical then
        last_crit = GetTime()
    end
end )

spec:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( event, unit, _, spellID )
    if UnitIsUnit( "player", unit ) and spellID == 75 then
        repeating = GetTime()
    end
end )

spec:RegisterEvent( "START_AUTOREPEAT_SPELL", function()
    repeating = GetTime()
end )

spec:RegisterEvent( "STOP_AUTOREPEAT_SPELL", function()
    repeating = 0
end )

spec:RegisterStateExpr( "time_to_auto", function()
    if buff.auto_shot.down then return 3600 end

    local last = action.auto_shot.lastCast
    local time_since = query_time - last

    local speed = UnitRangedDamage( "player" )
    return max( speed - ( time_since % speed ), moving and 0.5 or nil )
end )

spec:RegisterStateExpr( "auto_shot_cast_remains", function()
    if buff.auto_shot.down then return 0 end
    if time_to_auto > 0.5 then return 0 end
    return time_to_auto
end )


local finish_raptor = setfenv( function()
    spend( class.abilities.raptor_strike.spends[ spells.raptor_strike ], "mana" )
end, state )

spec:RegisterStateFunction( "start_raptor", function()
    applyBuff( "raptor_strike", swings.time_to_next_mainhand )
    state:QueueAuraExpiration( "raptor_strike", finish_raptor, buff.finish_raptor.expires )
end )

spec:RegisterHook( "reset_precast", function()
    if repeating > 0 then applyBuff( "auto_shot" ) end

    if IsUsableSpell( class.abilities.mongoose_bite.id ) and last_dodge > 0 and now - last_dodge < 5 then applyBuff( "mongoose_bite_usable", last_dodge + 5 - now ) end
    if IsUsableSpell( class.abilities.counterattack.id ) and last_parry > 0 and now - last_parry < 5 then applyBuff( "counterattack_usable", last_parry + 5 - now ) end

    if IsCurrentSpell( class.abilities.raptor_strike.id ) then
        start_raptor()
        Hekili:Debug( "Starting Raptor Strike, next swing in %.2f...", buff.maul.remains )
    end
end )


local mod_beast_within = setfenv( function( base )
    return base * ( buff.the_beast_within.up and 0.5 or 1 )
end, state )

local mod_efficiency = setfenv( function( base )
    return base * ( 1 - 0.3 * talent.efficiency.rank )
end, state )

local mod_master_marksman = setfenv( function( base )
    return base * ( 1 - 0.05 * talent.master_marksman.rank )
end, state )

local mod_imp_steady_shot = setfenv( function( base )
    return base * ( buff.improved_steady_shot.up and 0.8 or 1 )
end, state )

local mod_resourcefulness_cost = setfenv( function( base )
    return base * ( 1 - 0.2 * talent.resourcefulness.rank )
end, state )

local mod_resourcefulness_cd = setfenv( function( base )
    return base - 2 * talent.resourcefulness.rank
end, state )


-- Abilities
spec:RegisterAbilities( {
    -- An aimed shot that increases ranged damage by 5 and reduces healing done to that target by 50%.  Lasts 10 sec.
    aimed_shot = {
        id = 49050,
        cast = 0,
        cooldown = function() return glyph.aimed_shot.enabled and 8 or 10 end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_imp_steady_shot( mod_master_marksman( mod_efficiency( 0.08 ) ) ) ) end,
        spendType = "mana",

        talent = "aimed_shot",
        startsCombat = true,
        texture = 135130,

        handler = function ()
            applyDebuff( "target", "aimed_shot" )
            removeBuff( "rapid_killing" )
            removeBuff( "improved_steady_shot" )
        end,

        copy = { 19434, 20900, 20901, 20902, 20903, 20904, 27065, 49049, 49050 }
    },


    -- An instant shot that causes 65 Arcane damage.
    arcane_shot = {
        id = 49045,
        cast = 0,
        cooldown = function() return buff.lock_and_load.up and 0 or 6 end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_imp_steady_shot( mod_efficiency( 0.05 ) ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132218,

        handler = function ()
            if glyph.arcane_shot.enabled and ( debuff.viper_sting.up or debuff.scorpid_sting.up or debuff.serpent_sting.up ) then
                gain( 0.01 * mana.max, "mana" )
            end
            removeBuff( "rapid_killing" )
            removeBuff( "improved_steady_shot" )
            removeStack( "lock_and_load" )
        end,

        copy = { 3044, 14281, 14282, 14283, 14284, 14285, 14286, 14287, 27019, 49044, 49045 },
    },


    -- The hunter takes on the aspects of a beast, becoming untrackable and increasing melee attack power of the hunter and the hunter's pet by 10%.  Only one Aspect can be active at a time.
    aspect_of_the_beast = {
        id = 13161,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 132252,

        nobuff = "aspect_of_the_beast",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_beast" )
        end,
    },


    -- The hunter takes on the aspects of a cheetah, increasing movement speed by 30%.  If the hunter is struck, she will be dazed for 4 sec.  Only one Aspect can be active at a time.
    aspect_of_the_cheetah = {
        id = 5118,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 132242,

        nobuff = "aspect_of_the_cheetah",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_cheetah" )
        end,
    },


    -- The hunter takes on the aspects of a dragonhawk, increasing ranged attack power by 230 and chance to dodge by 18%.  Only one Aspect can be active at a time.
    aspect_of_the_dragonhawk = {
        id = 61847,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 132188,

        nobuff = "aspect_of_the_dragonhawk",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_dragonhawk" )
        end,

        copy = { 61846 },
    },


    -- The hunter takes on the aspects of a hawk, increasing ranged attack power by 20.  Only one Aspect can be active at a time.
    aspect_of_the_hawk = {
        id = 13165,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 136076,

        nobuff = "aspect_of_the_hawk",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_hawk" )
        end,

        copy = { 14318, 14319, 14320, 14321, 14322, 25296, 27044 },
    },


    -- The hunter takes on the aspects of a monkey, increasing chance to dodge by 18%.  Only one Aspect can be active at a time.
    aspect_of_the_monkey = {
        id = 13163,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 132159,

        nobuff = "aspect_of_the_monkey",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_monkey" )
        end,
    },


    -- The hunter and raid members within 40 yards take on the aspects of a pack of cheetahs, increasing movement speed by 30%.  If you are struck under the effect of this aspect, you will be dazed for 4 sec.  Only one Aspect can be active at a time.
    aspect_of_the_pack = {
        id = 13159,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 132267,

        nobuff = "aspect_of_the_pack",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_pack" )
        end,
    },


    -- The hunter takes on the aspect of the viper, causing ranged and melee attacks to regenerate mana but reducing your total damage done by 50%.  In addition, you gain 4% of maximum mana every 3 sec.  Mana gained is based on the speed of your ranged weapon. Requires a ranged weapon. Only one Aspect can be active at a time.
    aspect_of_the_viper = {
        id = 34074,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 132160,

        nobuff = "aspect_of_the_viper",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_viper" )
        end,
    },


    -- The hunter, group and raid members within 30 yards take on the aspect of the wild, increasing Nature resistance by 45.  Only one Aspect can be active at a time.
    aspect_of_the_wild = {
        id = 20043,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 136074,

        nobuff = "aspect_of_the_wild",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_wild" )
        end,

        copy = { 20190, 27045, 49071 },
    },


    auto_shot = {
        id = 75,
        cast = 0,
        cooldown = function() return UnitRangedDamage( "player" ) end,
        gcd = "off",

        startsCombat = false, -- it kinda doesn't.
        -- texture = 132369,

        nobuff = "auto_shot",

        handler = function()
            applyBuff( "auto_shot" )
        end
    },


    -- Gather information about the target beast.  The tooltip will display damage, health, armor, any special resistances, and diet.  In addition, Beast Lore will reveal whether or not the creature is tameable and what abilities the tamed creature has.
    beast_lore = {
        id = 1462,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.02 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132270,

        handler = function ()
            applyDebuff( "target", "beast_lore" )
        end,
    },


    -- Send your pet into a rage causing 50% additional damage for 10 sec.  While enraged, the beast does not feel pity or remorse or fear and it cannot be stopped unless killed.
    bestial_wrath = {
        id = 19574,
        cast = 0,
        cooldown = function() return ( glyph.bestial_wrath.enabled and 100 or 120 ) * ( 1 - 0.1 * talent.longevity.rank ) end,
        gcd = "off",

        spend = function() return mod_beast_within( 0.1 ) end,
        spendType = "mana",

        talent = "bestial_wrath",
        startsCombat = false,
        texture = 132127,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bestial_wrath" )
            if talent.the_beast_within.enabled then applyBuff( "the_beast_within" ) end
        end,
    },


    -- Fires a Black Arrow at the target, increasing all damage done by you to the target by 6% and dealing 818 Shadow damage over 15 sec. Black Arrow shares a cooldown with Trap spells.
    black_arrow = {
        id = 63672,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.06 ) ) end,
        spendType = "mana",

        talent = "black_arrow",
        startsCombat = true,
        texture = 136181,

        handler = function ()
            applyDebuff( "target", "black_arrow" )
            cool_traps()
        end,

        copy = { 3674, 63668, 63669, 63670, 63671, 63672 }
    },


    -- Summons your pet to you.
    call_pet = {
        id = 883,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132161,

        handler = function ()
            summonPet( "pet" )
        end,
    },


    -- Choose one of your stabled pets to replace your current pet.  The selected pet busts out of its stable to join you no matter where you are.  Cannot be used in combat.
    call_stabled_pet = {
        id = 62757,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        startsCombat = false,
        texture = 132599,

        usable = function() return time == 0, "cannot use in combat" end,

        handler = function ()
            summonPet( "pet" )
        end,
    },


    -- You deal 125% weapon damage, refreshing the current Sting on your target and triggering an effect:    Serpent Sting - Instantly deals 40% of the damage done by your Serpent Sting.    Viper Sting - Instantly restores mana to you equal to 60% of the total amount drained by your Viper Sting.    Scorpid Sting - Attempts to Disarm the target for 10 sec. This effect cannot occur more than once per 1 minute.
    chimera_shot = {
        id = 53209,
        cast = 0,
        cooldown = function() return glyph.chimera_shot.enabled and 9 or 10 end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_imp_steady_shot( mod_master_marksman( mod_efficiency( 0.12 ) ) ) ) end,
        spendType = "mana",

        talent = "chimera_shot",
        startsCombat = true,
        texture = 236176,

        handler = function ()
            if dot.serpent_sting.ticking then dot.serpent_sting.expires = query_time + class.auras.serpent_sting.duration
            elseif dot.viper_sting.ticking then
                dot.viper_sting.expires = query_time + class.auras.viper_sting.duration
            elseif dot.scorpid_sting.ticking then
                dot.scorpid_sting.expires = query_time + class.auras.scorpid_sting.duration
                applyDebuff( "target", "chimera_shot_disarmed" )
            elseif dot.wyvern_sting.ticking then
                dot.wyvern_sting.expires = query_time + class.auras.wyvern_sting.duration
            end
            if talent.concussive_barrage.enabled then applyDebuff( "target", "concussive_barrage" ) end
            removeBuff( "rapid_killing" )
            removeBuff( "improved_steady_shot" )
        end,
    },


    -- Dazes the target, slowing movement speed by 50% for 4 sec.
    concussive_shot = {
        id = 5116,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.06 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135860,

        handler = function ()
            applyDebuff( "target", "concussive_shot" )
        end,
    },


    -- A strike that becomes active after parrying an opponent's attack.  This attack deals 127 damage and immobilizes the target for 5 sec.  Counterattack cannot be blocked, dodged, or parried.
    counterattack = {
        id = 19306,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.03 ) ) end,
        spendType = "mana",

        talent = "counterattack",
        startsCombat = true,
        texture = 132336,

        buff = "counterattack_usable",

        usable = function() return target.distance < 10, "requires melee range" end,

        handler = function ()
            removeBufF( "counterattack_usable" )
            applyDebuff( "target", "counterattack" )
        end,
    },


    -- When activated, increases parry chance by 100%, reduces the chance ranged attacks will hit you by 100% and grants a 100% chance to deflect spells.  While Deterrence is active, you cannot attack.  Lasts 5 sec.
    deterrence = {
        id = 19263,
        cast = 0,
        cooldown = function() return glyph.deterrence.enabled and 80 or 90 end,
        gcd = "off",

        startsCombat = false,
        texture = 132369,

        toggle = "defensives",

        handler = function ()
            applyBuff( "deterrence" )
        end,
    },


    -- You attempt to disengage from combat, leaping backwards. Can only be used while in combat.
    disengage = {
        id = 781,
        cast = 0,
        cooldown = function() return ( glyph.disengage.enabled and 20 or 25 ) - ( 2 * talent.survival_tactics.rank ) end,
        gcd = "off",

        spend = function() return mod_beast_within( 0.05 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            setDistance( 20 + target.distance )
        end,
    },


    -- Dismiss your pet.  Dismissing your pet will reduce its happiness by 50.
    dismiss_pet = {
        id = 2641,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136095,

        handler = function ()
            dismissPet()
        end,
    },


    -- Distracts the target to attack you, but has no effect if the target is already attacking you. Lasts 6 sec.
    distracting_shot = {
        id = 20736,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.07 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135736,

        handler = function ()
            applyDebuff( "target", "distracting_shot" )
        end,
    },


    -- Zooms in the hunter's vision.  Only usable outdoors.  Lasts 1 min.
    eagle_eye = {
        id = 6197,
        cast = 60,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.01 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132172,

        handler = function ()
            applyBuff( "eagle_eye" )
        end,
    },


    -- You fire an explosive charge into the enemy target, dealing 191-219 Fire damage. The charge will blast the target every second for an additional 2 sec.
    explosive_shot = {
        id = 60053,
        cast = 0,
        cooldown = function() return buff.lock_and_load.up and 0 or 6 end,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.07 ) * ( buff.lock_and_load.up and 0 or 1 ) end,
        spendType = "mana",

        talent = "explosive_shot",
        startsCombat = true,
        texture = 236178,
        velocity = 40,

        caption = function()
            if debuff.explosive_shot.up and debuff.explosive_shot.id == 60053 and debuff.explosive_shot.remains > gcd.max then return "Rank 3" end
        end,

        handler = function ()
            removeStack( "lock_and_load" )
        end,

        impact = function ()
            applyDebuff( "target", "explosive_shot" )

        end,

        copy = { 53301, 60051, 60052, 60053 },
    },


    -- Place a fire trap that explodes when an enemy approaches, causing 138 to 168 Fire damage and burning all enemies for 483 additional Fire damage over 20 sec to all within 10 yards.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    explosive_trap = {
        id = 49067,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.19 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135826,

        handler = function ()
            cool_traps()
        end,

        copy = { 13813, 14316, 14317, 27025, 49066, 49067 },
    },


    -- Take direct control of your pet and see through its eyes for 1 min.
    eyes_of_the_beast = {
        id = 1002,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.01 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132150,

        handler = function ()
            applyBuff( "eyes_of_the_beast" )
        end,
    },


    -- Feed your pet the selected item.  Feeding your pet increases happiness.  Using food close to the pet's level will have a better result.
    feed_pet = {
        id = 6991,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        startsCombat = false,
        texture = 132165,

        handler = function ()
        end,
    },


    -- Feign death which may trick enemies into ignoring you.  Lasts up to 6 min.
    feign_death = {
        id = 5384,
        cast = 360,
        channeled = true,
        cooldown = function() return glyph.feign_death.enabled and 25 or 30 end,
        gcd = "off",

        spend = function() return mod_beast_within( 0.03 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132293,

        handler = function ()
            applyBuff( "feign_death" )
        end,
    },


    -- Exposes all hidden and invisible enemies within 10 yards of the targeted area for 20 sec.
    flare = {
        id = 1543,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.02 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135815,

        handler = function ()
        end,
    },


    -- Fire a freezing arrow that places a Freezing Trap at the target location, freezing the first enemy that approaches, preventing all action for up to 20 sec.  Any damage caused will break the ice.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    freezing_arrow = {
        id = 60192,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135837,

        handler = function ()
            cool_traps()
        end,
    },


    -- Place a frost trap that freezes the first enemy that approaches, preventing all action for up to 10 sec.  Any damage caused will break the ice.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    freezing_trap = {
        id = 14311,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135834,

        handler = function ()
            cool_traps()
        end,

        copy = { 1499, 14310, 14311 },
    },


    -- Place a frost trap that creates an ice slick around itself for 30 sec when the first enemy approaches it.  All enemies within 10 yards will be slowed by 50% while in the area of effect.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    frost_trap = {
        id = 13809,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.02 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135840,

        handler = function ()
            cool_traps()
        end,
    },


    -- Places the Hunter's Mark on the target, increasing the ranged attack power of all attackers against that target by 20.  In addition, the target of this ability can always be seen by the hunter whether it stealths or turns invisible.  The target also appears on the mini-map.  Lasts for 5 min.
    hunters_mark = {
        id = 1130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.02 ) * ( 1 - ( ( 1 / 3 ) * talent.improved_hunters_mark.rank ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132212,

        handler = function ()
            applyDebuff( "target", "hunters_mark" )
        end,

        copy = { 14323, 14324, 14325, 53338 },
    },


    -- Place a fire trap that will burn the first enemy to approach for 138 Fire damage over 15 sec.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    immolation_trap = {
        id = 49056,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.09 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135813,

        handler = function ()
            cool_traps()
        end,

        copy = { 13795, 14302, 14303, 14304, 14305, 27023, 49055, 49056 },
    },


    -- Command your pet to intimidate the target, causing a high amount of threat and stunning the target for 3 sec. Lasts 15 sec.
    intimidation = {
        id = 19577,
        cast = 0,
        cooldown = function() return 60 * ( 1 - 0.1 * talent.longevity.rank ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.08 ) end,
        spendType = "mana",

        talent = "intimidation",
        startsCombat = true,
        texture = 132111,

        toggle = "interrupts",

        usable = function() return pet.active, "requires a pet" end,

        handler = function ()
            applyDebuff( "target", "intimidation" )
            if not target.is_boss then interrupt() end
        end,
    },


    -- Give the command to kill, increasing your pet's damage done from special attacks by 60% for 30 sec.  Each special attack done by the pet reduces the damage bonus by 20%.
    kill_command = {
        id = 34026,
        cast = 0,
        cooldown = function() return 60 - ( 10 * talent.catlike_reflexes.rank ) end,
        gcd = "off",

        spend = function() return mod_beast_within( 0.03 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132176,

        usable = function() return pet.active, "requires a pet" end,

        handler = function ()
            applyBuff( "kill_command_buff", nil, 3 )
        end,
    },


    -- You attempt to finish the wounded target off, firing a long range attack dealing 200% weapon damage plus 543. Kill Shot can only be used on enemies that have 20% or less health.
    kill_shot = {
        id = 61006,
        cast = 0,
        cooldown = function() return glyph.kill_shot.enabled and 9 or 15 end,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.07 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 236174,

        usable = function() return target.health.pct < 20, "enemy health must be below 20 percent" end,

        handler = function ()
        end,

        copy = { 53351, 61005, 61006 },
    },


    -- Your pet attempts to remove all root and movement impairing effects from itself and its target, and causes your pet and its target to be immune to all such effects for 4 sec.
    masters_call = {
        id = 53271,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = function() return mod_beast_within( 0.07 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 236189,

        toggle = "interrupts",

        usable = function() return pet.active, "requires an active pet" end,

        handler = function ()
            applyBuff( "masters_call" )
        end,
    },


    -- Heals your pet for 125 health over 15 sec.
    mend_pet = {
        id = 136,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.09 ) * ( 1 - ( 0.1 * talent.improved_mend_pet.rank ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132179,

        usable = function() return pet.active, "requires an active pet" end,

        handler = function ()
            applyBuff( "mend_pet" )
        end,

        copy = { 3111, 3661, 3662, 13542, 13543, 13544, 27046, 48989, 48990 },
    },


    -- The current party or raid member targeted will receive the threat caused by your next damaging attack and all actions taken for 4 sec afterwards.
    misdirection = {
        id = 34477,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.09 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132180,

        usable = function() return pet.active or group, "requires an active pet or a group" end,

        handler = function ()
            applyBuff( "misdirection" )
        end,
    },


    -- Attack the enemy for 104 damage.
    mongoose_bite = {
        id = 1495,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132215,

        buff = "mongoose_bite_usable",

        usable = function() return target.distance < 10, "requires melee range" end,

        handler = function ()
            removeBuff( "mongoose_bite_usable" )
        end,

        copy = { 14269, 14270, 14271, 36916, 53339 },
    },


    -- Fires several missiles, hitting 3 targets.
    multishot = {
        id = 49048,
        cast = 0.5,
        cooldown = function() return glyph.multishot.enabled and 9 or 10 end,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.09 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132330,

        handler = function ()
            if talent.concussive_barrage.enabled then applyDebuff( "target", "concussive_barrage" ) end
        end,

        copy = { 2643, 14288, 14289, 14290, 25294, 27021, 49047, 49048 },
    },


    -- Increases ranged attack speed by 40% for 15 sec.
    rapid_fire = {
        id = 3045,
        cast = 0,
        cooldown = function() return 300 - 60 * talent.rapid_killing.rank end,
        gcd = "off",

        spend = function() return mod_beast_within( 0.03 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132208,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "rapid_fire" )
        end,
    },


    -- A strong attack that increases melee damage by 5.
    raptor_strike = {
        id = 2973,
        cast = 0,
        cooldown = 6,
        gcd = "off",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.04 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132223,

        handler = function ()
            if glyph.raptor_strike.enabled then applyBuff( "raptor_strike" ) end
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
        startsCombat = false,
        texture = 132206,

        toggle = "cooldowns",

        handler = function ()
            for k, v in pairs( class.specs[ 3 ].abilities ) do
                if type( k ) == "string" and k ~= "bestial_wrath" then
                    setCooldown( k, 0 )
                end
            end
        end,
    },


    -- Revive your pet, returning it to life with 15% of its base health.
    revive_pet = {
        id = 982,
        cast = function() return 10 - ( 3 * talent.improved_revive_pet.rank ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.8 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132163,

        handler = function ()
            summonPet( "pet" )
        end,
    },


    -- Scares a beast, causing it to run in fear for up to 10 sec.  Damage caused may interrupt the effect.  Only one beast can be feared at a time.
    scare_beast = {
        id = 1513,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.02 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132118,

        usable = function() return target.is_beast, "requires beast target" end,

        handler = function ()
            applyDebuff( "target", "scare_beast" )
        end,

        copy = { 14326, 14327 },
    },


    -- A short-range shot that deals 50% weapon damage and disorients the target for 4 sec.  Any damage caused will remove the effect.  Turns off your attack when used.
    scatter_shot = {
        id = 19503,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.08 ) end,
        spendType = "mana",

        talent = "scatter_shot",
        startsCombat = true,
        texture = 132153,

        handler = function ()
            applyDebuff( "target", "scatter_shot" )
        end,
    },


    -- Stings the target, reducing chance to hit with melee and ranged attacks by 3% for 20 sec.  Only one Sting per Hunter can be active on any one target.
    scorpid_sting = {
        id = 3043,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.11 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132169,

        handler = function ()
            removeDebuff( "target", "stings" )
            applyDebuff( "target", "scorpid_sting" )
        end,
    },


    -- Stings the target, causing 87 Nature damage over 15 sec.  Only one Sting per Hunter can be active on any one target.
    serpent_sting = {
        id = 49001,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.09 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132204,

        handler = function ()
            removeDebuff( "target", "stings" )
            applyDebuff( "target", "serpent_sting" )
        end,

        copy = { 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 27016, 49000, 49001 },
    },


    -- A shot that deals 50% weapon damage and Silences the target for 3 sec.  Non-player victim spellcasting is also interrupted for 3 sec.
    silencing_shot = {
        id = 34490,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = function() return mod_beast_within( 0.06 ) end,
        spendType = "mana",

        talent = "silencing_shot",
        startsCombat = true,
        texture = 132323,

        handler = function ()
            interrupt()
        end,
    },


    -- Place a trap that will release several venomous snakes to attack the first enemy to approach.  The snakes will die after 15 sec.  Trap will exist for 30 sec.  Only one trap can be active at a time.
    snake_trap = {
        id = 34600,
        cast = 0,
        cooldown = function() return mod_resourcefulness_cd( 30 ) end,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.09 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132211,

        handler = function ()
            cool_traps()
        end,
    },


    -- A steady shot that causes unmodified weapon damage, plus ammo, plus 78.  Causes an additional 175 against Dazed targets.
    steady_shot = {
        id = 56641,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_master_marksman( mod_efficiency( 0.05 ) ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132213,

        handler = function ()
        end,

        copy = { 34120, 49051, 49052, 56641 },
    },


    -- Begins taming a beast to be your companion.  Your armor is reduced by 100% while you focus on taming the beast for 20 sec.  If you lose the beast's attention for any reason, the taming process will fail.  Once tamed, the beast will be very unhappy and disloyal.  Try feeding the pet immediately to make it happy.
    tame_beast = {
        id = 1515,
        cast = 20,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.48 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132164,

        usable = function() return not pet.active, "cannot have a pet" end,

        handler = function ()
            applyDebuff( "target", "tame_beast" )
        end,
    },


    -- Shows the location of all nearby beasts on the minimap.  Only one form of tracking can be active at a time.
    track_beasts = {
        id = 1494,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 132328,

        nobuff = "track_beasts",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_beasts" )
        end,
    },


    -- Shows the location of all nearby demons on the minimap.  Only one form of tracking can be active at a time.
    track_demons = {
        id = 19878,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 136217,

        nobuff = "track_demons",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_demons" )
        end,
    },


    -- Shows the location of all nearby dragonkin on the minimap.  Only one form of tracking can be active at a time.
    track_dragonkin = {
        id = 19879,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 134153,

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_dragonkin" )
        end,
    },


    -- Shows the location of all nearby elementals on the minimap.  Only one form of tracking can be active at a time.
    track_elementals = {
        id = 19880,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 135861,

        nobuff = "track_elementals",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_elementals" )
        end,
    },


    -- Shows the location of all nearby giants on the minimap.  Only one form of tracking can be active at a time.
    track_giants = {
        id = 19882,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 132275,

        nobuff = "track_giants",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_giants" )
        end,
    },


    -- Greatly increases stealth detection and shows hidden units within detection range on the minimap.  Only one form of tracking can be active at a time.
    track_hidden = {
        id = 19885,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        nobuff = "track_hidden",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_hidden" )
        end,
    },


    -- Shows the location of all nearby humanoids on the minimap.  Only one form of tracking can be active at a time.
    track_humanoids = {
        id = 19883,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 135942,

        nobuff = "track_humanoids",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_humanoids" )
        end,
    },


    -- Shows the location of all nearby undead on the minimap.  Only one form of tracking can be active at a time.
    track_undead = {
        id = 19884,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 136142,

        nobuff = "track_undead",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_undead" )
        end,
    },


    -- Attempts to remove 1 Enrage and 1 Magic effect from an enemy target.
    tranquilizing_shot = {
        id = 19801,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.08 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136020,

        debuff = function()
            return debuff.dispellable_enrage.up and "dispellable_enrage" or "dispellable_magic"
        end,

        handler = function ()
            removeDebuff( "target", "dispellable_enrage" )
            removeDebuff( "target", "dispellable_magic" )
        end,
    },


    -- Increases the attack power of party and raid members within 100 yards by 10%.  Lasts until cancelled.
    trueshot_aura = {
        id = 19506,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "trueshot_aura",
        startsCombat = false,
        texture = 132329,

        nobuff = "trueshot_aura",

        handler = function ()
            applyBuff( "trueshot_aura" )
        end,
    },


    -- Stings the target, draining 4% mana over 8 sec (up to a maximum of 8% of the caster's maximum mana), and energizing the Hunter equal to 300% of the amount drained.  Only one Sting per Hunter can be active on any one target.
    viper_sting = {
        id = 3034,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.08 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132157,

        usable = function() return UnitPowerMax( "target", Enum.PowerType.Mana ) > 0, "requires a target that has mana" end,

        handler = function ()
            removeDebuff( "target", "stings" )
            applyDebuff( "target", "viper_sting" )
        end,
    },


    -- Continuously fires a volley of ammo at the target area, causing 80 Arcane damage to enemy targets within 8 yards every 1.00 second for 6 sec.
    volley = {
        id = 58434,
        cast = 6,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.17 ) * ( glyph.volley.enabled and 0.8 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132222,

        handler = function ()
        end,

        copy = { 1510, 14294, 14295, 27022, 58431, 58434 },
    },


    wing_clip = {
        id = 2974,
        cast = 0,
        cooldown = 1.5,
        gcd = "spell",

        spend = function() return mod_beast_within( mod_resourcefulness_cost( 0.06 ) ) * ( 1 - 0.02 * talent.efficiency.rank ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132309,

        usable = function() return target.distance < 10, "requires melee range" end,

        handler = function()
            applyDebuff( "target", "wing_clip" )
        end,
    },


    -- A stinging shot that puts the target to sleep for 30 sec.  Any damage will cancel the effect.  When the target wakes up, the Sting causes 300 Nature damage over 6 sec.  Only one Sting per Hunter can be active on the target at a time.
    wyvern_sting = {
        id = 19386,
        cast = 0,
        cooldown = function() return glyph.wyvern_sting.enabled and 54 or 60 end,
        gcd = "spell",

        spend = function() return mod_beast_within( 0.08 ) end,
        spendType = "mana",

        talent = "wyvern_sting",
        startsCombat = true,
        texture = 135125,

        toggle = "cooldowns",

        handler = function ()
            removeDebuff( "target", "stings" )
            applyDebuff( "target", "wyvern_sting" )
        end,
    },


    -- Pet Abilities
    acid_spit = {
        id = 55754,
        cast = 0,
        cooldown = function() return 10 * ( 1 - ( 0.1 * talent.longevity.rank ) ) end,
        gcd = "off",

        startsCombat = true,

        usable = function() return UnitPower( "pet", Enum.PowerType.Focus ) > 20, "requires 20 pet focus" end,

        handler = function()
            applyDebuff( "target", "acid_spit", nil, debuff.acid_spit.stack + 1 )
        end,

        copy = { 55749, 55750, 55751, 55752, 55753, 55754 }
    },

    call_of_the_wild = {
        id = 53434,
        cast = 0,
        cooldown = function() return 300 * ( 1 - ( 0.1 * talent.longevity.rank ) ) end,
        gcd = "off",

        startsCombat = false,

        handler = function()
            applyBuff( "call_of_the_wild" )
        end,
    },

    demoralizing_screech = {
        id = 55487,
        cast = 0,
        cooldown = function() return 10 * ( 1 - ( 0.1 * talent.longevity.rank ) ) end,
        gcd = "off",

        startsCombat = true,

        usable = function() return UnitPower( "pet", Enum.PowerType.Focus ) > 20, "requires 20 pet focus" end,

        handler = function()
            applyDebuff( "target", "demoralizing_screech" )
        end,

        copy = { 24423, 24577, 24578, 24579, 27051, 55487 }
    }


} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 1494,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "speed",

    package = "Beast Mastery (wowtbc.gg)",
    usePackSelector = true
} )


spec:RegisterPack( "Beast Mastery (wowtbc.gg)", 20230211, [[Hekili:fs1YUTnmqWpMCPfTr2YjTnPajhYHced0CrbO3O0kPvseMIuGKYQ(c)27sjeBkzB0l6b5SdN9Xqwm7Dwsjyr2BBwV5U1BIJJw)W3Em(owI9qhYs6GIDqn9HeAPNVGGX6Y(n9e1hCzFAqnyZlIQR)Sh7bHck9CAu96ccFJ12z(5QvhHrFzf7wviaJ526EEjAwL7j922joVTPxsVxXsY75c7Rsw(LLiDiDyb7nsQn8YsCciAkyjV3WnUSonxP5wsL()Ybdw6YusxMTbDzhvKl7pAW24YgvtelrWnwZyHbRGEHL(8TXcfuy5kjDUCbkl4Y6utJYYsqjKlWs2lmljspYtRKuqsa1CWtxEFvvubLNuSr9DNyKlT8woLL()S(C6QKOgKNIBQwzsBb9oFC3hktn0XltR4ACHe)wiQcqisvvPurjDGlkxG97HyZrs6GiDWxWwa8hHa3XjsluTTGCjHpeIRtn9EgIhdr0BWuk3BnlafV(SZ7cnJ44)x3ySxyIMxwnOUdL20Xnh556DvlORrB0a32WLKQosc(3oHYW3JPwQtmYYDHAULgT4xsZ3F1ZYhkXhkXwosZ0p7Y2CIW9kHapmsXSomOlajEXYZSUlz)GYdxah9BNgP2zoCUza8Uq7htqLAOwjBGHDlPGizpnQ6JXBK3eVEnP9bql9nawYRTDkT1Br34YMi3LnAfJCB9cqvr2owYn34YwCl0w)AXXUSFH56EWFVK)Qc3w32jImrh1)xEA11uCaEc1CtE4oHM1VYRE6mFDi4qh6iyAqlC)tM0WvxAkd3BMjmCJqtx46tMSWvoAQol8L56mNqqYgyBcHpFM3JFH9ie8rdq4ItdX(iNpS)8MqubJ0ZuB4em0BBuAAe7Jl6hhcz)l]] )

spec:RegisterPack( "Marksmanship", 20230226, [[Hekili:TA12UnUnq0)gJDrxO6ljoDbI9dfOaDdW6x0(mLOLgBrejsbsQ4AGa(T3HuXwu0sYPa9flBZzoCUCMZiYcYViX5unq2TC(YvZxUCD0INw89vprI1NRbsCnn7v6r8lCAf(5pPYxvvuUQGvBp8CPGMBbrjAKzObK49nSs9p4K9dJ8JOT1qgz3ksCblphATeuz9r3Kw0W1G0KwlzcjtF2KEqG)8VHxzLmsCjtPv2RMka8XoxUaC6(siN8NK4m0hqYOyMqLhbD0jMUGXX7NMPzcoA8)uxkuS3GeTKwt0yO6W7JJRAk1mvHq7dR2g4JDrwpr0aouXaLjD7gt6QoaFtuwcNTq8WOqKd7BoCisPz8JQOCXjEN)kqwdCDI7qlmp6hUzfSkqstUnI1wypqX0z660qH)YUlq2WtA)EIT232bsA5f2EWL6Nh2Fgxv62qu9jIobpIAzp6eXHeDbK8gRgKrAmZtumEgysF2KU2KoZK6QJdzDtT78mHO0wFJ8lCrsOIY42K3Ko3R0RbA(52A7a5Px)dr0bpsJPr41LHDmhAl9yE9dRCj9OGxqp9600R(SH2Xdvsfo0mnNYvjqgolp5atcbSQUdUsPghLmAz5LW(eRmpaRWJTiU2NKwl(y0ZFG6jFlAuqcELvQaJ(dFJkqTjjwdHCKwLbLy7BaC)UVlOOr5aZg7wm))NzXfl(CdJ7w0tKHI2LpOzJZd(Ih51RT2rDX52fpo3K((73Zst6hIJUriTijNHZqF9ZoG03UUCzSXijofX4Gs5YWh6viKzuomyLyCoPc0TnhvZXJakP0jPBvzgxOFX67JPDc(iKyF0QCmWC9ZBMAW25L766rX9ftcfQRLqMOApTtm8UAg9RwtlnnQ8H7YFd)d7HxxztIprLCB1Ge)JQAHud5M0hmPTOysDlHJmVydCXbwjC5curxZKFBZVpwSBEziR9dTVXoSXPPEXs88GTjFZUhzdUbYAB)DyB3S8UoQ0Mx6IdLna8AqxW8UBEEE9Sj24mBYHPTZdcGXQxxQgZ8zHBx(yG7twaBnPtnWAWqBicCiuA)QBdUsiW5wz)G)8QsFy0pS4EGvx1Zd7D(cZUK)gv8WmZRJe2hUQOfw(UiKzVHVmHg72nOs87VpLf3Qa)17rxMnHM7TKPoL1Gt6RlAtLjfuNKK6y69G4g9ZES2N3CdT1BSZFKeNShmw7)A9H2F9T3dpO9TWhsRyvOP)N4sTU0FXpTrxiKK4Fva)vLcVwk3P0s(3)]] )

spec:RegisterPack( "Survival (wowtbc.gg)", 20230211, [[Hekili:DwvqZTjpq0Fm5s70gSHy3M8ntYHEOtJp4lKz6nbcqy0ybIrAXuFr)27k4ZGGIRB7LaE3NES7B1(cXN8gjmJcmY(G1bpSoW33B9JBFAZwsiCUMrcRPPhPhWxQOL4FdBuN4NOct87ALTqsQ3HdV3I6SqsZSSPLnQuezba16)B1Qby4BG44QubvRV)qdpJPxP)F6UVOPcyQvKWKgUaETIKSCDTb)a1SuY(hWVaplJ1JKPtjHVvW1M4AfxQ4WztS9xjunlZelRmXqbZepunM4VROqHjURs8iHcUg0DYblN2ia819DYdRIMiyzKVqctrIzkofbjBRiH0uGlXN9vVoQKQosaSMTN7ssfTMNfLZvmxUaBl4GkLkerY8iSkJA5ISzy34I9ihXMkllPvZXT1fxTS)5eeFYfrJMfHTuPEgOpF9gNL0KN7X(rTqQ5Nyr6cj4nvoMM0Y3JxLpGQoWapzdOX5G)6rwse4vViQsjBTu80TOOLdf8kxggRdahcwsWSxJf7HqKSkwjNH3CEXehmsvjEJGFPB8V(9IFplNKcb7Chfb)YaTJ9PJb)jxrO8sw2IW2CRXLg4vh0ZgtAMQMvbrDj74z7FVgNRKAyuFNC7sdmA25fQy8N1kgEdoHoUNn0M2fC4YUqMIEqwvqBpoRPd(h3nF4MBiB(d7bmWjKzlmRlvG)614SULQQSInj81YAPcS2pbM4E(mXD2mEMDwfqMZfOPWD3zIh9v)wx9A2zJ67BI)klr1qvOFM1j0SZSRNkT3Ge(HNxDnrBz0UAYh55pBvSLr2lqlNZrACkRBrpMF0r0n6Chq3CUoE9sZyU8g0XVrhviBfUNzwPJrgC7Cdo1SQRCVQfN75CSNShAUp2YFc7EId6lRtUGhCAS4MAN8sGlWEZKBHAWAXn4OtIB0j(bocHJ5Hl8Xn)B0rtwHOnqHuHRjx(hXDlsKFo]] )


spec:RegisterPackSelector( "beast_mastery", "Beast Mastery (wowtbc.gg)", "|T132164:0|t Beast Mastery",
    "If you have spent more points in |T132164:0|t Beast Mastery than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "marksmanship", "Marksmanship (wowtbc.gg)", "|T132222:0|t Marksmanship",
    "If you have spent more points in |T132222:0|t Marksmanship than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "survival", "Survival (wowtbc.gg)", "|T132215:0|t Survival",
    "If you have spent more points in |T132215:0|t Survival than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )
	
-- Settings
spec:RegisterSetting( "suggest_explosive_st", false, {
    type = "toggle",
    name = "|T135826:0|t Suggest Explosive Trap on Single Target",
    desc = "When enabled, |T135826:0|t Explosive Trap will be suggested in single target scenarios as well as AoE.",
    width = "full",
} )

spec:RegisterSetting( "manage_mana_viper", false, {
    type = "toggle",
    name = "|T132160:0|t Swap to Aspect of the Viper for Mana",
    desc = "When enabled, the profile will suggest swapping to |T132160:0|t Aspect of the Viper at low mana.",
    width = "full",
} )