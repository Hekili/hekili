if UnitClassBase( 'player' ) ~= 'PALADIN' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 2 )

spec:RegisterResource( Enum.PowerType.Mana )


-- Idols
spec:RegisterGear( "libram_of_discord", 45510 )
spec:RegisterGear( "libram_of_fortitude", 42611, 42851, 42852, 42853, 42854 )
spec:RegisterGear( "libram_of_valiance", 47661 )
spec:RegisterGear( "libram_of_three_truths", 50455 )

-- Sets
spec:RegisterGear( "tier7ret", 43794, 43796, 43801, 43803, 43805, 40574, 40575, 40576, 40577, 40578 )
spec:RegisterGear( "tier10ret", 50324, 50325, 50326, 50327, 50328, 51160, 51161, 51162, 51163, 51164, 51275, 51276, 51277, 51278, 51279 )

-- Hooks
local LastConsecrationCast = 0
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= state.GUID then
        return
    end
end, false )

local aura_assigned
local blessing_assigned
spec:RegisterHook( "reset_precast", function()
    if not aura_assigned then
        class.abilityList.assigned_aura = "|cff00ccff[Assigned Aura]|r"
        class.abilities.assigned_aura = class.abilities[ settings.assigned_aura or "devotion_aura" ]

        if faction == "horde" then
            class.abilities.seal_of_vengeance = class.abilities.seal_of_corruption
        end
        aura_assigned = true
    end

    if not blessing_assigned then
        class.abilityList.assigned_blessing = "|cff00ccff[Assigned Blessing]|r"
        class.abilities.assigned_blessing = class.abilities[ settings.assigned_blessing or "blessing_of_kings" ]
        blessing_assigned = true
    end
end )


-- Talents
spec:RegisterTalents( {
    anticipation                    = {  1629, 5, 20096, 20097, 20098, 20099, 20100 },
    ardent_defender                 = {  1751, 3, 31850, 31851, 31852 },
    aura_mastery                    = {  1435, 1, 31821 },
    avengers_shield                 = {  1754, 5, 31935, 32699, 32700, 48826, 48827 },
    beacon_of_light                 = {  2192, 1, 53563 },
    benediction                     = {  1407, 5, 20101, 20102, 20103, 20104, 20105 },
    blessed_hands                   = {  2198, 2, 53660, 53661 },
    blessed_life                    = {  1744, 3, 31828, 31829, 31830 },
    blessing_of_sanctuary           = {  1431, 1, 20911 },
    combat_expertise                = {  1753, 3, 31858, 31859, 31860 },
    conviction                      = {  1411, 5, 20117, 20118, 20119, 20120, 20121 },
    crusade                         = {  1755, 3, 31866, 31867, 31868 },
    crusader_strike                 = {  1823, 1, 35395 },
    deflection                      = {  1403, 5, 20060, 20061, 20062, 20063, 20064 },
    divine_favor                    = {  1433, 1, 20216 },
    divine_guardian                 = {  2281, 2, 53527, 53530 },
    divine_illumination             = {  1747, 1, 31842 },
    divine_intellect                = {  1449, 5, 20257, 20258, 20259, 20260, 20261 },
    divine_purpose                  = {  1757, 2, 31871, 31872 },
    divine_sacrifice                = {  2280, 1, 64205 },
    divine_storm                    = {  2150, 1, 53385 },
    divine_strength                 = {  2185, 5, 20262, 20263, 20264, 20265, 20266 },
    divinity                        = {  1442, 5, 63646, 63647, 63648, 63649, 63650 },
    enlightened_judgements          = {  2191, 2, 53556, 53557 },
    eye_for_an_eye                  = {  1632, 2,  9799, 25988 },
    fanaticism                      = {  1759, 3, 31879, 31880, 31881 },
    guarded_by_the_light            = {  2194, 2, 53583, 53585 },
    guardians_favor                 = {  1425, 2, 20174, 20175 },
    hammer_of_the_righteous         = {  2196, 1, 53595 },
    healing_light                   = {  1444, 3, 20237, 20238, 20239 },
    heart_of_the_crusader           = {  1464, 3, 20335, 20336, 20337 },
    holy_guidance                   = {  1746, 5, 31837, 31838, 31839, 31840, 31841 },
    holy_power                      = {  1627, 5,  5923,  5924,  5925,  5926, 25829 },
    holy_shield                     = {  1430, 6, 20925, 20928, 20927, 27179, 48951, 48952 },
    holy_shock                      = {  1502, 1, 20473 },
    illumination                    = {  1461, 5, 20210, 20212, 20213, 20214, 20215 },
    improved_blessing_of_might      = {  1401, 2, 20042, 20045 },
    improved_blessing_of_wisdom     = {  1446, 2, 20244, 20245 },
    improved_concentration_aura     = {  1450, 3, 20254, 20255, 20256 },
    improved_devotion_aura          = {  1422, 3, 20138, 20139, 20140 },
    improved_hammer_of_justice      = {  1521, 2, 20487, 20488 },
    improved_judgements             = {  1631, 2, 25956, 25957 },
    improved_lay_on_hands           = {  1443, 2, 20234, 20235 },
    improved_righteous_fury         = {  1501, 3, 20468, 20469, 20470 },
    infusion_of_light               = {  2193, 2, 53569, 53576 },
    judgements_of_the_just          = {  2200, 2, 53695, 53696 },
    judgements_of_the_pure          = {  2199, 5, 53671, 53673, 54151, 54154, 54155 },
    judgements_of_the_wise          = {  1758, 3, 31876, 31877, 31878 },
    lights_grace                    = {  1745, 3, 31833, 31835, 31836 },
    onehanded_weapon_specialization = {  1429, 3, 20196, 20197, 20198 },
    pure_of_heart                   = {  1742, 2, 31822, 31823 },
    purifying_power                 = {  1743, 2, 31825, 31826 },
    pursuit_of_justice              = {  1634, 2, 26022, 26023 },
    reckoning                       = {  1426, 5, 20177, 20179, 20181, 20180, 20182 },
    redoubt                         = {  1421, 3, 20127, 20130, 20135 },
    repentance                      = {  1441, 1, 20066 },
    righteous_vengeance             = {  2149, 3, 53380, 53381, 53382 },
    sacred_cleansing                = {  2190, 3, 53551, 53552, 53553 },
    sacred_duty                     = {  1750, 2, 31848, 31849 },
    sanctified_light                = {  1465, 3, 20359, 20360, 20361 },
    sanctified_retribution          = {  1756, 1, 31869 },
    sanctified_wrath                = {  2147, 2, 53375, 53376 },
    sanctity_of_battle              = {  1761, 3, 32043, 35396, 35397 },
    seal_of_command                 = {  1481, 1, 20375 },
    seals_of_the_pure               = {  1463, 5, 20224, 20225, 20330, 20331, 20332 },
    sheath_of_light                 = {  2179, 3, 53501, 53502, 53503 },
    shield_of_the_templar           = {  2204, 3, 53709, 53710, 53711 },
    spiritual_attunement            = {  2282, 2, 31785, 33776 },
    spiritual_focus                 = {  1432, 5, 20205, 20206, 20207, 20209, 20208 },
    stoicism                        = {  1748, 3, 31844, 31845, 53519 },
    swift_retribution               = {  2148, 3, 53379, 53484, 53648 },
    the_art_of_war                  = {  2176, 2, 53486, 53488 },
    touched_by_the_light            = {  2195, 3, 53590, 53591, 53592 },
    toughness                       = {  1423, 5, 20143, 20144, 20145, 20146, 20147 },
    twohanded_weapon_specialization = {  1410, 3, 20111, 20112, 20113 },
    unyielding_faith                = {  1628, 2,  9453, 25836 },
    vengeance                       = {  1402, 3, 20049, 20056, 20057 },
    vindication                     = {  1633, 2,  9452, 26016 },
} )


