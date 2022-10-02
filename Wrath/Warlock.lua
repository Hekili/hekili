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
        id = 18647,
        duration = 30,
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
        id = 47813,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
        copy = { 172, 6222, 6223, 7648, 11671, 11672, 25311, 27216, 47812, 47813 },
    },
    -- $o1 Shadow damage over $d.
    curse_of_agony = {
        id = 47864,
        duration = function() return glyph.curse_of_agony.enabled and 28 or 24 end,
        tick_time = 2,
        max_stack = 1,
        copy = { 980, 1014, 6217, 11711, 11712, 11713, 27218, 47863, 47864 },
    },
    -- Causes $s1 Shadow damage after $d.
    curse_of_doom = {
        id = 47867,
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
        shared = "target",
    },
    -- Reduces Arcane, Fire, Frost, Nature and Shadow resistances by $s1.  Increases magic damage taken by $s2%.
    curse_of_the_elements = {
        id = 47865,
        duration = 300,
        max_stack = 1,
        copy = { 1490, 11721, 11722, 27228, 47865 },
        shared = "target",
    },
    -- Speaking Demonic increasing casting time by $s1%.
    curse_of_tongues = {
        id = 11719,
        duration = 30,
        max_stack = 1,
        copy = { 1714, 11719 },
        shared = "target",
    },
    -- Melee attack power reduced by $s1, and armor is reduced by $s2%.
    curse_of_weakness = {
        id = 50511,
        duration = 120,
        max_stack = 1,
        copy = { 702, 1108, 6205, 7646, 11707, 11708, 27224, 30909, 50511 },
        shared = "target",
    },
    -- Horrified.
    death_coil = {
        id = 47860,
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
        id = 47889,
        duration = 1800,
        max_stack = 1,
        copy = { 706, 1086, 11733, 11734, 11735, 27260, 47793, 47889 },
    },
    -- Stunned.
    demon_charge = {
        id = 60995,
        duration = 3,
        max_stack = 1,
    },
    -- Increases armor by $s1, and amount of health generated through spells and effects by $s2%
    demon_skin = {
        id = 696,
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

    -- Detect lesser invisibility.
    detect_invisibility = {
        id = 132,
        duration = 600,
        max_stack = 1,
    },
    -- Drains $s1 health every $t1 sec to the caster.
    drain_life = {
        id = 47857,
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
        id = 47855,
        duration = 15,
        max_stack = 1,
        copy = { 1120, 8288, 8289, 11675, 27217, 47855 },
    },
    -- Increases speed by $s2%.
    dreadsteed = {
        id = 23161,
        duration = 3600,
        max_stack = 1,
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
        id = 6215,
        duration = 20,
        max_stack = 1,
        copy = { 5782, 6213, 6215, 65809 },
    },
    -- Increases spell power by $s3 plus additional spell power equal to $s1% of your Spirit. Also regenerate $s2% of maximum health every 5 sec.
    fel_armor = {
        id = 47893,
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
    -- Increases speed by $s2%.
    felsteed = {
        id = 5784,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken from Shadow damage-over-time effects increased by $s3%.
    haunt = {
        id = 59164,
        duration = 12,
        max_stack = 1,
        copy = { 48181, 59161, 59163, 59164 },
    },
    -- Transferring Life.
    health_funnel = {
        id = 47856,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 755, 3698, 3699, 3700, 11693, 11694, 11695, 27259, 47856 },
    },
    -- Damages self and all nearby enemies.
    hellfire = {
        id = 47823,
        duration = 15,
        tick_time = 1,
        max_stack = 1,
        copy = { 1949, 11683, 11684, 27213, 47823 },
    },
    -- Fleeing in terror.
    howl_of_terror = {
        id = 17928,
        duration = 8,
        max_stack = 1,
        copy = { 5484, 17928, 50577 },
    },
    -- $s1 Fire damage every $t1 seconds.
    immolate = {
        id = 47811,
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
    -- Stunned.
    inferno_effect = {
        id = 22703,
        duration = 2,
        max_stack = 1,
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
    -- $47818s1 Fire damage every $47818t1 seconds.
    rain_of_fire = {
        id = 47820,
        duration = 8,
        max_stack = 1,
        copy = { 5740, 6219, 11677, 11678, 19474, 27212, 39273, 47819, 47820 },
    },
    ritual_of_doom = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=18540)
        id = 18540,
        duration = 60,
        max_stack = 1,
    },
    ritual_of_souls = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=58887)
        id = 58887,
        duration = 60,
        max_stack = 1,
        copy = { 58887, 29893 },
    },
    ritual_of_summoning = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=698)
        id = 698,
        duration = 120,
        max_stack = 1,
    },
    -- Causes $s1 Shadow damage every $t1 sec.  After taking $s2 total damage or dying, Seed of Corruption deals $47834s1 Shadow damage to the caster's enemies within $47834a1 yards.
    seed_of_corruption = {
        id = 47836,
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
        id = 47891,
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
        id = 47847,
        duration = 3,
        max_stack = 1,
        copy = { 30283, 30413, 30414, 47846, 47847 },
    },
    -- Enslaved.
    subjugate_demon = {
        id = 61191,
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
        id = 47843,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        copy = { 30108, 30404, 30405, 43522, 47841, 47843, 65812 },
    },

    my_curse = {
        alias = { "curse_of_the_elements", "curse_of_doom", "curse_of_agony", "curse_of_weakness", "curse_of_tongues", "curse_of_exhaustion" },
        aliasMode = "first",
        aliasType = "debuff",
    }
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


