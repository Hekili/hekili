if UnitClassBase( 'player' ) ~= 'WARLOCK' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 9 )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    aftermath                  = {   982, 2, 18119, 18120 },
    amplify_curse              = {  1061, 1, 18288 },
    backdraft                  = {  1888, 3, 47258, 47259, 47260 },
    backlash                   = {  1817, 3, 34935, 34938, 34939 },
    bane                       = {   943, 5, 17788, 17789, 17790, 17791, 17792 },
    cataclysm                  = {   941, 3, 17778, 17779, 17780 },
    chaos_bolt                 = {  1891, 1, 50796 },
    conflagrate                = {   968, 1, 17962 },
    contagion                  = {  1669, 5, 30060, 30061, 30062, 30063, 30064 },
    curse_of_exhaustion        = {  1081, 1, 18223 },
    dark_pact                  = {  1022, 1, 18220 },
    deaths_embrace             = {  1875, 3, 47198, 47199, 47200 },
    decimation                 = {  2261, 2, 63156, 63158 },
    demonic_aegis              = {  1671, 3, 30143, 30144, 30145 },
    demonic_brutality          = {  1225, 3, 18705, 18706, 18707 },
    demonic_embrace            = {  1223, 3, 18697, 18698, 18699 },
    demonic_empowerment        = {  1880, 1, 47193 },
    demonic_knowledge          = {  1263, 3, 35691, 35692, 35693 },
    demonic_pact               = {  1885, 5, 47236, 47237, 47238, 47239, 47240 },
    demonic_power              = {   983, 2, 18126, 18127 },
    demonic_resilience         = {  1680, 3, 30319, 30320, 30321 },
    demonic_tactics            = {  1673, 5, 30242, 30245, 30246, 30247, 30248 },
    destructive_reach          = {   964, 2, 17917, 17918 },
    devastation                = {   981, 1, 18130 },
    emberstorm                 = {   966, 5, 17954, 17955, 17956, 17957, 17958 },
    empowered_corruption       = {  1764, 3, 32381, 32382, 32383 },
    empowered_imp              = {  2045, 3, 47220, 47221, 47223 },
    eradication                = {  1878, 3, 47195, 47196, 47197 },
    everlasting_affliction     = {  1876, 5, 47201, 47202, 47203, 47204, 47205 },
    fel_concentration          = {  1001, 3, 17783, 17784, 17785 },
    fel_domination             = {  1226, 1, 18708 },
    fel_synergy                = {  1883, 2, 47230, 47231 },
    fel_vitality               = {  1242, 3, 18731, 18743, 18744 },
    fire_and_brimstone         = {  1890, 5, 47266, 47267, 47268, 47269, 47270 },
    grim_reach                 = {  1021, 2, 18218, 18219 },
    haunt                      = {  2041, 1, 48181 },
    improved_corruption        = {  1003, 5, 17810, 17811, 17812, 17813, 17814 },
    improved_curse_of_agony    = {  1284, 2, 18827, 18829 },
    improved_curse_of_weakness = {  1006, 2, 18179, 18180 },
    improved_demonic_tactics   = {  1882, 3, 54347, 54348, 54349 },
    improved_drain_soul        = {  1101, 2, 18213, 18372 },
    improved_fear              = {  2205, 2, 53754, 53759 },
    improved_felhunter         = {  1873, 2, 54037, 54038 },
    improved_health_funnel     = {  1224, 2, 18703, 18704 },
    improved_healthstone       = {  1221, 2, 18692, 18693 },
    improved_howl_of_terror    = {  1668, 2, 30054, 30057 },
    improved_immolate          = {   961, 3, 17815, 17833, 17834 },
    improved_imp               = {  1222, 3, 18694, 18695, 18696 },
    improved_life_tap          = {  1007, 2, 18182, 18183 },
    improved_sayaad            = {  1243, 3, 18754, 18755, 18756 },
    improved_searing_pain      = {   965, 3, 17927, 17929, 17930 },
    improved_shadow_bolt       = {   944, 5, 17793, 17796, 17801, 17802, 17803 },
    improved_soul_leech        = {  1889, 2, 54117, 54118 },
    intensity                  = {   985, 2, 18135, 18136 },
    malediction                = {  1667, 3, 32477, 32483, 32484 },
    mana_feed                  = {  1281, 1, 30326 },
    master_conjuror            = {  1261, 2, 18767, 18768 },
    master_demonologist        = {  1244, 5, 23785, 23822, 23823, 23824, 23825 },
    master_summoner            = {  1227, 2, 18709, 18710 },
    metamorphosis              = {  1886, 1, 59672 },
    molten_core                = {  1283, 3, 47245, 47246, 47247 },
    molten_skin                = {  1887, 3, 63349, 63350, 63351 },
    nemesis                    = {  1884, 3, 63117, 63121, 63123 },
    nether_protection          = {  1679, 3, 30299, 30301, 30302 },
    nightfall                  = {  1002, 2, 18094, 18095 },
    pandemic                   = {  2245, 1, 58435 },
    pyroclasm                  = {   986, 3, 18096, 18073, 63245 },
    ruin                       = {   967, 5, 17959, 59738, 59739, 59740, 59741 },
    shadow_and_flame           = {  1677, 5, 30288, 30289, 30290, 30291, 30292 },
    shadow_embrace             = {  1763, 5, 32385, 32387, 32392, 32393, 32394 },
    shadow_mastery             = {  1042, 5, 18271, 18272, 18273, 18274, 18275 },
    shadowburn                 = {   963, 1, 17877 },
    shadowfury                 = {  1676, 1, 30283 },
    siphon_life                = {  1041, 1, 63108 },
    soul_leech                 = {  1678, 3, 30293, 30295, 30296 },
    soul_link                  = {  1282, 1, 19028 },
    soul_siphon                = {  1004, 2, 17804, 17805 },
    summon_felguard            = {  1672, 1, 30146 },
    suppression                = {  1005, 3, 18174, 18175, 18176 },
    unholy_power               = {  1262, 5, 18769, 18770, 18771, 18772, 18773 },
    unstable_affliction        = {  1670, 1, 30108 },
} )


