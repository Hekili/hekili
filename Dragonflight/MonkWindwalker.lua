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
    dampen_harm                 = { 80704, 122278, 1 }, -- Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    dance_of_the_wind           = { 80704, 414132, 1 }, -- Your dodge chance is increased by 10%.
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
    dance_of_chiji              = { 80626, 325201, 1 }, -- Spending Chi has a chance to make your next Spinning Crane Kick free and deal an additional 200% damage.
    detox                       = { 80606, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    drinking_horn_cover         = { 80619, 391370, 1 }, -- The duration of Serenity is extended by 0.3 sec every time you cast a Chi spender.
    dust_in_the_wind            = { 80670, 394093, 1 }, -- Bonedust Brew's radius increased by 50%.
    empowered_tiger_lightning   = { 80659, 323999, 1 }, -- Xuen strikes your enemies with Empowered Tiger Lightning every 4 sec, dealing 10% of the damage you and your summons have dealt to those targets in the last 4 sec.
    faeline_harmony             = { 80671, 391412, 1 }, -- Your abilities reset Faeline Stomp 100% more often. Enemies and allies hit by Faeline Stomp are affected by Fae Exposure, increasing your damage and healing against them by 12% for 10 sec.
    faeline_stomp               = { 80672, 388193, 1 }, -- Strike the ground fiercely to expose a faeline for 30 sec, dealing 631 Nature damage to up to 5 enemies, and restores 1,327 health to up to 5 allies within 30 yds caught in the faeline. Up to 5 enemies caught in the faeline suffer an additional 1,026 damage. Your abilities have a 6% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
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
    last_emperors_capacitor     = { 80664, 392989, 1 }, -- Chi spenders increase the damage of your next Crackling Jade Lightning by 100% and reduce its cost by 5%, stacking up to 20 times.
    mark_of_the_crane           = { 80623, 220357, 1 }, -- Spinning Crane Kick's damage is increased by 18% for each unique target you've struck in the last 20 sec with Tiger Palm, Blackout Kick, or Rising Sun Kick. Stacks up to 5 times.
    meridian_strikes            = { 80620, 391330, 1 }, -- When you Combo Strike, the cooldown of Touch of Death is reduced by 0.35 sec. Touch of Death deals an additional 15% damage.
    open_palm_strikes           = { 80678, 392970, 1 }, -- Fists of Fury damage increased by 15%. When Fists of Fury deals damage, it has a 5% chance to refund 1 Chi.
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
    way_of_the_fae              = { 80605, 392994, 1 }, -- Increases the initial damage of Faeline Stomp by 10% per target hit by that damage, up to a maximum of 50% additional damage.
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
        copy = { 356773, "fae_exposure_damage" }
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
    faeline_stomp = {
        id = function() return talent.faeline_stomp.enabled and 388193 or 327104 end,
        cast = 0,
        -- charges = 1,
        cooldown = function() return state.spec.mistweaver and 10 or 30 end,
        -- recharge = 30,
        gcd = "spell",
        school = "nature",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        cycle = function() if talent.faeline_harmony.enabled then return "fae_exposure_damage" end end,

        handler = function ()
            applyBuff( "faeline_stomp" )

            if spec.brewmaster then
                applyDebuff( "target", "breath_of_fire" )
                active_dot.breath_of_fire = active_enemies
            end

            if spec.mistweaver then
                if talent.ancient_concordance.enabled then applyBuff( "ancient_concordance" ) end
                if talent.ancient_teachings.enabled then applyBuff( "ancient_teachings" ) end
                if talent.awakened_faeline.enabled then applyBuff( "awakened_faeline" ) end
            end

            if talent.faeline_harmony.enabled or legendary.fae_exposure.enabled then applyDebuff( "target", "fae_exposure" ) end
        end,

        copy = { 388193, 327104 }
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


spec:RegisterPack( "Windwalker", 20231221, [[Hekili:S3ZAZTnYr(BXF4ujLettsj5hjYQQSoRV7YD7EBTYPUVjqqYHIWIeGbau2ART4V9BEGhZa09m9aakBNZ1wLxjrWz63VMEAC7KB)WT3SmmND7ppD80ZNmD6KrJF9KxDXKBVj)XDSBVzx4I7dVJ)dXHB5)7)Bu8YpfU5EwQ4JECts4sXsKLSpDb)JxNNVl7p)IxCxu(69ZhTiz7lYI2UFtyEus8I0Wv5IFFXlMVjz(lwMgExs8Qnr3To)f7stwfTHL9IFjL9RHrl5)WVg8tjX3huVLJeF3BVz((On5)NX3ohg05qZo2c(F9LVHdqrlxYupklJ)Dfp6ZNm55to)WStomB60)YHztMY)1)8Hz3eT9WS97eRz2Od)9d)9YhE8R4F673NMVMLYF8XJMI8CxYFUFjmFXA1tv)HJFTAr(v2)CFukJVx3)yklCX6xW)H8K9IVXQe(INhMEhl)WSfpUytu8DMRWufq(UQD)WSTjz5BE8WSug)Z(PW07pmlzfFzwZ3J3LggZ)FHXlR3pB7WRk2H80O7zARJGbSjjLVkHl)4(SCg)NIIpmlJ)13WEUAb1wNx(8PxWxNdZ(WVO)vK4xCs8ZBH7AF3lF(0xl)U)uuS45BrMfpHA1V5D)x)jof9gX)kXX3N8E(xiJlTw(9m(AtEL(cZrY47z5)PAst5YCZhomBxAusAuUKW(qugx41eeKeQdZ(hYDPa14C8jAp0fLB4h4SHSnYNtU(PSOT72W2YI5CH3hLLNPO1CbShlG)xSimEbBJsT5WSL75a7DCiJLYI5qL5UCPjOKMSvkLuO09oHsN2x48Npv9f(Rsgdh8usFci4VXcZ1zgtF(0jYNvi4Yjd8Lpp5WmwC2EHmClyps8BXcXX5Pj3Z4q(Nwl(3s4w9eHlYJEGzUnJvSMWpkiKlwhgFNq4wSzHCZdIfIBq5WmbvuaZnqVA(LbIowjjvc6)uyC0IdZ(3tJyRYtsfiTKy)xecPlzsoJu7uXzYxhMxRTiaC2N52vKIYcaBdhj4)BchutLpDCH6YIqbiMhTTGCLYwUFb)NtJYk0o3fMMhfUr9OJU9MnccPWmAYowm3Y6hU9NLgMzXHZ3WwE7pOSELgTtGY3EZ)J6XUrqjf)E2(TBtId(06OCwqEehGcYYdZ3ZUnNBgSXkXxMCwAui3aF4goMoAX6OG57t5qsXtjTmY)RJ2g(5dZEU8Npm763Ey2517PGySjyDy6wXMCo6MSKnF)QvJwfYc4FLeHKtWYWTC6(ioLomkMtyVIBiwUPpJlRRE(ScLs(xADixoLVNJ2VRE75Rh36fJJNjB3jGGl6mAEyMnm7s01TffIVmtRxgX(9PWhK8GxkweG1xBH5p1RSTvCga3edoRPXolX0Bf)3nzfAFbNNdjzbtrnf4QvG5Un)GuLiRdm5jqYJL7)8n8ins2NhCF0I71x8mwEW8K49zJYJyPNpjy6Ufk6qY25jC4v5UI)hKar16WTZgZnmVqQplfEeU84kifW)ppbsYTeCuQr7c3SvhwCjGEy2FGZkg3c8G3BCzwyuBPWRqqYQaoh(JrYTJ)rz7IIJ5(hcwi83ljFkXdLcLDIIAfaOWAwxAV(qkgvpUeOfqj3AyWNkIDaqHKhHy8sw6QOgQKsaEr4Mnb5jblt2gflq7sy1c5Vsu7A0fP4rGzhV8yHreH5lVegUAAxWPgZGOy8Am7ecNvcIXkUpFGV6nrXCWiD)oUPNj6qLeiIIFGhzqAwWsMmUFX2Z3S3qzZcurfbdUtgtxz64OXi)GsNnYf(HK0C2NlffCQrnPPP5oIc9b(3XJ3DKHGv)rlVT43cBlzkCOlt6CzxsKfr3jyg15HGjGVS9XT2tVw)MgU786dXmgRm)cUXygDTSXES6nna6Td(PwcqBcMzS(yEfbrAA7YLPXJGJv3Qfy28ORwqN1o1dRJ9h1MIfJjDutcb5cVL8LpRu4GNLdpJjw6JJ453imnPc8feJ92QtHuw26WLjFAEYNf4vo3H9YmZmgCgw3umZpOs6qlcTGdDZlUup3dEkIPIQ(eOQ9wWU9Xlw3inKP4Mbkfns3Nj4lbFmCPcpmKkA9PYvTxrXGqJWIrbo49sZi4svTcd1Te4vYChbGo9mVYgGmVMuM5vxSlxQy7osuOu0A4fReTmZTB0LWjL5WCs1AafvYfeYdbV0dNwf3sj(wZG)9Fx)dvvHS6dpJa5QWhbSUOM8xhsZZTq3BLjIt45nZ(grNdizok(EPWYGn4bKRLlRBndWbiTi)1kSeTcEeeFnK9QB6BZGlid)eHqrUQUHcFskZsGyoJiPo1LgYjOj740SIxjJHLnvhHAlkQTsM6OtrnsbVh0tSGIi5)3lQjvi2Ru7Aw2d3L1WSqiqzV1NGW7bNWzAEUu(7V5Pwjdsx7ASjs2wdHwYF2wbCJNe1XCYdu5J5vu542JoIX1cgqJic0LbLrbcfzlsiSVljzdp3kDrePuK6xcehdM6WWcunBqv8Z5QdR1rWPpteoMAhkuid(8EwSs4R(SXQfLfbbk27h4XjeZ2gXuI3xO(e)wlHpXXQV48Kmv8SReMccQd5qe22ynzdBhBhEyTC08Hq(pX)KrR5GOeWK7xHGaxzHTKR2gmpL9Pg5UwGsMpIbeoPyPKhQV4umLk5rmjko9YcuuzBkjz5g(QinhzfZfFZAexJGAp(4tDcivyeysjtlJLVb8iokTItP5uPT2cbSr5tgfLnkmBnRsZGTDo3WEY(nL2LnFwXbtZsNhMEFgNyYneSU1Zn1J1Ck2Akq2tPcOYSBCcMNbGrv0tdLKtPIngBmkU0EJNcSXNHkWG7hTTC3lRyZuCUPKzeybLNwghSg6yry8K2wAmTW2afX9rJfVHcSRIBWqbViCHtHaXYVPfGxOUuOV1MaF(ymnSXssd83AIMDqdy1EMDvg(YEmErLlOsKZoPbXOzDvcwkKgfUHxNKghSi5bU9DDRNaO4KXvK9UViJvYqN1CPS53PAjriV6PNv6O2AAT6Ev6aX1BNLnGza04Atbwsl8FSsSdKu)MXgMv0PmyvJxwAiHLULIMJIum7gQwLsysVyRzHBYxpAX(u(tKl5uQ)KMxvvhlgSvgowwapM)5Q)IQiv1RjLNgWWMxFTRHDaFwzb0a9n)YXgMqnuVdk(JeIyyIIz55H9cZ0DUvam87dt3g6OuaT53Ucds3UNi(jv(K2ZSVF7cNbZsfMKQtdV8ZK6WzbFC)Y7ePv2iLJw5cpqq0QOuMe3DKuCV2erkzCDZWnbIumCK3BV2P5H3jJekLNBxMk9OLSvH73K7OU)gNsrR2OWIHgztFvvwFDJKnkKKz9FByP2OIgwFs484B(vugD9k9sJ8eRpGdRz5v2QDt0cF3n(x4zLmkvyHRQV(AfIhc17e3atTaa1EOuvKbrDwymrNaheMMMCNEDLDuu3Yt6OuchmNqsoyVw1EBWrDCzPBHHOcZtgB4ufh9hUT88ll3secgLsB57P9G07byLu2zHbDw7jCdUoLVRxBGZJX9Xgd3(luyoxPY06e9e5SE8oxxfVtngPFgpGPzAwJxRjIqeONOJHUopkTSb948OWOSELeRvglE5qH2BdtHf9TSY8PVh1bEqEeDYy2x3T3ahX1zV27UmZx8qKu5TbKt1dyRf1ZmGnhUqCHq0Qo(f6auJJfXeCSAPbwU9whffNqCCMLLulCjnPC9wK32HrqxqBkzBzxB)O4TD(fLiICVe3bK7Eu9hgJHA46Ueb1ZDN9ePJc2NoqZIFXN1Xd9YYXN4IhtwF3bJTvhP1uUfQKD0A83KLrRIexdj5nbz0RCtomsdK05pHhxtF6kmAhjkovvlzl7xVLVNSLrYwA3Jh7zB5NUzpdn17gNSco7uBkr5o5myGG31YulvlBgFrlsgwVIJ2WfeLMQA(m3nmlmGHDpBCDZsacihnUik2wTKtc9oR2rG5onQ7uNW72e3nBXsOPw0DjviwcmeRhrfwuHGBoMT(H52q8TzjOQPcMvxY)(VIU5aKwWhTxQqTL6ZvEPZWT(PY4wtXW3S1q)WpTIx6BWwUYiX)uCoQjv0BwIr(6KU)k2mAAnAo3bKP1z1c0wrrkbXRvNTkim2bZrUahv3iDsDLuWOpy32LotFSxvd3fbVaEVOuxttDlpjDBalmnFDqy8YaXXbz4z6zU6KPclJNAPW2NHQnIE7CO3iQUSa7595ziZFYFKHIrqftb5(WHGVO3MA7sKNcezsPW0LgaSvXiLzBK15cJ1PTSdigPFFEctycRV2Y3K2L65VM8JhM9FlwQ2vMXv5INypZnOuE0XBWBtPdp0aPODKsvekkCAv6XJZFP7qHwaZqrXkaXMnvQtahtv2vArEFH7R0NHIf2s(z0TPGBSGOjhyBk96kewZYOficPN3uF0ZeehufgNIx4vcEOgWkYhbzacaJAobA08lrz5dfYaZmTCKr034(Zl9FKk00IexE9LWqNh3vMbBmlaTX2snVdZFbpw9VLNSnGUFk6Wn8CtbfOjggYxRZ8HJM7tWuG92QUtDC0uEhEDCBdocFUgKy5h4ctXSMnSZGlqvJ3kRzcP8ehMe2WmD13Y52kKZQyymR2miQ6Tfpkj8blP4wAqAZO8HOuTSwJbIHHt5DvUCtOphtN(RKbwX8LZd42g40glz2swOGK1CS8LAEGL)qrEwhM9d8eTeZu0CLPylzaBjfKfLZnrT8YADpu8B2acvUbG50ynVcScgyrE6TDdOWolydGkv9QApDyUuHuDM32OmpwHvyGbl)vFagiZPt7hCPxaPHP6rhNchPKnFYMXluQPdMIO9lLpmoCSuViA(DilTaTMNXsqOuyEUQcgGT7PozOhJrTjmnAGQz0GsCOuMimr8EN(coCL79C4en1dC80NrcJnh4Ev8v3cKO9saD5eO91qbJABnGLoer)xiRA)p2lckciZFfI5Wy7spuE9AnnHzv13Y9xB4TpIG5elQtXLBOtohrRxvdthvgkcIwH4H863o5KtXmC87)(ZGQBWV)7f449m2kX3OAyRvSONrXQeW0YHw(K9M75M(6XSQX5UHB7YnCG5IGKgmIkYxJ1XYnyRQkv5crQgb(vJPN8mVRYm4IbiVGlg8H0pPiR)Aj7aTkaCCod8Ns)kDIIq0JWafmzhokzxXtITKKcXVBSJJ4nUSxgU9XcZqMCP3L)K(bG6IC6zEd03yNSsDJdkEOVd7(o0eGWjh0iWxWwHdHu1HeiSad0ve7Ybc7XQJB2DaLaCZH9(Wsiu7IA1IJ7XdJqz)YCiWdU3iRrj3h2dczR3bppqIKOHy7TcpmIoaZZF6Q5wUMKulqKBcM3fdHyfmiK6YqCPiiETjhkXlVV)cTg2)gr2jbNUCIS9kokekj6C)6RS8cdty9pXWRpMzgEKs2AyA44oLgLh555ulZEogGves(jcq8F9AL4JA(FEzwOcdoc9RCVSx5JfKJzEFUGUJvqndscFe0jh4gw27qLgkKbMBA5wSsFJhaMPh1ORJ4pcZ0nO1HMjEyYwUdnnJhR(X4i2Rzdh30ub98zRlMDoOUCfBJ1eyFYoBEWSkhcghmzR)ZKhNAx(N6iaBV)DX8xYCkHZK4P(LtfOkLLUF(RKRRQ7qVGJs2NUF2BlLqlcTdHWTu0R9oxB8a26bNcTtLjf7kmn6CsZMPVC5AxoiPM(9bjLvQNrXfMsDqs9n4mtX7QesKm27jOK31qKqicqUuTmNSoANcsFMtw(mESEIAViyYkLQpr9yt6wrt6AmTwRqGhAAaZz2UmmPOJWD(Kzf)rfISj5tINCBIG3UFRK7khpBiPd65i41Z83huXuNsJUNTS(osI8UL7PBDfR3J9o8tioREoQlimGJjLDEdhLx518yY7Bzlee5DXkDXokKdEcNZwVX7yN9okxxiT7jzvhmd9mAKWtCz9T9WVr4znlyEyE(g2DSWuh1lW7Xoq7GGDYIjGfvbqQS806yteYsGPXxnNClBxrQZiQbjNkl5uJGiGv9WkIrEaatV4J(KYmjbbK103mOBwNoTm4S3eThHm4(AlRSlOMvMhXqy7eY6F8fhJr)lSGg13WVEK0JRqib1ShKdrWBfrYos86WxGboxtXYUBVJq9y9UqAy1DFyhLTKCWDnADz9FGir0isVRjrxYVIUC()QpnEPeYeUWIZrw6yNQl(NowpopgxV038pzYJA(uwWzcbbO4pvcpQqWpRx22g(K1CM3I)hljumEECGJDMY6K65)zs6m616ypHc80i0SF8ZSf7ZfUzzpWe3suXRpt()UMjpgReEq8rCCl8HWOnIvyKo(WtrJBdjEzjSaeCxYoPD16Vv5R1vXpTzptpDsYVHzjvr2L7tdfBPKtyukwjqu8sDV6TVluuFKaEkLu7Qs)bU9eCLMRditykkGaGACS0Q8hBGz57csZa7EWJiUnh515E5d2e4FRS7VAd5Zxo3wyU7su)Fd55FP4p2Wwt73MMY)k8iVrcK7yQ6r0sUsb9oEtyiSCngkIyZPi0(OnCr63jmxeMxO1XT9LY)5KvQOpd1yrYour9lbBImN2kk92RmMq3v(zEgb85e973t7x1GI9RG)KSt43ckKAdS7FKXx1pOENQZPjNEZp((ZSHlcJilYBK1lrqkJTs8kpvUvvHBdAzhD102ECy0yll6fA99fDIvy2q0ELNFbexUeIG2sInpUzITv0KMklPrj89n634B07vl)Hz3iarUvFU83UnHpYTsDyM41MV2J8FOab7zaym(QaKm4A38)HXZBti0xyHHVVXcvaDccK5IsXvkgOu2sDk)B4yX(z8DM1mmOwqNY01A(c6UmOqrAxJRdL2D4sxb1LjLwdAp7VovM3WFSm1WKpXHA13jtckNPLbJpEOTAiPAw5BSUTB6OtA8XTB7izBjjn6DD176vNm5Z06yjZ3a)kpLLOCtzURRkD2ZSFhinAxkKNaXfijNON1qv6d)cF3somloH7Z4tc5HsbiW8uhkz0Vlr(DjslsKcNhsjYeEsflc3Tt6frgNJiJIpKK)tG1DOYXBvcWaooKlZpi(uLOFkJhhBthyaU8nFJ7QJ71z2b)s5vXbafzXJOTkvqSPUyloQ6toRHOgIFFWQKaqSkqTSJvKxl4z)Xw5OmkdwqxYDtTiGfAb5MMveOZJEteWn(1QOqakOxahWy57Rd7f3PhB9vYT2xAR54GeQUooaoykqNbdXDmeQupEcfVTFqXf5okvevG48EaeNNdwPi)bIP9aiMQacQdJhCGyspacLKzRte3qV)VPQ9vpu7DQlxE0UfYOwol9HrCu7OKZboUCRBxhe80Ej2MdC(6w3UoiIP1QZ5wp69HryQC7kKLmoAUS9B5Ez1JuJ)yH5I6Hvdr5a95oPDEf)dZxNUxvJ2cxNUkr7nIQu9Nom7hf1PIRqfZdA59rPuDUBOfzwLeCvzhHTsHELB7Ys3kyxXMjTx0OsAIUzZycmJhbRRavffL7sSWPRZuPmiTZHR0Q2D5qlCUZCupqbwut00sAbQ0S6XnjskBKiPc5ntlIPtrAtQMu8IgOivgfREu(KrrzJcZwZQYuJTDolnlz)MQGnnEwr9EyPZdtVpJtedJffMPXZn1J1Ck2AwK5fnavMgJtW8mamQUQ76N36PuXgJngfxAVXtb24ZqLcWTP3wy6LvSzkfat1JqE1(VAOt9zs3Am7bh655OOiUFeNk3NAv568X0Say((R8TYFT60aG7CVNzVvJSyEWfWuLiyddjN0H6vs9QjO1Gbah9XQ9CNhPSfRfMDcuLYq)amb(oqNcqnB1AFrEcHtHb)bmQRTklCu(u9BOt7qJtbmalUJTV1ne2C7NyYy9csHwnkTA60RlLjK87f4OKzNDQtzDkV6GkHaiNHDIc52oKhRSzN2AOR5EkKirTXz7ABk1m13zCd9z7I8fYDhzBfLsIqbQDMUq6rA7pxddpMuYZ18bGAlsvMwRNFPwG21V5AYTDbLSfUyTzaI4ET7eFP0DWPG5gH1VXCq6nT8WP)fHFTLySatM62bKLHZIZIJ7HgeG1)lnXhYeWR8LnrWnm(bsk8oiyplzH5RVf5SMVLwNo2ArVpmDBOLWv5KP3mM4HHGzUXLpZxIa84jGcXlFdgaGI15a1GxN66dh(AvugDKemvR9bL1hw1345wll)tjaorl)xrMvS075k(1fXV8ZKdFKSGpUF5DIU5UrzxS2mKpHiJg1wO(jP4okz(tj8PlniU9eCn8WnbcxwKQOoKvmbORXbdVtMOCkpeUSBnNnGvvyYYLEzDsASybEiCtsk6X2u28qEuzQQK2888HT793b5w1Qx4vtRk5vvu7G10zI8GVxeYDqP7JTv1r2gghTi4U0i2ko0cwyM1Hzb7ZybcCQypnQEHZLysJLqZ5tZVR9Y8r1ZQN8RQ8B6fxtVICHB48eUdAEei)2VX9Jmp5ZqvMRYnGIszCMbOupfO2IrAOc0GnHWPB)maW9b9RRv7A2OfyVDj6BY2KKRHQaLOYg5WM80xikYP(g011Q0s5bMw(9om7FROkRIDU1hkcyTi9pmR2(lQ3jwf2nXQ4zMck5200rB(0ux8jedmTFMNmj3PqLOYg5WMX0VquK)FIK7u7v15BmsqTuMq(H)XBlJukpGNRs4dwhHYnV9hwAspInJ3B95o1zgr2hQplDUW4vNxDFEpZEGpeVqVA52s76426Gd640CUddBtvyla9jNe1epDxMolW5V2TbecjjHPKLeqVNVoiVMjUz8A0UXDB24bh87swrvFpLc2kFYMC46oTSYau3Mii4PDbiuPv2lWQKbw3REtSCFX76W9Qf442Flq3RALVqRIJx3RbkcATUiDt8aLDAxYZVQN0iwkyw5UcnPrqrDnXdOrqILANHF8nqxntCvwcNI1OxDGW100J5Jm6ewYUcn5kDzJv4II7T5vNLiMhqd3DwXvvdiGgRx0WYR8x2JXlQ7S3QBV6nJ1bf2)CF0UDSLJIzBebkZxTSGwtTzfFV6zT1uhvp02O00KuPcxkhm5EMxYxZTj8)6NYA8ST79JQBm5KQOHQeMi2ozwUa(fxKVIgjVEPnVc)whqU2Aa(6f04wNFPowi(KpjIx1aOZn7n0E)6azAFEBGunbeO0Il(98qH4wIzg3JgDhEh9dU3PEP)Zlu4O1PfTaPN3Oe6WaThVKtGZLOKcQCG4E88B4Qv(N704XKU3btxChN50iw1F6a00MG0H39jdYqx5y8QuRwq64(keagJ8EiwqfJicZOJ5tVZRWZb0K)QFELlIRzNv3EtiG5dOpCleeZJ5XtVTc2jZD(8YS)ycgExHK(mMG8E6M1dhQyZm2o82LYzkZg9xVRQJqhfMqmoLjEpB0qN(pK4eWqb6WxfoeVsvACcrhiAxHv2LCTRoIL4S5khlUFtvsFsRxcTMgHC)(YLQvHHKPiTJXZfsKy1UWfr5jP6tUlv7CPUG5vhHTSfo5FktnlHko)6NFG8mVP13TQqPUHOlkRbqDty16KJUQPmo4va3YjviRycqAaycyWj(yjMCyHSb6wZdlWBXco9l681gf5XmLul9De9nO6dsdJwgWEqW(cxYTjfPgStLNMJV3ZAK0EFP70ET9cEheVWOp9QumOygsiD((E0Bb0G7t0rspxQn8hAV5NyRDmuNWwdfvB2dAu1uCNxtPwA(RADXmCnbdxumg3oN6wCn1T4QMBXfisXxvj)dzZ9kJ7EgkBR4okyX(M7j0SLwS1LuFy6cXkXflsfn0xvG7MbHxzYCZJsIllDh)Pl0bm9(BuHnDlN6pwEJR7yxBgTF89FVp0o579H237dTVP76kBFhCMhuRh5ViIBL2V3QDhfM(teR6B5wT7Rc(03skNFVBchiM(tdRk3CuTyjiqO4Endf86lapGsFQil2e22AuB1ukoHjqUDgHmA7w1Qk8AJ2OWzW(F5E7xuVsTYT9WSx7QkHw8B66ibaSJ3O4y0AgLJ7RLKoC(A4WUQCr98e)8UigelfQxnRkLcE4eWCVrWCCxSushWMf5(3A8EgaVxaXhoy9PFHWo0lxsC9vUcD0qoihLCxEl7xiFaYaGhFaWpApkivjJuaAyDzmccBTySF79clb9LKnKxCBfu3DH6USwlhP6AiKCxVVH8(TkILBgH)Vvr8OGWN6MoPvL0IkAwnlBChEsbH4)J9o22TnUv(TiuK1siU(4vYknTqspKCsWPb9aeaN(At2yVowOsA3QvkoTyH)2lj3R8YWlljxzfOx6fj6zgo35WrC2P99wRmoP3NSh6V7e0nbUAtQ7pDeRdXjEoueiRvKde(0qfwpockjLID0xt2Ul(BYJNB(0E8GVBFjWoXGU7OtkNwpqF4EolvYRniRoaMIXtWBraX4o0OR6idKWCfszMEPHc1PS7YqfhjGCg5VICqH)gKJZXtchJs(66hI2I3DOqWFapvswUonbpwsUdxrIZA9W0Eg(b4(V2VClMvLLGVXGO97swhrgQq3CF0MVeNDXJV73iVn3t)f8Rw5ge(iF9z8Nxebp8J6TGVPsIGwXWWVnQgMVWdW8NrW833KTpfVRXqTG1HGbLv4hVbFm)vNv)3fEPyIPTFogQrKlqwYjm0pG9N8aRB8yXavGngdWLyfYHKxcq5GUGy3ikBCNgu(47KzcK9eWeaIBydm)zpaZXa6X9NyR1diVzITjIPCQCbyiwHV4uSSKRyHBzvCL8uOwJg6BJbAT6Jo(FAlIrLW1PfAK8oRYHk5RvF0PXUcEDAHMVpLv8VBUcWGGL4rGReSFFQFX)qcladDvs0nGxdwGuiUf)3IJJtUmRBWZbggVJcwbKpYdioKC5um4sJRXsrSPM3LENeAYQi1aWSvStQm3yAOwnHMpOqFatJ31sfVMEMjFSr5Cg4aycKyRtZ7hiPuNIJW(yJaEkjbT6alwe1negIgRtBfK(n1uPeC9cphOsbUMNdHgtzns9IeLeBMBeabwDpfWqwC9AGM(kTYfcW5yDQwqV4cbW)QWBeKbnsVGroDnGdu70DdesSS6t9tHIGmgDdseAIw)6FBMbkuTrSXGQV0dbCF7C8ainDiEKxSVYJeL5ejRNoBbG7(2fpGTbcRrhvPdeSkTqbDBoYbBUVwtGQdDdTkTqrOC6M7R1jCOxLXWfxXInI0Qor1AQI1AyxI(axP0vlTs5fPJVRyfJfXluUppxW9HbQd4(sbUB4(srHx5(kTIS3EJbNjPXBJWxlywXyR)Sbac5GbdLiLYZLZIz)EbmNrbdnPJUxuCBM1nS9ZEw44lZZz(0zZFXLb8TVDE(a95GJYZXTSDav7ApBYLvYIJwowVZWGtbYfrDHbQs3ocxI(axPBhTcPlff642rYcPqexzIDb3hgOoG7lf4UH7lffEL7R0UYEN()K2o9hd6cJxk1YfLqwm737bxy9VpmoN(hzCSENHvRecuymVQ4)sfk(wXk9gVSAFBf15nItzbgU6jWLdHdMEe08BwFhgqx0JvmVqF0lwJHUys3ufZsKa1Xx9wZzvBf4Ql3WkMExndassXPYQqF00RHEPL)6JB2BYbVVcRUwUXUX)Tt5o94L9BfmHCD6uMXb9gZW5g0EEeWGb2VwtDVwVc3MP85Jqv(WhsOpCVd187UvraiLO(ZXu9WgYmvJ(WkXh5U2hrB6d3uqj92liXpUPiTE)DMPgEQR7BqLn9pS(7QJNUI(7tzv3AmEVcCLG97t9RU1y8Ef41Gf44Fw7xei0M1WfQ0qwayGuHV7up6OdkS6(Qo1Jo6lJp1JohYE0bO0h9PeN7EtaKXp5B5bZUverRJ8kri7XCCr4LgDFkQUPXJvw9reN(cWtE7chDNAhonD0DQD4CO5Nz2FUWkQuwC0YX6Dgg8jHk3QwLG7P2Htt3oaNd1RUDEHU5xDK1DrMzeDyJ6l3C6jpR(iItxR2FQZtp15PN680oAfXLF1rghR3zyqfyTSpxoZOARcC99E14Xv)i8LA(3rObDbYDdAaDCr1She)MjNSHfOmFRP3qSxfDG39D34pGGRC6iZcoMr2UbGJmn35bh1qExxWzXnJ4BaFimNHqAx1jGaxh1jGbxN0j81R2I)amWvRqnaubCbr(UUcy78UbC9aDvPcQ5JmfCcJ8MUng)ESezySxGTOfcg59Gi(HC3mk0hTYCNF)E7J(Xfcj0Zmig4ZmqHaan0BQs)1VHvZPAZ0bCveFL)Scmx90h9EQFFuAK7nYkc3pVy0qUHDj7yYbVtCR(jc8u5N4LV54q98JJqYJV7xxx5DF84gp8RWo4rF)FCnINEpEG(E9Y1V(pUoDBYDlxvpC2ZUOoG6ZN)FQog95BIwhpp7V3Ct9Ze95LYT5xE(xJwTpEE45lVBow8LMgF7fBIxHpRpgIOOjRwrMLUjRxUb7VopVEDIB5Twly9YTBt2sImTfrI7rkhiyTob9PpK1AD8n02JVt0wkB)AKgA7CRrb0J2Tpw8YBgWo4ThstFw1ueq4YRhHa4vpquIdW)D4zQow(9dp(P3um2)rIWyKAYFJudiZC4DyRh0Fo2Uzzg6)8RrlxHLpxud15zPXrBre8MBRgmdvFfN8SU2iNNKoplExPGuJ6KKNRvzBUDFrL5wqpwcLtq7s)42S)KHKUnUO0YLh44JXF7(iuileuQQn0SWGM(cu84zcTKHIMIjfLqQzIsmB6i104NV9ZwrJ0NFOzb0KY8qI(W7tigXTiQuYNG1YkqAvO)9P55WvHFFAGIb(SWcFnFYLeY4v7xUcPt(A8SZiAxP(iY6b7mp5UI5bc6ZBrMet)Yc0H9avWdtsXZIjmXJ1RNDva2UAAWaf0wWaMeDie1VNf3mkYrUbV(nVDKAsODhrEo2q5MDfEW4XHAqX8kOrbprK87r(f3UC3Y)br5VTW5WJF6AI3HpTeXhtxfHN27p(jStTwl5)vCUT2KeLVLZPMXkf4V9mAjGXHu55adk1CrFmsPnnHmG6UnAD0xIBumB41inF0)igf9gl9l12lQ9EgLWNsfhtlS62bAyZemuPgBTnLSAhpISb(W7lcPUjbPY(aopL65cwlcViSaE45lIJoG1IlOaclMwEbyQg4pZMeqjvkJO8JO)9I5dh)CcqstEGeAcVImesgfmudhZCMi55dR)7Q4YbT(asbxgLNJnexmnpxbZE0OGb01wVWDDWqAz7IWM6TtPgGWKGpLZRNc)KnctS5cryIFeZVjknLy3q8qHJs(HKD)FBKSNKN9O8K4DHi6EfofQcl1TXOqSCUjB7uUDkxIY4Qb30vWP2bdL8IpcmYbt7fmMzbOpzuaBQE3x5PUEBvsdzQJNu8dcZYGsTgOlkdhDD1)tvGjnGpBXdOqIyZO2d0qwE4vgGr7r3mtqhAdkhBwSvUsXgHrv0eqpXmqpXaqp2mqp2aqRsYYABs0F)VfNe1e13wpx4ui0Czzt5lKaiDKCnZbbzasd5uZBUGmaPHuPzWBidqHTbK6txdITQkKwEe4wJv(MJm3sSHrg)OgKlJxIge3uNpaA(KAgMQClFF1JcpeCl9iXoGmHW2orZ2rrjSWxzliy(GON5zbA8VecauxqalTyiFti3Gohkig5GsF7athwicHPIaI4LIjQIC3yNA3bchgQa4MAkBcIzvjzoFsaCza7mQHbzaVzKXCDDv6MpfuUXo91Bstx0yB3wXVDcAnWIJbxP4tiFUjTxHFD9j7N0k)4LcgLUlMuA0jB8QdTh4kFkk)6HduvOo0znQxIyNH1hCGKCokN8bY3eM4GsvruKJPztlmwUHzOOVi8siIG6em85UskoMw)TfLrRaRZMcIpDIBouLsbHXVaD0h5H8AVr6OV7EKClojo1ujVRuTZC9kYLrfrXgTI2V6SWP1hmT9lk4tzsgm)dhQfCfOwqN5mAgcVlz89VS31ERnUrq8plHcg7ETbljR7iGJGwO9Vk0pc(CsCUKMCxcYjLwiKp7v7QhE1UZSZm7UkXC0)6oIL2z255Vz0(GgLfj3XvVDIqXIDWhFDrzM7LZDLA17oU3kDG)9H9FL67L5VpE2DJBDoLPX6mJ2i7pLZ6SfCBlicZZXuwwDlYds1YiSm74wOHEifwMG(Dya0zcaNRjDYCDct(N6YJqOdiaWWvgirYr0geXKbq2WtZWYhuyvtCLacSWoEraZowevwvbaE5PAjbtGmWHbK29vjXrZw0nbis4jcz6DevIH3c5sOZFtQ1bQOWdOIIibvGUItmGv8Uc8OGRMbb4Hyagf8TJGbyy74NTzfKJF80r2wqtHzfyjYucyPwWYsLLkvyESIaGIvWm3NOK)8cE7Z4KgmuOc(PcAhxbPiyuHtgbQGJxSk80O8CLYJkiYuXBnA(54wKgjjq0cvzyrGyI(ViCeuUVkjcQ0i0qrXGgrHmXU)S1OyDXKkmCqjGcPxDKvtYCeXuIqiO5NvZMpyUcSstNbUyHA8)NBTauweCEtbQnmDtSFCPayupjD439njA(524wRkN5rXPc0y98RMzRZ6auN7bqD(37aQZpUtyMZY0K1Sxi2ZC(5sJc4F80roWFAm)5tBDwUYgq0C5K4)1H64bnKEWqEh7CFksgKDmJKOcMkmgnTsq9JTCO737UBtw4at)LxOxr7vLaGfMy7gecggCVugBbamUGH3s(BcqjFwZp(32HG5ihiXUkiYtuZU36QfYfuTqAMgO4356OEI3I4jWv39UQO(M3BhHoztkg75WDh4Lxabj(Wv3EDtyV1zNIMtkAWU(Iqr3Kg4(B3X3vNNF6NcZiifklSuEJ2AvoVJgcCwpey3Xy)37iG3FmHaM0HdH)rcJ3BtR3YY72vRgXT11p8fvIxLTnaCsRQKMfl6YHTwJjryaViBzhAamMp0bUOeyhyclvdhideax5OB2Nk8N7Db)oe30TD30cX1LLZMtVFlRYn9YH22saX53dg1IbpLXzhGIfbaqkNySX7DJONqaGEgDQOIqix8mC4v1rf8c4ds445Wt9Kmg2x6txNgKNbDbIJ4GHmmHvgtmk(CgU6vaGtCzxYQnistXGpkq(KLPp4TDhfqAprysEg(jOI83uCR4M2y(OXInhwGcGx9x7MRn)VMjRARF(K54DXvxSzV6pHBYXR1AQb0ydEuatIlSpGaWwEJQ45g7HUrdImi2M7J3whh4ZjdegwszfdGLG3Eg0T73KYmQf2PX9Np0PFcJXyiKLMUrS6NMT74yLq)NE9Z)MsS)6NBK7V(5F)2AW9j9PT7h6pW5K8a4Lq3rIQzcXUJhy48GLx706EWdpoQBv(GszK1pXgKFDJU0Al5R24okLCH9XxtZFQ9xYHpgJZlLpVA1)NQovb0NKt3UtnrgpZYYxQotd6oZN9C1soB8d5EYnD4b8CTiA9qUJI6JnsZmhoLQryMfMS7Heq9fYoNbREGgiS6cZjJnnwixDnwH)XLdLC4RkGCMa0xyul(WEZUhOQTnkKhjqexJ0iJDlMdEoCt5TSQlJrxB6D7IgwWxNWzfuKQjGxNZMKtQgoTeWOdjaPOU(5MGH17U8gLN5gLJjKDItgwK(k6nxONFCOcYmSfWQ6B(JrtqvRvqLLO75HwvmCmo11mXHfOG1Xu8q)pSpWHx49aj6zNJ6HZxrbpun7PovR4AkUcsbdNtCiH(bGKos)GYcLpB(y9Jk2IFd1wl09vlh1vsVxrij3vszo4MzwPCsnHkwKE5rH)J0TflGmmWIYcbiq5SWIPvb7KioehcJA9xD(zDrBp8G(3DZNNLlq4aUQLyymAfZQCM0j(AjIv1PL0p0FYEAmR0XYuISR2T9PBa)CzATV1cssJS7MDBV)PBw3(pPC8NdaD8JlhGAmssVP7pQYqBhphYgNMHG7tL7aC326VUfAagRzpBj5jQfuGg4uuFKMHCyGSYZGiauMFvhWgAyTeZlD)IyojYxcr6guV7QVRXNCkjDguzm6DT9(n)1Zx9fvRkbEcLdOw2mP8gKyr1TSglXT3RpqCNsYdRv2(fDHj1n4l2p08lW4tkEQVs9HZgmSkZB)DpLNBD6yI96Elu)ejIkNcIxjmlEjCdt1hdQWmFaTfii8xzZaReVVohJUEZR0FUtaOO4kYIwi46M6H()2d8E0EaUQ0J2EemmbCkEvtyGZOJM65HRXzUltOEAuwRj)QnYdGksx4IobnOw3)vX9dXagDoQpBo(SciQrFnTxPShuOE1xjBxQo9tT5tZRArgp(YYflyDjP5m7rdQyo7pr(0xum7r8KnICrR03pOka1g3heM7H5jno0WbEhhrMk03c4QXFsK2yhgNOJZhjho9YNRB(TN6KhD51U52RUQrF9v9hcC)MRFO(I2)sB3BuJcNNZiiMGhVYveQoFDdtUcIvKw4IunWzW4uWdhnUOaBDbpSKhgSrW8JCW8dCF4XgHEpss6IhpYbebHnJXtd1(3hoam7h((Jetf466TxE39dFjyT46BMI(wefpUR(HA1nUXJBV82gO99BpTZ6wHbdgSFD7)uTR9wMq3aIFM(6ty0Z35c5NQRGsa3pVlTxWCK7RAdXbXAZe4nc9ZeJE(DdsfNLdj(rIuvoSIo5NPsUFIwuc3EfKiCEb(cY(s52Cyj4yYEHPCP92ZSy5px(JJjINpQHYELEH4wLtTcZZPxh(Co9fvs5c6HQIAO6(GXRgzFOkP0n0WA9NoguuMTe6728jqf226lvkQgzSkNotlNRV)F1tVD1p28sDA5V1KHU(5hFc5Do4C3fl9p13WihE22BCeFDza4zhB03fTAW)S)JgnoCrbW4GTKm9TAlZj(uurXUGCzV)VLAYmAbaPqgiZiyvzwl8gNwl9lp8BV(5)4zZdvS(Kc9NV8bkgZ8oI4RQoOTGiWA(2)OZnCL4DZfXUamqEjeIcFWwJFK4dQxP2NIyvi6SCd176VXblmRNII2Dx7LbSvjbgzzjarxpcC25Trt9wOCuR51cYNJPxhdBXW8lcHSGw1U8cUBHEvMpsEtUaTdrHflFonYMyuiKt5Xrrw)rRfMR0yGmwzJTi9fEkgfgPepMrTECBXYT16Ey8uwBzLkKxU7NDo0HxM8S45tMGzAsmfFkOwYSPHgnjb6Kq3TB31k6mSCM6epH4zZiy7BOVldJFgtdY1tnW4A0vaW0(EXG)J5lN5PmwZQyHIre6I(pe1HNTjTfwTZlq2Cpb75fRI177JSkZpwK7SNh(BpvFGluOxKqZg2fVwLEHu1vebRH03(v2TUyDp7HX50sbyn6tgXevGOi8USg(ikYIGNwlsG38D0ce1nCHHwHvGsHlkkc783HRiMSzipZmOkCTPbCNW8sppv1YFgWX6bRewwTiWdTLPjTh3zKBLuB6Xa8ory9GyCoLzosX67SKdEx03Vyag5HhNspWqgaZggfIuwgv8DMi2p8)3GLbq9Xy8SWfa7w0Whhgdh)cKsf84u)EO7IJMuggGblsKlwCCo7QKslRXfG77mosWRRrtCUjen5wF3zo3gzZ7JYAGB4j(0HYFj5nLpk4kmAiphAMMgXl1hmDnHxmLz51fzDa8T5swEbVKKU5YCWqeEJ35OKILhtVm54xjGYcmWvddvxq7c5rgrJxmLNEm039at8I0Z9yspWRT4mtgmj6lPUpmcBgEWhl9BWTqNj7lQ95Kint)EVoGoT)He1TxoARe3HD2gYXOZrFxUfD8glJzX7Vxva5TaOvPSB6K3DG9p5BtV09DJHfv1ySVnXcdWQO5xWj9cQMixsMGsIIvCc3trX4rLF)TXZLmYYJ4XwXIxwOAHMCu249ldu9WAF9ppMhyaCgbFo4XMq6jJe7CgurYWnv6hHHtzbIDkl6iLP2GQWiUyTmkWGDK1PqZi06Itq5aTVy4Ea7egCKZqkEHTWHFTl8ywpG5jWGkWgjMjCGQDU46BTrIgwppHnhj67fOEO7m2boRi0iFqQE07sS)R9UA6TTHHH(BzhAqk2oe71Stn7225DyNRNxHxBaswkIt6akk2V9jBNKAjtA9OKCK7qrogBksk(XZs26n04paO(wzVgCCJbsCnh0tMfM3g6hqe(cO)Xrrlx)1xaTAo1IQGfLgGaYaHbaq449)HJIdz4kicEV1nxunIDGrG2klmc)14bL3nptcefSd6OirCU0CIcwU3fC8jInS9ect0OKjbeB8SO0qGGwWo)BDWCh1SG4lp8YC3kkQy)inwHotefpwOIPi(1tAgn3zHu4P3Das0vXPwXCpR40jrrcytzEUuOdmxus9YFccuhHr447edE2Lf8XfTBb6OirCyfvhfpvJ)6lGwXp96qE4GfIhON(HCfq7oa4pbK3trrOAJe)oIAeYXtwmNK8Ezs2w3cEKHOdwVNXnZ77tzat3sG61II0d1QSpIXcIgbXKEsXC(t7ZvSxr7J)7kYeeZxu(ya9J4teWTKs)G613hGhDpwj(ycQHeXT4uOzqmUZlGh56hGwqcWXZpYfR98OyAt0gHazcKl(OdQuS8mobeu(hreKlXDDrhuQFGqL8fTbpfzBUqIXYNwcKd6wLar5aCG)SljF8W0jbCsefTfr)4Gdm67)9hFB7YnBRbhn96x2x3wNJNL7Yu5x5pwSWAAh0OR6nZJRLyyd1KqB5jO7cTeawpIQBt7yjTwdRU6MS7vB(tLiwVPkrC)66vIP(s6BZxAPcbA2iv(SbP3J(A1kMnq2X(hoD(Vd8EMNaCMHMqf(ZL6smxNoqwAh61wyi5uZyYxoz7j8C2ODQpF1XqNQZn(YSFMVB3QI7kY36O5RLpB6sTEqmBrBNWW3Ep)m5wMDGS6QEKlMGbHB5rhdsuPosvx)zbN2nqVplRMLM5mT(dLeKCeexxacNo2W7lFv1IRdL70MSCvsUMniuHppMRkSvjjRKBfa)q0u(NHS6ipKV)4mwnCD(VxEB2DBxw8lLaBQbvZjOKhb)jV)wvbKdujNo9UykO2uQY95Lz7llYQuCdYyH)2s0UTlzTG8vkT8(Cf2M9p9KAMtv5P2icHR(YdyEL4StNZQQvgJs2R)q5Qn7wC4pAwOksJEY709XAHtgmNJPJ04Vj8sTzsraA74ezdEXfjPTixXRx8PztOiolTlG3nEQv5mSPePr48oDMqTx3E9ZMlmTDCBkNhmThpizbaJ)ocEWXCCBQwC7)tEDVCHglopvF5dpl8yV5Cx18vzh6UMX4UnDx9DS1RUXan2hN6Ipoet9wpr8AlI9JrSX4WhK8wdiN9JLnpkzCnHB2P(DZ)(]] )