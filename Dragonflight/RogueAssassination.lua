-- RogueAssassination.lua
-- November 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR

local format, wipe = string.format, table.wipe
local UA_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

local orderedPairs = ns.orderedPairs

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
    -- Rogue Talents
    acrobatic_strikes      = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by $s1 yds.
    airborne_irritant      = { 90741, 200733, 1 }, -- Blind has $s1% reduced cooldown, $s2% reduced duration, and applies to all nearby enemies.
    alacrity               = { 90751, 193539, 2 }, -- Your finishing moves have a $s2% chance per combo point to grant $193538s1% Haste for $193538d, stacking up to $193538u times.
    atrophic_poison        = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $h% chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    blackjack              = { 90686, 379005, 1 }, -- Enemies have $394119s1% reduced damage and healing for $394119d after Blind or Sap's effect on them ends.
    blind                  = { 90684, 2094  , 1 }, -- Blinds $?a200733[all enemies near ][]the target, causing $?a200733[them][it] to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    cheat_death            = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to $s2% of your maximum health. For $45182d afterward, you take $45182s1% reduced damage. Cannot trigger more often than once per $45181d.
    cloak_of_shadows       = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cold_blood             = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by $s1%.
    deadened_nerves        = { 90743, 231719, 1 }, -- Physical damage taken reduced by $s1%.;
    deadly_precision       = { 90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by $s1%.
    deeper_stratagem       = { 90750, 193531, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    echoing_reprimand      = { 90639, 385616, 1 }, -- Deal $s1 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.;
    elusiveness            = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by $s2%, and Feint also reduces non-area-of-effect damage taken by $s1%.
    evasion                = { 90764, 5277  , 1 }, -- Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    featherfoot            = { 94563, 423683, 1 }, -- Sprint increases movement speed by an additional $s1% and has ${$s2/1000} sec increased duration.
    fleet_footed           = { 90762, 378813, 1 }, -- Movement speed increased by $s1%.
    gouge                  = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.; Must be in front of your target.; Awards $s2 combo $lpoint:points;.
    graceful_guile         = { 94562, 423647, 1 }, -- Feint has $m1 additional $Lcharge:charges;.;
    improved_ambush        = { 90692, 381620, 1 }, -- $?s185438[Shadowstrike][Ambush] generates $s1 additional combo point.
    improved_sprint        = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by ${$m1/-1000} sec.
    improved_wound_poison  = { 90637, 319066, 1 }, -- Wound Poison can now stack $s1 additional times.
    iron_stomach           = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by $s1%.
    leeching_poison        = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you $108211s1% Leech.
    lethality              = { 90749, 382238, 2 }, -- Critical strike chance increased by $s1%. Critical strike damage bonus of your attacks that generate combo points increased by $s2%.
    marked_for_death       = { 90750, 137619, 1 }, -- Marks the target, instantly granting full combo points and increasing the damage of your finishing moves by $s1% for $d. Cooldown resets if the target dies during effect.
    master_poisoner        = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%.
    nightstalker           = { 90693, 14062 , 2 }, -- While Stealth$?c3[ or Shadow Dance][] is active, your abilities deal $s1% more damage.
    nimble_fingers         = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1.
    numbing_poison         = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d.  Each strike has a $5761h% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $5760s1% for $5760d.
    recuperator            = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per 2 sec.
    resounding_clarity     = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges $m1 additional combo $Lpoint:points;.
    reverberation          = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by $s1%.
    rushed_setup           = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%.
    shadow_dance           = { 90689, 185313, 1 }, -- Description not found.
    shadowrunner           = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster.
    shadowstep             = { 90695, 36554 , 1 }, -- Description not found.
    shiv                   = { 90740, 5938  , 1 }, -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    soothing_darkness      = { 90691, 393970, 1 }, -- You are healed for ${$393971s1*($393971d/$393971t)}% of your maximum health over $393971d after gaining Vanish or Shadow Dance.
    stillshroud            = { 94561, 423662, 1 }, -- Shroud of Concealment has $s1% reduced cooldown.;
    subterfuge             = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for ${$s2/1000} sec after Stealth breaks.
    superior_mixture       = { 94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional $s1%.
    thistle_tea            = { 90756, 381623, 1 }, -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    tight_spender          = { 90692, 381621, 1 }, -- Energy cost of finishing moves reduced by $s1%.
    tricks_of_the_trade    = { 90686, 57934 , 1 }, -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    unbreakable_stride     = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects $s1%.
    vigor                  = { 90759, 14983 , 2 }, -- Increases your maximum Energy by $s1 and Energy regeneration by $s2%.
    virulent_poisons       = { 90760, 381543, 1 }, -- Increases the damage of your weapon poisons by $s1%.

    -- Assassination Talents
    amplifying_poison      = { 90621, 381664, 1 }, -- Coats your weapons with a Lethal Poison that lasts for $d. Each strike has a $h% chance to poison the enemy, dealing $383414s1 Nature damage and applying Amplifying Poison for $383414d. Envenom can consume $s2 stacks of Amplifying Poison to deal $s1% increased damage. Max $383414u stacks.
    arterial_precision     = { 90784, 400783, 1 }, -- Shiv strikes ${$s2-1} additional nearby enemies and increases your Bleed damage done to affected targets by $s1% for $319504d.
    blindside              = { 90786, 328085, 1 }, -- Ambush and Mutilate have a $s1% chance to make your next Ambush free and usable without Stealth. Chance increased to $s2% if the target is under $s3% health.
    bloody_mess            = { 90625, 381626, 1 }, -- Garrote and Rupture damage increased by $s1%.
    caustic_spatter        = { 94556, 421975, 1 }, -- Using Mutilate on a target afflicted by your Rupture and Deadly Poison applies Caustic Spatter for $421976d. Limit 1.; Caustic Spatter causes $421976s1% of your Poison damage dealt to splash onto other nearby enemies, reduced beyond $421976s2 targets.
    crimson_tempest        = { 90632, 121411, 1 }, -- Finishing move that slashes all enemies within $A1 yards, causing victims to bleed. Lasts longer per combo point.; Deals extra damage when multiple enemies are afflicted, increasing by $s4% per target, up to ${$s4*5}%.; Deals reduced damage beyond $s3 targets.;    1 point  : ${$o1*4} over ${$d+(2*1)} sec;    2 points: ${$o1*5} over ${$d+(2*2)} sec;    3 points: ${$o1*6} over ${$d+(2*3)} sec;    4 points: ${$o1*7} over ${$d+(2*4)} sec;    5 points: ${$o1*8} over ${$d+(2*5)} sec$?s193531[;    6 points: ${$o1*9} over ${$d+(2*6)} sec][]
    cut_to_the_chase       = { 94557, 51667 , 1 }, -- Envenom extends the duration of Slice and Dice by up to $s1 sec per combo point spent.
    dashing_scoundrel      = { 90766, 381797, 1 }, -- Envenom also increases the critical strike chance of your weapon poisons by $s1%, and their critical strikes generate $s2 Energy.
    deadly_poison          = { 90783, 2823  , 1 }, -- Coats your weapons with a Lethal Poison that lasts for $d. Each strike has a $h% chance to poison the enemy for ${$2818m1*$2818d/$2818t1} Nature damage over $2818d. Subsequent poison applications will instantly deal $113780s1 Nature damage.
    deathmark              = { 90769, 360194, 1 }, -- Carve a deathmark into an enemy, dealing $o1 Bleed damage over $d. While marked your Garrote, Rupture, and Lethal poisons applied to the target are duplicated, dealing $?a134735[${100+$394331s1+$394331s3}%][${100+$394331s1}%] of normal damage.
    doomblade              = { 90777, 381673, 1 }, -- Mutilate deals an additional $s1% Bleed damage over ${$381672d+2} sec.
    dragontempered_blades  = { 94553, 381801, 1 }, -- You may apply $s1 additional Lethal and Non-Lethal Poison to your weapons, but they have $s2% less application chance.
    fatal_concoction       = { 90626, 392384, 1 }, -- Increases the damage of your weapon poisons by $s1%.
    flying_daggers         = { 94554, 381631, 1 }, -- Fan of Knives has its radius increased to $s4 yds, deals $s5% more damage, and an additional $s1% when striking $s2 or more targets.
    improved_garrote       = { 90780, 381632, 1 }, -- Garrote deals $s1% increased damage and has no cooldown when used from Stealth and for $392401d after breaking Stealth.
    improved_poisons       = { 90634, 381624, 1 }, -- Increases the application chance of your weapon poisons by $s1%.
    improved_shiv          = { 90628, 319032, 1 }, -- Shiv now also increases your Nature damage done against the target by $319504s1% for $319504d.
    indiscriminate_carnage = { 90774, 381802, 1 }, -- Garrote and Rupture apply to ${$m1-1} additional nearby $Lenemy:enemies; when used from Stealth and for $385747d after breaking Stealth.
    intent_to_kill         = { 94555, 381630, 1 }, -- Shadowstep's cooldown is reduced by $s1% when used on a target afflicted by your Garrote.
    internal_bleeding      = { 94556, 381627, 1 }, -- Kidney Shot and Rupture also apply Internal Bleeding, dealing up to ${5*$154953o1} Bleed damage over $154953d, based on combo points spent.
    iron_wire              = { 94555, 196861, 1 }, -- Garrote silences the target for $s2 sec when used from Stealth.; Enemies silenced by Garrote deal $256148s1% reduced damage for $256148d.
    kingsbane              = { 94552, 385627, 1 }, -- Release a lethal poison from your weapons and inject it into your target, dealing $s2 Nature damage instantly and an additional $o4 Nature damage over $d. ; Each time you apply a Lethal Poison to a target affected by Kingsbane, Kingsbane damage increases by $394095s1%.; Awards $s6 combo $lpoint:points;.
    lethal_dose            = { 90624, 381640, 2 }, -- Your weapon poisons, Nature damage over time, and Bleed abilities deal $s1% increased damage to targets for each weapon poison, Nature damage over time, and Bleed effect on them.
    lightweight_shiv       = { 90633, 394983, 1 }, -- Shiv deals $s2% increased damage and has $m1 additional $Lcharge:charges;.
    master_assassin        = { 90623, 255989, 1 }, -- Critical strike chance increased by $256735s1% while Stealthed and for $s1 sec after breaking Stealth.
    path_of_blood          = { 94536, 423054, 1 }, -- Increases maximum Energy by $s1.
    poison_bomb            = { 90767, 255544, 2 }, -- Envenom has a $<chance>% chance per combo point spent to smash a vial of poison at the target's location, creating a pool of acidic death that deals ${$255546s1*$s2} Nature damage over $255545d to all enemies within it.
    sanguine_blades        = { 90779, 200806, 1 }, -- While above $s1% of maximum Energy your Garrote, Rupture, and Crimson Tempest consume $s2 Energy to duplicate $s3% of any damage dealt.
    scent_of_blood         = { 90775, 381799, 2 }, -- Each enemy afflicted by your Rupture increases your Agility by $S1%, up to a maximum of $394080u%.
    seal_fate              = { 90757, 14190 , 1 }, -- Critical strikes with attacks that generate combo points grant an additional combo point per critical strike.
    sepsis                 = { 90622, 385408, 1 }, -- Infect the target's blood, dealing $o1 Nature damage over $d and gaining $s6 use of any Stealth ability. If the target survives its full duration, they suffer an additional $394026s1 damage and you gain $s6 additional use of any Stealth ability for $375939d.; Cooldown reduced by $s3 sec if Sepsis does not last its full duration.; Awards $s7 combo $lpoint:points;.
    serrated_bone_spike    = { 90622, 385424, 1 }, -- Embed a bone spike in the target, dealing $s1 Physical damage and $394036s1 Bleed damage every $394036t1 sec until they die or leave combat. ; Refunds a charge when target dies.; Awards 1 combo point plus 1 additional per active bone spike.
    shrouded_suffocation   = { 90776, 385478, 1 }, -- Garrote damage increased by $s1%. Garrote generates $s2 additional combo points when used from Stealth.
    sudden_demise          = { 94551, 423136, 1 }, -- Bleed damage increased by $s1%.; Targets below $s3% health instantly bleed out and take fatal damage when the remaining Bleed damage you would deal to them exceeds $s2% of their remaining health.
    systemic_failure       = { 90771, 381652, 1 }, -- Garrote increases the damage of Ambush and Mutilate on the target by $s1%.
    thrown_precision       = { 90630, 381629, 1 }, -- Fan of Knives has $s2% increased critical strike chance and its critical strikes always apply your weapon poisons.
    tiny_toxic_blade       = { 90770, 381800, 1 }, -- Shiv deals $s1% increased damage and no longer costs Energy.
    twist_the_knife        = { 90768, 381669, 1 }, -- Envenom duration increased by ${$s1/1000} sec.
    venom_rush             = { 94554, 152152, 1 }, -- Ambush and Mutilate refund $256522s1 Energy when used against a poisoned target.
    venomous_wounds        = { 90635, 79134 , 1 }, -- You regain $s2 Energy each time your Garrote or Rupture deal Bleed damage to a poisoned target.; If an enemy dies while afflicted by your Rupture, you regain energy based on its remaining duration.
    vicious_venoms         = { 90772, 381634, 2 }, -- Ambush and Mutilate cost $s2 more Energy and deal $s1% additional damage as Nature.
    zoldyck_recipe         = { 90785, 381798, 2 }, -- Your Poisons and Bleeds deal $s1% increased damage to targets below $s2% health.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5530, -- (354406) Cheap Shot grants Slice and Dice for $s1 sec and Kidney Shot restores $s2 Energy per combo point spent.
    creeping_venom     = 141 , -- (354895) Your Envenom applies Creeping Venom, reducing the target's movement speed by $354896s1% for $354896d.  Creeping Venom is reapplied when the target moves. Max $354896u stacks.
    dagger_in_the_dark = 5550, -- (198675) Each second while Stealth is active, nearby enemies within $198688A1 yards take an additional $198688s1% damage from you for $198688d. Stacks up to $198688u times.
    death_from_above   = 3479, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack.; You leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $269512s2% stronger effect.
    dismantle          = 5405, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for $d.
    hemotoxin          = 830 , -- (354124) Shiv also reduces the target's healing received by $S1% for $319504d.
    maneuverability    = 3448, -- (197000) Sprint has $s1% reduced cooldown and $s2% reduced duration.
    smoke_bomb         = 3480, -- (212182) Creates a cloud of thick smoke in an $m2 yard radius around the Rogue for $d. Enemies are unable to target into or out of the smoke cloud.
    system_shock       = 147 , -- (198145) Casting Envenom with at least 5 combo points on a target afflicted by your Garrote, Rupture, and lethal poison deals $198222s1 Nature damage, and reduces their movement speed by $198222m2% for $198222d.
    thick_as_thieves   = 5408, -- (221622) Tricks of the Trade now increases the friendly target's damage by $m1% for $59628d.
    veil_of_midnight   = 5517, -- (198952) Cloak of Shadows now also removes harmful physical effects and increases dodge chance by ${-$31224m1/2}%.
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
    normal = { "stealth" },
    vanish = { "vanish" },
    subterfuge = { "subterfuge" },
    shadow_dance = { "shadow_dance" },
    shadowmeld = { "shadowmeld" },
    sepsis = { "sepsis_buff" },

    improved_garrote = { "improved_garrote", "sepsis_buff" },

    basic = { "stealth", "vanish" },
    mantle = { "stealth", "vanish" },
    rogue = { "stealth", "vanish", "subterfuge", "shadow_dance" },
    ambush = { "stealth", "vanish", "subterfuge", "shadow_dance", "sepsis_buff" },

    -- SimC includes Improved Garrote in stealthed.all, but it feels misleading.
    all = { "stealth", "vanish", "shadowmeld", "subterfuge", "shadow_dance", "sepsis_buff", "improved_garrote" },
}


spec:RegisterStateTable( "stealthed", setmetatable( {}, {
    __index = function( t, k )
        local kRemains = k == "remains" and "all" or k:match( "^(.+)_remains$" )

        if kRemains then
            local category = stealth[ kRemains ]
            if not category then return 0 end

            local remains = 0
            for _, aura in ipairs( category ) do
                remains = max( remains, buff[ aura ].remains )
            end

            return remains
        end

        local category = stealth[ k ]
        if not category then return false end

        for _, aura in ipairs( category ) do
            if buff[ aura ].up then return true end
        end

        return false
    end,
} ) )


spec:RegisterStateExpr( "master_assassin_remains", function ()
    if not ( talent.master_assassin.enabled or legendary.mark_of_the_master_assassin.enabled ) then return 0 end
    if stealthed.mantle then return cooldown.global_cooldown.remains + ( legendary.mark_of_the_master_assassin.enabled and 4 or 3 )
    elseif buff.master_assassin_any.up then return buff.master_assassin_any.remains end
    return 0
end )

local stealth_dropped = 0

local function isStealthed()
    return ( UA_GetPlayerAuraBySpellID( 1784 ) or UA_GetPlayerAuraBySpellID( 115191 ) or UA_GetPlayerAuraBySpellID( 115192 ) or UA_GetPlayerAuraBySpellID( 11327 ) or GetTime() - stealth_dropped < 0.2 )
end

local calculate_multiplier = setfenv( function( spellID )
    local mult = 1

    if talent.nightstalker.enabled and isStealthed() then
        mult = mult * 1.08
    end

    if spellID == 703 and talent.improved_garrote.enabled and ( UA_GetPlayerAuraBySpellID( 375939 ) or UA_GetPlayerAuraBySpellID( 347037 ) or UA_GetPlayerAuraBySpellID( 392401 ) or UA_GetPlayerAuraBySpellID( 392403 ) ) then
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

    if set_bonus.tier31_4pc > 0 and resource == "energy" and amt > 9 then
        addStack( "natureblight", 6, floor( amt / 10 ) )
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

    if this_action == "garrote" and ( buff.improved_garrote.up or talent.improved_garrote.enabled and buff.sepsis_buff.up ) then mult = mult * 1.5 end

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


-- Tier 31
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207238 )
-- 422905: Rogue Assassination 10.2 Class Set 2pc
-- Each 10 energy you spend grants Natureblight, granting 1.0% attack speed and 1.0% Nature Damage for 6 sec. Multiple instances of Natureblight may overlap, up to 12.
-- TODO: Each application is actually individual, so I should track this differently.
spec:RegisterAura( "natureblight", {
    id = 426568,
    duration = 6,
    max_stack = 12
} )

-- Tier 30
spec:RegisterGear( "tier30", 202500, 202498, 202497, 202496, 202495 )
spec:RegisterAuras( {
    poisoned_edges = {
        id = 409587,
        duration = 30,
        max_stack = 1
    }
} )

local ExpireDeathmarkT30 = setfenv( function ()
    applyBuff( "poisoned_edges" )
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

    if set_bonus.tier30_4pc > 0 and debuff.deathmark.up then
        state:QueueAuraExpiration( "deathmark", ExpireDeathmarkT30, debuff.deathmark.expires )
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

        if buff.improved_garrote.up and buff.improved_garrote.remains > 3 then
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
        duration = function() return 60 * ( talent.airborne_irritant.enabled and 0.6 or 1 ) end,
        mechanic = "disorient",
        type = "Ranged",
        max_stack = 1
    },
    blindside = {
        id = 121153,
        duration = 10,
        max_stack = 1,
    },
    caustic_spatter = {
        id = 421976,
        duration = 10,
        max_stack = 1
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
        duration = function () return ( effective_combo_points ) + ( 2 * talent.twist_the_knife.rank ) end,
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
    -- Talent: Marked for death, taking extra damage from @auracaster's finishing moves. Cooldown resets upon death.
    -- https://wowhead.com/beta/spell=137619
    marked_for_death = {
        id = 137619,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Critical strike chance increased by $w1%.
    -- https://wowhead.com/beta/spell=256735
    master_assassin = {
        id = 256735,
        duration = 3600,
        max_stack = 1,
        copy = "master_assassin_aura"
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
    -- Attacks deal $w1% additional damage as Shadow and combo point generating attacks generate full combo points.
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
    -- Combo points stored.
    -- TODO: Is the # of points stored as a stack or value?
    shadow_techniques = {
        id = 196911,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- deeper_stratagem[193531] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- improved_shadow_techniques[394023] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- secret_stratagem[394320] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
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
        duration = function() return ( 8 + ( talent.featherfoot.rank * 4 ) ) * ( pvptalent.maneuverability.enabled and 0.5 or 1 ) end,
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
    -- Movement speed increased by $w1%.
    terrifying_pace = {
        id = 428389,
        duration = 3.0,
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
        usable = function () return stealthed.ambush or buff.audacity.up or buff.blindside.up, "requires stealth or audacity/blindside/sepsis_buff" end,

        cp_gain = function ()
            if buff.shadow_blades.up then return 6 end
            return 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + talent.improved_ambush.rank + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 )
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
        cooldown = function () return ( talent.blinding_powder.enabled and 90 or 120 ) * ( talent.airborne_irritant.enabled and 0.5 or 1 ) end,
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
        readyTime = function() return gcd.remains end,

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

        cp_gain = function () return 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) end,

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
        cooldown = function() return 15 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end,
        charges = function() return talent.graceful_guile.enabled and 2 or nil end,
        recharge = function() return talent.graceful_guile.enabled and ( 15 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) ) or nil end,
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
        cooldown = function () return ( buff.sepsis_buff.up or buff.improved_garrote.up ) and 0 or 6 end,
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

        cp_gain = function ()
            if buff.shadow_blades.up then return combo_points.max end
            return 1 + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 )
        end,

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

    -- Finishing move that stuns the target$?a426588[ and creates shadow clones to stun all other nearby enemies][]. Lasts longer per combo point, up to 5:;    1 point  : 2 seconds;    2 points: 3 seconds;    3 points: 4 seconds;    4 points: 5 seconds;    5 points: 6 seconds
    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = function() return talent.stunning_secret.enabled and 40 or 20 end,
        gcd = "spell",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return ( talent.rushed_setup.enabled and 20 or 25 ) * ( talent.stunning_secret.enabled and 2 or 1 ) * ( 1 - 0.1 * talent.tight_spender.rank ) * ( 1 + conduit.rushed_setup.mod * 0.01 )
        end,
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
    -- TODO:  MfD cooldown for Subtlety is different?
    marked_for_death = {
        id = 137619,
        cast = 0,
        cooldown = 40,
        gcd = "off",
        school = "physical",

        talent = "marked_for_death",
        startsCombat = false,
        texture = 236364,

        toggle = "cooldowns",

        usable = function ()
            return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
        end,

        cp_gain = function () return 7 end,

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
            if talent.caustic_spatter.enabled and dot.rupture.ticking and dot.deadly_poison_dot.ticking then
                applyDebuff( "target", "caustic_spatter" )
                active_dot.caustic_spatter = 1
            end

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

        spend = function()
            if buff.goremaws_bite.up then return 0 end
            return 25
        end,
        spendType = "energy",

        startsCombat = true,
        aura = "rupture",
        cycle = "rupture",

        usable = function () return combo_points.current > 0, "requires combo_points" end,

        used_for_danse = function()
            if not state.spec.subtlety or not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.rupture
        end,

        handler = function ()
            removeStack( "goremaws_bite" )
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

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 )
        end,

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

        cp_gain = function () return ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike end,

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

        spend = function () return ( talent.tiny_toxic_blade.enabled or legendary.tiny_toxic_blade.enabled ) and 0 or 30 end,
        spendType = "energy",

        talent = "shiv",
        startsCombat = true,

        cp_gain = function () return 1 + ( buff.shadow_blades.up and 6 or 0 ) + ( buff.broadside.up and 1 or 0 ) end,

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
        cooldown = function() return talent.stillshroud.enabled and 180 or 360 end,
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

        spend = function()
            if buff.goremaws_bite.up then return 0 end
            return talent.tight_spender.enabled and 22.5 or 25
        end,
        spendType = "energy",

        startsCombat = false,
        texture = 132306,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            removeStack( "goremaws_bite" )
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
        cooldown = function () return 120 * ( talent.improved_sprint.enabled and 0.5 or 1 ) * ( pvptalent.maneuverability.enabled and 0.5 or 1 ) end,
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
        cooldown = function() return 120 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end,
        recharge = function() return 120 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end,
        gcd = "off",

        startsCombat = false,
        texture = 132331,

        disabled = function ()
            if ( settings.solo_vanish and solo ) or group or boss then return false end
            return true
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
            if talent.soothing_darkness.enabled then applyBuff( "soothing_darkness" ) end
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

    canFunnel = true,
    funnel = false,

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


spec:RegisterPack( "Assassination", 20231109, [[Hekili:D3ZAZjYrs(BrHJadJKWa6HNXNGngp27D27zhoSMBVVjulOr0NGU56hsJ2qb)2VmZ6rxV7gmA84l2yhlORUQmZkR8DwCZWB(4nxppQm(MFD0GrNnC4G31F4GlE3WlV56YN3eFZ1BIM9q09WFKgTg(33xuevuKKgvMKLIp95vzrZXzPiRkFgmILLLBk(UV5BUpPCz1D9NLT(BkswxTIEJz5rlkXpp7BU567Qswv(tP3CNlq4TxCZ1rvLlZYV56Rtw)byItMppMn64Iz3Cno6tho80bV772E7VhVk6tBV9htFmonB92BZJ)FRsYJxhNww0F7pV9NLJ(T1J(d5jRlYs3E7hJxVjUOm0R9TWR93RYlxgNV92Hd6pA7TvBqW2yCxaJ73IkNTKnQ6ho4YthDo8Wp(uC0daK(PIO07Rqkz82BJsNdF1SLzjP3JG3gaYOVBww68eKYPSmdU40rxcZ01XBksk2EBXZPZ2E7QS7tG)teqKMRm2rNocbP3VAv2tk0Ni49(WVbV7M405ikfDFuskscI2E78NjWOmk)(y4BEAzmqJ(9QnLv5cy1M09uw1k4bzif6PKcyGPzWxFh8hvfAGeqOWTmG8mO)3kiJApNbYZHPBDcYTbadS9)42BH9L8N7FZ1RskkliUUY4OvWsISG)kXnhNgD3k4ZFpW)mJXLwaVlJRjpzd7R(LOhaaRGqOYST3Um6XyXIuTbibv50Y(pG)T4UOuGXgE5Y48Ki4Kr0kaq6)G4z95R52B7S92UWlNP(WYKzpqZ1lVG7NzRMN9uQYZXLRN4vpcE747QwSOpc00Z6O)va3jUtT92RasO4nPhhZ2CHx6Ms4WKhIXd1yKgfrIPBVnjfjfrZroMFikDg8vlYaEKI0OnflZklj05xtUFzzbqlEioxL6Wbv81NohF7AqEY4T3oYhaFMhaMpkdWvYjJ7E40xgHGnWkWM86TqnmrfqJxSigwJhJNccPUlB6g40xjhkpNr3DVrAc)1BjWBEgIlNVF4IaK)LiGVgi4cPTSTe8GWQyX5YDdti4DnnTtJ4Z60OQ8ibl2r8XOTXXF2JrWQaOsFgemLdaaEEHh88(O88SsKA)8m5luGNqvGA5z3(jR3KN9y88P83tCAqLxh(4qG35ubCsc)Ms)TCy9yhY2aQBkt2SkbPH4EYq233L)UjGmvK8VMK(oDwuEkOItGTrmkjU3lbNRijLRwjWK(lIsNMTy6dPWqzlS6ry3emHeG6DO(ZJxKmlPKTtDMysydh43wdVA205jXeExFmcofzWc9tCk42B)3zWmkaDZMvpdsKZrnklYJlaDspbALzubLXwCcI1ZYQszNSPd7cTlSdtiSWf9)tAupqvaJ8HSdxAWo0696qCFD9VHI7rZJJkxUok)b7ZNo53v5PKuC)BkxyZudi636HVpNPK0yZrQ60HGvu8LqUQUmvMsAqD8cGqVc3(lYY3XJ9EODsEv3eDI0Yu5utDj1u3GN6V(XO0KILU04QH2xZ2ZboeUspa0(N0RcubYMfIrZI1vWL(dI1(MRHbonn(tLKee4)MhnnAnYVEZ1NRSdTbwOPiDImfnGsqvu2eQDO4lnl9uf9JfXLvBku3jocp0gWOa(dn591gJ00aXdR5)vKf1p0zbXyYzh3X5wzZ25wQMrj1psZkJrnpmqK0LdA(0u3gKJo5VrCU9Czpq7P2h1ocoFmgsjmNjKUYpwRtx7ysZRjfN9hIKRrl7ABqOZJNQByNxZrWutwlASNeU5prtCONdibmOHlkq)iK4qojBBtECK6zBHnokNUDTZgAxPnBUFXEA68d7PeFwGPlk0HmtvrQouD3Qnys4iyGx0J0wQWCcHaCFwk8xWn8W7h0QCgzKMauDBIPeG7fYkIMP52oi0ghwBbj2TavD)G0D3XXaunelGGkT32YmoKa929IafTA1DrZEWdPYn33FQkkCkk5ZUSFY0oqoueCaPrB7(94cH1DjG7bBYakcHSDtbH(pwTknoNH9XPXRtWtjixkkZlQSNIEg2SeoGfZEW0BNuyJaP1G3nP1h9zACIyH6Qiz9AcTtWbZMmPKPYLrLgmc1EOatGl7pY2aGl63DnxiZlp8Vwvb)NGcjUY2PTpicUhAEpc6ZwgJ8TiffdJg6XqbIIKBCPCI5Z0kpLfpwlpYnvu3mudZz(9pdmd3hNsosKKIm1i35fwaS4P)i9sOJL3JbhmnoEo(1Kg)i4iagpxfWKn5INm3LIRMb0UED4tWX7jOBn6LJ2XlPIKYLjfLiXnoQ)IQvO60zlrc9uM3W4o6azqh6Aful64M)afns(Q8DGnZ46)F7aoCdNQOjzb6w4uT3(Ddm3BQ5DEc9rzjlESS4VsKcWuaXAPU3KMvofTwGlZ10qa((sYc1Zlny(Q8XMcA60O5rAOQbk(RG5k1bMq5upTDCxubYcIceK2wYcooH9I4JJHWGn9SyDGRhP(msY2joBXcXeod1aKhUZPXRkIvOl6iUKf2pY7YEaxHpjp7(Qyg7rOyQiz79gZpFJq)Hfv3bpCrffEmeoYtMX8cxqiMbIlNY(WumS8SGZliHYWZhqBEWzy2CI08oFoYVkzw8uytD68elx5)TkKDj9hyH0h2WltGL6zUHbFaFkkWIIz8hwcSpNGSgArktgAw8CvujYg9Kk3IMkegftdIeIbSdqd3P6AtqMvvIr7dGMPZqGrZ(ctdkCeWhKmnCGxwO2Skbqaxps9C7fEblRGFJWPVu1eKxaeXtVSplfc)YjG4B277pYcCjXAEJneqTJLcP1vtwV2r5Za9oaPnphiZ0YqQInE(Mksor9IJd8c1bUIcb40)NQ53JPH0CSxQo27IUhnXapu(qH(iHxe88MzVvJwZ9JFkg4lIj1fWzJyHHA4NVpbZ94TVF2S4n4Mkglmql4AqJilw5KzvOnk9vWwm0ZiFqb8jh22fuzVq(lGwPpexYeaxSktZIn(d7xoSpWgpTOmQSFu6ZtNVPqy7mE0smQrogfE8tzAQLnZpDZ2(vMchJONBTWpTmbZam)Dbr1a0xiZYyjsz)NOgHAndd3ptoh5KM4cBTPjUOCA0eNy8KMiA9cVhkSr10daD(CFH1WuEVKhFArmMR8cKsQqsuKBAQCip(0zryMRVgNtULb)a9NQU0W9lIj9iqsMDNAVFGEpmAYRJUhM53FxYkqne6qa()QZhpmMZbPmDV4yz4VVUhlh9i0q5sNBLgOLAgCatySt06nRswWszp7ehAAa4amMwhAa0)pzDeZ6154SEclVqOpzrzX7CsfKj4sX4rt9z1WfxqqTQgYOxpRZyJiJTgRudMh2627ZmD3AvOe3r4pxp7GWRhAU6MPWQmLQfcjw4lhE92z5zCl)CgTpz8Ncsr9Ka2D1bakxsRwHPRV(eAvr8u(36qcKaFwxvMSICQZOmkejE)drvfLOb2xVjQSuVIaeMEWgcqNPryfHjrWtudFKwjryobgEXz(yhEB1rHwwJ4c(l)5520R6)FdUvRXE9DvflDj69))HRsM5aX9UioNcvX07YaZ2k2K8GjVpp96x)9xlJ70wEQ75XzkRIxpvXSKOJ5ZDtEsgqqF(e8pJxaRssDTwbpNx7vfzWYIPaEbf8sYffQOWYFERJcajaXGfVplKHetQeQvFXI2jD4GTW21hsa)eBEl5FehdSslYrnQOksIuY06vWu4DxvEktBlrsjb(zl4HbOOnyMPd1QobnO)BfC7HIDZfgbAYbIHQ9MkH8tLyX0f8qzIHmeNRb9hDbxPKxFKBKU9Ftv43V8Ew8gjBnqs0sa0RD29erLgYmp5AQO6om0RaQB7ygKUgCZ1jyemyAOjckMXXkct458AWmO7QAX41GO(3r7UqER)bpcWijD0XkN1rgYZQT37JnJisjPcXitZZk52D3PPSuXKEESAGJ4rt6yPrBZZJUplTelQZCKJzveGtgPTYR)3guJq1(1rYy5ox6OOQKHWOQzc7SceSLkOW6mAKUDwt7TKcaMcbgYuWSeljnIm6uyjUu6nGD42p9naefpxxnaJLqG6BVvG79ySrN9rNbYWqzUH(k6lzaY3dMxoVizE83OvUlCVcavwRIyLdnwYrO9JKZlicZI(AF4fY4skQWA9vm5wPHKOVY4X2VLC40b(7eaPrijDv5FkzY1I7wR4A9NLaR0QXcUSCD1bNE1H4jO5Y)HpeCKFxDSQpZDHTESD(O(y0DN(lCixJL(hiiC7T)g39sssMKBTogwT3XH)UmjT)snPkeNbZnCmAWo8bVz3VArDg4rOIPQYOKsRKmqXt2O61qTPSs4N5xgngLSZx7bMKJd8cDQSG)3p3mdwAu80u5Og0nnXUJJKz1ZnmlNeDqF3dL1roo6gWJcxjB7ihNInpJ4MA7BmUWoJi8uZgGNye97GsyBKy1jkDrbAOv1Mt48iKVdzSMlHT)TvP1pGNJVsbObOyrcg1zxBeAKF)oS6JEQx(c15YdJFIu8zBQwcVkMBZl7RkEAQeEKY4Dv70yuwAkLQSHOwzcKAMqXImQyjyqog)9LXtJxFxCErw1kwevYwSy69ZMtc8zBu(gD9otxVQN6y(eD9EdLzsoKxhJmf3)FHA1l4sMqE)SQcsPXSKOvySrbs3hzXVTiKRYO8U487aEqqRCoyhXsF0axJ0c)DKF)2HDb8InAfWuaEqnDt1)6Fb6JVl7tE3NCn0Mp(0qATh1wmW05x9AtM8)semaUPHfu6eyryqMWbJkO(eTgZISytTWzm2fKYbTIEpz2WqXznVLazq0uRKjAyPgPk7XrAjWAl9zzys9j7VHQvGdr9Sd3QdGQhMdImmub8hQKkC53eWzC(ygTBK8rF(i5dDrYh(ffjFuBJbGdLJTHAvVBjNGGrbWr)fY6KqQqUiTEKbbPObcstapb7kZNIEUGfxfUVx8Z1j)Ry(bDMNyVf76aEcUSciRdt9A0aj12lSRSkz3nDpey1Ziyw1dugw3a(C5vEVpdjcyrOMjkZynO60sw)PQBeSVGnjajZxExuejdA3BaYtWWLStSnVpN2ZbZe)TCqbDbXkhSw6fPHJ)It3iEpRcx1rdNUJK(9sSKnLYx8m8sP4HIKxryIuFXsZowiQCtQRvwYikfmB1RdNPd6gVcUmOvTSVt(Sq07Q7nhnvUct8emqRVtnkFunM8umTLqVMkWvF4WU(3Oj7c55awi(1RY4ahR3jgIMcXIxEI66)wrOpZzmP1Ty6bkOyYIb4WiMmhS94GCshggGVif45T4nc01DI9L)dWFywUVXtOmdED0YK7EF5Vxr9Gqh)D1Ax7TrnDHwnS)LcDBUuo3TbZMWmhnOj9MnTBnuPDjLuccn957KszqBgr5hZsW8N9yCUOGuyvj3jk(yW7E1lLgWWIJ8dkMbH29qJpsWnvRAtqrke3dfQL(cN1Z48lrBvlE7A6RZ67BWa)f4N95mhCx0EU4uWKXQL29EAx1LsdJBSVC2d2a9ZSxkK0A66znrLh)7SS5RQaPdGlaZkBCnotWRABBqnZ1MmreRgA6XKIp3HMbcSMUOk)zkIP(9ki8SeNxeNJKpAwmT0VLZYIK8ycEOjX0UVwojOqUIYCqXYmENOmkyRWQ14k0EH3uUI5lUEHcwUS8wScxD)Xsmy5(odo4ovqnkPiNSFXUVBdzY4n1AANb)l(iAz7NhL(a9y25rSTjhz22eIcZdfITvCnhOxKEYA6uw2aRJ(uY6Q1GMPzuOArbAFpUKIkVJfF3zvuXaVsVJDiySUA0OkpJEP9lI)m1p6iUs5VvR53)6AKHJyE8M5i31IU2ribM6Je(sqxAemSDzc)IHrLezJ58MaIFQ3Nf)ggKeopAAChBvULzmRA(wvBJrSri7BTjYO35VtPgDHqX(rEuItbnPJ74tBC3ECPXgI9DTe(bSsc(OaL198bmQOcRCJyEtAraSRSciO2IB2c91vMqRQnpeht5QyvrgPQgxYsw5J((SFKzsgQvqzrv2N9iXWqnSG(7p8(MBNTGwoCuOi4lX7xjaunWwgTah98gR7Gr7aE6SwQ8fZ(gUOsoG74T6mx7jPTGw0LM4J5PdIvwlrGP4P3pTaLxnppEvTzuVr4q7X6rh1A)6ncZ3d272sc7RgfOBd8vMru1uSRyE)IGsUtfaydIP4xxosx8VhzmJkrVlOuCPeovSS6fT6c7g2bm2jwmW45OfbSeGTK7pQ6gAOMXAhKzGBuA(MHgWZ7T02iCqE7f11)88gHmKDA2AI1OhXDCElm2SKz7hyCfgGe5v84BV56NIYXoWeS(4J4(sY6nuPgrBaFT0M2VwENmI2wLrwNvvMTMXibUXKEpDdm(FMGLA0WVdVSHaVQZPh)1Mop91m5wwFVGhgEE3HFQhDxe6aQy2eVBG0OdgifC(mtQUX06lN7MZ(zhyO1Z896cTgCKgtUN6)XCUp)Z)CFGOkx(kc5EM7xxi39DPI5Ae8cxXCL(2xrAKN5EVpd92xvAUNz)piLWP4t(DlYUj)8DUHpZ2y2aa91LZMy)WbVstVtcGSzf3nsGLiFEw5T7Ftjy6VfpnPa(MC7wi1AYDoKwn5o6BuhGURX8Qo9noXoAiwhuL9gU33P3VcXd5MPVj)GWg6hY3psYR8034eVVSGTeU33P3ROzQnL3nXsEm22Qk1nKD6TTGBe35YE17oqtjZU7nrZ52JfyhK5(IxX5EOhIUZ22Xyjc2ApnO5A28IDJ54q72ZRRjZVUZULjw2cFO4dhsYJyaVstSFZTSf44EkDmany9WnXnEyyVzYg6HR1UspmLPznaVlHhPASAeXyA1lCK2ov7p67zcpKOVNtA7pm7zc)maZ7ZwMhDd7p6FOD28aoHUn0iBhTYWtmbScdTbC5nm1MiSh89am)B)5FIqDCA)2T8RkPT3s)0LapgV7AYwKGzY9RWFoyoi3atB)z(N7l91CS6DX02FgwRD9okYXKE84VreE)tWK7oMpl1LT9ju6Php8KKfJ97PqNUh53hLxEjG5UtghWg(E)ra5rQGSnuPaY24tni7aQMeaD8aXIlzvCBRTxyrEMjTloPtSU3Ky7uQz24NPv9p2f9QewgRIjhKRVv5udihEfXIG)r61cdXSVF3XQQZUoBJwfuYzzcKCLRgXbJD4Mt1)IBKkn(Y7SUeMC2fQN2B39cQ)vw5AjIVQDDw9zV8IZ6D7Lx4LjP2LWkmyTYN8LxKhmcF5RE1Ob9E5LUgvrzhTpZte1vJhbdT(kwDY43oaGgGpUJwnRD143nGiyFgULrdWDzxZ1NKTzmDbSEISEMh7SetOrpr(i9RG0o(FLR0Od8Dx)d)K6l80XEwmv8ZSkZ44PSNyzxPOmXpg9)7lV4)koLZq556n19tRFG21AAZql4(lte8R9fkQkOyiXgfVXGDZ7NZoQ5FEY4rV8YrCRumJtDhf57gV15Qln)iePi0Zm5buC91c2SlcTKUj8GSKwmi2DSNY40Vmor0qVWFNmE4fh7UAUSNf6k7u97nUHovFK2fYjPbLK9ZoKW4HoqxGa1A5bMtlXiUBYD(rBb3HNS4WKGB2hcTC5Kc(9UQYraYVLIpSQcAqQDhdP79iY3FcTBFBXDlm2qCwhh9XHjs25ih1gChhn0O6(QRN7yJWepyYSXthUaS523hatgnaT(1D0V64GRbmh2ZGL78195V2eOuVmxnEyVoDTljLjdDRhF4agNYU0E7MKgS1WtkJxZ2ID36(NO0)4m1xDDA6thNL5pGvd752oKrJcdo2DrVhqXY4S9CbD0s82ROlEOa2CmYpO8vI((5W3O7(WZItiVFfU9XiH(7j5Xd701X5upOezQAGjBKMxW6r7e0L7sGqa7)GLdwVJ8VE9AjryuteHrhsIWqn)Q)Cqe(QVICf9Xm8xc2F8tGQqWhXcMALATmKgCD6vc9otJ5VcDtuXoOSj7jqHAs6IkmGIItf2DOJXgGCa4BeQ519rBzNzAULZ)32Vwo3sXbSsk2gkLT5vzg39UoD3jjKVTNI)G1pMCB0TpMUf65sZKtDXsDBE6LYxEXDFuYwyp9qPhzU8oW6nVTH9U2133nSdzhSBRTM2sJA9jExi4HQDTBaDzg20XYIt53CaPhDRnI1tdypzq)3DmFH9141Dc101tUOhJdtVvR9WU3WUrpLTJDVtP9r43nsTX20(s5)Z706(2SY2KV6WH5uG6o5GK5SlFhMbH(I0MAtkF1L9SeI3nGE2XxmWNux3eYHSGs(LsNdBsYuI6yDax0BL4oDTILWGbUdMqnlQeMb6oBLNqHLCN0hEzDGDQ5q2bIVGj(sllazDHlIXecB0PVoNSZgidERQUaZzUU7CjRHAXliBe3w(cYEUTLJxV9AB5l5oWtS(bWoXdD80teJhynVzIEKfNfRWJXI4XFj(jKOgZyHJtpkIUBbkah7u7tGsggQz0TQwSxEX9Cn28hncqnJupjBdoWpveWPXb(M5jQ)8qO6uHMwLETmzlYFdgCqW0dSu9DFQmK82Tz0KHkQ50PGUHtcm9)Z2GdOsCdUQgny9QvZJ6zoz3(2(xUJ45M(htztTfr10HoEXjlGMDdi)xkq(Vc0zu19FY)Sh4GY54cUxZtAvmJzhDWFvcA5kO15ISyGT)Riqy)J(JxqlbBpGPhvwxnO)B701LLCxOAcz4Fado12PORgJ)WfWeAUV)6d86HWE4)7yCz)4qLN5VEaEwDNMuXJJZE87gGdirRie8rd6EK1LRFNa1YaOL8yJCAiCS1zXf3Zn(qsn(CEx53i5XXr5J4gw7(Mz3fLZzEZyFPHmB3cDds4pJj79lHRW)GABDYLXDQO(6ZxKfE7BYFWdr1S(t8y9qDCEc4NPP7O4i(SRUGmoX98(TpKU6DNZ5iFwJQLOV2XxmEe)eM5LPFdMx4yzeoB8546Wrb6YST71)fvJOWJcqrEJi2s23eqVzuVj)nUm2d6DCtBqN6RFbosWoa44A7zs9UJFkbZzJdY9cJj0BeymxC4A0FqPGwzLeWvpM4DXnRZKrYYYYOY1add6CKZOofn)5o2zc(ur4OUKOlhQ7Tgtkdx0UPN6kbcQtxZ8wRszca4dh5BXCq(3RfV2KgJAiSbf(nb1FLsrwCGP3CTMne)G9KI398J76RwUFZf9oURp61BUSxpFqQJnR9eY76D)sZZEdzl9EfXy1dwVQ30kbo25R81cCk4LxKwwGAGPQhTbtTa7nSFN3mQ53YpXV3KZdfuqwwMVwy2dwR)efGhSgmb1f0jm88dVa9Pm4GLHOT9AscO0qQJdK0w3XG2tQx7vhVbz(Au(OGUn0kncmxCRnPefjyKQeIJOinAtXYmUA2FL8Sfa5hudnLkAPLKdoGOuJXYev4iBjFLsWtrc7AzuXi(xwWleuxDy1jO0Q4D6oG)AWMK57mDyuak)cXibmjCojgXK5PQDus2ziKGfp1vBNJSjXQMTAhUOFIx5xsPhFNmes429VRxDS4SRmwm8ZrZi7VimN4qePpMT)WnrfdfYpPDfGGX2KUdqCtkcOF1FrhxlyO7WrN6ZhMEV8IPmiMlqEUJsaci3YifhiVkG0ME9u1pyKCt3YfplOQHrHPrHPjUzjSed7mrvby2KjAQNhr9xOB8HdbkurdWLNyilrOcJNJrUxYoPc7NziDDrvCMYSECxVUw0Nn11l8T)tkdtIultS)whOSQbUA0GLGQJXe8LHDqrb4wZS4tG5zAA8NWIUh(38OPrRXJyJp)cEXbylwg75mfP3fXLvBkCSqMz02oHL7sfH2vnIkUyOeptXWGEEQkTa1I4WrHE8Klh4JfmKNOt(BN3BViqElWw(3BCAHfG56k1T2cjDcedxoBNPoe6Bv9awtIGwEURsvHvcw69iYvmTBcoC6S6g0dpfg7a15KKGQKewpeOVa54o)aYrTtNTfKB6qnO5l6rIal03kKL0OQ0VOi)HOzDp7uba4u7BpBYIT9vbmX2bHimDqV0nSRYJXN5XgrVh54VHJYmvfZKXi0no2MD2xjjsUQT3xfbo0nf9SB(1rx8o6AP8M)V)]] )