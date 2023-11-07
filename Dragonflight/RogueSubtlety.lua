-- RogueSubtlety.lua
-- November 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local insert, wipe = table.insert, table.wipe

local spec = Hekili:NewSpecialization( 261 )

spec:RegisterResource( Enum.PowerType.Energy, {
    shadow_techniques = {
        last = function () return state.query_time end,
        interval = function () return state.time_to_sht[5] end,
        value = 8,
        stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
    }
} )

spec:RegisterResource( Enum.PowerType.ComboPoints, {
    shadow_techniques = {
        last = function () return state.query_time end,
        interval = function () return state.time_to_sht[5] end,
        value = 1,
        stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
    },

    --[[ shuriken_tornado = {
        aura = "shuriken_tornado",
        last = function ()
            local app = state.buff.shuriken_tornado.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 0.95 ) * 0.95
        end,

        stop = function( x ) return state.buff.shuriken_tornado.remains == 0 end,

        interval = 0.95,
        value = function () return state.active_enemies + ( state.buff.shadow_blades.up and 1 or 0 ) end,
    }, ]]
} )


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
    marked_for_death           = { 90750, 137619, 1 }, -- Marks the target, instantly granting full combo points and increasing the damage of your finishing moves by $s1% for $d. Cooldown resets if the target dies during effect.
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
            cooldown.secret_technique.expires = max( 0, cooldown.secret_technique.expires - amt )
        end

        reduceCooldown( "shadow_dance", amt * ( talent.enveloping_shadows.enabled and 1.5 or 1 ) )

        if legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
        end
    end
end

spec:RegisterHook( "spend", comboSpender )
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
        local moment = buff.shuriken_tornado.expires
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
        return target.distance
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
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207238 )

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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return 1 + ( buff.broadside.up and 1 or 0 )
        end,

        handler = function ()
            removeBuff( "honed_blades" )
            applyDebuff( "target", "shadows_grasp", 8 )

            if azerite.perforate.enabled and buff.perforate.up then
                -- We'll assume we're attacking from behind if we've already put up Perforate once.
                addStack( "perforate" )
                gainChargeTime( "shadow_blades", 0.5 )
            end

            gain( action.backstab.cp_gain, "combo_points" )

            removeBuff( "the_rotten" )
            removeBuff( "symbols_of_death_crit" )
            removeBuff( "perforated_veins" )
        end,
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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
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

            gain( action.cheap_shot.cp_gain, "combo_points" )

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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            -- Can't predict the Animacharge, unless you have the talent/legendary.
            if legendary.resounding_clarity.enabled or talent.resounding_clarity.enabled then
                applyBuff( "echoing_reprimand_2", nil, 2 )
                applyBuff( "echoing_reprimand_3", nil, 3 )
                applyBuff( "echoing_reprimand_4", nil, 4 )
                applyBuff( "echoing_reprimand_5", nil, 5 )
            end

            gain( action.echoing_reprimand.cp_gain, "combo_points" )

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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return 1 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            applyDebuff( "target", "shadows_grasp", 8 )
            if buff.stealth.up then removeBuff( "stealth" ) end
            gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )

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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return 3 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function()
            gain( action.goremaws_bite.cp_gain, "combo_points" )
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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( buff.premeditation.up and buff.slice_and_dice.up and 2 or 0 )
        end,

        usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,
        handler = function ()
            gain( action.shadowstrike.cp_gain, "combo_points" )

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
            gain( action.shiv.cp_gain, "combo_points" )
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

        startsCombat = true,
        cp_gain = function()
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return active_enemies
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

            gain( action.shuriken_storm.cp_gain, "combo_points" )
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

            local moment = buff.shuriken_tornado.expires
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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
            return 1
        end,

        handler = function ()
            gain( 1, "combo_points" )

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


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    canFunnel = true,
    funnel = false,
    
    nameplates = true,
    nameplateRange = 8,

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
    return settings.priority_rotation
end )

spec:RegisterVariable( "priority_rotation", function ()
    return settings.priority_rotation
end)


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


