-- PaladinRetribution.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 70 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.HolyPower )

spec:RegisterTalents( {
    -- Paladin Talents
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- [317920] Interrupt and Silence effects on party and raid members within $a1 yds are $s1% shorter. $?a339124[Fear effects are also reduced.][]
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light and become an avatar of retribution, increasing your damage and healing done by $s1% for $31884d, and allowing Hammer of Wrath to be cast on any target.; Combines with other Avenging Wrath abilities, granting all known Avenging Wrath effects while active.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[; Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.; Last $d, or until transferred damage would cause you to fall below $s3% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within $105421A1 yds, causing them to wander disoriented for $105421d.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has ${1+$m1} charges.
    crusader_aura                   = { 81601, 32223 , 1 }, -- Increases mounted speed by $s1% for all party and raid members within $a1 yds.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[; After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[; Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[; Generates $s5 Holy Power per target hit.][]
    fading_light                    = { 81623, 405768, 1 }, -- $@spellicon385127$@spellname385127:; Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional $s1%.; $@spellicon385126$@spellname385126:; Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for $s2% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- [379017] $?c2[Shield of the Righteous][Word of Glory] grants $s1% bonus armor for $d.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by $s1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and $s2 allies within it for $<points> every $26573t1 sec.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for $<damage> $?s403664[Holystrike][Holy] damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].; Generates $s2 Holy Power.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by $s2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection$?c2[ and Blessing of Spellwarding][] by ${-$s1/1000} sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a $s1% chance to cause your $?s198034[Divine Hammer][Consecration] to flare up, dealing $385816s1 Holy damage to up to $s1 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next $196941N successful attacks against the target to heal the attacker for $183811s1. $@switch<$s2>[][This effect can only occur once every $s1 sec on each target.]
    justification                   = { 81509, 377043, 1 }, -- Judgment's damage is increased by $s1%.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to $s2% your maximum health.$?a387791[; Grants the target $387792s1% increased armor for $387792d.][]; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.
    obduracy                        = { 81630, 385427, 1 }, -- Speed increased by $s3% and damage taken from area of effect attacks reduced by $s2%.
    punishment                      = { 93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke$?s31935[ or Avenger's Shield][] casts an extra $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike].
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for $d.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, $s1% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing.; This effect's bonus damage cannot exceed $s3% of your maximum health and its bonus healing cannot exceed $s4% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for $d.; Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by ${$m1/-1000} sec.
    sanctified_plates               = { 93009, 402964, 2 }, -- Armor increased by $s3%, Stamina increased by $s1% and damage taken from area of effect attacks reduced by $s2%.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by $s1% and Judgment cooldown reduced by ${$abs($s2)/1000}.1 sec.
    seal_of_mercy                   = { 81611, 384897, 1 }, -- Golden Path strikes the lowest health ally within it an additional time for $s1% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- Mastery increased by $s2% and $?c1[intellect][strength] increased by $s1%.
    seal_of_order                   = { 81623, 385129, 1 }, -- $@spellicon385127$@spellname385127:; Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional $s3%.; $@spellicon385126$@spellname385126:; Blessing of Dusk increases your armor by $s2% and your Holy Power generating abilities cooldown $s1% faster.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by ${$s1/1000} sec.
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your $?s2812[Denounce][Shield of the Righteous] and Word of Glory have $s1% increased initial damage and healing.
    touch_of_light                  = { 81543, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing $385354s1 Holy damage or healing an ally for $385352s1 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, $?s184662[Shield of Vengeance, ][]$?s31850[Ardent Defender][Divine Protection], and Lay on Hands by $s1%.

    -- Retribution Talents
    adjudication                    = { 81537, 406157, 1 }, -- Critical Strike damage of your abilities increased by $s1% and Hammer of Wrath also has a chance to cast Highlord's Judgment.
    aegis_of_protection             = { 81550, 403654, 1 }, -- Divine Protection reduces damage you take by an additional $s1%.
    afterimage                      = { 93189, 385414, 1 }, -- After you spend $s3 Holy Power, your next Word of Glory echoes onto a nearby ally at $s1% effectiveness.
    art_of_war                      = { 81523, 406064, 1 }, -- Your auto attacks have a $s1% chance to reset the cooldown of Blade of Justice.; Critical strikes increase the chance by an additional 10%.
    aurora                          = { 95069, 439760, 1 }, -- [223819] Your next Holy Power ability is free and deals $s2% increased damage and healing.
    avenging_wrath_might            = { 81544, 31884 , 1 }, -- Call upon the Light and become an avatar of retribution, increasing your critical strike chance by $s1% for $31884d.; Combines with other Avenging Wrath abilities.
    blade_of_justice                = { 81526, 184575, 1 }, -- $?s403826[Pierce enemies][Pierce an enemy] with a blade of light, dealing $s1 Holy damage$?s403826[ to your target and $404358s1 Holy damage to nearby enemies.][.]; Generates $s2 Holy Power.
    blade_of_vengeance              = { 81545, 403826, 1 }, -- Blade of Justice now hits nearby enemies for $404358s1 Holy damage. ; Deals reduced damage beyond 5 targets.
    blades_of_light                 = { 93164, 403664, 1 }, -- $?s406646[Templar Strikes, ]?s404542[Crusading Strikes, ][Crusader Strike, ]Judgment, Hammer of Wrath and your damaging single target Holy Power abilities now deal Holystrike damage and your abilities that deal Holystrike damage deal $s2% increased damage.
    blessed_champion                = { 81541, 403010, 1 }, -- Crusader Strike and Judgment hit an additional $s4 targets but deal $s3% reduced damage to secondary targets.
    blessing_of_anshe               = { 95071, 445200, 1 }, -- Your damage and healing over time effects have a chance to increase the $?c1[healing or damage of your next Holy Shock by $445204s1%.]?c3[damage of your next Hammer of Wrath by $445206s1% and make it usable on any target, regardless of their health.][]
    bonds_of_fellowship             = { 95181, 432992, 1 }, -- You receive 20% less damage from Blessing of Sacrifice and each time its target takes damage, you gain 4% movement speed up to a maximum of 40%.
    boundless_judgment              = { 81533, 405278, 1 }, -- Judgment generates $s1 additional Holy Power and has a $s3% increased chance to trigger Mastery: Highlord's Judgment.
    burn_to_ash                     = { 92686, 446663, 1 }, -- When Truth's Wake critically strikes, its duration is extended by $s1 sec.; Your other damage over time effects deal $s2% increased damage to targets affected by Truth's Wake. 
    burning_crusade                 = { 81536, 405289, 1 }, -- Divine Storm, Divine Hammer and Consecration now deal Radiant damage and your abilities that deal Radiant damage deal $s2% increased damage.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_ground              = { 81512, 204054, 1 }, -- Your Consecration is $s1% larger, and enemies within it have $s2% reduced movement speed.$?c3[; Your Divine Hammer is $s4% larger, and enemies within them have ${$198137s3*-1}% reduced movement speed.][]
    crusade                         = { 81544, 384392, 1 }, -- Call upon the Light and begin a crusade, increasing your haste $?s384376[and damage ][]by $s1% for $231895d.; Each Holy Power spent during Crusade increases haste by an additional $s1%.; Maximum $231895u stacks.; If $@spellname31884 is known, also grants $s1% damage per stack.; 
    crusading_strikes               = { 93186, 404542, 1 }, -- Crusader Strike replaces your auto-attacks and deals $408385s1 $?s403664[Holystrike][Physical] damage, but now only generates $s4 Holy Power every $s3 attacks.; Inherits Crusader Strike benefits but cannot benefit from Windfury.
    dawnlight                       = { 95099, 431377, 1 }, -- Casting $?c1[Holy Prism or Barrier of Faith]?c3[Wake of Ashes][] causes your next $431522u Holy Power spending abilities to apply Dawnlight on your target, dealing $431380o1 Radiant damage or $431381o1 healing over $431380d.; $431581s1% of Dawnlight's damage and healing radiates to nearby allies or enemies, reduced beyond $431581s2 targets.
    divine_arbiter                  = { 81540, 404306, 1 }, -- Highlord's Judgment and Holystrike damage abilities grant you a stack of Divine Arbiter.; At $s3 stacks your next damaging single target Holy Power ability causes $406983s1 Holystrike damage to your primary target and $406983s2 Holystrike damage to enemies within 6 yds.
    divine_auxiliary                = { 81538, 406158, 1 }, -- Final Reckoning and Execution Sentence grant $408386s1 Holy Power.
    divine_hammer                   = { 81516, 198034, 1 }, -- Divine Hammers spin around you, consuming a Holy Power to strike enemies within $198137A1 yds for $?s405289[${$198137sw1*1.05} Radiant][$198137sw1 Holy] damage every $t sec. ; While active your Judgment, Blade of Justice$?a404542[][ and Crusader Strike] recharge $s2% faster, and increase the rate at which Divine Hammer strikes by $s1% when they are cast. Deals reduced damage beyond 8 targets.
    divine_purpose                  = { 81618, 408459, 1 }, -- Holy Power spending abilities have a $s1% chance to make your next Holy Power spending ability free and deal $408458s2% increased damage and healing.
    divine_resonance                = { 93181, 384027, 1 }, -- [384028] After casting Divine Toll, you instantly cast $?c2[Avenger's Shield]?c1[Holy Shock][Judgment] every $384029t1 sec for $384029s2 sec.
    divine_storm                    = { 81527, 53385 , 1 }, -- Unleashes a whirl of divine energy, dealing $?s405289[${$s1*1.05} Radiant][$s1 Holy] damage to all nearby enemies. ; Deals reduced damage beyond $s2 targets.
    divine_wrath                    = { 93160, 406872, 1 }, -- Increases the duration of Avenging Wrath or Crusade by ${$s1/1000} sec.
    empyrean_legacy                 = { 93173, 387170, 1 }, -- Judgment empowers your next $?c3[Single target Holy Power ability to automatically activate Divine Storm][Word of Glory to automatically activate Light of Dawn] with $s2% increased effectiveness.; This effect can only occur every $387441d.
    empyrean_power                  = { 92860, 326732, 1 }, -- $?s404542[Crusading Strikes has a $s2%][Crusader Strike has a $s1%] chance to make your next Divine Storm free and deal $326733s1% additional damage.
    endless_wrath                   = { 95185, 432615, 1 }, -- Calling down an Empyrean Hammer has a $s1% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    eternal_flame                   = { 95095, 156322, 1 }, -- Heals an ally for $s2 and an additional $o1 over $d.; Healing increased by $s3% when cast on self.
    execution_sentence              = { 81539, 343527, 1 }, -- A hammer slowly falls from the sky upon the target, after $d, they suffer $s2% of the damage taken from your abilities as Holy damage during that time.; $?s406158 [Generates $406158s1 Holy Power.][]
    executioners_will               = { 81548, 406940, 1 }, -- Final Reckoning and Execution Sentence's durations are increased by ${$s1/1000} sec. 
    expurgation                     = { 92689, 383344, 1 }, -- Your Blade of Justice causes the target to burn for $383346o1 $?s403665[Holy][Radiant] damage over $383346d.
    final_reckoning                 = { 81539, 343721, 1 }, -- Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the area and causing them to take $s3% increased damage from your single target Holy Power abilities, and $s4% increased damage from other Holy Power abilities for $d.; $?s406158 [Generates $406158s1 Holy Power.][]
    final_verdict                   = { 81532, 383328, 1 }, -- Unleashes a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage to an enemy target,; Final Verdict has a $s2% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    for_whom_the_bell_tolls         = { 95183, 432929, 1 }, -- Divine Toll grants up to $433618s1% increased damage to your next $s2 Judgment when striking only $s3 enemy. This amount is reduced by $433618s4% for each additional target struck.
    gleaming_rays                   = { 95073, 431480, 1 }, -- While a Dawnlight is active, your Holy Power spenders deal $431481s1% additional damage or healing.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take $s1% increased damage from your next Holy Power ability.; Multiple applications may overlap.
    guided_prayer                   = { 81531, 404357, 1 }, -- When your health is brought below $s1%, you instantly cast a free Word of Glory at $s2% effectiveness on yourself.; Cannot occur more than once every $proccooldown sec.
    hammerfall                      = { 95184, 432463, 1 }, -- $?a137028[Shield of the Righteous and Word of Glory]?s198034[Templar's Verdict, Divine Storm and Divine Hammer][Templar's Verdict and Divine Storm] calls down an Empyrean Hammer on a nearby enemy.; While Shake the Heavens is active, this effect calls down an additional Empyrean Hammer.
    healing_hands                   = { 93189, 326734, 1 }, -- The cooldown of Lay on Hands is reduced up to $s1%, based on the target's missing health.; Word of Glory's healing is increased by up to $m3%, based on the target's missing health.
    heart_of_the_crusader           = { 93190, 406154, 2 }, -- Crusader Strike and auto-attacks deal $s3% increased damage and deal $s4% increased critical strike damage.; 
    higher_calling                  = { 95178, 431687, 1 }, -- $?a137028[Crusader Strike, Hammer of Wrath and Judgment][Crusader Strike, Hammer of Wrath and Blade of Justice] extend the duration of Shake the Heavens by $s1 sec.
    highlords_wrath                 = { 81534, 404512, 1 }, -- Mastery: Highlord's Judgment is ${$s3/2}% more effective on Judgment and Hammer of Wrath. Judgment applies an additional stack of Greater Judgment if it is known.
    holy_blade                      = { 92838, 383342, 1 }, -- Blade of Justice generates $s1 additional Holy Power.
    holy_flames                     = { 81545, 406545, 1 }, -- Divine Storm deals $s1% increased damage and when it hits an enemy affected by your Expurgation, it spreads the effect to up to $s3 targets hit.; You deal $s2% increased Holy damage to targets burning from your Expurgation.
    illumine                        = { 95098, 431423, 1 }, -- Dawnlight reduces the movement speed of enemies by $431380s3% and increases the movement speed of allies by $431381s3%.
    improved_blade_of_justice       = { 92838, 403745, 1 }, -- Blade of Justice now has ${$s1+1} charges.
    improved_judgment               = { 81533, 405461, 1 }, -- Judgment now has ${$s1+1} charges.
    inquisitors_ire                 = { 92951, 403975, 1 }, -- Every $t1 sec, gain $403976s1% increased damage to your next Divine Storm, stacking up to $403976u times.
    judge_jury_and_executioner      = { 92860, 405607, 1 }, -- Holy Power generating abilities have a chance to cause your next $?s383328[Final Verdict]?s215661[Justicar's Vengeance][Templar's Verdict] to hit an additional $s2 targets at $s3% effectiveness.
    judgment_of_justice             = { 93161, 403495, 1 }, -- Judgment deals $s2% increased damage and increases your movement speed by $20271s2% for $20271d.; If you have Greater Judgment, Judgment slows enemies by $408383s1% for $408383d.
    jurisdiction                    = { 81542, 402971, 1 }, -- $?s383328[Final Verdict]?s215661[Justicar's Vengeance][Templar's Verdict] and Blade of Justice deal $s4% increased damage.; The range of $?s383328[Final Verdict and ][]Blade of Justice is increased to $s3 yds.
    justicars_vengeance             = { 81532, 215661, 1 }, -- Focuses Holy energy to deliver a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage, and restores $408394s1% of your maximum health.; Damage is increased by $s2% when used against a stunned target.
    light_of_justice                = { 81521, 404436, 1 }, -- Reduces the cooldown of Blade of Justice by ${$s1/-1000} sec.
    lightforged_blessing            = { 93008, 403479, 1 }, -- Divine Storm heals you and up to $s2 nearby allies for ${$407467s1}.1% of maximum health.
    lights_celerity                 = { 81531, 403698, 1 }, -- Flash of Light casts instantly, its healing done is increased by $s3%, but it now has a ${$s1/1000} sec cooldown.
    lights_deliverance              = { 95182, 425518, 1 }, -- You gain a stack of Light's Deliverance when you call down an Empyrean Hammer.; While $?a137028[Eye of Tyr][Wake of Ashes] and Hammer of Light are unavailable, you consume $433674U stacks of Light's Deliverance, empowering yourself to cast Hammer of Light an additional time for free.
    lights_guidance                 = { 95180, 427445, 1 }, -- [427453] Hammer down your enemy with the power of the Light, dealing $429826s1 Holy damage and ${$429826s1/2} Holy damage up to 4 nearby enemies. ; Additionally, calls down Empyrean Hammers from the sky to strike $427445s2 nearby enemies for $431398s1 Holy damage each.; 
    lingering_radiance              = { 95071, 431407, 1 }, -- Dawnlight leaves an Eternal Flame for ${$s1/1000} sec on allies or a Greater Judgment on enemies when it expires or is extended.
    luminosity                      = { 95080, 431402, 1 }, -- $?c1[Critical Strike chance of Holy Shock and Light of Dawn increased by $s1%.]?c3[Critical Strike chance of Hammer of Wrath and Divine Storm increased by $s2%.][]
    morning_star                    = { 95073, 431482, 1 }, -- Every ${$t1}.1 sec, your next Dawnlight's damage or healing is increased by $431539s1%, stacking up to $431539u times.; Morning Star stacks twice as fast while out of combat.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- [385127] Your next Holy Power spending ability deals $s1% additional increased damage and healing. This effect stacks.
    penitence                       = { 92839, 403026, 1 }, -- Your damage over time effects deal $s1% more damage.
    quickened_invocation            = { 93181, 379391, 1 }, -- Divine Toll's cooldown is reduced by ${-$s1/1000} sec.
    radiant_glory                   = { 81549, 458359, 1 }, -- $?s384392[Crusade][Avenging Wrath] is replaced with Radiant Glory.; $@spellicon458359$@spellname458359; Wake of Ashes activates $?s384392[Crusade for $454373d][Avenging Wrath for $454351d].; Each Holy Power spent has a chance to activate $?s384392[Crusade for ${$454373d/2} sec][Avenging Wrath for ${$454351d/2} sec].
    righteous_cause                 = { 81523, 402912, 1 }, -- Each Holy Power spent has a $s1% chance to reset the cooldown of Blade of Justice.
    rush_of_light                   = { 81512, 407067, 1 }, -- The critical strikes of your damaging single target Holy Power abilities grant you $s1% Haste for $407065d.
    sacrosanct_crusade              = { 95179, 431730, 1 }, -- $?a137028[Eye of Tyr][Wake of Ashes] surrounds you with a Holy barrier for $?a137028[$s1][$s4]% of your maximum health.; Hammer of Light heals you for $?a137028[$s2][$s5]% of your maximum health, increased by $?a137028[$s3][$s6]% for each additional target hit. Any overhealing done with this effect gets converted into a Holy barrier instead.
    sanctification                  = { 95185, 432977, 1 }, -- Casting Judgment increases the damage of Empyrean Hammer by $433671s1% for $433671d.; Multiple applications may overlap.
    sanctify                        = { 92688, 382536, 1 }, -- Enemies hit by Divine Storm take $382538s1% more damage from Consecration and Divine Hammers for $382538d. 
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your auto attacks deal ${$385723s1*(1+$s2/100)} additional Holy damage.
    searing_light                   = { 81552, 404540, 1 }, -- Highlord's Judgment and Radiant damage abilities have a chance to call down an explosion of Holy Fire dealing $407478s2 Radiant damage to all nearby enemies and leaving a Consecration in its wake. ; Deals reduced damage beyond 8 targets.
    second_sunrise                  = { 95086, 431474, 1 }, -- $?c1[Light of Dawn and Holy Shock have a $s1% chance to cast again at $s2% effectiveness.]?c3[Divine Storm and Hammer of Wrath have a $s1% chance to cast again at $s2% effectiveness.][]
    seething_flames                 = { 92854, 405355, 1 }, -- Wake of Ashes deals significantly reduced damage to secondary targets, but now causes you to lash out $s2 extra times for $405345s1 Radiant damage. 
    shake_the_heavens               = { 95187, 431533, 1 }, -- After casting Hammer of Light, you call down an Empyrean Hammer on a nearby target every $431536T sec, for $431536d.
    shield_of_vengeance             = { 81550, 184662, 1 }, -- Creates a barrier of holy light that absorbs $<shield> damage for $d.; When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    solar_grace                     = { 95094, 431404, 1 }, -- Your Haste is increased by $439841s1% for $439841d each time you apply Dawnlight. Multiple stacks may overlap.
    sun_sear                        = { 95072, 431413, 1 }, -- $?c1[Holy Shock and Light of Dawn critical strikes cause the target to be healed for an additional $431415o1 over $431415d.]?c3[Hammer of Wrath and Divine Storm critical strikes cause the target to burn for an additional $431414o1 Radiant damage over $431414d.][]
    suns_avatar                     = { 95105, 431425, 1 }, -- During Avenging Wrath, you become linked to your Dawnlights, causing $431911s1 Radiant damage to enemies or $431939s1 healing to allies that pass through the beams, reduced beyond $s6 targets.; Activating Avenging Wrath applies up to $s3 Dawnlights onto nearby allies or enemies and increases Dawnlight's duration by $s5%.
    swift_justice                   = { 81521, 383228, 1 }, -- Reduces the cooldown of Judgment by ${$s1/-1000} sec and Crusader Strike by ${$s2/-1000} sec.
    tempest_of_the_lightbringer     = { 92951, 383396, 1 }, -- Divine Storm projects an additional wave of light, striking all enemies up to $s1 yds in front of you for $s2% of Divine Storm's damage.
    templar_strikes                 = { 93186, 406646, 1 }, -- Crusader Strike becomes a 2 part combo.; Templar Strike slashes an enemy for $407480s1 $?s403664 [Holystrike][Radiant] damage and gets replaced by Templar Slash for $406648d.; Templar Slash strikes an enemy for $406647s1 $?s403664[Holystrike][Radiant] damage, and burns the enemy for 50% of the damage dealt over 4 sec.
    unbound_freedom                 = { 93174, 305394, 1 }, -- Blessing of Freedom increases movement speed by $m1%, and you gain Blessing of Freedom when cast on a friendly target.
    undisputed_ruling               = { 95186, 432626, 1 }, -- Hammer of Light applies Judgment to its targets, and increases your Haste by $432629s1% for $432629d.$?a137028[; Additionally, Eye of Tyr grants $s2 Holy Power.][]
    unrelenting_charger             = { 95181, 432990, 1 }, -- Divine Steed lasts ${$s1/1000} sec longer and increases your movement speed by an additional $442221s1% for the first $442221d.
    vanguards_momentum              = { 92688, 383314, 1 }, -- Hammer of Wrath has $s1 extra charge and on enemies below $s2% health generates ${$403081s1} additional Holy Power.  
    vengeful_wrath                  = { 93177, 406835, 1 }, -- Hammer of Wrath deals $s1% increased damage to enemies below $s2% health.
    wake_of_ashes                   = { 81525, 255937, 1 }, -- Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yds in front of you, and applying $@spellname403695, burning the targets for an additional ${$403695s2*($403695d/$403695t+1)} damage over $403695d.; Demon and Undead enemies are also stunned for $255941d.; Generates $s2 Holy Power.
    will_of_the_dawn                = { 95098, 431406, 1 }, -- Movement speed increased by $431462s1% while above $s1% health.; When your health is brought below $s3%, your movement speed is increased by $431752s1% for $431752d. Cannot occur more than once every $456779d.
    wrathful_descent                = { 95177, 431551, 1 }, -- When Empyrean Hammer critically strikes, $s2% of its damage is dealt to nearby enemies.; Enemies hit by this effect deal $431625s3% reduced damage to you for $431625d.
    zealots_fervor                  = { 92952, 403509, 2 }, -- Auto-attack speed increased by $s1%.
    zealous_vindication             = { 95183, 431463, 1 }, -- Hammer of Light instantly calls down $s1 Empyrean Hammers on your target when it is cast.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning        = 756 , -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain $s5 additional stack if you are the victim.; At $s2 stacks of Reckoning, your next $?a137029[Judgment deals $392885s1%][weapon swing deals $247677s1%] increased damage, will critically strike, and activates $?s231895[Crusade][Avenging Wrath] for $?s231895[$s4][$s3] sec.
    blessing_of_sanctuary    = 752 , -- (210256) Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by $m2% for $d.
    blessing_of_spellwarding = 5573, -- (204018) Blesses a party or raid member, granting immunity to magical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.; Shares a cooldown with Blessing of Protection.
    hallowed_ground          = 5535, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    lawbringer               = 754 , -- (246806) Judgment now applies Lawbringer to initial targets hit for $246807d. Casting Judgment on an enemy causes all other enemies with your Lawbringer effect to suffer up to $246867s2% of their maximum health in Holy damage.
    luminescence             = 81  , -- (199428) When healed by an ally, allies within your Aura gain $s2% increased damage and healing for $355575d.
    searing_glare            = 5584, -- (410126) Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    spreading_the_word       = 5572, -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.; $@spellicon1022 $@spellname1022; Physical damage reduced by $199507m1% for $199507d.; $@spellicon1044 $@spellname1044; Cleared of all movement impairing effects.
    ultimate_retribution     = 753 , -- (355614) Mark an enemy player for retribution after they kill an ally within your Retribution Aura. If the marked enemy is slain within $355718d, cast Redemption on the fallen ally.
    wrench_evil              = 5653, -- (460720) Turn Evil's cast time is reduced by $s1%.
} )

-- Auras
spec:RegisterAuras( {
    -- Aura effectiveness increased.
    aura_mastery = {
        id = 412629,
        duration = 8.0,
        max_stack = 1,
    },
    -- $?$w2>0&$w3>0[Damage, healing and critical strike chance increased by $w2%.]?$w3==0&$w2>0[Damage and healing increased by $w2%.]?$w2==0&$w3>0[Critical strike chance increased by $w3%.][]$?a53376[ ][]$?a53376&a137029[Holy Shock's cooldown reduced by $w6%.]?a53376&a137028[Judgment generates $53376s3 additional Holy Power.]?a53376[Each Holy Power spent deals $326731s1 Holy damage to nearby enemies.][]
    avenging_wrath = {
        id = 31884,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- retribution_paladin[137027] #20: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_wrath[406872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- The healing or damage of your next Holy Shock is increased by $s1%.
    blessing_of_anshe = {
        id = 445204,
        duration = 20.0,
        max_stack = 1,
    },
    -- Immune to movement impairing effects. $?s199325[Movement speed increased by $199325m1%][]
    blessing_of_freedom = {
        id = 1044,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unbound_freedom[305394] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unbound_freedom[199325] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Immune to Physical damage and harmful effects.
    blessing_of_protection = {
        id = 1022,
        duration = 10.0,
        max_stack = 1,
    },
    -- $?$w1>0[$w1% of damage taken is redirected to $@auracaster.][Taking ${$s1*$e1}% of damage taken by target ally.]
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- retribution_paladin[412314] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- retribution_paladin[412314] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'pvp_multiplier': 0.0, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
    },
    -- Duration of stun, silence, fear and horror effects reduced by $m1%.
    blessing_of_sanctuary = {
        id = 210256,
        duration = 5.0,
        max_stack = 1,
    },
    -- Immune to magical damage and harmful effects.
    blessing_of_spellwarding = {
        id = 204018,
        duration = 10.0,
        max_stack = 1,
    },
    -- Disoriented.
    blinding_light = {
        id = 105421,
        duration = 6.0,
        max_stack = 1,
    },
    -- $?c1[Shield of the Righteous damage and Word of Glory healing increased by $w3%.]?c2[Hammer of the Righteous also causes a wave of light that hits all other enemies near the target.]?c3[Shield of the Righteous damage and Word of Glory healing increased by $w3%.][]$?$w2<0[; Damage taken reduced by ${-$W2}.1%.][]
    consecration = {
        id = 188370,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- strength_of_conviction[379008] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 188370, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Pondering the nature of the Light.
    contemplation = {
        id = 121183,
        duration = 8.0,
        max_stack = 1,
    },
    -- $?$w1>0&$w3>0[Damage done and haste increased by $<damage>%.]?$w1>0[Damage done increased by ${$w1}%.][Haste increased by $<damage>%.]$?$w4>0[ Hammer of Wrath may be cast on any target.][]$?s53376[ Exploding with Holy light for $326731s1 damage to nearby enemies.][]
    crusade = {
        id = 454373,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_wrath[406872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- divine_wrath[406872] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Mounted speed increased by $w1%.$?$w5>0[; Incoming fear duration reduced by $w5%.][]
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- aura_mastery[31821] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
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
        duration = 8.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- suns_avatar[431425] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Damage taken reduced by $w1%.
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- aura_mastery[31821] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Building up Divine strength, at 25 stacks your next single target Holy Power ability causes ${$406983s1/25} Holystrike damage to your primary target and ${$406983s2/25} Holystrike damage to enemies within 8 yds.
    divine_arbiter = {
        id = 406975,
        duration = 30.0,
        max_stack = 1,
    },
    -- Movement speed reduced by ${$s3*-1}%.
    divine_hammer = {
        id = 198137,
        duration = 1.5,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- burning_crusade[405289] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- consecrated_ground[204054] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- penitence[403026] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- truths_wake[403695] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 14.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sanctify[382538] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Damage taken reduced by $w1%.
    divine_protection = {
        id = 403876,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- retribution_paladin[137027] #15: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- retribution_paladin[412314] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- retribution_paladin[412314] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- aegis_of_protection[403654] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Your next Holy Power ability is free and deals $s2% increased damage and healing.
    divine_purpose = {
        id = 408458,
        duration = 12.0,
        max_stack = 1,
    },
    -- Casting $?c2[Avenger's Shield]?c1[Holy Shock][Judgement] every $t1 sec for $s2 sec.
    divine_resonance = {
        id = 384029,
        duration = 15.0,
        max_stack = 1,
    },
    -- Immune to all attacks and harmful effects.
    divine_shield = {
        id = 642,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Increases ground speed by $s4%$?$w1<0[, and reduces damage taken by $w1%][].
    divine_steed = {
        id = 221883,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- retribution_paladin[137027] #19: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[432990] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[442221] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Suffering $s1 Holy damage every $t1 sec.
    divine_vengeance = {
        id = 267620,
        duration = 4.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Cannot benefit from Empyrean Legacy.
    empyrean_legacy = {
        id = 387441,
        duration = 20.0,
        max_stack = 1,
    },
    -- Your next Divine Storm is free and deals $w1% additional damage.
    empyrean_power = {
        id = 326733,
        duration = 15.0,
        max_stack = 1,
    },
    -- Healing $w1 health every $t1 sec.
    eternal_flame = {
        id = 156322,
        duration = 16.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- retribution_paladin[412314] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[412314] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Sentenced to suffer $s2% of the damage your abilities deal during its duration as Holy damage.
    execution_sentence = {
        id = 343527,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- executioners_will[406940] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- penitence[403026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Suffering $s1 damage every $t1 sec
    exorcism = {
        id = 383208,
        duration = 12.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Deals $w1 damage over $d1.
    expurgation = {
        id = 273481,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Dealing $s1% less damage to the Paladin.
    eye_of_tyr = {
        id = 209202,
        duration = 9.0,
        max_stack = 1,
    },
    -- Taking $w3% increased damage from $@auracaster's single target Holy Power abilities and $s4% increased damage from their other Holy Power abilities.
    final_reckoning = {
        id = 343721,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- executioners_will[406940] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Your Judgment deals ${$w2*$w4}% increased damage.
    for_whom_the_bell_tolls = {
        id = 433618,
        duration = 20.0,
        max_stack = 1,
    },
    -- Cannot be affected by Divine Shield, Hand of Protection, or Lay on Hands.
    forbearance = {
        id = 25771,
        duration = 30.0,
        max_stack = 1,
    },
    -- Your Holy Power spenders deal $s1% additional damage or healing while a Dawnlight is active.
    gleaming_rays = {
        id = 431481,
        duration = 30.0,
        max_stack = 1,
    },
    -- Stunned.
    hammer_of_justice = {
        id = 853,
        duration = 6.0,
        max_stack = 1,
    },
    -- Taunted.
    hand_of_reckoning = {
        id = 62124,
        duration = 3.0,
        max_stack = 1,
    },
    -- Block chance increased by $w1%. Attackers take Holy damage.
    inner_light = {
        id = 386556,
        duration = 4.0,
        max_stack = 1,
    },
    -- Your next Divine Storm deals $s1% increased damage.
    inquisitors_ire = {
        id = 403976,
        duration = 3600,
        max_stack = 1,
    },
    -- Teleporting.
    jailers_judgment = {
        id = 162056,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your next $?s383328[Final Verdict]?s215661[Justicar's Vengeance][Templar's Verdict] hits ${$w1-1} additional targets.
    judge_jury_and_executioner = {
        id = 453433,
        duration = 12.0,
        max_stack = 1,
    },
    -- Taking $w1% increased damage from $@auracaster's next Holy Power ability.
    judgment = {
        id = 197277,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_wrath[404512] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': ADDITIONAL_CHARGES, }
        -- judgment_of_justice[403495] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- highlords_judgment[449198] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Attackers are healed for $183811s1.
    judgment_of_light = {
        id = 196941,
        duration = 30.0,
        max_stack = 1,
    },
    -- Suffering up to $246867s2% of maximum health in Holy damage when Judgment is cast.
    lawbringer = {
        id = 246807,
        duration = 60.0,
        max_stack = 1,
    },
    -- The paladin's healing spells cast on you also heal the Beacon of Light.
    lights_beacon = {
        id = 53651,
        duration = 0.0,
        max_stack = 1,
    },
    -- Deals $w1 damage.
    lights_decree = {
        id = 286232,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?$W1==$U[Ready to deliver Light's justice.][Building up Light's Deliverance. At $u stacks, your next Hammer of Light cast will activate another Hammer of Light for free.]
    lights_deliverance = {
        id = 433674,
        duration = 3600,
        max_stack = 1,
    },
    -- $w1% increased damage and healing.
    luminescence = {
        id = 355575,
        duration = 6.0,
        max_stack = 1,
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
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.
    radiant_decree = {
        id = 383469,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- final_reckoning[343721] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Taking $w2% increased damage from $@auracaster's next Holy Power ability.
    reckoning = {
        id = 343724,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Incapacitated.
    repentance = {
        id = 20066,
        duration = 60.0,
        max_stack = 1,
    },
    -- Damage and healing increased by $w1%. $?a31821[Healing received increased by $w2%.][]
    retribution_aura = {
        id = 404996,
        duration = 30.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- aura_mastery[31821] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Haste increased by $s1%.
    rush_of_light = {
        id = 407065,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Empyrean Hammer damage increased by $w1%
    sanctification = {
        id = 433671,
        duration = 10.0,
        max_stack = 1,
    },
    -- [382536] Damage taken from Consecration and Divine Hammers increased by $382538s1%.
    sanctify = {
        id = 382538,
        duration = 12.0,
        max_stack = 1,
    },
    -- $@spellaura385728
    seal_of_the_crusader = {
        id = 385723,
        duration = 0.0,
        max_stack = 1,
    },
    -- Misses spells and melee attacks.
    searing_glare = {
        id = 410201,
        duration = 4.0,
        max_stack = 1,
    },
    -- Detecting Undead.
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1,
    },
    -- Casting Empyrean Hammer on a nearby target every $t sec.
    shake_the_heavens = {
        id = 431536,
        duration = 8.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage and deals damage when the barrier fades or is fully consumed.
    shield_of_vengeance = {
        id = 184662,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Haste increased by $w1%.
    solar_grace = {
        id = 439841,
        duration = 12.0,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $w1%.
    spreading_the_word_protection = {
        id = 199507,
        duration = 6.0,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_charger = {
        id = 23214,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_darkforge_ram = {
        id = 270562,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_dawnforge_ram = {
        id = 270564,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_exarchs_elekk = {
        id = 73629,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_great_exarchs_elekk = {
        id = 73630,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_great_sunwalker_kodo = {
        id = 69826,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_lightforged_ruinstrider = {
        id = 363613,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_sunwalker_kodo = {
        id = 69820,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_thalassian_charger = {
        id = 34767,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_thalassian_warhorse = {
        id = 34769,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_warhorse = {
        id = 13819,
        duration = 3600,
        max_stack = 1,
    },
    -- Healing $w1 every $t1 sec.
    sun_sear = {
        id = 431415,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?(s403696)[Burning for $w2 damage every $t2 sec and movement speed reduced by $s1%.] [Movement speed reduced by $s1%.]
    truths_wake = {
        id = 403695,
        duration = 9.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- penitence[403026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
    },
    -- Disoriented.
    turn_evil = {
        id = 10326,
        duration = 40.0,
        max_stack = 1,

        -- Affected by:
        -- wrench_evil[460720] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Healing received from Holy Light, Flash of Light, and Holy Shock increased by $s2%.
    tyrs_deliverance = {
        id = 200654,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- A Paladin is seeking righteous vengeance for the death of $@auracaster.
    ultimate_retribution = {
        id = 355718,
        duration = 12.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%
    undisputed_ruling = {
        id = 432629,
        duration = 6.0,
        max_stack = 1,
    },
    -- Stunned.
    wake_of_ashes = {
        id = 255941,
        duration = 5.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    will_of_the_dawn = {
        id = 431462,
        duration = 5.0,
        max_stack = 1,
    },
    -- Auto attack speed increased and deals additional Holy damage.
    zeal = {
        id = 269571,
        duration = 20.0,
        pandemic = true,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Empowers your chosen aura for $d.$?a344218[; $@spellname465: Damage reduction increased to ${-$s1-$465s2}%.][]$?a344219[; $@spellname32223: Mount speed bonus increased to ${$s2+$32223s4}%.][]$?a344217[; $@spellname183435: Increases healing received by $s3% while its effect is active.][]$?a344220[; $@spellname317920: Affected allies immune to interrupts and silences.][]
    aura_mastery = {
        id = 31821,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 412629, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Call upon the Light to become an avatar of retribution, $?s53376&c2[causing Judgment to generate $53376s3 additional Holy Power, ]?s53376&c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies, ]?s53376&c1[reducing Holy Shock's cooldown by $53376s2%, ][]$?s326730[allowing Hammer of Wrath to be used on any target, ][]$?s384442&s384376[increasing your damage, healing and critical strike chance by $s2% for $d.]?!s384442&s384376[increasing your damage and healing by $s1% for $d.]?!s384376&s384442[increasing your critical strike chance by $s3% for $d.][and activating all the effects learned for Avenging Wrath for $d.]
    avenging_wrath = {
        id = 31884,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "avenging_wrath",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_PCT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_BLIND, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'value': 2179, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 395605, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MASTERY, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- retribution_paladin[137027] #20: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_wrath[406872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- $?s403826[Pierce enemies][Pierce an enemy] with a blade of light, dealing $s1 Holy damage$?s403826[ to your target and $404358s1 Holy damage to nearby enemies.][.]; Generates $s2 Holy Power.
    blade_of_justice = {
        id = 184575,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "blade_of_justice",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.66387, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 404358, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- holy_blade[383342] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- improved_blade_of_justice[403745] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- jurisdiction[402971] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- jurisdiction[402971] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_freedom = {
        id = 1044,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        talent = "blessing_of_freedom",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 7, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 11, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- unbound_freedom[305394] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unbound_freedom[199325] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[; Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_protection = {
        id = 1022,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "blessing_of_protection",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
    },

    -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.; Last $d, or until transferred damage would cause you to fall below $s3% health.
    blessing_of_sacrifice = {
        id = 6940,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 0.014,
        spendType = 'mana',

        talent = "blessing_of_sacrifice",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SPLIT_DAMAGE_PCT, 'amplitude': 1.0, 'points': 30.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- retribution_paladin[412314] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- retribution_paladin[412314] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'pvp_multiplier': 0.0, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
    },

    -- Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by $m2% for $d.
    blessing_of_sanctuary = {
        id = 210256,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 60.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'points': -60.0, 'value': 9, 'schools': ['physical', 'nature'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'points': -60.0, 'value': 12, 'schools': ['fire', 'nature'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'points': -60.0, 'value': 5, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'points': -60.0, 'value': 24, 'schools': ['nature', 'frost'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.; Shares a cooldown with Blessing of Protection.
    blessing_of_spellwarding = {
        id = 204018,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_RAID, }
    },

    -- Emits dazzling light in all directions, blinding enemies within $105421A1 yds, causing them to wander disoriented for $105421d.
    blinding_light = {
        id = 115750,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "blinding_light",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Cleanses a friendly target, removing all Poison and Disease effects.
    cleanse_toxins = {
        id = 213644,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        talent = "cleanse_toxins",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Consecrates the land beneath you, causing $?s405289[${$<dmg>*1.05} Radiant][${$<dmg>*1.05} Holy] damage over $d to enemies who enter the area$?s204054[ and reducing their movement speed by $204054s2%.][.] Limit $s2.
    consecration = {
        id = 26573,
        cast = 0.0,
        cooldown = 9.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 4488, 'schools': ['nature'], 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': SUMMON, 'subtype': NONE, 'value': 43499, 'schools': ['physical', 'holy', 'nature', 'shadow', 'arcane'], 'value1': 3002, 'target': TARGET_DEST_CASTER, }

        -- Affected by:
        -- retribution_paladin[137027] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #21: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 11000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- burning_crusade[405289] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- truths_wake[403695] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 14.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 64.0, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sanctify[382538] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Allows you a moment of peace as you kneel in quiet contemplation to ponder the nature of the Light.
    contemplation = {
        id = 121183,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Call upon the Light and begin a crusade, increasing your haste $?s384376[and damage ][]by ${$s5/10}% for $d.; Each Holy Power spent during Crusade increases haste $?s384376[and damage ][]by an additional ${$s5/10}%.; Maximum $u stacks.$?s53376[; While active, each Holy Power spent causes you to explode with Holy light for $326731s1 damage to nearby enemies.][]$?s384376[; Hammer of Wrath may be cast on any target.][]; 
    crusade = {
        id = 231895,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MASTERY, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 395605, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_wrath[406872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Increases mounted speed by $s1% for all party and raid members within $a1 yds.
    crusader_aura = {
        id = 32223,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "crusader_aura",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_MOUNTED_SPEED_NOT_STACK, 'points': 20.0, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_FLIGHT_SPEED_NOT_STACK, 'points': 20.0, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AREA_AURA_RAID, 'subtype': DUMMY, 'points': 20.0, 'value': 33, 'schools': ['physical', 'shadow'], 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 344219, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- aura_mastery[31821] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
    },

    -- Strike the target for $<damage> $?s403664 [Holystrike][Physical] damage.$?a196926[; Reduces the cooldown of Holy Shock by ${$196926m1/-1000}.1 sec.][]; Generates $s2 Holy Power.
    crusader_strike = {
        id = 35395,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        -- 1. [137029] holy_paladin
        -- spend = 0.006,
        -- spendType = 'mana',

        -- 2. [137027] retribution_paladin
        -- spend = 0.016,
        -- spendType = 'mana',

        -- 3. [137028] protection_paladin
        -- spend = 0.016,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target'], 'ap_bonus': 1.071, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #13: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- crusader_strike[342348] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -80.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- improved_crusader_strike[383254] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blessed_champion[403010] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Chain from Initial Target'], 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_crusader[406154] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_crusader[406154] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- templar_strikes[406646] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': -1.0, 'target': TARGET_UNIT_CASTER, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #31: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Party and raid members within $a1 yds are bolstered by their devotion, reducing damage taken by $s1%.
    devotion_aura = {
        id = 465,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -3.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 344218, 'points': -3.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- aura_mastery[31821] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Divine Hammers spin around you, consuming a Holy Power to strike enemies within $198137A1 yds for $?s405289[${$198137sw1*1.05} Radiant][$198137sw1 Holy] damage every $t sec. ; While active your Judgment, Blade of Justice$?a404542[][ and Crusader Strike] recharge $s2% faster, and increase the rate at which Divine Hammer strikes by $s1% when they are cast. Deals reduced damage beyond 8 targets.
    divine_hammer = {
        id = 198034,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spendType = 'holy_power',

        talent = "divine_hammer",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 2.2, 'trigger_spell': 198137, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 75.0, 'value': 1663, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 75.0, 'value': 1627, 'schools': ['physical', 'holy', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 75.0, 'value': 2128, 'schools': ['frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Reduces all damage you take by $s1% for $d. Usable while stunned.
    divine_protection = {
        id = 403876,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        spend = 0.007,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_paladin[137027] #15: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- retribution_paladin[412314] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- retribution_paladin[412314] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- aegis_of_protection[403654] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Grants immunity to all damage, harmful effects, knockbacks and forced movement effects for $d. $?a204077[Taunts all targets within 15 yd.][]; Cannot be used if you have Forbearance. Causes Forbearance for $25771d.
    divine_shield = {
        id = 642,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MOVEMENT_FORCE_MAGNITUDE, 'points': -100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed = {
        id = 190784,
        cast = 0.0,
        cooldown = 0.75,
        gcd = "none",

        talent = "divine_steed",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_paladin[137027] #19: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- cavalier[230332] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[432990] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[442221] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- [190784] Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed_221883 = {
        id = 221883,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MOUNTED_SPEED_NOT_STACK, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'value': 14584, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1154, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_paladin[137027] #19: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[432990] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[442221] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        from = "from_description",
    },

    -- Unleashes a whirl of divine energy, dealing $?s405289[${$s1*1.05} Radiant][$s1 Holy] damage to all nearby enemies. ; Deals reduced damage beyond $s2 targets.
    divine_storm = {
        id = 53385,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        talent = "divine_storm",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.931273, 'pvp_multiplier': 0.9259, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 403460, 'value': 200, 'schools': ['nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 407467, 'value': 200, 'schools': ['nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- burning_crusade[405289] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- luminosity[431402] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- empyrean_power[326733] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- empyrean_power[326733] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- inquisitors_ire[403976] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[; After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[; Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[; Generates $s5 Holy Power per target hit.][]
    divine_toll = {
        id = 375576,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "divine_toll",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- paladin[137026] #7: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_invocation[379391] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 375576, 'triggers': divine_toll, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- divine_purpose[408458] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },

    -- Heals an ally for $s2 and an additional $o1 over $d.; Healing increased by $s3% when cast on self.
    eternal_flame = {
        id = 156322,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.006,
        spendType = 'mana',

        talent = "eternal_flame",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 2.0, 'sp_bonus': 0.12, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.15, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- retribution_paladin[412314] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[412314] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- A hammer slowly falls from the sky upon the target, after $d, they suffer $s2% of the damage taken from your abilities as Holy damage during that time.; $?s406158 [Generates $406158s1 Holy Power.][]
    execution_sentence = {
        id = 343527,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "execution_sentence",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 0.65, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- executioners_will[406940] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- penitence[403026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Releases a blinding flash from Truthguard, causing $s2 Holy damage to all nearby enemies within $A1 yds and reducing all damage they deal to you by $s1% for $d.
    eye_of_tyr = {
        id = 209202,
        color = 'artifact',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'points': -25.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.567, 'points': 1.0, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 25.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENTRY, }
    },

    -- Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the area and causing them to take $s3% increased damage from your single target Holy Power abilities, and $s4% increased damage from other Holy Power abilities for $d.; $?s406158 [Generates $406158s1 Holy Power.][]
    final_reckoning = {
        id = 343721,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "final_reckoning",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.8875, 'pvp_multiplier': 0.8, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- executioners_will[406940] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Unleashes a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage to an enemy target,; Final Verdict has a $s2% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    final_verdict = {
        id = 383328,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        talent = "final_verdict",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.79322, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- final_reckoning[343721] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- jurisdiction[402971] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- jurisdiction[402971] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judge_jury_and_executioner[453433] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Chain from Initial Target'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Unleashes a powerful weapon strike that deals $s1 Holy damage to an enemy target.; Has a $s2% chance to activate Hammer of Wrath and reset its cooldown.
    final_verdict_336872 = {
        id = 336872,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.4495, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- final_reckoning[343721] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- jurisdiction[402971] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judge_jury_and_executioner[453433] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Chain from Initial Target'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        from = "affected_by_mastery",
    },

    -- Quickly heal a friendly target for $?$c1&$?a134735[${$s1*1}][$s1].
    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [137027] retribution_paladin
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 1. [137028] protection_paladin
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 2. [137029] holy_paladin
        -- spend = 0.018,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.156, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- retribution_paladin[137027] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[412314] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tyrs_deliverance[200654] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- lights_celerity[403698] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- lights_celerity[403698] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lights_celerity[403698] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Stuns the target for $d.
    hammer_of_justice = {
        id = 853,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.007,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Hammer down your enemy with the power of the Light, dealing $429826s1 Holy damage and ${$429826s1/2} Holy damage up to 4 nearby enemies. ; Additionally, calls down Empyrean Hammers from the sky to strike $427445s2 nearby enemies for $431398s1 Holy damage each.; 
    hammer_of_light = {
        id = 427453,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 5,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 429826, 'value': 600, 'schools': ['nature', 'frost', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Hurls a divine hammer that strikes an enemy for $<damage> $?s403664[Holystrike][Holy] damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].; Generates $s2 Holy Power.
    hammer_of_wrath = {
        id = 24275,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "hammer_of_wrath",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.302, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[412314] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[412314] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- luminosity[431402] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- vanguards_momentum[383314] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- vanguards_momentum[383314] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- highlords_judgment[449198] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 116.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 68.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[454373] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
    },

    -- [114165] Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_prism = {
        id = 114852,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.4, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE'], 'sp_bonus': 3.5, 'variance': 0.05, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #2: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE'], 'radius': 30.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENTRY, }

        -- Affected by:
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [114165] Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_prism_114871 = {
        id = 114871,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 7.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.4, 'variance': 0.05, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "class",
    },

    -- Petition the Light on the behalf of a fallen ally, restoring spirit to body and allowing them to reenter battle with $s2% health and at least $s1% mana.
    intercession = {
        id = 391054,
        cast = 2.0,
        cooldown = 600.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.020,
        spendType = 'mana',

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 20.0, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- final_reckoning[343721] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Stuns the target Player for $d. If the judgment holds for $d, the enemy will be instantly teleported to your jail. Can only be used while in Ashran.
    jailers_judgment = {
        id = 162056,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Judges the target, dealing $s1 $?s403664[Holystrike][Holy] damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability.][.]$?s315867[; Generates $220637s1 Holy Power.][]
    judgment = {
        id = 20271,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'sp_bonus': 0.610542, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'sp_bonus': 0.305271, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_judgment[405461] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- judgment_of_justice[403495] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- highlords_judgment[449198] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Judges the target, dealing $s1 Holy damage$?s231644[, and preventing $<shield> damage dealt by the target][].$?s315867[; Generates $220637s1 Holy Power.][]
    judgment_275773 = {
        id = 275773,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.125, 'pvp_multiplier': 1.3, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_judgment[405461] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- judgment_of_justice[403495] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Judges the target, dealing $s1 Holy damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability][].$?a315867[; Generates $220637s1 Holy Power.][]; 
    judgment_275779 = {
        id = 275779,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.125, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_judgment[405461] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- judgment_of_justice[403495] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Judges the target, dealing $s1 Holy damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability.][]$?s315867[; Generates $220637s1 Holy Power.][]
    judgment_406957 = {
        id = 406957,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.610542, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- retribution_paladin[137027] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_judgment[405461] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- judgment_of_justice[403495] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- highlords_judgment[449198] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Focuses Holy energy to deliver a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage, and restores $408394s1% of your maximum health.; Damage is increased by $s2% when used against a stunned target.
    justicars_vengeance = {
        id = 215661,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        talent = "justicars_vengeance",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.51612, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 0.6, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 408394, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- final_reckoning[343721] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- jurisdiction[402971] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judge_jury_and_executioner[453433] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Chain from Initial Target'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Heals a friendly target for an amount equal to $s2% your maximum health.$?a387791[; Grants the target $387792s1% increased armor for $387792d.][]; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.
    lay_on_hands = {
        id = 633,
        cast = 0.0,
        cooldown = 600.0,
        gcd = "none",

        talent = "lay_on_hands",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_MAX_HEALTH, 'subtype': NONE, 'pvp_multiplier': 0.75, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL_PCT, 'subtype': NONE, 'pvp_multiplier': 0.75, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yds in front of you and reducing their movement speed by $s2% for $d. Deals reduced damage beyond 5 targets.; Demon and Undead enemies are also stunned for $255941d.
    radiant_decree = {
        id = 383469,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 2.25, 'pvp_multiplier': 0.67, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'mechanic': snared, 'points': -50.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- final_reckoning[343721] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 30.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Interrupts spellcasting and prevents any spell in that school from being cast for $d.
    rebuke = {
        id = 96231,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        talent = "rebuke",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Brings a dead ally back to life with $s1% of maximum health and mana. Cannot be cast when in combat.
    redemption = {
        id = 7328,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }
    },

    -- Forces an enemy target to meditate, incapacitating them for $d.; Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "repentance",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'variance': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- When any party or raid member within $a1 yds takes more than $s3% of their health in damage in a single hit, each member gains $404996s1% increased damage and healing, decaying over $404996d. This cannot occur within $392503d of the aura being applied.
    retribution_aura = {
        id = 183435,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_ATTACK_POWER, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 344217, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_aura[317906] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    searing_glare = {
        id = 410126,
        cast = 1.25,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 410201, 'target': TARGET_UNIT_CASTER, }
    },

    -- Calls down a explosion of Holy Fire dealing $s2 Radiant damage to all nearby enemies and leaving a Consecration in its wake. ; 
    searing_light = {
        id = 407478,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.8, 'pvp_multiplier': 0.8, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Shows the location of all nearby undead on the minimap until cancelled. Only one form of tracking can be active at a time.
    sense_undead = {
        id = 5502,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRACK_CREATURES, 'variance': 0.25, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- [386568] When Shield of the Righteous expires, gain $386556s1% block chance and deal $386553s1 Holy damage to all attackers for $386556d.
    shield_of_the_righteous = {
        id = 53600,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.425, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_UNIT_CONE_ENEMY_24, }
        -- #1: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 403460, 'points': 1.0, }
        -- #2: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 407467, 'points': 1.0, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- retribution_paladin[137027] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- retribution_paladin[137027] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adjudication[406157] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_decree[383469] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crusade[231895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[231895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- crusade[454373] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusade[454373] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [386568] When Shield of the Righteous expires, gain $386556s1% block chance and deal $386553s1 Holy damage to all attackers for $386556d.
    shield_of_the_righteous_415091 = {
        id = 415091,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.5746, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 403460, 'points': 1.0, }
        -- #2: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 407467, 'points': 1.0, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- final_reckoning[343721] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 15.0, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- reckoning[343724] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        from = "affected_by_mastery",
    },

    -- Creates a barrier of holy light that absorbs $<shield> damage for $d.; When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    shield_of_vengeance = {
        id = 184662,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "shield_of_vengeance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Complete the Templar combo, slash the target for $<damage> $?s403664[Holystrike][Radiant] damage, and burn them over 4 sec for 50% of the damage dealt.; Generate $s2 Holy Power.
    templar_slash = {
        id = 406647,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.004,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target'], 'ap_bonus': 2.50011, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blessed_champion[403010] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Chain from Initial Target'], 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_crusader[406154] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_crusader[406154] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- Begin the Templar combo, striking the target for $<damage> $?s403664 [Holystrike][Radiant] damage.; Generates $s2 Holy Power.
    templar_strike = {
        id = 407480,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.004,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target'], 'ap_bonus': 1.35548, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_crusader_strike[383254] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blessed_champion[403010] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Chain from Initial Target'], 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_crusader[406154] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heart_of_the_crusader[406154] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- templar_strikes[406646] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': -1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Unleashes a powerful weapon strike that deals $224266s1 $?s403664[Holystrike][Holy] damage to an enemy target.
    templars_verdict = {
        id = 85256,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_paladin[137027] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- blades_of_light[403664] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- divine_arbiter[404306] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.021,
        spendType = 'mana',

        talent = "turn_evil",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- wrench_evil[460720] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Releases the Light within yourself, healing $s2 injured allies instantly and an injured ally every $t1 sec for $d within $200653A1 yds for $200654s1.; Allies healed also receive $200654s2% increased healing from your Holy Light, Flash of Light, and Holy Shock spells for $200654d.
    tyrs_deliverance = {
        id = 200652,
        cast = 2.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 200653, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Lash out with the Ashbringer, dealing $sw1 Radiant damage$?a179546[, and an additional $o3 Radiant damage over $d,][] to all enemies within $a1 yd in front of you, and reducing movement speed by $s2% for $d.; Demon and Undead enemies are stunned for $205290d if struck by the Wake of Ashes.$?a179546[; Generates $218001s1 Holy Power.][]
    wake_of_ashes = {
        id = 205273,
        color = 'artifact',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 1.743, 'points': 1.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'mechanic': snared, 'points': -50.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'tick_time': 1.0, 'ap_bonus': 0.294, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': SCHOOL_MASK_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
    },

    -- Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yds in front of you, and applying $@spellname403695, burning the targets for an additional ${$403695s2*($403695d/$403695t+1)} damage over $403695d.; Demon and Undead enemies are also stunned for $255941d.; Generates $s2 Holy Power.
    wake_of_ashes_255937 = {
        id = 255937,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "wake_of_ashes_255937",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Always AOE Line of Sight', 'Area Effects Use Target Radius'], 'ap_bonus': 2.926, 'pvp_multiplier': 0.727272, 'variance': 0.05, 'radius': 14.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 403695, 'variance': 0.05, 'value': 5, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 405345, 'variance': 0.05, 'value': 450, 'schools': ['holy', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 405350, 'variance': 0.05, 'value': 900, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
        from = "spec_talent",
    },

    -- Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yds in front of you, and applying $@spellname403695, burning the targets for an additional ${$403695s2*($403695d/$403695t+1)} damage over $403695d.; Demon and Undead enemies are also stunned for $255941d.; Generates $s2 Holy Power.
    wake_of_ashes_453868 = {
        id = 453868,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Always AOE Line of Sight', 'Area Effects Use Target Radius'], 'ap_bonus': 2.926, 'pvp_multiplier': 0.727272, 'variance': 0.05, 'radius': 14.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 403695, 'variance': 0.05, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 405345, 'variance': 0.05, 'value': 450, 'schools': ['holy', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 405350, 'variance': 0.05, 'value': 900, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_highlords_judgment[267316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_highlords_judgment[267316] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
        from = "affected_by_mastery",
    },

    -- Calls down the Light to heal a friendly target for $130551s1$?a378405[ and an additional $<heal> over $378412d][].$?a379043[ Your block chance is increased by $379043s1% for $379041d.][]$?a315921&!a315924[; Protection: If cast on yourself, healing increased by up to $315921s1% based on your missing health.][]$?a315924[; Protection: Healing increased by up to $315921s1% based on your missing health, or up to $315924s1% if cast on another target.][]
    word_of_glory = {
        id = 85673,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.006,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.465, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- retribution_paladin[137027] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 116.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[408458] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[408458] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

} )