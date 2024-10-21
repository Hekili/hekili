-- RogueOutlaw.lua
-- July 2024

-- Contributed to JoeMama.
if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

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
    echoing_reprimand         = {  90639, 385616, 1 }, -- Deal 59,682 Physical damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness               = {  90742,  79008, 1 }, -- Evasion also reduces damage taken by 20%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                   = {  90764,   5277, 1 }, -- Increases your dodge chance by 100% for 10 sec. Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.
    featherfoot               = {  94563, 423683, 1 }, -- Sprint increases movement speed by an additional 30% and has 4 sec increased duration.
    fleet_footed              = {  90762, 378813, 1 }, -- Movement speed increased by 15%.
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
    recuperator               = {  90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity        = {  90638, 381622, 1 }, -- Echoing Reprimand Animacharges 2 additional combo points.
    reverberation             = {  90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 100%.
    rushed_setup              = {  90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    shadowheart               = { 101714, 455131, 1 }, -- Leech increased by 2% while Stealthed.
    shadowrunner              = {  90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep                = {  90695,  36554, 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec.
    shiv                      = {  90740,   5938, 1 }, -- Attack with your off-hand, dealing 8,526 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards 1 combo point.
    soothing_darkness         = {  90691, 393970, 1 }, -- You are healed for 15% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    stillshroud               = {  94561, 423662, 1 }, -- Shroud of Concealment has 50% reduced cooldown.
    subterfuge                = {  90688, 108208, 2 }, -- Abilities and combat benefits requiring Stealth remain active for 3 sec after Stealth breaks.
    superior_mixture          = {  94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional 10%.
    thistle_tea               = {  90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 14.4% for 6 sec.
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
    blade_rush                = {  90664, 271877, 1 }, -- Charge to your target with your blades out, dealing 27,545 Physical damage to the target and 13,773 to all other nearby enemies. While Blade Flurry is active, damage to non-primary targets is increased by 100%. Generates 25 Energy over 5 sec.
    blinding_powder           = {  90643, 256165, 1 }, -- Reduces the cooldown of Blind by 25% and increases its range by 5 yds.
    combat_potency            = {  90646,  61329, 1 }, -- Increases your Energy regeneration rate by 25%.
    combat_stamina            = {  90648, 381877, 1 }, -- Stamina increased by 5%.
    count_the_odds            = {  90655, 381982, 1 }, -- Ambush, Sinister Strike, and Dispatch have a 10% chance to grant you a Roll the Bones combat enhancement buff you do not already have for 8 sec.
    crackshot                 = {  94565, 423703, 1 }, -- Between the Eyes has no cooldown and also Dispatches the target for 50% of normal damage when used from Stealth.
    dancing_steel             = {  90669, 272026, 1 }, -- Blade Flurry strikes 3 additional enemies and its duration is increased by 3 sec.
    deft_maneuvers            = {  90672, 381878, 1 }, -- Blade Flurry's initial damage is increased by 100% and generates 1 combo point per target struck.
    devious_stratagem         = {  90679, 394321, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    dirty_tricks              = {  90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    fan_the_hammer            = {  90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain 1 additional stack of Opportunity. Max 6 stacks. Half-cost uses of Pistol Shot consume 1 additional stack of Opportunity to fire 1 additional shot. Additional shots generate 1 fewer combo point and deal 20% reduced damage.
    fatal_flourish            = {  90662,  35551, 1 }, -- Your off-hand attacks have a 50% chance to generate 10 Energy.
    float_like_a_butterfly    = {  90755, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by 0.5 sec per combo point spent.
    ghostly_strike            = {  90644, 196937, 1 }, -- Strikes an enemy, dealing 36,727 Physical damage and causing the target to take 15% increased damage from your abilities for 12 sec. Awards 1 combo point.
    greenskins_wickers        = {  90665, 386823, 1 }, -- Between the Eyes has a 20% chance per Combo Point to increase the damage of your next Pistol Shot by 200%.
    heavy_hitter              = {  90642, 381885, 1 }, -- Attacks that generate combo points deal 10% increased damage.
    hidden_opportunity        = {  90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush at 80% of their value.
    hit_and_run               = {  90673, 196922, 1 }, -- Movement speed increased by 15%.
    improved_adrenaline_rush  = {  90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and full Energy when it ends.
    improved_between_the_eyes = {  90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.
    improved_main_gauche      = {  90668, 382746, 1 }, -- Main Gauche has an additional 5% chance to strike.
    keep_it_rolling           = {  90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by 30 sec.
    killing_spree             = {  94566,  51690, 1 }, -- Finishing move that teleports to an enemy within 10 yds, striking with both weapons for Physical damage. Number of strikes increased per combo point. 100% of damage taken during effect is delayed, instead taken over 8 sec. 1 point : 56,317 over 0.33 sec 2 points: 84,476 over 0.66 sec 3 points: 112,635 over 0.99 sec 4 points: 140,794 over 1.32 sec 5 points: 168,953 over 1.66 sec 6 points: 197,112 over 1.99 sec 7 points: 225,271 over 2.32 sec
    loaded_dice               = {  90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    opportunity               = {  90683, 279876, 1 }, -- Sinister Strike has a 45% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = {  90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional 2% per missing target below its maximum.
    precision_shot            = {  90647, 428377, 1 }, -- Between the Eyes and Pistol Shot have 10 yd increased range, and Pistol Shot reduces the the target's damage done to you by 5%.
    quick_draw                = {  90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate 1 additional combo point, and deal 20% additional damage.
    retractable_hook          = {  90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by 15 sec, and increases its retraction speed.
    riposte                   = {  90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every 1 sec.
    ruthlessness              = {  90680,  14161, 1 }, -- Your finishing moves have a 20% chance per combo point spent to grant a combo point.
    sleight_of_hand           = {  90651, 381839, 1 }, -- Roll the Bones has a 10% increased chance of granting additional matches.
    sting_like_a_bee          = {  90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    summarily_dispatched      = {  90653, 381990, 2 }, -- When your Dispatch consumes 5 or more combo points, Dispatch deals 6% increased damage and costs 5 less Energy for 8 sec. Max 5 stacks. Adding a stack does not refresh the duration.
    swift_slasher             = {  90649, 381988, 1 }, -- Slice and Dice grants additional attack speed equal to 100% of your Haste.
    take_em_by_surprise       = {  90676, 382742, 2 }, -- Haste increased by 10% while Stealthed and for 10 sec after breaking Stealth.
    thiefs_versatility        = {  90753, 381619, 1 }, -- Versatility increased by 3%.
    triple_threat             = {  90678, 381894, 1 }, -- Sinister Strike has a 15% chance to strike with both weapons after it strikes an additional time.
    underhanded_upper_hand    = {  90677, 424044, 1 }, -- Blade Flurry does not lose duration during Adrenaline Rush. Adrenaline Rush does not lose duration while Stealthed.

    -- Fatebound
    chosens_revelry           = {  95138, 454300, 1 }, -- Leech increased by 0.5% for each time your Fatebound Coin has flipped the same face in a row.
    deal_fate                 = {  95107, 454419, 1 }, -- Sinister Strike and Ambush generates 1 additional combo point when it strikes an additional time.
    deaths_arrival            = {  95130, 454433, 1 }, -- Grappling Hook may be used a second time within 3 sec, with no cooldown.
    delivered_doom            = {  95119, 454426, 1 }, -- Damage dealt when your Fatebound Coin flips tails is increased by 21% if there are no other enemies near the target.
    destiny_defined           = {  95114, 454435, 1 }, -- Sinister Strike has 5% increased chance to strike an additional time and your Fatebound Coins flipped have an additional 5% chance to match the same face as the last flip.
    double_jeopardy           = {  95129, 454430, 1 }, -- Your first Fatebound Coin flip after breaking Stealth flips two coins that are guaranteed to match the same face.
    edge_case                 = {  95139, 453457, 1 }, -- Activating Adrenaline Rush causes your next Fatebound Coin flip to land on its edge, counting as both Heads and Tails.
    fate_intertwined          = {  95120, 454429, 1 }, -- Fate Intertwined duplicates 20% of Dispatch critical strike damage as Cosmic to 2 additional nearby enemies. If there are no additional nearby targets, duplicate 20% to the primary target instead.
    fateful_ending            = {  95127, 454428, 1 }, -- When your Fatebound Coin flips the same face for the seventh time in a row, keep the lucky coin to gain 7% Agility until you leave combat for 10 seconds. If you already have a lucky coin, it instead deals 39,023 Cosmic damage to your target.
    hand_of_fate              = {  95125, 452536, 1, "fatebound" }, -- Flip a Fatebound Coin each time a finishing move consumes 5 or more combo points. Heads increases the damage of your attacks by 3%, lasting 15 sec or until you flip Tails. Tails deals 22,954 Cosmic damage to your target. For each time the same face is flipped in a row, Heads increases damage by an additional 1% and Tails increases its damage by 10%.
    inevitability             = {  95114, 454434, 1 }, -- Cold Blood now benefits the next two abilities but only applies to Dispatch. Fatebound Coins flipped by these abilities are guaranteed to match the same face as the last flip.
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
    nimble_flurry             = {  95128, 441367, 1 }, -- Blade Flurry damage is increased by 15% while Flawless Form is active.
    no_scruples               = {  95116, 441398, 1 }, -- Finishing moves have 10% increased chance to critically strike Fazed targets.
    smoke                     = {  95141, 441247, 1 }, -- You take 5% reduced damage from Fazed targets.
    so_tricky                 = {  95134, 441403, 1 }, -- Tricks of the Trade's threat redirect duration is increased to 1 hour.
    surprising_strikes        = {  95121, 441273, 1 }, -- Attacks that generate combo points deal 25% increased critical strike damage to Fazed targets.
    thousand_cuts             = {  95137, 441346, 1 }, -- Slice and Dice grants 10% additional attack speed and gives your auto-attacks a chance to refresh your opportunity to strike with Unseen Blade.
    unseen_blade              = {  95140, 441146, 1, "trickster" }, -- Sinister Strike and Ambush now also strike with an Unseen Blade dealing 34,432 damage. Targets struck are Fazed for 10 sec. Fazed enemies take 5% more damage from you and cannot parry your attacks. This effect may occur once every 20 sec.
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
    echoing_reprimand_2 = {
        id = 323558,
        duration = 45,
        max_stack = 6,
    },
    echoing_reprimand_3 = {
        id = 323559,
        duration = 45,
        max_stack = 6,
    },
    echoing_reprimand_4 = {
        id = 323560,
        duration = 45,
        max_stack = 6,
        copy = 354835,
    },
    echoing_reprimand_5 = {
        id = 354838,
        duration = 45,
        max_stack = 6,
    },
    echoing_reprimand = {
        alias = { "echoing_reprimand_2", "echoing_reprimand_3", "echoing_reprimand_4", "echoing_reprimand_5" },
        aliasMode = "first",
        aliasType = "buff",
        meta = {
            stack = function ()
                if combo_points.current > 1 and combo_points.current < 6 and buff[ "echoing_reprimand_" .. combo_points.current ].up then return combo_points.current end

                if buff.echoing_reprimand_2.up then return 2 end
                if buff.echoing_reprimand_3.up then return 3 end
                if buff.echoing_reprimand_4.up then return 4 end
                if buff.echoing_reprimand_5.up then return 5 end

                return 0
            end
        }
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
    shadow_dance = {
        id = 185313,
        duration = 6,
        max_stack = 1,
        copy = 185422
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
        duration = 3600,
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

local lastApplicator = "roll_the_bones"

local rtbSpellIDs = {
    [315508] = "roll_the_bones",
    [381989] = "keep_it_rolling",
    [193356] = "broadside",
    [199600] = "buried_treasure",
    [193358] = "grand_melee",
    [193357] = "ruthless_precision",
    [199603] = "skull_and_crossbones",
    [193359] = "true_bearing",
    [2098]   = "dispatch",
    [8676]   = "ambush",
    [193315] = "sinister_strike"
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
        if subtype == "SPELL_AURA_APPLIED" then
            lastRoll = GetTime()
            rollDuration = 30
        elseif subtype == "SPELL_AURA_REFRESH" then
            rollDuration = max( 30, min( 39, 60 - ( GetTime() - lastRoll ) ) )
            lastRoll = GetTime()
        end
    end
end )



spec:RegisterStateExpr( "rtb_buffs", function ()
    return buff.roll_the_bones.count
end )

spec:RegisterStateExpr( "rtb_primary_remains", function ()
    return max( lastRoll, action.roll_the_bones.lastCast ) + rollDuration - query_time
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
        if bone.up and bone.remains < primary - 0.1 then n = n + 1 end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_normal", function ()
    local n = 0
    local primary = rtb_primary_remains

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and abs( bone.remains - primary ) < 0.1 then n = n + 1 end
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
        if bone.up and bone.remains > primary + 0.1 then n = n + 1 end
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
    if not talent.echoing_reprimand.enabled and not covenant.kyrian then return c end
    if c < 2 or c > 5 then return c end
    if buff[ "echoing_reprimand_" .. c ].up then return 7 end
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
    if buff.cold_blood.up and ( ability == "ambush" or not talent.inevitability.enabled ) and ( not a or a.startsCombat ) then
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


spec:RegisterHook( "reset_precast", function()
    if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end

    if buff.adrenaline_rush.up and talent.improved_adrenaline_rush.enabled then
        state:QueueAuraExpiration( "adrenaline_rush", ExpireAdrenalineRush, buff.adrenaline_rush.expires )
    end

    if buff.cold_blood.up then setCooldown( "cold_blood", action.cold_blood.cooldown ) end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    -- Fan the Hammer.
    if query_time - lastShot < 0.5 and numShots > 0 then
        local n = numShots * ( action.pistol_shot.cp_gain - 1 )

        if Hekili.ActiveDebug then Hekili:Debug( "Generating %d combo points from pending Fan the Hammer casts; removing %d stacks of Opportunity.", n, numShots ) end
        gain( n, "combo_points" )
        removeStack( "opportunity", numShots )
    end

    if talent.underhanded_upper_hand.enabled then
        if buff.adrenaline_rush.up and buff.subterfuge.up then
            buff.adrenaline_rush.expires = buff.adrenaline_rush.expires + buff.subterfuge.remains
        end

        if buff.blade_flurry.up and buff.adrenaline_rush.up then
            buff.blade_flurry.expires = buff.blade_flurry.expires + buff.adrenaline_rush.remains
        end
    end

    if Hekili.ActiveDebug and buff.roll_the_bones.up then
        Hekili:Debug( "\nRoll the Bones Buffs (vs. %.2f):", rollDuration )
        for i = 1, 6 do
            local bone = rtb_buff_list[ i ]

            if buff[ bone ].up then
                local bone_duration = buff[ bone ].duration
                Hekili:Debug( " - %-20s %5.2f : %5.2f %s", bone, buff[ bone ].remains, bone_duration, bone_duration < rollDuration and "shorter" or bone_duration > rollDuration and "longer" or "normal" )
            end
        end
    end
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

        spend = function() return talent.tight_spender.enabled and 22.5 or 25 end,
        spendType = "energy",

        startsCombat = true,
        texture = 135610,

        usable = function()
            if not boss and buff.stealth.up and not buff.vanish.up then return false, "bte subterfuge bug workaround" end
            if settings.crackshot_lock and talent.crackshot.enabled and not stealthed.all then return false, "userpref requires stealth" end
            return combo_points.current > 0, "requires combo points"
        end,

        handler = function ()
            if talent.alacrity.enabled and effective_combo_points > 4 then
                addStack( "alacrity" )
            end

            applyBuff( "between_the_eyes" )

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

            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )
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
            if talent.underhanded_upper_hand.enabled then
                if buff.adrenaline_rush.up then buff.blade_flurry.expires = buff.blade_flurry.expires + buff.adrenaline_rush.remains end
                if buff.slice_and_dice.up then buff.slice_and_dice.expires = buff.slice_and_dice.expires + buff.blade_flurry.remains end
            end
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

        spend = function() return ( talent.tight_spender.enabled and 31.5 or 35 ) - 5 * ( buff.summarily_dispatched.up and buff.summarily_dispatched.stack or 0 ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        handler = function ()
            removeBuff( "brutal_opportunist" )
            removeBuff( "echoing_reprimand_" .. combo_points.current )
            removeBuff( "storm_of_steel" )

            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity" )
            end
            if talent.summarily_dispatched.enabled and combo_points.current > 5 then
                addStack( "summarily_dispatched", ( buff.summarily_dispatched.up and buff.summarily_dispatched.remains or nil ), 1 )
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "vicious_followup" ) end

            spend( combo_points.current, "combo_points" )

            if buff.coup_de_grace.up then
                if debuff.fazed.up then addStack( "flawless_form", nil, 5 ) end
                removeBuff( "coup_de_grace" )
            end
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

        cp_gain = function () return buff.shadow_blades.up and combo_points.max or ( 1 + ( buff.broadside.up and 1 or 0 ) ) end,

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
        cooldown = 420,
        gcd = "off",
        school = "physical",

        talent = "keep_it_rolling",
        startsCombat = false,

        toggle = "cooldowns",
        buff = "roll_the_bones",

        handler = function ()
            for _, v in pairs( rtb_buff_list ) do
                if buff[ v ].up then buff[ v ].expires = buff[ v ].expires + 30 end
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
        nobuff = function()
            if settings.never_roll_in_window and buff.roll_the_bones.up then
                return "subterfuge"
            end
        end,

        handler = function ()
            local pandemic = 0

            for _, name in pairs( rtb_buff_list ) do
                if rtb_buffs_will_lose_buff[ name ] then
                    pandemic = min( 9, max( pandemic, buff[ name ].remains ) )
                    removeBuff( name )
                end
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

        cp_gain = function ()
            if buff.shadow_blades.up then return 7 end
            return 1 + ( buff.broadside.up and 1 or 0 )
        end,

        -- 20220604 Outlaw priority spreads bleeds from the trinket.
        cycle = function ()
            if buff.acquired_axe_driver.up and debuff.vicious_wound.up then return "vicious_wound" end
        end,

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

    potion = "phantom_fire",

    package = "Outlaw",
} )


--[[ Retired 12/21/23:
spec:RegisterSetting( "ambush_anyway", false, {
    name = strformat( "%s: Regardless of Talents", Hekili:GetSpellLinkWithTexture( 1752 ) ),
    desc = strformat( "If checked, %s may be recommended even without %s talented.", Hekili:GetSpellLinkWithTexture( 1752 ),
        Hekili:GetSpellLinkWithTexture( spec.talents.hidden_opportunity[2] ) ),
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterSetting( "use_ld_opener", false, {
    name = strformat( "%s: Use Before %s (Opener)", Hekili:GetSpellLinkWithTexture( spec.abilities.adrenaline_rush.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.roll_the_bones.id ) ),
    desc = function()
        return strformat( "If checked, %s will be recommended before %s during the opener to guarantee at least 2 buffs from %s.\n\n"
            .. ( state.talent.loaded_dice.enabled and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires %s|r",
            Hekili:GetSpellLinkWithTexture( spec.abilities.adrenaline_rush.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.roll_the_bones.id ),
            Hekili:GetSpellLinkWithTexture( spec.talents.loaded_dice[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.loaded_dice[2] ) )
    end,
    type = "toggle",
    width = "full"
} )

local assassin = class.specs[ 259 ]

spec:RegisterSetting( "stealth_padding", 0.1, {
    name = strformat( "%s: %s Padding", Hekili:GetSpellLinkWithTexture( spec.abilities.between_the_eyes.id ), Hekili:GetSpellLinkWithTexture( assassin.abilities.stealth.id ) ),
    desc = strformat( "If set above zero, abilities recommended during %s effects will assume that %s ends earlier than it actually does.\n\n"
        .. "This setting can be used to prevent a late %s from occurring after %s expires, putting %s on a long cooldown despite %s.", Hekili:GetSpellLinkWithTexture( assassin.abilities.stealth.id ),
        assassin.abilities.stealth.name, Hekili:GetSpellLinkWithTexture( spec.abilities.between_the_eyes.id ), assassin.abilities.stealth.name, spec.abilities.between_the_eyes.name,
        Hekili:GetSpellLinkWithTexture( spec.talents.crackshot[2] ) ),
    type = "range",
    min = 0,
    max = 1,
    step = 0.05,
    width = "full",
} )

spec:RegisterSetting( "crackshot_lock", false, {
    name = strformat( "%s: %s |cFFFF0000Only|r", Hekili:GetSpellLinkWithTexture( spec.abilities.between_the_eyes.id ), Hekili:GetSpellLinkWithTexture( assassin.abilities.stealth.id ) ),
    desc = strformat( "If checked and %s is talented, %s will never be recommended outside of %s.\n\nThis is |cFFFF0000NOT|r the default simulation behavior, "
        .. "but can prevent %s from being placed on a long cooldown.", Hekili:GetSpellLinkWithTexture( spec.talents.crackshot[2] ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.between_the_eyes.id ), Hekili:GetSpellLinkWithTexture( assassin.abilities.stealth.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.between_the_eyes.id ), assassin.abilities.stealth.name ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_blade_rush_range", true, {
    name = strformat( "%s: Melee Only", Hekili:GetSpellLinkWithTexture( spec.abilities.blade_rush.id ) ),
    desc = strformat( "If checked, %s will not be recommended out of melee range.", Hekili:GetSpellLinkWithTexture( spec.abilities.blade_rush.id ) ),
    type = "toggle",
    width = "full"
} )

--[[ spec:RegisterSetting( "mfd_points", 3, {
    name = strformat( "%s: Combo Points", Hekili:GetSpellLinkWithTexture( spec.talents.marked_for_death[2] ) ),
    desc = strformat( "%s will only be recommended if when you have the specified number of combo points or fewer.",
        Hekili:GetSpellLinkWithTexture( spec.talents.marked_for_death[2] ) ),
    type = "range",
    min = 0,
    max = 5,
    step = 1,
    width = "full"
} ) ]]

--[[ spec:RegisterSetting( "no_rtb_in_dance_cto", true, {
    name = "Never |T1373910:0|t Roll the Bones during |T236279:0|t Shadow Dance",
    desc = function()
        return "If checked, |T1373910:0|t Roll the Bones will never be recommended during |T236279:0|t Shadow Dance. "
            .. "This is consistent with guides but is not yet reflected in the default SimulationCraft profiles as of 12 February 2023.\n\n"
            .. ( state.talent.count_the_odds.enabled and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires |T237284:0|t Count the Odds|r"
    end,
    type = "toggle",
    width = "full"
} ) ]]

spec:RegisterSetting( "never_roll_in_window", false, {
    name = strformat( "%s: Never Reroll in %s", Hekili:GetSpellLinkWithTexture( spec.abilities.roll_the_bones.id ), Hekili:GetSpellLinkWithTexture( 1784 ) ),
    desc = strformat( "If checked, %s will never be recommended while %s is active.\n\n"
        .. "This preference is not proven to be more optimal than the default behavior, but it is consistent with guides.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.roll_the_bones.id ),
        Hekili:GetSpellLinkWithTexture( spec.talents.subterfuge[2] ) ),
    type = "toggle",
    width = "full",
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
    width = "full",
} )

spec:RegisterSetting( "solo_vanish", true, {
    name = strformat( "%s: Solo", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    desc = strformat( "If unchecked, %s will not be recommended if you are playing alone, to avoid resetting combat.",
        Hekili:GetSpellLinkWithTexture( 1856 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Outlaw", 20240917, [[Hekili:T3t6YTTrs)SOkvrlgjrlsDe7uIQQyNKnXBo2VOKn)tqdbbjreiadoKIQsfF2)6UNzaMtqqjQeND3FyBzmd6zM((cJUE41)81xnLvgD9pm64rNE8BhE(GHNm68tU(QYhwfD9vRyH3YMd)qkBj83)yvzc7(13S)O(4ypKKXMIGOiRkpegFrz5QIp)1VEEC5IQjdcZw(6I4LvjSY4S0WC2Ss8)h(6RVAsvCs53ME9eJ1)SRVIvvUil)6RUkE57bqgpDAeFErfHxFfoVJo(ThD8BoC9nW)o8yX)E2NV(g8vwFt1keKR)W6pup5tGb)xzXfzPfnp)nhn6m(lF8W6xoVCsqEuEwsY6BkVpIDR28hbZ7NIkwffwU(MV7lxFZpUkknkF9nfrLLXPZvNmTJ(E2VLbdNhDxCrmU63mlpBPyXuM8XVfM8VW343mlonUybc2WS0PXLT(INRUL(3m8nxFZ7HT29lIsjiuepnkh3C38UYVcEoqCGzKdK2IfzLna7ZoA0BaG9ZlGTWVYGv)xHzgNE9vjXfLfiDMVXGF6hioNOu2KKOPx)oGOfI7sGUgbiTO0GYfrbrpevWjB5XR4d)1ItgCCGJBbSqVJ)caYgx2VcEf4hZwFZTrrRepeED4OnPA2mK2Ei(JW)pJoCzjtZUh(PyySVD5Q8S7IM(6)roaXIBJtlGjZsNc)1DzXW)aJMNhpLWfnt66RWvaqrSRVApynzjrPLdcLiObIJ56B6bC(8nYaZZ5G8OLSyKmDX6BoD9np(ynGIfBRaR3PgWkZEE92k4(4WBbuvZ06tBH9eBbhZSA11LGO0tJ20WrCdkDofolv(OqzvLixf8daE)QYiwcYtHeH7HhYYH)Qknj(2OKh4Kt4OH8ZmLzFFCkq7GflAwg(ce4tJ(JsbFAiRajZ5Tc3KmCl(ftZHZBsCk8Z)ufkaubhQLW)BcmVfXCztoyDSCIvAMu(rLHytCdswWb3rV6GY8QOGAMHlbMHZ0OVvPGW4cGPeyiQwTkkpa)pAqvmtuofWZbSGsyXJCYgYQp4b5W5EG6cpCeFHDorUutpL9V5mCEq6lzcHnqolEAq0D4wLnDAH2A)g(sBoL4us(W7BIVZE2JxbAc6JC2NyWz3qMOdzrsCyuaGodMc)GMi5S45lkBoo9qvYZYJkwGWQrerhc4sEkUKYHdbCvWKKSSPQBdywNPoRPXfRyLHlmMZ5BEoLOi5mwvsPlDSAsRGkFvXUvzffXWebktkiwCxvcywIrpamqTmgfAJjnMlNWk7RCI5qXLEdT17Brb4CqSYuZlkfYssqjzW2(ssqlgNmFfkKgCkxWkBw2BbnwUOOzRGTuKYeVJb0xIgDhlPc(h0ansTrTEjjbCfaJ5CK2dfW1wxLhdYBL5rSIku4)GwM88CK(VmkjkIyuatRW4LS85rLfdMKWMgfmlPkp)bIZAeNBYbNUqg0XOHzvPLY3UpDid4Ey14(Hb()FlWdfCm56BagfsFhPht6XsEfnJzOwZFI7ddo87YsJitUFjN7IpXpV59qwiAMzPOMvUTw(6GyhuRjmzyQO(h29myoXaaFhHxbxgei2d56R)h5Kr3VNJcrurbWwG8ICSiNLidTIxTc4ijEgeXulW1vocxOTnWNq0y0X1iHAcWOPbRoC2)oAcacdMb)SY1khn9qctLk9qHLc4IHsug3hnBmp5XIavxsYhzeTN2Gsx1Sxt8iFxKdZrQ7FjUsQgQR4ocljFWav)E7PkDKKLohnDdOUJfA1RhlnlFjlroMZx7YXe6rDmIX)CJ5VK9hnQNVaEPtER0BhHkQOPdyIDNtAyheIqklbdoI1nLI2HKRgSfrSPChdIlliFPlHniES4KBInFb7oYTKP4Zp94cuQcphaxDnVIeZYMZqXbUgrD6TClHJZW)uwgTev3ISkKqdQaz9nljVxOTzTvfdsoyxBBey0qrFb3tz(y1SMO3xCfbPO)H8Jm3dR6dl3WaHljRTCDbGyn8Q85NHZg09jDSpB1QS8YQ04YhqKR0jmAS5jztyjgUMVbVoKE84Y)b3(SGi7JAbO9L8QCp4qLxdWJDqzgW4fvVQ95ZWWlJlWbrI0NT1YL7x7gipa4afCLECdOf9SGvzGoLIbOrHquddk2nISZzgfcB5e09UAyCGmIMCGDeDQN7UfHXWyBN)ahANDSk)dhkb1XNINY3S1NYOzZIi2(a1tbF9cxr6eaRVOq2rKwKJiIOT(a)oPJyifCjAzpBwWmimBNrFnlHDpybTiaSGU0mWRoqquDnVAkleherN1(HR(wc8SM9FEe2k4vDPtkK5znbrJ2TrJ0hnuA7bWzcEc0PqeDkmkF0iUUfL4V0YdWaE8(cXpa8aaahMIW3)BOJmMTdfbwzqISKIm5MsSBgX3zFHafW3aAVSI1nGZ5TBnNZZXPSrhRqquFvnLjZdNoaqMQeh15gu8qAOb1HJ)wcoyfVQXBNcYkaEGLNc(XpCree1(uUEXPrHu80G62skZpfzOY13)LWebQtvYuUpy4QIVdN49oCdT(MVM2riIC4XEI9peevc4)NamDo8K6ioxHCpVg6lPo2VS2X(BaTEaZwECworBRdmbN7HsdhZyCtT5zvZfbTGrQOMHlYO7sKUxuMhhIBjvda2Y9Aprlyvr(4kgiMsWkGdaEG25wj2NH(sAsEvQ(r35wR2nkB5xL1tK(m8LnJ7Pt0jsIJEDtNKB2jCv2dMWGWz0Sgm8msxVy88O5rPnlllpKLIw1YZbPfAj0cPvm(QQKIiJWAhQfxBcAbSi43QMoFjcjJ5(zQZDcBoQmgXN3wyfi8k0vbmyvxHcZXhGnTOC0csaRiemtWsdb5YO8QLnlslZrgYB9HC1QKhqBqf4)tBJ7JCj5GA2TaSrIpCEg5kAM61spBlEaGUC27ekC5Y()tk8dK6IoXs(FbWaOqjUYhMmRx2o8wYfclQq9ngHGSCz00yWwjgtiizvw7oCTNE8eOTcZN1Y4qEmoAYSs5WkGFmbm(kYxEphoMyKakvJQTNdlbKWaYcIb)V44dx5uRJXnzKxjeGuwtNGOmADvuqOnOFobth1TIP75Hi2owRHU8kTzh1LCJ5dSLnsfTuNa1mPPXKFLuIQlkxBjz3RYYqlcYktPTgFvkplqkz8MsnmAvMIVP424vRIitUHmkj4itpLJlU(tqxEg4vaW8JhXwuqSHCUBA60vU2PK5uVvb7Pr)ryegyiTvNgdKHsuaLYNcLp(fmGJyzeyROlyXn4bn3LwzrhkQHDTFTngHZZMxfjsvRFluTyRuI1QZoQdzZAcmyxeiX4M1aPco)91mjo8ByGsSCnAT0X1qwQIQpD3ttvCJHRVLCSUOeHcqdENmAjzfMiMJ3)VKEBZFNMAm1sUCCJZLbKW48olOJXGCw6T1b31Zrmf0gKpJZ1chrp8UE6XnYZ4Yqf3IDwCjbPDJAY8hHKIwkkasU(c0)Zw0vyPqtVSvImrxuxsrBRFXZe5DtkGZjgcsNiLfw1Cvz(GtPY6o6JrsOZKVqCY)OWvCUbG5aHCCkVOzf2642ZJQ9MuxSxt8doeHfvoPZMs6Bk7U5qP3st228xJAtFDbOem1us(k6HCFuMvLZJmAcOcEgIKffepKNAnuZ33NHoDwTeJCno9wmsIgu8(1pDq5WbXqOb0BIUGUS(9OCbiN1iFZQFJW3mWHR6refG1RXaL4hnoPFpe5sjLBqTy64EAn6G6yj18TsngylTcUdS9IMaBBX70w2O8yC)YOzLyZnKgvDhOB4qzPIT37nfkcZmWzhOgvmLFq4PNC0P1pMlSUmUOGCPvltgGPVFVcZ3mYpqsTSL8kPmhKMtDOjcIaQmyPCBQXF2U8exMZbg(elM7MKUn26nCNCnsYZg0Nj0V6ZINPNM2zgY27Eezkt(SRqT1mxHXJZtSSlZ1QviqRma88)7YYGCNB4zURTUJWz4BkQalNk2ydwFdMd)ARVwQ0RZ4(9mewaZrmSD)Tkm3YAv(hvjtpKsKF0FSc8JQWt23ZMWfnBu68EoBhbPFetTKM3ZnigKSEADYNBk2rCQwwIvRuVrEyB3rDdLS6znTb)pFrwb4JyaM7IBPmUzMRwncYpZvaIbhsLauMakcpJzHce2H)70kExfv7OKs5qwao2IkRBCTfavQOpquFlzS8GqACyW88yqInlp004ONAaz1snsXlZmXJIxn4dRfZroiB8GNbcoyc)jrVOhYsN(m3CtYkkOP5Exks2JR1TTu81w2qAB7UPD0OrDiFlTL(WLSPb)Ef6pjQkMA3VN1g6SgEgla3wQ8UnMuSachGZTgS8)ZyHshmSwK)Lv4NjUMHxACZTctNwvmpUxVDzdStDSL9(JBiWv0LO(Z8i20h2ip9(QEy6Pul1DtKJ(JdwdQyh2jGnqMaA)bnk9pgtKEzsua8Ik(g3sspp2xL5cxG2EHF(tPqLuAjgL1466mH61ljhHK8lk(cXdab1Ick9JPQLlRQMwt05iMa1tLSOJuuOxknQ4KzYF4zc)cZYMMagersc2ZOUrpNCClDpgwU9MeTq)RD2DX1ja8A)bZKa)gTPb(LfLFl5vG(0ER60MbMND14vJowDwGcjWOEoljaLCmNQp9tc)9hAJQ8PaxjocqrbywLvoa8tjy6QInR(c2YxvKKH(YxVY42ZNAlXKg9e2EJ2jBVrAz1lydrRFNOfkDLvp0XjLO11tO9V00zKyRqVc18(n8U3f)RRQMah(zvZbbM9PN8RYMiIHDGedZyTEUY6JfJdDYJ0kk7n67xeN4olbfTKLMU33Mf1B0o1YMsIwJU12A8t)QFR7lZoNLaVj7RgcMv53ecTvk8(cNx9Xw7KprLJGiT(zkOKXy2l7c6DrjvYrnYoVNRC2mZkHPAyZzRj(UXPTMbBFg)FUii6V0CrObZ4SG(oqxFbXai7cOM657orAIEGISrPbzEAtFY42nXY2bUXEnPWwRXm65phQx4yik2k(W9AroPTCR88iRhQxkacT7P7mQfp(AWX4jqaRtniXOtjZiQhN(WDejkMNMnL3kmJI(nfZvarHrwJv5zHcXOVRk82hqD700OCT(QAgKeHNF1XNt75mCrUpg3oyx1fNIfoabRo)hdlfjVwaQR6xMvnb1H)HOSvS8PIunbtEsmJcnf3XVySBDt)xdFj2TrZQscGiMmllPsLvMjX3bji6mapckU4AmhC0GswCsHAk)ptXNnJ5ITYO5C77C62l)EDYX(wYC1g55rML0iL2)JnjdzmPmRRX0ImblRtw6pZUfg7vrlbn7pG(iKdXQvygF5FbK(96c1xmJs4qeeTmycemT4a4uXLR5Xt4SFx(3yWOMF)kIybRtlFtTejNa5TGYM(4eisl4yFdCIcxKHXENhb7Bmy92CnquBO2lvQ00e5YxlnO2wvFQgdckwjAZiT)QqYtuEJjZd8SlpWUALh6RSKnAaBGlLFuER4krjnwNVd0qG7zhibJkl6GVSgfS92ATmC2OjXf21NTYnHD7mIdZMdZvcDKnqPs1Dxx)nNXRKh6Vep)WBhw0hoyF)UCC54295WzBKAKi5wveVZqO6OhIzd)4kdzRSRc(q8rk5arpHKpleP)MFEFADpqT7F)9Q4WBdMMZUVb8E7(5pv9nDwf(dOvOFTzu7cEkE78QYfytfNc)rj(O2kyIF603otGUR4fiZbfRS(d)1MUnH7FuwQmnuhkDUxLzNX7OetQjnpX6()HitWtmaB62A7tJG6otE6TTirCgo4S26)Dr)m4V(BTWtOmStvGodKWzHAAYrM)Mr6RzjjtiPBCweULxUkSRQVcTAxIQSUIkDJq3E0DuJkWGHMYLfvv9xR1Vlghn6JjZ6cTf2oTSFllQsTVeIdJSmuAPNJ8UalslovLBdG7z54hxcStPVl94L46koyVI7uZRWmydeYCezW7BAwvz2sgHDcbN8Md(PU(dFhLRh8t9)9zPWsrd)kt)9Ef3mR1ZLhty89h(h93e88(vFBa)n(1H3X1ZUHDmwi)Fy5MRWODmgYd8C7oUbWB3N9oUsgjuZyj8KUTgyV(doy9eFNUBhV3jg7V6kcpO(Bu08BvvUz7632QjkPllPYx86gxo95QTuN6g7R0ZTgyEhDJRjm)m3W0wlKbO9RMQJRGX3lLpPw9VMkty)MDSKKh4P(znzIhy2FXtDeQAFlugG153jvhH7oH25uMSUJK3oPsp8T(6YnVScUBgUokLy0ImglINwBVJW(zjbE(FsyhNuurnN2o6PPkVNRu3z7y45bJ(YjxeoTy7WGBYNMDfn)VgpY2T7ElFoefF1tlMwVABOvu76Y4PhvTwg)ZRlAq07JsdmM7MS0IQSRflhzrNRX8Mv92bs3Xu0HUFe(gHUZP0b1Cb7kb1xaxR9Ssnf72a62vbVJq8z6S(FQQu21WBNycO1qHEb4m21Hl6rpXlWoFxRrYd82HuvpQNFbWnEwPNmUXd8E5Xn61FZa6UloNjK94a4lawFx7QPh4TdX6EwHxoSUJQGAa(wQN6RA3omLu0xTvwG9O9BhIH9Ovrp)6wyyxjFVJqwMxBdyAMl8ocTDiMWRe(Zgt4Ll(LcYn1DWaQ2fKOJquTktgW0vbOmHQNGs3byGx20a9TKamc4pJ3JryPTOlSwyy8JupBwCZxXEXG6CeDW4xJ3jbXLrlpe7g9X()6gw)bxVT61fH7ziCR)qRVu(XJw)HpXS)x)49cDWZ5xp(yxNYdJNn29narpbr2x029C2RSyJQiFtJuIjFSsgTCVT1)k68TRPL3X9(Wtfvmeb6t(m7H9s7czW3IQCxoGYlFcDBrlBh7NWvhA9EPHbNG6o5ccvf44vekb5)R4QVu9KlBAlUEPMV7YdPl)QXokHZ497qPKoyd1(PN)lvRlg1Z(Y06YH2pLUztVyuFolXhzxKMDch3iNQOkPfmpj0QFxuwF4)pO7AYoH74yjhFXW9AWC8lg0Xh)4JnpJFpIo(yRPD54Hnp7IZvgx5(c9IXN82E7P9Hq1Zhv5JRR3YoHuZwnMUqproZ923ZvvjilciuR79YEwZpo9ipGO)fN)4J23XLaK7)4JAFOqxmCK)DUzVWlyk23RxDp(ORw45YXJoWYEjb6dS6ON(94Th0LJp7yIk)FGxtI(r4MD2RaH7(U18YXQFH4hn8O91LBeO86el84J1eoLkjJ8j8iauRdC)EEPX923SJPE8rhDbwFUDJ)AVhf9JPTU)hfO6T1U5OJfNEx3rhxopCQ6wW8BaMVvcrpg(eKLBhF3lU5Lwgvd)IqK7KP(xlScimU(ev5y1aG)(uFJ7hsatDA6xMHi0D0vHGLLZoqRRcTHaDDhQ(CJB3q1H0UmdfoAlBd(g33P9kmBR2H3jXSRT4Un85Akv8LXHiPvpm2i69rsxRBFUu6lwLdNEEi6zKVQw0k5qfuV9AbV05J8UPFZFINFxNQ9TEiT4xo2651TBUdn0s7)J6)uqkpVEgFxImC7WX(dpyFRSW5WBJpDF35)cBl8dg2VVUdnxm2rw4AIp6JSE5EJy592c0Sl1UQQC)0HdoZT3FxmEOnIV2Rd7CKwpKzsQTfN5O()s76Ahiz1ge)qzpzpE4tsZU9lz051cZt)99MZR5ec(b5i)BiFkNUB9X23B)986RXJpU3gsrhiB3U)YBmVM6Qg45b(zFn3zIp4xMEiAy)n0osGGt7nsuFUOT51ChTV76LwN52t1TxY7rv)NHa)65154liNJRn98r51q3MoTcoe9UMQNFUYE7BGFoPNlvM6yrxApnaZz9BIvExDXXzE2ns2UQJ(nz4qjtqJvIF)V53iCMOcJ6vqPMxESVC8P9uYGRY1d3fJKHkQ6bIjS1VF3qqRPMr7xLgi(9pZl4nZ9QEr3mVj2iv3osLNJ76gZKsn(S2xkxxOAB1YH3Ao92U10FnfTxz3lWOrBcbAEhO1viFgXk8mV4ZS4YvVJ1AnWEJm2Y9iX2dHN(fAM5wR1SzGTEPdMH93ZoHyB4QqWs4u56eRXXe97Xm3UkpE4zhBYKlU1Y(0ZvuE)0UPXCBMs6(KN7ESlp1ISPdf(TbwDfunUSXmpnNiteMJlfjRTN86eZAK6BqmZrQV0WS8xu7EcZNawXH09G1y5T0vZPYL2b)DFShb7J746oQBRRDth7FD5Ha1KF8pE(DXBdoHRVGOV6NA1OqB87EF3yi5X(06ie9(bxwpd7VuY(IWiDFRO3MMR)77xEUDKcAtaTVjs45d)0ZQPmUBMszmxg9gUSMdgQwulyMZjqnzI3FT42SR633U6AYrFJDX4ItVWZSHWoTRCxFh4rJg(qQwW9V2BVqtUVNwBGyb5MFDC4CWQvGrjWlnwORxw(BRbHELRmTVimyOTmBiN)ayE()s6W1oWFIwCK)9D8VnoCTFCjA43LjBHgUEjTFRCOMIc63ih9DTWsI2MjeFm)RtdNKyNPf2kdnosEBDQhCKN8ZLwyuIdZizodfkuCALWjrOtjZttO6M)ECbAADyd4U4WvTRCGBxJEZhrKhL5i3(EEu)Bs4b11DiZFkYwEVE)AMTn9suc7oFH(j8GANFrwUzkWEDIe0GpAxlXwCGzFSDXu(SXv2mpE5pSliHhvoxy946kZ1Z)f06wrkoC9)7YKSJxMKVaSi(1H0yIs97KrAS3Zn1OqdP)RiYlhFMWaL)RgsmRWwtsFz2BZ5)4tmTmTtVCh)ZLuSNBAH4Po(uJec4UVSg9T3BCGBd5mZZ11ivk4Fm96R(XQYe8g5Qyvu41)WOZpMUyLU())d]] )