-- Auras
spec:RegisterAuras( {
    aura = {
        alias = { "devotion_aura", "retribution_aura", "concentration_aura", "shadow_resistance_aura", "frost_resistance_aura", "fire_resistance_aura", "crusader_aura" },
        aliasMode = "first",
        aliasType = "buff",
    },
    active_consecration = {
        duration = function() return 8 + (glyph.consecration.enabled and 2 or 0) end,
        max_stack = 1,
        generate = function ( t )
            local applied = action.consecration.lastCast

            if applied and now - applied < 8 + (glyph.consecration.enabled and 2 or 0) then
                t.count = 1
                t.expires = applied + 8 + (glyph.consecration.enabled and 2 or 0)
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
    -- Ardent Defender recently prevented your death.
    ardent_defender = {
        id = 66233,
        duration = 120,
        max_stack = 1,
    },
    -- Increases speed by $s2%.
    argent_charger = {
        id = 66906,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases speed by $s2%.
    argent_warhorse = {
        id = 66907,
        duration = 3600,
        max_stack = 1,
    },
    -- Concentration Aura provides immunity to Silence and Interrupt effects.  Effectiveness of all other auras increased by $s1%.
    aura_mastery = {
        id = 31821,
        duration = 6,
        max_stack = 1,
        shared = "player"
    },
    -- Dazed.
    avengers_shield = {
        id = 48827,
        duration = 10,
        max_stack = 1,
        copy = { 31935, 32699, 32700, 48826, 48827 },
    },
    -- All damage and healing caused increased by $s1%.
    avenging_wrath = {
        id = 31884,
        duration = 20,
        max_stack = 1,
    },
    -- Beacon of Light.
    beacon_of_light = {
        id = 53563,
        duration = function() return glyph.beacon_of_light.enabled and 90 or 60 end,
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
    blessed_life = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=31830)
        id = 31830,
        duration = 3600,
        max_stack = 1,
        copy = { 31830, 31829, 31828 },
    },
    blessing = {
        alias = { "blessing_of_kings", "blessing_of_might", "blessing_of_sanctuary", "blessing_of_wisdom", "greater_blessing_of_kings", "greater_blessing_of_might", "greater_blessing_of_sanctuary", "greater_blessing_of_wisdom" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Increases speed by $s2%.
    charger = {
        id = 23214,
        duration = 3600,
        max_stack = 1,
    },
    -- $s1 damage every $t1 $lsecond:seconds;.
    consecration = {
        id = 48819,
        duration = function() return glyph.consecration.enabled and 10 or 8 end,
        tick_time = 1,
        max_stack = 1,
        copy = { 20116, 20922, 20923, 20924, 26573, 27173, 48818, 48819 },
    },
    -- Mounted speed increased by $s1%.  This does not stack with other movement speed increasing effects.
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    -- Increases armor by $s1.
    devotion_aura = {
        id = 48942,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        copy = { 465, 643, 1032, 10290, 10291, 10292, 10293, 27149, 48941, 48942 },
    },
    -- Critical effect chance of next Flash of Light, Holy Light, or Holy Shock spell increased by $s1%.
    divine_favor = {
        id = 20216,
        duration = 3600,
        max_stack = 1,
    },
    -- Reduced damage taken.
    divine_guardian = {
        id = 70940,
        duration = 6,
        max_stack = 1,
    },
    -- Mana cost of all spells reduced by $s1%.
    divine_illumination = {
        id = 31842,
        duration = 15,
        max_stack = 1,
    },
    -- Complete immunity but unable to move.
    divine_intervention = {
        id = 19753,
        duration = 180,
        max_stack = 1,
    },
    -- Gaining $o1% of total mana.  Healing spells reduced by $s2%.
    divine_plea = {
        id = 54428,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
    },
    -- Damage taken reduced by $s2%.
    divine_protection = {
        id = 498,
        duration = 12,
        max_stack = 1,
    },
    -- $s1% of all damage taken by party members redirected to the Paladin.
    divine_sacrifice = {
        id = 64205,
        duration = 10,
        max_stack = 1,
    },
    -- Immune to all attacks and spells, but reduces all damage you deal by $s1%.
    divine_shield = {
        id = 642,
        duration = 12,
        max_stack = 1,
    },
    forbearance = {
        id = 25771,
        duration = 120,
        max_stack = 1,
        shared = "player"
    },
    -- Strength increased by 44.  Stacks up to 5 times.
    formidable = {
        id = 71187,
        duration = 15,
        max_stack = 5
    },
    -- Stunned.
    hammer_of_justice = {
        id = 10308,
        duration = 6,
        max_stack = 1,
        copy = { 853, 5588, 5589, 10308 },
    },
    -- Immune to movement impairing effects.
    hand_of_freedom = {
        id = 1044,
        duration = function() return 6 + 2 * talent.guardians_favor.rank end,
        max_stack = 1,
    },
    -- Immune to physical attacks.  Cannot attack or use physical abilities.
    hand_of_protection = {
        id = 10278,
        duration = 10,
        max_stack = 1,
        copy = { 1022, 5599, 10278, 66009 },
    },
    -- Taunted.
    hand_of_reckoning = {
        id = 62124,
        duration = 3,
        max_stack = 1,
    },
    -- Transfers $s1% damage taken to the paladin.
    hand_of_sacrifice = {
        id = 6940,
        duration = 12,
        max_stack = 1,
    },
    -- Reduces total threat by $53055s1% each second.
    hand_of_salvation = {
        id = 1038,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Block chance increased by $s1%.  $s2 Holy damage dealt to attacker when blocked.  $n charges.
    holy_shield = {
        id = 20925,
        duration = 10,
        max_stack = 1,
        copy = { 20925, 20927, 20928, 27179, 48951, 48952 },
    },
    holy_vengeance = {
        id = 31803,
        duration = 15,
        max_stack = 5,
        copy = { 53742, 356110, "blood_corruption" }
    },
    -- Stunned.
    holy_wrath = {
        id = 2812,
        duration = 3,
        max_stack = 1,
        copy = { 2812, 10318, 27139, 48816, 48817 },
    },
    -- Reduces the cast time of your next Flash of Light by ${$54149m2/-1000}.1 sec or increase the critical chance of your next Holy Light by $s1%.
    infusion_of_light = {
        id = 54149,
        duration = 15,
        max_stack = 1,
    },
    -- Reduces melee attack speed.
    judgements_of_the_just = {
        id = 68055,
        duration = 20,
        max_stack = 1,
        copy = { 68055 },
    },

    -- Casting and melee speed increased by $s1%.
    judgements_of_the_pure = {
        id = 54153,
        duration = 60,
        max_stack = 1,
        copy = { 53655, 53656, 53657, 54152, 54153 },
    },
    judgement = {
        alias = { "judgement_of_justice", "judgement_of_light", "judgement_of_wisdom" },
        aliasMode = "first",
        aliasType = "debuff",
    },
    judgement_of_justice = {
        id = 20184,
        duration = 20,
        max_stack = 1,
    },
    judgement_of_light = {
        id = 20185,
        duration = 20,
        max_stack = 1,
    },
    judgement_of_wisdom = {
        id = 20186,
        duration = 20,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $s1%.
    lay_on_hands = {
        id = 20236,
        duration = 15,
        max_stack = 1,
        copy = { 20233, 20236 },
    },
    -- The paladin's heals on you also heal the Beacon of Light.
    lights_beacon = {
        id = 53651,
        duration = 2,
        max_stack = 1,
    },
    lights_grace = {
        id = 31834,
        duration = 15,
        max_stack = 1
    },
    -- Each weapon swing generates an additional attack.
    reckoning = {
        id = 20178,
        duration = 8,
        max_stack = 4,
    },
    -- Block chance increased by $s1%.  Lasts maximum of $n  blocks.
    redoubt = {
        id = 20132,
        duration = 10,
        max_stack = 5,
        copy = { 20132, 20131, 20128 },
    },
    -- Incapacitated.
    repentance = {
        id = 20066,
        duration = 60,
        max_stack = 1,
    },
    -- Increases the threat generated by your Holy spells by $s1%.
    righteous_fury = {
        id = 25780,
        duration = 3600,
        max_stack = 1,
    },
    righteous_vengeance = {
        id = 61840,
        duration = 8,
        max_stack = 1
    },
    -- Resistance to Disease, Magic and Poison increased by $s1%.
    sacred_cleansing = {
        id = 53659,
        duration = 10,
        max_stack = 1,
    },
    -- Absorbs damage and increases the casting paladin's chance to critically hit with Flash of Light by $s2%.
    sacred_shield = {
        id = 53601,
        duration = function() return 30 * ( 1 + 0.5 * ( buff.divine_sacrifice.up and talent.divine_guardian.rank or 0 ) ) end,
        max_stack = 1,
        no_ticks = true,
        friendly = true,
        dot = "buff",
        shared = "player"
    },
    -- Absorbs damage and increases the casting paladin's chance to critically hit with Flash of Light by 50%.
    sacred_shield_absorb = {
        id = 58597,
        duration = 6,
        max_stack = 1,
    },
    -- Melee attacks deal additional Holy damage.
    seal_of_command = {
        id = 20375,
        duration = 1800,
        max_stack = 1,
    },
    -- Melee attacks have a chance to stun for $20170d.
    seal_of_justice = {
        id = 20164,
        duration = 1800,
        max_stack = 1,
    },
    -- Melee attacks have a chance to heal you.
    seal_of_light = {
        id = 20165,
        duration = 1800,
        max_stack = 1,
    },
    -- Melee attacks cause an additional  ${$MWS*(0.022*$AP+0.044*$SPH)} Holy damage.
    seal_of_righteousness = {
        id = 21084,
        duration = 1800,
        max_stack = 1,
        copy = { 21084, 20154 },
    },
    -- Melee attacks cause Holy damage over $31803d.
    seal_of_vengeance = {
        id = 31801,
        duration = 1800,
        max_stack = 1,
        copy = { 348704, "seal_of_corruption" }
    },
    -- Melee attacks have a chance to restore mana.
    seal_of_wisdom = {
        id = 20166,
        duration = 1800,
        max_stack = 1,
    },
    seal = {
        alias = { "seal_of_command", "seal_of_justice", "seal_of_light", "seal_of_righteousness", "seal_of_vengeance", "seal_of_wisdom" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Detecting Undead.
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1,
    },
    -- Silenced.
    silenced_shield_of_the_templar = {
        id = 63529,
        duration = 3,
        max_stack = 1,
    },
    -- Stunned.
    stun = {
        id = 20170,
        duration = function() return 2 + 0.5 * talent.judgements_of_the_just.rank end,
        max_stack = 1,
    },
    -- Increases speed by $s2%.
    summon_charger = {
        id = 34767,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases speed by $s2%.
    summon_warhorse = {
        id = 34769,
        duration = 3600,
        max_stack = 1,
    },
    -- Your next Flash of Light or Exorcism spell is instant cast.
    the_art_of_war = {
        id = 59578,
        duration = 15,
        max_stack = 1,
    },
    -- Compelled to flee.
    turn_evil = {
        id = 10326,
        duration = 20,
        max_stack = 1,
    },
    vengeance = {
        id = 20053,
        duration = 3600,
        max_stack = 3,
        copy = { 20052, 20050 }
    },
    -- Attack power reduced by $s1.
    vindication = {
        id = 26017,
        duration = 10,
        max_stack = 1,
        shared = "target",
        copy = { 67, 26017 },
    },
    -- Increases speed by $s2%.
    warhorse = {
        id = 13819,
        duration = 3600,
        max_stack = 1,
    },
} )


-- Glyphs
spec:RegisterGlyphs( {
    [54930] = "avengers_shield",
    [54938] = "avenging_wrath",
    [63218] = "beacon_of_light",
    [57937] = "blessing_of_kings",
    [57958] = "blessing_of_might",
    [57979] = "blessing_of_wisdom",
    [54935] = "cleansing",
    [54928] = "consecration",
    [54927] = "crusader_strike",
    [63223] = "divine_plea",
    [63220] = "divine_storm",
    [54939] = "divinity",
    [54934] = "exorcism",
    [54936] = "flash_of_light",
    [63231] = "guardian_spirit",
    [54923] = "hammer_of_justice",
    [63219] = "hammer_of_the_righteous",
    [54926] = "hammer_of_wrath",
    [54937] = "holy_light",
    [63224] = "holy_shock",
    [56420] = "holy_wrath",
    [54922] = "judgement",
    [57955] = "lay_on_hands",
    [405004] = "reckoning",
    [54929] = "righteous_defense",
    [63225] = "salvation",
    [54925] = "seal_of_command",
    [54943] = "seal_of_light",
    [56414] = "seal_of_righteousness",
    [56416] = "seal_of_vengeance",
    [54940] = "seal_of_wisdom",
    [57947] = "sense_undead",
    [63222] = "shield_of_righteousness",
    [54924] = "spiritual_attunement",
    [57954] = "wise",
    [54931] = "turn_evil",
} )

local mod_blessed_hands = setfenv( function( base )
    return base * ( 1 - 0.15 * talent.blessed_hands.rank )
end, state )

local mod_purifying_power_cd = setfenv( function( base )
    return base * ( 1 - 0.1667 * talent.purifying_power.rank )
end, state )

local mod_purifying_power_cost = setfenv( function( base )
    return base * ( 1 - 0.05 * talent.purifying_power.rank )
end, state )

local mod_divine_illumination = setfenv( function( base )
    return base * ( buff.divine_illumination.up and 0.5 or 1 )
end, state )

local mod_benediction = setfenv( function( base )
    return base * ( 1 - 0.02 * talent.benediction.rank )
end, state )

local mod_art_of_war = setfenv( function( base )
    return base - 0.75 * ( buff.the_art_of_war.up and talent.the_art_of_war.rank or 0 )
end, state )


-- Abilities
spec:RegisterAbilities( {
    -- Causes your Concentration Aura to make all affected targets immune to Silence and Interrupt effects and improve the effect of all other auras by 100%.  Lasts 6 sec.
    aura_mastery = {
        id = 31821,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "aura_mastery",
        startsCombat = false,
        texture = 135872,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "aura_mastery" )
        end,
    },


    -- Hurls a holy shield at the enemy, dealing 477 to 573 Holy damage, Dazing them and then jumping to additional nearby enemies.  Affects 3 total targets.  Lasts 10 sec.
    avengers_shield = {
        id = 31935,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.26 ) ) end,
        spendType = "mana",

        talent = "avengers_shield",
        startsCombat = true,
        texture = 135874,

        handler = function ()
            applyDebuff( "target", "avengers_shield" )
            if talent.shield_of_the_templar.rank == 3 then applyDebuff( "target", "silenced_shield_of_the_templar" ); interrupt() end
        end,

        copy = { 31935, 32699, 32700, 48826, 48827 },
    },


    -- Increases all damage and healing caused by 20% for 20 sec.  Cannot be used within 30 sec of being the target of Divine Shield, Divine Protection, or Hand of Protection, or of using Lay on Hands on oneself.
    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.sanctified_wrath.rank end,
        gcd = "off",

        spend = function() return mod_benediction( mod_divine_illumination( 0.08 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135875,

        toggle = "cooldowns",

        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "avenging_wrath" )
        end,
    },


    -- The target becomes a Beacon of Light to all members of your party or raid within a 60 yard radius.  Any heals you cast on party or raid members will also heal the Beacon for 100% of the amount healed.  Only one target can be the Beacon of Light at a time. Lasts 1 min.
    beacon_of_light = {
        id = 53563,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.35 ) ) end,
        spendType = "mana",

        talent = "beacon_of_light",
        startsCombat = false,
        texture = 236247,

        handler = function ()
            applyBuff( "beacon_of_light" )
        end,
    },


    -- Places a Blessing on the friendly target, increasing total stats by 10% for 10 min.  Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_kings = {
        id = 20217,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( glyph.blessing_of_kings.enabled and 0.03 or 0.06 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135995,

        handler = function ()
            removeBuff( "blessing" )
            applyBuff( "blessing_of_kings" )
        end,
    },


    -- Places a Blessing on the friendly target, increasing attack power by 20 for 10 min.  Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_might = {
        id = 19740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.05 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135906,

        handler = function ()
            removeBuff( "blessing" )
            applyBuff( "blessing_of_might" )
        end,

        copy = { 19834, 19835, 19836, 19837, 19838, 25291, 27140, 48931, 48932 },
    },


    -- Places a Blessing on the friendly target, reducing damage taken from all sources by 3% for 10 min and increasing strength and stamina by 10%.  In addition, when the target blocks, parries, or dodges a melee attack the target will gain 2% of maximum displayed mana.  Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_sanctuary = {
        id = 20911,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.07 ) ) end,
        spendType = "mana",

        talent = "blessing_of_sanctuary",
        startsCombat = false,
        texture = 136051,

        handler = function ()
            removeBuff( "blessing" )
            applyBuff( "blessing_of_sanctuary" )
        end,
    },


    -- Places a Blessing on the friendly target, restoring 10 mana every 5 seconds for 10 min.  Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_wisdom = {
        id = 19742,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.05 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135970,

        handler = function ()
            removeBuff( "blessing" )
            applyBuff( "blessing_of_wisdom" )
        end,

        copy = { 19850, 19852, 19853, 19854, 25290, 27142, 48935, 48936 },
    },


    -- Cleanses a friendly target, removing 1 poison effect, 1 disease effect, and 1 magic effect.
    cleanse = {
        id = 4987,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( mod_purifying_power_cost( 0.06 ) ) * ( glyph.cleansing.enabled and 0.8 or 1 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135953,

        buff = function()
            if buff.dispellable_poison.up then return "dispellable_poison" end
            if buff.dispellable_disease.up then return "dispellable_disease" end
            return "dispellable_magic"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_disease" )
            removeBuff( "dispellable_magic" )
        end,
    },


    -- All party or raid members within 40 yards lose 35% less casting or channeling time when damaged.  Players may only have one Aura on them per Paladin at any one time.
    concentration_aura = {
        id = 19746,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135933,

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "concentration_aura" )
        end,
    },


    -- Consecrates the land beneath the Paladin, doing 239 Holy damage over 8 sec to enemies who enter the area.
    consecration = {
        id = 26573,
        cast = 0,
        cooldown = function() return glyph.consecration.enabled and 10 or 8 end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( mod_purifying_power_cost( 0.22 ) ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135926,

        handler = function ()
            applyBuff( "active_consecration" )
            applyDebuff( "target", "consecration" )
        end,

        copy = { 20116, 20922, 20923, 20924, 27173, 48818, 48819 },
    },


    -- Increases the mounted speed by 20% for all party and raid members within 40 yards.  Players may only have one Aura on them per Paladin at any one time.  This does not stack with other movement speed increasing effects.
    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135890,

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "crusader_aura" )
        end,
    },


    -- An instant strike that causes 75% weapon damage.
    crusader_strike = {
        id = 35395,
        cast = 0,
        cooldown = 4,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.05 ) ) * ( glyph.crusader_strike.enabled and 0.8 or 1 ) end,
        spendType = "mana",

        talent = "crusader_strike",
        startsCombat = true,
        texture = 135891,

        handler = function ()
            if set_bonus.libram_of_three_truths then
                applyBuff("formidable")
            end
        end,
    },


    -- Gives 1205 additional armor to party and raid members within 40 yards.  Players may only have one Aura on them per Paladin at any one time.
    devotion_aura = {
        id = 48942,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135893,

        nobuff = "devotion_aura",

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "devotion_aura" )
        end,
    },


    -- When activated, gives your next Flash of Light, Holy Light, or Holy Shock spell a 100% critical effect chance.
    divine_favor = {
        id = 20216,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = function() return mod_benediction( mod_divine_illumination( 0.03 ) ) end,
        spendType = "mana",

        talent = "divine_favor",
        startsCombat = false,
        texture = 135915,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_favor" )
        end,
    },


    -- Reduces the mana cost of all spells by 50% for 15 sec.
    divine_illumination = {
        id = 31842,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "divine_illumination",
        startsCombat = false,
        texture = 135895,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_illumination" )
        end,
    },


    -- The paladin sacrifices herself to remove the targeted party member from harm's way.  Enemies will stop attacking the protected party member, who will be immune to all harmful attacks but will not be able to take any action for 3 min.
    divine_intervention = {
        id = 19752,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        startsCombat = false,
        texture = 136106,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "target", "divine_intervention" )
            health.current = 0
        end,
    },


    -- You gain 25% of your total mana over 15 sec, but the amount healed by your Flash of Light, Holy Light, and Holy Shock spells is reduced by 50%.
    divine_plea = {
        id = 54428,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        startsCombat = false,
        texture = 237537,
        nobuff = "divine_plea",

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_plea" )
        end,
    },


    -- Reduces all damage taken by 50% for 12 sec.  Once protected, the target cannot be targeted by Divine Shield, Divine Protection, or Hand of Protection again for 2 min.  Cannot be used within 30 sec of using Avenging Wrath.
    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.sacred_duty.rank end,
        gcd = "off",

        spend = function() return mod_benediction( mod_divine_illumination( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135954,

        toggle = "defensives",

        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "divine_protection" )
            applyDebuff( "player", "forbearance" )
        end,
    },


    -- 30% of all damage taken by party members within 30 yards is redirected to the Paladin (up to a maximum of 40% of the Paladin's health times the number of party members).  Damage which reduces the Paladin below 20% health will break the effect.  Lasts 10 sec.
    divine_sacrifice = {
        id = 64205,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "divine_sacrifice",
        startsCombat = false,
        texture = 253400,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_sacrifice" )
        end,
    },


    -- Protects the paladin from all damage and spells for 12 sec, but reduces all damage you deal by 50%.  Once protected, the target cannot be targeted by Divine Shield, Divine Protection, or Hand of Protection again for 2 min.  Cannot be used within 30 sec. of using Avenging Wrath.
    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function() return 300 - 30 * talent.sacred_duty.rank end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135896,

        toggle = "defensives",

        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "divine_shield" )
            applyDebuff( "player", "forbearance" )
        end,
    },


    -- An instant weapon attack that causes 110% of weapon damage to up to 4 enemies within 8 yards.  The Divine Storm heals up to 3 party or raid members totaling 25% of the damage caused.
    divine_storm = {
        id = 53385,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.12 ) ) end,
        spendType = "mana",

        talent = "divine_storm",
        startsCombat = true,
        texture = 236250,

        handler = function ()
        end,
    },


    -- Causes 180 to 194 Holy damage to an enemy target.  If the target is Undead or Demon, it will always critically hit.
    exorcism = {
        id = 879,
        cast = function() return mod_art_of_war( 1.5 ) end,
        cooldown = function() return mod_benediction( mod_purifying_power_cd( 15 ) ) end,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135903,

        handler = function ()
            removeBuff("the_art_of_war")
        end,

        copy = { 5614, 5615, 10312, 10313, 10314, 27138, 48800, 48801 },
    },


    -- Gives 130 additional Fire resistance to all party and raid members within 40 yards.  Players may only have one Aura on them per Paladin at any one time.
    fire_resistance_aura = {
        id = 48947,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135824,

        nobuff = "fire_resistance_aura",

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "fire_resistance_aura" )
        end,
    },


    -- Heals a friendly target for 86 to 98.
    flash_of_light = {
        id = 19750,
        cast = function() return mod_art_of_war( 1.5 ) - 0.75 * ( buff.infusion_of_light.up and talent.infusion_of_light.rank or 0 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_divine_illumination( 0.07 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "divine_favor" )
            removeBuff( "infusion_of_light" )
            removeBuff( "the_art_of_war" )
        end,

        copy = { 19939, 19940, 19941, 19942, 19943, 27137, 48784, 48785 },
    },


    -- Gives 130 additional Frost resistance to all party and raid members within 40 yards.  Players may only have one Aura on them per Paladin at any one time.
    frost_resistance_aura = {
        id = 48945,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135865,

        nobuff = "frost_resistance_aura",

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "frost_resistance_aura" )
        end,
    },


    -- Gives all members of the raid or group that share the same class with the target the Greater Blessing of Kings, increasing total stats by 10% for 30 min.  Players may only have one Blessing on them per Paladin at any one time.
    greater_blessing_of_kings = {
        id = 25898,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( glyph.blessing_of_kings.enabled and 0.06 or 0.12 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135993,

        item = 21177,
        bagItem = true,

        handler = function ()
            removeBuff( "my_greater_blessing" )
            applyBuff( "greater_blessing_of_kings" )
        end,
    },


    -- Gives all members of the raid or group that share the same class with the target the Greater Blessing of Might, increasing attack power by 185 for 30 min.  Players may only have one Blessing on them per Paladin at any one time.
    greater_blessing_of_might = {
        id = 25782,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.1 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135908,

        item = 21177,
        bagItem = true,

        handler = function ()
            removeBuff( "my_greater_blessing" )
            applyBuff( "greater_blessing_of_might" )
        end,

        copy = { 25916, 27141, 48933, 48934 },
    },


    -- Gives all members of the raid or group that share the same class with the target the Greater Blessing of Wisdom, restoring 30 mana every 5 seconds for 30 min.  Players may only have one Blessing on them per Paladin at any one time.
    greater_blessing_of_wisdom = {
        id = 25894,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.11 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135912,

        item = 21177,
        bagItem = true,

        handler = function ()
            removeBuff( "my_greater_blessing" )
            applyBuff( "greater_blesisng_of_wisdom" )
        end,

        copy = { 25918, 27143, 48937, 48938 },
    },


    -- Stuns the target for 3 sec and interrupts non-player spellcasting for 3 sec.
    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.improved_hammer_of_justice.rank - 5 * talent.judgements_of_the_just.rank end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135963,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "hammer_of_justice" )
        end,

        copy = { 5588, 5589, 10308 },
    },


    -- Hammer the current target and up to 2 additional nearby targets, causing 4 times your main hand damage per second as Holy damage.
    hammer_of_the_righteous = {
        id = 53595,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.06 ) ) end,
        spendType = "mana",

        talent = "hammer_of_the_righteous",
        startsCombat = true,
        texture = 236253,
        clash = 0.4,

        handler = function ()
        end,
    },


    -- Hurls a hammer that strikes an enemy for 441 to 477 Holy damage.  Only usable on enemies that have 20% or less health.
    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        cooldown = function() return glyph.avenging_wrath.enabled and buff.avenging_wrath.up and 3 or 6 end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( glyph.hammer_of_wrath.enabled and 0 or 0.12 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 132326,

        usable = function() return target.health.pct < 20 end,

        handler = function ()
        end,

        copy = { 24274, 24239, 27180, 48805, 48806 },
    },


    -- Places a Hand on the friendly target, granting immunity to movement impairing effects for 6 sec.  Players may only have one Hand on them per Paladin at any one time.
    hand_of_freedom = {
        id = 1044,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( mod_blessed_hands( 0.06 ) ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135968,

        handler = function ()
            applyBuff( "hand_of_freedom" )
        end,
    },


    -- A targeted party or raid member is protected from all physical attacks for 6 sec, but during that time they cannot attack or use physical abilities.  Players may only have one Hand on them per Paladin at any one time.  Once protected, the target cannot be targeted by Divine Shield, Divine Protection, or Hand of Protection again for 2 min.  Cannot be targeted on players who have used Avenging Wrath within the last 30 sec.
    hand_of_protection = {
        id = 10278,
        cast = 0,
        cooldown = function() return 300 - 60 * talent.guardians_favor.rank end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.06 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135964,

        toggle = "defensives",

        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "hand_of_protection" )
            applyDebuff( "forbearance" )
        end,

        copy = { 1022, 5599 },
    },


    -- Taunts the target to attack you.  If the target is tauntable and not currently targeting you, causes 262 Holy damage.
    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        spend = function() return mod_benediction( mod_divine_illumination( 0.03 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135984,

        handler = function ()
            applyDebuff( "target", "hand_of_reckoning" )
        end,
    },


    -- Places a Hand on the party or raid member, transfering 30% damage taken to the caster.  Lasts 12 sec or until the caster has transfered 100% of their maximum health.  Players may only have one Hand on them per Paladin at any one time.
    hand_of_sacrifice = {
        id = 6940,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( mod_blessed_hands( 0.06 ) ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135966,

        toggle = "defensives",

        handler = function ()
            applyBuff( "hand_of_sacrifice" )
        end,
    },


    -- Places a Hand on the party or raid member, reducing their total threat by 2% every 1 sec. for 10 sec.  Players may only have one Hand on them per Paladin at any one time.
    hand_of_salvation = {
        id = 1038,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( mod_blessed_hands( 0.06 ) ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135967,

        toggle = "defensives",

        handler = function ()
            applyBuff( "hand_of_salvation" )
        end,
    },


    -- Heals a friendly target for 53 to 64.
    holy_light = {
        id = 635,
        cast = function() return 2.5 - ( 0.5 * buff.lights_grace.stack ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_divine_illumination( 0.29 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135920,

        handler = function ()
            removeBuff( "divine_favor" )
            removeBuff( "infusion_of_light" )
            if talent.lights_grace.rank == 3 then applyBuff( "lights_grace" ) end
        end,

        copy = { 639, 647, 1026, 1042, 3472, 10328, 10329, 25292, 27135, 27136, 48781, 48782 },
    },


    -- Increases chance to block by 30% for 10 sec and deals 79 Holy damage for each attack blocked while active.  Each block expends a charge.  8 charges.
    holy_shield = {
        id = 20925,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.1 ) ) end,
        spendType = "mana",

        talent = "holy_shield",
        startsCombat = false,
        texture = 135880,

        handler = function ()
            applyBuff( "holy_shield" )
        end,

        copy = { 20925, 20928, 20927, 27179, 48951, 48952 },
    },


    -- Blasts the target with Holy energy, causing 314 to 340 Holy damage to an enemy, or 481 to 519 healing to an ally.
    holy_shock = {
        id = 20473,
        cast = 0,
        cooldown = function() return glyph.holy_shock.enabled and 5 or 6 end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.18 ) ) end,
        spendType = "mana",

        talent = "holy_shock",
        startsCombat = true,
        texture = 135972,

        handler = function ()
            removeBuff( "divine_favor" )
        end,
    },


    -- Sends bolts of holy power in all directions, causing 442 to 514 Holy damage and stunning all Undead and Demon targets within 10 yds for 3 sec.
    holy_wrath = {
        id = 2812,
        cast = 0,
        cooldown = function() return mod_purifying_power_cd( glyph.holy_wrath.enabled and 15 or 30 ) end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.2 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135902,

        handler = function ()
            if target.is_boss and ( target.is_undead or target.is_demon ) then applyDebuff( "target", "holy_wrath" ) end
        end,

        copy = { 10318, 27139, 48816, 48817 },
    },


    -- Unleashes the energy of a Seal spell to judge an enemy for 20 sec, preventing them from fleeing and limiting their movement speed.  Refer to individual Seals for additional Judgement effect.  Only one Judgement per Paladin can be active at any one time.
    judgement_of_justice = {
        id = 53407,
        cast = 0,
        cooldown = function() return 10 - talent.improved_judgements.rank - (set_bonus.tier7ret_2pc == 1 and 1 or 0) end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.05 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 236258,

        handler = function ()
            if talent.judgements_of_the_pure.enabled then applyBuff( "judgements_of_the_pure" ) end
            if talent.judgements_of_the_just.enabled then applyDebuff( "target", "judgements_of_the_just" ) end
            if talent.judgements_of_the_wise.rank == 3 then gain( 0.25 * mana.modmax, "mana" ) end
            if glyph.seal_of_command.enabled and buff.seal_of_command.up then gain( 0.08 * mana.modmax, "mana" ) end
            removeDebuff( "target", "judgement" )
            applyDebuff( "target", "judgement_of_justice" )
            setCooldown( "judgement_of_light", action.judgement_of_light.cooldown )
            setCooldown( "judgement_of_wisdom", action.judgement_of_wisdom.cooldown )
        end,
    },


    -- Unleashes the energy of a Seal spell to judge an enemy for 20 sec, granting attacks made against the judged enemy a chance of healing the attacker for 2% of their maximum health.  Refer to individual Seals for additional Judgement effect.  Only one Judgement per Paladin can be active at any one time.
    judgement_of_light = {
        id = 20271,
        cast = 0,
        cooldown = function() return 10 - talent.improved_judgements.rank - (set_bonus.tier7ret_2pc == 1 and 1 or 0) end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.05 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
            if talent.judgements_of_the_pure.enabled then applyBuff( "judgements_of_the_pure" ) end
            if talent.judgements_of_the_just.enabled then applyDebuff( "target", "judgements_of_the_just" ) end
            if talent.judgements_of_the_wise.rank == 3 then gain( 0.25 * mana.modmax, "mana" ) end
            if glyph.seal_of_command.enabled and buff.seal_of_command.up then gain( 0.08 * mana.modmax, "mana" ) end
            removeDebuff( "target", "judgement" )
            applyDebuff( "target", "judgement_of_light" )
            setCooldown( "judgement_of_justice", action.judgement_of_justice.cooldown )
            setCooldown( "judgement_of_wisdom", action.judgement_of_wisdom.cooldown )
        end,
    },


    -- Unleashes the energy of a Seal spell to judge an enemy for 20 sec, giving each attack a chance to restore 2% of the attacker's base mana.  Refer to individual Seals for additional Judgement effect.  Only one Judgement per Paladin can be active at any one time.
    judgement_of_wisdom = {
        id = 53408,
        cast = 0,
        cooldown = function() return 10 - talent.improved_judgements.rank - (set_bonus.tier7ret_2pc == 1 and 1 or 0) end,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.05 ) ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 236255,

        handler = function ()
            if talent.judgements_of_the_pure.enabled then applyBuff( "judgements_of_the_pure" ) end
            if talent.judgements_of_the_just.enabled then applyDebuff( "target", "judgements_of_the_just" ) end
            if talent.judgements_of_the_wise.rank == 3 then gain( 0.25 * mana.modmax, "mana" ) end
            if glyph.seal_of_command.enabled and buff.seal_of_command.up then gain( 0.08 * mana.modmax, "mana" ) end
            removeDebuff( "target", "judgement" )
            applyDebuff( "target", "judgement_of_wisdom" )
            setCooldown( "judgement_of_justice", action.judgement_of_justice.cooldown )
            setCooldown( "judgement_of_light", action.judgement_of_light.cooldown )
        end,
    },


    -- Heals a friendly target for an amount equal to the Paladin's maximum health and restores 1950 of their mana.  If used on self, the Paladin cannot be targeted by Divine Shield, Divine Protection, Hand of Protection, or self-targeted Lay on Hands again for 2 min.  Also cannot be used on self within 30 sec of using Avenging Wrath.
    lay_on_hands = {
        id = 48788,
        cast = 0,
        cooldown = function() return mod_benediction( ( glyph.lay_on_hands.enabled and 900 or 1200 ) - ( 120 * talent.improved_lay_on_hands.rank ) ) end,
        gcd = "spell",

        startsCombat = true,
        texture = 135928,

        toggle = "defensives",

        handler = function ()
            gain( 1950, "mana" )
            if glyph.divinity.enabled then
                gain( 3900, "mana" )
            end
            if talent.improved_lay_on_hands.enabled then applyBuff( "lay_on_hands" ) end
            applyDebuff( "player", "forbearance" )
        end,
    },


    -- Purifies the friendly target, removing 1 disease effect and 1 poison effect.
    purify = {
        id = 1152,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( mod_purifying_power_cost( 0.06 ) ) ) * ( glyph.cleansing.enabled and 0.8 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

        buff = function() return buff.dispellable_disease.up and "dispellable_disease" or "dispellable_poison" end,

        handler = function ()
            removeBuff( "dispellable_disease" )
            removeBuff( "dispellable_poison" )
        end,
    },


    -- Brings a dead player back to life with 65 health and 120 mana.  Cannot be cast when in combat.
    redemption = {
        id = 7328,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_divine_illumination( 0.64 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,

        copy = { 10322, 10324, 20772, 20773, 48949, 48950 },
    },


    -- Puts the enemy target in a state of meditation, incapacitating them for up to 1 min, and removing the effect of Righteous Vengeance.  Any damage caused will awaken the target.  Usable against Demons, Dragonkin, Giants, Humanoids and Undead.
    repentance = {
        id = 20066,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.09 ) ) end,
        spendType = "mana",

        talent = "repentance",
        startsCombat = false,
        texture = 135942,

        toggle = "defensives",

        usable = function() return not target.is_boss, "not usable against bosses" end,

        handler = function ()
            applyDebuff( "target", "repentance" )
            removeDebuff( "target", "righteous_vengeance" )
        end,
    },


    -- Causes 112 Holy damage to any enemy that strikes a party or raid member within 40 yards.  Players may only have one Aura on them per Paladin at any one time.
    retribution_aura = {
        id = 54043,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135873,

        nobuff = "retribution_aura",

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "retribution_aura" )
        end,
    },


    -- Come to the defense of a friendly target, commanding up to 3 enemies attacking the target to attack the Paladin instead.
    righteous_defense = {
        id = 31789,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 135068,

        handler = function ()
        end,
    },


    -- Increases the threat generated by your Holy spells by 80%.  Lasts until cancelled.
    righteous_fury = {
        id = 25780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135962,

        nobuff = "righteous_fury",

        handler = function ()
            applyBuff( "righteous_fury" )
        end,
    },


    -- Each time the target takes damage they gain a Sacred Shield, absorbing 500 damage and increasing the paladin's chance to critically hit with Flash of Light by 50% for up to 6 sec.  They cannot gain this effect more than once every 6 sec.  Lasts 30 sec.  This spell cannot be on more than one target at any one time.
    sacred_shield = {
        id = 53601,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.12 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 236249,
        nobuff = "sacred_shield",

        handler = function ()
            applyBuff( "sacred_shield" )
        end,
    },


    -- All melee attacks deal 27 to 27 additional Holy damage.  When used with attacks or abilities that strike a single target, this additional Holy damage will strike up to 2 additional targets.  Lasts 30 min.    Unleashing this Seal's energy will judge an enemy, instantly causing 56 to 56 Holy damage.
    seal_of_command = {
        id = 20375,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) ) end,
        spendType = "mana",

        talent = "seal_of_command",
        startsCombat = false,
        texture = 132347,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_command" )
        end,
    },


    -- Fills the Paladin with the spirit of justice for 30 min, giving each melee attack a chance to stun for 2 sec.  Only one Seal can be active on the Paladin at any one time.    Unleashing this Seal's energy will deal 85 Holy damage to an enemy.
    seal_of_justice = {
        id = 20164,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135971,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_justice" )
        end,
    },


    -- Fills the Paladin with divine light for 30 min, giving each melee attack a chance to heal the Paladin for 78.  Only one Seal can be active on the Paladin at any one time.    Unleashing this Seal's energy will deal 85 Holy damage to an enemy.
    seal_of_light = {
        id = 20165,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135917,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_light" )
        end,
    },


    -- Fills the Paladin with holy spirit for 30 min, granting each melee attack 23 additional Holy damage.  Only one Seal can be active on the Paladin at any one time.    Unleashing this Seal's energy will cause 105 Holy damage to an enemy.
    seal_of_righteousness = {
        id = 21084,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 132325,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_righteousness" )
        end,
    },


    -- Fills the Paladin with holy power, causing attacks to apply Holy Vengeance, which deals [(0.013 * Spell power + 0.025 * Attack power) * 5] additional Holy damage over 15 sec.  Holy Vengeance can stack up to 5 times.  Each of the Paladin's attacks also deals up to 33% weapon damage as additional Holy damage, based on the number of stacks.  Only one Seal can be active on the Paladin at any one time.  Lasts 30 min.  Unleashing this Seal's energy will deal (1 + 0.22 * Spell power + 0.14 * Attack power) Holy damage to an enemy, increased by 10% for each application of Holy Vengeance on the target.
    seal_of_vengeance = {
        id = 31801,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135969,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_vengeance" )
        end,
    },

    seal_of_corruption = {
        id = 348704,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135969,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_corruption" )
        end,
    },


    -- Fills the Paladin with divine wisdom for 30 min, giving each melee attack a chance to restore 4% of the paladin's maximum mana.  Only one Seal can be active on the Paladin at any one time.    Unleashing this Seal's energy will deal 85 Holy damage to an enemy.
    seal_of_wisdom = {
        id = 20166,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.14 ) * ( glyph.wise.enabled and 0.5 or 1 ) ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135960,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_wisdom" )
        end,
    },


    -- Shows the location of all nearby undead on the minimap until cancelled.   Only one form of tracking can be active at a time.
    sense_undead = {
        id = 5502,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135974,

        handler = function ()
            if buff.sense_undead.up then removeBuff( "sense_undead" )
            else applyBuff( "sense_undead" ) end
        end,
    },


    -- Gives 130 additional Shadow resistance to all party and raid members within 40 yards.  Players may only have one Aura on them per Paladin at any one time.
    shadow_resistance_aura = {
        id = 48943,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136192,

        nobuff = "shadow_resistance_aura",

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "shadow_resistance_aura" )
        end,
    },


    -- Slam the target with your shield, causing Holy damage based on your block value plus an additional 390.
    shield_of_righteousness = {
        id = 53600,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return mod_benediction( mod_divine_illumination( 0.06 ) ) * ( glyph.shield_of_righteousness.enabled and 0.2 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 236265,
        clash = 0.4,

        equipped = "shield",

        handler = function ()
        end,

        copy = { 61411 },
    },


    -- The targeted undead or demon enemy will be compelled to flee for up to 20 sec.  Damage caused may interrupt the effect.  Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = function() return glyph.turn_evil.enabled and 0 or 1.5 end,
        cooldown = function() return glyph.turn_evil.enabled and 8 or 0 end,
        gcd = "spell",

        spend = function() return mod_divine_illumination( 0.09 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135983,

        usable = function() return target.is_undead or target.is_demon, "target must be undead or demon" end,

        handler = function ()
            applyDebuff( "target", "turn_evil" )
        end,
    },
} )

