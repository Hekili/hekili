-- RogueAssassination.lua
-- November 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR

local FindPlayerAuraByID, FindUnitBuffByID, FindUnitDebuffByID = ns.FindPlayerAuraByID, ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local IterateTargets, ActorHasDebuff = ns.iterateTargets, ns.actorHasDebuff
local orderedPairs = ns.orderedPairs

local format = string.format

local spec = Hekili:NewSpecialization( 259 )

spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy, {
    garrote_vim = {
        aura = "garrote",
        debuff = true,

        last = function ()
            local app = state.debuff.garrote.last_tick
            local exp = state.debuff.garrote.expires
            local tick = state.debuff.garrote.tick_time
            local t = state.query_time

            return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
        end,

        stop = function ()
            return state.debuff.poisoned.down
        end,

        interval = function ()
            return state.debuff.garrote.tick_time
        end,

        value = 8
    },
    rupture_vim = {
        aura = "rupture",
        debuff = true,

        last = function ()
            local app = state.debuff.rupture.last_tick
            local exp = state.debuff.rupture.expires
            local tick = state.debuff.rupture.tick_time
            local t = state.query_time

            return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
        end,

        stop = function ()
            return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
        end,

        interval = function ()
            return state.debuff.rupture.tick_time
        end,

        value = 8
    },
    nothing_personal = {
        aura = "nothing_personal_regen",

        last = function ()
            local app = state.buff.nothing_personal_regen.applied
            local exp = state.buff.nothing_personal_regen.expires
            local tick = state.buff.nothing_personal_regen.tick_time
            local t = state.query_time

            return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
        end,

        stop = function ()
            return state.buff.nothing_personal_regen.down
        end,

        interval = function ()
            return state.buff.nothing_personal_regen.tick_time
        end,

        value = 4
    }
} )


