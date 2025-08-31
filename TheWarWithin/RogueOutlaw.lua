-- RogueOutlaw.lua
-- August 2025
-- Patch 11.2

-- Contributed to JoeMama.
if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 260 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints
local FindPlayerAuraByID = ns.FindPlayerAuraByID
local min = ns.safeMin

spec:RegisterResource( Enum.PowerType.ComboPoints, {
    -- Gain 1 CP every 0.5 s while channeling Killing Spree
    killing_spree = {
        channel = "killing_spree",                     -- only active during the channel
        last = function ()                             -- time of the most recent tick
            local app  = state.buff.casting.applied    -- channel started here
            local tick = 0.5 * state.haste
            local t    = state.query_time
            return app + math.floor( ( t - app ) / tick ) * tick
        end,
        interval = function () return 0.5 * state.haste end,
        value    = 1,                                  -- add 1 combo-point per tick
    },
} )
spec:RegisterResource( Enum.PowerType.Energy, {
        blade_rush = {
            aura = "blade_rush",

            last = function ()
                local app = state.buff.blade_rush.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function() return class.auras.blade_rush.tick_time end,
            value = 5,
        },
    },
    nil, -- No replacement model.
    {    -- Meta function replacements.
        base_time_to_max = function( t )
            if buff.adrenaline_rush.up then
                if t.current > t.max - 50 then return 0 end
                return state:TimeToResource( t, t.max - 50 )
            end
        end,
        base_deficit = function( t )
            if buff.adrenaline_rush.up then
                return max( 0, ( t.max - 50 ) - t.current )
            end
        end,
    }
)

