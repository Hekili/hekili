-- MonkWindwalker.lua
-- January 2025

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 269 )
local GetSpellCount = C_Spell.GetSpellCastCount

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

        interval = function () return class.auras.crackling_jade_lightning.tick_time end,
        value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
    }
} )
spec:RegisterResource( Enum.PowerType.Chi )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Monk
    ancient_arts                   = { 101184, 344359, 2 }, -- Reduces the cooldown of Paralysis by 15 sec and the cooldown of Leg Sweep by 10 sec.
    aspect_of_harmony              = { 101223, 450508, 1 }, -- Store vitality from 10% of your damage dealt and 30% of your healing. For 10 sec after casting Thunder Focus Tea your spells and abilities draw upon the stored vitality to deal 40% additional healing over 8 sec.
    balanced_stratagem             = { 101230, 450889, 1 }, -- Casting a Physical spell or ability increases the damage and healing of your next Fire or Nature spell or ability by 3%, and vice versa. Stacks up to 5.
    bounce_back                    = { 101177, 389577, 1 }, -- When a hit deals more than 12% of your maximum health, reduce all damage you take by 20% for 4 sec. This effect cannot occur more than once every 30 seconds.
    bounding_agility               = { 101161, 450520, 1 }, -- Roll and Chi Torpedo travel a small distance further.
    calming_presence               = { 101153, 388664, 1 }, -- Reduces all damage taken by 3%.
    celerity                       = { 101183, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    celestial_determination        = { 101180, 450638, 1 }, -- While your Celestial is active, you cannot be slowed below 90% normal movement speed.
    chi_burst                      = { 101159, 460485, 1 }, -- Your damaging spells and abilities have a chance to activate Chi Burst, allowing you to hurl a torrent of Chi energy up to 40 yds forward, dealing 33,390 Nature damage to all enemies, and 26,961 healing to the Monk and all allies in its path. Healing and damage reduced beyond 5 targets.
    chi_proficiency                = { 101169, 450426, 2 }, -- Magical damage done increased by 5% and healing done increased by 5%.
    chi_torpedo                    = { 101183, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                       = { 101159, 450391, 1 }, -- Every 15 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing 5,366 Nature damage or 9,191 healing. Bounces up to 7 times to targets within 25 yards.
    clarity_of_purpose             = { 101228, 451017, 1 }, -- Casting Vivify stores 13,629 vitality, increased based on your recent Gusts of Mist.
    clash                          = { 101154, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    coalescence                    = { 101227, 450529, 1 }, -- When Aspect of Harmony heals, it has a chance to spread to a nearby ally. When you directly heal an affected target, it has a chance to intensify. Targets damaged or healed by your Aspect of Harmony take 20% increased damage or healing from you.
    crashing_momentum              = { 101149, 450335, 1 }, -- Targets you Roll through are snared by 40% for 5 sec.
    dance_of_the_wind              = { 101137, 432181, 1 }, -- Your physical damage taken is reduced by 10% and an additional 10% every 4 sec until you receive a physical attack.
    detox                          = { 101150, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    diffuse_magic                  = { 101165, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                        = { 101149, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks. Targets already snared will be rooted for 8 sec instead.
    elusive_mists                  = { 101144, 388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by 6%.
    endless_draught                = { 101225, 450892, 1 }, -- Thunder Focus Tea has 1 additional charge.
    energy_transfer                = { 101151, 450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by 5 sec.
    escape_from_reality            = { 101176, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown.
    expeditious_fortification      = { 101174, 388813, 1 }, -- Fortifying Brew cooldown reduced by 30 sec.
    fast_feet                      = { 101185, 388809, 1 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_touch                    = { 101178, 394123, 1 }, -- Touch of Death increases your damage by 5% for 30 sec after being cast and its cooldown is reduced by 90 sec.
    ferocity_of_xuen               = { 101166, 388674, 1 }, -- Increases all damage dealt by 2%.
    flow_of_chi                    = { 101170, 450569, 1 }, -- You gain a bonus effect based on your current health. Above 90% health: Movement speed increased by 5%. This bonus stacks with similar effects. Between 90% and 35% health: Damage taken reduced by 5%. Below 35% health: Healing received increased by 10%.
    fortifying_brew                = { 101173, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 20%, reducing all damage you take by 20%.
    grace_of_the_crane             = { 101146, 388811, 1 }, -- Increases all healing taken by 6%.
    harmonic_gambit                = { 101224, 450870, 1 }, -- During Aspect of Harmony, Rising Sun Kick, Blackout Kick, and Tiger Palm also withdraw vitality to damage enemies.
    hasty_provocation              = { 101158, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    healing_winds                  = { 101171, 450560, 1 }, -- Transcendence: Transfer immediately heals you for 10% of your maximum health.
    improved_touch_of_death        = { 101140, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    ironshell_brew                 = { 101174, 388814, 1 }, -- Increases your maximum health by an additional 10% and your damage taken is reduced by an additional 10% while Fortifying Brew is active.
    jade_walk                      = { 101160, 450553, 1 }, -- While out of combat, your movement speed is increased by 15%.
    lighter_than_air               = { 101168, 449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within 5 sec, but the cooldown of Roll is increased by 2 sec.
    manifestation                  = { 101222, 450875, 1 }, -- Chi Burst and Chi Wave deal 50% increased damage and healing.
    mantra_of_purity               = { 101229, 451036, 1 }, -- When cast on yourself, your single-target healing spells heal for 10% more and restore an additional 21,261 health over 6 sec.
    mantra_of_tenacity             = { 101229, 451029, 1 }, -- Fortifying Brew grants 20% Stagger.
    martial_instincts              = { 101179, 450427, 2 }, -- Increases your Physical damage done by 5% and Avoidance increased by 4%.
    overwhelming_force             = { 101220, 451024, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm deal 15% additional damage to enemies in a line in front of you. Damage reduced above 5 targets.
    paralysis                      = { 101142, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage may cancel the effect.
    path_of_resurgence             = { 101226, 450912, 1 }, -- Chi Wave increases vitality stored by 25% for 5 sec.
    peace_and_prosperity           = { 101163, 450448, 1 }, -- Reduces the cooldown of Ring of Peace by 5 sec and Song of Chi-Ji's cast time is reduced by 0.5 sec.
    pressure_points                = { 101141, 450432, 1 }, -- Paralysis now removes all Enrage effects from its target.
    profound_rebuttal              = { 101135, 392910, 1 }, -- Expel Harm's critical healing is increased by 50%.
    purified_spirit                = { 101224, 450867, 1 }, -- When Aspect of Harmony ends, any remaining vitality is expelled as healing over 8 sec, split among nearby targets.
    quick_footed                   = { 101158, 450503, 1 }, -- The duration of snare effects on you is reduced by 20%.
    ring_of_peace                  = { 101136, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    rising_sun_kick                = { 101186, 107428, 1 }, -- Kick upwards, dealing 69,425 Physical damage, and reducing the effectiveness of healing on the target for 10 sec.
    roar_from_the_heavens          = { 101221, 451043, 1 }, -- Tiger's Lust grants 20% movement speed to up to 2 allies near its target.
    rushing_reflexes               = { 101154, 450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within 10 yards after you Roll.
    save_them_all                  = { 101157, 389579, 1 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    song_of_chiji                  = { 101136, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for 20 sec.
    soothing_mist                  = { 101143, 115175, 1 }, -- Heals the target for 158,707 over 7.4 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    spear_hand_strike              = { 101152, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 3 sec.
    spirits_essence                = { 101138, 450595, 1 }, -- Transcendence: Transfer snares targets within 10 yds by 70% for 4 sec when cast.
    strength_of_spirit             = { 101135, 387276, 1 }, -- Expel Harm's healing is increased by up to 100%, based on your missing health.
    summon_white_tiger_statue      = { 101162, 450639, 1 }, -- Invoking Xuen, the White Tiger also spawns a White Tiger Statue at your location that pulses 7,530 damage to all enemies every 2 sec for 10 sec.
    swift_art                      = { 101155, 450622, 1 }, -- Roll removes a snare effect once every 30 sec.
    tiger_tail_sweep               = { 101182, 264348, 1 }, -- Increases the range of Leg Sweep by 4 yds.
    tigers_lust                    = { 101147, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    tigers_vigor                   = { 101221, 451041, 1 }, -- Casting Tiger's Lust reduces the remaining cooldown on Roll by 5 sec.
    transcendence                  = { 101167, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence_linked_spirits   = { 101176, 434774, 1 }, -- Transcendence now tethers your spirit onto an ally for 1 |4hour:hrs;. Use Transcendence: Transfer to teleport to your ally's location.
    vigorous_expulsion             = { 101156, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification         = { 101145, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant and its healing is increased by 40%. This effect also reduces the energy cost of Vivify by 75%.
    way_of_a_thousand_strikes      = { 101226, 450965, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm contribute 30% additional vitality.
    winds_reach                    = { 101148, 450514, 1 }, -- The range of Disable is increased by 5 yds. The duration of Crashing Momentum is increased by 3 sec and its snare now reduces movement speed by an additional 20%.
    windwalking                    = { 101175, 157411, 1 }, -- You and your allies within 10 yards have 10% increased movement speed. Stacks with other similar effects.
    yulons_grace                   = { 101165, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for 0.6% of your max health every 3 sec in combat, stacking up to 6%.

    -- Windwalker
    acclamation                    = { 101036, 451432, 1 }, -- Rising Sun Kick increases the damage your target receives from you by 3% for 12 sec. Multiple instances may overlap.
    ascension                      = { 101037, 115396, 1 }, -- Increases your maximum Chi by 1, maximum Energy by 20, and your Energy regeneration by 10%.
    brawlers_intensity             = { 101038, 451485, 1 }, -- The cooldown of Rising Sun Kick is reduced by 1.0 sec and the damage of Blackout Kick is increased by 12%.
    combat_wisdom                  = { 101217, 121817, 1 }, -- While out of combat, your Chi balances to 2 instead of depleting to empty. Every 15 sec, your next Tiger Palm also casts Expel Harm and deals 30% additional damage.  Expel Harm Expel negative chi from your body, healing for 67,608 and dealing 10% of the amount healed as Nature damage to an enemy within 20 yards.
    communion_with_wind            = { 101041, 451576, 1 }, -- Strike of the Windlord's cooldown is reduced by 10 sec and its damage is increased by 100%.
    courageous_impulse             = { 101061, 451495, 1 }, -- The Blackout Kick! effect also increases the damage of your next Blackout Kick by 350%.
    crane_vortex                   = { 101055, 388848, 1 }, -- Spinning Crane Kick damage increased by 30% and its radius is increased by 15%.
    dance_of_chiji                 = { 101060, 325201, 1 }, -- Spending Chi has a chance to make your next Spinning Crane Kick free and deal an additional 200% damage.
    drinking_horn_cover            = { 101052, 391370, 1 }, -- The duration of Storm, Earth, and Fire is extended by 0.25 sec for every Chi you spend.
    dual_threat                    = { 101213, 451823, 1 }, -- Your auto attacks have a 20% chance to instead kick your target dealing 18,513 Physical damage and increasing your damage dealt by 5% for 5 sec.
    energy_burst                   = { 101056, 451498, 1 }, -- When you consume Blackout Kick!, you have a 100% chance to generate 1 Chi.
    ferociousness                  = { 101035, 458623, 1 }, -- Critical Strike chance increased by 2%. This effect is increased by 100% while Xuen, the White Tiger is active.
    fists_of_fury                  = { 101218, 113656, 1 }, -- Pummels all targets in front of you, dealing 102,854 Physical damage to your primary target and 55,541 damage to all other enemies over 3.7 sec. Deals reduced damage beyond 5 targets. Can be channeled while moving.
    flurry_of_xuen                 = { 101216, 452137, 1 }, -- Your spells and abilities have a chance to activate Flurry of Xuen, unleashing a barrage of deadly swipes to deal 58,433 Physical damage in a 10 yd cone, damage reduced beyond 5 targets. Invoking Xuen, the White Tiger activates Flurry of Xuen.
    fury_of_xuen                   = { 101211, 396166, 1 }, -- Your Combo Strikes grant a stacking 1% chance for your next Fists of Fury to grant 3% critical strike, haste, and mastery and invoke Xuen, The White Tiger for 10 sec.
    gale_force                     = { 101045, 451580, 1 }, -- Targets hit by Strike of the Windlord have a 100% chance to be struck for 10% additional Nature damage from your spells and abilities for 10 sec.
    glory_of_the_dawn              = { 101039, 392958, 1 }, -- Rising Sun Kick has a chance equal to 100% of your haste to trigger a second time, dealing 49,264 Physical damage and restoring 1 Chi.
    hardened_soles                 = { 101047, 391383, 1 }, -- Blackout Kick critical strike chance increased by 10% and critical damage increased by 18%.
    hit_combo                      = { 101216, 196740, 1 }, -- Each successive attack that triggers Combo Strikes in a row grants 1% increased damage, stacking up to 5 times.
    inner_peace                    = { 101214, 397768, 1 }, -- Increases maximum Energy by 30. Tiger Palm's Energy cost reduced by 5.
    invoke_xuen                    = { 101206, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for 20 sec. Xuen attacks your primary target, and strikes 3 enemies within 10 yards every 0.9 sec with Tiger Lightning for 3,870 Nature damage. Every 4 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing 8% of the damage you have dealt to those targets in the last 4 sec.
    invoke_xuen_the_white_tiger    = { 101206, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for 20 sec. Xuen attacks your primary target, and strikes 3 enemies within 10 yards every 0.9 sec with Tiger Lightning for 3,870 Nature damage. Every 4 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing 8% of the damage you have dealt to those targets in the last 4 sec.
    invokers_delight               = { 101207, 388661, 1 }, -- You gain 15% haste for 20 sec after summoning your Celestial.
    jade_ignition                  = { 101050, 392979, 1 }, -- Whenever you deal damage to a target with Fists of Fury, you gain a stack of Chi Energy up to a maximum of 30 stacks. Using Spinning Crane Kick will cause the energy to detonate in a Chi Explosion, dealing 26,831 Nature damage to all enemies within 8 yards, reduced beyond 5 targets. The damage is increased by 5% for each stack of Chi Energy.
    jadefire_fists                 = { 101044, 457974, 1 }, -- At the end of your Fists of Fury channel, you release a Jadefire Stomp. This can occur once every 25 sec.  Jadefire Stomp Strike the ground fiercely to expose a path of jade for 30 sec that increases your movement speed by 20% while inside, dealing 6,201 Nature damage to up to 5 enemies, and restoring 12,767 health to up to 5 allies within 30 yds caught in the path. Up to 5 enemies caught in the path suffer an additional 9,689 damage.
    jadefire_harmony               = { 101042, 391412, 1 }, -- Enemies and allies hit by Jadefire Stomp are affected by Jadefire Brand, increasing your damage and healing against them by 6% for 10 sec.
    jadefire_stomp                 = { 101044, 388193, 1 }, -- Strike the ground fiercely to expose a path of jade for 30 sec that increases your movement speed by 20% while inside, dealing 6,201 Nature damage to up to 5 enemies, and restoring 12,767 health to up to 5 allies within 30 yds caught in the path. Up to 5 enemies caught in the path suffer an additional 9,689 damage.
    knowledge_of_the_broken_temple = { 101203, 451529, 1 }, -- Whirling Dragon Punch grants 4 stacks of Teachings of the Monastery and its damage is increased by 20%. Teachings of the Monastery can now stack up to 8 times.
    last_emperors_capacitor        = { 104129, 392989, 1 }, -- Chi spenders increase the damage of your next Crackling Jade Lightning by 400% and reduce its cost by 5%, stacking up to 20 times.
    martial_mixture                = { 101057, 451454, 1 }, -- Blackout Kick increases the damage of your next Tiger Palm by 8%, stacking up to 30 times.
    memory_of_the_monastery        = { 101209, 454969, 1 }, -- Tiger Palm's chance to activate Blackout Kick! is increased by 25% and consuming Teachings of the Monastery grants you 1.0% haste for 5 sec equal to the amount of stacks consumed.
    meridian_strikes               = { 101038, 391330, 1 }, -- When you Combo Strike, the cooldown of Touch of Death is reduced by 0.60 sec. Touch of Death deals an additional 15% damage.
    momentum_boost                 = { 101048, 451294, 1 }, -- Fists of Fury's damage is increased by 100% of your haste and Fists of Fury does 10% more damage each time it deals damage, resetting when Fists of Fury ends. Your auto attack speed is increased by 60% for 8 sec after Fists of Fury ends.
    ordered_elements               = { 101051, 451463, 1 }, -- During Storm, Earth, and Fire, Rising Sun Kick reduces Chi costs by 1 for 7 sec and Blackout Kick reduces the cooldown of affected abilities by an additional 1 sec. Activating Storm, Earth, and Fire resets the remaining cooldown of Rising Sun Kick and grants 2 Chi.
    path_of_jade                   = { 101043, 392994, 1 }, -- Increases the initial damage of Jadefire Stomp by 10% per target hit by that damage, up to a maximum of 50% additional damage.
    power_of_the_thunder_king      = { 104128, 459809, 1 }, -- Crackling Jade Lightning now chains to 4 additional targets at 80% effectiveness and its channel time is reduced by 50%.
    revolving_whirl                = { 101203, 451524, 1 }, -- Whirling Dragon Punch has a 100% chance to activate Dance of Chi-Ji and its cooldown is reduced by 5 sec.
    rising_star                    = { 101205, 388849, 1 }, -- Rising Sun Kick damage increased by 15% and critical strike damage increased by 10%.
    rushing_jade_wind              = { 101046, 451505, 1 }, -- Strike of the Windlord summons a whirling tornado around you, causing 69,013 Physical damage over 12.0 sec to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    sequenced_strikes              = { 101059, 451515, 1 }, -- You have a 100% chance to gain Blackout Kick! after consuming Dance of Chi-Ji.
    shadowboxing_treads            = { 101062, 392982, 1 }, -- Blackout Kick damage increased by 10% and strikes an additional 2 targets at 80% effectiveness.
    singularly_focused_jade        = { 101043, 451573, 1 }, -- Jadefire Stomp's initial hit now strikes 1 target, but deals 500% increased damage and healing.
    slicing_winds                  = { 102250, 1217413, 1 }, -- Envelop yourself in razor-sharp winds, then lunge forward dealing 119,251 Nature damage to enemies in your path. Damage reduced beyond 5 enemies. Hold to increase lunge distance.
    spiritual_focus                = { 101052, 280197, 1 }, -- Every 2 Chi you spend reduces the cooldown of Storm, Earth, and Fire by 0.5 sec.
    storm_earth_and_fire           = { 101053, 137639, 1 }, -- Split into 3 elemental spirits for 15 sec, each spirit dealing 40% of normal damage and healing. You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies. While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    strike_of_the_windlord         = { 101215, 392983, 1 }, -- Strike with both fists at all enemies in front of you, dealing 185,487 Physical damage and reducing movement speed by 50% for 6 sec.
    teachings_of_the_monastery     = { 101054, 116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to 8. Blackout Kick has a 12% chance to reset the remaining cooldown on Rising Sun Kick.
    thunderfist                    = { 101040, 392985, 1 }, -- Strike of the Windlord grants you 4 stacks of Thunderfist and an additional stack for each additional enemy struck. Thunderfist discharges upon melee strikes, dealing 23,999 Nature damage.
    touch_of_the_tiger             = { 101049, 388856, 1 }, -- Tiger Palm damage increased by 40%.
    transfer_the_power             = { 101212, 195300, 1 }, -- Blackout Kick, Rising Sun Kick, and Spinning Crane Kick increase damage dealt by your next Fists of Fury by 3%, stacking up to 10 times.
    whirling_dragon_punch          = { 101204, 152175, 1 }, -- Performs a devastating whirling upward strike, dealing 86,397 damage to all nearby enemies and an additional 53,663 damage to the first target struck. Damage reduced beyond 5 targets. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    xuens_battlegear               = { 101210, 392993, 1 }, -- Rising Sun Kick critical strikes reduce the cooldown of Fists of Fury by 4 sec. When Fists of Fury ends, the critical strike chance of Rising Sun Kick is increased by 40% for 5 sec.
    xuens_bond                     = { 101208, 392986, 1 }, -- Invoke Xuen, the White Tiger's damage is increased by 30% and its cooldown is reduced by 30 sec.

    -- Shado-Pan
    against_all_odds               = { 101253, 450986, 1 }, -- Flurry Strikes increase your Agility by 1% for 5 sec, stacking up to 20 times.
    efficient_training             = { 101251, 450989, 1 }, -- Energy spenders deal an additional 20% damage. Every 50 Energy spent reduces the cooldown of Storm, Earth, and Fire by 1 sec.
    flurry_strikes                 = { 101248, 450615, 1, "shadowpan" }, -- Every 263,060 damage you deal generates a Flurry Charge. For each 240 energy you spend, unleash all Flurry Charges, dealing 25,253 Physical damage per charge.
    high_impact                    = { 101247, 450982, 1 }, -- Enemies who die within 10 sec of being damaged by a Flurry Strike explode, dealing 15,060 physical damage to uncontrolled enemies within 8 yds.
    lead_from_the_front            = { 101254, 450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for 20% of damage dealt.
    martial_precision              = { 101246, 450990, 1 }, -- Your attacks penetrate 12% armor.
    one_versus_many                = { 101250, 450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation. Fists of Fury damage increased by 15%. Keg Smash damage increased by 35%.
    predictive_training            = { 101245, 450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by 10% for the next 6 sec.
    pride_of_pandaria              = { 101247, 450979, 1 }, -- Flurry Strikes have 15% additional chance to critically strike.
    protect_and_serve              = { 101254, 450984, 1 }, -- Your Vivify always heals you for an additional 30% of its total value.
    veterans_eye                   = { 101249, 450987, 1 }, -- Striking the same target 5 times within 2 sec grants 1% Haste, stacking up to 10 times.
    vigilant_watch                 = { 101244, 450993, 1 }, -- Blackout Kick deals an additional 20% critical damage and increases the damage of your next set of Flurry Strikes by 10%.
    whirling_steel                 = { 101245, 450991, 1 }, -- When your health drops below 50%, summon Whirling Steel, increasing your parry chance and avoidance by 15% for 6 sec. This effect can not occur more than once every 180 sec.
    wisdom_of_the_wall             = { 101252, 450994, 1 }, -- Every 10 Flurry Strikes, become infused with the Wisdom of the Wall, gaining one of the following effects for 16 sec. Critical strike damage increased by 30%. Dodge and Critical Strike chance increased by 25% of your Versatility bonus. Flurry Strikes deal 24,096 Shadow damage to all uncontrolled enemies within 6 yds. Effect of your Mastery increased by 25%.

    -- Conduit of the Celestials
    august_dynasty                 = { 101235, 442818, 1 }, -- Casting Jadefire Stomp increases the damage of your next Rising Sun Kick by 30%. This effect can only activate once every 8 sec.
    celestial_conduit              = { 101243, 443028, 1, "conduit_of_the_celestials" }, -- The August Celestials empower you, causing you to radiate 2.3 million Nature damage onto enemies and 222,232 healing onto up to 5 injured allies within 15 yds over 3.8 sec, split evenly among them. Healing and damage increased by 6% per enemy struck, up to 30%. You may move while channeling, but casting other healing or damaging spells cancels this effect.
    chijis_swiftness               = { 101240, 443566, 1 }, -- Your movement speed is increased by 75% during Celestial Conduit and by 15% for 3 sec after being assisted by any Celestial.
    courage_of_the_white_tiger     = { 101242, 443087, 1 }, -- Tiger Palm has a chance to cause Xuen to claw your target for 50,309 Physical damage, healing a nearby ally for 25% of the damage done. Invoke Xuen, the White Tiger guarantees your next cast activates this effect.
    flight_of_the_red_crane        = { 101234, 443255, 1 }, -- Rushing Jade Wind and Spinning Crane Kick have a chance to cause Chi-Ji to increase your energy regeneration by 20% for 6 sec and quickly rush to 5 enemies, dealing 29,812 Physical damage to each target struck.
    heart_of_the_jade_serpent      = { 101237, 443294, 1 }, -- Strike of the Windlord calls upon Yu'lon to decrease the cooldown time of Fists of Fury, Strike of the Windlord, Rising Sun Kick, Flying Serpent Kick, and Whirling Dragon Punch by 75% for 6 sec. The channel time of Fists of Fury is reduced by 50% while Yu'lon is active.
    inner_compass                  = { 101235, 443571, 1 }, -- You switch between alignments after an August Celestial assists you, increasing a corresponding secondary stat by 2%. Crane Stance: Haste Tiger Stance: Critical Strike Ox Stance: Versatility Serpent Stance: Mastery
    jade_sanctuary                 = { 101238, 443059, 1 }, -- You heal for 10% of your maximum health instantly when you activate Celestial Conduit and receive 15% less damage for its duration. This effect lingers for an additional 8 sec after Celestial Conduit ends.
    niuzaos_protection             = { 101238, 442747, 1 }, -- Fortifying Brew grants you an absorb shield for 25% of your maximum health.
    restore_balance                = { 101233, 442719, 1 }, -- Gain Rushing Jade Wind while Xuen, the White Tiger is active.
    strength_of_the_black_ox       = { 101241, 443110, 1 }, -- After Xuen assists you, your next Blackout Kick refunds 2 stacks of Teachings of the Monastery and causes Niuzao to stomp at your target's location, dealing 29,812 damage to nearby enemies, reduced beyond 5 targets.
    temple_training                = { 101236, 442743, 1 }, -- Fists of Fury and Spinning Crane Kick deal 10% more damage.
    unity_within                   = { 101239, 443589, 1 }, -- Celestial Conduit can be recast once during its duration to call upon all of the August Celestials to assist you at 200% effectiveness. Unity Within is automatically cast when Celestial Conduit ends if not used before expiration.
    xuens_guidance                 = { 101236, 442687, 1 }, -- Teachings of the Monastery has a 15% chance to refund a charge when consumed. The damage of Tiger Palm is increased by 10%.
    yulons_knowledge               = { 101233, 443625, 1 }, -- Rushing Jade Wind's duration is increased by 4 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_serenity   = 5641, -- (455945) Celestial Conduit now prevents all crowd control for its duration.
    grapple_weapon      = 3052, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 5 sec.
    perpetual_paralysis = 5448, -- (357495)
    predestination      = 3744, -- (345829)
    ride_the_wind       =   77, -- (201372)
    rising_dragon_sweep = 5643, -- (460276)
    rodeo               = 5644, -- (355917) Every 3 sec while Clash is off cooldown, your next Clash can be reactivated immediately to wildly Clash an additional enemy. This effect can stack up to 3 times.
    stormspirit_strikes = 5610, -- (411098)
    tigereye_brew       =  675, -- (247483) Consumes up to 10 stacks of Tigereye Brew to empower your Physical abilities with wind for 2 sec per stack consumed. Damage of your strikes are reduced, but bypass armor. For each 3 Chi you consume, you gain a stack of Tigereye Brew.
    turbo_fists         = 3745, -- (287681)
    wind_waker          = 3737, -- (357633)
} )

-- Auras
spec:RegisterAuras( {
    -- Damage received from $@auracaster increased by $w1%.
    acclamation = {
        id = 451433,
        duration = 12.0,
        max_stack = 5,
    },
    blackout_reinforcement = {
        id = 424454,
        duration = 3600,
        max_stack = 1
    },
    bok_proc = {
        id = 116768,
        type = "Magic",
        duration = 15,
        max_stack = 2,
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    -- Channeling the power of the August Celestials, $?c2[healing $s3 nearby allies.]?c3[damaging nearby enemies.][]$?a443059[; Damage taken reduced by $w2%.][]$?a443566[; Movement speed increased by $w5%.][]
    celestial_conduit = {
        id = 443028,
        duration = 4.0,
        max_stack = 1,
    },
    chi_burst = {
        id = 460490,
        duration = 30,
        max_stack = 2,
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
    chi_wave = { -- TODO: Consider modeling this proc every 15s.
        id = 450380,
        duration = 3600,
        max_stack = 1
    },
    combat_wisdom = {
        id = 129914,
        duration = 3600,
        max_stack = 1
    },
    -- TODO: This is a stub until BrM is implemented.
    counterstrike = {
        duration = 3600,
        max_stack = 1
    },
    -- Taking $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=117952
    crackling_jade_lightning = {
        id = 117952,
        duration = function() return talent.power_of_the_thunder_king.enabled and 2 or 4 end,
        tick_time = function() return talent.power_of_the_thunder_king.enabled and 0.5 or 1 end,
        type = "Magic",
        max_stack = 1
    },
    -- Your dodge chance is increased by $w1% until you dodge an attack.
    dance_of_the_wind = {
        id = 432180,
        duration = 3600,
        max_stack = 9
    },
    -- Talent: Your next Spinning Crane Kick is free and deals an additional $325201s1% damage.
    -- https://wowhead.com/beta/spell=325202
    dance_of_chiji = {
        id = 325202,
        duration = 15,
        max_stack = 2,
        copy = { 286587, "dance_of_chiji_azerite" }
    },
   --[[darting_hurricane = {
        id = 459841,
        duration = 10,
        max_stack = 2
    },--]]
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
    dual_threat = {
        id = 451833,
        duration = 5,
        max_stack = 1
    },
    -- Transcendence: Transfer has no cooldown.; Vivify's healing is increased by $w3% and you're refunded $m2% of the cost when cast on yourself.
    escape_from_reality = {
        id = 343249,
        duration = 10.0,
        max_stack = 1,
        copy = 394112
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
    -- Gathering Yu'lon's energy.
    heart_of_the_jade_serpent = {
        id = 456368,
        duration = 120.0,
        max_stack = 1,
    },
    heart_of_the_jade_serpent_cdr = {
        id = 443421,
        duration = 6,
        max_stack = 1
    },
    heart_of_the_jade_serpent_cdr_celestial = {
        id = 443616,
        duration = 60.0,
        max_stack = 45,
    },
    heart_of_the_jade_serpent_stack_ww = {
        id = 443424,
        duration = 60.0,
        max_stack = 45,
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
        duration = 30,
        max_stack = 100,
        copy = { "fury_of_xuen", 396168, 396167, 287062 }
    },
    fury_of_xuen_buff = {
        id = 287063,
        duration = 8,
        max_stack = 1,
        copy = 396168
    },
    -- $@auracaster's abilities to have a $h% chance to strike for $s1% additional Nature damage.
    gale_force = {
        id = 451582,
        duration = 10.0,
        max_stack = 1,
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
    --[[mark_of_the_crane = {
        id = 228287,
        duration = 15,
        max_stack = 1,
        no_ticks = true
    },--]]
    -- The damage of your next Tiger Palm is increased by $w1%.
    martial_mixture = {
        id = 451457,
        duration = 15.0,
        max_stack = 30,
    },
    -- Haste increased by ${$w1}.1%.
    memory_of_the_monastery = {
        id = 454970,
        duration = 5.0,
        max_stack = 8,
    },
    -- Fists of Fury's damage increased by $s1%.
    momentum_boost = {
        id = 451297,
        duration = 10.0,
        max_stack = 1,
    },
    momentum_boost_speed = {
        id = 451298,
        duration = 8,
        max_stack = 1
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
    -- Reduces the Chi Cost of your abilities by $s1.
    ordered_elements = {
        id = 451462,
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
        max_stack = 1,
        copy = 443626
    },
    save_them_all = {
        id = 390105,
        duration = 4,
        max_stack = 1
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
        max_stack = function() return talent.knowledge_of_the_broken_temple.enabled and 8 or 4 end,
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
    wisdom_of_the_wall_flurry = {
        id = 452688,
        duration = 40,
        max_stack = 1
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

-- The War Within
spec:RegisterGear( "tww2", 229301, 229299, 229298, 229297, 229296 )
spec:RegisterAuras( {
    -- 2-set
    -- https://www.wowhead.com/ptr-2/spell=1216182/winning-streak // https://www.wowhead.com/ptr-2/spell=1215717/monk-windwalker-11-1-class-set-2pc
    -- [Your spells and abilities have a chance to activate a Winning Streak! increasing the damage of your Rising Sun Kick and Spinning Crane Kick by 3% stacking up to 10 times. Rising Sun Kick and Spinning Crane Kick have a 15% chance to remove Winning Streak!] = {
    winning_streak = {
        id = 1216182,
        duration = 3600,
        max_stack = 10
    },
    -- https://www.wowhead.com/ptr-2/spell=1216498/cashout // https://www.wowhead.com/ptr-2/spell=1215718/monk-windwalker-11-1-class-set-4pc
    cashout = {
        id = 1216498,
        duration = 30,
        max_stack = 10
    },
} )

-- Dragonflight
spec:RegisterGear( "tier31", 207243, 207244, 207245, 207246, 207248 )
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

-- Legacy
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
    celestial_conduit = true,
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
    slicing_wind = true,
    spinning_crane_kick = true,
    strike_of_the_windlord = true,
    tiger_palm = true,
    touch_of_death = true,
    weapons_of_order = true,
    whirling_dragon_punch = true
} )

local prev_combo, actual_combo = "none", "none"

spec:RegisterStateExpr( "last_combo", function () return actual_combo end )

spec:RegisterStateExpr( "combo_break", function ()
    return this_action == last_combo
end )

spec:RegisterStateExpr( "combo_strike", function ()
    return not combos[ this_action ] or this_action ~= last_combo
end )


-- If a Tiger Palm missed, pretend we never cast it.
-- Use RegisterEvent since we're looking outside the state table.
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
        if not ability then return end

        if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
            if ns.castsAll[1] == "tiger_palm" then table.remove( ns.castsAll, 1 ) end
            if ns.castsAll[2] == "tiger_palm" then table.remove( ns.castsAll, 2 ) end
            if ns.castsOn[1] == "tiger_palm" then table.remove( ns.castsOn, 1 ) end

            actual_combo = ns.castsOn[ 1 ] or "none"

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
local orderedElementsMod = 0

--[[spec:RegisterHook( "prespend", function( amt, resource, overcap, clean )

    if resource == "chi" then
        if talent.ordered_elements.enabled and buff.storm_earth_and_fire.up then
            amt = max( 0, amt - 1 )
        end
        if covenant.kyrian then return weapons_of_order( amt ), resource, overcap, true end
    end

    return amt, resource, overcap, true

end )--]]

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "chi" and amt > 0 then
        if talent.spiritual_focus.enabled then
            chiSpent = chiSpent + amt
            cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
            chiSpent = chiSpent % 2
        end

        if talent.drinking_horn_cover.enabled and buff.storm_earth_and_fire.up then
            buff.storm_earth_and_fire.expires = buff.storm_earth_and_fire.expires + 0.25
        end

        if talent.last_emperors_capacitor.enabled or legendary.last_emperors_capacitor.enabled then
            addStack( "the_emperors_capacitor" )
        end
    elseif resource == "energy" then
        if amt > 50 and talent.efficient_training.enabled then
            reduceCooldown( "storm_earth_and_fire", 1 )
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
            -- if ( talent.xuens_bond.enabled or conduit.xuens_bond.enabled ) and cooldown.invoke_xuen.remains > 0 then reduceCooldown( "invoke_xuen", 0.2 ) end
            if talent.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then reduceCooldown( "touch_of_death", 0.6 ) end
        end
        last_combo = key
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

    if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

    if buff.casting.up and buff.casting.v1 == action.spinning_crane_kick.id then
        removeBuff( "casting" )
        -- Spinning Crane Kick buff should be up.
    end

    if buff.weapons_of_order_ww.up then
        state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
    end
end )

spec:RegisterHook( "IsUsable", function( spell )
    if spell == "touch_of_death" then return end -- rely on priority only.

    -- Allow repeats to happen if your chi has decayed to 0.
    -- TWW priority appears to allow hit_combo breakage for Tiger Palm.
    if talent.hit_combo.enabled and buff.hit_combo.up and spell ~= "tiger_palm" and last_combo == spell then
        return false, "would break hit_combo"
    end
end )


--[[spec:RegisterStateTable( "fight_style", setmetatable( { onReset = function( self ) self.count = nil end },
        { __index = function( t, k )
            if k == "patchwerk" then
                return boss
            elseif k == "dungeonroute" then
                return false -- this option seems more likely to yeet cooldowns even for dying trash
            elseif k == "dungeonslice" then
                return not boss
            elseif k == "Dungeonslice" then -- to account for the typo in SIMC
                return not boss
            end
        end } ) )--]]

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

-- Totems (which are sometimes pets)
spec:RegisterTotems( {
    jade_serpent_statue = {
        id = 620831
    },
    white_tiger_statue = {
        id = 125826
    },
    black_ox_statue = {
        id = 627607
    }
} )

spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "CHI" then
        if UnitPower( "player", Enum.PowerType.Chi ) < 2 and ns.castsOn[ 1 ] == "tiger_palm" then table.remove( ns.castsOn, 1 ) end
        Hekili:ForceUpdate( event, true )
    end
end )

local empowered_cast_time
max_empower = 4

do
    local stages = {
        1.4 * 0.25,
        1.4 * 0.5,
        1.4 * 0.75,
        1.4
    }

    empowered_cast_time = setfenv( function()
        local power_level = args.empower_to or class.abilities[ this_action ].empowerment_default or max_empower
        return stages[ power_level ] * haste
    end, state )
end

spec:RegisterStateExpr( "orderedElementsMod", function()
    if not talented.ordered_elements.enabled or buff.storm_earth_and_fire.down then return 0 end
    return 1
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
            if buff.bok_proc.up then return 0 end
            return 3 - orderedElementsMod
        end,
        spendType = "chi",

        startsCombat = true,
        texture = 574575,

        --[[cycle = function()
            if cycle_enemies == 1 then return end

            if level > 32 and cycle_enemies > active_dot.mark_of_the_crane and active_dot.mark_of_the_crane < 5 and debuff.mark_of_the_crane.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target missing Mark of the Crane debuff." ) end
                return "mark_of_the_crane"
            end
        end,--]]

        handler = function ()
            local kicks = buff.teachings_of_the_monastery.up and buff.teachings_of_the_monastery.stack or 1
            local hits = min( talent.shadowboxing_treads.enabled and 3 or 1, true_active_enemies ) * kicks

            if buff.bok_proc.up then
                removeStack( "bok_proc" )
                if talent.energy_burst.enabled then gain( 1, "chi" ) end
                if set_bonus.tier21_4pc > 0 then gain( 1, "chi" ) end
            end

            if talent.martial_mixture.up then
                addStack( "martial_mixture", nil, hits )
            end

            reduceCooldown( "rising_sun_kick", ( buff.ordered_elements.up and 2 or 1 ) )
            reduceCooldown( "fists_of_fury", ( buff.ordered_elements.up and 2 or 1 ) )

            if buff.teachings_of_the_monastery.up then
                if talent.memory_of_the_monastery.enabled then
                    addStack( "memory_of_the_monastery", nil, buff.teachings_of_the_monastery.stack )
                end
                removeBuff( "teachings_of_the_monastery" )
                if buff.strength_of_the_black_ox.up then
                    removeBuff( "strength_of_the_black_ox" )
                    addStack( "teachings_of_the_monastery", nil, 2 )
                end
            end
            if talent.eye_of_the_tiger.enabled then applyDebuff( "target", "eye_of_the_tiger" ) end
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power", nil, kicks ) end

            -- Legacy
            if buff.blackout_reinforcement.up then
                removeBuff( "blackout_reinforcement" )
                if set_bonus.tier31_4pc > 0 then
                    reduceCooldown( "fists_of_fury", 3 )
                    reduceCooldown( "rising_sun_kick", 3 )
                    reduceCooldown( "strike_of_the_windlord", 3 )
                    reduceCooldown( "whirling_dragon_punch", 3 )
                end
            end

        end,
    },

    -- $?c2[The August Celestials empower you, causing you to radiate ${$443039s1*$s7} healing onto up to $s3 injured allies and ${$443038s1*$s7} Nature damage onto enemies within $s6 yds over $d, split evenly among them. Healing and damage increased by $s1% per target, up to ${$s1*$s3}%.]?c3[The August Celestials empower you, causing you to radiate ${$443038s1*$s7} Nature damage onto enemies and ${$443039s1*$s7} healing onto up to $s3 injured allies within $443038A2 yds over $d, split evenly among them. Healing and damage increased by $s1% per enemy struck, up to ${$s1*$s3}%.][]; You may move while channeling, but casting other healing or damaging spells cancels this effect.;
    celestial_conduit = {
        id = 443028,
        cast = function() return talent.unity_within.enabled and buff.celestial_conduit.up and 0 or 4.0 end,
        channeled = function() return not talent.unity_within.enabled or not buff.celestial_conduit.up end,
        dual_cast = function() return talent.unity_within.enabled and buff.celestial_conduit.up end,
        cooldown = 90.0,
        gcd = "spell",

        spend = 0.050,
        spendType = 'mana',

        talent = "celestial_conduit",
        startsCombat = false,

        start = function()
            applyBuff( "celestial_conduit" )
        end,

        handler = function()
            -- TODO: do whatever unity_within does.
        end,
    },

    -- Talent: Hurls a torrent of Chi energy up to 40 yds forward, dealing $148135s1 Nature damage to all enemies, and $130654s1 healing to the Monk and all allies in its path. Healing reduced beyond $s1 targets.  $?c1[    Casting Chi Burst does not prevent avoiding attacks.][]$?c3[    Chi Burst generates 1 Chi per enemy target damaged, up to a maximum of $s3.][]
    chi_burst = {
        id = 461404,
        cast = function () return 1 * haste end,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "chi_burst",
        startsCombat = false,
        buff = "chi_burst",

        handler = function()
            removeBuff( "chi_burst" )
        end,
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

    --[[ Talent: A wave of Chi energy flows through friends and foes, dealing $132467s1 Nature damage or $132463s1 healing. Bounces up to $s1 times to targets within $132466a2 yards.
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
    }, ]]

    -- Channel Jade lightning, causing $o1 Nature damage over $117952d to the target$?a154436[, generating 1 Chi each time it deals damage,][] and sometimes knocking back melee attackers.
    crackling_jade_lightning = {
        id = 117952,
        cast = 2,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
        spendPerSec = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,

        toggle = function ()
            if buff.the_emperors_capacitor.up then
                local dyn = state.settings.cjl_capacitor_toggle
                if dyn == "none" then return "none" end
                if dyn == "default" then return nil end
                return dyn
            end
            return "none"
        end,

        startsCombat = false,

        handler = function ()
            applyBuff( "crackling_jade_lightning" )
        end,

        finish = function ()
            removeBuff( "the_emperors_capacitor" )
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
        notalent = "combat_wisdom",

        handler = function ()
            gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            removeBuff( "gift_of_the_ox" )
            healing_sphere.count = 0

            -- gain( pvptalent.reverse_harm.enabled and 2 or 1, "chi" )
        end,
    },

    -- Talent: Strike the ground fiercely to expose a faeline for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the faeline. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the faeline$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].    Your abilities have a $s2% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    jadefire_stomp = {
        id = function() return talent.jadefire_stomp.enabled and 388193 or 327104 end,
        cast = 0,
        -- charges = 1,
        cooldown = function() return state.spec.mistweaver and 15 or 30 end,
        -- recharge = 30,
        gcd = "spell",
        school = "nature",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        notalent = "jadefire_fists",

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
        cooldown = 24,
        gcd = "spell",
        school = "physical",

        spend = function() return 3 - orderedElementsMod end,
        spendType = "chi",

        tick_time = function () return haste end,

        start = function ()
            -- Standard effects / talents

            removeBuff( "transfer_the_power" )

            if buff.fury_of_xuen.stack >= 50 then
                applyBuff( "fury_of_xuen_buff" )
                summonPet( "xuen", 10 )
                removeBuff( "fury_of_xuen" )
            end

            if talent.whirling_dragon_punch.enabled and cooldown.rising_sun_kick.remains > 0 then
                applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
            end

            -- Hero Talents

            -- The War Within
            if set_bonus.tww2 >= 4 then removeBuff( "cashout" ) end

            -- PvP
            if pvptalent.turbo_fists.enabled then
                applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
            end

            -- Legacy
            if set_bonus.tier29_2pc > 0 then applyBuff( "kicks_of_flowing_momentum", nil, set_bonus.tier29_4pc > 0 and 3 or 2 ) end
            if set_bonus.tier30_4pc > 0 then
                applyDebuff( "target", "shadowflame_vulnerability" )
                active_dot.shadowflame_vulnerability = active_enemies
            end
            removeBuff( "fists_of_flowing_momentum" )
        end,



        tick = function ()
            if legendary.jade_ignition.enabled then
                addStack( "chi_energy", nil, active_enemies )
            end
        end,

        finish = function ()
            if talent.jadefire_fists.enabled and query_time - action.fists_of_fury.lastCast > 25 then class.abilities.jadefire_stomp.handler() end
            if talent.momentum_boost.enabled then applyBuff( "momentum_boost" ) end
            if talent.xuens_battlegear.enabled or legendary.xuens_battlegear.enabled then applyBuff( "pressure_point" ) end
        end,
    },

    -- Talent: Soar forward through the air at high speed for $d.     If used again while active, you will land, dealing $123586s1 damage to all enemies within $123586A1 yards and reducing movement speed by $123586s2% for $123586d.
    flying_serpent_kick = {
        id = 101545,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "flying_serpent_kick",
        notalent = "slicing_winds",
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
        cooldown = function()
            if state.spec.brewmaster then return talent.expeditious_fortification.enabled and 240 or 360 end
            return talent.expeditious_fortification.enabled and 90 or 120
        end,
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
        cooldown = function() return 120 - ( 30 * talent.xuens_bond.rank ) end,
        gcd = "spell",
        school = "nature",

        talent = "invoke_xuen",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "xuen_the_white_tiger", 24 )
            applyBuff( "invoke_xuen" )

            if talent.invokers_delight.enabled or legendary.invokers_delight.enabled then
                if buff.invokers_delight.down then stat.haste = stat.haste + 0.2 end
                applyBuff( "invokers_delight" )
            end

            if talent.summon_white_tiger_statue.enabled then
                summonTotem( "white_tiger_statue", nil, 10 )
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

    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = function() return 45 - ( 7.5 * talent.ancient_arts.rank ) end,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "energy",
        toggle = function() if talent.pressure_points.enabled then return "interrupts" end end,

        talent = "paralysis",
        startsCombat = true,

        usable = function () if talent.pressure_points.enabled then
            return buff.dispellable_enrage.up end
            return true
        end,

        handler = function ()
            applyDebuff( "target", "paralysis" )
            if talent.pressure_points.enabled then removeBuff( "dispellable_enrage" ) end
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
            return ( 10 - talent.brawlers_intensity.rank ) * haste
        end,
        gcd = "spell",
        school = "physical",

        spend = function() return 2 - orderedElementsMod end,
        spendType = "chi",

        talent = "rising_sun_kick",
        startsCombat = true,

        handler = function ()

            removeBuff( "chi_wave" )

            if talent.acclamation.enabled then applyDebuff( "target", "acclamation", nil, debuff.acclamation.stack + 1 ) end
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end

            if talent.whirling_dragon_punch.enabled and cooldown.fists_of_fury.remains > 0 then
                applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
            end


            -- Legacy
            if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end
            if buff.weapons_of_order.up then
                applyBuff( "weapons_of_order_ww" )
                state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
            end
            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
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

    --[[ Talent: Summons a whirling tornado around you, causing ${(1+$d/$t1)*$148187s1} Physical damage over $d to all enemies within $107270A1 yards. Deals reduced damage beyond $s1 targets.
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

        spend = function() return weapons_of_order( buff.ordered_elements.up and 1 or 0 ) end,
        spendType = "chi",

        talent = "rushing_jade_wind",
        startsCombat = false,

        handler = function ()
            applyBuff( "rushing_jade_wind" )
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
        end,
    }, ]]

    --[[ Talent: Enter an elevated state of mental and physical serenity for $?s115069[$s1 sec][$d]. While in this state, you deal $s2% increased damage and healing, and all Chi consumers are free and cool down $s4% more quickly.
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
    }, ]]

    -- Envelop yourself in razor-sharp winds, then lunge forward dealing 118,070 Nature damage to enemies in your path. Damage reduced beyond 5 enemies. Hold to increase lunge distance.
    slicing_winds = {
        id = 1217413,
        cast = empowered_cast_time,
        cooldown = 30,
        gcd = "totem",

        empowered = true,
        empowerment_default = 1,

        talent = "slicing_winds",
        startsCombat = false,
        texture = 1029596,

        handler = function ()
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
        cast = 1.5,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () if buff.dance_of_chiji.up then return 0 end
            return 2 - orderedElementsMod
        end,
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
                if talent.sequenced_strikes.enabled then addStack( "bok_proc" ) end
                removeStack( "dance_of_chiji" )
            end

            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
            end

            applyBuff( "spinning_crane_kick" )

            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
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
        startsCombat = false,
        nobuff = "storm_earth_and_fire",
        texture = function()
            return buff.storm_earth_and_fire.up and 236188 or 136038
        end,

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
            if talent.ordered_elements.enabled then
                setCooldown( "rising_sun_kick", 0 )
                gain( 2, "chi" )
            end
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
        cooldown = function() return 40 - ( 10 * talent.communion_with_wind.rank ) end,
        gcd = "spell",
        school = "physical",

        spend = function() return 2 - orderedElementsMod end,
        spendType = "chi",

        talent = "strike_of_the_windlord",
        startsCombat = true,

        toggle = function() if settings.dynamic_strike_of_the_windlord and raid then return "essences" end end,

        handler = function ()
            applyDebuff( "target", "strike_of_the_windlord" )
            -- if talent.darting_hurricane.enabled then addStack( "darting_hurricane", nil, 2 ) end
            if talent.gale_force.enabled then applyDebuff( "target", "gale_force" ) end
            if talent.rushing_jade_wind.enabled then
                --[[applyDebuff( "target", "mark_of_the_crane" )
                active_dot.mark_of_the_crane = true_active_enemies--]]
                applyBuff( "rushing_jade_wind" )
            end
            if talent.thunderfist.enabled then addStack( "thunderfist", nil, 4 + ( true_active_enemies - 1 ) ) end
        end,
    },

    -- Strike with the palm of your hand, dealing $s1 Physical damage.$?a137384[    Tiger Palm has an $137384m1% chance to make your next Blackout Kick cost no Chi.][]$?a137023[    Reduces the remaining cooldown on your Brews by $s3 sec.][]$?a129914[    |cFFFFFFFFGenerates 3 Chi.]?a137025[    |cFFFFFFFFGenerates $s2 Chi.][]
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.inner_peace.enabled and 55 or 60 end,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            gain( 2, "chi" )
            removeBuff( "martial_mixture" )

            if buff.combat_wisdom.up then
                class.abilities.expel_harm.handler()
                removeBuff( "combat_wisdom" )
            end

            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end

            if talent.teachings_of_the_monastery.enabled then addStack( "teachings_of_the_monastery" ) end

            if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                if buff.alpha_tiger.down then
                    stat.haste = stat.haste + 0.10
                    applyBuff( "alpha_tiger" )
                    applyDebuff( "target", "recently_challenged" )
                end
            end

            --[[if buff.darting_hurricane.up then
                setCooldown( "global_cooldown", cooldown.global_cooldown.remains * 0.75 )
                removeStack( "darting_hurricane" )
            end--]]
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
            return ( talent.improved_touch_of_death.enabled and target.health_pct < 15 ) or ( target.class == "npc" and target.health_current < health.current ), "requires low health target"
        end,

        handler = function ()
            applyDebuff( "target", "touch_of_death" )
        end,
    },

    -- Talent: Absorbs all damage taken for $d, up to $s3% of your maximum health, and redirects $s4% of that amount to the enemy target as Nature damage over $124280d.
    touch_of_karma = {
        id = 122470,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

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
        id = function() return talent.transcendence_linked_spirits.enabled and 434763 or 101643 end,
        known = 101643,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        talent = "transcendence",
        startsCombat = false,

        handler = function ()
            applyBuff( talent.transcendence_linked_spirits.enabled and "transcendence_tethered" or "transcendence" )
        end,

        copy = { 101643, 434763 }
    },


    transcendence_transfer = {
        id = 119996,
        cast = 0,
        cooldown = function () return buff.escape_from_reality.up and 0 or 45 end,
        gcd = "spell",

        startsCombat = false,
        texture = 237585,

        buff = function()
            return talent.transcendence_linked_spirits.enabled and "transcendence_tethered" or "transcendence"
        end,

        handler = function ()
            if buff.escape_from_reality.up then removeBuff( "escape_from_reality" )
            elseif talent.escape_from_reality.enabled or legendary.escape_from_reality.enabled then
                applyBuff( "escape_from_reality" )
            end
            if talent.healing_winds.enabled then gain( 0.15 * health.max, "health" ) end
            if talent.spirits_essence.enabled then applyDebuff( "target", "spirits_essence" ) end
        end,
    },

    -- Causes a surge of invigorating mists, healing the target for $s1$?s274586[ and all allies with your Renewing Mist active for $s2][].
    vivify = {
        id = 116670,
        cast = function() return buff.vivacious_vivification.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return buff.vivacious_vivification.up and 2 or 8 end,
        spendType = "energy",

        startsCombat = false,

        handler = function ()
            removeBuff( "vivacious_vivification" )
            removeBuff( "chi_wave" )
        end,
    },

    -- Talent: Performs a devastating whirling upward strike, dealing ${3*$158221s1} damage to all nearby enemies. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    whirling_dragon_punch = {
        id = 152175,
        cast = 0,
        cooldown = function() return talent.revolving_whirl.enabled and 19 or 24 end,
        gcd = "spell",
        school = "physical",

        talent = "whirling_dragon_punch",
        startsCombat = false,

        usable = function ()
            if settings.check_wdp_range and not action.fists_of_fury.in_range then return false, "target is out of range" end
            return cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0, "requires fists_of_fury and rising_sun_kick on cooldown"
        end,

        handler = function ()
            if talent.knowledge_of_the_broken_temple.enabled then addStack( "teachings_of_the_monastery", nil, 4 ) end
            if talent.revolving_whirl.enabled then addStack( "dance_of_chiji" ) end
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

    potion = "tempered_potion",

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
    end
} )

spec:RegisterSetting( "sef_one_charge", false, {
    name = strformat( "%s: Reserve 1 Charge for Cooldowns Toggle", Hekili:GetSpellLinkWithTexture( spec.abilities.storm_earth_and_fire.id ) ),
    desc = strformat( "If checked, %s can be recommended while Cooldowns are disabled, as long as you will retain 1 remaining charge.\n\n"
            .. "If |W%s's|w |cFFFFD100Required Toggle|r is changed from |cFF00B4FFDefault|r, this feature is disabled.",
            Hekili:GetSpellLinkWithTexture( spec.abilities.storm_earth_and_fire.id ), spec.abilities.storm_earth_and_fire.name ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "dynamic_strike_of_the_windlord", false, {
    name = strformat( "%s: Raid Cooldown", Hekili:GetSpellLinkWithTexture( spec.abilities.strike_of_the_windlord.id ) ),
    desc = strformat(
        "If checked, %s will require an active Minor Cooldowns toggle to be recommended in raid.\n\nThis feature ensures %s is only recommended when you are actively using cooldown abilities (e.g., add waves, burst windows).",
        Hekili:GetSpellLinkWithTexture( spec.abilities.strike_of_the_windlord.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.strike_of_the_windlord.id )
    ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "cjl_capacitor_toggle", "none", {
    name = strformat( "%s: Special Toggle", Hekili:GetSpellLinkWithTexture( spec.abilities.crackling_jade_lightning.id ) ),
    desc = strformat(
        "When %s is talented and the aura is active, %s will only be recommended if the selected toggle is active.\n\n" ..
        "This setting will be ignored if you have set %s's toggle in |cFFFFD100Abilities and Items|r.\n\n" ..
        "Select |cFFFFD100Do Not Override|r to disable this feature.",
        Hekili:GetSpellLinkWithTexture( spec.auras.the_emperors_capacitor.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.crackling_jade_lightning.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.crackling_jade_lightning.id )
    ),
    type = "select",
    width = 2,
    values = function ()
        local toggles = {
            none       = "Do Not Override",
            default    = "Default |cffffd100(" .. ( spec.abilities.crackling_jade_lightning.toggle or "none" ) .. ")|r",
            cooldowns  = "Cooldowns",
            essences   = "Minor CDs",
            defensives = "Defensives",
            interrupts = "Interrupts",
            potions    = "Potions",
            custom1    = spec.custom1Name or "Custom 1",
            custom2    = spec.custom2Name or "Custom 2",
        }
        return toggles
    end
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

spec:RegisterSetting( "tok_damage", 1, {
    name = strformat( "%s: Required Incoming Damage", Hekili:GetSpellLinkWithTexture( spec.abilities.touch_of_karma.id ) ),
    desc = strformat( "If set above zero, %s will only be recommended if you have taken this percentage of your maximum health in damage in the past 3 seconds.",
            Hekili:GetSpellLinkWithTexture( spec.abilities.touch_of_karma.id ) ),
    type = "range",
    min = 0,
    max = 99,
    step = 0.1,
    width = "full"
} )

spec:RegisterPack( "Windwalker", 20250322, [[Hekili:S3ZIUnUX1(TyuaTs9gBlrjTBCGTb6nTbPbTPbDtrUaxCTenfLeJPivjPwVUWqF73Zm8186mpKOS3nzbkAsSipZzoVFXzUB0D)8DVFHFr4D)O3qVPdh75DXiVXVD6K7EFXtBdV79B9dEWFf8VK4Vb())LOKfp6h)qy2(5fzPFC)8OnBjp1tXP(liqlpDxwa8KRlk2M)nxE5QOI17U)IG0nxMhTzxSFruAsqM)YcY)DWL3hNE)LfRdFm7r4jJsUCBw6YO4W8l)PSW)PF0c4F5Fo7VNM8WS2f)cYRE37VFxuCXFn5U7vSj8UAShGnBddG)8BVcqOOflclF2WC4Ljp75dhF(OjFZ(5VpAZ3c))pLeS)h2)dL)K35EFn8t)8V8lWVe6NNMSFU3(572swl2hB0u4X(2y)SOINQ(7toFK35dFBdK5EPjNp8QsyZ(JF1(5(lwKfMNd)9)Y3bu288DHW)i58vaTF)8pKFX(5WgpNdmeS))zxiGBlJ(i7VmCearYt4HIfF95Jhc)4Fkoo9ryJgTIWw)j)4naZnD)87Zc9Fy)8VpQa2EPBUh(t5PBclI2eMZceVR0ScEeIZ)mm2hKvs3gMqwI0Df5rlGTu6syvsj74LrRwxWdvC8(DN7riT)8Aae)IpaWFHk6C37JJYlYjsHl9JJVheDH)9FKkKhM4FFC4I7(VV79(berqISrussuYQzG0ys4ShIGhNkBKfTT8j(UAO8E4VveMf5d)BRJ2p)29ZNUFEV9ZdiKLz5fzrpeExbiPjSwmVhZtw(QvaAClgDFmSyaXPexaWn2DWnTfCfeg6STa)eGvbzVT0FxCXSG4q)peECKgVZNacj(zRcbcodED)ULlVyHFsq4S0LZaK6xJUiVa2w7NFdv9XjIwFq8GaWTe1IDzHZ2MgLuCXUTu4qW2peodKP2ebsKZVE)8jvlqA8I0htUyjrEGGil3L90fzHB8JsYPKj4bhSF(ZpVFEFMN)X1rzXK99Im)vPjZ2UljyD77DD7oW4cmI(GAihLaBqlrplkNS057soe(VneErcgV0NkMoGdt0XDi6ZREQuWRuJOWpoeyraOiYEH(bHxu9YLKBM34TdPVXz6FPbsYm1Y7xSHyu58Az)MTjLuuaqbSjSIYDa)lZ2KM4Ndy(tmmatpjSaZQE6EujLkeTCtm7(Dz5fTyA5EHcZ7tFyg4ilGkQs22Nz4DhW96PzlcZcxmlmoCd8o5nG5vgfk)Dts)1wJac84g0guH)WfL8VA68JG)8yyDkFMgOQ(HAb)aEvWaadZlI8JNfKMSyxuHc9vT7OACv2IEdYxtuwh6NvuJz)Q)IWz5HzGtnWM6ImwcT5NEwdEtFpns5Gz7OaIp4wjCnmjeZ))4uu1yRqxg2V5hMBVXGqP7cwtENfH(fRji1BrrkZlsngzWeB7YR04oblENES4OG9xFS7qIaL5hfHINhdsoawruIYjOZv6rN8I0SnZil06z(jlMTmklSrnXw9ZEhGkZIq6dVcSpnBzkKabNs80A9JwZFFec5nF29GgpV7LZ0(e1IlrjFifsJihKeJjbEwRcsj204r7vfs6mw8yetWvsMDiK3rd1PLTnSeRkPBRHFzgvh9Is)Y0fLAMSvZT0LAej8)s6Wbio0UTvhgLfMZBP7RaE9t1l7cF4T4i)kcjBSPGCgjgfQl6iic(CBf6IGhK5bViOk9JWJBRMm2kOBNWzjtO0XECA6I4D5fhNdhgRekvOPBe8G)kfOsFeeuJswUlhGeNSglwQJVG7xYLvG(xvj8PxYZG)hZXqcEK)6AMJAzFc)PIPNV2h0ZUp9Je8OasUErot0xAsdCeUhQw7DGHJ04pqT2tKl51ln9mM9JQKcFl9hWu8Trtb3)yPvVMmTzttRudzMsBPC5GnLB3VmExgy8QuCpxmW3(MTeEDZ21YOphn0wfnQJz1UTzipKKLXDXukZcqoCZ2WSuWcsG)wFi0X0SAojHOCL6qnRisLkCvOyX6DjqeMGGyYkoHf3zfdzCDMb4cvCGAJIAKJK4jD7H7mW1uEnMzRNdvRPmLPlicLZksNrZ88AyvwfSOmn0)ivBVNrHn12PM2UHEmkFr6MgHe)44zLWsxzpWI63d3tuFJOkJQtvWu(ffXHRaVmgc6sXZjOHzkiYYkOyx0ohACYunFXalpkIXbANQI7td8KZ6ITa4QMOxD(vfmrj5G2dpeGprvsq1fWd1WktlSXEa)Lzv72wlRExz2KdEeh1fWDI1XtOjw8APHky6XWEkL4g2LRI5QH61jlN2G58WdsYM4VAfkds3brPeMUlFw0MT7IZdfC9PswPPABkDajfrNNH6cyvKNLskTgFFij9raCRAmREFgycau)H4bIdvTvnrr0hvN8UcV8cwQHzubAmE4pwUN6eUmlMk31ghIH5uBYeZy4yhI9bPiK9TOE1wU9gGIMo0betMHQzIM1TUTMM3asb7n1avNqGOFZ6NKescPUAaQNs6DUSamSs7I9ZIFA2Y0GD5aDL8okdfPbyR9ZGTXt1pea2NcIbAEvh6(XruCYbpGwqn77ibTjenLIlIbIPvpUbusD5qZcOJBPXVSiLXuhsQnWqTB9H0SIWpQvnTX9yteaMTcQTGayyhtgyq4l0U)qbgUViP9EFtk8YmfvgqgXsO01nk9sH6yOo4kYorDMyPATS10ht17DDICte9KHAGqHM8ehCXOvyvM1GzkEIhBjkALG4lpXehmyBJweK1Ym6l2AzZGUXed1SutJnXwtlKs0XO126n1dYX11EGm2Uve2fWx8tHqROtCZDkg1dUP5aE06PZbRkufYZPHIfMhSFF4drXrFZ(5)90frlJiesYCffSomqCUIIGab3p)P0D7N)yuCmeHa8xjdF25fPNVL6ejkz)8f7sGy2ikL9RghQKvXHNhMaHZLuqMTiYasn4I7etSciOVTrtwQfVA59dUJB6zarEntodF(Z8KJrKvHOfljt6snlSRqheZ9kyzcRR6gczv7e4sh(GWFL95O1oQuxo0GXMSG3(6ITtqBkL42YSIej3fUZCOOLO1m3G9nZCn7KGSTLYgAGJUwkFQAtS1vzS3N(Tu2qlQCzu7m55epOYVmPxVGJzfwayIHPB097)BP)3)pYKYgLlmGVWILbmhYasdUMd8JJH)lFYKaNZ7AMofW(RaEr0Ykp0lstEd8aR9jdTqys6UvRHhNWAaLY9Z)oIr4YH797iMHVtzxhEfOS2frfFuyekpEUe2myBwzI7LECWkNuLMFJFYS4dPxZ8z01d1IoNfvSEP9OuEbQA0pECq1zRl1hxvIKyJMXHWITiSfMHs01U6m1SNh2gKI3y6FhmklctAG2cTA1s1HZ0slUHLJrrxmhlnv8uRPttLdDF7GVBs0(w99hrZeVCslHUl8hutRhDVDUv6dz40tWX9XDiQK9SjxhtfSLPo321AllsEQRgFgRikhT7bScvATBa2ktAERn1ESTR3A93Zm)dLvjPrJEruPjqVHsj4zfHOAqSC(94vzoWPwczVWopuYfAt7xefFYO)oyKC0UdCMLwfzKZV3OHmyM2ac1xHREUrYfCeOzEdRk2GCKE2mfKAIUqZmKXmZkuAQUXnHJOBLtkvd5XR00irzNN6HoYuIXYzf3BVWxVuFB04ocLtnrqOB0MupmfIX6AgD4Es3hEenJiKTPABLqfQWqxez47yLv2eUHzCPAFCvjVI9SwLmQogV2YJyFmGcpeRfmpnCD0ILyvvr0oMr6JMKVkjAg6hJKGEowOwndVtNmDt2ndBUmBoFIKwP0q5C6DFGzlWLzXbtWVNfdKHQTXT62g5H)BiuOaawQCeQ1hfFGNAaKnvZ1SDbTZrgMQJdEPo1saMhy1ozsWQxDH5kPq7K)yLXt(XiYHjUXOulwOoV0JrK0q6OlIbZDv4umgrJy9ujo7qCUOM4WmFQ3GT9dn0ywSdDOHCWSSwedBiomAwqZm6ODbpdFnTqMqhBf3oLQUP0zdnu1uUCx9iU0s3G4YbBljlAcsHJfInBqBtl)NCnM8NsRlPchr28Oc0094Mu25TfASzuMAipildH(vip6hC4))kha1pNfL8a90VPr8MKry5)XmYjru55r0SYtoRI6hVqEco4a()GogwAblHdeqkA7DsDXOrgOChREktzuE3pFihAYm0yf6MTJMvBIYvRbnuSAmyVvuUeqQWpMbRevnK5nFBL0)bqfR88QsuSXycdYf0SsfYdqbhI9Nl1S2p)NYIsH17jNXnjw6n02cXGn1ZOgWfj4dU7DfshJy0Zy(u0y5FW6v5JQPTuVtmyonnsDaMOYulLeeoaRk01zEflJN7YEmd9xHIJ3bRGrZzrwH2EPxBcVzCx61gDaHgXqK8ZcioVaz0mGKtHRHb9tP8mrULXfK)kATbac0duPznT(1wysR6z(SFD3IvBQXudJVMfqDT)tB8FO0wGPETAb4GOSadZZU3pJKYmfOg6NQfaTIfrt9U0Zk42MeFGVYXhTusjI0DMLHbGcCEqycjXNNiL)A3MwaR5zu4gofIbmNmWP1V(h8HTb8RK)T4DHO9NGzyznLCor)xT3gEldytUbtz1PH2OPG8LGSVngB4x7yFqDurZVeqb11L0LMK0wUDMeHv)ocRTDzntXqP(kOA0pEzWAMLqHoXYDGDrqUFnriBwtmdU17fJHrZx)Bhy6mPpR3TfZdAeO1IrMB36743BwrmU9qi5MI6Le0RlIxVOwg4WCZkONwKPNncm9yIpI0NxWMBvOa5HlPpEe1ySI0mmBVUV8U4gMG3A0XQB9pFpufhDzZBMbOuUr2zdG8L79ud6H0n8jmobWzsvJ)TFqqS)g6bjCtbJSH)1Bp3uh2SG8TT0iyQclEpBZKRplxLIABiFzEUU5tVxntKMeRI87pSTNrLEwztQDhwHZc2SBueZsaBBEmYypZvlDm8MgZ72qgA4hL5G2YLD9R(bPKw4rAxRREHaPSn2n89TkJbkGmVbK2QZOqXRPqdnBJ6H89bFiHAH63yimAR4ymbFOSwnsVjROBF(ypWt)2(qYO2DClOgDXAqb3ag)KiM7KgzedQHEmJcePvhaosmedznQQyhFHX8QWyOXC0msmgoXq)ct5LHPqabLXOVyxFHN8cYtUhsCim7HYbJSGPU3A(Oz9JHyhGewMTD3)5)ehcHP(rHWlmwy)dGL1exI(MpyAVpTU6nQ2fA6msy2UTf0uvOTwzzMFznYSQytKUWwUQyGrB8eekvjF5IIrxS2pF2UCaHHLRjmR6F2t5pBSFnNzjpRVgmHM(cgEiK6HTQ3nj6IZrzk06g)KOGzRYIcxc7vtF(TFHQQ7ZnIZgHpeeljpbcqVp8jiIw9bHArbG8omuFKfOoZifT4x9Z2Tlz22O4y)MZjZWyYPK5YyIgP2y2ocrKxd(Qnehg(A54XrN)G7HSPGSabJsj5Lz3O9Rl2kP6dY((rBCVj9PsA7i9XA8zgdE8q1Bq9FXRF2WS8u21UFlXT8kJYIVh5Ac1IPwg8TNUecTNcmYnM8yo)u0u1edf0HPpDsFoaf8D8(q223EdeV)plFpg1)lN4bw9D5Zhen688DcbF5VBkaHECffScLm(P7BodTkWlOqFcVtA0RmvtPS6ROWQh267YfhMg8(0)hDTduFq6Yto121VbnStka1nN9d2BXecF0hVo90IjxV3Qd5hd1J9OG9rFR70u)GdrYr6RD0qX0(YDsJ(4VnDacP70DSI6PusrxYv4F9fwET3vrwmYGPpG0z(LUyc0e6AlF416UYWcLtnrRA4R2rW1bx3mr96ImHzYNpa67(hZjOrJXbSV(v9mDM(15y0X2EBFW22mvwnOBxUd7sD3hhMMsoZXQDt9DitDfEXp4B1XGm43IwMcloydW(QuFLVxq0mNF9nYYzKkQSaB(RH32nWNY3DdAMJXt1h7uRgUX7XKM8kvMMwHBhcmbYx)TiX3P54zXLp8Uoj6vZiRHlSVd74WK3vKQpZ(pnoL9T77q9yVYGS4Zb2LBkiT51vtwC5Sb3m25qQxDUAUIDkM(SlhEdbVE35ashzd1pM4hxNSsrN89AQ68(2Ldxbtvl5qKb5SXA(8P3PdAbZvUPV5Qz9YErdO9CWWb)low4kDRkUJcB2MDLfB93lkoKAt)9SdvPqXvjLJ1CHCC5AyPVjJkyPA9s)bj7092IzrlgYCx9bjlDSqGA(u1nuIdUi0AKtM1GzUxZbXGglPmzTW9rW)w28gdq(EN18L)72UeRPlM1nmmTuAQ0oEJEmkYPtQrBzBuhU)1h)37mWz(qyg5yEKe0R30HJH8OF)J(zeAg8A)8Ay9a7GGxYQd343W)ri(M9ZZc)37aXAGaKNskdI)oq(2VG8hcw7NScIAA)p83IsGFAY3q(2utGLK(ZVrU3qa8ixrck(LA6m8e9h9XbVgWK1IMaqvzS7lqveQxPgQTLfwaMY1l(0dXrdvdsPlMpbiJEX9jTaJrwa)6cTlczFXtyyjq(w1GurmpcWwturslY7uVicfkwybqkJ8llW)A1aNp3obyRoXprq7HiTGwUqHvXyzfLwqVt3EbrW8ecAXYrQwBvQALFIa(pdimi2X7cmhXMtNzN83alaIrTo1Sm2IiNiRWAGNPR0sGy)u)PsTWYz3ryTTlDNschJye)fzr6q(04rNmT9Xigsqk5NizsFHbTDXeRzOWQGvsrjWp9LGDJyCHTSJImAfvKucSi6dhzG5tqCd1KLRamLY(vcGiSWdaG7)bfzH2Eon9gNYafj6PUcTkQ(AFCdPquB10gub00IrmwsqsCnRMvx(54TzDupMV2cup9av6NTcOF6HPsY8DbMIb0FNGPsMr7cmfdO)obtrIy8KAVrYVvxqDWa6rrD(8btrk(1jLpkxESUG8Gc1JI(85bUQmqIQQS)gNIJaj4ggUmo)hJFJvzrfZVOaW19jGBu9OkIyXb6vyjqp3EK4zKq()xj572siYKLOSHiaO4p(7EJbgc5dTXnMcAWDhr)jEbH5rMyXPbQioWoIQ(39qeX4CNuq7tjSX6)XrYYgD6Qnbwdv6085hHKq7jRq)JqQsrxqWqaDhv0zSUr1byow7w6uwn2I0HvQdRlohz1HoLnQaROzNIcaITyDubaXk8)Xs9Frk3pIT)xKfPd1aWQv9r6Mzmcp4akWxfarcn9aaOY4kRhCNUPKHIZTKaYH9rMlzbVZ2ZLWdrD(KMOkM9QUnXf0vHymv8lRsADu9qyReInRtkn8Lj5p0vPZPHVgf(cZPq3sdrxLoNgIyp8KsdXAcC3sdrxLoKgQ0ha3PxsN4h4GTuJex6r7xrBnvYDSox6tF5qswV7HiQPMJOenVGW8idd70a1ttVVpnqfREhhTMuf4XsGSZQy6jykvpDdJg24J2fGgjxOxIHFcHj3r1P53MGVdy5NYPMeXtZrATbBm5qUZJfwbd3IYIl2ymBpDy1boDCa0P)s8INra6Oxmn2Uahjl(Zw8(0vnySI9CsQjj2I1r1KCmIBMJK63HZHxfarKsoaaQmNGMRjS34ukbNQ8w0c9olyle4JCxljSkgUrMSCT60SC1VsDLbRx9DYlj)53sYANwTYtl07m(G(p8NdPKdiq8uJXDe9(ZtOV)h(RBQhPiYXrv9yfrU)tjENi37LPlJixGz)H)W(5Rlk2M)nxE5QOI17UhciEZL5rBGOqiVvqM)YcY)DWL3hNE)LGLPh9ZEeE0OKl)tuaxF35(3iG)siEIhO2UE0p(HWSliV6(FGSo)RTLBKfG3Y9ZjGy)83hT5BbQWF3plynP(eKgD7nLEi7ojyXvV7(jKTt5gi)Ig)W)x3CjzM1IGuv)kYvUWn43aNQF76lVPY3M7gC6ROxQB3iF5zD7B71V5tAh5kT75N5pPwU175NpdHXnOxFt3TMp)CFmfIw4Iy)BqpYi9XDX8XG)i(AQ2gxpTf8QFYb9W8m(8Z01v6KgSc03ocGDxIhmGsrz1LV6fV2LJ0TE6pddUEAV(gydp)mghCqZpH8QLmqcMHDibE7O31ZLTZTUsSaCKCm61J7mo96XdnZK7yDLk8qNiDxSm9Wyw9iuJBbRPwyoHYbeTN0NhlUzuV(uPXrdBedA9MIIgdK2nJmPbqVIHGft2E2OjGjizIJYB0rCAgLYC9uaubRJU1RhYJ98ZKFEA5)yCVY8eVEkS7B(x7jsIE(zH7DXEMqceXvgNia3Q8w5znHcvAub8pTF(pLs9sY8CBP)LVkA5nuccYXJARfagfqaZdlzOsQILBs1y6neuL4R8Vq9Pdi1FfYfDj4c)d(rX0)e9NBXrEjpYWCh(XIWSeqKzBuLO3s)48Y9i9I4)Nlh(7C2TQ4LLEj4kAEs4D)h0obAXB1(zW9veYBqXnJi0qkhACpr5TEmNkq3o0m056lP8cmrybGvuybQjdFB9qUyEnBMhg(1R2VKSybDv(ZLDseyIvbizEHygOBULsGODZu7bv5rIJcGagGoJics1iRjq3qSgrS09UwfEzJqI0yhqh4)gFJDTNzavFZ9Z(K839(e4cBPRdkVXgAm1WHLC3S(6vXjCE2xv4c03TxU(EY3T3I)7bWT3L9wV3M3Kk7ccG1x7iTE8AvSjgrzp)LPVZ3h(quCejA(0frlJizFqc3pyDi5ua87jh6xFlPOB7Nd(Pda4)u6osEaXX7NVc(RqKnpCEr65BPNAGrqcll2LSkmLCSO1)dqIlK3BvC45q4MP7skix98q2f5KuEuIIT(nQfjOrW3ESv1kJ3urWbucqRj2lA09VPY8EJ9vcHSuMSCoQJswUlVYHHbR)evpXizQcPIl4gldtEacktytky0eeS0VtEXtXaFVKmNLURiSN546eTGJhAayAXqWzdAzDSynpNdl2LZCj0xA4jq86AWv43hpWgjevOSguGShqUhIvdlmMM6RCyesi3nlS6NH)MTTX4GfutAwCkI7r85Bdos1EYM8rHGxnLdiEsAWlpOsVcj24QDZq1XJ5nunHR9MN9lenRjAKxMs4(cnZAAw7n36xiAkjA0ipyVWWAPJmbtl7sPmOWBNoTxdzQzS0Qtj923oS3zY)mjH7wpe9QcZ8CsET34vvZgdhkYxB6PAUiW6vxaq2gR2Rk6H2J)1bv)jPIdtIR4ObbJNwLLbRh11jSqAU8UyIfWqWmTcmOxzxxxrNvHRLU55oDsXej4UVSiIfLuatxfr9S4X4UOLWqafheS0ivzfV63NUyI3Qb36DLXAtcAnLVSQBfNB8gmadVEu1fHtJbiJKh01Kj)oNwr3GfxMjwJ1vgIoEMQKqRXcizPIrDsdM3jO3sw0Y0jvTXwl4mvGuDEaGzcLMIhnfJCie4FP8D1(vjxNrhxVa(TJ0jPbBkTeD6pkFvD4Q8znLt4dzUPMUc)DDySuPXWqgUdQzjdgI21PgeBkllNpa5kJiQkPuGSmNmsvIMI1hGAcmc1FatSf2gpt1gGFkSqnHjuEcljKMClxA58RB69L8xViQvbK7rP2vDTU28CfFmhvRp63VTBnfITRg8ynNExvQ4k4cIDWOzozDKnpTxvbjD5LUAGJVaeoPDbjYrYRC(YCdMC9nv3Ej)XX9uswkvb0DNlr1nF7XeEaTPkhdauzqQw79qc6Wb)aQnbBYQV9MfX1sB6VM0W)2tJT0Q4M6EQ9rdrvXbxVfz(iXT2dZPqpqboEalpBZCGST6RjThTykQja(BeJVI7cXGVVpQhv3gBHIdz7XWKXZmZgUm1iXeRvB4P36t8RVvEmVDCvCck2bTbKQqpTUM4mzPEyBdRsG1Aq31gwoola0(UpUPOftNEG0O(4QsQIPSvnCKQGlhyq05WWrtIJesHht9BCqasVI)byQcvNLN4HgXy9fvtBHjCWeAZBFmswMS600teRzMOquQnlhO4dp)4mrFhxp2KPGQsk6D(K9ZlWkPyzt1XPIOz5DJNHkt1azfXl1hjGjE79xpXueutgWobENYKWvOSzI0zmCPA6OGxofwVBwQFBx732Y3WB)9ORiSZa2KU1N41jgqmBRWMfphxXcvi3WefRdw3BLPF9kEDdo8swNylxuNb3Rw1IBWGVuWyl89DMPjQrCsrlhiuN5ti1f2yGNv0dPRHfX519AvzE2SXLQ3MJy)bR20jlbE1IRPonYxOslvzHWpyuwigZBT1zsm)eC1ihWIgUjVAluLgxvnlZbxU6(IlstrkuKcRoI3RsBqKvHomzqAdlCSI04nEGbqQReQhtKm4bOOSy0QDoPZfYNzDxORscW6y(p6sykico1IA7lMwMlgLCSplsoKv1bg9blC7iB8vEiH(mOnecl3ooQK(k22OpDe3obkzAAdKBodP1FwJxiPOMgu(zc51Rov9HU(2g6HKtGZfxYhBPH))BVRLEBByyW)w2LUomGGA3gSlB5yUUbKbSddlVACB8AwCrEGT2d53(OKStILiLi9JKwSHcK2M4irrkrr(9zrZMZP6gvWn7H3WFDGYdx3sIDP6ZbLm0BATV)mWB3L8vRNBr(XOv7sGON1SZExFOzio5aEKVtifEnJo5KZIMNgQMRHBhMkpeOBfjfHPD6CtbgtXm00PkXcgZLpvZTe5SIqCH5A5R5e0qZp9WPvGTCBhATi0UvNzROcETC7R1BibiHF4(CYpaDnQU35FBcXauO9rWkw6rqMc585L)wsrlS4RzJoeHkHg0fHJTCvg3uP1D(zdECDVlhA8MbYBM5mF6Gg3ylAAYM1T6)jh1k2bWh53nNL5FSB8xNNUgEvPJ2n(lGsA3y4cx90UXRFm52uyJlilC4)GxZ(96YhZ5Pq0xpajBykHd6t78SSLVfUG5GlDvdLT9(5WLppnVsd2x5Uy34m4Y7RCyWZK1okIqBNqDptHjHE57LXk22HlvJKwIhv(7kvpcPOCFLBISfFkhcHiCXTm28gkFrC2pT8UjbW)URqyI7I7mKCJPqJ9ZiztHeqdteOWaikOmo8lz6mIMTAyhbzNt60iuA79IcDdfrzWBy4w4QaBwn3nTOc60eNin0b7HnXpGIuH6vxkSymkROBoSmVz5sRiXB)IExoYu9f9lnKKGulnIV6DIgyFm6krxp5mwNKlWk0hi0hI7s0ky8xDKJ5iDI0XDLtNvrYs0j7ITNjxv2rU6iP)gsaQ829u0TZpUmncIo0hfMrOt4UoYOXdF7gmc7lLaGD8)53VJxgE(zLMgllLvekxooMLWD((RIbDrHSJwjq41SY18WlAGpuy5iEyxK7XN6rHrWyWLzu8vRaYNqy9HfRAJjSfwzQjn1m0aAKnM8mK4GncfbJYyr0pcBmon3VMd0wM9IbFW(iPXv(65kFovSym)NhvvBClWXyiP4FfIxIvpDADlQDsBqMqnbXxr65ySq4CtnhdrSvOLdXUjFgeTxKa0Vv2Qw31YvJ2np7W2ouUHOnTbZtcHB9TRyPDkQHPFIsZPou)e7pv8DdpBuDQqr)E(JfsbwKwUnvAx3YaAPkWRBZXTmBs1CiX0tIk6HwztEPk(92pzaMSaYOe8Abrp88Zlsgnn7p6GDcaFlR6Nwb65eO5IcOzCxgcDYQTpUrRf0LQ67GGnuJ49Z7j6q0w(xtwME7O7xLMCh8TkUDTnFENOoQsgTQZvT7f7F)yR33xVEriOWvN3m0(d2EbT)KbhrpD5O3vtJRONcbLdXsc7JQrMk5jiJ0)zujhdMYr6Kz)CYQTW6ThtxaXauKOrYc1n89DlGjKg)eEH7pwMagriGX4cOoba9oGtb3hJMLclmwU2uAvfA5ABvp1idx1N)NrnOpPMYL0XI2lmD81EvMXVCvMXVivMdhmDceY)NxoCW3slEY9mCWKTBMNb)w9q6z4g4NH)9d]] )