spec:RegisterStateTable("assigned_aura", setmetatable( {}, {
    __index = function( t, k )
        return settings.assigned_aura == k
    end
}))

spec:RegisterStateTable("assigned_blessing", setmetatable( {}, {
    __index = function( t, k )
        return settings.assigned_blessing == k
    end
}))

spec:RegisterStateExpr("ttd", function()
    if is_training_dummy then
        return Hekili.Version:match( "^Dev" ) and settings.dummy_ttd or 300
    end
    
    return target.time_to_die
end)

spec:RegisterStateExpr("next_primary_at", function()
    return min(cooldown.crusader_strike.remains, cooldown.divine_storm.remains, cooldown.judgement_of_light.remains)
end)

spec:RegisterStateExpr("should_hammer", function()
    local hammercd = cooldown.hammer_of_the_righteous.remains
    local shieldcd = cooldown.shield_of_righteousness.remains

    return (hammercd <settings.max_wait_for_six) 
    and (shieldcd < (settings.min_six_delay-settings.max_wait_for_six))
end)

spec:RegisterStateExpr("should_shield", function()
    local hammercd = cooldown.hammer_of_the_righteous.remains
    local shieldcd = cooldown.shield_of_righteousness.remains

    return (shieldcd <settings.max_wait_for_six) 
    and (hammercd < (settings.min_six_delay-settings.max_wait_for_six))
end)

