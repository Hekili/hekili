-- MonkWindwalker.lua
-- October 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local GetNamePlates = C_NamePlate.GetNamePlates
local LRC = LibStub( "LibRangeCheck-2.0" )
local pow, format = math.pow, string.format


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
    ascension                   = { 80612, 115396, 1 }, -- Increases your maximum Chi by 1, maximum Energy by 20, and your Energy regeneration by 10%.
    attenuation                 = { 80668, 386941, 1 }, -- Bonedust Brew's Shadow damage or healing is increased by 20.0%, and when Bonedust Brew deals Shadow damage or healing, its cooldown is reduced by 0.5 sec.
    bonedust_brew               = { 80669, 386276, 1 }, -- Hurl a brew created from the bones of your enemies at the ground, coating all targets struck for 10 sec. Your abilities have a 50% chance to affect the target a second time at 40% effectiveness as Shadow damage or healing. Spinning Crane Kick refunds 1 Chi when striking enemies with your Bonedust Brew active.
    bounce_back                 = { 80717, 389577, 2 }, -- When a hit deals more than 20% of your maximum health, reduce all damage you take by 10% for 4 sec. This effect cannot occur more than once every 30 seconds.
    calming_presence            = { 80693, 388664, 1 }, -- Reduces all damage taken by 3%.
    celerity                    = { 80685, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    chi_burst                   = { 80709, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 537 Nature damage to all enemies, and 1,141 healing to the Monk and all allies in its path. Healing reduced beyond 6 targets. Chi Burst generates 1 Chi per enemy target damaged, up to a maximum of 2.
    chi_torpedo                 = { 80685, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                    = { 80709, 115098, 1 }, -- A wave of Chi energy flows through friends and foes, dealing 202 Nature damage or 507 healing. Bounces up to 7 times to targets within 25 yards.
    close_to_heart              = { 80707, 389574, 2 }, -- You and your allies within 10 yards have 2% increased healing taken from all sources.
    crane_vortex                = { 80667, 388848, 2 }, -- Spinning Crane Kick damage increased by 10%.
    dampen_harm                 = { 80704, 122278, 1 }, -- Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    dance_of_chiji              = { 80626, 325201, 1 }, -- Spending Chi has a chance to make your next Spinning Crane Kick free and deal an additional 200% damage.
    detox                       = { 80606, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    diffuse_magic               = { 80697, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                     = { 80679, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks. Targets already snared will be rooted for 8 sec instead.
    drinking_horn_cover         = { 80619, 391370, 1 }, -- The duration of Storm, Earth, and Fire is extended by 0.4 sec for every Chi you spend.
    dust_in_the_wind            = { 80670, 394093, 1 }, -- Bonedust Brew's radius increased by 50%.
    elusive_mists               = { 80603, 388681, 2 }, -- Reduces all damage taken while channelling Soothing Mists by 0%.
    empowered_tiger_lightning   = { 80659, 323999, 1 }, -- Xuen strikes your enemies with Empowered Tiger Lightning every 4 sec, dealing 10% of the damage you and your summons have dealt to those targets in the last 4 sec.
    escape_from_reality         = { 80715, 394110, 2 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown. During this time, if you cast Vivify on yourself, its healing is increased by 1% and 50% of its cost is refunded.
    expeditious_fortification   = { 80681, 388813, 1 }, -- Fortifying Brew cooldown reduced by 2 min.
    eye_of_the_tiger            = { 80700, 196607, 1 }, -- Tiger Palm also applies Eye of the Tiger, dealing 401 Nature damage to the enemy and 385 healing to the Monk over 8 sec. Limit 1 target.
    faeline_harmony             = { 80671, 391412, 1 }, -- Your abilities reset Faeline Stomp 100% more often. Enemies and allies hit by Faeline Stomp are affected by Fae Exposure, increasing your damage and healing against them by 8% for 10 sec.
    faeline_stomp               = { 80672, 388193, 1 }, -- Strike the ground fiercely to expose a faeline for 30 sec, dealing 467 Nature damage to up to 5 enemies, and restores 981 health to up to 5 allies within 30 yds caught in the faeline. Up to 5 enemies caught in the faeline suffer an additional 758 damage. Your abilities have a 6% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    fast_feet                   = { 80705, 388809, 2 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_flying_guillotine     = { 80666, 394923, 1 }, -- Touch of Death strikes up to 4 additional nearby targets.
    fatal_touch                 = { 80703, 394123, 2 }, -- Touch of Death cooldown reduced by 120 sec.
    ferocity_of_xuen            = { 80706, 388674, 2 }, -- Increases all damage dealt by 2%.
    fists_of_fury               = { 80613, 113656, 1 }, -- Pummels all targets in front of you, dealing 8,457 Physical damage over 3.5 sec to your primary target and 4,990 damage over 3.5 sec to all other enemies. Deals reduced damage beyond 5 targets. Can be channeled while moving.
    flashing_fists              = { 80615, 388854, 2 }, -- Fists of Fury damage increased by 10%.
    flying_serpent_kick         = { 80621, 101545, 1 }, -- Soar forward through the air at high speed for 1.5 sec. If used again while active, you will land, dealing 103 damage to all enemies within 8 yards and reducing movement speed by 70% for 4 sec.
    forbidden_technique         = { 80608, 393098, 1 }, -- Touch of Death deals 40% increased damage and can be used a second time within 5 sec before its cooldown is triggered.
    fortifying_brew             = { 80680, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 15%, reducing all damage you take by 20%.
    fury_of_xuen                = { 80656, 396166, 1 }, -- Your Combo Strikes grant a stacking 1.0% chance for your next Fists of Fury to grant 8% Haste and invoke Xuen, The White Tiger for 8 sec.
    generous_pour               = { 80683, 389575, 2 }, -- You and your allies within 10 yards have 10% increased avoidance.
    glory_of_the_dawn           = { 80677, 392958, 1 }, -- Rising Sun Kick has a 25% chance to trigger a second time, dealing 420 Physical damage and restoring 1 Chi.
    grace_of_the_crane          = { 80710, 388811, 2 }, -- Increases all healing taken by 2%.
    hardened_soles              = { 80611, 391383, 2 }, -- Blackout Kick critical strike chance increased by 5% and critical damage increased by 10%.
    hasty_provocation           = { 80696, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    hit_combo                   = { 80676, 196740, 1 }, -- Each successive attack that triggers Combo Strikes in a row grants 1% increased damage, stacking up to 6 times.
    improved_paralysis          = { 80687, 344359, 1 }, -- Reduces the cooldown of Paralysis by 15 sec.
    improved_roll               = { 80712, 328669, 1 }, -- Grants an additional charge of Roll and Chi Torpedo.
    improved_touch_of_death     = { 80684, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    improved_vivify             = { 80692, 231602, 2 }, -- Vivify healing is increased by 40%.
    inner_peace                 = { 80627, 195243, 1 }, -- Increases maximum Energy by 10.
    invoke_xuen_the_white_tiger = { 80657, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for 24 sec. Xuen attacks your primary target, and strikes 3 enemies within 10 yards every 0.9 sec with Tiger Lightning for 288 Nature damage. Every 4 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing 10% of the damage you have dealt to those targets in the last 4 sec.
    invoke_xuen                 = { 80657, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for 24 sec. Xuen attacks your primary target, and strikes 3 enemies within 10 yards every 0.9 sec with Tiger Lightning for 288 Nature damage. Every 4 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing 10% of the damage you have dealt to those targets in the last 4 sec.
    invokers_delight            = { 80661, 388661, 1 }, -- You gain 33% haste for 20 sec after summoning your Celestial.
    ironshell_brew              = { 80681, 388814, 1 }, -- Increases Armor while Fortifying Brew is active by 25%. Increases Dodge while Fortifying Brew is active by 25%.
    jade_ignition               = { 80607, 392979, 1 }, -- Whenever you deal damage to a target with Fists of Fury, you gain a stack of Chi Energy up to a maximum of 30 stacks. Using Spinning Crane Kick will cause the energy to detonate in a Chi Explosion, dealing 758 Nature damage to all enemies within 8 yards. The damage is increased by 5% for each stack of Chi Energy.
    last_emperors_capacitor     = { 80664, 392989, 1 }, -- Chi spenders increase the damage of your next Crackling Jade Lightning by 100% and reduce its cost by 5%, stacking up to 20 times.
    mark_of_the_crane           = { 80623, 220357, 1 }, -- Spinning Crane Kick's damage is increased by 18% for each unique target you've struck in the last 20 sec with Tiger Palm, Blackout Kick, or Rising Sun Kick. Stacks up to 5 times.
    meridian_strikes            = { 80620, 391330, 1 }, -- When you Combo Strike, the cooldown of Touch of Death is reduced by 0.35 sec. Touch of Death deals an additional 15% damage.
    open_palm_strikes           = { 80678, 392970, 1 }, -- Fists of Fury damage increased by 15%. When Fists of Fury deals damage, it has a 5% chance to refund 1 Chi.
    paralysis                   = { 80688, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    power_strikes               = { 80614, 121817, 1 }, -- Every 15 sec, your next Tiger Palm will generate 1 additional Chi and deal 100% additional damage.
    profound_rebuttal           = { 80708, 392910, 1 }, -- Expel Harm's critical healing is increased by 50%.
    resonant_fists              = { 80702, 389578, 2 }, -- Your attacks have a chance to resonate, dealing 350 Nature damage to enemies within 8 yds.
    ring_of_peace               = { 80698, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    rising_star                 = { 80673, 388849, 2 }, -- Rising Sun Kick damage increased by 10%.
    rising_sun_kick             = { 80690, 107428, 1 }, -- Kick upwards, dealing 4,747 Physical damage, and reducing the effectiveness of healing on the target for 10 sec.
    rushing_jade_wind           = { 80625, 116847, 1 }, -- Summons a whirling tornado around you, causing 1,703 Physical damage over 5.3 sec to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    save_them_all               = { 80714, 389579, 2 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    serenity                    = { 80618, 152173, 1 }, -- Enter an elevated state of mental and physical serenity for 12 sec. While in this state, you deal 20% increased damage and healing, and all Chi consumers are free and cool down 100% more quickly.
    shadowboxing_treads         = { 80624, 392982, 1 }, -- Blackout Kick damage increased by 20% and strikes an additional 2 targets.
    skyreach                    = { 80663, 392991, 1 }, -- Tiger Palm now has a 10 yard range and dashes you to the target when used. Tiger Palm also applies an effect which increases your critical strike chance by 50% for 6 sec on the target. This effect cannot be applied more than once every 1 min per target.
    soothing_mist               = { 80691, 115175, 1 }, -- Heals the target for 5,102 over 7.1 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    spear_hand_strike           = { 80686, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    spiritual_focus             = { 80617, 280197, 1 }, -- Every 2 Chi you spend reduces the cooldown of Storm, Earth, and Fire by 1.0 sec.
    storm_earth_and_fire        = { 80618, 137639, 1 }, -- Split into 3 elemental spirits for 15 sec, each spirit dealing 45% of normal damage and healing. You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies. While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    strength_of_spirit          = { 80682, 387276, 1 }, -- Expel Harm's healing is increased by up to 100%, based on your missing health.
    strike_of_the_windlord      = { 80675, 392983, 1 }, -- Strike with both fists at all enemies in front of you, dealing 6,684 damage and reducing movement speed by 50% for 6 sec.
    summon_black_ox_statue      = { 80716, 115315, 1 }, -- Summons a Black Ox Statue at the target location for 15 min, pulsing threat to all enemies within 20 yards. You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_jade_serpent_statue  = { 80713, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for 2,551 over 7.1 sec.
    summon_white_tiger_statue   = { 80701, 388686, 1 }, -- Summons a White Tiger Statue at the target location for 30 sec, pulsing 313 damage to all enemies every 2 sec for 30 sec.
    teachings_of_the_monastery  = { 80616, 116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to 3. Blackout Kick has a 15% chance to reset the remaining cooldown on Rising Sun Kick.
    thunderfist                 = { 80674, 392985, 1 }, -- Strike of the Windlord grants you a stack of Thunderfist for each enemy struck. Thunderfist discharges upon melee strikes, dealing 4,393 Nature damage.
    tiger_tail_sweep            = { 80604, 264348, 2 }, -- Increases the range of Leg Sweep by 2 yds and reduces its cooldown by 10 sec.
    tigers_lust                 = { 80689, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    touch_of_karma              = { 80610, 122470, 1 }, -- Absorbs all damage taken for 10 sec, up to 50% of your maximum health, and redirects 70% of that amount to the enemy target as Nature damage over 6 sec.
    touch_of_the_tiger          = { 80622, 388856, 2 }, -- Tiger Palm damage increased by 25%.
    transcendence               = { 80694, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    transfer_the_power          = { 80660, 195300, 1 }, -- Blackout Kick and Rising Sun Kick increase damage dealt by your next Fists of Fury by 3%, stacking up to 10 times.
    vigorous_expulsion          = { 80711, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification      = { 80695, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant.
    way_of_the_fae              = { 80605, 392994, 1 }, -- Increases the initial damage of Faeline Stomp by 10.0% per target hit by that damage, up to a maximum of 50.0% additional damage.
    whirling_dragon_punch       = { 80658, 152175, 1 }, -- Performs a devastating whirling upward strike, dealing 2,904 damage to all nearby enemies. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    widening_whirl              = { 80609, 388846, 1 }, -- Spinning Crane Kick radius increased by 15%.
    windwalking                 = { 80699, 157411, 2 }, -- You and your allies within 10 yards have 10% increased movement speed.
    xuens_battlegear            = { 80662, 392993, 1 }, -- Rising Sun Kick critical strikes reduce the cooldown of Fists of Fury by 5.0 sec. When Fists of Fury ends, the critical strike chance of Rising Sun Kick is increased by 50% for 5 sec.
    xuens_bond                  = { 80665, 392986, 1 }, -- Abilities that activate Combo Strikes reduce the cooldown of Invoke Xuen, the White Tiger by 0.1 sec, and Xuen's damage is increased by 10.0%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_tiger         = 3734, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you 20% haste for 8 sec. This effect cannot occur more than once every 30 sec per target.
    disabling_reach     = 3050, -- (201769) Disable now has a 10 yard range.
    grapple_weapon      = 3052, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 6 sec.
    mighty_ox_kick      = 5540, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    perpetual_paralysis = 5448, -- (357495) Paralysis range reduced by 10 yards, but spreads to 2 new enemies when removed.
    pressure_points     = 3744, -- (345829) Killing a player with Touch of Death reduces the remaining cooldown of Touch of Karma by 60 sec.
    reverse_harm        = 852 , -- (342928) Increases the healing done by Expel Harm by 60%, and your Expel Harm now generates 1 additional Chi.
    ride_the_wind       = 77  , -- (201372) Flying Serpent Kick clears all snares from you when used and forms a path of wind in its wake, causing all allies who stand in it to have 30% increased movement speed and to be immune to movement slowing effects.
    tigereye_brew       = 675 , -- (247483) Consumes up to 10 stacks of Tigereye Brew to empower your Physical abilities with wind for 2 sec per stack consumed. Damage of your strikes are reduced, but bypass armor. For each 3 Chi you consume, you gain a stack of Tigereye Brew.
    turbo_fists         = 3745, -- (287681) Fists of Fury now deals full damage to all targets hit, reduces all targets movement speed by 90%, and you Parry all attacks while channelling Fists of Fury.
    wind_waker          = 3737, -- (357633) Your movement enhancing abilities increases Windwalking on allies by 10%, stacking 2 additional times. Movement impairing effects are removed at 3 stacks.
} )


-- Auras
spec:RegisterAuras( {
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
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1,
        copy = 327104
    },
    -- Damage version.
    fae_exposure = {
        id = 395414,
        duration = 10,
        max_stack = 1,
        copy = 356773
    },
    fae_exposure_heal = {
        id = 395413,
        duration = 10,
        max_stack = 1,
        copy = 356774
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
    fury_of_xuen = {
        id = 396167,
        duration = 20,
        max_stack = 67,
        copy = { 396168, 396167, 287062 }
    },
    fury_of_xuen_haste = {
        id = 287063,
        duration = 8,
        max_stack = 1,
        copy = 396168
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
        id = 393050,
        duration = 5,
        max_stack = 1,
        copy = 337482,
        generate = function( t, auraType )
            local lastCast, castTime = action.fists_of_fury.lastCast, action.fists_of_fury.cast

            if query_time - lastCast < castTime + 5 then
                t.count = 1
                t.expires = lastCast + castTime + 5
                t.applied = lastCast + castTime
                t.caster = "player"

                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Taunted. Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=116189
    provoke = {
        id = 116189,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    recently_touched = { -- Fake aura for Forbidden Technique.
        duration = 5,
        max_stack = 1,
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
        max_stack = 1,
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


local application_events = {
    SPELL_AURA_APPLIED      = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REFRESH      = true,
}

local removal_events = {
    SPELL_AURA_REMOVED      = true,
    SPELL_AURA_BROKEN       = true,
    SPELL_AURA_BROKEN_SPELL = true,
}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local bonedust_brew_applied = {}
local bonedust_brew_expires = {}

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

        -- Track Bonedust Brew applications.
        elseif spellID == 325216 then
            if application_events[ subtype ] then
                bonedust_brew_applied[ destGUID ] = GetTime()
                bonedust_brew_expires[ destGUID ] = nil
            elseif removal_events[ subtype ] then
                bonedust_brew_expires[ destGUID ] = nil
                bonedust_brew_expires[ destGUID ] = nil
            end
        end
    elseif death_events[ subtype ] then
        bonedust_brew_applied[ destGUID ] = nil
        bonedust_brew_expires[ destGUID ] = nil
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
            addStack( "the_emperors_capacitor", nil, 1 )
        end
    end
end )


local noop = function () end

-- local reverse_harm_target


-- New Bonedust Brew Stuff
local checker = LRC:GetHarmMaxChecker( 8 )

local valid_brews = {}

local function ValidateBonedustBrews()
    local now = state.now
    checker = checker or LRC:GetHarmMaxChecker( 8 )
    table.wipe( valid_brews )

    for _, plate in ipairs( GetNamePlates() ) do
        local unit = plate.namePlateUnitToken

        if unit and UnitCanAttack( "player", unit ) and ( UnitIsPVP( "player" ) or not UnitIsPlayer( unit ) ) and checker( unit ) then
            local guid = UnitGUID( unit )

            valid_brews[ guid ] = 0

            if bonedust_brew_applied[ guid ] then
                if not bonedust_brew_expires[ guid ] then
                    -- We haven't scraped the aura for the duration yet.
                    local found, _, _, _, _, expires = AuraUtil.FindAuraByName( class.auras.bonedust_brew_debuff.name, unit, "HARMFUL|PLAYER" )

                    if found then
                        bonedust_brew_expires[ guid ] = expires
                        valid_brews[ guid ] = expires
                    end
                else
                    if bonedust_brew_expires[ guid ] > now then
                        valid_brews[ guid ] = bonedust_brew_expires[ guid ]
                    end
                end
            end
        end
    end
end

local GatherBonedustInfo = setfenv( function()
    local targets, bonedusts, aggregate, longest = 0, 0, 0, 0

    for _, expires in pairs( valid_brews ) do
        targets = targets + 1
        local remains = max( 0, expires - query_time )

        if remains > 0 then
            bonedusts = bonedusts + 1
            aggregate = aggregate + remains
            longest = max( longest, remains )
        end
    end

    return targets, bonedusts, aggregate, longest
end, state )

local bdbActions = {}

local SetAction = setfenv( function( name, damage, execution_time, net_chi, net_energy, mastery, p, capped )
    local a = bdbActions[ name ] or {}

    capped = capped or false

    a.damage = damage
    a.execution_time = execution_time
    a.net_chi = net_chi
    a.net_energy = ( capped and net_energy ) or ( net_energy + energy.regen * execution_time )
    a.idps = damage / execution_time
    a.cps = net_chi / execution_time
    a.eps = a.net_energy / execution_time
    a.rdps = a.idps + 0.5 * mastery * a.cps + 0.02 * mastery * ( 1 + p ) * a.eps

    bdbActions[ name ] = a

    return a
end, state )


local lastBonedustZoneTime = 0
local lastBonedustZoneValue = 0

-- Returns cap_energy, tp_fill, bok, break_mastery.
-- TODO: Update for Dragonflight.
local GetBonedustZoneInfo = setfenv( function()
    if query_time == lastBonedustZoneTime then
        return lastBonedustZoneValue
    end

    local targets, bonedusts, aggregate = GatherBonedustInfo()
    lastBonedustZoneTime = query_time

    if targets < 2 or bonedusts < 1 then
        -- Orange
        lastBonedustZoneValue = 0
        return 0
    end

    if aggregate > 0 then
        local length = 60
        local blp = 0.2
        local bb_rate = 1.5 + blp

        -- Bone Marrow Hops
        if conduit.bone_marrow_hops.rank > 0 then
            length = length - 2.5 - ( 2.5 * bb_rate )
        end

        -- Brewmaster Keg Smash
        if spec.brewmaster then
            length = length - ( 60 / length * 8 ) -- 2 Keg Smashes for a hard Cast
            length = length - bb_rate * 4         -- 1 Keg Smash per bountiful minimum (safe)
        end
    end

    -- Math below is credit to Tostad0ra, ported to Lua/WoW by Jeremals (https://wago.io/2rN0fBudK).
    -- https://colab.research.google.com/drive/1IlNnwzigBG_xa0VdXhiofvuy-mgJAhGa?usp=sharing

    local mastery = 1 + stat.mastery_value
    local haste = 1 + stat.haste

    -- Locally defined variables that may change.

    local eps = 0.2 -- Delay when chaining SCKs
    local tiger_palm_AP = 0.41804714952
    local sck_AP = 0.8481600000000001

    local coordinated_offensive_bonus = 1

    if conduit.coordinated_offensive.rank > 0 then
        coordinated_offensive_bonus = 1 + 0.085 + ( 0.009 * ( conduit.coordinated_offensive.rank - 1 ) )
    end

    local calculated_strikes_bonus = 0.16
    if conduit.calculated_strikes.rank > 0 then
        calculated_strikes_bonus = 0.16 + 0.1 + ( 0.01 * ( conduit.calculated_strikes.rank - 1 ) )
    end

    local bone_marrow_hops_bonus = 0
    if conduit.bone_marrow_hops.rank > 0 then
        bone_marrow_hops_bonus = 0.4 + ( 0.04 * ( conduit.bone_marrow_hops.rank - 1 ) )
    end

    -- sqrt scaling
    local N_effective_targets_above = 5 * pow( ( targets / 5 ), 0.5 )
    local N_effective_targets_below = targets
    local N_effective_targets = min( N_effective_targets_below, N_effective_targets_above )


    local mark_stacks = spinning_crane_kick.count
    local mark_bonus_per_target = 0.18 + calculated_strikes_bonus
    local mark_bonus = mark_bonus_per_target * mark_stacks
    local mark_multiplier = 1 + mark_bonus

    local p = tiger_palm_AP / ( ( N_effective_targets * sck_AP * mark_multiplier ) - ( 1.1 / 1.676 * 0.81 / 2.5 * 1.5 ) )

    local amp = 1 + stat.versatility_atk_mod

    if buff.invoke_xuen.up then
        amp = amp * 1.1
    end

    if buff.storm_earth_and_fire.up then
        amp = amp * 1.35 * ( 2 * coordinated_offensive_bonus + 1 ) / 3
    end

    amp = amp * ( 1 + ( 0.5 * 0.4 * ( bonedusts / targets ) * ( 1 + bone_marrow_hops_bonus ) ) )

    local TP_SCK = SetAction( "TP_SCK", amp * mastery * ( 1 + p ), 2, 1, -50, mastery, p )
    local rSCK_cap = SetAction( "rSCK_cap", amp, 1.5 / haste + eps, -1, 0, mastery, p, true )
    local rSCK_unc = SetAction( "rSCK_unc", amp, 1.5 / haste + eps, -1, 0, mastery, p )

    if rSCK_unc.rdps > TP_SCK.rdps then
        local regen = 2 * energy.regen
        local N_oc_expr = ( 1 - 2 * regen ) / ( 1.5 + haste * eps ) / ( regen / haste )
        local w_oc_expr = 1 / ( 1 + N_oc_expr )
        local rdps_nocap = w_oc_expr * TP_SCK.rdps + ( 1 - w_oc_expr ) * rSCK_unc.rdps

        -- Purple
        if rSCK_cap.rdps > rdps_nocap then
            lastBonedustZoneValue = 4
            return 4
        end

        -- Red
        lastBonedustZoneValue = 3
        return 3
    end

    -- Blue
    if rSCK_unc.idps < TP_SCK.idps then
        lastBonedustZoneValue = 1
        return 1
    end

    -- Green
    lastBonedustZoneValue = 2
    return 2
end, state )



spec:RegisterHook( "runHandler", function( key, noStart )
    if combos[ key ] then
        if last_combo == key then removeBuff( "hit_combo" )
        else
            if talent.hit_combo.enabled then addStack( "hit_combo", 10, 1 ) end
            if azerite.fury_of_xuen.enabled or talent.fury_of_xuen.enabled then addStack( "fury_of_xuen", nil, 1 ) end
            if ( talent.xuens_bond.enabled or conduit.xuens_bond.enabled ) and cooldown.invoke_xuen.remains > 0 then reduceCooldown( "invoke_xuen", 0.1 ) end
            if talent.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then reduceCooldown( "touch_of_death", 0.35 ) end
        end
        virtual_combo = key
    end

    lastBonedustZoneTime = 0
end )

spec:RegisterStateExpr( "cap_energy", function()
    return GetBonedustZoneInfo() == 4
end )

spec:RegisterStateExpr( "tp_fill", function()
    return GetBonedustZoneInfo() < 3
end )

spec:RegisterStateExpr( "no_bok", function()
    return GetBonedustZoneInfo() > 0
end )

spec:RegisterStateExpr( "break_mastery", function()
    return GetBonedustZoneInfo() > 1
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

    if not IsUsableSpell( 322109 ) then setCooldown( "touch_of_death", action.touch_of_death.cooldown ) end

    if buff.weapons_of_order_ww.up then
        state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
    end

    -- BDB Logic.
    if talent.bonedust_brew.enabled or state:IsKnown( "bonedust_brew" ) then
        ValidateBonedustBrews()
        lastBonedustZoneTime = 0
    end

    if talent.forbidden_technique.enabled and cooldown.touch_of_death.remains == 0 and query_time - action.touch_of_death.lastCast < 5 then
        applyBuff( "recently_touched", query_time - action.touch_of_death.lastCast )
    end
end )

spec:RegisterHook( "advance", function()
    lastBonedustZoneTime = 0
end )


spec:RegisterHook( "IsUsable", function( spell )
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
                return spinning_crane_kick.count >= min( active_enemies, 5 )

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


spec:RegisterPet( "xuen_the_white_tiger", 63508, "invoke_xuen", 24 )

spec:RegisterTotem( "jade_serpent_statue", 620831 )
spec:RegisterTotem( "white_tiger_statue", 125826 )
spec:RegisterTotem( "black_ox_statue", 627607 )


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

        cycle = "mark_of_the_crane",

        handler = function ()
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
                if talent.transfer_the_power.enabled then addStack( "transfer_the_power", nil, 1 ) end
        end,
    },

    -- Talent / Covenant (Necrolord): Hurl a brew created from the bones of your enemies at the ground, coating all targets struck for $d.  Your abilities have a $h% chance to affect the target a second time at $s1% effectiveness as Shadow damage or healing.    $?s137024[Gust of Mists heals targets with your Bonedust Brew active for an additional $328748s1.]?s137023[Tiger Palm and Keg Smash reduces the cooldown of your brews by an additional $s3 sec when striking enemies with your Bonedust Brew active.]?s137025[Spinning Crane Kick refunds 1 Chi when striking enemies with your Bonedust Brew active.][]
    bonedust_brew = {
        id = function() return talent.bonedust_brew.enabled and 386276 or 325216 end,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "shadow",

        talent = function()
            if covenant.necrolord then return end
            return "bonedust_brew"
        end,
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
        gcd = "totem",
        school = "nature",

        spend = 15,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            removeBuff( "gift_of_the_ox" )
            healing_sphere.count = 0

            gain( pvptalent.reverse_harm.enabled and 2 or 1, "chi" )
        end,
    },

    -- Talent: Strike the ground fiercely to expose a faeline for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the faeline. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the faeline$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].    Your abilities have a $s2% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    faeline_stomp = {
        id = function() return talent.faeline_stomp.enabled and 388193 or 327104 end,
        cast = 0,
        -- charges = 1,
        cooldown = 30,
        -- recharge = 30,
        gcd = "totem",
        school = "nature",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyBuff( "faeline_stomp" )

            if spec.brewmaster then
                applyDebuff( "target", "breath_of_fire" )
                active_dot.breath_of_fire = active_enemies
            end

            if talent.faeline_harmony.enabled or legendary.fae_exposure.enabled then applyDebuff( "target", "fae_exposure" ) end
        end,

        copy = { 388193, 327104 }
    },

    -- Talent: Pummels all targets in front of you, dealing ${5*$s5} Physical damage over $113656d to your primary target and ${5*$s5*$s6/100} damage over $113656d to all other enemies. Deals reduced damage beyond $s1 targets. Can be channeled while moving.
    fists_of_fury = {
        id = 113656,
        cast = 4,
        channeled = true,
        cooldown = function ()
            local x = 24 * haste
            if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
            return x
        end,
        gcd = "totem",
        school = "physical",

        spend = function ()
            if buff.serenity.up then return 0 end
            return weapons_of_order( 3 )
        end,
        spendType = "chi",

        cycle = "mark_of_the_crane",
        aura = "mark_of_the_crane",

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
        gcd = "totem",
        school = "physical",

        talent = "flying_serpent_kick",
        startsCombat = false,

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
        gcd = "totem",
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

    --[[ Deprecated.
    reverse_harm = {
        id = 287771,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 40,
        spendType = "energy",

        pvptalent = function ()
            if essence.conflict_and_strife.major then return end
            return "reverse_harm"
        end,

        startsCombat = true,
        texture = 627486,

        indicator = function ()
            local caption = class.abilities.reverse_harm.caption
            if caption and caption ~= UnitName( "player" ) then return "cycle" end
        end,

        caption = function ()
            if not group or not settings.optimize_reverse_harm then return end
            if reverse_harm_target then return reverse_harm_target end

            local targetName, dmg = UnitName( "player "), -1

            if raid then
                for i = 1, 5 do
                    local unit = "raid" .. i

                    if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                        local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                        local deficit = min( m - h, m * 0.08 )

                        if deficit > dmg then
                            targetName = i < 5 and UnitName( "target" ) or nil
                            dmg = deficit
                        end
                    end
                end

            elseif group then
                for i = 1, 5 do
                    local unit = i < 5 and ( "party" .. i ) or "player"

                    if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                        local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                        local deficit = min( m - h, m * 0.08 )

                        if deficit > dmg then
                            targetName = not UnitIsUnit( "player", unit ) and UnitName( unit ) or nil
                            dmg = deficit
                        end
                    end
                end

            end

            -- Consider using LibGetFrame to highlight a raid frame.
            reverse_harm_target = targetName
            return reverse_harm_target
        end,

        usable = function ()
            if not group and health.deficit / health.max < 0.02 then return false, "solo and health deficit is too low" end
            return true
        end,

        handler = function ()
            health.actual = min( health.max, health.current + 0.08 * health.max )
            gain( 1, "chi" )
        end,
    }, ]]

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
            local x = 10 * haste
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
        cycle = "mark_of_the_crane",

        handler = function ()
            applyDebuff( "target", "mark_of_the_crane" )
            applyDebuff( "target", "rising_sun_kick" )

            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
            end

            if talent.transfer_the_power.enabled then addStack( "transfer_the_power", nil, 1 ) end

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
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power", nil, 1 ) end
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
        gcd = "totem",
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
            if settings.check_sck_range and target.outside8 then return false, "target is outside of melee range" end
            return true
        end,

        handler = function ()
            removeBuff( "chi_energy" )
            removeBuff( "dance_of_chiji" )

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
        gcd = "totem",
        school = "physical",

        spend = 2,
        spendType = "chi",

        talent = "strike_of_the_windlord",
        startsCombat = true,

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
        gcd = "totem",
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
        gcd = "totem",
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
        cycle = function ()
            if legendary.keefers_skyreach.enabled and debuff.skyreach_exhaustion.up and active_dot.skyreach_exhaustion < cycle_enemies then return "skyreach_exhaustion" end
            return "mark_of_the_crane"
        end,

        buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

        handler = function ()
            gain( 2, "chi" )
            applyDebuff( "target", "mark_of_the_crane" )

            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end
            if ( legendary.keefers_skyreach.enabled or talent.skyreach.enabled ) and debuff.skyreach_exhaustion.down then
                if target.distance > 10 then setDistance( 5 ) end
                applyDebuff( "target", "skyreach" )
                applyDebuff( "player", "skyreach_exhaustion" )
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
        cooldown = function () return ( talent.fatal_touch.enabled or legendary.fatal_touch.enabled ) and 60 or 180
        end,
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
            if talent.forbidden_technique.enabled and buff.recently_touched.down then
                setCooldown( "touch_of_death", 0 )
                applyBuff( "recently_touched" )
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
        gcd = "totem",
        school = "physical",

        talent = "whirling_dragon_punch",
        startsCombat = false,

        usable = function ()
            if settings.check_wdp_range and target.outside8 then return false, "target is outside of melee range" end
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
        gcd = "totem",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "zen_flight" )
        end,
    },
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = true,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_agility",

    package = "Windwalker",

    strict = false
} )

spec:RegisterSetting( "allow_fsk", false, {
    name = "Use |T606545:0|t Flying Serpent Kick",
    desc = "If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable).",
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
    name = "Reserve One |T136038:0|t Storm, Earth, and Fire Charge as CD",
    desc = "If checked, |T136038:0|t when Storm, Earth, and Fire's toggle is set to Default, only one charge will be reserved for use with the Cooldowns toggle.",
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "tok_damage", 1, {
    name = "Required Damage for |T651728:0|t Touch of Karma",
    desc = "If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have taken this percentage of your maximum health in damage in the past 3 seconds.",
    type = "range",
    min = 0,
    max = 99,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "check_wdp_range", false, {
    name = "Check |T988194:0|t Whirling Dragon Punch Range",
    desc = "If checked, when your target is outside of |T988194:0|t Whirling Dragon Punch's range, it will not be recommended.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_sck_range", false, {
    name = "Check |T606543:0|t Spinning Crane Kick Range",
    desc = "If checked, when your target is outside of |T606543:0|t Spinning Crane Kick's range, it will not be recommended.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "use_diffuse", false, {
    name = "Use |T775460:0|t Diffuse Magic to Self-Dispel",
    desc = function()
        local t = class.abilities.diffuse_magic.toggle

        if t then
            local active = Hekili.DB.profile.toggles[ t ].value

            return "If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority.\n\n" ..
                "Requires " .. ( active and "|cFF00FF00" or "|cFFFF0000" ) .. t:gsub("^%l", string.upper) .. "|r Toggle"
        end

        return "If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority."
    end,
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Windwalker", 20221109.2, [[Hekili:T3ZApkUXw(BPvKiqMzyWMMzMolG0MSjAt0Ujr3EUA)WQBdgW040gBUgZ0tVQf)23tvLFuv5ZPQYa9KnRYxs6Xpo1PoVFvM78U7J3D7QG8W7(f)b((EEdUPV3iFV7Un)PDH3D7UGLpeCp8hjbBH)7)vuYQhdIFimJDRNItdwXaW(0dzlHBVjpF3(V9TV9(O8nhw0Fz623UpA7H4G8O0KLzbRZz)7LVDrC6I3Ukl4(0K1Xr3Vj)T7YsxhfhU)T)ww4FliAf8h)Tz)NPjpmREj7ZE37UDXHO48Fk5Ufyi(GrxdOZUWLWLF3nagfTAvO4zd3dV8D3ghTpFpdPt3fMa7JpE3VWjcHjblIdxD33D3Tblz4lCPpVlmE2MGSTIxplAN4g)Q4vVfUsEywuaqTcIdtY7VCt0SfhY2N3VaChN354C4Q93g85JZFd)VpoF6KJZhExoGJeRCE09HzZ2feVvEra65I0z7ZZIEiKgWDpo3)48xDC(IdRx3Fx6JaKeVZ((h2DCEpaqpTmoCwEq29HaTa2)aQmudvKww9vbwe)ACLTNFm4tHmGCndiyKVAadp1O2TRVCBYCq2imlmjk)jt8DbGMLUEw(MWzpccGXPzR0KbUTaqhN)BzrPzmqkH0mq9PWzGyY2OW9hNpMGHJZCRrL1bHXrjHW1t3UdJnv(GlIbn10d5ZEiA5dgfA4uS8WaGwMC)(YD520KG9WR8u)95aK4m5H4skxtUh4GUKc3plCBquIyZ7jTLykGSLD9HSNOfhMjS4O(01cDbjlbHRI)jaK3D20fDwgJa0scMpob79oX05Rv3M4XuoE88ZO3XN)w73fLKai3mWgliSW2Q93MUkADuyMqFXV)qUsrLiEZ3GHPFGetBS2c5dlQmaiVX9npY(ZZkk7nWDCwbEpUjklMbpHJOz7oKSCdhIu2fiLLqjocl0PPXRsFmPVICCTQb8ifUo2VjaEWfPFMHs5zHbR2x6ebxQYJ2wYvfcTzh2ZKzN97bRemfUTrmkTk3SX7Xxpktpzr7zp8(djLegmSL2QbUfQvmnCgbdu7(9iaXTljq5xXjBaeO97K9OHlYO6CZtxB3S3TcUVbZlYrs4OPOXu2UbhGlxnZjFGh2cGDgSJZbyWrDa45hcjDd(9fI67L3E7cZ7)5dHjcZc1aRVqc0Slrqm(tbWFb3P)ga4ZyqQs(nnP)I0KWvh2NpBrw4J9FibwDvTo1hO2HeiUpsytDr6EHA4AwCOZK9z5pQMCeL8PuW(gdbmhSenoFLv0UReMRPuP4m1xG61a8XWGDPjC5bWQlqDlGzVZzpsRWc4zgeJ(SWpXeDdwbwQIs4MxVUGQQFBEizQSgtBWWphU8axuzBO6BjHJnePQGWur8Hd4biY(FFd)czhscxNcAdfqjB)SvH80pQ1XyiFHkj9d1RCZ0LZeQHldT2ZnEV)qwOIM7vvWv8qlcYZJdVpmitDXT5WG9mwuQCHVpuIVRl9GftwtFlQcXf(vKLGRIdKDpLTwZiezEMTRqoCa2nyV7ax2ZEIxhswnEbZxym4JD2INMf(5GT7IdR92w53qElIfKPZ250iaUkfZW4cnDfHs83uroYeDqI3x5kO1HP2Kl8UcSLq8Wgwnqja180dl3WejxfgKVXCSPvqffTUzWjV2pa5UgufeB5Txhed8IcDfnN)0bJQMBKdee)bYrWKMUQkHPgbOEPwfWAxy2dGz564llVh3e4(z)(Hv3Vfee1330oeplmADuwiFVBjeYZArybAcY2bXZwcCw0ijVqR0IG75XSLbo82xhEj6cvzMAhOfDacKlm7apMlD3kwn9ug3yfwVQmGdenv29KO)XH73WlCNXqBxfK9W2uiCXvHlFy2NsZcwQvpe5WI4il8Wh2hYifjpeMFI2h9luTBgXvzbljWS6iHxFrccopnB7Rpo)hcYY3arLLamNFeeD)ZyqXDqlcX4QeARQFjrnjM04j9DX58)ViyBf6ZFfy9FfyDBcS2I8QWeoZqZSqMzMzGvMzm)J1MZ76s0ZwndacBQsYxBmSoblqvnemRwP1GwBsw587y04HnSCszTp1mZiidwzKNK7M6eyWydRpehde8LByfCPqdtUIRiVJ5Ckekb0KDAjcRpGsWVE8hMKpviZBfBSk5HN3MPLwtk0U235NIhDsqg39xaFV(LcV4zwP5YcLTkK9eVZa9KUnkhuNe9lPcKhz8AYIzVCl)qPD4ljLCOKftsfuHZojleSSpk6O1mwxQf9QUOpylwTamRMFyNLuHpxVe(d0J3XLaOmtdNufffh9AeavzwuwcWswpQXZCE2PpjXP2VmArQrejcZyWnn8TPS7X6dHka88DY7tl6oN9A(yvUZIqLHOmCZ0VX6hzO2mebDpCavq3efdYuZd)Jmh5ogSOIP8Fc5tBQDKio(hDd9k1GfwvgodLzQ10LHg8fzlxv6kZzQlNF5qq5k8QvuVrTOOE0HM(fDZqwpqtfS(lh(zPuINQVAtvnK2Q9lqvdnAuVDvqKn)v5ZwcrL)Pqt1DtDQN0Q12hRN4kWPYyiwRpkAXDpk3xyfuRw)Ly2aCSv7vzSEQJXHjtAxM5IG2Mu5WhS5qc4(IfosZmKONShQXTO58GOuJdTzSYRERXEAr8qXPpYaX2uMzPdB57smIxRN6l35Q(Nfx99YMzPMNqfRT62jo7TsDlzTVjQYHvFCP0c6GS2IINLy0sPnxHipinzP0tOLEOCNnXY6qpsgxNbPDK6OpPIMELB8f3szyAzr766y1qTxAvcEPAxb1Mot1Who)rvft8qLEqkqALOrS9Onw26HQtvygFM6S0Or0An54qJwiN5YSH(ExMn0gHdsRbGryvSi60G0rh5KjwHnkUUXOwjvIU3YzrOSo4qCowmnkbV8dI(VaQxq6Kzq8lI6ca2I4SWuGJebCVGpfefZddvMRakXZ2WcbJoQgPabdZZzM66ZYGe42RH)VuYOIlmBBW9rlXIcjDhhe1VrzGXS)kM1a0tyMuADu5AbBZGH2LEtBHklHc)QYPk5CSS54YEeBM4ADnFAmdtDmEx1PuYATZWQE04giuNtbmtfZALRyICv8g4WsktP1qxr5objPIAAwNZpsuQ2LajkQELvsN2vJv6J04Q(AJy(vEN9Hg7d2OeyiOymSa(pFMDcMuTr8J8lcgcwFC(bMLv(ueKTkkjGB54xxVg8yZZrBzAYQdr5QwR4xQ)Y6xb88v8gkc3eDDblSALqAiMagB16UJHKONWkKOgz43slsPUGaUt8VZB2IgLx77oefd7VVNXndYlmTcr3Lb)D6AHZZajPQMfDNzDDjZtHsMsLAGxRiSmQmDAcRikLWV4aNziwFt59wKZB0)dGh)O45oo)w2dkev2fh8exy5Xi2mOu9i)7bzqyUpzmolLE4xIeBeViAl8jFMEyX7RM)oqfy()(8YqM0aJKC)tM4hnD7t1eA(nbzo4oInN(9KKAv4m7z40ScuXu(fvNVpTn1FFFyHm33XUlqNsbsA4EwvBvzw6z)KM0xHRJ1Sd1hq26F3J4NbqpQasltOd7L8XZcuU16eez0eKuiqsZbvl18Cu5AzLfydfIMeqsRmn6PVA1toBJuDioIeV948)nrKIYNAWwsqmljlJv05YGXKh2EYqqAOLSy0xOXN06ux0qt5HyeeS(0KVj7GiE9DqmrchbLrSxLgqklHzW1fyonCfVku5SmZ1sornl46ACQ(udLFkddtOYlzOfcfEDk0ERbT0jTfjeefDjABoyw5kJfq(o8Z6RkkR7r2ESBH)Zdr72fUccAh0uoKZU5S)5Haw1(MTk8trll6kB1dEFCWQOaiadwrnwDV(TFmliFdSBs0VrkKOLiAVvqmjrBd41eHN8LYZjQcZ9zb73bC88WTA3NLrrHzVO7JI1U7YGLB4v4lyjCPmyTkROYE5ifrARNqGKPjDIfe)Fn9huQi(WxDAve3q8b4fEMQOHYhlu8sjqxZB6ks7YQrwQ6wyjKhBFjejRa5fPUniR9i6qZvQzZW((wPYVGfh)8A5rloOjNylpOlD051Yd3RKnJx6GC0LVs21L932tQ0RdM1meN1JkJ87u51EkExDQUF0gMCt3YQ0HHXiWSbMgF6cAeI1zZ(S3ic7hnpNRq9uho13xCRigoc6JoprTwyxbRK5ac8ECfbw9jC0WmVy6eWWvJ7(9VXPcY)bLWlDPjJgMCa7ENMOysJaP8hOezSH(d5tFk2AL2SFRBTV1k6)l(gpZjNAVh8PSw4uhu8h1slP5sz9yi2sGAU8H4kKLptqmYSEzjlbvdvDqClC7UWmwO5ld2XMiS0SsdzSQnlgMrr5v6ZQKgeG9mE5hMQFKuEtzTlS3HVgVBvziTJrvnl1qf7hRBpQrhcu6Pb9ePwbibfNC(wrAVrHhySW1lzF4FwjWdKc315L77RuB(isXltv92qnfwJ5a3UYD1H8mvvoTJTTyysQoYjkROEsKOmLZuhzINgRQM)ByyZUeXPZ20fA516ASjR7nCX4VPj90kI1qp1K5aTzdGEwj8DDSwg763XNPQN6XQ2izFjM66smwFjUMq8DCLGpMj3XhLpqMKSnp0ZSd8YV3QdzQUB8IkKJlbBiChl2JcYwY2tGCzgBYyRsvlkbaaBMkV7w5VPzXpX5UHz7GNUWjUMVyLMmCkF1b)HIwM8dfTmX2MPu3HqkqF2Uq9awOPqaIRDvW1R)O24Uu(O8r30N620YMi4y4EQxUX5mviO0AFP2sOr6JUub94Iir)NB2hQ(yU85yYGkG6PYtRbVf3748VdU5X53YbMe7YTttOjXaNsCGdV6MtHFKCmMVQ7Fp1mASSkZmx(wnEjSft8vo8eghyNY5eF54ctFc0UzRH0NawiZOGmg7F)D3(rwV)J2UlL18)1SHR6Rl1s(Aw7zfvQNDCrzPpeCipDRyelwUji5Eqp84p)FW7CRN33YgcJey943)RPlrXxl69RHNOuOaEYUEFUx9I8E8fH2YJ2Az)Bix9sE8NriosD1SD0NR1WC6piaLOS9pza6Kh91G4JjGgn5uHo18X2e)XNFwBWNyiD1WEQz4vh6J0Go15FUe82oF06W)DMO9OdChkBW4ic2qDqFrjpAln2vuN9fxe)x)xs()zsYNui5cj57DZxAPWQzDODcI(Fb8qrWkL6LMgSr6YMng4lbE)HVaRXxMqeiwKlKYudWF5SfGkQxm18TtqF4Fa(IiwtPGLuyOAfkwhAeX5DIqtx4MCqoBY0iMItBRqbIraE876Si35rm8Omd2wWHkVgK2sJYeYn)z1G5zH3Ed(cG4ncA8YUiOsfL9yRDIgxk5EuuQQilTdNiuEqlTHgcAS8hQyl7aov8Z9I40oTnAV4yoS)WoPDX9SQwfTewhXGYb458JZ)PCXlXhGZTHGuhGP5ByJ6FXrQAx1OWfLSm(WkwDecJal9zFlGaSkz8FZhx7FkpC7()XRpohW9LBKF6GKNQx1JZtsza)Z7IJwgLhxd3vS)6O4eguUO)lhNd4EXY8XYpChE)JJIpkK1xYxALFmkowAhvaY8YhLtn4xk5W2fHcEzCAoqp)joBNDb2xXlrfxooN)tCdCx2CUYPZLfJzF)QbF9vtEl1OUE8NXE66HCf)(KJ3k(JxxL7xhTEYYnrJlR1e6Jx1Pn2tFvrJuXgCEY3M1no87woCQVMnJMtqgrZxNUBcOo9A(SRoXHrx95NjhBvPBvpYQsxKCCvLEMgJQQ090gtvP7yyevzkMF1X5T(0jwrpN040jwDlGaRCAdzmqSdNO8lOYrQoMyQ8HRShp3Zp3Mdh4uLMD98Zk)Z30gin2ZFqNUD1mE3rbGtjRCFhY7m1BqVNFUBBpZFJvw4oT91N6nY(QwCG6MmWc4lPqkOuVEw4(7dxRY8jp7Fww(c0CSFhMjNHp)msVLkrXpWvkA)XXtEVy4y)XT75YP1RdvhnyON4yYjVKIdkhd6D1pQifBxIJPxVoSdONQu64jVBaFDC7C1jJh6hhdb7uCi4ET4eGmXJHMCr0R5mKrDUstPrSjpVZ(MmwP4ZqWcQ7brNUKjh98Z4j20JJGOhQn7ed5wcZDSH2PZoxHDMRkUQ8bXKHjUFs0uqpz3R0Ex7y(iP1PBHp83a))Pt86O2oNjEG9y5hWx7bGR0dFZY3AvNHm7ewrPCvKYAky5eqepSQ8kIeQ5Z4L91cDHAYGTbgidvfiOtFhAhev1F0aGg7aCktlQi2ctNsL6WYa8FIrnuLhLzFTPPXgk14NHaDzVHnaDo2a1kjaiL0RvGHMFech6doUbXnuOST1G8iC3ifdEmiA03xFTv6d(RvAcRKaQTjJyYWo05y7421b(55W(ovU1OlofdyIDT9mcQQ)ZpRPuoQxli0OBrh5g2f(0bKYOLGqiBOVC2eYcrpD42yUSRD7Inq3w1RpB8S5AmzulyJUOV0vFbEVUOZK3zX4GF)MVJndk(9VPNBkLNYMQbrZOi3jScTMtB6LBPyxJxxDeA0xDh1TfXXJn(u1aOQYHtu0V5jTJNfshEOCxJaI2s0QI93ITj5fWcLPXsWr2r4WQEMOCbmsHXEzqnDjA)coMd)4YuJaIaFNqwmo2QA7t)PgWGTIHsEWfKB(vtTJagyFNN7qK7EvgNJ0TynEOGVnu3geCjXD87bP22m5v)rxMnZvg2nDTnI3Jbp1Laa)OF0Ry7HGS6Vadd7288mm96rp)CZpt196yf5KpcnDAtnUM21FWR8h8nDPhOLQCM1VrVED6EfvZJRmdO32APQ5HoQQp)SfjBCHKHycjyLiPmUfcbbZhKbiSoKLEGnLHRlmVIwOkwraA8dVciSrzPgr5XIQOFP6vNUwOTTSuRTTgK9q4rn8q1LO(jMk6LHBwvmxpQkWXklk1AIYTvRaS3akaxW1XfyzVgXymHqLWZoVYrvDGin2cNHjC)oDv3QVBqh3kG80bsssMylSAHFPLk9GfVP5Fgx(sVqd7D5PhdTuE3Eykrug6obRz(dQD0z2tPXoi4xSnq(zcr4)N0pAhRhpHwB3PL812cEjh0OU0gp5MclWs7nt)4FmEINpgBw9NdJMPiQRTAsusiayGtt4SIYAgg(k)ZQbdBrc5z4aSqEqGfRjJaRARWYh(VGfQr(H0d4wki4pOJTFXn46li)EdyG5X)HWGHQA(rgDJJqQ(xRcHiql2rdrXw8WUhGT0v)ou8sU0EybZP9ZCbM4wuXVReVO4ggzr9xmIxYLhNRi)BlHD7(yKUQ5cHxKaQPFUZvw8GAl(zetkcmsR)lujflU)LmZybepTmkpJyRg5wQUNd25Mx8tpF3wUd(RKG)YNeCfXVrwwezlifDN8ah08Q1ETWXKMzjDUPbvTxQ6YQDD9w6VNL5GtdKeHpRV6RkhFpDCwlYnBvruCN(BcdIZ3mfY6s5cJf)pTzBcI3tpgmQL31ah1fpCm0VMlBvip83xB5UzqBHRCCLKs8kbjP3eE38TwdmLWEotGzoqM6nPC0mN5s2m(KZeGerCCYW7ch)rjEyoMdCu5pMenWd9xm7AvZGrjcxovgtO(QpvXryli1hrPPE30P53uGPYUrFJNv3UkpFHDdZR61yEzkfrQBBAXDKOKu1daEjJrQOzOC8OEnjLVQvDoIO35Y9tQR)R4pL(3ec81UXGulnawOVGYSEzzGT6GeLftIZ2yCrUWQtH9PrcDJyzjFcuKWH2cla7sTpzoqEyVz03OsgSLqJ1aPN6BP6qt9LeXPITDOnGiAH2q7GAQnqv0NURvKpgdsrnTvmM3XousPNwaGJF)xgbg0vr9ZaKJAyiFnGED13ni27Wno)R8jHTgaIjJDIQ(CHjTkD2QzcwbngQdLxw6t1AuQrRrxK1)RE269v7rwhXpTkb0y6l7xxfaYHdtvhwAqh7RefPtJOOsmLTzqieUcBXWnPe8N2OwPgxtvmYOV8sw4ELTlQyooXNJMtEVP5IzOJBwF0L2fd26J)uZPiW36KmnSh(Y7Oy0ucELlOVgKW5BO9eabpWFBRmWg7glocCAa2KqGwoEunBKnouDDQPAjhHJxgM)02qzTA4aLZI(KMTHwo0RK6zUPhYmiwCwXK)y0jHqshPHjMInTtxKOc8muWiwDfrELRTfuIx)rUKjaBghWlTvzjnK(kZvCPgFJvuCtktkSYFCK635eCC))9O0LUQP)PCwIkwEEeC9Gbu9cUO)5ez3XjyxEHVi2rKHhPNgttZUmeCyCe1Cn7jWq2tl41n)vz(fLQ73EQokv6fcjz18MgbB432H8R8We7D37UsmsxYDAZWnBNCvxDbR6ALJq5SntetVUIU3S5iu9tHGYsfCBBOEMIU13ArWSSzjO5Nv8suYjN8P9Ori2ad2we1VNGJ4EqB2uqUiKUlGmXD3gCiFtA2D3EB02VN)HR8U)3p]] )