-- Auras
spec:RegisterAuras( {
    -- Dazed.
    aftermath = {
        id = 18118,
        duration = 5,
        max_stack = 1,
    },
    -- Reduced cast time and global cooldown for your non-channeled Destruction spells by $s1%.
    backdraft = {
        id = 54277,
        duration = 15,
        max_stack = 1,
        copy = { 54277, 54276, 54274 },
    },
    backlash = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=34939)
        id = 34939,
        duration = 3600,
        max_stack = 1,
        copy = { 34939, 34938, 34936, 34935 },
    },
    -- Invulnerable, but unable to act.
    banish = {
        id = 710,
        duration = 20,
        max_stack = 1,
        copy = { 710, 18647 },
    },
    -- Taunted.
    challenging_howl = {
        id = 59671,
        duration = 6,
        max_stack = 1,
    },
    -- Fire damage every $t2 seconds.
    conflagrate = {
        id = 17962,
        duration = 6,
        max_stack = 1,
    },
    -- $s1 Shadow damage every $t1 seconds.
    corruption = {
        id = 172,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 172, 6222, 6223, 7648, 11671, 11672, 25311, 27216, 47812, 47813 },
    },
    -- $o1 Shadow damage over $d.
    curse_of_agony = {
        id = 980,
        duration = function() return glyph.curse_of_agony.enabled and 28 or 24 end,
        tick_time = 2,
        max_stack = 1,
        copy = { 980, 1014, 6217, 11711, 11712, 11713, 27218, 47863, 47864 },
    },
    -- Causes $s1 Shadow damage after $d.
    curse_of_doom = {
        id = 603,
        duration = 60,
        tick_time = 60,
        max_stack = 1,
        copy = { 603, 30910, 47867 },
    },
    -- Movement speed slowed by $s1%.
    curse_of_exhaustion = {
        id = 18223,
        duration = 12,
        max_stack = 1,
    },
    -- Reduces Arcane, Fire, Frost, Nature and Shadow resistances by $s1.  Increases magic damage taken by $s2%.
    curse_of_the_elements = {
        id = 1490,
        duration = 300,
        max_stack = 1,
        copy = { 1490, 11721, 11722, 27228, 47865 },
    },
    -- Speaking Demonic increasing casting time by $s1%.
    curse_of_tongues = {
        id = 1714,
        duration = 30,
        max_stack = 1,
        copy = { 1714, 11719 },
    },
    -- Melee attack power reduced by $s1, and armor is reduced by $s2%.
    curse_of_weakness = {
        id = 702,
        duration = 120,
        max_stack = 1,
        copy = { 702, 1108, 6205, 7646, 11707, 11708, 27224, 30909, 50511 },
    },
    -- Horrified.
    death_coil = {
        id = 6789,
        duration = function() return glyph.death_coil.enabled and 3.5 or 3 end,
        max_stack = 1,
        copy = { 6789, 17925, 17926, 27223, 47859, 47860, 52375, 59134, 65820 },
    },
    -- Your Soul Fire cast time is reduced by $s1%, and costs no shard.
    decimation = {
        id = 63167,
        duration = 10,
        max_stack = 1,
        copy = { 63167, 63165 },
    },
    -- Increases armor by $s1, and amount of health generated through spells and effects by $s2%
    demon_armor = {
        id = 706,
        duration = 1800,
        max_stack = 1,
        copy = { 706, 1086, 11733, 11734, 11735, 27260, 47793, 47889 },
    },
    -- Increases armor by $s1, and amount of health generated through spells and effects by $s2%
    demon_skin = {
        id = 687,
        duration = 1800,
        max_stack = 1,
        copy = { 687, 696 },
    },
    -- Demonic Circle Summoned.
    demonic_circle_summon = {
        id = 48018,
        duration = 360,
        tick_time = 1,
        max_stack = 1,
    },
    demonic_circle_teleport = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=48020)
        id = 48020,
        duration = 1,
        max_stack = 1,
    },
    demonic_resilience = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=30321)
        id = 30321,
        duration = 3600,
        max_stack = 1,
        copy = { 30321, 30320, 30319 },
    },
    -- Detect lesser invisibility.
    detect_invisibility = {
        id = 132,
        duration = 600,
        max_stack = 1,
    },
    -- Drains $s1 health every $t1 sec to the caster.
    drain_life = {
        id = 689,
        duration = 5,
        tick_time = 1,
        max_stack = 1,
        copy = { 689, 699, 709, 7651, 11699, 11700, 27219, 27220, 47857, 358742 },
    },
    -- Drains $m1% mana each second to the caster.
    drain_mana = {
        id = 5138,
        duration = 5,
        tick_time = 1,
        max_stack = 1,
    },
    -- $s2 Shadow damage every $t2 seconds.
    drain_soul = {
        id = 1120,
        duration = 15,
        max_stack = 1,
        copy = { 1120, 8288, 8289, 11675, 27217, 47855 },
    },
    -- Spell casting speed increased by $s1%.
    eradication = {
        id = 64371,
        duration = 10,
        max_stack = 1,
        copy = { 64371, 64370, 64368 },
    },
    -- Controlling Eye of Kilrogg.
    eye_of_kilrogg = {
        id = 126,
        duration = 45,
        max_stack = 1,
    },
    -- Feared.
    fear = {
        id = 5782,
        duration = 10,
        max_stack = 1,
        copy = { 5782, 6213, 6215, 65809 },
    },
    -- Increases spell power by $s3 plus additional spell power equal to $s1% of your Spirit. Also regenerate $s2% of maximum health every 5 sec.
    fel_armor = {
        id = 28176,
        duration = 1800,
        max_stack = 1,
        copy = { 28176, 28189, 44520, 44977, 47892, 47893 },
    },
    -- Imp, Voidwalker, Succubus, Felhunter and Felguard casting time reduced by $/1000;S1 sec.  Mana cost reduced by $s2%.
    fel_domination = {
        id = 18708,
        duration = 15,
        max_stack = 1,
    },
    -- Damage taken from Shadow damage-over-time effects increased by $s3%.
    haunt = {
        id = 48181,
        duration = 12,
        max_stack = 1,
        copy = { 48181, 59161, 59163, 59164 },
    },
    -- Transferring Life.
    health_funnel = {
        id = 755,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 755, 3698, 3699, 3700, 11693, 11694, 11695, 27259, 47856 },
    },
    -- Damages self and all nearby enemies.
    hellfire = {
        id = 1949,
        duration = 15,
        tick_time = 1,
        max_stack = 1,
        copy = { 1949, 11683, 11684, 27213, 47823 },
    },
    -- Fleeing in terror.
    howl_of_terror = {
        id = 5484,
        duration = 6,
        max_stack = 1,
        copy = { 5484, 17928, 50577 },
    },
    -- $s1 Fire damage every $t1 seconds.
    immolate = {
        id = 348,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309, 27215, 47810, 47811 },
    },
    -- Damages all nearby enemies.
    immolation_aura = {
        id = 50589,
        duration = 15,
        tick_time = 1,
        max_stack = 1,
    },
    improved_curse_of_agony = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=18829)
        id = 18829,
        duration = 3600,
        max_stack = 1,
        copy = { 18829, 18827 },
    },
    improved_healthstone = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=18693)
        id = 18693,
        duration = 3600,
        max_stack = 1,
        copy = { 18693, 18692 },
    },
    improved_howl_of_terror = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=30057)
        id = 30057,
        duration = 3600,
        max_stack = 1,
        copy = { 30057, 30054 },
    },
    improved_imp = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=18696)
        id = 18696,
        duration = 3600,
        max_stack = 1,
        copy = { 18696, 18695, 18694 },
    },
    improved_life_tap = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=18183)
        id = 18183,
        duration = 3600,
        max_stack = 1,
        copy = { 18183, 18182 },
    },
    improved_searing_pain = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=17930)
        id = 17930,
        duration = 3600,
        max_stack = 1,
        copy = { 17930, 17929, 17927 },
    },
    -- Demon Form.  Armor contribution from items increased by $47241s2%.  Chance to be critically hit by melee reduced by 6%.  Damage increased by $47241s3%.  Stun and snare duration reduced by $54817s1%.
    metamorphosis = {
        id = 47241,
        duration = 30,
        max_stack = 1,
    },
    -- Incinerate - Increases damage done by $71165s1% and reduces cast time by $71165s3%.    Soul Fire - Increases damage done by $71165s1% and increases critical strike chance by $71165s2%.
    molten_core = {
        id = 71165,
        duration = 15,
        max_stack = 1,
        copy = { 71165, 71162, 47383 },
    },
    -- Fire and Shadow damage increased by $s1%.
    pyroclasm = {
        id = 63244,
        duration = 10,
        max_stack = 1,
        copy = { 63244, 63243, 18093 },
    },
    -- $42223s1 Fire damage every $42223t1 seconds.
    rain_of_fire = {
        id = 5740,
        duration = 8,
        max_stack = 1,
        copy = { 5740, 6219, 11677, 11678, 19474, 27212, 39273, 47819, 47820 },
    },
    ritual_of_souls = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=29893)
        id = 29893,
        duration = 60,
        max_stack = 1,
    },
    ritual_of_summoning = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=698)
        id = 698,
        duration = 120,
        max_stack = 1,
    },
    -- Causes $s1 Shadow damage every $t1 sec.  After taking $s2 total damage or dying, Seed of Corruption deals $27285s1 Shadow damage to the caster's enemies within $27285a1 yards.
    seed_of_corruption = {
        id = 27243,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
        copy = { 27243, 47835, 47836 },
    },
    -- Detecting Demons.
    sense_demons = {
        id = 5500,
        duration = 3600,
        max_stack = 1,
    },
    -- Periodic shadow damage taken increased by $s1%, and periodic healing received reduced by $60468s1%.
    shadow_embrace = {
        id = 32391,
        duration = 12,
        max_stack = 3,
        copy = { 32391, 32390, 32389, 32388, 32386 },
    },
    -- Chance to be critically hit with spells increased by $s1%.
    shadow_mastery = {
        id = 17800,
        duration = 30,
        max_stack = 1,
    },
    -- Your next Shadow Bolt becomes an instant cast spell.
    shadow_trance = {
        id = 17941,
        duration = 10,
        max_stack = 1,
    },
    -- Absorbs Shadow damage.
    shadow_ward = {
        id = 6229,
        duration = 30,
        max_stack = 1,
        copy = { 6229, 11739, 11740, 28610, 47890, 47891 },
    },
    -- If target dies, casting warlock gets a Soul Shard.
    shadowburn = {
        id = 29341,
        duration = 5,
        max_stack = 1,
    },
    -- Stunned.
    shadowfury = {
        id = 30283,
        duration = 3,
        max_stack = 1,
        copy = { 30283, 30413, 30414, 47846, 47847 },
    },
    -- Enslaved.
    subjugate_demon = {
        id = 1098,
        duration = 300,
        max_stack = 1,
        copy = { 1098, 11725, 11726, 61191 },
    },
    summon_felguard = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=30146)
        id = 30146,
        duration = 3600,
        max_stack = 1,
    },
    summon_felhunter = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=691)
        id = 691,
        duration = 3600,
        max_stack = 1,
    },
    summon_imp = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=688)
        id = 688,
        duration = 3600,
        max_stack = 1,
    },
    summon_incubus = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=713)
        id = 713,
        duration = 3600,
        max_stack = 1,
    },
    summon_succubus = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=712)
        id = 712,
        duration = 3600,
        max_stack = 1,
    },
    summon_voidwalker = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=697)
        id = 697,
        duration = 3600,
        max_stack = 1,
    },
    -- Underwater Breathing.
    unending_breath = {
        id = 5697,
        duration = 600,
        max_stack = 1,
    },
    -- $s1 Shadow damage every $t1 sec.  If dispelled, will cause $*9;s1 damage to the dispeller and silence them for $31117d.
    unstable_affliction = {
        id = 30108,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 30108, 30404, 30405, 43522, 47841, 47843, 65812 },
    },
} )


