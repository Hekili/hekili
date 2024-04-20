if UnitClassBase( 'player' ) ~= 'MAGE' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 8 )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    arcane_barrage         = {  1847, 1, 44425 },
    arcane_concentration   = {    75, 1, 11213, 12574, 12575, 12576, 12577 },
    arcane_empowerment     = {  1727, 1, 31579, 31582, 31583 },
    arcane_flows           = {  1843, 1, 44378, 44379 },
    arcane_focus           = {    76, 1, 11222, 12839, 12840 },
    arcane_fortitude       = {    85, 1, 28574, 54658, 54659 },
    arcane_instability     = {   421, 1, 15058, 15059, 15060 },
    arcane_meditation      = {  1142, 1, 18462, 18463, 18464 },
    arcane_mind            = {    77, 1, 11232, 12500, 12501, 12502, 12503 },
    arcane_potency         = {  1725, 1, 31571, 31572 },
    arcane_power           = {    87, 1, 12042 },
    arcane_shielding       = {    83, 1, 11252, 12605 },
    arcane_stability       = {    80, 1, 11237, 12463, 12464, 16769, 16770 },
    arcane_subtlety        = {    74, 1, 11210, 12592 },
    arctic_reach           = {   741, 1, 16757, 16758 },
    arctic_winds           = {  1738, 1, 31674, 31675, 31676, 31677, 31678 },
    blast_wave             = {    32, 1, 11113 },
    blazing_speed          = {  1731, 1, 31641, 31642 },
    brain_freeze           = {  1854, 1, 44546, 44548, 44549 },
    burning_determination  = {  2212, 1, 54747, 54749 },
    burning_soul           = {    23, 1, 11083, 12351 },
    burnout                = {  1851, 1, 44449, 44469, 44470, 44471, 44472 },
    chilled_to_the_bone    = {  1856, 1, 44566, 44567, 44568, 44570, 44571 },
    cold_as_ice            = {  1737, 1, 55091, 55092 },
    cold_snap              = {    72, 1, 11958 },
    combustion             = {    36, 1, 11129 },
    critical_mass          = {    33, 1, 11115, 11367, 11368 },
    deep_freeze            = {  1857, 1, 44572 },
    dragons_breath         = {  1735, 1, 31661 },
    empowered_fire         = {  1734, 1, 31656, 31657, 31658 },
    empowered_frostbolt    = {  1740, 1, 31682, 31683 },
    enduring_winter        = {  1855, 1, 44557, 44560, 44561 },
    fiery_payback          = {  1848, 1, 64353, 64357 },
    fingers_of_frost       = {  1853, 1, 44543, 44545 },
    fire_power             = {    35, 1, 11124, 12378, 12398, 12399, 12400 },
    firestarter            = {  1849, 1, 44442, 44443 },
    flame_throwing         = {    28, 1, 11100, 12353 },
    focus_magic            = {  2211, 1, 54646 },
    frost_channeling       = {    66, 1, 11160, 12518, 12519 },
    frost_warding          = {    70, 1, 11189, 28332 },
    frostbite              = {    38, 1, 11071, 12496, 12497 },
    frozen_core            = {  1736, 1, 31667, 31668, 31669 },
    hot_streak             = {  1850, 1, 44445, 44446, 44448 },
    ice_barrier            = {    71, 1, 11426 },
    ice_floes              = {    62, 1, 31670, 31672, 55094 },
    ice_shards             = {    73, 1, 11207, 12672, 15047 },
    icy_veins              = {    69, 1, 12472 },
    ignite                 = {    34, 1, 11119, 11120, 12846, 12847, 12848 },
    impact                 = {    30, 1, 11103, 12357, 12358 },
    improved_blink         = {  1724, 1, 31569, 31570 },
    improved_blizzard      = {    63, 1, 11185, 12487, 12488 },
    improved_cone_of_cold  = {    64, 1, 11190, 12489, 12490 },
    improved_counterspell  = {    88, 1, 11255, 12598 },
    improved_fire_blast    = {    27, 1, 11078, 11080 },
    improved_fireball      = {    26, 1, 11069, 12338, 12339, 12340, 12341 },
    improved_frostbolt     = {    37, 1, 11070, 12473, 16763, 16765, 16766 },
    improved_scorch        = {    25, 1, 11095, 12872, 12873 },
    incanters_absorption   = {  1844, 1, 44394, 44395, 44396 },
    incineration           = {  1141, 1, 18459, 18460, 54734 },
    living_bomb            = {  1852, 1, 44457 },
    magic_absorption       = {  1650, 1, 29441, 29444 },
    magic_attunement       = {    82, 1, 11247, 12606 },
    master_of_elements     = {  1639, 1, 29074, 29075, 29076 },
    mind_mastery           = {  1728, 1, 31584, 31585, 31586, 31587, 31588 },
    missile_barrage        = {  2209, 1, 44404, 54486, 54488, 54489, 54490 },
    molten_fury            = {  1732, 1, 31679, 31680 },
    molten_shields         = {    24, 1, 11094, 13043 },
    netherwind_presence    = {  1846, 1, 44400, 44402, 44403 },
    permafrost             = {    65, 1, 11175, 12569, 12571 },
    piercing_ice           = {    61, 1, 11151, 12952, 12953 },
    playing_with_fire      = {  1730, 1, 31638, 31639, 31640 },
    precision              = {  1649, 1, 29438, 29439, 29440 },
    presence_of_mind       = {    86, 1, 12043 },
    prismatic_cloak        = {  1726, 1, 31574, 31575, 54354 },
    pyroblast              = {    29, 1, 11366 },
    pyromaniac             = {  1733, 1, 34293, 34295, 34296 },
    shatter                = {    67, 1, 11170, 12982, 12983 },
    shattered_barrier      = {  2214, 1, 44745, 54787 },
    slow                   = {  1729, 1, 31589 },
    spell_impact           = {    81, 1, 11242, 12467, 12469 },
    spell_power            = {  1826, 1, 35578, 35581 },
    student_of_the_mind    = {  1845, 1, 44397, 44398, 44399 },
    summon_water_elemental = {  1741, 1, 31687 },
    torment_the_weak       = {  2222, 1, 29447, 55339, 55340 },
    winters_chill          = {    68, 1, 11180, 28592, 28593 },
    world_in_flames        = {    31, 1, 11108, 12349, 12350 },
} )

