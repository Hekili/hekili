-- RogueOutlaw.lua
-- July 2024

-- Contributed to JoeMama.
if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints
local PTR = ns.PTR
local FindPlayerAuraByID = ns.FindPlayerAuraByID
local strformat = string.format

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
        max_stack = 1,
    },
    alacrity = {
        id = 193538,
        duration = 15,
        max_stack = 5,
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
        max_stack = 1,
    },
    -- Talent: Attacks striking nearby enemies.
    -- https://wowhead.com/beta/spell=13877
    blade_flurry = {
        id = 13877,
        duration = function () return talent.dancing_steel.enabled and 13 or 10 end,
        max_stack = 1,
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
        id = 381989,
    },
    -- Talent: Attacking an enemy every $t1 sec.
    -- https://wowhead.com/beta/spell=51690
    killing_spree = {
        id = 424562,
        duration = function () return 0.4 * combo_points.current end,
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
        max_stack = 1,
    },
    sharpened_sabers = {
        id = 252285,
        duration = 15,
        max_stack = 2,
    },
    soothing_darkness = {
        id = 393971,
        duration = 6,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.$?s245751[    Allows you to run over water.][]
    -- https://wowhead.com/beta/spell=2983
    sprint = {
        id = 2983,
        duration = 8,
        max_stack = 1,
    },
    subterfuge = {
        id = 115192,
        duration = function() return 3 * talent.subterfuge.rank end,
        max_stack = 1,
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
        max_stack = 5,
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
        duration = 30,
    },
    buried_treasure = {
        id = 199600,
        duration = 30,
    },
    grand_melee = {
        id = 193358,
        duration = 30,
    },
    ruthless_precision = {
        id = 193357,
        duration = 30,
    },
    skull_and_crossbones = {
        id = 199603,
        duration = 30,
    },
    true_bearing = {
        id = 193359,
        duration = 30,
    },


    -- Fake buffs for forecasting.
    rtb_buff_1 = {
        duration = 30,
    },
    rtb_buff_2 = {
        duration = 30,
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
        duration = 30,
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
        max_stack = 1,
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
        max_stack = 1,
    },
} )


local lastShot = 0
local numShots = 0

local rtbApplicators = {
    roll_the_bones = true,
    ambush = true,
    dispatch = true,
    keep_it_rolling = true,
}

local lastRoll = 0
local rollDuration = 30

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= state.GUID then return end

    if state.talent.fan_the_hammer.enabled and subtype == "SPELL_CAST_SUCCESS" and spellID == 185763 then
        -- Opportunity: Fan the Hammer can queue 1-2 extra Pistol Shots (and consume additional stacks of Opportunity).
        local now = GetTime()

        if now - lastShot > 0.5 then
            -- This is a fresh cast.
            local oppoStacks = ( select( 3, FindPlayerAuraByID( 195627 ) ) or 1 ) - 1
            lastShot = now
            numShots = min( state.talent.fan_the_hammer.rank, oppoStacks, 2 )

            Hekili:ForceUpdate( "FAN_THE_HAMMER", true )
        else
            -- This is *probably* one of the Fan the Hammer casts.
            numShots = max( 0, numShots - 1 )
        end
    end

    if spellID == 315508 then
        local now = GetTime()

        if subtype == "SPELL_AURA_APPLIED" then
            lastRoll = now
            rollDuration = 30
        elseif subtype == "SPELL_AURA_REFRESH" then
            -- Calculate remaining pandemic extension duration
            local pandemicExtension = min( 9, 60 - ( now - lastRoll ) )
            rollDuration = 30 + pandemicExtension
            lastRoll = now
        end

        -- Debug logging (optional, for development)
        if Hekili.ActiveDebug then
            Hekili:Debug( "Updated lastRoll to %.2f, rollDuration to %.2f", lastRoll, rollDuration )
        end
    end
end )



spec:RegisterStateExpr( "rtb_buffs", function ()
    return buff.roll_the_bones.count
end )

