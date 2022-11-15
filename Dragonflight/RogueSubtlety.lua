-- RogueSubtlety.lua
-- November 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local insert = table.insert

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

    shuriken_tornado = {
        aura = "shuriken_tornado",
        last = function ()
            local app = state.buff.shuriken_tornado.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 0.95 ) * 0.95
        end,

        stop = function( x ) return state.buff.shuriken_tornado.remains == 0 end,

        interval = 0.95,
        value = function () return state.active_enemies + ( state.buff.shadow_blades.up and 1 or 0 ) end,
    },
} )

-- Talents
spec:RegisterTalents( {
    -- Rogue
    acrobatic_strikes          = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by 3 yds.
    alacrity                   = { 90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison            = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.0% for 10 sec.
    blackjack                  = { 90696, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    cheat_death                = { 90747, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows           = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                 = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves            = { 90743, 231719, 1 }, -- Physical damage taken reduced by 3%.
    deadly_precision           = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem           = { 90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand          = { 90639, 385616, 1 }, -- Deal 1,833 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness                = { 90747, 79008 , 1 }, -- Evasion also reduces damage taken by 10%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                    = { 90764, 5277  , 1 }, -- Increases your dodge chance by 100% for 10 sec.
    feint                      = { 90742, 1966  , 1 }, -- Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by 40% for 6 sec.
    find_weakness              = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 15% of that enemy's armor for 10 sec.
    fleet_footed               = { 90762, 378813, 1 }, -- Movement speed increased by 15%.
    gouge                      = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    improved_ambush            = { 90692, 381620, 1 }, -- Shadowstrike generates 1 additional combo point.
    improved_sprint            = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison      = { 90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach               = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison            = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 10% Leech.
    lethality                  = { 90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    marked_for_death           = { 90750, 137619, 1 }, -- Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    master_poisoner            = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nightstalker               = { 90693, 14062 , 2 }, -- While Stealth or Shadow Dance is active, your abilities deal 4% more damage.
    nimble_fingers             = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison             = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    prey_on_the_weak           = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    recuperator                = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity         = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges 3 additional combo points.
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
    vigor                      = { 90759, 14983 , 1 }, -- Increases your maximum Energy by 50 and your Energy regeneration by 10%.
    virulent_poisons           = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.

    -- Subtlety
    black_powder               = { 90712, 319175, 1 }, -- Finishing move that launches explosive Black Powder at all nearby enemies dealing Physical damage. Deals reduced damage beyond 8 targets. All nearby targets with your Find Weakness suffer an additional 20% damage as Shadow. 1 point : 160 damage 2 points: 320 damage 3 points: 480 damage 4 points: 640 damage 5 points: 800 damage 6 points: 961 damage
    blind                      = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    cloaked_in_shadows         = { 90733, 382515, 1 }, -- Vanish grants you a shield for 6 sec, absorbing damage equal to 30% of your maximum health.
    danse_macabre              = { 90730, 382528, 1 }, -- Shadow Dance increases the damage of your attacks that generate or spend combo points by 10%, increased by an additional 10% for each different attack used. Bonus resets when an attack is repeated.
    dark_brew                  = { 90719, 382504, 1 }, -- Your attacks that deal Nature or Bleed damage now deal Shadow instead. Shadow damage increased by 10%.
    dark_shadow                = { 90732, 245687, 2 }, -- Shadow Dance increases damage by an additional 15%.
    deepening_shadows          = { 90724, 185314, 1 }, -- Your finishing moves reduce the remaining cooldown on Shadow Dance by 0.7 sec per combo point spent.
    deeper_daggers             = { 90721, 382517, 2 }, -- Eviscerate and Black Powder increase your Shadow damage dealt by 10% for 8 sec.
    fade_to_nothing            = { 90733, 382514, 1 }, -- Movement speed increased by 20% and damage taken reduced by 10% for 8 sec after gaining Stealth, Vanish, or Shadow Dance.
    finality                   = { 90720, 382525, 2 }, -- Eviscerate, Rupture, and Black Powder increase the damage of the next use of the same finishing move by 15%. Lasts 30 sec.
    flagellation               = { 90718, 384631, 1 }, -- Lash the target for 1,181 Shadow damage, causing each combo point spent within 12 sec to lash for an additional 236. Dealing damage with Flagellation increases your Mastery by 12.3%, persisting 12 sec after their torment fades.
    gloomblade                 = { 90699, 200758, 1 }, -- Punctures your target with your shadow-infused blade for 908 Shadow damage, bypassing armor. Critical strikes apply Find Weakness for 10 sec. Awards 1 combo point.
    improved_backstab          = { 90739, 319949, 1 }, -- Backstab has 15% increased critical strike chance. When you are behind your target, Backstab critical strikes now also expose a flaw in their defenses, applying Find Weakness for 10 sec.
    improved_shadow_dance      = { 90734, 393972, 2 }, -- Shadow Dance has 1 sec increased duration.
    improved_shadow_techniques = { 90736, 394023, 1 }, -- Shadow Techniques generates 3 additional Energy.
    improved_shuriken_storm    = { 90710, 319951, 1 }, -- Shuriken Storm has an additional 15% chance to crit, and its critical strikes apply Find Weakness for 10 sec.
    inevitability              = { 90708, 382512, 1 }, -- Backstab and Shadowstrike extend the duration of your Symbols of Death by 0.5 sec.
    invigorating_shadowdust    = { 90706, 382523, 2 }, -- Vanish reduces the remaining cooldown of your other Rogue abilities by 10 sec.
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
    secret_technique           = { 90715, 280719, 1 }, -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets. 1 point : 819 total damage 2 points: 1,637 total damage 3 points: 2,455 total damage 4 points: 3,274 total damage 5 points: 4,093 total damage 6 points: 4,911 total damage Cooldown is reduced by 1 sec for every combo point you spend.
    sepsis                     = { 90704, 385408, 1 }, -- Infect the target's blood, dealing 5,638 Nature damage over 10 sec. If the target survives its full duration, they suffer an additional 2,069 damage and you gain 1 use of any Stealth ability for 5 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
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
    finality_black_powder = {
        id = 340603,
        duration = 30,
        max_stack = 1
    },
    flagellation = {
        id = 384631,
        duration = 12,
        max_stack = 30,
        generate = function( t, aType )
            local unit, func

            if aType == "debuff" then
                unit = "target"
                func = FindUnitDebuffByID
            else
                unit = "player"
                func = FindUnitBuffByID
            end

            local name, _, count, _, duration, expires = func( unit, talent.flagellation.enabled and 384631 or 323654 )

            if name then
                t.count = count
                t.expires = expires
                t.applied = expires - duration
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
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
    finality_eviscerate = {
        id = 340600,
        duration = 30,
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

spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike )

    if sourceGUID == state.GUID then
        if subtype == "SPELL_ENERGIZE" and spellID == 196911 then
            last_shadow_techniques = GetTime()
            swings_since_sht = 0
        end

        if subtype:sub( 1, 5 ) == "SWING" and not multistrike then
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
    if not covenant.kyrian then return c end
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
            addStack( "alacrity", 20, 1 )
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


spec:RegisterStateExpr( "priority_rotation", function ()
    return settings.priority_rotation
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
end )


local ExpireSepsis = setfenv( function ()
    applyBuff( "sepsis_buff" )

    if legendary.toxic_onslaught.enabled then
        applyBuff( "adrenaline_rush", 10 )
        applyDebuff( "target", "vendetta", 10 )
    end
end, state )

spec:RegisterHook( "reset_precast", function( amt, resource )
    if debuff.sepsis.up then
        state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
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

    if not a or a.startsCombat then
        removeBuff( "cold_blood" )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
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
            applyDebuff( "target", "shadows_grasp", 8 )
            if azerite.perforate.enabled and buff.perforate.up then
                -- We'll assume we're attacking from behind if we've already put up Perforate once.
                addStack( "perforate", nil, 1 )
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
            if talent.alacrity.enabled and effective_combo_points > 4 then addStack( "alacrity", nil, 1 ) end
            removeBuff( "echoing_reprimand_" .. combo_points.current )

            if buff.finality_black_powder.up then removeBuff( "finality_black_powder" )
            elseif legendary.finality.enabled then applyBuff( "finality_black_powder" ) end

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
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 20, 1 )
            end
            removeBuff( "nights_vengeance" )

            if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
            elseif legendary.finality.enabled then applyBuff( "finality_eviscerate" ) end

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
            if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", nil, 1 ) end
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
            gain( ( buff.shadow_blades.up and 3 or 2 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )
            removeBuff( "the_rotten" )
            removeBuff( "symbols_of_death_crit" )

            if azerite.blade_in_the_shadows.enabled then addStack( "blade_in_the_shadows", nil, 1 ) end
            if buff.premeditation.up then
                if buff.slice_and_dice.up then
                    gain( 2, "combo_points" )
                    if buff.slice_and_dice.remains < 10 then buff.slice_and_dice.expires = query_time + 10 end
                else
                    applyBuff( "slice_and_dice", 10 )
                end
                removeBuff( "premeditation" )
            end

            if conduit.perforated_veins.enabled then
                addStack( "perforated_veins", nil, 1 )
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
            gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
            removeBuff( "symbols_of_death_crit" )
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
            applyBuff( "symbols_of_death_crit" )

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


spec:RegisterPack( "Subtlety", 20220911, [[Hekili:vZZAZTTrs(Br1wfdPLenFjfLCskLJ969I34SUIYgV3xeee4qrSceGlaOK1vQ4V9R75fMzW8auwooxT1URm4GbD3t)U7PVC8L)2LxmpUMC5Vmz0KjJ(UXJhoE0rF74zxEr9dRjxEX64KBJVb(J84vW)7fBUUoJu)a(dpKveph3GQInLjWpUSUED13)YxEtA9YnxpmPy1lRsxTjlUoTipPmErn(VtE5LxC9M0S6Fk)YRT)1V8I4n1llkHVx6QxdBC685e2QjvjnqX2R(1IB2q2(UliRRjRUMuU9QXJpy7v42T9DBF3RxgNFdP673(Ud3E17lUJS9Q7IltJVoJmCtfjADzArzA9drLf1uOC7vBwV9QQITxLwd)3k4VjWFCnzrrj8Y3d)x49WFDiDpFDXQRtZHhaOzD66m4VsIZYIItWDlklTcEBsEDzkb2RAyFljZ3KalBDrn8804m8r3xuElBdFF8TWp(2ms1skfd(u51KYYnRP)jS9Wxmg)7fmW5FVb)eZtNZazaobCSaP5zKOQIS7GVYWlVaHKk6HvnjoREjbp5(f65pjhPhZV8hbYofSHfTmEEX9vayFlHr0ltxZ(PFc(UxW2JxExCEA1YTxfJ0MnRpGtCUq5Tzi91KCYck4vwScE0sKaexvLINixxKVbioX5ak82u8)9JK4BZjvvWgsa4VbzPFie7xf)jG4)HTx1FtoqRQWVCA(ni9dqqGe8QQkC)ZhC5faSdpkn(Yl6dFSnlwmKtdgIN1p(i)HmKH(SbBVQhS1WH)AcCywhxEdPUAy1YnikLhvvxucOXPBVAgBdcXuX2WvuylkMdArLKvXP5aSF22RgDznifyCCOr4bsdJydO)S9zy)9GKwXg4bV5cGwD0(SNW)Nuc6XnpcEYckT53PyAZPTjhRkjtIzKfliWsUJeHCGfrRlagta2pha(K1rWbseqTWpPKIkPxa5khyjO02EmwyXgmCoWyKGSgNcB0e2B7NSJFXz0nQtah)iY9hD82RoKEAxhNHclZjK1WXeW)gxdQ(wnKFIq)KTyvyIwrm1JlONr4r5uJJYgkQuaCyfzDfQIPximgz0CiCcFQzoeIVguDxvhFTbF0pYFmO0a(kOmdtEfyrIZrnt3Vef5q22LP3aCoF43b4RgFlopLy9)yw8CuTgIdBwpufjtkYNVbuscesqJeOIFE0DeGxFyzC(TSZLtAONTwf9ZXw2rnlJH4rZrWCOu4bx00wl6AkSj44clkZ2KUll336Ntcu4(5bM3xYQVhYzc64Ibgpuv9YhkrMk4y9iNCqC(0C40PgOuz3sk14rl3KJ2RUHmSon)bq67tPjmiuBzb55osLNl9oeOoUtgmsEibm(W3z0kJcWVxykmaBZjuQhipnp6EU1afQlvOnmki5myRaihRaWQiAEkHkZ3Wdbkknet(NRzMUMkEByz9ZHhGamWdClOLG5TGUnl4Ch8lbPakYwmcZqKc(TDIcQR5hTPlOtauZju2n3cmtLOfAkfGP6)JVheCVbX0AgeJ41mf8c3F0e7B)itygyGYPqFXc4P9XZK4C4lhVQytEn(y5lpWQXc3hS972zlkAWzZHLSUiNz7Cx4FzQ(PIsN4wzS6Ei1LSFJ8nOOgraWxnP3cnIxX3gdyCf4M1MSOfLX3ScbyjmsnLrQJOo4amFKYjNenzDcNLKIDC9dlksGLiFtdDmpaMUYQIkwenNexVmc8oUaXbjiTNqrkqgjZtz0B5VAbjpIA5QH3tL2HuSVB35sB71xjzrjbDzXucHAfbxbjVAJWV6Ky0724YYhemXXG)IBYY48L54lq9CmN8jGj8II3W4AxxaEtHCDQhSbyYotYLLuuKbWDElQSol5jDtTuWDdjUJh5KFSJMd7G51XtBo1UjRa8(bnaq)8uV(TFI2au4cn9hvtloxNkW(FDrvLhh7o)mH6AUfXI6iW7xuYAEme3d3gneIq5npi1rpBevT8njZhc(wQ4S6sqFqeUjxI)h4GErme7LmAgX6Unn5wd8XeDkwdOpPU5De6VW)kBdHFCuLLMqIaEwWUbye3QuLvNuBzsPIW57Nta64kAGJG3waLOSH1biL3hldL7ICGl)6y6BIQqfFpkWY96ScanKJiL(zS485FaiQhOX0)uVqJyxa2kumpccTaC2EvCYs87px3htUFt3(a8VZni2VEjbLzqQDfHW0uOO9Gg7igpn9zyuMC7AXOb1FdT3wKmGzo8vAaaNIPhOHolojzj88BGa8aJGRqc6ej1S17nX37n197n137nZ97nZ37De8E2C(mmhK9qWmouEvscZdcgVnsNljSTeojajFM3tP3KxWcnjR4(dXJkvEamq6AqnqflHi0dWrdpQcpZijeW(h(MXAPyrEKQYJ5aKT4MBy0xhPDYKY005kAvZtl3QufSncTLvlRJwNbUqmJAgcih0Fw1zBNsuDHGy61AycID3)cRlzIblZ)ipd9NMMiVgFFBsj0Yymhsw(A0e3r90Oj3CsFGOHR2G4w9x1MNJ2uX863uXYkZI0YQAFPvrjtbjZR86NLMQytPO1RrAYf4A4O4By)jaet4PgseCpv8GczGkQrizbvoJPwJNnO6LQzucjRihg5tRtlrrmmecPygt35F71VHhZa875f0GkC6uTTalpMYlSaJFnslgmfVe0TfP6Jf3LGwIhY09WZMdvDYPmSg0K)cK3YM3xA02FDtoZRtGaxb4otpJ01ZlejVbt9SGtRpQZAEbLCxvCGmrSj4RUgmRt)fKYceRLS)bYYCxCAgcfdg2CWdbx4kvCnjocyS0yMAYPR09ox43hKHrkG)Fy7v)mP(Baa6gA6ybfNjLXG1J4RPPwK5xgxLnLiW)CCo)(yY8NJCsv1Pz00zdmajykQRhmC7v)p0edJKeQh(xteSCvPRwt9AFNYdPDrvluJiUiwlVydR7AYr0ya5HODx6nfkrEI8rJu)DEADbp95(s7zT2d3dxM2Nmolgr9hSTt4kFrhsP15IaGD7e6cHhO5SNqtNG(PlEOZpGR08YJtKRxIH4bEUsj1MoEQRUSiVkLYOWZvFSuEc)ycabDiyzJQlb7xZhQt8l8Oj0s0RKhQnW7J)X0)vNzLhukDattQsE5zKqwIyOHSIWitjNrk7XmTSPgjrYdHbhOL((mSWulmQdGmZoQz0P9o1nYwNYOE7097n564cm01FQ0F5o9bNQwubVjdPR74SUgAZUuObhLcySPZ0MYJujbPw0)KifqHhk47kNVXLGcD07ZYsqNLbA9Zf3tqMYM0wIoreJ2hkerI9Qp8ZO9GKyEjvrleWFwrPhGtg(WeAsfy6m5)uj5gc1NTXFRAEa4q56nzvTYVXjQlmJMo9O)9M5004zU2VtDTxhFdYawxMMCBL(kRrxFjSQ02kPeXONBittf(VANCc5(xuxd)s0IS4hiZVhJrdZIV574PitfBYUonF(W1BQQ3KrIiyfKH92i7KIL1QIXIDvcslKLKwgtV0zvgJKbWzY1lw9Q4YBruROKjaRqVI4oNE5fGmJVQny4DCdEZt5iZAUT91wWmkVUm1UiuspIxsImQBBBAJwrGy8amXhlLy3ihAF1QKJ7C7zjDXte5JwTCv5KKYISIY5MjsLuYsj51fGGx1ASYhO9cwaNvu)Z5)nM0CkCHXOJFOrdr3B6GQzMVnAPj3vAtpTZ67fQ77qnQ8M9C3YLbbujL(ZMCEQo5uiPNrIHT6HiYNIPUFRYhjkJG5AKzcuSj3sUdG7OII)xcgCJ5MWttoFv3xgxllwUKO1gRAPxrjT1Dt1sWkENUclpc8DXW7eDoIrwbnZ4hpcBmxd3xK)nuRuRBSiJ5QLANMgFuA9qdr8wjaIxVM(HtnJGvOvsEM2KKhAHYSNeOXcbebOIrEpIvsSAwgicPFQDjS5oz5T)oS)JAo)nD4rSSUuSyreeqpTiXgQtPFqBElX7tb4vpeE1TYUZsnvhxW)8YsHY68OFJbmupwzjqCOFLHFzrudFznq2()tohACg4o48hyfVv6WeYrwxuCBtdz8wmSYbIYcZ28Nv6KPITgNdIVb0SYJf3s4eAffqOMOjHgRabem)C96qCTnXo4UyB8ZN9ce3TZGku6cS2(5ZsTQTwk4Cmztx2U9hSueKgAuFvZ8DWTdpPfUPBMS0kteTwzsVq2uKg8mTvcmArau1R4M01ZJQdVDbxZRAcs4bTAkBerx5n4QpaCiCnZsoAWRWdPbIZJjF5BOrBHIxSqVOz0u2cex8wqJo6SkQH2OxwKmxgAammh6HhSbJW8ec0cEV06Z5xJVMnnKQilpTdmCRjJ5AHvklcjt6xMZszEmU4TS8yW620BW3dIL7HH7qAFLITIpkTYHJ0JVUTEIGc5nlqLzt6Dut1NzUV2W0xCn4labxCBfcQk0IOpP7vdTp9dUp1zYxi(SH80VzjynX5C9AneYa7AKACA0DtG023DzRMj7bnorufX5(SzjIjFEX1z1)ZlQT5CBe(8AiWAkhOlnTiwpUXxzx9DqFA2QWmKb)7Fqe0Wan6LlR793P(QXDikuMkrlsyjrym7jbJHBQDdlU7TjVcv(BudxK8XhRE2JDV6L(kILF3B(N6EPK3Wfc0EEXPeEPK)MbnoSl7e8By1CbtD96I1kQ9OESJ)bvxotHNMtsd7iHQVHJk0eyj1s4mqUVebCQapbT7O0(CU98jSMSjMr270vxwbPheuvJD9mQBdwTo3R0shKVTPH2SvDp3PDcmXrIapYVym6JUVEwTmoDEeThrggpFUAxfBtq5uxYxCDTgCtEfh1t1UzTCW7IbcqBvUbgv5PRfM3lOL3H6MtgpFS)2V9MHBVIk6X8iy(dSOx53BI6LymQ0cilGd0UpvoQQP4NshdO9f6R)an6GwvE0nTVfAGDwldvUNwerkL0sTNNoQs03RVFXByQnykxBdsEobP2dWDJ1hWg)68nLXDqxP6HZL2Q0yNuX4E)L5cYTJ2HSTmzKKTt1HC9UJ3EpQoWD(nBxOpTWz6syx21QgwLKmRFFEu0qABddmkzvSXLsQ)75ydifLKfRxbxf6zR(U6sB1zSJo8)rwymV9azlgOKWG5GkaH8I06OsXinU2g97Wjx4ZOjD4mYBSJU8W95XJSlTvtUUL2llsyNOvE)nxd7YIn3qCwKawwTSvxnTJHNRc4ONdqDPHPJeoF02KK9Zhwq4PIBKyu6cLsnzccAluK4vSem2QPKYAVjR464mETAg7Uynuq86SII5zanAiTrcdOrKHZ(t7JQk3wAlnChs9N1lU9inb(1f0)FznhDJpwajL8BJiB0InLpCPSKKp1TIucXEHXyrZ)zGos37wb(OtOqgDNCNp5W7ekAG5QklclQnD7mnPYko99LXRP7bjJKuxwuH6bsIKn8zZwgCL4hXvAnXoOdF3KcW)Z1ytRae)6nGw(w4vnz1AUYiwemb5df4INpccBUSkKeNSeZQCuCY)zdCcmpQgKaQmbU(28exiFlF14p1uKhR(U36nUhSAPKL0GzTvgAPdpXoEuqsMOuwHSDpqrcVfg2leGIHGioA8rJXZgtJi8oNaLfa(mi8I5rG70ZVLuMSmLSWwqgAI2oEjvttyYrsk3qYIUjUeWzIivjuaYzodtIlPsblWOvb3aYWCcNUGy1WNRfR0v5(4SpsqiC)vry1voLWtvaKwz274VHDrpWqvYYUMgNnnXUBQWTal9g8oFVi2gMlonLaz7vVHQUPlkKcIItgXkHMANIzPuAHB0qV5USvXXXelo8BpIgYYi6F8cE6VA3J5oV3zbVHsSV1jSeLzCg8FtYwZUb5LTUXgvlNR3nG7EFxUBKdgTq3ISxCcZELsiHn9wrZD8t61Mh8YL1cEnj0Py)oFejOnbdsIxVMD)kZLvZKJLqW5)14sS80IQ1Xtb2C2Y0B7DmQ5FrjLYOeCnULLkvfe1Wwus7Tmmtz3G9f)VcoATHLZGTSR1ARbNGzGbQ5OsJMinBekh3bsWT7i3e2o2BhlvMTcV5Q(qmQ1kcIp7BEPABL5rEVrJ0tA3ay9GKD1fyPzX8kqsBa8MnPeB7C4F5UwtaZpHrAbxzaRcWkkJJy3i3lVy2ipvsYDSoQLIz2iNbkmwgOGloaVNDMXaHezBv4Qlki8ez)(o8A3SnK)W2M2OSIF6tWOpsBnmem1d85FTyCJbtvpyAD328dhMbv8uHdAOlwZBL7B0D48bmle4BgiZZg4h0N0GGMZ8j7Pjv4kcKJxdPxiLuzEw1x5mGMAz9zvQR2V5PLqZxztCtpox)MnhoXYMPi8R6WnO9ROk6648D5(JoRRy25YBZtVo03FDVkmtfPfY)arY6P9pUPuO8VsQ9NzO(HInBVADw8d6MKRE5R43Vd(9RqVVCav8OcP58nHv9EwNNHxEgEM9O5fpDfXrLSSDC7XJ2oq71nYtYVJKvGEXy20imxJ5T)(tYRy(NqpfFQYabRvAFAbHouX1yLMvvw9x)xG4pUmfdRGFxv(GkWGxEU7kWrUvc44btiV1LXJz33y26qNOyf0B7Ab74euSohNZvFkHGJ4lQ1O)ElL(mAruR7wT3BOVKBW2B3nc5XcALZuIY(b33wpdETEYXcb7ixkGP3s3wCZ2cxUt8Q7bsCQioIoGkDqiPNrV7Q(55cU9cQ09qBKBvaHQrEGpI3oDN7PcDoBlRZPTL1ZGl(9CXf1bv0SOFz3TtJKv)Ia1SiumSCzoEerGB7xCB66gR3MXfXuzl(vXiZIDhTO64PQamdmtFEnaFGOs23ZM)5Y0pYxIo8)3LdEizqCIlTR7Gk00l0oB)MH3PaGDoNB9SxnCZXSulvaIabKmZGMAsDunjzzE6)HoAbKKglUC3Iy11HpLos2RtnHrqvMnfz0vl0WmnXMWqtOCV62PLTNKMAsnoG3J3N95GRHSUFHbkB53Qww5ZZOxL3MRSBtfTXuHXzCoqze9iyOxdSVKvPjdTfwHFgZFvSxs(scltgc2tgOXUz5TCpge8EtHajKGL0bigkQ67ttpbCuLjhU7d5DuF((YGF7WIBAMRoii0H9BF8I7yj8i7OAhzzLbB2K5zWBzG97(5KYMiEe)k5U0QesjTYDQYHuN8UJuwHRIn(wpz03D5f3hxI9nBf4)0R(1F5N(L)23V9QTx9B4Hv6Q1fLcxC(gPsOVbPlS0RJ(gHxAF8kDUcDOFlFWpaChV7NPxw5J(ECORcoFws)5VPjEP)13W06P(iHva4N6p(tdK7YjFM7Y23fa7Kx9SDd7MAaxYARkbRMN4c3EI7bk29x)h)SXM9TpvcL52fKILmVA3OvZEQGw)jki4Xp5DrLmn2KO)e3gtOPJNDCmkinwPEf7gTEYtf9SZv9KPw23UXJEQ7xxzoP3MZDJKn(ZeMSRUt5QEbVeEzVeBwRlb2)sLX4NOOdUfFla1jmtd0zcn8Z08KLGLpCmgPzXIu0LJ)YFbm9AoOTPp0XW2g)TMbUn(V(sm0T577Z7G3waSFrg(2cAZhkjh(A2g8ogywnuANy)ZEP6Ld3(kCDTWTV6MUR5G0fN5SHIE8rNDWJ99vmGqS(JMT65bTUe2Nn(ih7RwuS2ErepuCl2X2OM(F6B0LsgjoKEFmEolNTpIVWz44eewbT8YZ3(mne)KBpa2crKdWyeptlLghqdr)mBPNyZA44ZtejNF2X)b9rOc)Frg5EUrah3Bw8q3i3ECStnuRZg3JIS2hwFp(O2AN4ATtBV2PUw7S2RDMR1IdIpkr9R)iZZn93(0qHtRDmQu21nR9zzp7R8C1)rpBfi68j9AFvPpfOd92tAGYflvB(h6PZxSPtNB6KvtOC4R1Z75xUDIQCR(CStfamTSYaeWlsgh6FchhDQqVHDf0wOhIYPh3tlL1NFCpp5f(u(WOtJF78ZMDyFKt70XJg8cgn(RZCLtLmuQpz54MaeFxkzrlVGVJ6YYF2MwCHzlvcYbrQaUEAAsFhhjAEmUAoDL4IOtoAFBZvUxmz0(HMNCkRXwQUFrZwBo)4W3CYrVOVFTbZgWuh88mN225tk9op50MtUwKsky(fEYR9FT95AYRfMqW2ynUvh24ot9ohP7lrdHB8JpQPcdEsVGB80hF0AzPuNVAH3LzH8uCwh2dHq52NWCrlmXMUHpb(TNJjAMk0Pp(0AdqNdbkTV6SnZYltNQzQp3yiMP(tAZSmr4o)OPESHuYZz4uIcbP98uWVELoNovED740Jm(A0G2uxrlB0GNk96Vx7I5JsafDAmjDy7I)E(z44rkad7Sb967Pltonih)mfNlTAcAGfQrBCbjjEHdGa9zqlovqlcmMO6ThfiApGOuEvhdhQE7zFSqzb)Bg8tujV)yNFtTbhXyLIkqyemYJpUx)qbp0RVAA7MstBhg2XJpQ(8zSNpEqpgOD6XJgqftrlYISki1m(8odKAWzWw8zQfO)aLzxelbm7zRi(CFKnVF4o)bPLPPdpIIu)5AwhPrpqbsdJITPkFw4V(ht9cVFGw1SzFQg7uQ5VP3EMJtPEED3dDkW3SvP3EEC10HVcO0SrKqh1RDTqphc8ZaNz9opID97u66SgFpGshgyWh94JLUg6rABjkg6cf7zvaWr)ZC2i2YTnoJyHy9SmIImPNA9a(bl4TuoJ)jW0JW7bFJcO)WgXqTKfnG7Gb0dm6mG48ZoEuphspEff82ozGFAGVjLThRqCHeBJsOqEj3F8(ZErFVoFTN7wTAWaDPq05aMwBZBnTQtv876hyqZ1O3yqRJcl(PSdkS6WaaYM2JZMmg91Xs(9oRpFy)C(pmdOb75uPCF7KJqUYnaoslQQ6zeD1r(D3DABYgo5C8qzSJCJTsmgFCJm5xRHPtqZLUr1(7PL1jUmJdNC)891Ux)9cO(dCkZNDVa5tvnGeh28pFYaRIDEhnoGjtxRGQFsZKllno)jA4WyYF0QiH8rXZzJhEKnfiTN)oGl1TKfo1MydOotJbZHSLAAvAiFFbgknbjfwqxqF20rh6Ai10bmQTjuJsKUt6HMWJi2ILs76hNa8UArniVAw9SDnvBzMPv1XO(j63)ut1kHY8PB)cCqc8ROX)hKM1Gsptnggl4N7KDPlEo1)ZrBNtQMtxNnDl5PAi2bhnlKvNbPAWxEY(ohBlTJjtTxk6)uAMcrC9nCrth1Zq5KD6gQZ)G02Zsfu5OXutr7rQD9H7w7qeWa(VKrYAmwvSkxpDK7WafQimK31mpQ(tnzQEuRZ2MPEstG2wU0(MVLCaNSlVLCwMSlVK(ylzxEtXSoGLz6qZQe)VT75iIeImgsjoov9)z8mtmOIgMo2W4PnMdh0Gm8Uo(8fzG)Kya(eBXy5XJSIzy(nd4EiNH2aA9xe9X(PxohSh2C0zpNJ3d)FeNtAdfDHENQh2zfyPM75zWB4cbQ8jVy)CCKO6fSsaslFbAU8R9f2Rbfzf07m9kcB72QXlkSVB8O)Gl7F0HTllce6R5mbXa023wBr0e8Knq1pCCCpF5f2EVtODS2ZAJ95bA9dSD9gaEkE7)8cLbVOgQfEP199ZHjD(REyBAM4ZoE4eMxGFDUVAwocm6VbLBwdNl2rkqphD)3xQSCNjlRPAnKBP9NDOMxvVWJlUms8t4k1zH(iigOKKUBD9BKSujBbnhzjHph20wsbeymUgDue9pKBoMhsJntEwjnHsKtO(AZAQY6F0(9N8c1qqgmqNkInQ1xXBXwaMk7uQoRNA)XJ8KMBLSz6HRl47V)rwqc1RyMoM0HdxiojlBzZ9st4mqtlkPvT0wQpL7Ls7hzyPwB(wiB9ZUzqbtEpys5qCaD9I(MTUQT8De(q58ZozWaRaEB1YAGEQA3VxlhOi7mkHyKASBoHtE2O))Xt9k3KzzfkveevP2pzRCdSNLPX92Rt1c1SmI)jzsw5Iq6S0KQt0QZMnILju1HELRDSsIW47iQ13SrTs4cOa0XzNJtaw3xSddmQUlKAPJ5DKRX9TMkLVaFPPi5ZzGdptFMtnQjyhSa0oDTFPGkV5AG1xI70WDYphBt6k7BtlDy7cNE2jk(qAIUUstFJY6HtmEDjKlYeI24CkKJ3ZcdXNpEuGgQlun(MYCz)R9uxQRNSUpDSKzJGKVgtmUN)sg(dPDLcef2I)BCJAQviK1ovAMmyj(a4pPx)aA3BqPzRrRpi)o1HgEGK6whoGDpVmCeG3X28BeMWIepVnTSi3IstMZ7qngasLFyC6SFNL3i8bm0lCAerMUqHI5S)EA1m6t53DfTwr)LnTNo7bIw7Hbhk1WbHCMhkiHNN2k21nMURiCGxhI6nXmYcfaEfTd1RIxWpWm7vDbaHrUa0t0CEtxRdw47Frm9cnxrnER1a7dh0cfN1gfnAP(d48dhRIZ8(qG7Dy7Z19F2BqEUPZ2DaIDJatcRIliamZzB5FyFlDNwSs3P1ZGR1ojYK5VjxdSglXFI6Mz0sTsdz659K5Rh6m4sqff4F5VJ8d4BXpyfR)hPoKWCduRMJQGSAh0I5OBtADB9)LX53cr60ZJ1bSFcDMYSZf38YwvzoqJqonS0VTYzjnc7eI2FILcD48uL1X9FHA4ESfH4QuMQK5hAqqi(oy7v3kZcMPl(49qdtDJcJcJ9ZXXTghQ3C(y37pEJIds9ZJUNdfnjg1pUcmb(YAgtvgA)V5ECiVeLwn)bhFLYogMPl7JVFBZL)rOPw9sarBLCql(B)itWq2QMfOU9(OyfTHqyb7WVajSxUJc9bOG99tcLn5e8tRlYz226wbhoBMtiuDDT8MgKo3Njf14Hl1sDdtD8TXawvfHfTgt)a9kSaAKTLZeF501HJVQ3KjrdPeOXdKntvBpIKj3ZuyHQDexbjVAJy(vqVmJjXLLpiyOIzxhuopsU8MGYsgi19tKdAn4LykEo3n2cVh74fdlOlMNo(e)YFb3b7qAZD6qwWp364dyJy80WudhUxSey4bpMlO9XXECnfaph1BCx9DjxbFrDe44hY(IjXbnSWtWGqtZSrNZVpW05J1L)F)]] )