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


spec:RegisterGear( "tier29", 200360, 200362, 200363, 200364, 200365, 217188, 217190, 217186, 217187, 217189 )
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
            return weapons_of_order( level < 17 and 3 or 1 )
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

            if level > 22 then
                reduceCooldown( "rising_sun_kick", buff.weapons_of_order.up and 2 or 1 )
                reduceCooldown( "fists_of_fury", buff.weapons_of_order.up and 2 or 1 )
            end

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

            if state.spec.brewmaster then
                applyDebuff( "target", "breath_of_fire" )
                active_dot.breath_of_fire = active_enemies
            end

            if state.spec.mistweaver then
                if talent.ancient_concordance.enabled then applyBuff( "ancient_concordance" ) end
                if talent.ancient_teachings.enabled then applyBuff( "ancient_teachings" ) end
                if talent.awakened_jadefire.enabled then applyBuff( "awakened_jadefire" ) end
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
    nameplateRange = 10,
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


spec:RegisterPack( "Windwalker", 20240515, [[Hekili:S3ZAZTnos(BXF4uzx7Afjz7mt212vTtMj3D7DZUtnoBDFZuusqwmwIuljLD8wP0V9RbaFas2nEqrQ4CxQPkhpMGaD3OFJMnUF89F8(7w4NYU)Vnz0KlhD14Rgo6TxmAYv3Fx6lBz3F3w)5p6)a8lH(BGF()eeU4z)1pYI5p6L1r(l4trs0U45WJxLMUn5p9M38qq6QDZgopAZBsc2SBTFAqu48y)LP8))5Vz26OzVzrS)drHlxh8WQ03SnoAzWAwYB(Ty2V7hSa(LF37xJcF0RCjhYF37VB2UG1P)NH3pdb0N8UlhdGZw2C4p)23bquWIfm5yzjWlZh75JU68Xx9N2p9FKW2p9N)KF8UDH7N(ma07NYGFYI3pDJ)NIG)59)8W9)19)v5RD55JhbV2VgeYF024GO4G0x2pD3woGSF6Y4On7NcqPY7m58rxaVZDSywOyWjVeoF)0OW1WV7VD76awY(PPr7NgZrBL3C85JFBoqgYEggK)Awyk8)aBf1gihS(D2IDZHXUo4r26GvrrlGLzjaDjbHpSF6h)T9txSlw875qtLjz0vy42Y1rWs7V4t7ss3alF(RCX5JNC(KFS8va0oNsuDm8P9UYhMO8uaYVy)0b7NozYFE)uyWJVq3Gh9dWt)WUy5o04rdNqmo(s(B(PZxjhv5dh9JYj53z)ZDbXaX6UhFjM5pF1BGFjnAh)nwYXMu)4hyaTE(lZxdKSQZWejq((IvhyxIss57OXmofXp(rjThGuGhk2pe(h)WfLRNUv4hYwH0yyNuzE4scRJIxKVDWGFliKt5dFyn7C5eQmpV98jxcZJCRV8ve4xyu45nWDL39k5EBXUBdYmFeYz)U3)F9hbk6D8FkWXpe9boxhO2Ojdbx07huNyajdFKL(hljn5tZDFuLpmM9uqcOfPkiiiuGmsUayKKVySYGUmFb)iSnKSwmoX8hZc2SDnBJqM6dbjPjsAnWG9sg8)M5(HZzRL6VOfFKRYvvbfHUG7k0(9EU2pLx4cPGX(P)fXgdaEsUpoe8Zm)u1ndqiASySCgxGmWKkmyHj748WnG9GKCfmZIJEKX1TTI)ZsLq8r4ppn4jw1LzKCRrQ7B(k)WhY1o5d6PlusYPICyUg6vUFvbrhj5KYb9F1pma0a(VhhWwMgfZrAbX(pZzsxWe7mcPt5ot6k)0sPfoGZ(mOFxWkZbS1asa)mca1yXOdZexM7ZbX0GnzKR4m9JXbjzsNB9Jtd8xlh6W7VBnNqYTNfTLfcM4(49)nHfswO)S1Sf3)tsRiXbB5O89393Ld7ooLK))NSBZMOqVNxfKY8sdaaYlj1pDh7(uWCuTzcMMuwCGpyPvOxF48vbEZ2fdqs2OeAgH)6Wn(FE)0Zf)((P3EZ(PxuUMCIXAVv(XB4lYfKlYc2SDlxoCPpZdELioNJ3c)naDFiqP9dcbc71GIyXIEcWRlhFsMqj8sR8b(uynhUBB5Y)j)fSLWEfGOrB2YbHlBnEUFQou7kY5TbjcMMjLtdF9E2)jXMWB5tcY8RmXWO(bDlfSda6yO3BQTYcm9E()DxsM4N3fPySweK0QSCLIWGHZpkeksAX28ymoYCay2AWPVODPEpgm)r1jpHL6nlkCxYW0aw8fJ9MSDUKqeTzweaVsdwWFqaefZdOPneunpxirlyF4g9arKm4)VngJ3nhCKcsB9xVrfwmXI2aUWx06CRfIYBdcdbL9EZ5gVBqjYS1YvU4Lg5TiGjyladezMkijkl4wu8Iw6bmhFkihqrwojNLuyup5uodi7n4OCDbPcuwaPCqduF69CMZgicWGV9HlyXldQjclGY5(RxlijrBcc54AoaQz3QGZ8wYjjBi4y0B7lmYsy(QRWHR66rmkG1jYr)iXQYXUeoXyj4KaYRExqiagX72cQQgRcvcGii8jWvI4eVfmreB5BRNqX6vmBEblbXvSb9LVivwbWdhU(8owi3G58htgk(NBF3ioc9UJOm6XuqC8OxjiwlXkXd2coMpScdT4pNBRxSypffNY(CUKfbXGYCO9cl57paiLim8TnkqJCYyk7FGdICcvYUWgRPtZpLbnNNFSDGrA4ROmQPzHDy2PDeZsNpMOZ9XX9HYCcmHs)CFi)1xg)jqnkJa2ln5ahXXubDljitO01ApbrSSPC)aaukjNrec4dcEKf)I0KvEWhOWGZQ4Y4Otw5Vi65zrFMtltbxrwKun2jJU5oHsxhPuf2KqPqRJ3Njw9lvJDdIXoMN2mpzwK92UlC(QAHXnHwtvoxu8Ue(UPhxpKa7ReCBJNkMvkfuwXjrGBuAIWJ9jxrhnVyd3YnZ3ETi2BeOtnY1KUiY1X5rU2gBh5kbm7AUUqC7aow5YNNjWkbxp8QwP7QyoW836skTV0P8PfHiJW3PnLohGsYlSA8vtAbHSM2SdziepCcTb1JiXCsjUt57L20mzRWGohPQ7bG1uKJsy8MjW1DQWA43siKh0UzOOrmAM49XDXZOxlLXsvJrHm6l9kZWIOYEN9kdVRLqTgjvYWU6aDY90wsLmNOzdXPOaTYDbN2doiW8yMiu7i96t5GPSzHfPAoov)DnMPRA5gtByQVQOxeegJwEmP88WvV3icv71onQQ6VMAyOnDGBBUXm0iArtsNnuXyu7SmyqNcNX4ji2hbeG6ri3Z9fE5o)IfsaHR)VpkAnekRklIGls()4Xpaw5XW6jR3OIapsLLjaQt9v84DE2kKjgltQSG5R8uzlzL)YxYphCpwiBJOwCa27lLpXT5I7tXi5lolkr6g)sUceVsF24(9osH3q3bgt7yFMYGOOfRbztH8V2vf8uuXzhfKrVZ9NMFS7nuxn(TYv8eLfTGyHgtee32zyWgFYMms8KtfZx2g9W0Xddsg6NSIvWHY2mdulhTBDUsXQJ9zrLBnZp(XeVzGSgVWcQnUjomNtOMtoIFQTakFWMbZZqWOc6zfM1tTfBQSWK4sZfEcYclhffVWLKSw6ckJKVcL)9TfSi2yGsYVXPa2mArSakKcnmYdAQTOQwYAea6GeP80OuUsiJhfYwaWlSFXEUmI9m4tV6ijYSfOYOJtIh10Z1eJ5Bkxzu9YfJOKTnPqKpefdXQ4R(qKFYh(h4ppKxpLfMIY5s0tElE3vaEl2SYFVmdPl4sdCZXRIId9Mh9eqWuTGIGO5y6jhYKmsYhEw9PsN9NIPK)kiKx1WCZnyRn9aNOqGAbX1zJM1Gze04wXY62e)hKmFugDEh)z4ugQtZquIKCnTl4LNNwFcpPE6bZeDlTOUI5VoD1W57IJfv5gStj)tzYl83ww7YEBeULL4bo8pt(xKfRz5CAZOruo60RDlUbGmwvc95VDuf1WveV9Y(Jw49Yy5MLvNHE5Uc(MUXLczd)r)4n(gsPsZ9BtUKPQ3J7lNmAuSmK0vRcSbZI5QKktmr(ZeYWjEFA3Ih4Xuwl0JgzhOJGiEglf4oA46D0IWdndKn9x7Xd1an49oALM5)GWtSyigVezyslyl93To17sThCsLJ5PrD5OrrJOQdlowevLKvYXr10Ox3OpAm61FfPIuNcDSsmGxwwUIiHW1Nzprtoa7HtEN8msXZeIvP1gFLOYyNfzgJkXyMQmfu)rfp5qRzfNpu1wC04LqRJ7P9yDIOZnF7QGlCq(hDn7suE9OHLqBukA4kmPJIhqMZw7pGt039spZs1GfNYPzMvc8TfLOM9YCnoAcfdnzLr)4C7kQXfxBXRMGItCWYsMZJf1SFUEx9miLuHQFGah1JWWcEyLd4M)HaW)urEOG14wPRMoDSf2FIroWdyWvOQzzuXJdLWkv)mh0D2cfVQyIK0d5Fye1KrvgB9XwQfEpj3vl4zLzk(m31otwXCDHgh8LKSa4CQcWO0u(QA)Ga2D(ZDXyDBP4FV(pPNEW)EsLWiE4)AlwGlEnglWRi)9X0HRPcWiT7DOGGZjD7wE8WuzI8ksrtNn4zjR3b7)13KrLyr8FuMv)6f)xpwc52fIfHHAkRMDByreloL5KUX7F6Sm(nP3)oxNv2ReHOE(Pd4WbxQC3BFtWT6znywBufZ)K7T3kT7tGcV11KnOjiHwg1HMQjY9OoEn5D(HR)Z5yxV2IyxjsqdzacAuzzcCKE1pO0hFkA4X0rsZImwqOhujUfPmRIyBAu8gpMFC6kp)WfE8dlPIxeLNpCvtnfJjtdRYuMFWgQdHkEjNvO6iJgXYsFuthqk(A8Pa5oYyJYu5MItPcG8ZjQd4ApfJXnJH7QkiLwwnPjcI55YkZtt(luSwjWz)iMUiNXPcAcH2g6IlHfEGhruL4EV9ODiyLQgGW08e4B1Gln(1GxZ5vCM3(i4x8vIwRaFnRv(M)OjVr0eZzhq8TlGdD7d40aknfweWhvSIF9c4Z5pqzh8XYs914aMZo)zEH0O0XXy(1CaynKdUPI7YKccAQPLdWGBBo5QoHVQnDDbhM9w0AfY4pq3aQXHK5Ue(qB6FUj)lloeQ8nsoOjh36ON5lWMio72Un0mCAB7wF7LLGE0BlhD)vjO0wCgHFBgaDFqLB1XenXWX2PQGUgL0cN((QhHFptt00lOAfPX56VOTMCXu0xfYX83PUL1RL1e)av3SLKkBA0rUFoKF1X2FKatos9dK2Zs3UtNVrkimUd5GVPelPZnLpxsLqNZz5Cso0wuin7HMJr5elEaVtz7XEId6(layL3eKvo6r0PKUTCoBXmpqub0oPlpe2UpyvmUOO3TnpO8FktaD)0FkM3bWVtaMiPoqXxwnkVligkFYwn(KBCRnCILxieIFPTd0unrzzWzbrmovR9)2vU6wufTePr7MA5JtlSIdmuY(UamyHqo5WGl1MhKFeJ7iLoXml7Gq)LOFz)0)B(CPGow20ugBq(bPSlujbOzSYGwcDzkRhmvQlBMw3JaAB1LxRVFIgAZn8Vb6g6jf5pi4byhgwOcAB)MQom9f6DHLKmws6TYTQBfAHDrsUdqxs42D6aoS32AsPD9Ews05uu6TsW2PajmzjypJlNUn6z(Llsrq3zFVRiZWBjFYL1S2GfpG9l)z3RjdPTMwEIfHe0gsnD4eeeRYpmZtnsqUroCliUelwfdRTDB5MYpLzm85s6hnXkyxSH7CMNDWVCvIGZPeNSkOShYCicjRgFvl64qTBNPOtksDXMBlvL2N9jl7TdyHXqIoanofHaxDUwd6kmGaE6XpLe7H82Y44CTouxV11clDyGK9(psMP9E)aGAXzD6WSt(fPCah5DjFA)22ffZeYMn5Pmq3iTSmylTDOs3)KuSGwIJjKPyU1otr5T096sXBhO(WslpeKbN1Z2AvdAKHiZVAFqECkJoKPHTJUdAqfaVH8ZDTrcDRS0IfUfhnpzZM(qttCd3FVP8GQlPbeOQZ6vXMKJ05oIV6xiuNLVK2ug0x0lLEXfoFatwGBULv4C1Z9q)i0qog13NnSm9Ix2BxTwDaJOuFZrRVJtQfN(JhVNsH6X0QXHeoNJ0XJz2n1GwKHLyeFXrlNplYxdPmWzlJ2hmxBOH94x)U9aUX9FvrB7ldIw0Vr0eE4j6)uiWbbY0A15bfONKlzCnKs4bMtIyjxwzjlDVUeH1oAT9o63MIa1HzVhptTou8Ga4D(Bh0IyFlzb638iqGsFLUyW6CP171LfPdz)HGU1JQ5DXdG2Yj3zAYXN)o4M7YEDkh1gCIBPMW5O6SmQDZb)rxNFUeB(X099wYklt)JlrW)AjdnwSjsPL51we8g(GaTme(B7(y479aC7r)zCXoG9HU(QsK2cFSpWcZX2RtgAhq6SsI671iKf(XPhD(EHR0nfUIHl6BHZwdW2fgC6jOu)V8LQGZTJhD2Gt1IN3mE0GtqGZgt1vdqg1atZDti6YM)PjOqWzdOqsPHOD6V6ZD(RK9yvsqhETkzPpdDz69oQx469qKw9yWj2R13cRWDrfb5C4oDfgqap9OZzDfKtq7jqOw8LmJh2ogo4Y9hVflSdZEFC9Xxs7738QH6pQU6ZX494NPaD0NXToVcKP8utBEKoKDoC62r9BX1fTEU)LWIWTC41NtpE61hysWCRme696Z5vsVQYStCOiMt1NJZ6vXMKE8IuWcuW57eHg1tuNS)EXbLqBCCRrLePxW4ONDV8U91KV3MS1s9QKnZjA7wykKJVbBeloxiQwsgp42)uVDUSyjngheCUxayliCS6N39y2jT09QCMtlcyY(0D78PYyMhSnH5HdC26RUQfm7DjKY3CtrcGL0LkGGTApQhCOU0H0nbs2IAxrSVX)JsePzp2skkrfgn)zwgh5vuxqs9yAk6urpcW3W9mO7T1kN9L2E7muDfCNR8rm(b1mcmVSbnnilbpnzcDl9aZDVNE1ffOF33zTZ4doEn78joxL)UhuVjK2C7eQfkVoXos4at6SLNGQQpyCFms8M5NMUM9aZp2qYzC21WMHdyCl2cSyGfhriAYlIweSemUuws(uCsh3Sh0bwaiOey2g0tzenwMH)abDX(VCuxYXGvSpeZPMMJyLxoFTAKlv1cCjvEv7NOlsyXvgoWs(KpOmLSix(y(mPaqwDHVxkRB1nlE(wprVBkZRgDxp86dG9083MppemIJfxP3ZbnGE8hPCo8z0ZHPJhgKmCJFyWCVhIdylbOD(QC3rkg1KHR8t82LW844u2Aw(qBMIX1McLls86VlwSUvq8(y)6Sk(G12DTjkov5Vg2tGy3bdC)R)fiFagh0fSCgLQA3qJI6jb1gBKvebQTnrSt3CmiWDL8Y087O62YcMqph9DjRJsvqvnbUJro0Xp9vII0M0dirrV83B)0)nEPJOuXjvE413iVt4Hf7jFGmaekaRwVqSoTLvVvBvu2yYgZeuo36QoAUpnX0(eHcMMJ5OX5orxQnWih6uM(vII8)t4CNGLOhvFr(MIeuYLX5FGhVj7oZhmXd(G5)K26a2ujo0UWPudBrBQJR6r2h3p93IdIIfELD61L3VLNP3XhltPIEN416HXHvrYTOgrKUTG00wpOKJH7xEFMChR5eitaUbYB1Ke8dQVrTSQwzGoxrGMWz3YGYa8IfTtsTc9PTIWunXusysrs98btSmM5L2KuAKUv4nf0ultlZzzHH3NzMX9AYZMARysvi)vDkB0CJ5RlLnKOUHC5ymD4wLkg8MH5yBihz5PPseUeMGCOS(itAUEb6Q6b1KC7di7zKz52kwCuCJ3JIx4LWwI5ntv3i4bQ)h3p9x4HQdBAHGC9hGG13p99zm(khiMOicZ8rBDaVtiZ)PxO)ggpxtlltZKwpqmK(bLT9DBa1GQdHxV6P7yy(FK)skEbwtHhrwEUO4lD3CcHKAYO8F(2mxzptrTqTiHtwXkuXZ2mJfNeTBD(6xDSphadkEMFm49YmGVhnVs2pNtOMto(2iUFQjTzW9yt5ziyuP2w1QbPryBwTWK4sZfEcYctOPLwZxZ4KYck5u7o9uzzcXrbBgT4SwvWLYYLPr83i64VU4gPqF61uLtq8R19egsjZCvv7OOPgC5oqZsmB(k(CKLS1RDnaBvdgilcwkyoGazV8kZg)hykDOAhG6o3yzanKFwnLx7QAHgSa(P0Kns)koyVYD7qba0CbYZpKe0mxBSn8B4MChiTWVbvcHrMwdyhbGqGLxvlCe3zJCq1GTAsUwLK0wqJsUEufjUz1Vtpm7RekhAwucZWVDHvvKuDiL48nk1Kzt26sf361ijvfjFNr1iG6LwZPn5RJr(WwT5KlwHLwSszG(B5ValpO9aL8cLu0qQg9S9zxQ0w5PA5LVJ2uBQ7yQk1PzjU3mOtBP0UB40U4Y5YjVRQA8Aqi(nVsLjy8eZ2C1wq7gf3TLdgXa2RjhpitluA0oq5nS7SG5NUYPO8Ot8tXK(OF8gFnEYcKP3LXlBfvMkj8AKvGWSTlZo6aYXx9okaGeR1N7e32HVv6OuljbtgPguFu0czsw1NTLJjaowjUaEexS4hb5(YuSK)mX3oxI3N2T4bEk0RNEKo076dbzgPMv7yMGIBi9nht4tLBGFQlGeU)ApUfl0Sbvl)BOAX4GUYoO)dIaOJ5h8X9zfc0YdVgG(Lp89Y)zW3l)hQtwEW3l)NVfkzaDVJf5Iqj0d3zrml0(9kCQx20psBvFlxHtVk2N(ws487fXvhTPFK2Q()(fXv2x8TXd98x(mB(UuoTK9el(fyTfU3blNa65CAbaI6)KFWAb0QeF)wq2ZBfx0llYCe3mJ2k(Q)kFRC0M)BR3XuZ8Hf4RKez1Mu5NoXT1ymearwcWkJDgXvrRaElt(84QzGXWhgVuEe7ZLSKXQ2jDjlBIAyw6wV4KhXCwShXnQSrVxZflogKpBXmDo9Sns(Vv4N)TS)y9qfZpUWk15MUZIYQidiv8CtEyx1DdO69l(UG1al975jD0pntQlbcbd(9OLYAjXpvxQCv8HipFDYdiQ6xy4jwGpdQuSt50Rc9mkjnoAl)lweZKxfS7FKWkdsg4NHGM1MwAUsK58W(XZlQwqQEfxqRGNC2uwEAySYsw)dkcjbV5Zu92MRU6LTrfeLbYfZbVjoefwTjHyzdNACDXfzzZg8VGv6VMn)7NEhhibf)al421(VakQ2pLxIbQJ5)qceAtOB1dcdH7aKWHFWwgXNXCTmWchYfduPjyQmYzzTrj1a7ZEEHAm9M(ptFwN5d2IwPsrwcu1pnO8tcMFiNkU8AU0iVgRNcLRrqEEUNRCmhNkoPJ)q20lA7MzVts(PjnOO8DCWkTwLjs68P1M389pQj5Xxej1UHZFsfF3wCVrBCt(mLu0u1jmP1YCuUopNmnyvDrJ4WAeWLPJZHKN2KH0ZQjk9XFdwTO9tdJa7gpZ5hYzGqpCHUIh97CKFNJudhj36HGJmccSyU)2TcZicFD4rv8XO0Ff9CPkm(w0(dqmCiMMFI)ujRFmd8LTHjme7(vneJxnf1gtnJiOCT0o2Mzub7LMG(sLfVtfUnkR)OhDgcbld50wcRhIhyzfzBksPi3doFjwn5KGECBeFX25FLqoteqvak1xiRFN6DgL8hi1nvRVOxeaIu9wq4YDjbzL91zLz1G89hO91X4PenvFmNx9JyCW2Wzc(no6FTa9DLhRGgvqGmDEK1iq47cTgm43mh83JUisSckU5WGIlfKIgTWv3bIloaG4cjqqF)TAlqm5aaIjsGG(GvTfigFaaHKZSrtBPI(VFwMlWdq9Nr9j5nyYmEun9wLUHDmF9Y4gPT40nmE5lxgFhDXD0nSykTRZuKwQI(WIB)YLXlvPpTs)DNOarPi9QvRw5LWdtxfVtMZ6TXSSmEHK1AT5RmpZHjVeoV0XGIKGFxLl3Ly)GI6PJ9p3fSDlBXWq2A(5IaZCIxJgeU0GuXy19DzumOnbXXrXIAnmga5DXmWB(OnrWF95KAJL6trPyabXbly7s4tLOAJkmsAl8pWi4xK23XfPX3vEanvyww2iZCdUCQR2vs12rM06apwydPzPow9jpZ)S2Ra1Pv1OF4x9vtoKB(QI26Qnj1YTXxSTIGAvsfGkr383OG5sZ8WBOywMPHB6W7QKJ5DRLaCBzJCumkrpjSsTnl(Z23AvT)JhTQZn9tx00(gqMrOPjvqtphL6a87KgAQZ9VX6bn)v8IXahJ6JlmcxGzYMWQZTDGoPda3NxpqDVkd71nqM)ytnF42DnK48LDQfCvei23u64DydRhBbLnWRoh4DU99Ea30kK3Y02VyMC1WC)kUfT8GS8ut3LrQC3fAQHYypkm2sp(KPOkhrE2I2jXHDltJdfKn(xCVDZvFqtiAbr7Anxkhfb)QjMdqsD(JRl6tgcnLCr4ArF8H8PQUwwziEBzqOO84c36ppinQ42PKF(rYV7n5Xfwi7loQc4Pmz1HLvZ)NBFvm14DlYORziswalQLJyZp2)RRZJJEGEAQlWRYobF7AoyKbbQj8gCUSo6qqX5418fuz)HwDBLgJt1a0PZZMdlqXd4jIXJ9eF)ZFbOukqwRE5fpPRNzgroaER5CaO5d0ghVOOpoPl))L9UA2TnUbc)S4dXYUanqRKQtsHSFacYT2Znq1vXXaUwUsYUPac5zVl3vA1sY5B4WL)iTo6O1spd58phoKdP4a1kdeNlm(7e4MVE)bgnn5Q)p1T)6NR0N(j7z)U)t4n1YsvNZIIXDYf7(BKrL8WvSLJLc0X7ux39xYqXnsrXutumbOgmTrbIYQ902VZby2wb5BDr5)m4vbNPnI4sfz2YBvYHLIaL2OxVFRs6BpOzxfp8FveY5lFQC0BLE1uwl0sozBZSTh2AT8AFQRxXeEIwOef7sFPdVJhXn9krXOGmHJtID9w4u5gzE5pucYzlxU4U2jBXrEnGXQ0E6k9EhW2yOAvTpbMKL99qDhl)4HY9pczWYfXrsboEYFlS3c7CFZ0MHXbG5uRaNptIuUQbxMKRkHLoT(H6P2mHKZbHWdoQKSUeLok2G6eoRlAVeDDYnJ52JGJchj80OZWADuUib24JOJWLpGbHoNUwJOAJahv)bFgPC5EWhnDUjPwSkwup94AC46X1cIA7Q2tOjTNqCV0XmLXh0MGRK(qLGpRvPV9ymhLTMibTrITMDJwST20xMRwO)n9lSURWP6yCucs8IEe0PU35TuEkKDvwyUFmUDBCWHuqkBH31AjIE6Hf8kbc7cuJBBNqukCZt)0Yvc6m5fTRVJQc5m8k84tpRF5KegHqb1oQITGbzQsREtTPeqCefABFHY1)ovVhbzOtGVE4UkuZA7C5kzJeWquCXMuJQoecQwkbXC6AipaD0FD(GMf6KC7Ut0PQJ(GQdrJxbeBWWH)unXg)oQ6WZRSaPk5cpOmp7JWdX1zAAtAvb(7Hh8rYl5JQHakZkHhZkxQa2ccdBcSIe9RYnbq6crb94OMvcswMAtFPKnY9eplJpszJWxEtoD1YTIdz5wjpRzCXxQqolsh3ubQTtedEnYLEkwLHyKcm9HE4tW035C0b7YdUsqHtaGz2pnAI0WrUr2GcnaaZcV3CSFvEFERfjCp)oYmpsSxTf9xk9QQWyj7A0KHtuVBT)7SLkuV6p(TFx9S4C)F)0c17IZxuxE8bTUjGdu3(7)55YTTxsnwTqvSrZEUC)7ZQEvRU9RZE8U5RE73)4NU)XYp9l)Q6Uq)yj(Q(8a7iXhuFJYj(YoIE5iUO4Bx2aZRsamlgsd0AgXlLKI5FZaQT)eeSPyUoQGgOereBaCMyMTqY7aZCOCV5cXPY0Eu(9pYjZT6iqM79jaMFibWC0OdnBR1tfGFSTjMZ8TVKImnfQM5U(lIkASAukw0zFdbPrf54eHgMooLfQ4hRC0jyvHhNi086Kxz3bXiWaXqsiWDc2xNYx2Tuncm0vor3aEdybom)l1)RYFB1dk7TQxNhdtUeJazE)aIdMcLYaxcEFOC4dzFLe6NlKXjWJkaMT8XPfHLrTtjeAPygMcy69QML967MjsXc1YyqeGjia0OgFoyJfrfhf5yHGIyLQg2nXcvzU7jA0YTJb8jF52KcyVvv2cUSqZrsprMMJqJVKgwRiZwm3pZiagwPxQpxL9eJPvZV7PTYGmHa2VzuLca7)mQ4OayFLmjEgOHCmh2KIaqsGzjcAcjQZ906XGufTPDh6NckGkhKcvUKdbMVJoEaCZiIh(KYTDlrRIcNnr7TayUVDYdmBIhnOtl1beJsek0B1iwW26ZcbQK5nAuIqrb)826ZsChMuEmo5kbSqyZ6Kw7HHwQXCiYbUtURiPs(K0z3zAOXc9a5T5fdQpgOrG6Zc84q9zrrsP(o1IcxFZaNlEAE9rqUQUzcm4mat(8ZUGHlTzdpj287eeNlp)cFUAF3uFYRnDmO38MIrd3SX4xNE9vdp3U)bTzZzYPGxUzJ65r4CTBgW0Xd3Xl6TuSStWWHafdVUyG60Sd5qKdCNMDe5sNffsm7WmqnezLM4yq9XancuFwGhhQplksk13PEv4g9FNyJ(JGMWS5sTmrrsIn)EcmHLFBywg97zuSStWAecbjglPc(V3HGFqKYKrl3TUdA2LSjNZemm5i4WHacBbMUpqExd(KisvnSLIJiRavEzHa08KhvuPGLTkSQDhQWpDeuXHfcrhS9ZQBv693voplnDyavTVjmAJijm3NGAoodOKuGQfjPYgZXbJogD0dzt5EFVOWpvBubBetQtkCeKII1fOogvAbsgpQijpo0airf(2Qp)NZwV(H53nFMzC0MFwO8DRM)GFc49LkWUifbIwKdFbOt3oFg)kdW92hMp7fpdRjhh9Fk4Q5WJwoeCkYbdaHK0yMQU9k6NyOLiY2SWKOIINfDckfBHffpcnjQaZzrNGvLWcm)hlEv3UJbjf4ob7Rt5RUDhdskWDf2CW5Lk(57cez5xovvssqrqNq3PQssop(uvjDiRkjq2kYjh36KIa84J(I8WVZbIACvpAcKxEGD4SyOxNGKRZwTVsQ7ruA8gzJHHUtfaOqdDNkaWiQ(5N(xm0I2Yl6TuSStWAecpvaGhYcaeCYHj1SZvsJVQNvpv(PeDy96ZRoD0tQ7ruACMzIHHUt1ARqdDNQ12iQ(5N(xm0ISIVQNrXYobRri8uT26XQOADh0SlztU3YxRrd8kz5GQfjPcfX6DKG1EEhHg6a27g0aNvstNYq128w8Ojun)SVNHEszEWQdOBuii42(OMBcUT)Cha36fptbUQF2xWfWHDLAaFiuOriTRYeiW1rzcm46KmrQE6HshGbNwMEd7bzeQUNb2vqhOfoWP(0vblujA5l4i9)(0Y5QhwOzE6bgSedI5WxRMQg5KFZXuC9oq3VL4wMzaKO)8NBaF6gjIjOp8VnVFz2dpS(RlF2pEzS8F78YS4VywkUqlmQxhHxOL0Cf16tqvAH4))S31EVTTUv8plgfqWEnnZsYkBfWwaRBTyRydRaT7FNJJTsJxDInKSBUDWiF2hpK6bFC4l9in7I7FCVnWII8WZZFhksE6KxHHy3NhPXvt360NJd)qSUDd9ZMNSQJjZlHtj6WEXQzjnL(zqE6J)nk7f66OiwTObkOe7itBG59V)8H893UDxDHFS4YAWlVEXVVAbkU4Hv3NTO4hpSU(oG)Isj1IPx89v7oLTi8IT3UiF12nbJbX2HdzBU8HSDWIMb97Y1Kyu0QBbu6ZH4QNpx3o8T4jxdUFBE((COf3Mti0teLcsFD)EYV(ybx7u3aNCpCB(2nzNkGU4RqTGzc3ZmsPbwi0N(igZR409eTF(SMiG0wD8ugEZBkF(aJKyfnN8FxcLxi0MxxGBHwpIlEvdAq9V4JR(EgOC8QNU(9)s26tu9JmIo4pi6yBbtTJGPj51bJYTfK)87R2UdufUSUxxuCiBvoHIFytvrLP6rkQo1lW1f7pSOi7yPoJdl215ZoT2Bv1kLuXk0Rzc64HL5fFtIKSxl1MhguttAQSTKMmwQqcnfkKqS1bSPAqnpzIDA8Mn30jAum1WMgisklcP6dFAp1dbhrDG(lGAgBqRWbE6W5Z6)MzNoeCiJDmnuewSbgDzQxepLsgV702DeDY)muRNxDSuFKy(ark2FlRC4q(DoYKA1wUkRG7ngpC)bOardepOxpFwayyLemYcTfmsc1lLO(xfeI4lSVlaXMy8NF)hMyNe43)YxagkRpYCwQog27kPBPrH(dJK)eXLwob(6)Lq5FS07Wtx)zQ7HR3syKh2T6hen4NUgCDY3M)klHCEIs09YfcfHigjWxLIcKDkvMIFG96878Wg(nr7N8)YiWdanGsnE2hnOqqbqqnhigz97ahSBcgBvRT2UY0hbycDc8LpXIz)WEIA7JaqO6cwohHZIna1Ukmw6izRUawpKMu(jRTvXQMhhiiwkdR8gY)MUyC0RPDYH9psJpbTOGmitcg7GZzfZKZNhx)EvC5aUFGUEAK4UGXyAY5Zwy2tMems8JKWCzhmwu2Mg28HteudiJeYVQ45ZIVYgHjyXqfMqHwy9QdhOMouVuqKYVS)4)Ols2FtE(mkpPExOIU3b4OywQ5zKWSQUk59mZd8cf3vZOlT6C1(yeezQbIj(y4BqKudi)YKafiF3v5VUEQvsff2JRWovKDm4exbIYAyPMIaFzakh6F5vusyqumLgpM(t3SB)(nqRP)g9Ny6)cvF2sGmmJMTpC7jOi6bwntkFcY7eO5vKfwZ8yM9)ptR5(mTicmZZQoWYMzHHjzB5txh7xxh7rxh5xxh5rxBtds2zd1E8VWsM3hZrUY0GWa6VSSznFm0rUi5AQ)mM6ihKtnxwlM6ihKknf8itDuiFhzFzd0oAvFgGYu7j8(R)cdWrZsbWj2GbtTWKIHurTaLMwLWTiweQ2MsfLnqtHtoyuPZmDvQ3HJQRcVDxvrarlnYir5kfSokJYgQaU942h2SBF(gCItEzi11NpIDT(JyP9hhq2fktqu0RR4yRHOGzmfHlub5LjhDVK0QTGnlWPuwqnc4oAYMh2VLQFfGTen6gBH6CS2r2g49fXb6x)2wp067seZtVn3CvbCrIw52PcGPSK(90aRIM0FuEKbcXvXF3e0omk9C3vk(q5ZnjtG(46vmjUPHcMw17kX4sVTarWE6U9pcD397b5)P7nW4vwBAsslJhzBrqj5Wv3eChJ1jKrZ4HKOZiZtIb0dNyk1gPI5jmdjitq2AXWSTtdNQJafsAufbpDrjD6DzlFjBuNNOD86BgYyBkxubykjVuZHr5N0)8c(petnSuPA5mS3C3J5MQIOKJqk6lFEysnej(Vv)lzsEiX)0gnMzA1yAnx0rigDdDARPoxLXJ8KTi7a00sNfaFb6LzFhiKvB2uqSltHTFV4cQvMGKP8JMbFRuZRFR8QWopYMQX8qUpFG5qIZdN46YbRH47B1(Ho3ogr7KkQRjqr7spZ0G(ooaABas0Go09Mzw74)DxPPpZvKstOaFBVGtt0ensol(6rqTXOJUMXJB6co5HWZCoDLp6Ho9l38h6lLEpsFGKjM7Pp4MAGviuA642LwI6RAnRKbHnpa4WCJD7OvxNcX9sJh2wEf)Ovc7k2aSR4oc7s7(XId41pvOzXdHuud0mVHGf7U(joemzNpHlNH58P7JJFh9AidaX9zwcIcDStk0oj59mKRBJ8qb8lUfOKJDeKGxyTClYvFzbzhNA7N2EHXS9dJhmSxUqWCt53nZUOo5RzOOnypAO34LlUJgPqAOoVvoMAuC7b7P(Qwb71pmnTGO6l7FpGSpxlKDDCmhmETG8IUvLtF2N)AubTWGO06SGX1Q5iBj8a0D0hXVXyPDi2KwhB2drQo5wxZBVfeQH46UVuP9LwXyz41PjbgeQGZlP2plqwEwI7pYaU)OFTJ7p6LDq4iNuBDA27j23i3Jp3PCo6(4me5Ce1tMT9q6GQ8ru0KUPPmu5QeznxfQdB3agBVZ08oYr3HHSvwCoatWJPId9gLFdpKrHQBbKQ9mSCskNpB)WZKMGah6fKgUgIRDaJDZoWnpMiPT4r3ljR4HKffqE43LdS4cFWkkFp8N2Pz3ZDEvrEKxv)mn0MPJRg1Jm6T1swgLVlelJVEA12jBVMvXy81r58zuyX73S9wIlY5HxQnsBNH33xEZSV4t4F0IY5y6IOl)dTtHPpeSA6dPZhQYlrZciSkla1oP4x7jbu8skjaRwNAOFn(8RC0rV1eYYYHECvE((VcrPbLBee1sjkg0va21hpq(bXbClHtlHoOJ4BBhhNGCsYX5QD3NIliKWW47pSPI(ceCHkc8AhYQFFa7m85jjbJTF(YtJ4S3XpKMirqkW9X5avf6YzExN)ce(CpdrVqnaqpIT0qVBZhkgOidDN(uBT5QZfBh3ep9gbBkARQzJM2O9OBOXett30UmK6IGpYbJ9ueSmQKR1ezSeuZb6iwns0pxV8YR)HMLYPDcihmN0kz6H5)WGCwV1IoZ(UMjboZhbW87kNRK)ImzHZo)r((7Mn3SSa(j9AXUT8MqhYDAUIXhIBKVLv0T)FHqeChAxHoXpm(83ecmBr8lCineSpj2uJwd)Syz)ZXWpYoK5UYhpzr9xBXIYyxgijjnHTAEmzxzdat)INU(9aB)PRj89NU(d0Rid1lAIlzxOeV2LRejKxs7rGgMjwUIrq6odjtGXQgJ49bWXd3wvqEakpmCwG6nzvAy0u6LUszzKWqrLoqSrQ3HDnnWqbrwQry3eEJDGyAk8fAiMj8KBtGGQSuh7aP2mgAi1j8tg5XyINIyIivm48vtRZrWeO9ihXtpHlr76lAHkCLIMAZJLbkeLGP)J4FJQzA9UPct7mjGBHdqCCE7jIjAE267G3Dj9AsZN8WXehkbj8PdtNLOBH)m6(3WdRZdlu3wbg2gcAgt56OISD(uThbgwiWjYYCOmsn20Dr2jLBeLfZSbQbMa2Uu70rNkdMcfN441WiVi0jJhxSXMdtoFhEmlHPy6Q4rOQdV2aRtrXaB7S0yRDd6TUijw7yr9hWBKzduMLzr6uHfP0yDkBIp3JDUWrbDw1YvdO013du8K(NFeB(MQCYemfdDEHrU1kHLI0nIMi)9ID4RR7j22jBlEBqju66gA(IfyryKhmh094LdkJs(uh(ywV6vv3gYCZk61zhWY2KT64DOFQnQ0xA7Br90Cx2QDhVBo7F6Z(hdp6vtRDCkWPxw(JWIbkh0bth3obHVquQDW3wLF)kSoquY(2PwVKaXC0GExXgELDcsHactEl2aGbIbwIR61K2h1l6cc54KiAk2qtWjNL)nIn5qo0HyypPxEbfl)pN2qVJSrAbyas5ndkTHXwG15IOjUAh9k6EihECPYQVstLjNGBQOELYq9pb0uvEZ1x1H6YtM9CdjllDP)Q71nM28iFyvYxt1PZ8mkEYu93UZ4eVLm4uw0zCXMSgTRDpMp2WRoFUYD8E807iitvZ6)3s6Fis6hfq)SwkUrL2bVCwLaDtlL8QPdm6n)PMCwQPbtMVwVE05bElnxsHCfrR)Ok5n7MJ)g3BL)jmVRDJlutkmDtOQ64VEVJTb06a8V0ke7A4QDwMw5R8Zo08PjWvSQdx4YQjA7YSFK)tFV8ElqtYyZ9Axq)AivuzeGyOVRNN2rK2Ei4DBqgkC4EqvIFQcMxhUR21Xc8HlxFkN8SJL8JYuGVB7Mne5190pMxXYB3NFd7xyL6WtvxNWwAhN7ppAEQklCc6Iw6cFf15HDMRM8cERVUJetpqww4gQYMotaWFh7mZq4RBMao(ooKQiZ7yhQbRTd9hf09hQVjCR6(Q7gxaMD(Q1FBx9xOLYUEGN1ZWTCilFFounGoSA9wci)QJ83Bl3mb1kS3V6xsZyLrh6sr8g71hgH2xAczEuNXVQyYWqtK3jDOCh(Dflh7W2U2e5vyjx4)3VvB1jaDuu2OK6V4VsJWL09(nhM63ov7aZkYsEoVqFb)(e2YuycAF2d7ed1DIYA5ZhB803K87ejidFMgq52(25nnY2MApY(w)3L7lvqIeBVRsT1vZzD1mbDP5enov)i0p1boRmuca98)aQCDv(AqEsyVqSFhvWUD3pOZSS8dKxQCZO8ajsE(Pdh18on(ak95(pPLAPM2Yk9sMwxcK2kABu6vR2mUQa3j6vjgPF0UnnnTdmJmwHG43GjTGErjZk)esYjEVkidLMoI3txAO0oNrz1O(t7F)tx)3pXFT5vf9OQcB0w(yOXUu)wTd7GCISTXn37dHFn32h1gPlRNzXY5PqjNTXiCzf2ez)cclP2Za)OnhIun7zpPavZg65bkP5ZKRBcyDjNJtxYvePY7CAcg7hkUL4bfSDOWOkdpKOSMTxPUkUO3PV264j4HcAdla9C5wY1DNZO7qHjnBPFfCJZTfW5(aHJO0v14RDNVTawYizkAM6pfHsbUZZ9dBOUnWOtNy)op6mgMTT(DS125yCMU7XWLibDXNrpqI2DQzXHn9qCiihTE(hAJIqxPZF(8XUiOTYEeDlm)kPn0UVOnCyhbZse3Z7GT2nuE3NDAFSZGjTsQgoFPtNFSunVC5JvUL8nJ9QvGNJgmot3IDRliTyKk(1C32OSCnWB3jpy(AP))AVRMDJJByWpl5qmSrkc8oR3weGS(sr75c4E2BNMUozbSRl8UohYH(Sxn)zpJgsPpsXr74uJEQWBKO4VFKCKOulDaN6z0wgWyW4JC07WabneUGFr(wwduDQ(fNIY3I2lzJgXwGhrbpqBRhobwnWGnNkab3lYVfW5Jmc(CewHTZ3ileZOqqF6k(7vvfMcQKsabkLd70mAmCBx3N3Z3Vsa4NUOJGWu0iSXeijM7GDCvGymXWtsJi1ZtefybCCzJPYQFzt85XVmuetouU9okycaKyRw5Xbk(qD9a9PIizklYnmmUj9QW8Y7Pt06vlPQBHe5ne(SmDsRt5CGosO3at6NSIUpgNbMvZEBAItUgtHyUwJA)XbMhxvb0SZy2ox5RIX39TTeYpZ1Xq6PGO2nZ5dwKgaWjviZPuqcLe5KXPwNpoLohi5J(IzrrlrLXtffujFhD4Acy7Xan1RCNHtMy7JsLIC8L3pvpltOQm0asCxITM2EMv6TLEcOPyUmmV1WiiDSUT62W3MOUnGWqyH(9AZwRWYou3GUH1))LtXmkEB)M1QXG5u9QVra1B3(2pIGpCoFRbeGI7vXHDIdgrHiWm299eiENHGVKy9anZDpsOBTo8nG8IhnksK9e)gcqe(PsJVW4FSKlqT)Q3Su6Sp22iA9sP(RZHo6RnxdMU5NcqnSgUdgvDseytPTgGRu9oz8ugu35(j4OkQR9dlpajskZBz)7mQvWiYjJBvpS6EUK2S7dAnIYS8aI2ZwbR8QJuWYiDHPTL3Qr0CJPz7QMNMYhA0utb)cU(xwXtaC8hddTK(lCHKUlqNxQMKWYj3IUXQIHrlFoGJzkNyYByKvQq3NqryCslM6orjd4Oxa8(mPvq(IVXTnQb9gO4X83CLax3L(pLqrALDI8hquJO7IKLBoOekmudu(ftzcHMIrGk7V0Sdas(doY1uiAMqvrKqAkvgbS7OTUvh3rtILtcJepVsSdwGuZIKLGaDVCXCuQoHMLwJUxYjPHjyq4(hRu0wgkfTLQD)sPNGnFUJh2tSMXY4mybfLHBdS2cGl1bLFhEGjJUe3vWSaHq60lavTIQWByQZgO5QgXc9WicVL71)COoAsIgAmXlipE89opwJzXSlt0ScsMQpJy54QWm5nWi(wAneY0wqu4KO7IKLtvyAQSKs2JAUuVTnaPnQUsKywZpYYbecN5Aw9QOBM(KyeO3Mjjc32GMKYsBssbJXJq4hRKukcLKcZ8VgX7xWhDmr)ko6AkZ6q(WdhtaKy1)TAoTJ4Rpg6lIl9fiGmK55opqaWxMCZ3x04pO7IKLdZ17SiPX0PxaQIx8QWMvsu95KbOeRn155cuz(XBaEL5twB57izK1KSL0MmZkjU2KTYXcEYdrgDZc(65Uk0n6gJ2wab9afgl6Pk(oESWFUOd)jbHP)1frlWsRUcGnBD7QA9N60fKwt(xFYKXatClq1zoMgM3qp0f0aiKWW8bQf3AjbLstoD5foNC6dGkiHVXA6rQ0jpuCD(kEIB0yGaMc8FjpYijjCgHoLmJlQkRp5xQCi2NEAXAoAmwhFT)hCg4i3Hq4tdYo7JmXCMxj37eGRiDoef5kGd(B8vsI0aZlj3kII3KaKH5qd)9)9p(Th2D)d1Wdp9Jp)vu0)HC6WgNYx5x3UoQhfOD3Hrb6UD2TTwje6VEccYsVcafDQ6Fw)NzSgkS6x34jy87JwBFId1GVEKGrsJc5sdsUh9VLZDRLNJh)NNgeFa3NNfaZJLfuQ)CMUeY6Ij6K2A)OwL8uFDYNhXGeCUytc8lVOt1P6lAy)M)S8WHB3(5TLpO84pWE2NLEsmPweQL)(8t2P17)RD34IOuLhjJYGWoAn6ajYvhjPpmoV)8Eyr4t2LRlE)pXD0cRkjW4WewNbQtDb8(LF1fIB0uqE)2BEA2i7w56XYPt95RLohBvRu0HzkWG6STofutTkMzr3WhqMbu4DL)9UpT5ZpSB7nUfSXh0Pvlb5SqCX7(KZbs709F4081FH6pbD)s5(npUF7Mkc3B27Y)pBXG)zNXEckV1rLFP0HT5XV9nNKZ55P(qybRU7vTqcZUyflPwDyCR9D)W(BV)W62)qdgCYd9jVzipEG6K3Gs2Nr69Nj4sNDIO5N6LD)43(2f1dJU2)3pU(hp)eQzz(GFapB8PqLNJjsKQHZZ0zu1EzZ1ZglSOVEBbhhSiahK0bG3F(iWbNZ6Tfd0B)EIRpLSW9nbXpUu)OMOqHEOnJ95oeIXK5lsCeJpgZBWeJP35gIIMdOxl04MV(X0PEnYTgpGG8XJy47Pxj51WKQ5JZIyLxFv5JhCcMRV6QD39ZxFW9Fx)F]] )