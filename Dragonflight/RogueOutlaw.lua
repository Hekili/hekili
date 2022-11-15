-- RogueOutlaw.lua
-- October 2022

-- Contributed to JoeMama.
if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR
local FindPlayerAuraByID = ns.FindPlayerAuraByID

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
    ace_up_your_sleeve        = { 90670, 381828, 1 }, -- Between the Eyes has a 4% chance per combo point spent to grant 4 combo points.
    acrobatic_strikes         = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by 3 yds.
    adrenaline_rush           = { 90659, 13750 , 1 }, -- Increases your Energy regeneration rate by 60%, your maximum Energy by 50, and your attack speed by 20% for 20 sec.
    alacrity                  = { 90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    ambidexterity             = { 90660, 381822, 1 }, -- Main Gauche has an additional 5% chance to strike while Blade Flurry is active.
    atrophic_poison           = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.0% for 10 sec.
    audacity                  = { 90641, 381845, 1 }, -- Half-cost uses of Pistol Shot have a 35% chance to cause your next Ambush to be usable without Stealth. Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time.
    blackjack                 = { 90696, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    blade_flurry              = { 90674, 13877 , 1 }, -- Strikes up to 8 nearby targets for 529 Physical damage, and causes your single target attacks to also strike up to 7 additional nearby enemies for 50% of normal damage for 13 sec.
    blade_rush                = { 90644, 271877, 1 }, -- Charge to your target with your blades out, dealing 1,587 Physical damage to the target and 794 to all other nearby enemies. While Blade Flurry is active, damage to non-primary targets is increased by 100%. Generates 25 Energy over 5 sec.
    blind                     = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    blinding_powder           = { 90643, 256165, 1 }, -- Reduces the cooldown of Blind by 30 sec and increases its range by 5 yds.
    cheat_death               = { 90747, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows          = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    combat_potency            = { 90646, 61329 , 1 }, -- Increases your Energy regeneration rate by 25%.
    combat_stamina            = { 90648, 381877, 1 }, -- Stamina increased by 10%.
    count_the_odds            = { 90655, 381982, 2 }, -- Ambush and Dispatch have a 10% chance to grant you a Roll the Bones combat enhancement buff you do not already have for 5 sec. Duration and chance doubled while Stealthed.
    dancing_steel             = { 90669, 272026, 1 }, -- Blade Flurry strikes 3 additional enemies and its duration is increased by 3 sec.
    deadened_nerves           = { 90743, 231719, 1 }, -- Physical damage taken reduced by 3%.
    deadly_precision          = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem          = { 90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    deft_maneuvers            = { 90672, 381878, 1 }, -- Increases the range of your melee attacks by 2 yards while Blade Flurry is active.
    devious_stratagem         = { 90679, 394321, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    dirty_tricks              = { 90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    dreadblades               = { 90664, 343142, 1 }, -- Strike at an enemy, dealing 1,257 Physical damage and empowering your weapons for 10 sec, causing your Sinister Strike, Ambush, and Pistol Shot to fill your combo points, but your finishing moves consume 5% of your current health.
    echoing_reprimand         = { 90639, 385616, 1 }, -- Deal 1,746 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness               = { 90747, 79008 , 1 }, -- Evasion also reduces damage taken by 10%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                   = { 90764, 5277  , 1 }, -- Increases your dodge chance by 100% for 10 sec.
    fan_the_hammer            = { 90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain 1 additional stack of Opportunity. Max 6 stacks. Half-cost uses of Pistol Shot consume 1 additional stack of Opportunity to fire 1 additional shot.
    fatal_flourish            = { 90662, 35551 , 1 }, -- Your off-hand attacks have a 65% chance to generate 10 Energy.
    feint                     = { 90742, 1966  , 1 }, -- Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by 40% for 6 sec.
    find_weakness             = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 15% of that enemy's armor for 10 sec.
    fleet_footed              = { 90762, 378813, 1 }, -- Movement speed increased by 15%.
    float_like_a_butterfly    = { 90650, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by 0.5 sec per combo point spent.
    ghostly_strike            = { 90677, 196937, 1 }, -- Strikes an enemy, dealing 1,058 Physical damage and causing the target to take 10% increased damage from your abilities for 10 sec. Awards 1 combo point.
    gouge                     = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    grappling_hook            = { 90682, 195457, 1 }, -- Launch a grappling hook and pull yourself to the target location.
    greenskins_wickers        = { 90665, 386823, 1 }, -- Between the Eyes has a 20% chance per Combo Point to increase the damage of your next Pistol Shot by 200%.
    heavy_hitter              = { 90642, 381885, 1 }, -- Attacks that generate combo points deal 10% increased damage.
    hidden_opportunity        = { 90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush.
    hit_and_run               = { 90673, 196922, 1 }, -- Movement speed increased by 15%.
    improved_adrenaline_rush  = { 90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and again when it ends.
    improved_ambush           = { 90692, 381620, 1 }, -- Ambush generates 1 additional combo point.
    improved_between_the_eyes = { 90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.
    improved_main_gauche      = { 90668, 382746, 2 }, -- Main Gauche has an additional 5% chance to strike.
    improved_sprint           = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison     = { 90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach              = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    keep_it_rolling           = { 90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by 30 sec.
    killing_spree             = { 90664, 51690 , 1 }, -- Teleport to an enemy within 10 yards, attacking with both weapons for a total of 5,082 Physical damage over 2 sec. While Blade Flurry is active, also hits up to 4 nearby enemies for 100% damage.
    leeching_poison           = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 10% Leech.
    lethality                 = { 90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    loaded_dice               = { 90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    marked_for_death          = { 90750, 137619, 1 }, -- Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    master_poisoner           = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nightstalker              = { 90693, 14062 , 2 }, -- While Stealth is active, your abilities deal 4% more damage.
    nimble_fingers            = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison            = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    opportunity               = { 90683, 279876, 1 }, -- Sinister Strike has a 35% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = { 90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional 3% per missing target below its maximum.
    prey_on_the_weak          = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    quick_draw                = { 90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate 1 additional combo point, and deal 20% additional damage.
    recuperator               = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity        = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges 3 additional combo points.
    restless_blades           = { 90658, 79096 , 1 }, -- Finishing moves reduce the remaining cooldown of many Rogue skills by 1 sec per combo point spent. Affected skills: Adrenaline Rush, Between the Eyes, Blade Flurry, Blade Rush, Dreadblades, Ghostly Strike, Grappling Hook, Keep it Rolling, Killing Spree, Marked for Death, Roll the Bones, Sepsis, Sprint, and Vanish.
    retractable_hook          = { 90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by 15 sec, and increases its retraction speed.
    reverberation             = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 75%.
    riposte                   = { 90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every 1 sec.
    roll_the_bones            = { 90657, 315508, 1 }, -- Roll the dice of fate, providing a random combat enhancement for 30 sec.
    rushed_setup              = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    ruthlessness              = { 90680, 14161 , 1 }, -- Your finishing moves have a 20% chance per combo point spent to grant a combo point.
    sap                       = { 90685, 6770  , 1 }, -- Incapacitates a target not in combat for 1 min. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    seal_fate                 = { 90757, 14190 , 2 }, -- When you critically strike with a melee attack that generates combo points, you have a 50% chance to gain an additional combo point per critical strike.
    sepsis                    = { 90677, 385408, 1 }, -- Infect the target's blood, dealing 5,370 Nature damage over 10 sec. If the target survives its full duration, they suffer an additional 1,970 damage and you gain 1 use of any Stealth ability for 5 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
    shadow_dance              = { 90689, 185313, 1 }, -- Allows use of all Stealth abilities and grants all the combat benefits of Stealth for 6 sec. Effect not broken from taking damage or attacking.
    shadowrunner              = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep                = { 90695, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec.
    shiv                      = { 90740, 5938  , 1 }, -- Attack with your off-hand, dealing 397 Physical damage, dispelling all enrage effects and applying a concentrated form of your Crippling Poison, reducing movement speed by 70% for 5 sec. Awards 1 combo point.
    sleight_of_hand           = { 90651, 381839, 1 }, -- Roll the Bones has a 10% increased chance of granting additional matches.
    soothing_darkness         = { 90691, 393970, 1 }, -- You are healed for 30% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    subterfuge                = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for 3 sec after Stealth breaks.
    summarily_dispatched      = { 90653, 381990, 2 }, -- When your Dispatch consumes 5 or more combo points, Dispatch deals 5% increased damage and costs 5 less Energy for 8 sec. Max 5 stacks. Adding a stack does not refresh the duration.
    swift_slasher             = { 90649, 381988, 1 }, -- Slice and Dice grants an additional 2% attack speed per combo point spent.
    take_em_by_surprise       = { 90676, 382742, 2 }, -- Haste increased by 10% while Stealthed and for 10 sec after leaving Stealth.
    thiefs_versatility        = { 90753, 381619, 2 }, -- Versatility increased by 2%.
    thistle_tea               = { 90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 11.6% for 6 sec.
    tight_spender             = { 90694, 381621, 1 }, -- Energy cost of finishing moves reduced by 10%.
    tricks_of_the_trade       = { 90686, 57934 , 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    triple_threat             = { 90678, 381894, 2 }, -- Sinister Strike has a 10% chance to strike with both weapons after it strikes an additional time.
    vigor                     = { 90759, 14983 , 1 }, -- Increases your maximum Energy by 50 and your Energy regeneration by 10%.
    virulent_poisons          = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.
    weaponmaster              = { 90647, 200733, 1 }, -- Sinister Strike has a 5% increased chance to strike an additional time.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
boarding_party       = 853 , -- 209752
control_is_king      = 138 , -- 354406
dagger_in_the_dark   = 5549, -- 198675
death_from_above     = 3619, -- 269513
dismantle            = 145 , -- 207777
drink_up_me_hearties = 139 , -- 354425
enduring_brawler     = 5412, -- 354843
maneuverability      = 129 , -- 197000
smoke_bomb           = 3483, -- 212182
take_your_cut        = 135 , -- 198265
thick_as_thieves     = 1208, -- 221622
turn_the_tables      = 3421, -- 198020
veil_of_midnight     = 5516, -- 198952
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
    -- Talent: Sinister Strike, $?s196937[Ghostly Strike, ][]Ambush, and Pistol Shot will refill all of your combo points when used.
    -- https://wowhead.com/beta/spell=343142
    dreadblades = {
        id = 343142,
        duration = 10,
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
    find_weakness = {
        id = 316220,
        duration = 10,
        max_stack = 1,
    },
    -- Suffering $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=360830
    --[[ garrote = {
        id = 360830,
        duration = 18,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    }, -- Moved to Assassination. ]]
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
        id = 51690,
        duration = 2,
        tick_time = 0.4,
        max_stack = 1
    },
    -- Suffering $w4 Nature damage every $t4 sec.
    -- https://wowhead.com/beta/spell=385627
    kingsbane = {
        id = 385627,
        duration = 14,
        max_stack = 1
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
    prey_on_the_weak = {
        id = 255909,
        duration = 6,
        max_stack = 1,
    },
    -- Incapacitated.
    -- https://wowhead.com/beta/spell=107079
    quaking_palm = {
        id = 107079,
        duration = 4,
        max_stack = 1
    },
    restless_blades = {
        id = 79096,
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
        duration = 3,
        max_stack = 1,
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
        alias = { "crippling_poison", "numbing_poison", "atrophic_poison" },
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


spec:RegisterStateExpr( "rtb_buffs", function ()
    return buff.roll_the_bones.count
end )


spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )


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


spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "COMBO_POINTS" then
        Hekili:ForceUpdate( event, true )
    end
end )


local lastShot = 0
local numShots = 0

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
end )


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
    if not action.echoing_reprimand.known then return c end
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
            if buff.take_em_by_surprise.up then buff.take_em_by_surprise.expires = query_time + 10 end
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


local restless_blades_list = {
    "adrenaline_rush",
    "between_the_eyes",
    "blade_flurry",
    "blade_rush",
    "dreadblades",
    "ghostly_strike",
    "grappling_hook",
    "keep_it_rolling",
    "killing_spree",
    "marked_for_death",
    "roll_the_bones",
    "sepsis",
    "sprint",
    "vanish"
}

spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "combo_points" then
        if amt >= 5 and talent.ruthlessness.enabled then gain( 1, "combo_points" ) end

        local cdr = amt * ( ( buff.true_bearing.up and 2 or 1 ) + ( talent.float_like_a_butterfly.enabled and 0.5 or 0 ) )

        for _, action in ipairs( restless_blades_list ) do
            reduceCooldown( action, cdr )
        end

        if legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
        end
    end
end )


local ExpireSepsis = setfenv( function ()
    applyBuff( "sepsis_buff" )

    if legendary.toxic_onslaught.enabled then
        applyBuff( "shadow_blades" )
        applyDebuff( "target", "vendetta", 10 )
    end
end, state )

local ExpireAdrenalineRush = setfenv( function ()
    gain( combo_points.max, "combo_points" )
end, state )


local dreadbladesSet = false

spec:RegisterHook( "reset_precast", function()
    if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end

    if debuff.sepsis.up then
        state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
    end

    if buff.adrenaline_rush.up and talent.improved_adrenaline_rush.enabled then
        state:QueueAuraExpiration( "adrenaline_rush", ExpireAdrenalineRush, buff.adrenaline_rush.expires )
    end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    -- Fan the Hammer.
    if query_time - lastShot < 0.5 and numShots > 0 then
        local n = numShots * action.pistol_shot.cp_gain

        if Hekili.ActiveDebug then Hekili:Debug( "Generating %d combo points from pending Fan the Hammer casts; removing %d stacks of Opportunity.", n, numShots ) end
        gain( n, "combo_points" )
        removeStack( "opportunity", numShots )
    end

    if not dreadbladesSet then
        rawset( state.buff, "dreadblades", state.debuff.dreadblades )
        dreadbladesSet = true
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
            elseif azerite.brigands_blitz.enabled then
                applyBuff( "brigands_blitz" )
            end
        end,
    },

    -- Finishing move that deals damage with your pistol, increasing your critical strike chance against the target by $s2%.$?a235484[ Critical strikes with this ability deal four times normal damage.][]     1 point : ${$<damage>*1} damage, 3 sec     2 points: ${$<damage>*2} damage, 6 sec     3 points: ${$<damage>*3} damage, 9 sec     4 points: ${$<damage>*4} damage, 12 sec     5 points: ${$<damage>*5} damage, 15 sec$?s193531|((s394320|s394321)&!s193531)[     6 points: ${$<damage>*6} damage, 18 sec][]$?s193531&(s394320|s394321)[     7 points: ${$<damage>*7} damage, 21 sec][]
    between_the_eyes = {
        id = 315341,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "physical",

        spend = function() return talent.tight_spender.enabled and 22.5 or 25 end,
        spendType = "energy",

        startsCombat = false,
        texture = 135610,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            if talent.alacrity.enabled and effective_combo_points > 4 then
                addStack( "alacrity", 15, 1 )
            end

            applyDebuff( "target", "between_the_eyes", 3 * effective_combo_points )

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

    -- Talent: Strikes up to $?a272026[$331850i][${$331850i-3}] nearby targets for $331850s1 Physical damage, and causes your single target attacks to also strike up to $?a272026[${$s3+$272026s3}][$s3] additional nearby enemies for $s2% of normal damage for $d.
    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "physical",

        spend = 15,
        spendType = "energy",

        talent = "blade_flurry",
        startsCombat = false,

        readyTime = function() return buff.blade_flurry.remains - gcd.execute end,
        handler = function ()
            applyBuff( "blade_flurry" )
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
        startsCombat = false,

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
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "dismantle" )
        end,
    },

    -- Finishing move that dispatches the enemy, dealing damage per combo point:     1 point  : ${$m1*1} damage     2 points: ${$m1*2} damage     3 points: ${$m1*3} damage     4 points: ${$m1*4} damage     5 points: ${$m1*5} damage$?s193531|((s394320|s394321)&!s193531)[     6 points: ${$m1*6} damage][]$?s193531&(s394320|s394321)[     7 points: ${$m1*7} damage][]
    dispatch = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function() return ( talent.tight_spender.enabled and 31.5 or 35 ) - 5 * ( buff.summarily_dispatched.up and buff.summarily_dispatched.stack or 0 ) end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 15, 1 )
            end
            if talent.summarily_dispatched.enabled and combo_points.current > 5 then
                addStack( "summarily_dispatched", ( buff.summarily_dispatched.up and buff.summarily_dispatched.remains or nil ), 1 )
            end
            removeBuff( "storm_of_steel" )
            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )
        end,
    },

    -- Talent: Strike at an enemy, dealing $s1 Physical damage and empowering your weapons for $d, causing your Sinister Strike,$?s196937[ Ghostly Strike,][]$?s328305[ Sepsis,][]$?s323547[ Echoing Reprimand,][]$?s328547[ Serrated Bone Spike,][] Ambush, and Pistol Shot to fill your combo points, but your finishing moves consume $343145s1% of your current health.
    dreadblades = {
        id = 343142,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 50,
        spendType = "energy",

        talent = "dreadblades",
        startsCombat = true,

        toggle = "cooldowns",

        cp_gain = function () return combo_points.max end,

        handler = function ()
            applyDebuff( "player", "dreadblades" )
            gain( action.dreadblades.cp_gain, "combo_points" )
        end,
    },

    -- Talent: Strikes an enemy, dealing $s1 Physical damage and causing the target to take $s3% increased damage from your abilities for $d.    |cFFFFFFFFAwards $s2 combo $lpoint:points;.|r
    ghostly_strike = {
        id = 196937,
        cast = 0,
        cooldown = 35,
        gcd = "totem",
        school = "physical",

        spend = 30,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = true,

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) ) end,

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

        talent = "grappling_hook",
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
        cooldown = 120,
        gcd = "totem",
        school = "physical",

        talent = "killing_spree",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "killing_spree" )
            setCooldown( "global_cooldown", 2 )
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( talent.quick_draw.enabled and buff.opportunity.up and 1 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ) + ( talent.seal_fate.enabled and buff.cold_blood.up and 1 or 0 ) ) end,

        handler = function ()
            gain( action.pistol_shot.cp_gain, "combo_points" )
            removeStack( "opportunity" )

            -- If Fan the Hammer is talented, let's generate more.
            if talent.fan_the_hammer.enabled then
                local shots = min( talent.fan_the_hammer.rank, buff.opportunity.stack )
                gain( shots * action.pistol_shot.cp_gain, "combo_points" )
                removeStack( "opportunity", shots )
            end

            removeBuff( "deadshot" )
            removeBuff( "concealed_blunderbuss" ) -- Generating 2 extra combo points is purely a guess.
            removeBuff( "greenskins_wickers" )
            removeBuff( "tornado_trigger" )
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

        talent = "roll_the_bones",
        startsCombat = false,

        handler = function ()
            for _, name in pairs( rtb_buff_list ) do
                removeBuff( name )
            end

            if azerite.snake_eyes.enabled then
                applyBuff( "snake_eyes", nil, 5 )
            end

            applyBuff( "rtb_buff_1" )

            if buff.loaded_dice.up then
                applyBuff( "rtb_buff_2"  )
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
            gain( action.shiv.cp_gain, "combo_point" )
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

        startsCombat = false,
        texture = 136189,

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) ) end,

        -- 20220604 Outlaw priority spreads bleeds from the trinket.
        cycle = function ()
            if buff.acquired_axe_driver.up and debuff.vicious_wound.up then return "vicious_wound" end
        end,

        handler = function ()
            removeStack( "snake_eyes" )
            gain( action.sinister_strike.cp_gain, "combo_points" )
        end,

        copy = 1752
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


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "phantom_fire",

    package = "Outlaw",
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

spec:RegisterSetting( "ambush_anyway", false, {
    name = "Use |T132282:0|t Ambush Regardless of Talents",
    desc = "If checked, the addon will recommend |T132282:0|t Ambush even without Hidden Opportunity or Find Weakness talented.\n\n" ..
        "Dragonflight sim profiles only use Ambush with Hidden Opportunity or Find Weakness talented; this is likely suboptimal.",
    type = "toggle",
    width = "full",
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
    get = function () return not Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled = not val
    end,
} )


spec:RegisterPack( "Outlaw", 20221114.1, [[Hekili:v3tAZTTrY(BrvQIMmsIMG6ihLOQk(iBCQ9TXVq)E73iiiWqsSceGlomTQIf)T)6EoaMtaslP43(HKytmONE6PV7gDM5n7tZMgfusM9pgpA8yppVRhoE01JhF7SPLpULmB62GWhcwb)H0GnW)(pQktc2H)8Jjzbr4RxKvLhcpADz52IF(1VEvC56QfddZ286I4nvjbLXzPH5bllX)E4RNnDrvCs5hsNTW6Ep6NMnnOQCDw(SPtJ38waYXrre2YjfHZMoBAsCrzbf3jldQskH)4)GEwiPblsirZEdBT5XBXDF20)KuuscskxFyE8YdZ3Mvuedl8W8(PzhM)5QKusEa9hiPKnXKcyDPhMdhIfbLdaekKbhouMvciT2(jwYdXHpOT7FiTKKNxTT8W8mkuZsIY2b)PsyZdssY2DyoqB2eNUc3xyXmGbyXUyeNlxhuoBkaq4rXbZMEgSEgMqIgcaaXNR0WNSTa6skBqSphaVl8u8pLub)NYGesAjCtvLw6dGYplkQyihehM3dOoY7ZIGI4WdZ3V)W8fvlxoSyDaCk2qsIgwT1439Jcsdj0NmqJC821KWhky3e7asEqoHrUdW)z728STaMwc)4uXLwrj9VVmlhig5XRwb0bKybi2H5Vfpa8)8FahbapYsRkONyFgFB9PWpSmdPwxFYuR8Yf(45da)DhMpwqFoJFQxKdYdfXrSJC9Z404LbPuk86GnBi5n0yKOjGqXdvjj(bPaoMd8NWzGuWOFu4jwwzEfXFbjajaQeEuIeoHrXc6o7zsi(ejeNH1v5XWRuMtckQYRXD6ZwLJ4cC)si17JZtRtSRNlKtxcnljHFh(g8KFy(FsYP)2BZsJIPIdY3O4PkNUc868Mt(6efTZ83MbIBfdb1iXHXap09mk051xCXBa2XpdiEWMfvfRBU5o3fLauGKV6rgOUzKjRGlXT6Rr8mrFoJdiNSjigvfGa0BKjL79P4vhtuAfboelRqY2VqryG89r4NzqaUpPsBPVcwfJ4rLISiaX4xc2f8OmrNre8df3iiP)2NePNDSc36Vj4l(fBjigEPvs7LnCTzB3MLxwLgx(OK0gN((VRafW(r5b7uPTDijoq6gaoFHG(c4wFrsvAejho1fYIuKLljWP7Ze)2plA3u)ACAmELeaeBynY2HWBjuxFwfAK4ZK8LGvb6LdvxgZuug(g4oDXH5vPjKIcUkX3u(E41xhhIapbU0GhuaWkboylaOFZ54oiFtUKIkQ3K)GLBYCIZ7sNGsYqLWu3WfKYDecJ0tEKYwhe9itGXbXe0YEJgb8x4NTGYsYg0CkAaTQGWPaiDLDuVa5VxfKhXiszl5YbeWcZUaWAaEE)XtHZ9yoTuMNLjG)sjm3EO6DvudA(0A5B4861kbHQCQfwQXNZmJsLJtGt5H5)T3(o2P)xL23AbrpKk8tNcvG(AaRnQHkih02umCrcOy3FzsvE(JsMgZdIJ8jFgf5cq9CiIDp8WrsYzYVQKEokDOrf8dXu1uGevoyjsGPQKH)j1njWBZY4TO4eh5UajgXamfNbGaHYsOdiOqpY(ercbvmO4dbiCGWur2guG8DAYqfpckfIeEK9ge1rYkI7Y8hYNjF8DqAS3O2Co93Ixr3yWRNmGx6rj)EqhD5Y4MkPzodv14N0R)FdyCdO)IiMI2bwasApW9VcDZmDfsgwLKTiiP5soma99G(x8XnfDzkpoeXDzo8J0BqMh6Q(ErPd6oP7E7Laqyub9L194wHi(3Z21nnCkfjpm)DOVPN8HxWenu1BsxNvDhYTaitLjcukVk1j9G9w09q3n2JIEIXFfrFDD3MAqrMxm4TmXxX7iVBOYM8NdkzjsyDqEyqkXVmlhCYOKUfu3d0E(2QKcI8gJl8hKxycisuw4)VQIwTbHK2A)r51UiyLF2sF8g7Hc1vcViO0GffxNXi((VqcRkjuXDGBHic)d)7RantdbFQcdjBrvXPzPxUoiFd4Qfiwjcwlln5XHsN2TBtEe1ExWSVowbRZklrpmadcpsIqt9az7lXPAhvDMiXRVji)b8TZYHRNaGJt6UZLQ3BKOg(feKRdOxGUjlXdjjYdQaxeNgnCBvrzvcy(gJKfqcv3RQx2NZqRmW6kYsO4qTgBbUVemkVMMrGAx31JVwLiO7IznbocyZcaJde)CWVuzS2W9D1L2GuwOixzZzOAbtfVZvi7sgYVYkGhBZRJ6JEceAen8pmgjvaVeCdBnZgSTBqgNoxTGf28AEonNWS6lbjhocChQq7JpqiBfbANJAbIiOcFWVRTxWIH)p)iZSk9hq1SuDT)nWADAXdafrYBvkyygNzVtWcQhVudXXKHQxH4YgwgVb1OaufcLn(kH)(m8WMNLn3dxZyoHvdkurP6veiUwbI5VduzaNxRbk02YuJi3YkLIx(424EYHi2XczUnwvUgPP(idrCbkpYcR2sQP08qvLttHETe176x)lOFCnmFMXYwSlEjWic(AUwpRgDfK3aNC(cTE12YGqiGaXYYI0ulCT8QIIl2gugU2Waa69qBYes(RPjpO4Jhl1DJpVodHk6iL9iUolcsSikE62KYKg3PYZwvrA)UJZVhHrorHxXqwwevteLw6deCI1(C0K4eLlbn9Awm9OK(rRGtoXskXUFURSdDEx5(68oy3zw2u2AL8pYOqAPbdVFUv50Jk58JboFwkrA3IOIqDC6NJxLLdM8WquOBDeyOupnQ6zSvrvtlzGvMuR42PrAbdEa0)TXFbe1rvo4gCHCMiBspcyLiYFhesaqHv3ko)L6cAOF83NLmEF5uWOPwSgF1ZwuTkXorLUPloDHwGfQ6PKzjuutDwt64vxfp)edKJdw429PNTXwXJxyoex2jTLN6vRZkkbNwX4FEqJuXHJ2sAsqTcGK1s5KGlVOg6Tuw7LixTN0rfHtrEduLPTZ(yFlAmZQzRSHM1cd4XkTizbuclS58PHFTp1ZwFPBbDy14paOM8QrcZ5DTAmTnJh9msEALc5Yl6Lk55YDfZoc8SNWtvdxq94efnVLWe4DffRdFmecaI7pa67HL8SPGBuEn9yuSjG2van2C(6oM7idCh4KTuu1bTZ6wOJT6rP6wvGXkf6dCFpqlhIKdGnktM1wQMKI(ul8N6hWJG5JSaEpm)98iEzH7KMvkrq4vvH(JwtnydDSVuuYpXGPLS(BLT2PFNuO3z(BhOdhBSM0cHiLMiXTdTYg3Zz5SL3o35WGUbHGF(Ed1t9)hakFanTN0YftJ1SinElHhuj4XO4cijBhbt53N(07gEy()tbl5UWTx0J0kQSelaqonlPPS6cuNHl8AVUmmbPpIpEyB5wrU8tM8O3PkN0uNrDHu1kqAuompP7BlHbGjCLT9(XlTf48mB5J091GbHhBscgXNLtz6HdPt1LBiL8Ls0AbnyFKI)FT8DSqMwKvuCIevEcRqBpxAwjHOQ8GAn0NgrSnkyBPtvPeeA0hk)fIXExo(tmne0CNWYicx9WUmAnxddGF49uzgEQsW0lE1No3A2HnkLGPipnSrbhyho61w8J2t3lfQYz69W8VxuFCmpWd6wFISEa3zBUJJC)ov00YfRSIkvFA0JAx3kjdzQnq6klK84cmLAQkOQB(GueIIsqGHikKusZY3eKGQTwHvuHwOMiHtiOB80YvrF5nb)lAPGExHQ8ZjfnkdVvQe5WhsfCcwTO0Uxs9vnLRa4MY8(SeEaFjokLkpweg3MBFOpnY1zVmuS6tjjCDgU95eiO9nG2cfxQV1syQKTfXkuePhLdhgSVfaZHG2kmanSBqaGhUg5ZPYo1fI1AWTE6Uw3Tt0DhKAhHd0WySJeSnlDd1cTDiyMvbJWeWQqspkD7ZnwE4s0xDsGKTC3v)AKtx)ze4cQks1KljTh0m852tBUpBzzrjiBiCfhw6A)UsUs6M(N1S9BZO)xCN9KZykDF8xwHoP2Gn4YulufjhyRq9p6ltjlTlJZj2ss7yLS0IHVvuMhK4JvOuFP6giyzbyxEW2cScFKesyzEg2lGXHGn)sGHjwUi2DUsCtCPghZjj(UHqGTayW)2YQYQC1m9YyAWMpHPgOj)y2UHehHwGnIsUQ10oieGIWGCFS3ekkbzANjD20SlO1eUsIASVrtcQDpTU1jx9puFlyIliQ7ko8WGqupWs)GW)Dfdp49yOj5SEjbFPPtdnrfS(L8gcOfGJiLUyVOZmaUtGLaesI8bx)JEGKhUoMS0s86QcjoEjzLjrzG(V8ksI)QG8CGHdC)MA0MMjDDj(A1vabLYWUevBNdsW00QTKytvLZf7FDluTgMq3BgIITwA83XAZA0sJOxm5XixvGVb41citO6usBEJstbeiu8agMI3W1bf(OS6qi4a)OTf2plykggHvlkdUJMYFDPRQ6FbpoUI5KVOXFvy64NcMIf)TSPc3Tusk5cEPCnmvuDClEoBRH(CxlPJOduQlOwRLcYvQNP(xR3Sq9oIu)FMJcriBrJ5caJEYAMLwOMm3LSjJh2vPM98KdCYj)HL0a6PxkrelbdPTFRypd7Q5Jv4IsRjXHLnoe3Cesu7Pv7MgQNkU0oVG7KtiGMHVUiaDf0n)w2Sx5K7YlrxoJU(WIwI21nhM)RXyC3)to7dlyBGlVOc9)93(JZ)LQOGqkiqmUPNF(i4RwwcgNww5mZeV3wgR7jCgJd6gfiDX07S0Bi9r3ROA)6Oyke2sMEMmPPKOP)laYaRlceN14nBir4xybsOy5m7pAoqnDRbeOuknUZFnqKNNFJ220gMWD0ce6H95Q5Rfuo9g7U2)wlWxrEB4n8W(C5DNBIfR1r1pHxiXTOqBQ7DBWma9RybzSeFjlSSJrBULRpNLArA6FExJ8alXq00fJsggmyNkjQxtHVLFef7ysZgpJMwm2ZRjWYpxXPloDTZks9vG3oYDhTRDAjHo2VulnRjeMrtmVKko0TfIvg0)W)Q1kBRUmfKsmXafIqobB(7cEurKUn1bprjFtRDM1OPXgNrC)6DoptR403m9G4RotO)xj7SnT3vqrJE2lW)izjSlSV6kX7XtOErgSTyYmxYZRoH(QBcqJrSfBXDzliTp(7soo7SiowpWN8oyToDolxXrqKn(Sey1DiUUzSPjaw5t5GRHyA67yAgW7Em3WarmFxmcdwd4TmpBd993sj58SniFOT4f6nhr(HqTb15U4YAiJrjqp4yQjrynA44BARWfSuUJFPrcPxwulU6SNETNux2DHRAw0HTpzJ4wTWHkSFlV7E)iMEGWhRtsp(13qVNiIe1RFls(cGhO4eDz0V2eAHJOlJN13)B8Zqc18JFUSkCMF9kmDMzklzPNAs8iZTM9lu8s3Z1h6MKYTo(GRQ9gsZlFtxLy5T1L7GfyKkaMlCfTvh6nYRaGFXW9k18Hj)YuoSXVAae4SkxzQEKQz7Ty2hGB2mE1EO)ipiprzFONe1oBwh9BoILSiza0d7RTMph6zt3fKJoGbI5Fc3K4nilbpY7xX)2NFf2JMSdQ4BxjOQmBtaTv2bP5uqAE4HF)Vt9q(QFM(bvc7f9XVYAQBFftdM9hkUhHf137ldQH812HSkBUgKTldOd5BSdzTpntnq74d38iH9Za94w7qUrArdQMIrhjeFsu4d)UfoR6Em)04T05aC2SdcCSZUHOlEmN9jHXo4QrkosASR2UXjtN9UZPd6opHjNgv3HeTIhL6mf2ChTdClKkgCc4L(DvNvDtGKDUWJL745tw2LUTVEACRW1mQcnG7oSJJChEPW8xoATCdaQbxBDv7rQN)LbQpdubhqwnDCAq2EZ7EKqwkgBnWAPw9hPwtTEfvdUo6H1Je2pJYi)Wli27a2pJy)p9xKfl2U5nY(2P3ezABJRgb1a8EV4(q4ElE2CIWtNNTttAV6PA7ZylFoeR905E7e9E6NJF8ftL6v6x8I66zwaYA47UgLgqFSdOBw0qdOBDjT5mgRQDV6K8ht)0323LO51O7pjrJBqhwUCUjoxWXUd)N7jXGNH76H8NvPgWT(jx2b7cTgPNg3Y)56zQd)BEsrj3QNipdq2Hxcpdq2H3bpJ3Jo2HN89ONRaBF6efxGwobPAa2wUtLL6(avGdb2TI(fLn5rqrk8R2pBzm(9a(DhM)mnNjo878)(W601C(KxlpZjSVcxdEc7Rw3XTlmM)at8gDr8YjMDw29JVXomB(cCWx0PdC7370Xl7WLN(ehegv)BTCoUcXMoCl2oSv)2PTa6XukeRYm3DLdSx5ln0gDMbKMphFGT77WXKN4C)1mAlRXLj1uVVdBz9YN(aRSg0WHdhkMi6FMA)dJ71FrtdszSr00sxGng3eLox6c6hS7eRow2RVwhnTFpRexYJ(iLFREiyoGDvDeZ4q34zZxAphjR)I2VBCV(NzuKg43SQvC)(ZARYCd6XES23Qp)CPoghhSFFnsmbqcgoymtj7X7Hd55jPaluWyR7CpBBmLE(cp5dDFvO3d68leB1r7(jJp3qPc91p388ZQI39tUzuZLNkpi)AW(mI8EqxmJY8nEsd6MYP3VHwOC3pr(t36sdQ0L9TuF0E95KRMYOSFVv2)bCsORH8i8C7dGpv8IsMF(MhHNaflB7e6uze1N2X8vSN9tYD3yWKCSZoWtapz3SuRwSECXY3RtphpryR0ZXjaKQOhHVTZ9p3edJVJno1WDxBc6WT5c1io3QTrL49EcnlwhrIuc03UzlOmXrFC0Py49c2W2JXPCewy7gWHWjap8N(mbSByBdPD0e0sWsBC(jlXOaaJppQoXhAS9YltDg8Hq3spJawkU5CLEgXec0P0N8VRnu(KFKYm4J7yQONNBC3LIRtynK9fkTVbJoA2pY3751ZD7xVFVsppDNNN2EbyMArrWDP1US(UjxbU55wkDY497T2vId6zb7NCJjcz0d0u)IT3N2cj4)Y64zt0L5RIuOrMzgONER80y5voq)EUhWq458fVPLnpBsDrwTvkRDYSlxP7zXteUkl3DS8DEdVzGK1RVnTECNuJJ(a3Z0FmkcE)eJFVUZJ5ejlDD8DJh8mIAw9i)6EUe3m2x5Mf(cr)epXIAMgXe7DnCTiHP4ZxL0Y36(51KcyP3szA26UrCpoGzXGXXbCKC9xEN5ECNj4mOAcBYn73FSTR7LMTQ7DtW20fbHjF)eE752R1W)75OPCV3Rrl9))Q9A7uDXXR7UxFB(kj7N03dkV3V)mlzf2QUM7M4zgMFTaVzl)v)i9UMLFPjzKDqZ9XZE7RAH5vT9vTjmYqqR9CBNWt4YOs0v6tCZgOao4ReIfvVRStBq8HCkM2eqQ3z6dpfzGEUrUCB8xuFUPis5MX82C)EldhZb67Jw)Jq5tT8EICQjX(WyO0ss25TjtZEO1rO5G7fPTZySzkLBV7NCRXbGnXiO4DNv7hOvkj(TMnxlbRNzpsQ6usADgx2RF)tZaAl2Ih0Z5CMOrQxDBSFsCgr3GgFjLP4a0BzouAH4RKbBRd6p1uzlVMN81H7qYAoDQXxvh1KX4JuIGijIjtpmMdmgKd5dNSgFnHSEDmAezMemg5J96782SnwPUqYVsCSFxJIrie2rsor4yv37nE0x5bZ4KjN)oRUPPWT1YUAlgAVrgH5FLbgOxDpCtz2JmgmknSBUkYNQ7tqi)gBNehPLZN2B3SH6ftvMj3(aq0Ewf8gXYF7lXal08UvUyT9)AQw7GE6mawnndqOLSJoq8wM3O737YN1XmNK(go7a1jNg1tNpYdNa(vEb7K7d05nXP)S5npTaWgdGqS0h6R8oBoJApSaTYT4nWz0XCk5lWWaStQKLdEC69xn6sxdhq7r(RDuB7K(Smw)mC6top9kj(1OGbgoQ2RFlwDD5JQTWz6RepZ4Z9UzqBIE3BQ(J9yHI2wod9Dky6G0leLz2WuDPxsy(fDY652r3U9ZL9MwMuC6QaDBcS)zTmj9oDFLe1z3w13mTKFkN1ZEooSDpg8U)wfFJLg(DDKPeZbF39Jh5WRmS0s28u5eDU3EMbQJH3zSfgyL0iJRXxg1zvN9Cva(gy4VepnrFVzmCSrdxDW7AtEoD4CLOyKwMgWgAieZwoJNupo5m80qmb5mCUtzOXP)uqs3hN(uSqH6AeW1(B7EoTvtJ0M9BM0OoWVy9XOMrUlu1(gPog3GGYnTdERXv(p0ow0YauZAMCgAwRn5M7Z2w4CWP5mpUwhFATVjohPzncnTp10SD9b2yo25DMlSR4c6S)AIyKKjLgjRLX09xIGocozStgmTnD8XUPMF9bw3uPwg5B6)lIQ54Z0(or)WXIT2iQPRC7aL4CE9(99B7dfOoOyZhjsrL1YhcMfAdS9oZjy71sM70jeNB0dPcrz7)p8P7uUK7j1zPsPOs(Rnqn(bvNPTHnnZXolpumE54mwt17DxUH4jnarXxtNnkH4fL2It(fBkMN9eGbEMQ2Mk9SMzWZCoi7aswiokshrN8dZ()(d]] )