spec:RegisterPet( "imp", 416, "summon_imp", 3600 )
spec:RegisterPet( "voidwalker", 1860, "summon_voidwalker", 3600 )
spec:RegisterPet( "felhunter", 417, "summon_felhunter", 3600 )
spec:RegisterPet( "succubus", 1863, "summon_succubus", 3600 )
spec:RegisterPet( "incubus", 185317, "summon_incubus", 3600 )
spec:RegisterPet( "felguard", 17252, "summon_felguard", 3600 )

local cataclysm_reduction = {
    [0] = 1,
    [1] = 0.96,
    [2] = 0.93,
    [3] = 0.9
}

local mod_cataclysm = setfenv( function( base )
    return base * cataclysm_reduction[ talent.cataclysm.rank ]
end, state )

local aliasesSet = {}

spec:RegisterHook( "reset_precast", function()
    class.abilities.solo_curse = class.abilities[ settings.solo_curse or "curse_of_agony" ]
    class.abilities.group_curse = class.abilities[ settings.group_curse or "curse_of_the_elements" ]

    if not aliasesSet.solo_curse then
        class.abilityList.solo_curse = "|cff00ccff[Solo Curse]|r"
        aliasesSet.solo_curse = true
    end

    if not aliasesSet.group_curse then
        class.abilityList.group_curse = "|cff00ccff[Group Curse]|r"
        aliasesSet.group_curse = true
    end

    soul_shards = nil
end )

spec:RegisterStateExpr( "soul_shards", function()
    return GetItemCount( 6265 )
end )

