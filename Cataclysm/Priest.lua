if UnitClassBase( 'player' ) ~= 'PRIEST' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 5 )

-- Sets
spec:RegisterGear( "tier7", 39521, 39530, 39529, 39528, 39523, 40456, 40454, 40459, 40457, 40458 )
spec:RegisterGear( "tier9", 48755, 48756, 48757, 48758, 48759, 48078, 48077, 48081, 48079, 48080, 48085, 48086, 48082, 48084, 48083 )
spec:RegisterGear( "tier10", 51259, 51257, 51256, 51255, 51258, 51181, 51180, 51182, 51183, 51184, 51741, 51740, 51739, 51738, 51737 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    archangel                   = { 11608, 2, 87151, 81700 },
    atonement                   = { 11812, 2, 81749, 14523 },
    binding_prayers             = { 413,   2, 15018, 14911 },
    blessed_recovery            = { 1636,  3, 27811, 27815, 27816 },
    blessed_resilience          = { 11672, 2, 33145, 33142 },
    body_and_soul               = { 9587,  2, 64129, 64127 },
    borrowed_time               = { 1202,  3, 52797, 52798, 52795 },
    chakra                      = { 348,   1, 14751 },
    circle_of_healing           = { 1815,  1, 34861 },
    darkness                    = { 462,   3, 15308, 15307, 15259 },
    designer_notes              = { 7449,  1, 80556 },
    desperate_prayer            = { 2829,  1, 19236 },
    dispersion                  = { 9080,  1, 47585 },
    divine_accuracy             = { 7578,  2, 81762, 81763 },
    divine_aegis                = { 8609,  3, 47515, 47509, 47511 },
    divine_fury                 = { 9549,  3, 18530, 18531, 18533 },
    divine_providence           = { 1905,  5, 47562, 47567, 47565, 47564, 47566 },
    divine_touch                = { 1902,  2, 63534, 63542 },
    empowered_healing           = { 2859,  3, 33158, 33159, 33160 },
    evangelism                  = { 8593,  2, 81662, 81659 },
    focused_will                = { 8621,  2, 45243, 45234 },
    grace                       = { 8625,  2, 47517, 47516 },
    guardian_spirit             = { 9601,  1, 47788 },
    harnessed_shadows           = { 1816,  2, 33191, 78228 },
    heavenly_voice              = { 11668, 2, 87430, 87431 },
    holy_concentration          = { 1768,  2, 34859, 34753 },
    holy_reach                  = { 1635,  2, 27789, 27790 },
    holy_specialization         = { 2823,  5, 15008, 15009, 15010, 15011, 14889 },
    improved_devouring_plague   = { 9062,  2, 63626, 63625 },
    improved_healing            = { 408,   2, 14912, 15013 },
    improved_holy_nova          = { 7580,  2, 81766, 81830 },
    improved_mind_blast         = { 481,   3, 15312, 15273, 15313 },
    improved_power_word_shield  = { 10736, 2, 14768, 14748 },
    improved_psychic_scream     = { 9040,  2, 15448, 15392 },
    improved_renew              = { 10746, 2, 15020, 14908 },
    improved_shadow_word_pain   = { 482,   2, 15317, 15275 },
    inner_focus                 = { 8591,  1, 89485 },
    inner_sanctum               = { 346,   3, 14747, 14771, 14770 },
    inspiration                 = { 361,   2, 15362, 14892 },
    lightwell                   = { 1637,  1, 724 },
    masochism                   = { 11778, 2, 88995, 88994 },
    mental_agility              = { 341,   3, 14781, 14520, 14780 },
    mind_flay                   = { 501,   1, 15407 },
    mind_melt                   = { 1781,  2, 14910, 33371 },
    pain_and_suffering          = { 1909,  2, 47581, 47580 },
    pain_suppression            = { 1774,  1, 33206 },
    paralysis                   = { 11663, 2, 87192, 87195 },
    penance                     = { 1897,  1, 47540 },
    penitence                   = { 7576,  2, 81656, 81657 },
    phantasm                    = { 1906,  2, 47569, 47570 },
    power_infusion              = { 8611,  1, 10060 },
    power_word_barrier          = { 5564,  2, 62618, 14769 },
    psychic_horror              = { 1908,  1, 64044 },
    rapid_renewal               = { 14738, 1, 95649 },
    rapture                     = { 1896,  3, 47537, 47536, 47535 },
    reflective_shield           = { 2268,  2, 33202, 33201 },
    renewed_hope                = { 2235,  2, 57472, 57470 },
    revelations                 = { 11755, 1, 88627 },
    searing_light               = { 403,   3, 14909, 15017, 78069 },
    serendipity                 = { 1904,  2, 63733, 63730 },
    shadowform                  = { 521,   1, 15473 },
    shadowy_apparition          = { 5791,  3, 78204, 78202, 78203 },
    silence                     = { 98008, 1, 15487 },
    sin_and_punishment          = { 11605, 2, 87100, 87099 },
    soul_warding                = { 351,   3, 78501, 78500, 63574 },
    spirit_of_redemption        = { 1561,  1, 20711 },
    spiritual_guidance          = { 2845,  4, 15031, 15028, 15029, 15030 },
    strength_of_soul            = { 11813, 2, 89488, 89489 },
    surge_of_light              = { 11765, 2, 88690, 88687 },
    test_of_faith               = { 1903,  3, 47559, 47558, 47560 },
    thriving_light              = { 5795,  2, 78245, 78244 },
    tome_of_light               = { 12184, 2, 81625, 14898 },
    train_of_thought            = { 12183, 2, 92295, 92297 },
    twin_disciplines            = { 1898,  3, 47588, 47586, 47587 },
    twisted_faith               = { 1907,  2, 47577, 47573 },
    unbreakable_will            = { 342,   5, 14788, 14789, 14522, 14790, 14791 },
    vampiric_embrace            = { 484,   1, 15286 },
    vampiric_touch              = { 1779,  1, 34914 },
    veiled_shadows              = { 9046,  2, 15311, 15274 },
} )