-- Talents
spec:RegisterTalents( {
    -- Rogue
    acrobatic_strikes      = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by 3 yds.
    alacrity               = { 90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison        = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 40% chance of poisoning the enemy, reducing their damage by 3.6% for 10 sec.
    blackjack              = { 90696, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    -- cheat_death            = { 90747, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cheat_death            = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows       = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood             = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves        = { 90743, 231719, 1 }, -- Physical damage taken reduced by 3%.
    deadly_precision       = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem       = { 90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand      = { 90639, 385616, 1 }, -- Deal 1,713 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness            = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by 10%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                = { 90764, 5277  , 1 }, -- Increases your dodge chance by 100% for 10 sec.
    find_weakness          = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 15% of that enemy's armor for 10 sec.
    fleet_footed           = { 90762, 378813, 1 }, -- Movement speed increased by 15%.
    gouge                  = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    improved_ambush        = { 90692, 381620, 1 }, -- Ambush generates 1 additional combo point.
    improved_sprint        = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison  = { 90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach           = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison        = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 6% Leech.
    lethality              = { 90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    marked_for_death       = { 90750, 137619, 1 }, -- Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    master_poisoner        = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nightstalker           = { 90693, 14062 , 2 }, -- While Stealth is active, your abilities deal 4% more damage.
    nimble_fingers         = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison         = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 18% for 10 sec.
    prey_on_the_weak       = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    recuperator            = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity     = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges 2 additional combo points.
    reverberation          = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 75%.
    rushed_setup           = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    seal_fate              = { 90757, 14190 , 2 }, -- When you critically strike with a melee attack that generates combo points, you have a 50% chance to gain an additional combo point per critical strike.
    shadow_dance           = { 90689, 185313, 1 }, -- Allows use of all Stealth abilities and grants all the combat benefits of Stealth for 6 sec. Effect not broken from taking damage or attacking.
    shadowrunner           = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep             = { 90695, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    soothing_darkness      = { 90691, 393970, 1 }, -- You are healed for 30% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    subterfuge             = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for 3 sec after Stealth breaks.
    thiefs_versatility     = { 90753, 381619, 2 }, -- Versatility increased by 2%.
    thistle_tea            = { 90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 13.6% for 6 sec.
    tight_spender          = { 90694, 381621, 1 }, -- Energy cost of finishing moves reduced by 10%.
    tricks_of_the_trade    = { 90686, 57934 , 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride     = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                  = { 90759, 14983 , 1 }, -- Increases your maximum Energy by 50 and your Energy regeneration by 10%.
    virulent_poisons       = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.

    -- Assassination
    amplifying_poison      = { 90621, 381664, 1 }, -- Coats your weapons with a Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 40% chance to poison the enemy, dealing 113 Nature damage and applying Amplifying Poison for 12 sec. Envenom can consume 10 stacks of Amplifying Poison to deal 35% increased damage. Max 20 stacks.
    arterial_precision     = { 90784, 400783, 1 }, -- TODO: Shiv strikes 4 additional nearby enemies and increases your Bleed damage done to affected targets by 20% for 8 sec.
    blind                  = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    blindside              = { 90786, 328085, 1 }, -- Ambush and Mutilate have a 20% chance to make your next Ambush free and usable without Stealth. Chance increased to 40% if the target is under 35% health.
    bloody_mess            = { 90625, 381626, 2 }, -- Garrote and Rupture damage increased by 15%.
    crimson_tempest        = { 90632, 121411, 1 }, -- Finishing move that slashes all enemies within 13 yards, dealing instant damage and causing victims to bleed for additional damage. Deals reduced damage beyond 8 targets. Lasts longer per combo point. 1 point : 406 plus 376 over 4 sec 2 points: 609 plus 564 over 6 sec 3 points: 812 plus 752 over 8 sec 4 points: 1,015 plus 940 over 10 sec 5 points: 1,218 plus 1,127 over 12 sec
    cut_to_the_chase       = { 90629, 51667 , 1 }, -- Envenom extends the duration of Slice and Dice by up to 3 sec per combo point spent.
    dashing_scoundrel      = { 90766, 381797, 2 }, -- Envenom also increases the critical strike chance of your poisons by 5%, and their critical strikes generate 1 Energy.
    deadly_poison          = { 90783, 2823  , 1 }, -- Coats your weapons with a Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 40% chance to poison the enemy for 794 Nature damage over 12 sec. Subsequent poison applications will instantly deal 113 Nature damage.
    deathmark              = { 90769, 360194, 1 }, -- Carve a deathmark into an enemy, dealing 4,056 Bleed damage over 16 sec. While marked your Garrote, Rupture, and Lethal poisons applied to the target are duplicated, dealing 100% of normal damage.
    doomblade              = { 90777, 381673, 1 }, -- Mutilate deals an additional 20% Bleed damage over 8 sec.
    dragontempered_blades  = { 90765, 381801, 1 }, -- You may apply 1 additional Lethal and Non-Lethal Poison to your weapons.
    elaborate_planning     = { 90627, 193640, 2 }, -- Your finishing moves grant 4% increased damage done for 4 sec.
    exsanguinate           = { 90779, 200806, 1 }, -- Twist your blades into the target's wounds, causing your Bleed effects on them to bleed out 80% faster.
    fatal_concoction       = { 90626, 392384, 1 }, -- Increases the damage of your weapon poisons by 10%.
    flying_daggers         = { 90631, 381631, 1 }, -- Fan of Knives' radius is increased to 12 yds and deals 15% more damage when it strikes 5 or more targets.
    improved_garrote       = { 90780, 381632, 1 }, -- Garrote deals 50% increased damage and has no cooldown when used from Stealth and for 3 sec after breaking Stealth.
    improved_poisons       = { 90634, 381624, 2 }, -- Increases the application chance of your poisons by 5%.
    improved_shiv          = { 90628, 319032, 1 }, -- Shiv now also increases your Nature damage done against the target by 20% for 8 sec.
    indiscriminate_carnage = { 90774, 381802, 1 }, -- Your next Garrote and your next Rupture apply to up to 8 enemies within 10 yards.
    intent_to_kill         = { 90620, 381630, 1 }, -- Shadowstep's cooldown is reduced by 33% when used on a target afflicted by your Garrote.
    internal_bleeding      = { 90781, 381627, 1 }, -- Kidney Shot also deals up to 1,307 Bleed damage over 6 sec, based on combo points spent.
    iron_wire              = { 90778, 196861, 1 }, -- Garrote silences the target for 6 sec when used from Stealth. Enemies silenced by Garrote deal 15% reduced damage for 8 sec.
    kingsbane              = { 90765, 385627, 1 }, -- Release a lethal poison from your weapons and inject it into your target, dealing 2,324 Nature damage instantly and an additional 2,098 Nature damage over 14 sec. Each time you apply a Lethal Poison to a target affected by Kingsbane, Kingsbane damage increases by 20%. Awards 1 combo point.
    lethal_dose            = { 90624, 381640, 2 }, -- Your weapon poisons, Nature damage over time, and Bleed abilities deal 1% increased damage to targets for each weapon poison, Nature damage over time, and Bleed effect on them.
    lightweight_shiv       = { 90633, 394983, 1 }, -- Shiv has 1 additional charge.
    master_assassin        = { 90623, 255989, 1 }, -- While Stealth is active and for 3 sec after breaking Stealth, your critical strike chance is increased by 30%.
    poison_bomb            = { 90767, 255544, 2 }, -- Envenom has a 4% chance per combo point spent to smash a vial of poison at the target's location, creating a pool of acidic death that deals 1,770 Nature damage over 2 sec to all enemies within it.
    sap                    = { 90685, 6770  , 1 }, -- Incapacitates a target not in combat for 1 min. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    scent_of_blood         = { 90775, 381799, 3 }, -- Each enemy afflicted by your Rupture increases your Agility by 1%, up to a maximum of 24%.
    sepsis                 = { 90622, 385408, 1 }, -- Infect the target's blood, dealing 5,251 Nature damage over 10 sec and gaining 1 use of any Stealth ability. If the target survives its full duration, they suffer an additional 1,933 damage and you gain 1 additional use of any Stealth ability for 10 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
    serrated_bone_spike    = { 90622, 385424, 1 }, -- Embed a bone spike in the target, dealing 2,056 Physical damage and 171 Bleed damage every 2.8 sec until they die or leave combat. Refunds a charge when target dies. Awards 1 combo point plus 1 additional per active bone spike.
    shadowstep_2           = { 90782, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    shiv                   = { 90740, 5938  , 1 }, -- Attack with your poisoned blades, dealing 2,288 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Your Nature damage done to the target is increased by 20% for 8 sec. Awards 1 combo point.
    shrouded_suffocation   = { 90776, 385478, 1 }, -- Increases Garrote damage by 20%. Garrote generates 2 additional combo points when cast from Stealth.
    systemic_failure       = { 90771, 381652, 1 }, -- Garrote increases the damage of Ambush and Mutilate on the target by 20%.
    thrown_precision       = { 90630, 381629, 1 }, -- Fan of Knives's damage is increased by 15%, and it has a 5% increased critical strike chance.
    tiny_toxic_blade       = { 90770, 381800, 1 }, -- Shiv deals 500% increased damage and no longer costs Energy.
    twist_the_knife        = { 90768, 381669, 1 }, -- Envenom duration increased by 2 sec.
    venom_rush             = { 90773, 152152, 1 }, -- Ambush and Mutilate refunds 7 Energy when used against a poisoned target.
    venomous_wounds        = { 90635, 79134 , 1 }, -- You regain 6 Energy each time your Garrote or Rupture deal Bleed damage to a poisoned target. If an enemy dies while afflicted by your Rupture, you regain energy based on its remaining duration.
    vicious_venoms         = { 90772, 381634, 2 }, -- Ambush and Mutilate deal an additional 10% damage as Nature.
    zoldyck_recipe         = { 90785, 381798, 3 }, -- Your Poisons and Bleeds deal 15% increased damage to targets below 35% health.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5530, -- (354406) Cheap Shot grants Slice and Dice for 15 sec and Kidney Shot restores 10 Energy per combo point spent.
    creeping_venom     = 141 , -- (354895) Your Envenom applies Creeping Venom, reducing the target's movement speed by 5% for 4 sec. Creeping Venom is reapplied when the target moves. Max 18 stacks.
    dagger_in_the_dark = 5550, -- (198675) Each second while Stealth is active, nearby enemies within 10 yards take an additional 5% damage from your next Ambush for 10 sec. Stacks up to 8 times.
    death_from_above   = 3479, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack. You leap into the air and Envenom your target on the way back down, with such force that it has a 10% stronger effect.
    dismantle          = 5405, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for 6 sec.
    hemotoxin          = 830 , -- (354124) Shiv also reduces the target's healing received by 40% for 8 sec.
    maneuverability    = 3448, -- (197000) Sprint removes all root effects and suppresses all movement-slowing effects for 4 sec when used.
    smoke_bomb         = 3480, -- (212182) Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud.
    system_shock       = 147 , -- (198145) Casting Envenom with at least 5 combo points on a target afflicted by your Garrote, Rupture, and lethal poison deals 289 Nature damage, and reduces their movement speed by 90% for 2 sec.
    thick_as_thieves   = 5408, -- (221622) Tricks of the Trade now increases the friendly target's damage by 15% for 6 sec.
    veil_of_midnight   = 5517, -- (198952) You remain enveloped by the shadows for 2 sec after Stealth or Vanish fades, increasing dodge chance by 100%.
} )


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


local stealth = {
    rogue            = { "stealth"         , "vanish", "shadow_dance", "subterfuge"                              },
    mantle           = { "stealth"         , "vanish"                                                            },
    sepsis           = { "sepsis_buff"                                                                           },
    improved_garrote = { "improved_garrote"                                                                      },
    all              = { "stealth"         , "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
}

spec:RegisterStateTable( "stealthed", setmetatable( {}, {
    __index = function( t, k )
        if k == "rogue" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
        elseif k == "rogue_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

        elseif k == "mantle" or k == "basic" then
            return buff.stealth.up or buff.vanish.up
        elseif k == "mantle_remains" or k == "basic_remains" then
            return max( buff.stealth.remains, buff.vanish.remains )

        elseif k == "sepsis" then
            return buff.sepsis_buff.up
        elseif k == "sepsis_remains" then
            return buff.sepsis_buff.remains

        elseif k == "improved_garrote" then
            return buff.improved_garrote_buff.up
        elseif k == "improved_garrote_remains" then
            return buff.improved_garrote_buff.remains

        elseif k == "all" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
        elseif k == "remains" or k == "all_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
        end

        return false
    end
} ) )

spec:RegisterStateExpr( "master_assassin_remains", function ()
    if not ( talent.master_assassin.enabled or legendary.mark_of_the_master_assassin.enabled ) then return 0 end
    if stealthed.mantle then return cooldown.global_cooldown.remains + ( legendary.mark_of_the_master_assassin.enabled and 4 or 3 )
    elseif buff.master_assassin_any.up then return buff.master_assassin_any.remains end
    return 0
end )

local stealth_dropped = 0

local function isStealthed()
    return ( FindPlayerAuraByID( 1784 ) or FindPlayerAuraByID( 115191 ) or FindPlayerAuraByID( 115192 ) or FindPlayerAuraByID( 11327 ) or GetTime() - stealth_dropped < 0.2 )
end

local calculate_multiplier = setfenv( function( spellID )
    local mult = 1
    local stealth = isStealthed()

    if stealth then
        if talent.nightstalker.enabled then
            mult = mult * 1.08
        end
    end

    if ( FindPlayerAuraByID( 392401 ) or FindPlayerAuraByID( 392403 ) ) and spellID == 703 then
        mult = mult * 1.5
    end

    return mult
end, state )


-- Bleed Modifiers
local tracked_bleeds = {}

local function NewBleed( key, spellID )
    tracked_bleeds[ key ] = {
        id = spellID,
        exsanguinate = {},
        rate = {},
        last_tick = {},
        haste = {}
    }

    tracked_bleeds[ spellID ] = tracked_bleeds[ key ]
end

local function ApplyBleed( key, target, exsanguinate )
    local bleed = tracked_bleeds[ key ]

    bleed.rate[ target ]         = 1 + ( exsanguinate and 1 or 0 )
    bleed.last_tick[ target ]    = GetTime()
    bleed.exsanguinate[ target ] = exsanguinate
    bleed.haste[ target ]        = 100 + GetHaste()
end

local function UpdateBleed( key, target, exsanguinate )
    local bleed = tracked_bleeds[ key ]

    if not bleed.rate[ target ] then
        return
    end

    if exsanguinate and not bleed.exsanguinate[ target ] then
        bleed.rate[ target ] = bleed.rate[ target ] + 1
        bleed.exsanguinate[ target ] = true
    end

    bleed.haste[ target ] = 100 + GetHaste()
end

local function UpdateBleedTick( key, target, time )
    local bleed = tracked_bleeds[ key ]

    if not bleed.rate[ target ] then return end

    bleed.last_tick[ target ] = time or GetTime()
end

local function RemoveBleed( key, target )
    local bleed = tracked_bleeds[ key ]

    bleed.rate[ target ]         = nil
    bleed.last_tick[ target ]    = nil
    bleed.exsanguinate[ target ] = nil
    bleed.haste[ target ]        = nil
end

local function GetExsanguinateRate( aura, target )
    return tracked_bleeds[ aura ] and tracked_bleeds[ aura ].rate[ target ] or 1
end

NewBleed( "garrote", 703 )
NewBleed( "garrote_deathmark", 360830 )
NewBleed( "rupture", 1943 )
NewBleed( "rupture_deathmark", 360826 )
NewBleed( "crimson_tempest", 121411 )
NewBleed( "internal_bleeding", 154904 )

NewBleed( "deadly_poison_dot", 2823 )
NewBleed( "deadly_poison_dot_deathmark", 394324 )
NewBleed( "sepsis", 328305 )
NewBleed( "serrated_bone_spike", 324073 )

local application_events = {
    SPELL_AURA_APPLIED      = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REFRESH      = true,
}

local removal_events = {
    SPELL_AURA_REMOVED      = true,
    SPELL_AURA_BROKEN       = true,
    SPELL_AURA_BROKEN_SPELL = true,
}

local stealth_spells = {
    [1784  ] = true,
    [115191] = true,
}

local tick_events = {
    SPELL_PERIODIC_DAMAGE   = true,
}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if removal_events[ subtype ] then
            if stealth_spells[ spellID ] then
                stealth_dropped = GetTime()
                return
            end
        end

        if tracked_bleeds[ spellID ] then
            if application_events[ subtype ] then
                -- TODO:  Modernize basic debuff tracking and snapshotting.
                ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                ns.trackDebuff( spellID, destGUID, GetTime(), true )

                ApplyBleed( spellID, destGUID )
                return
            end

            if tick_events[ subtype ] then
                UpdateBleedTick( spellID, destGUID, GetTime() )
                return
            end

            if removal_events[ subtype ] then
                RemoveBleed( spellID, destGUID )
                return
            end
        end

        -- Exsanguinate was used.
        if subtype == "SPELL_CAST_SUCCESS" and spellID == 200806 then
            UpdateBleed( "garrote", destGUID, true )
            UpdateBleed( "rupture", destGUID, true )
            UpdateBleed( "crimson_tempest", destGUID, true )
            UpdateBleed( "internal_bleeding", destGUID, true )
            return
        end
    end

    if death_events[ subtype ] then
        --[[ TODO: Deal with annoying Training Dummy resets.

        RemoveBleed( "garrote", destGUID )
        RemoveBleed( "rupture", destGUID )
        RemoveBleed( "crimson_tempest", destGUID )
        RemoveBleed( "internal_bleeding", destGUID )

        RemoveBleed( "deadly_poison_dot", destGUID )
        RemoveBleed( "sepsis", destGUID )
        RemoveBleed( "serrated_bone_spike", destGUID ) ]]
    end
end, false )


local energySpent = 0

local ENERGY = Enum.PowerType.Energy
local lastEnergy = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "ENERGY" then
        local current = UnitPower( "player", ENERGY )

        if current < lastEnergy then
            energySpent = ( energySpent + lastEnergy - current ) % 30
        end

        lastEnergy = current
        return
    elseif powerType == "COMBO_POINTS" then
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

spec:RegisterStateExpr( "energy_spent", function ()
    return energySpent
end )

spec:RegisterHook( "spend", function( amt, resource )
    if legendary.duskwalkers_patch.enabled and cooldown.vendetta.remains > 0 and resource == "energy" and amt > 0 then
        energy_spent = energy_spent + amt
        local reduction = floor( energy_spent / 30 )
        energy_spent = energy_spent % 30

        if reduction > 0 then
            reduceCooldown( "vendetta", reduction )
        end
    end

    if resource == "combo_points" then
        if buff.flagellation_buff.up then
            if legendary.obedience.enabled then
                reduceCooldown( "flagellation", amt )
            end

            if debuff.flagellation.up then
                stat.mod_haste_pct = stat.mod_haste_pct + amt
            end
        end

        if amt > 0 and talent.elaborate_planning.enabled then
            applyBuff( "elaborate_planning" )
        end

        if amt > 1 and amt < 6 and action.echoing_reprimand.known then
            local er = "echoing_reprimand_" .. amt
            if buff[ er ].up then removeBuff( er ) end
        end
    end
end )


spec:RegisterStateExpr( "persistent_multiplier", function ()
    if not this_action then return 1 end
    local mult = 1

    if buff.stealth.up or buff.subterfuge.up then
        if talent.nightstalker.enabled then
            mult = mult * 1.08
        end
    end

    if buff.improved_garrote.up and this_action == "garrote" then mult = mult * 1.5 end

    return mult
end )




local exsanguinated_spells = {
    garrote = "garrote",
    garrote_deathmark = "garrote_deathmark",
    kidney_shot = "internal_bleeding",
    rupture = "rupture",
    rupture_deathmark = "rupture_deathmark",
    crimson_tempest = "crimson_tempest",

    deadly_poison = "deadly_poison_dot",
    sepsis = "sepsis",
    serrated_bone_spike = "serrated_bone_spike",
}

local true_exsanguinated = {
    "garrote",
    "garrote_deathmark",
    "internal_bleeding",
    "rupture",
    "rupture_deathmark",
    "crimson_tempest",
}

spec:RegisterStateExpr( "exsanguinated", function ()
    local aura = this_action and exsanguinated_spells[ this_action ]
    aura = aura and debuff[ aura ]

    if not aura or not aura.up then return false end
    return aura.exsanguinated_rate > 1
end )

spec:RegisterStateExpr( "will_lose_exsanguinate", function ()
    local aura = this_action and exsanguinated_spells[ this_action ]
    aura = aura and debuff[ aura ]

    if not aura or not aura.up then return false end
    return aura.exsanguinated_rate > 1
end )

spec:RegisterStateExpr( "exsanguinated_rate", function ()
    local aura = this_action and exsanguinated_spells[ this_action ]
    aura = aura and debuff[ aura ]

    if not aura or not aura.up then return 1 end
    return aura.exsanguinated_rate
end )


-- Enemies with either Deadly Poison or Wound Poison applied.
spec:RegisterStateExpr( "poisoned_enemies", function ()
    return ns.countUnitsWithDebuffs( "deadly_poison_dot", "wound_poison_dot", "crippling_poison_dot", "amplifying_poison_dot" )
end )

spec:RegisterStateExpr( "poison_remains", function ()
    return debuff.lethal_poison.remains
end )


local valid_bleeds = { "garrote", "internal_bleeding", "rupture", "crimson_tempest", "mutilated_flesh", "serrated_bone_spike" }

-- Count of bleeds on targets.
spec:RegisterStateExpr( "bleeds", function ()
    local n = 0

    for _, aura in pairs( valid_bleeds ) do
        if debuff[ aura ].up then
            n = n + 1
        end
    end

    return n
end )

-- Count of bleeds on all poisoned (Deadly/Wound) targets.
spec:RegisterStateExpr( "poisoned_bleeds", function ()
    return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "amplifying_poison_dot", "garrote", "internal_bleeding", "rupture" )
end )


spec:RegisterStateExpr( "ss_buffed", function ()
    return false
end )

spec:RegisterStateExpr( "non_ss_buffed_targets", function ()
    return active_enemies
    --[[ local count = ( debuff.garrote.down or not debuff.garrote.exsanguinated ) and 1 or 0

    for guid, counted in ns.iterateTargets() do
        if guid ~= target.unit and counted and ( not ns.actorHasDebuff( guid, 703 ) or not ssG[ guid ] ) then
            count = count + 1
        end
    end

    return count ]]
end )

spec:RegisterStateExpr( "ss_buffed_targets_above_pandemic", function ()
    --[[ if not debuff.garrote.refreshable and debuff.garrote.ss_buffed then
        return 1
    end ]]
    return 0
end )



spec:RegisterStateExpr( "pmultiplier", function ()
    if not this_action then return 0 end

    local a = class.abilities[ this_action ]
    if not a then return 0 end

    local aura = a.aura or this_action
    if not aura then return 0 end

    if debuff[ aura ] and debuff[ aura ].up then
        return debuff[ aura ].pmultiplier or 1
    end

    return 0
end )

spec:RegisterStateExpr( "improved_garrote_remains", function()
    if buff.improved_garrote_buff.up then
        if buff.shadow_dance.up then return buff.shadow_dance.remains end
        return buff.improved_garrote_buff.remains
    end
    return 0
end )

spec:RegisterStateExpr( "priority_rotation", function ()
    return settings.priority_rotation
end )


local ExpireSepsis = setfenv( function ()
    applyBuff( "sepsis_buff" )

    if legendary.toxic_onslaught.enabled then
        applyBuff( "adrenaline_rush", 10 )
        applyBuff( "shadow_blades", 10 )
    end
end, state )


-- Tier Set
spec:RegisterGear( "tier29", 200372, 200374, 200369, 200371, 200373 )
spec:RegisterAura( "septic_wounds", {
    id = 394845,
    duration = 8,
    max_stack = 5
} )


local kingsbaneReady = false

spec:RegisterHook( "reset_precast", function ()
    local status = "Bleed Snapshots       Remains  Multip.  RateMod  Exsang.\n"
    for _, aura in orderedPairs( exsanguinated_spells ) do
        local d = debuff[ aura ]
        d.pmultiplier = nil
        d.exsanguinated_rate = nil
        d.exsanguinated = nil

        if Hekili.ActiveDebug then
            status = format( "%s%-20s  %7.2f  %7.2f  %7.2f  %7s\n", status, aura, d.remains, d.pmultiplier, d.exsanguinated_rate, d.exsanguinated and "true" or "false" )
        end
    end

    if Hekili.ActiveDebug then Hekili:Debug( status ) end

    if debuff.sepsis.up then
        state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    if buff.cold_blood.up then setCooldown( "cold_blood", action.cold_blood.cooldown ) end

    if buff.vanish.up then applyBuff( "stealth" ) end
    -- Pad Improved Garrote's expiry in order to avoid ruining your snapshot.
    if buff.improved_garrote.up then buff.improved_garrote.expires = buff.improved_garrote.expires - 0.05 end

    if buff.indiscriminate_carnage.up then
        if action.garrote.lastCast < action.indiscriminate_carnage.lastCast then applyBuff( "indiscriminate_carnage_garrote" ) end
        if action.rupture.lastCast < action.indiscriminate_carnage.lastCast then applyBuff( "indiscriminate_carnage_rupture" ) end
    end

    if not kingsbaneReady then
        rawset( buff, "kingsbane", buff.kingsbane_buff )
        rawset( debuff, "kingsbane", debuff.kingsbane_dot )
        kingsbaneReady = true
    end
end )

-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if stealthed.mantle and ( not a or a.startsCombat ) then
        if talent.master_assassin.enabled then
            applyBuff( "master_assassin" )
        end

        if talent.subterfuge.enabled then
            applyBuff( "subterfuge" )
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark", 4 )
        end

        if buff.stealth.up then
            setCooldown( "stealth", 2 )
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )

        if buff.improved_garrote.up then
            buff.improved_garrote.expires = query_time + 2.95
        end
    end

    if buff.cold_blood.up and ( not a or a.startsCombat ) then
        removeBuff( "cold_blood" )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
end )


-- Auras
spec:RegisterAuras( {
    -- Talent: Each strike has a chance of inflicting Nature damage and applying Amplification. Envenom consumes Amplification to deal increased damage.
    -- https://wowhead.com/beta/spell=381664
    alacrity = {
        id = 193538,
        duration = 15,
        max_stack = 5,
    },
    amplifying_poison = {
        id = 381664,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Envenom consumes stacks to amplify its damage.
    -- https://wowhead.com/beta/spell=383414
    amplifying_poison_dot = {
        id = 383414,
        duration = 12,
        max_stack = 20
    },
    amplifying_poison_dot_deathmark = {
        id = 394328,
        duration = 12,
        max_stack = 20,
    },
    -- Talent: $w1% reduced damage and healing.
    -- https://wowhead.com/beta/spell=394119
    blackjack = {
        id = 394119,
        duration = 6,
        max_stack = 1
    },
    -- Attacks striking up to $s3 additional nearby enemies.
    -- https://wowhead.com/beta/spell=319606
    blade_flurry = {
        id = 319606,
        duration = 12,
        max_stack = 1,
        copy = 13877
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=2094
    blind = {
        id = 2094,
        duration = 60,
        mechanic = "disorient",
        type = "Ranged",
        max_stack = 1
    },
    blindside = {
        id = 121153,
        duration = 10,
        max_stack = 1,
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=1833
    cheap_shot = {
        id = 1833,
        duration = 4,
        mechanic = "stun",
        max_stack = 1
    },
    -- You have recently escaped certain death.  You will not be so lucky a second time.
    -- https://wowhead.com/beta/spell=45181
    cheated_death = {
        id = 45181,
        duration = 360,
        max_stack = 1
    },
    -- All damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=45182
    cheating_death = {
        id = 45182,
        duration = 3,
        max_stack = 1
    },
    -- Talent: Resisting all harmful spells.
    -- https://wowhead.com/beta/spell=31224
    cloak_of_shadows = {
        id = 31224,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Critical strike chance of your next damaging ability increased by $s1%.
    -- https://wowhead.com/beta/spell=382245
    cold_blood = {
        id = 382245,
        duration = 3600,
        max_stack = 1,
        onRemove = function()
            setCooldown( "cold_blood", action.cold_blood.cooldown )
        end,
    },
    crimson_tempest = {
        id = 121411,
        duration = function () return 2 * ( 1 + effective_combo_points ) end,
        max_stack = 1,
        meta = {
            exsanguinated = function( t ) return t.up and tracked_bleeds.crimson_tempest.exsanguinate[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.crimson_tempest.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.crimson_tempest.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.crimson_tempest.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.crimson_tempest.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    -- Healing for ${$W1}.2% of maximum health every $t1 sec.
    -- https://wowhead.com/beta/spell=354494
    crimson_vial = {
        id = 354494,
        duration = 4,
        type = "Magic",
        max_stack = 1,
        copy = { 212198, 185311 }
    },
    -- Each strike has a chance of poisoning the enemy, slowing movement speed by $3409s1% for $3409d.
    -- https://wowhead.com/beta/spell=3408
    crippling_poison = {
        id = 3408,
        duration = 3600,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=3409
    crippling_poison_dot = {
        id = 3409,
        duration = 12,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed slowed by $s1%.
    -- https://wowhead.com/beta/spell=115196
    crippling_poison_snare = {
        id = 115196,
        duration = 5,
        mechanic = "snare",
        max_stack = 1
    },
    -- Each strike has a chance of causing the target to suffer Nature damage every $2818t1 sec for $2818d. Subsequent poison applications deal instant Nature damage.
    -- https://wowhead.com/beta/spell=2823
    deadly_poison = {
        id = 2823,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Suffering $w1 Nature damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=394324
    deadly_poison_dot = {
        id = 2818,
        duration = function () return 12 * haste end,
        max_stack = 1,
        exsanguinated = false,
        copy = 394324,
        meta = {
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.deadly_poison_dot.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.deadly_poison_dot.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    deadly_poison_dot_deathmark = {
        id = 394324,
        duration = function () return 12 * haste end,
        max_stack = 1,
        exsanguinated = false,
        meta = {
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.deadly_poison_dot_deathmark.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot_deathmark.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.deadly_poison_dot_deathmark.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot_deathmark.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    -- Talent: Bleeding for $w damage every $t sec. Duplicating $@auracaster's Garrote, Rupture, and Lethal poisons applied.
    -- https://wowhead.com/beta/spell=360194
    deathmark = {
        id = 360194,
        duration = 16,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Detecting certain creatures.
    -- https://wowhead.com/beta/spell=56814
    detection = {
        id = 56814,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Damage done increased by $w1%.
    -- https://wowhead.com/beta/spell=193641
    elaborate_planning = {
        id = 193641,
        duration = 4,
        max_stack = 1
    },
    -- Poison application chance increased by $s2%.$?s340081[  Poison critical strikes generate $340426s1 Energy.][]
    -- https://wowhead.com/beta/spell=32645
    envenom = {
        id = 32645,
        duration = function () return ( 1 + effective_combo_points ) + ( 2 * talent.twist_the_knife.rank ) end,
        type = "Poison",
        max_stack = 1
    },
    -- Talent: Dodge chance increased by ${$w1/2}%.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    -- https://wowhead.com/beta/spell=5277
    evasion = {
        id = 5277,
        duration = 10,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=331868
    fancy_footwork = {
        id = 331868,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Damage taken from area-of-effect attacks reduced by $s1%$?$w2!=0[ and all other damage taken reduced by $w2%.  ][.]
    -- https://wowhead.com/beta/spell=1966
    feint = {
        id = 1966,
        duration = 6,
        max_stack = 1
    },
    -- Talent: $w1% of armor is ignored by the attacking Rogue.
    -- https://wowhead.com/beta/spell=316220
    find_weakness = {
        id = 316220,
        duration = 10,
        max_stack = 1
    },
    garrote = {
        id = 703,
        duration = 18,
        max_stack = 1,
        ss_buffed = false,
        meta = {
            duration = function( t ) return t.up and ( 18 * haste / t.exsanguinated_rate ) or class.auras.garrote.duration end,
            exsanguinated = function( t ) return t.up and tracked_bleeds.garrote.exsanguinate[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.garrote.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.garrote.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.garrote.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.garrote.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    garrote_deathmark = {
        id = 360830,
        duration = 18,
        max_stack = 1,
        ss_buffed = false,
        meta = {
            duration = function( t ) return t.up and ( 18 * haste / t.exsanguinated_rate ) or class.auras.garrote_deathmark.duration end,
            exsanguinated = function( t ) return t.up and tracked_bleeds.garrote_deathmark.exsanguinate[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.garrote_deathmark.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.garrote_deathmark.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.garrote_deathmark.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.garrote_deathmark.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    -- Silenced.
    -- https://wowhead.com/beta/spell=1330
    garrote_silence = {
        id = 1330,
        duration = function () return talent.iron_wire.enabled and 6 or 3 end,
        mechanic = "silence",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=1776
    gouge = {
        id = 1776,
        duration = 4,
        mechanic = "incapacitate",
        max_stack = 1
    },
    improved_garrote = {
        id = 392401,
        duration = 3600,
        max_stack = 1,
        copy = { 392403, "improved_garrote_aura", "improved_garrote_buff" }
    },
    -- Talent: Your next Garrote and Rupture apply to $s1 nearby targets.
    -- https://wowhead.com/beta/spell=381802
    indiscriminate_carnage = {
        id = 381802,
        duration = 3600,
        max_stack = 1
    },
    indiscriminate_carnage_garrote = {
        duration = 3600,
        max_stack = 1
    },
    indiscriminate_carnage_rupture = {
        duration = 3600,
        max_stack = 1
    },
    -- Each strike has a chance of poisoning the enemy, inflicting $315585s1 Nature damage.
    -- https://wowhead.com/beta/spell=315584
    instant_poison = {
        id = 315584,
        duration = 3600,
        max_stack = 1
    },
    internal_bleeding = {
        id = 154953,
        duration = 6,
        max_stack = 1,
        meta = {
            exsanguinated = function( t ) return t.up and tracked_bleeds.internal_bleeding.exsanguinate[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.internal_bleeding.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.internal_bleeding.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.internal_bleeding.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.internal_bleeding.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    -- Talent: Damage done reduced by $s1%.
    -- https://wowhead.com/beta/spell=256148
    iron_wire = {
        id = 256148,
        duration = 8,
        max_stack = 1
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=408
    kidney_shot = {
        id = 408,
        duration = function() return ( 1 + effective_combo_points ) end,
        mechanic = "stun",
        max_stack = 1
    },
    -- Talent: Suffering $w4 Nature damage every $t4 sec.
    -- https://wowhead.com/beta/spell=385627
    kingsbane_dot = {
        id = 385627,
        duration = 14,
        max_stack = 1,
        copy = "kingsbane"
    },
    -- Talent: Kingsbane damage increased by $s1%.
    -- https://wowhead.com/beta/spell=394095
    kingsbane_buff = {
        id = 394095,
        duration = 20,
        max_stack = 99
    },
    -- Movement-impairing effects suppressed.
    -- https://wowhead.com/beta/spell=197003
    maneuverability = {
        id = 197003,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Marked for Death will reset upon death.
    -- https://wowhead.com/beta/spell=137619
    marked_for_death = {
        id = 137619,
        duration = 60,
        max_stack = 1
    },
    -- Talent: Critical strike chance increased by $w1%.
    -- https://wowhead.com/beta/spell=256735
    master_assassin = {
        id = 256735,
        duration = 3600,
        max_stack = 1
    },
    -- Damage dealt increased by $w1%.
    -- https://wowhead.com/beta/spell=31665
    master_of_subtlety = {
        id = 31665,
        duration = 3600,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t sec.
    -- https://wowhead.com/beta/spell=381672
    mutilated_flesh = {
        id = 381672,
        duration = 6,
        tick_time = 3,
        mechanic = "bleed",
        max_stack = 1,
        copy = 340431
    },
    -- Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=286581
    nothing_personal = {
        id = 286581,
        duration = 20,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
    },
    nothing_personal_regen = {
        id = 289467,
        duration = 20,
        tick_time = 2,
        max_stack = 1,
    },
    -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    numbing_poison = {
        id = 5761,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Attack and casting speed slowed by $s1%.
    -- https://wowhead.com/beta/spell=5760
    numbing_poison_dot = {
        id = 5760,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Damage taken increased by $s1%.
    -- https://wowhead.com/beta/spell=255909
    prey_on_the_weak = {
        id = 255909,
        duration = 6,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=360826
    rupture = {
        id = 1943,
        duration = function () return 4 * ( 1 + effective_combo_points ) end,
        tick_time = function () return ( debuff.rupture.exsanguinated and 2 or 1 ) * haste end,
        mechanic = "bleed",
        max_stack = 1,
        meta = {
            exsanguinated = function( t ) return t.up and tracked_bleeds.rupture.exsanguinate[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.rupture.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.rupture.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.rupture.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.rupture.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    rupture_deathmark = {
        id = 360826,
        duration = function () return 4 * ( 1 + effective_combo_points ) end,
        tick_time = function () return ( debuff.rupture_deathmark.exsanguinated and 2 or 1 ) * haste end,
        mechanic = "bleed",
        max_stack = 1,
        meta = {
            exsanguinated = function( t ) return t.up and tracked_bleeds.rupture_deathmark.exsanguinate[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.rupture_deathmark.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.rupture_deathmark.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.rupture_deathmark.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod / t.exsanguinated_rate
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.rupture_deathmark.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    -- Talent: Incapacitated.$?$w2!=0[  Damage taken increased by $w2%.][]
    -- https://wowhead.com/beta/spell=6770
    sap = {
        id = 6770,
        duration = 60,
        mechanic = "sap",
        max_stack = 1
    },
    -- Talent: Your Ruptures are increasing your Agility by $w1%.
    -- https://wowhead.com/beta/spell=394080
    scent_of_blood = {
        id = 394080,
        duration = 24,
        max_stack = 24
    },
    -- Talent: Suffering $w1 Nature damage every $t1 sec, and $394026s1 when the poison ends.
    -- https://wowhead.com/beta/spell=385408
    sepsis = {
        id = 385408,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 328305, 375936 },
        exsanguinated = false,
        meta = {
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.sepsis.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.sepsis.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
        },
    },
    sepsis_buff = {
        id = 375939,
        duration = 10,
        max_stack = 1,
        copy = 347037
    },
    -- Bleeding for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=394036
    serrated_bone_spike = {
        id = 394036,
        duration = 3600,
        tick_time = 3,
        max_stack = 1,
        exsanguinated = false,
        meta = {
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.serrated_bone_spike.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.serrated_bone_spike.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
        },
        copy = { "serrated_bone_spike_dot", 324073 }
    },
    -- Talent: Combo point generating abilities generate $s2 additional combo point and deal $s1% additional damage as Shadow.
    -- https://wowhead.com/beta/spell=121471
    shadow_blades = {
        id = 121471,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Access to Stealth abilities.$?$w3!=0[  Movement speed increased by $w3%.][]$?$w4!=0[  Damage increased by $w4%.][]
    -- https://wowhead.com/beta/spell=185422
    shadow_dance = {
        id = 185422,
        duration = 6,
        max_stack = 1,
        copy = 185313
    },
    -- Talent: Movement speed increased by $s2%.
    -- https://wowhead.com/beta/spell=36554
    shadowstep = {
        id = 36554,
        duration = 2,
        max_stack = 1
    },
    -- Energy cost of abilities reduced by $w1%.
    -- https://wowhead.com/beta/spell=112942
    shadow_focus = {
        id = 112942,
        duration = 3600,
        max_stack = 1
    },
    -- Movement speed slowed by $w1%.
    -- https://wowhead.com/beta/spell=206760
    shadows_grasp = {
        id = 206760,
        duration = 8,
        max_stack = 1
    },
    -- Shadowstrike deals $s2% increased damage and has $s1 yds increased range.
    -- https://wowhead.com/beta/spell=245623
    shadowstrike = {
        id = 245623,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: $w1% increased Nature damage taken from $@auracaster.$?${$W2<0}[ Healing received reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=319504
    shiv = {
        id = 319504,
        duration = 8,
        max_stack = 1
    },
    -- Concealing allies within $115834A1 yards in shadows.
    -- https://wowhead.com/beta/spell=114018
    shroud_of_concealment = {
        id = 114018,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Concealed in shadows.
    -- https://wowhead.com/beta/spell=115834
    shroud_of_concealment_buff = {
        id = 115834,
        duration = 2,
        max_stack = 1
    },
    -- Attack speed increased by $w1%.
    -- https://wowhead.com/beta/spell=315496
    slice_and_dice = {
        id = 315496,
        duration = function () return 6 * ( 1 + effective_combo_points ) end,
        max_stack = 1,
    },
    smoke_bomb = {
        id = 212182,
        duration = 5,
        max_stack = 1,
    },
    sprint = {
        id = 2983,
        duration = 8,
        max_stack = 1,
    },
    -- Stealthed.
    -- https://wowhead.com/beta/spell=115191
    stealth = {
        id = 115191,
        duration = 3600,
        max_stack = 1,
        copy = 1784
    },
    -- Damage done increased by 10%.
    -- https://wowhead.com/beta/spell= = {
    symbols_of_death = {
        id = 212283,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Mastery increased by ${$w2*$mas}.1%.
    -- https://wowhead.com/beta/spell=381623
    thistle_tea = {
        id = 381623,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- $s1% increased damage taken from poisons from the casting Rogue.
    -- https://wowhead.com/beta/spell=245389
    toxic_blade = {
        id = 245389,
        duration = 9,
        max_stack = 1
    },
    -- Talent: Threat redirected from Rogue.
    -- https://wowhead.com/beta/spell=57934
    tricks_of_the_trade_target = {
        id = 57934,
        duration = 30,
        max_stack = 1
    },
    -- Talent: All threat transferred from the Rogue to the target.  $?s221622[Damage increased by $221622m1%.][]
    -- https://wowhead.com/beta/spell=59628
    tricks_of_the_trade = {
        id = 59628,
        duration = 6,
        max_stack = 1
    },
    -- Improved stealth.$?$w3!=0[  Movement speed increased by $w3%.][]$?$w4!=0[  Damage increased by $w4%.][]
    -- https://wowhead.com/beta/spell=11327
    vanish = {
        id = 11327,
        duration = 3,
        max_stack = 1
    },
    -- Each strike has a chance of inflicting additional Nature damage to the victim and reducing all healing received for $8680d.
    -- https://wowhead.com/beta/spell=8679
    wound_poison = {
        id = 8679,
        duration = 3600,
        max_stack = 1
    },
    -- Healing effects reduced by $w2%.
    -- https://wowhead.com/beta/spell=8680
    wound_poison_debuff = {
        id = 8680,
        duration = 12,
        max_stack = 3,
        copy = { 394327, "wound_poison_dot" }
    },

    poisoned = {
        alias = { "amplifying_poison_dot", "amplifying_poison_dot_deathmark", "deadly_poison_dot", "deadly_poison_dot_deathmark", "kingsbane_dot", "sepsis", "wound_poison_dot" },
        aliasMode = "longest",
        aliasType = "debuff",
        duration = 3600,
    },
    lethal_poison = {
        alias = { "amplifying_poison", "deadly_poison", "wound_poison", "instant_poison" },
        aliasMode = "shortest",
        aliasType = "buff",
        duration = 3600
    },
    nonlethal_poison = {
        alias = { "atrophic_poison", "numbing_poison", "crippling_poison" },
        aliasMode = "shortest",
        aliasType = "buff",
        duration = 3600
    },

    -- PvP Talents
    creeping_venom = {
        id = 198097,
        duration = 4,
        max_stack = 18,
    },

    system_shock = {
        id = 198222,
        duration = 2,
    },

    -- Legendaries
    bloodfang = {
        id = 23581,
        duration = 6,
        max_stack = 1
    },

    master_assassins_mark = {
        id = 340094,
        duration = 4,
        max_stack = 1
    },

    master_assassin_any = {
        alias = { "master_assassin", "master_assassins_mark" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = function () return legendary.mark_of_the_master_assassin.enabled and 4 or 3 end,
    }
} )


-- Abilities
spec:RegisterAbilities( {
    -- Ambush the target, causing $s1 Physical damage.$?s383281[    Has a $193315s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.][]    |cFFFFFFFFAwards $s2 combo $lpoint:points;$?s383281[ each time it strikes][].|r
    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if buff.blindside.up then return 0 end
            return talent.tight_spender.enabled and 45 or 50
        end,
        spendType = "energy",

        startsCombat = true,
        usable = function () return stealthed.all or buff.audacity.up or buff.blindside.up or buff.sepsis_buff.up, "requires stealth or audacity/blindside/sepsis_buff" end,

        cp_gain = function ()
            return debuff.dreadblades.up and combo_points.max or ( 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + talent.improved_ambush.rank + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) )
        end,

        handler = function ()
            gain( action.ambush.cp_gain, "combo_points" )
            if talent.venom_rush.enabled and debuff.poisoned.up then gain( 7, "energy" ) end

            if buff.blindside.up then removeBuff( "blindside" ) end
            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
            if buff.audacity.up then removeBuff( "audacity" ) end
        end,
    },

    -- Talent: Coats your weapons with a Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 40% chance to poison the enemy, dealing 75 Nature damage and applying Amplification for 12 sec. Envenom can consume 10 stacks of Amplification to deal 35% increased damage. Max 20 stacks.
    amplifying_poison = {
        id = 381664,
        cast = 1.5,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        talent = "amplifying_poison",
        startsCombat = false,
        essential = true,

        handler = function ()
            applyBuff( "amplifying_poison" )
        end,
    },

    -- Talent: Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $h% chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    atrophic_poison = {
        id = 381637,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        talent = "atrophic_poison",
        startsCombat = false,
        essential = true,

        readyTime = function() return buff.atrophic_poison.remains - 120 end,

        handler = function ()
            applyBuff( "atrophic_poison" )
        end,
    },

    -- Talent: Blinds the target, causing it to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    blind = {
        id = 2094,
        cast = 0,
        cooldown = function () return talent.blinding_powder.enabled and 90 or 120 end,
        gcd = "spell",

        talent = "blind",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "blind" )
        end,
    },

    -- Stuns the target for $d.    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if talent.dirty_tricks.enabled then return 0 end
            return ( talent.tight_spender.enabled and 36 or 40 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        startsCombat = true,

        cycle = function ()
            if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
        end,

        usable = function ()
            if target.is_boss then return false, "cheap_shot assumed unusable in boss fights" end
            return stealthed.all or buff.subterfuge.up, "not stealthed"
        end,

        nodebuff = "cheap_shot",

        cp_gain = function () return 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) end,

        handler = function ()
            applyDebuff( "target", "cheap_shot", 4 )

            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

            if talent.prey_on_the_weak.enabled then
                applyDebuff( "target", "prey_on_the_weak" )
            end

            if pvptalent.control_is_king.enabled then
                applyBuff( "slice_and_dice" )
            end

            gain( action.cheap_shot.cp_gain, "combo_points" )
        end,
    },

    -- Talent: Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cloak_of_shadows = {
        id = 31224,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "cloak_of_shadows",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            applyBuff( "cloak_of_shadows" )
        end,
    },

    -- Talent: Increases the critical strike chance of your next damaging ability by $s1%.
    cold_blood = {
        id = 382245,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "physical",

        talent = "cold_blood",
        startsCombat = false,
        nobuff = "cold_blood",

        handler = function ()
            applyBuff( "cold_blood" )
        end,
    },

    -- Drink an alchemical concoction that heals you for $?a354425&a193546[${$O1}.1][$o1]% of your maximum health over $d.
    crimson_vial = {
        id = 185311,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "nature",

        spend = function () return 20 - ( 10 * talent.nimble_fingers.rank ) + conduit.nimble_fingers.mod end,
        spendType = "energy",

        startsCombat = false,
        texture = 1373904,

        handler = function ()
            applyBuff( "crimson_vial" )
        end,
    },

    -- Talent: Finishing move that slashes all enemies within 13 yards, dealing instant damage and causing victims to bleed for additional damage. Deals reduced damage beyond 8 targets. Lasts longer per combo point. 1 point : 325 plus 307 over 4 sec 2 points: 487 plus 460 over 6 sec 3 points: 650 plus 613 over 8 sec 4 points: 812 plus 767 over 10 sec 5 points: 975 plus 920 over 12 sec
    crimson_tempest = {
        id = 121411,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = 30,
        spendType = "energy",

        talent = "crimson_tempest",
        startsCombat = true,
        aura = "crimson_tempest",
        cycle = "crimson_tempest",

        usable = function () return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            applyDebuff( "target", "crimson_tempest", 2 + ( effective_combo_points * 2 ) )
            debuff.crimson_tempest.pmultiplier = persistent_multiplier
            debuff.crimson_tempest.exsanguinated_rate = 1
            debuff.crimson_tempest.exsanguinated = false

            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )

            if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
        end,
    },


    crippling_poison = {
        id = 3408,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,
        texture = 132274,

        readyTime = function () return buff.crippling_poison.remains - 120 end,

        handler = function ()
            applyBuff( "crippling_poison" )
        end,
    },


    deadly_poison = {
        id = 2823,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,
        texture = 132290,


        readyTime = function () return buff.deadly_poison.remains - 120 end,

        handler = function ()
            applyBuff( "deadly_poison" )
        end,
    },

    -- Talent: Carve a deathmark into an enemy, dealing 3,209 Bleed damage over 16 sec. While marked your Garrote, Rupture, and Lethal poisons applied to the target are duplicated, dealing 100% of normal damage.
    deathmark = {
        id = 360194,
        cast = 0,
        cooldown = 120,
        gcd = "totem",
        school = "physical",

        talent = "deathmark",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "deathmark" )
        end,
    },

    -- Throws a distraction, attracting the attention of all nearby monsters for $s1 seconds. Usable while stealthed.
    distract = {
        id = 1725,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "physical",

        spend = function () return 30 * ( talent.rushed_setup.enabled and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        startsCombat = false,
        texture = 132289,

        handler = function ()
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) ) end,

        handler = function ()
            -- Can't predict the Animacharge, unless you have the talent/legendary.
            if legendary.resounding_clarity.enabled or talent.resounding_clarity.enabled then
                applyBuff( "echoing_reprimand_2", nil, 2 )
                applyBuff( "echoing_reprimand_3", nil, 3 )
                applyBuff( "echoing_reprimand_4", nil, 4 )
                applyBuff( "echoing_reprimand_5", nil, 5 )
            end
            gain( action.echoing_reprimand.cp_gain, "combo_points" )
        end,

        copy = { 385616, 323547 },
    },

    -- Finishing move that drives your poisoned blades in deep, dealing instant Nature damage and increasing your poison application chance by 30%. Damage and duration increased per combo point. 1 point : 288 damage, 2 sec 2 points: 575 damage, 3 sec 3 points: 863 damage, 4 sec 4 points: 1,150 damage, 5 sec 5 points: 1,438 damage, 6 sec
    envenom = {
        id = 32645,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "nature",

        spend = 35,
        spendType = "energy",

        startsCombat = true,

        usable = function () return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            if pvptalent.system_shock.enabled then
                if combo_points.current >= 5 and debuff.garrote.up and debuff.rupture.up and ( debuff.deadly_poison_dot.up or debuff.wound_poison_dot.up ) then
                    applyDebuff( "target", "system_shock", 2 )
                end
            end

            if pvptalent.creeping_venom.enabled then
                applyDebuff( "target", "creeping_venom" )
            end

            if talent.cut_to_the_chase.enabled and buff.slice_and_dice.up then
                buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
            end

            applyBuff( "envenom" )
            spend( combo_points.current, "combo_points" )

            if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
        end,
    },

-- Talent: Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    evasion = {
        id = 5277,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "physical",

        talent = "evasion",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "evasion" )
        end,
    },

    -- Talent: Twist your blades into the target's wounds, causing your Bleed effects on them to bleed out 100% faster.
    exsanguinate = {
        id = 200806,
        cast = 0,
        cooldown = 180,
        gcd = "totem",
        school = "physical",

        spend = 25,
        spendType = "energy",

        talent = "exsanguinate",
        startsCombat = true,

        handler = function ()
            local rate

            for i, aura in ipairs( true_exsanguinated ) do
                local deb = debuff[ aura ]

                if deb.up and not deb.exsanguinated then
                    deb.exsanguinated = true

                    rate = deb.exsanguinated_rate
                    deb.exsanguinated_rate = deb.exsanguinated_rate + 1

                    deb.expires = query_time + ( deb.remains * rate / deb.exsanguinated_rate )
                    deb.duration = deb.expires - deb.applied
                end
            end
        end,
    },

    -- Sprays knives at all enemies within 18 yards, dealing 544 Physical damage and applying your active poisons at their normal rate. Deals reduced damage beyond 8 targets. Awards 1 combo point.
    fan_of_knives = {
        id = 51723,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        cycle = function () return buff.deadly_poison.up and "deadly_poison_dot" or buff.amplifying_poison.up and "amplifying_poison_dot" or nil end,

        handler = function ()
            gain( 1, "combo_points" )
            removeBuff( "hidden_blades" )
            if buff.deadly_poison.up then
                applyDebuff( "target", "deadly_poison_dot" )
                active_dot.deadly_poison_dot = min( active_enemies, active_dot.deadly_poison_dot + 8 )
            elseif buff.amplifying_poison.up then
                applyDebuff( "target", "amplifying_poison_dot" )
                active_dot.amplifying_poison_dot = min( active_enemies, active_dot.amplifying_poison_dot + 8 )
            end
        end,
    },

    -- Talent: Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by $s1% $?s79008[and all other damage taken by $s2% ][]for $d.
    feint = {
        id = 1966,
        cast = 0,
        cooldown = 15,
        gcd = "totem",
        school = "physical",

        spend = function () return talent.nimble_fingers.enabled and 25 or 35 + conduit.nimble_fingers.mod end,
        spendType = "energy",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            applyBuff( "feint" )
        end,
    },

    -- Garrote the enemy, causing 2,407 Bleed damage over 18 sec. Awards 1 combo point.
    garrote = {
        id = 703,
        cast = 0,
        cooldown = function () return buff.improved_garrote.up and 0 or 6 end,
        gcd = "totem",
        school = "physical",

        spend = 45,
        spendType = "energy",

        startsCombat = true,
        aura = "garrote",
        cycle = "garrote",

        cp_gain = function() return ( stealthed.rogue or stealthed.improved_garrote ) and talent.shrouded_suffocation.enabled and 3 or 1 end,

        handler = function ()
            applyDebuff( "target", "garrote" )
            debuff.garrote.pmultiplier = persistent_multiplier
            debuff.garrote.exsanguinated_rate = 1
            debuff.garrote.exsanguinated = false

            if debuff.deathmark.up then
                applyDebuff( "target", "garrote_deathmark" )
                debuff.garrote_deathmark.pmultiplier = persistent_multiplier * ( buff.improved_garrote.up and 1.5 or 1 )
                debuff.garrote_deathmark.exsanguinated_rate = 1
                debuff.garrote_deathmark.exsanguinated = false
            end

            if buff.indiscriminate_carnage_garrote.up then
                active_dot.garrote = min( true_active_enemies, active_dot.garrote + 8 )
                removeBuff( "indiscriminate_carnage_garrote" )
                if buff.indiscriminate_carnage_rupture.down then
                    removeBuff( "indiscriminate_carnage" )
                    setCooldown( "indiscriminate_carnage", action.indiscriminate_carnage.cooldown )
                end
            end

            gain( action.garrote.cp_gain, "combo_points" )

            if stealthed.rogue then
                if talent.iron_wire.enabled then
                    applyDebuff( "target", "garrote_silence" )
                    applyDebuff( "target", "iron_wire" )
                end
                if azerite.shrouded_suffocation.enabled then
                    debuff.garrote.ss_buffed = true
                end
            end
        end,
    },

    -- Talent: Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.    Must be in front of your target.    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    gouge = {
        id = 1776,
        cast = 0,
        cooldown = 20,
        gcd = "totem",
        school = "physical",

        spend = function () return talent.dirty_tricks.enabled and 0 or 25 end,
        spendType = "energy",

        talent = "gouge",
        startsCombat = true,

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) ) end,

        handler = function ()
            applyDebuff( "target", "gouge" )
            gain( action.gouge.cp_gain, "combo_points" )
        end,
    },

    -- Talent: Your next Garrote and your next Rupture apply to up to 8 enemies within 10 yards.
    indiscriminate_carnage = {
        id = 381802,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "physical",

        talent = "indiscriminate_carnage",
        startsCombat = false,
        nobuff = "indiscriminate_carnage",

        handler = function ()
            applyBuff( "indiscriminate_carnage" )
            applyBuff( "indiscriminate_carnage_garrote" )
            applyBuff( "indiscriminate_carnage_rupture" )
        end,
    },

    instant_poison = {
        id = 315584,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,
        texture = 132273,

        readyTime = function () return buff.instant_poison.remains - 120 end,

        handler = function ()
            applyBuff( "instant_poison" )
        end,
    },

    -- A quick kick that interrupts spellcasting and prevents any spell in that school from being cast for 5 sec.
    kick = {
        id = 1766,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end
    },


    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = function () return ( talent.rushed_setup.enabled and 20 or 25 ) * ( 1 - 0.1 * talent.tight_spender.rank ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        startsCombat = true,
        aura = "internal_bleeding",
        cycle = "internal_bleeding",

        usable = function ()
            if target.is_boss then return false, "kidney_shot assumed unusable in boss fights" end
            return combo_points.current > 0, "requires combo points"
        end,

        handler = function ()
            applyDebuff( "target", "kidney_shot", 1 + combo_points.current )
            if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity" ) end
            if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            if talent.internal_bleeding.enabled then
                applyDebuff( "target", "internal_bleeding" )
                debuff.internal_bleeding.pmultiplier = persistent_multiplier
                debuff.internal_bleeding.exsanguinated = false
                debuff.internal_bleeding.exsanguinated_rate = 1
            end

            if pvptalent.control_is_king.enabled then
                gain( 10 * combo_points.current, "energy" )
            end

            spend( combo_points.current, "combo_points" )
        end,
    },

    -- Talent: Release a lethal poison from your weapons and inject it into your target, dealing 1,770 Nature damage instantly and an additional 1,648 Nature damage over 14 sec. Each time you apply a Lethal Poison to a target affected by Kingsbane, Kingsbane damage increases by 20%. Awards 1 combo point.
    kingsbane = {
        id = 385627,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "nature",

        spend = 35,
        spendType = "energy",

        talent = "kingsbane",
        startsCombat = false,

        cp_gain = 1,

        handler = function ()
            applyDebuff( "target", "kingsbane_dot" )
            gain( action.kingsbane.cp_gain, "combo_points" )
        end,
    },

    -- Talent: Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    marked_for_death = {
        id = 137619,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "physical",

        talent = "marked_for_death",
        startsCombat = false,
        texture = 236364,

        toggle = "cooldowns",

        usable = function ()
            return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
        end,

        cp_gain = function () return 5 end,

        handler = function ()
            gain( action.marked_for_death.cp_gain, "combo_points" )
        end,
    },

    -- Attack with both weapons, dealing a total of 649 Physical damage. Awards 2 combo points.
    mutilate = {
        id = 1329,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = 50,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            gain( 2, "combo_points" )
            if talent.venom_rush.enabled and debuff.poisoned.up then gain( 7, "energy" ) end

            if talent.doomblade.enabled or legendary.doomblade.enabled then
                applyDebuff( "target", "mutilated_flesh" )
            end
        end,
    },

    -- Throws a poison-coated knife, dealing 171 damage and applying your active Lethal and Non-Lethal Poisons. Awards 1 combo point.
    poisoned_knife = {
        id = 185565,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = 40,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
        end,
    },

    -- Coats your weapons with a Non-Lethal Poison that lasts for 1 hour.  Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    numbing_poison = {
        id = 5761,
        cast = 1,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,
        texture = 136066,

        readyTime = function () return buff.numbing_poison.remains - 120 end,

        handler = function ()
            applyBuff( "numbing_poison" )
        end,
    },

    -- Finishing move that tears open the target, dealing Bleed damage over time. Lasts longer per combo point. 1 point : 1,250 over 8 sec 2 points: 1,876 over 12 sec 3 points: 2,501 over 16 sec 4 points: 3,126 over 20 sec 5 points: 3,752 over 24 sec
    rupture = {
        id = 1943,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        aura = "rupture",
        cycle = "rupture",

        usable = function () return combo_points.current > 0, "requires combo_points" end,
        handler = function ()
            removeBuff( "masterful_finish" )

            applyDebuff( "target", "rupture" )
            debuff.rupture.pmultiplier = persistent_multiplier
            debuff.rupture.exsanguinated = false
            debuff.rupture.exsanguinated_rate = 1

            if debuff.deathmark.up then
                applyDebuff( "target", "rupture_deathmark" )
                debuff.rupture_deathmark.pmultiplier = persistent_multiplier
                debuff.rupture_deathmark.exsanguinated = false
                debuff.rupture_deathmark.exsanguinated_rate = 1
            end

            if buff.indiscriminate_carnage_rupture.up then
                active_dot.rupture = min( true_active_enemies, active_dot.rupture + 8 )
                removeBuff( "indiscriminate_carnage_rupture" )
                if buff.indiscriminate_carnage_garrote.down then
                    removeBuff( "indiscriminate_carnage" )
                    setCooldown( "indiscriminate_carnage", action.indiscriminate_carnage.cooldown )
                end
            end

            if buff.finality_rupture.up then removeBuff( "finality_rupture" )
            elseif talent.finality.enabled then applyBuff( "finality_rupture" ) end

            if talent.scent_of_blood.enabled or azerite.scent_of_blood.enabled then
                applyBuff( "scent_of_blood", dot.rupture.remains, active_dot.rupture )
            end

            spend( combo_points.current, "combo_points" )
        end,
    },


    sap = {
        id = 6770,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return ( talent.dirty_tricks.enabled and 0 or 35 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
        spendType = "energy",

        talent = "sap",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "sap" )
        end,
    },

    -- Talent: Infect the target's blood, dealing $o1 Nature damage over $d. If the target survives its full duration, they suffer an additional $328306s1 damage and you gain $s6 use of any Stealth ability for $347037d.    Cooldown reduced by $s3 sec if Sepsis does not last its full duration.    |cFFFFFFFFAwards $s7 combo $lpoint:points;.|r
    sepsis = {
        id = function() return talent.sepsis.enabled and 385408 or 328305 end,
        cast = 0,
        cooldown = 90,
        gcd = "totem",
        school = "nature",

        spend = 25,
        spendType = "energy",

        startsCombat = true,

        toggle = "cooldowns",

        cp_gain = function() return debuff.dreadblades.up and combo_points.max or ( 1 + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) ) end,

        handler = function ()
            applyBuff( "sepsis_buff" )
            applyDebuff( "target", "sepsis" )
            debuff.sepsis.exsanguinated_rate = 1
            gain( action.sepsis.cp_gain, "combo_points" )
        end,

        copy = { 385408, 328305 }
    },

    -- Talent: Embed a bone spike in the target, dealing 1,696 Physical damage and 141 Bleed damage every 2.8 sec until they die or leave combat. Refunds a charge when target dies. Awards 1 combo point plus 1 additional per active bone spike.
    serrated_bone_spike = {
        id = function() return talent.serrated_bone_spike.enabled and 385424 or 328547 end,
        cast = 0,
        charges = function () return legendary.deathspike.equipped and 5 or 3 end,
        cooldown = 30,
        recharge = 30,
        gcd = "totem",
        school = "physical",

        spend = 15,
        spendType = "energy",

        startsCombat = true,
        cycle = "serrated_bone_spike",

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike ) end,

        handler = function ()
            applyDebuff( "target", "serrated_bone_spike" )
            debuff.serrated_bone_spike.exsanguinated_rate = 1
            gain( action.serrated_bone_spike.cp_gain, "combo_points" )
            if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
        end,

        copy = { 385424, 328547 }
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

        usable = function () return not stealthed.all, "not used in stealth" end,
        handler = function ()
            applyBuff( "shadow_dance" )

            if talent.danse_macabre.enabled then applyBuff( "danse_macabre" ) end
            if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows" ) end
            if talent.premeditation.enabled then applyBuff( "premeditation" ) end
            if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
            if talent.silent_storm.enabled then applyBuff( "silent_storm" ) end

            if azerite.the_first_dance.enabled then
                gain( 2, "combo_points" )
                applyBuff( "the_first_dance" )
            end
        end,
    },

    -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    shadowstep = {
        id = 36554,
        cast = 0,
        charges = function()
            if talent.shadowstep.enabled and talent.shadowstep_2.enabled then return 2 end
        end,
        cooldown = function() return 30 * ( 1 - 0.333 * talent.intent_to_kill.rank ) end,
        recharge = function()
            if talent.shadowstep.enabled and talent.shadowstep_2.enabled then return 30 * ( 1 - 0.333 * talent.intent_to_kill.rank ) end
        end,
        gcd = "off",

        talent = "shadowstep",
        startsCombat = false,
        texture = 132303,

        handler = function ()
            applyBuff( "shadowstep" )
            setDistance( 5 )
        end,
    },

    -- Talent: Attack with your poisoned blades, dealing 319 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Your Nature damage done against the target is increased by 20% for 8 sec. Awards 1 combo point.
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

    -- Extend a cloak that shrouds party and raid members within 30 yards in shadows, providing stealth for 15 sec.
    shroud_of_concealment = {
        id = 114018,
        cast = 0,
        cooldown = 360,
        gcd = "totem",
        school = "physical",

        startsCombat = false,

        toggle = "interrupts",

        usable = function() return stealthed.all, "requires stealth" end,
        handler = function ()
            applyBuff( "shroud_of_concealment" )
        end,
    },

    -- Finishing move that consumes combo points to increase attack speed by 50%. Lasts longer per combo point. 1 point : 12 seconds 2 points: 18 seconds 3 points: 24 seconds 4 points: 30 seconds 5 points: 36 seconds
    slice_and_dice = {
        id = 315496,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function() return talent.tight_spender.enabled and 22.5 or 25 end,
        spendType = "energy",

        startsCombat = false,
        texture = 132306,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity" )
            end
            applyBuff( "slice_and_dice" )
            spend( combo_points.current, "combo_points" )
        end,
    },

    -- Increases your movement speed by 70% for 8 sec. Usable while stealthed.
    sprint = {
        id = 2983,
        cast = 0,
        cooldown = function () return talent.improved_sprint.enabled and 60 or 120 end,
        gcd = "off",

        startsCombat = false,
        texture = 132307,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "sprint" )
        end,
    },

    -- Conceals you in the shadows until cancelled, allowing you to stalk enemies without being seen.
    stealth = {
        id = 1784,
        cast = 0,
        cooldown = 2,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        texture = 132320,

        usable = function ()
            if time > 0 then return false, "cannot stealth in combat"
            elseif buff.stealth.up then return false, "already in stealth"
            elseif buff.vanish.up then return false, "already vanished" end
            return true
        end,

        handler = function ()
            applyBuff( "stealth" )

            if talent.improved_garrote.enabled then applyBuff( "improved_garrote" ) end
            if talent.premeditation.enabled then applyBuff( "premeditation" ) end
            if talent.silent_storm.enabled then applyBuff( "silent_storm" ) end
            if talent.take_em_by_surprise.enabled and buff.take_em_by_surprise.down then
                applyBuff( "take_em_by_surprise" )
                stat.haste = state.haste + 0.1
            end

            if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
            if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
        end,

        copy = 115191
    },

    -- Talent: Restore 100 Energy. Mastery increased by 13.6% for 6 sec.
    thistle_tea = {
        id = 381623,
        cast = 0,
        charges = 3,
        cooldown = 60,
        recharge = 60,
        icd = 1,
        gcd = "off",
        school = "physical",

        spend = -100,
        spendType = "energy",

        talent = "thistle_tea",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "thistle_tea" )
        end,
    },

    -- Talent: Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    tricks_of_the_trade = {
        id = 57934,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "tricks_of_the_trade",
        startsCombat = false,

        usable = function() return group, "requires an ally" end,

        handler = function ()
            applyBuff( "tricks_of_the_trade" )
        end,
    },

    -- Allows you to vanish from sight, entering stealth while in combat. For the first 3 sec after vanishing, damage and harmful effects received will not break stealth. Also breaks movement impairing effects.
    vanish = {
        id = 1856,
        cast = 0,
        charges = 1,
        cooldown = 120,
        recharge = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132331,

        disabled = function ()
            return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
        end,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "vanish" )
            applyBuff( "stealth" )

            if talent.improved_garrote.enabled then applyBuff( "improved_garrote" ) end
            if talent.invigorating_shadowdust.enabled then
                for name, cd in pairs( cooldown ) do
                    if cd.remains > 0 then reduceCooldown( name, 15 * talent.invigorating_shadowdust.rank ) end
                end
            end
            if talent.premeditation.enabled then applyBuff( "premeditation" ) end
            if talent.silent_storm.enabled then applyBuff( "silent_storm" ) end
            if talent.take_em_by_surprise.enabled and buff.take_em_by_surprise.down then
                applyBuff( "take_em_by_surprise" )
                stat.haste = state.haste + 0.1
            end

            if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
            if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
        end,
    },


    wound_poison = {
        id = 8679,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,
        texture = 134197,

        readyTime = function () return buff.wound_poison.remains - 120 end,

        handler = function ()
            applyBuff( "wound_poison" )
        end,
    },

    -- TODO: Dragontempered Blades allows for 2 Lethal Poisons and 2 Non-Lethal Poisons.
    apply_poison_actual = {
        name = "|cff00ccff[" .. _G.MINIMAP_TRACKING_VENDOR_POISON .. "]|r",
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,

        next_poison = function()
            if buff.lethal_poison.down or talent.dragontempered_blades.enabled and buff.lethal_poison.stack < 2 then
                if talent.amplifying_poison.enabled and buff.amplifying_poison.down then return "amplifying_poison"
                elseif action.deadly_poison.known and buff.deadly_poison.down then return "deadly_poison"
                elseif action.instant_poison.known and buff.instant_poison.down then return "instant_poison"
                elseif action.wound_poison.known and buff.wound_poison.down then return "wound_poison" end

            elseif buff.nonlethal_poison.down or talent.dragontempered_blades.enabled and buff.nonlethal_poison.stack < 2 then
                if talent.atrophic_poison.enabled and buff.atrophic_poison.down then return "atrophic_poison"
                elseif action.numbing_poison.known and buff.numbing_poison.down then return "numbing_poison"
                elseif action.crippling_poison.known and buff.crippling_poison.down then return "crippling_poison" end

            end

            return "apply_poison_actual"
        end,

        texture = function ()
            local np = action.apply_poison_actual.next_poison
            if np == "apply_poison_actual" then return 136242 end
            return action[ np ].texture
        end,

        bind = function ()
            return action.apply_poison_actual.next_poison
        end,

        readyTime = function ()
            if action.apply_poison_actual.next_poison ~= "apply_poison_actual" then return 0 end
            return 0.01 + min( buff.lethal_poison.remains, buff.nonlethal_poison.remains )
        end,

        handler = function ()
            applyBuff( action.apply_poison_actual.next_poison )
        end,

        copy = "apply_poison"
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "phantom_fire",

    package = "Assassination",
} )


spec:RegisterSetting( "priority_rotation", false, {
    name = "Funnel AOE -> Target",
    desc = "If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present.",
    type = "toggle",
    width = 1.5
} )

spec:RegisterSetting( "envenom_pool_pct", 50, {
    name = "Energy % for |T132287:0|t Envenom",
    desc = "If set above 0, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = 1.5
} )

spec:RegisterStateExpr( "envenom_pool_deficit", function ()
    return energy.max * ( ( 100 - ( settings.envenom_pool_pct or 100 ) ) / 100 )
end )

spec:RegisterSetting( "mfd_points", 3, {
    name = "|T236340:0|t Marked for Death Combo Points",
    desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
    type = "range",
    min = 0,
    max = 5,
    step = 1,
    width = "full"
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
    get = function () return not Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled = not val
    end,
} )


spec:RegisterPack( "Assassination", 20230128, [[Hekili:T3ZAZTTTw(BrtNLrYpuKOLstZ1sDst6Ut792oDQ9E3VzjAjklUHIuljLt8D0OF775GxeaeaK6HDtVt)q7elccCEHZBaEx)7U9UBMhueE3V63Z)QE99FBx)(d8hC3nfpTo8UBwhm7tbpa)JKGvW))955b55rjbfrPj4tFkonyooj5PBYMbJyzrX68396x)quXYn33Dw6QxNhTAtm5nMLfSOa)7zV(UBUFtuCXpLC39gHGRE7D3eSPyzA2D3Ct0QpaZC085H0HhMp7UBU7M4O8ICYIxegexSmeHKFLGtHjb3hd)9paZYmkWgLmpkFww0ke8dNmlilHGz4SLfTMoOB4Z0UPVN8E53Dd80IWSOayDwhghpPii7HWI8UlcsMKUyYNsIEmmF30X7Mctvuw4C(i2nD72DtR7L6VBQ3UPzbrZNe(yysr3G5ZZ7gLqE4B6DxbqzSGspeKLLcKUBM90S4q(AGKazGMJsDJwTol9ra(yVhzHBTB6NJaamonpCs4xYdsEydHcrEABaYcxfeLaW61aS6VB6R3nvEyZNKrgmIQRbgDr064OWmy4Ji4whY8qbTUfrRaWmDY8i4nUuAUbu1xJv8tmOD30)lk4(oGNSED8t7MMct)VhUilmFjc9fW))(nlwin2CKSDvDKn3R3UPNVB6p(L8hGfe4g9V9DsRQymbfa2Te(hHjWRMUay4uco8ZP7Mcy9UPRc(ciCSjJSjaG1WfPzHK5wqgL5yfbXOCGmvUldnieZA4OiA(iWltcxfHYyJ4Yy7hR(ThiR(XaajayLb)tYFkz2e9zggNoSRoMUxbCWI7U5XGKO8LU2xZgHX9X7M(H0045PFgN2Dt)NKHUB6naiTB6cumYaxNkq9XWGILRcY(KboJoORWDMXwXU8hUznN6ppeftfpqH2Y5bZtledWergj(YJjJkrIRpNd0wSsZ5ibbiWxvaDLpsMUpGphGI77tNSonkbuAnpCr0SiqqE8iYS7wL23tNgxkUmYZ4ChkFrrBnWhPQRP79nW0WTH(xE15Cvn5)5JTvNHcyvUIO1KJognOvIucHHwn(vuKqSm4SWG5pX4V20W6K)s3F9lbGAmG(WDPavUUzDXMSWZfm1KuGRIwcZ4QDZakF4feLPrjpiTl9CW)Gh7Y3AtxIBcxNhb0UfaceVB6sucocuqVofwqudLSmIerYLycBmRiq)KagWRmKwuoDgfBu50E6sbL2)UI(utBCv2tNJikF7CLHRTzMl2LtifG93zFIq36iaf2tKFpu17VoqJ1(YTBQUTshTgU6gfXVRtOIqX2cqkawZjZdsaxLbA8qlBFugNMHnYJabF8z)LnmtCy0j16g2PMfdmZ3C0mZ)sXOdfJhQaHcN(LwlAbYWxea7am5bRISWVhkIBqMvaWCcegXJBItcZOKkHJ9Oaak7guiRJHolU8(6ta8Rh8tcW1qgdnwhobLgdtqCmkLcXTVIG2r4GPtwoxKQyzqHMutzykWeyYBH01a4gwi72an0b8FfVjSMaUVMeZi8otOjNae3EqefSjty1VEaPn7HNa24dHjtqsBuck7IcHd1OyFq80FK8sySHWBb7nddNJ)ms5YdkWO(cLbt6KZFYCt2byaA0czkAnc5IhRe2OyeE1Q2Cr0dll4bHPHS)A4xkuJxvrgbIQhIQnihrBu8rO8bOaGAhIqtC6drGcOamkz6Iq(zYQwgCSmHYq8JwzDtcJZdLOrMiccUSDcHj94MYKsw6dBybcBpy8sGDgSbyc9pMGjTIM6kUyRi5vWI)Tw2Y6CgMnNa4V1MbO4OzHtac)K5rvmb9BBaQ)njFC3uuziWukIGL6jMNfFaFkkitYWXhwcS4lKm6q36)JjpgMKUIQ3cJdJOTOKJQOuGQ8vbI4oxiBgMA(LziV0c0Snfy6JaOzYmeyumVOBpP68najtFxDo26CrCa)MEK8gSHwHkbRkKskrWSFVdruaSfrEzBjlX9lhLfoJ((6MokjsmvKkUj1Fijxzg1EwU2bzZcsW0)LLbKzYYqSiO981BiBLlxCCGdKhymQZiFY)7M5pScNjTXouES3h8aAZOidS5LRos4fxdimXaATMN)XVecYfOqap7D0xe)7haoCxmHXZcxJm1K0KlxgKTAXMyA24i2jttIFQRe2IPYeLdYH)YHXAu9eOtbwZje1vY8cljngOaLy2KC4FKaAiUPFV92imxvmq(s(uybvxCECQIPE2d7w0VlSDzsEraaojpnz(6C5mqWhLVHrH7YLMMsf0ICMIIzstHHr0rJJ9Xqa(ahwqhRxgnduu1MOGk5PoOwBcRd2XkMwyy4qdsyQ8ckkcxTM9h5sEplSU1vyrP)H5UHVrYOjcuvYOjITcz0irACD05oUz72DwXbAoB9KvbFzc4mhA8)6VNGlmLTGg70njZbFbMmlgEXINkv3E2UPFRt(kYprMw(Y0nXKTM0)BgeecX7I0nGrmyRWLQUUWINsyaB2YuYW)9W1zrRiUO8HFRQRi0xFcl(LjZwlCxq35Bvns2mQRBywAJDPPmZBLzXwqvy7i54CdkAKqY7b2OdwrYPAW9rXGHF0PAjZ54oKbGA92dpxi6FthK00fZ5WQW5ra5GupgqWXVm1RxuzNYf082s)1B)b8pbZRzFokNSLdTJq83ipDvOWocOrnopL)CKxtlgdXck8d5K)jHXTzTsiRHlwa4hweedwBjMQysFZddxdrRMxaI)aLyLIPExrC6ikYGvRJJw8ekrt1U3f2Ko7tmlL9OJv3kkMyeFhwrfocjQUIs0oSj1gAdekLTGgYmS5InHZQ765mw4Lwd2qtx0sN0P77GjJTTJNB5QUjjwfh44qcIzSUdnqhL5Cajsx1jMHjRCztE4KfrXXHzUsPEoeFoPgC3NcojLVo6t6UYZko6n)WnIW2fBjP79sr35d4sQW)mh1ogLICPlikkxaRczhL49M)e5VZtHLf2HgSGKCks8aeUw2t8blVduG1LiNCkGmGmtWFNLzftwtDshozlC1kP7knT1Ys(7G(fq1wgQoDg4XhHucbvaZEovL49BYsmvezsCX5nbZ0Y4Mszu719T8DD3NMt9JqjoFQG8qT0OzaX6IQpeq(LcSyYcwMGWejIZvVU42c3zeTw62)Zsmtk)Y7PA5jz7ejrlbqVmYYluDldZZ5PIE5qrRNUYFtw4lHIgQKTvJ0FQvGDneRMeeXn9yvqauO1tYZbDLZUsXGsM504L)Nbjur6)olVDiNuQqT09bdk9X42FOjSrkHLR9AswAbZdwV6Yz)iskLpxo1nS85i5yqwWdPjyaaHyd9CFCaGtsmctjsWcXWvV5yd5AccuQud43ZfXskRoZnHsVkmIxI)aEI6lZ3DDSwIzhQzik0KtDCdK4jgTPUkcXRW5(a4HCFYVa0HW5QgFOseCyF3uoW3HjfDRXmL4K(kfb(Q73KV0z6swTPikoOUoSQrSHwoCqKLaPdsAyu1oN62G7V8xyqUcp5JeiC30FJSSSMMqqURjXpoPLccfjUemHKockPAknIbxMMmBoeyt3HUP16P8OS8414CSd1ExjxFitDQ212Qr4zyNkjSEARkIAoFxPqcsDO0pHELb4f8)X4t3SgnYLeToK5FqAIiQ140phMdRWT3(riuP)BsKueZMmp2wWQJyXsCx6h(nu(Jbu8yXO(dI79Gy62VKqPw9OfOrAoKJ9ygSyrmiftkfb2tifr4QEy8HBqW9xw8rwCFKgKdHH6tUfYSUSA)swMbdVMYk27SHrcuOjwZRPwmJPzmvkMrUMwTQPlncJ1BxVCYeVHKk(YNJsi1xMLMdLCGqYfgOwiAgh94XJiCFqPhbNGPEiISqhuUUkPBwlrSfds6(gsshGwzMisrAD)WV8EZy1QavCr39(zMlIjZhbQQ8AAbt1MUYvzZTAaUjVSX20WPMSM5hioe5sktkUTjp6BeB3ej0O7fkwjR0bucL71jFAB0k8D9CkkKKqZLyoe3qQMz0cw4hcK4cP0hIbNqurtszijEBsET4CpKdXwqUg9Cqlv(IiCVRjztfbtB5nmig4Rq4xtwV5F9VaZC3N(fAwesxSyYdGzu0KjDMno09o6Kxk9zYDuHjPJAQGTFnc2ORs(McJXGwuEcoyoEAUEbvtYzzwnjw4K7Lcn6UqaTss2L6yBxPG0jAs9Obhw9lLVSkldvpGLuowyQ22Ewt0NmiQt18IzaO6G5gpft)b7H9lf(f)IJiWyJXF)i5(VCK8(Mi59)QIK730qRmP8sWjep0yywkChtPuVmJu4VkVx)nCDfKxIvMdPObCsBWuE1R0FJYHihPlhfWFi)(GKqJXhvVfW6onhhStgTSc9Ewn(7oz(NtkpIxDd7AsplOvECzFlPXHOA3KzK8(uuNPWck53kBIFAmpm35ItrCb4RBEyjwmOARhRWomw1itf1dTMVjN9R80SbbEWYZM1k(PyvUVEmdLsX1XQBqk(8uvF4Wdh16FCTqbwn8oX4ATZEp4QzdwwRY319nnSUqdu9I0ycf7BVnZBcnO9bJgd4s7NzJAxwM3QzetmtNH5mEiTU6g2XjJ(sZ9DI2uXu2Xj5XwRpHJEKk9(X0BvYnW7J)CWt50KFZ3p835kSuDiXA)mW7gyCpN0EjEX1)CAYRqNDWO2Gi1j9(cnNcldIxqx6xLB2phMaVqfAL2bwtNpJHvoEzvAgdvYH3Iko3cW0kmTCKu6MxyPeNgYBeo76VSKzcKtAVJblxFRKa2ZznqCZOpF1rfufErAI9kIuhn5fGG0wPwxSo3w4Xv1hjfNJpXVJZT7Jr1PXs5yOZevDSjkOEqkkuqcvOyzuEbYOcdK88Xyd61J5UJOcEJK7REZB5KIwt11Zo1MabXYCg1tnjxZlHzcwAVBmBxxzqqO70FERn2De2ZcJcNMES3uTZmub9TCi0XuVA3vBcl4(4005XBYr3hcM1SKABHdwcoRt5E14B33CNZabSMSyt2tKzXE5dCplHz5Hz8s)7B3dlNZYcqyGapKjXUNfoNe8O4G9du8KzSJTGFdtqij)pEokWmwD8YfYzR4YoaL4QB36IZwjEgitoHtnkODgSHAYuF8lMlXABD3UK28RNvYYCZRyMr7GquTYiFK1EAWopmLAKtzGsRQ9pG9rymgK2IJ0jk8J)pleIQvoS0VMLby9iVAixJj2a5KdWHwQKrUA4xwhLXYNJ5wFPmYH8pfTEcTew8dcGHkRCm09Q2aRtNN)(s6RszzHSD0uwMVS50a9iDo4TNBH(XmFFyfQPNzuQepOrPgSguTdydqhUGfZ6SnKouhRukMf4kaNeyzRlLehbev)4xholcBuMYiEXWsfrddiesui0wQF6Ah5MG8I9jEZw7CDHpiV)1Y5ST28a4xV43O6m5wbyQeD11MIUYDPBoEsd33XdL0qhMRwrT(4o9QjStZegHuOKGQTEXYSGQq(CZ6pfgsQWbjPkfzr828GKFBCdf2eHbezaQS9d4M(GcucMOPGOVmoalvnweA(XNiGC8tbJCyBeuY3CDiE08PLRp02jmwjNhOxTtOMqQtGL1FnYUbAtuX1YCwJ2DOVyMYIG8fLthE2lQ1rdhfqsW0v8KPm(VkwWO7F)lwtdyn99BaVXyBMAR560I72D)XOGr74NIUAuerfNSF4xXkjii4UJ61CFJXKFkvo2MawNtiWNr(tdao9YOPs)Yqjh7MElLEqDIGjOfURS5X4NFbuRd1wF2Me6PoL04lO9h)lhMtvHrZ2m(VkDHHM7zH7l0SldUg8kIRrf0ZyIiF1FuUwh2knfxLSP(egNPYmJZGEsFAP0j3TPitC0JK1xon5myKM59KG15ltXZgUJT5z81RrIi6Qa(3QT41T)EmbEgWZ(dVtrdahXr7)ZWC6NfgRC(LgkLUi(lKcexSFsToq7UPFgVWxDmwDUkcz1QFxM9)xYg)7ISHrZl2ptW62x06X3447jNFP3N(JGY0kAF53)dHyZTGKx(j9hvSEpe7(fy6kr9TpKKYoCj0J6an2q5wKHhbjxjlVyDvLNpc7CAXV0aJqgR8BZiFMTwDZT8(Ig2KaQSdxjUBescdYWipjTejNgjQEP4W5XQkZ8uEjz4NLV5y9Jrh0V9hEn2bCwjzc)0A1e51AOST17Y1l3vEJaQRzWDSxwYYFnhUURP9GKNwIBnuIbsEt1BAawhsi8TP89kBPUgOdyajxBy6GcZYr(p)sn9QUGxAFoidD)i)UBUf3aeTADAwbZ5HxjYJ4RWP8)BdMy7DSdezWMI0v0D5ZwcuRW8U7(5)b5iW6)o8ooeWKmYJtxhsZ1wov46v27HaVwMzcETzy0199)puAplY1)42TsA1VEu)oEvPlxYMHX(VIklEKGXRpAWqqVUQg6LJ8g45ajcMjFNBoQFdWQ32iIRR0maZHNTBrZR739koX)feNAeN6OWjGtU7NnS)HMX89BZtFvHHxzPApA0rBfdcgw7(FPJ1zxH00vBUD1wK6tS)ZkyRp7p7GTXsIPd8oV4k)JBLU6zLvyz21YTG2KBP961N7bpRqU(SFYeIg(Sc26Z(jdSFZZkyBz2ps5eJQzzxND7NE23Ag(0VOL0aqB3dt6y)39mn7gXFXLXX(rbQStM10VvVfxeGP9l6LAvtWE1QxKmvMCJdPrtUHBpgdGUPX8So91oXgUwCmqvoy4(qNE76LpLmtBt(jrm0oKFyKKN5PV2j(qfbBiCFOtFDMcR2DXAA(S3(X1P7NCTbTFk(S4I9jbiPRW3AEfKnh)Q6deQHZ6jeUTyu04npG2I482jOgM4S557hh0ItOhj9vFwv90IL55xP6PLXtv2(nXhHlCVSEEEAN9xM9iNmEO7j(i4Hv2Zv1gcPwMUmGWhWZ0eB3T2Q2nmpLggGB)Lp4jUulVLiUpsbS(pp6ESnTNqL79TSFwKxzTzUsEQRmHwIX7KpH0MExB2uBg)ktLf1lhoSzzcpeyZs0HhTIvZEiLUNUhzb6QuignWZAHAQDVo7951zuFE1R)yfYzVNza26cCWqSfvtNoi2YcCas)7(5FIioHtZ3UJD1bJD6rEbkYG9eC6IiShx)gS1qpj3iX7(z2F3vKAJrY3nXgE(5JEn2MlHsximxu5skDu)ExeTyu1M(CC)H7(5VbBxMIN77NxZWoV8dxGT07i2SxEwOVG0)WJ6JqV94J9A3YEK5B36iiVXJCe5ANJbK9Lb5QqLeixfFkbzdq1yhOthDM5Z6LYBtipYUai1nTmIKCzQV(7BB1Y(zFRfEbRIzwEOYv6RPDfKnfsfe)Nj0VYnZWEfY5kG0PkKgLawh04c2Y8bpgefJVwxYBDCFZqeyWibk9n4hETIJ)lbIyQbsc(1gbr6wQNugPrOY(uo9HmMMJg15AFcyVxFooSV4ADvdB5n2zKJVIQh7f7BJHDO2qDuViD9iYNqKle9xZiJDUjTc5IhP4)m7PE2FXRvo4z8Tywh(fLFSog5CjLXv9dkftmrCH8aYwAxGcB364QtO2zE28CcJ9z)tJHmOOP4a3Vq7bg9p1eEYnFZ4r(B32IPdtVIgEsQz0ERbYlnRpyigpSmtwaft)mxWyORL0mHh8EUbdIE3Llno1VReiAOEeyhpQ)WZn3CZvNfYxFc5Fx7JnH8Ju(2sWuK)1YT5xP5jqCEuf31yx4IJ63D4fknliZavLBzrW5bZNp8TBXdHQNIEGRVQxhV2vBiNRnDKbodGHTBn9KXkgRPoACYUQbviqM8O1SZRx17sBx9GE1Jdeu4iUM(0bAvZa1DXOXup3YqQsqgGd1XGp7B3Am9E6)SqllGO7Xn1xtrm57Wnn0Xs9S3U10feG2YrZHGMxketjETC0HuTBzjDbEgwtWdBldwq65VXM1g3(mUFpJ7263J7eUGkJgMEjUf7AkFRcttNmB4CJ41YWb1US5XQtA30iLfF0bD8c0lccPKc6gU48Uq6k2JQMS9lXwPogPnoCjZ3OqYiFFjTpfN8R3oBKZ8li3Ry84sP0nbRPsOSJ6712aB3ck1RZ2TUMmFLW0vZEn44Kj5lhojdlhSETSVEDAirWVoIG)PKi0xjW)xEIGyoqS2WMsR7ifzkJqUuBkCPDzY3nCx)MoEAn3TxBhyZOH9OgiQClQ1HfxUSX4)KEVM5wjTtFfmOFZBVmr2YiX1qZAp2vxbF(a3nn8aDuSYLnMu0nkiJ18)4128XZU0(IS7EW2q3qi88wwUNY8mCeVh)DDFZ2TUMXXd6vzNMmGQSzZcg0EVaPbNp4mZZyzs2OBM0EZZ61D44QCC6oml3Tz)TVkVBZQ43i8CjjlHclHRlmTvEgVILm5LOrJ9c)mMz((7sssrl2mh3BxvKE4itRQyJsP2mIC)zanoryrP9e57omzdsk3ByJ7735CZ2GuFTQwNG3CKFfeu6k0QmprQ3fyETRKcKEGHo21Y1ORa3lmjqce6Qod0XOBhSP6S3ub8m3a9et4osJ7yT7YRTBDn4(Egcn)nyshSfrMeDw9w6A8GHvqb61IfcYeQH2vVLLmEyK4PpZLxxw4S3KxqCZy1WxqCjy1WXREFx1WxYCQ5Oe2Q563ZYLHWOEvM3u(LwfolvsGink3)G)4f(32D6)4fwshOP3unRSMp4Laf5CETQT8zm0sue6Es7(SvI6oGqtv0NaUZyjLQYHgOPe3cAOKJppJHuBWaHjpI8fPyXK7CLrLB(ZoOA(Q9TcVd70Xa7s1N6YproIsIyi1G9pbKvYwI)O)Y)zGEy4B8MIhPLuiQFX18H5RHRGHuzF4Riqyp2VFFneSTaMwuBEDVUV1RTPubmuXjeNFd)US63VVRhHF7(OELFOFa(E(qylY)EANvCdksnfkOLm31YQ(dPtTQea7Y3nZ5Q1VhH(EaFu8mGAkofzJO2UvLBsqpx(wn6QZ1cWxyMXuBN3Xm(qud9s(LGRwYtd1n4M0iYNH5V0BMi2glaHACYvdLrGd0psDwawcP)a)AVzyT4Fe3mrQQbVBz1hc5u23mY8iFxWMnkb13W)0CJHkHIPv9FO6nWgZpIQBLBRMchw0z6vuIRYwYdkTwDHUp(f(E)SXub2ofhub1G5DTl2VHeH9)McTbOJkIqngCkUwq1xAUyJ50EkcqW2v6GSqL613G70C67CJT5W29mibJPm86QPmuhl5uZJalnCnFwlw23Zwiz1LFutjw1kU(nGSHk(Ug2xpH4Cs2SWlWEva70Hr9jIrVSxANoe4S13rszJYRTk9E7wHtSIlQRAmfJXkAMVAAYoZPKjD6QYd43GmDgpWvsm2hgLzQMjlULo8wXAG1w76pZK4((oPX7mC3J912n)Oo7vlN1MyZkKSXJ8TQAzGN52q1VhWLSNEzt(z6XzET9p)QZARbcd60rk43NPlLshAY1e8zpXbDrEZWxHc92L5h3EW5TTDEtoByNYhYpLlKF0M3lN9MowPRnvbdNA)xmHJIjqcj(RMloX6ulTFQHe(6zu3Hdn1Vy36H7l(I3Tz2KaSsiAlN46l73rzhGnpoRu0rNPE)6(dltiUOADB3Q1HlB3wQ)VSMEyte6qQNxoLBkBKL3tjALuprEGo3vz9EURQNQ)vYWKt3H)jwfafog)orIYrB2)UAN6JKuPXAHi4WDnx9atT3BEh)fT4PIirUpuPLQc3Y2)23jrQkJpTs(UfhejCt4dy68iBLl)0VWdHqj0vNe5AcQZbbNMIX97MlSrCa3rf6(MluD)M2jf4FskDkV7mjovAG1O3xycYhTYRKmoWlb7E0SXETuW9UI2B2EwautQPKMVowQ5OJ(vDqhlHW4SFb(EMPgoLJsZuusb0yQwk6oEdeuskrVuoV7FvssDrhAF1LC4YOgA5EIW4aK4nwU7djrsOsTz9Tp7qP8Ew8AVt4XX5csmXTF0IV4OrLb0f03gq3aXjfH885yoc7Y3eO2axlaqkglavH6zDSRtoM1(ZN97AXBsZUFz6zu7hoTuun(kptToBL(uTYGeY9uooRBHeXMj9B8rELQ2DbIAt1(fW)plysWkWhMIrdgAGgb4fWYNmhB)JtKSTJCgU)6eC2xuyN(CeQmUHG7y1caK)y02(mqepmfe7n9TV)lib(RALf68WNzvg7lNI2vBph6uixi8ZWpVHFh5ol)U))d]] )
