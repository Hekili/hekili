-- MonkWindwalker.lua
-- October 2023

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 269 )

spec:RegisterResource( Enum.PowerType.Energy, {
    crackling_jade_lightning = {
        aura = "crackling_jade_lightning",
        debuff = true,

        last = function ()
            local app = state.debuff.crackling_jade_lightning.applied
            local t = state.query_time

            return app + floor( ( t - app ) / state.haste ) * state.haste
        end,

        stop = function( x )
            return x < class.abilities.crackling_jade_lightning.spendPerSec
        end,

        interval = function () return state.haste end,
        value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
    }
} )
spec:RegisterResource( Enum.PowerType.Chi )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Monk
    bounce_back                 = { 80717, 389577, 2 }, -- When a hit deals more than 20% of your maximum health, reduce all damage you take by 10% for 4 sec. This effect cannot occur more than once every 30 seconds.
    calming_presence            = { 80693, 388664, 1 }, -- Reduces all damage taken by 3%.
    celerity                    = { 80685, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    chi_burst                   = { 80709, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 726 Nature damage to all enemies, and 1,786 healing to the Monk and all allies in its path. Healing reduced beyond 6 targets. Chi Burst generates 1 Chi per enemy target damaged, up to a maximum of 2.
    chi_torpedo                 = { 80685, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                    = { 80709, 115098, 1 }, -- A wave of Chi energy flows through friends and foes, dealing 273 Nature damage or 793 healing. Bounces up to 7 times to targets within 25 yards.
    close_to_heart              = { 80707, 389574, 2 }, -- You and your allies within 10 yards have 2% increased healing taken from all sources.
    diffuse_magic               = { 80697, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                     = { 80679, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks. Targets already snared will be rooted for 8 sec instead.
    elusive_mists               = { 80603, 388681, 2 }, -- Reduces all damage taken while channelling Soothing Mists by 0%.
    escape_from_reality         = { 80715, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within $343249d, ignoring its cooldown.; During this time, if you cast Vivify on yourself, its healing is increased by $s1% and $343249m2% of its cost is refunded.
    expeditious_fortification   = { 80681, 388813, 1 }, -- Fortifying Brew cooldown reduced by 2 min.
    eye_of_the_tiger            = { 80700, 196607, 1 }, -- Tiger Palm also applies Eye of the Tiger, dealing 542 Nature damage to the enemy and 493 healing to the Monk over 8 sec. Limit 1 target.
    fast_feet                   = { 80705, 388809, 2 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_touch                 = { 80703, 394123, 2 }, -- Touch of Death cooldown reduced by 120 sec.
    ferocity_of_xuen            = { 80706, 388674, 2 }, -- Increases all damage dealt by 2%.
    fortifying_brew             = { 80680, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 20%, reducing all damage you take by 20%.
    generous_pour               = { 80683, 389575, 2 }, -- You and your allies within 10 yards take 10% reduced damage from area-of-effect attacks.
    grace_of_the_crane          = { 80710, 388811, 2 }, -- Increases all healing taken by 2%.
    hasty_provocation           = { 80696, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    improved_paralysis          = { 80687, 344359, 1 }, -- Reduces the cooldown of Paralysis by 15 sec.
    improved_roll               = { 80712, 328669, 1 }, -- Grants an additional charge of Roll and Chi Torpedo.
    improved_touch_of_death     = { 80684, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    improved_vivify             = { 80692, 231602, 2 }, -- Vivify healing is increased by 40%.
    ironshell_brew              = { 80681, 388814, 1 }, -- Increases Armor while Fortifying Brew is active by 25%. Increases Dodge while Fortifying Brew is active by 25%.
    paralysis                   = { 80688, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    profound_rebuttal           = { 80708, 392910, 1 }, -- Expel Harm's critical healing is increased by 50%.
    resonant_fists              = { 80702, 389578, 2 }, -- Your attacks have a chance to resonate, dealing 0 Nature damage to enemies within 8 yds.
    ring_of_peace               = { 80698, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    save_them_all               = { 80714, 389579, 2 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    song_of_chiji               = { 80698, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for 20 sec.
    spear_hand_strike           = { 80686, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 3 sec.
    strength_of_spirit          = { 80682, 387276, 1 }, -- Expel Harm's healing is increased by up to 100%, based on your missing health.
    summon_black_ox_statue      = { 80716, 115315, 1 }, -- Summons a Black Ox Statue at the target location for 15 min, pulsing threat to all enemies within 20 yards. You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_jade_serpent_statue  = { 80713, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for 3,376 over 7.3 sec.
    summon_white_tiger_statue   = { 80701, 388686, 1 }, -- Summons a White Tiger Statue at the target location for 30 sec, pulsing 415 damage to all enemies every 2 sec for 30 sec.
    tiger_tail_sweep            = { 80604, 264348, 2 }, -- Increases the range of Leg Sweep by 2 yds and reduces its cooldown by 10 sec.
    transcendence               = { 80694, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    vigorous_expulsion          = { 80711, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification      = { 80695, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant.
    windwalking                 = { 80699, 157411, 2 }, -- You and your allies within 10 yards have 10% increased movement speed.
    yulons_grace                = { 80697, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for 2.0% of your max health every 2 sec in combat, stacking up to 10%.

    -- Windwalker
    ascension                   = { 80612, 115396, 1 }, -- Increases your maximum Chi by 1, maximum Energy by 20, and your Energy regeneration by 10%.
    attenuation                 = { 80668, 386941, 1 }, -- Bonedust Brew's Shadow damage or healing is increased by 20%, and when Bonedust Brew deals Shadow damage or healing, its cooldown is reduced by 0.5 sec.
    bonedust_brew               = { 80669, 386276, 1 }, -- Hurl a brew created from the bones of your enemies at the ground, coating all targets struck for 10 sec. Your abilities have a 50% chance to affect the target a second time at 40% effectiveness as Shadow damage or healing. Spinning Crane Kick refunds 1 Chi when striking enemies with your Bonedust Brew active.
    crane_vortex                = { 80667, 388848, 2 }, -- Spinning Crane Kick damage increased by 10%.
    dampen_harm                 = { 80704, 122278, 1 }, -- Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    dance_of_chiji              = { 80626, 325201, 1 }, -- Spending Chi has a chance to make your next Spinning Crane Kick free and deal an additional 200% damage.
    dance_of_the_wind           = { 80704, 414132, 1 }, -- Your dodge chance is increased by 10%.
    detox                       = { 80606, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    drinking_horn_cover         = { 80619, 391370, 1 }, -- The duration of Serenity is extended by 0.3 sec every time you cast a Chi spender.
    dust_in_the_wind            = { 80670, 394093, 1 }, -- Bonedust Brew's radius increased by 50%.
    empowered_tiger_lightning   = { 80659, 323999, 1 }, -- Xuen strikes your enemies with Empowered Tiger Lightning every 4 sec, dealing 10% of the damage you and your summons have dealt to those targets in the last 4 sec.
    fatal_flying_guillotine     = { 80666, 394923, 1 }, -- Touch of Death strikes up to 4 additional nearby targets. This Touch of Death is always an Improved Touch of Death.
    fists_of_fury               = { 80613, 113656, 1 }, -- Pummels all targets in front of you, dealing ${5*$117418s1} Physical damage to your primary target and ${5*$117418s1*$s6/100} damage to all other enemies over $113656d. Deals reduced damage beyond $s1 targets. Can be channeled while moving.
    flashing_fists              = { 80615, 388854, 2 }, -- Fists of Fury damage increased by 10%.
    flying_serpent_kick         = { 80621, 101545, 1 }, -- Soar forward through the air at high speed for 1.5 sec. If used again while active, you will land, dealing 139 damage to all enemies within 8 yards and reducing movement speed by 70% for 4 sec.
    forbidden_technique         = { 80608, 393098, 1 }, -- Touch of Death deals 20% increased damage and can be used a second time within 5 sec before its cooldown is triggered.
    fury_of_xuen                = { 80656, 396166, 1 }, -- Your Combo Strikes grant a stacking 1% chance for your next Fists of Fury to grant 5% haste and invoke Xuen, The White Tiger for 8 sec.
    glory_of_the_dawn           = { 80677, 392958, 1 }, -- Rising Sun Kick has a 25% chance to trigger a second time, dealing 568 Physical damage and restoring 1 Chi.
    hardened_soles              = { 80611, 391383, 2 }, -- Blackout Kick critical strike chance increased by 5% and critical damage increased by 10%.
    hit_combo                   = { 80676, 196740, 1 }, -- Each successive attack that triggers Combo Strikes in a row grants 1% increased damage, stacking up to 6 times.
    inner_peace                 = { 80627, 397768, 1 }, -- Increases maximum Energy by 30. Tiger Palm damage increased by 10%.
    invoke_xuen                 = { 80657, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for 20 sec. Xuen attacks your primary target, and strikes 3 enemies within 10 yards every 0.9 sec with Tiger Lightning for 390 Nature damage. Every 4 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing 10% of the damage you have dealt to those targets in the last 4 sec.
    invoke_xuen_the_white_tiger = { 80657, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for 20 sec. Xuen attacks your primary target, and strikes 3 enemies within 10 yards every 0.9 sec with Tiger Lightning for 390 Nature damage. Every 4 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing 10% of the damage you have dealt to those targets in the last 4 sec.
    invokers_delight            = { 80661, 388661, 1 }, -- You gain 33% haste for 20 sec after summoning your Celestial.
    jade_ignition               = { 80607, 392979, 1 }, -- Whenever you deal damage to a target with Fists of Fury, you gain a stack of Chi Energy up to a maximum of 30 stacks. Using Spinning Crane Kick will cause the energy to detonate in a Chi Explosion, dealing 1,026 Nature damage to all enemies within 8 yards. The damage is increased by 5% for each stack of Chi Energy.
    jadefire_harmony            = { 80671, 391412, 1 }, -- Your abilities reset Jadefire Stomp $s2% more often. Enemies and allies hit by Jadefire Stomp are affected by Jadefire Brand, increasing your damage and healing against them by $395413s1% for $395413d.
    jadefire_stomp              = { 80672, 388193, 1 }, -- Strike the ground fiercely to expose a path of jade for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the path. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the path$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].; Your abilities have a $s2% chance of resetting the cooldown of Jadefire Stomp while fighting within the path.
    last_emperors_capacitor     = { 80664, 392989, 1 }, -- Chi spenders increase the damage of your next Crackling Jade Lightning by 100% and reduce its cost by 5%, stacking up to 20 times.
    mark_of_the_crane           = { 80623, 220357, 1 }, -- Spinning Crane Kick's damage is increased by 18% for each unique target you've struck in the last 20 sec with Tiger Palm, Blackout Kick, or Rising Sun Kick. Stacks up to 5 times.
    meridian_strikes            = { 80620, 391330, 1 }, -- When you Combo Strike, the cooldown of Touch of Death is reduced by 0.35 sec. Touch of Death deals an additional 15% damage.
    open_palm_strikes           = { 80678, 392970, 1 }, -- Fists of Fury damage increased by 15%. When Fists of Fury deals damage, it has a 5% chance to refund 1 Chi.
    path_of_jade                = { 80605, 392994, 1 }, -- Increases the initial damage of Jadefire Stomp by ${$s1}% per target hit by that damage, up to a maximum of ${$s1*$s2}% additional damage.
    power_strikes               = { 80614, 121817, 1 }, -- Every 15 sec, your next Tiger Palm will generate 1 additional Chi and deal 100% additional damage.
    rising_star                 = { 80673, 388849, 2 }, -- Rising Sun Kick damage increased by 10% and critical strike damage increased by 10%.
    rising_sun_kick             = { 80690, 107428, 1 }, -- Kick upwards, dealing 6,006 Physical damage, and reducing the effectiveness of healing on the target for 10 sec.
    rushing_jade_wind           = { 80625, 116847, 1 }, -- Summons a whirling tornado around you, causing 2,076 Physical damage over 5.5 sec to all enemies within 9 yards. Deals reduced damage beyond 5 targets.
    serenity                    = { 80618, 152173, 1 }, -- Enter an elevated state of mental and physical serenity for 12 sec. While in this state, you deal 15% increased damage and healing, and all Chi consumers are free and cool down 100% more quickly.
    shadowboxing_treads         = { 80624, 392982, 1 }, -- Blackout Kick damage increased by 10% and strikes an additional 2 targets.
    skyreach                    = { 80663, 392991, 1 }, -- Tiger Palm now has a 10 yard range and dashes you to the target when used. Tiger Palm also applies an effect which increases your critical strike chance by 50% for 6 sec on the target. This effect cannot be applied more than once every 1 min per target.
    skytouch                    = { 80663, 405044, 1 }, -- Tiger Palm now has a 10 yard range. Tiger Palm also applies an effect which increases your critical strike chance by 50% for 6 sec on the target. This effect cannot be applied more than once every 1 min per target.
    soothing_mist               = { 80691, 115175, 1 }, -- Heals the target for 8,440 over 7.3 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    spiritual_focus             = { 80617, 280197, 1 }, -- Every 2 Chi you spend reduces the cooldown of Serenity by 0.3 sec.
    storm_earth_and_fire        = { 80618, 137639, 1 }, -- Split into 3 elemental spirits for 15 sec, each spirit dealing 42% of normal damage and healing. You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies. While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    strike_of_the_windlord      = { 80675, 392983, 1 }, -- Strike with both fists at all enemies in front of you, dealing 12,715 damage and reducing movement speed by 50% for 6 sec.
    teachings_of_the_monastery  = { 80616, 116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to 3. Blackout Kick has a 12% chance to reset the remaining cooldown on Rising Sun Kick.
    thunderfist                 = { 80674, 392985, 1 }, -- Strike of the Windlord grants you a stack of Thunderfist for each enemy struck. Thunderfist discharges upon melee strikes, dealing 5,818 Nature damage.
    tigers_lust                 = { 80689, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    touch_of_karma              = { 80610, 122470, 1 }, -- Absorbs all damage taken for 10 sec, up to 50% of your maximum health, and redirects 70% of that amount to the enemy target as Nature damage over 6 sec.
    touch_of_the_tiger          = { 80622, 388856, 2 }, -- Tiger Palm damage increased by 25%.
    transfer_the_power          = { 80660, 195300, 1 }, -- Blackout Kick and Rising Sun Kick increase damage dealt by your next Fists of Fury by 3%, stacking up to 10 times.
    whirling_dragon_punch       = { 80658, 152175, 1 }, -- Performs a devastating whirling upward strike, dealing 3,536 damage to all nearby enemies. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    widening_whirl              = { 80609, 388846, 1 }, -- Spinning Crane Kick radius increased by 15%.
    xuens_battlegear            = { 80662, 392993, 1 }, -- Rising Sun Kick critical strikes reduce the cooldown of Fists of Fury by 4 sec. When Fists of Fury ends, the critical strike chance of Rising Sun Kick is increased by 40% for 5 sec.
    xuens_bond                  = { 80665, 392986, 1 }, -- Abilities that activate Combo Strikes reduce the cooldown of Invoke Xuen, the White Tiger by 0.1 sec, and Xuen's damage is increased by 10%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_tiger         = 3734, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you 20% haste for 8 sec. This effect cannot occur more than once every 30 sec per target.
    disabling_reach     = 3050, -- (201769) Disable now has a 10 yard range.
    grapple_weapon      = 3052, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 5 sec.
    mighty_ox_kick      = 5540, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    perpetual_paralysis = 5448, -- (357495) Paralysis range reduced by 5 yards, but spreads to 2 new enemies when removed.
    pressure_points     = 3744, -- (345829) Killing a player with Touch of Death reduces the remaining cooldown of Touch of Karma by 60 sec.
    reverse_harm        = 852 , -- (342928) Increases the healing done by Expel Harm by 30%, and your Expel Harm now generates 1 additional Chi.
    ride_the_wind       = 77  , -- (201372) Flying Serpent Kick clears all snares from you when used and forms a path of wind in its wake, causing all allies who stand in it to have 30% increased movement speed and to be immune to movement slowing effects.
    stormspirit_strikes = 5610, -- (411098) Striking more than one enemy with Fists of Fury summons a Storm Spirit to focus your secondary target for 25 sec, which will mimic any of your attacks that do not also strike the target for 25% of normal damage.
    tigereye_brew       = 675 , -- (247483) Consumes up to 10 stacks of Tigereye Brew to empower your Physical abilities with wind for 2 sec per stack consumed. Damage of your strikes are reduced, but bypass armor. For each 3 Chi you consume, you gain a stack of Tigereye Brew.
    turbo_fists         = 3745, -- (287681) Fists of Fury now reduces all targets movement speed by 90%, and you Parry all attacks while channelling Fists of Fury.
    wind_waker          = 3737, -- (357633) Your movement enhancing abilities increases Windwalking on allies by 10%, stacking 2 additional times. Movement impairing effects are removed at 3 stacks.
} )


-- Auras
spec:RegisterAuras( {
    blackout_reinforcement = {
        id = 424454,
        duration = 3600,
        max_stack = 1
    },
    bok_proc = {
        id = 116768,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: The Monk's abilities have a $h% chance to affect the target a second time at $s1% effectiveness as Shadow damage or healing.
    -- https://wowhead.com/beta/spell=325216
    bonedust_brew = {
        id = 325216,
        duration = 10,
        max_stack = 1,
        copy = 386276
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    -- Increases the damage done by your next Chi Explosion by $s1%.    Chi Explosion is triggered whenever you use Spinning Crane Kick.
    -- https://wowhead.com/beta/spell=393057
    chi_energy = {
        id = 393057,
        duration = 45,
        max_stack = 30,
        copy = 337571
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=119085
    chi_torpedo = {
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    -- TODO: This is a stub until BrM is implemented.
    counterstrike = {
        duration = 3600,
        max_stack = 1,
    },
    -- Taking $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=117952
    crackling_jade_lightning = {
        id = 117952,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $m2% to $m3% for $d, with larger attacks being reduced by more.
    -- https://wowhead.com/beta/spell=122278
    dampen_harm = {
        id = 122278,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Your dodge chance is increased by $w1% until you dodge an attack.
    dance_of_the_wind = {
        id = 432180,
        duration = 10.0,
        max_stack = 1,
    },
    -- Talent: Your next Spinning Crane Kick is free and deals an additional $325201s1% damage.
    -- https://wowhead.com/beta/spell=325202
    dance_of_chiji = {
        id = 325202,
        duration = 15,
        max_stack = 1,
        copy = { 286587, "dance_of_chiji_azerite" }
    },
    -- Talent: Spell damage taken reduced by $m1%.
    -- https://wowhead.com/beta/spell=122783
    diffuse_magic = {
        id = 122783,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement slowed by $w1%. When struck again by Disable, you will be rooted for $116706d.
    -- https://wowhead.com/beta/spell=116095
    disable = {
        id = 116095,
        duration = 15,
        mechanic = "snare",
        max_stack = 1
    },
    disable_root = {
        id = 116706,
        duration = 8,
        max_stack = 1,
    },
    escape_from_reality = {
        id = 343249,
        duration = 10,
        max_stack = 1
    },
    exit_strategy = {
        id = 289324,
        duration = 2,
        max_stack = 1
    },
    -- Talent: $?$w1>0[Healing $w1 every $t1 sec.][Suffering $w2 Nature damage every $t2 sec.]
    -- https://wowhead.com/beta/spell=196608
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Fighting on a faeline has a $s2% chance of resetting the cooldown of Faeline Stomp.
    -- https://wowhead.com/beta/spell=388193
    jadefire_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1,
        copy = { 327104, "faeline_stomp" }
    },
    -- Damage version.
    jadefire_brand = {
        id = 395414,
        duration = 10,
        max_stack = 1,
        copy = { 356773, "fae_exposure", "fae_exposure_damage", "jadefire_brand_damage" }
    },
    jadefire_brand_heal = {
        id = 395413,
        duration = 10,
        max_stack = 1,
        copy = { 356774, "fae_exposure_heal" },
    },
    -- Talent: $w3 damage every $t3 sec. $?s125671[Parrying all attacks.][]
    -- https://wowhead.com/beta/spell=113656
    fists_of_fury = {
        id = 113656,
        duration = function () return 4 * haste end,
        max_stack = 1,
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=120086
    fists_of_fury_stun = {
        id = 120086,
        duration = 4,
        mechanic = "stun",
        max_stack = 1
    },
    flying_serpent_kick = {
        name = "Flying Serpent Kick",
        duration = 2,
        generate = function ()
            local cast = rawget( class.abilities.flying_serpent_kick, "lastCast" ) or 0
            local expires = cast + 2

            local fsk = buff.flying_serpent_kick
            fsk.name = "Flying Serpent Kick"

            if expires > query_time then
                fsk.count = 1
                fsk.expires = expires
                fsk.applied = cast
                fsk.caster = "player"
                return
            end
            fsk.count = 0
            fsk.expires = 0
            fsk.applied = 0
            fsk.caster = "nobody"
        end,
    },
    -- Talent: Movement speed reduced by $m2%.
    -- https://wowhead.com/beta/spell=123586
    flying_serpent_kick_snare = {
        id = 123586,
        duration = 4,
        max_stack = 1
    },
    fury_of_xuen_stacks = {
        id = 396167,
        duration = 20,
        max_stack = 67,
        copy = { "fury_of_xuen", 396168, 396167, 287062 }
    },
    fury_of_xuen_haste = {
        id = 287063,
        duration = 8,
        max_stack = 1,
        copy = 396168
    },
    hidden_masters_forbidden_touch = {
        id = 213114,
        duration = 5,
        max_stack = 1
    },
    hit_combo = {
        id = 196741,
        duration = 10,
        max_stack = 6,
    },
    invoke_xuen = {
        id = 123904,
        duration = 20, -- 11/1 nerf from 24 to 20.
        max_stack = 1,
        hidden = true,
        copy = "invoke_xuen_the_white_tiger"
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=388663
    invokers_delight = {
        id = 388663,
        duration = 20,
        max_stack = 1,
        copy = 338321
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=119381
    leg_sweep = {
        id = 119381,
        duration = 3,
        mechanic = "stun",
        max_stack = 1
    },
    mark_of_the_crane = {
        id = 228287,
        duration = 15,
        max_stack = 1,
        no_ticks = true
    },
    mortal_wounds = {
        id = 115804,
        duration = 10,
        max_stack = 1,
    },
    mystic_touch = {
        id = 113746,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=115078
    paralysis = {
        id = 115078,
        duration = 60,
        mechanic = "incapacitate",
        max_stack = 1
    },
    power_strikes = {
        id = 129914,
        duration = 1,
        max_stack = 1
    },
    pressure_point = {
        id = 393053,
        duration = 5,
        max_stack = 1,
        copy = 337482
    },
    -- Taunted. Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=116189
    provoke = {
        id = 116189,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Nearby enemies will be knocked out of the Ring of Peace.
    -- https://wowhead.com/beta/spell=116844
    ring_of_peace = {
        id = 116844,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    rising_sun_kick = {
        id = 107428,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Dealing physical damage to nearby enemies every $116847t1 sec.
    -- https://wowhead.com/beta/spell=116847
    rushing_jade_wind = {
        id = 116847,
        duration = function () return 6 * haste end,
        tick_time = 0.75,
        dot = "buff",
        max_stack = 1
    },
    save_them_all = {
        id = 390105,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Damage and healing increased by $w2%.  All Chi consumers are free and cool down $w4% more quickly.
    -- https://wowhead.com/beta/spell=152173
    serenity = {
        id = 152173,
        duration = 12,
        max_stack = 1
    },
    skyreach = {
        id = 393047,
        duration = 6,
        max_stack = 1,
        copy = { 344021, "keefers_skyreach" }
    },
    skyreach_exhaustion = {
        id = 393050,
        duration = 60,
        max_stack = 1,
        copy = { 337341, "recently_rushing_tiger_palm" }
    },
    -- Talent: Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=115175
    soothing_mist = {
        id = 115175,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- $?$w2!=0[Movement speed reduced by $w2%.  ][]Drenched in brew, vulnerable to Breath of Fire.
    -- https://wowhead.com/beta/spell=196733
    special_delivery = {
        id = 196733,
        duration = 15,
        max_stack = 1
    },
    -- Attacking nearby enemies for Physical damage every $101546t1 sec.
    -- https://wowhead.com/beta/spell=101546
    spinning_crane_kick = {
        id = 101546,
        duration = function () return 1.5 * haste end,
        tick_time = function () return 0.5 * haste end,
        max_stack = 1
    },
    -- Talent: Elemental spirits summoned, mirroring all of the Monk's attacks.  The Monk and spirits each do ${100+$m1}% of normal damage and healing.
    -- https://wowhead.com/beta/spell=137639
    storm_earth_and_fire = {
        id = 137639,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=392983
    strike_of_the_windlord = {
        id = 392983,
        duration = 6,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=280184
    sweep_the_leg = {
        id = 280184,
        duration = 6,
        max_stack = 1
    },
    teachings_of_the_monastery = {
        id = 202090,
        duration = 20,
        max_stack = 3,
    },
    -- Damage of next Crackling Jade Lightning increased by $s1%.  Energy cost of next Crackling Jade Lightning reduced by $s2%.
    -- https://wowhead.com/beta/spell=393039
    the_emperors_capacitor = {
        id = 393039,
        duration = 3600,
        max_stack = 20,
        copy = 337291
    },
    thunderfist = {
        id = 393565,
        duration = 30,
        max_stack = 30
    },
    -- Talent: Moving $s1% faster.
    -- https://wowhead.com/beta/spell=116841
    tigers_lust = {
        id = 116841,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    touch_of_death = {
        id = 115080,
        duration = 8,
        max_stack = 1
    },
    touch_of_karma = {
        id = 125174,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Damage dealt to the Monk is redirected to you as Nature damage over $124280d.
    -- https://wowhead.com/beta/spell=122470
    touch_of_karma_debuff = {
        id = 122470,
        duration = 10,
        max_stack = 1
    },
    -- Talent: You left your spirit behind, allowing you to use Transcendence: Transfer to swap with its location.
    -- https://wowhead.com/beta/spell=101643
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transcendence_transfer = {
        id = 119996,
    },
    transfer_the_power = {
        id = 195321,
        duration = 30,
        max_stack = 10
    },
    -- Talent: Your next Vivify is instant.
    -- https://wowhead.com/beta/spell=392883
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=196742
    whirling_dragon_punch = {
        id = 196742,
        duration = function () return action.rising_sun_kick.cooldown end,
        max_stack = 1,
    },
    windwalking = {
        id = 166646,
        duration = 3600,
        max_stack = 1,
    },
    -- Flying.
    -- https://wowhead.com/beta/spell=125883
    zen_flight = {
        id = 125883,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    zen_pilgrimage = {
        id = 126892,
    },

    -- PvP Talents
    alpha_tiger = {
        id = 287504,
        duration = 8,
        max_stack = 1,
    },
    fortifying_brew = {
        id = 201318,
        duration = 15,
        max_stack = 1,
    },
    grapple_weapon = {
        id = 233759,
        duration = 6,
        max_stack = 1,
    },
    heavyhanded_strikes = {
        id = 201787,
        duration = 2,
        max_stack = 1,
    },
    ride_the_wind = {
        id = 201447,
        duration = 3600,
        max_stack = 1,
    },
    tigereye_brew = {
        id = 247483,
        duration = 20,
        max_stack = 1
    },
    tigereye_brew_stack = {
        id = 248646,
        duration = 120,
        max_stack = 20,
    },
    wind_waker = {
        id = 290500,
        duration = 4,
        max_stack = 1,
    },

    -- Conduit
    coordinated_offensive = {
        id = 336602,
        duration = 15,
        max_stack = 1
    },

    -- Azerite Powers
    recently_challenged = {
        id = 290512,
        duration = 30,
        max_stack = 1
    },
    sunrise_technique = {
        id = 273298,
        duration = 15,
        max_stack = 1
    },
} )



spec:RegisterGear( "tier31", 207243, 207244, 207245, 207246, 207248 )


-- Tier 30
spec:RegisterGear( "tier30", 202509, 202507, 202506, 202505, 202504 )
spec:RegisterAura( "shadowflame_vulnerability", {
    id = 411376,
    duration = 15,
    max_stack = 1
} )


spec:RegisterGear( "tier29", 200360, 200362, 200363, 200364, 200365 )
spec:RegisterAuras( {
    kicks_of_flowing_momentum = {
        id = 394944,
        duration = 30,
        max_stack = 2,
    },
    fists_of_flowing_momentum = {
        id = 394949,
        duration = 30,
        max_stack = 3,
    }
} )

spec:RegisterGear( "tier19", 138325, 138328, 138331, 138334, 138337, 138367 )
spec:RegisterGear( "tier20", 147154, 147156, 147152, 147151, 147153, 147155 )
spec:RegisterGear( "tier21", 152145, 152147, 152143, 152142, 152144, 152146 )
spec:RegisterGear( "class", 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

spec:RegisterGear( "cenedril_reflector_of_hatred", 137019 )
spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
spec:RegisterGear( "drinking_horn_cover", 137097 )
spec:RegisterGear( "firestone_walkers", 137027 )
spec:RegisterGear( "fundamental_observation", 137063 )
spec:RegisterGear( "gai_plins_soothing_sash", 137079 )
spec:RegisterGear( "hidden_masters_forbidden_touch", 137057 )
spec:RegisterGear( "jewel_of_the_lost_abbey", 137044 )
spec:RegisterGear( "katsuos_eclipse", 137029 )
spec:RegisterGear( "march_of_the_legion", 137220 )
spec:RegisterGear( "prydaz_xavarics_magnum_opus", 132444 )
spec:RegisterGear( "salsalabims_lost_tunic", 137016 )
spec:RegisterGear( "sephuzs_secret", 132452 )
spec:RegisterGear( "the_emperors_capacitor", 144239 )

spec:RegisterGear( "soul_of_the_grandmaster", 151643 )
spec:RegisterGear( "stormstouts_last_gasp", 151788 )
spec:RegisterGear( "the_wind_blows", 151811 )


spec:RegisterStateTable( "combos", {
    blackout_kick = true,
    bonedust_brew = true,
    chi_burst = true,
    chi_wave = true,
    crackling_jade_lightning = true,
    expel_harm = true,
    faeline_stomp = true,
    jadefire_stomp = true,
    fists_of_fury = true,
    flying_serpent_kick = true,
    rising_sun_kick = true,
    rushing_jade_wind = true,
    spinning_crane_kick = true,
    strike_of_the_windlord = true,
    tiger_palm = true,
    touch_of_death = true,
    weapons_of_order = true,
    whirling_dragon_punch = true
} )

local prev_combo, actual_combo, virtual_combo

spec:RegisterStateExpr( "last_combo", function () return virtual_combo or actual_combo end )

spec:RegisterStateExpr( "combo_break", function ()
    return this_action == virtual_combo and combos[ virtual_combo ]
end )

spec:RegisterStateExpr( "combo_strike", function ()
    return not combos[ this_action ] or this_action ~= virtual_combo
end )


-- If a Tiger Palm missed, pretend we never cast it.
-- Use RegisterEvent since we're looking outside the state table.
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
        if not ability then return end

        if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
            if ns.castsAll[1] == "tiger_palm" then ns.castsAll[1] = "none" end
            if ns.castsAll[2] == "tiger_palm" then ns.castsAll[2] = "none" end
            if ns.castsOn[1] == "tiger_palm" then ns.castsOn[1] = "none" end
            actual_combo = "none"

            Hekili:ForceUpdate( "WW_MISSED" )

        elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
            prev_combo = actual_combo
            actual_combo = ability

        elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
            -- track the last tick.
            state.buff.rushing_jade_wind.last_tick = GetTime()
        end
    end
end )


local chiSpent = 0

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "chi" and amt > 0 then
        if talent.spiritual_focus.enabled then
            chiSpent = chiSpent + amt
            cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
            chiSpent = chiSpent % 2
        end

        if talent.drinking_horn_cover.enabled then
            if buff.storm_earth_and_fire.up then buff.storm_earth_and_fire.expires = buff.storm_earth_and_fire.expires + 0.4
            elseif buff.serenity.up then buff.serenity.expires = buff.serenity.expires + 0.3 end
        end

        if talent.last_emperors_capacitor.enabled or legendary.last_emperors_capacitor.enabled then
            addStack( "the_emperors_capacitor" )
        end
    end
end )


local noop = function () end

-- local reverse_harm_target




spec:RegisterHook( "runHandler", function( key, noStart )
    if combos[ key ] then
        if last_combo == key then removeBuff( "hit_combo" )
        else
            if talent.hit_combo.enabled then addStack( "hit_combo" ) end
            if azerite.fury_of_xuen.enabled or talent.fury_of_xuen.enabled then addStack( "fury_of_xuen" ) end
            if ( talent.xuens_bond.enabled or conduit.xuens_bond.enabled ) and cooldown.invoke_xuen.remains > 0 then reduceCooldown( "invoke_xuen", 0.1 ) end
            if talent.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then reduceCooldown( "touch_of_death", 0.35 ) end
        end
        virtual_combo = key
    end
end )


spec:RegisterStateTable( "healing_sphere", setmetatable( {}, {
    __index = function( t,  k)
        if k == "count" then
            t[ k ] = GetSpellCount( action.expel_harm.id )
            return t[ k ]
        end
    end
} ) )

spec:RegisterHook( "reset_precast", function ()
    rawset( healing_sphere, "count", nil )
    if healing_sphere.count > 0 then
        applyBuff( "gift_of_the_ox", nil, healing_sphere.count )
    end

    chiSpent = 0

    if actual_combo == "tiger_palm" and chi.current < 2 and now - action.tiger_palm.lastCast > 0.2 then
        actual_combo = "none"
    end

    if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

    if buff.casting.up and buff.casting.v1 == action.spinning_crane_kick.id then
        removeBuff( "casting" )
        -- Spinning Crane Kick buff should be up.
    end

    spinning_crane_kick.count = nil

    virtual_combo = actual_combo or "no_action"
    -- reverse_harm_target = nil

    if buff.weapons_of_order_ww.up then
        state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
    end

    if talent.forbidden_technique.enabled and cooldown.touch_of_death.remains == 0 and query_time - action.touch_of_death.lastCast < 5 then
        applyBuff( "recently_touched", query_time - action.touch_of_death.lastCast )
    end
end )

spec:RegisterHook( "IsUsable", function( spell )
    if spell == "touch_of_death" then return end -- rely on priority only.

    -- Allow repeats to happen if your chi has decayed to 0.
    if talent.hit_combo.enabled and buff.hit_combo.up and ( spell ~= "tiger_palm" or chi.current > 0 ) and last_combo == spell then
        return false, "would break hit_combo"
    end
end )


spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
    { __index = function( t, k )
            if k == "count" then
                return max( GetSpellCount( action.spinning_crane_kick.id ), active_dot.mark_of_the_crane )

            elseif k == "modifier" then
                local mod = 1
                -- Windwalker:
                if state.spec.windwalker then
                    -- Mark of the Crane (Cyclone Strikes) + Calculated Strikes (Conduit)
                    mod = mod * ( 1 + ( t.count * ( conduit.calculated_strikes.enabled and 0.28 or 0.18 ) ) )
                end

                -- Crane Vortex (Talent)
                mod = mod * ( 1 + 0.1 * talent.crane_vortex.rank )

                -- Kicks of Flowing Momentum (Tier 29 Buff)
                mod = mod * ( buff.kicks_of_flowing_momentum.up and 1.3 or 1 )

                -- Brewmaster: Counterstrike (Buff)
                mod = mod * ( buff.counterstrike.up and 2 or 1 )

                -- Fast Feet (Talent)
                mod = mod * ( 1 + 0.05 * talent.fast_feet.rank )
                return mod

            elseif k == "max" then
                return spinning_crane_kick.count >= min( cycle_enemies, 5 )

            end
    end } ) )

spec:RegisterStateExpr( "alpha_tiger_ready", function ()
    if not pvptalent.alpha_tiger.enabled then
        return false
    elseif debuff.recently_challenged.down then
        return true
    elseif cycle then return
        active_dot.recently_challenged < active_enemies
    end
    return false
end )

spec:RegisterStateExpr( "alpha_tiger_ready_in", function ()
    if not pvptalent.alpha_tiger.enabled then return 3600 end
    if active_dot.recently_challenged < active_enemies then return 0 end
    return debuff.recently_challenged.remains
end )

spec:RegisterStateFunction( "weapons_of_order", function( c )
    if c and c > 0 then
        return buff.weapons_of_order_ww.up and ( c - 1 ) or c
    end
    return c
end )


spec:RegisterPet( "xuen_the_white_tiger", 63508, "invoke_xuen", 24, "xuen" )

spec:RegisterTotem( "jade_serpent_statue", 620831 )
spec:RegisterTotem( "white_tiger_statue", 125826 )
spec:RegisterTotem( "black_ox_statue", 627607 )


spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "CHI" then
        Hekili:ForceUpdate( event, true )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Kick with a blast of Chi energy, dealing $?s137025[${$s1*$<CAP>/$AP}][$s1] Physical damage.$?s261917[    Reduces the cooldown of Rising Sun Kick and Fists of Fury by ${$m3/1000}.1 sec when used.][]$?s387638[    Strikes up to $387638s1 additional$ltarget;targets.][]$?s387625[    $@spelldesc387624][]$?s387046[    Critical hits grant an additional $387046m2 $Lstack:stacks; of Elusive Brawler.][]
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.serenity.up or buff.bok_proc.up then return 0 end
            return weapons_of_order( 1 )
        end,
        spendType = "chi",

        startsCombat = true,
        texture = 574575,

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if talent.mark_of_the_crane.enabled and cycle_enemies > active_dot.mark_of_the_crane and active_dot.mark_of_the_crane < 5 and debuff.mark_of_the_crane.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target missing Mark of the Crane debuff." ) end
                return "mark_of_the_crane"
            end
        
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target with Skyreach debuff." ) end
                return "keefers_skyreach"
            end
        end,
        
        cycle_to = function()
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                return true
            end
        end,

        handler = function ()
            if buff.blackout_reinforcement.up then
                removeBuff( "blackout_reinforcement" )
                if set_bonus.tier31_4pc > 0 then
                    reduceCooldown( "fists_of_fury", 3 )
                    reduceCooldown( "rising_sun_kick", 3 )
                    reduceCooldown( "strike_of_the_windlord", 3 )
                    reduceCooldown( "whirling_dragon_punch", 3 )
                end
            end
            if buff.bok_proc.up and buff.serenity.down then
                removeBuff( "bok_proc" )
                if set_bonus.tier21_4pc > 0 then gain( 1, "chi" ) end
            end
            reduceCooldown( "rising_sun_kick", buff.weapons_of_order.up and 2 or 1 )
            reduceCooldown( "fists_of_fury", buff.weapons_of_order.up and 2 or 1 )

            removeBuff( "teachings_of_the_monastery" )

            if talent.eye_of_the_tiger.enabled then applyDebuff( "target", "eye_of_the_tiger" ) end
            if talent.mark_of_the_crane.enabled then
                applyDebuff( "target", "mark_of_the_crane" )
                if talent.shadowboxing_treads.enabled then active_dot.mark_of_the_crane = min( active_dot.mark_of_the_crane + 2, active_enemies ) end
            end
                if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
        end,
    },

    -- Talent / Covenant (Necrolord): Hurl a brew created from the bones of your enemies at the ground, coating all targets struck for $d.  Your abilities have a $h% chance to affect the target a second time at $s1% effectiveness as Shadow damage or healing.    $?s137024[Gust of Mists heals targets with your Bonedust Brew active for an additional $328748s1.]?s137023[Tiger Palm and Keg Smash reduces the cooldown of your brews by an additional $s3 sec when striking enemies with your Bonedust Brew active.]?s137025[Spinning Crane Kick refunds 1 Chi when striking enemies with your Bonedust Brew active.][]
    bonedust_brew = {
        id = function() return talent.bonedust_brew.enabled and 386276 or 325216 end,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "bonedust_brew" )
            if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
        end,

        copy = { 386276, 352216 }
    },

    -- Talent: Hurls a torrent of Chi energy up to 40 yds forward, dealing $148135s1 Nature damage to all enemies, and $130654s1 healing to the Monk and all allies in its path. Healing reduced beyond $s1 targets.  $?c1[    Casting Chi Burst does not prevent avoiding attacks.][]$?c3[    Chi Burst generates 1 Chi per enemy target damaged, up to a maximum of $s3.][]
    chi_burst = {
        id = 123986,
        cast = function () return 1 * haste end,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        spend = function() return max( -2, true_active_enemies ) end,
        spendType = "chi",

        talent = "chi_burst",
        startsCombat = false,
    },

    -- Talent: Torpedoes you forward a long distance and increases your movement speed by $119085m1% for $119085d, stacking up to 2 times.
    chi_torpedo = {
        id = 115008,
        cast = 0,
        charges = function () return legendary.roll_out.enabled and 3 or 2 end,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        school = "physical",

        talent = "chi_torpedo",
        startsCombat = false,

        handler = function ()
            -- trigger chi_torpedo [119085]
            applyBuff( "chi_torpedo" )
        end,
    },

    -- Talent: A wave of Chi energy flows through friends and foes, dealing $132467s1 Nature damage or $132463s1 healing. Bounces up to $s1 times to targets within $132466a2 yards.
    chi_wave = {
        id = 115098,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        talent = "chi_wave",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Channel Jade lightning, causing $o1 Nature damage over $117952d to the target$?a154436[, generating 1 Chi each time it deals damage,][] and sometimes knocking back melee attackers.
    crackling_jade_lightning = {
        id = 117952,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
        spendPerSec = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,

        startsCombat = false,

        handler = function ()
            applyBuff( "crackling_jade_lightning" )
            removeBuff( "the_emperors_capacitor" )
        end,
    },

    -- Talent: Reduces all damage you take by $m2% to $m3% for $d, with larger attacks being reduced by more.
    dampen_harm = {
        id = 122278,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "physical",

        talent = "dampen_harm",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "dampen_harm" )
        end,
    },

    -- Talent: Removes all Poison and Disease effects from the target.
    detox = {
        id = 218164,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "nature",

        spend = 20,
        spendType = "energy",

        talent = "detox",
        startsCombat = false,

        toggle = "interrupts",
        usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up, "requires dispellable_poison/disease" end,

        handler = function ()
            removeDebuff( "player", "dispellable_poison" )
            removeDebuff( "player", "dispellable_disease" )
        end,nm
    },

    -- Talent: Reduces magic damage you take by $m1% for $d, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    diffuse_magic = {
        id = 122783,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "diffuse_magic",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Reduces the target's movement speed by $s1% for $d, duration refreshed by your melee attacks.$?s343731[ Targets already snared will be rooted for $116706d instead.][]
    disable = {
        id = 116095,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 15,
        spendType = "energy",

        talent = "disable",
        startsCombat = true,

        handler = function ()
            if not debuff.disable.up then applyDebuff( "target", "disable" )
            else applyDebuff( "target", "disable_root" ) end
        end,
    },

    -- Expel negative chi from your body, healing for $s1 and dealing $s2% of the amount healed as Nature damage to an enemy within $115129A1 yards.$?s322102[    Draws in the positive chi of all your Healing Spheres to increase the healing of Expel Harm.][]$?s325214[    May be cast during Soothing Mist, and will additionally heal the Soothing Mist target.][]$?s322106[    |cFFFFFFFFGenerates $s3 Chi.]?s342928[    |cFFFFFFFFGenerates ${$s3+$342928s2} Chi.][]
    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        spend = 15,
        spendType = "energy",

        startsCombat = false,

        handler = function ()
            gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            removeBuff( "gift_of_the_ox" )
            healing_sphere.count = 0

            gain( pvptalent.reverse_harm.enabled and 2 or 1, "chi" )
        end,
    },

    -- Talent: Strike the ground fiercely to expose a faeline for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the faeline. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the faeline$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].    Your abilities have a $s2% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    jadefire_stomp = {
        id = function() return talent.jadefire_stomp.enabled and 388193 or 327104 end,
        cast = 0,
        -- charges = 1,
        cooldown = function() return state.spec.mistweaver and 10 or 30 end,
        -- recharge = 30,
        gcd = "spell",
        school = "nature",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        cycle = function() if talent.jadefire_harmony.enabled then return "jadefire_brand" end end,

        handler = function ()
            applyBuff( "jadefire_stomp" )

            if spec.brewmaster then
                applyDebuff( "target", "breath_of_fire" )
                active_dot.breath_of_fire = active_enemies
            end

            if spec.mistweaver then
                if talent.ancient_concordance.enabled then applyBuff( "ancient_concordance" ) end
                if talent.ancient_teachings.enabled then applyBuff( "ancient_teachings" ) end
                if talent.awakened_faeline.enabled then applyBuff( "awakened_faeline" ) end
            end

            if talent.jadefire_harmony.enabled or legendary.fae_exposure.enabled then applyDebuff( "target", "jadefire_brand" ) end
        end,

        copy = { 388193, 327104, "faeline_stomp" }
    },

    -- Talent: Pummels all targets in front of you, dealing ${5*$117418s1} Physical damage to your primary target and ${5*$117418s1*$s6/100} damage to all other enemies over $113656d. Deals reduced damage beyond $s1 targets. Can be channeled while moving.
    fists_of_fury = {
        id = 113656,
        cast = 4,
        channeled = true,
        cooldown = function ()
            local x = 24 * haste
            if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
            return x
        end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.serenity.up then return 0 end
            return weapons_of_order( 3 )
        end,
        spendType = "chi",

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target with Skyreach debuff." ) end
                return "keefers_skyreach"
            end
        end,
        
        cycle_to = function()
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                return true
            end
        end,

        tick_time = function () return haste end,

        start = function ()
            removeBuff( "fists_of_flowing_momentum" )
            removeBuff( "transfer_the_power" )

            if buff.fury_of_xuen.stack >= 50 then
                applyBuff( "fury_of_xuen_haste" )
                summonPet( "xuen", 8 )
                removeBuff( "fury_of_xuen" )
            end

            if talent.whirling_dragon_punch.enabled and cooldown.rising_sun_kick.remains > 0 then
                applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
            end

            if pvptalent.turbo_fists.enabled then
                applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
            end

            if legendary.pressure_release.enabled then
                -- TODO: How much to generate?  Do we need to queue it?  Special buff generator?
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "kicks_of_flowing_momentum", nil, set_bonus.tier29_4pc > 0 and 3 or 2 ) end
            if set_bonus.tier30_4pc > 0 then
                applyDebuff( "target", "shadowflame_vulnerability" )
                active_dot.shadowflame_vulnerability = active_enemies
            end
        end,

        tick = function ()
            if legendary.jade_ignition.enabled then
                addStack( "chi_energy", nil, active_enemies )
            end
        end,

        finish = function ()
            if talent.xuens_battlegear.enabled or legendary.xuens_battlegear.enabled then applyBuff( "pressure_point" ) end
        end,
    },

    -- Talent: Soar forward through the air at high speed for $d.     If used again while active, you will land, dealing $123586s1 damage to all enemies within $123586A1 yards and reducing movement speed by $123586s2% for $123586d.
    flying_serpent_kick = {
        id = 101545,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "physical",

        talent = "flying_serpent_kick",
        startsCombat = false,

        -- Sync to the GCD even though it's not really on it.
        readyTime = function()
            return gcd.remains
        end,

        handler = function ()
            if buff.flying_serpent_kick.up then
                removeBuff( "flying_serpent_kick" )
            else
                applyBuff( "flying_serpent_kick" )
                setCooldown( "global_cooldown", 2 )
            end
        end,
    },

    -- Talent: Turns your skin to stone for $120954d$?a388917[, increasing your current and maximum health by $<health>%][]$?s322960[, increasing the effectiveness of Stagger by $322960s1%][]$?a388917[, reducing all damage you take by $<damage>%][]$?a388814[, increasing your armor by $388814s2% and dodge chance by $388814s1%][].
    fortifying_brew = {
        id = 115203,
        cast = 0,
        cooldown = function() return talent.expeditious_fortification.enabled and 240 or 360 end,
        gcd = "off",
        school = "physical",

        talent = "fortifying_brew",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "fortifying_brew" )
            if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
        end,
    },


    grapple_weapon = {
        id = 233759,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "grapple_weapon",

        startsCombat = true,
        texture = 132343,

        handler = function ()
            applyDebuff( "target", "grapple_weapon" )
        end,
    },

    -- Talent: Summons an effigy of Xuen, the White Tiger for $d. Xuen attacks your primary target, and strikes 3 enemies within $123996A1 yards every $123999t1 sec with Tiger Lightning for $123996s1 Nature damage.$?s323999[    Every $323999s1 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing $323999s2% of the damage you have dealt to those targets in the last $323999s1 sec.][]
    invoke_xuen = {
        id = 123904,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "nature",

        talent = "invoke_xuen",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "xuen_the_white_tiger", 24 )
            applyBuff( "invoke_xuen" )

            if talent.invokers_delight.enabled or legendary.invokers_delight.enabled then
                if buff.invokers_delight.down then stat.haste = stat.haste + 0.33 end
                applyBuff( "invokers_delight" )
            end
        end,

        copy = "invoke_xuen_the_white_tiger"
    },

    -- Knocks down all enemies within $A1 yards, stunning them for $d.
    leg_sweep = {
        id = 119381,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.tiger_tail_sweep.rank end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "leg_sweep" )
            active_dot.leg_sweep = active_enemies
            if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
        end,
    },

    -- Talent: Incapacitates the target for $d. Limit 1. Damage will cancel the effect.
    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = function() return talent.improved_paralysis.enabled and 30 or 45 end,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "energy",

        talent = "paralysis",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "paralysis" )
        end,
    },

    -- Taunts the target to attack you$?s328670[ and causes them to move toward you at $116189m3% increased speed.][.]$?s115315[    This ability can be targeted on your Statue of the Black Ox, causing the same effect on all enemies within  $118635A1 yards of the statue.][]
    provoke = {
        id = 115546,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "provoke" )
        end,
    },

    -- Talent: Form a Ring of Peace at the target location for $d. Enemies that enter will be ejected from the Ring.
    ring_of_peace = {
        id = 116844,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "ring_of_peace",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Kick upwards, dealing $?s137025[${$185099s1*$<CAP>/$AP}][$185099s1] Physical damage$?s128595[, and reducing the effectiveness of healing on the target for $115804d][].$?a388847[    Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds][]
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = function ()
            local x = ( buff.tea_of_plenty_rsk.up and 1 or 10 ) * haste
            if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
            return x
        end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.serenity.up then return 0 end
            return weapons_of_order( 2 )
        end,
        spendType = "chi",

        talent = "rising_sun_kick",
        startsCombat = true,

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if talent.mark_of_the_crane.enabled and cycle_enemies > active_dot.mark_of_the_crane and active_dot.mark_of_the_crane < 5 and debuff.mark_of_the_crane.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target missing Mark of the Crane debuff." ) end
                return "mark_of_the_crane"
            end
        
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target with Skyreach debuff." ) end
                return "keefers_skyreach"
            end
        end,
        
        cycle_to = function()
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                return true
            end
        end,

        handler = function ()
            applyDebuff( "target", "rising_sun_kick" )
            removeStack( "tea_of_plenty_rsk" )

            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
            end

            if talent.mark_of_the_crane.enabled then applyDebuff( "target", "mark_of_the_crane" ) end

            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end

            if talent.whirling_dragon_punch.enabled and cooldown.fists_of_fury.remains > 0 then
                applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
            end

            if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end

            if buff.weapons_of_order.up then
                applyBuff( "weapons_of_order_ww" )
                state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
            end
        end,
    },

    -- Roll a short distance.
    roll = {
        id = 109132,
        cast = 0,
        charges = function ()
            local n = 1 + ( talent.celerity.enabled and 1 or 0 ) + ( legendary.roll_out.enabled and 1 or 0 )
            if n > 1 then return n end
            return nil
        end,
        cooldown = function () return talent.celerity.enabled and 15 or 20 end,
        recharge = function () return talent.celerity.enabled and 15 or 20 end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        notalent = "chi_torpedo",

        handler = function ()
            if azerite.exit_strategy.enabled then applyBuff( "exit_strategy" ) end
        end,
    },

    -- Talent: Summons a whirling tornado around you, causing ${(1+$d/$t1)*$148187s1} Physical damage over $d to all enemies within $107270A1 yards. Deals reduced damage beyond $s1 targets.
    rushing_jade_wind = {
        id = 116847,
        cast = 0,
        cooldown = function ()
            local x = 6 * haste
            if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
            return x
        end,
        gcd = "spell",
        school = "nature",

        spend = function() return weapons_of_order( 1 ) end,
        spendType = "chi",

        talent = "rushing_jade_wind",
        startsCombat = false,

        handler = function ()
            applyBuff( "rushing_jade_wind" )
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
        end,
    },

    -- Talent: Enter an elevated state of mental and physical serenity for $?s115069[$s1 sec][$d]. While in this state, you deal $s2% increased damage and healing, and all Chi consumers are free and cool down $s4% more quickly.
    serenity = {
        id = 152173,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
        gcd = "off",
        school = "physical",

        talent = "serenity",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "serenity" )
            setCooldown( "fists_of_fury", cooldown.fists_of_fury.remains - ( cooldown.fists_of_fury.remains / 2 ) )
            setCooldown( "rising_sun_kick", cooldown.rising_sun_kick.remains - ( cooldown.rising_sun_kick.remains / 2 ) )
            setCooldown( "rushing_jade_wind", cooldown.rushing_jade_wind.remains - ( cooldown.rushing_jade_wind.remains / 2 ) )
            if conduit.coordinated_offensive.enabled then applyBuff( "coordinated_offensive" ) end
        end,
    },

    -- Talent: Heals the target for $o1 over $d.  While channeling, Enveloping Mist$?s227344[, Surging Mist,][]$?s124081[, Zen Pulse,][] and Vivify may be cast instantly on the target.$?s117907[    Each heal has a chance to cause a Gust of Mists on the target.][]$?s388477[    Soothing Mist heals a second injured ally within $388478A2 yds for $388477s1% of the amount healed.][]
    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        hasteCD = true,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        talent = "soothing_mist",
        startsCombat = false,

        handler = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    -- Talent: Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $d.
    spear_hand_strike = {
        id = 116705,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "spear_hand_strike",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },

    -- Spin while kicking in the air, dealing $?s137025[${4*$107270s1*$<CAP>/$AP}][${4*$107270s1}] Physical damage over $d to all enemies within $107270A1 yds. Deals reduced damage beyond $s1 targets.$?a220357[    Spinning Crane Kick's damage is increased by $220358s1% for each unique target you've struck in the last $220358d with Tiger Palm, Blackout Kick, or Rising Sun Kick. Stacks up to $228287i times.][]
    spinning_crane_kick = {
        id = 101546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return buff.dance_of_chiji.up and 0 or weapons_of_order( 2 ) end,
        spendType = "chi",

        startsCombat = true,

        usable = function ()
            if settings.check_sck_range and not action.fists_of_fury.in_range then return false, "target is out of range" end
            return true
        end,

        handler = function ()
            removeBuff( "chi_energy" )
            if buff.dance_of_chiji.up then
                if set_bonus.tier31_2pc > 0 then applyBuff( "blackout_reinforcement" ) end
                removeBuff( "dance_of_chiji" )
            end

            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
            end

            applyBuff( "spinning_crane_kick" )

            if debuff.bonedust_brew.up or active_dot.bonedust_brew > 0 and active_enemies > 1 then
                gain( 1, "chi" )
            end
        end,
    },

    -- Talent: Split into 3 elemental spirits for $d, each spirit dealing ${100+$m1}% of normal damage and healing.    You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies.    While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    storm_earth_and_fire = {
        id = 137639,
        cast = 0,
        charges = 2,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
        recharge = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
        icd = 1,
        gcd = "off",
        school = "nature",

        talent = "storm_earth_and_fire",
        notalent = "serenity",
        startsCombat = false,

        toggle = function ()
            if settings.sef_one_charge then
                if cooldown.storm_earth_and_fire.true_time_to_max_charges > gcd.max then return "cooldowns" end
                return
            end
            return "cooldowns"
        end,

        handler = function ()
            -- trigger storm_earth_and_fire_fixate [221771]
            applyBuff( "storm_earth_and_fire" )
        end,

        bind = "storm_earth_and_fire_fixate"
    },


    storm_earth_and_fire_fixate = {
        id = 221771,
        known = 137639,
        cast = 0,
        cooldown = 0,
        icd = 1,
        gcd = "spell",

        startsCombat = true,
        texture = 236188,

        notalent = "serenity",
        buff = "storm_earth_and_fire",

        usable = function ()
            if buff.storm_earth_and_fire.down then return false, "spirits are not active" end
            return action.storm_earth_and_fire_fixate.lastCast < action.storm_earth_and_fire.lastCast, "spirits are already fixated"
        end,

        bind = "storm_earth_and_fire",
    },

    -- Talent: Strike with both fists at all enemies in front of you, dealing ${$395519s1+$395521s1} damage and reducing movement speed by $s2% for $d.
    strike_of_the_windlord = {
        id = 392983,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "physical",

        spend = 2,
        spendType = "chi",

        talent = "strike_of_the_windlord",
        startsCombat = true,

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target with Skyreach debuff." ) end
                return "keefers_skyreach"
            end
        end,
        
        cycle_to = function()
            if talent.skyreach.enabled and active_dot.keefers_skyreach > 0 and debuff.keefers_skyreach.down then
                return true
            end
        end,

        handler = function ()
            applyDebuff( "target", "strike_of_the_windlord" )
            if talent.thunderfist.enabled then addStack( "thunderfist", nil, true_active_enemies ) end
        end,
    },

    -- Talent: Summons a Black Ox Statue at the target location for $d, pulsing threat to all enemies within $163178A1 yards.    You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_black_ox_statue = {
        id = 115315,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "physical",

        talent = "summon_black_ox_statue",
        startsCombat = false,

        handler = function ()
            summonTotem( "black_ox_statue" )
        end,
    },

    -- Talent: Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for $198533o1 over $198533d.
    summon_jade_serpent_statue = {
        id = 115313,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        talent = "summon_jade_serpent_statue",
        startsCombat = false,

        handler = function ()
            summonTotem( "jade_serpent_statue" )
        end,
    },

    -- Talent: Summons a White Tiger Statue at the target location for $d, pulsing $389541s1 damage to all enemies every 2 sec for $d.
    summon_white_tiger_statue = {
        id = 388686,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",

        talent = "summon_white_tiger_statue",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "white_tiger_statue" )
        end,
    },

    -- Strike with the palm of your hand, dealing $s1 Physical damage.$?a137384[    Tiger Palm has an $137384m1% chance to make your next Blackout Kick cost no Chi.][]$?a137023[    Reduces the remaining cooldown on your Brews by $s3 sec.][]$?a129914[    |cFFFFFFFFGenerates 3 Chi.]?a137025[    |cFFFFFFFFGenerates $s2 Chi.][]
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 50,
        spendType = "energy",

        startsCombat = true,

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if talent.mark_of_the_crane.enabled and cycle_enemies > active_dot.mark_of_the_crane and active_dot.mark_of_the_crane < 5 and debuff.mark_of_the_crane.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target missing Mark of the Crane debuff." ) end
                return "mark_of_the_crane"
            end
        end,

        buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

        handler = function ()
            gain( buff.power_strikes.up and 3 or 2, "chi" )
            removeBuff( "power_strikes" )

            if talent.mark_of_the_crane.enabled then applyDebuff( "target", "mark_of_the_crane" ) end

            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end

            if ( legendary.keefers_skyreach.enabled or talent.skyreach.enabled or talent.skytouch.enabled ) and debuff.skyreach_exhaustion.down then
                if talent.skytouch.enabled and target.minR > 10 then setDistance( 5 ) end
                applyDebuff( "target", "skyreach" )
                applyDebuff( "target", "skyreach_exhaustion" )
            end

            if talent.teachings_of_the_monastery.enabled then addStack( "teachings_of_the_monastery" ) end

            if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                if buff.alpha_tiger.down then
                    stat.haste = stat.haste + 0.10
                    applyBuff( "alpha_tiger" )
                    applyDebuff( "target", "recently_challenged" )
                end
            end
        end,
    },


    tigereye_brew = {
        id = 247483,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        startsCombat = false,
        texture = 613399,

        buff = "tigereye_brew_stack",
        pvptalent = "tigereye_brew",

        handler = function ()
            applyBuff( "tigereye_brew", 2 * min( 10, buff.tigereye_brew_stack.stack ) )
            removeStack( "tigereye_brew_stack", min( 10, buff.tigereye_brew_stack.stack ) )
        end,
    },

    -- Talent: Increases a friendly target's movement speed by $s1% for $d and removes all roots and snares.
    tigers_lust = {
        id = 116841,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "tigers_lust",
        startsCombat = false,

        handler = function ()
            applyBuff( "tigers_lust" )
        end,
    },

    -- You exploit the enemy target's weakest point, instantly killing $?s322113[creatures if they have less health than you.][them.    Only usable on creatures that have less health than you]$?s322113[ Deals damage equal to $s3% of your maximum health against players and stronger creatures under $s2% health.][.]$?s325095[    Reduces delayed Stagger damage by $325095s1% of damage dealt.]?s325215[    Spawns $325215s1 Chi Spheres, granting 1 Chi when you walk through them.]?s344360[    Increases the Monk's Physical damage by $344361s1% for $344361d.][]
    touch_of_death = {
        id = 322109,
        cast = 0,
        cooldown = function () return 180 - ( 45 * talent.fatal_touch.rank ) end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        toggle = "cooldowns",
        cycle = "touch_of_death",

        -- Non-players can be executed as soon as their current health is below player's max health.
        -- All targets can be executed under 15%, however only at 35% damage.
        usable = function ()
            return ( talent.improved_touch_of_death.enabled and target.health.pct < 15 ) or ( target.class == "npc" and target.health_current < health.max ), "requires low health target"
        end,

        handler = function ()
            applyDebuff( "target", "touch_of_death" )

            if talent.forbidden_technique.enabled then
                if buff.hidden_masters_forbidden_touch.down then
                    setCooldown( "touch_of_death", 0 )
                    applyBuff( "hidden_masters_forbidden_touch" )
                else
                    removeBuff( "hidden_masters_forbidden_touch" )
                end
            end
        end,
    },

    -- Talent: Absorbs all damage taken for $d, up to $s3% of your maximum health, and redirects $s4% of that amount to the enemy target as Nature damage over $124280d.
    touch_of_karma = {
        id = 122470,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

        talent = "touch_of_karma",
        startsCombat = true,

        toggle = "defensives",

        usable = function ()
            return incoming_damage_3s >= health.max * ( settings.tok_damage or 20 ) / 100, "incoming damage not sufficient (" .. ( settings.tok_damage or 20 ) .. "% / 3 sec) to use"
        end,

        handler = function ()
            applyBuff( "touch_of_karma" )
            applyDebuff( "target", "touch_of_karma_debuff" )
        end,
    },

    -- Talent: Split your body and spirit, leaving your spirit behind for $d. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence = {
        id = 101643,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        talent = "transcendence",
        startsCombat = false,

        handler = function ()
            applyBuff( "transcendence" )
        end,
    },


    transcendence_transfer = {
        id = 119996,
        cast = 0,
        cooldown = function () return buff.escape_from_reality.up and 0 or 45 end,
        gcd = "spell",

        startsCombat = false,
        texture = 237585,

        buff = "transcendence",

        handler = function ()
            if buff.escape_from_reality.up then removeBuff( "escape_from_reality" )
            elseif legendary.escape_from_reality.enabled then
                applyBuff( "escape_from_reality" )
            end
        end,
    },

    -- Causes a surge of invigorating mists, healing the target for $s1$?s274586[ and all allies with your Renewing Mist active for $s2][].
    vivify = {
        id = 116670,
        cast = function() return buff.vivacious_vivification.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.038,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            removeBuff( "vivacious_vivification" )
        end,
    },

    -- Talent: Performs a devastating whirling upward strike, dealing ${3*$158221s1} damage to all nearby enemies. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    whirling_dragon_punch = {
        id = 152175,
        cast = 0,
        cooldown = 24,
        gcd = "spell",
        school = "physical",

        talent = "whirling_dragon_punch",
        startsCombat = false,

        usable = function ()
            if settings.check_wdp_range and not action.fists_of_fury.in_range then return false, "target is out of range" end
            return cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0, "requires fists_of_fury and rising_sun_kick on cooldown"
        end,

        handler = function ()
        end,
    },

    -- You fly through the air at a quick speed on a meditative cloud.
    zen_flight = {
        id = 125883,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "zen_flight" )
        end,
    },
} )

spec:RegisterRanges( "fists_of_fury", "strike_of_the_windlord" , "tiger_palm", "touch_of_karma", "crackling_jade_lightning" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = false,

    nameplates = true,
    rangeChecker = "fists_of_fury",
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_agility",

    package = "Windwalker",

    strict = false
} )

spec:RegisterSetting( "allow_fsk", false, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.abilities.flying_serpent_kick.id ) ),
    desc = strformat( "If unchecked, %s will not be recommended despite generally being used as a filler ability.\n\n"
        .. "Unchecking this option is the same as disabling the ability via |cFFFFD100Abilities|r > |cFFFFD100|W%s|w|r > |cFFFFD100|W%s|w|r > |cFFFFD100Disable|r.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.flying_serpent_kick.id ), spec.name, spec.abilities.flying_serpent_kick.name ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val
    end,
} )

--[[ Deprecated.
spec:RegisterSetting( "optimize_reverse_harm", false, {
    name = "Optimize |T627486:0|t Reverse Harm",
    desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
    type = "toggle",
    width = "full",
} ) ]]

spec:RegisterSetting( "sef_one_charge", false, {
    name = strformat( "%s: Reserve 1 Charge for Cooldowns Toggle", Hekili:GetSpellLinkWithTexture( spec.abilities.storm_earth_and_fire.id ) ),
    desc = strformat( "If checked, %s can be recommended while Cooldowns are disabled, as long as you will retain 1 remaining charge.\n\n"
        .. "If |W%s's|w |cFFFFD100Required Toggle|r is changed from |cFF00B4FFDefault|r, this feature is disabled.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.storm_earth_and_fire.id ), spec.abilities.storm_earth_and_fire.name ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "tok_damage", 1, {
    name = strformat( "%s: Required Incoming Damage", Hekili:GetSpellLinkWithTexture( spec.abilities.touch_of_karma.id ) ),
    desc = strformat( "If set above zero, %s will only be recommended if you have taken this percentage of your maximum health in damage in the past 3 seconds.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.touch_of_karma.id ) ),
    type = "range",
    min = 0,
    max = 99,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "check_wdp_range", false, {
    name = strformat( "%s: Check Range", Hekili:GetSpellLinkWithTexture( spec.abilities.whirling_dragon_punch.id ) ),
    desc = strformat( "If checked, %s will not be recommended if your target is outside your %s range.", Hekili:GetSpellLinkWithTexture( spec.abilities.whirling_dragon_punch.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.fists_of_fury.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_sck_range", false, {
    name = strformat( "%s: Check Range", Hekili:GetSpellLinkWithTexture( spec.abilities.spinning_crane_kick.id ) ),
    desc = strformat( "If checked, %s will not be recommended if your target is outside your %s range.", Hekili:GetSpellLinkWithTexture( spec.abilities.spinning_crane_kick.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.fists_of_fury.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "use_diffuse", false, {
    name = strformat( "%s: Self-Dispel", Hekili:GetSpellLinkWithTexture( spec.abilities.diffuse_magic.id ) ),
    desc = function()
        local m = strformat( "If checked, %s may be recommended when when you have a dispellable magic debuff.", Hekili:GetSpellLinkWithTexture( spec.abilities.diffuse_magic.id ) )

        local t = class.abilities.diffuse_magic.toggle
        if t then
            local active = Hekili.DB.profile.toggles[ t ].value
            m = m .. "\n\n" .. ( active and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires " .. t:gsub("^%l", string.upper) .. " Toggle|r"
        end

        return m
    end,
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Windwalker", 20240203, [[Hekili:S3ZAVTnss(BXF4eSXUrrI(rMSRTb2j7K7U9UzUGXzX9ntrj1YIXuKAjPStgeOF7x)Gp6MSQ(bfPIdUGbWJJzZURQ66DxDX7NE)hV)ULb5K7)nVjExmXBY5JN8MPV17I7Vl)lBj3F32Gfpg8a9xId2q)5)By8YNdIEKKYE0xIscwYMISKDPlOpEDE(2S)YRF9dH5R3nF8IKnVolCZUOG8WK4fPbRYz)7fVEEuY8xVmn4HK4vrHpSo)1BttwfgrYE9hsj)Eq4s6V87()As8J(1l5y27E)DZ3fgL)FgF)CqqF6LuWzlzb9pF1BPqu4YLeXyjz0xMn2xnX7vto)VSF2DKusCy(x2pl7lXl2pljoI(7bB3gfsY2plpz)SugSmE))y))q8MtF10ROV5)mJSFwm5z6GcIiX50)bL(0yGtOd83jl3TGo2OWhjrHRtswsxMv7NTllm(H9Z(4h2pB5Uu(VxcnktYKlPtYVggNKUF220WKuo4UkkHU0bl)0US8n0LV8vo)vt9EL3pv)kukgDT2YOtQJHnT3v)WmPNsH8Z3pB0(zEE)19ZOdE656g8K3qF673LMVMqxWPtg7Hmo2s(HG8fRfJQ(Ht(jXK87K)1UWukX6Uh)skjyX6xt)L8KDS3yfdBYdsFGqP1l(YIikjtDg8ea57Qw99Z2KKLZ2rtjmksq6JcApfs3p7DPbX0)xq8Y61t3k8MIvipLUtknpm2ZOK0LLBhe6VfgZO8XperELycLMNREL3f05rS1x)kC8loj(vTWDP39sXEB1UBlYmBeIz)U39F9NPu07y)KJJVp59mUoQSCBgc6Rn9nYtmfjJFKK)NRjnLtZDFuMpmL8uygv0wfe4ekQmcFvkqn6o(uPbDr5c(r62qweFC85pLeUzBezdxM69Hz5zcAnLb7lfW)RxeeVGejuQGl(iwLlvbL0KnCUKcvsVJPss6foxiySF2FJVXqbpb3hdc(7KGC5ndQq0u(yzmUuYarOWGeNTJXd3c2dZkvWmpn5rcfYFEn7N1kHyJiyrE4te1LzIyRj4tmc5I1bXpuQDkGQ8Knru1TuvmmEH8wOx9(LcIorWjvc6)AqCivd4)EAizvEskdP5e7)kJjDjHVZWLof7m5RdYRLwyao5ZuLUCwzgGfrrc6ptOGAkF0XfIllcyGyE4McYvAH(X0WScPZTbP5HbrIHo((7IyesMrMKTKyQDNpE)VXnBrIdMhrwE)pluTNgULHY3F3)Jyy3XOKS)D2UnBsI9FEDyoXppKcq(z5b57i3NtTr0yMOttojnmGA(JRxF8I1H(Z3LsHKIrX1ms)RJ3e859ZEf)33p72B2p7861KrmI8xhKUHTiNJUiljZ3TA14vbeF6RKW4C8xgSHs3htP0bHXuc71ufX8f9ekVUy8zfcL0xADaLpLUMJ3TTE5)uWsYk6Effrt2SLbcx0z8C)mDO2LOZBlseDA8QNg269CWt8nHRytcW8lnX0r9gDlfDhGQJbFVPXkZX07z)3DzfIF(NNdXAHqsvz5QfHPgo)ixOiRdBZtH4ilbG5rupXs2L7)y4IhLN8msU)8K4DzJZdjPNp13B7cbHizZ8ek8kmyr)dCGOAEOAAJPQMxWLO5SpmJEurKc4)3McX7wcocbPTbrBKHftSOTGl4fTj3ALO82W4yQYE)fmJ3TOef2Azkx8Zt8xgs4SfudefMkqjklzwu8tw5tzo(uyjGcSCcolHWOEYPyga2BGr5McsvOmhszGgv9P)ZfoBaiatD4oEjjDvydryouUiikItss2egZW1sauZUvfN5TOtsXqGXORgkmYsy(YlHHRM6rmkG1lYr)eYQYWUmgXyf1jbGx9UWykyKUBlvv1uzOIdeHXprDLinZFjHhgv526jySEvZMF4kQ4k0G(6xfkROWddU(8osmZG5IhZgZ)F3(2jme6Thrz0JPG40jVqqSoIv8hSL6y(yfgA(FU0wpFXEkjnN85sjleIbM5q7fwk3FOGug3W32KqnYjtXS)rDqKrOY2f3AnDA(XmO588dTdmrdFfMrnnlSdZoUJyw68HNo3hNoekZrWem9ZdH83qz8hb1WmcyV0KdCehtf0DKG4HPR1EccFzZz(bqrPSsgrAaF0GhjPFryYQm4dqyWzvCfC0zRdwM888KpZOL5uxrwMPg7Kr3C9W01Hkvbnjyk0659zKv)c5y3OXyNYsBMVi1U(B3fVyDJW48W1uvYfLUlJTB6Z0dXXELGBB9u(SIPGYkojeCdtteCSpLk6W5fB5wUz(2R5XEdaDYrUM1hrUoTmY1Uy7OujGzxZ1fIBpWXkw(YmbQeC94l7KURQ5aYFRlW0(INYNoeImaFN2u6Cakjp3QXRM0ceznTzhYqiEWeAdQhbI5etChZ3lTPzYwHbDos10daRPihLW4ntGB6uH1WVLqilODZqrRy0mX7d7INrVwQJLQbJcA0x6vMbfrL9o7vhExhHAnsQOHD1d6KhOTeLmNOzdXPOaTYDbN2doiW8yMiu7i96t5GPSzbfPAjo18DnMPRg5gtByQVOOxiegJwEmP88WvV3kcv71onrv9xBnm4MoGTn3AgAfTOjPZwQymQDwemOtHZy8eehIaca9iK55(s)sNFHcjaX1)3LKerdLvMfHZfj(h(SdGvCmS(IIaQkWJCrzca6uVIhVlkwHcXyrsL5mF1NkBnR8x)A55G7tIjB41IdL9(cXtCBUy(umr8IZtYeUXVIPaXV2NnMFVtK4n0DGX4o2JOez6vLAlEkGoo67nEnfb4Gn)jfSjurjYsQqT)8uYZnsKqbcRoef4FAbkkuiLKSmIooUoi2FUjctDsvYplj6O(4koT8e)brs2cDIevUcSbdhJgY4zqBgSjZBc)jNYNVcESX5thhMnoiBnPs4GSzo1IqYUOskS6yzvfbjDEq6JzukgvxW6wJZZH50dBozi(P2cOSbBgmpdaJQONkYjNAl2OSWO4s7f2dyHpdL5rxeF6epAZHEvftGnw)eCumC0MrZd0qcz1WQoQTQivvWnia4rGklByuM3OYe9GSrvgkHP2afW9dbZtSAHFU(hL1SkJgfqKE11cKBlf1bhNyROHDG2uagL6sdk9z68XuazYGbBisoQiJV6dYVYeaREtRmvxYORN8Iy(40kUPLmrwM7kRtsJ9xK8eLGjZtbGOLy6jhYKmrikDwZPsN95QPe280u50au6qJ20piBFTdexNDQObmdGg3Yxw3M4)KG5dZY4BNOO7vMYGES18AiLzpyjR(f1608jnZFAHSBTD)1KGO81JxSlnLxgG0TkXFsY9drfx7VH73AMpnIO5I)IOAwRNtBgnGcENETBHvLwWRIOL9QjkMsuKV9l(JLmoA1rW3TS6C1R3vG31nUuaB4pgKUjam5on0ORSFByL8Kv8XC0ueUouov6RvHUbtsz6KQtjs5Z4cXz(FA3YhybD3i2mnhk(bbrSu6YXDWCo0tlcl2vQSzqKplwmdji4GwP5bpW9xmLgeCMioYLKvb7IY9Vq7jlPCoyTkCjnkA4LLz15gjRLujjqQNZqtR(GjXO5Ri0K6uS1kbjFrD9CceJ7qMEjnjjDaknb0drgovrwL3F4vclLMwK6qSmhAQ0DaDiL)KdTOEC(uN7qTdudToUNoGfsJo)8TRe3Gb5FY10VHvKlAyj0gMIgUct6OybvIyThpXLhqjp4ET5zPAWQJb2mZkc(2HA4ZEzon(zuEpdMwAxroq5glUAAuoXbllfopwDPgk17QNbPMkOEdkoQNXJf8Wsvaa7MsWUlnpuXACRWvtNoxh7psnh4bm40LAkqL84qkUs57bIoFRQEv(ejOhI)WeSjdRo)gITul8EsSRwXZksL(zURDgTKc7dnoWljAfc6ujYHPP8f1(bcS789bYyHTj5FV(780a4FpQsyap8FPflW5VeJf4fK)(q6W1uICO29ouqW5SUDllEySurEjQOPZg8SK17G9)67YOsSi(pmZQF7I)BaRXE7cXcXqnMvZ(nSiKfhZCs)49pEUm)U07FNlen7vIGCHhWd4WbxQC3BFtWT8znywBKI5F092Bf29rqHRCnzdMsaR7rDOPCRCpQJxsENF46)Co21RTi2vKe0GgGGgvwMahHx9JQ9XhJgEmDK0SiJfe6rkXTiKzLeBZts34tcsZx7heV0NDyjkErCIPYFOqdR0uwEWgYdblEjNvO6iJgYYIx1uhqk(ADxPChzSrzQytXPubGEFR6bU2tHyCly4UubP0YQjmrGmpxOmpT5VaXAPaNdsi6ICgMkOjeABOlUew4bEerkX9E7r7qWQvnqdtZNJVQbxA86Y3W5vyM3Hi4x4vcxRaBnBuFR)KjVr0eZzpq8TlGdD7dW0amnfweWhwSIF7c4Z5BWTd(yzP(AyaZzN)mVqAu64ym)AoaSwYb3O4UmQGGMkO5am42LtUQx4R6sBPWHzVd9EIc(dWna4YthEOT9p3K)Lvhcv5gjd0eJlk5z2cSjHXUTBdodN2(s23Fzjya92Yr3FLckTdNr43Nbqpeu5oDmrEgo2ozf0nOKw40338i8hyAIMMLvNinox)fD1KlKIEvihYFNMwwVwuu8JKDZwqQSPtq5(5q(nhB)jem5i1Wu6olD3oD(wPGW4oKd(MISKo31cDjvc9oNLZj5qBrH0UjJofKtS6bSwjUp5jgOhSKcRSUeT0rpcoL49T05lN7tfvOAN0LhcB3hSkgxq0722hu(pxiGUF2pNYAr63XbtGuhi5lRgL3veJlK4nAENBCRpLcLxiaIFTTdWunHzzWzbriovR9)2vU6oufTiPr7Mg5JtlScdmyY(UamqHq6DyWLC3vkiHWCKsNyMLTyP)wYVSF2)nBUKqhl7Qmtni)au2fYKaWmwzqlHUmLnaMk1LntRBIcDT6YB0yubdT5g2LeVLEsE(dcFGUdtxOkA7WMQoi9f6DHfLmwt6TYTQB5AHDrsUhqxu42D6amS31AsPBnNxu05uq6TuW25usy2kQ9mMC62KNzFsuQc6U4cVcmdxH(KlAyTbkEa7x(ZUxtgs7mT8elcjOlKA8Wjqiw13mZtnsqUrmCliUilMIH1UUTCt9DzgcFUa)rEwb78nCNZ8Sd(LlteCoL4OvbL9qMdriz14vTOdd1UDMIoPi1fBUDuv6q2iXS3oGfgdrAr2WueeC15AnOVWae4zaVkj2d5DLXX5ADOPERR5w6Gaj79Fent7d(ba1HZ60Hzh9gPCah5DnF6W2xk5ZeWMn6PmG3LiSmylTTWt3VskwqlHXe0um3zNPW8w6EDP4ThuFyPLheYGZ6z7SQbnYqO5xDiipoLrh00W2tFKEafaVb96U2kHUklnFH7WrZJ2nUp00e3Y93BQpO6AAacQ6SEvOj5iDUJWR(5C1zLlPnLb95dsPxCUZhWKf4MBzfUu98a0WgnKJr99zdltV4fd23ESEGruOV5O1y2r1IJF5XhOuOEmTACiHZ5iD8yMDtnOfAyjgXxy0Y5ZI8LqkdC2YO9bZ1fA4aE73ThWnU)llABFzq0H(nIMWdpr)vHageqtRvVhuGEsUGX1qkHhzojI1Cz1LS096sew3O127OFxkcuhM9b8m16rXdeG357oOfX(wZcmS5rabL(g9LtR3LwVxxwKoK9he62aQM3fpa6kNCVPjhE(7HpTz2Rt5O2GtCl1eohvNLrTBo4p868ZLyZpMUV3rwzr6FCjc(xkzOXInrmTmV0IG3Wfc0Yq4VT)JHFWdWDa9NXf7a2h66lkrAl8X(almhB)E7G7asVvsu)OgHSWpo9OZpkCL(PWvm8LqN7S1iODHrNEci1)RFvfCUD6KZgDQw88MPtgDcaC2AQUCeWOgzAUBdrx0(p5bcbNncdjfgI2P)BdVZ3s2JvjbD41QKL(m0NP37O(fPFaI0AadoXET(wyfUpQiiNd3PVWae4zaDoRVGCeApcc1HBYmCy7q4GlFG9TyHDy2hIVV(10(HnVAG(JQR(Cm(Ho0uGo6Z4wVxbYyEQPnpshYohmD7OExCDrRN73ewaULdV(CgWtV(atcMBLHWGxFoVq6vvMDIdeXCQ(CCwVk0KmGFifSafC(BIqR6jQx2Fp)GsOnmU1QsI0lyC0ZUxz3(Y7hTjBTupLSz6PTBHjro(oSrS4CHOAjz8GB)td25YcL0yyqW5EbGTGWXQFEpGzN0s3RkzoTiGj7t3TZNkJzEWUeMhmWzRV6YwWS3LqmFZnfjausxuabB1E0m4qDPdPFcKSd1UcFFJ9hfis7ESLquclmA2ZSmoYlX(ajnGPPOxf9qaFChQlMoxBRvo7lT92zW6k4ox5Jq8dYzeyrDdAAurcEAZe6w6bw4Ep9Qpkq)(VZAxWhC8A25EoxL)UhuVjK2C7eQdkVoXos4it6SfNGQSpymFmY8NhKNhrEGeKAi5mo7Ay7WbmUfBbwmYIJiem5fjldxrnUuxs(yCsh3Sh0dwaqOeq2g0tz4nwMXVbHUy)nh1LCmyf7dYCQP5iQ8YLRvRCPkxGl5Spm4SjxtKW8Vz4uwYNcOktrlYLpwotsaKvFX3RL1T6tlE5wpsVBQWRgDFF41ha7PLVnBEqyeNY)MEVGQb0N9iPZHVGEooF64WSXBcIdx4)qAizffAxSU0DKQr5nEDqM)UmIpdNkwZ6hAZumTXui9LeV57cfRRcIpe7xNP4dwx318KCQkiIUNqJDNAG7p(dQ8b14GUGLlOuQDdnmQNauBTrQic0yBczNU9yaGBL8Y0(EuDBDbtONJ(USOKCjuvtG7qKdD8tFJOiDj9acu0V892p7FJv6isvCIYdV(gX3eE6I9uaLmqjuuSkAjFD6kREN2QWSXumgpqo3MQoAVp5zAFcrbt7XC04C90LAdiYHoLPFJOi))eoxpOe9i7lY3vKGAUmg)d9XBk(M5tnXt9bl4jT1bSPsCOBHtjh2I2uhR6r2h3p7dPHjPCVYo966VVLNP3XhltPIEN416HXHvrYDOgreUTa00wpOKJb7x(qMChR5eqtaUbYRAscEJ8B0iRQkd05kc0eo7wgugbxSO9sQvWpTvaMkptjHjhi1ZhmXYyMx6ssPb6wH3urtTmTmNveg(qMzg3RjpBQTcpvi)fDkB08fZxxkBqrDd5YXy6WTkvmWndZP2qokYtJseUiMGCOS(qtAUEbAv9GAsU9bK9m0SCBfloiUX6rXl9ZiRG8Mr1ncwG6)59Z(fwO60nTyQC97PbRVF27ky8LoqmErew4JwuiRtiZ(PFCWgclxtRQtZKwpqmK(bPT9DBOQbLhcRE1Z3r07)XjWol22Fx25BOCJhaVi)QQbuhsTRZvTtBaw)RRQ5PYoV951(7IuDusTXCZETlN2ejVGHCNYy2xlOiTjvCV0Ru31ic)S1KktxKnZjPzj7IkJntDSphshu68GuQxzZPYZG5lZ(50dBoz0Sw5ZaBsBN0cOP8mamQ2kICvU0kCuRwyuCP9c7bSWNHYfGFn5BZmDv12SnhmSOcOyyHnJMFmYsOtDLa1k1caMVe1ReckIFRynkCFQHqITtdG6Nm2B4)ZQOlGDm4e9xugnQhmbm1o5OQirGTwLayNdTxQSUaY(7QDuJhPKfRzQDkZNUCelTFhOSeP4clUBxJmLiATdqEtDQius09P6p4T6HgJmyaACNOFPBWSz2orzU6ovj2Rcbw1JSU(H5j7KFyLSR5YCgI)9cCus1fqzkRr(vdujearI9BEZpjj4P8s72SrDn2l5EkelrTYz9sBcXmX7mPH8SEw(BBCLtns77KUIsorih1otMjDGw(ZHsJ7aqjpxYgaQUOZ2x8nX2khTR)2bPn)f6CxSwnGL4E7yMTLs3bJcQlewfstbP32YcN8lA6lAjlFhEMnaPVwcnkVBllmG2)lvXhRjGx762KfMHrZXe36aB7zjjiFTtrPINCNQj9XG0nbACxLsMEBbZSvuzSdrqNnZRCoVmq7LVfdaqXA9jJXTD4BfEz0rsG3e5KsKKSuKKyOmW8TbaNkf)llYks6Jub)2j5HF3)Y8)0ULpWoca7tVZrfzMiNv(ucNIdMOOVnWNm3a7uJOs4br(mtwCGuJfjuJGmqxAhm4bEGYPSdU5(IczA1Hxdt)Y7)r5ln6hLV0pkFPVRlwhDVJfr0lf7H7SiMfA)rfAniB6hPTQVNRqRxe7tFpjC(JIqRN20poBv13OBJhQ5V8zYID5S1I8ej9luWJ7(dfI4iiBNiKUsbpfegXriP4F3s5n9xZynlICfWnSKT8B1x9Bvszy)w0oICMbSIKWOhwTpwF1iUTbHJdefziQo2saxPSc4T5SCUUSkRQGCdx8Db)k01HSM3RXX9iklIgyw(w)0ShHCMAaXn8t9b)dhoeKpF5CDofSnr8)v4N)qXFSzOuLNzMsDSP7epSYZzubZBkdlPPzs1VF47cJOS0VJLvUG8cPUmAik0Fpz1EETIeKRlxNs2ylZNL0jRDTuRP3i(msPyMkPxLGUCwvt2YUrIqMeuWU)zgPoisk)mnOsT5TLPezblSy48gQfKAwrf4H)JoBslpomQSKnVWqa5yUCMA2wCDQ9zuaYvZbRjnKeR2eqSSHsnTP4IOSyd)d6k9pkM)9ZUJbKuf)uwWTrbFHQOA)m2rTlpM)dbqaM23sSw9KIa4oOs40FqwLWMXsTm0foMjgittGuzuYYAJsQr2ND5k1y69o4m9P6LnylAvkvrrlRFAu9v(LveasUeAU0hVgQNbvQrO9x()t5hfWFQy65TvZI3jR84wgvvgloyLwRYebD(0gZB7ZwDuJh3(0v5oaYv8DB13fAJBYNjLcdv)0ewllr5M8C3cu0NihMbhUmDChO80MmKEwdrPp(b6QLSFwCc1UXZm(Hsgi9NCWbYJ(doYFWrQHJKz9GZrMqdSyrW2TCZiCFDyrv8XK8Ff8SHQm(w1EdamCWNMFM9ubRFkH6lBltya29vnedxUbngtdJiGCT4o2wyub6L8aFjLcq6eJw)bp7lacwbYPTevpepWkkIw9h0vV58fF1ets9rxHraQVr2L3ciNjcGkaf6lef4sZoFs5de6MA03ZRcarOElmE1USWIAb6S6O(rF)rAFDiEkEtZhY51GecdSnCMEFNJ(xZrFx5XQOrvei8OkajqW7cDgmyF5nS5udnaf3CyqXfCsrRw0Q7aX5haqCUaiW)(SAlq4DaaHNaiWp4rBbIPhaqi4mB1uwu0)93f5c8au)zuFszdKSGhvtVtPFyhlxVcUrClo9dJx5YvW3Hx)09dlMu74mhOLPOpS4UVCf8sk9Hv87vIeeLd0lwTALxrFy(60DICwVnLuKXlGSwRnFLLzom7lXlQDmOkj43P8XBjniSQEZi)RDHB3swooMeXo3a6mN53QbGlmivnwD3pHQbTjmnnjLxmEPuqExkH6nFYMe6F95SgJf8AmuLh2Pv5v31nf8sdOm9Gf(Lwp1QTbuTTajTEud5hFErUCLFYZS7rUcuNRQI9W)wt5DiFQPQ6JQ2KLj3gF12kaQPeBUmr3CLKBUwcp8o4LLH(FZ((7JdYX8JzfhC7yNtKpkEtauPAC5)z77LP2FBnv92yyABL23XVmcnTPcAAYNyN4CV0brDUHj2mk2VHFjkGXOH4l0GlWmAxp1575FV0YDhYVhp9Vkd71nGMqxtD73U9D)W5VUOwWvHGyFxPJ3HnSbSNp2cV6DG35(L7b8Pnb9Z6S9lMjxnm3GG7qpgir79V52gFSan1bxShfMAPhFICgvIiG32NMXZDq6SHHc0oTlS3ULQpWjeDGODnwRHjxkAunXCqLux8yuvJPGRPKjc3i6J3xovn1YkczClHgBilqZTblcZtQ(CqYoqhXn1sC(DvY(8ZoG(uIOCTkks9xzFzf16DRsXQzisurjY1px7RG(1n5XbpHnnfY2LfhPUDDJl0Ga1eEdmxwpDQKWC8AUts2Fks3Q0jAudqxZDkY(fO6bSmJ4tEIT)fSKQukuu8CLf8ORhIfsoaUYCoa0Cv2HXlm6Jqx()h7DTTBBCde9BXpel7c0aTsUoTfk(diiV1(Cd26Q4AaxlxjBNuab)T39MwTKCodhU8I31yFvl1mKZDoCiNEAfdUYaX5cJ)ocU5R3FGwxk(LdxxPFSsF6hmN9h(NWRwKHQoNffTBrk293cTsRHR6hxkfODF9xAFMySJIRKIIv6O4cGAWQwfikR2RuEyAGSTmYx2GI)m4z4M5U2AtfjF71LYHfIaf2OF84wLu3Eq7UkU7)QiKR3(qXOBKEvuwZusozxZSDh2JkjAEQntXeEIsOezhsFPfVJd4UmLOyuqMWXjXUElCL5gzDXpuaY8TB3Ct3KTyjVgWyv6oDLExby7etDk)gptYYXMwULLF4q5Y2Iigw)gwskWWj)TWM5R19ntBgghaMvTcC(mjs5QcCzsUQew6Q6xwQAZesohecp4OAK6Cu6OydQt4SoR7s02j3SKBpcwQKd)tJodR1s9B4zNgIocx(age6C6JkevteyPCm4ZiLn3dUOPZnjvIvXG6PgxJfxp2wquBx1CcDr3je3tlmtD1bTjylPpuj4Zyv6At9YsDKjsqBHyRzxPeBRj9L5LGW9USfw3v4uDjokbjErhaTg7dElLNczB1PL9x)A7ghSifeZEMDTwIO36xbVLBW2U0YU2jeLc300aRSLGoDEr367OQYk9Vcp(8tQ3wiHriKrTJQqlyqMQ0QhXAkbelrH21xOC9VP69WldDc81d3vr5S2mxUs2iHfFbklz3oMv)pqpbue5l8EuKhgtiI7gZQ2ucc8vbtAV)5mwa9buHqcpHqUDX2acnXzwjIKN4AF01auoHXF1SXx5gpHfVsWR2cVKKP2)vmzJCpHSY4JuwiCL3erN3oTI9z5wjpRyBXvQqkBQ02PcubchcE9yjGaW0F4vdqy2LdCfVcMaatuebXGuHsGuOQmiRl2WvzodHQObxJpbM5rI9Qnx(CHx1smwqOwCX8SY3K2VLVTe17(JF73lFHvU9FEyt5tSYxlVhYZ6CPYMvErI)3Nk2Wzb1y3MYYKj)PIDEMx9ajD9FNF)nR39(x(0NV9(Ip9t)A51Q9(c8v95zMXHpR(Yjt8Lde9IrCw23pVfMxgbyMnNgO1mINlifR)Ugu7(jiyJXCDrgnqjciwd4mHmBGKpaM5q5E9fIvLPJO8LpXjZTBaiZ9ZraM)seG5IfV2STo36C3yBlPN5koF1MSKVsd6KKl0HBZJHht)7PfnQpQLOXkhDMxInAuroorOHP5azGk(XkhDcwv4XjcnVn5vMn7jcmqmKicCRG9TP8Lz3VIad9Lt0pGBlChVTlcCP9xLZPY4dQERrVU8HPrd6eJyaIdMsssdxcEAKMX7Z7yn7nleU88kcaam74twjIqTQusi0IXmmgW05vnl711n)eJfQHrMaatqaZbD)eaRybfhzPyHGIWMQAX1XcvbL7iA82SpC(7QQsd4scnhj9eyAocnUsAyTIKVzTBMramScVuFPkBpAtR2F3rBLEzcb4eoOsbG9lhuCKbSVsM0rn0qoMx3K4aqINz1cAcjOZ946XGufTTv45MckGk7LcvQKdbMVdoEaCZaIh(Ki2SvRDbHZgP9wam33nPe693Hw0PKscIrjcfQDHcdyB8zHavY8gnkrOiJFEB8zjUdJkpgN0gpwiSzZsPZHql1Ope5a3k3vKujFY)mBAj0yHEG828cb1hd0aq9zbEyO(SOiQuFRAr(RVPHZnpSU(it3v)o6p7eat(0toJHlTFppjw)7eeNZp9mxUeDxvFsXT9tN39USfZ3Vx7xx9XlNFQz31z)(tKtbpF)(YhIGtvQb)vlNFGxmAPyjNGHdbkeEDXa1QzhYHih4wn7iYLolkKy2HzGkiY48Sdb1hd0aq9zbEyO(SOiQuFR6v(B0)dIn6VaAcZKl1Xefjjw)7rWew6THzy0FKrXsobRvimTNofjone89IugnA5H1TxZUOn5SMGHlgahoeqyZZ09bY7Q3NerSQ5UyCezzOYHZhGMM8OIkDTKvryDBodUPJGkMnFi6GTFwD)nV9MI5zHPdnOQ8nHrBeiH5XeutXzafLcQnlkvIzkoy0LOJEizk3hBddUPAJkyJqsDIHJGyuCXa1XGslqY4bfjPXHgajLHVT7l)z(JpE36BwNRhhT(NfkF3Pnl4Ma(yPIXZIrGOzPWxa60TtNXVIaCV(U15p7yynP4O)JbxnfE0sHGtwkyaiKehZu1Dwq3edNUWfhrLpLoU8v14PG4FBYR63DIiQa3kyFBkF1V7erubElyt8fUWB4IYJMhagek8xNkJkjOWRJuCQmQKZJNkJQxZYOcKELuYXnoAlapEWxvkUDWvuJR6vPG82oCaNzZD6iVSDyWJvs9iIs)E4oVdHHUPkwuOHUPkwmGQFUP)fcTOgEXOLILCcgENqnlvVcWDQIffA2bSp0OA25sPXxnYkam3uIED96ZRon4j1JikDRy)uXbpvCWtfhCp1ImIVAKrXsobdLG1MAPzMt5wfunerv5juVtcSQ)9eAOdqUFqduXfT9CHYgW2M71HQ(ND9mIJkZdE639JcbbxZJmUo4A(5EaUh38ef4Q(zxbNhNnsSb8RHcncP9vMabUEktGbxVKjI1tRt8am4WvuB9liJq1DFU(cApTWboKG(kyHkbjxbhP)3h2UU8HZj3rpWGLOxmh(ArSSLa52CmgLTAkkvl0diOYJrUg4P7Qh6qEb4uZtx1dEOv67gNmuEVTEvnCxilgxxdgLRb411ioxaRXeutrzMJQUyVe0G2d8cOPO0(xIQ1xNSK9)S3XAVTnYXFlchaHuJJRiPOVgajc00MG2Gw0aK0Vwzzj6y1iBjqkfF5GG)T3D2Lp2hZ(IpIDpCFjXGA5UZoVNH7otx0KvDjqEjChih2YgMLGu6Nf5Pp83POxyQJIyDggO9oSJSTbK3)5thY3F72D1nqWIlRDD5vl(JvPT4IhwDF2IIV)W66kY(fLuQftV4BR2DkBr4fBVDr(QTBcgdKTdhY2C5dz7GmSaZ7Y1eBu0Enb0cTb7QNpxpo8dAi3aUFBE((Cye3Mta0teMcYCD)EYtFSGBCQhJWjp9bSDwXP7jSM8b0q8FA1Xtz4dVPhPd7scl(81LD9F0Hx3ftHrpIZysJJA6FXhx9TmGY9tpD97(LS1NOeVmcdY3jmaBb5GJGCd51bjMTfK)8BR2UdOtxwpRlkoKTkNaXpSPQ)Ru9tk016CsDX(dlkYowsqDi)uNp7u6YQARiPITHvZa0XdlZl(QeizVTJnpmO58yI3(sjdzSup3zk0ZDyPURPXjnpzIDy8Mn30jyumQTMbicklcP8dFCpv8LdOoqFcWMXw0kN0oD48z9F9JthcoKXUHakel2cJMWXfXtPGXBpTDhHN8Van03vhl5hjIpGA893Y6CmKNZbMuH)YeJc6Ey4W9hGUama8aF98zbGGvsWilWwWijxsPa1)UGaeFMLHxImX4p9U3pXoiWFsuVaeuwFKPjtDnSpvsfiqH5ddK)irZyoX3YFLa5FOu7Wtx)jQ6HR3sqKh2T67eo4NUg0RXpM)glwzEGsu9Yfc9RhgiW3qFcKvkvg9DG9M568Wg8nH7N8pzeB3ahqjhp77EuiWaiWMdaJm)DGdYnbJTY1wlxzkV9tOBGp)rMb1h2tyBFe8sPURuZb4mBdqBEcdLoswQlGndPjLF8rBn3P5XbcKLsZkVM8)Plgh9k6KCy)Ju7tWikilYKGXoOCwrm585X1VxfwoG7b0uDn58zqymn58zli7jtcgj(DnyQSdglsBtdB(whcSbKvc5PkA(SORSHycsmuIjuJ)xV6WbQOdvlfyP8Z7p(p7cL93PN)aPNuTlus3Bb)OysQ5zeZSQQk51mZ74fQFxnRUuIZQ1XiqYunet0XWpGiPbqEYKafx(URsFD9wRekkSBxHDH86OXjUEPKvZsnD67sduom)YP7ryrueLgpM(OB2TF)gy00NrFeJ)xOrTw6idtOz7d3Ec63CGuZKYFb5Dc08kYeRzESZ()NT1CF2wecM5DvhqzZSGWKKT8zQJ9BQJ9yQJ8BQJ8yQTXbjRSHkp(xzrA7J4ixhcqyb9Nw2KqgdtKluUMwFIPjYb6utDcX0e5avPPx7yAIc5Ni7Pnq7QvLJ(Yq7j4(R)mZHJMubWr2GftThEI5PIAV8mTkGBrFrOCBknF1an9y4GrLkZ01uBhoOUY82Dv9FcTWidefCJWaKDeR3(JdCY5iu3C(iwfLhrs7pnGOluKGiPxxFKwdqb7yQhUqZwxgC09sszBbBxGdPmJAeN7ObBEy)wk)vawkA0T2cTeyTRSnN3xehOp5QTEP1pLiINElU5kd4IeT0Ttfaszj9JDbsfnH)O8tgaexj)DJq7WQ0Ztxj5dfp3emb6pxNXK4MbkiAvFqcJl12cab7x3T)ry6UFpq)pDVbeVsUPjbTmEKTKGsIHREi4kgRdiJgXdjqNrM3edOgoXqQncfZtycsqKGSCXWKTtdNQdafcAu1dEAsjD6DzPVKTQZt0UE9nczSnMlkbmLexQzZO8B6NpJ)dXwdluQwUd7n19yQPQakzlKI6YNhMu7Ie)hs)LmipK()0goMzA5yAnw0rxm6M3PTg6CLgpYt0IScqtPola(8WlZ(gaiR2SPGixMcNyEXeQvgGKP4JMbFRuZ5VvolSZJSXAmpK7Zhy2K48WjUMoynaFFZ2p0X2XaANyrDnak6u6zKg03XbN2gGanOlDVjM1o8F3zA6ZyfPWeQJVTNWPXAIgkNfD9iETXGJUgXJB8coPHWZyoDfp6bp9l34h6lMEpcFGejM7Hp4gBGvxO0mXTlSe1x1AujdcAEa8dZn0TJsDDYe3lnCyBXv8RwPBxXgC7kUJUDP98yX541ZQRzXdbvuJRzE7cwS78N4UGjR8jC5mmLpDFD87s0craiEoZsqyOJDIH2jkVNMCDBLhkh)IBHxYXo6KGx(A5MLR(scYUFQTFB7LpMTFz8aH9Y1fm3y(DtSlQt6AgkydoJg6fE5S7OHkKgQtBLJHgf3EN9uFvRo71pinTor1xY)E4Y(CTUSRdJ5GWRfpVOhv50F47FnSGwqquyDwW4A2CKJeEa6j6JO3yS0jeBsRTn7bjvhDRRXT3ca1GDD3tvAFXvmw2960Kadevq5L04Nfitpl97pYGF)r)w3V)Ox2gHJCIT1PDVN((g5U95ofZr3xNHiMJOEsSThchufpI6nPBCkdvSkrwJvHQW2nhJTpzAEhzR7Ws2kjohCtWJTIdZgfFd)idcvpcivNzy5GuoF2(LNjnbXDOxqC4AaU25ySBYbUPXejSfpMEjAfVlzrbKF8BYgwCbpy1lFp0N2PD3p64QI8iUQ(zBOnshxfQhzuBRLOmkFxWwgFRCQTB2EnQIX45r58zu3I3Vz7TevKZdVuRL2o7EFFPnZEYNW)OfL7X0frx(ZTJHPpiSAMdP7hQYlrJciSkka1jP436bbu8skiaRsNAGFn68Ru0rl(czz5WmUkpF)xaR0aZnIh1sbkg0vhSRVEG8lId(TeoT01bDaFBN44eKBsoowT76uCXdjmF893TPI(Yj4cvpWRviR(9bSJWNNKem2(9lpnItEh)sAIybPaxhNdqvOl35DD6lqWZ9Sl6fQga6rFlnm720HI5uKHPtFOT2u15ISJBKNEdGnzTvvSrZy0E1n0iIPzAAxesDHWh5GWEkIVmQGR1azSyuZb4iw1s0ZRwE58FOjvoTJa5G4KwktpS)hgpN1lTOtSVRrsGJ8rCy(TL7vYFr2SWDN)i)8DZMBwwapspxSBP3eMqUBZvm(sCJCvwr35)fmrWDPDfMe)8XNVsiWKfXl4qAayFcSP2Bn87IL9phd)k7qK7kF8Kf1FTflmJDzHKO0e0Q51KvYgaK(fpD97a0(txtW7pD97PLid1cnXLSckXRCPKiH8sAVc0WoXsjgbz6membvOvTY5lwuQsJQjkcC)nQbVbTcBrOLs11e4w6be5y56ag5rSFjcVo8hL4)(crjkzJiUZcJMcfgMYMwGHEJCG4GulcEndWqF9vAqQZc8XGTdmnTzbnaZeEWTXyvvK0JDauBwdnG6e(nJ8AmXFYLib)QP1XXykWIih95FcxYaQlgev((kZJIjrIOXLZmIOyXy0gjHnPLzLwmk)aeQ58tNYxf1zX2wkIcVsHnFk3xUKtcUu0GyI62teLH5zRVdKmxccMy8jkwy1KfuJ2cn8J1bLgQ7CrdNjdDRjkPvsPYuTxkigjgxhh0NKAoajsvz)6eWixV8NySQUDsP2YSyMn3dHDVTYdORSIZWiW42eRnO34iPc2VvwHIcglsFaDlMzuzCOfPtfslQXECvVlkbSdQwMbItFVqXt6F8rS5AJ5Kjymg60YI5qaiS4eqdk78bD4TkmBNDUfVPuBBZanxkdweg5bYb9uL5aZOKoRKaF34Z9bTcLCUFQQ4iZTRO6Yau2MSvhVd9J7rP(shymQND3LTA3X7MZ(V(C(hJ464vtRD1qatVS8HGfAz95y842bi8uFPobFDv(9RWMark7BMATSeIPOb3e1v2bifaim5nylaMLFiPA1zb3h2lAkOCCtenfBPjE9ML)vIm5qU0HyHXqlxcfl)VN28fi7NiJaeaP4Mbf2WqlqM1iCIR2rRT4d5YJtvw9fAGj5e)lkQZnhQ(jaMQIuVU4kQlYC2VBi8CPYmSUx3yG6J8bvPeq8mpTINmvF9Kgh49p85WRKlFP0Kf0kVYcRIZHlr6YAqvI63vyhtbE4vKqOk11VhpsW5KaI(98d8CKFaxjS4mLVytDGRBlgFjQCKgXq9GKfbpzxlRbrLWUP4g0QQQMOZQxztkQSw655dXqAVrCLqtx6ujcC3mX1OiV8pH9DTgoHMXHPQmlIoXQ443aIaGN(0(O6AOSzldR89hzhg(0eO816qXSwXFuTAt539J8F77LDkbysokeVoH5Vcc6w2xxS4mQ3N299U9bB0TfzOI4WdOs8ZaXumYv2ChlGhUC9PCYVDSeFuAl)UTB2qOx3t)qPflVDF(nSNWYy1PQs1SLXXPH2JHNQIcHcZE7WROkpSJC1eb0B8vDKyGqY0c38FUzYecTPJtM5GvQhMqelDCjvJbPJtOMOkCy(OHx8(6QmC10xv3HHakYxT(R7Q)63u01d8OEMtuhYY3NdnSPdRwVLeot11P8nLhuJAg27x9lPzSwuenPlV2EV3ry8LIqMx1z85)t2N4e5tPik2H)ehZHoSDIyrEfwyu()TX125hqxfLdHQ(IQwAeoLU3RkBQFxATlmRbw55(c9f874bidHjOZzpCkxupLpRLV7XXtFDYFqeGm8vFaMB7hv60iBxyGi7xRcxQfTafj2(uLABQk)I6Ze4LirxJOhzEuvBpqbvgk5a98FgLUUkFnqpjOxW2VJmy3U770Dww(bYlvEqFEGyjp)0HJAENgDaL6C)x02yvZyzT1ktzGbzSIYgLA1QfJR(GAIAvIrMhThbwtNU1ilFNUobVOGzLEcj6eVwfKLsZeXRPlnu6ujPK3T)8(3901)Jt8LKWkRhvDVK2IhdnoL6pgJyxswKJKV5zFi0R52zu3iCz9(GwUpf61UncHlR8nrwVGqYd)bGpAZf0vZ5HuYq1SHEFGcA(S56gbwxW54WLC3MQSEEt8X(HIBjAqbzhQBuLMhsuYo9vQ5RgTEjBBINGBkOnOa078Cjw3DmJUlCN0UL(9(nU3wa3PgemIYuv7FT74TfqkJKHOzQpkcfcChN7NVHApFs6VDM94QZqy2ow9XwhNJ2z6UgdxSe0fDg9aiAxPMff20liJaD06DlPnmcDfoF(XJDHqBf9iQwy(vsxwaF92WHtBnlqCpRVDTBP8Eo70DeG5M0kP2S9LoD38s18YL)SshiWSVxTY55ObdZ0nB36mslAPIpN72wLLRbC7o5fBOL0DqPEVil))AVRMDBCJyWpl7HnibBrqKCClkW6CPO9Cbsphx1TojgiUUi2ElWEOp7v)6ynMCMpYHASsAqpveVZW)5hjLeX8LbCgmMLd((Hqqd(B4xGNUvpDN6WMtrfBr7lWKg1gpeiYNEBQwKQ2HnLgaEVlYN6XXJocMp8BW2fBKfIzqiO7)8j40vfMgQetcbkJd7SmACCBp3xUZlNka8tx2rqykAu2ykKiRDWoPkqoMq4jPrK6ejIcSGOapWif0R045qCMbaKz)z17KdEs1RMdH88IeXP1fz1d8JVVOM0Fam6E8t6zin6TIj4Cay4tNkmyIA4R4MkbAjZaj25Ayti5URVLq5zQydPCbr3kgZmwGwEZPviRIsqjuevHWzwNojLUaiPJ(c5rrRrLjtfLujDSoCvW2YgOfBKAm9jsSFuXdKld9dlUXYsik8TUfxg5WyTxyf)GyhaAkuidZhgkcshRhKSnYTbQ)6icewOFVpEXkSS9TnOhr7)FLuml232NsRAmyLME1pd81x3M2XM)JxX3mCbO4ExDyN6GrvicmJDtqx8ndbFjYoGzw4EKu3Ad4Ba5foBuGm7ro1CeLFS04Rm5hl5c07V6llMzzJDnIoVy6)6yyg2AR1Gz(1XaudBeZGzvhef2q6RbekvFqghJb1ZQEayvrZPUF7birsz(qQ)Krd)erpz8WPHn3tL2M9Eq7ruI1hq0EYAyLtFK82gPRnDq0wTWNBCnBp10mgAFl6Ak4xW9)YkzcqG)qyOLmFHRLmDb66s1uewkLw0dwvmmA5BvCmx5ilEdJSIf6(aQcdtAHm3jAzah9cG3NPScYVMBCxJAqVEAEm)7QHNxWJd)i(eyu2rkFarnIElsoUXGrOWunq1xmKfeAkgbQQ)IZpaO4p4mxdHQzanfrsPP0yeWVJ27wDEhnfwoics86kXympLMfOkbb2EPs4O0CcTkTgBVOlsdtXGi9pvLOnXxjAtuh(LYobBBFhoTNylJjHfWcAkd3fyThaxPdkFo8algDcEOGrbcH4PxaQAkvJ3WmNnWYvnIf6vBe(i3R)5qt0Ken0XeVG64XV704nMe3UerZkizQ5mIvJRc3KpaJ4BI1qiJ7arHtIElsoovPPPQsk6iQPY822eK2y6krJzT8ijmieoZzS2vbVm9fXiWUnrAeURbTiLj2uKcMGhHWpvfPK7RifMTPns0pVFMTe9R4ORHSQd5RICmfqKD)3QT(osS(qOViEPVabKHSD45bca(5c387fn)d6Ti54Wc9okkAmE6fGQ4vVk8zLKvFm5akXBtDDUaDM)4laVZ8rBT8gshznjBjTjZTssOnzNCOKN8qKrVmVFVyN67n6gJ2YGGEGcJfLRcFJNk8NzD4pjim9Fpn0cS0QxbWMRU9uT(rD6AsVj3xFYOXat8wGQZDmomV((qxqdGqIaZfOwyVLimknH7slCo50havqcFJ11J0OtEQ466vCu3O5abCf4FsEKrssKmcdkzMuuvvFYFPYHeF6PfRLOHeD89(VhpWrU9HWhhKD2pYeJzzL8OtaHI0fquuOao4VHpjjAdSOKCNikEtcqgMdn83(3F)xFE56NRHhE(NF5PO4WpKtBNxA8v81fZcgrb62lXOa9UD2DTwPeo88eKKL(eaA6u1)SdEPxYAOWQFDtKGNw)pvhXQ1voI7wD5(36wFd47asWiTrUCTbP0J(3YfU1s(y3FVF1Zb8(8KbSbsYOm)5CDj015deN26)O2K8CxBYxwQEesUqB57BUUZ0P6jAyZ8)Oy72Nw8WIINvY(98NDfPNfsRfGA5FF(jN066)C59LzuQQJKXyq4eToIHefQJK07NN3DdhK5NZUzw(L)ahR53usGZHjIodmN6s49Z)szkUJ2WXBwC)(9EC5jxViklnF(ArzGTQtk467ey1u22NcQ90eZ2xR)hqMEu4QI)A5xM)WZlxCF5b2ed68QJGC7)L9PVugaPDZ93Fz66EqhUaBFSyZ8DBwmVIWDw9T8)ZY69p7cwoO4PsQ8XIsSn7(23k1CLrEQzcle1DFvlKiSZNYsQvmt5zV672806TZA)dnyWjz6Z(qFzCpZjN9uSRG05ptiLU4mrBm0B6(XF8Jz1RFT2)3pp77V6mQ9uEVFaVyCFQYRWujsTW5f6mMAVUL6jteMFODBoNem3JeKmaGZF(eibhZ2T59SBFlj1Jse6mEcQ8YT1cp2toFmz(Qmd9XSX4on9X07ylxDdd6mCkUD1EiBQ3ZjIhBrSC8eMyC4nsEpbKA54MMsjpTSWD3wSBBPI5UBVD5QF6UTL)3D)h]] )