spec:RegisterSetting("paladin_description", nil, {
    type = "description",
    name = "Adjust the settings below according to your playstyle preference. It is always recommended that you use a simulator "..
        "to determine the optimal values for these settings for your specific character."
})

spec:RegisterSetting("paladin_description_footer", nil, {
    type = "description",
    name = "\n\n"
})

spec:RegisterSetting("general_header", nil, {
    type = "header",
    name = "General"
})

spec:RegisterSetting("maintain_aura", true, {
    type = "toggle",
    name = "Maintain Aura",
    desc = "When enabled, selected aura will be recommended if it is down",
    width = "full",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.maintain_aura = val
    end
})

local auras = {}
spec:RegisterSetting( "assigned_aura", "retribution_aura", {
    type = "select",
    name = "Assigned Aura",
    desc = "Select the Aura that should be recommended by the addon.  It is referenced as |cff00ccff[Assigned Aura]|r in your priority.",
    width = "full",
    values = function()
        table.wipe( auras )

        auras.devotion_aura = class.abilityList.devotion_aura
        auras.retribution_aura = class.abilityList.retribution_aura
        auras.concentration_aura = class.abilityList.concentration_aura
        auras.shadow_resistance_aura = class.abilityList.shadow_resistance_aura
        auras.frost_resistance_aura = class.abilityList.frost_resistance_aura
        auras.fire_resistance_aura = class.abilityList.fire_resistance_aura
        auras.crusader_aura = class.abilityList.crusader_aura

        return auras
    end,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.assigned_aura = val
        class.abilities.assigned_aura = class.abilities[ val ]
    end,
} )

