-- RogueOutlaw.lua
-- January 2025

-- Contributed to JoeMama.
if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints
local PTR = ns.PTR
local FindPlayerAuraByID = ns.FindPlayerAuraByID
local strformat, abs = string.format, math.abs
local IsSpellOverlayed = IsSpellOverlayed

local spec = Hekili:NewSpecialization( 260 )

spec:RegisterResource( Enum.PowerType.ComboPoints )
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
    acrobatic_strikes         = {  90752, 455143, 1 }, -- Auto-attacks increase auto-attack damage and movement speed by 1.0% for 3 sec, stacking up to 10%.
    airborne_irritant         = {  90741, 200733, 1 }, -- Blind has 50% reduced cooldown, 70% reduced duration, and applies to all nearby enemies.
    alacrity                  = {  90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison           = {  90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.6% for 10 sec.
    blackjack                 = {  90686, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    blind                     = {  90684,   2094, 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    cheat_death               = {  90742,  31230, 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows          = {  90697,  31224, 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                = {  90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves           = {  90743, 231719, 1 }, -- Physical damage taken reduced by 5%.
    deadly_precision          = {  90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem          = {  90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand         = {  90638, 470669, 1 }, -- After consuming a supercharged combo point, your next Sinister Strike also strikes the target with an Echoing Reprimand dealing 22,527 Physical damage.
    elusiveness               = {  90742,  79008, 1 }, -- Evasion also reduces damage taken by 20%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                   = {  90764,   5277, 1 }, -- Increases your dodge chance by 100% for 10 sec. Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.
    featherfoot               = {  94563, 423683, 1 }, -- Sprint increases movement speed by an additional 30% and has 4 sec increased duration.
    fleet_footed              = {  90762, 378813, 1 }, -- Movement speed increased by 15%.
    forced_induction          = {  90638, 470668, 1 }, -- Increase the bonus granted when a damaging finishing move consumes a supercharged combo point by 1.
    gouge                     = {  90741,   1776, 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    graceful_guile            = {  94562, 423647, 1 }, -- Feint has 1 additional charge.
    improved_ambush           = {  90692, 381620, 1 }, -- Ambush generates 1 additional combo point.
    improved_sprint           = {  90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison     = {  90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach              = {  90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison           = {  90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 3% Leech.
    lethality                 = {  90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    master_poisoner           = {  90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nimble_fingers            = {  90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison            = {  90763,   5761, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 18% for 10 sec.
    recuperator               = {  90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 3 sec.
    rushed_setup              = {  90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    shadowheart               = { 101714, 455131, 1 }, -- Leech increased by 2% while Stealthed.
    shadowrunner              = {  90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shiv                      = {  90740,   5938, 1 }, -- Attack with your off-hand, dealing 11,833 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards 1 combo point.
    soothing_darkness         = {  90691, 393970, 1 }, -- You are healed for 30% of your maximum health over 6 sec after activating Vanish.
    stillshroud               = {  94561, 423662, 1 }, -- Shroud of Concealment has 50% reduced cooldown.
    subterfuge                = {  90688, 108208, 2 }, -- Abilities requiring Stealth can be used for 3 sec after Stealth breaks. Combat benefits requiring Stealth persist for an additional 3 sec after Stealth breaks.
    supercharger              = {  90639, 470347, 2 }, -- Roll the Bones supercharges 1 combo point. Damaging finishing moves consume a supercharged combo point to function as if they spent 2 additional combo points.
    superior_mixture          = {  94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional 10%.
    thistle_tea               = {  90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 14.4% for 6 sec. When your Energy is reduced below 30, drink a Thistle Tea.
    thrill_seeking            = {  90695, 394931, 1 }, -- Grappling Hook has 1 additional charge.
    tight_spender             = {  90692, 381621, 1 }, -- Energy cost of finishing moves reduced by 6%.
    tricks_of_the_trade       = {  90686,  57934, 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride        = {  90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                     = {  90759,  14983, 2 }, -- Increases your maximum Energy by 50 and Energy regeneration by 5%.
    virulent_poisons          = {  90760, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.
    without_a_trace           = { 101713, 382513, 1 }, -- Vanish has 1 additional charge.

    -- Outlaw
    ace_up_your_sleeve        = {  90670, 381828, 1 }, -- Between the Eyes has a 5% chance per combo point spent to grant 5 combo points.
    adrenaline_rush           = {  90659,  13750, 1 }, -- Increases your Energy regeneration rate by 50%, your maximum Energy by 50, and your attack speed by 20% for 20 sec.
    ambidexterity             = {  90660, 381822, 1 }, -- Main Gauche has an additional 5% chance to strike while Blade Flurry is active.
    audacity                  = {  90641, 381845, 1 }, -- Half-cost uses of Pistol Shot have a 45% chance to make your next Ambush usable without Stealth. Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time.
    blade_rush                = {  90664, 271877, 1 }, -- Charge to your target with your blades out, dealing 33,600 Physical damage to the target and 16,800 to all other nearby enemies. While Blade Flurry is active, damage to non-primary targets is increased by 100%. Generates 25 Energy over 5 sec.
    blinding_powder           = {  90643, 256165, 1 }, -- Reduces the cooldown of Blind by 25% and increases its range by 5 yds.
    combat_potency            = {  90646,  61329, 1 }, -- Increases your Energy regeneration rate by 30%.
    combat_stamina            = {  90648, 381877, 1 }, -- Stamina increased by 5%.
    count_the_odds            = {  90655, 381982, 1 }, -- Ambush, Sinister Strike, and Dispatch have a 15% chance to grant you a Roll the Bones combat enhancement buff you do not already have for 8 sec.
    crackshot                 = {  94565, 423703, 1 }, -- Entering Stealth refreshes the cooldown of Between the Eyes. Between the Eyes has no cooldown and also Dispatches the target for 50% of normal damage when used from Stealth.
    dancing_steel             = {  90669, 272026, 1 }, -- Blade Flurry strikes 3 additional enemies and its duration is increased by 3 sec.
    deft_maneuvers            = {  90672, 381878, 1 }, -- Blade Flurry's initial damage is increased by 100% and generates 1 combo point per target struck.
    devious_stratagem         = {  90679, 394321, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    dirty_tricks              = {  90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    fan_the_hammer            = {  90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain 1 additional stack of Opportunity. Max 6 stacks. Half-cost uses of Pistol Shot consume 1 additional stack of Opportunity to fire 1 additional shot. Additional shots generate 1 fewer combo point and deal 20% reduced damage.
    fatal_flourish            = {  90662,  35551, 1 }, -- Your off-hand attacks have a 50% chance to generate 10 Energy.
    float_like_a_butterfly    = {  90755, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by 0.5 sec per combo point spent.
    ghostly_strike            = {  90644, 196937, 1 }, -- Strikes an enemy, dealing 44,352 Physical damage and causing the target to take 15% increased damage from your abilities for 12 sec. Awards 1 combo point.
    greenskins_wickers        = {  90665, 386823, 1 }, -- Between the Eyes has a 20% chance per Combo Point to increase the damage of your next Pistol Shot by 200%.
    heavy_hitter              = {  90642, 381885, 1 }, -- Attacks that generate combo points deal 10% increased damage.
    hidden_opportunity        = {  90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush at 80% of their value.
    hit_and_run               = {  90673, 196922, 1 }, -- Movement speed increased by 15%.
    improved_adrenaline_rush  = {  90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and full Energy when it ends.
    improved_between_the_eyes = {  90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.
    improved_main_gauche      = {  90668, 382746, 1 }, -- Main Gauche has an additional 5% chance to strike.
    keep_it_rolling           = {  90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by 30 sec.
    killing_spree             = {  94566,  51690, 1 }, -- Finishing move that teleports to an enemy within 10 yds, striking with both weapons for Physical damage. Number of strikes increased per combo point. 100% of damage taken during effect is delayed, instead taken over 8 sec. 1 point : 78,912 over 0.30 sec 2 points: 118,369 over 0.59 sec 3 points: 157,825 over 0.89 sec 4 points: 197,281 over 1.18 sec 5 points: 236,738 over 1.48 sec 6 points: 276,194 over 1.78 sec 7 points: 315,651 over 2.07 sec
    loaded_dice               = {  90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    opportunity               = {  90683, 279876, 1 }, -- Sinister Strike has a 45% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = {  90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional 4% per missing target below its maximum.
    precision_shot            = {  90647, 428377, 1 }, -- Between the Eyes and Pistol Shot have 10 yd increased range, and Pistol Shot reduces the the target's damage done to you by 5%.
    quick_draw                = {  90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate 1 additional combo point, and deal 20% additional damage.
    retractable_hook          = {  90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by 15 sec, and increases its retraction speed.
    riposte                   = {  90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every 1 sec.
    ruthlessness              = {  90680,  14161, 1 }, -- Your finishing moves have a 20% chance per combo point spent to grant a combo point.
    sleight_of_hand           = {  90651, 381839, 1 }, -- Roll the Bones has a 15% increased chance of granting additional matches.
    sting_like_a_bee          = {  90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    summarily_dispatched      = {  90653, 381990, 2 }, -- When your Dispatch consumes 5 or more combo points, Dispatch deals 6% increased damage and costs 5 less Energy for 8 sec. Max 5 stacks. Adding a stack does not refresh the duration.
    swift_slasher             = {  90649, 381988, 1 }, -- Slice and Dice grants additional attack speed equal to 100% of your Haste.
    take_em_by_surprise       = {  90676, 382742, 2 }, -- Haste increased by 10% while Stealthed and for 20 sec after breaking Stealth.
    thiefs_versatility        = {  90753, 381619, 1 }, -- Versatility increased by 3%.
    triple_threat             = {  90678, 381894, 1 }, -- Sinister Strike has a 15% chance to strike with both weapons after it strikes an additional time.
    underhanded_upper_hand    = {  90677, 424044, 1 }, -- Blade Flurry does not lose duration during Adrenaline Rush. Adrenaline Rush does not lose duration while Stealthed.

    -- Fatebound
    chosens_revelry           = {  95138, 454300, 1 }, -- Leech increased by 0.5% for each time your Fatebound Coin has flipped the same face in a row.
    deal_fate                 = {  95107, 454419, 1 }, -- Sinister Strike and Ambush generate 1 additional combo point when they strike an additional time.
    deaths_arrival            = {  95130, 454433, 1 }, -- Grappling Hook may be used a second time within 3 sec with no cooldown, but its total cooldown is increased by 5 sec.
    delivered_doom            = {  95119, 454426, 1 }, -- Damage dealt when your Fatebound Coin flips tails is increased by 30% if there are no other enemies near the target. Each additional nearby enemy reduces this bonus by 6%.
    destiny_defined           = {  95114, 454435, 1 }, -- Sinister Strike has 5% increased chance to strike an additional time and your Fatebound Coins flipped have an additional 5% chance to match the same face as the last flip.
    double_jeopardy           = {  95129, 454430, 1 }, -- Your first Fatebound Coin flip after breaking Stealth flips two coins that are guaranteed to match the same outcome.
    edge_case                 = {  95139, 453457, 1 }, -- Activating Adrenaline Rush flips a Fatebound Coin and causes it to land on its edge, counting as both Heads and Tails.
    fate_intertwined          = {  95120, 454429, 1 }, -- Fate Intertwined duplicates 30% of Dispatch critical strike damage as Cosmic to 2 additional nearby enemies. If there are no additional nearby targets, duplicate 30% to the primary target instead.
    fateful_ending            = {  95127, 454428, 1 }, -- When your Fatebound Coin flips the same face for the seventh time in a row, keep the lucky coin to gain 7% Agility until you leave combat for 10 seconds. If you already have a lucky coin, it instead deals 68,727 Cosmic damage to your target.
    hand_of_fate              = {  95125, 452536, 1, "fatebound" }, -- Flip a Fatebound Coin each time a finishing move consumes 5 or more combo points. Heads increases the damage of your attacks by 10%, lasting 15 sec or until you flip Tails. Tails deals 34,363 Cosmic damage to your target. For each time the same face is flipped in a row, Heads increases damage by an additional 2% and Tails increases its damage by 10%.
    inevitabile_end           = {  95114, 454434, 1 }, -- Cold Blood now benefits the next two abilities but only applies to Dispatch. Fatebound Coins flipped by these abilities are guaranteed to match the same outcome as the last flip.
    inexorable_march          = {  95130, 454432, 1 }, -- You cannot be slowed below 70% of normal movement speed while your Fatebound Coin flips have an active streak of at least 2 flips matching the same face.
    mean_streak               = {  95122, 453428, 1 }, -- Fatebound Coins flipped by Dispatch multiple times in a row are 33% more likely to match the same face as the last flip.
    tempted_fate              = {  95138, 454286, 1 }, -- You have a chance equal to your critical strike chance to absorb 10% of any damage taken, up to a maximum chance of 40%.

    -- Trickster
    cloud_cover               = {  95116, 441429, 1 }, -- Distract now also creates a cloud of smoke for 10 sec. Cooldown increased to 90 sec. Attacks from within the cloud apply Fazed.
    coup_de_grace             = {  95115, 441423, 1 }, -- After 4 strikes with Unseen Blade, your next Dispatch will be performed as a Coup de Grace, functioning as if it had consumed 5 additional combo points. If the primary target is Fazed, gain 5 stacks of Flawless Form.
    devious_distractions      = {  95133, 441263, 1 }, -- Killing Spree applies Fazed to any targets struck.
    disorienting_strikes      = {  95118, 441274, 1 }, -- Killing Spree has 10% reduced cooldown and allows your next 2 strikes of Unseen Blade to ignore its cooldown.
    dont_be_suspicious        = {  95134, 441415, 1 }, -- Blind and Shroud of Concealment have 10% reduced cooldown. Pick Pocket and Sap have 10 yd increased range.
    flawless_form             = {  95111, 441321, 1 }, -- Unseen Blade and Killing Spree increase the damage of your finishing moves by 3% for 12 sec. Multiple applications may overlap.
    flickerstrike             = {  95137, 441359, 1 }, -- Taking damage from an area-of-effect attack while Feint is active or dodging while Evasion is active refreshes your opportunity to strike with Unseen Blade. This effect may only occur once every 5 sec.
    mirrors                   = {  95141, 441250, 1 }, -- Feint reduces damage taken from area-of-effect attacks by an additional 10%
    nimble_flurry             = {  95128, 441367, 1 }, -- Blade Flurry damage is increased by 20% while Flawless Form is active.
    no_scruples               = {  95116, 441398, 1 }, -- Finishing moves have 10% increased chance to critically strike Fazed targets.
    smoke                     = {  95141, 441247, 1 }, -- You take 5% reduced damage from Fazed targets.
    so_tricky                 = {  95134, 441403, 1 }, -- Tricks of the Trade's threat redirect duration is increased to 1 hour.
    surprising_strikes        = {  95121, 441273, 1 }, -- Attacks that generate combo points deal 25% increased critical strike damage to Fazed targets.
    thousand_cuts             = {  95137, 441346, 1 }, -- Slice and Dice grants 10% additional attack speed and gives your auto-attacks a chance to refresh your opportunity to strike with Unseen Blade.
    unseen_blade              = {  95140, 441146, 1, "trickster" }, -- Sinister Strike and Ambush now also strike with an Unseen Blade dealing 61,091 damage. Targets struck are Fazed for 10 sec. Fazed enemies take 5% more damage from you and cannot parry your attacks. This effect may occur once every 20 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    boarding_party       =  853, -- (209752) Between the Eyes increases the movement speed of all friendly players within 15 yards by 30% for 6 sec.
    control_is_king      =  138, -- (354406) Cheap Shot grants Slice and Dice for 15 sec and Kidney Shot restores 10 Energy per combo point spent.
    dagger_in_the_dark   = 5549, -- (198675) Each second while Stealth is active, nearby enemies within 12 yards take an additional 2% damage from you for 10 sec. Stacks up to 6 times.
    death_from_above     = 3619, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack. You leap into the air and Dispatch your target on the way back down, with such force that it has a 40% stronger effect.
    dismantle            =  145, -- (207777) Disarm the enemy, preventing the use of any weapons or shield for 5 sec.
    drink_up_me_hearties =  139, -- (354425) Crimson Vial restores 5% additional maximum health and grants 60% of its healing to allies within 15 yds.
    enduring_brawler     = 5412, -- (354843) Every 3 sec you remain in combat, gain 1% chance for Sinister Strike to hit an additional time. Lose 1 stack each second while out of combat. Max 15 stacks.
    maneuverability      =  129, -- (197000) Sprint has 50% reduced cooldown and 50% reduced duration.
    smoke_bomb           = 3483, -- (212182) Creates a cloud of thick smoke in an 8 yard radius around the Rogue for 5 sec. Enemies are unable to target into or out of the smoke cloud.
    take_your_cut        =  135, -- (198265) Roll the Bones also grants 10% Haste for 10 sec to allies within 15 yds.
    thick_as_thieves     = 1208, -- (221622) Tricks of the Trade now increases the friendly target's damage by 15% for 6 sec.
    turn_the_tables      = 3421, -- (198020) After coming out of a stun, you deal 10% increased damage for 12 sec.
    veil_of_midnight     = 5516, -- (198952) Cloak of Shadows now also removes harmful physical effects.
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
    -- Talent: Attacking an enemy every $t1 sec.
    -- https://wowhead.com/beta/spell=51690
    killing_spree = {
        id = 424562,
        duration = function () return 0.4 * effective_combo_points end,
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

    local now = GetTime()

    -- SPELL_CAST_SUCCESS
    if subtype == "SPELL_CAST_SUCCESS" then

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
        end

        if spellID == 51690 and state.talent.disorienting_strikes.enabled then -- Killing Spree grants 2 stacks of Disorienting Strikes (hidden aura)
            disorientStacks = 2
        end

        if spellID == 193315 or spellID == 8676 then -- Sinister Strike (193315) or Ambush (8676) consumes 1 Disorienting Strike stack.
            disorientStacks = disorientStacks - 1

        end
    end

    -- SPELL_DAMAGE
    if subtype == "SPELL_DAMAGE" then
        if spellID == 441144 then  -- Unseen Blade damage event.
            if disorientStacks < 0 then
                lastUnseenBlade = now
            end
        end
    end

    -- SPELL_AURA_APPLIED / SPELL_AURA_REFRESH
    if spellID == 315508 then
        if subtype == "SPELL_AURA_APPLIED" then
            lastRoll = now
            rollDuration = 30
        elseif subtype == "SPELL_AURA_REFRESH" then
            local pandemicExtension = min( 9, 60 - ( now - lastRoll ) )
            rollDuration = 30 + pandemicExtension
            lastRoll = now
        end

        if Hekili.ActiveDebug then
            Hekili:Debug( "Updated lastRoll to %.2f, rollDuration to %.2f", lastRoll, rollDuration )
        end
    end
end)

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

--[[ Coup De Grace double cast bug, currently a 5% dps gain according to sims
spec:RegisterStateExpr( "coup_de_bug", function ()
    return talent.coup_de_grace.enabled and ( IsSpellOverlayed( 2098 ) or buff.escalating_blade.at_max_stacks ) and ( haste * 1.2 ) < 1
end )--]]

-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    -- if ability ~= "coup_de_grace" then coup_de_bug = false end

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

    local now = query_time

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

end )

spec:RegisterGear( {
    -- The War Within
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
        known    = 2098,

        spend = function() return 35 * ( talent.tight_spender.enabled and 0.94 or 1 ) - ( 5 * buff.summarily_dispatched.stack ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        buff = "coup_de_grace",
        talent = "coup_de_grace",

        handler = function ()

            spec.abilities.dispatch.handler()

            if debuff.fazed.up then addStack( "flawless_form", nil, 5 ) end
            removeBuff( "coup_de_grace" )
            removeBuff( "escalating_blade" )

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
        cast = 0,
        cooldown = function() return 90 * ( talent.disorienting_strikes.enabled and 0.9 or 1 ) end,
        gcd = "totem",
        school = "physical",

        spend = function() return 45 * ( talent.tight_spender.enabled and 0.94 or 1 ) end,
        spendType = "energy",

        talent = "killing_spree",
        startsCombat = true,

        toggle = "cooldowns",
        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            setCooldown( "global_cooldown", 0.4 * effective_combo_points )
            applyBuff( "killing_spree" )
            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )

            if talent.disorienting_strikes.enabled then
                applyBuff( "disorienting_strikes" )
                unseen_blades_available = unseen_blades_available + 2
            end

            if talent.flawless_form.enabled then addStack( "flawless_form" ) end
        end
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

spec:RegisterPack( "Outlaw", 20250425, [[Hekili:T3tAZTTT2(BXZDgfPABfrz7Ct6y7zss3sAAtEXPV(ntrjczXAksD5ID8B8OF7VZ5aasaqas6LKUm3p0MerqGdo7Ba8CVZ)05NfguWo)xNoz6rtoC6rJNmXB6Kdp)SIB2Wo)SnblUm4c4VKeSg()VVSio4A8NVjonieF980YSfWJwvuSj)BF6tViQyv58Xlsx)08O1LXbfrPjlYcwwG)7fpDEC68NwSIDDq21WqJsE6lxGd5dzrPzrf38UO8I8NMLErjZpLwUX47D(zZlJIlEtY5ZTbYtMcGCqzXQ0SZp7SO1VgaOOWqgF4SC49XHV)Kd3F6rF72z4q2o732GZ023kFK3uNpAYZmF0S93o7xt3oBDAg8pEDA5MTZcH)2pMfSa(JxvEH8Tpy)Ph4yIpyFVAWPu7rE7pbbNxUzt8nWQeLNZc1hz(2zdlwfKCj8xEZByFAt6IrJPxh2kt4lQN34jJps8JtEX(tE(EBNb)P3eXFAD55dfF)pKgLNMKl)1NdOp(loXR6fZkM7NXYsJJ3oR4AwWLkJg3cFKLVHTOy7S39DBN9(nSew22z5SIIOKlQhkbj)sWFKcpmJDvuEeUUZwMLUwSqvdDYl(2AYWYOKO8v4uUinjmQOLx7zQaZ)Ba(EaLdaQRxXsO3ppkKLHG1Sxv89WVdCOWiak6L5RslKt1)E)PphMQpTcw(Fpaw5FN4Kp)SyK5fLk4af83(vsgJLempMfE(RaMuIBheHstJbSMu8b5rZI2WF2pi2s5WeLM5NW(CborW)BkoBYP4YO4yaw9Z3KXyQlcmWduh4cG50pK5FbYAAmWdDaFZzaPKL4dIQ(SBy5gG4VLJ848XauDet893GCKGmlIeH)Ysa)xWcIruybkOeeLua)Ny4ZlxUeyLqYnhn)rq8nMLdZXhYyli6)2zi4CftmoCw2KLUafYG1n)YiKu)7rlUeWvBNfbRycqLeV0yGcLbplVazoq1hHWGweGZACEkYcMeki0Pe5pnom96KXacd0eb8bbNF2qoGootaC(BKW2yuG)2Bfp3eDnoJH7xybpE7Sd5dChyheeZskgVMfK4NxKbYkJf4(TZgTD2aqIMghnNxuTj9VMVhRwZ6PYYGQNrKaFKoNqCOpOcon0Gn4zQJkmkFtqXIv6JPau2ZPNTXxRUcACmcEbvK7vbWFatWyU4IFLaCfR(DuW57tYljTXvsSCYBuUGZaquB2GOM5SfbL5c2040R3odvlDXnJBiYDW9ta5NIUyfYTYTQzxwzjYuxbRato7ZlyBkeWAyeWQvGk)bzkH80QaGdDnloCCVWJehLGrzHCDQ5p0z3YRNCjBMGEZchtgKfCuMQm6bGyH3sYAAJedQrbImcSgy1PBN9dbsK4pfSEnltJARjLJ6ZlxZqBoBsZkkticbQakxQxIR5zDWNXFdNfGi8QmW1guhg83dqneEWs8bnvvQQFekBurdTIXfpCzaN1zfTjgNbMX3o70t2oBknkIIKwd3JjWJpINjPCCnpsWLOAdWT965P(BsbTTO6NtOnqLIkhkvgvPeWkHva0CFQ8vHl5WRiEbRNxMVIRViKTmOmUWM(cnYkyuwsrqL4BsZZJGbcBYeqp9vLXGSza9dGu66iu2jkHVtdkgnUEXLkOSO)qBbFtcSXYkrznvv)CtmbXKcbWTZ1KRar4G5RqUKda87QySQP4fxAtzr6gaMyf1dukHG)T4sgzGPtKlN8Psxhdy2OfrfvSm7wnnrRbtKxXc95eI65yxRmmCRoCLF8z7Ojey6ZD5Npl6QMnva09UuNNexLfB8bXoW3fYi8(et6(exDTsNa0JYw1GH4ffmiiU6NU0Fj4yO(yKcDq4eKvCqZ7AtlV9GmOi2fuggSaFOMBaQVLa7oYMNtsNwfETeaeY99KETsQJimgkkGOmHYN9NY57ptx9vL(VXCprfQhHPhMaWjdg(()eTTm0fkvxY9hIducOzkhYEPyBYbaDfPQk)QzySzl3LI(faf2N)p8rFN5EqlMOfH52uk1Qv2k1i48ShIGqwOLeJuXQS0Ylwj9tupEHa0TH1mvz6Mah4Xw0cYVafvJASRABafLr)77JjtLLRximrqhWB887d(MygW3(fobwHpsZdYz(AAG8oI0ViEEg7cMIj)GmWCmZVinldeWWvWBIQ7MINVPmo3m6epp1bgdu7IC))Om8I14mzmwTGJMhCbQkOGIaOHJSOx8KXJkttvadgVnQPkh)xAlGPffoAd03YYwcEQ5hKVauMfKS4g)Cww566jTLX0IhMs(NAOfEhK)a2ptBl2TGqarhaXgY8ZqBX2NGMM3RnDOpb28F5sgBJFuHpg2pyL02qWuebtwy0cM2J56pnwc08RHW9ReAN4A5(zybbzxGH7J8LC33rZ)2zFxeMWfypcCqGC(lRMzmMsuH2C2skjnFKNIcu54RstqViksvCtuF(aR)SWiWssm50ismc5EHNkDafJsawyWQd4ucevkIlg3M(oCaKxFZXLxLc0coXf13uXOtQ)9JoF3GipUC1vusv8lZdUGbIFl9bvQbTfUi)fmZ)rm7Z1jOHMmrWssdwXGfpY3S0ermCebznqkca9mQwc475CW24l)W7GFVKSHjMp4TYz1tlAstMfienehTgqDH2CUVei6zOdhaAeMswMp(pSjgKxohE1LLxOlfSthrMzf)lCXhCcPYUHPdAMjiOn)zut5qv6pSKkJGWBQHPUsfILNZ9TUAeM7k1CLCGiwetLT1eG6Tw)Pb2rX9iCvb)PfT03taQlYEpOAdQJzxZl0wcB8ylpIC)M)4bTWpzdx4odapQ4I(XeRgtDbBzzSpyH10KKsEoWrnpfap)4YfxEdStJsueSmgd(u)IGO4C1qWpsHB2ySRaPfZXoY6WBU89rmCKncIPbN)Sji70hAIyefbxc7W1(ZbxIkZaF5ZBOOKqC2gx5glydd7qpIMFaQkyGjluAXamQWd5IYq3pZZhpeFgMqEm7rffS1yogq3mwb016zLMoEzhQYqPEMiOupznN4kbEbg1Oq3C4I0EMllg6Z1ySHbxXsEcMKrYakz8CzuwEb3jgy(xszn)NFZh3o7gkSiBSuAvGWKO1jNClguQSiCkL9CUKz1eA67P6O9oAcnESOu4SN7NaX6hetpCIPXrNEXA1guRCnNvcIulwfKDHA5gW8eHyzroDPuoRZNaCva7dsK4rHRsQmMt0RlM9uo2hAsE9S53AQTTU)m8g3ypqjCDj8xrVLv3c)8zkPFhvZLNMQxILAYQgKRsupysBH7yfCvHHG5K8j5SFWgHGgHhY551ipAnqKkZckQeWe6RScO8fCmOwdReHaJweHXqCmpwysBFkk3oafSGWw9vDY55CTuygoAr5udh512GVwan5OoOFPQ2AnJ(bXaOoHkQqLUdkvui)jLVZx)HkQ7Bebiat3hnzZ6WV0DAXTktPVUJdPvXW2XpVzjkUr8OQBN9WQlVia109YpQJCcIfkM4iiDuZ4oJwtGd69EBGTu1pTn5YlwLMxeFdw5WOlnR9LzQW(r(GXSfIJg2n51Bvi0S9Vyr4ykTR)WN(PAfwGS3sMOwR1QSW3dXguQjnXgg7cZC7QM)vRf9aaI2eVb1brjMfc6m6h5G5YYSIvCfKjSLiOkQ()cUTmm8WFjfZyuj8Ra2i5sdlAdR)5cVXrG7B0RIjqAD1ls7d5OM6AuJQTRr6hKpbDvPLmdmpoiK5VmUml7gJTATS9RWbb0lAuC1ytPe)d6Fk0PjaUht1a)jnkSK6QPf9fYtaKU2sVGHjtdGLN)5aG3jOa0NgtU)IRj3XI9KMan9ur6m0nPLWgBUsFcWbpAi85HtCFn4cDHyiVpmuF3BX4p3rCvhd2odRLMTSZ2)Tkzx5(SBrHPGeGiEOOSmo2aCi)qhU0uPXWvcF)cVdoqa7C9OeTd9Suqwq9crjcBQOqOvVz3vPIR0)6tzyLMFfliZ0aSbw5G2Wkkm7MfiTTSyiFCbae(ZfWax01mT4Dx1RMLOvZPMxqAl2ToQZoCeU5lObLTp0lYWIJTMfB6AvJroVmlcSBHDNc2nfDm68lrTC4CdkdZZPeB28vA4Cghtj9pEbkmNJbRCnLeVBQ4RO6YeSQk3RFS4vpjxlNRbjxGXAD9QOfRKXrHM9QlI88BQ8eaINrRyvCghW)WRy(Y5SUafweOmZGRdn1MzA(BrpprFoUUsKRAt6Ifh4INuxdK7kSWve)PF)3Ns9ANIBpnZcUmQqE1YebaEDacGYUwzcwEso4c(tTuez41OpfW8cw4IjKm6xd12wnvOShTMj4lH6racEumvRDDA9Cg5XvqgMIeqZNxUIjaDtCScCNxMpU46RN6F4Mfg6dWTJFCkQ)s0fed0tDQnQpzgu4bF9uHUZO1rxtf(M65Y50hnId3JCY5RuCetRXxc3uZyxeKfYvSIYiYazg3iaYQq4ikmfUjNARZbWXzk0(dfR5E4Fwii(oMBvQlSpUrkdteAoX17otuhQz3wOGxu8F3ujpV(hVFl8osphQYNF9(2isfpxEU3j3aPtOIHGhv6zXmmYror9Na(Zw5tqpHbg5SmYoQN0koOrkvLPHZoPwQlrZfi7GxsXuBJFxvc)4o6SaL2TuUaTn38Trb6DlLHSxD2t)4hE6NELzqO9GnXu8NSwPwsszrlALSoWXloWfdz)YpA)NtLeG2WrMD60xMDS7oJKD1mKln2YpXJ1jxAKwMMkkQW5mP6EqBdzATQGBuIl5UbUc4FrLd1rLI9RoMCfKuQ8wJ7t1015a07sOwt4cIjN23QX75keT1bH()NsS75851zK9WaPJK7zltmchUcaZA6UqtYjGH488GSB2RzMQRObr)FSkVHK5iRkyKx)HTIMSMDfddVQz2KWuoHP66lsnrjEvh5vPjc21lOAcyQiplIm35COvjz0ZmyWMO5urYqYIYVu2aXCeQj6cvyxMO1Uxi61AwGPEb28uKG(xf4woItav6zjy107VN2yqhyKvDJ0VkZrF75vUQUwaAkapTpWqO0lOwcSdLgyBPIRwBKjpZaBFGuJf0gFzm7Z8qdKsazLXsBO1A2WzT(0LWZ6Ler3StQ6at3NI((fv(PFOETcNHea3ndMlgQ(xXrDFZC0EN706MEuBKeh7R6gtbtUSRi9QBhEdUUFe7YnmqHfyFSVpNJI8xRUb6bF5ylwLeHW0n7vverm0WVRecynnbaUfcPEXV8rWhqgvlICkIy0w76OSmCigfJedXcpAE53HJbGAf5efWOwg3KwsygxXDYZEOLuUZpuq8KuYTwqHTaqdLxgztgRDeHQDaOEJO2MHOTg)IuFkZZvvd0k86ULr4UpHhkL4Y8I62vXDfAoysl9RIAvN3Ks)jU(AN5kA18xwIPZTgMWHDO2WaJcSSlPCZPpmTZTZYOmMTJTZuTZTd4idlVac62Fb1lQ6dTvdBVJjtM66GlsO)b39pXbJGx7U)OeJ9aDMhdYlmf1zkoRk58UPhmwnnHscW(KvU6STZLd)JYKlxhGqzk4Tde4QpF9AsTmlASA25Cnlv2CaOO7QWDunMZjyHiUwTb9D8J4GE3etQdazvYgdSTwBP8rw3GA1yWB8QGCSfDkgdEN5hUjVBNkb1zNLhNwaXykMhLUhU6xWDLPIDJbn9EaWtFua4P8IJYBhzlLhT78Uw35b615WWJMq2Yc0JBw5vAhBoyewkFYr1om1OOD0rxWsmAc7xonlBMxuQg7KBIYo5hyVkWY7kaY9e(ZRvTwJYcH6CpQUSq7jtiAap5r0lI8NXPxJ(1m0J73VyUKW)imjo8Ckr1jnNAxeEkN0sHkHf71j3tCYGAVSLVKgKqeQLulyl(J(e0TshZ1wPwZrtOWSBVwRwoxPYOJvdZ6mXKuxdwzWYFxuomkaM5raqpfZS6p9E1a2QRel2ajfRQtUTO4lFFLp3vCb8JXMik8kNJjRNAyr(4AQwkubYeB(8wdbByx()31rARJEt8U2nRTcmyQBBRwZUp5HCXX6JdZUo4o3T5juCpxhfX6ZZC98sXHZ7LePOqDJBCvqum5HNfMFJARBjOHkwFlpRpIoMhUPbw7d17zvU543Fq2CKCvuEu9DUK74Sf0kXKxvsfl0dv9LUux2Ei2AemKy5WNBD1GsjJ267H6dMzn7n4PmmzslwQua1WGOMFuv(ujCOwQCFxm3t5y7CNOB7CXuFLSurpJufesbL9xdVWcSpVbCKThCVvyihQomAxxhhu2UuR045gzoAuBnhqxyZEJ)0rrKGoMhFQt1aJ1Ah8yHT6QWQkx3dKzFeKh225lDiTW7QYr)FkblG(Hzbxxp9opGPFtNYc7sRWOQoLUPpwI3wMQ7e4)my7D1deUjuv5psKpulKSIQBgKMeom(0qEW48iw3t2flQC8b8ZWVj5KgNyD)FqKj4uaInnYWYdIIA)46PFm9iQJ34JAI3R5bevp1o9vPOh2ykuESv7pwSGiONUcqPtJiwTlJi9ovWr2kisIB3RrRXcxN72wHWef3sEFmC0AZhyCpU0m3lnZFCrvhmYv000L0R5(TMcyISRJ4f(LNb0gfDZmJlo7mHwVCBGxEoPcghfHSRtRqtWJC(HDfD)(eapkKVpu9nQYTOEf1GX17rJc4FhIQOrOnvLa2zyeQPKHFsfGO6WHkUoRaW5SRdYW6Idret3WqrRXfwS3EIAImFcwuvqOJoRA5POcQGYI01beAAXkS1yGOkE77OuGJxftVonbwq6XpHe706jCq27jCVsFI2V)emkXpJ3TueaTmfVGe4nbwzgA(hKgyYSMx14ECCa)OyJ4)c54ivUl5E5vp6WqCWHbfbO(QVD7BPGQ1Gd43ERfuYIW87gM4qdmHmbgoA9tjoPRweTgn1(Y4O3rBSmUhN2Yq3fv23oMPJXYoXYq0N9x4Cx05SBDiIzF7BFdreX5856mliHcpKPPlJWK68V(xG35FzVD52(wCr(TnIGTP7vmUYF8geJUf2YW(zX7zycRWulI57z6bZxEed3kCOpFC1bJD3tEQ6bj3(ia5fFm5G7Hjs5e3vL2(Bl0gVxJdJ7jtHTdEb093XtpTdCPEUZSTN3lA5jcf2UA9(b2Bci5pR0ogdSMXo6Czzf(0BVhxG3DCs7Et71NnDlRkXN8aV7DQG9AwsAAFCUHDuND8o2r9Fl9GIl(yESv3JYf8jdDAe)2BT5S7PNmD3gyuAQ3THVVJgWDK(0toAcTN)N4v7IBmUzvgfyCvS6PNOEuq23B)HA(qoWSYV3EBf9kO(Q852BLrbPE99mAGts7GHMHuC7TwctA0i1nNz5J5BsW3cI0(4FrZ09Al1WZVhy4s765FTZPGtJ0Mb3vjUZzJNknLHPFZUGZULqop9eVJ2vlKZMZaD3VO(7gx1lQps7MDrOe7VlfoPwtpbnnKP0dgSsIYz5SgyTuwd0kFfOEAWqvPYJpz6(nuMD7T74OmvJSka07600ClZ1NQy7YIeCJCcGWW)Ck7stKIrKIv(l4OEmd2rxt6Wwk7XPthyplPh7obPa7GtIZObTSyhFirQ(Rv5sAIUvskOcJOEA2gyK3Qwm4yX6YGDSYd)3O6C0eRPQasZwIUERbdDNR3t8QzT0Q2XGDCwFJrkyUoZH3JvrkUF8m89OfboGHyODPWtpPnXqx1O44PJ04N6jE4bwSH7hsXo2WU73d92DyJ0jBX37VPfESD9gns39(JpXs9d4iW)kweGorZ7ChWZ2Cjt1DSVXB8r2dg64t8AI5R8gVz2(REKzM(BQluL59VS5R)ERaSoAWh5mY3eI0QjaXAyeIW)cXC)zMYDlmZQLhypzc5pX7E5QyNUsjcr4R29LrnabbpAjpoinYHR2dgUJZWZQnB6kvp16ZEmV3l6X2X1UPRutzeuI14m(YEnwyU50VHnW9MgmQMnJ6Ss00a0PE0E5HFjvycF87cdeUg2rrlaWR9Yni8I38sQGa8EFLtycFM6hncev4xKTRFIJb6OInH7ZnsWd9gKWCZyKNyC)uD(8gZVSbWyRR(TtEw1g4bDRkyCVqCxaRtp5WbMWOuY6bdxFfUThUB71dSTxh0WJf(Vy9qsYFK5PJeXw)PEffyIg0tseTUghBDz6Un28cHRtp4fJ2DOl0qZbz7ELq5XwUljuEQJ7pcLr02DgbomdDq3PltbtuNrPzuzGozIIcN(Dy8)7ZnLq34HMNHAfXPQdpnedWGHTEJjCme9q9lQCg8p(qTyu7hg(F(x3b3lkZWkmmOI72BhAhH7PKCfdvNJSsCpAqvsxQ3DJ0nx8FVvc266wjOBs5oTslvfZinJ6xjavUyQsDgyzGd05o6ipLT8UIa11SEUJl7gvpZW(5izY6)6D9bysi6BRv0mG5BVfpTsd0oPsaIzA7RqZJWFFN5JQtc1x1JVFtxmOkfwhPT9dVBT(c5zX1Edg0ScfwhwvYmh01r0)0dMONUUEFMV)ACc8BOiq)C4Rvm2gmgyQqDFg8R6Af1hjYlSJ69CYHJg0szEVxyXh4jN3ebzVaZQn3Of8Kz7cm4XIvT7AI3BWU6WLBJoVtRaCTTBLgIyNg7cU61)sDk0BKMIkyO1ooyWowpr6dSKcZhYrl3EskKjVYXHn)0dBag6Zc)GFxL(l1txUvn9hmri0A5GG2aaLND8gpP64IB(KQtiEJ81PDOWjK5x6d7D72kDDwRRrLnpOXCj32p23No9iRiEUf2(EoTDb757rNs5te7rV2G26CV1S)AD4FXKEUUt7362SZBDVU8seuzFSco4sRN0DY65deZwJQjklpxRwfkI1)Z8ZiRfeGjnJsKRB3RfkmC9TL94dRnpO8fLDeyNHEpRFQhRFLMpEKvAM875QLhk)yEkyIK0PQbkuGQnnTArGMMhHVIR2ab3mYwk7WJ9NRvBaKnUb32kB48JGkR9zB92BRTzrD5(iBlSKS1nPy6Fz)ERALcBTxeA4UOTc2yRLneot)SbMzvfShPx6kpHKQvjoRKGEvytUM5)7xJKgFnsQXOQUERff7o2cBsXHt7FusCwQazuOhQgSM9pdjN6D0KgfM40jUZmhx35x9pFi3BKixTJXbhJ2epQFJq6b81(NoezkdEK(uGCxGhNFHqo2ZUtQpVtPDjlXx5p9D231vr5(GYCuJWDDgG(qNFEYAVrvhEVf4R8(YXNZohbZvfT3O7cIR98c000FpYxXdErBsCCNw5gT31DVHJh4(dA4xY9KBMNAVfu)aMj96YXxXnHRcU)8XD6jhj4CC)zJdgZOgdsFz6IT(XK77oH02Xowt8Rw(eUjlHGJpUBu7v((KZp790P1K(WMSaV37MqhF6Z))p]] )
