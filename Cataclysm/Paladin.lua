if UnitClassBase( 'player' ) ~= 'PALADIN' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local paladin = Hekili:NewSpecialization( 2 )

paladin:RegisterResource( Enum.PowerType.Mana )
paladin:RegisterResource( Enum.PowerType.HolyPower )


-- Idols
-- TODO: Update for Cataclysm
paladin:RegisterGear( "libram_of_discord", 45510 )
paladin:RegisterGear( "libram_of_fortitude", 42611, 42851, 42852, 42853, 42854 )
paladin:RegisterGear( "libram_of_valiance", 47661 )
paladin:RegisterGear( "libram_of_three_truths", 50455 )

-- Sets
-- TODO: Update for Cataclysm
paladin:RegisterGear( "tier7ret", 43794, 43796, 43801, 43803, 43805, 40574, 40575, 40576, 40577, 40578 )
paladin:RegisterGear( "tier10ret", 50324, 50325, 50326, 50327, 50328, 51160, 51161, 51162, 51163, 51164, 51275, 51276, 51277, 51278, 51279 )

-- Hooks
local aura_assigned
local blessing_assigned
paladin:RegisterHook( "reset_precast", function()
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
paladin:RegisterTalents( {
    -- Holy

    holy_shock                       = { 20473, 1, 20473 },
    meditation                       = { 95859, 1, 95859 },
    walk_in_the_light                = { 85102, 1, 85102 },
    illuminated_healing              = { 76669, 1, 76669 },
    arbiter_of_the_light             = { 10113, 2, 20359, 20360 },
    protector_of_the_innocent        = { 12189, 3, 20138, 20139, 20140 },
    judgements_of_the_pure           = { 10127, 3, 53671, 53673, 54151 },
    clarity_of_purpose               = { 11213, 3, 85462, 85463, 85464 },
    last_word                        = { 10097, 2, 20234, 20235 },
    blazing_light                    = { 11780, 2, 20237, 20238 },
    denounce                         = { 10109, 2, 31825, 85510 },
    divine_favor                     = { 11202, 1, 31842 },
    infusion_of_light                = { 10129, 2, 53569, 53576 },
    daybreak                         = { 11771, 2, 88820, 88821 },
    enlightened_judgements           = { 10113, 2, 53556, 53557 },
    beacon_of_light                  = { 10133, 1, 53563 },
    speed_of_light                   = { 11215, 3, 85495, 85498, 85499 },
    sacred_cleansing                 = { 10121, 1, 53551 },
    conviction                       = { 11779, 3, 20049, 20056, 20057 },
    aura_mastery                     = { 10115, 1, 31821 },
    paragon_of_virtue                = { 12151, 2, 93418, 93417 },
    tower_of_radiance                = { 11168, 3, 84800, 85511, 85512 },
    blessed_life                     = { 10117, 2, 31828, 31829 },
    light_of_dawn                    = { 11203, 1, 85222 },

    -- Protection

    avengers_shield                  = { 31935, 1, 31935 },
    vengeance                        = { 84839, 1, 84839 },
    judgements_of_the_wise           = { 31878, 1, 31878 },
    divine_bulwark                   = { 76671, 1, 76671 },
    divinity                         = { 12198, 3, 63646, 63647, 63648 },
    seals_of_the_pure                = { 10324, 2, 20224, 20225 },
    eternal_glory                    = { 12152, 2, 87163, 87164 },
    judgements_of_the_just           = { 10372, 2, 53695, 53696 },
    toughness                        = { 10332, 3, 20143, 20144, 20145 },
    improved_hammer_of_justice       = { 10336, 2, 20487, 20488 },
    hallowed_ground                  = { 10344, 2, 84631, 84633 },
    sanctuary                        = { 10346, 3, 20911, 84628, 84629 },
    hammer_of_the_righteous          = { 10374, 1, 53595 },
    wrath_of_the_lightbringer        = { 11159, 2, 84635, 84636 },
    reckoning                        = { 11161, 2, 20177, 20179 },
    shield_of_the_righteous          = { 11607, 1, 53600 },
    grand_crusader                   = { 11193, 2, 75806, 85043 },
    vindication                      = { 10680, 1, 26016, },
    holy_shield                      = { 10356, 1, 20925 },
    guarded_by_the_light             = { 11221, 2, 85639, 85646 },
    divine_guardian                  = { 10350, 1, 70940 },
    sacred_duty                      = { 10370, 2, 53709, 53710 },
    shield_of_the_templar            = { 10340, 3, 31848, 31849, 84854 },
    ardent_defender                  = { 10350, 1, 31850 },

    -- Retribution

    templars_verdict                 = { 85256, 1, 85256 },
    sheath_of_light                  = { 53503, 1, 53503 },
    two_handed_weapon_specialization = { 20113, 1, 20113 },
    judgements_of_the_bold           = { 89901, 1, 89901 },
    hand_of_light                    = { 76672, 1, 76672 },
    eye_for_an_eye                   = { 10647, 2, 9799, 25988 },
    crusade                          = { 10651, 3, 31866, 31867, 31868 },
    improved_judgement               = { 11612, 2, 87174, 87175 },
    guardians_favor                  = { 12153, 2, 20174, 20175 },
    rule_of_law                      = { 11269, 3, 85457, 85458, 87461 },
    pursuit_of_justice               = { 11611, 2, 26022, 26023 },
    communion                        = { 10665, 1, 31876 },
    the_art_of_war                   = { 10661, 3, 53486, 53488, 87138 },
    long_arm_of_the_law              = { 11610, 2, 87168, 87172 },
    divine_storm                     = { 11204, 1, 53385 },
    sacred_shield                    = { 11207, 1, 85285 },
    sanctity_of_battle               = { 11372, 1, 25956 },
    seals_of_command                 = { 10643, 1, 85126 },
    sanctified_wrath                 = { 10669, 3, 53375, 90286, 53376 },
    selfless_healer                  = { 11271, 3, 85804, 85803, 85804 },
    repentance                       = { 10663, 1, 20066 },
    divine_purpose                   = { 10633, 2, 85117, 86172 },
    inquiry_of_faith                 = { 10677, 3, 53380, 53381, 53382 },
    acts_of_sacrifice                = { 11211, 2, 85446, 85795 },
    zealotry                         = { 11222, 1, 85696 }
} )


-- Auras
paladin:RegisterAuras( {
    aura = {
        alias = { "devotion_aura", "retribution_aura", "concentration_aura", "resistance_aura", "crusader_aura" },
        aliasMode = "first",
        aliasType = "buff",
    },
    blessing = {
        alias = { "blessing_of_might", "blessing_of_kings" },
        aliasMode = "first",
        aliasType = "buff"
    },
    seal = {
        alias = { "seal_of_truth", "seal_of_righteousness", "seal_of_insight", "seal_of_justice" },
        aliasMode = "first",
        aliasType = "buff"
    },
    defensive = {
        alias = { "holy_shield", "divine_protection", "divine_guardian", "ardent_defender", "guardian_of_ancient_kings"},
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
            if spec.protection then
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
            local holyPowerSpent = math.min(state.holy_power.current, 3)
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

    -- Strength increased by 1%. When your Guardian of Ancient Kings departs, you release Ancient Fury, causing 234 Holy damage, split among all enemies within 10 yards.
    ancient_power = {
        id = 86700,
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
    -- Next Holy Power ability consumes no Holy Power and casts as if 3 Holy Power were used.
    divine_purpose = {
        id = 90174,
        duration = 8,
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
    -- Your Crusader Strike generates 3 charges of Holy Power per strike for the next 20 sec. Requires 3 Holy Power to use, but does not consume Holy Power.
    zealotry = {
        id = 85696,
        duration = 20,
        max_stack = 1
    },

    -- Class Debuffs

    -- Holy damage every 3 sec.
    censure = {
        id = 31803,
        duration = 15,
        max_stack = 5,
        dot = "debuff",
        tick_time = 3
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
    -- Retribution Debuffs

    -- Incapacitated.
    repentance = {
        id = 20066,
        duration = 60,
        max_stack = 1,
    }
} )

-- Glyphs
paladin:RegisterGlyphs( {
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
paladin:RegisterAbilities( {
    -- Class Abilities

    -- Brings all dead party and raid members back to life with 35% health and 35% mana. Cannot be cast in combat or while in a battleground or arena.
    absolution = {
        id = 450761,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135951,

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
            local base_cooldown = 4.5

            if talent.sanctity_of_battle.enabled then
                return base_cooldown * state.haste
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

        startsCombat = true,
        texture = 135891,

        handler = function ()
            gain( 1, "holy_power" )
            if buff.zealotry.up then gain( 3, "holy_power" ) end
            if talent.vindication.enabled then applyDebuff( "target", "vindication" ) end
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
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
            if talent.shield_of_the_templar.rank == 1 then gain( 1, "holy_power" ) end
            if talent.shield_of_the_templar.rank == 2 then gain( 2, "holy_power" ) end
            if talent.shield_of_the_templar.rank == 3 then gain( 3, "holy_power" ) end
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
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
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

        startsCombat = function() if spec.retribution then return true else return false end end,
        texture = 135919,

        toggle = function()
            if spec.protection then
                return "defensives"
            else
                return "cooldowns"
            end
        end,

        handler = function ()
            applyBuff( "guardian_of_ancient_kings" )
            if spec.retribution then applyBuff( 'ancient_power' ) end
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
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
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
            if talent.tower_of_radiance.enabled then gain( 1, "holy_power" ) end
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
            if buff.divine_purpose.up then
                return 0
            else
                return state.holy_power.current
            end
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 461858,

        handler = function ()
            applyBuff( "inquisition" )
            if buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
                gain( -state.holy_power.current, "holy_power" )
            end
        end,
    },
    -- Unleashes the energy of a Seal to judge an enemy for Holy damage.
    judgement = {
        id = 20271,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
            if talent.judgements_of_the_pure.enabled then applyBuff( "judgements_of_the_pure" ) end
            if talent.judgements_of_the_wise.enabled then applyBuff( "judgements_of_the_wise" ) end
            if talent.judgements_of_the_bold.enabled then applyBuff( "judgements_of_the_bold" ) end
            if talent.judgements_of_the_just.enabled then applyDebuff( "target", "judgements_of_the_just" ) end
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
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
    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function()
            if buff.divine_purpose.up then
                return 0
            else
                return state.holy_power.current
            end
        end,
        spendType = "holy_power",

        startsCombat = true,
        texture = 236265,

        equipped = "shield",

        handler = function ()
            if buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
                gain( -state.holy_power.current, "holy_power" )
            end
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
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
    -- TODO: Overhealing with Guarded by the Light might need to be tracked here
    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = function() return talent.walk_in_the_light.enabled and 0 or 20 end,
        gcd = "spell",

        spend = function()
            if buff.divine_purpose.up then
                return 0
            else
                return state.holy_power.current
            end
        end,
        spendType = "holy_power",

        startsCombat = true,
        texture = 133192,

        handler = function()
            if glyph.long_word.enabled then
                applyBuff("long_word")
            end
            if talent.selfless_healer.enabled then
                applyBuff("selfless")
            end
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
            gain( 1, "holy_power" )
        end,
    },

    -- Protection Abilities

    -- Reduce damage taken by 20% for 10 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead cause you to be healed for 15% of your maximum health.
    ardent_defender = {
        id = 31850,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "ardent_defender",
        starsCombat = false,
        texture = 135870,

        toggle="defensives",

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
            if talent.grand_crusader.enabled then gain( 1, "holy_power" ) end
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

        toggle = "defensives",

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
            gain( 1, "holy_power" )
            if talent.vindication.enabled then applyDebuff( "target", "vindication" ) end
        end,
    },
    -- Increases the amount your shield blocks by an additional 20% for 10 sec.
    holy_shield = {
        id = 20925,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        talent = "holy_shield",
        startsCombat = false,
        texture = 135880,

        toggle = "defensives",

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
            local haste_multiplier = 1 + (min(state.haste, 100) / 100)

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
            if active_enemies >= 4 then gain( 1, "holy_power" ) end
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
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
            if buff.divine_purpose.up then
                return 0
            else
                return state.holy_power.current
            end
        end,
        spendType = "holy_power",

        talent = "templars_verdict",
        startsCombat = true,
        texture = 461860,

        handler = function ()
            if buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
                gain( -state.holy_power.current, "holy_power" )
            end
            if spec.retribution and buff.guardian_of_ancient_kings.up and buff.ancient_power.stacks < 20 then addStack( "ancient_power", 1 ) end
        end,
    },
    -- Your Crusader Strike generates 3 charges of Holy Power per strike for the next 20 sec.  Requires 3 Holy Power to use, but does not consume Holy Power.
    zealotry = {
        id = 85696,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "zealotry",
        startsCombat = false,
        texture = 237547,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "zealotry" )
        end,
    }
} )


paladin:RegisterStateTable( "assigned_aura", setmetatable( {}, {
    __index = function( t, k )
        return settings.assigned_aura == k
    end
}))

paladin:RegisterStateTable( "assigned_blessing", setmetatable( {}, {
    __index = function( t, k )
        return settings.assigned_blessing == k
    end
}))

paladin:RegisterStateExpr( "ttd", function()
    if is_training_dummy then
        return Hekili.Version:match( "^Dev" ) and settings.dummy_ttd or 300
    end

    return target.time_to_die
end )

-- Zealotry and Inquisition optimizations for Retribution
-- Returns the expected amount of seconds until we want to use Zealotry
paladin:RegisterStateExpr( "time_until_zealotry", function()
    local time_until_zealotry = cooldown.zealotry.remains
    if buff.guardian_of_ancient_kings.up and not buff.zealotry.up then
        time_until_zealotry = buff.guardian_of_ancient_kings.remains - 20
    end
    return time_until_zealotry
end )
-- Returns time time it would take to get to 3 holy power if intend to use another spender first
paladin:RegisterStateExpr( "time_to_generate_holy_power", function()
    local needed_holy_power = function()
        if holy_power.current > 0 then
            return 3 + 3 - holy_power.current
        else
            return 3
        end
    end
    return needed_holy_power() * cooldown.crusader_strike.duration
end )
-- Returns the time it would take to get to 3 holy power from zero
paladin:RegisterStateExpr( "time_to_three_holy_power", function()
    return 3 * cooldown.crusader_strike.duration
end )
-- We want to use Zealotry 20 seconds until Guardian of Ancient Kings expires
-- We don't want to spend Holy Power if we're about to use Zealotry
-- Returns true if it's safe to spend Holy Power before Zealotry is ready to be used
paladin:RegisterStateExpr( "can_spend_holy_power", function()
    -- Only consider waiting for Zealotry if cooldowns are enabled
    -- TODO: It's probably better to also consider if the player has disabled Zealotry in their custom settings as well
    if toggle.cooldowns then
        if time_to_generate_holy_power <= time_until_zealotry then
            return true
        else
            return false
        end
    else
        return true
    end
end )




paladin:RegisterSetting( "paladin_description", nil, {
    type = "description",
    name = "Adjust the settings below according to your playstyle preference. It is always recommended that you use a simulator "..
        "to determine the optimal values for these settings for your character."
})

paladin:RegisterSetting( "paladin_description_footer", nil, {
    type = "description",
    name = "\n\n"
})

paladin:RegisterSetting( "general_header", nil, {
    type = "header",
    name = "General"
})
paladin:RegisterSetting( "maintain_aura", true, {
    type = "toggle",
    name = "Maintain Aura",
    desc = "When enabled, selected aura will be recommended if it is down",
    width = "full",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.maintain_aura = val
    end
})
local auras = {}
paladin:RegisterSetting( "assigned_aura", "retribution_aura", {
    type = "select",
    name = "Assigned Aura",
    desc = "Select the Aura that should be recommended by the addon.  It is referenced as |cff00ccff[Assigned Aura]|r in your priority.",
    width = "full",
    values = function()
        table.wipe( auras )

        auras.devotion_aura = class.abilityList.devotion_aura
        auras.retribution_aura = class.abilityList.retribution_aura
        auras.concentration_aura = class.abilityList.concentration_aura
        auras.resistance_aura = class.abilityList.resistance_aura
        auras.crusader_aura = class.abilityList.crusader_aura

        return auras
    end,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.assigned_aura = val
        class.abilities.assigned_aura = class.abilities[ val ]
    end,
} )
paladin:RegisterSetting( "maintain_blessing", true, {
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
paladin:RegisterSetting( "assigned_blessing", "blessing_of_kings", {
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
paladin:RegisterSetting( "divine_plea_threshold", 75, {
    type = "range",
    name = "Divine Plea Threshold",
    desc = "Select the maximum mana percent at which divine plea will be recommended.",
    width = "full",
    min = 0,
    max = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.divine_plea_threshold = val
    end
})
paladin:RegisterSetting( "mana_judgement_threshold", 50, {
    type = "range",
    name = "Mana Judgement Threshold",
    desc = "Select the maximum mana percent at which judgement will be prioritized for Judgements of the Wise / Bold.",
    width = "full",
    min = 0,
    max = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.mana_judgement_threshold = val
    end
})
paladin:RegisterSetting( "single_target_consecration", false, {
    type = "toggle",
    name = "Consecrate Single Target",
    desc = "Enable to recommend Consecration filler for single target.\n\n"..
    "WARNING: This uses a lot of mana! It will only recommend above 70% mana.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.single_target_consecration = val
    end
})
paladin:RegisterSetting( "ignore_consecration_movement", false, {
    type = "toggle",
    name = "Consecrate While Moving",
    desc = "Enable to recommend Consecration even while moving.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.ignore_consecration_movement = val
    end
})
paladin:RegisterSetting( "general_footer", nil, {
    type = "description",
    name = "\n\n\n"
})

paladin:RegisterSetting( "retribution_header", nil, {
    type = "header",
    name = "Retribution"
})
paladin:RegisterSetting( "divine_storm_threshold", 8, {
    type = "range",
    name = "Divine Storm Threshold",
    desc = "Select the minimum number of enemies before Divine Storm will be prioritized higher than Inquisition.\n\n".. 
        "Recommended: 8",
    width = "full",
    min = 4,
    softMax = 10,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.divine_storm_threshold = val
    end
})
paladin:RegisterSetting( "seal_of_righteousness", 4, {
    type = "range",
    name = "Seal of Righteousness Threshold",
    desc = "Select the minimum number of enemies before Seal of Righteousness will be prioritized higher.\n\n"..
        "Recommended: 3",
    width = "full",
    min = 2,
    softMax = 10,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.seal_of_righteousness = val
    end
})
paladin:RegisterSetting( "selfless_healer", false, {
    type = "toggle",
    name = "Selfless Healer WoG",
    desc = "Enable to recommend World of Glory to get Selfless Healer buff.\n\n"..
        "NOTE: This is NOT optimal DPS, it is for healing support efficiency.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.selfless_healer = val
    end
})
paladin:RegisterSetting( "zealotry_macro", false, {
    type = "toggle",
    name = "Zealotry / Avenging Wrath Macro",
    desc = "Enable if you've combined Zealotry and Avenging Wrath into one macro.\n\n"..
        "This will turn off recommendation to cast Avenging Wrath.\n\n"..
        "Avenging Wrath will be recommended instead if the Zealotry talent is not learned.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.zealotry_macro = val
    end
})paladin:RegisterSetting( "zealotry_save", false, {
    type = "toggle",
    name = "Save for Zealotry",
    desc = "Enable if you want Holy Power to be saved for Zealotry when it's going to be recommended soon.\n\n"..
        "This setting will enable prediction for how long it will take to rebuild 3 Holy Power and hold off on spenders if needed.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.zealotry_save = val
    end
})
paladin:RegisterSetting( "retribution_footer", nil, {
    type = "description",
    name = "\n\n\n"
})

-- TODO: Are these options still need for Cataclysm?
paladin:RegisterSetting( "protection_header", nil, {
    type = "header",
    name = "Protection"
})
paladin:RegisterSetting( "defensive_threshold", 60, {
    type = "range",
    name = "Defensive Threshold",
    desc = "Select the health percentage to recommend defensives.\n\n"..
        "It is recommended to place this higher than the Major Defensive Threshold to avoid overlapping cooldowns.\n\n"..
        "Defensives: Holy Shield, Divine Protection, and Divine Guardian if enabled.",
    width = "full",
    min = 0,
    softMax = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.defensive_threshold = val
    end
})
paladin:RegisterSetting( "major_defensive", 20, {
    type = "range",
    name = "Major Defensive Threshold",
    desc = "Select the health percentage to recommend using major defensive cooldowns.\n\n"..
        "Major Defensives: Lay on Hands, Guardian of Ancient Kings, Ardent Defender.",
    width = "full",
    min = 0,
    softMax = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.major_defensive = val
    end
})
paladin:RegisterSetting( "wog_threshold", 90, {
    type = "range",
    name = "Word of Glory Threshold",
    desc = "Select the health percentage to recommend Word of Glory instead of Shield of the Righteous.\n\n"..
        "Guarded by the Light talent will give you a shield equal to overhealing.",
    width = "full",
    min = 0,
    softMax = 100,
    step = 1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.wog_threshold = val
    end
})
paladin:RegisterSetting( "captain_america", false, {
    type = "toggle",
    name = "Captain America Mode",
    desc = "Enable if you want to prioritize Avenger's Shield for Grand Crusader.\n\n"..
        "This will put Avenger's Shield before other abilities for more reset chances.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.captain_america = val
    end
})
paladin:RegisterSetting( "use_guardian", false, {
    type = "toggle",
    name = "Divine Guardian Defensive",
    desc = "Enable to include Divine Guardian as a recommended defensive.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.use_guardian = val
    end
})
paladin:RegisterSetting( "ranged_opener", false, {
    type = "toggle",
    name = "Ranged Opener",
    desc = "Enable to recommend pre-pull casts for maximum snap threat.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 2 ].settings.ranged_opener = val
    end
})
paladin:RegisterSetting( "protection_footer", nil, {
    type = "description",
    name = "\n\n\n"
})

if (Hekili.Version:match( "^Dev" )) then
    paladin:RegisterSetting("pala_debug_header", nil, {
        type = "header",
        name = "Debug"
    })
    paladin:RegisterSetting( "pala_debug_description", nil, {
        type = "description",
        name = "Settings used for testing\n\n"
    })
    paladin:RegisterSetting( "dummy_ttd", 300, {
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
    paladin:RegisterSetting( "pala_debug_footer", nil, {
        type = "description",
        name = "\n\n"
    })
end


paladin:RegisterOptions( {
    enabled = true,

    aoe = 2,

    gcd = 21084,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    -- TODO: Update for Catalcysm launch
    potion = "speed",

    package = "Retribution (Himea Beta)",
    usePackSelector = true
} )


paladin:RegisterPack( "Retribution (Himea Beta)", 20240516, [[Hekili:TR16oUTnw4NLbfW1UBQRVmZK0c7aSj5hnbBlcQ6VLeTeTnB0fxskp7SWqp77HuwuusKs2J9K2uemymSfp35HFNdjL7u3F31jeXXU)6SjZUDYDtVF8KzZNC7uxh(J7WUo7qbFcTb(sckg(83WCkzvgNKMK7p8NjXyuU)BWC0ibPpgLIcfIKLMrdaYDiXzrib1VLIwZZ93F78zF)mxNvzKi(7tCxzq9Z(Xz3bIyhoaESRZwsyiUGsmlW1533sy5(I)bvF08Y9txd)oOWUIimom86uAU)pJ)ejImgSoA6AseytFtU)hrrOqsYpL7R7pFagr6rFlRWNY9)3F8)K7)95(VJWcsPHadBfemMHi8ujd)c6XCFHXN)b43cztXbPXRq88puypSX7kF0)A5pqRuOhkJIEbz9YBwLTE9yXVgNTBadZ5KKnSXXisch(xs3aeJr2KGdL)ACtXywzbPjb4eofDPQRTGSOqAgdfIPxKU0LHz1eI3NEPUunzyBUIbzsiW1Vef1qkMv1QimWuYgV01EFsiYkLvoKzfwoALsv03sM9R6yYMT8RSQLY0SQzyuKGeonJVvOwPwfpfIAc9WwmFYel5aK9KeS3UiSCIjgLGgVdtfPPlu2QgrE8TWmX20OqZY7pYc3GJbUlxi)o8AuwuLLlsVrrrEf)0taY8cbO4sscPgvzmShHJJz6pCxAbgt1t2c4RuaLtKNeeGJWfRUEHG901R92eeUCQod0SK2kpaCT9yreqm0EShobhtWSx3pRIjOiCP7(EHxaiJuyioyyvrjH)bYypIsqWeBbZCah0JN6fsWVypkkdVCyiwo9bOeahWCFywC8JIuhyoC0HdCeDdMpwJXsv)wPpuPWcFsl)GksHWPzSeiTQwEsRrhhM(qYGgXILQecJ8yqZQSbH2gAo5s8upfHv5xJginp1imzk(wS3kyqP9zqHBYq0qckrqlGvqesubeeKcCc8n()bMFkN(OA5X0jgKvjv1tLuXnRQsj1zthme8Kh92L(aMUC(HdsglxnLr3LYWWm7Obr494OLV6UZYkohzVWOSHpt2iYXEaw0S1GgKYufTGCWButBLp1lgfqtHeZB4OiiguroorKNh2xAX5Lv8uskoguy8uASHL4lBIZjj0eqNsIKK)mJWisGgvCs7Hsl5WHHLRsfYc7vnF9DtgF)9JEDl2oM5m6uZBgga5Fa4xsOMWHPI2ZsmWWhzWtEa6hted3eLc5yvycrRJuWaNOXOHouWT3wq7y6vWkBodwjMfZBHsDRbbaDEXWbhlniMXu6gk5MsXE6e4fNUxMDb2i8vGSrdo2XsHQ0jwSQOHfy0akBhJbDC(jCpoXctIaQfUlcrzE7XaWtaVkZR1KXHd6tzxJ8KpRbWz9HzuhxsMKQhnnWo()MsdiSyf3cqdeLlY9FarbJWatBrXXWuMGejazjV1XnLX7JLLfz8Wt2fWx0Rtarqa2kjJbfZX0PZ9MTlWlg6GbpOfUBpExJSltUIqasZ1(YRNutGf9E4CSjOsrx0uu39MEeJSJMqALzSC6id64ZvxgkfEf6YqjR)s7Y4eSIZr2lmk7pZDzO0BpqU9LiDYymk2)IVRaLN836Ucuw5Fffevk)CkOOy6YkOyc(4kxrX2Iht(IHkkQbVKkkTTLN1Ep0TTx)YjAjSs97vmruJnxhiJJj(I6axDDGjDX(1zUoVpExkLdys(3140uhN)bxheujmL66ipKuxh5aYt7vQp4B)Q88KpcS5(gxNakHJPeK4aF1REM7F4qU)WC)oRHM7pOWmQQJM7Vm3FAU)iWAck8OAfQD5IZm2MrakupOL7Vi3V3cTGYKgsFLBRSifrcRzUvRXA9wPDnDsLaTwlvOGB7oM3BDyP2Mnv6JqaQA5LmwpVyQYm4uzOrwdvs(RURYQlDlxhTkNICeWOVRR5OlWewC6MW9DzcnrDK64gTSL613LwHWibsSuNVYOQJzAY0EPvttp0a(68kP2a3tiMx1DMrTweKoODPxlL(h7nY1S3b16DBDqK7)D5(IUiKrYxBqmQS1rxsMkWMPcOQjpZLrRH3OzuIGbSoThmpTEpUet3w)ixl)QwRtspZoA(q7gRqHTDVRw0VzRtsd1oIV5gCQexzZqsXyhQ2CVof2DR(Dkau1GVB08Kux2rTT3luvzOMitN4c3PsyxBigAMJG271PTQNPMKzhRYEPwJ9pvPmTHLQWoo2qnH2vlvQmSIgRkZhV5y40CdwssQ7eaW0lN0y1yhnBPI06pvmt4ewC5sM6zsXuJlBQOHlVI7HxCNmQEDk5qDXtnMJMRtuXfr1Gcz2yJ6qvZ9MVOQgIWEf9MDWbbrnP34QPQ5LfNZJPI1Nc3hBlvgVv30xxr8MxQEXBCaLSRyy1v9R7CQuOIReUEUrTRfUOB2oVf)U7E9Iuv7BWVw6zZX6SX1lZq0VEFdGrLQ3oa5fP(Ax7VgKtTh3z68fP(gVma65E1hOZgulnHvv3pVfZOKI6MYkRVIavgu7H6SX0Nfts(Qdy2KkgQ)MC1FzckQnorRYCR9oAV12Rw1Sj6OXvLNRHMYvyFN2MQBV7zv3MTqFxwRvsd82o8uF4VUf7VUf7tZe(ICl2pL03NEURD4Rox4A(c)Bb6ihVBCTVULDdiQ)dCl7n3IO1Id3AplQJnA)8VtmdBJ4wRBXQRnZFsrIf1LE7dxRJDW)3SthPZcbF(N0M1XKM9cg1RwCUNyzhNsXzDcr90S55Dcrv6W0bezhX(z8aIMvR50UpGOzt1P16benZoMXvQLA(XJdXqRYP7KHRkolFjwfFlkdlxcy79wvg4eV)XLDE0(nyvkWJh3G(J5Q)C))]] )

paladin:RegisterPack( "Protection (Himea Beta)", 20240502, [[Hekili:TR1wVTTnu4FlfdWlbl1XxsCxkCkWslWAdw7kGlqFZs0s02SrsuJKkEbWq)23Hu3iLjvIDU8Y6lbo8Y57WdjpFNpcnF48VnFwisGN)LrdgD2GZhmQ)WZhC(4rZNjUlfpFwkk4g0k4hjOy4VFLrf4abHMK7FXez33frrHsZWPzSayiRfIu(Bp90n0nIfb9xT60aKaDAqeIZF9QmsiMFAATzEDkkcfssoD(SfzKiXNsMVyxx6SZV48HaeP4aOzadsyiUyKyEGPB91cdM7dTHkAAjLL7)r8nKis)C)RqCCyUVSdWh5KyEUFeDfj4eyo4LOabLjhGAwxm5IjnMA(SicxWvlxsYQim8RVOcI4e0IiC48RMplGreygbbUjgfjw3pfdbMerU)0CFowiGzY7hJ(bL5fIxIt4KBH4gkOeb0DE0eV1OKq(CHC5(ey(C)E5(lYwUSpIbrorrpHyw)q6MKgWxLb9tqjE0LEOKaICO3inO0tg)06joXQLp1YJLEYzhKNu7dEI1mmFnnkSXBQ7Sf6WOUZJVMGJcLiF(lhYHKBjjyVM7ks8N8CJVQ96jMXXEv7t74z1Da(1BC6xkm4GZ1A5jBsU1lyzI1st87stuVPFlozf4cEByiOBntdJ8cNGv74bOubIK4bzTyKauldJzCT90HdChuL7(P0nyivWL5(dY93Un3pgLGCeOl3ZIWOMq9UBPq3kG7i1HjWJvBlDTfVHUYgIBOSqzuEveLDNcZoYN0ctT9kvSsTBTg7XiRwlW0mvsHHDKvqZEtnSxalJJG7YECbJCdwzNZ2z7xBxYC)FO7BHceBfw0VksfueLgnq7cnkgotixlfhTK2BIo2)ilCfogcWTr9n6JkGMWXbSsAbZbACswffSCkwijVwIYIe2irQHbff5v8pEsUNcgiVc2yscrutrund5vwiAeZB5vJ1huk1IFR2bKtNUeoWeek9QMLbuoadiGXHG7eGJWwx6U3yK2bY)GtWXemW4(UCFnRZYsCUkdGBl3ITL87Hm7sEAv8oLHdOXlqDgXRpD7TmdUYOQWGrsl68ZO7KNMgD2oz4mNwrUUozVFvfHCgd1pl1mVBmK7Qi)f0RQlO6jYQez0xoEggU4SitTKLnO5(T7PtI7hLtaxbK5Hkoi0YnS0xN82pohPkDslFWO5opD(OGpeFl1siWS5o5UFuWd58HJ7qfu4Doky2rN00vUa0dxENXTBunctxPEEv)qMHTO0XAhA3UQO9F5CPy59u7UurxDwFrtXmmSeDEbZ2KYcdEW160rjhhb88TiopOQoY9p2mAXqaLkqINc5GzhsnjhvUajj)tgHtKtVSKX61UEx6rOjvEJ16AUpxuZQnLW0jvwhvLCFG1QYZ6stoiJH)xklGWJVNQwUpZyROv3ztSBnMTkCu0ILeS)uk7b7j)uk7)lKYUhNnCFjWnF3dM94c98FDQu(NsBVpPTT5wmKj1Ov0u3BRG8ElDvRkzNIin0K6sezlrPoKUkkLkAjdpnvXx0yIBrqad6v(ROmSI1peRoAcvZdMboPfMfhFxv1yJhmqrUlp9uQ(wqIHRNuVqIYmSsPy6nxs9CleOKWkFR3Xdho6S(GOWniwsrHJFkoLYeYhJ9COUoLhM7REc2(5xl1ZrxsKU6Vu)SVVf(vZJbFn0Xhbur)kugYvybu(8F81)k3)15(FGWdGdqW4xlhqFoIiOQj8zAizjr9cWmACU)3PF)Bx9(C)3JKZ)pvVGTYeh4lDxasLqY8RH)x6)vAtZVUyHY7xlx93U8ut5LNqwEPlvNoMFlzHsl8kDnh9SR3Ox36oTd2UI)oq421qoauxP3HILUnSdJHIUdegdB4AVYq32bculRyhQfTvK1a2IgvxwaSQ3EpabG3p0kLxpXqRSPDOniuRVlPlRBkiPB7wtczhNjA49Kw6OgMMPJ3UvNoDA3uPh3ZED72HvJ2sbRvHzLRalIYMo54EnE6LJ3lSluCzVpZQrKU2(y5k5s778AX5UVtVM209ezv5P)qXB2wBiz2NwVr7js6UlLmU6JQ(Dz1BSvOeAXX7SEI27YE5q9j06XplaVqsNC5i7Q5DxF39p1IhmTA5(j5QaixzqxqTuA3LLRpWgv1lumznk(tu1pC5rUkEOhu4WXB3UBjdvq)E1AObWI1eaPEf1YLOzTJtDkxBxl5u32Ey2Eo1IAbWwdBVHPBHMwautZxxGzrvvpBkQ2fGDK29Sct16)jaKEwvg(SECRdEhxNxmsN2r4VK(rlN(G9I9XIPn0x1Y4J75kkyiwZIvBrCPBtBhFTlaZvKQHcWYi0fB56MIRWCndrvYPzQSKvJREtFpZPC(GgSkY7(uCER2s7JR8ysVvd4lv6TAaFUsVvdWZB6T2W8cMERg6hCsPMDzhjLmhGJYXA9Hz0ri)PlLwTPFstP1ebT)1r4o9w9mB9DqyoJP2MHZ0Cnxjm)(gK2CNpkIPJSL4rlj3UEQ1KNM3dlFFQfYVVU)oX8RYBYfZNHGdyu28zQxKr9(pZ)V)]] )

-- TODO: This needs updating for Cataclysm
-- paladin:RegisterPack( "Holy Paladin (wowtbc.gg)", 20221002.1, [[Hekili:vA1YUTToq0pMceKG2kl5Mw3CrCw0vnErAbua6ozrjowIxtrkqsz3ayWV9ouQrMsrooDtc9WZCMhCMJDsuYJjXuIbsEyE485rHHZdIwm)MWRtInpvdjX1K8TKc8GGuH)97s(t20Fs4ektytVCVCVjlpOO4kh0N4sc1rPw2OYr4LgtT()MnRhgEYW3olNt06pw0WOGEwjY5hR7OCwsCwdJBUxKKnvM95imZ01qoAgPNrPqhsqNNe)yjtBtRvmPIzW809PmIgO2ujMTMsWM2Nk20FPiMsBABAeKeZzAJUTHaBinCdE8H2geiizCGM8TK4CKyqXijXKCdBhSMknbzajxkwl3SMZkkn20L20WoesbwqdVoX4Y9trBwZMnbAGWdOY9IJK4m5OypttLvoo(0j5WqufGjGI1drKJ18T20OqB6f20kIGeud4JJW0AFHxI()n0cOcVzyGU2fOjX0vpEjbI(ZVLoMMKRa6ADjd40X9Rbx6O8l(jazhikyII17DVEJc(cFKu2oMawZ48MkMG0zCa8Vob8Aoqgb7gFy1Yjikk0hsJgJQbQ0Jrfnr82q2jvJbo3hOB)a7gY8TJH9Voc41JBBUU3qL7neKnAbO1TSE95EbbbuXaC36oK02XQZfoC(xd5QU3axmo7uYlJXL9HHPxtHk3g9Hd(gBeuGGJtxnQ31nP4c7Gjj43svotxnSRIZZ1kixwLroQa8SlkWOyznUpSM0OgpOCM1A0SwJJUJwTF2S71yl(F9RVD)wPQFbUTM2bkTdsVAAs8EIs0gU47RQLkJtMCUnTJlBARCyGDLRFi3W4OC(7ENnD43aSYzcD6h5gzgOWZi92v2vDSOd67LVF5muZNviWvBxRBAiVOx8b2MLVSIpVZDv)P8U3FNxdLNDUCAT9LH(UouuUpy9Y3(yNqC15WOnNBJcVWxJ(2fHNKKUVSXpD8fohvhdUByvmur1)MjuqN4ANIPV5ofsFl9cIt4DR(NV9JYDdQTPfSMUf67OV0Jxp5V6l3fDXR7(rbKjD(Yrsshomwo6kF2ok5qAmLoD)(Fos7AAYFc]] )


paladin:RegisterPackSelector( "retribution", "Retribution (Himea Beta)", "|T135873:0|t Retribution",
    "If you have spent more points in |T135873:0|t Retribution than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )

paladin:RegisterPackSelector( "protection", "Protection (Himea Beta)", "|T135893:0|t Protection",
    "If you have spent more points in |T135893:0|t Protection than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

-- TODO: This needs updating for Cataclysm
-- paladin:RegisterPackSelector( "holy", "Holy Paladin (wowtbc.gg)", "|T135920:0|t Holy",
--     "If you have spent more points in |T135920:0|t Holy than in any other tree, this priority will be automatically selected for you.",
--     function( tab1, tab2, tab3 )
--         return tab1 > max( tab2, tab3 )
--     end )