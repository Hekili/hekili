-- PaladinRetribution.lua
-- October 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 70 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

spec:RegisterTalents( {
    -- Paladin Talents
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- [183435] When any party or raid member within $a1 yds takes more than $s3% of their health in damage in a single hit, each member gains $404996s1% increased damage and healing, decaying over $404996d. This cannot occur within $392503d of the aura being applied.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- [317920] Interrupt and Silence effects on party and raid members within $a1 yds are $s1% shorter. $?a339124[Fear effects are also reduced.][]
    avenging_wrath                  = { 81606, 384376, 1 }, -- Call upon the Light and become an avatar of retribution, increasing your damage and healing done by $s1% for $31884d, and allowing Hammer of Wrath to be cast on any target.; Combines with other Avenging Wrath abilities, granting all known Avenging Wrath effects while active.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[; Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.; Last $d, or until transferred damage would cause you to fall below $s3% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within $105421A1 yds, causing them to wander disoriented for $105421d.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has ${1+$m1} charges.
    crusaders_reprieve              = { 81543, 403042, 1 }, -- Increases the range of your $?s53595[Hammer of the Righteous and ]?s204019[][Crusader Strike, ]Rebuke $?!c2[and auto-attacks ][]by $s2 yds. Using $?s53595[Hammer of the Righteous]?s204019[Blessed Hammer][Crusader Strike] heals you for $403044s1% of your maximum health.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[; After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[; Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[; Generates $s5 Holy Power per target hit.][]
    fading_light                    = { 81623, 405768, 1 }, -- $@spellicon385127$@spellname385127:; Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional $s1%.; $@spellicon385126$@spellname385126:; Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for $s2% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- [379017] $?c2[Shield of the Righteous][Word of Glory] grants $s1% bonus armor for $d.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by $s1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and $s2 allies within it for $<points> every $26573t1 sec.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for $<damage> $?s403664[Holystrike][Holy] damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].; Generates $s2 Holy Power.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by $s2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection$?c2[ and Blessing of Spellwarding][] by ${-$s1/1000} sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a $s1% chance to cause your Consecration to flare up, dealing $385816s1 Holy damage to up to $s1 enemies standing within it.
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
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your $?s2812[Denounce][Shield of the Righteous] and Word of Glory have $s1% increased damage and healing.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing $385354s1 Holy damage or healing an ally for $385352s1 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, $?s184662[Shield of Vengeance, ][]$?s31850[Ardent Defender][Divine Protection], and Lay on Hands by $s1%.

    -- Retribution Talents
    adjudication                    = { 81537, 406157, 1 }, -- Critical Strike damage of your abilities increased by $s1% and Hammer of Wrath critical strikes cause a Blessed Hammer to spiral outward dealing $404139s1 Holystrike damage to enemies.
    aegis_of_protection             = { 81550, 403654, 1 }, -- Divine Protection reduces damage you take by an additional $s1% and Shield of Vengeance absorbs $s2% more damage.
    afterimage                      = { 93189, 385414, 1 }, -- After you spend $s3 Holy Power, your next Word of Glory echoes onto a nearby ally at $s1% effectiveness.
    art_of_war                      = { 81523, 406064, 1 }, -- Your auto attacks have a $h% chance to reset the cooldown of Blade of Justice.
    avenging_wrath_might            = { 81525, 384442, 1 }, -- Call upon the Light and become an avatar of retribution, increasing your critical strike chance by $s1% for $31884d.; Combines with other Avenging Wrath abilities.
    blade_of_justice                = { 81526, 184575, 1 }, -- $?s403826[Pierce enemies][Pierce an enemy] with a blade of light, dealing $?s403826[$404358s1][$s1] Holy damage.; Generates $s2 Holy Power.
    blade_of_vengeance              = { 81545, 403826, 1 }, -- Blade of Justice now hits nearby enemies for $404358s1 Holy damage. ; Deals reduced damage beyond 5 targets.
    blades_of_light                 = { 93164, 403664, 1 }, -- Crusader Strike, Judgment, Hammer of Wrath and your damaging single target Holy Power abilities deal Holystrike damage.
    blessed_champion                = { 81541, 403010, 2 }, -- Crusader Strike and Judgment hit an additional $s4 targets but deal $s3% reduced damage to secondary targets.
    boundless_judgment              = { 81533, 405278, 1 }, -- Judgment generates $s1 additional Holy Power.
    burning_crusade                 = { 81536, 405289, 1 }, -- Divine Storm, Divine Hammer and Consecration now deal Radiant damage and your abilities that deal Radiant damage deal $s2% increased damage.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_blade               = { 81516, 404834, 1 }, -- Blade of Justice casts Consecration at the target's location.; This effect can only occur every 10 sec.
    consecrated_ground              = { 81512, 204054, 1 }, -- Your Consecration is $s1% larger, and enemies within it have $s2% reduced movement speed.$?c3[; Your Divine Hammer is $s4% larger, and enemies within them have ${$198137s3*-1}% reduced movement speed.][]
    crusade                         = { 81525, 384392, 1 }, -- Call upon the Light and begin a crusade, increasing your haste by $s1% for $231895d.; Each Holy Power spent during Crusade increases haste by an additional $s1%.; Maximum $231895u stacks.; If $@spellname31884 is known, also grants $s1% damage per stack.;
    crusading_strikes               = { 93186, 404542, 1 }, -- Crusader Strike replaces your auto-attacks and deals $408385s1 $?s403664[Holystrike][Physical] damage, but now only generates $s4 Holy Power every $s3 attacks.; Inherits Crusader Strike benefits but cannot benefit from Windfury.
    divine_arbiter                  = { 81540, 404306, 1 }, -- Abilities that deal Holystrike damage deal $s1% increased damage and casting abilities that deal Holystrike damage grants you a stack of Divine Arbiter.; At $s3 stacks your next damaging single target Holy Power ability causes $406983s1 Holystrike damage to your primary target and $406983s2 Holystrike damage to enemies within 6 yds.
    divine_auxiliary                = { 81538, 406158, 1 }, -- Final Reckoning and Execution Sentence grant $408386s1 Holy Power.
    divine_hammer                   = { 81516, 198034, 1 }, -- Divine Hammers spin around you, damaging enemies within $198137A1 yds for $?s405289[${$d/$t1*$198137sw1*1.05} Radiant][${$d/$t1*$198137sw1} Holy] damage over $d. Deals reduced damage beyond 8 targets.
    divine_purpose                  = { 81618, 408459, 1 }, -- Holy Power abilities have a $s1% chance to make your next Holy Power ability free and deal $408458s2% increased damage and healing.
    divine_resonance                = { 93181, 384027, 1 }, -- [384028] After casting Divine Toll, you instantly cast $?c2[Avenger's Shield]?c1[Holy Shock][Judgment] every $384029t1 sec for $384029s2 sec.
    divine_storm                    = { 81527, 53385 , 1 }, -- Unleashes a whirl of divine energy, dealing $?s405289[${$s1*1.05} Radiant][$s1 Holy] damage to all nearby enemies. ; Deals reduced damage beyond $s2 targets.
    divine_wrath                    = { 93160, 406872, 1 }, -- Increases the duration of Avenging Wrath or Crusade by ${$s1/1000} sec.
    empyrean_legacy                 = { 81545, 387170, 1 }, -- Judgment empowers your next $?c3[Single target Holy Power ability to automatically activate Divine Storm][Word of Glory to automatically activate Light of Dawn] with $s2% increased effectiveness.; This effect can only occur every $387441d.
    empyrean_power                  = { 92860, 326732, 1 }, -- $?s404542[Crusading Strikes has a $s2%][Crusader Strike has a $s1%] chance to make your next Divine Storm free and deal $326733s1% additional damage.
    execution_sentence              = { 81539, 343527, 1 }, -- A hammer slowly falls from the sky upon the target, after $d, they suffer $s2% of the damage taken from your abilities as Holy damage during that time.; $?s406158 [Generates $406158s1 Holy Power.][]
    executioners_will               = { 81548, 406940, 1 }, -- Final Reckoning and Execution Sentence's durations are increased by ${$s1/1000} sec.
    expurgation                     = { 92689, 383344, 1 }, -- Your Blade of Justice causes the target to burn for $383346o1 $?s403665[Holy][Radiant] damage over $383346d.
    final_reckoning                 = { 81539, 343721, 1 }, -- Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the target area and causing them to take $s3% increased damage from your Holy Power abilities for $d.; $?s406158 [Generates $406158s1 Holy Power.][]
    final_verdict                   = { 81532, 383328, 1 }, -- Unleashes a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage to an enemy target,; Final Verdict has a $s2% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take $s1% increased damage from your next Holy Power ability.
    guided_prayer                   = { 81531, 404357, 1 }, -- When your health is brought below $s1%, you instantly cast a free Word of Glory at $s2% effectiveness on yourself.; Cannot occur more than once every $proccooldown sec.
    healing_hands                   = { 93189, 326734, 1 }, -- The cooldown of Lay on Hands is reduced up to $s1%, based on the target's missing health.; Word of Glory's healing is increased by up to $m3%, based on the target's missing health.
    heart_of_the_crusader           = { 93190, 406154, 1 }, -- Crusader Strike and auto-attacks deal $s3% increased damage and deal $s4% increased critical strike damage.;
    highlords_judgment              = { 81534, 404512, 2 }, -- Judgment's duration is increased by ${$s3/1000} sec. If you have Greater Judgment, targets take $231663s1% increased damage from your next ${$s1+1} Holy Power abilities.
    holy_blade                      = { 92838, 383342, 1 }, -- Blade of Justice generates $s1 additional Holy Power.
    improved_blade_of_justice       = { 92838, 403745, 1 }, -- Blade of Justice now has ${$s1+1} charges.
    improved_judgment               = { 81533, 405461, 1 }, -- Judgment now has ${$s1+1} charges.
    inquisitors_ire                 = { 92951, 403975, 1 }, -- Every $t1 sec, gain $403976s1% increased damage to your next Divine Storm, stacking up to $403976u times.
    judge_jury_and_executioner      = { 92860, 405607, 1 }, -- Increases the critical strike chance of Judgment $s1%.;
    judgment_of_justice             = { 93161, 403495, 1 }, -- Judgment deals $s2% increased damage and increases your movement speed by $s2%.; If you have Greater Judgment, Judgment slows enemies by $408383s1% for $408383d.
    jurisdiction                    = { 81542, 402971, 1 }, -- $?s383328[Final Verdict]?s215661[Justicar's Vengeance][Templar's Verdict] and Blade of Justice deal $s4% increased damage.; The range of $?s383328[Final Verdict and ][]Blade of Justice is increased to $s3 yds.
    justicars_vengeance             = { 81532, 215661, 1 }, -- Focuses Holy energy to deliver a powerful weapon strike that deals $s1 $?s403664[Holystrike][Holy] damage, and restores $408394s1% of your maximum health.; Damage is increased by $s2% when used against a stunned target.
    light_of_justice                = { 81521, 404436, 1 }, -- Reduces the cooldown of Blade of Justice by ${$s1/-1000} sec.
    lightforged_blessing            = { 93008, 403479, 1 }, -- Divine Storm heals you and up to $s2 nearby allies for $407467s1% of maximum health.
    lights_celerity                 = { 81531, 403698, 1 }, -- Flash of Light casts instantly, its healing done is increased by $s3%, but it now has a ${$s1/1000} sec cooldown.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- [385127] Your next Holy Power spending ability deals $s1% additional increased damage and healing. This effect stacks.
    penitence                       = { 92839, 403026, 1 }, -- Your damage over time effects deal $s1% more damage.
    quickened_invocation            = { 93181, 379391, 1 }, -- Divine Toll's cooldown is reduced by ${-$s1/1000} sec.
    righteous_cause                 = { 81523, 402912, 1 }, -- Templar's Verdict, Final Verdict and Justicar's Vengeance have a $h% chance to reset the cooldown of Blade of Justice.
    rush_of_light                   = { 81512, 407067, 1 }, -- The critical strikes of your damaging single target Holy Power abilities grant you $s1% Haste for $407065d.
    sanctify                        = { 92688, 382536, 1 }, -- Enemies hit by Divine Storm take $382538s1% more damage from Consecration and Divine Hammers for $382538d.
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your auto attacks deal ${$385723s1*(1+$s2/100)} additional Holy damage.
    searing_light                   = { 81552, 404540, 1 }, -- Your abilities that deal Radiant damage have a chance to call down an explosion of Holy Fire dealing $407478s2 Radiant damage to all nearby enemies and leaving a Consecration in its wake. ; Deals reduced damage beyond 8 targets.
    seething_flames                 = { 81549, 405355, 1 }, -- Wake of Ashes deals significantly reduced damage to secondary targets, but now causes you to lash out $s2 extra times for $405345s1 Radiant damage.
    shield_of_vengeance             = { 81544, 184662, 1 }, -- Creates a barrier of holy light that absorbs $<shield> damage for $d.; When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    swift_justice                   = { 81521, 383228, 1 }, -- Reduces the cooldown of Judgment by ${$s1/-1000} sec and Crusader Strike by ${$s2/-1000} sec.
    tempest_of_the_lightbringer     = { 92951, 383396, 1 }, -- Divine Storm projects an additional wave of light, striking all enemies up to $s1 yds in front of you for $s2% of Divine Storm's damage.
    templar_strikes                 = { 93186, 406646, 1 }, -- Crusader Strike becomes a 2 part combo.; Templar Strike slashes an enemy for $407480s1 $?s403664 [Holystrike][Radiant] damage. ; You have $406648d to continue the combo.; Templar Slash strikes an enemy for $406647s1 $?s403664[Holystrike][Radiant] damage and is always a critical strike.; Inherits Crusader Strike benefits.
    truths_wake                     = { 92686, 403696, 1 }, -- Wake of Ashes also causes targets to burn for an additional $403695o2 Radiant damage over $403695d.
    unbound_freedom                 = { 93174, 305394, 1 }, -- Blessing of Freedom increases movement speed by $m1%, and you gain Blessing of Freedom when cast on a friendly target.
    vanguard_of_justice             = { 93173, 406545, 1 }, -- Your damaging Holy Power abilities cost $s1 additional Holy Power and deal $s2% increased damage.
    vanguards_momentum              = { 92688, 383314, 1 }, -- Hammer of Wrath has $s1 extra charge and on enemies below $s2% health generates ${$403081s1} additional Holy Power.
    vengeful_wrath                  = { 93177, 406835, 1 }, -- Hammer of Wrath always critically strikes.
    wake_of_ashes                   = { 92854, 255937, 1 }, -- Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yds in front of you$?s403696[, reducing their movement speed by $403695s1% and burning them for $403695o2 Radiant damage over $403695d.] [ and reducing their movement speed by $403695s1% for $403695d.]; Demon and Undead enemies are also stunned for $255941d.; Generates $s2 Holy Power.
    zealots_fervor                  = { 92952, 403509, 1 }, -- Auto-attack speed increased by $s1%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning        = 756, -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain $s5 additional stack if you are the victim.; At $s2 stacks of Reckoning, your next $?a137029[Judgment deals $392885s1%][weapon swing deals $247677s1%] increased damage, will critically strike, and activates $?s231895[Crusade][Avenging Wrath] for $?s231895[$s4][$s3] sec.
    blessing_of_sanctuary    = 752, -- (210256) Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by $m2% for $d.
    blessing_of_spellwarding = 5573, -- (204018) Blesses a party or raid member, granting immunity to magical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.; Shares a cooldown with Blessing of Protection.
    hallowed_ground          = 5535, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure    = 5422, -- (355858) Casting Judgment on an enemy cleanses $s1 Poison, Disease, and Magic effect they have caused on you.
    lawbringer               = 754, -- (246806) Judgment now applies Lawbringer to initial targets hit for $246807d. Casting Judgment on an enemy causes all other enemies with your Lawbringer effect to suffer up to $246867s2% of their maximum health in Holy damage.
    luminescence             = 81, -- (199428) When healed by an ally, allies within your Aura gain $s2% increased damage and healing for $355575d.
    searing_glare            = 5584, -- (410126) Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    spreading_the_word       = 5572, -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.; $@spellicon1022 $@spellname1022; Physical damage reduced by $199507m1% for $199507d.; $@spellicon1044 $@spellname1044; Cleared of all movement impairing effects.
    ultimate_retribution     = 753, -- (355614) Mark an enemy player for retribution after they kill an ally within your Retribution Aura. If the marked enemy is slain within $355718d, cast Redemption on the fallen ally.
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
    -- Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=403876
    divine_protection = {
        id = 403876,
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


-- Tier 30
spec:RegisterGear( "tier30", 202455, 202453, 202452, 202451, 202450 )


spec:RegisterGear( "tier29", 200417, 200419, 200414, 200416, 200418 )

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
        id = 403876,
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
            removeDebuffStack( "target", "judgment" )
            removeDebuff( "target", "reckoning" )

            if buff.empyrean_power.up then
                removeBuff( "empyrean_power" )
            elseif buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
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

    -- Talent: Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the target area and causing them to take $s3% increased damage from your Holy Power abilities for $d.    |cFFFFFFFFPassive:|r $@spelldesc343723
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

        spend = 0.10,
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
        rangeSpell = 35395,
        cast = 0,
        charges = 2,
        cooldown = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
        recharge = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * haste end,
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
        rangeSpell = 35395,
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
            return ( talent.vanguard_of_justice.enabled and 4 or 3 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
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

--[[ Retired 20230426.
    spec:RegisterSetting( "desync_toll", false, {
    name = "Desync |T3565448:0|t Divine Toll",
    desc = "If checked, when Seraphim, Final Reckoning, and/or Execution Sentence are toggled off or disabled, the addon will recommend |T3565448:0|t Divine Toll despite being out of sync with your cooldowns.\n\n"
        .. "This is useful for maximizing the number of Divine Toll casts in a fight, but may result in a lower overall DPS.",
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterPack( "Retribution", 20230624, [[Hekili:T3XAtQTrYFlBDLXGJngPDXEZvlKkNtUQIR78hc5Q8nec0aOZcjojHxVPO43(1Zm6X8Ohjbs4Z1fxjvITMwD3t)E6z0WCR5)28zEUPK5FWEK9TJEJ9DdTEZOX2wZNL(0EY8z7Dx9r3nWFi0Dh8F)vsAS)YdP(rH0XEkiY1JIJKOdXRGXNpB5b)G0FjC(sCedGUNSA(hE7O5Z2675r4qsswnFgfYxn6nVY(U)6Pf)8NjRy050IzKWus4kYPfhsaE50cxV)9HKuI3PfRJIfaLe)8Ktl(D)GGHNE)P3ZX34xzDpGV)zum8Mpgf)XtlsJoTiGKciAPFGFQpbERKNak4j9iGRGhEAH)A4v2cVDe8FJZb5jyakq(jUldiEVonAZg6)NKUsM6VfO(VKsIbPbGcy(83)1x)J)oNICEXnii6r4b7jHEK4e(dxYMVuw6XT(buE3f4RWnztAgsKjevSbKA3(4OprKiJeCJUNbhxGynAOfqN9uDvImy2mWebqy8BFLnhn)l2iNwSpIRSGPWRIw)Q1(B2MwOWOZNvBjR(ygZVmkjrgzw5eB0W3cil2pkMjIriS1Tmy)zp)0mrvYH97JIbYT2p0pzlte6DiMjSExmWdEugmoAf881Xr7oTqWo(0IF8qSRafSZ5gjLgaF4hP2mP(7yiUpmtHHwZNnzZ3GOn(Rgme8nIJwdAT5ZCxrjsYW9XKvr7w6M(DtETB8k3qItAuCmyA)s)1tsDdG)0qG)DdCai)yuiLiVh7Tt26tc8CIw78js4gIl1ZafWp5g7tTnFj13Ds2eWXYz5H1RtE5NCdou80Hwd36MWgzyskWvBs3E8iYG7CbhV4Nqh7tGG3nL5BGo(w67IoYkqzFoZbB05GDvZb7kMd21mhSnohSV85GLZo3WdUbAkc)eGdd9x5Sj2NSgmswT9CWRnoETBlETCOrsEz0(jjKu)1zO3I))DibjKjJgo(LRIcbhtaNtYrZqflVE9lNRRIIc8IEmCi4U6sFRN9SIhTI75wm0KrhpACWN9Skqk9nBgnDPUuGNNZJWqBXjTbyQHdgCoYA7wlRTvL12xdzncsfL1vtZorwJYbNLSopxJQ02wuABjiRVXOHTjTWXJM1pvQGkhJM9AOB4toE7tkgFWl6BnC83vr8pacestnUgmyA)kDelhRj0gj)bgTTYOnnB7FjVYnAnoeiW7tSKRKSITaniTubAnwUFY1pGHNcflOoJjlp8rI4tuuWaUGCSozMVQ6xnZ7yYox)WKh(HSW5spvY1tWyilXDg0ImZkOQoh(F1jWpjLZu5unPEq3qcP1FebvZ8(sd6cemHxXfT6bgdR4QCy)XJstKd77j93tsHs7NybEB06x6XkGXjxgypgHIaNgqHkX5FFWBZUSsxGQwbUp1nEdjnzOcatNyF84nXU(EoGggeuUEEjdjFgMKGxH6Z9dN(2X6p(WECMzTpyceef51Azao(HQVD8tj74Qd3aycU1n2z)H)4pciolJ(mLU9nfRkxuoU3nYgjIrdKnrbyLbDqV(BJcEYzF0JK4PtGHHx4bqej(0BzpD64b1mlscIsZJ6zXyDCzwVAMrtVBudfRa7FJCWPCuJMJid)irlZJrpXAGyMC0attNizkFgcf7V4cfldcfRZsOypquC2XcfMLI5uE9XgIxaAM8qnfoqmzbd9jdqluPyURtKImR3Ok0nfxFQ9OCOpFTR9OZX7YgxMzBwMz3ozgM9IrD2xpYmwC1KTUWaepNy3)GIe3Wq)Tq6EiXhZF8ISlUu7jdCmYsUP8MKp1uld5mLfp03tm69Dvgtx(P25Ph88)KFiXX9WNHvQ6g)emB5dqYBfMtswtZ6vMGsFWCjIun3MbdMIhpYNIyqL3kmA4i0(ziWlkJGYigGz6TJk4cvqkybdkY8AbZlyqT2VnR8Gfj)5oiTRU8Hzn3Cxpl1ekLfSvNNhljJeV2q7Ob941XvuyINpz69)F1eSpYm0YMAXQpX7P6vrItCE0piWGoxXAKjpq81Vh1qAY9nFoOurzpdfTuVGuWvsnNJMZCbXmQrVDupn9pMoEkTmOccxKtRW3fuszQHT73mDKOCzstdjoqCrtf9fwBrIEq5xUatrFaFDHYRNjdTjq2ODSfZWMnKD7FkgsdW5c2cu(l0oQ75V2NUAwHM6)tZ0BNpHUjauBfAJOZ71lSs3WNNsbK93y9TyhDdb8OnZoRj6V7NOi2FtiDXvaQ8t3EAXpMP5oT43zQo85T4mHAzwKcuqe07g5PxazJ7QNOEX3WnXYLYXlHe4Xf14Q8yUs2(oDlvKUkLB8aHEFXTcVHIZuHzOQIUbjmOO2U2CgqzbnXTIvmwD(v8jttwrWdwILjjQWO7XL)kxiKJurhFvjsvLyFzey4YlOIY9bCXvSN)Q0VjSYewLIRYwkzSRtfs0xMa1gVkDILCfR0aW99imsL3LhwyEbqahFXWcXKKOqQ5RuNCK4LhD)iHwETlq6ezc(aeJVUMSywTQl1RoDNw2otjPknu0leQzftFhwrh0IdAqf2geJzc80OGaDH4n6ATAfSSk(nxb34RL494r5(rEVPz8Lzetl6QHopOunluJtsayWwSyIINc08JKeXfv0RYQkmqfXUSIQ8e1V3wQkwgDi0lGKu2g2bxe9xgaIcQxjpterPEwjAYEm7fUmAT1fk2jMsSIvj33mEEqiA6s6mL45ScqXEaXhpMaRNFzu4HeWXIeF7iN72VAGM0kZ3BlXnamq3VkL3SJmS(j3WnhCJHAJ2frLGh2zYc8STfAI22qlxohnUKJgflzSYzOSRvx3KPs7mC7a3((AAAiA4i8oTHSJbMk53iRbpHSkM12vMaq8b0z)L4EKbf3lrFxxAgsYMt5gLu0OgApFSHG3eG6eN1XCu5galAB4BhlR7Sft7dQYYkxunNuRfsSAHM(wLWvymjn(fAS0e)66GHj0AG3qJn8BEyYwgwRz2kgGs(Gm1ahIMyEpFg9q4aaLD2bhBD)8zp6gtlPoz(SFJU5W(7YoWx0Ti(5EK1UhcsFoDvZ)Nd(X0LmNer3jz3dPr7Cz7WmyrdRIIESZ(haToTGE82Exuiql2WpxUWKNZxVTYthsczLNaJ236ZdyhAme(P4qhCECKfohPSQcfotDnhACih33QIBZ7BFbbYajfhMog90nfGc3fG5SZZvv8DjiDlYBbxlCsZQIZLbR7jslMbSZcxv8EoaDjIBb)spHEvXUzJ3HO1eZENbSICcE0WmomDm6BbJBYHbfKUf5TGRRYrXiyDprAXma3PbbGUeXTGFrDB0hVdrRjMDSrFCKJmlINoousK4ngz8MqctqjrI3ACwuu2C(PbbzoGbZvf9xne)n((pf8D0EchIeO67qal1FCZXWF7pd0yyv8qqxdvnCcNpVtbnopmixaFHIMluY0kbtDZ5gjxQtSuytDVXWY1BSIdJKVqxJ(RgI)gF)Nc(U(yMAF2iy4VdIzwZhosnuTnXgQHhmhZSzIMluY0kbtDZ5gjxQtSuyt99DSXQIVqxJ(gGy0tmncYnbxd5)MsgQzMZ5J(MU0(k7Cq7rVPfzzcZxADHxz03ae3m9Pz4Ai)3uYCrMnnV)SxKztZrFdnB0YGDL(y8qJZAYhv5tHtXrOHFcEOvdBs9QsrRAPy(hExU4)lOC71FXLBV(ki3gMTtpRJONRt2PT0fWkyh(iHErkWpBNuBY8VErF61gaD)gpTy5H0C4cJyBt0HqjO98Oa75M6U0nH8xp9(tlE1Pf8pPC0TykFoN88ZAlM0AG2fTPxDpUm1co5VAmdPCegUHiTWIjB)JRQsIsqUIiVw0288ankDt7jtLPBm1UtRQvNAd3qKwRehfKRiYRfTnVAWgPoBpzQuDAQNExMT(vf51UM6ltH2WfSFziV2YOUmrrdRr7Yq(vcTFz4zldN0c1J2Tsom1HnLmZe61pqVkea5e)EMKOtoRiwAB6D3kEmu4Wvg9AFexMe(5JBKaAjp7w(3a6VO6Q(IGSwpXrRWT48598ZQc3U5yDvjU6eNmd4U1YYUxkyiAqxIRorIEDJA1LsHUCLtgWvNirVUbQ7gPaASJYdx6xDbp6sC1Hfu0LM3DjU0wzd)T0pW0kOvhatuqB9hCeu(roOG5YbmHrTvhKXskFOkQCSYWNj21pz3k4xhaJ55hD1f6Mib3Aq4Rvb1Ary8ZTa5wOwTm4f2HIf7RVK32GGPtSFo9(FHfhMI4XYnbLgKD(mi272O45ZM5V7DZNXEo7kiMFa(H)4hyxjXziE(FJF1ah7VNIO5Zo77lU87F15Z43wCZtN)bBfkeTF(m2fdxjW5TbM9NC4x9Xk3vxZNr7olbGdgcnug9LZVZ4MpBu2FfEV81LMdF26tpT4HFG2Q41AxljuU(wfUoNvv)4w4s1mEUOlXumC3LGHYmPaksP3RTzFAdy6knjIH6mkPT8hqsH2jFyK7DhrcIiwYuM4QsM4xPBJ5n))0IJhpT4l7GsMxCqY3ggmf2zm3SRIj(Imi2CZUCUn(YNBOh4wCrj)s1IsV3C50d903Ip9kP3BVWGmfSoDBNe9OmTFDNw0dc)kzIPTFyNw8mOwx1WoLJo50IrCLzfa9S6OrjwAoVy40OGYsgHTHC2aLaYdhxORTOQS7BNkZUEvMTbvgYMM25QmuAGOYQLx6CvwfCwDQSVVDQS8BqrrL2nNwuPRMzLkDMxNkVwT(RLaqAxzaXXPfVGHdRHq1vFxfbMlG0WwOZGa(3PACfQd0RLaOXCLAQqZCLLaxjRZTk0428kqeQiPYsqk)UyzwtJ5kO(0Fwhy1yj8bPZhs5fUJXn9YQid5Qmbm1sPFL5uMOzftv0stSYqX58haoXo36XKFvrbKOXdKgfmVXRwLrdoJB6Y7ilsrTVErGOI3Bq(mOK8MBnHY0W8nOcZ89UCUs9MubKDWIL5JMXyvCJQWS7YvIs3gnyvzwNU6gCRSgQfNsB1EDktbG(FJoL(EYxQSzcCbbPW9rdwbT4IXPGy82spVCkNjaLEg7AAHrxRrT0DuTG0sEJrrd3NhmANDPrYypZ3ld8jMDjVjDbdGvJQusjZ2tQMG3QAvyU5a5EMNbxNJcSIClz4MWw6DC5cyh1BmcSc5KyRQW9dm)xfHNH2YXHd7QMriCNbzG2D0aZD2EKkTn3YfjVmLlfcScJoFR5kStbFTkmuzeq7AvPdnwRRvG42QwnRsHgAPwTbOL5C7xrpzdZBZ5U6JAjYYILzkAsxwmMyW5IhQF7yszUwfD2YCQJBOzjLUHDo3yiIVoJyMZfCgyv(onHIwZX3vtZxX1WdNo0RIhtwn26LZ(qrk1ckz6Q2HfkQiJ2lqrhV64lfBIVN6f5dg8cg2kIhMuvnj0fyCDVyphLd3j3TrRVhfsoZidQT5GKTWnh3h3(SJT1(mqvM(XwQlUQAnfb1TIWQ0qyfqVtcTIUTkaoweqLBxiritfnfqwoz9TjS2icvfyuSPecxdVylpuzYWOGYUJ81Y9pmApWeME5lrswMuCxdNpCF5LExENdRTQCP7DyUL8DOl6uBbo1UglXyr3IItd7XH0cRmDKiuyad3FSMcjNT0mt3NXnzXH9XZXt5g5a1vSwvDreA5bvT2nAq(kxM9)hRfRwb91G2rmPJ2vsD1RR)B6TVk0BQxn28mF5Srnns9SweGb(zc3lN9krj82HR38iiTDblZ)1nR6gLw5p9ysPFbLf(pcz8H1)HiJPdE7y8HPjUZ5tfQwDySotuws)IFe0WCelQQs)3UmfV0AnjFG1c9E16px2AF5ZlHagm96OTnz6KIxJDwpEOOv(49mKd1ugudY)zRgB(J0ZVc3f(UsyPiJQOZg1k(ODQE0fOOvc6jVFp5unlAhYglj17FTDDP8NzzkTkcYyEREOIzj3wWhmikvqIH0gtfPQ9xVsvRQKQ6F4onrQARlv12wV6KQ2y9ATkB1BQzpm5tBeq4NFbbbQPmyssw(tlKO1AhIrBPDr9gC1zLLkiS21wArzZ34zDdB1(kxLHDLZrZQa7owfyYOTslKVovb2y91oxfuXpICQD8SvwNDKrErIPQ47Q70Us1tSTduuEOFW5AEtWNw0GVZpNlgu2IP9nxnEMKT(9hUN8(Ow1oepr)qPuZgkNVRQzRUU69mol0EnRfrHFnUqdeMTQfLC7ijo1CFagi1evz)UA2VcPGaIfdkUPNDBjBkTnS(nX4sIvzHv2G(IvAsWkPYjqMHTWJiFdV0pBdaDVVuuPBKwZMM8NaPwFJcol7C3wC5Qivm(vHkzQAq(BEFKqMZkbCVVbEmtmc25kPUOUeMVY1MOUvIvz80Oihr1aZuPnkLsftknlCtwVtlxxGaBwuELuO0cZRYFKczuEKUUysBZjoqCL(sX3NNw8pZ)Vd]] )
