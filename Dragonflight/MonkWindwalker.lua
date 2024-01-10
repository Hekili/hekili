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


spec:RegisterPack( "Windwalker", 20240110, [[Hekili:S3tAVnoYv(BXFynSqsRwh2DpDITbY0z6D3S7mzW4oy)MPOKkzXXuKkKu2Thmq)236Ghvr(E1bpuCJ0ya842SyvV7R6vfVF69F((7w7NrU)NMnz2LtMoDY4PtMoB23D)DzVSNC)D79x9O)d0FjYFh9N)FbrRF2p8rsc7rVeg7VMnfPXhswrF82SS9P)P3(2hcY2Ey54vX7EBAWUdH(zbXrRs83KX(3RE7YW4LVDDI)dXrBcdEyB2B3NeVjiKK(2FoH8l(bRP)YV49JXrp6vTKJzV793T8qqy2)D09lHa9jxoLco7jRO)539bkefSEnrmwsk9LzJ9ntM(MPt(thx8lK1hwroUim4rsyW2441hxeV54IdPbrpCCXN)5JlwFiH)73rsirbzVm(4F74FRysMCfDs(XGO4KJl2NeeNqhWXfBcJF(4c)1)6H0SDKOSIxz(BMo7nZ(UQxHIo01ApdjuhdBAVR6HPspLc5ZpU48JlMn7pFCbDWtNRBWtEp9PF6qs2wcDbPKOziJJTK)SF2QTIrv9WjFNys(fY)8qqcLyD3JVKq8xT9T0Fjl(a7n2WWMm)KhizhxS6LvHusM6mmtaKFSC1pUyxCAwiLCLqyue)Khf0EkKECXht8JO)p)O1vRNUv495RqwcLtknpmzNW4K1fSdc93cIyu(OhcjVrmHsZZ7EZSlPZJG1x9kC8lko6nnWDP39kbVTK72GmZgHy2V7J)p)rkf9o2p544NI)etQJQO1uGG(AtFV8etrYOhjz)XkstX0C3NLLdtipfKs17ubboH64I)bFvYrnMQJ0GUSyb)mLnKgYhhF(tib72hsyc1uyoinlvqRPcyVKd)VDLF0ksOqJhx9rSkxPckjX74sj52l(iZEH0lmxOyCCXFHZyOGNq6Jbb)vIFMmZGQenLpwMGlLmqN(S4JlirPhyYWnG9a2)kIjoUmj(rcfYFEl7NfWTye(RYcEIOUmteSg)FLrixT1p6bMWnBX8Pw2yte1wi1edtwiRb6vXVuq0jcjPcq)h9JcwDCX)zsaztwCcdP5e7)mtiDnHZz4ANcot2w)SkTfgGt(c1IixuMbyHuKG(ZykOMWhDuU6YkFgiMfSlNCLKBFmjinx7CVFswGFOyOJV)UqgHK5biEpjI6u4Z3)tCFkKi)LHK13)9c7Ujb7zO89393fd7ogLK9VtpSBxCK3ZBdYiEzbuaYlnZp7a5(mQb8AZeDAYijb(uFt(HmdRR2g4T8qcfsYhf3Yi9VoEN)xoU4n8F)4IBV54I5vRjJye6T1pzhBrMJUiRjlpSzZ4n(ep6ReZKC8w7VJs3htP0(bruc71udX8f9mQSUy8P5kL0xARpvoLUMJpSVA5PZh16fHINX72ZGGlBnAECHom7k05TbfIonZQMg269S)tCEW7ytcW8lnX0r9EDlfLbqnXGZAQTYCm9E2)DxAU2N38mijlykQQaxLcm1T5N5QePTGjpfsESy9xgsdsk(qM3JbREuEYtjzElJJoKoolGKmFQ3S9Re0H4DlJPWRWDf9pWbIY5HANnIAyEfxFMl8WC5rvqYH)FAkKKBb4iuJ27hUtgwmjG2aUGx06cRLkY7dIIOM69wXCD3GsK7PLzAXll2BDaHlvqDpK7OaLOSM5pXlEJhv24xdkauGLtiyjuf1tofZaaVbgLRRhvIYCiLbAuJNEpNhQbG(lnw4O1KKnb10G5q5k)WqojjExqedxlaqnCRsjZBrNK8HaJrVBOWilH5RUcgUQBgXOcwVOh9DyMvy(2yeJn0qeaE17cIOGrYH9ulvtLHkoqee9enqIKuV1eEgofS1ZWe9kNnVGnu1vOb97)UWyffEyW1xoqIyUlx9y6y()72pmHHqF4eQJEkveNo5vcI1sSI)G90WYhRiqZ)ZfU65l2tXjzKVuOzHqmW8gAVYsb)HcsPChF7Jd0ONmfZ)hn8qgHk9quJ10P5hZHMZZpehyIg5kmNAAwyhMD84WSm4JzAcEC6qylhbrWmppeQFdLVFeudZhG9ktoiqCkTp3scYmmtT2tq4lBglmakkLwiisZ2JM5ij5fHhRIupaHbNTWLlrNU1FD8ZlJ)cJwMrJezDQAMtgJYDgMPouTkOjbZEwpZNrw9lLZCJMGDcRMzEIIU6T)q0QT1sIBgUHQcPOKdPmUP3V6VwG9kz224P8zfZaLvssi4gMLi4uFkm0Hll2iQCZYTxZZ8ga6KZBnThYBDArERTXZrHnaZbMRlb3EqGvS8fvbuj16Xx1ktxLZbu0wxIz8fVCpTibzaXoT1ZPd2iNB14vlzbIQM2sdzibpycTbRJazCIPTJf5L2AmzRYGMWOQ7)3AcYjjhEZ036Huyn8BjeYYy3mu0ibntI(Wb4zmMLQePQjNGM6LEBzqPtzFOEv521sOwJIkAox9Gj5bILOu2enmeNsb0QGfCIh0jW8uwfu7i96R3GPszbLMAPTYAVRXYCvRWyAts9vf9cHWy0XJjJND38EJ8tT360evZFnTWG76a21CJzOrUIM0oByIXO1zrQGoLmJXnpCishamGqwG7R9kI9fkHaKi))yCCinrwzreUuK4F4X27vXoW6jAoNY0oYeDiaym9kb8UkFfYvJfvuMl8vTHSvIY)(VxSf4EKiYUaIq8(sXtCBUyXumr8IlJtfrXVHzaXRkKnwyVtKKn0TxX4X1Jyez67kSw8KpDC03B8wkcWbB(tYftOQsK1uLAVLjKNRvgHCewDikW)0CuuyqkoEDiDCCBqS)CDeMgJQuCws0r9PvCrXM9dIKSf6mjQCjydMngnJXrqmd2KnBc)jxWNVCzSXzthhKo2pDlPu5GSBj1Jq8HWckS6yznebjzPFYJPukg1wW2gJBMdZ5mS5KH4xylGYgSzWCeagvspv0tUWwSrzHrXLMl8mGfEeQWJUe(0PE0uc9DLcb249tirXWrBgnprdjKvJO65nnfPAcUgbapbuzDdJ68gnMOhKnAYqjl1AOaECiyrIvP8ZT)OSMLf0ihI0BUwGC7POo44eSIA(bAsbyuQRmy0NzZhZaKjhgSHifOIm(Qpj)sxaPVeTQ0vDHGUEYlI7JlkLMwZuzzHRSnojYBv8tucMSmfaIwGPN1LjzIqvAu9PsN)5YPe290u5YaueqJ2Ypi7FTfexNdQOgmdGg3Yxw3M4)Gq4dZZ4hMOy7vMYGUN182hL5pynR1f1g08z1lFAUUBLF)Te)WSTJxDijH3bGuwL4pjf(HOtO92XJBn1JMr0sXFr0iRvZPnJgWaVtV2TWMsZLvrSY(UjkUsu0V9Y)JfcoATrW5wwTP6vCfyUUXLcGH)OFYoFWI7uZIUc)2Wknt2Whlqtr66q1uPVwfkdMKWSjvvsKINXvIt9(1dRFGL0DTCZ0SJ4DcI2eKq44oynh6PfHL7kv30p0JLlMHce0PvAP)d84ftOjbNkYJCnzJ)HWmd7RKYUG1ORL0yOH3sMLBBKSvYAvSuDJgQzQwPGrAhjCbpQ)kcRUoLhUsc1vBGM20HlAe2Pfi)z2G)5UwTgLYTWv21TnIBeH6DUzGPsaW2oCwungwbPiewF675NKe)G8gyyy3dk2W9cjCW0JTYd7TmzFSWoUQWTqFSvgtNO4ufh97VLC(vfljcbZMAaEkR5mCz64pcTqZgR7kSlxTnDGETIkAaW2fQpHpgGc32y2WsVwKN65YPbRD3hVTmkPkmsElibtHxTW7Ata0sGEQmgAA7sLYL2HTlfJY6uja0YyXZ1aATvmGMFweegDDDN4WRYTLUMupRgnxa8yp1RxzLZbx0Z1bKZKdZRb1tnmpdoEmHqwT5dQXDwBVQSnQtulcvZm8EoyrCMQv9vkiljPC5J9IXWjTsqBM12YUvFNIOBNNkqe(AXoxxp8I4pmbd1W1DTeuNJhJGn(qrBRXtSt0ZCzdiB0hK2lqyTXbdsb49dz3PBcTe4AtAtp5hVoyta7GmYplzJFpcrCUSDcR2br8nCPWErBAhsnNkpRS4jLfO(tf33YcujlqPJ)hqAG9O8SJ2bAtmZOnwmSHpfeOfT3heiGMnsxbbNRnRPmhrk1hw7UG2Prwk6v2RMMBgDyaZ5(L28cPrU0rjpSgV2Igmc7iwy609a6AqtcC2FqmgWZHHDo1Gbl0TmqdLs7E8HfBRvva3If3EkUMkE)AU8Bvub1kR5E7kAVreKdfdERhIz41LE9R1WT8osz2AKI7FTXKIVtnVZ145mLxL7jQnOPg1zwIsvhC6mE1d2)AguP54cLoIdmsJGQvGg3k28zRYpYctwMaNB5T125v1mcJgEkdK0SkJfeAjC6YcDwj12S4KDEe)KSTE(rR9yBPMsueNzQjzYTWEHMnhyeQwn6rMZ(()2KLC8ZkhOMCFMQN7iJngtfmfKdflc(oG9J9fqcU5cCxPGuAf1eUiqMNlvMNMYxGyT85YZpMWS0Rl9z7oCE)L4F44I)x2u1SwwMkW(uOerrJQINlMmEdEUTnenGUCh7oR3LmFTV8xyb8ykLJAxOgG(vUH1FXnYKIRfh8aLdtxOsARMCghcANXsdGsgRi9GzdWa66DWnmLFaTsy)nJKr6amS32evB3L6ck6Cbi9(QkwugLeMUHKW1t3h)m7wUSmIN899gygEh6tUSMBAOBue7x(r6YCV10YML)EsJTrUnKA8SGriwvn13fgji3i36aAjUilMI3V2YwUPQnyHWNlXF0mRG9r6kmI9bUGhrIIRBxRngAPrShYCiTjRgVQhD3QPspyi1fFUT0u6qEguT3pGfodrUALGPii4QZjG0xyac8mGD9J9qEBfCCobO62TUM7PdcKSp(r0dFQPcp31YlJEFj1pLsfZRCN3bgrKYd6vAaFMay2S(Lgezn24aMs2s3L)aEHW6aPegrqRvvRJLclyPtE1PCXmR715P1wg0Oc1OSpdj5XTc0Gz5SNUBxb1)UHxQBRQxu)uFmNVUpnh2iiIDBzWCM38TzoBwfAsgWDw0mkmNBoRyjTzRrMJ3HrDG)o357lzlWn3U0JhWJ6pCfgxUEPh1aeL2OP0IwlkzLJgyr(MnaZ3NNu8XfFpnRy2vBFwUxcuMVUu4wvC9DFPeJT(jU0nUfu9EbUUWR4vGLqgZNdMXERKglcdoNnaQu1PsYJzWx7EybwE8BQvPbTWkmW0IiMn6DPI11A4sUc(9t577Zk33J24fc3NSllp0aKCokTxdvB5uguxxk2ckVaZGoshHmexp9UzwWrXb9ue7r8wKEDdacO(8IoriVXIG5pi7ED3VeHTG(GC5LzzOX6o9w5trnXzTseNO4C7hDnekNLf0i)aFzVXt0Av37P63jjzgKEkRpTUykTJpczHWvEZa682jmUlOls5UDGkCk7faZubl3SAN51FTeqac4)6RPdWzxoWv6uWeiZ5)6)afGayDkYaK58dUwLh0YC)AO2j4vgVNzEGRUCMLx2d5vE5G9TgRhOgVwZUuQUtdtRV91IJahPJNsheAqlDPw0ghFDYbHl2K6ZIp48wAy)MW3gAi6Mz0Drd7bCJ8FzvBOUscg3WY9SDBRVH(AhXh8Pnfp9n7PPw57CZn)vLuw1rHrBcITJwB)o02Mp5yom7dy(p9O6bcW78bbZI6(vjcmS9)bck9VMVuA9UYQ(Cr6a7bHSnGw5DjaG2ki3BgYHN)E4tzM9MuovzXialx2Gr0EbQRDBHXKR08HqdtxaAsoLrV3srzrB74uo5Vs6SglyIywzEnu9GANTRUNa)T9Fg8dE6Tdy0mU4gW(exFvPrBre22wHAKJtLTFGDWJ)O3oiBF7KDzryC6rNVDCJ6NJBKHV758yTohIlC(fNbs9)9FxfCUD6KrNFHw88MPto)ma4SXuD15aJ6CtZDti6YM)PzGqWOZXqsHJidFj470(ouWa1TZDMJrewjU7NWmldzOplU3j97p)aKO1aMBI9w9TWlCFCoUCoBN(cdqGNbm4S(cYrO9iiul(M5dN1oeo4YNtFlwyhM9H4ZPFfTFyRQgy8O6ovvgVqPnLOJ26T17hBCSa10wfPUW4GjBN07njxm65(hmFaHLUFQQgWTUUJLaZTJJWGFQQELCRdzogoqeZPtvLZMvHMKtu79GS6FNZ12t7xfR2YFN3PYzdJBno)x6vmo512R4cpE23UWJ1s9ukM5mTx4XsKJVcV4nD(GPyjzSZxEVd2MYcvZyyqyiopinumgYBM5bS4KwgEvHWPf5lzF1UDEpzmld2MS8GboBJvx2dM9HeIfBUPmbGQ5IciyR1dGpJmTPNwShJBtJRW5BS)OarcJFMnYDXmg3HDL1vgllAh)c7CQRsrVQ6Ha(4buNpDUEd)6CS027Nb7(D252EesEqUGaRS4REKJvhyL7xVX9X1Qq)FhjNlhC6U2QN58DZG7j1BcPnFXq3cJxNzhj8Ct2SfBGQCmySyms9w6NLfsEG4NyO4mohAyZ0bmYITalo3IDieS4fLFoBk6hFmjPtB1d6bpaiuciFd6Pm6)q)y)LxGl1yWkXhK5uZ9eVYlxgwuTsPkLbS(dNYaKb8RTSAV814NXhD7qAlJLX5wMZIS4GxP2E)kRjvttb5cAealU2MjzPjUBNJEYANw9qswdy9l7QTvSsM7CrpBrZ8I7KuVuHjBu3Iw5D9jv2wFNOzu2hrQjhrKZvLQnzJAVoNMVZNFnwBXt65f3czyJFwuW2DxNtETdB63P8RGAFM95aWsTi6PBlVyowv9fTyK7wN7)eInNBOZ3vQqtYa2js9h)ab2DUZImMHqv89qb3Re(7p8fYQdzSGsipryxGnmAb9NBj8nOnMMDuafH8FYpiKndJLPT0KNPw5IwxalabqhVNB5V6TEYNId0NY(TWde5e91ThaLXoPKIGU3OIjEBTTlGdeEr(7OR(w6mXFFOyKTc4TPePxx4XYSVQRLCUbzUeUbzl3)JAyw2EVK0hHIkFaXn14UAoW6a)n8gKSjKVC9sDjfSpw8)vKN)58)ynluL3obkf9g56EKdK7jIkf1qUsa95ZsCQO0m13okM9Ujq5pOEdAEiiKks)rMnc)SCToQfZe6VhVry6XxIfXBulX)Wlmq9MguO3ETYNzSRLoNUgXNZLBU66FdKU)o26LZFI3Z8rcLaIc29psPZ6NtcIEKAyIkpF3p8Pr6WfMrKvz1QSGLGukH6MiFPktZa0zp6SjT84WOYsMF(GKxx0nMs9qc5uTuYH4IPGfwzCKAlryz31nTUYssqmDDd(n6c9jX0FCXDmqKA1Nk)Tp0)fQvQJlEoiBR0q(VeGayMpLEVuU6wbKmOA30FqOz5Ye6ZTWqx3iMkGmbbYCrH4QngOe2snk)R4yr)(qR)soZ2IMvKzOITjPaqzPBoPkwDZbzDnu)tvynO59E7f8mB(dfPeZoHb5VtkhugjLJLlEO1AirqNVO28wW)WMKhFjl(G8JZZqty072YpSrgzYJkql6Kx4WBSKNYcuUUm3TLLN8m93Rd5WL2rG4c0kNOJQPk95FMUAXhxeft9z8mtEOqasBE6Dvg9BsKFtIuJejZ5bxImMMuXk)975Er4X5WYO4ZXz)iyHEkD8wMSnGJd(089SNke9ti04yR7adWLVIpyKDquzi18GakYIhrBz(Fy344n4OINmQMOgIFFWklbqSYrT0HkYRv0S)iBaRp0ae0fF1etcyvIqo915b68IZebqJFxuDClBugQIhaE8pR62gUPTGOnhsdYB97rLMqWF)Z1(6qIu8ZomuqRfFWs1xzSVYr)R5OVRYyQxj8qv7ZabcMl0AWGD)davBohHIB6guCzgy16ChiM3bGyEgy1(ChiM1bGywgyz7ChiM2bGqiz2O5uuS)9xf1aSdM)mApPOncYLr10dj9J4OuBlKb0CjAxUwi4vSC5YD47jr)iIjDSeYaADe9Pe3(LlxwszRztpSJgTHCeR0H5NXQlyfeLbCMuSAL3qFy22KdIAvNhcHPsvFhRAD)XJl(bw96Okur0G3(uqITb5OOfPwTiCvzdHVBd9kt3ftAJG(zlg3ErTkkY63sLlGb8i5nfWoR4KxHLwrvgBfbRohUIZsNwlPWAhzOUOmSOIOjL8gujQxzAFAYPinjvtNnPabzHXky1JZMooiDSF6wszgRKDlPrzeFiSmOBLXYQ7fjzPFYJPuIOFeRav1g3mhMZzyZzEgO2bO805mcMJaWOQDFqENXVWwSrzHrXLMl8mGfEeQuaUn9MctVRKnBtHaf9JgdlSz03k(enuIovDpqJB6y4qpNJII4(rmQCFHwLR5tSZcGYUeW)MBjf7nCVLEM(UstJ5btatzcX1mKCElQBRThJiPwbbylG2CG68iHSAlZSJNOKoscSqVd0UHuXw125UNBXUrHpaL67lQgbkFAuPcVEOXOagGf3j6x6AcBM9tuClbjY2eTQCs12cSMCNBABcWYz7McDelADyzkRr5vdujeaze2oRKPBZU0YMnARXEn3lGejQmoRxBtOMjENj10N1lYNl3nW2kkKeHcuBKSq6aT8ZLWWHKsoxYhaQTirDA0UpUsbAx91RmR5EJkLWSMWfRmdyjUx5oXvkDlCkOUqy92ofK(qdpCYVi8NUqLjy6mZoG03gQg13TvegW6)vQ4J1eWRDLnzHBy8nML5DGXEwt8Z2EpYEUFVBD8A5K(OFYoFnHRsjtFyILBkeM5gt(mFhcWJNakeV8dyaakwNbSxeYuxx4W3kIYOLKGzsTSjV60ItBqM2TN4ucGtLY)LLzfj5rQIF1Mzu8mEzVt9(1dRFGDgaQv2fDDZ6PezKO2m1pof3qjZpLWNS0a7G2q1W9d9yUSSQI6qwXyGUeh0)bEIYj0q4sVp)EdwQ4sAoBvBJtIyV7t(HXj1l11p8PQwNYH6rvMQMJ7oUEF(giYIgDdVgALPSkIvhSsot5B7)kFQBjzpRnQjYo)OGvEpKeq2qHwWYXS1p17qkXJHt5RPsnlmoftRnfsUCQ)U6lUNT(tDKFvMvtN4AY1HZpKYtOULPXD8B)g17XY4VavpUsJ)ckLYofGs9eGAdgPI0Fn2ecNU5yaGBOyLT1qtEuSfV3Xf)h5vsKTYnEilOS8uCWSmP7DSiJEPCpCxeXSs7DPHXzsCtGAVPJJRtL5FNz6Niwf2btmFmZavoRBDSjFAMj(eIn0MJ51oF6RjLZzqLxuhhxNlX)DMPFAyv8Tt3JMhM)tA)0ry6AXTEaPMB4YBC5KDQgY5NR6takZ665LNl(r6dVZYZ1UuE7aNjlTXrLJlT8RyrlUxHfbNb0lKCuJn62CJkbNBUZhQs7LeMzTKa6jF3a5vnP03l)g1oT)kd05BrEt4Cv3NzgB5JSohUQBAlTr1U7Jh8ukbeQKkPhyfabRPxNjwgpsMT5MmdOvcUbOdL1YxSRAQ32PRZh3Vh3T5c5Tw5CFvFp)OPyGfRk0DvakQljEaEjgy6ouZQ7ycaXRkvwl2HUXVxT0XWUGC4QGh9iRRxH26Q4PJvyII7S5vJL)Mgqd1Dw(XreiGgThM0IJ1z6lrRQ6E7YtO8DkFOHi)Zdb73twpoIeYcKKoBPEnUG6f89YXQRHvkh0UGKK4eUcxcfmPEMxtNZDX0)6ZP1gBZ(AP8uXoTmAOsHjlBvod3QfxFS4Wcun1QxKeAVGU0DihQMqLBXaLpUCSN8mlEvfGotTVx78NbTzD5RGw59WHnTVJBJhke3cmtWs78L5oSrJUF7Y5G7ERgVs99Hb6t5fAcC2efCwHleZFasuC2Y)Z2Fp7AVtbvpBdZvQQ93gDgHMMubnxilyvFOxUXFC(Y80ICdRKEg2pskWy0q81dXfyg9g5150j6LBQSH8tfv)BYWEBdOPty6YURDFtAoDxIFN0lTQtjdBaVpsBGx9oW78TryxUbU60nxQvHAy(YRUfPYyS6bkhJctfkYEuyQLr8j66axstSBFWXHHc0Bml4ODlmFGtiAbr7ASkqLjDcH0KYbvtD1JHL5)YTuYuHRL9XNkMQg1iJNT4EcnTqwoM79xfKfNiFt4j6ApX9PqPUpVtDPpLiU6SYByH3C06R4PgVBznJndrIsFP0nKnoocxxxgh8gpqZMAWlEeqgrycyfmK)F276R3g3gg(NL(qtAhWoe701RBilFaoSh37hcAtVfG1MUK2UBab3N9z544yjXFu)xjUWVgRqkrsrjr(tuApzBU9(yfPIebTbpd80S)E9pxkExYNoNbEz2ZG2pSzXQh(6Y3fQVfpu5tA1(6y2HCF5AzfaebGBnhbaMB1a94cjF8WvUHaVkyhyBUWTFNGv53F8aQkPPa5A)C90PFsV3pIlnZ7tOPYmDohkkrGgV6xPTP5yM2f4Xujf9(MAD4uBzXCBzXmvwCdyAWS2jquoTNjDhfHQTcYl5s1FguH4zGDTPPil2CVWoSYeyJaKNTNus(0bT(x)7)RwqUCZlvTUX6vAYAHuKj76MTBZ6gvVxdfQITX2BaVId4vCaVIEcDT9YgTTY1bLrUacLbW81BWluVhmFX1YDaPB9gl3sQD1tejM(Hi4OvMW(P6Zp1CFo6wIBy2Je9jlyq0N)N1ijVzmsBQBE2EvCoQJQujFTE8kTtpUr1(HKc(rO3IE(cCU9vaPkrXDMceiZY4rq4tkaPn8C6zeaTCMPKIW463u6nXLvHqt8PZXTWYOF6euDDjghNfpnrmNjgeghJte0YHO0MaQ7K(GwkpEkBIIDfmzErjJ6W83Xq9g7dsfaDHHGUPbecPdksrxdHXAWaMn(R9VhnOC(OvBs90MqbUyMbulgkUOU)o(WSJt3FhFYzCIVYSGUtWtBc0zBPqY8gHuLKwSPpYmdcFqE6FYeuzK1xrJTxKNGxYL(LFzehWWhrweYkAFaqA6k7fvVVEZRl)o)(lC)Hj6KpAVdmsY5ZqUxM0(9CDPvUvnQHCyVPawcpoc6KuueXzCS4RL1fUkrDnBNKwIHLfx61QQJfX7v(YeFPYjD5ntkMuTi5)UyJy0vTrI)u86bT6PxwlE(GEuezRXDkCYJffk))5TvBeIQTRf5SyXBVU(Pf1p(x3)xlE(Bl3(PF8L)OUg6)l)MOQQ(Cf)Q)8y9tbxrprX3N4lh0ivT4QIVFDlnVnb0Sycnr76LtHQuoa1iBk6RLf0eLWOwH4mM9Am5ZGEoCoV6aXieFoYYF8foBUTNb2C3LaA(RjGMLLNA1wNxwb3uBtP75slzR0zjlbzQIKBuPBt43zQnUTSrohtO2Ap70Vpq0SISDwXgMcVRgR4BR9SZIrfUDwXMpM6k9cPmbhiAscjUrY(X0(sVYstWbF1e(rCtB3jy)IGL0Eq0Ne7pOo7M3lE4LuOorlod5btQ6u4Lfj1Bm)AEhFaeghJL8cAhaaA2znzPDeQaPxlPwk6HPGMopQzvVUE4Numq1CYebAc2WCuppbWlwu5rrogiODytHhnvUqbznhztWU9H9FxNQ0qUSiZrwprwMJyJRIgwVilwV0n3iafwlohu6wA4FWsFLb5cbSiCuTcaNxoQ8Oa4FLmbLkSHnFNA2AzjioaMeyuTGUqIAFpTRyqofTTmZ72euGuoOju5Yoe4(o68bOnJiF4dIyZrT2gfnBIoBbWDF3GsOIO0w2jfscIwzflKX9QgT1(SLe1M(nQvwXIc((T2NTz5WKQJXbTjGbcB0SKWQmTvJAtSN4g1UwzvYh8pDystZf6gY7ZlgsFmrJG0NL4Xr6ZYIKk9nolk85Bk8C9ll3N59TvRx8CfLVaOKhDXvmAPD74fXQFNq4C9ORCbF7Z3Nr3w4RF5LfLt2Tt5xN973ozKoy23T7c7LGxVBNad)JKWV)SPtoOl6TsSSlWWBbkgR6IjQr3oKnXEIB0TJvlPZYcBC7W0qjgPLp7yi9XencsFwIhhPpllsQ0348QWD6)zRD6xcDHPRL64IIueR(9e4cl)(W0C63ZKyzxG1AeM3StrYtnd)GeLjtwEyChuVlzDoJby4MZGKdbm2cmCFG4UgCMisfM7srkYkqWHleIMN4OIGUw2qew7uKyL5JGe6GJFwFxUw9TQ(zLRdfQk9nl3TrKmM7tunh5akjaQTijiXmhjgDkk1dzBY9HSAwgNL)IQ0jfleKcWfdMogvzbYgpQmjplObyIy7BDF)ou4G6NT0(UtvR3nd8(cIXlsXgrlYXAbOSBNpNFTpoxUzAKJu)NcTAowrlhgof5qbGysACtvFRlE0nZWHlCXrwfc0XTFu1Fae)htDLF3jIKsCJK9JP9LF3jIKs8wYM5lCrW0ffhTaimyRWpoaJkByrqPuCagv2RJhGr1PegvGWRKtnUwQTa64ZEuP4wIROAxDf5G7PgFEXeNs5LPKb3xf19ij9NGN8ogo6gqSOLo6gqSyeN(528VymlQrx0BLyzxGHpjuZqnOn4oGyrlD7aohAsD7CRT7VQNbam3MeDAx1NF60zVOUhjPBn7hah8a4GhahSNZI02FvptILDbgkaRnyPzStXwfGgIKo5jw1jb2P)EsnucK9JAaexC4bQuuLTx)Skrv(QRzioPQoyUV9t(ajxZZkUk5A(zpi3RRFJIC1)SRKlGmJKAcFkMoJyQV2eiY5PnbMCEztKQcRt6imi1ksVsUaxq1FZxchM3nq6b81Ocb(ixjh5kVVSzPOK5SWX1EbdXaum8yquuv(DRhMc4QMdiAHkCGsVyvkKx55Scq5sq2YZhQbp8KK7MMmwRBB8kA4UrwkUMgGPwNPxtJ0CXR6tunhWlhHQ4Gm0G(dcIO5as)try8nBEYoC5pI9DF8)zVN9EBBKJ)ZIXbqi144ksk5RbqIanxtq)DOfnao9FpzAj6y1izjqkfNui4p7)2zx(yFm7l(iX9W9px8rTC3zN3ZWDNPnO8HTCHzj8K(zrE(x))OOxyQJIQ6vLpF7wY2gqE)2neC6dqNZ(Mn7(LF7Md57VFZ2SQ(8qXv1UX8Qf)5QKxC5JP7Ywu8Thxvxx2VSKUTyYLFjD7PSfHxU5(fa57WHS1x9y2widlWmUCfXwfTLLSF3Mhb7RNpxpo8dAi3a2TjpFFomI7ZjG4jcZbzU2TN80Nk4gN6Xi85FfBlvCAhHdLpIgIBuPhpLHp8MgHfS9iC6ZR6tgOdVUjzaJUknpcURP)9Ek9lza97NE(2391SvNOKWmcBY3iSb0(69rq6H86GCZMcYF(L0nBb6Zv1Z6IIdzP5ea(X1vTEKQFsHEwNrQl3Fyrr2XscPdzN68zNswwvVPjrSbUAgGoEyzEXNLaP1zSe6xgM3YSV(qkXfdWgDvoXcdAonM4TrnYqgH1DFyjURPNPmF2y7W4DRVRtWOyuBndqeuwes5h(WEQqmhqDG(eGlJTOvUQD6W5Z6)2hNoeyPPQJMUXfXtOGXBpTzlHN8xGUdt6Xs(rI0dOmF)9SoEd55CGjv0VmTOGgigoC)bOFObapWxpFAaixnl4clWwWfsoMsbQ)Drwt7(NOg8M39(X2bb(ZH6LGGYQJmnyQRH9PsQ8akmFyG8hi6fZjEy(Fjq(7zkhE(2BOAhUDdbpEyB63imWpFlOuJBi)Dw0Y8GKGULlf6IqS1NVlefiPqQm67GsoxYJjmTh2tBKKRt3L(PSggZgCnHZN8FYiwVbQFj3o7lEuiq8fyXbyrM3oWbzMGrw5yRLPmLX(X0nWh)aZK6J7jSSpb(Pu3B(4aCMzHdPB3HHrVqwIlGndjZk)SJ2APvZJdeOkLwuEn5Ftwmk6v0j5W(NOMMGruqwKXbJCqXSIiY5ZJQFVkSCa3dOP5A85ZGGyYSZNTGShpo4cXVObtDDWirABsyZx5qGnGSsipvrRNf9KnetqCHsmHQ7)Q0dhOYnunuGvYpU)4)Slu2)GE(DKEs1UqjDVfCHIjPMNrmXQOMKxPmVlxyEC1S2I5nRwbJa9s1cmrbd)aIKga5jJdKD17Hkn11BRsyOWU9e21WRJgL46GswnhDt1)tLHjhMF5K9iSikIrJgrFeFxbnG9igVVqtXS0bgMaZMhV)e0L5ajMXL)cY7eO5vKPvt9yN9)oBR5(STiemZ7QoGYMAbHjjA5Zuh73uh7Xuh53uh5XuBJdswxdvE8VXIS2hXrU(cGWc6pTSjDmgMixOCnn8ettKd0PMQdIPjYbQsth2X0efYpr2ZwG2vRkd9LH0tW93(rMZgnPaGJSblMAZbfZlf1gbBsvG2I(Hq52K(GgeEon9G0GlkvMPPlepGqDL5ThQ66eAHrgik4cHbi7iwxGfh4KZqOU58jS6ipIK2FzarxOibrsVUMrTgGc2XuVBHwdSm4O7LKYYc2Uahszg1io2rd08W(nu(Ra0gVSM1wO38QDLT54(I4a9PwT1lT(Per80BXnxzaxmtlD7ubGuws)uxGurtOpk)KbaXvYF3i0oSk980vs(qXZnHsG(Z1zljMlMJniDD7K4sTTaqW(1T7FcMUD7b6)PDgq8kPKMeZYOlSL8ts8B1dbxXyDWy0aEiX5CH5nXaQHtmCAJqX8zmbjimqwEyyY2jHt0bGcrmQ6bpnzKo9US0wYw15Z0UE9nczKnMlkbmHewQzZO8B6FCg)hITgwOuTCh2BQ7XutvbuYwif1LppCwTls8Fg9xYG8q6)tB4yMQLJP1yrhDXOBEN2AOZvA8fEIwKvaAkZzb5PBwVm7laGKUEDbrUmboN8I5tRmajtXhnf(gPMZDRCgyNhzJ1yEi3NoWSjX5HJDnvWAa((MTFOJTJb0oXI6Aau0P0ZinOVJdoTnabAqx6EtmRD4)UZ00NXksHjuhFBpHtJ1enuol66r8AJbhDnIh34fCsdHNXC6kE0dE6xUXp0xm9Ee(ajsm3dFWn2aRUqPzIBxyjQVQ1Osge08a4hMBOBhL66KjUxA4W2IR4xTs3UIn42vChD7s75WIZXRFOUMfpeurnUM5TlyXUZFI7cMSYNWLtXu(091XVRolebG45lBgcdDStm0or590KRBR8q54xCl8so2rNe8Yxl3SC1xsq29tT9BBV8XS9lJhiSxUUG5gZVBIDrDsxZqbBWz0qVWlNDhnuHKqDARCm0O427SN6RA1zV(bPP1jQ(s(3dx2NR1LDDymheET45f9ikN8DF)RHf0ccIcRtdgvZMJCuWdqpnFe9gJKoHyJBTTzpiP6OBDnU9waOgSR7EQs7lUIrYUxNmlWarfuEjn(PbY0Zs)(Jm43F0V397p6LTr4iNyBDA37PVVrUBFUtXC091ziI5iQNeB7HWbvXJOEt6gNYqfRsK1yvOkSDZXy7tMM3r26oSKTsIZb3e8yR4WSrX3WpYGq1Jas1zgwoiLZNTFXzsMH4o0lioCnax7Cm2n5a30yIe2IhtVeTI3LSOaYp(fzdlUGhS6LVh6t70U77DCvrEexv)Sn0gPJRc1xyuBRLOmkFxWwgFdCQTB2EnQIr45r58zu3I3VEZ9evKZdVsRL2o7EFFPnZEYNW)OfL7XKfrx9ZTJHPpiS6mLkCZqvEhAqaHvbbOohf)EpgGIxsXayv4ud8RrLFLEoAfxillhMX0889Fcmsd82ioulfNyqx9VU(MbYVio42s4Ksph0b8TDIJNHCbYXXQDxLIloiH5IV)Env0x(axO6aET(y1ppGDe(8zZcgz)QLNeXRra7gAIy)OavdNdWuOlx2DDAlqWY9S)5fQA)7rhlnm720GI5rKHPtFCT2u05IKJBKNEdGnzQvvOrZy0EVn0iGPzAAx4rDHWh5GOEcIJmQGR1OySysZb4iw1o0pwD8Yj)qtECAhbYbXjTuMEy)pmUnRxArNyFxdJah5J4U8Bl3RK)ISzHlo)r(57U13TSaEKEUy3YTjmHCxLRy8L4o5YRIUd)lyIG7g7kmj(5HpFvqGjlIxLH0aW(evtTVA4xel7Flg(v2HW2v(YjlQ)ulwyg7YcjrPjOvZRjREnai9lF(23bO9NVLG3F(23VjhTktCfRAs8kxQdsiVK27)mStSuBrqModHsqfAvlw(IvIQKOAIIa3FJAW7qlRweAPubnbUIEarowU4FrEe7xIWl9(rZ8FFHOeLSre3zHrtGkctzFkWq7qoqCqQ19UMbyOv(kni1zb(sW2bMMoRGgGzmp42ySQko6roaQnRHgqDm)MrEng7p5sKGF9K6OymfyrKJ(8pMlva1vcIkFFL5rXKir04YzgruSyeAVJWM0Y0slgLF9b1e(Pt5RI6SyBlfrHxPWMp15lxYibxcAqmrD)jIYW8SvpasMlbbtm(eflSAsbQrBHg(X6Gsd1DOOHdKHU1eL0kPuzI2BeeJeJRJdAnsnNEePsRFD6xKls(Jnwo3oPuyzwm1M7HWU3wnb0vwXPyeyCBI1g0BCKub73kRqrbJePpGUfZmQmo0IKjcjf1yBTQ3fLa2bvlZaXPVxO4X9p(i2CbXC8ymgdDAzXCiaewCcObLD(Go8wfMTdo3I3uQTTzGMRJblcJ8a5GEKYCGzusN1SaF34Z9bTc1AUFQQUiZTRO6Yau26S0JpG(L9OuFPtlg1ZUhYs3E8H5S)PpN)riUoE9KAxneW0llFiyHwwFogpUDacp1xQtWNtZ3LInbIu23mXA9ietrdUjQRTdqkaq4S3GTayw(HKQvNdCFyVOPGYXnr0eSLM41Bw(NjYKd5shIfgdTwjuS8)CA9NGSFImcqaKIBguyddTazwJWjMULwoXhYLhNQK(jAGj5e)lkQZnhQ(jaMQIuVUYkQlYC2VBi8CPAlSUx3yG6x4dQsjG4PEAfF2e9frACG3)WNdVwUULstwqR8klSkohUePlRbvjQFxHDmf4HxtcHQux)E8ibNtci6pYpWpI8d4kHfNP8fBQdCDBX4lrLJ0igQhKSi4j7AzniQe2nf3Gwsv1eDw9kBsrL16npFigs7nIReAAmNkrG7MjUgf5L)jSVR1Wj05nmvIzr0jwfh)Aqea80N26uxb1lBzyLVLi7WWNmdQDToufRv8hvR2u(D)f(V99YoLamjhfIxhV8xbbDl7RlwCg17t7(E3(Gn62ImurC4buj(zGykg5QzUJeWdxT6uo53owIpkTL)WM1Rj0RD0puAXY73NFh7jSmwDQQonBzCCAO9y4jQOqOIS3o8kQYd7ixnra9gFvhjgiKmTWn)NBMmHqB64KzoyL6HjeXshxs1yq64eQjQchMpA4fVVUedxn9vfDyiGI80vFEB9x)MIUEKh1ZCI6qw((COhnDiD1gs4mv3LY3uEqnQzy3L(1KmwFjIM0LxBVH7im(sriZR6u(8)j7t8m5ZOik2H)4gZHoSCCyrEdwuu()PX12XhqxfLtGQ(cQwseoHU3RiBQFwATlmRPv55(c9f870bidHZqNZE4qUOEiFwjFVJJN86z)jraYWh9b4TTFoPtISDzbISFLkCPo0cuKy7tvITPQ8dQpvGxIeCnIAK5rvT8afuzOK)ZZ)zu6AA(kGEsqVGPFhzWUF73O7SS8dKxQ8C(8iXqE(Pdh18on6akv5(VOTUQMXYALvMsadYyfLnkvQvlgx990e1QeJmp6oaSMoBRrw(kDDcCrHYk1esKjELkilLMjIxrxsO0zssjRB)19V75B)hN4RgHv2oQACjTengACg1FggXUESiNgFZZ(qOvZTJNUz8OTBcA5(uOh72icUSYXezTcczo87a(OnxnxnhgsjZuth69bkO5ZMRBeyDrMJdxY9yQYk5nXb7hlUNO)eKDOorvACyMsQPVwnz1OvkzBt8yCdbTbfGEBNlX6UJz0Dv7K2T0p2VX92c460GGruMQANRDhVTaYxKmenv9rrOqG74C)8mu7Hts)9YShxDgcZ2zQp264C0ot31y4ILGUOZOhar7k1SOWME7yeOJwVyjTHrORW5pE8yxi0wrpIQfMFT0nfWxVnC4OwZcd3ZkBx7wkVNZoDbbyUjLk1wTVYPRLxIMxU8Nv69aM99Qn(ohnyiMUz6wNnArdv85B32QSCfGA3kVydTGUd60)okk7GSqpVLPZ3)F7D1SBBCed(zjhIHnsHH3vwTOar(w75EONJ62u5ebyxvyj7c4d5zV7VY7ol5mFKd3rRtn6PcRmd)Bi)i5odhJaWln4VAFb(Yw9uAQ(vMIY1I2lVKg1gpciYVCBQ6JQ(aBkna8UxKFXJZhDemF43GTZ3ilcZGiqp(Wj4utfMYPer8akBd7mmAo32UUVSNxUua0NUyJGGu0ORX0hrM5GDsvGqmHqtsJh1Xrefwbr(DGbkOxPXZH4mdaeZHTP3je8IQBLdH88IeXP1Pyna7JVxst6x(IUV8KbgsZERycohae(YLcDMOg9kUPsGcYmrIDUY1esU7E2sO8mvSHuUGOwfZzglqbV50kKjrjidkIKq4mRtNKsNdK0rFHorrRrLjtffujDSoCsW2YgO5AKAi9jsSpk3bYHGE)CBmmdIcFtzXTr2jw7LvX3f2jGMc5XW8oHIa0X6UiBJCBIkUoIaHf53B9wSck7qBd6(Z()xjfZ88T9d0QgcwPPx9x)E92TVTN5)8v8LcxaiU3uh2PoyufIWYyx7ZfVZqOxISayM5Uhj0Twh(gqEHJgfiYEKTmhr5hln(kt(XsUaL(REZIPr2yBJO1lMYVohAGTYunyAEDm40W6Vmyq1jrFnLh1a8KQ3hJJTG6gvpbSQOMupS4aKaPmVd1FWOoFIONmUZ0WM7PsBZUpOvikX6diApzLRYPksElI01w2fARMYZnNmBx100dAFt3AkWxWv)YkzcGF)qiOL0CHRL0Ab6Ss1KcwkLw0DvvmiA5JsCStYrM6ggzflW9jufgM0czUtuWao6faTptsfKVIBSoA1I51tPJ5VMgEUBh9F8Ec0h7iLpGGgr3fjl3CWiuyOgO0lMY0bTeIavUFXDmai1p4axtHMzcTerIOP0we4yh9HB1HD0Kw5KiiXZQeJX8KywGCeey7LkHJsZj0C0AS9IofnmfdI0)uLG2cFjOTqR3xkZeSb8D4GEInmwew(kOImCBG1ha4sCq5NGhyQOlW9emlWhep9cqvlPQ6gM5SbwUQbSqpqJWB3E9phQBMKGHgt8cYIhFVtZPXKCSlr0ScsMQhJyz4Q4yY7Gb8TWAeKXTGOOjr3fjlNMO0u5ifTd1uzDBB8rBSCLOWSwEKegecL5kw7QGBM(uyey3Minc32GMIYcBsrbtWJq4NQuuY9LIc98ZgX5N3hxlr)koYAkZ5q(Shht(hzL)TAmVJ4Qpe2lIB7fiCmKXbppmaWNiCZ3x0WpO7IKLdZZ7SiLX4PxaQIx9Q4mRKG6ZPdGsoTPolxGYYpEdWllF0wlFhPJSMKTK2KDSsIRnzRCOGN8iKr3mVpsSl9DvUXOTmiOhOOyr5QW74Pc(zwh8tcct97OHwCLwD1)A262v16VYPRjpm5ETjJgcmXT)u3PX4G867bUGg)GebMloTWhw0BtAcZLwWCYPpaQGe8g7jpsBo5bIRZwXrBJgbe4Ka)3WJmssIKrOpjZKIQY5t(Djhs8PNwSwIgs0Xx3)b8aRhNba4JdWo7BlXCwwj37eGRiDoef5kGd8B4vsI2aZlj3kII2KaJH5ad)9V9h)2dB39qn4WZ)4lFaf9F)MoSU04R4PnRc6rbA3lHOaDNo72wRuc9xpbbzPxbGsov9pR3TDjRHcR(1nEcUB3)wTe3VR6G4J3F5XBBRVM71JemsBKlxBqk9O)TCUBTKpE8FooS5aUipzadDKmkZFUJUe668jItBp)O2K8CxBYxgJEesUqZ17BUUZ0P6Rzy)6)S4WH728LnfpOK9hCE2vKEwiTwaQL)E8t2M1D)12BlJOuLgjJXGW2znIHe5QJK0hgN3DSgK5NZUzv(L)ehR53usWHdteDgyo1fW7x(1YqCJMPX73C7XjDC5kxp6jlnFEQO0Xw1kfCGDcmmkBltb1OzIzERn8HJzafEFXFV9ZR)YdB3CB5c24d68QLGCE)L9Hpx6aPDw9pC856Uq9hzTFTy)6h3VzDfH7mSB5)NLn4F2fSCqXDLu5xlkX284ZpxQ5k98uZewiQ7EnlKiSZxYsQvmt5AF)pS)UDhw1(hAWGtY0N9UHY4bMtotMyxbPZFMqkDXzIMrO309JF)7ZQN4AT)VFC1pE1zutM8b)aEX4XqLxHPsKAHZl0zm1EDl1tMimVVDBoNem3JeK0bGZF(eibNZ2T5dSB)EsQhLi0P5euXLBZfEUhCEmz(Qmc9y2yEhMEm9o3Iv3WGo9MIB6ShYM6TyI4(welhpHbgNEJK3caPwoUVjvYtll8PdL)3N(Vp]] )