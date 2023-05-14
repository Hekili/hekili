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


spec:RegisterPack( "Subtlety", 20230514, [[Hekili:n31(VTnYX))wmoafPeBD6LDYvyzGCji97L2Rn4uAVFZ00su2SHIuLKkjUWq)T)DM9f3hZUKYoo3HcCn2C5YzNDE8zESRVC8LF8YfRIRtU8Fmz0KPJoD8SHJhF6RM(YlxuF32KlxSnE5NIVb(h5XBG)7IDxxNLuFh(G7YkIxHtqvXUYLWdVCX17sZQ)L8lVMAwpB6uySBtwc)6ZgF5IBtxTkHp2KQLxUah7jJo9KXZ(l7VA)v)wsw8x3FvvDsCw9TrlxvT)Q4L1Pf57VklTQE)vLj)3DPLjBsYRRgU)97FVAgMWMHXJgoE)v72IKI(aMEY4FsoGrdFPCigJyYRyJ4FUToDt6)lz)vjRxNUmnjF5DAJBg81yJ7xl(mmMTLjll2CDmqBVo7z3KuFBC5(R(WU)3)ldE6pxalNRtwxuc)Wc(YA4LlW1sfJnY)vjip9FW2zsYJVod(5F(YflltRtktJVCrFys2TE9qXWhUB7(RU)EXV8ZX5Pv8F3G9x1B)vWObwEwwuDCjqqvdRUDxz6NsYJQQlk3S)QZ3F1m(e85yy(HV3WTLPfWN7UOYI6yodFWLl48EGmVnEvXxQQXzHV1vMUL)OfYvaS7PE19x9lRvR3FKtGWojYe2T9y4)uHSdTjD)v1fiJkpzDkWjxxwaKjmRa)nUQkfz0xxKVdfhYHV07sX)7VNe)P8KQkyct(Cc8ztHp6xseFiChzdkn9MpaSKD5zWiXVCA(nWExmWkH9PxxvHZF(GlRbjul(FXwyLNu3WgKCl8FLTlbL9b()Q48QKOnXlJVUmb2IaThgl(u5MbkFueTTifLzxLGYuaTnF)vt4BcEF(uTDu2NAlk5VkLZMvsbGyAcqHFojsFMy0Wl7Umb89EfF(QJZa1RHzaNce)YVjIV9puWAysgaRiIBE4MSc4RMfVc)85aXXyvgYi)BbFJVl)xvVW(R(rqfb4xat7AyR7wCteLFaPZIsghKTIaPaXs6lP13Y05q2GqyJjrWFxMeJ(RaYeWBLxuJdlDtm80BrgWkC)EQx9nLAb1IJXp5QJPiJIZbz7gWdoA)vRsypDniKg9fHm6qGKJtZRyJrWGt3STeSHSkYCVOHpBlCW3Lgl)oGw0QiW0setcK9BdVhZf5AiatjxjNqtRx)1ro2ShbhRpjnJlXWe9rCQEGp2XKM9dy7hTFvNKl3nAxMFAZ6TH0X16PpI1Ai(Bd5sB4qTKAN2N0q7xl0Iqk)S2PCFMmUaM1LBbA6RrWNpFf6HQmDzn6Cs9Twgd0f)hIqpzC)zcZbGupyShjJxArggMeExk3NqsCzwkAjMRzVqSkrlfL5Gvh0HXWqFAn6RzDY1oLCmXujLjOn3k4NKRKxfAL86SkGkRIxlmVTwSYq)pZEb39dFXL8vGYZUJzEtUTc6flGVgmCG7xSRUkfnlk9Zp4Gx5HfAWTx4JFIscTc(orRrGq6sNDsmzMhM1p1LTDK5Kv8fCJ3Ycp6d)UIDcN4CYejRuqM4Tlax9lwWDoSaiDajac58qzs(LaaBRVGzQYp)rZd5QKKTjLaZTmUgamVHCqvjlltQPg0apCWXJ8QaZrbKucwqbIAv0NtaFksth4UYPDX0HpREM7v)l0(SUZAKRB7TEzwrLqW)206Ag4kgQRp8VrXyC0SLKFSTpbljDJHJTr1PPRiHUc7rBRsR623zMhyX43YpIcJPLVUMYK1844I7TmaOpIj8LsGbDgvVT)9X(DWhguJq3H7HUid4k5dRUd0YYQIkwhTkjgSM1mAyWVIrSTmRDy26wqkoHAuMSUmbTezgkHanjoIK8QDOjimGILXOOECzjy8gqSb6basY17Yqdq)oABcFbg4Z8KVcMswu8wULSTfq0f4obJ7YGuqtUn88A4)bu)64Dz1urfASW(TeHqS5NdKFYbk6Z7YYtk5iVHqR2KMuXnKYJyvxuGplurbz89(fWyCz5UT1CC6YDhohdm(w8fqYmDZgMDGuCW8VGc6oeESwavFkD5NOqI3XiVQYsxMeb7yrRG)bTQbPpqtionXYubtLVGyaZHcjJvjW6cwIjmJGW2EzdNaxOXSqyz(OYb5GRJzVjYVK0efw6GRzjbMwfHsyrWcGfpJmAgjBX0nTkybg3kz5Tfy0CLjGzHnixBIIL58Etc9Et9)Etd9EZ8)EZc9ENcVN1UXBUnb9pGBhvjjCPFnfqwm)PYicXSdGsSRz6TlU9JyiKflhWJo81gmYglEc)3oKJkqjIGeAxWLgsL(ESVryI6C5YID5k5mCjvMitvwDkIO8AWyv6n5fLmLrq18eKROl2GUQRxER0QaJxnA4Pv8SALaoDW3mgTRaUMQtraxkUhvKgTV8p0fD33oycqEbSAlY5noGluXidmri0bi486OTz7QgoJ5qc4poUz9PvseeKFKQuI3V5TvCSYRtlTIZA5QkQqt6AKaNBAeulNgM2u19fFZYvdzy76He0naFr9uGRDMdtvfNGYlJXCBlrVDlgB0cCmc3WVL)p1cKcvZXDPKVUnTmr4vrj7Y19)RV5TCSQQu)awpAlWKFBxo3JoqcvWKY1kuU1jZYzFudBvbtjPQ4yoLb6JlXxDl4qG7fCnJkUL)d4(5NJtZqQyGwGTL7Y7qGlniwbXhdXHMejtfar76LtoLHgvOK950BkkBuSEoOtms)5ByPpfXIjqXeyS8reTUy5oRHz8jJZIX15DuZeoYN3HCykcV1i9KYAjuFlI3dCshWT(APpDbGgwAQvaSykJOCfwXJvjL0b2yQgdiFGa6lv5DowjkHZN8BHwU5YhC3vaOTBUd)bfj73SrJWb)1mJNvzIIGn4k9ejmQ4eZK3y4bZbPB2THZx0Ifu97ntgltyJpyPwD8nOfKA9KIa702zc5WtesNYHHPjq)5IVj1auHRXQetrvfLHXMe22jcAAxrW2V9e5mO7FwF5YXjGw3eeeR0h(tJ0mJEAjCw7Ph5cJ5gKepQm5MK8gAnUeccebeuwc8BloXFV4ljOmSmEBoEQym(WcjW0x)H)owHRLXmRk43K9pRySqWNLBeIIp52Dzvwri(pgFM(aZqzUQO)ZUv3SHrCMJ9L6J964Bq72OkZNQCI7uvntvKNkIbDpJcnv4pz8bSTwW3fIZ4fdfOFSwOrxx8vTzJ4HY4aTJj18JzVLkh9M4YpjlTaMFaT1suvcguhSAb(lbO9gPcrwb4Eg9HAHAE5CpHIdrq7T7awOhBMShDOTTIN7uD3E85jkuaTC74GFmSET)(TPywceUP(GovCmczPiDfkWwXZWNlinUQppplWVloh)LiANQIcH30Rt4L)blx7xxMSvg8YF7oGvKtji1oxtKOFgcJv4hvl)z(RXIML2J23sXAg8ashN3AyzamHNx4MDhI8G0izAMvp392UjICMm0fV8T2IbWY9wpvM0cQZqO3s4P276QjjG6umpkRQO1ICmHrNIzwC4lpTtlLwtTOCNN(ZdU5wDN2hY7KCcf72ixOdNyMxwhM3HNMbbofWPiyDfmK2TcI2Kf3qkwDDowvupeZv4oqFQgC3WmD0knCbLUYNs3gjMkQ8oSuVtz0vv0FXo0Xl8a)ze2qz8)Rsty7HUX6sk5lPstBT)TKKTyCOq4JsIrgkllKWRbaVCRKLyGOWpnKk7b02dmxKsbsWzuCgB9j2cuL)KwAwtECYHQ1Pa52frJE6fyBf42ocm4(f6cS5XMCBS7FtMDFf3gRZ8DchoVtWzcN)Kg2RLHAlMd)P1jlVnp9)UtyxqdJlmUORZkkSd8CXD5lHGaHhV)QFgFUQg4SzC)vFuoLsVRYS7tLmJUs391D51qB29CIyXPnaDX)aMZorQ8QmMzXFiZpHZU5Y7wI2T4YrSi7m4D)6US6uW8chnIkSrS4cixeXDNXAAm2(nd(9QDLcTCerUqU4yTcbbdGnBBbdVjBsxoSZQBTuXTwvlUyEtF54A6reT3ewkqmdDBGJziQms0XvXb6A8fyRuAPk4VGFQY42bJRDy(EbdT7d0gG0WlxoHNjXMT)f8p6qaeBHuIsjJGVkR2EC5nbeaR8pEkV(obk88bkWydyLOVV86UUvdYhsdHDDgaFgK((ceTFt6bKpn5ZPvltkznKHvyLyELEqrf5h0DxwBJTX4RL4gddETOFcZKoAe(m4nUQ3ilfivingcbTGc3t)lr)qdDTPdb1dqmbuDwhDZYvUwqz5UreMgmOtGbTx1OYmHzwjh07iRfCUbV3C)OS9Sals86hPLmB9Lu4WAE6xO9)xIo)notOUIZUkpmy19Rlk(utSRVdtu9azpkZTg8uWJSmUfogPaXYkR5QVoJSFyWks7UiZCKT(IZ4PGGXBVBNw(LNKyr5j1B)cokN3YTD9R8vdpFWXRI)V7a7h6DoK)K10fY0HVWAOOoGoZaxgAuMOxKzGYyfyABw8DCVh2y3chTsJ3yIyEDiB)qeqFXnlQ1zX3a2ZIflrBOueXvGotqNxUQpFaeDe7IkXzWy8jmVGYE28TkxHA8eiqMCop5DdjQJRJET(EM2wlr1JAwPyr2IaxZ8dJsq48T3nT8qtKPRg54NXb4eCxYhwLGrBjcIsK2zxG567G2mg1mAmiJteI(tIy)MULMkHu2GG2t85sw38V5wlLRhDHjbMkUSdAq(24pNyv9avJ2WnTQQUkkcYIDEX741v6)SdTiFd(EXzz3nSRblfub0QobbXQp(m9GFW(kKmKhJuw0sgKoFU0i)rTKnkH5Bauve78YaKxs50rrt2U0PGq2WyAtwVBsO9PKC6eqSbwbFA8j0dqy8OqJKOlVBKSd4)LqiTX7FEZxdwIXRRzIIcV)5VfHliGzOo)r3WBmGAMhJTAs8SSMJ)dMzsUSUb4JHKHX5VqhGMqseG9zXyenKz)6HT80k2XOtD4RQYt3kvVkYvoKZe1W6JF8TqWpS1pxJCf312AXrMccjkN3mgkLcuVJTyQAAtcLIzC(D4Wn8bugNUkI1vwdrQtl3IuAvN7tzukTR3veTO7AwX3b0Uhde6MnLJX(Dbh6eggR1tBs6qNjQqB0oBTytEY3E5bZYyxeTeZ0rvYtD3VU(TC5zEfRD3MQd2hZpidMHtUHinc95jmMBYSjFXMTum)HgggFLlOv2GSTReQc9tg5e8cRN35MU7qPloeUXu5YnuoaA3zns3ZmYwkdiuo20ErlZIlnAMgZZrOtmNDRuyAX6B3fEmgvhoYuUmkAFFKwXncQ5XupUlK9juhHS87CGUV7yv7CPfp5kWiQu7szKxangX1GhGPAzj7j5oTvGjsBCTdLBQfwAkF2byb1Ywh4WtFravTxz0By7UgMU17UH80hAMeHX(X23VtjnuljA(L5gyGXLOaA9vniIjMWrJOG)4yhSdYMZLh8xdtF6KcvnyyZVzPpT3zg4R0EgSOzTXb6e5lmO4Boiem6ZkR2ZdVKnuA1EotaXpmFgzWcZpdcpyiRtPBXRqt6qcAGYYIk3RHwBUBQylESX6gD)nqpKw2)pM6WwogyeKKEQAHfB06DLSQCnPLJFv4PkPSkPe9gZMk)yJAFQaeZj8STGZuBPfm0mHYT4rQllcBIm205RZGUg2TlqZAryuhxNCxbIYYoPHgw2CT2Q6Ne(r(Bv8n3aSfkFNMdW1b8rUWe1Mf86Ty7w8iPHQtWYgMeiuojKGgbkRhBeG0eUiLOB4Ow(i)Y2BDdUZ80Lr3uMMSg(ilV9HWR(EViDOzCb63HRlz3ITaDaIi3aMOn2hjJ3YpZwyKszzxZsollVz7QqkaR5e8o)fzOvC8bnPxE)vVLjKZlyIEd5(GkCs3lEpAWEeZXHtpBZFjLNzT(X42vEBO6M(BwwheS)Y()sY2IrpkVkiOQns7RQgpkonGBRa(uhprAeLuZBpVjtHOCqn8JGv8OFhaA3H1ZCTBhKJ0tBJ(otOar0Y7yBzCrKjut7C0jachdTVD0BQUZDXTwtJFDQAkqutKoLQAE6u2KGSGxyx)bNm1O19nlJ3YJowuAmb5nC)v)Z8mv(TTpZOEBHhJehaQs5mwts2Ayj9vW7vu8g8uCD5IzJcKuB)HvPNS6zCaO0GtFmYjoh4zKVsvxJ21FjYmOTzf9HyxtMpSVPlYReB1j4HmLxNbro0eBDkZXSZiiOib)Zv8hXn(oIN4QX7nkSdv5r60rZ0L4jw0whPaQKoQoVj6hPugbFli9ysSvQwdswaQkvPiRLHIwuAobCBk4eTl38i21Qnu1PoG3nkTwkhrehhsZoqAQBgvTDEC7kDM3Jejl5y6mE11uKmXHDMloVBNDJWLTOVLMSPEvpRC1t5npqQxmm8JDEe2EQN0IHF7DAl7ldmsuLxcQdfQg1B(j5AS9mKn14d7VhVvb61XQQbGzQszHsQ7LSRUUNzTA9VfiIpKnE7k3qCIAmsAIf8uUTpR(CsCySUUGxXnXeoSLswfw4Zf(ChwPw5W1NeYdRNIpxXZFC8WFExPeBqLcCapNGw9fcWbqFtRQ0AASVuK)S69SZbHENJLUjrG6NFWLcEtas0yytSUZAAUqxCv2DUt3OKF5Pv1(gzHLbjI0fYyXo8PMti5dcLVyPe4WElKx63(XWwASW5aDpDV6aDZSrqFGVhlv)KGToNdh2Ob1zFVOBzb5qXlGT6n8RSUeegPecAT5nwG9TrGOwHiqvHSddFQQM4XP8gGLbekL3Y4DO0nMeRCBW82pRd18GEA0U7DyY0FgnucpqETGo5YfFjUe7meWP5hX1F6MTfi4m2Q4zQ4YFM6Y(eybvfS7iRD1fBIzxhuahkNbm)9)D2H2fV9pFtro81yp(zcbiB59NXHd67XsXlyy9h)1bQzFk9SB4oXAQjD1ypVN(enVVIEEvanSMthai2Z3p99z(SVpTSx6EUUT64SBFrC5q003txnZ((3tiVkUPEomP1ZSPWgtpdNnen(OiohJs2R2XEe9FaBoKlq(HA8WwFEiPhTC9l9nVIdrIZCAD4s6889iPtpsGnDBO1K6Eqm66U8JGuj3TxUQ6W2QhttxnzsZIOC78h7L6SGQVQqcOvFD6b0oAY9B0SpEe90Rh7G1utfpvxN2hbxEShFA8UNWz5R3sfotLNDm3(rWAA93WcD9t8ie)fwQ8nXgLXXEMjRXt7tnG04tj1UL1qfEKanU8Z1AHqEwZhZrU(j5JrAZqRyfFtSDOhaMTGirCH289NkWAEM3hPQ93lOApoE631z9rVt5ZC5dMCjf7zrR)nrGVj0llQYnuEhJmbqsonmsYPhYC1DuP7F)VWyt4u8Y9g)5Baze4vtrX60MJmD1q1fQXlM)J6xZi7Fp1iKLF9ymY75exKi0VMm1UKp0Uvlp25o(y(4t9mVghwFQx8401Z1oJMih6hW)ux8yU5ov0I(kdM1Vj3pN6toEdDYM5VLx)L6Faz6e4BNgTh4XS8bnNNLA7R6Z7Vpuk)UyUrJ(IlGNOBms)RfpPJcfheQ3EtVLyLRNz15J7Xye03IN3FVXyN4BStDh7uFJDM7yN5BS4n0jJl)h)9sP)ne6BalbV2Z1J1HozDyZTh9REH(p0JQOHxmPNRj5ZbgtVJAlhOecu6kfM3ZK6lA7ROl(Ih)dZdB3(P8oB0WgNPvwGlhs7)CDL)Eu2peqApxCLw2ZOKfxCMb7)I5Z4wS)d5kIuNlyDjrkmzk)UhZVh84oCmBVP3)d)GSdg4qsaTsfnk)RMd)KOquI2kimc(u4tzW5LeYBUtMTRKd8kxmGNd7Reobjm50xiuinUulF(KrYFV3lZsTXiGhACmeFEZuBF5vIV5KtFE)WUOMnGRd(T5sISDTwT40qreZof585nf1ZMvYiZ)qU2hBFrXtpPHSVAH4XqRb2atpCnCJXVWTJWU)ESfbnnwaJSxRFWPTHwP)StSdWBq7t7mP60(hW1Wy7Sw2e(aKu(wCBiQtDMx9IUe0fa48xOFRns8YSlrr9FV1DMO(JmUIefW1)zBdqdzCh01KXwPJRPlMp5f9DcNRxWQXEX8ZarnpvHDqd989PQIUlztlV61buy09O2WaD)9h1Vnml967gmlI25(7jqbnEqp(c48ZgnWLIB48ggi0jD3xswkZaVIWaUm4h1uaMyD4t2N3wjVI8um1lK9I5Jb(NGf3yGQfBmJBmw8T9E)WEvRNkLJ1ADCUX5JOoBkcmA29rM3hOS9oD4PSL1FUULpC4iwD9Ilx5XU()MCDB4k(YCTkjVvUx)ixm1aP85qGN9BThUa3HJAKFThLet03MRFd7LutH2yYIEObl4)NApl6519yJdqSfaeJ0zypR9CpqSxmEeB5)T5w3WMSnAS4JLnsnNKv4CPBLZEhfaiCJHLVB3QdU2CmP7wJqeqTXjcWx7OEE3W812AGMzWtybajPx)JcugGEh572lq45N6o8OnuKNoWrDK27Id7JvFVok6Qb7IseE(4ZAei(J6guOvlWWsTFW2FfSTQThzDCjbToWcg1bdrd1UT)EFszKYjODu9Dssp(dWGxOKIKwAhpY3iycWgMJ4gE)t0fgH9EOts6f37fZhp8ukRWUhanarPJ865uI24MREcu8i)Rhhzd77j4szOvwbXYnn)IPJoX3nsrhwrEW1XpdRhSTIj02kg1RV7T(GMqR5n(W5ZFLoYb8rdOdkFYiBY3jwKdEjmTxtmloz2kST5ZNpdcBHt3UD9WGE9Pqf3SunGEXL0ESxjbDXdQhUJVtNRlwqAVpT4gB2GUqBbmn3Zs5nStZP9c5NoyWn(dNHqI8vQCj6CPhy)r0oy7mhvT2(8Smm5BBzGaeG5XWVxFNKOmAKPxhnL32qEmv3vu4RQay2g(Yt7rX3gixeMBPIL4m61rlegOer9wwBo9p75HiFhjs(P0xfAK1vlaPjjmOhVAog6)QlraD7GgpQj3JJCiTMt(FtGLexEb2VL6q(FiVL688FiVK5r3)qEtZs)tDW2jY3GPTaoJ25u8RzQ14rGL5JCXraJ27ryhmZ31oV6IjU7EMlr7J1E7lVNAQ9h0oyLpQZ5UVfEL7QIuDcDWRvxI)S8NXKMLfVWeozbK6pYfImbkKaj)tatqZCNFARFw7ldEJERWY7vFVP7HzoLetYdZx)rZNmGG0DR27rAaVC5FHzoN1luohPRlSHSwpJU3PduByITRxndNpUXpjnv2kUa9SX5ctky8VN41tmqxK7AwcCA3V86cBhG3BmOxAb02ElItjyl4eMWTT9a(70bbNqUSrSBnsU6CK7V3FKediIu6KsvRjyimYAKSU836IWujnrYfqi(7iIhryL8XKUlJpFClIa96RS3iomhQaPiIk6H)hvdcgKzYIByrwMs7fkJ3y4yeMmSgy45xLGOgcsdzO7FJoUWRQ7jcX8Vl)9ZiGihr2A8icEKF9K20Ojt4q)jpxpeNbDxD67WF2iEqkPD2zWlgpkqgTvHuqvxcL5NwF)xqbfr)VBe2EZdUPYbCy(37cYihdBebffCTyqqOn)jSqaUSBxMrnZKwl246ru)krq1qEDZo5fZXROPxq0S6D7BBFA3nQ9SvpUeUkYM9lZ5Ywn1yo6rMAC)uQSmJ9jXw2EUh0SsyWKPZJ3ynurKznF(zA1NuFe3FVDAdMoQjVbM3OrdgyxjV)KCPe5BBWB1b1VPIMpBepxZ6xMr(MXk1cgFhz52MnQNBMNoSDqEFp9D56aQBQx2xdgeTBlG0PPSyFNVJF(MTi0ApU2QW6f9NDYKN3szLhechCl(3NfMD2PRTNhfJPvwazx9XtHcxWRB3flHvVAsfDFdviDcUbbP(7eo(peQ0WjNei146BEgkTdui0n(CT2yiNp)NchA35iCasW)efn3tP0TU4EyTAxlcATJA6IXJCl8Rztr(KD1X0vXd)shMo1ADXQvbo9T3dnM7ZbgBawMo8lZEQNxLvXJeOh0lxnVLUm8UYZBxoy8Qw2RjmM92yi4puBJHvrKjqthPhZpmqnTjFSS9P2e)vXXgs68wK2XFvu47xxvHZF(aNTOKvQniojY0F56J8r0i9kGvG1XjSYXSGjvq0MycaRmoYFv1uK7V6hbjur7ok93imvI2Ki6(kMZgr2(eBm82kL3k)i310YR6KDW6GsPkWkAEJPb4MU3KobMePQ88tPRLfwklYF)uzryDZGjD7xF(lBBdblwTqtXUtF9ksOpbgATu8aHf8u8tWFfg47vjYe3Sk6lcXyvgbfeu6MTLGFMvrMFYM(Z1c7sp7OWEubCPVM90AUKR3(wur7zxUtHR0IphA6MS7GjPAkErpVcUajgMEMqtppnhpcJJ(bMjK0KYMwq0bhQrJf8GOor09w4fTAUGgCOtye4RZQqu9XRfw2wRDwvKhdnonN8vGiWGMAabcXr1Frm7KBxXcrY4iOm0JQANxqTaUWbHyxp2h6NhhSvSkDSrJESURyNWLf)7GUsrOdVDb4yBXcU59fj4jO8DS0E8OwREIvqDaiulYgyCw3PtnqhTUoMg0a3x3Vfs(2oU0oqs3MkYXjZz9h(3UT6SFtrCVb2hadrHWonSsAhSz8em92ikAQIkVxPcpPZ6Qpj7u0rCsP6y5aVy(ldLHxro9DGYPsSQDopyiqWrKKxXYDlcyBj2(HlJllbTEWLxj7igHNJt49)DuBqDeo5jILb4w)m57XKMn3oKBxwdC2kY6Zh)QEbNLwNH2P0lxeVR(2IYlxSiDZBy3rFx())]] )