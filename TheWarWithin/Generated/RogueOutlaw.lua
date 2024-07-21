-- RogueOutlaw.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 260 )

-- Resources
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )

spec:RegisterTalents( {
    -- Rogue Talents
    acrobatic_strikes         = { 90752, 455143, 1 }, -- Auto-attacks increase auto-attack damage and movement speed by ${$s1/10}.1% for $455144d, stacking up to ${$s1/10*$455144u}%.
    airborne_irritant         = { 90741, 200733, 1 }, -- Blind has $s1% reduced cooldown, $s2% reduced duration, and applies to all nearby enemies.
    alacrity                  = { 90751, 193539, 2 }, -- Your finishing moves have a $s2% chance per combo point to grant $193538s1% Haste for $193538d, stacking up to $193538u times.
    atrophic_poison           = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $h% chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    blackjack                 = { 90686, 379005, 1 }, -- Enemies have $394119s1% reduced damage and healing for $394119d after Blind or Sap's effect on them ends.
    blind                     = { 90684, 2094  , 1 }, -- Blinds $?a200733[all enemies near ][]the target, causing $?a200733[them][it] to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    cheat_death               = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to $s2% of your maximum health. For $45182d afterward, you take $45182s1% reduced damage. Cannot trigger more often than once per $45181d.
    cloak_of_shadows          = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cold_blood                = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by $s1%.
    deadened_nerves           = { 90743, 231719, 1 }, -- Physical damage taken reduced by $s1%.; 
    deadly_precision          = { 90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by $s1%.
    deeper_stratagem          = { 90750, 193531, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    echoing_reprimand         = { 90639, 385616, 1 }, -- Deal $s1 Physical damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.; 
    elusiveness               = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by $s2%, and Feint also reduces non-area-of-effect damage taken by $s1%.
    evasion                   = { 90764, 5277  , 1 }, -- Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    featherfoot               = { 94563, 423683, 1 }, -- Sprint increases movement speed by an additional $s1% and has ${$s2/1000} sec increased duration.
    fleet_footed              = { 90762, 378813, 1 }, -- Movement speed increased by $s1%.
    gouge                     = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.; Must be in front of your target.; Awards $s2 combo $lpoint:points;.
    graceful_guile            = { 94562, 423647, 1 }, -- Feint has $m1 additional $Lcharge:charges;.; 
    improved_ambush           = { 90692, 381620, 1 }, -- $?s185438[Shadowstrike][Ambush] generates $s1 additional combo point.
    improved_sprint           = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by ${$m1/-1000} sec.
    improved_wound_poison     = { 90637, 319066, 1 }, -- Wound Poison can now stack $s1 additional times.
    iron_stomach              = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by $s1%.
    leeching_poison           = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you $108211s1% Leech.
    lethality                 = { 90749, 382238, 2 }, -- Critical strike chance increased by $s1%. Critical strike damage bonus of your attacks that generate combo points increased by $s2%.
    master_poisoner           = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%.
    nimble_fingers            = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1.
    numbing_poison            = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $5761h% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $5760s1% for $5760d.
    recuperator               = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per $426605t sec.
    resounding_clarity        = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges $m1 additional combo $Lpoint:points;.
    reverberation             = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by $s1%.
    rushed_setup              = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%.
    shadowheart               = { 101714, 455131, 1 }, -- Leech increased by $s1% while Stealthed.; 
    shadowrunner              = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster.
    shadowstep                = { 90695, 36554 , 1 }, -- Description not found.
    shiv                      = { 90740, 5938  , 1 }, -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    soothing_darkness         = { 90691, 393970, 1 }, -- You are healed for ${$393971s1*($393971d/$393971t)}% of your maximum health over $393971d after gaining Vanish or Shadow Dance.
    stillshroud               = { 94561, 423662, 1 }, -- Shroud of Concealment has $s1% reduced cooldown.; 
    subterfuge                = { 90688, 108208, 2 }, -- Abilities and combat benefits requiring Stealth remain active for ${$s2/1000} sec after Stealth breaks.
    superior_mixture          = { 94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional $s1%.
    thistle_tea               = { 90756, 381623, 1 }, -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    tight_spender             = { 90692, 381621, 1 }, -- Energy cost of finishing moves reduced by $s1%.
    tricks_of_the_trade       = { 90686, 57934 , 1 }, -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    unbreakable_stride        = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects $s1%.
    vigor                     = { 90759, 14983 , 2 }, -- Increases your maximum Energy by $s1 and Energy regeneration by $s2%.
    virulent_poisons          = { 90760, 381543, 1 }, -- Increases the damage of your weapon poisons by $s1%.
    without_a_trace           = { 101713, 382513, 1 }, -- Vanish has $s1 additional $lcharge:charges;.

    -- Outlaw Talents
    ace_up_your_sleeve        = { 90670, 381828, 1 }, -- Between the Eyes has a $s1% chance per combo point spent to grant $394120s2 combo points.
    adrenaline_rush           = { 90659, 13750 , 1 }, -- Increases your Energy regeneration rate by $s1%, your maximum Energy by $s4, and your attack speed by $s2% for $d.
    ambidexterity             = { 90660, 381822, 1 }, -- Main Gauche has an additional $s1% chance to strike while Blade Flurry is active.
    audacity                  = { 90641, 381845, 1 }, -- Half-cost uses of Pistol Shot have a $193315s3% chance to make your next Ambush usable without Stealth.; Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time.
    blade_rush                = { 90664, 271877, 1 }, -- Charge to your target with your blades out, dealing ${$271881sw1*$271881s2/100} Physical damage to the target and $271881sw1 to all other nearby enemies.; While Blade Flurry is active, damage to non-primary targets is increased by $s1%.; Generates ${$271896s1*$271896d/$271896t1} Energy over $271896d.
    blinding_powder           = { 90643, 256165, 1 }, -- Reduces the cooldown of Blind by $s1% and increases its range by $s2 yds.
    chosens_revelry           = { 95138, 454300, 1 }, -- Leech increased by ${$s1/100}.1% for each time your Fatebound Coin has flipped the same face in a row.
    cloud_cover               = { 95116, 441429, 1 }, -- Distract now also creates a cloud of smoke for $441587d. Cooldown increased to $s2 sec.; Attacks from within the cloud apply Fazed.
    combat_potency            = { 90646, 61329 , 1 }, -- Increases your Energy regeneration rate by $s1%.
    combat_stamina            = { 90648, 381877, 1 }, -- Stamina increased by $<stam>%.
    count_the_odds            = { 90655, 381982, 1 }, -- Ambush, Sinister Strike, and Dispatch have a $s1% chance to grant you a Roll the Bones combat enhancement buff you do not already have for $s2 sec.
    coup_de_grace             = { 95115, 441423, 1 }, -- After $441786s1 strikes with Unseen Blade, your next $?a137036[Dispatch][Eviscerate] will be performed as a Coup de Grace, functioning as if it had consumed $s3 additional combo points.; If the primary target is Fazed, gain $s2 stacks of Flawless Form.
    crackshot                 = { 94565, 423703, 1 }, -- Between the Eyes has no cooldown and also Dispatches the target for $s1% of normal damage when used from Stealth.
    dancing_steel             = { 90669, 272026, 1 }, -- Blade Flurry strikes $s3 additional enemies and its duration is increased by ${$s2/1000} sec.
    deal_fate                 = { 95107, 454419, 1 }, -- $?a137037[Mutilate, Ambush, Fan of Knives][Sinister Strike]$?a383281[ and Ambush][] generate$?a137037[]$?a383281[] $454421s1 additional combo point $?a137037[when they trigger Seal Fate]?383281[when they strike an additional time][when they strike an additional time].
    deaths_arrival            = { 95130, 454433, 1 }, -- $?a137037[Shadowstep][Grappling Hook] may be used a second time within $457333d, with no cooldown. 
    deft_maneuvers            = { 90672, 381878, 1 }, -- Blade Flurry's initial damage is increased by $s1% and generates $m2 $Lcombo point:combo points; per target struck.
    delivered_doom            = { 95119, 454426, 1 }, -- Damage dealt when your Fatebound Coin flips tails is increased by $s1% if there are no other enemies near the target.
    destiny_defined           = { 95114, 454435, 1 }, -- $?a137037[Weapon poisons have $s1% increased application chance][Sinister Strike has $s2% increased chance to strike an additional time] and your Fatebound Coins flipped have an additional $s3% chance to match the same face as the last flip. 
    devious_distractions      = { 95133, 441263, 1 }, -- $?a137036[Killing Spree][Secret Technique] applies Fazed to any targets struck.
    devious_stratagem         = { 90679, 394321, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    dirty_tricks              = { 90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    disorienting_strikes      = { 95118, 441274, 1 }, -- $?a137036[Killing Spree][Secret Technique] has $s1% reduced cooldown and allows your next $s2 strikes of Unseen Blade to ignore its cooldown.
    dont_be_suspicious        = { 95134, 441415, 1 }, -- Blind and Shroud of Concealment have $s1% reduced cooldown.; Pick Pocket and Sap have $s2 yd increased range.
    double_jeopardy           = { 95129, 454430, 1 }, -- Your first Fatebound Coin flip after breaking Stealth flips two coins that are guaranteed to match the same face.
    edge_case                 = { 95139, 453457, 1 }, -- Activating $?a137036[Adrenaline Rush][Deathmark] causes your next Fatebound Coin flip to land on its edge, counting as both Heads and Tails.
    fan_the_hammer            = { 90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain $m1 additional $Lstack:stacks; of Opportunity. Max ${$s2+1} stacks.; Half-cost uses of Pistol Shot consume $m1 additional $Lstack:stacks; of Opportunity to fire $m1 additional $Lshot:shots;. Additional shots generate $m3 fewer combo $Lpoint:points; and deal $s4% reduced damage.
    fatal_flourish            = { 90662, 35551 , 1 }, -- Your off-hand attacks have a $s1% chance to generate $35546s1 Energy.
    fate_intertwined          = { 95120, 454429, 1 }, -- Fate Intertwined duplicates $s1% of $?a137037[Envenom][Dispatch] critical strike damage as Cosmic to $s2 additional nearby enemies. If there are no additional nearby targets, duplicate $s1% to the primary target instead.
    fateful_ending            = { 95127, 454428, 1 }, -- When your Fatebound Coin flips the same face for the seventh time in a row, keep the lucky coin to gain $452562s1% Agility until you leave combat for $s2 seconds. If you already have a lucky coin, it instead deals $461818s1 Cosmic damage to your target.
    flawless_form             = { 95111, 441321, 1 }, -- Unseen Blade and $?a137036[Killing Spree][Secret Technique] increase the damage of your finishing moves by $441326s1% for $441326d.; Multiple applications may overlap.
    flickerstrike             = { 95137, 441359, 1 }, -- Taking damage from an area-of-effect attack while Feint is active or dodging while Evasion is active refreshes your opportunity to strike with Unseen Blade.; This effect may only occur once every $proccooldown sec.
    float_like_a_butterfly    = { 90755, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by ${$s1/10}.1 sec per combo point spent.
    ghostly_strike            = { 90644, 196937, 1 }, -- Strikes an enemy, dealing $s1 Physical damage and causing the target to take $s3% increased damage from your abilities for $d.; Awards $s2 combo $lpoint:points;.
    greenskins_wickers        = { 90665, 386823, 1 }, -- Between the Eyes has a $s1% chance per Combo Point to increase the damage of your next Pistol Shot by $394131s1%.
    hand_of_fate              = { 95125, 452536, 1 }, -- Flip a Fatebound Coin each time a finishing move consumes $s1 or more combo points. Heads increases the damage of your attacks by $456479s1%, lasting $452923d or until you flip Tails. Tails deals $452538s1 Cosmic damage to your target.; For each time the same face is flipped in a row, Heads increases damage by an additional $452923s1% and Tails increases its damage by $452917s1%.
    heavy_hitter              = { 90642, 381885, 1 }, -- Attacks that generate combo points deal $s1% increased damage.
    hidden_opportunity        = { 90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush at $s1% of their value.
    hit_and_run               = { 90673, 196922, 1 }, -- Movement speed increased by $s1%.
    improved_adrenaline_rush  = { 90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and full Energy when it ends.
    improved_between_the_eyes = { 90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.; 
    improved_main_gauche      = { 90668, 382746, 1 }, -- Main Gauche has an additional $s1% chance to strike.
    inevitability             = { 95114, 454434, 1 }, -- Cold Blood now benefits the next two abilities but only applies to $?a137037[Envenom][Dispatch]. Fatebound Coins flipped by these abilities are guaranteed to match the same face as the last flip.
    inexorable_march          = { 95130, 454432, 1 }, -- You cannot be slowed below $s1% of normal movement speed while your Fatebound Coin flips have an active streak of at least $s2 flips matching the same face.
    keep_it_rolling           = { 90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by $s1 sec.
    killing_spree             = { 94566, 51690 , 1 }, -- Finishing move that teleports to an enemy within $r yds, striking with both weapons for Physical damage. Number of strikes increased per combo point.; $s6% of damage taken during effect is delayed, instead taken over 8 sec.;    1 point  : ${$<dmg>*2} over ${$424556d}.2 sec;    2 points: ${$<dmg>*3} over ${$424556d*2}.2 sec;    3 points: ${$<dmg>*4} over ${$424556d*3}.2 sec;    4 points: ${$<dmg>*5} over ${$424556d*4}.2 sec;    5 points: ${$<dmg>*6} over ${$424556d*5}.2 sec$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$<dmg>*7} over ${$424556d*6}.2 sec][]$?s193531&(s394320|s394321)[;    7 points: ${$<dmg>*8} over ${$424556d*7}.2 sec][]
    loaded_dice               = { 90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    mean_streak               = { 95122, 453428, 1 }, -- Fatebound Coins flipped by $?a137036[Dispatch][Envenom] multiple times in a row are $s1% more likely to match the same face as the last flip.
    mirrors                   = { 95141, 441250, 1 }, -- Feint reduces damage taken from area-of-effect attacks by an additional $s1%
    nimble_flurry             = { 95128, 441367, 1 }, -- $?a137036[Blade Flurry damage is increased by $s1%]?s200758[Your auto-attacks, Backstab, Shadowstrike, and Eviscerate also strike up to $s2 additional nearby targets for $s3% of normal damage][Your auto-attacks, Backstab, Shadowstrike, and Eviscerate also strike up to $s2 additional nearby targets for $s3% of normal damage] while Flawless Form is active.
    no_scruples               = { 95116, 441398, 1 }, -- Finishing moves have $s1% increased chance to critically strike Fazed targets.
    opportunity               = { 90683, 279876, 1 }, -- Sinister Strike has a $193315s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = { 90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional $s1% per missing target below its maximum.
    precision_shot            = { 90647, 428377, 1 }, -- Between the Eyes and Pistol Shot have $s1 yd increased range, and Pistol Shot reduces the the target's damage done to you by $185763s4%.
    quick_draw                = { 90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate $s2 additional combo point, and deal $s1% additional damage.
    retractable_hook          = { 90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by ${$s1/-1000} sec, and increases its retraction speed.
    riposte                   = { 90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every $proccooldown sec.
    ruthlessness              = { 90680, 14161 , 1 }, -- Your finishing moves have a $b1% chance per combo point spent to grant a combo point.
    sleight_of_hand           = { 90651, 381839, 1 }, -- Roll the Bones has a $s1% increased chance of granting additional matches.
    smoke                     = { 95141, 441247, 1 }, -- You take $s1% reduced damage from Fazed targets.
    so_tricky                 = { 95134, 441403, 1 }, -- Tricks of the Trade's threat redirect duration is increased to $m1 $Lhour:min;.
    sting_like_a_bee          = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or $?s199804[Between the Eyes][Kidney Shot] take $s1% increased damage from all sources for $255909d.
    summarily_dispatched      = { 90653, 381990, 2 }, -- When your Dispatch consumes $s2 or more combo points, Dispatch deals $386868s1% increased damage and costs $386868s2 less Energy for $s3 sec.; Max $386868u stacks. Adding a stack does not refresh the duration.
    surprising_strikes        = { 95121, 441273, 1 }, -- Attacks that generate combo points deal $s1% increased critical strike damage to Fazed targets.
    swift_slasher             = { 90649, 381988, 1 }, -- Slice and Dice grants additional attack speed equal to $s2% of your Haste.
    take_em_by_surprise       = { 90676, 382742, 2 }, -- Haste increased by $s2% while Stealthed and for $s1 sec after breaking Stealth.
    tempted_fate              = { 95138, 454286, 1 }, -- You have a chance equal to your critical strike chance to absorb $s1% of any damage taken, up to a maximum chance of $s2%.
    thiefs_versatility        = { 90753, 381619, 1 }, -- Versatility increased by $s1%.
    thousand_cuts             = { 95137, 441346, 1 }, -- Slice and Dice grants $s1% additional attack speed and gives your auto-attacks a chance to refresh your opportunity to strike with Unseen Blade.
    triple_threat             = { 90678, 381894, 1 }, -- Sinister Strike has a $s1% chance to strike with both weapons after it strikes an additional time.
    underhanded_upper_hand    = { 90677, 424044, 1 }, -- Blade Flurry does not lose duration during Adrenaline Rush.; Adrenaline Rush does not lose duration while Stealthed.
    unseen_blade              = { 95140, 441146, 1 }, -- $?a137036[Sinister Strike]?s200758[Gloomblade][Backstab] and $?a137036[Ambush][Shadowstrike] now also strike with an Unseen Blade dealing $441144s1 damage. Targets struck are Fazed for $441224d.; Fazed enemies take $441224s1% more damage from you and cannot parry your attacks.; This effect may occur once every $459485d.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    boarding_party       = 853 , -- (209752) Between the Eyes increases the movement speed of all friendly players within $209754A1 yards by $209754s1% for $209754d.
    control_is_king      = 138 , -- (354406) Cheap Shot grants Slice and Dice for $s1 sec and Kidney Shot restores $s2 Energy per combo point spent.
    dagger_in_the_dark   = 5549, -- (198675) Each second while Stealth is active, nearby enemies within $198688A1 yards take an additional $198688s1% damage from you for $198688d. Stacks up to $198688u times.
    death_from_above     = 3619, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack.; You leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $269512s2% stronger effect.
    dismantle            = 145 , -- (207777) Disarm the enemy, preventing the use of any weapons or shield for $d.
    drink_up_me_hearties = 139 , -- (354425) Crimson Vial restores $s1% additional maximum health and grants $s3% of its healing to allies within $354494a yds.
    enduring_brawler     = 5412, -- (354843) Every $354844t sec you remain in combat, gain $354847s1% chance for Sinister Strike to hit an additional time. Lose $354845s1 stack each second while out of combat. Max $354847u stacks.
    maneuverability      = 129 , -- (197000) Sprint has $s1% reduced cooldown and $s2% reduced duration.
    smoke_bomb           = 3483, -- (212182) Creates a cloud of thick smoke in an $m2 yard radius around the Rogue for $d. Enemies are unable to target into or out of the smoke cloud. 
    take_your_cut        = 135 , -- (198265) $?s5171[Slice and Dice][Roll the Bones] also grants $198368s1% Haste for $198368d to allies within $198368A1 yds.
    thick_as_thieves     = 1208, -- (221622) Tricks of the Trade now increases the friendly target's damage by $m1% for $59628d.
    turn_the_tables      = 3421, -- (198020) After coming out of a stun, you deal $198027m1% increased damage for $198027d.
    veil_of_midnight     = 5516, -- (198952) Cloak of Shadows now also removes harmful physical effects.
} )

-- Auras
spec:RegisterAuras( {
    -- Auto-attack damage and movement speed increased by ${$W}.1%.
    acrobatic_strikes = {
        id = 455144,
        duration = 3.0,
        max_stack = 1,
    },
    -- Energy regeneration increased by $w1%.; Maximum Energy increased by $w4.; Attack speed increased by $w2%.; $?$w5>0[Damage increased by $w5%.][]
    adrenaline_rush = {
        id = 13750,
        duration = 20.0,
        tick_time = 1.0,
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
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Damage reduced by ${$W1*-1}.1%.
    atrophic_poison = {
        id = 392388,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- master_poisoner[378436] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- $w2% increased critical strike chance.
    between_the_eyes = {
        id = 315341,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- devious_stratagem[394321] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_between_the_eyes[235484] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- precision_shot[428377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- $w1% reduced damage and healing.
    blackjack = {
        id = 394119,
        duration = 6.0,
        max_stack = 1,
    },
    -- Attacks striking nearby enemies.
    blade_flurry = {
        id = 13877,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ambidexterity[381822] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- dancing_steel[272026] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Disoriented.
    blind = {
        id = 2094,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- airborne_irritant[200733] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- airborne_irritant[200733] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -70.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- blinding_powder[256165] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- blinding_powder[256165] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- dont_be_suspicious[441415] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Movement speed increased by $s1%.
    boarding_party = {
        id = 209754,
        duration = 6.0,
        max_stack = 1,
    },
    -- Stunned.
    cheap_shot = {
        id = 1833,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
    },
    -- Critical strike chance of your next damaging ability increased by $s1%.
    cold_blood = {
        id = 382245,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- inevitability[454434] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 456330, 'target': TARGET_UNIT_CASTER, }
    },
    -- Healing for ${$W1}.2% of maximum health every $t1 sec.
    crimson_vial = {
        id = 354494,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- iron_stomach[193546] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- nimble_fingers[378427] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Being stalked by a rogue.; The rogue deals an additional $m1% damage.
    dagger_in_the_dark = {
        id = 198688,
        duration = 10.0,
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
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- virulent_poisons[381543] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- ghostly_strike[196937] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

        -- Affected by:
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Rogue's second combo point is Animacharged. ; Damaging finishing moves using exactly 2 combo points deal damage as if 7 combo points are consumed.
    echoing_reprimand = {
        id = 323558,
        duration = 45.0,
        max_stack = 1,

        -- Affected by:
        -- reverberation[394332] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
    -- Fatebound Coin (Heads) bonus.
    fatebound_coin_heads = {
        id = 456479,
        duration = 3600.0,
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
    -- Finding treasure.
    find_treasure = {
        id = 199736,
        duration = 3600,
        max_stack = 1,
    },
    -- Taking $s3% increased damage from the Rogue's abilities.
    ghostly_strike = {
        id = 196937,
        duration = 12.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Incapacitated.
    gouge = {
        id = 1776,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Your next Pistol Shot deals $s2% increased damage.
    greenskins_wickers = {
        id = 394131,
        duration = 15.0,
        max_stack = 1,
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
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Stunned.
    kidney_shot = {
        id = 408,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- stunning_secret[426588] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stunning_secret[426588] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Absorbing all damage.
    killing_spree = {
        id = 424562,
        duration = 3.0,
        max_stack = 1,
    },
    -- Leech increased by $s1%.
    leeching_poison = {
        id = 108211,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- master_poisoner[378436] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- assassination_rogue[137037] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Your next $?s5171[Slice and Dice will be $w1% more effective][Roll the Bones will grant at least two matches].
    loaded_dice = {
        id = 256171,
        duration = 45.0,
        max_stack = 1,
    },
    -- Agility increased by $w1%.
    lucky_coin = {
        id = 452562,
        duration = 3600,
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
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Movement speed reduced by $s3%$?a428377[ and dealing $s4% less damage to the Rogue.][.]
    pistol_shot = {
        id = 185763,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- precision_shot[428377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- greenskins_wickers[394131] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Gained a random combat enhancement.
    roll_the_bones = {
        id = 315508,
        duration = 30.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- Incapacitated.$?$w2!=0[; Damage taken increased by $w2%.][]
    sap = {
        id = 6770,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dont_be_suspicious[441415] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Energy cost of abilities reduced by $w1%.
    shadow_focus = {
        id = 112942,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed increased by $s2%.
    shadowstep = {
        id = 36554,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- shadowstep[394931] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Concealed in shadows.
    shroud_of_concealment = {
        id = 115834,
        duration = 3600,
        tick_time = 0.5,
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
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- swift_slasher[381988] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- thousand_cuts[441346] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- A smoke cloud interferes with targeting.
    smoke_bomb = {
        id = 212182,
        duration = 5.0,
        max_stack = 1,
    },
    -- Healing $w1% of max health every $t.
    soothing_darkness = {
        id = 393971,
        duration = 6.0,
        max_stack = 1,
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
    -- Stealthed.$?$w3!=0[; Movement speed increased by $w3%.][]
    stealth = {
        id = 1784,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- shadowheart[455131] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- shadowrunner[378807] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- subterfuge[108208] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'trigger_spell': 1784, 'triggers': stealth, 'spell': 115191, 'value': 1784, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Damage taken increased by $w1%.
    stinging_vulnerability = {
        id = 255909,
        duration = 6.0,
        max_stack = 1,
    },
    -- Dispatch deals $w1% increased damage and costs $w2 less Energy.
    summarily_dispatched = {
        id = 386868,
        duration = 8.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    take_your_cut = {
        id = 198368,
        duration = 10.0,
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
    -- Damage done increased by $m1%.
    turn_the_tables = {
        id = 198027,
        duration = 12.0,
        max_stack = 1,
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
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_wound_poison[319066] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- master_poisoner[378436] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- virulent_poisons[381543] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- ghostly_strike[196937] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Increases your Energy regeneration rate by $s1%, your maximum Energy by $s4, and your attack speed by $s2% for $d.
    adrenaline_rush = {
        id = 13750,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        talent = "adrenaline_rush",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_POWER_REGEN_PERCENT, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'resource': energy, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MELEE_RANGED_HASTE_2, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_MAX_POWER, 'points': 50.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

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
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_ambush[381620] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ghostly_strike[196937] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- destiny_defined[454435] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },

    -- Finishing move that deals damage with your pistol, increasing your critical strike chance by $s2%.$?a235484[ Critical strikes with this ability deal four times normal damage.][];    1 point : ${$<damage>*1} damage, 3 sec;    2 points: ${$<damage>*2} damage, 6 sec;    3 points: ${$<damage>*3} damage, 9 sec;    4 points: ${$<damage>*4} damage, 12 sec;    5 points: ${$<damage>*5} damage, 15 sec$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$<damage>*6} damage, 18 sec][]$?s193531&(s394320|s394321)[;    7 points: ${$<damage>*7} damage, 21 sec][]
    between_the_eyes = {
        id = 315341,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.26, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_PCT, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- devious_stratagem[394321] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_between_the_eyes[235484] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- precision_shot[428377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Strikes up to $?a272026[$331850i][${$331850i-3}] nearby targets for $331850s1 Physical damage$?a381878[ that generates 1 combo point per target][], and causes your single target attacks to also strike up to $?a272026[${$s3+$272026s3}][$s3] additional nearby enemies for $s2% of normal damage for $d.
    blade_flurry = {
        id = 13877,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 15,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 385835, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }

        -- Affected by:
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ambidexterity[381822] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- dancing_steel[272026] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Charge to your target with your blades out, dealing ${$271881sw1*$271881s2/100} Physical damage to the target and $271881sw1 to all other nearby enemies.; While Blade Flurry is active, damage to non-primary targets is increased by $s1%.; Generates ${$271896s1*$271896d/$271896t1} Energy over $271896d.
    blade_rush = {
        id = 271877,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "blade_rush",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- deft_maneuvers[385835] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- blinding_powder[256165] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- blinding_powder[256165] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- devious_stratagem[394321] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

        -- Affected by:
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Finishing move that dispatches the enemy, dealing damage per combo point:;    1 point  : ${$m1*1} damage;    2 points: ${$m1*2} damage;    3 points: ${$m1*3} damage;    4 points: ${$m1*4} damage;    5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[;    7 points: ${$m1*7} damage][]
    dispatch = {
        id = 2098,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 35,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.315, 'pvp_multiplier': 1.2, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- devious_stratagem[394321] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ghostly_strike[196937] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- summarily_dispatched[386868] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- summarily_dispatched[386868] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Aura Points Stack'], 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- devious_stratagem[394321] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- death_from_above[269512] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.375, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_from_above[269512] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- death_from_above[269512] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
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

    -- You can sense nearby treasure, making it appear on the minimap. Lasts $d.
    find_treasure = {
        id = 199736,
        color = 'racial',
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRACK_RESOURCES, 'variance': 0.25, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Strikes an enemy, dealing $s1 Physical damage and causing the target to take $s3% increased damage from your abilities for $d.; Awards $s2 combo $lpoint:points;.
    ghostly_strike = {
        id = 196937,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        spend = 35,
        spendType = 'energy',

        talent = "ghostly_strike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.6, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 3.0, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Increase the remaining duration of your active Roll the Bones combat enhancements by $s1 sec.
    keep_it_rolling = {
        id = 381989,
        cast = 0.0,
        cooldown = 420.0,
        gcd = "none",

        talent = "keep_it_rolling",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
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

        -- Affected by:
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- stunning_secret[426588] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stunning_secret[426588] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Finishing move that teleports to an enemy within $r yds, striking with both weapons for Physical damage. Number of strikes increased per combo point.; $s6% of damage taken during effect is delayed, instead taken over 8 sec.;    1 point  : ${$<dmg>*2} over ${$424556d}.2 sec;    2 points: ${$<dmg>*3} over ${$424556d*2}.2 sec;    3 points: ${$<dmg>*4} over ${$424556d*3}.2 sec;    4 points: ${$<dmg>*5} over ${$424556d*4}.2 sec;    5 points: ${$<dmg>*6} over ${$424556d*5}.2 sec$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$<dmg>*7} over ${$424556d*6}.2 sec][]$?s193531&(s394320|s394321)[;    7 points: ${$<dmg>*8} over ${$424556d*7}.2 sec][]
    killing_spree = {
        id = 51690,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 45,
        spendType = 'energy',

        spend = 1,
        spendType = 'happiness',

        talent = "killing_spree",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.3, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- deeper_stratagem[193531] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tight_spender[381621] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- devious_stratagem[394321] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- disorienting_strikes[441274] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- dont_be_suspicious[441415] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Draw a concealed pistol and fire a quick shot at an enemy, dealing ${$s1*$<CAP>/$AP} Physical damage$?a428377[, also reducing movement speed by $s3% and reducing the target's damage done to you by $s4% for $d.][ and reducing movement speed by $s3% for $d.]; Awards $s2 combo $lpoint:points;.
    pistol_shot = {
        id = 185763,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.376, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'ap_bonus': 0.19656, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': happiness, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'pvp_multiplier': 0.6, 'points': -5.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- precision_shot[428377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- greenskins_wickers[394131] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Roll the dice of fate, providing a random combat enhancement for $d.
    roll_the_bones = {
        id = 315508,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 25,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- deeper_stratagem[193531] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
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
        -- rushed_setup[378803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dirty_tricks[108216] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dont_be_suspicious[441415] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
        -- shadowstep[394931] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
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
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ghostly_strike[196937] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    },

    -- Viciously strike an enemy, causing ${$s1*$<mult>} Physical damage.$?s279876[; Has a $s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.][]; Awards $s2 combo $lpoint:points; each time it strikes.
    sinister_strike = {
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
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- heavy_hitter[381885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- heavy_hitter[381885] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deft_maneuvers[385835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- fazed[441224] #3: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Viciously strike an enemy, causing $s1 Physical damage.; Awards $s2 combo $lpoint:points;.
    sinister_strike_1752 = {
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
        -- outlaw_rogue[137036] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- outlaw_rogue[137036] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cold_blood[382245] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- deadly_precision[381542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lethality[382238] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- ghostly_strike[196937] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- assassination_rogue[137037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- assassination_rogue[137037] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- assassination_rogue[137037] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fazed[441224] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
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
        -- adrenaline_rush[13750] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- devious_stratagem[394321] #0: { 'type': APPLY_AURA, 'subtype': MOD_ADDITIONAL_POWER_COST, 'points': 1.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
        -- swift_slasher[381988] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- thousand_cuts[441346] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Creates a cloud of thick smoke in an $m2 yard radius around the Rogue for $d. Enemies are unable to target into or out of the smoke cloud. 
    smoke_bomb = {
        id = 212182,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 180.0,
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