-- Talents
spec:RegisterTalents( {
    -- Rogue
    acrobatic_strikes              = {  90752,  455143, 1 }, -- Auto-attacks increase auto-attack damage and movement speed by $s1% for $s2 sec, stacking up to $s3%
    airborne_irritant              = {  90741,  200733, 1 }, -- Blind has $s1% reduced cooldown, $s2% reduced duration, and applies to all nearby enemies
    alacrity                       = {  90751,  193539, 2 }, -- Your finishing moves have a $s1% chance per combo point to grant $s2% Haste for $s3 sec, stacking up to $s4 times
    atrophic_poison                = {  90763,  381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $s1 |$s2hour:hrs;. Each strike has a $s3% chance of poisoning the enemy, reducing their damage by $s4% for $s5 sec
    blackjack                      = {  90686,  379005, 1 }, -- Enemies have $s1% reduced damage and healing for $s2 sec after Blind or Sap's effect on them ends
    blind                          = {  90684,    2094, 1 }, -- Blinds all enemies near the target, causing them to wander disoriented for $s1 sec. Damage may interrupt the effect. Limit $s2
    cheat_death                    = {  90742,   31230, 1 }, -- Fatal attacks instead reduce you to $s1% of your maximum health. For $s2 sec afterward, you take $s3% reduced damage. Cannot trigger more often than once per $s4 min
    cloak_of_shadows               = {  90697,   31224, 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $s1 sec
    cold_blood                     = {  90748,  382245, 1 }, -- Increases the critical strike chance of your next damaging ability by $s1%
    deadened_nerves                = {  90743,  231719, 1 }, -- Physical damage taken reduced by $s1%
    deadly_precision               = {  90760,  381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by $s1%
    deeper_stratagem               = {  90750,  193531, 1 }, -- Gain $s1 additional max combo point. Your finishing moves that consume more than $s2 combo points have increased effects, and your finishing moves deal $s3% increased damage
    echoing_reprimand              = {  90638,  470669, 1 }, -- After consuming a supercharged combo point, your next Sinister Strike also strikes the target with an Echoing Reprimand dealing $s$s2 Physical damage
    elusiveness                    = {  90742,   79008, 1 }, -- Evasion also reduces damage taken by $s1%, and Feint also reduces non-area-of-effect damage taken by $s2%
    evasion                        = {  90764,    5277, 1 }, -- Increases your dodge chance by $s1% for $s2 sec
    featherfoot                    = {  94563,  423683, 1 }, -- Sprint increases movement speed by an additional $s1% and has $s2 sec increased duration
    fleet_footed                   = {  90762,  378813, 1 }, -- Movement speed increased by $s1%
    forced_induction               = {  90638,  470668, 1 }, -- Increase the bonus granted when a damaging finishing move consumes a supercharged combo point by $s1
    gouge                          = {  90741,    1776, 1 }, -- Gouges the eyes of an enemy target, incapacitating for $s1 sec. Damage may interrupt the effect. Must be in front of your target. Awards $s2 combo point
    graceful_guile                 = {  94562,  423647, 1 }, -- Feint has $s1 additional charge
    improved_ambush                = {  90692,  381620, 1 }, -- Ambush generates $s1 additional combo point
    improved_sprint                = {  90746,  231691, 1 }, -- Reduces the cooldown of Sprint by $s1 sec
    improved_wound_poison          = {  90637,  319066, 1 }, -- Wound Poison can now stack $s1 additional times
    iron_stomach                   = {  90744,  193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by $s1%
    leeching_poison                = {  90758,  280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you $s1% Leech
    lethality                      = {  90749,  382238, 2 }, -- Critical strike chance increased by $s1%. Critical strike damage bonus of your attacks that generate combo points increased by $s2%
    master_poisoner                = {  90636,  378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%
    nimble_fingers                 = {  90745,  378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1
    numbing_poison                 = {  90763,    5761, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $s1 |$s2hour:hrs;. Each strike has a $s3% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $s4% for $s5 sec
    recuperator                    = {  90640,  378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per $s2 sec
    rushed_setup                   = {  90754,  378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%
    shadowheart                    = { 101714,  455131, 1 }, -- Leech increased by $s1% while Stealthed
    shadowrunner                   = {  90687,  378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster
    shiv                           = {  90740,    5938, 1 }, -- Attack with your off-hand, dealing $s$s2 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards $s3 combo point
    soothing_darkness              = {  90691,  393970, 1 }, -- You are healed for $s1% of your maximum health over $s2 sec after activating Vanish
    stillshroud                    = {  94561,  423662, 1 }, -- Shroud of Concealment has $s1% reduced cooldown
    subterfuge                     = {  90688,  108208, 2 }, -- Abilities requiring Stealth can be used for $s1 sec after Stealth breaks. Combat benefits requiring Stealth persist for an additional $s2 sec after Stealth breaks
    supercharger                   = {  90639,  470347, 2 }, -- Roll the Bones supercharges $s1 combo point. Damaging finishing moves consume a supercharged combo point to function as if they spent $s2 additional combo points
    superior_mixture               = {  94567,  423701, 1 }, -- Crippling Poison reduces movement speed by an additional $s1%
    thistle_tea                    = {  90756,  381623, 1 }, -- Restore $s1 Energy. Mastery increased by $s2% for $s3 sec. When your Energy is reduced below $s4, drink a Thistle Tea
    thrill_seeking                 = {  90695,  394931, 1 }, -- Grappling Hook has $s1 additional charge
    tight_spender                  = {  90692,  381621, 1 }, -- Energy cost of finishing moves reduced by $s1%
    tricks_of_the_trade            = {  90686,   57934, 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $s1 sec and lasting $s2 sec
    unbreakable_stride             = {  90747,  400804, 1 }, -- Reduces the duration of movement slowing effects $s1%
    vigor                          = {  90759,   14983, 2 }, -- Increases your maximum Energy by $s1 and Energy regeneration by $s2%
    virulent_poisons               = {  90760,  381543, 1 }, -- Increases the damage of your weapon poisons by $s1%
    without_a_trace                = { 101713,  382513, 1 }, -- Vanish has $s1 additional charge

    -- Outlaw
    ace_up_your_sleeve             = {  90670,  381828, 1 }, -- Between the Eyes has a $s1% chance per combo point spent to grant $s2 combo points
    adrenaline_rush                = {  90659,   13750, 1 }, -- Increases your Energy regeneration rate by $s1%, your maximum Energy by $s2, and your attack speed by $s3% for $s4 sec
    ambidexterity                  = {  90660,  381822, 1 }, -- Main Gauche has an additional $s1% chance to strike while Blade Flurry is active
    audacity                       = {  90641,  381845, 1 }, -- Half-cost uses of Pistol Shot have a $s1% chance to make your next Ambush usable without Stealth. Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time
    blade_rush                     = {  90664,  271877, 1 }, -- Charge to your target with your blades out, dealing $s$s2 Physical damage to the target and $s3 to all other nearby enemies. While Blade Flurry is active, damage to non-primary targets is increased by $s4%. Generates $s5 Energy over $s6 sec
    blinding_powder                = {  90643,  256165, 1 }, -- Reduces the cooldown of Blind by $s1% and increases its range by $s2 yds
    combat_potency                 = {  90646,   61329, 1 }, -- Increases your Energy regeneration rate by $s1%
    combat_stamina                 = {  90648,  381877, 1 }, -- Stamina increased by $s1%
    count_the_odds                 = {  90655,  381982, 1 }, -- Ambush, Sinister Strike, and Dispatch have a $s1% chance to grant you a Roll the Bones combat enhancement buff you do not already have for $s2 sec
    crackshot                      = {  94565,  423703, 1 }, -- Entering Stealth refreshes the cooldown of Between the Eyes. Between the Eyes has no cooldown and also Dispatches the target for $s1% of normal damage when used from Stealth
    dancing_steel                  = {  90669,  272026, 1 }, -- Blade Flurry strikes $s1 additional enemies and its duration is increased by $s2 sec
    deft_maneuvers                 = {  90672,  381878, 1 }, -- Blade Flurry's initial damage is increased by $s1% and generates $s2 combo point per target struck
    devious_stratagem              = {  90679,  394321, 1 }, -- Gain $s1 additional max combo point. Your finishing moves that consume more than $s2 combo points have increased effects, and your finishing moves deal $s3% increased damage
    dirty_tricks                   = {  90645,  108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy
    fan_the_hammer                 = {  90666,  381846, 2 }, -- When Sinister Strike strikes an additional time, gain $s1 additional stack of Opportunity. Max $s2 stacks. Half-cost uses of Pistol Shot consume $s3 additional stack of Opportunity to fire $s4 additional shot. Additional shots generate $s5 fewer combo point and deal $s6% reduced damage
    fatal_flourish                 = {  90662,   35551, 1 }, -- Your off-hand attacks have a $s1% chance to generate $s2 Energy
    float_like_a_butterfly         = {  90755,  354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by $s1 sec per combo point spent
    ghostly_strike                 = {  90644,  196937, 1 }, -- Strikes an enemy, dealing $s$s2 Physical damage and causing the target to take $s3% increased damage from your abilities for $s4 sec. Awards $s5 combo point
    greenskins_wickers             = {  90665,  386823, 1 }, -- Between the Eyes has a $s1% chance per Combo Point to increase the damage of your next Pistol Shot by $s2%
    heavy_hitter                   = {  90642,  381885, 1 }, -- Attacks that generate combo points deal $s1% increased damage
    hidden_opportunity             = {  90675,  383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush at $s1% of their value
    hit_and_run                    = {  90673,  196922, 1 }, -- Movement speed increased by $s1%
    improved_adrenaline_rush       = {  90654,  395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and full Energy when it ends
    improved_between_the_eyes      = {  90671,  235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage
    improved_main_gauche           = {  90668,  382746, 1 }, -- Main Gauche has an additional $s1% chance to strike
    keep_it_rolling                = {  90652,  381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by $s1 sec
    killing_spree                  = {  94566,   51690, 1 }, -- Finishing move that unleashes a barrage of gunfire, striking random enemies within $s1 yards for Physical damage. Number of strikes increased per combo point. Restores $s2 combo point every $s3 sec. $s4 point : $s5 million over $s6 sec $s7 points: $s8 million over $s9 sec $s10 points: $s11 million over $s12 sec $s13 points: $s14 million over $s15 sec $s16 points: $s17 million over $s18 sec $s19 points: $s20 million over $s21 sec $s22 points: $s23 million over $s24 sec
    loaded_dice                    = {  90656,  256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches
    opportunity                    = {  90683,  279876, 1 }, -- Sinister Strike has a $s1% chance to hit an additional time, making your next Pistol Shot half cost and double damage
    precise_cuts                   = {  90667,  381985, 1 }, -- Blade Flurry damage is increased by an additional $s1% per missing target below its maximum
    precision_shot                 = {  90647,  428377, 1 }, -- Between the Eyes and Pistol Shot have $s1 yd increased range, and Pistol Shot reduces the the target's damage done to you by $s2%
    quick_draw                     = {  90663,  196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate $s1 additional combo point, and deal $s2% additional damage
    retractable_hook               = {  90681,  256188, 1 }, -- Reduces the cooldown of Grappling Hook by $s1 sec, and increases its retraction speed
    riposte                        = {  90661,  344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every $s1 sec
    ruthlessness                   = {  90680,   14161, 1 }, -- Your finishing moves have a $s1% chance per combo point spent to grant a combo point
    sleight_of_hand                = {  90651,  381839, 1 }, -- Roll the Bones has a $s1% increased chance of granting additional matches
    sting_like_a_bee               = {  90755,  131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take $s1% increased damage from all sources for $s2 sec
    summarily_dispatched           = {  90653,  381990, 2 }, -- When your Dispatch consumes $s1 or more combo points, Dispatch deals $s2% increased damage and costs $s3 less Energy for $s4 sec. Max $s5 stacks. Adding a stack does not refresh the duration
    swift_slasher                  = {  90649,  381988, 1 }, -- Slice and Dice grants additional attack speed equal to $s1% of your Haste
    take_em_by_surprise            = {  90676,  382742, 2 }, -- Haste increased by $s1% while Stealthed and for $s2 sec after breaking Stealth
    thiefs_versatility             = {  90753,  381619, 1 }, -- Versatility increased by $s1%
    triple_threat                  = {  90678,  381894, 1 }, -- Sinister Strike has a $s1% chance to strike with both weapons after it strikes an additional time
    underhanded_upper_hand         = {  90677,  424044, 1 }, -- Blade Flurry does not lose duration during Adrenaline Rush. Adrenaline Rush does not lose duration while Stealthed

    -- Fatebound
    chosens_revelry                = {  95138,  454300, 1 }, -- Leech increased by $s1% for each time your Fatebound Coin has flipped the same face in a row
    deal_fate                      = {  95107,  454419, 1 }, -- Sinister Strike and Ambush generate $s1 additional combo point when they strike an additional time
    deaths_arrival                 = {  95130,  454433, 1 }, -- Grappling Hook may be used a second time within $s1 sec with no cooldown, but its total cooldown is increased by $s2 sec
    delivered_doom                 = {  95119,  454426, 1 }, -- Damage dealt when your Fatebound Coin flips tails is increased by $s1% if there are no other enemies near the target. Each additional nearby enemy reduces this bonus by $s2%
    destiny_defined                = {  95114,  454435, 1 }, -- Sinister Strike has $s1% increased chance to strike an additional time and your Fatebound Coins flipped have an additional $s2% chance to match the same face as the last flip
    double_jeopardy                = {  95129,  454430, 1 }, -- Your first Fatebound Coin flip after breaking Stealth flips two coins that are guaranteed to match the same outcome
    edge_case                      = {  95139,  453457, 1 }, -- Activating Adrenaline Rush flips a Fatebound Coin and causes it to land on its edge, counting as both Heads and Tails
    fate_intertwined               = {  95120,  454429, 1 }, -- Fate Intertwined duplicates $s1% of Dispatch critical strike damage as Cosmic to $s2 additional nearby enemies. If there are no additional nearby targets, duplicate $s3% to the primary target instead
    fateful_ending                 = {  95127,  454428, 1 }, -- When your Fatebound Coin flips the same face for the seventh time in a row, keep the lucky coin to gain $s2% Agility until you leave combat for $s3 seconds. If you already have a lucky coin, it instead deals $s$s4 Cosmic damage to your target
    hand_of_fate                   = {  95125,  452536, 1 }, -- Flip a Fatebound Coin each time a finishing move consumes $s2 or more combo points. Heads increases the damage of your attacks by $s3%, lasting $s4 sec or until you flip Tails. Tails deals $s$s5 Cosmic damage to your target. For each time the same face is flipped in a row, Heads increases damage by an additional $s6% and Tails increases its damage by $s7%
    inevitabile_end                = {  95114,  454434, 1 }, -- Cold Blood now benefits the next two abilities but only applies to Dispatch. Fatebound Coins flipped by these abilities are guaranteed to match the same outcome as the last flip
    inexorable_march               = {  95130,  454432, 1 }, -- You cannot be slowed below $s1% of normal movement speed while your Fatebound Coin flips have an active streak of at least $s2 flips matching the same face
    mean_streak                    = {  95122,  453428, 1 }, -- Fatebound Coins flipped by Dispatch are $s1% more likely to match the same face as the last flip
    tempted_fate                   = {  95138,  454286, 1 }, -- You have a chance equal to your critical strike chance to absorb $s1% of any damage taken, up to a maximum chance of $s2%

    -- Trickster
    cloud_cover                    = {  95116,  441429, 1 }, -- Distract now also creates a cloud of smoke for $s1 sec. Cooldown increased to $s2 sec. Attacks from within the cloud apply Fazed
    coup_de_grace                  = {  95115,  441423, 1 }, -- After $s1 strikes with Unseen Blade, your next Dispatch will be performed as a Coup de Grace, functioning as if it had consumed $s2 additional combo points. If the primary target is Fazed, gain $s3 stacks of Flawless Form
    devious_distractions           = {  95133,  441263, 1 }, -- Killing Spree applies Fazed to any targets struck
    disorienting_strikes           = {  95118,  441274, 1 }, -- Killing Spree has $s1% reduced cooldown and allows your next $s2 strikes of Unseen Blade to ignore its cooldown
    dont_be_suspicious             = {  95134,  441415, 1 }, -- Blind and Shroud of Concealment have $s1% reduced cooldown. Pick Pocket and Sap have $s2 yd increased range
    flawless_form                  = {  95111,  441321, 1 }, -- Unseen Blade and Killing Spree increase the damage of your finishing moves by $s1% for $s2 sec. Multiple applications may overlap
    flickerstrike                  = {  95137,  441359, 1 }, -- Taking damage from an area-of-effect attack while Feint is active or dodging while Evasion is active refreshes your opportunity to strike with Unseen Blade. This effect may only occur once every $s1 sec
    mirrors                        = {  95141,  441250, 1 }, -- Feint reduces damage taken from area-of-effect attacks by an additional $s1%
    nimble_flurry                  = {  95128,  441367, 1 }, -- Blade Flurry damage is increased by $s1% while Flawless Form is active
    no_scruples                    = {  95116,  441398, 1 }, -- Finishing moves have $s1% increased chance to critically strike Fazed targets
    smoke                          = {  95141,  441247, 1 }, -- You take $s1% reduced damage from Fazed targets
    so_tricky                      = {  95134,  441403, 1 }, -- Tricks of the Trade's threat redirect duration is increased to $s1 hour
    surprising_strikes             = {  95121,  441273, 1 }, -- Attacks that generate combo points deal $s1% increased critical strike damage to Fazed targets
    thousand_cuts                  = {  95137,  441346, 1 }, -- Slice and Dice grants $s1% additional attack speed and gives your auto-attacks a chance to refresh your opportunity to strike with Unseen Blade
    unseen_blade                   = {  95140,  441146, 1 }, -- Sinister Strike and Ambush now also strike with an Unseen Blade dealing $s1 damage. Targets struck are Fazed for $s2 sec. Fazed enemies take $s3% more damage from you and cannot parry your attacks. This effect may occur once every $s4 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    boarding_party                 =  853, -- (209752)
    control_is_king                =  138, -- (354406) Cheap Shot grants Slice and Dice for $s1 sec and Kidney Shot restores $s2 Energy per combo point spent
    dagger_in_the_dark             = 5549, -- (198675) Each second while Stealth is active, nearby enemies within $s1 yards take an additional $s2% damage from you for $s3 sec. Stacks up to $s4 times
    death_from_above               = 3619, -- (269513) Finishing move that empowers your weapons with energy to perform a deadly attack. You leap into the air and Dispatch your target on the way back down, with such force that it has a $s1% stronger effect
    dismantle                      =  145, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for $s1 sec
    drink_up_me_hearties           =  139, -- (354425)
    maneuverability                =  129, -- (197000) Sprint has $s1% reduced cooldown and $s2% reduced duration
    preemptive_maneuver            = 5699, -- (1219122) Feint decreases your damage taken by an additional $s1% while stunned and its energy cost is reduced by $s2%
    smoke_bomb                     = 3483, -- (212182) Creates a cloud of thick smoke in an $s1 yard radius around the Rogue for $s2 sec. Enemies are unable to target into or out of the smoke cloud
    thick_as_thieves               = 1208, -- (221622) Tricks of the Trade now increases the friendly target's damage by $s1% for $s2 sec
    turn_the_tables                = 3421, -- (198020)
} )

local rtb_buff_list = {
    "broadside", "buried_treasure", "grand_melee", "ruthless_precision", "skull_and_crossbones", "true_bearing", "rtb_buff_1", "rtb_buff_2"
}

-- Auras
spec:RegisterAuras( {
    -- Talent: Energy regeneration increased by $w1%.  Maximum Energy increased by $w4.  Attack speed increased by $w2%.  $?$w5>0[Damage increased by $w5%.][]
    -- https://wowhead.com/beta/spell=13750
    adrenaline_rush = {
        id = 13750,
        duration = 20,
        max_stack = 1
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
        max_stack = 1
    },
    alacrity = {
        id = 193538,
        duration = 15,
        max_stack = 5
    },
    audacity = {
        id = 386270,
        duration = 10,
        max_stack = 1,
    },
    -- $w2% increased critical strike chance.
    between_the_eyes = {
        id = 315341,
        duration = function() return 3 * effective_combo_points end,
        max_stack = 1
    },
    -- Talent: Attacks striking nearby enemies.
    -- https://wowhead.com/beta/spell=13877
    blade_flurry = {
        id = 13877,
        duration = function () return talent.dancing_steel.enabled and 13 or 10 end,
        max_stack = 1
    },
    -- Talent: Generates $s1 Energy every sec.
    -- https://wowhead.com/beta/spell=271896
    blade_rush = {
        id = 271896,
        duration = 5,
        tick_time = 1,
        max_stack = 1
    },
    coup_de_grace = {
        id = 462127,
        duration = 3600,
        max_stack = 1
    },
    disorienting_strikes = {
        duration = 3600,
        max_stack = 2
    },
    double_jeopardy = {
        duration = 3600,
        max_stack = 1
    },
    echoing_reprimand = {
        id = 470671,
        duration = 30,
        max_stack = 1
    },
    escalating_blade = {
        id = 441786,
        duration = 3600,
        max_stack = 4
    },
    -- Taking 5% more damage from $auracaster.
    fazed = {
        id = 441224,
        duration = 10,
        max_stack = 1
    },
    flawless_form = {
        id = 441326,
        duration = 12,
        max_stack = 20
    },
    -- Talent: Taking $s3% increased damage from the Rogue's abilities.
    -- https://wowhead.com/beta/spell=196937
    ghostly_strike = {
        id = 196937,
        duration = 10,
        max_stack = 1
    },
    -- Suffering $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=154953
    internal_bleeding = {
        id = 154953,
        duration = 6,
        tick_time = 1,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Increase the remaining duration of your active Roll the Bones combat enhancements by 30 sec.
    keep_it_rolling = {
        id = 381989
    },
    -- Killing Spree Blasting nearby enemies every $s1 sec. $s2 seconds remaining
    -- https://www.wowhead.com/spell=51690
    killing_spree = {
        id = 51690,
        duration = function () return 0.5 * effective_combo_points * haste end,
        tick_time = function () return 0.5 * haste end,
        max_stack = 1
    },
    -- Suffering $w4 Nature damage every $t4 sec.
    -- https://wowhead.com/beta/spell=385627
    kingsbane = {
        id = 385627,
        duration = 14,
        max_stack = 50
    },
    -- Talent: Leech increased by $s1%.
    -- https://wowhead.com/beta/spell=108211
    leeching_poison = {
        id = 108211,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Your next $?s5171[Slice and Dice will be $w1% more effective][Roll the Bones will grant at least two matches].
    -- https://wowhead.com/beta/spell=256171
    loaded_dice = {
        id = 256171,
        duration = 45,
        max_stack = 1,
        copy = 240837
    },
    -- Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=286581
    nothing_personal = {
        id = 286581,
        duration = 20,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Pistol Shot costs $s1% less Energy and deals $s3% increased damage.
    -- https://wowhead.com/beta/spell=195627
    opportunity = {
        id = 195627,
        duration = 12,
        max_stack = 6
    },
    -- Movement speed reduced by $s3%.
    -- https://wowhead.com/beta/spell=185763
    pistol_shot = {
        id = 185763,
        duration = 6,
        max_stack = 1
    },
    -- Incapacitated.
    -- https://wowhead.com/beta/spell=107079
    quaking_palm = {
        id = 107079,
        duration = 4,
        max_stack = 1
    },
    riposte = {
        id = 199754,
        duration = 10,
        max_stack = 1
    },
    sharpened_sabers = {
        id = 252285,
        duration = 15,
        max_stack = 2
    },
    soothing_darkness = {
        id = 393971,
        duration = 6,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.$?s245751[    Allows you to run over water.][]
    -- https://wowhead.com/beta/spell=2983
    sprint = {
        id = 2983,
        duration = 8,
        max_stack = 1
    },
    subterfuge = {
        id = 115192,
        duration = function() return 3 * talent.subterfuge.rank end,
        max_stack = 1
    },
    -- Damage taken increased by $w1%.
    stinging_vulnerability = {
        id = 255909,
        duration = 6,
        max_stack = 1
    },
    summarily_dispatched = {
        id = 386868,
        duration = 8,
        max_stack = 5
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=385907
    take_em_by_surprise = {
        id = 385907,
        duration = function() return combat and 10 * talent.take_em_by_surprise.rank + 3 * talent.subterfuge.rank or 3600 end,
        max_stack = 1
    },
    -- Talent: Threat redirected from Rogue.
    -- https://wowhead.com/beta/spell=57934
    tricks_of_the_trade = {
        id = 57934,
        duration = 30,
        max_stack = 1
    },
    unseen_blade = {
        id = 459485,
        duration = 20,
        max_stack = 1
    },
    -- Real RtB buffs.
    broadside = {
        id = 193356,
        duration = 30
    },
    buried_treasure = {
        id = 199600,
        duration = 30
    },
    grand_melee = {
        id = 193358,
        duration = 30
    },
    ruthless_precision = {
        id = 193357,
        duration = 30
    },
    skull_and_crossbones = {
        id = 199603,
        duration = 30
    },
    true_bearing = {
        id = 193359,
        duration = 30
    },
    -- Fake buffs for forecasting.
    rtb_buff_1 = {
        duration = 30
    },
    rtb_buff_2 = {
        duration = 30
    },
    supercharged_combo_points = {
        -- todo: Find a way to find a true buff / ID for this as a failsafe? Currently fully emulated.
        duration = 3600,
        max_stack = function() return combo_points.max end,
        copy = { "supercharge", "supercharged", "supercharger" }
    },
    -- Roll the dice of fate, providing a random combat enhancement for 30 sec.
    roll_the_bones = {
        alias = rtb_buff_list,
        aliasMode = "longest", -- use duration info from the buff with the longest remaining time.
        aliasType = "buff",
        duration = 30
    },
    lethal_poison = {
        alias = { "instant_poison", "wound_poison" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600
    },
    nonlethal_poison = {
        alias = { "numbing_poison", "crippling_poison", "atrophic_poison" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600
    },

    -- Legendaries (Shadowlands)
    concealed_blunderbuss = {
        id = 340587,
        duration = 8,
        max_stack = 1
    },
    deathly_shadows = {
        id = 341202,
        duration = 15,
        max_stack = 1
    },
    greenskins_wickers = {
        id = 340573,
        duration = 15,
        max_stack = 1,
        copy = 394131
    },
    master_assassins_mark = {
        id = 340094,
        duration = 4,
        max_stack = 1,
        copy = "master_assassin_any"
    },

    -- Azerite
    snake_eyes = {
        id = 275863,
        duration = 30,
        max_stack = 1
    },
} )



local inStealth = false
local exitedStealth = 0

spec:RegisterEvent( "UPDATE_STEALTH", function()
    local stealthed = IsStealthed()
    if inStealth and not stealthed then exitedStealth = GetTime() end
    inStealth = stealthed
end )

local lastShot, numShots = 0, 0
local lastUnseenBlade, disorientStacks = 0, 0
local lastRoll = 0
local rollDuration = 30
local rtbApplicators = {
    roll_the_bones = true,
    ambush = true,
    dispatch = true,
    keep_it_rolling = true,
}
local restless_blades_list = {
    "adrenaline_rush",
    "between_the_eyes",
    "blade_flurry",
    "blade_rush",
    "ghostly_strike",
    "grappling_hook",
    "keep_it_rolling",
    "killing_spree",
    "roll_the_bones",
    "sprint",
    "vanish"
}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= state.GUID then return end
    
    -- SPELL_CAST_SUCCESS
    if subtype == "SPELL_CAST_SUCCESS" then
        local now = GetTime()

        if spellID == 185763 and state.talent.fan_the_hammer.enabled then
            -- Opportunity: Fan the Hammer can queue 1-2 extra Pistol Shots.
            if now - lastShot > 0.5 then
                local oppoStacks = ( select( 3, FindPlayerAuraByID( 195627 ) ) or 1 ) - 1
                lastShot = now
                numShots = min( state.talent.fan_the_hammer.rank, oppoStacks, 2 )

                Hekili:ForceUpdate( "FAN_THE_HAMMER", true )
            else
                numShots = max( 0, numShots - 1 )
            end

            return
        end

        if spellID == 51690 and state.talent.disorienting_strikes.enabled then -- Killing Spree grants 2 stacks of Disorienting Strikes (hidden aura)
            disorientStacks = 2
            return
        end

        if spellID == 193315 or spellID == 8676 then -- Sinister Strike (193315) or Ambush (8676) consumes 1 Disorienting Strike stack.
            disorientStacks = disorientStacks - 1
            return
        end

        if spellID == 315508 then
            -- 1. ‑‑ compute pandemic before we overwrite rollDuration
            local elapsed    = now - lastRoll           -- time since previous roll
            local remaining  = max( 0, rollDuration - elapsed )   -- container time left
            local pandemic   = min( 9, max( 0, remaining ) )
            -- 2. ‑‑ reset container
            lastRoll     = now                          -- real start‑time
            rollDuration = 30 + pandemic                -- 30 s + up‑to‑9 s
            return
        end

        return
    end

    -- SPELL_DAMAGE
    if subtype == "SPELL_DAMAGE" then
        local now = GetTime()
        if spellID == 441144 then  -- Unseen Blade damage event.
            if disorientStacks < 0 then
                lastUnseenBlade = now
            end
        end
        return
    end

    if subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" then
        if exitedStealth > 0 and ( spellID == class.auras.fatebound_coin_heads.id or spellID == class.auras.fatebound_coin_tails.id ) then
            exitedStealth = 0
        end
    end
end )

spec:RegisterStateExpr( "rtb_buffs", function ()
    return buff.roll_the_bones.count
end )

spec:RegisterStateExpr( "last_unseen_blade", function ()
    return lastUnseenBlade
end )

spec:RegisterStateExpr( "disorient_stacks", function ()
    return disorientStacks
end )

spec:RegisterStateExpr( "unseen_blades_available", function ()
    local count = 0

    -- add 1 if the ICD is cooled down
    if state.query_time - lastUnseenBlade >= 20 then count = count + 1 end

    -- add the # of bypasses that are available
    if disorientStacks > 0 then count = count + disorientStacks end

    return count
end )

local TriggerUnseenBlade = setfenv( function( )
    if unseen_blades_available > 0 then
        -- Handle ICD vs bypass
        if buff.disorienting_strikes.remains then
            removeStack( "disorienting_strikes" )
        else
            last_unseen_blade = query_time
            applyDebuff( "player", "unseen_blade" )
        end

        addStack( "escalating_blade" )
        if buff.escalating_blade.stack == 4 then applyBuff( "coup_de_grace" ) end
        applyDebuff( "target", "fazed" )
        unseen_blades_available = unseen_blades_available - 1
    end
end, state )

spec:RegisterStateExpr( "rtb_primary_remains", function ()
    local baseTime = max( lastRoll or 0, action.roll_the_bones.lastCast or 0 )
    return max( 0, baseTime + rollDuration - query_time )
end )

--[[   local remains = 0

    for rtb, appliedBy in pairs( rtbAuraAppliedBy ) do
        if appliedBy == "roll_the_bones" then
            local bone = buff[ rtb ]
            if bone.up then remains = max( remains, bone.remains ) end
        end
    end

    return remains
end ) ]]

spec:RegisterStateExpr( "rtb_buffs_shorter", function ()
    local n = 0
    local primary = rtb_primary_remains

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and bone.remains < primary - 0.2 then -- Slightly larger threshold
            n = n + 1
        end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_normal", function ()
    local n = 0
    local primary = rtb_primary_remains
    local tolerance = 0.2  -- Threshold for "close enough"

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and abs( bone.remains - primary ) <= tolerance then
            n = n + 1
        end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_min_remains", function ()
    local r = 3600

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ].remains
        if bone > 0 then r = min( r, bone ) end
    end

    return r == 3600 and 0 or r
end )

spec:RegisterStateExpr( "rtb_buffs_max_remains", function ()
    local r = 0

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        r = max( r, bone.remains )
    end

    return r
end )

spec:RegisterStateExpr( "rtb_buffs_longer", function ()
    local n = 0
    local primary = rtb_primary_remains

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and bone.remains > primary + 0.2 then -- Slightly larger threshold
            n = n + 1
        end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_will_lose", function ()
    local count = 0
    count = count + ( rtb_buffs_will_lose_buff.broadside and 1 or 0 )
    count = count + ( rtb_buffs_will_lose_buff.buried_treasure and 1 or 0 )
    count = count + ( rtb_buffs_will_lose_buff.grand_melee and 1 or 0 )
    count = count + ( rtb_buffs_will_lose_buff.ruthless_precision and 1 or 0 )
    count = count + ( rtb_buffs_will_lose_buff.skull_and_crossbones and 1 or 0 )
    count = count + ( rtb_buffs_will_lose_buff.true_bearing and 1 or 0 )
    return count
end )

spec:RegisterStateTable( "rtb_buffs_will_lose_buff", setmetatable( {}, {
    __index = function( t, k )
        return buff[ k ].up and buff[ k ].remains <= rtb_primary_remains + 0.1
    end
} ) )

spec:RegisterStateTable( "rtb_buffs_will_retain_buff", setmetatable( {}, {
    __index = function( t, k )
        return buff[ k ].up and not rtb_buffs_will_lose_buff[ k ]
    end
} ) )

spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )

spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "COMBO_POINTS" then
        Hekili:ForceUpdate( event, true )
    end
end )

spec:RegisterStateExpr( "mantle_duration", function ()
    return legendary.mark_of_the_master_assassin.enabled and 4 or 0
end )

spec:RegisterStateExpr( "master_assassin_remains", function ()
    if not legendary.mark_of_the_master_assassin.enabled then
        return 0
    end

    if stealthed.mantle then
        return cooldown.global_cooldown.remains + 4
    elseif buff.master_assassins_mark.up then
        return buff.master_assassins_mark.remains
    end

    return 0
end )

spec:RegisterStateExpr( "cp_gain", function ()
    return ( this_action and class.abilities[ this_action ].cp_gain or 0 )
end )

spec:RegisterStateExpr( "effective_combo_points", function ()
    local c = combo_points.current or 0

    if c > 0 and buff.supercharged_combo_points.up then
        c = c + ( talent.forced_induction.enabled and 3 or 2 )
    end

    return c
end )

-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if stealthed.all and ( not a or a.startsCombat ) then
        if buff.stealth.up then
            setCooldown( "stealth", 2 )
            if buff.take_em_by_surprise.up then
                buff.take_em_by_surprise.expires = query_time + 10 * talent.take_em_by_surprise.rank
            end
            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end
        end
        
        if talent.double_jeopardy.enabled then
            applyBuff( "double_jeopardy" )
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark" )
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )
    end
    if buff.cold_blood.up and ( ability == "ambush" or not talent.inevitable_end.enabled ) and ( not a or a.startsCombat ) then
        removeStack( "cold_blood" )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "combo_points" then
        if amt >= 5 and talent.ruthlessness.enabled then gain( 1, "combo_points" ) end

        local cdr = amt * ( buff.true_bearing.up and 1.5 or 1 )

        for _, action in ipairs( restless_blades_list ) do
            reduceCooldown( action, cdr )
        end

        if talent.float_like_a_butterfly.enabled then
            reduceCooldown( "evasion", amt * 0.5 )
            reduceCooldown( "feint", amt * 0.5 )
        end

        if legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
        end
    end
end )

local ExpireAdrenalineRush = setfenv( function ()
    gain( energy.max, "energy" )
end, state )

for i = 1, 7 do
    spec:RegisterStateExpr( "supercharge_" .. i, function ()
        return buff.supercharged_combo_points.stack >= i
    end )
end

spec:RegisterHook( "reset_precast", function()
    -- Supercharged Combo Point handling
    local cPoints = GetUnitChargedPowerPoints( "player" )
    if talent.supercharger.enabled and cPoints then
        local charged = 0
        for _, point in pairs( cPoints ) do
            charged = charged + 1
        end
        if charged > 0 then applyBuff( "supercharged_combo_points", nil, charged ) end
    end

    if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end

    if buff.adrenaline_rush.up and talent.improved_adrenaline_rush.enabled then
        state:QueueAuraExpiration( "adrenaline_rush", ExpireAdrenalineRush, buff.adrenaline_rush.expires )
    end

    if buff.cold_blood.up then setCooldown( "cold_blood", action.cold_blood.cooldown ) end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    if talent.unseen_blade.enabled then
        -- Sync CDG availabilty with gamestate
        if talent.coup_de_grace.enabled and IsSpellOverlayed( 2098 ) then
            applyBuff( "coup_de_grace" )
        end

        -- Sync unseen blade ICD with gamestate
        local unseenBladeCD = 20 - ( now - last_unseen_blade )
        if unseenBladeCD > 0 then
            applyDebuff( "player", "unseen_blade", unseenBladeCD )
        else
            removeDebuff( "player", "unseen_blade" )
        end

        -- sync disorienting strike stacks with gamestate
        if disorient_stacks > 0 then
            applyBuff( "disorienting_strikes", nil, disorient_stacks )
        else
            removeBuff( "disorienting_strikes" )
        end
        if Hekili.ActiveDebug then
            Hekili:Debug( "UB-Status: unseen_blades_available=%d DS=%d  ICD=%.1f",
              unseen_blades_available,
              buff.disorienting_strikes.stack or 0,
              unseenBladeCD
            )
        end
    end

    -- Debugging for Roll the Bones
    if Hekili.ActiveDebug and buff.roll_the_bones.up then
       -- local elapsed = query_time - lastRoll
       -- local remaining = max( 0, rollDuration - elapsed )
       -- local pandemic = min( 9, remaining )
       -- Hekili:Debug( "RTB: elapsed=%.2f  pandemic=%.2f  duration=%.2f",
       --               elapsed, pandemic, rollDuration )
        Hekili:Debug( "RTB   queueBase=%.2f (lastRoll=%.2f / lastCast=%.2f)  rollDur=%.2f",
                      max( lastRoll or 0, action.roll_the_bones.lastCast or 0 ),
                      lastRoll or 0,
                      action.roll_the_bones.lastCast or 0,
                      rollDuration )
        Hekili:Debug( "\nRoll the Bones Debugging:" )
        Hekili:Debug( " - lastRoll: %.2f", lastRoll )
        Hekili:Debug( " - rollDuration: %.2f", rollDuration )
        Hekili:Debug( " - rtb_primary_remains: %.2f", rtb_primary_remains )
        Hekili:Debug( " - Totals  | longer: %d  normal: %d  shorter: %d  willLose: %d",
        rtb_buffs_longer, rtb_buffs_normal, rtb_buffs_shorter, rtb_buffs_will_lose )

        local lenTol = 0.2                             -- length tolerance for "longer" and "shorter"
        local primary  = rtb_primary_remains
        Hekili:Debug(" - Buff Status (vs. %.2f):", rtb_primary_remains)

        for i = 1, #rtb_buff_list do
            local name = rtb_buff_list[i]
            local b = buff[name]
            if b.up then
                local diff = b.remains - primary
                local label = diff > lenTol and "longer"
                             or diff < -lenTol and "shorter"
                             or                     "normal"
                local lose = rtb_buffs_will_lose_buff[name] and "*" or " "  -- mark with * what buff will be lost
                Hekili:Debug("   %s %-20s %5.2f [%s]", lose, name, b.remains, label)
            end
        end
    end

    -- Fan the Hammer.
    if query_time - lastShot < 0.5 and numShots > 0 then
        local n = numShots * ( action.pistol_shot.cp_gain - 1 )

        if Hekili.ActiveDebug then Hekili:Debug( "Generating %d combo points from pending Fan the Hammer casts; removing %d stacks of Opportunity.", n, numShots ) end
        gain( n, "combo_points" )
        removeStack( "opportunity", numShots )
    end

    if talent.underhanded_upper_hand.enabled and buff.adrenaline_rush.up then
        -- Revisit for all Stealth effects (and then resume countdown upon breaking Stealth).
        if buff.subterfuge.up then
            buff.adrenaline_rush.expires = buff.adrenaline_rush.expires + buff.subterfuge.remains
        end
        if buff.blade_flurry.up then
            buff.blade_flurry.expires = buff.blade_flurry.expires + buff.adrenaline_rush.remains
        end
    end

    if talent.double_jeopardy.enabled and exitedStealth > 0 then
        if Hekili.ActiveDebug then Hekili:Debug( "Double Jeopardy: Applying pseudobuff since Fatebound Coin not applied since exiting Stealth at %.2f.", exitedStealth ) end
        applyBuff( "double_jeopardy" )
    end
end )

spec:RegisterGear( {
    -- The War Within
    tww3 = {
        items = { 237667, 237665, 237663, 237664, 237662 },
        auras = {
            tww3_trickster_4pc = {
                -- id = 999998,
                duration = 5,
                max_stack = 1,
                generate = function( t )
                    local cdg = buff.coup_de_grace
                    if set_bonus.tww3 >= 4 and cdg.up and cdg.remains <= 10 then
                        -- Only treat this as the "trickster window" version if it's the 5s duration .. use 10s just as a safety net. The other version of the aura is 3600
                        t.name = "tww3_trickster_4pc"
                        t.count = 1
                        t.expires = cdg.expires
                        t.applied = cdg.expires - 5
                        t.caster = "player"
                    else
                        t.name = "tww3_trickster_4pc"
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
                end
            }
        },
    },
    tww2 = {
        items = { 229290, 229288, 229289, 229287, 229292 },
        auras = {
            -- 2-set
            winning_streak = {
                id = 1217078,
                duration = 3600,
                max_stack = 10
            }
        }
    },

    -- Dragonflight
    tier31 = {
        items = { 207234, 207235, 207236, 207237, 207239, 217208, 217210, 217206, 217207, 217209 }
    },
    tier30 = {
        items = { 202500, 202498, 202497, 202496, 202495 },
        auras = {
            soulrip = {
                id = 409604,
                duration = 8,
                max_stack = 1
            },
            soulripper = {
                id = 409606,
                duration = 15,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200372, 200374, 200369, 200371, 200373 },
        auras = {
            vicious_followup = {
                id = 394879,
                duration = 15,
                max_stack = 1
            },
            brutal_opportunist = {
                id = 394888,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Legion Legendary
    mantle_of_the_master_assassin = {
        items = { 144236 },
        auras = {
            master_assassins_initiative = {
                id = 235027,
                duration = 3600
            }
        }
    }
} )

-- Abilities
spec:RegisterAbilities( {
    -- Talent: Increases your Energy regeneration rate by $s1%, your maximum Energy by $s4, and your attack speed by $s2% for $d.
    adrenaline_rush = {
        id = 13750,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "adrenaline_rush",
        startsCombat = false,
        texture = 136206,

        toggle = "cooldowns",

        cp_gain = function () return talent.improved_adrenaline_rush.enabled and combo_points.max or 0 end,

        handler = function ()
            applyBuff( "adrenaline_rush" )
            if talent.improved_adrenaline_rush.enabled then
                gain( action.adrenaline_rush.cp_gain, "combo_points" )
                state:QueueAuraExpiration( "adrenaline_rush", ExpireAdrenalineRush, buff.adrenaline_rush.remains )
            end

            if talent.edge_case.enabled then
                addStack( "fatebound_coin_heads" )
                addStack( "fatebound_coin_tails" )
            end

            energy.regen = energy.regen * 1.6
            energy.max = energy.max + 50
            forecastResources( "energy" )

            if talent.loaded_dice.enabled then
                applyBuff( "loaded_dice" )
            end
            if talent.underhanded_upper_hand.enabled and buff.subterfuge.up then
                buff.adrenaline_rush.expires = buff.adrenaline_rush.expires + buff.subterfuge.remains
            end
            if azerite.brigands_blitz.enabled then
                applyBuff( "brigands_blitz" )
            end
        end
    },

    -- Finishing move that deals damage with your pistol, increasing your critical strike chance by $s2%.$?a235484[ Critical strikes with this ability deal four times normal damage.][];    1 point : ${$<damage>*1} damage, 3 sec;    2 points: ${$<damage>*2} damage, 6 sec;    3 points: ${$<damage>*3} damage, 9 sec;    4 points: ${$<damage>*4} damage, 12 sec;    5 points: ${$<damage>*5} damage, 15 sec$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$<damage>*6} damage, 18 sec][]$?s193531&(s394320|s394321)[;    7 points: ${$<damage>*7} damage, 21 sec][]
    between_the_eyes = {
        id = 315341,
        cast = 0,
        cooldown = function () return talent.crackshot.enabled and stealthed.rogue and 0 or 45 end,
        gcd = "totem",
        school = "physical",

        spend = function() return 25 * ( talent.tight_spender.enabled and 0.94 or 1 ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 135610,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            if talent.alacrity.rank > 1 and effective_combo_points > 9 then addStack( "alacrity" ) end

            applyBuff( "between_the_eyes" )

            if stealthed.rogue and talent.crackshot.enabled then
                spec.abilities.dispatch.handler()
            end

            if set_bonus.tier30_4pc > 0 and ( debuff.soulrip.up or active_dot.soulrip > 0 ) then
                removeDebuff( "target", "soulrip" )
                active_dot.soulrip = 0
                applyBuff( "soulripper" )
            end

            if azerite.deadshot.enabled then
                applyBuff( "deadshot" )
            end

            if legendary.greenskins_wickers.enabled or talent.greenskins_wickers.enabled and effective_combo_points >= 5 then
                applyBuff( "greenskins_wickers" )
            end

            if buff.double_jeopardy.up and combo_points.current > 4 then removeBuff( "double_jeopardy" ) end

            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )
        end
    },

    -- Strikes up to $?a272026[$331850i][${$331850i-3}] nearby targets for $331850s1 Physical damage$?a381878[ that generates 1 combo point per target][], and causes your single target attacks to also strike up to $?a272026[${$s3+$272026s3}][$s3] additional nearby enemies for $s2% of normal damage for $d.
    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "physical",

        spend = 15,
        spendType = "energy",

        startsCombat = false,

        cp_gain = function() return talent.deft_maneuvers.enabled and true_active_enemies or 0 end,
        handler = function ()
            applyBuff( "blade_flurry" )
            if talent.deft_maneuvers.enabled then gain( action.blade_flurry.cp_gain, "combo_points" ) end
            if talent.underhanded_upper_hand.enabled and buff.adrenaline_rush.up then buff.blade_flurry.expires = buff.blade_flurry.expires + buff.adrenaline_rush.remains end
        end
    },

    -- Talent: Charge to your target with your blades out, dealing ${$271881sw1*$271881s2/100} Physical damage to the target and $271881sw1 to all other nearby enemies.    While Blade Flurry is active, damage to non-primary targets is increased by $s1%.    |cFFFFFFFFGenerates ${$271896s1*$271896d/$271896t1} Energy over $271896d.
    blade_rush = {
        id = 271877,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "physical",

        talent = "blade_rush",
        startsCombat = true,

        usable = function () return not settings.check_blade_rush_range or target.distance < ( talent.acrobatic_strikes.enabled and 9 or 6 ), "no gap-closer blade rush is on, target too far" end,

        handler = function ()
            applyBuff( "blade_rush" )
            setDistance( 5 )
        end
    },

    death_from_above = {
        id = 269513,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 2,

        spend = function() return talent.tight_spender.enabled and 22.5 or 25 end,
        spendType = "energy",

        pvptalent = "death_from_above",
        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            if buff.double_jeopardy.up and combo_points.current > 4 then removeBuff( "double_jeopardy" ) end
            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )
        end
    },

    dismantle = {
        id = 207777,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 25,
        spendType = "energy",

        pvptalent = "dismantle",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dismantle" )
        end
    },

    dispatch = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function() return 35 * ( talent.tight_spender.enabled and 0.94 or 1 ) - ( 5 * buff.summarily_dispatched.stack ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        nobuff = "coup_de_grace",

        handler = function ()
            removeBuff( "brutal_opportunist" )

            if talent.alacrity.rank > 1 and effective_combo_points > 9 then addStack( "alacrity" ) end

            if talent.summarily_dispatched.enabled and combo_points.current > 5 then
                addStack( "summarily_dispatched", ( buff.summarily_dispatched.up and buff.summarily_dispatched.remains or nil ), 1 )
            end


            if buff.slice_and_dice.up then
                buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
            else applyBuff( "slice_and_dice", combo_points.current * 3 ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "vicious_followup" ) end

            if buff.double_jeopardy.up and combo_points.current > 4 then removeBuff( "double_jeopardy" ) end

            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )
        end,

        bind = "coup_de_grace"
    },

    -- Finishing move that dispatches the enemy, dealing damage per combo point:     1 point  : ${$m1*1} damage     2 points: ${$m1*2} damage     3 points: ${$m1*3} damage     4 points: ${$m1*4} damage     5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[     6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[     7 points: ${$m1*7} damage][]
    coup_de_grace = {
        id = 441776,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",
        known = 2098,

        spend = function() return 35 * ( talent.tight_spender.enabled and 0.94 or 1 ) - ( 5 * buff.summarily_dispatched.stack ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        buff = "coup_de_grace",
        talent = "coup_de_grace",

        handler = function ()
            spec.abilities.dispatch.handler()

            if debuff.fazed.up then addStack( "flawless_form", nil, 5 ) end

            if set_bonus.tww3 >= 4 and buff.tww3_trickster_4pc.down  then
                applyBuff( "coup_de_grace", 5 ) -- recast within 5 seconds
                applyBuff( "tww3_trickster_4pc" )
                applyBuff( "escalating_blade", 5, 4 )
            else
                removeBuff( "coup_de_grace" )
                removeBuff( "escalating_blade" )
                removeBuff( "tww3_trickster_4pc" )
            end

            setCooldown( "global_cooldown", 1.2 * ( buff.adrenaline_rush.up and haste or 1) )
        end,

        bind = "dispatch"
    },

    -- Talent: Strikes an enemy, dealing $s1 Physical damage and causing the target to take $s3% increased damage from your abilities for $d.    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    ghostly_strike = {
        id = 196937,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

        spend = 30,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = true,

        cp_gain = function () return 1 + ( buff.broadside.up and 1 or 0 ) end,

        handler = function ()
            applyDebuff( "target", "ghostly_strike" )
            gain( action.ghostly_strike.cp_gain, "combo_points" )
        end
    },

     -- Talent: Launch a grappling hook and pull yourself to the target location.
    grappling_hook = {
        id = 195457,
        cast = 0,
        cooldown = function () return ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( talent.retractable_hook.enabled and 45 or 60 ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        texture = 1373906,

        handler = function ()
        end
    },

    -- Talent: Increase the remaining duration of your active Roll the Bones combat enhancements by $s1 sec.
    keep_it_rolling = {
        id = 381989,
        cast = 0,
        cooldown = 360,
        gcd = "off",
        school = "physical",

        talent = "keep_it_rolling",
        startsCombat = false,

        toggle = "cooldowns",
        buff = "roll_the_bones",

        handler = function ()
           for _, v in pairs( rtb_buff_list ) do
                if buff[ v ].up then
                    -- Add 30 seconds but cap the total duration at 60 seconds.
                    local newExpires = buff[ v ].expires + 30
                    buff[ v ].expires = min( newExpires, query_time + 60 )

                    -- Optional Debugging
                    if Hekili.ActiveDebug then
                        Hekili:Debug( "Keep It Rolling applied to '%s': New expires = %.2f (capped at 60 seconds).", v, buff[ v ].expires )
                    end
                end
            end
        end
    },

    -- Talent: Teleport to an enemy within 10 yards, attacking with both weapons for a total of $<dmg> Physical damage over $d.    While Blade Flurry is active, also hits up to $s5 nearby enemies for $s2% damage.
    killing_spree = {
        id = 51690,
        cast = function () return 0.5 * effective_combo_points * haste end,
        channeled = true,

        cooldown = function () return 180 * ( talent.disorienting_strikes.enabled and 0.9 or 1 ) end,
        gcd = "totem",
        school = "physical",
        texture = 6735718,
        spend = function () return 45 * ( talent.tight_spender.enabled and 0.94 or 1 ) end,
        spendType = "energy",
        talent = "killing_spree",
        startsCombat = true,
        toggle = "cooldowns",
        usable = function () return combo_points.current > 0, "requires combo points" end,
        handler = function ()

        end,

        -- No tick_time/tick, no finish-refund – resource model does it.
        start = function ()
            if buff.double_jeopardy.up and combo_points.current > 4 then removeBuff( "double_jeopardy" ) end
                
            applyBuff( "killing_spree" )
            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )
            if talent.disorienting_strikes.enabled then
                applyBuff( "disorienting_strikes" )
                unseen_blades_available = unseen_blades_available + 2
            end
            if talent.flawless_form.enabled then addStack( "flawless_form" ) end
        end,
        finish = function() end,
    },

    -- Draw a concealed pistol and fire a quick shot at an enemy, dealing ${$s1*$<CAP>/$AP} Physical damage and reducing movement speed by $s3% for $d.    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    pistol_shot = {
        id = 185763,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return 40 - ( buff.opportunity.up and 20 or 0 ) end,
        spendType = "energy",

        startsCombat = true,

        cp_gain = function () return buff.shadow_blades.up and combo_points.max or ( 1 + ( buff.broadside.up and 1 or 0 ) + ( talent.quick_draw.enabled and buff.opportunity.up and 1 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ) ) end,

        handler = function ()
            gain( action.pistol_shot.cp_gain, "combo_points" )

            removeBuff( "deadshot" )
            removeBuff( "concealed_blunderbuss" ) -- Generating 2 extra combo points is purely a guess.
            removeBuff( "greenskins_wickers" )
            removeBuff( "tornado_trigger" )

            if buff.opportunity.up then
                removeStack( "opportunity" )
                if set_bonus.tier29_4pc > 0 then applyBuff( "brutal_opportunist" ) end
            end

            -- If Fan the Hammer is talented, let's generate more.
            if talent.fan_the_hammer.enabled then
                local shots = min( talent.fan_the_hammer.rank, buff.opportunity.stack )
                gain( shots * ( action.pistol_shot.cp_gain - 1 ), "combo_points" )
                removeStack( "opportunity", shots )
            end
        end
    },

    -- Talent: Roll the dice of fate, providing a random combat enhancement for $d.
    roll_the_bones = {
        id = 315508,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "physical",

        spend = 25,
        spendType = "energy",

        startsCombat = false,

        handler = function ()
            local pandemic = 0

            for _, name in pairs( rtb_buff_list ) do
                if rtb_buffs_will_lose_buff[ name ] then
                    pandemic = min( 9, max( pandemic, buff[ name ].remains ) )
                    removeBuff( name )
                end
            end

            if talent.supercharger.enabled then
                addStack( "supercharged_combo_points", nil, talent.supercharger.rank )
            end

            if azerite.snake_eyes.enabled then
                applyBuff( "snake_eyes", nil, 5 )
            end

            applyBuff( "rtb_buff_1", nil, 30 + pandemic )

            if buff.loaded_dice.up then
                applyBuff( "rtb_buff_2", nil, 30 + pandemic )
                removeBuff( "loaded_dice" )
            end

            if pvptalent.take_your_cut.enabled then
                applyBuff( "take_your_cut" )
            end

        end
    },


    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 25,
        gcd = "totem",
        school = "physical",

        spend = function () return legendary.tiny_toxic_blade.enabled and 0 or 20 end,
        spendType = "energy",

        talent = "shiv",
        startsCombat = true,

        cp_gain = function () return 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) end,

        handler = function ()
            gain( action.shiv.cp_gain, "combo_points" )
            removeDebuff( "target", "dispellable_enrage" )
        end
    },

    shroud_of_concealment = {
        id = 114018,
        cast = 0,
        cooldown = 360,
        gcd = "totem",
        school = "physical",

        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "shroud_of_concealment" )
        end
    },

    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        usable = function () return stealthed.ambush or buff.audacity.up, "requires stealth or audacity/blindside/sepsis_buff" end,

        cp_gain = function ()
            return 2 + ( buff.broadside.up and 1 or 0 ) + talent.improved_ambush.rank + ( buff.cold_blood.up and not talent.inevitable_end.enabled and 1 or 0 )
        end,

        handler = function ()
            gain( action.ambush.cp_gain, "combo_points" )
            if buff.audacity.up then removeBuff( "audacity" ) end
            if talent.unseen_blade.enabled then TriggerUnseenBlade() end

        end,

        copy = 430023,
        bind = "sinister_strike"
    },

    sinister_strike = {
        id = 193315,
        known = 1752,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 45,
        spendType = "energy",

        startsCombat = true,
        texture = 136189,


        cp_gain = function () return 1 + ( buff.broadside.up and 1 or 0 ) end,

        handler = function ()
            gain( action.sinister_strike.cp_gain, "combo_points" )
            removeStack( "snake_eyes" )
            if talent.unseen_blade.enabled then TriggerUnseenBlade() end
            if talent.echoing_reprimand.enabled then removeBuff( "echoing_reprimand" ) end

        end,

        copy = 1752,

        bind = "ambush"
    },

    smoke_bomb = {
        id = 212182,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        pvptalent = "smoke_bomb",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "smoke_bomb" )
        end
    },
} )

-- Override this for rechecking.
spec:RegisterAbility( "shadowmeld", {
    id = 58984,
    cast = 0,
    cooldown = 120,
    gcd = "off",

    usable = function () return boss and group end,
    handler = function ()
        applyBuff( "shadowmeld" )
    end
} )

spec:RegisterRanges( "pick_pocket", "kick", "blind", "shadowstep" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "tempered_potion",

    package = "Outlaw",
} )

local assassin = class.specs[ 259 ]

spec:RegisterSetting( "check_blade_rush_range", true, {
    name = strformat( "%s: Melee Only", Hekili:GetSpellLinkWithTexture( spec.abilities.blade_rush.id ) ),
    desc = strformat( "If checked, %s will not be recommended out of melee range.", Hekili:GetSpellLinkWithTexture( spec.abilities.blade_rush.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "allow_shadowmeld", false, {
    name = strformat( "%s: Use in Groups", Hekili:GetSpellLinkWithTexture( 58984 ) ),
    desc = strformat( "If checked, %s may be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in %s, even if your action bar does not change.  " ..
    "%s can only be recommended in boss fights or when you are in a group, to avoid resetting combat.", Hekili:GetSpellLinkWithTexture( 58984 ), Hekili:GetSpellLinkWithTexture( 58984 ), Hekili:GetSpellLinkWithTexture( 58984 ) ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled = not val
    end,
} )

spec:RegisterSetting( "solo_vanish", true, {
    name = strformat( "Allow %s When Solo", Hekili:GetSpellLinkWithTexture( 1856 ) ),  -- Vanish
    desc = strformat( "If enabled, %s can be recommended even when you are alone, |cFFFF0000which may reset combat|r.", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "vanish_charges_reserved", 0, {
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer than this number of (fractional) charges.", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = 1.5
} )

spec:RegisterSetting( "sinister_clash", -0.5, {
    name = strformat( "%s: Clash Buffer", Hekili:GetSpellLinkWithTexture( spec.abilities.sinister_strike.id ) ),
    desc = strformat( "If set below zero, %s will not be recommended when a higher priority ability is available within the time specified.\n\n"
        .. "Example: %s is ready in 0.3 seconds.  |W%s|w is ready immediately.  Clash Buffer is set to |W|cFF00B4FF-0.5s|r.|w  |W%s|w will not "
        .. "be recommended as it pretends to be unavailable for 0.5 seconds.\n\n"
        .. "Recommended: |cFF00B4FF-0.5s|r", Hekili:GetSpellLinkWithTexture( spec.abilities.sinister_strike.id ),
        Hekili:GetSpellLinkWithTexture( assassin.abilities.ambush.id ), spec.abilities.sinister_strike.name, spec.abilities.sinister_strike.name ),
    type = "range",
    min = -3,
    max = 3,
    step = 0.1,
    get = function () return Hekili.DB.profile.specs[ 260 ].abilities.sinister_strike.clash end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 260 ].abilities.sinister_strike.clash = val
    end,
    width = 1.5,
} )

spec:RegisterPack( "Outlaw", 20250826, [[Hekili:L3ZAZTTn2(BjtNrrQ2wrso2nnJLNjjD72K2TT340B)MPHOGKyTePw(io(oE0V975CWBqqs58At6oZUnjIGahCE)cGxo(Y3C5fZzL8l)1jJMCYONC8OHto(4Nm54lVO82T8lVyll(A2s4VKY2a)3FRQCn7MOIJJYlNf9wwEcB2AAy3UoJnhNUISQ8y4NwvwUT4Pp6rltkxvnByC2MhvKSPAnRmjlnoNTOe)3XpA26SzpQCf)gw(nWqtsF0ZIXH875jz5jL3(ljfLfpAoFbRAD5JYZwwXJYiWyi((xEXSQK1LVm9YzH2kF3OtV8cwv5QS8lV4IKnVaaSK5Z5IHZlG3)OJ2D1BwX3D1FYYH)dbd7U6coRid(ZJ39kC(oA0toAYPpD3vp73)f4H3MgV7k49MXwWEY3TWmMrNaJ5htYlkfd9v7Ev7Z)e17(4JMGVlcJ7U6p2IBfZJgpPXhn6u)hHa2VMT7Qnz5W)4fzvB3D1C4V9pZzXWF88QLQ3(4JMCCdt8Xhn2aovopA8rJqW5zB3U(wyvskk4ZDhzXUR6xUILEn8xE5l5VzBw8GH0RdBLrIfD84HJgEI8hh99aY7WDxb)54rY)m4Ylgk(()EwcGalu)kqEor8IJgRFrKjnNNNTE9URkVHZU2A04w418IT8yGu9l)WUR(TT8uoqHk4LLjPlndLGK)f7VYGhMZFBsrcUUxTipBJCH0dD03)udzyrsAsXkCkJZsNNu2YRDQnW8)YW3dOCaqDZkEk9(fjZ55iyD1Zl)hWVdSrWiak61fRYkvt13D0KN806SBxEXAukcfpFln5WF7xjHFEkkap)YNdsjKyNEeK0rEYwXpQGPQcqBaSjqCrrjlDolhO9Oi4CyVbR8F(NhdcaW(Fwwvk8i26By3cpIvwY3STe(BLz4VMSm1Stf7M)5QSIsKL6IY8KR5dV8cy9lHDnd0QWlJMLLwvmS8MBooAHAbIMSfKe7HOOS1ZZUjD4sXSeviMKCoB(T0ikzR5PL(pxHakb9g3heI1weHEqJKyZd8GiUrHr0p7NtwVMiFxSnNZ14db6yfa7gSbHCfeEIwNaZtwQzlcVmUSVg0QTMxap83Z5XexPySiC)wx0xFyna5GOsyThUWa63D3UREGg1CTagJkqquHz2D1ac91NgPgnpJdcu80iqZDe)wEHfIEw1IfdZLqx0wfWbJydlbfboF3vpwS2fvB55XRy5l5rJDxP2P4UaEyAkmFiz947dz9n5jGevj3JewN(bsDv2eTKf1hdsmsbHZRqnWfzakqiqQet0l2HE8dbfpyO2Nyy7IIivKoxpD7oKCd9U0SN61fT2wsYDi2uVJhPiucKjyDVAB0CE0scmkt2WJkssrRnNnfu1pstW8OQAql6XivLOxp((qVSr)SzKKgIaJzaErWxvieibFfamvvo5(HG0WbLYi1sszQP66Me0UrrsPq8Bd7DwZjjKYsrAl4AdnpTP)sJuf7IHlQwVgmnjz9regGQam1jFSLaedCwgQNOhAtA5QYinT8mAT0BQVD3vprqfkV8ca03ueYqHVat61CW2I0dXKnGe9cWoweRaywNZsJbOINxTXgDG7UsoBnO9y(qgIMBfkbEOjtmCcTSgTOgFdBE0)Uc0zveTbnCbUk(bbrNO2YbM4wu7exLdYUaHklLhLmpB9hgumwdg1N4acto0o4balYFKEBcFTqu4x5WkNVnpPydQfklDj63bP7XOmkfyKHFAbPr5NF5RfstOgPHkyPspNrPMP0ZIe6DgARa1PmvBsWYCeNVnkb2VzKEOagKilnsjkutO77xundwSfvlVhYdiN2idXQH9bGypPne7VWr9qOtyByltP)HqmHCAk(AHfH)QcJsOauxHQyMNXvMlMNuKxH2ca0(eKeLLEeGE1ZIgn)xvPxVHXbH(mG3JVKfjwpBenHJQzTgxFLP6MMLHsyfu4p5KUXBNyqBncxaI702qC)GimpppMrvTGJNWBGOkqR0W9BdIqScLvoE4kwbiDWkhYsVnA(2IU3siRqX6mu7MCEgB2K6Fb2uFxdc7YXm59aEN8rbENi0LlcfPtL5)OmILcl1vGDRiig9SGUidKgqW4DL48QFLTGToaUKjcOfvHooyaQ1tbmeY4hLSa2abvc0t(ZlycC3k2Mn88H5qSMtN0dSepllABgmtfNpnElW29oy2b1CEB0FgMvHy3RZK(S56U3KF8n)KXjVyWcdFDaN4f6abxFJxr)o5JWl(9cYvd6xiTaGgQnKJhdT3LlxNnJbQ)hRvuBq6wUtzJ6cO4r9o(CuE74FRQuOkpBH2gZHKwBikdXRkb2)XTOIi0lkKZQKLOEaY4kdVrGKcgbIi6d54WzzBEwm6GkAG8AIv9pbN(aMmHxBKgpzilwUeBiiXOxwS1OEYcYGffuKDar(H60uaikzSWsG2ofzSffmSj74uOjBPE3fDJyZfWEuGb5gPYPU8aAbpxgGVZEuGPITSY4vUJPej(KM0of5FnxYmiOgBbTljKI2(Pac)TvRt55cnV8u(MeK1iHq9BMXkhm0ajYPjKwcNf8Lk(F)GAfb(Sg9TaCwx4snjSiwbTOz5kw5qBLiXxhsjt2wkRb2XpOYw5BzRR4eNIKYisjyu22Tz5LvPjL3AOmin0wVYqaZMeJQoqNwMS7Qd0td4xAE2BbFWyBMvbUKONJdu8C5zS5OyiXDi4IWKoT8wXSDYicmJew3fZsK2uyi)56ExAd7IvXwViLSWX0)TFnFpnrlgRs0KlEPT0kem(Zb2tAByDl)7yvZzX4dDeFTFljYCGhN2FuyLeoP2ggq3oASklCIq6qeeY5JyiPERJMiyZVqjB4LVnDG8KIrCRIwU5C89)jABH5tudHgLzc9ycGscnteq2ZKBtba48Yoj1XWFiMfx(dFRdDZF0VgVPtK(FpHApWqo6iXo1FHY8kE0modTh2Xqb7Dq4TB4R9Z3qTrodmVccAaoNvuL31OlUgd3gN7yWJ0ciOAB99QxXg3sXLeXMbIZrBHxeu9fhY7vT2AgUa0)icZ1QiJRYjlEEriNeDyw)jWBo0wPOOhArXDxHZZHQKrSGKllxLNvTCLY(PR3YmmP)B42QiRdCyAcIfETzLJvBPFNnGLU9N4TjmVUIZAyn(s7LBVqys3vH347FFW3KWg(2Jh1i0ku7oCgRGh5OrhtbZbk1YatYsEQzzz5G3i8OYS8CqdgTeJTnhlF(2Q1f((TnEI9axJoVxe9xvZxUbNjVXES9yNXwgLTqMRSAg6rXqYyS2uVgyWc0GA(lW)LZc4BHU7C3OM02Z9stE6RyGmql8oidcSFMeYUMEpmhq0mWPBEuEvr4jySxgucAsQx3PvWmeSwMG2L5jXUPgvypYfKgIEV4jmdUddSaGK6Z0Jf9wwLOYQcY5gTVUh8ZV81h8l0AU7QFaxu38qkccjNvsft6zVw45KyfOGJFrgASAodIYgmr0sqc4EM84Lub((JnDDSna6QjeYRf1IdTA(CeecJqe2afPox8ihStBkIRXWy2m18sZJqUNu6G4msu0d72sn28PdoiR)LoSlFS1tbUa6NeUJmsaNUPdXkRAG2SrHK23lOqxOIjG1NlwZrfwIOh)jWEO0pPlm1VjxdCif92SkLnR1zOFyJeVWyfiJfPmHcMiED1CKrixfjo48pFEcWSH5s3KMr7INGW08S0hwQxZaVddyHyLv5m45NiwxXe5fUOtE2NiQebLkgzAef7Duf8kyN76bSovJg8GFEk1eKieFejqhuQBvU5QTCgYRdkEuz63mtf6aVtaRtcxILjwfwPjLZ7pBGpjxXiYteQMSLsLJ2NXXUKOV81AEgyht1t5wkKQ6C17bzkijWkocBTu6ST1bjU3(MpApsTmDCTzzB)X62yOJp6Xs0ZH4FwktaVk8ISuK)Nc0bFhjSqUec6TXjy3Dy14KAUWuxH8q4U5YMQ2Uev3iNmXDkWZnZFoE8(ND)7JbSAynvH4re3p9B7QxiEx(xk5s2i4jASMG12LLwefMSa8cDCcTqcCXZvXqDyWKJjLGEdeqeM0nrer(L)jmQFpWB9CR9rdsdbffcW6QMVa5TW6bnKKnRr4e9x1wHHsmGOwSowZgUdv(fYmgvG9BIXwPVRwAZfVuAVh9C6qQg6mSUlmIQDJmDT83IHSleCKDYGmIB3s2RDlZVK9IutI(Mzv2m7QtJAi5Yy5nprqIGF6TSK1Knap(HGoIiXXIeq2yCx(sCD74ZaReS0WAU3Zvp30MzZw13k1TYQ3Plb9uYvbnumpRcMUO)INTLLp)w7SQ2E5X7QqFsTZn5AKB907iwDVc)duZcrXfOo3zXIJwgppCUTf6yglZ(KiNt)itLW9FIkUbUs8fCLdXiZgL1(ejtSQMdn09hUXa1Vd8AB4lvUq7KYTVeNMArL(1yD8tAPLT7avcIsPZ4o86PaOFPLHsz4f0tey6fv5cxBMXt5lquUiZHe9bW3clhG49)kdJJVcFKUiToUVyviYKIHf0RIoCSr)IEL)RHrnWOgNAIe1tekxB0DJzRbv(rlwxLNFBJXB8CCqahinkb31ek92afU0LbtODmsxuGZ1s3clgwlNtLvqrbGq2MnEplCHirbQFNteaYoMcDNe8x61V55MWoE5IgImirgdch1TxsTF3nmCjQsltuHHb6yXx6uC6nVw2me)HA9eChVay1lLVXVnFEJbOjB7bhxRsZY3GlHuDPRB)QhsflW3Un8BNgk0yxRNmDiLOHJSQIqbLNxbw1BndIwPBZZNSUY0PacO64JIvlOUuwyp8qHQZISnC9iu1GLu(nJRA9nKDvNJuYDSvm0ZmJwzH)CYXSV7frtpfipNQ3oyxOH8uP8yWriw(ThUlqNXkbRK)pUoLgkxaqPmIt9f)(ozbtrVrkdL9iuXl2SyddKxdYbFm8fWQC1wW9V6XY0sJX0uopmUZvV4qbFbptg9SSy04qPwkmu6ERJLZKw9YtkUwO5fC9MWN(yl0xVQuNkaPTD6xiFrs08AuEMWvTvGLqHvyfNf2A7k6NfJfSAU8vXT0xxEUb53RLEnTCdDRP2njanXWtwbmesZRU1Dm9vLWB8AnDPvLiBjb(bZnFTSR)bsTIjeZI183jQaTsaHugjiEg5FCwnnyp4(Jm4kR8Mk8ypML6kRzC6Nk7MS91iuERAj6GA2CLsnp8dweTF7sPTekqVADWDDPrIP7(4a3(3v(nSynfKWahwoPoxD1w2x1Y)iqBMrYboTwVsN8A4reVygYeMTyNQL9WE4ml3UiCcQIY9bvtsCO3etXxMH(lEtcv7z6hPQ4RAOFtvEtkOehi8JsY8A9UMoN5nmmKIhYb)kEogJrf1eI8AS7XakSOw6ecP1zVJymaZSDRVSNC1UZzio79Fv3JqtBq05EaS992GDdYDnR3N(Eqh0VDFpOS2A)ssD8Nf4ruOsIhBRwWVJs0B3hSVaNPNzkb2Yi(MOzqqYswYGPg3pstBCI8)zkpAaj7IvmqdYg(A)Ak9pXs0I5hpgBaQJy6QHDH(nWGU5XRstqT53EO(4lHop(dvPl5zPGEgvUQL)YRZQWtVvrc69zSW5Znj554q8oguuz4qM1H7vHWvKx)qOnkd9LynfdoaMreJvGmKrHijJLt43iLNGeSlexB64OSaTe4WMQroDMokZIOSnCUkSLGWRFiOXET(k2tBRRkk3NKoC8OwtjLbzSnJ(tC9pXP454QfbHXFRFn2D62UzG)H88RPWnDhMt72TijNhQN8g)eNcVNgJ9(mBDum1jfUdTvFC)VVohFVBC8jT6U5xRDo(KM8O5lLwhx16gTKVE7wv1HOCHQTp2dLJTLnw3ok3Dn(hPydGzFwyd2pZ6ZIxX1jGb65wXcivZ52n7TK5Wo60A)SdhcAeDTHcIbdt83fZr5wPuCopMsOmvXku9SLnT9cB2DijwDVSXeRMxYOvNoX97cF082daXG20TQClP(Bl40pqQrGTwBdlSvzADDrl670L445KUcZDKt7tsiBt)N70c7K5msBvb12x6k4zQ13bwMo9tZ((e0x4eu7MU0aU1HJ4uh3ERvfU6Hon2YAzd9K(GqPiS2oQz3aTmZrEtk0siA5U2QPNyWUe1NJVfLzgSTzDfB0Xnr0PanvBicrhEV67xDB6CkqgzmjjblbudhNIaL4rL)s7maEHCUnvmseD4FKwqAkK(UH6SwwXaoMsoFUPLzkW72brfNs5vOJgpc8pLVMd(twk53BPlKRBdeenbydqGuoMiqQO1m)1VR8o1f3DhbT4gDvBuvRYH0eWGThtB6ZBwPJOYVMy2pOb86b1RA3HnPnYeyVzEP0)koeWk2ET9QWvgoSULaAF0C7bE2(iT43N9Hdq99SYt6g2iaw9qxrgI1LYwdL6oHwHa1R6Xw1RYrEuihwyQMQozWLKuLBQbRsf9UHi9GwzQjevyoFrjE0F5vV15q90t9sULj7XkrOGP(sY63yIoKpp8XROnBRTqhEg6xeetbveWJ1iqaiNO(hs1kw5BAmy)DWH1icKHytEAPS2I0oRCUEdADLAt9KIcdnL)VRqBS4BqcsSnIYOHX4iALWL3Fcq4JUZuc)7tCA7y6eIq2Nqwh11HeRn)aMAkuDtD0AxQNMGTgmDv7eQ7bAupetsm0TqGYliKmJpWG25VBl4r6EO)rVNAq5VPVvAZRNUmmu75ELCAqOsqUVyZ9g)5IIiv1yfhPBEct5i0n4bwCpDwyQ2ShiZ9rvC)2oBA9Pf(aBEW)DfORiAEo7gZ03ix)32j37bcUxD9aQRqt(2Q(elf()w2UBRqRTekWc3EdpajRuFTjvNWHPZAUi3DIi)ou5(LnhpteaMp5KgNCD)FqK5UR(beB6L29pikA4JMI7rsHOoJhEsD8UHhqgqqy6RvgAdXuy94GEqemj1dcvcxtscCotZ1tyz96Vw6xSUa(nlCU2QWjktpTwjKGLVCFY2GPKs4Oi2atY4QdEKxC83k60u4rZLfD0YjpT)DThQJxUjQviS7rOqbIGZ70jvl2hZcvkI3dTZIdvEz7n50lV4gwo2iXfxEbD9JLSbxyPBdpuKP7hI1zfy3YreHOlpyvLzByeMjEflDje4XUx9luzHXBOTxKLclf94hkYvH9ngfW19qHddp053HFS)43Hx5CeOSidpwXeXIvLJg(UH6fttNKi83iwK5eSYJi7DPACKYMfcR6MrpFoo45SsgkP(0DVICfW9gT6vsiWfzqzI8(Hlo1dxOY1x9CtQqiTK(sd6rm5FxdtE98iwBYdoe5KhCVhp)EUZpUXDEWgKlW2VPX5GdAAzAOp8cGi2RLzYOpLeYjJ)urjFjreX587DfuqcfEMOYwKGhQ4V5BW7)Wc8C5UbGLptxcO7EfUUxON5xGZmIj2SbneIxxNpDN5Y6eh8paCBpfPhQ72tCxk2yfd1hXRdM(i7trz4raQrIqr6dXsRmT5diz43wL8OAhRSPtaiLo9a)N7Se2akXnS0aG(4dtwm9bbclsD)T0W16I1btOxWiGPRkch0YhLtuy49PBJnEF2M3D3dQVJ(GqMYPRP(UVnSfHV(aVNp0WUHJLM2po3Mh2ZoEFEy)VvvwqiD53bdhs3Ibt73Otp3DxiNJpF6KdQHrPP(GA(kpONWX7ZNEYiAp)3X7vIMX4(f0rIXJB8Qw6OXh13Xz7E(vj5U76huMjqoTg0RrkBV((rGC3DbIQAWGM3B4W9pVLkokp(azogo)4VFWbIN18fHH1GcD5xy94ax4fwpTHl5cRr02fBbom7TUFhnkqbG)yet9h)7FIUxBLPpX1dHqpNBTg6CkeCNoZqZ1eTZztKOsRH5EFpGZEGGZpF64toWj486ZaDJqy)7Exae2pY5(EqQ((dRszglp0oebl6DSmSeq(Qwa(iG8vDHVQJh8I0friTvrSEpWvZw)wk805t6folNN1Ccon(nuNEmOxll2zpMOoFzvWQ6OBRK6zX75MMSEE5DQflabu337bbzB)ASst1rF2LWXc)5w(JEIxxvQIZN(4E9TTwF20jaBwd1xcEsiRWeo8RQQe9(I8c5T40(UO0q(i6J07F8rb8XzqV(nNp9PJhyje)zRSoVFsPQRCZqIG9dR378PTP4RPQ6C2eBSYEJh(alpZ7hsjm2iCai9hFq)AjGpaN132chZbJhmWnaNZMgOIlce4xILnPt08dUh45qUMz7w23oE4jHdh8SPJRJ5V7UgRpI(r(1gPU1NbMqg)yxGJ6ipNASqOpp3P)gKS)FKkyeGsBxMLdv13y643lNv70ZoPF0)n)YJWGgG46cKCjKLObl)96)GgJCY4wAt5FAGubEG5TRmx55BcQVm4nmW0rY1O(DxaaFTDu0qGdIoUNtBpF2KGX9(fYD5GpH09(OaPJHsUA)gXpH2)OUWgX0DHqd4LONBM25esRWmGrSZhBPJ8J0DVGp6tCzpGOT(Du)iasBVYpYWW8V7fOTWEFtk4dF((M67nP0pRq3QcNbmKg83xBxmc(icV6cG4c9nCagjJ(FmuCviqbZ4)JNp9eZaNEQqX)94EpWhOcNSi3QdyTiFUVAd2pWvSMAhb)SEBf4dHc1nwg0dF(jvMomN)YWL5OEEzcomTIVEDDJeC(XJCDzEVpd7FoUXb8XME37aojgTMpGwMxdCNdOlpN9JKMDBilxtFS85bVBbg0RL0X(EHH)c4wcy)e4mm5pO9YH07(ke0VjPGgX1GZDTFu872GFBpUnbkKRYZfVbEbI8FpNo)Mve6lLUh(IRzGgaK3w5HmVJHlk880Ht8wmHDSG9732sg(TARyF1cS((NC9EnEo4bWT58URtzxGt8U2VwpFUhmyGGj)lQdPEnVI1WqR1nR3dcEG17fi5cFiN88W(eRcBTHZI(5pUgy4olIZfUUUo2h(8GrfD8OgJKToaQoA51EI(0K7)e9biVwK6oNzCcz(P(SG7dcU9XuthfBdQS(5qwit2(Pc)8jNeeXFcTN33JXDtWEXH0HyEQCpoUnO1eQx9oRliioDYO9CDNSFRB9EUR51vyZu7zPgoesRuY)uNc7apS5KT9nbdA0nPgFQ(AyfaqD888WeRpjyQyf(i9fbZAUfFiUSZ8Ofs1kJQTva8)E8H0kagWNbMsIcXAh8Y)vQ9SPVUwN9yNkmAxymHf(GNAzJJd1F8G7ROG6COlfPuFatnJKKNRPpS5(6SU7BnifpPR1O(xs09DUpPRPU2xh09DMhlumFXh9VvODbXH)2BsSF2PeYWB4Pyq5nR(7dAiVGdNAysH7NvlWHrbFUTbp991iSp4)5ZmChR8NkdX3)Vrhgq2nXHhuRpJTZ550rwf)(VLFmoUx4L(1VE81HG59rCW87wOLbwjqw)nma0XzfVn9qVEc9StStYS132GZE8e)mNqa1G6unFkKIb5tZ3oJpEyvlqwQq19Rhqt4)EnPw2IgCM8mo8FGp3f3leuD8tq(Ot61pmxY4XnBLsJa(Q7lxX9cfgqiPjoKEpieVxawphgjzgIS7Gd5pf0pv5Z8(8ui1URApF9gu6NKJRLTMZeAA(OD1ufcqAnIUp13bvHaOqbk0CoLQLeCP))o3fv3DNXbv6qFni0cRCOVBcYxoxIubPOb7WSALjiuj0d1iEYYZCAp)JYaW87Mq(XYG2cg7vqu(E1roek3lzKeASEbhR1HmOg9By3IAZfnkJmsA26KLP2byG4FVE2Wc5k89)a7eTVF1XWTFlCloM7ZK1YWCc7SuLFSKnPMQ8APoXUBGwLHzzXP2fIYtqXRtLvp1(OwrQ0dMcHqhWNq4KWhhhT6z7uYmWUusbIYhXtnP1vvDvvfd9pl34C3g5XknaoKGbQa5d3so(iBvESSBWk)XO1jJb4vKH5QYPvU0lMFRCfKbLrDoga4itQOYKE1(TD6tOMTjeXPxJ12vvw7E9flZqNeBnKYOEb4(p6mCGU)XPSUdCeSjVVMrC14(N68t93egsApzdLaqkLFcmlpvKcbjITMSViwLcmCA8vehNo1CsceOI6QTGAmAEUxka8lMb1jpa5rWhIyIZgFY7lNyWWg7lH9V9jdWVMRa9)3exHCRz3GFiA4Xx(RtoDeDZkC5))p]] )
