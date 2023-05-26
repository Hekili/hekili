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

            if talent.deeper_daggers.enabled or conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
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


spec:RegisterPack( "Subtlety", 20230514.1, [[Hekili:n3vEZTnYX(plQ2QOjTK4YtzVVsKv51658wNSjUcD29)eiebOiIbbyaaLTsPIF2FDpxyUbOo8UvQAJLWGb90tF8RpMrxp86pF9IOWQ4R)7JgmA8GPdN0F40bxm(IRxuD)U4RxSlC1xcVf(hzHBH)7I93uLgxDp(G7tZdJWjOmFFXk4HxV4M9jPv)s213yFwNcJDx8k4xFXWRxSjjkkMo24YvxVah75dME(Wj)phwEy5)mon8BhwwwfhMwTjyvu5HLHRQsYZoSmnPS6WYI4)Z(KI4TXzvL9p8Xdlp)WsywVd)3FumBJiZ2Wb9hEy5(DizvknGXNp8N4dyq)3WhIYig9wYi(h7Qs2M8FJpSmE96KvjXzRUxACtGVgzC)A(DWy2veVkF7nHaD(U0xDBC1MWIdl)0()7)nfE6pNdlTBIxNxa)Wc6sS)1lW1vjHLs)vXi)9Vt2LIZcVjf(5F(6fuUamOnHr5FTSQi5lXuMyrYo6JwWFFGpMxfs5Ahw(lRfFTF8UWSKYnapfjH97od(pLiXinPhwwLJKzw86eyDSUiFl8R2GRUWYYeCzEtE2ECJjd(sFib)V)EC4xYIllHjm(Uy4ZMaF0VgZ(qi)ylUV((pDyz39zPWiXVCs2TaNlew3ax6DLL48N176fWsc(vjHxVOl8X2VEDFgRP)(Dhw(WdSFjDXq(D9oSSdm1GKZU400GQWcG5x2VCZECjLfuwLxalJlpSCcDcUleMFG32Fxrso85UpOqWY6DDfiTQX)Z3b8(4Q6nc(mG)R09XOEaqtrHzLXbBdxfEtrmq2GMe5ZoLtGO8rEWU8eu(nkgLPaUZSdlhrjmNpFS0QK8P2HAbrjuQwWzaX0yGcVloqEMi0WBApFc(EVLoFvHPGQw)uyVc2sYUnGka2NXAqULQu4VX4lu5O)sAoqgPHrWp)JGkaWpaMYnGWXgumbz3WosEbHdrOyqoJrYFnPAdrNcxMS9gImh9DjYKYVci1bVvwEfoSKTHWt3GlWiYMva1y2Tcccyqza7djAy)ES2(DTmOquX2Rs4Nur0eKrr5GKDd4bNCyzum5PRb1KGVY0s6dlPWKSsYyym4KT7kaBirbQ7f18zDHd6U0q(3b0JJcatlbejqYV1)EmvKRMauLC5Ccj7oYVoYXM8e4yDTsZ4s0prFcLQ75IDmQE)aepqD6Q4m(UrZY8JRxV1KoUwN(ewR(4V1KRDdhILuZ0(OAA)gMwgs5x0mL7YKXCywxTdOPVfaF(Si0dvrYQk05K4BTkeOl6peGEYO(ZykBGupyHgjJ3OrgkMm(qc1RuCyrAc6lGQ5VGTkrljfzGvh0LvFFFAj6REDs1o5Cm2uXLjSBULXpTUsERVvY7slbQSmCnZ83A2kd9ao5uQdq6Il(BaLNEpX8hFBf0lwaFny4a3pFFvzcA2K77R3rVY9l0GBVti4NysOLW3jyncesw6SvIjtCWS(P2STJmN08VIB8AEaque3NVNbJGsMizLaYexTaaBSyb15XcG0bSii8ZJLj5wcaSTEkXuLB(JKhYO44DXfaZTiScapV16GkJxvexzBq9CWbhoWbqqjduQS1)fAkv2VlYG0D8UknVKjJUjPQIGeJar7t)gkXHJ2qhcwEGXAy9hfCxm4(IBLcfaM2gRuObwCjPJT9L47y1y4qDuDs6kCWZWE0UYKY29DM4ayo(TCJOqzAPRRXeznhoUOEl9a6ZYe(goWa)iD94FFOUd(2ecIrGefXRlIrTC1afyi5WreNvUhvVXWfwfIYMHffGHranei4cO4wVpfvU)DuVhFbcWVS4VbQPlYVIALyxoe7aUkL5Z(XEXuXPajYtb6oRF59GXG0YG81brXHGr36rdd(TeEAdZAlMnc3LaPWolTMNxb)pyzSoCFALTOcvy()ZyMqSklbKFYaU2D7tZIlOiZHG72MexsnKsJyvwuGol2Ics579lGX4II97QO445lB6Uky8n)RGKzY2TeJlj4GPFbb0Ei8yPaQ(sYQVydjEnpk5onk4QeuY)WY)3ScWAAznWHK7SjiergEkoZbXKxb0GSbLTLb7vMMSkoaeKdIG)HDTrRUDvrvPB9MPxefdupW8Ij2SbH(IAEmUudjHNt8(LbAb3esEtCNG)PLJ7PeOsLaE0H06DnZNLKYauXlawaKqSebyvZRzE6IxTjhdxSigS7Sf4r1HuOSEF)My02oUGlJJPsUsk4KmgKWJ2dZTakTTMyxyXMpJHhMVQhnYV3PqrSnkvSkIiMi7Fg0yWiXMOX7nY37n297n237nX97nX37nLj4QJUVzbx7O40HXUAv((mH4fYNlI55HRkbHOEdyHo52S8cI2nORFoUvjluGakQwTHBMHSboO)0sAAYIbVy4BgIgQaFDvjicoXwQSqNds2sufnV8vx0TxQLSz4ebS(2NZalMlc6gyIqSiq0(vb7s3x2FcX1bWFm8B7uNRnCiVrRW09E)vLuq4RtkkRAzODRIkTbWxySwX0OU41UDyKplWXWacCf9FkfMeAiazzXFBxsb32UqqIAD4V8(ROWBfj(bulADaqxQAiwkvoQ21L9TF7QO(eCYDq21TWUN4PWE7fgB98WJSHKx159(mkshGXuclvQIJaUJ1C72fvcJYj6rL5Nr5xGk7k8v3bUkOEExt4nBO)aUvFxycXjypPGPl2N1IGLQrjdYgkYd1jV2gc)MvmhnLGaMPhExYT5f16EVguBgi)8TKKgJaRyiN8mw6icwNVAV2Wu(KHPH468EBZeoYx3I8MYcPwpLOY(0xZDOZWjrY)Ua3grvefOXIQefxuQ4cNvvKQniIAaiG1qAu1Wb0wjriYbw22dfIs4hJtiOXDQ8b1nlau827XFG)H8ytOw4G(AQXqlSIzs8wKEcywvmIDYzEdaDXKT73szAsb1k(9QjiMiSrhm3wt4TO6BLCIyGDA9SVC8jFPv5nr1(J78)xNocBHisQisEzPnRs1jjUve042cHTBZjpQx7)SUYFKrmOMz6iuOS8NgPzc9uhKNf3JHfqKUiaGIcG5PTS(B5Fngfi5bStXpfIbbNZrh)Up93WI0TkKy)aPpY)SKWpa3I(wjidFi12h7rfX3gtcky4fYrLYOYD7tl1Ik9Vp8nYdmfL5kd(37JUDlz9Oo23kp2BcVfTBJQmyoM0I1vubvr0UcIbbnGcnL4pP8b0nbs3fctPfGfOFS(Rb3K)nPzZYd5XEQhhS6hZvwr2gw8fE5mWG9LwlbLXyOxWQfeiSe6Llqt1BHSSOq9yABEPCpMIJLef0SdyMESAcMKr)2iyQPwTtdoXWQq)7BsWmpWCd9j5VYziKK8KiugUKMkstOHuvBA(LGFxyg(lr0mL55mxP3etlPewe6VTkEhp(L)69Wsnt2tkDrgyet8JSOVmegrirjLZo311rYs7jhAOar9EePa0zDZuGtqZfDlRcQAMenzFTte5cE0no5BnbaxZ9whrggPBlouLSO3AXtTZ1vDg9KPyAGyLbRz51cdGftty)3mTvlLgZtiFN3(NhCZfDV0hY5KCUn2TsIn7psnxWgmVJkzr1kgqqhLvG1vWqA7kcBDkz9Py125ikVQpMFY9G(uf4UHyAPrAyUnDLVKSlGnv2Y7sDuu0HOAi8VghVddnfIDJ(86OBjXJDdG2KLTCmkq4NuYEzx18bitlTOzwOPBGSw7ZZ6qusmrSWm2vzLjljyX)68FYZ1VyzIv09EMzyWDqyAc2gz2TQOUU4I1RzVf)j1fU1UoHKu9OJv3vavUncyDKlnye48pamB)v7Lg0HLDBjOranfO6GBsZZ1ty6I7ZwbXUbp(WYFgFUiR3e75hw(54vBYs(p7fon5fcWQnpDVaA8m6tR4tj1OJTe)02PURSlV6fPEFUW((sdqww1J5SZ5kVcJzAlbRPIXqUE19Rq7wujaTi78k02qf3Au4A(S6(YXuNLf51is6iudJQNPZqf5MFDFAvcyrKcWsePlwdguccJUiL0DFeLvsqgr7lyKng3btP(mPA6bdGmB7aFfXBtw13AYFEKgn4MiP0gnnG1FYfu3D9bSG58vHGUWxLuAq6AK5Pul5Htl736D1J0T9PyRLQPj5UYIIYA3cR0Ty(ofrIBlZqUaZ1OqQoGvl9AMt31nAk9yAcTBsb4ZGe)xHO9RZte)PX3LuUkUG0eiAHvI5v6rfvKBq3TzTnuhJVuIBum41GnbyMmsShRqGYOuOZS)qAuecAafUJEMY(dvKNh3hcgeetaXZ1b3UksPLXK)G2YOdl4o4vphE1dIwMMO7sQrHCVHTGYJO9P8N5nkgyBKw4P((dR5LDHQPJQTy7(VyDcDykZcf(Dfj1b7hIQ88Vuh17hWuy3J3Z20j)zLp5k3g0oT2OrFPPHLvJq5g)Gci5kQ1HFLQntZ4Ayu4)zpOH6SjJShVmVmQU64ZU(XSWTFIByd01jngVkanxjRXjanfOzO5ulD2mbxgPGv7sdVN6qth(MMUAJuRb7H0Vu(IwzDA4Ty)qWwqwqWzjsyJVGBWkOxqlqPSexHcd8tWojtSsiNc2FpN4rN3HhxjCRlXmHWNYOmZpa(2rpuOREn4BIYcPPxlZiL43wQEunhelYwaG5GEyy8aNx)RzZUN8ILHFHU2qlbBcVlwlH2IUcHQtlk4hYIiruU4d0sD8V3JMcUfFVW0077FeLiveRd)JIB5xqX24vmXfmfVHVXIkJLIAZ4fKfy13VeZOYGuoWiYpjG8BAx2ZyI598AcYfsH2gSKxvnTK37n(GHxih8d2lJEd5PbNu)lvFnz1mAyVjCDfr(J5Rj7k05eZPM40)ClTa1ve7F7KeZjz3f)heDxQaUIRo9SG0qEUUCg3nXjnKZmMdaa6xa5SmbmX4IXdcgTBLrzR0bv1KOF7ey7AtqQvWf7PfISYNqouHHd8nsl9)ETGU3W4ml0by2joaW(SyiIgYxOZfHjrbKU4QFyuuPuo9SjnFPlLa((NC3i0GoJALw1RqpEg5qc6G0jJRmlzh3KBEMavtkR6CF(ZxbbFsupOwPJO(XxZopBqiPz0ozrqhOTyISEzD3CimwhMDpo8(wdDZnV3yzG96jDPqdCMWjT07mJhuYp(F)66ROQ20IiBssE2bXzDofwfgQQ2tRZGqR3CQJR75ZGP)eQWcvVlnHXutM15lwT)GPpuXKZBnbusgKUgRVk0pAGr4rKM3NA6UfLU4y4gJ5lxF5aOzVIiDprjpNeGqzyF9fSknSqPzAup7IgXC2UsHjfRVEJ6ryuolSQF0x)oft5hot0SusXKfb6(CffHRlgkueIg5ij1QDe7UVSAiwjYMNsH)MZAiPkET9Tkg1ubMSARTzmtJ1WsBZBONnPkEBgC8PVWJQ2Bv6nS93at3693A9epkLMIkEBmyLw62QeZjLen3Ic9uatAPaADfDTHkMWbdSbSWWoylezMXpSXkM(KjfBvpHm)QL(uFNPNRs7PWIM0ehOvKpZGIR5WIGrxsnWET)LSIriPNteqCdZNqgKKfKcXI1N0m1n4vOovfETBOzrL61qQRYvvSzpwzDJU)6jhsl5)htDOEid6PnZKKKtvlSydwVVGuTOrnCKV8pvXfLXfO3yYu5oJMnpvqKkX0C2GZutPf03mHYT4X4lnaBImY05k7z3a725OzTaep)nX3NJN6d9KgYADmRJvXQNPLyrVMqpcIrH3ElWYS5xvDaMoNpXecN0SGx9g72HhrouvdyjWKabqXHlulSP9yLWsgnG5pAKlV1G78Kvb3wKeVgMOvBCXRmhxZ8PVRlqx5DdxoaHUv)yxCf9GEHXqKMEdjZNKSGTVeNcSAyW78)Wd6GcbPolWhwEfrk1pBObBoGopPGjYnK7JQWjTVS7Ob7behhg9Sn9LeEMvRdUOnM5LcbBZS)V40Dy0x)Me9iAIJnrQ9o9X3Ux1EumAa3gXHjoRH2b6zBE74mnfwk7JYsZTPTUTaODlwpZKUrsoroHiYmzFbIiLGVMYLblLJQ2YSNAfCm29TJEtLDUZU9yQ9RR4fKvXdl1eXvQQPzUABmUQpvVGigjftQNFwfUJg9nRUxmkQ)HL)JSur(T1p(SUBCihP9g04I7NrynXPRHL03aVxbHBXd611lMmWtsTDF7xiNv4juaO2bN(uKtmoK1it2wDnAw)1so30REZNou3P4LS92y8WRslSal)KS9kHfBY5xeuwG)ze9ru7ZdOz9ziB5XkbKUvPvANARJ6CT5CIADw(Nl1o)0wlPXAKWGYFmDrGvBitSLUzXXHr(4UsyNBa5xvwzPOlN4fsRuuYZkE465fQtaLIWjApHrzr6q7SxyR2oVW7kZA3HSOTmqClHKqpzUN4gyINUwoRyOTYwynYynimuHFTU0HDIBUjNwdlM2LE69vSnOQP2rlV62Wh4jhlkUsW(NcB41ZBWvIUiUMfREkP(Yjb1IYsJcy)eFn2Co3gR8HD314IqhBzbXaCtLjKGtL972wWat0wTU3cyrCsgVEvwupABolzLB5VFEFb3tAPWvknTEAThb4ienShvk1UyFnp7vvhihKa5EglzBSJC8ztq1euDl4kAzq2L00JRJMVuS)4JFxXp4sEV9bLNzdEp)ml6WeNijukxRo1xKnMAYgx7C2eoPjhv)sJHKWPhnkFgT558GZ2X628j1MRABCMVhFqCMVjA02pt4d5klCWwxsHdRB5NW(bj2T0RlVye7ih3zL6nQG(TLaRwSi6uMkabuQOrdctODnkbmusLYflbzLgSHe3L)ipe8jLxrSnOEJR1IAEyFAKUVFiY03HM1GhiUwsVEXxdlW2ebeu)mYxs2UlhbUrwDVseV8Rex2OaRPmNCVCTVkFBi5kOc4Czeu6F8VrorV4no67ZZGVg5XVIjaPla)kkurxpMlEbdR7WV1tm7JTp7kg)1MARog0N3PVqZ7BTpVc8lAZPbUg957N((mF63Hx6lDhxXxTC21V8VmiA73ny1Z(HpArELD7aDCsRVrNcRn90FsF04JG4mmkPVAh6q48rS5yDbspuJh36ZH24twU2GVXFx2X)Wyo1owiTE(EI0PdjW6EwuBsnpigg7Yp)SuR72RIkpUT6H2PR6mPPruM9uJ(sDIx1xbaE7QVgnMzln5(mn7dhyF6Lr6Rn12I(PTt7tGl72Sb29eglF5wQWyQCSJz2pcAtR7gwOTFING4pZsLRjwPun6ZS16408udin(sCLz5lebOWGxZ)CnwWJxv)XmKRFr(ywTzivSINfBhYHFPliAjYmD((lfynhZ7tu1(7fuTNgp976S(K3PCzU8rtUwf7jrR)SiWxh6LgvzgBUHrgpijh7hj54JzUApQ0dF8xiSjCkEZbL)8rGmc82FiFDs9LfqzFXfQXPZ(r5RzKdF02i4vV9mm(3zwUirS)A8CYA9H6915zg3XhZgo1X8QCy9T9INLSEM05cf5q)a(NAJNYTfQGwKxzWS(SCNGkp54TckzM9DxFQqnWVaxX(UZpjt4Z5nTPmbWZpbv(qPnapJKGPz0KuRF5H(Wd(YI38zkDWmUaEHU6mDVwCKFlKBZSx4mFzSvUCYsNnSdHry)w48Hhug7ixJDS5yh7AStmh7exJDkxm5p(7ct3Bi2VsTy8Ah33wh7K1In3o2F15Y)qhBfxB(OoM24VeymDoPPKQArGswPq9oTuErRFNFrx84FPHi72VKxnLkMPunBdCzFA)xkR83XM9dgg5lzxqLDuQcX8luy)ZNnH6c4pK7CszUG2TojZKj)7Eg9I1J6btTpM(4p8d8(JGIXb0kf0i)p(q0JuKLstxcXLqNcxkdgVetEZCY0DLCKxWJE8COFhZXiHrtpLPqQClz(6rd4)EN3oMsJHH3u5Cn(66Pw)2WeFZrtFDx)UOM0JQd(8CRt2SwRuGFOiIARNC5S660PZkjK5Fi3JKnVOO57ur2xSqCyOvbBGQhUAUXWtnBXShEa7fqvJfWi704hCCtOv6o5C9ig7180oHRoD4rCVo2mRLmHpcjLNJBKrzQt96F0KGMdO9pv(Uz0YltUvgL)9AxcJYps5oxKH))N1na1NWDiiOL3knCnnF2Ot7AeFyhV1RD(Slarnh1PTxn989P8LMlzvlVYfwKz09KMWa9WdN0TjmlD6AgDmI25HhSGcAyVo0fWLxmONjfxZ5vmqit6MVeV2OEEfMbCEWpIPamXAWN0pASCEfDJw70k1XN9Izdb(hJfxBGQbBmdRnw88ELHOVQLZnZzs9Io148j2oSlmmA69pNZhiS9oU)uYY6pxxoigCeTgzXKR8ux)pl3UiMIVexRCYlY8Ugz(yfKYxcbE2TXw4cChoOw(vFuCmrpp3ki6lP6k3rKfDqdAW)NQplYjk(mLdWTgaeL0zOpRDmpHTZhoGS8FEUtp0jBLov(mEJptjzbox7TWANt8aeU2WY3T7KdtBoQ0DJricO2Oeb4RDqhNByU6enqZ07r2aGK0P7jEQRqNtCDrdW88B723OjuKt7zOoA37Ib7JuWWwk6kb7YMi8SHxulq8h1vHrJwGHLAxVD)kyBvAps78xcADGfmBN0eju76(7DjLzvobTJkVtA1JFpm4fBsrClTdh4AeebyfZrudV)j6QDqFp0iR)SlsJzd7p1MvyZtUgGO0qE9sBI24MRCcuCi)lhhzn77f4kLOrwHLLBs28Xdo31vmrlwroW1rpuShTTIr2TvmOtxZRrcjHw1RqIlN9wzKd4J6zpO8rd0jFJyro6LW4o1XSyKzl)2MVC2eiSfkDB2gf9601gQ46LQc0lQK2t9wyOnEqDWDCDCFnXcA37tdUXM0Rn0MhtZD0uE970CChF(P9gCJ7WzSir(wrUenUff0)isNuEIJQg7iEsgMCTT0Jbcq9C93PRrsugmq1RJKYBtipgl7kY)DFamB9FZ0o24B94lc1Tu2sCI91rdegOez7T02C6EXR9r(gsK0J9Vi0iT7QaRMKWGECQ5OO)lUvcKTdQ8O6CpoWG0QVkbQdS0YTHG(BjU1aoM3sCbbCmVK6DbWX8MQ9sGTd)VL8nOAlGYOno6)sMAvEeyz(etCeWODE23bZ8TTvUMpYC3tDjQFM9BE59stT)G0P48jDU7DTWlnxvwvNqh8s1L4pl)DtPEzrlmHrwaT9xndwMazsGw)BkJxZCxoTXpR(TlVsVvO59QRZ09qmNAftYJZx)jZg1ZcPBwT3tKaEzY)8ZCUOJVCoAVUWkYADuAhOwqT(j22ExpC5WA)K2PYgXfiNnotysEJ)9CNEIb6Y6UMMaN0LcVSW2r49gd61UaAtVLLd(xd4egrTT9i(BpIfobFzJy3QLCL5ip8G7ij6zjsPZleTMGIWiPZ0AZFgr8tL2jsQaIL)KI4qewiFmQ9Y4Zg2GiqNUc7nSthIiqklrf94)Z9HfgKAYIRzrAMs74lJ3y4ywmzOnq)ZVibr1eKeYqZ)OFm3PQ75mX8Vl)1TWJiNLS14qe8e36jnPrBnHdDh9A5qC61E1PVd)b24rPK2ANbNoCGNmAlcPWwDjeMFA89p1gue5)quO7n37MkfWH6FanSg5OFJiOOGPfdleA9FtmyGlB31Mu9mj1InMEeLVreenKx7StoFgENpDQLUFVDFB9dWUsTN16Xf)vrwTFzUK3QPkZrhRPg3nLYlZyxRylBo3dswjuyY2ZJ3qjurwZA(SlKQpP8iE4b90gmEqDEduVIK61tVsE)j5kpY12GZQdkF1hnBYaAUMLVDKCnJLIfm(o8YTnzqhZmpDC7G0(E67YDpu7uV0VzlS0UTasN6YI9D(k75zBri1ECnvH15DNC(Ox3qzL75dhCd(3N4ND2QlWNNeJPrwG1U6JMcfQGx7U3F8REvNk6UkQqYeCncs53XF8FiuP(Jo3tQXL38uuA7jqOR85ASXqUC2p5p0Ulr4awb)BPO5okLU292dPv7AqqRzutZhoWSWVQnf5l2vTtBfpClDO6uRXfRuf4K3Ep2yUVeySEyzYWVu7PEAvwzpIHEqUC10w6sX7knVDzGXRkEVMqy27cHG)qTncwfwMavDKEg9Wav3M8H82NAB43yhBiUZBwAh)vwHVFxzjo)z9m2IIJeBqusKO)s1hPJOw6LbRaRJJFLJjEtQaRnXyawjCK)IOPipS8hbjuw7oY93WmvI2KS09veNnSS9X2yOTvkTv(rURQLxXj7G0bLCvGi78gvdW1DVP9eyAjvLxo1ETSWszz93pMxewZmyAV9RV8nnTHGfRMPPO3PVofjKNafTwB8aMf8e8tqFfc4B2z5dIQjk4RmXyrgbzeuY2DfGFMOa1pzD)5QHDPJEuypPaUKxZoAnxRR3UAurZzxUvHR0Gph70T1Ud2kvBJx0XPGlqI(PNr2PNxMJhHYr)aZessCrDliAGdvPXcEuuhl6En8IAnxqno0rec8DPLiQ(W1mlBRLoRk8JHgLMJ)gqeyqt1GaH4O6UiKCuWljHiPCeu67qvT1lOgaxyGqSTh7d5ZJd2kwfg2Orpw3NVN5YI(DqxPi0HRwao2wSGAEFrmEck)ajThpP1QJyfehacXISggN2Levn0rT73PE1W9L9BHKVUJlPdK0MewoojoR)0Vz2QZUnfr9gOFamyfcBQFL0wyZ4fy61ruuxfvAVs5FsN0wFs6POZYjLQLLdC(S34ldVSC6BaLtKyv9CEqqGGJioRKK7weW2kS9dxfwuaA9GlVcYrmcphNW7)7O2G4iCstelbWT8H83HjnDUTp3UKg4SrK1xo8TD8olnodntPxViCF1M8IRxSiz77jx6Fx)))d]] )