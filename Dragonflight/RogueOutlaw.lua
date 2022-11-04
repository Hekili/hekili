-- RogueOutlaw.lua
-- October 2022

-- Contributed to JoeMama.
if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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

        --[[ vendetta_regen = {            -- TODO: Vendetta regen?
            --aura = "vendetta_regen",

            --last = function ()
                --local app = state.buff.vendetta_regen.applied
                --local t = state.query_time

                --return app + floor( t - app )
            --end,

            --interval = 1,
            --value = 20,
        --}, ]]
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
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=2094
    blind = {
        id = 2094,
        duration = 60,
        mechanic = "disorient",
        type = "Ranged",
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
        duration = -1,
        max_stack = 1
    },
    -- Bleeding for $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=121411
    crimson_tempest = {
        id = 121411,
        duration = 2,
        tick_time = 2,
        max_stack = 1
    },
    -- Healing for $?a354425|a193546[${$W1}.2][$w1]% of maximum health every $t1 sec.
    -- https://wowhead.com/beta/spell=185311
    crimson_vial = {
        id = 185311,
        duration = 4,
        type = "Magic",
        max_stack = 1
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
    -- Suffering $w1 Nature damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=394324
    deadly_poison_dot = {
        id = 2818,
        duration = 12,
        tick_time = 2,
        max_stack = 1,
        copy = 394324
    },
    -- Bleeding for $w damage every $t sec. Duplicating $@auracaster's Garrote, Rupture, and Lethal poisons applied.
    -- https://wowhead.com/beta/spell=360194
    deathmark = {
        id = 360194,
        duration = 16,
        tick_time = 2,
        mechanic = "bleed",
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
    -- Talent: Dodge chance increased by ${$w1/2}%.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    -- https://wowhead.com/beta/spell=5277
    evasion = {
        id = 5277,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Damage taken from area-of-effect attacks reduced by $s1%$?$w2!=0[ and all other damage taken reduced by $w2%.  ][.]
    -- https://wowhead.com/beta/spell=1966
    feint = {
        id = 1966,
        duration = 6,
        max_stack = 1
    },
    flagellation = {
        id = 384631,
        duration = 12,
        max_stack = 30,
        copy = { "flagellation_buff", 323654 }
    },
    find_weakness = {
        id = 316220,
        duration = 10,
        max_stack = 1,
    },
    -- Suffering $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=360830
    garrote = {
        id = 360830,
        duration = 18,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Talent: Taking $s3% increased damage from the Rogue's abilities.
    -- https://wowhead.com/beta/spell=196937
    ghostly_strike = {
        id = 196937,
        duration = 10,
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
    -- Each strike has a chance of poisoning the enemy, inflicting $315585s1 Nature damage.
    -- https://wowhead.com/beta/spell=315584
    instant_poison = {
        id = 315584,
        duration = 3600,
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
    -- Stunned.
    -- https://wowhead.com/beta/spell=408
    kidney_shot = {
        id = 408,
        duration = function() return ( 1 + effective_combo_points ) end,
        mechanic = "stun",
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
        duration = -1,
        max_stack = 1
    },
    -- Talent: Your next $?s5171[Slice and Dice will be $w1% more effective][Roll the Bones will grant at least two matches].
    -- https://wowhead.com/beta/spell=256171
    loaded_dice = {
        id = 256171,
        duration = 45,
        max_stack = 1
    },
    -- Talent: Marked for Death will reset upon death.
    -- https://wowhead.com/beta/spell=137619
    marked_for_death = {
        id = 137619,
        duration = 60,
        max_stack = 1
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
    safe_fall = {
        id = 1860,
    },
    subterfuge = {
        id = 115192,
        duration = 3,
        max_stack = 1,
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
    -- Bleeding for $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=360826
    rupture = {
        id = 360826,
        duration = 4,
        tick_time = 2,
        mechanic = "bleed",
        max_stack = 1
    },
    -- Talent: Incapacitated.$?$w2!=0[  Damage taken increased by $w2%.][]
    -- https://wowhead.com/beta/spell=6770
    sap = {
        id = 6770,
        duration = 60,
        mechanic = "sap",
        max_stack = 1
    },
    -- Talent: Suffering $w1 Nature damage every $t1 sec, and $394026s1 when the poison ends.
    -- https://wowhead.com/beta/spell=385408
    sepsis = {
        id = 385408,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = 328305,
        exsanguinated = false,
        meta = {
            vendetta_exsg = function( t ) return t.up and tracked_bleeds.sepsis.vendetta[ target.unit ] or false end,
            exsanguinated_rate = function( t ) return t.up and tracked_bleeds.sepsis.rate[ target.unit ] or 1 end,
            last_tick = function( t ) return t.up and ( tracked_bleeds.sepsis.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
        },
    },
    sepsis_buff = {
        id = 347037,
        duration = 5,
        max_stack = 1
    },
    -- Bleeding for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=394036
    serrated_bone_spike = {
        id = 394036,
        duration = 3600,
        tick_time = 3,
        max_stack = 1,
        copy = 324073
    },
    -- Talent: Access to Stealth abilities.$?$w3!=0[  Movement speed increased by $w3%.][]$?$w4!=0[  Damage increased by $w4%.][]
    -- https://wowhead.com/beta/spell=185422
    shadow_dance = {
        id = 185422,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s2%.
    -- https://wowhead.com/beta/spell=36554
    shadowstep = {
        id = 36554,
        duration = 2,
        max_stack = 1
    },
    shadow_blades = {
        id = 121471,
        duration = 20,
        max_stack = 1,
    },
    -- Talent: $w1% increased Nature damage taken from $@auracaster.$?${$W2<0}[ Healing received reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=319504
    shiv = {
        id = 319504,
        duration = 8,
        max_stack = 1
    },
    sharpened_sabers = {
        id = 252285,
        duration = 15,
        max_stack = 2,
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
    -- Movement speed increased by $w1%.$?s245751[    Allows you to run over water.][]
    -- https://wowhead.com/beta/spell=2983
    sprint = {
        id = 2983,
        duration = 8,
        max_stack = 1,
    },
    -- Stealthed.$?$w3!=0[  Movement speed increased by $w3%.][]$?$w4!=0[  Damage increased by $w4%.][]
    -- https://wowhead.com/beta/spell=1784
    stealth = {
        id = 1784,
        duration = 3600,
        copy = 115191
    },
    -- Your next combo point generator will critically strike.
    -- https://wowhead.com/beta/spell=227151
    symbols_of_death = {
        id = 227151,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=385907
    take_em_by_surprise = {
        id = 385907,
        duration = -1,
        max_stack = 1
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
    tricks_of_the_trade = {
        id = 57934,
        duration = 30,
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
        copy = 394327
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
        max_stack = 1
    },

    master_assassins_mark = {
        id = 340094,
        duration = 4,
        max_stack = 1,
        copy = "master_assassin_any"
    },
    -- T28
    tornado_trigger = {
        id = 364235,
        duration = 3600,
        max_stack = 1
    },
    tornado_trigger_loading = {
        id = 364234,
        duration = 3600,
        max_stack = 6
    },
} )


spec:RegisterStateExpr( "rtb_buffs", function ()
    return buff.roll_the_bones.count
end )


spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )


local stealth = {
    rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
    mantle  = { "stealth", "vanish" },
    sepsis  = { "sepsis_buff" },
    all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
}


spec:RegisterStateTable( "stealthed", setmetatable( {}, {
    __index = function( t, k )
        if k == "rogue" then
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
    if not covenant.kyrian then return c end
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
        end

        if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff( "master_assassins_mark" )
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "combo_points" then
        if amt >= 5 then gain( 1, "combo_points" ) end

        local cdr = amt * ( buff.true_bearing.up and 2 or 1 )

        reduceCooldown( "adrenaline_rush", cdr )
        reduceCooldown( "between_the_eyes", cdr )
        reduceCooldown( "blade_flurry", cdr )
        reduceCooldown( "grappling_hook", cdr )
        reduceCooldown( "roll_the_bones", cdr )
        reduceCooldown( "sprint", cdr )
        reduceCooldown( "blade_rush", cdr )
        reduceCooldown( "killing_spree", cdr )
        reduceCooldown( "vanish", cdr )
        reduceCooldown( "marked_for_death", cdr )
        reduceCooldown( "dreadblades", cdr )
        reduceCooldown( "ghostly_strike", cdr )
        reduceCooldown( "sepsis", cdr )
        reduceCooldown( "keep_it_rolling", cdr )

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

spec:RegisterHook( "reset_precast", function()
    if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
    if debuff.sepsis.up then
        state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
    end
    if buff.adrenaline_rush.up and talent.improved_adrenaline_rush.enabled then
        state:QueueAuraExpiration( "adrenaline_rush", ExpireAdrenalineRush, buff.adrenaline_rush.expires )
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

    -- Ambush the target, causing $s1 Physical damage.$?s383281[    Has a $193315s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.][]    |cFFFFFFFFAwards $s2 combo $lpoint:points;$?s383281[ each time it strikes][].|r
    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return talent.tight_spender.enabled and 45 or 50 end,
        spendType = "energy",

        startsCombat = true,
        usable = function () return stealthed.all or buff.audacity.up or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,

        cp_gain = function ()
            return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 3 or 2 ) )
        end,

        handler = function ()
            gain( action.ambush.cp_gain, "combo_points" )
            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
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

        handler = function ()
            applyBuff( "atrophic_poison" )
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

        cp_gain = function () return buff.shadow_blades.up and 2 or 1 end,

        handler = function ()
            applyDebuff( "target", "cheap_shot", 4 )

            if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

            if talent.prey_on_the_weak.enabled then
                applyDebuff( "target", "prey_on_the_weak", 6 )
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


    crippling_poison = {
        id = 3408,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,

        texture = 132274,

        readyTime = function () return buff.nonlethal_poison.remains - 120 end,

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


        readyTime = function () return buff.lethal_poison.remains - 120 end,

        handler = function ()
            applyBuff( "deadly_poison" )
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

        spend = function() return talent.tight_spender.enabled and 31.5 or 35 end,
        spendType = "energy",

        startsCombat = true,

        usable = function() return combo_points.current > 0, "requires combo points" end,
        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 15, 1 )
            end

            removeBuff( "storm_of_steel" )
            removeBuff( "echoing_reprimand_" .. combo_points.current )
            spend( combo_points.current, "combo_points" )
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + 2 ) end,

        handler = function ()
            -- Can't predict the Animacharge, unless you have the legendary.
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

    -- Talent: Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by $s1% $?s79008[and all other damage taken by $s2% ][]for $d.
    feint = {
        id = 1966,
        cast = 0,
        cooldown = 15,
        gcd = "totem",
        school = "physical",

        talent = "feint",
        spend = function () return talent.nimble_fingers.enabled and 25 or 35 + conduit.nimble_fingers.mod end,
        spendType = "energy",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            applyBuff( "feint" )
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) ) end,

        handler = function ()
            applyDebuff( "target", "ghostly_strike" )
            gain( action.ghostly_strike.cp_gain, "combo_points" )
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

        cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

        handler = function ()
            applyDebuff( "target", "gouge" )
            gain( action.gouge.cp_gain, "combo_points" )
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
                if buff[ v ].up then buff[ v ].expires = buff[ v ].expires + 7 end
            end
        end,
    },


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
        texture = 132298,

        usable = function ()
            if target.is_boss then return false, "kidney_shot assumed unusable in boss fights" end
            return combo_points.current > 0
        end,

        handler = function ()
            if talent.alacrity.enabled and combo_points.current > 4 then
                addStack( "alacrity", 15, 1 )
            end
            applyDebuff( "target", "kidney_shot", 1 + combo_points.current )
            if pvptalent.control_is_king.enabled then
                gain( 10 * combo_points.current, "energy" )
            end
            spend( combo_points.current, "combo_points" )
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

    -- Coats your weapons with a Non-Lethal Poison that lasts for 1 hour.  Each strike has a 30% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by 15% for 10 sec.
    numbing_poison = {
        id = 5761,
        cast = 1,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,

        readyTime = function () return buff.nonlethal_poison.remains - 120 end,

        handler = function ()
            applyBuff( "numbing_poison" )
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + ( buff.opportunity.up and 5 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ) ) end,

        handler = function ()
            gain( action.pistol_shot.cp_gain, "combo_points" )

            removeBuff( "deadshot" )
            removeBuff( "opportunity" )
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

        cp_gain = 1,

        handler = function ()
            applyBuff( "sepsis_buff" )
            applyDebuff( "target", "sepsis" )
            debuff.sepsis.exsanguinated_rate = 1
            gain( action.sepsis.cp_gain, "combo_points" )
        end,

        copy = { 385408, 328305 }
    },

    -- Talent: Allows use of all Stealth abilities and grants all the combat benefits of Stealth for $d$?a245687[, and increases damage by $s2%][]. Effect not broken from taking damage or attacking.$?s137035[    If you already know $@spellname185313, instead gain $394930s1 additional $Lcharge:charges; of $@spellname185313.][]
    shadow_dance = {
        id = 185313,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "shadow_dance",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "shadow_dance",

        usable = function () return not stealthed.all, "not used in stealth" end,
        handler = function ()
            applyBuff( "shadow_dance" )
            if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
            if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows" ) end
            if azerite.the_first_dance.enabled then
                gain( 2, "combo_points" )
                applyBuff( "the_first_dance" )
            end
        end,
    },

    shadowstep = {
        id = 36554,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        talent = "shadowstep",
        startsCombat = false,
        texture = 132303,

        handler = function ()
            applyBuff( "shadowstep" )
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

        cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

        handler = function ()
            gain( action.shiv.cp_gain, "combo_point" )
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

        cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) ) end,

        -- 20220604 Outlaw priority spreads bleeds from the trinket.
        cycle = function ()
            if buff.acquired_axe_driver.up and debuff.vicious_wound.up then return "vicious_wound" end
        end,

        handler = function () -- Some azerite power stuff which is irrelevant but generates errors in Warning tab of the addon
            --removeStack( "snake_eyes" )
            gain( action.sinister_strike.cp_gain, "combo_points" )

            --if buff.shallow_insight.up then buff.shallow_insight.expires = query_time + 10 end
            --if buff.moderate_insight.up then buff.moderate_insight.expires = query_time + 10 end
            -- Deep Insight does not refresh, and I don't see a way to track why/when we'd advance from Shallow > Moderate > Deep.
        end,

        copy = 1752
    },

    -- Finishing move that consumes combo points to increase attack speed by $s1%. Lasts longer per combo point.     1 point  : 12 seconds     2 points: 18 seconds     3 points: 24 seconds     4 points: 30 seconds     5 points: 36 seconds$?s193531|((s394320|s394321)&!s193531)[     6 points: 42 seconds][]$?s193531&(s394320|s394321)[     7 points: 48 seconds][]
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
                addStack( "alacrity", 15, 1 )
            end
            applyBuff( "slice_and_dice" )
            spend( combo_points.current, "combo_points" )
        end,
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

    -- Conceals you in the shadows until cancelled, allowing you to stalk enemies without being seen. $?s14062[Movement speed while stealthed is increased by $s3% and damage dealt is increased by $s4%.]?s108209[ Abilities cost $112942s1% less while stealthed. ][]$?s31223[ Attacks from Stealth and for $31223s1 sec after deal $31665s1% more damage.][]
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
            if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
            if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
        end,
    },

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

    -- Allows you to vanish from sight, entering stealth while in combat. For the first $11327d after vanishing, damage and harmful effects received will not break stealth. Also breaks movement impairing effects.
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

            if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
            if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end

            if legendary.invigorating_shadowdust.enabled then
                for name, cd in pairs( cooldown ) do
                    if cd.remains > 0 then reduceCooldown( name, 20 ) end
                end
            end
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

        readyTime = function () return buff.lethal_poison.remains - 120 end,

        handler = function ()
            applyBuff( "wound_poison" )
        end,
    },


    --[[ apply_poison = {
        name = _G.MINIMAP_TRACKING_VENDOR_POISON,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        essential = true,

        texture = function ()
            if buff.lethal_poison.down or level < 33 then
                return state.spec.assassination and level > 12 and class.abilities.deadly_poison.texture or class.abilities.instant_poison.texture
            end
            if level > 32 and buff.nonlethal_poison.down then return class.abilities.crippling_poison.texture end
        end,

        bind = function ()
            if buff.lethal_poison.down or level < 33 then
                return state.spec.assassination and level > 12 and "deadly_poison" or "instant_poison"
            end
            if level > 32 and "nonlethal_poison" then return "crippling_poison" end
        end,

        usable = function ()
            return buff.lethal_poison.down or level > 32 and buff.nonlethal_poison.down, "requires missing poison"
        end,

        handler = function ()
            if buff.lethal_poison.down then
                applyBuff( state.spec.assassination and level > 12 and "deadly_poison" or "instant_poison" )
            elseif level > 32 then applyBuff( "crippling_poison" ) end
        end,

        copy = "apply_poison_actual"
    }, ]]
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

spec:RegisterSetting( "dirty_gouge", false, {
    name = "Use |T132155:0|t Gouge with Dirty Tricks",
    desc = "If checked, the addon will recommend |T132155:0|t Gouge when Dirty Tricks is talented and you do not have " ..
        "enough energy to Sinister Strike.  |cFFFFD100This may be problematic for positioning|r, as you'd need to be in front of your " ..
        "target.\n\nThis setting is unchecked by default.",
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


spec:RegisterPack( "Outlaw", 20221104, [[Hekili:T31EZTTrs(plQsv0KwY08HLDYwISQy5KCo3Ln5w572)tGGadjXkqaU4HK1vS4N9R7EgampbOSKIURUR2DD8smONE6PF8R7PXKRhF9xU(Qq)c21)1jJMmz84rVB4Ort((rF)1xvC)o21xTZp4g)1WFjXFl8N)EzrS)D4pFFCQFi(65PLzbWJ2uuSl)V823UoQyt5YHbPBFBE02Yy)IO0KGm)vf4))G3E9vllJIl(CY1lTn3Fymm3(LfBsZU(QRI2Ejq5OWqgF4S8GRV66RIJYlYjENTYVmUa(R)vATWs8xgZcV(J8XMfTdN9RV6VXYly(XfBoSiA1Hf7sZZJGbEyr)K0dlUTmoHL5t)alHTnILdJl5WcyrS0VyaWqbC6iOY1fatRnFvd5MOGB0M9pNuWYYk3vCyrkr104W07G)wbm5(XXP3DybiB2gLSgNxyWCIbCXDripxSXV46RaccpkY)6RobgpNtyHdbcG8Zun(jDhWUSIgg7wF4DHNI)T4s4FKvS0Bz5QvW0CXHftoSOhipoSaio(RdxMb7W5rHSHL7KEwwzcBvA2AgSfNeambl0BzCzsilBzzE(qblqVbm8cyajfdx5N4bCR3g)TBzzndA)(Mjm)MY4yp)KqVGmydAzAclNM7bwN(OKBJwNMb6xjR9Y34dI0WY8c70UiRK5TKbIGK1v0CaFisIHzvIbUaOmlcwCfzm)8YSAXa9S1ziFULfZWF3qBllno(WIp(Ldlo9WIF53G99mCloznQIjMmGzIVhEciwYOTyqH4JvY8ZoS4lFSA7)Q6f3zCkDvYLvp7JnIEAl2JBOIlQmInqDJ39G1nqn)uVDPG2y(qWklkic0ENZfqN6sdbmEYwFpFCNpsAxduvclJkavMYKcsrinm0LUIRbHBw08Ill65CvKm2w)i0ybN2XW0oqB)4NsW9pqIb)V1myDSQe3E(XTGudeHx(hWpZPaSPc)rgl5vWO4YpYO8sKLWnjGc)oWu1BI(35FVSC3NOPhUEJOjhK(N)OK(8LvWoVT(F1lFhd5W3yDd4nK0MEq6UDPzfLjrf3tp610JeY3)zj4IYlmZ)ovzBhMQdK2bSB6lSRWrXwTIbRUBzETVw02P(5OKiClXhe2WyK9uJ7sOkFAj6g9ww2kWVjT5aAbL5CN1P4BGZeyOuMeZYHFFfAX8XIFcE9nrbiXJHnn4b5aTIHf2sG6NFkodY7KRiwrDN89w2jZyo3lDskjx5vbdgUKvChJXf9S7j1A)W75MvoeMGx7Z1eG)OyT5xuW2IbCWqmL5mHeaLR8L6zO(9A)SqUqkDLWoGbEHUZhIUGR3p8q0CpMvlP8SkgqueZbgqEEv8SA(0A7By9oUvbc5FQfvQjNYJRt2XXWQeCoF5N4R(FwAERnehJsHV)HifOxduTrpu(qykW95Yy)qM3Q4YSS7Lc1M5hf6XUfn58r)CiJnhE4ij7m5xvYphjhoT2I9MiYnfyrLbHJQ4uvXWFNIwa4XkI2HMtcM7muyeb0SAnaci0wAdl4g0OhvFczbGlg08HXJvLNUfni)KMnu(9GtHWMat(4l9ZeVlRFiVM8W3bLX)GMmUrLrfOtTmhWb4X)7EiAqoMqXmiHsB8ihW0c8rSgoiqqyo9Y6ykB4QkX1qtT9JHd5VfnhUWr2kdIqOdPxxh2xdlYdgpCPFoZtjc(4ZjLhXZbVamjU2plWpH5vKMbrblOPGqpO98DLX5m5jgh45YdmoA9MICV)rz46TiL0g77Lh7s)1EPRaKwqGPC1rcViOvZbIxdZV(9slkWGqGpJ7zHy0aGX)AuI2K5seV1p7g8TtZabKpOWij9CzDEUe)4LZW9DGJb1mlqWLuIbRKLrjHd3bG4kJbp8y6aatOgbUEy3MIoIGXLNgt8qTrDfVVc8BVHsRQgGNEskQcbDui1BOHWgTp4)G5LbqxK5AH7LOT7YGaUHEAdTHPSirMAlEzTPHcaofXUKV(Pwj8eBbMQx6XrbmkfIWimPuzcVcIuVH7M2bzlQnmTKpzToNwCARHByzWsqeZfDHEdJTte25Ym0omKH(3HqZ7oJNs6F7p4EEPFarSqWw(fWHEs(nGercqdrgU)B(74VKafr(QJydv3cXHnSiAlAtdsfgPgpTcBoNpSb(OzF4DCLZ(YjFTUMX8UdmAH1RvSKTnSbvW(fjuzmsevGihUJBIvYIOJbYrwuwSbLPEOcruoApsyyT50qdeJQMMI8Af65ZR(xWq9nkFsjfjy087IwbkIaCKn6zg3vEadCQ53Q3OtEg2mLcCbaAH0cstdn8mfgLVZViyJHlEmGBB2Csqg0S3UuGFMBVjJ5GxSLjNwxthfhYYi0QtSvsFub5fKHFRAeBraZzE(55W)nkPzVhi7Og1TqespryiNAQaqQvCrlV2k9)ASgnj1RiW18M21wVvY1Rj3r1Kkp1vbuoTRQ2CAhgz84Psfod8r6fbgo8KUTv3IMGFYy1DxxSQ1Lt0A0aC4JCSaiUM5mMeYus(hCFaeHwOdHkVwIYQWBnwCiYdcXdSRPP8O7o7buWl9xGa1eFVySgoknfv1vlZ)gioWwVLW7wMTllkxUiGTlnT5D0qtwVmjkZULxw2rhTy8c9t4U50Xy8)lXFQL436xLSIlyxIrylJZpXLivfXeXXKcdyB0)ftGXrUUnubiyz(Coes4SkzDoAjeSd64uby33UWN7uw7TQDmRvRL6ieofPp4AfuLrmx8bQL2lAY3KsSiMTEkoTwDGFJi5Hf)yUGONXtQ)WI)tFEru4P27Jof5WC5yvRQKAidXLqfLd3)i4Vvf4saRTQ4Bk0Gt2FB1NQRGsvzJ7U4yTyBmOg46dIqMMkdSvIIUldulfj4XS725wB7Aw2QkILcBy5vPzVBSo1KWSspw8P0srwQCpPN3PY5rDKjPAdqTWMEG7KHBRanszGRLcy9deE4(dEs)hw8tIS(5P8LKwi5vsC4d0pATcAnYL(svk4rwqbP0WSICYbCyb17SmNd0PJTTs68cKkwvfqm6aaMl2IAVwxwzFxoW5SdFBuPCZdVjHC(xx(v7vQEGP2NlBX6eyRDazmsHdijLqP0eAQ)MffqZYxrY1aWdW4HNBbFAlL3QXKYgA4lufMnhiOy11i7ZsxxYmK(QNGOXzzn28i7(myF4th0MpEYDuvrYtI2Xe4bGSmQmtItVJHvY)lF5tdpS4)iNvbCi8Eks0krun(jSIhYrn3KMjDMs(j3JpEytPmpkzUbBJDuaN1Vlc1ejjiol1N8qc7RW8nDevuhKFHiF8iMltZZTXsDxyYPJirP(tdlRatPBK)TUtDSgq1A8kdq5mmg1TPwtTIFqrEF4q)vyzE0jRmRZWFZnp6PFu(q44aP(xJeNOmwdYAv4k4vu0cjuy0uihpx5KE8eHORodLXUGNR8wA8izVG6qJFZKVWJlrW241Iueu6Uu6aXd8HF4Nip1vO5q94Vaz63Fc(N3zfY)aHHgzuQV6QMPHwbHyGGqfGHtXrBQ7Tu1t5ZH0AXASFMkenLpof6a35nkbEyld6oCjNgtAoAF90sKoB92ubhvzZONiYrlC73zWyPehLfscH3jTAq3eRNhrE6ilYMMO(AvaSgtMow8wtefDkxMtwDFwkHET(QHCeNKMT1pgJPSokGBxaUrfGFrRy6GrPxER))a1QV8t5dTdN)ykEql(qDbkR9AbOL3KMV3QuDuWUiVh6e2I8Ge0rmK2bkXlLU70nEyIR2J68nlXQxLSGnP40NX2LfTfC9Pec49MILC2U8ifjI0JYGfd2HmawfWdv0nadGLkndMfupNmTQpYFR1BzsR5gzfWE)UB2kPs67Aid6sWjeecYChZFxAc3VKYgwR5uRvsVTm(rApXDD2foMupn7rJu87GTZqbI7L5lHQLlY5zPovc2HR8rml6BnfEnPjiX(sZiX)UttrKkvAAymQAdQnbfUMVPJALnBM(DP0)eNzLdBHMhVvLyUJnCdomLZPFjlduvrFA6dt5i6xfLX4hQJ2O(G8OWIYMxK5h7fqDRH6q1JjXX0CxM)UCeFglMfuKLMxaw1baE0cq1kYxQNp6CK4K4k0aEWf47gKcUn2HHdaztrzM65cXvHquBCxlH14zTTdvTeAH24PX4QhuUdYmppaa3HDwtEb4NW5ruzcxa8edBjHnXmrM0rYbV35rz8H6DbtEbzDxNixGFa60yLNFW)SKZhI2K1uCwpe)VYAXadBTcr730cXrMs3brvFfbANGkbyKe6b56fEdllyteBLTmHvmsC8sY(AdtbNLzLSyV1(zzGchKGmbeGyiDl(AhBGaLuyxHHcYalypW6iAfZwvUCoyV31IuRrj09KHSOEreuqi9jEB0ZdDq(NZfjJuMJVbGecSjub60ggAkcdyuCdwiHXd34N7H2QdH8z9c3LBFTG1NzeEq2PWE0vIxxARQ(xWLJR8ZfdAY3eNo5XWPIgiPQ5BA50SBofCLnHRQABhlq1T1mQtuC8sXxvD4wu1NyTWlCamTxRixNpkVyaDjDTC8PJ1w5Fe5simu9QYAWtXeTEd43htmcK73i34fZOogQAHPomsN5iaHcGpVNAHSapYHRzFxLVj6wKA62tQiZQk7kB1kiZJBXZwdWtc(ZcGqxG5zQwJECmLm3aCkYgN3LsGZEWsQnnSurG)aG0KgJPir1JMsDhf)idV8(d8EUgrd5ZplhGLsbjW9go)17e9Q0RBPFFA75T86kQydphx76fePBERFNtFdQ32(MwiI0zxY)eTsBGcs7Aq2tPuxbQJ3Y2WSDoG)SFvLk)xOL2zuGH8smDLFVrMj1M(GpZGBY515blH0DSQQFsnP27oLx4vQysFQjvsEXFOJ8ar0k7YPvjCLSPLnq5hrChpBbJNr13K)86De5NRGqXXjb(uW3okcl19Dol4IZDEJd4dlynw2zfWp7GCvb3jIVGVIQZIRv3jopoml57Qxo0D7OQc(XRou9LVv3h6Yf9UP7irNlvEwod)RSvWSqLFP(9ev5ppfMwSIKRk4f7NrV6wFeUmFWwG0zHP9WFxcCNXPo16c(bpdw7IiNh5ZriKn(Wp4oVJkQSiPQ4Q8XYimmVk5tnTyXzIVmT7IqAW7F1vzPBP3FhjYfzelVOTGu68JOUiOryD(1VPMYiswAHJLKdP1OHtQjNnZf(rwGFlxkgnoBrTETxRt(EHlOMU9IAlck5yvX5j6N8sQlKHbJPWgCFDL2XVVjAFIvvTD9Dr2xb(anNOHrFppnfzxuTZ)D8d9cD4IFYUkAMF7(P67Ui4gvahInD0vkY(gkUPp21hCOuDS64tAZVm0paxeYZyL2r9dDFGt1MFimCGZRqv2kSzJCFb(dGcMn047fL0xUsqB4VreNFGGMUhjpBxIzid7SPIJSH(rrIivNOcTsuQoJb7RMTaOgdSh2GM8pj7r)aIu)o)SeqBcmZ)cojrBrvcr2HVs89x)kSfN5l0QVoi)YI0TODoznNawZdp8R)Br4X2o9VGk(jWCrp(vD8ff)kUVSUgw1Elm8(J)6aNZMvv)Q5Ov7IUOCN1Y2CL0rrV1NX3PnJ2R0B100EDG7I2wRqSMC64O852PCJnRgvnnMpsk(O2tp8Rw0VR)qrECA4o7wNkESZ25PlDpNn6JXm4QtGoszSR(SstA3v7y1HCpGu1EasCDU9Oo9Ft7XJOvb6so1PX9J2lG7zu7qJnNjhTiR(m8(xmPP7z(5sA6EgFQKMF4zFg((xS9RF4fBMhp(pjhuIPBYZUpD3tXtMt9XoqdP3wBAclxT3Ob5F5CCm2TM4ZLNdJP0SHk0KJwA1cDIoz0F6RJj6wspLWkni(thUYPgqwfhKJ5jovtF3hkLb1naajExZtjYG6whsB4D4NVZREqqE0fSn7)MLm2uhX9hZPHAU9nq3tIZbCSZW)7DLO7bxqaLpXxnIB9Z)1qz8pjjKJWdpjsiRk(0bu(W07Dll0p9otjHRZ3txoO7z5ioqVxPhtU7Z(tFw1bk(uKwRDaIpDu2rmWNakp(5il)2jTC1j1iSTcxkRB)zsTgj27RAsXdlO7Pq4X4nor6QiSb15pkFyDLfoD2BDDnMC4xTnADWyNzCBwmB8OZIwnZSzGMp5C70S5BzcFrNix3V3jIt70v0ne2FOgYBlRJPi30bGD70w9BI3cPNqsi(bvCXuhCVYNfRBI0C5o8R4)57oS4XDFtwZnZQLFFh27Yfp(BrYAsdlp8MQexaNO2iPC()f5gmuM7QAjIZWUBAwZDvWz0N4XS6BTXlM0R)jgNoa8BnE9TwV4ENy1LX(9N02zgnqHWoaAxrdT7mHbd2VVMTNnPhNPnUKj7jo2F5lysAt5z(Am0TWxV5DfBb2oYM5ZMCQ5Mb)KHMp78rG4ZE(d1BhQ)8(9e1SFJpohC0nGenVW3BGUfD6nULfr38zYFMvVXq69M(wolUx3xiUAkw((9wvOhieHUAgf452Vo9u5lsm)0D7c(aKyP7Mr3XIORQo(oU7zFLCX5gkjh7nb4dGp57SJr2Ke42(Mi654jvbIg7yfaMv0s4L9w8ZTWWOT1esd39Wm422g(KrcTvBx8HZhFQqd36fEOm3LPE37XzsryocHJAeVMxu)w3J)MbH5DsDU(asC3F2eDoru6qYdt964dPULtFh8dE(PkN(UjfOlSp5Fx7(5t(rkxhFcenv9OzdsjIxNXBG0ZuoiCUrGzBJoF84EUBx097v6EKlgpwBUaotTRoXzP1Uc9IztnPb2bNeUnNzfA(og9Ejh3u3P6TFFlFUDgtdpqljVFuDHPjLB62ZA)tQbuQqDyPxefMKwFMZxRExC45MCJuRZ4ID63YC6c5wxX5ESlJAhWVmnizNYrRILEULUg9i5CZTI6(Jui(S0BKxmzWtiRzfv576XruR99MAoRYD04zRen94mlEsKm1EP7lrlUOm7roYHZr0qHhhXS4U(4iokU(tVddpU1eSgudGm7897p22o8nMTC4fZW2nejHPc5mrBg2R1Kf75O5cNp2Pl(x42eSt7y7UET7JXgsfzukVgCQcPkBPaBwDcCXSXMPwwN0Jztdv)i9U)tSPj13FdA2pEYBdplkVQTHNnJrodAT3b7KEcaBpGlgZgscaDvWYtyLLXWdjIieF63iqY04uJcWb0XX1wWSr9mCTJ8DvvDmUumLGu1uvOb6ZV2TjjP7A59ercLvP4kzA1U502SZ5p069C5G5t05m5S)S6iwj5KE9DMorpBiShzaJEQHSr(kuKMXJ6K371DHVKhIwRR0tBzjQqM1R9W2wZ89b97RqjDc9Ivv5Iw)vmKk8p7()VS8OgF7ZYL2OB59rlK4okSCHnQeW4cWhL7lEGMv5l)1DOPirUOkwUb(uLwTQCkc(5Q1DefOblhB7LuZPQhKqv)J(L13gSy99KT0pUvE3vPXqpT(vSWE9ChE7yQaaFQ0prm0xehkGX9)aeESJdgtf5kyuikv(ZXTtOzmo5ZtS)3Ybkoq34VVvChafAPgJdQEltb4(9UqNpXq5ucBILi06(E6Fc)TTCj1isI2wPHh0SJQR5cGK74(dKV1(cEP5PlXmoKAXvt4maZVnqpM3hH96BcV5cB5fasNC1R5l71qq9ywg3iYEgUW(6uCyzjhLmF6O346c8R330ISDDXwVI(iOKU1wnlfW38fCx7HcCEhVj8JFCG1KwSQxUF0Y0HV75tAYl8)jCf5zKJJSOrjaLrKMMGqoLNMAy9DxSEh5SzlL)(k58p50XNpOnN2Z7p5nwX5rLW11o1idF2n3yCDiz67moG1Iok(rBgfvHuUy20rAlX5tA838SEx0DmOSDLTItxf6HIDNoIeEsZ7EUMiCsIu5GBg3YCvDsHvxqTKbx3Rv3(fFal2UV44M)E51N81fxh1M08QIB(etL8MBonBvoOV9wTOUWyQ)8a3Ru7vPRUEAhpkFPRknKHvVp3W25yuvIWk3IBGKMxE2ztfXKSHNtTUhI341V3Gj4xyA1Lzt7(ytNoth5CknD5uDJRz8K6lzndKYv3RAg5cOCvQP)uWdHhENmXJr21fJw7VT7BVSAzK2nIMPmQd(Z4YfZOWIQXa0UCZ2V3cyP3BuQRp0ox0Y1kM1AUArPsU)jTnfoVoXCEIlwVuXAFsCErF1KVy73Ly22((oeuYXDlG5I7YpJUrSMvDrDHStBh3V7pxdDgC2eNkyAt6KJDsn)enSoPsnoe7L8FNU1S85(MNPV4W1TL6bp1niUQ1572VVFBFRa1HlmF0aH3AhTnWjTr26kuz5rerTxpDDbXPgTPBLPS9)n02fkBY9KAE3g0jkFsgQLrrnblBCJANwCY3SO1cPRU44eQLxP3C1IW)ZQgNcWx3L5s8ANwDO40vpzaEbGoIUviU()o]] )