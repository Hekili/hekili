-- PaladinRetribution.lua
-- August 2025
-- Patch 11.2

-- TODO: If blessing of dawn is ever added to the APL, use combatlogs to build a tracker for the hidden counter
-- TODO: There are probably more edge cases you can add for Hammer of Light free predictions

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 70 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local GetSpellCooldown = C_Spell.GetSpellCooldown

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    a_just_reward                  = { 103858,  469411, 1 }, -- After Cleanse Toxins successfully removes an effect from an ally, they are healed for $s1
    afterimage                     = {  93189,  385414, 1 }, -- After you spend $s1 Holy Power, your next Word of Glory echoes onto a nearby ally at $s2% effectiveness
    auras_of_the_resolute          = {  81600,  385633, 1 }, -- Learn Concentration Aura, Devotion Aura, and Crusader Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within $s3 yds are $s4% shorter.  Devotion Aura: Party and raid members within $s7 yds are bolstered by their devotion, reducing damage taken by $s8%.  Crusader Aura: Increases mounted speed by $s11% for all party and raid members within $s12 yds
    blessed_calling                = { 103868,  469770, 1 }, -- Allies affected by your Blessings have $s1% increased movement speed
    blessing_of_freedom            = {  81631,    1044, 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for $s1 sec
    blessing_of_protection         = {  81616,    1022, 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $s1 sec. Cannot be used on a target with Forbearance. Causes Forbearance for $s2 sec
    blessing_of_sacrifice          = {  81614,    6940, 1 }, -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer $s2% of damage prevented. Last $s3 sec, or until transferred damage would cause you to fall below $s4% health
    blinding_light                 = {  81598,  115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within $s1 yds, causing them to wander disoriented for $s2 sec. Damage may cancel the effect
    cavalier                       = {  81605,  230332, 1 }, -- Divine Steed now has $s1 charges
    cleanse_toxins                 = {  81507,  213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects
    consecrated_ground             = {  81543,  204054, 1 }, -- Your Consecration is $s1% larger, and enemies within it have $s2% reduced movement speed. Your Divine Hammer is $s3% larger, and enemies within them have $s4% reduced movement speed
    divine_purpose                 = {  81618,  408459, 1 }, -- Holy Power spending abilities have a $s1% chance to make your next Holy Power spending ability free and deal $s2% increased damage and healing
    divine_reach                   = {  93168,  469476, 1 }, -- The radius of your auras is increased by $s1 yds
    divine_resonance               = {  93181,  384027, 1 }, -- After casting Divine Toll, you instantly cast Judgment every $s1 sec for $s2 sec
    divine_spurs                   = { 103857,  469409, 1 }, -- Divine Steed's cooldown is reduced by $s1%, but its duration is reduced by $s2%
    divine_steed                   = {  81632,  190784, 1 }, -- Leap atop your Charger for $s1 sec, increasing movement speed by $s2%. Usable while indoors or in combat
    divine_toll                    = {  81496,  375576, 1 }, -- Instantly cast Judgment on up to $s1 targets within $s2 yds. Divine Toll's Judgment deals $s3% increased damage
    empyreal_ward                  = { 103859,  387791, 1 }, -- Lay on Hands grants the target $s1% increased armor for $s2 sec and now ignores healing reduction effects
    eye_for_an_eye                 = {  81628,  469309, 1 }, -- Melee and ranged attackers receive $s$s2 Holy damage each time they strike you during Divine Protection and Divine Shield
    faiths_armor                   = {  81495,  406101, 1 }, -- Word of Glory grants $s1% bonus armor for $s2 sec
    fist_of_justice                = {  81602,  234299, 1 }, -- Hammer of Justice's cooldown is reduced by $s1 sec
    golden_path                    = { 103856,  377128, 1 }, -- Consecration heals you and $s1 allies within it for $s2 every $s3 sec
    greater_judgment               = {  81603,  231663, 1 }, -- Judgment causes the target to take $s1% increased damage from your next Holy Power ability. Multiple applications may overlap
    hammer_of_wrath                = {  81510,   24275, 1 }, -- Hurls a divine hammer that strikes an enemy for $s$s2 Holystrike damage. Only usable on enemies that have less than $s3% health, or during Avenging Wrath. Generates $s4 Holy Power
    healing_hands                  = {  93189,  326734, 1 }, -- The cooldown of Lay on Hands is reduced up to $s1%, based on the target's missing health. Word of Glory's healing is increased by up to $s2% on yourself, based on your missing health
    holy_aegis                     = {  81609,  385515, 1 }, -- Armor and critical strike chance increased by $s1%
    holy_reprieve                  = { 103860,  469445, 1 }, -- Your Forbearance's duration is reduced by $s1 sec
    holy_ritual                    = { 103866,  199422, 1 }, -- Allies are healed for $s1 when you cast a Blessing spell on them and healed again for $s2 when the blessing ends
    improved_blessing_of_protection = {  81617,  384909, 1 }, -- Reduces the cooldown of Blessing of Protection by $s1 sec
    inspired_guard                 = { 103864,  469439, 1 }, -- Divine Protection increases healing taken by $s1% for its duration
    judgment_of_light              = {  81608,  183778, 1 }, -- Judgment causes the next $s1 successful attacks against the target to heal the attacker for $s2
    lay_on_hands                   = {  81597,     633, 1 }, -- Heals a friendly target for an amount equal to $s1% your maximum health. Grants the target $s2% increased armor for $s3 sec. Cannot be used on a target with Forbearance. Causes Forbearance for $s4 sec
    lead_the_charge                = { 103867,  469780, 1 }, -- Divine Steed reduces the cooldown of $s1 nearby ally's major movement ability by $s2 sec. Your movement speed is increased by $s3%
    lightbearer                    = { 103861,  469416, 1 }, -- $s1% of all healing done to you from other sources heals up to $s2 nearby allies, divided evenly among them
    lightforged_blessing           = {  93008,  403479, 1 }, -- Divine Storm heals you and up to $s1 nearby allies for $s2% of maximum health
    lights_countenance             = { 103854,  469325, 1 }, -- The cooldowns of Repentance and Blinding Light are reduced by $s1 sec
    lights_revocation              = { 103863,  146956, 1 }, -- Removing harmful effects with Divine Shield heals you for $s1% for each effect removed. This heal cannot exceed $s2% of your maximum health. Divine Shield may now be cast while Forbearance is active
    obduracy                       = {  81630,  385427, 1 }, -- Speed increased by $s1% and damage taken from area of effect attacks reduced by $s2%
    of_dusk_and_dawn               = {  81624,  385125, 1 }, -- When you cast $s1 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals $s4% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by $s7% For $s8 sec
    punishment                     = {  93165,  403530, 1 }, -- Successfully interrupting an enemy with Rebuke casts an extra Crusader Strike
    quickened_invocation           = {  93181,  379391, 1 }, -- Divine Toll's cooldown is reduced by $s1 sec
    rebuke                         = {  81604,   96231, 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for $s1 sec
    recompense                     = {  81607,  384914, 1 }, -- After your Blessing of Sacrifice ends, $s1% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed $s2% of your maximum health and its bonus healing cannot exceed $s3% of your maximum health
    repentance                     = {  81598,   20066, 1 }, -- Forces an enemy target to meditate, incapacitating them for $s1 min. Damage may cancel the effect. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants
    righteous_protection           = { 103865,  469321, 1 }, -- Blessing of Sacrifice now removes and prevents all Poison and Disease effects
    sacred_strength                = {  81618,  469337, 1 }, -- Holy Power spending abilities have $s1% increased damage and healing
    sacrifice_of_the_just          = {  81607,  384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by $s1 sec
    sanctified_plates              = {  93009,  402964, 2 }, -- Armor increased by $s1%, Stamina increased by $s2% and damage taken from area of effect attacks reduced by $s3%
    seal_of_might                  = {  81621,  385450, 2 }, -- Mastery increased by $s1% and strength increased by $s2%
    seal_of_the_crusader           = {  93683,  416770, 1 }, -- Your auto attacks heal a nearby ally for $s1
    selfless_healer                = { 103856,  469434, 1 }, -- Flash of Light is $s1% more effective on your allies and $s2% of the healing done also heals you
    stand_against_evil             = { 103855,  469317, 1 }, -- Turn Evil now affects $s1 additional enemies
    steed_of_liberty               = {  81631,  469304, 1 }, -- Divine Steed also grants Blessing of Freedom for $s1 sec.  Blessing of Freedom: Blesses a party or raid member, granting immunity to movement impairing effects for $s4 sec
    stoicism                       = { 103862,  469316, 1 }, -- The duration of stun effects on you is reduced by $s1%
    turn_evil                      = {  93010,   10326, 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $s1 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time
    unbound_freedom                = {  93174,  305394, 1 }, -- Blessing of Freedom increases movement speed by $s1%, and you gain Blessing of Freedom when cast on a friendly target
    unbreakable_spirit             = {  81615,  114154, 1 }, -- Reduces the cooldown of your Divine Shield, Shield of Vengeance, Divine Protection, and Lay on Hands by $s1%
    vengeful_wrath                 = { 103849,  406835, 2 }, -- Hammer of Wrath deals $s1% increased damage to enemies below $s2% health
    worthy_sacrifice               = { 103865,  469279, 1 }, -- You automatically cast Blessing of Sacrifice onto an ally within $s1 yds when they are below $s2% health and you are not in a loss of control effect. This effect activates $s3% of Blessing of Sacrifice's cooldown
    wrench_evil                    = { 103855,  460720, 1 }, -- Turn Evil's cast time is reduced by $s1%

    -- Retribution
    adjudication                   = {  81537,  406157, 1 }, -- Critical Strike damage of your abilities increased by $s1% and Hammer of Wrath also has a chance to cast Highlord's Judgment
    aegis_of_protection            = {  81550,  403654, 1 }, -- Divine Protection reduces damage you take by an additional $s1%
    art_of_war                     = {  81523,  406064, 1 }, -- Your auto attacks have a $s1% chance to reset the cooldown of Blade of Justice. Critical strikes increase the chance by an additional $s2%
    avenging_wrath                 = {  81544,   31884, 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage, healing, and critical strike chance by $s1% for $s2 sec
    blade_of_justice               = {  81526,  184575, 1 }, -- Pierce an enemy with a blade of light, dealing $s$s2 Holy damage. Generates $s3 Holy Power
    blade_of_vengeance             = {  81545,  403826, 1 }, -- Blade of Justice now hits nearby enemies for $s$s2 Holy damage. Deals reduced damage beyond $s3 targets
    blades_of_light                = {  93164,  403664, 1 }, -- Crusading Strikes, Judgment, Hammer of Wrath and your damaging single target Holy Power abilities now deal Holystrike damage and your abilities that deal Holystrike damage deal $s1% increased damage
    blessed_champion               = {  81541,  403010, 1 }, -- Crusader Strike and Judgment hit an additional $s1 targets but deal $s2% reduced damage to secondary targets
    boundless_judgment             = {  81533,  405278, 1 }, -- Judgment generates $s1 additional Holy Power and has a $s2% increased chance to trigger Mastery: Highlord's Judgment
    burn_to_ash                    = {  92686,  446663, 1 }, -- When Truth's Wake critically strikes, its duration is extended by $s1 sec. Your other damage over time effects deal $s2% increased damage to targets affected by Truth's Wake
    burning_crusade                = {  81536,  405289, 1 }, -- Divine Storm, Divine Hammer and Consecration now deal Radiant damage and your abilities that deal Radiant damage deal $s1% increased damage
    crusade                        = {  81544,  231895, 1 }, -- Call upon the Light and begin a crusade, increasing your haste and damage by $s1% for $s2 sec. Each Holy Power spent during Crusade increases haste and damage by an additional $s3%. Maximum $s4 stacks. Hammer of Wrath may be cast on any target
    crusading_strikes              = {  93186,  404542, 1 }, -- Crusader Strike replaces your auto-attacks and deals $s$s2 Holystrike damage, but now only generates $s3 Holy Power every $s4 attacks. Inherits Crusader Strike benefits but cannot benefit from Skyfury
    divine_arbiter                 = {  81540,  404306, 1 }, -- Highlord's Judgment and Holystrike damage abilities grant you a stack of Divine Arbiter. At $s3 stacks your next damaging single target Holy Power ability causes $s$s4 Holystrike damage to your primary target and $s$s5 Holystrike damage to enemies within $s6 yds
    divine_auxiliary               = {  81538,  406158, 1 }, -- Final Reckoning and Execution Sentence grant $s1 Holy Power
    divine_hammer                  = {  81516,  198034, 1 }, -- Divine Hammers spin around you, striking enemies nearby for $s$s2 Holy damage every $s3 sec for $s4 sec. While active, each Holy Power spent increases the duration of Divine Hammer by $s5 sec. Deals reduced damage beyond $s6 targets
    divine_storm                   = {  81527,   53385, 1 }, -- Unleashes a whirl of divine energy, dealing $s$s2 Holy damage to all nearby enemies. Deals reduced damage beyond $s3 targets
    divine_wrath                   = {  93160,  406872, 1 }, -- Increases the duration of Avenging Wrath or Crusade by $s1 sec
    empyrean_legacy                = {  93173,  387170, 1 }, -- Judgment empowers your next Single target Holy Power ability to automatically activate Divine Storm with $s1% increased effectiveness. This effect can only occur every $s2 sec
    empyrean_power                 = {  92860,  326732, 1 }, -- Crusading Strikes has a $s1% chance to make your next Divine Storm free and deal $s2% additional damage
    execution_sentence             = {  81539,  343527, 1 }, -- A hammer slowly falls from the sky upon the target, after $s1 sec, they suffer $s2% of the damage taken from your abilities as Holy damage during that time
    executioners_will              = {  81548,  406940, 1 }, -- Final Reckoning and Execution Sentence's durations are increased by $s1 sec
    expurgation                    = {  92689,  383344, 1 }, -- Your Blade of Justice causes the target to burn for $s$s2 Radiant damage over $s3 sec
    final_reckoning                = {  81539,  343721, 1 }, -- Call down a blast of heavenly energy, dealing $s$s2 Holy damage to all targets in the area and causing them to take $s3% increased damage from your single target Holy Power abilities, and $s4% increased damage from other Holy Power abilities for $s5 sec
    final_verdict                  = {  81532,  383328, 1 }, -- Unleashes a powerful weapon strike that deals $s$s2 Holystrike damage to an enemy target, Final Verdict has a $s3% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health
    guided_prayer                  = {  81531,  404357, 1 }, -- When your health is brought below $s1%, you instantly cast a free Word of Glory at $s2% effectiveness on yourself. Cannot occur more than once every $s3 sec
    heart_of_the_crusader          = {  93190,  406154, 2 }, -- Crusader Strike and auto-attacks deal $s1% increased damage and deal $s2% increased critical strike damage
    highlords_wrath                = {  81534,  404512, 1 }, -- Mastery: Highlord's Judgment is $s1% more effective on Judgment and Hammer of Wrath. Judgment applies an additional stack of Greater Judgment if it is known
    holy_blade                     = {  92838,  383342, 1 }, -- Blade of Justice generates $s1 additional Holy Power
    holy_flames                    = {  81545,  406545, 1 }, -- Divine Storm deals $s1% increased damage and when it hits an enemy affected by your Expurgation, it spreads the effect to up to $s2 targets hit. You deal $s3% increased Holy damage to targets burning from your Expurgation
    improved_blade_of_justice      = {  92838,  403745, 1 }, -- Blade of Justice now has $s1 charges
    improved_judgment              = {  81533,  405461, 1 }, -- Judgment now has $s1 charges
    inquisitors_ire                = {  92951,  403975, 1 }, -- Every $s1 sec, gain $s2% increased damage to your next Divine Storm, stacking up to $s3 times
    judge_jury_and_executioner     = {  92860,  405607, 1 }, -- Holy Power generating abilities have a chance to cause your next Final Verdict to hit an additional $s1 targets at $s2% effectiveness
    judgment_of_justice            = {  93161,  403495, 1 }, -- Judgment deals $s1% increased damage and increases your movement speed by $s2% for $s3 sec. If you have Greater Judgment, Judgment slows enemies by $s4% for $s5 sec
    jurisdiction                   = {  81542,  402971, 1 }, -- Final Verdict and Blade of Justice deal $s1% increased damage. The range of Final Verdict and Blade of Justice is increased to $s2 yds
    justicars_vengeance            = {  81532,  215661, 1 }, -- Focuses Holy energy to deliver a powerful weapon strike that deals $s$s2 Holystrike damage, and restores $s3% of your maximum health. Damage is increased by $s4% when used against a stunned target
    light_of_justice               = {  81521,  404436, 1 }, -- Reduces the cooldown of Blade of Justice by $s1 sec
    lights_celerity                = {  81531,  403698, 1 }, -- Flash of Light casts instantly, its healing done is increased by $s1%, but it now has a $s2 sec cooldown
    penitence                      = {  92839,  403026, 1 }, -- Your damage over time effects deal $s1% more damage
    radiant_glory                  = {  81549,  458359, 1 }, -- Crusade is replaced with Radiant Glory. Radiant Glory Wake of Ashes activates Crusade for $s3 sec. Each Holy Power spent has a chance to activate Crusade for $s4 sec
    righteous_cause                = {  81523,  402912, 1 }, -- Each Holy Power spent has a $s1% chance to reset the cooldown of Blade of Justice
    rush_of_light                  = {  81512,  407067, 1 }, -- The critical strikes of your damaging single target Holy Power abilities grant you $s1% Haste for $s2 sec
    sanctify                       = {  92688,  382536, 1 }, -- Enemies hit by Divine Storm take $s1% more damage from Consecration and Divine Hammers for $s2 sec
    searing_light                  = {  81552,  404540, 1 }, -- Highlord's Judgment and Radiant damage abilities have a chance to call down an explosion of Holy Fire dealing $s$s2 Radiant damage to all nearby enemies and leaving a Consecration in its wake. Deals reduced damage beyond $s3 targets
    seething_flames                = {  92854,  405355, 1 }, -- Wake of Ashes deals significantly reduced damage to secondary targets, but now causes you to lash out $s2 extra times for $s$s3 Radiant damage
    shield_of_vengeance            = {  81550,  184662, 1 }, -- Creates a barrier of holy light that absorbs $s1 damage for $s2 sec. When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies
    swift_justice                  = {  81521,  383228, 1 }, -- Reduces the cooldown of Judgment by $s1 sec and Crusader Strike by $s2 sec
    tempest_of_the_lightbringer    = {  92951,  383396, 1 }, -- Divine Storm projects an additional wave of light, striking all enemies up to $s1 yds in front of you for $s2% of Divine Storm's damage
    templar_strikes                = {  93186,  406646, 1 }, -- Crusader Strike becomes a $s3 part combo. Templar Strike slashes an enemy for $s$s4 Holystrike damage and gets replaced by Templar Slash for $s5 sec. Templar Slash strikes an enemy for $s$s6 Holystrike damage, and burns the enemy for $s7% of the damage dealt over $s8 sec
    vanguards_momentum             = {  92688,  383314, 1 }, -- Hammer of Wrath has $s1 extra charge and on enemies below $s2% health generates $s3 additional Holy Power
    wake_of_ashes                  = {  81525,  255937, 1 }, -- Lash out at your enemies, dealing $s$s2 Radiant damage to all enemies within $s3 yds in front of you, and applying Truth's Wake, burning the targets for an additional $s4 damage over $s5 sec. Demon and Undead enemies are also stunned for $s6 sec. Generates $s7 Holy Power
    zealots_fervor                 = {  92952,  403509, 2 }, -- Auto-attack speed increased by $s1%

    -- Herald Of The Sun
    aurora                         = {  95069,  439760, 1 }, -- After you cast Wake of Ashes, gain Divine Purpose.  Divine Purpose Your next Holy Power spending ability is free and deals $s3% increased damage and healing
    blessing_of_anshe              = {  95071,  445200, 1 }, -- Your damage and healing over time effects have a chance to increase the damage of your next Hammer of Wrath by $s1% and make it usable on any target, regardless of their health
    dawnlight                      = {  95099,  431377, 1 }, -- Casting Wake of Ashes causes your next $s2 Holy Power spending abilities to apply Dawnlight on your target, dealing $s$s3 Radiant damage or $s4 healing over $s5 sec. $s6% of Dawnlight's damage and healing radiates to nearby allies or enemies, reduced beyond $s7 targets
    eternal_flame                  = {  95095,  156322, 1 }, -- Heals an ally for $s1 and an additional $s2 over $s3 sec. Healing increased by $s4% when cast on self
    gleaming_rays                  = {  95073,  431480, 1 }, -- While a Dawnlight is active, your Holy Power spenders deal $s1% additional damage or healing
    illumine                       = {  95098,  431423, 1 }, -- Dawnlight reduces the movement speed of enemies by $s1% and increases the movement speed of allies by $s2%
    lingering_radiance             = {  95071,  431407, 1 }, -- Dawnlight leaves an Eternal Flame for $s1 sec on allies or a Greater Judgment on enemies when it expires or is extended
    luminosity                     = {  95080,  431402, 1 }, -- Critical Strike chance of Hammer of Wrath and Divine Storm increased by $s1%
    morning_star                   = {  95073,  431482, 1 }, -- Every $s1 sec, your next Dawnlight's damage or healing is increased by $s2%, stacking up to $s3 times. Morning Star stacks twice as fast while out of combat
    second_sunrise                 = {  95086,  431474, 1 }, -- Divine Storm and Hammer of Wrath have a $s1% chance to cast again at $s2% effectiveness
    solar_grace                    = {  95094,  431404, 1 }, -- Your Haste is increased by $s1% for $s2 sec each time you apply Dawnlight. Multiple stacks may overlap
    sun_sear                       = {  95072,  431413, 1 }, -- Hammer of Wrath and Divine Storm critical strikes cause the target to burn for an additional $s$s2 Radiant damage over $s3 sec
    suns_avatar                    = {  95105,  431425, 1 }, -- During Avenging Wrath, you become linked to your Dawnlights within $s2 yds, causing $s$s3 Radiant damage to enemies or $s4 healing to allies that pass through the beams, reduced beyond $s5 targets. Activating Crusade applies up to $s6 Dawnlights onto nearby allies or enemies and increases Dawnlight's duration by $s7%
    will_of_the_dawn               = {  95098,  431406, 1 }, -- Movement speed increased by $s1% while above $s2% health. When your health is brought below $s3%, your movement speed is increased by $s4% for $s5 sec. Cannot occur more than once every $s6 min

    -- Templar
    bonds_of_fellowship            = {  95181,  432992, 1 }, -- You receive $s1% less damage from Blessing of Sacrifice and each time its target takes damage, you gain $s2% movement speed up to a maximum of $s3%
    endless_wrath                  = {  95185,  432615, 1 }, -- Calling down an Empyrean Hammer has a $s1% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health
    for_whom_the_bell_tolls        = {  95183,  432929, 1 }, -- Divine Toll grants up to $s1% increased damage to your next $s2 Judgment when striking only $s3 enemy. This amount is reduced by $s4% for each additional target struck
    hammerfall                     = {  95184,  432463, 1 }, -- Templar's Verdict, Divine Storm and Divine Hammer calls down an Empyrean Hammer on a nearby enemy. While Shake the Heavens is active, this effect calls down an additional Empyrean Hammer
    higher_calling                 = {  95178,  431687, 1 }, -- Crusader Strike, Hammer of Wrath and Blade of Justice extend the duration of Shake the Heavens by $s1 sec
    lights_deliverance             = {  95182,  425518, 1 }, -- You gain a stack of Light's Deliverance when you call down an Empyrean Hammer. While Wake of Ashes and Hammer of Light are unavailable, you consume $s1 stacks of Light's Deliverance, empowering yourself to cast Hammer of Light an additional time for free
    lights_guidance                = {  95180,  427445, 1 }, -- Wake of Ashes is replaced with Hammer of Light for $s4 sec after it is cast.  Hammer of Light: Hammer down your enemy with the power of the Light, dealing $s$s7 Holy damage and $s$s8 Holy damage up to $s9 nearby enemies. Additionally, calls down Empyrean Hammers from the sky to strike $s10 nearby enemies for $s$s11 Holy damage each. Costs $s12 Holy Power
    sacrosanct_crusade             = {  95179,  431730, 1 }, -- Wake of Ashes surrounds you with a Holy barrier for $s1% of your maximum health. Hammer of Light heals you for $s2% of your maximum health, increased by $s3% for each additional target hit. Any overhealing done with this effect gets converted into a Holy barrier instead
    sanctification                 = {  95185,  432977, 1 }, -- Casting Judgment increases the damage of Empyrean Hammer by $s1% for $s2 sec. Multiple applications may overlap
    shake_the_heavens              = {  95187,  431533, 1 }, -- After casting Hammer of Light, you call down an Empyrean Hammer on a nearby target every $s1 sec, for $s2 sec
    undisputed_ruling              = {  95186,  432626, 1 }, -- Hammer of Light applies Judgment to its targets, and increases your Haste by $s1% for $s2 sec
    unrelenting_charger            = {  95181,  432990, 1 }, -- Divine Steed lasts $s1 sec longer and increases your movement speed by an additional $s2% for the first $s3 sec
    wrathful_descent               = {  95177,  431551, 1 }, -- When Empyrean Hammer critically strikes, $s1% of its damage is dealt to nearby enemies. Enemies hit by this effect deal $s2% reduced damage to you for $s3 sec
    zealous_vindication            = {  95183,  431463, 1 }, -- Hammer of Light instantly calls down $s1 Empyrean Hammers on your target when it is cast
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blessing_of_sanctuary          =  752, -- (210256) Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by $s1% for $s2 sec
    blessing_of_spellwarding       = 5573, -- (204018) Blesses a party or raid member, granting immunity to magical damage and harmful effects for $s1 sec. Cannot be used on a target with Forbearance. Causes Forbearance for $s2 sec. Shares a cooldown with Blessing of Protection
    hallowed_ground                = 5535, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect
    luminescence                   =   81, -- (556606) Lightbearer's healing transfer is increased by up to $s1% based on your current health. Lower health heals allies for more
    searing_glare                  = 5584, -- (410126) Call upon the light to blind enemy players in a $s1 yd cone, causing enemies to miss their spells and attacks for $s2 sec
    shining_revelation             = 5675, -- (936051) The light reveals all enemies in stealth or invisible to you while under the effects of Divine Shield. This effect lingers for $s1 sec after Divine Shield fades
    spellbreaker                   = 5666, -- (469895) Eye for an Eye can now also trigger at $s1% effectiveness from direct Magic damage
    spreading_the_word             = 5572, -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.  Blessing of Protection Physical damage reduced by $s3% for $s4 sec.  Blessing of Freedom Cleared of all movement impairing effects
    ultimate_retribution           =  753, -- (355614)
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
        max_stack = 1,
        dot = "buff",
        shared = "player",
        friendly = true
    },
    divine_arbiter = {
        id = 406975,
        duration = 30,
        max_stack = 25
    },
    divine_hammer = {
        id = 198034,
        duration = 8,
        tick_time = 2,
        max_stack = 1
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
        duration = function () return ( 4 + ( level > 40 and 2 or 0 ) + ( 2 * talent.unrelenting_charger.rank ) + pvptalent.steed_of_glory.rank ) * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) * ( talent.divine_spurs.enabled and 0.6 or 1 ) end,
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
    endless_wrath = {
        id = 452244,
        dutaion = 12,
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
        duration = function() return talent.holy_reprieve.enabled and 20 or 30 end,
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
        id = 427441,
        duration = 20,
        max_stack = function() return 1 + set_bonus.tww3 >=4 and 1 or 0 end
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
        max_stack = 50
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
        duration = 8,
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237619, 237617, 237622, 237620, 237618 },
        auras = {
            -- Herald of the Sun
            solar_wrath= {
                id = 1236972,
                duration = 20,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229244, 229242, 229243, 229245, 229247 },
        auras = {
            winning_streak = {
                id = 1216828,
                duration = 30,
                max_stack = 10
            },
            all_in = {
                id = 1216837,
                duration = 4,
                max_stack = 1
            }
            -- TODO: Incorporate free spends?
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207189, 207190, 207191, 207192, 207194, 217198, 217200, 217196, 217197, 217199 },
        auras = {
            echoes_of_wrath = {
                id = 423590,
                duration = 12,
                max_stack = 1
            }
        }
    },
    tier30 = {
        items = { 202455, 202453, 202452, 202451, 202450 }
    },
    tier29 = {
        items = { 200417, 200419, 200414, 200416, 200418 }
    }
} )

spec:RegisterHook( "prespend", function( amount, resource )
    -- You still need the holy power in order to cast, but it won't be consumed. It does trigger other effects as though it were consumed, though.
    if resource == "holy_power" and buff.all_in.up then
        ns.callHook( "spend", amount, resource )
        return 0, resource
    end
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "holy_power" then
        if buff.blessing_of_dawn.up then
            applyBuff( "blessing_of_dusk" )
            removeBuff( "blessing_of_dawn" )
        end
        if talent.crusade.enabled and buff.crusade.up then
            addStack( "crusade", buff.crusade.remains, amt )
        end
        if legendary.uthers_devotion.enabled then
            reduceCooldown( "blessing_of_freedom", 1 )
            reduceCooldown( "blessing_of_protection", 1 )
            reduceCooldown( "blessing_of_sacrifice", 1 )
            reduceCooldown( "blessing_of_spellwarding", 1 )
        end
        if buff.divine_hammer.up then buff.divine_hammer.expires = buff.divine_hammer.expires + ( amt * 0.3 ) end
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
local freeHOLApplied = 0
local willBeFree = false
local holProcGcdSafe = false


spec:RegisterStateExpr( "hol_is_free", function ()
    return ( query_time - freeHOLApplied ) < 12
end )

spec:RegisterStateExpr( "hol_will_be_free", function ()
    return willBeFree
end )

spec:RegisterStateExpr( "hol_proc_before_gcd", function ()
    return holProcGcdSafe
end )

local empyreanHammerCallers = {
    [198034]    = true,     -- Divine Hammer Initial Cast
    [53385]     = true,     -- Divine Storm
    [383328]    = true,     -- TV
    [336872]    = true,     -- TV variations
    [85256]     = true,     -- TV variations
    [427453]    = true,     -- Hammer of Light
    [198137]    = true,     -- Divine Hammer Tick
}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if spellID == 406834 then -- Crusader Strikes: Energize
            current_crusading_strikes = 0
        elseif spellID == 408385 then
            local now = GetTime()
            if now - last_crusading_strike > 0.5 then -- Crusader Strikes: Swing Damage
                current_crusading_strikes = current_crusading_strikes + 1
                last_crusading_strike = now
                if current_crusading_strikes < 2 then
                    Hekili:ForceUpdate( "CRUSADING_STRIKES", true )
                end
            end
        -- Hammer of Light stuff
        ----
        elseif spellID == 433732 then
            -- This is the event where you actually gain the free cast for 12 seconds, separate from the 20 second cast window
            freeHOLApplied = ( subtype == "SPELL_AURA_APPLIED" ) and GetTime() or 0
            willBeFree = false
            Hekili:ForceUpdate( "HAMMER_OF_LIGHT_FREE_CAST_APPLIED", true )
        elseif subtype == "SPELL_CAST_SUCCESS" and state.talent.lights_deliverance.enabled and empyreanHammerCallers[ spellID ] and state.talent.hammerfall.enabled then
            -- An empyrean hammer (or 2) is on the way, hasn't hit yet
            local wake = GetSpellCooldown( 255937 )
            local ld = GetPlayerAuraBySpellID( 433674 )
            local sth = GetPlayerAuraBySpellID( 431536 )
            local stacks = 1 + ( sth and 1 or 0 )
            local ld_count = ld and ld.applications or 0
            willBeFree = wake.activeCategory == 2285 and ( ld_count + stacks ) >= 50
            if willBeFree then Hekili:ForceUpdate( "HAMMER_OF_LIGHT_50_LD_STACK_SOON", true ) end
        elseif spellID == 433674 and ( subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_APPLIED" ) then
            -- Calculate GCD remains when LD hits 50 stacks
            local ld = GetPlayerAuraBySpellID( 433674 )
            -- Quick exits
            if not ld or ld.applications ~= 50 then
                return
            elseif state.prev_gcd[1].hammer_of_light then
                holProcGcdSafe = true
                return
            end

            local rawGCD = GetSpellCooldown( 61304 )
            local gcdRemains = rawGCD.startTime > 0 and ( rawGCD.startTime + rawGCD.duration ) - GetTime() or 0
            -- if GCD remains is more than 600ms, we are safe to recommend HoL NOW.
            -- If 600ms or less, we are running a high risk of the user being recommended an uncastable spell
            holProcGcdSafe = gcdRemains >= 0.6
            Hekili:ForceUpdate( "HAMMER_OF_LIGHT_50_LD_STACK_NOW", true )
        end
        -- Gets its own block because it's also in empyreanHammerCallers
        if spellID == 427453 and freeHOLApplied > 0 then
            freeHOLApplied = 0
            Hekili:ForceUpdate( "HAMMER_OF_LIGHT_CAST", true )
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
    -- reset to force refresh with real combatlog data
    hol_is_free = nil
    hol_will_be_free = nil
    hol_proc_before_gcd = nil

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

    -- Testfix for 4pc; if this is insufficient then will need to track SPELL_ENERGIZE from CLEU to count Holy Power already regenerated and subtract from the gain amount.
    if buff.all_in.up then
        local last = state.prev_gcd.last
        local last_ability = class.abilities[ last ]

        if last_ability and action[ last ].timeSince < 0.5 then
            local spend, spendType = last_ability.spend
            spendType = not spendType and last_ability.spendType or "mana"
            if spendType == "holy_power" then gain( spend, "holy_power" ) end
        end
    end

    if hol_will_be_free and buff.hammer_of_light.down then
        if hol_proc_before_gcd then
            hol_is_free = true
        end
    end
    if hol_is_free and buff.hammer_of_light_ready.down then
        -- This is the case where we've already seen it in combatlogs
        addStack( "hammer_of_light_ready" )
    end

    -- Debug snapshot for hammer_of_light
    if Hekili.ActiveDebug then
        Hekili:Debug( "Hammer of Light - freeHOLApplied: %.2f, willBeFree: %s, hol_is_free: %s, hol_will_be_free: %s, buff.hammer_of_light_ready.stack: %d, set_bonus.tww3: %d, buff.lights_deliverance.stack: %d, action.wake_of_ashes.time_since: %.2f",
            freeHOLApplied or 0,
            willBeFree and "TRUE" or "FALSE",
            hol_is_free and "TRUE" or "FALSE",
            hol_will_be_free and "TRUE" or "FALSE",
            buff.hammer_of_light_ready.stack or 0,
            set_bonus.tww3 or 0,
            buff.lights_deliverance.stack or 0,
            action.wake_of_ashes.time_since or 0
        )
    end

end )

local DeliverLight = setfenv( function ( incomingStacks )

    if  buff.lights_deliverance.at_max_stacks then return end

    if incomingStacks and incomingStacks > 0 then
        addStack( "lights_deliverance", nil, incomingStacks )
    end

    if buff.lights_deliverance.at_max_stacks and buff.hammer_of_light.down and cooldown.wake_of_ashes.remains > 0 then
        hol_is_free = true
        addStack( "hammer_of_light_ready" )
        removeBuff( "lights_deliverance" )
    end

end, state )

spec:RegisterHook( "runHandler_startCombat", csStartCombat )

spec:RegisterHook( "runHandler", function( a )
    if talent.lights_deliverance.enabled then
        -- This handles the case where we don't think HoL proc will arrive before the GCD is over, so we apply it in the next slot.
        if hol_will_be_free and not hol_proc_before_gcd then
            addStack( "hammer_of_light_ready" )
            hol_is_free = true
            hol_will_be_free = false
            hol_proc_before_gcd = false
        end
    end
end )

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
        cooldown = 60,
        gcd = "off",
        school = "holy",

        notalent = function()
            return talent.radiant_glory.enabled and "radiant_glory" or "crusade"
        end,
        startsCombat = false,
        toggle = "cooldowns",

        usable = function() return talent.avenging_wrath.enabled, "requires avenging_wrath" end,

        handler = function ()
            applyBuff( "avenging_wrath" )
        end,
    },

    -- Talent: Pierces an enemy with a blade of light, dealing $s1 Physical damage.    |cFFFFFFFFGenerates $s2 Holy Power.|r
    blade_of_justice = {
        id = 184575,
        cast = 0,
        cooldown = function() return ( talent.light_of_justice.enabled and 10 or 12 ) * haste end,
        charges = function() if talent.improved_blade_of_justice.enabled then return 2 end end,
        recharge = function() if talent.improved_blade_of_justice.enabled then return ( talent.light_of_justice.enabled and 10 or 12 ) * haste end end,
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
            if buff.shake_the_heavens.up then
                buff.shake_the_heavens.expires = buff.shake_the_heavens.expires + 1
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
            if talent.righteous_protection.enabled then
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_disease" )
            end
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
        cooldown = function() return talent.lights_countenance.enabled and 75 or 90 end,
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

        talent = "auras_of_the_resolute",
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
        cooldown = function () return ( talent.swift_justice.enabled and 4 or 6 ) * haste end,
        recharge = function () return ( talent.swift_justice.enabled and 4 or 6 ) * haste end,
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
            if buff.shake_the_heavens.up then
                buff.shake_the_heavens.expires = buff.shake_the_heavens.expires + 1
            end
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

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        talent = "divine_hammer",
        startsCombat = false,
        texture = 626003,

        handler = function ()
            applyBuff( "divine_hammer" )
            if talent.lights_deliverance.enabled and talent.hammerfall.enabled then
                DeliverLight( 1 + ( buff.shake_the_heavens.up and 1 or 0 ) )
            end
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
        nodebuff = function() if not talent.lights_revocation.enabled then return "forbearance" end end,

        handler = function ()
            applyBuff( "divine_shield" )
            applyDebuff( "player", "forbearance" )
        end,
    },

    -- Talent: Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed = {
        id = 190784,
        cast = 0,
        charges = function () if talent.cavalier.enabled then return 2 end end,
        cooldown = function() return 45 * ( talent.divine_spurs.enabled and 0.8 or 1 ) end,
        recharge = function () if talent.cavalier.enabled then return 45 * ( talent.divine_spurs.enabled and 0.8 or 1 ) end end,
        gcd = "off",
        school = "holy",

        talent = "divine_steed",
        startsCombat = false,

        handler = function ()
            applyBuff( "divine_steed" )
            if talent.steed_of_liberty.enabled then applyBuff( "blessing_of_freedom", 3 ) end
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
            return ( talent.vanguard_of_justice.enabled and 4 or 3 )
        end,
        spendType = "holy_power",

        talent = "divine_storm",
        startsCombat = true,

        handler = function ()
            --Standard effects / talents
            removeDebuffStack( "target", "judgment" )

            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end

            if buff.empyrean_power.up then
                removeBuff( "empyrean_power" )
            elseif buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            end

            if talent.holy_flames.enabled and debuff.expurgation.up and active_enemies > active_dot.expurgation then
                active_dot.expurgation = min( active_enemies, active_dot.expurgation + 4 )
            end

            if talent.sanctify.enabled then
                applyDebuff( "target", "sanctify" )
                active_dot.sanctify = active_enemies
            end

            -- Hero Talents
            if talent.lights_deliverance.enabled and talent.hammerfall.enabled then
                DeliverLight( 1 + ( buff.shake_the_heavens.up and 1 or 0 ) )
            end
            -- Legacy
            removeBuff( "echoes_of_wrath" )
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
        cooldown = function() return 45 - ( 15 * talent.fist_of_justice.rank ) end,
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
        known = 255937,
        flash = 255937,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = function()
            if buff.divine_purpose.up or hol_is_free then return 0 end
            return 5
        end,
        spendType = "holy_power",

        startsCombat = true,
        buff = "hammer_of_light_ready",

        handler = function ()

            if hol_is_free then
                hol_is_free = false
            else
                removeBuff( "divine_purpose" ) -- Confirmed it does not consume Divine Purpose when its already free
            end

            if talent.undisputed_ruling.enabled then
                applyDebuff( "target", "judgment" )
                applyBuff( "undisputed_ruling" )
            end

            removeStack( "hammer_of_light_ready" ) -- do this first or else that function misbehaves
            if talent.lights_deliverance.enabled then
                DeliverLight( 3 + ( 2 * talent.zealous_vindication.rank ) )
            end
        end,

        bind = { "wake_of_ashes", "eye_of_tyr" }
    },

    --[[hammer_of_reckoning = {
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
    },--]]

    -- Talent: Hurls a divine hammer that strikes an enemy for $<damage> Holy damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].    |cFFFFFFFFGenerates $s2 Holy Power.
    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        charges = function() if talent.vanguards_momentum.enabled then return 2 end end,
        cooldown = 7.5,
        recharge = function() if talent.vanguards_momentum.enabled then return 7.5 end end,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = function() return ( talent.vanguards_momentum.enabled and target.health_pct < 20 and -2 ) or -1 end,
        spendType = "holy_power",

        talent = "hammer_of_wrath",
        startsCombat = false,

        usable = function () return target.health_pct < 20 or buff.avenging_wrath.up or buff.crusade.up or buff.endless_wrath.up or buff.final_verdict.up or buff.blessing_of_anshe.up or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires buff/talent or target under 20% health" end,
        handler = function ()
            removeBuff( "final_verdict" )
            removeBuff( "endless_wrath" )
            if buff.divine_arbiter.stack > 24 then removeBuff( "divine_arbiter" ) end

            if buff.shake_the_heavens.up then
                buff.shake_the_heavens.expires = buff.shake_the_heavens.expires + 1
            end
            -- Legacy
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
        cooldown = function() return ( talent.swift_justice.enabled and 10 or 12 ) * haste end,
        recharge = function() if talent.improved_judgment.enabled then return ( talent.swift_justice.enabled and 10 or 12 ) * haste end end,
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
            return ( talent.vanguard_of_justice.enabled and 4 or 3 )
        end,
        spendType = "holy_power",

        talent = "justicars_vengeance",
        startsCombat = true,

        handler = function ()
            removeBuff( "empyrean_legacy" )
            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end
            removeBuff( "divine_purpose" )

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

            if talent.empyreal_ward.enabled then applyBuff( "empyreal_ward" ) end
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
            if talent.truths_wake.enabled or conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,
    }, ]]

    -- Talent: Forces an enemy target to meditate, incapacitating them for $d.    Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = function() return talent.lights_countenance.enabled and 0 or 15 end,
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
            return ( talent.vanguard_of_justice.enabled and 4 or 3 )
        end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeBuff( "divine_purpose" )
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
        cooldown = 6,
        recharge = 6,
        hasteCD = true,
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
            return 3
        end,
        spendType = "holy_power",
        notalent = "justicars_vengeance",

        startsCombat = true,

        handler = function ()

            -- Standard effects and talents
            if buff.divine_arbiter.stack > 24 then removeBuff( "divine_arbiter" ) end
            removeDebuffStack( "target", "judgment" )
            if buff.empyrean_legacy.up then
                spec.abilities.divine_storm.handler() -- TODO: Check for resource gain?
                removeBuff( "empyrean_legacy" )
            end

            if buff.dawnlight.up then
                applyBuff( "dawnlight_dot" )
                removeStack( "dawnlight" )
            end

            removeBuff( "divine_purpose" )

            -- Hero Talents
            if talent.lights_deliverance.enabled and talent.hammerfall.enabled then
                DeliverLight( 1 + ( buff.shake_the_heavens.up and 1 or 0 ) )
            end

            -- Legacy
            removeBuff( "echoes_of_wrath" )
            removeStack( "vanquishers_hammer" )

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
        nobuff = "hammer_of_light_ready",
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
            if talent.lights_guidance.enabled then applyBuff( "hammer_of_light_ready", nil, 1 + set_bonus.tww3 >=4 and 1 or 0 ) end
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
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            spend( 0.15 * mana.max, "mana" )
            removeBuff( "recompense" )
            removeBuff( "divine_purpose" )
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

    potion = "tempered_potion",

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

spec:RegisterPack( "Retribution", 20250818, [[Hekili:T31EVTnYr8plghIIvoBzrAjhLulvCnTf9cccouDf3FuujUsCLeVqrQsszhdiWp7D2Lp3LZUKsI29asWDiXMC4mZ(BEUpiZmJz)6SP2Ki6SpB23Cy)rgVRx)r9VB4DZMg90o6SP7il)czn8dEKTWF(pPrbol2h547XU3tU(eBgpc93hSeU)SPl274g9ZEZwGX4Bhya0UJUC2NFB)zt34yBttiLgUC20RVo26x3qJT(nsa8horBC8ITMsjH(WFFB8hz866(JU2y07JT(PF5tWnFYBz8hJ)O(h1m7rV9AJ(WJo1z7hIT(x7yAy2TmV2KX1F93(TYpN1(cIgap81MVdi6VTALZshQ3YNIT8xfB93D8Cc3qdcJTUCLZxP2DtFG(VlHRjcmHx)PyR)HpO6aH)5cYm6FvSfJCtjYZizucN(7oFn95jE250yTkWFB6Zvq)GC6jB3sds01p5SEtugrV9AZBFFvKdSTb(RCCbl6p8dXwBII2f((BUznCZ9l6T0F7nHoB37sy(bldiRIy)(YBw46V4MOn0hjbpY5Zn)0sgj)sGJFGt0tFYjmk8gB6kYE3OB2rCj2oEZdk8P6Xyt8hzYCAUa(ataXwFWF7wNOeloOY2lUJE7Ybje)xbmaUwH7bZLGDJ)90NcCw9FITa3Ja6kAayZOGvkYp2c8dDDNhrcwtJc7z78GJhDEyKFWwgT7CjlPaaZgiawdJJhOZPE0ToWZdCNWhzH92fqb8ybj6hhFt4ghQR9C)vZFG6TMsazHt4dKahYcx6vSOQXWW37l0O5gZxSF1QWREG4Up)Q9m6THeYVtVWiq)xhT5WbKBULegrdEc9EpaUMaw6c2a07VH9SO3zjy3oMXGj6yWu3yWuZyWSMXGPYXG5PpgmMhc(yx5VBCinYzv6yXi5VNtDdPJ73B4vl99SDy8CCgB6jzj7CzbIU03312)rVE27d4U1V6v5xAzW(qInn)wJ7F4GYB(QxPHPSNSzYKWCrD8wp)r4wBWfTcAQrd6EmyT5zJ1MYyT5ZbwJW0YyTEz2kynQgCuy9U00WYOTzz02OewFHshBvwHdhuBF0AGkUhu5zzpI3tZT3fMF)UV5sJEd)rn5takqenZ5QB3jxQnqS4Enr2i5JXKTrQSlvRammb0f7)cT8vwsGIqj)6CxO(yIjltjdRN01qrjqr9deklLZa4525ZU2voRgZ1AjpT97oCinnzIZp7c2u(LOFLUKxyEEi1lIv7mHC)WWoRy9rafV3sC8cV)2(jfCXKVJ3d(FbCV(kKB3J4YXUeDFN)J0G5oER2h2MAiom4Yu4W5)(E71BbAzstSfajcMm28WHlcio2ZPGcf1JyBhccK1eZHdYx3XBYBhw9YQuMvoGRGRVV9rmO7i87HrqR5Jn6FkqX(q6CNi62RcD9JYYpyWuLlVexz6OkrvQdWKb9BO(2TZfrexgafaT)r8IMV21NxZh5QDUmJ4QJUcv6rc4EbDDrGEWdZ0OX1GmD7YyUqcLmgIMxpLTiz4YYRo2OB5QVOjtMmwiUPdlu6iSrMFdBJmuyJmokBKz3Yw32YgXZMTGggb0dMRWV1mthHlmpnJ6olW6si3Sw9XY774czeRstDzWRz)mQpEtJz)JzOAIpuR0XkMhSse6)7dvKz5YgNcXmtmgQZFd0kT(tDsu605KVHV6fklMvLf8OVMJsgdLI3kkTwdiDF)ESI(1bLmbGfscz3247(0CEBqtgpOtKZw69aXLV6T8RobUQaXqVjjudmjL3PWfz)xHzjtuLhGLtTOhybeotFZWdz8hmBIIk5oCnG1cvpMgnpYFUTdDYOovS)Wm4N)OJRltXQqVHz3AsdD)6L24UaI4o38FmaRaU2rbAwc1qCAlLPmNSvoSUDHPL9fFpq5kOHxwRANI4WIQWWuNv2GTS(pu7yvvZOckQk8Bekphpsgapd)rvbqytspR8CLiDSO5jSYLQkmQQ)7uQtzud8ornSQMXatciZIyq)2paT8mdxLTw1vwNaBO7kcGwSlKSYaxkUUNGn)Wb5lLhWav)2bDaXaMOn058ztTaQDTMgu0NY(Wnmc43mDqap2tbqzKehiHrrIJ5d0aBNLrnqozfoYzPlDnz5tSS)xCzzeJeSaQwhK3zL0LtCzmh0fh2sq18Xr(u4KUoerrSFsTzrPrSgRVrFC1sGAERh1uff5H5R)n7zZB)OKxrwOM6XjUbTwh6J0DUO1I0qt1zhMarLV52M0p99SKmOjOWbSFFp0T)scustOnOxwvRJEdslJ74ablE0nbh4XPFBIcIPstVJD6sTMVDi7PLtfxS0DnKbRiUHufpp(QdMRIxfcZJyz0ydPQ7Jf6uak1xglcOH(EK8L9JxMeKIJhpOwF9qfQzQ3Y8qxG68mN5xfuYViwt9nMk40cxW1Gj2KirE03f2(S(n3TpynFQ8qRul)cuAiR2bFKUYfqMWoYofr(UU1O8cdub)801oC9EhBcFcoO9ukrvd685onro3PCwf6M5vd6IDYaSwrVFujol1Yy9D9ozWX0Be0helAVAltDvyzkzdf7i(EwdPTGCR3uzmuJTs1uapCqCD0hPAa2SW75cl4qEseP5imOXPBvKyuUhWbTvWENkDxEeb)k7mnN4hQUT8cCTOcsXejf569MfLfaiomKApFj8y7aM1nbf5xM5EWsu4b4Vqpx44dhjuqu2(r0qK4S8FglT6CzEqpp4vDOcZRr1WjXvTgOts)uqfjyjHN7iiauZztzN0aGQ8JU0OztFKeWsMfoBk)OY4SDNFquS1k)GyRxNVZRVMDWr(V7DcyhCKq)TaLK9r(BjrSladBW7lSx8h)eeofBXoOpFW3dKg)2VwZgm(6KtSsojr40CPXx72ISNTMMm6oboNEqo0P3fK0Um)m06shXeDAUizTVqoJra)qWOt3ZiOnz8zOVSJMJo1n9(TiBvPS3QGRih1GkCgNMwM9NHIRkGbLK2L5NHwRlqrjzTVqoJraEqdcbTjJpd9fnSP69Br2QszhOmgVywBP7wlsCognpRS)zJXFxV)MqV93rtOie6T0d4s9Bpog)p)J5igxlFohRrQTYbDexh6MbWNi0CIiZzbm1nMBeUuhSK7tnuzM46DwXPriwOTz)ZgJ)UE)nHExFoZkNZgm(3c5mR5SHxJupNCd1OdQZz2mO5erMZcyQBm3iCPoyj3N6Uw2zvkwOTzFdym6jAeH5QORH6FtfdZnB(XZ(MoPyTZ5(8zVQPNOIZNAFHpZSVbmUz2t101q9VPI5KCBA(kBEsUnnN9n0TPsfSNP33g08SQIrLEBxKceA4BzdA3WQmVYs0OwjM9U1Kb)VG42nV442npd4g4rY3hJv(UU(pcfqzBurab8dFKgaxhyIDIpzeJSKDnj2ITVrXwl2hLrNNpFtq27jqTTnJyBsezbjK((4pYF9BtElmtfS4gOKnMdF9rTbkQMDU4lZHIu7LUDJMYF1JJUUk2fK8mY8AzBZZ32O06NVy0Mwx1ehm0BoRC7gY0ArCusEgzETST5DD1iZ55lgTMZ32Q(6pRmpNTJAvdQKo3UmVhlx6pZtJY42qXS0SKKZMc5o34hmBk7ZcXSP8RZ)GFK8bya(XpZ)aGK8GZMM8YPoBk1Jv1WE2Fzw0SpBYOO4k5elFEcs4)8Kpti5j0zC42tHdfBqpWIi23JI09yVIwJ86OuZqWFh8u0OcwKvOK9tU7H)srn1yRdhatZl6n5AxkOKssw3nyG7rm2m1PeVi3eBSzwm2gGp2CwHp6QIsSUDa)Sa2z62HuqTCBIXwDGyvbtqL2WITEf0bs2vLxZJyRXXw9tgSAi6v1jJcU0CDrXIGGQskPTHAw3u3i(3kGzt73ByUFLbZKn88mzM1BYmvyYq6vV1nzOYaXKvRU06MmnAwDMS7optw2lwBzJ2fXwAd1uBuzJ86m51A1VrGaHMua4i26nCEaZDk26h1K4kNsfZCJtb8)tQOvObq3iqqJ1k5sfQ1kJsALOn3i3IBMunTu11SYPhvne(5qVS3q25eeRCBHFbO1fhdvU)5WetU0vhWn1SXl2brp5r43n)WOZh1Dkf1GEK0HHve7uoYgYnRnK8ZhjwT2IbgxzuCSwJTUp2A9s7EBjFLB7mlKTWjDeRKNqmLIZ2oFGx98T3lLnI4cYzDVqDKpkPyz0fSMxKlyPt2EHWLnVtgZ)SQ1P(NSBwaVQuH5amebENIe5i0GDmSrKAXyd5GYlm8YfQ6tupx(dYKV8jRN7Imcv2YNMECbR4m3Nj1Y8f)KWNWVQNgEohm6JFBEyxH3JqihwLLcxNYoe3N7q88OGhJxKXWg4gLrKE)igfchT)CJCbIvkyKHxVTr41KX5Es80ofhI)ISMchKFUGZGOYjvlEJa53s8GBNkiD5jZFLdeR4NxlqzI0rTqI0o4kSUKRVtPyr5u5KuvFdcYS06ZEA0xx6tzXEpxQmBXfLKS4HMxotfhXwG8khuOysNcEUEjmfAraxA2ZgMLjn7LrqMOBltufKqIyTv5q8JoRQ2gARGDMMa9G8DOGm3DucrEBzkLE3gKPDuzALfReTVRmTYVNdLjnQmQDs9eIaMSWOBvNCrictZB1TqNmfMLGYVl5IjE5bfvEnKLTRcVD5cc5y0PUzQLOqZFZZZU9LIjFlEd0R0SRWBHoVKJ5G0E6Z63U0lLT(wU58v1lgRmGiwxOkIIx3qU3sXxU20c0yESCLrFJ1xOqYvQHMCh9TqNNzPe6vQXJgavQ8RQ2KHcSOgOSwtbshIz16X7meRbMYtg52tUtIAAJUIfI)Lf4iMrXFqhxcr7Q9wEHChkxyUYNJa99G)DW(0bB5p5byDVxFft2NdaflIsu59qbPCSuc(kF7Auyqyxu7xlYKhJ99UJbQvN)YTLsKN8zfvF5hTFGnZ7cif(pHz(92H43UCfcjP2GvYPPWPc)7Xf(36a7cnm)Jbkw9RCFUKL5ZqkgoRTceDUtZM07G(N0WRRC7yQNhSEkoMLBPtDlXx5LqxVNExPQPIldCMushaiR3SqELklgB2YINaxCrjWOkRamluqkERtsOief56hvYbaPgQKtI53DsEEDsm05KuD36BItIzvNKkBErJDsmXQ9Np98IVtPF3pP98tY(3iLYWlsFb6YNFrnBC2Lnivegpe2FTlWToA72ZSV4ZE6oiMjBjz1uAYlkOUuAAhJDuUzC1Itg)XgNm1VkMszgsxQ6JjIiv1R1xVux5QNzo2bZP2Le9ua9SfKVMEXQf1H(BzFpxBi1nENaYlGGSk(Wny7dex2i7fA6cOLt1KCQqyxAJ0L5xUOfNzt(xKZJjZA3Jyzok0tuFKChTgUyhy7y2e(MP0b1Zo77mR8WdLlgMXnAZJlV9dfo5vJrkwEDv(4TPFG2TwvT5wYmQBJlroskk3UX0tCsS2DCmZ(RYE0xyQ2IHFfBibk4kJgdpjKTYkXxSdhNOjDude8yLKz(ChfRlfNQtiv5gqvK3wvo5jfn9vVc3rBxPLE(klH1rfrxRxRUfJittuSifd6)YN6S8IlieSYxCPK)B2)l]] )
