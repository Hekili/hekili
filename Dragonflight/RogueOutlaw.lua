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

spec:RegisterTalents( {
    -- Rogue Talents
    acrobatic_strikes         = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by $s1 yds.
    alacrity                  = { 90751, 193539, 2 }, -- Your finishing moves have a $s2% chance per combo point to grant $193538s1% Haste for $193538d, stacking up to $193538u times.
    atrophic_poison           = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $h% chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    blackjack                 = { 90696, 379005, 1 }, -- Enemies have $394119s1% reduced damage and healing for $394119d after Blind or Sap's effect on them ends.
    blind                     = { 90684, 2094  , 1 }, -- Blinds the target, causing it to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    cheat_death               = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to $s2% of your maximum health. For $45182d afterward, you take $45182s1% reduced damage. Cannot trigger more often than once per $45181d.
    cloak_of_shadows          = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cold_blood                = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by $s1%.
    deadened_nerves           = { 90743, 231719, 1 }, -- Physical damage taken reduced by $s1%.;
    deadly_precision          = { 90760, 381542, 2 }, -- Increases the critical strike chance of your attacks that generate combo points by $s1%.
    deeper_stratagem          = { 90750, 193531, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    echoing_reprimand         = { 90639, 385616, 1 }, -- Deal $s1 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.;
    elusiveness               = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by $s2%, and Feint also reduces non-area-of-effect damage taken by $s1%.
    evasion                   = { 90764, 5277  , 1 }, -- Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    find_weakness             = { 90690, 91023 , 2 }, -- Your Stealth abilities reveal a flaw in your target's defenses, causing all your attacks to bypass $s1% of that enemy's armor for $316220d.
    fleet_footed              = { 90762, 378813, 1 }, -- Movement speed increased by $s1%.
    gouge                     = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.; Must be in front of your target.; Awards $s2 combo $lpoint:points;.
    improved_ambush           = { 90692, 381620, 1 }, -- $?s185438[Shadowstrike][Ambush] generates $s1 additional combo point.
    improved_sprint           = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by ${$m1/-1000} sec.
    improved_wound_poison     = { 90637, 319066, 1 }, -- Wound Poison can now stack $s1 additional times.
    iron_stomach              = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by $s1%.
    leeching_poison           = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you $108211s1% Leech.
    lethality                 = { 90749, 382238, 2 }, -- Critical strike chance increased by $s1%. Critical strike damage bonus of your attacks that generate combo points increased by $s2%.
    marked_for_death          = { 90750, 137619, 1 }, -- Marks the target, instantly generating $s1 combo points. Cooldown reset if the target dies within $d.
    master_poisoner           = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%.
    nightstalker              = { 90693, 14062 , 2 }, -- While Stealth$?c3[ or Shadow Dance][] is active, your abilities deal $s1% more damage.
    nimble_fingers            = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1.
    numbing_poison            = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d.  Each strike has a $5761h% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $5760s1% for $5760d.
    prey_on_the_weak          = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or $?s199804[Between the Eyes][Kidney Shot] take $s1% increased damage from all sources for $255909d.
    recuperator               = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per 2 sec.
    resounding_clarity        = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges $m1 additional combo $Lpoint:points;.
    reverberation             = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by $s1%.
    rushed_setup              = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%.
    sap                       = { 90685, 6770  , 1 }, -- Incapacitates a target not in combat for $d. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1.
    seal_fate                 = { 90757, 14190 , 2 }, -- When you critically strike with a melee attack that generates combo points, you have a $s1% chance to gain an additional combo point per critical strike.
    shadow_dance              = { 90689, 394930, 1 }, -- Description not found.
    shadowrunner              = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster.
    shadowstep                = { 90695, 394931, 1 }, -- Description not found.
    shiv                      = { 90740, 5938  , 1 }, -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    soothing_darkness         = { 90691, 393970, 1 }, -- You are healed for ${$393971s1*($393971d/$393971t)}% of your maximum health over $393971d after gaining Vanish or Shadow Dance.
    subterfuge                = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for $115192d after Stealth breaks.
    thiefs_versatility        = { 90753, 381619, 2 }, -- Versatility increased by $s1%.
    thistle_tea               = { 90756, 381623, 1 }, -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    tight_spender             = { 90694, 381621, 1 }, -- Energy cost of finishing moves reduced by $s1%.
    tricks_of_the_trade       = { 90686, 57934 , 1 }, -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    unbreakable_stride        = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects $s1%.
    vigor                     = { 90759, 14983 , 1 }, -- Increases your maximum Energy by $s1 and your Energy regeneration by $s2%.
    virulent_poisons          = { 90761, 381543, 1 }, -- Increases the damage of your weapon poisons by $s1%.

    -- Outlaw Talents
    ace_up_your_sleeve        = { 90670, 381828, 1 }, -- Between the Eyes has a $s1% chance per combo point spent to grant $s2 combo points.
    adrenaline_rush           = { 90659, 13750 , 1 }, -- Increases your Energy regeneration rate by $s1%, your maximum Energy by $s4, and your attack speed by $s2% for $d.
    ambidexterity             = { 90660, 381822, 1 }, -- Main Gauche has an additional $s1% chance to strike while Blade Flurry is active.
    audacity                  = { 90641, 381845, 1 }, -- Half-cost uses of Pistol Shot have a $193315s3% chance to cause your next Ambush to be usable without Stealth.; Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time.
    blade_flurry              = { 90674, 13877 , 1 }, -- Strikes up to $?a272026[$331850i][${$331850i-3}] nearby targets for $331850s1 Physical damage, and causes your single target attacks to also strike up to $?a272026[${$s3+$272026s3}][$s3] additional nearby enemies for $s2% of normal damage for $d.
    blade_rush                = { 90644, 271877, 1 }, -- Charge to your target with your blades out, dealing ${$271881sw1*$271881s2/100} Physical damage to the target and $271881sw1 to all other nearby enemies.; While Blade Flurry is active, damage to non-primary targets is increased by $s1%.; Generates ${$271896s1*$271896d/$271896t1} Energy over $271896d.
    blinding_powder           = { 90643, 256165, 1 }, -- Reduces the cooldown of Blind by ${$s1/-1000} sec and increases its range by $s2 yds.
    combat_potency            = { 90646, 61329 , 1 }, -- Increases your Energy regeneration rate by $s1%.
    combat_stamina            = { 90648, 381877, 1 }, -- Stamina increased by $<stam>%.
    count_the_odds            = { 90655, 381982, 2 }, -- Ambush and Dispatch have a $s1% chance to grant you a Roll the Bones combat enhancement buff you do not already have for $s2 sec.; Duration and chance doubled while Stealthed.
    dancing_steel             = { 90669, 272026, 1 }, -- Blade Flurry strikes $s3 additional enemies and its duration is increased by ${$s2/1000} sec.
    deft_maneuvers            = { 90672, 381878, 1 }, -- Increases the range of your melee attacks by $s1 yards while Blade Flurry is active.
    devious_stratagem         = { 90679, 394321, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    dirty_tricks              = { 90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    dreadblades               = { 90664, 343142, 1 }, -- Strike at an enemy, dealing $s1 Physical damage and empowering your weapons for $d, causing your Sinister Strike,$?s196937[ Ghostly Strike,][]$?s328305[ Sepsis,][]$?s323547[ Echoing Reprimand,][]$?s328547[ Serrated Bone Spike,][] Ambush, and Pistol Shot to fill your combo points, but your finishing moves consume $343145s1% of your current health.
    fan_the_hammer            = { 90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain $m1 additional $Lstack:stacks; of Opportunity. Max ${$s2+1} stacks.; Half-cost uses of Pistol Shot consume $m1 additional $Lstack:stacks; of Opportunity to fire $m1 additional $Lshot:shots;. Additional shots generate $m3 fewer combo $Lpoint:points;.
    fatal_flourish            = { 90662, 35551 , 1 }, -- Your off-hand attacks have a $s1% chance to generate $35546s1 Energy.
    float_like_a_butterfly    = { 90650, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by ${$s1/10}.1 sec per combo point spent.
    ghostly_strike            = { 90677, 196937, 1 }, -- Strikes an enemy, dealing $s1 Physical damage and causing the target to take $s3% increased damage from your abilities for $d.; Awards $s2 combo $lpoint:points;.
    grappling_hook            = { 90682, 195457, 1 }, -- Launch a grappling hook and pull yourself to the target location.
    greenskins_wickers        = { 90665, 386823, 1 }, -- Between the Eyes has a $s1% chance per Combo Point to increase the damage of your next Pistol Shot by $394131s1%.
    heavy_hitter              = { 90642, 381885, 1 }, -- Attacks that generate combo points deal $s1% increased damage.
    hidden_opportunity        = { 90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush.
    hit_and_run               = { 90673, 196922, 1 }, -- Movement speed increased by $s1%.
    improved_adrenaline_rush  = { 90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and again when it ends.
    improved_between_the_eyes = { 90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.;
    improved_main_gauche      = { 90668, 382746, 2 }, -- Main Gauche has an additional $s1% chance to strike.
    keep_it_rolling           = { 90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by $s1 sec.
    killing_spree             = { 90664, 51690 , 1 }, -- Teleport to an enemy within 10 yards, attacking with both weapons for a total of $<dmg> Physical damage and taking $s6% reduced damage over $d.; While Blade Flurry is active, also hits up to $s5 nearby enemies for $s2% damage.
    loaded_dice               = { 90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    opportunity               = { 90683, 279876, 1 }, -- Sinister Strike has a $193315s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = { 90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional $s1% per missing target below its maximum.
    quick_draw                = { 90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate $s2 additional combo point, and deal $s1% additional damage.
    restless_blades           = { 90658, 79096 , 1 }, -- Finishing moves reduce the remaining cooldown of many Rogue skills by $<cdr> sec per combo point spent.; Affected skills: Adrenaline Rush, Between the Eyes, Blade Flurry, Blade Rush, Dreadblades, Ghostly Strike, Grappling Hook, Keep it Rolling, Killing Spree, Marked for Death, Roll the Bones, Sprint, and Vanish.
    retractable_hook          = { 90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by ${$s1/-1000} sec, and increases its retraction speed.
    riposte                   = { 90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every $proccooldown sec.
    roll_the_bones            = { 90657, 315508, 1 }, -- Roll the dice of fate, providing a random combat enhancement for $d.
    ruthlessness              = { 90680, 14161 , 1 }, -- Your finishing moves have a $b1% chance per combo point spent to grant a combo point.
    sepsis                    = { 90677, 385408, 1 }, -- Infect the target's blood, dealing $o1 Nature damage over $d and gaining $s6 use of any Stealth ability. If the target survives its full duration, they suffer an additional $394026s1 damage and you gain $s6 additional use of any Stealth ability for $375939d.; Cooldown reduced by $s3 sec if Sepsis does not last its full duration.; Awards $s7 combo $lpoint:points;.
    sleight_of_hand           = { 90651, 381839, 1 }, -- Roll the Bones has a $s1% increased chance of granting additional matches.
    summarily_dispatched      = { 90653, 381990, 2 }, -- When your Dispatch consumes $s2 or more combo points, Dispatch deals $386868s1% increased damage and costs $386868s2 less Energy for $s3 sec.; Max $386868u stacks. Adding a stack does not refresh the duration.
    swift_slasher             = { 90649, 381988, 1 }, -- Slice and Dice grants an additional $s1% attack speed per combo point spent.
    take_em_by_surprise       = { 90676, 382742, 2 }, -- Haste increased by $s2% while Stealthed and for $s1 sec after leaving Stealth.
    triple_threat             = { 90678, 381894, 2 }, -- Sinister Strike has a $s1% chance to strike with both weapons after it strikes an additional time.
    weaponmaster              = { 90647, 200733, 1 }, -- Sinister Strike has a $s1% increased chance to strike an additional time.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    boarding_party       = 853 , -- (209752) Between the Eyes increases the movement speed of all friendly players within $209754A1 yards by $209754s1% for $209754d.
    control_is_king      = 138 , -- (354406) Cheap Shot grants Slice and Dice for $s1 sec and Kidney Shot restores $s2 Energy per combo point spent.
    dagger_in_the_dark   = 5549, -- (198675) Each second while Stealth is active, nearby enemies within $198688A1 yards take an additional $198688s1% damage from you for $198688d. Stacks up to $198688u times.
    death_from_above     = 3619, -- (269513) Finishing move that empowers your weapons with energy to performs a deadly attack.; You leap into the air and $?s32645[Envenom]?s2098[Dispatch][Eviscerate] your target on the way back down, with such force that it has a $269512s2% stronger effect.
    dismantle            = 145 , -- (207777) Disarm the enemy, preventing the use of any weapons or shield for $d.
    drink_up_me_hearties = 139 , -- (354425) Crimson Vial restores $s1% additional maximum health and grants $s3% of its healing to allies within $354494a yds.
    enduring_brawler     = 5412, -- (354843) Every $354844t sec you remain in combat, gain $354847s1% chance for Sinister Strike to hit an additional time. Lose $354845s1 stack each second while out of combat. Max $354847u stacks.
    maneuverability      = 129 , -- (197000) Sprint has $s1% reduced cooldown and $s2% reduced duration.
    smoke_bomb           = 3483, -- (212182) Creates a cloud of thick smoke in an $m2 yard radius around the Rogue for $d. Enemies are unable to target into or out of the smoke cloud.
    take_your_cut        = 135 , -- (198265) $?s5171[Slice and Dice][Roll the Bones] also grants $198368s1% Haste for $198368d to allies within $198368A1 yds.
    thick_as_thieves     = 1208, -- (221622) Tricks of the Trade now increases the friendly target's damage by $m1% for $59628d.
    turn_the_tables      = 3421, -- (198020) After coming out of a stun, you deal $198027m1% increased damage for $198027d.
    veil_of_midnight     = 5516, -- (198952) Cloak of Shadows now also removes harmful physical effects and increases dodge chance by ${-$31224m1/2}%.
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


spec:RegisterPack( "Outlaw", 20230711, [[Hekili:D3ZAtnoss(BHyIZT9a4220qVZEy2yg655n7S91m7TFdHSSSToKL8PhqZee(3(Lz9s1JSKm0MUN7IyEasLYQQ8DMvwjxp(6F)6RMhwfF9Vnz0Ktg92XJho(03C6OZU(QQh2eF9vBcJUnCj8dzHRH)7)OUkn8E8XpKMhoh)8Y86Ii4vRQQ2u(xF9RxMuTQE2WO81VUmzDDAyvsEwur4Ik83JE91xnRojT6NZUEg9C)MRVkSUAvEX1xDvY6lbiNmFEmF4XLrxFfo8Jh92Jhp(VU9MT38(WQOvBVz8OHJhE62BQ3GaD42Fz7VWh4Php5m2a)qCA4h3EZ3fhgLNT9MQC4FxfJp4H8S5WVKSojB52BkHxKuT9M55XLzVc(H7cZskHPa2dXfBVzvsvfBGSVEtr8Dj51LBVzwDvvE2qCQ(NLXCyKSED88eybL(G67T(SWzjPjvp8VJtiB6Upe)Yf5YH(Jx(Ud03oJFdB7a4L7m2MJNWE(3oFU3nP24NC84tLJpg(I8niHI)f14Y)BNxeNfMMKb)8hQX9)SyyrH)wEAQeS5zXWEijt875BIZW9yYIT38Rahcc53LeHydyyvHPXzvXZpIpnlRdlcHFhEB195icCXIsg(73xHd)(86u47xhMKHOVzXSvg8KzpG4N0BzG8wgT4Y86SkXI4FmFoIxrAQ(AGb5RWzJZgdu6nXrjWw8pc57Dooa(2(HaSsJxunGHXeOO08Ljr8Los(IXj8)sWBOWalskkRq2ram5awaeeMHqRpoIOqeZIpEoWm(ahVJySbAuMtoE8jmkZ)KXkV9M)omhW8(JfjWkkVa52RlbPYHxFvAszvjkgUibxhWp9BmHAGYnlnE(1FhimfHBkqSlU6(44Sayvge)qCjxCQizd)1)adaXfL4m)DvFpFFEBC8gXg7YcMqrmsLqXSJ4u5p8EoTL9aKNLX4(JfWuvcKMs4P1zPXLLcWufwSmUI)nHZYRR4t08eC7alhqejjeu)Wg2qqMmoOkpaE92BUy7nNS9MEaUuUogAVPgweJSlaSpF7nVz7np(OKRB4s1sk4(KOBHD6qbwIbZd48FudREdhqhSRWsmQK1BkYVlEEGZQuFWSzTa04HiPaGXkkPeOiSzDW1vG6rlcAdsI9PLPaVDaWTdijGjxhbSiz5QQa1tGjRiErrC5kewsmzZUQ8(KfvbLPHiFqZAe36ixCEWM8KSkaqxmfEYMG1HFmaeHq5Sbn8zMRhCdCcUbKVokpfqiP55Z13uWOEJ(OMNuUb1RBoMkKNDryDAffJUb78hIlRIdtRwX5s3KxwMW209ZaUT7QtbHoowae)wNivIXLw13nCOqrhmMVFg0JvuuVbyNZzWb2M53l0NgMMMJQBaRbmLvj4G5ZaQMlbxLvRcRAM2BbUkfQJqyUeu(BTcq7bszjGQaAO)(ScqlbSdxSioQQ0q(si)WhAkc)Gy2Wb(of1qBIZ3atAS2k8UqaoWBXFkTogLyzmrrOIygNEoOg2Gthy2eOZ45dNfwIk1qMloB8QqaHTooDUsEt75bZdZIIfYeM77lxfhHwcqY89WUnenrH0Yq8F3aIGBksy6rVsYruwX(DUj2IKLlbCIYGURLKz5z1LSDCa3ni1UiiQkhXwN(uWwsOuundKnlaJP6eMgXrUFpb5B2KxuvNb(iiXM286o2J)adS4EjBEcJntrMWzLzOLPHyIMwaUc1cWIzzYCoU2wdXIqUsSvHGFnwQiKqO8260uM8Fubi1ndxrCcNHE2QI6yqXyiI5nP4PmB2CTzIVdFN2cFQ2cNVQRbBJZdQkIdlRluRDHcDCTamwXX6AYP3TExD98T4qY)zFEj)YTUyGOn6GeqppakC5Aqv6qQ0wyc80HXVeMsXejez(pyofGEd8b(uYn8Bl4Oy5K7(HnBz(IRp7Fue2GS8I14md03rCZvQxLMNTeDSen9mwJxQVpkz7KXUzsDbSYok6hY3OXWAmlEhfHjEVJLC5zp6bcUV3U)4(6K1ZID5FXmD9tSHde9MXFe6ICsoa4K)igD7OqYPW4GUc3Fcx0VuTdb2O7qAm4ADXdvRydpoTSXeZb6Ce3NaOO08Y4aVOmPGcXhT9MJBbyA6my4zLMsxtsCR8QxvpdqLlQxYFbsE(leKhWhSNhbIZyweMmpGfaYWquCwNZy8eH6sRX0Oo3(nOTYJBbO89)zs9jK(LJZQqp9S8soI3Y7ZZXrzRU5U8K5s2d0vOviFeAfhjiBVjlhuOSk8omUbygXrIqJRYPjIlyE4QGcXyFVNp(CC0GEpz8lACZO)zyqAyGyS3TmnFwyksT(MNIWeJPS)oPX22j6HGJSjrOo0l4wZo0nSHW1ZG4UBGXHK66uknUdGxEDzaezm4Uz9g1BH1pMWIYHCaccjpCF4dsDDy4NlFGVooDKfb67Zq7PcssyMiynimw4N(wg0ec68xO7mvOMdxs3H1zWflMiP1fe7pE0tg97gzc3QIz8jhlTAC(FJ92Zypsg3t961aytFiqg2b4FAJjsfNn3p6K7IdApCiYiRbesfBE7FQ0L)RKZlMFc5eVvLLeywV89ctRVhZcWhpE8rOmscmoMIsmgAiu0qwALumZv3NRJN5zgWcpBh7u34zwCcbCX)YHZsb3GcwKwxu8GM6rkvlG2HjJ0yt1)utnx6cb3MWSxaiuiu7wT(SgchmztQk1cyghQy5psUh4iQimobg(fdrcmbppMPWbWzfys)q1lx(oyGLR45DcZ3u5dGo(5sc23Hl9T38dS1UoowFpfGFddj3AaJ)eO1cNyHzYh0KwWK6imu6gmcpML6MWzETmfuyeKsfNZaUIBfHbHbEMTmTrnxtS4HOjt2VeGtQULMDmsnEkOmJlIT59f5Q7CQbGiWRr8JTJ(0aZ9R533nI7k2IeeSqJ072ow5MQz4D(2G2X8raihrp16OOoZlsqKkpCoSdSyNqIy(1NZ(CBpdBwICL(iPnoWWs04tzsHI3xeVmwBvhwefMH29lkazu2u8x0ZAJ49BQzoTzKDNXFJ(atrt2Lb)31ZxUgHK5yNmsFSZcxgKVaITlbcZ3jFqOZ0SC2OYiKAXSzdOrh0rxI)M5eya)8Qk4nG0lMq27rLov5FmX(BS5NfgXsbnoRa9aBQ)J)if8Em)JARaIxANOljhL5KzZBjhnyU4wCPMxauTq8ZAiP(09EQgskOmgzgb0iyPLiWv1kxL7)GcWinricnoPyoutpEuEEud8zPZdKhpqVgxcgIU(XIm1kkNZzwe0cYVLbEIvkcSIKCajk4eQGNucOgtMbEExNxYjDcvibkMbZuNAmPM5T1jZgQWqoWhwNMnGlfH6DB5OdCyhmtaNGswAfOcBnAZEqLvPDJxY0NRZ5En3rcYnCAr5D4eMZFKjhAqd2L2pfGOVmA(qWxpnniAJKsvHvc7Hnz4C23u2q26BNGlHltK5ozGx(uIm3AqtibxpFPr5qFPr5WUsJYH(t6HanFHDo8iIQ2kTFi57mJDVvQVOuDsyw2XBnJu)PtEA4w1nykd(DnECYxWoNPd1tTDr(YAEcgS4)EntJXaBohMmfH2ydkxd4dLPpR7mUVZztuN1WY9NDYNdX3eiCGZVJh8eyqpxcBguoEUB7chsWaHPgcnh2kHSnT6KCBLblNrImmQWPjtqc6y1OguPglwBMdCT2ZungbXbnEiywp6HiWRcb3fQ9UfVbA4KPwGN7l5eTN2cpXy7vyY(mZwWYytP4mByNGCzwYMyzgBYILrELc(8J(2)7)(7gkkVcEUIM)apRIHLIARap1hmCz1cfJgabc7OMdZEaF9qQu94hT7SQXZqKVY5HBXqI4KOkdGS4pct3jJyN)nUC)7lEhpNv88J5UI62vUtgrMOU51fI6xO3tLy5NsrLmgxR7yC2vipyCOhDLMbxmAuN5imAfYFc)8xBRSxBYiZHXtrtVJMIE(lPaXgRvlaAMK0tCbzAaAtTEp9d2Pff7EdXuPUsaJ7Jd3KNTMjEqdb78WzEy(Qy9jdQ3YZg2X6NwxwHQeJQ6KwFIEEHC9uSzzSjN9)vPgOX(jmHblQXSXyeafp6C1WIlkJlWcfYEyNPpSfjfXuvMapoALZWG)jLvfHPbOfr7H6xxEwsuWsvj8C9vOZ55lweaUtY0DZnK6oUoyx6GR1Wg3Yv5GeeijabtFBSPfobCSgIkfYTK9pUNCDL9Fm7YwAsFhVwoqLwwNWyDjUYWZymED5WM8hqGyNXQ0nuyK5fmRm38HCPh7))fb)B5vX)1T3CLQomVeRdtwA6rnSQs9twTG5S6SZUu2gnCCPw6L)XlFNml0BV5NFfEwlfyLvI7ZvXOH8zXrHm4IzK8vSjcMPSWIcmJCHOXVmqRYWMC9qqxlb2)1SuBxcX2WCaLoSoxKfGdaj55n(DtDEycBQN1Tfj0ZnPxUwRjCd4lOzCtwgfweG5yg(YS4VCBH3k3belkCpyBIszYfI4724kdplBtEG5Qo)BgwnE4QWYaSwBgco5emFtz3CWa7WvLP5G7SnZnUa9LnzXGM8SwGt2llWj8uOitKxBvGPEEcSkElzAaDs0M2jkRB(EhdiYn)htm86ZijhC3(87UYoKxBTQ7R1eHSdGsvcGTMtJNuKKC11(oouT4mHv18aW1PBZIlDIOwWFzogfZv30fn3R4RadgOap5IR7tOJFc54bPnYYrYUoy6gdygjHXBeWgJsg9lnhnEewQ0d2CGz8sQ38qjTz86Eh316UroXQW1kcZUv)0g)FQtIUnyEr49gN2U4TH1ZdJmqAN3Pp6ANKjD5zrGn0OpMyg)Yr7c)Q3Drpp8YQKs2smc6V1HyQrXKhLLFj4DGhvtHLAx04(L96GenQfOH(uak)JULrpDEflyz(RhSVXg(tsPz5wstw10Z4suhyr27aV2sGKp1n1tQki1lzyVcVV8UEpWfq6jcXRgq9bzK(V(7kUxarFm1TP3IxUf6aqFgeBRb6ky0XWMQwAntTTRbZKdHEkyJHNEFZRPaH4lDQm2bu5ZdZROLCoyn7yMj)GVLOYtRJoSpvevFTvLnSm8cvM4KUhnR28gTxX1(XqvYIpOfNGlJ3uMu2EYR9vKHJ7uRqxHYn2YlLVdxUq4CT74lT(dtkIY7Y2QtQPkjxYJAYm35AE(lKw8D2cN2GEnxJuopy57PBvjPxAnYA8JFnaz3LfSSk2EZpKGzr(FjSnXZYoWnvwJ(G(Tc9zV(kgXMVF2QU)GVpbI8mfRrNCZsoQfhZ3DNz7swuPTWv1RIWWzs51cS5lCOjTicknlStbw41tmkVNu5fLHjdkzisIAJtsiy(JsuM2SN)dHYe(8tmRmYtSqNmTvCRhZJ0bk7Sl4HDizuqQnRQDdVlmjLBT31DvpxJKET7S6oWa0ZJbXw8G0V4M6nMxbjkh46MGWoZQMRfji7WV4GsHdJBkm)qVmiuYlrzrDgV(NTjBozJ3Znz02uzledsuPswGa(g6AXBJn51JPBKfN7LGXuPIXa3G19i7Oyy(Rl0gjVpy8tOJDNtzJ5nhYpGq2Lp4DnAG14DXJE4PW06JLRV)ioq12TfYbz0k6OxzXV43bUN)62ZHiY2q9TkuxQqNhWo9U2CHTTtj(z5n3tte2WjgD2Ww9YJE52aO4Ov54r)vedgqxd8xxtCkZ7M5UDCJ)jyvXnhuUh4B3cQ)txdfe6UqrXlf3d(3NxfNfH644D7a8k)efUrE(Qhjpy)evTmh)ryDGAfzd7Y3lUN58HvxYug(FICHO4m2DkOIH5zif49KSnlpwgVotzNzQ08EYR0sxNpvkyX9U15oE0I8wRjeWNPpM2JXgLmBjgvaSCLEpAC2Mm37bIfwexIE2XPto76RUpSanibU0)7OQ6K1iIuCoEVsKuZxHNreSYlWfeVu7dRRYxdM7MZoY)SLGS02F5xzUzI91JlZZG5I96xjttGs6(vC3rCFHCxddO)4poOli6kEzbz)YF2ZWBONbdbplGtk1UJWDVSY3(leumXfS)PrX8SkntoQ1kKoZP27)tFb3)TodMkmSjDKAtSH8zV4RDpZGvOiwG3tKr7iS3d003(IJxSNbvrKouDrpjRDv5e(KULPpNjxRUJ7ConhRXu9nV4yspZG1Du0c8EUbJoALh5trV79XZrLV)RSxhk4uvb)ttfNhXbF1UUxmcDjU3XAMNUUN2c2Jnp3O2SwQ(7Tno0VVuZG3gRJpSUVgWJ98nXddPEJXXMtKQP50b5mIP48tNwU3z(iTiMVjMxGPL8Ad6v(lVYEhqeGuV(EkDYlEZHw1H5Xgzp9F7KbYDYNRP81Wu2Li)EWc4lVNbF(TXkaGD1tBbFFLzVJKVhrX9aYF8FXJElJuNBRZI84fDaThZL7bqpXbHikJj3YSsbF)vILd0pXd0DRrkhOtoK2u)PvPl7f1G7rMAFHEQL(iB9)ehE9UAw5fbQnjiWcMUzoyhHOmTbwWZovd7i02dsWEG8EjShhbb(x)jhiVh4(mXTVKPfG0jG9gEWdCFM4Hx(0d4Xu9NOSRhOUhSt4bYA(hzbwI6DzhH5Eel7XzI9Ie9xmxH2JZGhxw2l4hpWEVS6jT)ZQrKx9KS87r75Ezn26mSxWWVu2u8L05p9ux6bYptT0F5Sw9PJj8O7BpazpAnE5G8NGNHV8A4(ILkZpzPqFPXCpqi9bA9Zw0cWuh7OU(4FMPkgb2BbnUr8I)J1gXHxJ9iK8fjPQoMu5qv6spC6R1BPoB)fQr4Rz6qpA8w6HxXVJWQuDkr7YH(ZeXps)s7emCKtxpz64rhLSyQ7TP6IjNsdtR8MraYtqikOa(s32Jps3yw61rRW58X96ZYXLNxFYJp2Ced8gqZ0rdO3jMGGyJmHHAAdYEOjgL3lfsNdyvBSPN9zBWklHEh4PLbbCUFf2sAL0(Ntx9wTY15HaOUx6D36ah7E3mi3Dp52ynbJgXsT1BUzG9ZulVwFTjtalxu14YwDeRA(LC)MrW3RV1LW6Xh1QhhrpKZ4zQA0zaNIN3DVT2)6SPl3G41d8AYqSfum7NpPx)dCQdd4zKAVF8Xd8E4G4grKIARUOJyxB2qPhOjXnDIqU3T7w7k8GWJyftoZ9OMyg2EF2(N)0Pk96t7M9JpsYRnqqfj6Xrp(y)(UAY618iE7L(IPJbIvFx0OFSOFAUnyekvV4KVrq5PAB0nV1F7IUzmT1MOHrnGtu)80KM3vYDxYGhSRNvFV(eJ84ooS9bGKTRYgMLh(Jn7FZCHI)u1KI3j8C(MPSwmnt(QVNo78fJNaABC6tq9CgFs2XEaXGZpdfgTVvcaKbfz49WONXDW48Xtyy09Cxf2pkX(M6j4X67Lj8XhPQoVlMo5qhN7yG(qhDfcrtIMXSM)Fgv85GE8dR8IPNoIHE(c0WG9JcTVPqcuOoA6IP97R3DHoE8GZ)B9p7ybkJQwnga8h0Tt5lMA0OIAuG9LQp)6h14Cw0cCJ)RaeO9HkSJrcMgQwo4fJLSEKTezgc6lxVewh5y3G4mCve1eTdUc2n8Iqpl(k8VSxp1UaC3WwBT6PVcObcRw4RU0IbaCUQDDUmy5hvFyM9Dxe6efMm48YPhAuyYUqG1zE1FUvJ4v)vg9Dxr8xYRlxtmGS1kg7c7gtDKXT6JhZhL5HX98Fj(OnCm2DknppeTaNOVNENp9eiAe)IMtNiyinlLeP37g3TGEeBQPNQKf)SEd6CrmCRlmjosdoG3WTyaK2N7bIyr0kHCP8RXDLt(qdSv73rUbQ50iDB983BcAmk8NHl4Mlbq7(sO5YRzqJ9epvIq75pmigAqpbNQa70OgKSPh46RRifcV4xhToXkCrvQ7OMV4SPqec(n)3fTZhp8u94G(cEPY6eLSZ7AHWO(dzRYlM68C1DktGP0FNefnzWECPr6aD)(k3yAoSHbFnDYWXRi2ap11N)SfOYct3saeBxN7Ufl0jILaWk9vYeNRHTanCW3Y)JH7ryYNXga6ucRwDRCUBDZpf9K)j8gA1jZ2Ul(BwONsUnDVG(Aq(hynioDeso1ZNoMkMohExP)3QxzFgOUAOj46SUWvcVSuDmPMpa869q3ZHqXI627mBKu8FCe67FW9Nb2tNU7rmgwDNNGG(MCSq3REAihWjtuHYC(YO52ZH1bsiTly3J01t2tvEfM9UhFKirFo7blpoyOmIVRNBs)4Sbwj9J)qpj9J)sYwE(GlKjZ1jXtAz89IPN5Hiij3FUQd6)TtCwiTgYewlNmCRr)Z0tIA71skFpOJaVelgTTjphx0F2Jp6eZP)P2cHmONL8rJiL9zmc6x6O7GpGmIHX8898fSpyBJxDo9uM6IO5tbTOub3rL(q3D65uAA9LQnRmjrYxRqBVanI7orj0ND8jJCssQSXCt7sK1g1Z(0CTO1cSBu(B2eUPTicSAJidSw0UT)AxfpgPBQlDpwYoTeEFpVAKSxanjgYvZI6OHS0S4nRl0UaOmw7T3U5Gw4TIALHkRwEnjo(ez(9i(JHIJ2EzdT25nQEyT9BuTTAh3fm6u1mzMDTLlBdkZk1WUjvFKw7wMRxWIA1c7GsPQzwBE8rFnTnqNU3K4CHNZDqKBM)K3pKBhPt18Q))ei(22u2Duzh3mnNfR2IS7XxbkIpJwr34rTVsC7mYVCRL36BPuEeR3cpv27J1sQjzMs9FhGOPgt8IeSM5j76m7E5F8pZ8sIXPVW2SK0CM8q7dBXUdukR6eWcYfJh1RTmAkz01D9w3Ln32z7GN0AsBYCwFuZDp)P9WnjjhAfF55Kg(uNrKz4o(3gYJPGmJchynN(tXGFdN9827q35ffv4b2bv3RV98qsnis(flPyN78yv(Yg8YS3AYTPoY0jncdAlijVE58Cwyg11fzVP0SaVm4K3N2xg08jAEbRlO601vhSlje0GBXVO35tKFGzkMg4vzGoMqpTvwcHnefA0ROYtS7pQAC2UoZ6Dt3fgHSRNUZ7WN5gSFx9P0ZNI(i31OUy8KrptSYaH1hEPvWoNdWnVQVN703TSkAJ5n3LfySYCwurO4yUr)W75zYN9a0DzMpZnNFYrnNicdmCNc4Ft4mw8L8QanwZlp(gG5BVP4dhv7KVGt613N8Mep(gfsW9erekpjpYLgJKeFN4nE7Mc9AjVxe7wRsfwgjLLaGChz4hrp9ciwXOB0cgmtRGzu2uRMM)Ifq8szbRy57IT0YHU5kvU0uhgrlNVNvEvNiiugPqvpuXMzTzXBeGU3soq7tLBTN8h2Cag7yo361VJt6WY5dp)9vOnXB2FpvIU(3MC2iwFk76)3)]] )