-- Auras
spec:RegisterAuras( {
    -- Attempts to dispel $10872s1 disease every $t1 seconds.
    abolish_disease = {
        id = 552,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
    },
    absolution = {
        id = 33167,
        duration = 3600,
        max_stack = 1,

    },
    --
    archangel = {
        id = 81700,
        duration = 18,
        max_stack = 1,
    },
    -- Prevents you from being critically hit.
    blessed_resilience = {
        id = 33145,
        duration = 6,
        max_stack = 1,
        copy = { 33143 },
    },
    -- Movement speed increased by $s1%.
    body_and_soul = {
        id = 65081,
        duration = 4,
        max_stack = 1,
        copy = { 65081, 64128 },
    },
    -- $s1% spell haste until next spell cast.
    borrowed_time = {
        id = 52797,
        duration = 6,
        max_stack = 1,
        copy = { 59891, 59890, 59889, 59888, 59887 },
    },
    -- Causes $s1 damage every $t1 seconds, healing the caster.
    devouring_plague = {
        id = 2944,
        duration = function() return 30 * spell_haste end,
        tick_time = function() return 3 * ( buff.shadowform.up and spell_haste or 1 ) end,
        max_stack = 1,

        generate = function ( t )
            local applied = action.devouring_plague.lastCast

            if active_dot.devouring_plague == 0 then
                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
                return
            end

            if applied and now - applied < 30 * spell_haste then
                t.count = 1
                t.expires = applied + 30 * spell_haste
                t.applied = applied
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,

        copy = { 2944, 19276, 19277, 19278, 19279, 19280, 25467, 48299, 48300 },
    },
    dark_archangel = {
        id = 87153,
        duration = 18,
        max_stack = 1,
   },
    -- Reduces all damage by $s1%, and you regenerate $49766s1% mana every $60069t1 sec for $d.  Cannot attack or cast spells. Immune to snare and movement impairing effects.
    dispersion = {
        id = 47585,
        duration = 6,
        max_stack = 1,
    },
    divine_fury = { 
        id = 18533,
        duration = 3600,
        max_stack = 1,
        copy = { 18535, 18534, 18533, 18531, 18530 },
    },
    -- Healing received increased by $s2%.
    divine_hymn = {
        id = 64844,
        duration = 8,
        max_stack = 1,
        copy = { 64844, 64843 },
    },
    dark_evangelism = {
        id = 87118,
        duration = 18,
        max_stack = 5,
    },
    -- %d% increased periodic shadow damage.
    empowered_shadow = {
        id = 95799,
        duration = 15,
        max_stack = 1,
    },
    -- Increases the damage done by your Smite, Holy Fire and Penance spells by 4% and reduces the mana cost of those spells by 6%.
    evangelism = {
        id = 81661,
        duration = 18,
        max_stack = 5,
    },
    -- Reduced threat level.
    fade = {
        id = 586,
        duration = 10,
        max_stack = 1,
    },
    -- Warded against Fear.
    fear_ward = {
        id = 6346,
        duration = 180,
        max_stack = 1,
    },
    -- Cannot lose casting time from taking damage while casting Priest spells and decreases the duration of Interrupt effects by $s2%.
    focused_casting = {
        id = 27828,
        duration = 6,
        max_stack = 1,
        copy = { 14743, 27828 },
    },
    -- All damage reduced by $s1%.  Healing effects increased by $s2%.
    focused_will = {
        id = 45242,
        duration = 8,
        max_stack = 3,
        copy = { 45237, 45241, 45242 },
    },
    -- Increases all healing received by the Priest by $s2%.
    grace = {
        id = 47930,
        duration = 15,
        max_stack = 3,
    },
    -- Increased healing received by $s1% and will prevent 1 killing blow.
    guardian_spirit = {
        id = 47788,
        duration = 10,
        max_stack = 1,
    },
    healing_prayers = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=15018)
        id = 15018,
        duration = 3600,
        max_stack = 1,
        copy = { 15018, 14911 },
    },
    -- Mana regeneration increased by $s1%.
    holy_concentration = {
        id = 63725,
        duration = 8,
        max_stack = 1,
        copy = { 63725, 63724, 34754 },
    },
    -- $s2 Holy damage every $t2 seconds.
    holy_fire = {
        id = 14914,
        duration = 7,
        max_stack = 1,
        copy = { 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 25384, 48134, 48135 },
    },
    holy_specialization = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=15011)
        id = 15011,
        duration = 3600,
        max_stack = 1,
        copy = { 15011, 15010, 15009, 15008, 14889 },
    },
    -- Maximum mana increased by $s2%.
    hymn_of_hope = {
        id = 64904,
        duration = function() return glyph.hymn_of_hope.enabled and 10 or 8 end,
        max_stack = 1,
        copy = { 64904, 64901 },
    },
    improved_mana_burn = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=14772)
        id = 14772,
        duration = 3600,
        max_stack = 1,
        copy = { 14772, 14750 },
    },
    improved_power_word_shield = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=14769)
        id = 14769,
        duration = 3600,
        max_stack = 1,
        copy = { 14769, 14768, 14748 },
    },
    improved_psychic_scream = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=15448)
        id = 15448,
        duration = 3600,
        max_stack = 1,
        copy = { 15448, 15392 },
    },
    improved_renew = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=17191)
        id = 17191,
        duration = 3600,
        max_stack = 1,
        copy = { 17191, 15020, 14908 },
    },
    -- Spirit increased by $s1% and allows $s2% mana regeneration while casting.
    improved_spirit_tap = {
        id = 59000,
        duration = 8,
        max_stack = 1,
        copy = { 49694, 59000 },
    },
    -- Increases armor by $s1.
    inner_fire = {
        id = 588,
        duration = 1800,
        max_stack = 32,
        copy = { 588, 602, 1006, 7128, 10951, 10952, 25431, 48040, 48168 },
    },
    -- The mana cost of your next spell is reduced by $s1%.
    inner_focus = {
        id = 14751,
        duration = 3600,
        max_stack = 1,
    },
    -- Reduces physical damage taken by $s1%.
    inspiration = {
        id = 15359,
        duration = 15,
        max_stack = 1,
        copy = { 14893, 15357, 15359 },
    },
    -- Levitating.
    levitate = {
        id = 1706,
        duration = 120,
        max_stack = 1,
    },
    lightwell = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=724)
        id = 724,
        duration = 180,
        max_stack = 1,
    },
    -- Charmed.  Time between attacks increased by $s3%.
    mind_control = {
        id = 605,
        duration = 60,
        max_stack = 1,
    },
    -- Movement speed slowed.
    mind_flay = {
        id = 15407,
        duration = function() return ( 3 - ( set_bonus.tier10_4pc == 1 and 0.5 or 0 ) ) * spell_haste end,
        tick_time = function() return ( 1 - ( set_bonus.tier10_4pc == 1 and 0.17 or 0 ) ) * spell_haste end,
        max_stack = 1,
        copy = { 15407, 17311, 17312, 17313, 17314, 18807, 25387, 48155, 48156, 58381 },
    },
    -- Spell haste increased by 5%.
    mind_quickening = {
        id = 49868,
        duration = 3600,
        max_stack = 1,
    },
    -- Causing shadow damage to all targets within $49821a1 yards.
    mind_sear = {
        id = 48045,
        duration = function() return 5 * spell_haste end,
        tick_time = function() return 1 * spell_haste end,
        max_stack = 1,
        copy = { 48045, 49821, 53022, 53023, 60441 },
    },
    -- Reduced distance at which target will attack.
    mind_soothe = {
        id = 453,
        duration = 15,
        max_stack = 1,
    },
    -- Chance for the next Mind Blast from the Priest to critically hit increased by 30%.
    mind_spike = { 
        id = 73510,
        duration = 3600,
        max_stack = 3,
        copy = { 87178, 87179 },
    },
    -- Sight granted through target's eyes.
    mind_vision = {
        id = 2096,
        duration = 60,
        max_stack = 1,
        copy = { 2096, 10909 },
    },

    mind_spike = { 
        id = 73510,
        duration = 3600,
        max_stack = 3,
        copy = { 87178, 87179 },
    },
    -- Chance to hit with spells on the target increased by $s1%.
    misery = {
        id = 33198,
        duration = 24,
        max_stack = 1,
        copy = { 33196, 33197, 33198 },
    },
    -- All damage taken reduced by $s1% and resistance to Dispel mechanics increased by $s2%.
    pain_suppression = {
        id = 33206,
        duration = 8,
        max_stack = 1,
    },
    -- Spell casting speed increased by $s1% and mana cost of spells reduced by $s2%.
    power_infusion = {
        id = 10060,
        duration = 15,
        max_stack = 1,
    },
    -- Absorbs damage.
    power_word_shield = {
        id = 17,
        duration = 30,
        max_stack = 1,
        copy = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218, 27607, 48065, 48066 },
    },

    power_word_fortitude = {
        id = 79105,
        duration = 60,
        max_stack = 1,
        copy = { 1244, 1245, 2791, 10937, 10938, 21562, 25389, 48161, 79014, 79105 },
    },
    -- Increases Shadow Resistance by $s1.
    prayer_of_shadow_protection = {
        id = 27683,
        duration = function() return glyph.shadow_protection.enabled and 1800 or 1200 end,
        max_stack = 1,
        copy = { 27683, 39236, 39374, 48170 },
    },
    -- Disarmed.
    psychic_horror = {
        id = 64058,
        duration = 10,
        max_stack = 1,
        copy = { 64058, 64044 },
    },
    -- Running in Fear.
    psychic_scream = {
        id = 8122,
        duration = function() return glyph.psychic_scream.enabled and 10 or 8 end,
        max_stack = 1,
        copy = { 8122, 8124, 10888, 10890, 27610 },
    },
    -- Healing $s1 damage every $t1 seconds.
    renew = {
        id = 139,
        duration = function() return glyph.renew.enabled and 12 or 15 end,
        tick_time = 3,
        max_stack = 1,
        copy = { 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25221, 25222, 25315, 27606, 48067, 48068 },
    },
    -- Reduces all damage taken by $s1%.
    renewed_hope = {
        id = 63944,
        duration = 60,
        max_stack = 1,
    },
    -- Reduces the cast time of your next Greater Heal or Prayer of Healing by $s1%.
    serendipity = {
        id = 63735,
        duration = 20,
        max_stack = 3,
        copy = { 63735, 63734, 63731 },
    },
    -- Shackled.
    shackle_undead = {
        id = 9484,
        duration = 30,
        max_stack = 1,
        copy = { 9484, 9485, 10955 },
    },
    -- Consumed to increase damage done by Mind Blast or Mind Spike.
    shadow_orb = {
        id = 77487,
        duration = 60,
        max_stack = 3,
    },
    -- Shadow resistance increased by $s1.
    shadow_protection = {
        id = 976,
        duration = function() return glyph.shadow_protection.enabled and 1200 or 600 end,
        max_stack = 1,
        copy = { 976, 7235, 7241, 7242, 7243, 7244, 10957, 10958, 16874, 25433, 48169 },
    },
    -- Increases Shadow damage done by $s1%.
    shadow_weaving = {
        id = 15258,
        duration = 15,
        max_stack = 5,
        copy = { 15258 },
    },
    -- $s1 Shadow damage every $t1 seconds.
    shadow_word_pain = {
        id = 589,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
        copy = { 589, 594, 970, 992, 2767, 10892, 10893, 10894, 25367, 25368, 27605, 48124, 48125 },
    },
    shadowfiend = {
        duration = 15,
        max_stack = 1,
    },
    -- Shadow damage you deal increased by $s2%.  All damage you take reduced by $s3% and threat generated is reduced by $49868s1%. You may not cast Holy spells except Cure Disease and Abolish Disease.  Grants the periodic damage from your Shadow Word: Pain, Devouring Plague, and Vampiric Touch spells the ability to critically hit for $49868s2% increased damage and grants Devouring Plague and Vampiric Touch the ability to benefit from haste.
    shadowform = {
        id = 15473,
        duration = 3600,
        max_stack = 1,
    },
    -- Glyph of Shadow
    shadowy_insight = {
        id = 61792,
        duration = 10,
        max_stack = 1,
    },
    -- Silenced.
    silence = {
        id = 15487,
        duration = 5,
        max_stack = 1,
    },
    spell_warding = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=27904)
        id = 27904,
        duration = 3600,
        max_stack = 1,
        copy = { 27904, 27903, 27902, 27901, 27900 },
    },
    -- Spirit increased by $s1% and allows $s2% of mana regeneration while casting.
    spirit_tap = {
        id = 15271,
        duration = 15,
        max_stack = 1,
        copy = { 15271 },
    },
    -- Spirit of Redemption
    spirit_of_redemption = {
        id = 27827,
        duration = function() return glyph.spirit_of_redemption.enabled and 21 or 15 end,
        max_stack = 1,
    },
    -- Your next Smite or Flash Heal spell is instant cast, costs no mana but is incapable of a critical hit.
    surge_of_light = {
        id = 33151,
        duration = 10,
        max_stack = 1,
        copy = { 33151 },
    },
    -- $15286s1% of single-target Shadow spell damage caused by casting priest heals the priest and $/5;15286s1% heals the group.
    vampiric_embrace = {
        id = 15286,
        duration = 1800,
        max_stack = 1,
    },
    -- $s2 Shadow damage every $t2 seconds. Priest's party or raid members gain 1% of their maximum mana per 5 sec when the priest deals damage from Mind Blast.
    vampiric_touch = {
        id = 34914,
        duration = function() return ( 15 + ( set_bonus.tier9_2pc == 1 and 6 or 0 ) ) * ( buff.shadowform.up and spell_haste or 1 ) end,
        max_stack = 1,
        tick_time = function() return 3 * ( buff.shadowform.up and spell_haste or 1 ) end,
        copy = { 34914, 34916, 34917, 48159, 48160 },
    },
} )

