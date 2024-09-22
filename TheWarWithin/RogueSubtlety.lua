-- RogueSubtlety.lua
-- November 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local insert, wipe = table.insert, table.wipe
local strformat = string.format

local GetSpellInfo = ns.GetUnpackedSpellInfo

local spec = Hekili:NewSpecialization( 261 )

spec:RegisterResource( Enum.PowerType.Energy, {
    shadow_techniques = {
        last = function () return state.query_time end,
        interval = function () return state.time_to_sht[5] end,
        value = 7,
        stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
    }
} )

spec:RegisterResource( Enum.PowerType.ComboPoints )

-- Talents
spec:RegisterTalents( {
    -- Rogue
    acrobatic_strikes          = {  90752, 455143, 1 }, -- Auto-attacks increase auto-attack damage and movement speed by 1.0% for 3 sec, stacking up to 10%.
    airborne_irritant          = {  90741, 200733, 1 }, -- Blind has 50% reduced cooldown, 70% reduced duration, and applies to all nearby enemies.
    alacrity                   = {  90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison            = {  90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.6% for 10 sec.
    blackjack                  = {  90686, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    blind                      = {  90684,   2094, 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    cheat_death                = {  90742,  31230, 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows           = {  90697,  31224, 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                 = {  90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves            = {  90743, 231719, 1 }, -- Physical damage taken reduced by 5%.
    deadly_precision           = {  90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem           = {  90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand          = {  90639, 385616, 1 }, -- Deal 46,245 Physical damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness                = {  90742,  79008, 1 }, -- Evasion also reduces damage taken by 20%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                    = {  90764,   5277, 1 }, -- Increases your dodge chance by 100% for 10 sec.
    featherfoot                = {  94563, 423683, 1 }, -- Sprint increases movement speed by an additional 30% and has 4 sec increased duration.
    fleet_footed               = {  90762, 378813, 1 }, -- Movement speed increased by 15%.
    gouge                      = {  90741,   1776, 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    graceful_guile             = {  94562, 423647, 1 }, -- Feint has 1 additional charge.
    improved_ambush            = {  90692, 381620, 1 }, -- Shadowstrike generates 1 additional combo point.
    improved_sprint            = {  90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison      = {  90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach               = {  90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison            = {  90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 3% Leech.
    lethality                  = {  90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    master_poisoner            = {  90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nimble_fingers             = {  90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison             = {  90763,   5761, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 18% for 10 sec.
    recuperator                = {  90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity         = {  90638, 381622, 1 }, -- Echoing Reprimand Animacharges 2 additional combo points.
    reverberation              = {  90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 100%.
    rushed_setup               = {  90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    shadowheart                = { 101714, 455131, 1 }, -- Leech increased by 2% while Stealthed.
    shadowrunner               = {  90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep                 = {  90695,  36554, 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    shiv                       = {  90740,   5938, 1 }, -- Attack with your off-hand, dealing 10,555 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards 1 combo point.
    soothing_darkness          = {  90691, 393970, 1 }, -- You are healed for 15% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    stillshroud                = {  94561, 423662, 1 }, -- Shroud of Concealment has 50% reduced cooldown.
    subterfuge                 = {  90688, 108208, 2 }, -- Abilities and combat benefits requiring Stealth remain active for 3 sec after Stealth breaks.
    superior_mixture           = {  94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional 10%.
    thistle_tea                = {  90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 19.6% for 6 sec.
    tight_spender              = {  90692, 381621, 1 }, -- Energy cost of finishing moves reduced by 6%.
    tricks_of_the_trade        = {  90686,  57934, 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride         = {  90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                      = {  90759,  14983, 2 }, -- Increases your maximum Energy by 50 and Energy regeneration by 5%.
    virulent_poisons           = {  90760, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.
    without_a_trace            = { 101713, 382513, 1 }, -- Vanish has 1 additional charge.

    -- Subtlety
    cloaked_in_shadows         = {  90733, 382515, 1 }, -- Vanish grants you a shield for 6 sec, absorbing damage equal to 18% of your maximum health.
    danse_macabre              = {  90730, 382528, 1 }, -- Shadow Dance increases the damage of your attacks that generate or spend combo points by 6%, increased by an additional 6% for each different attack used.
    dark_brew                  = {  90719, 382504, 1 }, -- Your attacks that deal Nature or Bleed damage now deal Shadow instead. Shadow damage increased by 10%.
    dark_shadow                = {  90732, 245687, 2 }, -- Shadow Dance increases damage by an additional 15%.
    deepening_shadows          = {  90724, 185314, 1 }, -- Your finishing moves reduce the remaining cooldown on Shadow Dance by 0.5 sec per combo point spent.
    deeper_daggers             = {  90721, 382517, 1 }, -- Eviscerate and Black Powder increase your Shadow damage dealt by 8% for 8 sec.
    double_dance               = { 101715, 394930, 1 }, -- Shadow Dance has 1 additional charge.
    ephemeral_bond             = {  90725, 426563, 1 }, -- Increases healing received by 8%.
    exhilarating_execution     = {  90711, 428486, 1 }, -- Your finishing moves heal you for 5% of damage done. At full health gain shielding instead, absorbing up to 10% of your maximum health.
    fade_to_nothing            = {  90733, 382514, 1 }, -- Movement speed increased by 20% and damage taken reduced by 10% for 8 sec after gaining Stealth, Vanish, or Shadow Dance.
    finality                   = {  90720, 382525, 2 }, -- Eviscerate, Rupture, and Black Powder increase the damage of the next use of the same finishing move by 15%.
    find_weakness              = {  90690,  91023, 1 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 30% of that enemy's armor for 10 sec.
    flagellation               = {  90718, 384631, 1 }, -- Lash the target for 8,893 Shadow damage, causing each combo point spent within 12 sec to lash for an additional 1,779. Dealing damage with Flagellation increases your Mastery by 2.5%, persisting 12 sec after their torment fades.
    gloomblade                 = {  90699, 200758, 1 }, -- Punctures your target with your shadow-infused blade for 11,624 Shadow damage, bypassing armor. Critical strikes apply Find Weakness for 10 sec. Awards 1 combo point.
    goremaws_bite              = {  94581, 426591, 1 }, -- Lashes out at the target, inflicting 48,023 Shadow damage and causing your next 3 finishing moves to cost no Energy. Awards 3 combo points.
    improved_backstab          = {  90739, 319949, 1 }, -- Gloomblade has 15% increased critical strike chance. When you are behind your target, Backstab critical strikes now also expose a flaw in their defenses, applying Find Weakness for 10 sec.
    improved_shadow_dance      = {  90734, 393972, 1 }, -- Shadow Dance has 2 sec increased duration.
    improved_shadow_techniques = {  90736, 394023, 1 }, -- Shadow Techniques generates 3 additional Energy.
    improved_shuriken_storm    = {  90710, 319951, 1 }, -- Shuriken Storm has an additional 15% chance to crit, and its critical strikes apply Find Weakness for 10 sec.
    inevitability              = {  90704, 382512, 1 }, -- Gloomblade and Shadowstrike extend the duration of your Symbols of Death by 0.5 sec.
    invigorating_shadowdust    = {  90706, 382523, 2 }, -- Vanish reduces the remaining cooldown of your other Rogue abilities by 10.0 sec.
    lingering_shadow           = {  90731, 382524, 1 }, -- After Shadow Dance ends, Gloomblade deals an additional 50% damage as Shadow, fading by 2.8% per sec.
    master_of_shadows          = {  90735, 196976, 1 }, -- Gain 25 Energy over 3 sec when you enter Stealth or activate Shadow Dance.
    night_terrors              = {  94582, 277953, 1 }, -- Shuriken Storm reduces enemies' movement speed by 50% for 8 sec.
    perforated_veins           = {  90707, 382518, 1 }, -- After striking 4 times with Gloomblade, your next attack that generates combo points deals 50% increased damage.
    planned_execution          = {  90703, 382508, 1 }, -- Symbols of Death increases your critical strike chance by 6%.
    premeditation              = {  90737, 343160, 1 }, -- After entering Stealth, your next combo point generating ability generates full combo points.
    quick_decisions            = {  90728, 382503, 1 }, -- Shadowstep's cooldown is reduced by 20%, and its maximum range is increased by 20%.
    relentless_strikes         = {  90709,  58423, 1 }, -- Your finishing moves generate 5 Energy per combo point spent.
    replicating_shadows        = {  90717, 382506, 1 }, -- Rupture deals an additional 20% damage as Shadow and applies to 1 additional nearby enemy.
    secret_stratagem           = {  90722, 394320, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    secret_technique           = {  90715, 280719, 1 }, -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets. 1 point : 13,973 total damage 2 points: 27,947 total damage 3 points: 41,921 total damage 4 points: 55,894 total damage 5 points: 69,868 total damage 6 points: 83,842 total damage Cooldown is reduced by 1 sec for every combo point you spend.
    sepsis                     = {  90704, 385408, 1 }, -- Infect the target's blood, dealing 81,226 Nature damage over 10 sec and gaining 1 use of any Stealth ability. If the target survives its full duration, they suffer an additional 26,488 damage and you gain 1 additional use of any Stealth ability for 10 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
    shadow_blades              = {  90726, 121471, 1 }, -- Draws upon surrounding shadows to empower your weapons, causing your attacks to deal 20% additional damage as Shadow and causing your combo point generating abilities to generate full combo points for 20 sec.
    shadow_focus               = {  90727, 108209, 1 }, -- Abilities cost 5% less Energy while Stealth or Shadow Dance is active.
    shadowcraft                = {  94580, 426594, 1 }, -- While Symbols of Death is active, your Shadow Techniques triggers 40% more frequently, stores 1 additional combo point, and finishing moves can use those stored when there are enough to refresh full combo points.
    shadowed_finishers         = {  90723, 382511, 1 }, -- Eviscerate and Black Powder deal an additional 30% damage as Shadow to targets with your Find Weakness active.
    shot_in_the_dark           = {  90698, 257505, 1 }, -- After entering Stealth or Shadow Dance, your next Cheap Shot is free.
    shrouded_in_darkness       = {  90700, 382507, 1 }, -- Shroud of Concealment increases the movement speed of allies by 100% and leaving its area no longer cancels the effect.
    shuriken_tornado           = {  90716, 277925, 1 }, -- Focus intently, then release a Shuriken Storm every sec for the next 4 sec.
    silent_storm               = {  90714, 385722, 1 }, -- Gaining Stealth, Vanish, or Shadow Dance causes your next Shuriken Storm to have 100% increased chance to critically strike.
    swift_death                = {  90701, 394309, 1 }, -- Symbols of Death has 5 sec reduced cooldown.
    terrifying_pace            = {  94582, 428387, 1 }, -- Shuriken Storm increases your movement speed by 30% for 3 sec when striking 3 or more enemies.
    the_first_dance            = {  90735, 382505, 1 }, -- Activating Shadow Dance generates 4 combo points.
    the_rotten                 = {  90705, 382015, 1 }, -- After activating Symbols of Death, your next 2 attacks that generate combo points deal 35% increased damage and are guaranteed to critically strike.
    veiltouched                = {  90713, 382017, 1 }, -- Your abilities deal 5% increased magic damage.
    warning_signs              = {  90703, 426555, 1 }, -- Symbols of Death increases your Haste by 6%.
    weaponmaster               = {  90738, 193537, 1 }, -- Gloomblade and Shadowstrike have a 15% chance to hit the target twice each time they deal damage.

    -- Deathstalker
    bait_and_switch            = {  95106, 457034, 1 }, -- Evasion reduces magical damage taken by 20%. Cloak of Shadows reduces physical damage taken by 20%.
    clear_the_witnesses        = {  95110, 457053, 1 }, -- Your next Shuriken Storm after applying Deathstalker's Mark deals an additional 2,964 Shadow damage and generates 1 additional combo point.
    corrupt_the_blood          = {  95108, 457066, 1 }, -- Rupture deals an additional 370 Plague damage each time it deals damage, stacking up to 10 times. Rupture duration increased by 3 sec.
    darkest_night              = {  95142, 457058, 1 }, -- When you consume the final Deathstalker's Mark from a target or your target dies, gain 40 Energy and your next Eviscerate cast with maximum combo points is guaranteed to critically strike, deals 60% additional damage, and applies 3 stacks of Deathstalker's Mark to the target.
    deathstalkers_mark         = {  95136, 457052, 1, "deathstalker" }, -- Shadowstrike from Stealth or Shadow Dance applies 3 stacks of Deathstalker's Mark to your target. When you spend 5 or more combo points on attacks against a Marked target you consume an application of Deathstalker's Mark, dealing 10,375 Plague damage and increasing the damage of your next Gloomblade or Shadowstrike by 25%. You may only have one target Marked at a time.
    ethereal_cloak             = {  95106, 457022, 1 }, -- Cloak of Shadows duration increased by 2 sec.
    fatal_intent               = {  95135, 461980, 1 }, -- Your damaging abilities against enemies above 20% health have a very high chance to apply Fatal Intent. When an enemy falls below 20% health, Fatal Intent inflicts 1,777 Plague damage per stack.
    follow_the_blood           = {  95131, 457068, 1 }, -- Fan of Knives, Shuriken Storm, Crimson Tempest, and Black Powder deal 20% additional damage while 3 or more enemies are afflicted with Rupture.
    hunt_them_down             = {  95132, 457054, 1 }, -- Auto-attacks against Marked targets deal an additional 2,964 Plague damage.
    lingering_darkness         = {  95109, 457056, 1 }, -- After Shadow Blades expires, gain 30 sec of 10% increased Shadow damage.
    momentum_of_despair        = {  95131, 457067, 1 }, -- If you have critically struck with Fan of Knives or Shuriken Storm, increase the critical strike chance of Fan of Knives, Shuriken Storm, and Black Powder by 15% for 12 sec.
    shadewalker                = {  95123, 457057, 1 }, -- Each time you consume a stack of Deathstalker's Mark, reduce the cooldown of Shadowstep by 3 sec.
    shroud_of_night            = {  95123, 457063, 1 }, -- Shroud of Concealment duration increased by 5 sec.
    singular_focus             = {  95117, 457055, 1 }, -- Damage dealt to targets other than your Marked target deals 3% Plague damage to your Marked target.
    symbolic_victory           = {  95109, 457062, 1 }, -- Symbols of Death additionally increases the damage of your next Eviscerate or Black Powder by 10%.

    -- Trickster
    cloud_cover                = {  95116, 441429, 1 }, -- Distract now also creates a cloud of smoke for 10 sec. Cooldown increased to 90 sec. Attacks from within the cloud apply Fazed.
    coup_de_grace              = {  95115, 441423, 1 }, -- After 4 strikes with Unseen Blade, your next Eviscerate will be performed as a Coup de Grace, functioning as if it had consumed 5 additional combo points. If the primary target is Fazed, gain 5 stacks of Flawless Form.
    devious_distractions       = {  95133, 441263, 1 }, -- Secret Technique applies Fazed to any targets struck.
    disorienting_strikes       = {  95118, 441274, 1 }, -- Secret Technique has 10% reduced cooldown and allows your next 2 strikes of Unseen Blade to ignore its cooldown.
    dont_be_suspicious         = {  95134, 441415, 1 }, -- Blind and Shroud of Concealment have 10% reduced cooldown. Pick Pocket and Sap have 10 yd increased range.
    flawless_form              = {  95111, 441321, 1 }, -- Unseen Blade and Secret Technique increase the damage of your finishing moves by 3% for 12 sec. Multiple applications may overlap.
    flickerstrike              = {  95137, 441359, 1 }, -- Taking damage from an area-of-effect attack while Feint is active or dodging while Evasion is active refreshes your opportunity to strike with Unseen Blade. This effect may only occur once every 5 sec.
    mirrors                    = {  95141, 441250, 1 }, -- Feint reduces damage taken from area-of-effect attacks by an additional 10%
    nimble_flurry              = {  95128, 441367, 1 }, -- Your auto-attacks, Backstab, Shadowstrike, and Eviscerate also strike up to 7 additional nearby targets for 40% of normal damage while Flawless Form is active.
    no_scruples                = {  95116, 441398, 1 }, -- Finishing moves have 10% increased chance to critically strike Fazed targets.
    smoke                      = {  95141, 441247, 1 }, -- You take 5% reduced damage from Fazed targets.
    so_tricky                  = {  95134, 441403, 1 }, -- Tricks of the Trade's threat redirect duration is increased to 1 hour.
    surprising_strikes         = {  95121, 441273, 1 }, -- Attacks that generate combo points deal 25% increased critical strike damage to Fazed targets.
    thousand_cuts              = {  95137, 441346, 1 }, -- Slice and Dice grants 10% additional attack speed and gives your auto-attacks a chance to refresh your opportunity to strike with Unseen Blade.
    unseen_blade               = {  95140, 441146, 1, "trickster" }, -- Gloomblade and Shadowstrike now also strike with an Unseen Blade dealing 26,679 damage. Targets struck are Fazed for 10 sec. Fazed enemies take 5% more damage from you and cannot parry your attacks. This effect may occur once every 20 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5529, -- (354406)
    dagger_in_the_dark =  846, -- (198675)
    death_from_above   = 3462, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack. You leap into the air and Eviscerate your target on the way back down, with such force that it has a 40% stronger effect.
    dismantle          = 5406, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for 5 sec.
    distracting_mirage = 5411, -- (354661)
    maneuverability    = 3447, -- (197000)
    shadowy_duel       =  153, -- (207736) You lock your target into a duel contained in the shadows, removing both of you from the eyes of onlookers for 5 sec. Allows access to Stealth-based abilities.
    silhouette         =  856, -- (197899)
    smoke_bomb         = 1209, -- (359053) Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud.
    thick_as_thieves   = 5409, -- (221622)
    thiefs_bargain     =  146, -- (354825)
    veil_of_midnight   =  136, -- (198952)
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
    darkest_night = {
        id = 457280,
        duration = 30,
        max_stack = 1
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
    exhilarating_execution = {
        id = 428488,
        duration = 10,
        max_stack = 1
    },
    fade_to_nothing = {
        id = 386237,
        duration = 8,
        max_stack = 1
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
        duration = function() return 3 * talent.subterfuge.rank end,
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
            local ability = class.abilities[ spellName ] -- use spellName to capture spellID variants

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
        if Hekili.ActiveDebug then
            Hekili:Debug( "Danse Tracker @ Reset:" )
            for k, v in pairs( danse_macabre_tracker ) do
                Hekili:Debug( "  " .. k .. " = " .. tostring( v ) )
            end
        end
    end

    if debuff.sepsis.up then
        state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
    end

    if buff.shuriken_tornado.up then
        if prev_gcd[1].shuriken_tornado then
            class.abilities.shuriken_storm.handler()
            if buff.shadow_dance.up and talent.danse_macabre.enabled and not danse_macabre_tracker.shuriken_storm then
                danse_macabre_tracker.shuriken_storm = true
            end
        end
        local moment = buff.shuriken_tornado.expires - 0.02
        while( moment > query_time ) do
            state:QueueAuraEvent( "shuriken_tornado", class.abilities.shuriken_storm.handler, moment, "AURA_PERIODIC" )
            moment = moment - 1
        end
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    if buff.cold_blood.up then setCooldown( "cold_blood", action.cold_blood.cooldown ) end
end )

spec:RegisterHook( "step", function()
    if Hekili.ActiveDebug then
        Hekili:Debug( "Danse Tracker @ Step:" )
        for k, v in pairs( danse_macabre_tracker ) do
            Hekili:Debug( "  " .. k .. " = " .. tostring( v ) )
        end
    end
end )

spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "COMBO_POINTS" then
        Hekili:ForceUpdate( event, true )
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
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207239, 217208, 217210, 217206, 217207, 217209 )

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

        spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        notalent = "gloomblade",

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            if buff.premeditation.up then return combo_points.max end
            return 1 + ( buff.broadside.up and 1 or 0 )
        end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.backstab
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

            removeBuff( "perforated_veins" )
            removeBuff( "premeditation" )
            removeBuff( "symbols_of_death_crit" )
            removeBuff( "the_rotten" )
        end,

        bind = "gloomblade"
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
            return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
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
            return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 )
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
            if buff.premeditation.up then return combo_points.max end
            return 1 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            applyDebuff( "target", "find_weakness" )
            applyDebuff( "target", "cheap_shot" )
            removeBuff( "shot_in_the_dark" )

            st_gain( "cheap_shot" )
            removeBuff( "premeditation" )

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
            if buff.premeditation.up then return combo_points.max end
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
            removeBuff( "premeditation" )

            if buff.the_rotten.up then removeStack( "the_rotten" ) end
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
            return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
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

            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity" )
            end
            removeBuff( "nights_vengeance" )

            if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
            elseif talent.finality.enabled then applyBuff( "finality_eviscerate" ) end

            if buff.darkest_night.up and combo_points.deficit == 0 then
                applyDebuff( "target", "deathstalkers_mark", nil, debuff.deathstalkers_mark.stack + 3 )
            end

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
            return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
        end,
        spendType = "energy",

        talent = "gloomblade",
        startsCombat = true,

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            if buff.premeditation.up then return combo_points.max end
            return 1 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function ()
            applyDebuff( "target", "shadows_grasp", 8 )

            st_gain( "gloomblade" )
            removeBuff( "premeditation" )

            if buff.the_rotten.up then removeStack( "the_rotten" )
            else removeBuff( "symbols_of_death_crit" ) end
        end,

        bind = "backstab"
    },


    -- Lashes out at the target, inflicting $426592s1 Shadow damage and causing your next $426593u finishing moves to cost no Energy.; Awards $220901s1 combo $lpoint:points;.
    goremaws_bite = {
        id = 426591,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = function() return 25  * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 ) end,
        spendType = "energy",

        talent = "goremaws_bite",
        startsCombat = true,

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            if buff.premeditation.up then return combo_points.max end
            return 3 + ( talent.seal_fate.enabled and ( buff.cold_blood.up or buff.the_rotten.up ) and 1 or 0 )
        end,

        handler = function()
            st_gain( "goremaws_bite" )
            removeBuff( "premeditation" )

            applyBuff( "goremaws_bite" )
            if buff.the_rotten.up then removeStack( "the_rotten" ) end
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
        cooldown = 60,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
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

    -- Talent: Allows use of all Stealth abilities and grants all the combat benefits of Stealth for $d$?a245687[, and increases damage by $s2%][]. Effect not broken from taking damage or attacking.$?s137035[    If you already know $@spellname185313, instead gain $394930s1 additional $Lcharge:charges; of $@spellname185313.][]
    shadow_dance = {
        id = 185313,
        cast = 0,
        charges = function ()
            if state.spec.subtlety and talent.shadow_dance.enabled then return 2 end
            return talent.enveloping_shadows.enabled and 2 or nil end,
        cooldown = 60,
        recharge = function ()
            if state.spec.subtlety and talent.shadow_dance.enabled then return 60 end
            return talent.enveloping_shadows.enabled and 60 or nil
        end,
        gcd = "off",

        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "shadow_dance",

        usable = function ()
            if state.spec.subtlety then return end
            return not stealthed.all, "not used in stealth"
        end,
        handler = function ()
            applyBuff( "shadow_dance" )

            if talent.danse_macabre.enabled then
                applyBuff( "danse_macabre" )
                wipe( danse_macabre_tracker )
            end
            if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows" ) end
            if talent.premeditation.enabled then applyBuff( "premeditation" ) end
            if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
            if talent.silent_storm.enabled then applyBuff( "silent_storm" ) end
            if talent.soothing_darkness.enabled then applyBuff( "soothing_darkness" ) end

            if state.spec.subtlety and set_bonus.tier30_2pc > 0 then
                applyBuff( "symbols_of_death", 6 )
                if debuff.rupture.up then debuff.rupture.expires = debuff.rupture.expires + 4 end
            end

            if azerite.the_first_dance.enabled then
                gain( 2, "combo_points" )
                applyBuff( "the_first_dance" )
            end
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
            return ( 45 - ( azerite.blade_in_the_shadows.enabled and 2 or 0 ) ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
        end,
        spendType = "energy",

        startsCombat = true,
        cycle = function () return talent.find_weakness.enabled and "find_weakness" or nil end,

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            if buff.premeditation.up then return combo_points.max end
            return 2 + ( talent.improved_ambush.enabled and 1 or 0 ) + ( buff.broadside.up and 1 or 0 )
        end,

        usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.shadowstrike
        end,

        handler = function ()
            st_gain( "shadowstrike" )

            removeBuff( "honed_blades" )
            removeBuff( "premeditation" )
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

            if talent.deathstalkers_mark.enabled and stealthed.all then
                applyDebuff( "target", "deathstalkers_mark", nil, 3 )
            end

            if conduit.perforated_veins.enabled then
                addStack( "perforated_veins" )
            end

            removeBuff( "sepsis_buff" )

            applyDebuff( "target", "find_weakness" )
        end,

        bind = "ambush"
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
            if buff.premeditation.up then return combo_points.max end
            return 1 + ( buff.broadside.up and 1 or 0 )
        end,

        handler = function ()
            st_gain( "shiv" )
            removeBuff( "premeditation" )
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
            return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
        end,
        spendType = "energy",

        nobuff = "shuriken_tornado",

        startsCombat = true,
        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            if buff.premeditation.up then return combo_points.max end
            return active_enemies
        end,

        used_for_danse = function()
            if not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.shuriken_storm
        end,

        handler = function ()
            st_gain( "shuriken_storm" )

            removeBuff( "honed_blades" )
            removeBuff( "premeditation" )
            removeBuff( "symbols_of_death_crit" )
            removeStack( "the_rotten" )

            if buff.silent_storm.up then
                applyDebuff( "target", "find_weakness" )
                active_dot.find_weakness = active_enemies
                removeBuff( "silent_storm" )
            end

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
            return 60 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 )
        end,
        spendType = "energy",

        talent = "shuriken_tornado",
        startsCombat = true,

        handler = function ()
            applyBuff( "shuriken_tornado" )
            if buff.shadow_dance.up and talent.danse_macabre.enabled and not danse_macabre_tracker.shuriken_storm then
                danse_macabre_tracker.shuriken_storm = true
            end

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

        spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.95 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            if buff.premeditation.up then return combo_points.max end
            return 1
        end,

        handler = function ()
            st_gain( "shuriken_toss" )

            removeBuff( "premeditation" )
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
    nameplateRange = 10,
    rangeFilter = false,

    canFunnel = true,
    funnel = false,

    damage = true,
    damageExpiration = 6,

    potion = "phantom_fire",

    package = "Subtlety",
} )

spec:RegisterSetting( "priority_rotation", false, {
    name = "Subtlety Rogue is able to do funnel damage. Head over to |cFFFFD100Toggles|r to learn how to turn the feature on and off. " ..
    "If funnel is enabled, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers in order to do priority damage.\n\n",
    desc = "",
    type = "description",
    fontSize = "medium",
    width = "full"
})

--[[
spec:RegisterStateExpr( "priority_rotation", function ()
    local prio = settings.priority_rotation
    if prio == nil then return true end
    return prio
end )
--]]

spec:RegisterSetting( "mfd_points", 3, {
    name = "|T236340:0|t Marked for Death Combo Points",
    desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
    type = "range",
    min = 0,
    max = 5,
    step = 1,
    width = "full"
} )



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


spec:RegisterPack( "Subtlety", 20240922, [[Hekili:v3ZwZnUn39BXtMrR0ABvj6lR3oR0mTj9HStBEOo9RVjkksiBwtrQqszhNrJ(T3daijUDaaLVL97LeVIGhGZ9la4Wftx87lUnjQMS43cMeC5KVgemEYntNo9RlUT(5TKf3Unk(HO7G)ipAd8FVD3Q6ms9Z0h8Cwrucfavf7kJHhU42v7sZQ)18fRWH6nWy3sIHF(6PlU9(0KecFSKQ4f3sh75t(65bb)Rhw(FSEDACkjp(5dl3TLcSQdF)W3BhZKlo7Ws4)pDkm2Bt38ZiJ6MZNEfmkg4SmKVCEWnWt)97jhw()gvc)N067tZxCBwAvDff3sRjBO)XVXivK8OvzKKf)7lUnkUoTagzu19KQWI1H13tcjBwrkbYr2IBJlHxTmnAXTdpSC1U1RhhxKLeUkROiz8UThwUF)HLWJo5WY6OmsE94KO8ks4MO4OvLKXnt1HLdAE9Q7JskEkegvmPdaSNO(Iv1al7WY5ZoS8IdlhXaGysKweDZWOgyvuvXg9607UVoSKSjknh(LVDy50jTcawq3AGNAHa9eqsjLRIkFOkCvjS6VxM4WqG1zGiwwwe9fcz)cf)g0TOtZFm9UIs4553fYPdj7QQfyqhPOHiTklcKP6OsK)yx62TKKXRIYtkYsjLmm4jGjtsAgmB(kJstcjpsNZOKekaAXBeSaW5lSGZBslllytY6s432vcttDXMc4xFQYa9n4Sdysg1rL3rQhxNUHaVCyskHZvNELgwHZta(A7I39YbWJlTGhRirXalbMDkOxrEUipzXT7aPTI1RdVloHQx0mj4JvGQGmiqUJYGNcl5SSw0KlctiBbUss0D3bR(ogNKYH6aKLDh0QhzY96GshTQQUOCdbScuc8XIIC(iIla1IINYnE84oTG5GLKjuAkqUUYgBpkpno8UYuYAaoubDCsL548tM(iXVRTGF1Lapgudk2vfwdkbvBsRbqztGwtlu3SctuULKyd0WQ5lwwnPBajI1K46WOQysov955Wks5Un2O7UEdbkKuupUC3wQAcO8f)ay0ryfgZufDrEJvswA(dK6PAoeEmc(lySJBEEy1Z5XHvzf1hwsPlkkh4KZHSHDQmZvzCDe6rCZgnZ046PJ7EJKDLmmXJdGznYgDtSNLFGKqB30giMwGxN8CRJjlO4a)i28UL1OofbxRmWEi9pQK4kaN7RU5CbhhNl49KZf8UZ5MIX5M(JhNla4C184ntWIotWYGaoZYc5(sR40ZagXFyNVL7GWH2WwIMrDLbA)aG6I7qchaiDTuOhutl0yuaFRpsGrWOfa6DEl9mHWTGKMNe(ej6HCsvhbt4OdSrvw8inSeimoiwUvi(6ATe9ugaIqyw3G4XCheuijpudVgjeWRUFxz6dWqyofCfcN2izXRxMUL)WFbCNCpSqZEGabq3ouQxmyShwsfrRa6hK1aJhy4SioJevYIzaIXIsteIrdLeZEEZQImwuoj0jebHtZjpMceS0S06NTr1SZp)MGFkGPXWLiKTX)1sLeIrYeX2OR6cPQHTQoMAkrDD0US6oP5oIppAanygipKhaVuApxpY0cis2kk1V9DAv3O)v2osRN7S0ysieLmeUjlyu2ad5UpRGFgcXljLbbhHngdXTeY)hH0mP45t1aL4KkxXq58D5zJHeHIqMkg4bfHBlsZBv3N2QH1zHrfreuAfKhl0djZkYXOr)NLPX1SqnAHw5UCR4r3BJf6GI21pFpHMnx66dlFUyhv)ccThe)GaCalk0mgoJIy5Pv3d6AmfqQC6gcDq1fqKH51m9YwPOErNBgDydVs3fPMgCcKveH(UuNpcxaY8bGneVfsr9pdb7X5nzSrwtJfl9rsOjttD0s(BmNSgpBYWasxGw(G6MOmz277sKqyUQcMJYhutJelkv2cW1QvorB0vjQeItwa4Ma4PuQpK8TnYpjNuE3ZQyl1XQaDzjopgcOgeI(m8WRKFy99W8LbzxsIeeHpRdcUevCz06ATr1tuH7LMIj2DtRJjTj6EkvcM9OsYDejL1OY4OCAIXLLWIKbDfBInpF7USkD7XtvmBNrzrvH)F7sUBdfsAJvZ49DS8Sbw5dvgwW3wsOIgrM2WJ2Un7zQetf9FzAi)OmuFHSn5OmWN69W)C7U)6Vaw5QI)mSBDeghvvJ5nW67kTKrEOdt(A2of0ci)kQPwGAnfZSVF0TU4oi4HXR3LNtY0SoE7trB5M52wMwactqSPLf1nrgtnAwtlTxlmHFQIkpXNDjQy7Bh2(Yy(y8VuvYYtk857JQGqNIG02ZFomzBfE6rMJIApYDAB(tpyKmEAeAnMto)4zakEIHbyjt4bprXI5(ie(rZB8guvTSJzNjv0dFjdKJ5hzGIa)T4Wqe8n18l19Xdemdg)45mUjVWMCgal05agGTu0CC1dq)24N3NV6E5vt4G2wvGv4CQgU(FOHVj)CiWdA0B)cTu(hw(FXRLpp7POc4pIOuE2q(DMZhwqDSGaPypeQci4cJOyTsIxbN2wg5kTYyCc7TtOjpgMWN0bwZOxu(aN5wcaapB7ryEouk5jpdAiQlceuotLUvEbbIxUWroS6oy0upCNp)0jUidMRg6RSalbWw3h4IcAgDOrzJyUXVD4UeAm8FXzyARwQoYLnwB75gROuAI1fzzafHvEF1Dqsv6OKSfIgqgOvkqCikx9k2ZI42GKQbl)PAVW5C5k56h5FYLDr0a8QWveqfGesRRRBRRIPaIOPe8UutIVpp9p2PQbyA98AjdkD7(gMDdXCHNPAlXZx11(gpJeL6WPx(e9bBl1Na1sgr2wL6ChJKRpEpXOUhHXtSqt5clO7qwNwCpPubwr(Glv3FP(Q0OUJl9HYJxIl5YLEbJpe)CmnDTgl6)gAe1D8knWPh6m)Xhws3zZIDGtKFvcVoS82oedxjWlvyGTcUOupo8kK7JV1NnR6yW)(H8VnyUhETq5T1Ti1ElyxVMKlvx0okKScNcbIQfOqlvgzFluFtbfKcRJno(EvRoSg(H9AM5GOOQHlk6YqhB7MULFf8towpBQ3t09p3G(yfL7OXc1szCHPzej2QILdzxzpskxrk1WiCEblonbcb(MkOYNG7WY0nq0JURJ3rlVIMyHzu8OH0n0pxZUGlYEiPhx2y1OcB4aibn2KAINIS5G2CInoH0ZSE4wqhWwiBfihd9X4pyudKwHzGDWwCsoSDCN4LAwZw6)OP(Zq64mZNm6qt9xAZwXisCmA2ryH1xMiwZuCoZ2YO(AiLga3K(zQXIDgysUycRIPDZfNkoo(EkVRQnqwf7X6XyQLNIOGNwt8KtATN4zhFQLTvTBfWGwV7okVdeW)5FPIVNcDfsJHD0kOLuXhY3UPcltomE7WJI9AxQFOmO8ubgou6qlTKzTDqpCOW7uQBKCgjU2s(BevH(yT40pxm6U1vp0GT0UIDWC08mB0EDtA9LfAK(PP9jwYOhpu94(e7qsj5xeapWjEcYXai2Ic8BlJVMaWeBtIqi0t4qxllPzagkZPPUB6B8bv7UZVgU5KRvTMidyHjfbol9Cgg7PejS8tZO0D6zYQ2J4m34M9KyWjyhz8(FRP2msi12c2)NIphFH6DSuKsZx55Mki2orcoiv0qoLQbruCAugRk1m8Ohrol)kIDLIYWcxVR8zgy6rOR4GbmHskPwbzGPhblkbgRgoKknqAjPR2hb9iEl0vjfSv1LWVtRoRsv7dTuinNXU8BfuhGv1T7I(lpBxjjhHhh5b0pB3OELKTJG6v0Ui5ifZMQbKRMtHRZ)DtYD2I4aL0(lmY6)aJS(ggbONqa8ehOEYuQv9(F6dr0EmgVGGFg6T4fno(g4l7hVUlCyG2UoWrOU2BszJW)P8sH(5JAsgGKXpyeSQwpMRgTB72h(Icn9OOlJulGRCMbokJRvtLCDA5mfETMnF12mD7nUhfIT9e84E7J4bQ1SdutCT40k2afRPNhlUVQMTn8fTFpdf4RN78JQTil3SOgXoFzs7kJo2ZazKOmopM)2slNaVcNhu37(gvrLZzOnVon2V0et)3Oh2Mdl)VB3(iA2RP0YtLtpkX72owtw1MLqSDx4CibdPcqDnMnw)8rBzv4oHPzOoS05i9fg2WA)vslqKJlxsuF7ZLyMpKUnSLl5CpG5gkfoFKEr(CHSfNJ6nBInWsY6scq1yCcDriNQ(TNC7O)IK4mdWwJooTknWw(5n(65xsly1fLXJoyY4BUs3qEsA12OA(TqZ(HHvqp10Q86(lk5zBBBzpstbD6u8fIDpevmxlnazwPJSUpVZAJKdO2ttVYRicdqERnvPbU3ea7YQTgmb78rzm51gLmHCtpCj5DVb1kRHKyST7Zcy2n(bWz1tj0IXQyXmr5i8VARnmfrhS3XHJSJ)QBZLHDeSQY3dKPwC(yEHyIRAk7ZN3mPQAHBFyesXXWOh43VdUsKNJUdwgvgNhl)mNrnXe54y7Qzze3(K6bZL8yAvmDtTmoimGlZhPB)bmQMloomZ3(uuzoqMRwCl7AAdA0fL1nNfQpLsVqaFIAB)p2LwsXMQIn0Jl1U6In07IdOTDFuoyvD8HV)FMMdpIEJX)5ICyMyp(tyXibqKEOsrFwlHdgZWP)5iFWvyhtdOMwa1HyaoeTeuTg49e6T(CDPfQIY1UvNSGENC9c5MZXPXvrv6sMXSc2oBcZLwU8QFQBUU6dCUUXYCHC8u7OBoocR6KT3AW7fW63ptdOImGETIpEa3bYV6hKwjc4Jrzf)wdEVaw)Mu6IZHsJF7a8yAxWaXIA3jG(TXQQrqbg2qSf1qpTg(godxGpdYHdObBSifeqfL(2Cn)ooQRbB)nh3NobFkKYsvd2ixEO(cuU7i2nksdOspPN0ZUlAYXrrV2QIK(1tarvczik4TnGBEdjqmR8sb(l1XW7m49c4xQX2EUUFPGVdWF59KzAd4VjIH2x5VmsY7m49c4xQiypx3VuWBZYeVsVhNzPp4KtEXU2SqjF1P8ybIOLXrd4ol1J(883Nd1xjj3Ulv107)KUFv8S))KBNRXjVnjx)UKYQL5s)wQOnj2Uel9e6ixVeTjWXfq5VJ5WsyZ6L7uxEXYvCrh6wkBW7c)2i5(3X5YiAI3X5YInp5Doxxgg5SfOdvJSX5VQ4yZ9j9W51ppD9eIkNsDd50hnpb790w8Re)N(HAk69X)QnW(AjnFKfw02K9w6Q1Yu8AP(wQhG85MvFnJCKA7lyFFO()imzVcBotTyiUjgp(rj4t6X6i9SEgOJ0ji8t)ZwapItoJoHW4i10tiQCib1ak6biuhUFKgyE)TVyzgELwH)i1m)byU0o8BiwcqoAC6W(JmCtlZ1lsBd1MdRTi9MyTr04b0wtMD2WEAbWOleQtlT1Lc7j8FLUMTAFrQdaAW9r6oG9eU6nncnqBRjbkZ))vgRNc0B4n5a6roG1LXHhV4wGNFFr5IBP9PCA7iQyDQ4ukvnURi3No7FrUxsD47yJO9uoCg9qynZFhI6m2XsB2f4qJ2kDPBZUvOH)AQneQZm6huZME47)0HLVMo4uFWEJd6rdYQ0vP6dGAkbOONc1aOPNLUEM9Y2oy4j2ly8(9oQ948zokO6OxZsoqEjBUQKwYM4JyjJSQM7aDSSIBc8IQI0na5Fw8t0MCP8)wfxvoT6n4j)iXO3rlLHHEd(Hdliiq)dIDYtuwYQc8ajw(4bpF20bNy5S1lbeTMgzdU1ULSNXBIGCzo1Ueovx6nUxr6Ngif1S)bZlhUckGEUVgit2Mj36P2VhVjvnxzudobfS73pe74A)Tztp1AaH73RCxnGXoW2k4IrwMx)egwCauYH6vb8BZcM0U0ybUW6IJFo4Qt7IzQBdy)SyOCEkBhuHFvE2v7yIMtiiIE1PYnBrKxM1ofL)DTUNO8JuAwIsQ3JzimvJr5WfZKPLphAZNfC6qJazgWOY2AJtZND9(9SrG0oMhD(WtS0eMhCITaBgnyi6XXB)(tqcyzetr8iBjY9HYWwd4TkzWETTZiQyrQe(tlozJk(nkv8elr3mYC5k4oMpRLoklaa2lmmGJ18FASJB)uBUFVIeZ3MDj4FYz0(DmA99baSp08eKIRpyOMK5vdII1BuvZvfFppy0ibvebO60dXUJrz4TVOEL4hOA35ADOWBrtuiG7TzWWoxZQfkPJ3FXaXiSCaLHbzABmyK(Aron4Zu6DrC7)wwHIlakImHg(F1aZZ))8Pt8JLbgiqWLJOH(4u8z)((rBWviBnsDb3mr)BbtgmznillWytW3M4a6vZrgpXOFZdMGGdVoe4LT(DsPPcZN0CBBKAIssshyxPtq(rc)1ABsd8qyaV2TSF(ZvULcWJn0suGJd1czbFAOiD(LmUGLcZoYpDKPe)e91IrBdQNRhrmexi0He0Cz7Gs7iegHcCtBsGu38AhRjBoc1iEbnsf6TNiXAxMWztyqsxyGRRn1C5uRpAu6emAuZVIX8XEKORcPcUo9DNRFg9cPVAq1)7tR)X0XpltG2OA0rnp2bqI6AaAO9ZNoYNI(SRNGRRyOQm8IjFUdwQ3n7rJKSjy5IedXwpHrVE77)owmNWZ3J6xaLip0dvgxkz4qR5k18gY9AhWGZqKRzOnl5yHttdHI2xcgOXoUrhRVtUVU8ImAPBxVLu1frP8M7naxP0xWdo1YU0)7Jyy1uV0W(PuIIcbc1RFQAyaAUSUMYinEjkTcYixnfYPtaBH6Qoxl0CqAvnglxENDPZ8Gw7ObvE4Ij2c5sh16DeoGh2jglnTuwe9NeLkozmtNOKBEZtS6RcfdnDvl66lkI7Y9Kf93ORbV033ORLTy7fq1d0HIAlBX(ClEpwX1o1O2ZOFNdPWJZIv(aBcISTKDLtij6kUr6jX8s1ZRStdGetaUzPPt8HcMFgj7KZr9L7ZGGfbU(8bVCaMhD3RENFhjT6pFisgAZMEL0QeNXoY3Yb7lo5zsF5)4jzEIsHsBSgy89MuOKQ(iAkHMeky0w)IlkQqU3BDgplkp0CTVvK(rW)ExVw(qoQlDijSQxhHRGaL(P2njtmnjaBgh2Gd1QhoUjWnoy)7ePj1hlahR6Z2N4QZyFG7A3wggOh2zM0yNC6s)ZeBho9u3E2gnFMJ9PbpElGXdq2X6jqzJUKeCIsE2woh(lXaTaA2NuhYIAKZaFKZG3eYjYwI9cjNtv2eUpmYPGGY3TgJqE0BSdnX9mCOl)Ns2wLhGOIRk5YH7dH9R4x6(50A5HssG0hyjD5TJWGG3n60mdSy64Mo1oVLsFTFYOulJqo0rTGYDLUWSP4vprRu1iVfg24U8fbJ6cqYYMBHs3gkTHNsi8(9g1XFKtY5aPo3cYmgxSBle8m4JmINXRwtjal3gMMT1mgWtf0S9S8Tz0wZYOrOlk5I5lOdA6poRCa9tTQjK1hOB4p0m2vPmFmBYkZnPvnp58aPDtc7U2GrgK1IqfgA8vA2SuKRG)XxPDwwW)e97VKANnbzjUsQvIOUonethyV6hA7p0fw3n4FsUWyVzRi1QH5YA5SlXRO4iTQtiWbZD(C4jQnGeCB2Dj9QwQtdsLf9h3k1iVIOXIqDKb0z9w7P4DKo4ck1J03EO0LiFxzUCuqje7SDgD09DBvkURMpkLQ2s2Nn7(8orB3ShOSlENNAWIOhyPsS2Cq)dwbAXjwYehBH87E31STrGZU2rH8DusllXQIlB5rOUhehq060PbF2N2HYg)iDAETC0BMp7lwcL1A4CDQ12AdL9qEVFI29rd3g7PhBsm1SNBXn6PYIUE5fyD(SlNGVqUqoQ9Ukb0bg(NCmkGSRZEIRVsH(owtkZPZt(v6h9b(QriY47qikHuSPGVfNCm7Ngm19a6d6J)x)KqC6wxOfAjVn9ZULP8nb)OnzzRy1G3L4GtC0J6KVSF2WMoXY(APmx0tMSpYfRBLT4))d]] )