spec:RegisterSetting("maintain_blessing", true, {
    type = "toggle",
    name = "Maintain Aura",
    desc = "When enabled, selected blessing will be recommended if it is down. Disable this setting if your raid group uses another "..
        "blessing management tool such as PallyPower.",
    width = "full",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.maintain_blessing = val
    end
})

local blessings = {}
spec:RegisterSetting( "assigned_blessing", "blessing_of_kings", {
    type = "select",
    name = "Assigned Blessing",
    desc = "Select the Blessing that should be recommended by the addon.  It is referenced as |cff00ccff[Assigned Blessing]|r in your priority.",
    width = "full",
    values = function()
        table.wipe( blessings )

        blessings.blessing_of_sanctuary = class.abilityList.blessing_of_sanctuary
        blessings.blessing_of_might = class.abilityList.blessing_of_might
        blessings.blessing_of_kings = class.abilityList.blessing_of_kings
        blessings.blessing_of_wisdom = class.abilityList.blessing_of_wisdom

        return blessings
    end,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.assigned_blessing = val
        class.abilities.assigned_blessing = class.abilities[ val ]
    end,
} )

spec:RegisterSetting("holy_wrath_threshold", 2, {
    type = "range",
    name = "Holy Wrath Threshold",
    desc = "Select the minimum number of enemies before holy wrath will be prioritized higher",
    width = "full",
    min = 0,
    softMax = 10,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.holy_wrath_threshold = val
    end
})
spec:RegisterSetting("primary_slack", 0.5, {
    type = "range",
    name = "Primary Slack (s)",
    desc = "Amount of extra time in s to give main abilities to come off CD before using Exo or Cons",
    width = "full",
    min = 0,
    softMax = 2,
    step = 0.01,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.primary_slack = val
    end
})

