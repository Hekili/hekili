-- ShamanElemental.lua
-- January 2025

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
    amplification_core          = {  94874, 445029, 1 }, -- While Surging Totem is active, your damage and healing done is increased by 3%.
    ancestral_wolf_affinity     = { 103610, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    arctic_snowstorm            = { 103619, 462764, 1 }, -- Enemies within 10 yds of your Frost Shock are snared by 30%.
    ascending_air               = { 103607, 462791, 1 }, -- Wind Rush Totem's cooldown is reduced by 30 sec and its movement speed effect lasts an additional 2 sec.
    astral_bulwark              = { 103611, 377933, 1 }, -- Astral Shift reduces damage taken by an additional 20%.
    astral_shift                = { 103616, 108271, 1 }, -- Shift partially into the elemental planes, taking 40% less damage for 12 sec.
    brimming_with_life          = { 103582, 381689, 1 }, -- Maximum health increased by 10%, and while you are at full health, Reincarnation cools down 75% faster. 
    call_of_the_elements        = { 103592, 383011, 1 }, -- Reduces the cooldown of Totemic Recall by 60 sec.
    capacitor_totem             = { 103579, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after 2 sec, stunning all enemies within 9 yards for 3 sec.
    chain_heal                  = { 103588,   1064, 1 }, -- Heals the friendly target for 239,026, then jumps up to 15 yards to heal the 3 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_lightning             = { 103583, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing 128,877 Nature damage and then jumping to additional nearby enemies. Affects 5 total targets. Generates 2 Maelstrom per target hit.
    cleanse_spirit              = { 103608,  51886, 1 }, -- Removes all Curse effects from a friendly target.
    creation_core               = { 103592, 383012, 1 }, -- Totemic Recall affects an additional totem.
    earth_elemental             = { 103585, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for 1 min. While this elemental is active, your maximum health is increased by 15%.
    earth_shield                = { 103596,    974, 1 }, -- Protects the target with an earthen shield, increasing your healing on them by 20% and healing them for 64,719 when they take damage. This heal can only occur once every 3 sec. Maximum 9 charges. Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.
    earthgrab_totem             = { 103617,  51485, 1 }, -- Summons a totem at the target location for 30 sec. The totem pulses every 2 sec, rooting all enemies within 9 yards for 6 sec. Enemies previously rooted by the totem instead suffer 50% movement speed reduction.
    earthsurge                  = {  94881, 455590, 1 }, -- Allies affected by your Earthen Wall Totem, Ancestral Protection Totem, and Earthliving effect receive 15% increased healing from you.
    elemental_orbit             = { 103602, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1. You can have Earth Shield on yourself and one ally at the same time.
    elemental_resistance        = { 103601, 462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by 6% for 3 sec.
    elemental_warding           = { 103597, 381650, 1 }, -- Reduces all magic damage taken by 6%.
    encasing_cold               = { 103619, 462762, 1 }, -- Frost Shock snares its targets by an additional 10% and its duration is increased by 2 sec.
    enhanced_imbues             = { 103606, 462796, 1 }, -- The effects of your weapon and shield imbues are increased by 30%.
    fire_and_ice                = { 103605, 382886, 1 }, -- Increases all Fire and Frost damage you deal by 3%.
    frost_shock                 = { 103604, 196840, 1 }, -- Chills the target with frost, causing 101,941 Frost damage and reducing the target's movement speed by 50% for 6 sec. Generates 3 Maelstrom.
    graceful_spirit             = { 103626, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by 30 sec and increases your movement speed by 20% while it is active.
    greater_purge               = { 103624, 378773, 1 }, -- Purges the enemy target, removing 2 beneficial Magic effects.
    guardians_cudgel            = { 103618, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind                = { 103591, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem        = { 103590,   5394, 1 }, -- Summons a totem at your feet for 18 sec that heals an injured party or raid member within 46 yards for 96,643 every 1.9 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    hex                         = { 103623,  51514, 1 }, -- Transforms the enemy into a frog for 6 sec. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    imbuement_mastery           = {  94871, 445028, 1 }, -- Increases the duration of your Earthliving effect by 3 sec. 
    jet_stream                  = { 103607, 462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by 10% and now removes snares.
    lava_burst                  = { 103598,  51505, 1 }, -- Hurls molten lava at the target, dealing 182,153 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock. Generates 8 Maelstrom.
    lightning_lasso             = { 103589, 305483, 1 }, -- Grips the target in lightning, stunning and dealing 482,880 Nature damage over 5 sec while the target is lassoed. Can move while channeling.
    lively_totems               = {  94882, 445034, 1 }, -- When you summon a Healing Tide Totem, Healing Stream Totem, Cloudburst Totem, Mana Tide Totem, or Spirit Link Totem you cast a free instant Chain Heal at 100% effectiveness.
    mana_spring                 = { 103587, 381930, 1 }, -- Your Lava Burst casts restore 1,750 mana to you and 4 allies nearest to you within 40 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury                = { 103622, 381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by 4%.
    natures_guardian            = { 103613,  30884, 1 }, -- When your health is brought below 35%, you instantly heal for 20% of your maximum health. Cannot occur more than once every 45 sec.
    natures_swiftness           = { 103620, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    oversized_totems            = {  94859, 445026, 1 }, -- Increases the size and radius of your totems by 15%, and the health of your totems by 30%.
    oversurge                   = {  94874, 445030, 1 }, -- Surging Totem deals 50% more damage during Ascendance.
    planes_traveler             = { 103611, 381647, 1 }, -- Reduces the cooldown of Astral Shift by 30 sec.
    poison_cleansing_totem      = { 103609, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within 34 yards every 1.5 sec for 9 sec.
    primordial_bond             = { 103612, 381764, 1 }, -- While you have an elemental active, your damage taken is reduced by 5%.
    pulse_capacitor             = {  94866, 445032, 1 }, -- Increases the healing done by Surging Totem by 25%.
    purge                       = { 103624,    370, 1 }, -- Purges the enemy target, removing 1 beneficial Magic effect.
    reactivity                  = {  94872, 445035, 1 }, -- Your Healing Stream Totems now also heals a second ally at 50% effectiveness. Cloudburst Totem stores 25% additional healing.
    refreshing_waters           = { 103594, 378211, 1 }, -- Your Healing Surge is 30% more effective on yourself. 
    seasoned_winds              = { 103628, 355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by 15% for 18 sec. Stacks up to 2 times.
    spirit_walk                 = { 103591,  58875, 1 }, -- Removes all movement impairing effects and increases your movement speed by 60% for 8 sec.
    spirit_wolf                 = { 103581, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain 5% increased movement speed and 5% damage reduction every 1 sec, stacking up to 4 times.
    spiritwalkers_aegis         = { 103626, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for 5 sec.
    spiritwalkers_grace         = { 103584,  79206, 1 }, -- Calls upon the guidance of the spirits for 15 sec, permitting movement while casting Shaman spells. Castable while casting. Increases movement speed by 20%.
    static_charge               = { 103618, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by 5 sec for each enemy it stuns, up to a maximum reduction of 20 sec.
    stone_bulwark_totem         = { 103629, 108270, 1 }, -- Summons a totem at your feet that grants you an absorb shield preventing 2.4 million damage for 15 sec, and an additional 248,338 every 5 sec for 30 sec.
    supportive_imbuements       = {  94866, 445033, 1 }, -- Learn a new weapon imbue, Tidecaller's Guard.  Tidecaller's Guard Imbue your shield with the element of Water for 1 |4hour:hrs;. Your healing done is increased by 2.0% and the duration of your Healing Stream Totem and Cloudburst Totem is increased by 3.0 sec. 
    surging_totem               = {  94877, 444995, 1 }, -- Summons a totem at the target location that creates a Tremor immediately and every 5.6 sec for 18,558 Flamestrike damage. Damage reduced beyond 5 targets. Lasts 24 sec.
    swift_recall                = {  94859, 445027, 1 }, -- Successfully removing a harmful effect with Tremor Totem or Poison Cleansing Totem, or controlling an enemy with Capacitor Totem or Earthgrab Totem reduces the cooldown of the totem used by 5 sec. Cannot occur more than once every 20 sec per totem.
    thunderous_paws             = { 103581, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional 25% for the first 3 sec. May only occur once every 20 sec.
    thundershock                = { 103621, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by 5 sec.
    thunderstorm                = { 103603,  51490, 1 }, -- Calls down a bolt of lightning, dealing 10,145 Nature damage to all enemies within 10 yards, reducing their movement speed by 40% for 5 sec, and knocking them upward. Usable while stunned.
    totemic_coordination        = {  94881, 445036, 1 }, -- Chain Heals from Lively Totem and Totemic Rebound are 25% more effective.
    totemic_focus               = { 103625, 382201, 1 }, -- Increases the radius of your totem effects by 15%. Increases the duration of your Earthbind and Earthgrab Totems by 10 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, and Wind Rush Totems by 3.0 sec.
    totemic_projection          = { 103586, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_rebound             = {  94890, 445025, 1 }, -- Chain Heal now jumps to a nearby totem within 23 yards once it reaches its last target, causing the totem to cast Chain Heal on an injured ally within 30 yards for 103,474. Jumps to 2 nearby targets within 23 yards.
    totemic_recall              = { 103595, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge               = { 103599, 381867, 1 }, -- Reduces the cooldown of your totems by 6 sec.
    traveling_storms            = { 103621, 204403, 1 }, -- Thunderstorm now can be cast on allies within 40 yards, reduces enemies movement speed by 60%, and knocks enemies 25% further.
    tremor_totem                = { 103593,   8143, 1 }, -- Summons a totem at your feet that shakes the ground around it for 13 sec, removing Fear, Charm and Sleep effects from party and raid members within 34 yards.
    voodoo_mastery              = { 103600, 204268, 1 }, -- Your Hex target is slowed by 70% during Hex and for 6 sec after it ends. Reduces the cooldown of Hex by 15 sec.
    whirling_elements           = {  94879, 445024, 1 }, -- Elemental motes orbit around your Surging Totem. Your abilities consume the motes for enhanced effects. Water: Air: The cast time of your next healing spell is reduced by 40%. Earth: Your next Chain Heal applies Earthliving at 150% effectiveness to all targets hit.
    wind_barrier                = {  94891, 445031, 1 }, -- If you have a totem active, your totem grants you a shield absorbing 513,311 damage for 30 sec every 30 sec.
    wind_rush_totem             = { 103627, 192077, 1 }, -- Summons a totem at the target location for 18 sec, continually granting all allies who pass within 11 yards 40% increased movement speed for 5 sec.
    wind_shear                  = { 103615,  57994, 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for 2 sec.
    winds_of_alakir             = { 103614, 382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by 10%. When you have 3 or more totems active, your movement speed is increased by 15%.

    -- Elemental
    aftershock                  = {  81000, 273221, 1 }, -- Earth Shock, Elemental Blast, and Earthquake have a 25% chance to refund all Maelstrom spent.
    ascendance                  = {  80989, 114050, 1 }, -- Transform into a Flame Ascendant for 18 sec, instantly casting a Flame Shock and a 50% effectiveness Lava Burst at up to 6 nearby enemies. While ascended, Elemental Overload damage is increased by 25% and spells affected by your Mastery: Elemental Overload cause 1 additional Elemental Overload.
    charged_conduit             = {  80991, 468625, 1 }, -- Increases the duration of Lightning Rod by 4 sec and its damage bonus by 25%.
    deeply_rooted_elements      = {  80992, 378270, 1 }, -- Each Maelstrom spent has a 0.12% chance to activate Ascendance for 6.0 sec.  Ascendance Transform into a Flame Ascendant for 18 sec, instantly casting a Flame Shock and a 50% effectiveness Lava Burst at up to 6 nearby enemies. While ascended, Elemental Overload damage is increased by 25% and spells affected by your Mastery: Elemental Overload cause 1 additional Elemental Overload.
    earth_shock                 = {  80984,   8042, 1 }, -- Instantly shocks the target with concussive force, causing 328,454 Nature damage.
    earthen_rage                = { 103634, 170374, 1 }, -- Your damaging spells incite the earth around you to come to your aid for 6 sec, repeatedly dealing 21,067 Nature damage to your most recently attacked target.
    earthquake_ground           = {  80985,  61882, 1 }, -- Causes the earth within 8 yards of the target location to tremble and break, dealing 186,874 Physical damage over 6 sec and has a 5% chance to knock the enemy down. Multiple uses of Earthquake may overlap. This spell is cast at a selected location.
    earthquake_targeted         = {  80985, 462620, 1 }, -- Causes the earth within 8 yards of your target to tremble and break, dealing 186,874 Physical damage over 6 sec and has a 5% chance to knock the enemy down. Multiple uses of Earthquake may overlap. This spell is cast at your target.
    earthshatter                = {  80995, 468626, 1 }, -- Increases Earth Shock and Earthquake damage by 8% and the stat bonuses granted by Elemental Blast by 25%.
    echo_chamber                = {  81013, 382032, 1 }, -- Increases the damage dealt by your Elemental Overloads by 40%.
    echo_of_the_elementals      = {  81008, 462864, 1 }, -- When your Storm Elemental or Fire Elemental expires, it leaves behind a lesser Elemental to continue attacking your enemies for 10 sec.
    echo_of_the_elements        = {  80999, 333919, 1 }, -- Lava Burst has an additional charge.
    echoes_of_great_sundering   = { 103641, 384087, 1 }, -- After casting Earth Shock, your next Earthquake deals 120% additional damage. After casting Elemental Blast, your next Earthquake deals 140% additional damage.
    elemental_blast             = {  80984, 117014, 1 }, -- Harnesses the raw power of the elements, dealing 408,098 Elemental damage and increasing your Critical Strike or Haste by 7% or Mastery by 14% for 10 sec.
    elemental_equilibrium       = {  80993, 378271, 1 }, -- Dealing direct Fire, Frost, and Nature damage within 10 sec will increase all damage dealt by 10% for 10 sec. This can only occur once every 30 sec.
    elemental_fury              = {  80983,  60188, 1 }, -- Your damaging critical strikes deal 275% damage instead of the usual 200%.
    elemental_unity             = { 103630, 462866, 1 }, -- While a Storm Elemental is active, your Nature damage dealt is increased by 10%. While a Fire Elemental is active, your Fire damage dealt is increased by 10%.
    erupting_lava               = {  81006, 468574, 1 }, -- Increases the duration of Flame Shock by 6 sec and its damage by 50%. Lava Burst consumes up to 3 sec of Flame Shock, instantly dealing that damage. Lava Burst overloads benefit at 50% effectiveness.
    everlasting_elements        = { 103633, 462867, 1 }, -- Increases the duration of your Elementals by 20%.
    eye_of_the_storm            = {  81003, 381708, 1 }, -- Reduces the Maelstrom cost of Earth Shock and Earthquake by 5. Reduces the Maelstrom cost of Elemental Blast by 10.
    fire_elemental              = {  80981, 198067, 1 }, -- Calls forth a Greater Fire Elemental to rain destruction on your enemies for 20 sec. While the Fire Elemental is active, Flame Shock deals damage 15% faster, and newly applied Flame Shocks last 100% longer.
    first_ascendant             = { 103640, 462440, 1 }, -- The cooldown of Ascendance is reduced by 60 sec.
    flames_of_the_cauldron      = {  81010, 378266, 1 }, -- Reduces the cooldown of Flame Shock by 1.5 sec and Flame Shock deals damage 15% faster.
    flash_of_lightning          = {  80990, 381936, 1 }, -- Increases the critical strike chance of Lightning Bolt, Tempest, and Chain Lightning by 10%.
    flux_melting                = {  80996, 381776, 1 }, -- Casting Frost Shock or Icefury increases the damage of your next Lava Burst by 20%.
    fury_of_the_storms          = {  80998, 191717, 1 }, -- Casting Stormkeeper summons a powerful Lightning Elemental to fight by your side for 10 sec.
    fusion_of_elements          = { 103638, 462840, 1 }, -- After casting Icefury, the next time you cast a damaging Nature and Fire spell, you additionally cast an Elemental Blast at your target at 60% effectiveness.
    herald_of_the_storms        = {  80998, 468571, 1 }, -- Casting Lightning Bolt, Tempest, or Chain Lightning reduces the cooldown of Stormkeeper by 2.0 sec.
    icefury                     = {  80997, 462816, 1 }, -- Casting Lightning Bolt, Tempest, Lava Burst, or Chain Lightning has a chance to replace your next Frost Shock with Icefury, stacking up to 2 times.  Icefury Hurls frigid ice at the target, dealing 297,424 Frost damage and causing your next Frost Shock to deal 200% increased damage, damage 4 additional targets, and generate 7 additional Maelstrom. Generates 12 Maelstrom.
    improved_flametongue_weapon = {  81009, 382027, 1 }, -- Imbuing your weapon with Flametongue increases your Fire spell damage by 6.5% for 1 |4hour:hrs;.
    lightning_capacitor         = { 103631, 462862, 1 }, -- While Lightning Shield is active, your Nature damage dealt is increased by 8%.
    lightning_rod               = {  81012, 210689, 1 }, -- Tempest, Earth Shock, Elemental Blast, and Earthquake make your target a Lightning Rod for 8 sec. Lightning Rods take 10% of all damage you deal with Tempest, Lightning Bolt, and Chain Lightning.
    liquid_magma_totem          = { 103637, 192222, 1 }, -- Summons a totem at the target location that erupts dealing 70,412 Fire damage and applying Flame Shock to 3 enemies within 9 yards. Continues hurling liquid magma at a random nearby target every 0.9 sec for 6 sec, dealing 33,304 Fire damage to all enemies within 9 yards. Generates 8 Maelstrom. 
    magma_chamber               = {  81007, 381932, 1 }, -- Flame Shock damage increases the damage of your next Earth Shock, Elemental Blast, or Earthquake by 1.5%, stacking up to 10 times.
    master_of_the_elements      = {  81004,  16166, 1 }, -- Casting Lava Burst increases the damage or healing of your next Nature, Physical, or Frost spell by 15%.
    mountains_will_fall         = {  81002, 381726, 1 }, -- Earth Shock, Elemental Blast, and Earthquake can trigger your Mastery: Elemental Overload at 50% effectiveness. Overloaded Earthquakes do not knock enemies down.
    power_of_the_maelstrom      = {  81015, 191861, 1 }, -- Casting Lava Burst has a 60% chance to cause your next Lightning Bolt, Tempest, or Chain Lightning cast to trigger Elemental Overload an additional time, stacking up to 2 times.
    preeminence                 = { 103640, 462443, 1 }, -- Your haste is increased by 20% while Ascendance is active and its duration is increased by 3 sec.
    primal_elementalist         = { 103632, 117013, 1 }, -- Your Earth, Fire, and Storm Elementals are drawn from primal elementals 80% more powerful than regular elementals, with additional abilities, and you gain direct control over them.
    primordial_fury             = { 103639, 378193, 1 }, -- Elemental Fury increases critical strike damage by an additional 25%.
    primordial_wave             = {  81014, 375982, 1 }, -- Blast all targets affected by your Flame Shock within 45 yards with a Primordial Wave, dealing 103,474 Elemental damage, and granting you Lava Surge. Generates 3 Maelstrom.
    searing_flames              = {  81005, 381782, 1 }, -- Flame Shock damage has a chance to generate 2 Maelstrom.
    splintered_elements         = {  80978, 382042, 1 }, -- Primordial Wave grants you 10% Haste plus 4% for each additional targets blasted by Primordial Wave for 12 sec.
    storm_elemental             = {  80981, 192249, 1 }, -- Calls forth a Greater Storm Elemental to hurl gusts of wind at your enemies for 20 sec. While the Storm Elemental is active, casting Lightning Bolt, Tempest, or Chain Lightning increases your haste by 6%, stacking up to 4 times.
    storm_frenzy                = { 103635, 462695, 1 }, -- Your next Chain Lightning, Tempest, or Lightning Bolt has 30% reduced cast time after casting Earth Shock, Elemental Blast, or Earthquake. Can accumulate up to 2 charges.
    stormkeeper                 = {  80988, 191634, 1 }, -- Charge yourself with lightning, causing your next 2 Lightning Bolts to deal 30% more damage, and also causes your next 2 Lightning Bolts or Chain Lightnings to be instant cast and trigger an Elemental Overload on every target.
    surge_of_power              = {  81000, 262303, 1 }, -- Earth Shock, Elemental Blast, and Earthquake enhance your next spell cast within 15 sec: Flame Shock: The next cast also applies Flame Shock to 1 additional target within 8 yards of the target. Lightning Bolt or Tempest: Your next cast will cause 1 additional Elemental Overload. Chain Lightning: Your next cast will chain to 1 additional target. Lava Burst: Reduces the cooldown of your Fire and Storm Elemental by 4.0 sec. Frost Shock: Freezes the target in place for 6 sec.
    swelling_maelstrom          = {  81016, 381707, 1 }, -- Increases your maximum Maelstrom by 50. Increases Earth Shock, Elemental Blast, and Earthquake damage by 5%.
    thunderstrike_ward          = { 103636, 462757, 1 }, -- Imbue your shield with the element of Lightning for 1 |4hour:hrs;, giving Lightning Bolt, Tempest, and Chain Lightning a chance to call down 2 Thunderstrikes on your target for 62,243 Nature damage.

    -- Farseer
    ancestral_swiftness         = {  94894, 443454, 1 }, -- Your next healing or damaging spell is instant, costs no mana, and deals 10% increased damage and healing. If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side for 6 sec.
    ancient_fellowship          = {  94862, 443423, 1 }, -- Ancestors have a 20% chance to call another Ancestor for 6 sec when they depart.
    call_of_the_ancestors       = {  94888, 443450, 1, "farseer" }, -- Primordial Wave calls an Ancestor to your side for 6 sec. Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell.
    earthen_communion           = {  94858, 443441, 1 }, -- Earth Shield has an additional 3 charges and heals you for 25% more.
    elemental_reverb            = {  94869, 443418, 1 }, -- Lava Burst gains an additional charge and deals 5% increased damage.
    final_calling               = {  94875, 443446, 1 }, -- When an Ancestor departs, they cast Elemental Blast at a nearby enemy.
    heed_my_call                = {  94884, 443444, 1 }, -- Ancestors last an additional 4 sec.
    latent_wisdom               = {  94862, 443449, 1 }, -- Your Ancestors' spells are 25% more powerful.
    maelstrom_supremacy         = {  94883, 443447, 1 }, -- Increases the damage of Earth Shock, Elemental Blast, and Earthquake by 15%. Increases the healing of Healing Surge and Chain Heal by 15%.
    natural_harmony             = {  94858, 443442, 1 }, -- Reduces the cooldown of Nature's Guardian by 15 sec and causes it to heal for an additional 10% of your maximum health.
    offering_from_beyond        = {  94887, 443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of Fire Elemental and Storm Elemental by 5 sec.
    primordial_capacity         = {  94860, 443448, 1 }, -- Increases your maximum Maelstrom by 25.
    routine_communication       = {  94884, 443445, 1 }, -- Lightning Bolt, Lava Burst, Chain Lightning, Icefury, and Frost Shock casts have a 8% chance to call an Ancestor to your side for 6 sec.
    spiritwalkers_momentum      = {  94861, 443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by 1 sec, up to a maximum of 4 sec.

    -- Stormbringer
    arc_discharge               = {  94885, 455096, 1 }, -- Tempest causes your next 2 Chain Lightning or Lightning Bolt spells to be instant cast and deal 20% increased damage. Can accumulate up to 2 charges.
    awakening_storms            = {  94867, 455129, 1 }, -- Lightning Bolt and Chain Lightning have a chance to strike your target for 133,929 Nature damage. Every 3 times this occurs, your next Lightning Bolt is replaced by Tempest.
    conductive_energy           = {  94868, 455123, 1 }, -- Lightning Rod targets now also take 10% of the damage that Tempest deals, and Tempest also applies Lightning Rod effect.
    electroshock                = {  94863, 454022, 1 }, -- Tempest increases your movement speed by 20% for 5 sec.
    lightning_conduit           = {  94863, 467778, 1 }, -- You have a chance to get struck by lightning, increasing your movement speed by 50% for 5 sec. The effectiveness is increased to 100% in outdoor areas. You call down a Thunderstorm when you Reincarnate.
    natures_protection          = {  94880, 454027, 1 }, -- Lightning Shield reduces the damage you take by 3%.
    rolling_thunder             = {  94889, 454026, 1 }, -- Gain one stack of Stormkeeper every 50 sec.
    storm_swell                 = {  94873, 455088, 1 }, -- Tempest grants 9% Mastery for 6 sec. 
    stormcaller                 = {  94893, 454021, 1 }, -- Increases the critical strike chance of your Nature damage spells by 5% and the critical strike damage of your Nature spells by 5%.
    supercharge                 = {  94873, 455110, 1 }, -- Lightning Bolt, Tempest, and Chain Lightning have a 50% chance to cause an additional Elemental Overload.
    surging_currents            = {  94880, 454372, 1 }, -- When you cast Tempest you gain Surging Currents, increasing the effectiveness of your next Chain Heal or Healing Surge by 20%, up to 100%.
    tempest                     = {  94892, 454009, 1, "stormbringer" }, -- Every 300 Maelstrom spent replaces your next Lightning Bolt with Tempest. 
    unlimited_power             = {  94886, 454391, 1 }, -- Spending Maelstrom grants you 1% haste for 15 sec. Multiple applications may overlap.
    voltaic_surge               = {  94870, 454919, 1 }, -- Earthquake and Chain Lightning damage increased by 5%.
} )

-- PvP Talents
spec:RegisterPvpTalents( { 
    burrow              = 5574, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by 50% for 5 sec. When the effect ends, enemies within 6 yards are knocked in the air and take 455,287 Physical damage.
    counterstrike_totem = 3490, -- (204331) Summons a totem at your feet for 15 sec. Whenever enemies within 23 yards of the totem deal direct damage, the totem will deal 100% of the damage dealt back to attacker. 
    electrocute         = 5659, -- (206642) 
    grounding_totem     = 3620, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within 34 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    shamanism           = 5660, -- (193876) 
    static_field_totem  =  727, -- (355580) Summons a totem with 4% of your health at the target location for 6 sec that forms a circuit of electricity that enemies cannot pass through.
    storm_conduit       = 5681, -- (1217092) 
    totem_of_wrath      = 3488, -- (460697) 
    unleash_shield      = 3491, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
} )

spec:RegisterHook( "TALENTS_UPDATED", function()
    talent.earthquake = talent.earthquake_targeted.enabled and talent.earthquake_targeted or talent.earthquake_ground
end )


-- Auras
spec:RegisterAuras( {
    -- Talent: A percentage of damage or healing dealt is copied as healing to up to 3 nearby injured party or raid members.
    -- https://wowhead.com/beta/spell=108281
    --[[ancestral_guidance = {
        id = 108281,
        duration = 10,
        tick_time = 0.5,
        max_stack = 1
    },--]]
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
    -- Your next $s3 Chain Lightning or Lightning Bolt spells are instant cast and will deal $s2% increased damage.
    arc_discharge = {
        id = 455097,
        duration = 15.0,
        max_stack = 2
    },
    -- Movement speed reduced by $w1%.
    arctic_snowstorm = {
        id = 462765,
        duration = 8.0,
        max_stack = 1
    },
    -- Talent: Transformed into a powerful Fire ascendant. Chain Lightning is transformed into Lava Beam.
    -- https://wowhead.com/beta/spell=114050
    ascendance = {
        id = 1219480,
        duration = function() return 15 + 3 * talent.preeminence.rank end,
        max_stack = 1,
        copy = { 114051, 114052, 114050 }
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
    call_of_the_ancestors = {
        id = 447244,
        duration = 6,
        max_stack = 1
    },
    -- When you deal damage, $w1% is dealt to your lowest health ally within $204331m2 yards.
    counterstrike_totem = {
        id = 208997,
        duration = 15.0,
        max_stack = 1
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
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    electroshock = {
        id = 454025,
        duration = 5.0,
        max_stack = 1
    },
    elemental_blast = {
        alias = { "elemental_blast_critical_strike", "elemental_blast_haste", "elemental_blast_mastery" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff"
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
        max_stack = 1
    },
    elemental_blast_haste = {
        id = 173183,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1
    },
    elemental_blast_mastery = {
        id = 173184,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1
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
        copy = 347349
    },
    -- Fire, Frost, and Nature damage taken reduced by $w1%.
    elemental_resistance = {
        id = 462568,
        duration = 3.0,
        pandemic = true,
        max_stack = 1
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
        duration = function() return 20 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    fury_of_the_storms = {
        id = 191716,
        duration = function() return 10 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1,
        copy = "fury_of_storms",
        generate = function( t )
            if action.stormkeeper.time_since < t.duration then
                t.applied = action.stormkeeper.time_since
                t.expires = action.stormkeeper.lastCast + t.duration
                t.stack = 1
                t.caster = "player"
                return
            end

            t.applied = 0
            t.expires = 0
            t.stack = 0
            t.caster = nil
        end,
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
        duration = function() return ( 18 + 6 * talent.erupting_lava.rank ) * ( buff.fire_elemental.up and 2 or 1 ) * ( buff.lesser_fire_elemental.up and 2 or 1 ) end,
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
    -- Fire damage dealt increased by ${$W1}.1%.
    improved_flametongue_weapon = {
        id = 382028,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- enhanced_imbues[462796] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- enhanced_imbues[462796] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- enhanced_imbues[462796] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Talent: Your next Lava Burst casts instantly.
    -- https://wowhead.com/beta/spell=77762
    lava_surge = {
        id = 77762,
        duration = 10,
        max_stack = 1
    },
    lightning_conduit = {
        id = 468226,
        duration = 5,
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
        duration = function() return talent.charged_conduit.enabled and 12 or 8 end,
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
    -- Lightning Bolt$?a454009[, Tempest,][] and Chain Lightning will trigger Elemental Overload an additional time.
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
    -- Mastery increased by $w1%.
    storm_swell = {
        id = 455089,
        duration = 6.0,
        max_stack = 1,
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
    -- Your next Chain Heal or Healing Surge has $w1% increased effectiveness.
    surging_currents = {
        id = 454376,
        duration = 30.0,
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
    -- Haste increased by $w1%.
    wind_gust = {
        id = 263806,
        duration = 20,
        max_stack = 4
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

-- The War Within
spec:RegisterGear( "tww1", 212014, 212012, 212011, 212010, 212009 )
spec:RegisterAura( "maelstrom_surge", {
    id = 457727,
    duration = 5,
    max_stack = 1
} )

spec:RegisterGear( "tww2", 229260, 229261, 229262, 229263, 229265 )
spec:RegisterAuras( {
    -- https://www.wowhead.com/spell=1218612
    jackpot = {
        id = 1218612,
        duration = 8,
        max_stack = 1
    },
} )

-- Dragonflight


spec:RegisterGear( "tier29", 200396, 200398, 200400, 200401, 200399 )
spec:RegisterSetBonuses( "tier29_2pc", 393688, "tier29_4pc", 393690 )
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
    --[[ancestral_guidance = {
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
    },--]]

    ancestral_swiftness = {
        id = 443454,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        school = "nature",

        talent = "ancestral_swiftness",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "ancestral_swiftness",

        handler = function ()
            if talent.natures_swiftness.enabled then
                -- Summon an ancestor.
            end
            applyBuff( "ancestral_swiftness" )
        end,
    },

    -- Transform into a Flame Ascendant for $d, instantly casting a Flame Shock and a $s10% effectiveness Lava Burst at up to $s7 nearby enemies.; While ascended, Elemental Overload damage is increased by $s8% and spells affected by your Mastery: Elemental Overload cause $s9 additional Elemental $LOverload:Overloads;.
    ascendance = {
        id = 114050,
        cast = 0,
        cooldown = function () return 180 - 60 * talent.first_ascendant.rank end,
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
            spec.abilities.flame_shock.handler()
            spec.abilities.lava_burst.handler()
            active_dot.flame_shock = min( true_active_enemies, active_dot.flame_shock + 6 )

            if set_bonus.tww2 >= 2 then summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental", 6 ) end
        end,

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
            if buff.surging_currents.up then removeBuff( "surging_currents" ) end
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
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,

        handler = function ()
            removeBuff( "chains_of_devastation_cl" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )

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

            if talent.conductive_energy.enabled then
                if debuff.lightning_rod.down then
                    applyDebuff( "target", "lightning_rod" )
                else
                    active_dot.lightning_rod = min( active_enemies, active_dot.lightning_rod + 1 )
                end
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
        cycle = function() if talent.lightning_rod.enabled then return "lightning_rod" end end,

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
        id = function() return talent.earthquake_targeted.enabled and 462620 or 61882 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 60 - 5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "earthquake",
        startsCombat = true,

        cycle = function() if talent.lightning_rod.enabled then return "lightning_rod" end end,

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

        copy = { 462620, 61882 }
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
        cycle = function() if talent.lightning_rod.enabled then return "lightning_rod" end end,

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
        id = 470411,
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

        copy = 188389
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
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up then return 0 end
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
            elseif buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            if buff.surging_currents.up then removeBuff( "surging_currents" ) end
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

    -- Talent: Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[    |cFFFFFFFFGenerates $343725s3 Maelstrom.|r][]
    lava_burst = {
        id = 51505,
        cast = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.lava_surge.up ) and 0 or ( 2 * haste ) end,
        charges = function () return talent.echo_of_the_elements.enabled and 3 or 2 end,
        cooldown = function () return 8 * haste end,
        recharge = function () return 8 * haste end,
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
            if buff.lava_surge.up then removeStack( "lava_surge" ) end
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "flux_melting" )
            removeStack( "molten_charge" )
            removeBuff( "echoing_shock" )



            gain( ( 8 + ( talent.flow_of_power.rank * 2 ) ) * ( buff.primal_fracture.up and 1.5 or 1 ), "maelstrom" )

            if talent.erupting_lava.enabled and debuff.flame_shock.up then
                if debuff.flame_shock.remains > 3 then
                    debuff.flame_shock.expires = debuff.flame_shock.expires - 3
                else
                    removeDebuff( "target", "flame_shock" )
                end
            end

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

                removeBuff( "primordial_wave" )
            end

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
            if buff.arc_discharge.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        nobuff = "tempest",

        handler = function ()

            local ms = 6 + ( 2 * talent.flow_of_power.rank )
            local overload = 2

            ms = ms + ( buff.stormkeeper.up and overload or 0 ) + ( buff.surge_of_power.up and ( 2 * overload ) or 0 ) + ( buff.power_of_the_maelstrom.up and overload or 0 )
            ms = ms * ( buff.primal_fracture.up and 1.5 or 1 )

            gain( ms, "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeStack( "arc_discharge" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )

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
                addStack( "arc_discharge", nil, 2 )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "tempest"
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
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        buff = "tempest",

        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        handler = function ()
            removeBuff( "tempest" )

            local ms = 6 + ( 2 * talent.flow_of_power.rank )
            local overload = 2

            ms = ms + ( buff.stormkeeper.up and overload or 0 ) + ( buff.surge_of_power.up and ( 2 * overload ) or 0 ) + ( buff.power_of_the_maelstrom.up and overload or 0 )
            ms = ms * ( buff.primal_fracture.up and 1.5 or 1 )

            gain( ms, "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeStack( "arc_discharge" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )

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
                addStack( "arc_discharge", nil, 2 )
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "lightning_bolt",
        flash = 188196
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
            gain( 8, "maelstrom" )
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
        cooldown = 30,
        gcd = "spell",
        school = "elemental",

        spend = 0.03,
        spendType = "mana",

        talent = function()
            if covenant.necrolord then return end
            return "primordial_wave"
        end,
        startsCombat = true,

        -- velocity = 30,

        usable = function()
            if active_dot.flame_shock < 1 then return false, "requires active flame_shock" end
        end,

        handler = function ()

            if talent.call_of_the_ancestors.enabled then
                applyBuff( "call_of_the_ancestors" )
            end
            gain_maelstrom( 3 )
            if talent.conductive_energy.enabled then active_dot.lightning_rod = min( active_enemies, max( active_dot.lightning_rod, active_dot.flame_shock ) ) end

            removeBuff( "echoing_shock" )
            if talent.splintered_elements.enabled then applyBuff( "splintered_elements" ) end

            if set_bonus.tier31_2pc > 0 and state.spec.elemental then
                applyBuff( "elemental_blast_critical_strike", 10 )
                applyBuff( "elemental_blast_haste", 10 )
                applyBuff( "elemental_blast_mastery", 10 )
            end
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

            if talent.fury_of_the_storms.enabled then
                applyBuff( "fury_of_storms" )
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )
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

    potion = "tempered_potion",

    package = "Elemental",
} )


spec:RegisterPack( "Elemental", 20250314, [[Hekili:TZZAZTTrs(BrvQLI02IIpevKtjjxjEDU1(C8Mk05YhU6iii4qrCceGlEifENo(B)6Eg8yMbZmaueuwojFy3iZzq390V7EEmP)Kppz8C7yYKpnO3Gr9g2Fu3E9o7SZgnzC8M1KjJxB7CR9nWF4BVc()FNhzfXp22dhzJxG9CecrbjHoWOlJJxh9DNE6nUXltM11jy1PrURs8SJDd8DcTxeJ)BNtNmEwIRx879Nmtf6hoea5AId8RNpaGQ785e2ujrotgJt9KEdpP)zF32P)czvWDKTth7U6TBNIFL7cxNTtJDx56Ft02Plcc3o97JCi(ZT9DiB)W2pKdGEFx2hMSgjJIbhCYGlOqpAJpaT7HfeBQW6omyHRhSA)MTtFNFusiG97j2Rd83oL47S02pE7uxaZ2Rx75sMd)JfBNUji5yKoJiEeNy8xF)kas3H)1p6b824a)BsGj8Buq1D7hSDqUwu31HeGroZo(LxD6IIzAXW5RCxCfioazsx3uaAvEwDj(2Z8aCPeQr3Uzrs4g1d65EZYyFGxAfT0L4PbeG82Fojmko09waP2HAMhXomEzkKqs)Ozjlw0L)x7MSUv6cIKPSzfeoZnwdXhheU6wcznju9eUZo0fx8Vc1GVALnXZYXE9RUZ2lHCv)E9E5OEVifHr3t88WLkolyTeSQBOT)TVCWOSzSo0Dvq4CxBkqSDCJ3qNsDqnv5e(q3yYQOu8d8l)BjXD731nQB06nRSJIb2ii2M9Wdzdoq1GTf(0LbjreRGfavfopQ1rfF6s7ilCmKrlbsDFuFHpQtM4yHliFTStnLIrJfWe49(anfMSgu6da9ChGgJk0EbMW9U(ZbzliJPZ)DunXTtb2i9))oQmw4lIw7g6gFVT3T4Q9MqBhYRGjccMR6ZpVzEbbG2oO6svLsjt7CB9mT(hEGQLXnqY6hEWjiWBEW9(8)EizLTRF01J6jGhGmiH3c4F3XdpCagiHsZ7oy2fYfhcuEPQOEEhcCbIXXzQJhhH(SMXtaOMdQK)QiVG4mv8(upv6v3B1U9c0vJvgI6FrVwuIJBEHK1bHGDAmev66bJsPEDtyimbbyE5f960s9IZE(MwTPqd1NqJcQJLik)iJ)Lnu8ss6WDA1ohEC(gU3(UcogsNhv2)boNhEaCk45zfBhEdbSBGOhU(w5UCV(QbDG1yquulX1XG(DQKHpGNHRWfYFXW3vgoO2)jscyybQ)B8Txhrq3zlXfuOsXb1TVp9tSIyFHfj9dEfZ37cRBCMFf14q2smxUmWSfzFMf5)a9MZCc)w0F(2PVC70bGlwx)ei1gHCG0rRIrektIzb06kellvo(ii9x3th7MXTbjoYTt1IJQuNVFzswtunqdr3I5rOvYTk5YhHtcD4vB1yMLsaJ0WMl7)Vq0vhxm6z3YzE8xS7Qz3CQ8S82nOXJFMf4kzEzzWZqoAn4xAzm88a5QrY9Bkpqxex8FPVDmuQwKv09UlI9jraR9B(gGH)ROtZFo4EWfoKl7IKixSqo8)92mkgNjuoxoOC9VlaQYH87qeqFybIeaZ)5AeowUPGrLt9QsVAOqQCRdI5Hdn5rVKOykyKdfdX0l(DnoJfvih2VfQMYJXWeFl2)c03JIzll7aYRWs7CIzkyMTo6xj8IGP5rsbawhrwXtaIsZt2kV4p5rP6NfdxufP0acA8eNLbzA85ZisjOZQLKMKlMNsAb6qT7ldCUnRLc)mv1xgcEU)Re35q9J3SY2koaTwrdYQmDUC0laRxdwpTr0ChXAEay9IuJfLyU8Q0FN4tw5sIoz4dpOzMTfN51VzyNkmk7vsUuaUx5SXjxcgX0kQCrclXwhjrxDJDDWkRA1(r5k(YRgURRcjeGuUAw2vYCSZ5mDllOf8MLjilpnzYPOAnEptBN(HFD8N3o9V)pbVsF(OTtZATMB3B3S6eN5(0URbOieiTtDDaaE6QGzUEKt71R3P96FXP9p7BpD8sxBRpA)dKGKfwwFaCDy93dSEFSL1pbUwUJ2yoa1JxtaleR2)Zq3BCXF4)WDojWA2MIV9x(BVD4F7ho3)2Bz)HLL1Ntc9jHDS6DYzwroHeIpW3I7(FV(MslYCbtr8j(4mSYhUAGENAh1(X2Qeqn)requtEPPf)MakJSuTtJCG97dByK)nqGc)5uFfjEW)Dgmpia98UBN(M3iZwa1H1GWxLXeZjEOJ1C3iqNhgHXKUCq6QjcPbKMPXCewnId1PSpQSqLZc8IZrgV8izDl1iPLrRXRgiJlPjWzSLzvD15AqvnafNB)fHe))NnmE0vdAPMv0kVVExMNnAwdbpPD)rVubJ4fgxXMhLLshndJpAFNDUIZ6WahqHjoy7u0WnbdUGb9GrSdtBKwwMiPnpg7Sg8VGGwWhHKju6j210)vI9TKSgu7gxoGeGxibLq1AzzUZafC4Zycc6xq5B5QbmAbzJPXoJSqYfhNf6LzUjfGfnXA1oNLF9ObNK3hvYgIG9wQsngMgYrdg5gGIIbYa7QmQQsIkfpx5e70jnYnXFohZZgzUoEbOOGY2Tx)QTt)jkzZ43aPaS0ukpJfJM1GM4uP9qG1E)zbjXmOr(91i7qM3tYfquVEfCIYkF979I2gvLEz)oPoh1YRv1lVwAsg8YHk9VnQtDfevnRz1tC1QD(uYB2)mpyfMNhtMFI(VmDIPon7uYVMeeuPV)1ImqCTF5vYlEiGxvm2JQJeQmpmDNy0KI3xj8V9N5erdav4ibTYJsRg4JzRNTt)LGuNmFMjxyEkgZvgrQlKk8nKNTywK5WG5Te(xxkQs0QCou5mVuDetPe8hBR8NEU5Zv71NCoX(VmZT8OPn9EhcDRPPgGyAtqX4zTOzrr86sMxUSVJJhuohMwh1wx2nSMfvS01NaKcH)zCweYQ7vAQWsF5)CWjdJ)VQi1rwkkxA7VjEj8LxNLfiuz37yDWcGcm1uNXnDMHvL5x6kv9eAjZ0gYTU)F)r7Wicj8)lLby75LXfO0RW6pcDqdL6bPZn(F36TFmT(RChYM4jmF3(byACuQLEAn8rGl6KFhzE7hRPMMGfHIVyag7vtM18tC)YaxYzVOQnuLDjrARJu6)j9hXnNoJcynbjimkvlix33OO3OQ)JvXVkzN4QSCfVv0KmB1TAQxLfAPpeAL(uAvvqw5mDyS3uZP2i788x2HLBJKD14GFUQYEuPoBUncxF15L03ZdT8NQmzuZ8k1bLDGB9CntLgFLU)ldwMisw3HbrXPRISgqLMRH18v3uexuScMJuT4m7hueVswiMC6KDsPEfJ)AbKzizrijAj9GxzybvCgRkMLWw1yyVzKNxJUlny7WtqNo0t4ax5vDRGayZITV0zPbAyRpnSXfA3Bgk199Rx7TrCFIy5w4MEwqP5yiugOm9QENJ0UDjPmZs9NTIWxgeSCQqheeNVxR58VTt)nKbo1gyqRsCwY(R1qj9UyJf0tRLeb6MOYnxr7KvTjfL3jI2QpqjTk(z6HBYktRIFZju(bdK(GoT0CwjECBKXEUX9n9(GWVliYsGS9djV1(63tGYMpQ3uJ6dHsiV(7RqXXRoVD))0NzPszl4zym1uAxDciBkY5oVwMD)eiZIH)NkhuXs198o8O8sl7bZ62aPk5VOAACNDzKhcpLKSWe3L7Upxp9dUJe6yVMs8yQQSIby5YM1fo8e9dMuGZ43rd8ZuE)3Wq)O6CASFdlBPKBRtoe1l5ZoTm3C1rv160ogiAPmnbkF)Wvf8Nc1I9fnp((ajtyCDeQr67J8w79dybL80N2nxYK9)EvAAETjQNs6AsOlok6RGIuv5p3d5uyx22sdCKq2YX276(DV45xJjKRULwubEBFue)I5TyHqLUsT0)lKZH6iN0umulZ6f7KFJVm0HOtLVi0qk629mqkvVdRvp0RfZn4z5JDUooRKZUtamIKm9kIHLPLM)ag0kjoYDEQQBXgtBkC9twHRWQ4hD98qRjAxEGGUFV392BWTm)oBxpAqGIFJ6ACwqCCWQTt9C9nTiezX1l3K6woCTGbgrl7gln3feCWY(6ZzRzojelFJGKWIl4eEapqMsnfrzyCYyiPgmgu(nKS3KX3BhImHOjJ)mY8CxHxbJuVwhdL1F82PHeirsQMtuaMXNDcWFTP55H3qrWTnqiFe42BNo47WJ6QpGh6WhBSw8JzUqnpPS0HHj3U)V3jhtNPgtsvCiHc5Aw0a7rhqyFUAyxozDjWR4mcQbdxiJHqTN1TCCKoLy1ZPwGxXPLRe4vphZGxxTOs8NYtqh)51QXGORDjORUenzi3xJ6Fta6HASSKsWr2MsA4Dg86sLqHTRY5PfHASFF6rOyAjYOrC0Df4PX5LaAwYg6aMg3pnkWoC8zno4oCi8B15rLBFcl5mLBSDfWnH1Sgq)KZKAgTFna)XPWQjaW(lo1a4MqCQb0nkd4WPBOjG4(ZXpGrA1a6dgtAqpD5Li3uNJLZlrEc7kkAeBuTa)GXW6RgHQlvwcBAAlLouPjTRNqu1qPH9Lc8nIgMgGV3Ur0byLTmqcbkNJweDitrulWpygGnzoPd0Kgzd4kxhOpCmgDiSreZnzY7d0KlDtW11a6gLopCIWdxQ56a9HBTOjFVg0922pOO3EcDm84NPD5ttBjAWUbPbdnsV(03jo(ZUroSlAcN0W1eOIN8dfGT0eQfGhyMAlnCnbAfuRIjygWnUMHgm0iAgA73g)Xtq2YHFmTawdvFaYfwBHQntYQFPaFtKfWxGkFpacyD1m2aRcDG(qSk0uiAtSkEcRXvt28h6SeMtwyN4TJ5hukfQWgDhO0KHwd66xdgAex)F1V)zh04ILSOAIuMkd1gNPOdfndxPuc3nrQz62TYMKRObfndx5WxCGouSN0VspT5V1V7MV2kBMb95o(yDPXqhT2w6nRF8NApH8uV4JtPAQV0CQf43lBsJSKkOz1ZPwGFV8UQlIJ4l8SSnO4OQSrEp18ab5zzpyE4H6I9Kqpzm9VWhmE7ac8F(e95NNnTjJfVzrtgNc(j)WK4jFAaoZIFzStOlOd5Apz8rSdTPIZz32Pp8W2PW4zwqgBJrbHibje9d5ju64StdNevEMevM9fLpiqS3Y(q31Sju9dnh)sUn(Sbz(kDSD6LGFMTtFX2P34mhsC93L5gA84TDANTtBbI00ZjBPRQka5RYhl9I5TD6jBNoKHbTFfpmZ)URFd9d7KHwdpLBWKbV79q(8in8zoeYZVQfZkNn1IYL0C9NY4nvXeroHX74kJnoChw3Jfor4OXdWjoxRDHo5GcHhkeoNrZ149TJrpJK1N0Fy3kKpsSlCb8T8wwkUUwswyxOrYxW2KSS(Q(z0tYOV0zXLEYHb5Xv077okpytr(sRLlRqnxdr7zZZuaBot1mcQ0TrtwZqFUBuqrjB8vifbQW1mJAxoGAX)AnY90D5qHXbhRJDUMl)w6XGVWIP89ftAXO5IFnTJSh9sxTGQVAC4teiUybJDDw1koo2u6xhX3Qs3qOUdFKk(tynLy6xLlMc)ixr9JOLCkqJevqXJ(q8CX35VoEmApZHDfYhys5x3eQCV09rIgeRnZ12lvySHSZxuj7S6z0XmByOUCiYV4nMv2fF4wkKgcx7NIFw)nCkJXsNM2lDuM1dhZfcpmAaLBYsajl9lnD5vW(RIBlJQu6mUZDm)vs2MpPpiJuHQUedlUWqLsi8lW7xOu4grrQA7L(9OI42vQ1dwu9lC3xHkv(CeUmkfkTQss6Y8mqnemzKCWRAPVv1mN940mzKb3NOEJkesRUWxlLF(Y8pwA7(t17rDpDjllHU)Cj8LzNyY4M5N0mJ2fz7r1vXPJ6u77lNBVGtJYv58hCHwtZ7JOjKOKX)TpsV1OR096rIKxCMxwLIJBhDnkmcLxjRuZNxRuIm5YRIBrzTZ09pBoq1vZPbhOp)fEFn4auxrFACa(mNP308o9oWgix)ygJl9c)QkD46(alOGHR)4YNTuARVyJ8xCbooSPAsmQaFwjNiM8iSt(AOUcgixl8HR4S6v4vk9B(CjqNPk21qjfHdXRokLTjxA)UY2AAMXoBJlMy1fd4ZKQYYBldGdr5XkJHQt9pVjEkvlYuaR0HA6emEyvuQJ9m8fELQOUVnFPEkQYmDwl4Kytn6tGkDXPRjeA21KuQu1gi0RWZvf9pQ(5NTtEJvWeRoFonbl1wFCnY2NjeQ7dLQu1A68c1QYsZsB0Qs3vcjBuzAGv5v5pi5WpqBT0gBcIbjujsPXejFfKz(aJviRS1ep9SYMMJyiFB5keL26cX3zhb8vUDjhPNrvVWT5U1lEozOe5R53Pv5DEqCxwhkxab7pTyVkn1i2b3lSZKXPFfJxnKMcDXpza0C0Va5bwPcxeMV(ojjkSCeoujI7GT6x(wjkpoRwm971kUg2TJcH4QwZHDyVo4l1(HZvA5A64zKlhvUDOvMIMQdyYtgUvAyP4CEuUa(A)S6wGJM)4y4u(4kO(SiadR5OQX80fQ5cqLgSlu5jZt8tLVnszXfoIRZ4cpVUYPfTVhSbgOQ2I7A8kOwtJTT17etuicloxm15uuS3hHH38Msr)kFmaQZrCq)zhyNoIcCo0FKhDGYCjvhwHA7WR6xhyEY3WRQBnDOy6ifie8wGk3Jxm4hd5)i9wkKMNQBA3EV37hMxxyv(jBWAWYD9uRTdCehOnWPvVxYfRJMdx6lot1MIEGPaU6zmTZGnCJ1pQzBzUXDXQzBTLqT8v1j2CQxQ93ABdRYcJesR14ZtmRHbDV4pU90v)bDAhEEQREV3QORy0c63Jhy5Nk)J1xhRwTDOv919vUlDLx0FzOnt(FlTdyp)iArx2S9EQuIUcvXuQT)kZFuSHaTsxyspJZ0eWpZuYQ6BdpF)o0gh5r8Oq)LTFuQAXUWQB)ESOnYQLtwG9NnrBSk1b0sGMlXe5xmAA8IZ1GDr0ih1UeAezL18nOwJshpQPfdsVh55TxtNa89q1aHy63mnph7iA6mzOGAHeTeSlv1(nZlO3rhfxbHKI1bhWJw7c857T9Uf7WWnqO(snC0uRCs1G506lNCIKjHq6gAUToJ4QaFMxqWClA2HkAu2(rnCybw(KqSnuv2(QDgl7(Agt9KUUv16QNAIPOlwOJQ8MCPWdCARJG0EJ8cI5)3f0S5RpdlVI2L6kdM35fC7Ak33fsWRmz(v5POxqvoXHPtSChGquXIWQMrzpFZxbD6cNwn2i0b1QNy9lND84mE7XWC(nYmvn0us1yGsvbL3tQ)sv45TQGGj(atDh1NKq7b(gF71r4(uUe5DHtgZU22qDgoZPfl7dHXnmDPSW0DtphupxC4ncvqD(tu8cr)zigkOldZQ63A2It8YNRBnjpRILIUwPZPsTNl0x3REsvj2X)iGULzygjVfjA6oOdOCLRFcwA63l0z8sTqU6ycYCkX4A62CJufEZSTgXyuG3YN9UOw0ZfRwTEOkFPJRW4wvIdYkEYXc(eWEqJNu5wKXM8xemqYjsn1jK31Q)sN4zIoHPnlbNRf4qDEMuN7h0l2)dIuBhLfgz0AS8UNyVoWps5w2if5SOs)OLUeV5DrIsvJaydxSZf5r0PDqps72AByxgOeaT2gVKsn5s9EDxLEN6e3g2NLJyasDze(6a6)v1wruqIvzEbyfpVjHUoXuT1mGhM4BX(Bl8HAH9CTyXsaaFWwmTlcM(wXdRdT1c5pCsQAUGqBrId8VjHyX0ok1DGOeSVaSb3oL4JV0sPhCeCRvDjZZVdThJhjIiIhXHU3LVF16WG7ODrRanyzaiOuDlhCt)aRYKLqVU41ZIUDdBBHe0UeEmzkPSko3Ze6E5sARSrr3TaUHSAKMTX6(PQHzDhLA2i2gVIU9k8atvUZQz2uNlSu5p)sceLSIAWAy2GIq(NMf3d)lVe4)0VxpA2AJe2mMO7b1AKrLVVlDdT9VLLxNW2UW5gZXETTJB8g6uPOkvPmBBbvv0x1u4((iAGZq8iWu6DGkV93MYAW0djvjaiNkQqp4184oXZYeslzsQLSDs8YaqKp2DvIh9Dq5TH2lydo5)p]] )
