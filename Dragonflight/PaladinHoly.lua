-- PaladinHoly.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 65 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    afterimage                      = { 81613, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness
    aspiration_of_divinity          = { 81622, 385416, 2 }, -- Your Crusader Strike now also grants you 1% increased Intellect for 6 sec. Multiple applications may overlap.
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage, healing and critical strike chance by 20% for 20 sec.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yards, causing them to wander disoriented for 6 sec. Non-Holy damage will break the disorient effect.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    divine_purpose                  = { 81618, 223817, 1 }, -- Holy Power abilities have a 15% chance to make your next Holy Power ability free and deal 15% increased damage and healing.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for 4 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 64 every 0.9 sec.
    hallowed_ground                 = { 81509, 377043, 1 }, -- Consecration's damage is increased by 10%.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    holy_avenger                    = { 81618, 105809, 1 }, -- Your Holy Power generation is tripled for 20 sec.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection by 60 sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 483 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next 25 successful attacks against the target to heal the attacker for 48.
    obduracy                        = { 81627, 385427, 1 }, -- Speed and Avoidance increased by 2%.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- When you reach 5 Holy Power, you gain Blessing of Dawn. When you reach 0 Holy Power, you gain Blessing of Dusk. Blessing of Dawn Damage and healing increased by 9%, and Holy Power-spending abilities dealing 8% additional increased damage and healing for 20 sec. Blessing of Dusk Damage taken reduced by 4%, armor increased by 10%, and Holy Power generating abilities cool down 10% faster for 20 sec.
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_wrath                = { 81620, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage, healing and critical strike chance by 20% for 20 sec.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by 2%.
    seal_of_clarity                 = { 81612, 384815, 2 }, -- Spending Holy Power has a 5% chance to reduce the Holy Power cost of your next Word of Glory or Light of Dawn by 1.
    seal_of_mercy                   = { 81611, 384897, 2 }, -- Golden Path strikes the lowest health ally within it an additional time for 50.0% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- During Avenging Wrath, your Mastery is increased by 4%.
    seal_of_order                   = { 81623, 385129, 1 }, -- In the Dawn, your Holy Power-spending abilities deal 8% increased damage and healing. In the Dusk, your armor is increased by 10% and your Holy Power generating abilities cool down 10% faster.
    seal_of_reprisal                = { 81629, 377053, 2 }, -- Your Crusader Strike deals 10% increased damage.
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your attacks have a chance to cause your target to take 3% increased Holy damage for 5 sec.
    seal_of_the_templar             = { 81631, 377016, 1 }, -- While mounted on your Charger or under the effects of Crusader Aura, the ranges of Crusader Strike, Rebuke, and Hammer of Justice are increased by 3 yards.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by 1 sec.
    seraphim                        = { 81620, 152262, 1 }, -- The Light magnifies your power for 15 sec, granting 8% Haste, Critical Strike, and Versatility, and 12% Mastery.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 403 Holy damage or healing an ally for 544 health.
    turn_evil                       = { 81630, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Divine Protection, and Lay on Hands by 30%.
    zealots_paragon                 = { 81625, 391142, 1 }, -- Hammer of Wrath and Judgment deal 10% additional damage and extend the duration of Avenging Wrath by 0.5 sec.

    -- Holy
    aura_mastery                    = { 81567, 31821 , 1 }, -- Empowers your chosen aura for 8 sec.
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- Learn Retribution Aura and Crusader Aura:  Retribution Aura: When any party or raid member within 40 yards dies, you gain Avenging Wrath for 12 sec. When any party or raid member within 40 yards takes more than 50% of their health in damage in a single hit, you gain Seraphim for 4 sec. This cannot occur more than once every 30 sec.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yards.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yards are 30% shorter.  Devotion Aura: Party and raid members within 40 yards are bolstered by their devotion, reducing damage taken by 3%.
    avenging_crusader               = { 81584, 216331, 1 }, -- You become the ultimate crusader of light for 12 sec. Crusader Strike and Judgment cool down 30% faster and heal up to 3 injured allies for 250% of the damage they deal. If Avenging Wrath is known, also increases Judgment, Crusader Strike, and auto-attack damage by 30%.
    avenging_wrath_might            = { 81584, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage, healing and critical strike chance by 20% for 20 sec.
    awakening                       = { 81592, 248033, 2 }, -- Word of Glory and Light of Dawn have a 15% chance to grant you Avenging Wrath for 8 sec.
    barrier_of_faith                = { 81558, 148039, 1 }, -- Imbue a friendly target with a Barrier of Faith, absorbing 3,874 damage for 12 sec. For the next 24 sec, Barrier of Faith accumulates 50% of effective healing from your Flash of Light or Holy Light spells. Every 6 sec, the accumulated healing becomes an absorb shield.
    beacon_of_faith                 = { 81554, 156910, 1 }, -- Mark a second target as a Beacon, mimicking the effects of Beacon of Light. Your heals will now heal both of your Beacons, but at 30% reduced effectiveness.
    beacon_of_virtue                = { 81554, 200025, 1 }, -- Apply a Beacon of Light to your target and 3 injured allies within 30 yards for 8 sec. All affected allies will be healed for 50% of the amount of your other healing done. Your Flash of Light and Holy Light on these targets will also grant 1 Holy Power.
    bestow_faith                    = { 81564, 223306, 1 }, -- Begin mending the wounds of a friendly target, healing them for 2,875 after 5 sec. Generates 1 Holy Power upon healing.
    blessing_of_summer              = { 81593, 388007, 1 }, -- Bless an ally for 30 sec, causing their attacks to have a 40% chance to deal 30% additional damage as Holy. Blessing of the Seasons: Turns to Autumn after use.
    boundless_salvation             = { 81587, 392951, 1 }, -- Casting Flash of Light on targets affected by Tyr's Deliverance extends the duration of your Tyr's Deliverance by 2.5 sec. Casting Holy Light on targets affected by Tyr's Deliverance extends the duration of your Tyr's Deliverance by 5.0 sec. Tyr's Deliverance can be extended up to a maximum of 50 sec.
    breaking_dawn                   = { 81582, 387879, 1 }, -- Increases the range of Light of Dawn to 40 yds.
    commanding_light                = { 81580, 387781, 2 }, -- Beacon of Light transfers an additional 10% of the amount healed.
    crusaders_might                 = { 81594, 196926, 2 }, -- Crusader Strike reduces the cooldown of Holy Shock by 1.0 sec.
    divine_favor                    = { 81570, 210294, 1 }, -- The healing of your next Holy Light or Flash of Light is increased by 60% and its cast time is reduced by 30%.
    divine_glimpse                  = { 81585, 387805, 2 }, -- Holy Shock has a 5% increased critical strike chance.
    divine_insight                  = { 81572, 392914, 1 }, -- Holy Shock's healing and damage is increased by 5%.
    divine_protection               = { 81568, 498   , 1 }, -- Reduces all damage you take by 20% for 8 sec.
    divine_resonance                = { 81596, 387893, 1 }, -- After casting Divine Toll, you instantly cast Holy Shock every 5 sec. This effect lasts 15 sec.
    divine_revelations              = { 81578, 387808, 1 }, -- While empowered by Infusion of Light, Flash of Light heals for an additional 10%, and Holy Light refunds 1% of your maximum mana.
    divine_toll                     = { 81579, 375576, 1 }, -- Instantly cast Holy Shock on up to 5 targets within 30 yds. After casting Divine Toll, you instantly cast Holy Shock every 5 sec. This effect lasts 15 sec.
    echoing_blessings               = { 81556, 387801, 1 }, -- Blessing of Freedom increases the target's movement speed by 15%. Blessing of Protection and Blessing of Sacrifice reduce the target's damage taken by 15%. These effects linger for 8 sec after the Blessing ends.
    empyreal_ward                   = { 81575, 387791, 1 }, -- Lay on Hands grants the target 30% increased armor for 1 min.
    empyrean_legacy                 = { 81591, 387170, 1 }, -- Judgment empowers your next Word of Glory to automatically activate Light of Dawn with 25% increased effectiveness. This effect can only occur every 30 sec.
    glimmer_of_light                = { 81595, 325966, 1 }, -- Holy Shock leaves a Glimmer of Light on the target for 30 sec. When you Holy Shock, all targets with Glimmer of Light are damaged for 228 or healed for 624. You may have Glimmer of Light on up to 8 targets.
    greater_judgment                = { 92220, 231644, 1 }, -- Judgment causes the target to take 30% increased damage from your next Crusader Strike or Holy Shock.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for 1,186 Holy damage. Only usable on enemies that have less than 20% health, or during Avenging Wrath. Generates 1 Holy Power.
    holy_light                      = { 81569, 82326 , 1 }, -- An efficient spell, healing a friendly target for 3,916.
    holy_prism                      = { 81577, 114165, 1 }, -- Fires a beam of light that scatters to strike a clump of targets. If the beam is aimed at an enemy target, it deals 945 Holy damage and radiates 882 healing to 5 allies within 15 yards. If the beam is aimed at a friendly target, it heals for 1,764 and radiates 567 Holy damage to 5 enemies within 15 yards.
    holy_shock                      = { 81555, 20473 , 1 }, -- Triggers a burst of Light on the target, dealing 727 Holy damage to an enemy, or 1,910 healing to an ally. Has an additional 30% critical strike chance. Generates 1 Holy Power.
    illumination                    = { 81572, 387993, 1 }, -- Holy Light and Flash of Light healing increased by 10%.
    imbued_infusions                = { 81557, 392961, 1 }, -- Consuming Infusion of Light reduces the cooldown of Holy Shock by 1.0 sec.
    improved_cleanse                = { 81508, 393024, 1 }, -- Cleanse additionally removes all Disease and Poison effects.
    inflorescence_of_the_sunwell    = { 81591, 392907, 1 }, -- Infusion of Light has 1 additional charge, reduces the cost of Flash of Light by an additional 30%, and causes every 3 casts of Holy Light to generate an additional Holy Power.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    light_of_dawn                   = { 81565, 85222 , 1 }, -- Unleashes a wave of holy energy, healing up to 5 injured allies within a 15 yd frontal cone for 1,328.
    light_of_the_martyr             = { 81561, 183998, 1 }, -- Sacrifice a portion of your own health to instantly heal an ally for 2,876. You take damage equal to 50% of the healing done. Does not cause your Beacon of Light to be healed. Cannot be cast on yourself.
    lights_hammer                   = { 81577, 114158, 1 }, -- Hurls a Light-infused hammer to the ground, dealing 243 Holy damage to nearby enemies and healing up to 6 nearby allies for 342, every 2 sec for 14 sec.
    maraads_dying_breath            = { 81559, 388018, 1 }, -- Light of Dawn increases your next Light of the Martyr by 10% for each ally healed, and allows that Light of the Martyr to heal through Beacon of Light. Light of the Martyr damages you over 5 sec instead of instantly.
    moment_of_compassion            = { 81571, 387786, 1 }, -- Your Flash of Light heals for an additional 15% when cast on a target affected by your Beacon of Light.
    power_of_the_silver_hand        = { 81589, 200474, 1 }, -- Holy Light and Flash of Light have a chance to grant you Power of the Silver Hand, increasing the healing of your next Holy Shock by 10% of all damage and effective healing you do within the next 10 sec, up to a maximum of 24,310.
    protection_of_tyr               = { 81566, 200430, 1 }, -- Aura Mastery also increases all healing received by party or raid members within 40 yards by 10%.
    radiant_onslaught               = { 81574, 231667, 1 }, -- Crusader Strike now has 2 charges.
    relentless_inquisitor           = { 81590, 383388, 2 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 3 times.
    resplendent_light               = { 81571, 392902, 1 }, -- Holy Light heals up to 5 targets within 12 yds for 8% of its healing.
    rule_of_law                     = { 81562, 214202, 1 }, -- Increase the range of your heals by 50% for 10 sec.
    saved_by_the_light              = { 81563, 157047, 1 }, -- When an ally with your Beacon of Light is damaged below 30% health, they absorb the next 5,166 damage. You cannot shield the same person this way twice within 1 min.
    second_sunrise                  = { 81583, 200482, 2 }, -- Light of Dawn has a 10% chance to create a second cone of light immediately after the first.
    shining_savior                  = { 81576, 388005, 1 }, -- Word of Glory and Light of Dawn healing increased by 5%.
    tirions_devotion                = { 81573, 392928, 1 }, -- Lay on Hands' cooldown is reduced by 1 sec per Holy Power spent.
    tower_of_radiance               = { 81586, 231642, 1 }, -- Casting Flash of Light or Holy Light on your Beacon of Light grants 1 Holy Power. Casting Flash of Light or Holy Light on targets without Beacon of Light has a chance to grant 1 Holy Power, increasing based on their current health threshold.
    tyrs_deliverance                = { 81588, 200652, 1 }, -- Releases the Light within yourself, healing 5 injured allies instantly and an injured ally every 0.9 sec for 10 sec within 20 yds for 762. Allies healed also receive 25% increased healing from your Holy Light and Flash of Light spells for 10 sec.
    unending_light                  = { 81564, 387998, 1 }, -- Each Holy Power spent on Light of Dawn increases the healing of your next Word of Glory by 5%, up to a maximum of 45%.
    untempered_dedication           = { 81560, 387814, 1 }, -- Light of the Martyr's damage and healing is increased by 10% each time it is cast. This effect can stack up to 5 times and lasts for 15 sec.
    unwavering_spirit               = { 81566, 392911, 1 }, -- The cooldown of Aura Mastery is reduced by 30 sec.
    veneration                      = { 81581, 392938, 1 }, -- Flash of Light, Holy Light, and Judgment critical strikes reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning       = 5553, -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain 1 additional stack if you are the victim. At 100 stacks of Reckoning, your next Judgment deals 200% increased damage, will critically strike, and activates Avenging Wrath for 6 sec.
    avenging_light          = 82  , -- (199441) When you heal with Holy Light, all enemies within 10 yards of the target take Holy damage equal to 30% of the amount healed.
    blessed_hands           = 88  , -- (199454) Your Blessing of Protection and Blessing of Freedom spells now have 1 additional charge.
    cleanse_the_weak        = 642 , -- (199330) When you dispel an ally within your aura, all allies within your aura are dispelled of the same effect. Healing allies with your Holy Light will cleanse all Diseases and Poisons from the target.
    darkest_before_the_dawn = 86  , -- (210378) Every 5 sec the healing done by your next Light of Dawn is increased by 20%. Stacks up to 5 times.
    divine_vision           = 640 , -- (199324) Increases the range of your Aura by 30 yards and reduces the cooldown of Aura Mastery by 60 sec.
    hallowed_ground         = 3618, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure   = 5421, -- (355858) Casting Judgment on an enemy cleanses 1 Poison, Disease, and Magic effect they have caused on allies within your Aura.
    lights_grace            = 859 , -- (216327) Increases the healing done by your Flash of Light by 25%, and your Holy Light reduces all damage the target receives by 15% for 5 sec.
    precognition            = 5501, -- (377360) If an interrupt is used on you while you are not casting, gain 15% Haste and become immune to crowd control, interrupt, and cast pushback effects for 5 sec.
    spreading_the_word      = 87  , -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.  Blessing of Protection Physical damage reduced by 30% for 6 sec.  Blessing of Freedom Cleared of all movement impairing effects.
    ultimate_sacrifice      = 85  , -- (199452) Your Blessing of Sacrifice now transfers 100% of all damage to you into a damage over time effect, but lasts 6 sec and no longer cancels when you are below 20% health.
    vengeance_aura          = 5537, -- (210323) When a full loss of control effect is applied to you or an ally within your Aura, gain 6% critical strike chance for 8 sec. Max 2 stacks.
} )


-- Auras
spec:RegisterAuras( {
    afterimage = {
        id = 385414,
    },
    aspiration_of_divinity = {
        id = 385416,
    },
    aura_mastery = {
        id = 31821,
        duration = 8,
        max_stack = 1,
    },
    avenging_crusader = {
        id = 216331,
        duration = 25,
        max_stack = 1,
    },
    avenging_wrath = {
        id = 31884,
        duration = 25,
        max_stack = 1,
    },
    barrier_of_faith = {
        id = 148039,
        duration = 18,
        max_stack = 1,
    },
    beacon_of_faith = {
        id = 156910,
        duration = 3600,
        max_stack = 1,
    },
    beacon_of_light = {
        id = 53563,
        duration = 3600,
        max_stack = 1,
    },
    beacon_of_virtue = {
        id = 200025,
        duration = 8,
        max_stack = 1,
    },
    bestow_faith = {
        id = 223306,
        duration = 5,
        max_stack = 1,
    },
    blessing_of_autumn = {
        id = 388010,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_freedom = {
        id = 1044,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    blessing_of_protection = {
        id = 1022,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12,
        max_stack = 1,
    },
    blessing_of_spring = {
        id = 388013,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_summer = {
        id = 388007,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_winter = {
        id = 388011,
        duration = 30,
        max_stack = 1,
    },
    blinding_light = {
        id = 115750,
    },
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1,
    },
    consecration = {
        id = 26573,
    },
    contemplation = {
        id = 121183,
        duration = 8,
        max_stack = 1,
    },
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,
    },
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,
    },
    divine_favor = {
        id = 210294,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    divine_protection = {
        id = 498,
        duration = 8,
        max_stack = 1,
    },
    divine_purpose = {
        id = 223819,
        duration = 12,
        max_stack = 1,
    },
    divine_resonance = {
        id = 387895,
        duration = 15,
        max_stack = 1,
    },
    divine_shield = {
        id = 642,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    divine_steed = {
        id = 276112,
        duration = 6.15,
        max_stack = 1,
    },
    echoing_freedom = {
        id = 339321,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    echoing_protection = {
        id = 339324,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    fleshcraft = {
        id = 324631,
        duration = 120,
        max_stack = 1,
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    golden_path = {
        id = 377128,
    },
    holy_avenger = {
        id = 105809,
        duration = 20,
        max_stack = 1,
    },
    incandescence = {
        id = 385464,
    },
    infusion_of_light = {
        id = 54149,
        duration = 15,
        max_stack = 2,
        copy = 53576
    },
    light_of_the_martyr = {
        id = 196917,
        duration = 5.113,
        max_stack = 1,
    },
    mastery_lightbringer = {
        id = 183997,
    },
    of_dusk_and_dawn = {
        id = 385125,
    },
    recompense = {
        id = 384914,
    },
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1,
    },
    rule_of_law = {
        id = 214202,
        duration = 10,
        max_stack = 1,
    },
    seal_of_clarity = {
        id = 384815,
    },
    seal_of_mercy = {
        id = 384897,
    },
    seal_of_might = {
        id = 385450,
    },
    seal_of_the_templar = {
        id = 377016,
    },
    seraphim = {
        id = 152262,
        duration = 15,
        max_stack = 1,
    },
    shield_of_the_righteous = {
        id = 132403,
        duration = 4.5,
        max_stack = 1,
    },
    shielding_words = {
        id = 338788,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    tyrs_deliverance = {
        id = 200652,
        duration = 10,
        max_stack = 1,
    },
    unending_light = {
        id = 394709,
        duration = 30,
        type = "Magic",
        max_stack = 6,
    },
    untempered_dedication = {
        id = 387815,
        duration = 15,
        max_stack = 5,
    },
    vanquishers_hammer = {
        id = 328204,
    },
    zealots_paragon = {
        id = 391142,
    },
} )


spec:RegisterHook( "reset_precast", function()
    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    absolution = {
        id = 212056,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1030102,

        handler = function ()
        end,
    },


    aura_mastery = {
        id = 31821,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 135872,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "aura_mastery" )
        end,
    },


    avenging_crusader = {
        id = 216331,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.5,
        spendType = "mana",

        talent = "avenging_crusader",
        notalent = "avenging_wrath",
        startsCombat = false,
        texture = 589117,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avenging_crusader" )
        end,

        bind = { "avenging_wrath", "sanctified_wrath" }
    },


    avenging_wrath = {
        id = function() return talent.avenging_crusader.enabled and 216331 or 31884 end,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return talent.avenging_crusader.enabled and 5 or 0 end,
        spendType = function() return talent.avenging_crusader.enabled and "holy_power" or 0 end,

        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            if talent.avenging_crusader.enabled then spend( 5, "holy_power" ) end
            applyBuff( "avenging_wrath" )
        end,

        copy = { "avenging_crusader", "sanctified_wrath", 31884, 216331 }
    },


    barrier_of_faith = {
        id = 148039,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,
        texture = 4067370,

        handler = function ()
            applyBuff( "barrier_of_faith" )
        end,
    },


    beacon_of_faith = {
        id = 156910,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 1030095,

        handler = function ()
            applyBuff( "beacon_of_faith" )
        end,
    },


    beacon_of_light = {
        id = 53563,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 236247,

        handler = function ()
            applyBuff( "beacon_of_light" )
        end,
    },


    beacon_of_virtue = {
        id = 200025,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,
        texture = 1030094,

        handler = function ()
            applyBuff( "beacon_of_virtue" )
        end,
    },


    bestow_faith = {
        id = 223306,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236249,

        handler = function ()
            applyBuff( "bestow_faith" )
        end,
    },


    blessing_of_autumn = {
        id = 388010,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636843,

        handler = function ()
            setCooldown( "blessing_of_winter", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,
    },


    blessing_of_freedom = {
        id = 1044,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135968,

        handler = function ()
            applyBuff( "blessing_of_freedom" )
        end,
    },


    blessing_of_protection = {
        id = 1022,
        cast = 0,
        charges = 1,
        cooldown = 300,
        recharge = 300,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 135964,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyDebuff( "forbearance" )
            applyBuff( "blessing_of_protection" )
        end,
    },


    blessing_of_sacrifice = {
        id = 6940,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135966,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "blessing_of_sacrifice" )
        end,
    },


    blessing_of_spring = {
        id = 388013,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636844,

        handler = function ()
            setCooldown( "blessing_of_summer", 45 )
            setCooldown( "blessing_of_autumn", 90 )
            setCooldown( "blessing_of_winter", 135 )
        end,
    },


    blessing_of_summer = {
        id = 388007,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636845,

        handler = function ()
            setCooldown( "blessing_of_autumn", 45 )
            setCooldown( "blessing_of_winter", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,
    },


    blessing_of_winter = {
        id = 388011,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636846,

        handler = function ()
            setCooldown( "blessing_of_spring", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_autumn", 135 )
        end,
    },


    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 571553,

        handler = function ()
            applyDebuff( "blinding_light" )
        end,
    },


    cleanse = {
        id = 4987,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

        handler = function ()
        end,
    },


    concentration_aura = {
        id = 317920,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135933,

        handler = function ()
            applyBuff( "concentration_aura" )
            removeBuff( "devotion_aura" )
            removeBuff( "crusader_aura" )
            removeBuff( "retribution_aura" )
        end,
    },


    contemplation = {
        id = 121183,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        startsCombat = false,
        texture = 134916,

        handler = function ()
        end,
    },


    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135890,

        handler = function ()
            applyBuff( "crusader_aura" )
            removeBuff( "devotion_aura" )
            removeBuff( "retribution_aura" )
            removeBuff( "concentration_aura" )
        end,
    },


    crusader_strike = {
        id = 35395,
        cast = 0,
        charges = 2,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        startsCombat = true,
        texture = 135891,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

            if talent.crusaders_might.enabled then
                setCooldown( "holy_shock", max( 0, cooldown.holy_shock.remains - 2.0 ) )
            end
        end,
    },


    devotion_aura = {
        id = 465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135893,

        handler = function ()
            applyBuff( "devotion_aura" )
            removeBuff( "retribution_aura" )
            removeBuff( "crusader_aura" )
            removeBuff( "concentration_aura" )
        end,
    },


    divine_favor = {
        id = 210294,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = false,
        texture = 135915,

        handler = function ()
            applyBuff( "divine_favor" )
        end,
    },


    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 60 end,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 524353,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyBuff( "divine_protection" )
        end,
    },


    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
        gcd = "spell",

        startsCombat = false,
        texture = 524354,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyDebuff( "forbearance" )
            applyBuff( "divine_shield" )
        end,
    },


    divine_steed = {
        id = 190784,
        cast = 0,
        charges = 2,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",

        startsCombat = false,
        texture = 1360759,

        handler = function ()
            applyBuff( "divine_steed" )
        end,
    },


    divine_toll = {
        id = 375576,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = true,
        texture = 3565448,

        toggle = "cooldowns",

        handler = function ()
            if talent.divine_resonance.enabled then
                applyBuff( "divine_resonance" )
                state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" )
            end
            gain( ( buff.holy_avenger.up and 5 or 2 ) * min( 5, active_enemies ), "holy_power" )
        end,
    },


    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "infusion_of_light" )
            removeBuff( "divine_favor" )
        end,
    },


    fleshcraft = {
        id = 324631,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 3586267,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "fleshcraft" )
        end,
    },


    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 135963,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "hammer_of_justice" )
        end,
    },


    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        startsCombat = true,
        texture = 613533,

        usable = function () return target.health_pct < 20 end,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
        end,
    },


    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135984,

        handler = function ()
            applyDeuff( "hand_of_reckoning" )
        end,
    },


    holy_avenger = {
        id = 105809,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 571555,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "holy_avenger" )
        end,
    },


    holy_light = {
        id = 82326,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 135981,

        handler = function ()
            removeBuff( "infusion_of_light" )
            removeBuff( "divine_favor" )
        end,
    },


    holy_prism = {
        id = 114165,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.13,
        spendType = "mana",

        startsCombat = true,
        texture = 613408,

        handler = function ()
        end,
    },


    holy_shock = {
        id = 20473,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        startsCombat = true,
        texture = 135972,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
        end,
    },


    intercession = {
        id = 391054,
        cast = 2.0003372583008,
        cooldown = 600,
        gcd = "spell",

        spend = 0,
        spendType = "holy_power",

        startsCombat = false,
        texture = 4726195,

        handler = function ()
        end,
    },


    judgment = {
        id = 275773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
        end,
    },


    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
        gcd = "spell",

        startsCombat = false,
        texture = 135928,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "forbearance" )
        end,
    },


    light_of_dawn = {
        id = 85222,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 461859,

        handler = function ()
            removeBuff( "divine_purpose" )
        end,
    },


    light_of_the_martyr = {
        id = 183998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 1360762,

        handler = function ()
            removeBuff( "maraads_dying_breath" )
        end,
    },


    lights_hammer = {
        id = 114158,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 613955,

        handler = function ()
        end,
    },


    rebuke = {
        id = 96231,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 523893,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    redemption = {
        id = 7328,
        cast = 10.000345582886,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,
    },


    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135942,

        handler = function ()
            applyDebuff( "repentance" )
        end,
    },


    retribution_aura = {
        id = 183435,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135889,

        handler = function ()
            applyBuff( "retribution_aura" )
            removeBuff( "devotion_aura" )
            removeBuff( "crusader_aura" )
            removeBuff( "concentration_aura" )
        end,
    },


    rule_of_law = {
        id = 214202,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        startsCombat = false,
        texture = 571556,

        handler = function ()
            applyBuff( "rule_of_law" )
        end,
    },


    seraphim = {
        id = 152262,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,
        texture = 1030103,

        handler = function ()
            applyBuff( "seraphim" )
        end,
    },


    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = true,
        texture = 236265,

        handler = function ()
            removeBuff( "divine_purpose" )
            applyBuff( "shield_of_the_righteous" )
        end,
    },


    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 571559,

        handler = function ()
            applyDebuff( "turn_evil" )
        end,
    },


    tyrs_deliverance = {
        id = 200652,
        cast = 2,
        cooldown = 90,
        gcd = "spell",

        startsCombat = false,
        texture = 1122562,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "tyrs_deliverance" )
        end,
    },


    vanquishers_hammer = {
        id = 328204,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 3578228,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            applyBuff( "vanquishers_hammer" )
        end,
    },


    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 133192,

        handler = function ()
            removeBuff( "divine_purpose" )
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 25,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Holy Paladin",
} )


