-- RogueOutlaw.lua
-- October 2023

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
    -- Rogue Talents
    acrobatic_strikes         = { 90752, 196924, 1 }, -- Increases the range of your melee attacks by $s1 yds.
    airborne_irritant         = { 90741, 200733, 1 }, -- Blind has $s1% reduced cooldown, $s2% reduced duration, and applies to all nearby enemies.
    alacrity                  = { 90751, 193539, 2 }, -- Your finishing moves have a $s2% chance per combo point to grant $193538s1% Haste for $193538d, stacking up to $193538u times.
    atrophic_poison           = { 90763, 381637, 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d. Each strike has a $h% chance of poisoning the enemy, reducing their damage by ${$392388s1*-1}.1% for $392388d.
    blackjack                 = { 90686, 379005, 1 }, -- Enemies have $394119s1% reduced damage and healing for $394119d after Blind or Sap's effect on them ends.
    blind                     = { 90684, 2094  , 1 }, -- Blinds $?a200733[all enemies near ][]the target, causing $?a200733[them][it] to wander disoriented for $d. Damage will interrupt the effect. Limit 1.
    cheat_death               = { 90742, 31230 , 1 }, -- Fatal attacks instead reduce you to $s2% of your maximum health. For $45182d afterward, you take $45182s1% reduced damage. Cannot trigger more often than once per $45181d.
    cloak_of_shadows          = { 90697, 31224 , 1 }, -- Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for $d.
    cold_blood                = { 90748, 382245, 1 }, -- Increases the critical strike chance of your next damaging ability by $s1%.
    deadened_nerves           = { 90743, 231719, 1 }, -- Physical damage taken reduced by $s1%.;
    deadly_precision          = { 90760, 381542, 1 }, -- Increases the critical strike chance of your attacks that generate combo points by $s1%.
    deeper_stratagem          = { 90750, 193531, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    echoing_reprimand         = { 90639, 385616, 1 }, -- Deal $s1 Arcane damage to an enemy, extracting their anima to Animacharge a combo point for $323558d.; Damaging finishing moves that consume the same number of combo points as your Animacharge function as if they consumed $s2 combo points.; Awards $s3 combo $lpoint:points;.;
    elusiveness               = { 90742, 79008 , 1 }, -- Evasion also reduces damage taken by $s2%, and Feint also reduces non-area-of-effect damage taken by $s1%.
    evasion                   = { 90764, 5277  , 1 }, -- Increases your dodge chance by ${$s1/2}% for $d.$?a344363[ Dodging an attack while Evasion is active will trigger Mastery: Main Gauche.][]
    featherfoot               = { 94563, 423683, 1 }, -- Sprint increases movement speed by an additional $s1% and has ${$s2/1000} sec increased duration.
    fleet_footed              = { 90762, 378813, 1 }, -- Movement speed increased by $s1%.
    gouge                     = { 90741, 1776  , 1 }, -- Gouges the eyes of an enemy target, incapacitating for $d. Damage will interrupt the effect.; Must be in front of your target.; Awards $s2 combo $lpoint:points;.
    graceful_guile            = { 94562, 423647, 1 }, -- Feint has $m1 additional $Lcharge:charges;.;
    improved_ambush           = { 90692, 381620, 1 }, -- $?s185438[Shadowstrike][Ambush] generates $s1 additional combo point.
    improved_sprint           = { 90746, 231691, 1 }, -- Reduces the cooldown of Sprint by ${$m1/-1000} sec.
    improved_wound_poison     = { 90637, 319066, 1 }, -- Wound Poison can now stack $s1 additional times.
    iron_stomach              = { 90744, 193546, 1 }, -- Increases the healing you receive from Crimson Vial, healing potions, and healthstones by $s1%.
    leeching_poison           = { 90758, 280716, 1 }, -- Adds a Leeching effect to your Lethal poisons, granting you $108211s1% Leech.
    lethality                 = { 90749, 382238, 2 }, -- Critical strike chance increased by $s1%. Critical strike damage bonus of your attacks that generate combo points increased by $s2%.
    marked_for_death          = { 90750, 137619, 1 }, -- Marks the target, instantly granting full combo points and increasing the damage of your finishing moves by $s1% for $d. Cooldown resets if the target dies during effect.
    master_poisoner           = { 90636, 378436, 1 }, -- Increases the non-damaging effects of your weapon poisons by $s1%.
    nightstalker              = { 90693, 14062 , 2 }, -- While Stealth$?c3[ or Shadow Dance][] is active, your abilities deal $s1% more damage.
    nimble_fingers            = { 90745, 378427, 1 }, -- Energy cost of Feint and Crimson Vial reduced by $s1.
    numbing_poison            = { 90763, 5761  , 1 }, -- Coats your weapons with a Non-Lethal Poison that lasts for $d.  Each strike has a $5761h% chance of poisoning the enemy, clouding their mind and slowing their attack and casting speed by $5760s1% for $5760d.
    recuperator               = { 90640, 378996, 1 }, -- Slice and Dice heals you for up to $s1% of your maximum health per 2 sec.
    resounding_clarity        = { 90638, 381622, 1 }, -- Echoing Reprimand Animacharges $m1 additional combo $Lpoint:points;.
    reverberation             = { 90638, 394332, 1 }, -- Echoing Reprimand's damage is increased by $s1%.
    rushed_setup              = { 90754, 378803, 1 }, -- The Energy costs of Kidney Shot, Cheap Shot, Sap, and Distract are reduced by $s1%.
    shadow_dance              = { 90689, 185313, 1 }, -- Description not found.
    shadowrunner              = { 90687, 378807, 1 }, -- While Stealth or Shadow Dance is active, you move $s1% faster.
    shadowstep                = { 90695, 36554 , 1 }, -- Description not found.
    shiv                      = { 90740, 5938  , 1 }, -- Attack with your $?s319032[poisoned blades][off-hand], dealing $sw1 Physical damage, dispelling all enrage effects and applying a concentrated form of your $?a3408[Crippling Poison, reducing movement speed by $115196s1% for $115196d.]?a5761[Numbing Poison, reducing casting speed by $359078s1% for $359078d.][]$?(!a3408&!a5761)[active Non-Lethal poison.][]$?(a319032&a400783)[; Your Nature and Bleed ]?a319032[; Your Nature ]?a400783[; Your Bleed ][]$?(a400783|a319032)[damage done to the target is increased by $319504s1% for $319504d.][]$?a354124[ The target's healing received is reduced by $354124S1% for $319504d.][]; Awards $s3 combo $lpoint:points;.
    soothing_darkness         = { 90691, 393970, 1 }, -- You are healed for ${$393971s1*($393971d/$393971t)}% of your maximum health over $393971d after gaining Vanish or Shadow Dance.
    stillshroud               = { 94561, 423662, 1 }, -- Shroud of Concealment has $s1% reduced cooldown.;
    subterfuge                = { 90688, 108208, 1 }, -- Your abilities requiring Stealth can still be used for ${$s2/1000} sec after Stealth breaks.
    superior_mixture          = { 94567, 423701, 1 }, -- Crippling Poison reduces movement speed by an additional $s1%.
    thistle_tea               = { 90756, 381623, 1 }, -- Restore $s1 Energy. Mastery increased by ${$s2*$mas}.1% for $d.
    tight_spender             = { 90692, 381621, 1 }, -- Energy cost of finishing moves reduced by $s1%.
    tricks_of_the_trade       = { 90686, 57934 , 1 }, -- $?s221622[Increases the target's damage by $221622m1%, and redirects][Redirects] all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next $d and lasting $59628d.
    unbreakable_stride        = { 90747, 400804, 1 }, -- Reduces the duration of movement slowing effects $s1%.
    vigor                     = { 90759, 14983 , 2 }, -- Increases your maximum Energy by $s1 and Energy regeneration by $s2%.
    virulent_poisons          = { 90760, 381543, 1 }, -- Increases the damage of your weapon poisons by $s1%.

    -- Outlaw Talents
    ace_up_your_sleeve        = { 90670, 381828, 1 }, -- Between the Eyes has a $s1% chance per combo point spent to grant $394120s2 combo points.
    adrenaline_rush           = { 90659, 13750 , 1 }, -- Increases your Energy regeneration rate by $s1%, your maximum Energy by $s4, and your attack speed by $s2% for $d.
    ambidexterity             = { 90660, 381822, 1 }, -- Main Gauche has an additional $s1% chance to strike while Blade Flurry is active.
    audacity                  = { 90641, 381845, 1 }, -- Half-cost uses of Pistol Shot have a $193315s3% chance to make your next Ambush usable without Stealth.; Chance to trigger this effect matches the chance for your Sinister Strike to strike an additional time.
    blade_rush                = { 90664, 271877, 1 }, -- Charge to your target with your blades out, dealing ${$271881sw1*$271881s2/100} Physical damage to the target and $271881sw1 to all other nearby enemies.; While Blade Flurry is active, damage to non-primary targets is increased by $s1%.; Generates ${$271896s1*$271896d/$271896t1} Energy over $271896d.
    blinding_powder           = { 90643, 256165, 1 }, -- Reduces the cooldown of Blind by $s1% and increases its range by $s2 yds.
    combat_potency            = { 90646, 61329 , 1 }, -- Increases your Energy regeneration rate by $s1%.
    combat_stamina            = { 90648, 381877, 1 }, -- Stamina increased by $<stam>%.
    count_the_odds            = { 90655, 381982, 1 }, -- Ambush, Sinister Strike, and Dispatch have a $s1% chance to grant you a Roll the Bones combat enhancement buff you do not already have for $s2 sec.; Duration and chance doubled while Stealthed.
    crackshot                 = { 94565, 423703, 1 }, -- Between the Eyes has no cooldown and also Dispatches the target for $s1% of normal damage when used from Stealth.
    dancing_steel             = { 90669, 272026, 1 }, -- Blade Flurry strikes $s3 additional enemies and its duration is increased by ${$s2/1000} sec.
    deft_maneuvers            = { 90672, 381878, 1 }, -- Blade Flurry's initial damage is increased by $s1% and generates $m2 $Lcombo point:combo points; per target struck.
    devious_stratagem         = { 90679, 394321, 1 }, -- Gain $s1 additional max combo point.; Your finishing moves that consume more than $s3 combo points have increased effects, and your finishing moves deal $s4% increased damage.
    dirty_tricks              = { 90645, 108216, 1 }, -- Cheap Shot, Gouge, and Sap no longer cost Energy.
    fan_the_hammer            = { 90666, 381846, 2 }, -- When Sinister Strike strikes an additional time, gain $m1 additional $Lstack:stacks; of Opportunity. Max ${$s2+1} stacks.; Half-cost uses of Pistol Shot consume $m1 additional $Lstack:stacks; of Opportunity to fire $m1 additional $Lshot:shots;. Additional shots generate $m3 fewer combo $Lpoint:points; and deal $s4% reduced damage.
    fatal_flourish            = { 90662, 35551 , 1 }, -- Your off-hand attacks have a $s1% chance to generate $35546s1 Energy.
    float_like_a_butterfly    = { 90755, 354897, 1 }, -- Restless Blades now also reduces the remaining cooldown of Evasion and Feint by ${$s1/10}.1 sec per combo point spent.
    ghostly_strike            = { 90644, 196937, 1 }, -- Strikes an enemy, dealing $s1 Physical damage and causing the target to take $s3% increased damage from your abilities for $d.; Awards $s2 combo $lpoint:points;.
    greenskins_wickers        = { 90665, 386823, 1 }, -- Between the Eyes has a $s1% chance per Combo Point to increase the damage of your next Pistol Shot by $394131s1%.
    heavy_hitter              = { 90642, 381885, 1 }, -- Attacks that generate combo points deal $s1% increased damage.
    hidden_opportunity        = { 90675, 383281, 1 }, -- Effects that grant a chance for Sinister Strike to strike an additional time also apply to Ambush at $s1% of their value.
    hit_and_run               = { 90673, 196922, 1 }, -- Movement speed increased by $s1%.
    improved_adrenaline_rush  = { 90654, 395422, 1 }, -- Generate full combo points when you gain Adrenaline Rush, and full Energy when it ends.
    improved_between_the_eyes = { 90671, 235484, 1 }, -- Critical strikes with Between the Eyes deal four times normal damage.;
    improved_main_gauche      = { 90668, 382746, 1 }, -- Main Gauche has an additional $s1% chance to strike.
    keep_it_rolling           = { 90652, 381989, 1 }, -- Increase the remaining duration of your active Roll the Bones combat enhancements by $s1 sec.
    killing_spree             = { 94566, 51690 , 1 }, -- Finishing move that teleports to an enemy within $r yds, striking with both weapons for Physical damage. Number of strikes increased per combo point.; $s6% of damage taken during effect is delayed, instead taken over 8 sec.;    1 point  : ${$<dmg>*2} over ${$424556d}.2 sec;    2 points: ${$<dmg>*3} over ${$424556d*2}.2 sec;    3 points: ${$<dmg>*4} over ${$424556d*3}.2 sec;    4 points: ${$<dmg>*5} over ${$424556d*4}.2 sec;    5 points: ${$<dmg>*6} over ${$424556d*5}.2 sec$?s193531|((s394320|s394321)&!s193531)[;    6 points: ${$<dmg>*7} over ${$424556d*6}.2 sec][]$?s193531&(s394320|s394321)[;    7 points: ${$<dmg>*8} over ${$424556d*7}.2 sec][]
    loaded_dice               = { 90656, 256170, 1 }, -- Activating Adrenaline Rush causes your next Roll the Bones to grant at least two matches.
    opportunity               = { 90683, 279876, 1 }, -- Sinister Strike has a $193315s3% chance to hit an additional time, making your next Pistol Shot half cost and double damage.
    precise_cuts              = { 90667, 381985, 1 }, -- Blade Flurry damage is increased by an additional $s1% per missing target below its maximum.
    precision_shot            = { 90647, 428377, 1 }, -- Between the Eyes and Pistol Shot have $s1 yd increased range, and Pistol Shot reduces the the target's damage done to you by $185763s4%.
    quick_draw                = { 90663, 196938, 1 }, -- Half-cost uses of Pistol Shot granted by Sinister Strike now generate $s2 additional combo point, and deal $s1% additional damage.
    retractable_hook          = { 90681, 256188, 1 }, -- Reduces the cooldown of Grappling Hook by ${$s1/-1000} sec, and increases its retraction speed.
    riposte                   = { 90661, 344363, 1 }, -- Dodging an attack will trigger Mastery: Main Gauche. This effect may only occur once every $proccooldown sec.
    ruthlessness              = { 90680, 14161 , 1 }, -- Your finishing moves have a $b1% chance per combo point spent to grant a combo point.
    sepsis                    = { 90677, 385408, 1 }, -- Infect the target's blood, dealing $o1 Nature damage over $d and gaining $s6 use of any Stealth ability. If the target survives its full duration, they suffer an additional $394026s1 damage and you gain $s6 additional use of any Stealth ability for $375939d.; Cooldown reduced by $s3 sec if Sepsis does not last its full duration.; Awards $s7 combo $lpoint:points;.
    sleight_of_hand           = { 90651, 381839, 1 }, -- Roll the Bones has a $s1% increased chance of granting additional matches.
    sting_like_a_bee          = { 90755, 131511, 1 }, -- Enemies disabled by your Cheap Shot or $?s199804[Between the Eyes][Kidney Shot] take $s1% increased damage from all sources for $255909d.
    summarily_dispatched      = { 90653, 381990, 2 }, -- When your Dispatch consumes $s2 or more combo points, Dispatch deals $386868s1% increased damage and costs $386868s2 less Energy for $s3 sec.; Max $386868u stacks. Adding a stack does not refresh the duration.
    swift_slasher             = { 90649, 381988, 1 }, -- Slice and Dice grants additional attack speed equal to $s2% of your Haste.
    take_em_by_surprise       = { 90676, 382742, 2 }, -- Haste increased by $s2% while Stealthed and for $s1 sec after breaking Stealth.
    thiefs_versatility        = { 90753, 381619, 1 }, -- Versatility increased by $s1%.
    triple_threat             = { 90678, 381894, 1 }, -- Sinister Strike has a $s1% chance to strike with both weapons after it strikes an additional time.
    underhanded_upper_hand    = { 90677, 424044, 1 }, -- Slice and Dice does not lose duration during Blade Flurry.; Blade Flurry does not lose duration during Adrenaline Rush.; Adrenaline Rush does not lose duration while Stealthed.; Stealth abilities can be used for an additional ${$s2/1000} sec after Stealth breaks.
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
        id = 424562,
        duration = function () return 0.4 * combo_points.current end,
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
        duration = function() return talent.underhanded_upper_hand.enabled and 6 or 3 end,
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
        elseif IsCurrentSpell( 193315 ) then
            rtbAuraAppliedBy[ aura ] = "sinister_strike"
        elseif IsCurrentSpell( 315341 ) then
            rtbAuraAppliedBy[ aura ] = "between_the_eyes"
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

spec:RegisterStateExpr( "rtb_primary_remains", function ()
    for rtb, appliedBy in pairs( rtbAuraAppliedBy ) do
        if appliedBy == "roll_the_bones" then
            local bone = buff[ rtb ]
            if bone.up then return bone.remains end
        end
    end

    return 0
end )

spec:RegisterStateExpr( "rtb_buffs_shorter", function ()
    local n = 0
    local primary = rtb_primary_remains

    for _, rtb in ipairs( rtb_buff_list ) do
        local bone = buff[ rtb ]
        if bone.up and bone.remains < primary then n = n + 1 end
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
        if bone.up and bone.remains > primary then n = n + 1 end
    end
    return n
end )

spec:RegisterStateExpr( "rtb_buffs_will_lose", function ()
    return rtb_buffs_normal + rtb_buffs_shorter
end )

spec:RegisterStateTable( "rtb_buffs_will_lose_buff", setmetatable( {}, {
    __index = function( t, k )
        if not buff[ k ].up or buff[ k ].remains < rtb_primary_remains then return false end
        return false
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


-- Tier 31
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207239 )
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
            if talent.underhanded_upper_hand.enabled then
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
    "ghostly_strike",
    "grappling_hook",
    "keep_it_rolling",
    "killing_spree",
    "marked_for_death",
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


local ExpireSepsis = setfenv( function ()
    applyBuff( "sepsis_buff" )

    if legendary.toxic_onslaught.enabled then
        applyBuff( "shadow_blades" )
        applyDebuff( "target", "vendetta", 10 )
    end
end, state )

local ExpireAdrenalineRush = setfenv( function ()
    gain( energy.max, "energy" )
end, state )


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

        usable = function() return combo_points.current > 0, "requires combo points" end,

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
            if talent.deft_maneuvers.enabled then gain( action.blade_flurry.cp_gain, "combo_points" ) end
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


spec:RegisterRanges( "pick_pocket", "kick", "blind", "shadowstep" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    rangeChecker = "pick_pocket",
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "phantom_fire",

    package = "Outlaw",
} )


spec:RegisterSetting( "mfd_points", 3, {
    name = strformat( "%s: Combo Points", Hekili:GetSpellLinkWithTexture( spec.talents.marked_for_death[2] ) ),
    desc = strformat( "%s will only be recommended if when you have the specified number of combo points or fewer.",
        Hekili:GetSpellLinkWithTexture( spec.talents.marked_for_death[2] ) ),
    type = "range",
    min = 0,
    max = 5,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "ambush_anyway", false, {
    name = strformat( "%s Regardless of Talents", Hekili:GetSpellLinkWithTexture( 1752 ) ),
    desc = strformat( "If checked, %s may be recommended even without %s talented.", Hekili:GetSpellLinkWithTexture( 1752 ),
        Hekili:GetSpellLinkWithTexture( spec.talents.hidden_opportunity[2] ) ),
    type = "toggle",
    width = "full",
} )
local assassin = class.specs[ 259 ]

spec:RegisterSetting( "stealth_padding", 0.5, {
    name = strformat( "%s Padding", Hekili:GetSpellLinkWithTexture( assassin.abilities.stealth.id ) ),
    desc = strformat( "If set above zero, abilities recommended during %s effects will assume that %s ends earlier than it actually does.\n\n"
        .. "This setting can be used to prevent a late %s from actually occurring after %s expires, putting %s on a long cooldown despite %s.", Hekili:GetSpellLinkWithTexture( assassin.abilities.stealth.id ),
        assassin.abilities.stealth.name, Hekili:GetSpellLinkWithTexture( spec.abilities.between_the_eyes.id ), assassin.abilities.stealth.name, spec.abilities.between_the_eyes.name,
        Hekili:GetSpellLinkWithTexture( spec.talents.crackshot[2] ) ),
    type = "range",
    min = 0,
    max = 1,
    step = 0.05,
    width = "full",
} )

spec:RegisterSetting( "sinister_clash", -0.5, {
    name = strformat( "%s: Clash Offset", Hekili:GetSpellLinkWithTexture( spec.abilities.sinister_strike.id ) ),
    desc = strformat( "If set below zero, %s will not be recommended if a higher priority ability is available within the time specified.\n\n"
        .. "Example: %s is ready in 0.3 seconds.  |W%s|w is ready immediately.  Clash Offset is set to |cFFFFD100-0.5|rs.  |W%s|w will not "
        .. "be recommended, as it pretends to be unavailable for 0.5 seconds.\n\n"
        .. "Recommended:  |cffffd100-0.5|rs", Hekili:GetSpellLinkWithTexture( spec.abilities.sinister_strike.id ),
        Hekili:GetSpellLinkWithTexture( 1752 ), spec.abilities.sinister_strike.name, spec.abilities.sinister_strike.name ),
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

spec:RegisterSetting( "solo_vanish", true, {
    name = strformat( "%s: Solo", Hekili:GetSpellLinkWithTexture( 1856 ) ),
    desc = strformat( "If unchecked, %s will not be recommended if you are playing alone, to avoid resetting combat.",
        Hekili:GetSpellLinkWithTexture( 1856 ) ),
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

spec:RegisterSetting( "check_blade_rush_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( spec.abilities.blade_rush.id ) ),
    desc = strformat( "If checked, %s will not be recommended out of melee range.", Hekili:GetSpellLinkWithTexture( spec.abilities.blade_rush.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Outlaw", 20231129, [[Hekili:v3vBZTTrs6FlQ2QyiJKOjOSKt2tuvfBFz34Bt2CMEV9BccKeKeRab4IxKSUsf)TFDpVamV0dainvSVVKidmONz6UNUF6UNz4TE3(PBNUiOi82FB8OXx45n(hh6n2B8OxF70IN2gE70TbZVpyf8hjbBG)7FVSio4r8XpfNgSa)880YS5WRwxuSn)p)QxTkQyD5SHZt38Q8OnLXbfrPjZZcwwG)75V62PZkJIl(LKBNr33xC70GYI1Pz3oDA0M3buoAXIqEZdZNF7uS5N75D(4Fy3D92D34F8pV7Up9yyW957URiD3DFS4T7UlizXU7EBCWIWD39ZXLzzpT7UYCyQmC3h29HksCb8T)w4J7UBAryqCX6D397blweLSA3D5HffWFO3(XY(s0nZZIkcZIc49CrwqsomJH(CtAg8FNNMLfoVig68LzPBGUbMrAu07sGI)C0NHge95WC93HJoJUz(6GKvHl0BNNKgfRHo9Tf)NmQP3MrqBEBWSN2MLMUegFr5L5qJX)M9bPLf5rleprWn0OWiGD3F8aGm)AusAgFUam1TOq0OLqJEFAY3vS7USWLzH5aFDAY7zDcVda1JzbWFxMehMdYTi4VJG)FCkilwuMX0A0j6BWjzzgmfH(2B0WXY(wNPnczO)EqX818wv)YrVHZPuFT3WlLKbMDvYiHA77q12bku4YZhFfJcFmmoa43VnmyEAIq4Z49HpLIAEfrB4krP852I0WCg)4HGKiKDaegNhRJykzIVEBw4drPLaFywzrbYaGU6FGIjg)zZMWfrWifvNeFVXNfmlkoQ4P)dSdzD3Jb4xUmv20)Y7E)jQthVxZMoWASh0MMEJzp)NwSW5KuP9J5QXS2hcFr6wK7X)cMw2pTilmjiokb(7pwIZ)zHlzRq(yACSKSPjHOQqI4FNUnmbNJrG(YFdS2Gu(9rZd5AkfbXHjfHloJ3nRkdGfFfHWBlEmfzGlxMZ4FFAn28htlJHVFtqucY(MfYgzWtMHRntJzgpcUNjlExAzsHyq83xSixynrDmWO8uS34Mebj92W5rWu8)nGp358a4B7J65XHsfjblkoDv0C(qhfFHyh()i0nQ4alJYYlq90C9vn9XwmpqU(DbOm(eNVJCmvf2l4graTiHo(Vc9b0V)LSiyeLMHld4MfVDACuEroAsFzeooG)63yoiaj3S4Wf3(wWW8CCsbMWdlEmmmXhgL(HpfMZnnNfTL)AMk7B5Trmv(pFkuyE((WWTIhIM14IkCr4zm1EywGtU004fPpMWL()YgWQ1dHlE1FjdOyoiLYF1NUy0zcbtWdPr4S)HWSSiUX76gE7uPXZBNEIuTzi4qA(95RtlgkMDmxj95dMHMtVHzHOIdmbUE3DVE3Dp)CfHIednFRVPIWkTEv1WY)XO53hMz0mWNJ)S0KY8HfrHzxmY)1BbH1a2G7eXGJGgLBVTaCJEycR3jzfi9JIr19sxYpkNeCrKu3fT08(GeCv6Jr4s7eKWGIl7JwQkzFeqkuPQNe(5cMoDHQaRnPLKyd5MvhwKvg6xjSUbewxYAAv7Yxha)F)f4i0U1EGpLbiR8cdwz9iIjcYJbta(GUN)c0wGQ2XYOvRlQjAVkpGiTQLj6ua7Yx7SlxeYL7RtZbKe(5fzr3hcYCUktToTrdK0QQpVhKhWId)CWGdRlVe7s5BNdCi)zXPPluhgqRUsTvlIY3Iop1Btboixgugxqz0iDlmFdlQjYdbW8IXoG)YNJSmRygW1YaVbDw(BSyXdxS0UUnQ1bofUWdiWAUtbE)Y1JFevC5(oJtzgyFGH3qAMQ)yjjuDhmaNkXLW8aukXPcZ9JpUcWNtMRNWiYPIfXXSpMR(GsYbulGBKXX6n5dgwZ(46CvdH4uaUimbGUFexHP(DakUnbXY3r(z3Wh2QVJPMFPr73e85ALECUEXpknALZntaywdqHRM8bCggH)fokKd)SYygmaGzhG)BCY)qOWJUMvf0jo(nOui4XGNeUdqrOa(tqCwyWc4fRdqsC5PvKrZsMyi6qFKWEG2K4JH5Qwc3MMNhbne0vsa3Dpugd(Kdypa8oVjsIXH7mFGInbXOGWyGw)9lamNSSYTwUkrVRaldHqdHAXbGgHnM3dvk)fRdkunlm)(kRbnzacx7hghJnWpmjdbnaoEQh(agYk7f7LwC)kty8q98t3UnnROmbGYQ7Fe5zP(BtHzv(qWKt0CeabQKoMT2Y0PCWMzaAZAAix(nldw)HYF(IpMQkcDA1tCQD5ivDbov8bqWCTvCw(M9EwgUCzitv2xDwW7V5BzRGa(lQaFoBn35mpCAREyJt32ehqbdJdMdqjiwsb8RZ9KHJUbdIHnCq9wC8Cg3f(5J5kPv(45Aov2tvzp8EqN98d7n7HPB5xeKTkeKTZWi39xkcC)AM8fn4eeTWNHwEieME(qCic(ThlmTXLTkF6qvV7RMVyimHnys)t2edI4RiAlUgvmcWWkyboihO8OoMVoeGCTGVwBbG4hnH846qEuP5myoV7951(wqBu5pbOnwi5HAjLqLpQoW9XVbzK)OdqDZb1bF()WhbUZHVlO08f5436nQjZi)vaPcg8rukSq)PknnWVhqOZKgAxgWJpllTCLWahAvRsyJbhHXXTrv4Ap4qmjZXHKQDfBDBTNObntKnM8HIM4VLNNgT5TIfuptui1DBLttlf3QjqwzItMRi6iSpCH4UrHddic7ZDJYKBlA4miepFnZCExYmIjEFw4QqLrDq28GKq)cmPtjfSU41QG3eVFBzCEObippnSGXii2C))v5IvBqkz0wneHZcw5NU0hLV3NBbleGAY9ZvbmSAWSDlGvfm6KJ)lToy)Xbrc5AcZakXR852jkHyGxad8WG8suf(0MB)QmeU(MWymQ)ESa(pydwEJyEDmny)EoiAQSIOIo6px)pzz2ji5PkCnOVD2ssg(N3YMJaCxXKewwh(55XLYGKz4L(v(uchA5WZRnc2D8qVuq8p5lbLplzJKa9zCTpbr)XsUvgJz0hF2BL4cuOWFLHjz3D)9Aqjd6sScQWBoPb9kwuOZKdJEDglut0Cw98ONAiInrZbgq6ndEHcx6xGCVTCX06i2YDMLyIqDqrvHuPy69LSyoW1fVldqYpJV8RAz24QvA75cjMQqtYSCSRzPeyUsh3ZLrjPrMt)J0KfvCcOoqw4HRf03UlnZjdlSvJ2Ga37r(14a(8gi6a2K9kzI5qMbyBzd64ecipSotqcqLP5C5GrQDUgBLz8S8mrYNN5mKHjc7e1HTYJff7rSLi1ykrP1z9f6hHkhM)9h5TpfB980szYttvv0NNIjkgJLL9UvXPZcIPIgRYTTIWxvGOKTk1LHLjlcZwdAtGhZYTBdZ8X)HLT6k4BBcskq5FL)F)8qeNfGq4IQWNmd8vhfGzievahQQLGFgewMgGsjiXsyfq8cFzfeQNhQ5DrDWJQrQZ8QOjqbjlZPS1JdnzpKjGza58ECtW517MMeie9O7UZkcGoWeprbSTnF0H(rDe36eU2ynXq0JeOELwHEksPzjoPBbpkOgQHHflWo2z7YwHU9L1QKTywMDkEHiGhmE(w9IwilRbbkfao(U6kKYOBIs2OQNX9Rt)VjdwMh49jrbDxUjHf0xp3lCibJnZaDhOgf(EABsAIJFfSsweGChJA6JwnhFQAy7mjrQLpyz43)JAlzgCynVJvzv68d2gyw6keHjNb2qQjUUo1eeqR7aZHNcdi4Hcw99clbyOiNGxghB(vDgdrf2l14EmVoWtV48xx9yU(8MO8CMJkT8fb4G(3Ly6BRQoCWgE5txbRlsiq6dXZw4VromnzFodoxQgsiLUG9o6CdoX6lOZbiBjKnPVuOYAc81LDBBBief4EznOtQ8OiKcC11ezTSfpDCEDTZRaIUnkluPYgIM(M2AkVMDVsuUowMYjZtIQVnTkiqxwbRAbWXvsfixRF6BQT(qvbpr295PgwVuGIxrczvZzxR1qPsj7uxtIE1LowB4XxKzWYqIDfdKGujcRiUFeaTmLvGUBnl6MEH9mGjzMi6k3NHBZJi1iNYEJyfBw0kwHEu8oLk2ZfmD2AJNiBjVm7bM7UiCbY7t)uNJKVs8quBDMGQxBR9nlLKPZhx(5OX37Pyv2CejTh0eYFpkiQTLvcMb5Q8Skzjctcu1BhftI1LUZTOo0nlya9BHjPT4XL0zavEw9f5z2euR2aINJJ1WhhdsGWaLa3CNLZrcJk2m(5Rrbk83FV5QiL(OrOVChPUG8jCxYr7Hoc3a6ISQKkRpeDLdTYDlGpyEi6heRw6isn4wYtTaYqA6I4Y8cusmVOvfZlulfInwXA2W2u2)Vkn21ShOd9xwIOm0m0WtxDvZaF3Hz3ZYaVEZ0s58sWDd1MkqpFZOXsW4wqS)CwnI1BQRqy3GBLj)vv7KPBNIHRKUCPpaNIvQbU2QD7Q5XiWlIAeXG9nAONddphULdesHRK(QIfGLmQYCEywWGDt(qgVWL1(fzbRstqUn4EAZmFwTAtajKlMsdFGd7j8q65gvz5U4g52gOFLrMSOK7rRTEdJamyU6conQBBL1hT8(iuKRA3y3TBGHvmN98WkZh3uf(sdlMK1v8eTHX6GC)Ai0MV3Z49maiEUsMXm2ERe9mXarY2yLUez0T9RSUmo5CLuJCy52MWay4LdYHuTGbAkvK3GLwnhKElQbJtLcqrMjVAuRcsWzWuPRlJXegpQlxfpgLSiFEqMpwHx4ltc)6nfEJCgqmOW5GR0Cium9S9S4sGBOkNxead2KN8xSnVDncGxonpoTixPNXHNRy(fnA8bm8gFugEJ5jls6iVPn9Q7iWNAddqa4kVCg8GLLRc3VQBWdzImJe92JSjyY2jIUZDvWv2sGejMOdKsDQAH8u1iOXguLiG7o0BkEdL7srIy)QW)aOftJ95BMfnHjWI)5ajo8)AWMngXhPL9oO3ZlrVHA1DsjnEYGTzwIbLvGkNPuOrzcRy7AR3975Ab)xVlMLjASZXBjE5YaoBDnBAmmli5El9ivTp2aSkgvL4A1ZwspQ0b6PG8KCtklCgAINZAg1un)QGmY2twARD9DKW323(a1XhPf(Ex5N1B8S)Djmz9b4hpQTNZeVnOCrWCT14xxV8atAgJ0POFbIV2ilbokdA1g26DYOlvlchp3iQCw9TTLlR08V7lTIRSWFRoKdq0t)KGH4kF68YNXY7QybKwFXxnTxkqsqqTTRd4HpjLx1HSwz8PjoPY6aI1wxt8k2M)J)AE6IR6hQ9EORuetkLimCHgySKtKstnjggnm3MRsSk2vPOdYaMBC3BJrDoa12l0v6yvx(2oFGn7ez)S1jxJAmnoyPkyEZ2JCdaQNr(CAJl3GQCtw0UwT4owARI9m7G2wmDuSxiKp6Mlywh0Odl55kwquT6PQvOlAC7k6K2S7Ql3P7IAFSgNyecdk2yNuwL0((2zF1kCMUC61snLOz3R5(Vyh1lmREFKZ86U8MC94oELuxNI7BNQd2icdRClGhH1bw9jXI4VurQA9imPL(PGyKrMjC2A2Eoz0rvRyavkQ)snO1TSU3VvCnT3hDzsAQfUjKT1AlK7Ywc0GAkOVfBfaoTMoHZxNIhsQSWTzrBGfSnblsacT59v9pXAKqxTbBG7pogtl7nHnWD4o8QhxBB9uhJYtTdl6mxX)WpwRPZ1TzJVGL5qjlPg13dbrXCxGwmbdhueGYTXv35iSj9TrdbSjChU5USIkOgh3)KhoeN(70pu38O(0rGjoG8zLj8TjMPmWkXjoc9Y0hrdSvsMstH2PLQTHx6OQRTZS4QIDwlJvEM6WQRRCzuvbl5f8E)0QCPt0V54LBcupz8aAzA2rSXhDEgwSTf8TbY7(DmjLSYUjZcXEL6Jzyfvq1wU)yPqGWNSvjppocehNgmzbj8AlY8bSQi2eoyvSvoqm1t)LU2Ec7BPRv8asJqNNWLbnHmZTsZVSuy4TmN0Oc70pf6m9wkkr8QDEMmwD1vEb8l(K5bB1YSfpMEE)(FJsfaZxgEPYqb((a0kCwyz9Jndt2ZmwXbOrPkzCODT3XqnOCP8As)tKrMrczRsCc6yaUe5fUJMa9NbTQzmtnyRy82)vjULGXlGKPi(QcCP8u2oir44nKDAfWJCpoKybyP4xUYLCxqUaTWhpb)iCRIM2qaT6vMidFIs5xH0tmBi3ommSF4(kdBQ8If6hUD6JbzO7tyO(julpAd2XIz23XXF(D4wTaKKzi3GFs(ckls3eWyp87Dh8QM5VX2oO4fjZ7stGUI96VZCL83Xbbz9C58eEFFVppOn6586LWG(TEnu0X(Z25Urh5(gSWShgFK5qV2XiwBZrzoAjVseQP8UpqOoiUkd(6QpCfn9Sx4yqy3RS6ypyC2PDPNPFYQnP9BoACdsju1E(E)KrMAKvBkVHvNBgZtfOCG21tryBlcO6sLtPtRDNEB16QloA8CA6rn0vp7ATo2nACxg8hr19UmDQCW36CrTL)bprCyh8GLZoO3l4iMI1tD63Avk44J27o)iTc0Hfv6ZnGb3S5dxGzp9d09KYPBYG8eN7jtAYUHaB0HG(Uj0PNb6Z(rlM0fXhTFg0D40TEpxymgT3mgwmHx8fdhBZ0xEKP3ljWdsj)8f5hfP(bpJBd69XsV)RrV5ae(lGjjh616N2hJEG(Oazs5JhyYxg65Wy8btppRbOyhV18UQTQB62MWDp6vZ9Dlrpr0KxsQ3oDT3TWw0LSjDBuFyuVl0vDZdtqtJx3TrRxZu1616wqSmyPrv1TFPdkB0eDQBzGsJt0i1jBshWy4FS84OMRxJf5u7JSo6jOozIg00olJDKIYumAqpZ0s2rQPxrxtJBKL7TJu2O44gK2rr7T0OEbXV0ypCW27F5dz8yJ58yhcQdmShroWFqOKpkAWVKiW)JQhCGX6OWFCq7J4O)yJO7pk69LBz2bLpk8wsFYSki9D7L34xEl8oSxQxmsdQtxPYos5d0d9lVNdhw6pcCchwKpcu2H1Txok)fGyZbfpyldoSnEeM7)4lOU2Up8lmJciHFdFh8I7Ta2pibWRXl5N0Lr13F65dRQa0PtEL6nj5Up8Ny3ekFlDnkU7duJA5UF8mCpkpP(UN4m2EaFcrAQN0VdfS6uYgPK06EUp2IxpUN95t8gVrdgWyRFBEnlUNC3OLtmxl17eQB1dHCO)jTv3REov0F(zYpUQ2r9oX5NoOhXxE9eVMeeh)B1(kE7(YrBIHspXoLvCf9RfFUA3EFSbivdFzUyh3FLVtS4vo1bemmsDiQkF1JK1o(0xadcmbZ3wxE)DsxLZrjUXFuwUX)PpyYONFU(z8FPeMmYQz3mXR(zxFPY7vUkJUEYf)iyKrBhaYyGFtDBrUN6YPBNWU1pzk19DCzBEJ3yGnADZD2ZQ9rjN7GedU(QNF2(w8bO8GNFgpQ390oM3x7nMEIOQxFM1Lg4KlW5HYflOCzjDrquLMI7fdYo1u3uh3IEjCiguJXbf9LXOC8PyXe4Q1JFG3Ggu1VFYuV(k7rSkya9avNiUgNTq7dLh4XuWCWeieyUQqMdbK25YYv3REPx(b2s3VSFZpuTvvPIau9O8l7HkXXFBp06S1rpGtOM(f9WTHuZZIQ0JEdaGO2xT3mz8PwclgPpvFV1Gqa6X3ZU3m5Yrmw0l4VPfUN4MhqjXeN(x0JBMO(R5X5EN3xZYFptaaCNPFD)zOW9u36hLcXCFFbnmEKWIe1TwXnRMVqDiyEhNXhkZbaFCaHh5F4kAVRfDXz8Fgl4gf0LQA)lPZOBC9RwHApA8BnHQgh2nUpLCToQzGKvBM(pqei1j2P8aKMlpvBNYBtb2pHeQp34xmc1xP9deHW8P8C3vBuMnwHwBD(7if5D9m1ztFUHgLGwSTA1JPNQUV8RxG(nYXKZEEPCwpuMC6P2PNrAfDh6bNfOMZga02jK8Lx8d4wRZvX2YJ4uV1R)j0mcIPNW8K7t321EdVu1wDNLYD(yQ16mTZtME9TEiRZVzI1ZRoLAcgG67KZ8Xh08(BJJA2rKPscMPFFVtTs37GVNo3Q4z3AaOvsEwY6DsdNISNFwZdZZpBLibmkjx951t84IWVbp4xTkG6(A4E9P8NP6l77HfX0OsRYbLk8ZkEQDM8RELzrASTtYz9FvpIwemz1tt2zYdWfMHXdWLP9hzCkTy(9XuxkVvIQ9D8v9s2VEGdOljIhfM09fYtR7svJLKwa7BlIuWqGQI41tgxVQ253W4BVi3g(MScTeMG8bni)qqCN35uKWUj8h0Zj()Rz4)R8W8n5nzFBShbZqFlT27eNW37zYpVG0)IEGwuwOmiJaJY)p8UN3KdBK2j1yHQtRKswA1tzRw(xhtwrcNn)n4kZgCft6(EG543y7SWCL1yQNbDGtPgNc0CwxT8kJ)BMCLv)RF4hR1koM3)7M9j)wNNSMqTChJ3Z9kLtAd6tpQ8d7jS3yFnArN3yN1w7WV12n5onMCbCBPYZ1PMxL(ea9AHvAPjOC1OZ6bgJr)ozNg60eVrWIkDgL4ku(7VsXqZHDRPtBsv63v)Eu)6lhzvcf9VMFHMxfqOXfNoPm)czsPi(r1XASjVw0TEt1nHU5BQU8ZTqzODFNRVNfuTktClGBskmF44B4QsMx15NPCtsZZALYLe9nI7j2Zhn0ZG3UFlDMCzZJkNNbb7HNvDv6HRPVzuV(W6GoDmi65(KfCJhiVDVf(XcBQS2Q1lr8BgtYnWmDEc9g6x5f6B6ERvS6mqQB(7VneTMxN2SeJ6m1W3yCNyBxBWOKBUAeT95rnpsSVwSF5glVX1qj)m2Ll9eHu2R2Aef)29jPGwwm2jlWOFh3T(1(au4UF5HV9ZvfEP20pHdqezX9S7Hp2dXR)dz6al3kdvth)UAWCVQoDIV6txmsgftaVC54wxjlsU)mQY7yfNHdFGzywFURMlHAOd9P5tYj)RRIZ35vSrvlSZDiGoxhp3iep3arkcOVPUAcfcfZwZZ6u1QskV4wrVicG2kBSG5SQeLIcLAXacopssFmHa8Sp0rURnZ1ePmBJtjns96l7rdZwRvEJhq09gfUvQVBCpBkLIAk090kNRfLVpIbx3pFliEukwQXDjcUqsQnzI02IM13K6eVuEBLlQnYutWrcZ3UJ5S(yn3qg9nJEVTOXT796jr3QlL6aNqzXnEFt1ikkkzATmu(t7zIMPt75l215o1mJo90wzvIilVvsvI8(FL0qNsUd6PN(jp3LaHLdt7HANYmOMsTAcanONp3LME5NB6A2wU)4KRcuSG0atYoz9NAKi3RLSCTtmHSvgr1FyBrXxMBcD3SuzXKDBEW2XOvAS71VAHwtIfI6iXgExB94QspnOo4FZ9yIl3H4QQJ1DyE78T(U3PUvE)R3qhUtLrJo3B8Mp2XquvPN0ArZdLdtX9aVsU72kE6RDzXADxyA71OaIqt2T9HRhl)a9AlnyG9AKUkvoH22rVwURP7rbPrBDOPqTszKAhL3mpYvon)texP2Dxh54DnE3vE9bYQRrQ64k6(6jy2IARvaA1rhO8X2dR2meVAR3Vv4ujkTpPVTMOH7bm7xaR53(BJVAe7Ex82)Vp]] )