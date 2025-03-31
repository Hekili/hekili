if UnitClassBase( 'player' ) ~= 'WARLOCK' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID
local FindUnitDebuffByID = ns.FindUnitDebuffByID

local spec = Hekili:NewSpecialization( 9 )

-- Sets
spec:RegisterGear( "tier13", 78776, 78797, 78816, 78825, 78844, 76343, 76342, 76341, 76340, 76339, 78681, 78702, 78721, 78730, 78749 )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.SoulShards )

-- Talents
spec:RegisterTalents( {
    aftermath                   = { 11197, 2, 85113, 85114 },
    amplify_curse               = {  6542, 1, 18288 },
    ancient_grimoire            = { 11188, 2, 85109, 85110 },
    aura_of_foreboding          = { 11814, 2, 89604, 89605 },
    backdraft                   = { 10978, 3, 47258, 47259, 47260 },
    backlash                    = { 10958, 3, 34935, 34938, 34939 },
    bane                        = { 10938, 3, 17788, 17789, 17790 },
    bane_of_havoc               = { 10962, 1, 80240 },
    burning_embers              = { 11182, 2, 91986, 85112 },
    cataclysm                   = {   941, 3, 17778, 17779, 17780 },
    chaos_bolt                  = { 10986, 1, 50796 },
    conflagrate                 = {   968, 1, 17962 },
    contagion                   = {  6562, 5, 30060, 30061, 30062, 30063, 30064 },
    cremation                   = { 11199, 2, 85103, 85104 },
    curse_of_exhaustion         = { 11128, 1, 18223 },
    dark_arts                   = { 10992, 3, 18694, 85283, 85284 },
    deaths_embrace              = { 11142, 3, 47198, 47199, 47200 },
    decimation                  = { 11034, 2, 63156, 63158 },
    demonic_aegis               = { 11190, 2, 30143, 30144 },
    demonic_brutality           = {  3059, 3, 18705, 18706, 18707 },
    demonic_embrace             = { 10994, 3, 18697, 18698, 18699 },
    demonic_empowerment         = { 11160, 1, 47193 },
    demonic_knowledge           = {  3031, 3, 35691, 35692, 35693 },
    demonic_pact                = { 11042, 1, 47236 },
    demonic_power               = {   983, 2, 18126, 18127 },
    demonic_quickness           = {  3089, 2, 80228, 80229 },
    demonic_rebirth             = { 11713, 2, 88446, 88447 },
    demonic_resilience          = {  3027, 3, 30319, 30320, 30321 },
    demonic_tactics             = {  3033, 5, 30242, 30245, 30246, 30247, 30248 },
    designer_notes              = {  7451, 1, 80557 },
    destructive_reach           = {   964, 2, 17917, 17918 },
    doom_and_gloom              = { 11100, 2, 18827, 18829 },
    emberstorm                  = { 11181, 2, 17954, 17955 },
    empowered_corruption        = {  1764, 3, 32381, 32382, 32383 },
    empowered_imp               = { 10982, 2, 47220, 47221 },
    eradication                 = { 11134, 3, 47195, 47196, 47197 },
    everlasting_affliction      = { 11150, 3, 47201, 47202, 47203 },
    fel_concentration           = {  6540, 3, 17783, 17784, 17785 },
    fel_domination              = {  1226, 1, 18708 },
    fel_synergy                 = { 11206, 2, 47230, 47231 },
    fel_vitality                = {  3005, 3, 18731, 18743, 18744 },
    fire_and_brimstone          = { 10984, 3, 47266, 47267, 47268 },
    grim_reach                  = {  6544, 2, 18218, 18219 },
    hand_of_guldan              = { 11201, 1, 71521 },
    haunt                       = { 11152, 1, 48181 },
    impending_doom              = { 11198, 3, 85106, 85107, 85108 },
    improved_corruption         = { 11104, 3, 17810, 17811, 17812 },
    improved_demonic_tactics    = {  3037, 3, 54347, 54348, 54349 },
    improved_fear               = { 11114, 2, 53754, 53759 },
    improved_health_funnel      = { 10998, 2, 18703, 18704 },
    improved_howl_of_terror     = { 11140, 2, 30054, 30057 },
    improved_immolate           = { 10960, 2, 17815, 17833 },
    improved_life_tap           = { 11110, 2, 18182, 18183 },
    improved_sayaad             = {  3063, 3, 18754, 18755, 18756 },
    improved_searing_pain       = { 11196, 2, 17927, 17929 },
    improved_soul_fire          = { 10940, 2, 18119, 18120 },
    inferno                     = { 11189, 1, 85105 },
    intensity                   = {   985, 2, 18135, 18136 },
    jinx                        = { 11214, 2, 18179, 85479 },
    malediction                 = {  6568, 3, 32477, 32483, 32484 },
    mana_feed                   = { 11020, 2, 30326, 85175 },
    master_conjuror             = {  3077, 2, 18767, 18768 },
    master_demonologist         = {  3079, 5, 23785, 23822, 23823, 23824, 23825 },
    master_summoner             = { 11014, 2, 18709, 18710 },
    metamorphosis               = { 11044, 1, 59672 },
    molten_core                 = { 11024, 3, 47245, 47246, 47247 },
    molten_skin                 = {  1887, 3, 63349, 63350, 63351 },
    nemesis                     = {  3097, 3, 63117, 63121, 63123 },
    nether_protection           = { 10964, 2, 30299, 30301 },
    nether_ward                 = { 12120, 1, 91713 },
    nightfall                   = { 11122, 2, 18094, 18095 },
    pandemic                    = { 11200, 2, 85099, 85100 },
    ruin                        = {   967, 5, 17959, 59738, 59739, 59740, 59741 },
    shadow_and_flame            = { 10936, 3, 17793, 17796, 17801 },
    shadow_embrace              = { 11124, 3, 32385, 32387, 32392 },
    shadow_mastery              = {  6558, 5, 18271, 18272, 18273, 18274, 18275 },
    shadowburn                  = { 10948, 1, 17877 },
    shadowfury                  = { 10980, 1, 30283 },
    siphon_life                 = { 11420, 2, 63108, 86667 },
    soul_leech                  = { 10970, 2, 30293, 30295 },
    soul_link                   = {  3065, 1, 19028 },
    soul_siphon                 = { 11112, 2, 17804, 17805 },
    soul_swap                   = { 11366, 1, 86121 },
    soulburn_seed_of_corruption = { 11419, 1, 86664 },
    summon_felguard             = {  3095, 1, 30146 },
    unholy_power                = {  3071, 5, 18769, 18770, 18771, 18772, 18773 },
    unstable_affliction         = {  6572, 1, 30108 },
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
        max_stack = 3,
        copy = { 54274, 54276, 79617 },
    },
    backlash = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=34939)
        id = 34936,
        duration = 8,
        max_stack = 1,
    },
    -- $o1 Shadow damage over $d.
    bane_of_agony = {
        id = 980,
        duration = function() return glyph.bane_of_agony.enabled and 28 or 24 end,
        tick_time = function() return 2 * haste end,
        max_stack = 1,
        copy = { "curse_of_agony", 980, 1014, 6217, 11711, 11712, 11713, 27218, 47863, 47864 },
    },
    -- Causes $s1 Shadow damage after $d.
    bane_of_doom = {
        id = 603,
        duration = 60,
        tick_time = 15, -- Does not scale with haste
        max_stack = 1,
        copy = { "curse_of_doom", 603, 30910, 47867 },
    },
    active_havoc = {
        duration = 300,
        max_stack = 1,

        generate = function( t )
            t.duration = class.auras.bane_of_havoc.duration

            if active_dot.bane_of_havoc > 0 or debuff.bane_of_havoc.up then
                t.count = 1
                t.applied = action.bane_of_havoc.lastCast
                t.expires = t.applied + t.duration
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end
    },
    active_doom = {
        duration = 60,
        max_stack = 1,

        generate = function( t )
            t.duration = class.auras.bane_of_doom.duration

            if active_dot.bane_of_doom > 0 or debuff.bane_of_doom.up then
                t.count = 1
                t.applied = action.bane_of_doom.lastCast
                t.expires = t.applied + t.duration
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end
    },
    -- Receiving 15% of all damage done by the Warlock to other targets.
    bane_of_havoc = {
        id = 80240,
        duration = 300,
        max_stack = 1,
    },
    -- NOTE: Bane of Havoc deals damage as a different spell.
    bane_of_havoc_damage = {
        id = 85455,
        duration = 0,
        max_stack = 1,

        copy = { 85468, 85466, 101553 },

        generate = function( t )
            if debuff.bane_of_havoc.up then
                t.count = 1
                t.applied = action.bane_of_havoc.lastCast
                t.expires = t.applied + t.duration
                t.caster = "player"
            end
        end
    },
    -- Invulnerable, but unable to act.
    banish = {
        id = 710,
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
        id = 172,
        duration = function() return ( 18 * haste )	end,
        tick_time = function() return ( 3 * haste )	end,
        max_stack = 1,
    },
    -- Movement speed slowed by $s1%.
    curse_of_exhaustion = {
        id = 18223,
        duration = 30,
        max_stack = 1,
        shared = "target",
    },
    -- Critical strike chance taken from Warlock Demon abilities increased by $s1%.
    curse_of_guldan = {
        id = 86000,
        duration = 15,
        max_stack = 1,
    },
    -- Speaking Demonic increasing casting time by $s1%.
    curse_of_tongues = {
        id = 1714,
        duration = 30,
        max_stack = 1,
        shared = "target",
    },
    -- Melee attack power reduced by $s1, and armor is reduced by $s2%.
    curse_of_weakness = {
        id = 702,
        duration = 120,
        max_stack = 1,
        copy = { 702, 1108, 6205, 7646, 11707, 11708, 27224, 30909, 50511 },
        shared = "target",
    },
    -- Haste increased by $w1%.
    dark_intent = {
        id = 85767,
        duration = 1800,
        max_stack = 1,
    },
    -- Periodic damage and healing increased by 3%.
    dark_intent_buff = {
        id = 94310,
        duration = 7,
        max_stack = 3
    },
    -- Horrified.
    death_coil = {
        id = 6789,
        duration = function() return glyph.death_coil.enabled and 3.5 or 3 end,
        max_stack = 1,
    },
    -- Your Soul Fire cast time is reduced by $s1%, and costs no shard.
    decimation = {
        id = 63167,
        duration = 10,
        max_stack = 1,
    },
    -- Increases armor by $s1, and amount of health generated through spells and effects by $s2%
    demon_armor = {
        id = 687,
        duration = 3600,
        max_stack = 1,
    },
    -- Stunned.
    demon_charge = {
        id = 60995,
        duration = 3,
        max_stack = 1,
    },
    -- Stunned.
    demon_leap = {
        id = 54786,
        duration = 2,
        max_stack = 1,
    },
    -- Increases the caster's armor and speeds its health regeneration for 30 min.
    demon_skin = {
        id = 20798,
        duration = 1800,
        max_stack = 1,
    },
    demon_soul = {
        alias = {
            "demon_soul_imp",
            "demon_soul_voidwalker",
            "demon_soul_felhunter",
            "demon_soul_succubus",
            "demon_soul_felguard"
        },
        aliasMode = "latest",
        aliasType = "buff",
    },
    -- Critical strike chance of your cast time Destruction spells increased by $s1%.
    demon_soul_imp = {
        id = 79459,
        duration = 20,
        max_stack = 1,
    },
    -- All threat generated by you is redirected to your Voidwalker for 15 sec.
    demon_soul_voidwalker = {
        id = 79464,
        duration = 15,
        max_stack = 1
    },
    -- Periodic shadow damage increased by 20%.
    demon_soul_felhunter = {
        id = 79460,
        duration = 20,
        max_stack = 1
    },
    -- Shadow Bolt damage increased by 10%.
    demon_soul_succubus = {
        id = 79463,
        duration = 20,
        max_stack = 1
    },
    -- Haste increased by 15% and damage increased by 10%.
    demon_soul_felguard = {
        id = 79462,
        duration = 20,
        max_stack = 1
    },
    -- Demonic Circle Summoned.
    demonic_circle_summon = {
        id = 48018,
        duration = 360,
        tick_time = 1,
        max_stack = 1,
    },
    -- Spell Power increased by $s1%.
    demonic_pact = {
        id = 53646,
        duration = 3600,
        max_stack = 1,
    },
    -- Imp, Voidwalker, Succubus, Felhunter and Felguard casting time reduced by $*1;w1%.
    demonic_rebirth = {
        id = 88448,
        duration = 10,
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
        id = 89420,
        duration = function () return ( 1.5 * haste ) end,
        tick_time = function () return ( 0.5 * haste ) end,
        max_stack = 1,
    },
    -- $s2 Shadow damage every $t2 seconds.
    drain_soul = {
        id = 1120,
        duration = function () return ( 15 * haste ) end,
		tick_time = function() return ( 3 * haste ) end,
        max_stack = 1,
    },
    -- Increases speed by $s2%.
    dreadsteed = {
        id = 23161,
        duration = 3600,
        max_stack = 1,
    },
    -- Soul Fire is instant cast.
    empowered_imp = {
        id = 47283,
        duration = 8,
        max_stack = 1,
    },
    -- Spell casting speed increased by $s1%.
    eradication = {
        id = 64371,
        duration = 10,
        max_stack = 1,
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
        duration = 20,
        max_stack = 1,
    },
    -- Increases spell power by $s3 plus additional spell power equal to $s1% of your Spirit. Also regenerate $s2% of maximum health every 5 sec.
    fel_armor = {
        id = 28176,
        duration = 3600,
        max_stack = 1,
    },
    -- Imp, Voidwalker, Succubus, Felhunter and Felguard casting time reduced by $/1000;S1 sec.  Mana cost reduced by $s2%.
    fel_domination = {
        id = 18708,
        duration = 15,
        max_stack = 1,
    },
    fel_intelligence = {
        id = 54424,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases speed by $s2%.
    felsteed = {
        id = 5784,
        duration = 3600,
        max_stack = 1,
    },
    felstorm = {
        id = 89751,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
    },
    jinx_curse_elements = {
        id = 86105,
	    copy = { 86105, 85547 },
	    duration = 4,
        max_stack = 1,
    },
    -- Damage taken from Shadow damage-over-time effects increased by $s3%.
    haunt = {
        id = 48181,
        duration = 12,
        max_stack = 1,
    },
    -- Transferring Life.
    health_funnel = {
        id = 755,
        duration = 3,
        tick_time = 1,
        max_stack = 1,
    },
    -- Damages self and all nearby enemies.
    hellfire = {
        id = 1949,
        duration = 15,
        tick_time = 1,
        max_stack = 1,
    },
    -- Fleeing in terror.
    howl_of_terror = {
        id = 5484,
        duration = 8,
        max_stack = 1,
    },
    -- $s1 Fire damage every $t1 seconds.
    immolate = {
        id = 348,
        duration = function() return 15 + ( talent.inferno.enabled and 6 or 0 ) end,
        tick_time = function() return 3 * spell_haste end,
        max_stack = 1,
    },
    -- Damages all nearby enemies.
    immolation_aura = {
        id = 50589,
        duration = 15,
        tick_time = 1,
        max_stack = 1,
    },
    -- Damage taken is reduced by $s1%.
    improved_health_funnel = {
        id = 60956,
        duration = 3600,
        max_stack = 1,
    },
    -- Shadow and Fire damage increased by $w1%.
    improved_soul_fire = {
        id = 85383,
        duration = 20,
        max_stack = 1,
    },
    -- Stunned.
    infernal_awakening = {
        id = 22703,
        duration = 2,
        max_stack = 1,
    },
    -- Spell Power increase from Life Tap.
    life_tap = {
        id = 63321,
        duration = 40,
        max_stack = 1,
    },
    -- Increases fire damage caused by $s1% and increases the critical hit chance of your fire spells by $s2%.
    -- TODO: Get other Master Demonologist effect auras.
    master_demonologist_imp = {
        id = 23829,
        duration = 3600,
        max_stack = 1,
    },
    -- Demon Form.  Armor contribution from items increased by $47241s2%.  Chance to be critically hit by melee reduced by 6%.  Damage increased by $47241s3%.  Stun and snare duration reduced by $54817s1%.
    metamorphosis = {
        id = 47241,
        duration = function() return 30 + ( glyph.metamorphosis.enabled and 6 or 0 ) end,
        max_stack = 1,
    },
    -- Increases damage done by $71165s1% and reducing cast time by $71165s3% of your Incinerate.
    molten_core = {
        id = 71165,
        duration = 15,
        max_stack = 1,
    },
    nether_protection_holy = {
        id = 54370,
        duration = 8,
        max_stack = 1,
    },
    nether_protection_fire = {
        id = 54371,
        duration = 8,
        max_stack = 1,
    },
    nether_protection_frost = {
        id = 54372,
        duration = 8,
        max_stack = 1,
    },
    nether_protection_arcane = {
        id = 54373,
        duration = 8,
        max_stack = 1,
    },
    nether_protection_shadow = {
        id = 54374,
        duration = 8,
        max_stack = 1,
    },
    nether_protection_nature = {
        id = 54375,
        duration = 8,
        max_stack = 1,
    },
    -- Absorbs ${$M1+($SP*0.807)} spell damage.
    nether_ward = {
        id = 91711,
        duration = 30,
        max_stack = 1,
    },
    -- Movement speed reduction (after Fear).
    nightmare = {
        id = 60947,
        duration = 5,
        max_stack = 1,
    },
    -- $47818s1 Fire damage every $47818t1 seconds.
    rain_of_fire = {
        id = 5740,
        duration = 8,
        max_stack = 1,
    },
    -- Replenishes $s1% of maximum mana per 10 sec.
    replenishment = {
        id = 57669,
        duration = 15,
        max_stack = 1,
        shared = "player",
        dot = "buff",
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
        id = 27243,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
    },
    -- Detecting Demons.
    sense_demons = {
        id = 5500,
        duration = 3600,
        max_stack = 1,
    },
    -- Chance to be critically hit with spells increased by $s1%.
    shadow_and_flame = {
        id = 17800,
        duration = 30,
        max_stack = 1,
    },
    -- Periodic Shadow damage taken increased by $s1%.
    shadow_embrace = {
        id = 32389,
        duration = 12,
        max_stack = 3,
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
    },
    -- If target dies, casting warlock gets a Soul Shard.
    shadowburn = {
        id = 29341,
        duration = 5,
        max_stack = 1,
    },
    shadowflame = {
        id = 47960,
        duration = 6,
        tick_time = 2,
        max_stack = 1,
    },
    -- Stunned.
    shadowfury = {
        id = 30283,
        duration = 3,
        max_stack = 1,
    },
    -- Gaining $s1 soul shard every $s3 sec and $s2% total health every $t1 sec.
    soul_harvest = {
        id = 79268,
        duration = 9,
        tick_time = 1,
        max_stack = 1,
    },
    soulburn = {
        id = 74434,
        duration = 15,
        max_stack = 1
    },
    soul_link = {
        id = 25228,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    soulburn_demonic_circle = {
        id = 79438,
        duration = 8,
        max_stack = 1,
    },
    -- Critical effect chance of your Searing Pain spell increased by $s1%.
    soulburn_searing_pain = {
        id = 79440,
        duration = 6,
        max_stack = 1,
    },
    -- Enslaved.
    subjugate_demon = {
        id = 1098,
        duration = 300,
        max_stack = 1,
    },
    -- Your next Fear is instant cast.
    sudden_fear = {
        id = 53756,
        duration = 10,
        max_stack = 1,
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
	summon_infernal = {
        id = 1122,
        duration = 60,
        max_stack = 1,
    },
    summon_doomguard = {
        id = 18540,
        duration = function() return 45 + ( set_bonus.tier13_2pc and 30 or 0 ) end,
        max_stack = 1,
    },
    -- Underwater Breathing.
    unending_breath = {
        id = 5697,
        duration = 600,
        max_stack = 1,
        shared = "player",
        dot = "buff",
    },
    -- $s1 Shadow damage every $t1 sec.  If dispelled, will cause $*9;s1 damage to the dispeller and silence them for $31117d.
    unstable_affliction = {
        id = 30108,
        duration = 15,
        tick_time = function() return ( 3 * haste ) end,
        max_stack = 1,
        copy = { 30108, 30404, 30405, 43522, 47841, 47843, 65812 },
    },
    unstable_affliction_silence = {
        id = 31117,
        duration = 4,
        max_stack = 1,
    },
    -- T11 4pc Buff
    fel_spark = {
        id = 89937,
        duration = 15,
        max_stack = 1,
    },
    -- Custom Auras
    my_bane = {
        alias = { "bane_of_agony", "bane_of_doom", "bane_of_havoc" },
        aliasMode = "first",
        aliasType = "debuff",
    },
    my_curse = {
        alias = { "curse_of_the_elements", "curse_of_weakness", "curse_of_tongues", "curse_of_exhaustion" },
        aliasMode = "first",
        aliasType = "debuff",
    },
    armor = {
        alias = { "fel_armor", "demon_armor", "demon_skin" },
        aliasMode = "first",
        aliasType = "buff"
    }
})


-- Glyphs
spec:RegisterGlyphs( {
    [56241] = "bane_of_agony",
    [63304] = "chaos_bolt",
    [56235] = "conflagrate",
    [56218] = "corruption",
    [58080] = "curse_of_exhaustion",
    [56232] = "death_coil",
    [63309] = "demonic_circle",
    [58081] = "eye_of_kilrogg",
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
    [70947] = "lash_of_pain",
    [63320] = "life_tap",
    [63303] = "metamorphosis",
    [58094] = "ritual_of_souls",
    [56250] = "seduction",
    [56240] = "shadow_bolt",
    [56229] = "shadowburn",
    [63310] = "shadowflame",
    [63312] = "soul_link",
    [56226] = "soul_swap",
    [56231] = "soulstone",
    [58107] = "subjugate_demon",
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
spec:RegisterPet( "doomguard", 11859, "summon_doomguard", 45 )
spec:RegisterPet( "infernal", 89, "summon_infernal", 60 )


local cataclysm_reduction = {
    [0] = 1,
    [1] = 0.96,
    [2] = 0.93,
    [3] = 0.9
}

local mod_cataclysm = setfenv( function( base )
    return base * cataclysm_reduction[ talent.cataclysm.rank ]
end, state )

--[[ local finish_shadow_cleave = setfenv( function()
    spend( class.abilities.shadow_cleave.spend * mana.modmax, "mana" )
end, state )

spec:RegisterStateFunction( "start_shadow_cleave", function()
    applyBuff( "shadow_cleave", swings.time_to_next_mainhand )
    state:QueueAuraExpiration( "shadow_cleave", finish_shadow_cleave, buff.shadow_cleave.expires )
end ) ]]

spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )

spec:RegisterStateExpr( "persistent_multiplier", function( action )
    local mult = 1
    if action == "corruption" then
        if talent.deaths_embrace.enabled and target.health.pct < 25 then
            mult = mult * ( 1 + 0.04 * talent.deaths_embrace.rank )
        end

        if buff.tricks_of_the_trade_buff.up then
            mult = mult * 1.15
        end
    end

    return mult
end )

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_AURA_APPLIED" then
            local aura = class.auras[ spellID ]

            if aura == class.auras.corruption then
                local mult = 1

                if state.talent.deaths_embrace.enabled and aura == class.auras.corruption and UnitGUID( "target" ) == destGUID and ( UnitHealth( "target" ) / ( UnitHealthMax( "target" ) or 1 ) < 0.35 ) then
                    mult = mult * 1 + 0.04 * state.talent.deaths_embrace.rank
                end

                if FindUnitBuffByID( "player", 57933 ) then
                    mult = mult * 1.15
                end

                ns.saveDebuffModifier( spellID, mult )
                ns.trackDebuff( spellID, destGUID, GetTime(), true )
            end
        end
    end
end )

spec:RegisterHook( "runHandler", function( action )
    if buff.empowered_imp.up and class.abilities[ action ].startsCombat then
        removeBuff( "empowered_imp" )
    end
end )

spec:RegisterStateExpr("pet_twisting", function()
    return settings.pet_twisting
end )


local lastTarget

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" and destGUID == nil and destGUID ~= "" then
            lastTarget = destGUID
        end
    end
end )

