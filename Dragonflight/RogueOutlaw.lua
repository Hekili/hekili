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
                addStack( "alacrity" )
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
        startsCombat = true,

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
                addStack( "alacrity" )
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


spec:RegisterPack( "Outlaw", 20221119, [[Hekili:vZZAZTTrs(BrvQIMmsMMpSStsjQQITZUjP2BtUqVx(gbbbgsHvGa8WdlRQyXF7x3ZlmpbiTOIV9d7gzIb90tp97UrVy8IpUyECyfzX)CYOjtgpE83pC8OPF30VBX8Qh3rwmFxy09HBG)ilCl8))B1vPHpG)8JP5HX4RxMxxebp6UQQDL)WRE1MKQ7QxnmkF7Rkt2wNgwLKNfveUUc)3rVAX8v1jPv)s2IvU273(6fZdRRUlVyX85jBFpa4K4ycB1KYOfZxmpnPSQKI6K1H1PvWF(pPhfsw4Qus8I3XwBrYoCZxm)piLvKW0Q7oSmz9HL7YlltGfEyz)S8dl)uDAgPiK(dKmY2esjSUSdlHZWQWQbacfXGdhklQaCUT97xYQiff17QoSmNcN8048hG)Qc2UW008hoSeigBtY2G7eSy2oa77djiwwDxy1I5aaHhLeUy(fW6z7njEiaGgu6(KO7r8zQb(KVdqxsvZc)uiaj4P4FLwd)NQWuswfCrvNvfaaoipoUCihehw2dOoQ76QWYKOdl3V)WYv1RxpS8Uq4mTLKgpSEN1VhehMfrOpzGbX593rIUVKDt8aqYdlimYDi()2TRiFhGPvWpoxCPvwr)3RZlastrYMnavbjDaIDy57Xda)V)n4ia4rEwDj9ehWyBLNIGOQCKA96tMAvuTkapFa4V5WYjc6Zf8t9QcqCOmjMDKLpJtJxhMrPW3fUDlPOHgJenbekVVonnimdWXcG)eodKsg9JcpXYQkQjbRiHibqNWJcKWjmorq3zptbXNPG4mSUUibELQcsyzDHe3PpBtbIlW9lHi3hVNwVyxpFiNPeAEAk)o8D4j)WY)Guq)T3NNfNqfouVrXtvbDf4151N81jkANhSlhe(khcQrsIsaEOBzuOlLxCjBb2XpbiE42v1L31CZDPpkbOaPyZJmqD9iBwbFIBYRr8mrFoJdOGSnmbvmGaC8iBk3pLHxDmrPne4qSUgjB)ifHbY3Vd)mdcW9jvAl7fWQyepQuKdbig)s4dHpQs0zeHGiXncs6FZtI0Zowr7c2g(5GYDeedFPts7lB4AZ3TlVOQolP6rfPno99)Tguigexe(GoTTdjXbk3aW5lc0xa36RsRZIjfWPUuvKISEnboDFIe0(zX4M6VLKLGxjHaXgwJQDi8wc18NxJMm(ePynyJGE5q1LXmfLJVbUtxDyzDwkPSKRs8Dv)e863LeHapfU0GhucWkfoyRaOF9L4oOEtUMIk63KV1XnzbX7DPxqPy2sy4B4ks1decJ0tEKYwhg)itGXdXe0YETbb8h5NTWQkYw04kAoTUKWPaiDLDuVc5V3eweZis5R5YbeWcZdHG1a88(DNcN7XCAPmpRtb3LszE9q17QPg0(Ps5B48oUvccv5ulSutUKzgLkhNcNYdl)7V)dSt)FtzFLcIJrQW3Fkub6RbS2OgQWcqBt5WvPGI9G1P1ffpQyASimjoG8juKle1ZHi2TWdhPiNP(Qk65O0HgvW3NqvtbsufGLibMQtg(tQttGZMvj7qXjoYDfsmsaykodabcLLqhqqHEK9jMebQyqXhcq4aHPY8TOa5hmKHkFeukel8p7DiQJKve3v5puptb47G04XJAZzXFozdDJbVEYbEPhv87bD0LlJBRKM5muDJFsV6)jKXnGEpIykAhyfiPDp3)k0PZSnizytA(QqfViJcrFpO)JaCtrxMksIqCxLd)i9gK5HUUVxu6GPt6(3EfaefxsF5w94(FK)q30W5uK8WYpG(MEYhEbt0qDVj9DwnDi3bGSvMiqPI6mV0d2Br3dt3ypk6jg(vm91nDBQbfzEXG3YKanVJgFnv2K)CqjlrbRdlIcZibv5fGtgv0TG6EGXZ3vNwsu3yCHVvDHPGirvzW)UoEZwesgR97ux7QWnb5RdWBS7l1xj8IGsdwuCDgJ4p9zsuDfHkUdCler4F4)EdOzAi4tvuezhQkolp7L3fwSfC1ceReHULNL(4qLt7UDPpIAVlz2xNOH15vvOhgGbHhjXOPEGS95KmJJQjtK413gwCp(25fW1tiWXPC35t171kuJGscY1b0lq3KJ4Hue5bvGRsYIhURUSQofmFJX1ciHU7vYL9PC0kdSUY8ukoi1ylW91Gr57Ojeq66Uz816ebtxmLe4yGnlemoqcka)svXAl331xAds5GIm1LZqsbtnVZ1i7kgYN6eWtC51H8ONcHgrd)dJrshWRb3WUJzd21niJtNjw7GlxUdKDLjik)yeC9WnrAOJJ9RdRs2IIXaQqygKzEMety2TnDMteE4AuSnqZJMXgszVdXssrPRuO0Gg8nAZD5LvGmeQo(EIIRsGIOPYmu0M7iS45qCJdYy0Xt6IudU25XEg1bub1thxCjBQLTgNBxd0ir3LJY8feWI1w4w3LqOLxcQ23eX3H8088kH6BaFssWGO(tWQFgZ53cutgeKi6wZp)Bx(J1XHruqGyyJ2UFhSqKNIgjZRCikXYcxGASxsfacVBd5GwYqic6cqPGh4yK2RXjt6laJyqrkNEqDfLVg95FHHb83bxeZkVNYK8NG9aGrtCmtG49IX0kH0iMtC)wZzPjGkWYBgnWR)wOWx6FMgROLN(BKBwWdS96KY9tpprZkDPYb81eTgEnnzac60o69xqjE95qPPd)LnpHxPWOOrBKbSwwfstDhYtjsFhZntAMhE9LS4SOjA4dnS(m3UZYHLGcbw8wNkjQN7CbqXoMGR1ZOXKZEUKaR(Cvk7K2ORMggohhgpjJciOIKR1H6edC00gd6Mqg5ZmhALVdeBoO)HN(EhrcQ4daPQcKjkhYtauy2JqG4AI4TPE48RjO9aQ(rMIW5VBUmH7YqcvsZsOytH)SSr16v4Fswtk4Pyw8EXps)3L5GHFG9hCFb)puXhQoC0EdBXMMcYRgwcGd09etDBacLfmHeG)EfiydGv1iT1cBnYjxR)ly7T8jOZaU(rRCWarqd6tsKrEgfUZiVvCndZZ(atJaE9cK7CmW7hsqyCpHaV06I8T03FhLKhDhIxAoBz6PbARMXOjt5KJZmvlahA0mkY)7G186VeMYG1OHtKGZLOjlpFyAv1Y(T3u4lZlmlIkHFguDQO7vDF)B6SHTTpv73oTWHkSFppKMFpVIKfHwcZPzdgt5i9(IHMxzFBs(mGIOyfDz0uSHwbylRUKEr9FJ5Ef18JLiuJj8lx3yFDsNQ2r1GqpS8B5Me51PGVJGQKD5zBXC(PVFUVyXl)X(YUVIESoYYS0ri1D8cxEj53qJ3G7lX4)HJJWv0wDONTJra(wGHb9zGcwKax2uZh2mrZ5WgZFccCw9lT1DYk8wye(F(q(hzmx0FeETS7rNbqbCytK5zWl6RgRxflDpDfRUw63y44KlLfVvZ0LA0bYc8OCBOLeYMQz1KPRI8n1kjlsD9hvqmQ2SzfbUNwLdnQ3JGrtMKOMkDPXTyeiAxXJ4eCk(rPZPl4)TkN3LDPPtSGI6Q7qhQdWawtkbuweU1TMfHuRGXmkKrDlXBT3OD6r7ebjGfawnSApfgxq9QhdZzdzys2Ns2Kd6yP5uMU1X1LvM192SG7AI3TuYCvsTwEcTQJBiydMSnyfeszDb4brPAPJ7)u8y6KCmZNVDmSvEwml9NPEw)Oz30mV5dvGfAXtPXUODuUq16V6Q4fBsH)5tHICOE6LoUv84zM7PTmWysOmYEIgPYDcwAsiIgGu1G5LGRUOg6TslyOqUAVcYUCCWqE3n7J7TOX7c9uSPqZAHb8iLKu7rifS4Ocy8PE26RClycl9uMnYWfzVRg9jDYOZi5PvkKVuIUwROLASfgsxDIN9o4ohFSwQWtUlNsXAxHg5puzPtEgjC2LaAxzN2ocezgnh4pl4UcpUdANZTWeBnl5GFvbwRuOpW)9aT3wAotkktCg9REnWL1tGxMVFNvPIdl)jEPkyUNsZ)K8WZJfnRjyjJA62qZ6RuEJNyvqu8cWjlSxVsPqVZcVpWeoUydrq1w0O6Sx6vRXkNaILzxqk6MgfVyoevMz7rIPCHwdBAV)vVdcMSmlzhHhdrEgrCPKM)abRF7h)4hgEy5)Qjpd80XSoSKNhgmzMyYhLXYrdpvMSNShXhpCrlfktTxIS5rVXxmJ(ttGZEBAScpGN06X2(GK1Ukit3Pd4xOm7csml8D6raPgYoebtiiAtG2nriD9)A9hyHsTkVS8ejD8AmIwyEPDZFexxek1dFAKQwPtEz(Cf(SDWUisp(Lt4rVsBHiwqRCDd8CJqt4XpjYlcYvHzqz6hVCHRA6B1ai2Y70ikfSAD4rxBbr6lVi9DKAewxnIvVFq3ktSucO1donH070cthuI(DQ8PLRCvLx6(0ygNV5jGHmsdKTwDeu(HNrRFrjArr)JGHlkKzYYl2IjnmnFd2om0USjw40b62oTxJOV82W)nTpE(qPUK0jfzk74O1gzdVptWq40Qs7Ef1x30TgGB6rVZs4a8LWcA1zxYnWtmAJ97d9Pr(U45Hckp1wL1vZL634imvAn5vPqTM)AS1EbGZsBnv2r2vDUjCMUw3Tt0DhKAhHdCr35ETLSkyfMa2sz0Js3(CJ96xf6RojSZShtD40RR)YAe8TMjEszpOz)ZVN2C)4YZJtr2q4koQY3(nvTTiT9ztTOD0)lUZJvtQkDFcwxJoU2Gn4Y076isbWwXk5J(YMQUS1jfekenx1Rvxfg(wzvryAqe9lsrFP(nqyBlu81f9qr4UsSzUiPKOQIC8Z(ijc8vOcyNsu7xXoxjIcTMybpMJzmsyLTyQgAYNM7BTbcChtrkIqrqS0aUH)R11v1fy6OL5S1)Aq81Vwo)4BhMXb1V0e)lnmsZSQBN3EJxXH3QCoFacVPmkSiaBy2Ykq3KYTI9ZWZ1rQeY(EqTUfn9gb170EUWZjxRGOry1jqQTekIpZfLBK2weI6MkDen5liBaSCGiACae4r89KIO7siRDvlgnrupVuxeKlyLXnQOMKgSjSOa4ZLfVft9)rgWVgjwO2eVXOYsRr7nfGQhA(axtcE9q)D2LgZVxqOOn37sq8V1a8)a7R8J2Dk8pfiEK(1L4BGLPKSv3TQUAvnEzQgwnE4DHLyRHacdzpgeVR09jgtkYiSn9YH7158xx56v(l4XPZIc1nEn5PGxtSWlS3dRAAWYUkW2CrJy6WVE)DTmOxd)MzqdhTwzSJauXjL7cRIOEXCeDsTrYYPrey2R69oIIvCHNYQOAdw2gkvYEXUlYj7Z0G2nA8anrSK1Sd0GXFFb6vIODuOjebJj9p(DriP8ipPC9nD5MYhcefmm9oS3jCfRsT50G)hQN4zNPcDAxXKQk))AgvUVAT1C0XAAbiikmrlltVizEAXoUBMh3g3tRMiTVWwlDPQBu6eM252Dv7bvkPHeDp8Bxs2XV2HFv(qY6QGY0qKHQTufBNsfvNR1B3yHuMdjzD)608aukKQTgQGXNaslUgX329BaVdclWoRe0s9rKxnzlwOaol9l4Fj3Vap8mlXh4FjoH1v5BdPnMp4wEg4w(Wd)6)G21Rt)b6NhkSx0h)cNXU8cMmG7hkOFWI6p(ZdKq(1UHSE)Ryaz3n3IjKV2nKn(qtnaTNpd1Je2Nb6XBCd5M2GXaQ29hZrcXNef(WV6GZs2X8NgVLjhG3kaiWXolrqx8yElEG1o4R6chjn2xDN8Y05U8uDq352FpnQUhjAnJXMmfUmM3bUfrfdob8Y8UQZ0ojqYox4XYDC(KL9PB7lNg3kCTRlSbW9x44JChEUW8NpATAfWnGRR2k5i1Z)8a1ZavWdK17(edi7U7vosiRK9zdW6i51hPwtJMLWaUEAIJJe2NrzK3(mI9EG9ze7)()ISyX2TXJCVDM1t0yB81jewGF8ZUpe(3IZMteJn5z70K2lEQ2(S2YZHy9ytU3orVN(547E2uPo18IxK4i78zjHV)uEzb9jEGUDwPSGUZL0MZySCO8ItYFmZtFBPcW(A0FwaSUb9y5Y7M4Dbh7o8FUNelEgURhQ5RWa4oZLrhSl0VZ5tJB5)C9m1J)npPOKB1tKZaK94LWzaYE8o4mEp6zhEY3JJ9fy7tNO4d0QvF3aWUkmVQu3Vqf4qG9grdtWMJkOif9BQjclV6iCCeKVob7n(V5WYZ0a04WVY)3dLzU5YzVsDyA4Ef(MOgUxTPpCxznyfMnE0vjRNzxS0BNCTBy20QK4l61xU9796dMB4YZKIhcJURUoohtrSPdpKDdB9VXihGEcLcXYC9nt9G9AzA2fDMbKMuEdCGFdo))eN7VKz2PexMjPEFd2oxvp95YPe0WHdN(Mi6FHEV0G71FrJ5svSruoSRWQYotRMyxr)4vM50hZE9nQv2(9kFyw8z6K2VjNUNdyxvhXWB0pE28fPXrs5x(1nt61)cwPOu(80GFZPcY97zR1Z3M2GEShB8nTXpx6ZNYb73lrIzasWWbRHLzpErQuhuMcSqdJDUZ9CTXu65Z8iD0)vHz)yXVqC1YU3oBYLwkvOV(L2NFwpyD7SRh1C5PZdYVgCp8lVf0fZOmFLhHI(PCMvY2bL72zQvJ7LwuPxYyZ0)gO71NtUAQOY(9oz)hWjH(MELWZDpzb1Xlkz(8nOfpbkw(Uz0XnjQpTJbhzp3NKBU2Ij5yhkINaEYUzPwTyDkGJEzTNNNiSvo2ZjaKQOhHVUd0q)edRE6Mtn83gAGoCxUqnIZT6AgqE7yHMfNZ(rkb6R3qtuL4yoN90m8EfBkcY4uoclSDd4i4eGh(tFyh2nSDH0EAVgfyzmNcvLy0aGvRc3j(qdZxDz6dxqe6o6SxWsX1xQ9Xpydb64hu93nM2GQpsB4cYDmvmcZAC3LIRZy9Y9vADaiJoA3Vn3oECp)Tc2(9A9eYnJhBSxaMPxFeCxADOPDZSPGBE(LsNnz)ENFYfd65a7NDTncz177u)ID)zCiKG)lBGMzJUmFvucnYojbmL4kJRJglVQX83Z)hIpEoF2hmz2NnLjjI0kLZwPYNR09C4jcxLL)Ps2nJhE9afRxFDgVyDsno6dCpB)XOi4TZS(D50fJtKCmzXUzYGZiQ50J8x3ZN4M1(Qo7VUAnF8GnZHAMgXe3dkcPiHT4ZxK0Yx7z3LnfWX3HdtZw3ZvRJdyomyCCahjx)LpfUoUZeCg0nHn7697p2rZ1lThlx3mdhjxiiS57NXhfx9An8)EE(QdVDCJw6))1i0Qt1fhVU7E9D5RKQFsFlO8E)(lCKGyN6AUz2y7W8Lc82D)N8rMtgl(LMIr2bn3hN9PrLdMx9PrLlHrgc6CeA1j8eUmQfDL58QQbkGd(AHyr17Q60geFiNIzmHa6DH5x5HkqV0kxUn(lA(Pfls5M1CPA)EhdrQbM7JrRKq5tD8EICQPW(WyOmss2LTjtZEOZ(1EWTI02znEPuYT3TZEJ1bG91tsX7ol8pqR0s8RKn3ibRx4oskzkjDolO61V)PzaTvBXUnFpON3VfZgTb6BV7tO3i9g04JP6nba9wMvtoUu0YSTZHHJEkUvxZt(AYFOAnNo94UKrtznILuiikIEQ0dRVDAlYH6Ht1sGHWxVogFqmtfwJfPE99EB2clwNi5xio2VRXveeA7ifNl8SQBhpz0x4bZ6KPMxpNUVPXT1YU6k26XJSc)FQfgyw1pCtz2PS(4HBy38v8pD3QUz2eRTtHJ0X5Z4TB2qZISQYK7Eib5oBdJhXYR7ZXG(X(UvTiU9)sQI7GEMmaonzdqOLSMoq8w23O737Zx2jmNN(koFDmjNw1zNpwGMb(BELCo3mBBs2pyFZtlmS1q6bljI5kVXLtQUdxWOmmJh4nQzoL8zyu60jvYXbpj72PJEPVrRJ7mcyCuB7KEwMiowodQM)ETecBviblhy71VfRU(8D1vyo91IZzYLJVEqBIE3AR(Rz4X0XzOVxbtpKEHOmZgMUR(kcZpRtJg)oa3T)VS30X0uXufOFtG9VOLPpZP7RKO(7UQkNTL8t5SEX54W29OI523O5BSYaIPJmOypCyUDYipELHLCYLNkNOZ9UZyGm2EVXwyHvkJvLgFz0NNlUZHb4BGL)s80h9T2X2XgFkYG6nMolMWzQOiLoMIEwAieZFfRNih5kwEAiMYkwo3PnyvmFkiPhGZ7awOqDniumUKDMAaDi6FiL4cw8GSnMyk2usRRcJJrI5KdX9M1IABJrDceLVTb03yXR82oqSwgqiTqomgCjaBe4hqp9DEY1DS1EhyiDeYbdrUW7adP9D17C6W9XLNZ1whHio5galBh7C9WhcxEfDQxmtm6nusQLZIQ6)tKWedNnz0rUPto2n1(ZIW5MQ0alFvhxenhFMo)zMhowe9wXQn1VBBIZ5R3VVFBFbdYqXTFKiHzolMjymQnW27cVGTxl5r0KqCPvhTkSM4EepCJ2LCpL(CvjXyQFge6rTO7cVlSPzun44HIj0aNXs0NiYfYLNN1aenpC922gIxuzlo5xSP0IUt7g4pSEtZ0Zz(iVW3aBbNdfl()c]] )