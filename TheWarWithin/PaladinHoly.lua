-- PaladinHoly.lua
-- January 2025

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format
local SPEC_ACTIVE = _G.SPEC_ACTIVE

local PTR = ns.PTR

local spec = Hekili:NewSpecialization( 65 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    a_just_reward                   = { 103858, 469411, 1 }, -- After Cleanse successfully removes an effect from an ally, they are healed for 14,229.
    afterimage                      = {  81613, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness.
    auras_of_the_resolute           = {  81600, 385633, 1 }, -- Learn Concentration Aura, Devotion Aura, and Crusader Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yds are 30% shorter.  Devotion Aura: Party and raid members within 40 yds are bolstered by their devotion, reducing damage taken by 3%.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yds.
    blessed_calling                 = { 103868, 469770, 1 }, -- Allies affected by your Blessings have 15% increased movement speed.
    blessing_of_freedom             = {  81631,   1044, 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = {  81616,   1022, 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    blessing_of_sacrifice           = {  81614,   6940, 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = {  81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yds, causing them to wander disoriented for 6 sec.
    cavalier                        = {  81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    consecrated_ground              = {  81543, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed.
    divine_purpose                  = {  93191, 223817, 1 }, -- Holy Power spending abilities have a 15% chance to make your next Holy Power spending ability free and deal 15% increased damage and healing.
    divine_reach                    = {  93168, 469476, 1 }, -- The radius of your auras is increased by 20 yds.
    divine_resonance                = {  93180, 386738, 1 }, -- After casting Divine Toll, you instantly cast Holy Shock every 5 sec for 15 sec.
    divine_spurs                    = { 103857, 469409, 1 }, -- Divine Steed's cooldown is reduced by 20%, but its duration is reduced by 40%.
    divine_steed                    = {  81632, 190784, 1 }, -- Leap atop your Charger for 5 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    divine_toll                     = {  81496, 375576, 1 }, -- Instantly cast Holy Shock on up to 5 targets within 30 yds.
    echoing_blessings               = {  93520, 387801, 1 }, -- Blessing of Freedom increases the target's movement speed by 15%. Blessing of Protection and Blessing of Sacrifice reduce the target's damage taken by 15%. These effects linger for 8 sec after the Blessing ends.
    empyreal_ward                   = { 103859, 387791, 1 }, -- Lay on Hands grants the target 30% increased armor for 8 sec and now ignores healing reduction effects.
    eye_for_an_eye                  = {  81628, 469309, 1 }, -- Melee and ranged attackers receive 4,107 Holy damage each time they strike you during Divine Protection and Divine Shield.
    faiths_armor                    = {  81495, 406101, 1 }, -- Word of Glory grants 20% bonus armor for 4.5 sec.
    fist_of_justice                 = {  81602, 234299, 1 }, -- Hammer of Justice's cooldown is reduced by 15 sec.
    golden_path                     = { 103856, 377128, 1 }, -- Consecration heals you and 5 allies within it for 436 every 0.8 sec.
    greater_judgment                = {  92220, 231644, 1 }, -- Judgment deems the target unworthy, preventing the next 21,594 damage dealt by the target.
    hammer_of_wrath                 = {  81510,  24275, 1 }, -- Hurls a divine hammer that strikes an enemy for 25,385 Holy damage. Only usable on enemies that have less than 20% health. Generates 1 Holy Power.
    holy_aegis                      = {  81609, 385515, 1 }, -- Armor and critical strike chance increased by 4%.
    holy_reprieve                   = { 103860, 469445, 1 }, -- Your Forbearance's duration is reduced by 10 sec.
    holy_ritual                     = { 103866, 199422, 1 }, -- Allies are healed for 11,384 when you cast a Blessing spell on them and healed again for 11,384 when the blessing ends.
    improved_blessing_of_protection = {  81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection by 60 sec.
    improved_cleanse                = {  81508, 393024, 1 }, -- Cleanse additionally removes all Disease and Poison effects.
    inspired_guard                  = { 103864, 469439, 1 }, -- Divine Protection increases healing taken by 15% for its duration.
    judgment_of_light               = {  81608, 183778, 1 }, -- Judgment causes the next 5 successful attacks against the target to heal the attacker for 1,793.
    lay_on_hands                    = {  81597,    633, 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Grants the target 30% increased armor for 8 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    lead_the_charge                 = { 103867, 469780, 1 }, -- Divine Steed reduces the cooldown of 4 nearby ally's major movement ability by 3.0 sec. Your movement speed is increased by 3%.
    lightbearer                     = { 103861, 469416, 1 }, -- 10% of all healing done to you from other sources heals up to 4 nearby allies, divided evenly among them.
    lightforged_blessing            = { 103852, 406468, 1 }, -- Shield of the Righteous heals you and up to 2 nearby allies for 2.0% of maximum health.
    lights_countenance              = { 103854, 469325, 1 }, -- The cooldowns of Repentance and Blinding Light are reduced by 15 sec.
    lights_revocation               = { 103863, 146956, 1 }, -- Removing harmful effects with Divine Shield heals you for 10% for each effect removed. This heal cannot exceed 30% of your maximum health. Divine Shield may now be cast while Forbearance is active.
    obduracy                        = {  81630, 385427, 1 }, -- Speed increased by 2% and damage taken from area of effect attacks reduced by 2%.
    of_dusk_and_dawn                = {  93357, 409439, 1 }, -- When you cast 3 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals 15% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by 4% For 10 sec.
    punishment                      = {  93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke casts an extra Crusader Strike.
    quickened_invocation            = {  93180, 379391, 1 }, -- Divine Toll's cooldown is reduced by 15 sec.
    rebuke                          = {  81604,  96231, 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 3 sec.
    recompense                      = {  81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = {  81598,  20066, 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    righteous_protection            = { 103865, 469321, 1 }, -- Blessing of Sacrifice now removes and prevents all Poison and Disease effects.
    sacred_strength                 = {  93191, 469337, 1 }, -- Holy Power spending abilities are 2% more effective.
    sacrifice_of_the_just           = {  81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 15 sec.
    sanctified_plates               = {  93009, 402964, 2 }, -- Armor increased by 6%, Stamina increased by 3% and damage taken from area of effect attacks reduced by 1%.
    seal_of_might                   = {  81621, 385450, 2 }, -- Mastery increased by 2% and intellect increased by 2%.
    seal_of_the_crusader            = {  93683, 416770, 1 }, -- Your auto attacks heal a nearby ally for 6,103.
    selfless_healer                 = { 103856, 469434, 1 }, -- Flash of Light and Holy Light are 10% more effective on your allies and 10% of the healing done also heals you.
    stand_against_evil              = { 103855, 469317, 1 }, -- Turn Evil now affects 5 additional enemies.
    steed_of_liberty                = {  81631, 469304, 1 }, -- Divine Steed also grants Blessing of Freedom for 3.0 sec.  Blessing of Freedom: Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    stoicism                        = { 103862, 469316, 1 }, -- The duration of stun effects on you is reduced by 20%.
    turn_evil                       = {  93010,  10326, 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = {  81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Divine Protection, and Lay on Hands by 30%.
    vengeful_wrath                  = { 103851, 406835, 2 }, -- Hammer of Wrath deals 50% increased damage to enemies below 35% health.
    worthy_sacrifice                = { 103865, 469279, 1 }, -- You automatically cast Blessing of Sacrifice onto an ally within 40 yds when they are below 35% health and you are not in a loss of control effect. This effect activates 100% of Blessing of Sacrifice's cooldown.
    wrench_evil                     = { 103855, 460720, 1 }, -- Turn Evil's cast time is reduced by 100%.

    -- Holy
    aura_mastery                    = {  81567,  31821, 1 }, -- Empowers your chosen aura for 8 sec.
    avenging_crusader               = {  81584, 216331, 1 }, -- You become the ultimate crusader of light for 18.8 sec. Crusader Strike and Judgment cool down 30% faster and heal up to 5 injured allies within 40 yds for 260% of the damage done, split evenly among them. Grants an additional charge of Crusader Strike for its duration.
    avenging_wrath                  = {  81584,  31884, 1 }, -- Call upon the Light to become an avatar of retribution, reducing Holy Shock's cooldown by 50%, increasing your damage, healing, and critical strike chance by 15% for 25 sec.
    awakening                       = {  81592, 414195, 1 }, -- While in combat, your Holy Power spenders generate 1 stack of Awakening. At 15 stacks of Awakening, your next Judgment deals 40% increased damage, will critically strike, and activates Avenging Wrath for 12 sec.
    awestruck                       = {  81564, 417855, 1 }, -- Holy Shock, Holy Light, and Flash of Light critical healing increased by 20%.
    barrier_of_faith                = {  81577, 148039, 1 }, -- Imbue a friendly target with a Barrier of Faith, absorbing 58,681 damage for 12 sec. For the next 24 sec, Barrier of Faith accumulates 20% of effective healing from your Flash of Light, Holy Light, or Holy Shock spells. Every 6 sec, the accumulated healing becomes an absorb shield.
    beacon_of_faith                 = {  81554, 156910, 1 }, -- Mark a second target as a Beacon, mimicking the effects of Beacon of Light. Your heals will now heal both of your Beacons, but at 30% reduced effectiveness.
    beacon_of_the_lightbringer      = {  81568, 197446, 1 }, -- Mastery: Lightbringer now increases your healing based on the target's proximity to either you or your Beacon of Light, whichever is closer.
    beacon_of_virtue                = {  81554, 200025, 1 }, -- Apply a Beacon of Light to your target and 4 injured allies within 30 yds for 8 sec. All affected allies will be healed for 20% of the amount of your other healing done.
    bestow_light                    = {  81560, 448040, 1 }, -- Light of the Martyr's health threshold is reduced to 70% and increases Holy Shock's healing by an additional 5% for every 5 sec Light of the Martyr is active, stacking up to 3 times. While below 70% health, the light urgently heals you for 2,347 every 1 sec.
    blessing_of_summer              = {  81593, 388007, 1 }, -- Bless an ally for 30 sec, causing 12% of all healing to be converted into damage onto a nearby enemy and 12% of all damage to be converted into healing onto an injured ally within 40 yds. Blessing of the Seasons: Turns to Autumn after use.
    boundless_salvation             = {  81587, 392951, 1 }, -- Your Holy Shock, Flash of Light, and Holy Light spells extend the duration of Tyr's Deliverance on yourself when cast on targets affected by Tyr's Deliverance. Holy Shock: Extends 2.0 sec. Flash of Light: Extends 4.0 sec.  Holy Light: Extends 8.0 sec. Tyr's Deliverance can be extended up to a maximum of 40 sec.
    breaking_dawn                   = {  81583, 387879, 2 }, -- Increases the range of Light of Dawn to 25 yds.
    commanding_light                = {  81580, 387781, 1 }, -- Beacon of Light transfers an additional 10% of the amount healed.
    crusaders_might                 = {  81594, 196926, 1 }, -- Crusader Strike reduces the cooldown of Holy Shock and Judgment by 2.0 sec.
    divine_favor                    = {  81570, 460422, 1 }, -- After casting Barrier of Faith or Holy Prism, the healing of your next Holy Light or Flash of Light is increased by 40%, its cast time is reduced by 30%, and its mana cost is reduced by 50%.
    divine_glimpse                  = {  81585, 387805, 1 }, -- Holy Shock and Judgment have a 8% increased critical strike chance.
    divine_revelations              = {  81578, 387808, 1 }, -- While empowered by Infusion of Light, Flash of Light heals for an additional 20%, and Holy Light or Judgment refund 0.5% of your maximum mana.
    empyrean_legacy                 = { 103831, 387170, 1 }, -- Judgment empowers your next Word of Glory to automatically activate Light of Dawn with 25% increased effectiveness. This effect can only occur every 20 sec.
    extrication                     = {  81569, 461278, 1 }, -- Word of Glory and Light of Dawn gain up to 30% additional chance to critically strike, based on their target's current health. Lower health targets are more likely to be critically struck.
    glistening_radiance             = {  81576, 461245, 1 }, -- Spending Holy Power has a 25% chance to trigger Saved by the Light's absorb effect at 33% effectiveness without activating its cooldown.
    glorious_dawn                   = {  93521, 461246, 1 }, -- Holy Shock has a 12% chance to refund a charge when cast and its healing is increased by 10%.
    hand_of_divinity                = {  81570, 414273, 1 }, -- Call upon the Light to empower your spells, causing your next 2 Holy Lights to heal 30% more, cost 50% less mana, and be instant cast.
    holy_prism                      = {  81577, 114165, 1 }, -- Fires a beam of light that scatters to strike a clump of targets. If the beam is aimed at an enemy target, it deals 49,180 Holy damage and radiates 35,859 healing to 5 allies within 30 yds. If the beam is aimed at a friendly target, it heals for 71,718 and radiates 21,516 Holy damage to 5 enemies within 30 yds.
    holy_shock                      = {  81555,  20473, 1 }, -- Triggers a burst of Light on the target, dealing 12,675 Holy damage to an enemy, or 28,375 healing to an ally. Generates 1 Holy Power.
    imbued_infusions                = {  81557, 392961, 1 }, -- Consuming Infusion of Light reduces the cooldown of Holy Shock by 1.0 sec.
    inflorescence_of_the_sunwell    = {  81591, 392907, 1 }, -- Infusion of Light has 1 additional charge, increases Greater Judgment's effect by an additional 50%, reduces the cost of Flash of Light by an additional 30%, and Holy Light's healing is increased by an additional 50%.
    liberation                      = { 102502, 461287, 1 }, -- Word of Glory and Light of Dawn have a chance equal to your haste to reduce the cost of your next Holy Light, Crusader Strike, or Judgment by 342.
    light_of_dawn                   = {  81565,  85222, 1 }, -- Unleashes a wave of Holy energy, healing up to 5 injured allies within a 15 yd frontal cone for 13,934.
    light_of_the_martyr             = {  81561, 447985, 1 }, -- While above 80% health, Holy Shock's healing is increased 20%, but creates a heal absorb on you for 30% of the amount healed that prevents Beacon of Light from healing you until it has dissipated.
    lights_conviction               = {  93927, 414073, 1 }, -- Holy Shock now has 2 charges.
    lights_protection               = {  93522, 461243, 1 }, -- Allies with Beacon of Light receive 5% less damage.
    merciful_auras                  = {  81593, 183415, 1 }, -- Your auras restore 1,766 health to 3 injured allies within 20 yds every 2 sec. While Aura Mastery is active, heals all allies within 40 yds and healing is increased by 20%.
    moment_of_compassion            = {  81571, 387786, 1 }, -- Your Flash of Light heals for an additional 50% when cast on a target affected by your Beacon of Light.
    overflowing_light               = {  81556, 461244, 1 }, -- 30% of Holy Shock's overhealing is converted into an absorb shield. The shield amount cannot exceed 10% of your max health.
    power_of_the_silver_hand        = {  81589, 200474, 1 }, -- Holy Light, Flash of Light, and Judgment have a chance to grant you Power of the Silver Hand, increasing the healing of your next Holy Shock by 20% of all damage and effective healing you do within the next 10 sec, up to a maximum of 466,350.
    protection_of_tyr               = {  81566, 200430, 1 }, -- Aura Mastery also increases all healing received by party or raid members within 40 yards by 10%.
    reclamation                     = {  81558, 415364, 1 }, -- Holy Shock and Crusader Strike refund up to 10% of their Mana cost and deal up to 50% more healing or damage, based on the target's missing health.
    relentless_inquisitor           = {  81590, 383388, 1 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 5 times.
    resplendent_light               = {  81571, 392902, 1 }, -- Holy Light heals up to 5 targets within 12 yds for 8% of its healing.
    righteous_judgment              = {  93523, 414113, 1 }, -- Judgment has a 50% chance to cast Consecration at the target's location. The limit on Consecration does not apply to this effect.
    rising_sunlight                 = {  81595, 461250, 1 }, -- After casting Avenging Wrath, your next 2 Holy Shocks cast 2 additional times. After casting Divine Toll, your next 2 Holy Shocks cast 2 additional times.
    sanctified_wrath                = {  81592,  53376, 1 }, -- Avenging Wrath now reduces Holy Shock's cooldown by 50%. and its duration is increased by 25%.
    saved_by_the_light              = {  81574, 157047, 1 }, -- When an ally with your Beacon of Light is damaged below 50% health, they absorb the next 105,626 damage. You cannot shield the same person this way twice within 1 min.
    shining_righteousness           = {  81562, 414443, 1 }, -- Shield of the Righteous deals 15,022 damage to its first target struck. Every 5 Shields of the Righteous make your next Word of Glory or Light of Dawn cost no Holy Power.
    tirions_devotion                = {  81573, 414720, 1 }, -- Lay on Hands' cooldown is reduced by 1.5 sec per Holy Power spent and restores 5% of your Mana.
    tower_of_radiance               = {  81586, 231642, 1 }, -- Casting Flash of Light or Holy Light grants 1 Holy Power.
    truth_prevails                  = {  81579, 461273, 1 }, -- Judgment heals you for 34,151 and its mana cost is reduced by 30%. 50% of overhealing from this effect is transferred onto 2 allies within 40 yds.
    tyrs_deliverance                = {  81588, 200652, 1 }, -- Releases the Light within yourself, healing 5 injured allies instantly and an injured ally every 0.8 sec for 20 sec within 40 yds for 3,995. Allies healed also receive 12% increased healing from your Holy Light, Flash of Light, and Holy Shock spells for 12 sec.
    unending_light                  = {  81575, 387998, 1 }, -- Each Holy Power spent on Light of Dawn increases the healing of your next Word of Glory by 5%, up to a maximum of 45%.
    unwavering_spirit               = {  81566, 392911, 1 }, -- The cooldown of Aura Mastery is reduced by 30 sec.
    veneration                      = {  81581, 392938, 1 }, -- Hammer of Wrath heals up to 5 injured allies for 200% of the damage done, split evenly among them. Flash of Light, Holy Light, and Judgment critical strikes reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.

    -- Herald of the Sun
    aurora                          = {  95069, 439760, 1 }, -- After you cast Holy Prism or Barrier of Faith, gain Divine Purpose.  Divine Purpose Your next Holy Power spending ability is free and deals 15% increased damage and healing.
    blessing_of_anshe               = {  95071, 445200, 1 }, -- Your damage and healing over time effects have a chance to increase the healing or damage of your next Holy Shock by 200%.
    dawnlight                       = {  95099, 431377, 1, "herald_of_the_sun" }, -- Casting Holy Prism or Barrier of Faith causes your next 2 Holy Power spending abilities to apply Dawnlight on your target, dealing 55,436 Radiant damage or 83,884 healing over 8 sec. 8% of Dawnlight's damage and healing radiates to nearby allies or enemies, reduced beyond 5 targets.
    eternal_flame                   = {  95095, 156322, 1 }, -- Heals an ally for 65,479 and an additional 15,126 over 16 sec. Healing increased by 25% when cast on self.
    gleaming_rays                   = {  95073, 431480, 1 }, -- While a Dawnlight is active, your Holy Power spenders deal 5% additional damage or healing.
    illumine                        = {  95098, 431423, 1 }, -- Dawnlight reduces the movement speed of enemies by 50% and increases the movement speed of allies by 20%.
    lingering_radiance              = {  95071, 431407, 1 }, -- Dawnlight leaves an Eternal Flame for 6 sec on allies or a Greater Judgment on enemies when it expires or is extended.
    luminosity                      = {  95080, 431402, 1 }, -- Critical Strike chance of Holy Shock and Light of Dawn increased by 5%.
    morning_star                    = {  95073, 431482, 1 }, -- Every 5.0 sec, your next Dawnlight's damage or healing is increased by 5%, stacking up to 10 times. Morning Star stacks twice as fast while out of combat.
    second_sunrise                  = {  95086, 431474, 1 }, -- Light of Dawn and Holy Shock have a 15% chance to cast again at 30% effectiveness.
    solar_grace                     = {  95094, 431404, 1 }, -- Your Haste is increased by 2% for 12 sec each time you apply Dawnlight. Multiple stacks may overlap.
    sun_sear                        = {  95072, 431413, 1 }, -- Holy Shock and Light of Dawn critical strikes cause the target to be healed for an additional 9,678 over 4 sec.
    suns_avatar                     = {  95105, 431425, 1 }, -- During Avenging Wrath, you become linked to your Dawnlights, causing 2,535 Radiant damage to enemies or 1,844 healing to allies that pass through the beams, reduced beyond 5 targets. Activating Avenging Wrath applies up to 4 Dawnlights onto nearby allies or enemies and increases Dawnlight's duration by 20%.
    will_of_the_dawn                = {  95098, 431406, 1 }, -- Movement speed increased by 5% while above 80% health. When your health is brought below 35%, your movement speed is increased by 40% for 5 sec. Cannot occur more than once every 1 min.

    -- Lightsmith
    authoritative_rebuke            = {  95232, 469886, 1 }, -- Successfully interrupting an enemy spellcast reduces your Rebuke's cooldown by 1.0 sec. Effect increased by 100% while wielding a Holy Armament.
    blessed_assurance               = {  95235, 433015, 1 }, -- Casting a Holy Power ability increases the damage and healing of your next Crusader Strike by 120%.
    blessing_of_the_forge           = {  95230, 433011, 1 }, -- Avenging Wrath summons an additional Sacred Weapon, and during Avenging Wrath your Sacred Weapon casts spells on your target and echoes the effects of your Holy Power abilities.
    divine_guidance                 = {  95235, 433106, 1 }, -- For each Holy Power ability cast, your next Consecration deals 36,618 damage or healing immediately, split across all enemies and allies.
    divine_inspiration              = {  95231, 432964, 1 }, -- Your spells and abilities have a chance to manifest a Holy Armament for a nearby ally.
    forewarning                     = {  95231, 432804, 1 }, -- The cooldown of Holy Armaments is reduced by 20%.
    hammer_and_anvil                = {  95238, 433718, 1 }, -- Judgment critical strikes cause a shockwave around the target, dealing 83,520 healing at the target's location.
    holy_armaments                  = {  95234, 432459, 1, "lightsmith" }, -- Will the Light to coalesce and become manifest as a Holy Armament, wielded by your friendly target.  Holy Bulwark: While wielding a Holy Bulwark, gain an absorb shield for 15.0% of your max health and an additional 2.0% every 2 sec. Lasts 20 sec. Becomes Sacred Weapon after use.
    laying_down_arms                = {  95236, 432866, 1 }, -- When an Armament fades from you, the cooldown of Lay on Hands is reduced by 15.0 sec and you gain Infusion of Light.
    rite_of_adjuration              = {  95233, 433583, 1 }, -- Imbue your weapon with the power of the Light, increasing your Stamina by 3% and causing your Holy Power abilities to sometimes unleash a burst of healing around a target. Lasts 1 |4hour:hrs;.
    rite_of_sanctification          = {  95233, 433568, 1 }, -- Imbue your weapon with the power of the Light, increasing your armor by 5% and your primary stat by 2%. Lasts 1 |4hour:hrs;.
    shared_resolve                  = {  95237, 432821, 1 }, -- The effect of your active Aura is increased by 33% on targets with your Armaments.
    solidarity                      = {  95228, 432802, 1 }, -- If you bestow an Armament upon an ally, you also gain its benefits. If you bestow an Armament upon yourself, a nearby ally also gains its benefits.
    tempered_in_battle              = {  95232, 469701, 1 }, -- When you or an ally wielding a Holy Bulwark are healed above maximum health, transfer 100% of the overhealing to your ally. When you or an ally wielding a Sacred Weapon drop below 40% health, redistribute your health immediately and every 1 sec for 4 sec.
    valiance                        = {  95229, 432919, 1 }, -- Consuming Infusion of Light reduces the cooldown of Holy Armaments by 3.0 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blessed_hands           =   88, -- (199454)
    cleanse_the_weak        =  642, -- (199330)
    darkest_before_the_dawn =   86, -- (210378)
    denounce                = 5618, -- (2812) Casts down the enemy with a bolt of Holy Light, causing 45,667 Holy damage and preventing the target from causing critical effects for the next 8 sec.
    divine_plea             = 5663, -- (415244)
    divine_vision           =  640, -- (199324)
    hallowed_ground         = 3618, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure   = 5657, -- (355858)
    searing_glare           = 5583, -- (410126) Call upon the light to blind your enemies in a 25 yd cone, causing enemies to miss their spells and attacks for 4 sec.
    spellbreaker            = 5665, -- (469895) Eye for an Eye can now also trigger at 100% effectiveness from Magic damage.
    spreading_the_word      =   87, -- (199456)
    ultimate_sacrifice      =   85, -- (199452)
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blessed_hands           =   88, -- (199454)
    cleanse_the_weak        =  642, -- (199330)
    darkest_before_the_dawn =   86, -- (210378)
    denounce                = 5618, -- (2812) Casts down the enemy with a bolt of Holy Light, causing 33,481 Holy damage and preventing the target from causing critical effects for the next 8 sec.
    divine_vision           =  640, -- (199324)
    hallowed_ground         = 3618, -- (216868)
    judgments_of_the_pure   = 5657, -- (355858)
    searing_glare           = 5583, -- (410126) Call upon the light to blind your enemies in a 25 yd cone, causing enemies to miss their spells and attacks for 4 sec.
    spreading_the_word      =   87, -- (199456)
    ultimate_sacrifice      =   85, -- (199452)
    wrench_evil             = 5651, -- (460720)
} )


-- Auras
spec:RegisterAuras( {
    afterimage = {
        id = 385414,
    },
    afterimage_stacks = {
        id = 400745,
        duration = 3600,
        max_stack = 39,
    },
    aura_mastery = {
        id = 31821,
        duration = 8,
        max_stack = 1,
    },
    avenging_crusader = {
        id = 216331,
        duration = 15,
        max_stack = 1,
    },
    avenging_wrath = {
        id = 31884,
        duration = 25,
        max_stack = 1,
    },
    awakening = {
        id = 414196,
        duration = 60,
        max_stack = 15
    },
    awakening_ready = {
        id = 414193,
        duration = 30,
        max_stack = 1
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
        dot = "buff",
        friendly = true,
        no_ticks = true,
    },
    beacon_of_light = {
        id = 53563,
        duration = 3600,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true,
    },
    beacon_of_virtue = {
        id = 200025,
        duration = 8,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true,
    },
    bestow_faith = {
        id = 223306,
        duration = 5,
        max_stack = 1,
    },
    bestow_light = {
        id = 448086,
        duration = 3600,
        max_stack = 3
    },
    blessed_assurance = {
        id = 433019,
        duration = 20,
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
    -- Damage every $t1 sec.
    -- https://wowhead.com/beta/spell=26573
    consecration = {
        id = 26573,
        duration = 12,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        generate = function( c, type )
            if type == "buff" then
                local dropped, expires

                for i = 1, 5 do
                    local up, name, start, duration = GetTotemInfo( i )

                    if up and name == class.abilities.consecration.name then
                        dropped = start
                        expires = dropped + duration
                        break
                    end
                end

                if dropped and expires > query_time then
                    c.expires = expires
                    c.applied = dropped
                    c.count = 1
                    c.caster = "player"
                    return
                end
            end

            c.count = 0
            c.expires = 0
            c.applied = 0
            c.caster = "unknown"
        end
    },
    consecration_strength_of_conviction = {
        id = 188370,
        duration = 12,
        max_stack = 1,
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
    dawnlight = {
        id = 431522,
        duration = 30,
        max_stack = 2
    },
    dawnlight_dot = {
        id = 431380,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    dawnlight_hot = {
        id = 431381,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        friendly = true,
        dot = "buff"
    },
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,
        dot = "buff",
        shared = "player",
        friendly = true
    },
    divine_favor = {
        id = 210294,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    divine_plea = {
        id = 415246,
        duration = 15,
        max_stack = 1
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
    empyreal_ward = {
        id = 387791,
        duration = 30,
        max_stack = 1
    },
    forbearance = {
        id = 25771,
        duration = function() return talent.holy_reprieve.enabled and 20 or 30 end,
        max_stack = 1,
    },
    -- Your next Holy Light heals $s1% more, costs $s3% less mana, and is instant cast.
    hand_of_divinity = {
        id = 414273,
        duration = 20.0,
        max_stack = 2,
    },
    infusion_of_light = {
        id = 54149,
        duration = 15,
        max_stack = function() if talent.inflorescence_of_the_sunwell.enabled then
            return 2 end
            return 1
        end,
        copy = 53576
    },
    liberation = {
        id = 461471,
        duration = 20,
        max_stack = 1
    },
    light_of_the_martyr = {
        id = 196917,
        duration = 5.113,
        max_stack = 1,
    },
    maraads_dying_breath = {
        id = 388019,
        duration = 10,
        max_stack = 5,
    },
    mastery_lightbringer = {
        id = 183997,
    },
     -- Restores health to $210291s2 injured allies within $210291A1 yards every $t1 sec.
     merciful_auras = {
        id = 183415,
        duration = 0.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -18.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -18.0, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- aura_mastery[31821] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    of_dusk_and_dawn = {
        id = 385125,
    },
    overflowing_light = {
        id = 414133,
        duration = 8,
        max_stack = 1
    },
    -- $s1% of all effective healing done will be added onto your next Holy Shock.
    power_of_the_silver_hand = {
        id = 200656,
        duration = 10.0,
        max_stack = 1,
    },
    recompense = {
        id = 384914,
    },
    relentless_inquisitor = {
        id = 383389,
        duration = 12,
        max_stack = 5
    },
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1,
    },
    rising_sunlight = {
        id = 414204,
        duration = 30,
        max_stack = 4,
    },
    rule_of_law = {
        id = 214202,
        duration = 10,
        max_stack = 1,
    },
    seal_of_the_crusader = {
        id = 385723,
        duration = 3600,
        max_stack = 1,
    },
    shielding_words = {
        id = 338788,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    shining_righteousness = {
        id = 414444,
        duration = 30,
        max_stack = 5
    },
    shining_righteousness_ready = {
        id = 414445,
        duration = 30,
        max_stack = 1
    },
    tempered_in_battle = {
        id = 469704,
        duration = 4,
        max_stack = 1
    },
    tyrs_deliverance = {
        id = 200652,
        duration = 20,
        max_stack = 1,
        dot = 'buff'
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
    -- Hammer of Wrath can be used on any target.
    veneration = {
        id = 392939,
        duration = 15.0,
        max_stack = 1,
    },
} )

-- Current Expansion
spec:RegisterGear( "tww2", 229244, 229242, 229243, 229245, 229247 )

-- Legacy

spec:RegisterGear( "tier31", 207189, 207190, 207191, 207192, 207194 )
spec:RegisterAuras( {
    holy_reverberation = { -- TODO: Is actually multiple applications, not true stacks; check SimC.
        id = 423377,
        duration = 8,
        max_stack = 6,
        friendly = true,
        copy = { "holy_reverberation_heal", "holy_reverberation_buff" }
    },
    holy_reverberation_dot = {
        id = 423379,
        duration = 8,
        max_stack = 6,
        copy = { "holy_reverberation_dmg", "holy_reverberation_debuff" }
    },
    first_light = {
        id = 427946,
        duration = 6,
        max_stack = 1
    }
} )


spec:RegisterGear( "tier30", 202455, 202453, 202452, 202451, 202450, 217198, 217200, 217196, 217197, 217199 )
-- 2pc is based on crits which aren't guaranteed, so we can't proactively model them.

local HandleAwakening = setfenv( function()
    if talent.awakening.enabled then
        if buff.awakening.stack == buff.awakening.max_stack - 1 then
            removeBuff( "awakening" )
            applyBuff( "awakening_ready" )
        else
            addStack( "awakening" )
        end
    end
end, state )


spec:RegisterHook( "reset_precast", function()
    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end

    if talent.holy_armaments.enabled then
        if IsSpellKnownOrOverridesKnown( 432472 ) then
            applyBuff( "sacred_weapon_ready" )
            removeBuff( "holy_bulwark_ready" )
        else
            applyBuff( "holy_bulwark_ready" )
            removeBuff( "sacred_weapon_ready" )
            end
    end
end )

spec:RegisterHook( "spend", function( amt, resource )

    if amt > 0 and resource == "holy_power" then
        if talent.tirions_devotion.enabled then
            reduceCooldown( "lay_on_hands", amt * 1.5 )
        end

        if talent.relentless_inquisition.enabled then
            addStack( "relentless_inquisitor" )
        end

        if talent.blessed_assurance.enabled then
            applyBuff( "blessed_assurance" )
        end

        if talent.unending_light.enabled and this_action == "word_of_glory" then
            addStack( "unending_light", nil, amt )
        end
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
        key = "avenging_crusader",
        id = 216331,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = false,
        texture = 589117,
        talent = "avenging_crusader",

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avenging_crusader" )
            if talent.rising_sunlight.enabled then addStack( "rising_sunlight", nil, 2 ) end
        end,

        bind = { "avenging_wrath", "sanctified_wrath" }
    },


    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        toggle = "cooldowns",
        notalent = "avenging_crusader",

        handler = function ()
            applyBuff( "avenging_wrath" )
            if talent.rising_sunlight.enabled then addStack( "rising_sunlight", nil, 2 ) end
        end,

        bind = { "avenging_crusader", "sanctified_wrath" }
    },


    barrier_of_faith = {
        id = 148039,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.024,
        spendType = "mana",

        startsCombat = false,
        texture = 4067370,

        handler = function ()
            applyBuff( "barrier_of_faith" )
            if talent.dawnlight.enabled then applyBuff( "dawnlight", nil, 2 ) end
        end,
    },


    beacon_of_faith = {
        id = 156910,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 1030095,
        talent = "beacon_of_faith",

        handler = function ()
            applyBuff( "beacon_of_faith" )
            active_dot.beacon_of_faith = 1
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
        talent = "beacon_of_light",

        handler = function ()
            applyBuff( "beacon_of_light" )
            active_dot.beacon_of_light = 1
        end,
    },


    beacon_of_virtue = {
        id = 200025,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.045,
        spendType = "mana",

        startsCombat = false,
        texture = 1030094,
        talent = "beacon_of_virtue",

        handler = function ()
            applyBuff( "beacon_of_virtue" )
            active_dot.beacon_of_virtue = min( 5, group_members )
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
        gcd = "off",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636843,
        buff = "blessing_of_autumn_active",

        handler = function ()
            removeBuff( "blessing_of_autumn_active" )
            applyBuff( "blessing_of_winter_active" )

            setCooldown( "blessing_of_winter", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,

        bind = { "blessing_of_winter", "blessing_of_spring", "blessing_of_summer" },

        auras = {
            blessing_of_autumn_active = {
                duration = 3600,
                max_stack = 1,
                generate = function( t )
                    if IsActiveSpell( 388010 ) then
                        t.name = t.name or strformat( "%s %s", class.auras.blessing_of_autumn.name, SPEC_ACTIVE )
                        t.count = 1
                        t.applied = now
                        t.expires = now + 3600
                        t.caster = "player"
                        return
                    end

                    t.count = 0
                    t.applied = 0
                    t.expires = 0
                    t.caster = "nobody"
                end,
            }
        }
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
        cooldown = function() return talent.sacrifice_of_the_just.enabled and 105 or 120 end,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135966,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "blessing_of_sacrifice" )
            if talent.righteous_protection.enabled then
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_disease" )
            end
        end,
    },


    blessing_of_spring = {
        id = 388013,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636844,
        buff = "blessing_of_spring_active",

        handler = function ()
            removeBuff( "blessing_of_spring_active" )
            applyBuff( "blessing_of_summer_active" )

            setCooldown( "blessing_of_summer", 45 )
            setCooldown( "blessing_of_autumn", 90 )
            setCooldown( "blessing_of_winter", 135 )
        end,

        bind = { "blessing_of_autumn", "blessing_of_winter", "blessing_of_summer" },

        auras = {
            blessing_of_spring_active = {
                duration = 3600,
                max_stack = 1,
                generate = function( t )
                    if IsActiveSpell( 388013 ) then
                        t.name = t.name or strformat( "%s %s", class.auras.blessing_of_spring.name, SPEC_ACTIVE )
                        t.count = 1
                        t.applied = now
                        t.expires = now + 3600
                        t.caster = "player"
                        return
                    end

                    t.count = 0
                    t.applied = 0
                    t.expires = 0
                    t.caster = "nobody"
                end,
            }
        }
    },


    blessing_of_summer = {
        id = 388007,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636845,
        buff = "blessing_of_summer_active",

        handler = function ()
            removeBuff( "blessing_of_summer_active" )
            applyBuff( "blessing_of_autumn_active" )

            setCooldown( "blessing_of_autumn", 45 )
            setCooldown( "blessing_of_winter", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,

        bind = { "blessing_of_autumn", "blessing_of_winter", "blessing_of_spring" },

        auras = {
            blessing_of_summer_active = {
                duration = 3600,
                max_stack = 1,
                generate = function( t )
                    if IsActiveSpell( 388007 ) or IsActiveSpell( 328620 ) then
                        t.name = t.name or strformat( "%s %s", class.auras.blessing_of_summer.name, SPEC_ACTIVE )
                        t.count = 1
                        t.applied = now
                        t.expires = now + 3600
                        t.caster = "player"
                        return
                    end

                    t.count = 0
                    t.applied = 0
                    t.expires = 0
                    t.caster = "nobody"
                end,
            }
        }
    },


    blessing_of_winter = {
        id = 388011,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636846,
        buff = "blessing_of_winter_active",
        nobuff = function()
            if solo then return "blessing_of_autumn" end
        end,

        handler = function ()
            removeBuff( "blessing_of_winter_active" )
            applyBuff( "blessing_of_spring_active" )

            setCooldown( "blessing_of_spring", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_autumn", 135 )
        end,

        bind = { "blessing_of_autumn", "blessing_of_spring", "blessing_of_summer" },

        auras = {
            blessing_of_winter_active = {
                duration = 3600,
                max_stack = 1,
                generate = function( t )
                    if IsActiveSpell( 388011 ) then
                        t.name = t.name or strformat( "%s %s", class.auras.blessing_of_winter.name, SPEC_ACTIVE )
                        t.count = 1
                        t.applied = now
                        t.expires = now + 3600
                        t.caster = "player"
                        return
                    end

                    t.count = 0
                    t.applied = 0
                    t.expires = 0
                    t.caster = "nobody"
                end,
            }
        }
    },

    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = function() return talent.lights_countenance.enabled and 75 or 90 end,
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
        cooldown = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

        toggle = "interrupts",
        usable = function() return buff.dispellable_magic.up or talent.improved_cleanse.enabled and ( buff.dispellable_poison.up or buff.dispellable_disease.up ), "requires a dispellable effect" end,

        handler = function ()
            removeBuff( "player", "dispellable_magic" )
            if talent.improved_cleanse.enabled then
                removeBuff( "player", "dispellable_poison" )
                removeBuff( "player", "dispellable_disease" )
            end
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

        talent = "auras_of_the_resolute",
        startsCombat = false,
        texture = 135890,
        nobuff = "paladin_aura",

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
        charges = function() return buff.avenging_crusader.up and 3 or 2 end,
        cooldown = function() return 6 * ( buff.avenging_crusader.up and 0.7 or 1 ) end,
        recharge = function() return 6 * ( buff.avenging_crusader.up and 0.7 or 1 ) end,
        gcd = "spell",

        spend = 0.006,
        spendType = "mana",

        startsCombat = true,
        texture = 135891,

        handler = function ()
            gain( 1, "holy_power" )
            removeBuff( "liberation" )

            if talent.crusaders_might.enabled then
                reduceCooldown( "holy_shock", 2 )
                reduceCooldown( "judgment", 2 )
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
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 135915,

        handler = function ()
            applyBuff( "divine_favor" )
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
        nodebuff = function() if not talent.lights_revocation.enabled then return "forbearance" end end,

        handler = function ()
            applyDebuff( "forbearance" )
            applyBuff( "divine_shield" )
        end,
    },


    divine_steed = {
        id = 190784,
        cast = 0,
        charges = 2,
        cooldown = function() return 45 * ( talent.divine_spurs.enabled and 0.8 or 1 ) end,
        recharge = 45,
        gcd = "off",

        startsCombat = false,
        texture = 1360759,

        handler = function ()
            applyBuff( "divine_steed" )
        end,
    },


    flash_of_light = {
        id = 19750,
        cast = function() return 1.5 * ( buff.divine_favor.up and 0.7 or 1 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.06 * ( buff.divine_favor.up and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            if buff.infusion_of_light.up then
                removeStack( "infusion_of_light" )
                if talent.valiance.enabled then reduceCooldown( "holy_armaments", 3 ) end
                if talent.imbued_infusions.enabled then reduceCooldown( "holy_shock", 1) end
            end
            removeBuff( "divine_favor" )
            if talent.boundless_salvation.enabled and buff.tyrs_deliverance.up then
                buff.tyrs_deliverance.expires = buff.tyrs_deliverance.expires + 4
            end
            if talent.tower_of_radiance.enabled then gain( 1, "holy_power" ) end
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
        cooldown = function() return 45 - ( 15 * talent.fist_of_justice.rank ) end,
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

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 613533,

        usable = function ()
            return target.health_pct < 20 or buff.veneration.up or talent.avenging_wrath.enabled and ( buff.avenging_wrath.up or buff.avenging_crusader.up ), "requires target below 20% health, veneration, or avenging_wrath active"
        end,

        handler = function ()
            removeBuff( "veneration" )
            gain( 1, "holy_power" )
            HandleAwakening()
        end,
    },

    -- Call upon the Light to empower your spells, causing your next $n Holy Lights to heal $s1% more, cost $s3% less mana, and be instant cast.
    hand_of_divinity = {
        id = 414273,
        cast = 1.5,
        cooldown = 90.0,
        gcd = "spell",

        talent = "hand_of_divinity",
        startsCombat = false,

        handler = function()
            addStack( "hand_of_divinity", nil, 2 )
        end
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


    -- TODO: Verify if removed (or not).
    holy_light = {
        id = 82326,
        cast = function () return buff.hand_of_divinity.up and 0 or 2 end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.07 * ( buff.hand_of_divinity.up and 0.5 or 1 ) * ( buff.divine_favor.up and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135981,

        handler = function ()
            removeBuff( "divine_favor" )
            removeStack( "hand_of_divinity" )
            removeBuff( "liberation" )

            if buff.infusion_of_light.up then
                removeStack( "infusion_of_light" )
                if talent.valiance.enabled then reduceCooldown( "holy_armaments", 3 ) end
                if talent.imbued_infusions.enabled then reduceCooldown( "holy_shock", 1) end
            end
            if talent.boundless_salvation.enabled and buff.tyrs_deliverance.up then
                buff.tyrs_deliverance.expires = buff.tyrs_deliverance.expires + 8
            end
            if talent.tower_of_radiance.enabled then gain( 1, "holy_power" ) end
        end,
    },


    holy_prism = {
        id = 114165,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.026,
        spendType = "mana",

        startsCombat = true,
        texture = 613408,

        handler = function ()
            if talent.dawnlight.enabled then applyBuff( "dawnlight", nil, 2 ) end
            if set_bonus.tier30_4pc > 0 then
                gain( 1, "holy_power" )
                HandleAwakening()
            end
        end,
    },


    holy_shock = {
        id = 20473,
        cast = 0,
        cooldown = function() return ( 8.5 - ( 1 * talent.imbued_infusions.rank ) - ( 2 * talent.crusaders_might.rank ) ) * ( talent.sanctified_wrath.enabled and buff.avenging_wrath.up and 0.5 or 1 ) end,
        charges = function() return talent.lights_conviction.enabled and 2 or nil end,
        recharge = function() return talent.lights_conviction.enabled and ( ( 8.5 - ( 2 * talent.imbued_infusions.rank ) - ( 2 * talent.crusaders_might.rank ) ) * ( talent.sanctified_wrath.enabled and buff.avenging_wrath.up and 0.5 or 1 ) ) or nil end,
        gcd = "spell",

        spend = 0.028,
        spendType = "mana",

        startsCombat = true,
        texture = 135972,

        handler = function ()
            local times = buff.rising_sunlight.up and 3 or 1

            for i = 1, times do
                gain( 1, "holy_power" )
                HandleAwakening()

                removeBuff( "power_of_the_silver_hand" )
                removeStack( "rising_sunlight" )

                if talent.boundless_salvation.enabled and buff.tyrs_deliverance.up then
                    buff.tyrs_deliverance.expires = buff.tyrs_deliverance.expires + 2
                end

                if talent.light_of_the_martyr.enabled and health.pct > ( talent.bestow_light.enabled and 70 or 80 ) then
                    applyDebuff( "player", "light_of_the_martyr" )
                end

                if talent.overflowing_light.enabled then applyBuff( "overflowing_light" ) end
            end

            removeStack( "rising_sunlight" )
        end,
    },


    intercession = {
        id = 391054,
        cast = 2,
        cooldown = 600,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,
        texture = 4726195,

        handler = function ()
            spend( 0.02 * mana.max, "mana" )
        end,
    },


    judgment = {
        id = 275773,
        cast = 0,
        cooldown = function() return ( 12 - ( 0.5 * talent.seal_of_alacrity.rank ) - ( 2 * talent.crusaders_might.rank ) )  * ( buff.avenging_crusader.up and 0.7 or 1 ) end,
        gcd = "spell",

        spend = 0.024,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
            gain( 1, "holy_power" )
            HandleAwakening()

            if buff.infusion_of_light.up then
                removeStack( "infusion_of_light" )
                if talent.valiance.enabled then reduceCooldown( "holy_armaments", 3 ) end
                if talent.imbued_infusions.enabled then reduceCooldown( "holy_shock", 1) end
            end

            removeBuff( "liberation" )

            if talent.empyrean_legacy.enabled and debuff.empyrean_legacy_icd.down then
                applyBuff( "empyrean_legacy" )
                applyDebuff( "player", "empyrean_legacy_icd" )
            end
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
            applyDebuff( "player", "forbearance" )
            if talent.empyreal_ward.enabled then applyBuff( "empyreal_ward" ) end
            if talent.tirions_devotion.enabled then gain( 0.05 * mana.max, "mana" ) end
        end,
    },


    light_of_dawn = {
        id = 85222,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up or buff.shining_righteousness_ready.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 461859,

        handler = function ()
            if talent.blessed_assurance.enabled then applyBuff( "blessed_assurance" ) end
            spend( 0.18 * mana.max, "mana" )
            if buff.divine_purpose.down and buff.shining_righteousness_ready.down then addStack( "afterimage_stacks", nil, 3 ) end
            if buff.dawnlight.up then
                applyBuff( "dawnlight_hot" )
                removeStack( "dawnlight" )
            end
            removeBuff( "divine_purpose" )
            removeBuff( "shining_righteousness_ready" )
            if talent.maraads_dying_breath.enabled then applyBuff( "maraads_dying_breath" ) end
            removeBuff( "unending_light" )
        end,
    },


    light_of_the_martyr = {
        id = 183998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.016,
        spendType = "mana",

        startsCombat = false,
        texture = 1360762,

        handler = function ()
            removeBuff( "maraads_dying_breath" )
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


    shield_of_the_righteous = {
        id = 415091,
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
        equipped = "shield",


        handler = function ()
            if talent.blessed_assurance.enabled then applyBuff( "blessed_assurance" ) end

            if buff.divine_purpose.down and buff.shining_righteousness_ready.down then addStack( "afterimage_stacks", nil, 3 ) end
            removeBuff( "divine_purpose" )
            reduceCooldown( "crusader_strike", 1.5 )

            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end

            if talent.shining_righteousness.enabled then
                if buff.shining_righteousness.stack == buff.shining_righteousness.max_stack - 1 then
                    removeBuff( "shining_righteousness" )
                    applyBuff( "shining_righteousness_ready" )
                else
                    addStack( "shining_righteousness" )
                end
            end
        end,

        copy = 53600
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
            active_dot.tyrs_deliverance = group_members
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
            gain( 1, "holy_power" )
            HandleAwakening()
            applyBuff( "vanquishers_hammer" )
        end,
    },


    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up or buff.shining_righteousness_ready.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 133192,

        handler = function ()
            if talent.blessed_assurance.enabled then applyBuff( "blessed_assurance" ) end
            if buff.afterimage_stacks.stack >= 20 then removeStack( "afterimage_stacks", 20 ) end
            if buff.dawnlight.up then
                applyBuff( "dawnlight_hot" )
                removeStack( "dawnlight" )
            end
            if buff.divine_purpose.down and buff.shining_righteousness_ready.down then addStack( "afterimage_stacks", nil, 3 ) end

            removeBuff( "divine_purpose" )
            removeBuff( "shining_righteousness_ready" )
            removeBuff( "empyrean_legacy" )


            spend( 0.06, "mana" )

            if talent.faiths_armor.enabled then applyBuff( "faiths_armor" ) end
        end
    },


    eternal_flame = {
        id = 156322,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up or buff.shining_righteousness_ready.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 135433,

        handler = function ()
            removeBuff( "divine_purpose" )
            removeBuff( "shining_righteousness_ready" )
            applyBuff( "eternal_flame" )
        end,

        copy = 461432
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterRanges( "judgment", "hammer_of_justice", "crusader_strike", "holy_shock" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Holy Paladin",
} )


spec:RegisterPack( "Holy Paladin", 20240908, [[Hekili:9E1xVnUnm8pl3lPTyTEojTnPdn9HT9WUUHIdihW9MTvSLT1ITKNKCYfGa9zFuYXoY)lTpSBOanjIuKuu)i5p5n17RERJqsS3BZCNDV7tUlDM(0dp(W9ERLhkWERlqHBrjWxOOC4))bl7Gk4lOmueHQLEiJHI0wrWk5HGgER3usYKFM6TzitpvBArbo07ThFWBDkjkcxPkwec2hJYWCvqbNW4ejblubiowf87Fz9DXSWsbosfWOqu8Q6vTHVZDXDZDVvf4(0DUl)fvWxtb1)gcmY3iYuDuMresHjglW0imx)93mhDmfTjdh59RERdb3H5eK(KKXubtubxRcsH4rM6uekvbpRcw4QcoEuf8jva(Fkjff4ihrkbNbb1nM9SPmowVeLqt85KKujMvkOyHWNJrrhCklQmHrrCEXbyzQFgobfQf6TgfkjmiQ3Z4r(Sy)Kmg)GNesJJgXjCM2SFm3F2dzA5AxeH2t1EyU2d1sRoxAXYu8zBzhcs4p4IlgvMjBYP17NJ3uUf3w9QZqTgODyAIoq3ZrY0oAoFqnd5LceCf2r57TvofWO(iEoayPYoX7BpyRjSSqOnlCifL559S7JJPnQuwMt7O9IX0EpHk7z7LJgja4NM0r7NS12CXj8)7YOe9zSJQtDT1TGv9zBvgh9BqqBYySOSsHSnCT9f2iYQVIAb1IjaCqBuJ3BHcGsAFW55DVPMoF0yek)KqFcQCaVEAdvrwiJLfX2thqpoohrOq7LxubjHro5OVxThd8PGTh0bG2Kqcu6VcAVavesojuhzNd(quwMF1p81TzQA24x1SSPDJEpTGOrKDek2xYYY6EQFOhugGdI8UQ94LBgyHSWOqi4aC1ocxwIn7EXO7(9ZRqxM4s4uZXHPiEcCki5yt3XtPrRSZPn7RZCBRC9Y)FCDtTH2NpDjKeKDe4qaqd7Z5uB0kR40j(DiuFoIQNg2CcT2SP)wRAVuKUNIPdWaD4M1QD5ifZZM1dpiszHB7Q24fln1aN38qG)lERnRf6fXdrg0lN3lGHFwaxpS8ni5LhZA6AuuXKa6NYro6O0QgbVZ06Yi7YZ)0Bzh2pIjDod3nnjRlD7xnye3mO5DgRoOdIra)IXDGrSjJa5KDqBaT8kUqlDbQp7rC9uAOTNHXcjVGXH4nMbmxU60q1RubCnrdUg9lyAWom5HLd0QGfGIaamkCuV(xq3evW05a9NFJrbNzKF1yvuGzLSliVUId076PF)MZoyXpAhS8hMduV(ztgwB251v4Qad3qqSg2YIjzn12cNgC8pT6NBbgVLeVAy0R61H2ChqNE7JJyx5(EgXaS0gXGpNmo2uBQgJbMOIrM9kThOpOK6mQTW2mSSLSPhJQXKwXGAmPvmMg1Yggs2s7WiYwufbi7vAiJ0CrAZ354XH560DDlEo2gVHoJ9IDPjCRMGWQA(b3wrSy1uD88PXG0hp((SzE5uZ8Jh7ZIXcyPb0NzG07M1q4OvUVdhIgWxRZy7XgADg7OmP)u8NR5GzzX6BZ)dmL9CAtwUZu)jvQo6e)w5O2t1hkI7LsnJDFNS1fgu)YahP2tHTQ0DQXvGsTEeP2j6h3o56ZpR95fUhp(PopM9MjFG3rEQEO)tyhmqA9wZZnV(a(zqZn6JtH2kPm4Pw)jGxyBH(ZuIzcS3)(d]] )