spec:RegisterStateExpr( "curse_grouped", function()
    if settings.group_type == "party" and IsInGroup() then return true end
    if settings.group_type == "raid" and IsInRaid() then return true end
    return false
end )



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

        startsCombat = false,
        texture = 136135,

        handler = function( rank )
            applyDebuff( "target", "banish" )
        end,

        copy = { 18647 },
    },


    -- Sends a bolt of chaotic fire at the enemy, dealing 864 to 1089 Fire damage. Chaos Bolt cannot be resisted, and pierces through all absorption effects.
    chaos_bolt = {
        id = 50796,
        cast = 2.5,
        cooldown = function() return ( glyph.chaos_bolt.enabled and 10 or 12 ) - 0.1 * talent.bane.rank end,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.07 ) end,
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

        spend = function() return mod_cataclysm( 0.16 ) end,
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

        handler = function( rank )
            applyDebuff( "target", "corruption" )
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

        startsCombat = false,
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

        startsCombat = false,
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

        startsCombat = false,
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

        startsCombat = false,
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
            applyDebuff( "target", "curse_of_agony" )
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

        usable = function() return target.time_to_die > 65, "target must survive long enough for curse_of_doom to expire" end,

        handler = function( rank )
            applyDebuff( "target", "curse_of_doom" )
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
            applyDebuff( "target", "curse_of_exhaustion" )
        end
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
            applyDebuff( "target", "curse_of_the_elements" )
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
            applyDebuff( "target", "curse_of_tongues" )
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
            applyBuff( "curse_of_weakness" )
            applyDebuff( "target", "curse_of_weakness" )
        end,

        copy = { 1108, 6205, 7646, 11707, 11708, 27224, 30909, 50511 },
    },


    -- Drains 305 of your summoned demon's Mana, returning 100% to you.
    dark_pact = {
        id = 59092,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "dark_pact",
        startsCombat = false,
        texture = 136141,

        pet_cost = {
            [18220] = 305,
            [18937] = 440,
            [18938] = 545,
            [27265] = 700,
            [59092] = 1200
        },

        usable = function() return pet.mana_current > 150 + ( class.abilities.dark_pact.pet_cost[ class.abilities.dark_pact.id ] or 1200 ), "requires pet mana" end,

        handler = function()
            gain( class.abilities.dark_pact.pet_cost[ class.abilities.dark_pact.id ] or 1200, "mana" )
        end,

        copy = { 18220, 18937, 18938, 27265 }
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
            applyDebuff( "target", "death_coil" )
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

        startsCombat = false,
        texture = 136185,

        handler = function ()
            applyBuff( "demon_armor" )
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

        startsCombat = false,
        texture = 136185,

        handler = function ()
            applyDebuff( "target", "demon_skin" )
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
        startsCombat = false,
        texture = 236292,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "demonic_empowerment" )
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

        startsCombat = false,
        texture = 136153,

        handler = function ()
            applyBuff( "detect_invisibility" )
        end
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

        aura = "drain_life",

        start = function( rank )
            applyDebuff( "target", "drain_life" )
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

        aura = "drain_mana",

        start = function( rank )
            applyDebuff( "target", "drain_mana" )
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

        aura = "drain_soul",

        start = function( rank )
            applyDebuff( "target", "drain_soul" )
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

        startsCombat = false,
        texture = 136155,

        handler = function ()
            applyBuff( "eye_of_kilrogg" )
        end
    },


    -- Strikes fear in the enemy, causing it to run in fear for up to 10 sec.  Damage caused may interrupt the effect.  Only 1 target can be feared at a time.
    fear = {
        id = 6215,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 136183,

        handler = function()
            applyDebuff( "target", "fear" )
        end,

        copy = { 5782, 6213 },
    },


    -- Surrounds the caster with fel energy, increasing spell power by 50 plus additional spell power equal to 30% of your Spirit. In addition, you regain 2% of your maximum health every 5 sec. Only one type of Armor spell can be active on the Warlock at any time.  Lasts 30 min.
    fel_armor = {
        id = 47893,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.28,
        spendType = "mana",

        startsCombat = true,
        texture = 136156,

        handler = function ()
            applyBuff( "fel_armor" )
        end,

        copy = { 28176, 28189, 47892 },
    },


    -- Your next Imp, Voidwalker, Succubus, Incubus, Felhunter or Felguard Summon spell has its casting time reduced by 5.5 sec and its Mana cost reduced by 50%.
    fel_domination = {
        id = 18708,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "fel_domination",
        startsCombat = false,
        texture = 136082,

        usable = function() return not pet.alive, "not used with an active pet" end,

        handler = function ()
            applyBuff( "fel_domination" )
        end
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
            applyDebuff( "target", "haunt" )
        end,
    },


    -- Gives 12 health to the caster's pet every second for 10 sec as long as the caster channels.
    health_funnel = {
        id = 47856,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            return ability.health_cost[ ability.id ] or 520
        end,
        spendType = "health",

        health_cost = {
            [755]  = 12,
            [3698] = 24,
            [3699] = 43,
            [3700] = 64,
            [11693] = 89,
            [11694] = 119,
            [11695] = 153,
            [27259] = 188,
            [47856] = 520,
        },

        startsCombat = false,
        texture = 136168,
        aura = "health_funnel",

        start = function( rank )
            applyBuff( "health_funnel" )
        end,

        copy = { 755, 3698, 3699, 3700, 11693, 11694, 11695, 27259 },
    },


    -- Ignites the area surrounding the caster, causing 87 Fire damage to herself and 87 Fire damage to all nearby enemies every 1 sec.  Lasts 15 sec.
    hellfire = {
        id = 47823,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.64 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135818,

        aura = "hellfire",

        start = function( rank )
            applyBuff( "hellfire" )
        end,

        copy = { 1949, 11683, 11684, 27213 },
    },


    -- Howl, causing 5 enemies within 10 yds to flee in terror for 6 sec.  Damage caused may interrupt the effect.
    howl_of_terror = {
        id = 17928,
        cast = 1.5,
        cooldown = function() return glyph.howl_of_terror.enabled and 32 or 40 end,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136147,

        handler = function( rank )
            applyDebuff( "target", "howl_of_terror" )
        end,

        copy = { 5484 },
    },


    -- Burns the enemy for 10 Fire damage and then an additional 20 Fire damage over 15 sec.
    immolate = {
        id = 348,
        cast = function() return 2 - 0.1 * talent.bane.rank end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.17 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135817,

        handler = function( rank )
            applyDebuff( "target", "immolate" )
        end,

        copy = { 707, 1094, 2941, 11665, 11667, 11668, 25309, 27215, 47810, 47811 },
    },


    -- Deals 416 to 480 Fire damage to your target and an additional 104 to 120 Fire damage if the target is affected by an Immolate spell.
    incinerate = {
        id = 47838,
        cast = function()
            if buff.backlash.up then return 0 end
            return 2.5 * ( 1 - ( 0.02 * talent.emberstorm.rank ) )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.14 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135789,

        handler = function ()
            removeBuff( "backlash" )
            applyDebuff( "target", "incinerate" )
        end,

        copy = { 29722, 32231, 47837 },
    },


    -- Converts 286 health into 40 mana.  Spell power increases the amount of mana returned.
    life_tap = {
        id = 57946,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if ability.id == 57946 then return 2000 + stat.spirit * 1.5 end
            if ability.id == 27222 then return 1164 + stat.spirit * 1.5 end
            if ability.id == 11689 then return  867 + stat.spirit * 1.5 end
            if ability.id == 11688 then return  346 + stat.spirit * 1.5 end
            if ability.id == 11687 then return  249 + stat.spirit * 1.5 end
            if ability.id ==  1456 then return  159 + stat.spirit * 1.5 end
            if ability.id ==  1455 then return   86 + stat.spirit * 1.5 end
            if ability.id ==  1454 then return   41 + stat.spirit * 1.5 end
            return 2000 + stat.spirit * 1.5
        end,
        spendType = "health",

        startsCombat = false,
        texture = 136126,

        handler = function ()
            if ability.id == 57946 then gain( 2000 + stat.spell_power * 0.5 ); return end
            if ability.id == 27222 then gain( 1164 + stat.spell_power * 0.5 ); return end
            if ability.id == 11689 then gain(  867 + stat.spell_power * 0.5 ); return end
            if ability.id == 11688 then gain(  346 + stat.spell_power * 0.5 ); return end
            if ability.id == 11687 then gain(  249 + stat.spell_power * 0.5 ); return end
            if ability.id ==  1456 then gain(   86 + stat.spell_power * 0.5 ); return end
            if ability.id ==  1455 then gain(   41 + stat.spell_power * 0.5 ); return end
            if ability.id ==  1454 then gain( 2000 + stat.spell_power * 0.5 ); return end
            gain( 2000 + stat.spell_power * 0.5 )
        end,

        copy = { 1454, 1455, 1456, 11687, 11688, 11689, 27222 },
    },


    -- Calls down a fiery rain to burn enemies in the area of effect for 246 Fire damage over 8 sec.
    rain_of_fire = {
        id = 5740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.57 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136186,

        aura = "rain_of_fire",

        start = function( rank )
            applyBuff( "rain_of_fire" )
        end,

        copy = { 6219, 11677, 11678, 27212, 47819, 47820 },
    },


    --[[ Begins a ritual that creates a Soulwell.  Raid members can click the Soulwell to acquire a Master Healthstone.  The Soulwell lasts for 3 min or 25 charges.  Requires the caster and 2 additional party members to complete the ritual.  In order to participate, all players must right-click the soul portal and not move until the ritual is complete.
    ritual_of_souls = {
        id = 29893,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = function() return 0.8 * ( glyph.souls.enabled and 0.3 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136194,

        handler = function ()
        end,

        copy = { 58887 },
    }, ]]


    --[[ Begins a ritual that creates a summoning portal.  The summoning portal can be used by 2 party or raid members to summon a targeted party or raid member.  The ritual portal requires the caster and 2 additional party or raid members to complete.  In order to participate, all players must be out of combat and right-click the portal and not move until the ritual is complete.
    ritual_of_summoning = {
        id = 698,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136223,

        handler = function ()
        end,
    }, ]]


    -- Inflict searing pain on the enemy target, causing 38 to 47 Fire damage.  Causes a high amount of threat.
    searing_pain = {
        id = 5676,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.08 ) end,
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

        cycle = "seed_of_corruption",

        handler = function()
            applyDebuff( "target", "seed_of_corruption" )
        end,

        copy = { 47835, 47836 },
    },


    --[[ Shows the location of all nearby demons on the minimap until cancelled.  Only one form of tracking can be active at a time.
    sense_demons = {
        id = 5500,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 136172,

        handler = function ()
        end,
    }, ]]


    -- Sends a shadowy bolt at the enemy, causing 13 to 18 Shadow damage.
    shadow_bolt = {
        id = 47809,
        cast = function()
            if buff.backlash.up then return 0 end
            if buff.shadow_trance.up then return 0 end
            return 1.7 - 0.1 * talent.bane.rank
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.1 ) * ( glyph.shadow_bolt.enabled and 0.9 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136197,

        handler = function ()
            removeBuff( "backlash" )
            removeBuff( "shadow_trance" )
        end,

        copy = { 686, 695, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307, 27209, 47808 },
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
            applyBuff( "shadow_ward" )
        end,

        copy = { 11739, 11740, 28610, 47890, 47891 },
    },


    -- Instantly blasts the target for 91 to 104 Shadow damage.  If the target dies within 5 sec of Shadowburn, and yields experience or honor, the caster gains a Soul Shard.
    shadowburn = {
        id = 47827,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.2 ) end,
        spendType = "mana",

        talent = "shadowburn",
        startsCombat = true,
        texture = 136191,

        usable = function() return soul_shards > 0, "requires a soul_shard" end,

        handler = function ()
            applyDebuff( "target", "shadowburn" )
            soul_shards = max( 0, soul_shards - 1 )
        end,

        copy = { 17877, 18867, 18868, 18869, 18870, 18871, 27263, 30546, 47826 }
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
            applyDebuff( "target", "shadowflame" )
        end,

        copy = { 61290 },
    },


    -- Shadowfury is unleashed, causing 357 to 422 Shadow damage and stunning all enemies within 8 yds for 3 sec.
    shadowfury = {
        id = 30283,
        cast = 0,
        cooldown = 20,
        gcd = 500,

        spend = function() return mod_cataclysm( 0.27 ) end,
        spendType = "mana",

        talent = "shadowfury",
        startsCombat = true,
        texture = 136201,

        handler = function ()
            applyDebuff( "target", "shadowfury" )
        end,
    },


    -- Burn the enemy's soul, causing 640 to 801 Fire damage.
    soul_fire = {
        id = 47824,
        cast = function() return 6 - 0.4 * talent.bane.rank end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.09 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135808,

        usable = function() return soul_shards > 0, "requires a soul_shard" end,

        handler = function( rank )
            soul_shards = max( 0, soul_shards - 1 )
        end,

        copy = { 6353, 17924, 27211, 30545 },
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
        startsCombat = false,
        texture = 136160,

        usable = function() return pet.alive, "requires a pet" end,

        handler = function()
            applyBuff( "soul_link" )
        end
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

        usable = function() return soul_shards > 0, "requires a soul_shard" end,

        handler = function()
            soul_shards = max( 0, soul_shards - 1 )
        end
    },


    -- Subjugates the target demon, up to level 45, forcing it to do your bidding.  While subjugated, the time between the demon's attacks is increased by 30% and its casting speed is slowed by 20%.  Lasts up to 5 min.
    subjugate_demon = {
        id = 61191,
        cast = function() return glyph.subjugate_demon.enabled and 1.5 or 3 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.27,
        spendType = "mana",

        startsCombat = true,
        texture = 136154,

        usable = function() return not pet.exists, "cannot have a pet" end,

        handler = function( rank )
            applyDebuff( "target", "enslave_demon" )
            summonPet( "controlled_demon" )
        end,

        copy = { 1098, 11725, 11726 },
    },


    -- Summons a Felguard under the command of the Warlock.
    summon_felguard = {
        id = 30146,
        cast = function() return 10 - ( 2 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.8 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.2 * talent.master_summoner.rank ) end,
        spendType = "mana",

        talent = "summon_felguard",
        startsCombat = false,
        texture = 136216,

        usable = function() return soul_shards > 0, "requires a soul_shard" end,

        handler = function()
            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            dismissPet( "succubus" )
            summonPet( "felguard" )
            soul_shards = max( 0, soul_shards - 1 )
        end
    },


    -- Summons a Felhunter under the command of the Warlock.
    summon_felhunter = {
        id = 691,
        cast = function() return 10 - ( 2 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.8 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.2 * talent.master_summoner.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136217,

        usable = function() return soul_shards > 0, "requires a soul_shard" end,

        handler = function()
            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            summonPet( "felhunter" )
            dismissPet( "succubus" )
            dismissPet( "felguard" )
            soul_shards = max( 0, soul_shards - 1 )
        end
    },


    -- Summons an Imp under the command of the Warlock.
    summon_imp = {
        id = 688,
        cast = function() return 10 - ( 2 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.64 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.2 * talent.master_summoner.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136218,

        handler = function()
            summonPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            dismissPet( "succubus" )
            dismissPet( "felguard" )
        end
    },


    -- Summons an Incubus under the command of the Warlock.
    summon_incubus = {
        id = 713,
        cast = function() return 10 - ( 2 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.80 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.2 * talent.master_summoner.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 4352492,

        handler = function()
            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            summonPet( "succubus" )
            dismissPet( "felguard" )
            soul_shards = max( 0, soul_shards - 1 )
        end
    },


    -- Summons a Succubus under the command of the Warlock.
    summon_succubus = {
        id = 712,
        cast = function() return 10 - ( 2 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.80 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.2 * talent.master_summoner.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136220,

        handler = function()
            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            summonPet( "succubus" )
            dismissPet( "felguard" )
            soul_shards = max( 0, soul_shards - 1 )
        end
    },


    -- Summons a Voidwalker under the command of the Warlock.
    summon_voidwalker = {
        id = 697,
        cast = function() return 10 - ( 2 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.80 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.2 * talent.master_summoner.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136221,

        usable = function() return soul_shards > 0, "requires a soul_shard" end,

        handler = function()
            dismissPet( "imp" )
            summonPet( "voidwalker" )
            dismissPet( "felhunter" )
            dismissPet( "succubus" )
            dismissPet( "felguard" )
            soul_shards = max( 0, soul_shards - 1 )
        end
    },


    -- Allows the target to breathe underwater for 10 min.
    unending_breath = {
        id = 5697,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136148,

        handler = function ()
            applyBuff( "unending_breath" )
        end
    },


    -- Shadow energy slowly destroys the target, causing 550 damage over 15 sec.  In addition, if the Unstable Affliction is dispelled it will cause 990 damage to the dispeller and silence them for 5 sec. Only one Unstable Affliction or Immolate per Warlock can be active on any one target.
    unstable_affliction = {
        id = 47843,
        cast = function() return glyph.unstable_affliction.enabled and 1.3 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "unstable_affliction",
        startsCombat = true,
        texture = 136228,

        handler = function ()
            applyDebuff( "target", "unstable_affliction" )
        end,

        copy = { 30108, 30404, 30405, 47841 }
    },
} )


local curses = {}

spec:RegisterSetting( "solo_curse", "curse_of_agony", {
    type = "select",
    name = "Preferred Curse when Solo",
    desc = "Select the Curse you'd like to use when playing solo.  It is referenced as |cff00ccff[Solo Curse]|r in your priority.",
    width = "full",
    values = function()
        table.wipe( curses )

        curses.curse_of_agony = class.abilityList.curse_of_agony
        curses.curse_of_the_elements = class.abilityList.curse_of_the_elements
        curses.curse_of_doom = class.abilityList.curse_of_doom
        curses.curse_of_exhaustion = class.abilityList.curse_of_exhaustion
        curses.curse_of_tongues = class.abilityList.curse_of_tongues
        curses.curse_of_weakness = class.abilityList.curse_of_weakness

        return curses
    end,
    set = function( _, val )
        Hekili.DB.profile.specs[ 9 ].settings.solo_curse = val
        class.abilities.solo_curse = class.abilities[ val ]
    end,
} )

spec:RegisterSetting( "group_curse", "curse_of_the_elements", {
    type = "select",
    name = "Preferred Curse when Grouped",
    desc = "Select the Curse you'd like to use when playing in a group.  It is referenced as |cff00ccff[Group Curse]|r in your priority.",
    width = "full",
    values = function()
        table.wipe( curses )

        curses.curse_of_agony = class.abilityList.curse_of_agony
        curses.curse_of_the_elements = class.abilityList.curse_of_the_elements
        curses.curse_of_doom = class.abilityList.curse_of_doom
        curses.curse_of_exhaustion = class.abilityList.curse_of_exhaustion
        curses.curse_of_tongues = class.abilityList.curse_of_tongues
        curses.curse_of_weakness = class.abilityList.curse_of_weakness

        return curses
    end,
    set = function( _, val )
        Hekili.DB.profile.specs[ 9 ].settings.group_curse = val
        class.abilities.group_curse = class.abilities[ val ]
    end,
} )

spec:RegisterSetting( "group_type", "party", {
    type = "select",
    name = "Group Type for Group Curse",
    desc = "Select the type of group that is required before the addon recommends your |cff00ccff[Group Curse]|r rather than |cff00ccff[Solo Curse]|r.\n\n" ..
        "Selecting " .. PARTY .. " will work for a 5 person group.  Selecting " .. RAID .. " will work for any larger group.\n\n" ..
        "In default priorities, |cffffd100curse_grouped|r will be |cffffd100true|r when this condition is met.  Custom priorities may ignore this setting.",
    width = "full",
    values = {
        party = PARTY,
        raid = RAID
    }
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 687,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    -- package = "",
    -- package1 = "",
    -- package2 = "",
    -- package3 = "",
} )

spec:RegisterPack( "BC Warlock", 20210601, [[dauIHaqijQEerQ0MeIprKsnkjqNsc4veHzHkULefPDPk)IiAyOsDmH0YGKEMeLMMsjUMeuBtcY3ukjJtPK6CsueZJivDpHAFOsoOefwiKQhsKIyIePInsKsgjrkQtsKcResStj0tPyQQQARePi9vjkQ9k1FfmyfDyQwmQ6XQmzLCzKnRWNjQrRQYPf9AIKzJYTL0Ub(nOHRuTCOEoHPt66qSDjY3HugVsPoVQY8vk2pLUJ2)BZYvQlIk3OgL7cXD0x0TSLcfDlTr)2P2S7NuUm1gGxP2uMDmdEs1MD)Jb9v)Vncic(O2GUlOLDcb2zzgwM)JU0e70bl7uACFLPstPeiStzKCrIxB4rsMknanFBwUsDru5g1OCxiUJ(IULTuOOrBJyNUUyzsB(LRfbA(2SiX1M))sHDMc70TZD)KYLj7eoSt)0ecStwkuHDoGy7uAMKkz5RnSuOI(FBw0WryA)VlgT)3gc48mA1O3MdNkHtVnLCC68m65JblpnHa7mIDwUDUt6lR7pNLLi7mIDwq7uZkzNX2j325Mn25iL)Pbmv9eiStUSZYYTDwG24NMqqBei1keeY6ERDru7)THaopJwn6T5WPs40BtbTZsooDEg9wKqXiNMqGDUzJDwUDQoJa6tGuRqqyqmzehVEeW5z0YolGDgXol3o3j9jqUdHhr8CwwISZi2jpYy8wufcYli8dNJ8O3cIgWoJyNf0o1Ss2zSDYTDUzJDos5FAatvpbc7Kl7SSCBNfOn(Pje0gbsTcbbbYDi8iIw7ILT)3gc48mA1O3MdNkHtVnLCC68m6TiHIronHa7mIDUt6tGChcpI45SSe1g)0ecAZIQqqEbHF4CKh1AxCl9)2qaNNrRg92C4ujC6T5h5m93B)u7Kl7CR52oJyNJu(NgWu1tGWo5YoJw424NMqqB4zq4kmqWFT2flC)VneW5z0QrVn(Pje0gbrRaCeoigJSRje0MdNkHtVnLBNAEsLaz7mID6NMLOabOAsc7Kl7e12CFhJcQJLjv0fJ2AxSq9)2qaNNrRg92C4ujC6TXpnlrbcq1Ke2jx2jQ2ze70pnlrHfuFcIwb4iCqmgzxtiWo5k2o9tZsuGaunjHDgXovhlt6dTu)LGT2oJyN)iNP)E7NANCzNBf3TXpnHG28JySrIPw7IBv)VneW5z0QrVnhovcNEB8tZsuGaunjHDYLDIQDgXo9tZsuyb1NGOvaocheJr21ecStUITt)0Sefiavts0g)0ecAd2tqaocJetT2f36(FBiGZZOvJEBoCQeo92SiEKX4v)chcwqVfenGDgXopeSGcYyiYoTAJFAcbTrgdr2dhcwqT2flt6)THaopJwn6T5WPs40BZI4rgJx9lCiyb9wq0aTXpnHG2iGmy4qWcQ1UyuU7)THaopJwn6TXpnHG241Dwo(chcwqTzrIdN7AcbTXpnHaXBrdhHPsel5HGfuaocliSY5(ogfuhltQiokNQVD4(ogfuhltQigvo5iEr8iJXR(foeSGEliAGiYyiYEe1XYK(0SsbfgwjXvHkCKcwU6mcOpVUZYXx4qWc6raNNrRnB4rgJNx3z54lCiyb9q2lqBoCQeo92iJHi72ze7Cr8iJXR(foeSGEyQ6jqyNsVDIk32ze7SG2PMvYoJTtUTZnBSZrk)tdyQ6jqyNCzNLLB7SaT2fJgT)3gc48mA1O3MdNkHtVnLCC68m65JblpnHG2iuCEAxmAB8ttiOnNZyb)0eccSuOTHLcna8k1gFmy5Pje0AxmkQ9)2qaNNrRg92C4ujC6TPKJtNNrVfvHaidk)1gHIZt7IrBJFAcbT5Cgl4NMqqGLcTnSuObGxP2SOkeazq5Vw7IrlB)VneW5z0QrVnhovcNEBk5405z0BrcfJCAcbTrO480Uy024NMqqBoNXc(PjeeyPqBdlfAa4vQnlsOyyRDXOBP)3gc48mA1O3MdNkHtVn7K(QoWd7NANCzNLLB7mIDwDG)2p1oLE7ClC3g)0ecAZYXsf29tBTlgTW9)2qaNNrRg92C4ujC6T5h5m93B)u7Kl7CRkSDgXoRoWF7NANsVDUfUTZi25iL)Pbmv9eiStUSZOfUn(Pje0gwoOG67T2fJwO(FBiGZZOvJEBoCQeo92SiEKX4v)chcwqVfenGDgXovhlt6tZkfuyyLKDYLDIk3TXpnHG2CiybfGJGldbFT2fJUv9)2qaNNrRg924NMqqBYAfYCLAZ9DmkOowMurxmABQ(2H77yuqDSmPI2GABoCQeo92uUDQ5jvcKTZi2z1b(B)u7Kl7SqC3Axm6w3)BJFAcbTr8Zxq0c8qM2gc48mA1O3ARTzhthSY7A)VlgT)3gc48mA1O3g)0ecAZGybhxH42SiXHZDnHG2ugm08pHDIii7uArm7SmWvi(1MdNkHtVn8iJXBqSGJRq8Bbrd0Axe1(FBiGZZOvJEB8ttiOnlQcbbhxH42SiXHZDnHG2ing25heXoxqG0wTZFEjYoLweZoldCfITZps5yNicYoLoufcSZYaxHy7eITtPdvHa70ivcET5WPs40BdpYy8gel44ke)wq0a2ze7KhzmElQcbbhxH43cIgO1Uyz7)THaopJwn6T5WPs40BdpYy8gel44ke)wq0a2ze7KhzmElQcbbhxH43cIgWoJyN8iJXBrviiiKkbVfenqB8ttiOnlQcbbHujO1U4w6)THaopJwn6TbU3gbPTXpnHG2uYXPZZO2uYziuBuNra9HaeQZZOGpgS80ecEeW5z0Yo3SXovNra9jY9FqqGLd6raNNrl7CZg7uDgb0Nx3z54lCiyb9iGZZOvBk54aWRuB8XGLNMqqRDXc3)BdbCEgTA0BdCVncsBJFAcbTPKJtNNrTPKZqO2OoJa6tGuRqqyqmzehVEeW5z0Yo3SXovNra9jGiSalbs9iGZZOLDUzJDQoJa6R6cLWHfvHaidkNc9raNNrl7CZg7uDgb03IQqqEb1pnpXJaopJwTPKJdaVsTzrviaYGYFT2flu)VneW5z0QrVnW92iiTn(Pje0MsooDEg1MsodHAJ6mcOpXpFbrJhbdEeW5z0Yo3SXovNra9DqWG5YyxPhbCEgTAtjhhaELAZIekg50ecAT12SOkeazq5V(FxmA)VneW5z0QrVn(Pje0MSwHmxP2CFhJcQJLjv0fJ2MQVD4(ogfuhltQOnO2MdNkHtVnLBNAEsLaz7mIDwq7ugdr2TZnBSZQd83(P2jx2zH42olqRDru7)THaopJwn6TXpnHG2CqmgzxtiOn33XOG6yzsfDXOTP6BhUVJrb1XYKkAdQT5WPs40Bt52PMNujqU1Uyz7)TPclLa5Uy02qaNNrHkSucKB0BJFAcbTr8Zxq04rWG2qaNNrRg9wBTnlsOyy)VlgT)3gc48mA1O3g)0ecAZHGfuaoc6pkqmQsav0M77yuqDSmPIUy02u9Td33XOG6yzsfTb12C4ujC6Tzr8iJXR(foeSGEliAa7mIDkJHi7T2frT)3gc48mA1O3g)0ecAZHGfuaocy6KIrcbGeI2CFhJcQJLjv0fJ2MQVD4(ogfuhltQOnO2MdNkHtVnlIhzmE1VWHGf0BbrdyNrStzmezV1Uyz7)THaopJwn6TXpnHG2CiybfGJWccRT5(ogfuhltQOlgTnvF7W9DmkOowMurBqTnhovcNEBwepYy8QFHdblO3cIgWoJyNYyiYUDgXovhlt6tZkfuyyLKDYLDwOcBNrSZcANLBNQZiG(86olhFHdblOhbCEgTSZnBStEKX451Dwo(chcwqpKD7SaT2f3s)VneW5z0QrVn(Pje0MSwHmxP2CFhJcQJLjv0fJ2MQVD4(ogfuhltQOnO2MdNkHtVnLBNAEsLa5w7IfU)3MkSucK7IrBdbCEgfQWsjqUrVn(Pje0gXpFbrJhbdAdbCEgTA0BTlwO(FBiGZZOvJEBoCQeo92SiEKX4L1kK5k9q2TZi2zbTZkSucKTZnBSZfXJmgVSwHmxPhMQEce2P0BNOANfOn(Pje0Mdcgmxg7k1ARTXhdwEAcb9)Uy0(FBiGZZOvJEB8ttiOniaH68mk4JblpnHG2CFhJcQJLjv0fJ2MQVD4(ogfuhltQOnO2MdNkHtVnLBNAEsLa52SiXHZDnHG2y(bH6R1UiQ9)2qaNNrRg924NMqqBoigJSRje0M77yuqDSmPIUy02u9Td33XOG6yzsfTb12C4ujC6TPC7uZtQei3AxSS9)2qaNNrRg924NMqqBYAfYCLAZ9DmkOowMurxmABQ(2H77yuqDSmPI2GABoCQeo92uUDQ5jvcKBTlUL(FBiGZZOvJEB8ttiOnIC)heey5GAZ9DmkOowMurxmABQ(2H77yuqDSmPI2GABoCQeo92uUDQ5jvcKBT1wBdAogKazrB()JStPnIGcPsvH02o9ttiWorZf2jaQ25aIaw2zcSt9xkSZSUdX6ZII0OUdXkTSZcBN(PjeyNSuOINfL2SJHJKrTr6ANLbdn)tyNicYoLweZoldCfIFwu8ttiq82X0bR8UkrSKdIfCCfI5KJyEKX4niwWXvi(TGObSOiDTtPXWo)Gi25ccK2QD(Zlr2P0Iy2zzGRqSD(rkh7erq2P0HQqGDwg4keBNqSDkDOkeyNgPsWZIIFAcbI3oMoyL3vjILCrvii44keZjhX8iJXBqSGJRq8BbrdeHhzmElQcbbhxH43cIgWIIFAcbI3oMoyL3vjILCrviiiKkbCYrmpYy8gel44ke)wq0ar4rgJ3IQqqWXvi(TGObIWJmgVfvHGGqQe8wq0awu8ttiq82X0bR8UkrSKLCC68mIdWRuSpgS80ec4uYziuS6mcOpeGqDEgf8XGLNMqWJaopJwB2OoJa6tK7)GGalh0JaopJwB2OoJa6ZR7SC8foeSGEeW5z0YIIFAcbI3oMoyL3vjILSKJtNNrCaELIxufcGmO8hNsodHIvNra9jqQviimiMmIJxpc48mATzJ6mcOpbeHfyjqQhbCEgT2SrDgb0x1fkHdlQcbqguof6JaopJwB2OoJa6BrviiVG6NMN4raNNrllk(PjeiE7y6GvExLiwYsooDEgXb4vkErcfJCAcbCk5mekwDgb0N4NVGOXJGbpc48mATzJ6mcOVdcgmxg7k9iGZZOLfflk(PjeiIfi1keeY6oNCexYXPZZONpgS80ecIu(oPVSU)CwwIIuqnRum3B2ms5FAatvpbcUkl3fWIIFAcbcjILuGuRqqqGChcpIGtoIlyjhNopJElsOyKttiyZMYvNra9jqQviimiMmIJxpc48mAvGiLVt6tGChcpI45SSefHhzmElQcb5fe(HZrE0BbrdePGAwPyU3SzKY)0aMQEceCvwUlGff)0ecesel5IQqqEbHF4CKhXjhXLCC68m6TiHIronHGi7K(ei3HWJiEollrwu8ttiqirSK8miCfgi4po5i(h5m93B)uU2AUJms5FAatvpbcUIwylk(PjeiKiwsbrRaCeoigJSRjeW5(ogfuhltQiokNCexUMNujqoIFAwIceGQjj4cvlk(PjeiKiwYFeJnsmXjhX(PzjkqaQMKGluJ4NMLOWcQpbrRaCeoigJSRjeWvSFAwIceGQjjIOowM0hAP(lbBDKFKZ0FV9t5AR42IIFAcbcjILe7jiahHrIjo5i2pnlrbcq1KeCHAe)0Sefwq9jiAfGJWbXyKDnHaUI9tZsuGaunjHff)0eceselPmgIShoeSG4KJ4fXJmgV6x4qWc6TGObICiybfKXqKDAzrXpnHaHeXskGmy4qWcItoIxepYy8QFHdblO3cIgWII01o9ttiqirSKhcwqb4iSGWkN77yuqDSmPI4OCQ(2H77yuqDSmPIyu5KJ4fXJmgV6x4qWc6TGObIiJHi7ruhlt6tZkfuyyLexfQWrky5QZiG(86olhFHdblOhbCEgT2SHhzmEEDNLJVWHGf0dzVawu8ttiqirSKEDNLJVWHGfeNCelJHi7rwepYy8QFHdblOhMQEcespQChPGAwPyU3SzKY)0aMQEceCvwUlGff)0ecesel55mwWpnHGalfkhGxPyFmy5PjeWrO4804OCYrCjhNopJE(yWYttiWIIFAcbcjIL8Cgl4NMqqGLcLdWRu8IQqaKbL)4iuCEACuo5iUKJtNNrVfvHaidk)zrXpnHaHeXsEoJf8ttiiWsHYb4vkErcfd5iuCEACuo5iUKJtNNrVfjumYPjeyrXpnHaHeXsUCSuHD)uo5iEN0x1bEy)uUkl3rQoWF7Nk9BHBlk(PjeiKiwswoOG67CYr8pYz6V3(PCTvfos1b(B)uPFlChzKY)0aMQEceCfTWwu8ttiqirSKhcwqb4i4YqWhNCeViEKX4v)chcwqVfenqe1XYK(0SsbfgwjXfQCBrXpnHaHeXsM1kK5kX5(ogfuhltQiokNQVD4(ogfuhltQigvo5iUCnpPsGCKQd83(PCviUTO4NMqGqIyjf)8feTapKPwuKU2P5heQplkwu8ttiq88XGLNMqqmcqOopJc(yWYttiGZ9DmkOowMurCuovF7W9DmkOowMurmQCYrC5AEsLazlk(PjeiE(yWYttiqIyjpigJSRjeW5(ogfuhltQiokNQVD4(ogfuhltQigvo5iUCnpPsGSff)0ecepFmy5PjeirSKzTczUsCUVJrb1XYKkIJYP6BhUVJrb1XYKkIrLtoIlxZtQeiBrXpnHaXZhdwEAcbselPi3)bbbwoio33XOG6yzsfXr5u9Td33XOG6yzsfXOYjhXLR5jvcKTOyrXpnHaXBrviaYGYFselzwRqMReN77yuqDSmPI4OCQ(2H77yuqDSmPIyu5KJ4Y18KkbYrkOmgISVzt1b(B)uUke3fWIIFAcbI3IQqaKbL)KiwYdIXi7AcbCUVJrb1XYKkIJYP6BhUVJrb1XYKkIrLtoIlxZtQeiBrXpnHaXBrviaYGYFselP4NVGOXJGbCQWsjqooQfflk(PjeiElsOyOeXsEiybfGJG(JceJQeqfCUVJrb1XYKkIJYP6BhUVJrb1XYKkIrLtoIxepYy8QFHdblO3cIgiImgISBrXpnHaXBrcfdLiwYdblOaCeW0jfJecajeCUVJrb1XYKkIJYP6BhUVJrb1XYKkIrLtoIxepYy8QFHdblO3cIgiImgISBrXpnHaXBrcfdLiwYdblOaCewqyLZ9DmkOowMurCuovF7W9DmkOowMurmQCYr8I4rgJx9lCiyb9wq0arKXqK9iQJLj9PzLckmSsIRcv4ifSC1zeqFEDNLJVWHGf0JaopJwB2WJmgpVUZYXx4qWc6HSxalk(PjeiElsOyOeXsM1kK5kX5(ogfuhltQiokNQVD4(ogfuhltQigvo5iUCnpPsGSff)0eceVfjumuIyjf)8fenEemGtfwkbYXrTO4NMqG4TiHIHsel5bbdMlJDL4KJ4fXJmgVSwHmxPhYEKcwHLsG8MnlIhzmEzTczUspmv9eiKEulqBCe9he3gPzsQKLT2A3]] )