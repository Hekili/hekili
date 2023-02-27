-- MonkBrewmaster.lua
-- November 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 268 )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.Chi )

-- Talents
spec:RegisterTalents( {
    -- Monk
    bounce_back                         = { 80717, 389577, 2 }, -- When a hit deals more than 20% of your maximum health, reduce all damage you take by 10% for 4 sec. This effect cannot occur more than once every 30 seconds.
    calming_presence                    = { 80693, 388664, 1 }, -- Reduces all damage taken by 3%.
    celerity                            = { 80685, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    chi_burst                           = { 80709, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 1,182 Nature damage to all enemies, and 2,169 healing to the Monk and all allies in its path. Healing reduced beyond 6 targets. Casting Chi Burst does not prevent avoiding attacks.
    chi_torpedo                         = { 80685, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                            = { 80709, 115098, 1 }, -- A wave of Chi energy flows through friends and foes, dealing 365 Nature damage or 876 healing. Bounces up to 7 times to targets within 25 yards.
    close_to_heart                      = { 80707, 389574, 2 }, -- You and your allies within 10 yards have 2% increased healing taken from all sources.
    dampen_harm                         = { 80704, 122278, 1 }, -- Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    diffuse_magic                       = { 80697, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                             = { 80679, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
    elusive_mists                       = { 80603, 388681, 2 }, -- Reduces all damage taken while channelling Soothing Mists by 0%.
    escape_from_reality                 = { 80715, 394110, 2 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown. During this time, if you cast Vivify on yourself, its healing is increased by 1% and 50% of its cost is refunded.
    expeditious_fortification           = { 80681, 388813, 1 }, -- Fortifying Brew cooldown reduced by 2 min.
    eye_of_the_tiger                    = { 80700, 196607, 1 }, -- Tiger Palm also applies Eye of the Tiger, dealing 592 Nature damage to the enemy and 529 healing to the Monk over 8 sec. Limit 1 target.
    fast_feet                           = { 80705, 388809, 2 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_touch                         = { 80703, 394123, 2 }, -- Touch of Death cooldown reduced by 120 sec.
    ferocity_of_xuen                    = { 80706, 388674, 2 }, -- Increases all damage dealt by 2%.
    fortifying_brew                     = { 80680, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 15%, reducing all damage you take by 20%, increasing your armor by 25% and dodge chance by 25%.
    generous_pour                       = { 80683, 389575, 2 }, -- You and your allies within 10 yards have 10% increased avoidance.
    grace_of_the_crane                  = { 80710, 388811, 2 }, -- Increases all healing taken by 2%.
    hasty_provocation                   = { 80696, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    improved_paralysis                  = { 80687, 344359, 1 }, -- Reduces the cooldown of Paralysis by 15 sec.
    improved_roll                       = { 80712, 328669, 1 }, -- Grants an additional charge of Roll and Chi Torpedo.
    improved_touch_of_death             = { 80684, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    improved_vivify                     = { 80692, 231602, 2 }, -- Vivify healing is increased by 40%.
    ironshell_brew                      = { 80681, 388814, 1 }, -- Increases Armor while Fortifying Brew is active by 25%. Increases Dodge while Fortifying Brew is active by 25%.
    paralysis                           = { 80688, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    profound_rebuttal                   = { 80708, 392910, 1 }, -- Expel Harm's critical healing is increased by 50%.
    resonant_fists                      = { 80702, 389578, 2 }, -- Your attacks have a chance to resonate, dealing 192 Nature damage to enemies within 8 yds.
    ring_of_peace                       = { 80698, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    save_them_all                       = { 80714, 389579, 2 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    spear_hand_strike                   = { 80686, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    strength_of_spirit                  = { 80682, 387276, 1 }, -- Expel Harm's healing is increased by up to 100%, based on your missing health.
    summon_black_ox_statue              = { 80716, 115315, 1 }, -- Summons a Black Ox Statue at the target location for 15 min, pulsing threat to all enemies within 20 yards. You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_jade_serpent_statue          = { 80713, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for 4,746 over 6.9 sec.
    summon_white_tiger_statue           = { 80701, 388686, 1 }, -- Summons a White Tiger Statue at the target location for 30 sec, pulsing 584 damage to all enemies every 2 sec for 30 sec.
    tiger_tail_sweep                    = { 80604, 264348, 2 }, -- Increases the range of Leg Sweep by 2 yds and reduces its cooldown by 10 sec.
    transcendence                       = { 80694, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    vigorous_expulsion                  = { 80711, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification              = { 80695, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant.
    windwalking                         = { 80699, 157411, 2 }, -- You and your allies within 10 yards have 10% increased movement speed.

    -- Brewmaster
    anvil_stave                         = { 80634, 386937, 2 }, -- Each time you dodge or an enemy misses you, the remaining cooldown on your Brews is reduced by 0.5 sec. This effect can only occur once every 3 sec.
    attenuation                         = { 80728, 386941, 1 }, -- Bonedust Brew's Shadow damage or healing is increased by 20.0%, and when Bonedust Brew deals Shadow damage or healing, its cooldown is reduced by 0.5 sec.
    black_ox_brew                       = { 80636, 115399, 1 }, -- Chug some Black Ox Brew, which instantly refills your Energy, Purifying Brew charges, and resets the cooldown of Celestial Brew.
    blackout_combo                      = { 80601, 196736, 1 }, -- Blackout Kick also empowers your next ability: Tiger Palm: Damage increased by 100%. Breath of Fire: Periodic damage increased by 50%, and damage reduction increased by 5%. Keg Smash: Reduces the remaining cooldown on your Brews by 2 additional sec. Celestial Brew: Gain up to 3 additional stacks of Purified Chi. Purifying Brew: Pauses Stagger damage for 3 sec.
    bob_and_weave                       = { 80636, 280515, 1 }, -- Increases the duration of Stagger by 3.0 sec.
    bonedust_brew                       = { 80729, 386276, 1 }, -- Hurl a brew created from the bones of your enemies at the ground, coating all targets struck for 10 sec. Your abilities have a 50% chance to affect the target a second time at 40% effectiveness as Shadow damage or healing. Tiger Palm and Keg Smash reduces the cooldown of your brews by an additional 1 sec when striking enemies with your Bonedust Brew active. Your abilities have a low chance to cast Bonedust Brew at your target's location.
    bountiful_brew                      = { 80728, 386949, 1 }, -- Your abilities have a low chance to cast Bonedust Brew at your target's location.
    breath_of_fire                      = { 80650, 115181, 1 }, -- Breathe fire on targets in front of you, causing 1,121 Fire damage. Deals reduced damage to secondary targets. Targets affected by Keg Smash will also burn, taking 778 Fire damage and dealing 5% reduced damage to you for 12 sec.
    call_to_arms                        = { 80718, 397251, 1 }, -- Weapons of Order calls forth Niuzao, the Black Ox to assist you for 12 sec.
    celestial_brew                      = { 80649, 322507, 1 }, -- A swig of strong brew that coalesces purified chi escaping your body into a celestial guard, absorbing 18,872 damage.
    celestial_flames                    = { 80646, 325177, 1 }, -- Drinking from Brews has a 30% chance to coat the Monk with Celestial Flames for 6 sec. While Celestial Flames is active, Spinning Crane Kick applies Breath of Fire and Breath of Fire reduces the damage affected enemies deal to you by an additional 5%.
    charred_passions                    = { 80651, 386965, 1 }, -- Your Breath of Fire ignites your right leg in flame for 8 sec, causing your Blackout Kick and Spinning Crane Kick to deal 50% additional damage as Fire damage and refresh the duration of your Breath of Fire on the target.
    chi_surge                           = { 80718, 393400, 1 }, -- Weapons of Order releases a surge of chi at your target's location, dealing 11,361 Nature damage split evenly between all targets over 8 sec. Reduce the cooldown of Weapons of Order by 4 sec per affected enemy, to a maximum of 20 sec.
    clash                               = { 80629, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    counterstrike                       = { 80630, 383785, 1 }, -- Each time you dodge or an enemy misses you, your next Tiger Palm or Spinning Crane Kick deals 100% increased damage.
    detox                               = { 81633, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    dragonfire_brew                     = { 80651, 383994, 1 }, -- After using Breath of Fire, you breathe fire 2 additional times, each dealing 467 Fire damage. Breath of Fire damage increased by up to 100% based on your level of Stagger.
    elusive_footwork                    = { 80602, 387046, 2 }, -- Blackout Kick deals an additional 5% damage. Blackout Kick critical hits grant an additional 1 stack of Elusive Brawler.
    exploding_keg                       = { 80722, 325153, 1 }, -- Hurls a flaming keg at the target location, dealing 6,028 Fire damage to nearby enemies, causing your attacks against them to deal 467 additional Fire damage, and causing their melee attacks to deal 100% reduced damage for the next 3 sec.
    face_palm                           = { 80631, 389942, 1 }, -- Tiger Palm has a 50% chance to deal 200% of normal damage and reduce the remaining cooldown of your Brews by 1 additional sec.
    fluidity_of_motion                  = { 80632, 387230, 1 }, -- Blackout Kick's cooldown is reduced by 1 sec and its damage by 10%.
    fortifying_brew_determination       = { 80654, 322960, 1 }, -- Fortifying Brew increases Stagger effectiveness by 15% while active. Combines with other Fortifying Brew effects.
    fundamental_observation             = { 80628, 387035, 1 }, -- Zen Meditation has 25% reduced cooldown and is no longer cancelled when you move or when you are hit by melee attacks.
    gai_plins_imperial_brew             = { 80725, 383700, 1 }, -- Purifying Brew instantly heals you for 25% of the purified Stagger damage.
    gift_of_the_ox                      = { 80638, 124502, 1 }, -- When you take damage, you have a chance to summon a Healing Sphere. Healing Sphere: Summon a Healing Sphere visible only to you. Moving through this Healing Sphere heals you for 5,009.
    graceful_exit                       = { 80643, 387256, 1 }, -- After you successfully dodge or an enemy misses you, you gain 10% increased movement speed for 3 sec. Max 3 stacks.
    healing_elixir                      = { 80644, 122281, 1 }, -- Drink a healing elixir, healing you for 15% of your maximum health.
    high_tolerance                      = { 80653, 196737, 2 }, -- Stagger is 5% more effective at delaying damage. You gain up to 10% Haste based on your current level of Stagger.
    hit_scheme                          = { 80647, 383695, 1 }, -- Dealing damage with Blackout Kick increases the damage of your next Keg Smash by 10%, stacking up to 4 times.
    improved_celestial_brew             = { 80648, 322510, 1 }, -- Purifying Brew increases the absorption of your next Celestial Brew by up to 200%, based on Stagger purified.
    improved_invoke_niuzao_the_black_ox = { 80720, 322740, 1 }, -- Purifying Stagger damage while Niuzao is active increases the damage of Niuzao's next Stomp by 25% of damage purified, split between all enemies.
    improved_purifying_brew             = { 80655, 343743, 1 }, -- Purifying Brew now has 2 charges.
    invoke_niuzao                       = { 80724, 132578, 1 }, -- Summons an effigy of Niuzao, the Black Ox for 25 sec. Niuzao attacks your primary target, and frequently Stomps, damaging all nearby enemies. While active, 25% of damage delayed by Stagger is instead Staggered by Niuzao.
    invoke_niuzao_the_black_ox          = { 80724, 132578, 1 }, -- Summons an effigy of Niuzao, the Black Ox for 25 sec. Niuzao attacks your primary target, and frequently Stomps, damaging all nearby enemies. While active, 25% of damage delayed by Stagger is instead Staggered by Niuzao.
    keg_smash                           = { 80637, 121253, 1 }, -- Smash a keg of brew on the target, dealing 2,210 Physical damage to all enemies within 8 yds and reducing their movement speed by 20% for 15 sec. Deals reduced damage beyond 5 targets. Grants Shuffle for 5 sec and reduces the remaining cooldown on your Brews by 3 sec.
    light_brewing                       = { 80635, 325093, 1 }, -- Reduces the cooldown of Purifying Brew and Celestial Brew by 20%.
    pretense_of_instability             = { 80633, 393516, 1 }, -- Activating Purifying Brew or Celestial Brew grants you 15% dodge for 5 sec.
    purifying_brew                      = { 80639, 119582, 1 }, -- Clears 50% of your damage delayed with Stagger. Instantly heals you for 25% of the damage cleared.
    quick_sip                           = { 80642, 388505, 1 }, -- Purify 5% of your Staggered damage each time you gain 3 sec of Shuffle duration.
    rising_sun_kick                     = { 80690, 107428, 1 }, -- Kick upwards, dealing 5,712 Physical damage.
    rushing_jade_wind                   = { 80727, 116847, 1 }, -- Summons a whirling tornado around you, causing 2,261 Physical damage over 7.8 sec to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    salsalabims_strength                = { 80652, 383697, 1 }, -- When you use Keg Smash, the remaining cooldown on Breath of Fire is reset.
    scalding_brew                       = { 80652, 383698, 1 }, -- Keg Smash deals an additional 20% damage to targets affected by Breath of Fire.
    shadowboxing_treads                 = { 80632, 387638, 1 }, -- Blackout Kick's damage increased by 20% and it strikes an additional 2 targets.
    shuffle                             = { 80641, 322120, 1 }, -- Niuzao's teachings allow you to shuffle during combat, increasing the effectiveness of your Stagger by 100%. Shuffle is granted by attacking enemies with your Keg Smash, Blackout Kick, and Spinning Crane Kick.
    soothing_mist                       = { 80691, 115175, 1 }, -- Heals the target for 9,492 over 6.9 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    special_delivery                    = { 80727, 196730, 1 }, -- Drinking from your Brews has a 100% chance to toss a keg high into the air that lands nearby after 3 sec, dealing 1,531 damage to all enemies within 8 yards and reducing their movement speed by 50% for 15 sec.
    spirit_of_the_ox                    = { 92611, 400629, 1 }, -- Rising Sun Kick and Blackout Kick have a chance to summon a Healing Sphere. Healing Sphere: Summon a Healing Sphere visible only to you. Moving through this Healing Sphere heals you for 5,009.
    staggering_strikes                  = { 80645, 387625, 1 }, -- When you Blackout Kick, your Stagger is reduced by 2,087.
    stormstouts_last_keg                = { 80721, 383707, 1 }, -- Keg Smash deals 20% additional damage, and has 1 additional charge.
    tigers_lust                         = { 80689, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    training_of_niuzao                  = { 80635, 383714, 1 }, -- Gain up to 15% Mastery based on your current level of Stagger.
    tranquil_spirit                     = { 80725, 393357, 1 }, -- When a Gift of the Ox Healing Sphere is consumed or you cast Expel Harm, your current Stagger amount is lowered by 5%.
    walk_with_the_ox                    = { 80723, 387219, 2 }, -- Abilities that grant Shuffle reduce the cooldown on Invoke Niuzao, the Black Ox by 0.50 sec, and Niuzao's Stomp deals an additional 10% damage.
    weapons_of_order                    = { 80719, 387184, 1 }, -- For the next 30 sec, your Mastery is increased by 10%. Additionally, Keg Smash cooldown is reset instantly and enemies hit by Keg Smash take 8% increased damage from you for 10 sec, stacking up to 4 times.
    zen_meditation                      = { 80726, 115176, 1 }, -- Reduces all damage taken by 60% for 8 sec. Being hit by a melee attack, or taking another action will cancel this effect.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    admonishment       = 843 , -- (207025) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    alpha_tiger        = 5552, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you 20% haste for 8 sec. This effect cannot occur more than once every 30 sec per target.
    avert_harm         = 669 , -- (202162) Guard the 4 closest players within 15 yards for 15 sec, allowing you to Stagger 20% of damage they take.
    dematerialize      = 5541, -- (353361) Demateralize into mist while stunned, reducing damage taken by 30%. Each second you remain stunned reduces this bonus by 10%.
    double_barrel      = 672 , -- (202335) Your next Keg Smash deals 50% additional damage, and stuns all targets it hits for 3 sec.
    eerie_fermentation = 765 , -- (205147) You gain up to 30% movement speed and 15% magical damage reduction based on your current level of Stagger.
    grapple_weapon     = 5538, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 6 sec.
    guided_meditation  = 668 , -- (202200) The cooldown of Zen Meditation is reduced by 75%. While Zen Meditation is active, all harmful spells cast against your allies within 40 yards are redirected to you. Zen Meditation is no longer cancelled when being struck by a melee attack.
    hot_trub           = 667 , -- (202126) Purifying Brew deals 20% of your purified staggered damage as Fire, divided between all enemies within 10 yards.
    incendiary_breath  = 671 , -- (202272) Increases the radius and damage of Breath of Fire by 100%, causing it to disorient all targets it strikes for 4 sec, but its cooldown is increased by 100%.
    microbrew          = 666 , -- (202107) Reduces the cooldown of Fortifying Brew by 50%.
    mighty_ox_kick     = 673 , -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    nimble_brew        = 670 , -- (354540) Douse allies in the targeted area with Nimble Brew, preventing the next full loss of control effect within 8 sec.
    niuzaos_essence    = 1958, -- (232876) Drinking a Purifying Brew will dispel all snares affecting you.
    rodeo              = 5417, -- (355917) Every 7 sec while Clash is off cooldown, your next Clash can be reactivated immediately to wildly Clash an additional enemy. This effect can stack up to 3 times.
    wind_waker         = 5542, -- (357633) Your movement enhancing abilities increases Windwalking on allies by 10%, stacking 2 additional times. Movement impairing effects are removed at 3 stacks.
} )


-- Auras
spec:RegisterAuras( {
    admonishment = {
        id = 207025,
    },
    blackout_combo = {
        id = 228563,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: The Monk's abilities have a $h% chance to affect the target a second time at $s1% effectiveness as Shadow damage or healing.
    -- https://wowhead.com/beta/spell=386276
    bonedust_brew = {
        id = 386276,
        duration = 10,
        max_stack = 1,
        copy = 325216
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    breath_of_fire_dot = {
        id = 123725,
        duration = 12,
        max_stack = 1,
        copy = "breath_of_fire"
    },
    brewmasters_balance = {
        id = 245013,
    },
    celestial_brew = {
        id = 322507,
        duration = 8,
        max_stack = 1,
    },
    celestial_flames = {
        id = 325190,
        duration = 6,
        max_stack = 1,
    },
    celestial_fortune = {
        id = 216519,
    },
    -- Increases the damage done by your next Chi Explosion by $s1%.    Chi Explosion is triggered whenever you use Spinning Crane Kick.
    -- https://wowhead.com/beta/spell=393057
    chi_energy = {
        id = 393057,
        duration = 45,
        max_stack = 30
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=119085
    chi_torpedo = {
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    clash = {
        id = 128846,
        duration = 4,
        max_stack = 1,
    },
    -- Taking $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=117952
    crackling_jade_lightning = {
        id = 117952,
        duration = function() return 4 * haste end,
        tick_time = function() return haste end,
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
    -- Your next Spinning Crane Kick is free and deals an additional $325201s1% damage.
    -- https://wowhead.com/beta/spell=325202
    dance_of_chiji = {
        id = 325202,
        duration = 15,
        max_stack = 1
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
    double_barrel = {
        id = 202335,
    },
    elusive_brawler = {
        id = 195630,
        duration = 10,
        max_stack = 10,
    },
    exploding_keg = {
        id = 325153,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: $?$w1>0[Healing $w1 every $t1 sec.][Suffering $w2 Nature damage every $t2 sec.]
    -- https://wowhead.com/beta/spell=196608
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        max_stack = 1
    },
    -- Fighting on a faeline has a $s2% chance of resetting the cooldown of Faeline Stomp.
    -- https://wowhead.com/beta/spell=388193
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1
    },
    fortifying_brew = {
        id = 120954,
        duration = 15,
        max_stack = 1,
    },
    gift_of_the_ox = {
        id = 124502,
        duration = 3600,
        max_stack = 10,
    },
    graceful_exit = {
        id = 387254,
        duration = 3,
        max_stack = 3
    },
    guard = {
        id = 115295,
        duration = 8,
        max_stack = 1,
    },
    hit_scheme = {
        id = 383696,
        duration = 8,
        max_stack = 4
    },
    invoke_niuzao_the_black_ox = {
        id = 132578,
        duration = 25,
        max_stack = 1,
        copy = { "invoke_niuzao", "niuzao_the_black_ox" }
    },
    invokers_delight = {
        id = 338321,
        duration = 20,
        max_stack = 1
    },
    -- Talent: $?$w3!=0[Movement speed reduced by $w3%.  ][]Drenched in brew, vulnerable to Breath of Fire.
    -- https://wowhead.com/beta/spell=121253
    keg_smash = {
        id = 121253,
        duration = 15,
        max_stack = 1
    },
    -- Talent: $?$w3!=0[Movement speed reduced by $w3%.  ][]
    -- https://wowhead.com/beta/spell=330911
    keg_smash_snare = {
        id = 330911,
        duration = 15,
        max_stack = 1
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=119381
    leg_sweep = {
        id = 119381,
        duration = 3,
        mechanic = "stun",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=115078
    paralysis = {
        id = 115078,
        duration = 60,
        mechanic = "incapacitate",
        max_stack = 1
    },
    pretense_of_instability = {
        id = 393515,
        duration = 3,
        max_stack = 1
    },
    -- Taunted. Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=116189
    provoke = {
        id = 116189,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    purified_chi = {
        id = 325092,
        duration = 15,
        max_stack = 10,
    },
    -- Talent: Nearby enemies will be knocked out of the Ring of Peace.
    -- https://wowhead.com/beta/spell=116844
    ring_of_peace = {
        id = 116844,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dealing physical damage to nearby enemies every $116847t1 sec.
    -- https://wowhead.com/beta/spell=116847
    rushing_jade_wind = {
        id = 116847,
        duration = 6,
        tick_time = 0.75,
        max_stack = 1
    },
    shuffle = {
        id = 322120,
        duration = 9,
        max_stack = 1,
        copy = 215479
    },
    -- Talent: Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=115175
    soothing_mist = {
        id = 115175,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?$w2!=0[Movement speed reduced by $w2%.  ][]Drenched in brew, vulnerable to Breath of Fire.
    -- https://wowhead.com/beta/spell=196733
    special_delivery = {
        id = 196733,
        duration = 15,
        max_stack = 1
    },
    -- Attacking all nearby enemies for Physical damage every $101546t1 sec.
    -- https://wowhead.com/beta/spell=330901
    spinning_crane_kick = {
        id = 330901,
        duration = 1.5,
        tick_time = 0.5,
        max_stack = 1,
        copy = { 101546, 322729 }
    },
    -- Damage of next Crackling Jade Lightning increased by $s1%.  Energy cost of next Crackling Jade Lightning reduced by $s2%.
    -- https://wowhead.com/beta/spell=393039
    the_emperors_capacitor = {
        id = 393039,
        duration = 3600,
        max_stack = 20
    },
    -- Talent: Moving $s1% faster.
    -- https://wowhead.com/beta/spell=116841
    tigers_lust = {
        id = 116841,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Damage dealt to the Monk is redirected to you as Nature damage over $124280d.
    -- https://wowhead.com/beta/spell=122470
    touch_of_karma = {
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
    -- Talent: Your next Vivify is instant.
    -- https://wowhead.com/beta/spell=392883
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    weapons_of_order = {
        id = 387184,
        duration = function () return conduit.strike_with_clarity.enabled and 35 or 30 end,
        max_stack = 1,
        copy = 310454
    },
    weapons_of_order_debuff = {
        id = 387179,
        duration = 8,
        max_stack = 4,
        copy = 312106
    },
    -- Flying.
    -- https://wowhead.com/beta/spell=125883
    zen_flight = {
        id = 125883,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    zen_meditation = {
        id = 115176,
        duration = 8,
        max_stack = 1,
    },

    light_stagger = {
        id = 124275,
        duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
        unit = "player",
    },
    moderate_stagger = {
        id = 124274,
        duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
        unit = "player",
    },
    heavy_stagger = {
        id = 124273,
        duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
        unit = "player",
    },

    -- Azerite Powers
    straight_no_chaser = {
        id = 285959,
        duration = 7,
        max_stack = 1,
    },

    -- Conduits
    dizzying_tumble = {
        id = 336891,
        duration = 5,
        max_stack = 1
    },
    fortifying_ingredients = {
        id = 336874,
        duration = 15,
        max_stack = 1
    },
    lingering_numbness = {
        id = 336884,
        duration = 5,
        max_stack = 1
    },

    -- Legendaries
    charred_passions = {
        id = 338140,
        duration = 8,
        max_stack = 1
    },
    mighty_pour = {
        id = 337994,
        duration = 8,
        max_stack = 1
    }
} )


spec:RegisterHook( "reset_postcast", function( x )
    for k, v in pairs( stagger ) do
        stagger[ k ] = nil
    end
    return x
end )


spec:RegisterGear( "tier29", 200363, 200365, 200360, 200362, 200364 )
spec:RegisterAura( "brewmasters_rhythm", {
    id = 394797,
    duration = 15,
    max_stack = 4
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
spec:RegisterGear( "salsalabims_lost_tunic", 137016 )
spec:RegisterGear( "soul_of_the_grandmaster", 151643 )
spec:RegisterGear( "stormstouts_last_gasp", 151788 )
spec:RegisterGear( "the_emperors_capacitor", 144239 )
spec:RegisterGear( "the_wind_blows", 151811 )


spec:RegisterHook( "spend", function( amount, resource )
    if equipped.the_emperors_capacitor and resource == "chi" then
        addStack( "the_emperors_capacitor" )
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


local staggered_damage = {}
local staggered_damage_pool = {}
local total_staggered = 0

local stagger_ticks = {}

local function trackBrewmasterDamage( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, arg2, arg3, arg4, arg5, arg6, _, arg8, _, _, arg11 )
    if destGUID == state.GUID then
        if subtype == "SPELL_ABSORBED" then
            local now = GetTime()

            if arg1 == destGUID and arg5 == 115069 then
                local dmg = table.remove( staggered_damage_pool, 1 ) or {}

                dmg.t = now
                dmg.d = arg8
                dmg.s = 6603

                total_staggered = total_staggered + arg8

                table.insert( staggered_damage, 1, dmg )

            elseif arg8 == 115069 then
                local dmg = table.remove( staggered_damage_pool, 1 ) or {}

                dmg.t = now
                dmg.d = arg11
                dmg.s = arg1

                total_staggered = total_staggered + arg11

                table.insert( staggered_damage, 1, dmg )

            end
        elseif subtype == "SPELL_PERIODIC_DAMAGE" and sourceGUID == state.GUID and arg1 == 124255 then
            table.insert( stagger_ticks, 1, arg4 )
            stagger_ticks[ 31 ] = nil

        end
    end
end

-- Use register event so we can access local data.
spec:RegisterCombatLogEvent( trackBrewmasterDamage )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    table.wipe( stagger_ticks )
end )


function stagger_in_last( t )
    local now = GetTime()

    for i = #staggered_damage, 1, -1 do
        if staggered_damage[ i ].t + 10 < now then
            total_staggered = max( 0, total_staggered - staggered_damage[ i ].d )
            staggered_damage_pool[ #staggered_damage_pool + 1 ] = table.remove( staggered_damage, i )
        end
    end

    t = min( 10, t )

    if t == 10 then return total_staggered end

    local sum = 0

    for i = 1, #staggered_damage do
        if staggered_damage[ i ].t > now + t then
            break
        end
        sum = sum + staggered_damage[ i ]
    end

    return sum
end

local function avg_stagger_ps_in_last( t )
    t = max( 1, min( 10, t ) )
    return stagger_in_last( t ) / t
end


state.UnitStagger = UnitStagger


spec:RegisterStateTable( "stagger", setmetatable( {}, {
    __index = function( t, k, v )
        local stagger = debuff.heavy_stagger.up and debuff.heavy_stagger or nil
        stagger = stagger or ( debuff.moderate_stagger.up and debuff.moderate_stagger ) or nil
        stagger = stagger or ( debuff.light_stagger.up and debuff.light_stagger ) or nil

        if not stagger then
            if k == "up" then return false
            elseif k == "down" then return true
            else return 0 end
        end

        -- SimC expressions.
        if k == "light" then
            return t.percent < 3.5

        elseif k == "moderate" then
            return t.percent >= 3.5 and t.percent <= 6.5

        elseif k == "heavy" then
            return t.percent > 6.5

        elseif k == "none" then
            return stagger.down

        elseif k == "percent" or k == "pct" then
            -- stagger tick dmg / current effective hp
            if health.current == 0 then return 100 end
            return ceil( 100 * t.tick / health.current )

        elseif k == "percent_max" or k == "pct_max" then
            if health.max == 0 then return 100 end
            return ceil( 100 * t.tick / health.max )

        elseif k == "tick" or k == "amount" then
            if t.ticks_remain == 0 then return 0 end
            return t.amount_remains / t.ticks_remain

        elseif k == "ticks_remain" then
            return floor( stagger.remains / 0.5 )

        elseif k == "amount_remains" then
            t.amount_remains = UnitStagger( "player" )
            return t.amount_remains

        elseif k == "amount_to_total_percent" or k == "amounttototalpct" then
            return ceil( 100 * t.tick / t.amount_remains )

        elseif k:sub( 1, 17 ) == "last_tick_damage_" then
            local ticks = k:match( "(%d+)$" )
            ticks = tonumber( ticks )

            if not ticks or ticks == 0 then return 0 end

            -- This isn't actually looking backwards, but we'll worry about it later.
            local total = 0

            for i = 1, ticks do
                total = total + ( stagger_ticks[ i ] or 0 )
            end

            return total


            -- Hekili-specific expressions.
        elseif k == "incoming_per_second" then
            return avg_stagger_ps_in_last( 10 )

        elseif k == "time_to_death" then
            return ceil( health.current / ( t.tick * 2 ) )

        elseif k == "percent_max_hp" then
            return ( 100 * t.amount / health.max )

        elseif k == "percent_remains" then
            return total_staggered > 0 and ( 100 * t.amount / stagger_in_last( 10 ) ) or 0

        elseif k == "total" then
            return total_staggered

        elseif k == "dump" then
            if DevTools_Dump then DevTools_Dump( staggered_damage ) end

        else
            return stagger[ k ]

        end

        return nil

    end
} ) )

spec:RegisterTotem( "black_ox_statue", 627607 )
spec:RegisterPet( "niuzao_the_black_ox", 73967, "invoke_niuzao", 25 )

--[[ Dragonflight:
New priority increments BOC variable when list requirements are met and the last ability used was Blackout Kick.

rotation_blackout_combo:
    talent.blackout_combo.enabled & talent.salsalabims_strength.enabled & talent.charred_passions.enabled & ! talent.fluidity_of_motion.enabled

rotation_fom_boc:
    talent.blackout_combo.enabled & talent.salsalabims_strength.enabled & talent.charred_passions.enabled & talent.fluidity_of_motion.enabled

We will count actual Blackout Kicks in combat, and reset to zero when out of combat and Blackout Combo falls off. ]]

local blackoutComboCount = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, _, _, _, _, _, _, _, spellID )
    if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 205523 and state.talent.blackout_combo.enabled and state.talent.salsalabims_strength.enabled and state.talent.charred_passions.enabled then
        blackoutComboCount = blackoutComboCount + 1
    end
end )


-- I shouldn't need to do this, but trying to prevent unnecessary warnings when scripts are loaded.
state.boc_count = 0

spec:RegisterStateExpr( "boc_count", function()
    return blackoutComboCount
end )


spec:RegisterHook( "reset_precast", function ()
    rawset( healing_sphere, "count", nil )
    if healing_sphere.count > 0 then
        applyBuff( "gift_of_the_ox", nil, healing_sphere.count )
    end

    -- Reset blackoutComboCount if we are not in combat and Blackout Combo has fallen off.
    if state.combat == 0 and buff.blackout_combo.down then
        blackoutComboCount = 0
    end
    boc_count = nil

    stagger.amount = nil
    stagger.amount_remains = nil
end )


-- Abilities
spec:RegisterAbilities( {
    -- You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    admonishment = {
        id = 207025,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        pvptalent = "admonishment",
        startsCombat = false,
        texture = 620830,

        handler = function ()
            applyDebuff( "target", "admonishment" )
        end,
    },

    -- Guard the 4 closest players within 15 yards for 15 sec, allowing you to Stagger 20% of damage they take.
    avert_harm = {
        id = 202162,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "avert_harm",
        startsCombat = false,
        texture = 620829,

        usable = function() return group, "requires allies" end,

        handler = function ()
            active_dot.avert_harm = min( 4, group_members )
        end,
    },

    -- Talent: Chug some Black Ox Brew, which instantly refills your Energy, Purifying Brew charges, and resets the cooldown of Celestial Brew.
    black_ox_brew = {
        id = 115399,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "physical",

        talent = "black_ox_brew",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            gain( energy.max, "energy" )
            setCooldown( "celestial_brew", 0 )
            gainCharges( "purifying_brew", class.abilities.purifying_brew.charges )
        end,
    },

    -- Strike with a blast of Chi energy, dealing 1,429 Physical damage and granting Shuffle for 3 sec.
    blackout_kick = {
        id = 205523,
        cast = 0,
        cooldown = function() return talent.fluidity_of_motion.enabled and 3 or 4 end,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyBuff( "shuffle" )
            if buff.charred_passions.up and debuff.breath_of_fire_dot.up then applyDebuff( "target", "breath_of_fire_dot" ) end

            if talent.blackout_combo.enabled then applyBuff( "blackout_combo" ) end
            if talent.hit_scheme.enabled then addStack( "hit_scheme" ) end
            if talent.staggering_strikes.enabled then stagger.amount_remains = max( 0, stagger.amount_remains - stat.attack_power ) end
            if talent.walk_with_the_ox.enabled then reduceCooldown( "invoke_niuzao", 0.25 * talent.walk_with_the_ox.rank ) end

            if conduit.walk_with_the_ox.enabled and cooldown.invoke_niuzao.remains > 0 then reduceCooldown( "invoke_niuzao", 0.5 ) end

            addStack( "elusive_brawler" )
        end,
    },

    -- Talent: Breathe fire on targets in front of you, causing 897 Fire damage. Deals reduced damage to secondary targets. Targets affected by Keg Smash will also burn, taking 622 Fire damage and dealing 5% reduced damage to you for 12 sec.
    breath_of_fire = {
        id = 115181,
        cast = 0,
        cooldown = function () return buff.blackout_combo.up and 12 or 15 end,
        gcd = "totem",
        school = "fire",

        talent = "breath_of_fire",
        startsCombat = true,

        usable = function ()
            if active_dot.keg_smash / true_active_enemies < settings.bof_percent / 100 then
                return false, "keg_smash applied to fewer than " .. settings.bof_percent .. " targets"
            end
            return true
        end,

        handler = function ()
            removeBuff( "blackout_combo" )
            addStack( "elusive_brawler", nil, active_enemies * ( 1 + set_bonus.tier21_2pc ) )
            if debuff.keg_smash.up then applyDebuff( "target", "breath_of_fire_dot" ) end
            if talent.charred_passions.enabled or legendary.charred_passions.enabled then applyBuff( "charred_passions" ) end
        end,
    },

    -- Talent: A swig of strong brew that coalesces purified chi escaping your body into a celestial guard, absorbing 13,480 damage.
    celestial_brew = {
        id = 322507,
        cast = 0,
        cooldown = function() return talent.light_brewing.enabled and 36 or 45 end,
        gcd = "totem",
        school = "physical",

        talent = "celestial_brew",
        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            removeBuff( "purified_chi" )
            applyBuff( "celestial_brew" )

            if talent.pretense_of_instability.enabled then applyBuff( "pretense_of_instability" ) end

            if legendary.mighty_pour.enabled then
                applyBuff( "mighty_pour" )
            end
        end,
    },

    -- Talent: Hurls a torrent of Chi energy up to 40 yds forward, dealing 967 Nature damage to all enemies, and 1,775 healing to the Monk and all allies in its path. Healing reduced beyond 6 targets. Casting Chi Burst does not prevent avoiding attacks.
    chi_burst = {
        id = 123986,
        cast = 1,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "chi_burst",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_torpedo = {
        id = 115008,
        cast = 0,
        charges = function() return talent.improved_roll.enabled and 3 or 2 end,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        school = "physical",

        talent = "chi_torpedo",
        startsCombat = true,

        handler = function ()
            addStack( "chi_torpedo" )
        end,
    },

    -- Talent: A wave of Chi energy flows through friends and foes, dealing 299 Nature damage or 876 healing. Bounces up to 7 times to targets within 25 yards.
    chi_wave = {
        id = 115098,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        talent = "chi_wave",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    clash = {
        id = 324312,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "physical",

        talent = "clash",
        startsCombat = true,

        handler = function ()
            setDistance( 5 )
            applyDebuff( "target", "clash" )
        end,
    },

    -- Channel Jade lightning, causing 654 Nature damage over 3.5 sec to the target and sometimes knocking back melee attackers.
    crackling_jade_lightning = {
        id = 117952,
        cast = 0,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 20,
        spendType = "energy",

        startsCombat = true,

        start = function ()
            removeBuff( "the_emperors_capacitor" )
            applyDebuff( "target", "crackling_jade_lightning" )
        end,
    },

    -- Talent: Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
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

        usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up, "requires dispellable effect" end,
        handler = function ()
            removeDebuff( "player", "dispellable_poison" )
            removeDebuff( "player", "dispellable_disease" )
        end,
    },

    -- Talent: Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
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
            applyBuff( "diffuse_magic" )
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
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
            applyDebuff( "target", "disable" )
        end,
    },

    -- Your next Keg Smash deals 50% additional damage, and stuns all targets it hits for 3 sec.
    double_barrel = {
        id = 202335,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        pvptalent = "double_barrel",
        startsCombat = false,
        texture = 644378,

        handler = function ()
            applyBuff( "double_barrel" )
        end,
    },

    -- Expel negative chi from your body, healing for 3,494 and dealing 10% of the amount healed as Nature damage to an enemy within 8 yards. Draws in the positive chi of all your Healing Spheres to increase the healing of Expel Harm.
    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "totem",
        school = "nature",

        spend = 15,
        spendType = "energy",

        startsCombat = true,

        usable = function ()
            if ( settings.eh_percent > 0 and health.pct > settings.eh_percent ) then return false, "health is above " .. settings.eh_percent .. "%" end
            return true
        end,
        handler = function ()
            gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            removeBuff( "gift_of_the_ox" )
            if talent.tranquil_spirit.enabled and healing_sphere.count > 0 then stagger.amount_remains = 0.95 * stagger.amount_remains end
            healing_sphere.count = 0
        end,
    },

    -- Talent: Hurls a flaming keg at the target location, dealing 6,028 Fire damage to nearby enemies, causing your attacks against them to deal 467 additional Fire damage, and causing their melee attacks to deal 100% reduced damage for the next 3 sec.
    exploding_keg = {
        id = 325153,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "fire",

        talent = "exploding_keg",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "exploding_keg" )
        end,
    },

    -- Talent: Turns your skin to stone for 15 sec, increasing your current and maximum health by 15%, reducing all damage you take by 20%, increasing your armor by 25% and dodge chance by 25%.
    fortifying_brew = {
        id = 115203,
        cast = 0,
        cooldown = function () return ( talent.expeditious_fortification.enabled and 300 or 420 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",
        school = "physical",

        talent = "fortifying_brew",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "fortifying_brew" )
            health.max = health.max * 1.2
            health.actual = health.actual * 1.2
            if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
        end,
    },

    -- You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 6 sec.
    grapple_weapon = {
        id = 233759,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        pvptalent = "grapple_weapon",
        startsCombat = true,
        texture = 132343,

        handler = function ()
            applyBuff( "grapple_weapon" )
        end,
    },

    -- Talent: Drink a healing elixir, healing you for 15% of your maximum health.
    healing_elixir = {
        id = 122281,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "off",
        school = "nature",

        talent = "healing_elixir",
        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            gain( 0.15 * health.max, "health" )
        end,
    },

    -- Talent: Summons an effigy of Niuzao, the Black Ox for 25 sec. Niuzao attacks your primary target, and frequently Stomps, damaging all nearby enemies. While active, 25% of damage delayed by Stagger is instead Staggered by Niuzao.
    invoke_niuzao_the_black_ox = {
        id = 132578,
        cast = 0,
        cooldown = 180,
        gcd = "totem",
        school = "nature",

        talent = "invoke_niuzao_the_black_ox",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "niuzao_the_black_ox", 25 )

            if legendary.invokers_delight.enabled then
                if buff.invokers_delight.down then stat.haste = stat.haste + 0.33 end
                applyBuff( "invokers_delight" )
            end
        end,

        copy = "invoke_niuzao"
    },

    -- Talent: Smash a keg of brew on the target, dealing 2,009 Physical damage to all enemies within 8 yds and reducing their movement speed by 20% for 15 sec. Deals reduced damage beyond 5 targets. Grants Shuffle for 5 sec and reduces the remaining cooldown on your Brews by 3 sec.
    keg_smash = {
        id = 121253,
        cast = 0,
        cooldown = 8,
        charges = function () return ( talent.stormstouts_last_keg.enabled or legendary.stormstouts_last_keg.enabled ) and 2 or nil end,
        recharge = function () return ( talent.stormstouts_last_keg.enabled or legendary.stormstouts_last_keg.enabled ) and 8 or nil end,
        gcd = "totem",
        school = "physical",

        spend = 40,
        spendType = "energy",

        talent = "keg_smash",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "keg_smash" )
            active_dot.keg_smash = active_enemies

            applyBuff( "shuffle" )

            reduceCooldown( "celestial_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ) + ( buff.bonedust_brew.up and 1 or 0 ) )
            reduceCooldown( "fortifying_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ) + ( buff.bonedust_brew.up and 1 or 0 ) )
            gainChargeTime( "purifying_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ) +  ( buff.bonedust_brew.up and 1 or 0 ) )

            if buff.weapons_of_order.up then
                applyDebuff( "target", "weapons_of_order_debuff", nil, min( 5, debuff.weapons_of_order_debuff.stack + 1 ) )
            end

            if talent.salsalabims_strength.enabled then setCooldown( "breath_of_fire", 0 ) end
            if talent.walk_with_the_ox.enabled then reduceCooldown( "invoke_niuzao", 0.25 * talent.walk_with_the_ox.rank ) end

            removeBuff( "blackout_combo" )
            addStack( "elusive_brawler" )
        end,
    },

    -- Knocks down all enemies within 6 yards, stunning them for 3 sec.
    leg_sweep = {
        id = 119381,
        cast = 0,
        cooldown = function () return talent.tiger_tail_sweep.enabled and 50 or 60 end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "leg_sweep" )
            interrupt()
            if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
        end,
    },

    -- You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        pvptalent = "mighty_ox_kick",
        startsCombat = true,
        texture = 1381297,

        handler = function ()
        end,
    },

    -- Douse allies in the targeted area with Nimble Brew, preventing the next full loss of control effect within 8 sec.
    nimble_brew = {
        id = 354540,
        cast = 0,
        cooldown = 90,
        gcd = "totem",

        pvptalent = "nimble_brew",
        startsCombat = false,
        texture = 839394,

        toggle = "defensives",

        handler = function ()
            applyBuff( "nimble_brew" )
        end,
    },

    -- Talent: Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = function() return talent.improved_paralysis.enabled and 30 or 45 end,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "energy",

        talent = "paralysis",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "paralysis" )
        end,
    },

    -- Taunts the target to attack you and causes them to move toward you at 50% increased speed. This ability can be targeted on your Statue of the Black Ox, causing the same effect on all enemies within 10 yards of the statue.
    provoke = {
        id = 115546,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "provoke" )
        end,
    },

    -- Talent: Clears 50% of your damage delayed with Stagger. Instantly heals you for 25% of the damage cleared.
    purifying_brew = {
        id = 119582,
        cast = 0,
        charges = function () return talent.improved_purifying_brew.enabled and 2 or nil end,
        cooldown = function () return ( talent.light_brewing.enabled and 12 or 15 ) * haste end,
        recharge = function () return talent.improved_purifying_brew.enabled and ( ( talent.light_brewing.enabled and 12 or 15 ) * haste ) or nil end,
        gcd = "off",
        school = "physical",

        talent = "purifying_brew",
        startsCombat = false,
        toggle = "defensives",

        usable = function ()
            if stagger.amount == 0 then return false, "no damage is staggered" end
            if health.current == 0 then return false, "you are dead" end
            return true
        end,

        handler = function ()
            if buff.blackout_combo.up then
                addStack( "elusive_brawler" )
                removeBuff( "blackout_combo" )
            end

            if talent.improved_celestial_brew.enabled then applyBuff( "purified_chi" ) end
            if talent.pretense_of_instability.enabled then applyBuff( "pretense_of_instability" ) end

            local stacks = stagger.heavy and 3 or stagger.moderate and 2 or 1
            addStack( "purified_chi", nil, stacks )

            local reduction = stagger.amount_remains * ( 0.5 + 0.03 * buff.brewmasters_rhythm.stack )
            stagger.amount_remains = stagger.amount_remains - reduction
            gain( 0.25 * reduction, "health" )
        end,

        copy = "brews"
    },

    -- Talent: Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
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

    -- Talent: Kick upwards, dealing 3,359 Physical damage.
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "physical",

        talent = "rising_sun_kick",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Roll a short distance.
    roll = {
        id = 109132,
        cast = 0,
        charges = function() return talent.improved_roll.enabled and 3 or 2 end,
        cooldown = function () return talent.celerity.enabled and 15 or 20 end,
        recharge = function () return talent.celerity.enabled and 15 or 20 end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        notalent = "chi_torpedo",

        handler = function ()
        end,
    },

    -- Talent: Summons a whirling tornado around you, causing 2,261 Physical damage over 7.8 sec to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    rushing_jade_wind = {
        id = 116847,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "nature",

        talent = "rushing_jade_wind",
        startsCombat = false,

        handler = function ()
            applyBuff( "rushing_jade_wind" )
        end,
    },

    -- Talent: Heals the target for 9,492 over 6.9 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "totem",
        school = "nature",

        spend = 15,
        spendType = "energy",

        talent = "soothing_mist",
        startsCombat = false,

        start = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    -- Talent: Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
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

    -- Spin while kicking in the air, dealing 935 Physical damage over 1.3 sec to enemies within 8 yds. Dealing damage with Spinning Crane Kick grants Shuffle for 1 sec, and your Healing Spheres travel towards you.
    spinning_crane_kick = {
        id = 322729,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 25,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            applyBuff( "shuffle" )
            applyBuff( "spinning_crane_kick" )
            removeBuff( "counterstrike" )

            if buff.celestial_flames.up then
                applyDebuff( "target", "breath_of_fire_dot" )
                active_dot.breath_of_fire_dot = active_enemies
            end

            if buff.charred_passions.up and debuff.breath_of_fire_dot.up then
                applyDebuff( "target", "breath_of_fire_dot" )
            end

            if talent.walk_with_the_ox.enabled then reduceCooldown( "invoke_niuzao", 0.25 * talent.walk_with_the_ox.rank ) end

            if set_bonus.tier29_2pc > 0 then addStack( "brewmasters_rhythm" ) end
        end,
    },

    -- Strike with the palm of your hand, dealing 568 Physical damage. Reduces the remaining cooldown on your Brews by 1 sec.
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 50,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            removeBuff( "blackout_combo" )
            removeBuff( "counterstrike" )

            reduceCooldown( "celestial_brew", debuff.bonedust_brew.up and 2 or 1 )
            reduceCooldown( "fortifying_brew", debuff.bonedust_brew.up and 2 or 1 )
            gainChargeTime( "purifying_brew", debuff.bonedust_brew.up and 2 or 1 )

            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end

            if set_bonus.tier29_2pc > 0 then addStack( "brewmasters_rhythm" ) end
        end,
    },

    -- Talent: Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
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

    -- For the next 30 sec, your Mastery is increased by 10%. Additionally, Keg Smash cooldown is reset instantly and enemies hit by Keg Smash take 8% increased damage from you for 10 sec, stacking up to 4 times.
    weapons_of_order = {
        id = function() return talent.weapons_of_order.enabled and 387184 or 310454 end,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",


        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "weapons_of_order" )
            setCooldown( "keg_smash", 0 )
            if talent.call_to_arms.enabled or legendary.call_to_arms.enabled then summonPet( "niuzao", 12 ) end
            if talent.chi_surge.enabled then reduceCooldown( "weapons_of_order", min( active_enemies, 5 ) * 4 ) end
        end,

        copy = { 387184, 310454 }
    },

    -- Talent: Reduces all damage taken by 60% for 8 sec. Being hit by a melee attack, or taking another action will cancel this effect.
    zen_meditation = {
        id = 115176,
        cast = 8,
        channeled = true,
        cooldown = function() return talent.fundamental_observation.enabled and 225 or 300 end,
        gcd = "off",
        school = "nature",

        talent = "zen_meditation",
        startsCombat = false,

        toggle = "defensives",

        start = function ()
            applyBuff( "zen_meditation" )
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "phantom_fire",

    package = "Brewmaster"
} )


--[[ spec:RegisterSetting( "ox_walker", true, {
    name = "Use |T606543:0|t Spinning Crane Kick in Single-Target with Walk with the Ox",
    desc = "If checked, the default priority will recommend |T606543:0|t Spinning Crane Kick when Walk with the Ox is active.  This tends to " ..
        "reduce mitigation slightly but increase damage based on using Invoke Niuzao more frequently.",
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterSetting( "purify_for_celestial", true, {
    name = "|T1360979:0|t Celestial Brew: Maximize Shield",
    desc = "If checked, the addon will focus on using |T133701:0|t Purifying Brew as often as possible, to build stacks of Purified Chi for your Celestial Brew shield.\n\n" ..
        "This is likely to work best with the Light Brewing talent, but risks leaving you without a charge of Purifying Brew following a large spike in your Stagger.\n\n" ..
        "Custom priorities may ignore this setting.",
    type = "toggle",
    width = "full",
} )


spec:RegisterSetting( "purify_for_niuzao", true, {
    name = "|T133701:0|t Purifying Brew: Use with |T608951:0|t Improved Invoke Niuzao",
    desc = "If checked, the addon will recommend |T133701:0|t Purifying Brew when you have |T608951:0|t Improved Invoke Niuzao talented, while Niuzao is active.  This is used to maximize Stomp damage from Niuzao.",
    type = "toggle",
    width = "full"
} )


spec:RegisterSetting( "purify_stagger_currhp", 12, {
    name = "|T133701:0|t Purifying Brew: Stagger Tick % Current Health",
    desc = "If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000current|r effective health (or more).  " ..
        "Custom priorities may ignore this setting.\n\n" ..
        "This value is halved when playing solo.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "purify_stagger_maxhp", 6, {
    name = "|T133701:0|t Purifying Brew: Stagger Tick % Maximum Health",
    desc = "If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000maximum|r health (or more).  " ..
        "Custom priorities may ignore this setting.\n\n" ..
        "This value is halved when playing solo.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "bof_percent", 50, {
    name = "|T615339:0|t Breath of Fire: Require |T594274:0|t Keg Smash %",
    desc = "If set above zero, |T615339:0|t Breath of Fire will only be recommended if this percentage of your targets are afflicted with |T594274:0|t Keg Smash.\n\n" ..
        "Example:  If set to |cFFFFD10050|r, with 2 targets, Breath of Fire will be saved until at least 1 target has Keg Smash applied.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "eh_percent", 65, {
    name = "|T627486:0|t Expel Harm: Health %",
    desc = "If set above zero, the addon will not recommend |T627486:0|t Expel Harm until your health falls below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full"
} )


spec:RegisterPack( "Brewmaster", 20230226, [[Hekili:TZXAVjosYFlJwnmqYehdesMzfG0n79LD0P7wDSRUVHXy3aEJX2NFeMCkY)2VQ62pAB3TTXqYKrB0oklXU76DxD9ISC4YFF5ct9qYY)5i1rJvhn6wLrJh(5rtwUi8rpYYfE6g3RVf(GJ(E4NFXNCyVEqiXhF1J2U6MiicCJ8nGxVlm0l4NV(6TwH7IwRy4U)6aR9r26HwUog(6BcXF346Llwhzzh(Rolxle)Q3UCHEu4oxanlS2)laKTmnjSLtcmwU433rIxHVkEvonfVYZ3Y13k8X4vrbKG4v)wKV1MhTC2Yww8kDhZ4v)cXMeeAPBN90TB9jbbwpqSHTUXfG0F)3wOeVkEffr6MMUoXR2PdG0t3NaWiCNf8lRbXd8z34vbrEEU(H4h8FW6b91w2aDOe)14VIS2vQJUA0T)mcX)gWjaa(D3iJDXRC3a4IOhUJhyHisZ5L(6EEeD)a2lxdVBVfqTixTX3Dptqmqz5cBRGWauHy46AB6EWjqZXk6)P7QDW1fE()KQWjo6RTjMl)cSoabeFlDqDRBtCcvoq09CHT5UrZ13K4RKU4f6gOsC5IYRyziO8Kc23b0B0MnkRDDiMrbHARbbUsKx8QEXRmj03vgIAjppiKkqMfV6MC0xaqiUh3nCN(YkmCY7tLGvxGpzVULdOmMhVAOAnu2nsPmHKvoKiFZZ21e0VA3t2IqAs9qsojofeEdVLYqTwbB58G79KudhWuuBTnOi0C)gsk3wN4(8GJqE7xR9E(UpqmtxRrOEdgYw7HdixbhAP4sXl1fatoBdEk0aNdMmHZK3mS)H1WESkvpp8okF1O6EE2AQawUvDjY70)3O4vxeVsvrDs7TB9DdP31PT21qZCZ6mt1mzjUC3OqT7TmUNN1R1yl5CLVf60xliYHU9QhRkTG6TIsbAuWoCt)PUjr7GLJzkyPsvQAO6sY1dG4Id)LxyBSwsLiq0cRDlyUaAq4IrunTXYNKzVK(AWgslaU5Fxj5OCxuehI)2hPAx2hbgzlXHQO7ZD0idYkBIST18jg7093s0y(wylEi14tWwyRnqBJpJqXWmgq)3CWO92j8EJtTEygRv0NfEnYA31zTzdkPpjfW42EGObYR9wKeNduw4vHWmNTc8SCCq(cIZ0HKz))5x3gdf8nsS1GLVhjBW)BBviZELQqcT2cx55PBZyOgd90inQ8chgkCNwn(kkUBkgB0FQXolTd6pqQEgj9nu40OluC1RJ8dcfdi6RkD)GXoV6dJjLLr5nKWbihHi(HlTAWb5O2EztJmvxUSrUR(MCpDUUS5Tli6Qg4TliEvAm82fe)L6cctYg9i7Wk5neGfacu(oMAbH(w3teL7q6InT2SbYMrBV(wlJw73pGegchpcssHsBJRVMrELY6rv7OjGwOla6VPLOPP(L3AyQaplE1tpLOkOqXcU5c4W0CpR(Ic(2vMqTUYG1ag4YmYkzaWV3rf3jMNRa7W5uKKlOkMSyt3G5CpTKBmbrE1oYQqHm7t5IKb5sLswUi)wNTB5eNLWrvnfZOw5PYw4KLiRc2EOV2JeQicemFqyfjbxTgG9(erx8kJQXA86B5XE5FeqqBaNnwBJOLEnHscc13IoqmI8935Lwku(Qb7sHqGcVyyRVlVXOaXUq2UmYaljv2czVqXZiK5HR(Dk6o6VdsHaxB3VFcHKcRmruCfNfHb4dO9YIt0IibxhVSGUrrrG8YlconZHttcWBmujOMwjkwWax8Q3ZANYiGmoyzd(7VN(ZhDJIxzb8Wi8cMaci1mdWLeUd4Y4v7i62up7yFFYWeT7p)bTMGh2HbjjXuM2rPeor3hukMwbu6)CAKLISzzY46fPZeRlqzJWyT6KCEOm583nP8PzhF2eYdvBi8suweUJTEi4L7yP8z5aekk7n1Hi3iAJzjtLSyACnSyVvvgrdIp9JyKpm7RbfIPaURoKVy4fdQaWIhXjpHc5rgwICNOE2j3(jumhnLOVgKtWLyhkrFdFCVEUjzkXhW7q59yijKOGO97DD0oSdEUglPeqJggjiSFPlLIPB5jMqS)UyPzmXA0uMOKNNE76DeiOhZISSHEULe(PBqavqdxxSluRqKZCXdJjna0X(akn(PI1sY11uBtK)JLzLpxyze)aIpgOC5euu5xMnsgbA)zK529a1xETfs9blTff7LxvHCE0DmGqK9HqKn0TTlV0XfOr9TOycsJY4(GYRuEca9ZJ4xEOZ(qwcuJ9JiCB2EgqDOmklrljQ1Yia5wmHm4etqoKO99fmxrEe1rCPsGRN9lA44cWgAan24DiVTR48dGIh5hM(rs8Gq6CkDWMsJsh5fw85x6CYQ8sA6YEOC9OLiOumb)7KcAhVAbKJAccFq3g8iUGRfYpOdsbas0pLG5SAHhKTteVLtiidVcQQsPsJZN3AQVDDB4F6RT2hGfoH4SfUBkZTEcHoSteA5W2LtOM(6BXi19jvRC1XqNJ6cDoUCm1pB0j)6kf7vzozCN4KYrTMXjIGffp3qRsz6Jvea3MXQ8W4QbUSQU2YZGvMAaeTYdhRj0o6yrBkkLF3xtOC8XIsdwQVJLFFstO8MJfLBGvHJy3sAHw98jOPPE1sTkmkYwvQ4wuI3M77wRQ5COi(QnZ3xx6QxH4SK1tTg5RI9QuqRSQ0lZBkg)P8Ezk3i6474rwOX4w(gXikmTVhNL(ZjpcHtS)CYtOa3w5(ZXLrJ4UIvi2FUopvuWlV3zLrArVHL68J8wzjTVo86aX1DN7Ct1o)045KwDkSLDqQfUfQDKh5ND30nxzyfBR7Q3MBrru25BUf784N26rl8TXk0S6TdfV8qW1dnD)1BZeYXFNZBZeY3B6)Tzc54V7Vr)HT8U)gDb267(bV7pq8XAyK(9GcN58d6(OPzqYx2jiQa63Vi63oPpKmNiFiELp5)gzr7ayGlQk0JcD3RhIpae7oGyxj(R)dlh4v38ZXR(fxhax0x)HYLzQOW6dSVUrnSQuEdwD)HFBqgUM0aUKFDNm828aluMggENyIOCeeLWOSsPNd(4V(RuTbc0pNEvF8k6x)k410X1XaRh4NWenD3yHLKGTQaLSmpVC21SCnJ)QO3LzJ8rRnZKzsjFRODAPDYBuh)1F6NIx9LK4gqXeeyn7HIGyA24FetQEgwNcd3iNWp66nlGe(rA5wMPIsMKDd7PYmlX)YcZOe)lkgWeYb1oys96lyKKMMmiqp9KO5UPN0XqA6qLjxKS3bp9uddE00rPRTxvhCZXPzIJTkccMIHoqr96)U6pHjMjg0tApoLlmtMgNzt4mmAX5REYhcOE1paqGbfT9UN4ORuV9bTzIsfhvi(IODUApU23oVIXwjI8LGFWUy)YWoxOIgPTGLACAsEw0quS2woIrIVamt3uphpVKPCEToFlpl6CgANPwVGCwrbjirejOEDmGkphwtDskbId(lGZh1cKoYNXJP3nPx1z7yE(CDCrFvLrxI)4cQsEqYDrIg3eEmw69LW6e1JgR9foZidkiWlgGfgvISr4G7oXgNieEawCqp4Ft24uGGUn1wB(4NEssqOquaUbb9km)gthvieJ8r0OWtZMid(NwAamkOMsN3c(hwC8kkaF(PPOqepL6kdl0XAlZ5hzDVE2quG1pnaL6B(9LTpog66hmBuV(YI0NhGvgDGbtNn8uyqJq9x5m4Srhd)9cR3OsFWlVGroGNQZYujj1ekrxThI5PS01ToSq2vIhfHEPouQRT5DMcgXrbs6D)Zlbm(8qaPRr8qd0DY7MRQRjYnAPxUT8iZwdaBJZb(I43e4AXzr(2P3e4gFeGlTLYnbZBWe()P0qUNQdbr5t2m7dP)Da6WHdkhCH4M0nz)XaYJyBpBOQ6TQWnZhi(xz5SjcpX8H5)g(7XR(1Khm9A95PHC1wap(t3n8t3CDItVRC3CfR8oZ)pSNWIk8FHpJbEFIUXoSCO3qhIx4cmLILarKZoq8L4QI8niTbhmnD4gCMiKYvAPCfk)e3uR0BWNnk3dKmSvEZCh6Ko1NnbZc96cb47e2cSETjQf0m4mHU3jRfG9AS9F8H3kJmk0hVmLtL2r2eyKFtvlu4dVT3PQ8Qh)VRrW3clCbjQKKjH(ESWFHUW)PBtZIvv5Uefx1203nCLPSl(QuHOg22dJqI50jYr8FvCmjim6ZVhQJb1flvS3Aax0og6EOy1I3a5y43xMQUAfvVS)i1lV5c8pipdEVSTzg5tVK69Qk3ozaYDE(KhQjw0ZkVfTMp2qkMlsF9WIvFfdB1fGC2ycGI)eM(4O0QhQ6ZJ7sITm8nphFxHR)YJGwFFwOc8cMtHLhCs8mM(T7MnABnmtYmribotTx355PdpHnpxDGiF9IzUYhqB)oB7LVD)U(tdVN)l9ftpT92)tWKJ)UR6YNn136yLj9A3XsyLxEeGU9sL6dMOne30zNSVjzUZRoRbxmA6XiIVAmwe9)QglGrO(3RybyO(5lwGHQxoQBXcu1r6Rdo67z0nTI3Ao6McHyuXkIZHrM27PNEjcpGXEDoKOmQTWn8Y5VweiuReoVu8x3JGPfCABaZztN(JriFNadYFxPC30DmScPtwDlcMGrTclvvlieAieTfjTnUYZx8ShhEF(JNLrpN34zB0CR5GT6SHxZGUxdbMmw9QH31Er3jvbpkU61eh2OJ(lZ8ZF2urhx0ZY4qmM5EDeMnRjtJipLDl3Lf8GwA18W5XU2vw6BMa1DdR6Ns(snup0kpK78Wt2mYZSmL(Dzy6W6z1cFXfYpexTEM1aKSbTUzPQwY3laetS59(s(X((I8iwRBGVVO)WReSWQr1oyW8z3oPq)90k9fx48RrQfIcM4FeM4oYNp(5d79IjCQLAZNV)xufwT0u(i6xvWn71IGt042Y6uVWPxxEBeQdhTzkRBy)TyaVfaJ25M885I8eom2f3JICnkDz1587hnhFNGCwk0(rWH3RnNDV6D01jNCYHtNCKDQoXm25jmaiMR4ktuLqNXjWObhHSvDoCeMaPUCaTloczORopCCcGFi8WDccqPq7hbpCmk91Jhog98k2dhJapspChryCjWVtE(Y3B388LoEDNjNsCGRoxfClRQt30JXc)J0sdaRbVVLxAx8tL4K8s()IS0j)p8I(ZKtioq2spr1dKCNe1VU6p8w)EREUsYjNEhBef8iPthUkbGgpHr)(tV8))d]] )