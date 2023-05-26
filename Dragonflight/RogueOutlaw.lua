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
    -- Rogue
    acrobatic_strikes         = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by 3 yds.
    alacrity                  = { 90751, 193539, 2 }, -- Your finishing moves have a 5% chance per combo point to grant 1% Haste for 15 sec, stacking up to 5 times.
    atrophic_poison           = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, reducing their damage by 3.0% for 10 sec.
    blackjack                 = { 90696, 379005, 1 }, -- Enemies have 30% reduced damage and healing for 6 sec after Blind or Sap's effect on them ends.
    -- cheat_death               = { 90747, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cheat_death               = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min.
    cloak_of_shadows          = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec.
    cold_blood                = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by 100%.
    deadened_nerves           = { 90743, 231719, 1 }, -- Physical damage taken reduced by 3%.
    deadly_precision          = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by 5%.
    deeper_stratagem          = { 90750, 193531, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    echoing_reprimand         = { 90639, 385616, 1 }, -- Deal 1,884 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for 45 sec. Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed 7 combo points. Awards 2 combo points.
    elusiveness               = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by 10%, and Feint also reduces non-area-of-effect damage taken by 20%.
    evasion                   = { 90764, 5277  , 1 }, -- Increases your dodge chance by 100% for 10 sec.
    find_weakness             = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass 15% of that enemy's armor for 10 sec.
    fleet_footed              = { 90762, 378813, 1 }, -- Movement speed increased by 15%.
    gouge                     = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for 4 sec. Damage will interrupt the effect. Must be in front of your target. Awards 1 combo point.
    improved_ambush           = { 90692, 381620, 1 }, -- Ambush generates 1 additional combo point.
    improved_sprint           = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by 60 sec.
    improved_wound_poison     = { 90637, 319066, 1 }, -- Wound Poison can now stack 2 additional times.
    iron_stomach              = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by 25%.
    leeching_poison           = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you 5% Leech.
    lethality                 = { 90749, 382238, 2 }, -- Critical strike chance increased by 1%. Critical strike damage bonus of your attacks that generate combo points increased by 10%.
    marked_for_death          = { 90750, 137619, 1 }, -- Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min.
    master_poisoner           = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by 20%.
    nightstalker              = { 90693, 14062 , 2 }, -- While Stealth is active, your abilities deal 4% more damage.
    nimble_fingers            = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by 10.
    numbing_poison            = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for 1 |4hour:hrs;. Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    prey_on_the_weak          = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or Kidney Shot take 10% increased damage from all sources for 6 sec.
    recuperator               = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to 1% of your maximum health per 2 sec.
    resounding_clarity        = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges 2 additional combo points.
    reverberation             = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by 75%.
    rushed_setup              = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by 20%.
    seal_fate                 = { 90757, 14190 , 2 }, -- When you critically strike with a melee attack that generates combo points, you have a 50% chance to gain an additional combo point per critical strike.
    shadow_dance              = { 90689, 185313, 1 }, -- Allows use of all Stealth abilities and grants all the combat benefits of Stealth for 6 sec. Effect not broken from taking damage or attacking.
    shadowrunner              = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move 20% faster.
    shadowstep                = { 90695, 36554 , 1 }, -- Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec.
    soothing_darkness         = { 90691, 393970, 1 }, -- You are healed for 30% of your maximum health over 6 sec after gaining Vanish or Shadow Dance.
    subterfuge                = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for 3 sec after Stealth breaks.
    thiefs_versatility        = { 90753, 381619, 2 }, -- Versatility increased by 2%.
    thistle_tea               = { 90756, 381623, 1 }, -- Restore 100 Energy. Mastery increased by 11.6% for 6 sec.
    tight_spender             = { 90694, 381621, 1 }, -- Energy cost of finishing moves reduced by 10%.
    tricks_of_the_trade       = { 90686, 57934 , 1 }, -- Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec.
    unbreakable_stride        = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects 30%.
    vigor                     = { 90759, 14983 , 1 }, -- Increases your maximum Energy by 50 and your Energy regeneration by 10%.
    virulent_poisons          = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by 10%.

    -- Outlaw
    ace_up_your_sleeve        = { 90670, 381828, 1 }, -- Between the Eyes has a 4% chance per combo point spent to grant 4 combo points.
    adrenaline_rush           = { 90659, 13750 , 1 }, -- Increases your Energy regeneration rate by 60%, your maximum Energy by 50, and your attack speed by 20% for 20 sec.
    ambidexterity             = { 90660, 381822, 1 }, -- Main Gauche has an additional 5% chance to strike while Blade Flurry is active.
    audacity                  = { 90641, 381845, 1 }, -- Half-cost uses of Pistol Shot have a 40% chance to cause your next Ambush to be usable without Stealth. Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time.
    blade_flurry              = { 90674, 13877 , 1 }, -- Strikes up to 5 nearby targets for 519 Physical damage, and causes your single target attacks to also strike up to 4 additional nearby enemies for 50% of normal damage for 10 sec.
    blade_rush                = { 90644, 271877, 1 }, -- Charge to your target with your blades out, dealing 1,557 Physical damage to the target and 779 to all other nearby enemies. While Blade Flurry is active, damage to non-primary targets is increased by 100%. Generates 25 Energy over 5 sec.
    blind                     = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1.
    blinding_powder           = { 90643, 256165, 1 }, -- Reduces the cooldown of Blind by 30 sec and increases its range by 5 yds.
    combat_potency            = { 90646, 61329 , 1 }, -- Increases your Energy regeneration rate by 25%.
    combat_stamina            = { 90648, 381877, 1 }, -- Stamina increased by 10%.
    count_the_odds            = { 90655, 381982, 2 }, -- Ambush and Dispatch have a 10% chance to grant you a Roll the Bones combat enhancement buff you do not already have for 5 sec. Duration and chance doubled while Stealthed.
    dancing_steel             = { 90669, 272026, 1 }, -- Blade Flurry strikes 3 additional enemies and its duration is increased by 3 sec.
    deft_maneuvers            = { 90672, 381878, 1 }, -- Increases the range of your melee attacks by 2 yards while Blade Flurry is active.
    devious_stratagem         = { 90679, 394321, 1 }, -- Gain 1 additional max combo point. Your finishing moves that consume more than 5 combo points have increased effects, and your finishing moves deal 5% increased damage.
    dirty_tricks              = { 90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    dreadblades               = { 90664, 343142, 1 }, -- Strike at an enemy, dealing 1,271 Physical damage and empowering your weapons for 8 sec, causing your Sinister Strike, Ambush, and Pistol Shot to fill your combo points, but your finishing moves consume 5% of your current health.
    fan_the_hammer            = { 90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain 1 additional stack of Opportunity. Max 6 stacks. Half-cost uses of Pistol Shot consume 1 additional stack of Opportunity to fire 1 additional shot. Additional shots generate 1 fewer combo point.
    fatal_flourish            = { 90662, 35551 , 1 }, -- Your off-hand attacks have a 60% chance to generate 10 Energy.
    float_like_a_butterfly    = { 90650, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by 0.5 sec per combo point spent.
    ghostly_strike            = { 90677, 196937, 1 }, -- Strikes an enemy, dealing 1,142 Physical damage and causing the target to take 10% increased damage from your abilities for 10 sec. Awards 1 combo point.
    grappling_hook            = { 90682, 195457, 1 }, -- Launch a grappling hook and pull yourself to the target location.
    greenskins_wickers        = { 90665, 386823, 1 }, -- Between the Eyes has a 20% chance per Combo Point to increase the damage of your next Pistol Shot by 200%.
    heavy_hitter              = { 90642, 381885, 1 }, -- Attacks that generate combo points deal 10% increased damage.
    hidden_opportunity        = { 90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush.
    hit_and_run               = { 90673, 196922, 1 }, -- Movement speed increased by 15%.
    improved_adrenaline_rush  = { 90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and again when it ends.
    improved_between_the_eyes = { 90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.
    improved_main_gauche      = { 90668, 382746, 2 }, -- Main Gauche has an additional 5% chance to strike.
    keep_it_rolling           = { 90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by 30 sec.
    killing_spree             = { 90664, 51690 , 1 }, -- Teleport to an enemy within 10 yards, attacking with both weapons for a total of 4,932 Physical damage and taking 65% reduced damage over 2 sec. While Blade Flurry is active, also hits up to 4 nearby enemies for 100% damage.
    loaded_dice               = { 90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    opportunity               = { 90683, 279876, 1 }, -- Sinister Strike has a 40% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = { 90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional 2% per missing target below its maximum.
    quick_draw                = { 90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate 1 additional combo point, and deal 20% additional damage.
    restless_blades           = { 90658, 79096 , 1 }, -- Finishing moves reduce the remaining cooldown of many Rogue skills by 1 sec per combo point spent. Affected skills: Adrenaline Rush, Between the Eyes, Blade Flurry, Blade Rush, Dreadblades, Ghostly Strike, Grappling Hook, Keep it Rolling, Killing Spree, Marked for Death, Roll the Bones, Sprint, and Vanish.
    retractable_hook          = { 90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by 15 sec, and increases its retraction speed.
    riposte                   = { 90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every 1 sec.
    roll_the_bones            = { 90657, 315508, 1 }, -- Roll the dice of fate, providing a random combat enhancement for 30 sec.
    ruthlessness              = { 90680, 14161 , 1 }, -- Your finishing moves have a 20% chance per combo point spent to grant a combo point.
    sap                       = { 90685, 6770  , 1 }, -- Incapacitates a target not in combat for 1 min. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    sepsis                    = { 90677, 385408, 1 }, -- Infect the target's blood, dealing 5,776 Nature damage over 10 sec and gaining 1 use of any Stealth ability. If the target survives its full duration, they suffer an additional 2,126 damage and you gain 1 additional use of any Stealth ability for 10 sec. Cooldown reduced by 30 sec if Sepsis does not last its full duration. Awards 1 combo point.
    shiv                      = { 90740, 5938  , 1 }, -- Attack with your off-hand, dealing 419 Physical damage, dispelling all enrage effects and applying a concentrated form of your active Non-Lethal poison. Awards 1 combo point.
    sleight_of_hand           = { 90651, 381839, 1 }, -- Roll the Bones has a 10% increased chance of granting additional matches.
    summarily_dispatched      = { 90653, 381990, 2 }, -- When your Dispatch consumes 5 or more combo points, Dispatch deals 6% increased damage and costs 5 less Energy for 8 sec. Max 5 stacks. Adding a stack does not refresh the duration.
    swift_slasher             = { 90649, 381988, 1 }, -- Slice and Dice grants an additional 2% attack speed per combo point spent.
    take_em_by_surprise       = { 90676, 382742, 2 }, -- Haste increased by 10% while Stealthed and for 10 sec after leaving Stealth.
    triple_threat             = { 90678, 381894, 2 }, -- Sinister Strike has a 10% chance to strike with both weapons after it strikes an additional time.
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
}

local rtbAuraAppliedBy = {}

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

    local aura = rtbSpellIDs[ spellID ]

    if aura and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) then
        if IsCurrentSpell( 2098 ) then
            rtbAuraAppliedBy[ aura ] = "dispatch"
        elseif IsCurrentSpell( 8676 ) then
            rtbAuraAppliedBy[ aura ] = "ambush"
        elseif aura == "roll_the_bones" then
            lastApplicator = aura
        elseif aura == "keep_it_rolling" then
            lastApplicator = aura
            for bone in pairs( rtbAuraAppliedBy ) do
                rtbAuraAppliedBy[ bone ] = aura
            end
        else
            rtbAuraAppliedBy[ aura ] = lastApplicator
        end
    end
end )



spec:RegisterStateExpr( "rtb_buffs", function ()
    return buff.roll_the_bones.count
end )

spec:RegisterStateExpr( "rtb_buffs_shorter", function ()
    local n = 0
    for _, rtb in ipairs( rtb_buff_list ) do
        if buff[ rtb ].up and buff[ rtb ].duration < 30 then n = n + 1 end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_normal", function ()
    local n = 0
    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and rtbAuraAppliedBy[ rtb ] == "roll_the_bones" then n = n + 1 end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_longer", function ()
    local n = 0
    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and bone.duration > 30 and rtbAuraAppliedBy[ rtb ] == "keep_it_rolling" then n = n + 1 end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_will_lose", function ()
    if rtb_buffs_normal > 0 then return rtb_buffs_normal + rtb_buffs_shorter end
    return 0
end )

spec:RegisterStateTable( "rtb_buffs_will_lose_buff", setmetatable( {}, {
    __index = function( t, k )
        if not buff[ k ].up then return false end

        local appliedBy = rtbAuraAppliedBy[ k ]
        if appliedBy == "roll_the_bones" then return true end
        if appliedBy == "keep_it_rolling" then return false end

        return rtb_buffs_normal > 0
    end
} ) )

spec:RegisterStateTable( "rtb_buffs_will_retain_buff", setmetatable( {}, {
    __index = function( t, k )
        return not rtb_buffs_will_lose_buff[ k ]
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
            if talent.subterfuge.enabled then applyBuff( "subterfuge" ) end
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark" )
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )
    end

    if buff.cold_blood.up and ( not a or a.startsCombat ) then
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
        if buff.grand_melee.up then
            if buff.slice_and_dice.down then applyBuff( "slice_and_dice", 2 * effective_combo_points )
            else buff.slice_and_dice.expires = buff.slice_and_dice.expires + 2 * effective_combo_points end
        end

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

    if buff.cold_blood.up then setCooldown( "cold_blood", action.cold_blood.cooldown ) end

    class.abilities.apply_poison = class.abilities[ action.apply_poison_actual.next_poison ]

    -- Fan the Hammer.
    if query_time - lastShot < 0.5 and numShots > 0 then
        local n = numShots * ( action.pistol_shot.cp_gain - 1 )

        if Hekili.ActiveDebug then Hekili:Debug( "Generating %d combo points from pending Fan the Hammer casts; removing %d stacks of Opportunity.", n, numShots ) end
        gain( n, "combo_points" )
        removeStack( "opportunity", numShots )
    end

    if not dreadbladesSet then
        rawset( state.buff, "dreadblades", state.debuff.dreadblades )
        dreadbladesSet = true
    end

    if Hekili.ActiveDebug and buff.roll_the_bones.up then
        Hekili:Debug( "\nRoll the Bones Buffs:" )
        for i = 1, 6 do
            local bone = rtb_buff_list[ i ]

            if buff[ bone ].up then
                Hekili:Debug( " - %-20s %5.2f : %5.2f %s | %s", bone, buff[ bone ].remains, buff[ bone ].duration, rtb_buffs_will_lose_buff[ bone ] and "lose" or "keep", rtbAuraAppliedBy[ bone ] or "unknown" )
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

        startsCombat = true,
        texture = 135610,

        usable = function() return combo_points.current > 0, "requires combo points" end,

        handler = function ()
            if talent.alacrity.enabled and effective_combo_points > 4 then
                addStack( "alacrity" )
            end

            applyDebuff( "target", "between_the_eyes", 3 * effective_combo_points )

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
                gain( shots * action.pistol_shot.cp_gain, "combo_points" )
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

        talent = "roll_the_bones",
        startsCombat = false,
        nobuff = function()
            if settings.no_rtb_in_dance_cto and talent.count_the_odds.enabled then return "shadow_dance" end
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
    enhancedRecheck = true -- needed for variable timings.
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
    name = "|T132282:0|t Ambush Regardless of Talents",
    desc = "If checked, the addon will recommend |T132282:0|t Ambush even without Hidden Opportunity or Find Weakness talented.\n\n" ..
        "Dragonflight sim profiles only use Ambush with Hidden Opportunity or Find Weakness talented; this is likely suboptimal.",
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "no_rtb_in_dance_cto", true, {
    name = "Never |T1373910:0|t Roll the Bones during |T236279:0|t Shadow Dance",
    desc = function()
        return "If checked, |T1373910:0|t Roll the Bones will never be recommended during |T236279:0|t Shadow Dance. "
            .. "This is consistent with guides but is not yet reflected in the default SimulationCraft profiles as of 12 February 2023.\n\n"
            .. ( state.talent.count_the_odds.enabled and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires |T237284:0|t Count the Odds|r"
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "use_ld_opener", false, {
    name = "Use |T136206:0|t Adrenaline Rush before |T1373910:0|t Roll the Bones (Opener)",
    desc = function()
        return "If checked, the addon will recommend |T136206:0|t Adrenaline Rush before |T1373910:0|t Roll the Bones during the opener to guarantee "
            .. "at least 2 buffs from |T236279:0|t Loaded Dice.\n\n"
            .. ( state.talent.loaded_dice.enabled and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires |T236279:0|t Loaded Dice|r"
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "allow_shadowmeld", false, {
    name = "|T132089:0|t Shadowmeld when Solo",
    desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
    "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled = not val
    end,
} )

spec:RegisterSetting( "solo_vanish", true, {
    name = "|T132331:0|t Vanish when Solo",
    desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Outlaw", 20230526, [[Hekili:D3tAZTTrw(BrvQbMmsIMhwYjzj1ujYjzs2mz8ALS5BeceaKeRab4IdjRuQ4V9596l0Nausu2z3QMdlGgV(1V7JUBoF08FB(vrbvXZ)1Xdhpz4zJpFWO3o6RMmA(vv3VnE(vBdcVjyf8pYc2a)V)R6Q0G7WhFFAEqe(5L51fHWRwxvTT8BE9RxLuTUEXGW8nVUmztDAqvsEwyrWYk8VdF98RwuNKw9tzZxyDUh)1ZVkOUADEX8RUkzZLaKtIIIPdpUmC(v4WpD4zNo(8Vz317U(dXPbFC31FxCqyE2URRYH)76y8b3NNfb)rYMKSv7UUeErs1URJYJlZEf8pUnilPC9URbulUy31RtQQidK81BlIVnjVUC31lQRQYZgGt1VxgtHrYMnXrjaYNEV471(SGfjPjv3)FGtiz6Ula)YL58H(Jx(UJ29Z7(z(Yz0Bilhy5E7aLNpM88VnkY5IuA8JpD0z8XhdFr(wK(t)IAe9)2OI4SG0Km4F)HAC9Vigqk8VYtt5GnplgwdjzS)oFBCgUgtwU76Fby8iKFxsisnGHvfKgNvfhDcDAwvhuea)n82Q7Yrc4YLLe63VTgh(D51PW3VjijdjFlIjyg8Kf3J0N0BiG8gcV4Y86Skgs8VIIq6kYtLXbcKVcNnQ0jWP3ghMalX)mGU2P0a4B7faWknEzvFcfJrIsZxLesrDK9fJt4)nt2qqbwMuucpF0qam5avaKVxGqRhoIWaKYIpocegVNs3rkwFjoZKthnHWz(9TOy)UR)NWCaZ7pwKayuEr4AKoakBdMFvAszvjQDH6kOA2Vsuvbg3I04O5FhOIeIRjq9lEBzs58RcVpmn2VkOyvm8LWWVkSibKltcavzYthakcWiY9JsGj)cyTmA31EikJmOblIRUlooZhwT(X3hxoOE7URF4bGRKxwsg4YKvRR8lIrgh8KPieO6KfjBPyZ3HOBCr58kqRwdJBWh2mUADEzv69(Lvfj3epObWZ2D9eYm2JWltt5RRblsb(U)Y06II7PdCmdjracs2brKHqX((eGCe7TL1lG5FznqGXx6HczwOlampRH8QIJ4YAIdgrWMfG2Kg94FaKmuQkjhw8ag)TKbbICe1puIly7wuj4hsqX6)io4gqXdfXkqrSSY6nOkBDuqi89V(kcZMUEA0BFpiSKNIwoYRKjZLXedALdOOMFq293fCpLE1JR1oGAD1pF728IQ6myAgWwD0rYg2nXXB9ta2pyKaaAZy6Z5ueICadvBKEiKEcE7t(3QVWGNeMNNgLFxMXeI827jtNewTeiB(3XOAn4uJuT6aqaJ8W34GhULqj9ljesfg5FaE1Aye7U(4Dx)pieoWQtdLJ88FiGBZ4FeaUjkoHz4vMnXT2KhkduGbrCxf3iOGC7mC8b3gKKIiSQInLkeqvBxtMpfYaBec2IL31MaGhJpj)sgJ6iBC8wv3eVzDaWi8JcYcX3HmKZE0meIR4FSaSyvEdXQXFKeEdy5HRCO4H(oc3tHrvNLsu0kQZYiEA0zBY0zQ5kXK5FhDU4lSEK1w3mdRKsHUGf4RyRDWzG0psSo)rtSOsVwemfMyuOnOFTnymvLvq4FmRrOR)7IrAjgLay3KnM3aI8x(EMF531ybws2f4XpkHwxIC9S8kcksnBB8oa)8zVxqLLFVm5DmJ4(wNETE64ngRqU)28KmWfwu8YKqmsWlili4)mIy2Gb()3AG37hveCNIj2V0L8feP1n6E609dQlI2Lj)hTkms7Skgce0VYjb1o62aO4W1ajBfeXb4aDdiFHG7RDcU2C3TNl8NHxf94aauD0WhTI6VB6OWITluv8sw8NVpVkoleTXrZYi)24IWaGJGHFU6Eqh)U1OxQKkUQB8hb8aTksg2LV)eQ(nDy1LeJH)xOuiQoJj7PWXE6Ab9440Gfq4Y(Y6bSNxeVcXHVKzSJjkYMrGCVnpBtqzL28zx7cJnKQyrJUTaYyOmjkwyZTf9nPxB1XPvxFeRhJiHPlInpbsIaqxE0JsYcOQbW6xguNwzl8EfPIpedqjifLdqw)wiG8eyGajndII426uG8fqEaqi3KWZCJMIIKMjdk2coxz((ji5TII6TO4uwtizSawttZXCSahSerLeCW0zOKlTwToOQzAVbOWTf5CjKXRggGjbtNUOemdGDx)9zfqQrWkC5Y4qGrBjFc6qjbj5htgol6c9W9Y3sSw0Gb3gaWHeB1TbP1XcB9Hy2Ne58Ci3tfzam1ek5mocfOXm5AcRLyECtCAKw4UwmBQSUVCDmXHl3zBagFpYlrx3qQcf5GPqsYJxXLiahC4FtRRqrYQvanrufdZ0NxKNvxswX(0s6iwf(Hv52IfRvQfhkfvla70yS62Tx42YRUSUrri(abS4AjlkHiMjyt4SIewHlCHNolk97BGAkEaVPgY(eC94hwaADlqmYsQLvf1X(lIdqkVkhpLuOci1sodN(ojeFMeItX66Ie4tQaVIL1fcCNfJiIlGGvCJHmNRwNyNNlKZw0LVWSF(sVR0mLSj7sRuxz6BJOYlbP2eIyQm)NWes9o(b6us9gQR4ie54R(bnlzrg19KyS(z5fBWzg4VdjlYMxLMNTcRM2fuFuczPEU4KTZg7wi1eWIqFbVVt(AjbwLzX5OkQRwJ5p5VTiomPeONUhRv0tF09De(9Zq6RtrpRjjzjR(tevWj5pbXb6mrKuisqxHRpw(pxkwH0iXa)vW)79vRjdpoTSXfZrYseyKzGybewKtsgxrXYhT76tBbys2mi0zHLstxsuV8EMH)ZlCIEW8i7Pi(jYGOcMfbjr(KQUoiavNLLmgXQUN(yAmNR)g0x5PTau66)CU9e71fDSWoDB1(CSU5MBZtI4IhL8aQBszMKk86GBJ514HcnQjNMYmdZd1euawW)7OJphhny3B7oE94LshimhRmnw9zY7wLMVii1wUsDh3Z(xwqh50s9M1KoBYgiMLBbNm00IAGH7aZjp(waE51L(lZXWnR3kERRS8O26OjsWQI7qng03NH(tzSKGmwr4cdqQhVEBefD6lKdMkqkGlE4WYc4mKjK7DXA6FDt(LjQ0fb1Rs4wFsTm2gJgzoL71y6FN82ZjpIrWlR3SbaB69(y4WbvHy8PYvsGjztJJo52yFZjvE60OH)qcRNzvK5T3z8q(VIpVytz4t8orRH6tlseX167XwF8XthrYnnbghXqjwTOvqmpKEPjeMRUlxMoVKm9A0z9CN6Mo3Atf4MhTzAbSomEOKyQ8NQA5swj4MeI)cGGwaXT1M3Nnq6GjBXm5yih2snstZ4RbkHkeZtGqFXuKaxWrXedoanRa70jAE5Y3bdSCnTzByt2kVhSXhXzyFhI67U(hi4UmnwEn5JFdHi3AcJyBoWjUPrhcTfStwmhLMjJqZzPUjDMxZ77gMbj3W5cqQ4gwAqyINzRsBmZjyYHbOltYF4JtQsPH2Vm1O9DtnViYI3vMRMZPeacJiTbBKE2NkuUFj)UUjCxrqsqXcDsVFRyryQQP35AbQNZNfazO6jWJI6mNeb6xrMdxLTUvIiT)N4N7UWS2RQegB9zeTq5QljvNUIWGm0VFrbOJsMIVsU4nS3VTMe0MCLB(1rFT8atrx2L()p1rR2GqsDSJhkp2fbR8Zxc52LaP5BupimyAsnBevesGmyxcrB0L4FPobkWpVQcEdO9IDH(o0Otv(ht0)gD5zMtSuWIZAWoW26)8ptHOhZ)Oegy5L8sROxFj1jZvVDa3f3GOAEbW1cWpRHL6Y27zsej)YyuyeiJGN2wAlsGydp4xq6qRrkcnbPOou1iEerEudYzPr(89eHNutlXq)izMQLLZuIhbPK8BzGt0krGwMK9TscMyl5jHcQYKPqN33516Ko2wkbcHH0KWysomy9fuN0LqodRPEZSvzdrAih5IQBxmGQfXLcBztti7ItVYJCzydPeP0HILQDXEeVSN22yqeNSurAuIKGw2s3BGI9WOCiir6VinppYMc)Jcu8ajTvk1U84WuD09)YkGA3DSXDRyoYr3y0QVFB8fPsJl6Atf1XDlcpg2tuRGlZuqPToDPBFXwzj3pJrQbTZ2im9BxQXPmylHYc2fwfgHDs1H2tRcxeal3EpHMDp9AGYIQ2A51670uwRsKh5aCEUQ02XUQ02XDvPTJDxxmwH4UqVmVwk8IwLHrg05kRETQJAZ7QffsJa6vm8yVzXYXuXRpcPD)W64nK1BJoDr(QAAnO0KWEnXPsFDjNcw)r1DyRW5AaFaVcRD3uM9UGZYIgAriVxHLY(gFwm(UJnLwJRhLTX904LNfwqFw0iwSnOBMrp6lJ(FiIPXyKn7elph1qdJ9EOKdKgrS2IyWmGqIXVqiv5rdGi)ABlo6UcH2qWPUQFv7v2YrzyCQmP3w1LKI6vYARx9wi5(YSKTX8I6LfZtopfslet)73(T3nGTTJPLtm6EAHNjTbNKMCgTIkceL0lFai51vSDu2LVFWClvd0nz3aRX2mtXCAg5eIiojIThBw8hHPBYWs(UD7FU8D0YAslHQjg1D0(tgATwUr1fS91R3JLz5MtzREDM(VXsXuHYGXboSvQM)5WHDwg5W1O8zjzxpOASxAYMBRmxpgl9gwk8AFF)61HhajxsY12AUTkf1MzDp5E)1IHDNrPkmx11Uerab9s1QqZBkh0CB19rlYgs41P1LvOjXWQo51tKlDOzSGnOX2CY)VO6rn(pHj0FznM1sdAjkGJyyXfLXf4gOxFyNlpSLjfX0me0g1Bvk9aeFszvrqQp6ruFOUTLNLe6VsS12NFfM)w(YL(q4KeB3uhPMJRdXLoKAv8XPTbZv8WzFpOl6YqlfiMgjxxniIUnYvSK(o629HSRlvBcDDjIzyBOJ3usmwpYL16fKtacQmsIcMC8pCrCTp2))lb(xZRI)MDxFL4yhDjESJiDYbTWkocm8trto58NOFepgoyuPuhi(XlFhVrf7U(NEf2oUc8ehHRZ1XOJ8fXHbe4IfT(vKjcMPSGIcSOTbOZVmWQcHVo21EcSee)3q6(rjKBdjau7jUzsSaAaOjh1e3njpc7(upVBpsyKB8OC1WjCb4kTyCrwggu4JTHa(YS4pFlH3YxbwqkCnO7Is4YfY47M4kLil764XW(MbvJgSoOe3VXa6MDVF02YULGbXHRktZHWzBMBebD1Wb2Gg)KqWXheeCSsv28DuSKU7bhTh4yRYgQfhqxTEUX(Jso0otGrzu8KxSx2pSjvI6300sm6jfuTTJ6YqDVI7cV925yRPr3J3TVhXBER5wwDANHyj1Rs7Balludj(JkLXDut7tr9CUk8Az7x3viEYV1GzkXX4nRYDrL2dzuph7qyp1Ab0gzukorlh2HPwEL0zDO)HMA4UgtQBOs7SvP6zyYu7RX27GU2sEap2f1JAFokVPGDQ8(Yh5uFtajNhRtlGYdsP6n92xApdIUeQBZU1uXH08ilYTSLvFzdmYuyvtlTwOT2TGPkHyFkiJHwDwLUxzt91EMO7bP8Pr5f8sQeSKFm1CxPljBLzZWg2ZLq1R1tRP8H5DiVYADnAYUVB4bLw7Mcvj2EcT1QqnTzR7hkY5oeYRO67PzzCdztftsF4YcYDoarLMvZpCZ9)H3t3ipKhGPasYdS58mEsZjuKagAGX0VjybPsA0thr8avoR1D0O40u7YeLCWZVrH6A5ujAZrNJdhPA4ADal2OenaZalLhCRTBXw8zA1UrtbxMaOfgShMW3(2XAf16Y7sww5xMgGsiQA0TVP7uLAvBKopalrFkAA0RATzuQCKOhUkJHOdClWhWXWUgog9giTPGcCFPcc7)gk8bCeq1IjJ(kwK)VcjlqKOf4sIUJZcQRY3aPlgrkRz2kGLT7N)fYrDF03q279WCrE9R4uirp1FfvG28fC6gmGEJ(y)UGOP1ani72CH(m8g7ZGsyoAa3Aiq7jCpiy(UF2chJDoZECCmhyPAgeAyO90l0x)N9cU(BDgudprN1z94aPd5ZFXXDhZGMltnW7Wv(Ec7dap9TV40f9zq0O8bIZ7G1(ZZNWh1HT4Pm5s(d6CovhRYu91V4ushZG2w1xd8o2i)gwLh6YqV52s3WKV7DUEhg4eBgShNjohQdU2booPi23OoDGZ0qpFCiSdFEMXvPHQUd8YG)95AgCg1NlQUROd1NVXoeiLJntxs0wCBDWodjgoF(8YdUWNvpI5BJPnrVK2)Jx5UfYEhzPF5E9C0E4lEZXA9A(uLs))3M0NVs(unLVgMYUu5paEaF5Jm4tVpwga03HiAW31wjYqZ3HQ4bG4p6RCy3sPgA62SSwdodq7WD5ba0JniiSw1y2kjb8D3TjdOpXb0n7dKb0ToK2m)j1oOdIzWdOqTRupLkgKU9Flv4DFDR8Ia1Mg(ObtZobTNqKxdxn4PxG(9eAhanyhq(GK2JHIa9RF2jY7aUprA7lzzbSgeWbJo4aUpr6WlF5bC4Q(zQ76aQha)eoGSu8rAG1stH2tyEaPYocM4GOr)zluOd4m4iKLdc9XbSpiyVv))KZP5REuE(Dy98GGJTodhek8lLpfxfD(5x6shq(jAL(ZN3QNpLWHTVdaKDy14LdYpJidF5TW9zRuMpBTqxLX8aWiDbA5DUUgGTTP2LTh)tetXiWElyXnK2HCYvio8AYEVmC(Vo(CYH4nFzsQ4oeOCGOYPhp71YhY8D)STr464LBF04Msg3rZNG7QJzwoa52)m(DDO1xQxRHtmohWZgn8KKLZm38Oxm(m7WuReAwa5eeImMHRkV9Wd2pQYEDC4WNoYRhTz22F9KhEOPBd0JK9SH9TVsubHLfYycPPni7GNO0dABeDkGfTj3ZAlY9oYXHOheI)c8sAJZ7Fk3ZLcmxwgcG6b52Sug449zjbYDFlvQGtWOrQuB3wLeW(j6sGug341ILQQQCkfpHS734s)QjZ71t70l(Wd0wQjFRQO8mXDFzFkhpV7B7r34zZH6fPRh507bBjie2No2RhTeZYN)x4zwnK)Wdh5SpH4cHvTATdnmBvREfl2xsJB2yMEV599OPYdcplyS1z2Z2etO2hYleXNpxXRN9iUF4bRYA9zCrlhP7hEOxptlzEnpIEHlEXSraZQNjz0nv0npxhmmJQxm5RzCEBxKInV19fOyZyA7ItegvFkt9tZ1w4(YU7sh8O9TT9E9SmYt7OV79bnBtJnepp0hREJgsvk(l1123ErNZ3oJCPls0V654Uo8IrJbRnghlApJXNKDQdq0F65OYO(wkeGmyidp1iEkBvUPJgtOOh47zp3Ke9D2otgRNtHWhEW25f(IzJp2i4ocOp2Wwbt10Y1tOu8FkxNj99O9T8IzNnKqE(mCf65MeQVZAzKqzY0fZ61tEZjE6O(t)79o)ugjZ222OpiFy)cg8Izk7ZXgdyFUU57CtAmAlnJ24(OSbwFSL2XqMqJTByLlgXf9SEjbsiqF(UD9Kjo63hgkHkIwI2Jqb7gEHyKfFb(d81J9EXRBylHRnBVDLlKdjqODP2jRTOaaJTMENObPuPYdt9MOdHULBuai4LZow53jbtiqUR6KFU2vtN8RuUj6y5FX)17QjhqcUI5Uq(bC6eLBGdAoF2CpmYZ9rHXUJJrMtPARrKsCY(pBytNnbYgXTQ5SXmbs1Dvcp6DLFQt8SSOMDMqx8t6pOxMegQ3fIgNvhoq0WT4a0Em39z5IiD0E46Vk)0DXFOc1Q9FYU6lMtLkV55(S814u4Vc)EBzYaK(5BrkKx1Kg9ypLtq9CNgeHmixRtrIDsCdRIPhzgRlRecV4)6y1jvHQQA7uH4kpBBecM8M7FASMoAWzY5b9z834Qojj79QMPmk)qcwEXmJNlo2NmkL874KOX9pGOM1aO71tegttFh6)L2RloEQa77yl(5UAbIQW0TgGLLRXpLuKuNSGcGO0xWRHUe1cSWbFl9N62tWIpJ33rZS41QBJZDBB(XyN8VG)Gr1PW2(R(RUNp5sBYrb9LG(piAyPrjwLuNoBKTC6mKD5XFlELE7qnTqBrQt73)jwuwIByGMpaI69yZ(qiernVQGA0uC3oc51pe(tF9Pto8iIaRCWtqoXugITKwMUkmshAATEG7bq)YFuUSov5vyD6E4blL0ZaB1ITGqCS8DEML3JYW1kVh9HokVh9LwpCH9VGx2wJsmjvB3lMDUdYnNX(PAZp)3MyGiTMCeUboj0wLlgihLK1RLI7EuhPyXqgPLjTAw2)ShEWi7s3tTgbPVNMMqJYJE3ebljDCTh23AUbJOv25Z4f8NoD1OpPeddHrZa7L2sJZwHcnxPtTzt1vr10QzKv5Abz7f4ggStsI9UepzOr5q534G2d(rBH6yDQIls3TFnM5vVDbT77de1gAnfA29i4xAA4rPWsDz7rt3PLe59CArshbAkbKPLfrtG0SS4S(k2D2lCl78wpXGSqVJ9eoQ0Ul)SsJNWRKNL7XzdR98BQpJ3iUC(0FJ4(4ZiWaLRGpIoZ(ExYPdk19KH(TV3js3JCu7cACRwehegvvRpZdp466mbSP7SCnx4OddSQW8x8l6T2j62Uv(()ee(2wu6xvCgbuQolA33BMnQcmeFUDdDJg2oMyELV9YHlV1fQuEc5stBg)sDtQ8LwRjQ7d(JDUXyNebTzE8(oZMN4h3ZmDZVyCJP1GssbtESEBv0VBM47VeWdYfJg61wTl5c6YHElhYM5f9w)hfojnzg4NT52ZDbomlhYXAzso1QJpr3Gut3X9YG3qcR1o4iT50DXeC740Z5TQ1EJu2spqp9zVE6ZJvUHLYCrk)1uJhlQmw)xM1wtvmLjMgfmOFBjj5mkNNcIPSdUSERnPUvUuKKpK(x638jsrblROACFK1FFk9NI0IBvVPJ5FGAXK670yGmLqUavAkHnmf7Kx2Emr)MdtsY2mywNl6UOiwVpW27v4tCb2RRBWRPZWyK7AuxmA8WNivPpZ7ZFbU3TAO10faj2Ev1hkP2OEbt861XfX103iicM9(Gz80AZvACsA57yVX5vOGxl19YYQvBtbZZKY(nR1uL4i86ERcle)vUngul2GAU32WXMBhllVKVHv0IOrxh6yZALYrnrZiAP)Eg1vLTroLlSQCcKnZAdYRK2UZTCG0NYxAp6pSPbg7zL4861rNo0cjXXpAtTP0tUNYM)V)]] )