-- Glyphs
spec:RegisterGlyphs( {
    [55675]  = "circle_of_healing",
    [63248]  = "desperation",
    [55677]  = "dispel_magic",
    [63229]  = "dispersion",
    [63246]  = "divine_accuracy",
    [55684]  = "fade",
    [57985]  = "fading",
    [55678]  = "fear_ward",
    [55679]  = "flash_heal",
    [58009]  = "fortitude",
    [63231]  = "guardian_spirit",
    [55683]  = "holy_nova",
    [55686]  = "inner_fire",
    [57987]  = "levitate",
    [55673]  = "lightwell",
    [55691]  = "mass_dispel",
    [55687]  = "mind_flay",
    [63235]  = "penance",
    [55689]  = "power_word:_barrier",
    [55672]  = "power_word:_shield",
    [55680]  = "prayer_of_healing",
    [55685]  = "prayer_of_mending",
    [55688]  = "psychic_horror",
    [55676]  = "psychic_scream",
    [55674]  = "renew",
    [55690]  = "scourge_imprisonment",
    [57986]  = "shackle_undead",
    [107906] = "shadow",
    [58015]  = "shadow_protection",
    [55682]  = "shadow_word:_death",
    [55681]  = "shadow_word:_pain",
    [58228]  = "shadowfiend",
    [55692]  = "smite",
    [63237]  = "spirit_tap"
} )