spec:RegisterAuras( {
-- Increases magic damage taken by up to $s1 and healing by up to $s2.
    amplify_magic = {
        id = 43017,
        duration = 600,
        max_stack = 1,
        copy = { 1008, 8455, 10169, 10170, 27130, 33946, 43017 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 1 #1 -- APPLY_AURA, MOD_HEALING, points: 16, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 2 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 30, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 2 #1 -- APPLY_AURA, MOD_HEALING, points: 32, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 3 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 50, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 3 #1 -- APPLY_AURA, MOD_HEALING, points: 53, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 4 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 75, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 4 #1 -- APPLY_AURA, MOD_HEALING, points: 80, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 5 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 90, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 5 #1 -- APPLY_AURA, MOD_HEALING, points: 96, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 6 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 120, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 6 #1 -- APPLY_AURA, MOD_HEALING, points: 128, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 7 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 240, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 7 #1 -- APPLY_AURA, MOD_HEALING, points: 255, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Arcane spell damage increased by $s1% and mana cost of Arcane Blast increased by $s2%.
    arcane_blast = {
        id = 36032,
        duration = 6,
        max_stack = 4,
        copy = { 30451, 42894, 42896, 42897 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 5.0, points: 841, addl_points: 137, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 5.3, points: 896, addl_points: 145, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 6.2, points: 1046, addl_points: 169, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, points: 0, target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 7.0, points: 1184, addl_points: 193, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Increases Intellect by $s1.
    arcane_brilliance = {
        id = 43002,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        dot = "buff",
        copy = { 23028, 27127, 43002 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_STAT, points: 31, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID
        -- Rank 2 #0 -- APPLY_AURA, MOD_STAT, points: 40, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID
        -- Rank 3 #0 -- APPLY_AURA, MOD_STAT, points: 60, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID

        -- Affected by:
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Increases Intellect by $s1.
    arcane_intellect = {
        id = 42995,
        duration = 1800,
        max_stack = 1,
        shared = "player",
        dot = "buff",
        copy = { 1459, 1460, 1461, 10156, 10157, 27126, 42995 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_STAT, points: 2, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        -- Rank 2 #0 -- APPLY_AURA, MOD_STAT, points: 7, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        -- Rank 3 #0 -- APPLY_AURA, MOD_STAT, points: 15, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        -- Rank 4 #0 -- APPLY_AURA, MOD_STAT, points: 22, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        -- Rank 5 #0 -- APPLY_AURA, MOD_STAT, points: 31, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        -- Rank 6 #0 -- APPLY_AURA, MOD_STAT, points: 40, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        -- Rank 7 #0 -- APPLY_AURA, MOD_STAT, points: 60, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.arcane_intellect[57924] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50, target: TARGET_UNIT_CASTER
    },
    -- Increased damage and mana cost for your spells.
    arcane_power = {
        id = 12042,
        duration = function() return talent.arcane_power.enabled and 18 or 15 end,
        max_stack = 1,

        -- Effects:
        -- [42995] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, points: 20, target: TARGET_UNIT_CASTER
        -- [42995] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, points: 20, target: TARGET_UNIT_CASTER
        -- [42995] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_flows[44378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -15, target: TARGET_UNIT_CASTER
        -- talent.arcane_flows[44379] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -30, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- glyph.arcane_power[56381] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
    },
    -- Dazed.
    blast_wave = {
        id = 42945,
        duration = 6,
        max_stack = 1,
        copy = { 11113, 13018, 13019, 13020, 13021, 27133, 33933, 42944, 42945 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.0, points: 153, addl_points: 33, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 1 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 1 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.2, points: 200, addl_points: 41, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 2 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 2 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.4, points: 276, addl_points: 53, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 3 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 3 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.6, points: 364, addl_points: 69, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 4 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 4 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.9, points: 461, addl_points: 83, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 5 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 5 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.1, points: 532, addl_points: 95, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 6 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 6 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.3, points: 615, addl_points: 109, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 7 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 7 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 8 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 3.3, points: 881, addl_points: 157, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 8 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 8 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 9 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 3.9, points: 1046, addl_points: 187, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 9 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 9 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY

        -- Affected by:
        -- talent.spell_impact[11242] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12467] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- talent.blast_wave[62126] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -15, target: TARGET_UNIT_CASTER
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
    },
    -- Movement speed increased by $s1%.
    blazing_speed = {
        id = 31643,
        duration = 8,
        max_stack = 1,

        -- Effects:
        -- [42945] #0 -- APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- [42945] #1 -- DISPEL_MECHANIC, NONE, points: 100, value: 7, schools: ['physical', 'holy', 'fire'], target: TARGET_UNIT_CASTER
        -- [42945] #2 -- DISPEL_MECHANIC, NONE, points: 100, value: 11, schools: ['physical', 'holy', 'nature'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Blinking.
    blink = {
        id = 1953,
        duration = 1,
        max_stack = 1,

        -- Effects:
        -- [42945] #0 -- LEAP, NONE, radius: 20.0, target: TARGET_UNIT_CASTER, target2: TARGET_DEST_CASTER_FRONT_LEAP
        -- [42945] #1 -- APPLY_AURA, MECHANIC_IMMUNITY, sp_bonus: 1.0, target: TARGET_UNIT_CASTER, mechanic: stunned
        -- [42945] #2 -- APPLY_AURA, MECHANIC_IMMUNITY, sp_bonus: 1.0, target: TARGET_UNIT_CASTER, mechanic: rooted

        -- Affected by:
        -- talent.improved_blink[31569] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -25
        -- talent.improved_blink[31570] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.blink[56365] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RADIUS, points: 5, target: TARGET_UNIT_CASTER
        -- talent.improved_blink[47000] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, points: -15, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.improved_blink[46989] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, points: -30, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
    },
    -- $42938s1 Frost damage every $42938t1 $lsecond:seconds;.
    blizzard = {
        id = 42940,
        duration = 8,
        max_stack = 1,
        copy = { 42208, 42209, 42210, 42211, 42212, 42213, 42198, 42939, 42940 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.1, points: 36, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.2, points: 63, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.2, points: 92, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.3, points: 128, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.3, points: 166, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.4, points: 212, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.4, points: 273, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 8 #0 -- PERSISTENT_AREA_AURA, DUMMY, sp_bonus: 0.119, points_per_level: 1.9, points: 298, radius: 8.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 8 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 42937, triggers: blizzard, points: 0, target: TARGET_UNIT_CASTER
        -- Rank 9 #0 -- PERSISTENT_AREA_AURA, DUMMY, sp_bonus: 0.119, points_per_level: 1.9, points: 360, radius: 8.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 9 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 42938, triggers: blizzard, points: 0, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_power[12042] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15058] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15059] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15060] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #2 -- APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.piercing_ice[11151] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[11160] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.improved_blizzard[11185] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, item_type: 128, item: deprecated_tauren_trappers_pants, value: 836, schools: ['fire', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.improved_blizzard[12487] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, item_type: 128, item: deprecated_tauren_trappers_pants, value: 988, schools: ['fire', 'nature', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.improved_blizzard[12488] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, item_type: 128, item: deprecated_tauren_trappers_pants, value: 989, schools: ['physical', 'fire', 'nature', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12518] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12519] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12952] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12953] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16757] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16758] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31667] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -2, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31668] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -4, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31669] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -6, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
    },
    -- Immune to Interrupt and Silence mechanics.
    burning_determination = {
        id = 54748,
        duration = 20,
        max_stack = 1,
    },
    -- Movement slowed by $s1% and time between attacks increased by $s2%.
    chilled = {
        id = 6136,
        duration = function() return 5 + talent.permafrost.rank end,
        max_stack = 1,
        copy = { 6136, 7321, 12484, 12485, 12486, 15850, 18101, 31257 },
        shared = "target",

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #1 -- APPLY_AURA, MOD_MELEE_HASTE, mechanic: slowed, points: -25, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #1 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, points: -50, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #1 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.frostbite[11071] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[11175] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12496] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12497] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12569] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -13, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12571] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -20, target: TARGET_UNIT_CASTER
        -- talent.precision[29438] #0 -- APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.precision[29439] #0 -- APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.precision[29440] #0 -- APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44566] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44567] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44568] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44570] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
    },
    -- Your next damage spell has its mana cost reduced by $/10;s1%.
    clearcasting = {
        id = 12536,
        duration = 15,
        max_stack = 1,

        -- Effects:
        -- [12536] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_potency[31571] #0 -- APPLY_AURA, DUMMY, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_potency[31572] #0 -- APPLY_AURA, DUMMY, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Increases critical strike chance from Fire damage spells by $28682s1%.
    combustion = {
        id = 28682,
        duration = 3600,
        max_stack = 10,

        -- Effects:
        -- [28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Movement slowed by $s1%.
    cone_of_cold = {
        id = 42931,
        duration = function() return 8 + talent.permafrost.rank end,
        max_stack = 1,
        copy = { 120, 8492, 10159, 10160, 10161, 27087, 42930, 42931 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 1 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 0.8, points: 97, addl_points: 11, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 1 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 2 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.0, points: 145, addl_points: 15, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 2 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 3 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 3 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.2, points: 202, addl_points: 21, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 3 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 4 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 4 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.3, points: 263, addl_points: 27, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 4 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 5 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 5 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.5, points: 334, addl_points: 31, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 5 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 6 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 6 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.7, points: 409, addl_points: 39, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 6 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 7 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 7 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 2.3, points: 558, addl_points: 53, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 7 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 8 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 8 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 2.9, points: 706, addl_points: 67, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 8 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY

        -- Affected by:
        -- talent.spell_impact[11242] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12467] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.frostbite[11071] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[11151] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[11175] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- talent.improved_cone_of_cold[11190] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 15, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.improved_cone_of_cold[12489] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 25, target: TARGET_UNIT_CASTER
        -- talent.improved_cone_of_cold[12490] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 35, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12496] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12497] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12569] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -13, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12571] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -20, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12952] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12953] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16757] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16758] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31670] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31674] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -1, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31674] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -1, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31675] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -2, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31675] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -2, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31676] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -3, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31676] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -3, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31677] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -4, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31677] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31678] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -5, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31678] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44566] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44567] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44568] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44570] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[55094] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- talent.incineration[18459] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- talent.incineration[18460] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- talent.incineration[54734] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
    },
    -- Immune to all Curse effects.
    curse_immunity = {
        id = 60803,
        duration = 4,
        max_stack = 1,
        shared = "player",
        dot = "buff",

        -- Effects:
        -- [60803] #0 -- APPLY_AURA, DISPEL_IMMUNITY, points: 100, value: 2, schools: ['holy'], target: TARGET_UNIT_TARGET_ALLY
    },
    -- Increases Intellect by $s1.
    dalaran_brilliance = {
        id = 61316,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        dot = "buff",

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_STAT, points: 60, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID
        -- Rank 1 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 61332, radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID

        -- Affected by:
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.arcane_intellect[57924] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50, target: TARGET_UNIT_CASTER
    },
    -- Increases Intellect by $s1.
    dalaran_intellect = {
        id = 61024,
        duration = 1800,
        max_stack = 1,
        shared = "player",
        dot = "buff",

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_STAT, points: 60, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.arcane_intellect[57924] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50, target: TARGET_UNIT_CASTER
    },
    -- Reduces magic damage taken by up to $s1 and healing by up to $s2.
    dampen_magic = {
        id = 43015,
        duration = 600,
        max_stack = 1,
        copy = { 604, 8450, 8451, 10173, 10174, 33944, 43015 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -10, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 1 #1 -- APPLY_AURA, MOD_HEALING, points: -11, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 2 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -20, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 2 #1 -- APPLY_AURA, MOD_HEALING, points: -21, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 3 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -40, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 3 #1 -- APPLY_AURA, MOD_HEALING, points: -43, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 4 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -60, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 4 #1 -- APPLY_AURA, MOD_HEALING, points: -64, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 5 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -90, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 5 #1 -- APPLY_AURA, MOD_HEALING, points: -96, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 6 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -120, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 6 #1 -- APPLY_AURA, MOD_HEALING, points: -128, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 7 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: -240, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        -- Rank 7 #1 -- APPLY_AURA, MOD_HEALING, points: -255, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Stunned and Frozen.
    deep_freeze = {
        id = 44572,
        duration = 5,
        max_stack = 1,

        -- Effects:
        -- [44572] #0 -- APPLY_AURA, MOD_STUN, mechanic: stunned, points: 0, target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16757] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16758] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.fingers_of_frost[44544] #0 -- APPLY_AURA, ABILITY_IGNORE_AURASTATE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.deep_freeze[63090] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 10, target: TARGET_UNIT_CASTER
    },
    -- Increased spell power by $w1.
    demonic_pact = {
        id = 48090,
        duration = 45,
        max_stack = 1,
        shared = "player",
        dot = "buff",
    },
    -- Disoriented.
    dragons_breath = {
        id = 42950,
        duration = 5,
        max_stack = 1,
        copy = { 31661, 33041, 33042, 33043, 42949, 42950 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.5, points: 369, addl_points: 61, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 1 #1 -- APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 1 #2 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.6, points: 453, addl_points: 73, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 2 #1 -- APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 2 #2 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.8, points: 573, addl_points: 93, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 3 #1 -- APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 3 #2 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.0, points: 679, addl_points: 111, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 4 #1 -- APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 4 #2 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.7, points: 934, addl_points: 151, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 5 #1 -- APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 5 #2 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 3.2, points: 1100, addl_points: 179, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 6 #1 -- APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        -- Rank 6 #2 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY

        -- Affected by:
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11115] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11367] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11368] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34293] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34295] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34296] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.firestarter[44442] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.firestarter[44443] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6970, schools: ['holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.living_bomb[44457] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[44461] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.burning_determination[54747] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.burning_determination[54749] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, triggers: burning_determination, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.living_bomb[55359] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[55360] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[55361] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.living_bomb[55362] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
    },
    -- Gain $s1% of total mana every $t1 sec.
    evocation = {
        id = 12051,
        duration = 8,
        max_stack = 1,

        -- Effects:
        -- [12051] #0 -- APPLY_AURA, OBS_MOD_POWER, tick_time: 2.0, points: 15, target: TARGET_UNIT_CASTER
        -- [12051] #1 -- APPLY_AURA, OBS_MOD_HEALTH, tick_time: 2.0, points: 0, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_flows[44378] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -60000, target: TARGET_UNIT_CASTER
        -- talent.arcane_flows[44379] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -120000, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- aura.demonic_pact[53646] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 48090, points: 0, target: TARGET_UNIT_CASTER
        -- glyph.evocation[56380] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 15, target: TARGET_UNIT_CASTER
    },
    -- Disarmed!
    fiery_payback = {
        id = 64346,
        duration = 6,
        max_stack = 1,

        -- Effects:
        -- [64346] #0 -- APPLY_AURA, MOD_DISARM, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        -- [64346] #1 -- APPLY_AURA, MOD_DISARM_RANGED, target: TARGET_UNIT_TARGET_ENEMY
    },
    -- Your next $s1 spells treat the target as if it were Frozen.
    fingers_of_frost = {
        id = 74396,
        duration = 15,
        max_stack = 2,

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Absorbs Fire damage.
    fire_ward = {
        id = 43010,
        duration = 30,
        max_stack = 1,
        copy = { 543, 8457, 8458, 10223, 10225, 27128, 43010 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 165, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 1 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 290, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 2 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 470, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 3 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 675, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 4 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 5 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 875, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 5 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 6 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 1125, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 6 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 7 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 1950, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- Rank 7 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.molten_shields[11094] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 15, target: TARGET_UNIT_CASTER
        -- talent.molten_shields[13043] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 30, target: TARGET_UNIT_CASTER
        -- glyph.fire_ward[57926] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 5, target: TARGET_UNIT_CASTER
        -- glyph.drain_soul[58070] #0 -- APPLY_AURA, DUMMY, points: 0, target: TARGET_UNIT_CASTER
    },
    -- $s2 Fire damage every $t2 seconds.
    fireball = {
        id = 42833,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        copy = { 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070, 38692, 42832, 42833 },
        -- Effects:
        -- [ ] 01.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.123, points_per_level: 0.6, points: 13, addl_points: 9, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 01.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 02.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.271, points_per_level: 0.8, points: 30, addl_points: 15, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 02.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 03.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.5, points_per_level: 1.0, points: 52, addl_points: 21, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 03.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 2, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 04.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.793, points_per_level: 1.3, points: 83, addl_points: 33, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 04.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 3, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 05.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 1.8, points: 138, addl_points: 49, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 05.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 5, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 06.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 2.1, points: 198, addl_points: 67, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 06.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 7, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 07.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 2.4, points: 254, addl_points: 81, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 07.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 8, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 08.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 2.7, points: 317, addl_points: 97, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 08.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 10, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 09.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.0, points: 391, addl_points: 115, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 09.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 13, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 10.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.4, points: 474, addl_points: 135, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 10.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 15, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 11.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.7, points: 560, addl_points: 155, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 11.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 18, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 12.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.8, points: 595, addl_points: 165, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 12.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 19, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 13.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 4.0, points: 632, addl_points: 173, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 13.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 21, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 14.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 4.2, points: 716, addl_points: 197, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 14.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 23, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 15.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 4.6, points: 782, addl_points: 215, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 15.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 25, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 16.0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 5.2, points: 887, addl_points: 245, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 16.1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 29, target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- [ ] aura.arcane_power[12042].2 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31641].0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31642].0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31643].0 -- APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129].0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.fireball_proc[57761].0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.fireball_proc[57761].1 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100000, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472].1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[11095].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[12872].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[12873].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457].0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461].0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359].0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360].0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361].0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362].0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.presence_of_mind[12043].0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589].0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589].1 -- APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589].2 -- APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] glyph.fire_blast[56369].0 -- APPLY_AURA, DUMMY, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] glyph.fireball[56368].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -150, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058].0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058].1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059].0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059].1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060].0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060].1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[11083].0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[12351].0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115].0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367].0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368].0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31656].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31657].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31658].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124].1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378].1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398].1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399].1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400].1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_fireball[11069].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_fireball[12338].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -200, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_fireball[12339].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -300, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_fireball[12340].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -400, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_fireball[12341].0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -500, target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31638].0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31639].0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31640].0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293].0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295].0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296].0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[11242].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12467].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12469].0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
    },
    -- Your next Fireball or Frostfire Bolt spell is instant and costs no mana.
    fireball_proc = {
        id = 57761,
        duration = 15,
        max_stack = 1,
        copy = "brain_freeze",

        -- Effects:
        -- [ ] 00 APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] 01 APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100000, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- [ ] talent.arcane_potency[31571].0 -- APPLY_AURA, DUMMY, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_potency[31572].0 -- APPLY_AURA, DUMMY, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592].1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Your next Flamestrike spell is instant cast and costs no mana.
    firestarter = {
        id = 54741,
        duration = 10,
        max_stack = 1,
    },
    -- $s2 Fire damage every $t2.
    flamestrike = {
        id = 42926,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        copy = { 2120, 2121, 8422, 8423, 10215, 10216, 27086, 42925, 42926 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 0.6, points: 51, addl_points: 17, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 1 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 12, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 0.8, points: 95, addl_points: 27, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 2 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 22, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.0, points: 153, addl_points: 39, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 3 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 35, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.3, points: 219, addl_points: 53, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 4 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 49, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.5, points: 290, addl_points: 69, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 5 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 66, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.7, points: 374, addl_points: 85, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 6 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 85, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.9, points: 470, addl_points: 105, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 7 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 106, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 8 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 2.8, points: 687, addl_points: 155, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 8 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 155, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        -- Rank 9 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 3.5, points: 872, addl_points: 195, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 9 #1 -- PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 195, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY

        -- Affected by:
        -- talent.arcane_power[12042] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.presence_of_mind[12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15058] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15059] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15060] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #2 -- APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.burning_soul[11083] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- talent.flame_throwing[11100] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11115] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11367] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11368] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.burning_soul[12351] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- talent.flame_throwing[12353] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.playing_with_fire[31638] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.playing_with_fire[31639] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.playing_with_fire[31640] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.blazing_speed[31641] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- talent.blazing_speed[31642] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- talent.blazing_speed[31643] #0 -- APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34293] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34295] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34296] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.firestarter[44442] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.firestarter[44443] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6970, schools: ['holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.living_bomb[44457] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[44461] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.firestarter[54741] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.firestarter[54741] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -100, target: TARGET_UNIT_CASTER
        -- talent.burning_determination[54747] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.burning_determination[54748] #0 -- APPLY_AURA, MECHANIC_IMMUNITY, points: 0, target: TARGET_UNIT_CASTER, mechanic: silenced
        -- talent.burning_determination[54749] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, triggers: burning_determination, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.living_bomb[55359] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[55360] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[55361] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.living_bomb[55362] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
    },
    -- Increases chance to critically hit with spells by $s1%.
    focus_magic = {
        id = 54646,
        duration = 1800,
        max_stack = 1,
    },
    focus_magic_proc = {
        id = 54648,
        duration = 10,
        max_stack = 1,

        -- Effects:
        -- [54648] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ANY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Increases Armor by $s1 and may slow attackers.
    frost_armor = {
        id = 7301,
        duration = function() return glyph.frost_armor.enabled and 3600 or 1800 end,
        max_stack = 1,
        copy = { 168, 7300, 7301 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 30, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 1 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 6136, target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 110, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 2 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 6136, target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 200, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 3 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 6136, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.frost_channeling[11160] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.shatter[11170] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frost_warding[11189] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12518] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12519] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.shatter[12982] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12983] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.frost_warding[28332] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- talent.precision[29438] #1 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- glyph.ice_armor[56384] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- glyph.ice_armor[56384] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_3_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] glyph.frost_armor[57928] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1800000, target: TARGET_UNIT_CASTER
    },
    -- Frozen in place.
    frost_nova = {
        id = 42917,
        duration = 8,
        max_stack = 1,
        copy = { 122, 865, 6131, 10230, 27088, 42917 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.018, points_per_level: 0.5, points: 18, addl_points: 3, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 1 #1 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.043, points_per_level: 0.5, points: 32, addl_points: 5, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 2 #1 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.043, points_per_level: 0.5, points: 51, addl_points: 7, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 3 #1 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.043, points_per_level: 0.5, points: 69, addl_points: 11, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 4 #1 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 0.5, points: 229, addl_points: 31, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 5 #1 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 0.8, points: 364, addl_points: 51, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        -- Rank 6 #1 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY

        -- Affected by:
        -- talent.piercing_ice[11151] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12952] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12953] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16757] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16758] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31670] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31674] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -1, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31675] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -2, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31676] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -3, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31677] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31678] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
        -- talent.brain_freeze[44546] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 57761, points: 0, value: 23, schools: ['physical', 'holy', 'fire', 'frost'], target: TARGET_UNIT_CASTER
        -- talent.brain_freeze[44548] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 57761, points: 0, value: 23, schools: ['physical', 'holy', 'fire', 'frost'], target: TARGET_UNIT_CASTER
        -- talent.brain_freeze[44549] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 57761, points: 0, value: 23, schools: ['physical', 'holy', 'fire', 'frost'], target: TARGET_UNIT_CASTER
        -- talent.ice_floes[55094] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- glyph.frost_nova[56376] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, points: 20, value: 7801, schools: ['physical', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
    },
    -- Absorbs Frost damage.
    frost_ward = {
        id = 43012,
        duration = 30,
        max_stack = 1,
        copy = { 6143, 8461, 8462, 10177, 28609, 32796, 43012 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 165, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 1 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 290, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 2 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 470, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 3 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 675, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 4 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 5 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 875, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 5 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 6 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 1125, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 6 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 7 #0 -- APPLY_AURA, SCHOOL_ABSORB, points: 1950, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 7 #1 -- APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.molten_shields[11094] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 15, target: TARGET_UNIT_CASTER
        -- talent.molten_shields[13043] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 30, target: TARGET_UNIT_CASTER
        -- glyph.frost_ward[57927] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 5, target: TARGET_UNIT_CASTER
    },
    -- Frozen.
    frostbite = {
        id = 12494,
        duration = 5,
        max_stack = 1,

        -- Effects:
        -- [12494] #0 -- APPLY_AURA, MOD_ROOT, points: 0, target: TARGET_UNIT_TARGET_ANY
    },
    -- Movement slowed by $s1%.
    frostbolt = {
        id = 42842,
        duration = function() return 9 + talent.permafrost.rank end,
        max_stack = 1,
        copy = { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697, 42841, 42842 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.172, points_per_level: 0.5, points: 17, addl_points: 3, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.283, points_per_level: 0.7, points: 30, addl_points: 5, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.488, points_per_level: 0.9, points: 50, addl_points: 7, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.743, points_per_level: 1.1, points: 73, addl_points: 9, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 5 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 5 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 1.5, points: 125, addl_points: 13, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 5 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 6 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 6 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 1.7, points: 173, addl_points: 17, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 6 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 7 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 7 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.0, points: 226, addl_points: 21, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 7 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 8 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 8 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.3, points: 291, addl_points: 25, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 8 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 9 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 9 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.6, points: 352, addl_points: 31, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 9 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 10 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 10 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.9, points: 428, addl_points: 35, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 10 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 11 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 11 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.2, points: 514, addl_points: 41, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 11 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 12 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 12 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.2, points: 535, addl_points: 43, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 12 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 13 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 13 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.5, points: 596, addl_points: 47, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 13 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 14 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 14 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.8, points: 629, addl_points: 51, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 14 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 15 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 15 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 4.2, points: 701, addl_points: 57, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 15 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 16 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 16 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 4.8, points: 798, addl_points: 63, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 16 #2 -- APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.presence_of_mind[12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.slow[31589] #1 -- APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.improved_frostbolt[11070] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.frostbite[11071] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[11151] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- talent.winters_chill[11180] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.improved_frostbolt[12473] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -200, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12496] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12497] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -13, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -20, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12952] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12953] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16757] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16758] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.improved_frostbolt[16763] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -300, target: TARGET_UNIT_CASTER
        -- talent.improved_frostbolt[16765] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -400, target: TARGET_UNIT_CASTER
        -- talent.improved_frostbolt[16766] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -500, target: TARGET_UNIT_CASTER
        -- talent.winters_chill[28592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.winters_chill[28593] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31667] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -2, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31668] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -4, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31669] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -6, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.empowered_frostbolt[31682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- talent.empowered_frostbolt[31682] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.empowered_frostbolt[31683] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- talent.empowered_frostbolt[31683] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -200, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44566] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44566] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44567] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44567] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44568] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 3, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44568] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44570] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44570] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44571] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- glyph.frostbolt[56370] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- glyph.ice_block[56372] #0 -- APPLY_AURA, DUMMY, points: 5, target: TARGET_UNIT_CASTER
    },
    -- Movement slowed by $s1%.  $s3 Fire damage every $t3 sec.
    frostfire_bolt = {
        id = 47610,
        duration = function() return 9 + talent.permafrost.rank end,
        tick_time = 3,
        max_stack = 1,
        copy = { 44614, 47610 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.9, points: 628, addl_points: 103, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #2 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, points: 20, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #1 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 4.5, points: 721, addl_points: 117, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #2 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, points: 30, target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_power[12042] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- aura.presence_of_mind[12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.frostbite[11071] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[11175] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[11175] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12496] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- talent.frostbite[12497] #0 -- APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12569] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12569] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12571] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- talent.permafrost[12571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44566] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44566] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44567] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44567] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44568] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 3, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44568] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44570] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44570] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44571] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- talent.chilled_to_the_bone[44571] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- talent.burning_soul[11083] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- talent.improved_scorch[11095] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.burning_soul[12351] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.improved_scorch[12872] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.improved_scorch[12873] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.empowered_fire[31656] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- talent.empowered_fire[31657] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- talent.empowered_fire[31658] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 15, target: TARGET_UNIT_CASTER
        -- glyph.frostfire[61205] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- glyph.frostfire[61205] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2
        -- glyph.fireball[57761] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- glyph.fireball[57761] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100000, target: TARGET_UNIT_CASTER
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
    },
    heating_up = {
        duration = 3600, -- Heating up is a pseudo buff that has no duration
        max_stack = 1,
    },
    -- Your next Pyroblast spell is instant cast.
    hot_streak = {
        id = 48108,
        duration = 10,
        max_stack = 1,
    },
    -- Cannot be made invulnerable by Ice Block.
    hypothermia = {
        id = 41425,
        duration = 30,
        max_stack = 1,
    },
    -- Increases armor by $s1, Frost resistance by $s3 and may slow attackers.
    ice_armor = {
        id = 43008,
        duration = function() return glyph.frost_armor.enabled and 3600 or 1800 end,
        tick_time = 6,
        max_stack = 1,
        copy = { 7302, 7320, 10219, 10220, 27124, 43008 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 290, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 1 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
        -- Rank 1 #2 -- APPLY_AURA, MOD_RESISTANCE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 380, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 2 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
        -- Rank 2 #2 -- APPLY_AURA, MOD_RESISTANCE, points: 9, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 470, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 3 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
        -- Rank 3 #2 -- APPLY_AURA, MOD_RESISTANCE, points: 12, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 560, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 4 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
        -- Rank 4 #2 -- APPLY_AURA, MOD_RESISTANCE, points: 15, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 5 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 645, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 5 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
        -- Rank 5 #2 -- APPLY_AURA, MOD_RESISTANCE, points: 18, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 6 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 930, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 6 #1 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
        -- Rank 6 #2 -- APPLY_AURA, MOD_RESISTANCE, points: 40, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- Rank 6 #3 -- APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.frost_channeling[11160] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_warding[11189] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12518] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12519] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_warding[28332] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- glyph.ice_armor[56384] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- glyph.ice_armor[56384] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_3_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] glyph.frost_armor[57928] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1800000, target: TARGET_UNIT_CASTER
    },
    -- Absorbs damage.
    ice_barrier = {
        id = 43039,
        duration = 60,
        max_stack = 1,
        copy = { 11426, 13031, 13032, 13033, 27134, 33405, 43038, 43039 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 2.8, points: 438, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 3.2, points: 549, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 3.6, points: 678, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 4.0, points: 818, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 5 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 4.4, points: 925, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 6 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 4.8, points: 1075, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 7 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 15.0, points: 2800, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 8 #0 -- APPLY_AURA, SCHOOL_ABSORB, points_per_level: 15.0, points: 3300, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[11160] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12518] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12519] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31674] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -1, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31675] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -2, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31676] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -3, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31677] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -4, target: TARGET_UNIT_CASTER
        -- talent.arctic_winds[31678] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -5, target: TARGET_UNIT_CASTER
        -- talent.cold_as_ice[55091] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -10, target: TARGET_UNIT_CASTER
        -- talent.cold_as_ice[55092] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- talent.ice_barrier[63095] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Immune to all attacks and spells.  Cannot attack, move or use spells.
    ice_block = {
        id = 45438,
        duration = 10,
        max_stack = 1,

        -- Effects:
        -- [45438] #0 -- APPLY_AURA, MOD_STUN, points: 0, target: TARGET_UNIT_CASTER
        -- [45438] #1 -- APPLY_AURA, SCHOOL_IMMUNITY, points: 0, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- [45438] #2 -- APPLY_AURA, SCHOOL_IMMUNITY, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31670] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[55094] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
    },
    -- Casting speed of all spells increased by $s1% and reduces pushback suffered by damaging attacks while casting by $s2%.
    icy_veins = {
        id = 12472,
        duration = 20,
        max_stack = 1,

        -- Effects:
        -- [12472] #0 -- APPLY_AURA, MOD_CASTING_SPEED_NOT_STACK, points: 20, target: TARGET_UNIT_CASTER
        -- [12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31670] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[31672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- talent.ice_floes[55094] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
    },
    -- Deals Fire damage every $t1 sec.
    ignite = {
        id = 413841,
        duration = 4,
        tick_time = 2,
        max_stack = 1,

        -- Effects:
        -- [413841] #0 -- APPLY_AURA, PERIODIC_DUMMY, tick_time: 2.0, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        -- [413841] #1 -- APPLY_AURA, DUMMY, points: 0, target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.ignite[12848] #0 -- APPLY_AURA, DUMMY, target: TARGET_UNIT_CASTER
    },
    -- Next Fire Blast stuns the target for $12355d.
    impact = {
        id = 64343,
        duration = 10,
        max_stack = 1,
        copy = { 12355 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_STUN, points: 0, target: TARGET_UNIT_TARGET_ENEMY
    },
    -- Chance to be hit by all attacks and spells reduced by $s1%.
    improved_blink = {
        id = 46989,
        duration = 4,
        max_stack = 1,

        -- Effects:
        -- [46989] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, points: -30, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [46989] #1 -- APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -30, target: TARGET_UNIT_CASTER
        -- [46989] #2 -- APPLY_AURA, MOD_ATTACKER_SPELL_HIT_CHANCE, points: -30, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Spells have a $s1% additional chance to critically hit.
    improved_scorch = {
        id = 22959,
        duration = 30,
        max_stack = 1,

        -- Effects:
        -- [22959] #0 -- APPLY_AURA, MOD_ATTACKER_SPELL_CRIT_CHANCE, points: 5, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
    },
    -- Spell power increased.
    incanters_absorption = {
        id = 44413,
        duration = 10,
        max_stack = 1,

        -- Effects:
        -- [44413] #0 -- APPLY_AURA, MOD_DAMAGE_DONE, points: 0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Invisible.
    invisibility = {
        id = 32612,
        duration = 20,
        max_stack = 1,

        -- Effects:
        -- [32612] #0 -- SANCTUARY, NONE, target: TARGET_UNIT_CASTER
        -- [32612] #1 -- APPLY_AURA, MOD_INVISIBILITY, points_per_level: 5.0, points: 340, target: TARGET_UNIT_CASTER
        -- [32612] #2 -- APPLY_AURA, MOD_INVISIBILITY_DETECT, points: 1000, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.invisibility[56366] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 10000, target: TARGET_UNIT_CASTER
    },
    -- Fading.
    invisibility_fading = {
        id = 66,
        duration = function() return 3 - talent.prismatic_cloak.rank end,
        tick_time = 1,
        max_stack = 1,
    },
    -- Causes $s1 Fire damage every $t1 sec.  After $d or when the spell is dispelled, the target explodes causing $55362s1 Fire damage to all enemies within $55362a1 yards.
    living_bomb = {
        id = 55360,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 44461, 55361, 55362 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.flame_throwing[11100] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.flame_throwing[12353] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.living_bomb[63091] #0 -- APPLY_AURA, ABILITY_PERIODIC_CRIT, points: 10, value: 5, schools: ['physical', 'fire'], target: TARGET_UNIT_CASTER
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
    },
    -- Resistance to all magic schools increased by $s1 and allows $s2% of your mana regeneration to continue while casting.  Duration of all harmful Magic effects reduced by $s3%.
    mage_armor = {
        id = 43024,
        duration = 1800,
        tick_time = 6,
        max_stack = 1,
        copy = { 6117, 22782, 22783, 27125, 43023, 43024 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 5, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 1 #1 -- APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 10, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 2 #1 -- APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 3 #1 -- APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 18, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 4 #1 -- APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
        -- Rank 5 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 21, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 5 #1 -- APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
        -- Rank 5 #2 -- APPLY_AURA, MOD_AURA_DURATION_BY_DISPEL, points: -50, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 6 #0 -- APPLY_AURA, MOD_RESISTANCE, points: 40, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 6 #1 -- APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
        -- Rank 6 #2 -- APPLY_AURA, MOD_AURA_DURATION_BY_DISPEL, points: -50, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
        -- Rank 6 #3 -- APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_shielding[11252] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 25, target: TARGET_UNIT_CASTER
        -- talent.arcane_shielding[12605] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.magic_absorption[29441] #1 -- APPLY_AURA, MOD_RESISTANCE, points_per_level: 0.5, points: 0, value: 124, schools: ['fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.magic_absorption[29444] #1 -- APPLY_AURA, MOD_RESISTANCE, points_per_level: 1.0, points: 0, value: 124, schools: ['fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.mage_armor[56383] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 20, target: TARGET_UNIT_CASTER
    },
    -- Absorbs damage, draining mana instead.
    mana_shield = {
        id = 43020,
        duration = 60,
        max_stack = 1,
        copy = { 1463, 8494, 8495, 10191, 10192, 10193, 27131, 43019, 43020 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 120, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 2 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 210, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 300, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 4 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 390, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 5 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 480, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 6 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 570, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 7 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 715, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 8 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 1080, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- Rank 9 #0 -- APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 1330, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_shielding[11252] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_TAKEN, points: -17, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_shielding[12605] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_TAKEN, points: -33, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Copies of the caster that attack on their own.
    mirror_image = {
        id = 55342,
        duration = 30,
        tick_time = 1,
        max_stack = 1,

        -- Effects:
        -- [55342] #0 -- APPLY_AURA, MOD_TOTAL_THREAT, points: -90000000, target: TARGET_UNIT_CASTER
        -- [55342] #1 -- TRIGGER_SPELL, NONE, trigger_spell: 58832, points: 3, target: TARGET_UNIT_CASTER
        -- [55342] #2 -- APPLY_AURA, PERIODIC_DUMMY, tick_time: 1.0, trigger_spell: 58836, points: 0, target: TARGET_UNIT_CASTER
    },
    -- Reduces the channeled duration of your next Arcane Missiles spell by $/1000;S1 secs, reduces the mana cost by $s3%, and the missiles fire every .5 secs.
    missile_barrage = {
        id = 44401,
        duration = 15,
        max_stack = 1,

        -- Effects:
        -- [44401] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: -2500, target: TARGET_UNIT_CASTER
        -- [44401] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, AURA_PERIOD, points: -500, target: TARGET_UNIT_CASTER
        -- [44401] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -100, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_potency[31571] #0 -- APPLY_AURA, DUMMY, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_potency[31572] #0 -- APPLY_AURA, DUMMY, points: 30, target: TARGET_UNIT_CASTER
    },
    -- Causes $43044s1 Fire damage to attackers.  Chance to receive a critical hit reduced by $s2%.  Critical strike rating increased by $s3% of Spirit.
    molten_armor = {
        id = 43046,
        duration = 1800,
        tick_time = 6,
        max_stack = 1,
        copy = { 34913, 43045, 43046 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, points: 75, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 43043, triggers: molten_armor, points: 0, target: TARGET_UNIT_CASTER
        -- Rank 2 #1 -- APPLY_AURA, MOD_ATTACKER_SPELL_AND_WEAPON_CRIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
        -- Rank 2 #2 -- APPLY_AURA, MOD_ABILITY_SCHOOL_MASK, points: 35, value: 1792, value1: 4, target: TARGET_UNIT_CASTER
        -- Rank 2 #3 -- APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER
        -- Rank 3 #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 43044, triggers: molten_armor, points: 0, target: TARGET_UNIT_CASTER
        -- Rank 3 #1 -- APPLY_AURA, MOD_ATTACKER_SPELL_AND_WEAPON_CRIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
        -- Rank 3 #2 -- APPLY_AURA, MOD_ABILITY_SCHOOL_MASK, points: 35, value: 1792, value1: 4, target: TARGET_UNIT_CASTER
        -- Rank 3 #3 -- APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.magic_absorption[29441] #0 -- APPLY_AURA, DUMMY, target: TARGET_UNIT_CASTER
        -- talent.magic_absorption[29444] #0 -- APPLY_AURA, DUMMY, points: 2, target: TARGET_UNIT_CASTER
        -- talent.torment_the_weak[29447] #0 -- APPLY_AURA, DUMMY, points: 4, target: TARGET_UNIT_CASTER
        -- talent.torment_the_weak[55339] #0 -- APPLY_AURA, DUMMY, points: 8, target: TARGET_UNIT_CASTER
        -- talent.torment_the_weak[55340] #0 -- APPLY_AURA, DUMMY, points: 12, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- glyph.molten_armor[56382] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: 20, target: TARGET_UNIT_CASTER
    },
    -- Cannot attack or cast spells.  Increased regeneration.
    polymorph = {
        id = 61780,
        duration = 50,
        max_stack = 1,
        copy = { 118, 12824, 12825, 12826, 28271, 28272, 61025, 61305, 61721, 61780 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #1 -- APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #1 -- APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #0 -- APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #1 -- APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #0 -- APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #1 -- APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.presence_of_mind[12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Your next Mage spell with a casting time less than 10 sec will be an instant cast spell.
    presence_of_mind = {
        id = 12043,
        duration = 3600,
        max_stack = 1,

        -- Effects:
        -- [12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_potency[31571] #0 -- APPLY_AURA, DUMMY, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_potency[31572] #0 -- APPLY_AURA, DUMMY, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_flows[44378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -15, target: TARGET_UNIT_CASTER
        -- talent.arcane_flows[44379] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -30, target: TARGET_UNIT_CASTER
    },
    -- $s2 Fire damage every $t2 seconds.
    pyroblast = {
        id = 42891,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938, 42890, 42891 },

        -- Effects:
        -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 1.9, points: 140, addl_points: 47, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 1 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 14, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 2.2, points: 179, addl_points: 57, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 18, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 2.6, points: 254, addl_points: 73, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 3 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 24, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 3.0, points: 328, addl_points: 91, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 4 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 31, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 3.4, points: 406, addl_points: 109, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 5 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 39, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 3.8, points: 502, addl_points: 129, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 6 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 47, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 4.2, points: 599, addl_points: 151, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 7 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 57, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 8 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 4.6, points: 707, addl_points: 191, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 8 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 67, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 9 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 5.0, points: 845, addl_points: 229, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 9 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 78, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 10 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 5.4, points: 938, addl_points: 253, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 10 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 89, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 11 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 5.8, points: 1013, addl_points: 273, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 11 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 96, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 12 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 6.8, points: 1189, addl_points: 321, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 12 #1 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 113, target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_power[12042] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.presence_of_mind[12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15058] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15059] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15060] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #2 -- APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.burning_soul[11083] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- talent.flame_throwing[11100] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11115] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11367] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.critical_mass[11368] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.burning_soul[12351] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- talent.flame_throwing[12353] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.playing_with_fire[31638] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.playing_with_fire[31639] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.playing_with_fire[31640] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.blazing_speed[31641] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- talent.blazing_speed[31642] #0 -- APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- talent.blazing_speed[31643] #0 -- APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- talent.empowered_fire[31656] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- talent.empowered_fire[31657] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- talent.empowered_fire[31658] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 15, target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34293] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34295] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.pyromaniac[34296] #0 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.fiery_payback[44440] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -1750, target: TARGET_UNIT_CASTER
        -- talent.fiery_payback[44440] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: 2500, target: TARGET_UNIT_CASTER
        -- talent.fiery_payback[44441] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -3500, target: TARGET_UNIT_CASTER
        -- talent.fiery_payback[44441] #2 -- APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: 5000, target: TARGET_UNIT_CASTER
        -- talent.living_bomb[44457] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[44461] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.living_bomb[55359] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[55360] #0 -- APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.living_bomb[55361] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.living_bomb[55362] #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- talent.hot_streak[48108] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, sp_bonus: 1.0, points: -100, target: TARGET_UNIT_CASTER
    },
    -- Replenishes $s1% of maximum mana per 5 sec.
    replenishment = {
        id = 57669,
        duration = 15,
        max_stack = 1,
        shared = "player",
        dot = "buff",
    },
    -- Frozen in place.
    shattered_barrier = {
        id = 55080,
        duration = 8,
        max_stack = 1,

        -- Effects:
        -- [55080] #0 -- APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY

        -- Affected by:
        -- talent.frost_channeling[11160] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12518] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12519] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
    },
    -- Silenced.
    silenced_improved_counterspell = {
        id = 55021,
        duration = function() return 2 * talent.improved_counterspell.rank end,
        max_stack = 1,
        copy = { 18469, 55021 },

        -- Effects:
        -- Rank 1 #0 -- APPLY_AURA, MOD_SILENCE, target: TARGET_UNIT_TARGET_ENEMY
        -- Rank 2 #0 -- APPLY_AURA, MOD_SILENCE, target: TARGET_UNIT_TARGET_ENEMY
    },
    -- Movement speed reduced by $s1%.  Time between ranged attacks increased by $s2%.  Casting time increased by $s3%.
    slow = {
        id = 31589,
        duration = 15,
        max_stack = 1,

        -- Effects:
        -- [31589] #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [31589] #1 -- APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [31589] #2 -- APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },
    -- Slows falling speed.
    slow_fall = {
        id = 130,
        duration = 30,
        max_stack = 1,

        -- Effects:
        -- [130] #0 -- APPLY_AURA, FEATHER_FALL, target: TARGET_UNIT_TARGET_RAID

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.slow_fall[57925] #0 -- APPLY_AURA, NO_REAGENT_USE, points: 0, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
    },
    water_elemental = {
        duration = function()
            if glyph.eternal_water.enabled then return 3600 end
            return 45 + ( 5 * talent.enduring_winter.rank )
        end,
        max_stack = 1,
    },
    -- Spells have a $s1% additional chance to critically hit.
    winters_chill = {
        id = 12579,
        duration = 15,
        max_stack = 5,

        -- Effects:
        -- [12579] #0 -- APPLY_AURA, MOD_ATTACKER_SPELL_CRIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- glyph.arcane_intellect[57924] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50, target: TARGET_UNIT_CASTER
        -- glyph.slow_fall[57925] #0 -- APPLY_AURA, NO_REAGENT_USE, points: 0, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- glyph.fire_ward[57926] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 5, target: TARGET_UNIT_CASTER
        -- glyph.drain_soul[58070] #0 -- APPLY_AURA, DUMMY, points: 0, target: TARGET_UNIT_CASTER
        -- glyph.frost_ward[57927] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 5, target: TARGET_UNIT_CASTER
    },

    -- Aliases
    unique_armor = {
        alias = { "frost_armor", "molten_armor", "mage_armor", "ice_armor" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    frozen = {
        alias = { "deep_freeze", "frost_nova", "frostbite", "shattered_barrier" },
        aliasMode = "first",
        aliasType = "debuff",
    }
} )


-- Glyphs
spec:RegisterGlyphs( {
    [63092] = "arcane_barrage",
    [62210] = "arcane_blast",
    [56360] = "arcane_explosion",
    [57924] = "arcane_intellect",
    [56363] = "arcane_missiles",
    [56381] = "arcane_power",
    [62126] = "blast_wave",
    [56365] = "blink",
    [63090] = "deep_freeze",
    [58070] = "drain_soul",
    [70937] = "eternal_water",
    [56380] = "evocation",
    [56369] = "fire_blast",
    [57926] = "fire_ward",
    [56368] = "fireball",
    [57928] = "frost_armor",
    [56376] = "frost_nova",
    [57927] = "frost_ward",
    [56370] = "frostbolt",
    [61205] = "frostfire",
    [56384] = "ice_armor",
    [63095] = "ice_barrier",
    [56372] = "ice_block",
    [56377] = "ice_lance",
    [56374] = "icy_veins",
    [56366] = "invisibility",
    [63091] = "living_bomb",
    [56383] = "mage_armor",
    [56367] = "mana_gem",
    [63093] = "mirror_image",
    [56382] = "molten_armor",
    [56375] = "polymorph",
    [56364] = "remove_curse",
    [56371] = "scorch",
    [57925] = "slow_fall",
    [56373] = "water_elemental",
} )


-- Events that will provoke a 
local AURA_EVENTS = {
    SPELL_AURA_APPLIED      = 1,
    SPELL_AURA_APPLIED_DOSE = 1,
    SPELL_AURA_REFRESH      = 1,
    SPELL_AURA_REMOVED      = 1,
    SPELL_AURA_REMOVED_DOSE = 1,
}

local AURA_REMOVED = {
    SPELL_AURA_REFRESH      = 1,
    SPELL_AURA_REMOVED      = 1,
    SPELL_AURA_REMOVED_DOSE = 1,
}

local FORCED_RESETS = {}

for _, aura in pairs( { "arcane_power", "clearcasting", "fingers_of_frost", "fireball_proc", "firestarter", "hot_streak", "missile_barrage", "presence_of_mind", "deep_freeze", "frost_nova", "frostbite", "shattered_barrier" } ) do
    FORCED_RESETS[ spec.auras[ aura ].id ] = 1
end

local lastFingersConsumed = 0
local lastFrostboltCast = 0

local heating_spells = {
    [42833] = 1,
    [42873] = 1,
    [42859] = 1,
    [55362] = 1,
    [47610] = 1
}
local heatingUp = false

spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, ...)
    if not ( sourceGUID == state.GUID or destGUID == state.GUID ) then
        return
    end

	if (sourceGUID == state.GUID) then
        if subtype == 'SPELL_DAMAGE' then
            if state.talent.hot_streak.enabled and heating_spells[spellID] == 1 then
                local critical = select(7, ...)
                if critical then
                    heatingUp = true
                else
                    heatingUp = false
                end
            end
        elseif subtype == 'SPELL_AURA_APPLIED' then
            if state.talent.hot_streak.enabled and spellID == spec.auras.hot_streak.id then
                heatingUp = false
            end
        end
    end

    if AURA_REMOVED[ subtype ] and spellID == spec.auras.fingers_of_frost.id then
        lastFingersConsumed = GetTime()
    end

    if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and spec.abilities[ spellID ] and spec.abilities[ spellID ].key == "frostbolt" then
        lastFrostboltCast = GetTime()
    end
    
    if AURA_EVENTS[ subtype ] and FORCED_RESETS[ spellID ] then
        Hekili:ForceUpdate( "MAGE_AURA_CHANGED", true )
    end
end, false )


local mana_gem_values = {
    [5514] = 390,
    [5513] = 585,
    [8007] = 829,
    [8008] = 1073,
    [22044] = 2340,
    [33312] = 3330
}

spec:RegisterStateExpr( "mana_gem_charges", function() return 0 end )
spec:RegisterStateExpr( "mana_gem_id", function() return 33312 end )

spec:RegisterStateExpr( "frozen", function()
    return buff.fingers_of_frost.up or debuff.frozen.up
end )

spec:RegisterHook( "reset_precast", function()
    mana_gem_charges = nil
    mana_gem_id = nil

    for item in pairs( mana_gem_values ) do
        count = GetItemCount( item, nil, true )
        if count > 0 then
            mana_gem_charges = count
            mana_gem_id = item
            break
        end
    end

    -- When Frostbolt consumes FoF, we can still make use of that FoF until the Frostbolt impact.

    local frostbolt_remains = action.frostbolt.in_flight_remains
    if frostbolt_remains == 0 and query_time - lastFrostboltCast < 0.2 then
        frostbolt_remains = max( 0, lastFrostboltCast + ( target.distance / action.frostbolt.velocity ) - query_time )
    end

    if lastFingersConsumed == lastFrostboltCast and frostbolt_remains > 0 and frostbolt_remains < cooldown.deep_freeze.remains then
        if buff.fingers_of_frost.up then 
            addStack( "fingers_of_frost" )
        else
            addStack( "fingers_of_frost", frostbolt_remains )
        end
    end

    if heatingUp then
        applyBuff("heating_up")
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Amplifies magic used against the targeted party member, increasing damage taken from spells by up to $s1 and healing spells by up to $s2.  Lasts $d.
    amplify_magic = {
        id = 43017,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.270 * ( 1 - 0.01 * talent.precision.rank ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            active_dot.amplify_magic = active_dot.amplify_magic + 1

            -- Effects:
            -- Rank 1 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 1 #1 -- APPLY_AURA, MOD_HEALING, points: 16, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 2 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 30, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 2 #1 -- APPLY_AURA, MOD_HEALING, points: 32, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 3 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 50, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 3 #1 -- APPLY_AURA, MOD_HEALING, points: 53, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 4 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 75, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 4 #1 -- APPLY_AURA, MOD_HEALING, points: 80, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 5 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 90, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 5 #1 -- APPLY_AURA, MOD_HEALING, points: 96, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 6 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 120, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 6 #1 -- APPLY_AURA, MOD_HEALING, points: 128, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 7 #0 -- APPLY_AURA, MOD_DAMAGE_TAKEN, points: 240, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- Rank 7 #1 -- APPLY_AURA, MOD_HEALING, points: 255, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        end,

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 1008, 8455, 10169, 10170, 27130, 33946, 43017 },
    },

    -- Launches several missiles at the enemy target, causing $s1 Arcane damage.
    arcane_barrage = {
        id = 44781,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.180 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( talent.arcane_barrage.enabled and 0.8 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 24,

        handler = function()
            removeDebuff( "player", "arcane_blast" )

            -- Effects:
            -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 2.5, points: 385, addl_points: 85, target: TARGET_UNIT_TARGET_ENEMY
            -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 15.5, points: 708, addl_points: 157, target: TARGET_UNIT_TARGET_ENEMY
            -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 6.1, points: 935, addl_points: 209, target: TARGET_UNIT_TARGET_ENEMY
        end,

        impact = function()
        end,

        -- Affected by:
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_barrage[63092] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -20, target: TARGET_UNIT_CASTER
        -- aura.mirror_image[63093] #0 -- APPLY_AURA, DUMMY, target: TARGET_UNIT_CASTER

        copy = { 44425, 44780, 44781 },
    },

    -- Blasts the target with energy, dealing $s1 Arcane damage.  Each time you cast Arcane Blast, the damage of all Arcane spells is increased by $36032s1% and mana cost of Arcane Blast is increased by $36032s2%.  Effect stacks up to $36032u times and lasts $36032d or until any Arcane damage spell except Arcane Blast is cast.
    arcane_blast = {
        id = 42897,
        cast = function() return ( buff.presence_of_mind.up or buff.clearcasting.up ) and 0 or 2.5 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.070 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( 1 + ( debuff.arcane_blast.stack * 1.75 ) ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" )
            elseif buff.clearcasting.up then removeBuff( "clearcasting" ) end

            applyDebuff( "player", "arcane_blast", nil, min( 4, debuff.arcane_blast.stack + 1 ) )

            -- Effects:
            -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 5.0, points: 841, addl_points: 137, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] Rank 1 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
            -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 5.3, points: 896, addl_points: 145, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] Rank 2 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
            -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 6.2, points: 1046, addl_points: 169, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] Rank 3 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, points: 0, target: TARGET_UNIT_CASTER
            -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.714, points_per_level: 7.0, points: 1184, addl_points: 193, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] Rank 4 #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[11237] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 20, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[11242] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- aura.arcane_power[12042] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[12463] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 40, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[12464] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 60, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12467] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[16769] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 80, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[16770] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.prismatic_cloak[31574] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, points: -2, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.prismatic_cloak[31575] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, points: -4, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- aura.arcane_empowerment[31579] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 3, target: TARGET_UNIT_CASTER
        -- aura.arcane_empowerment[31579] #1 -- APPLY_AREA_AURA_RAID, MOD_DAMAGE_PERCENT_DONE, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 100.0, target: TARGET_UNIT_CASTER
        -- aura.arcane_empowerment[31582] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 6, target: TARGET_UNIT_CASTER
        -- aura.arcane_empowerment[31582] #1 -- APPLY_AREA_AURA_RAID, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 100.0, target: TARGET_UNIT_CASTER
        -- aura.arcane_empowerment[31583] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 9, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.spell_power[35578] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- talent.spell_power[35581] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_blast[42894] #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_blast[42896] #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, points: 0, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_blast[42897] #1 -- TRIGGER_SPELL, NONE, trigger_spell: 36032, target: TARGET_UNIT_CASTER
        -- talent.prismatic_cloak[54354] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, points: -6, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.shatter[11170] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- aura.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.shatter[12982] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12983] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.incineration[18459] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- talent.incineration[18460] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31679] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31680] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.burnout[44449] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- talent.burnout[44469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- talent.burnout[44470] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- talent.burnout[44471] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- talent.burnout[44472] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.incineration[54734] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- aura.arcane_blast[36032] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 15, value: 64, schools: ['arcane'], target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_blast[36032] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 175, target: TARGET_UNIT_CASTER

        copy = { 30451, 42894, 42896, 42897 },
    },

    -- Infuses all party and raid members with brilliance, increasing their Intellect by $s1 for $d.
    arcane_brilliance = {
        id = 43002,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.810 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( glyph.arcane_intellect.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        bagItem = 17020,

        nobuff = "arcane_brilliance",
        handler = function()
            applyBuff( "arcane_brilliance" )
            active_dot.arcane_brilliance = group_members

            -- Effects:
            -- Rank 1 #0 -- APPLY_AURA, MOD_STAT, points: 31, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID
            -- Rank 2 #0 -- APPLY_AURA, MOD_STAT, points: 40, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID
            -- Rank 3 #0 -- APPLY_AURA, MOD_STAT, points: 60, value: 3, schools: ['physical', 'holy'], radius: 100.0, target: TARGET_UNIT_CASTER_AREA_RAID
        end,

        -- Affected by:
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [x] glyph.arcane_intellect[57924] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50, target: TARGET_UNIT_CASTER

        copy = { 23028, 27127, 43002, 61316, "dalaran_brilliance" },
    },

    -- Causes an explosion of arcane magic around the caster, causing $s1 Arcane damage to all targets within $a1 yards.
    arcane_explosion = {
        id = 42921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.220 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( glyph.arcane_explosion.enabled and 0.9 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            removeDebuff( "player", "arcane_blast" )

            -- Effects:
            -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.166, points_per_level: 0.4, points: 31, addl_points: 5, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 0.6, points: 56, addl_points: 7, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 0.9, points: 96, addl_points: 9, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 0.9, points: 138, addl_points: 13, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.1, points: 185, addl_points: 17, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.3, points: 242, addl_points: 21, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.5, points: 305, addl_points: 25, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 8 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.6, points: 376, addl_points: 31, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 9 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 2.0, points: 480, addl_points: 39, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 10 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 2.3, points: 537, addl_points: 45, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        end,

        -- Affected by:
        -- talent.arcane_focus[11222] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[11242] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_power[12042] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- talent.arcane_power[12042] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12467] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12839] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.arcane_focus[12840] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15058] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15059] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15060] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.prismatic_cloak[31574] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, points: -2, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.prismatic_cloak[31575] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, points: -4, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.slow[31589] #1 -- APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.spell_power[35578] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- talent.spell_power[35581] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.prismatic_cloak[54354] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, points: -6, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.shatter[11170] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12982] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12983] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31679] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31680] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.burnout[44449] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- talent.burnout[44469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- talent.burnout[44470] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- talent.burnout[44471] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- talent.burnout[44472] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] glyph.arcane_explosion[56360] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -10, target: TARGET_UNIT_CASTER

        copy = { 1449, 8437, 8438, 8439, 10201, 10202, 27080, 27082, 42920, 42921 },
    },

    -- Increases the target's Intellect by $s1 for $d.
    arcane_intellect = {
        id = 42995,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.310 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( glyph.arcane_intellect.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "arcane_intellect" )

            -- Effects:
            -- Rank 1 #0 -- APPLY_AURA, MOD_STAT, points: 2, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
            -- Rank 2 #0 -- APPLY_AURA, MOD_STAT, points: 7, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
            -- Rank 3 #0 -- APPLY_AURA, MOD_STAT, points: 15, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
            -- Rank 4 #0 -- APPLY_AURA, MOD_STAT, points: 22, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
            -- Rank 5 #0 -- APPLY_AURA, MOD_STAT, points: 31, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
            -- Rank 6 #0 -- APPLY_AURA, MOD_STAT, points: 40, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
            -- Rank 7 #0 -- APPLY_AURA, MOD_STAT, points: 60, value: 3, schools: ['physical', 'holy'], target: TARGET_UNIT_TARGET_ALLY
        end,

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [x] glyph.arcane_intellect[57924] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50, target: TARGET_UNIT_CASTER

        copy = { 1459, 1460, 1461, 10156, 10157, 27126, 42995, 61024, "dalaran_intellect" },
    },

    -- Launches Arcane Missiles at the enemy, causing $7268s1 Arcane damage every $5143t2 sec for $5143d.
    arcane_missiles = {
        id = 42846,
        cast = function()
            local base = level < 16 and 3 or level < 24 and 4 or 5
            return ( buff.missile_barrage.up and 2.5 or base ) * haste
        end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up or buff.missile_barrage.up ) and 0 or 0.310 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        start = function()
            removeDebuff( "player", "arcane_blast" )

            if buff.missile_barrage.up then removeBuff( "missile_barrage" )
            elseif buff.clearcasting.up then removeBuff( "clearcasting" ) end

            -- Effects:
            -- Rank 1 #0 -- APPLY_AURA, DUMMY, target: TARGET_UNIT_TARGET_ENEMY
            -- Rank 1 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 7268, target: TARGET_UNIT_CASTER
            -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 0.4, points: 36, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 0.5, points: 56, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 0.6, points: 83, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 0.7, points: 115, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 0.8, points: 151, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 0.9, points: 192, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 8 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 1.0, points: 230, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 9 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 1.1, points: 240, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 10 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 1.2, points: 260, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 11 #0 -- APPLY_AURA, DUMMY, target: TARGET_UNIT_TARGET_ENEMY
            -- Rank 11 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 38703, triggers: arcane_missiles, target: TARGET_UNIT_CASTER
            -- Rank 12 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.286, points_per_level: 1.5, points: 320, target: TARGET_UNIT_CHANNEL_TARGET
            -- Rank 13 #0 -- APPLY_AURA, DUMMY, target: TARGET_UNIT_TARGET_ENEMY
            -- Rank 13 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 42845, triggers: arcane_missiles, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- talent.arcane_stability[11237] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 20, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[11247] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[12463] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 40, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[12464] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 60, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- talent.magic_attunement[12606] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[16769] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 80, target: TARGET_UNIT_CASTER
        -- talent.arcane_stability[16770] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arcane_empowerment[31583] #1 -- APPLY_AREA_AURA_RAID, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 100.0, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #1 -- APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [x] talent.missile_barrage[44401] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: -2500, target: TARGET_UNIT_CASTER
        -- [x] talent.missile_barrage[44401] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, AURA_PERIOD, points: -500, target: TARGET_UNIT_CASTER
        -- [x] talent.missile_barrage[44401] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -100, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- glyph.arcane_missiles[56363] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER

        copy = { 5143, 7269, 7270, 8419, 8418, 10273, 10274, 25346, 27076, 38700, 38704, 42844, 42846 },
    },

    -- When activated, your spells deal $s1% more damage while costing $s2% more mana to cast.  This effect lasts $D.
    arcane_power = {
        id = 12042,
        cast = 0,
        cooldown = function() return 120 - ( 15 * talent.arcane_flows.rank ) end,
        gcd = "off",

        toggle = "cooldowns",
        startsCombat = false,

        handler = function()
            applyBuff( "arcane_power" )

            -- Effects:
            -- [x] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, points: 20, target: TARGET_UNIT_CASTER
            -- [x] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, points: 20, target: TARGET_UNIT_CASTER
            -- [x] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_flows[44378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -15, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_flows[44379] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -30, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] glyph.arcane_power[56381] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
    },

    -- A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for $s1 Fire damage, knocking them back and dazing them for $d.
    blast_wave = {
        id = 42945,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.070 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( buff.arcane_power.up and 1.2 or 1 ) * ( glyph.blast_wave.enabled and 0.85 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if target.within10 then
                applyDebuff( "target", "blast_wave" )
            end

            -- Effects:
            -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.0, points: 153, addl_points: 33, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 1 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 1 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.2, points: 200, addl_points: 41, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 2 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 2 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.4, points: 276, addl_points: 53, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 3 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 3 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.6, points: 364, addl_points: 69, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 4 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 4 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.9, points: 461, addl_points: 83, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 5 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 5 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.1, points: 532, addl_points: 95, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 6 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 6 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.3, points: 615, addl_points: 109, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 7 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 7 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 8 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 3.3, points: 881, addl_points: 157, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 8 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 8 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 9 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 3.9, points: 1046, addl_points: 187, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] Rank 9 #1 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- Rank 9 #2 -- KNOCK_BACK, NONE, points: 80, value: 100, schools: ['fire', 'shadow', 'arcane'], radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        end,

        -- Affected by:
        -- talent.spell_impact[11242] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12467] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.spell_impact[12469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- talent.spell_power[35578] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- talent.spell_power[35581] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.shatter[11170] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12982] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12983] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.fire_power[11124] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- talent.combustion[11129] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12378] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12398] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12399] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- talent.fire_power[12400] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31679] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31680] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.burnout[44449] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- talent.burnout[44469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- talent.burnout[44470] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- talent.burnout[44471] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- talent.burnout[44472] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] glyph.blast_wave[62126] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -15, target: TARGET_UNIT_CASTER
        -- talent.combustion[28682] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER

        copy = { 11113, 13018, 13019, 13020, 13021, 27133, 33933, 42944, 42945 },
    },

    -- Teleports the caster $a1 yards forward, unless something is in the way.  Also frees the caster from stuns and bonds.
    blink = {
        id = 1953,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.210 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( 1 - 0.25 * talent.improved_blink.rank ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "blink" )
            setDistance( max( 5, target.distance - ( glyph.blink.enabled and 25 or 20 ) ) )

            if talent.improved_blink.enabled then applyBuff( "improved_blink" ) end
            
            -- Effects:
            -- #0 -- LEAP, NONE, radius: 20.0, target: TARGET_UNIT_CASTER, target2: TARGET_DEST_CASTER_FRONT_LEAP
            -- #1 -- APPLY_AURA, MECHANIC_IMMUNITY, sp_bonus: 1.0, target: TARGET_UNIT_CASTER, mechanic: stunned
            -- #2 -- APPLY_AURA, MECHANIC_IMMUNITY, sp_bonus: 1.0, target: TARGET_UNIT_CASTER, mechanic: rooted
        end,

        -- Affected by:
        -- [x] talent.improved_blink[31569] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -25
        -- [x] talent.improved_blink[31570] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -50
        -- talent.mind_mastery[31584] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31585] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31586] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31587] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- talent.mind_mastery[31588] #0 -- APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- glyph.blink[56365] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, RADIUS, points: 5, target: TARGET_UNIT_CASTER
        -- talent.improved_blink[47000] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, points: -15, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.improved_blink[46989] #0 -- APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, points: -30, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
    },

    -- Ice shards pelt the target area doing ${$42208m1*8*$<mult>} Frost damage over $10d.
    blizzard = {
        id = 42940,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.740 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            -- Effects:
            -- Rank 1 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.1, points: 36, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 2 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.2, points: 63, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 3 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.2, points: 92, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 4 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.3, points: 128, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 5 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.3, points: 166, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 6 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.4, points: 212, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 7 #0 -- SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 0.4, points: 273, radius: 8.0, target: TARGET_DEST_CHANNEL_TARGET, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- Rank 8 #0 -- PERSISTENT_AREA_AURA, DUMMY, sp_bonus: 0.119, points_per_level: 1.9, points: 298, radius: 8.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- Rank 8 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 42937, triggers: blizzard, points: 0, target: TARGET_UNIT_CASTER
            -- Rank 9 #0 -- PERSISTENT_AREA_AURA, DUMMY, sp_bonus: 0.119, points_per_level: 1.9, points: 360, radius: 8.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- Rank 9 #1 -- APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 42938, triggers: blizzard, points: 0, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- aura.arcane_power[12042] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- aura.arcane_power[12042] #2 -- APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15058] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15058] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15059] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15059] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15060] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.arcane_instability[15060] #1 -- APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.slow[31589] #0 -- APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.slow[31589] #1 -- APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.slow[31589] #2 -- APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- talent.spell_power[35578] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- talent.spell_power[35581] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[11151] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[11160] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.shatter[11170] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.improved_blizzard[11185] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, item_type: 128, item: deprecated_tauren_trappers_pants, value: 836, schools: ['fire', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[11207] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- talent.improved_blizzard[12487] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, item_type: 128, item: deprecated_tauren_trappers_pants, value: 988, schools: ['fire', 'nature', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.improved_blizzard[12488] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, item_type: 128, item: deprecated_tauren_trappers_pants, value: 989, schools: ['physical', 'fire', 'nature', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12518] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.frost_channeling[12519] #0 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.ice_shards[12672] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12952] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.piercing_ice[12953] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12982] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.shatter[12983] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- talent.ice_shards[15047] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16757] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- talent.arctic_reach[16758] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- talent.precision[29438] #0 -- APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.precision[29438] #1 -- APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- talent.precision[29439] #0 -- APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.precision[29440] #0 -- APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31667] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -2, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31668] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -4, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.frozen_core[31669] #0 -- APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -6, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[11108] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12349] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- talent.world_in_flames[12350] #0 -- APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31679] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.molten_fury[31680] #0 -- APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- talent.burnout[44449] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- talent.burnout[44469] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- talent.burnout[44470] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- talent.burnout[44471] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- talent.burnout[44472] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 42208, 42209, 42210, 42211, 42212, 42213, 42198, 42939, 42940 },
    },

    -- When activated, this spell finishes the cooldown on all Frost spells you recently cast.
    cold_snap = {
        id = 11958,
        cast = 0,
        cooldown = function() return 480 * ( 1 - ( 0.1 * talent.cold_as_ice.rank ) ) end,
        gcd = "off",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            setCooldown( "ice_block", 0 )
            setCooldown( "icy_veins", 0 )
            setCooldown( "summon_water_elemental", 0 )

            -- Effects:
            -- #0 -- DUMMY, NONE, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [x] talent.cold_as_ice[55091] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -10, target: TARGET_UNIT_CASTER
        -- [x] talent.cold_as_ice[55092] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
    },

    -- When activated, this spell increases your critical strike damage bonus with Fire damage spells by $s1%, and causes each of your Fire damage spell hits to increase your critical strike chance with Fire damage spells by $28682s1%.  This effect lasts until you have caused $11129n non-periodic critical strikes with Fire spells.
    combustion = {
        id = 11129,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "combustion" )
            stat.crit = stat.crit + 10
        end,

        -- Affected by:
        -- talent.arcane_subtlety[11210] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- talent.arcane_subtlety[12592] #1 -- APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },

    -- Targets in a cone in front of the caster take ${$m2*$<mult>} to ${$M2*$<mult>} Frost damage and are slowed by $s1% for $d.
    cone_of_cold = {
        id = 42931,
        cast = 0,
        cooldown = function() return 10 * ( 1 - min( 0.2, 0.07 * talent.ice_floes.rank ) ) end,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.250 * ( 1 - 0.01 * ( talent.precision.rank + talent.arcane_focus.rank ) ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if target[ "within" .. ( 10 * ( 1 + 0.1 * talent.arctic_reach.rank ) ) ] then
                applyDebuff( "target", "cone_of_cold" )
            end

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 1.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 0.8, points: 97, addl_points: 11, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 1.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 2.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 2.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.0, points: 145, addl_points: 15, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 2.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 3.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 3.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.2, points: 202, addl_points: 21, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 3.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 4.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 4.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.3, points: 263, addl_points: 27, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 4.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 5.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 5.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.5, points: 334, addl_points: 31, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 5.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 6.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 6.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 1.7, points: 409, addl_points: 39, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 6.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 7.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 7.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 2.3, points: 558, addl_points: 53, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 7.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 8.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 8.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.214, points_per_level: 2.9, points: 706, addl_points: 67, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [ ] 8.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[11071.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[12496.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[12497.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.arctic_reach[16757.1] APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [x] talent.arctic_reach[16758.1] APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31674.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -1, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31674.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -1, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31675.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31675.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31676.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -3, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31676.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -3, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31677.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31677.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31678.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -5, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31678.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44566.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44567.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44568.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44570.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44571.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31670.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31672.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[55094.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[11207.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[12672.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[15047.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_cone_of_cold[11190.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_cone_of_cold[12489.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.improved_cone_of_cold[12490.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[18459.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[18460.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[54734.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[11175.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[11175.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[11175.2] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12569.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12569.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12569.2] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -13, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12571.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12571.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12571.2] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -20, target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[11151.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12952.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12953.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[11242.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12467.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12469.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 120, 8492, 10159, 10160, 10161, 27087, 42930, 42931 },
    },

    -- Conjures $s1 $lmuffin:muffins;, providing the mage and $ghis:her; allies with something to eat.; Conjured items disappear if logged out for more than 15 minutes.
    conjure_food = {
        id = 33717,
        cast = function() return buff.presence_of_mind.up and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.400,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            -- Effects:
            -- [ ] 1.0 CREATE_ITEM, NONE, item_type: 5349, item: conjured_muffin, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 2.0 CREATE_ITEM, NONE, item_type: 1113, item: conjured_bread, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 3.0 CREATE_ITEM, NONE, item_type: 1114, item: conjured_rye, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 4.0 CREATE_ITEM, NONE, item_type: 1487, item: conjured_pumpernickel, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 5.0 CREATE_ITEM, NONE, item_type: 8075, item: conjured_sourdough, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 6.0 CREATE_ITEM, NONE, item_type: 8076, item: conjured_sweet_roll, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 7.0 CREATE_ITEM, NONE, item_type: 22895, item: conjured_cinnamon_roll, points_per_level: 2.0, points: 10, target: TARGET_UNIT_CASTER
            -- [ ] 8.0 CREATE_ITEM, NONE, item_type: 22019, item: conjured_croissant, points_per_level: 2.0, points: 10, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 587, 597, 990, 6129, 10144, 10145, 28612, 33717 },
    },

    -- Conjures a mana agate that can be used to instantly restore $5405s1 mana.
    conjure_mana_gem = {
        id = 42985,
        cast = function() return buff.presence_of_mind.up and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.750,
        spendType = "mana",

        startsCombat = false,

        usable = function() return mana_gem_charges < 3, "mana gem is fully charged" end,
        handler = function()
            if level > 77 then mana_gem_id = 33312
            elseif level > 67 then mana_gem_id = 22044
            elseif level > 57 then mana_gem_id = 8008
            elseif level > 47 then mana_gem_id = 8007
            elseif level > 37 then mana_gem_id = 5513
            else mana_gem_id = 5514 end

            mana_gem_charges = 3

            -- Effects:
            -- [ ] 1.0 CREATE_ITEM, NONE, item_type: 5514, item: mana_agate, target: TARGET_UNIT_CASTER
            -- [ ] 2.0 CREATE_ITEM, NONE, item_type: 5513, item: mana_jade, target: TARGET_UNIT_CASTER
            -- [ ] 3.0 CREATE_ITEM, NONE, item_type: 8007, item: mana_citrine, target: TARGET_UNIT_CASTER
            -- [ ] 4.0 CREATE_ITEM, NONE, item_type: 8008, item: mana_ruby, target: TARGET_UNIT_CASTER
            -- [ ] 5.0 CREATE_ITEM, NONE, item_type: 22044, item: mana_emerald, target: TARGET_UNIT_CASTER
            -- [ ] 6.0 CREATE_ITEM, NONE, item_type: 33312, item: mana_sapphire, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 759, 3552, 10053, 10054, 27101, 42985 },
    },

    -- Conjures $s1 Mana Pies providing the mage and $ghis:her; allies with something to eat.; Conjured items disappear if logged out for more than 15 minutes.
    conjure_refreshment = {
        id = 42956,
        cast = function() return buff.presence_of_mind.up and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.400,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            -- Effects:
            -- [ ] 1.0 CREATE_ITEM, NONE, item_type: 43518, item: conjured_mana_pie, points: 20, target: TARGET_UNIT_CASTER
            -- [ ] 2.0 CREATE_ITEM, NONE, item_type: 43523, item: conjured_mana_strudel, points: 20, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 42955, 42956 },
    },

    -- Conjures $s1 $lbottle:bottles; of water, providing the mage and $ghis:her; allies with something to drink.; Conjured items disappear if logged out for more than 15 minutes.
    conjure_water = {
        id = 27090,
        cast = function() return buff.presence_of_mind.up and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.400,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            -- Effects:
            -- [ ] 1.0 CREATE_ITEM, NONE, item_type: 5350, item: conjured_water, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 2.0 CREATE_ITEM, NONE, item_type: 2288, item: conjured_fresh_water, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 3.0 CREATE_ITEM, NONE, item_type: 2136, item: conjured_purified_water, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 4.0 CREATE_ITEM, NONE, item_type: 3772, item: conjured_spring_water, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 5.0 CREATE_ITEM, NONE, item_type: 8077, item: conjured_mineral_water, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 6.0 CREATE_ITEM, NONE, item_type: 8078, item: conjured_sparkling_water, points_per_level: 2.0, points: 2, target: TARGET_UNIT_CASTER
            -- [ ] 7.0 CREATE_ITEM, NONE, item_type: 8079, item: conjured_crystal_water, points_per_level: 2.0, points: 10, target: TARGET_UNIT_CASTER
            -- [ ] 8.0 CREATE_ITEM, NONE, item_type: 30703, item: conjured_mountain_spring_water, points_per_level: 2.0, points: 10, target: TARGET_UNIT_CASTER
            -- [ ] 9.0 CREATE_ITEM, NONE, item_type: 22018, item: conjured_glacier_water, points_per_level: 2.0, points: 10, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 5504, 5505, 5506, 6127, 10138, 10139, 10140, 37420, 27090 },
    },

    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for $d.  Generates a high amount of threat.
    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = 24,
        gcd = "none",

        spend = 0.090,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",

        readyTime = state.timeToInterrupt,
        debuff = "casting",

        handler = function()
            interrupt()

            if talent.improved_counterspell.enabled then applyDebuff( "target", "silenced_improved_counterspell" ) end

            -- Effects:
            -- [x] 0. INTERRUPT_CAST, NONE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },

    -- Dampens magic used against the targeted party member, decreasing damage taken from spells by up to $s1 and healing spells by up to $s2.  Lasts $d.
    dampen_magic = {
        id = 43015,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.270,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            active_dot.dampen_magic = min( group_members, active_dot.dampen_magic + 1 )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -10, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 1.1 APPLY_AURA, MOD_HEALING, points: -11, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 2.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -20, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 2.1 APPLY_AURA, MOD_HEALING, points: -21, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 3.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -40, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 3.1 APPLY_AURA, MOD_HEALING, points: -43, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 4.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -60, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 4.1 APPLY_AURA, MOD_HEALING, points: -64, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 5.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -90, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 5.1 APPLY_AURA, MOD_HEALING, points: -96, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 6.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -120, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 6.1 APPLY_AURA, MOD_HEALING, points: -128, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 7.0 APPLY_AURA, MOD_DAMAGE_TAKEN, points: -240, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
            -- [x] 7.1 APPLY_AURA, MOD_HEALING, points: -255, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_RAID
        end,

        -- Affected by:
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 604, 8450, 8451, 10173, 10174, 33944, 43015 },
    },

    -- Stuns the target for $d.  Only usable on Frozen targets.  Deals ${$71757m1*$<mult>} to ${$71757M1*$<mult>} damage to targets permanently immune to stuns.
    deep_freeze = {
        id = 44572,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.090,
        spendType = "mana",

        startsCombat = true,

        debuff = function() return buff.fingers_of_frost.down and "frozen" or nil end,
        handler = function()
            removeStack( "fingers_of_frost" )
            applyDebuff( "target", "deep_freeze" )

            -- Effects:
            -- [x] 0. APPLY_AURA, MOD_STUN, mechanic: stunned, points: 0, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [x] aura.deep_freeze[63090.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 10, target: TARGET_UNIT_CASTER
        -- [x] aura.fingers_of_frost[44544.0] APPLY_AURA, ABILITY_IGNORE_AURASTATE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_reach[16757.0] APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_reach[16758.0] APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[11207.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[12672.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[15047.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
    },

    -- Targets in a cone in front of the caster take $s1 Fire damage and are Disoriented and Snared for $d.  Any direct damaging attack will revive targets.  Turns off your attack when used.
    dragons_breath = {
        id = 42950,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.070 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if target.within10 then
                applyDebuff( "target", "dragons_breath" )
            end
            -- Effects:
            -- [x] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.5, points: 369, addl_points: 61, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 1.1 APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 1.2 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.6, points: 453, addl_points: 73, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 2.1 APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 2.2 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 1.8, points: 573, addl_points: 93, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 3.1 APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 3.2 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.0, points: 679, addl_points: 111, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 4.1 APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 4.2 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 2.7, points: 934, addl_points: 151, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 5.1 APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 5.2 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 3.2, points: 1100, addl_points: 179, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 6.1 APPLY_AURA, MOD_CONFUSE, mechanic: disoriented, points: 0, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
            -- [x] 6.2 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -50, radius: 10.0, target: TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.burning_determination[54747.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] aura.burning_determination[54749.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, triggers: burning_determination, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.firestarter[44442.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] aura.firestarter[44443.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6970, schools: ['holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[11108.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[12349.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[12350.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER

        copy = { 31661, 33041, 33042, 33043, 42949, 42950 },
    },

    -- While channeling this spell, you gain $o1% of your total mana over $d.
    evocation = {
        id = 12051,
        cast = function() return 8 * haste end,
        channeled = true,
        cooldown = function() return 240 - 60 * talent.arcane_flows.rank end,
        gcd = "spell",

        startsCombat = false,

        start = function()
            applyBuff( "evocation" )

            -- Effects:
            -- [ ] 0. APPLY_AURA, OBS_MOD_POWER, tick_time: 2.0, points: 15, target: TARGET_UNIT_CASTER
            -- [ ] 1. APPLY_AURA, OBS_MOD_HEALTH, tick_time: 2.0, points: 0, target: TARGET_UNIT_CASTER
        end,

        tick = function()
            gain( 0.15 * power.max, "mana" )
        end,

        finish = function()
            removeBuff( "evocation" )
        end,

        onBreakChannel = function()
            removeBuff( "evocation" )
        end,

        -- Affected by:
        -- [ ] aura.demonic_pact[53646.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 48090, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.evocation[56380.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_flows[44378.1] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -60000, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_flows[44379.1] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -120000, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },

    -- Blasts the enemy for $s1 Fire damage.
    fire_blast = {
        id = 42873,
        cast = 0,
        cooldown = function() return 8 - talent.improved_fire_blast.rank end,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.210 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.204, points_per_level: 0.6, points: 23, addl_points: 9, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.332, points_per_level: 1.0, points: 56, addl_points: 15, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.4, points: 102, addl_points: 25, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.8, points: 167, addl_points: 35, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 2.2, points: 241, addl_points: 49, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 2.6, points: 331, addl_points: 63, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 7.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 3.0, points: 430, addl_points: 79, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 8.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 3.3, points: 538, addl_points: 99, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 9.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 3.7, points: 663, addl_points: 123, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 10.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 4.0, points: 759, addl_points: 141, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 11.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 4.9, points: 924, addl_points: 171, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fire_blast[11078.0] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -1000, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fire_blast[11080.0] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -2000, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[18459.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[18460.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[54734.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[11242.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12467.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12469.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 2136, 2137, 2138, 8412, 8413, 10197, 10199, 27078, 27079, 42872, 42873 },
    },

    -- Absorbs $s1 Fire damage.  Lasts $d.
    fire_ward = {
        id = 43010,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return 0.160 * ( 1 - 0.01 * talent.precision.rank ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "fire_ward" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, SCHOOL_ABSORB, points: 165, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 1.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 2.0 APPLY_AURA, SCHOOL_ABSORB, points: 290, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 2.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, SCHOOL_ABSORB, points: 470, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 3.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 4.0 APPLY_AURA, SCHOOL_ABSORB, points: 675, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 4.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 5.0 APPLY_AURA, SCHOOL_ABSORB, points: 875, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 5.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 6.0 APPLY_AURA, SCHOOL_ABSORB, points: 1125, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 6.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 7.0 APPLY_AURA, SCHOOL_ABSORB, points: 1950, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
            -- [x] 7.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] glyph.fire_ward[57926.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] glyph.drain_soul[58070.0] APPLY_AURA, DUMMY, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_shields[11094.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_shields[13043.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 30, target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER

        copy = { 543, 8457, 8458, 10223, 10225, 27128, 43010 },
    },

    -- Hurls a fiery ball that causes $s1 Fire damage and an additional $o2 Fire damage over $d.
    fireball = {
        id = 42833,
        cast = function()
            if buff.fireball_proc.up or buff.presence_of_mind.up then return 0 end
            local base = level > 23 and 3.5 or level > 17 and 3 or level > 11 and 2.5 or level > 5 and 2 or 1.5
            return ( base - ( glyph.fireball.enabled and 0.15 or 0 ) - 0.1 * talent.improved_fireball.rank ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up or buff.fireball_proc.up ) and 0 or 0.19 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 24,

        handler = function()
            if buff.fireball_proc.up then removeBuff( "fireball_proc" )
            elseif buff.clearcasting.up then removeBuff( "clearcasting" )
            elseif buff.presence_of_mind then removeBuff( "presence_of_mind" ) end
        end,

        impact = function()
            if not glyph.fireball.enabled then applyDebuff( "target", "fireball" ) end

            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.123, points_per_level: 0.6, points: 13, addl_points: 9, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 1.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.271, points_per_level: 0.8, points: 30, addl_points: 15, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.5, points_per_level: 1.0, points: 52, addl_points: 21, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 3.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 2, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.793, points_per_level: 1.3, points: 83, addl_points: 33, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 4.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 3, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 1.8, points: 138, addl_points: 49, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 5.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 5, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 2.1, points: 198, addl_points: 67, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 6.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 7, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 7.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 2.4, points: 254, addl_points: 81, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 7.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 8, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 8.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 2.7, points: 317, addl_points: 97, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 8.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 10, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 9.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.0, points: 391, addl_points: 115, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 9.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 13, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 10.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.4, points: 474, addl_points: 135, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 10.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 15, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 11.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.7, points: 560, addl_points: 155, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 11.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 18, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 12.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 3.8, points: 595, addl_points: 165, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 12.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 19, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 13.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 4.0, points: 632, addl_points: 173, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 13.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 21, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 14.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 4.2, points: 716, addl_points: 197, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 14.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 23, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 15.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 4.6, points: 782, addl_points: 215, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 15.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 25, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 16.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.0, points_per_level: 5.2, points: 887, addl_points: 245, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 16.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 2.0, points: 29, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.arcane_power[12042.2] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31641.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31642.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31643.0] APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [x] aura.fireball_proc[57761.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [x] aura.fireball_proc[57761.1] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100000, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[11095.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[12872.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[12873.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.2] APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] glyph.fire_blast[56369.0] APPLY_AURA, DUMMY, points: 50, target: TARGET_UNIT_CASTER
        -- [x] glyph.fireball[56368.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -150, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[11083.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[12351.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31656.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31657.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31658.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fireball[11069.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fireball[12338.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -200, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fireball[12339.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -300, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fireball[12340.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -400, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_fireball[12341.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -500, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31638.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31639.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31640.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[11242.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12467.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12469.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER


        copy = { 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070, 38692, 42832, 42833 },
    },

    -- Calls down a pillar of fire, burning all enemies within the area for $s1 Fire damage and an additional $o2 Fire damage over $d.
    flamestrike = {
        id = 42926,
        cast = function() return ( buff.firestarter.up or buff.presence_of_mind.up ) and 0 or 2 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.firestarter.up or buff.clearcasting.up ) and 0 or 0.300 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if buff.firestarter.up then
                removeBuff( "firestarter" )
            else
                if buff.clearcasting.up then removeBuff( "clearcasting" ) end
                if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
            end

            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 0.6, points: 51, addl_points: 17, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 1.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 12, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 0.8, points: 95, addl_points: 27, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 2.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 22, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.0, points: 153, addl_points: 39, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 3.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 35, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.3, points: 219, addl_points: 53, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 4.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 49, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.5, points: 290, addl_points: 69, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 5.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 66, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.7, points: 374, addl_points: 85, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 6.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 85, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 7.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 1.9, points: 470, addl_points: 105, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 7.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 106, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 8.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 2.8, points: 687, addl_points: 155, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 8.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 155, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
            -- [ ] 9.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.243, points_per_level: 3.5, points: 872, addl_points: 195, radius: 5.0, target: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 9.1 PERSISTENT_AREA_AURA, PERIODIC_DAMAGE, tick_time: 2.0, sp_bonus: 0.122, points: 195, radius: 5.0, target: TARGET_DEST_DYNOBJ_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.arcane_power[12042.2] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31641.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31642.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31643.0] APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.burning_determination[54747.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] aura.burning_determination[54748.0] APPLY_AURA, MECHANIC_IMMUNITY, points: 0, target: TARGET_UNIT_CASTER, mechanic: silenced
        -- [ ] aura.burning_determination[54749.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54748, triggers: burning_determination, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.firestarter[44442.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6971, schools: ['physical', 'holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] aura.firestarter[44443.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 54741, points: 0, value: 6970, schools: ['holy', 'nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [x] aura.firestarter[54741.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [x] aura.firestarter[54741.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.2] APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[11083.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[12351.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31638.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31639.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31640.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[11108.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[12349.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[12350.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER

        copy = { 2120, 2121, 8422, 8423, 10215, 10216, 27086, 42925, 42926 },
    },

    -- Increases the target's chance to critically hit with spells by $s1%.  When the target critically hits the caster's chance to critically hit with spells is increased by $54648s1% for $54648d.  Cannot be cast on self.
    focus_magic = {
        id = 54646,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.060,
        spendType = "mana",

        startsCombat = false,

        usable = function() return group, "cannot cast on self" end,
        handler = function()
            active_dot.focus_magic = active_dot.focus_magic + 1

            -- Effects:
            -- [x] 0. APPLY_AURA, MOD_SPELL_CRIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ALLY
            -- [ ] 1. DUMMY, NONE
        end,

        -- Affected by:
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },

    -- Increases Armor by $s1.  If an enemy strikes the caster, they may have their movement slowed by $6136s1% and the time between their attacks increased by $6136s2% for $6136d.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $d.
    frost_armor = {
        id = 7301,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.240 * ( 1 - ( 0.01 * talent.precision.rank ) ) * ( 1 - ( talent.frost_channeling.enabled and ( 1 + talent.frost_channeling.rank * 0.03 ) or 0 ) ) end,
        spendType = "mana",

        startsCombat = false,
        essential = true,
        nobuff = "frost_armor",

        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "frost_armor" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MOD_RESISTANCE, points: 30, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 1.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 6136, target: TARGET_UNIT_CASTER
            -- [x] 2.0 APPLY_AURA, MOD_RESISTANCE, points: 110, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 2.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 6136, target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, MOD_RESISTANCE, points: 200, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 3.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 6136, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [x] aura.frost_armor[57928.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1800000, target: TARGET_UNIT_CASTER
        -- [ ] aura.ice_armor[56384.0] APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.ice_armor[56384.1] APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_3_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[11160.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12518.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12519.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.frost_warding[11189.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.frost_warding[28332.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER

        copy = { 168, 7300, 7301 },
    },

    -- Blasts enemies near the caster for ${$m1*$<mult>} to ${$M1*$<mult>} Frost damage and freezes them in place for up to $d.  Damage caused may interrupt the effect.
    frost_nova = {
        id = 42917,
        cast = 0,
        cooldown = function() return 25 * ( 1 - ( min( 0.2, 0.07 * talent.ice_floes.rank ) ) ) end,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.070 * ( 1 - 0.01 * buff.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if target[ "within" .. ( 10 + target.arctic_reach.rank ) ] then
                applyDebuff( "target", "frost_nova" )
            end

            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.018, points_per_level: 0.5, points: 18, addl_points: 3, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] 1.1 APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.043, points_per_level: 0.5, points: 32, addl_points: 5, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] 2.1 APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.043, points_per_level: 0.5, points: 51, addl_points: 7, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] 3.1 APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [ ] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.043, points_per_level: 0.5, points: 69, addl_points: 11, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] 4.1 APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [ ] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 0.5, points: 229, addl_points: 31, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] 5.1 APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [ ] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.193, points_per_level: 0.8, points: 364, addl_points: 51, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
            -- [x] 6.1 APPLY_AURA, MOD_ROOT, mechanic: rooted, points: 0, radius: 10.0, target: TARGET_SRC_CASTER, target2: TARGET_UNIT_SRC_AREA_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.frost_nova[56376.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, points: 20, value: 7801, schools: ['physical', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.arctic_reach[16757.1] APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [x] talent.arctic_reach[16758.1] APPLY_AURA, ADD_PCT_MODIFIER, RADIUS, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31674.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -1, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31675.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31676.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -3, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31677.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31678.1] APPLY_AURA, MOD_ATTACKER_RANGED_HIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
        -- [ ] talent.brain_freeze[44546.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 57761, points: 0, value: 23, schools: ['physical', 'holy', 'fire', 'frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.brain_freeze[44548.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 57761, points: 0, value: 23, schools: ['physical', 'holy', 'fire', 'frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.brain_freeze[44549.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 57761, points: 0, value: 23, schools: ['physical', 'holy', 'fire', 'frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31670.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31672.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[55094.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[11207.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[12672.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[15047.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[11151.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12952.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12953.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 122, 865, 6131, 10230, 27088, 42917 },
    },

    -- Absorbs $s1 Frost damage.  Lasts $d.
    frost_ward = {
        id = 43012,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return 0.140 * ( 1 - 0.01 * talent.precision.rank ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "frost_ward" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, SCHOOL_ABSORB, points: 165, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 1.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 2.0 APPLY_AURA, SCHOOL_ABSORB, points: 290, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 2.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, SCHOOL_ABSORB, points: 470, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 3.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 4.0 APPLY_AURA, SCHOOL_ABSORB, points: 675, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 4.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 5.0 APPLY_AURA, SCHOOL_ABSORB, points: 875, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 5.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 6.0 APPLY_AURA, SCHOOL_ABSORB, points: 1125, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 6.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 7.0 APPLY_AURA, SCHOOL_ABSORB, points: 1950, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 7.1 APPLY_AURA, REFLECT_SPELLS_SCHOOL, amplitude: 1.0, points: 0, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] glyph.frost_ward[57927.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_shields[11094.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_shields[13043.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 30, target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER

        copy = { 6143, 8461, 8462, 10177, 28609, 32796, 43012 },
    },

    -- Launches a bolt of frost at the enemy, causing ${$m2*$<mult>} to ${$M2*$<mult>} Frost damage and slowing movement speed by $s1% for $d.
    frostbolt = {
        id = 42842,
        cast = function() return buff.presence_of_mind.up and 0 or 1.5 - ( 0.1 * ( talent.improved_frostbolt.rank + talent.empowered_frostbolt.rank ) ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.110 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 28,

        handler = function()
            if buff.clearcasting.up then removeBuff( "clearcasting" ) end
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
        end,

        impact = function()
            if buff.fingers_of_frost.up then removeStack( "fingers_of_frost" ) end
            applyDebuff( "target", "frostbolt" )
        end,

        -- Effects:
        -- [ ] 1.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 1.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.172, points_per_level: 0.5, points: 17, addl_points: 3, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 1.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 2.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 2.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.283, points_per_level: 0.7, points: 30, addl_points: 5, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 2.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 3.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 3.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.488, points_per_level: 0.9, points: 50, addl_points: 7, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 3.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 4.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 4.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.743, points_per_level: 1.1, points: 73, addl_points: 9, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 4.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 5.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 5.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 1.5, points: 125, addl_points: 13, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 5.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 6.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 6.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 1.7, points: 173, addl_points: 17, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 6.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 7.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 7.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.0, points: 226, addl_points: 21, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 7.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 8.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 8.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.3, points: 291, addl_points: 25, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 8.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 9.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 9.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.6, points: 352, addl_points: 31, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 9.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 10.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 10.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 2.9, points: 428, addl_points: 35, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 10.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 11.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 11.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.2, points: 514, addl_points: 41, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 11.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 12.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 12.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.2, points: 535, addl_points: 43, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 12.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 13.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 13.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.5, points: 596, addl_points: 47, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 13.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 14.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 14.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.8, points: 629, addl_points: 51, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 14.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 15.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 15.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 4.2, points: 701, addl_points: 57, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 15.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 16.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 16.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 4.8, points: 798, addl_points: 63, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] 16.2 APPLY_AURA, MOD_HEALING_PCT, points: 0, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[11071.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[12496.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[12497.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.winters_chill[11180.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] aura.winters_chill[28592.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] aura.winters_chill[28593.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] glyph.frostbolt[56370.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] glyph.ice_block[56372.0] APPLY_AURA, DUMMY, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_reach[16757.0] APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_reach[16758.0] APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44566.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44566.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44567.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44567.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44568.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44568.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44570.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44570.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44571.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44571.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_frostbolt[31682.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- [x] talent.empowered_frostbolt[31682.1] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_frostbolt[31683.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- [x] talent.empowered_frostbolt[31683.1] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -200, target: TARGET_UNIT_CASTER
        -- [ ] talent.frozen_core[31667.0] APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -2, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.frozen_core[31668.0] APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -4, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.frozen_core[31669.0] APPLY_AURA, MOD_DAMAGE_PERCENT_TAKEN, sp_bonus: 1.0, points: -6, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[11207.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[12672.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[15047.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_frostbolt[11070.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_frostbolt[12473.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -200, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_frostbolt[16763.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -300, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_frostbolt[16765.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -400, target: TARGET_UNIT_CASTER
        -- [x] talent.improved_frostbolt[16766.0] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -500, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[11175.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[11175.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[11175.2] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12569.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12569.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12569.2] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -13, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12571.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12571.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12571.2] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: -20, target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[11151.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12952.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12953.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697, 42841, 42842 },
    },

    -- Launches a bolt of frostfire at the enemy, causing ${$m2*$<mult>} to ${$M2*$<mult>} Frostfire damage, slowing movement speed by $s1% and causing an additional $o3 Frostfire damage over $d. This spell will be checked against the lower of the target's Frost and Fire resists.
    frostfire_bolt = {
        id = 47610,
        cast = function() return ( buff.fireball_proc.up or buff.presence_of_mind.up ) and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.fireball_proc.up and 0 or 0.140 * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 28,

        handler = function()
            if buff.fireball_proc.up then removeBuff( "fireball_proc" )
            elseif buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
            if buff.fingers_of_frost.up then removeStack( "fingers_of_frost" ) end
        end,

        impact = function()
            applyDebuff( "frostfire_bolt" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 1.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 3.9, points: 628, addl_points: 103, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 1.2 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, points: 20, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.0 APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -40, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 2.1 SCHOOL_DAMAGE, NONE, sp_bonus: 0.857, points_per_level: 4.5, points: 721, addl_points: 117, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.2 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, points: 30, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [x] aura.arcane_power[12042.2] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [x] aura.fireball_proc[57761.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [x] aura.fireball_proc[57761.1] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100000, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[11071.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[12496.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostbite[12497.0] APPLY_AURA, ADD_TARGET_TRIGGER, trigger_spell: 12494, triggers: frostbite, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostfire[61205.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] aura.frostfire[61205.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2
        -- [ ] aura.improved_scorch[11095.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[12872.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] aura.improved_scorch[12873.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[11083.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[12351.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44566.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44566.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44567.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44567.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44568.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44568.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -6, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44570.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44570.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -8, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44571.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44571.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31656.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31657.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31658.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[11207.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[12672.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[15047.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[11175.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[11175.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -4, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12569.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 2000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12569.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.permafrost[12571.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 3000, target: TARGET_UNIT_CASTER
        -- [ ] talent.permafrost[12571.1] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_1_VALUE, points: -10, target: TARGET_UNIT_CASTER

        copy = { 44614, 47610 },
    },

    -- Increases Armor by $s1 and Frost resistance by $s3.   If an enemy strikes the caster, they may have their movement slowed by $7321s1% and the time between their attacks increased by $7321s2% for $7321d.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $d.
    ice_armor = {
        id = 43008,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.240 * ( 1 - 0.01 * talent.precision.rank ) * ( talent.frost_channeling.enabled and ( 0.99 - 0.03 * talent.frost_channeling.rank ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        essential = true,
        nobuff = "ice_armor",

        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "ice_armor" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MOD_RESISTANCE, points: 290, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 1.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
            -- [x] 1.2 APPLY_AURA, MOD_RESISTANCE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 2.0 APPLY_AURA, MOD_RESISTANCE, points: 380, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 2.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
            -- [x] 2.2 APPLY_AURA, MOD_RESISTANCE, points: 9, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, MOD_RESISTANCE, points: 470, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 3.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
            -- [x] 3.2 APPLY_AURA, MOD_RESISTANCE, points: 12, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 4.0 APPLY_AURA, MOD_RESISTANCE, points: 560, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 4.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
            -- [x] 4.2 APPLY_AURA, MOD_RESISTANCE, points: 15, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 5.0 APPLY_AURA, MOD_RESISTANCE, points: 645, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 5.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
            -- [x] 5.2 APPLY_AURA, MOD_RESISTANCE, points: 18, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [x] 6.0 APPLY_AURA, MOD_RESISTANCE, points: 930, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 6.1 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 7321, target: TARGET_UNIT_CASTER
            -- [x] 6.2 APPLY_AURA, MOD_RESISTANCE, points: 40, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
            -- [ ] 6.3 APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [x] glyph.frost_armor[57928.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 1800000, target: TARGET_UNIT_CASTER
        -- [ ] glyph.ice_armor[56384.0] APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] glyph.ice_armor[56384.1] APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_3_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[11160.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12518.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12519.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.frost_warding[11189.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.frost_warding[28332.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 50, target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER

        copy = { 7302, 7320, 10219, 10220, 27124, 43008 },
    },

    -- Instantly shields you, absorbing $s1 damage.  Lasts $d.  While the shield holds, spellcasting will not be delayed by damage.
    ice_barrier = {
        id = 43039,
        cast = 0,
        cooldown = function() return 30 * ( 1 - 0.01 * talent.precision.rank ) * ( 1 - 0.1 * talent.cold_as_ice.rank ) * ( talent.frost_channeling.enabled and ( 0.99 - 0.03 * talent.frost_channeling.rank ) or 1 ) end,
        gcd = "spell",

        spend = 0.210,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "ice_barrier" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 2.8, points: 438, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 2.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 3.2, points: 549, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 3.6, points: 678, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 4.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 4.0, points: 818, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 5.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 4.4, points: 925, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 6.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 4.8, points: 1075, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 7.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 15.0, points: 2800, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 8.0 APPLY_AURA, SCHOOL_ABSORB, points_per_level: 15.0, points: 3300, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] glyph.ice_barrier[63095.0] APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31674.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -1, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31675.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31676.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -3, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31677.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -4, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_winds[31678.0] APPLY_AURA, MOD_ATTACKER_MELEE_HIT_CHANCE, sp_bonus: 1.0, points: -5, target: TARGET_UNIT_CASTER
        -- [x] talent.cold_as_ice[55091.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -10, target: TARGET_UNIT_CASTER
        -- [x] talent.cold_as_ice[55092.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[11160.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12518.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12519.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER

        copy = { 11426, 13031, 13032, 13033, 27134, 33405, 43038, 43039 },
    },

    -- You become encased in a block of ice, protecting you from all physical attacks and spells for $d, but during that time you cannot attack, move or cast spells.  Also causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = function() return 300 * ( talent.ice_floes.enabled and ( 1 - min( 0.2, 0.07 * talent.ice_floes.rank ) ) or 1 ) end,
        gcd = "spell",

        spend = 15,
        spendType = "mana",

        startsCombat = false,

        nodebuff = "hypothermia",
        handler = function()
            applyBuff( "ice_block" )
            removeDebuff( "player", "hypothermia" )

            -- Effects:
            -- [x] 0. APPLY_AURA, MOD_STUN, points: 0, target: TARGET_UNIT_CASTER
            -- [x] 1. APPLY_AURA, SCHOOL_IMMUNITY, points: 0, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [x] 2. APPLY_AURA, SCHOOL_IMMUNITY, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31670.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31672.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[55094.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
    },

    -- Deals ${$m1*$<mult>} to ${$M1*$<mult>} Frost damage to an enemy target.  Causes triple damage against Frozen targets.
    ice_lance = {
        id = 42914,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.060 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) * ( talent.frost_channeling.enabled and ( 0.99 - 0.03 * talent.frost_channeling.rank ) or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 38,

        handler = function()
            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 3.2, points: 160, addl_points: 27, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 1.3, points: 181, addl_points: 29, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.143, points_per_level: 1.3, points: 220, addl_points: 35, target: TARGET_UNIT_TARGET_ENEMY
        end,

        impact = function()
            if buff.fingers_of_frost.up then removeBuff( "fingers_of_frost" )
            elseif debuff.frost_nova.up then removeDebuff( "target", "frost_nova" )
            elseif debuff.frostbite.up then removeDebuff( "target", "frostbite" ) end
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] glyph.ice_lance[56377.0] APPLY_AURA, DUMMY, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_reach[16757.0] APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.arctic_reach[16758.0] APPLY_AURA, ADD_PCT_MODIFIER, RANGE, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44566.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44567.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44568.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44570.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.chilled_to_the_bone[44571.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 5, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[11160.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12518.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12519.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[11207.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 33, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[12672.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 66, target: TARGET_UNIT_CASTER
        -- [ ] talent.ice_shards[15047.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[11151.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12952.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 4, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.piercing_ice[12953.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 6, value: 16, schools: ['frost'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[11242.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12467.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12469.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 30455, 42913, 42914 },
    },

    -- Hastens your spellcasting, increasing spell casting speed by $s1% and reduces the pushback suffered from damaging attacks while casting by $s2%.  Lasts $d.
    icy_veins = {
        id = 12472,
        cast = 0,
        cooldown = function() return 180 * ( talent.ice_floes.enabled and ( 1 - min( 0.2, 0.07 * talent.ice_floes.rank ) ) or 1 ) end,
        gcd = "off",

        spend = 0.030,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "icy_veins" )
            stat.haste = stat.haste + 20

            -- Effects:
            -- [x] 0. APPLY_AURA, MOD_CASTING_SPEED_NOT_STACK, points: 20, target: TARGET_UNIT_CASTER
            -- [ ] 1. APPLY_AURA, ADD_PCT_MODIFIER, points: 100, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31670.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -7, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[31672.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -14, target: TARGET_UNIT_CASTER
        -- [x] talent.ice_floes[55094.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
    },

    -- $?s54354[Instantly makes the caster invisible, reducing all threat.][Fades the caster to invisibility over $66d, reducing threat each second.]  The effect is cancelled if you perform any actions.  While invisible, you can only see other invisible targets and those who can see invisible.  Lasts $32612d.
    invisibility = {
        id = 66,
        cast = 0,
        cooldown = function() return 180 * ( 1 - 0.15 * talent.arcane_flows.rank ) end,
        gcd = "spell",

        spend = 0.160,
        spendType = "mana",

        startsCombat = false,
        toggle = "defensives",

        handler = function()
            if talent.prismatic_cloak.rank == 3 then
                applyBuff( "invisibility" )
            else
                applyBuff( "invisibility_fading" )
                applyBuff( "invisibility" )
                buff.invisibility.applied = buff.invisibility_fading.expires
            end

            -- Effects:
            -- [x] 0. APPLY_AURA, PERIODIC_TRIGGER_SPELL, tick_time: 1.0, trigger_spell: 35009, points: 0, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [x] talent.arcane_flows[44378.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -15, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_flows[44379.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -30, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [x] talent.prismatic_cloak[31574.1] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: -1000, target: TARGET_UNIT_CASTER
        -- [x] talent.prismatic_cloak[31575.1] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: -2000, target: TARGET_UNIT_CASTER
        -- [x] talent.prismatic_cloak[54354.1] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: -3000, target: TARGET_UNIT_CASTER
    },

    -- The target becomes a Living Bomb, taking $o1 Fire damage over $d.  After $d or when the spell is dispelled, the target explodes dealing $44461s1 Fire damage to all enemies within $44461a1 yards.
    living_bomb = {
        id = 55362,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.220,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "living_bomb" )

            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] glyph.living_bomb[63091.0] APPLY_AURA, ABILITY_PERIODIC_CRIT, points: 10, value: 5, schools: ['physical', 'fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER

        copy = { 44461, 55361, 55362 },
    },

    -- Increases your resistance to all magic by $s1 and allows $s2% of your mana regeneration to continue while casting.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $d.
    mage_armor = {
        id = 43024,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.260,
        spendType = "mana",

        startsCombat = false,

        nobuff = "mage_armor",
        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "mage_armor" )

            -- Effects:
            -- [ ] 1.0 APPLY_AURA, MOD_RESISTANCE, points: 5, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [ ] 1.1 APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
            -- [ ] 2.0 APPLY_AURA, MOD_RESISTANCE, points: 10, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [ ] 2.1 APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
            -- [ ] 3.0 APPLY_AURA, MOD_RESISTANCE, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [ ] 3.1 APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
            -- [ ] 4.0 APPLY_AURA, MOD_RESISTANCE, points: 18, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [ ] 4.1 APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
            -- [ ] 5.0 APPLY_AURA, MOD_RESISTANCE, points: 21, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [ ] 5.1 APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
            -- [ ] 5.2 APPLY_AURA, MOD_AURA_DURATION_BY_DISPEL, points: -50, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 6.0 APPLY_AURA, MOD_RESISTANCE, points: 40, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [ ] 6.1 APPLY_AURA, MOD_MANA_REGEN_INTERRUPT, points: 50, target: TARGET_UNIT_CASTER
            -- [ ] 6.2 APPLY_AURA, MOD_AURA_DURATION_BY_DISPEL, points: -50, value: 1, schools: ['physical'], target: TARGET_UNIT_CASTER
            -- [ ] 6.3 APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] glyph.mage_armor[56383.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_2_VALUE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_shielding[11252.1] APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_shielding[12605.1] APPLY_AURA, ADD_PCT_MODIFIER, EFFECT_1_VALUE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_absorption[29441.1] APPLY_AURA, MOD_RESISTANCE, points_per_level: 0.5, points: 0, value: 124, schools: ['fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_absorption[29444.1] APPLY_AURA, MOD_RESISTANCE, points_per_level: 1.0, points: 0, value: 124, schools: ['fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 6117, 22782, 22783, 27125, 43023, 43024 },
    },

    -- Absorbs $s1 damage, draining mana instead.  Drains $e mana per damage absorbed.  Lasts $d.
    mana_shield = {
        id = 43020,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.070,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "mana_shield" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 120, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 2.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 210, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 300, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 4.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 390, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 5.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 480, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 6.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 570, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 7.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 715, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 8.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 1080, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
            -- [x] 9.0 APPLY_AURA, MANA_SHIELD, amplitude: 1.5, points: 1330, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] talent.arcane_shielding[11252.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_TAKEN, points: -17, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_shielding[12605.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_TAKEN, points: -33, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 1463, 8494, 8495, 10191, 10192, 10193, 27131, 43019, 43020 },
    },

    -- Creates $<images> copies of the caster nearby, which cast spells and attack the mage's enemies.  Lasts $55342d.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.100,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "mirror_image" )

            -- Effects:
            -- [x] 0. APPLY_AURA, MOD_TOTAL_THREAT, points: -90000000, target: TARGET_UNIT_CASTER
            -- [ ] 1. TRIGGER_SPELL, NONE, trigger_spell: 58832, points: 3, target: TARGET_UNIT_CASTER
            -- [ ] 2. APPLY_AURA, PERIODIC_DUMMY, tick_time: 1.0, trigger_spell: 58836, points: 0, target: TARGET_UNIT_CASTER
        end,
    },

    -- Causes $34913s1 Fire damage when hit, increases your critical strike rating by $30482s3% of your Spirit, and reduces the chance you are critically hit by $30482s2%.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $30482d.
    molten_armor = {
        id = 43046,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.280 * ( 1 - 0.01 * talent.precision.rank ) end,
        spendType = "mana",

        startsCombat = false,
        essential = true,
        nobuff = "molten_armor",

        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "molten_armor" )

            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, points: 75, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.0 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 43043, triggers: molten_armor, points: 0, target: TARGET_UNIT_CASTER
            -- [x] 2.1 APPLY_AURA, MOD_ATTACKER_SPELL_AND_WEAPON_CRIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
            -- [x] 2.2 APPLY_AURA, MOD_ABILITY_SCHOOL_MASK, points: 35, value: 1792, value1: 4, target: TARGET_UNIT_CASTER
            -- [x] 2.3 APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER
            -- [x] 3.0 APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 43044, triggers: molten_armor, points: 0, target: TARGET_UNIT_CASTER
            -- [x] 3.1 APPLY_AURA, MOD_ATTACKER_SPELL_AND_WEAPON_CRIT_CHANCE, points: -5, target: TARGET_UNIT_CASTER
            -- [x] 3.2 APPLY_AURA, MOD_ABILITY_SCHOOL_MASK, points: 35, value: 1792, value1: 4, target: TARGET_UNIT_CASTER
            -- [x] 3.3 APPLY_AURA, PERIODIC_DUMMY, tick_time: 6.0, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [ ] glyph.molten_armor[56382.0] APPLY_AURA, ADD_FLAT_MODIFIER, EFFECT_3_VALUE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_absorption[29441.0] APPLY_AURA, DUMMY, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_absorption[29444.0] APPLY_AURA, DUMMY, points: 2, target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.torment_the_weak[29447.0] APPLY_AURA, DUMMY, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.torment_the_weak[55339.0] APPLY_AURA, DUMMY, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.torment_the_weak[55340.0] APPLY_AURA, DUMMY, points: 12, target: TARGET_UNIT_CASTER

        copy = { 34913, 43045, 43046 },
    },

    -- Transforms the enemy into a sheep, forcing it to wander around for up to $d.  While wandering, the sheep cannot attack or cast spells but will regenerate very quickly.  Any damage will transform the target back into its normal form.  Only one target can be polymorphed at a time.  Only works on Beasts, Humanoids and Critters.
    polymorph = {
        id = 12826,
        cast = function() return buff.presence_of_mind.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.070 * ( 1 - 0.01 * talent.arcane_focus.rank ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end

            active_dot.polymorph = 0
            applyDebuff( "target", "polymorph" )

            -- Effects:
            -- [x] 1.0 APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 1.1 APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.0 APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.1 APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 3.0 APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 3.1 APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 4.0 APPLY_AURA, MOD_CONFUSE, points: 0, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 4.1 APPLY_AURA, TRANSFORM, value: 16372, schools: ['fire', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER

        copy = { 118, 12824, 12825, 12826, 28271, 28272, 61025, 61305, 61721, 61780 },
    },

    -- When activated, your next Mage spell with a casting time less than 10 sec becomes an instant cast spell.
    presence_of_mind = {
        id = 12043,
        cast = 0,
        cooldown = function() return 120 - ( 1 - 0.15 * talent.arcane_flows.rank ) end,
        gcd = "off",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "presence_of_mind" )
            -- Effects:
            -- [x] 0. APPLY_AURA, ADD_PCT_MODIFIER, points: -100, target: TARGET_UNIT_CASTER
        end,

        -- Affected by:
        -- [x] talent.arcane_flows[44378.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -15, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_flows[44379.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, points: -30, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_potency[31571.0] APPLY_AURA, DUMMY, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_potency[31572.0] APPLY_AURA, DUMMY, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
    },

    -- Hurls an immense fiery boulder that causes $s1 Fire damage and an additional $o2 Fire damage over $d.
    pyroblast = {
        id = 42891,
        cast = function() return buff.presence_of_mind.up and 0 or 5 - ( talent.fiery_payback.enabled and health.pct < 35 and ( 1.75 * buff.fiery_payback.rank ) or 0 ) end,
        cooldown = function() return ( talent.fiery_payback.enabled and health.pct < 35 and ( 2.5 * buff.fiery_payback.rank ) or 0 ) end,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up or buff.hot_streak.up ) and 0 or 0.220 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 24,

        handler = function()
            if buff.clearcasting.up then removeBuff( "clearcasting" )
            elseif buff.hot_streak.up then removeBuff( "hot_streak" ) end
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
        end,

        impact = function()
            applyDebuff( "target", "pyroblast" )

            -- Effects:
            -- [x] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 1.9, points: 140, addl_points: 47, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 1.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 14, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 2.2, points: 179, addl_points: 57, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 18, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 2.6, points: 254, addl_points: 73, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 3.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 24, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 3.0, points: 328, addl_points: 91, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 4.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 31, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 3.4, points: 406, addl_points: 109, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 5.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 39, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 3.8, points: 502, addl_points: 129, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 6.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 47, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 7.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 4.2, points: 599, addl_points: 151, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 7.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 57, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 8.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 4.6, points: 707, addl_points: 191, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 8.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 67, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 9.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 5.0, points: 845, addl_points: 229, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 9.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 78, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 10.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 5.4, points: 938, addl_points: 253, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 10.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 89, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 11.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 5.8, points: 1013, addl_points: 273, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 11.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 96, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 12.0 SCHOOL_DAMAGE, NONE, sp_bonus: 1.15, points_per_level: 6.8, points: 1189, addl_points: 321, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 12.1 APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.05, points: 113, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.arcane_power[12042.2] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31641.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31642.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31643.0] APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [x] aura.fiery_payback[44440.1] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -1750, target: TARGET_UNIT_CASTER
        -- [x] aura.fiery_payback[44440.2] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: 2500, target: TARGET_UNIT_CASTER
        -- [x] aura.fiery_payback[44441.1] APPLY_AURA, ADD_FLAT_MODIFIER, CAST_TIME, points: -3500, target: TARGET_UNIT_CASTER
        -- [x] aura.fiery_payback[44441.2] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: 5000, target: TARGET_UNIT_CASTER
        -- [x] aura.hot_streak[48108.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, sp_bonus: 1.0, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.2] APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.1] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, sp_bonus: 1.0, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[11083.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[12351.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31656.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 5, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31657.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.empowered_fire[31658.0] APPLY_AURA, ADD_FLAT_MODIFIER, SPELL_POWER, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.1] APPLY_AURA, ADD_PCT_MODIFIER, PERIODIC_DAMAGE_HEALING, sp_bonus: 1.0, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31638.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31639.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31640.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[11108.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[12349.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.world_in_flames[12350.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 6, target: TARGET_UNIT_CASTER

        copy = { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938, 42890, 42891 },
    },

    -- Removes $m1 Curse from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.080 * ( 1 - 0.01 * talent.arcane_focus.rank ) end,
        spendType = "mana",

        startsCombat = false,

        buff = "dispellable_curse",
        handler = function()
            removeBuff( "dispellable_curse" )

            -- Effects:
            -- [x] 0. DISPEL, NONE, value: curse, schools: ['holy'], target: TARGET_UNIT_TARGET_ALLY
        end,

        -- Affected by:
        -- [x] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [x] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },

    -- TODO: Replace with Use Mana Gem.
    -- Restores $s1 mana.
    replenish_mana = {
        id = 42987,
        name = "|cff00ccff[Mana Gem]|r",
        link = "|cff00ccff[Mana Gem]|r",
        known = function()
            return state.mana_gem_charges > 0
        end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,

        item = function() return state.mana_gem_id or 36799 end,
        bagItem = true,
        texture = function() return GetItemIcon( state.mana_gem_id or 36799 ) end,

        usable = function ()
            return mana_gem_charges > 0, "requires mana_gem in bags"
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( state.mana_gem_id )
            return max( 0, start + duration - query_time )
        end,

        handler = function()
            gain( mana_gem_values[ state.mana_gem_id ] * ( glyph.mana_gem.enabled and 1.4 or 1 ), "mana" )
            mana_gem_charges = mana_gem_charges - 1

            -- Effects:
            -- Rank 1 #0 -- ENERGIZE, NONE, points: 389, addl_points: 21, target: TARGET_UNIT_CASTER, resource: mana
            -- Rank 2 #0 -- ENERGIZE, NONE, points: 584, addl_points: 31, target: TARGET_UNIT_CASTER, resource: mana
            -- Rank 3 #0 -- ENERGIZE, NONE, points: 828, addl_points: 43, target: TARGET_UNIT_CASTER, resource: mana
            -- Rank 4 #0 -- ENERGIZE, NONE, points: 1072, addl_points: 55, target: TARGET_UNIT_CASTER, resource: mana
            -- Rank 5 #0 -- ENERGIZE, NONE, points: 2339, addl_points: 121, target: TARGET_UNIT_CASTER, resource: mana
            -- Rank 6 #0 -- ENERGIZE, NONE, points: 3329, addl_points: 171, target: TARGET_UNIT_CASTER, resource: mana
        end,

        -- Affected by:
        -- talent.icy_veins[12472] #1 -- APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- glyph.mana_gem[56367] #0 -- APPLY_AURA, ADD_PCT_MODIFIER, SPELL_EFFECTIVENESS, points: 40, target: TARGET_UNIT_CASTER

        copy = { 5405, 10052, 10057, 10058, 27103, 42987, "mana_gem", "use_mana_gem" },
    },

    -- Scorch the enemy for $s1 Fire damage.
    scorch = {
        id = 42859,
        cast = function() return buff.presence_of_mind.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.080 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if talent.improved_scorch.rank == 3 then
                applyDebuff( "target", "improved_scorch" )
            end

            -- Effects:
            -- [ ] 1.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 0.9, points: 52, addl_points: 13, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 10.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 2.6, points: 320, addl_points: 59, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 11.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 3.1, points: 375, addl_points: 69, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 2.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.1, points: 76, addl_points: 17, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 3.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.3, points: 99, addl_points: 21, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 4.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.5, points: 132, addl_points: 27, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 5.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.7, points: 161, addl_points: 31, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 6.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 1.9, points: 199, addl_points: 40, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 7.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 2.1, points: 232, addl_points: 43, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 8.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 2.3, points: 268, addl_points: 49, target: TARGET_UNIT_TARGET_ENEMY
            -- [ ] 9.0 SCHOOL_DAMAGE, NONE, sp_bonus: 0.429, points_per_level: 2.5, points: 304, addl_points: 57, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] aura.arcane_power[12042.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [x] aura.arcane_power[12042.1] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31641.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31642.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 18350, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] aura.blazing_speed[31643.0] APPLY_AURA, MOD_INCREASE_SPEED, points: 50, target: TARGET_UNIT_CASTER
        -- [x] aura.clearcasting[12536.0] APPLY_AURA, ADD_PCT_MODIFIER, POWER_COST, points: -1000, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[11129.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] aura.combustion[28682.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] aura.icy_veins[12472.1] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 100, target: TARGET_UNIT_CASTER
        -- [x] aura.improved_scorch[11095.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 22959, points: 0, target: TARGET_UNIT_CASTER
        -- [x] aura.improved_scorch[11095.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [x] aura.improved_scorch[12872.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 22959, points: 0, target: TARGET_UNIT_CASTER
        -- [x] aura.improved_scorch[12872.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [x] aura.improved_scorch[12873.0] APPLY_AURA, PROC_TRIGGER_SPELL, trigger_spell: 22959, points: 0, target: TARGET_UNIT_CASTER
        -- [x] aura.improved_scorch[12873.1] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] aura.living_bomb[44457.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 153, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[44461.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 306, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55359.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 256, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55360.0] APPLY_AURA, PERIODIC_DAMAGE, tick_time: 3.0, sp_bonus: 0.2, points: 345, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.living_bomb[55361.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 512, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [ ] aura.living_bomb[55362.0] SCHOOL_DAMAGE, NONE, sp_bonus: 0.4, points: 690, radius: 10.0, target: TARGET_DEST_TARGET_ENEMY, target2: TARGET_UNIT_DEST_AREA_ENEMY
        -- [x] aura.presence_of_mind[12043.0] APPLY_AURA, ADD_PCT_MODIFIER, CAST_TIME, points: -100, target: TARGET_UNIT_CASTER
        -- [ ] aura.slow[31589.0] APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] aura.slow[31589.1] APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, DAMAGE_HEALING, points: -60, target: TARGET_UNIT_TARGET_ENEMY
        -- [ ] glyph.scorch[56371.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15058.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15059.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_instability[15060.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[11083.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 35, target: TARGET_UNIT_CASTER
        -- [ ] talent.burning_soul[12351.0] APPLY_AURA, ADD_PCT_MODIFIER, PUSHBACK_REDUCTION, points: 70, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44449.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44469.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 20, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44470.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44471.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 40, target: TARGET_UNIT_CASTER
        -- [ ] talent.burnout[44472.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11115.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11367.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 4, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.critical_mass[11368.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 6, value: 4, schools: ['fire'], target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[11124.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12378.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12398.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12399.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 8, target: TARGET_UNIT_CASTER
        -- [ ] talent.fire_power[12400.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 10, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[11100.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.flame_throwing[12353.0] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[18459.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[18460.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.incineration[54734.0] APPLY_AURA, ADD_FLAT_MODIFIER, CRIT_CHANCE, sp_bonus: 1.0, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31679.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 6, value: 4919, schools: ['physical', 'holy', 'fire', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.molten_fury[31680.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, sp_bonus: 1.0, points: 12, value: 4920, schools: ['nature', 'frost', 'shadow'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31638.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31639.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.playing_with_fire[31640.0] APPLY_AURA, MOD_DAMAGE_PERCENT_DONE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29438.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [x] talent.precision[29438.1] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -1, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29439.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 2, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.precision[29440.0] APPLY_AURA, MOD_SPELL_HIT_CHANCE, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34293.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34295.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 2, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.pyromaniac[34296.0] APPLY_AURA, MOD_SPELL_CRIT_CHANCE_SCHOOL, points: 3, value: 127, schools: ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[11170.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 849, schools: ['physical', 'frost', 'arcane'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12982.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 910, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.shatter[12983.0] APPLY_AURA, OVERRIDE_CLASS_SCRIPTS, value: 911, schools: ['physical', 'holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[11242.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12467.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 4, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_impact[12469.0] APPLY_AURA, ADD_PCT_MODIFIER, DAMAGE_HEALING, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35578.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 25, target: TARGET_UNIT_CASTER
        -- [ ] talent.spell_power[35581.0] APPLY_AURA, ADD_PCT_MODIFIER, CRIT_DAMAGE, points: 50, target: TARGET_UNIT_CASTER

        copy = { 2948, 8444, 8445, 8446, 10205, 10206, 10207, 27073, 27074, 42858, 42859 },
    },

    -- Reduces target's movement speed by $s1%, increases the time between ranged attacks by $s2% and increases casting time by $s3%.  Lasts $d.  Slow can only affect one target at a time.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.120,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "slow" )
            -- Effects:
            -- [x] 0. APPLY_AURA, MOD_DECREASE_SPEED, mechanic: snared, points: -60, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 1. APPLY_AURA, ADD_PCT_MODIFIER_BY_LABEL, points: -60, target: TARGET_UNIT_TARGET_ENEMY
            -- [x] 2. APPLY_AURA, HASTE_SPELLS, points: -30, target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },

    -- Slows friendly party or raid target's falling speed for $d.
    slow_fall = {
        id = 130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.060,
        spendType = "mana",

        startsCombat = false,
        bagItem = function()
            if glyph.slow_fall.enabled then return end
            return 17056
        end,

        handler = function()
            applyBuff( "slow_fall" )
            -- Effects:
            -- [x] 0. APPLY_AURA, FEATHER_FALL, target: TARGET_UNIT_TARGET_RAID
        end,

        -- Affected by:
        -- [x] glyph.slow_fall[57925.0] APPLY_AURA, NO_REAGENT_USE, points: 0, value: 14, schools: ['holy', 'fire', 'nature'], target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[11210.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 15, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_subtlety[12592.1] APPLY_AURA, ADD_FLAT_MODIFIER, RESOURCE_GENERATION, points: 30, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31584.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 3, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31585.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 6, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31586.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 9, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31587.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 12, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.mind_mastery[31588.0] APPLY_AURA, MOD_SPELL_DAMAGE_OF_STAT_PERCENT, points: 15, value: 126, schools: ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], value1: 3, target: TARGET_UNIT_CASTER
    },

    -- Steals a beneficial magic effect from the target.  This effect lasts a maximum of 2 min.
    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.200,
        spendType = "mana",

        startsCombat = true,

        debuff = "stealable_magic",
        handler = function()
            removeDebuff( "target", "stealable_magic" )

            -- Effects:
            -- [x] 0. STEAL_BENEFICIAL_BUFF, NONE, value: 1, schools: ['physical'], target: TARGET_UNIT_TARGET_ENEMY
        end,

        -- Affected by:
        -- [ ] talent.arcane_focus[11222.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12839.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] talent.arcane_focus[12840.0] APPLY_AURA, ADD_FLAT_MODIFIER, HIT_CHANCE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[11247.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 3, target: TARGET_UNIT_CASTER
        -- [ ] talent.magic_attunement[12606.1] APPLY_AURA, ADD_FLAT_MODIFIER, RANGE, points: 6, target: TARGET_UNIT_CASTER
    },

    -- Summon a Water Elemental to fight for the caster$?(s70937)[][ for $70907d].
    summon_water_elemental = {
        id = 31687,
        cast = 0,
        cooldown = function() return ( glyph.water_elemental.enabled and 150 or 180 ) * ( 1 - 0.1 * talent.cold_as_ice.rank ) end,
        gcd = "spell",

        spend = function() return 0.160 * ( talent.frost_channeling.enabled and ( 0.99 - 0.03 * talent.frost_channeling.rank ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            summonPet( "water_elemental", spec.auras.water_elemental.duration )
            applyBuff( "water_elemental" )

            -- Effects:
            -- [ ] 0. DUMMY, NONE, target: TARGET_DEST_CASTER_FRONT
        end,

        -- Affected by:
        -- [ ] aura.icy_veins[56374.0] APPLY_AURA, DUMMY, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] aura.polymorph[56375.0] APPLY_AURA, DUMMY, points: 2, target: TARGET_UNIT_CASTER
        -- [ ] glyph.eternal_water[70937.0] APPLY_AURA, DUMMY, points: 0, target: TARGET_UNIT_CASTER
        -- [ ] glyph.water_elemental[56373.0] APPLY_AURA, ADD_FLAT_MODIFIER, COOLDOWN, points: -30000, target: TARGET_UNIT_CASTER
        -- [x] talent.cold_as_ice[55091.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -10, target: TARGET_UNIT_CASTER
        -- [x] talent.cold_as_ice[55092.0] APPLY_AURA, ADD_PCT_MODIFIER, COOLDOWN, sp_bonus: 1.0, points: -20, target: TARGET_UNIT_CASTER
        -- [x] talent.enduring_winter[44557.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 5000, target: TARGET_UNIT_CASTER
        -- [x] talent.enduring_winter[44560.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 10000, target: TARGET_UNIT_CASTER
        -- [x] talent.enduring_winter[44561.0] APPLY_AURA, ADD_FLAT_MODIFIER, BUFF_DURATION, points: 15000, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[11160.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -4, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12518.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -7, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
        -- [x] talent.frost_channeling[12519.0] APPLY_AURA, MOD_POWER_COST_SCHOOL_PCT, points: -10, value: 84, schools: ['fire', 'frost', 'arcane'], value1: 1, target: TARGET_UNIT_CASTER
    }
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 1459,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    potion = "potion_of_speed",

    -- package = "",
    -- package1 = "",
    -- package2 = "",
    -- package3 = "",
} )

spec:RegisterSetting( "spellsteal_cooldown", 0, {
    type = "range",
    name = strformat( CAPACITANCE_SHIPMENT_COOLDOWN, Hekili:GetSpellLinkWithTexture( spec.abilities.spellsteal.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended more frequently than the specified timeframe (in seconds).\n\n"
        .. "This setting can prevent %s from remaining the first recommendation when your enemy has stacking buffs or multiple buffs.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.spellsteal.id ), spec.abilities.spellsteal.name ),
    width = "full",
    min = 0,
    max = 15,
    step = 0.1
} )

spec:RegisterStateExpr( "spellsteal_cooldown", function()
    return settings.spellsteal_cooldown or 0
end )


spec:RegisterSetting( "living_bomb_cap", 3, {
    type = "range",
    name = strformat( SPELL_MAX_CHARGES:gsub( "%%d", "%%s"), Hekili:GetSpellLinkWithTexture( spec.abilities.living_bomb.id ) ),
    desc = strformat( "When target swapping is enabled, %s may be recommended on the specified number of targets.\n\n"
        .. "This setting can help balance mana expenditure vs. multi-target damage.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.living_bomb.id ) ),
    width = "full",
    min = 1,
    max = 10,
    step = 1
} )

spec:RegisterStateExpr( "living_bomb_cap", function()
    return settings.living_bomb_cap or 3
end )


spec:RegisterSetting( "use_cold_snap", false, {
    type = "toggle",
    name = strformat( "%s %s", USE, Hekili:GetSpellLinkWithTexture( spec.abilities.cold_snap.id ) ),
    desc = strformat( "If enabled, the default Frost priority %s may recommend to reset the cooldown of %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.cold_snap.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.icy_veins.id ) ),
} )

spec:RegisterStateExpr( "use_cold_snap", function()
    return settings.use_cold_snap
end )


spec:RegisterPackSelector( "arcane", "Arcane Wowhead", "|T135932:0|t Arcane",
    "If you have spent more points in |W|T135932:0|t Arcane|w than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "fire", "Fire Wowhead", "|T135810:0|t Fire",
    "If you have spent more points in |W|T135810:0|t Fire|w than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "frost", "Frost Wowhead", "|T135846:0|t Frost",
    "If you have spent more points in |W|T135846:0|t Frost|w than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )

spec:RegisterPack( "Arcane Wowhead", 20230924, [[Hekili:9EvBVTTnq4FlffWjfRw2X5TLIMc01bSLGTGH5o09jjrjF2MiuKAKu2nfb63(UJ6Lqjl7g0c0Vyjt(W7nE39Ck8KWpgoFbZcH3nB6StNE1SZdMoD6StonCU9HCiCEol9E2k8fjld)996uMekJ)KA7AGTG2)bHcFbLJrvOtrmRT2CZBMmz72TbBRWfKQYMSvzf3pzvbFbmjvWmgWmjdL9eMtOtwKBgRvwMLRKJtvkXc1wPzmlHl4woygNVbLEsbxyVrgMmSHplCoRWUwPdN)7W94jr7HVybuDaWKgoNoW4PxnE2zVPm(gjkBMOm2QzsJWP8Y4LAvwRtgeoxWnwd5JmfGpUZf3ajlralc)LW5PAUf0Cgg1y6vGnyl3UMlpzkEIusK4tNtgbFoxOm0kw00DISgqUgmGmfIulJY4Yf(kaXEQp2eb)lFHP7J5mFmlf4nMXQ53dDHzPaXswHW26knNjvvirhXKdcrpz3XwDamwG1hvhRudzQnquAH2adzP7jakaPnGlXWfzkrSeJsNtsmO(aLXJkJtkwUCyuuAJdsLDeSsOsyIi7AqNHpnS8CqhLUMUPc04f8dEbnUgI2srw0ip)hHr6G0Q2GI8NmMdz4K9DrN0hv1ZoH5l9ruNbMR2c6E4(zFC80hI2aCPPhOR8bLX1ALoIN5Ao0bhM13nUrLDAEE1b)hd2(GjFGQ44Y7bRbFBnZIlQb5r4tf5WB5eomplLVKdunyJMlmqeEpKzC6A)vIeEm7dKqg28Om(DLXZ8Y0zcru1FIOQ7QA8OQUCuvoj8z7v4la39wDinb7MzdmwSxzz81LXN5UzpU(YnJBmCbIIP1y0cVIlJF8XYySGFt0Q0fbx0roLXVAN7SAru5YN(DzvdAsTzJyblxUAh9xJZP(ZgiNYPQ(Pb7V8jJjzb5POR(2Y4lN63XihlS4M1reeNuU45jf)wTWgvQRrEvZomoJ0pjm7qDU77iAUqWzsIhRtA7CihZ5sanMfH8h(2HMX9Q23rqUGBBh0b9Kxug)CeYo7ZX2kcbKAR0rFNPD7D6mtvTrmDMs3NAaJxBWwveQgMv0zXwtsmVa7i8P3)33DZD)gYCwg)X1yjkplxPX7GLkm0CunXYrOdb)xb2vdDkJkJk5lSQmKWgxa7GjxbMGYB)donmbXd)bLe1RB7JQ7U(VOuSkV)30Afx)4t(8RAp)5FZNV82BCMpDStBimkJD0942uUJAjwOeo)LLX)jg0qnvpc0T4k(t6GDnh76A(0SoJDt5WtRhWzmf1htt5GdYCWjDCcVxghzSVex(VAYMlVTYCnbTj4)01t2jZ518LxtjxJouI1HevBwejPx81e1O9NFoSwEkvSXd)1QCOw4ii)5s8x)P5q8x1FUJkr(HMySpSwsxYXoaJ(OdZIp6zpMHVYpe6Vt7zNjk81B1yc(R4pwG)6TJb4VOpTVll9BKo3xMTe6DUX7Xp)AIz(AKyMcoDP2F3SbCNggtc(EPfV(SrhVhk6hFCp0ZVAaLvFSVMU2l17OkA3HKSBIGo52(mKKgBObF7Lt9b2sc2bZjtPQSM6qmC(KQA)YKQ0VoFgt)J0)Bv6VFZ3N0F9oFtcLnqJEsKoH))]] )
spec:RegisterPack( "Fire Wowhead", 20230925, [[Hekili:DAvxVTTnu0FlffW5HflBR20LuahG9b2wc2cgIBrFtsuuuweMIuLKkAUpOF77EPSKPKTZkgcqSn5LhE)4CVhgTk6trBYiww0tHldF3Y7cVjy5T3egUkAJDFflAtfHUJSf(IKuc))34AwBYxunfmsgU7EHc(cGIrvRPGffwBL5Jlw000e00zxavvUOrzf7wSTMNXwqfeJHzwuciVihGCrwLzUwzjwUsoNQuImvJ0mNKYfClNzMx9cGDAnxyFqgLEwNE1DGxuXOrpDl4g8SmwNLmdnAdA58L3np8Mp2M8GeaLiAtSAI0iC3ABsUwvoeBbrBeCJ1GHgrXGpEYLSyssQGLf9ZrBOAULP5eivr0Bz2GgUTGlxTeobfHeCyiqTXneW5TG3obGERYfqU1y18DmFutRZZdWSJbWhwlOUcDkjlMcP(BreF33PlfE8YY0KTkPjovZi2ceK37IXbpM)TVr0z(WAH)G0yoPwyhse9hGQQLWDcjEHy8HUy86S1yzeHx8CCX4(6)qe2FWsUwR0X8shJC0D9(X(uzATP77JS6gFR409XVW4sZeJ(GVrUAtmLunXOF03Ok1zURBNe9ipuZR6S8ZgOnIi3JuqUChZAGVvqSWIAM8k4tLTGPB4ODiPMNZziPS)kRnSyOwxAWR6UlKOf8x4YTXPq6ask7PcwChVWGfXnLK)jE8Q(NOlOpHrz5q(WQIZ4GNDFBYQW2KzTjzmhD178bUs44W(z22Abr3M88HED07HgMlXIXa5fwmtYkHHaU7ZJktjcrC3pIXM1Uw24Ujvytlc(L7ADoCHYgdTEmYUa4FuRxrDVw56FDWmLlFeMsfgYEmgOJn(4bVCl6wX(QIayQJXINjO3OJi1VfKpfDOnIMJBLsM22bHqLMHTae75gB1FAIMsGEVunxi4ejo7EuTAdRc4xPmOAHdp99CnHN5Q6Uu4jaf038E5K2BAt(Ea5K95WSgHGrThyxtcMHTF9HJoeRL8VwZIj6sLEcALq6Mj72Ay4Y5RHAvDLZlpqvZu2GCfT2eddP402K1TjEccEB5kvqX6fy4jU3Gyw0MgIwcCkOF8l)0Zp9Wt)oOz1M8PcOJJxwP0W4HCfuxU6Wq5RGSj7R1aDaYOgvjoBP2QkbnsybAbrULzcAF8pHHTTjFaq7ZstDfIeAqNZbWnmS7kW42hFOS3I3D0iNQiSnet12ci)S5py7avAK1PY5cGg922K)cMqdxJ75cpc)2)vbWC35U5UhFxWC3lc4u3JbMJJ3NJViae9F1xf4GEcpfD83cl)399aTp256MGH2IFy9It4BxZZxJuYzVgD81GAG7Hi9M)lOMDzw95VfFojEdNNdF(Z6X6WJ6iTZopHD9Y(e4V2XTgqeWXxR3F9JA3xFqpF9zKZ7G9x6lJ(a4lSp(c7fY9xDq42FXbUR)IDcZoAY)tfxF0g0CDaEIwMVPE6GxpsID9QRpr2D9evxSgDQA79RcNDbv2rPSjIIxJYHRb1qe1X6P3hokx1R3nWUMQnokDpOYHM3PboA)rAxow35L7MckkOHuWEEm45WohFiTxYP)92tn2790d8XBhIQXVOE6zh)84tVSWt9SdpyghMh9V]] )
spec:RegisterPack( "Frost Wowhead", 20230930, [[Hekili:fJ1FpsTnq0plOkT3Du2S)4G7a0DivkQTGApv1qf9VsI3Kj76Eo2bBNBzpDkF27yNnjoztwOuHQqcYAp(nppEM5ztWIG3h4Nq0qWnlNV885V485ElE6Y5p95b(6D5qGFoj(wYA8dojd)7Fsku6YOpi2UbijMP3Xe4himkrHmgnzJwNRE5SzB3U1BBLDEXISzBfA2TZwxqtGzXmIsbQzzi0Zsnyoljxnvk0envWNgleSeXwUAkzfLr1uqnn)oe8vfuM(T8Gvdt7lrAKdXb3G8FdnjbQSeuXb()g6RxwgvTdENllPX7MEhq5QwEo1YqACf5MA45uddrsCuww(oFixdzRazzKHByisksPmK7FxzuxoGd8nJgi29ys57WrXH)DjG4VIGeGeBaq5Lxp03F9mImMWHWvskJrj8y4j00RLeAYKvfPPEhmTNX1hfkkxdmgeRni9OphuDMRzPhXlXc(FxiHWmcNeUgYmEP(7W4ne5AqD1YHxBMGPbEirMjKM1z9DbN(XcOAWJ4xvrwMGhUftdLHadYaUMWS7XCq7zwYDWK1SD5B8a0goHvzShWjRyqYWWMkIlu4Mznn2G1APOiFsfyHjcTNZ8xpFyiY3jfRWehBaFLqPQp6FdKskyTh82OxbgJLyvdJ5oUDaLgWDeJINeXjx3ouyDkxfS)yDcOlazuPuidPMC2oapEy7ljwHiG1jH26e3b3NWKl2I57oJNYW(wHXKC3bZfMVEsHccfPPHRXn3IUbfwsOItYn0YyvZavzNnmOkJToA4mUeYi4)(QlMBlf)tfugr47kJ0sk)wqRWV2GLGrejWpb)xHEdi3sn2z6GrtPqINlNm0GI1ZQwaFda5MMjaCp(lTOmcRfW4l(JDyZ4YitoaAaLVgpHrFKw36jQQUa9fndtiWiNOqXq6TLQ3GKAVDRWYdCzY9)mLkXL8ACWomlbPryQLfM41PjGniHTSUh4Ef5p8q1VRObgXdTDZ8uAuB56fNn50kS8sRDsOXXEuEykJUEJ(HhCnO7CN15WUE(MA5dCkwmHPByoNNdTBpbDgS(m8QymkgQPzWJpY(4aA0SpA4YkS1hVfC0E3fTIrV)EImXy((YDGdzyZ8xTCYJYe3HUTBok3K9AtnhCnAZjS2ZCIs5lMp5qi2xZaFkNjuMcIVoyQ2P19BQMV7YwoVZofW4PTd9NRo0mrtB9owv3K3lpwF1LDGhUteBfg7yZ5ZhmrjW)o8SehT9Meb(BjsoUhub(F4h(JBE7n)mkzxg9(nyYpnlxiXAIutrXjjv9tpPmscFSaddjyfLWu)rk0ImSbwITudtyuyjZVInslJwS8LMwMC0X25pzF(4FDsvnCZVR79HJF6IpDMNPl(BT(3SSLOtS7hSmNQ0g8d8r3Urid8)f4w8Mab(2zS3XRIP4N3yVZx1sd8DB)h4V3HbVoqJXdJDTJ0SKwzad(wPb3bB0gmyCURVCve65RN2ZxXsSvNKsc8Fuz0rKfCy1GYkgSFMlhA6q3Jax4AKRwsp7U01UgTLEg9CJroPRMyEZIQY57TIxm6(VJ6tz0KYObuGSJpUkuz0RkJUyU7P(Ean(EX8Eo3CDzjnVY0VsLRwF1OBz91IrsQC67oeb(FuPZ9W40YO(IBLrp8W(ZKregIUgR5lJoZEiDADv7OIDvaoUGhIKns2V8SLLJj8zjWHIFnxXQts0acHLrxHgulgwg94JUVDktAA2A495hN3hks2dOMqMfTXBC0viZwcS0UfXokvAuTaxR9AH8z)7HSNgPDS((WvV26Nl(24N(I6wFD5O(AVC(bOV0PDrRaVfSJ2ERV4EVgDlgVtxTuTnn7sh3lHCmNLQ2yX9axBKQ63cBeup3b1MRjybOJOOZTdCjV28w(9VYQriDGEzh8U2ED0o4)HGw2AECCBt(HFG8qAZD0l)sa5G57(s7d2mnt3OQpA029D32O(YofbDER(X1(h(14oxOW517nk9JfvAFtUDV)F8sfJx8AFWU1f7lJ79ODREGBXv7unxWy4Ob(qENRru)g)G2)e8pd]] )