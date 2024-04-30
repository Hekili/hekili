if UnitClassBase( 'player' ) ~= 'PALADIN' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 2 )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.HolyPower )


-- Idols
-- TODO: Update for Cataclysm
spec:RegisterGear( "libram_of_discord", 45510 )
spec:RegisterGear( "libram_of_fortitude", 42611, 42851, 42852, 42853, 42854 )
spec:RegisterGear( "libram_of_valiance", 47661 )
spec:RegisterGear( "libram_of_three_truths", 50455 )

-- Sets
-- TODO: Update for Cataclysm
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
    -- Holy

    holy_shock                      = { 20473, 1, 20473 },
    mediation                       = { 95859, 1, 95859 },
    walk_in_the_light               = { 85102, 1, 85102 },
    illuminated_healing             = { 76669, 1, 76669 },
    arbiter_of_the_light            = { 10113, 2, 20359, 20360 },
    protector_of_the_innocent       = { 12189, 3, 20138, 20139, 20140 },
    judgements_of_the_pure          = { 10127, 3, 53671, 53673, 54151 },
    clarity_of_purpose              = { 11213, 3, 85462, 85463, 85464 },
    last_word                       = { 10097, 2, 20234, 20235 },
    blazing_light                   = { 11780, 2, 20237, 20238 },
    denounce                        = { 10109, 2, 31825, 85510 },
    divine_favor                    = { 11202, 1, 31842 },
    infusion_of_light               = { 10129, 2, 53569, 53576 },
    daybreak                        = { 11771, 2, 88820, 88821 },
    enlightened_judgements          = { 10113, 2, 53556, 53557 },
    beacon_of_light                 = { 10133, 1, 53563 },
    speed_of_light                  = { 11215, 3, 85495, 85498, 85499 },
    sacred_cleansing                = { 10121, 1, 53551 },
    conviction                      = { 11779, 3, 20049, 20056, 20057 },
    aura_mastery                    = { 10115, 1, 31821 },
    paragon_of_virtue               = { 12151, 2, 93418, 93417 },
    tower_of_radiance               = { 11168, 3, 84800, 85511, 85512 },
    blessed_life                    = { 10117, 2, 31828, 31829 },
    light_of_dawn                   = { 11203, 1, 85222 },

    -- Protection

    avengers_shield                 = { 31935, 1, 31935 },
    vengeance                       = { 84839, 1, 84839 },
    judgements_of_the_wise          = { 31878, 1, 31878 },
    divine_bulwark                  = { 76671, 1, 76671 },
    divinity                        = { 12198, 3, 63646, 63647, 63648 },
    seals_of_the_pure               = { 10324, 2, 20224, 20225 },
    eternal_glory                   = { 12152, 2, 87163, 87164 },
    judgements_of_the_just          = { 10372, 2, 53695, 53696 },
    toughness                       = { 10332, 3, 20143, 20144, 20145 },
    improved_hammer_of_justice      = { 10336, 2, 20487, 20488 },
    hallowed_ground                 = { 10344, 2, 84631, 84633 },
    sanctuary                       = { 10346, 3, 20911, 84628, 84629 },
    hammer_of_the_righteous         = { 10374, 1, 53595 },
    wrath_of_the_lightbringer       = { 11159, 2, 84635, 84636 },
    reckoning                       = { 11161, 2, 20177, 20179 },
    shield_of_the_righteous         = { 11607, 1, 53600 },
    grand_crusader                  = { 11193, 2, 75806, 85043 },
    vindication                     = { 10680, 1, 26016, },
    holy_shield                     = { 10356, 1, 20925 },
    guarded_by_the_light            = { 11221, 2, 85639, 85646 },
    divine_guardian                 = { 10350, 1, 70940 },
    sacred_duty                     = { 10370, 2, 53709, 53710 },
    shield_of_the_templar           = { 10340, 3, 31848, 31849, 84854 },
    ardent_defender                 = { 10350, 1, 31850 },

    -- Retribution

    templars_verdict                = { 85256, 1, 85256 },
    sheath_of_light                 = { 53503, 1, 53503 },
    two_handed_weapon_specialization= { 20113, 1, 20113 },
    judgements_of_the_bold          = { 89901, 1, 89901 },
    hand_of_light                   = { 76672, 1, 76672 },
    eye_for_an_eye                  = { 10647, 2, 9799, 25988 },
    crusade                         = { 10651, 3, 31866, 31867, 31868 },
    improved_judgement              = { 11612, 2, 87174, 87175 },
    guardians_favor                 = { 12153, 2, 20174, 20175 },
    rule_of_law                     = { 11269, 3, 85457, 85458, 87461 },
    pursuit_of_justice              = { 11611, 2, 26022, 26023 },
    communion                       = { 10665, 1, 31876 },
    the_art_of_war                  = { 10661, 3, 53486, 53488, 87138 },
    long_arm_of_the_law             = { 11610, 2, 87168, 87172 },
    divine_storm                    = { 11204, 1, 53385 },
    sacred_shield                   = { 11207, 1, 85285 },
    sanctity_of_battle              = { 11372, 1, 25956 },
    seals_of_command                = { 10643, 1, 85126 },
    sanctified_wrath                = { 10669, 3, 53375, 90286, 53376 },
    selfless_healer                 = { 11271, 3, 85804, 85803, 85804 },
    repentance                      = { 10663, 1, 20066 },
    divine_purpose                  = { 10633, 2, 85117, 86172 },
    inquiry_of_faith                = { 10677, 3, 53380, 53381, 53382 },
    acts_of_sacrifice               = { 11211, 2, 85446, 85795 },
    zealotry                        = { 11222, 1, 85696 }
} )


