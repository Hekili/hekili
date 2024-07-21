-- RogueSubtlety.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 261 )

-- Resources
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )

spec:RegisterTalents( {
    -- Rogue Talents
    acrobatic_strikes          = { 90752, 455143, 1 }, -- Auto-attacks increase auto-attack damage and movement speed by ${$s1/10}.1% for $455144d, stacking up to ${$s1/10*$455144u}%.
    airborne_irritant          = { 90741, 200733, 1 }, -- Blind has $s1% reduced cooldown, $s2% reduced duration, and applies to all nearby enemies.
    alacrity                   = { 90751, 193539, 2 }, -- Your finishing moves have a $s2% chance per combo point to grant $193538s1% Haste for $193538d, stacking up to $193538u times.
    atrophic_poison            = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $h% chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    blackjack                  = { 90686, 379005, 1 }, -- Enemies have $394119s1% reduced damage and healing for $394119d after Blind or Sap's effect on them ends.
    blind                      = { 90684, 2094  , 1 }, -- Blinds $?a200733[all enemies near ][]the target, causing $?a200733[them][it] to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    cheat_death                = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to $s2% of your maximum health. For $45182d afterward, you take $45182s1% reduced damage. Cannot trigger more often than once per $45181d.
    cloak_of_shadows           = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cold_blood                 = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by $s1%.
    deadened_nerves            = { 90743, 231719, 1 }, -- Physical damage taken reduced by $s1%.; 
    deadly_precision           = { 90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by $s1%.
    deeper_stratagem           = { 90750, 193531, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    echoing_reprimand          = { 90639, 385616, 1 }, -- Deal $s1 Physical damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.; 
    elusiveness                = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by $s2%, and Feint also reduces non-area-of-effect damage taken by $s1%.
    evasion                    = { 90764, 5277  , 1 }, -- Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    featherfoot                = { 94563, 423683, 1 }, -- Sprint increases movement speed by an additional $s1% and has ${$s2/1000} sec increased duration.
    fleet_footed               = { 90762, 378813, 1 }, -- Movement speed increased by $s1%.
    gouge                      = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.; Must be in front of your target.; Awards $s2 combo $lpoint:points;.
    graceful_guile             = { 94562, 423647, 1 }, -- Feint has $m1 additional $Lcharge:charges;.; 
    improved_ambush            = { 90692, 381620, 1 }, -- $?s185438[Shadowstrike][Ambush] generates $s1 additional combo point.
    improved_sprint            = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by ${$m1/-1000} sec.
    improved_wound_poison      = { 90637, 319066, 1 }, -- Wound Poison can now stack $s1 additional times.
    iron_stomach               = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by $s1%.
    leeching_poison            = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you $108211s1% Leech.
    lethality                  = { 90749, 382238, 2 }, -- Critical strike chance increased by $s1%. Critical strike damage bonus of your attacks that generate combo points increased by $s2%.
    master_poisoner            = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%.
    nimble_fingers             = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1.
    numbing_poison             = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $5761h% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $5760s1% for $5760d.
    recuperator                = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per $426605t sec.
    resounding_clarity         = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges $m1 additional combo $Lpoint:points;.
    reverberation              = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by $s1%.
    rushed_setup               = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%.
    shadowheart                = { 101714, 455131, 1 }, -- Leech increased by $s1% while Stealthed.; 
    shadowrunner               = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster.
    shadowstep                 = { 90695, 36554 , 1 }, -- Description not found.
    shiv                       = { 90740, 5938  , 1 }, -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    soothing_darkness          = { 90691, 393970, 1 }, -- You are healed for ${$393971s1*($393971d/$393971t)}% of your maximum health over $393971d after gaining Vanish or Shadow Dance.
    stillshroud                = { 94561, 423662, 1 }, -- Shroud of Concealment has $s1% reduced cooldown.; 
    subterfuge                 = { 90688, 108208, 2 }, -- Abilities and combat benefits requiring Stealth remain active for ${$s2/1000} sec after Stealth breaks.
    superior_mixture           = { 94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional $s1%.
    thistle_tea                = { 90756, 381623, 1 }, -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    tight_spender              = { 90692, 381621, 1 }, -- Energy cost of finishing moves reduced by $s1%.
    tricks_of_the_trade        = { 90686, 57934 , 1 }, -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    unbreakable_stride         = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects $s1%.
    vigor                      = { 90759, 14983 , 2 }, -- Increases your maximum Energy by $s1 and Energy regeneration by $s2%.
    virulent_poisons           = { 90760, 381543, 1 }, -- Increases the damage of your weapon poisons by $s1%.
    without_a_trace            = { 101713, 382513, 1 }, -- Vanish has $s1 additional $lcharge:charges;.

    -- Subtlety Talents
    bait_and_switch            = { 95106, 457034, 1 }, -- Evasion reduces magical damage taken by $5277s3%. ; Cloak of Shadows reduces physical damage taken by $31224s3%.
    clear_the_witnesses        = { 95110, 457053, 1 }, -- Your next $?c1[Fan of Knives][Shuriken Storm] after applying Deathstalker's Mark deals an additional $457179s1 Plague damage and generates $457178s1 additional combo point.
    cloaked_in_shadows         = { 90733, 382515, 1 }, -- Vanish grants you a shield for $386165d, absorbing damage equal to $s1% of your maximum health.
    cloud_cover                = { 95116, 441429, 1 }, -- Distract now also creates a cloud of smoke for $441587d. Cooldown increased to $s2 sec.; Attacks from within the cloud apply Fazed.
    corrupt_the_blood          = { 95108, 457066, 1 }, -- Rupture deals an additional $457133s2 Plague damage each time it deals damage, stacking up to $457133u times. Rupture duration increased by ${$s1/1000} sec.
    coup_de_grace              = { 95115, 441423, 1 }, -- After $441786s1 strikes with Unseen Blade, your next $?a137036[Dispatch][Eviscerate] will be performed as a Coup de Grace, functioning as if it had consumed $s3 additional combo points.; If the primary target is Fazed, gain $s2 stacks of Flawless Form.
    danse_macabre              = { 90730, 382528, 1 }, -- Shadow Dance increases the damage of your attacks that generate or spend combo points by $393969s1%, increased by an additional $393969s1% for each different attack used.
    dark_brew                  = { 90719, 382504, 1 }, -- Your attacks that deal Nature or Bleed damage now deal Shadow instead.; Shadow damage increased by $s2%.
    dark_shadow                = { 90732, 245687, 2 }, -- Shadow Dance increases damage by an additional $s1%.
    darkest_night              = { 95142, 457058, 1 }, -- When you consume the final Deathstalker's Mark from a target or your target dies, gain $457280s1 Energy and your next $?c1[Envenom][Eviscerate] cast with maximum combo points is guaranteed to critically strike, deals $457280s2% additional damage, and applies $457280s3 stacks of Deathstalker's Mark to the target.
    deathstalkers_mark         = { 95136, 457052, 1 }, -- $?c1[Ambush][Shadowstrike] from Stealth$?c3[ or Shadow Dance][] applies $s1 stacks of Deathstalker's Mark to your target. When you spend $s2 or more combo points on attacks against a Marked target you consume an application of Deathstalker's Mark, dealing $457157s1 Plague damage and increasing the damage of your next $?c1[Ambush or Mutilate]?s200758[Gloomblade or Shadowstrike][Backstab or Shadowstrike] by $457160s1%.; You may only have one target Marked at a time.
    deepening_shadows          = { 90724, 185314, 1 }, -- Your finishing moves reduce the remaining cooldown on Shadow Dance by ${$sw1/10}.1 sec per combo point spent.
    deeper_daggers             = { 90721, 382517, 1 }, -- Eviscerate and Black Powder increase your Shadow damage dealt by $383405s1% for $383405d.
    devious_distractions       = { 95133, 441263, 1 }, -- $?a137036[Killing Spree][Secret Technique] applies Fazed to any targets struck.
    disorienting_strikes       = { 95118, 441274, 1 }, -- $?a137036[Killing Spree][Secret Technique] has $s1% reduced cooldown and allows your next $s2 strikes of Unseen Blade to ignore its cooldown.
    dont_be_suspicious         = { 95134, 441415, 1 }, -- Blind and Shroud of Concealment have $s1% reduced cooldown.; Pick Pocket and Sap have $s2 yd increased range.
    double_dance               = { 101715, 394930, 1 }, -- Shadow Dance has $s1 additional charge.
    ephemeral_bond             = { 90725, 426563, 1 }, -- Increases healing received by $s1%.; 
    ethereal_cloak             = { 95106, 457022, 1 }, -- Cloak of Shadows duration increased by ${$s1/1000} sec.
    exhilarating_execution     = { 90711, 428486, 1 }, -- Your finishing moves heal you for $s1% of damage done. At full health gain shielding instead, absorbing up to $s2% of your maximum health.
    fade_to_nothing            = { 90733, 382514, 1 }, -- Movement speed increased by $386237s1% and damage taken reduced by $386237s2% for $386237d after gaining Stealth, Vanish, or Shadow Dance.
    fatal_intent               = { 95135, 461980, 1 }, -- Your damaging abilities against enemies above $M3% health have a very high chance to apply Fatal Intent. When an enemy falls below $M3% health, Fatal Intent inflicts ${$s1*(1+$@versadmg)} Plague damage per stack.
    finality                   = { 90720, 382525, 2 }, -- Eviscerate, Rupture, and Black Powder increase the damage of the next use of the same finishing move by $s1%.
    find_weakness              = { 90690, 91023 , 1 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass $s1% of that enemy's armor for $316220d.
    flagellation               = { 90718, 384631, 1 }, -- Lash the target for $s1 Shadow damage, causing each combo point spent within $d to lash for an additional $345316s1. Dealing damage with Flagellation increases your Mastery by ${$s2*$mas}.1%, persisting $345569d after their torment fades.
    flawless_form              = { 95111, 441321, 1 }, -- Unseen Blade and $?a137036[Killing Spree][Secret Technique] increase the damage of your finishing moves by $441326s1% for $441326d.; Multiple applications may overlap.
    flickerstrike              = { 95137, 441359, 1 }, -- Taking damage from an area-of-effect attack while Feint is active or dodging while Evasion is active refreshes your opportunity to strike with Unseen Blade.; This effect may only occur once every $proccooldown sec.
    follow_the_blood           = { 95131, 457068, 1 }, -- $?s51723[Fan of Knives]$?s197835[Shuriken Storm] and $?s121411[Crimson Tempest]$?s319175[Black Powder] deal $s1% additional damage while $s2 or more enemies are afflicted with Rupture.
    gloomblade                 = { 90699, 200758, 1 }, -- Punctures your target with your shadow-infused blade for $s1 Shadow damage, bypassing armor.$?s319949[ Critical strikes apply Find Weakness for $319949s1 sec.][]; Awards $s2 combo $lpoint:points;.
    goremaws_bite              = { 94581, 426591, 1 }, -- Lashes out at the target, inflicting $426592s1 Shadow damage and causing your next $426593u finishing moves to cost no Energy.; Awards $426593s1 combo $lpoint:points;.
    hunt_them_down             = { 95132, 457054, 1 }, -- Auto-attacks against Marked targets deal an additional $457193s1 Plague damage.
    improved_backstab          = { 90739, 319949, 1 }, -- $?s200758[Gloomblade][Backstab] has $s2% increased critical strike chance.; When you are behind your target, Backstab critical strikes now also expose a flaw in their defenses, applying Find Weakness for $s1 sec.
    improved_shadow_dance      = { 90734, 393972, 1 }, -- Shadow Dance has ${$s1/1000} sec increased duration.
    improved_shadow_techniques = { 90736, 394023, 1 }, -- Shadow Techniques generates $s1 additional Energy.
    improved_shuriken_storm    = { 90710, 319951, 1 }, -- Shuriken Storm has an additional $s2% chance to crit, and its critical strikes apply Find Weakness for $s1 sec.
    inevitability              = { 90704, 382512, 1 }, -- $?S200758[Gloomblade][Backstab] and Shadowstrike extend the duration of your Symbols of Death by ${$s2/10}.1 sec.
    invigorating_shadowdust    = { 90706, 382523, 2 }, -- Vanish reduces the remaining cooldown of your other Rogue abilities by ${$s1}.1 sec.
    lingering_darkness         = { 95109, 457056, 1 }, -- After $?c1[Deathmark][Shadow Blades] expires, gain $457273d of $457273s1% increased $?c1[Nature][Shadow] damage.
    lingering_shadow           = { 90731, 382524, 1 }, -- After Shadow Dance ends, $?s200758[Gloomblade][Backstab] deals an additional $s1% damage as Shadow, fading by ${$s1/$s3}.1% per sec.
    master_of_shadows          = { 90735, 196976, 1 }, -- Gain ${$196980s1*$196980d/$196980t1+$196980s2} Energy over $196980d when you enter Stealth or activate Shadow Dance.
    mirrors                    = { 95141, 441250, 1 }, -- Feint reduces damage taken from area-of-effect attacks by an additional $s1%
    momentum_of_despair        = { 95131, 457067, 1 }, -- If you have critically struck with $?s51723[Fan of Knives]$?s197835[Shuriken Storm], increase the critical strike chance of $?s51723[Fan of Knives]$?s197835[Shuriken Storm] and $?s121411[Crimson Tempest]$?s319175[Black Powder] by $457115s1% for $457115d.
    night_terrors              = { 94582, 277953, 1 }, -- Shuriken Storm reduces enemies' movement speed by $206760s1% for $206760d.
    nimble_flurry              = { 95128, 441367, 1 }, -- $?a137036[Blade Flurry damage is increased by $s1%]?s200758[Your auto-attacks, Backstab, Shadowstrike, and Eviscerate also strike up to $s2 additional nearby targets for $s3% of normal damage][Your auto-attacks, Backstab, Shadowstrike, and Eviscerate also strike up to $s2 additional nearby targets for $s3% of normal damage] while Flawless Form is active.
    no_scruples                = { 95116, 441398, 1 }, -- Finishing moves have $s1% increased chance to critically strike Fazed targets.
    perforated_veins           = { 90707, 382518, 1 }, -- After striking $s1 times with $?s200758[Gloomblade][Backstab], your next attack that generates combo points deals $426602s1% increased damage.
    planned_execution          = { 90703, 382508, 1 }, -- Symbols of Death increases your critical strike chance by $s1%.
    premeditation              = { 90737, 343160, 1 }, -- After entering Stealth, your next combo point generating ability generates full combo points.
    quick_decisions            = { 90728, 382503, 1 }, -- Shadowstep's cooldown is reduced by $s3%, and its maximum range is increased by $s1%.
    relentless_strikes         = { 90709, 58423 , 1 }, -- Your finishing moves generate $98440s2 Energy per combo point spent.
    replicating_shadows        = { 90717, 382506, 1 }, -- Rupture deals an additional $s1% damage as Shadow and applies to $s4 additional nearby enemy.
    secret_stratagem           = { 90722, 394320, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    secret_technique           = { 90715, 280719, 1 }, -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets.;    1 point  : ${$280720m1*1*$<mult>} total damage;    2 points: ${$280720m1*2*$<mult>} total damage;    3 points: ${$280720m1*3*$<mult>} total damage;    4 points: ${$280720m1*4*$<mult>} total damage;    5 points: ${$280720m1*5*$<mult>} total damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$280720m1*6*$<mult>} total damage][]$?s193531&(s394320|s394321)[;    7 points: ${$280720m1*7*$<mult>} total damage][]; Cooldown is reduced by $s5 sec for every combo point you spend.
    sepsis                     = { 90704, 385408, 1 }, -- Infect the target's blood, dealing $o1 Nature damage over $d and gaining $s6 use of any Stealth ability. If the target survives its full duration, they suffer an additional $394026s1 damage and you gain $s6 additional use of any Stealth ability for $375939d.; Cooldown reduced by $s3 sec if Sepsis does not last its full duration.; Awards $?a121471[${$s7+$121471s4}][$s7] combo $lpoint:points;.
    shadewalker                = { 95123, 457057, 1 }, -- Each time you consume a stack of Deathstalker's Mark, reduce the cooldown of Shadowstep by ${$s1/-1000} sec.
    shadow_blades              = { 90726, 121471, 1 }, -- Draws upon surrounding shadows to empower your weapons, causing your attacks to deal $s1% additional damage as Shadow and causing your combo point generating abilities to generate full combo points for $d.
    shadow_focus               = { 90727, 108209, 1 }, -- Abilities cost $112942m1% less Energy while Stealth or Shadow Dance is active.
    shadowcraft                = { 94580, 426594, 1 }, -- While Symbols of Death is active, your Shadow Techniques triggers $s3% more frequently, stores $m2 additional combo $Lpoint:points;, and finishing moves can use those stored when there are enough to refresh full combo points.
    shadowed_finishers         = { 90723, 382511, 1 }, -- Eviscerate and Black Powder deal an additional $s1% damage as Shadow to targets with your Find Weakness active.
    shot_in_the_dark           = { 90698, 257505, 1 }, -- After entering Stealth or Shadow Dance, your next Cheap Shot is free.
    shroud_of_night            = { 95123, 457063, 1 }, -- Shroud of Concealment duration increased by ${$s1/1000} sec.
    shrouded_in_darkness       = { 90700, 382507, 1 }, -- Shroud of Concealment increases the movement speed of allies by $s1% and leaving its area no longer cancels the effect.
    shuriken_tornado           = { 90716, 277925, 1 }, -- Focus intently, then release a Shuriken Storm every sec for the next $d. 
    silent_storm               = { 90714, 385722, 1 }, -- Gaining Stealth, Vanish, or Shadow Dance causes your next Shuriken Storm to have $385727s1% increased chance to critically strike.
    singular_focus             = { 95117, 457055, 1 }, -- Damage dealt to targets other than your Marked target deals $s1% Plague damage to your Marked target.; 
    smoke                      = { 95141, 441247, 1 }, -- You take $s1% reduced damage from Fazed targets.
    so_tricky                  = { 95134, 441403, 1 }, -- Tricks of the Trade's threat redirect duration is increased to $m1 $Lhour:min;.
    surprising_strikes         = { 95121, 441273, 1 }, -- Attacks that generate combo points deal $s1% increased critical strike damage to Fazed targets.
    swift_death                = { 90701, 394309, 1 }, -- Symbols of Death has ${$s1/-1000} sec reduced cooldown.
    symbolic_victory           = { 95109, 457062, 1 }, -- $?a137037 [Shiv][Symbols of Death] additionally increases the damage of your next $?a137037 [Envenom][Eviscerate or Black Powder] by $s1%.
    terrifying_pace            = { 94582, 428387, 1 }, -- Shuriken Storm increases your movement speed by $428389s1% for $428389d when striking $s1 or more enemies.
    the_first_dance            = { 90735, 382505, 1 }, -- Activating Shadow Dance generates $394029s1 combo points.
    the_rotten                 = { 90705, 382015, 1 }, -- After activating Symbols of Death, your next $@switch<$s1>[attack][$s1 attacks] that $@switch<$s1>[generates][generate] combo points $@switch<$s1>[deals][deal] $394203s3% increased damage and $@switch<$s1>[is][are] guaranteed to critically strike.
    thousand_cuts              = { 95137, 441346, 1 }, -- Slice and Dice grants $s1% additional attack speed and gives your auto-attacks a chance to refresh your opportunity to strike with Unseen Blade.
    unseen_blade               = { 95140, 441146, 1 }, -- $?a137036[Sinister Strike]?s200758[Gloomblade][Backstab] and $?a137036[Ambush][Shadowstrike] now also strike with an Unseen Blade dealing $441144s1 damage. Targets struck are Fazed for $441224d.; Fazed enemies take $441224s1% more damage from you and cannot parry your attacks.; This effect may occur once every $459485d.
    veiltouched                = { 90713, 382017, 1 }, -- Your abilities deal $s1% increased magic damage.
    warning_signs              = { 90703, 426555, 1 }, -- Symbols of Death increases your Haste by $s1%.
    weaponmaster               = { 90738, 193537, 1 }, -- $?s200758[Gloomblade][Backstab] and Shadowstrike have a $s1% chance to hit the target twice each time they deal damage$?a134735[, striking for $s3% of normal damage][].
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5529, -- (354406) Cheap Shot grants Slice and Dice for $s1 sec and Kidney Shot restores $s2 Energy per combo point spent.
    dagger_in_the_dark = 846 , -- (198675) Each second while Stealth is active, nearby enemies within $198688A1 yards take an additional $198688s1% damage from you for $198688d. Stacks up to $198688u times.
    death_from_above   = 3462, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack.; You leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $269512s2% stronger effect.
    dismantle          = 5406, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for $d.
    distracting_mirage = 5411, -- (354661) Distract slows affected enemies by $354812s1% and creates a Mirage that follows an enemy for $354812d. Reactivate Distract to teleport to your Mirage's location. 
    maneuverability    = 3447, -- (197000) Sprint has $s1% reduced cooldown and $s2% reduced duration.
    shadowy_duel       = 153 , -- (207736) You lock your target into a duel contained in the shadows, removing both of you from the eyes of onlookers for $d.; Allows access to Stealth-based abilities.
    silhouette         = 856 , -- (197899) Shadowstep's cooldown is reduced by $s1% when cast on a friendly target.
    smoke_bomb         = 1209, -- (359053) Creates a cloud of thick smoke in an $m2 yard radius around the Rogue for $d. Enemies are unable to target into or out of the smoke cloud. 
    thick_as_thieves   = 5409, -- (221622) Tricks of the Trade now increases the friendly target's damage by $m1% for $59628d.
    thiefs_bargain     = 146 , -- (354825) The cooldowns of Shadow Blades, Vanish, and Feint are reduced by $s1%, but using one reduces your damage by $354827s1% for $354827d.
    veil_of_midnight   = 136 , -- (198952) Cloak of Shadows now also removes harmful physical effects.
} )

-- Auras
spec:RegisterAuras( {
    -- Auto-attack damage and movement speed increased by ${$W}.1%.
    acrobatic_strikes = {
        id = 455144,
        duration = 3.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    alacrity = {
        id = 193538,
        duration = 15.0,
        max_stack = 1,
    },
    -- Envenom consumes stacks to amplify its damage.
    amplifying_poison = {
        id = 383414,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- envenom[32645] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Damage reduced by ${$W1*-1}.1%.
    atrophic_poison = {
        id = 392388,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- master_poisoner[378436] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $w1% reduced damage and healing.
    blackjack = {
        id = 394119,
        duration = 6.0,
        max_stack = 1,
    },
    -- Disoriented.
    blind = {
        id = 2094,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- airborne_irritant[200733] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- airborne_irritant[200733] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -70.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- dont_be_suspicious[441415] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Stunned.
    cheap_shot = {
        id = 1833,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- All damage taken reduced by $s1%.
    cheating_death = {
        id = 45182,
        duration = 3.0,
        max_stack = 1,
    },
    -- Resisting all harmful spells.$?a457034[ Physical damage taken reduced by $w3%.][]
    cloak_of_shadows = {
        id = 31224,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- ethereal_cloak[457022] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Absorbing $w1 damage.
    cloaked_in_shadows = {
        id = 341530,
        duration = 4.0,
        max_stack = 1,
    },
    -- Critical strike chance of your next damaging ability increased by $s1%.
    cold_blood = {
        id = 382245,
        duration = 3600,
        max_stack = 1,
    },
    -- $@auracaster's Rupture corrupts your blood, dealing $s2 Plague damage.
    corrupt_the_blood = {
        id = 457133,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- dark_brew[382504] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dark_brew[382504] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Healing for ${$W1}.2% of maximum health every $t1 sec.
    crimson_vial = {
        id = 354494,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- iron_stomach[193546] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- nimble_fingers[378427] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ephemeral_bond[426563] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- drink_up_me_hearties[354425] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement slowed by $w1%.
    crippling_poison = {
        id = 3409,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- master_poisoner[378436] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- superior_mixture[423701] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.5, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Being stalked by a rogue.; The rogue deals an additional $m1% damage.
    dagger_in_the_dark = {
        id = 198688,
        duration = 10.0,
        max_stack = 1,
    },
    -- Attacks that generate or spend combo points deal $w1% increased damage.
    danse_macabre = {
        id = 393969,
        duration = 3600,
        max_stack = 1,
    },
    -- Your next $?c1[Envenom][Eviscerate] cast with maximum combo points is guaranteed to critically strike, deal $w2% additional damage, and apply $w3 stacks of Deathstalker's Mark to the target.
    darkest_night = {
        id = 457280,
        duration = 30.0,
        max_stack = 1,
    },
    -- Suffering $w1 Nature damage every $t1 seconds.
    deadly_poison = {
        id = 2818,
        duration = 12.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- virulent_poisons[381543] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veiltouched[382017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- envenom[32645] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Shadow damage dealt increased by ${$w1}.1%.
    deeper_daggers = {
        id = 341550,
        duration = 8.0,
        max_stack = 1,
    },
    -- Detecting traps.
    detect_traps = {
        id = 2836,
        duration = 0.0,
        max_stack = 1,
    },
    -- Detecting certain creatures.
    detection = {
        id = 56814,
        duration = 30.0,
        max_stack = 1,
    },
    -- Disarmed.
    dismantle = {
        id = 207777,
        duration = 5.0,
        max_stack = 1,
    },
    -- Movement slowed by $w1%.
    distracting_mirage_slow = {
        id = 354812,
        duration = 8.0,
        max_stack = 1,
    },
    -- Rogue's second combo point is Animacharged. ; Damaging finishing moves using exactly 2 combo points deal damage as if 7 combo points are consumed.
    echoing_reprimand = {
        id = 323558,
        duration = 45.0,
        max_stack = 1,

        -- Affected by:
        -- reverberation[394332] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_blades[121471] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Poison application chance increased by $s2%.$?a455072[ Envenom damage increased by $s3%.][]$?s340081[; Poison critical strikes generate $340426s1 Energy.][]$?a393724[ Poison damage increased by $w7%][]
    envenom = {
        id = 32645,
        duration = 0.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- envenom[32645] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- rapid_injection[455072] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Building to a Coup de Grace.
    escalating_blade = {
        id = 441786,
        duration = 3600,
        max_stack = 1,
    },
    -- Dodge chance increased by ${$w1/2}%.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]$?a457034[ Magical damage taken reduced by $w3%.][]
    evasion = {
        id = 5277,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- elusiveness[79008] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Your next Eviscerate has $s1% increased critical strike chance.
    eviscerate = {
        id = 245691,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- planned_execution[382508] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- secret_stratagem[394320] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warning_signs[426555] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- momentum_of_despair[457115] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Movement speed increased by $w1%.
    fade_to_nothing = {
        id = 341533,
        duration = 10.0,
        max_stack = 1,
    },
    -- Falling below $461980M~3% health will cause Fatal Intent to inflict ${$461980s1*(1+$@versadmg)} Plague damage.
    fatal_intent = {
        id = 461981,
        duration = 60.0,
        max_stack = 1,
    },
    -- Taking $w1% more damage from $@auracaster.
    fazed = {
        id = 441224,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- no_scruples[441398] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- smoke[441247] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- surprising_strikes[441273] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Damage taken from area-of-effect attacks reduced by $s1%$?$w2!=0[ and all other damage taken reduced by $w2%.; ][.]
    feint = {
        id = 1966,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- elusiveness[79008] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- graceful_guile[423647] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- nimble_fingers[378427] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- mirrors[441250] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- $w1% of armor is ignored by the attacking Rogue.
    find_weakness = {
        id = 316220,
        duration = 10.0,
        max_stack = 1,
    },
    -- $?$W2>0[$@auracaster is tormenting the target, dealing $345316s1 Shadow damage for each combo point spent.][Combo points spent deal $345316s1 Shadow damage to $@auracaster's tormented target. Mastery increased by ${$W3*$mas}.1%.]
    flagellation = {
        id = 384631,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[341550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Your finishing moves cost no Energy.
    goremaws_bite = {
        id = 426593,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- shadow_blades[121471] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Incapacitated.
    gouge = {
        id = 1776,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Suffering $w1 Nature damage every $t1 seconds.
    instant_poison = {
        id = 315585,
        duration = 0.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- virulent_poisons[381543] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veiltouched[382017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- envenom[32645] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Stunned.
    kidney_shot = {
        id = 408,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- stunning_secret[426588] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stunning_secret[426588] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Leech increased by $s1%.
    leeching_poison = {
        id = 108211,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- master_poisoner[378436] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- envenom[32645] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- envenom[32645] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- All $?c1[Nature][Shadow] damage dealt increased by $w1%.
    lingering_darkness = {
        id = 457273,
        duration = 30.0,
        max_stack = 1,
    },
    -- Regenerating ${$s1*$d/$t1+$s2} Energy over $d.
    master_of_shadows = {
        id = 196980,
        duration = 3.0,
        max_stack = 1,
    },
    -- Critical strike chance of $?s51723[Fan of Knives]$?s197835[Shuriken Storm] and $?s121411[Crimson Tempest]$?s319175[Black Powder] increased by $w1%.
    momentum_of_despair = {
        id = 457115,
        duration = 12.0,
        max_stack = 1,
    },
    -- Attack and casting speed slowed by $s1%.
    numbing_poison = {
        id = 5760,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- master_poisoner[378436] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- master_poisoner[378436] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- At $394254u stacks, your next attack that generates combo points deals $w1% increased damage.
    perforated_veins = {
        id = 426602,
        duration = 3600,
        max_stack = 1,
    },
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    rupture = {
        id = 360826,
        duration = 4.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- corrupt_the_blood[457066] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- replicating_shadows[382506] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_DISTANCE, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- assassination_rogue[137037] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Incapacitated.$?$w2!=0[; Damage taken increased by $w2%.][]
    sap = {
        id = 6770,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dont_be_suspicious[441415] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Suffering $w1 Nature damage every $t1 sec, and $394026s1 when the poison ends.
    sepsis = {
        id = 385408,
        duration = 10.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Attacks deal $w1% additional damage as Shadow and combo point generating attacks generate full combo points.
    shadow_blades = {
        id = 121471,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veiltouched[382017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thiefs_bargain[354825] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[341550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Energy cost of abilities reduced by $w1%.
    shadow_focus = {
        id = 112942,
        duration = 3600,
        max_stack = 1,
    },
    -- Combo points stored.
    shadow_techniques = {
        id = 196911,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- deeper_stratagem[193531] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- improved_shadow_techniques[394023] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- secret_stratagem[394320] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Movement speed slowed by $w1%.
    shadows_grasp = {
        id = 206760,
        duration = 8.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s2%.
    shadowstep = {
        id = 36554,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- subtlety_rogue[137035] #4: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'target': TARGET_UNIT_CASTER, }
        -- shadowstep[394935] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- quick_decisions[382503] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- shadowstep[394931] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Shadowstrike deals $s2% increased damage and has $s1 yds increased range.
    shadowstrike = {
        id = 245623,
        duration = 3600,
        max_stack = 1,
    },
    -- Encased in the shadows, interfering with targeting.
    shadowy_duel = {
        id = 207736,
        duration = 5.0,
        max_stack = 1,
    },
    -- Concealed in shadows.
    shroud_of_concealment = {
        id = 115834,
        duration = 3600,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- shrouded_in_darkness[382507] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Releasing a Shuriken Storm every sec.
    shuriken_tornado = {
        id = 277925,
        duration = 4.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Your next Shuriken Storm has $s1% increased critical strike chance.
    silent_storm = {
        id = 385727,
        duration = 3600,
        max_stack = 1,
    },
    -- Attack speed increased by $w1%.
    slice_and_dice = {
        id = 315496,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- thousand_cuts[441346] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- A smoke cloud interferes with targeting.
    smoke_bomb = {
        id = 359053,
        duration = 5.0,
        max_stack = 1,
    },
    -- Healing $w1% of max health every $t.
    soothing_darkness = {
        id = 393971,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- ephemeral_bond[426563] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement speed increased by $w1%.$?s245751[; Allows you to run over water.][]
    sprint = {
        id = 2983,
        duration = 8.0,
        tick_time = 0.25,
        max_stack = 1,

        -- Affected by:
        -- improved_sprint[231691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- featherfoot[423683] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- featherfoot[423683] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- maneuverability[197000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- maneuverability[197000] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Stealthed.
    stealth = {
        id = 115191,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- shadowheart[455131] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- shadowrunner[378807] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- subterfuge[108208] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'trigger_spell': 1784, 'triggers': stealth, 'spell': 115191, 'value': 1784, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Damage of your next $?a137037 [Envenom][Eviscerate or Black Powder] is increased by $w1%.
    symbolic_victory = {
        id = 457167,
        duration = 12.0,
        max_stack = 1,
    },
    -- Damage done increased by $s1%.
    symbols_of_death = {
        id = 212283,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- planned_execution[382508] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- warning_signs[426555] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Movement speed increased by $w1%.
    terrifying_pace = {
        id = 428389,
        duration = 3.0,
        max_stack = 1,
    },
    -- Your next attack that generates combo points deals $s3% increased damage and is guaranteed to critically strike.
    the_rotten = {
        id = 394203,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage reduced by $w1%.
    thiefs_bargain = {
        id = 354827,
        duration = 6.0,
        max_stack = 1,
    },
    -- Mastery increased by ${$w2*$mas}.1%.
    thistle_tea = {
        id = 381623,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,
    },
    -- All threat transferred from the Rogue to the target.; $?s221622[Damage increased by $221622m1%.][]
    tricks_of_the_trade = {
        id = 59628,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- so_tricky[441403] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3594000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Improved stealth.$?$w3!=0[; Movement speed increased by $w3%.][]$?$w4!=0[; Damage increased by $w4%.][]
    vanish = {
        id = 11327,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- shadowheart[455131] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- shadowrunner[378807] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- subterfuge[108208] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Healing effects reduced by $w2%.
    wound_poison = {
        id = 8680,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_wound_poison[319066] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- master_poisoner[378436] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veiltouched[382017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- envenom[32645] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Ambush the target, causing $s1 Physical damage.$?s383281[; Has a $193315s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.][]; Awards $s2 combo $lpoint:points;$?s383281[ each time it strikes][].
    ambush = {
        id = 8676,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 50,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.51228, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_ambush[381620] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Coats your weapons with a Lethal Poison that lasts for $d. Each strike has a $h% chance to poison the enemy, dealing $383414s1 Nature damage and applying Amplifying Poison for $383414d. Envenom can consume $s2 stacks of Amplifying Poison to deal $s1% increased damage. Max $383414u stacks.
    amplifying_poison = {
        id = 381664,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'trigger_spell': 383414, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- envenom[32645] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- envenom[32645] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Stab the target, causing ${$s2*$<mult>} Physical damage. Damage increased by $s4% when you are behind your target$?s319949[, and critical strikes apply Find Weakness for $319949s1 sec][].; Awards $s3 combo $lpoint:points;.
    backstab = {
        id = 53,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.57, 'pvp_multiplier': 1.45, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- improved_backstab[319949] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'modifies': CRIT_CHANCE, }
        -- shadow_blades[121471] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Finishing move that launches explosive Black Powder at all nearby enemies dealing Physical damage. Deals reduced damage beyond $s4 targets.$?s382511[ All nearby targets with your Find Weakness suffer an additional $382511s1% damage as Shadow.][];    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]; 
    black_powder = {
        id = 319175,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.0878, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target2': TARGET_DEST_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- secret_stratagem[394320] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- momentum_of_despair[457115] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Blinds $?a200733[all enemies near ][]the target, causing $?a200733[them][it] to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    blind = {
        id = 2094,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "blind",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -60.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- airborne_irritant[200733] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- airborne_irritant[200733] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -70.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- dont_be_suspicious[441415] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Stuns the target for $d.; Awards $s2 combo $lpoint:points;.
    cheap_shot = {
        id = 1833,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cloak_of_shadows = {
        id = 31224,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "cloak_of_shadows",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_SPELL_HIT_CHANCE, 'points': -200.0, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 35729, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- ethereal_cloak[457022] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- [441423] After $441786s1 strikes with Unseen Blade, your next $?a137036[Dispatch][Eviscerate] will be performed as a Coup de Grace, functioning as if it had consumed $s3 additional combo points.; If the primary target is Fazed, gain $s2 stacks of Flawless Form.
    coup_de_grace = {
        id = 441776,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': IGNORE_HIT_DIRECTION, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [212198] Drink an alchemical concoction that heals you for $o1% of your maximum health over $d.
    create_crimson_vial = {
        id = 212205,
        color = 'pvp_talent',
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_ITEM, 'subtype': NONE, 'item_type': 137222, 'item': crimson_vial, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 3.0, }
    },

    -- Drink an alchemical concoction that heals you for $?a354425&a193546[${$O1}.1][$o1]% of your maximum health over $d.
    crimson_vial = {
        id = 185311,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 20,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 1.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- iron_stomach[193546] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- nimble_fingers[378427] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ephemeral_bond[426563] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- drink_up_me_hearties[354425] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Finishing move that empowers your weapons with energy to performs a deadly attack.; You leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $269512s2% stronger effect.
    death_from_above = {
        id = 269513,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 15,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': IGNORE_HIT_DIRECTION, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 184963, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Finishing move that empowers your weapons with shadow energy and performs a devastating two-part attack. ; You whirl around, dealing up to $s2 damage to all enemies within 8 yds, then leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $163786s2% stronger effect.
    death_from_above_152150 = {
        id = 152150,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.5733, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': IGNORE_HIT_DIRECTION, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 184963, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- Focus intently on trying to detect certain creatures.
    detection = {
        id = 56814,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INVISIBILITY_DETECT, 'points': 100.0, 'value': 5, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Disarm the enemy, preventing the use of any weapons or shield for $d.
    dismantle = {
        id = 207777,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 15,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISARM_RANGED, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DISARM_OFFHAND, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DISARM, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Throws a distraction, attracting the attention of all nearby monsters for $s1 seconds. Usable while stealthed.
    distract = {
        id = 1725,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISTRACT, 'subtype': NONE, 'points': 10.0, 'radius': 10.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- cloud_cover[441429] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 441587, 'target': TARGET_UNIT_CASTER, }
    },

    -- Throws a distraction, attracting the attention of all nearby monsters and leaving a cloud of smoke for $d. Usable while stealthed.; Attacks from within the cloud afflict targets with Fazed for $441224d.
    distract_441587 = {
        id = 441587,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 32665, 'schools': ['physical', 'nature', 'frost'], 'radius': 10.0, 'target': TARGET_UNK_149, }

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- cloud_cover[441429] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 441587, 'target': TARGET_UNIT_CASTER, }
        from = "from_description",
    },

    -- Deal $s1 Physical damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.; 
    echoing_reprimand = {
        id = 385616,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 10,
        spendType = 'energy',

        talent = "echoing_reprimand",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.6, 'pvp_multiplier': 0.7, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': energy, }

        -- Affected by:
        -- reverberation[394332] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_blades[121471] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Finishing move that drives your poisoned blades in deep, dealing instant Nature damage and increasing your poison application chance by $s2%. Damage and duration increased per combo point.;    1 point  : ${$m1*1} damage, 1 sec;    2 points: ${$m1*2} damage, 2 sec;    3 points: ${$m1*3} damage, 3 sec;    4 points: ${$m1*4} damage, 4 sec;    5 points: ${$m1*5} damage, 5 sec$?s193531[;    6 points: ${$m1*6} damage, 6 sec][]
    envenom = {
        id = 32645,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.275, 'pvp_multiplier': 0.96, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- envenom[32645] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- rapid_injection[455072] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    evasion = {
        id = 5277,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "evasion",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DODGE_PERCENT, 'points': 200.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- elusiveness[79008] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Finishing move that disembowels the target, causing damage per combo point.$?s382511[ Targets with Find Weakness suffer an additional $382511s1% damage as Shadow.][];    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]
    eviscerate = {
        id = 196819,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.21, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [196819] Finishing move that disembowels the target, causing damage per combo point.$?s382511[ Targets with Find Weakness suffer an additional $382511s1% damage as Shadow.][];    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]
    eviscerate_328082 = {
        id = 328082,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.21, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dark_brew[382504] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[383405] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- [441423] After $441786s1 strikes with Unseen Blade, your next $?a137036[Dispatch][Eviscerate] will be performed as a Coup de Grace, functioning as if it had consumed $s3 additional combo points.; If the primary target is Fazed, gain $s2 stacks of Flawless Form.
    eviscerate_coup_de_grace = {
        id = 462241,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.055, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [441423] After $441786s1 strikes with Unseen Blade, your next $?a137036[Dispatch][Eviscerate] will be performed as a Coup de Grace, functioning as if it had consumed $s3 additional combo points.; If the primary target is Fazed, gain $s2 stacks of Flawless Form.
    eviscerate_coup_de_grace_462242 = {
        id = 462242,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.055, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- [441423] After $441786s1 strikes with Unseen Blade, your next $?a137036[Dispatch][Eviscerate] will be performed as a Coup de Grace, functioning as if it had consumed $s3 additional combo points.; If the primary target is Fazed, gain $s2 stacks of Flawless Form.
    eviscerate_coup_de_grace_462243 = {
        id = 462243,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.11, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- [196819] Finishing move that disembowels the target, causing damage per combo point.$?s382511[ Targets with Find Weakness suffer an additional $382511s1% damage as Shadow.][];    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]
    eviscerate_coup_de_grace_462244 = {
        id = 462244,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.055, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dark_brew[382504] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[383405] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- [196819] Finishing move that disembowels the target, causing damage per combo point.$?s382511[ Targets with Find Weakness suffer an additional $382511s1% damage as Shadow.][];    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]
    eviscerate_coup_de_grace_462247 = {
        id = 462247,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.055, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dark_brew[382504] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[383405] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- [196819] Finishing move that disembowels the target, causing damage per combo point.$?s382511[ Targets with Find Weakness suffer an additional $382511s1% damage as Shadow.][];    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]
    eviscerate_coup_de_grace_462248 = {
        id = 462248,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.11, 'pvp_multiplier': 0.95, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dark_brew[382504] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[383405] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- symbolic_victory[457167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- eviscerate[245691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- death_from_above[163786] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[163786] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[163786] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[163786] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by $s1% $?s79008[and all other damage taken by $s2% ][]for $d.
    feint = {
        id = 1966,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_AOE_DAMAGE_AVOIDANCE, 'points': -40.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- elusiveness[79008] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- graceful_guile[423647] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- nimble_fingers[378427] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- mirrors[441250] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Lash the target for $s1 Shadow damage, causing each combo point spent within $d to lash for an additional $345316s1. Dealing damage with Flagellation increases your Mastery by ${$s2*$mas}.1%, persisting $345569d after their torment fades.
    flagellation = {
        id = 384631,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "flagellation",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Suppress Points Stacking'], 'ap_bonus': 0.5, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MASTERY, 'pvp_multiplier': 0.8, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_VERSATILITY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[341550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Punctures your target with your shadow-infused blade for $s1 Shadow damage, bypassing armor.$?s319949[ Critical strikes apply Find Weakness for $319949s1 sec.][]; Awards $s2 combo $lpoint:points;.
    gloomblade = {
        id = 200758,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        talent = "gloomblade",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.65352, 'pvp_multiplier': 1.45, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_backstab[319949] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'modifies': CRIT_CHANCE, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- veiltouched[382017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[341550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Lashes out at the target, inflicting $426592s1 Shadow damage and causing your next $426593u finishing moves to cost no Energy.; Awards $426593s1 combo $lpoint:points;.
    goremaws_bite = {
        id = 426591,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        talent = "goremaws_bite",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 426592, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 426593, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.; Must be in front of your target.; Awards $s2 combo $lpoint:points;.
    gouge = {
        id = 1776,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        talent = "gouge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A quick kick that interrupts spellcasting and prevents any spell in that school from being cast for $d.
    kick = {
        id = 1766,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Finishing move that stuns the target$?a426588[ and creates shadow clones to stun all other nearby enemies][]. Lasts longer per combo point, up to 5:;    1 point  : 2 seconds;    2 points: 3 seconds;    3 points: 4 seconds;    4 points: 5 seconds;    5 points: 6 seconds
    kidney_shot = {
        id = 408,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- stunning_secret[426588] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stunning_secret[426588] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Pick the target's pocket.
    pick_pocket = {
        id = 921,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': PICKPOCKET, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- dont_be_suspicious[441415] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Finishing move that tears open the target, dealing Bleed damage over time. Lasts longer per combo point.;    1 point  : ${$o1*2} over 8 sec;    2 points: ${$o1*3} over 12 sec;    3 points: ${$o1*4} over 16 sec;    4 points: ${$o1*5} over 20 sec;    5 points: ${$o1*6} over 24 sec$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$o1*7} over 28 sec][]$?s193531&(s394320|s394321)[;    7 points: ${$o1*8} over 32 sec][]
    rupture = {
        id = 1943,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'mechanic': bleeding, 'ap_bonus': 0.262416, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'mechanic': bleeding, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199672, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199672, 'value': 160, 'schools': ['shadow'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #4: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199672, 'value': 500, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- corrupt_the_blood[457066] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- replicating_shadows[382506] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- replicating_shadows[382506] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_DISTANCE, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Incapacitates a target not in combat for $d. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    sap = {
        id = 6770,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'variance': 0.15, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dont_be_suspicious[441415] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets.;    1 point  : ${$280720m1*1*$<mult>} total damage;    2 points: ${$280720m1*2*$<mult>} total damage;    3 points: ${$280720m1*3*$<mult>} total damage;    4 points: ${$280720m1*4*$<mult>} total damage;    5 points: ${$280720m1*5*$<mult>} total damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$280720m1*6*$<mult>} total damage][]$?s193531&(s394320|s394321)[;    7 points: ${$280720m1*7*$<mult>} total damage][]; Cooldown is reduced by $s5 sec for every combo point you spend.
    secret_technique = {
        id = 280719,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        talent = "secret_technique",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_executioner[76808] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_executioner[76808] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.45, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_stratagem[193531] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- disorienting_strikes[441274] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- secret_stratagem[394320] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- secret_stratagem[394320] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Infect the target's blood, dealing $o1 Nature damage over $d and gaining $s6 use of any Stealth ability. If the target survives its full duration, they suffer an additional $394026s1 damage and you gain $s6 additional use of any Stealth ability for $375939d.; Cooldown reduced by $s3 sec if Sepsis does not last its full duration.; Awards $?a121471[${$s7+$121471s4}][$s7] combo $lpoint:points;.
    sepsis = {
        id = 385408,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        talent = "sepsis",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'ap_bonus': 0.37584, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, }
        -- #6: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- dark_brew[382504] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 1.0, 'value': 32, 'schools': ['shadow'], 'target': TARGET_UNIT_CASTER, }
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Draws upon surrounding shadows to empower your weapons, causing your attacks to deal $s1% additional damage as Shadow and causing your combo point generating abilities to generate full combo points for $d.
    shadow_blades = {
        id = 121471,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "shadow_blades",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dark_brew[382504] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- veiltouched[382017] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veiltouched[382017] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thiefs_bargain[354825] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deeper_daggers[341550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Allows use of all Stealth abilities and grants all the combat benefits of Stealth for $d$?a245687[, and increases damage by $s2%][]. Effect not broken from taking damage or attacking.$?s137035[; If you already know $@spellname185313, instead gain $394930s1 additional $Lcharge:charges; of $@spellname185313.][]
    shadow_dance = {
        id = 185313,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_THREAT, 'points': -10000000.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dark_shadow[245687] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- dark_shadow[245687] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- dark_shadow[245687] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- double_dance[394930] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_shadow_dance[393972] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- improved_shadow_dance[393972] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Step through the shadows to appear behind your target and gain $s2% increased movement speed for $d.$?s137035|s137037[; If you already know $@spellname36554, instead gain $394931s1 additional $Lcharge:charges; of $@spellname36554.][]
    shadowstep = {
        id = 36554,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        talent = "shadowstep",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 36563, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 70.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_TARGET_ANY, }

        -- Affected by:
        -- subtlety_rogue[137035] #4: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'target': TARGET_UNIT_CASTER, }
        -- shadowstep[394935] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- quick_decisions[382503] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- shadowstep[394931] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Strike the target, dealing $s1 Physical damage.; While Stealthed, you strike through the shadows and appear behind your target up to ${5+$245623s1} yds away, dealing $245623s2% additional damage.; Awards $s2 combo $lpoint:points;.
    shadowstrike = {
        id = 185438,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 45,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.5, 'pvp_multiplier': 1.08, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- shadow_dance[185313] #5: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_ambush[381620] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- shadowstrike[245623] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- shadowstrike[245623] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- You lock your target into a duel contained in the shadows, removing both of you from the eyes of onlookers for $d.; Allows access to Stealth-based abilities.
    shadowy_duel = {
        id = 207736,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        spend = 50,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': INTERFERE_TARGETTING, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': INTERFERE_TARGETTING, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 210558, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, 'form': stealth, 'creature_type': none, }
    },

    -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    shiv = {
        id = 5938,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        talent = "shiv",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.9504, 'pvp_multiplier': 0.83, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #3: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 9, 'schools': ['physical', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Extend a cloak that shrouds party and raid members within $115834A1 yards in shadows, providing stealth for $d.
    shroud_of_concealment = {
        id = 114018,
        cast = 0.0,
        cooldown = 360.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.5, 'trigger_spell': 115834, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- stillshroud[423662] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- dont_be_suspicious[441415] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- shroud_of_night[457063] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- shrouded_in_darkness[382507] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Sprays shurikens at all enemies within $A1 yards, dealing ${$s1*$<CAP>/$AP} Physical damage$?a277953[ and reducing movement speed by $206760s1% for $206760d]?a428387[ and increasing movement speed by $428389s1% for $428389d when striking $428387s1 or more enemies][]. Deals reduced damage beyond $s4 targets.$?s319951[; Critical strikes with Shuriken Storm apply Find Weakness for $319949s1 sec.][]; Awards $s2 combo $lpoint:points; per target hit.
    shuriken_storm = {
        id = 197835,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 45,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.3475, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_shuriken_storm[319951] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- momentum_of_despair[457115] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- silent_storm[385727] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Focus intently, then release a Shuriken Storm every sec for the next $d. 
    shuriken_tornado = {
        id = 277925,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 60,
        spendType = 'energy',

        talent = "shuriken_tornado",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Throws a shuriken at an enemy target for ${$s1*$<CAP>/$AP} Physical damage.; Awards $s2 combo $lpoint:points;.
    shuriken_toss = {
        id = 114014,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.19656, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'ap_bonus': 0.19656, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- danse_macabre[393969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- danse_macabre[393969] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.8, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Viciously strike an enemy, causing $s1 Physical damage.; Awards $s2 combo $lpoint:points;.
    sinister_strike = {
        id = 1752,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 45,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.21762, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }

        -- Affected by:
        -- subtlety_rogue[137035] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- subtlety_rogue[137035] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- symbols_of_death[212283] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- symbols_of_death[212283] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_dance[185313] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_dance[185313] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Viciously strike an enemy, causing ${$s1*$<mult>} Physical damage.$?s279876[; Has a $s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.][]; Awards $s2 combo $lpoint:points; each time it strikes.
    sinister_strike_193315 = {
        id = 193315,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 45,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.6, 'pvp_multiplier': 1.05, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadow_blades[121471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "from_description",
    },

    -- Finishing move that consumes combo points to increase attack speed by $s1%. Lasts longer per combo point.;    1 point  : 12 seconds;    2 points: 18 seconds;    3 points: 24 seconds;    4 points: 30 seconds;    5 points: 36 seconds$?s193531|((s394320|s394321)&!s193531)[;    6 points: 42 seconds][]$?s193531&(s394320|s394321)[;    7 points: 48 seconds][]
    slice_and_dice = {
        id = 315496,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_MELEE_RANGED_HASTE_2, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 426605, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- secret_stratagem[394320] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- thousand_cuts[441346] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- goremaws_bite[426593] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Creates a cloud of thick smoke in an $m2 yard radius around the Rogue for $d. Enemies are unable to target into or out of the smoke cloud. 
    smoke_bomb = {
        id = 359053,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 6951, 'schools': ['physical', 'holy', 'fire', 'shadow'], 'target': TARGET_DEST_CASTER_GROUND_2, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 8.0, }
    },

    -- Increases your movement speed by $s1% for $d. Usable while stealthed.$?s245751[; Allows you to run over water.][]
    sprint = {
        id = 2983,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 70.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.25, 'points': 1.0, }

        -- Affected by:
        -- improved_sprint[231691] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- featherfoot[423683] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- featherfoot[423683] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- maneuverability[197000] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- maneuverability[197000] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Conceals you in the shadows until cancelled, allowing you to stalk enemies without being seen. $?s14062[Movement speed while stealthed is increased by $s3% and damage dealt is increased by $s4%.]?s108209[ Abilities cost $112942s1% less while stealthed. ][]$?s31223[ Attacks from Stealth and for $31223s1 sec after deal $31665s1% more damage.][]
    stealth = {
        id = 1784,
        cast = 0.0,
        cooldown = 2.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'value': 30, 'schools': ['holy', 'fire', 'nature', 'frost'], 'value1': 2, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points_per_level': 5.0, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }

        -- Affected by:
        -- shadowheart[455131] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- shadowrunner[378807] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- subterfuge[108208] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'trigger_spell': 1784, 'triggers': stealth, 'spell': 115191, 'value': 1784, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Conceals you in the shadows until cancelled, allowing you to stalk enemies without being seen. $?s14062[Movement speed while stealthed is increased by $s3%. ]?s13975[Movement speed while stealthed is increased by $s3%. ][]$?s31223[Attacks from Stealth and for $31223s1 sec after deal $31665s1% more damage.][]
    stealth_115191 = {
        id = 115191,
        cast = 0.0,
        cooldown = 2.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points_per_level': 5.0, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- shadowheart[455131] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- shadowrunner[378807] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- subterfuge[108208] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'trigger_spell': 1784, 'triggers': stealth, 'spell': 115191, 'value': 1784, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        from = "triggered_spell",
    },

    -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    thistle_tea = {
        id = 381623,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        talent = "thistle_tea",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': ENERGIZE, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'resource': energy, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MASTERY, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    tricks_of_the_trade = {
        id = 57934,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        talent = "tricks_of_the_trade",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': REDIRECT_THREAT, 'subtype': NONE, 'points': 100.0, 'value': 30000, 'schools': ['frost', 'shadow'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_TARGET_RAID, }
    },

    -- Allows you to vanish from sight, entering stealth while in combat. For the first $11327d after vanishing, damage and harmful effects received will not break stealth. Also breaks movement impairing effects.
    vanish = {
        id = 1856,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SANCTUARY_2, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 18461, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #3: { 'type': FORCE_DESELECT, 'subtype': NONE, 'attributes': ['Exclude Own Party'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- without_a_trace[382513] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

} )