spec:RegisterSetting("hor_macros", false, {
    type = "toggle",
    name = "Using HoR Macros",
    desc = "Enable when using Hand of Reckoning Macros (dont display HoR when using Glyph)",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.hor_macros = val
    end
})

spec:RegisterSetting("highroll", false, {
    type = "toggle",
    name = "T10-Highroll Playstyle",
    desc = "Enable to prioritize DS, for higher potential damage, but less damage on average",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.highroll = val
    end
})

spec:RegisterSetting("fol_on_aow", false, {
    type = "toggle",
    name = "Flash of Light on AoW",
    desc = "Enable to recommend Flash of Light on spare Art of War during Exo CDs",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.fol_on_aow = val
    end
})

spec:RegisterSetting("general_footer", nil, {
    type = "description",
    name = "\n\n\n"
})

spec:RegisterSetting("mana_regen_header", nil, {
    type = "header",
    name = "Mana Upkeep"
})

spec:RegisterSetting("mana_regen_description", nil, {
    type = "description",
    name = "Mana Upkeep settings will change mana regeneration related recommendations\n\n"
})

spec:RegisterSetting("judgement_of_wisdom_threshold", 70, {
    type = "range",
    name = "Judgement of Wisdom Threshold",
    desc = "Select the minimum mana percent at which judgement of wisdom will be recommended",
    width = "full",
    min = 0,
    max = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.judgement_of_wisdom_threshold = val
    end
})

spec:RegisterSetting("divine_plea_threshold", 75, {
    type = "range",
    name = "Divine Plea Threshold",
    desc = "Select the minimum mana percent at which divine plea will be recommended",
    width = "full",
    min = 0,
    max = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.divine_plea_threshold = val
    end
})

spec:RegisterSetting("mana_footer", nil, {
    type = "description",
    name = "\n\n\n"
})

spec:RegisterSetting("protection_header", nil, {
    type = "header",
    name = "Prot Settings"
})

spec:RegisterSetting("max_wait_for_six", 0.3, {
    type = "range",
    name = "Max Wait for Six",
    desc = "Max allowed delay to wait for 6s-Casts (SotR, HotR) CD in seconds.\n\n"..
        "Recommendation:\n - 0.3 seconds\n\n"..
        "Default: 0.3",
    width = "full",
    min = 0,
    softMax = 1,
    step = 0.01,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.max_wait_for_six = val
    end
})
spec:RegisterSetting("min_six_delay", 4, {
    type = "range",
    name = "Min Six Delay",
    desc = "Min allowed delay to wait between 6s-Casts (SotR, HotR) CD in seconds.\n\n"..
        "Recommendation:\n - 4 seconds\n\n"..
        "Default: 4",
    width = "full",
    min = 0,
    softMax = 6,
    step = 0.1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.min_six_delay = val
    end
})

spec:RegisterSetting("squeeze_hw_in_bl", true, {
    type = "toggle",
    name = "Use HolyWrath during BL",
    desc = "Enable to squeeze HW in open partial global after Consecration during bloodlust against Undead/Demon",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.squeeze_hw_in_bl = val
    end
})

if (Hekili.Version:match( "^Dev" )) then
    spec:RegisterSetting("pala_debug_header", nil, {
        type = "header",
        name = "Debug"
    })

    spec:RegisterSetting("pala_debug_description", nil, {
        type = "description",
        name = "Settings used for testing\n\n"
    })

    spec:RegisterSetting("dummy_ttd", 300, {
        type = "range",
        name = "Training Dummy Time To Die",
        desc = "Select the time to die to report when targeting a training dummy",
        width = "full",
        min = 0,
        softMax = 300,
        step = 1,
        set = function( _, val )
            Hekili.DB.profile.specs[ 2 ].settings.dummy_ttd = val
        end
    })


    spec:RegisterSetting("pala_debug_footer", nil, {
        type = "description",
        name = "\n\n"
    })
end


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    gcd = 21084,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    potion = "speed",

    package = "Retribution (LightClub)",
    usePackSelector = true
} )


