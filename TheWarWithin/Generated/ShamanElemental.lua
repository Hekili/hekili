-- ShamanElemental.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 262 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Maelstrom )

spec:RegisterTalents( {
    -- Shaman Talents
    ancestral_guidance          = { 103810, 108281, 1 }, -- For the next $d, $s1% of your healing done and $s2% of your damage done is converted to healing on up to $s4 nearby injured party or raid members, up to ${$MHP*$s3/100} healing to each target per second.
    ancestral_wolf_affinity     = { 103610, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    arctic_snowstorm            = { 103619, 462764, 1 }, -- Enemies within $s1 yds of your Frost Shock are snared by $462765s1%.
    ascending_air               = { 103607, 462791, 1 }, -- Wind Rush Totem's cooldown is reduced by ${$s1/-1000} sec and its movement speed effect lasts an additional ${$s2/1000} sec.
    astral_bulwark              = { 103611, 377933, 1 }, -- Astral Shift reduces damage taken by an additional $s1%.
    astral_shift                = { 103616, 108271, 1 }, -- Shift partially into the elemental planes, taking $s1% less damage for $d.
    brimming_with_life          = { 103582, 381689, 1 }, -- Maximum health increased by $s1%, and while you are at full health, Reincarnation cools down $381684s1% faster.; 
    call_of_the_elements        = { 103592, 383011, 1 }, -- Reduces the cooldown of $@spellname108285 by ${$s1/-1000} sec.
    capacitor_totem             = { 103579, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    chain_heal                  = { 103588, 1064  , 1 }, -- Heals the friendly target for $s1, then jumps up to $?a236502[${$s3*(($236502s2/100)+1)}][$s3] yards to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_lightning             = { 103583, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing $s1 Nature damage and then jumping to additional nearby enemies. Affects $x1 total targets.$?s187874[; If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by $333964s1%.][]$?s187874[; Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by ${$s3/1000}.1 sec.][]$?a343725[; Generates $343725s5 Maelstrom per target hit.][]
    creation_core               = { 103592, 383012, 1 }, -- $@spellname108285 affects an additional totem.
    earth_elemental             = { 103585, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.; While this elemental is active, your maximum health is increased by $381755s1%.
    earth_shield                = { 103596, 974   , 1 }, -- Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $u charges.; $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earthgrab_totem             = { 103617, 51485 , 1 }, -- Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    elemental_orbit             = { 103602, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1.; You can have Earth Shield on yourself and one ally at the same time.
    elemental_resistance        = { 103601, 462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by $462568s1% for $462568d.$?c3[; Healing from Cloudburst Totem reduces Fire, Frost, and Nature damage taken by $462369s1% for $462369d.][]
    elemental_warding           = { 103597, 381650, 1 }, -- Reduces all magic damage taken by $s1%.
    encasing_cold               = { 103619, 462762, 1 }, -- Frost Shock snares its targets by an additional $s1% and its duration is increased by ${$s2/1000} sec.
    enhanced_imbues             = { 103606, 462796, 1 }, -- The effects of your weapon imbues are increased by $?c1[$s1]?c2[$s2]?c3[$s3][]%.
    fire_and_ice                = { 103605, 382886, 1 }, -- Increases all Fire and Frost damage you deal by $s1%.
    frost_shock                 = { 103604, 196840, 1 }, -- Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    graceful_spirit             = { 103626, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by ${$m1/-1000} sec and increases your movement speed by $s2% while it is active.
    greater_purge               = { 103624, 378773, 1 }, -- Purges the enemy target, removing $m1 beneficial Magic effects.
    guardians_cudgel            = { 103618, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind                = { 103591, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem        = { 103590, 5394  , 1 }, -- $@spelltooltip5394
    hex                         = { 103623, 51514 , 1 }, -- Transforms the enemy into a frog for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    jet_stream                  = { 103607, 462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by $s1% and now removes snares.
    lava_burst                  = { 103598, 51505 , 1 }, -- Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[; Generates $343725s3 Maelstrom.][]
    lightning_lasso             = { 103589, 305483, 1 }, -- Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    mana_spring                 = { 103587, 381930, 1 }, -- Your $?!s137041[Lava Burst][]$?s137039[ and Riptide][]$?s137041[Stormstrike][] casts restore $?a137040[$381931s1]?a137041[$404550s1][$404551s1] mana to you and $s1 allies nearest to you within $395192a1 yards.; Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury                = { 103622, 381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by $s1%.
    natures_guardian            = { 103613, 30884 , 1 }, -- When your health is brought below $s1%, you instantly heal for ${$31616s1*(1+$s2/100)}% of your maximum health. Cannot occur more than once every $445698d.
    natures_swiftness           = { 103620, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    planes_traveler             = { 103611, 381647, 1 }, -- Reduces the cooldown of Astral Shift by ${$s1/-1000} sec.
    poison_cleansing_totem      = { 103609, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within $403922a yards every $383014t1 sec for $d.
    primordial_bond             = { 103612, 381764, 1 }, -- [381761] While you have an elemental active, your damage taken is reduced by $s1%.
    purge                       = { 103624, 370   , 1 }, -- Purges the enemy target, removing $m1 beneficial Magic $leffect:effects;.$?(s147762&s51530); [ Successfully purging a target grants a stack of Maelstrom Weapon.][]
    refreshing_waters           = { 103594, 378211, 1 }, -- Your Healing Surge is $s1% more effective on yourself.; 
    seasoned_winds              = { 103628, 355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by $s1% for $355634d. Stacks up to $355634U times.
    spirit_walk                 = { 103591, 58875 , 1 }, -- Removes all movement impairing effects and increases your movement speed by $58875s1% for $58875d.
    spirit_wolf                 = { 103581, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain $260881s1% increased movement speed and $260881s2% damage reduction every $260882t1 sec, stacking up to $260881u times.
    spiritwalkers_aegis         = { 103626, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for $378078d.
    spiritwalkers_grace         = { 103584, 79206 , 1 }, -- Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    static_charge               = { 103618, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by $s1 sec for each enemy it stuns, up to a maximum reduction of $s2 sec.
    stone_bulwark_totem         = { 103629, 108270, 1 }, -- Summons a totem with ${$m1*$MHP/100} health at the feet of the caster for $d, granting the caster a shield absorbing $114893s1 damage for $114893d, and up to an additional $462844s1 every $114889t1 sec.
    thunderous_paws             = { 103581, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional $s1% for the first $338036d. May only occur once every $proccooldown sec.
    thundershock                = { 103621, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by ${$s1/-1000} sec.
    thunderstorm                = { 103603, 51490 , 1 }, -- Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    totemic_focus               = { 103625, 382201, 1 }, -- Increases the radius of your totem effects by $s3%.; Increases the duration of your Earthbind and Earthgrab Totems by ${$s1/1000} sec.; Increases the duration of your $?s157153[Cloudburst][Healing Stream], Tremor, Poison Cleansing, $?s137039[Ancestral Protection, Earthen Wall, ][]and Wind Rush Totems by ${$s2/1000}.1 sec.
    totemic_projection          = { 103586, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall              = { 103595, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge               = { 103599, 381867, 1 }, -- Reduces the cooldown of your totems by ${$s1/-1000} sec.
    traveling_storms            = { 103621, 204403, 1 }, -- Thunderstorm now can be cast on allies within $204406r yards, reduces enemies movement speed by $204408s3%, and knocks enemies $s2% further.
    tremor_totem                = { 103593, 8143  , 1 }, -- Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    voodoo_mastery              = { 103600, 204268, 1 }, -- Your Hex target is slowed by $378080s1% during Hex and for $378080d after it ends.; Reduces the cooldown of Hex by ${($m1/1000)*-1} sec.
    wind_rush_totem             = { 103627, 192077, 1 }, -- Summons a totem at the target location for $d, continually granting all allies who pass within $a1 yards $192082s1% increased movement speed for $192082d.
    wind_shear                  = { 103615, 57994 , 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    winds_of_alakir             = { 103614, 382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by $s3%.; When you have $s4 or more totems active, your movement speed is increased by $s2%.

    -- Elemental Talents
    aftershock                  = { 81000, 273221, 1 }, -- Earth Shock, Elemental Blast, and Earthquake have a $s1% chance to refund all Maelstrom spent.
    ancestral_swiftness         = { 94894, 443454, 1 }, -- [443454] Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.; If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side.
    ancient_fellowship          = { 94862, 443423, 1 }, -- Ancestors have a $s1% chance to call another Ancestor when they expire.
    arc_discharge               = { 94885, 455096, 1 }, -- When Tempest strikes more than one target, your next $455097u Chain Lightning spells are instant cast and deal $455097s2% increased damage.
    ascendance                  = { 81003, 114050, 1 }, -- Transform into a Flame Ascendant for $d, replacing Chain Lightning with Lava Beam, removing the cooldown on Lava Burst, and increasing the damage of Lava Burst by an amount equal to your critical strike chance.; When you transform into the Flame Ascendant, instantly cast a Lava Burst at all enemies affected by your Flame Shock, and refresh your Flame Shock durations to $188389d.
    awakening_storms            = { 94867, 455129, 1 }, -- $?s137041[Stormstrike, ][]Lightning Bolt$?s137041[,][] and Chain Lightning have a chance to strike your target for $455130s1 Nature damage. Every $s2 times this occurs, your next Lightning Bolt is replaced by Tempest.
    call_of_the_ancestors       = { 94888, 443450, 1 }, -- $?a137040[Primordial Wave calls an Ancestor to your side for $445624d. ][Benefiting from Undulation calls an Ancestor to your side for $445624d.; Casting Unleash Life calls an Ancestor to your side for $s1 sec.; ]Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell.
    cleanse_spirit              = { 103608, 51886 , 1 }, -- Removes all Curse effects from a friendly target.
    conductive_energy           = { 94868, 455123, 1 }, -- [210689] $?s454009[Tempest, ][]$?s137040[Earth Shock, Elemental Blast, and Earthquake][Lightning Bolt, Elemental Blast, and Chain Lightning] make your target a Lightning Rod for $197209d. Lightning Rods take $s2% of all damage you deal with Lightning Bolt and Chain Lightning.
    deeply_rooted_elements      = { 103641, 378270, 1 }, -- [114052] Transform into a Water Ascendant, duplicating all healing you deal at $s4% effectiveness for $114051d and immediately healing for $294020s1. Ascendant healing is distributed evenly among allies within $114083A1 yds.
    earth_shock                 = { 80984, 8042  , 1 }, -- Instantly shocks the target with concussive force, causing $s1 Nature damage.$?a190493[; Earth Shock will consume all stacks of Fulmination to deal extra Nature damage to your target.][]
    earthen_communion           = { 94858, 443441, 1 }, -- Earth Shield has an additional $s1 charges and heals you for $s3% more.
    earthen_rage                = { 103634, 170374, 1 }, -- Your damaging spells incite the earth around you to come to your aid for $170377d, repeatedly dealing $170379s1 Nature damage to your most recently attacked target.
    earthquake                  = { 80985, 61882 , 1 }, -- Causes the earth within $a1 yards of the target location to tremble and break, dealing $<damage> Physical damage over $d and has a $77478s2% chance to knock the enemy down. Multiple uses of Earthquake may overlap.; This spell is cast at a selected location.
    echo_chamber                = { 81013, 382032, 1 }, -- Increases the damage dealt by your Elemental Overloads by $s1%.
    echo_of_the_elementals      = { 81008, 462864, 1 }, -- When your Storm Elemental or Fire Elemental expires, it leaves behind a lesser Elemental to continue attacking your enemies for $462865d.
    echo_of_the_elements        = { 80999, 333919, 1 }, -- $?s137039[Riptide and Lava Burst have][Lava Burst has] an additional charge.
    echoes_of_great_sundering   = { 80991, 384087, 1 }, -- After casting Earth Shock, your next Earthquake deals $s1% additional damage.; After casting Elemental Blast, your next Earthquake deals $s2% additional damage.
    elemental_blast             = { 80984, 117014, 1 }, -- Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[; If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_equilibrium       = { 80993, 378271, 1 }, -- Dealing direct Fire, Frost, and Nature damage within $378272d will increase all damage dealt by $s4% for $378275d. This can only occur once every $378277d.
    elemental_fury              = { 80983, 60188 , 1 }, -- Your damaging $?a343190[and healing ][]critical strikes deal ${$m1+200}% damage $?a343190[or healing ][]instead of the usual 200%.
    elemental_reverb            = { 94869, 443418, 1 }, -- Lava Burst gains an additional charge and deals 5% increased damage.$?a137039[; Riptide gains an additional charge and heals for 5% more.][]; 
    elemental_unity             = { 103630, 462866, 1 }, -- While a Storm Elemental is active, your Nature damage dealt is increased by $157299s4%.; While a Fire Elemental is active, your Fire damage dealt is increased by $188592s4%.
    everlasting_elements        = { 103633, 462867, 1 }, -- Increases the duration of your Elementals by $s1%.
    eye_of_the_storm            = { 80995, 381708, 1 }, -- Reduces the Maelstrom cost of Earth Shock and Earthquake by $s1.; Reduces the Maelstrom cost of Elemental Blast by $s3.
    final_calling               = { 94875, 443446, 1 }, -- [444490] Surrounds your target in a protective water bubble for $d.; The shield absorbs the next $?a443449[${$s1*(1+$443449s1/100)}][$s1] incoming damage, but the absorb amount decays fully over its duration.
    fire_elemental              = { 80981, 198067, 1 }, -- Calls forth a Greater Fire Elemental to rain destruction on your enemies for $188592d. ; While the Fire Elemental is active, Flame Shock deals damage ; ${100*(1/(1+$188592s2/100)-1)}% faster, and newly applied Flame Shocks last $188592s3% longer.
    first_ascendant             = { 81002, 462440, 1 }, -- The cooldown of Ascendance is reduced by ${$s1/-1000} sec.
    flames_of_the_cauldron      = { 81010, 378266, 1 }, -- Reduces the cooldown of Flame Shock by ${$s2/-1000}.1 sec and Flame Shock deals damage ${100*(1/(1+$m1/100)-1)}% faster.
    flash_of_lightning          = { 80990, 381936, 1 }, -- Increases the critical strike chance of Lightning Bolt and Chain Lightning by $s2%.; Casting Lightning Bolt or Chain Lightning reduces the cooldown of your Nature spells by ${$381937s1/-1000}.1 sec.
    flow_of_power               = { 80998, 385923, 1 }, -- Increases the Maelstrom generated by Lightning Bolt and Lava Burst by $s1.
    flux_melting                = { 80996, 381776, 1 }, -- Casting Frost Shock or Icefury increases the damage of your next Lava Burst by $381777s1%.
    fury_of_the_storms          = { 103640, 191717, 1 }, -- Activating Stormkeeper summons a powerful Lightning Elemental to fight by your side for $191716d.
    fusion_of_elements          = { 103638, 462840, 1 }, -- After casting Icefury, the next time you cast a Nature and a Fire spell, you additionally cast an Elemental Blast at your target at $s1% effectiveness.
    heed_my_call                = { 94884, 443444, 1 }, -- Ancestors last an additional ${$s1/1000} sec.
    icefury                     = { 80997, 462816, 1 }, -- [210714] Hurls frigid ice at the target, dealing $s1 Frost damage and causing your next $s4 Frost Shocks to deal $s2% increased damage and generate $343725s7 Maelstrom.; Generates $343725s8 Maelstrom.
    improved_flametongue_weapon = { 81009, 382027, 1 }, -- Imbuing your weapon with Flametongue increases your Fire spell damage by 5% for 1 hour.
    latent_wisdom               = { 94862, 443449, 1 }, -- Your Ancestors' spells are $s1% more powerful.
    lightning_conduit           = { 103631, 462862, 1 }, -- While Lightning Shield is active, your Nature damage dealt is increased by $s3%.
    lightning_rod               = { 80992, 210689, 1 }, -- $?s454009[Tempest, ][]$?s137040[Earth Shock, Elemental Blast, and Earthquake][Lightning Bolt, Elemental Blast, and Chain Lightning] make your target a Lightning Rod for $197209d. Lightning Rods take $s2% of all damage you deal with Lightning Bolt and Chain Lightning.
    liquid_magma_totem          = { 103637, 192222, 1 }, -- Summons a totem at the target location that erupts dealing $383061s1 Fire damage and applying Flame Shock to $383061s2 enemies within $383061A1 yards. Continues hurling liquid magma at a random nearby target every $192226t1 sec for $d, dealing ${$192231s1*(1+($137040s3/100))} Fire damage to all enemies within $192223A1 yards.; 
    maelstrom_supremacy         = { 94883, 443447, 1 }, -- $?a137040[Increases the damage of Earth Shock, Elemental Blast, and Earthquake by $s1% and the healing of Healing Surge by $s2%.][Increases the healing done by Healing Wave, Healing Surge, Wellspring, Downpour, and Chain Heal by $s2%.]
    magma_chamber               = { 81007, 381932, 1 }, -- Flame Shock damage increases the damage of your next Earth Shock, Elemental Blast, or Earthquake by ${$S1/10}.1%, stacking up to $381933u times.
    master_of_the_elements      = { 81004, 16166 , 1 }, -- Casting Lava Burst increases the damage or healing of your next Nature$?a137039[][, Physical,] or Frost spell by $s2%.
    mountains_will_fall         = { 81012, 381726, 1 }, -- Earth Shock, Elemental Blast, and Earthquake can trigger your Mastery: Elemental Overload at $s1% effectiveness.; Overloaded Earthquakes do not knock enemies down.
    natural_harmony             = { 94858, 443442, 1 }, -- Reduces the cooldown of Nature's Guardian by ${$s1/-1000} sec and causes it to heal for an additional $s2% of your maximum health.
    natures_protection          = { 94880, 454027, 1 }, -- Targets struck by your Tempest deal $454029s1% less damage to you for $454029d.
    offering_from_beyond        = { 94887, 443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of $?a137040[Fire Elemental and Storm Elemental by ${$s1/-1000} sec.][Riptide by ${$s2/-1000} sec.]
    power_of_the_maelstrom      = { 81015, 191861, 1 }, -- Casting Lava Burst has a $s2% chance to cause your next Lightning Bolt or Chain Lightning cast to trigger Elemental Overload an additional time, stacking up to $191877U times.
    preeminence                 = { 81002, 462443, 1 }, -- Your haste is increased by $s2% while Ascendance is active and its duration is increased by ${$s1/1000} sec.
    primal_elementalist         = { 103632, 117013, 1 }, -- Your Earth, Fire, and Storm Elementals are drawn from primal elementals $s1% more powerful than regular elementals, with additional abilities, and you gain direct control over them.
    primordial_capacity         = { 94860, 443448, 1 }, -- Increases your maximum $?a137040[Maelstrom by $s1.][mana by $s2%.; Tidal Waves can now stack up to ${$s3+$s4} times.]
    primordial_fury             = { 103639, 378193, 1 }, -- Elemental Fury increases critical strike damage by an additional $s1%.
    primordial_wave             = { 81014, 375982, 1 }, -- Blast your target with a Primordial Wave, dealing $375984s1 Elemental damage and applying Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    rolling_thunder             = { 94889, 454026, 1 }, -- $?s137040[Gain one stack of Stormkeeper every $s1 sec][Tempest summons a Nature Feral Spirit for $426516d].
    routine_communication       = { 94884, 443445, 1 }, -- $?a137040[Lava Burst casts have a $s2][Riptide has a $s1]% chance to call an Ancestor.
    searing_flames              = { 81005, 381782, 1 }, -- Flame Shock damage has a chance to generate $s1 Maelstrom.
    shocking_grasp              = { 94863, 454022, 1 }, -- Your Nature damage critical strikes reduce the target's movement speed by $454025s1% for $454025d.
    skybreakers_fiery_demise    = { 81006, 378310, 1 }, -- Flame Shock damage over time critical strikes reduce the cooldown of your Fire and Storm Elemental by $?s192249[${$m1/1000}.1][${$m2/1000}.1] sec, and Flame Shock has a $s3% increased critical strike chance.
    spiritwalkers_momentum      = { 94861, 443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by ${$s1/1000} sec, up to a maximum of ${$s2/1000} sec.
    splintered_elements         = { 80978, 382042, 1 }, -- Primordial Wave grants you $s1% Haste plus $s2% for each additional $?a137039[Healing Wave]?a137040[Lava Burst][Lightning Bolt] generated by Primordial Wave for $382043d.
    storm_elemental             = { 80981, 192249, 1 }, -- Calls forth a Greater Storm Elemental to hurl gusts of wind that damage the Shaman's enemies for $157299d.; While the Storm Elemental is active, each time you cast Lightning Bolt or Chain Lightning, the cast time of Lightning Bolt and Chain Lightning is reduced by $263806s1%, stacking up to $263806u times.
    storm_frenzy                = { 103635, 462695, 1 }, -- Your next Chain Lightning$?s454009[, Tempest,][] or Lightning Bolt has $462725s1% reduced cast time after casting Earth Shock, Elemental Blast, or Earthquake. Can accumulate up to $462725u charges.
    storm_swell                 = { 94885, 455088, 1 }, -- When Tempest only strikes a single target, gain $?s137040[$455089s1 Maelstrom][$s1 stacks of Maelstrom Weapon].
    stormcaller                 = { 94893, 454021, 1 }, -- Increases the critical strike chance of your Nature damage spells by $s1% and the critical strike damage of your Nature spells by $s2%.
    stormkeeper                 = { 80989, 191634, 1 }, -- $@spelltooltip191634
    supercharge                 = { 94873, 455110, 1 }, -- $?s137040[Lightning Bolt and Chain Lightning Elemental Overloads have a $s1% chance to cause an additional Elemental Overload.][Lightning Bolt and Chain Lightning have a $s2% chance to refund $s3 Maelstrom Weapon stacks.]
    surge_of_power              = { 81000, 262303, 1 }, -- Earth Shock, Elemental Blast, and Earthquake enhance your next spell cast within $285514d:; Flame Shock: The next cast also applies Flame Shock to $287185s1 additional target within $287185A1 yards of the target.; Lightning Bolt: Your next cast will cause $s2 additional Elemental Overload$L:s;.; Chain Lightning: Your next cast will chain to $s4 additional target.; Lava Burst: Reduces the cooldown of your Fire and Storm Elemental by ${$m1/1000}.1 sec.; Frost Shock: Freezes the target in place for $285515d.
    surging_currents            = { 94880, 454372, 1 }, -- After using Tempest, your next Chain Heal, or Healing Surge will be instant cast and consume no Mana.
    swelling_maelstrom          = { 81016, 381707, 1 }, -- Increases your maximum Maelstrom by $s1.; Increases Earth Shock, Elemental Blast, and Earthquake damage by $s2%.
    tempest                     = { 94892, 454009, 1 }, -- Every $?s137040[$s1][$s2] $?s137040[Maelstrom][Maelstrom Weapon stacks] spent replaces your next Lightning Bolt with Tempest.; $@spelltooltip452201
    thunderstrike_ward          = { 103636, 462757, 1 }, -- Imbue your shield with the element of Lightning for $d, giving Lightning Bolt and Chain Lightning a chance to call down $s1 Thunderstrikes on your target for $462763s1 Nature damage.
    unlimited_power             = { 94886, 454391, 1 }, -- Spending $?s137040[Maelstrom][Maelstrom Weapon stacks] grants you $454394s1% haste for $454394d, stacking. Gaining a new stack does not refresh the duration.
    unrelenting_calamity        = { 80988, 382685, 1 }, -- Reduces the cast time of Lightning Bolt and Chain Lightning by ${$s1/-1000}.2 sec.; Increases the duration of Earthquake by ${$s2/1000} sec.
    voltaic_surge               = { 94870, 454919, 1 }, -- Crash Lightning, Chain Lightning, and Earthquake damage increased by $s1%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5574, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by ${$s3-100}% for $d.; When the effect ends, enemies within $409304A1 yards are knocked in the air and take $<damage> Physical damage.
    counterstrike_totem = 3490, -- (204331) Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker. 
    electrocute         = 5659, -- (206642) When you successfully Purge a beneficial effect, the enemy suffers $206647o1 Nature damage over $206647d.
    grounding_totem     = 3620, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within $8178A1 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts $d.
    shamanism           = 5660, -- (193876) Your $?FAC[Bloodlust][Heroism] spell now has a $m1 sec. cooldown, but increases Haste by $204361s1%, and only affects you and your friendly target when cast for $204361d.; In addition, $?FAC[Bloodlust][Heroism] is no longer affected by $?FAC[Sated][Exhaustion].
    static_field_totem  = 727 , -- (355580) Summons a totem with $s2% of your health at the target location for $d that forms a circuit of electricity that enemies cannot pass through.
    totem_of_wrath      = 3488, -- (460697) Primordial Wave summons a totem at your feet for $204330d that increases the critical effect of damage and healing spells of all nearby allies within $<radius> yards by $208963s1% for $208963d.; 
    unleash_shield      = 3491, -- (356736) Unleash your Elemental Shield's energy on an enemy target:; $@spellicon192106$@spellname192106: Knocks them away.; $@spellicon974$@spellname974: Roots them in place for $356738d.; $@spellicon52127$@spellname52127: Summons a whirlpool for $356739d, reducing damage and healing by $356824s1% while they stand within it.
    volcanic_surge      = 5571, -- (408572) Increases the damage of Lightning Bolt and Chain Lightning by $s1% and the damage of Lava Burst by $s4%.; Lava Surge has an additional $s2% chance to trigger and instead reduces the cast time of your next Lightning Bolt or Chain Lightning by $408575s1%, stacking up to $408575U times.
} )

-- Auras
spec:RegisterAuras( {
    -- A percentage of healing and single target damage dealt is copied as healing to up to $s4 nearby injured party or raid members.
    ancestral_guidance = {
        id = 108281,
        duration = 10.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- restoration_shaman[137039] #29: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.
    ancestral_swiftness = {
        id = 443454,
        duration = 3600,
        max_stack = 1,
    },
    -- Your next $s3 Chain Lightning spells are instant cast and will deal $s2% increased damage.
    arc_discharge = {
        id = 455097,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    arctic_snowstorm = {
        id = 462765,
        duration = 8.0,
        max_stack = 1,
    },
    -- Transformed into a powerful Air ascendant. Auto attacks have a $114089r yard range. Stormstrike is empowered and has a $114089r yard range.$?s384411[; Generating $384411s1 $lstack:stacks; of Maelstrom Weapon every $384437t1 sec.][]
    ascendance = {
        id = 114051,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- first_ascendant[462440] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- preeminence[462443] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- preeminence[462443] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Damage taken reduced by $w1%.
    astral_shift = {
        id = 108271,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- astral_bulwark[377933] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- planes_traveler[381647] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Haste increased by $w1%.
    bloodlust = {
        id = 204361,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- shamanism[193876] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 8, 'target': TARGET_UNIT_CASTER, }
    },
    -- Reincarnation is cooling down $s1% faster.
    brimming_with_life = {
        id = 381684,
        duration = 3600,
        max_stack = 1,
    },
    -- Burrowed underground. ; Cannot be attacked.
    burrow = {
        id = 409293,
        duration = 5.0,
        max_stack = 1,
    },
    -- When you deal damage, $w1% is dealt to your lowest health ally within $204331m2 yards.
    counterstrike_totem = {
        id = 208997,
        duration = 15.0,
        max_stack = 1,
    },
    -- Stormstrike, Ice Strike, and Lava Lash deal an additional $195592s1 damage to all targets in front of you.
    crash_lightning = {
        id = 187878,
        duration = 12.0,
        max_stack = 1,
    },
    -- Maximum health increased by $w3%.
    downpour = {
        id = 207778,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?$w3!=0[Damage taken reduced by $w3%.; ][]Heals for ${$w2*(1+$w1/100)} upon taking damage.
    earth_shield = {
        id = 974,
        duration = 600.0,
        max_stack = 1,

        -- Affected by:
        -- earthen_communion[443441] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- earthen_communion[443441] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': ADDITIONAL_CHARGES, }
    },
    -- Rooted.
    earth_unleashed = {
        id = 356738,
        duration = 2.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    earthbind = {
        id = 3600,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Rooted.
    earthgrab = {
        id = 64695,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    echoing_shock = {
        id = 320125,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $w1 Nature damage every $t1 sec.
    electrocute = {
        id = 206647,
        duration = 3.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Critical Strike increased by $s1%.
    elemental_blast_critical_strike = {
        id = 118522,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- elemental_shaman[137040] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Damage of your next Frost spell increased by $w1%.
    elemental_equilibrium = {
        id = 378272,
        duration = 10.0,
        max_stack = 1,
    },
    -- Fire, Frost, and Nature damage taken reduced by $w1%.
    elemental_resistance = {
        id = 462568,
        duration = 3.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    enfeeblement = {
        id = 378080,
        duration = 6.0,
        max_stack = 1,
    },
    -- Cannot benefit from Heroism or other similar effects.
    exhaustion = {
        id = 57723,
        duration = 600.0,
        max_stack = 1,
    },
    -- Cannot move while using Far Sight.
    far_sight = {
        id = 6196,
        duration = 60.0,
        max_stack = 1,
    },
    -- Flame Shock deals damage $s2% faster. $?$w3!>0[Newly applied Flame Shocks have $w3% increased duration.][]
    fire_elemental = {
        id = 188592,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- everlasting_elements[462867] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Suffering $w2 Volcanic damage every $t2 sec.
    flame_shock = {
        id = 188389,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- elemental_shaman[137040] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- flames_of_the_cauldron[378266] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- flames_of_the_cauldron[378266] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- skybreakers_fiery_demise[378310] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- restoration_shaman[137039] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_elemental[188592] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.52, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- fire_elemental[188592] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lashing_flames[334168] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Each of your weapon attacks causes up to ${$max(($<coeff>*$AP),1)} additional Fire damage.
    flametongue_weapon = {
        id = 319778,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- enhanced_imbues[462796] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhanced_imbues[462796] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Your next Lava Burst will deal $s1% increased damage.
    flux_melting = {
        id = 381777,
        duration = 12.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.
    frost_shock = {
        id = 196840,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- elemental_shaman[137040] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 27.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- encasing_cold[462762] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- encasing_cold[462762] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Your next Earth Shock $?s117014[or Elemental Blast ][]will deal an additional ${$s1*$260113s1} Nature damage to the target.; Your next Earthquake's cast time is reduced by ${$min(-$s2,100)}%, and your next Earthquake's damage is increased by $s3%.
    fulmination = {
        id = 260111,
        duration = 30.0,
        max_stack = 1,
    },
    -- After casting a damaging Fire$?a462841[ and a Nature][] spell, you additionally cast an Elemental Blast at your target.
    fusion_of_elements = {
        id = 462843,
        duration = 20.0,
        max_stack = 1,
    },
    -- Increases movement speed by $?s382215[${$382216s1+$w2}][$w2]%.$?$w3!=0[; Less hindered by effects that reduce movement speed.][]
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Will redirect harmful spells to the Grounding Totem.
    grounding_totem = {
        id = 8178,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Haste increased by $w1%.
    heroism = {
        id = 32182,
        duration = 40.0,
        max_stack = 1,

        -- Affected by:
        -- shamanism[193876] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 8, 'target': TARGET_UNIT_CASTER, }
    },
    -- Incapacitated.
    hex = {
        id = 51514,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Damage taken from the Shaman's Flame Shock increased by $s1%.
    lashing_flames = {
        id = 334168,
        duration = 20.0,
        max_stack = 1,
    },
    -- Stunned. Suffering $w1 Nature damage every $t1 sec.
    lightning_lasso = {
        id = 305485,
        duration = 5.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- natures_fury[381655] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Casting Shaman's Lightning Bolt and Chain Lightning also deal $210689s2% of their damage to the Lightning Rod.
    lightning_rod = {
        id = 197209,
        duration = 8.0,
        max_stack = 1,
    },
    -- Chance to deal $192109s1 Nature damage when you take melee damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].
    lightning_shield = {
        id = 192106,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Increases the damage of your next $?s117014[Elemental Blast][Earth Shock] or Earthquake by ${$W1}.1%.
    magma_chamber = {
        id = 381933,
        duration = 21.0,
        max_stack = 1,
    },
    -- Your next Nature, Physical, or Frost spell will deal $s1% increased damage or healing.
    master_of_the_elements = {
        id = 260734,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- master_of_the_elements[16166] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'modifies': EFFECT_1_VALUE, }
    },
    -- Dealing $w1% less damage to $@auracaster.
    natures_protection = {
        id = 454029,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        max_stack = 1,
    },
    -- Cleansing all Poison effects from a nearby party or raid member within $a yards every $t1 sec.
    poison_cleansing = {
        id = 403922,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- elemental_shaman[137040] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- restoration_shaman[137039] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_fury[343190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Lightning Bolt and Chain Lightning will trigger Elemental Overload an additional time.
    power_of_the_maelstrom = {
        id = 191877,
        duration = 20.0,
        max_stack = 1,
    },
    -- Cannot benefit from Bloodlust or other similar effects.
    sated = {
        id = 57724,
        duration = 600.0,
        max_stack = 1,
    },
    -- Frost damage taken decreased by $w1%.
    seasoned_winds = {
        id = 355634,
        duration = 18.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    shocking_grasp = {
        id = 454025,
        duration = 3.0,
        max_stack = 1,
    },
    -- Mastery increased by $w1% and auto attacks have a $h% chance to instantly strike again.
    skyfury = {
        id = 462854,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Increases movement speed by $s1%.
    spirit_walk = {
        id = 58875,
        duration = 8.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%; Damage taken reduced by $s2%.
    spirit_wolf = {
        id = 260881,
        duration = 3600,
        max_stack = 1,
    },
    -- Immune to Silence and Interrupt effects.
    spiritwalkers_aegis = {
        id = 378078,
        duration = 5.0,
        max_stack = 1,
    },
    -- Able to move while casting all Shaman spells.
    spiritwalkers_grace = {
        id = 79206,
        duration = 15.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- graceful_spirit[192088] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- graceful_spirit[192088] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Stunned.
    static_charge = {
        id = 118905,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Absorbing up to $w1 damage.
    stone_bulwark = {
        id = 114893,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Reduces the cast time of your next Lightning Bolt$?s454009[, Tempest,][] or Chain Lightning by $s1%.
    storm_frenzy = {
        id = 462725,
        duration = 12.0,
        max_stack = 1,
    },
    -- Your next Lightning Bolt will deal $s2% increased damage, and your next Lightning Bolt or Chain Lightning will be instant cast and cause an Elemental Overload to trigger on every target hit.
    stormkeeper = {
        id = 191634,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- stormkeeper[392714] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your next spell cast will be enhanced.
    surge_of_power = {
        id = 285514,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Chain Heal or Healing Surge will be instant and consume no mana.
    surging_currents = {
        id = 454376,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    thunderous_paws = {
        id = 338036,
        duration = 3.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s3%.
    thunderstorm = {
        id = 204408,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- thundershock[378779] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- The cast time of your next Chain Heal reduced by $w1% and its jump distance is increased by $w2%.
    tidebringer = {
        id = 236502,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Healing and spell critical effect increased by $w1%.
    totem_of_wrath = {
        id = 208963,
        duration = 15.0,
        max_stack = 1,
    },
    -- Haste increased by $s1%.
    unlimited_power = {
        id = 454394,
        duration = 15.0,
        max_stack = 1,
    },
    -- The cast time of Lightning Bolt and Chain Lightning is reduced by $w1%.
    volcanic_surge = {
        id = 408575,
        duration = 18.0,
        max_stack = 1,

        -- Affected by:
        -- restoration_shaman[137039] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Allows walking over water.
    water_walking = {
        id = 546,
        duration = 600.0,
        max_stack = 1,
    },
    -- Reduces the cast time of Lightning Bolt and Chain Lightning by $s1%.
    wind_gust = {
        id = 263806,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    wind_rush = {
        id = 192082,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- ascending_air[462791] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- jet_stream[462817] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- For the next $d, $s1% of your healing done and $s2% of your damage done is converted to healing on up to $s4 nearby injured party or raid members, up to ${$MHP*$s3/100} healing to each target per second.
    ancestral_guidance = {
        id = 108281,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "ancestral_guidance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 3.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- restoration_shaman[137039] #29: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Returns the spirit to the body, restoring a dead target to life with $s1% of maximum health and mana. Cannot be cast when in combat.
    ancestral_spirit = {
        id = 2008,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.; If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side.
    ancestral_swiftness = {
        id = 443454,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        talent = "ancestral_swiftness",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Transform into a Flame Ascendant for $d, replacing Chain Lightning with Lava Beam, removing the cooldown on Lava Burst, and increasing the damage of Lava Burst by an amount equal to your critical strike chance.; When you transform into the Flame Ascendant, instantly cast a Lava Burst at all enemies affected by your Flame Shock, and refresh your Flame Shock durations to $188389d.
    ascendance = {
        id = 114050,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "ascendance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 59346, 'schools': ['holy', 'frost', 'arcane'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 114074, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MOD, 'points': -8000.0, 'value': 1536, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- first_ascendant[462440] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- preeminence[462443] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- preeminence[462443] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },

    -- Transform into an Air Ascendant for $114051d, immediately dealing $344548s1 Nature damage to any enemy within $344548A1 yds, reducing the cooldown and cost of Stormstrike by $s4%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a $114089r yd range.$?s384411[; While Ascendance is active, generate $s1 Maelstrom Weapon $lstack:stacks; every $384437t1 sec.][]
    ascendance_114051 = {
        id = 114051,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 59347, 'schools': ['physical', 'holy', 'frost', 'arcane'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_AUTOATTACK_WITH_RANGED_SPELL, 'trigger_spell': 114089, 'triggers': windlash, 'value': 114093, 'schools': ['physical', 'fire', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 115356, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #5: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 344548, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- first_ascendant[462440] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- preeminence[462443] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- preeminence[462443] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        from = "from_description",
    },

    -- Yanks you through the twisting nether back to $z. Speak to an Innkeeper in a different place to change your home location.
    astral_recall = {
        id = 556,
        cast = 10.0,
        cooldown = 600.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TELEPORT_UNITS, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_HOME, }

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Shift partially into the elemental planes, taking $s1% less damage for $d.
    astral_shift = {
        id = 108271,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "astral_shift",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -40.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- astral_bulwark[377933] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- planes_traveler[381647] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Increases haste by $s1% for all party and raid members for $d.; Allies receiving this effect will become Sated and unable to benefit from Bloodlust or Time Warp again for $57724d.
    bloodlust = {
        id = 2825,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        spend = 0.004,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'sp_bonus': 0.25, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- shamanism[193876] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 8, 'target': TARGET_UNIT_CASTER, }
    },

    -- Increases haste by $s1% to you and your target for $d.
    bloodlust_204361 = {
        id = 204361,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        spend = 0.004,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'sp_bonus': 0.25, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'target2': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ALLY, 'target2': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- shamanism[193876] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 8, 'target': TARGET_UNIT_CASTER, }
        from = "from_description",
    },

    -- Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by ${$s3-100}% for $d.; When the effect ends, enemies within $409304A1 yards are knocked in the air and take $<damage> Physical damage.
    burrow = {
        id = 409293,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': INTERFERE_TARGETTING, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': KEYBOUND_OVERRIDE, 'value': 244, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 150.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 10.5, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_HIT_CHANCE, 'sp_bonus': 0.25, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_RANGED_HIT_CHANCE, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 7, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 11, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 13, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MOD_FLYING_RESTRICTIONS, 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_SPELL_HIT_CHANCE, 'points': -200.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    capacitor_totem = {
        id = 192058,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "capacitor_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 2.0, 'value': 61245, 'schools': ['physical', 'fire', 'nature', 'frost', 'shadow'], 'value1': 3407, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Heals the friendly target for $s1, then jumps up to $?a236502[${$s3*(($236502s2/100)+1)}][$s3] yards to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_heal = {
        id = 1064,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.15,
        spendType = 'mana',

        -- 0. [137039] restoration_shaman
        -- spend = 0.056,
        -- spendType = 'mana',

        -- 1. [137040] elemental_shaman
        -- spend = 0.150,
        -- spendType = 'mana',

        -- 2. [137041] enhancement_shaman
        -- spend = 0.150,
        -- spendType = 'mana',

        talent = "chain_heal",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 2.31, 'chain_amp': 0.7, 'chain_targets': 4, 'pvp_multiplier': 1.2, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_CHAINHEAL_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- elemental_shaman[137040] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- natures_swiftness[378081] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- ancestral_swiftness[443454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surging_currents[454376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surging_currents[454376] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- surging_currents[454376] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- surging_currents[454376] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidebringer[236502] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- tidebringer[236502] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_DISTANCE, }
        -- elemental_fury[343190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- Hurls a lightning bolt at the enemy, dealing $s1 Nature damage and then jumping to additional nearby enemies. Affects $x1 total targets.$?s187874[; If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by $333964s1%.][]$?s187874[; Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by ${$s3/1000}.1 sec.][]$?a343725[; Generates $343725s5 Maelstrom per target hit.][]
    chain_lightning = {
        id = 188443,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        talent = "chain_lightning",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.635, 'chain_targets': 3, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- elemental_shaman[137040] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- elemental_shaman[137040] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 67.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ascendance[114050] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 114074, 'target': TARGET_UNIT_CASTER, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- flash_of_lightning[381936] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- stormkeeper[191634] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- unrelenting_calamity[382685] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -250.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- voltaic_surge[454919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- volcanic_surge[408572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surge_of_power[285514] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- restoration_shaman[137039] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 235.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arc_discharge[455097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- arc_discharge[455097] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_frenzy[462725] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- volcanic_surge[408575] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- wind_gust[263806] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- wind_gust[263806] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- Removes all Curse effects from a friendly target.
    cleanse_spirit = {
        id = 51886,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        talent = "cleanse_spirit",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker. 
    counterstrike_totem = {
        id = 204331,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 50.0, 'value': 105451, 'schools': ['physical', 'holy', 'nature', 'shadow', 'arcane'], 'value1': 3804, 'target': TARGET_DEST_CASTER_FRONT_LEFT, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 20.0, }
        -- #2: { 'type': UNKNOWN, 'subtype': NONE, 'points': 100.0, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.; While this elemental is active, your maximum health is increased by $381755s1%.
    earth_elemental = {
        id = 198103,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        talent = "earth_elemental",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- everlasting_elements[462867] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $u charges.; $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earth_shield = {
        id = 974,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        spend = 0.050,
        spendType = 'mana',

        spend = 0.050,
        spendType = 'mana',

        talent = "earth_shield",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'attributes': ['Suppress Points Stacking'], 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- earthen_communion[443441] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- earthen_communion[443441] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': ADDITIONAL_CHARGES, }
    },

    -- Instantly shocks the target with concussive force, causing $s1 Nature damage.$?a190493[; Earth Shock will consume all stacks of Fulmination to deal extra Nature damage to your target.][]
    earth_shock = {
        id = 8042,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 60,
        spendType = 'maelstrom',

        talent = "earth_shock",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.8343, 'pvp_multiplier': 0.89, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_elemental_overload[168534] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_elemental_overload[168534] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- eye_of_the_storm[381708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- maelstrom_supremacy[443447] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- swelling_maelstrom[381707] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [356736] Unleash your Elemental Shield's energy on an enemy target:; $@spellicon192106$@spellname192106: Knocks them away.; $@spellicon974$@spellname974: Roots them in place for $356738d.; $@spellicon52127$@spellname52127: Summons a whirlpool for $356739d, reducing damage and healing by $356824s1% while they stand within it.
    earth_unleashed = {
        id = 356738,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'mechanic': rooted, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons a totem at the target location for $d that slows the movement speed of enemies within $3600A1 yards by $3600s1%.
    earthbind_totem = {
        id = 2484,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 2.0, 'value': 2630, 'schools': ['holy', 'fire', 'arcane'], 'value1': 3400, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    earthgrab_totem = {
        id = 51485,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "earthgrab_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 2.0, 'value': 60561, 'schools': ['physical', 'frost'], 'value1': 3404, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Causes the earth within $a1 yards of your target to tremble and break, dealing $<damage> Physical damage over $d and has a $77478s2% chance to knock the enemy down. Multiple uses of Earthquake may overlap.; This spell is cast at your target.
    earthquake = {
        id = 462620,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 60,
        spendType = 'maelstrom',

        talent = "earthquake",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 3691, 'schools': ['physical', 'holy', 'nature', 'shadow', 'arcane'], 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- eye_of_the_storm[381708] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- maelstrom_supremacy[443447] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- swelling_maelstrom[381707] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unrelenting_calamity[382685] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- voltaic_surge[454919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fulmination[260111] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Causes the earth within $a1 yards of the target location to tremble and break, dealing $<damage> Physical damage over $d and has a $77478s2% chance to knock the enemy down. Multiple uses of Earthquake may overlap.; This spell is cast at a selected location.
    earthquake_61882 = {
        id = 61882,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 60,
        spendType = 'maelstrom',

        talent = "earthquake_61882",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 3691, 'schools': ['physical', 'holy', 'nature', 'shadow', 'arcane'], 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- eye_of_the_storm[381708] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- maelstrom_supremacy[443447] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- swelling_maelstrom[381707] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unrelenting_calamity[382685] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- voltaic_surge[454919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fulmination[260111] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        from = "spec_talent",
    },

    -- Shock the target for $s1 Elemental damage and create an ancestral echo, causing your next damage or healing spell to be cast a second time ${$s2/1000}.1 sec later for free.
    echoing_shock = {
        id = 320125,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.033,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.65, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[; If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_blast = {
        id = 117014,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        spend = 90,
        spendType = 'maelstrom',

        talent = "elemental_blast",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.75, 'pvp_multiplier': 0.85, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_elemental_overload[168534] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_elemental_overload[168534] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 164.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- eye_of_the_storm[381708] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- maelstrom_supremacy[443447] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- swelling_maelstrom[381707] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [328923] Transfer the life force of up to $328928I enemies in the targeted area, dealing ${($328928s1*$d/$t2) + $328928s1} Nature damage evenly split to each enemy target over $d. $?a137041[; Fully channeling Fae Transfusion generates $s4 $Lstack:stacks; of Maelstrom Weapon.][]; Pressing Fae Transfusion again within $328933d will release $s1% of all damage from Fae Transfusion, healing up to $328930s2 allies within $328930A1 yds.
    fae_transfusion = {
        id = 328930,
        color = 'night_fae',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'radius': 20.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Changes your viewpoint to the targeted location for $d.
    far_sight = {
        id = 6196,
        cast = 60.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': ADD_FARSIGHT, 'subtype': NONE, 'radius': 100.0, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Calls forth a Greater Fire Elemental to rain destruction on your enemies for $188592d. ; While the Fire Elemental is active, Flame Shock deals damage ; ${100*(1/(1+$188592s2/100)-1)}% faster, and newly applied Flame Shocks last $188592s3% longer.
    fire_elemental = {
        id = 198067,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "fire_elemental",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- everlasting_elements[462867] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- [198067] Calls forth a Greater Fire Elemental to rain destruction on your enemies for $188592d. ; While the Fire Elemental is active, Flame Shock deals damage ; ${100*(1/(1+$188592s2/100)-1)}% faster, and newly applied Flame Shocks last $188592s3% longer.
    fire_elemental_188592 = {
        id = 188592,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 95061, 'schools': ['physical', 'fire', 'frost', 'arcane'], 'value1': 3213, 'radius': 5.0, 'target': TARGET_DEST_CASTER_LEFT, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.52, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }

        -- Affected by:
        -- everlasting_elements[462867] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        from = "from_description",
    },

    -- Sears the target with fire, causing $s1 Volcanic damage and then an additional $o2 Volcanic damage over $d.; Flame Shock can be applied to a maximum of $I targets.$?a137039[][; If Flame Shock is dispelled, a volcanic eruption wells up beneath the dispeller, exploding for $204395s1 Volcanic damage and knocking them into the air.]
    flame_shock = {
        id = 188389,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 0.003,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.195, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.116, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- elemental_shaman[137040] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- flames_of_the_cauldron[378266] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- flames_of_the_cauldron[378266] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- skybreakers_fiery_demise[378310] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- restoration_shaman[137039] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_elemental[188592] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.52, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- fire_elemental[188592] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lashing_flames[334168] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Imbue your $?s33757[off-hand ][]weapon with the element of Fire for $319778d, causing each of your attacks to deal ${$max(($<coeff>*$AP),1)} additional Fire damage$?s382027[ and increasing the damage of your Fire spells by $382028s1%][]. 
    flametongue_weapon = {
        id = 318038,
        color = 'weapon_imbue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- enhanced_imbues[462796] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhanced_imbues[462796] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    frost_shock = {
        id = 196840,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        talent = "frost_shock",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.63, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- elemental_shaman[137040] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 27.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- encasing_cold[462762] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- encasing_cold[462762] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Turn into a Ghost Wolf, increasing movement speed by $?s382215[${$s2+$382216s1}][$s2]% and preventing movement speed from being reduced below $s3%.
    ghost_wolf = {
        id = 2645,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'amplitude': 1.0, 'target': TARGET_UNIT_CASTER, 'form': ghost_wolf, 'creature_type': beast, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'amplitude': 1.0, 'target': TARGET_UNIT_CASTER, 'form': ghost_wolf, 'creature_type': beast, }

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Purges the enemy target, removing $m1 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0.0,
        cooldown = 12.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        spend = 0.210,
        spendType = 'mana',

        spend = 0.210,
        spendType = 'mana',

        talent = "greater_purge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 2.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a totem at your feet that will redirect all harmful spells cast within $8178A1 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts $d.
    grounding_totem = {
        id = 204336,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 50.0, 'value': 5925, 'schools': ['physical', 'fire', 'shadow'], 'value1': 3406, 'target': TARGET_DEST_CASTER_BACK_LEFT, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- A gust of wind hurls you forward.
    gust_of_wind = {
        id = 192063,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        talent = "gust_of_wind",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': LEAP_BACK, 'subtype': NONE, 'points': 100.0, 'value': 200, 'schools': ['nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.; If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.05,
        spendType = 'mana',

        -- 0. [137039] restoration_shaman
        -- spend = 0.018,
        -- spendType = 'mana',

        -- 1. [137040] elemental_shaman
        -- spend = 0.050,
        -- spendType = 'mana',

        -- 2. [137041] enhancement_shaman
        -- spend = 0.050,
        -- spendType = 'mana',

        talent = "healing_stream_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 3527, 'schools': ['physical', 'holy', 'fire', 'arcane'], 'value1': 3402, 'target': TARGET_DEST_CASTER_BACK_RIGHT, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [137039] restoration_shaman
        -- spend = 0.044,
        -- spendType = 'mana',

        -- 1. [137040] elemental_shaman
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 2. [137041] enhancement_shaman
        -- spend = 0.080,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 4.896, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- elemental_shaman[137040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- natures_swiftness[378081] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- refreshing_waters[378211] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- ancestral_swiftness[443454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surging_currents[454376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surging_currents[454376] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- surging_currents[454376] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- surging_currents[454376] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_fury[343190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- Increases haste by $s1% for all party and raid members for $d.; Allies receiving this effect will become Exhausted and unable to benefit from Heroism or Time Warp again for $57723d.
    heroism = {
        id = 32182,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        spend = 0.004,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'sp_bonus': 0.25, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- shamanism[193876] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 8, 'target': TARGET_UNIT_CASTER, }
    },

    -- Transforms the enemy into a compy for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex = {
        id = 210873,
        color = 'compy',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 106397, 'schools': ['physical', 'fire', 'nature', 'frost'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Transforms the enemy into a spider for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_211004 = {
        id = 211004,
        color = 'spider',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 106469, 'schools': ['physical', 'fire', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a snake for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_211010 = {
        id = 211010,
        color = 'snake',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 106470, 'schools': ['holy', 'fire', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a cockroach for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_211015 = {
        id = 211015,
        color = 'cockroach',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 106471, 'schools': ['physical', 'holy', 'fire', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a skeletal hatchling for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_269352 = {
        id = 269352,
        color = 'skeletal_hatchling',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 137120, 'schools': ['shadow'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a Zandalari Tendonripper for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_277778 = {
        id = 277778,
        color = 'zandalari_tendonripper',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 134871, 'schools': ['physical', 'holy', 'fire', 'frost', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a wicker mongrel for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_277784 = {
        id = 277784,
        color = 'wicker_mongrel',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 142224, 'schools': ['frost'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a living honey for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_309328 = {
        id = 309328,
        color = 'living_honey',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 158593, 'schools': ['physical'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class",
    },

    -- Transforms the enemy into a frog for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex_51514 = {
        id = 51514,
        color = 'frog',
        cast = 1.7,
        cooldown = 30.0,
        gcd = "global",

        talent = "hex_51514",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 70495, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 754, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 7, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- voodoo_mastery[204268] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "class_talent",
    },

    -- Unleashes a blast of superheated flame at the enemy, dealing $s1 Fire damage and then jumping to additional nearby enemies. Damage is increased by $s2% after each jump. Affects $x1 total targets.  ; Generates $343725s5 Maelstrom per target hit. 
    lava_beam = {
        id = 114074,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.762, 'chain_amp': 1.1, 'chain_targets': 3, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_elemental_overload[168534] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_elemental_overload[168534] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- elemental_shaman[137040] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 67.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- stormkeeper[191634] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- unrelenting_calamity[382685] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -250.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- volcanic_surge[408572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surge_of_power[285514] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arc_discharge[455097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- arc_discharge[455097] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[; Generates $343725s3 Maelstrom.][]
    lava_burst = {
        id = 51505,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "lava_burst",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 285452, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': maelstrom, }

        -- Affected by:
        -- mastery_elemental_overload[168534] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_elemental_overload[168534] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 29.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- maelstrom[343725] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- echo_of_the_elements[333919] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- elemental_reverb[443418] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- elemental_reverb[443418] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- volcanic_surge[408572] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 45.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flux_melting[381777] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 128.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Charges your off-hand weapon with lava and burns your target, dealing $s1 Fire damage.; Damage is increased by $s2% if your offhand weapon is imbued with Flametongue Weapon. $?s334033[Lava Lash will spread Flame Shock from your target to $s3 nearby targets.][]$?s334046[; Lava Lash increases the damage of Flame Shock on its target by $334168s1% for $334168d.][]
    lava_lash = {
        id = 60103,
        cast = 0.0,
        cooldown = 18.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.308, 'pvp_multiplier': 1.25, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_elemental_overload[168534] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_elemental_overload[168534] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_elemental[188592] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_elemental[188592] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[; Generates $343725s1 Maelstrom.][]
    lightning_bolt = {
        id = 188196,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.14, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- elemental_shaman[137040] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 57.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lightning_bolt[318044] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- flash_of_lightning[381936] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- stormkeeper[191634] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- stormkeeper[191634] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.2, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unrelenting_calamity[382685] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -250.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- volcanic_surge[408572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.75, 'points': 145.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_frenzy[462725] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- volcanic_surge[408575] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- wind_gust[263806] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- wind_gust[263806] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    lightning_lasso = {
        id = 305483,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "lightning_lasso",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- $?s454009[Tempest, ][]$?s137040[Earth Shock, Elemental Blast, and Earthquake][Lightning Bolt, Elemental Blast, and Chain Lightning] make your target a Lightning Rod for $197209d. Lightning Rods take $s2% of all damage you deal with Lightning Bolt and Chain Lightning.
    lightning_rod = {
        id = 210689,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "lightning_rod",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Surround yourself with a shield of lightning for $d.; Melee attackers have a $h% chance to suffer $192109s1 Nature damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].; $?s383010[The Shaman can have up to two Elemental Shields active on them.][Only one Elemental Shield can be active on the Shaman at a time.]
    lightning_shield = {
        id = 192106,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.003,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'trigger_spell': 192109, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Suppress Points Stacking'], 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'attributes': ['Suppress Points Stacking'], 'points': 5.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- Summons a totem at the target location that erupts dealing $383061s1 Fire damage and applying Flame Shock to $383061s2 enemies within $383061A1 yards. Continues hurling liquid magma at a random nearby target every $192226t1 sec for $d, dealing ${$192231s1*(1+($137040s3/100))} Fire damage to all enemies within $192223A1 yards.; 
    liquid_magma_totem = {
        id = 192222,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.007,
        spendType = 'mana',

        talent = "liquid_magma_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 2.0, 'value': 97369, 'schools': ['physical', 'nature', 'frost', 'arcane'], 'value1': 3697, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 395349, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "natures_swiftness",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within $403922a yards every $383014t1 sec for $d.
    poison_cleansing_totem = {
        id = 383013,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "poison_cleansing_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 5923, 'schools': ['physical', 'holy', 'shadow'], 'value1': 5428, 'target': TARGET_DEST_CASTER_FRONT_LEFT, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- An instant weapon strike that causes $s1 Physical damage.
    primal_strike = {
        id = 73899,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.019,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.34, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Blast your target with a Primordial Wave, dealing $375984s1 Elemental damage and applying Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave = {
        id = 375982,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "primordial_wave",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 375983, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 0.42857, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- Purges the enemy target, removing $m1 beneficial Magic $leffect:effects;.$?(s147762&s51530); [ Successfully purging a target grants a stack of Maelstrom Weapon.][]
    purge = {
        id = 370,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        spend = 0.140,
        spendType = 'mana',

        spend = 0.140,
        spendType = 'mana',

        talent = "purge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Allows you to resurrect yourself upon death with $21169s1% health and mana. This effect can occur only once every $s2 minutes.
    reincarnation = {
        id = 20608,
        color = 'passive',
        cast = 0.0,
        cooldown = 1800.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, }

        -- Affected by:
        -- brimming_with_life[381684] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'points': 75.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [20608] Allows you to resurrect yourself upon death with $21169s1% health and mana. This effect can occur only once every $s2 minutes.
    reincarnation_21169 = {
        id = 21169,
        cast = 0.0,
        cooldown = 1800.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SELF_RESURRECT, 'subtype': NONE, 'points': 20.0, }

        -- Affected by:
        -- brimming_with_life[381684] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'points': 75.0, 'target': TARGET_UNIT_CASTER, }
        from = "from_description",
    },

    -- Harness the fury of the Windlord to grant a target ally $s1% Mastery and empower their auto attacks to have a $h% chance to instantly strike again for $d.; If the target is in your party or raid, all party and raid members will be affected.
    skyfury = {
        id = 462854,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MASTERY, 'points': 2.0, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ALLY_OR_RAID, }
    },

    -- Removes all movement impairing effects and increases your movement speed by $58875s1% for $58875d.
    spirit_walk = {
        id = 58875,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "spirit_walk",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 60.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 58876, 'target': TARGET_UNIT_CASTER, }
    },

    -- Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    spiritwalkers_grace = {
        id = 79206,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        spend = 0.028,
        spendType = 'mana',

        talent = "spiritwalkers_grace",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_BY_SPELL_LABEL, 'value': 640, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_BY_SPELL_LABEL, 'value': 888, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_BY_SPELL_LABEL, 'value': 981, 'schools': ['physical', 'fire', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_BY_SPELL_LABEL, 'value': 1089, 'schools': ['physical', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_BY_SPELL_LABEL, 'value': 726, 'schools': ['holy', 'fire', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- graceful_spirit[192088] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- graceful_spirit[192088] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Reduces the cooldown of Capacitor Totem by $s1 sec for each enemy it stuns, up to a maximum reduction of $s2 sec.
    static_charge = {
        id = 265046,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "static_charge",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a totem with $s2% of your health at the target location for $d that forms a circuit of electricity that enemies cannot pass through.
    static_field_totem = {
        id = 355580,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 7.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 4.0, 'value': 179867, 'schools': ['physical', 'holy', 'nature', 'frost'], 'value1': 4455, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summons a totem with ${$m1*$MHP/100} health at the feet of the caster for $d, granting the caster a shield absorbing $114893s1 damage for $114893d, and up to an additional $462844s1 every $114889t1 sec.
    stone_bulwark_totem = {
        id = 108270,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "stone_bulwark_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 59712, 'schools': ['arcane'], 'value1': 81, 'target': TARGET_DEST_CASTER_FRONT_RIGHT, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 10.0, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Calls forth a Greater Storm Elemental to hurl gusts of wind that damage the Shaman's enemies for $157299d.; While the Storm Elemental is active, each time you cast Lightning Bolt or Chain Lightning, the cast time of Lightning Bolt and Chain Lightning is reduced by $263806s1%, stacking up to $263806u times.
    storm_elemental = {
        id = 192249,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "storm_elemental",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- everlasting_elements[462867] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Raises The Fist of Ra-den to the sky and absorbs all nearby electric energy, causing your next $n casts of Lightning Bolt or Chain Lightning to be instant and deal $s1% increased damage.
    stormkeeper = {
        id = 205495,
        color = 'artifact',
        cast = 1.5,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Charge yourself with lightning, causing your next $n Lightning Bolts to deal $s2% more damage, and also causes your next $n Lightning Bolts or Chain Lightnings to be instant cast and trigger an Elemental Overload on every target.$?s137040[; If you already know $@spellname191634, instead gain $392714s1 additional $Lcharge:charges; of $@spellname191634.][]
    stormkeeper_191634 = {
        id = 191634,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        talent = "stormkeeper_191634",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.2, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- stormkeeper[392714] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        from = "spec_talent",
    },

    -- Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    thunderstorm = {
        id = 51490,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "thunderstorm",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.104485, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': KNOCK_BACK, 'subtype': NONE, 'points': 60.0, 'value': 300, 'schools': ['fire', 'nature', 'shadow'], 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -40.0, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #3: { 'type': KNOCK_BACK, 'subtype': NONE, 'points': 100.0, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- mastery_elemental_overload[168534] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_elemental_overload[168534] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.56, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- thundershock[378779] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- traveling_storms[204403] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 204406, 'target': TARGET_UNIT_CASTER, }
        -- elemental_fury[60188] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_elemental[157299] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_elemental[157299] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Calls down a bolt of lightning, dealing $204408s1 Nature damage to all enemies within $204408A1 yards of the target, reducing their movement speed by $204408s3% and knocking them $?s378779[upward][away from the Shaman]. This spell is usable while stunned.
    thunderstorm_204406 = {
        id = 204406,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- thundershock[378779] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        from = "from_description",
    },

    -- Imbue your shield with the element of Lightning for $d, giving Lightning Bolt and Chain Lightning a chance to call down $s1 Thunderstrikes on your target for $462763s1 Nature damage.
    thunderstrike_ward = {
        id = 462757,
        color = 'shield_imbue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "thunderstrike_ward",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Relocates your active totems to the specified location.
    totemic_projection = {
        id = 108287,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "none",

        talent = "totemic_projection",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'variance': 1.0, 'value': 47319, 'schools': ['physical', 'holy', 'fire', 'frost', 'arcane'], 'value1': 1881, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_DEST, }
    },

    -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_recall = {
        id = 108285,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "totemic_recall",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- call_of_the_elements[383011] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    tremor_totem = {
        id = 8143,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "tremor_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 5913, 'schools': ['physical', 'nature', 'frost'], 'value1': 3406, 'target': TARGET_DEST_CASTER_FRONT_LEFT, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Unleash your Elemental Shield's energy on an enemy target:; $@spellicon192106$@spellname192106: Knocks them away.; $@spellicon974$@spellname974: Roots them in place for $356738d.; $@spellicon52127$@spellname52127: Summons a whirlpool for $356739d, reducing damage and healing by $356824s1% while they stand within it.
    unleash_shield = {
        id = 356736,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Allows the friendly target to walk across water for $d. Damage will cancel the effect.
    water_walking = {
        id = 546,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Summons a totem at the target location for $d, continually granting all allies who pass within $a1 yards $192082s1% increased movement speed for $192082d.
    wind_rush_totem = {
        id = 192077,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "wind_rush_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 2.0, 'value': 97285, 'schools': ['physical', 'fire'], 'value1': 3695, 'radius': 10.0, 'target': TARGET_UNIT_DEST_AREA_ALLY, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- ascending_air[462791] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    wind_shear = {
        id = 57994,
        cast = 0.0,
        cooldown = 12.0,
        gcd = "none",

        talent = "wind_shear",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Hurl a staggering blast of wind at an enemy, dealing a total of ${$115357sw1+$115360sw1} Physical damage, bypassing armor.
    windstrike = {
        id = 115356,
        cast = 0.0,
        cooldown = 7.5,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 115357, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 115360, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- ascendance[114051] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ascendance[114051] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

} )