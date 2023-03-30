-- PaladinRetribution.lua
-- October 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 70 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yds, causing them to wander disoriented for 6 sec. Non-Holy damage will break the disorient effect.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    crusaders_reprieve              = { 81543, 403042, 1 }, -- Increases the range of your Crusader Strike, Rebuke and auto-attacks by 3 yds. Using Crusader Strike heals you for 2% of your maximum health.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for 6 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast Judgment on up to 5 targets within 30 yds. Divine Toll's Judgment deals 100% increased damage.
    fading_light                    = { 81623, 405768, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for 20% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- Word of Glory grants 20% bonus armor for 4.5 sec.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 98 every 0.9 sec.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection by 60 sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 797 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next 5 successful attacks against the target to heal the attacker for 372.
    justification                   = { 81509, 377043, 1 }, -- Judgment's damage is increased by 10%.
    obduracy                        = { 81630, 385427, 1 }, -- Speed and Avoidance increased by 2%.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- When you cast 3 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals 10% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by 5% For 10 sec.
    punishment                      = { 93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke casts an extra Crusader Strike.
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for 60 sec. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_plates               = { 93009, 402964, 2 }, -- Armor increased by 10%, Stamina increased by 5% and damage taken from area of effect attacks reduced by 5%.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by 2% and Judgment cooldown reduced by 0.5 sec.
    seal_of_mercy                   = { 81611, 384897, 1 }, -- Golden Path strikes the lowest health ally within it an additional time for 100% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- Mastery increased by 2% and strength increased by 2%.
    seal_of_order                   = { 81623, 385129, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk increases your armor by 10% and your Holy Power generating abilities cool down 10% faster.
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your auto attacks deal 111 additional Holy damage.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by 2 sec.
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your Shield of the Righteous and Word of Glory have 10% increased damage and healing.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 664 Holy damage or healing an ally for 884 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Divine Protection, and Lay on Hands by 30%.

    -- Retribution
    adjudication                    = { 81537, 406157, 1 }, -- Critical Strike damage of your abilities increased by 5% and Hammer of Wrath critical strikes cause a Blessed Hammer to spiral outward dealing 432 Holystrike damage to enemies.
    aegis_of_protection             = { 81550, 403654, 1 }, -- Divine Protection reduces damage you take by an additional 10% and Shield of Vengeance absorbs 20% more damage.
    afterimage                      = { 93189, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness
    art_of_war                      = { 81523, 406064, 1 }, -- Your auto attacks have a 20% chance to reset the cooldown of Blade of Justice.
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- Learn Retribution Aura and Crusader Aura:  Retribution Aura: When any party or raid member within 40 yds takes more than 30% of their health in damage in a single hit, each member gains 5% increased damage and healing, decaying over 30 sec. This cannot occur within 30 sec of the aura being applied.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yds.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yds are 30% shorter.  Devotion Aura: Party and raid members within 40 yds are bolstered by their devotion, reducing damage taken by 3%.
    avenging_wrath_might            = { 81525, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, increasing your critical strike chance by 20% for X sec.
    blade_of_justice                = { 81526, 184575, 1 }, -- Pierce an enemy with a blade of light, dealing 5,019 Physical damage. Generates 1 Holy Power.
    blade_of_vengeance              = { 81545, 403826, 1 }, -- Blade of Justice now hits nearby enemies for 3,012 Physical damage. Deals reduced damage beyond 5 targets.
    blades_of_light                 = { 93164, 403664, 1 }, -- Crusader Strike, Judgment, Hammer of Wrath and your damaging single target Holy Power abilities deal Holystrike damage.
    blessed_champion                = { 81541, 403010, 2 }, -- Crusader Strike and Judgment hit an additional 2 targets but deal 40% reduced damage to secondary targets.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    boundless_judgment              = { 81533, 405278, 1 }, -- Judgment generates 1 additional Holy Power.
    burning_crusade                 = { 81536, 405289, 1 }, -- Divine Storm, Divine Hammer and Consecration now deal Radiant damage and your abilities that deal Radiant damage deal 10% increased damage.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_blade               = { 81516, 404834, 1 }, -- Blade of Justice casts Consecration at the target's location. This effect can only occur every 10 sec.
    consecrated_ground              = { 81512, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed. Your Divine Hammer is 25% larger, and enemies within them have 30% reduced movement speed.
    crusade                         = { 81525, 231895, 1 }, -- Call upon the Light and begin a crusade, increasing your haste and damage by 3% for 25 sec. Each Holy Power spent during Crusade increases haste and damage by an additional 3%. Maximum 10 stacks. Hammer of Wrath may be cast on any target. Combines with Avenging Wrath.
    crusading_strikes               = { 93186, 404542, 1 }, -- Crusader Strike replaces your auto-attacks and deals 1,185 Physical damage, but now only generates 1 Holy Power every 2 attacks. Inherits Crusader Strike benefits but cannot benefit from Windufry.
    divine_arbiter                  = { 81540, 404306, 1 }, -- Abilities that deal Holystrike damage deal 10% increased damage and casting abilities that deal Holystrike damage grants you a stack of Divine Arbiter. At 25 stacks your next damaging single target Holy Power ability causes 10,273 Holystrike damage to your primary target and 3,081 Holystrike damage to enemies within 6 yds.
    divine_auxiliary                = { 81538, 406158, 1 }, -- Final Reckoning and Execution Sentence grant 3 Holy Power.
    divine_hammer                   = { 81516, 198034, 1 }, -- Divine Hammers spin around you, damaging enemies within 8 yds for 2,587 Holy damage over 12 sec. Deals reduced damage beyond 8 targets.
    divine_purpose                  = { 81618, 408459, 1 }, -- Holy Power abilities have a 10% chance to make your next Holy Power ability free and deal 10% increased damage and healing.
    divine_resonance                = { 93181, 384027, 1 }, --
    divine_storm                    = { 81527, 53385 , 1 }, -- Unleashes a whirl of divine energy, dealing 2,362 Holy damage to all nearby enemies. Deals reduced damage beyond 5 targets.
    divine_wrath                    = { 93160, 406872, 1 }, -- Increases the duration of Avenging Wrath or Crusade by 3 sec.
    empyrean_legacy                 = { 81545, 387170, 1 }, -- Judgment empowers your next Single target Holy Power ability to automatically activate Divine Storm with 25% increased effectiveness. This effect can only occur every 20 sec.
    empyrean_power                  = { 92860, 326732, 1 }, -- Crusader Strike has a 15% chance to make your next Divine Storm free and deal 15% additional damage.
    execution_sentence              = { 81539, 343527, 1 }, -- A hammer slowly falls from the sky upon the target, after 8 sec, they suffer 8,466 Holy damage, plus 20% of damage taken from your abilities in that time.
    executioners_will               = { 81548, 406940, 1 }, -- Final Reckoning and Execution Sentence's durations are increased by 4 sec.
    expurgation                     = { 92689, 383344, 1 }, -- Your Blade of Justice causes the target to burn for 1,847 of the damage dealt as Radiant damage over 6 sec.
    final_reckoning                 = { 81539, 343721, 1 }, -- Call down a blast of heavenly energy, dealing 7,533 Holy damage to all targets in the target area and causing them to take 30% increased damage from your Holy Power abilities for 10 sec.
    final_verdict                   = { 81532, 383328, 1 }, -- Unleashes a powerful weapon strike that deals 3,739 Holy damage to an enemy target, Final Verdict has a 15% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take 20% increased damage from your next Holy Power ability.
    guided_prayer                   = { 81531, 404357, 1 }, -- When your health is brought below 25%, you instantly cast a free Word of Glory at 100% effectiveness on yourself. Cannot occur more than once every 60 sec.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for 3,835 Holy damage. Only usable on enemies that have less than 20% health, or during Avenging Wrath. Generates 1 Holy Power.
    healing_hands                   = { 93189, 326734, 1 }, -- The cooldown of Lay on Hands is reduced up to 60%, based on the target's missing health. Word of Glory's healing is increased by up to 100%, based on the target's missing health.
    heart_of_the_crusader           = { 93190, 406154, 1 }, -- Crusader Strike and auto-attacks deal 10% inceased damage and deal 10% increased critical strike damage.
    highlords_judgment              = { 81534, 404512, 2 }, -- Judgment's duration is increased by 3 sec. If you have Greater Judgment, targets take 20% increased damage from your next 2 Holy Power abilities.
    holy_blade                      = { 92838, 383342, 1 }, -- Blade of Justice generates 1 additional Holy Power.
    improved_blade_of_justice       = { 92838, 403745, 1 }, -- Blade of Justice now has 2 charges.
    improved_judgment               = { 81533, 405461, 1 }, -- Judgment now has 2 charges.
    inquisitors_ire                 = { 92951, 403975, 1 }, -- Every 2 sec, gain 5% increased damage to your next Divine Storm, stacking up to 10 times.
    judge_jury_and_executioner      = { 92860, 405607, 1 }, -- Increases the critical strike chance of Judgment 10%.
    judgment_of_justice             = { 93161, 403495, 1 }, -- Judgment deals 10% increased damage and increases your movement speed by 10%. If you have Greater Judgment, Judgment slows enemies by 30% for 8 sec.
    jurisdiction                    = { 81542, 402971, 1 }, -- Templar's Verdict and Blade of Justice deal 10% increased damage. The range of Blade of Justice is increased to 20 yds.
    justicars_vengeance             = { 81532, 215661, 1 }, -- Focuses Holy energy to deliver a powerful weapon strike that deals 3,410 Holy damage, and restores 6% of your maximum health. Damage is increased by 25% when used against a stunned target.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    light_of_justice                = { 81521, 404436, 1 }, -- Reduces the cooldown of Blade of Justice by 2 sec.
    lightforged_blessing            = { 93008, 403479, 1 }, -- Divine Storm heals you and up to 4 nearby allies for 3% of maximum health.
    lights_celerity                 = { 81531, 403698, 1 }, -- Flash of Light casts instantly, its healing done is increased by 50%, but it now has a 6 sec cooldown.
    penitence                       = { 92839, 403026, 1 }, -- Your damage over time effects deal 15% more damage.
    quickened_invocation            = { 93181, 379391, 1 }, -- Divine Toll's cooldown is reduced by 15 sec.
    righteous_cause                 = { 81523, 402912, 1 }, -- Templar's Verdict, Final Verdict and Justicar's Vengeance have a 20% chance to reset the cooldown of Blade of Justice.
    rush_of_light                   = { 81512, 407067, 1 }, -- The critical strikes of you damaging single target Holy Power abilities grant you 5% Haste for 10 sec.
    sanctify                        = { 92688, 382536, 1 }, -- Enemies hit by Divine Storm take 25% more damage from Consecration and Divine Hammers for 12 sec.
    searing_light                   = { 81552, 404540, 1 }, -- Your abilities that deal Radiant damage have a chance to call down an explosion of Holy Fire dealing 6,848 Radiant damage to all nearby enemies and leaving a Consecration in its wake. Deals reduced damage beyond 8 targets.
    seething_flames                 = { 81549, 405355, 1 }, -- Wake of Ashes deals significantly reduced damage to secondary targets, but now causes you to lash out 2 extra times for 4,766 Radiant damage.
    shield_of_vengeance             = { 81544, 184662, 1 }, -- Creates a barrier of holy light that absorbs 17,463 damage for 15 sec. When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    swift_justice                   = { 81521, 383228, 1 }, -- Reduces the cooldown of Judgment by 2 sec and Crusader Strike by 2 sec.
    tempest_of_the_lightbringer     = { 92951, 383396, 1 }, -- Divine Storm projects an additional wave of light, striking all enemies up to 20 yards in front of you for 20% of Divine Storm's damage.
    templar_strikes                 = { 93186, 406646, 1 }, -- Crusader Strike becomes a 2 part combo. Templar Strike slashes an enemy for 2,739 Radiant damage. You have 3 sec to continue the combo. Templar Slash strikes an enemy for 3,287 Radiant damage and has a 100% increased chance to critically strike. Inherits Crusader Strike benefits.
    truths_wake                     = { 92686, 403696, 1 }, -- Wake of Ashes also causes targets to burn for an additional 4,618 Radiant damage over 9 sec.
    unbound_freedom                 = { 93174, 305394, 1 }, -- Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target.
    vanguard_of_justice             = { 93173, 406545, 1 }, -- Your damaging Holy Power abilities cost 1 additional Holy Power and deal 25% increased damage.
    vanguards_momentum              = { 92688, 383314, 1 }, -- Hammer of Wrath has 1 extra charge and on enemies below 20% health generates 1 additional Holy Power.
    vengeful_wrath                  = { 93177, 406835, 1 }, -- Hammer of Wrath always critically strikes.
    wake_of_ashes                   = { 92854, 255937, 1 }, -- Lash out at your enemies, dealing 7,944 Radiant damage to all enemies within 14 yds in front of you and reducing their movement speed by 50% for 9 sec. Demon and Undead enemies are also stunned for 5 sec. Generates 3 Holy Power.
    zealots_fervor                  = { 92952, 403509, 1 }, -- Auto-attack speed increased by 20%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning     = 756 , -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain 1 additional stack if you are the victim. At 50 stacks of Reckoning, your next weapon swing deals 200% increased damage, will critically strike, and activates Avenging Wrath for 6 sec.
    blessing_of_sanctuary = 752 , -- (210256) Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by 60% for 5 sec.
    divine_punisher       = 755 , -- (204914) Casting two consecutive Judgments on the same enemy will generate 3 Holy Power.
    hallowed_ground       = 5535, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure = 5422, -- (355858) Casting Judgment on an enemy cleanses 1 Poison, Disease, and Magic effect they have caused on allies within your Aura.
    jurisdiction          = 757 , -- (204979) Increase the range of Blade of Justice and Hammer of Justice by 10 yds, and radius of Divine Storm by 4 yds.
    law_and_order         = 858 , -- (204934) When your Hand of Hindrance is dispelled or otherwise removed early, the cooldown is reduced by 15 sec. Your Blade of Justice applies Hand of Hindrance to the target for 3 sec.
    lawbringer            = 754 , -- (246806) Judgment now applies Lawbringer to initial targets hit for 1 min. Casting Judgment on an enemy causes all other enemies with your Lawbringer effect to suffer up to 10% of their maximum health in Holy damage.
    luminescence          = 81  , -- (199428) When healed by an ally, allies within your Aura gain 4% increased damage and healing for 6 sec.
    ultimate_retribution  = 753 , -- (355614) Mark an enemy player for retribution after they kill an ally within your Retribution Aura. If the marked enemy is slain within 8 sec, cast Redemption on the fallen ally.
    unbound_freedom       = 641 , -- (305394) Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target. Unbound Freedom also causes any Blessing of Freedom applied to yourself to be undispellable.
    vengeance_aura        = 751 , -- (210323) When a full loss of control effect is applied to you or an ally within your Aura, gain 6% critical strike chance for 8 sec. Max 2 stacks.
} )


-- Auras
spec:RegisterAuras( {
    -- Damage taken reduced by $w1%.  The next attack that would otherwise kill you will instead bring you to $w2% of your maximum health.
    -- https://wowhead.com/beta/spell=31850
    ardent_defender = {
        id = 31850,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Silenced.
    -- https://wowhead.com/beta/spell=31935
    avengers_shield = {
        id = 31935,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Crusader Strike and Judgment cool down $w2% faster.$?a384376[    Judgment, Crusader Strike, and auto-attack damage increased by $s1%.][]    $w6 nearby allies will be healed for $w5% of the damage done.
    -- https://wowhead.com/beta/spell=216331
    avenging_crusader = {
        id = 216331,
        duration = 20,
        max_stack = 1
    },
    -- Talent: $?$w2>0&$w4>0[Damage, healing and critical strike chance increased by $w2%.]?$w4==0&$w2>0[Damage and healing increased by $w2%.]?$w2==0&$w4>0[Critical strike chance increased by $w4%.][]$?a53376[ ][]$?a53376&a137029[Holy Shock's cooldown reduced by $w6%.]?a53376&a137028[Judgment generates $53376s3 additional Holy Power.]?a53376[Each Holy Power spent deals $326731s1 Holy damage to nearby enemies.][]
    -- https://wowhead.com/beta/spell=31884
    avenging_wrath = {
        id = 31884,
        duration = function() return talent.divine_wrath.enabled and 23 or 20 end,
        max_stack = 1
    },
    avenging_wrath_autocrit = {
        id = 294027,
        duration = 20,
        max_stack = 1,
        copy = "avenging_wrath_crit"
    },
    -- Will be healed for $w1 upon expiration.
    -- https://wowhead.com/beta/spell=223306
    bestow_faith = {
        id = 223306,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    blade_of_wrath = {
        id = 281178,
        duration = 10,
        max_stack = 1,
    },
    -- Damage and healing increased by $w1%$?s385129[, and Holy Power-spending abilities dealing $w4% additional increased damage and healing.][.]
    -- https://wowhead.com/beta/spell=385127
    blessing_of_dawn = {
        id = 385127,
        duration = 20,
        max_stack = 2,
        copy = 337767
    },
    blessing_of_dusk = {
        id = 385126,
        duration = 10,
        max_stack = 1,
        copy = 337757
    },
    -- Talent: Immune to movement impairing effects. $?s199325[Movement speed increased by $199325m1%][]
    -- https://wowhead.com/beta/spell=1044
    blessing_of_freedom = {
        id = 1044,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Immune to Physical damage and harmful effects.
    -- https://wowhead.com/beta/spell=1022
    blessing_of_protection = {
        id = 1022,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?$w1>0[$w1% of damage taken is redirected to $@auracaster.][Taking ${$s1*$e1}% of damage taken by target ally.]
    -- https://wowhead.com/beta/spell=6940
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Immune to magical damage and harmful effects.
    -- https://wowhead.com/beta/spell=204018
    blessing_of_spellwarding = {
        id = 204018,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Attack speed reduced by $w3%.  Movement speed reduced by $w4%.
    -- https://wowhead.com/beta/spell=388012
    blessing_of_winter = {
        id = 388012,
        duration = 6,
        type = "Magic",
        max_stack = 10,
        copy = 328506
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=115750
    blinding_light = {
        id = 115750,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Interrupt and Silence effects reduced by $w1%. $?s339124[Fear effects are reduced by $w4%.][]
    -- https://wowhead.com/beta/spell=317920
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1
    },
    consecrated_blade = {
        id = 382522,
        duration = 10,
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
            local dropped, expires

            c.count = 0
            c.expires = 0
            c.applied = 0
            c.caster = "unknown"

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
            end
        end
    },
    crusade = {
        id = 231895,
        duration = function() return talent.divine_wrath.enabled and 28 or 25 end,
        type = "Magic",
        max_stack = 10,
    },
    -- Mounted speed increased by $w1%.$?$w5>0[  Incoming fear duration reduced by $w5%.][]
    -- https://wowhead.com/beta/spell=32223
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=465
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1
    },
    divine_arbiter = {
        id = 406975,
        duration = 30,
        max_stack = 25
    },
    divine_hammer = {
        id = 198034,
        duration = 12,
        max_stack = 1,
        generate = function( dh )
            local last = action.divine_hammer.lastCast

            if last and last + 12 > query_time then
                dh.count = 1
                dh.expires = last + 12
                dh.applied = last
                dh.caster = "player"
                return
            end
            dh.count = 0
            dh.expires = 0
            dh.applied = 0
            dh.caster = "nobody"
        end
    },
    -- Talent: Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=498
    divine_protection = {
        id = 498,
        duration = 8,
        max_stack = 1
    },
    divine_purpose = {
        id = 408458,
        duration = 12,
        max_stack = 1,
    },
    divine_resonance = {
        id = 387895,
        duration = 15,
        max_stack = 1,
        copy = { 355455, 384029, 386730 }
    },
    -- Immune to all attacks and harmful effects.
    -- https://wowhead.com/beta/spell=642
    divine_shield = {
        id = 642,
        duration = 8,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases ground speed by $s4%$?$w1<0[, and reduces damage taken by $w1%][].
    -- https://wowhead.com/beta/spell=221883
    divine_steed = {
        id = 221883,
        duration = function () return ( ( talent.seasoned_warhorse.enabled and 6 or 4 ) + pvptalent.steed_of_glory.rank ) * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) end,
        max_stack = 1,
        copy = { 221885, 221886 },
    },
    empyrean_legacy = {
        id = 387178,
        duration = 20,
        max_stack = 1
    },
    empyrean_legacy_icd = {
        duration = 30,
        max_stack = 1
    },
    -- Talent: Your next Divine Storm is free and deals $w1% additional damage.
    -- https://wowhead.com/beta/spell=326733
    empyrean_power = {
        id = 326733,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Sentenced to suffer $w1 Holy damage.
    -- https://wowhead.com/beta/spell=343527
    execution_sentence = {
        id = 343527,
        duration = function() return talent.executioners_will.enabled and 12 or 8 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $s1 damage every $t1 sec
    -- https://wowhead.com/beta/spell=383208
    exorcism = {
        id = 383208,
        duration = 12,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    exorcism_stun = {
        id = 385149,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Deals $w1 damage over $d1.
    -- https://wowhead.com/beta/spell=273481
    expurgation = {
        id = 383346,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
        copy = 344067
    },
    -- Talent: Counterattacking all melee attacks.
    -- https://wowhead.com/beta/spell=205191
    eye_for_an_eye = {
        id = 205191,
        duration = 10,
        max_stack = 1
    },
    fading_light = {
        id = 405790,
        duration = 10,
        max_stack = 1,
    },
    faiths_armor = {
        id = 379017,
        duration = 4.5,
        max_stack = 1
    },
    -- Talent: Taking $w3% increased damage from $@auracaster's Holy Power abilities.
    -- https://wowhead.com/beta/spell=343721
    final_reckoning = {
        id = 343721,
        duration = function() return talent.executioners_will.enabled and 14 or 10 end,
        type = "Magic",
        max_stack = 1
    },
    final_verdict = {
        id = 383329,
        duration = 15,
        max_stack = 1,
        copy = 337228
    },
    -- Talent: Your next Holy Power spender costs $s2 less Holy Power.
    -- https://wowhead.com/beta/spell=209785
    fires_of_justice = {
        id = 209785,
        duration = 15,
        max_stack = 1,
        copy = "the_fires_of_justice" -- backward compatibility
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    -- Damaged or healed whenever the Paladin casts Holy Shock.
    -- https://wowhead.com/beta/spell=287280
    glimmer_of_light = {
        id = 287280,
        duration = 30,
        type = "Magic",
        max_stack = 1
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=853
    hammer_of_justice = {
        id = 853,
        duration = 6,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=183218
    hand_of_hindrance = {
        id = 183218,
        duration = 10,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=62124
    hand_of_reckoning = {
        id = 62124,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    inquisition = {
        id = 84963,
        duration = 45,
        max_stack = 1,
    },
    inquisitors_ire = {
        id = 403976,
        duration = 3600,
        max_stack = 10,
        -- TODO: Override .up and .stacks to increment every 2 seconds.
    },
    -- Taking $w1% increased damage from $@auracaster's next Holy Power ability.
    -- https://wowhead.com/beta/spell=197277
    judgment = {
        id = 197277,
        duration = function() return 15 + 3 * talent.highlords_judgment.rank end,
        max_stack = function() return 1 + talent.greater_judgment.rank end,
        copy = 214222
    },
    judgment_buff = {
        id = 20271,
        duration = 5,
        max_stack = 1
    },
    judgment_of_justice = {
        id = 408383,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Attackers are healed for $183811s1.
    -- https://wowhead.com/beta/spell=196941
    judgment_of_light = {
        id = 196941,
        duration = 30,
        max_stack = 5
    },
    -- Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=378412
    light_of_the_titans = {
        id = 378412,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=383469
    radiant_decree = {
        id = 383469,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Burning with holy fire for $w1 Holy damage every $t1 sec.
    -- https://wowhead.com/beta/spell=278145
    radiant_incandescence = {
        id = 278145,
        duration = 3,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        copy = 278147
    },
    recompense = {
        id = 397191,
        duration = 12,
        max_stack = 1,
    },
    -- Taking $w2% increased damage from $@auracaster's next Holy Power ability.
    -- https://wowhead.com/beta/spell=343724
    reckoning = {
        id = 343724,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=383389
    relentless_inquisitor = {
        id = 383389,
        duration = 12,
        max_stack = 3,
        copy = 337315
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=20066
    repentance = {
        id = 20066,
        duration = 60,
        mechanic = "incapacitate",
        type = "Magic",
        max_stack = 1
    },
    -- When any party or raid member within $a1 yards dies, you gain Avenging Wrath for $w1 sec.    When any party or raid member within $a1 yards takes more than $s3% of their health in damage, you gain Seraphim for $s4 sec. This cannot occur more than once every 30 sec.
    -- https://wowhead.com/beta/spell=183435
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1
    },
    righteous_verdict = {
        id = 267611,
        duration = 6,
        max_stack = 1,
    },
    rush_of_light = {
        id = 407065,
        duration = 10,
        max_stack = 1,
    },
    sanctified_ground = {
        id = 387480,
        duration = 3600,
        max_stack = 1,
    },
    sanctify = {
        id = 382538,
        duration = 8,
        max_stack = 1,
    },
    -- Talent: $@spellaura385728
    -- https://wowhead.com/beta/spell=385723
    seal_of_the_crusader = {
        id = 385723,
        duration = 5,
        max_stack = 1
    },
    sealed_verdict = {
        id = 387643,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Flash of Light cast time reduced by $w1%.  Flash of Light heals for $w2% more.
    -- https://wowhead.com/beta/spell=114250
    selfless_healer = {
        id = 114250,
        duration = 15,
        max_stack = 4
    },
    -- Talent: Absorbs $w1 damage and deals damage when the barrier fades or is fully consumed.
    -- https://wowhead.com/beta/spell=184662
    shield_of_vengeance = {
        id = 184662,
        duration = 15,
        mechanic = "shield",
        type = "Magic",
        max_stack = 1
    },
    -- $?$w2>1[Absorbs the next ${$w2-1} damage.][Absorption exhausted.]  Refreshed to $w1 absorption every $t1 sec.
    -- https://wowhead.com/beta/spell=337824
    shock_barrier = {
        id = 337824,
        duration = 18,
        tick_time = 6,
        type = "Magic",
        max_stack = 1
    },
    the_magistrates_judgment = {
        id = 337682,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=10326
    turn_evil = {
        id = 10326,
        duration = 40,
        mechanic = "turn",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Holy Damage increased by $w1%.
    -- https://wowhead.com/beta/spell=383311
    vanguards_momentum = {
        id = 383311,
        duration = 10,
        max_stack = 3,
        copy = 345046
    },
    virtuous_command = {
        id = 383307,
        duration = 5,
        max_stack = 1,
        copy = 339664
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=255937
    wake_of_ashes = {
        id = 255937,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    wake_of_ashes_stun = {
        id = 255941,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Auto attack speed increased and deals additional Holy damage.
    -- https://wowhead.com/beta/spell=269571
    zeal = {
        id = 269571,
        duration = 20,
        max_stack = 1
    },

    paladin_aura = {
        alias = { "concentration_aura", "crusader_aura", "devotion_aura", "retribution_aura" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },

    empyreal_ward = {
        id = 387792,
        duration = 60,
        max_stack = 1,
        copy = 287731
    },
    -- Power: 335069
    negative_energy_token_proc = {
        id = 345693,
        duration = 5,
        max_stack = 1,
    },
    reckoning_pvp = {
        id = 247677,
        max_stack = 30,
        duration = 30
    },
    templar_strikes = {
        duration = 3,
        max_stack = 1
    },
    truths_wake = {
        id = 383351,
        duration = 6,
        max_stack = 1,
        copy = 339376
    },
} )


-- Legacy sets.
spec:RegisterAuras( {
    sacred_judgment = {
        id = 246973,
        duration = 8
    },
    hidden_retribution_t21_4p = {
        id = 253806,
        duration = 15
    },
    whisper_of_the_nathrezim = {
        id = 207633,
        duration = 3600
    },
    ashes_to_dust = {
        id = 236106,
        duration = 6
    },
    chain_of_thrayn = {
        id = 236328,
        duration = 3600
    },
    liadrins_fury_unleashed = {
        id = 208410,
        duration = 3600,
    },
    scarlet_inquisitors_expurgation = {
        id = 248289,
        duration = 3600,
        max_stack = 3
    }
} )


spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "holy_power" then
        if buff.blessing_of_dawn.up then
            applyBuff( "blessing_of_dusk" )
            removeBuff( "blessing_of_dawn" )
        end
        if talent.crusade.enabled and buff.crusade.up then
            addStack( "crusade", buff.crusade.remains, amt )
        end
        if talent.fist_of_justice.enabled then
            reduceCooldown( "hammer_of_justice",talent.fist_of_justice.rank * amt )
        end
        if talent.relentless_inquisitor.enabled then
            if buff.relentless_inquisitor.stack < ( 3 * talent.relentless_inquisitor.rank ) then
                stat.haste = stat.haste + 0.01
            end
            addStack( "relentless_inquisitor" )
        end
        if talent.sealed_verdict.enabled then applyBuff( "sealed_verdict" ) end
        if talent.selfless_healer.enabled then addStack( "selfless_healer" ) end
        if legendary.uthers_devotion.enabled then
            reduceCooldown( "blessing_of_freedom", 1 )
            reduceCooldown( "blessing_of_protection", 1 )
            reduceCooldown( "blessing_of_sacrifice", 1 )
            reduceCooldown( "blessing_of_spellwarding", 1 )
        end
    end
end )

spec:RegisterHook( "gain", function( amt, resource, overcap )
    if amt > 0 and resource == "holy_power" and buff.blessing_of_dusk.up and talent.fading_light.enabled then
        applyBuff( "fading_light" )
    end
end )

spec:RegisterStateExpr( "time_to_hpg", function ()
    if talent.crusading_strikes.enabled then
        return max( gcd.remains, min( cooldown.judgment.true_remains, cooldown.blade_of_justice.true_remains, ( state:IsUsable( "hammer_of_wrath" ) and cooldown.hammer_of_wrath.true_remains or 999 ), action.wake_of_ashes.known and cooldown.wake_of_ashes.true_remains or 999, ( race.blood_elf and cooldown.arcane_torrent.true_remains or 999 ), ( action.divine_toll.known and cooldown.divine_toll.true_remains or 999 ) ) )
    elseif talent.templar_strikes.enabled then
        if buff.templar_strikes.up then
            return gcd.remains
        end
        return max( gcd.remains, min( cooldown.judgment.true_remains, cooldown.templar_strike.true_remains, cooldown.blade_of_justice.true_remains, ( state:IsUsable( "hammer_of_wrath" ) and cooldown.hammer_of_wrath.true_remains or 999 ), action.wake_of_ashes.known and cooldown.wake_of_ashes.true_remains or 999, ( race.blood_elf and cooldown.arcane_torrent.true_remains or 999 ), ( action.divine_toll.known and cooldown.divine_toll.true_remains or 999 ) ) )
    end

    return max( gcd.remains, min( cooldown.judgment.true_remains, cooldown.crusader_strike.true_remains, cooldown.blade_of_justice.true_remains, ( state:IsUsable( "hammer_of_wrath" ) and cooldown.hammer_of_wrath.true_remains or 999 ), action.wake_of_ashes.known and cooldown.wake_of_ashes.true_remains or 999, ( race.blood_elf and cooldown.arcane_torrent.true_remains or 999 ), ( action.divine_toll.known and cooldown.divine_toll.true_remains or 999 ) ) )
end )


local last_empyrean_legacy_icd_expires = 0

local current_crusading_strikes = 1
-- Strike 0 = SPELL_ENERGIZE occurred; Holy Power was gained -- the swing lands *after*.
-- Strike 1 = The swing that caused Holy Power gain just landed.
-- Strike 2 = The non-producing Holy Power swing has landed.
-- Strike 3 = Should never actually reach due to SPELL_ENERGIZE reset, but this would be the next productive swing.
local last_crusading_strike = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if destGUID == state.GUID and subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.empyrean_legacy.id then
        last_empyrean_legacy_icd_expires = GetTime() + 30
    elseif sourceGUID == state.GUID then
        if spellID == 406834 then -- Crusader Strikes: Energize
            current_crusading_strikes = 0
        elseif spellID == 408385 then
            local now = GetTime()
            if now - last_crusading_strike > 0.5 then -- Crusader Strikes: Swing Damage
                current_crusading_strikes = current_crusading_strikes + 1
                last_crusading_strike = GetTime()
                if current_crusading_strikes < 2 then
                    Hekili:ForceUpdate( "CRUSADING_STRIKES", true )
                end
            end
        end
    end
end )

local CrusadingStrikes = setfenv( function()
    if not action.rebuke.in_range then
        if Hekili.ActiveDebug then Hekili:Debug( "Crusading Strikes energize fails: Out of range." ) end
        return
    end
    spec.abilities.crusader_strike.handler()
end, state )

local csStartCombat = setfenv( function()
    if not talent.crusading_strikes.enabled then return end

    if not action.rebuke.in_range then
        if Hekili.ActiveDebug then Hekili:Debug( "Unable to forecast Crusading Strikes; out of range." ) end
        return
    end

    local mh_speed = swings.mh_speed
    local first_productive_swing = state.false_start

    if current_crusading_strikes < 2 then
        first_productive_swing = first_productive_swing + mh_speed
        if Hekili.ActiveDebug then Hekili:Debug( "First Crusading Strikes resource gain forecasted for next swing." ) end
        state:QueueAuraEvent( "crusading_strikes", CrusadingStrikes, first_productive_swing, "AURA_PERIODIC" )
    else
        -- Generate Holy Power on combat start.
        if Hekili.ActiveDebug then Hekili:Debug( "Immediate Crusading Strikes resource gain on virtual combat start." ) end
        spec.abilities.crusader_strike.handler()
    end

    for i = 1, 4 do
        state:QueueAuraEvent( "crusading_strikes", CrusadingStrikes, first_productive_swing + 2 * i * mh_speed, "AURA_PERIODIC" )
    end
end, state )



spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "HOLY_POWER" then
        Hekili:ForceUpdate( event, true )
    end
end )


spec:RegisterStateExpr( "consecration", function () return buff.consecration end )
spec:RegisterGear( "tier29", 200417, 200419, 200414, 200416, 200418 )

spec:RegisterHook( "reset_precast", function ()
    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5  then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 5 , "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end

    if last_empyrean_legacy_icd_expires > query_time then
        applyDebuff( "player", "empyrean_legacy_icd", last_empyrean_legacy_icd_expires - query_time )
    end

    local last_ts = action.templar_strike.lastCast

    if now - last_ts < 3 and action.templar_slash.lastCast < last_ts then
        applyBuff( "templar_strikes" )
    end

    if time > 0 and talent.crusading_strikes.enabled then
        if not action.rebuke.in_range then
            if Hekili.ActiveDebug then Hekili:Debug( "Unable to forecast Crusading Strikes; out of range." ) end
        else
            local mh_speed = swings.mh_speed

            if last_crusading_strike == 0 or now - last_crusading_strike > mh_speed then
                if Hekili.ActiveDebug then Hekili:Debug( "Unable to forecast Crusading Strikes swing; no prior swings have been detected or the last swing was more than 1 swing timer ago." ) end
            else
                local time_since = now - last_crusading_strike

                local was_productive = current_crusading_strikes < 2
                local next_swing = now + ( mh_speed * ( was_productive and 2 or 1 ) ) - time_since

                if Hekili.ActiveDebug then
                    if last_crusading_strike == 0 then Hekili:Debug( "No prior Crusading Strikes swings have been detected; assuming first swing is non-productive." )
                    else Hekili:Debug( "Last Crusading Strikes swing was %.2f seconds ago (vs. %.2f swing timer); it was %s.", time_since, mh_speed, was_productive and "productive" or "non-productive" ) end
                end

                for i = 1, 5 do
                    state:QueueAuraEvent( "crusading_strikes", CrusadingStrikes, next_swing + 2 * ( i - 1 ) * mh_speed, "AURA_PERIODIC" )
                end
            end
        end
    end
end )

spec:RegisterHook( "runHandler_startCombat", csStartCombat )


spec:RegisterStateFunction( "apply_aura", function( name )
    removeBuff( "concentration_aura" )
    removeBuff( "crusader_aura" )
    removeBuff( "devotion_aura" )
    removeBuff( "retribution_aura" )

    if name then applyBuff( name ) end
end )

spec:RegisterStateFunction( "foj_cost", function( amt )
    if buff.fires_of_justice.up then return max( 0, amt - 1 ) end
    return amt
end )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Call upon the Light to become an avatar of retribution, $?s53376&c2[causing Judgment to generate $53376s3 additional Holy Power, ]?s53376&c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies, ]?s53376&c1[reducing Holy Shock's cooldown by $53376s2%, ][]$?s326730[allowing Hammer of Wrath to be used on any target, ][]$?s384442&s384376[increasing your damage, healing and critical strike chance by $s2% for $d.]?!s384442[increasing your damage and healing by $s1% for $d.]?!s384376[increasing your critical strike chance by $s3% for $d.][and activating all the effects learned for Avenging Wrath for $d.]
    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = function () return 120 * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",
        school = "holy",

        notalent = "crusade",
        startsCombat = false,
        toggle = "cooldowns",

        usable = function() return talent.avenging_wrath.enabled or talent.avenging_wrath_might.enabled, "requires avenging_wrath/avenging_wrath_might" end,

        handler = function ()
            applyBuff( "avenging_wrath" )
        end,
    },

    -- Talent: Pierces an enemy with a blade of light, dealing $s1 Physical damage.    |cFFFFFFFFGenerates $s2 Holy Power.|r
    blade_of_justice = {
        id = 184575,
        cast = 0,
        cooldown = function() return ( talent.light_of_justice.enabled and 10 or 12 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
        charges = function() if talent.improved_blade_of_justice.enabled then return 2 end end,
        recharge = function() if talent.improved_blade_of_justice.enabled then return ( talent.light_of_justice.enabled and 10 or 12 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.holy_blade.enabled and -2 or -1 end,
        spendType = "holy_power",

        talent = "blade_of_justice",
        startsCombat = true,

        handler = function ()
            if buff.consecrated_blade.up then
                -- TODO: Handle 10 second CD.
                class.abilities.consecration.handler()
                removeBuff( "consecrated_blade" )
            end
            if talent.expurgation.enabled then
                applyDebuff( "target", "expurgation" )
            end
            removeBuff( "blade_of_wrath" )
            removeBuff( "sacred_judgment" )
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_freedom = {
        id = 1044,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "holy",

        spend = 0.07,
        spendType = "mana",

        talent = "blessing_of_freedom",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_freedom" )
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.    Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[    Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_protection = {
        id = 1022,
        cast = 0,
        cooldown = function() return talent.improved_blessing_of_protection.enabled and 240 or 300 end,
        gcd = "spell",
        school = "holy",

        spend = 0.15,
        spendType = "mana",

        talent = "blessing_of_protection",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_protection" )
            applyDebuff( "player", "forbearance" )
            if talent.blessing_of_spellwarding.enabled then setCooldown( "blessing_of_spellwarding", action.blessing_of_spellwarding.cooldown ) end
        end,
    },

    -- Talent: Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.    Last $d, or until transferred damage would cause you to fall below $s3% health.
    blessing_of_sacrifice = {
        id = 6940,
        cast = 0,
        cooldown = function() return talent.sacrifice_of_the_just.enabled and 60 or 120 end,
        gcd = "off",
        school = "holy",

        spend = 0.07,
        spendType = "mana",

        talent = "blessing_of_sacrifice",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_sacrifice" )
        end,
    },

    -- Talent: Emits dazzling light in all directions, blinding enemies within $105421A1 yards, causing them to wander disoriented for $105421d. Non-Holy damage will break the disorient effect.
    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "holy",

        spend = 0.06,
        spendType = "mana",

        talent = "blinding_light",
        startsCombat = false,
        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "blinding_light" )
            active_dot.blinding_light = max( active_enemies, active_dot.blinding_light )
        end,
    },

    -- Talent: Cleanses a friendly target, removing all Poison and Disease effects.
    cleanse_toxins = {
        id = 213644,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "holy",

        spend = 0.065,
        spendType = "mana",

        talent = "cleanse_toxins",
        startsCombat = false,

        usable = function ()
            return buff.dispellable_poison.up or buff.dispellable_disease.up, "requires poison or disease"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_disease" )
        end,
    },

    -- Interrupt and Silence effects on party and raid members within $a1 yards are $s1% shorter. $?s339124[Fear effects are also reduced.][]
    concentration_aura = {
        id = 317920,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "auras_of_the_resolute",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "concentration_aura" )
        end,
    },

    -- Consecrates the land beneath you, causing $<dmg> Holy damage over $d to enemies who enter the area$?s204054[ and reducing their movement speed by $204054s2%.][.] Limit $s2.
    consecration = {
        id = 26573,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        school = "holy",

        startsCombat = false,
        notalent = function() return talent.consecrated_blade.enabled and "consecrated_blade" or "divine_hammer" end,

        handler = function ()
            applyBuff( "consecration" )
        end,
    },


    crusade = {
        id = 231895,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "crusade",
        toggle = "cooldowns",

        startsCombat = false,
        texture = 236262,

        nobuff = "crusade",

        handler = function ()
            applyBuff( "crusade" )
        end,
    },

    -- Increases mounted speed by $s1% for all party and raid members within $a1 yards.
    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "auras_of_swift_vengeance",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "crusader_aura" )
        end,
    },

    -- Strike the target for $<damage> Physical damage.$?a196926[    Reduces the cooldown of Holy Shock by ${$196926m1/-1000}.1 sec.][]    |cFFFFFFFFGenerates $s2 Holy Power.
    crusader_strike = {
        id = 35395,
        cast = 0,
        charges = 2,
        cooldown = function () return ( talent.swift_justice.enabled and 4 or 6 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
        recharge = function () return ( talent.swift_justice.enabled and 4 or 6 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = 0.11,
        spendType = "mana",
        notalent = "templar_strikes",

        usable = function() return not talent.crusading_strikes.enabled, "crusading_strikes talent" end,
        startsCombat = true,

        handler = function ()
            gain( 1, "holy_power" )
            if talent.divine_arbiter.enabled then addStack( "divine_arbiter" ) end
            if talent.crusaders_might.enabled then reduceCooldown( "holy_shock", 1 ) end
        end,
    },

    -- Party and raid members within $a1 yards are bolstered by their devotion, reducing damage taken by $s1%.
    devotion_aura = {
        id = 465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "auras_of_the_resolute",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "devotion_aura" )
        end,
    },

    -- Divine Hammers spin around you, damaging enemies within 8 yds for 2,269 Holy damage over 12 sec. Deals reduced damage beyond 8 targets.
    divine_hammer = {
        id = 198034,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        talent = "divine_hammer",
        startsCombat = false,
        texture = 626003,

        handler = function ()
            applyBuff( "divine_hammer" )
        end,
    },

    -- Talent: Reduces all damage you take by $s1% for $d.
    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = function () return 60 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "off",
        school = "holy",

        spend = 0.035,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "divine_protection" )
        end,
    },

    -- Grants immunity to all damage and harmful effects for $d. $?a204077[Taunts all targets within 15 yd.][]    Cannot be used if you have Forbearance. Causes Forbearance for $25771d.
    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function () return 300 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "spell",
        school = "holy",

        startsCombat = false,

        toggle = "cooldowns",
        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "divine_shield" )
            applyDebuff( "player", "forbearance" )
        end,
    },

    -- Talent: Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed = {
        id = 190784,
        cast = 0,
        charges = function () return talent.cavalier.enabled and 2 or nil end,
        cooldown = 45,
        recharge = function () return talent.cavalier.enabled and 45 or nil end,
        gcd = "off",
        school = "holy",

        talent = "divine_steed",
        startsCombat = false,

        handler = function ()
            applyBuff( "divine_steed" )
        end,

        copy = 221883
    },

    -- Talent: Unleashes a whirl of divine energy, dealing $s1 Holy damage to all nearby enemies. Deals reduced damage beyond $s2 targets.
    divine_storm = {
        id = 53385,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            if buff.empyrean_power.up then return 0 end
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "divine_storm",
        startsCombat = true,

        handler = function ()
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )

            if buff.empyrean_power.up then
                removeBuff( "empyrean_power" )
            elseif buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end

            if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end

            if talent.sanctify.enabled then
                applyDebuff( "target", "sanctify" )
                active_dot.sanctify = active_enemies
            end
        end,
    },

    -- Talent: Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[    After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[    Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[    Generates $s5 Holy Power per target hit.][]
    divine_toll = {
        id = function() return talent.divine_toll.enabled and 375576 or 304971 end,
        cast = 0,
        cooldown = function() return talent.quickened_invocation.enabled and 45 or 60 end,
        gcd = "spell",
        school = "arcane",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            local spellToCast

            if state.spec.protection then spellToCast = class.abilities.avengers_shield.handler
            elseif state.spec.retribution then spellToCast = class.abilities.judgment.handler
            else spellToCast = class.abilities.holy_shock.handler end

            for i = 1, min( 5, true_active_enemies ) do
                spellToCast()
            end

            if talent.divine_resonance.enabled or legendary.divine_resonance.enabled then
                applyBuff( "divine_resonance" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires     , "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 5 , "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 10, "AURA_PERIODIC" )
            end
        end,

        copy = { 375576, 304971 }
    },

    -- Talent: A hammer slowly falls from the sky upon the target. After $d, they suffer ${$387113s1*$<mult>} Holy damage$?s387196[ and enemies within $387200a2 yards will suffer $387196s1% of the damage taken from your abilities in that time.][, plus $s2% of damage taken from your abilities in that time.]
    execution_sentence = {
        id = 343527,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        spend = function ()
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "execution_sentence",
        startsCombat = false,

        handler = function ()
            removeBuff( "fires_of_justice" )
            removeBuff( "hidden_retribution_t21_4p" )
            removeDebuff( "target", "reckoning" )
            applyDebuff( "target", "execution_sentence" )
        end,
    },

    -- Talent: Blasts the target with Holy Light, causing $383921s1 Holy damage and burns the target for an additional ${$383208s1*($383208d/$383208t)} Holy Damage over $383208d. Stuns Demon and Undead targets for $385149d.    Applies the damage over time effect to up to $s2 nearby enemies if the target is standing within your Consecration.
    exorcism = {
        id = 383185,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "holy",

        talent = "exorcism",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "exorcism" )
            if target.is_demon or target.is_undead then applyDebuff( "target", "exorcism_stun" ) end
        end,
    },

    -- Talent: Surround yourself with a bladed bulwark, reducing Physical damage taken by $s2% and dealing $205202sw1 Physical damage to any melee attackers for $d.
    eye_for_an_eye = {
        id = 205191,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "eye_for_an_eye",
        startsCombat = false,

        handler = function ()
            applyBuff( "eye_for_an_eye" )
        end,
    },

    -- Talent: Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the target area and causing them to take $s3% increased damage from your Holy Power abilities for $d.    |cFFFFFFFFPassive:|r $@spelldesc343723
    final_reckoning = {
        id = 343721,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        talent = "final_reckoning",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "final_reckoning" )
        end,
    },

    -- Expends a large amount of mana to quickly heal a friendly target for $?$c1&$?a134735[${$s1*1.15}][$s1].
    flash_of_light = {
        id = 19750,
        cast = function ()
            if talent.lights_celerity.enabled then return 0 end
            return ( 1.5 - ( buff.selfless_healer.stack * 0.5 ) ) * haste
        end,
        cooldown = function() return talent.lights_celerity.enabled and 6 or 0 end,
        gcd = "spell",
        school = "holy",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            removeBuff( "selfless_healer" )
        end,
    },

    -- Stuns the target for $d.
    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        spend = 0.035,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hammer_of_justice" )
        end,
    },


    hammer_of_reckoning = {
        id = 247675,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        startsCombat = true,
        -- texture = ???,

        pvptalent = "hammer_of_reckoning",

        usable = function () return buff.reckoning.stack >= 50 end,
        handler = function ()
            removeStack( "reckoning", 50 )
            if talent.crusade.enabled then
                applyBuff( "crusade", 12 )
            else
                applyBuff( "avenging_wrath", 6 )
            end
        end,
    },

    -- Talent: Hurls a divine hammer that strikes an enemy for $<damage> Holy damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].    |cFFFFFFFFGenerates $s2 Holy Power.
    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        charges = function() return talent.vanguards_momentum.enabled and 2 or nil end,
        cooldown = function() return 7.5 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) end,
        recharge = function() return talent.vanguards_momentum.enabled and ( 7.5 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) ) or nil end,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = function() return talent.vanguards_momentum.enabled and -2 or -1 end,
        spendType = "holy_power",

        talent = "hammer_of_wrath",
        startsCombat = false,

        usable = function () return target.health_pct < 20 or ( talent.avenging_wrath.enabled and ( buff.avenging_wrath.up or buff.crusade.up ) ) or buff.final_verdict.up or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires buff/talent or target under 20% health" end,
        handler = function ()
            removeBuff( "final_verdict" )
            if buff.divine_arbiter.stack > 24 then removeBuff( "divine_arbiter" ) end
            if legendary.the_mad_paragon.enabled then
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 1 end
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 1 end
            end
            if talent.zealots_paragon.enabled then
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 0.5 end
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 0.5 end
            end
        end,
    },

    -- Talent: Burdens an enemy target with the weight of their misdeeds, reducing movement speed by $s1% for $d.
    hand_of_hindrance = {
        id = 183218,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "holy",

        spend = 0.1,
        spendType = "mana",

        talent = "hand_of_hindrance",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "hand_of_hindrance" )
        end,
    },

    -- Commands the attention of an enemy target, forcing them to attack you.
    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hand_of_reckoning" )
        end,
    },

    -- Petition the Light on the behalf of a fallen ally, restoring spirit to body and allowing them to reenter battle with $s2% health and at least $s1% mana.
    intercession = {
        id = 391054,
        cast = 2,
        cooldown = 600,
        gcd = "spell",
        school = "holy",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            -- brez.
        end,
    },

    -- Judges the target, dealing $s1 Holy damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability.][]$?s315867[    |cFFFFFFFFGenerates $220637s1 Holy Power.][]
    judgment = {
        id = 20271,
        cast = 0,
        charges = function() if talent.improved_judgment.enabled then return 2 end end,
        cooldown = function() return ( ( talent.swift_justice.enabled and 10 or 12 ) - 0.5 * talent.seal_of_alacrity.rank ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
        recharge = function()
            if talent.improved_judgment.enabled then
                return ( talent.swift_justice.enabled and 10 or 12 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste
            end
        end,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        velocity = function()
            if talent.greater_judgment.enabled then return 35 end
        end,

        handler = function ()
            removeBuff( "recompense" )
            gain( talent.boundless_judgment.enabled and 2 or 1, "holy_power" )
            if talent.divine_arbiter.enabled then addStack( "divine_arbiter" ) end
            if talent.empyrean_legacy.enabled and debuff.empyrean_legacy_icd.down then
                applyBuff( "empyrean_legacy" )
                applyDebuff( "player", "empyrean_legacy_icd" )
            end
            if talent.judgment_of_justice.enabled then
                applyBuff( "judgment_buff" )
                if talent.greater_judgment.enabled then applyDebuff( "target", "judgment_of_justice" ) end
            end
            if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 5 ) end
            if talent.virtuous_command.enabled or conduit.virtuous_command.enabled then applyBuff( "virtuous_command" ) end
            if talent.zeal.enabled then applyBuff( "zeal", 20, 2 ) end
            if talent.zealots_paragon.enabled then
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 0.5 end
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 0.5 end
            end
        end,

        impact = function()
            if talent.greater_judgment.enabled then
                applyDebuff( "target", "judgment", nil, 1 + talent.highlords_judgment.rank )
            end
        end
    },

    -- Talent: Focuses Holy energy to deliver a powerful weapon strike that deals $s1 Holy damage, and restores health equal to the damage done.    Damage is increased by $s2% when used against a stunned target.
    justicars_vengeance = {
        id = 215661,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "justicars_vengeance",
        startsCombat = true,

        handler = function ()
            removeBuff( "empyrean_legacy" )
            removeDebuff( "target", "reckoning" )
            if buff.blessing_of_dawn.up then
                removeBuff( "blessing_of_dawn" )
                applyBuff( "blessing_of_dusk" )
            end
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end
            if talent.divine_arbiter.enabled then addStack( "divine_arbiter" ) end
        end,
    },

    -- Talent: Heals a friendly target for an amount equal to $s2% your maximum health.$?a387791[    Grants the target $387792s1% increased armor for $387792d.][]    Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.
    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "off",
        school = "holy",

        talent = "lay_on_hands",
        startsCombat = false,

        toggle = "cooldowns",
        nodebuff = "forbearance",

        handler = function ()
            gain( health.max, "health" )
            applyDebuff( "player", "forbearance", 30 )

            if talent.liadrins_fury_reborn.enabled then
                gain( 5, "holy_power" )
            end

            if azerite.empyreal_ward.enabled then applyBuff( "empyreal_ward" ) end
        end,
    },

    -- Talent: Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yd in front of you and reducing their movement speed by $s2% for $d. Damage reduced on secondary targets.    Demon and Undead enemies are also stunned for $255941d.    |cFFFFFFFFGenerates $s3 Holy Power.
    radiant_decree = {
        id = 383469,
        known = 255937,
        flash = { 383469, 255937 },
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holyfire",

        spend = function() return talent.vanguard_of_justice.enabled and 4 or 3 end,
        spendType = "holy_power",

        talent = "radiant_decree",
        startsCombat = true,

        usable = function ()
            if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
            return true
        end,

        handler = function ()
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )
            if target.is_undead or target.is_demon then applyDebuff( "target", "radiant_decree" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if talent.truths_wake.enabled or conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,
    },

    -- Talent: Forces an enemy target to meditate, incapacitating them for $d.    Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.06,
        spendType = "mana",

        talent = "repentance",
        startsCombat = false,

        handler = function ()
            interrupt()
            applyDebuff( "target", "repentance" )
        end,
    },

    -- When any party or raid member within $a1 yards dies, you gain Avenging Wrath for $s1 sec.    When any party or raid member within $a1 yards takes more than $s3% of their health in damage, you gain Seraphim for $s4 sec. This cannot occur more than once every 30 sec.
    retribution_aura = {
        id = 183435,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "auras_of_swift_vengeance",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "retribution_aura" )
        end,
    },

    -- Slams enemies in front of you with your shield, causing $s1 Holy damage, and increasing your Armor by $?c1[${$132403s1*$INT/100}][${$132403s1*$STR/100}] for $132403d.$?a386568[    $@spelldesc386568][]$?a280373[    $@spelldesc280373][]
    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "off",
        school = "holy",

        spend = function () return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.the_magistrates_judgment.up and 1 or 0 ) end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeBuff( "the_magistrates_judgment" )
            applyBuff( "shield_of_the_righteous" )
        end,
    },

    -- Talent: Creates a barrier of holy light that absorbs $<shield> damage for $d.    When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    shield_of_vengeance = {
        id = 184662,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "holy",

        talent = "shield_of_vengeance",
        startsCombat = false,

        toggle = "defensives",

        usable = function ()
            if ( settings.sov_damage or 0 ) > 0 then return incoming_damage_5s > 0.01 * settings.sov_damage * health.max, "incoming damage over 5s must exceed " .. settings.sov_damage .. "% of max health" end
            return true
        end,

        handler = function ()
            applyBuff( "shield_of_vengeance" )
        end,
    },

    -- Begin the Templar combo, striking the target for 3,207 Radiant damage. Generates 1 Holy Power.
    templar_strike = {
        id = 407480,
        cast = 0,
        charges = 2,
        cooldown = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
        recharge = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
        gcd = "totem",
        school = "physical",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 1109508,
        talent = "templar_strikes",
        nobuff = "templar_strikes",

        handler = function ()
            gain( 1, "holy_power" )
            applyBuff( "templar_strikes" )
            if talent.divine_arbiter.enabled then addStack( "divine_arbiter" ) end
        end,

        bind = { "templar_slash", "crusader_strike" }
    },

    -- Complete the Templar combo, slash the target with a 100% increased chance to critically strike for 4,053 Radiant damage. Generate 1 Holy Power.
    templar_slash = {
        id = 406647,
        known = 407480,
        rangeSpell = 407480,
        flash = 407480,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 1109506,
        talent = "templar_strikes",
        buff = "templar_strikes",

        handler = function ()
            gain( 1, "holy_power" )
            removeBuff( "templar_strikes" )
            if talent.divine_arbiter.enabled then addStack( "divine_arbiter" ) end
        end,

        bind = { "templar_strike", "crusader_strike" }
    },

    -- Unleashes a powerful weapon strike that deals $224266s1 Holy damage to an enemy target.
    templars_verdict = {
        id = function() return talent.final_verdict.enabled and 383328 or runeforge.final_verdict.enabled and 336872 or 85256 end,
        known = 85256,
        flash = { 85256, 336872, 383328 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",
        notalent = "justicars_vengeance",

        startsCombat = true,

        handler = function ()
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )
            removeStack( "vanquishers_hammer" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end

            if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
            if buff.empyrean_legacy.up then
                class.abilities.divine_storm.handler() -- TODO: Check for resource gain?
                removeBuff( "empyrean_legacy" )
            end
            if buff.divine_arbiter.stack > 24 then removeBuff( "divine_arbiter" ) end

            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if talent.righteous_verdict.enabled then applyBuff( "righteous_verdict" ) end
        end,

        copy = { "final_verdict", 336872, 383328 },
    },

    -- Talent: The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.105,
        spendType = "mana",

        talent = "turn_evil",
        startsCombat = false,

        handler = function ()
            applyBuff( "turn_evil" )
        end,
    },

    -- Talent: Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yd in front of you and reducing their movement speed by $s2% for $d. Damage reduced on secondary targets.    Demon and Undead enemies are also stunned for $255941d.    |cFFFFFFFFGenerates $s3 Holy Power.
    wake_of_ashes = {
        id = 255937,
        flash = { 383469, 255937 },
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holyfire",

        spend = -3,
        spendType = "holy_power",

        talent = "wake_of_ashes",
        notalent = "radiant_decree",
        startsCombat = true,

        usable = function ()
            if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
            return true
        end,

        handler = function ()
            if target.is_undead or target.is_demon then applyDebuff( "target", "wake_of_ashes" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,
    },

    -- Calls down the Light to heal a friendly target for $130551s1$?a378405[ and an additional $378412s1 over $378412d][].$?a379043[ Your block chance is increased by$379043s1% for $379041d.][]$?a315921&!a315924[    |cFFFFFFFFProtection:|r If cast on yourself, healing increased by up to $315921s1% based on your missing health.][]$?a315924[    |cFFFFFFFFProtection:|r Healing increased by up to $315921s1% based on the target's missing health.][]
    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            removeBuff( "recompense" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
                removeBuff( "the_magistrates_judgment" )
            end
            gain( 1.33 * stat.spell_power * 8, "health" )

            if talent.faiths_armor.enabled then applyBuff( "faiths_armor" ) end
            if conduit.shielding_words.enabled then applyBuff( "shielding_words" ) end
        end,
    },
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "spectral_strength",

    package = "Retribution",
} )


spec:RegisterSetting( "check_wake_range", false, {
    name = "Check |T1112939:0|t Wake of Ashes Range",
    desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "sov_damage", 20, {
    name = "|T236264:0|t Shield of Vengeance Damage Threshold",
    desc = "If set above zero, |T236264:0|t Shield of Vengeance can only be recommended when you've taken the specified amount of damage in the last 5 seconds, in addition to any other criteria in the priority.",
    type = "range",
    width = "full",
    min = 0,
    max = 100,
    step = 1,
} )

spec:RegisterSetting( "desync_toll", false, {
    name = "Desync |T3565448:0|t Divine Toll",
    desc = "If checked, when Seraphim, Final Reckoning, and/or Execution Sentence are toggled off or disabled, the addon will recommend |T3565448:0|t Divine Toll despite being out of sync with your cooldowns.\n\n"
        .. "This is useful for maximizing the number of Divine Toll casts in a fight, but may result in a lower overall DPS.",
    type = "toggle",
    width = "full",
} )


spec:RegisterPack( "Retribution", 20230330, [[Hekili:T3XApUTnYFlloeh70ehlz7UBlw7I7kUp0Gd5dN79vBR1METAKL8PhBYwSW)2VHK6bFmuVDUw0au0UvC0mdN3Cif9AR1)66v7DIjR)O9e7PtMoDYyR5t(bR7wVk(5ZK1Ro7S7topc)HVZj4F)VjXHUpKe7g4th7zVaN9uCefKeUdgF9QhsC9I)f)1pOJ4zZMn9haypt2T(J3oz9QJU73t4GsI2TEff03nX(D2w)4LTx2(lXKqafx2g4Fzlqx)prIH)W9KR)Jx2oK4Vhg6WLTpeefDW9XJWGEbp6UB04lF4Yh4iB67SMYq2)CVBCe82bx2gLC(Cqia9bxF3OJKq457tczy9NdtIC2d08CyWo45hcdoDzRW0(Y2)EsOJefszxRjJNm(w6B6ge6g)8LTjNPIazyVJb7)HncaBahNWC5DbhEx6SayHhjCED3rYUpbSrqiFEoge7HbhC9aHTZo6lhn(CizxWPhCI)UfV3jCNJpztCqyiXp(TUhwe74b)1yyU64TbG8tb(0z6hWE7OJUeV9BcoS5jI)Jeh)DeCaFYj015bpYBPMfls1nBS28qYHdrV9jhVK8No2A8rNi2iJJIbU6X4JV8cYGNCIaf(ZOJ9eOKCID9aXk64hPVl6i7avrtMd2OZb7YMd2LmhSRyoyBCoy3(5G1Mto(joEAkc3iGd9D3T5XqxYbWiz3XMGxBC8A3v8ATj6z)DVn48IisS7Hu0BX)VBiErKftgp)T7c8bNyaNlYqZyflVbdlMR7cc82h8z)XGRTd9TE1RYF0oUxE(qlM8Ylgh8vVQeKsFZ6rthQlf45T5ZWqhXjTbyQGdg1ezTDNL12QYA7RHSgbPIY6YPzViRr5GgjRZYeOkTTfL2wcY6BmAyBsl8YlM1pLQGkgJMPBSJ)ZB2FokF8rVzO145FxjX)aiqin14A0OLdl1rSyS6qBK8hy02kL20ST)niF)xi7sIjqjceiW7ZS6gO5upc)lqdsZN6c53DEYX1JHNCflOodjpK8jI4tuuWaUGCSBsnFv1VAM3HKtoU(r3)tPHZLEQKRNGXqAI7uOfzMDoEEB4)VB8CJI5mvgvJQg0hj(0sRcGkF(qHbDocwWllHw9aJHvCvso)YlstKKZdK()JIHQgxybEB0swgWQQztMmWEocfbo1Jcv0MFlz)JNslDbQue4(yNWhjXrJvay5c7xE5Mqh39BanmiOC2VpAm5lWKe8kuFUR)YBNR)4KZ4mZbxWeWliyFNLb44pjISXnMCIRoC8Gj4rNWnNt(9F3JS5HGVqP7qtXQYeLZhCJSrIy0aztuawzqhny4XaVN3Co4ZKWLlGHHx4Eqej(0PSNUC(OkMfrEbXzr9SySoUmBqfZOLZMutXkW(3ihCkd1O5isXps0YSy0lSgjMjhnW0YfsMYnqOy)vxOyzqOy1iHI9irXzpluywkMt5neBiEbOPYd1u4aXKfm0NmcTqL85UorYZSEJQq3uC9L2tYGU5Ax7jnX7YgxMzBwMz3nzgM9IrD2)3LzilGLkWKSqxAzidKmXOVNySWzLgHu(P2zbB37(KlSCCNKVaR7Zj85bfX0jScuaMiBwjvDQYY1lGXWepRsKS0vQvE84U9Ws0(spe0pNV3ebZqsQeEy9v8wQHZkkxOk9oleNeVwt5(Ob8QiYtlU3LS8ot5(Le9SzhIHWDOsTf3vBoQQ07lbDgYsLshDGMehtQUKMvG6nNoTpE(XLte5Wf11YLMBPUfBr5fKcWMnzKy5M5DFtR869qIlhG)PpGxrTCLGP8weua7jwzGSjo505NdbxE(urQ0orsj(YuDBESmbQo4gzm6rE0z3ZuR6B4jXZKoHparOdZtiR8yUkWEgi7gQvPMr)dqT)MPSu583q3HdYjJRKOdOAMtnu1d6KJljYAlqwf3GsOzvbTsrDDkI5ElXaCIQTFljk2DNtyKCK9VjxRRCfxSc1xC2Jlvd37Ul(BY0MjtlKQfRP24YUZf8VnckCAx8cl5ImObJhUNWiv2YCzbtfabcMigQjKef4tDgKI3jXlF25teAfroaPJKj49q8(Qsdzw7xHEVokYz4wbnjzdKyHwkPEoOrgKhPsU4appDPXn6I)MXltX5LkfZqvPL4NrhuUnk3zA61otpAbm10KhLQPXr2e5bMz5vHM)uGMFIejwn6GstPBGkInhcvtjQmHAdZmpFiiXFVhjQO7rJAf9FWdefuFjE2iIsTHs0K9y2l0oAD050jsiLy5lhzOz8CVTWSLotj73SdqXzaXJ0KlP(ChjoEGf45DX8vJL((p54)yItiup0PaQSk5KjBTgR1BGCTsX613gPh8WgQjQHOmtWxlospfnvARrwdEczhVXmmbG4dOZ(2yjMcf3GuVVS1djPZPmRckAuJ2Ln2yWWfqD0MdHCu54bRJz8TZL1D2I5fbvzXkovnNKtUlNoTUVvbC5gtYLm0oJL64yvfmmHwn8gQTHF9Ji1X4k1ZwXauYh1HA4quhZ71ROBtpau2bxX(U1R(StiTgXO1R(v62h5Ek94Jq3ePxVNCWjXl(1x2gs(VjUH0TCkkGUxtojXbNCy7bfyrdlAjA8Lp8VaADzR9pEz7ph4d0In8RLl4(18Z(HYtht8PRnDpm6qRVWpKli8t(2s2moYcNJuktwHZulIwJd54EQkUnVZE5eifKyCy6z0tB1kfUwG50t8rz8Dbi9lY7axlCwukJZLbR)jshMbStltz8Ega9jI7a)spdpLXUPJ3JO1eZoZawr2JFnmJdtpJ(oW4MCyqbPFrEh46YCumcw)tKomdWDAqaOprCh4xu3g9X7r0AIzNB0hh5q1H4PJdLej(EJmEDiHjOKiXTgNf5LnNTFXiZbmyUQO)QH4VX3)LGVdot4qebvF7dyP6dKkg(7(PKedRIhtYkOAVCojX5Hrzc4wkAAPKPtcMQMZ1sUuLyj3M6oJHLR2yfhgjFH(g9xne)n((Ve8D1Xm1oy5y4VhIzwXrlVcQ2LydvWdMJzwprtlLmDsWu1CUwYLQel52u)qpBSQ4l03OVgig9mvIGCtWvt(VUKHAMTP5OVUlTV0oh0D0BArwMWCBRl8kJ(AG46Ppndxn5)6sMwz2u)(Z2kZM6J(AA2OLb7k956GgN1KpQYhlJIJqn)iDqRg2K6vLIwvsXSpnNmX)xr527)Ql3E)vqUnoDNEoe45f8zx6hQSdGvWo8ZKqc9dgMAFsTjZ((MCPFvX09B8Y2hsIZGZpGTnrj(sqVFpf49oXop4er(XlF4Y23Dzl)JofDlMYMZrVUrBXKwd0A1ME1)4Yul4K)UsmKYry4AI0ClM09pUSkjka5kI8krB9ZduR0nDNmLMUXu7oTkxDQnCnrALsCuqUIiVs0w)QbRL6S7KPu1PPE61oB9RkYRCn1TtHwZfS3oKNJwRj4HuvpdTkXwvh2uqwldh5H(c9A7v6FoqpA(18th0RBu(1(5qLukU0pkVkOf5S(2mk0zjAPyVxoolxxo3GLwR0IgWvpQfVw(fLI9ErlED58(S(ud4Qh1IgOW1vw0lAXRfNJgxU4yd2lbM7rfOwnyCeOF0ovOGoaMOGwLsCeuCCSvWCXaMWOwDmPSKYPxxLJvgUHyx)mOQGFDamwtGHcM6GiXYWPWSh1JwATlR3jHTbbtVi7V8HFH5tsr8C5wDqD4wVI9xS71o(bZf(ZpYUN7sr16)b)6Ml09m9vxVQX3umz38ARxXVNywhV(J2kui486vSReMcGZAVd7V2WVp9uULoOd5La)N8Y0v(qGUS9(FI2rNdAFH3PVk7AKz9QjakcPFdQUoarqZYq56PkCDgRQEO15s1uEoV7pummRnyOiokGIy6nAx6rwgtxPnpmKzOG2Yhm8CTt2Wi3raIeerSKQmXvLm9LHM6Dz7lVCz7x3bLmV4GK1EvmfwdMB2LXeFvgeBUzxm3M3(5g6bPdxuYVonO077Bp9qpvD4tVc6DBldYKZ602jNZlwkHmgpx0zZul6VSDaelwY6tRf4x2(kOii1qyfJU4Y2jC9Cja9QQOrbwQpVyydOrzjJWwtoBevLDx3uz2DsLzBqLHSpj9UkdLgiQSk5LExLvcNXuz)q3uzz3Ds5knBzLMLOk7MlBl1rZSkLoVRsHxPo)9sai1gwqyCz7By4WAmuO13vse7CinSNzmiG)zPgxH6(8EjaQnxPMJ0mxzjWv8kqeQiP0sqk(E3yMmZ56bGg6FOP8HuEHzmIoiTeoKVHFWulM(1JszI6vmvEZcXkdfNZVh4e7mJetop5vCI60Np6Om8aMYvUSvfKz(IbGzRmlnuH2feamdGf4jtB8prFog0)m9z43Ec(WuD3OcPV09Naw5HvjKVb38OlS(0Yy9ARzbeznVkfSaqYx0BzkHcjLWnRawPM4YPLGCAAHprg9tLqspJDheWOR1Ko6OOwQybVXOOHpHDgTtVkTySN5VeA(eZUG3K(KEXQEukRGzdgvBSPCDtH7N5fQNzB0aUodfyLFwWW1HT07(rlyh1VrBSsSKyRYW99mhufHNH2lj4wzyMQ9TplfJPGcMBYHKVKYhBnwHjn3MTeRrWJQoER1u1wUgZYCc2ROPpUrTL5uMdrvQS46PAvgJQDloimMy0S8hQFrLrzUofoZYCoPBOb3LUeiAQtN4RZiM5a7naRYF29u0AoMSA2PsUPi40HEBryYQXwVYS7ZZbLtjt3gemV68uaVbfD8c9Al2eFp17Acm4fmSvepmPQAAMwyCDRy7ZKJCi34mR7qHKZmkGAoAwhCZX9XTBCSTUhmV0i52wIYjvTMSGYwQ5Lk92ub0PsOv0TvbWzIaQCbyiczSOPaYkJQUJxvgrOSaJIRVw46zS8v68eYf6ywD4YKj)ADmB4HYlmR46DuBnBsxXJCJJzc1iiTEiLgVxJcUf9WN2Q1yvXgDw1kRAYY0udhPZSg6yFd40CEXW12NbgbnpCzRQaB5mmJ1Yx333u3)5uDlMUq76fT8LW(nv(F2v5Qx9P80Dz8rfncSrv(BGFwWJ4WELGiExB1BXI98cwM)7Yr5P)k9hndPCUTR1t3ohFyA26m(uHQLh8S3eLf0p)NVdmFyE5ei)MBiuLf2Gs((v2BT7zDhEqLrjkAoT8rbqadMED0osSCr(RXogd3N3LA8MUXHAjdQrL3zSHMxW7GAirOD0DsluRkbCK3eImQMgPbz3oK6JT2wbu8J1hLw5HumV)dujNKtQqaf(lblGN(l2GW)FPn77pwsvRYKQ6hF86ivT1LQA71u1svBfPQD5DKSQnwJpTraHVB7ccuKFWm0LS8NMlrR0oeJ2sBT3n4QZsRPqy5PD0IYwUq4YmSn391sNJMvb29SkWKrBPwi)rvfG6fyUtkkvtW2kNcCIDqOQFNGxM3LRMNObdkBXCDMRvCG8wBP9ROc65cWynLls32)Im)sAKkAwTK5HPTiQxZpR2ZOQ7GDBSITWsOOx0ADmJLs0Gmd7GLWOuW0xHdq37kev6lUPIoMJWPkg63vdn2cJG1O5xDQ1uCLrskgnLBEyxnBct67LfvlueBT4xtggXNOppx0v)82U3(zZfdREzMS7UsGH1Plc0jj(yq46vRCp9ZSNS()9d]] )