-- Abilities
spec:RegisterAbilities( {
    -- Consumes your Evangelism effects, causing an effect depending on what type of Evangelism effect is consumed:
    -- Archangel (Evangelism):Instantly restores 1% of your total mana and increases your healing done by 3% for each stack. Lasts for 18 sec. 30 sec cooldown.
    -- Dark Archangel (Dark Evangelism):Instantly restores 5% of your total mana and increases the damage done by your Mind Flay, Mind Spike, Mind Blast and Shadow Word: Death by 4% for each stack. Lasts for 18 sec. 90 sec cooldown.
    archangel = {
        id = 87151,
        cast = 0,
        cooldown = function() return buff.dark_evangelism.up and 90 or 30 end,
        gcd = "spell",

        startsCombat = false,
        texture = 458225,
        talent = "archangel",

        handler = function ()
            if buff.dark_evangelism.stacks > 0 then
                    applyBuff("dark_archangel", 18)
            elseif buff.evangelism.stacks > 0 then
                    applyBuff("archangel", 18)
            end
            removeBuff("dark_evangelism")
            removeBuff("evangelism")
        end,
        copy = { 81700, 87151, 87152, 87153 },
    },
    -- Heals a friendly target and the caster for 1055 to 1352.  Low threat.
    binding_heal = {
        id = 32546,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.27,
        spendType = "mana",

        startsCombat = false,
        texture = 135883,

        handler = function ()
        end,

        copy = { 48119, 48120 },
    },


    -- Heals up to 5 friendly party or raid members within 15 yards of the target for 347 to 383.
    circle_of_healing = {
        id = 34861,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        talent = "circle_of_healing",
        startsCombat = false,
        texture = 135887,

        handler = function ()
        end,
    },


    -- Removes 1 disease from the friendly target.
    cure_disease = {
        id = 528,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = false,
        texture = 135935,

        handler = function ()
        end,
    },


    -- Instantly heals the caster for 263 to 325.
    desperate_prayer = {
        id = 19236,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        talent = "desperate_prayer",
        startsCombat = false,
        texture = 135954,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Afflicts the target with a disease that causes 152 Shadow damage over 24 sec. 15% of damage caused by the Devouring Plague heals the caster. This spell can only affect one target at a time.
    devouring_plague = {
        id = 2944,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = true,
        texture = 252997,

        handler = function ()
            if talent.shadow_weaving.rank == 3 then
                addStack( "shadow_weaving" )
            end
            applyDebuff( "target", "devouring_plague" )
        end,

        copy = { 19276, 19277, 19278, 19279, 19280, 25467, 48299, 48300 },
    },


    -- Dispels magic on the target, removing 1 harmful spell from a friend or 1 beneficial spell from an enemy.
    dispel_magic = {
        id = 527,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = true,
        texture = 135894,
        buff = "dispellable_magic",

        handler = function ()
            if glyph.dispel_magic.enabled then health.current = min( health.max, health.current + 0.03 * health.max ) end
            removeBuff( "dispellable_magic" )
        end,

        copy = { 988 },
    },


    -- You disperse into pure Shadow energy, reducing all damage taken by 90%.  You are unable to attack or cast spells, but you regenerate 6% mana every 1 sec for 6 sec. Dispersion can be cast while stunned, feared or silenced and clears all snare and movement impairing effects when cast, and makes you immune to them while dispersed.
    dispersion = {
        id = 47585,
        cast = 0,
        cooldown = function() return glyph.dispersion.enabled and 75 or 120 end,
        gcd = "spell",

        talent = "dispersion",
        startsCombat = false,
        texture = 237563,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Heals 3 nearby lowest health friendly party or raid targets within 40 yards for 3024 to 3342 every 2 sec for 8 sec, and increases healing done to them by 10% for 8 sec. Maximum of 12 heals. The Priest must channel to maintain the spell.
    divine_hymn = {
        id = 64843,
        cast = 0,
        cooldown = 480,
        gcd = "spell",

        spend = 0.63,
        spendType = "mana",

        startsCombat = false,
        texture = 237540,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Fade out, temporarily reducing all your threat for 10 sec.
    fade = {
        id = 586,
        cast = 0,
        cooldown = function() return glyph.fade.enabled and 21 or 30 end,
        gcd = "spell",

        spend = function() return glyph.fading.enabled and 0.105 or 0.15 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135994,

        handler = function ()
        end,
    },


    -- Wards the friendly target against Fear.  The next Fear effect used against the target will fail, using up the ward.  Lasts 3 min.
    fear_ward = {
        id = 6346,
        cast = 0,
        cooldown = function() return glyph.fear_ward.enabled and 120 or 180 end,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135902,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Heals a friendly target for 202 to 247.
    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.flash_heal.enabled and 0.162 or 0.18 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
        end,

        copy = { 9472, 9473, 9474, 10915, 10916, 10917, 25233, 25235, 48070, 48071 },
    },


    -- A slow casting spell that heals a single target for 924 to 1039.
    greater_heal = {
        id = 2060,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.32,
        spendType = "mana",

        startsCombat = false,
        texture = 135913,

        handler = function ()
        end,

        copy = { 10963, 10964, 10965, 25314, 25210, 25213, 48062, 48063 },
    },


    -- Calls upon a guardian spirit to watch over the friendly target. The spirit increases the healing received by the target by 40%, and also prevents the target from dying by sacrificing itself.  This sacrifice terminates the effect but heals the target of 50% of their maximum health. Lasts 10 sec.
    guardian_spirit = {
        id = 47788,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.06,
        spendType = "mana",

        talent = "guardian_spirit",
        startsCombat = false,
        texture = 237542,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Heal your target for 307 to 353.
    heal = {
        id = 2050,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.32,
        spendType = "mana",

        startsCombat = false,
        texture = 135915,

        handler = function ()
        end,

        copy = { 2055, 6063, 6064 },
    },


    -- Consumes the enemy in Holy flames that cause 108 to 134 Holy damage and an additional 21 Holy damage over 7 sec.
    holy_fire = {
        id = 14914,
        cast = 2,
        cooldown = 10,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        startsCombat = true,
        texture = 135972,

        handler = function ()
        end,

        copy = { 15262, 15263, 15264, 15265, 15266, 15267, 15261, 25384, 48134, 48135 },
    },


    -- Causes an explosion of holy light around the caster, causing 29 to 34 Holy damage to all enemy targets within 10 yards and healing all party members within 10 yards for 54 to 63.  These effects cause no threat.
    holy_nova = {
        id = 15237,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = true,
        texture = 135922,

        handler = function ()
        end,

        copy = { 15430, 15431, 27799, 27800, 27801, 25331, 48077, 48078 },
    },


    -- Restores 3% mana to 3 nearby low mana friendly party or raid targets every 2 sec for 8 sec, and increases their total maximum mana by 20% for 8 sec. Maximum of 12 mana restores. The Priest must channel to maintain the spell.
    hymn_of_hope = {
        id = 64901,
        cast = function() return glyph.hymn_of_hope.enabled and 10 or 8 end,
        channeled = true,
        cooldown = 360,
        gcd = "spell",

        startsCombat = false,
        texture = 135982,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- A burst of Holy energy fills the caster, increasing armor by 315.  Each melee or ranged damage hit against the priest will remove one charge.  Lasts 30 min or until 20 charges are used.
    inner_fire = {
        id = 588,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = false,
        texture = 135926,

        handler = function ()
            applyBuff( "inner_fire", nil, 20 + ( talent.inner_fire.rank * 4 ) )
        end,

        copy = { 7128, 602, 1006, 10951, 10952, 25431, 48040, 48168 },
    },


    -- When activated, reduces the mana cost of your next spell by 100% and increases its critical effect chance by 25% if it is capable of a critical effect.
    inner_focus = {
        id = 14751,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "inner_focus",
        startsCombat = false,
        texture = 135863,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "inner_focus" )
        end,
    },


    -- Heal your target for 47 to 58.
    lesser_heal = {
        id = 2050,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        startsCombat = false,
        texture = 135929,

        handler = function ()
        end,

        copy = { 2052, 2053 },
    },


    -- Allows the friendly party or raid target to levitate, floating a few feet above the ground.  While levitating, the target will fall at a reduced speed and travel over water.  Any damage will cancel the effect.  Lasts 2 min.
    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135928,

        handler = function ()
            -- TODO: glyph.levitate.enabled removes reagent requirement.
        end,
    },


    -- Creates a Holy Lightwell.  Friendly players can click the Lightwell to restore 801 health over 6 sec.  Attacks done to you equal to 30% of your total health will cancel the effect. Lightwell lasts for 3 min or 10 charges.
    lightwell = {
        id = 724,
        cast = 0.5,
        cooldown = 180,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        talent = "lightwell",
        startsCombat = false,
        texture = 135980,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Destroy 10% of the target's mana (up to a maximum of 20% of your own maximum mana). For each mana destroyed in this way, the target takes 0.5 Shadow damage.
    mana_burn = {
        id = 8129,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = true,
        texture = 136170,

        handler = function ()
        end,
    },


    -- Dispels magic in a 15 yard radius, removing 1 harmful spell from each friendly target and 1 beneficial spell from each enemy target.  Affects a maximum of 10 friendly targets and 10 enemy targets.  This dispel is potent enough to remove Magic effects that are normally undispellable.
    mass_dispel = {
        id = 32375,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.33 * ( glyph.mass_dispel.enabled and 0.65 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135739,

        handler = function ()
        end,
    },


    -- Blasts the target for 42 to 46 Shadow damage.
    mind_blast = {
        id = 8092,
        cast = function() return 1.5 * haste end,
        cooldown = function() return 8 - ( 0.5 * talent.improved_mind_blast.rank ) end,
        gcd = "spell",

        spend = function() return 0.17 * ( set_bonus.tier7_2pc == 1 and 0.90 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136224,

        handler = function ()
        end,

        copy = { 8102, 8103, 8104, 8105, 8106, 10945, 10946, 10947, 25372, 25375, 48126, 48127 },
    },


    -- Controls a humanoid mind up to level 82, but increases the time between its attacks by 25%.  Lasts up to 1 min.
    mind_control = {
        id = 605,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 136206,

        handler = function ()
        end,
    },


    -- Assault the target's mind with Shadow energy, causing 45 Shadow damage over 3 sec and slowing their movement speed by 50%.
    mind_flay = {
        id = 15407,
        cast = function () return class.auras.mind_flay.duration end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "mind_flay",
        startsCombat = true,
        texture = 136208,

        aura = "mind_flay",
        tick_time = function () return class.auras.mind_flay.tick_time end,

        start = function ()
            applyDebuff( "target", "mind_flay" )
            if talent.pain_and_suffering.rank == 3 then
                applyDebuff( "shadow_word_pain" )
            end
        end,

        tick = function ()
            if talent.shadow_weaving.rank == 3 then
                addStack( "shadow_weaving" )
            end
        end,

        breakchannel = function ()
            removeDebuff( "target", "mind_flay" )
        end,

        handler = function ()
        end,

        copy = { 17311, 17312, 17313, 17314, 18807, 25387, 48155, 48156 }
    },


    -- Causes an explosion of shadow magic around the enemy target, causing 183 to 197 Shadow damage every 1 sec for 5 sec to all enemies within 10 yards around the target.
    mind_sear = {
        id = 48045,
        cast = function() return 5 * spell_haste end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",

        spend = 0.28,
        spendType = "mana",

        startsCombat = true,
        texture = 237565,

        aura = "mind_sear",
        tick_time = function () return class.auras.mind_sear.tick_time end,

        start = function ()
            applyDebuff( "target", "mind_sear" )
        end,

        tick = function ()
            if talent.shadow_weaving.rank == 3 then
                addStack( "shadow_weaving" )
            end
        end,

        breakchannel = function ()
            removeDebuff( "target", "mind_sear" )
        end,

        handler = function ()
        end,

        copy = { 53023 },
    },


    -- Soothes the target, reducing the range at which it will attack you by 10 yards.  Only affects Humanoid targets.  Lasts 15 sec.
    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135933,

        handler = function ()
        end,
    },


    -- Allows the caster to see through the target's eyes for 1 min.
    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135934,

        handler = function ()
        end,

        copy = { 10909 },
    },


    -- Instantly reduces a friendly target's threat by 5%, reduces all damage taken by 40% and increases resistance to Dispel mechanics by 65% for 8 sec.
    pain_suppression = {
        id = 33206,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "pain_suppression",
        startsCombat = false,
        texture = 135936,

        toggle = "defensives",

        handler = function ()
            applyBuff( "pain_suppression" )
        end,
    },
    -- Blasts the target for 1213 Shadowfrost damage, but extinguishes your shadow damage-over-time effects from the target in the process. Mind Spike also increases the critical strike chance of your next Mind Blast on the target by 30%. Stacks up to 3 times.
    mind_spike = {
        id = 73510,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 457655    ,

        handler = function ()
            applyDebuff("target", "mind_spike")
        end,
    },
    -- Launches a volley of holy light at the target, causing 240 Holy damage to an enemy, or 670 to 756 healing to an ally instantly and every 1 sec for 2 sec.
    penance = {
        id = 47540,
        cast = function() return 2 * haste end,
        channeled = true,
        cooldown = function() return glyph.penance.enabled and 10 or 12 end,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        talent = "penance",
        startsCombat = true,
        texture = 237545,

        start = function ()
            applyDebuff( "target", "penance" )
        end,
    },


    -- Infuses the target with power, increasing spell casting speed by 20% and reducing the mana cost of all spells by 20%.  Lasts 15 sec.
    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.16,
        spendType = "mana",

        talent = "power_infusion",
        startsCombat = false,
        texture = 135939,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "power_infusion" )
        end,
    },


    -- Power infuses the target, increasing their Stamina by 3 for 30 min.
    power_word_fortitude = {
        id = 79105,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.fortitude.enabled and 0.135 or 0.27 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135987,

        handler = function ()
            applyBuff( "power_word_fortitude" )
        end,

        copy = { 1244, 1245, 2791, 10937, 10938, 21562, 25389, 48161, 79014, 79105 },
    },


    -- Draws on the soul of the friendly target to shield them, absorbing 48 damage.  Lasts 30 sec.  While the shield holds, spellcasting will not be interrupted by damage.  Once shielded, the target cannot be shielded again for 15 sec.
    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = 4,
        gcd = "spell",

        spend = 0.23,
        spendType = "mana",

        startsCombat = false,
        texture = 135940,

        handler = function ()
            -- if glyph.power_word_shield.enabled then health.current = min( health.max, health.current + some_amount_of_healing ) end
            applyBuff( "power_word_shield" )
            applyDebuff( "player", "weakened_soul" )
        end,

        copy = { 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218, 48065, 48066 },
    },

    -- A powerful prayer heals the friendly target's party members within 30 yards for 312 to 333.
    prayer_of_healing = {
        id = 596,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.48,
        spendType = "mana",

        startsCombat = false,
        texture = 135943,

        handler = function ()
        end,

        copy = { 996, 10960, 10961, 25316, 25308, 48072 },
    },


    -- Places a spell on the target that heals them for 800 the next time they take damage.  When the heal occurs, Prayer of Mending jumps to a party or raid member within 20 yards.  Jumps up to 5 times and lasts 30 sec after each jump.  This spell can only be placed on one target at a time.
    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 135944,

        handler = function ()
        end,

        copy = { 48112, 48113 },
    },


    -- Power infuses the target's party and raid members, increasing their Shadow resistance by 60 for 20 min.
    prayer_of_shadow_protection = {
        id = 27683,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.62,
        spendType = "mana",

        startsCombat = false,
        texture = 135945,

        handler = function ()
            applyBuff( "prayer_of_shadow_protection" )
        end,

        copy = { 39374, 48170 },
    },


    -- You terrify the target, causing them to tremble in horror for 3 sec and drop their main hand and ranged weapons for 10 sec.
    psychic_horror = {
        id = 64044,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        talent = "psychic_horror",
        startsCombat = true,
        texture = 237568,

        toggle = "interrupts",

        handler = function ()
        end,
    },


    -- The caster lets out a psychic scream, causing 2 enemies within 8 yards to flee for 8 sec.  Damage caused may interrupt the effect.
    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = function() return glyph.psychic_scream.enabled and 22 or 30 end,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = true,
        texture = 136184,
        toggle = "interrupts",

        handler = function ()
        end,

        copy = { 8124, 10888, 10890 },
    },


    -- Heals the target for 45 over 15 sec.
    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = false,
        texture = 135953,

        handler = function ()
        end,

        copy = { 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, 25221, 25222, 48067, 48068 },
    },


    -- Brings a dead player back to life with 70 health and 135 mana.  Cannot be cast when in combat.
    resurrection = {
        id = 2006,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.6,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,

        copy = { 2010, 10880, 10881, 20770, 25435, 48171 },
    },


    -- Shackles the target undead enemy for up to 30 sec.  The shackled unit is unable to move, attack or cast spells.  Any damage caused will release the target.  Only one target can be shackled at a time.
    shackle_undead = {
        id = 9484,
        cast = function() return glyph.scourge_imprisonment.enabled and 0.5 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 136091,
        toggle = "interrupts",

        handler = function ()
        end,

        copy = { 9485, 10955 },
    },


    -- Increases the target's resistance to Shadow spells by 30 for 10 min.
    shadowfiend = {
        id = 34433,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136199,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "shadowfiend" )
        end,

        copy = {},
    },


    -- Increases the target's resistance to Shadow spells by 30 for 10 min.
    shadow_protection = {
        id = 27683,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.31,
        spendType = "mana",

        startsCombat = false,
        texture = 136121,

        handler = function ()
            applyBuff( "shadow_protection" )
        end,

        copy = { 10957, 10958, 25433, 48169 },
    },


    -- A word of dark binding that inflicts 450 to 522 Shadow damage to the target.  If the target is not killed by Shadow Word: Death, the caster takes damage equal to the damage inflicted upon the target.
    shadow_word_death = {
        id = 32379,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,
        texture = 136149,

        handler = function ()

        end,

        copy = { 32996, 48157, 48158 },
    },


    -- A word of darkness that causes 30 Shadow damage over 18 sec.
    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = true,
        texture = 136207,

        handler = function ()
            applyDebuff( "target", "shadow_word_pain" )
        end,

        copy = { 594, 970, 992, 2767, 10892, 10893, 10894, 25367, 25368, 48124, 48125 },
    },


    -- Assume a Shadowform, increasing your Shadow damage by 15%, reducing all damage done to you by 15% and threat generated by 30%.  However, you may not cast Holy spells while in this form except Cure Disease and Abolish Disease.  Grants the periodic damage from your Shadow Word: Pain, Devouring Plague, and Vampiric Touch spells the ability to critically hit for 100% increased damage and grants Devouring Plague and Vampiric Touch the ability to benefit from haste.
    shadowform = {
        id = 15473,
        cast = 0,
        cooldown = 1.5,
        gcd = "spell",

        spend = 0.13,
        spendType = "mana",

        talent = "shadowform",
        startsCombat = false,
        texture = 136200,

        handler = function ()
            applyBuff( "shadowform" )
        end,
    },


    -- Silences the target, preventing them from casting spells for 5 sec.  Non-player victim spellcasting is also interrupted for 3 sec.
    silence = {
        id = 15487,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 225,
        spendType = "mana",

        talent = "silence",
        startsCombat = true,
        texture = 136164,
        toggle = "interrupts",

        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "silence" )
        end,
    },


    -- Smite an enemy for 15 to 20 Holy damage.
    smite = {
        id = 585,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 135924,

        handler = function ()
        end,

        copy = { 591, 598, 984, 1004, 6060, 10933, 10934, 25363, 25364, 48122, 48123 },
    },


    -- Fills you with the embrace of Shadow energy, causing you to be healed for 15% and other party members to be healed for 3% of any single-target Shadow spell damage you deal for 30 min.
    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "vampiric_embrace",
        startsCombat = false,
        texture = 136230,
        essential = true,

        handler = function ()
            applyBuff( "vampiric_embrace" )
        end,
    },


    -- Causes 450 Shadow damage over 15 sec to your target and causes up to 10 party or raid members to gain 1% of their maximum mana per 5 sec when you deal damage from Mind Blast. In addition, if the Vampiric Touch is dispelled it will cause 720 damage to the afflicted target.
    vampiric_touch = {
        id = 34914,
        cast = function() return 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        talent = "vampiric_touch",
        startsCombat = true,
        texture = 135978,

        handler = function ()
            if talent.shadow_weaving.rank == 3 then
                addStack( "shadow_weaving" )
            end
            applyDebuff( "target", "vampiric_touch" )
        end,
    },
} )