spec:RegisterPack( "Holy Paladin", 20230205, [[Hekili:fFvBVTonu4FltiTbIrPP7L7DxuNeGe6UbAcPoeFaDtSBYPnM6yhSDwxLQ8VDo2jP1jnb4knj(WMCSp(58(5Xnok(54fzude)0SPZUA6SP3mj62RJU5M4fMDLq8IsA6g6ACHGwG))Js(ol5xPCAgt4oDhxsZCOOLvQuuI4flRyCZdI4LdaD07V(ou2sin(PBrLKZYYGArbDA8INZzAlX9h1sA0TLixHFNAysHLWzAdE8kPYs(iSHXztIx430BfLGiduU1p5DoqqxYHS4FiErQIzafJgV4mlXq5GWmHULUbemX6jncAj73xRSxGeqafma129wsu8IAtavsod4zjYvjMCirXwNBazLo2GU6O6CCfEULSwjRkpQaUdsh(z0TchSx9zd7rW2kvEBDnxQ2HGzCX6v0kU5qqQvufSSAdeQPbCjxIsXkRVXp5sd0SmxMPSsvk1G(sl57FbeRrRXs(Df1KJ7SGkqLSI5C429OISqr)rvLMIjp8afM0PCoMMYXvAS0d)EjMRn7MC0CPnxnzRdWdXPdPjqrlZzf98NRdLjhRNt84aQEYDtOC42ATtvyGuxvuCI03oM00ktvHON0VBmP3YeMtW(9JAjLkCvpPV7)szFBKlTjM3T8pvk5zYTIbKtbfuMOULyDA2Kc6R13XhjlLBrzWYlwkZyjZTKPyEWOyPgxP2bNiftUj1FK46DR7GtQNXCOh2DNPH(Eg7fMasmsoVNth1Po23)OtYPdKOIMDs(hJI6(vjrJ3YDMlaj0qkw1HGmPQ03dBOQ1GzYwMjNjq7(OZgiSh6UvGEJ0N79vX9mJovH)zv26cm)1xOBpXL05Y0n9f7DJ6shs4hV8qz6aFQPEiXLCXrg(XkLkivwSKAoz67YaZdOktcwddI067H38fmD7o9avbo2IQCZZ0oobS7NvukvMM5(x0wICHLOG)QIPCvUAPFmrLrwG0o4gP5uSVwpX(4VGLn4i8pGdzKcuz(JVO)StenJCG9BBoWZ)YOx)Qd4n7ngVREZWZ(4abTMP(FEXS7gXM6pyOVTn2aMU2OJOVujxX4qnRFbZpCdnSQYaBFnYeJdrqDGd82ag0(iwYdM6l5l7kCvezogdkUnGg8oh2mjwKJRyIuEvMJlhWguq9b0aiFJL8h)MgCibf6pHusBZzP5Hstf7oQvlriDG)Aj3nGJFe3m3Qg6QwL(D4dxuTQ55AiWIWp1q8DCRzbAElZr7DWJAG00kQpA43suvSeQZHCPbJNp4t2UnUQ3RLWdDnN(WCBJO(RN)T1092h)cl5)bEC7JhTKUm5HN0sIhUxiPD4(Nssp2P1KYJDAnj8Oi7jDdpTpB2LoES5TZOUSM)BE0LSvZpBS(J97)3jDVVzm8(9Ns2oFAOffqugUDhEXtIOEAWo(vaXL347r7DEpkVoi2Lwl8OwwStmapVthdOllJZg(hyQAdpUrlnymPnj4QKg(v7DYkTtu3V3bWXFbW9rdczN3P7aQpoN7Fy)G3TZZYh6UyNALjxIVF5NXtKBWFZLG5PlJ)7d]] )