spec:RegisterStateExpr( "rtb_primary_remains", function ()
    local baseTime = max( lastRoll or 0, action.roll_the_bones.lastCast or 0 )
    return max( 0, baseTime + rollDuration - query_time )
end )

local abs = math.abs

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


-- Tier 31
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207239, 217208, 217210, 217206, 217207, 217209 )
-- 422908: Rogue Outlaw 10.2 Class Set 4pc
-- TODO: Roll the Bones additionally refreshes a random Roll the Bones combat enhancement buff you currently possess.


-- Tier 30
spec:RegisterGear( "tier30", 202500, 202498, 202497, 202496, 202495 )
spec:RegisterAuras( {
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
} )

-- Tier Set
spec:RegisterGear( "tier29", 200372, 200374, 200369, 200371, 200373 )
spec:RegisterAuras( {
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
} )

-- Legendary from Legion, shows up in APL still.
spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
spec:RegisterAura( "master_assassins_initiative", {
    id = 235027,
    duration = 3600
} )

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


local restless_blades_list = {
    "adrenaline_rush",
    "between_the_eyes",
    "blade_flurry",
    "blade_rush",
    "ghostly_strike",
    "grappling_hook",
    "keep_it_rolling",
    "killing_spree",
    -- "marked_for_death",
    "roll_the_bones",
    "sprint",
    "vanish"
}

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

    -- Debugging for Roll the Bones
    if Hekili.ActiveDebug and buff.roll_the_bones.up then
        Hekili:Debug( "\nRoll the Bones Debugging:" )
        Hekili:Debug( " - lastRoll: %.2f", lastRoll )
        Hekili:Debug( " - rollDuration: %.2f", rollDuration )
        Hekili:Debug( " - rtb_primary_remains: %.2f", rtb_primary_remains )

        Hekili:Debug( " - Buff Status (vs. %.2f):", rollDuration )
        for i = 1, 6 do
            local bone = rtb_buff_list[ i ]
            if buff[ bone ].up then
                local bone_duration = buff[ bone ].duration
                Hekili:Debug( "   * %-20s %5.2f : %5.2f %s",
                    bone,
                    buff[ bone ].remains,
                    bone_duration,
                    bone_duration < rollDuration and "shorter" or bone_duration > rollDuration and "longer" or "normal"
                )
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

   -- if Hekili.ActiveDebug and buff.roll_the_bones.up then
   --     Hekili:Debug( "\nRoll the Bones Buffs (vs. %.2f):", rollDuration )
   --     for i = 1, 6 do
   --         local bone = rtb_buff_list[ i ]

   --         if buff[ bone ].up then
   --             local bone_duration = buff[ bone ].duration
   --             Hekili:Debug( " - %-20s %5.2f : %5.2f %s", bone, buff[ bone ].remains, bone_duration, bone_duration < rollDuration and "shorter" or bone_duration > rollDuration and "longer" or "normal" )
   --         end
   --     end
   -- end
end )


