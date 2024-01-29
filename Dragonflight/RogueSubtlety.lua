-- RogueSubtlety.lua
-- November 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local insert, wipe = table.insert, table.wipe
local strformat = string.format

local spec = Hekili:NewSpecialization( 261 )

spec:RegisterResource( Enum.PowerType.Energy, {
    shadow_techniques = {
        last = function () return state.query_time end,
        interval = function () return state.time_to_sht[5] end,
        value = 8,
        stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
    }
} )

spec:RegisterResource( Enum.PowerType.ComboPoints )

-- Talents
spec:RegisterTalents( {
    -- Rogue Talents
    acrobatic_strikes          = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by $s1 yds.
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
    echoing_reprimand          = { 90639, 385616, 1 }, -- Deal $s1 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.;
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
    -- marked_for_death           = { 90750, 137619, 1 }, -- Marks the target, instantly granting full combo points and increasing the damage of your finishing moves by $s1% for $d. Cooldown resets if the target dies during effect.
    master_poisoner            = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%.
    nightstalker               = { 90693, 14062 , 2 }, -- While Stealth$?c3[ or Shadow Dance][] is active, your abilities deal $s1% more damage.
    nimble_fingers             = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1.
    numbing_poison             = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d.  Each strike has a $5761h% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $5760s1% for $5760d.
    recuperator                = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per 2 sec.
    resounding_clarity         = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges $m1 additional combo $Lpoint:points;.
    reverberation              = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by $s1%.
    rushed_setup               = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%.
    shadow_dance               = { 90689, 185313, 1 }, -- Description not found.
    shadowrunner               = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster.
    shadowstep                 = { 90695, 36554 , 1 }, -- Description not found.
    shiv                       = { 90740, 5938  , 1 }, -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    soothing_darkness          = { 90691, 393970, 1 }, -- You are healed for ${$393971s1*($393971d/$393971t)}% of your maximum health over $393971d after gaining Vanish or Shadow Dance.
    stillshroud                = { 94561, 423662, 1 }, -- Shroud of Concealment has $s1% reduced cooldown.;
    subterfuge                 = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for ${$s2/1000} sec after Stealth breaks.
    superior_mixture           = { 94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional $s1%.
    thistle_tea                = { 90756, 381623, 1 }, -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    tight_spender              = { 90692, 381621, 1 }, -- Energy cost of finishing moves reduced by $s1%.
    tricks_of_the_trade        = { 90686, 57934 , 1 }, -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    unbreakable_stride         = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects $s1%.
    vigor                      = { 90759, 14983 , 2 }, -- Increases your maximum Energy by $s1 and Energy regeneration by $s2%.
    virulent_poisons           = { 90760, 381543, 1 }, -- Increases the damage of your weapon poisons by $s1%.

    -- Subtlety Talents
    cloaked_in_shadows         = { 90733, 382515, 1 }, -- Vanish grants you a shield for $386165d, absorbing damage equal to $s1% of your maximum health.
    danse_macabre              = { 90730, 382528, 1 }, -- Shadow Dance increases the damage of your attacks that generate or spend combo points by $393969s1%, increased by an additional $393969s1% for each different attack used.
    dark_brew                  = { 90719, 382504, 1 }, -- Your attacks that deal Nature or Bleed damage now deal Shadow instead.; Shadow damage increased by $s2%.
    dark_shadow                = { 90732, 245687, 2 }, -- Shadow Dance increases damage by an additional $s1%.
    deepening_shadows          = { 90724, 185314, 1 }, -- Your finishing moves reduce the remaining cooldown on Shadow Dance by ${$sw1/10}.1 sec per combo point spent.
    deeper_daggers             = { 90721, 382517, 1 }, -- Eviscerate and Black Powder increase your Shadow damage dealt by $383405s1% for $383405d.
    ephemeral_bond             = { 90725, 426563, 1 }, -- Increases healing received by $s1%.;
    exhilarating_execution     = { 90711, 428486, 1 }, -- Your finishing moves heal you for $s1% of damage done. At full health gain shielding instead, absorbing up to $s2% of your maximum health.
    fade_to_nothing            = { 90733, 382514, 1 }, -- Movement speed increased by $386237s1% and damage taken reduced by $386237s2% for $386237d after gaining Stealth, Vanish, or Shadow Dance.
    finality                   = { 90720, 382525, 2 }, -- Eviscerate, Rupture, and Black Powder increase the damage of the next use of the same finishing move by $s1%.
    find_weakness              = { 90690, 91023 , 1 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass $s1% of that enemy's armor for $316220d.
    flagellation               = { 90718, 384631, 1 }, -- Lash the target for $s1 Shadow damage, causing each combo point spent within $d to lash for an additional $345316s1. Dealing damage with Flagellation increases your Mastery by ${$s2*$mas}.1%, persisting $345569d after their torment fades.
    gloomblade                 = { 90699, 200758, 1 }, -- Punctures your target with your shadow-infused blade for $s1 Shadow damage, bypassing armor.$?s319949[ Critical strikes apply Find Weakness for $319949s1 sec.][]; Awards $s2 combo $lpoint:points;.
    goremaws_bite              = { 94581, 426591, 1 }, -- Lashes out at the target, inflicting $426592s1 Shadow damage and causing your next $426593u finishing moves to cost no Energy.; Awards $220901s1 combo $lpoint:points;.
    improved_backstab          = { 90739, 319949, 1 }, -- Backstab has $s2% increased critical strike chance.; When you are behind your target, Backstab critical strikes now also expose a flaw in their defenses, applying Find Weakness for $s1 sec.
    improved_shadow_dance      = { 90734, 393972, 1 }, -- Shadow Dance has ${$s1/1000} sec increased duration.
    improved_shadow_techniques = { 90736, 394023, 1 }, -- Shadow Techniques generates $s1 additional Energy.
    improved_shuriken_storm    = { 90710, 319951, 1 }, -- Shuriken Storm has an additional $s2% chance to crit, and its critical strikes apply Find Weakness for $s1 sec.
    inevitability              = { 90704, 382512, 1 }, -- $?S200758[Gloomblade][Backstab] and Shadowstrike extend the duration of your Symbols of Death by ${$s2/10}.1 sec.
    invigorating_shadowdust    = { 90706, 382523, 2 }, -- Vanish reduces the remaining cooldown of your other Rogue abilities by ${$s1}.1 sec.
    lingering_shadow           = { 90731, 382524, 1 }, -- After Shadow Dance ends, $?s200758[Gloomblade][Backstab] deals an additional $s1% damage as Shadow, fading by ${$s1/$s3}.1% per sec.
    master_of_shadows          = { 90735, 196976, 1 }, -- Gain ${$196980s1*$196980d/$196980t1+$196980s2} Energy over $196980d when you enter Stealth or activate Shadow Dance.
    night_terrors              = { 94582, 277953, 1 }, -- Shuriken Storm reduces enemies' movement speed by $206760s1% for $206760d.
    perforated_veins           = { 90707, 382518, 1 }, -- After striking $s1 times with $?s200758[Gloomblade][Backstab], your next attack that generates combo points deals $426602s1% increased damage.
    planned_execution          = { 90703, 382508, 1 }, -- Symbols of Death increases your critical strike chance by $s1%.
    premeditation              = { 90737, 343160, 1 }, -- After entering Stealth, your next Shadowstrike grants up to $s1 sec of Slice and Dice, and generates $s2 additional combo points if Slice and Dice is active.
    quick_decisions            = { 90728, 382503, 1 }, -- Shadowstep's cooldown is reduced by $s3%, and its maximum range is increased by $s1%.
    relentless_strikes         = { 90709, 58423 , 1 }, -- Your finishing moves generate $98440s2 Energy per combo point spent.
    replicating_shadows        = { 90717, 382506, 1 }, -- Rupture deals an additional $s1% damage as Shadow and applies to $s4 additional nearby enemy.
    secret_stratagem           = { 90722, 394320, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    secret_technique           = { 90715, 280719, 1 }, -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets.;    1 point  : ${$280720m1*1*$<mult>} total damage;    2 points: ${$280720m1*2*$<mult>} total damage;    3 points: ${$280720m1*3*$<mult>} total damage;    4 points: ${$280720m1*4*$<mult>} total damage;    5 points: ${$280720m1*5*$<mult>} total damage$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$280720m1*6*$<mult>} total damage][]$?s193531&(s394320|s394321)[;    7 points: ${$280720m1*7*$<mult>} total damage][]; Cooldown is reduced by $s5 sec for every combo point you spend.
    sepsis                     = { 90704, 385408, 1 }, -- Infect the target's blood, dealing $o1 Nature damage over $d and gaining $s6 use of any Stealth ability. If the target survives its full duration, they suffer an additional $394026s1 damage and you gain $s6 additional use of any Stealth ability for $375939d.; Cooldown reduced by $s3 sec if Sepsis does not last its full duration.; Awards $s7 combo $lpoint:points;.
    shadow_blades              = { 90726, 121471, 1 }, -- Draws upon surrounding shadows to empower your weapons, causing your attacks to deal $s1% additional damage as Shadow and causing your combo point generating abilities to generate full combo points for $d.
    shadow_focus               = { 90727, 108209, 1 }, -- Abilities cost $112942m1% less Energy while Stealth or Shadow Dance is active.
    shadowcraft                = { 94580, 426594, 1 }, -- While Symbols of Death is active, your Shadow Techniques triggers $s3% more frequently, stores $m2 additional combo $Lpoint:points;, and finishing moves can use those stored when there are enough to refresh full combo points.
    shadowed_finishers         = { 90723, 382511, 1 }, -- Eviscerate and Black Powder deal an additional $s1% damage as Shadow to targets with your Find Weakness active.
    shot_in_the_dark           = { 90698, 257505, 1 }, -- After entering Stealth or Shadow Dance, your next Cheap Shot is free.
    shrouded_in_darkness       = { 90700, 382507, 1 }, -- Shroud of Concealment increases the movement speed of allies by $s1% and leaving its area no longer cancels the effect.
    shuriken_tornado           = { 90716, 277925, 1 }, -- Focus intently, then release a Shuriken Storm every sec for the next $d.
    silent_storm               = { 90714, 385722, 1 }, -- Gaining Stealth, Vanish, or Shadow Dance causes your next Shuriken Storm to have $385727s1% increased chance to critically strike.
    swift_death                = { 90701, 394309, 1 }, -- Symbols of Death has ${$s1/-1000} sec reduced cooldown.
    terrifying_pace            = { 94582, 428387, 1 }, -- Shuriken Storm increases your movement speed by $428389s1% for $428389d when striking $s1 or more enemies.
    the_first_dance            = { 90735, 382505, 1 }, -- Activating Shadow Dance generates $394029s1 combo points.
    the_rotten                 = { 90705, 382015, 1 }, -- After activating Symbols of Death, your next $@switch<$s1>[attack][$s1 attacks] that $@switch<$s1>[generates][generate] combo points $@switch<$s1>[deals][deal] $394203s3% increased damage and $@switch<$s1>[is][are] guaranteed to critically strike.
    veiltouched                = { 90713, 382017, 1 }, -- Your abilities deal $s1% increased magic damage.
    warning_signs              = { 90703, 426555, 1 }, -- Symbols of Death increases your Haste by $s1%.
    weaponmaster               = { 90738, 193537, 1 }, -- $?s200758[Gloomblade][Backstab] and Shadowstrike have a $s1% chance to hit the target twice each time they deal damage$?a134735[, striking for $s3% of normal damage][].
    without_a_trace            = { 90702, 382513, 1 }, -- Vanish has $s1 additional $lcharge:charges;.
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
    veil_of_midnight   = 136 , -- (198952) Cloak of Shadows now also removes harmful physical effects and increases dodge chance by ${-$31224m1/2}%.
} )


-- Auras
spec:RegisterAuras( {
    -- Disoriented.
    blind = {
        id = 2094,
        duration = function() return 60 * ( talent.airborne_irritant.enabled and 0.6 or 1 ) end,
        max_stack = 1,

        -- Affected by:
        -- [x] airborne_irritant[200733] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    danse_macabre = {
        id = 393969,
        duration = function () return talent.subterfuge.enabled and 9 or 8 end,
        max_stack = 10
    },
    deeper_daggers = {
        id = 383405,
        duration = 8,
        max_stack = 1,
        copy = 341550 -- Conduit version.
    },
    finality_black_powder = {
        id = 385948,
        duration = 30,
        max_stack = 1
    },
    finality_eviscerate = {
        id = 385949,
        duration = 30,
        max_stack = 1
    },
    finality_rupture = {
        id = 385951,
        duration = 30,
        max_stack = 1,
    },
    flagellation = {
        id = 323654,
        duration = 12,
        max_stack = 30
    },
    flagellation_buff = {
        id = 384631,
        duration = 12,
        max_stack = 30
    },
    flagellation_persist = {
        id = 394758,
        duration = 12,
        max_stack = 30,
        copy = 345569,
    },
    -- Your finishing moves cost no Energy.
    -- TODO: Does Goremaw's Bite track by value or by stacks?
    goremaws_bite = {
        id = 426593,
        duration = 30,
        max_stack = 3,

        -- Affected by:
        -- shadow_blades[121471] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Talent: $?s200758[Gloomblade][Backstab] deals an additional $s1% damage as Shadow.
    -- https://wowhead.com/beta/spell=385960
    lingering_shadow = {
        id = 385960,
        duration = 18,
        tick_time = 1,
        max_stack = 50
    },
    -- Marked for death, taking extra damage from @auracaster's finishing moves. Cooldown resets upon death.
    marked_for_death = {
        id = 137619,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- subtlety_rogue[137035] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    master_of_shadows = {
        id = 196980,
        duration = 3,
        max_stack = 1,
    },
    perforated_veins_stack = {
        id = 394254,
        duration = 3600,
        max_stack = 4
    },
    -- At $394254u stacks, your next attack that generates combo points deals $w1% increased damage.
    perforated_veins = {
        id = 426602,
        duration = 3600,
        max_stack = 1,
    },
    premeditation = {
        id = 343173,
        duration = 3600,
        max_stack = 1,
    },
    secret_technique = {
        duration = 1.3,
        max_stack = 1,
        generate = function( t )
            local applied = action.secret_technique.lastCast
            local expires = applied + 1.3

            if query_time < expires then
                t.name = t.name or GetSpellInfo( 280719 ) or "secret_technique"
                t.count = 1
                t.applied = applied
                t.duration = 1.3
                t.expires = expires
                t.caster = "player"
                return
            end

            t.name = t.name or GetSpellInfo( 280719 ) or "secret_technique"
            t.count = 0
            t.applied = 0
            t.duration = 1.3
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Talent: Combo point generating abilities generate $s2 additional combo point and deal $s1% additional damage as Shadow.
    -- https://wowhead.com/beta/spell=121471
    shadow_blades = {
        id = 121471,
        duration = 20,
        max_stack = 1
    },
    shadow_techniques = {
        id = 196911,
        duration = 3600,
        max_stack = 14,
    },
    shot_in_the_dark = {
        id = 257506,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Releasing a Shuriken Storm every sec.
    -- https://wowhead.com/beta/spell=277925
    shuriken_tornado = {
        id = 277925,
        duration = 4,
        max_stack = 1
    },
    silent_storm = {
        id = 385727,
        duration = 3600,
        max_stack = 1
    },
    subterfuge = {
        id = 115192,
        duration = 3,
        max_stack = 1,
    },
    symbols_of_death_crit = {
        id = 227151,
        duration = 10,
        max_stack = 1,
        copy = "symbols_of_death_autocrit"
    },
    -- Talent: Your next Shadowstrike or $?s200758[Gloomblade][Backstab] deals $s3% increased damage, generates $s1 additional combo points, and is guaranteed to critically strike.
    -- https://wowhead.com/beta/spell=394203
    the_rotten = {
        id = 394203,
        duration = 30,
        max_stack = 1,
        copy = 341134
    },

    -- Azerite Powers
    blade_in_the_shadows = {
        id = 279754,
        duration = 60,
        max_stack = 10,
    },
    nights_vengeance = {
        id = 273424,
        duration = 8,
        max_stack = 1,
    },
    perforate = {
        id = 277720,
        duration = 12,
        max_stack = 1
    },
    replicating_shadows = {
        id = 286131,
        duration = 1,
        max_stack = 50
    },
    the_first_dance = {
        id = 278981,
        duration = function () return buff.shadow_dance.duration end,
        max_stack = 1,
    },

    -- Conduit
    perforated_veins_conduit = {
        id = 341572,
        duration = 12,
        max_stack = 6
    },

    -- Legendaries (Shadowlands)
    deathly_shadows = {
        id = 341202,
        duration = 15,
        max_stack = 1,
    },
    master_assassins_mark = {
        id = 340094,
        duration = 4,
        max_stack = 1
    },
} )


local true_stealth_change = 0
local emu_stealth_change = 0

spec:RegisterEvent( "UPDATE_STEALTH", function ()
    true_stealth_change = GetTime()
end )


local last_mh = 0
local last_oh = 0
local last_shadow_techniques = 0
local swings_since_sht = 0

local danse_ends = 0
local danse_macabre_actual = {}

spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike )
    if not sourceGUID == state.GUID then return end

    if subtype == "SPELL_ENERGIZE" and spellID == 196911 then
        last_shadow_techniques = GetTime()
        swings_since_sht = 0

    elseif subtype:sub( 1, 5 ) == "SWING" and not multistrike then
        if subtype == "SWING_MISSED" then
            offhand = spellName
        end

        local now = GetTime()

        if now > last_shadow_techniques + 3 then
            swings_since_sht = swings_since_sht + 1
        end

        if offhand then last_mh = GetTime()
        else last_mh = GetTime() end
    end

    if state.talent.danse_macabre.enabled and subtype == "SPELL_CAST_SUCCESS" then
        if spellID == 185313 then
            -- Start fresh with each Shadow Dance.
            wipe( danse_macabre_actual )
            danse_ends = GetTime() + 8

        elseif danse_ends > GetTime() then
            local ability = class.abilities[ spellID ]

            if ability then
                danse_macabre_actual[ ability.key ] = true
            end
        end
    end
end )


local sht = {}

spec:RegisterStateTable( "time_to_sht", setmetatable( {}, {
    __index = function( t, k )
        local n = tonumber( k )
        n = n - ( n % 1 )

        if not n or n > 5 then return 3600 end

        if n <= swings_since_sht then return 0 end

        local mh_speed = swings.mainhand_speed
        local mh_next = ( swings.mainhand > now - 3 ) and ( swings.mainhand + mh_speed ) or now + ( mh_speed * 0.5 )

        local oh_speed = swings.offhand_speed
        local oh_next = ( swings.offhand > now - 3 ) and ( swings.offhand + oh_speed ) or now

        table.wipe( sht )

        if mh_speed and mh_speed > 0 then
            for i = 1, 4 do
                insert( sht, mh_next + ( i * mh_speed ) )
            end
        end

        if oh_speed and oh_speed > 0 then
            for i = 1, 4 do
                insert( sht, oh_next + ( i * oh_speed ) )
            end
        end

        local i = 1

        while( sht[i] ) do
            if sht[i] < last_shadow_techniques + 3 then
                table.remove( sht, i )
            else
                i = i + 1
            end
        end

        if #sht > 0 and n - swings_since_sht < #sht then
            table.sort( sht )
            return max( 0, sht[ n - swings_since_sht ] - query_time )
        else
            return 3600
        end
    end
} ) )

spec:RegisterStateTable( "time_to_sht_plus", setmetatable( {}, {
    __index = function( t, k )
        local n = tonumber( k )
        n = n - ( n % 1 )

        if not n or n > 5 then return 3600 end
        local val = time_to_sht[k]

        -- Time of next attack instead.
        if val == 0 then
            local last = swings.mainhand
            local speed = swings.mainhand_speed
            local swing = 3600

            if last > 0 and speed > 0 then
                swing = last + ( ceil( ( query_time - last ) / speed ) * speed ) - query_time
            end

            last = swings.offhand
            speed = swings.offhand_speed

            if last > 0 and speed > 0 then
                swing = min( swing, last + ( ceil( ( query_time - last ) / speed ) * speed ) - query_time )
            end

            return swing
        end

        return val
    end,
} ) )


spec:RegisterStateExpr( "bleeds", function ()
    return ( debuff.garrote.up and 1 or 0 ) + ( debuff.rupture.up and 1 or 0 )
end )


spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )


spec:RegisterStateExpr( "effective_combo_points", function ()
    local c = combo_points.current or 0
    if not talent.echoing_reprimand.enabled and not covenant.kyrian then return c end
    if c < 2 or c > 5 then return c end
    if buff[ "echoing_reprimand_" .. c ].up then return 7 end
    return c
end )


-- Legendary from Legion, shows up in APL still.
spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
spec:RegisterGear( "denial_of_the_halfgiants", 137100 )

local function comboSpender( amt, resource )
    if resource == "combo_points" then
        if amt > 0 then
            gain( 6 * amt, "energy" )
        end

        if talent.alacrity.enabled and amt >= 5 then
            addStack( "alacrity" )
        end

        if talent.secret_technique.enabled then
            reduceCooldown( "secret_technique", amt )
        end

        reduceCooldown( "shadow_dance", amt * ( talent.enveloping_shadows.enabled and 1.5 or 1 ) )

        if legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
        end
    end
end

spec:RegisterHook( "spend", comboSpender )

local function st_gain( token )
    local amount = action[ token ].cp_gain
    local st_addl_gain = max( 0, min( combo_points.deficit - amount, buff.shadow_techniques.stack ) )

    if st_addl_gain > 0 then
        removeStack( "shadow_techniques", st_addl_gain )
        amount = amount + st_addl_gain
    end

    gain( amount, "combo_points" )
end

setfenv( st_gain, state )
-- spec:RegisterHook( "spendResources", comboSpender )


spec:RegisterStateExpr( "mantle_duration", function ()
    return legendary.mark_of_the_master_assassin.enabled and 4 or 0
end )

spec:RegisterStateExpr( "master_assassin_remains", function ()
    if not legendary.mark_of_the_master_assassin.enabled then return 0 end

    if stealthed.mantle then return cooldown.global_cooldown.remains + 4
    elseif buff.master_assassins_mark.up then return buff.master_assassins_mark.remains end
    return 0
end )


-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if stealthed.mantle and ( not a or a.startsCombat ) then
        if talent.subterfuge.enabled then
            applyBuff( "subterfuge" )
        end

        if legendary.mark_of_the_master_assassin.enabled then
            applyBuff( "master_assassins_mark" )
        end

        if buff.stealth.up then
            setCooldown( "stealth", 2 )
        end

        removeBuff( "stealth" )
        removeBuff( "vanish" )
        removeBuff( "shadowmeld" )
    end

    if buff.shadow_dance.up and talent.danse_macabre.enabled and not danse_macabre_tracker[ a.key ] then
        danse_macabre_tracker[ a.key ] = true
        addStack( "danse_macabre" )
    end

    if buff.cold_blood.up and ( not a or a.startsCombat ) then
        removeBuff( "cold_blood" )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
end )


local ExpireSepsis = setfenv( function ()
    applyBuff( "sepsis_buff" )

    if legendary.toxic_onslaught.enabled then
        applyBuff( "adrenaline_rush", 10 )
        applyDebuff( "target", "vendetta", 10 )
    end
end, state )


spec:RegisterStateTable( "danse_macabre_tracker", setmetatable( {}, {
    __index = function( t, k )
        return false
    end,
} ) )

spec:RegisterStateExpr( "used_for_danse", function()
    if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
    return danse_macabre_tracker[ this_action ]
end )


spec:RegisterHook( "reset_precast", function( amt, resource )
    if talent.danse_macabre.enabled then
        wipe( danse_macabre_tracker )
        if buff.shadow_dance.up then
            for k in pairs( danse_macabre_actual ) do
                danse_macabre_tracker[ k ] = true
            end
        end
    end

    if debuff.sepsis.up then
        state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
    end

    if buff.shuriken_tornado.up then
        local moment = buff.shuriken_tornado.expires - 0.02
        while( moment > query_time ) do
            state:QueueAuraEvent( "shuriken_tornado", class.abilities.shuriken_storm.handler, moment, "AURA_PERIODIC" )
            moment = moment - 1
        end
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    if buff.cold_blood.up then setCooldown( "cold_blood", action.cold_blood.cooldown ) end
end )

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "COMBO_POINTS" then
        Hekili:ForceUpdate( powerType, true )
    end
end )

spec:RegisterCycle( function ()
    if this_action == "marked_for_death" then
        if cycle_enemies == 1 or active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
        if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
        if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
    end
end )

spec:RegisterGear( "insignia_of_ravenholdt", 137049 )
spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
    spec:RegisterAura( "master_assassins_initiative", {
        id = 235027,
        duration = 5
    } )

    spec:RegisterStateExpr( "mantle_duration", function()
        if stealthed.mantle then return cooldown.global_cooldown.remains + buff.master_assassins_initiative.duration
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0
    end )


spec:RegisterGear( "shadow_satyrs_walk", 137032 )
    spec:RegisterStateExpr( "ssw_refund_offset", function()
        return target.maxR
    end )

spec:RegisterGear( "soul_of_the_shadowblade", 150936 )
spec:RegisterGear( "the_dreadlords_deceit", 137021 )
    spec:RegisterAura( "the_dreadlords_deceit", {
        id = 228224,
        duration = 3600,
        max_stack = 20,
        copy = 208693
    } )

spec:RegisterGear( "the_first_of_the_dead", 151818 )
    spec:RegisterAura( "the_first_of_the_dead", {
        id = 248210,
        duration = 2
    } )

spec:RegisterGear( "will_of_valeera", 137069 )
    spec:RegisterAura( "will_of_valeera", {
        id = 208403,
        duration = 5
    } )


-- Tier Sets
spec:RegisterGear( "tier21", 152163, 152165, 152161, 152160, 152162, 152164 )
spec:RegisterGear( "tier20", 147172, 147174, 147170, 147169, 147171, 147173 )
spec:RegisterGear( "tier19", 138332, 138338, 138371, 138326, 138329, 138335 )

-- Tier 31
-- Tier 31
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207239 )

