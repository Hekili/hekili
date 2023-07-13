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
    atrophic_poison            = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.6% for 10 sec.
    blackjack                  = { 90696, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    cheat_death                = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows           = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                 = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves            = { 90743, 231719, 1 }, -- Physical damage taken reduced by 3%.
    deadly_precision           = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem           = { 90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand          = { 90639, 385616, 1 }, -- Deal 2,107 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness                = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by 10%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                    = { 90764, 5277  , 1 }, -- Increases your dodge chance by 100% for 10 sec.
    find_weakness              = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 15% of that enemy's armor for 10 sec.
    fleet_footed               = { 90762, 378813, 1 }, -- Movement speed increased by 15%.
    gouge                      = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    improved_ambush            = { 90692, 381620, 1 }, -- Shadowstrike generates 1 additional combo point.
    improved_sprint            = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison      = { 90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach               = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison            = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 6% Leech.
    lethality                  = { 90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    marked_for_death           = { 90750, 137619, 1 }, -- Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    master_poisoner            = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nightstalker               = { 90693, 14062 , 2 }, -- While Stealth or Shadow Dance is active, your abilities deal 4% more damage.
    nimble_fingers             = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison             = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 18% for 10 sec.
    prey_on_the_weak           = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    recuperator                = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity         = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges 2 additional combo points.
    reverberation              = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 75%.
    rushed_setup               = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    seal_fate                  = { 90757, 14190 , 2 }, -- When you critically strike with a melee attack that generates combo points, you have a 50% chance to gain an additional combo point per critical strike.
    shadow_dance               = { 90689, 185313, 1 }, -- Allows use of all Stealth abilities and grants all the combat benefits of Stealth for 7 sec, and increases damage by 30%. Effect not broken from taking damage or attacking. If you already know Shadow Dance, instead gain 1 additional charge of Shadow Dance.
    shadowrunner               = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep                 = { 90695, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    soothing_darkness          = { 90691, 393970, 1 }, -- You are healed for 24% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    subterfuge                 = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for 3 sec after Stealth breaks.
    thiefs_versatility         = { 90753, 381619, 2 }, -- Versatility increased by 2%.
    thistle_tea                = { 90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 19.6% for 6 sec.
    tight_spender              = { 90694, 381621, 1 }, -- Energy cost of finishing moves reduced by 10%.
    tricks_of_the_trade        = { 90686, 57934 , 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride         = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                      = { 90759, 14983 , 1 }, -- Increases your maximum Energy by 50 and your Energy regeneration by 10%.
    virulent_poisons           = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.

    -- Subtlety
    black_powder               = { 90712, 319175, 1 }, -- Finishing move that launches explosive Black Powder at all nearby enemies dealing Physical damage. Deals reduced damage beyond 8 targets. All nearby targets with your Find Weakness suffer an additional 20% damage as Shadow. 1 point : 192 damage 2 points: 384 damage 3 points: 576 damage 4 points: 769 damage 5 points: 961 damage 6 points: 1,152 damage
    blind                      = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    cloaked_in_shadows         = { 90733, 382515, 1 }, -- Vanish grants you a shield for 6 sec, absorbing damage equal to 30% of your maximum health.
    danse_macabre              = { 90730, 382528, 1 }, -- Shadow Dance increases the damage of your attacks that generate or spend combo points by 6%, increased by an additional 6% for each different attack used.
    dark_brew                  = { 90719, 382504, 1 }, -- Your attacks that deal Nature or Bleed damage now deal Shadow instead. Shadow damage increased by 10%.
    dark_shadow                = { 90732, 245687, 2 }, -- Shadow Dance increases damage by an additional 15%.
    deepening_shadows          = { 90724, 185314, 1 }, -- Your finishing moves reduce the remaining cooldown on Shadow Dance by 0.7 sec per combo point spent.
    deeper_daggers             = { 90721, 382517, 2 }, -- Eviscerate and Black Powder increase your Shadow damage dealt by 0% for 8 sec.
    fade_to_nothing            = { 90733, 382514, 1 }, -- Movement speed increased by 20% and damage taken reduced by 10% for 8 sec after gaining Stealth, Vanish, or Shadow Dance.
    finality                   = { 90720, 382525, 2 }, -- Eviscerate, Rupture, and Black Powder increase the damage of the next use of the same finishing move by 15%. Lasts 30 sec.
    flagellation               = { 90718, 384631, 1 }, -- Lash the target for 798 Shadow damage, causing each combo point spent within 12 sec to lash for an additional 159. Dealing damage with Flagellation increases your Mastery by 2.5%, persisting 12 sec after their torment fades.
    gloomblade                 = { 90699, 200758, 1 }, -- Punctures your target with your shadow-infused blade for 1,043 Shadow damage, bypassing armor. Critical strikes apply Find Weakness for 10 sec. Awards 1 combo point.
    improved_backstab          = { 90739, 319949, 1 }, -- Backstab has 15% increased critical strike chance. When you are behind your target, Backstab critical strikes now also expose a flaw in their defenses, applying Find Weakness for 10 sec.
    improved_shadow_dance      = { 90734, 393972, 2 }, -- Shadow Dance has 1 sec increased duration.
    improved_shadow_techniques = { 90736, 394023, 1 }, -- Shadow Techniques generates 3 additional Energy.
    improved_shuriken_storm    = { 90710, 319951, 1 }, -- Shuriken Storm has an additional 15% chance to crit, and its critical strikes apply Find Weakness for 10 sec.
    inevitability              = { 90708, 382512, 1 }, -- Gloomblade and Shadowstrike extend the duration of your Symbols of Death by 0.5 sec.
    invigorating_shadowdust    = { 90706, 382523, 2 }, -- Vanish reduces the remaining cooldown of your other Rogue abilities by 15.0 sec.
    lingering_shadow           = { 90731, 382524, 2 }, -- After Shadow Dance ends, Gloomblade deals an additional 50% damage as Shadow, fading by 2.8% per sec.
    master_of_shadows          = { 90735, 196976, 1 }, -- Gain 25 Energy over 3 sec when you enter Stealth or activate Shadow Dance.
    night_terrors              = { 90711, 277953, 1 }, -- Shuriken Storm reduces enemies' movement speed by 50% for 8 sec.
    perforated_veins           = { 90707, 382518, 2 }, -- Shadowstrike increases the damage of your next Gloomblade by 20%. Max 5 stacks.
    planned_execution          = { 90703, 382508, 2 }, -- Symbols of Death increases your critical strike chance by 5%.
    premeditation              = { 90737, 343160, 1 }, -- After entering Stealth, your next Shadowstrike grants up to 10 sec of Slice and Dice, and generates 2 additional combo points if Slice and Dice is active.
    quick_decisions            = { 90728, 382503, 1 }, -- Shadowstep's cooldown is reduced by 20%, and its maximum range is increased by 20%.
    relentless_strikes         = { 90709, 58423 , 1 }, -- Your finishing moves generate 5 Energy per combo point spent.
    replicating_shadows        = { 90717, 382506, 1 }, -- Rupture deals an additional 20% damage as Shadow and applies to 1 additional enemy within 8 yds.
    sap                        = { 90685, 6770  , 1 }, -- Incapacitates a target not in combat for 1 min. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    secret_stratagem           = { 90722, 394320, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    secret_technique           = { 90715, 280719, 1 }, -- Finishing move that creates shadow clones of yourself. You and your shadow clones each perform a piercing attack on all enemies near your target, dealing Physical damage to the primary target and reduced damage to other targets. 1 point : 1,034 total damage 2 points: 2,068 total damage 3 points: 3,102 total damage 4 points: 4,136 total damage 5 points: 5,170 total damage 6 points: 6,204 total damage Cooldown is reduced by 1 sec for every combo point you spend.
    sepsis                     = { 90704, 385408, 1 }, -- Infect the target's blood, dealing 6,550 Nature damage over 10 sec and gaining 1 use of any Stealth ability. If the target survives its full duration, they suffer an additional 2,377 damage and you gain 1 additional use of any Stealth ability for 10 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
    shadow_blades              = { 90726, 121471, 1 }, -- Draws upon surrounding shadows to empower your weapons, causing your combo point generating abilities to generate 1 additional combo point and deal 50% additional damage as Shadow for 20 sec.
    shadow_focus               = { 90727, 108209, 1 }, -- Abilities cost 15% less Energy while Stealth or Shadow Dance is active.
    shadowed_finishers         = { 90723, 382511, 2 }, -- Eviscerate and Black Powder deal an additional 20% damage as Shadow to targets with your Find Weakness active.
    shadowstep_2               = { 90729, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    shiv                       = { 90740, 5938  , 1 }, -- Attack with your off-hand, dealing 548 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards 1 combo point.
    shot_in_the_dark           = { 90698, 257505, 1 }, -- After entering Stealth or Shadow Dance, your next Cheap Shot is free.
    shrouded_in_darkness       = { 90700, 382507, 1 }, -- Shroud of Concealment increases the movement speed of all party and raid members within its radius by 100%.
    shuriken_tornado           = { 90716, 277925, 1 }, -- Focus intently, then release a Shuriken Storm every sec for the next 4 sec.
    silent_storm               = { 90714, 385722, 1 }, -- Gaining Stealth, Vanish, or Shadow Dance causes your next Shuriken Storm to have 100% increased chance to critically strike.
    stiletto_staccato          = { 90725, 382509, 1 }, -- Shadow Techniques now also reduces the remaining cooldown of Shadow Blades by 1.0 sec.
    swift_death                = { 90701, 394309, 1 }, -- Symbols of Death has 5 sec reduced cooldown.
    the_first_dance            = { 90735, 382505, 1 }, -- Activating Shadow Dance generates 4 combo points.
    the_rotten                 = { 90705, 382015, 1 }, -- After activating Symbols of Death, your next Shadowstrike or Gloomblade deals 50% increased damage, generates 4 additional combo points, and is guaranteed to critically strike.
    veiltouched                = { 90713, 382017, 1 }, -- Your abilities deal 5% increased magic damage.
    weaponmaster               = { 90738, 193537, 1 }, -- Shadowstrike and Backstab have a 15% chance to hit the target twice each time they deal damage.
    without_a_trace            = { 90702, 382513, 1 }, -- Vanish has 1 additional charge.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5529, -- (354406) Cheap Shot grants Slice and Dice for 15 sec and Kidney Shot restores 10 Energy per combo point spent.
    dagger_in_the_dark = 846 , -- (198675) Each second while Stealth is active, nearby enemies within 12 yards take an additional 2% damage from you for 10 sec. Stacks up to 6 times.
    death_from_above   = 3462, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack. You leap into the air and Eviscerate your target on the way back down, with such force that it has a 15% stronger effect.
    dismantle          = 5406, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for 5 sec.
    distracting_mirage = 5411, -- (354661) Distract slows affected enemies by 60% and creates a Mirage that follows an enemy for 8 sec. Reactivate Distract to teleport to your Mirage's location.
    maneuverability    = 3447, -- (197000) Sprint has 50% reduced cooldown and 50% reduced duration.
    shadowy_duel       = 153 , -- (207736) You lock your target into a duel contained in the shadows, removing both of you from the eyes of onlookers for 5 sec. Allows access to Stealth-based abilities.
    silhouette         = 856 , -- (197899) Shadowstep's cooldown is reduced by 67% when cast on a friendly target.
    smoke_bomb         = 1209, -- (359053) Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud.
    thick_as_thieves   = 5409, -- (221622) Tricks of the Trade now increases the friendly target's damage by 15% for 6 sec.
    thiefs_bargain     = 146 , -- (354825) The cooldowns of Shadow Blades, Vanish, and Feint are reduced by 33%, but using one reduces your damage by 10% for 6 sec.
    veil_of_midnight   = 136 , -- (198952) Cloak of Shadows now also removes harmful physical effects and increases dodge chance by 100%.
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


spec:RegisterPack( "Subtlety", 20230603, [[Hekili:n3t)VTTrY(3IrbuKsSv1NoPpyzG06xUxZD9UGt9A)nltlszXlsK6iPCIpyO)2FZSFX9Jzxsf7KwCa9sexUCMzNVNzNC9WR)1RNhhvLC9FF0GrJhC(GX9hb)PHtUEE1d7sUE(UOLFm6o4pKfTf(VZ3FB1MKQhWh8WM8OyCdkZ3xSeE41ZVDF6MQFo76BP31XWA3LSe(5ZhE981PXXj81MuU8654ApBW5Nny8)ZHBM)X0DhU5FUFx1(IKd3KMD4MT73uLEwvuXDjvhU5tRtY0xq5HBYHFiklVADsXHBsYs2(a8BWF8ba(oCJ6ft3S5WnXPWlvKSjQk9(KnWclZZZ6F49hEphmME2WjayaFbynFgECvs0MQ1lwgdFOOLvP4hBtAzfUl)N9PfjBtYQkXD4MZaWFD69M72i2UnCq)HhUz)oK6uQTGXNn8hKlyq)xlxIXkg9g2k(h7Qs3M(FbWpz1Q0LPjzlFqBDtGVgBD)s(9WA2vKSmF7TraC(2nVaiaRJaAXh2)F)VBGN(J5aQDBYQCKeoNJI9VEoIxLStw(pLGhZ)DgZssw0TBG)(pE9Covaw06O48pvwvK(Xe(zzr6o(JMlFFGoMxfXPAhU5NxP(AF)9rzPLRbAkcc73Dk8FkrGrBtHZUCemZswLc4XQI8TWpTgXUOYYuenVnpBpEWKbFP3LI)3Fpj6JzjLLWgMCpYQKcF0pLi(qi9ylEU(tF4WnD3NTbwj(LtZUdOCraEduP3wwI7FwVRNdOe8tPrxpVl8X2VAvFbPP)EGn9Xhf)ihzy)wVd30b2AGZzxYMnl4CFL9lxVhrPSfLv5faACXHBMW3G7JG9hOT93vKMdFUhwuOiz9UUceASO)57aAFsv9bHChW)0M9jO4iatXrzLjl2gTm62IeaSbbA2NDQear(J8f7Ytr(34eKNcOoZoCZioG595J1Ws2NAhkfeNYHAfLbyttwIIzl03jgm862tNGV3B47xv0gquR)g4ScosYUBbNbSVG0GultUWFtqx48r)Ln5aySjkg(7Fpica0dGOCRuJcsUNW1BmvG7aFMaK)uA1AMmfIMIZggph)Dz8K6VcxVeOscxw62i4PRremMDyTGRt9ofabeOmG8HanCEp268UMhuXQq9Qm6jNfnfjuCki70aEWjGQVe2txbIjl(KqkPpGsrPzLS1iiWPB3va6qIxyEwutNTzo4NsdLFhqooEbOAzbJdK9RHpJ5SC1aGjNRKsOP3r)1rk2KNafRljmJOyyG(eou3Zh5yu95bWEGY0vjzYtJM55hxJV1GoIRtFc4Ai6Bn4sR4qHsnd7JQH9BfsziKFEZqUpvgxc76YDam95fWNplgTqvKUScnoP(wlJa4I)xwGwY42ZecBaxpOHgbJxBbggQmExk3QusuXMu0waxYFUalrnjfzGwh0Kv)qFAn4Rgp5sNskMyRK8e0QBf0tsm5nHWK3UPeGYYOvc1FReygAbCYR4ga5ixYNbihDfAI0zjWdLB6oh(AWYr)R2xvMIQnL2(6D0yEyMg84DcZ)jbhAj8DwScDesN7SvSjt8qS(H2CSJeNn5Fcp4TSaGEra(tkCJGdMiyHoOE1CWzJ5Z5gpMdGo4lc6f8XsK8Zba6wFftvLF6JMfY4KKDjfaXTiQc8HFl5IktwwKurTOEEOGdh4XrqnfuMK1)fQkv3UlsGSn8UCtEPGhDDAvfZtmMlAF43qooC1oYqa6bkRb8pEX9jG5lPwkKbyAB0sHkyruY232VgFhsLHdT9Qttwr68mCgTRmTSDFNjECmh)w(9OWyB541ygVMhdxCRLbC6JydFT0XGWE6gW((qBd8TjeeNajkswvKGs5Mbki8KdxrswjlOsmCHLriVzurbgm59OgbWlUv7XyiF3VJY94lWC8ll5ZGy688R4Aj2LdXoGyPoDoSVxcrCUJe5Ba4oRF5dGYGnLlYxTiojcu6wVAyXVHrtByxBXUXOUmxkOjP108k4)bOXQiiACQOcni()ZebtSjjb4FYaQ2973KLuW9mhdxpnPKRiLhXQoRaFxOIcY479ZGY4II97Q4(XlrB(PkO8n)taNz62TmLlP4I5FbLR9q4XAbu9X0LFKYt8AAu69wqWvPiN)HB(FZkaTPL1ooKEpfJqmB5BWDErc7vajikxzBzWELBsxMSayKxed)bAPrsZUMEvzR9wixeNaqpq8sy6S55zrsJrunIfEoZ6xgifCBe7nXtc5NwpUNsaknc4X2L2G4SCxslxGcElaeGfILkaRAATWsxYY15y4IfjGENTanQoKcd89NwNG62reUmjHZ5QjGZYyqQmApm3ci32kMEH5R)vm8W8L94r(9wdisCqz6RIkIj25NdmUyK6q059gf69g7)9gh69M4)9Me69MkyCT9UVzgxAV4SDJD5Y89zk2lKoxKiZdxvk6I6TGg607YYlys3GS(z4rLotb6qr1Y1s1mSdWb9NwYttwcyfdFZiurfyRRkf9GtDKQZ05bKjIQOz03ePBpxl7WWRhW2hFEdS4svq3areIfbI2VAXUn7l7pHz6aOpo2T9kZ1gkuWOveYE)0vLCNWxLwuw1Yq7wgxs5GVszTHQrB2RD7WiFMJRr4iWv8)OwysOIaKKL85DPfsD7kgjU2H)YpDf39wvIFaXIwha0fMkI1sLJPEDDB73TmUpZp5oi56o40t9u4S9CNJEz4ruEYBA8EFg3thm74aQYfCuU7qMB3UOqyCotoQm)uo9cezxIV6oWub3Y7kgTzn)VGh13hLYmc2tly6I9zTiyPAVKbEdd(H6Kxt5HFZcMJMY8awihEF6D5f1YEVeeBgO)8TSKgJowj8CkWA5RyXQ8L7TwMXNmAteINpqTt4kFzlYBQiKA7uIQBtFL0GUWpjw(3v(TXefrgAS2oXjfLgMWfvfPAn6rn4iazinMs4G3wPXONdISThPyLWpMeqqL7C(dUzwWrX7Ea)lYpuaDc1mh8xZmgALwmxGNG7zHqRItStEZBailMUD)wortlOw1VBMGygZgFXsDnr3HIVv6jIboPTZ(YXN8LwL3et9p(Z)FD6iOcrKvrK8YskTs1jjUva0426cB3MtEuV2)z9L)iNyqDZ0rKsy5pnCZm4PoipcZJrfqKUOdaffaXZcT(B5FkbziLbSZ9Fkcdcox6D8B)WFdls3YiM(de(y)Xsg9amlgctqc(qUUpXJksUlHfuWWZ1JkvaL72VP0kQ0)(WxRVWnipx5I)9(472YWhZ1(g91EB0DOEBuKbZXKvSUQkOQI2vbmOtdittj(3m(a2Qa5NcrB4fGfGFS(RlUn)ZA7gXdLXEAhhS5hZxwr2gv8rz5mWG91WLfLjyOxa2cmeeHE5ZPP6Jqrwu4wmP2xo1JZ4fS6Xgz5XKV7hv2CcMQQrwPfTorKUv1WPSH1ElnJ5UKQyUoj9JvwxQt3M9L4efSfWFE8lFcdpAYtBzo4C8zFCTp7SC8s7t)qPMqPIi43oFGRxcmYpilVLxUtwFsiRvUveX2r7kRlk6zrE2lyAd2v)bXufW0hYcNlTYiXammDX6KnWjav6xiSOz8kujKMqmP1BJw(AR4HzqWp3kEapjmTX86wNxWAgjnlUgCqnyOe2jhpYezWr)mGVZM5NXFQQLOMWX24OmrYNuXV4Pyx0p0WvHX9NE9CWqcOIE1ciyhJA9P)bPmfFf(a0i1QZGxTUxxyCVSGl1lQ3ConI3Gj)QScFGMnEgd6hMz8RlIAL4wlKT7)siwgTb81igLt3Pzn(tmFqZ)OSVAoCZ7Wyp6jB2g(M)SsN8zuI3ImoDOb3)zrYD0Zypp)PxXlh)VWlgn3v5O4O)ZEqRK3Qdrwa7lL5)YxP67QNUCEXXQaL2zP)N9jMglgpWwM0z91EEgYk7s4ZT4wqzLtQiZr9V)i(eEEujAjfMdMSmnSBt0dmLQZzGbC0iHdlz1gHwYugmLk9Esuy1MO7WezlqixvRgz713xGNikMQR(sBxSo1dvBna23hwcEgj0THYhezCZGa(b4KuWwP4tb9VNXQsJm18xXCqhfA0iMf7ZY4eZ3bgNqFOqJDwruPIN3sUwNqEsWW(RPGy2raVcentjrIYC8ys81O07PJSIAsXXnutW6O7tSIerLoFUmTktnijcc8ePc8yu)37rvb3HVh4()d9pICBPc7t(rzoCnWmKmk2eF1Us1WeYfOB9H7hIGXAOuYU(WqNH1(8sTJglYOt)0FYc2V0(ATmv6(Lpvq(8uGk9MhTOMvux(f5WNEUgBhRi0KPnSLgP(xM2Amkqx3Ovvm(pHTMSR6v7RPQTnVJNzXkM(VDAS5mNnX)at2LZGByQZGrv1dN(RTQQmjN4JbtOYqyaaC9BbRjubIysX4blgTBPt(gSDQQjw)2XW2LIrQvUl2ZQwZgFc9SipCqOvs04s1m6KjF1FeQGANKfGVpZhIEd5OVxpa0O04fSYV1pkoUuRZeO4MVWNqG88tpnYniZyMIm7GMWMBgbOdAT0Czw6oPk38mLxnBePv5x)1R6F4gM4bxlDm3o(krJixTgBcbmmlfCG6Iz86L1PHxPSok7bC59jZgRFAVdAGfPNJkAnnprrpgpOu232)YQR4I28S)5csbobXD9sUBvNbgGTEA8(IOwOqZOq2ujU9jQWCuyfMdKmHX5vI(2bw1YpYopnBSd(dnu58gxhkzlYwInuQvhnWj8iwiWLKzV8jsnglr3q90tZwfr4EIrBPXCekdli7ILBImRcIztN7eZPjf0ttUQL9CNmYempPn491VZ9P8DNQQYLwmzXGSVuqrz6s4fk6IgRxsB1jcT5lsfXgr2CenTfvQdMivO7VhEdASSJhDTn7Z0ylFPPSgg4qsLF4Jp9fbe1EJrr92FlSDR2FhzRQRLMcv(NjHLUH841m8tn3rjzf6z4mjO1UScTMMePzRKmt8dgq5yHJEWwWYmtElrmu9Pdkc)0xSs0kwypxW2)(VEQgRU9jtpDK3KttJenPjkqRaFHcfF7bbJrxwMKFzyu2qjK2Zzmi(DZNbgSKfSbIfRpRlyAWQqDQkcQ3WsJk3QHw7azkylESzz9gyGu7Yz))yQdTdzWoTzUGKw(xrKDXQ9fpW2Qg6v3WBvsrzsbAnMTv(ZOzZBfePscpNn4o1uAbdTtiFl2)1BwGv)JTD(YE2TWPDoQwBb6p)TjpKJTRNDsdf18JCTgA9C1el5be9oEC0D3bKmk7QMlW148jUUWPTl4DMC3oS3MrrnGKaBceaL0DHAMnRhBewYObYcY4ZAnyopD5I7kstwbB0Y1(OvURRz603ue0xE3q0ba0T29l3v8o0fJHyZMBzz(KLfS9L4wGLCbEN)hzqhCxqQZc8HBUIXLgMm0GohqMNvWe9oP4lQWjbtWJJHJbmdhonBd)LuwMn7rCv)Nu3mRhU5)JvgOd38BeDDA56yZME5lQKG(6CIg9dt1K40o6rTVD8MMcIY(yGA(vT1TfoA3c8zM2vj9e9eIOtKdfiIwc(AkxgIuoAQlJo1k4AOTTJwt1nUlU2V121nSckQ4brnr8LQAEMR2MGy9RSliItsXIULfHnMumwnwrvmI6EjGO(hU5FKTrLFB779aRd8Q3KcSV)G)M)0EdsCj9ZyKMKnRau6ZG1RfrBXo0965tgeiP2(V2I6zfEc3buANtFk8jo3ogKitvxJMLFjY5MD1B(WH6w8PuC2MG36aEHfe5NuCwP0yZA8Cqyb(JX8hX1ppGN1NHc0tuciBTs2TB7r1qYE3OwNL)l16dRrmPKgRrIWv(qzqOvEQpHkDZQ(yu)EkWiNRb(xtszPuarviTsvjpRKHRNxyUbCic3O9mcfb3HvtZrvBNVYNkZAx3X1wci)AV)Gj1tD15LPRvskgsv2cYiJTCHHZ8hVxiUOCpPGPUIxdlH0LD69n0nykP2XkV6u(heihlgMs6IXPosNSsBkXMf3sJvpJuF5fGArzPrgSFqIJnNZTXgFyFPktl0XwwqmWVPYuwWPU9wvleKTWw)hbIiozR3UklM9KS3sw5N)7h3xiTKwQmLYtRNv7ragcrf7XINYl3kVRNUnrvCzwsZt3M4jhFumQUov3cQIvgK9XnHjOUGp(CQZqDJkAVqD(eIExP6y2Vih(fGUzsk1H9gVfftjBqBGReDS)3xNIHaj6)8pO)vofVlc5PXORuL8ouZ9oHWnsyz(gDIQKfEhFy1WNLe40N5ZltWlKiZ6)F9bavZ0vQZrYfoxgUJpGcVPWuftpz)WyKJRg1e05jNgz5aZWWYgxHwlh)jNy4SGl5RDSiNBKBq)DUM)BEJL0zh1vlMFSOuXy2dTeXbqOoWlE1(GHXg90mjQ(rLwOwXk(kpP3VbJMNfmLTmiEKrWtUeVJ6wIwlyC0j)DMkm7qcwTDpGLIW39jl007YSGnqAdMSO1dvnlsZ2nDKQ(y6UfIpfvmoscMCjMQm)Rjj74Try9qwtCb48hWODUbQnVPbln7VphJPijyHH1m)FUJyhripHXZ)PCCaOqtCOV8GqHny4iAtkoW7O1)yIxsbGvI3s(KWTQKb))OJvkFMm7hTHvSJEBYhhv8XfGc(pzMZJMkCkr4lskS3gzC(dzlX0RP1oJIKoA3QIQyWeZkaANLSSx0O7XG6jQOqA7wBeWqnsAs3uFFTfOZRgqX3zsHxLApluiOpSk(6qTltqM2tEgc)oCJr0vMoatFC75A20GV5xWz(iOXK7kM4ZFGnMgKnLYg2aaKjSYChVUprW8yleQpvBSFidOChyvjzB6sEBY4RfLosLgsvKCyJFtHDIHTp41yUeluWLk0booQh1qDR2mT0oP8(pvpsd8VsLCTwSyuTJ)211slDl2Vxj6V4aZdNJKj121wIXrNxd7nQk9yMtD3UbC0g44)um)6Sm04kDLCFA5YKc2CIQgTR4brDpghnSk(CuD6Wj9bz6pfvGDMC51Z)vKViD7U8cz8fVqvIMxOgmPXyGjSz41(Q8TrSXvfyjjJLy43)3y3(xC6K(t5zW3J94xiWm7ll1l4g899yjUdlR7Wp3tT7JP3Dd6M1wtstT33PFL233qVVQuMzTNoPsZE)(HVn7N98(Yg19moWA5UBpOWCaA65iw9UF49e8RIjj0XXT(ABiS(AU1FsF8IUPaoNlaNn2o0dZ5xWHdjcYZdYXHFEKgFY81o0nl)aD2tl)dB9(9eHtpCG1(vzTPUEK5Ck)8tsjpTxgxECh1dPHR6I3AbuUTXTnQojO4RYJsAXxN7culv5(mT7dhqV96jx2ARPs4EB32Nav2VAdSHDDqF9U41zR8CI52cSwBR)EKTTFINa7VqtLVn2O7GS3zYwhQ5Tg804JGNMoDmJY9sH3KYpxJ9yZlQ)yo81Fv(yK6m06pMNfDh6o0AZisumaB6(xlN18SVprr7VvUQ90OPFt31N8jLp1LFXGljBpBYq8SWWxFn)TGk35aHJsMaEsooSNKJpM9Q9ELE49)mJmHBXRpy8p1eiHacCCF168IRNppD7pHLpkFvAD1gk7RgfhVA23RpGso8EQviBFWtXmgpJyeKq)AYMcG8H2xSOtDMoiZgo1Z(AKTFQx800vZ0sxesV(o8FKoEkZzufSOJzWU(Smnr13CCEIY25qtjudOb(beJdnTqzB4Z5m6uhaKjCHZFyunQtzvxzgvLL2V7XhdLcLlNzCf6qe4R0q30pU4zYQGuBH2dVtQfbMRNjZzd7Wie0ZVZhF0yTJ8T2XURDSV1oXDTt8T2Ps2K)4NIM(pqOhgxcATNj11XUzT4WTd9REP(FPdv3DD5OoUA8VaimDorL2sFmDUmu6cfMtdtDK2EAHXrE8FJIyN2FnhQLgQPmvBdu5qs)xOl83jqLPVqmAl7yuO9lp3G8F5SjCta)HmTk1PcwZRsHkt539u(i5JBbZSr6F)39DYg0L7XdivQGr5)SfXVt7e59UeIsHVf(egCEjb)M7MzBk5ihnKbSCypD6eGWOPVsiqAmFnF5ObYF37C1uBncVpngSgVSERTNJM4BoA6l7g2e1KECzWNN5vzZsTAHbISiM9(8fZQlZJnPKbM)HmbkBgP4z)0G3xHiEu0A4BGPfUAQXWx5EhhE8r8YOyQSawzNg)GJBYBLUtoZo(XEnVTtKIth(cMiKntAzB4xaNYZXSCuh6mhCKUa0LG3(VsFQos8YS55O(VBn(g1FKX0Au4))pARaQpJ6W8Gw)O0X00LZg9QUorlYnk5BsbE5SZbwnw7V5oHa7vdph(Mm48CrztnV6J0oHs3tAYhOhF8KUn5ZsNUUXkJE784JeEbnSxhocCX5d65cX1uEdfe6GU7ljNkFbEfHcCzWpQTauX6qNSNnlsAfzFo2jK(Izdb6NGexRGQbDmdRvw88oZ6SXA9m1CQ2LHKRC(eQsIl8rZ(cC49bkDVJ7pLHw)5A605qrSAkbxQYtf)FwgVDUSVmtRsWl2T5EVCSHNYxabE2TX7qayoCqn)R9QK(e98mw6SrP664X4f9adwU)p1Ex0tB8PgTeLLdigPZWEx742xlxoCad9FEgQC2GTXvL7u5nVJdYk)CPVdvDojGJW1kw(Mnu4C15yc3ngHi41ghiaBTd649aZxxfbsMbBGsWLKoDpjqvg6Cc99iL5KPZTDH9lnNZRP9CehPTU4q(yLpSLSUAUDrXcpB451me)rnl2AudmGQDd2j5GUvTZi3Erh0GrDvN18A32EVpUms(eupQ(jjPf)EyWluCrsnTdh4Bfmgyd1rCfV)jA2IzFg6K1FXKCB2W(tP0c7o6eapkD4xVGI1gpC1tGIh(F94iRjFFfMPznskiq30Slhp4mFZ4SwGrE8RJpvwoADfJO1vmOtx35yMgtR5mm7IzVr3Zb8r9OdkF0aBW3jwKJgfg3PR)2dnSU5lMnbcBHd3UnvrVoDP8kUgvnC9IZP9uhdyTXcQhQdTEtlnkmFbPT(0GzSj9AdSfq1ChlH3Wgnh3jKD6Gb34pCgcoY3OYLOZy8Y(JODtIygQAS7MzzyY3XspHtaM3pPoDDsIYGbMwD0eEBYZJX6MIcp8TGDR)RN2HIU1tIeexHHlNnHgpAaWaHiQ3Y6WP75Vme47WrYN7uQqJSgwwKQKWGE8k5yi)Rglw66bnEuDUhh4aA1ZYQ6aljghx2VLASvDmVLAcvDmVe76oRggvhZBA2lbutFkI8nyQlGtODM9uAQAnEeOz(ex)iGv7D4lbQ5BBJDD5i3tptu0EOr1m691gA)oTXiYtAWp5dXlDXksXj0aVwDj(ZYfVUgT4fMWjlGux7wrMafCGKxk9GQ5UyAJFw7lDMrVvyz9QR309WuNs6tYxMT(tMnQhbO7wT3t0C8YL(fM4CENq5CKUUWg8ADmAhOwaTHb22EZlVyyTDsAOSr)c0ZgNRBsbJ)9mVwIb4I8uZIHt7UIPZSDewVXGEPzqB6T6IaN5nH(YbOd4or)nCAVg8GyexR3xWLvMGgjjiOxD18060QhF0Fmg9iIH6ScvtlyWMY6zT2CVJddL0ajN1H4oi7H5wX5mQ9C)Zg2aZrNUknrIBrIkelI4L(YVFWeeiZ0ixtISuY2PHlmmLYeRfgE)vPoQgG08z09wcFPxH6ZeS5FtUoSby5iYJJhwWt8lN0KenzQi6o6L6b)0R9ItFdUrUFrcPT2mXRgoiqUUvbBqvXcL6NgF)xr5KI(nx12oFWdvURiM34wYykdRebzfC1yqaO1xIwHBNTBIEwVtAnFJRTs9H1LQv9ANEYlNHJJ0xr0L8T7BBpBLmQkTv3VeU(YMDsZfYMq1yp6qM0C)qQSaKDj96S5SsOPLWGitNHVHA(lrMp9zNRv5s9v84J2juy8G6mkyo9o71ZUgF)jzAC67yWBDd1NkNZMmGNf6LAdUtF7yPcHX3rwiUjd64MtQJ7eK3ruFtglMTt8YEORr0iUGNo1fm7B80K8zdj0ACUMQ96LDNC2Ox2qbN7fYp4gSVpjm5SvZwYNeHPrsaz)(XtUcNXRDJKYWIx1jPURHiKoax7bP(7eoYq0vP(JolqsZ1p8meA7P8q34Z1ylJCXSFiCqFxGUdq68pr509uKDRrkjRj8AGrRzVMUC4a3scB2UKF1McKTL9Wp3HPrTgrwTAZPF8smhidNXgGWgGKP7(Lz32ZR)Q4rcVh0lKnVzVmSUYZOxgO8Qs2fkmI9Uii4puAJ5RIihHMgspLFnHQBG(izJvTn6ZIluK04TiHK)IOK4VTSe3)SEohrjXQdioiYKF5YJ8vuZ9kCRaRWtyHJjbtQGObYeoSYOi)fv7sE4MVh4qfncP0EJqvjQtIOVSygBe5buCWWB4uEt(JuxtnVQ78bR3kLIaX00gtfW191jDQnjsI5ftPRYfwKlYFFSS8SU52KUXSV41nDGGLXwiPy3dWEzj03adPwkAGqdEk(j4VcZ5BXT8dIQjEXNeSXQCfkaO0T7ka7mXlm)K1DURLVlDSJc7jfWLoo7PPDjX3UwqrZ5DUvHR0GnhA4MSVHjHAkArhVmUaiggEgrdpFDU4egxkemtiPjf1nNOJFOgTCWxe0jIU3YFrR2oO2p0rma8TBkrV6Jwj0STs7wSiVGACyo5ZaqGbnv7eiehv35rSRmEjlejJlNsFpIQTgHAW5chpeB7fcr)M6GnPvHJoA0I1d57fMS4Fh0uk66WvZbdBZNZvVppbVBLVJL2JNeU6jwb1vJqHK1UXznmPQDD0Aoq1R2DFD7wi4BB4s7QkTovKJtMX6p8BUnbTFvrCRb2xndrjYMgwiTf6m(kS92EuuxFvExufEtN0wBs2POJ4ou1YcfE5SxhkdVIC674kNkXQ258G5bcUIKSswUBrh2wInM4YOIcqQhm5vWU8r4n8eE)FhLguxUtEIyzoCRF9)9OsZMAhYSlR1oB0Z6lg(Mob3Lg3HMHu2ab86))p]] )