spec:RegisterCycle( function ()
    if this_action == "marked_for_death" then
        if cycle_enemies == 1 or active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
        if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
        if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
    end
end )


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

        cp_gain = function ()
            return talent.improved_adrenaline_rush.enabled and combo_points.max or 0
        end,

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
        end,
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

        usable = function()
            return combo_points.current > 0, "requires combo points"
        end,

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
        end,
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

        -- 20231108: Deprecated; we use Blade Flurry more now.
        -- readyTime = function() return buff.blade_flurry.remains - gcd.execute end,

        cp_gain = function() return talent.deft_maneuvers.enabled and true_active_enemies or 0 end,
        handler = function ()
            applyBuff( "blade_flurry" )
            if talent.deft_maneuvers.enabled then gain( action.blade_flurry.cp_gain, "combo_points" ) end
            if talent.underhanded_upper_hand.enabled and buff.adrenaline_rush.up then buff.blade_flurry.expires = buff.blade_flurry.expires + buff.adrenaline_rush.remains end
        end,
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
        end,
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
        end,
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
        end,
    },

    -- Finishing move that dispatches the enemy, dealing damage per combo point:     1 point  : ${$m1*1} damage     2 points: ${$m1*2} damage     3 points: ${$m1*3} damage     4 points: ${$m1*4} damage     5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[     6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[     7 points: ${$m1*7} damage][]
    dispatch = {
        id = function() return buff.coup_de_grace.up and 441776 or 2098 end,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function() return 35 * ( talent.tight_spender.enabled and 0.94 or 1 ) - ( 5 * buff.summarily_dispatched.stack ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        handler = function ()
            removeBuff( "brutal_opportunist" )

            if talent.alacrity.rank > 1 and effective_combo_points > 9 then addStack( "alacrity" ) end

            if talent.summarily_dispatched.enabled and combo_points.current > 5 then
                addStack( "summarily_dispatched", ( buff.summarily_dispatched.up and buff.summarily_dispatched.remains or nil ), 1 )
            end

            if buff.coup_de_grace.up then
                if debuff.fazed.up then addStack( "flawless_form", nil, 5 ) end
                removeBuff( "coup_de_grace" )
            end

            if buff.slice_and_dice.up then
                buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
            else applyBuff( "slice_and_dice", combo_points.current * 3 ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "vicious_followup" ) end

            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )
        end,

        copy = { 2098, "coup_de_grace", 441776 }
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
        end,
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
        end,
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
    end,
    },

    -- Talent: Teleport to an enemy within 10 yards, attacking with both weapons for a total of $<dmg> Physical damage over $d.    While Blade Flurry is active, also hits up to $s5 nearby enemies for $s2% damage.
    killing_spree = {
        id = 51690,
        cast = 0,
        cooldown = 90,
        gcd = "totem",
        school = "physical",

        talent = "killing_spree",
        startsCombat = true,

        toggle = "cooldowns",
        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            setCooldown( "global_cooldown", 0.4 * combo_points.current )
            applyBuff( "killing_spree" )
            spend( combo_points.current, "combo_points" )
            removeStack( "supercharged_combo_points" )

            if talent.flawless_form.enabled then addStack( "flawless_form" ) end
        end,
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
        end,
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
        --[[nobuff = function()
            if settings.never_roll_in_window and buff.roll_the_bones.up then
                return "subterfuge"
            end
        end, --]]

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

        end,
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
        end,
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
        end,
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

            if talent.echoing_reprimand.enabled then removeBuff( "echoing_reprimand" ) end

        end,

        copy = 1752,

        bind = function() return buff.audacity.down and "ambush" or nil end,
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
        end,
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
    end,
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

spec:RegisterPack( "Outlaw", 20250102, [[Hekili:T3Z6YTTTs)S4PZOyvBRijBNM2X2Z0K2(1KEj9RQ90)jkisilwlrQYl2XZ4rp7NDbiaXvsAB5C5Co)iX2KGla2DXENlNoA6FmDsePGo9xhpC8PdhnC8GrF9WJhpDsXTBOtNSHeEf5s4xsiRH))DLfRi3Gx(2vPKi8PZtlZcHBTSOyt(388NFzCXYY5dctx)8841LRifXPjHzKff4Fh(8PtMxgVQ4njtN7AQhD8XtNqklwMMnDYK41VgGCCueLpCAE40j4WpA4OJgo(B2o7B3Sz1TBNToopNgTDg(eBNvUbbC(2z7xSKKCf8lV5n0)ytAy)bBF723ca4KJgn8OXhday0ObdhCQ8Yd)6Jg(Yd3od(5OHv)80VrhWAdgHXVLgNNMKxF9xE04t5p8WrYhoRyEqgnlD1QTZkUHsUsB84M53P5BOHfBN9ZF32zVBdnHMTDwoTOio5s1bZwr)c5VtHBNrVoopgN9zlYsxxnzkdE4xdd(p5l8zlItIZxIGnmnjkUOXh8fQlP)fbFYTZEnS0UzjnHbH84iAgU4M9QIVhUoq7HrKbmn5ltlQb2xD04xca7pwclH)IaZ(FbJmoz6KvX5f5iBeFHb)2VY4jPjK5ROrtFfWmeIRsGTHcinAsqXsAa9wAoNDilEd)2)zoa7xXhdGFXz67Vf5bks3o7kkDt1fHNa2nZlxSajNhI)k83PS9t6QO0BGFlgU3BwVjl9AA0Z))YaiMFvCsomyscWKrUong(bC3SS4i22VEqtNGZaGvitNShmNKv0KIbHcCYGQD22z9a2t(czG5wBqgDnjgPmNTD2jBND3DsafxTScSEgjGvg9LYLvWnXHxrZugwF2syVQLGJrwUzAbC48HroQzcMHN3JG9sPpkuAzbYib)cG3NuqjRq2iKULrxKrrUo2OD9SQKt84aJqgjyfzd83bPjRO5WG)TmAi7Wc)jujvDIoLvbPGncabijocVZ0XAEcKPmiUiaLiamr6eW6HTMsscYlYabgkepK0CmsAe0JqG5ny(Q00ivYfmQt0hv5MGiAWLW(KAmWtvhyuC(gsr4s9XuaI(HTE665Kc5zvXJqqrXbByYcnaTjtexBcWltZwasxci5H0Kiss4Tb50SY11aTHXiWaoyoZ5mrkRw4zqjEaB6yjsXXdsIYGRcKdAqwzUpayZ3ipwAaan2igpI5a4sC61oxr9qqvVWuffhsf32403RQoYXpf8tmPF45KFNd0TZGT1Msur03kxo4bf8O2C6I0mkFSIdEPjcjPOq)Y1W1(z2Iy7SVdwfaWxVMgfdQyqLXahpG)J4NNtfNxtOVhwbBajO01XHWzBa(s2ohKc8(StsZXzxfNZplQDBgA0p5(fDLCVJjSoxrJ4hKIOliLRkCPYtJwcAGfIer9sBsZZJHbcsLsa6X1LRaReiSla2lSogjuXmTz4S23(mHJJJAZ3Bsamqw5glTIi5NSAv6nGnja9MXhfJdMpd51cDbHdYP9kqBIRJQPBGLevzGxta8oCx83wvc)yFjdp3cWG0nBsZkktIlUvxyjUxtrjpjfaNaDrCiYSFX5BNnE7SdS1DswpxJeEGq(DgWuJQIyI15kirJWU8wo0oDiBzgWfFXHsG0qkxYvAFxQU25Zs4MG1K3ha2DHgBCeyIk7)b0rfjKgnGGNn71K5fiErbdch7csxeSaoI60sHfGD9mvBWH)1Mgj0bYGIwsszejeVPMUr1NQc723LjCcluZ5S7eGqE0iHjQaEPIAJhequ2HC1(hnMZ1lTEWWu0bCtoRefbGhaaOsLIp)pY2wOb3YvyTrlKv5PIfv1QzmFL9TvBt(cq7HJXhei4xtv5x4arNFXu4x78laBbk4JKDjfy2NVcKchSyvzw2TmRmgZifzK4Oa61irJefLparnxa3COQXkkpATHkWOUmmAaGOnioC0h4qxr8guyt1k4qeLI7xXcLV7dxsbJiJ4cnIaJLqZ7a3gky(EKNIAqE93bdeioLRIqToWVFBsivA72RW132z)aBbQIhvx4b4Z0Ke(q4Ksa)pcqNn4UCubPqqCm8SFvtId)X4lxI6lJtZy0wPWyeohIlw8O4ccxzzwA5LvcQts1DYIGkvxRsBTxBGzEXHfOcbfnrAN61w)kI0FPXEO(XfeMbw8FQtxNWxvoPbpXx)qq3SZu4tpAO3vlxC7G5KCAGMK8rNYKtxD)m6L0ef94zHeqVBrAgOdUGnf6MMYVpyYtUPvVJgRoWva1Uip4VlJUCncjJXQzX9CYLOivehEvULDYv0MaGhdg1IaGYtAY92Rz(xBW89o0Tg8jRfiDDLF4zLRysVwfVgWDOxPBaoW8sMCiGHefkjEMvGuqM660KkVSyIbxdkfiao7wHeEM)uvsmbqxcMQLHAoqWdagp6UK7bm(F5LZbI2Ism8qw2nP8SbShna)dxwZwdgT72MVZoT5cvSW1ej56n1sB6Evtk16lG2E12b5Yjps0T1RP2Cs0X952xjhH5Us1lYJR89Z0eoxbDO70a3O4gKCyW16W(Uh4cQnYEhOAkr1qZuKEoSejVaMegI16wmBW43Uxd8tUWfMwb(eHl6gtCnsdn(Br5QaWUstpl3VgNHJAEkS8cwvgE1TWonor5GLXyW7cwJeVkxGlzgkRWnBm2LWPfZX235WTN(UCmSVlcIPzwFSji71fAs1ikixb7W1bZbJDkZadrYTeuYqCUgx5gxydtBL6GTcwOFo04iDfFmxsG7UMYuZxRe0LEVomPtDfCRgcj5gyXfKrfzKqtt63NaifQAWP5HSgnwnb)R8RIbIoZs0qcluLOEsM3UCBoaZFsbtqPVNzWudbFQLiJAAqPROAY0E)AfvX03hsrpYzl1OyqZrbgPLuwSRXOMwJ47cMTDz)kceQjQsfz1MKMLEzjTsNKFXEDGeld4ydHeAdyljqIXfRbsfC75hicC4pswVMMPrRfwcfssuIHLUtBjkg3ZDbH5UjtufAP1RerhqKhagZXR)nHpO8NPota1(a2XWmlfjW5DwY2gdYijxjdMrd6WWr8cnP06HZONECsaLENZcTGuYRZuaurA9lYOvbEkwHZuDYLmGUE1G1WwbMZoqbQrUmJf5YyHHT80bGhTX8cYS8TmHNcGBtlR4ce(0xt6gZ)d(ad3Wb4QQ4CgXJZznmn0I0I9O71G5uMMK2Emh77oNqnfJsBA)yn1hQbvU5m)KdYUsmpaoHDrU)(lkZ4(5phKCUaDGRkbJH8KFIcS(Lu0)QY1yyyItUcDlUgDUV8QdkgnigmxG9KO3wRLphdbig1yFJQF9zgqn7k5DQ2JELHReJbJD6Va2Idg8KyeHcE0shZI2ilYiAUWRg0gRdZUJeZz1rIPHew0WcLhXMVJUOatwCcT8A4i9HI8WzV2RJ0lgMRtR3jvY3WRE8rNiVm)8H8eMwy5anw)tjzfNFGDMKSgmQdGWLGeXehcqaN9lcwlwMMw40SMmm0O2y4JT47RJn85wpH7yaZu2zd6tRel6trLrsCCj(Yrsz4sHij3YswiUAyKlvjxPjOA)LKRPkoZRQyYzYozAR(Jmur9ROemH9SW2HgDCdbxcaLjgiw)DzoQRSkbqmYgOJJIxmQmJWX3CHR03VbScjNR2KW4zkOR3ujbiDo)ecbSxHjj4sW0nXJYfg8Ao7aBsEhgJsvEcSujy7Fo6(ebvwE9G1GReQhvgjJ4TdQ4bn7AU42fagkyohbXUr150(EucUlO2hxtORuFDlZaLk8xbQoIGeGXpyA9GTZEZcZy)CSMUS7n7W9HjOwbW9HMFShtzQS2PbsQXi0OQcBLymm97mBLBZPAINQNpEQ(UI4SGtYmNN6jcSoHSZ5jKf5yyIf4ceWiolyM4w1GpWQ0C17b)4wEYx5SgCTe6zZLvxmCD1gtXibP3e(iN66uK1OAiUPTb4ZeWFe0gepMEygn7oHF(P387B1n0NN8g(g5gN7trf9ix9JLOPywkpbTtdCOTQPS07ypXUUcdoZ8RMIJEJB0F8Dg7ZfmdzzonwlOvqPPz6sCQ3HSTUngHlhIrIQhBuALZNszt0yUO9wLiHllDbs3l)hUx4untAToWUxRNz3Z9X2wsAHHT16PWTMOEjGub32XI5j(kADwkuGPgD(p4w3MVLLs96CLXOdycZkz18iOAMrELoVYOR8ZRlJVKrKQd3awrKyinkOApvxQjhn)DmYfntkzks57H8JxUSqrokszgxJhAUMEg5ZVJ1KOG)Pe9rnGN5c6JBjDQyp7aWYK94CDKehgCzwmyXAAw4YMxfsJ8nJxPW8YMxzgtfUU86kaLahodks5coO3MMe9ixBDc95CEXfQxRJJzcKGJhzuZ409tXvcRWkNbzGj5(5ILC8cxxY7uqNeN01tSkUInTWtBP9BzXRjz36AAnY3wj3JiIWz3YLLlpup3AgzqBaR4yrrUcyWT0N5RMiLF3SmEfT64pzvv8UvcB1HIkZveAdLDCDjjiu5zh(eCLVbxjSmAwqv2rCnPjuuEdABhBDbMZTbZUpg0lcl6iybBCnjEfIa3kTCKV(5c(Lr01krXTWO2LiN1Hq43CshzNgaAoblBDGdL5DTssIoPEuEc1tdr60oX9bvfGWOgRaHjSchZGZJLw3y0IfgNxQDIILoMR4eH0hG)un1U)jp1U)i8NhQf1ueYtQXupcQ3(QX3QnYKE0W8uBt71iTSVp0DDU4r8Up7m5rvXxKhRIDcVCjzMoc061y0oeflMwfnl1Wg6SkhkIxJvUqalyZxi4XCkEY0AXAaYfJJjizf40w7YVb)Rg2qgNvZB0Mu2pXacYSaQghbZwWIsmUt1RjCyALEXCAgOA)kMFX6dtRWlwaos6Q6LhRvYfGLcG7NzKvbHSAHrFO(umwfLWr2imF69uI(iOactdCXasYTbrBYBxXiGMMKVkfJaOCMXLNp1HvdA8dy5nENS8gp1SIvAk08oluL3SOsVuLQVReQXz64pSwhgQIWvgVIZTccjQLYPdfsfv)ftB3MvKBRMu0PuQqB1Yu0yz1j(gk3U4KNHr0IlmSmdXszO0rWzc0Hk8xjlyQ)yqSm30qtHtGQ2XygXYwtuDdbqqTA8KX(scqtFpvh9OthQ7xuqsAgt0eCZH2sobHVHlXiBMPk7SHG)7K6)VuWX2fuoZ0J5SuvYENoktQsCPiYM8nqvqKfKFwSSCAJc)H4waoc2t50WQaulm9W6KulvutpfSR3HIy3HnLZaNOMjkO4ADZC)5K(uZSMs)itT3EsR)QRF1CdGYFxMUVmPkqjyut5yW5g7NmwUAbKqSMzXYgvWzV9Kh4rBoGlTGvf73kJcETrlJoLr0xuST(Ljims3)BXrdTnR(bJMIxFRC1k8VHKn8fIytYrH5oxqvLjbl1tWXBoYMJqotSO8fw5wxumH7wNVO6E91GjaV0vOiVh(pDplgeE5F2usF55hU5YL4BzdQYS3gkD7hymMuQySMed6Vse4XtTU4WpWZQ8a7kw4qFLMasw3KLgQcxLJwcuISwwCki0D1fqT9nsIcCCVUGcnR0)EoRhVMKK2g2TZiom4bexXpq8QfOuHhCDi4nWewWJTnpbh3pSOpCW(oULsPByDpL6p05lrH6j5XEQaNDocvh9Wy2WxdwMmrZkHzeEjfhK0dH4Jcr6)f(zF28EG67(Y)ughEvqug5MAW79n(5lvFsNvIZbICh13(LpIBHD1tlmSlb(NH1v3)cCY0aBhuSc5BLTnDd90mIR2I77PmwrQm7eEvLzsnzJRAE))rK52zFxg2gaCzVXdJG6US)1l3FgXz0GtTr71Sav10K)K53apHYTDkc0HqSwsmCtfK4paoWoND6ghfd3YZ3k66YeuJlZdKjSCfujBNEn7n3hSkcxsmRTve9Re5T2voAulJ(TcOvb)w6Vf5VtAhq1MrK3dnV2zwgGv8bouStqCYOHGNYtUHKHEeaRuwtdiETYR1WZCfpNNH(raK1me1WFbJiLfPRjmCfy5vcyJ2GTV9NzEtGDLHxNMatm72pRXit9mUg4MhKaDadE)rVVFBZuDqRmGUD0S6ieLXjZaGwXpRJWZMIBay)SeMZW4pyyBpZ0dg3C8hSvUNzAxVY3Hu1t(GHB8mtpyCJh490JB0R2FdO7(vbWeYN(bdR7zMEWyDpWBhI19mdpDyDhVZfgGVH3EJ65y7BDOKJ719Z2fQ1EWKmpWZBtOXa(T2SA648zxz6gtK)(CJ5mSRvq4bEgXO1aQEQEOocBLgcJbCD0QyAHjRQjuC)4YE6vT4zgmAGd(420BVdDu08dMdWNYesDhxWepqSBgdDeQATPbtjzUAHdDeU7eANtomzdq5(XJ5zD67vDWlRG73iIoIv2jNI9aBLIzZaUoAVpMW8fFGWooPOvEFD)ON7AZB31gN4bJ(0DUa8D9(HbBtx8UIM)Xy2S00vLGBpV8pYzRLxsOUonEE7HSMg)JRlN41FdxmWyUF9xmH8lFcLt91pHNaQ4P8Ci7bFO1haFcCgY3u9yIJZx9HB17zQE4yEpa8rGogBDSrkeWSixCC(3Xq0HULcd5z)wHUZH0bnKb7kz8AP1280TR873rP5Q1rGf9YU0qmHQhD6p6vRjCzrDxRAfguUrayTRxdjgvzrk2U64fbzzgMmWBOybPYRB(yrgu4bQwupLS(blFCSeUSaBgfQJokchCePGGPR4BaEaS9SPTo8WxWc((oHJyhkv2JxM65XXa6UtYthHSi)jgW0mNlDeA7qmHh(5DaMWB4aFQGCD(TmGQDIV6ievZMPbmDLOttO6n0CpAmGhnr7e(ITV9nSdWiGFPUGc8ik2EptxeJ1zb)w5dKU7EW5pxTH4U9TUgbiicSmJU(qSoLp3)7fJ7Nwu2)w9y0ZhV9TFX2zFU0fyDV7mCDW1U8W4fNxrn95XrpN1)hw1s9eQK0npwCzfVWDV(0Ff98T84L4zQvVQ9HUNh9O2Zih9xWAQ7IxKGhqlLvU0RzbzqDN04yvbo26yv)BrbPXpTy2iUoK1GmpFFVhVV7ox1mWfNp(al8jd0hyvcb97XRhHlo)0HST8)b2Xs9JWnldWkeUks9IZvFZhpA0r7R9smioBjDV4U7KKlLyIE3DcfaQr0SFpVu2E7Bwyg3DNJInPFFgr7JBNm1p(1QVMwHG93XxpBCp7o96fJhwT7D1xrU4YWi1LG5BYdFPGVEriQAN38tBFQfk149MuU8o93NOwbbNrvdc(RL1wHg7CL6W0B2Oi0Du9sxC(OtpqR6LSHaRDKQEDJUpQ6T0A2OmX4cf8OGhx0QUwOS1AIy)nU8ypPIIghN4SQeQ6twFIu7R27lLQRtzZPBLzpdVrAqOJdjm92Rb8sN3Y7MQw9bU)DTR23DHREX5(lAvhcGRKaD24(peKYJRYt3Lid3wrS)Od23YhlhMq8L7727gS4spyu)(6wPC25o8XIJ)(eSIqBflV39an7sOQQa1VC0GtDBs3zNpYgXlnQW2dy5TmdbH9XzoQ)JATB6ajRwMPhkQSZZh9GKSB)qg1VPq5ZRLV87slH)y3s(Qx7GbmoCNc5aD6BeYVTNxBeU7U9AXJR(swiV(KPFQECfRLrlnbXKp6oPNjwG3V(Wn)(TKxnyx0CgX6ZpQA2j9yR7U2x8mxEQwPYm2t1CxW7SEETL9mMTSsvjFs2P7AB3wX2ON(VE(5f7TVb(54EUebQJfDjn0amN2V(y8)R10z0MYmjIgHmcPJYx42lo)KE7l)RbknuSZgbU7Arj40gNDKi(TmAfrWjI(DHw9F3nwU7hf74EM0fMnSEjnk31U7YDXO(nWayr)75N(3Zf9Nt7)mRxWzsomIDQk1yGSdXD25(ur(K1P3AFD6jOXowP9KBPZQIh)N99TToJE85TCdyOkdI0oASxdNn2Z1HdZfOEhxdxGAMHP9L2cPqFi74AMR1UMliMvSAredKQKMN3t7f8gWOJBEgS76zDfYN2gG1BAz2GTYKo72BYD3D)MkxTES7105z7HYyECnImlfqQf(qJrKS3EgH78lWtL)VwpMig8pWwpMjbPXOpJvUJd(iZ0xiUG7IXsC3AunNr0D)f7StCN2oquxdbVg9x8tL2d29gdlF3nDGQ3FVgXT1UKRKlP9Sq4kgk)WAAxUDFtembpTXRloX6mSou4Tulz6Hv7BxofjDSiJooA6Cwlqrx5Y6oYgXL5DK9ElR4NO1UT8jko)qw7K6CrZUQEF5sIR)Q6ZJASHDCEh3T51Uy(8pV8aD9dY87wZm9X)7mEnwHlvGrH133QrCTwM1(UXrIn(j2HYYCSYry)Ax1VYUm3Flrq83NdFyW7iU1dQ1P9Qcp)AaTVNBFlQVHYR3vFhlX6pssoVPYh(Bh3x853rW0pXu(xLanT5PLmRcG5X)zxY1kWFaVDKh0D83xjxRhxmh(TVZMTHFMr77S0D3vRbH9nwQVRjwq1ANq8P8hijNKyNPNZYYlhjrtgYyh5R8fwb6bmVspY8Iy04ucMtIqNsQI(PkTKNuf78gmFZNX9DZmngPyY)1zVVyxY(qPULxbkYI5bw81HEKHOz16dGzzvLDCsiveZu(dMUEnU3wKLwH)lmkWCz3GRUQxCLL2)dRXyADEaTR)CoOvn)qZ93E71sZX0BmrffX0jyw4BUDyEXOthwhGPb82G5fdv9sO(nCG7NWNATXsNi3dWYgtGED6uG0RHET1ulVyeVmg)a2KkBFp5MLHRH04DarpqnFKAeLTVJAU9ucmQwCFDODtEpMwVnHYZCm1EBQKTpHoCJ6L(EQAJDAjyyoBYKv1X8NjFESDIdKb)qrA59nCs2o35les7797xCTarBZw6dMM(qfvlD5XZ37Apr0qk8Y2ulnSMtrgnJ4QXsTxnOp650M04p1iwvzKh7xpZ6YYYTRN)V35pHBj)Co12NR2DDeE645B8CLX5()4sFX5NwX24)JknwkdwdsFAAJNEhY6DVWz75gPvDvhDsirsWC(LFU1nXJte80jSki8DjtN8UYIvy7GmFdnC6Vo(fdzD1VP)7)]] )