--spec:RegisterPack( "Retribution (WoWSims)", 20230222.1, [[Hekili:1IvtVrokt4Fl5sRjAh5(JKjZ(UA65WE6DYHrRwVNTnTnTnBBmwaozAPi)BFl8NGBWjDNokkjwuq98qrrrvvW6G)jWpbjXb)CZQn3TAZMnERVF16vRd8LhlXb(LO4dOu4Jcef(7FJLCYUkjHvOKDmNHsu6qWQ4XG8mPSu8hlxMsKzv78Iz0LpZEwqOc4)Y8dl3LZ2TKIesmFjm8YsuokHuSKpQ4LCMeP(WlLf4VRIKl)rrWoRefqUehddcqtssWTZdlInOAD0F1ctDuVURJ2Z41r)F8bsojWpNiKIgJbEpQkxcF(ZgJdUaTlhNe8Nb(XCcWAckW)M6ibwkjfPcVmgpKII5mrD0I6O08JLzECC8bwbi3RB9nY(uDucEx1(9EsoIOehMurPh9QkRJE5L6iqVO0uoRo62aFuCRvodvKeY2hoOZa)kbggzFyACIIMs1(3fxBWtGr5EjSNlA4HsZpHdXfykbd0EBD06r8uZvH3t4IumQaovb9F37r)F3Q(bFdkS1uA)EL27LJuaRSnpZrYmDuHz(f9zwYA)VXmEqFgkdfquQyYK(68Bhtkahp6NgukMR4Fl9aL976iMb3A4GpjojefhJZXCKfs()CIpysqEGkIXfY6OVP5O9VvjPykmCd4ercJgkZ4yrglpzKawMMcX1R0zPXKYjPzYjeCTBNFGqH7yfvcpjbZxVkCtz8uFOeYtKcCOqY4TO72)e85Pmy2PoDDAeatR9OPDcXScboU12AC(OlOb57moDMC6nztFVtwcxDLiEkw6reHjyQkaI6g74GvfjyeCp)w77JTgHmYp2saBhGJsB40xUaxLoZFzogzdbnXnq8GtiM)M8jNYFv3whZReOeWAlG4WhWtT1g3Am00Kj6(UY5EO0g6ndhI4T3oq8MqVGOc8VKHLCcfXpgIKn70bZz)4IC4XWrsJ)fJhtenB9nRMZbFgp3lg9Po6BCFJ9JCF7(I9zC64Y5FJ7NDgi5Eg8AsriI98LCgBSfnc0ODjPxbXm4Ae8iNxVfaENNcpK3EX4HXDX(CKiBm0Q6h)s49BgDh61tTOdTHDOccj8BiQIJAJUieK0c1tmWiEAPo1mWiporYSzkCbqdoHQOpTEHta3ISztK4sGVpeZeKngUp)IRfOj4Nyw2UMd3NQY1c09eogYauaPPQsjBc2wL2Nl0vJcqkUYz4GvXZMR1fqcrgcUb6MfoK3NL2ztdy2a(9jN0tL(r96)qDx)GALJm5urZM33vIe02C5SrcAxSOUub)izHaS8YkiUQDMmkE(mnVsSPljyRuzib5My0pbPURMsxnMa18H3pkApy)bTKXLQs520MFN6bTM6g9QFe0ELekfmW3VcsjdYowOc5Z2tYX9iREqT7nGFB7YPXM)mz)2BQkxy)QWI5d5x)Onionc8zbYPl3bm6HBppe0xPDLBew9SuUXkTRCBXnplmSPahqzl845HLnnyhm7rbpl0SRc7WDsOo3i1p1fVHyPVoynH0E3G1OLxhSHOwVBah00RdAB8P3nITQP(XbabyoPVsFwRTsBx3G5f1Ll394svaWn9D4sNlN0Zjf6MDwArx9tD1IUDTT131tPxD1F3y1MT7rxsBhM0hzOJsMMsJ2kma)j9rYyr27uK(uS0lhLU1l8)BVT(d5uR5go)QaUALIRaZw7Emn(6vI24102pNtm5lUzU6GDBonenuFOcPpnPaZxEzAXL3oLfBNTlmwmeQcaDB0T2PL5mNM0PRbx6gtZUM4sv6J3xn6B1IyVe5fV9wbm7H)mNXxie67VRk3N3zYE3kmcBzwNF3TLpM2sCXnM4HMuBd(Vd]] )

spec:RegisterPack( "Retribution (LightClub)", 20231114.1, [[Hekili:vVrApoUT1FldcGHD6gn(yoYgmZeGMuGUlk2gu3pBjAjAB1rhguuE3byG(T3hj1bPmjLKp2MMSjWljFN8Dt7vZw9VxTmarXR(Y8PZxmB2S7CMnB6JZwSAj9T94vl3J8FfTf(qckg())lmLeUoNgMMu4n(FeUDh93IYxpHDW3IsrbmeMLMt8HdVJs3N9l3EBqyMFkjWz72BJyq4dq4hHYYc9xTCDEye9tjRwRJrEGXiz7X(WYa(cdcWItIZ8BXm)bkcfecFGKsrIL2Ksk8(74xdJcl8wJYWbfES1Rz7F63fCgae2pnogNeWbnB1YOWmAgxyct2gHHp9fUYcNGwhHdw9xxT0NesXKqetg2SXjdJICcs)AYQLiFgwayHLCt34EaNSfJsaDcLjiMqZyqLw4Dab)fythAym2LM6geIl8(XcVPoFSW7Nk8MpTWBsH3lfEc64Gy4hyt3Vsq0Do(PPrm(GFQrCCEdi)v8Ocd5KVVW793l8csPo7sJEtARmkC3ZPZDaQAKkvYXePfgfPyucYzpgmhsOfEpv4LHPua2mN)tEWwmOXPm(5RHzbPXU0DeCgWfbnetZXyu8ogf1EgUfMm3aN(EJ8hWoURttYZCIcxtqXmmW4cqXtYP7Y4kqUQdmMIdd4xm(P5LsZ9nmHpjpdfGjUzGr5R8B6h6bzPHyYSPe4VpFVFH3ZfEZ40SwpTdKhsAuudLccpeMGb6aCeJmpkRlAZgQkIFw(Ok4r9CF8eUqlr3(ims3fP02mkmBQn3akISftDcZCdWXmxwMjAZI5jbyuqL9n)6HUd7IicReeHBwdBLG)g1DpjmgrEZfr5gZ1mC16zrC7C44Qc3lCxN(zWw4DBB3e83sj(Hz8ROzMJDu5AYa7a21hI(G9j8Wq)VrkwOifY8dxsmh(6pn3dlCU38nH5yvd1U77RqnZr18IhSUoc8S7SfRrqJnPqS)exu6xpf3MJfOklxjp7keuLcYPs17qWXOWKmoQEOrk2aLbSRjSn7FHK7Bq5ruDPCRTkrrrUI)IlltTiFTROgLWKqADI2kiYZWUGgjoRvKUfYhAFAPbJ8j4Awg4PB24U1pGXvn3cqrseOafCaWo(4iCPNsFZ)CJCK(uIBmYNKkY6Sn6T97a9M)RPjW(oLWxLspalUajGALLmoipo(T605aErB3ssvnzqjbmDDnopsUSM0QDAWY762lxFtdjhMBn)4JgjvzWqCcooelmAKu6K8eJx((Gv4bCDUUEH96KU1LEH)g2pNc207GQg7hHlbrx2Z(aEzzMChG98QrxJS6cqAk(1fLtqIIIjH7fB)L0d441ycRCX5lAzYvEZvB5XUWOW)XreFlwX5Btyw1WkohrlRLXEceaYYWclkCEkfhPmqT3ZAjNNc5RSnBrzLLRcfCPiAa(qQgXvD5UcEmuIUjKGb))mWWJvJFlARDxRXeofwacWrTWdA32A0ItGjY2HG8tM5cd7BnSIn2aoDgZfxLvQw1P6dSOZVYGSHtoElR1NFHyIyrxu6yI4Ym12kH)cXfzGMNMdvDONtA2UZsSVeCtz3NAzLMot7Qaz(ycKZrU4HPs2D6MyGLAwVqTJrBYF9DAqh))2ej41Gp3rQHFBtMWuH4gB6FADzBwA8FhkogYgXixLCAo5WjkNDkFpixWCNtEXCq7l6iquMRH9rGyo0PvoYmTTeg8SKrn32N3ye0pyrMZKsXwAA3xRORQwhsmQXDfMs4SP4I3E8rMDZS0x7ynT2(0Vk1UAlDEtC6jw6UVHjvg0WP4AAqB8DG1BRFnxY3qhtY1HZ5O(AosfA5Ge0KpmDp31UbWkpl2NIYXCDK5(ZbgFXuXm8L0BsoLCew2xO8YAYP2nRuI(DqEwq3U3xyXnFQmruB3Ll7L9rFwvdWEsfusqN1cu)h7p9XKH)6hm9BJ9QIo45Au9NWxjzy2XQtS9IwxIL8Ew7lno9qvr19iZu5wYJ7zU5Csp0)K9p2ZSxk1p0oXBFRFyWI9zg(6o7dQ3CzjNP528(yUzPuLRs9awdWmO8v6mgVexxZC(zBdW3C0b7f0uNgTLNGupMYjBLDc(EMP9rZViJ5itxREye1MP9q6AIXsXqdSuoZ2VMBuAO2Vx4RQwffb6MdysgBRQVPgZDGSeGrjRmNSvl)u8(ucL9qfpuLJUWJ)1PWP4ZSHBNUjKvFYpu)D24xk8K)QC85Fq7xrdi3Fp(cLWHwD43fFgwKrTQXQx8zbBXm0lx6V88TThY9hc388n57hD8mJy7oY(eY1tIJhL9GiYXGBGmYZTEyuqgs9ixz(0dc5kqQh56ga9GOHoeyGu6MZ8WOLomONy6hN8GOMEuONCRBpZyZuQ6OJ6XqP7My8zdF2eJJLUjw94FpBcwJPUjQiM5ztrbAmyS0U9dg1oA2XpT4HPg8qBsTWGuoFWtDuNvzKYFx8c81ONftP1lU)bwNJpZ6qw(u1VYU8IIxvxEfdVA(hKEn6NNPaq7xUw9O8RJMrPv)o6Jm8g6JgBQ783F)g(7Mprr2vRSQ(6q5TWhz4DWFAUmQA9eWcTOOxBgAvR98LzDcAzN7hd7ZZgP)1S7eLmt0iCLPWNy3WqIAcSfuqIuma2DpGJkQiawQX9pWhaXZgv1JwmD6K3F)4XF0bjuKMsICud(pb92xkb)gx72GuH2wYpRCmfQEz8riCmmQD1Zazm8p6MBXpo15Jt(P5tN8IajMMtbOcgFm7)ma4KrJVX48iE)DtZI4L7MOHX1u43rbhg3VYeVDHoci3ybdZgMQGKFDdSY9UY9Lf9rp6glDqpQLVYCD4v1XTdUwZ2TgfWLI1L16V0xT(v)ADULRvTjtgBpBIEe20pb37PvRn1XdQBRzYrx0NM6dA)wh7u1jAT3)rnApACxTy)0VAT96jVOVX6tvoE8une6hf6c5rQvN1llLUk74cyLCgktrEI)MiVsdZuMOP7kYuZv0aMMKfNDa9gSF5UXVDUZ96OqROF2IQpfkCQPaSY3Y86Y1DI9wgQnNQ3PQg1lrYywMtGIN51qF542jTSLSsxXnVCxxsPL9p7CjnySprVB94JsbRn8WJMIxpurYUeDLzSHha9YXpNAS47QJfVSShKk5s0tYqJexdLUQ2nvZEFkz)cuyEnVDnciQh5TIhwFinT3M1XplQJA2L)tI6P71G9Eh6ZwOlt8Ah0Z82NGdRgKjh(PpUygcr1YX7I6vP1MBqX)VMC3cDCxpcQFv5jN71XvdpG61KjfblpIjv)50u6UjWxZV(N(AgQYMcBejpdgig)D(8YdRwY)f3(ptu(D6UAjcIFKswTCzoiZqyGm(JkT6)o]] )

spec:RegisterPack( "Protection 96", 20231129.1, [[Hekili:fNvBVTnos4FlblGRnAI8RXxtrCwS7xU2Gd5wuVa73SfTeTnVij6vKkEZbd9B)MHYwMuIu2j192p0AvYHZZdhoCMHtN1F2VpBAirsN90GEdg1ByVHE9V92b96pBQ81n0zt3qcEMSc(iHed)9VLYL0ajJNK7F3yC6xJ4KquncEwAaiYAPCJ4ZD7UIjxNTWlGh3DlFRGflGFLrp3DreFr3yIqst7cd3DdjIeYs6UPu3DHVi4hER4ZMUiJfj)AYSfwO6Wr9gaqVHgaddyZcdPfssfbM093kGj3)GYZ9xYtZ9)c9zweZl3)xjcAyUpoXEcN7hXxXcUgwdDjjqYtrbuR6UX3n(OQMnnIjKcLzG9xWppPSS0eYIiA4SFD20GugSFzKztb9WEHoNMqJzuaIhY97N73k3pGZJc5Bt8eRz0OW58LZtzRwlP8mrcvi8sPXewcSK7NK7lOsjlzLWlMLmhaDEinI8AU)h1NI8xZ3syY5aLrzkahP7AsCmnfHqUMEeMzs0m6I5Le0XQVKe0Hnaj4WttW)wTGs4Arkf87xqKn7kijr0ePhlgC9FHgEulZxML(Q3H1uIP58nFyDvUF2gLFL2MHLiH)mNKLsutrec2QeazCeW6itzlYqSudObC1zA8y4DaDapjamfPelGBzoa(rxu4tZeKq44ScYgddGE7Le0q6lClBxZHbqhFjbDjlf8wPciCfbmRvW26Saf(hxukKYfYg4G1Pbs8PljjeRjqKc3SWX8anU7DrdqAa)KvMu5WOEh(aJN8mUYJmP(uaj637hnlIXyn2zrXuilChA7cXcby6LzeiyNvMCCAKnVVGHVb2SLjc5X2PY(5qE4oY4ISLl9eusKwMOC)HJ7P54bZI67fAYkk64PuP7ODfQKeaLMmViTNzwoDvRlLsTQ4zLz04rVEysnSq5gRl3gEXVMI4oermjH4THMIbXv73YZG)tw4kAmm8rdiKnfUZburlTNfXuq(jDwziuuHZRodLyK1LKSOtKt(4rewjrHtHLk2QFGbj8HDAyZzLpdTpXQ2nChgQVXj4uOt4wid56khlJ0LmtqNdejwurOBp5PR68hxoF5Y5Rccrd4r)g4HcPqj4yO1GaAenLyrfU9pKK0vuP3AyNkx7Tjqw44oONY80UWcXDxuNKftHAZaBdSWFUuCxfPQlEht)rJcbTvQxHjUXCr)TX3C)BAOWvLT8kL58KLXVpu5jRMgLRJwrIzq2w13ZXxdv8MO5fVBmHLqTL88Cwlw2T6(RsjnE5f2GQBy7VtbvokObfUJh2vwUmp0OwZYv08nzYQvP8C)D7Y9dPkqHkuzj4fXWS44xb8ShA9uLoR0fueiSzNVjIsoqC4KBv0RBw7fYoo3ELuWdqc3XA1w1XySkpkTJqnHozn2VddDF3gA3vw3SEur)GWpAw3gRxE)zvz2cJJjhjACh6Q4aPchQ)UnlKSXIzpLPvkdv2HrQ)L5z(dk)GZlfBUFxLs64(CXD1Uak7JCZeqeOySVjOx4XbZscPKcFSc)xDIj(Zmk9)s)cCZ4pWOQhKPmQJXgVSKgy7n27t3w44waynhe932RU5PcBB41x5QzzC9gQR(hwzm9FlLX0uvU7neHCPzbHQAkAOoqvW1xa)tCwS7Ad73FWip4w2wsAsXRr(JF5Bp91N(NFo3p3)3xdPIyXB4PY9Dd7dyO5pGTj7pZyQMKj4XGqKmjpMiXbcwtG7acV8hvlFjpkIVvv2n(Wk4yBlnfgpt1doSnDsuSckN7JPdW7fYdYLWvydUy6shgIchsKKfeb9Z5pQskQfmfg5XVQyocZitaqYbwPm5AE6SPtZGd7KmbS5rLf(Vtm7N447W(8WxYIGCu)0pL7BRzJpItGwuV(99gChcFbIcVYEe9XjDnBSZ1SLtoVwd5qBv6wdQVRY20Y(JJB1CtGSdr9EY8MaP(YDaJEdyEBiOVs7k3OrlVjLBSs7k3wNuEtyytboGYwdtEByztd2bZEFrEtOzxf2HBr1MF4gPdI26m6UYPbt1JJVBWuA50Gv2gJVBal10PbTid03nIfQXHZs1hVIOvRhi3pCCphRxpr1X1ARzh3pXHo0k92Uafp41(CwszJ0qVuG7pVYaod9hv4SOLJqZeUV7cMgqSoPwML)8qFBR2XbGL1pXy9M9wqFMYEjOpyftjA9T3BGR16LaIOXsmFTDrYWkDi4(jd61QDXAoJ3zF)pVx0t)g7o37411AmSYJvVgFM6eSciKR)FLv3489(TUQ9z8o)wNXB87CYTo2EbLBlwSZVOM9M)LQGnvXHJZ9NcU8jH3mDdnkck1R9x4YV1fk9(BhvUhOfJtFdUIw2Qo6NM8LXgSB9(O7ULuHvoaaz1jTYxms0GP5hPLW1X6D1pwjy14BxtKFa)VoNUuQD8I3pkkCS8vDQCpn8w3QH2gwtBAb3vEiypz2TZv)yQTCT2DCKlMTEPvBNnDz3U22teyTvlDUS2I(10wLMmy7gtT14i)2vw6sY5GxJTd57B7lLHpmQLU9(H2NxM3UJQB5p(OFvi7k9Xy3UQ9WOtR2TD25IwTBSNfpG9ROtND7QCAmPXEuuNZ)iQfXMQJmRzDVi1kfB)UPwZgM0t1pHz)Vd]] )

