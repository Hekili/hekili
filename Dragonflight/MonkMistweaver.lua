-- MonkMistweaver.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 270 )

spec:RegisterResource( Enum.PowerType.Mana )


-- Talents
spec:RegisterTalents( {
    -- Monk
    bounce_back                   = { 80717, 389577, 2 }, -- When a hit deals more than 20% of your maximum health, reduce all damage you take by 10% for 4 sec. This effect cannot occur more than once every 30 seconds.
    calming_presence              = { 80693, 388664, 1 }, -- Reduces all damage taken by 3%.
    celerity                      = { 80685, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    chi_burst                     = { 80709, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 582 Nature damage to all enemies, and 1,167 healing to the Monk and all allies in its path. Healing reduced beyond 6 targets.
    chi_torpedo                   = { 80685, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                      = { 80709, 115098, 1 }, -- A wave of Chi energy flows through friends and foes, dealing 180 Nature damage or 518 healing. Bounces up to 7 times to targets within 25 yards.
    close_to_heart                = { 80707, 389574, 2 }, -- You and your allies within 10 yards have 2% increased healing taken from all sources.
    dampen_harm                   = { 80704, 122278, 1 }, -- Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    diffuse_magic                 = { 80697, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                       = { 80679, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
    elusive_mists                 = { 80603, 388681, 2 }, -- Reduces all damage taken while channelling Soothing Mists by 0%.
    escape_from_reality           = { 80715, 394110, 2 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown. During this time, if you cast Vivify on yourself, its healing is increased by 1% and 50% of its cost is refunded.
    expeditious_fortification     = { 80681, 388813, 1 }, -- Fortifying Brew cooldown reduced by 2 min.
    eye_of_the_tiger              = { 80700, 196607, 1 }, -- Tiger Palm also applies Eye of the Tiger, dealing 356 Nature damage to the enemy and 331 healing to the Monk over 8 sec. Limit 1 target.
    fast_feet                     = { 80705, 388809, 2 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_touch                   = { 80703, 394123, 2 }, -- Touch of Death cooldown reduced by 120 sec.
    ferocity_of_xuen              = { 80706, 388674, 2 }, -- Increases all damage dealt by 2%.
    fortifying_brew               = { 80680, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 15%, reducing all damage you take by 20%.
    generous_pour                 = { 80683, 389575, 2 }, -- You and your allies within 10 yards have 10% increased avoidance.
    grace_of_the_crane            = { 80710, 388811, 2 }, -- Increases all healing taken by 2%.
    hasty_provocation             = { 80696, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    improved_paralysis            = { 80687, 344359, 1 }, -- Reduces the cooldown of Paralysis by 15 sec.
    improved_roll                 = { 80712, 328669, 1 }, -- Grants an additional charge of Roll and Chi Torpedo.
    improved_touch_of_death       = { 80684, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    improved_vivify               = { 80692, 231602, 2 }, -- Vivify healing is increased by 40%.
    ironshell_brew                = { 80681, 388814, 1 }, -- Increases Armor while Fortifying Brew is active by 25%. Increases Dodge while Fortifying Brew is active by 25%.
    paralysis                     = { 80688, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    profound_rebuttal             = { 80708, 392910, 1 }, -- Expel Harm's critical healing is increased by 50%.
    resonant_fists                = { 80702, 389578, 2 }, -- Your attacks have a chance to resonate, dealing 189 Nature damage to enemies within 8 yds.
    ring_of_peace                 = { 80698, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    save_them_all                 = { 80714, 389579, 2 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    spear_hand_strike             = { 80686, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    strength_of_spirit            = { 80682, 387276, 1 }, -- Expel Harm's healing is increased by up to 100%, based on your missing health.
    summon_black_ox_statue        = { 80716, 115315, 1 }, -- Summons a Black Ox Statue at the target location for 15 min, pulsing threat to all enemies within 20 yards. You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_jade_serpent_statue    = { 80713, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for 2,813 over 6.9 sec.
    summon_white_tiger_statue     = { 80701, 388686, 1 }, -- Summons a White Tiger Statue at the target location for 30 sec, pulsing 316 damage to all enemies every 2 sec for 30 sec.
    tiger_tail_sweep              = { 80604, 264348, 2 }, -- Increases the range of Leg Sweep by 2 yds and reduces its cooldown by 10 sec.
    transcendence                 = { 80694, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    vigorous_expulsion            = { 80711, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification        = { 80695, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant.
    windwalking                   = { 80699, 157411, 2 }, -- You and your allies within 10 yards have 10% increased movement speed.

    -- Mistweaver
    accumulating_mist             = { 80564, 388564, 1 }, -- Zen Pulse's damage and healing is increased by 25% each time Soothing Mist heals, up to 6 times. When your Soothing Mist channel ends, this effect is canceled.
    ancient_concordance           = { 80569, 388740, 2 }, -- Your Blackout Kicks strike 3 targets and have an additional 3% chance to reset the cooldown of your Rising Sun Kick while within your Faeline Stomp.
    ancient_teachings             = { 80598, 388023, 1 }, -- After casting Essence Font or Faeline Stomp, your Tiger Palm, Blackout Kick, and Rising Sun Kick heal an injured ally within 30 yards for 150% of the damage done. Lasts 15 sec.
    awakened_faeline              = { 80577, 388779, 1 }, -- Your abilities reset Faeline Stomp 100% more often. While within Faeline Stomp, your Tiger Palms strike twice and your Spinning Crane Kick heals 3 nearby allies for 70% of the damage done.
    burst_of_life                 = { 80583, 399226, 1 }, -- Life Cocoon's cooldown is reduced by 20 sec, but its absorb amount is reduced by 40%. When Life Cocoon expires, it releases a burst of mist that restores 3,964 health to 3 nearby allies.
    calming_coalescence           = { 80583, 388218, 1 }, -- Each time Soothing Mist heals, the absorb amount of your next Life Cocoon is increased by 3%, stacking up to 50 times.
    clouded_focus                 = { 80598, 388047, 1 }, -- Healing with Enveloping Mists or Vivify while channeling Soothing Mists increases their healing done by 15% and reduces their mana cost by 15%. Stacks up to 3 times. When your Soothing Mists channel ends, this effect is cancelled.
    dancing_mists                 = { 80587, 388701, 2 }, -- Renewing Mist has a 10% chance to immediately spread to an additional target when initially cast or when traveling to a new target.
    echoing_reverberation         = { 80564, 388604, 1 }, -- Zen Pulse triggers a second time at 80% effectiveness if cast on targets with Enveloping Mist.
    enveloping_breath             = { 80582, 343655, 1 }, -- While active, Yu'lon and Chi'Ji heal up to 6 nearby targets with Enveloping Breath when you cast Enveloping Mist, healing for 2,791 over 7 sec, and increasing the healing they receive from you by 10%.
    enveloping_mist               = { 80568, 124682, 1 }, -- Wraps the target in healing mists, healing for 4,507 over 7 sec, and increasing healing received from your other spells by 40%. Applies Renewing Mist for 6 seconds to an ally within 40 yds.
    essence_font                  = { 80597, 191837, 1 }, -- Unleashes a rapid twirl of healing bolts at up to 6 allies within 30 yds, every 0.9 sec for 2.6 sec. Each bolt heals a target for 516, plus an additional 223 over 8 sec. Gust of Mists will heal affected targets twice. Castable while moving.
    faeline_stomp                 = { 80560, 388193, 1 }, -- Strike the ground fiercely to expose a faeline for 30 sec, dealing 532 Nature damage to up to 5 enemies, and restores 1,163 health to up to 5 allies within 30 yds caught in the faeline. Up to 5 allies caught in the faeline are healed with an Essence Font bolt. Your abilities have a 6% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    focused_thunder               = { 80593, 197895, 1 }, -- Thunder Focus Tea now empowers your next 2 spells.
    font_of_life                  = { 80580, 337209, 1 }, -- Your Essence Font's initial heal is increased by 76 and has a chance to reduce the cooldown of Thunder Focus Tea by 1 sec.
    gift_of_the_celestials        = { 80576, 388212, 1 }, -- Reduces the cooldown of Invoke Yul'on, the Jade Serpent by 2 min, but decreases its duration to 12 sec.
    healing_elixir                = { 80572, 122281, 1 }, -- Drink a healing elixir, healing you for 15% of your maximum health.
    improved_detox                = { 81634, 388874, 1 }, -- Detox additionally removes all Poison and Disease effects.
    invigorating_mists            = { 80559, 274586, 1 }, -- Vivify heals all allies with your Renewing Mist active for 1,396.
    invoke_chiji                  = { 80590, 325197, 1 }, -- Summon an effigy of Chi-Ji for 25 sec that kicks up a Gust of Mist when you Blackout Kick, Rising Sun Kick, or Spinning Crane Kick, healing up to 2 allies for 1,325, and reducing the cost and cast time of your next Enveloping Mist by 33%, stacking. Chi-Ji's presence makes you immune to movement impairing effects.
    invoke_chiji_the_red_crane    = { 80590, 325197, 1 }, -- Summon an effigy of Chi-Ji for 25 sec that kicks up a Gust of Mist when you Blackout Kick, Rising Sun Kick, or Spinning Crane Kick, healing up to 2 allies for 1,325, and reducing the cost and cast time of your next Enveloping Mist by 33%, stacking. Chi-Ji's presence makes you immune to movement impairing effects.
    invoke_yulon                  = { 80590, 322118, 1 }, -- Summons an effigy of Yu'lon, the Jade Serpent for 25 sec. Yu'lon will heal injured allies with Soothing Breath, healing the target and up to 2 allies for 1,343 over 3.9 sec. Enveloping Mist costs 50% less mana while Yu'lon is active.
    invoke_yulon_the_jade_serpent = { 80590, 322118, 1 }, -- Summons an effigy of Yu'lon, the Jade Serpent for 25 sec. Yu'lon will heal injured allies with Soothing Breath, healing the target and up to 2 allies for 1,343 over 3.9 sec. Enveloping Mist costs 50% less mana while Yu'lon is active.
    invokers_delight              = { 80571, 388661, 1 }, -- You gain 33% haste for 20 sec after summoning your Celestial.
    jade_bond                     = { 80576, 388031, 1 }, -- Abilities that activate Gust of Mist reduce the cooldown on Invoke Yul'on, the Jade Serpent by 0.3 sec, and Yu'lon's Soothing Breath healing is increased by 40.0%.
    life_cocoon                   = { 80584, 116849, 1 }, -- Encases the target in a cocoon of Chi energy for 12 sec, absorbing 27,270 damage and increasing all healing over time received by 50%.
    lifecycles                    = { 80575, 197915, 1 }, -- Enveloping Mist reduces the mana cost of your next Vivify by 25%. Vivify reduces the mana cost of your next Enveloping Mist by 25%.
    mana_tea                      = { 80575, 197908, 1 }, -- Reduces the mana cost of your spells by 50% for 10 sec.
    mastery_of_mist               = { 80589, 281231, 1 }, -- Renewing Mist now has 2 charges.
    mending_proliferation         = { 80573, 388509, 1 }, -- Each time Enveloping Mist heals, its healing bonus has a 50% chance to spread to an injured ally within 30 yds.
    mist_wrap                     = { 80563, 197900, 1 }, -- Increases Enveloping Mist's duration by 1 sec and its healing bonus by 10%.
    mists_of_life                 = { 80567, 388548, 1 }, -- Life Cocoon applies Renewing Mist and Enveloping Mist to the target.
    misty_peaks                   = { 80594, 388682, 2 }, -- Renewing Mist's heal over time effect has a 5% chance to proc Enveloping Mist for 2 sec.
    nourishing_chi                = { 80599, 387765, 1 }, -- Life Cocoon increases healing over time received by an additional 20.0%, and this effect lingers for an additional 10 sec after the cocoon is removed.
    overflowing_mists             = { 80581, 388511, 2 }, -- Your Enveloping Mists heal the target for 2.0% of their maximum health each time they take damage.
    peaceful_mending              = { 80592, 388593, 2 }, -- Allies targeted by Soothing Mist receive 10% more healing from your Enveloping Mist and Renewing Mist effects.
    rapid_diffusion               = { 80579, 388847, 2 }, -- Rising Sun Kick and Enveloping Mist apply Renewing Mist for 6 seconds to an ally within 40 yds.
    refreshing_jade_wind          = { 80563, 196725, 1 }, -- Summon a whirling tornado around you, causing 3,551 healing over 13.0 sec to up to 6 allies within 10 yards.
    renewing_mist                 = { 80588, 115151, 1 }, -- Surrounds the target with healing mists, restoring 2,904 health over 20 sec. If Renewing Mist heals a target past maximum health, it will travel to another injured ally within 20 yds.
    resplendent_mist              = { 80585, 388020, 2 }, -- Gust of Mists has a 30% chance to do 100% more healing.
    restoral                      = { 80574, 388615, 1 }, -- Heals all party and raid members within 40 yards for 4,162 and clears them of all harmful Poison and Disease effects. Castable while stunned. Healing increased by 100% when not in a raid.
    revival                       = { 80574, 115310, 1 }, -- Heals all party and raid members within 40 yards for 4,162 and clears them of all harmful Magical, Poison, and Disease effects. Healing increased by 100% when not in a raid.
    rising_mist                   = { 80558, 274909, 1 }, -- Rising Sun Kick heals all allies with your Renewing Mist, Enveloping Mist, or Essence Font for 306, and extends those effects by 4 sec, up to 100% of their original duration.
    rising_sun_kick               = { 80690, 107428, 1 }, -- Kick upwards, dealing 2,712 Physical damage. Applies Renewing Mist for 6 seconds to an ally within 40 yds
    secret_infusion               = { 80570, 388491, 2 }, -- After using Thunder Focus Tea, your next spell gives 5% of a stat for 10 sec: Enveloping Mist: Critical strike Renewing Mist: Haste Vivify: Mastery Rising Sun Kick: Versatility Essence Font: Haste
    shaohaos_lessons              = { 80596, 400089, 1 }, -- Each time you cast Sheilun's Gift, you learn one of Shaohao's Lessons for up to 30 sec, based on how many clouds of mist are consumed. Lesson of Doubt: Your spells and abilities deal up to 35% more healing and damage to targets, based on their current health. Lesson of Despair: Your Critical Strike is increased by 30% while above 50% health. Lesson of Fear: Decreases your damage taken by 15% and increases your Haste by 25%. Lesson of Anger: 25% of the damage or healing you deal is duplicated every 4 sec.
    sheiluns_gift                 = { 80586, 399491, 1 }, -- Draws in all nearby clouds of mist, healing up to 3 nearby allies for 1,220 per cloud absorbed. A cloud of mist is generated every 8 sec while in combat.
    song_of_chiji                 = { 80561, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for 20 sec.
    soothing_mist                 = { 80691, 115175, 1 }, -- Heals the target for 5,627 over 6.9 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target. Each heal has a chance to cause a Gust of Mists on the target.
    spirit_of_the_crane           = { 80562, 210802, 1 }, -- Teachings of the Monastery causes each additional Blackout Kick to restore 0.45% mana.
    tea_of_plenty                 = { 80565, 388517, 1 }, -- Thunder Focus Tea also empowers 2 additional Renewing Mist, Essence Font, or Rising Sun Kick at random.
    tea_of_serenity               = { 80565, 393460, 1 }, -- Thunder Focus Tea also empowers 2 additional Renewing Mist, Enveloping Mist, or Vivify at random.
    teachings_of_the_monastery    = { 80595, 116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to 3. Blackout Kick has a 15% chance to reset the remaining cooldown on Rising Sun Kick.
    tear_of_morning               = { 80558, 387991, 1 }, -- Casting Vivify or Enveloping Mist on a target with Renewing Mist has a 10% chance to spread the Renewing Mist to another target. Your Vivify healing through Renewing Mist is increased by 20% and your Enveloping Mist also heals allies with Renewing Mist for 20% of its healing.
    thunder_focus_tea             = { 80600, 116680, 1 }, -- Receive a jolt of energy, empowering your next 2 spells cast: Enveloping Mist: Immediately heals for 3,401. Renewing Mist: Duration increased by 10 sec. Vivify: No mana cost. Rising Sun Kick: Cooldown reduced by 9 sec. Essence Font: Channels 100% faster.
    tigers_lust                   = { 80689, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    unison                        = { 80573, 388477, 1 }, -- Soothing Mist heals a second injured ally within 15 yds for 100% of the amount healed.
    uplifted_spirits              = { 80591, 388551, 1 }, -- Vivify critical strikes and Rising Sun Kicks reduce the remaining cooldown on Revival by 1.0 sec, and Revival heals targets for 15.0% of Revival's heal over 10 sec.
    upwelling                     = { 80593, 274963, 1 }, -- For every 6 sec Essence Font spends off cooldown, your next Essence Font may be channeled for 1 additional second. The duration of Essence Font's heal over time is increased by 4 sec.
    veil_of_pride                 = { 80596, 400053, 1 }, -- Increases Sheilun's Gift cloud of mist generation to every 4 sec.
    yulons_whisper                = { 80578, 388038, 1 }, -- Activating Thunder Focus Tea causes you to exhale the breath of Yu'lon, healing up to 5 allies within 15 yards for 1,886 over 2 sec.
    zen_pulse                     = { 80566, 124081, 1 }, -- Trigger a Zen Pulse around an ally. Deals 2,013 damage to all enemies within 8 yds of the target. The ally is healed for 2,127 per enemy damaged.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_tiger          = 5551, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you 20% haste for 8 sec. This effect cannot occur more than once every 30 sec per target.
    chrysalis            = 678 , -- (202424) Reduces the cooldown of Life Cocoon by 45 sec.
    counteract_magic     = 679 , -- (353502) Removing hostile magic effects from a target increases the healing they receive from you by 10% for 10 sec, stacking up to 3 times.
    dematerialize        = 5398, -- (353361) Demateralize into mist while stunned, reducing damage taken by 30%. Each second you remain stunned reduces this bonus by 10%.
    dome_of_mist         = 680 , -- (202577) Enveloping Mist transforms 100% of its remaining periodic healing into a Dome of Mist when dispelled.  Dome of Mist Absorbs damage. All healing received by the Monk increased by 30%. Lasts 8 sec.
    eminence             = 70  , -- (353584) Transcendence: Transfer can now be cast if you are stunned. Cooldown reduced by 15 sec if you are not.
    grapple_weapon       = 3732, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 6 sec.
    healing_sphere       = 683 , -- (205234) Coalesces a Healing Sphere out of the mists at the target location after 1.5 sec. If allies walk through it, they consume the sphere, healing themselves for 1,790 and dispelled of all harmful periodic magic effects. Maximum of 3 Healing Spheres can be active by the Monk at any given time.
    mighty_ox_kick       = 5539, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    peaceweaver          = 5395, -- (353313) Revival's cooldown is reduced by 50%, and provides immunity to magical damage and harmful effects for 2 sec.
    precognition         = 5508, -- (377360) If an interrupt is used on you while you are not casting, gain 15% Haste and become immune to crowd control, interrupt, and cast pushback effects for 5 sec.
    refreshing_breeze    = 682 , -- (353508) During Soothing Mist's channel, Expel Harm's healing is increased by 15%, and dispels 1 Magic, Disease, and Poison effect from the target. Stacks each time Soothing Mist heals the target.
    thunderous_focus_tea = 5402, -- (353936) Thunder Focus Tea can now additionally cause Crackling Jade Lightning's knockback immediately, or cause Essence Font to increase your movement speed by 70% and provide immunity to movement impairing effects.
    zen_focus_tea        = 1928, -- (209584) Provides immunity to Silence and Interrupt effects for 5 sec.
} )


-- Auras
spec:RegisterAuras( {
    accumulating_mist = {
        id = 388566,
        duration = 30,
        max_stack = 6
    },
    ancient_concordance = {
        id = 389391,
        duration = 3600,
        max_stack = 1
    },
    ancient_teachings = {
        id = 388026,
        duration = 15,
        max_stack = 1
    },
    awakened_faeline = {
        id = 389387,
        duration = 3600,
        max_stack = 1
    },
    bonedust_brew = {
        id = 386276,
        duration = 10,
        max_stack = 1
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    calming_coalescence = {
        id = 388220,
        duration = 3600,
        max_stack = 50
    },
    chi_burst = { -- TODO: Hidden aura that procs Chi per enemy targeted.
        id = 123986,
        duration = 1,
        max_stack = 1
    },
    chi_torpedo = { -- Movement buff.
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    close_to_heart = {
        id = 389684,
        duration = 3600,
        max_stack = 1,
        copy = 389574
    },
    clouded_focus = {
        id = 388048,
        duration = 8,
        max_stack = 3
    },
    crackling_jade_lightning = {
        id = 117952,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    dampen_harm = {
        id = 122278,
        duration = 10,
        max_stack = 1
    },
    diffuse_magic = {
        id = 122783,
        duration = 6,
        max_stack = 1
    },
    disable = {
        id = 116095,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    enveloping_mist = {
        id = 124682,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    essence_font = {
        id = 344006,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        copy = 191840
    },
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    fae_exposure_buff = {
        id = 356774,
        duration = 10,
        max_stack = 1,
        friendly = true
    },
    fae_exposure_debuff = {
        id = 356773,
        duration = 10,
        max_stack = 1
    },
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1
    },
    fatal_touch = {
        id = 337296,
        duration = 3600,
        max_stack = 1
    },
    generous_pour = {
        id = 389685,
        duration = 3600,
        max_stack = 1
    },
    grapple_weapon = {
        id = 233759,
        duration = 6,
        max_stack = 1
    },
    invoke_chiji_the_red_crane = { -- This is not the presence of the totem, but the buff stacks gained while totem is up.
        id = 343820,
        duration = 20,
        max_stack = 3,
        copy = { "invoke_chiji", "chiji_the_red_crane", "chiji" }
    },
    invoke_yulon_the_jade_serpent = { -- Misleading; use pet.yulon.up or totem.yulon.up instead.
        id = 322118,
        duration = 25,
        tick_time = 1,
        max_stack = 1,
        copy = { "invoke_yulon", "yulon_the_jade_serpent", "yulon" }
    },
    invokers_delight = {
        id = 388663,
        duration = 20,
        max_stack = 1
    },
    leg_sweep = {
        id = 119381,
        duration = 3,
        max_stack = 1
    },
    life_cocoon = {
        id = 116849,
        duration = 12,
        max_stack = 1
    },
    mana_tea = {
        id = 197908,
        duration = 10,
        max_stack = 1
    },
    mastery_gust_of_mists = {
        id = 117907,
    },
    mystic_touch = {
        id = 8647,
    },
    overflowing_mists = {
        id = 388513,
        duration = 6,
        max_stack = 1
    },
    paralysis = {
        id = 115078,
        duration = 60,
        max_stack = 1
    },
    profound_rebuttal = {
        id = 392910,
    },
    refreshing_jade_wind = {
        id = 196725,
        duration = 9,
        tick_time = 0.75,
        max_stack = 1
    },
    ring_of_peace = {
        id = 116844,
        duration = 5,
        max_stack = 1
    },
    save_them_all = {
        id = 389579,
    },
    secret_infusion = {
        alias = { "secret_infusion_critical_strike", "secret_infusion_haste", "secret_infusion_mastery", "secret_infusion_versatility" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 10,
    },
    secret_infusion_critical_strike = {
        id = 388498,
        duration = 10,
        max_stack = 1,
        copy = "secret_infusion_crit"
    },
    secret_infusion_haste = {
        id = 388497,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_mastery = {
        id = 388499,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_versatility = {
        id = 388500,
        duration = 10,
        max_stack = 1
    },
    song_of_chiji = {
        id = 198909,
        duration = 20,
        max_stack = 1
    },
    soothing_breath = { -- Applied by Yu'lon while active.
        id = 343737,
        duration = 25,
        max_stack = 1,
    },
    soothing_mist = {
        id = 115175,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    spinning_crane_kick = {
        id = 101546,
        duration = 1.5,
        tick_time = 0.5,
        max_stack = 1
    },
    strength_of_spirit = {
        id = 387276,
    },
    summon_black_ox_statue = { -- TODO: Is a totem.
        id = 115315,
        duration = 900,
        max_stack = 1
    },
    summon_jade_serpent_statue = { -- TODO: Is a totem.
        id = 115313,
        duration = 900,
        max_stack = 1
    },
    summon_white_tiger_statue = { -- TODO: Is a totem.
        id = 388686,
        duration = 30,
        max_stack = 1
    },
    teachings_of_the_monastery = {
        id = 202090,
        duration = 10,
        max_stack = 3
    },
    thunder_focus_tea = {
        id = 116680,
        duration = 30,
        max_stack = 1,
        onRemove = function()
            setCooldown( "thunder_focus_tea", 30 )
        end,
    },
    tigers_lust = {
        id = 116841,
        duration = 6,
        max_stack = 1
    },
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transcendence_transfer = {
        id = 119996,
    },
    vigorous_expulsion = {
        id = 392900,
    },
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    yulons_whisper = { -- TODO: If needed, this would be triggered by TFT cast.
        id = 388040,
        duration = 2,
        tick_time = 1,
        max_stack = 1
    },
    zen_flight = {
        id = 125883,
        duration = 3600,
        max_stack = 1
    },
    zen_focus_tea = {
        id = 209584,
        duration = 5,
        max_stack = 1
    },
    zen_pilgrimage = {
        id = 126892,
    },
} )


spec:RegisterTotem( "chiji", 877514 )
spec:RegisterTotem( "yulon", 574571 )

spec:RegisterStateTable( "gust_of_mist", setmetatable( {}, {
    __index = function( t,  k)
        if k == "count" then
            t[ k ] = GetSpellCount( action.sheiluns_gift.id )
            return t[ k ]
        end
    end
} ) )

spec:RegisterHook( "reset_precast", function()
    gust_of_mist.count = nil
end )


-- Abilities
spec:RegisterAbilities( {
    -- Strike with a blast of Chi energy, dealing 1,429 Physical damage and granting Shuffle for 3 sec.
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            removeBuff( "teachings_of_the_monastery" )
            if pet.chiji.up then
                addStack( "invoke_chiji" )
                gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
            end
        end,
    },

    enveloping_mist = {
        id = 124682,
        cast = function()
            if buff.invoke_chiji.stack == 3 then return 0 end
            return 2 * ( 1 - 0.333 * buff.invoke_chiji.stack ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            return pet.yulon.up and 0.12 or 0.24
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 775461,

        handler = function ()
            removeBuff( "invoke_chiji" )
            gust_of_mist.count = 0

            applyBuff( "enveloping_mist" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_versatility" ) end
        end,
    },

    essence_font = {
        id = 191837,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.36,
        spendType = "mana",

        startsCombat = false,
        texture = 1360978,

        handler = function ()
            applyBuff( "essence_font" )
            if talent.ancient_teachings.enabled then applyBuff( "ancient_teachings" ) end
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_haste" ) end
        end,
    },

    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 627486,

        handler = function ()
        end,
    },

    invoke_chiji_the_red_crane = {
        id = 325197,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 877514,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "chiji", nil, 25 )
        end,

        copy = "invoke_chiji"
    },

    invoke_yulon_the_jade_serpent = {
        id = 322118,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 574571,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "yulon", nil, 25 )
        end,

        copy = "invoke_yulon"
    },

    life_cocoon = {
        id = 116849,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.12,
        spendType = "mana",

        startsCombat = false,
        texture = 627485,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "life_cocoon" )
        end,
    },

    mana_tea = {
        id = 197908,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        startsCombat = false,
        texture = 608949,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "mana_tea" )
        end,
    },

    -- You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        pvptalent = "mighty_ox_kick",
        startsCombat = false,
        texture = 1381297,

        handler = function ()
        end,
    },

    reawaken = {
        id = 212051,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1056569,

        handler = function ()
        end,
    },

    refreshing_jade_wind = {
        id = 196725,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 606549,

        handler = function ()
        end,
    },

    renewing_mist = {
        id = 115151,
        cast = 0,
        charges = 2,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 627487,

        handler = function ()
            applyBuff( "renewing_mist" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_haste" ) end
        end,
    },

    restoral = {
        id = 388615,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = 0.2187,
        spendType = "mana",

        startsCombat = false,
        texture = 1381300,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    resuscitate = {
        id = 115178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 132132,

        handler = function ()
        end,
    },

    revival = {
        id = 115310,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = 0.2187,
        spendType = "mana",

        startsCombat = false,
        texture = 1020466,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Talent: Kick upwards, dealing 3,359 Physical damage.
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = function() return ( buff.thunder_focus_tea.up and 3 or 12 ) * haste end,
        gcd = "spell",
        school = "physical",

        talent = "rising_sun_kick",
        startsCombat = true,

        handler = function ()
            if state.spec.mistweaver then
                if talent.rapid_diffusion.enabled then
                    if solo then applyBuff( "renewing_mist", 3 * talent.rapid_diffusion.rank )
                    else active_dot.renewing_mist = max( group_members, active_dot.renewing_mist + 1 ) end
                end
                if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_versatility" ) end
                if pet.chiji.up then
                    addStack( "invoke_chiji" )
                    gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
                end
                removeStack( "thunder_focus_tea" )
            end
        end,
    },

    -- Draws in all nearby clouds of mist, healing up to 3 nearby allies for 1,220 per cloud absorbed. A cloud of mist is generated every 8 sec while in combat.
    sheiluns_gift = {
        id = 399491,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "sheiluns_gift",
        startsCombat = false,
        texture = 1242282,

        usable = function()
            return gust_of_mist.count > 0, "requires mists"
        end,

        handler = function ()
            gust_of_mist.count = 0
        end,
    },

    song_of_chiji = {
        id = 198898,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 332402,

        handler = function ()
            applyDebuff( "target", "song_of_chiji" )
        end,
    },

    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "totem",

        spend = 0.16,
        spendType = "mana",

        startsCombat = false,
        texture = 606550,

        handler = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    spinning_crane_kick = {
        id = 101546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyBuff( "spinning_crane_kick" )
            if pet.chiji.up then
                addStack( "invoke_chiji" )
                gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
            end
        end,
    },

    thunder_focus_tea = {
        id = 116680,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 611418,
        nobuff = "thunder_focus_tea",

        handler = function ()
            addStack( "thunder_focus_tea", nil, talent.focused_thunder.enabled and 2 or 1 )
        end,
    },

    -- Strike with the palm of your hand, dealing 568 Physical damage. Reduces the remaining cooldown on your Brews by 1 sec.
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end
            if talent.teachings_of_the_monastery.enabled then
                addStack( "teachings_of_the_monastery" )
            end
        end,
    },

    vivify = {
        id = 116670,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.19,
        spendType = "mana",

        startsCombat = false,
        texture = 1360980,

        handler = function ()
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_mastery" ) end
        end,
    },

    zen_focus_tea = {
        id = 209584,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 651940,

        handler = function ()
            applyBuff( "zen_focus_tea" )
        end,
    },

    -- Trigger a Zen Pulse around an ally. Deals 2,013 damage to all enemies within 8 yds of the target. The ally is healed for 2,127 per enemy damaged.
    zen_pulse = {
        id = 124081,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 613397,

        handler = function ()
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )

spec:RegisterSetting( "save_faeline", false, {
    type = "toggle",
    name = "|T3636842:0|t Faeline Stomp: Don't Reuse",
    desc = "If checked, the default priority will not recommend |T3636842:0|t Faeline Stomp when you already have |T3528274:0|t Ancient Concordance and/or |T3528275:0|t Awakened Faeline active.\n\n"
        .. "This may be desired from a mana efficiency standpoint.",
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = true,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Mistweaver",

    strict = false
} )


spec:RegisterPack( "Mistweaver", 20230216, [[Hekili:nF1wVTTnu4Fl5LMeSunFjlDDioaDdyanyRVO(SKOPOS5SePgjvDmGb)TVpk5l00YXEfBD7HeBZZhpNd)ox4Hjdt(CsCoXWs(0ObJgpy0WhIgoA447Vpj2SQMLextOliZWxeKk8)FNRnlzKVWuorRkLKCNk0YgffItIN2WlnFuKmTF9ogyRzuS87gKepNNNZ6WY00Kyh23oy0Bh(WpzZSzFasZTzYAdxkSzgPnJ8fjhlPyuI2WfZSz)kHvYfmBwSrwvBZwoNbSAdrK3kNJFrWFSx4B2rX2DCtHuzZQiccexuWPCMGU62iC0uYcEjoqeQZ26OAyrz1uI57M891Yw)55(KrNZtN2O0MtlEjyp7Z7KJvbJquPZHhNQnk(cMVWgnlLByvA)fNwkL5PfnQvhSktPzQfUdP3QL8zZn60)OjFwfty8fvWvSwv5VirqzWniLPusz5b6NmlvwKcxKU4a3jGrCAUJJX5bbL74ftUsZmo6xhPX5pDJ81RV6MPnffrWOG8nPuPGkv5oFiQPE96oHljlycw(2Dbj36BmNFM29Z0seLVZLRoHiz35OtQzYqNh4aaldfvXz6NMm(8QaFEAn84yVOyK2fEnZBe5mvAHK2OtnmsGCfxdkiv3isxaomq60suRjBmTYA5mdPeKseuesCa31Y(ZzPvsbs)zQvBiOtdau1BOszzUCPikW8rkwfHl0pnJMhvrEjWD2NRE0Ybz4DND(mCYRjLv)t56OgMU4XXNh4MZXJJ8dii83xePN4OxMWMDfqux0E(3k6DwdFCCA)6bbQob6AUq4oFufbLOo)njgD01aZ2(1dEFs8sIYbtNe)55OBjVQwQmO9PRP51qvx76d)NnOhc6iRLvadPb17OTpwGI(zZy6i7Z)wBZ2XOL(VifWoTIV(SSZ1DD8ppWiMGmTKLJnCZWxUnYLf0JhRn))1H7S4dFdTO95p2YoodDp4bA3DSUEFokijU9BU72rKgF8P2rf2OMKFojMQWTskoP7oY9zO2ShNaYB7vNyoIWsWedYY(A1wqPPtxJpPUUc8ZLsn2S1RTzNVG0M9Mo66vCYd6f4CX7BjYns3wW670aZpeIPT4na0d(G6Tq2ho2n0W2G3PdihAJr(Gd57dH(Fa1FUBZSzpzZ2CJ23SiY3ikO9grKTHKTlBd74eSLrEza7URUljjNvqAkpot5ObtFTmLDdQ2xoY(4W2bxdqDq8y)GSVwejyW2xRsz3GUbGENpOdh8na5pEG)5piCaW37dSBW4aedh8APm9oNCx0gsVztmV)5L9sk6zMzB2TEmI)a6TE1L3G)PUUDDJg7sz2xKemgD31iPDVD0DrId(FJE)Fv2rB6YQ39WRJYR7nSm6sQ2hF(2gT2gZvmxI3i)b(c88YfK2vt(R]] )