-- Auras
spec:RegisterAuras( {
    aura = {
        alias = { "devotion_aura", "retribution_aura", "concentration_aura", "resistance_aura", "crusader_aura" },
        aliasMode = "first",
        aliasType = "buff",
    },
    stat_buff = {
        alias = { "blessing_of_kings", "mark_of_the_wild" },
        aliasMode = "first",
        aliasType = "buff"
    },
    seal = {
        alias = { "seal_of_truth", "seal_of_righteousness", "seal_of_insight", "seal_of_justice" },
        aliasMode = "first",
        aliasType = "buff"
    },
    active_consecration = {
        duration = function() return 10 + (glyph.consecration.enabled and 2 or 0) end,
        max_stack = 1,
        generate = function ( t )
            local applied = action.consecration.lastCast

            if applied and now - applied < 10 + (glyph.consecration.enabled and 2 or 0) then
                t.count = 1
                t.expires = applied + 10 + (glyph.consecration.enabled and 2 or 0)
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

    -- Auras

    -- Increases armor by $s2%.
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    -- Does $s2% Holy damage to anyone who strikes you.
    retribution_aura = {
        id = 7294,
        duration = 3600,
        max_stack = 1,
        shared = "player",
    },
    -- Reduces casting or channeling time lost when damaged by 35%.
    concentration_aura = {
        id = 19746,
        duration = 3600,
        max_stack = 1,
        shared = "player",
    },
    -- Increases Fire, Frost and Shadow resistance by $s1.
    resistance_aura = {
        id = 19891,
        duration = 3600,
        max_stack = 1,
        shared = "player",
    },
    -- Mounted speed increased by 20%. This does not stack with other movement speed increasing effects.
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,
        shared = "player",
    },

    -- Seals

    -- Single-target attacks cause Holy damage over 15 sec.
    seal_of_truth = {
        id = 31801,
        duration = 1800,
        max_stack = 1
    },
    -- Melee attacks cause an additional [Mainhand weapon base speed * (0.011 * Attack power + 0.022 * Spell power) * (100) / 100] Holy damage.
    seal_of_righteousness = {
        id = 20154,
        duration = 1800,
        max_stack = 1
    },
    -- Melee attacks have a chance to heal you and regenerate mana.
    seal_of_insight = {
        id = 20165,
        duration = 1800,
        max_stack = 1
    },
    -- Melee attacks limit maximum run speed for 5 sec and deal [Mainhand weapon base speed * (0.005 * Attack power + 0.01 * Spell power) * (100) / 100] additional Holy damage.
    seal_of_justice = {
        id = 20164,
        duration = 1800,
        max_stack = 1
    },

    -- Class Buffs

    -- All damage and healing increased by 20%
    avenging_wrath = {
        id = 31884,
        duration = 20,
        max_stack = 1
    },
    -- Places a Blessing on the friendly target, increasing Strength, Agility, Stamina, and Intellect by 5%, and all magical resistances by 97, for 1 hour.  
    -- If target is in your party or raid, all party and raid members will be affected. Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_kings = {
        id = 20217,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    -- Places a Blessing on the friendly target, increasing melee attack power by 20%, increasing ranged attack power by 10%, and restoring 0 mana every 5 seconds for 1 hour.  
    -- If target is in your party or raid, all party and raid members will be affected. Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_might = {
        id = 19740,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    -- Gaining 12% of total mana. Healing spells reduced by 50%.
    divine_plea = {
        id = 54428,
        duration = 9,
        max_stack = 1
    },
    -- Damage taken reduced by 20%.
    -- ALT: Glyph of Divine Protection - Also reduced magical damage by 20%.
    divine_protection = {
        id = 498,
        duration = 10,
        max_stack = 1
    },
    -- Immune to all attacks and spells, but reduces all damage you deal by 50%.
    divine_shield = {
        id = 642,
        duration = 8,
        max_stack = 1
    },
    -- Protected by a Guardian of Ancient Kings.
    -- ALT: Holy - The Guardian will heal the target of your next 5 single-target heals, and nearby friendly targets for 10% of the amount healed.
    -- ALT: Protection - Incoming damage reduced by 50%.
    -- ALT: Retribution - Attacks by you and your Guardian infuse you with Ancient Power and unleash Ancient Fury when your Guardian departs.
    guardian_of_ancient_kings = {
        id = 86669,
        duration = function()
            if class.spec.key == "protection" then
                return 12
            else
                return 30
            end
        end,

        max_stack = 1,
        copy = { 86669, 86659, 86698 }
    },
    -- Immune to movement impairing effects.
    hand_of_freedom = {
        id = 1044,
        duration = function() return 6 + 2 * talent.guardians_favor.rank end,
        max_stack = 1
    },
    -- Immune to physical attacks.  Cannot attack or use physical abilities.
    hand_of_protection = {
        id = 1022,
        duration = 10,
        max_stack = 1
    },
    -- Transfers 30% damage taken to the paladin.
    hand_of_sacrifice = {
        id = 6940,
        duration = 12,
        max_stack = 1
    },
    -- Reduces total threat by 2% each second.
    -- ALT: Glyph of Salvation - Threat temporarily reduced.
    hand_of_salvation = {
        id = 1038,
        duration = 10,
        max_stack = 1
    },
    -- Imbues a friendly target with radiant energy, healing that target and all allies within 10 yards for 2428 and another 473 every 1 sec for 3 sec. Healing effectiveness diminishes for each player target beyond 6.
    holy_radiance = {
        id = 82327,
        duration = 3,
        max_stack = 1
    },
    -- Increases Holy damage done by 30%.
    -- Duration is 4 seconds per Holy Power spent, increased by the Inquiry of Faith talent.
    inquisition = {
        id = 84963,
        duration = function()
            local holyPowerSpent = math.min(holy_power.current, 3)
            local inquiryRank = talent.inquiry_of_faith.rank

            if inquiryRank == 1 then
                return holyPowerSpent * 4 * 1.66
            elseif inquiryRank == 2 then
                return holyPowerSpent * 4 * 2.33
            elseif inquiryRank == 3 then
                return holyPowerSpent * 4 * 3.00
            else
                return holyPowerSpent * 4
            end
        end,
        max_stack = 1
    },
    -- Increases your threat generation while active.
    righteous_fury = {
        id = 25780,
        duration = 3600,
        max_stack = 1
    },
    
    -- Holy Buffs

    -- Concentration Aura provides immunity to Silence and Interrupt effects.  Effectiveness of Devotion Aura, Resistance Aura, and Retribution Aura increased by 100%.
    aura_mastery = {
        id = 31821,
        duration = 6,
        max_stack = 1,
        shared = "player"
    },
    -- Beacon of Light.
    beacon_of_light = {
        id = 53563,
        duration = 300,
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
    -- Your next Holy Shock will not trigger a cooldown.
    daybreak = {
        id = 88819,
        duration = 12,
        max_stack = 1
    },
    -- Spell haste increased by 20%. Spell critical chance increased by 20%.
    divine_favor = {
        id = 31842,
        duration = 20,
        max_stack = 1
    },
    -- TODO: This is the holy T12 4 set bonus so it probably needs to be moved.
    -- Heals for 10% of the value of Flash of Light, Holy Light, or Divine Light.
    divine_flame = {
        id = 54968,
        duration = 0,
        max_stack = 1
    },
    -- Reduces the cast time of your next Flash of Light, Holy Light, Divine Light or Holy Radiance by 0.75 sec.
    infusion_of_light = {
        id = 53672,
        duration = 15,
        max_stack = 1,
        copy = { 54149 },
    },
    -- Casting and melee speed increased by 3/6/9%. Mana regeneration from Spirit increased by 10%.
    judgements_of_the_pure = {
        id = 53657,
        duration = 60,
        max_stack = 1,
        copy = { 53655, 53656 }
    },
    -- The paladin's healing spells cast on you also heal the Beacon of Light.
    lights_beacon = {
        id = 53651,
        duration = 2,
        max_stack = 1,
    },
    
    -- Protection Buffs
    
    -- Damage taken reduced by 20%. The next attack that would otherwise kill you will instead cause you to be healed for 15% of your maximum health.
    ardent_defender = {
        id = 31850,
        duration = 10,
        max_stack = 1
    },
    -- Damage taken reduced by 20%.
    divine_guardian = {
        id = 70940,
        duration = 6,
        max_stack = 1,
        shared = "player"
    },
    -- 30% of all damage taken by party members redirected to the Paladin.
    divine_sacrifice = {
        id = 64205,
        duration = 10,
        max_stack = 1
    },
    -- Your next Avenger's Shield will generate Holy Power.
    grand_crusader = {
        id = 85416,
        duration = 6,
        max_stack = 1
    },
    -- Absorbs damage.
    -- TODO: Need testing for this overheal tracking function
    guarded_by_the_light = {
        id = 88063,
        duration = 6,
        max_stack = 1,
        type = buff,
        generate = function(t)
            t.count = 1
            t.expires = state.query_time + 6
            t.applied = state.query_time
            t.caster = "player"
            t.v1 = 0 -- Overhealing amount
        end
    },
    -- Increases damage blocked by 20%.
    holy_shield = {
        id = 20925,
        duration = 10,
        max_stack = 1
    },
    -- Your Judgement grants you 25% of your base mana over 10 sec.
    judgements_of_the_bold = {
        id = 89906,
        duration = 10,
        max_stack = 1
    },
    -- Each weapon swing generates an additional attack.
    reckoning = {
        id = 20178,
        duration = 8,
        max_stack = 4,
        copy = { 20178 }
    },
    -- Your next Shield of the Righteous will be a critical strike.
    sacred_duty = {
        id = 85433,
        duration = 10,
        max_stack = 1,
        copy = { 85433 }
    },
    -- Increases attack power by $s1%.
    vengeance = {
        id = 76691,
        duration = 3600,
        max_stack = 1
    },

    -- Retribution Buffs

    -- Unleash the fury of ancient kings, causing 234 Holy damage per application of Ancient Fury, divided evenly among all targets within 10 yards.
    ancient_fury = {
        id = 86704,
        duration = 30,
        max_stack = 20
    },
    -- Damage and healing increasedy by 1/2/3%
    conviction = {
        id = 20050,
        duration = 15,
        max_stack = 3,
        copy = { 20052, 20053 }
    },
    -- Your next Holy Light heals for an additional 100%.
    crusader = {
        id = 94686,
        duration = 15,
        max_stack = 1
    },
    -- Regaining 3% of your base mana per second.
    judgements_of_the_wise = {
        id = 31930,
        duration = 10,
        max_stack = 1
    },
    -- Movement speed increased by 45%.
    long_arm_of_the_law = {
        id = 87173,
        duration = 4,
        max_stack = 1
    },
    -- NOTE: Should Replenishment be in the paladin lua?
    -- Replenishes 1% of maximum mana per 10 sec.
    replenishment = {
        id = 57669,
        duration = 15,
        max_stack = 1
    },
    -- Absorbs $s1% damage. Increases healing received by 20%.
    sacred_shield = {
        id = 96263,
        duration = 15,
        max_stack = 1
    },
    -- Damage increased by $s1%.
    selfless = {
        id = 90811,
        duration = 10,
        max_stack = 1
    },
    -- Movement speed increased by 20/40/60%.
    speed_of_light = {
        id = 85497,
        duration = 10,
        max_stack = 1
    },
    -- Your next Exorcism is instant, free, and causes 100% additional damage.
    the_art_of_war = {
        id = 59578,
        duration = 15,
        max_stack = 1
    },

    -- Class Debuffs

    -- Holy damage every 3 sec.
    censure = {
        id = 31803,
        duration = 15,
        max_stack = 5
    },
    -- $s1 damage every 1 second.
    consecration = {
        id = 82366,
        duration = function() return glyph.consecration.enabled and 12 or 10 end,
        tick_time = 1,
        max_stack = 1,
        copy = { 26573 },
    },
    -- Suffering $s1% Holy damage per 2 sec.
    exorcism = {
        id = 879,
        duration = 6,
        max_stack = 1
    },
    -- Cannot be affected by Divine Shield, Hand of Protection or Lay on Hands.
    forbearance = {
        id = 25771,
        duration = 60,
        max_stack = 1,
        shared = "player"
    },
    -- Stunned.
    hammer_of_justice = {
        id = 853,
        duration = 6,
        max_stack = 1
    },
    -- Taunted.
    hand_of_reckoning = {
        id = 62124,
        duration = 3,
        max_stack = 1,
    },
    -- Stunned.
    holy_wrath = {
        id = 2812,
        duration = 3,
        max_stack = 1
    },
    -- NOTE: This is actually called Seal of Justice but shares a name with the buff seal as well.
    -- Cannot move faster than normal movement speed.
    justice = {
        id = 20170,
        duration = function() return 5 + 1 * talent.judgements_of_the_just.rank end,
        max_stack = 1,
    },
    -- Compelled to flee.
    turn_evil = {
        id = 10326,
        duration = 20,
        max_stack = 1,
    },

    -- Holy Debuffs

    -- Incapable of causing a critical effect.
    denounce = {
        id = 85509,
        duration = 6,
        max_stack = 1
    },

    -- Protection Debuffs

    -- Silenced.
    avengers_shield = {
        id = 48827,
        duration = 3,
        max_stack = 1
    },
    -- Dazed.
    dazed_avengers_shield = {
        id = 63529,
        duration = 10,
        max_stack = 1
    },
    -- Attack speed slowed.
    judgements_of_the_just = {
        id = 68055,
        duration = 20,
        max_stack = 1
    },
    -- Physical damage done reduced by 10%.
    vindication = {
        id = 26017,
        duration = 10,
        max_stack = 1,
        shared = "target"
    },

    -- Retribution Debuffs

    -- Incapacitated.
    repentance = {
        id = 20066,
        duration = 60,
        max_stack = 1,
    }
} )

-- Glyphs
spec:RegisterGlyphs( {
    [63218] = "beacon_of_light",
    [57937] = "blessing_of_kings",
    [57958] = "blessing_of_might",
    [54935] = "cleansing",
    [54928] = "consecration",
    [54927] = "crusader_strike",
    [56414] = "dazing_shield",
    [54937] = "divine_favor",
    [63223] = "divine_plea",
    [54924] = "divine_protection",
    [54939] = "divinity",
    [54934] = "exorcism",
    [54930] = "focused_shield",
    [54923] = "hammer_of_justice",
    [63219] = "hammer_of_the_righteous",
    [54926] = "hammer_of_wrath",
    [63224] = "holy_shock",
    [56420] = "holy_wrath",
    [57979] = "insight",
    [54922] = "judgement",
    [57954] = "justice",
    [57955] = "lay_on_hands",
    [54940] = "light_of_dawn",
    [54925] = "rebuke",
    [89401] = "righteousness",
    [63225] = "salvation",
    [54943] = "seal_of_insight",
    [56416] = "seal_of_truth",
    [63222] = "shield_of_the_righteous",
    [63220] = "templars_verdict",
    [54938] = "ascetic_crusader",
    [93466] = "long_word",
    [57947] = "truth",
    [54931] = "turn_evil",
    [54936] = "word_of_glory"
} )

-- Abilities
spec:RegisterAbilities( {
    -- Class Abilities

    -- Brings all dead party and raid members back to life with 35% health and 35% mana. Cannot be cast in combat or while in a battleground or arena.
    absolution = {
        id = 450761,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135950,

        handler = function ()
        end,
    },
    -- Increases all damage and healing caused by 20% for 20 sec.
    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.paragon_of_virtue.rank end,
        gcd = "off",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 135875,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avenging_wrath" )
        end,
    },
    -- Places a Blessing on the friendly target, increasing Strength, Agility, Stamina, and Intellect by 5%, and all magical resistances by 97, for 1 hour.  
    -- If target is in your party or raid, all party and raid members will be affected.  Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_kings = {
        id = 20217,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() 
            local base_cost = 0.19
            local reduction = glyph.blessing_of_kings.enabled and 0.5 or 1
            return base_cost * reduction
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 135993,

        handler = function ()
            removeBuff( "blessing" )
            applyBuff( "blessing_of_kings" )
        end,
    },
    -- Places a Blessing on the friendly target, increasing melee attack power by 20%, increasing ranged attack power by 10%, and restoring 0 mana every 5 seconds for 1 hour.
    -- If target is in your party or raid, all party and raid members will be affected.  Players may only have one Blessing on them per Paladin at any one time.
    blessing_of_might = {
        id = 19740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() 
            local base_cost = 0.19
            local reduction = glyph.blessing_of_might.enabled and 0.5 or 1
            return base_cost * reduction
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 135908,

        handler = function ()
            removeBuff( "blessing" )
            applyBuff( "blessing_of_might" )
        end,
    },
    -- Cleanses a friendly target, removing 1 Poison effect and 1 Disease effect.
    -- ALT: Sacred Cleansing - Cleanses a friendly target, removing 1 Poison effect, 1 Disease effect, and 1 Magic effect.
    -- ALT: Acts of Sacrifice - Cleanses a friendly target, removing 1 Poison effect, 1 Disease effect. Also removes a movement impairing effect if used on yourself.
    cleanse = {
        id = 4987,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() 
            local base_cost = 0.14
            local reduction = glyph.cleansing.enabled and 0.2 or 1
            return base_cost * reduction
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

        buff = function()
            if buff.dispellable_poison.up then return "dispellable_poison" end
            if buff.dispellable_disease.up then return "dispellable_disease" end
            if buff.dispellable_magic.up and glyph.sacred_cleansing.enabled then return "dispellable_magic" end
            return "dispellable_magic"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_disease" )
            if glyph.sacred_cleansing.enabled then removeBuff( "dispellable_magic" ) end
        end,
    },
    -- All party or raid members within 40 yards lose 35% less casting or channeling time when damaged. Players may only have one Aura on them per Paladin at any one time.
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
    -- Consecrates the land beneath the Paladin, doing 780 Holy damage over 10 sec to enemies who enter the area.
    consecration = {
        id = 26573,
        cast = 0,
        cooldown = function() return glyph.consecration.enabled and 36 or 30 end,
        gcd = "spell",

        spend = function()
            local base_cost = 0.19
            if talent.hallowed_ground.rank == 1 then
                return base_cost * 0.6
            elseif talent.hallowed_ground.rank == 2 then
                return base_cost * 0.2
            else
                return base_cost
            end
        end,
        spendType = "mana",

        startsCombat = true,
        texture = 135926,

        handler = function ()
            applyBuff( "active_consecration" )
            applyDebuff( "target", "consecration" )
        end,
    },
    -- Increases the mounted speed by 20% for all party and raid members within 40 yards. Players may only have one Aura on them per Paladin at any one time. This does not stack with other movement speed increasing effects.
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
        cooldown = function()
            local base_cooldown = 4
            local haste_multiplier = 1 / (1 + min(haste, 100) / 100)

            if talent.sanctity_of_battle.enabled then
                return base_cooldown * haste_multiplier
            else
                return base_cooldown
            end
        end,
        gcd = "spell",

        spend = function() 
            local base_cost = 0.1
            local reduction = glyph.ascetic_crusader.enabled and 0.7 or 1
            return base_cost * reduction
        end,
        spendType = "mana",

        talent = "crusader_strike",
        startsCombat = true,
        texture = 135891,

        handler = function ()
            if talent.vindication.enabled then applyDebuff( "target", "vindication" ) end
        end,
    },
    -- Gives 0 additional armor to party and raid members within 40 yards.  Players may only have one Aura on them per time per Paladin at any one time.
    devotion_aura = {
        id = 465,
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
    -- A large heal that heals a friendly target for 11245. Good for periods of heavy damage.
    divine_light = {
        id = 82326,
        cast = function()
            local base_cast = 3
            if talent.clarity_of_purpose.rank == 1 then
                base_cast = base_cast - 0.15
            elseif talent.clarity_of_purpose.rank == 2 then
                base_cast = base_cast - 0.3
            elseif talent.clarity_of_purpose.rank == 3 then
                base_cast = base_cast - 0.5
            end
            if buff.infusion_of_light.up and talent.infusion_of_light.rank == 1 then
                return base_cast - 0.75
            elseif buff.infusion_of_light.up and talent.infusion_of_light.rank == 2 then
                return base_cast - 1.5
            else
                return base_cast
            end
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.35,
        spendType = "mana",

        startsCombat = false,
        texture = 135981,

        handler = function ()
            if buff.infusion_of_light.up then removeBuff( "infusion_of_light" ) end
        end,
    },
    -- You gain 12% of your total mana over 9 sec, but the amount healed by your healing spells is reduced by 50%.
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
    -- Reduces all damage taken by 20% for 10 sec.
    -- ALT: Glyph of Divine Protection - Also reduces magical damage taken by 20%.
    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = function() return 60 - 15 * talent.paragon_of_virtue.rank end,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 524353,

        toggle = "defensives",

        nobuff = "divine_protection",

        handler = function ()
            applyBuff( "divine_protection" )
        end,
    },
    -- Protects you from all damage and spells for 8 sec, but reduces all damage you deal by 50%. Cannot be used on a target with Forbearance. Causes Forbearance for 1 min.
    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 524354,

        toggle = "defensives",

        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "divine_shield" )
            applyDebuff( "player", "forbearance" )
        end,
    },
    -- Causes [((2483 + 2771) / 2) + (0.344 * Attack power)] Holy damage to an enemy target.  If the target is Undead or Demon, it will always critically hit.
    exorcism = {
        id = 879,
        cast = function() return buff.the_art_of_war.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.3,
        spendType = "mana",

        startsCombat = true,
        texture = 135903,

        handler = function ()
            removeBuff("the_art_of_war")
            if glyph.exoricism.enabled then applyDebuff( "target", "exorcism" ) end
            if talent.denounce.rank == 1 and rng.roll(0.5) then applyDebuff( "target", "denounce" ) end
            if talent.denounce.rank == 2 then applyDebuff( "target", "denounce" ) end
        end,
    },
    -- A quick, expensive heal that heals a friendly target for 7024.
    flash_of_light = {
        id = 19750,
        cast = function()
            local base_cast = 1.5
            if buff.infusion_of_light.up and talent.infusion_of_light.rank == 1 then
                return base_cast - 0.75
            elseif buff.infusion_of_light.up and talent.infusion_of_light.rank == 2 then
                return base_cast - 1.5
            else
                return base_cast
            end
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.31,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            if buff.infusion_of_light.up then removeBuff( "infusion_of_light" ) end
        end,
    },
    -- ALT: Summons a Guardian of Ancient Kings to protect you for 30 sec.
    --      While active, your next 5 direct heals will cause the Guardian to heal the same target for the amount healed by your heal, and friendly targets within 10 yards of the target for 10% of the amount healed
    -- ALT: Summons a Guardian of Ancient Kings to protect you for 12 sec.
    --      While the Guardian is active, all incoming damage is reduced by 50%
    -- ALT: Summons a Guardian of Ancient Kings to attack your current target for 30 sec.
    --      While active, your and your Guardian's attacks cause you to be infused with Ancient Power, increasing your Strength by 1% per application.
    --      After 30 sec or when your Guardian is killed, you will release Ancient Fury, causing 199 damage plus 199 per application of Ancient Power, divided among all targets within 10 yards
    guardian_of_ancient_kings = {
        id = 86150,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        startsCombat = function() if class.spec.key == "retribution" then return true else return false end end,
        texture = 135919,

        handler = function ()
            applyBuff( "guardian_of_ancient_kings" )
            if class.spec.key == "retribution" then applyBuff( 'ancient_fury' ) end
        end,
    },
    -- Stuns the target for 6 sec.
    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.improved_hammer_of_justice.rank end,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135963,

        handler = function ()
            applyDebuff( "target", "hammer_of_justice" )
        end,
    },
    -- Hurls a hammer that strikes an enemy for 3848 Holy damage. Only usable on enemies that have 20% or less health.
    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return glyph.hammer_of_wrath.enabled and 0 or 0.12 end,
        spendType = "mana",

        startsCombat = true,
        texture = 133041,

        usable = function()
            if talent.sanctified_wrath.enabled and buff.avenging_wrath.up then
                return true
            else
                return target.health.pct < 20
            end
        end,
        
        handler = function ()
        end,
    },
    -- Places a Hand on the friendly target, granting immunity to movement impairing effects for 6 sec. Players may only have one Hand on them per Paladin at any one time.
    hand_of_freedom = {
        id = 1044,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = function() return 0.06 - ( 0.06 * 0.2 * talent.acts_of_sacrifice.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135968,

        handler = function ()
            applyBuff( "hand_of_freedom" )
        end,
    },
    -- A targeted party or raid member is protected from all physical attacks for 6 sec, but during that time they cannot attack or use physical abilities.
    -- Players may only have one Hand on them per Paladin at any one time.  Once protected, the target cannot be targeted by Divine Shield, Divine Protection, or Hand of Protection again for 2 min.
    -- Cannot be targeted on players who have used Avenging Wrath within the last 30 sec.
    hand_of_protection = {
        id = 1022,
        cast = 0,
        cooldown = function() return 300 - 60 * talent.guardians_favor.rank end,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135964,

        toggle = "defensives",

        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "hand_of_protection" )
            applyDebuff( "forbearance" )
        end,
    },
    -- Taunts the target to attack you, but has no effect if the target is already attacking you.
    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135984,

        handler = function ()
            applyDebuff( "target", "hand_of_reckoning" )
        end,
    },
    -- Places a Hand on the party or raid member, transferring 30% damage taken to the caster. Lasts 12 sec or until the caster has transferred 100% of their maximum health.
    -- Players may only have one Hand on them per Paladin at any one time.
    hand_of_sacrifice = {
        id = 6940,
        cast = 0,
        cooldown = function() return 120 - 15 * talent.paragon_of_virtue.rank end,
        gcd = "spell",

        spend = function() return 0.06 - ( 0.06 * 0.2 * talent.acts_of_sacrifice.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135966,

        toggle = "defensives",

        handler = function ()
            applyBuff( "hand_of_sacrifice" )
        end,
    },
    -- Places a Hand on the party or raid member, reducing their total threat by 2% every 1 sec for 10 sec. Players may only have one Hand on them per Paladin at any one time.
    -- ALT: Glyph of Salvation - Places a Hand on the party or raid member, removing all threat from the target for 10 sec.
    hand_of_salvation = {
        id = 1038,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return 0.06 - ( 0.06 * 0.2 * talent.acts_of_sacrifice.rank ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135967,

        toggle = "defensives",

        handler = function ()
            applyBuff( "hand_of_salvation" )
        end,
    },
    -- Heals a friendly target for 4217.
    holy_light = {
        id = 635,
        cast = function()
            local base_cast = 3
            if talent.clarity_of_purpose.rank == 1 then
                base_cast = base_cast - 0.15
            elseif talent.clarity_of_purpose.rank == 2 then
                base_cast = base_cast - 0.3
            elseif talent.clarity_of_purpose.rank == 3 then
                base_cast = base_cast - 0.5
            end
            if buff.infusion_of_light.up and talent.infusion_of_light.rank == 1 then
                return base_cast - 0.75
            elseif buff.infusion_of_light.up and talent.infusion_of_light.rank == 2 then
                return base_cast - 1.5
            else
                return base_cast
            end
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        startsCombat = false,
        texture = 135920,

        handler = function ()
            if buff.infusion_of_light.up then removeBuff( "infusion_of_light" ) end
        end,
    },
    -- Imbues a friendly target with radiant energy, healing that target and all allies within 10 yards for 2428 and another 473 every 1 sec for 3 sec. Healing effectiveness diminishes for each player target beyond 6.
    holy_radiance = {
        id = 82327,
        cast = function()
            local base_cast = 3
            if talent.clarity_of_purpose.rank == 1 then
                base_cast = base_cast - 0.15
            elseif talent.clarity_of_purpose.rank == 2 then
                base_cast = base_cast - 0.3
            elseif talent.clarity_of_purpose.rank == 3 then
                base_cast = base_cast - 0.5
            end
            if buff.infusion_of_light.up and talent.infusion_of_light.rank == 1 then
                return base_cast - 0.75
            elseif buff.infusion_of_light.up and talent.infusion_of_light.rank == 2 then
                return base_cast - 1.5
            else
                return base_cast
            end
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.4,
        spendType = "mana",

        startsCombat = false,
        texture = 457654,

        handler = function ()
            applyBuff( "target", "holy_radiance" )
        end,
    },
    -- Sends bolts of holy power in all directions, causing (0.61 * Spell power + 2302) Holy damage divided among all targets within 10 yds and stunning all Demons and Undead for 3 sec.
    holy_wrath = {
        id = 2812,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = true,
        texture = 135950,

        handler = function()
            if target.is_boss and (target.is_undead or target.is_demon) then
                applyDebuff("target", "holy_wrath")
            elseif target.is_boss and glyph.holy_wrath.enabled and (target.is_dragonkin or target.is_elemental) then
                applyDebuff("target", "holy_wrath")
            end
        end,
    },
    -- Consumes all Holy Power to increase your Holy Damage by 30%.  Lasts 4 sec per charge of Holy Power consumed.
    inquisition = {
        id = 84963,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            local holy_power = state.holy_power.current
            if buff.divine_purpose.up then
                return 0
            else
                return holy_power
            end
        end,
        spendType = "holy_power",

        talent = "inquisition",
        startsCombat = false,
        texture = 461858,

        handler = function ()
            applyBuff( "inquisition" )
        end,
    },
    -- Unleashes the energy of a Seal to judge an enemy for Holy damage.
    judgement = {
        id = 20271,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
            applyDebuff( "target", "judgement" )
            if talent.judgements_of_the_pure.enabled then applyBuff( "judgements_of_the_pure" ) end
            if talent.judgements_of_the_wise.enabled then applyBuff( "judgements_of_the_wise" ) end
            if talent.judgements_of_the_bold.enabled then applyBuff( "judgements_of_the_bold" ) end
            if talent.judgements_of_the_just.enabled then applyDebuff( "target", "judgements_of_the_just" ) end
        end,
    },
    -- Heals a friendly target for an amount equal to your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 1 min.
    -- ALT: Glyph of Divinity - and causes you to regain 10% of your maximum mana
    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function() return glyph.lay_on_hands.enabled and 420 or 600 end,
        gcd = "spell",

        startsCombat = false,
        texture = 135928,

        toggle = "defensives",

        handler = function ()
            if glyph.divinity.enabled then
                gain( 0.1 * player.maximum_mana, "mana" )
            end
            applyDebuff( "player", "forbearance" )
        end,
    },
    -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    rebuke = {
        id = 96231,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        startsCombat = true,
        texture = 523893,

        toggle = "interrupts",

        handler = function ()
            interrupt()
        end,
    },
    -- Brings a dead ally back to life with 35% of maximum health and mana. Cannot be cast when in combat.
    redemption = {
        id = 7328,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.64,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,
    },
    -- Gives 195 additional Fire, Frost and Shadow resistance to all party and raid members within 40 yards. Players may only have one Aura on them per Paladin at any one time.
    resistance_aura = {
        id = 19891,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135824,

        nobuff = "resistance_aura",

        handler = function ()
            removeBuff( "aura" )
            applyBuff( "resistance_aura" )
        end,
    },
    -- Causes 116 Holy damage to any enemy that strikes a party or raid member within 40 yards. Players may only have one Aura on them per Paladin at any one time.
    retribution_aura = {
        id = 7294,
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
    -- Increases your threat generation while active, making you a more effective tank.
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
    -- Fills the Paladin with divine power for 30 min, giving each single-target melee attack a chance to heal the Paladin for (0.15 * Attack power + 0.15 * Spell power) and restore 4% of the Paladin's base mana.  
    -- Only one Seal can be active on the Paladin at any one time. Unleashing this Seal's energy will deal (1 + 0.25 * Spell power + 0.16 * Attack power) Holy damage to an enemy.
    seal_of_insight = {
        id = 20165,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.insight.enabled and 0.7 or 0.14 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135917,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_insight" )
        end,
    },
    -- Fills the Paladin with the spirit of justice for 30 min, causing each single-target melee attack to limit the target's maximum run speed for 5 sec and deal 
    -- [Mainhand weapon base speed * (0.005 * Attack power + 0.01 * Spell power) * (100) / 100] additional Holy damage. Only one Seal can be active on the Paladin at any one time.
    -- Unleashing this Seal's energy will deal (1 + 0.25 * Spell power + 0.16 * Attack power) Holy damage to an enemy.
    seal_of_justice = {
        id = 20164,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.justice.enabled and 0.7 or 0.14 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135971,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_justice" )
        end,
    },
    -- Fills the Paladin with holy spirit for 30 min, granting each melee attack [Mainhand weapon base speed * (0.011 * Attack power + 0.022 * Spell power) * (100) / 100] additional Holy damage.
    -- Unleashing this Seal's energy will cause (1 + 0.2 * Attack power + 0.32 * Spell power) Holy damage to an enemy
    -- ALT: Glyph of Seal of Truth - Also grants 10 expertise while active.
    seal_of_righteousness = {
        id = 20154,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.righteousness.enabled and 0.7 or 0.14 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135960,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_righteousness" )
        end,
    },
    -- Fills the Paladin with holy power, causing single-target attacks to Censure the target, which deals [(0.01 * Spell power + 0.0270 * Attack power) * 5 * (100) / 100] additional Holy damage over 15 sec.
    -- Censure can stack up to 5 times.  Once stacked to 5 times, each of the Paladin's attacks also deals 15% weapon damage as additional Holy damage.
    -- Unleashing this Seal's energy will deal (1 + 0.223 * Spell power + 0.142 * Attack power) Holy damage to an enemy, increased by 20% for each application of Censure on the target.
    -- ALT: Glyph of Seal of Truth - Also grants 10 expertise while active.
    seal_of_truth = {
        id = 31801,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.truth.enabled and 0.7 or 0.14 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135969,

        handler = function ()
            removeBuff( "seal" )
            applyBuff( "seal_of_truth" )
        end,
    },
    -- Slam the target with your shield, causing Holy damage.  Consumes all charges of Holy Power to determine damage dealt:
    -- 1 Holy Power: 584 damage
    -- 2 Holy Power: 1752 damage
    -- 3 Holy Power: 3504 damage
    shield_of_righteousness = {
        id = 53600,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function()
            local holy_power = state.holy_power.current
            if buff.divine_purpose.up then
                return 0
            else
                return holy_power
            end
        end,
        spendType = "holy_power",

        startsCombat = true,
        texture = 236265,

        equipped = "shield",

        handler = function ()
        end,
    },
    -- The targeted undead or demon enemy will be compelled to flee for up to 20 sec. Damage caused may interrupt the effect. Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = function() return glyph.turn_evil.enabled and 0 or 1.5 end,
        cooldown = function() return glyph.turn_evil.enabled and 8 or 0 end,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 135983,

        usable = function() return target.is_undead or target.is_demon, "target must be undead or demon" end,

        handler = function ()
            applyDebuff( "target", "turn_evil" )
        end,
    },
    -- Consumes all Holy Power to heal a friendly target for [((1733 + 1930) / 2) + 0.198 * Attack power] per charge of Holy Power.
    -- ALT: Glyph of the Long Word: plus 1831.5 over 6 sec
    -- TODO: The Overheal tracking component needs testing
    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = function() return talent.walk_in_the_light.enabled and 0 or 20 end,
        gcd = "spell",

        spend = function()
            local holy_power = state.holy_power.current
            if buff.divine_purpose.up then
                return 0
            else
                return holy_power
            end
        end,
        spendType = "holy_power",

        talent = "word_of_glory",
        startsCombat = true,
        texture = 133192,

        handler = function()
            if glyph.long_word.enabled then
                applyBuff("long_word")
            end

            local heal_amount = 0
            local target = "player"
            local healed = state:Heal(target, "word_of_glory", heal_amount)

            -- Check for overhealing
            if healed > state.health.max then
                local overheal = healed - state.health.max
                applyBuff("guarded_by_the_light", 6, 1, overheal)
            end

            if talent.selfless_healer.enabled then applyBuff( "selfless" ) end
        end,
    },

    -- Holy Abilities

    -- Causes your Concentration Aura to make all affected targets immune to Silence and Interrupt effects and improve the effect of Devotion Aura, Resistance Aura, and Retribution Aura by 100%. Lasts 6 sec.
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
    -- The target becomes a Beacon of Light to all targets within a 60 yard radius.  Your Word of Glory, Holy Shock, Flash of Light, Divine Light and Light of Dawn will also heal the Beacon for 50% of the amount healed.
    -- Holy Light will heal for 100% of the amount. Only one target can be the Beacon of Light at a time. Lasts 5 min.
    beacon_of_light = {
        id = 53563,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.beacon_of_light.enabled and 0 or 0.06 end,
        spendType = "mana",

        talent = "beacon_of_light",
        startsCombat = false,
        texture = 135873,

        handler = function ()
            applyBuff( "target", "beacon_of_light" )
        end,
    },
    -- Increases your spell casting haste by 20% and spell critical chance by 20% for 20 sec.
    divine_favor = {
        id = 31842,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "divine_favor",
        startsCombat = false,
        texture = 135915,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_favor" )
        end,
    },
    -- Blasts the target with Holy energy, causing 1397 Holy damage to an enemy, or 2625 healing to an ally, and grants a charge of Holy Power.
    holy_shock = {
        id = 20473,
        cast = 0,
        cooldown = function() return buff.daybreak.up and 0 or 6 end,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        talent = "holy_shock",
        startsCombat = true,
        texture = 135972,

        handler = function ()
            applyBuff( "infusion_of_light")
        end,
    },

    -- Protection Abilities

    -- Reduce damage taken by 20% for 10 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead cause you to be healed for 15% of your maximum health.
    ardent_defender = {
        id = 31850,
        cast = 0,
        cooldown = 180,
        gcd = 0,

        talent = "ardent_defender",
        starsCombat = false,
        texture = 135870,

        handler = function()
            applyBuff( "ardent_defender" )
        end,
    },
    -- Hurls a holy shield at the enemy, dealing 2674 Holy damage, silencing and interrupting spellcasting for 3 sec, and then jumping to additional nearby enemies.  Affects 3 total targets.
    -- ALT: Glyph of Dazing Shield - dazing
    avengers_shield = {
        id = 31935,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "avengers_shield",
        startsCombat = true,
        texture = 135874,

        handler = function ()
            applyDebuff( "target", "avengers_shield" )
            if glyph.dazing_shield.enabled then applyDebuff( "target", "dazing_shield" ) end
        end,
    },
    -- All party or raid members within 30 yards, excluding the Paladin, take 20% reduced damage for 6 sec.
    divine_guardian = {
        id = 70940,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "divine_guardian",
        startsCombat = false,
        texture = 253400,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_guardian" )
        end,
    },
    -- 30% of all damage taken by party members within 30 yards is redirected to the Paladin (up to a maximum of 40% of the Paladin's health times the number of party members).
    -- Damage which reduces the Paladin below 20% health will break the effect. Lasts 10 sec.
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
    -- Hammer the current target for 30% weapon damage, causing a wave of light that hits all targets within 8 yards for 699 Holy damage. Grants a charge of Holy Power.
    hammer_of_the_righteous = {
        id = 53595,
        cast = 0,
        cooldown = 4.5,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "hammer_of_the_righteous",
        startsCombat = true,
        texture = 236253,

        handler = function ()
            if talent.vindication.enabled then applyDebuff( "target", "vindication" ) end
        end,
    },
    -- Increases the amount your shield blocks by an additional 20% for 10 sec.
    holy_shield = {
        id = 20925,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "holy_shield",
        startsCombat = false,
        texture = 135880,

        handler = function ()
            applyBuff( "holy_shield" )
        end,
    },

    -- Retribution Abilities

    -- An instant attack that causes 100% weapon damage to all enemies within 8 yards.
    -- The Divine Storm heals up to 3 party or raid members totaling 25% of the damage caused, and will grant a charge of Holy Power if it hits 4 or more targets.
    divine_storm = {
        id = 53385,
        cast = 0,
        cooldown = function()
            local base_cooldown = 4
            local haste_multiplier = 1 / (1 + min(haste, 100) / 100)

            if talent.sanctity_of_battle.enabled then
                return base_cooldown * haste_multiplier
            else
                return base_cooldown
            end
        end,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "divine_storm",
        startsCombat = true,
        texture = 236250,

        handler = function ()
        end,
    },
    -- Puts the enemy target in a state of meditation, incapacitating them for up to 1 min. Any damage from sources other than Censure will awaken the target. Usable against Demons, Dragonkin, Giants, Humanoids and Undead.
    repentance = {
        id = 20066,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "repentance",
        startsCombat = false,
        texture = 135942,

        toggle = "defensives",

        usable = function() return not target.is_boss, "not usable against bosses" end,

        handler = function ()
            applyDebuff( "target", "repentance" )
        end,
    },

    -- An instant weapon attack that causes a percentage of weapon damage. Consumes all charges of Holy Power to increase damage dealt:
    -- 1 Holy Power: 30% Weapon Damage
    -- 2 Holy Power: 30% Weapon Damage
    -- 3 Holy Power: 90% Weapon Damage
    templars_verdict = {
        id = 85256,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            local holy_power = state.holy_power.current
            if buff.divine_purpose.up then
                return 0
            else
                return holy_power
            end
        end,
        spendType = "holy_power",

        talent = "templars_verdict",
        startsCombat = true,
        texture = 461860,

        handler = function ()
        end,
    },
} )

-- TODO: Update these for Cataclysm
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

-- TODO: Update these for Cataclysm
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

-- TODO: Update these for Cataclysm
--spec:RegisterPack( "Retribution (WoWSims)", 20230222.1, [[Hekili:1IvtVrokt4Fl5sRjAh5(JKjZ(UA65WE6DYHrRwVNTnTnTnBBmwaozAPi)BFl8NGBWjDNokkjwuq98qrrrvvW6G)jWpbjXb)CZQn3TAZMnERVF16vRd8LhlXb(LO4dOu4Jcef(7FJLCYUkjHvOKDmNHsu6qWQ4XG8mPSu8hlxMsKzv78Iz0LpZEwqOc4)Y8dl3LZ2TKIesmFjm8YsuokHuSKpQ4LCMeP(WlLf4VRIKl)rrWoRefqUehddcqtssWTZdlInOAD0F1ctDuVURJ2Z41r)F8bsojWpNiKIgJbEpQkxcF(ZgJdUaTlhNe8Nb(XCcWAckW)M6ibwkjfPcVmgpKII5mrD0I6O08JLzECC8bwbi3RB9nY(uDucEx1(9EsoIOehMurPh9QkRJE5L6iqVO0uoRo62aFuCRvodvKeY2hoOZa)kbggzFyACIIMs1(3fxBWtGr5EjSNlA4HsZpHdXfykbd0EBD06r8uZvH3t4IumQaovb9F37r)F3Q(bFdkS1uA)EL27LJuaRSnpZrYmDuHz(f9zwYA)VXmEqFgkdfquQyYK(68Bhtkahp6NgukMR4Fl9aL976iMb3A4GpjojefhJZXCKfs()CIpysqEGkIXfY6OVP5O9VvjPykmCd4ercJgkZ4yrglpzKawMMcX1R0zPXKYjPzYjeCTBNFGqH7yfvcpjbZxVkCtz8uFOeYtKcCOqY4TO72)e85Pmy2PoDDAeatR9OPDcXScboU12AC(OlOb57moDMC6nztFVtwcxDLiEkw6reHjyQkaI6g74GvfjyeCp)w77JTgHmYp2saBhGJsB40xUaxLoZFzogzdbnXnq8GtiM)M8jNYFv3whZReOeWAlG4WhWtT1g3Am00Kj6(UY5EO0g6ndhI4T3oq8MqVGOc8VKHLCcfXpgIKn70bZz)4IC4XWrsJ)fJhtenB9nRMZbFgp3lg9Po6BCFJ9JCF7(I9zC64Y5FJ7NDgi5Eg8AsriI98LCgBSfnc0ODjPxbXm4Ae8iNxVfaENNcpK3EX4HXDX(CKiBm0Q6h)s49BgDh61tTOdTHDOccj8BiQIJAJUieK0c1tmWiEAPo1mWiporYSzkCbqdoHQOpTEHta3ISztK4sGVpeZeKngUp)IRfOj4Nyw2UMd3NQY1c09eogYauaPPQsjBc2wL2Nl0vJcqkUYz4GvXZMR1fqcrgcUb6MfoK3NL2ztdy2a(9jN0tL(r96)qDx)GALJm5urZM33vIe02C5SrcAxSOUub)izHaS8YkiUQDMmkE(mnVsSPljyRuzib5My0pbPURMsxnMa18H3pkApy)bTKXLQs520MFN6bTM6g9QFe0ELekfmW3VcsjdYowOc5Z2tYX9iREqT7nGFB7YPXM)mz)2BQkxy)QWI5d5x)Onionc8zbYPl3bm6HBppe0xPDLBew9SuUXkTRCBXnplmSPahqzl845HLnnyhm7rbpl0SRc7WDsOo3i1p1fVHyPVoynH0E3G1OLxhSHOwVBah00RdAB8P3nITQP(XbabyoPVsFwRTsBx3G5f1Ll394svaWn9D4sNlN0Zjf6MDwArx9tD1IUDTT131tPxD1F3y1MT7rxsBhM0hzOJsMMsJ2kma)j9rYyr27uK(uS0lhLU1l8)BVT(d5uR5go)QaUALIRaZw7Emn(6vI24102pNtm5lUzU6GDBonenuFOcPpnPaZxEzAXL3oLfBNTlmwmeQcaDB0T2PL5mNM0PRbx6gtZUM4sv6J3xn6B1IyVe5fV9wbm7H)mNXxie67VRk3N3zYE3kmcBzwNF3TLpM2sCXnM4HMuBd(Vd]] )

spec:RegisterPack( "Retribution (LightClub)", 20231114.1, [[Hekili:vVrApoUT1FldcGHD6gn(yoYgmZeGMuGUlk2gu3pBjAjAB1rhguuE3byG(T3hj1bPmjLKp2MMSjWljFN8Dt7vZw9VxTmarXR(Y8PZxmB2S7CMnB6JZwSAj9T94vl3J8FfTf(qckg())lmLeUoNgMMu4n(FeUDh93IYxpHDW3IsrbmeMLMt8HdVJs3N9l3EBqyMFkjWz72BJyq4dq4hHYYc9xTCDEye9tjRwRJrEGXiz7X(WYa(cdcWItIZ8BXm)bkcfecFGKsrIL2Ksk8(74xdJcl8wJYWbfES1Rz7F63fCgae2pnogNeWbnB1YOWmAgxyct2gHHp9fUYcNGwhHdw9xxT0NesXKqetg2SXjdJICcs)AYQLiFgwayHLCt34EaNSfJsaDcLjiMqZyqLw4Dab)fythAym2LM6geIl8(XcVPoFSW7Nk8MpTWBsH3lfEc64Gy4hyt3Vsq0Do(PPrm(GFQrCCEdi)v8Ocd5KVVW793l8csPo7sJEtARmkC3ZPZDaQAKkvYXePfgfPyucYzpgmhsOfEpv4LHPua2mN)tEWwmOXPm(5RHzbPXU0DeCgWfbnetZXyu8ogf1EgUfMm3aN(EJ8hWoURttYZCIcxtqXmmW4cqXtYP7Y4kqUQdmMIdd4xm(P5LsZ9nmHpjpdfGjUzGr5R8B6h6bzPHyYSPe4VpFVFH3ZfEZ40SwpTdKhsAuudLccpeMGb6aCeJmpkRlAZgQkIFw(Ok4r9CF8eUqlr3(ims3fP02mkmBQn3akISftDcZCdWXmxwMjAZI5jbyuqL9n)6HUd7IicReeHBwdBLG)g1DpjmgrEZfr5gZ1mC16zrC7C44Qc3lCxN(zWw4DBB3e83sj(Hz8ROzMJDu5AYa7a21hI(G9j8Wq)VrkwOifY8dxsmh(6pn3dlCU38nH5yvd1U77RqnZr18IhSUoc8S7SfRrqJnPqS)exu6xpf3MJfOklxjp7keuLcYPs17qWXOWKmoQEOrk2aLbSRjSn7FHK7Bq5ruDPCRTkrrrUI)IlltTiFTROgLWKqADI2kiYZWUGgjoRvKUfYhAFAPbJ8j4Awg4PB24U1pGXvn3cqrseOafCaWo(4iCPNsFZ)CJCK(uIBmYNKkY6Sn6T97a9M)RPjW(oLWxLspalUajGALLmoipo(T605aErB3ssvnzqjbmDDnopsUSM0QDAWY762lxFtdjhMBn)4JgjvzWqCcooelmAKu6K8eJx((Gv4bCDUUEH96KU1LEH)g2pNc207GQg7hHlbrx2Z(aEzzMChG98QrxJS6cqAk(1fLtqIIIjH7fB)L0d441ycRCX5lAzYvEZvB5XUWOW)XreFlwX5Btyw1WkohrlRLXEceaYYWclkCEkfhPmqT3ZAjNNc5RSnBrzLLRcfCPiAa(qQgXvD5UcEmuIUjKGb))mWWJvJFlARDxRXeofwacWrTWdA32A0ItGjY2HG8tM5cd7BnSIn2aoDgZfxLvQw1P6dSOZVYGSHtoElR1NFHyIyrxu6yI4Ym12kH)cXfzGMNMdvDONtA2UZsSVeCtz3NAzLMot7Qaz(ycKZrU4HPs2D6MyGLAwVqTJrBYF9DAqh))2ej41Gp3rQHFBtMWuH4gB6FADzBwA8FhkogYgXixLCAo5WjkNDkFpixWCNtEXCq7l6iquMRH9rGyo0PvoYmTTeg8SKrn32N3ye0pyrMZKsXwAA3xRORQwhsmQXDfMs4SP4I3E8rMDZS0x7ynT2(0Vk1UAlDEtC6jw6UVHjvg0WP4AAqB8DG1BRFnxY3qhtY1HZ5O(AosfA5Ge0KpmDp31UbWkpl2NIYXCDK5(ZbgFXuXm8L0BsoLCew2xO8YAYP2nRuI(DqEwq3U3xyXnFQmruB3Ll7L9rFwvdWEsfusqN1cu)h7p9XKH)6hm9BJ9QIo45Au9NWxjzy2XQtS9IwxIL8Ew7lno9qvr19iZu5wYJ7zU5Csp0)K9p2ZSxk1p0oXBFRFyWI9zg(6o7dQ3CzjNP528(yUzPuLRs9awdWmO8v6mgVexxZC(zBdW3C0b7f0uNgTLNGupMYjBLDc(EMP9rZViJ5itxREye1MP9q6AIXsXqdSuoZ2VMBuAO2Vx4RQwffb6MdysgBRQVPgZDGSeGrjRmNSvl)u8(ucL9qfpuLJUWJ)1PWP4ZSHBNUjKvFYpu)D24xk8K)QC85Fq7xrdi3Fp(cLWHwD43fFgwKrTQXQx8zbBXm0lx6V88TThY9hc388n57hD8mJy7oY(eY1tIJhL9GiYXGBGmYZTEyuqgs9ixz(0dc5kqQh56ga9GOHoeyGu6MZ8WOLomONy6hN8GOMEuONCRBpZyZuQ6OJ6XqP7My8zdF2eJJLUjw94FpBcwJPUjQiM5ztrbAmyS0U9dg1oA2XpT4HPg8qBsTWGuoFWtDuNvzKYFx8c81ONftP1lU)bwNJpZ6qw(u1VYU8IIxvxEfdVA(hKEn6NNPaq7xUw9O8RJMrPv)o6Jm8g6JgBQ783F)g(7Mprr2vRSQ(6q5TWhz4DWFAUmQA9eWcTOOxBgAvR98LzDcAzN7hd7ZZgP)1S7eLmt0iCLPWNy3WqIAcSfuqIuma2DpGJkQiawQX9pWhaXZgv1JwmD6K3F)4XF0bjuKMsICud(pb92xkb)gx72GuH2wYpRCmfQEz8riCmmQD1Zazm8p6MBXpo15Jt(P5tN8IajMMtbOcgFm7)ma4KrJVX48iE)DtZI4L7MOHX1u43rbhg3VYeVDHoci3ybdZgMQGKFDdSY9UY9Lf9rp6glDqpQLVYCD4v1XTdUwZ2TgfWLI1L16V0xT(v)ADULRvTjtgBpBIEe20pb37PvRn1XdQBRzYrx0NM6dA)wh7u1jAT3)rnApACxTy)0VAT96jVOVX6tvoE8une6hf6c5rQvN1llLUk74cyLCgktrEI)MiVsdZuMOP7kYuZv0aMMKfNDa9gSF5UXVDUZ96OqROF2IQpfkCQPaSY3Y86Y1DI9wgQnNQ3PQg1lrYywMtGIN51qF542jTSLSsxXnVCxxsPL9p7CjnySprVB94JsbRn8WJMIxpurYUeDLzSHha9YXpNAS47QJfVSShKk5s0tYqJexdLUQ2nvZEFkz)cuyEnVDnciQh5TIhwFinT3M1XplQJA2L)tI6P71G9Eh6ZwOlt8Ah0Z82NGdRgKjh(PpUygcr1YX7I6vP1MBqX)VMC3cDCxpcQFv5jN71XvdpG61KjfblpIjv)50u6UjWxZV(N(AgQYMcBejpdgig)D(8YdRwY)f3(ptu(D6UAjcIFKswTCzoiZqyGm(JkT6)o]] )

spec:RegisterPack( "Protection 96", 20231124.1, [[Hekili:nRvBVTnos4FlflGBmUu5O8IBsrCwS7xU2Id5wuVa9BsIwI2MxLe9ksf3CWq)2VziTTOKOEXBsaUp0ABXHZ8WHZlpImEUE)P38iIK694LxC5vUUxETJ7hV6MlV1BU85nuV5BiH)GSc(skjb())iJlPHsgpTi4UP4WphZjrOAe88SqqK1s5gXNMmzftUoFHtipzYw(wblraFkJ)XKfX8ftsicjnBc84jBiXKiw6Knh19e4Be8loR4EZxKZILFj1BHDO(rW0BOHWJbBZIIOAjPIWQW9p0MPi4GYlcwYZkc(m9hSyMtrWVte0OIaCG9aUiiMVIfEomh6ssOKNHcOM1DtVBAPQ8MhZesHYnW(j8XJkplnLSiMg597EZdZyW6Lr8Md6H9e1NMstyuWepue4wemQiiKZJJ4BtDeRz04iF(s)m2Q1skpxKsfcNmAcHLct5(zfbNnGjeLNTFL(HIabvkzPReojSuFaL(r0yYZfbJ1qcxeRjjj0mupY10sD5jrNBBRNJOOLz3oSBBcNkSBz5JW(Q(H9)h6TLq6glL2DC07kcwKVCPZ(4PqEQGgQrGt(gveLLqTRkTV5m6ElMSAvgViy3UIGiQYOYmW3aRp)O8KKNb7zSS4Xp7R9rDVdCyberFcwS(BIPKdahC3RIFEZANiw5y7vIghGejKuIZgku0jvc7sg(CJzb(2mQaWemVXvC)gcH486EX5P5ODB3rFZjvBOupKNOPROzcdV70Uq9(9Q)tE0kAc4KQSnD8Pya4wMiINGk8JTQq9gsnmCytPtqE7lX1kLrk)W1QFvDp)bvCWXTDlljZT)jkLmU99L7AfNGvKKSvuPdtazYjysogfw(W80ikrhJPJFnbM4VYP0)l9ZqMX3bZT(GmhlPuzHFSWdS8M6C7n6axTbBeGmZWmQmVTObQe1xl1ujaUCDVO11B7PwD6J7n6YvvoZQqXy9pt4GI3rjjTJiIlDeKqOV8(4TIaWJCHrVbZb1LwJGE55XYURUQclfusSdUbnGKCuwCDa8DaVxu3fuhG2Nzv7QKlskWZ6qP1k5Dyfz9(Bvh51MsMlO(aqse1e6gtH2W1Fwrcv1gC68Ll9xfgHoWYGlGVygWed82KWqAmDFIvvvuV(YXCrsCSV(h(ixknJkFnRtKtvN1r2NhUg8sY1oBcL6U2xEHTUThtaQNVdPGQu9E70xsn4xhaDMJsBKjULWK1kW8Mz1QjWjKF6Jw3hOX6V3X2OsWG2vuuuuzuBYOqy)csp5ussm2fILam9Fcctocw)L5zp3Svs1X7oJc6KSVHHXkLLkH)5taIz6CmHGTkfdqHNaEizgBrUAXHpWWW1hPpEmNQPH69yPvDgsnJBzS(ONCYMplxqIGOMAwUYJ7KOYFdJc084wwUvFCFuAovJUKLbjfube1IvnRzBRJ2jjO)oqiJdPmTJbRd3hRPtfeI1eOAr7OOLX7KuuxWaKgSF6QQq5WtDo8fSS1pWzwIKMd1nvLxjuKOPFydf6HoYE5TefcW1lZjqXoRiPC4Ujh9kHM982ScfdoDTxzSKMtzVl4vqNErpeBCBVANwLMK6Q(I6Dq97r3kmCmFp1A0oN2lti32lr8MXD(2tH7SQV8taHmuA1jMDXTU344IupYs1PCF)3(2JF5X)5Nkckc(Z10IaOZmptU)eUEp2F)94rF9x5m1bFj4jGqKCjpHiXheUMa7AcNIVQM(sECmFRk2cREa7iBPzWZZvNRgE0Bsum9sOiaPsGV)N8GCPCLTHxLYu6Oiu4iIKSGiOFQ4RQZxX4qdGN81VOqoAMRRAaeCibf(swmWz5x(LIaBhk4xXbqVKJRRZLxJQuRfHZrYn)JztQYi5C2YzdJttlARgnduFVlFZi7v1h1n7f7MOjzItYinNElMXK5WPzbZzAx5vyiCskVYmTRCBuaojBytbTykBD6pnBztd2nM9g6NK1SRc7MRrx72T0brhnaAb9BmvZ5xSXuAPFJDS)7l2Gh1u)gv3b4fBrTAAjyPEty0AnAEFp04UL5B2PTCU26sF)Sw0Hr7y7cO7dBFmlTmryy2k((H1gEa6pwhSy0JWWfU)4FQ6aXxuFekB5b88GRTz3YgGL5pRY8RE4pMJC8WEmFynxj69TF4nNBCypvTy9tg4C8mbMjy)SIwREMl6(L1oPM7ND5fMZbpBIZf0WzNn0de5(FDOhgYyebVf69(wpEL(9zinlD0eYb53ud)H)LIBKIh20IG5qKyA0hMVHghdSQo7ZC53Maey)24YWvWwv84vakUURh)nAW(Hb4YoC3xFW(9E1aNTOheNd1PBcR(UjXHcRoCF96cEv9wTfmCxZGbcsxE7AI8949vtxknwvySLMf4XRxq1iPJlDPEDQRAOnJk1Q4k8Yb3TRTlgSX0nU3TsSu9oahDwR3(3UDNzVQU178B8RRVWTH2QDBx2YZAmNwAw9olxx3qSxN3l3lB5lLrpC9it)9dNnS2OtUUPNV82NuLHRDHA72v)Y0gp6SsRv)k0gDwNxE2d4fNnE8UD12nMDuH2USSMy(TGyHnvhxLa6ErAWRA)QPXTEn7cV54Bhh9VtR(h9Y078MdVW(AEM3855aItZf6)cd8(Fp]] )

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