spec:RegisterPack( "Holy Paladin (wowtbc.gg)", 20221002.1, [[Hekili:vA1YUTToq0pMceKG2kl5Mw3CrCw0vnErAbua6ozrjowIxtrkqsz3ayWV9ouQrMsrooDtc9WZCMhCMJDsuYJjXuIbsEyE485rHHZdIwm)MWRtInpvdjX1K8TKc8GGuH)97s(t20Fs4ektytVCVCVjlpOO4kh0N4sc1rPw2OYr4LgtT()MnRhgEYW3olNt06pw0WOGEwjY5hR7OCwsCwdJBUxKKnvM95imZ01qoAgPNrPqhsqNNe)yjtBtRvmPIzW809PmIgO2ujMTMsWM2Nk20FPiMsBABAeKeZzAJUTHaBinCdE8H2geiizCGM8TK4CKyqXijXKCdBhSMknbzajxkwl3SMZkkn20L20WoesbwqdVoX4Y9trBwZMnbAGWdOY9IJK4m5OypttLvoo(0j5WqufGjGI1drKJ18T20OqB6f20kIGeud4JJW0AFHxI()n0cOcVzyGU2fOjX0vpEjbI(ZVLoMMKRa6ADjd40X9Rbx6O8l(jazhikyII17DVEJc(cFKu2oMawZ48MkMG0zCa8Vob8Aoqgb7gFy1Yjikk0hsJgJQbQ0Jrfnr82q2jvJbo3hOB)a7gY8TJH9Voc41JBBUU3qL7neKnAbO1TSE95EbbbuXaC36oK02XQZfoC(xd5QU3axmo7uYlJXL9HHPxtHk3g9Hd(gBeuGGJtxnQ31nP4c7Gjj43svotxnSRIZZ1kixwLroQa8SlkWOyznUpSM0OgpOCM1A0SwJJUJwTF2S71yl(F9RVD)wPQFbUTM2bkTdsVAAs8EIs0gU47RQLkJtMCUnTJlBARCyGDLRFi3W4OC(7ENnD43aSYzcD6h5gzgOWZi92v2vDSOd67LVF5muZNviWvBxRBAiVOx8b2MLVSIpVZDv)P8U3FNxdLNDUCAT9LH(UouuUpy9Y3(yNqC15WOnNBJcVWxJ(2fHNKKUVSXpD8fohvhdUByvmur1)MjuqN4ANIPV5ofsFl9cIt4DR(NV9JYDdQTPfSMUf67OV0Jxp5V6l3fDXR7(rbKjD(Yrsshomwo6kF2ok5qAmLoD)(Fos7AAYFc]] )


spec:RegisterPackSelector( "retribution", "Retribution (LightClub)", "|T135873:0|t Retribution",
    "If you have spent more points in |T135873:0|t Retribution than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )

spec:RegisterPackSelector( "protection", "Protection 96", "|T135893:0|t Protection",
    "If you have spent more points in |T135893:0|t Protection than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "holy", "Holy Paladin (wowtbc.gg)", "|T135920:0|t Holy",
    "If you have spent more points in |T135920:0|t Holy than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )