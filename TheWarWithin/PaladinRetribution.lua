-- PaladinRetribution.lua
-- July 2024

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
    afterimage                      = {  93189, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness.
    auras_of_the_resolute           = {  81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yds are 30% shorter.  Devotion Aura: Party and raid members within 40 yds are bolstered by their devotion, reducing damage taken by 3%.
    avenging_wrath                  = {  81606,  31884, 1 }, -- Call upon the Light to become an avatar of retribution, increasing your critical strike chance by 20% for 20 sec.
    blessing_of_freedom             = {  81600,   1044, 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = {  81616,   1022, 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    blessing_of_sacrifice           = {  81614,   6940, 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = {  81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yds, causing them to wander disoriented for 6 sec.
    cavalier                        = {  81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    cleanse_toxins                  = {  81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    crusader_aura                   = {  81601,  32223, 1 }, -- Increases mounted speed by 20% for all party and raid members within 40 yds.
    divine_purpose                  = {  81618, 408459, 1 }, -- Holy Power spending abilities have a 10% chance to make your next Holy Power spending ability free and deal 10% increased damage and healing.
    divine_resonance                = {  93181, 384027, 1 }, -- After casting Divine Toll, you instantly cast Judgment every 5 sec for 15 sec.
    divine_steed                    = {  81632, 190784, 1 }, -- Leap atop your Charger for 4 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    divine_toll                     = {  81496, 375576, 1 }, -- Instantly cast Judgment on up to 5 targets within 30 yds. Divine Toll's Judgment deals 100% increased damage.
    fading_light                    = {  81623, 405768, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for 3% of damage or healing dealt.
    faiths_armor                    = {  81495, 406101, 1 }, -- Word of Glory grants 20% bonus armor for 4.5 sec.
    fist_of_justice                 = {  81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = {  81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 784 every 0.7 sec.
    greater_judgment                = {  81603, 231663, 1 }, -- Judgment causes the target to take 20% increased damage from your next Holy Power ability. Multiple applications may overlap.
    hammer_of_wrath                 = {  81510,  24275, 1 }, -- Hurls a divine hammer that strikes an enemy for 32,110 Holy damage. Only usable on enemies that have less than 20% health. Generates 1 Holy Power.
    healing_hands                   = {  93189, 326734, 1 }, -- The cooldown of Lay on Hands is reduced up to 60%, based on the target's missing health. Word of Glory's healing is increased by up to 100%, based on the target's missing health.
    holy_aegis                      = {  81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    improved_blessing_of_protection = {  81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection by 60 sec.
    incandescence                   = {  81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 6,470 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = {  81608, 183778, 1 }, -- Judgment causes the next 5 successful attacks against the target to heal the attacker for 3,019.
    justification                   = {  81509, 377043, 1 }, -- Judgment's damage is increased by 10%.
    lay_on_hands                    = {  81597,    633, 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    lightforged_blessing            = {  93008, 403479, 1 }, -- Divine Storm heals you and up to 2 nearby allies for 2.0% of maximum health.
    obduracy                        = {  81630, 385427, 1 }, -- Speed increased by 2% and damage taken from area of effect attacks reduced by 2%.
    of_dusk_and_dawn                = {  81624, 385125, 1 }, -- When you cast 3 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals 10% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by 4% For 10 sec.
    punishment                      = {  93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke casts an extra Crusader Strike.
    quickened_invocation            = {  93181, 379391, 1 }, -- Divine Toll's cooldown is reduced by 15 sec.
    rebuke                          = {  81604,  96231, 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 3 sec.
    recompense                      = {  81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = {  81598,  20066, 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = {  81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_plates               = {  93009, 402964, 2 }, -- Armor increased by 10%, Stamina increased by 5% and damage taken from area of effect attacks reduced by 3%.
    seal_of_alacrity                = {  81619, 385425, 2 }, -- Haste increased by 2% and Judgment cooldown reduced by 0.5 sec.
    seal_of_mercy                   = {  81611, 384897, 1 }, -- Golden Path strikes the lowest health ally within it an additional time for 100% of its effect.
    seal_of_might                   = {  81621, 385450, 2 }, -- Mastery increased by 2% and strength increased by 2%.
    seal_of_order                   = {  81623, 385129, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk increases your armor by 10% and your Holy Power generating abilities cooldown 10% faster.
    seal_of_the_crusader            = {  81626, 385728, 2 }, -- Your auto attacks deal 1,797 additional Holy damage.
    seasoned_warhorse               = {  81631, 376996, 1 }, -- Increases the duration of Divine Steed by 2 sec.
    strength_of_conviction          = {  81480, 379008, 2 }, -- While in your Consecration, your Shield of the Righteous and Word of Glory have 10% increased initial damage and healing.
    touch_of_light                  = {  81543, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 5,391 Holy damage or healing an ally for 7,052 health.
    turn_evil                       = {  93010,  10326, 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbound_freedom                 = {  93174, 305394, 1 }, -- Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target.
    unbreakable_spirit              = {  81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Divine Protection, and Lay on Hands by 30%.
    vengeful_wrath                  = {  93177, 406835, 1 }, -- Hammer of Wrath deals 50% increased damage to enemies below 35% health.

    -- Retribution
    adjudication                    = {  81537, 406157, 1 }, -- Critical Strike damage of your abilities increased by 5% and Hammer of Wrath also has a chance to cast Highlord's Judgment.
    aegis_of_protection             = {  81550, 403654, 1 }, -- Divine Protection reduces damage you take by an additional 20%.
    art_of_war                      = {  81523, 406064, 1 }, -- Your auto attacks have a 20% chance to reset the cooldown of Blade of Justice. Critical strikes increase the chance by an additional 10%.
    avenging_wrath_might            = {  81544,  31884, 1 }, -- Call upon the Light to become an avatar of retribution, increasing your critical strike chance by 20% for 20 sec.
    blade_of_justice                = {  81526, 184575, 1 }, -- Pierce enemies with a blade of light, dealing 35,979 Holy damage to your target and 31,635 Holy damage to nearby enemies. Generates 1 Holy Power.
    blade_of_vengeance              = {  81545, 403826, 1 }, -- Blade of Justice now hits nearby enemies for 31,635 Holy damage. Deals reduced damage beyond 5 targets.
    blades_of_light                 = {  93164, 403664, 1 }, -- Templar Strikes, Judgment, Hammer of Wrath and your damaging single target Holy Power abilities now deal Holystrike damage and your abilities that deal Holystrike damage deal 5% increased damage.
    blessed_champion                = {  81541, 403010, 1 }, -- Crusader Strike and Judgment hit an additional 4 targets but deal 25% reduced damage to secondary targets.
    boundless_judgment              = {  81533, 405278, 1 }, -- Judgment generates 1 additional Holy Power and has a 50% increased chance to trigger Mastery: Highlord's Judgment.
    burn_to_ash                     = {  92686, 446663, 1 }, -- When Truth's Wake critically strikes, its duration is extended by 2 sec. Your other damage over time effects deal 30% increased damage to targets affected by Truth's Wake.
    burning_crusade                 = {  81536, 405289, 1 }, -- Divine Storm, Divine Hammer and Consecration now deal Radiant damage and your abilities that deal Radiant damage deal 5% increased damage.
    consecrated_ground              = {  81512, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed. Your Divine Hammer is 25% larger, and enemies within them have 30% reduced movement speed.
    crusade                         = {  81544, 384392, 1 }, -- Call upon the Light and begin a crusade, increasing your haste by 3% for 27 sec. Each Holy Power spent during Crusade increases haste by an additional 3%. Maximum 10 stacks. If Avenging Wrath is known, also grants 3% damage per stack.
    crusading_strikes               = {  93186, 404542, 1 }, -- Crusader Strike replaces your auto-attacks and deals 8,654 Physical damage, but now only generates 1 Holy Power every 2 attacks. Inherits Crusader Strike benefits but cannot benefit from Windfury.
    divine_arbiter                  = {  81540, 404306, 1 }, -- Highlord's Judgment and Holystrike damage abilities grant you a stack of Divine Arbiter. At 25 stacks your next damaging single target Holy Power ability causes 92,147 Holystrike damage to your primary target and 18,429 Holystrike damage to enemies within 6 yds.
    divine_auxiliary                = {  81538, 406158, 1 }, -- Final Reckoning and Execution Sentence grant 3 Holy Power.
    divine_hammer                   = {  81516, 198034, 1 }, -- Divine Hammers spin around you, consuming a Holy Power to strike enemies within 8 yds for 8,772 Holy damage every 1.6 sec. While active your Judgment, Blade of Justice and Crusader Strike recharge 75% faster, and increase the rate at which Divine Hammer strikes by 15% when they are cast. Deals reduced damage beyond 8 targets.
    divine_storm                    = {  81527,  53385, 1 }, -- Unleashes a whirl of divine energy, dealing 28,604 Holy damage to all nearby enemies. Deals reduced damage beyond 5 targets.
    divine_wrath                    = {  93160, 406872, 1 }, -- Increases the duration of Avenging Wrath or Crusade by 3 sec.
    empyrean_legacy                 = {  93173, 387170, 1 }, -- Judgment empowers your next Single target Holy Power ability to automatically activate Divine Storm with 25% increased effectiveness. This effect can only occur every 20 sec.
    empyrean_power                  = {  92860, 326732, 1 }, -- Crusader Strike has a 15% chance to make your next Divine Storm free and deal 15% additional damage.
    execution_sentence              = {  81539, 343527, 1 }, -- A hammer slowly falls from the sky upon the target, after 8 sec, they suffer 20% of the damage taken from your abilities as Holy damage during that time.
    executioners_will               = {  81548, 406940, 1 }, -- Final Reckoning and Execution Sentence's durations are increased by 4 sec.
    expurgation                     = {  92689, 383344, 1 }, -- Your Blade of Justice causes the target to burn for 40,152 Radiant damage over 12 sec.
    final_reckoning                 = {  81539, 343721, 1 }, -- Call down a blast of heavenly energy, dealing 70,953 Holy damage to all targets in the area and causing them to take 30% increased damage from your single target Holy Power abilities, and 15% increased damage from other Holy Power abilities for 12 sec.
    final_verdict                   = {  81532, 383328, 1 }, -- Unleashes a powerful weapon strike that deals 43,623 Holy damage to an enemy target, Final Verdict has a 15% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    guided_prayer                   = {  81531, 404357, 1 }, -- When your health is brought below 25%, you instantly cast a free Word of Glory at 60% effectiveness on yourself. Cannot occur more than once every 60 sec.
    heart_of_the_crusader           = {  93190, 406154, 2 }, -- Crusader Strike and auto-attacks deal 10% increased damage and deal 10% increased critical strike damage.
    highlords_wrath                 = {  81534, 404512, 1 }, -- Mastery: Highlord's Judgment is 50% more effective on Judgment and Hammer of Wrath. Judgment applies an additional stack of Greater Judgment if it is known.
    holy_blade                      = {  92838, 383342, 1 }, -- Blade of Justice generates 1 additional Holy Power.
    holy_flames                     = {  81545, 406545, 1 }, -- Divine Storm deals 10% increased damage and when it hits an enemy affected by your Expurgation, it spreads the effect to up to 4 targets hit. You deal 3% increased Holy damage to targets burning from your Expurgation.
    improved_blade_of_justice       = {  92838, 403745, 1 }, -- Blade of Justice now has 2 charges.
    improved_judgment               = {  81533, 405461, 1 }, -- Judgment now has 2 charges.
    inquisitors_ire                 = {  92951, 403975, 1 }, -- Every 2 sec, gain 5% increased damage to your next Divine Storm, stacking up to 10 times.
    judge_jury_and_executioner      = {  92860, 405607, 1 }, -- Holy Power generating abilities have a chance to cause your next Final Verdict to hit an additional 3 targets at 80% effectiveness.
    judgment_of_justice             = {  93161, 403495, 1 }, -- Judgment deals 10% increased damage and increases your movement speed by 10% for 5 sec. If you have Greater Judgment, Judgment slows enemies by 30% for 8 sec.
    jurisdiction                    = {  81542, 402971, 1 }, -- Final Verdict and Blade of Justice deal 10% increased damage. The range of Final Verdict and Blade of Justice is increased to 20 yds.
    justicars_vengeance             = {  81532, 215661, 1 }, -- Focuses Holy energy to deliver a powerful weapon strike that deals 36,882 Holy damage, and restores 3% of your maximum health. Damage is increased by 25% when used against a stunned target.
    light_of_justice                = {  81521, 404436, 1 }, -- Reduces the cooldown of Blade of Justice by 2 sec.
    lights_celerity                 = {  81531, 403698, 1 }, -- Flash of Light casts instantly, its healing done is increased by 20%, but it now has a 6 sec cooldown.
    penitence                       = {  92839, 403026, 1 }, -- Your damage over time effects deal 10% more damage.
    radiant_glory                   = {  81549, 458359, 1 }, -- Avenging Wrath is replaced with Radiant Glory. Radiant Glory Wake of Ashes activates Avenging Wrath for 8 sec. Each Holy Power spent has a chance to activate Avenging Wrath for 4 sec.
    righteous_cause                 = {  81523, 402912, 1 }, -- Each Holy Power spent has a 6% chance to reset the cooldown of Blade of Justice.
    rush_of_light                   = {  81512, 407067, 1 }, -- The critical strikes of your damaging single target Holy Power abilities grant you 5% Haste for 10 sec.
    sanctify                        = {  92688, 382536, 1 }, -- Enemies hit by Divine Storm take 20% more damage from Consecration and Divine Hammers for 12 sec.
    searing_light                   = {  81552, 404540, 1 }, -- Highlord's Judgment and Radiant damage abilities have a chance to call down an explosion of Holy Fire dealing 44,230 Radiant damage to all nearby enemies and leaving a Consecration in its wake. Deals reduced damage beyond 8 targets.
    seething_flames                 = {  92854, 405355, 1 }, -- Wake of Ashes deals significantly reduced damage to secondary targets, but now causes you to lash out 2 extra times for 46,518 Radiant damage.
    shield_of_vengeance             = {  81550, 184662, 1 }, -- Creates a barrier of holy light that absorbs 294,965 damage for 10 sec. When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    swift_justice                   = {  81521, 383228, 1 }, -- Reduces the cooldown of Judgment by 2 sec and Crusader Strike by 2 sec.
    tempest_of_the_lightbringer     = {  92951, 383396, 1 }, -- Divine Storm projects an additional wave of light, striking all enemies up to 20 yds in front of you for 20% of Divine Storm's damage.
    templar_strikes                 = {  93186, 406646, 1 }, -- Crusader Strike becomes a 2 part combo. Templar Strike slashes an enemy for 29,977 Radiant damage and gets replaced by Templar Slash for 5 sec. Templar Slash strikes an enemy for 55,290 Radiant damage, and burns the enemy for 50% of the damage dealt over 4 sec.
    vanguards_momentum              = {  92688, 383314, 1 }, -- Hammer of Wrath has 1 extra charge and on enemies below 20% health generates 1 additional Holy Power.
    wake_of_ashes                   = {  81525, 255937, 1 }, -- Lash out at your enemies, dealing 71,899 Radiant damage to all enemies within 14 yds in front of you, and applying Truth's Wake, burning the targets for an additional 45,052 damage over 9 sec. Demon and Undead enemies are also stunned for 5 sec. Generates 3 Holy Power.
    zealots_fervor                  = {  92952, 403509, 2 }, -- Auto-attack speed increased by 20%.

    -- Herald of the Sun
    aurora                          = {  95069, 439760, 1 }, -- After you cast Wake of Ashes, gain Divine Purpose.  Divine Purpose Your next Holy Power ability is free and deals 10% increased damage and healing.
    blessing_of_anshe               = {  95071, 445200, 1 }, -- Your damage and healing over time effects have a chance to increase the damage of your next Hammer of Wrath by 200% and make it usable on any target, regardless of their health.
    dawnlight                       = {  95099, 431377, 1, "herald of the sun" }, -- Casting Wake of Ashes causes your next 2 Holy Power spending abilities to apply Dawnlight on your target, dealing 83,845 Radiant damage or 100,616 healing over 8 sec. 8% of Dawnlight's damage and healing radiates to nearby allies or enemies, reduced beyond 5 targets.
    eternal_flame                   = {  95095, 156322, 1 }, -- Heals an ally for 117,396 and an additional 46,560 over 16 sec. Healing increased by 35% when cast on self.
    gleaming_rays                   = {  95073, 431480, 1 }, -- While a Dawnlight is active, your Holy Power spenders deal 5% additional damage or healing.
    illumine                        = {  95098, 431423, 1 }, -- Dawnlight reduces the movement speed of enemies by 50% and increases the movement speed of allies by 20%.
    lingering_radiance              = {  95071, 431407, 1 }, -- Dawnlight leaves an Eternal Flame for 6 sec on allies or a Greater Judgment on enemies when it expires or is extended.
    luminosity                      = {  95080, 431402, 1 }, -- Critical Strike chance of Hammer of Wrath and Divine Storm increased by 10%.
    morning_star                    = {  95073, 431482, 1 }, -- Every 5.0 sec, your next Dawnlight's damage or healing is increased by 5%, stacking up to 10 times. Morning Star stacks twice as fast while out of combat.
    second_sunrise                  = {  95086, 431474, 1 }, -- Divine Storm and Hammer of Wrath have a 15% chance to cast again at 30% effectiveness.
    solar_grace                     = {  95094, 431404, 1 }, -- Your Haste is increased by 2% for 12 sec each time you apply Dawnlight. Multiple stacks may overlap.
    sun_sear                        = {  95072, 431413, 1 }, -- Hammer of Wrath and Divine Storm critical strikes cause the target to burn for an additional 6,707 Radiant damage over 4 sec.
    suns_avatar                     = {  95105, 431425, 1 }, -- During Avenging Wrath, you become linked to your Dawnlights, causing 3,726 Radiant damage to enemies or 838 healing to allies that pass through the beams, reduced beyond 5 targets. Activating Avenging Wrath applies up to 4 Dawnlights onto nearby allies or enemies and increases Dawnlight's duration by 20%.
    will_of_the_dawn                = {  95098, 431406, 1 }, -- Movement speed increased by 5% while above 80% health. When your health is brought below 35%, your movement speed is increased by 40% for 5 sec. Cannot occur more than once every 1 min.

    -- Templar
    bonds_of_fellowship             = {  95181, 432992, 1 }, -- You receive 20% less damage from Blessing of Sacrifice and each time its target takes damage, you gain 4% movement speed up to a maximum of 40%.
    endless_wrath                   = {  95185, 432615, 1 }, -- Calling down an Empyrean Hammer has a 10% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    for_whom_the_bell_tolls         = {  95183, 432929, 1 }, -- Divine Toll grants up to 100% increased damage to your next 3 Judgment when striking only 1 enemy. This amount is reduced by 20% for each additional target struck.
    hammerfall                      = {  95184, 432463, 1 }, -- Templar's Verdict and Divine Storm calls down an Empyrean Hammer on a nearby enemy. While Shake the Heavens is active, this effect calls down an additional Empyrean Hammer.
    higher_calling                  = {  95178, 431687, 1 }, -- Crusader Strike, Hammer of Wrath and Blade of Justice extend the duration of Shake the Heavens by 1 sec.
    lights_deliverance              = {  95182, 425518, 1 }, -- You gain a stack of Light's Deliverance when you call down an Empyrean Hammer. While Wake of Ashes and Hammer of Light are unavailable, you consume 60 stacks of Light's Deliverance, empowering yourself to cast Hammer of Light an additional time for free.
    lights_guidance                 = {  95180, 427445, 1, "templar" }, -- Wake of Ashes is replaced with Hammer of Light for 12 sec after it is cast.  Hammer of Light: Hammer down your enemy with the power of the Light, dealing 142,678 Holy damage and 71,339 Holy damage up to 4 nearby enemies. Additionally, calls down Empyrean Hammers from the sky to strike 3 nearby enemies for 11,438 Holy damage each. Costs 5 Holy Power.
    sacrosanct_crusade              = {  95179, 431730, 1 }, -- Wake of Ashes surrounds you with a Holy barrier for 10% of your maximum health. Hammer of Light heals you for 5% of your maximum health, increased by 1% for each additional target hit. Any overhealing done with this effect gets converted into a Holy barrier instead.
    sanctification                  = {  95185, 432977, 1 }, -- Casting Judgment increases the damage of Empyrean Hammer by 10% for 10 sec. Multiple applications may overlap.
    shake_the_heavens               = {  95187, 431533, 1 }, -- After casting Hammer of Light, you call down an Empyrean Hammer on a nearby target every 2 sec, for 8 sec.
    undisputed_ruling               = {  95186, 432626, 1 }, -- Hammer of Light applies Judgment to its targets, and increases your Haste by 12% for 6 sec.
    unrelenting_charger             = {  95181, 432990, 1 }, -- Divine Steed lasts 2 sec longer and increases your movement speed by an additional 30% for the first 3 sec.
    wrathful_descent                = {  95177, 431551, 1 }, -- When Empyrean Hammer critically strikes, 100% of its damage is dealt to nearby enemies. Enemies hit by this effect deal 5% reduced damage to you for 8 sec.
    zealous_vindication             = {  95183, 431463, 1 }, -- Hammer of Light instantly calls down 2 Empyrean Hammers on your target when it is cast.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning        =  756, -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain 1 additional stack if you are the victim. At 100 stacks of Reckoning, your next weapon swing deals 200% increased damage, will critically strike, and activates Avenging Wrath for 6 sec.
    blessing_of_sanctuary    =  752, -- (210256) Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by 60% for 5 sec.
    blessing_of_spellwarding = 5573, -- (204018) Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    hallowed_ground          = 5535, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    lawbringer               =  754, -- (246806) Judgment now applies Lawbringer to initial targets hit for 1 min. Casting Judgment on an enemy causes all other enemies with your Lawbringer effect to suffer up to 2% of their maximum health in Holy damage.
    luminescence             =   81, -- (199428) When healed by an ally, allies within your Aura gain 2% increased damage and healing for 6 sec.
    searing_glare            = 5584, -- (410126) Call upon the light to blind your enemies in a 25 yd cone, causing enemies to miss their spells and attacks for 4 sec.
    spreading_the_word       = 5572, -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.  Blessing of Protection Physical damage reduced by 30% for 6 sec.  Blessing of Freedom Cleared of all movement impairing effects.
    ultimate_retribution     =  753, -- (355614) Mark an enemy player for retribution after they kill an ally within your Retribution Aura. If the marked enemy is slain within 12 sec, cast Redemption on the fallen ally.
    wrench_evil              = 5653, -- (460720) Turn Evil's cast time is reduced by 100%.
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
        id = function() return talent.radiant_glory.enabled and 454351 or 31884 end,
        duration = function()
            if talent.radiant_glory.enabled then return 8 end
            return talent.divine_wrath.enabled and 23 or 20
        end,
        max_stack = 1,
        copy = { 31884, 454351 }
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
    -- The healing or damage of your next Holy Shock is increased by $s1%.
    blessing_of_anshe = {
        id = 445206,
        duration = 20.0,
        max_stack = 1
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
    blessing_of_sanctuary = {
        id = 210256,
        duration = 5,
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
        id = function() return talent.radiant_glory.enabled and 454373 or 231895 end,
        duration = function()
            if talent.radiant_glory.enabled then return 10 end
            return 27 + 3 * talent.divine_wrath.rank
        end,
        type = "Magic",
        max_stack = 10,
        copy = { 231895, 454373 }
    },
    -- Mounted speed increased by $w1%.$?$w5>0[  Incoming fear duration reduced by $w5%.][]
    -- https://wowhead.com/beta/spell=32223
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    crusaders_direhorn = {
        id = 290608,
        duration = 3600,
        max_stack = 1,
    },
    -- Dealing $w1 Radiant damage and radiating $431581s1% of this damage to nearby enemies every $t1 sec.$?e2[; Movement speed reduced by $w3%.][]
    dawnlight = {
        id = 431380,
        duration = function() return 8.0 * ( buff.avenging_wrath.up and 1.25 or 1 ) end,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- suns_avatar[431425] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
    -- Movement speed reduced by ${$s3*-1}%.
    divine_hammer_snare = {
        id = 198137,
        duration = 1.5,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=403876
    divine_protection = {
        id = 498,
        duration = 8,
        max_stack = 1,
        copy = 403876
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
        duration = function () return ( 4 + ( 2 * talent.seasoned_warhorse.rank ) + ( 2 * talent.unrelenting_charger.rank ) + pvptalent.steed_of_glory.rank ) * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) end,
        max_stack = 1,
        copy = { 221885, 221886 },
    },
    -- Suffering $s1 Holy damage every $t1 sec.
    divine_vengeance = {
        id = 267620,
        duration = 4.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    earthen_ordinants_ramolith = {
        id = 453785,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by $s1%.
    empyreal_ward = {
        id = 387792,
        duration = 60.0,
        max_stack = 1,
    },
    -- Damage done to $@auracaster is reduced by $w3%.
    empyrean_hammer = {
        id = 431625,
        duration = 8.0,
        max_stack = 1,
    },
    empyrean_legacy = {
        id = 387178,
        duration = 20,
        max_stack = 1
    },
    empyrean_legacy_icd = {
        id = 387441,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Your next Divine Storm is free and deals $w1% additional damage.
    -- https://wowhead.com/beta/spell=326733
    empyrean_power = {
        id = 326733,
        duration = 15,
        max_stack = 1
    },
    -- Healing $w1 health every $t1 sec.
    eternal_flame = {
        id = 156322,
        duration = 16.0,
        pandemic = true,
        max_stack = 1,
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
        duration = function () return set_bonus.tier31_2pc > 0 and 9 or 6 end,
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
    -- Taking $w3% increased damage from $@auracaster's single target Holy Power abilities and $s4% increased damage from their other Holy Power abilities.
    final_reckoning = {
        id = 343721,
        duration = function() return 12 + 4 * talent.executioners_will.rank end,
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
    -- Your Judgment deals ${$w2*$w4}% increased damage.
    for_whom_the_bell_tolls = {
        id = 433618,
        duration = 20.0,
        max_stack = 1,
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    -- Your Holy Power spenders deal $s1% additional damage or healing while a Dawnlight is active.
    gleaming_rays = {
        id = 431481,
        duration = 30.0,
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
    hammer_of_light_ready = {
        id = 427453,
        duration = 12,
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
    -- Your next $?s383328[Final Verdict]?s215661[Justicar's Vengeance][Templar's Verdict] hits ${$w1-1} additional targets.
    judge_jury_and_executioner = {
        id = 453433,
        duration = 12.0,
        max_stack = 1,
    },
    -- Taking $w1% increased damage from $@auracaster's next Holy Power ability.
    -- https://wowhead.com/beta/spell=197277
    judgment = {
        id = 197277,
        duration = 15,
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
    lights_deliverance = {
        id = 433674,
        duration = 3600,
        max_stack = 60
    },
    -- The damage and healing of your next Dawnlight is increased by $w1%.
    morning_star = {
        id = 431539,
        duration = 15.0,
        max_stack = 1,
    },
    -- $s1% of all effective healing done will be added onto your next Holy Shock.
    power_of_the_silver_hand = {
        id = 200656,
        duration = 10.0,
        max_stack = 1,
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
    -- Empyrean Hammer damage increased by $w1%
    sanctification = {
        id = 433671,
        duration = 10.0,
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
    -- Casting Empyrean Hammer on a nearby target every $t sec.
    shake_the_heavens = {
        id = 431536,
        duration = 8.0,
        max_stack = 1,
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
    -- Haste increased by $w1%.
    solar_grace = {
        id = 439841,
        duration = 12.0,
        max_stack = 1,
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
    -- Healing $w1 every $t1 sec.
    sun_sear = {
        id = 431415,
        duration = 4.0,
        max_stack = 1
    },
    the_magistrates_judgment = {
        id = 337682,
        duration = 15,
        max_stack = 1,
    },
    -- $?(s403696)[Burning for $w2 damage every $t2 sec and movement speed reduced by $s1%.] [Movement speed reduced by $s1%.]
    truths_wake = {
        id = 403695,
        duration = 9.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,
        copy = { 339376, 383351 }
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
    -- Haste increased by $w1%
    undisputed_ruling = {
        id = 432629,
        duration = 6.0,
        max_stack = 1,
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
    -- Movement speed increased by $w1%.
    will_of_the_dawn = {
        id = 431462,
        duration = 5.0,
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


local current_crusading_strikes = 1
-- Strike 0 = SPELL_ENERGIZE occurred; Holy Power was gained -- the swing lands *after*.
-- Strike 1 = The swing that caused Holy Power gain just landed.
-- Strike 2 = The non-producing Holy Power swing has landed.
-- Strike 3 = Should never actually reach due to SPELL_ENERGIZE reset, but this would be the next productive swing.
local last_crusading_strike = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
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


spec:RegisterGear( "tier31", 207189, 207190, 207191, 207192, 207194, 217198, 217200, 217196, 217197, 217199 )
spec:RegisterAura( "echoes_of_wrath", {
    id = 423590,
    duration = 12,
    max_stack = 1
} )


-- Tier 30
spec:RegisterGear( "tier30", 202455, 202453, 202452, 202451, 202450 )

spec:RegisterGear( "tier29", 200417, 200419, 200414, 200416, 200418 )


local tempDebug = { 387174, 255937, 427453, 429826, 427441 }
local IsSpellOverlayed = IsSpellOverlayed
local C_Spell, C_UnitAuras = C_Spell, C_UnitAuras
local tostringall = tostringall

local ld_stacks = 0
local free_hol_triggered = 0

spec:RegisterHook( "reset_precast", function ()
    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5  then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 5 , "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end

    local last_ts = action.templar_strike.lastCast

    if now - last_ts < 3 and action.templar_slash.lastCast < last_ts then
        applyBuff( "templar_strikes" )
    end

    if IsSpellKnownOrOverridesKnown( 427453 ) then
        if talent.lights_deliverance.enabled then
            -- We need to track when it ticks over from 59/60 stacks.
            local stacks = buff.lights_deliverance.stack

            if stacks < ld_stacks then
                free_hol_triggered = now
            end
            ld_stacks = stacks

            if free_hol_triggered + 12 < now then free_hol_triggered = 0 end -- Reset.

            if free_hol_triggered > 0 and action.hammer_of_light.lastCast > action.wake_of_ashes.lastCast then
                local hol_remains = free_hol_triggered + 12 - query_time
                hol_remains = hol_remains > 0 and hol_remains or ( 2 * gcd.max )

                applyBuff( "hammer_of_light_free", max( 2 * gcd.max, hol_remains ) )
                if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light active; applied hammer_of_light_free: %.2f : %.2f : %.2f : %d", buff.hammer_of_light_free.remains, free_hol_triggered, query_time, ld_stacks ) end
            else
                if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light active; hammer_of_light_free ruled out: %.2f : %.2f : %d", free_hol_triggered, query_time, ld_stacks ) end
            end
        end

        if not buff.hammer_of_light_free.up then
            local hol_remains = action.wake_of_ashes.lastCast + 12 - query_time
            hol_remains = hol_remains > 0 and hol_remains or ( 2 * gcd.max )
            applyBuff( "hammer_of_light_ready", hol_remains )
            if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light not active; applied hammer_of_light_ready: %.2f", buff.hammer_of_light_ready.remains ) end
        end

        if buff.hammer_of_light_ready.down and buff.hammer_of_light_free.down then
            if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light appears active [ %.2f ] but I don't know why; applying hammer_of_light_ready." ) end
            applyBuff( "hammer_of_light_ready", 2 * gcd.max )
        end
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
    -- if buff.fires_of_justice.up then return max( 0, amt - 1 ) end
    return amt
end )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Call upon the Light to become an avatar of retribution, $?s53376&c2[causing Judgment to generate $53376s3 additional Holy Power, ]?s53376&c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies, ]?s53376&c1[reducing Holy Shock's cooldown by $53376s2%, ][]$?s326730[allowing Hammer of Wrath to be used on any target, ][]$?s384442&s384376[increasing your damage, healing and critical strike chance by $s2% for $d.]?!s384442[increasing your damage and healing by $s1% for $d.]?!s384376[increasing your critical strike chance by $s3% for $d.][and activating all the effects learned for Avenging Wrath for $d.]
    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = function () return ( level > 42 and 60 or 120 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",
        school = "holy",

        notalent = function()
            return talent.radiant_glory.enabled and "radiant_glory" or "crusade"
        end,
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
                spec.abilities.consecration.handler()
                removeBuff( "consecrated_blade" )
            end
            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
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

    blessing_of_sanctuary = {
        id = 210256,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        pvptalent = "blessing_of_sanctuary",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_sanctuary" )
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

        spend = 0.10,
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

        usable = function() return level < 11 end,

        handler = function ()
            applyBuff( "consecration" )
        end,
    },

    -- Call upon the Light and begin a crusade, increasing your haste $?s384376[and damage ][]by ${$s5/10}% for $d.; Each Holy Power spent during Crusade increases haste $?s384376[and damage ][]by an additional ${$s5/10}%.; Maximum $u stacks.$?s53376[; While active, each Holy Power spent causes you to explode with Holy light for $326731s1 damage to nearby enemies.][]$?s384376[; Hammer of Wrath may be cast on any target.][];
    crusade = {
        id = 231895,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        toggle = "cooldowns",

        startsCombat = false,
        texture = 236262,
        talent = "crusade",
        notalent = "radiant_glory",

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

        talent = "crusader_aura",
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
        cooldown = function () return ( talent.swift_justice.enabled and 4 or 6 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
        recharge = function () return ( talent.swift_justice.enabled and 4 or 6 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
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

    -- Divine Hammers spin around you, consuming a Holy Power to strike enemies within $198137A1 yds for $?s405289[${$198137sw1*1.05} Radiant][$198137sw1 Holy] damage every $t sec. ; While active your Judgment, Blade of Justice$?a404542[][ and Crusader Strike] recharge $s2% faster, and increase the rate at which Divine Hammer strikes by $s1% when they are cast. Deals reduced damage beyond 8 targets.
    divine_hammer = {
        id = 198034,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "divine_hammer",
        startsCombat = false,
        texture = 626003,

        handler = function ()
            applyBuff( "divine_hammer" ) -- TODO: Tick down Holy Power.
        end,
    },

    -- Talent: Reduces all damage you take by $s1% for $d.
    divine_protection = {
        id = function() return state.spec.retribution and 403876 or 498 end,
        cast = 0,
        cooldown = function () return 60 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "off",
        school = "holy",

        spend = 0.035,
        spendType = "mana",

        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            applyBuff( "divine_protection" )
        end,

        copy = { 403876, 498 },
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
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "divine_storm",
        startsCombat = true,

        handler = function ()
            removeBuff( "echoes_of_wrath" )
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )

            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end

            if buff.empyrean_power.up then
                removeBuff( "empyrean_power" )
            elseif buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
                removeBuff( "hidden_retribution_t21_4p" )
            end

            if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end

            if talent.holy_flames.enabled and debuff.expurgation.up and active_enemies > active_dot.expurgation then
                active_dot.expurgation = min( active_enemies, active_dot.expurgation + 4 )
            end

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

            if debuff.expurgation.up and set_bonus.tier31_4pc > 0 then
                applyBuff( "echoes_of_wrath" )
            end

            if talent.divine_resonance.enabled or legendary.divine_resonance.enabled then
                applyBuff( "divine_resonance" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires     , "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 5 , "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 10, "AURA_PERIODIC" )
            end

            if talent.rising_sunlight.enabled then addStack( "rising_sunlight", nil, 2 ) end
        end,

        copy = { 375576, 304971 }
    },

    -- Heals an ally for $s2 and an additional $o1 over $d.; Healing increased by $s3% when cast on self.
    eternal_flame = {
        id = 156322,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = function() return buff.divine_purpose.up and 0 or 3 end,
        spendType = 'holy_power',

        talent = "eternal_flame",
        startsCombat = false,

        handler = function()
            removeStack( "divine_purpose" )
            applyBuff( "eternal_flame" )
        end,
    },

    -- Talent: A hammer slowly falls from the sky upon the target. After $d, they suffer ${$387113s1*$<mult>} Holy damage$?s387196[ and enemies within $387200a2 yards will suffer $387196s1% of the damage taken from your abilities in that time.][, plus $s2% of damage taken from your abilities in that time.]
    execution_sentence = {
        id = 343527,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        spend = function () return talent.divine_auxiliary.enabled and -3 or 0 end,
        spendType = "holy_power",

        talent = "execution_sentence",
        startsCombat = false,

        handler = function ()
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

    -- Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the area and causing them to take $s3% increased damage from your single target Holy Power abilities, and $s4% increased damage from other Holy Power abilities for $d.; $?s406158 [Generates $406158s1 Holy Power.][]
    final_reckoning = {
        id = 343721,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        spend = function() return talent.divine_auxiliary.enabled and -3 or 0 end,
        spendType = "holy_power",

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

        spend = 0.1,
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

    -- Hammer down your enemy with the power of the Light, dealing $429826s1 Holy damage and ${$429826s1/2} Holy damage up to 4 nearby enemies. ; Additionally, calls down Empyrean Hammers from the sky to strike $427445s2 nearby enemies for $431398s1 Holy damage each.;
    hammer_of_light = {
        id = 427453,
        known = function() return state.spec.protection and 387174 or 255937 end,
        flash = function() return state.spec.protection and 387174 or 255937 end,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = function()
            if buff.divine_purpose.up or buff.hammer_of_light_free.up then return 0 end
            return state.spec.protection and 3 or 5
        end,
        spendType = 'holy_power',

        startsCombat = true,
        buff = function() return buff.hammer_of_light_free.up and "hammer_of_light_free" or "hammer_of_light_ready" end,

        handler = function ()
            removeBuff( "divine_purpose" )

            if buff.hammer_of_light_free.up then
                removeBuff( "hammer_of_light_free" )
            else
                removeBuff( "hammer_of_light_ready" )

                if buff.lights_deliverance.stack_pct == 100 then
                    removeBuff( "lights_deliverance" )
                    applyBuff( "hammer_of_light_free" )
                end
            end
        end,

        bind = { "wake_of_ashes", "eye_of_tyr" }
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

        usable = function () return target.health_pct < 20 or ( talent.avenging_wrath.enabled and ( buff.avenging_wrath.up or buff.crusade.up ) ) or buff.final_verdict.up or buff.blessing_of_anshe.up or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires buff/talent or target under 20% health" end,
        handler = function ()
            removeBuff( "final_verdict" )
            if buff.divine_arbiter.stack > 24 then removeBuff( "divine_arbiter" ) end
            if talent.zealots_paragon.enabled then
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 0.5 end
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 0.5 end
            end
            if set_bonus.tier30_2pc > 0 then
                applyDebuff( "target", "judgment" )
                if set_bonus.tier30_4pc > 0 then
                    active_dot.judgment = min( active_enemies, active_dot.judgment + 4 )
                end
            end
            if legendary.the_mad_paragon.enabled then
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 1 end
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 1 end
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

    -- [114165] Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_prism = {
       id = 114852,
       cast = 0.0,
       cooldown = 20.0,
       gcd = "spell",

       spend = 0.026,
       spendType = "mana",

       startsCombat = true,

       handler = function ()
       end,

       copy = 114165
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
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
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
            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
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

    --[[ Talent: Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yd in front of you and reducing their movement speed by $s2% for $d. Damage reduced on secondary targets.    Demon and Undead enemies are also stunned for $255941d.    |cFFFFFFFFGenerates $s3 Holy Power.
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

        handler = function ()
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )
            if target.is_undead or target.is_demon then applyDebuff( "target", "radiant_decree" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if talent.truths_wake.enabled or conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,
    }, ]]

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

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeBuff( "divine_purpose" )
            removeBuff( "the_magistrates_judgment" )
            applyBuff( "shield_of_the_righteous" )

            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end
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
            if ( settings.sov_damage or 20 ) > 0 then return incoming_damage_5s > 0.01 * settings.sov_damage * health.max, "incoming damage over 5s must exceed " .. settings.sov_damage .. "% of max health" end
            return true
        end,

        handler = function ()
            applyBuff( "shield_of_vengeance" )
        end,
    },

    -- Complete the Templar combo, slash the target for $<damage> $?s403664[Holystrike][Radiant] damage, and burn them over 4 sec for 50% of the damage dealt.; Generate $s2 Holy Power.
    templar_slash = {
        id = 406647,
        known = 407480,
        rangeSpell = 35395,
        flash = 407480,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0.004,
        spendType = "mana",

        startsCombat = true,
        texture = 1112940,
        talent = "templar_strikes",
        buff = "templar_strikes",

        handler = function ()
            gain( 1, "holy_power" )
            removeBuff( "templar_strikes" )
            if talent.divine_arbiter.enabled then addStack( "divine_arbiter" ) end
        end,

        bind = { "templar_strike", "crusader_strike" }
    },

    -- Begin the Templar combo, striking the target for 3,207 Radiant damage. Generates 1 Holy Power.
    templar_strike = {
        id = 407480,
        rangeSpell = 35395,
        cast = 0,
        charges = 2,
        cooldown = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
        recharge = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
        gcd = "totem",
        school = "physical",

        spend = 0.004,
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

    -- Unleashes a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage to an enemy target,; Final Verdict has a $s2% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    templars_verdict = {
        id = function() return talent.final_verdict.enabled and 383328 or runeforge.final_verdict.enabled and 336872 or 85256 end,
        -- known = 85256,
        -- flash = 85256,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",
        notalent = "justicars_vengeance",

        startsCombat = true,

        handler = function ()
            removeBuff( "echoes_of_wrath" )
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )
            removeStack( "vanquishers_hammer" )

            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end

            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "hidden_retribution_t21_4p" )
            end

            if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
            if buff.empyrean_legacy.up then
                spec.abilities.divine_storm.handler() -- TODO: Check for resource gain?
                removeBuff( "empyrean_legacy" )
            end
            if buff.divine_arbiter.stack > 24 then removeBuff( "divine_arbiter" ) end

            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if talent.righteous_verdict.enabled then applyBuff( "righteous_verdict" ) end
        end,

        copy = { "final_verdict", 336872, 383328, 85256 },
    },

    -- Talent: The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = function() return talent.wrench_evil.enabled and 0 or 1.5 end,
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

    --- Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yds in front of you, and applying $@spellname403695, burning the targets for an additional ${$403695s2*($403695d/$403695t+1)} damage over $403695d.; Demon and Undead enemies are also stunned for $255941d.; Generates $s2 Holy Power.
    wake_of_ashes = {
        id = 255937,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holyfire",

        spend = -3,
        spendType = "holy_power",

        talent = "wake_of_ashes",
        nobuff = function() return buff.hammer_of_light_free.up and "hammer_of_light_free" or "hammer_of_light_ready" end,
        startsCombat = true,

        usable = function ()
            if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
            return true
        end,

        handler = function ()
            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end
            if target.is_undead or target.is_demon then applyDebuff( "target", "wake_of_ashes" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if talent.lights_guidance.enabled then applyBuff( "hammer_of_light_ready" ) end
            if talent.radiant_glory.enabled then
                if talent.crusade.enabled then applyBuff( "crusade", 10 )
                else applyBuff( "avenging_wrath", 8 ) end
            end
            if conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,

        bind = "hammer_of_light"
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
            return 3 - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            spend( 0.1 * mana.max, "mana" )
            removeBuff( "recompense" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "hidden_retribution_t21_4p" )
                removeBuff( "the_magistrates_judgment" )
            end
            gain( 1.33 * stat.spell_power * 8, "health" )

            if talent.faiths_armor.enabled then applyBuff( "faiths_armor" ) end
            if conduit.shielding_words.enabled then applyBuff( "shielding_words" ) end
        end,
    },
} )

spec:RegisterRanges( "hammer_of_justice", "rebuke", "crusader_strike", "blade_of_justice", "hammer_of_wrath" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

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

--[[ Retired 20230426.
    spec:RegisterSetting( "desync_toll", false, {
    name = "Desync |T3565448:0|t Divine Toll",
    desc = "If checked, when Seraphim, Final Reckoning, and/or Execution Sentence are toggled off or disabled, the addon will recommend |T3565448:0|t Divine Toll despite being out of sync with your cooldowns.\n\n"
        .. "This is useful for maximizing the number of Divine Toll casts in a fight, but may result in a lower overall DPS.",
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterPack( "Retribution", 20240928, [[Hekili:T3rApQns2FlTgfcKPdbBG0DMTHvAhPv7enkFyzKMVbuGnGNySz9rFiH8V9TQYx1XRkxaMENztKIs646539vD4QNBn)3MpZbL4o)l2dShn4t2333AG19J(08zjVCWD(SdO1FfTf)dbO94)(F7Me5TknXlmGm2l(HihcoIdtJwJhF(SvPE(j)sW8vqiEW4Hyyp4UE(xUBW8z78CCCZb1nE98zeqF)Gp9E77)PSLZ82)ZzltpqWYFlB5)k8xZwUX75)E2NZ(CjGwdUnBj5fSfEHAGUphB)tVNlWbkWPcQLBIc3x8MSVXOQ3aTFVBu2YWnzl)vVT7sQb7U3Bped2VTdJMFhHH539s25rulrHB88Xkd0AIEkU)Hi31H7xHs(XjFiENNRVZIWnlE0nyRlkynMxHa8ruKhALV7Tef)eSwp4RUjlSwSkDZM4BFe5Nw90(w93HIPJ0pojcJ3KDhpcm4EuCIB0lGJ9OBumkXZ3lbE8DK3fCK1rEjNImydkd26KbBnYGDdYGTszW(8LbRfXVeS(2WdtIDt82uilw5)7cx)y3jd6p(21HboEeCoPen9fSKD6wRrxhg67e(uqFN0ie5TEZBQE06O0yKJB1qtgC8OYbFZB0GuYBAgnrexuVGTlEcp0oysRaMg4GENIU2(I112I6A7RHUgaPS6A90Sv01GCWjPRpe5fIdfEruBBZQTTy013O0XwLv44r12hTgO6XWzyx3hf8YcNdXvJ37DDT6p(h1KpbdbaPjox96nTR2aX6XmH2a5JHOTvbTj1ukmrydtK7Q0V6Y(K1iF)f5)3f(EXj5MSsMmUzq36g4Iz0WOygsvjLK37qi5z36TzcLRf80spC8yrAYCNFYdCCPpY9z310(bwe7gK4IRNLdEyCCNnKkMlIC3J8cIFy4GSp)d)aUama99cEm8Ry3RNX52dq(uDxoVFi8j3OfEbBsJBtoewn4ty44f)rQZ29yyjud3TcwLMGI26Me3xaGPtSpE8MiKNZcxmdL0h54eJjiwZJ9ZfFUxW07gl)yvmZgpSRGFyOZji0D4()Xj4U3Myn4CufPXUl8sC3FBSFysz(blcR0TlmZ0rvIQchGPJgyi)2RZnjiFIckc54HcswS1pKwZh4PD6wcSS0vZspHWUx4UUqX7CJl5OjnOz61JGCUekLiemVEbAbYWvMxDIvp2QVGjtMoHlUPdju6eSr2FdBJSuyJSojBKDpwR71WgrJJux6eQmyfFl)AvfwVr0Yj11sPz2Eqj0NUlInBlfnkQ2WIQulzqMiLAO)NlQatJJiNCoftTgRZVhZvA9RHjSmS0WDZvhwJfcWRls0G24Hb9jLVAsNriauoaCC6Uq)xwqlOpDYOojE7DFadm7thsF6uHNAJDtYXOJ3JEbUlqPpJNLhsv6gsoH8k29jOBrs4chp3P33rYAGNW4IN889j4rcEl7EnKC6HTRDGTt8khQn68LEfcFNUvChGlet(ZkW24rAUcplGVggGzUAyOzrLBmbwTOkOOWJIiSS8)yTYQQEF4yuv6V7bX5K7VC3Ng9YHMtyz1aPWrOqUPKIOQkxQQDVcOlqKbENGgwvnOsOaqtRJgWoffItKhMmrXsZI0bx7fHfoYdYN3yx(2Nl0)X4PISN27CE(V9hEjcNdn3Er5IYa1C)GhDJC8wNughGlXCWnoHiVj7Cxq7jFfUaXw3iCxj8O03DlA9lKmI3KRulDbIwHlvfv1EJWJZTq2J6bl27OlliHb8ZxuqiGkqzoS8bftgR9vO6hYBuv)JrZwiHcSaowb5qLZQsofojQ9tNI9pE3qt637bI7UIK63WQ)Y5kQjSIQ8dvfaznOdxeTcv9FKgN4TgHZtZvP9vwkBuNFDvcepE)CDans4)V1a16G6fUqoORAwXI80Mix(P1YHf4viPszFBmUvZ1jtSedyzlPGl)WkTrUXHbiXjtZr1cd4IyFCg6koV6PyA(v(82VZwbMw5JTweHnpWGgmCJtiPNMdPrBPZobxUE9xX5dltys58n(ybnwbw5QFW5DvSIhBt9Cq0UwbBnrakdkG(rn(RFuDYgnTtBqZqthb1rZd3FkfjXfejrjY1o7Pq3w4LKe67Z7u9aPZKwGUnRSTgRrBRQH9Jh5x)U7vjGNxifPDnJYi1wHuD02lYjeU1L1eoSUzf6JPVa2KOLyLHnvyVQ2MkDCDsU6juOMepyxZv4wgIJDDwSgJIdyeZnpmk)xerSZf5J9zoSojFoZfV)JOGTPOiChi7djR5z6(6zxv)kpmCCPqrLLnP(5CArzhkxqCmjjzcW(fAcy4THkaIDnAvypwfMg4qOB161Ecg5gTX)vWq1KcMe60cb1aUdtSlxiXMx0Avtdqz(M83S0bHWbIj3khRpwzIzTyCtb5Oc5JN3v)7gZRBTzlRHv11tSs01GRNkBHMcm8TQHR0VKF8ZmpR5oKxOBLzMffqHIwJOvdJIWiB(mYE2JHQ6CIypF2tOiYK(JNpJE4k82FimkjB5MWOSLVTApmFB2Yi3)tQxKRt2YymRLTeLMeUhLqEa2UJZcf3p7Z)koylBj5aI8ZHbyQrh(TA2QomItczajbgMUwp3RfrpzXtjWDgyU4irOJVRbPDr(fW1mhwdDCopyTprUajGECs0X7La0Mi(c4xYHCrh7wmElIwvm7qfyfyt7LWmmmTm6VagxvadiiTlYVaUwxGIsWAFICbsaCqdaaTjIVa(fmSrE8weTQy2rkJXRx8MI99eiohcMRk6VAi(7893e8D4b3CiIX9wgGXsZ7dpe(V8dmiewzpXGnq1w5idcZd9kvWNPQ5m1mxKIPjz2i9stQLkFQXkZe3SZkmmCXcTn6VAi(7893e8DZ5mLoqpq4VfYz2WPSUbQEj5gAGhuNZ0mvZzQzUifttYSr6LMulv(uFSLDwfIfAB0BaIbpBGaixfCgY)MsgIB2Ith9MoPyTZ5(YrVQPNOcZNBFHxz0BaInZEQgod5FtjZz52y(kBEwUnMJEdDBKQGDL(YvaZZQkgv47griqWWVxfWUHvzEfPOvJuS8RuPu9)kQ3(WRUE7dxb9g2JKUpgBc99dFcxaLSrfriSF4tUr4NJrItUpzcbS8DnjBjzhEYwUknPeUGq6MGKgWbTJdbyhucAfk29NY(C2Y3NTm)7zSGW8BGsPmh)2tAduKMDoWjgOkcfyS(Ube1JJyy6RmELpBicih4WJykfk8n4)qruuSJzydrALVAXEfQRhMAqUIiVr0AEfiJk0D5KrBHoPPs1soIVY4TfDWvn5sl9o4sdBisB0heeKRiYBeTM3zUro4xozoRo5oVO)RkYRq7DTQbvGNBxKxH27V6bMF6kLsrbEf)QjeqT4WNi2VwCT034Jk1D54QWV1GRQAXsAl2Fvq)fR2F1rCXsFjGYYfetczGn)wDyPE7j18RfmhX91PiWxCJPuuHXRMpWfbQObsJBB9S0Ux3M3v0BZzXJxR(VKQ4Db8OcCDb8iO3F9bX70C)vyMz(SceyoMrorZIWhsGaEfg9pr4(cmvVwTZ3(ozAR)wFsPHCoOdCIyu(0YlGzzao1A6Reod2seGF4tf9YNLwbcidWjtcUtFVi65g8ulalFE6fvpsaOKesNKPl2PXsrwQ2YKQa9TPjvHFFRqISp)l0AbeepMFvgjj6NpJ(t07dq3nOu)e8p(f69dyoOZNLFXenFwbQN)pMNm)l2eiQFsfWINv9C8Vi)weSAjijyy45GH6kzyuKqUZ9kov4sCnWn1qdIq4b8B5MuJIYL2L8t(P4)rXQaNT84rSH5vDqk3vOukaPC94HuUNGSzRJjEvges2SRLTrWYM3gyPtwlrwFESFwe5l(2dvdT4gBKTSdomIZeiTXbzlFdUVPYNkUl9zlNKTCqUWQbO30enQXI58IITThKLucRHCwVc3i69e38zd6pUYVYIyYgFzMm7Mnz2kmza7UuRBYaPbGjRrEP1nzA4SMmzF8YmzLxQsSgTBYwQnutTrLi5nzYB0Q)boa4wYuS6iB57O4WQpUk5pQjXvfKk2Rrke4)mvIRadG(ahagZvILkuZvwmCfVn3QYIBNxnLP6Az5ugpGAdjHK9v853x7Eiaauj3Auw)PPrDqhNBZfE6iQTMsDGpbFS)zc5BtKW5M1nr1QcbvYuqCv8bgNT8HSLBx70Fp6zQjWUM2CFULqvU4cnu8T8tfz1tVUMAIF7Hq5DRji2t5Mk8QykWY2GPyJGnlhP8n7vgwQkHvL(dhN8rfPBbGr3euzOATSPEEYcev9ThaL(JkPV4Tia1d4EEAd)T9NJb5VVFk(TgapC6bACBPvM7cBakpnCi1dvgURddEkwBRXgyUlbsV9Mab3LvqLXOwJXCnmq0x3zK(I4OpSoBt93SS8ZOxxbu6An4ctbDFlKccZEQ)SZlIG1KI6t6Yyi6rnm3cCdFckUzRZ4B0iBXMyr9s6WzCHs6HndAKbDCXduMGxKwPyDcyemfQfPpVAQJT9arkOEw8m0aazyUD4ywDg8Q8KtoQd0kGlJbo1PW3movBYnRAExqHjuBzw5Dqph1lHunXlhHsl1LRBKwYEPn4qPUU9F9CO0BShdASPjheS1QR7OWBDsnRsDgLUFiygJnFB1dLUNiOsZfLW1sD1aXQtAUzjYtFrUDjuzaTLBL6HQkmvus1Thb1mZ1JPMUJplSX(EI3nfqWZ4fjOEOAvX6yNHHrDDORwWH2id7bSrgIcTWclYLYu8IVGf0ewXgykxnVSDMvxvxmeV6bC7RzlYyWopxMj7grIwDPmwoCx(zZvF5mknrpUlOXCt7OIj0wU0dm3vIvZ1u1Cr5nyMvlHmTuP2kZrS(j39iWT5iNcs1TRN8Sze2pzdAKMnYDOIuS6AP1K2WzN6dRrR66auGpbVsaZB7NqWoYt6Ceul9uF8tyAU)zw5DcUcVgAyGBFt9t287k6ZtrlEdFMxuOe9MSoCNsFuA)1br(RrUq7jST80QhoOMTZ)9gI(L0t7Vbn4knDEliXDJHhMDnifOQbRZNPQtfEJtQ9g1PSR5WQFBFavdPYljFTCTeI46QUv6oMTwmJgCwIxvOuZlpJEieRVPB16yfjW79A29jrVNEpHLkKFT(lPsHaaSPcveKaG0kUxU3h5QlkP4qK0Y8tcfeI36KhkIJI8dtyCaaQ2j4Ky)DNKRRtILoNe5diUjoj2Yojs7qLXoj2qvQ1Lj5Mg2xUUgeeaHdUTV7gy)hTDfWm7Tl0f2oFhpLdMexaaDbtALXok3RVg1tw)5wpzRFPPf8jlw7(tjMTG1BiAS22aD0EAAPRph1A5Eq0qD(g1R4ENg0)oXD9WGDiXK(z7c2HjEaYwurPnWEPwV9g5qnvjuvBAubVO6ZpWqgwC9S52hTP0TUPdOBJ4hRrj9aXILDjLAQwq9oNu7Ej7a28UkC9nbnQ)7WVbC62oZjYhNef)gIP60IKPD)nl7swL9yax8lVNF9Mm04kWq0gJplnR0s31W(v0Sj9Edi8eLGDTcRmk7IQt3eBFfkszQkD406E(AMH7OTPuM3xADeoPi6g9A1nhZsorXCphX7rle9mVyA8O0KDHrZNr(9mn9jZ)V)]] )