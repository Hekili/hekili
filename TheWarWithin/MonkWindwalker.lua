-- MonkWindwalker.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 269 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

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
    ancient_arts                   = { 101184,  344359, 2 }, -- Reduces the cooldown of Paralysis by $s1 sec and the cooldown of Leg Sweep by $s2 sec
    bounce_back                    = { 101177,  389577, 1 }, -- When a hit deals more than $s1% of your maximum health, reduce all damage you take by $s2% for $s3 sec. This effect cannot occur more than once every $s4 seconds
    bounding_agility               = { 101161,  450520, 1 }, -- Roll and Chi Torpedo travel a small distance further
    calming_presence               = { 101153,  388664, 1 }, -- Reduces all damage taken by $s1%
    celerity                       = { 101183,  115173, 1 }, -- Reduces the cooldown of Roll by $s1 sec and increases its maximum number of charges by $s2
    celestial_determination        = { 101180,  450638, 1 }, -- While your Celestial is active, you cannot be slowed below $s1% normal movement speed
    chi_burst                      = { 101159,  460485, 1 }, -- Your damaging spells and abilities have a chance to activate Chi Burst, allowing you to hurl a torrent of Chi energy up to $s2 yds forward, dealing $s$s3 Nature damage to all enemies, and $s4 healing to the Monk and all allies in its path. Healing and damage reduced beyond $s5 targets
    chi_proficiency                = { 101169,  450426, 2 }, -- Magical damage done increased by $s1% and healing done increased by $s2%
    chi_torpedo                    = { 101183,  115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by $s1% for $s2 sec, stacking up to $s3 times
    chi_wave                       = { 101159,  450391, 1 }, -- Every $s2 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing $s$s3 Nature damage or $s4 healing. Bounces up to $s5 times to targets within $s6 yards
    clash                          = { 101154,  324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within $s1 yards for $s2 sec
    crashing_momentum              = { 101149,  450335, 1 }, -- Targets you Roll through are snared by $s1% for $s2 sec
    dance_of_the_wind              = { 101137,  432181, 1 }, -- Your physical damage taken is reduced by $s1% and an additional $s2% every $s3 sec until you receive a physical attack
    detox                          = { 101150,  218164, 1 }, -- Removes all Poison and Disease effects from the target
    diffuse_magic                  = { 101165,  122783, 1 }, -- Reduces magic damage you take by $s1% for $s2 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible
    disable                        = { 101149,  116095, 1 }, -- Reduces the target's movement speed by $s1% for $s2 sec, duration refreshed by your melee attacks. Targets already snared will be rooted for $s3 sec instead
    elusive_mists                  = { 101144,  388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by $s1%
    energy_transfer                = { 101151,  450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by $s1 sec
    escape_from_reality            = { 101176,  394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within $s1 sec, ignoring its cooldown
    expeditious_fortification      = { 101174,  388813, 1 }, -- Fortifying Brew cooldown reduced by $s1 sec
    fast_feet                      = { 101185,  388809, 1 }, -- Rising Sun Kick deals $s1% increased damage. Spinning Crane Kick deals $s2% additional damage
    fatal_touch                    = { 101178,  394123, 1 }, -- Touch of Death increases your damage by $s1% for $s2 sec after being cast and its cooldown is reduced by $s3 sec
    ferocity_of_xuen               = { 101166,  388674, 1 }, -- Increases all damage dealt by $s1%
    flow_of_chi                    = { 101170,  450569, 1 }, -- You gain a bonus effect based on your current health. Above $s1% health: Movement speed increased by $s2%. This bonus stacks with similar effects. Between $s3% and $s4% health: Damage taken reduced by $s5%. Below $s6% health: Healing received increased by $s7%
    fortifying_brew                = { 101173,  115203, 1 }, -- Turns your skin to stone for $s1 sec, increasing your current and maximum health by $s2%, reducing all damage you take by $s3%
    grace_of_the_crane             = { 101146,  388811, 1 }, -- Increases all healing taken by $s1%
    hasty_provocation              = { 101158,  328670, 1 }, -- Provoked targets move towards you at $s1% increased speed
    healing_winds                  = { 101171,  450560, 1 }, -- Transcendence: Transfer immediately heals you for $s1% of your maximum health
    improved_touch_of_death        = { 101140,  322113, 1 }, -- Touch of Death can now be used on targets with less than $s1% health remaining, dealing $s2% of your maximum health in damage
    ironshell_brew                 = { 101174,  388814, 1 }, -- Increases your maximum health by an additional $s1% and your damage taken is reduced by an additional $s2% while Fortifying Brew is active
    jade_walk                      = { 101160,  450553, 1 }, -- While out of combat, your movement speed is increased by $s1%
    lighter_than_air               = { 101168,  449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within $s1 sec, but the cooldown of Roll is increased by $s2 sec
    martial_instincts              = { 101179,  450427, 2 }, -- Increases your Physical damage done by $s1% and Avoidance increased by $s2%
    paralysis                      = { 101142,  115078, 1 }, -- Incapacitates the target for $s1 min. Limit $s2. Damage may cancel the effect
    peace_and_prosperity           = { 101163,  450448, 1 }, -- Reduces the cooldown of Ring of Peace by $s1 sec and Song of Chi-Ji's cast time is reduced by $s2 sec
    pressure_points                = { 101141,  450432, 1 }, -- Paralysis now removes all Enrage effects from its target
    profound_rebuttal              = { 101135,  392910, 1 }, -- Expel Harm's critical healing is increased by $s1%
    quick_footed                   = { 101158,  450503, 1 }, -- The duration of snare effects on you is reduced by $s1%
    ring_of_peace                  = { 101136,  116844, 1 }, -- Form a Ring of Peace at the target location for $s1 sec. Enemies that enter will be ejected from the Ring
    rising_sun_kick                = { 101186,  107428, 1 }, -- Kick upwards, dealing $s$s2 Physical damage, and reducing the effectiveness of healing on the target for $s3 sec
    rushing_reflexes               = { 101154,  450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within $s1 yards after you Roll
    save_them_all                  = { 101157,  389579, 1 }, -- When your healing spells heal an ally whose health is below $s1% maximum health, you gain an additional $s2% healing for the next $s3 sec
    song_of_chiji                  = { 101136,  198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for $s1 sec
    soothing_mist                  = { 101143,  115175, 1 }, -- Heals the target for $s1 over $s2 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target
    spear_hand_strike              = { 101152,  116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $s1 sec
    spirits_essence                = { 101138,  450595, 1 }, -- Transcendence: Transfer snares targets within $s1 yds by $s2% for $s3 sec when cast
    strength_of_spirit             = { 101135,  387276, 1 }, -- Expel Harm's healing is increased by up to $s1%, based on your missing health
    summon_white_tiger_statue      = { 101162,  450639, 1 }, -- Invoking Xuen, the White Tiger also spawns a White Tiger Statue at your location that pulses $s1 damage to all enemies every $s2 sec for $s3 sec
    swift_art                      = { 101155,  450622, 1 }, -- Roll removes a snare effect once every $s1 sec
    tiger_tail_sweep               = { 101182,  264348, 1 }, -- Increases the range of Leg Sweep by $s1 yds
    tigers_lust                    = { 101147,  116841, 1 }, -- Increases a friendly target's movement speed by $s1% for $s2 sec and removes all roots and snares
    transcendence                  = { 101167,  101643, 1 }, -- Split your body and spirit, leaving your spirit behind for $s1 min. Use Transcendence: Transfer to swap locations with your spirit
    transcendence_linked_spirits   = { 101176,  434774, 1 }, -- Transcendence now tethers your spirit onto an ally for $s1 |$s2hour:hrs;. Use Transcendence: Transfer to teleport to your ally's location
    vigorous_expulsion             = { 101156,  392900, 1 }, -- Expel Harm's healing increased by $s1% and critical strike chance increased by $s2%
    vivacious_vivification         = { 101145,  388812, 1 }, -- After casting Rising Sun Kick, your next Vivify becomes instant and its healing is increased by $s1%. This effect also reduces the energy cost of Vivify by $s2%
    winds_reach                    = { 101148,  450514, 1 }, -- The range of Disable is increased by $s1 yds. The duration of Crashing Momentum is increased by $s2 sec and its snare now reduces movement speed by an additional $s3%
    windwalking                    = { 101175,  157411, 1 }, -- You and your allies within $s1 yards have $s2% increased movement speed. Stacks with other similar effects
    yulons_grace                   = { 101165,  414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for $s1% of your max health every $s2 sec in combat, stacking up to $s3%

    -- Windwalker
    acclamation                    = { 101036,  451432, 1 }, -- Rising Sun Kick increases the damage your target receives from you by $s1% for $s2 sec. Multiple instances may overlap
    ascension                      = { 101037,  115396, 1 }, -- Increases your maximum Chi by $s1, maximum Energy by $s2, and your Energy regeneration by $s3%
    brawlers_intensity             = { 101038,  451485, 1 }, -- The cooldown of Rising Sun Kick is reduced by $s1 sec and the damage of Blackout Kick is increased by $s2%
    combat_wisdom                  = { 101217,  121817, 1 }, -- While out of combat, your Chi balances to $s1 instead of depleting to empty. Every $s2 sec, your next Tiger Palm also casts Expel Harm and deals $s3% additional damage.  Expel Harm Expel negative chi from your body, healing for $s6 and dealing $s7% of the amount healed as Nature damage to an enemy within $s8 yards
    communion_with_wind            = { 101041,  451576, 1 }, -- Strike of the Windlord's cooldown is reduced by $s1 sec and its damage is increased by $s2%
    courageous_impulse             = { 101061,  451495, 1 }, -- The Blackout Kick! effect also increases the damage of your next Blackout Kick by $s1%
    crane_vortex                   = { 101055,  388848, 1 }, -- Spinning Crane Kick damage increased by $s1% and its radius is increased by $s2%
    dance_of_chiji                 = { 101060,  325201, 1 }, -- Spending Chi has a chance to make your next Spinning Crane Kick free and deal an additional $s1% damage
    drinking_horn_cover            = { 101052,  391370, 1 }, -- The duration of Storm, Earth, and Fire is extended by $s1 sec for every Chi you spend
    dual_threat                    = { 101213,  451823, 1 }, -- Your auto attacks have a $s2% chance to instead kick your target dealing $s$s3 Physical damage and increasing your damage dealt by $s4% for $s5 sec
    energy_burst                   = { 101056,  451498, 1 }, -- When you consume Blackout Kick!, you have a $s1% chance to generate $s2 Chi
    ferociousness                  = { 101035,  458623, 1 }, -- Critical Strike chance increased by $s1%. This effect is increased by $s2% while Xuen, the White Tiger is active
    fists_of_fury                  = { 101218,  113656, 1 }, -- Pummels all targets in front of you, dealing $s$s2 Physical damage to your primary target and $s3 damage to all other enemies over $s4 sec. Deals reduced damage beyond $s5 targets. Can be channeled while moving
    flurry_of_xuen                 = { 101216,  452137, 1 }, -- Your spells and abilities have a chance to activate Flurry of Xuen, unleashing a barrage of deadly swipes to deal $s$s2 Physical damage in a $s3 yd cone, damage reduced beyond $s4 targets. Invoking Xuen, the White Tiger activates Flurry of Xuen
    fury_of_xuen                   = { 101211,  396166, 1 }, -- Your Combo Strikes grant a stacking $s1% chance for your next Fists of Fury to grant $s2% critical strike, haste, and mastery and invoke Xuen, The White Tiger for $s3 sec
    gale_force                     = { 101045,  451580, 1 }, -- Targets hit by Strike of the Windlord have a $s1% chance to be struck for $s2% additional Nature damage from your spells and abilities for $s3 sec
    glory_of_the_dawn              = { 101039,  392958, 1 }, -- Rising Sun Kick has a chance equal to $s2% of your haste to trigger a second time, dealing $s$s3 Physical damage and restoring $s4 Chi
    hardened_soles                 = { 101047,  391383, 1 }, -- Blackout Kick critical strike chance increased by $s1% and critical damage increased by $s2%
    hit_combo                      = { 101216,  196740, 1 }, -- Each successive attack that triggers Combo Strikes in a row grants $s1% increased damage, stacking up to $s2 times
    inner_peace                    = { 101214,  397768, 1 }, -- Increases maximum Energy by $s1. Tiger Palm's Energy cost reduced by $s2
    invoke_xuen                    = { 101206,  123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for $s2 sec. Xuen attacks your primary target, and strikes $s3 enemies within $s4 yards every $s5 sec with Tiger Lightning for $s$s6 Nature damage. Every $s7 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing $s8% of the damage you have dealt to those targets in the last $s9 sec
    invoke_xuen_the_white_tiger    = { 101206,  123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for $s2 sec. Xuen attacks your primary target, and strikes $s3 enemies within $s4 yards every $s5 sec with Tiger Lightning for $s$s6 Nature damage. Every $s7 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing $s8% of the damage you have dealt to those targets in the last $s9 sec
    invokers_delight               = { 101207,  388661, 1 }, -- You gain $s1% haste for $s2 sec after summoning your Celestial
    jade_ignition                  = { 101050,  392979, 1 }, -- Whenever you deal damage to a target with Fists of Fury, you gain a stack of Chi Energy up to a maximum of $s3 stacks. Using Spinning Crane Kick will cause the energy to detonate in a Chi Explosion, dealing $s$s4 Nature damage to all enemies within $s5 yards, reduced beyond $s6 targets$s$s7 The damage is increased by $s8% for each stack of Chi Energy
    jadefire_fists                 = { 101044,  457974, 1 }, -- At the end of your Fists of Fury channel, you release a Jadefire Stomp. This can occur once every $s2 sec.  Jadefire Stomp Strike the ground fiercely to expose a path of jade for $s5 sec that increases your movement speed by $s6% while inside, dealing $s$s7 Nature damage to up to $s8 enemies, and restoring $s9 health to up to $s10 allies within $s11 yds caught in the path. Up to $s12 enemies caught in the path suffer an additional $s13 damage
    jadefire_harmony               = { 101042,  391412, 1 }, -- Enemies and allies hit by Jadefire Stomp are affected by Jadefire Brand, increasing your damage and healing against them by $s1% for $s2 sec
    jadefire_stomp                 = { 101044,  388193, 1 }, -- Strike the ground fiercely to expose a path of jade for $s2 sec that increases your movement speed by $s3% while inside, dealing $s$s4 Nature damage to up to $s5 enemies, and restoring $s6 health to up to $s7 allies within $s8 yds caught in the path. Up to $s9 enemies caught in the path suffer an additional $s10 damage
    knowledge_of_the_broken_temple = { 101203,  451529, 1 }, -- Whirling Dragon Punch grants $s1 stacks of Teachings of the Monastery and its damage is increased by $s2%. Teachings of the Monastery can now stack up to $s3 times
    last_emperors_capacitor        = { 104129,  392989, 1 }, -- Chi spenders increase the damage of your next Crackling Jade Lightning by $s1% and reduce its cost by $s2%, stacking up to $s3 times
    martial_mixture                = { 101057,  451454, 1 }, -- Blackout Kick increases the damage of your next Tiger Palm by $s1%, stacking up to $s2 times
    memory_of_the_monastery        = { 101209,  454969, 1 }, -- Tiger Palm's chance to activate Blackout Kick! is increased by $s1% and consuming Teachings of the Monastery grants you $s2% haste for $s3 sec equal to the amount of stacks consumed
    meridian_strikes               = { 101038,  391330, 1 }, -- When you Combo Strike, the cooldown of Touch of Death is reduced by $s1 sec. Touch of Death deals an additional $s2% damage
    momentum_boost                 = { 101048,  451294, 1 }, -- Fists of Fury's damage is increased by $s1% of your haste and Fists of Fury does $s2% more damage each time it deals damage, resetting when Fists of Fury ends. Your auto attack speed is increased by $s3% for $s4 sec after Fists of Fury ends
    ordered_elements               = { 101051,  451463, 1 }, -- During Storm, Earth, and Fire, Chi costs are reduced by $s1 and Blackout Kick reduces the cooldown of affected abilities by an additional $s2 sec. Activating Storm, Earth, and Fire resets the remaining cooldown of Rising Sun Kick and grants $s3 Chi
    path_of_jade                   = { 101043,  392994, 1 }, -- Increases the initial damage of Jadefire Stomp by $s1% per target hit by that damage, up to a maximum of $s2% additional damage
    power_of_the_thunder_king      = { 104128,  459809, 1 }, -- Crackling Jade Lightning now chains to $s1 additional targets at $s2% effectiveness and its channel time is reduced by $s3%
    revolving_whirl                = { 101203,  451524, 1 }, -- Whirling Dragon Punch has a $s1% chance to activate Dance of Chi-Ji and its cooldown is reduced by $s2 sec
    rising_star                    = { 101205,  388849, 1 }, -- Rising Sun Kick damage increased by $s1% and critical strike damage increased by $s2%
    rushing_jade_wind              = { 101046,  451505, 1 }, -- Strike of the Windlord summons a whirling tornado around you, causing $s$s2 Physical damage over $s3 sec to all enemies within $s4 yards. Deals reduced damage beyond $s5 targets
    sequenced_strikes              = { 101059,  451515, 1 }, -- You have a $s1% chance to gain Blackout Kick! after consuming Dance of Chi-Ji
    shadowboxing_treads            = { 101062,  392982, 1 }, -- Blackout Kick damage increased by $s1% and strikes an additional $s2 targets at $s3% effectiveness
    singularly_focused_jade        = { 101043,  451573, 1 }, -- Jadefire Stomp's initial hit now strikes $s1 target, but deals $s2% increased damage and healing
    slicing_winds                  = { 102250, 1217413, 1 }, -- Envelop yourself in razor-sharp winds, then lunge forward dealing $s$s2 Nature damage to enemies in your path. Damage reduced beyond $s3 enemies. Hold to increase lunge distance
    spiritual_focus                = { 101052,  280197, 1 }, -- Every $s1 Chi you spend reduces the cooldown of Storm, Earth, and Fire by $s2 sec
    storm_earth_and_fire           = { 101053,  137639, 1 }, -- Split into $s1 elemental spirits for $s2 sec, each spirit dealing $s3% of normal damage and healing. You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies. While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target
    strike_of_the_windlord         = { 101215,  392983, 1 }, -- Strike with both fists at all enemies in front of you, dealing $s$s2 Physical damage and reducing movement speed by $s3% for $s4 sec. Deals reduced damage to secondary targets
    teachings_of_the_monastery     = { 101054,  116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to $s1. Blackout Kick has a $s2% chance to reset the remaining cooldown on Rising Sun Kick
    thunderfist                    = { 101040,  392985, 1 }, -- Strike of the Windlord grants you $s2 stacks of Thunderfist and an additional stack for each additional enemy struck. Thunderfist discharges upon melee strikes, dealing $s$s3 Nature damage
    touch_of_the_tiger             = { 101049,  388856, 1 }, -- Tiger Palm damage increased by $s1%
    transfer_the_power             = { 101212,  195300, 1 }, -- Blackout Kick, Rising Sun Kick, and Spinning Crane Kick increase damage dealt by your next Fists of Fury by $s1%, stacking up to $s2 times
    whirling_dragon_punch          = { 101204,  152175, 1 }, -- Performs a devastating whirling upward strike, dealing $s1 damage to all nearby enemies and an additional $s2 damage to the first target struck. Damage reduced beyond $s3 targets. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown
    xuens_battlegear               = { 101210,  392993, 1 }, -- Rising Sun Kick critical strikes reduce the cooldown of Fists of Fury by $s1 sec. When Fists of Fury ends, the critical strike chance of Rising Sun Kick is increased by $s2% for $s3 sec
    xuens_bond                     = { 101208,  392986, 1 }, -- Invoke Xuen, the White Tiger's damage is increased by $s1% and its cooldown is reduced by $s2 sec

    -- Conduit Of The Celestials
    august_dynasty                 = { 101235,  442818, 1 }, -- Casting Jadefire Stomp increases the damage of your next Rising Sun Kick by $s1%
    celestial_conduit              = { 101243,  443028, 1 }, -- The August Celestials empower you, causing you to radiate $s1 million Nature damage onto enemies and $s2 healing onto up to $s3 injured allies within $s4 yds over $s5 sec, split evenly among them. Healing and damage increased by $s6% per enemy struck, up to $s7%. You may move while channeling, but casting other healing or damaging spells cancels this effect
    chijis_swiftness               = { 101240,  443566, 1 }, -- Your movement speed is increased by $s1% during Celestial Conduit and by $s2% for $s3 sec after being assisted by any Celestial
    courage_of_the_white_tiger     = { 101242,  443087, 1 }, -- Tiger Palm has a chance to cause Xuen to claw your target for $s$s2 Physical damage, healing a nearby ally for $s3% of the damage done. Invoke Xuen, the White Tiger guarantees your next cast activates this effect
    flight_of_the_red_crane        = { 101234,  443255, 1 }, -- Rushing Jade Wind and Spinning Crane Kick have a chance to cause Chi-Ji to increase your energy regeneration by $s2% for $s3 sec and quickly rush to $s4 enemies, dealing $s$s5 Physical damage to each target struck
    heart_of_the_jade_serpent      = { 101237,  443294, 1 }, -- Strike of the Windlord calls upon Yu'lon to increase the cooldown recovery rate of Fists of Fury, Strike of the Windlord, Rising Sun Kick, Flying Serpent Kick, and Whirling Dragon Punch by $s1% for $s2 sec. The channel time of Fists of Fury is reduced by $s3% while Yu'lon is active
    inner_compass                  = { 101235,  443571, 1 }, -- You switch between alignments after an August Celestial assists you, increasing a corresponding secondary stat by $s1%. Crane Stance: Haste Tiger Stance: Critical Strike Ox Stance: Versatility Serpent Stance: Mastery
    jade_sanctuary                 = { 101238,  443059, 1 }, -- You heal for $s1% of your maximum health instantly when you activate Celestial Conduit and receive $s2% less damage for its duration. This effect lingers for an additional $s3 sec after Celestial Conduit ends
    niuzaos_protection             = { 101238,  442747, 1 }, -- Fortifying Brew grants you an absorb shield for $s1% of your maximum health
    restore_balance                = { 101233,  442719, 1 }, -- Gain Rushing Jade Wind while Xuen, the White Tiger is active
    strength_of_the_black_ox       = { 101241,  443110, 1 }, -- After Xuen assists you, your next Blackout Kick refunds $s1 stacks of Teachings of the Monastery and causes Niuzao to stomp at your target's location, dealing $s2 damage to nearby enemies, reduced beyond $s3 targets
    temple_training                = { 101236,  442743, 1 }, -- Fists of Fury and Spinning Crane Kick deal $s1% more damage
    unity_within                   = { 101239,  443589, 1 }, -- Celestial Conduit can be recast once during its duration to call upon all of the August Celestials to assist you at $s1% effectiveness. Unity Within is automatically cast when Celestial Conduit ends if not used before expiration
    xuens_guidance                 = { 101236,  442687, 1 }, -- Teachings of the Monastery has a $s2% chance to refund a charge when consumed$s$s3 The damage of Tiger Palm is increased by $s4%
    yulons_knowledge               = { 101233,  443625, 1 }, -- Rushing Jade Wind's duration is increased by $s1 sec

    -- Shado Pan
    against_all_odds               = { 101253,  450986, 1 }, -- Flurry Strikes increase your Agility by $s1% for $s2 sec, stacking up to $s3 times
    efficient_training             = { 101251,  450989, 1 }, -- Energy spenders deal an additional $s1% damage. Every $s2 Energy spent reduces the cooldown of Storm, Earth, and Fire by $s3 sec
    flurry_strikes                 = { 101248,  450615, 1 }, -- Every $s2 damage you deal generates a Flurry Charge. For each $s3 energy you spend, unleash all Flurry Charges, dealing $s$s4 Physical damage per charge
    high_impact                    = { 101247,  450982, 1 }, -- Enemies who die within $s2 sec of being damaged by a Flurry Strike explode, dealing $s$s3 physical damage to uncontrolled enemies within $s4 yds
    lead_from_the_front            = { 101254,  450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for $s1% of damage dealt
    martial_precision              = { 101246,  450990, 1 }, -- Your attacks penetrate $s1% armor
    one_versus_many                = { 101250,  450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation. Fists of Fury damage increased by $s1%. Keg Smash damage increased by $s2%
    predictive_training            = { 101245,  450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by $s1% for the next $s2 sec
    pride_of_pandaria              = { 101247,  450979, 1 }, -- Flurry Strikes have $s1% additional chance to critically strike
    protect_and_serve              = { 101254,  450984, 1 }, -- Your Vivify always heals you for an additional $s1% of its total value
    veterans_eye                   = { 101249,  450987, 1 }, -- Striking the same target $s1 times within $s2 sec grants $s3% Haste, stacking up to $s4 times
    vigilant_watch                 = { 101244,  450993, 1 }, -- Blackout Kick deals an additional $s1% critical damage and increases the damage of your next set of Flurry Strikes by $s2%
    whirling_steel                 = { 101245,  450991, 1 }, -- When your health drops below $s1%, summon Whirling Steel, increasing your parry chance and avoidance by $s2% for $s3 sec. This effect can not occur more than once every $s4 sec
    wisdom_of_the_wall             = { 101252,  450994, 1 }, -- Every $s2 Flurry Strikes, become infused with the Wisdom of the Wall, gaining one of the following effects for $s3 sec. Critical strike damage increased by $s4%. Dodge and Critical Strike chance increased by $s5% of your Versatility bonus. Flurry Strikes deal $s$s6 Shadow damage to all uncontrolled enemies within $s7 yds. Effect of your Mastery increased by $s8%
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_serenity              = 5641, -- (455945) Celestial Conduit now prevents all crowd control for its duration
    grapple_weapon                 = 3052, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for $s1 sec
    perpetual_paralysis            = 5448, -- (357495) Paralysis range reduced by $s1 yards, but spreads to $s2 new enemies when removed
    predestination                 = 3744, -- (345829) Killing a player with Touch of Death reduces the remaining cooldown of Touch of Karma by $s1 sec
    ride_the_wind                  =   77, -- (201372) Flying Serpent Kick clears all snares from you when used and forms a path of wind in its wake, causing all allies who stand in it to have $s1% increased movement speed and to be immune to movement slowing effects
    rising_dragon_sweep            = 5643, -- (460276) Whirling Dragon Punch knocks enemies up into the air and causes them to fall slowly until they reach the ground
    rodeo                          = 5644, -- (355917) Every $s1 sec while Clash is off cooldown, your next Clash can be reactivated immediately to wildly Clash an additional enemy. This effect can stack up to $s2 times
    stormspirit_strikes            = 5610, -- (411098) Striking more than one enemy with Fists of Fury summons a Storm Spirit to focus your secondary target for $s1 sec, which will mimic any of your attacks that do not also strike the target for $s2% of normal damage
    tigereye_brew                  =  675, -- (247483) Consumes up to $s1 stacks of Tigereye Brew to empower your Physical abilities with wind for $s2 sec per stack consumed. Damage of your strikes are reduced, but bypass armor. For each $s3 Chi you consume, you gain a stack of Tigereye Brew
    turbo_fists                    = 3745, -- (287681) Fists of Fury now reduces all targets movement speed by $s1%, and you Parry all attacks while channelling Fists of Fury
    wind_waker                     = 3737, -- (357633) Your movement enhancing abilities increases Windwalking on allies by $s1%, stacking $s2 additional times. Movement impairing effects are removed at $s3 stacks
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
        max_stack = 1,
    },
    heart_of_the_jade_serpent_tww3_tier = {
        id = 1238904,
        duration = 8,
        max_stack = 1
    },
    heart_of_the_jade_serpent_cdr_celestial = {
        id = 443616,
        duration = 8,
        max_stack = 1,
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
        max_stack = 1
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
        duration = 20,
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237673, 237671, 237676, 237674, 237672 },
        auras = {
            -- Conduit of the Celestials
            jade_serpents_blessing = {
                id = 1238901,
                duration = 4,
                max_stack = 1,
                copy = "jade_serpents_blessing_tww3_tier"
            },
            flurry_charge_tww3_tier = {
                id = 1237196,
                duration = 3600,
                max_stack = 20
            }
        }
    },
    tww2 = {
        items = { 229301, 229299, 229298, 229297, 229296 },
        auras = {
            winning_streak = {
                id = 1216182,
                duration = 3600,
                max_stack = 10
            },
            cashout = {
                id = 1216498,
                duration = 30,
                max_stack = 10
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207243, 207244, 207245, 207246, 207248 }
    },
    tier30 = {
        items = { 202509, 202507, 202506, 202505, 202504 },
        auras = {
            shadowflame_vulnerability = {
                id = 411376,
                duration = 15,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200360, 200362, 200363, 200364, 200365, 217188, 217190, 217186, 217187, 217189 },
        auras = {
            kicks_of_flowing_momentum = {
                id = 394944,
                duration = 30,
                max_stack = 2
            },
            fists_of_flowing_momentum = {
                id = 394949,
                duration = 30,
                max_stack = 3
            }
        }
    },
    -- Legacy
    tier21 = { items = { 152145, 152147, 152143, 152142, 152144, 152146 } },
    tier20 = { items = { 147154, 147156, 147152, 147151, 147153, 147155 } },
    tier19 = { items = { 138325, 138328, 138331, 138334, 138337, 138367 } },
    class =  { items = { 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 } },
    cenedril_reflector_of_hatred = { items = { 137019 } },
    cinidaria_the_symbiote = { items = { 133976 } },
    drinking_horn_cover = { items = { 137097 } },
    firestone_walkers = { items = { 137027 } },
    fundamental_observation = { items = { 137063 } },
    gai_plins_soothing_sash = { items = { 137079 } },
    hidden_masters_forbidden_touch = { items = { 137057 } },
    jewel_of_the_lost_abbey = { items = { 137044 } },
    katsuos_eclipse = { items = { 137029 } },
    march_of_the_legion = { items = { 137220 } },
    prydaz_xavarics_magnum_opus = { items = { 132444 } },
    salsalabims_lost_tunic = { items = { 137016 } },
    sephuzs_secret = { items = { 132452 } },
    the_emperors_capacitor = { items = { 144239 } },
    soul_of_the_grandmaster = { items = { 151643 } },
    stormstouts_last_gasp = { items = { 151788 } },
    the_wind_blows = { items = { 151811 } }
} )

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
    slicing_winds = true,
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


local XuenCasts = 0

-- If a Tiger Palm missed, pretend we never cast it.
-- Use RegisterEvent since we're looking outside the state table.
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
        
        if ability then
            if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
                if ns.castsAll[1] == "tiger_palm" then table.remove( ns.castsAll, 1 ) end
                if ns.castsAll[2] == "tiger_palm" then table.remove( ns.castsAll, 2 ) end
                if ns.castsOn[1]  == "tiger_palm" then table.remove( ns.castsOn, 1  ) end

                actual_combo = ns.castsOn[ 1 ] or "none"
                Hekili:ForceUpdate( "WW_MISSED" )

            elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
                prev_combo = actual_combo
                actual_combo = ability

            elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
                -- track the last tick.
                state.buff.rushing_jade_wind.last_tick = GetTime()

            end

            if subtype == "SPELL_CAST_SUCCESS" and spellID == spec.abilities.invoke_xuen.id then
                print( strformat( "Added Xuen Cast %d.", XuenCasts ) )
            end
        
        elseif subtype == "SPELL_AURA_REMOVED" then
            if spellID == class.auras.flurry_charge.id then ShadoPanFlurryChargeEnergy = 0
            elseif spellID == class.auras.flurry_charge_tww3_tier.id then TWW3FlurryChargeEnergy = 0 end
        end
    end
end )


local ENERGY = Enum.PowerType.Energy
local LastEnergy = -1

local ShadoPanFlurryChargeEnergy = 0
local TWW3FlurryChargeEnergy = 0

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType ~= "ENERGY" then return end
    if not state.hero_tree.shadopan then return end

    local flurryCharge = GetPlayerAuraBySpellID( class.auras.flurry_charge.id )
    local flurryChargeTWW3 = state.set_bonus.tww3 > 1 and GetPlayerAuraBySpellID( class.auras.flurry_charge_tww3_tier.id )

    if flurryCharge or flurryChargeTWW3 then
        local current = UnitPower( "player", ENERGY )
        local difference = LastEnergy - current

        if difference > 3 then
            if flurryCharge then ShadoPanFlurryChargeEnergy = ShadoPanFlurryChargeEnergy + difference end
            if flurryflurryChargeTWW3 then TWW3FlurryChargeEnergy = TWW3FlurryChargeEnergy + difference end
        end

        LastEnergy = current
    end
end )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
    XuenCasts = 0
end )

spec:RegisterStateExpr( "invoke_xuen_count", function()
    return XuenCasts
end )



spec:RegisterStateExpr( "flurry_charge_energy", function()
    return ShadoPanFlurryChargeEnergy
end )

spec:RegisterStateExpr( "flurry_charge_tww3_energy", function()
    return TWW3FlurryChargeEnergy
end )


local chiSpent = 0
local orderedElementsMod = 0

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
        
        if buff.flurry_charge.up then
            if flurry_charge_energy + amt > 240 then
                flurry_charge_energy = 0
                removeBuff( "flurry_charge" )
            else flurry_charge_energy = flurry_charge_energy + amt end
        end
        
        if buff.flurry_charge_tww3_tier.up then
            if flurry_charge_tww3_energy + amt > ( set_bonus.tww3 > 3 and buff.storm_earth_and_fire.up and 120 or 240 ) then
                flurry_charge_tww3_energy = 0
                removeBuff( "flurry_charge_tww3_tier" )
            else flurry_charge_tww3_energy = flurry_charge_tww3_energy + amt end
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
            t[ k ] = GetSpellCastCount( action.expel_harm.id )
            return t[ k ]
        end
    end
} ) )

spec:RegisterHook( "reset_precast", function ()
    invoke_xuen_count = nil
    flurry_charge_energy = nil
    flurry_charge_tww3_energy = nil

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

    if hero_tree.conduit_of_the_celestials and set_bonus.tww3 > 3 and buff.heart_of_the_jade_serpent_tww3_tier.up then
        local jsRemains = buff.heart_of_the_jade_serpent_tww3_tier.remains
        applyBuff( "jade_serpents_blessing", jsRemains + 4 )
        buff.jade_serpents_blessing.applied = now + jsRemains
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
        cast = function() return 4 * ( pet.yulon.active and 0.5 or 1 ) end,
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

            invoke_xuen_count = invoke_xuen_count + 1

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

            if talent.vivacious_vivification.enabled then applyBuff( "vivacious_vivification" ) end

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
            if set_bonus.tww3_conduit_of_the_celestials > 1 then
                applyBuff( "heart_of_the_jade_serpent_tww3_tier", 4 )
                if set_bonus.tww3_conduit_of_the_celestials > 3 then
                    applyBuff( "jade_serpents_blessing", 8 )
                    buff.jade_serpents_blessing.applied = query_time + 4
                    buff.jade_serpents_blessing.expires = query_time + 8
                end
            end
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
            if talent.heart_of_the_jade_serpent.enabled then applyBuff( "heart_of_the_jade_serpent_cdr" ) end
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

        -- Force GCD sync.
        readyTime = function() return gcd.remains end,

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

        spend = function() return 30 * ( buff.vivacious_vivification.up and 0.25 or 1 ) end,
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

spec:RegisterPack( "Windwalker", 20250322, [[Hekili:S3tAVTnsw(BXyWOwA2ezjklNKgYcy2EMbtAm9b6072lWI1u0uusSnfPwsQ4yad9BFFvXRQyvV6GsYXD28Lz6yrw1RE3NfVD8T)6TFyPxEWT)OZiNPJERJZWXJMmY5D3(H8h3fC7h255FV3A4)i2Bl8)(BHXlFWl6(GuYp9yuI3sYsKLSp1h(5n557Y(2lVCDy(M93n0pz7LzHB3h5LhMe7N6TkN8V9V8UOK7UmFtWdPpapzy8L7stwfgfKD5pNg8lEHlH)JFX9hsIV3TzhhsE1B)WD7dJYFF8T3ja5JE3K3C1uaA2f4d)5RHdXMWLldkE2Gm4Ljp7Rh92x748Thw8HhJ9pSGabW)D42V72pefMLNroqR8IIUdo6W)9psrsbXE3ffS82)9B)GFAyEqAOh8FTj8WI5hwm9WIEhwaN27sCZYtdVhqfE(KZmbycJJdJx7ch)4a37dHfLcmPH7kEI)r1ELdan(EXS6fBx5MpPzVUlcwMK95f7cSCtSF5M2SC5HRdsD35fTfwRCcuVYBFuURFuG3hdKHAQEZ0WmYroBFC5b2)r4LCZ9sxhaiy49yaL72VA1WS8K0TUbEP5BC9Ix6UkmnyyAWwVW4mkCnEIeKmhE051xDyr1wOexM7ffeNpCn8)5Ukb4Chw(yLBrs0YKhIhgg)XK7dC)0(GyxGz19HnWc4sXk8G2i67LfK7Exs8(SH5p8WexND(0)8feGIUFRI2NM(yjWNvTNmSk0FWnzvXUbm(rjPlvthr20YD0paKPYd9IC9tIxUpmN7G(rpyjG)1WSTalO7MK8FpZLamFmWwipk0NqWjWmf3FfkatP2l9I9PhuGR73dbIpW3EyXnhw4yPKeSvtr4bbQvAe5XxM6Toj2D3(y)nSqIUJVciDgaPsyQbO5AJLi4Xi7sdYY2Ng4Uljeq473rbHcOXnioyByqgDFVINhDfrJfb(wTp9roUYRKdGVXEaSEZKIsB20zn0pTq34UJIFlYjqQMwfA8mHtSnbOqFRmO6DMRQT)HfWcMU(XcfUtzLyHJarNBGhRsPNEI7nUEulXtPV0abrPk98d369PdlEDLo)6dlfHKdRcyrEDwLEOTjXEzWr5rgkJUNe2a3YNU48wcOfhc372NMXRk6IY18UK7DbFb8PcaKJ9fAE3bCVoOUminyPlO2Bl8oz1lZNzqO431jwuzfgqWtQbBqXWhhk3YqXZuVQYFOMLFaVSPOTbrbzLNOkyv07NAG)cngzkrV0TzdX4Ff0)7EldCZcs3bBOR)Yu3AOLU7k4TbNuaBr5S81kinio78JJhHkoR7m1Rlhjg4izV)gY7SmWlFdfwW8Y6ZJfUXT9RYyWPBBhUVpAzT6mrqWFMXACOrQ7RLYjldOpcJ3MScAt5Lk1je3RsUs)zRwbMwayql10epEZiUvUK3g0fkFIkgQc3MtZao4OW1BYRKyPuKKSIdXkYV4YchJNYq0KUgwINmiUcyBFBdvxqJiLYJ5FPchMa80UGcKKqGdmIFuv7n6DkCdiCBqfzHGnmsewUZJgyUPHKVgqFpwHox6bVfhLxIJOGjQbiISyobZbi69nZCjxT4keafZzyZuLzo8HS9OEYkpqqJJGvPiu)k)CIsswgTplN1rhlpx4SaTDhwllqbJCYdGWqy8Q9zWtxbXcGR890PTnBdKuTzxP)vzcciGdEEJ05(CtuiVTIKjxaKq1kzfY24bc73L8jYrnpnWBzgJlQkYrKJf5CYavQZR86szQdQCtI3CIxEEuWAyL5ESwP44QD(yET502xbJLNBafqNCs0hPg)jVeVAqDpJEFQKYevGZW0ZIWEH7rsHnK68s2VlP0Ak3bgJioqydqS1mR(eAy8hKCQnqRgrcEGAFwUJBmOhYtIzwYpfipu2dQYoQ2ssIeefzH9oy7UG0eqTQV3opiqJK0kYlbT9UslVTKBkrJfkAkpe5B2hdXJaYHXRp28pIWIGzE7eNPeKDVT1nfBqrG1djmUU5jU08tmdw61(llswXFHQUZiTkseHM2CkEimBzY2AgjIFcfRLQuUHQVXARC91EcyK6W1kk1zC5Ap7BHtZf5LtRBNDi0kQQI2HzCuOGoQyBAlTqM(EVRoegRF1svzYKrMGNMHxOYiyIctWssXPqxdRhzWFXTev0O3LuVsP4xSCvOkB3Lfc7kJD9srStv8mLRPddLSGDC0PCx0N2DNtY2HGSXZuJj(O2W46NShCtlizFMB42D7JYAxFozSm1PTLZWeQxVt0KqhJ8o)QwUXEFCYdWYTUwf7DPGgcq7a40quGSJQomIC)bXpvyjR40ifIq3B7x1Nh6oRUjretBxH(mQOfvfQfomHKP7(gukedpEdqbtlQ0Lonsver9sBZRW51lzlv4vlQcMGRWT2wsj)aSI7J8sJE09FK4VpdWFFp4wJuxti(7qc91DJxkaUpw9qnaq9tarmVDhfcu0ljDa313s0xTJBszoA7EMsP26LsOCzk2av0gml12Q5sxD4Q01qxTpMKMh8jLsS1gnR9lqUwWRWT(zu9Ni(1qlSiDXWTojRAYQf4fjtYuGmMf7OQqNQ5lvrIBBC6Oz(zCRQrZwDjYLF2vYeIBjRSgkE((rEBPTZwHOLsPDlm6OKNvKyHPC(Q3YMnKgEk(mHCLfQWnrycc8XL(II6aXAAhCvXk3WlW3td4Buq6NAHMzZkLFRQ7OAVXZaRSseX0JaMamiSk50fNC28YVvsR8v0VNHKSDTkWp31lZpiM4r4JKG83ZCEu8mSTny9M0WAab0dwpJxwICBNVoDwRvfaoltHj1IdpZ2SkP3Lu8)Z13H)CXFmxvB6X2RoMb0wbq5k74oSAUcksMms2A1wrDYoAJg28OvPhI8FfTpWK6HXBoc)rP54ppmiLEoHnYTGtusn9YfB3o9qAlKaXwrT5enUwkpf9n2FAiYcQVAzdTpxn6mifsLPTQX5mfD2jpOebocklP1TGOcdLTR2LnjpSPM1nBoY70AVRE4G)xap4hSuEgbzqymf1ebl9ma1mBHeH0v7bUvq)6gItIU1v13UKhQ1GgtM76BfrNjogfCsd4EqTlAfBK(YK8g(ZMriJ5DbLRVTtMmQBWY4rhTAJXnWNr82h52zNwQgVNvPu48cd9mHjL8qvf8KujmoBZ)nWR5y43(plndaqXQK0dl(U)2Hf)GxS3A6UYzNjyfDpcRmg22jE9MyAFURJUQ)HM(7z8ioHlKgQs)XFGk2lTQPir1)OmjdY7JMb8gcPKWIy6MeT04Eh4A4PMYjZLVCTldz78BMfh2)zHtYvrgoRiJ7SbloRoj8YjBKNvMx4D74PvzelRivhehViwdd5t8nQ4F4sMHPB)W(mIbSvUR9xsC7MxQ4)idGPFnnm(Es(lOt9u5wMx9hZf7ODUL4N2rqGQGa)w9JWSQ8L3gpxKtBgGigyubw9KITixs34kEA(Us28mvGeXWUF(T8JFuTrFjIhvBjl05xVt5s6n32AFir(CyXpNgMaB4JwdCcsE3qtGmd4unuwEjuhIf6oxfRvLkcjeKPCWdoqlbqkNoSCLTURKT0P7BzrsZe6rxJwJvmtFNqVE6ZxvWzhAgFIwAvyYQVxQpjvha)ukX2sUKgISv2oKY7r4XysAG3AQdPac6(cop8Klz6As9YiZ933VC92kifVgeMUQB8ECR39LcU4jAY0LReBslhex(eOC8khpZ(FDoBmAixmyaw4d(8KV89mipwvyv2Av3)pMZhJ0uYXB6y(nWR9RMmmRp7ZJI2Y8)hN5QfpPzVqNR2owFFk13QHU1MzB12s0rHgK(4HNtrrspKdIhxd9B7Sjzrb7Xn3j2Eokzoy88qBn8nav2RvMJu3ZHvQ0UUsBP59MnUNaN6EnuH4JIX6tv(25XK6SJuJs1EW(6GzDmdMfwhh(IBkJ6stiwHoFUh5(A(jTYd0hqyYZqqbwCrKya3XzrtP5QYqd0uRvMg50pxJzcc9XIwZq0b)Engg4ilOHjGe4SqHXrhKqep64J9JDmy0Q)sn7U4CUySpSgoini0fQ)mYnNXGxmiWD9HBwpTzvjedV9VurYWgjIVyhYgSPo8CpdiDKH8L1aqOyijpR9LlLtt7Sav7UlMLaHzNSRHe53C7BjfnHnyJ2UpYmByW0vyKlg4rLPywfL7fHr73CUo8VTZu5vJgOzmxNwVoKy5DQLozimTIcPz5zPR6nBAkoRtAi68EFsViOoL9lmc8ArxxEY11PS3JB1G)wmuAcDM6Z4CiGf)xRgXvuW500L)wnVz2YsQlB5DHRKZqdsxSRygU6ypABO3NZFEgqbvD)TIrcRJTaCD1kuTR4gPm5yEQ0ZRE6PWTfjBCey69IwvuJudUbQLkYTByT(dZ0py10DPN16mm9dkgSRon9dwygrPUorIfMjbfJxvhMbhh2yV9XgLcluyAIgD7hLcfZkKYn8SnkfkMZNZ64m00yok7ka0gDZ64AhXjjwxPxt6mm2IPmHl)sS8m8P2xczc15im)quC0yXrht1pnUsa108(s7(qHwffP0gIV6B)YVtcr8E74O6xiVw78ubdl9DRExu(itI5SSKWWL4xKIqEStuU2zO2D6SU2Cw(XcTg9AownfwIRfKTRu8A2d5CM9mkms8keEDh7H(wRKby8gIL(0eRQfbQ1Aw1Dl3dH351Y2UMuQB6PCSWaMy6mG1NFQuWBq1gZh609sB3BEOb5znYxa6YXoTaAtHgnzWAR5SdZCPrYgeaJenoErrecJMUk8ReMNhcdvFzr5nY13BfFLQ88qvilbLYqjkAUek)kr55HOCxqAwqkPkKfXQKxnNfk(iQu(mJjf(njN9FZ4kuXFBy(4HB8YCjt9b5iuysV63Ce)ntgj6A)ryj1(j7JHWW)Z1PDqdcGFEis2dR3HfjXhwqNAdWvo5T3AlCGZZYz2GJdhLWrLp3hl17IZ)HHJ2uooqu)b)jG(SNJ(G5QUT0hnNkR9GCYiJoPIKnmN0nHSXEiSKh8CDaLtkDKrkXcDqgP8ioPNcgurYgwDgpbKnCwZwO3FmPaBwRhtwSchbwvfGiIrW63gcMKE5AiBA5(TaVD0WfPlxZJsTnXp(D6)aOnR6kuWYrCOyFaSy9C(P9g)albjn7MyBaKZnNyQposZyR8UtqzBGIbn8iGXe3xiHMQ(SFmjJZiOuOnPTiN2S5RvXeZOgxYN)uMrKgnr)MdG9vUZxOFAnOVTTnjmJZ1T61WM6YiC)7RcdPPIqdujbGBSJr0uuOwCULmfLDrhWA9mSJamlFy6KP16IVPD6J5n0Jff10aqSJahh5H)tQGCOgphyDKix9AAMgjP5IUbiL3P16tnKQgAVVHmU1YRgo(g6dOTHM(SmQhOpGLaRbSPZOvJrJRES65LpQhy9yBNuG95u7f3gGrdKjFY9diCXYvnQifqYv8yZ5MqznYhd(UHMaw4o8yI(bz25LQZOwQrckTEYKvQkLXrj5vGxy6wuZE2)RJLUrZnoV2ovnLt1RJ2eqFMbHE8(jBqdJvd2AhV9UOTsbVHTF(eLQX5kPLyRyaY5lXMndEuHeU28k0ZSpSAADhqBn5v7ZTI78JUqY6zyaFMABXY9whVlJ1wltWLKl2mU4r52dNj1m9Y00RpN8Jz6ID5svuAhUV6LeHt3vCGrWdUx4T(wpzQHm8Tc3b6MBznPZYqvEjShhCk5am5mkmYwhPRhhTdeh)NkU6(tsPri9DxX8dTV2409TertGA285MZ8Z6vVCoo28P53G4xvmQuDu1TjbCxBqe1dQsgCZ(cNyY5e3WFbBWgDT3Z7QoDNP45eeZfB0qNo23tJzg6z05Inx5mGzgsYz0FqrsZ647n)a7CQPe3Q5(ttlUT82js0hdToyYDkB0ARFhN28WOPaWOZUc)jOEYxNfJLHbShwrTJxvfHTPwaBxRbBMkoM(59QID1x1hwl6dyKIF1UYRyG4eYx3xSFS(uc3wlK21PqVSZB6XLTw11z5OZ0PO)gkk0vziiOAfmumriDzct7OcXeZZeP(siqrHD6dcOfFwH5tyRk)MATh4oFP1LNwgV06JUnthOUCnjMOjbKq)ZIyTchzvmhIiJoy7StRZfdzKeUBRleeVf12djdwgjqGYKPZrbtcy5nS8fBd2Y8TvS5XzzrQ0TH9SgLxgvKBCxa6BtadTEiexBKCJtGKdsLjBuhNY7yZ7O8qp4t)OIzuulkWwfikgoXQm7DutWRz3udcFN1uFIlzZqt1JnNFl6QKNZSyOczzHoFJ0XO3OlMwiB(4PPGqQDCPLDmMR6yO4R2IolH8ogR5Z)IUYWOxJKY7wcmMwlm(CU5a0Mu6tZ9Ar1UlzIU13mikvB7ZnE12f3NAUwmhQEUhYFfFw7e9vrF5a5NFvjLbw(zxLBEt5(eS1(QsHZ4OIplDwQW24b4F6ewOZhzM7NAHAzLawjRG9ZC)unzVurvGX2td4jurwX1tDoN5EYxohi0AYp9JoJCMoAIdyp9bVucodETFDdqfaFzssZl)W78n5f9UC23CyrkOXhy(GJEwcP0sE7bUqVCYFWFJx8AqN4HV)Fr)(9m(BjFIpIHnJ(ZvRYq(2NgwZ8eMFnx4N7p(td0UOoQxuHFw1IMSliLEHzas0HX4WwpKLVNM6D3dFkD(Z)zNNEIul0ECzJyMZin4PZbSGck1ioNZbjgBrpks8KZbKITOhfKE15asXw0JcsNEoGuSf9OG0Rphqk2IEuq6Bohqk2IEuq6Bphqk2I2ri9W3lXAw5KL8ngAmJUcRsIIsEamqsEOupWWWdGZc0X0AzHrICYJvyY9WcY3QiIFm5vpxCcD73hZ90lxsE4LE5E35Lf8Ta8sAXpd(oRsozVNEOiB)743ycqdw)3NVjj92p8HWTFh48bS(l)jWzGFlmE5dErKV1pGxgjRcjFd8(t)jyxZZ3L9TxE56W8n7VBi4NZLzHBHqtilm4j1QCY)2)Y7IsU7saYahgEaE0W4l)R09U6ZL1)IabxwIJVect5EA65l2ZHKL4W3t2pcCbe7)6(17j4khhs1dDMsXaxpD5BME9DKtzXblBy9394)TBUKqNb7yBFf5Rb1n4FkJl2O)7)zW9HrH)phw8Es9Uj(2vrZ(ba6AqidJ27v8kY20k7KLBABJLVkz3nzb5VI(5e8MreqNFZ)jcZqYkGvZh8VOKxSHnyyXZ)djKeVsyUlkQhh8aqrkWh(QWv3SfEoYjz4saDtcEE(02pkXt88eGXzzIHVXQOhP5MPKBJ4Nk6B28wcFsOHL9WIIpWYSpxXNQyYcw3cSO1psRxleXC0obu6MEHb7Q9RQe)JUzIeQ)F)tGN9XKjN7NFFP2GS97QeGj8ISCb)DAmbfpBiWY49rVWi6FQffJNPKOdmOCJC3fwYl2UEDf312HXR2tIbWD0WL7l82D(i2Zi)slwEGYvNIY0n6fGFKQFm2pG0TrD)tGievGLkoArpounEqQWjGFlb5Xechnclf8cuMyZ(sK2gG)LGTuPykBbqNZFmIAibf3YE1bvcJCSuZVUxFDjq9PNkilvxtqZbN3VaPDyh0RpLEyqbCNpE6tp1hRlwB2cKVZWdkePyl7eZrrDrCNnTz5L)Kd6HLgYsgoHYiZDQoHWbZsjr5H4h54z2ue9EQd0F20E91qgE6jmk4G6Fc5vliGQAZL5JFtpBooZTfznqAyOtgz3UoEuheIgpqpNuhwwvYMLBiIiZPyh6HXm0JGTbeLPk0uPdUu5lVwT(fKq6cm8VThCWoj(drH(b94b)Bg3Rpvmz8OA(ZMjNdf(bC3fS7WYIDG0(sbsiTAKAPxYmaCi0CvZhFvpz7tAY(8ac8k8cooGkxrkK0peZ4eok5z2uyPax7M70d5XE6jYppT4)BsVISppBkGjR)pfq3p9uRmo2thq80tTfhR(lI4efmCYqU4wkLYuDQyDAZFye7bVDAGX4loYSuvVT1q8py1marFtCvlMCsjERnOTdVMO6Gv298qYLZ81vgb5QjoLCdLSdypy9rx8hqx7AoLg3aeCLQc)Xw7TQ)wRp2vsvk0cdmrgMAQuDhuAFHnjGxwgcUNa12ColQMjbolti1TjQDMbXX5RmiMXGq8xVIrqQf5rIScYTepAqLhwQAZBXCJigYMs(OcIICU2rLHFX6INmh4mn(eNtIp8dKIV48A2q)1Tk4gMJPbpnXRF7HhcxM1V0v1Su8T8XGb96FcefQPz8REP5CgJ4s9CexgxxKcdQ1p0EJvkwX)WNAqQ)jG)95kgCdEyQ6knHK)YcChqZyz5f8y5vrxgRF4KBXx3I)PlPgdfQblR)s2RizKpz1k31(lVzmDL(j6feM(LG7IlJMCyQWxlxxNnPb8(UYJMbWxfwi7vegx)8Iu)vj9kbVxL1psTloSOQKg63OQlRmVKaUTQLyYntnFP8Jc8(OYvBCBKKfRo8VXx5zo6xOvWF9osZRY8KEP(KgUbWRPacMSUGYSz(f3Ef1(sWbL35TMAxdaL7ZOjuh10mHqY(Q08WK5(77xUEB52z(lVX7XTE3xWXP7TAxbg)7jDwRxkPVFn59fqq02e2K30MQiugufvezM3HfBsdwDZ3uvvVhE4HHpK8WgWv0Is7Tlik6MXJgD9OlPfe41vfe4BM)ZK)9HfVV8pm7sV5hwa6nISzLDM8UrxDzH2Nxt0(8Aq7ZRPAFEnv7Z3m)90F8WI)l4xFvzTW(nYdaQGiprXghMv9TzGpSXH1c3v57VU0he0AbxkFToO59xtHL6FHeFZeZiNH(MnqvGYLuqi8aiiz0WJBoNKATjHx5vCxNhfYZOzIrFYmpPw2njtIKgzR055MIKWDQBYxrZzJjLlwzRBenTkZMQimjYVpHK(fM(sSblu3eGdKdSkaczukXU0hpHfgY0nBsV(TqsmurMmJW)qV9LrgNmHLHOsG0jfz7IiTNAn)trLuDuiazj1rASMYrMsEsaJEMiVVaOtp9u)lepDnOgzflKvT0oVC)nG257b2oKVansZYErwHuK)D(ftEEe7jPqeLLjq6R3ki)Ey7(PrNGD41EiyVJxqAYjWsK84hTrLTKsiRZUddvKR46gX2GNBhuYoF6lR5SfRQLCSbFoXU2YcBY92ArnMel9u5CXVOj5hhilND54wtdj(sQVYlwoa(V8sYFg(V8p1r5yY5GnTjQAtR(xOieEt6VeVLpQRNoWB6c4LnkfYJhjV6zoJKJ4A(Y88vKMXinYltrCFfNzmoR57AZxrAsrA0Sassw3IFTqHEdEKjrF3WhwA)cNRNpDAVAKuC1v8ALR3Zbv7xi(ZKwrPjwZELzm71e)3VXPuFTMBSGz6EQ67316STZvLIY0E0msIdk)tT9)NMqKJEj6DbkfS0kgjiCyJuCxQACfYy60h0BbMzL4zzWArcd4gtrzmeSgiP3BQuF5vCdBuIES42abzBLF8z8fR5QV0oplgpsweSYRGekWXE7rzBkpuI9SdmeNkuzETrPiYUcjabrt4amCB4K3P7jPD9leNkDcZ5DAB8tmG4bzxJgwDAzkbqBwCoTEINdLADDqCcoqym8NDt5i4)xMObn0yWPmBm1x3vfPY7AHSWqU)ZmLzvbdO2UAxu8LpI8xZe1iFK28aLGyH6AhyE6PbuNYZh6hlbA)MiKdmP5ftEgNbJdT7fKXY7civ5T2ItQwEZzVfJN4lv0VeVFi0GpNOAobCZ0BAU4hBoEeVTRqGOwbrlhMkXlsv7Y4GHA9yZh3tH6yG4QKLJ(JIFhIE5Oe3CDWgB9QIDhR1AA93vHEBLQU5OM)4UfhKJ8y8aM66OJ02csSC4M5uN0QuqBnofIUQyDgWetMr(eofP3LgyKrvJrS6cOPWRS3wHCZ24bhH7s(ezNYjbcIUvyxZQOEir2y8KL9o(O3kHNIspxc15B2hdXv4sc62wpW7QxdA1L2xkvSDlux7nLLSjt7jnN421VFZF3alFbiU(oBC5mJqS8KCkp6k03RwRTCn9uHcvxWOu9ExFkJrIwsZt5ckZyqLMYtzSyTDGOsNIGTADUh88grwl7HtTW(TGMCCn01b(lClk2tHD1Y4Xp)CdN8Dqw2LQqb0L6JKoa6tg7nY5qUwcm2HT3V5(dJKdZ(ksMOsifvLg)1GMI6qICd7vRwV9TQ3PKOJN)ttO6uLExzSygp(xtotmY7ksJOJDcyAdEr56QwMJjxWD7yyuAInEPp1kIStdr7ZgTlEQB1)5tN2rCuFCrlzXJ0iwowwGjd0W60nyuh7iTHMyQsIfmqTueuim6caaO)4BLmmvf35U2RrdvuMhNIg0r1fJinYvB10w)2hddNoLr1T2OX0y0vuOBj7ixfp9ODpQrL(1PJOSEEoV(QQlvhj7wr32FJbz7rVlvJNOPsbfBgEi(HFMRBtd895U0nnqIC2B0m6OTAn1RSXzBs15rrMLuS1MYTjgQaVNcZUsxSdsCIWgO4zjdNws9156LkwJwoAjXbI6TwHbHV0Q4Ft9d49h4O7daRxyDQ0FH3DaKwJwzHDSTU)s4wyITYcNjAyRFUBuHxc6BnER72Y)cR2X1WL91VurHhnUkG9nGNHQB4mxLZxyfzwaGgPGJ6)Ft5ErvFABCx6cDdzy74ykgPgL1NgPaVAdSUkqIiMVirl9EiU9foXmzzAR(qRT0jpJ1LVJQZnhESpGn8KpYeahkFRSBdedeb59q4yiEfSwCJk7WQsHW9fd7OKkmDxKm6)OBBNlAC)2BsZ9BJyYbvHC1LWOov8fSgAZOIWyV8X5Spke1ZyV4vyXTcX8PwwXv8ovGzHKxop2RFh8OcKwXv5(dQYk)FWAhb8d8Pnm9Uj11L6E1IfDQbf4U1RC1r4FUw9ZS9LW)x7DT0Btede(3seQRksOOSBBGl0CcXr4ah4wH0hQurBdISvCJF7yVVIFmp96nnvu1lvjzThpZ4XZJV1JaCje5NfeIfO9rAvj5HYQJEX5sts4Iq5w9dj0M8IGnNcwLsKmlcFYn0Shm3sG6LX5Xxt5RjC1kkOKx3ENfuv0Nz1fAFAgi0OA4043jUZJPvzz(Jat013thCU8NpS5p3D9v3myR4IFB2Sy2OCTTnzqaRsnoONpDunSIClnOtL60AIiTz(YPd(n4SDnv8xK26kN39h237)i6laya3MrebLhEWEheoeduM3dpnaFAxitjcMcHYTNAe1iKm5uVUmfq1GT9jvC1iXAfQYYLmqRjwHqPESykPtUsargMtMNguYiutHREQH9BuPsXXaiNYD94QWzBBDesCafuXPdxvMK3whMLg70KjmUGmDe7cMXNXj0Qa0ud6MYiaLHMMzMJJEmYytwyyLHlIx9gGlzXUpsBnpaSPfY5HJvjOk(0lCTjON2xqEsgu)pPKlljhYJE2fp3fX33MiKdC6Sho)xHOygueg9ydc4YxtFU9Aiy9vVnpvEvyQGYqfAFgwB9)tKm7h2nuf6X45Qn)U)S(2nCqSRyRtfKVh2ilE)mbdAnv(Irz9YB9YzC4NTa5U(mI7G1EbssP4fawEydWsT7cZgmgB1D8GWyQo9MmwDipUOtAeUyWCnfMbNKVnOHQWzJtXCWu78LklPSBz99IgByeRmQIagGqWigqwZz4Y9LayDQVTf6NXw8mOXwjZGvg9k6AJCv36iDjXeDSJQdtsRIiRoHi9tmjF2T1FHvXjW4jYj9F6EMmrJdB8JGAlrurYHNS7He9txcm4lq7RiVbTHU2S9d9adSp3keCp5nRebhgce(w31IERJzH9snT2x6KjKRXQfpJxJVVs5D3CLews5IGZ4i9)yGukemYljI0d11RdzLypg1kTIJsG6TMHL80QtpQLSEn2jHdDOPIhvwaaJdgAo8yZtTHfRXPf2auAkfAeUy4H6cMlzrPIiiztptqBwenPshwlQYkTTHr0iOgF62CDIdT4prjCfdEZ8jBjullfGQ0SM1bDnoYOnlGI9JCKrxi1nCpsekFmnty4T(3sN2Atou91XdIZVOxomzlPNa4xjqy6MENuQ)vIre9UEP09gp23bQVHFw3XTiFlFgo0jkoMpgLGVm40TizrqE00M4mWWV0TMY9wS(SwPcvEOyKulLBe4GPor)6qgwsYq8663oMGjEDC241EmBMayvX03Qy6tuhx2P5re(ZHtuo9UqsWqU)46tiAgBDFpri1jyJWtnC6eqImLdjnO0bi30RbHBfHbBC(s1XUxonmXrCk(0GhoaU5yWO2hxh0LJN333JpdJZzVNsro7O)z51gTxmCGphT)w2Bi1g6UTRA)3VVXVlCp3RBBh0aBS8L3Iq5EphCuRiL8QJG(WMhVW2QxTTwWMwu8xQx7EpCv31jXpZ2jXnXFD)B2E3M6(gmE7BuD7)pVC(pwV9B2FNvpQO)JR8)yUY6n4bSB4Fg)pEO(OJQaRRKB7uQNCnScqcUk7emkj9QHg2EdKk)SHb)ibdgJIPyXZYmjlLMO4Iy0KQW6pzHi2A1izRZ0PjKRLGuASkbAmvrVHT(PnTCXDgdetPKCtenc5JojFaD07756F961)YTLrIoBwMHXxShU68AZFN)V)]] )