-- Glyphs
spec:RegisterGlyphs( {
    [63304] = "chaos_bolt",
    [56235] = "conflagrate",
    [56218] = "corruption",
    [56241] = "curse_of_agony",
    [58080] = "curse_of_exhausion",
    [56232] = "death_coil",
    [63309] = "demonic_circle",
    [56244] = "fear",
    [56246] = "felguard",
    [56249] = "felhunter",
    [63302] = "haunt",
    [56238] = "health_funnel",
    [56224] = "healthstone",
    [56217] = "howl_of_terror",
    [56228] = "immolate",
    [56248] = "imp",
    [56242] = "incinerate",
    [58081] = "kilrogg",
    [63303] = "metamorphosis",
    [70947] = "quick_decay",
    [56226] = "searing_pain",
    [56240] = "shadow_bolt",
    [56229] = "shadowburn",
    [63310] = "shadowflame",
    [56216] = "siphon_life",
    [63312] = "soul_link",
    [58094] = "souls",
    [56231] = "soulstone",
    [58107] = "subjugate_demon",
    [56250] = "succubus",
    [58079] = "unending_breath",
    [56233] = "unstable_affliction",
    [56247] = "voidwalker",
} )


-- Abilities
spec:RegisterAbilities( {
    -- Banishes the enemy target, preventing all action but making it invulnerable for up to 20 sec.  Only one target can be banished at a time.  Casting Banish on a banished target will cancel the spell.  Only works on Demons and Elementals.
    banish = {
        id = 710,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136135,

        handler = function ()
        end,

        copy = { 18647 },
    },


    -- Sends a bolt of chaotic fire at the enemy, dealing 864 to 1089 Fire damage. Chaos Bolt cannot be resisted, and pierces through all absorption effects.
    chaos_bolt = {
        id = 50796,
        cast = 2.5,
        cooldown = function() return glyph.chaos_bolt.enabled and 10 or 12 end,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        talent = "chaos_bolt",
        startsCombat = true,
        texture = 236291,

        handler = function ()
        end,
    },


    -- Consumes an Immolate or Shadowflame effect on the enemy target to instantly deal damage equal to 60% of your Immolate or Shadowflame, and causes an additional 40% damage over 6 sec.
    conflagrate = {
        id = 17962,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        talent = "conflagrate",
        startsCombat = true,
        texture = 135807,

        handler = function ()
            if not glyph.conflagrate.enabled then
                if debuff.immolate.up then removeDebuff( "target", "immolate" )
                elseif debuff.shadowflame.up then removeDebuff( "target", "shadowflame" ) end
            end
        end,
    },


    -- Corrupts the target, causing 40 Shadow damage over 12 sec.
    corruption = {
        id = 172,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 136118,

        handler = function ()
        end,

        copy = { 6222, 6223, 7648, 11671, 11672, 25311, 27216, 47812, 47813 },
    },


    -- While applied to target weapon it increases damage dealt by direct spells by 1% and spell critical strike rating by 7.  Lasts for 1 hour.
    create_firestone = {
        id = 6366,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.54,
        spendType = "mana",

        startsCombat = true,
        texture = 132386,

        handler = function ()
        end,

        copy = { 17951, 17952, 17953, 27250, 60219, 60220 },
    },


    -- Creates a Minor Healthstone that can be used to instantly restore 100 health.    Conjured items disappear if logged out for more than 15 minutes.
    create_healthstone = {
        id = 6201,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.53,
        spendType = "mana",

        startsCombat = true,
        texture = 135230,

        handler = function ()
        end,

        copy = { 6202, 5699, 11729, 11730, 27230, 47871, 47878 },
    },


    -- Creates a Minor Soulstone.  The Soulstone can be used to store one target's soul.  If the target dies while their soul is stored, they will be able to resurrect with 400 health and 700 mana.    Conjured items disappear if logged out for more than 15 minutes.
    create_soulstone = {
        id = 693,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.68,
        spendType = "mana",

        startsCombat = true,
        texture = 136210,

        handler = function ()
        end,

        copy = { 20752, 20755, 20756, 20757, 27238, 47884 },
    },


    -- While applied to target weapon it increases damage dealt by periodic spells by 1% and spell haste rating by 10.  Lasts for 1 hour.
    create_spellstone = {
        id = 2362,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.45,
        spendType = "mana",

        startsCombat = true,
        texture = 134131,

        handler = function ()
        end,

        copy = { 17727, 17728, 28172, 47886, 47888 },
    },


    -- Curses the target with agony, causing 84 Shadow damage over 24 sec.  This damage is dealt slowly at first, and builds up as the Curse reaches its full duration.  Only one Curse per Warlock can be active on any one target.
    curse_of_agony = {
        id = 980,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136139,

        handler = function ()
        end,

        copy = { 1014, 6217, 11711, 11712, 11713, 27218, 47863, 47864 },
    },


    -- Curses the target with impending doom, causing 3200 Shadow damage after 1 min.  If the target yields experience or honor when it dies from this damage, a Doomguard will be summoned.  Cannot be cast on players.
    curse_of_doom = {
        id = 603,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = true,
        texture = 136122,

        toggle = "cooldowns",

        handler = function ()
        end,

        copy = { 30910, 47867 },
    },


    -- Reduces the target's movement speed by 30% for 12 sec.  Only one Curse per Warlock can be active on any one target.
    curse_of_exhaustion = {
        id = 18223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "curse_of_exhaustion",
        startsCombat = true,
        texture = 136162,

        handler = function ()
        end,
    },


    -- Curses the target for 5 min, reducing Arcane, Fire, Frost, Nature, and Shadow resistances by 45 and increasing magic damage taken by 6%.  Only one Curse per Warlock can be active on any one target.
    curse_of_the_elements = {
        id = 1490,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136130,

        handler = function ()
        end,

        copy = { 11721, 11722, 27228, 47865 },
    },


    -- Forces the target to speak in Demonic, increasing the casting time of all spells by 25%.  Only one Curse per Warlock can be active on any one target.  Lasts 30 sec.
    curse_of_tongues = {
        id = 1714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136140,

        handler = function ()
        end,

        copy = { 11719 },
    },


    -- Target's melee attack power is reduced by 21 and armor is reduced by 5% for 2 min.  Only one Curse per Warlock can be active on any one target.
    curse_of_weakness = {
        id = 702,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136138,

        handler = function ()
        end,

        copy = { 1108, 6205, 7646, 11707, 11708, 27224, 30909, 50511 },
    },


    -- Drains 305 of your summoned demon's Mana, returning 100% to you.
    dark_pact = {
        id = 18220,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "dark_pact",
        startsCombat = true,
        texture = 136141,

        handler = function ()
        end,
    },


    -- Causes the enemy target to run in horror for 3 sec and causes 257 Shadow damage.  The caster gains 300% of the damage caused in health.
    death_coil = {
        id = 6789,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.23,
        spendType = "mana",

        startsCombat = true,
        texture = 136145,

        toggle = "cooldowns",

        handler = function ()
        end,

        copy = { 17925, 17926, 27223, 47859, 47860 },
    },


    -- Protects the caster, increasing armor by 465, and increasing the amount of health generated through spells and effects by 20%. Only one type of Armor spell can be active on the Warlock at any time.  Lasts 30 min.
    demon_armor = {
        id = 706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.31,
        spendType = "mana",

        startsCombat = true,
        texture = 136185,

        handler = function ()
        end,

        copy = { 1086, 11733, 11734, 11735, 27260, 47793, 47889 },
    },


    -- Protects the caster, increasing armor by 90, and increasing the amount of health generated through spells and effects by 20%. Only one type of Armor spell can be active on the Warlock at any time.  Lasts 30 min.
    demon_skin = {
        id = 687,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.31,
        spendType = "mana",

        startsCombat = true,
        texture = 136185,

        handler = function ()
        end,

        copy = { 696 },
    },


    -- You summon a Demonic Circle at your feet, lasting 6 min. You can only have one Demonic Circle active at a time.
    demonic_circle_summon = {
        id = 48018,
        cast = 0.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = true,
        texture = 237559,

        handler = function ()
        end,
    },


    -- Teleports you to your Demonic Circle and removes all snare effects.
    demonic_circle_teleport = {
        id = 48020,
        cast = 0,
        cooldown = function() return glyph.demonic_circle.enabled and 26 or 30 end,
        gcd = "spell",

        spend = 100,
        spendType = "mana",

        startsCombat = true,
        texture = 237560,

        handler = function ()
        end,
    },


    -- Grants the Warlock's summoned demon Empowerment.    Imp - Increases the Imp's spell critical strike chance by 20% for 30 sec.    Voidwalker - Increases the Voidwalker's health by 20%, and its threat generated from spells and attacks by 20% for 20 sec.    Succubus and Incubus - Instantly vanishes, causing the demon to go into an improved Invisibility state. The vanish effect removes all stuns, snares and movement impairing effects from the demon.    Felhunter - Dispels all magical effects from the Felhunter.    Felguard - Increases the Felguard's attack speed by 20% and breaks all stun, snare and movement impairing effects and makes your Felguard immune to them for 15 sec.
    demonic_empowerment = {
        id = 47193,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.06,
        spendType = "mana",

        talent = "demonic_empowerment",
        startsCombat = true,
        texture = 236292,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Allows the friendly target to detect lesser invisibility for 10 min.
    detect_invisibility = {
        id = 132,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 136153,

        handler = function ()
        end,
    },


    -- Transfers 10 health every 1 sec from the target to the caster.  Lasts 5 sec.
    drain_life = {
        id = 689,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = true,
        texture = 136169,

        handler = function ()
        end,

        copy = { 699, 709, 7651, 11699, 11700, 27219, 27220, 47857 },
    },


    -- Transfers 3% of target's maximum mana every 1 sec from the target to the caster (up to a maximum of 6% of the caster's maximum mana every 1 sec).  Lasts 5 sec.
    drain_mana = {
        id = 5138,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = true,
        texture = 136208,

        handler = function ()
        end,
    },


    -- Drains the soul of the target, causing 55 Shadow damage over 15 sec.  If the target is at or below 25% health, Drain Soul causes four times the normal damage. If the target dies while being drained, and yields experience or honor, the caster gains a Soul Shard.  Each time the Drain Soul damages the target, it also has a chance to generate a Soul Shard.  Soul Shards are required for other spells.
    drain_soul = {
        id = 1120,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = true,
        texture = 136163,

        handler = function ()
        end,

        copy = { 8288, 8289, 11675, 27217, 47855 },
    },


    -- Summons an Eye of Kilrogg and binds your vision to it.  The eye moves quickly but is very fragile.
    eye_of_kilrogg = {
        id = 126,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136155,

        handler = function ()
        end,
    },


    -- Strikes fear in the enemy, causing it to run in fear for up to 10 sec.  Damage caused may interrupt the effect.  Only 1 target can be feared at a time.
    fear = {
        id = 5782,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 136183,

        handler = function ()
        end,

        copy = { 6213, 6215 },
    },


    -- Surrounds the caster with fel energy, increasing spell power by 50 plus additional spell power equal to 30% of your Spirit. In addition, you regain 2% of your maximum health every 5 sec. Only one type of Armor spell can be active on the Warlock at any time.  Lasts 30 min.
    fel_armor = {
        id = 28176,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.28,
        spendType = "mana",

        startsCombat = true,
        texture = 136156,

        handler = function ()
        end,

        copy = { 28189, 47892, 47893 },
    },


    -- Your next Imp, Voidwalker, Succubus, Incubus, Felhunter or Felguard Summon spell has its casting time reduced by 5.5 sec and its Mana cost reduced by 50%.
    fel_domination = {
        id = 18708,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "fel_domination",
        startsCombat = true,
        texture = 136082,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- You send a ghostly soul into the target, dealing 405 to 473 Shadow damage and increasing all damage done by your Shadow damage-over-time effects on the target by 20% for 12 sec. When the Haunt spell ends or is dispelled, the soul returns to you, healing you for 100% of the damage it did to the target.
    haunt = {
        id = 48181,
        cast = 1.5,
        cooldown = 8,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "haunt",
        startsCombat = true,
        texture = 236298,

        handler = function ()
        end,
    },


    -- Gives 12 health to the caster's pet every second for 10 sec as long as the caster channels.
    health_funnel = {
        id = 755,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "health",

        startsCombat = true,
        texture = 136168,

        handler = function ()
        end,

        copy = { 3698, 3699, 3700, 11693, 11694, 11695, 27259, 47856 },
    },


    -- Ignites the area surrounding the caster, causing 87 Fire damage to herself and 87 Fire damage to all nearby enemies every 1 sec.  Lasts 15 sec.
    hellfire = {
        id = 1949,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.64,
        spendType = "mana",

        startsCombat = true,
        texture = 135818,

        handler = function ()
        end,

        copy = { 11683, 11684, 27213, 47823 },
    },


    -- Howl, causing 5 enemies within 10 yds to flee in terror for 6 sec.  Damage caused may interrupt the effect.
    howl_of_terror = {
        id = 5484,
        cast = 1.5,
        cooldown = function() return glyph.howl_of_terror.enabled and 32 or 40 end,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136147,

        handler = function ()
        end,

        copy = { 17928 },
    },


    -- Burns the enemy for 10 Fire damage and then an additional 20 Fire damage over 15 sec.
    immolate = {
        id = 348,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = true,
        texture = 135817,

        handler = function ()
        end,

        copy = { 707, 1094, 2941, 11665, 11667, 11668, 25309, 27215, 47810, 47811 },
    },


    -- Deals 416 to 480 Fire damage to your target and an additional 104 to 120 Fire damage if the target is affected by an Immolate spell.
    incinerate = {
        id = 29722,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = true,
        texture = 135789,

        handler = function ()
        end,

        copy = { 32231, 47837, 47838 },
    },


    -- Converts 286 health into 40 mana.  Spell power increases the amount of mana returned.
    life_tap = {
        id = 1454,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "health",

        startsCombat = true,
        texture = 136126,

        handler = function ()
        end,

        copy = { 1455, 1456, 11687, 11688, 11689, 27222, 57946 },
    },


    -- Calls down a fiery rain to burn enemies in the area of effect for 246 Fire damage over 8 sec.
    rain_of_fire = {
        id = 5740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.57,
        spendType = "mana",

        startsCombat = true,
        texture = 136186,

        handler = function ()
        end,

        copy = { 6219, 11677, 11678, 27212, 47819, 47820 },
    },


    -- Begins a ritual that creates a Soulwell.  Raid members can click the Soulwell to acquire a Master Healthstone.  The Soulwell lasts for 3 min or 25 charges.  Requires the caster and 2 additional party members to complete the ritual.  In order to participate, all players must right-click the soul portal and not move until the ritual is complete.
    ritual_of_souls = {
        id = 29893,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = function() return 0.8 * ( glyph.souls.enabled and 0.3 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136194,

        toggle = "cooldowns",

        handler = function ()
        end,

        copy = { 58887 },
    },


    -- Begins a ritual that creates a summoning portal.  The summoning portal can be used by 2 party or raid members to summon a targeted party or raid member.  The ritual portal requires the caster and 2 additional party or raid members to complete.  In order to participate, all players must be out of combat and right-click the portal and not move until the ritual is complete.
    ritual_of_summoning = {
        id = 698,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136223,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Inflict searing pain on the enemy target, causing 38 to 47 Fire damage.  Causes a high amount of threat.
    searing_pain = {
        id = 5676,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135827,

        handler = function ()
        end,

        copy = { 17919, 17920, 17921, 17922, 17923, 27210, 30459, 47814, 47815 },
    },


    -- Imbeds a demon seed in the enemy target, causing 1044 Shadow damage over 18 sec.  When the target takes 1044 total damage or dies, the seed will inflict 1110 to 1290 Shadow damage to all enemies within 15 yards of the target.  Only one Corruption spell per Warlock can be active on any one target.
    seed_of_corruption = {
        id = 27243,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.34,
        spendType = "mana",

        startsCombat = true,
        texture = 136193,

        handler = function ()
        end,

        copy = { 47835, 47836 },
    },


    -- Shows the location of all nearby demons on the minimap until cancelled.  Only one form of tracking can be active at a time.
    sense_demons = {
        id = 5500,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 136172,

        handler = function ()
        end,
    },


    -- Sends a shadowy bolt at the enemy, causing 13 to 18 Shadow damage.
    shadow_bolt = {
        id = 686,
        cast = function() return buff.shadow_trance.up and 0 or 1.7 end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.1 * ( glyph.shadow_bolt.enabled and 0.9 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136197,

        handler = function ()
            removeBuff( "shadow_trance" )
        end,

        copy = { 695, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307, 27209, 47808, 47809 },
    },


    -- Absorbs 290 shadow damage.  Lasts 30 sec.
    shadow_ward = {
        id = 6229,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 136121,

        handler = function ()
        end,

        copy = { 11739, 11740, 28610, 47890, 47891 },
    },


    -- Instantly blasts the target for 91 to 104 Shadow damage.  If the target dies within 5 sec of Shadowburn, and yields experience or honor, the caster gains a Soul Shard.
    shadowburn = {
        id = 17877,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        talent = "shadowburn",
        startsCombat = true,
        texture = 136191,

        handler = function ()
        end,
    },


    -- Targets in a cone in front of the caster take 530 to 578 Shadow damage and an additional 544 Fire damage over 8 sec.
    shadowflame = {
        id = 47897,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = true,
        texture = 236302,

        handler = function ()
        end,

        copy = { 61290 },
    },


    -- Shadowfury is unleashed, causing 357 to 422 Shadow damage and stunning all enemies within 8 yds for 3 sec.
    shadowfury = {
        id = 30283,
        cast = 0,
        cooldown = 20,
        gcd = 500,

        spend = 0.27,
        spendType = "mana",

        talent = "shadowfury",
        startsCombat = true,
        texture = 136201,

        handler = function ()
        end,
    },


    -- Burn the enemy's soul, causing 640 to 801 Fire damage.
    soul_fire = {
        id = 6353,
        cast = 6,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 135808,

        handler = function ()
        end,

        copy = { 17924, 27211, 30545, 47824 },
    },


    -- When active, 20% of all damage taken by the caster is taken by your Imp, Voidwalker, Succubus, Felhunter, Felguard, or subjugated demon instead.  That damage cannot be prevented. Lasts as long as the demon is active and controlled.
    soul_link = {
        id = 19028,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        talent = "soul_link",
        startsCombat = true,
        texture = 136160,

        handler = function ()
        end,
    },


    -- Reduces threat by 50% for all enemies within 50 yards.
    soulshatter = {
        id = 29858,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 573,
        spendType = "health",

        startsCombat = true,
        texture = 135728,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Subjugates the target demon, up to level 45, forcing it to do your bidding.  While subjugated, the time between the demon's attacks is increased by 30% and its casting speed is slowed by 20%.  Lasts up to 5 min.
    subjugate_demon = {
        id = 1098,
        cast = function() return glyph.subjugate_demon.enabled and 1.5 or 3 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.27,
        spendType = "mana",

        startsCombat = true,
        texture = 136154,

        handler = function ()
        end,

        copy = { 11725, 11726, 61191 },
    },


    -- Summons a Felguard under the command of the Warlock.
    summon_felguard = {
        id = 30146,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        talent = "summon_felguard",
        startsCombat = true,
        texture = 136216,

        handler = function ()
        end,
    },


    -- Summons a Felhunter under the command of the Warlock.
    summon_felhunter = {
        id = 691,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        startsCombat = true,
        texture = 136217,

        handler = function ()
        end,
    },


    -- Summons an Imp under the command of the Warlock.
    summon_imp = {
        id = 688,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.64,
        spendType = "mana",

        startsCombat = true,
        texture = 136218,

        handler = function ()
        end,
    },


    -- Summons an Incubus under the command of the Warlock.
    summon_incubus = {
        id = 713,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        startsCombat = true,
        texture = 4352492,

        handler = function ()
        end,
    },


    -- Summons a Succubus under the command of the Warlock.
    summon_succubus = {
        id = 712,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        startsCombat = true,
        texture = 136220,

        handler = function ()
        end,
    },


    -- Summons a Voidwalker under the command of the Warlock.
    summon_voidwalker = {
        id = 697,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        startsCombat = true,
        texture = 136221,

        handler = function ()
        end,
    },


    -- Allows the target to breathe underwater for 10 min.
    unending_breath = {
        id = 5697,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 136148,

        handler = function ()
        end,
    },


    -- Shadow energy slowly destroys the target, causing 550 damage over 15 sec.  In addition, if the Unstable Affliction is dispelled it will cause 990 damage to the dispeller and silence them for 5 sec. Only one Unstable Affliction or Immolate per Warlock can be active on any one target.
    unstable_affliction = {
        id = 30108,
        cast = function() return glyph.unstable_affliction.enabled and 1.3 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "unstable_affliction",
        startsCombat = true,
        texture = 136228,

        handler = function ()
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 687,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    -- package = "",
    -- package1 = "",
    -- package2 = "",
    -- package3 = "",
} )