-- Hooks
spec:RegisterHook( "reset_precast", function ()
end )

-- Expressions
spec:RegisterStateExpr( "flay_over_blast", function()
    local currentSP = GetSpellBonusDamage( 6 ) or 0
    local vttimer = select( 4, GetSpellInfo( 34914 ) ) / 1000
    local currHaste = ( ( 1.5 / vttimer ) - 1 ) * 100
    
    -- Hekili:Debug( "flay_over_blast()["..tostring( rtn ).."]: currentSP["..tostring( currentSP ).."], currHaste["..tostring( currHaste ).."], latency["..tostring( latency ).."] )" )

    if set_bonus.tier10_4pc then
        -- Linelo maffs for 4pc T10 with 10ms MF clip delays
        if (currHaste > 102.68 and currentSP > 1500) or (currentSP > 5493.3 and currHaste < 50) or
        (currentSP > 5.0219e-04*currHaste^4 - 1.7950e-01*currHaste^3 + 2.4578e+01*currHaste^2 - 1.5651e+03*currHaste^1 + 4.1580e+04) then
            return false
        end
    else
        --Linelo maffs w/o 4pc T10
        local latency = select(4, GetNetStats()) / 1000
        if currentSP >= (-1.0038e-02*latency^2 + 1.7241e-03*latency + 1.1564e-04)*currHaste^4 
        +  (4.928100*latency^2 - 0.908961*latency - 0.063893)*currHaste^3
        +  (-878.800*latency^2 + 177.068*latency + 13.641)*currHaste^2
        +  (6.6990e+04*latency^2 - 1.5253e+04*latency - 1.3489e+03)*currHaste^1
        +  (-1.8099e+06*latency^2 + 5.0044e+05*latency + 5.3978e+04) then
            return false
        end
    end
    
    return true
end )