-- Tier 30
spec:RegisterGear( "tier30", 202500, 202498, 202497, 202496, 202495 )
-- Shadow Dance is in RogueAssassination.lua, so the 2pc bonus is handled there.

-- DF Tier Set
spec:RegisterGear( "tier29", 200369, 200371, 200372, 200373, 200374 )
spec:RegisterAuras( {
    honed_blades = {
        id = 394894,
        duration = 15,
        max_stack = 7 -- ???
    },
    masterful_finish = {
        id = 395003,
        duration = 3,
        max_stack = 1
    }
})



-- Abilities
spec:RegisterAbilities( {
    -- Stab the target, causing 632 Physical damage. Damage increased by 20% when you are behind your target, and critical strikes apply Find Weakness for 10 sec. Awards 1 combo point.
    backstab = {
        id = 53,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        notalent = "gloomblade",

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( buff.broadside.up and 1 or 0 ) + buff.secret_techniques.stack
        end,

        handler = function ()
            removeBuff( "honed_blades" )
            applyDebuff( "target", "shadows_grasp", 8 )

            if azerite.perforate.enabled and buff.perforate.up then
                -- We'll assume we're attacking from behind if we've already put up Perforate once.
                addStack( "perforate" )
                gainChargeTime( "shadow_blades", 0.5 )
            end

            st_gain( "backstab" )

            removeBuff( "the_rotten" )
            removeBuff( "symbols_of_death_crit" )
            removeBuff( "perforated_veins" )
        end,

        bind = "shadowstrike"
    },

    -- Talent: Finishing move that launches explosive Black Powder at all nearby enemies dealing Physical damage. Deals reduced damage beyond 8 targets. All nearby targets with your Find Weakness suffer an additional 20% damage as Shadow. 1 point : 135 damage 2 points: 271 damage 3 points: 406 damage 4 points: 541 damage 5 points: 676 damage 6 points: 812 damage
    black_powder = {
        id = 319175,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,

        usable = function () return combo_points.current > 0, "requires combo_points" end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.black_powder
        end,

        handler = function ()
            removeBuff( "masterful_finish" )

            if talent.alacrity.enabled and effective_combo_points > 4 then addStack( "alacrity" ) end
            removeBuff( "echoing_reprimand_" .. combo_points.current )

            if buff.finality_black_powder.up then removeBuff( "finality_black_powder" )
            elseif talent.finality.enabled then applyBuff( "finality_black_powder" ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "honed_blades", nil, effective_combo_points ) end

            spend( combo_points.current, "combo_points" )
            if talent.deeper_daggers.enabled or conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
        end,
    },

    -- Stuns the target for 4 sec. Awards 1 combo point.
    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.shot_in_the_dark.up then return 0 end
            return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 )
        end,
        spendType = "energy",

        startsCombat = true,
        nodebuff = "cheap_shot",

        usable = function ()
            if boss then return false, "cheap_shot assumed unusable in boss fights" end
            return stealthed.all, "not stealthed"
        end,

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            applyDebuff( "target", "find_weakness" )

            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end

            applyDebuff( "target", "cheap_shot" )
            removeBuff( "shot_in_the_dark" )

            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

            st_gain( "cheap_shot" )

            if buff.cold_blood.up then removeBuff( "cold_blood" )
            elseif buff.the_rotten.up then removeStack( "the_rotten" ) end
        end,
    },

    -- Talent: Deal $s1 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.    Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.    |cFFFFFFFFAwards $s3 combo $lpoint:points;.|r
    echoing_reprimand = {
        id = function() return talent.echoing_reprimand.enabled and 385616 or 323547 end,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "arcane",

        spend = 10,
        spendType = "energy",

        startsCombat = true,
        toggle = "cooldowns",

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            return 2 + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            -- Can't predict the Animacharge, unless you have the talent/legendary.
            if legendary.resounding_clarity.enabled or talent.resounding_clarity.enabled then
                applyBuff( "echoing_reprimand_2", nil, 2 )
                applyBuff( "echoing_reprimand_3", nil, 3 )
                applyBuff( "echoing_reprimand_4", nil, 4 )
                applyBuff( "echoing_reprimand_5", nil, 5 )
            end

            st_gain( "echoing_reprimand" )

            if buff.cold_blood.up then removeBuff( "cold_blood" )
            elseif buff.the_rotten.up then removeStack( "the_rotten" ) end
        end,

        copy = { 385616, 323547 },
    },

    -- Finishing move that disembowels the target, causing damage per combo point. Targets with Find Weakness suffer an additional 20% damage as Shadow. 1 point : 273 damage 2 points: 546 damage 3 points: 818 damage 4 points: 1,091 damage 5 points: 1,363 damage 6 points: 1,636 damage
    eviscerate = {
        id = 196819,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        usable = function () return combo_points.current > 0, "requires combo points" end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.eviscerate
        end,

        handler = function ()
            removeBuff( "masterful_finish" )
            removeBuff( "cold_blood" )

            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity" )
            end
            removeBuff( "nights_vengeance" )

            if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
            elseif talent.finality.enabled then applyBuff( "finality_eviscerate" ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "honed_blades", nil, effective_combo_points ) end

            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )

            if talent.deeper_daggers.enabled or conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
        end,

        copy = 328082
    },

    -- TODO: Does Flagellation generate combo points with Shadow Blades?
    flagellation = {
        id = function() return talent.flagellation.enabled and 384631 or 323654 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0,
        spendType = "energy",

        startsCombat = true,
        texture = 3565724,

        toggle = "essences",

        indicator = function ()
            if settings.cycle and args.cycle_targets == 1 and active_enemies > 1 and target.time_to_die < longest_ttd then
                return "cycle"
            end
        end,

        handler = function ()
            applyBuff( talent.flagellation.enabled and "flagellation_buff" or "flagellation" )
            applyDebuff( "target", "flagellation" )
        end,

        copy = { 384631, 323654 }
    },

    -- Talent: Punctures your target with your shadow-infused blade for 760 Shadow damage, bypassing armor. Critical strikes apply Find Weakness for 10 sec. Awards 1 combo point.
    gloomblade = {
        id = 200758,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "shadow",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        talent = "gloomblade",
        startsCombat = true,

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            applyDebuff( "target", "shadows_grasp", 8 )
            if buff.stealth.up then removeBuff( "stealth" ) end

            st_gain( "gloomblade" )

            if buff.cold_blood.up then removeBuff( "cold_blood" )
            elseif buff.the_rotten.up then removeStack( "the_rotten" )
            else removeBuff( "symbols_of_death_crit" ) end
        end,
    },


    -- Lashes out at the target, inflicting $426592s1 Shadow damage and causing your next $426593u finishing moves to cost no Energy.; Awards $220901s1 combo $lpoint:points;.
    goremaws_bite = {
        id = 426591,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = function() return 25  * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "goremaws_bite",
        startsCombat = true,

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return 3 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function()
            st_gain( "goremaws_bite" )

            applyBuff( "goremaws_bite" )
            if buff.cold_blood.up then removeBuff( "cold_blood" )
            elseif buff.the_rotten.up then removeStack( "the_rotten" ) end
        end,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 426592, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 426593, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dark_brew[382504] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deeper_daggers[383405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- perforated_veins[394254] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.6, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- the_rotten[394203] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- perforated_veins[426602] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Talent: Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets. 1 point : 692 total damage 2 points: 1,383 total damage 3 points: 2,075 total damage 4 points: 2,767 total damage 5 points: 3,458 total damage 6 points: 4,150 total damage Cooldown is reduced by 1 sec for every combo point you spend.
    secret_technique = {
        id = 280719,
        cast = 0,
        cooldown = function () return 45 - min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ) end,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        talent = "secret_technique",
        startsCombat = true,

        usable = function () return combo_points.current > 0, "requires combo_points" end,
        handler = function ()
            applyBuff( "secret_technique" ) -- fake buff for APL logic.
            removeStack( "goremaws_bite" )
            if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity" ) end
            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
        end,
    },

    -- Draws upon surrounding shadows to empower your weapons, causing your attacks to deal $s1% additional damage as Shadow and causing your combo point generating abilities to generate full combo points for $d.
    shadow_blades = {
        id = 121471,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end,
        gcd = "off",
        school = "physical",

        talent = "shadow_blades",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "shadow_blades" )
        end,
    },

    -- Strike the target, dealing 1,118 Physical damage. While Stealthed, you strike through the shadows and appear behind your target up to 25 yds away, dealing 25% additional damage. Awards 3 combo points.
    shadowstrike = {
        id = 185438,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return ( 45 - ( azerite.blade_in_the_shadows.enabled and 2 or 0 ) ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        cycle = function () return talent.find_weakness.enabled and "find_weakness" or nil end,

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            return 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( buff.premeditation.up and buff.slice_and_dice.up and 2 or 0 )
        end,

        usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.shadowstrike
        end,

        handler = function ()
            st_gain( "shadowstrike" )

            removeBuff( "honed_blades" )
            removeBuff( "symbols_of_death_crit" )
            removeBuff( "the_rotten" )

            if azerite.blade_in_the_shadows.enabled then addStack( "blade_in_the_shadows" ) end
            if buff.premeditation.up then
                if buff.slice_and_dice.up then
                    if buff.slice_and_dice.remains < 10 then buff.slice_and_dice.expires = query_time + 10 end
                else
                    applyBuff( "slice_and_dice", 10 )
                end
                removeBuff( "premeditation" )
            end

            if conduit.perforated_veins.enabled then
                addStack( "perforated_veins" )
            end

            removeBuff( "sepsis_buff" )

            applyDebuff( "target", "find_weakness" )
        end,

        bind = "backstab"
    },

    -- Talent: Attack with your off-hand, dealing 386 Physical damage, dispelling all enrage effects and applying a concentrated form of your Crippling Poison, reducing movement speed by 70% for 5 sec. Awards 1 combo point.
    shiv = {
        id = 5938,
        cast = 0,
        charges = function()
            if talent.lightweight_shiv.enabled then return 2 end
        end,
        cooldown = 25,
        recharge = function()
            if talent.lightweight_shiv.enabled then return 25 end
        end,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up or talent.tiny_toxic_blade.enabled or legendary.tiny_toxic_blade.enabled then return 0 end
            return 30
        end,
        spendType = "energy",

        talent = "shiv",
        startsCombat = true,

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( buff.broadside.up and 1 or 0 )
        end,

        handler = function ()
            st_gain( "shiv" )
            removeDebuff( "target", "dispellable_enrage" )
            if talent.improved_shiv.enabled then applyDebuff( "target", "shiv" ) end
        end,
    },

    -- Sprays shurikens at all enemies within 13 yards, dealing 369 Physical damage. Deals reduced damage beyond 8 targets. Critical strikes with Shuriken Storm apply Find Weakness for 10 sec. Awards 1 combo point per target hit.
    shuriken_storm = {
        id = 197835,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        nobuff = "shuriken_tornado",

        startsCombat = true,
        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return active_enemies
        end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.shuriken_storm
        end,

        handler = function ()
            removeBuff( "honed_blades" )
            removeBuff( "symbols_of_death_crit" )
            removeStack( "the_rotten" )

            if buff.silent_storm.up then
                applyDebuff( "target", "find_weakness" )
                active_dot.find_weakness = active_enemies
                removeBuff( "silent_storm" )
            end

            st_gain( "shuriken_storm" )
        end,
    },

    -- Talent: Focus intently, then release a Shuriken Storm every sec for the next 4 sec.
    shuriken_tornado = {
        id = 277925,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "physical",

        spend = function ()
            return 60 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
        end,
        spendType = "energy",

        talent = "shuriken_tornado",
        startsCombat = true,

        handler = function ()
            applyBuff( "shuriken_tornado" )

            local moment = buff.shuriken_tornado.expires - 0.02
            while( moment > query_time ) do
                state:QueueAuraEvent( "shuriken_tornado", class.abilities.shuriken_storm.handler, moment, "AURA_PERIODIC" )
                moment = moment - 1
            end
        end,
    },

    -- Throws a shuriken at an enemy target for 230 Physical damage. Awards 1 combo point.
    shuriken_toss = {
        id = 114014,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return 1
        end,

        handler = function ()


            removeBuff( "symbols_of_death_crit" )
            removeStack( "the_rotten" )
        end,
    },

    -- Invoke ancient symbols of power, generating 40 Energy and increasing damage done by 10% for 10 sec.
    symbols_of_death = {
        id = 212283,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "symbols_of_death" )
            -- applyBuff( "symbols_of_death_crit" )

            if legendary.the_rotten.enabled then applyBuff( "the_rotten" ) end
        end,
    }
} )


