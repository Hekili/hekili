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
        duration = 3,
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
spec:RegisterGear( "tier31", 207234, 207235, 207236, 207237, 207238 )
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
        cooldown = function () return talent.crackshot.enabled and 0 or 45 end,
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

    -- Strikes up to $?a272026[$331850i][${$331850i-3}] nearby targets for $331850s1 Physical damage$?a381878[ that generates 1 combo point per target][], and causes your single target attacks to also strike up to $?a272026[${$s3+$272026s3}][$s3] additional nearby enemies for $s2% of normal damage for $d.
    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "physical",

        spend = 15,
        spendType = "energy",

        startsCombat = true,

        readyTime = function() return buff.blade_flurry.remains - gcd.execute end,
        handler = function ()
            if talent.deft_maneuvers.enabled then gain( active_enemies, "combo_points" ) end
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
            if buff.shadow_blades.up or debuff.dreadblades.up then return 7 end
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


spec:RegisterPack( "Outlaw", 20231105, [[Hekili:L3ZAZTTrs(Br1wfmzKenbLO8MCKSQy7lp8TjBUiNB)MGGaajXkqaE4HK1wQ4V9R7zWJ5rpaG0uX(U7d7glIb90t390VNb3yFZhV5AF38GB(1jJNCHT94PJS)RJTVC6nxN)02GBUERR39URG)rS7g4))VxKh5(i(ZpfL46JVEwsrQh8O155BZ(Ux)6vH5RlUBKxYMxNfUPiYnpmj2l1Dzo(3EV(MRVRimk)NJV5o65(YBU2TiFDs6nxFD4M3bqo03pGp8GmVBUgh(522NpE63T72D3(BU5ER3DR94rtgT7d7(a7XJFdmcLhBpA6UBl2IZ5UBhSmnzZUBVUgfFhIIdfGW0ZNCfdc)EqK7N2D7BdC9sI3DBEc8)whG)WtjX(WFeUjmE1UBZGheMV7w)KGS4xb)JhCJdZG5gaCq6UBxhMNZgi7T3Mg8qysr2UBVRippjEeov)rwahgHB2e4hcyA0t1VVYR5Exyuy(t)B4eYMUhDX3Czs1q)X39(texo2xYwoa98bPLP9e2V)9((gxKcJFY52tRgFa8gjBrQh)nkq0)79tdIDJcJH)9VxGR)7caKc)RKOOkWMehaRHW4Y)ozBqmUgdxU72)gizHq(9HEi1agwUBuqCEG)z8PzvHBQl83WtZFmbjGlxMXOFFCno8htkIG3FJByms(UlGHzWVC3ti9j6EgiVNXlExsrCEjs8399r6kYtfXbgKVgNnU4pWP3g4fclX)LlFTZPbW7oWfGvuqLGujjkkzvOhh1r2xaoH)xLYg1uGLHPz5OCkaMeGkaBGUdH2aCeEUiLf)zFqy8joDhPyIcSWMIlyCM)Oug)xG5aM3FmneWOKuCBqrgSBE0nxhfMLNHBFxgI4b8V(vMYaGZDxuG)nVf2e6Hlky7Aq(JbbXoaw6e8uqgFByA4w(J)bgacsZQLFFl)fkxx)7pHmACTFFqW2YFeE9CoFd3rEgBpaSKWvAssKFYJXCrHFEZ20Khc8F9pMcqmdyzzV(Jxm(SsUK7djHiP4HG00qFg)SzG3CnolbPHU3C9jvYqJanrE3NTojFu5sD3TwarMJmJuxRJsdqPiybmB3TxU72NFUgqHLOMJ27udyHrVQgTCEm07EGCjpSSGCN7sIlYgLhgKEXyNl3cCUHmK7KsKJagfBVjh0FEyCU3vrkq4hgHY(fM4Fjf5zH(LYGxNh4gLVMZIQeKr1oV3ng3Y(yiUppgbmifZEPLIC2hbte1Y9XbFkNjGNlYW6IBvbSrCDSn8PfaFAkBu1djBTl8FD8rKtAG2tasmsaVqHa2GhmcFweOfWbK4C8dfbXmCx7Q15o1)cmTPbltdGPeGvdNqgc4uEPXP0pGZTxNKLh9KtwEA49baNMlO0ijRmGkyvpN3dCbylHtgOZHnLtXPS6PEaXX5UOKeFr0ag1vIJYpmBlA)uEm5isU0TikNsVHKm2VhKjkSSnjllegiWdJbncpueb6WCz)aOnBtyLnbUYVHceqouOK2LMVFgmlKMwSvtBcQaYnkkb1Edgxz6kcXbZNHmUujkt6Mlsd9UNsajzlGsbcd8bxG3Xy5p4gva)Nb18jU7lojB3MKMxedMSL36JR1eNTja2KncORHEOUXfZ3DliEEQU(g3n3bwvBGXPv6UsbBw4MuMScx1bAIy1tCOnDmdnD4EYXHIdyS3pKTeiKj7EvgSCza8ShcCexf85ZBRZg3pbIFbOQ6ZHTBS)FGWuYmd8h5IkkSAt58qfgmZcZYgBoOufAM8Ca6Cx62GoRXqhuEdXNZ4ANoFcx4Qw9fNJxRguK8WNbzYZ09M8aR9OiNC30vbaV9UiWNcNLrfPPpXuEmHRWWn03H5vWixWbKrikckNMmMlEW5TcVQKkSvE(JGfScr6FWwyGNT5HBX9wLya6(eZbPkeL7DL36aWAIpFpIp4zdQN)X1bahkf9Qf1G)U3ddeismhRqhQYEc0M6xrdFlIF7U9hyiOiDueXDW3PwfdH9kpqCWH)hoOdkC3ukHKNFg(UVPTD))eOng9Xkmb0M(uTGg4bgaNZQmmT0L7gAAsXQs9sOYOAEn6di6U6grERoUH6D9Yr9FckVLeTLWFbny)vJ6(RymJ0K)QrK0IyJ0OsN5GP4BpesmZla8TThBed5AugDh4qQJKYk7PmvrLppnyvGas7M65gh4aoHcXgKZMcBr7mLpFBruwGI9i7jIdmcT3M58pl8xTbHKYyVqCS35UYjzPdYMUptZcgyvKBLP2gwnYSDlywfuDKH)L0eiHlvCu5HOAQOgBe2jq4PtrSFq6AWdbqdFX2TbPo4F0yvVgDDYcqPcybDXHPZon)ohweto42bNOeuJ6CMIzIh5W1)uaXq4dKYa3ScCVXPTp(vPOVoBcIWOMSybmDWkcThZSMPAi49CpqOIQmniL9BPfrbFxZFYIm2n(PYag526z71zHp)w2AeIHSCrc6lc(KxurvCfSio(f(scrTm43BuUkQ0djl8jDVnBqaI(6vCpC3GhmHsSg2ySgDhAaQOpbJs7Jxy3ykqI2(X0cw4dW6bjzdWF7TvELiaHFIHIq40n44qUE4hXHXZMbxUedTJ55aYYeDU6KwK(Yb8aclRen6hPP03AZ7aAwhwIEH3gm5(GrUFBgQXKYw4lL0XHZ0nWX7MDbsatQaHy(ugwf(occb5d0xewqJUmxklfQ0K)iKEefmmtUBCvoIHn8O5ACwU)USFcTl3u(N8zWp7kPfDISAEhPr4iiVcsbKBYV((c8FZyGVlfIN7oUs3ALRtQ1VUNQpzCW22dMHtnlkApHj2YKPOktlN(NPHkk)762MCTFFnscCjTgepojDJBeZs9yf9krjXRW9Dl4s5IpJH1tvgpgwwtsmGx6IVvru5795UDItOO10QaUysaL7slNhHK(GXhGVdkN6(O7tLslO2IYuv7gbgz9HhS2fbX0YnMzMTIQ6qlsttdo8Dwd0zJQPgIr)vgdUp3I8TrHGZBbOdzSIRQYkikGbQI3GofdkIcAsivzyFGaoBQuYW0mCuQClEAq5RZmwSBXLkNBykCknoJ4irOX2yM0K)zyEk3gJvc4r(4tWr7LuuL52erLhEjykRXucYE2QOK7CJidGOo6LeC716ah2MxrEIqEZyRBITeKEbpPjAcI5ZTUyeoPfqOr6MlBYRI8qB11B7MitiMuLS9zgax0z4e58aFBj98ARqzB6LjalRo786LNb3rZQ5KQ9xEo2HFyI3w58XxLXEcxgGa52vLe0s4gxhjUi9FqJDuvsFvYo3NefzrKPmAoQG9E5SwnJNZn50S2dOrLvs6W(K4n)cShm3fPosPpHVNCYPIPTHXjs0SAw5D1F0e8yzUUKt(jYdN2aWQxdcHkNvLOGcWVTmfMJKPW6esEEnHP9iwRd2OMfMMScdpGt7BjRwZQZQLufu8bKfSCvIRY(2QJPtRMFZzuPLy1v1sPNbsIszUSXujvQKkzm)ZIS8MkIw7O02q2F6YktjY8y(CZy7fBbPuEbMRsNvfNnJm3rM9HqZWpvubvb33r9tkDPMNbBdfJPCmal)BatFuPROIIJ1g0jeSZLWkAbfj))Gv(WWYi(zeeUymVMRUiD9IAs6GlfIEzOIXFssLSBtOq0fmsbnnYQPOHs0h(gojYohyxvQOqQkmY1WrjtsMstAwW2SqsPYRzpHB1gG4kMxHc6OtkRWotUTrfcU6ZksFGP0pe3c9(Kp27ilR5(efpL5JNvl7c1vt4wj22D4p0(qzlOGrfJQmS0M3v2uHXjRoNWqlVY3C94CZQOyjSVnK51EvHyKQJkHrrX0RwTYyAcxWQ)mbXQ9ekRn6(Lj4Y3XPmP7QoFlbFEkxwdVCeGUbUc(iBozXJh3jJWBnYGZ46oy5)Rc1fMSoYwTUKLuC(EyZFWKosqF1fLUArIfX76hRwhnjeLRzaIU0N0jvp5YmZQgBeyFa344L3jb6cXkeP7cvdASnPYGNCY0ztOZYc0Zejnpk5rhS3gKEptTS8WUuCylbtyufu2wsJhQKe025g54XehLhQjvEBWozXzvDJSCZ1fGivYYLoGRcSsWWLB1hxdngDQGO0zmxAgpY2GMOwvLWfM6QK8CUu7L1VT8oSG54vxXfIo9ykf5I(JWsItrgIzOY(GnzJyKEtA88tDxLeJmxWk4M7CWwciigeimXdA5fuD(hObX3J6WThfMnY4lYv33m2AlosrSxUBOECtmpUHk(TyCMhvReArDObTSJSQMTNiHgRDZCA8fx952spNXkuvN3SreBop0KaZ3uwN5zIlqp2))1UbKwAQqOzG(HnbUa1id45mdInfXT9Ph2Jbsk(nbCqLOOYCcEv325aZxxxz1vbNW4knLjLhdJ9Z8CtDWk1dVzCWxULWBQwbeifUgmL7IYnb26Mcn54MY2MSCxazJFYXFBw3seaT86SOK8mHzgrptXUxoOjha6n5OGEt4zaQYpX2AstZPz4ADVml3GMvCh8dllwfSF1vWuq3teuq0rO9uPmHiuwZTbHq)RreiFpaL4svladrDUk9qjrqS9y2eSNw1sD56LgU2HnW)2KihEtjjXmbs8p4wLY2FYDZgLi8KYchm7zfy(ELQ4Jq64QcrMP4hewbOCMqj5Qs8eRR5E3Vv1hv83PPrBRsyyVJyS8HlD5K11SLXOu3471KJeL(yiyDW0wcDTRuz4SOsRNTGRYK9rBz05QoGQTIARAB1(4YIjqAVRJHS42DPHASNkLNH(spBAGW)7cyX6aU68OuVdw(u3cFxpP94Z6mmPM3wj9ngkazDJ39UM8x1uQgEYJePSYjRZKwA(795wRtwNpx3u(qW5FFjbXuEX5fzHLe0YnqsZfF30Ejav5ZvR7DQtzEf)QXZRALpTrjf2hqS3AgXJynXj)XdLdnMQhsnLsvsUeHIR(wYFfogMSfUoxHODic4OBEGqkNPAh12toqBP4uC7B30b2QRSF67CX1QetRi7E1Csm9r93))UOYTik3MgTzIfPrtATSDog21MPJI(Is(JS6cM2bj4WkbGGgerTEIsfYSgZMIoPl9UY8D6POXgRYXBGqHcDoW6bBE4bjvOxpbwEK1sSw5EPwsxBl75ikNqF53K7h3XRi66eSJzQpiEOBynfWrBoj2e)5YsfRCJkSKB6JXkzbX4OzDMW4JQuXqU3r8ooURdrYBXrXkqzfFnWBDcE2wsd2MgUbeDBZbHs3XAVvX)E2Gk5ATOny)TORQJRnRKMD8N3s)nAzo1awEQEacNzksa(bsmXtw7f(awxIursA8)5b3WiUXanIGIQAc3t19WS3XAsQLN2zO2SaBM6YQEJyen)dEGbC4Vt(44YJ)r2xK4OamW(0IyEB1OYd0sHGHGqu1w2czLKO0wqosjDcpl0dpSyq5II9wkJvhSMamBQczyDXh51)E)KQmjtmO9ihBZ9wspJLYVRHOep60mHgb4D)gMUowTZQIhFVscWDyXqqXwULPkMaH1jT2l44WqmC(2yCQbvTLBlXOY7EG28iu0ldd(oyj)qLwAGnewIN3ZYqlyWJ2x1YgGOnFuml08Zllv8wKrQuHDEUcmMOhbHiEHypRkQvXDEaAGshEUBLYXdp6w(8(FICfW7Nu8QFGYn0dqQWy1HLpcrmEptzf3vfkrjLM7woBqcCikHlHhtAFImgLMM8T2pt0viGSq2ihmpDWMwchA9LDXnx)OBkASaCP4JipnCdsKk3z(kUZvVc7PiaVtr0HFs8ClYt2awI8zvipEfe81Up83yTZhEHx8UKyyQyp(vQYTVIBYx73RwXWZhy)PHDbpJN8Df435jKVNZNUPmLjY8HRxDgMCKPqxAaJLkRLk2swwSgiV7deIdLN369tE4cASt3zlfm0S3yQRFdZGYzv2KCH8jzUN02dGxrsrRBk3JcnLUzivqX27yYUw)19t2O6ZWG65YRA(67547qMsHtmrNtN8yLMQPhnUBRW7ikRRoduehXtEwNuhLb)v4YP2uANRfXr(N8c5QJSKKb4DeX43CKXydW7feJPewOoDwDk3y4L27j)iPvYUlxEuAZUxzYYg9zf4vTBsQm6JxTxgKmGXn12xbh1l6Vgr4fxCYGr0dEdWX2yYlPkasoVNF2rHRFWR4)SK7)smBgC6)fWLndZK8rxrzgOpxl9uI8G53hB4zp2aaLADavOs2xbAG2aU(zfKvjO1SCw2)wT3pQ1Zv)AF19ywv7yvIzIyiVKqVB4Q3NTAWLCi9dRpmO3h4k22TeWu5X9dBTBhQApwgQ)1xmb9jAACLqyX(u0asRmezORP3tIi3k0jhspCsY5yzYumvWk0wQgUsJPrd1MCnQat9Kq2tiwLbsf4PM1YEcTJHEzAiRufzfqBO62AsuVGoG16mCWga)ILRTdgJpE5xRvNWpIuG)KCZ)Oib)sgcXFwZGH8kCuOpVK5SG0UbROOVAVSy8YRfYWEA56PPaD6IT1tiFGwrE51UzqB0rGsyqRXraYg2b(Yb5pdVko2b8zy)7N1AF3h(z2wweGVH3SKyXRz3v5WJXlsLKLHn3RYzJQlIZPZFT4124UpqnIQgCG8HINyLZ0UXwMFXzHlNxUoOtkWUp8xyxPgFnDResVuR6GVZWwqDEZDGWzSw8Dor(vNpOhvF6uYbjKTvlZNkTztS0p(zlShpCiJS(159r4EsDBeGQ3DzzupP1ju37eLCObN0vXNmd4NFM8LRlGJ1jgF1HweV5S52TXI(Fb3EGhb2yB8kAA2PSsriFreo0AqBSnTUBHV3yVBDDY9kVmxRF7pP9K(VfPKatkotvxjlswXKtFb0AXymFPUe92tIoNksCL488Znug(Tp48XcAa436GlMB38BZMk8CHlBOzZV4B5KKVQUP62tcvY25SBCqMy6adx0FlSNa0nTBnqlTXhgFUbqmC2vp)S(TBda5Hp)mEaITKo8WZSNqVqKVfRi8PzcUseU39SOUxKibTsLxiGTTGEstfSXGxAshhfkq3H3DmjTpVp8e1ZGiCbOEu(8sicC8dmH4Fll8PEa7QmP0IvcQwKCX8jNQXkyG(uDBkw82VCX8PJzl5xWp4cMx4QhTKYfo9NBIfZf)utCU95dKAJxlvlkCTZFz)gjyEPR9ftOCTVVwHMmguwW4Uehf)fR88frb1ldkoQ4bEqW9W4i)zvO7PUCkoJ)rwGRnrU5SfaHYNebrri89mFGL6enyUrjom5pKbi0j6IzWM40tL6IzDiW(uhi(7kFzdeFK0hYGs9BvNjQgDHmCfgT2zJIKh23Z7Ko85AoeuVte8ctWtSNPB2X9vYrysFDj0h(clo5CwyPKVSwIFJrcet8f4eWjK0Lx8dFuNR1Y2II4ejzn4eAcbXYRuFJ5tE0m7rtfv(2BUCVpcrDUs79IXAG2pYM8fZ1(96tqujbq8zvR8jh06(RJJb0rKOs6DYGb2NQLhZHFdDsdXZvdeN8jKNZhRtA5e(88ZsgqGaQvDma9620CcHSZzHFfEOC6Kb1)9WwdOSNjAl7BGnX0UzwNvdr)jRPP6POU(rQvFqxp5q9LOYrUP0S4xz331nOn4lfrCtaVzq5Iv7(BurEvZnwRoIUc2LiYLMnFsJiVX3Hre)A7IPwLkkLQEKek5BmeTZ5TMOERtuUuQhAz0r5zGJY1YPYTQNLYSo16Kw80SYo)xjxC0QKuLCfi61mDcHKYUdv6ppDqRxG0GYculIQs8QNn8BUQHM95CZpRUqvkpnt7iXsTjpwlMFXPuRVshe0U8NfislMFL28l3VwnRXJ5v3S6CYVWOjtCDhxEZwgLOf3erBn1Ikfw2LB10V)yOtTLDdf6WUCLP1DuP81W1T8IlvwEQqP1GwXwtJjx1kieUeJzdMrxKVgLPngp3E8ysIv5Dv63Ol01CpeRJx11CqURVmZ5F(zJxauAtm)MhUoedLB4yYvXfv5TG4JcHgVS6(lw7j1xzXQpP(wkwZ0S0ftSCXC9A)(Zvfu4nYk(eUuH6Ds8zcxyR8eBiCxSUO8(r88XJSvKbnUZPjgnzLlp)SPBzvW1cJztAHHSmpFA7ltJT)S(6fW3E1N1wMBD5f2GyI5EegRbJG5LoVFFxmHCnJ5q7e6ogw4bYD1B7ujQRL3)pQaH6TzllfEMNfLRKw9IOegV4kAfF2JBht0VvAF5WL3ycvYoJD3UoVuQXUrPiLTqZ9NnnVyIrsGY8oPFZREBzBEEz6k)HMkeuzVM4Zip6DZ9mV5y)iExsuLLRITvbzjhIGyyyVUjlzV(JxmUk(dxEvfX2hinSQW01PtRMUWnKXSoiVYPR78aAQu1s)Y6WcmEphupc9uIbB4i(I)pSmYx6lhidDzXx0Vz)9K6QtCn46)IlNA1ACdyvqjMuLIgwjJt)L7FMKqSL4xEmDil9z0hbSzDO0ADjGzZLxmXdRUGGl3yDTQFSL2aiIdUC6BoHNTKEA1qMBpeyQzVzr0VISiI4eIiMJ0qv4HcIveToqL)YEM1u6C49IDdktTYOZ1QwwGiszznxLij2xvPEtivDwYPlY2C(8LsixdQ2JkdPiulKVov45WnJjxC02UzBRAhOQDbckpAHiPN55tvYk5mY4JQgLs(eoSoY6L5Yh2mjTQYOMvpOBoulNSwdQ3O1gBHOOim0BM2pxxhLHwgJW0KrWE3RF94AdUB62aZ9izTn)M2nWCO0TAsV1lBudOOOqpP2I2rLdtW9aVfC73oE6B60Y96DhaK5gPuss2S(HztQEb5cLmCO(EK(YvoHw3HvhxVRwuU0iTpupvngjdd7GgrwFnE5b(Q4MZTV06dKu34FQHBf3zZXev11OaVvhFG8NHSpIlE38RtUAm7kK7M)Np]] )