-- Options
spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    gcd = 1243,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 3,

    potion = "volcanic",

    package = "Shadow",
    package1 = "Shadow",
    -- package2 = "",
    -- package3 = "",
} )


-- Packs
spec:RegisterPack( "Shadow", 20240719, [[Hekili:nRvBVXTns4FlbfNrCIJoVBZ2EPNxd4u3G6a00GkFx(qrLexjU7sy92jrzxdyOF73md17l5k59SBoyKyVIKZmCE75rCPZmNRDSdysUZNMF683E63p7DwZ)2fZp9Do2Y7t5o2Pm)ByBG)iMfb)V9wwqYD4JVpmHfGlppPiZhg6ljFXweLx6DuPh83)mhg2EvHiuEvSZk9QzoS8uUVZNw4yVveeWvZKN77yF9wbim8FSsVkZO0lzn8zFPijU0luKlHHxNKv69Z8BeHclWYYswlcb75B(MspL5w695mbpxw(r8zVNLZdabftM5qtU8JQz95m(pMeTIjFZfK2YHhx69tXsEwTyb9gbgiyqXjsWQcZG1Fp8eqYcqzkZm3knJ7tI61l)75nR8eX6LRkwV2Q9rwWVJj98JmWA9(CYDO2(sswWpu69HKmPqweW7Qtqf3Y1RQuC1U3bl2DD9sBuQUbhQ(RIJr1)br2uvPaxH7AybOIErrAhP9VzrPImHp4eJwLX8NQmVTADUC1Y6kzBjldwEZ0l9Uti3w69lIyicBNkUXGqJGj4MRgNI4hwOD6buBWW8bltMu6DrYpv6LLizQSyulZH8rq5rjORMhZJG0vqT4NaZoNh3tNzfXUQp5ILaNGLMlzjKRr5kDRKX5lNtQ)s(AwrOuP)Cr8Mq(BaF3gUSJLmMgWcivXHnjHsVRReXV1ic14)AkNsDY5)NcEmgQPA08QLvP52CJUXRkVECvTUCl8hrm0XhWr3Rj)IvE)alLNOwIv7tTkspQ(PQ4KQiif0q3Xc43cT1a71nnKTPO36AYiLjf(BTQZflIIWWzvcKGJBjCVa5luxSQmjmr3JrdwnaNLfwLBr721InBhUVYBLkTXs5slswhjfr8ZwOsHJ4GJn2)(Ap6hcz3RI5OhusEX6wIvDv(m(qn(W1WsrnThFLPHY4O2YpBJFWRdHM(ObHM3fPP4(uNbu5OQ9sOlvZ2VvhDdUAmTDsTADe5QwgBWeuiNnEtRb9RzRYRcnxYYUb8N3YI3WHcGiAD(3KB2tHDpYksLU97c4MKTYIw75lNDKk1cKTlVr01JUG2tV8Ww7XQ0GLVC(RqV(CRfVszOwnMOvqrgvKECDv6VqE(2A3b(S3hsFaJmd8qy5h7wMiKTkKRZLScx6jA8evHMFJZu5cTGcxJ1sDYdQT2kgaRskQ6EX)ZueqQVw7xs2jVDqTADQP(rLc)BCrhzFJ8Y6EbqYk1m4GnZHDv6yO70WzGPUZ49nwnboMI5eqgke6fBkkrR(FLd7PlY83sjwak6wE8EkcuzarS)e5rr1lQg0xMCnm4wg2HlhmAHVa7q36K6BeSAf2KPOn9E5IJE5EJMNV4OrCINV44hDp6j2)T1)nOV2LCMSkHM6Qxd3IQzfpeN58f)nWDXzH4ej8FwmtndCCZTadqzJ2HsOwkzyL6lpB(IhEafJ6dN2AExkaM2z5nuoA11T8S71PXGMvGQQrOZo1q71jcCVBrIkhQFxNCfdD)KKqfjkZquVy)Phio0dpmwzgnPATz1wF0DcnDojgCgBCAda6nbEA7rLle3ojKXx6TOLKxZ(c4V1WFbeGgUClgffLq6bEEI0wAw59ZW3tlkLfSduR)9(HC3kHTC2jqDVB)Nrqx5CjcNMdCEL5UcG)ycFukcMgVFZTlmawCqBxvYwVsY7GwK4BtI9TctW(884KInBh6AgGY8e4yom4PJQk7X)ggZnqWp3aGxBR3NCenLprhK2(2Xp94CtNGsNsSXyOqTmFCKOFCLzgOoI7w8T2EIPE)8aq1uk10KlKNNx3K7TgBYnzOSJ63b8S32bBB2cdnEnW7zq)vh7BvyBnhj135yFhllgtCRp8PQZssTJJe55ujtErAAc(se0l1sVjb2usczT3av9wLELExv5iPZCicynWjpfEefCfEBAMijtiPx8ZpSiaFHFUaDM)aaZ49MsVFNIAxj5r5)XjiPmbXqUz2S47B1Af3fizleODjdBLlsXP(vlRv6)KcNvQ5ALik9M9hvH02hnVJMvTjB2r1Pn1tL8g0JIlIwb5eWmYdtKwLF8Qi0HHpaskubKQtVdg0XMvi3Mare7cGVrCro4)PbXtxecBWV(eDqL8ySEoW59WJjH4y3jEINAyMiv98dfp2XgKbupkykD0M8v6DomrhjKVyWwgwncYQlAaUjS3bJWXErxDQR1jD8KJuXx6DM5500cDGt6PMkb6C(wdoN(4sphUg9yPDDmgFDpuk7IPcr8LMwBnkPEp6F5mvqp)Bn45hIOoWKFkif8yctMia0nqzMeaUrxSVEbeW(EAgmrsdD3r7sraTIVBGv0o)9CUutTsgWVl9EneJvy4o2Djj4yxZsyWEhPtmyR)KZJb36F)eAas466mMVASq6gI2HSb51NVGcqd77FgjLhEqP4MzpJad(hd8fJGc1JCIoymj8JnKbpkMhEA27tDhYHP31f9IMm1ENEo5HEH5S4DMHMtsFWm2580hhKLoiMb7(hZH7mHdGFGVO9aFiWcc14SkcbMW8mvuEONt)ZCtM9GHSl1MjtKy4j7RphtZ(qxR(El9LqhIbTMPdmuHBpJ8dQuqDhROAwqf)XDJOljXoV07vT(N5wlOpRCgAorDqgd7qR1Wg9y8hp1554l1qhA2xhmvtaldjpQNaZb)LjOPU6WjtQdu4RevSNmgxVBQGC6(Qh0MmbcD2Pg8snFVa6Op88)TuStAQH2hQUhhrnmgjR586PoAernZJj)Jj8)NeiqtWBKMNYB4(xgbVPXBBh6zZpL2kMWMB)Yn0ThMWxwsxZQpVqLInbLo9o7tK72b99PSlu64n(i8q0ppAwC3jVNVtL2jESI3BG6AQSpYVvj)jzrdjvn97VJbGOMBSJo(N9RZ(F9280UFgCtB275pbDCMRoAmx1TXdpCmn8p7zRt5Q)ShZPJ2O22s8g2vDrQ()X4uT(1Db30wXn1lz3ogJXRq3(ELG2BiNwJzFx5UbLSkgtM6Ym8wZPvBJFL80QZHKY7xAm(vYt7BYkB(X5)o]] )


spec:RegisterPackSelector( "discipline", "none", "|T135987:0|t Discipline",
    "If you have spent more points in |T135987:0|t Discipline than in any other tree, this priority will be automatically selected for you.",
    -- Criteria
    -- The pack selector hook passes the points spent in tab1 (Discipline), tab2 (Holy), and tab3 (Shadow).
    function( tab1, tab2, tab3 )
        -- If we spent the most points in Shadow, then swap to this package.
        -- We could also reference anything else we wanted; e.g., talent.shadowform.enabled or something else entirely.
        return tab1 > max( tab2, tab3 )
    end )


spec:RegisterPackSelector( "holy", "none", "|T237542:0|t Holy",
    "If you have spent more points in |T237542:0|t Holy than in any other tree, this priority will be automatically selected for you.",
    -- Criteria
    -- The pack selector hook passes the points spent in tab1 (Discipline), tab2 (Holy), and tab3 (Shadow).
    function( tab1, tab2, tab3 )
        -- If we spent the most points in Shadow, then swap to this package.
        -- We could also reference anything else we wanted; e.g., talent.shadowform.enabled or something else entirely.
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "shadow", "Shadow", "|T136207:0|t Shadow",
    "If you have spent more points in |T136207:0|t Shadow than in any other tree, this priority will be automatically selected for you.",
    -- Criteria
    -- The pack selector hook passes the points spent in tab1 (Discipline), tab2 (Holy), and tab3 (Shadow).
    function( tab1, tab2, tab3 )
        -- If we spent the most points in Shadow, then swap to this package.
        -- We could also reference anything else we wanted; e.g., talent.shadowform.enabled or something else entirely.
        return tab3 > max( tab1, tab2 )
    end )

-- Settings
spec:RegisterSetting( "dots_in_aoe", true, {
    type = "toggle",
    name = "|T252997:0|t|T136207:0|t|T135978:0|t Apply DoTs in AOE",
    desc = "When enabled, the Shadow priority will recommend applying DoTs to your current target in multi-target scenarios before channeling |T237565:0|t Mind Sear.",
    width = "full",
} )