spec:RegisterRanges( "pick_pocket", "sinister_strike", "blind", "shadowstep" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    rangeChecker = "pick_pocket",
    rangeFilter = false,

    canFunnel = true,
    funnel = false,

    damage = true,
    damageExpiration = 6,

    potion = "phantom_fire",

    package = "Subtlety",
} )



spec:RegisterSetting( "mfd_points", 3, {
    name = "|T236340:0|t Marked for Death Combo Points",
    desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
    type = "range",
    min = 0,
    max = 5,
    step = 1,
    width = "full"
} )


spec:RegisterSetting( "priority_rotation", false, {
    name = "Use Priority Rotation (Funnel Damage)",
    desc = "If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers.",
    type = "toggle",
    width = "full"
})

spec:RegisterStateExpr( "priority_rotation", function ()
    local prio = settings.priority_rotation
    if prio == nil then return true end
    return prio
end )

spec:RegisterSetting( "rupture_duration", 12, {
    name = strformat( "%s Duration", Hekili:GetSpellLinkWithTexture( 1943 ) ),
    desc = strformat( "If set above 0, %s will not be recommended if the target will die within the timeframe specified.\n\n"
        .. "Popular guides suggest using that a target should live at least 12 seconds for %s to be worth using.\n\n",
        Hekili:GetSpellLinkWithTexture( 1943 ), class.specs[ 259 ].abilities.rupture.name ),
    type = "range",
    min = 0,
    max = 18,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "solo_vanish", true, {
    name = "Allow |T132331:0|t Vanish when Solo",
    desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
    type = "toggle",
    width = "full"
} )


spec:RegisterSetting( "allow_shadowmeld", nil, {
    name = "Allow |T132089:0|t Shadowmeld",
    desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
        "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 261 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 261 ].abilities.shadowmeld.disabled = not val
    end,
} )


spec:RegisterPack( "Subtlety", 20240105, [[Hekili:L3ZAVnoYr(BXyb0i5hksYYEMnW2a7mt2CzVD2Sy9E3hTefvllEMsuHKYE8cb9B)QQ7Mn7hv3K(1KfiiajEeB2DvvxVRIvUz4n)(nxppQKDZVmAWOXdgo4S(d((XFyW53CD5JBy3C9MO47IUf(J1rRG)7R3oRmLv(i(GhtZIMJBqr228y4H3C9STjPL)J13mJExpdw7gwm8ZNp8MRxMmFotSwwr8nxJR9KbdpzWz)19tVoz1(PB3G7s)9)0(FcE4PNmC4jdpfEO)hp475p(ljRZY5R6t0l7d8L9JjFD)0n5zlssz7NMSAtwEP56EVyDBZlxYGnC4G(JQ2WcZvEgFL)Auz8sX6QF8GZpzac2xFxYM9t)TTBk3MJN369txTnTm5KYO8BzL7N(Ws2A9fuSFAg8drRZehpBnB1JWVb)5JanF)u1lMKMUF68e4LYzPrLj3ZsHfwKLTwdmo7KHJ5q5VbRbW8IswuA5YjXZHdkkUmbpS0KIsCx(xBtYzRyRl5450taWFzY9M72i(Ubi7qcIYaGU89vlyq)37EraRyK4I4FUPmzvYFaGpBXIK4e264h1w34kY7xYUNH3yS4SvZIa48hsFhqawgb0IFD7F8h414hZauBgBrgscVwGI9V5AeVk4CRIFIHSU)cxaGToAwk8V)4nxlOcWIwgnp7HIY8K7yc(Z8KnIh9dPpe9ybU14d3pDrEM6CU5AyDLS8KiuwyXI(YdR)w4IVZ(PDbI(gwA6eXfxr)ILBXDz9KIYSCGL(I9thVF6UDisMKb71JtYZkJexn9UPeeDSGydy7htwNuSSIrcFNFyDuYQO9tJxIN4C4pakhaWBYsGRwbV0kKzW437xtjIJaWv8pMG0qDueUSyXiZ2e(BpPAtV6sy)2mb23ja6UEUaJeeKkegW31anUIYOVb9NZqMa469cyJgjEB)lay(oItAlJsb(v4HSnSCGIMhvcQUw1xsTe7JCrfS4Cwj1I6j4vMiu4TGtrrc)PEyvMbAilkJMzDv8r5pdmiin(ZrRlaMLVefhndzmHhfF3(P3cI05YR35aLz9TOCgY7nlnc2V(6K7dK0WnOG58ebBrfbusDXxDY8O1XS(WQIswlVoo1zrYdq(6WEVTGnFcaS4RJWANAkk(dW1jh2RPuDAKBwDWvGoi3Hm0LmeUrQ6ypu1BtZGlCeeTOR)D1d(pDk7yK(D2txbMGkOPa7vKksGPKuge0p3c0B51HbHrCfmwhV1ju4X8E8yOjl1hEj8FaQ0IiWEmLDbdc4VXKQ1bt0lqvMffjZqtpDxdAqVFBksZ4)aAWoHviS1lSz1tdyKgnAsR()ynqxYbVceQ0JZYsbKa(Rs44a1Z4LzrYQv8BNeCXItOaDmaHsWazz9XExs8DHuOva25TGGpNGu99t)BRZbLLQ9L7rG(f3Cg)EBoF5P4opHXFfps7zBGJJPbB3hb7d8u8Vs3YQSIMMeZMeTE(K5WFWzeqv5HfrSnczHs)pfOGgsbNZaOhiEmUDtHNwv0yevJqdnCHKRx)zGZmI)M4nr1rZHBPbJcakJZwdCT4XqiHAafFAjdfZ(0NrpWWJjjVOmKXxnttGBBuIrQRrdIMTtmB2GoiEnUg0btaH(S4pbGymyo9t)QG5gXD2x3a(ckV1rozGgTF6A2xHN93)0NforGoRc(PIE5PZr0O7oM(jO0xyEJRu4cVWTXZ7Z9yPdsUUDz5KA1X7NEUJ3evQiQuf4vQElGzl2MYDCgW04LikJmiC096k3gb3NvEK1DgS45zCbVISJfKlGvjgF1napKqKCbN0Su8pWB67Js4sh90C0kF7AZRAulvCjQlsNEwbg9bwdd2HA)AH35dpzbTrd4UrjTlDFYTz59ZJwdmNhc(GDM(dbmPaIcCcCG1MSWvzSfcvTX5rlkTwvajXfvIHsTBBlyQ4uKIjiZggN5CwEHHGNmAMYLaV6sq8fPdF)tMoGg8U9rbtt1d77U3eh8swk43jEQdh8mpwthBdD8gglnU0i9219UObmiObWpb2wsMJ6j3wWzQJuYh4Lu1fyolkwW0ZLGQOSAyHF9CKm)oeebaBGQjR5KbqaD9Tte498TfAOTRiZePM0HTk2kudjO)jz12vcMX40mKlfzxv)UE0u4fjChlwCL(1OBrvwL8W9u(Y0nBBjsyvS89AxCybJncPnw6jLpPdpCBVrWDABTYoUXTASNyQgA7dITIboRLuA)1GTsl21NOaNg8ZHho47l6LO84O1mmg3CGN0cT(5Shy4nFve(cVdJWm4KTqIu)WV(ZysmIJ4kar4J)NfC6byZneMGe8Hcf2YhLZa)45a8z6odlHYnBtlSCg(xgEU(ctr2NIj)FBNF7ko(yUwdpSNfD7KSftqX37kCCXwL6gLt2kGb9ibzAkW)LXbmYWd(QmTySeB(iXfvuQi5qakI5gAYSSVQDGepmqaP2Utvt)ZzlqUeH6CfcoPGHUbcKGHcuxW1emNtgHUyY08FZyBuQBVwUsuRlxkK7D6pdpJPhIMm9HlHBpzaDMXRrej1iRCPuhgUrWPCF0sRopPAwZWIpxlPpGo6fOkzi2W7zWk4EW3Z5QvpMF3B3AgSQ8TyXBHAXjiVnB7TlpiDmJNB2aowHE5YYNfLFxXKzGlqycD7yUKOcW5qoB(sicNvZaxrY2MkW4wSvvrxq88(gkP)GylFZ2Vza)m4KklNJlpaQ4GRirq6pfJQ8KMzWU(Fjnm))kP1sw0FmfIfmnv69m)NaffRVdZHDXJa4MNbMgIu3tsfUY1uhxvbvmZkT(aXaqISm7q((e8G9t)i(eHKXzoPdvyHHhhZM0Ohfct8ufUF6VZIxUo5FTLr79LmJILvRYqGX1K4zuQTOC1rpEszQJqb2(LjRqlmt4z9NRZ)8QCm7xOtYGkbzNLOFFQulX2uKues14cTBvahEmgJnqOvXRdCoyfbfYp2I1uOczv7PlxIPWHzoOmKlo1RBsJ(qv6NdVl8lGX6P2RrzMowUNltUy9DqfgEq73tJmCJ3BMp6GgoYwiYlIjuyQOX0uELE(7RiGpcx0PCTNZzrLljVjejbW7kVIVqBLoFMh(yHTAgHluR5UoXTcIy6kWZNCv(XeCofYmHuLG0pYVJPYHJs2WccDkvuYTOrAXQeU39zCDIOf0bZ(TumPRNCPRUFbtDGRmR3waImS8thmz0M4kEPgOQ1PR3GPtx82KvrDNASe9BjumvR2p(YH(ONKGJ)JMOys66sEccs9cMAnDDaEUZn4HEr33MyJwuDwx1dNmU(QUYkGo5zc)xQ4vCFmyoa0yusyOGMfOhvo1QOrGzqmVyG2uiohqAZ2y8F73SROaVieaNrlPm0b9YdCLkdyoEzllaPtXrQCT(3fpxLRBcHyesovQ0yfVEZvM9AhkqlpsYeFHskjyXrE1eCXC51RLA4pLktBpF6D2AmfSQuHG0Bv64BjH9akno11JlGKHVfOlB4EaMv8R5s3PUjZJsMpHDpEBfnFEvLXCYFyStPXOWmc3x(Grgz3od2LfBVLvNnmlvA89JmbGQG0YWd4bi(caKSRnR8zGAp4HEKVnlA2RG0UgJVTxA1KhNKHA76tNWSmT1UrZzm7IQeM9e3vvY3vw9nESlNKubTtwnRUj1sJV194VlEcgYtK3BrrOsMj)SkndhZZLpwm1k3VkKH7jZiL(TE3w5C4vn5CihHneo1RtrT(rQ0L1f9uzGMTt)SBJAZDSey7jwRocQdtIEYPyYcz9AJsvqZO(V)mEtxnOpMkVdBKvr4wEhTt6(imlRvKLEH5WNNbBHOVZaNjIVJFH3SQmDSSbx8g30vtROOs3s8TheAa7Ytf1HHVcQev8hpo)e5jviLtUzWvgDqJaCoOj(unh0CTG0MWn5EboWio9nz8)xQ0s3CkWcakoXmkFURMtkmLMcH1aSo9oa7Fsu6embq1jPoCwr0FL6mdIxptwSn)X6uy)C2gWuplhfbQZU9ZyBwKKZezHc3fB3rB7UGcsytQLoblMbFRS90Y0Fk4T5YsXjGsl9qBTJarupkBxVLjoNm)MwkT5x61jBtDDB4dQ)gCIwxKsUX8fLTJuTEvd7NAaHE2t47f4NbPQbu(rJmtJWywgT9fR6vCZ1QJ(cVUy(uS7hq0SD5XTdPBMYBAcSarAFE)TkjppJFkCJwG5I5GJ9qSp5zpu4G)uwA6gibMNzHw(sZEVkOpm4GiIpNFMbkWZWGs479m2JzyeQGVkWMTyYTXZ5zUuwVpY1A4tUrBzyOFx2nQZJU9wa8j0QATaDgyLFTuo3j3ffXIBOe07cBYKzzO8TPHeRh7gThNE5RPWGi4tINCBEcBbSriVonTYDDntN(MIG(sInIoaGUYoFoFUYp2faepJRfI7i72cClWAZcVZFD)uEXQncAv2re)f)z3iabrHwbzXr)qM)OlPk4lzYAPoiAHnFNGxrZ2O2LxUo9MV4zv2o6G985u9aUh12TNKzuGTRiw23NA9rZY5MTFKT2NMrQxu(D72KrrdbgTfOF)mUfl7kL3NKemowDFQmUWyrpoYPDgLGJN3SFhB3HFJJMs82W1q(dMepJQAz1erE)K4RhL0D65yTe5jY1VDX9QX8QqCLfDxCk1T(QKjaTx7enlzWJQ826pZrT1VaLdq1zmrN1Rok2WP5deloFGT9i)znKo6kmANdDJ7SoYkJWQBooF948AGzVE7SR9QzD5CWr)1Q1G13gvE6LQqZraAX5az1rDj7n1o22Ymea(valm0yTIHCgBxNYqDZpG9wfMY6OzGvlPKA0grsTLP4rI4a)n2s)yd)AvpxqhlR)AoBblDbalFfcvzs0QSTyxcnEGE0PzPaRJ8tfKOKAXw9ZKmRbIY8s2ItdAHqGxrXX2P(ePou18Pzv2HkeHLXb9LgQ4jgzJL(R3yUEw4m(Kbr2dUUnmssSHkWVRU5mSbR5kYeDUoY2H3WzjwoL01t2Gqg22Y2lyDRJSTslURvkKXN307uLI2pLDCqnPkfegCgMfuPJF(gzqSTk9mEYUJUQg3YWtNUe60LrRcuQ9OHnQtynOTq95fc5mWTPHJ4Q57(KZBTxiONWpqz3G(SCbSB13TQ8Es8H903(Rqcbd160ZROZkvCoYLZUpPig)cOcUPa3r8DaN1dG)gHwxLmfXPAftivwt81TdpSeBQ4OzjPjL8Vcdgs6r95ZyIViRQVXRVuLF(9Qpq24OIsZUCQIhWq3LGbX47AXxK1sKK(doPwrf)BlPq9nJyhxKVestL7GtWEcU29HZP8vSzEjjP3SSQ6gYBmx4NPtYe7ZeNphO22FPZn)IZ4Tyk1hSJziNpTqn1TDsbVTdTpVAV8MZhXd8)j9y5yzh8(SUNAjCwO5BZNxvgUK0hD78x12945vufPtM2XwvheQ4lLjMFPR1VIQpxgPmMPa8DjBMujzs4LJH5FdxQ0Erbwr9HP3ArtNlxh1gb8kIwZIs2qPBXxbl5bU9JjRJafLMLGuKTw5tMOutRZ9sWk0CD(vwXdAa4gI2vHO(a2kHB0gE08hRjEADfBOU1WAxiQUGWJYIAlgiJNrC9g13hBwMfBbfpfASOz8le9pTdUgnHRam5xtisK80EauuIxEYpUkyrmprv7xnhGwTjp7EuTjr2KQkQOVciOyNd1XS(LffmwesJnYzQhglDM47YxWH7TAcPEUIVgShFbNMjGwpHhfQpSGsUdkIzusAcobpsZWfWwNT92LhR2XAj3na7aBvsC)Bc1kkTvFalkh99O6ZzvaiIpQvnLfcVOr(1Skqwbx4RED2NXVhEeHK5e16tH9mNVgE)3C6w)ArsrosfUBlwmQ4XFVtBPrUf73rYMv3PrsmW1wWiQckwvegn)MVrv)9QNw77T(PwkIA4ESFSGvHtyOthoC4P9bXMhIYxdxMfyhSWQgOpsNFFNY9N3PgVnymYzRqnrBlZwH9bppNhRVLphB(z(3IkoJB(u2A484p(DMvTrn)qENq7MVhxPtaww3HFTxt7U90jXA39n8sS39t9a76rxyd4urEyVVJF1339)eXnMSfIEA3xFGg20Cf0cYi(AMTXxp7PqPp)RQ1(cQ(j(2ZHdO3uEe1wBNXh2BB3Oxg0nKEt9eXV1b0qEbA4Ax4fWt7w3d4(c4if773tVV1EpyTPU(D0YDK0tcBYAiVnAGOgpV4fsrfnsc1NyMYgI0KrfyR(D)FwAV7ppN3BcdEB0YRC2MwlVtrkAPwE7pUlRD333(vl11)MqN8Cwbejclj8NhmGNeyN7x9md32D6LrloJEx1R5N1UsvoWwURVju4VLN15VjulpEt8c3vFwSFHmmFJCe4prhwDPyFNTJI21O1zldl0kkIe9LGzt16SXE8A4f7FJVn(f4GZip(J(MCjokC4zYMQZMYq2XDnV1spsCA0Sg9hXxRPv7nYihJ4VLhMdBQ8Wc3RzANC08hDo3w0OATae80fAnC2H6DT35ZLyTgq7DVmxJFv006Ht(fij6XXW3ebrpN1l0OMND9T1X5VL0NxGXM3)ne69CwwnVbbkq0AhTCVFgUm)THIqQlHxhJxfTi1dbhla0Du8Odt)do4GB073BmlVXd8MRb4yzw(nxJteDS208rEEvQwl6RMArhD5FrFqmT)NOwr184J8Hv9r9XyHhVKyil5zpnQo8XoJrPlhECYIl1k9aI0FhokZFjZIvfSOJvWU(QmXv13CCMRY35qtsvdOb(beJdnrv5B4R5CmvhaQQDH4E0OTaoMxJ9lPQQ)2n72fQ4txDPX8(eraYrGQoKypf3eqeo06Xx)nDsMACJyYHc3nHq0l0XZobAaIlKZZ0ognbXvN3rV0BxD5yb3()wMrP6ubRPuQK7O6Cpwm2gfcRM9BYp9Da8)p5FA)cnHGYsfmINo2qQlJeZ3FNsjvWW)pMbCl8XH68ssUu3nZwQ5joZrdiKyp1aLGWObhj1HlsKp(T6E4OZoszNuvaIdRxQWeepj9WV28HkgfMYtu0VSxDzDbiTbTN1gw1dMxeyJXB(d0r3D7CXiHG)RZueTzvfAo6BWG6GecuwbWECjGd8)BzAG2mQkQDcICu9o7fxoC3od9mWV0HEWDE1LN2KQ8XEF1Xvcz7FgZVZMXs(gIiz7zl5a0RXK3uh6mhZNUa0vxo8SJ0NbNeVmF6BQ)7wdBt9hzmBn5oabi1hv6LG)XR1yIS2jnoTM7qI(LVJ5VRUC0rDD8uvy4Z3GI8QlpF3o(kiMvD9CbH6919zvtfYkQYNuo(GKLx(4iS(ebTio6mDh9Cs9MDpiWSBSZbn850TBxWx)juISlU8d729MSxb(0JBsrApPzGxNPYO9nuD(r0njzNBal3SoZExerCAATq3x4oU9ydi1FENU(4RH7ujOy)qb54Tzi2zJw6jF5yJ(pZ20ObYArSOq(Hd60v92UYfDS)QnnNSfxGwDSSqncy3c)wafFCNW8ADmCcrKrIED6Eq43Q23foBq9DN(20eBo3FVlh1jSX0r6iPNEXItDc(nFC1PcUONYKh0HL3AVdWp09a3pTnGir9jF0RtqahqT6BdDUtnYc1xXiWVvrs0ZXQIXyud8f(2(TBCy2BGxXKWBk91cIUoFDikUouX9NJAka2tQ)HAauijxEMUz1S46lqGB(hzF2yJZW)RL6uQDC6u(j(6mn(CP1MJKUaahnpRfZbOIQJqqWEM898yPhnOxdkl8sDcn78EbKHdO6bE5VsXJr9OAEmZTt9P1feN50yIpewAXioiYn7tc4wgy(GkMBNbKhNo)CgRD2a2T6JnVNU0aWizBcScBSIVw87DOVWAsxyWBGXn)(Az(xypy3o37mHYK3(zmN9vGwEwWlGUnAU9k)MBbSOZbeFJrD6Ahby3HdaX5U03RJAke7t7TBxnGgE4XbNfo24obhzCh2cxsQDftnQ461JMXH4lzkS0kc3bSkpMM41aTaSnr9wwsZDp)WqeSE2SfI5MgYrW3CRz8MT3ONoWplH0ORTETM8EfSIpWbQmJVuB0GzK8DNtYY)uXt8AfZg50YZOemQhPAg6S0GhN3qn90A7BOguAT9fqEP6zIM)3cnr(IghA2hSvTTiJzNRAHtWngnAGyC1DJrJ5qkVjzXM7oc0qnck1W1hakTbwESefg6CDAIaUX6RKcinQ3K2Fp8KTjvbDA20UjShSBtuOHTESUKrRFMgmsFP6iEAcmudiSJ1MpwIyQpWOGisLfoJhSAzyZhHbR6sK0ZqKDJ)aMJBBteHUC2a92AUE1m69wdTICL8QoBU8rckiXVNtxtPtbc(E90oGw1tu67ShMyVkjePm9hR(6lnsd1B00fOMulkzHJjp7VXZQeQkEnPKn58Ey3o1AcmRhacSCzENXdQnkW8DqTg6pT3EAIZ6AZ1lDT)zIabrsEmCgskVYCvWDIQKYnsZPMbas6EvolZjMocHDf8mzFA8CMGbeqSBz4Tempq5maf6egwp3tKUIFKU(9gItDm6qLVtVIdIIn38NTFJ3s6FmP6Ed(eCMgZBeTbYMERNAKaqmo9cZg39aYpt2D7CQCFVGC3oK(N7Gbim4kCpYDubqh4u4uAaHbfu7bbKywvdVFr8APzNCUaOCo(B7xZpL8Sf8fgT6667Rw4vUFu)x5ni0tgvRAM8dRt4IXR)N0Ea2lIcXqlC05ahHJMKcjluv3rhQNyIETqg6B3htFdw)OjmvALBm5ohnCqNgx0fK14sPZPX3)OZiqcDVj4ysd3L8096Sl1ETu5)wDVZ0MAF7ZqRwZY4A5rFoPjn9qNwsQStHtG1JiYvPbuYpWN9OdTDOHAC0PksV0(zBQI1tvd0fJdRGA4GEwDd1B)8k1pzQQ7HOZx5qpX43qMb6P5tMbluNUHleYLNpGUEuo1iU7Pdo0oDMvj8RxNwKQ3t9FHhYuQeohQbN2Rs763eWAU4KYCeyZy6KL9EuLgrWw9kofq9X1ymAppEHCsHcMV0NgOxoEaYxzoWq9TJfkifFNQMzC8GooTx1aVSwKmWJBNcc7PfPsvxOkvkKVMRx4Ix6y5mm9PUkxDj8kVPUsOxN6KMwPpSw5M13UbYdtH7J9OqONwpGytm7qFHTBxZzpNiL71sDIg0Gov36fEGskVQYc(EXo0QgAuZWfdhC0Wrh2CBMqU)9SSSB0x3IMn4HOhrF35PbbeZZZQDdWM3HnxX5isBsDwsflOX4)qtzUbLTxVDyf89iR8pSokzvuL2J5o90fQrIxnpJF3LLNd2n1SR(6dv9MWxXQAw17(wfZVUzshrZ1FXLdvD6O9y(rRFHmNqpcQ0hRAsrzgZet)ZVitj0u5)NCYTOwoznjmJyvkuqtJQ6aY6YE70ncEdgcRWmTL9dmJiTdznmchL7PDi8Vsuy96g68TGIu3VO)PJMm2WOHs(91NgylWBd7KyOVTARvha7HKAf9IRrxhiJptVU5)p]] )