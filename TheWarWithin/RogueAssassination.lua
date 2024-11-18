-- RogueAssassination.lua
-- October 2024

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints
local strformat, insert, sort, wipe, max = string.format, table.insert, table.sort, table.wipe, math.max
local UA_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID


local orderedPairs = ns.orderedPairs

local spec = Hekili:NewSpecialization( 259 )

spec:RegisterResource( Enum.PowerType.ComboPoints )

spec:RegisterResource( Enum.PowerType.Energy, {
    garrote_vim = {
        talent = "venomous_wounds",
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
            return state.debuff.poisoned.down or state.active_dot.garrote == 0
        end,

        interval = function ()
            return state.debuff.garrote.tick_time
        end,

        value = function () return state.poisoned_garrotes * 8 end
    },
    rupture_vim = {
        talent = "venomous_wounds",
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
            return state.debuff.poisoned.down or state.active_dot.rupture == 0
        end,

        interval = function ()
            return state.debuff.rupture.tick_time
        end,

        value = function () return state.poisoned_ruptures * 8 end
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
    acrobatic_strikes      = {  90752, 455143, 1 }, -- Auto-attacks increase auto-attack damage and movement speed by 1.0% for 3 sec, stacking up to 10%.
    airborne_irritant      = {  90741, 200733, 1 }, -- Blind has 50% reduced cooldown, 70% reduced duration, and applies to all nearby enemies.
    alacrity               = {  90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison        = {  90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 21% chance of poisoning the enemy, reducing their damage by 3.6% for 10 sec.
    blackjack              = {  90686, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    blind                  = {  90684,   2094, 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    cheat_death            = {  90742,  31230, 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows       = {  90697,  31224, 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood             = {  90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves        = {  90743, 231719, 1 }, -- Physical damage taken reduced by 5%.
    deadly_precision       = {  90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem       = {  90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand      = {  90638, 470669, 1 }, -- After consuming a supercharged combo point, your next Mutilate also strikes the target with an Echoing Reprimand dealing 20,557 Physical damage.
    elusiveness            = {  90742,  79008, 1 }, -- Evasion also reduces damage taken by 20%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                = {  90764,   5277, 1 }, -- Increases your dodge chance by 100% for 10 sec.
    featherfoot            = {  94563, 423683, 1 }, -- Sprint increases movement speed by an additional 30% and has 4 sec increased duration.
    fleet_footed           = {  90762, 378813, 1 }, -- Movement speed increased by 15%.
    forced_induction       = {  90638, 470668, 1 }, -- Increase the bonus granted when a damaging finishing move consumes a supercharged combo point by 1.
    gouge                  = {  90741,   1776, 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    graceful_guile         = {  94562, 423647, 1 }, -- Feint has 1 additional charge.
    improved_ambush        = {  90692, 381620, 1 }, -- Ambush generates 1 additional combo point.
    improved_sprint        = {  90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison  = {  90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach           = {  90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison        = {  90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 7% Leech.
    lethality              = {  90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    master_poisoner        = {  90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nimble_fingers         = {  90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison         = {  90763,   5761, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 21% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 18% for 10 sec.
    recuperator            = {  90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 3 sec.
    rushed_setup           = {  90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    shadowheart            = { 101714, 455131, 1 }, -- Leech increased by 2% while Stealthed.
    shadowrunner           = {  90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shiv                   = {  90740,   5938, 1 }, -- Attack with your poisoned blades, dealing 66,434 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Your Nature and Bleed damage done to the target is increased by 30% for 8 sec. Awards 1 combo point.
    soothing_darkness      = {  90691, 393970, 1 }, -- You are healed for 30% of your maximum health over 6 sec after activating Vanish.
    stillshroud            = {  94561, 423662, 1 }, -- Shroud of Concealment has 50% reduced cooldown.
    subterfuge             = {  90688, 108208, 2 }, -- Abilities requiring Stealth can be used for 3 sec after Stealth breaks. Combat benefits requiring Stealth persist for an additional 3 sec after Stealth breaks.
    supercharger           = {  90639, 470347, 2 }, -- Shiv supercharges 1 combo point. Damaging finishing moves consume a supercharged combo point to function as if they spent 2 additional combo points.
    superior_mixture       = {  94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional 10%.
    thistle_tea            = {  90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 13.6% for 6 sec. When your Energy is reduced below 30, drink a Thistle Tea.
    thrill_seeking         = {  90695, 394931, 1 }, -- Shadowstep has 1 additional charge.
    tight_spender          = {  90692, 381621, 1 }, -- Energy cost of finishing moves reduced by 6%.
    tricks_of_the_trade    = {  90686,  57934, 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride     = {  90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                  = {  90759,  14983, 2 }, -- Increases your maximum Energy by 50 and Energy regeneration by 5%.
    virulent_poisons       = {  90760, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.
    without_a_trace        = { 101713, 382513, 1 }, -- Vanish has 1 additional charge.

    -- Assassination
    amplifying_poison      = {  90621, 381664, 1 }, -- Coats your weapons with a Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 21% chance to poison the enemy, dealing 2,339 Nature damage and applying Amplifying Poison for 12 sec. Envenom can consume 10 stacks of Amplifying Poison to deal 35% increased damage. Max 20 stacks.
    arterial_precision     = {  90784, 400783, 1 }, -- Shiv strikes 4 additional nearby enemies and increases your Bleed damage done to affected targets by 30% for 8 sec.
    blindside              = {  90786, 328085, 1 }, -- Ambush and Mutilate have a 15% chance to make your next Ambush free and usable without Stealth. Chance increased to 30% if the target is under 35% health.
    bloody_mess            = {  90625, 381626, 1 }, -- Garrote and Rupture damage increased by 15%.
    caustic_spatter        = {  94556, 421975, 1 }, -- Using Mutilate on a target afflicted by your Rupture and Deadly Poison applies Caustic Spatter for 10 sec. Limit 1. Caustic Spatter causes 40% of your Poison damage dealt to splash onto other nearby enemies, reduced beyond 5 targets.
    crimson_tempest        = {  90632, 121411, 1 }, -- Finishing move that slashes all enemies within 10 yards, causing victims to bleed. Lasts longer per combo point. Deals extra damage when multiple enemies are afflicted, increasing by 20% per target, up to 100%. Deals reduced damage beyond 5 targets. 1 point : 39,269 over 6 sec 2 points: 49,648 over 8 sec 3 points: 60,027 over 10 sec 4 points: 70,406 over 12 sec 5 points: 80,786 over 14 sec 6 points: 91,165 over 16 sec 7 points: 101,544 over 18 sec
    dashing_scoundrel      = {  90766, 381797, 1 }, -- Envenom's effect also increases the critical strike chance of your weapon poisons by 5%, and their critical strikes generate 1 Energy.
    deadly_poison          = {  90783,   2823, 1 }, -- Coats your weapons with a Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 21% chance to poison the enemy for 25,032 Nature damage over 12 sec. Subsequent poison applications will instantly deal 2,339 Nature damage.
    deathmark              = {  90769, 360194, 1 }, -- Carve a deathmark into an enemy, dealing 97,008 Bleed damage over 16 sec. While marked your Garrote, Rupture, and Lethal poisons applied to the target are duplicated, dealing 100% of normal damage.
    doomblade              = {  90777, 381673, 1 }, -- Mutilate deals an additional 20% Bleed damage over 8 sec.
    dragontempered_blades  = {  94553, 381801, 1 }, -- You may apply 1 additional Lethal and Non-Lethal Poison to your weapons, but they have 30% less application chance.
    fatal_concoction       = {  90626, 392384, 1 }, -- Increases the damage of your weapon poisons by 10%.
    flying_daggers         = {  94554, 381631, 1 }, -- Fan of Knives has its radius increased to 12 yds, deals 15% more damage, and an additional 15% when striking 5 or more targets.
    improved_garrote       = {  90780, 381632, 1 }, -- Garrote deals 50% increased damage and has no cooldown when used from Stealth and for 12 sec after breaking Stealth.
    improved_poisons       = {  90634, 381624, 1 }, -- Increases the application chance of your weapon poisons by 5%.
    improved_shiv          = {  90628, 319032, 1 }, -- Shiv now also increases your Nature damage done against the target by 30% for 8 sec.
    indiscriminate_carnage = {  90774, 381802, 1 }, -- Garrote and Rupture apply to 2 additional nearby enemies when used from Stealth and for 12 sec after breaking Stealth.
    intent_to_kill         = {  94555, 381630, 1 }, -- Shadowstep's cooldown is reduced by 33% when used on a target afflicted by your Garrote.
    internal_bleeding      = {  94556, 381627, 1 }, -- Kidney Shot and Rupture also apply Internal Bleeding, dealing up to 36,373 Bleed damage over 6 sec, based on combo points spent.
    iron_wire              = {  94555, 196861, 1 }, -- Garrote silences the target for 5 sec when used from Stealth. Enemies silenced by Garrote deal 15% reduced damage for 5 sec.
    kingsbane              = {  94552, 385627, 1 }, -- Release a lethal poison from your weapons and inject it into your target, dealing 55,959 Nature damage instantly and an additional 48,216 Nature damage over 14 sec. Each time you apply a Lethal Poison to a target affected by Kingsbane, Kingsbane damage increases by 20%, up to 1,000%. Awards 1 combo point.
    lethal_dose            = {  90624, 381640, 2 }, -- Your weapon poisons, Nature damage over time, and Bleed abilities deal 1% increased damage to targets for each weapon poison, Nature damage over time, and Bleed effect on them.
    lightweight_shiv       = {  90633, 394983, 1 }, -- Shiv deals 100% increased damage and has 1 additional charge.
    master_assassin        = {  90623, 255989, 1 }, -- Critical strike chance increased by 25% while Stealthed and for 12 sec after breaking Stealth.
    path_of_blood          = {  94536, 423054, 1 }, -- Increases maximum Energy by 100.
    poison_bomb            = {  90767, 255544, 2 }, -- Envenom has a 4% chance per combo point spent to smash a vial of poison at the target's location, creating a pool of acidic death that deals 36,419 Nature damage over 2 sec to all enemies within it.
    rapid_injection        = {  94557, 455072, 1 }, -- Envenom's effect increases the damage of Envenom by 10%.
    sanguine_blades        = {  90779, 200806, 1 }, -- While above 50% of maximum Energy your Garrote, Rupture, and Crimson Tempest consume 2 Energy to duplicate 30% of any damage dealt.
    sanguine_stratagem     = {  94554, 457512, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    scent_of_blood         = {  90775, 381799, 2 }, -- Each enemy afflicted by your Rupture increases your Agility by 2%, up to a maximum of 20%.
    seal_fate              = {  90757,  14190, 1 }, -- Critical strikes with attacks that generate combo points grant an additional combo point per critical strike.
    serrated_bone_spikes   = {  90622, 455352, 1 }, -- Prepare a Serrated Bone Spike every 30 sec, stacking up to 3. Rupture spends a stack to embed a bone spike in its target.  Serrated Bone Spike: Deals 30,356 Physical damage and 4,138 Bleed damage every 2.4 sec until the target dies or leaves combat. Refunds a stack when the target dies. Awards 1 combo point plus 1 additional per active bone spike.
    shrouded_suffocation   = {  90776, 385478, 1 }, -- Garrote damage increased by 20%. Garrote generates 2 additional combo points when used from Stealth.
    sudden_demise          = {  94551, 423136, 1 }, -- Bleed damage increased by 10%. Targets below 35% health instantly bleed out and take fatal damage when the remaining Bleed damage you would deal to them exceeds 150% of their remaining health.
    systemic_failure       = {  90771, 381652, 1 }, -- Garrote increases the damage of Ambush and Mutilate on the target by 20%.
    thrown_precision       = {  90630, 381629, 1 }, -- Fan of Knives has 10% increased critical strike chance and its critical strikes always apply your weapon poisons.
    tiny_toxic_blade       = {  90770, 381800, 1 }, -- Shiv deals 200% increased damage and no longer costs Energy.
    twist_the_knife        = {  90768, 381669, 1 }, -- Envenom duration increased by 2 sec. Envenom can now overlap 2 times.
    venomous_wounds        = {  90635,  79134, 1 }, -- You regain 8 Energy each time your Garrote or Rupture deal Bleed damage to a poisoned target. If an enemy dies while afflicted by your Rupture, you regain energy based on its remaining duration.
    vicious_venoms         = {  90772, 381634, 2 }, -- Ambush and Mutilate cost 5 more Energy and deal 35% additional damage as Nature.
    zoldyck_recipe         = {  90785, 381798, 2 }, -- Your Poisons and Bleeds deal 15% increased damage to targets below 35% health.

    -- Deathstalker
    bait_and_switch        = {  95106, 457034, 1 }, -- Evasion reduces magical damage taken by 20%. Cloak of Shadows reduces physical damage taken by 20%.
    clear_the_witnesses    = {  95110, 457053, 1 }, -- Your next Fan of Knives after applying Deathstalker's Mark deals an additional 23,752 Plague damage and generates 1 additional combo point.
    corrupt_the_blood      = {  95108, 457066, 1 }, -- Rupture deals an additional 593 Plague damage each time it deals damage, stacking up to 10 times. Rupture duration increased by 3 sec.
    darkest_night          = {  95142, 457058, 1 }, -- When you consume the final Deathstalker's Mark from a target or your target dies, gain 40 Energy and your next Envenom cast with maximum combo points is guaranteed to critically strike, deals 60% additional damage, and applies 3 stacks of Deathstalker's Mark to the target.
    deathstalkers_mark     = {  95136, 457052, 1, "deathstalker" }, -- Ambush from Stealth applies 3 stacks of Deathstalker's Mark to your target. When you spend 5 or more combo points on attacks against a Marked target you consume an application of Deathstalker's Mark, dealing 28,502 Plague damage and increasing the damage of your next Ambush or Mutilate by 50%. You may only have one target Marked at a time.
    ethereal_cloak         = {  95106, 457022, 1 }, -- Cloak of Shadows duration increased by 2 sec.
    fatal_intent           = {  95135, 461980, 1 }, -- Your damaging abilities against enemies above 20% health have a very high chance to apply Fatal Intent. When an enemy falls below 20% health, Fatal Intent inflicts 5,341 Plague damage per stack.
    follow_the_blood       = {  95131, 457068, 1 }, -- Fan of Knives and Crimson Tempest deal 30% additional damage while 2 or more enemies are afflicted with Rupture.
    hunt_them_down         = {  95132, 457054, 1 }, -- Auto-attacks against Marked targets deal an additional 5,938 Plague damage.
    lingering_darkness     = {  95109, 457056, 1 }, -- After Deathmark expires, gain 30 sec of 30% increased Nature damage.
    momentum_of_despair    = {  95131, 457067, 1 }, -- If you have critically struck with Fan of Knives, increase the critical strike chance of Fan of Knives and Crimson Tempest by 15% and critical strike damage by 32% for 12 sec.
    shadewalker            = {  95123, 457057, 1 }, -- Each time you consume a stack of Deathstalker's Mark, reduce the cooldown of Shadowstep by 3 sec.
    shroud_of_night        = {  95123, 457063, 1 }, -- Shroud of Concealment duration increased by 5 sec.
    singular_focus         = {  95117, 457055, 1 }, -- Damage dealt to targets other than your Marked target deals 5% Plague damage to your Marked target.
    symbolic_victory       = {  95109, 457062, 1 }, -- Shiv additionally increases the damage of your next Envenom by 18%.

    -- Fatebound
    chosens_revelry        = {  95138, 454300, 1 }, -- Leech increased by 0.5% for each time your Fatebound Coin has flipped the same face in a row.
    deal_fate              = {  95107, 454419, 1 }, -- Mutilate, Ambush, and Fan of Knives generate 1 additional combo point when they trigger Seal Fate.
    deaths_arrival         = {  95130, 454433, 1 }, -- Shadowstep may be used a second time within 3 sec with no cooldown, but its total cooldown is increased by 5 sec.
    delivered_doom         = {  95119, 454426, 1 }, -- Damage dealt when your Fatebound Coin flips tails is increased by 30% if there are no other enemies near the target. Each additional nearby enemy reduces this bonus by 6%.
    destiny_defined        = {  95114, 454435, 1 }, -- Weapon poisons have 5% increased application chance and your Fatebound Coins flipped have an additional 5% chance to match the same face as the last flip.
    double_jeopardy        = {  95129, 454430, 1 }, -- Your first Fatebound Coin flip after breaking Stealth flips two coins that are guaranteed to match the same outcome.
    edge_case              = {  95139, 453457, 1 }, -- Activating Deathmark flips a Fatebound Coin and causes it to land on its edge, counting as both Heads and Tails.
    fate_intertwined       = {  95120, 454429, 1 }, -- Fate Intertwined duplicates 30% of Envenom critical strike damage as Cosmic to 2 additional nearby enemies. If there are no additional nearby targets, duplicate 30% to the primary target instead.
    fateful_ending         = {  95127, 454428, 1 }, -- When your Fatebound Coin flips the same face for the seventh time in a row, keep the lucky coin to gain 7% Agility until you leave combat for 10 seconds. If you already have a lucky coin, it instead deals 85,507 Cosmic damage to your target.
    hand_of_fate           = {  95125, 452536, 1, "fatebound" }, -- Flip a Fatebound Coin each time a finishing move consumes 5 or more combo points. Heads increases the damage of your attacks by 10%, lasting 15 sec or until you flip Tails. Tails deals 42,753 Cosmic damage to your target. For each time the same face is flipped in a row, Heads increases damage by an additional 2% and Tails increases its damage by 10%.
    inevitabile_end        = {  95114, 454434, 1 }, -- Cold Blood now benefits the next two abilities but only applies to Envenom. Fatebound Coins flipped by these abilities are guaranteed to match the same outcome as the last flip.
    inevitable_end         = {  95114, 454434, 1 }, -- Cold Blood now benefits the next two abilities but only applies to Envenom. Fatebound Coins flipped by these abilities are guaranteed to match the same outcome as the last flip.
    inexorable_march       = {  95130, 454432, 1 }, -- You cannot be slowed below 70% of normal movement speed while your Fatebound Coin flips have an active streak of at least 2 flips matching the same face.
    mean_streak            = {  95122, 453428, 1 }, -- Fatebound Coins flipped by Envenom multiple times in a row are 33% more likely to match the same face as the last flip.
    tempted_fate           = {  95138, 454286, 1 }, -- You have a chance equal to your critical strike chance to absorb 10% of any damage taken, up to a maximum chance of 40%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5530, -- (354406)
    creeping_venom     =  141, -- (354895)
    dagger_in_the_dark = 5550, -- (198675)
    death_from_above   = 3479, -- (269513) Finishing move that empowers your weapons with energy to perform a deadly attack.; You leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $269512s2% stronger effect.
    dismantle          = 5405, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for 5 sec.
    hemotoxin          =  830, -- (354124)
    maneuverability    = 3448, -- (197000)
    smoke_bomb         = 3480, -- (212182) Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud.
    system_shock       =  147, -- (198145)
    thick_as_thieves   = 5408, -- (221622)
    veil_of_midnight   = 5517, -- (198952)
} )


spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )

spec:RegisterStateExpr( "effective_combo_points", function ()
    local c = combo_points.current or 0

    if c > 0 and buff.supercharged_combo_points.up then
        c = c + ( talent.forced_induction.enabled and 3 or 2 )
    end

    return c
end )


local stealth = {
    normal = { "stealth" },
    vanish = { "vanish" },
    subterfuge = { "subterfuge" },
    shadow_dance = { "shadow_dance" },
    shadowmeld = { "shadowmeld" },
    sepsis = { "sepsis_buff" },

    improved_garrote = { "improved_garrote_aura", "improved_garrote", "sepsis_buff" },

    basic = { "stealth", "vanish" },
    mantle = { "stealth", "vanish" },
    rogue = { "stealth", "vanish", "subterfuge", "shadow_dance" },
    ambush = { "stealth", "vanish", "subterfuge", "shadow_dance", "sepsis_buff" },

    all = { "stealth", "vanish", "shadowmeld", "subterfuge", "shadow_dance", "sepsis_buff", "improved_garrote_aura", "improved_garrote" },
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
    if buff.master_assassin_any.up then return buff.master_assassin_any.remains end
    return 0
end )

spec:RegisterStateExpr( "indiscriminate_carnage_remains", function ()
    if not talent.indiscriminate_carnage.enabled then return 0 end
    return buff.indiscriminate_carnage_any.remains
end )

local stealth_dropped = 0

local function isStealthed()
    return ( UA_GetPlayerAuraBySpellID( 1784 ) or UA_GetPlayerAuraBySpellID( 115191 ) or UA_GetPlayerAuraBySpellID( 115192 ) or UA_GetPlayerAuraBySpellID( 11327 ) or GetTime() - stealth_dropped < 0.2 )
end

local calculate_multiplier = setfenv( function( spellID )
    local mult = 1

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
        rate = {},
        last_tick = {},
        haste = {}
    }

    tracked_bleeds[ spellID ] = tracked_bleeds[ key ]
end

local function ApplyBleed( key, target )
    local bleed = tracked_bleeds[ key ]

    bleed.rate[ target ]         = 1
    bleed.last_tick[ target ]    = GetTime()
    bleed.haste[ target ]        = 100 + GetHaste()
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
    bleed.haste[ target ]        = nil
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

local envenom1 = 0
local envenom2 = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if removal_events[ subtype ] then
            if stealth_spells[ spellID ] then
                stealth_dropped = GetTime()
                return
            end
        end

        if spellID == 32645 and destGUID == state.GUID and application_events[ subtype ] then
            local now = GetTime()
            last = last or now

            local buff = UA_GetPlayerAuraBySpellID( 32645 )

            if not buff then
                envenom1 = 0
                envenom2 = 0
                return
            end

            if not state.talent.twist_the_knife.enabled then
                envenom1 = buff.expirationTime or 0
                envenom2 = 0
                return
            end

            local exp = buff.expirationTime or 0
            envenom2 = min( exp, envenom1 )
            envenom1 = exp

            --[[ print( format( "Updated Envenom at %.2f, %.2f (%.2f), [1] %.2f (%.2f), [2] %.2f (%.2f)", now, exp, exp - now,
                envenom1, envenom1 - now,
                envenom2, envenom2 - now ) ) ]]
            return
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
    if resource == "energy" and amt > 0 then
        if legendary.duskwalkers_patch.enabled and cooldown.vendetta.remains > 0 then
            energy_spent = energy_spent + amt
            local reduction = floor( energy_spent / 30 )
            energy_spent = energy_spent % 30

            if reduction > 0 then
                reduceCooldown( "vendetta", reduction )
            end
        end

        if talent.thistle_tea.enabled and energy.current < 30 and cooldown.thistle_tea.charges > 0 then
            spendCharges( "thistle_tea", 1 )
            gain( 100, "energy" )
            applyBuff( "thistle_tea" )
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

        if amt > 4 and debuff.deathstalkers_mark.up then
            removeDebuffStack( "target", "deathstalkers_mark" )
            if debuff.deathstalkers_mark.down and talent.darkest_night.enabled then
                    gain( 40, "energy" )
                    applyBuff( "darkest_night" )
                end
            applyBuff( "deathstalkers_mark_buff" )
        end
    end
end )

spec:RegisterStateExpr( "poison_chance", function ()
    return ( 0.3 + ( talent.destiny_defined.enabled and 0.05 or 0 ) + ( talent.improved_poisons.enabled and 0.05 or 0 ) ) * ( talent.dragontempered_blades.enabled and 0.7 or 1 )
end )

spec:RegisterStateExpr( "persistent_multiplier", function ()
    if not this_action then return 1 end
    if this_action == "garrote" and buff.improved_garrote_any.up then return 1.5 end
    return 1
end )

-- Enemies with either Deadly Poison or Wound Poison applied.
spec:RegisterStateExpr( "poisoned_enemies", function ()
    return ns.countUnitsWithDebuffs( "deadly_poison_dot", "wound_poison_dot", "amplifying_poison_dot" )
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


-- Count of Garrotes on all poisoned (Deadly/Wound) targets.
spec:RegisterStateExpr( "poisoned_garrotes", function ()
    return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "amplifying_poison_dot", "garrote" )
end )

-- Count of Ruptures on all poisoned (Deadly/Wound) targets.
spec:RegisterStateExpr( "poisoned_ruptures", function ()
    return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "amplifying_poison_dot", "rupture" )
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
    if not this_action or this_action == "variable" then return 0 end

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
        if buff.shadow_dance.up then return buff.shadow_dance.remains + spec.auras.improved_garrote.duration end
        return buff.improved_garrote_any.remains
    end
    return 0
end )


local first_envenom = 0
local second_envenom = 0

spec:RegisterStateExpr( "envenom_stacks", function ()
    return ( first_envenom > query_time and 1 or 0 ) + ( second_envenom > query_time and 1 or 0 )
end )

spec:RegisterStateExpr( "envenom_2_remains", function ()
    if not talent.twist_the_knife.enabled then return buff.envenom.remains end
    return max( 0, second_envenom - query_time )
end )

spec:RegisterStateExpr( "priority_rotation", function ()
    return toggle.funnel
end )


local ExpireSepsis = setfenv( function ()
    applyBuff( "sepsis_buff" )

    if legendary.toxic_onslaught.enabled then
        applyBuff( "adrenaline_rush", 10 )
        applyBuff( "shadow_blades", 10 )
    end
end, state )


-- Tier 31
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207239, 217208, 217210, 217206, 217207, 217209 )
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
    -- Supercharged Combo Point handling
    local cPoints = GetUnitChargedPowerPoints( "player" )
    if talent.supercharger.enabled and cPoints then
        local charged = 0
        for _, point in pairs( cPoints ) do
            charged = charged + 1
        end
        if charged > 0 then applyBuff( "supercharged_combo_points", nil, charged ) end
    end

    if covenant.night_fae and debuff.sepsis.up then
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

    if not kingsbaneReady then
        rawset( buff, "kingsbane", buff.kingsbane_buff )
        rawset( debuff, "kingsbane", debuff.kingsbane_dot )
        kingsbaneReady = true
    end

    if talent.indiscriminate_carnage.enabled and buff.stealth.up then
        applyBuff( "indiscriminate_carnage_aura", 3600 )
        removeBuff( "indiscriminate_carnage" )
    end

    if talent.master_assassin.enabled and buff.stealth.up then
        applyBuff( "master_assassin_aura", 3600 )
        removeBuff( "master_assasin" )
    end

    -- Tracking Envenom buff stacks.
    first_envenom = min( buff.envenom.expires, envenom1 )
    second_envenom = envenom2

    if Hekili.ActiveDebug then
        if talent.twist_the_knife.enabled then Hekili:Debug( "Envenoms:  [1] = %.2f, [2] = %.2f", max( 0, first_envenom - query_time ), max( second_envenom - query_time, 0 ) ) end
        Hekili:Debug( "Energy Cap in %.2f -- Enemies: %d, Bleeds: %d, P. Bleeds: %d, P. Garrotes: %d, P. Ruptures: %d", energy.time_to_max, active_enemies, bleeds, poisoned_bleeds, poisoned_garrotes, poisoned_ruptures )
    end
end )

-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if stealthed.mantle and ( not a or a.startsCombat ) then
        if talent.master_assassin.enabled then
            removeBuff( "master_assassin_aura" )
            applyBuff( "master_assassin" )
        end

        if talent.improved_garrote.enabled then
            removeBuff( "improved_garrote_aura" )
            applyBuff( "improved_garrote" )
        end

        if talent.indiscriminate_carnage.enabled then
            removeBuff( "indiscriminate_carnage_aura" )
            applyBuff( "indiscriminate_carnage" )
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark", 4 )
        end

        if buff.stealth.up then
            setCooldown( "stealth", 2 )
            removeBuff( "stealth" )
            if talent.subterfuge.enabled then applyBuff( "subterfuge" ) end
        end

        if buff.shadowmeld.up then removeBuff( "shadowmeld" ) end
        if buff.vanish.up then removeBuff( "vanish" ) end
    end

    if buff.cold_blood.up and ( ability == "envenom" or not talent.inevitable_end.enabled ) and ( not a or a.startsCombat ) then
        removeStack( "cold_blood" )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
end )


-- Auras
spec:RegisterAuras( {
    acrobatic_strikes = {
        id = 455144,
        duration = 3,
        max_stack = 10
    },
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
    -- Talent: Each strike has a chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    -- https://wowhead.com/beta/spell=381637
    atrophic_poison = {
        id = 381637,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Damage reduced by ${$W1*-1}.1%.
    -- https://wowhead.com/beta/spell=392388
    atrophic_poison_dot = {
        id = 392388,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    audacity = {
        id = 386270,
        duration = 10,
        max_stack = 1,
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
        duration = function() return 60 * ( talent.airborne_irritant.enabled and 0.7 or 1 ) end,
        mechanic = "disorient",
        type = "Ranged",
        max_stack = 1
    },
    blindside = {
        id = 121153,
        duration = 10,
        max_stack = 1,
    },
    -- Real RtB buffs.
    broadside = {
        id = 193356,
        duration = 30,
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
    clear_the_witnesses = {
        id = 457178,
        duration = 12,
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
        id = function() return talent.inevitable_end.enabled and not state.spec.subtlety and 456330 or 382245 end,
        duration = 3600,
        max_stack = function() return talent.inevitable_end.enabled and not state.spec.subtlety and 2 or 1 end,
        onRemove = function()
            setCooldown( "cold_blood", action.cold_blood.cooldown )
        end,
        copy = { 382245, 456330 }
    },
    crimson_tempest = {
        id = 121411,
        duration = function () return 4 + ( 2 * effective_combo_points ) end,
        max_stack = 1,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.crimson_tempest.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.crimson_tempest.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
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
    darkest_night = {
        id = 457280,
        duration = 30,
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
        copy = 394324,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.deadly_poison_dot.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    deadly_poison_dot_deathmark = {
        id = 394324,
        duration = function () return 12 * haste end,
        max_stack = 1,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot_deathmark.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.deadly_poison_dot_deathmark.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
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
    deathstalkers_mark_buff = {
        id = 457160,
        duration = 12,
        max_stack = 3 -- ?
    },
    deathstalkers_mark = {
        id = 457129,
        duration = 60,
        max_stack = 3,
        copy = "deathstalkers_mark_debuff"
    },
    -- Detecting certain creatures.
    -- https://wowhead.com/beta/spell=56814
    detection = {
        id = 56814,
        duration = 30,
        max_stack = 1
    },
    edge_case = {
        -- not a real buff, need to emulate behavior based on finisher casts.
        duration = 30,
        max_stack = 1
    },
    -- Poison application chance increased by $s2%.$?s340081[  Poison critical strikes generate $340426s1 Energy.][]
    -- https://wowhead.com/beta/spell=32645
    envenom = {
        id = 32645,
        duration = function () return ( effective_combo_points ) + ( 2 * talent.twist_the_knife.rank ) end,
        tick_time = 5,
        type = "Poison",
        max_stack = function () return 1 + ( talent.twist_the_knife.enabled and 1 or 0 ) end,
        meta = {
            stack = function( t, type ) if type == "buff" then return state.envenom_stacks end end,
            stacks = function( t, type ) if type == "buff" then return state.envenom_stacks end end,
            max_stack_remains = function( t, type )
                if type == "buff" then
                    if state.talent.twist_the_knife.enabled then return state.envenom_2_remains end
                    return state.buff.envenom.remains
                end
            end,
        }
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
    fatebound_coin_heads = {
        id = 452923,
        duration = 15,
        max_stack = 10
    },
    fatebound_coin_tails = {
        id = 452917,
        duration = 15,
        max_stack = 10
    },
    fatebound_lucky_coin = {
        id = 452562,
        duration = 15,
        max_stack = 10
    },
    -- Talent: Damage taken from area-of-effect attacks reduced by $s1%$?$w2!=0[ and all other damage taken reduced by $w2%.  ][.]
    -- https://wowhead.com/beta/spell=1966
    feint = {
        id = 1966,
        duration = 6,
        max_stack = 1
    },
    finality_rupture = {
        id = 385951,
        duration = 30,
        max_stack = 1,
    },
    -- Talent: $w1% of armor is ignored by the attacking Rogue.
    -- https://wowhead.com/beta/spell=316220
    find_weakness = {
        id = 316220,
        duration = 10,
        max_stack = 1
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



    garrote = {
        id = 703,
        duration = 18,
        max_stack = 1,
        ss_buffed = false,
        meta = {
            duration = function( t ) return t.up and ( 18 * haste ) or class.auras.garrote.duration end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.garrote.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.garrote.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
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
            duration = function( t ) return t.up and ( 18 * haste ) or class.auras.garrote_deathmark.duration end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.garrote_deathmark.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.garrote_deathmark.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
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
    -- Your finishing moves cost no Energy.
    -- TODO: Does Goremaw's Bite track by value or by stacks?
    goremaws_bite = {
        id = 426593,
        duration = 30,
        max_stack = 3,

        -- Affected by:
        -- shadow_blades[121471] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        duration = function() return combat and ( 6 + 3 * talent.subterfuge.rank ) or 3600 end,
        max_stack = 1,
        copy = "improved_garrote_buff"
    },
    improved_garrote_aura = {
        id = 392403,
        duration = 3600,
        max_stack = 1,
    },
    improved_garrote_any = {
        alias = { "improved_garrote_aura", "improved_garrote" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = function() return combat and ( 6 + 3 * talent.subterfuge.rank ) or 3600 end,
        max_stack = 1,
    },
    -- Talent: Your next Garrote and Rupture apply to $s1 nearby targets.
    -- https://wowhead.com/beta/spell=381802
    indiscriminate_carnage = {
        id = 385747,
        duration = function() return 6 + 3 * talent.subterfuge.rank end,
        max_stack = 1,
    },
    indiscriminate_carnage_aura = {
        id = 385754,
        duration = 3600,
        max_stack = 1,
    },
    indiscriminate_carnage_any = {
        alias = { "indiscriminate_carnage_aura", "indiscriminate_carnage" },
        aliasMode = "longest",
        aliasType = "buff",
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
            last_tick = function( t ) return t.up and ( tracked_bleeds.internal_bleeding.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.internal_bleeding.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod 
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
        duration = function() return ( 3 + effective_combo_points ) end,
        mechanic = "stun",
        max_stack = 1
    },
    -- Talent: Kingsbane damage increased by $s1%.
    -- https://wowhead.com/beta/spell=394095
    kingsbane_buff = {
        id = 394095,
        duration = 20,
        max_stack = 50,
        copy = 192853
    },
    -- Talent: Suffering $w4 Nature damage every $t4 sec.
    -- https://wowhead.com/beta/spell=385627
    kingsbane_dot = {
        id = 385627,
        duration = 14,
        max_stack = 1,
        copy = "kingsbane"
    },
    -- Movement-impairing effects suppressed.
    -- https://wowhead.com/beta/spell=197003
    maneuverability = {
        id = 197003,
        duration = 4,
        max_stack = 1
    },
    --[[ Talent: Marked for death, taking extra damage from @auracaster's finishing moves. Cooldown resets upon death.
    -- https://wowhead.com/beta/spell=137619
    marked_for_death = {
        id = 137619,
        duration = 15,
        max_stack = 1
    }, ]]
    -- Talent: Critical strike chance increased by $w1%.
    -- https://wowhead.com/beta/spell=256735
    master_assassin = {
        id = 256735,
        duration = function() return 6 + 3 * talent.subterfuge.rank end,
        max_stack = 1,
    },
    master_assassin_aura = {
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
    momentum_of_despair = {
        id = 457115,
        duration = 12,
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
        duration = function () return ( 4 * ( 1 + effective_combo_points ) ) + ( talent.corrupt_the_blood.enabled and 3 or 0 ) end,
        tick_time = function() return 2 * haste end,
        mechanic = "bleed",
        max_stack = 1,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.rupture.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.rupture.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.rupture.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    rupture_deathmark = {
        id = 360826,
        duration = function () return 4 * ( 1 + effective_combo_points ) end,
        tick_time =  haste,
        mechanic = "bleed",
        max_stack = 1,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.rupture_deathmark.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.rupture_deathmark.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod
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
        max_stack = 20
    },
    -- Talent: Suffering $w1 Nature damage every $t1 sec, and $394026s1 when the poison ends.
    -- https://wowhead.com/beta/spell=385408
    sepsis = {
        id = 385408,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 328305, 375936 },
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.sepsis.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t ) return t.up and ( haste * 2 ) or ( haste * 2 ) end,
        },
    },
    sepsis_buff = {
        id = 375939,
        duration = 10,
        max_stack = 1,
        copy = 347037
    },
    serrated_bone_spike_charges = {
        id = 455366,
        duration = 3600,
        max_stack = 3
    },
    -- Bleeding for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=394036
    serrated_bone_spike_dot = {
        id = 394036,
        duration = 3600,
        tick_time = 3,
        max_stack = 1,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.serrated_bone_spike.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t ) return t.up and ( haste * 2 ) or ( haste * 2 ) end,
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
        duration = function() return 6 + talent.improved_shadow_dance.rank * 2 + buff.first_dance.up and 4 or 0 end,
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
    subterfuge = {
        id = 115192,
        duration = function() return 3 * talent.subterfuge.rank end,
        max_stack = 1,
    },
    -- todo: Find a way to find a true buff / ID for this as a failsafe? Currently fully emulated.
    supercharged_combo_points = {
        duration = 3600,
        max_stack = function() return combo_points.max end,
        copy = { "supercharge", "supercharged", "supercharger" }
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
        alias = { "master_assassin_aura", "master_assassin", "master_assassins_mark" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = function() return 6 + 3 * talent.subterfuge.rank end
    }
} )


local BoneSpikes = setfenv( function( ruptureTargets )

    -- Locals / setup
    local maxEnemies = true_active_enemies
    local boneSpikeTargets = min( maxEnemies, buff.serrated_bone_spike_charges.stack, ruptureTargets ) -- Maximum spendable stacks for this cast
    local spikeComboPoints = 0
    removeStack( "serrated_bone_spike_charges", nil, boneSpikeTargets )

    -- Primary target
    if debuff.serrated_bone_spike_dot.down then applyDebuff( "target", "serrated_bone_spike_dot" ) end
    local embeddedSpikes = active_dot.serrated_bone_spike_dot
    spikeComboPoints = spikeComboPoints + 1 + embeddedSpikes
    boneSpikeTargets = boneSpikeTargets - 1

    -- Calculate this part of additional targets first in case we overflow, save calculations by breaking loop early
    spikeComboPoints = spikeComboPoints + ( embeddedSpikes * boneSpikeTargets )

    local loopBreak = combo_points.max
    -- Additional targets if there are any eligible stacks left to spend
    for i = 1, boneSpikeTargets do
        -- max 7 combo points, don't waste time calculating more
        if spikeComboPoints >= loopBreak then
            break
        end
        -- If it's realistic to spread this stack to a new enemy, only gain 1 and increment the dots, otherwise gain 2 with no increment
        if embeddedSpikes < maxEnemies then
            spikeComboPoints = spikeComboPoints + 1
            embeddedSpikes = embeddedSpikes + 1
        else spikeComboPoints = spikeComboPoints + 2 end

    end

    -- Increment real dot counter now that we are finised with the repetitive calculations /w local variables
    active_dot.serrated_bone_spike_dot = min(maxEnemies, embeddedSpikes)

    -- Gain the points
    gain( spikeComboPoints, "combo_points" )

end, state )

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
            return 50 + ( talent.vicious_venoms.rank * 5 )
        end,
        spendType = "energy",

        startsCombat = true,
        usable = function () return stealthed.ambush or buff.audacity.up or buff.blindside.up, "requires stealth or audacity/blindside/sepsis_buff" end,

        cp_gain = function ()
            return 2 + ( buff.broadside.up and 1 or 0 ) + talent.improved_ambush.rank + ( talent.seal_fate.enabled and buff.cold_blood.up and not talent.inevitable_end.enabled and 1 or 0 )
        end,

        handler = function ()
            gain( action.ambush.cp_gain, "combo_points" )

            if buff.blindside.up then removeBuff( "blindside" ) end
            if covenant.night_fae and buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
            if buff.audacity.up then removeBuff( "audacity" ) end
            if buff.deathstalkers_mark_buff.up then removeBuff( "deathstalkers_mark_buff" ) end

            if stealthed.ambush and talent.deathstalkers_mark.enabled then
                applyDebuff( "target", "deathstalkers_mark", nil, 3 )
                if talent.clear_the_witnesses.enabled then applyBuff( "clear_the_witnesses" ) end
            end

            if talent.unseen_blade.enabled and debuff.unseen_blade.down then
                applyDebuff( "target", "fazed" )
                applyDebuff( "player", "unseen_blade" )
                if buff.escalating_blade.stack == 3 then
                    removeBuff( "escalating_blade" )
                    applyBuff( "coup_de_grace" )
                else
                    addStack( "escalating_blade" )
                end
            end

        end,

        bind = function()
            return buff.audacity.up and "sinister_strike" or nil
        end,

        copy = 430023
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
            return 40 * ( 1 + conduit.rushed_setup.mod * 0.01 ) * ( 1 - 0.2 * talent.rushed_setup.rank ) end,
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

        cp_gain = function () return 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and not talent.inevitable_end.enabled and 1 or 0 ) end,

        handler = function ()
            applyDebuff( "target", "cheap_shot", 4 )

            if covenant.night_fae and buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

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
        id = function() return talent.inevitable_end.enabled and not state.spec.subtlety and 456330 or 382245 end,
        known = 382245,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "physical",

        talent = "cold_blood",
        startsCombat = false,
        nobuff = "cold_blood",

        handler = function ()
            applyBuff( "cold_blood", nil, talent.inevitable_end.enabled and not state.spec.subtlety and 2 or nil )
        end,

        copy = { 382245, 456330 }
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

        spend = function ()
            return 45 * ( 1 - 0.06 * talent.tight_spender.rank )
        end,
        spendType = "energy",

        talent = "crimson_tempest",
        startsCombat = true,
        aura = "crimson_tempest",
        cycle = "crimson_tempest",

        usable = function () return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            applyDebuff( "target", "crimson_tempest", 4 + ( effective_combo_points * 2 ) )
            debuff.crimson_tempest.pmultiplier = persistent_multiplier

            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )

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
        id = 323547,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "arcane",

        spend = 10,
        spendType = "energy",

        usable = function() return covenant.kyrian end,
        startsCombat = true,
        toggle = "cooldowns",

        cp_gain = function () return 2 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and not talent.inevitable_end.enabled and 1 or 0 ) end,

        handler = function ()
            -- Can't predict the Animacharge, unless you have the legendary.
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

        spend = function ()
            return 35 * ( 1 - 0.06 * talent.tight_spender.rank )
        end,
        spendType = "energy",

        startsCombat = true,

        usable = function () return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            if buff.darkest_night.up and combo_points.deficit == 0 then
                removeBuff( "darkest_night" )
                applyDebuff( "target", "deathstalkers_mark", nil, 3 )
                if talent.clear_the_witnesses.enabled then applyBuff( "clear_the_witnesses" ) end
            end

            if pvptalent.system_shock.enabled then
                if combo_points.current >= 5 and debuff.garrote.up and debuff.rupture.up and ( debuff.deadly_poison_dot.up or debuff.wound_poison_dot.up ) then
                    applyDebuff( "target", "system_shock", 2 )
                end
            end

            if pvptalent.creeping_venom.enabled then
                applyDebuff( "target", "creeping_venom" )
            end

            if level > 17 and buff.slice_and_dice.up then
                buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
            else applyBuff( "slice_and_dice", combo_points.current * 3 ) end

            local app_duration = spec.auras.envenom.duration + min( 0.3 * spec.auras.envenom.duration, buff.envenom.remains )
            second_envenom = first_envenom
            first_envenom = query_time + app_duration

            addStack( "envenom" ) -- Buff.
            applyDebuff( "target", "envenom" ) -- Debuff.

            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )
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

        cp_gain = function()
            local fanCP = buff.clear_the_witnesses.up and 2 or 1

            -- Predict crit gains
            if talent.seal_fate.enabled and settings.fok_critical_cp_prediction ~= "do_not_predict" then
                -- calculate the crit chance of Fan of Knives then estimate 
                fanCP = fanCP + max(0, floor( true_active_enemies * ( 0.01 * ( crit_pct_current + ( talent.deadly_precision.enabled and 5 or 0 ) + ( talent.thrown_precision.enabled and 5 or 0 ) + ( buff.momentum_of_despair.up and 10 or 0 ) + ( buff.master_assassin_any.up and 20 or 0 ) ) ) ) - ( settings.fok_critical_cp_prediction == "predict_conservatively" and 1 or 0 ) )

            end

            return fanCP
        end,

        handler = function ()
            gain( action.fan_of_knives.cp_gain, "combo_points" )
            removeBuff( "hidden_blades" )
            removeBuff( "clear_the_witnesses" )

            -- This is a rough estimation for AoE poison applications. If required, can be iterated on in the future if it needs to be referenced in an APL
            local newDeadlyPoisons = floor( poison_chance * max( 0, true_active_enemies - active_dot.deadly_poison_dot ) )

            if buff.deadly_poison.up then
                applyDebuff( "target", "deadly_poison_dot" )
                active_dot.deadly_poison_dot = min( active_enemies, active_dot.deadly_poison_dot + newDeadlyPoisons )
            end
            if buff.amplifying_poison.up then
                applyDebuff( "target", "amplifying_poison_dot" )
                active_dot.amplifying_poison_dot = min( active_enemies, active_dot.amplifying_poison_dot + newDeadlyPoisons )
            end
        end,
    },

    -- Talent: Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by $s1% $?s79008[and all other damage taken by $s2% ][]for $d.
    feint = {
        id = 1966,
        cast = 0,
        cooldown = function() return 15 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end,
        charges = function() if talent.graceful_guile.enabled then return 2 end end,
        recharge = function() if talent.graceful_guile.enabled then return ( 15 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) ) end end,
        gcd = "off",
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
        cooldown = function () return buff.improved_garrote_any.up and 0 or 6 end,
        gcd = "totem",
        school = "physical",

        spend = 45,
        spendType = "energy",

        startsCombat = true,
        aura = "garrote",
        cycle = "garrote",

        usable = function ()
            if not debuff.garrote.refreshable and settings.max_garrote_spread > 0 and buff.indiscriminate_carnage_any.up then
                return ( active_dot.garrote < settings.max_garrote_spread ), strformat( "Active Garrotes [%d] >= Max Garrote Setting [%d]", active_dot.garrote, settings.max_garrote_spread )
            end
            return true
        end,

        cp_gain = function() return ( stealthed.rogue or stealthed.improved_garrote ) and talent.shrouded_suffocation.enabled and 3 or 1 end,

        handler = function ()
            applyDebuff( "target", "garrote" )
            debuff.garrote.pmultiplier = persistent_multiplier

            if debuff.deathmark.up then
                applyDebuff( "target", "garrote_deathmark" )
                debuff.garrote_deathmark.pmultiplier = persistent_multiplier
            end

            if buff.indiscriminate_carnage_any.up then
                active_dot.garrote = min( true_active_enemies, active_dot.garrote + 2 )
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
        cooldown = 25,
        gcd = "totem",
        school = "physical",

        spend = function () return talent.dirty_tricks.enabled and 0 or 25 end,
        spendType = "energy",

        talent = "gouge",
        startsCombat = true,

        cp_gain = function ()
            if buff.shadow_blades.up then return combo_points.max end
            return 1 + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and not talent.inevitable_end.enabled and 1 or 0 )
        end,

        handler = function ()
            applyDebuff( "target", "gouge" )
            gain( action.gouge.cp_gain, "combo_points" )
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
        cooldown = 30,
        gcd = "spell",

        spend = function ()
            if buff.goremaws_bite.up then return 0 end
            return ( talent.rushed_setup.enabled and 20 or 25 ) * ( talent.stunning_secret.enabled and 2 or 1 ) * ( 1 - 0.06 * talent.tight_spender.rank ) * ( 1 + conduit.rushed_setup.mod * 0.01 )
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
            if talent.alacrity.rank > 1 and effective_combo_points > 9 then addStack( "alacrity" ) end
            if talent.internal_bleeding.enabled then
                applyDebuff( "target", "internal_bleeding" )
                debuff.internal_bleeding.pmultiplier = persistent_multiplier
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
            removeBuff( "kingsbane" )
            applyDebuff( "target", "kingsbane_dot" )
            gain( action.kingsbane.cp_gain, "combo_points" )
        end,
    },

    --[[ Talent: Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
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
    }, ]]

    -- Attack with both weapons, dealing a total of 649 Physical damage. Awards 2 combo points.
    mutilate = {
        id = 1329,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function()
            return 50 + ( talent.vicious_venoms.rank * 5 )
        end,
        spendType = "energy",

        startsCombat = true,
        texture = 132304,

        handler = function ()
            gain( 2, "combo_points" )
            if talent.caustic_spatter.enabled and dot.rupture.ticking and dot.deadly_poison_dot.ticking then
                applyDebuff( "target", "caustic_spatter" )
                active_dot.caustic_spatter = 1
            end


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

    -- Pick the target's pocket.
    pick_pocket = {
        id = 921,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",

        startsCombat = true,
        texture = 133644,

        handler = function ()
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
            return 25 * ( 1 - 0.06 * talent.tight_spender.rank )
        end,
        spendType = "energy",

        startsCombat = true,
        aura = "rupture",
        cycle = "rupture",

        usable = function ()
            if combo_points.current == 0 then return false, "requires combo_points" end
            if ( settings.rupture_duration or 0 ) > 0 and target.time_to_die < ( settings.rupture_duration or 0 ) then return false, "target will die within " .. ( settings.rupture_duration or 0 ) .. " seconds" end
            return true
        end,

        used_for_danse = function()
            if not state.spec.subtlety or not talent.danse_macabre.enabled or buff.shadow_dance.down then return false end
            return danse_macabre_tracker.rupture
        end,

        handler = function ()
            --- Shared functionality
            debuff.rupture.pmultiplier = persistent_multiplier
            applyDebuff( "target", "rupture" )

            spend( combo_points.current, "combo_points" )
            if talent.supercharger.enabled then removeStack( "supercharged_combo_points" ) end

            --- Assassination Rogue specific
            if debuff.deathmark.up then
                applyDebuff( "target", "rupture_deathmark" )
                debuff.rupture_deathmark.pmultiplier = persistent_multiplier
            end
            
            local ruptureTargets = min( true_active_enemies, buff.indiscriminate_carnage_any.up and 3 or 1 )
            if ruptureTargets > 1 then active_dot.rupture = min( true_active_enemies, active_dot.rupture + ( ruptureTargets - 1 ) ) end -- Primary target is already handle, so -1
            if buff.serrated_bone_spike_charges.up then BoneSpikes( ruptureTargets ) end

            if talent.scent_of_blood.enabled or azerite.scent_of_blood.enabled then
                applyBuff( "scent_of_blood", dot.rupture.remains, active_dot.rupture * ( 2 * talent.scent_of_blood.rank ) )
            end

            --- Subtlety Rogue specific
            if state.spec.subtlety then
                if buff.masterful_finish.up then removeBuff( "masterful_finish" ) end
                if buff.finality_rupture.up then removeBuff( "finality_rupture" )
                elseif talent.finality.enabled then applyBuff( "finality_rupture" ) end
                removeStack( "goremaws_bite" )
            end

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
        id = 328305,
        cast = 0,
        cooldown = 90,
        gcd = "totem",
        school = "nature",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        usable = function() return covenant.night_fae end,
        toggle = "cooldowns",

        cp_gain = function()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( talent.seal_fate.enabled and buff.cold_blood.up and not talent.inevitable_end.enabled and 1 or 0 ) + ( buff.broadside.up and 1 or 0 )
        end,

        handler = function ()
            applyBuff( "sepsis_buff" )
            applyDebuff( "target", "sepsis" )
            gain( action.sepsis.cp_gain, "combo_points" )
        end,

        copy = { 385408, 328305 }
    },

    -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. If you already know Shadowstep, instead gain 1 additional charge of Shadowstep.
    shadowstep = {
        id = 36554,
        cast = 0,
        charges = function() if talent.shadowstep.enabled and talent.shadowstep_2.enabled then return 2 end end,
        cooldown = function() return 30 * ( 1 - 0.333 * talent.intent_to_kill.rank ) end,
        recharge = function() if talent.shadowstep.enabled and talent.shadowstep_2.enabled then return 30 * ( 1 - 0.333 * talent.intent_to_kill.rank ) end end,
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
        charges = function() if talent.lightweight_shiv.enabled then return 2 end end,
        cooldown = 25,
        recharge = function() if talent.lightweight_shiv.enabled then return 25 end end,
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
            if talent.supercharger.enabled then addStack( "supercharged_combo_points", nil, talent.supercharger.rank ) end
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
            return 25 * ( 1 - 0.06 * talent.tight_spender.rank )
        end,
        spendType = "energy",

        startsCombat = false,
        texture = 132306,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            removeStack( "goremaws_bite" )
            if talent.alacrity.rank > 1 and effective_combo_points > 9 then addStack( "alacrity" ) end
            applyBuff( "slice_and_dice" )
            spend( combo_points.current, "combo_points" )

            if talent.underhanded_upper_hand.enabled then
                if buff.blade_flurry.up then buff.slice_and_dice.expires = buff.slice_and_dice.expires + buff.blade_flurry.remains end
            end
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

            if talent.crackshot.enabled then setCooldown( "between_the_eyes", 0 ) end

            if talent.improved_garrote.enabled then applyBuff( "improved_garrote_aura" ) end
            if talent.indiscriminate_carnage.enabled then applyBuff( "indiscriminate_carnage_aura" ) end
            if talent.master_assassin.enabled then applyBuff( "master_assassin_aura" ) end
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
        charges = function() if talent.without_a_trace.enabled then return 2 end end,
        cooldown = function() return 120 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end,
        recharge = function() if talent.without_a_trace.enabled then return 120 * ( pvptalent.thiefs_bargain.enabled and 0.667 or 1 ) end end,
        gcd = "off",

        startsCombat = false,
        texture = 132331,

        disabled = function ()
            if ( settings.solo_vanish and solo ) or group then return false end
            return true
        end,

        toggle = "cooldowns",

        readyTime = function ()
            local reserved = settings.vanish_charges_reserved or 0
            if reserved > 0 then
                local cd = cooldown.vanish
                return ( 1 + reserved - cd.charges_fractional ) * cd.recharge
            end
        end,

        handler = function ()
            applyBuff( "vanish" )
            applyBuff( "stealth" )
            if talent.crackshot.enabled then setCooldown( "between_the_eyes", 0 ) end

            if talent.improved_garrote.enabled then applyBuff( "improved_garrote" ) end
            if talent.invigorating_shadowdust.enabled then
                for name, cd in pairs( cooldown ) do
                    if cd.remains > 0 then reduceCooldown( name, 10 * talent.invigorating_shadowdust.rank ) end
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

    potion = "tempered_potion",

    package = "Assassination",
} )


spec:RegisterSetting( "priority_rotation", false, {
    name = "Assassination Rogue is able to do funnel damage. Head over to |cFFFFD100Toggles|r to learn how to turn the feature on and off. " ..
    "If funnel is enabled, the default priority will change slightly to do priority damage to a mob.\n\n",
    desc = "",
    type = "description",
    fontSize = "medium",
    width = "full"
} )

--[[spec:RegisterSetting( "envenom_pool_5_points", true, {
    name = "Pool for |T132287:0|t Envenom at 5 Combo Points",
    desc = "If checked, pooling Energy for |T132287:0|t Envenom may be recommended over |T132304:0|t Mutilate filler at 5+ Combo Points.\n\n" ..
        "The default priority would pool at 6+ Combo Points, but guides recommend pooling at 5+.",
    type = "toggle",
    width = "full"
} )

spec:RegisterStateExpr( "envenom_at_5cp", function ()
    if buff.darkest_night.up then return 0 end -- Bypass with Darkest Night to ensure pooling to CP cap.
    return settings.envenom_pool_5_points and 1 or 0
end )--]]

spec:RegisterSetting( "fok_critical_cp_prediction", "predict", {
    name = strformat( "%s Critical Combo Point Prediction", Hekili:GetSpellLinkWithTexture( 51723 ) ),  -- Fan of Knives
    desc = strformat( "%sThis setting controls how %s predicts critical strikes for combo point generation.%s " ..
                      "|n|n%sThis option only works if the %s talent is selected.%s\n\n" ..
                      "|cFF00FF00• Predict:|r Assumes a certain number of critical hits will occur based on your current critical strike chance and number of nearby enemies.\n\n" ..
                      "|cFF00FF00• Predict Conservatively:|r The predicted number of combo points is reduced by 1 in order to prevent more jarring rotation changes from unlucky critical strikes.\n\n" ..
                      "|cFF00FF00• Do Not Predict:|r Disables critical prediction, using only guaranteed combo points from casting %s.",
                      "|cFFFFD100", Hekili:GetSpellLinkWithTexture( 51723 ), "|r",
                      "|cFFFF0000", Hekili:GetSpellLinkWithTexture( 14190 ), "|r",
                      Hekili:GetSpellLinkWithTexture( 51723 )
    ),
    type = "select",
    values = {
        ["predict"] = "Predict",
        ["predict_conservatively"] = "Predict Conservatively",
        ["do_not_predict"] = "Do Not Predict"
    },
    width = 1.5,
} )

spec:RegisterSetting( "envenom_pool_pct", 0, {
    name = strformat( "Minimum Energy %% for %s", Hekili:GetSpellLinkWithTexture( 32645 ) ),
    desc = strformat( "If set above 0, %s will ONLY be used when you have at least this percentage of your Energy.", Hekili:GetSpellLinkWithTexture( 32645 ) ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = 1.5
} )

spec:RegisterStateExpr( "envenom_pool_deficit", function ()
    return energy.max * ( ( 100 - ( settings.envenom_pool_pct or 100 ) ) / 100 )
end )

-- Not currently used, but could be investigated as per review comments on PR #4133
--[[spec:RegisterSetting( "dot_threshold", 7, {
    name = "Remaining Time |cff4ec9b0DoT|r Threshold",
    desc = "If set above 0, the |cff4ec9b0DoT|r priority will not be used if your enemy or enemies will not survive longer than the specified time.",
    type = "range",
    min = 0,
    max = 10,
    step = 0.1,
    width = 1.5
} )--]]

--[[spec:RegisterSetting( "mfd_points", 3, {
    name = "|T236340:0|t |cff4ec9b0Marked for Death|r Combo Points",
    desc = "The addon will only recommend |T236364:0|t |cff4ec9b0Marked for Death|r when you have the specified number of combo points or fewer.",
    type = "range",
    min = 0,
    max = 5,
    step = 1,
    width = "full"
} )--]]

spec:RegisterSetting( "vanish_charges_reserved", 0, {
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer than this number of (fractional) charges.", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = 1.5
} )

spec:RegisterSetting( "solo_vanish", true, {
    name = strformat( "Allow %s When Solo", Hekili:GetSpellLinkWithTexture( 1856 ) ),  -- Vanish
    desc = strformat( "If enabled, %s can be recommended even when you are alone, |cFFFF0000which may reset combat|r.", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "allow_shadowmeld", nil, {
    name = strformat( "Allow %s", Hekili:GetSpellLinkWithTexture( 58984 ) ),  -- Shadowmeld
    desc = strformat( "If checked, %s can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change. " ..
                      "%s can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
                      Hekili:GetSpellLinkWithTexture( 58984 ), Hekili:GetSpellLinkWithTexture( 58984 ) ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled = not val
    end,
} )

spec:RegisterSetting( "max_garrote_spread", 10, {
    name = strformat( "Maximum %s DoTs During %s", Hekili:GetSpellLinkWithTexture( 703 ), Hekili:GetSpellLinkWithTexture( 381802 ) ),
    desc = strformat( "This setting controls the maximum number of %s the priority will guide you to apply while the %s buff is active." ..
                      "|n|n|cFFFFD100Set to 0 for no limit.|r\n\n" ..
                      "|cFF00FF00Maximum:|r This number will be used as the maximum number of %s, and can go as high as 20.",
                      Hekili:GetSpellLinkWithTexture( 703 ), Hekili:GetSpellLinkWithTexture( 381802 ),
                      Hekili:GetSpellLinkWithTexture( 703 )
    ),
    type = "range",
    min = 0,
    max = 20,
    step = 1,
    width = "full"
} )


spec:RegisterPack( "Assassination", 20241117.2, [[Hekili:v3ZAZTTrs(BrvQIH0wsMKsYpYjPuo2j7zVNZLkY7MVjiisqjCIeGlaOK1wQ0V9R7EEGzg0ZaqAQ4S7MejrmyM(90VMHNp68pF(ztJRso)xhpC8HJgn6v7p6vhDWbJo)SQ7xMC(zlJNCt8vWVKfVa(VVTSmUSmnlUknpdF69ZZJNIZsz(QIjWiUUQAz5p8IxCvA11RUC)j5lErz6IvZP3ysr8Sk8VN8IZp7YvPZR(q25x2eeo)S4vvxNxC(zNLU4DWKMoDAIyKjLto)mCK7nA0EJE5p84f)C2Tjz5lE8IYkayF8IQ0fPzx9F94fVDXLRkV(Xp(4hvJF4yy8)A(JxSiVi5XlMexwbd9Xlol79W4)8DjXW7)H3v)kd37GrWR8tjvvjfWkSA5Y8IQhVywo8xRktkkF8I7UgMWPW)MLdpjjl(Y5WCxfxCvc83L3fVCjTi7bRZ9fPZmN9XVcM9pbGbo7kIlay5ffjtqkM1GhT7JxG)8i4LqcdaclrsNEqdFZEJFn8WFjh4fpEXY8850stGRMoDhWAYxbW27JlUjPe(LFn9QRHFaWw9OslrS6UmRj)WFqtMAo5WBzm2rHGYriv93tUnTeaZzPZNNyaGgJB4rakJ)81YF(gVt6R3Bm(W3oFE(DbMZxlqcZ5ay9fjZJ)cY8skU6E8pVkjd)X)AvArYIKSQsRzymj2jy0crP3()(ZMJyeUg)skmLLtG3oQmUAvbPc84f3gxKsVQX4h(gI1cV0)GajG2pRa5ceCQh4RecmF(Ayf)Jya9(dGvMckIZtlRkj1WQK45vxNG6K)kPEleiNE(pD(z5lHbKubAxte6Vkqb)T5RsqDYzZ2xaY5ZIUCEE(09LQvNEYJx0N(NYLjZNhjeWl3FwCgo2BYsVfb7NHI(ZHjWDAkIZUHE84hVyamD)i8BdHFvOtxKUuasNPqaGMsqjmN)bGUXiv(mCkHFiOM4yU7AKrb2E0Q)tYxHJbfFVoTsOFxHeSfXFbmeTGW6iH5mxMZ5vGvihIgiEhLL8LkKCQjCOWFurI0Oh8SdCEllC6TlxohKQEFsC11auo)gYUXNaTpHoxkaVxhJ88yqQfXNzZo)m49bZcPXGPybbDQ57hTaE99LR4Jx07Xl2b0xtigiZaxTKgdc)3MennNB2E8cGfpKgxFYmAI6tE4HhVqmZclgrzObJ9jZdihurwIjlUi94Wq0JpfFtcAmfzPv5iUFlYCVo9wuLeqJvfeB7Vd)3YlJZq2pqDIr16S45ap(6Kj3WqHUr9cweM(OHmZhwLo5gAbq8AcWkreX45immq9Q1K1saavesZpcSqeNIYPhd6WQ3KECIW6d8s10i8vqk0rHOqARWi5bN9QyCFbsogN5AA0zRUeObZwH7rxtpsMnlrWQHnGVmpAzEkAdJuIvk97xpiqJoBA0ejQXtRCXPASgMZd0e6GsGA5OjanxAxGi21Kh50JuOx2jkKIq0Cxu8FHF5Q6TJ3wKichwqlyuSC9IIbJio6zW(jlsrRINqsgBFs0RCirQHuSAjytdfjUFY8eLTAYe2wKcKMnnfzjlqhcHzjUid8vmko7EfDOpUj6mWq51InlrSduOGnHqdZL7tGNHYMqFtV40(Wk7ZsTzdtysSKu8CP4d0lME2AUvSCegZvT8UaMeuU9rJHrv5rttHv7uGzEKJ44VRafL44hSOnpEX7eehKP9ApmTRIlkYRAHPruud7nJfyXsWf7Q0LZtrvGJfIB4NlOPDNB13IalHiALeaLl91)4Dzi98X5n)hgvNtvQoCSI9mOgWah7Wv(WILf53Ico)nbKHoik2mgDA93fIMcpIfujJXwUlcmK7e1(5gGT(gh2Anpt7u2(PsakstPeKDFSplLhb9XuxfmImlDc6(WPI355K7vg(GDDr(QPW6vc4w(esSxT3ytbVk4)dEhLLc7HZ4(iVZpSUVbeg52QaJb)))tAwXiGYMOiLUmhfFG8tcnicR(xQkIJIxGmHZp7WJSDhJXBnlGrTO4MOZOFJw4Fb4CZwnhDHFkWzn5u7i1vMbd5syrNgnF1KBUhmqMMP0s(AmB2VX8JZmOQNoV00r7Jm2iWzSxNep1DSdmDPNyFT5sQjPPCzbmNgSbLnmnJWiMrFka2erP4NZwKUURkhfVHjRbRgPJ6J1y0oYPEyTvndBt77tvZCmmQDoBCBTFTELRFKPn6dBx1TTOQWOLo0dF21v7W6m(dHjOdPk5fsbcSChFljHOmvQuD7G0X)jX0dZtiBTI1Qd7nnsQtxeNonk5weZINcAYOxQNQJfUj7nOxWA2ce44LKfbIb56lmd9pKQPnvPgfeE5ZQg0iUbRWdEjTZ0bw7mPJBrMzalDmDOwetYDbDvU4iBUEg3fYgZosmMcXi2ZaZMa3de7Jjzbk7ejFzjyZh3yTP0(3oz4THHlpYShmKHYJbzLxq(dY5eHfF4DuUZMgVau9bxYUfXmrEhIVmDEAf5a4QsKobREX93DDc(cFshq8Ft7YSMIh0)i)EBjrut6x385C0yohPc7ysncOJByv28KYsKyiZjBMmNSifyPpeSZEDSvr5(KOXZLw(e5MkguzZUkQe9xEArY8Aj8NjCrr9c(dU7zKHIb25EHjTtkPx5spjEvje1gGYXyw69Ktm3r5etTkGzs(LsrZgL)upjlYqd1mFkmXD66onLtSj5WML4huAL8s4zr6hXjZ1o8gmVzoPWI(S6GPTxDx4spJ2qyqFsfilzjooxhnWBli5EWD9FRizsAjn0ggyJLJkAPAqwOIhWUdBYFcjRlzwO)kL5G)6jlwcYJ1mn3K7fm9NsMACjLMFeD1j6K3n65Oy)Dj4)nIKR8JAm0DZ9s4ZRNVDUF8IxBLJe(3MjbQ1glor6zJHgTsT1HwQXjCb5ZFMA3opSblfAFPzTHKZtkX1tcMTCoAelCh0TVFr73sPHoJwrr50Y06aP3MkmmUt0e(d6)vn8RCMcucNqWUuTigZsdV2aVXQ6N)vGzFleqDZgOfH69RwSuvzeegNjCka2B3K2CzEPibB0JJSKU0sFKS9KRrZCL0ETVUbSa7uSacklAY0YwDD7tWab7MaBiFvPv6E(T8khB0K4cLk75WMWG0pSUYeC4dYrNl949VP02YCF7954VFrkbMAXSIy8NLIeGCjSzt59ztOcksB6OOALMOrqiHqVOzRkUNBFUUojjfLjf0wkmBI0XjzwArcbnHn)zjRZRt5nsphxCQZf8MnDB2gtM1De4DLvfGo)eWYIqsgCHWxmiT7xKa)(wwh8VP18UDc02lieh8()oz(s8X)tvxsqAOubFbf14Y0juvGHynXrX7zmW2JuJzn8)8DcR2pEXNfMTfMChdHT8zbpwSD1DjQkwdogV6QRDABeRe)BkHi9gYEtiEqDtdm7L1CmNTG4SN4g1AW6oTvdRUTA81buDKBTE0PSz1YBsswIfVzEzoL(GsrlwGXB)28FwirHBczW6S1hCTA6gLyqk1MWB7hYhBVLe24vdso7h2wKqQ0iIA2rDSjRoqbfncpVDM4r21(RdVcS4V6Pp3d(s8GVQ(UrYCOt7LcR75GDfIy7kj6ggqtjXVvYDbL4cx29UXPh9MwyfnucBlSdTjcz3eP9g8kKLexHmekukAVZ5X4waV73q)dNrjQm2CRhAGjtXexIXSG7jKnDEQD9eDP3BOvurPGn8Qh5rrImL2RdzW4adJf(MNNP2BATMT24JdiwPidkUnmJEqWCo0t1Obc5c2GrA3ff2U6OxRj9ECDyC1dWwNiq4wJD3w6mLm27iHKpdrMFdkUA4Uc4vdq8epiCc90(7cIGLiBbeuJswGHnKVA(5Nb2DGpDw0vtMsBkjMFFJ2kwG13jCu0CK25)wikm(EPrM5GeeexA0Yv)7)nOqFz(x8IjCdLXcOFkQpFGQiBZjfquIWlgNvUifttSpaX7WxlGXFWzHKrjvWHkBJBOC6bkmzr80O)1QKKmSh0YOgXxtuyEwGTKsbhnlqx)bnCWK)uiOS7JGWzXWp4PIHEJ1Iq6Rn42EIwFDgtAx5WxpHjr3rEtGMyVh55rGGkiMqypLkTHMY554pQNjl9En1vryXeHeHVJ)Uw0UzfdHBdntoqll1ydpsKJy)QX7RPWytQCpJfjlz(D8NMHG6ucy1)CpqJi7egrgGCt)Tc2AqgE6P4J4O4J(ppkUJi(4gQpJfotaoCfdox1AUn)9KsvBSHb8VeO3PKhC9XuvF7Q5O3I0hOZ)R4u7S4Y4kZu8kMLwtp5hYaPd06IiJdkYMiOHyXbAPmDXcIUKIdwScLQ0vcgUm8e6gGeYTHB7UmjImr6rpIoPzOd9Ys97u6E1t)zz4m)U4qZKLKmf)yQZYKbfy6TJt4cCBk3oGgyxVaIQ25T0bH(n15z6SKQvyOCYCoj64P68bxJjPins95mBN3oAWvHvRpBr8xIOC8zRLpYemMmpDzuG2MVDW4vdjN2rNkmsBzC2vRaome4xmqOQJPgg5iRrElefd6iebbLu6cmHVvlHD5JMNcUifjeW42YUDOuf2mgpXqkI(JK)ynaM4BZtNgb6LCB62omeSwEQgKAhp18dmM6QeHIyP6MlEsDrukZLRVIjpnI(iMnxAhQ1wpnLyBABvUgeoO)qnbRw4KVBmwZzQESgIVIzs)OMsoDzdqF61VRotiGnv0af6Xh60EnzolVksEWgrs9OHbZxmnnnpWAgjHfgrK4pIWJOhULqr6KkNmgw3F4f5xTkrGKHAAC85EJM(ukAAC5uz8xFMaXfoCdzrO07QT25htmwaSEH4uhCto1uJjs595Fw1h1DEnu9ugUqHtJpTqus3G1PuvVezM4wBMdoc3ZJGfKPk0e(Ib77dbG9(u8O9Ih(wrxV9wvNU1rcXu69PvZF8JYnYTZW0rK1s294nczQyc2Gdv4jqotSm0gkopF5Q5LjMlooWxzoqQVkkJ()wn9k8a06o2xBo2lJVIYpbq(VP0EKWlI1XNCTs74MgyWUeatNwj(xwlW6xslWEWvGrNzRYYsMBAuyzrAoqzVpcu(0jMDTCUsntn8E1KNz4b(1XL42(v7hNDF00LL8rg1CuuA3zCKFQo1ROGaxWv1JqNaCJHLwUVNmE0yn9puU9(qLZumN4Yzam7HUYRpsOuOS)tK)uQ5tJ2mxghZsR5OICXe1cTMLsEABmJMK6q0VglzisDizUnYv1jlJiNrXs6s(acXPE8p648fMcCurgpYk1hZi7oAjbGpisMezYWXWRsXsGiYSUrjDnrIM1uMZtx799ls2BcLcFWueEBieJa(7PF1mQoUW1Q0Mz7(XGQXogyGiA)AeP42(OziTedK1N1F4(h98H7FWZ4iKOpS7nC)rh9m)(4oypbyPJCysoUVX6CAP8UXK4eCPpWTOkjA4nDcopadBPQnUQ03key4tWyqNIi)TwadF29KBycR1YwxapJD0aO)nDrSObLMI1DzxrfYW9THTy3)C7MbZJNO9SRXsNBnb9qm8a0kOXAuqUFJz)Gmw2RsC(k4wsrrJYB1XogbVfUbzv1sqZlu1CsgaH9f6X5UTGfl5k0XzZuPNfCxFZW2lYXDG7WgyHvCcn4z8(SXT9JQHokVoF18PIwbtMhvQAF4TiIvWSLjrYpDJmJ2HEw3xQM73w7SBiT6(y7qKuIKTvnYoqgRpjdVtSKG5wXA6s1uGun1Z18ntk)zErnTDXQQ05YAs4MnH1CQQV3kc2nM)cAMclv)Fxwnu0u4bpxvfu2dmmU(uRhwxQ4sVWN6wRri13WVtLyqxQq7EMDiXIC0f8vlWXby0Y40cUtAx11fGdkC9n7aZUbyEcWyXAjExAvwsjGqkBj74lnm1tunr3cU5sSryApLBuXz5wyqUuEzQKjeBvBSCVI9aeeQnPXpbwIKPets3CwImPQO5pEHIOpqYM)SZgqYuqovhacTHFtfwgUOknLnotiQhWDze4MsFh5LVjYeH4MHZDI8U5I4r)ey4EAz60KxuFzMSpg8U0NIvyfUuVG4ArsNFEMRkMEgNwV97IQMQFMUubhARPnsmJzlx1EIMRZqTiD(Avi7vI9c0PrEAAy2RBnH26iMCsZBqHphF5EFsUIw6CVNe9XU9w4ohQJmwRo1E6GQRG5NQrOqGpRH)krYN2O(dP2yL3ZcRhf1gLcX4Qo4pItLLXX4iJs7e4Clh8P3kdjXSodgheO6Dp1IrGZyFTh4RGT8nIUTDAvgZdz6rhUFB7ea2qRtL45smqUim0OPWVyvlXJc66exDwcu3sT0hpL33y4ObUb)QfjuN7aXPBvh)Kg3314SHkodO7kLxOSiMxrnHMGxA2h0YUgVe2QPCwkg(nh7kypXybY)JY4R0NtnTZmYoNBVjwn1KeaLW27IZQGPrUTCDeJDmpNIo)IXjBNCQIH74C6SP23tTP)DPi9QCvXTKtbZZrzcrNB7RW8m0j5wInB2nYB5HDRnOmAYT6JMvB5X4DgMhERry3YRlTs66vOtuuFhnllIa3bW3(mezwWRxQ2sKtdRFlDaWjIk4PmYYup3oquXBIjf2RvaB1t(3I1IsCIZv5PqKnMDLUBiSrJ4RmnetPtIL(8trTyZ1uhamv4xASe84Ytr11axa3RojEF7d3FhQuTfb7qnrPvh(KhBvFZ0lfttOJmMjyBEYXmoMbgdPvx4fhmSx87IJE1l(FfMjWtCMvb27KSS(CQX5PPfdOE3eYWzVo3hQbx)6lAIgoQzPore)G32pQRCrUrAFx)qJCaxRm0j1TATTANasZsUnTcVSfWW8NAfaWgFphnOzp2PPP6ojVHpuy2x(jrlWlUrzP4LfDnRX1xBzTp)6tTiWAafz6KHBDjcFxCrgQFbUXIQQPlmU8E)ETCX3RVOxXUVpNU9jwvLVq0m7GCFgi3V)JF8)HsA9b)avjzy9Oh)9QZGasWTUn)(EXE8(hGIyddS)OVmqVchYVcAlfotCd)4CNV3WpFCxnyotDOBpS6v5XpYqDf6hBfsRJ6Qdm6X3DxIGN5M)iS4SeHVQI66k5ueF31WZfeJ7SF0FA4HVvA7GhV8jKx)QNiiNvqx1xcRNO(ypwrCpjtUgr8DsNCjbEMFN0c7m7EskDlea0k8wb53ydCE04AEpa4mX(VOa6O06wCf8iZUX0epZ3wbIzfduoKTEIcEmYSXO92B(yrszR(SvWXTGUolmsXnVEq4RDHqzpg4289Ai0x357Yo2EtSFVzKVIBBR3ykzgqy3K24j2hNr2(5RhVXJPhNUZ1r2XtV72IKJUpRwpiSH5xnHZTPzyiDmdjSTDTeuRto7q60KZ0SoH46gJ5jD6BDIz6cPqAwRlCVPtFhMy)TYeZkeCWDctc1MvmSIUVGnIDBBkU6BY3kkA(H8nJP)ep9ToXBQswhH7nD67We)NUO5ASGRJYNh)EmBTnNTT4AFWw2Zs0MER3gwEaSVYGJ84XJmY1MfB3z(duo(oUgUvQ3zb8vi)oo72n0HZCZ3ThUZSNerTvPnEwJVAAdFS)RB4oB7iFPVgTyMWu7066mTP8j91ez)aHN4uIhXFr2BF8c6Bzk450fB0KZ)1Xh9gS74ZNLwxvVY91Ur(8tEHzd6)4h5gHktY7I5v)KgnlZUuzHpXQ38F8JFhG1Rz7J3Lvxol1TkTC1hTB6St8VBBV(74FF(hEiWwgNEsG9bh0BNUyJ2Cbc084FfO)yt0VjgAG(nPn1qhdgEAasJb2hcVmN)qy)3HfjUQJDEExiwnl8HKAz2ZS7n(4F8iUE6MaOU2H68GJQfO(439DknuNby1Te7QFuuzcIPLcXAJBOME7q1uY)160hjW(R70rRrglua)MdO6R)mqBo54PGwyPyDoPYMZGnd35Cll52SNMQtpyOGbN3LJuS)L084Akxp2cL)WdSLsg(y7Qe6DHmpdMYfYPG(9cFSKp(Kr(N9MhJt5A8QH7DWWNXNZI9gnmWXDW)IPpLPwmOtpC4Zpc(NGtPAxLuFhi3aeqrFPRmbOmM1OhQo(GE7W(u8IwWsK5DEoTQ(HbJUGxch6Q0Aki9Wd7CRt703t)bAQxp2dmqhF36Xyix9Wd1n1xdbIhEa7XJEwnJWXNmwOg57C2AskClwVGKu3nvIJ2PWKNt)L9Wd(pQTp8GNMf4utq7DCQY8qe4YO1l6EAy7Wmil4KX047SU2(KjtOTf5jEIzx)F6iJfY)reQ1vseOM54SpPP4kBFQvp9Krh9C(BKIMZcDEun)CNJFQ5JSoTPYn12Qx3Q1BylPVn0vDVt8mn6YDTZE6j97hOHF02qBEXn(SXdo9hhpCaHLB6LRA7i0u27CqT9W6(h50tc07i96BC73b7PiG6TZ9YkhomX(ssLmoysLp9KX1gZ4rXEMoq1Sbb3tzV4LeQSTUKs5qgPjRDTAlCHkn3b9buVAqUTqMAt9oU(ecnhnw4J4t6fJjh2lB7xoSFD4G93XJRuIJ(sUXfH5ayWEjr99RrEYyiOfVp9yKTe2pC819ZaoAWGbH4q9F1Z77ReJp7ObpVVpC6zVeM4D4piH)fHH4LDuZOCT8guy(nEXxtD5N0Bt0qA6oHV1rT8hEq7GvL66)SxGnxo9Kdar9MVZZg3(B5N4o40d75X3Qtgk3u(P4GvutpbxXAUngBd)l3gBhv6i5BdjruyUNPRoUCmNDaNvvpIhEiq8fNmwMRJ)0pObDftBGFoUJ3lWr940J6XCep65gR6omhSdJ9Xz5XCpNHPqu3T)zIWL4X7dn1AhIe(8HSBZXVe1)5VaIIz6VjlQ57wPfsmPP07eLiFLiKgjt7A(DGaDA2Svy2Vr7k8nKVisGVItCHlEQxcCn7ZWcQ5pnnLa22goiCKJTF2j6gLN(A2XzKAPdc2Tt1IHoQzN3F8lh0qyTFDQpDBA7tp5OHcRknyfEW7rhr49t4XBWLkyCaaq6WomN3HE97q6P0O8HaQfCFLd7X(EV8HhCigAclZ5y4zVuMUfexA5ij0nrevdW1Trl6pAIIzDafcTNiTJ4M1M8nakTFt7A0Q(cVZ63Yzw40H9A5SkCkQwARqeumhLY3HV4u94pfcbJICG29HTZ3UKgepzUxS9bRJ(DnORHkkJHAT)sIKfovUH7aNRxy4DfY7F4xtSf95D2whTKtj41BZ38UWGKauedrMNasH1f2ZUQRghqO38A55KN8BLhJCSnT(kcsQG)x8lHhgQQQSbAJ)U8VERHCN(HgjZwBkXZvWZPWU9p8GKIQZAPkuv91TdrExZBqNWOlp26ZGL1fOLHZjD5gOHboSDVU(yYZKYTJdsZBKrFJe1BXfCPWogPCV)x6emBFHSOk2pV6oNN)99Bdql245UWbCsCG3qMBIRnqg1TqGvcnAItmVP4sEO13dOUBRlCggGWYPQgWIag6TtJ(XOxO0qdX8VxF)9StppDBZavYCyVyz6TdR91b8eiQAX)zERW0fs7otdDxXacXniZS5sq8HoQaaXRphR7jGnji5)zDZT0Dfhjgl8B18QvXSYEuUfg4pDISxzlsbtZ5uqe2WRfLqMrcLN0UXxL5(P5nRY6y9sz9XE7s7V8AQNpkJenSSZ)f1Hrhm4Ag3FSbhp2taWEI7FCtydXk83Lv8K9ldhMOGyLt6z)P1XDpYxIiAhGA(fpstOrZI4jTTTgEAlQT(608lmgrCh(tWXbd7TZAWFpWoVwkOyAEKhue0ukVPjEYUKo76JzkNu)HzEE6v4jjhdyaM)juhxcbWmbCHpv9R6UKPRJVwirTbyX9lrpaGpSQyLehvZk7dBmfjfaUxHu)yWBGRqr80sQLw19WJ3ryozm5vkmR3)3LpBDPSoPXS(Mz8P(AzsTTVUD8d7L7s9MQQrkhzNXZg9EjM)aM0y7lDNwUb0CYgB1JQA6a13r98SJiBw0dOlpEi)mnyGzBd1a2g0zs242izJ3MKSrw916F1izIGVA57G7AkRk5KuwqOnJvXV681YnlX6GHm(hjJOEZ)Q1Mf6Q)A0MuI5wuU3s)9M968w6VOSxNxY(RAAsISrf66XjgyNpuu4RBV2A4gYRvcgI6BW1)o4Y3WFTsRVj8v1LZjbUmbKWfsExwknK3yrBqseBzvxTeTsHnmBG1KT54CDroEBrfDI2P(TwejtdyKkecWkLlFZdbVV1nCywhseiNMmYQyAsgffJU3cv7aKkXnQd3UlH0ujMKSo0oWkdX2tbz8jvH21yhV)6qJ5Kdd2sLkhhsGUI5n94kafBqB8TTofjCP2hnWX5GsdbqTuNko3P1LMDRj95ZOCnijYjSH1zPSMiC12eXQ1d3z9bUTp3hZpovNsHAdgFTOMKuzk9HmC7(BxDwvnbFTY8jtRg)Dpz9iQohfnnw(nOlr5GkFforKpiDIpQVFRW8cRAnaSRDUgBrQzGqjrLMnJFzQtVJQgsMZjDNzz3Ah2xNwWUdsbkD0Dwd4KH96JfT6KHYyLStDpkomqMtBSZkkPkUH(WipmzKmhExRXK5kzlGnlnJ0XOm7ZIJo661kyRHbirRh6U9CZAIF8OgDBaHF6AFGi3cDc8jPtC81yyDw94XgJIHSb1P1JVnwGCDK)2(27Y6z7hqBSvHuFIQWoi4klXUO6wyWCudrlYk8tb6sqOB99JbDBdrxTTWnfD11kwHUFWQnsXu5r9rkpggOPn3ymMVpwJIZUhX7(gLwgC0OmHSvwUpbbGCEGES1qBxc3hBtfTIIY1yQ0Rg30PZ1NrYUQ5dYdhIUXa(bT1pCl)FxGik)orC3ySS1QzT4nb6VBD3zoA8dp42TN9d1oXA2qFdQPCLowSs1etUXytX75YaX)xJQPfQfcghg5tnp(oUNwhUoDvlC5TyFpFSEJrM77qBxcC6jvm8xXzh9migxft1vmrjr8(MEakQoDGTyT7nHdpsgZTyrr73ZOFJw4Fb4RZwrf3MQIvZvXORJizI6w4z(Qj3Cp1ip7hOg2H01BTTHo5iPvRano0jhnObgwUeZ5Ib1uzzZOhercC(QQoOrXrlQy7R3E1TKeNMJQmznec17yRIww1bCQ)2vi18zwcS8zZkqwmp0NqEWQ2(JhoyBjrko1KZtIVL4qkBFknGnH78TMjeIYnouhUdBBagGItNgLClf60uqmpn7u1HXstZ0bRruVgUN0bIJRKRnYiGMd6q6L0EB9YNRB6PY6k7Irk0RrNU2yARLgdHNmMjzuSvXVcepqikw0eeO7njFbIOTYSTZdi780jDSjQOmYehmKUgJp)))d]] )