spec:RegisterCycle( function ()
    if active_enemies == 1 then return end

    if this_action == "bane_of_havoc" and class.abilities.bane_of_havoc.key == "bane_of_havoc" then return "cycle" end

    if ( debuff.bane_of_havoc.up and FindUnitDebuffByID( "target", 80240 ) ) then return "cycle" end
end )


-- Abilities
spec:RegisterAbilities( {
    --Banes the target with agony, causing 1536 Shadow damage over 24 sec.  This damage is dealt slowly at first, and builds up as the Curse reaches its full duration.  Only one Bane per Warlock can be active on any one target.
    bane_of_agony = {
        id = 980,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.rank > 1 and "totem" or "spell" end,

        spend = 0.1, 
        spendType = "mana",

        startsCombat = true,
        texture = 136139,

        handler = function()
            removeDebuff( "target", "my_bane" )
            applyDebuff( "target", "bane_of_agony" )
        end,

        copy = "curse_of_agony",
    },

    --Banes the target with impending doom, causing 1948 Shadow damage every 15 sec.  When Bane of Doom deals damage, it has a 20% chance to summon a Demon guardian. Only one target can have Bane of Doom at a time, only one Bane per Warlock can be active on any one target. Lasts for 1 min.
    bane_of_doom = {
        id = 603,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.rank > 1 and "totem" or "spell" end,

        spend = 0.15, 
        spendType = "mana",

        startsCombat = true,
        texture = 136122,

        handler = function()
            removeDebuff( "target", "my_bane" )
            applyDebuff( "target", "bane_of_doom" )
            applyBuff( "active_doom" )
        end,

        copy = "curse_of_doom",
    },

    --Banes the target for 5 min, causing 15% of all damage done by the Warlock to other targets to also be dealt to the baned target. Only one target can have Bane of Havoc at a time, and only one Bane per Warlock can be active on any one target.
    bane_of_havoc = {
        id = 80240,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.rank > 1 and "totem" or "spell" end,

        startsCombat = true,
        texture = 460695,

        indicator = function () return active_enemies > 1 and ( lastTarget == "lastTarget" or target.unit == lastTarget ) and "cycle" or nil end,
        cycle = "bane_of_havoc",

        handler = function()
            if class.abilities.bane_of_havoc.cycle then
                active_dot.bane_of_havoc = active_dot.bane_of_havoc + 1
            else
                removeDebuff( "target", "my_bane" )
                applyDebuff( "target", "bane_of_havoc" )
            end
            applyBuff( "active_havoc" )
        end,

        copy = { 85455, 85468, 85466, 101553 },
    },

    --Banishes the enemy target, preventing all action but making it invulnerable for up to 30 sec.  Only one target can be banished at a time.  Casting Banish on a banished target will cancel the spell.  Only works on Demons and Elementals.
    banish = {
        id = 710,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 136135,

        handler = function()
            applyDebuff( "target", "banish")
        end,
    },

    -- Sends a bolt of chaotic fire at the enemy, dealing 1312 to 1665 Fire damage. Chaos Bolt cannot be resisted, and pierces through all absorption effects.
    chaos_bolt = {
        id = 50796,
        cast = function()
            local cast_time = 2.5

            if talent.bane.rank == 1 then cast_time = cast_time - 0.1 end
            if talent.bane.rank == 2 then cast_time = cast_time - 0.3 end
            if talent.bane.rank == 3 then cast_time = cast_time - 0.5 end
            if buff.backdraft.up then cast_time = cast_time * ( 1 - 0.1 * talent.backdraft.rank ) end

            cast_time = cast_time * spell_haste

            return cast_time
        end,
        cooldown = function() return ( glyph.chaos_bolt.enabled and 10 or 12 ) end,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.07 ) end,
        spendType = "mana",

        talent = "chaos_bolt",
        startsCombat = true,
        texture = 236291,

        handler = function()
            removeStack( "backdraft" )
        end,

    },

    -- Instantly deals fire damage equal to $s2% of your Immolate's periodic damage on the target.
    conflagrate = {
        id = 17962,
        cast = 0,
        cooldown = function() return 10 - ( glyph.conflagrate.enabled and 2 or 0 ) end,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.16 ) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 135807,
        talent = "conflagrate",

        debuff = "immolate",

        handler = function()
            if talent.aftermath.rank == 2 then applyDebuff( "target", "aftermath" ) end
            if talent.backdraft.enabled then applyBuff( "backdraft", nil, 3 ) end
        end,

    },

    -- Corrupts the target, causing $o1 Shadow damage over $d.
    corruption = {
        id = 172,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.enabled and "totem" or "spell" end,


        spend = 0.06, 
        spendType = "mana",

        startsCombat = true,
        texture = 136118,

        handler = function()
            applyDebuff( "target", "corruption")
            debuff.corruption.pmultiplier = persistent_multiplier
        end,

    },

    -- Creates a Healthstone that can be consumed to restore $6262s1% health.; Conjured items disappear if logged out for more than 15 minutes.
    create_healthstone = {
        id = 6201,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.53 ) end, 
        spendType = "mana",

        startsCombat = false,
        texture = 135230,

        handler = function()
            --"/cata/spell=6201/create-healthstone"
        end,

    },

    -- Creates a Soulstone. When cast on live targets, the soul of the target is stored and they will be able to resurrect upon death. If cast on a dead target, they are instantly resurrected. Targets resurrect with $3026s1% health and $3026q1% mana.; Conjured items disappear if logged out for more than 15 minutes.
    create_soulstone = {
        id = 693,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.68 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136210,

        handler = function()
            --"/cata/spell=693/create-soulstone"
        end,

    },

    -- Reduces the target's movement speed by 30% for 12 sec.  Only one Curse per Warlock can be active on any one target.
    curse_of_exhaustion = {
        id = 18223,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.enabled and "totem" or "spell" end,

        spend = function() return mod_suppression( 0.06 ) end,
        spendType = "mana",

        talent = "curse_of_exhaustion",
        startsCombat = true,
        texture = 136162,

        handler = function ()
            removeDebuff( "target", "my_curse" )
            applyDebuff( "target", "curse_of_exhaustion" )
        end
    },

    -- Curses the target for 5 min, reducing Arcane, Fire, Frost, Nature, and Shadow resistances by 184 and increasing magic damage taken by 8%.  Only one Curse per Warlock can be active on any one target.
    curse_of_the_elements = {
        id = 1490,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.enabled and "totem" or "spell" end,

        spend = 0.1, 
        spendType = "mana",

        startsCombat = true,
        texture = 136130,

        handler = function()
            removeDebuff( "target", "my_curse" )
            applyDebuff( "target", "curse_of_the_elements" )
        end,
    },

    -- Forces the target to speak in Demonic, increasing the casting time of all spells by 30%.  Only one Curse per Warlock can be active on any one target.  Lasts 30 sec.
    curse_of_tongues = {
        id = 1714,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.enabled and "totem" or "spell" end,

        spend = 0.04, 
        spendType = "mana",

        startsCombat = true,
        texture = 136140,

        handler = function()
            removeDebuff( "target", "my_curse" )
            applyDebuff( "target", "curse_of_tongues" )
        end,
    },

    -- Target's physical damage done is reduced by 10% for 2 min.  Only one Curse per Warlock can be active on any one target.
    curse_of_weakness = {
        id = 702,
        cast = 0,
        cooldown = 0,
        gcd = function() return talent.amplify_curse.enabled and "totem" or "spell" end,

        spend = 0.1, 
        spendType = "mana",

        startsCombat = true,
        texture = 136138,

        handler = function()
            removeDebuff( "target", "my_curse" )
            applyDebuff( "target", "curse_of_weakness" )
        end,
    },

    -- You link yourself with the targeted friendly target, increasing both of your haste by 3%. When you or the linked target gains a critical periodic damage or healing effect, the other gains increased periodic damage and healing lasting for 7 sec.  You gain 3%, while the target gains 1%.  Stacks up to 3 times. Dark Intent lasts for 30 min.
    dark_intent = {
        id = 80398,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06, 
        spendType = "mana",

        startsCombat = false,
        texture = 463285,

        handler = function()
            applyBuff( "dark_intent" )
        end,

    },

    -- Causes the enemy target to run in horror for 3 sec and causes 754 Shadow damage.  The caster gains 300% of the damage caused in health. Requires Warlock.
    death_coil = {
        id = 6789,
        cast = 0,
        cooldown = 2,
        gcd = "spell",

        spend = 0.23,
        spendType = "mana",

        startsCombat = true,
        texture = 136145,

        toggle = "defensives",

        handler = function()
            --"/cata/spell=6789/death-coil"
            applyDebuff( "target", "death_coil" )
        end,

    },

    -- Protects the caster, increasing armor by 2345, and increasing the amount of health generated through spells and effects by (20)%. Only one type of Armor spell can be active on the Warlock at any time.
    demon_armor = {
        id = 687,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136185,

        handler = function()
            removeBuff( "armor" )
            applyBuff( "demon_armor" )
        end,

    },

    -- Leap through the air 16 yards in front of you, slamming down on all enemies within 5 yards of the target area, causing 2419 Shadow damage and stunning them for 2 sec.
    demon_leap = {
        id = 54785,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,
        texture = 132368,

        buff = "metamorphosis",
        handler = function()
            applyDebuff( "target", "demon_leap" )
        end,

    },

    -- You and your summoned demon fuse souls, granting the Warlock a temporary power depending on the demon currently enslaved.Imp - Critical strike chance of your cast time Destruction spells increased by 30% for 20 sec. Voidwalker - All threat generated by you transferred to your Voidwalker for 15 sec.Succubus - Shadow Bolt damage increased by 10% for 20 sec.Felhunter - Periodic shadow damage increased by 20% for 20 sec.Felguard - Spell haste increased by 15% and fire and shadow damage done increased by 10% for 20 sec.
    demon_soul = {
        id = 77801,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.15, 
        spendType = "mana",

        startsCombat = false,
        texture = 463284,

        toggle = "cooldowns",

        handler = function()
            if     pet.imp.active        then applyBuff( "demon_soul_imp" )
            elseif pet.voidwalker.active then applyBuff( "demon_soul_voidwalker" )
            elseif pet.succubus.active   then applyBuff( "demon_soul_succubus" )
            elseif pet.felhunter.active  then applyBuff( "demon_soul_felhunter" )
            elseif pet.felguard.active   then applyBuff( "demon_soul_felguard" ) end
        end,
    },

    -- You summon a Demonic Circle at your feet, lasting 6 min. You can only have one Demonic Circle active at a time. In the Demonology Abilities category.
    demonic_circle_summon = {
        id = 48018,
        cast = 0.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15, 
        spendType = "mana",

        startsCombat = false,
        texture = 237559,

        handler = function()
            applyBuff( "demonic_circle_summon" )
        end,
    },

    -- Teleports you to your Demonic Circle and removes all snare effects.; Soulburn; Soulburn: Movement speed increased by 50% for 8 sec. Requires Warlock.
    demonic_circle_teleport = {
        id = 48020,
        cast = 0,
        cooldown = function() return glyph.demonic_circle.enabled and 26 or 30 end,
        gcd = "spell",

        spend = 100, 
        spendType = "mana",

        startsCombat = false,
        texture = 237560,

        handler = function()
            if buff.soulburn.up then
                applyBuff( "soulburn_demonic_circle" )
                removeBuff( "soulburn" )
            end

        end,
    },

    -- Grants the Warlock's summoned demon Empowerment.; Imp - Instantly heals the Imp for $54444s1% of its total health.; Voidwalker - Increases the Voidwalker's health by $54443s2%, and its threat generated from spells and attacks by $54443s2% for $54443d.; Succubus - Instantly vanishes, causing the Succubus to go into an improved Invisibility state. The vanish effect removes all stuns, snares and movement impairing effects from the Succubus.; Felhunter - Dispels all magical effects from the Felhunter.; Felguard - Instantly removes all stun, snare, fear, banish, or horror and movement impairing effects from your Felguard and makes your Felguard immune to them for $54508d.
    demonic_empowerment = {
        id = 47193,
        cast = 0,
        cooldown = function() return 60 * ( 1 - 0.15 * talent.nemesis.rank ) end,
        gcd = "none",

        spend = 0.060,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            -- Don't need to model.
        end,
    },

    -- Drains the life from the target, causing 82 Shadow damage and restoring 2% of the caster's total health every 1 sec. Lasts 3 sec.SoulburnSoulburn: Cast time reduced by 50%.
    drain_life = {
        id = 689,
        cast = function () return 3 * haste * ( buff.soulburn.up and 0.5 or 1 ) end,
        cooldown = 0,
        channeled = true,
        breakable = true,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 136169,
        aura = "drain_life",

        tick_time = function () return class.auras.drain_life.tick_time end,

        start = function()
            removeBuff( "soulburn" )
            applyDebuff( "target", "drain_life" )
            if talent.everlasting_affliction.rank == 3 and dot.corruption.ticking then dot.corruption.expires = query_time + dot.corruption.duration end
        end,

		tick = function () end,

        breakchannel = function ()
            removeDebuff( "target", "drain_life" )
        end,

        copy = 89420
    },

    -- Drains the soul of the target, causing 385 Shadow damage over 15 sec.  If the target is at or below 25% health, Drain Soul causes double the normal damage. If the target dies while being drained, and yields experience or honor, the caster gains 3 Soul ShardsGlyph of Drain Souland 10% of  his total mana Soul Shards are required for Soulburn.
    drain_soul = {
        id = 1120,
        cast = 15,
        cooldown = 0,
        gcd = "spell",
        channeled = true,
        breakable = true,

        spend = 0.14, 
        spendType = "mana",

        startsCombat = true,
        texture = 136163,
        tick_time = function () return class.auras.drain_soul.tick_time end,

        start = function( rank )
            applyDebuff( "target", "drain_soul" )
            if talent.everlasting_affliction.rank == 3 and dot.corruption.ticking then dot.corruption.expires = query_time + dot.corruption.duration end
        end,

        tick = function () end,

		breakchannel = function ()
            removeDebuff( "target", "drain_soul" )
        end,
    },

    -- Summons an Eye of Kilrogg and binds your vision to it.  The eye moves quickly but is very fragile. In the Demonology Abilities category. Requires Warlock.
    eye_of_kilrogg = {
        id = 126,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04, 
        spendType = "mana",

        startsCombat = false,
        texture = 136155,

        handler = function()
            applyBuff( "eye_of_kilrogg" )
        end,

    },

    -- Strikes fear in the enemy, causing it to Glyph of Feartremble in placerun in fear for up to 20 sec.  Damage caused may interrupt the effect.  Only 1 target can be feared at a time.
    fear = {
        id = 5782,
        cast = function() return buff.sudden_fear.up and 0 or 1.7 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12, 
        spendType = "mana",

        startsCombat = true,
        texture = 136183,

        handler = function()
            removeBuff( "sudden_fear" )
            applyDebuff( "target", "fear" )
        end,
    },

    -- Surrounds the caster with fel energy, increasing spell power by 638 and causes you to be healed for 3% of any single-target spell damage you deal.Only one type of Armor spell can be active on the Warlock at any time.
    fel_armor = {
        id = 28176,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136156,

        handler = function()
            removeBuff( "armor" )
            applyBuff( "fel_armor" )
        end,
    },

    -- Your next Imp, Voidwalker, Succubus, Incubus, Felhunter or Felguard Summon spell has its casting time reduced by $/1000;S1 sec and its Mana cost reduced by $s2%.
    fel_domination = {
        id = 18708,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        startsCombat = false,

        handler = function()
            applyBuff( "fel_domination" )
        end,

        -- Affected by:
        -- [ ] aura.metamorphosis[54879.2] -- APPLY_AURA, MOD_IGNORE_SHAPESHIFT, target: TARGET_UNIT_CASTER
    },

    -- Deals 238.5 Shadowflame damage to an enemy target, increasing the duration of Immolate or Unstable Affliction by 6 sec. In the Destruction Abilities category.
    fel_flame = {
        id = 77799,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06, 
        spendType = "mana",

        startsCombat = true,
        texture = 135795,

        handler = function()
            if dot.immolate.ticking then dot.immolate.expires = dot.immolate.expires + 6 end
            if dot.unstable_affliction.ticking then dot.unstable_affliction.expires = dot.unstable_affliction.expires + 6 end
        end,
    },
    felstorm = {
        id = 89751,
        cast = 0,
        cooldown = 45,
        gcd = off,

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 236303,

        generate = function( t )
            local name, _, _, _, duration, expires = FindUnitBuffByID( "pet", 89751 )

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

    -- Summons a falling meteor down upon the enemy target, dealing $71521s1 Shadowflame damage and erupts an aura of magic within $86000a1 yards, causing all targets within it to have a $86000s1% increased  chance to be critically hit by any Warlock demons. The aura lasts for $86041d.
    hand_of_guldan = {
        id = 71521,
        cast = 2,
        cooldown = 12,
        gcd = "spell",

        spend = 0.070,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "curse_of_guldan" )
            if talent.cremation.rank > 1 and debuff.immolate.up then applyDebuff( "target", "immolate" ) end
        end,
    },

    -- You send a ghostly soul into the target, dealing [((Spell power * 0.5577) * 1.25) +  922] Shadow damage and increasing all damage done by your Shadow damage-over-time effects on the target by 20% for 12 sec. When the Haunt spell ends or is dispelled, the soul returns to you, healing you for 100% of the damage it did to the target.
    haunt = {
        id = 48181,
        cast = 1.5,
        cooldown = 8,
        gcd = "spell",

        spend = 0.12, 
        spendType = "mana",

        startsCombat = true,
        texture = 236298,

        handler = function()
            applyDebuff( "target", "haunt" )
            if talent.everlasting_affliction.rank == 3 and dot.corruption.ticking then dot.corruption.expires = query_time + dot.corruption.duration end
        end,
    },

    -- Sacrifices 1% of your total health to restore 6% of your summoned Demon's total health every 1 sec. Lasts for 3 sec. In the Demonology Abilities category.
    health_funnel = {
        id = 755,
        cast = 3,
        cooldown = 0,
        gcd = "spell",
        channeled = true,
        breakable = true,

        spend = 0.01,
        spendType = "health",

        startsCombat = false,
        texture = 136168,

        aura = "health_funnel",

        start = function()
            applyBuff( "health_funnel" )
        end,
    },

    --Ignites the area surrounding the caster, causing 319 Fire damage to himself and 319 Fire damage to all nearby enemies every 1 sec.  Lasts 15 sec.
    hellfire = {
        id = 1949,
        cast = 15,
        cooldown = 0,
        gcd = "spell",
        channeled = true,
        beakable = true,

        spend = function() return mod_cataclysm( 0.64 ) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 135818,

        handler = function()
        end,

        copy = 85403
    },

    -- Howl, causing 5 enemies within 10 yds to flee in terror for 8 sec.  Damage caused may interrupt the effect. In the Affliction Abilities category.
    howl_of_terror = {
        id = 5484,
        cast = function() return 1.5 * ( 1 - 0.5 * talent.improved_howl_of_terror.rank ) end,
        cooldown = function() return glyph.howl_of_terror.enabled and 32 or 40 end,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 136147,

        handler = function()
            applyDebuff( "target", "howl_of_terror" )
        end,
    },

    -- Burns the enemy for 596 Fire damage and then an additional 1890 Fire damage over 15 sec.; Unstable Affliction; Only one Unstable Affliction or Immolate per Warlock can be active on any one target.
    immolate = {
        id = 348,
        cast = function () return (talent.bane.rank == 3 and 1.5 or 2) * spell_haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.08 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135817,
        cycle = "immolate",

        handler = function()
            removeDebuff( "target", "unstable_affliction" )
            applyDebuff( "target", "immolate" )
        end,

    },

    --Ignites the area surrounding you, causing 567 Fire damage to all nearby enemies every 1 sec.  Lasts 15 sec. In the Demonology Abilities category.
    immolation_aura = {
        id = 50589,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.64, 
        spendType = "mana",

        startsCombat = true,
        texture = 135818,
        buff = "metamorphosis",

        handler = function()
            applyBuff( "immolation_aura" )
        end,
    },

    -- Deals 551.5 Fire damage to your target and an additional 91.9 Fire damage if the target is affected by an Immolate spell. In the Destruction Abilities category.
    incinerate = {
        id = 29722,
        cast = function()
            if buff.backlash.up then return 0 end

            local cast_time = 2.5

            if talent.emberstorm.rank == 1 then cast_time = cast_time - 0.13 end
            if talent.emberstorm.rank == 2 then cast_time = cast_time - 0.25 end
            if buff.molten_core.up then cast_time = cast_time * ( 1 - 0.1 * talent.molten_core.rank ) end
            if buff.backdraft.up then cast_time = cast_time * ( 1 - 0.1 * talent.backdraft.rank ) end

            cast_time = cast_time * spell_haste

            return cast_time
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.14 ) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 135789,

        handler = function()
            if buff.backlash.up then removeBuff( "backlash" )
            else
                removeStack( "molten_core", 1 )
                removeStack( "backdraft" )
            end
        end,
    },

    -- You Life Tap for 15% of your total health, converting [(120)]% of that into mana. In the Affliction Abilities category. Requires Warlock. A spell.
    life_tap = {
        id = 1454,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "health",

        startsCombat = false,
        texture = 136126,

        handler = function()
            gain( action.life_tap.spend * health.max * ( 1.2 + 0.1 * talent.improved_life_tap.rank ), "mana" )
            if glyph.life_tap.enabled then applyBuff( "life_tap" ) end
        end,

    },

    -- You transform into a Demon for 30 sec.  This form increases your armor by 600%, damage by 20%, reduces the chance you'll be critically hit by melee attacks by 6% and reduces the duration of stun and snare effects by 50%.  You gain some unique demon abilities in addition to your normal abilities. 3 minute cooldown.
    metamorphosis = {
        id = 47241,
        cast = 0,
        cooldown = function() return 180 * ( 1 - ( 0.15 * talent.nemesis.rank ) ) end,
        gcd = "off",

        startsCombat = false,
        texture = 237558,

        toggle = "cooldowns",

        handler = function()
            applyBuff( "metamorphosis" )
        end,
    },

    -- Absorbs ${$M1+($SP*0.807)} spell damage.  Lasts $d.
    nether_ward = {
        id = 91711,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.12, 
        spendType = "mana",

        startsCombat = true,
        texture = 135796,

        handler = function()
            applyBuff( "nether_ward" )
        end,
    },

    --Calls down a fiery rain to burn enemies in the area of effect for (767 * 4) Fire damage over 8 sec. In the Destruction Abilities category. Requires Warlock.
    rain_of_fire = {
        id = 5740,
        cast = function() return 8 * spell_haste end,
        cooldown = 0,
        channeled = true,
        breakable = true,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.57 ) end,
        spendType = "mana",
        tick_time = function () return ( 2 * haste ) end,

        startsCombat = true,
        texture = 136186,

        aura = "rain_of_fire",

        start = function()
            applyBuff( "rain_of_fire" )
        end,
    },

	-- Commented out to fix issue #3441
    --[[ Begins a ritual that creates a Soulwell.  Raid members can click the Soulwell to acquire a Healthstone.  The Soulwell lasts for 3 min or 25 charges.  Requires the caster and 2 additional party members to complete the ritual.  In order to participate, all players must right-click the soul portal and not move until the ritual is complete.
    ritual_of_souls = {
        id = 29893,
        cast = 60,
        cooldown = 300,
        channeled = true,
        breakable = true,
        gcd = "spell",

        spend = 0.27, 
        spendType = "mana",

        startsCombat = false,
        texture = 136194,

        handler = function()
        end,
    },

    -- Begins a ritual that creates a summoning portal.  The summoning portal can be used by 2 party or raid members to summon a targeted party or raid member.  The ritual portal requires the caster and 2 additional party or raid members to complete.  In order to participate, all players must be out of combat and right-click the portal and not move until the ritual is complete.
    ritual_of_summoning = {
        id = 698,
        cast = 120,
        cooldown = 120,
        channeled = true,
        breakable = true,
        gcd = "spell",

        spend = 0.12, 
        spendType = "mana",

        startsCombat = false,
        texture = 136223,

        handler = function()
        end,
    }, ]]

    -- Inflict searing pain on the enemy target, causing 310 Fire damage.  Causes a high amount of threat.SoulburnSoulburn: Increases the critical effect chance of your next Searing Pain by 100%, and your subsequent Searing Pain casts by 50% for 6 sec.
    searing_pain = {
        id = 5676,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.12 ) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 135827,

        handler = function()
            --"/cata/spell=5676/searing-pain"
            if buff.soulburn.up then
                applyBuff( "soulburn_searing_pain" ) --TODO: implement 79440 soulburn_searing_pain
                removeBuff( "soulburn" )
            end
        end,

    },

    -- Imbeds a demon seed in the enemy target, causing 1746 Shadow damage over 18 sec.  When the target takes 2033 total damage or dies, the seed will inflict 737 Shadow damage to all enemies within 15 yards of the target.  Only one Corruption spell per Warlock can be active on any one target.Soulburn: Seed of CorruptionSoulburn: Your Seed of Corruption detonation effect will afflict Corruption on all enemy targets. The Soul Shard will be refunded if the detonation is successful.
    seed_of_corruption = {
        id = 27243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.34, 
        spendType = "mana",

        startsCombat = true,
        texture = 136193,

        cycle = "seed_of_corruption",

        handler = function()
            removeBuff( "target", "corruption" )
            if buff.soulburn.up then
                applyDebuff( "target", "soulburn_seed_of_corruption" )
            else
                applyDebuff( "target", "seed_of_corruption" )
            end
        end,
    },

    -- Sends a shadowy bolt at the enemy, causing 596.5 Shadow damage. In the Destruction Abilities category. Requires Warlock. Learn how to use this in our class guide.
    shadow_bolt = {
        id = 686,
        cast = function()
            if buff.backlash.up then return 0 end
            if buff.shadow_trance.up then return 0 end
            return ( 1.7 - ( talent.bane.enabled and ( 0.2 * talent.bane.rank - 0.1 ) or 0 ) ) * ( 1 - 0.1 * ( buff.backdraft.up and talent.backdraft.rank or 0 ) ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.1 ) * ( glyph.shadow_bolt.enabled and 0.85 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136197,

        cycle = "shadow_bolt",

		velocity = 6,

        handler = function()
            --"/cata/spell=686/shadow-bolt"
            -- TODO: Confirm order in which Backlash vs. Shadow Trace would be consumed.
            if buff.backlash.up then removeBuff( "backlash" )
            elseif buff.shadow_trance.up then removeBuff( "shadow_trance" ) end
            if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            if talent.everlasting_affliction.rank == 3 and dot.corruption.ticking then dot.corruption.expires = query_time + dot.corruption.duration end
            removeStack( "backdraft" )
            applyDebuff( "target", "shadow_and_flame" )
        end,

    },
    --[[ Inflicts 110 Shadow damage to an enemy target and nearby allies, affecting up to 3 targets.
    shadow_cleave = { --TODO: check if spell still exists (update for cata)
        id = 50581,
        cast = 0,
        cooldown = 6,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 132332,

        buff = "metamorphosis",
        nobuff = "shadow_cleave",

        usable = function() return target.distance < 10, "must be in melee range" end,

        handler = function ()
            start_shadow_cleave()
        end,
    }, ]]

    --Absorbs [3551 + (Spell power * 0.807)] shadow damage.  Lasts 30 sec. In the Demonology Abilities category. Requires Warlock. Learn how to use this in our class guide.
    shadow_ward = {
        id = 6229,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.12, 
        spendType = "mana",

        startsCombat = true,
        texture = 136121,

        handler = function()
            --"/cata/spell=6229/shadow-ward"
            applyBuff( "shadow_ward" )
        end,
    },

    -- Instantly blasts the target for 91 to 104 Shadow damage.  If the target dies within 5 sec of Shadowburn, and yields experience or honor, the caster gains a Soul Shard.
    shadowburn = {
        id = 17877,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.2 ) end,
        spendType = "mana",

        talent = "shadowburn",
        startsCombat = true,
        texture = 136191,

        usable = function()
            return target.health.pct < 20, "target must be below 20% health"
        end,

        handler = function ()
            applyDebuff( "target", "shadowburn" )
        end,
    },

    --Targets in a cone in front of the caster take 700 Shadow damage and an additional 489 Fire damage over 6 sec.Glyph of ShadowflameAlso reduces movement speed by 70% to afflicted targets
    shadowflame = {
        id = 47897,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.25 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 236302,

        cycle = "shadowflame",

        handler = function()
            --"/cata/spell=47897/shadowflame"
            applyDebuff( "target", "shadowflame" )
        end,
    },

    --Shadowfury is unleashed, causing 688 to 819 Shadow damage and stunning all enemies within 8 yds for 3 sec. In the Warlock Talents category. A spell.
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

        handler = function()
            applyDebuff( "target", "shadowfury" )
        end,
    },

    -- Burn the enemy's soul, causing 2447 Fire damage.SoulburnSoulburn: Instant cast. In the Destruction Abilities category. Requires Warlock. A spell.
    soul_fire = {
        id = 6353,
        cast = function()
            if buff.soulburn.up then return 0 end
            if buff.empowered_imp.up then return 0 end
            return ( 4 - 0.5 * talent.emberstorm.rank ) * ( buff.decimation.up and ( 1 - 0.2 * talent.decimation.rank ) or 1 ) * spell_haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_cataclysm( 0.09 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135808,

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "empowered_imp" )

            applyDebuff( "target", "soul_fire" )

            if talent.improved_soul_fire.enabled then
                applyBuff( "improved_soul_fire" )
            end
        end,
    },

    -- You seek out nearby wandering souls, regenerating 45% health and 3 soul shards over 9 sec.  Cannot be cast when in combat. In the Demonology Abilities category.
    soul_harvest = {
        id = 79268,
        cast = 9,
        cooldown = 30,
        channeled = true,
        breakable = true,
        gcd = "spell",

        startsCombat = false,
        texture = 236223,

        handler = function()
            gain( 0.45 * health.max, "health")
            soul_shards = soul_shards + 3
        end,
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

        nobuff = "soul_link",

        usable = function() return pet.alive, "requires a pet" end,

        handler = function()
            applyBuff( "soul_link" )
        end
    },

    -- You instantly deal $86121s1 damage$?s56226[][, and remove your Shadow damage-over-time effects from the target].; For $86211d afterwards, the next target you cast Soul Swap: Exhale on will be afflicted by the Shadow damage-over-time effects and suffer $86121s1 damage.; You cannot Soul Swap to the same target.
    soul_swap = {
        id = 86121,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.180,
        spendType = "mana",

        startsCombat = true,

        handler = function()
        end,
    },

    -- You instantly deal 167 damage, and remove your Shadow damage-over-time effects from the target.For 20 sec afterwards, the next target you cast Soul Swap: Exhale on will be afflicted by the Shadow damage-over-time effects and suffer 167 damage.You cannot Soul Swap to the same target.
    soul_swap_exhale = {
        id = 86213,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.06, 
        spendType = "mana",

        startsCombat = true,
        texture = 132291,

        handler = function()
        end,
    },

    -- Consumes a Soul Shard, allowing you to use the secondary effects on some of your spells.Drain LifeSummon Imp, Voidwalker, Succubus, Felhunter, FelguardDemonic Circle: TeleportSoul FireHealthstoneSearing PainSoulburn: Seed of CorruptionSeed of Corruption
    soulburn = {
        id = 74434,
        cast = 0,
        cooldown = function() return 45 * ( 1 - 0.15 * talent.nemesis.rank ) end,
        gcd = "off",

        spend = 1,
        spendType = "soul_shards",

        startsCombat = false,
        texture = 463286,

        toggle = "cooldowns",

        handler = function()
            applyBuff( "soulburn" )
        end,
    },

    -- Reduces threat by 90% for all enemies within 50 yards. In the Demonology Abilities category. Requires Warlock. Learn how to use this in our class guide.
    soulshatter = {
        id = 29858,
        cast = 0,
        cooldown = 2,
        gcd = "spell",

        spend = 0.08, 
        spendType = "health",

        startsCombat = true,
        texture = 135728,

        handler = function()
        end,
    },

    -- Enslaves the target demon, forcing it to do your bidding.  While enslaved, the time between the demon's attacks is increased by 30% and its casting speed is slowed by 20%.  Lasts up to 5 min.
    subjugate_demon = {
        id = 1098,
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
    },

    --Summons a Doomguard to fight beside you for 45 sec.The Doomguard will assist you by attacking the target which is afflicted by your Bane of Doom or Bane of Agony spell.
    summon_doomguard = {
        id = 18540,
        cast = 0,
        cooldown = function() return 600 + ( set_bonus.tier13_2pc and -240 or 0 ) end,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 236418,

        toggle = "cooldowns",

        handler = function()
            summonPet( "doomguard" )
			dismissPet( "infernal" )
        end,

    },

    -- Summons a Felguard under the command of the Warlock.SoulburnSoulburn: Instant cast. In the Warlock Talents category. Learn how to use this in our class guide.
    summon_felguard = {
        id = 30146,
        cast = function()
            if buff.soulburn.up then return 0 end
            return ( 6 - ( 1 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) ) * ( buff.demonic_rebirth.up and 0.5 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.8 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.5 * talent.master_summoner.rank ) end,  
        spendType = "mana",

        startsCombat = false,
        texture = 136216,
        talent = "summon_felguard",

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "fel_domination" )
            removeBuff( "demonic_rebirth" )

            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            dismissPet( "succubus" )
            summonPet( "felguard" )

        end,
    },
    --Summons a Felhunter under the command of the Warlock.SoulburnSoulburn: Instant cast. In the Demonology Abilities category. Learn how to use this in our class guide.
    summon_felhunter = {
        id = 691,
        cast = function()
            if buff.soulburn.up then return 0 end
            return ( 6 - ( 1 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) ) * ( buff.demonic_rebirth.up and 0.5 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "soul_shards",

        startsCombat = false,
        texture = 136217,

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "fel_domination" )
            removeBuff( "demonic_rebirth" )

            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            summonPet( "felhunter" )
            dismissPet( "succubus" )
            dismissPet( "felguard" )

        end,

    },

    -- Summons an Imp under the command of the Warlock.SoulburnSoulburn: Instant cast. In the Demonology Abilities category. Learn how to use this in our class guide.
    summon_imp = {
        id = 688,
        cast = function()
            if buff.soulburn.up then return 0 end
            return ( 6 - ( 1 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) ) * ( buff.demonic_rebirth.up and 0.5 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.64 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.5 * talent.master_summoner.rank ) end, 
        spendType = "mana",

        startsCombat = false,
        texture = 136218,

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "fel_domination" )
            removeBuff( "demonic_rebirth" )

            summonPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            dismissPet( "succubus" )
            dismissPet( "felguard" )
        end,

    },

    -- Summons an Incubus under the command of the Warlock.SoulburnSoulburn: Instant cast. In the Demonology Abilities category. Learn how to use this in our class guide.
    summon_incubus = {
        id = 713,
        cast = function()
            if buff.soulburn.up then return 0 end
            return ( 6 - ( 1 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) ) * ( buff.demonic_rebirth.up and 0.5 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.8 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.5 * talent.master_summoner.rank ) end, 
        spendType = "mana",

        startsCombat = false,
        texture = 4352492,

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "fel_domination" )
            removeBuff( "demonic_rebirth" )

            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            summonPet( "succubus" )
            dismissPet( "felguard" )

        end,

    },
    --Summons a meteor from the Twisting Nether, causing 466.5 Fire damage and stunning all enemy targets in the area for 2 sec.  An Infernal rises from the crater, under the command of the caster for 45 sec.The Infernal deals strong area of effect damage, and will be drawn to attack targets afflicted by your Bane of Agony or Bane of Doom spells.
    summon_infernal = {
        id = 1122,
        cast = 1.5,
        cooldown = 600,
        gcd = "spell",

        spend = 0.8, 
        spendType = "mana",

        startsCombat = true,
        texture = 136219,

        toggle = "cooldowns",

        handler = function()
            dismissPet( "doomguard" )
			summonPet( "infernal" )
        end,

    },
    --Summons a Succubus under the command of the Warlock.SoulburnSoulburn: Instant cast. In the Demonology Abilities category. Learn how to use this in our class guide.
    summon_succubus = {
        id = 712,
        cast = function()
            if buff.soulburn.up then return 0 end
            return ( 6 - ( 1 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) ) * ( buff.demonic_rebirth.up and 0.5 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.8 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.5 * talent.master_summoner.rank ) end,  
        spendType = "mana",

        startsCombat = false,
        texture = 136220,

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "fel_domination" )
            removeBuff( "demonic_rebirth" )

            dismissPet( "imp" )
            dismissPet( "voidwalker" )
            dismissPet( "felhunter" )
            summonPet( "succubus" )
            dismissPet( "felguard" )

        end,
    },

    -- Summons a Voidwalker under the command of the Warlock.SoulburnSoulburn: Instant cast. In the Demonology Abilities category. Learn how to use this in our class guide.
    summon_voidwalker = {
        id = 697,
        cast = function()
            if buff.soulburn.up then return 0 end
            return ( 6 - ( 1 * talent.master_summoner.rank ) - ( buff.fel_domination.up and 5.5 or 0 ) ) * ( buff.demonic_rebirth.up and 0.5 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.8 * ( buff.fel_domination.up and 0.5 or 1 ) * ( 1 - 0.5 * talent.master_summoner.rank ) end,  
        spendType = "mana",

        startsCombat = false,
        texture = 136221,

        handler = function()
            removeBuff( "soulburn" )
            removeBuff( "fel_domination" )
            removeBuff( "demonic_rebirth" )

            dismissPet( "imp" )
            summonPet( "voidwalker" )
            dismissPet( "felhunter" )
            dismissPet( "succubus" )
            dismissPet( "felguard" )

        end,

    },

    -- Allows the target to breathe underwater for 10 minGlyph of Unending Breathand increases swim speed by 20%. In the Demonology Abilities category.
    unending_breath = {
        id = 5697,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02, 
        spendType = "mana",

        startsCombat = false,
        texture = 136148,

        handler = function()
            applyBuff( "unending_breath" )
        end,
    },

    --Shadow energy slowly destroys the target, causing 1115 damage over 15 sec.  In addition, if the Unstable Affliction is dispelled it will cause 2007 damage to the dispeller and silence them for 4 sec.  Only one Unstable Affliction or Immolate per Warlock can be active on any one target.
    unstable_affliction = {
        id = 30108,
        cast = function()
            return ( glyph.unstable_affliction.enabled and 1.3 or 1.5 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",
        tick_time = function () return class.auras.unstable_affliction.tick_time end,

        talent = "unstable_affliction",
        startsCombat = true,
        texture = 136228,

        cycle = "unstable_affliction",
        handler = function()
            removeDebuff( "target", "immolate" )
            applyDebuff( "target", "unstable_affliction" )
        end,
    },
} )


