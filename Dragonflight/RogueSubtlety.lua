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
    -- Rogue
    acrobatic_strikes          = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by 3 yds.
    alacrity                   = { 90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison            = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.0% for 10 sec.
    blackjack                  = { 90696, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    -- cheat_death                = { 90747, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cheat_death                = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows           = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                 = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves            = { 90743, 231719, 1 }, -- Physical damage taken reduced by 3%.
    deadly_precision           = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem           = { 90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand          = { 90639, 385616, 1 }, -- Deal 1,799 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness                = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by 10%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                    = { 90764, 5277  , 1 }, -- Increases your dodge chance by 100% for 10 sec.
    find_weakness              = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 15% of that enemy's armor for 10 sec.
    fleet_footed               = { 90762, 378813, 1 }, -- Movement speed increased by 15%.
    gouge                      = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    improved_ambush            = { 90692, 381620, 1 }, -- Shadowstrike generates 1 additional combo point.
    improved_sprint            = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison      = { 90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach               = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison            = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 5% Leech.
    lethality                  = { 90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    marked_for_death           = { 90750, 137619, 1 }, -- Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    master_poisoner            = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nightstalker               = { 90693, 14062 , 2 }, -- While Stealth or Shadow Dance is active, your abilities deal 4% more damage.
    nimble_fingers             = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison             = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    prey_on_the_weak           = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    recuperator                = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity         = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges 2 additional combo points.
    reverberation              = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 75%.
    rushed_setup               = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    seal_fate                  = { 90757, 14190 , 2 }, -- When you critically strike with a melee attack that generates combo points, you have a 50% chance to gain an additional combo point per critical strike.
    shadow_dance               = { 90689, 185313, 1 }, -- Allows use of all Stealth abilities and grants all the combat benefits of Stealth for 8 sec, and increases damage by 30%. Effect not broken from taking damage or attacking. If you already know Shadow Dance, instead gain 1 additional charge of Shadow Dance.
    shadowrunner               = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep                 = { 90695, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    soothing_darkness          = { 90691, 393970, 1 }, -- You are healed for 30% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    subterfuge                 = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for 3 sec after Stealth breaks.
    thiefs_versatility         = { 90753, 381619, 2 }, -- Versatility increased by 2%.
    thistle_tea                = { 90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 19.6% for 6 sec.
    tight_spender              = { 90694, 381621, 1 }, -- Energy cost of finishing moves reduced by 10%.
    tricks_of_the_trade        = { 90686, 57934 , 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride         = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                      = { 90759, 14983 , 1 }, -- Increases your maximum Energy by 50 and your Energy regeneration by 10%.
    virulent_poisons           = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.

    -- Subtlety
    black_powder               = { 90712, 319175, 1 }, -- Finishing move that launches explosive Black Powder at all nearby enemies dealing Physical damage. Deals reduced damage beyond 8 targets. All nearby targets with your Find Weakness suffer an additional 20% damage as Shadow. 1 point : 166 damage 2 points: 332 damage 3 points: 497 damage 4 points: 663 damage 5 points: 829 damage 6 points: 995 damage
    blind                      = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    cloaked_in_shadows         = { 90733, 382515, 1 }, -- Vanish grants you a shield for 6 sec, absorbing damage equal to 30% of your maximum health.
    danse_macabre              = { 90730, 382528, 1 }, -- Shadow Dance increases the damage of your attacks that generate or spend combo points by 6%, increased by an additional 6% for each different attack used.
    dark_brew                  = { 90719, 382504, 1 }, -- Your attacks that deal Nature or Bleed damage now deal Shadow instead. Shadow damage increased by 10%.
    dark_shadow                = { 90732, 245687, 2 }, -- Shadow Dance increases damage by an additional 15%.
    deepening_shadows          = { 90724, 185314, 1 }, -- Your finishing moves reduce the remaining cooldown on Shadow Dance by 0.7 sec per combo point spent.
    deeper_daggers             = { 90721, 382517, 2 }, -- Eviscerate and Black Powder increase your Shadow damage dealt by 10% for 8 sec.
    fade_to_nothing            = { 90733, 382514, 1 }, -- Movement speed increased by 20% and damage taken reduced by 10% for 8 sec after gaining Stealth, Vanish, or Shadow Dance.
    finality                   = { 90720, 382525, 2 }, -- Eviscerate, Rupture, and Black Powder increase the damage of the next use of the same finishing move by 15%. Lasts 30 sec.
    flagellation               = { 90718, 384631, 1 }, -- Lash the target for 681 Shadow damage, causing each combo point spent within 12 sec to lash for an additional 136. Dealing damage with Flagellation increases your Mastery by 2.5%, persisting 12 sec after their torment fades.
    gloomblade                 = { 90699, 200758, 1 }, -- Punctures your target with your shadow-infused blade for 890 Shadow damage, bypassing armor. Critical strikes apply Find Weakness for 10 sec. Awards 1 combo point.
    improved_backstab          = { 90739, 319949, 1 }, -- Backstab has 15% increased critical strike chance. When you are behind your target, Backstab critical strikes now also expose a flaw in their defenses, applying Find Weakness for 10 sec.
    improved_shadow_dance      = { 90734, 393972, 2 }, -- Shadow Dance has 1 sec increased duration.
    improved_shadow_techniques = { 90736, 394023, 1 }, -- Shadow Techniques generates 3 additional Energy.
    improved_shuriken_storm    = { 90710, 319951, 1 }, -- Shuriken Storm has an additional 15% chance to crit, and its critical strikes apply Find Weakness for 10 sec.
    inevitability              = { 90708, 382512, 1 }, -- Backstab and Shadowstrike extend the duration of your Symbols of Death by 0.5 sec.
    invigorating_shadowdust    = { 90706, 382523, 2 }, -- Vanish reduces the remaining cooldown of your other Rogue abilities by 15.0 sec.
    lingering_shadow           = { 90731, 382524, 2 }, -- After Shadow Dance ends, Backstab deals an additional 50% damage as Shadow, fading by 2.8% per sec.
    master_of_shadows          = { 90735, 196976, 1 }, -- Gain 25 Energy over 3 sec when you enter Stealth or activate Shadow Dance.
    night_terrors              = { 90711, 277953, 1 }, -- Shuriken Storm reduces enemies' movement speed by 50% for 8 sec.
    perforated_veins           = { 90707, 382518, 2 }, -- Shadowstrike increases the damage of your next Backstab by 20%. Max 5 stacks.
    planned_execution          = { 90703, 382508, 2 }, -- Symbols of Death increases your critical strike chance by 5%.
    premeditation              = { 90737, 343160, 1 }, -- After entering Stealth, your next Shadowstrike grants up to 10 sec of Slice and Dice, and generates 2 additional combo points if Slice and Dice is active.
    quick_decisions            = { 90728, 382503, 1 }, -- Shadowstep's cooldown is reduced by 20%, and its maximum range is increased by 20%.
    relentless_strikes         = { 90709, 58423 , 1 }, -- Your finishing moves generate 5 Energy per combo point spent.
    replicating_shadows        = { 90717, 382506, 1 }, -- Rupture deals an additional 20% damage as Shadow and applies to 1 additional enemy within 8 yds.
    sap                        = { 90685, 6770  , 1 }, -- Incapacitates a target not in combat for 1 min. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    secret_stratagem           = { 90722, 394320, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    secret_technique           = { 90715, 280719, 1 }, -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets. 1 point : 892 total damage 2 points: 1,784 total damage 3 points: 2,676 total damage 4 points: 3,568 total damage 5 points: 4,460 total damage 6 points: 5,352 total damage Cooldown is reduced by 1 sec for every combo point you spend.
    sepsis                     = { 90704, 385408, 1 }, -- Infect the target's blood, dealing 5,513 Nature damage over 10 sec and gaining 1 use of any Stealth ability. If the target survives its full duration, they suffer an additional 2,029 damage and you gain 1 additional use of any Stealth ability for 10 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
    shadow_blades              = { 90726, 121471, 1 }, -- Draws upon surrounding shadows to empower your weapons, causing your combo point generating abilities to generate 1 additional combo point and deal 50% additional damage as Shadow for 20 sec.
    shadow_focus               = { 90727, 108209, 1 }, -- Abilities cost 15% less Energy while Stealth or Shadow Dance is active.
    shadowed_finishers         = { 90723, 382511, 2 }, -- Eviscerate and Black Powder deal an additional 20% damage as Shadow to targets with your Find Weakness active.
    shadowstep_2               = { 90729, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    shiv                       = { 90740, 5938  , 1 }, -- Attack with your off-hand, dealing 397 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards 1 combo point.
    shot_in_the_dark           = { 90698, 257505, 1 }, -- After entering Stealth or Shadow Dance, your next Cheap Shot is free.
    shrouded_in_darkness       = { 90700, 382507, 1 }, -- Shroud of Concealment increases the movement speed of all party and raid members within its radius by 100%.
    shuriken_tornado           = { 90716, 277925, 1 }, -- Focus intently, then release a Shuriken Storm every sec for the next 4 sec.
    silent_storm               = { 90714, 385722, 1 }, -- Gaining Stealth, Vanish, or Shadow Dance causes your next Shuriken Storm to have 100% increased chance to critically strike.
    stiletto_staccato          = { 90725, 382509, 1 }, -- Shadow Techniques now also reduces the remaining cooldown of Shadow Blades by 1.0 sec.
    swift_death                = { 90701, 394309, 1 }, -- Symbols of Death has 5 sec reduced cooldown.
    the_first_dance            = { 90735, 382505, 1 }, -- Activating Shadow Dance generates 4 combo points.
    the_rotten                 = { 90705, 382015, 1 }, -- After activating Symbols of Death, your next Shadowstrike or Backstab deals 50% increased damage, generates 4 additional combo points, and is guaranteed to critically strike.
    veiltouched                = { 90713, 382017, 1 }, -- Your abilities deal 5% increased magic damage.
    weaponmaster               = { 90738, 193537, 1 }, -- Shadowstrike and Backstab have a 15% chance to hit the target twice each time they deal damage.
    without_a_trace            = { 90702, 382513, 1 }, -- Vanish has 1 additional charge.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5529, -- (354406) Cheap Shot grants Slice and Dice for 15 sec and Kidney Shot restores 10 Energy per combo point spent.
    dagger_in_the_dark = 846 , -- (198675) Each second while Stealth is active, nearby enemies within 10 yards take an additional 5% damage from your next Shadowstrike for 10 sec. Stacks up to 8 times.
    death_from_above   = 3462, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack. You leap into the air and Eviscerate your target on the way back down, with such force that it has a 10% stronger effect.
    dismantle          = 5406, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for 6 sec.
    distracting_mirage = 5411, -- (354661) Distract slows affected enemies by 30% and creates a Mirage that follows an enemy for 8 sec. Reactivate Distract to teleport to your Mirage's location.
    maneuverability    = 3447, -- (197000) Sprint removes all root effects and suppresses all movement-slowing effects for 4 sec when used.
    shadowy_duel       = 153 , -- (207736) You lock your target into a duel contained in the shadows, removing both of you from the eyes of onlookers for 5 sec. Allows access to Stealth-based abilities.
    silhouette         = 856 , -- (197899) Shadowstep's cooldown is reduced by 67% when cast on a friendly target.
    smoke_bomb         = 1209, -- (359053) Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud.
    thick_as_thieves   = 5409, -- (221622) Tricks of the Trade now increases the friendly target's damage by 15% for 6 sec.
    thiefs_bargain     = 146 , -- (354825) The cooldowns of Shadow Blades, Vanish, and Feint are reduced by 33%, but using one reduces your damage by 10% for 6 sec.
    veil_of_midnight   = 136 , -- (198952) You remain enveloped by the shadows for 2 sec after Stealth or Vanish fades, increasing dodge chance by 100%.
} )


-- Auras
spec:RegisterAuras( {
    danse_macabre = {
        id = 393969,
        duration = function () return talent.subterfuge.enabled and 9 or 8 end,
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
        id = 384631,
        duration = 12,
        max_stack = 30,
        copy = 323654
    },
    flagellation_persist = {
        id = 394758,
        duration = 12,
        max_stack = 30,
        copy = { "flagellation_buff", 345569 }
    },
    -- Talent: $?s200758[Gloomblade][Backstab] deals an additional $s1% damage as Shadow.
    -- https://wowhead.com/beta/spell=385960
    lingering_shadow = {
        id = 385960,
        duration = 18,
        tick_time = 1,
        max_stack = 50
    },
    master_of_shadows = {
        id = 196980,
        duration = 3,
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
    deeper_daggers = {
        id = 341550,
        duration = 5,
        max_stack = 1
    },
    perforated_veins = {
        id = 341572,
        duration = 12,
        max_stack = 3
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


local stealth = {
    rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
    mantle  = { "stealth", "vanish" },
    sepsis  = { "sepsis_buff" },
    all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
}


spec:RegisterStateTable( "stealthed", setmetatable( {}, {
    __index = function( t, k )
        if k == "basic" then
            return buff.stealth.up or buff.vanish.up
        elseif k == "basic_remains" then
            return max( buff.stealth.remains, buff.vanish.remains )

        elseif k == "rogue" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
        elseif k == "rogue_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

        elseif k == "mantle" then
            return buff.stealth.up or buff.vanish.up
        elseif k == "mantle_remains" then
            return max( buff.stealth.remains, buff.vanish.remains )

        elseif k == "sepsis" then
            return buff.sepsis_buff.up
        elseif k == "sepsis_remains" then
            return buff.sepsis_buff.remains

        elseif k == "all" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
        elseif k == "remains" or k == "all_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
        end

        return false
    end
} ) )


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
        if talent.subterfuge.enabled and stealthed.mantle then
            applyBuff( "subterfuge" )
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark", 4 )
        end

        if buff.stealth.up then
            setCooldown( "stealth", 2 )
        end
        removeBuff( "stealth" )
        removeBuff( "vanish" )
        removeBuff( "shadowmeld" )
    end

    if buff.shadow_dance.up and talent.danse_macabre.enabled then
        danse_macabre_tracker[ a.key ] = true
    end
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

spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if stealthed.all and ( not a or a.startsCombat ) then
        if buff.stealth.up then
            setCooldown( "stealth", 2 )
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark" )
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )
    end

    if buff.cold_blood.up and ( not a or a.startsCombat ) then
        removeBuff( "cold_blood" )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
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

        spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        notalent = "gloomblade",

        handler = function ()
            removeBuff( "honed_blades" )
            applyDebuff( "target", "shadows_grasp", 8 )

            if azerite.perforate.enabled and buff.perforate.up then
                -- We'll assume we're attacking from behind if we've already put up Perforate once.
                addStack( "perforate" )
                gainChargeTime( "shadow_blades", 0.5 )
            end
            gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )
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

        spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "black_powder",
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
            if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
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

        cycle = function ()
            if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
        end,

        usable = function ()
            if boss then return false, "cheap_shot assumed unusable in boss fights" end
            return stealthed.all, "not stealthed"
        end,

        handler = function ()
            applyDebuff( "target", "find_weakness" )

            if talent.prey_on_the_weak.enabled then
                applyDebuff( "target", "prey_on_the_weak" )
            end

            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end

            applyDebuff( "target", "cheap_shot" )
            removeBuff( "shot_in_the_dark" )

            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

            gain( buff.shadow_blades.up and 2 or 1, "combo_points" )
            removeBuff( "symbols_of_death_crit" )
        end,
    },

    -- Finishing move that disembowels the target, causing damage per combo point. Targets with Find Weakness suffer an additional 20% damage as Shadow. 1 point : 273 damage 2 points: 546 damage 3 points: 818 damage 4 points: 1,091 damage 5 points: 1,363 damage 6 points: 1,636 damage
    eviscerate = {
        id = 196819,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function () return combo_points.current > 0 end,
        handler = function ()
            removeBuff( "masterful_finish" )

            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity" )
            end
            removeBuff( "nights_vengeance" )

            if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
            elseif talent.finality.enabled then applyBuff( "finality_eviscerate" ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "honed_blades", nil, effective_combo_points ) end

            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )

            if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
        end,
    },

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
            applyBuff( "flagellation" )
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

        spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "gloomblade",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shadows_grasp", 8 )
            if buff.stealth.up then removeBuff( "stealth" ) end
            gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )
            removeBuff( "the_rotten" )
            removeBuff( "symbols_of_death_crit" )
        end,
    },

    -- Talent: Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets. 1 point : 692 total damage 2 points: 1,383 total damage 3 points: 2,075 total damage 4 points: 2,767 total damage 5 points: 3,458 total damage 6 points: 4,150 total damage Cooldown is reduced by 1 sec for every combo point you spend.
    secret_technique = {
        id = 280719,
        cast = 0,
        cooldown = function () return 45 - min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ) end,
        gcd = "totem",
        school = "physical",

        spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        talent = "secret_technique",
        startsCombat = true,

        usable = function () return combo_points.current > 0, "requires combo_points" end,
        handler = function ()
            applyBuff( "secret_technique" ) -- fake buff for APL logic.
            if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity" ) end
            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
        end,
    },

    -- Talent: Draws upon surrounding shadows to empower your weapons, causing your combo point generating abilities to generate 1 additional combo point and deal 50% additional damage as Shadow for 20 sec.
    shadow_blades = {
        id = 121471,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
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

        spend = function () return ( azerite.blade_in_the_shadows.enabled and 38 or 40 ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        cycle = function () return talent.find_weakness.enabled and "find_weakness" or nil end,

        usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,
        handler = function ()
            gain( ( buff.shadow_blades.up and 3 or 2 ) + ( buff.the_rotten.up and 4 or 0 ) + ( buff.premeditation.up and buff.slice_and_dice.up and 2 or 0 ), "combo_points" )
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

        spend = function () return ( talent.tiny_toxic_blade.enabled or legendary.tiny_toxic_blade.enabled ) and 0 or 20 end,
        spendType = "energy",

        talent = "shiv",
        startsCombat = true,

        cp_gain = function () return 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) end,

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

        spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            removeBuff( "honed_blades" )
            removeBuff( "symbols_of_death_crit" )

            if buff.silent_storm.up then
                applyDebuff( "target", "find_weakness" )
                active_dot.find_weakness = active_enemies
                removeBuff( "silent_storm" )
            end

            gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
        end,
    },

    -- Talent: Focus intently, then release a Shuriken Storm every sec for the next 4 sec.
    shuriken_tornado = {
        id = 277925,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "physical",

        spend = function () return 60 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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

        handler = function ()
            gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
            removeBuff( "symbols_of_death_crit" )
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


spec:RegisterPack( "Subtlety", 20230405, [[Hekili:n3ZAVTTXY(BXOaksX2Q6PtsHLbsRr6T502tqvA73mnL4klEcfPkjLDCHH(TFNz3Ll33KY2jT4c0BSi5UZm78(XEUA4vF8Q5rHLKR(1rdgnEWKbt7pC80bdgD18Y73sUA(2WLFk8g4FKgUb(VZ3TOmHuEp(G7tYcJWfOiBx(s4HxnFXU4KYFk9Qfww1jVzYRG3Dlzj8ZNn8Q5RJJIiS3LuS8Q547E6GXNo8nF3(R3F9Wb9h0)v7VE3wCP6V)97FF1Bm61034)UTmEt8Ft2Fnz1Q4LXK0L3l9EtoDWu679lz3cVZ2CYYSnlcl3F9BtEXnKY1H57V(d7(7)obE63N959xVGSklh(J5LKWKY19VAEsCrzbfhz)ebr4FLs2iPHlsG)(7VAE4YY4Su4LwhgLDxrzE8NimSkpEl7rZR((9x)BzLH4pIG2pTsSBF7THPXfR3FDicc72Ec8FkqGrAr3FDzgcMPKvXaESkpBd8tRrSlSOigrZfzP7kGfjf2P3fJ)3)Ke(PusrbSGKBjW2gdB6De(gH0JnHaY)dFy)1D3LMaVjUZXP3auUqaVbQ0BlkW1pT3vZbuc(P4WRM3f2SDRw1NtA6VB7(RF4b(pYqg6V1B)1DGLE)1WzFssqzyoq8l6xSEhIsPbfLz5aAC((RNWwGBdH1hOT93MhNbB39b5cswVRkb2hn6F2wG2tkRpiQwb8FLSJGmMamffMwqc2eUmCrobaBG1MUTtRaqK)ilyBwCkaFreKNcOoZ2F9igG585JLWs6wbmBBirXmOwqza2ucaH3scKxjkm8Q2tNG971S1RmmHKw2pboRGJK0BcymG95KgKAPYf(hC6cJp6htYaWijmc(7Vfeba6bquwamhRr2eKCdNiz5ukefIb(moiFxC5AQmfIM8Zgkph7BP8KYFcW1bFvAwj(AXBcHNUgrWi6Hvat7YncaciqPa5dbA48ES25DnpOGvX2NsPNmw0yKqXOG0td4bhT)6ic9PRaXKG74sj9bukmoTG(oCcC8MT5GoKOa1ZIA6SoZb7uAy1(aYXrbGQLakhi9x9FgZy5Qbavo3kkHKEh5phPytEcuSUwHzef9d0hXG6E1Wv9wGW00Nam5JouFmBxaxqmBwUAunSVGlnGq(znd5UeTVaw1LBby6ZbW2NgHwsYJxwIgre71YqaUy)raAXHz3HluaCNGMuemELgyOiA)UyM1dsyEsmQZMjHoNJLOeFEkODanT033wlbF14jtkQIIXxQkjj7Qf50tRyYR9HjVnPaGYIWvC1uR4ygAPAYXmdvmKJ8zaYtUNQMQ6yf4FNd7g86a1pBxzrmQERYgvVdgZ9Z0GhVWMFQGdTa2NGvOdlYCNTInzIdI1BAZXosCsYUdp410uJw7VpBh3CpdmrWkg4jUCo4uW85mL8Zbqh8za9B7qjsU5aaDGhtvP4M(izjlIq2sYbIBEyj415gRVubzzoP02l1ZbfC4ahoSjPGsLS(7Okpz7Jibs3a5YKScop664YsQhtuxP(WFGCC4BBidbOhOufW)OGBjGzMkTuidW02OLcC2GIs6(G(LyFSQmCOU3xsYkvo5cNrBlIlA3(mXHd04E52YVYYYWRXuEnk6dab60yjjTsjfZQMhNZSSGVQYaUFps9yhEOUH42eQGHd)5Kv5eukx1HEUhx4Bqsl2HI3OB9ldrEZW8CqXi41cW4cEBTAxckC)NOCp(buh0sjFgetNNDjtlX2mWhFelLPZ(9rIlIZ8)jlbG70(f3dkdskcYwfercbLU1Vn8YVMstByvBXQrPUuxkStsRP5LW)hGgRc3LuAl6nfI)Vr4mXQKeG)jfOA3UljLKZ8GgccBtmPGPiLfzPmRaBvSfTIY(9tGY488DBlz(BxH2Stvq5B2DaNz8MnuLlX4lZ2bHl4qySsb(8P4LFYMhZTmcPIK4LKaGRkic(h2fnSAdu1fhDvPCM0ica(aMqOkqboW8AegXNqAmTutrPal5Iq6xIKLQTwoyHcakvIsqxuZloxTkXfbOuqaGa04serLulbWn7qwUodJXkNakb2a0OA)WvW3Fynbv0IiCbHWyJKK2OHzhxfIegqoE0VIkKoF9hXyQYw2JfU0BvGi(bLQJdIWmONFgWyWiXHOX3nY33n293n233nX93nX33nf(oBbj0mJRDxQ09PC5YSDPc2lKoNtyljCseJ(lUauxgFtAwovude8ofpQKzkqR7LlxxjZtpah0FAbl3seWKc(LHOwdWWtzm6oL4ivMPZbiBjsJMrFvKU9CT0ddNUJQF850l)lerQceriWaie5YGTj7k6pHQhhOpggrDkZ1gkK3GG4YE)WLfmpIxfNxu2Y4Swgvyl0eHcDfvJ6SxB3IHHmhFhUv5lz)tPywqfbijJ85TX5eUcCbJet7Wp(dxY81uKTeqSO1rJCUQIyP8FOQxx2q7nlJ6tDATdsUUbo9epfoBpZ4OVkwLMcm532LY86aOlfaMYKBeUEynFODrzWOmQyur2jmYfiXUe)0TGLcMvWvusZA2FGN03ggNGqrpPaBZ3L2IaxQ9yfynuyhQt4RTaiAwUC0uQ3OCXWBJVjlVw07LGuZa5NVHMOv0jhUxmEEx2BeSkB5oTxtzldtcr88EBRe(MVSf5AKhEREAeLnPVQYEo3NfAoRf(qrLer(zSYarK8cfl4S3kOCn6Dl4hG1aBufWbpFGa6ZfzOouWkHBwfGG62z8hmRSGtB3Cp(hvB0HgGlBfudTvOpZepSWifW1Vye(KZW5bPY4n72WOFsXAk(D18Rs57yVCLwNWBqb5s58Jah66jf5WZjsRsNHQMi3PpVolb2ICJwqHSIcB6NQZXARaOXT1z2UnNtNETFBDLwhJyBntarOqU55GX(zHBMcpEJSnmhcafDfiphiEAO1pNDhbziRIJM5jvigBAwLFYV9d)mwJRLHuvji8r)Nfu6byG0hMGe8Hm1G8hLtUHKAgSihk3UlPqlyXFD4zYVycYZve8)2fDZgk(O(UVs(DxeEdQchfzWu)OfcQOaKIGqfad6(aY0uG)LYgORTGDkeMWQFja)y5ldwK9zPvZYdRcjup8u1nZ1r6MW8pvvnamgCjCjOGGbHbylqFT4)Ul3NQpc5j3Gz8026YOECbhlXV3STyUCSAEFK9dUr3QMAvpnypdlI7FUogtia3I0hK3LtqVtYIJqE4cwgcnDsKjAZs7d8BHP4pIo2uKLXTQUGWQidwd3pVKSTksM)Z9aQMkBuLHKbgrh)iRzk3zJieOKsLM7YTiPP9O9nu3MEpImZ5PStsEwWsrCllIOAc(mjFTJf5SQ4CCs3AYvCnZBDej(JDS4quYICRfl1oXR6eTjdXSqYkcwXt3egklM9U(VAARqLgtFx1jV9ThmZfDV0g5Cro1g5wjFJ9vljPjX7WZ4a3pfWOiODfuKwD(2ynDhk1GeoeSA7AeLv2htB4oqEQem3qvT0imCHnzLpfVnGVu2sbrDavSxrvr4)Hq2IbPcHXXEEDCU0qZwaEBYtIngqi8xkzxURAMbKHLw0liSepqX1(v5FikMqzlmJIvwyYsIe8JN)wvk4fOjwO175QHbZbHjXyBrzxRIkEvXwVI)vvpPUEQ2LjK4QhDOYUcxLBddwh5k2fbg)da123zVIDo0S7lvklbOoyrswMEQtNFF6simo4X7V(7XNlQInvF((R)iz5604)ANWOzv(5TQZt3kGgnJ90YQLKP0XwEnA7s3v2KxnsQ3Mi89x6fK5v9Oo7u9(RqhfSMQcd(6L3Ve1BX4a0ISZltBdfcRrMRlMv3wlMYS8iVgrZmHAyu9mngQW38l7skJbnImhSer6ILgb5GWOlsOnhhvyLgKr0UCoyJXDWfQprQuBWlqxTTGTcYM4L9TMCIhPsJkvKmyJLqW6TCoZCxFWxWSkSqax4NsRyhdh5wk1sJ40I(T(u9anBFm2zMAssUl4NOAZTqlDlwVJrpXTLefxoZ1itQUdRwAvlNMRBuv6H0dxlsa3Nbo(7GO9Rtpq1tj3gxSKKt7ndTWkX8k9OIkYTt3Tb3gQ7JVuIBuu41GobyLmYXhVKGYEPWwz)H0OWe0Gx4oALj7puHFECFiyqGnbypxfCZYiLo5sEdTLrhEWDWNEk8P7fDCmv2LwTc5w2AoJgXAZ3pw1)wGUrwjO67pSMVSiQMmQgY2935nsCycxdfUVIK6GTPqzw2NQJ69Dy2S7v1YZSf)zLo5k3gSgv2OpzzPHLxTq5(XG5qYLmTd)ctAMLX1WOW)AhiH6S3FShVCvbvn7F0rMbjz6ZsL(t8aBGUmPX7R6GMRK140bnfxZq1PwAmyQFz0sxTnj8EMbnD330KvBeAnip02yYx0kRscVb07eYrilEWzjsyJDWTZkOvqlUszjUcfc4hGtsoBLGpf0)Ek1IEvhBEPWSUeXecFkLrmFhyBhTqHM61CFtuHin5AzcPe92sHKQPGy92caFoyd3Hh3513nB69KrwU)lmCd1eSo8wIwcTf9hctMwu7pKerJOC(7yL64)TdvfCd(DHjj33)akwQiwNQnfpYpJ5BJx2exUP4n8nEuz8uuBgVGmdR(5LyfvEjL5Tq(jb0FPDzpJZM3ZRkixEk02GL8kQPL8EVXhm8m5GFWwm0BipnyK63vT1KwtOHZMWvLu(pUTM0lrJtCJAIHN5gwTQlP6)2kXMtZUl(pOYUmgCftD9TsP09YPjEX2Xb112jBR8FRNwmRkBHSV7dh47nT0N41CEEJRYSYdGEasa4mY8HO7j(ILnpmokG2Gv9dJIkKsYMn2RZDXvYPskDkqdmXQL(uV654mFHa0EPj9QinEBLoWSuHBgj8YL9XpEjeniLFLP2mIzyDfF(SGyetznzIaoqLJuMVI6oTqO9mm9E817Bnwk30Ed0a7jsgQWIKLsjT0wlJhuunoB)YQlzYASQ6AcsEobXv9cMFoySJApToK(wF4uhO1ZNgm)z4Gh7CxwgCz6WQtGRAF0YEOIp5V20dp6lPlX6RK5JgyeVcTj3z6sBrTeoeQX4k01xq5nBMcH7jkjEK6zsk2YDbltcZvA0f1zXZiiW2vBkPGV17HokHYzLo97o0FYCY7DNiAKjPGKIaz)kbfHTeUBHOpt0r3PvNi2RBIvfXkHA8uQe3f8MfQSQg6wzJAQIpw112StmJ1CU1M1qphsLv1Y)WZNGhrTxR03w7wal3QD3yDc(KYBacl6oBBJ(5mnzk0dxvRQROfjuDaBWaBonyOJRfSdZQgmwf1AYGITsvqxF16mQt175QoAkuGjnrbAf4Zvw4An8D63Lw5Px6h3v00i9CkxGBNRPWdne9eicO(0MzUbv)1jiWRYbn1MmtdsD1TQ0l)Xk4nAJRNCGK0))yc70DuxpzvMGKCcsbKny1UCAnAg1W8p5FPi5fKC0KlDPCNhXMxki(acltj4k1uY48TsidmotBjbyRBrxo32ITQKKP(2MBVCMyYFTlE7wC8SqwCaca6qWImTPycSWfVm4M8yYk41wU2ijGiO5Y6h(QaqUrVb8VKn)nOlRjjlOz(IMfKDf4sGvdb(MVRYhxMfV6SaU)6lP0R2qrBuka4cPjoxUXmFujqV9LFf1LmGQtZOnEzFKWGGA9qfD2A9uYS)6)psYw0P))qcEefZFDKA70E4T9tTYoJgXSrZ)dTKYEfWXTas3w4twlGHzsxgdkL9sMW4ZNvksOLCylPp2vw9yb5VHGBYX65o2i)bsThXYWTS4I4LiGZgbH99FttePcuFaaD3JfoYqiWus6NsLjijRau6ZGkNGWn40XC18jd8K)p3ZVVCc0MWCFWURfpLJfJXefjY2sbCZS4wYgIEIU)W(6MQTGF2sWXVJLdw1E1tOCJo0xaVj8pJypIPkBalE8HQzlxxWTPrDPvd0MXc16eIEHuNpZQcFJPtUxZnPtR8ZAITmZjgIa5zeKsoxd8Vok8GOMdfIQdvwfivwU6cWGiCH2rjuw4o0AtDBPb)l8PYS21p6TLaIhj0uTit9e31lvjsRIum0wgETgZIM1EgZVwdnWhoHfzS09ZLU07hmfDdQsQD0Y4PntOEI(vj6aSvtWEd80gYFQolUMgREkjLWja1Ik4HmyVPchBoBiJv2y3nyR1ke4P2bGRffX0ikKiwN1wBVt0Ww3hb8WeOVVE(VvhiiNz33n)33VlVYsAHWuklHlAvsgmeIk2JkK6SM7YsFr5EApxl3EnXBioY(Ingvt)oBbvrl3EU4MECn)55IZhF07YQz8W79CM8kBq7RM0lhQ4ePqq5IbP(Q4Wus24cUYgZjlTv6x7f00f8ODeMdBEgIw(jw3MhV1krBJbLD8EXGYsLOTpiTdRewQC26CwXk118tj)ah7g2fZfb9DSYVtTXqxFeZ5LTc9oLlcqDkvut2Wywd2rDgkUuzA8PyAWAAOj(D0xqNu(eXXG6DgvlYgT9Lr6glHYtFlQwdEa7gjC8OxF187cZXkQdmQFePlXB2MHoUrXUxiIU(fOsaiU5CK(uKrVzH2vMTjKEj6auUuQx6V)NPZb5OVddwlf2n6JFbNbsNb(fmxfD94k2l416o8Z9eR(y7RUIYFTL2QHb91D6xO1912xxH)lARPHFn6R3B(6SE63cr6OUJlPOwU66xFrgaT9B3O6vF)7TWVYVFtomU1Z0HWAvp9N0hv(iaodLs6y7qhS(pIdhRiiB(Vom8Zbi9K5RFLR1L3P8gRPwh03617jcNo4aRBVlTf1SN1B7P8tauTEAVmQ4WoQhAhUQtILgqz2Td6O6eVIVch4Tl(A0dBTuL7Z0QpCG9Lx2tFTL2w0pTDzFcu5HoSPXQRTb6lxSBJLYXjMzLI1ww3LsUTBXZn7VuQPFwedKJKqNMAjidD0(lLFhFT8p4PH9Fvx1Nmn1Lm6JgCTYGsdr8zH1S2FFnOYmGqDu1WwKK7lJ97(Y4dzTAVRq7F)prjt4s8kGASKLdu6Tio8yC6SZwfxpmVf9fd8(XZ(w5RbG9V32BuvDTtWGUMzzq)T)zvjc06d1BZRtmMb)zdN6yDvgMwBF4jXRMjn3wif6B2F9t7s2talYygSQplxLEYloEz6rx5NZRWo5nOkgw2XPst8CcnjeZyjYu)w57Hh8LPNlMP0)Hic8f6oPZnU4ihii7ax82zov4yUCc1MnSdLqy)6T7HhuE3rUE3XMV7yxV7eZ3DIR3fV66Ou5)5VK5CFGy)gQHtRDC91COlwloC7y)tVq(p6yRamxmQJPk5ZbctNJAkXBwyOKfkuVS4KrA9RqhgYd(KXoT)sENVPOJtvllqL9j9FUSWFhB6p4jp9C(n)whLmvFXzkK)lMnHPX(FKBZnzQG295gxLz1(Ec7EQIzWrTZyE)38nv1qN5scivkGXQ)Ncdwh6BP8LfKY(SLWLWGXhX53mxmDtjh4vNMhlh6xztCqy00J5cKk3)CVC0GQF359oN07yBmHEz9sRFpZHF5OPVSRFtut6XKbFEUp3AwQvkIkfEf1(u48z1f1rNMsH3)rUF2Ag7yjhtbXeiIdnUkojOAQRMAm8yZwb6HhWERsvRb8MDACdh3KBlDNCQEKE9AEzNujxT)rCFP1mPLUGpcoLNJB6mzOt9AvZeGUa8s)y578mlFm92ot(31UCZKFKYDzg3V9VxxtuFk1bTrPCuAyJ6IzJoURrCDD8wCVlMDgWQ5OOE9QHNVo16YeLvvblxfkU23JAYzOhE4OUn58sNUMr1IU98WdwChAyVome48Zg0ZeIRP8kkiKbDZpQQqAE(eUM8QOGelbOR1GoPpHBv0kRdDqhF6lMneOFg5zSbDmdRvw88ok(6yTCovorQ)zzkNpYwFTZDwtVzRC(aHU3X9NsrR)Dn09gueTUEWKQ8uX)NLP23K9LAATc8ImNH)lgR4Y85qeODBSFFaZHdQ5F1FRkNJEEM2EDuQUmpuErhWGwCat1xf5cgCIYCyQ5aIsEn0x1oMdk3fdhqr)NNzLxhSvAR1tQ6swgilC41E)o25ipEexRy5R2SUBQZrfUBmurWRngqa2Ah0X5bMR2wcKm92c8GljD6wrZSvFPoh5AEH5w(Tnv7n5f50EgIJ2TUyq(OvxQLSUsUDzJfE2WZQzi(NAeZBudSmQQBy2f7G1duuHNmj3QP5Eyug2oURujoCGR3GYPPO3GPH8FrJsToX2iT68bxF2W(tTPU0CSDax)mySo3gpiqSvs5Hdgv5a(QjFFbgH7gjfwq340lgp4uxJ0DlWihoGXMpTdwOEKDH6bD6Ao22smTQJS95ZETSjE8r9Sh98Ob6GVrqdhmkmUtDWfg5IYVs0ZNnbIVGb3MfhVxNU2CFTgvv8rIXP9uN652yQZb1X1CIz60MDZenyVzsV2aBEg65oAcV(TUnUJpdQEJcXDChw4iFTi7FgtTS(Min0QQOQJ2CMIe88kjppTD6AKrJbduTSijG2KBaJLn34FMJHvR)RM2XgTPh3reTJnoEmXoE0aGbck2(kBNcDp7L(Wbdwp2O2kcwrB(GTQ7bddXPiIIGUysGLv4P8O6SboWa0QhF36q9Sm8M6FLysDpKVsmuUhYhPo)ThYxQpWSwI3xveV7rMw7bUcNJNlth6ZZi0Qd8Ib21hgBLZbnAjLu8)TCz4xJGSSIBKckBxf680qX15z9)HcWRy95tBCB1VYGvQWVMg5UoZ1av9Hv7Spo7xhnBuplGUznhpsYzct6NFIZzD8LWl7vNuHxRJspK0cO1pW22b3(8H12fSdLnAStovqMM(TlVX)0tDA5bGlRNAAmCs30VYmBhG1kmqo7mOn9vwgrPgSloIPL7rCHYBHsuH2aRq3AoxzkYdp4274Ew8()06cKRWmsBNP2C3W7hkTdKmgel3t8oyHf8hJApp(SHnWc0PRqFdVp2fbhyXt)h)D4UfcKAMkRjrAQs74lDRyigwuzO9I(xFrspQbijNGmVj3VWPO7PC28Vkxz5Ey5SKbchSGh5woPjjARbr3D0lLDPVx7fN(kCRP)OesBTXGJhoWt6ufEpBlP4c1pn(9hBZve5BxCDR5EpuzoCOEROBnsj)krqwbtngwa06l6CUZLT7oqPELKA0dtlIYZUTOTWANEYlMHxGlhBPLPB3ERpQTkf(uRblAQeMU2VQkv11QhInhXSKSUcPYEgMgQxLM)LC3N4I(4SYpY3bkZMmGLEs5RjfxRyHaHXVPQuktg0XmrghgPL1tlFvUesAh3R(iUBPNkbhjQl5Xx57UJNnKqQ1NAQ6zx0DYPJEzdLmSNp3mBW85e)KZwDtE8KimnscS2XwSCvWy8A3faIFXR6Sx2vresgGRDqt(B8hEf6js)rN6jBQYhEkcT9eoaRSDnw0)ZN9g)roDoAT1QV1wkiQJYKQDbEqBJQgy0A2PKlgoqQv80TLXBgRVq35gTL9Wn3HAERAezLkAJ8X7Hgs75aH1djt27g1gNMvyo(J4M1LRWjRDDuSUYslwkO8QSQpcOe7THqSvO02IS0Df8eTPAi9e2eFu3l0HvTgd9)zbNoBivgV5z17x41k9Tff46N2Z4iIejoGyGiv(LjpYEJAUxgcIjBVbHJjEJzN3cqC)bPuKFu0WB7V(BbouERSvzVHRQe1jzPZAOgB4jtJFWWAzqw)AJuxvnVI23N2DCvIar2PnQkGR7mp75h0sMapFQ9sJGvgX6VpUQUDMji0ER1E(RA6abRVjxsrVloDYsiVaksT2ObCn4X4wW(emsJJIiv5fjk4ooBSiHBCakEZ2CWotuG6ww37LA(U0rpiNNu8mY4SJ2U0k(2vdkoKK3kVNw7AtR7On8OJtMoaX9ZrmYo88LPT1vAjFmjbXK86wdZWhsL6i)OGoEGVA(6Pvl5AFihrbW3MuGEKhUIRvAL0meunNqmyM8zaiWaEQDGdIbQ78q6O1wqdVrz0a6744V1iudogy4DxBBhF55Ka78MCd9RO1M7Z2Xn3W2h0miA2)Y5GrP5ZzQMNtWrC7D0mc8KWvh(5lAmDbsw7cM2n9sTBFAxsl9QDvx2Mdc(6gDKguK1X80)rn0(H)WSfuDRgHPjxVX451iAQFH0XnRZ4lWYR7nqDjrzTgJ)fDsBTNON9kltWslRu2fZELVKFYt3THByICoQNVcQ3d4BqslOP1eD2Aj2TzldZZbPEWCvoD0pWbTd(()eLgeZyhlhLuNLLhAAhQ00P2(mzs7xVg9k(8HVUJ3vPXvOzi9Q5H7kxNLF185XB(b6n31v))]] )