spec:RegisterPack( "Subtlety", 20231107, [[Hekili:L3ZAVTnss(BXyayKsS1kjl7KDHTbYJD2BMBMzhep79rlrrrzXZuKAjPCIhiOF7xv973KYpYgGdhWEzmB2DvvxVRILUz0n)XnxViUj9MFB8WXNoA0W3oy0Ptgn(T3CDZdBsV56nXj3fFl8pkIxd)VxVDEtEAZd4dEiVmEbUb1LBRsGhEZ1Z3ML38tf3m39Uocw7M0e4pFo8pxLTyrkDTP1j3CnU2tgn6KHV9VTF2(z)42QMvPv7NnA4GX7NTDdUJ1d2)Z7)zXkpJSYFpUjzfDDYhp88tgEk84RVlBZ(zFE7MMTvP7NLvSF26T5nzN0exDBAZ(zFzvAH6cQ3pRe(dXfL0JpTiD9dWFd(Npai6(zIxmlpF)SfzWlvLMh3KDFAoSW6YYcfW4StgnHaLFgwZxHh3KgN3SAAYc4GItAYWdlpRUb3L)92SQ01Pfne8C2ja4Vk7E9DBmz3aKDKdIYqGU8x5ly4G3YxI2kg)oYk(NBAYwN9Na4NUCzwswArYdkRBcN8(RL3dRztvAs565XaC((8xbeGvXaT433(N)zo80pucO280LLij8Akko4MRr8QMWIq)tPi)YVr46slINNd)3F4MRPubyrRIxu(L6MQS7sPmfvzBOp695Fj(HACRXhUF2YQsX5CZ1W6AsRYIrgWLlhWoSbBHl(O9Z6be9nP55tPxC1dQxTf3LIP1nLvR3p7I9ZMSF2UD7NDFmSlaynytvwjSPpmTQSjMEh1)MgGX1a01aYFmRiREfNJcFN3xeNToE)SKv4rVa(hajeG8nLzWDmLPAnYvO93hijjjXaCt)pMIetvCfU1stqUUPK3EkFtV6sy)2mf23PaExSGEnmLkaVKaJiQCQbQyse5ejGgva3lCQP6znyrkY4aSexaN54qGTtqyIxqW)PaC9VHCN2eNdckWdt3KwbxLvXnGIQ1dy7h9cLTO60KQ0gxlQ)bd0N5H7DoOPSUjEUbtXhy)zGNfVT)uCrnW)(RXjXZrzf4rj3TF2TGwMkgJ2cGWxClk6JIdZZJH9BGkX5iqudVI2G6kwKrzq53pSlp8vNUiUijDaSQ4ScgJXPwlIDaSxh27T1PlMcal(6iSgjP14FaySiWUKgg1QaM4G5GoOkafTAsr4gPQN7HQEBEjWkGGObD9FiEW)FNYobPFV9W1PsPck6uFgPIoWuNuge0FNxTabVo0im0RGjQ4TkHcpM)kEmUjlYdVb()aQ0YyWfbxMQ0iGFoLzPb8AyjQ8UUoBoAnSxbOl)(T5inJ8hqFiYsRPUFqnJQO4HTlTAF5Nka6sf4Oc14sszzoGeW)Qbooq5fEzwNTEn52jdxm9eQrFvqOeSz3ip27YsUZLHajnk7Edi4tzivF)S)ErfOgvSVeNuuV4wKsU3wqwEoUZttjVc7k3uXF5g44svGnUHy8FLVnLBtkpljDACXIPlG)bHravYhweX2COgk9VQrbnKcUifGEG4LsSGtD(JtJrungnbresUU4taNzm5nXBc(rtGBMbJAaktklaUw8yCy3qdk(4Quum7JFcDkepMSQ6MoAAc8KmKguDIMPFvB2G(SEnUg0NxaH(e9FcaXeWq7h)DkZnI7PFDd4Ek7wh5KbA0(zfPFfE2)4JFI6od6)m46m64PkhrREGPEfPOVq)gxOWfEHBtwmG47uesUUDvZuP649Zo3YzfUkchkl1LQ3cy2YT5eF5bmnzfIYidcbDVM7jl4rVW3WEZHfVOKi4vxEmLCbSkj4RUb4HOIKljKMv0)d8M((4mI0rFfx(Q2wOFvJAPsAqDrQ0toymayn0yhKUA7q3A7cAJhsCWIzx6(SBlRgufxamNVgCX7m1hcysnen4u4aLMSWvPTfuvTjvXlBmwvajXLCXqM2TT1PIqNyIjiZggV5I0QAnbpwawnRaE1vG4Rq5)brhqdE3(aLPrewG9E74GxLMdEKIN6OHpYJv3L3qhVMXsTlnN(bBFx0cge0a4hbBlzlq9KBRjm1Xc5d8sIFbwLgNqz6jsqCkRcw4xpNtMFlccfG1q1ScczaeqlUDkfVxSTwbTTfzMY0KoQtr5HAib9pzR3UMYmMKxICPi7Q4VRgxhErc3X0fZ1VgFlQYQHebQWxMELBBqcRGLpyukDmQjK2yONK9Kisga8gl5PD1k7Kw3QjEIPAKPpiMkgiSwmP9Nd2kLOOpqbof4NapeW30Fg(bhxLexKIHqxb8KgO1Vu(Lu8MNNRbQ3HXysLkxYqQ3)7)cMxLKyIcqe(i)ZAc9aS5gctqc(iQcB2JQsb)4ja8zQodZGYnBZRnCg(3gDU6cZr2N6P)VBxC7Ac(OV23QU25X3oTC5uu89UAlxSfzts4KTayqpsqMMA8)s7agR5bpp5pAlXKpIErfNtZxfGIy6QMoV8RkhOJh6WfvFUtjP)vPlrUeQ6CbcoTofDdeibJOOoJR3rWfTBDOhpLHdudGzGz0wO4QyDQYPwRSppdzSLNEFwDcgPxWnfcFl5o4o6lG0yO1vrtQQRtfx1rHd)1m2dItbO3NRqLNXZZYbFRrVnt5(nmpLg5jpw2FLf)ATm3KjX1n0OxjPeA)S)izvr2)EBQUZ708fP5)UPrbP)AeK0TJ1Y0kt8Hw6BSzaZlkBeKRgqKHaJrCBcWFAnQgzkjBZNG6(uC1nyqCH8()Zuowx()lSaHQI4zk4tKSEya5AEIYZ0HsIuXq3NQfnuxYRb3d(JCL3fTeY4pcbdRDriztkI(4ddv1VxxjJWcBKgG9IlTMKA5E4JvPDd0Jj57uJf4)HHHChVtix6udSewvH33mwzD5K7Y2mLla4igxjJspD2c1xSdPEVZIcw3YwIPbIu2TKSqirilRNamMybpxiG7HXGIPhgyLr9LSNmvOw0xEf7etL3u)5Ypzd9zSGJP52G)0MuUQqWZQfpO4(eSUPZZllDgsPqtJXUyMTXhksQklY(tufox5lYC9ry33p7d42RNhTbaLnD5wq5sTcByjHwR6nirRf1QAklbeOrGbDNs0t1wKeB1dHsqUuwGkVxG0dFcr0t3Kx26nvL3JQgvFfXj23vuRwmQjpKG6HOCigbj5xCZsfTLaxRmFmTjEKkXN2JSGxBMdM(2sOASj)kwBwqdh1iTiIOgInFAfxZZW6rMxIliTOC7TRowSJsHZnaBr66SKbode)qf5tJRqZ58mHrbeA(Wu0h8aGP51iFBjhKfWf(Qxx(jmv6icreXOE8RKfTZSsKU)RqvlDsrzkiGEEVinUzLKh8nyjHnK79Uyu3YzDvPBh2p4WpZz6eCJRDGJKfAQs8gk(KkdIN)uPFTwHIGb9)yDghaASM9B2aQBq1)PvZJRURE68kqAEfxstSKyqdfH8GL)kD980Q6YT5cndTTvccT9Z1V6EhDlFX2V5GSvzEwAfbx(c4nu6cwnDoKCWy7nY)flposVsioY)J5X3I1rGYkq(tqGpf3HMqQb7kRqdl1XI7jM3jS1iv2x7Yp(eRYn53xtp1e39d1iHNo4SBUgmlbuSLtVnzbrzTW0PYbALInrbiiPbXWNdy3ob2nz8neLjKQhGRLcrys5iATxwvc)V)bf(iAMP1KAGRiis6w)a0nCNlkasuqa2fBRbnkPvNoC64njbOlgkumOn9(xf5P1yUqYzQtrysKTKVqCQT8ojr7hlt2w3N5ibtB9Zkn0xsdu8GY86vX5hK5(mREerXx8n5XpOh8Q0zRehjc2YXoHGxKRAJCwyx4LMIScMZNtaJoN7FfToUPvlr1bG2I7tb2drf8KGS1su1viD1CtDwWIETurJry3KcGvoOq(XwH51EkgYS1azybwRC46cnEZy743z4qQNDHCbmHbXDtFSCPE8k12D5w3tT2WbV30F0rTCKDWCcT8ucps7KNR6eWGocDQAO7Ex5vKfAAqtK0kDty0S5wqIJHKHketxhxqsUnTu9uoNAw4nCnyFGCh7kQVoQZ895z3wOP8dJYkMCKL6GPNaOSet65PTEe3VUu6Z5LAHQk7CinMovXBprPPTe1Bjum1DQy0KCgFqco(pAhTnNQUKdqqQFWOVv1b45oxJh6jDFRJnkfyY4QE00jYRAUvavYZuYFHZRy)yWCaOXOXHHc3SabdBgmdILOh0McbyasBMgJ)7F2tUD6kLXD93ObQekkut3NSAulUpic3oy9DJLuCxHu3IDo5vVqimeSDSE2KpXUhOFlblAA6Jl)sCcK5PPvAPB3UWPgIKUqJa3AUkDC3IUWHv(3P1dfBNd7YYT3M6cmucEWvTu5leuUahWxGq8YAmdZ4FWEgODaEO3uCQLEUoYQfqOqHXX9nkxSpOhcrbiShG612RX9f8sCFG7QODzegh1ECvC2IPP3JljEXcQtXubaFHtOuacJ7X)G(emYGy)jQMerHE7kWRu2XKUVbB)rUxk1SiUz1q2iP(DWhQRAZhkccRPHXrfw6jGanEOEOb9HkMy8ZUnUl3XmGLvHsveufMO9ZF90LSoSmoxM0ZbV9mskYgoal((RBLvH69QAub3hJ5YMtw6hMd)XvnOluXYw8eAsBxnDIIYSE7BpCObShPEoVo8vaxuXFyRKtKe7DoHCNcxzUJTcGZHTXNQ4hJEyxCvvTfvgXzPHAHZUPK8)x0UfkOr7zHmaOyfAf752AoDHPUPqyx7jZWgW(NfNpfZb3nIoajCYduFfLK3cxptxUT6bY24VJWBzBaVftRqraY2y6hyx3MLzvPIYDn20PTUUlOGe(bNKpfB)iYwfSz6WcKrKLsYaLwQraA6OoTdYm9qL1QlotXSDTiD6d(bgWtiRUUmQf1wwUviEUrdKi6RpmCTDV0yTHax3sqEKlQd)(ZbwGiTpF6wNvvvsofIPiWiWcWD01LWF9l1oYHR9DvVazV7md0Yx9l6ZH(WGdIi(CPzoOwUeDLMS3ZtFOedpZmXWS(UZ5Atc3ukCT2SVxSfX3Ela(o0vASazOLkER6I7MTlcIfX8hOnf2eiKyuQv38GXJDhd0yFFTzq4RzjtVTklDjSriVUBAL96ANo9nfb9LbxeDaaDTzYm(e370LaepN8XjrCpDBnUfy5zH35VXQwIExmrX1)Yb2ntgXNeKfNhcQjPk4lj8dZ2A7OH0AuQ2GYpQAv6o8kFUXoK4dRzl8Rh3v3QCNjTwP1HwTqVf9n1R3os9Ks84tVNpKF2WT1Aim)9CsWiy198gWkH(DarODA1gIKf4)alm1NjOjdV1CgJ8GPjZDvnpjrK09P(6JFv3mowjbt0KqBw1jjMZdQK9Daqpf5NhgJjaTLAf)OZW1C2WC6FpLD1MTiYszokuz9KXngoXuGyX5d7wsiDjltJNbJV412r6jJLrlq22JSwnYQwy2d1TxQfmYch9xernwFtu5WZHUIrA3IZbYJs)q(D23vPz1ea(Dal00yTof5m2YQVmwj5ySYWXZblkmj14n0k2YsQcdXb(BSrNX25XOqJGo20bfe2I08LaS8vi4GPXRl3IDs)KHQXdwMdSoSXQrWAYQ(vknHw)rNFgad7GqGxrXjMjBePoUQ(A7QSdLHCdJdQlnybVuZ)PzIZPkEwOM3lTj9bYEq0TvlAprmby4hHirrg9R7ez7WB4Ymdhg65j)lidBxz7PSUYyj5AXTTsHm(K2sWvns9tzNeutQqbHgNHEjaI8Z3WYswNsiIN8POQQXU(WUtqH7eu5wfit7rlBuuynODq95fu5mSr7OD(4HxNCVqqFQFG0V4OGJqfTp7DDXH)BiYgHjA7gBb1(9lWZsvtACnvgyfO3INIynjahnL3yJj0HCeoyN5PC(5XijggCvybC27iYzYIOihkZlcj9H7qKiAtXS6qDnes89yfhH1WhDrNbXKhxvaGynMEDuVX6nLvnmc2Rebm8kXa8bvNuUgnxSfCYhbzI5HIBjtQNFH8PTIZeiWTl40ip(v6bFkgujVIASX3J5euyz9g91(TT7MJbfJD33usXC3pZdSR(r8yc4U(aFm33ZF2339)SJBmw9noS7R35g2uYiTbK54JJ2eF9SNujbYhPR5fK8j(2ZrdDVPeLpgBN23jCx3ONg0nY9M6r5OXb0Ik0wU2PFHah2TUhW9jWrg8Mxg(OXMAhFAh3rNFLbMK1qFjcTqutwu)ePO0SC7QfKfMCz2e4GDhAB5x99Z59IWG3fT8cpuCRL3kEUoQL30oSXU7R)n7OU(xe6KNZkGiryjHVFWaI)Yw3VQor31D6PrlER7Dvn9ig7QRmN0XD9fHc)T8S8OR(jsT8zW(PUTN(IWX4BBFri4FxCyY0w9ktpfnZNL1wgwQLgWT7lb9s(BUXJ)wAUA84VLhw4aSyv3Z4mCx6V23AMpfwv8Qvpk8vJmP)eJTmd)sEyw8zSdlCrVuo54fpyDUDOIzVYN)Lkf(6vpn)mFw0A5Hd(j43(3sntEoRNObcF2hEE8c97a6ZtqX93sVk8Cwgjn2bk4iLYDCVFe(F(THI4uxcj5PplArKjz0aaTt1Pkm9teWb3O3UxB0FJhioYGkxMjhzf1deZqO3C5FrDSiT)NDTc(0XZ5d5DtXXy9vU0XipYZEQnCvo2AOgD5OJZwEPYxZpIM)aoRZFktgvbSOIvWU(Sm)tv3CCcOs25qZ1unOb(dighA(Ms2WNZPkQkaWldd9EuRz7pMuITlPL5WCqPUBxOM09Ql1M(Mic4CGKQcjMZunkeHt1E81FrNROA3i6COWDtie9cv8mYfPI5t0fSPlAKwD8V68i1cJD1LtOC7)hzIHQsfmMzOmUd(5EmDiksfw1BWPF(ha4)FwGqov3hOEuaJ4PJL(Evm9haaRHYqn4AiDl8XHA9smUu7nZuQ5aNaObesmNHFmqy8W3W0AtZdo2h(VE8zVryzuK)(xlxk1Odjh3WFT9dLoykzNiTY8xDPSwQMG2JAd5v79IaBmEZFKk6UBNngrf8FEMPNTRQqX1EngulKGIYca2JtaeG))iZMZ2rvAPhqKZvv6V4Yr72PPNb(lrUhJMxD5PTPkFI3xDcxiB)JyAA2ows2qej7oBjbGEoMdMQqN(q30gGU6YrN9g1jIPJxMmlmv)7gJ(s1hPnPljoabi1he6LG)JNRcVlDsJqRjoKOE5Bz(7Qlh)MEw(MgfS07xD55725RK79Tbb5(A)mED25uf50mbjlp9P9I8ebTiw6mTN(cm9M9okWhHq0rT0V772f81pGkmDXLVB3UxK9kWhGqBks7ZmdiCr9fCUZyE)PMdMJvAODQLHJC9rmW8IZE6045bcYfovAqm97RPiJffXOHLSPkpb8p6iNnCe9()5zW0yIpYmIP6sIz2GmCZ(mlQcjhd6ElOgluK9N0cO1)8OE(0RbY0mqX8HuXHxM54HjAPMUTJ1gAnMUgPHSgelxi)OHr9eVTTEXOWF1IxGEDy4HYyqDt43cO4tIcRRjsZjuQmD)OEhf(TK(UsydK3DQBtBQ5i(7F54OWotnwfj907GeQtWUl8QtPCrhYWxPvfb(5h6DKDtudejxY69Jcc4aQjVnu5ovilU6xEGFJtsu1wlymg3cFHVTh0QzYS3cVIoHxx6RdeDv(6quCvOI4pVRbHsFM(hxFgImYLNHFIKfxDbuCZ)ulXeBSM)jDuNI0X5tjN4HmpsSPO62JcacU5mnybafrru2DZPsYJJXD8W(DbKD)9ur8FamQQMILwuWCAKlOKN94G(h51Jidn1VtK8cRPic568Xm7pmbSBvNTihoBfCx5MIIS(ouUh5eVB1SrWudoP93xKAiUI1D7S)EtOsLV8dIdZRaLewHxa9A1U1v(TBbyre3iI6OAiQNzO09gnCyFD9FYhoUTCvCA)D7KaA4jSbCw4S14eCUA86oyBpY8ttcqQ(UzCC8nCeuS9ceUdyEBIBIxl0cqjVR3YqAU35VoebZs7fD4sicuWyqyy6w3Pd9ZsWSEP7RhkG2MZJJS1PQhOUY8tqRkgwNKHJE0N41qHjYPKWwgyiN7eA6SuGhR3qmIj66BiMMeD9fqEj5GJW)BHwIFsZmcZd2OiHot(HGrYLtmT6vNB1226qJcLHLWGT96F(azfoXUKPLihFmIbH9GDkJsS(60VEod29mfy09vPLqPoW4Akl4iNm6o7qvrynJfKsU6pcJ1ZMiPMGnZMwcmc31gGYLVCg0BJHJq7O3ln0st1WZ6aoWhjO2j(9y64lvkqW3RVPg5rd5zg(h5)(nOLTLxOFQFKKeALzSmiz(RebpVX0xJjb68hFPD7eRr18UXQa(E2Y8(dUKyJM7)hBjXAC)dTuFfXo1Vkf1k07)hOihej2XqyCC5ZKTIOtevoh)9SVfQURFRGyuEEY50IXJfetyx1Oj59X9lDKdsGD)gyicDKWyTl0jmSEEuOuC7Urf0eOI0AfNFqT0k0QQ3(pVpTlBO8drHQ3AhGZUycsCBkRT36q9uhIbPFyg5EYlmvmB3oL7rJEvOFqgDR7Gh7pGqHHBQhn2)Kc5ocNGSDyHHTok9e1lPrgAgJc9HrJvtH7M632F7FCj5AaFHrlrYJK0bLaDSNZlx5nCWtglvd78tTJA2)5)h(Ma8poQTGBXan1zgIbTj45Sim9g)A1Cf0VdslF7(T3PftEUPqCfXTMVL3mAyuRl6cN1VrODP13)nN5ajuDHqhtA5sLKXxRTt6Zc37nzdc1Lc87ZiRshbzB1rDStWm74oLHUYCeoqREJJ8iQbLKd8rpjM6gAiMUhIorGz7SlLQ5q1jDXKWQSgnSVrlF9Yp(N8tM4TiL7CjoYtK4Te)EFffyASqr9cxhGlpFO7IUyvi0ENo81MPAKNmU(rDinSN6)cpKXvgCosbonxLY1VoG1Ef4yrYBYyALb8(UsFdLT6zCOk5JRrBsjD8s2GxcmOPoCLUCYqKVsF(l5BhRfqk(o8o2CYWiREiBOxwlNmWt6MccZHVJqvxOYXrLVwOwuHN6uokm9rwbQEo8iVTsV3psMqtU(qPYTg9pjfKh2fUpXJcH(kn6GjXmY9f2UDTNzBhPdxk1r7cb3PHwTOaUKY5z933lg5w1qRAgUy0W3mA8RBVxkCU)9nSSR1860kQ)L4hqV5jjbH0qts3am5Dsxi4COjnrMlt6cAn2p0uwGaY2R28VubaKN(9fXzRJ5Qrwy1btOQjsj30(728(e4VTw71xx3Q)Pv8y2zgZPDhE5UBIh)4ofpTMSO)rnN9qkDHJ(ydIEB8bERFYsqh9x(7FLLbkAY6qhYXVeicxLruXmPq34cVVsL1a3Q6)EJhdl3SBxjosp9zrUYDwlrsFAKdh6Ovzx2MSVeuezx4(DhnzIMvkHcJNFAGPggty3jg6BRuXHaKuJWLSTYBbz3CD82MvLv3C91zR)izOJDZ)h]] )