spec:RegisterSetting("pet_twisting", true, {
    type = "toggle",
    name = "Pet Twisting",
    desc = "Enable this setting to allow the addon to automatically switch between pets based on the situation.\n\n" ..
        "If this setting is disabled, the addon will not switch pets and will only use the pet you have summoned.",
    width = "full"
})

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 687,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "volcanic_potion",

    package = "Affliction",
    usePackSelector = true
} )

spec:RegisterPack( "Affliction ", 20250323, [[Hekili:nNvBVTnos4FlDxG0w0U6sSBAU2Zoa9L7LeSxUfRZI(HdRSOLOS4fjsDuujRbc0V9BgskjkzjzNU3Uy)qBKfhoVXzEMze9pZ)w)vref1)MzNo78tNpBU3PNoB(836VsTlN6VkNeEhzl8aNKb))hIJtzHkMGxfGlUlvqIqMuikLHab(R2uYsvxX93mmNphOnNg6FZ78xLWIIOgkPfH(RUnHvufG)JufyLCvGig(TvMPScfSCSqwf8pO3XszE(R0VevcIGc)5gTvr5KnP0i)pcVwVz)vHLYc6Ar8AvcDnnLMr5W(0YwYYn08bXFTk4hfkIDlsMIkzeWDqsbY9(pm(V4jj87QcoPk4fvbkIClv5fr3ughRxETro1cWls8axtTLMbvdpjnJW4GTTOkyEvWl9vGNBmdriLLwfUJ2xf8gpWXqk5QU6URo2U7ocDMwhrrCpOwCAgJAw4TOQmVNQmgZl5fkKO1KMiLosjKuOwRyySuT1mWwqj(MJuIBiCT3KSvW31rwkw4DAzPTSN1)SQEJrcrMhslJVDAkti3lcRjT1a6ObOQF(OQ(ESobpR8kZRcE8X21ek7cUMZlC8EvbVcsgG0lE4o9ZZWqMgnkXebuQJZIxVnmcZkan7TJerbPVPRlEGK3lGAf8(QGvWcvbFVylleuJz16zXlp2tf0(gi4AjO3OwDXO(RqHifZF8kO0iKFJe8cw4Gs4sucDSYnLsD41FEmpXEcQNl5ljuiDENOSkiHPG0daHcqJYesAJJ51vbf5KSQaW3b8ZGH9Pgoc)MRX4kG4O0MT55A57zjl1IcJs0o4ABzmF7LwF77oyAeGEs4HuTF8chhrcb88XPiUpWNZoDmhMMU1BePiMZUqir26fmXCWBnMP91tHqxuMLj4RJPPjqamv2pA06UUvZOHXPHmSCWQiPG3yim0F3Yf7L81p3SJH9jGxwCBtSrDCpCUgdQlOnjGCIzsKosEoGtsQbkpwO5rsDAqjhS(Ytai(qq)DHJT7nHssvjE5Hkti75hSUWtaCnB3AehAye7HGd3Z0CvVfl7QFrsW0wJ5HtJH90YZ6JlnPkP9yUUZwHalDHjq26mS5P0SnssiTTRKXzRBwqhLxVVwO5wdO98gyX8HXiMetktCFNdkxe79qGA3wFeXEf2G8gdgwFChhbt4e7XmO5NAm(oV8It1MTrd1pUnDxEIxklgH2Y9Q5BJSRxXacgrJjLPtc)b4ERnbcDHh(SDR9TyKEOoJ8o0KRX6AS8DCsoGbvKlbfUWvGdaAmiAE3oJbuhaFBLMaaeIdL1(BOYcbjclaLYcmFpJ0s5hbEzGl1hTT2WxzG50ys1mnNMMU((Yuovs2aZjO2P58HMg4PbW8hKkgBOX6UpWcd70rNeoW4plUTkGghtrx3lMu6Vx))FhSX7b)fo1LscpMIO2z2zW0NWHA5Ih4Wj8n)WNStQmoqABX4wGtkwK)WaNtuxP7r5ivkghkDOMRC6tuwYxBEEnoBPzcZ1MjGXzmNecRpVxC0SUBBstJ41hOSf6qd2KlPHISnKP72cXgtiY7Pf9dV(x5G(lDfOzcbG6i7mQt3CL(KJiHUI7DwHkQ(9nOq1RKlm)Tdo14j6DA0B8oivghcewxGeGFnI3C2zN9oFyOgj3Gm(Lp8J3C1n)93J9RFlgLZYYfsL97m88oNlpVkqs)VLqffa)RqGjhKsLidYNGxeMq4BPfEvx)9moS05ap)jErzoYpKaJEcmfBb55aDvxB(Qh5srmdBUf)rgROqNhB3Pvt2Ihk4mykas)oOdBpuJVsz2K(ihqXIq5OsiWRPGzVd5nta(n4jgpmTmcdlPmiFw(EqbW0()9pvqrorZk(zy4LhsyHjUuRXtQLAvaxGm)xW2qzQ0w(gHpzrkQf6FrpFKvm3AyrvWz)STes7RM5i5hyPPowuD5LAs1Ed9R4LzBOMZIua3T66RYQD1VP3NncweItkvjqS3QvzLXs2DyMI2V7V6BRcmr9vxB2wHxtw0Rw(NCtwEnlEPt(WI5dVLMqDK(EjedVdtkWikqViBKPpRjdadKalW2PqdhSAHgzOrlCBBWLYEDmOz4)FQ63rkTDyGA0xztaUCCWk5U8EKEb0g4FGkK6At6A(V2PJGLNPpWhU)JhFCSEpw0QUVYQQVAwhj1wngfGtavljduF1X9ow9zxo0RS3RXcElHsPiB6wW8YLZo4g7aiVplwmB04FB374b)yFmH2SVoI5iYa7hn9ugKFCP(7uKWEYT9JaGI7qFkHfTt3pkhhjm6O)kcTY4K9GfU0bsypbJ1AhWN17Zdm((BN03rFBL9ILtjCNXJDTw7a1lU4q7SbP8Pp))Jp(vIU2gf1OMNm18(xoFcRWowUB63u0QNwVPwL7N5C0TvpOTwe2z2x0Fi(fxC6jg5FYWdUBQ35E)pTseGQMQqZWxou3OTF1xn0I5VuRI)tOap77(SqPQHY(c0lhujIwuOB8JR)sXzInf2VtDrc4fHc3z4oJWE3iy7vAOidz6663rP52Lm6tr9Nv2GLb0Nz6YGKzUzU7reTB1f2(H6EmrcG(7868bVnVCMNUByD(n4QBVlrZYZHL)iHBRs(b8MdSR0CRw7DI80aPg6oUw82(m9xnovBhcx)TpiK3rKIsE07nZlOs0nw8GuO)J(O7B0xxsDhZFd24ojT0edInt0v0Di2gdPV000hi7Wqazj1RVr15cz23Cg8w0w4(jBF2WBO3TNncvDU5S(Q2V1v4WI9tFpw91OMRd7qoQY8t6gn509IdVQX)oIRZAby)945LZ02WvMwh19NkPn34KoFx9GOovomvuO7ohuAGAyMQs83gFaQiJFRuy3OBXEHg4YQAamS(mC0tn2ZVDxh2EEY9CAd1(4XFjzxU)z1rxR2LEtf6ox91sZnF5))c]] )

spec:RegisterPack( "Demonology", 20250323, [[Hekili:TRvBVTnos4FlbhG3BXMvBStC62CjbOTP7TPaB7I19WHdhwltlrBtejrbjQKZFX)2Vz4lsuVqj500D)WDFOnjsKCEHdFMNzOwoD5NxUiKiOl)4SZMn)SZNDU3zNnB28lxUqSpLUCrkj4bYw4xsiXW)FhnMNWJ4B3JVAFeNeIlroVilaE9YfRlyrI7twU256MNsdw(XxVCXowyivnsAEWYfFEhl)Wk8FKdR0Y9Wk(g4VdemEYHvrSCb86n8SdR(z6dSiM3YfYhkTd6gsrKa(1pkTlAczDenC5BxUqTaGS3NqsZP(5PzSKT5kjNXsvVvnQCp9c9D38dSKawcndmKtzBUrqY2sfWRxxSzJx(osi)jFssO)MiW54b)vYKTr7t35vnppJwSaKJGMXiWVX5r4G9IPcsmplDhpNL7LrJjSeW(U9WQlNUua(o0mka9LVzJ)2Gq0WkTLAt22AHjEEd7Vs2svFdncCbKSh8ksRwq8PslbxHl6FfQR52Rskx(tyjM7CjIjjeV0aXHvxFy1S5vtoITH6liP40V050HOnq)3rYcL(QPhwn5WQsdJLiOrrST0KakOzYxw6XdX4xFCbQC3GoCPCu5uHadl8sPcFXtqCf8xwbpWSwxKjTTxnSd(RNEueJtgKX2cWhGQZp6iEpOitg94l2r9Pr0yAIOzu)7WXOoNbJ6WQ3Rh2v3dpjHdVjbEknchuAg)rgmB9qvNeSTEZzJuW09FSicpeSgoNk2lpEG66RBOR1uMf4eHntophIoEIj2Dy1VupqV02iGiu)HpIbmymAvyI7ZDZu4j(k0oLzesIbKi)mUGycTNEwFgXB(07bDFhfqSUaCFayfimk()RrWTKWg2Kc0db4mXhJZkXh)iSVMqJz4EYT3ifODCMBlDAnlLWLN6N2e4S(MZN)nJDfrZvbbkB8RTLD9Z2WYHJoriMccDBVhcYlnJgWJxt6pLbc2aynpsrvSU)awvH(OWg22DLrS)K(OPovLCaYmNhwTawovuO2FbJnxWZI7gGtz7NxMmOB8WUWlKURtGJSqglse4n7faXDcJtCGhnQ1FxbacMnI8jiGjjd2q9QhKu(8(tOCI(GT0XfXsQNyR8P9NwP0sgdiCfaEz6GgzaRLrwOoI1tCM1cwpkBQxTGNRQcVCR8N4oFyxHswEBDSynnyMxvyki(FLcb6Xfia9AqCmqXIHClWVMrsqQIDOvDfJvtgN71a64Q)fVOFX4Giud(sdh75MlddIJJKag(KImsxXGLXys2Gk6t1TSlalBr1Bbh4)eGnPpsZWKUBSW0S1mdxtiUJaBCsyGx1v8Rrb2bBYByznL(CpKQS6vGOFdsFMffrZofeCel1aONqPH1zPQs(P0JCpZYlHyN3ffOsCDEwwHw6b7dkbFZLSxDT(vZsreQHzCPhWY7DLJbSeO8JyvQfcYyqb8AslrsKCPW0s9rpsV)spgf1mhhQ5SdRUxpIJtjfoZv1dOrLb0cY4tjAsDqPzGqi45hftg4rYGpblg(Df9mzwwmx99vUeB0vbl4bdOVMJNr21iWIJZhx4UGzAbQ8ZYmGOs(3lI(MqsI7dhwb6yfxaL2TfrWm668EtGgZmxtsKKHd58MqCi8ZBjgx2DWaUc)bsagWFkqUVmdbz1(dSBYt(gbwukc6gXrVdnHxSf2I)RtNJzqc4jH5FlmdyHaUgu5ijv7dO3YRhpTgea9N(cUFitD8B68Uq1AALKT8K9nmtvj2XucUDHg0EeKnGKintmPcbYwqnCAkWG2qa5tDUeDnvoP3GRVEfY3bzMGTsYJCwi6VKwat8mmUzZnzW0Xz27A68xUaHTHEAHb)oBCPouQ(axDJUpVf6(99Kp0jQUlW0Qgj0cPbLK5L1o3ajs5rceu)DYYoGI2cYBN1togFWLzyf4cLusFQJulVYZqN9NujxSvH7ObSyDCtlfq7g2rjrIDwncOQcTWYPRvUMvnoOd6hrslYmDq4PQQYqAknjug)HQ1EjYi2WQA59C2bNUQ7R50QIaRA8t9Gi)1GJVZATS93Y(mu3GETh6xxOF5HvFpCyzHKPTKDMIQ9HvxHq)yOvfNnaQIsYYLiQDxMHvFu6LSFVn3qVXzOXwwFrzL)tDxctj7D02ml4qc0TQ2VQ0xHkcxv93rw4w5CFBeNJL0vKThbcm4Re8uiMT)tzbw404G93aJTpk5olly2lFzbUYB2KgC7uN3xociVameqBgK(Et8ONv3A6jpOJIzU4zxmJZGQ(tk1dRJ5iR260oWZTs8Z)i4EC8zNvupCLM8)bOE4krTgkbhP(qyR01gW67QgtxbxSa)uyvRFeWkznqDi4bvZ(MwVNywmJb4RKAeZHmxDKIpODpKyjBOzjCF9O6ZFDX8w2VA2KOUsz3I8Wxj6)TsspmlUFSflUFXjKW4ktVv29Q5GQtT22In4RIdBR2I2rBADNiT5IJDoDKlEpTkfgiSNKJ)jEHExmD60xVCXtKSe11OPoCd882WIOQcjJz5QJI5fPPCSpPYEHc5BafnaIPYyjpGfuJOD3luts2q2yGKgg4bvidpgdg2JRnJdg5EC)iiQqEheuOCAA2vh(aqg6WQ)9)arkVxqJZ)9tX2AWc2zpAcczyKQgCL(FsJybmru16gQ2XLOqgH(3KDXxlMpRwc4i1VRBHB1JMzj5NyiewPfzaWndTQZWjfXRPzOGZJ4cVdF4(y0HHpyEJ7(eEjSzwi2XZwUyrCXMm2dyFSL(9YNG4xX8dF4Vab1VKTO(Whukdq4Y058V7MFWUb54TKA186Rp3XuQ3aA5S6Il3KtQ4VmWcPiWHR0jpVLQStZ4A0rpP7X4XwllLCREq39KQ4qGZQuVM0nF2oxcvpMHqsCtU6s5b8tswehZpC3VUaiCMIh3urcs4nZokIYzOA8w5Xl63hq0eOTRSuD)vvt)TqMiGJXORS6BLcV5DLdZGtnhcFIN9GNhGdWXJZGzJiictMDecoI9GKyaarGRM2HGU)QsQoUlOVDDAnw5xUB(xUjj4HapmsyicOrIkSO1aN2n(UqjbqbjIMa4adEzxbynfO)51NzaTqetyFSkghDs1)Ohq7P)v(2lNAp)AJ5uR8T3uByLF(a1oaz(mdShPk4TCyTz(BpyZNeaoCZ3nW1atnBdux3yD0NBNoXvXot65E4V(Yboh2n(1lROGqXV4RL3wH787aav7bUVEnaZG3kFnz1GJXPi7IB6SOANHatCx43TZKQ0x(DSpSodSTqnSoLQBV5IjdC8zQYP9cCB5dRJDtARTAF9y06bYMOddUtxb5VPfMCwJS9hvzZ6mGamZQ2Iixx3T5y4LYvE2tC3vjPmFED0yy9PrFu(cI(pUMymSMz6vsPk1DBoKY(p7MwmS1yx2UKxMU2)jTRJ9wqUkJAwRgmCL8n3lQ6Xa6Cb7RQ4KwTKiKsIWIFKaL4ZzyTgg1VSWIisUSeGImLnLFk2SdQYWLJiJeNk5eKqefz2jcKwTNou9p8UQmEVVSjqd5(NnFYjD3SfP51zBtgwfA2mM6H1vnyzs3nx52BMozOMQC90ZgTEyAksT6CA0NLUCoxOInpYwLmSAvVfknz0bs8OAhYWYZQVl2KP19m56xHjEgAnoMm0N)CxUXNm1qmcSGqzv0Ljdv1t7mjQjx5x41ZBzHDQZvzBO1oc64U7VU8E7lt6(8I4CPmdgY9N4fWpc1)zKr5)N3WvEJHCYVejoQFH)Jq4vneWwYAUbdDf)Jy9hgduNU7yUu)ri369XOv(oT764Uk)ri2YVzalJT66(H63NOZhBDn)LPEgDZLgHIu3(D3JMbxOgTAQ32i9YCv9JrPC15dh9a1zxkCs6FK47D1i2YUHQVt)EeF3Q7akLQpa83F8jFhQGsGwXxq5Jh3NlBtPAxkMvlR1PipQpr2Ml9yAKNEOJTu1sW2X9fU2umJcv84(ewBkcZhUQ8isNFsR3oxd((C)etBksRCj1(UsVzABLOASxFPwnEEFcPo2bPdRcMrE9LYB6B5)n]] )

spec:RegisterPack( "Destruction", 20250331, [[Hekili:1IvtVTTny4Fl5IHdsMNLtCAYwspmSdT9qV4Stdts0s0XeHsuGIYzEWq)23ljLiPPOSDb2qrtIiF5Z73Fqghf)A8QCKah)9fZxSC(D3fnlkA(J3)u8kX(kC8Qku27O3G)Oeva)83X1cEtMGWkL7TNYq5smQzn8my)4vRBiuXxlJxhg4pb0wHZI)oWHTK8CSMsCDw8Qx3sQBtL)h1M2X42u2g4BfhBtPKAbS9ggVn9l43juYmqm4SnekWCnv1ZQ44mwXAK4Mx(5nyAcIxW43s28Y6MnBMP(Awo7JYdhCwGJlqKY6NJECE73cHuDtrbRmHuujH6QkSygIs2HdtnLSbNiqkAlqLONFAeyRykvlmlzn01n8sfdvYA)kZAQcFeszgPeZbl)4qMSHWHTnealZBkt0FLiTX3k92Va)gySC5D4eCjUGGRFEXzpgIHhEUphD2ZjnzYdUfJOITZQYepVyPJyoR2AVmEZ1uglN2ulalYHdtfi(BGJXfI5tMQnD7lrv14K6koP8TAf9QnYXs)Q0WaRD91E8Z7y3cFN9I9iJiiQLeWjEhlsGa0m7Q7y0mujjlPI9bMFKJuXW)pXUlgoNXkERbXZnCWdo)J1f1fyzvSKbgNWZojcxOefCUmXXUm8bNTdw1GHjb8opUqarMcXZsMmnh3DC9AMdLHQfjcsb(gbj7D1Fnr(JebljNG)8YRHGdpBz)zxmzmuJwmzG93p(iJvUHIEJ3jH(qnWwUgvItyBu(a5b6IyDf2hGq2EnTyFI8eQ6vAHPlVsEE1QsnRJyxSbopj0Ys7tDIwdFoAq4EpTO3yL7hr(IwALVJOpap1R7X0dhcODdnSCEtvFY(vsiGeWE8T7A8woE(qYSFW7weWvW1vGDuZCOAeQmd)8JbjVVyCOYm(I)weRoznJkSvVxd90Y5OnYypGyVt42YyAbBNuBLTou4)48oVpDFnh9pmEcqbUaxk6dcmKg5lkYEGgfvHICL6ke)9HXNzn8ALNtSfkEtvSO2jYg6EtPj7AOYUmRHoWI9kjWpR10hsP(A1PVH7qDyGyCKm3zmoLbWTpb0aYjsElAhl72S9zuP1v63QFjYonGoBsrKNEOHPVTF5gmVerd0zB5KtxcTdNloEttphIPLIFF9vpMEVp9MYKb0u)Is6HFgRQ3utI0nx7ZfNKYX5JtUzil6LpRXrD)LPhQ2JiX2KmgHoClLnt(r8QDyEnSx)4NlGXn)aXlLTW7h0SBUr9eNfK6AyZ206MQkgx0nK5BGOWjzTPDE36zTPTPFvOpKAUkiemhNduSfblJbgVxInHXHudGUYmAdmFlSfbsP4)cOtP)uB6F(h1yjs4I6)6220p2sY26snQCVLRTPLmj4)DfLKreulU5Y)sYCSLP)km0mVNnVQHOnn6VKGM7U0cho)bHsD0Ooif9KQSgQLkBkwlBOdMkktmR9BFTqAWKlS0BsDytyQ8gXwgpE1xGaku8k1gYRmO8tVg)D1Dq0htErGEVB8kCjAnfNh)BXcWnEevooAxQesa2GAOcdW2TxLb2gWzI04ydZAtFgmfw09Ip1ICI((p1cJWCri)zWUFzid5gsOVBuOTnB0c8YldxLvszAmxd40ghDzrZLKAtpCOn1zXUYekHaUSKvkmx160MORGa1(7ozpS92vN2ki7YPy9toCUVZP8O37gOOVSGxO0YtjA(JX6iHDlkH4bxMyB15XOp5sLzq3bHSspFaps)bpQp2qhLF)lGc3cZsC)rJyH04jDwcVMAd9xDTfpTtZRzNY)9Odw2wJgp4LkR37Kf40XmKF24V6A45ICOoK6i)r6sQ0HPqjX(ELTP30MEDyR)dJij2gLbKfVUOHr(txSTce3lSIHQgNq97ZxOW9QrAdM0O4pESUI1CvC10(KSb3h3PuZr3jhSRktRxwDGWAte1XyFbsDWr4S7m4I1kEKjDw9c6Ptb(pJT2oLUmE8CMlkn28GaM8Mbv9oU0MFeTh)CFMkR24)waoBn(7bOcDUluD0tg(p90zUM3lqL26Kepr(L5AJ9LdV2eA75hDXCH60NIRrlSvwpow46aLNa97Xr1VHVZGBzfZtsib5PZvx2xHFWKOATIU3u3QeDfzmVfHRLk8Bs4AJg9Dj0gl)0ExYL6v08FuflA5qfZ)bmcjGdFedhj0PjXXgPaIUciLSpEz1R0XJQlJyfLHV3Hse8IChtTd2YrkgJpxWpwp7OZ28FqZaFS6NTkA8Az9ZN59okoAN5rxuin(KEG)x)Ock7w)tNOvY5oX3J8yd9(9Joy0itKgDMILUpgt8rttBnVJxO7mplJJTj0d7OaF8Qmxznt2Bbe61BconSe7Xl(4y)pLToSfP)FX)7p]] )


spec:RegisterPackSelector( "affliction", "Affliction", "|T136145:0|t Affliction",
    "If you have spent more points in |T136145:0|t Affliction than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "demonology", "Demonology", "|T136172:0|t Demonology",
    "If you have spent more points in |T136172:0|t Demonology than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "destruction", "Destruction", "|T136186:0|t Destruction",
    "If you have spent more points in |T136186:0|t Destruction than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )
