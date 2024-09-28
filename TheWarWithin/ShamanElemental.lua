-- ShamanElemental.lua
-- July 2024

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local strformat = string.format

local spec = Hekili:NewSpecialization( 262 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Shaman
    ancestral_guidance          = { 103810, 108281, 1 }, -- For the next 10 sec, 25% of your healing done and 25% of your damage done is converted to healing on up to 3 nearby injured party or raid members, up to 199,751 healing to each target per second.
    ancestral_wolf_affinity     = { 103610, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    arctic_snowstorm            = { 103619, 462764, 1 }, -- Enemies within 10 yds of your Frost Shock are snared by 30%.
    ascending_air               = { 103607, 462791, 1 }, -- Wind Rush Totem's cooldown is reduced by 30 sec and its movement speed effect lasts an additional 2 sec.
    astral_bulwark              = { 103611, 377933, 1 }, -- Astral Shift reduces damage taken by an additional 20%.
    astral_shift                = { 103616, 108271, 1 }, -- Shift partially into the elemental planes, taking 60% less damage for 12 sec.
    brimming_with_life          = { 103582, 381689, 1 }, -- Maximum health increased by 10%, and while you are at full health, Reincarnation cools down 75% faster.
    call_of_the_elements        = { 103592, 383011, 1 }, -- Reduces the cooldown of Totemic Recall by 60 sec.
    capacitor_totem             = { 103579, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after 2 sec, stunning all enemies within 9 yards for 3 sec.
    chain_heal                  = { 103588,   1064, 1 }, -- Heals the friendly target for 47,508, then jumps up to 15 yards to heal the 3 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_lightning             = { 103583, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing 28,925 Nature damage and then jumping to additional nearby enemies. Affects 5 total targets. Generates 2 Maelstrom per target hit.
    cleanse_spirit              = { 103608,  51886, 1 }, -- Removes all Curse effects from a friendly target.
    creation_core               = { 103592, 383012, 1 }, -- Totemic Recall affects an additional totem.
    earth_elemental             = { 103585, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for 1.2 min. While this elemental is active, your maximum health is increased by 15%.
    earth_shield                = { 103596,    974, 1 }, -- Protects the target with an earthen shield, increasing your healing on them by 20% and healing them for 30,297 when they take damage. This heal can only occur once every few seconds. Maximum 9 charges. Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.
    earthgrab_totem             = { 103617,  51485, 1 }, -- Summons a totem at the target location for 30 sec. The totem pulses every 2 sec, rooting all enemies within 9 yards for 8 sec. Enemies previously rooted by the totem instead suffer 50% movement speed reduction.
    elemental_orbit             = { 103602, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1. You can have Earth Shield on yourself and one ally at the same time.
    elemental_resistance        = { 103601, 462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by 6% for 3 sec.
    elemental_warding           = { 103597, 381650, 1 }, -- Reduces all magic damage taken by 6%.
    encasing_cold               = { 103619, 462762, 1 }, -- Frost Shock snares its targets by an additional 10% and its duration is increased by 2 sec.
    enhanced_imbues             = { 103606, 462796, 1 }, -- The effects of your weapon imbues are increased by 30%.
    fire_and_ice                = { 103605, 382886, 1 }, -- Increases all Fire and Frost damage you deal by 3%.
    frost_shock                 = { 103604, 196840, 1 }, -- Chills the target with frost, causing 23,923 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    graceful_spirit             = { 103626, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by 30 sec and increases your movement speed by 20% while it is active.
    greater_purge               = { 103624, 378773, 1 }, -- Purges the enemy target, removing 2 beneficial Magic effects.
    guardians_cudgel            = { 103618, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind                = { 103591, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem        = { 103590,   5394, 1 }, -- Summons a totem at your feet for 18 sec that heals an injured party or raid member within 46 yards for 11,135 every 1.6 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    hex                         = { 103623,  51514, 1 }, -- Transforms the enemy into a frog for 1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    jet_stream                  = { 103607, 462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by 10% and now removes snares.
    lava_burst                  = { 103598,  51505, 1 }, -- Hurls molten lava at the target, dealing 41,924 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock. Generates 10 Maelstrom.
    lightning_lasso             = { 103589, 305483, 1 }, -- Grips the target in lightning, stunning and dealing 124,386 Nature damage over 5 sec while the target is lassoed. Can move while channeling.
    mana_spring                 = { 103587, 381930, 1 }, -- Your Lava Burst casts restore 100 mana to you and 4 allies nearest to you within 40 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury                = { 103622, 381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by 4%.
    natures_guardian            = { 103613,  30884, 1 }, -- When your health is brought below 35%, you instantly heal for 27% of your maximum health. Cannot occur more than once every 45 sec.
    natures_swiftness           = { 103620, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    planes_traveler             = { 103611, 381647, 1 }, -- Reduces the cooldown of Astral Shift by 30 sec.
    poison_cleansing_totem      = { 103609, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within 34 yards every 1.5 sec for 9 sec.
    primordial_bond             = { 103612, 381764, 1 }, -- While you have an elemental active, your damage taken is reduced by 5%.
    purge                       = { 103624,    370, 1 }, -- Purges the enemy target, removing 1 beneficial Magic effect.
    refreshing_waters           = { 103594, 378211, 1 }, -- Your Healing Surge is 30% more effective on yourself.
    seasoned_winds              = { 103628, 355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by 15% for 18 sec. Stacks up to 2 times.
    spirit_walk                 = { 103591,  58875, 1 }, -- Removes all movement impairing effects and increases your movement speed by 60% for 8 sec.
    spirit_wolf                 = { 103581, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain 5% increased movement speed and 5% damage reduction every 1 sec, stacking up to 4 times.
    spiritwalkers_aegis         = { 103626, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for 5 sec.
    spiritwalkers_grace         = { 103584,  79206, 1 }, -- Calls upon the guidance of the spirits for 15 sec, permitting movement while casting Shaman spells. Castable while casting.
    static_charge               = { 103618, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by 5 sec for each enemy it stuns, up to a maximum reduction of 20 sec.
    stone_bulwark_totem         = { 103629, 108270, 1 }, -- Summons a totem with 49,937 health at the feet of the caster for 30 sec, granting the caster a shield absorbing 230,342 damage for 10 sec, and up to an additional 23,034 every 5 sec.
    thunderous_paws             = { 103581, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional 25% for the first 3 sec. May only occur once every 20 sec.
    thundershock                = { 103621, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by 5 sec.
    thunderstorm                = { 103603,  51490, 1 }, -- Calls down a bolt of lightning, dealing 3,275 Nature damage to all enemies within 10 yards, reducing their movement speed by 40% for 5 sec, and knocking them away from the Shaman. Usable while stunned.
    totemic_focus               = { 103625, 382201, 1 }, -- Increases the radius of your totem effects by 15%. Increases the duration of your Earthbind and Earthgrab Totems by 10 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, and Wind Rush Totems by 3.0 sec.
    totemic_projection          = { 103586, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall              = { 103595, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge               = { 103599, 381867, 1 }, -- Reduces the cooldown of your totems by 6 sec.
    traveling_storms            = { 103621, 204403, 1 }, -- Thunderstorm now can be cast on allies within 40 yards, reduces enemies movement speed by 60%, and knocks enemies 25% further.
    tremor_totem                = { 103593,   8143, 1 }, -- Summons a totem at your feet that shakes the ground around it for 13 sec, removing Fear, Charm and Sleep effects from party and raid members within 34 yards.
    voodoo_mastery              = { 103600, 204268, 1 }, -- Your Hex target is slowed by 70% during Hex and for 6 sec after it ends. Reduces the cooldown of Hex by 15 sec.
    wind_rush_totem             = { 103627, 192077, 1 }, -- Summons a totem at the target location for 18 sec, continually granting all allies who pass within 11 yards 40% increased movement speed for 5 sec.
    wind_shear                  = { 103615,  57994, 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for 2 sec.
    winds_of_alakir             = { 103614, 382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by 10%. When you have 3 or more totems active, your movement speed is increased by 15%.

    -- Elemental
    aftershock                  = {  81000, 273221, 1 }, -- Earth Shock, Elemental Blast, and Earthquake have a 25% chance to refund all Maelstrom spent.
    ascendance                  = {  81003, 114050, 1 }, -- Transform into a Flame Ascendant for 18 sec, replacing Chain Lightning with Lava Beam, removing the cooldown on Lava Burst, and increasing the damage of Lava Burst by an amount equal to your critical strike chance. When you transform into the Flame Ascendant, instantly cast a Lava Burst at all enemies affected by your Flame Shock, and refresh your Flame Shock durations to 18 sec.
    deeply_rooted_elements      = { 103641, 378270, 1 }, -- Casting Lava Burst has a 7% chance to activate Ascendance for 6.0 sec.  Ascendance Transform into a Flame Ascendant for 18 sec, replacing Chain Lightning with Lava Beam, removing the cooldown on Lava Burst, and increasing the damage of Lava Burst by an amount equal to your critical strike chance. When you transform into the Flame Ascendant, instantly cast a Lava Burst at all enemies affected by your Flame Shock, and refresh your Flame Shock durations to 18 sec.
    earth_shock                 = {  80984,   8042, 1 }, -- Instantly shocks the target with concussive force, causing 93,303 Nature damage.
    earthen_rage                = { 103634, 170374, 1 }, -- Your damaging spells incite the earth around you to come to your aid for 6 sec, repeatedly dealing 4,311 Nature damage to your most recently attacked target.
    earthquake                  = {  80985,  61882, 1 }, -- Causes the earth within 8 yards of the target location to tremble and break, dealing 51,148 Physical damage over 7 sec and has a 5% chance to knock the enemy down. Multiple uses of Earthquake may overlap. This spell is cast at a selected location.
    earthquake_2                = {  80985, 462620, 1 }, -- Causes the earth within 8 yards of your target to tremble and break, dealing 51,148 Physical damage over 7 sec and has a 5% chance to knock the enemy down. Multiple uses of Earthquake may overlap. This spell is cast at your target.
    echo_chamber                = {  81013, 382032, 1 }, -- Increases the damage dealt by your Elemental Overloads by 10%.
    echo_of_the_elementals      = {  81008, 462864, 1 }, -- When your Storm Elemental or Fire Elemental expires, it leaves behind a lesser Elemental to continue attacking your enemies for 15 sec.
    echo_of_the_elements        = {  80999, 333919, 1 }, -- Lava Burst has an additional charge.
    echoes_of_great_sundering   = {  80991, 384087, 1 }, -- After casting Earth Shock, your next Earthquake deals 120% additional damage. After casting Elemental Blast, your next Earthquake deals 140% additional damage.
    elemental_blast             = {  80984, 117014, 1 }, -- Harnesses the raw power of the elements, dealing 186,852 Elemental damage and increasing your Critical Strike or Haste by 6% or Mastery by 11% for 10 sec.
    elemental_equilibrium       = {  80993, 378271, 1 }, -- Dealing direct Fire, Frost, and Nature damage within 10 sec will increase all damage dealt by 10% for 10 sec. This can only occur once every 30 sec.
    elemental_fury              = {  80983,  60188, 1 }, -- Your damaging critical strikes deal 275% damage instead of the usual 200%.
    elemental_unity             = { 103630, 462866, 1 }, -- While a Storm Elemental is active, your Nature damage dealt is increased by 10%. While a Fire Elemental is active, your Fire damage dealt is increased by 10%.
    everlasting_elements        = { 103633, 462867, 1 }, -- Increases the duration of your Elementals by 20%.
    eye_of_the_storm            = {  80995, 381708, 1 }, -- Reduces the Maelstrom cost of Earth Shock and Earthquake by 5. Reduces the Maelstrom cost of Elemental Blast by 10.
    fire_elemental              = {  80981, 198067, 1 }, -- Calls forth a Greater Fire Elemental to rain destruction on your enemies for 36 sec. While the Fire Elemental is active, Flame Shock deals damage 33% faster, and newly applied Flame Shocks last 100% longer.
    first_ascendant             = {  81002, 462440, 1 }, -- The cooldown of Ascendance is reduced by 60 sec.
    flames_of_the_cauldron      = {  81010, 378266, 1 }, -- Reduces the cooldown of Flame Shock by 1.5 sec and Flame Shock deals damage 15% faster.
    flash_of_lightning          = {  80990, 381936, 1 }, -- Increases the critical strike chance of Lightning Bolt and Chain Lightning by 10%. Casting Lightning Bolt or Chain Lightning reduces the cooldown of your Nature spells by 1.0 sec.
    flow_of_power               = {  80998, 385923, 1 }, -- Increases the Maelstrom generated by Lightning Bolt and Lava Burst by 2.
    flux_melting                = {  80996, 381776, 1 }, -- Casting Frost Shock or Icefury increases the damage of your next Lava Burst by 20%.
    fury_of_the_storms          = { 103640, 191717, 1 }, -- Activating Stormkeeper summons a powerful Lightning Elemental to fight by your side for 9.6 sec.
    fusion_of_elements          = { 103638, 462840, 1 }, -- After casting Icefury, the next time you cast a Nature and a Fire spell, you additionally cast an Elemental Blast at your target at 60% effectiveness.
    icefury                     = {  80997, 462816, 1 }, -- Casting Lava Burst has a chance to replace your next Frost Shock with Icefury, stacking up to 2 times.  Icefury Hurls frigid ice at the target, dealing 48,842 Frost damage and causing your next 2 Frost Shocks to deal 225% increased damage and generate 10 Maelstrom. Generates 12 Maelstrom.
    improved_flametongue_weapon = {  81009, 382027, 1 }, -- Imbuing your weapon with Flametongue increases your Fire spell damage by 5% for 1 hour.
    lightning_conduit           = { 103631, 462862, 1 }, -- While Lightning Shield is active, your Nature damage dealt is increased by 8%.
    lightning_rod               = {  80992, 210689, 1 }, -- Earth Shock, Elemental Blast, and Earthquake make your target a Lightning Rod for 8 sec. Lightning Rods take 20% of all damage you deal with Lightning Bolt and Chain Lightning.
    liquid_magma_totem          = { 103637, 192222, 1 }, -- Summons a totem at the target location that erupts dealing 29,601 Fire damage and applying Flame Shock to 3 enemies within 9 yards. Continues hurling liquid magma at a random nearby target every 0.8 sec for 6 sec, dealing 17,420 Fire damage to all enemies within 9 yards.
    magma_chamber               = {  81007, 381932, 1 }, -- Flame Shock damage increases the damage of your next Earth Shock, Elemental Blast, or Earthquake by 1.5%, stacking up to 10 times.
    master_of_the_elements      = {  81004,  16166, 1 }, -- Casting Lava Burst increases the damage or healing of your next Nature, Physical, or Frost spell by 15%.
    mountains_will_fall         = {  81012, 381726, 1 }, -- Earth Shock, Elemental Blast, and Earthquake can trigger your Mastery: Elemental Overload at 50% effectiveness. Overloaded Earthquakes do not knock enemies down.
    power_of_the_maelstrom      = {  81015, 191861, 1 }, -- Casting Lava Burst has a 25% chance to cause your next Lightning Bolt or Chain Lightning cast to trigger Elemental Overload an additional time, stacking up to 2 times.
    preeminence                 = {  81002, 462443, 1 }, -- Your haste is increased by 25% while Ascendance is active and its duration is increased by 3 sec.
    primal_elementalist         = { 103632, 117013, 1 }, -- Your Earth, Fire, and Storm Elementals are drawn from primal elementals 80% more powerful than regular elementals, with additional abilities, and you gain direct control over them.
    primordial_fury             = { 103639, 378193, 1 }, -- Elemental Fury increases critical strike damage by an additional 25%.
    primordial_wave             = {  81014, 375982, 1 }, -- Blast your target with a Primordial Wave, dealing 11,550 Elemental damage and applying Flame Shock to them. Your next Lava Burst will also hit all targets affected by your Flame Shock for 80% of normal damage.
    searing_flames              = {  81005, 381782, 1 }, -- Flame Shock damage has a chance to generate 2 Maelstrom.
    skybreakers_fiery_demise    = {  81006, 378310, 1 }, -- Flame Shock damage over time critical strikes reduce the cooldown of your Fire and Storm Elemental by 1.0 sec, and Flame Shock has a 50% increased critical strike chance.
    splintered_elements         = {  80978, 382042, 1 }, -- Primordial Wave grants you 20% Haste plus 4% for each additional Lava Burst generated by Primordial Wave for 12 sec.
    storm_elemental             = {  80981, 192249, 1 }, -- Calls forth a Greater Storm Elemental to hurl gusts of wind that damage the Shaman's enemies for 36 sec. While the Storm Elemental is active, each time you cast Lightning Bolt or Chain Lightning, the cast time of Lightning Bolt and Chain Lightning is reduced by 3%, stacking up to 10 times.
    storm_frenzy                = { 103635, 462695, 1 }, -- Your next Chain Lightning or Lightning Bolt has 40% reduced cast time after casting Earth Shock, Elemental Blast, or Earthquake. Can accumulate up to 2 charges.
    stormkeeper                 = {  80989, 191634, 1 }, -- Charge yourself with lightning, causing your next 2 Lightning Bolts to deal 150% more damage, and also causes your next 2 Lightning Bolts or Chain Lightnings to be instant cast and trigger an Elemental Overload on every target. If you already know Stormkeeper, instead gain 1 additional charge of Stormkeeper.
    surge_of_power              = {  81000, 262303, 1 }, -- Earth Shock, Elemental Blast, and Earthquake enhance your next spell cast within 15 sec: Flame Shock: The next cast also applies Flame Shock to 1 additional target within 8 yards of the target. Lightning Bolt: Your next cast will cause 2 additional Elemental Overloads. Chain Lightning: Your next cast will chain to 1 additional target. Lava Burst: Reduces the cooldown of your Fire and Storm Elemental by 4.0 sec. Frost Shock: Freezes the target in place for 6 sec.
    swelling_maelstrom          = {  81016, 381707, 1 }, -- Increases your maximum Maelstrom by 50. Increases Earth Shock, Elemental Blast, and Earthquake damage by 5%.
    thunderstrike_ward          = { 103636, 462757, 1 }, -- Imbue your shield with the element of Lightning for 1 |4hour:hrs;, giving Lightning Bolt and Chain Lightning a chance to call down 2 Thunderstrikes on your target for 8,151 Nature damage.
    unrelenting_calamity        = {  80988, 382685, 1 }, -- Reduces the cast time of Lightning Bolt and Chain Lightning by 0.25 sec. Increases the duration of Earthquake by 1 sec.

    -- Farseer
    ancestral_swiftness         = {  94894, 443454, 1 }, -- Your next healing or damaging spell is instant, costs no mana, and deals 10% increased damage and healing. If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side.
    ancient_fellowship          = {  94862, 443423, 1 }, -- Ancestors have a 15% chance to call another Ancestor when they expire.
    call_of_the_ancestors       = {  94888, 443450, 1, "farseer" }, -- Primordial Wave calls an Ancestor to your side for 6 sec. Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell.
    earthen_communion           = {  94858, 443441, 1 }, -- Earth Shield has an additional 3 charges and heals you for 25% more.
    elemental_reverb            = {  94869, 443418, 1 }, -- Lava Burst gains an additional charge and deals 5% increased damage.
    final_calling               = {  94875, 443446, 1 }, -- When an Ancestor expires, they cast Elemental Blast at a nearby enemy.
    heed_my_call                = {  94884, 443444, 1 }, -- Ancestors last an additional 2 sec.
    latent_wisdom               = {  94862, 443449, 1 }, -- Your Ancestors' spells are 20% more powerful.
    maelstrom_supremacy         = {  94883, 443447, 1 }, -- Increases the damage of Earth Shock, Elemental Blast, and Earthquake by 8% and the healing of Healing Surge by 8%.
    natural_harmony             = {  94858, 443442, 1 }, -- Reduces the cooldown of Nature's Guardian by 10 sec and causes it to heal for an additional 5% of your maximum health.
    offering_from_beyond        = {  94887, 443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of Fire Elemental and Storm Elemental by 10 sec.
    primordial_capacity         = {  94860, 443448, 1 }, -- Increases your maximum Maelstrom by 25.
    routine_communication       = {  94884, 443445, 1 }, -- Lava Burst casts have a 8% chance to call an Ancestor.
    spiritwalkers_momentum      = {  94861, 443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by 1 sec, up to a maximum of 4 sec.

    -- Stormbringer
    arc_discharge               = {  94885, 455096, 1 }, -- When Tempest strikes more than one target, your next 3 Chain Lightning spells are instant cast and deal 75% increased damage.
    awakening_storms            = {  94867, 455129, 1 }, -- Lightning Bolt and Chain Lightning have a chance to strike your target for 8,884 Nature damage. Every 3 times this occurs, your next Lightning Bolt is replaced by Tempest.
    conductive_energy           = {  94868, 455123, 1 }, -- Lightning Rod targets now also take 20% of the damage that Tempest deals, and Tempest also applies Lightning Rod effect.
    natures_protection          = {  94880, 454027, 1 }, -- Targets struck by your Tempest deal 10% less damage to you for 6 sec.
    rolling_thunder             = {  94889, 454026, 1 }, -- Gain one stack of Stormkeeper every 50 sec.
    shocking_grasp              = {  94863, 454022, 1 }, -- Your Nature damage critical strikes reduce the target's movement speed by 50% for 3 sec.
    storm_swell                 = {  94885, 455088, 1 }, -- When Tempest only strikes a single target, gain 30 Maelstrom.
    stormcaller                 = {  94893, 454021, 1 }, -- Increases the critical strike chance of your Nature damage spells by 10% and the critical strike damage of your Nature spells by 5%.
    supercharge                 = {  94873, 455110, 1 }, -- Lightning Bolt and Chain Lightning Elemental Overloads have a 50% chance to cause an additional Elemental Overload.
    surging_currents            = {  94880, 454372, 1 }, -- After using Tempest, your next Chain Heal, or Healing Surge will be instant cast and consume no Mana.
    tempest                     = {  94892, 454009, 1, "stormbringer" }, -- Every 400 Maelstrom spent replaces your next Lightning Bolt with Tempest.
    unlimited_power             = {  94886, 454391, 1 }, -- Spending Maelstrom grants you 3% haste for 15 sec, stacking. Gaining a new stack does not refresh the duration.
    voltaic_surge               = {  94870, 454919, 1 }, -- Crash Lightning, Chain Lightning, and Earthquake damage increased by 15%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5574, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by 50% for 5 sec. When the effect ends, enemies within 6 yards are knocked in the air and take 108,591 Physical damage.
    counterstrike_totem = 3490, -- (204331) Summons a totem at your feet for 15 sec. Whenever enemies within 23 yards of the totem deal direct damage, the totem will deal 100% of the damage dealt back to attacker.
    electrocute         = 5659, -- (206642)
    grounding_totem     = 3620, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within 34 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    shamanism           = 5660, -- (193876)
    static_field_totem  =  727, -- (355580) Summons a totem with 4% of your health at the target location for 6 sec that forms a circuit of electricity that enemies cannot pass through.
    totem_of_wrath      = 3488, -- (460697) Primordial Wave summons a totem at your feet for 15 sec that increases the critical effect of damage and healing spells of all nearby allies within 46 yards by 20% for 15 sec.
    unleash_shield      = 3491, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
    volcanic_surge      = 5571, -- (408572)
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: A percentage of damage or healing dealt is copied as healing to up to 3 nearby injured party or raid members.
    -- https://wowhead.com/beta/spell=108281
    ancestral_guidance = {
        id = 108281,
        duration = 10,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Health increased by $s1%.    If you die, the protection of the ancestors will allow you to return to life.
    -- https://wowhead.com/beta/spell=207498
    ancestral_protection = {
        id = 207498,
        duration = 30,
        max_stack = 1
    },
    -- Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.
    ancestral_swiftness = {
        id = 443454,
        duration = 3600,
        max_stack = 1,
        onRemove = function( t )
            setCooldown( "ancestral_swiftness", action.ancestral_swiftness.cooldown )
        end
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
    -- Talent: Transformed into a powerful Fire ascendant. Chain Lightning is transformed into Lava Beam.
    -- https://wowhead.com/beta/spell=114050
    ascendance = {
        id = 114050,
        duration = function() return 15 + 3 * talent.preeminence.rank end,
        max_stack = 1,
        copy = { 114051, 114052 }
    },
    -- Talent: Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=108271
    astral_shift = {
        id = 108271,
        duration = 12,
        max_stack = 1
    },
    -- Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=2825
    bloodlust = {
        id = 2825,
        duration = function() return pvptalent.shamanism.enabled and 10 or 40 end,
        max_stack = 1,
        shared = "player",
        copy = { 32182, 204361, "heroism" }
    },
    -- When you deal damage, $w1% is dealt to your lowest health ally within $204331m2 yards.
    counterstrike_totem = {
        id = 208997,
        duration = 15.0,
        max_stack = 1,
    },
    -- Chance to activate Windfury Weapon increased to ${$319773h}.1%.  Damage dealt by Windfury Weapon increased by $s2%.
    -- https://wowhead.com/beta/spell=384352
    doom_winds = {
        id = 384352,
        duration = 8,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=198103
    earth_elemental = {
        id = 198103,
        duration = function() return 60 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Heals for ${$w2*(1+$w1/100)} upon taking damage.
    -- https://wowhead.com/beta/spell=974
    earth_shield = {
        id = function () return talent.elemental_orbit.enabled and 383648 or 974 end,
        duration = 600,
        type = "Magic",
        max_stack = function() return 9 + 3 * talent.earthen_communion.rank end,
        dot = "buff",
        friendly = true,
        shared = "player",
        copy = { 383648, 974 }
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=3600
    earthbind = {
        id = 3600,
        duration = 5,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Rooted.
    -- https://wowhead.com/beta/spell=64695
    earthgrab = {
        id = 64695,
        duration = 8,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=382024
    earthliving_weapon = {
        id = 382024,
        duration = 12,
        max_stack = 1
    },
    echoes_of_great_sundering = {
        id = 384088,
        duration = 25,
        max_stack = 1,
        copy = { 336217, "echoes_of_great_sundering_es", "echoes_of_great_sundering_eb" }
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    -- https://wowhead.com/beta/spell=320125
    echoing_shock = {
        id = 320125,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- $w1 Nature damage every $t1 sec.
    electrocute = {
        id = 206647,
        duration = 3.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    elemental_blast = {
        alias = { "elemental_blast_critical_strike", "elemental_blast_haste", "elemental_blast_mastery" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
    },
    electrified_shocks = {
        id = 382089,
        duration = 9,
        type = "Magic",
        max_stack = 1
    },
    elemental_blast_critical_strike = {
        id = 118522,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1,
    },
    elemental_blast_haste = {
        id = 173183,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1,
    },
    elemental_blast_mastery = {
        id = 173184,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1,
    },
    -- Talent: Damage dealt increased by $s1%.
    -- https://wowhead.com/beta/spell=378275
    elemental_equilibrium = {
        id = 378275,
        duration = 10,
        max_stack = 1,
        copy = 347348
    },
    elemental_equilibrium_debuff = {
        id = 378277,
        duration = 30,
        max_stack = 1,
        copy = 347349,
    },
    -- Fire, Frost, and Nature damage taken reduced by $w1%.
    elemental_resistance = {
        id = 462568,
        duration = 3.0,
        pandemic = true,
        max_stack = 1,
    },
    enfeeblement = {
        id = 378080,
        duration = 6,
        max_stack = 1
    },
    -- Cannot move while using Far Sight.
    -- https://wowhead.com/beta/spell=6196
    far_sight = {
        id = 6196,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $188592s2%
    -- https://wowhead.com/beta/spell=198067
    fire_elemental = {
        id = 188592,
        duration = function() return 30 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    lesser_fire_elemental = {
        id = 462992,
        duration = 15,
        max_stack = 1
    },
    -- Suffering $w2 Fire damage every $t2 sec.
    -- https://wowhead.com/beta/spell=188389
    flame_shock = {
        id = 188389,
        duration = function() return 18 * ( buff.fire_elemental.up and 0.75 or 1 ) * ( buff.lesser_fire_elemental.up and 2 or 1 ) end,
        tick_time = function() return 2 * haste * ( talent.flame_of_the_cauldron.enabled and 0.85 or 1 ) * ( buff.fire_elemental.up and 0.75 or 1 ) * ( buff.lesser_fire_elemental.up and 0.75 or 1 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Each of your weapon attacks causes up to ${$max(($<coeff>*$AP),1)} additional Fire damage.
    -- https://wowhead.com/beta/spell=319778
    flametongue_weapon = {
        id = 319778,
        duration = 3600,
        max_stack = 1,
    },
    improved_flametongue_weapon = {
        id = 382028,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Your next Lava Burst will deal $s1% increased damage.
    -- https://wowhead.com/beta/spell=381777
    flux_melting = {
        id = 381777,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=196840
    frost_shock = {
        id = 196840,
        duration = function() return 6 + 2 * talent.encasing_cold.rank end,
        type = "Magic",
        max_stack = 1
    },
    -- After casting a damaging Fire$?a462841[ and a Nature][] spell, you additionally cast an Elemental Blast at your target.
    fusion_of_elements_fire = {
        id = 462843,
        duration = 20.0,
        max_stack = 1,
    },
    fusion_of_elements_nature = {
        id = 462841,
        duration = 20.0,
        max_stack = 1,
    },
    -- Increases movement speed by $?s382215[${$382216s1+$w2}][$w2]%.$?$w3!=0[  Less hindered by effects that reduce movement speed.][]
    -- https://wowhead.com/beta/spell=2645
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Your next Frost Shock will deal $s1% additional damage, and hit up to ${$334195s1/$s2} additional $Ltarget:targets;.
    -- https://wowhead.com/beta/spell=334196
    hailstorm = {
        id = 334196,
        duration = 20,
        max_stack = 5
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/beta/spell=73920
    healing_rain = {
        id = 73920,
        duration = 10,
        max_stack = 1
    },
    -- Healing $?s147074[two injured party or raid members][an injured party or raid member] every $t1 sec.
    -- https://wowhead.com/beta/spell=5672
    healing_stream = {
        id = 5672,
        duration = 15,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=51514
    hex = {
        id = 51514,
        duration = 60,
        mechanic = "polymorph",
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=342240
    ice_strike = {
        id = 342240,
        duration = 6,
        max_stack = 1
    },
    icefury = {
        id = 462818,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Frost Shock damage increased by $w2%.
    -- https://wowhead.com/beta/spell=210714
    icefury_dmg = {
        id = 210714,
        duration = 25,
        type = "Magic",
        max_stack = 4,
        copy = "icefury_dmg"
    },
    -- Fire damage inflicted every $t2 sec.
    -- https://wowhead.com/beta/spell=118297
    immolate = {
        id = 118297,
        duration = 21,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Lava Burst casts instantly.
    -- https://wowhead.com/beta/spell=77762
    lava_surge = {
        id = 77762,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Stunned. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=305485
    lightning_lasso = {
        id = 305485,
        duration = 5,
        tick_time = 1,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    lightning_rod = {
        id = 197209,
        duration = 8,
        max_stack = 1
    },
    -- Chance to deal $192109s1 Nature damage when you take melee damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].
    -- https://wowhead.com/beta/spell=192106
    lightning_shield = {
        id = 192106,
        duration = 1800,
        max_stack = 1
    },
    maelstrom_surge = { -- TWW Tier 1 4pc
        id = 457727,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Flame Shock damage increases the damage of your next Earth Shock, Elemental Blast, or Earthquake by 0.8%, stacking up to 20 times.
    -- https://www.wowhead.com/beta/spell=381933
    magma_chamber = {
        id = 381933,
        duration = 20,
        type = "magic",
        max_stack = 20
    },
    --[[ Removed in 10.0.5 -- Talent:
    -- https://wowhead.com/beta/spell=381930
    mana_spring_totem = {
        id = 381930,
        duration = 120,
        type = "Magic",
        max_stack = 1
    }, ]]
    -- Talent: Your next Nature, Physical, or Frost spell will deal $s1% increased damage or healing.
    -- https://wowhead.com/beta/spell=260734
    master_of_the_elements = {
        id = 260734,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    -- https://wowhead.com/beta/spell=378081
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        onRemove = function( t )
            setCooldown( "natures_swiftness", action.natures_swiftness.cooldown )
        end
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=280205
    pack_spirit = {
        id = 280205,
        duration = 3600,
        max_stack = 1
    },
    -- Cleansing $383015s1 poison effect from a nearby party or raid member every $t1 sec.
    -- https://wowhead.com/beta/spell=383014
    poison_cleansing = {
        id = 383014,
        duration = 6,
        tick_time = 1.5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Lightning Bolt and Chain Lightning will trigger Elemental Overload an additional time.
    -- https://wowhead.com/beta/spell=191877
    power_of_the_maelstrom = {
        id = 191877,
        duration = 20,
        max_stack = 2
    },
    -- Heals $w2 every $t2 seconds.
    -- https://wowhead.com/beta/spell=61295
    riptide = {
        id = 61295,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    spirit_wolf = {
        id = 260881,
        duration = 3600,
        max_stack = 4
    },
    -- Talent: Increases movement speed by $s1%.
    -- https://wowhead.com/beta/spell=58875
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Immune to Silence/Interrupt.
    -- https://wowhead.com/beta/spell=378078
    spiritwalkers_aegis = {
        id = 378078,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Able to move while casting all Shaman spells.
    -- https://wowhead.com/beta/spell=79206
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent
    splintered_elements = {
        id = 382043,
        duration = 12,
        max_stack = 10,
        copy = { 382042, 354648 } -- Old spell ID, just in case.
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=118905
    static_charge = {
        id = 118905,
        duration = 3,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    stoneskin = {
        id = 383018,
        duration = 15,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=192249
    storm_elemental = {
        id = 192249,
        duration = function() return 30 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    lesser_storm_elemental = {
        id = 192249,
        duration = function() return 15 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    storm_frenzy = {
        id = 462725,
        duration = 12,
        max_stack = 2
    },
    -- Stormstrike cooldown has been reset$?$?a319930[ and will deal $319930w1% additional damage as Nature][].
    -- https://wowhead.com/beta/spell=201846
    stormbringer = {
        id = 201846,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Your next Chain Lightning will deal $s2% increased damage and be instant cast.
    -- https://wowhead.com/beta/spell=320137
    stormkeeper = {
        -- Elemental: 191634
        -- Enhancement: 320137
        -- Restoration: 383009
        id = 191634,
        duration = 15,
        type = "Magic",
        max_stack = 2,
        copy = { 320137, 383009 }
    },
    -- Incapacitated.
    -- https://wowhead.com/beta/spell=197214
    sundering = {
        id = 197214,
        duration = 2,
        max_stack = 1
    },
    -- Talent: Your next spell cast will be enhanced.
    -- https://wowhead.com/beta/spell=285514
    surge_of_power = {
        id = 285514,
        duration = 15,
        max_stack = 1
    },
    surge_of_power_debuff = {
        id = 285515,
        duration = 6,
        max_stack = 1,
    },
    -- Talent: Your next Healing Surge$?s137039[, Healing Wave, or Riptide][] will be $w1% more effective.
    -- https://wowhead.com/beta/spell=378102
    swirling_currents = {
        id = 378102,
        duration = 15,
        type = "Magic",
        max_stack = 3,
        copy = 338340
    },
    tempest = {
        id = 454015,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $378075s1%.
    -- https://wowhead.com/beta/spell=378076
    thunderous_paws = {
        id = 378076,
        duration = 3,
        max_stack = 1
    },
    thunderstrike_ward = {
        id = 462760,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s3%.
    -- https://wowhead.com/beta/spell=51490
    thunderstorm = {
        id = 51490,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    volcanic_surge = {
        id = 408575,
        duration = 18,
        max_stack = 2
    },
    water_walking = {
        id = 546,
        duration = 600,
        max_stack = 1,
    },
    wind_rush = {
        id = 192082,
        duration = 5,
        max_stack = 1,
    },
    wind_gust = {
        id = 263806,
        duration = 30,
        max_stack = 20
    },
    -- Talent: Lava Burst damage increased by $s1%.
    -- https://wowhead.com/beta/spell=378269
    windspeakers_lava_resurgence = {
        id = 378269,
        duration = 15,
        max_stack = 1,
        copy = 336065
    },

    -- Pet aura.
    call_lightning = {
        duration = 20,
        generate = function( t, db )
            if storm_elemental.up then
                local name, _, count, _, duration, expires = FindUnitBuffByID( "pet", 157348 )

                if name then
                    t.count = count
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = "pet"
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    -- Conduit
    vital_accretion = {
        id = 337984,
        duration = 60,
        max_stack = 1
    },
} )


-- Pets
spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental",
    function()
        if not talent.primal_elementalist.enabled then return 0 end
        return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) )
    end )
spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental",
    function()
        if not talent.primal_elementalist.enabled then return 0 end
        return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) )
    end )
spec:RegisterTotem( "greater_fire_elemental", 135790 ) -- Texture ID

spec:RegisterPet( "primal_earth_elemental", 61056, "earth_elemental",
    function()
        if not talent.primal_elementalist.enabled then return 0 end
        return 60
    end )
spec:RegisterTotem( "greater_earth_elemental", 136024 ) -- Texture ID

local elementals = {
    [77942] = { "primal_storm_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
    [61029] = { "primal_fire_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
    [61056] = { "primal_earth_elemental", function () return 60 end, false }
}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local summon = {}
local wipe = table.wipe

local vesper_heal = 0
local vesper_damage = 0
local vesper_used = 0

local vesper_expires = 0
local vesper_guid
local vesper_last_proc = 0

local recall_totems = {
    capacitor_totem = 1,
    earthbind_totem = 1,
    earthgrab_totem = 1,
    grounding_totem = 1,
    healing_stream_totem = 1,
    liquid_magma_totem = 1,
    poison_cleansing_totem = 1,
    stoneskin_totem = 1,
    tranquil_air_totem = 1,
    tremor_totem = 1,
    wind_rush_totem = 1,
}

local ancestral_wolf_affinity_spells = {
    cleanse_spirit = 1,
    wind_shear = 1,
    purge = 1,
    -- TODO: List totems?
}

local recallTotem1
local recallTotem2

spec:RegisterStateExpr( "recall_totem_1", function()
    return recallTotem1
end )

spec:RegisterStateExpr( "recall_totem_2", function()
    return recallTotem2
end )

spec:RegisterStateExpr( "lightning_rod", function()
end )

spec:RegisterStateTable( "rolling_thunder", {

} )


spec:RegisterHook( "runHandler", function( action )
    if buff.ghost_wolf.up then
        if talent.ancestral_wolf_affinity.enabled then
            local ability = class.abilities[ action ]
            if not ancestral_wolf_affinity_spells[ action ] and not ability.gcd == "totem" then
                removeBuff( "ghost_wolf" )
            end
        else
            removeBuff( "ghost_wolf" )
        end
    end

    if talent.totemic_recall.enabled and recall_totems[ action ] then
        recall_totem_2 = recall_totem_1
        recall_totem_1 = action
    end

    if talent.elemental_equilibrium.enabled and debuff.elemental_equilibrium_debuff.down then
        local ability = class.abilities[ action ]
        if ability and ability.startsCombat and ability.school then
            if ability.school == "fire" then last_ee_fire = query_time
            elseif ability.school == "frost" then last_ee_frost = query_time
            elseif ability.school == "nature" then last_ee_nature = query_time end

            if max( last_ee_fire, last_ee_frost, last_ee_nature ) - min( last_ee_fire, last_ee_frost, last_ee_nature ) < 10 then
                applyBuff( "elemental_equilibrium" )
                applyDebuff( "player", "elemental_equilibrium_debuff" )
            end
        end
    end
end )


local fireDamage, frostDamage, natureDamage = 0, 0, 0
local stormkeeperCastStart, stormkeeperLastProc = 0, 0

local further_beyond_duration_remains, fbSpells = 0, {
    earth_shock = 1,
    earthquake = 1,
    elemental_blast = 1,
    ascendance = 1
}
spec:RegisterStateExpr( "fb_extension_remaining", function()
    return further_beyond_duration_remains
end )

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, school )
    -- Deaths/despawns.
    if death_events[ subtype ] then
        if destGUID == summon.guid then
            wipe( summon )
        elseif destGUID == vesper_guid then
            vesper_guid = nil
        end
        return
    end

    if sourceGUID == state.GUID then
        -- Summons.
        if subtype == "SPELL_SUMMON" then
            local npcid = destGUID:match("(%d+)-%x-$")
            npcid = npcid and tonumber( npcid ) or -1
            local elem = elementals[ npcid ]

            if elem then
                summon.guid = destGUID
                summon.type = elem[1]
                summon.duration = elem[2]()
                summon.expires = GetTime() + summon.duration
                summon.extends = elem[3]
            end

            if spellID == 324386 then
                vesper_guid = destGUID
                vesper_expires = GetTime() + 30

                vesper_heal = 3
                vesper_damage = 3
                vesper_used = 0
            end

        --[[ Tier 28
        elseif summon.extends and state.set_bonus.tier28_4pc > 0 and subtype == "SPELL_ENERGIZE" and ( spellID == 51505 or spellID == 285466 ) then
            summon.expires = summon.expires + 1.5
            summon.duration = summon.duration + 1.5 ]]

        elseif spellID == 191634 then
            -- Stormkeeper.
            if subtype == "SPELL_CAST_START" then stormkeeperCastStart = GetTime()
            elseif subtype == "SPELL_CAST_SUCCESS" or subtype == "SPELL_CAST_FAILED" then stormkeeperCastStart = 0
            elseif subtype == "SPELL_AURA_APPLIED" and stormkeeperCastStart == 0 then
                stormkeeperLastProc = GetTime()
            end

        -- Vesper Totem heal
        elseif spellID == 324522 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_heal = vesper_heal - 1
            end

        -- Vesper Totem damage; only fires on SPELL_DAMAGE...
        elseif spellID == 324520 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_damage = vesper_damage - 1
            end

        end

        if ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) and state.talent.elemental_equilibrium.enabled then
            if bit.band( school, 4  ) == 1 then fireDamage   = GetTime() end
            if bit.band( school, 16 ) == 1 then frostDamage  = GetTime() end
            if bit.band( school, 8  ) == 1 then natureDamage = GetTime() end
        end
    end
end )

spec:RegisterStateExpr( "vesper_totem_heal_charges", function()
    return vesper_heal
end )

spec:RegisterStateExpr( "vesper_totem_dmg_charges", function ()
    return vesper_damage
end )

spec:RegisterStateExpr( "vesper_totem_used_charges", function ()
    return vesper_used
end )

spec:RegisterStateFunction( "trigger_vesper_heal", function ()
    if vesper_totem_heal_charges > 0 then
        vesper_totem_heal_charges = vesper_totem_heal_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterStateFunction( "trigger_vesper_damage", function ()
    if vesper_totem_dmg_charges > 0 then
        vesper_totem_dmg_charges = vesper_totem_dmg_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterStateExpr( "last_ee_fire", function ()
    return fireDamage
end )

spec:RegisterStateExpr( "last_ee_frost", function ()
    return frostDamage
end )

spec:RegisterStateExpr( "last_ee_nature", function ()
    return natureDamage
end )


spec:RegisterStateTable( "rolling_thunder", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if not talent.rolling_thunder.enabled and set_bonus.tier30_2pc == 0 then return 0 end

        if k == "next_tick" then
            return max( 0, t.last_tick + 50 - query_time )
        elseif k == "last_tick" then
            return 0
        end
    end, state )
} ) )

spec:RegisterStateExpr( "t30_2pc_timer", function()
    return rolling_thunder
end )

spec:RegisterStateExpr( "lightning_rod", function()
    return active_dot.lightning_rod
end )


spec:RegisterTotem( "liquid_magma_totem", 971079 )
spec:RegisterTotem( "tremor_totem", 136108 )
spec:RegisterTotem( "wind_rush_totem", 538576 )

spec:RegisterTotem( "vesper_totem", 3565451 )


spec:RegisterStateTable( "fire_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.fire_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "storm_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.storm_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "earth_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.earth_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )



-- Tier 29
spec:RegisterGear( "tier29", 200396, 200398, 200400, 200401, 200399 )
spec:RegisterSetBonuses( "tier29_2pc", 393688, "tier29_4pc", 393690 )
-- 2-Set: - https://www.wowhead.com/beta/spell=393688
-- 4-Set: - https://www.wowhead.com/beta/spell=393690
spec:RegisterAuras( {
    seismic_accumulation = {
        id = 394651,
        duration = 15,
        max_stack = 5,
    },
    elemental_mastery = {
        id = 394670,
        duration = 5,
        max_stack = 1,
    }
} )


-- Tier 30
spec:RegisterGear( "tier30", 202473, 202471, 202470, 202469, 202468 )
spec:RegisterAura( "primal_fracture", {
    id = 410018,
    duration = 8,
    max_stack = 1,
    copy = "t30_4pc_ele"
} )

spec:RegisterGear( "tier31", 207207, 207208, 207209, 207210, 207212, 217238, 217240, 217236, 217237, 217239 )
spec:RegisterAuras( {
    molten_slag = {
        id = 426577,
        duration = 4,
        max_stack = 1,
    },
    molten_charge = {
        id = 426578,
        duration = 20,
        max_stack = 1
    }
} )

spec:RegisterGear( "tww1", 212014, 212012, 212011, 212010, 212009 )
spec:RegisterAura( "maelstrom_surge", {
    id = 457727,
    duration = 5,
    max_stack = 1
} )


local TriggerHeatWave = setfenv( function()
    applyBuff( "lava_surge" )
end, state )

local TriggerStaticAccumulation = setfenv( function()
    addStack( "maelstrom_weapon", nil, talent.static_accumulation.rank )
end, state )

local TriggerStormkeeperRT = setfenv( function()
    addStack( "stormkeeper" )
    rolling_thunder.last_tick = query_time
end, state )


local debugstack = debugstack

spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end
    if oh and oh_enchant == 7587 then applyBuff( "thunderstrike_ward" ) end
    if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end
    if talent.thunderstrike_ward.enabled and buff.thunderstrike_ward.down and ( now - action.thunderstrike_ward.lastCast < 1 ) then applyBuff( "thunderstrike_ward" ) end

    if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
        applyBuff( "master_of_the_elements" )
    end

    if vesper_expires > 0 and now > vesper_expires then
        vesper_expires = 0
        vesper_heal = 0
        vesper_damage = 0
        vesper_used = 0
    end

    vesper_totem_heal_charges = nil
    vesper_totem_dmg_charges = nil
    vesper_totem_used_charges = nil

    recall_totem_1 = nil
    recall_totem_2 = nil

    if totem.vesper_totem.up then
        applyBuff( "vesper_totem", totem.vesper_totem.remains )
    end

    rawset( state.pet, "earth_elemental", talent.primal_elementalist.enabled and state.pet.primal_earth_elemental or state.pet.greater_earth_elemental )
    rawset( state.pet, "fire_elemental",  talent.primal_elementalist.enabled and state.pet.primal_fire_elemental  or state.pet.greater_fire_elemental  )
    rawset( state.pet, "storm_elemental", talent.primal_elementalist.enabled and state.pet.primal_storm_elemental or state.pet.greater_storm_elemental )

    if talent.primal_elementalist.enabled then
        dismissPet( "primal_fire_elemental" )
        dismissPet( "primal_storm_elemental" )
        dismissPet( "primal_earth_elemental" )

        if summon.expires then
            if summon.expires <= now then
                wipe( summon )
            else
                summonPet( summon.type, summon.expires - now )
            end
        end
    end

    if talent.primordial_surge.enabled and query_time - action.primordial_wave.lastCast < 12 then
        local expires = action.primordial_wave.lastCast + 12
        while expires > query_time do
            state:QueueAuraEvent( "primordial_surge", TriggerHeatWave, expires, "AURA_PERIODIC" )
            expires = expires - 3
        end
    end

    if talent.rolling_thunder.enabled or set_bonus.tier30_2pc > 0 then
        rolling_thunder.last_tick = stormkeeperLastProc
        if rolling_thunder.next_tick > 0 then
            state:QueueAuraEvent( "stormkeeper", TriggerStormkeeperRT, query_time + rolling_thunder.next_tick, "AURA_PERIODIC" )
        end
    end

    if buff.ascendance.down or not talent.further_beyond.enabled then
        fb_extension_remaining = 0
    end

    --[[ TODO: Not really needed; shift to Enhancement module.
    if talent.static_accumulation.enabled and buff.ascendance.up then
        local expires = buff.ascendance.expires
        while expires > query_time do
            state:QueueAuraEvent( "ascendance", TriggerStaticAccumulation, query_time + expires )
            expires = expires - 1
        end
    end ]]
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "maelstrom" and set_bonus.tww1_4pc > 0 then applyBuff( "maelstrom_surge" ) end
end )


local fol_spells = {}

spec:RegisterStateFunction( "flash_of_lightning", function()
    if #fol_spells == 0 then
        for k, v in pairs( class.abilityList ) do
            if v.school == "nature" then table.insert( fol_spells, k ) end
        end
    end

    for _, spell in ipairs( fol_spells ) do
        reduceCooldown( spell, 1 )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: For the next $d, $s1% of your damage and healing is converted to healing on up to 3 nearby injured party or raid members.
    ancestral_guidance = {
        id = 108281,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "nature",

        talent = "ancestral_guidance",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "ancestral_guidance" )
        end,
    },

    ancestral_swiftness = {
        id = 443454,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "nature",

        startsCombat = false,
        talent = "ancestral_swiftness",
        nobuff = "ancestral_swiftness",
        toggle = "cooldowns",

        handler = function ()
            if talent.natures_swiftness.enabled then
                -- Summon an ancestor.
            end
            applyBuff( "ancestral_swiftness" )
        end,
    },

    -- Talent: Transform into a Flame Ascendant for $d, replacing Chain Lightning with Lava Beam, removing the cooldown on Lava Burst, and increasing the damage of Lava Burst by an amount equal to your critical strike chance.    When you transform into the Flame Ascendant, instantly cast a Lava Burst at all enemies affected by your Flame Shock, and refresh your Flame Shock durations to $188389d.
    ascendance = {
        id = function()
            if state.spec.elemental then return 114050 end
            if state.spec.enhancement then return 114051 end
            return 114052
        end,
        cast = 0,
        cooldown = function () return 180 - 30 * talent.oath_of_the_far_seer.rank end,
        gcd = "spell",
        school = function()
            if spec.elemental then return "fire" end
            return "nature"
        end,
        talent = "ascendance",
        startsCombat = function()
            if state.spec.elemental and active_dot.flame_shock > 0 then return true end
            return false
        end,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ascendance" )
            if state.spec.elemental and dot.flame_shock.up then dot.flame_shock.expires = query_time + class.auras.flame_shock.duration
            elseif state.spec.enhancement and talent.static_accumulation.enabled then
                for i = 1, class.auras.ascendance.duration do
                    state:QueueAuraEvent( "ascendance", TriggerStaticAccumulation, query_time + i, "AURA_PERIODIC" )
                end
            end
        end,

        copy = { 114050, 114051, 114052 }
    },


    astral_recall = {
        id = 556,
        cast = 10,
        cooldown = 600,
        gcd = "spell",

        startsCombat = false,
        texture = 136010,

        handler = function () end,
    },


    astral_shift = {
        id = 108271,
        cast = 0,
        cooldown = function () return talent.planes_traveler.enabled and 90 or 120 end,
        gcd = "off",
        school = "nature",

        talent = "astral_shift",
        startsCombat = false,
        nopvptalent = "ethereal_form",

        toggle = "defensives",

        handler = function ()
            applyBuff( "astral_shift" )
        end,
    },

    -- Increases haste by $s1% for all party and raid members for $d.    Allies receiving this effect will become Sated and unable to benefit from Bloodlust or Time Warp again for $57724d.
    bloodlust = {
        id = function() return state.faction == "Alliance" and 32182 or 2825 end,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "nature",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",
        nodebuff = "sated",

        handler = function ()
            applyBuff( "bloodlust" )
            applyDebuff( "player", "sated" )
            stat.haste = state.haste + 0.4
        end,

        copy = { 2825, "heroism" }
    },

    -- PvP Talent: Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by ${$s3-100}% for $d.; When the effect ends, enemies within $409304A1 yards are knocked in the air and take $<damage> Physical damage.
    burrow = {
        id = 409293,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        pvptalent = "burrow",

        handler = function()
            applyBuff( "burrow" )
            setCooldown( "global_cooldown", 5 )
        end,

        auras = {
            burrow = {
                id = 409293,
                duration = 5,
                max_stack = 1
            }
        }

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

    -- Talent: Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = function () return 60 - 3 * talent.totemic_surge.rank + conduit.totemic_surge.mod * 0.001 end,
        gcd = "totem",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "capacitor_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "capacitor_totem" )
        end,
    },

    -- Talent: Heals the friendly target for $s1, then jumps to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_heal = {
        id = 1064,
        cast = function ()
            if buff.chains_of_devastation_ch.up then return 0 end
            if buff.ancestral_swiftness.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            return 2.5 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.15 end,
        spendType = "mana",

        talent = "chain_heal",
        startsCombat = false,

        handler = function ()
            removeBuff( "chains_of_devastation_ch" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end -- TODO: Determine order of instant cast effect consumption.
            removeBuff( "echoing_shock" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_cl" )
            end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Talent: Hurls a lightning bolt at the enemy, dealing $s1 Nature damage and then jumping to additional nearby enemies. Affects $x1 total targets.$?s187874[    If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by $333964s1%.][]$?s187874[    Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by ${$s3/1000}.1 sec.][]$?a343725[    |cFFFFFFFFGenerates $343725s5 Maelstrom per target hit.|r][]
    chain_lightning = {
        id = 188443,
        cast = function ()
            if buff.chains_of_devastation_cl.up then return 0 end
            if buff.ancestral_swiftness.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.03 * min( 10, buff.wind_gust.stacks ) )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
                * ( 1 - 0.25 * buff.volcanic_surge.stack )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,

        nobuff = "ascendance",
        bind = "lava_beam",

        handler = function ()
            removeBuff( "chains_of_devastation_cl" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )
            removeBuff( "volcanic_surge" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_ch" )
            end

            -- 2 MS per target, direct.
            -- 1 MS per target, overload.
            -- stormkeeper guarantees overload on every target hit
            -- power of the maelstrom guarantees 1 extra overload on the initial target
            -- surge of power adds 1 extra target to total potential enemies hit
            local amount = ( buff.stormkeeper.up and 3 or 2 )
                * min( ( level > 42 and 5 or 3 ) + ( buff.surge_of_power.up and 1 or 0 ), true_active_enemies )
                + ( buff.power_of_the_maelstrom.up and 1 or 0 )
            gain( amount, "maelstrom" )

            if buff.stormkeeper.up then
                removeStack( "stormkeeper" )
                if set_bonus.tier30_4pc > 0 then applyBuff( "primal_fracture" ) end
            end

            removeStack( "power_of_the_maelstrom" )
            removeBuff( "surge_of_power" )

            if pet.storm_elemental.up or buff.lesser_storm_elemental.up then
                addStack( "wind_gust" )
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Removes all Curse effects from a friendly target.
    cleanse_spirit = {
        id = 51886,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "nature",

        spend = 0.10,
        spendType = "mana",

        talent = "cleanse_spirit",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_curse",

        handler = function ()
            removeBuff( "dispellable_curse" )
            if state.spec.elemental and time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },

    -- Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker.
    counterstrike_totem = {
        id = 204331,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "fire",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "counterstrike_totem",
        startsCombat = false,
        texture = 511726,

        handler = function ()
            summonTotem( "counterstrike_totem" )
        end,
    },

    -- Talent: Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.    While this elemental is active, your maximum health is increased by $381755s1%.
    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = function () return 300 * ( buff.deadened_earth.up and 0.6 or 1 ) end,
        gcd = "spell",
        school = "nature",

        talent = "earth_elemental",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 * ( 1 + 0.2 * talent.everlasting_elements.rank ) )
            if conduit.vital_accretion.enabled then
                applyBuff( "vital_accretion" )
                health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
            end
        end,

        usable = function ()
            if state.spec.restoration then return end
            return max( cooldown.fire_elemental.true_remains, cooldown.storm_elemental.true_remains ) > 0, "DPS elementals must be on CD first"
        end,

        timeToReady = function ()
            return max( pet.fire_elemental.remains, pet.storm_elemental.remains, pet.primal_fire_elemental.remains, pet.primal_storm_elemental.remains )
        end,
    },

    -- Talent: Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $n charges.    $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.02,
        spendType = "mana",

        talent = "earth_shield",
        startsCombat = false,

        --This can be fine, as long as the APL doesn't recommend casting both unless elemental orbit is picked.
        handler = function ()
            applyBuff( "earth_shield", nil, class.auras.earth_shield.max_stack )
            if not talent.elemental_orbit.enabled then removeBuff( "lightning_shield" ) end
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Talent: Instantly shocks the target with concussive force, causing $s1 Nature damage.$?a190493[    Earth Shock will consume all stacks of Fulmination to deal extra Nature damage to your target.][]
    earth_shock = {
        id = 8042,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 60 - 5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "earth_shock",
        notalent = "elemental_blast",
        startsCombat = true,
        cycle = function() return talent.lightning_rod.enabled and "lightning_rod" or nil end,

        handler = function ()
            removeBuff( "master_of_the_elements" )
            removeBuff( "magma_chamber" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.echoes_of_great_sundering.enabled or runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering" )
            end

            if talent.windspeakers_lava_resurgence.enabled or runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.further_beyond.enabled and buff.ascendance.up then
                local extension = min( 2.5, fb_extension_remaining )
                buff.ascendance.expires = buff.ascendance.expires + extension
                fb_extension_remaining = fb_extension_remaining - extension
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if talent.storm_frenzy.enabled then
                addStack( "storm_frenzy", nil, 2 )
            end

            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Summons a totem at the target location for $d that slows the movement speed of enemies within $3600A1 yards by $3600s1%.
    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        startsCombat = false,
        notalent = "earthgrab_totem",
        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthbind_totem" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    earthgrab_totem = {
        id = 51485,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "spell",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "earthgrab_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthgrab_totem" )
        end,
    },

    -- Talent: Causes the earth within $a1 yards of the target location to tremble and break, dealing $<damage> Physical damage over $d and has a $?s381743[${$77478s2+$381743S1)}.1][$77478s2]% chance to knock the enemy down.
    earthquake = {
        id = function() return talent.earthquake_2.enabled and 462620 or 61882 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 60 - 5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = function() return talent.earthquake_2.enabled and "earthquake_2" or "earthquake" end,
        startsCombat = true,

        handler = function ()
            removeBuff( "echoes_of_great_sundering" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "magma_chamber" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if talent.further_beyond.enabled and buff.ascendance.up then
                local extension = min( 2.5, fb_extension_remaining )
                buff.ascendance.expires = buff.ascendance.expires + extension
                fb_extension_remaining = fb_extension_remaining - extension
            end

            if talent.windspeakers_lava_resurgence.enabled then
                addStack( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.storm_frenzy.enabled then
                addStack( "storm_frenzy", nil, 2 )
            end

            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = { 61882, 462620 }
    },

    -- Shock the target for $s1 Elemental damage and create an ancestral echo, causing your next damage or healing spell to be cast a second time ${$s2/1000}.1 sec later for free.
    echoing_shock = {
        id = 320125,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        spend = 0.0325,
        spendType = 'mana',

        startsCombat = true,

        handler = function()
            applyBuff( "echoing_shock" )
        end,
    },

    -- Talent: Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[    If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_blast = {
        id = 117014,
        cast = function ()
            if ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) then return 0 end
            return 2 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        gcd = "spell",
        school = "elemental",

        spend = function () return 90 - 7.5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "elemental_blast",
        startsCombat = true,
        cycle = function() return talent.lightning_rod.enabled and "lightning_rod" or nil end,

        handler = function ()
            removeBuff( "master_of_the_elements" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "magma_chamber" )
            removeBuff( "echoing_shock" )

            applyBuff( "elemental_blast" )

            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.echoes_of_great_sundering.enabled or runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering" )
            end

            if talent.windspeakers_lava_resurgence.enabled or runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.further_beyond.enabled and buff.ascendance.up then
                local extension = min( 3.5, fb_extension_remaining )
                buff.ascendance.expires = buff.ascendance.expires + extension
                fb_extension_remaining = fb_extension_remaining - extension
            end

            if talent.storm_frenzy.enabled then
                addStack( "storm_frenzy", nil, 2 )
            end

            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end
            if talent.further_beyond.enabled and buff.ascendance.up then buff.ascendance.expires = buff.ascendance.expires + 3.5 end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Changes your viewpoint to the targeted location for $d.
    far_sight = {
        id = 6196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "far_sight" )
        end,
    },

    -- Talent: Calls forth a Greater Fire Elemental to rain destruction on your enemies for $188592d.     While the Fire Elemental is active, Flame Shock deals damage   ${100*(1/(1+$188592s2/100)-1)}% faster, and newly applied Flame Shocks last $188592s3% longer.
    fire_elemental = {
        id = 198067,
        cast = 0,
        charges = 1,
        cooldown = 150,
        recharge = 150,
        gcd = "spell",
        school = "fire",

        spend = 0.05,
        spendType = "mana",

        talent = "fire_elemental",
        startsCombat = false,

        toggle = "cooldowns",

        timeToReady = function ()
            return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.storm_elemental.remains, pet.primal_storm_elemental.remains )
        end,

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental" )
        end,
    },

    -- Sears the target with fire, causing $s1 Fire damage and then an additional $o2 Fire damage over $d.    Flame Shock can be applied to a maximum of $I targets.
    flame_shock = {
        id = 188389,
        cast = 0,
        cooldown = function () return talent.flames_of_the_cauldron.enabled and 4.5 or 6 end,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,

        cycle = "flame_shock",
        min_ttd = function () return debuff.flame_shock.duration * 0.3 end,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_fire.up then
                removeBuff( "fusion_of_elements_fire" )
                class.abilities.elemental_blast.handler()
            end

            if talent.magma_chamber.enabled then addStack( "magma_chamber" ) end

            if buff.surge_of_power.up then
                active_dot.surge_of_power_debuff = min( active_enemies, active_dot.flame_shock + 1 )
                removeBuff( "surge_of_power" )
            end

            -- TODO: should also gain on every tick of damage.
            if talent.searing_flames.enabled then gain( talent.searing_flames.rank, "maelstrom" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Imbue your $?s33757[off-hand ][]weapon with the element of Fire for $319778d, causing each of your attacks to deal ${$max(($<coeff>*$AP),1)} additional Fire damage$?s382027[ and increasing the damage of your Fire spells by $382028s1%][].
    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        startsCombat = false,
        nobuff = "flametongue_weapon",

        handler = function ()
            applyBuff( "flametongue_weapon" )
            if talent.improved_flametongue_weapon.enabled then applyBuff( "improved_flametongue_weapon" ) end
        end,
    },

    -- Talent: Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = true,
        nobuff = "icefury",
        texture = 135849,

        bind = "icefury",

        handler = function ()
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            applyDebuff( "target", "frost_shock" )

            if talent.encasing_cold.enabled then applyDebuff( "target", "encasing_cold" ) end

            if talent.flux_melting.enabled then applyBuff( "flux_melting" ) end

            if buff.icefury_dmg.up then
                gain( buff.primal_fracture.up and 15 or 10, "maelstrom" )
                removeStack( "icefury_dmg", 1 )

                if talent.electrified_shocks.enabled then
                    applyDebuff( "target", "electrified_shocks" )
                    active_dot.electrified_shocks = min( true_active_enemies, active_dot.electrified_shocks + 2 )
                end
            end

            if buff.surge_of_power.up then
                applyDebuff( "target", "surge_of_power_debuff" )
                removeBuff( "surge_of_power" )
            end

            if talent.flux_melting.enabled then
                applyBuff( "flux_melting" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Turn into a Ghost Wolf, increasing movement speed by $?s382215[${$s2+$382216s1}][$s2]% and preventing movement speed from being reduced below $s3%.
    ghost_wolf = {
        id = 2645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "ghost_wolf" )
            if talent.spirit_wolf.enabled then applyBuff( "spirit_wolf" ) end
        end,
    },

    -- Talent: Purges the enemy target, removing $m1 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "nature",

        spend = 0.024,
        spendType = "mana",

        talent = "greater_purge",
        startsCombat = function()
            if talent.elemental_equilibrium.enabled then return false end
            return true
        end,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            if buff.fusion_of_elements_nature.up then -- ???
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end
        end,
    },


    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        pvptalent = "grounding_totem",
        startsCombat = false,
        texture = 136039,

        handler = function ()
            summonTotem( "grounding_totem" )
        end,
    },

    -- Talent: A gust of wind hurls you forward.
    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "nature",

        talent = "gust_of_wind",
        startsCombat = false,

        toggle = "interrupts",

        handler = function () end,
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = 1,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        recharge = 30,
        gcd = "totem",

        spend = 0.05,
        spendType = "mana",

        talent = "healing_stream_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "healing_stream_totem" )
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if conduit.swirling_currents.enabled or talent.swirling_currents.enabled then applyBuff( "swirling_currents" ) end
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.surging_currents.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.surging_currents.up ) and 0 or 0.1 end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" )
            elseif buff.natures_swiftness.up then removeBuff( "natures_swiftness" )
            elseif buff.surging_currents.up then removeBuff( "surging_currents" ) end
            removeBuff( "echoing_shock" )

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if buff.swirling_currents.up then removeStack( "swirling_currents" ) end
        end,
    },

    -- Talent: Transforms the enemy into a frog for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex = {
        id = 51514,
        cast = 1.7,
        cooldown = function () return 30 - 15 * talent.voodoo_mastery.rank end,
        gcd = "spell",
        school = "nature",

        talent = "hex",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hex" )
            if talent.enfeeblement.enabled then applyDebuff( "target", "enfeeblement" ) end
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,

        copy = { 210873, 211004, 211010, 211015, 269352, 277778, 277784, 309328 }
    },

    -- Talent: Hurls frigid ice at the target, dealing $s1 Frost damage and causing your next $n Frost Shocks to deal $s2% increased damage and generate $343725s7 Maelstrom.    |cFFFFFFFFGenerates $343725s8 Maelstrom.|r
    icefury = {
        id = 210714,
        cast = 2,
        cooldown = 30,
        gcd = "spell",
        school = "frost",

        spend = 0.03,
        spendType = "mana",

        talent = "icefury",
        startsCombat = true,
        buff = "icefury",
        texture = 135855,

        bind = "frost_shock",

        handler = function ()
            removeBuff( "icefury" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            applyBuff( "icefury_dmg", nil, 2 )
            gain( 25 * ( buff.primal_fracture.up and 1.5 or 1 ), "maelstrom" )

            if talent.fusion_of_elements.enabled then
                applyBuff( "fusion_of_elements_fire" )
                applyBuff( "fusion_of_elements_nature" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Unleashes a blast of superheated flame at the enemy, dealing $s1 Fire damage and then jumping to additional nearby enemies. Damage is increased by $s2% after each jump. Affects $x1 total targets.  ; Generates $343725s5 Maelstrom per target hit.
    lava_beam = {
        id = 114074,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.stormkeeper.up or buff.arc_discharge.up then return 0 end
            return 2 - ( 0.25 * talent.unrelenting_calamity.rank )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        startsCombat = true,
        texture = 236216,

        buff = "ascendance",
        bind = "chain_lightning",

        handler = function ()
            gain( ( buff.stormkeeper.up and 3 or 2 ) * min( ( level > 42 and 5 or 3 ) + ( buff.surge_of_power.up and 1 or 0 ), true_active_enemies ), "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeStack( "stormkeeper" )
            removeStack( "arc_discharge" )
            removeBuff( "surge_of_power" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_fire.up then
                removeBuff( "fusion_of_elements_fire" )
                class.abilities.elemental_blast.handler()
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[    |cFFFFFFFFGenerates $343725s3 Maelstrom.|r][]
    lava_burst = {
        id = 51505,
        cast = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.lava_surge.up ) and 0 or ( 2 * haste ) end,
        charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
        cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
        recharge = function () return talent.echo_of_the_elements.enabled and ( buff.ascendance.up and 0 or ( 8 * haste ) ) or nil end,
        gcd = "spell",
        school = "fire",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.025 end,
        spendType = "mana",

        talent = "lava_burst",
        notalent = function()
            if state.spec.enhancement then return "elemental_blast" end
        end,
        startsCombat = true,

        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeBuff( "windspeakers_lava_resurgence" )
            removeBuff( "lava_surge" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "flux_melting" )
            removeStack( "molten_charge" )
            removeBuff( "echoing_shock" )

            gain( ( 10 + ( talent.flow_of_power.rank * 2 ) ) * ( buff.primal_fracture.up and 1.5 or 1 ), "maelstrom" )

            if buff.fusion_of_elements_fire.up then
                removeBuff( "fusion_of_elements_fire" )
                class.abilities.elemental_blast.handler()
            end

            if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

            if talent.rolling_magma.enabled and talent.primordial_wave.enabled then
                reduceCooldown( "primordial_wave", 0.5 )
            end

            if talent.surge_of_power.enabled then
                gainChargeTime( "fire_elemental", 4 )
                gainChargeTime( "storm_elemental", 4 )
                removeBuff( "surge_of_power" )
            end

            if buff.primordial_wave.up then
                if state.spec.elemental and talent.splintered_elements.enabled then
                    if buff.splintered_elements.down then stat.haste = state.haste + 0.1 * active_dot.flame_shock end
                    applyBuff( "splintered_elements", nil, active_dot.flame_shock )
                end

                if set_bonus.tier31_4pc > 0 then
                    applyBuff( "molten_charge", nil, 2 )
                end
            end
            removeBuff( "primordial_wave" )

            if talent.rolling_magma.enabled then
                reduceCooldown( "primordial_wave", 0.2 * talent.rolling_magma.rank )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        impact = function ()
            if set_bonus.tier31_4pc > 0 then applyDebuff( "target", "molten_slag" ) end
        end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    lightning_bolt = {
        id = 188196,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.03 * min( 10, buff.wind_gust.stacks ) )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
                * ( 1 - 0.25 * buff.volcanic_surge.stack )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        nobuff = "tempest",

        handler = function ()
            removeBuff( "tempest" )

            local ms = 6 + ( 2 * talent.flow_of_power.rank )
            local overload = 2

            ms = ms + ( buff.stormkeeper.up and overload or 0 ) + ( buff.surge_of_power.up and ( 2 * overload ) or 0 ) + ( buff.power_of_the_maelstrom.up and overload or 0 )
            ms = ms * ( buff.primal_fracture.up and 1.5 or 1 )

            gain( ms, "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )
            removeBuff ( "volcanic_surge" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if buff.stormkeeper.up then
                removeStack( "stormkeeper" )
                if set_bonus.tier30_4pc > 0 then applyBuff( "primal_fracture" ) end
            end

            if pet.storm_elemental.up or buff.lesser_storm_elemental.up then
                addStack( "wind_gust" )
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end

            if talent.arc_discharge.enabled and active_enemies > 1 then
                addStack( "arc_discharge", nil, 3 )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "tempest",
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    tempest = {
        id = 452201,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.03 * min( 10, buff.wind_gust.stacks ) )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
                * ( 1 - 0.25 * buff.volcanic_surge.stack )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        buff = "tempest",

        handler = function ()
            removeBuff( "tempest" )

            local ms = 6 + ( 2 * talent.flow_of_power.rank )
            local overload = 2

            ms = ms + ( buff.stormkeeper.up and overload or 0 ) + ( buff.surge_of_power.up and ( 2 * overload ) or 0 ) + ( buff.power_of_the_maelstrom.up and overload or 0 )
            ms = ms * ( buff.primal_fracture.up and 1.5 or 1 )

            gain( ms, "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )
            removeBuff ( "volcanic_surge" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if buff.stormkeeper.up then
                removeStack( "stormkeeper" )
                if set_bonus.tier30_4pc > 0 then applyBuff( "primal_fracture" ) end
            end

            if pet.storm_elemental.up or buff.lesser_storm_elemental.up then
                addStack( "wind_gust" )
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end

            if talent.arc_discharge.enabled and active_enemies > 1 then
                addStack( "arc_discharge", nil, 3 )
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "lightning_bolt"
    },

    -- Talent: Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    lightning_lasso = {
        id = 305483,
        cast = 5,
        channeled = true,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "lightning_lasso",
        startsCombat = true,

        start = function ()
            applyDebuff( "target", "lightning_lasso" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = 305485
    },

    -- Surround yourself with a shield of lightning for $d.    Melee attackers have a $h% chance to suffer $192109s1 Nature damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].    $?s383010[The Shaman can have up to two Elemental Shields active on them.][Only one Elemental Shield can be active on the Shaman at a time.]
    lightning_shield = {
        id = 192106,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        startsCombat = false,

        readyTime = function () return buff.lightning_shield.remains - 120 end,

        handler = function ()
            applyBuff( "lightning_shield" )
            if not talent.elemental_orbit.enabled then removeBuff( "earth_shield" ) end
        end,
    },

    -- Talent: Summons a totem at the target location that erupts dealing $383061s1 Fire damage and applying Flame Shock to $383061s2 enemies within $383061A1 yards. Continues hurling liquid magma at a random nearby target every $192226t1 sec for $d, dealing ${$192231s1*(1+($137040s3/100))} Fire damage to all enemies within $192223A1 yards.
    liquid_magma_totem = {
        id = 192222,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "fire",

        spend = 0.035,
        spendType = "mana",

        talent = "liquid_magma_totem",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "liquid_magma_totem" )
            applyDebuff( "target", "flame_shock" )
            active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 2 )
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    --[[ Passive in 10.0.5 -- Talent: Summons a totem at your feet for $d that restores $381931s1 mana to you and $s1 allies nearest to the totem within $?s382201[${$s2*(1+$382201s3/100)}][$s2] yards when you cast $?!s137041[Lava Burst][]$?s137039[ or Riptide][]$?s137041[Stormstrike][].    Allies can only benefit from one Mana Spring Totem at a time, prioritizing healers.
    mana_spring_totem = {
        id = 381930,
        cast = 0,
        cooldown = function () return 45 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "mana_spring_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "mana_spring_totem" )
        end,
    }, ]]

    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        talent = "natures_swiftness",
        notalent = "ancestral_swiftness",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "natures_swiftness",

        handler = function ()
            applyBuff( "natures_swiftness" )
        end,
    },

    -- Talent: Summons a totem at your feet that removes $383015s1 poison effect from a nearby party or raid member within $383015a yards every $383014t1 sec for $d.
    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = function () return 45 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "poison_cleansing_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "poison_cleansing_totem" )
        end,
    },

    -- An instant weapon strike that causes $s1 Physical damage.
    primal_strike = {
        id = 73899,
        cast = 0,
        charges = 0,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",
        school = "physical",

        spend = 0.094,
        spendType = "mana",

        notalent = "stormstrike",
        startsCombat = true,

        handler = function ()
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Blast your target with a Primordial Wave, dealing $375984s1 Shadow damage and apply Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave = {
        id = function() return talent.primordial_wave.enabled and 375982 or 326059 end,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        spend = 0.03,
        spendType = "mana",

        talent = function()
            if covenant.necrolord then return end
            return "primordial_wave"
        end,
        startsCombat = true,

        velocity = 30,

        handler = function ()
            removeBuff( "echoing_shock" )
            -- applyDebuff( "target", "flame_shock" )
            applyBuff( "primordial_wave" )

            if talent.primordial_surge.enabled then
                applyBuff( "lava_surge" )
                state:QueueAuraEvent( "primordial_surge", TriggerHeatWave, query_time + 3, "AURA_PERIODIC" )
                state:QueueAuraEvent( "primordial_surge", TriggerHeatWave, query_time + 6, "AURA_PERIODIC" )
                state:QueueAuraEvent( "primordial_surge", TriggerHeatWave, query_time + 9, "AURA_PERIODIC" )
                state:QueueAuraEvent( "primordial_surge", TriggerHeatWave, query_time + 12, "AURA_PERIODIC" )
            end

            if set_bonus.tier31_2pc > 0 and state.spec.elemental then
                applyBuff( "elemental_blast_critical_strike", 10 )
                applyBuff( "elemental_blast_haste", 10 )
                applyBuff( "elemental_blast_mastery", 10 )
            end
        end,

        impact = function ()
            applyDebuff( "target", "flame_shock" )
        end,

        copy = { 326059, 375982 }
    },

    -- Talent: Removes all movement impairing effects and increases your movement speed by $58875s1% for $58875d.
    spirit_walk = {
        id = 58875,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "physical",

        talent = "spirit_walk",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spirit_walk" )
        end,
    },

    -- Talent: Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    spiritwalkers_grace = {
        id = 79206,
        cast = 0,
        cooldown = function () return 120 - 30 * talent.graceful_spirit.rank end,
        gcd = "spell",
        school = "nature",

        spend = 0.141,
        spendType = "mana",

        talent = "spiritwalkers_grace",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spiritwalkers_grace" )
        end,
    },

    -- Talent: Summons a totem at your feet for $d that grants $383018s1% physical damage reduction to you and the $s1 allies nearest to the totem within $?s382201[${$s2*(1+$382201s3/100)}][$s2] yards.
    stoneskin_totem = {
        id = 383017,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "stoneskin_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "stoneskin_totem" )
            applyBuff( "stoneskin" )
        end,
    },

    -- Talent: Calls forth a Greater Storm Elemental to hurl gusts of wind that damage the Shaman's enemies for $157299d.    While the Storm Elemental is active, each time you cast Lightning Bolt or Chain Lightning, the cast time of Lightning Bolt and Chain Lightning is reduced by $263806s1%, stacking up to $263806u times.
    storm_elemental = {
        id = 192249,
        cast = 0,
        charges = 1,
        cooldown = 150,
        recharge = 150,
        gcd = "spell",
        school = "nature",

        talent = "storm_elemental",
        startsCombat = false,

        toggle = "cooldowns",

        timeToReady = function ()
            return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.fire_elemental.remains, pet.primal_fire_elemental.remains )
        end,

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )
        end,
    },

    -- Talent: Charge yourself with lightning, causing your next $n Chain Lightnings to deal $s2% more damage and be instant cast.
    stormkeeper = {
        id = 191634,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        talent = "stormkeeper",
        startsCombat = false,
        texture = 839977,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "stormkeeper", nil, 2 )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end
        end,
    },

    -- Imbue your shield with the element of Lightning for $d, giving Lightning Bolt and Chain Lightning a chance to call down $s1 Thunderstrikes on your target for $462763s1 Nature damage.
    thunderstrike_ward = {
        id = 462757,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        talent = "thunderstrike_ward",
        startsCombat = false,
        equipped = "shield",
        nobuff = "thunderstrike_ward",

        handler = function()
            -- TODO: Check if we need to use Imbue system instead.
            applyBuff( "thunderstrike_ward" )
        end,
    },

    -- Talent: Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = function () return 30 - 5 * talent.thundershock.rank end,
        gcd = "spell",
        school = "nature",

        talent = "thunderstorm",
        startsCombat = true,

        handler = function ()
            removeBuff( "echoing_shock" )
            applyDebuff( "target", "thunderstorm" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Relocates your active totems to the specified location.
    totemic_projection = {
        id = 108287,
        cast = 0,
        cooldown = 10,
        gcd = "off",
        school = "nature",

        talent = "totemic_projection",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_recall = {
        id = 108285,
        cast = 0,
        cooldown = function() return talent.call_of_the_elements.enabled and 120 or 180 end,
        gcd = "spell",
        school = "nature",

        talent = "totemic_recall",
        startsCombat = false,

        usable = function() return recall_totem_1 ~= nil end,

        handler = function ()
            if recall_totem_1 then setCooldown( recall_totem_1, 0 ) end
            if talent.creation_core.enabled and recall_totem_2 then setCooldown( recall_totem_2, 0 ) end
        end,
    },

    -- Talent: Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = function () return 60 - 6 * talent.totemic_surge.rank + ( conduit.totemic_surge.mod * 0.001 ) end,
        gcd = "totem",
        school = "nature",

        spend = 0.023,
        spendType = "mana",

        talent = "tremor_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tremor_totem" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d, continually granting all allies who pass within $192078s1 yards $192082s% increased movement speed for $192082d.
    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = function () return 120 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.01,
        spendType = "mana",

        talent = "wind_rush_totem",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "wind_rush_totem" )
        end,
    },

    -- Talent: Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    wind_shear = {
        id = 57994,
        cast = 0,
        cooldown = 12,
        gcd = "off",
        school = "nature",

        talent = "wind_shear",
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
            if buff.fusion_of_elements_nature.up then -- ???
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end
        end,
    },

    -- Pet Abilities
    meteor = {
        id = 117588,
        known = function () return talent.primal_elementalist.enabled and not talent.storm_elemental.enabled and fire_elemental.up end,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = true,
        texture = 1033911,

        talent = "primal_elementalist",

        usable = function () return fire_elemental.up end,
        handler = function () end,
    },

    tempest_pet = { -- TODO: Rename to Tempest (Pet) ?
        id = 157375,
        known = function () return talent.primal_elementalist.enabled and talent.storm_elemental.enabled and storm_elemental.up end,
        cast = 0,
        cooldown = 40,
        gcd = "off",

        startsCombat = true,

        talent = "primal_elementalist",

        usable = function () return storm_elemental.up end,
        handler = function () end,
    },
} )


spec:RegisterStateExpr( "funneling", function ()
    return false
    -- return active_enemies > 1 and settings.cycle and settings.funnel_damage
end )


spec:RegisterSetting( "stack_buffer", 1.1, {
    name = strformat( "%s and %s Padding", Hekili:GetSpellLinkWithTexture( spec.abilities.icefury.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.stormkeeper.id ) ),
    desc = strformat( "The default priority tries to avoid wasting %s and %s stacks with a grace period of 1.1 GCD per stack.\n\n" ..
            "Increasing this number will reduce the likelihood of wasted |W%s|w / |W%s|w stacks due to other procs taking priority, leaving you with more time to react.",
            Hekili:GetSpellLinkWithTexture( spec.abilities.icefury.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.stormkeeper.id ), spec.abilities.icefury.name,
            spec.abilities.stormkeeper.name ),
    type = "range",
    min = 1,
    max = 2,
    step = 0.01,
    width = "full"
} )

spec:RegisterSetting( "hostile_dispel", false, {
    name = strformat( "Use %s or %s", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    desc = strformat( "If checked, %s or %s can be recommended your target has a dispellable magic effect.\n\n"
        .. "These abilities are also on the Interrupts toggle by default.", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "purge_icd", 12, {
    name = strformat( "%s Internal Cooldown", Hekili:GetSpellLinkWithTexture( 370 ) ),
    desc = strformat( "If set above zero, %s cannot be recommended again until time has passed since it was last used, even if there are more "
        .. "dispellable magic effects on your target.\n\nThis feature can prevent you from being encouraged to spam your dispel endlessly against enemies "
        .. "with rapidly stacking magic buffs.", Hekili:GetSpellLinkWithTexture( 370 ) ),
    type = "range",
    min = 0,
    max = 20,
    step = 1,
    width = "full"
} )


spec:RegisterRanges( "lightning_bolt", "flame_shock", "wind_shear", "primal_strike" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    canFunnel = true,
    funnel = false,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Elemental",
} )


spec:RegisterPack( "Elemental", 20240915, [[Hekili:LZZAZTnYr(BX1wHMATffjTOw7TKCQ1ETZzF2jBz5C5dPcbbbhsHtGamaGIRUtH)2t39GbaZGzga(ss25d2scyW8OF)A6H9g(1HxoXnLn8p3VB)t7(QEd607fd637fdVm92fSHxUW17A3zWVe6oh()3fWMZctDdW3CBqK7eCgsIwg7bV9Q00fj)8jNmZp9QLJ74fn)Ke)5ldCt9Jc9IDNMI)T3jdVC8s)G0peoCS2LhMXfmp4HNb)6v(tMW4JKL4n8sCKh39Lh3BWZxpQ7RGF(ZRhDP)81JwUaNR1FC9h5J5NoU)lG391RyRh93CJH)d2x(HWwpoAQFaSH)H1JExyYYyyaRyUlIcxpIf6DLBy66r(jRh5UyrGpBc8htxp62OLp9gyKjSaMxk(0pmhMPBWF79ba4jnkC2sCTOPQZ6p66Hh8KolIzaSySB6ZU4KPfJ0HVMp3F6faefaRD8ZMqNQJQdl0DCaSwAN1KRVD6Y4B1)Ya)zxLg6hoZj5kFwGHPaqzHtyXjPX(xdlQBSPLknkE(1m2cwS(bWCJtVkBPWZ2tgVC60oLFANLlALDIzcckNO4X(P6NXBCJ9Xd)ZrIWlM7YcC8Cx88BCdwYUOx3UpBq3FmB(swXccWJkok4SenVtSB41pR)aXiwe7ppkEIVlnjUE(P3sd55rlUiH1ODqYIBN7MKYID8dD6LKMTtaix41S0o964N0jFmjacC8gpR9dNOmR91nRR)iqc)Hq4bXlxaeTraDQhmGKcQpyDw5hoba9akGg)7ikP1JaWa9)3qOaPVizHFSF6k3GRXLAwSRh75Waba7f9kpUXbrra1kq6ry6mqSBIhlCIBOhtq1E3DerqPxSCXD35fffmjAvy5NhZM76hM86bDLwhyBWIVgw)nFDkppt9Jz0EEZNMnz7IVci(isSGGd7ATmH54NYM)8KGOub1spAnf0xDujyV7U2JJssAnfLm4KnVNF6G7Ul1Fo7CPh3I2ELi8IzlIIboTuq1WfN29Ow571sIgeB2ZH5uZs1VFThH(woca3XJ6JaochqnYKYdrvmmE(OnM6l6G7KYFzOBkOJkXjzL)00qwscWg)daJ8Fnb4F)TOvGKyqiW0Lj(Ogm8FVvCEWrc6XYNk)WBIaX7SFhGdHa9jUb4IFwGZdaCZMMsl)IOuLNeVm0H)xob(G8pAcCJyph1E4LEbr(b6WdcCsDJNXa5rGwvFC0zh1x3V25lbgwalBcqrDcrOWcLXk7KR(OqrJ8ZlZ)N9Hekw3xQ8ctFkN6q5ZYizWpbG3))Vh2e)R1J(cd1Om6tF(Rak5xb8aytbifo4w(VUaOQ8jrX)9)l21(b()J1Jg7MGguGiX0y0AcbP56rCkpaQOUTsJakpFpG0uiUjNEoW)FU0FcOnC2CxhACDWPvqf)6EdA1gNSByotIs7q2DaKHrExFEB7iW)4zhDCFGBJlxtbQNjB7i1DA1Tdz9dTV0Sv5mcaafmzJ5kSZc(tCdUE0n(Ua9FU(C0kp0aTLiLdmOLWgNRsmJhbTItaZ7OU1kzxWkyAEU3TE5uFjCkAo6gNwNOPoeddjSwiCx5v5c4ZTf58Z6ECUHiSBPXMEfaWrsOQw4X3yfktkZ)dezFsGl(xMaqwHeevjALByeqJUW37A2KkqLsee6GiXSPGGPRW9Dl9qhHHEfc5IJMioQTuO5Yf5YxKoOOCGuWzIp74EN1ARjuB9K8DrfASCOUki9TGYcGD93bqVkCnnA9ORyblwpcwXucgJpkegm4FWcgAi96rtJG)7Y)7NDz0VXzOp7zW4Y2LRh95OKuusqemEauTRqEf6xe0Rr8uRnJw842V8z9fdAAq0Qku3h9J6XkTSJuUWi28mjjOc6Aux6OSZCJPYBJK58npklcCqKJNoBxa2wf41Q92jJ4OnHtWSi7ZU7odZZR7wrwmq8VaeSO78YvS5g7bRxcG6GxjuT9X)6LGyJF9VawC81NaCbzU87356BNFS3KqYRF4Gg7ZsoX3dwUtMhng82(KUD7Es3EV8KEN(tNaE1768j33WIwo1X5JltsD(1iNpK648zWyJBOagaeYxUGX8UYP9Fj2FMp(G)h)jSiNX3w8TF5p82x8hEZzHxFn)xCCC(6YyGH6iNUhFQtIxmJfcGI0o)VlQO4SW4A6S9lZqqfWcFwoFkqpfl8uQkbgmVlb)PhnM06G6Tx5Nc0NFY9gqMXByUZbIwxGRcgBkypy(Bwc(zxHimaENZy4JquqgggenmhGKi)Ib5RQEpiq4OBGoizZ(9O9wKrgohco5n5aQieytoM0H4TWuTez8RQZh)kqB285m4PPmuUAwmBaAuAexwkUf0WFoiHg3k0HafnNTjYe2eYWdDU4sUKds2UbehEK1XmzIJS)buUD9sFTkoIdTj9FC8jD44GapZiHfXrEDW)Wpnt7h)RZOUWxxJry7BizBTVi3BXmFVPvLGeW3CKK(hYflnNcesWP5o3n8wmSIZETGf5ZKxMCUPum4Jzrnnz)CCZDwfmIhMUwvpcT4YVZ8xoJ(Gj2ef2KzyacAiRA64sv8iH1AfGG4zUbrZcIgJejOTMLjAiCb5K0cMhmU35DveY(HtYFcoBP40IMsba3kGokEI)ZLUxZK83XeQEM3e7K8zKkmApGVDgUdaqA2gWHLq6XRBuJL02BCGL8qICVHfMfLzWbojPRFjAsckJfDSFzkxMnjvZfLB7feHeOi1y0nSyp3feSAVatBlzY(fDTAjFjNCEDEmBerQ94x09OhdW3cMwacsgOhaM0EmAwOK2boBCvs6Q2WVpGZ6K2VBIVFqH1fwUNttxslCfzJcPocmdsFxOwEqHAzaA)g3WRLujpzzm35lAMWLdN3FPWyO9dgQTDXP3DxnORbcQFES1WPq85o8y7vGo0yj3RaCG67a9upuy5gOxG0Asif(ytYObePoRtHJDYI648OySXMdQvlzQA5WLvfBLNePXbU61L20txMQZAaxTuLnwR4VheWswk3m4u7(dKKSJGKp4XOSxYTz89I4ypTWYjHTLkNqF(hw60uLdR4y0yEqndbj2RyC4VrMcA0CpsJDc4XQSiP9HnGGjVnZgU6SeuJGLgWFlPTenRdrZiTk55KQRJ2D0vN6pJrrrwqB(8C(zhTp2xA8pDh2DkZMypkSLqqT85c1zB(oUkKKNgNmmDrsWBsGcAzmFg719SjOS5DUX9vEabSWdwnImOWLtLmJddaf6Cp(w03v0wA0IL4jiWbJdqPWAWNGbLNaByLAmEOLbs6xFXPgj3jlk2b05FYD(ymRtURCfcD)vyayqt(sueDELf8UN8CTqQ1eA5aff4QvrQv9u52J3Lv6nBH(vuId1ed4ktrCeS2Ytr5ewkLjZNTvPUuDk2OKy(dck8LjYbcRtnlGAQoL1t8WN(t1n9ULiu7wX3Rb6f5rlcpUA08dIwcrFBq)2X6FBIisJ4HTFjJ6igY8f2cosF2uFIX0PYd2QwD(TTE4QZdNELmMRAybj7wx6DLQ5QG4u0JVkEBVOWB7YGfkGsuQkdCVLSmgG0wGoniHUwpvx0lZCWnoBoBAgFZZIEnPNKGV)IiDWamlpFWMHX03GGY39gKae0c5M5M8NUbEYQRyi9OgFiubNAsdDHGHQHEv4ZQS4Hs(zk7ZMCAyZKF8z3WLaF8TvZ8xcpZFijXywkx1)cAFNfymIqbuB4h4A)yTbz(toxfx0RvBtjTR)D3LnyLrCbgimtFvDbXSa4PoGCxZRFU1qIvz6ntgEKqOVP08xNWrz8hY6tr1uF4JjNJ9CdFkzCg3Xy08SmjgyA1hds6jTA(zLS7SiFr64lsDfs)l5BaLz(QRzsgHtAwoJ3E6g9O)ZLjHQvJt7gzUuU4dDfxODkM83Na6Lrx3PnB1zMtkaBW5JlN062MOgSY6BsOPLAESi6ZvpJnV6ouQPGQ10X8LbP(lqlsY16efkYLyQiMnRirMfLbE6vyWehdi1PuIV4(fLU9epFZtwyGQWUgHnTYioZUmhvaRfRg3QcHyRJ1qvR4eXnBCuqQPGoOhKs7eUzujvZGXNJsFhPIpmtUMHkLX2MBl9Zt3rO2yrzLqOzb8QeartkDq(0agLx7KO5mkTTYQA2z8unhIAtLWtA0XmlCxA1GTVPdnWgRnMHyqIvLhyXKY8Pq2vTCAUoCwUeNPX85Wn48ED6kjnxk58KgCMBkA4Bk4r5)hRgjXBf9DdYaF9MdPTywwLxml779S5IKOjzTJeKmMyRaYQFotCc6pBz)B)lFr(VNbimGHlJFd(nIUKM3v(yEU51ytEH1Gt(TumPWzIhvEqFAw(a4lpMSw8TLY8DPec65UylY5Nkawt(znl1AVMfU60834S01Qg)SAwgjTLbNEd28mwwpxXJq6qkJBBmrOzIlzesJPW2P8wT9OYZ(EcvU1IuSlQiZs(9dMCBru7apN8fjihBvXcxU3RCG1VXvvHp2lAozhvw1E5njZ2drzkfsUVZ88qmJFicFPi3TNLt)TTGyvVIQlyqnOI2Q3T4CQd1SgSdKh7TIyOobNgVGoYgKVzNW)EV0)rJRDPIKKLlhtdyHKRj4rqznjrOShKjYkhMk0tudG1XquinQDTEBOuZg2ViKVUx3wTJJ43V6SRlEhKP3j1376xpOW5f1bji3ebuxcdvhrO9OKHo2RGc7RGcp4YX2j6DECr3fjGMdKu77fPihaSAr22AGa26KONiCY5xJOqjVc5hkv1r01agG9SBWaLiQPqTLSJk8VubiTxkViUpAzZA29tUFrY5mwCt619ZdsavvdsLXVSrwhkpnvUe(LSiKhFgEn4Yz20ue9G9HhGDwAtIUsTrQQb2u9E34egl(K3DzHwtETDxUssYIVbhLWViGCXgZWeNhfYwx9ERuCxCEGIJxfdAIboN4XQbQRKSPIxH3n)EDZimZLqVVkJ9Vtnq0AHucQDLBmbdQCNcmaE3flTQZlfLT0oVJSRNBJ3n7AmqlsOzUwKCJfxX1YGNRvX(OMg9v0koZj3J6wQSNpwin59y9lLNimxXvfSNWMfE(sZpGfUypdfyr3)h(DDMYiljCxjJR2YfwPINsaVZo6otMpJCBUH1PHEd)1Nwjo0qeJyYCElv5in)MpdBEjnwR4dnNO96w2aL(wueMV3hlmdEve(L3vTGb3xQIYWN1v6G)a)Mls2Wv9YQIAosxfvUSIsexcw20P(E(Kz(z3L1IV7naqAZia2Am879dcqKknbGsWFjyL7TjsvZs(ZiK(4O0ueJdUCz1yojmEZso9gxqKnAYqj2IUo1eFWkxWgXxZV3)YIIqCdzLOy4y9ZHqNgkprSIdVeegJcgZA0CVS)GHxUYngHgjdVK6qC(ZXEcugH8tZBtxpfl(iWZNyuMhM0qarSea3UuQ)b0A4m8Uj9Xp5JgRD2ptj2bwn61pTIQDQlN9uU0tdVvqkdJQDVF)O85(LQZDSX2nw(cKnKu9JrA6FLHPxtFhRY0RFmzt)6p(bc0IZ6PRZ6fri1kVnLn8s63W(iOBed(XFM6kHzaHHVz4LEOwuqT(WlFsMyTkfkl8T00o8s5xnmfW41oDvRz2I5t5D4e(IMnH5C1ktg)54eDQYejgMCzSYB8HX(l4V8axCTLponT4zxpcCBR3G1JAbiDr4vuR9jWjp6TwLlcZ0FK6rbhTE0Xu5FE3DIkVXK7wJocHLdmIuS2DHka6vhaoTNzafPepfy9klGePHlTdmydjD2Es(XZWvXNgvP8raqXZ6sqhaG)J5FTPAlvH65a0iLqW0prSVzWgnvkAzyim8xAaQwICXoeTSUhKQZeeUvo8rksNfaxyagS4GG08vVC3xHG89oJ(Y9eHERYubMdZMQCGdr7FcroV6GGC0u3bfiozJGWNV9e80ibW)lxp6zKeKIprBdmIqb)OzKzR6XKxqys7eeNzd9Dp3QPqSCVU7B0CnsP56g2nrHhTTmSnr30z8DHXzh0X1fv2OxD8bQrvrOkvdIYTtGx4I6SarTKf1GkXzw12iPJ230T6PsQJYJdnDKvTElx)V4sMPaf2BDoPM1uOkJmZiwZ7lrfcASOVtn27LPFZVJCeKWK5Nkc4ouWJnPtsTlqf6SQAEOmwhxd7c7SjvO)dIwUnrVKvXQk43hlnzlcTzY877h0wBdVUScNt5AnOXjvcOvvvCF0qTiO2pDOGATkCzKx6RfGqLZo3Mw6ngtJwzsZAQQ7ATVWGw59B77IaUM8DPixtQcm9U3AswADE3g17mVjaO)3RxiHe)qD5AVGJOM0OPA3xTjllZz)EM8rXis4bQdBvgH0U0L6fDcD9OlilkR1hvLaaaeQvYYfP44fDfwi)Obr13Kxg1HOEOAvxvdBtvT27h1UpYquM8XWiI6BY(8Lc)yD6NqyzdW2du57SLO2s4sdwP)QCKO6OiRkE8q40a1YiPLQtM5KwYLzGDBsA(2QKPh1EM5qsTIL3iPUk8gh4g9fbvn5hBPsL4(fIM8Toe1K)WzvJGUDuJ7CzAa8MRMpbeFdfNyU2pec5p8Eb3CZ5BM7bgecwRCh96Q2Qg2gb5S7iA1OgTH3o4My2rnrpnrFVIseAtobGjpdThYNh6dtfLULpsM8hZeMzN6LzvoAgRxMcpJRlwCs05kzogpGM81Xoo7(8yAEZ)ct2)Bc78iPJUTH2jwXPGsSFObINwdlQKrK7dIMxyYC(9UKE7LJLc2DlA8C0PXCjC0iGLoYoCAFr5SwxHDQy9WXsghWRNicuXFRt2t2X8NPUydA8IvuStYZbGELkmQHFdwxnsdnRQzuYqL(UANU9svdimZ989yD5uNBSu5(wRzvPvl0MCwRQ1pJgdM33nhpfuDnT(UAmPSDnh)gzBchss2MSxkEOAwUlOLl3hGTo167wvgjvNwnUewEi6xGiEXKvWAlCPQ74dBh4tNWlD5NQCiIunWwjuoYXzPmZ8EVqSuto7fc5kTTx3gzv6x2NxP8m4bq4OMmt1N3dzOJHwG1MUAM7REQlOLUuwr1GzIzUwj06vkT)6KIivZoxHyMqZNxLaAduD1UHgLkjSQAZrt61gPokng9njnPHOTrPvIeZogVb842eRBPV6vnhu6GhBDnk(TylFKYV4oxCC)hanRfc2MPxA7RYVZ2AbH3x9(rIk6(RU9kmcV8D85Whgp90a0w0ED2TpIaHPnvJJSCn0HTkXkylC2kG5DVDmsWptoHAffVlD(WMGVBeqRbbmtwqqDzlGxZhMD80gnVwj(BkHVvHCgtnHUMHiDsu9luNN9Uw6bIKmWED6wYZf5AC9XrbGTnYNBs3CKoI2d7)oCeRRYanfWAdTXrAZUXLR03t9oTTO0mQt8rRdwbq0u72EIexEJYFUDVX38siPjPshd(xoayhk3e7SYP2k0l5J7JF68TQDpULeV1JKnnS8e7VpPeoBVqjyTsYe(o9yNkyBL2DWie2x449d3UXs6YOcTnRjcU)6nBBUYNV31SOZP86dA6gxS4njCrkeCQ5lSmfNXYDtv)s9xe7QU1uZ6VtKYhYktZIi1VTAPLk8Fn0dsTvz4rsEPiHTLslAxbtHXoAjnUbQoRAO3wslCUebvASMqMtdPbz7JOim5mCJR(Z2pGm9hCWKA2SBSK06eNNu1bWVR78OeTMP0yRVUy32MSPs0qBULr1AICPYQsQZAsSt9fIbeg9yPQCTz4ebPoyXDroOesRTAaVQTDFs70dF4tsBwS9A1041UnrtQXnAucMykkn7pysn2FuylJCh1uAmv7QM8xtffigxWUvagpeTIuQGU22B)1U3tq)ped6BIxHViZegPMGjrQmitULXQfDJmUUj7LEM3lBkLaTXT6hAtmd6HytBU)HXLpujDAMs1rQOUuBSY59sll9aQPMosMSTvQyxnESUp7QPvWDYnUubxAdmQ3IrX1B4nhSzYmn73tGnRFIw5aB)IbSbIi1C0PtLrtQSL1Vd6HYYM9EZQQnQQ713GwPn82D3sou9x1HBrb0ygBCQQ1hkaLDPlRAtK8PK20gv9(nTAImFvbovvdyLfRKUo1EUkpO)g2pfhaCzu1zvzzKbUnSlUAq2E5LMyTN6Umq7vyqAv)qiCqJxUiLZRJx)JKslXk)WjWkaMgqw7VrhO3rVvqiNdilM8Kf(aCELBW1y)pDwSRhtbeATRHMXwBQWU05XPuyBneS)bLkrGXbrrtCiBcsREfh2TDtPvbo(S4RXJDQTMY52SkB(zgnSGo34MXCvxC)SzWxYRUC62JKAUo0Z6RU9u2J5wNM3PDDaHI9qonCVG2HfHvIElDMQEAMrS5(jQmKCVtl6IVXmST9wkwjN2WWREEEytTSH63h4AcIslDCtnxq6zJPFJaj9dN89biPpcsmPJg)ohqp6eXhv8GunLWQInof6TsUYNfmPs3Wv(10ussFfJGBBFIXE8kVgffJEre)NYdXSmX6v)JWkam5Ls6kfRt8Yqh(V7GTvAEZLg8dHUeGr277D2(w5lthPwkVfHRtXKKk10OWzlzoRyUlWNPOzjHs0m)Ly3nboSOkskCXlwe4ZMK7LYtXagxu8PFyoyk3nKVoflZ6r)nAQ01Yb8Z(aNQBlPKTvgZLC9TChjLqDsxDYkelk2OuESzPnbrDxdRTBS6OhiT4f8skdZQ0CEqCYIbarDBkqBsDC9HvIFGG0xvsDeOYlbieY)aHGi83cwc)Ox3UudODq3Y3FQKvmE2Jk8QiMA2nyRQv6MwvkNmEUlC98tVLgkTuzeLIOuOtWz97qBnh(YRIQ2gDYK2GvttVI34Q1NKLrCBUltVkcicU0F(YaQPH(2y3P8xo8F)d]] )