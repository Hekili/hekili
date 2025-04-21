-- ShamanEnhancement.lua
-- July 2024

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR
local FindPlayerAuraByID = ns.FindPlayerAuraByID

-- Globals
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetSpellCastCount = C_Spell.GetSpellCastCount
local strformat = string.format
local insert, wipe = table.insert, table.wipe

local spec = Hekili:NewSpecialization( 263 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Shaman
    ancestral_swiftness       = {  94894, 443454, 1 }, -- Your next healing or damaging spell is instant, costs no mana, and deals 10% increased damage and healing. If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side for 6 sec.
    ancestral_wolf_affinity   = { 103610, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    ancient_fellowship        = {  94862, 443423, 1 }, -- Ancestors have a 20% chance to call another Ancestor for 6 sec when they depart.
    arctic_snowstorm          = { 103619, 462764, 1 }, -- Enemies within 10 yds of your Frost Shock are snared by 30%.
    ascending_air             = { 103607, 462791, 1 }, -- Wind Rush Totem's cooldown is reduced by 30 sec and its movement speed effect lasts an additional 2 sec.
    astral_bulwark            = { 103611, 377933, 1 }, -- Astral Shift reduces damage taken by an additional 20%.
    astral_shift              = { 103616, 108271, 1 }, -- Shift partially into the elemental planes, taking 40% less damage for 12 sec.
    brimming_with_life        = { 103582, 381689, 1 }, -- Maximum health increased by 10%, and while you are at full health, Reincarnation cools down 75% faster.
    call_of_the_ancestors     = {  94888, 443450, 1 }, -- Benefiting from Undulation calls an Ancestor to your side for 6 sec. Casting Unleash Life calls an Ancestor to your side for 12 sec. Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell.
    call_of_the_elements      = { 103592, 383011, 1 }, -- Reduces the cooldown of Totemic Recall by 60 sec.
    capacitor_totem           = { 103579, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after 2 sec, stunning all enemies within 9 yards for 3 sec.
    chain_heal                = { 103588,   1064, 1 }, -- Heals the friendly target for 171,930, then jumps up to 15 yards to heal the 3 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_lightning           = { 103583, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing 54,244 Nature damage and then jumping to additional nearby enemies. Affects 5 total targets. If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by 20%. Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by 0.5 sec. Consumes Maelstrom Weapon for increased cast speed and damage.
    cleanse_spirit            = { 103608,  51886, 1 }, -- Removes all Curse effects from a friendly target.
    creation_core             = { 103592, 383012, 1 }, -- Totemic Recall affects an additional totem.
    earth_elemental           = { 103585, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for 1 min. While this elemental is active, your maximum health is increased by 15%.
    earth_shield              = { 103596,    974, 1 }, -- Protects the target with an earthen shield, increasing your healing on them by 20% and healing them for 105,153 when they take damage. This heal can only occur once every 3 sec. Maximum 9 charges. Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.
    earthen_communion         = {  94858, 443441, 1 }, -- Earth Shield has an additional 3 charges and heals you for 25% more.
    earthgrab_totem           = { 103617,  51485, 1 }, -- Summons a totem at the target location for 30 sec. The totem pulses every 2 sec, rooting all enemies within 9 yards for 8 sec. Enemies previously rooted by the totem instead suffer 50% movement speed reduction.
    elemental_orbit           = { 103602, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1. You can have Earth Shield on yourself and one ally at the same time.
    elemental_resistance      = { 103601, 462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by 6% for 3 sec.
    elemental_reverb          = {  94869, 443418, 1 }, -- Lava Burst gains an additional charge and deals 5% increased damage.
    elemental_warding         = { 103597, 381650, 1 }, -- Reduces all magic damage taken by 6%.
    encasing_cold             = { 103619, 462762, 1 }, -- Frost Shock snares its targets by an additional 10% and its duration is increased by 2 sec.
    enhanced_imbues           = { 103606, 462796, 1 }, -- The effects of your weapon imbues are increased by 15%.
    final_calling             = {  94875, 443446, 1 }, -- When an Ancestor departs, they cast Hydrobubble on a nearby injured ally.  Hydrobubble
    fire_and_ice              = { 103605, 382886, 1 }, -- Increases all Fire and Frost damage you deal by 3%.
    frost_shock               = { 103604, 196840, 1 }, -- Chills the target with frost, causing 60,449 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    graceful_spirit           = { 103626, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by 30 sec and increases your movement speed by 20% while it is active.
    greater_purge             = { 103624, 378773, 1 }, -- Purges the enemy target, removing 2 beneficial Magic effects.
    guardians_cudgel          = { 103618, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind              = { 103591, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem      = { 103590,   5394, 1 }, -- Summons a totem at your feet for 18 sec that heals an injured party or raid member within 46 yards for 80,597 every 1.9 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    heed_my_call              = {  94884, 443444, 1 }, -- Ancestors last an additional 4 sec.
    hex                       = { 103623,  51514, 1 }, -- Transforms the enemy into a frog for 1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    jet_stream                = { 103607, 462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by 10% and now removes snares.
    latent_wisdom             = {  94862, 443449, 1 }, -- Your Ancestors' spells are 25% more powerful.
    lava_burst                = { 103598,  51505, 1 }, -- Hurls molten lava at the target, dealing 101,287 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.
    lightning_lasso           = { 103589, 305483, 1 }, -- Grips the target in lightning, stunning and dealing 614,591 Nature damage over 5 sec while the target is lassoed. Can move while channeling.
    maelstrom_supremacy       = {  94883, 443447, 1 }, -- Increases the healing done by Healing Wave, Healing Surge, Wellspring, Downpour, and Chain Heal by 15%.
    mana_spring               = { 103587, 381930, 1 }, -- Your Stormstrike casts restore 2,625 mana to you and 4 allies nearest to you within 40 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natural_harmony           = {  94858, 443442, 1 }, -- Reduces the cooldown of Nature's Guardian by 15 sec and causes it to heal for an additional 10% of your maximum health.
    natures_fury              = { 103622, 381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by 4%.
    natures_guardian          = { 103613,  30884, 1 }, -- When your health is brought below 35%, you instantly heal for 20% of your maximum health. Cannot occur more than once every 45 sec.
    natures_swiftness         = { 103620, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    offering_from_beyond      = {  94887, 443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of Riptide by 2 sec.
    planes_traveler           = { 103611, 381647, 1 }, -- Reduces the cooldown of Astral Shift by 30 sec.
    poison_cleansing_totem    = { 103609, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within 34 yards every 1.5 sec for 9 sec.
    primordial_bond           = { 103612, 381764, 1 }, -- While you have an elemental active, your damage taken is reduced by 5%.
    primordial_capacity       = {  94860, 443448, 1 }, -- Increases your maximum mana by 5%. Tidal Waves can now stack up to 4 times.
    purge                     = { 103624,    370, 1 }, -- Purges the enemy target, removing 1 beneficial Magic effect.
    refreshing_waters         = { 103594, 378211, 1 }, -- Your Healing Surge is 25% more effective on yourself.
    routine_communication     = {  94884, 443445, 1 }, -- Riptide has a 15% chance to call an Ancestor to your side for 6 sec.
    seasoned_winds            = { 103628, 355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by 15% for 18 sec. Stacks up to 2 times.
    spirit_walk               = { 103591,  58875, 1 }, -- Removes all movement impairing effects and increases your movement speed by 60% for 8 sec.
    spirit_wolf               = { 103581, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain 5% increased movement speed and 5% damage reduction every 1 sec, stacking up to 4 times.
    spiritwalkers_aegis       = { 103626, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for 5 sec.
    spiritwalkers_grace       = { 103584,  79206, 1 }, -- Calls upon the guidance of the spirits for 15 sec, permitting movement while casting Shaman spells. Castable while casting.
    spiritwalkers_momentum    = {  94861, 443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by 1 sec, up to a maximum of 4 sec.
    static_charge             = { 103618, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by 5 sec for each enemy it stuns, up to a maximum reduction of 20 sec.
    stone_bulwark_totem       = { 103629, 108270, 1 }, -- Summons a totem at your feet that grants you an absorb shield preventing 2.1 million damage for 15 sec, and an additional 214,354 every 5 sec for 30 sec.
    thunderous_paws           = { 103581, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional 25% for the first 3 sec. May only occur once every 20 sec.
    thundershock              = { 103621, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by 5 sec.
    thunderstorm              = { 103603,  51490, 1 }, -- Calls down a bolt of lightning, dealing 9,201 Nature damage to all enemies within 10 yards, reducing their movement speed by 40% for 5 sec, and knocking them upward. Usable while stunned.
    totemic_focus             = { 103625, 382201, 1 }, -- Increases the radius of your totem effects by 15%. Increases the duration of your Earthbind and Earthgrab Totems by 10 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, and Wind Rush Totems by 3.0 sec.
    totemic_projection        = { 103586, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall            = { 103595, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge             = { 103599, 381867, 1 }, -- Reduces the cooldown of your totems by 6 sec.
    traveling_storms          = { 103621, 204403, 1 }, -- Thunderstorm now can be cast on allies within 40 yards, reduces enemies movement speed by 60%, and knocks enemies 25% further.
    tremor_totem              = { 103593,   8143, 1 }, -- Summons a totem at your feet that shakes the ground around it for 13 sec, removing Fear, Charm and Sleep effects from party and raid members within 34 yards.
    voodoo_mastery            = { 103600, 204268, 1 }, -- Your Hex target is slowed by 70% during Hex and for 6 sec after it ends. Reduces the cooldown of Hex by 15 sec.
    wind_rush_totem           = { 103627, 192077, 1 }, -- Summons a totem at the target location for 18 sec, continually granting all allies who pass within 11 yards 40% increased movement speed for 7 sec.
    wind_shear                = { 103615,  57994, 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for 2 sec.
    winds_of_alakir           = { 103614, 382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by 10%. When you have 3 or more totems active, your movement speed is increased by 15%.

    -- Enhancement
    alpha_wolf                = {  80970, 198434, 1 }, -- While Feral Spirits are active, Chain Lightning and Crash Lightning causes your wolves to attack all nearby enemies for 13,429 Physical damage every 2 sec for the next 8 sec.
    ascendance                = {  92219, 114051, 1 }, -- Transform into an Air Ascendant for 15 sec, immediately dealing 191,191 Nature damage to any enemy within 8 yds, reducing the cooldown and cost of Stormstrike by 60%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a 30 yd range.
    ashen_catalyst            = {  80947, 390370, 1 }, -- Each time Flame Shock deals periodic damage, it increases the damage of your next Lava Lash by 12% up to 96%, and reduces the cooldown of your Lava Lash by 0.5 sec.
    converging_storms         = {  80973, 384363, 1 }, -- Each target hit by Crash Lightning increases the damage of your next Stormstrike by 25%, up to a maximum of 6 stacks.
    crash_lightning           = {  80974, 187874, 1 }, -- Electrocutes all enemies in front of you, dealing 143,917 Nature damage. Hitting 2 or more targets enhances your weapons for 12 sec, causing Stormstrike, Ice Strike, and Lava Lash to also deal 43,611 Nature damage to all targets in front of you. Damage reduced beyond 6 targets.
    crashing_storms           = {  80953, 334308, 1 }, -- Crash Lightning damage increased by 40%. Chain Lightning now jumps to 2 extra targets.
    deeply_rooted_elements    = {  92219, 378270, 1 }, -- Each stack of Maelstrom Weapon consumed has a 0.6% chance to activate Ascendance for 6.0 sec.  Ascendance Transform into an Air Ascendant for 15 sec, immediately dealing 191,191 Nature damage to any enemy within 8 yds, reducing the cooldown and cost of Stormstrike by 60%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a 30 yd range.
    doom_winds                = {  80959, 384352, 1 }, -- Unleash a devastating storm around yourself, dealing 66,279 Stormstrike damage every 1 sec to nearby enemies for 8 sec. Increases your chance to activate Windfury Weapon by 200%, and the damage of Windfury Weapon by 10%.
    elemental_assault         = {  80962, 210853, 2 }, -- Stormstrike damage is increased by 10%, and Stormstrike, Lava Lash, and Ice Strike have a 50% chance to generate 1 stack of Maelstrom Weapon.
    elemental_blast           = {  80966, 117014, 1 }, -- Harnesses the raw power of the elements, dealing 180,793 Elemental damage and increasing your Critical Strike or Haste by 3% or Mastery by 6% for 10 sec. If Lava Burst is known, Elemental Blast replaces Lava Burst and gains 1 additional charge.
    elemental_spirits         = {  80970, 262624, 1 }, -- Your Feral Spirits are now imbued with Fire, Frost, or Lightning, increasing your damage dealt with that element by 10%, but now only increase your Physical damage dealt by 10%.
    elemental_weapons         = {  80961, 384355, 1 }, -- Each active weapon imbue Increases all Fire, Frost, and Nature damage dealt by 2.5%.
    feral_spirit              = {  80972,  51533, 1 }, -- Summons two Spirit Wolves that aid you in battle for 15 sec. They are immune to movement-impairing effects, and each Feral Spirit summoned grants you 15% increased Physical damage dealt by your abilities. Feral Spirit generates one stack of Maelstrom Weapon immediately, and one stack every 3 sec for 15 sec.
    fire_nova                 = {  80944, 333974, 1 }, -- Erupt a burst of fiery damage from all targets affected by your Flame Shock, dealing 45,519 Flamestrike damage to up to 6 targets within 8 yds of your Flame Shock targets. Each eruption from Fire Nova generates 1 stack of Maelstrom Weapon.
    flowing_spirits           = {  80971, 469314, 1 }, -- Your damaging abilities have a 10% chance to summon a Feral Spirit for 8 sec.
    flurry                    = { 103642, 382888, 1 }, -- Increases your attack speed by 15% for your next 3 melee swings after dealing a critical strike with a spell or ability.
    forceful_winds            = {  80969, 262647, 1 }, -- Windfury causes each successive Windfury attack within 15 sec to increase the damage of Windfury by 15%, stacking up to 5 times.
    hailstorm                 = {  80944, 334195, 1 }, -- Each stack of Maelstrom Weapon consumed increases the damage of your next Frost Shock by 15%, and causes your next Frost Shock to hit 1 additional target per Maelstrom Weapon stack consumed, up to 5. Consuming at least 2 stacks of Hailstorm generates 1 stack of Maelstrom Weapon.
    hot_hand                  = {  80945, 201900, 2 }, -- Melee auto-attacks with Flametongue Weapon active have a 5% chance to reduce the cooldown of Lava Lash by 33% and increase the damage of Lava Lash by 15% for 8 sec.
    ice_strike                = {  80956, 470194, 1 }, -- Strike your target with an icy blade, dealing 286,978 Frost damage and snaring them by 50% for 6 sec. Ice Strike increases the damage of your next Frost Shock by 100% and generates 1 stack of Maelstrom Weapon.
    ice_strike_passive        = {  80956, 466467, 1 }, -- Whenever you spend Maelstrom Weapon, your Frost Shock has a chance to become Ice Strike. Ice Strike Strike your target with an icy blade, dealing 286,978 Frost damage and snaring them by 50% for 6 sec. Ice Strike increases the damage of your next Frost Shock by and generates 1 stack of Maelstrom Weapon. This ability has a 40 yard range.
    improved_maelstrom_weapon = {  80957, 383303, 1 }, -- Maelstrom Weapon now increases the damage of spells it affects by 20% per stack and the healing of spells it affects by 20% per stack.
    lashing_flames            = {  80948, 334046, 1 }, -- Lava Lash and Sundering increases the damage of Flame Shock on its target by 100% for 20 sec.
    lava_lash                 = {  80942,  60103, 1 }, -- Charges your off-hand weapon with lava and burns your target, dealing 123,154 Fire damage. Damage is increased by 100% if your offhand weapon is imbued with Flametongue Weapon. Lava Lash will spread Flame Shock from your target to 5 nearby targets.
    legacy_of_the_frost_witch = {  80951, 384450, 2 }, -- Consuming 10 stacks of Maelstrom Weapon will reset the cooldown of Stormstrike and increases the damage of your Physical and Frost abilities by 5% for 8 sec.
    maelstrom_weapon          = {  80941, 187880, 1 }, -- When you deal damage with a melee weapon, you have a chance to gain Maelstrom Weapon, stacking up to 10 times. Each stack of Maelstrom Weapon reduces the cast time of your next damage or healing spell by 20% and increase its damage by 25% or its healing by 25%. A maximum of 10 stacks of Maelstrom Weapon can be consumed at a time.
    molten_assault            = {  80943, 334033, 1 }, -- Lava Lash cooldown reduced by 6.0 sec, and if Lava Lash is used against a target affected by your Flame Shock, Flame Shock will be spread to up to 5 nearby enemies.
    molten_thunder            = { 103848, 469344, 1 }, -- The cooldown of Sundering is reduced by 10 sec, but it can no longer Incapacitate. Sundering has a 40% chance to reset its own cooldown, increased by 12% for up to 5 targets. Each consecutive reset reduces these chances by half.
    overflowing_maelstrom     = {  80938, 384149, 1 }, -- Your damage or healing spells will now consume up to 10 Maelstrom Weapon stacks.
    primordial_storm          = {  80963, 1218047, 1 }, -- Primordial Wave transforms into a single use Primordial Storm for 15 sec after it is cast. Primordial Storm Devastate nearby enemies with a Primordial Storm dealing 79,801 Flamestrike, 79,801 Froststrike, 79,801 Stormstrike damage, and unleashing a Lightning Bolt or a Chain Lightning at 150% effectiveness. Deals reduced damage beyond 5 targets. Consumes Maelstrom Weapon for increased damage.
    primordial_wave           = {  80965, 375982, 1 }, -- Blast all targets affected by your Flame Shock within 45 yards with a Primordial Wave, dealing 460,943 Elemental damage. Primordial Wave generates 5 stacks of Maelstrom Weapon.
    raging_maelstrom          = {  80939, 384143, 1 }, -- Maelstrom Weapon can now stack 5 additional times, and Maelstrom Weapon now increases the damage of spells it affects by an additional 5% per stack and the healing of spells it affects by an additional 5% per stack.
    splintered_elements       = {  80964, 382042, 2 }, -- Primordial Wave grants you 10% Haste plus 4% for each additional targets blasted by Primordial Wave for 12 sec.
    static_accumulation       = {  80950, 384411, 2 }, -- 10% chance to refund Maelstrom Weapon stacks spent on Lightning Bolt, Tempest, or Chain Lightning. While Ascendance is active, generate 1 Maelstrom Weapon stack every 1 sec.
    stormblast                = {  80960, 319930, 1 }, -- Stormstrike has an additional charge. Stormsurge now also causes your next Stormstrike to deal 25% additional damage as Nature damage, stacking up to 2 times.
    stormflurry               = {  80954, 344357, 1 }, -- Stormstrike has a 25% chance to strike the target an additional time for 40% of normal damage. This effect can chain off of itself.
    storms_wrath              = {  80967, 392352, 1 }, -- Increase the chance for Mastery: Enhanced Elements to trigger Windfury and Stormsurge by 150%.
    sundering                 = {  80975, 197214, 1 }, -- Shatters a line of earth in front of you with your main hand weapon, causing 193,251 Flamestrike damage and Incapacitating any enemy hit for 2 sec.
    swirling_maelstrom        = {  80955, 384359, 1 }, -- Consuming at least 2 stacks of Hailstorm, and each explosion from Fire Nova now also grants you 1 stack of Maelstrom Weapon.
    tempest_strikes           = {  80966, 428071, 1 }, -- Stormstrike, Ice Strike, and Lava Lash have a 100% chance to discharge electricity at your target, dealing 35,689 Nature damage.
    thorims_invocation        = {  80949, 384444, 1 }, -- Increases the damage of Lightning Bolt and Chain Lightning by 20%, and reduces the cooldown of Ascendance by 60 sec. While Ascendance is active, Windstrike automatically consumes up to 5 Maelstrom Weapon stacks to discharge a Lightning Bolt or Chain Lightning at 100% effectiveness at your enemy, whichever you most recently used.
    unrelenting_storms        = {  80973, 470490, 1 }, -- When Crash Lightning hits only 1 target, it activates Windfury Weapon and its cooldown is reduced by 40%.
    unruly_winds              = {  80968, 390288, 1 }, -- Windfury Weapon has a 100% chance to trigger a third attack.
    voltaic_blaze             = { 103871, 470053, 1 }, -- Tempest, Lightning Bolt and Chain Lightning have a high chance to make your next Flame Shock become Voltaic Blaze. Voltaic Blaze Instantly shocks the target and 5 nearby enemies with blazing thunder, causing 358,219 Nature damage and applying Flame Shock. Generates 1 stack of Maelstrom Weapon.
    windfury_weapon           = {  80958,  33757, 1 }, -- Imbue your main-hand weapon with the element of Wind for 1 |4hour:hrs;. Each main-hand attack has a 28% chance to trigger three extra attacks, dealing 21,471 Physical damage each. Windfury causes each successive Windfury attack within 15 sec to increase the damage of Windfury by 15%, stacking up to 5 times.
    witch_doctors_ancestry    = {  80971, 384447, 1 }, -- Increases the chance to gain a stack of Maelstrom Weapon by 4%, and whenever you gain a stack of Maelstrom Weapon, the cooldown of Feral Spirits is reduced by 1.0 sec.

    -- Totemic
    amplification_core        = {  94874, 445029, 1 }, -- While Surging Totem is active, your damage and healing done is increased by 3%.
    earthsurge                = {  94881, 455590, 1 }, -- Casting Sundering within 40 yards of your Surging Totem causes it to create a Tremor at 100% effectiveness at the target area.
    imbuement_mastery         = {  94871, 445028, 1 }, -- Increases the chance for Windfury Weapon to trigger by 5% and increases its damage by 8%. When Flametongue Weapon triggers from Windfury Weapon attacks, it has a chance to gather a whirl of flame around the target, dealing 300% of its damage to all nearby enemies.
    lively_totems             = {  94882, 445034, 1 }, -- Lava Lash has a chance to summon a Searing Totem to hurl Searing Bolts that deal 44,552 Fire damage to a nearby enemy. Lasts 8 sec. Frost Shocks empowered by Hailstorm, Lava Lash, and Fire Nova cause your Searing totems to shoot a Searing Volley at up to 5 nearby enemies for 85,541 Fire damage.
    oversized_totems          = {  94859, 445026, 1 }, -- Increases the size and radius of your totems by 15%, and the health of your totems by 30%.
    oversurge                 = {  94874, 445030, 1 }, -- Surging Totem deals 50% more damage during Ascendance.
    pulse_capacitor           = {  94866, 445032, 1 }, -- Increases the damage of Surging Totem by 25%.
    reactivity                = {  94872, 445035, 1 }, -- While Hot Hand is active Lash Lava shatters the earth, causing a Sundering at 50% effectiveness. Sunderings from this effect do not Incapacitate.
    supportive_imbuements     = {  94866, 445033, 1 }, -- Increases the critical strike chance of Flametongue Weapon by 25%, and its critical strike damage by 100%.
    surging_totem             = {  94877, 444995, 1, "totemic" }, -- Summons a totem at the target location that creates a Tremor immediately and every 5.1 sec for 122,862 Flamestrike damage. Damage reduced beyond 5 targets. Lasts 24 sec.
    swift_recall              = {  94859, 445027, 1 }, -- Successfully removing a harmful effect with Tremor Totem or Poison Cleansing Totem, or controlling an enemy with Capacitor Totem or Earthgrab Totem reduces the cooldown of the totem used by 5 sec. Cannot occur more than once every 20 sec per totem.
    totemic_coordination      = {  94881, 445036, 1 }, -- Increases the critical strike chance of your Searing Totem's attacks by 15%, and its critical strike damage by 30%.
    totemic_rebound           = {  94890, 445025, 1 }, -- Lightning Bolt, Chain Lightning and Elemental Blast has a chance to unleash a Surging Bolt at your Surging Totem, increasing the totem's damage by 10%, and then redirecting the bolt to your target for 81,575 Nature damage. The damage bonus effect can stack.
    whirling_elements         = {  94879, 445024, 1 }, -- Elemental motes orbit around your Surging Totem. Your abilities consume the motes for enhanced effects. Air: Your next Lightning Bolt, Chain Lightning or Elemental Blast unleashes 3 Surging Bolts at your Surging Totem. Earth: Direct damage of your next Flame Shock is increased by 300% and it is applied to 5 nearby enemies. Fire: Your next Lava Lash or Fire Nova grants you Hot Hands for 8 sec.
    wind_barrier              = {  94891, 445031, 1 }, -- If you have a totem active, your totem grants you a shield absorbing 300,925 damage for 30 sec every 30 sec.

    -- Stormbringer
    arc_discharge             = {  94885, 455096, 1 }, -- Tempest causes your next Chain Lightning or Lightning Bolt to be instant cast, deal 40% increased damage, and cast an additional time. Can accumulate up to 2 charges.
    awakening_storms          = {  94867, 455129, 1 }, -- Stormstrike, Lightning Bolt, and Chain Lightning have a chance to strike your target for 139,705 Nature damage. Every 3 times this occurs, your next Lightning Bolt is replaced by Tempest.
    conductive_energy         = {  94868, 455123, 1 }, -- Gain the effects of the Lightning Rod talent:  Lightning Rod Tempest, Lightning Bolt, Elemental Blast, Primordial Wave and Chain Lightning make your target a Lightning Rod for 8 sec. Lightning Rods take 10% of all damage you deal with Tempest, Lightning Bolt, and Chain Lightning.
    electroshock              = {  94863, 454022, 1 }, -- Tempest increases your movement speed by 20% for 5 sec.
    lightning_conduit         = {  94863, 467778, 1 }, -- You have a chance to get struck by lightning, increasing your movement speed by 50% for 5 sec. The effectiveness is increased to 100% in outdoor areas. You call down a Thunderstorm when you Reincarnate.
    natures_protection        = {  94880, 454027, 1 }, -- Lightning Shield reduces the damage you take by 3%.
    rolling_thunder           = {  94889, 454026, 1 }, -- Tempest summons a Nature Feral Spirit for 15 sec.
    storm_swell               = {  94873, 455088, 1 }, -- Tempest grants 10% Mastery for 6 sec.
    stormcaller               = {  94893, 454021, 1 }, -- Increases the critical strike chance of your Nature damage spells by 5% and the critical strike damage of your Nature spells by 5%.
    supercharge               = {  94873, 455110, 1 }, -- Lightning Bolt, Tempest, and Chain Lightning have a 35% chance to refund 2 Maelstrom Weapon stacks.
    surging_currents          = {  94880, 454372, 1 }, -- When you cast Tempest you gain Surging Currents, increasing the effectiveness of your next Chain Heal or Healing Surge by 20%, up to 100%.
    tempest                   = {  94892, 454009, 1, "stormbringer" }, -- Every 40 Maelstrom Weapon stacks spent replaces your next Lightning Bolt with Tempest.
    unlimited_power           = {  94886, 454391, 1 }, -- Spending Maelstrom Weapon stacks grants you 1% haste for 15 sec. Multiple applications may overlap.
    voltaic_surge             = {  94870, 454919, 1 }, -- Crash Lightning and Chain Lightning damage increased by 15%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5575, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by 50% for 5 sec. When the effect ends, enemies within 6 yards are knocked in the air and take 392,977 Physical damage.
    counterstrike_totem = 3489, -- (204331) Summons a totem at your feet for 15 sec. Whenever enemies within 23 yards of the totem deal direct damage, the totem will deal 100% of the damage dealt back to attacker.
    electrocute         = 5658, -- (206642)
    grounding_totem     = 3622, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within 34 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    shamanism           =  722, -- (193876)
    static_field_totem  = 5438, -- (355580) Summons a totem with 4% of your health at the target location for 6 sec that forms a circuit of electricity that enemies cannot pass through.
    stormweaver         = 5596, -- (410673)
    totem_of_wrath      = 3487, -- (460697)
    unleash_shield      = 3492, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
} )



-- Auras
spec:RegisterAuras( {
    -- Damage and healing increased by $w1%.
    amplification_core = {
        id = 456369,
        duration = 20.0,
        max_stack = 1,
    },
    -- Talent: A percentage of damage or healing dealt is copied as healing to up to 3 nearby injured party or raid members.
    -- https://wowhead.com/ptr-2/spell=108281
    --[[ancestral_guidance = {
        id = 108281,
        duration = 10,
        tick_time = 0.5,
        max_stack = 1
    },--]]
    -- Health increased by $s1%.    If you die, the protection of the ancestors will allow you to return to life.
    -- https://wowhead.com/ptr-2/spell=207498
    ancestral_protection = {
        id = 207498,
        duration = 30,
        max_stack = 1
    },
    -- Your next 1 Chain Lightning or Lightning Bolt spells are instant cast and will deal 40% increased damage.
    arc_discharge = {
        id = 470532,
        duration = 15.0,
        max_stack = 2
    },
    -- Movement speed reduced by $w1%.
    arctic_snowstorm = {
        id = 462765,
        duration = 8.0,
        max_stack = 1
    },
    -- Talent: Transformed into a powerful Air ascendant. Auto attacks have a $114089r yard range. Stormstrike is empowered and has a $114089r yard range.$?s384411[    Generating $384411s1 $lstack:stacks; of Maelstrom Weapon every $384437t1 sec.][]
    -- https://wowhead.com/ptr-2/spell=114051
    ascendance = {
        id = 114051,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Damage of your next Lava Lash increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=390371
    ashen_catalyst = {
        id = 390371,
        duration = 15,
        max_stack = 8
    },
    awakening_storms = {
        id = 462131,
        duration = 3600,
        max_stack = 4
    },
    -- Haste increased by $w1%.
    -- https://wowhead.com/ptr-2/spell=2825
    bloodlust = {
        id = 2825,
        duration = 40,
        max_stack = 1
    },
    -- When you deal damage, $w1% is dealt to your lowest health ally within $204331m2 yards.
    counterstrike_totem = {
        id = 208997,
        duration = 15.0,
        max_stack = 1,
    },
    -- Increases nature damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=224127
    crackling_surge = {
        id = 224127,
        duration = 15,
        max_stack = 20,
        meta = {
            active = function( t ) return active_crackling_surges end,
        },
    },
    crash_lightning = {
        id = 187878,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Damage of your next Crash Lightning increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=333964
    cl_crash_lightning = {
        id = 333964,
        duration = 15,
        max_stack = 6,
        copy = "converging_storms"
    },
    -- Talent: Chance to activate Windfury Weapon increased to ${$319773h}.1%.  Damage dealt by Windfury Weapon increased by $s2%.
    -- https://wowhead.com/ptr-2/spell=384352
    doom_winds_talent = {
        id = 466772,
        duration = 8,
        max_stack = 1,
        copy = 384352
    },
    doom_winds_buff = { -- legendary.
        id = 335903,
        duration = 8,
        tick_time = 1,
        max_stack = 1,
    },
    doom_winds_debuff = {
        id = 335904,
        duration = 60,
        tick_time = 1,
        max_stack = 1,
        copy = "doom_winds_cd",
    },
    doom_winds = {
        alias = { "doom_winds_talent", "doom_winds_buff" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 8,
        max_stack = 1,
    },
    -- Maximum health increased by $w3%.
    downpour = {
        id = 207778,
        duration = 6.0,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/ptr-2/spell=198103
    earth_elemental = {
        id = 198103,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Heals for ${$w2*(1+$w1/100)} upon taking damage.
    -- https://wowhead.com/ptr-2/spell=974
    earth_shield = {
        id = 974,
        duration = 600,
        type = "Magic",
        max_stack = 9
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/ptr-2/spell=3600
    earthbind = {
        id = 3600,
        duration = 5,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Increases physical damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=392375
    earthen_weapon = {
        id = 392375,
        duration = 15,
        type = "Magic",
        max_stack = 20,
        meta = {
            active = function( t ) return active_earthen_weapons end,
        },
    },
    -- Rooted.
    -- https://wowhead.com/ptr-2/spell=64695
    earthgrab = {
        id = 64695,
        duration = 8,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=382024
    earthliving_weapon = {
        id = 382024,
        duration = 12,
        max_stack = 1
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    -- https://wowhead.com/ptr-2/spell=320125
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
    -- Movement speed increased by $w1%.
    electroshock = {
        id = 454025,
        duration = 5.0,
        max_stack = 1
    },
    -- Fire, Frost, and Nature damage taken reduced by $w1%.
    elemental_resistance = {
        id = 462568,
        duration = 3.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Cannot move while using Far Sight.
    -- https://wowhead.com/ptr-2/spell=6196
    far_sight = {
        id = 6196,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Generating $s1 stack of Maelstrom Weapon every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=333957
    feral_spirit = {
        id = 333957,
        duration = 15,
        tick_time = 3,
        max_stack = 20,
        meta = {
            active = function( t ) return active_feral_spirits end,
        },
        copy = 469328,
    },
    -- Suffering $w2 Fire damage every $t2 sec.
    -- https://wowhead.com/ptr-2/spell=188389
    flame_shock = {
        id = 188389,
        duration = 18,
        tick_time = 2.0,
        pandemic = true,
        type = "Magic",
        max_stack = 1
    },
    -- Each of your weapon attacks causes up to ${$max(($<coeff>*$AP),1)} additional Fire damage.
    -- https://wowhead.com/ptr-2/spell=319778
    flametongue_weapon = {
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Attack speed increased by $w1%.
    -- https://wowhead.com/ptr-2/spell=382889
    flurry = {
        id = 382889,
        duration = 15,
        max_stack = 3
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/ptr-2/spell=196840
    frost_shock = {
        id = 196840,
        duration = function() return 6 + 2 * talent.encasing_cold.rank end,
        type = "Magic",
        max_stack = 1
    },
    converging_storms = {
        id = 198300,
        duration = 12,
        max_stack = 6,
    },
    -- Increases movement speed by $?s382215[${$382216s1+$w2}][$w2]%.$?$w3!=0[  Less hindered by effects that reduce movement speed.][]
    -- https://wowhead.com/ptr-2/spell=2645
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Frost Shock will deal $s1% additional damage, and hit up to ${$334195s1/$s2} additional $Ltarget:targets;.
    -- https://wowhead.com/ptr-2/spell=334196
    hailstorm = {
        id = 334196,
        duration = 20,
        max_stack = 5
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/ptr-2/spell=73920
    healing_rain = {
        id = 73920,
        duration = 10,
        max_stack = 1
    },
    -- Healing $?s147074[two injured party or raid members][an injured party or raid member] every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=5672
    healing_stream = {
        id = 5672,
        duration = 15,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/ptr-2/spell=51514
    hex = {
        id = 51514,
        duration = 60,
        mechanic = "polymorph",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Lava Lash damage increased by $s1% and cooldown reduced by ${$s2/4}%.
    -- https://wowhead.com/ptr-2/spell=215785
    hot_hand = {
        id = 215785,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/ptr-2/spell=342240
    ice_strike_snare = {
        id = 342240,
        duration = 6,
        max_stack = 1,
    },
    -- Talent: Damage of your next Frost Shock increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=384357
    ice_strike = {
        id = 384357,
        duration = 12,
        max_stack = 1
    },
    -- Frost Shock damage increased by $w2%.
    -- https://wowhead.com/ptr-2/spell=210714
    icefury = {
        id = 210714,
        duration = 25,
        type = "Magic",
        max_stack = 4
    },
    -- Increases frost damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=224126
    icy_edge = {
        id = 224126,
        duration = 15,
        max_stack = 20,
        meta = {
            active = function( t ) return active_icy_edges end,
        },
    },
    -- Fire damage inflicted every $t2 sec.
    -- https://wowhead.com/ptr-2/spell=118297
    immolate = {
        id = 118297,
        duration = 21,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken from the Shaman's Flame Shock increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=334168
    lashing_flames = {
        id = 334168,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Damage dealt by your physical abilities increased by $w1%.
    -- https://wowhead.com/ptr-2/spell=384451
    legacy_of_the_frost_witch = {
        id = 384451,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Stunned. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=305485
    lightning_lasso = {
        id = 305485,
        duration = 5,
        tick_time = 1,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Casting Shaman's Lightning Bolt and Chain Lightning also deal $210689s2% of their damage to the Lightning Rod.
    lightning_rod = {
        id = 197209,
        duration = 8.0,
        max_stack = 1,
    },
    -- Chance to deal $192109s1 Nature damage when you take melee damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].
    -- https://wowhead.com/ptr-2/spell=192106
    lightning_shield = {
        id = 192106,
        duration = 1800,
        max_stack = 1
    },
    -- Searing Totem is hurling Searing Bolts at nearby enemies.
    lively_totems = {
        id = 461242,
        duration = 8.0,
        max_stack = 1,
    },
    -- Talent: Your next damage or healing spell has its cast time reduced by ${$max($187881s1, -100)*-1}%$?s383303[ and damage or healing increased by][]$?s383303&!s384149[ ${$min($187881w2, 5*$s~2)}%]?s383303&s384149[ $187881w2%][].
    -- https://wowhead.com/ptr-2/spell=344179
    maelstrom_weapon = {
        id = 344179,
        duration = 30,
        type = "Magic",
        max_stack = function() return talent.raging_maelstrom.enabled and 10 or 5 end
    },
    -- Increases fire damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=224125
    molten_weapon = {
        id = 224125,
        duration = 15,
        type = "Magic",
        max_stack = 20,
        meta = {
            active = function( t ) return active_molten_weapons end,
        },
    },
    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    -- https://wowhead.com/ptr-2/spell=378081
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        onRemove = function( t )
            -- 20221117:  This function is triggered when the buff is removed.
            setCooldown( "natures_swiftness", action.natures_swiftness.cooldown )
        end
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/ptr-2/spell=280205
    pack_spirit = {
        id = 280205,
        duration = 3600,
        max_stack = 1
    },
    -- Cleansing $383015s1 poison effect from a nearby party or raid member every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=383014
    poison_cleansing = {
        id = 383014,
        duration = function() return 6 + 3 * talent.tidecallers_guard.rank end,
        tick_time = 1.5,
        type = "Magic",
        max_stack = 1
    },
    primal_lava_actuators = {
        id = 335896,
        duration = 15,
        max_stack = 20,
    },
    -- https://www.wowhead.com/spell=1218125
    -- Primordial Storm Primordial Wave has been replaced by Primordial Storm.
    primordial_storm = {
        id = 1218125,
        duration = 15,
        max_stack = 1,
    },
    primordial_wave = {
        id = 375986,
        duration = 10,
        max_stack = 1,
        copy = 327164
    },
    -- Heals $w2 every $t2 seconds.
    -- https://wowhead.com/ptr-2/spell=61295
    riptide = {
        id = 61295,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Mastery increased by $w1% and auto attacks have a $h% chance to instantly strike again.
    skyfury = {
        id = 462854,
        duration = 3600.0,
        max_stack = 1,
        shared = "player",
        dot = "buff"
    },
    -- Talent: Increases movement speed by $s1%.
    -- https://wowhead.com/ptr-2/spell=58875
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Able to move while casting all Shaman spells.
    -- https://wowhead.com/ptr-2/spell=79206
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/ptr-2/spell=118905
    static_charge = {
        id = 118905,
        duration = 3,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Absorbing up to $w1 damage.
    stone_bulwark = {
        id = 114893,
        duration = 15,
        max_stack = 1,
    },
    -- Mastery increased by $w1%.
    storm_swell = {
        id = 455089,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your next Stormstrike deals $s1% additional damage as Nature damage.
    stormblast = {
        id = 470466,
        duration = 12,
        max_stack = 1,
    },
    -- Your next Lightning Bolt or Chain Lightning will deal $s2% increased damage and be instant cast.
    -- https://wowhead.com/ptr-2/spell=383009
    stormkeeper = {
        id = 383009,
        duration = 15,
        type = "Magic",
        max_stack = 2,
        copy = 320137
    },
    -- Stormstrike cooldown has been reset$?$?a319930[ and will deal $319930w1% additional damage as Nature][].
    stormsurge = {
        id = 201846,
        duration = 12.0,
        max_stack = 1,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/ptr-2/spell=197214
    sundering = {
        id = 197214,
        duration = 2,
        max_stack = 1
    },
    -- Your next Chain Heal or Healing Surge will be instant and consume no mana.
    surging_currents = {
        id = 454376,
        duration = 30.0,
        max_stack = 1,
    },
    -- Talent: Tempest
    -- https://www.wowhead.com/spell=454015/tempest
    tempest = {
        id = 454015,
        duration = 30.0,
        max_stack = 2,
        copy = { 454009, 452201 }
    },
    -- Talent: Movement speed increased by $378075s1%.
    -- https://wowhead.com/ptr-2/spell=378076
    thunderous_paws = {
        id = 378076,
        duration = 3,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s3%.
    -- https://wowhead.com/ptr-2/spell=51490
    thunderstorm = {
        id = 51490,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Your healing done is increased by $w2%.; $?a157153[Cloudburst][Healing Stream] Totem lasts an additional ${$w1/1000} sec.
    tidecallers_guard = {
        id = 457496,
        duration = 3600.0,
        max_stack = 1,

    },
    -- Healing and spell critical effect increased by $w1%.
    totem_of_wrath = {
        id = 208963,
        duration = 15.0,
        max_stack = 1,
    },
    totemic_rebound = {
        id = 458269,
        duration = 25,
        max_stack = 20
    },
    -- Your next healing spell has increased effectiveness.
    -- https://wowhead.com/ptr-2/spell=73685
    unleash_life = {
        id = 73685,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Haste increased by $s1%.
    unlimited_power = {
        id = 454394,
        duration = 15.0,
        max_stack = 1,
    },
    voltaic_blaze = {
        id = 470058,
        duration = 20,
        max_stack = 1
    },
    -- Allows walking over water.
    water_walking = {
        id = 546,
        duration = 600.0,
        max_stack = 1,
    },
    whirling_air = {
        id = 453409,
        duration = 24,
        max_stack = 1
    },
    whirling_earth = {
        id = 453406,
        duration = 24,
        max_stack = 1
    },
    whirling_fire = {
        id = 453405,
        duration = 24,
        max_stack = 1
    },
    -- Absorbs $w1 damage.
    wind_barrier = {
        id = 457387,
        duration = 30.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    wind_rush = {
        id = 192082,
        duration = function() return 5.0 + 2 * talent.ascending_air.rank end,
        max_stack = 1
    },
    windfury_weapon = {
        duration = 3600,
        max_stack = 1,
    },


    chains_of_devastation_cl = {
        id = 336736,
        duration = 20,
        max_stack = 1,
    },
    chains_of_devastation_ch = {
        id = 336737,
        duration = 20,
        max_stack = 1
    },
} )

spec:RegisterStateTable( "feral_spirit", setmetatable( {}, {
    __index = function( t, k )
        return buff.feral_spirit[ k ]
    end
} ) )

spec:RegisterStateTable( "twisting_nether", setmetatable( { onReset = function( self ) end }, {
    __index = function( t, k )
        if k == "count" then
            return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
        end

        return 0
    end
} ) )

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local vesper_heal = 0
local vesper_damage = 0
local vesper_used = 0

local vesper_expires = 0
local vesper_guid
local vesper_last_proc = 0

local last_totem_actual = 0

local recall_totems = {
    capacitor_totem = 1,
    earthbind_totem = 1,
    earthgrab_totem = 1,
    grounding_totem = 1,
    healing_stream_totem = 1,
    liquid_magma_totem = 1,
    poison_cleansing_totem = 1,
    skyfury_totem = 1,
    stoneskin_totem = 1,
    tranquil_air_totem = 1,
    tremor_totem = 1,
    wind_rush_totem = 1,
}

local recallTotem1
local recallTotem2
local tiWindow, tiSpell, tiTarget = 0, "lightning_bolt", nil
local recent_spell_hits = {}
local actual_spirits, virtual_spirits = {}, {}
local molten_weapons, virtual_molten_weapons = {}, {}
local icy_edges, virtual_icy_edges = {}, {}
local crackling_surges, virtual_crackling_surges = {}, {}
local earthen_weapons, virtual_earthen_weapons = {}, {}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    -- Deaths/despawns.
    if death_events[ subtype ] and destGUID == vesper_guid then
        vesper_guid = nil
        return
    end

    if sourceGUID == state.GUID then
        -- Summons.
        if subtype == "SPELL_SUMMON" then
            if spellID == 262627 or spellID == 426516 then
                actual_spirits[ destGUID ] = {
                    expires = GetTime() + ( state.talent.flowing_spirits.enabled and 8 or 15 ),
                    alpha_expires = 0
                }

                C_Timer.After( ( state.talent.flowing_spirits.enabled and 8 or 15 ), function()
                    actual_spirits[ destGUID ] = nil
                end )

            elseif spellID == 469328 then
                actual_spirits[ destGUID ] = {
                    expires = GetTime() + 8,
                    alpha_expires = 0
                }

                C_Timer.After( 8, function()
                    actual_spirits[ destGUID ] = nil
                end )

            elseif spellID == 324386 then
                vesper_guid = destGUID
                vesper_expires = GetTime() + 30

                vesper_heal = 3
                vesper_damage = 3
                vesper_used = 0
            end

        -- For any Maelstrom Weapon changes, force an immediate update for responsiveness.
        elseif spellID == 344179 then
            Hekili:ForceUpdate( subtype, true )

        elseif state.talent.alpha_wolf.enabled and ( spellID == 187874 or spellID == 188443 ) then
            local expires = GetTime() + 8

            for k, v in pairs( actual_spirits ) do
                v.alpha_expires = expires
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

        if state.talent.thorims_invocation.enabled and subtype == "SPELL_DAMAGE" and ( spellID == 188196 or spellID == 452201 or spellID == 188443 ) then

            -- Chain Lightning ALWAYS sets tiSpell to "chain_lightning"
            if spellID == 188443 then
                tiSpell = "chain_lightning"
                return
            end

            -- timestamp not needed if it's a chain lightning, declare after
            local now = GetTime()

            if now > tiWindow then -- "if this is a new window"
                tiWindow = GetTime() + 0.5 -- Window closure time
                tiSpell = "lightning_bolt" -- We can set to Lightning Bolt since we're at target count = 1 for now.
                tiTarget = destGUID -- To count the next target, we just need to know it wasn't this guy.
                return
            end

            -- If we're here, we're inside an active Thorim's log collection window of 0.5s.
            -- If this is hit # 3 - 99999 of the same window it doesn't matter
            if tiSpell == "chain_lightning" then return end

            -- Otherwise, check if this is a new enemy
            if destGUID ~= tiTarget then
                tiSpell = "chain_lightning" -- If so, it must be an aoe CL or tempset, and so thorims is primed to CL
                return
             end
        end

        if subtype == "SPELL_CAST_SUCCESS" then
            -- Reset in case we need to deal with an instant after a hardcast.
            vesper_last_proc = 0

            local ability = class.abilities[ spellID ]
            local key = ability and ability.key

            if key and recall_totems[ key ] then
                recallTotem2 = recallTotem1
                recallTotem1 = key
            end
        end
    end

    if destGUID == state.GUID and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) then
        if spellID == 224125 then
            insert( molten_weapons, {
                expires = GetTime() + ( state.talent.flowing_spirits.enabled and 8 or 15 )
            } )

        elseif spellID == 224126 then
            insert( icy_edges, {
                expires = GetTime() + ( state.talent.flowing_spirits.enabled and 8 or 15 )
            } )

        elseif spellID == 224127 then
            insert( crackling_surges, {
                expires = GetTime() + ( state.talent.flowing_spirits.enabled and 8 or 15 )
            } )

        elseif spellID == 392375 then
            insert( earthen_weapons, {
                expires = GetTime() + ( state.talent.flowing_spirits.enabled and 8 or 15 )
            } )

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

spec:RegisterStateExpr( "active_feral_spirits", function()
    local count = 0

    for _, v in pairs( virtual_spirits ) do
        if v.expires > query_time then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "alpha_wolf_min_remains", function()
    local minimum

    for _, v in pairs( virtual_spirits ) do
        if v.expires > query_time then
            local remains = max( 0, v.alpha_expires - query_time )
            if remains == 0 then return 0 end
            if not minimum then minimum = remains
            else minimum = min( minimum, remains ) end
        end
    end

    return minimum or 0
end )

spec:RegisterStateExpr( "active_molten_weapons", function()
    local count = 0

    for _, v in pairs( virtual_molten_weapons ) do
        if v > query_time then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "active_icy_edges", function()
    local count = 0

    for _, v in pairs( virtual_icy_edges ) do
        if v > query_time then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "active_crackling_surges", function()
    local count = 0

    for _, v in pairs( virtual_crackling_surges ) do
        if v > query_time then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "active_earthen_weapons", function()
    local count = 0

    for _, v in pairs( virtual_earthen_weapons ) do
        if v > query_time then count = count + 1 end
    end

    return count
end )

local TriggerFeralMaelstrom = setfenv( function()
    gain_maelstrom( 1 )
end, state )

local TriggerStaticAccumulation = setfenv( function()
    gain_maelstrom( 1 )
end, state )

spec:RegisterStateExpr( "ti_mode", function ()
    return tiSpell
end)

spec:RegisterStateExpr( "ti_lightning_bolt", function ()
    return ti_mode == "lightning_bolt"
end)

spec:RegisterStateExpr( "ti_chain_lightning", function ()
    return ti_mode == "chain_lightning"
end)

spec:RegisterStateExpr( "tempest_mael_count", function ()
    return GetSpellCastCount( class.abilities.tempest.id )
end )

spec:RegisterStateExpr( "time_since_tr", function ()
    return max( action.stormstrike.time_since, action.windstrike.time_since )
end )

spec:RegisterStateExpr( "time_since_as", function ()
    return max( action.stormstrike.time_since, action.windstrike.time_since, action.lightning_bolt.time_since, action.tempest.time_since, action.chain_lightning.time_since )
end )


spec:RegisterHook( "reset_precast", function ()
    tempest_mael_count = nil

    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5401 then applyBuff( "windfury_weapon" ) end
    if oh and oh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end

    if buff.windfury_weapon.down and ( now - action.windfury_weapon.lastCast < 1 ) then applyBuff( "windfury_weapon" ) end
    if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end

    if settings.pad_windstrike and cooldown.windstrike.remains > 0 and buff.ascendance.up then
        reduceCooldown( "windstrike", latency * 2 )
    end

    if settings.pad_lava_lash and cooldown.lava_lash.remains > 0 and buff.hot_hand.up then
        reduceCooldown( "lava_lash", latency * 2 )
    end

    local tick = dot.flame_shock.next_tick + 0.1
    if talent.ashen_catalyst.enabled and dot.flame_shock.ticking and cooldown.lava_lash.remains > 0.25 then
        local original = cooldown.lava_lash.remains

        while( tick < cooldown.lava_lash.expires ) do
            reduceCooldown( "lava_lash", min( cooldown.lava_lash.expires - tick, active_dot.flame_shock * 0.5 ) )
            -- addStack( "ashen_catalyst", nil, active_dot.flame_shock )
            tick = tick + dot.flame_shock.tick_time
        end

        if Hekili.ActiveDebug then Hekili:Debug( "[Ashen Catalyst] Lava Lash cooldown reduced from %.2f to %.2f.", original, cooldown.lava_lash.remains ) end
    end

    if talent.ascendance.enabled and buff.ascendance.up then
        setCooldown( "ascendance", buff.ascendance.applied + ( talent.thorims_invocation.enabled and 120 or 180 ) - now )
    end

    if vesper_expires > 0 and now > vesper_expires then
        vesper_expires = 0
        vesper_heal = 0
        vesper_damage = 0
        vesper_used = 0
    end

    vesper_totem_heal_charges = 0
    vesper_totem_dmg_charges = 0
    vesper_totem_used_charges = 0

    if totem.vesper_totem.up then
        applyBuff( "vesper_totem", totem.vesper_totem.remains )
    end

    if buff.feral_spirit.up then
        --[[ local next_mw = query_time + 3 - ( ( query_time - buff.feral_spirit.applied ) % 3 )

        while ( next_mw <= buff.feral_spirit.expires ) do
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, next_mw, "AURA_PERIODIC" )
            next_mw = next_mw + 3
        end ]]

        if talent.alpha_wolf.enabled then
            local last_trigger = max( action.chain_lightning.lastCast, action.crash_lightning.lastCast )

            if last_trigger > buff.feral_spirit.applied then
                applyBuff( "alpha_wolf", last_trigger + 8 - now )
            end
        end
    end

    wipe( virtual_spirits )
    for k, v in pairs( actual_spirits ) do
        if v.expires > now then
            virtual_spirits[ k ] = {
                expires = v.expires,
                alpha_expires = v.alpha_expires
            }
        else
            virtual_spirits[ k ] = nil
        end
    end

    wipe( virtual_molten_weapons )
    for k, v in pairs( molten_weapons ) do
        if v.expires > now then
            virtual_molten_weapons[ k ] = v.expires
        else
            molten_weapons[ k ] = nil
        end
    end

    wipe( virtual_icy_edges )
    for k, v in pairs( icy_edges ) do
        if v.expires > now then
            virtual_icy_edges[ k ] = v.expires
        else
            icy_edges[ k ] = nil
        end
    end

    wipe( virtual_crackling_surges )
    for k, v in pairs( crackling_surges ) do
        if v.expires > now then
            virtual_crackling_surges[ k ] = v.expires
        else
            crackling_surges[ k ] = nil
        end
    end

    wipe( virtual_earthen_weapons )
    for k, v in pairs( earthen_weapons ) do
        if v.expires > now then
            virtual_earthen_weapons[ k ] = v.expires
        else
            earthen_weapons[ k ] = nil
        end
    end

    if Hekili.ActiveDebug then
        if active_feral_spirits > 0 then Hekili:Debug( "Feral Spirits: " .. active_feral_spirits ) end
        if active_molten_weapons > 0 then Hekili:Debug( "Molten Weapons: " .. active_molten_weapons ) end
        if active_icy_edges > 0 then Hekili:Debug( "Icy Edges: " .. active_icy_edges ) end
        if active_crackling_surges > 0 then Hekili:Debug( "Crackling Surges: " .. active_crackling_surges ) end
        if active_earthen_weapons > 0 then Hekili:Debug( "Earthen Weapons: " .. active_earthen_weapons ) end
    end

    --[[ if buff.ascendance.up and talent.static_accumulation.enabled then
        local next_mw = query_time + 1 - ( ( query_time - buff.ascendance.applied ) % 1 )

        while ( next_mw <= buff.ascendance.expires ) do
            state:QueueAuraEvent( "ascendance_maelstrom", TriggerStaticAccumulation, next_mw, "AURA_PERIODIC" )
            next_mw = next_mw + 1
        end
    end ]]

    ti_mode = tiSpell -- Sync with CLEU every recommendation set

    rawset( buff, "doom_winds_debuff", debuff.doom_winds_debuff )
    rawset( buff, "doom_winds_cd", debuff.doom_winds_debuff )

    if totem.surging_totem.remains > cooldown.surging_totem.remains then setCooldown( "surging_totem", totem.surging_totem.remains ) end
end )


local ancestral_wolf_affinity_spells = {
    cleanse_spirit = 1,
    wind_shear = 1,
    purge = 1,
    -- TODO: List totems?
}

spec:RegisterStateExpr( "recall_totem_1", function()
    return recallTotem1
end )

spec:RegisterStateExpr( "recall_totem_2", function()
    return recallTotem2
end )

spec:RegisterHook( "runHandler", function( action )
    if buff.ghost_wolf.up then
        if talent.ancestral_wolf_affinity.enabled then
            local ability = class.abilities[ action ]
            if not ancestral_wolf_affinity_spells[ action ] and not ability.gcd == "totem" then
                removeBuff( "ghost_wolf" )
                removeBuff( "spirit_wolf" )
            end
        else
            removeBuff( "ghost_wolf" )
            removeBuff( "spirit_wolf" )
        end
    end

    if talent.totemic_recall.enabled and recall_totems[ action ] then
        recall_totem_2 = recall_totem_1
        recall_totem_1 = action
    end
end )


spec:RegisterGear({
    tww2 = {
        items = { 229260, 229261, 229262, 229263, 229265 },
        auras = {
            -- https://www.wowhead.com/spell=1218616
            -- Winning Streak! Stormstrike, Lava Lash and Doom Winds damage increased by 5.0%.
            winning_streak = {
                id = 1218616,
                duration = 30,
                max_stack = 5
            },
            -- https://www.wowhead.com/spell=1223410
            -- Electrostatic Wager Crash Lightning damage increased by 120%.
            electrostatic_wager = {
                id = 1223410,
                duration = 30,
                max_stack = 10,
            },
        }
    },
    tier29 = {
        items = { 200396, 200398, 200400, 200401, 200399 },
        auras = {
            maelstrom_of_elements = {
                id = 394677,
                duration = 15,
                max_stack = 1
            },
            fury_of_the_storm = {
                id = 396006,
                duration = 3,
                max_stack = 10
            }
        }
    },
    tier30 = {
        items = { 202473, 202471, 202470, 202469, 202468 },
        auras = {
            earthen_might = {
                id = 409689,
                duration = 15,
                max_stack = 1,
                copy = "t30_2pc_enh"
            },
            volcanic_strength = {
                id = 409833,
                duration = 15,
                max_stack = 1,
                copy = "t30_4pc_enh_damage"
            },
            crackling_thunder = {
                id = 409834,
                duration = 15,
                max_stack = 2,
                copy = "t30_4pc_enh_cl"
            }
        }
    },
    tier31 = {
        items = { 207207, 207208, 207209, 207210, 207212, 217238, 217240, 217236, 217237, 217239 },
    },
    waycrest_legacy = {
        items = { 158362, 159631 },
    },
    electric_mail = {
        items = { 161031, 161034, 161032, 161033, 161035 },
    }
} )


spec:RegisterStateFunction( "consume_maelstrom", function( cap )
    local stacks = min( buff.maelstrom_weapon.stack, cap or ( talent.overflowing_maelstrom.enabled and 10 or 5 ) )

    if talent.hailstorm.enabled and stacks > buff.hailstorm.stack then
        applyBuff( "hailstorm", nil, stacks )
    end

    removeStack( "maelstrom_weapon", stacks )
    if set_bonus.tier29_4pc > 0 then addStack( "fury_of_the_storm", nil, stacks ) end

    -- TODO: Have to actually track consumed MW stacks.
    if legendary.legacy_oF_the_frost_witch.enabled and stacks > 4 or talent.legacy_of_the_frost_witch.enabled and stacks > 9 then
        setCooldown( "stormstrike", 0 )
        setCooldown( "windstrike", 0 )
        applyBuff( "legacy_of_the_frost_witch" )
    end
end )

spec:RegisterStateFunction( "gain_maelstrom", function( stacks )
    if talent.witch_doctors_ancestry.enabled and not action.feral_spirit.disabled then
        reduceCooldown( "feral_spirit", stacks * talent.witch_doctors_ancestry.rank )
    end

    addStack( "maelstrom_weapon", nil, stacks )
end )

spec:RegisterStateFunction( "maelstrom_mod", function( amount )
    local mod = max( 0, 1 - ( 0.2 * buff.maelstrom_weapon.stack ) )
    return mod * amount
end )

spec:RegisterTotems( {
    skyfury_totem = {
        id = 135829
    },
    counterstrike_totem = {
        id = 511726
    },
    poison_cleansing_totem = {
        id = 136070
    },
    stoneskin_totem = {
        id = 4667425
    },
} )

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

    -- Talent: Transform into an Air Ascendant for $114051d, immediately dealing $344548s1 Nature damage to any enemy within $344548A1 yds, reducing the cooldown and cost of Stormstrike by $s4%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a $114089r yd range.$?s384411[    While Ascendance is active, generate $s1 Maelstrom Weapon $lstack:stacks; every $384437t1 sec.][]
    ascendance = {
        id = 114051,
        cast = 0,
        cooldown = function() return talent.thorims_invocation.enabled and 120 or 180 end,
        gcd = "spell",
        school = "nature",

        talent = "ascendance",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            -- trigger ascendance [344548], windstrike [115356]
            applyBuff( "ascendance" )
            --[[ if talent.static_accumulation.enabled then
                for i = 1, 15 do
                    state:QueueAuraEvent( "ascendance_maelstrom", TriggerStaticAccumulation, query_time + i, "AURA_PERIODIC" )
                end
            end ]]
        end,
    },

    -- Talent: Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = function () return 60 - 6 * talent.totemic_surge.rank + conduit.totemic_surge.mod * 0.001 end,
        gcd = "totem",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "capacitor_totem",
        startsCombat = false,
        toggle = "interrupts",

        handler = function ()
            summonTotem( "capacitor_totem" )
            if not target.is_boss and debuff.casting.remains > totem.capacitor_totem.remains then
                debuff.casting.expires = query_time + totem.capacitor_totem.remains
            end
        end,
    },

    -- Talent: Heals the friendly target for $s1, then jumps to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_heal = {
        id = 1064,
        cast = function ()
            if buff.chains_of_devastation_ch.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            if buff.surging_currents.up then return 0 end
            return 2.5 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up or buff.surging_currents.up and 0 or 0.15 end,
        spendType = "mana",

        talent = "chain_heal",
        startsCombat = false,

        handler = function ()
            consume_maelstrom()

            removeBuff( "chains_of_devastation_ch" )
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" )
            elseif buff.surging_currents.up then removeBuff( "surging_currents" ) end

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
            if buff.natures_swiftness.up then return 0 end
            if buff.arc_discharge.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 ) * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,

        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        handler = function ()
            local refund = ceil( buff.maelstrom_weapon.stack * 0.5 )
            consume_maelstrom()

            if set_bonus.tier30_2pc > 1 then applyBuff( "maelstrom_weapon", nil, refund ) end

            if talent.totemic_rebound.enabled and buff.whirling_air.up then
                removeBuff( "whirling_air" )
                addStack( "totemic_rebound", nil, 3 )
            end

            removeStack( "arc_discharge" )
            removeBuff( "chains_of_devastation_cl" )

            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end -- TODO: Determine order of instant cast effect consumption.
            removeBuff( "master_of_the_elements" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_ch" )
            end

            if talent.crash_lightning.enabled then
                if true_active_enemies > 1 then applyBuff( "cl_crash_lightning", nil, min( talent.crashing_storms.enabled and 5 or 3, true_active_enemies ) ) end
                reduceCooldown( "crash_lightning", min( talent.crashing_storms.enabled and 5 or 3, true_active_enemies ) )
            end

            if talent.alpha_wolf.enabled then
                for _, v in pairs( virtual_spirits ) do
                    if v.expires > query_time then
                        v.alpha_expires = min( v.expires, query_time + 8 )
                    end
                end
            end

            removeStack( "stormkeeper" )

            if pet.storm_elemental.up then
                addStack( "wind_gust" )
            end

            if buff.feral_spirit.up and talent.alpha_wolf.enabled then
                applyBuff( "alpha_wolf" )
            end

            if talent.conductive_energy.enabled then
                if debuff.lightning_rod.down then
                    applyDebuff( "target", "lightning_rod" )
                else
                    active_dot.lightning_rod = min( active_enemies, active_dot.lightning_rod + 1 )
                end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            ti_mode = "chain_lightning"
        end,
    },

    -- Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker.
    counterstrike_totem = {
        id = 204331,
        cast = 0,
        cooldown = function () return 45 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "counterstrike_totem",

        startsCombat = false,
        texture = 511726,

        handler = function ()
            summonPet( "counterstrike_totem" )
        end,
    },

    -- Talent: Electrocutes all enemies in front of you, dealing ${$s1*$<CAP>/$AP} Nature damage. Hitting 2 or more targets enhances your weapons for $187878d, causing Stormstrike, Ice Strike, and Lava Lash to also deal ${$195592s1*$<CAP>/$AP} Nature damage to all targets in front of you. Damage reduced beyond $s2 targets.$?s384363[    Each target hit by Crash Lightning increases the damage of your next Stormstrike by $198300s1%, up to a maximum of $198300u stacks.][]
    crash_lightning = {
        id = 187874,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "nature",

        spend = 0.01,
        spendType = "mana",

        talent = "crash_lightning",
        startsCombat = true,

        handler = function ()
            if active_enemies > 1 then
                applyBuff( "crash_lightning" )
            end

            removeBuff( "crashing_lightning" )
            removeBuff( "cl_crash_lightning" )

            if buff.feral_spirit.up and talent.alpha_wolf.enabled then
                applyBuff( "alpha_wolf" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            if talent.converging_storms.enabled then
                applyBuff( "converging_storms", nil, min( 6, active_enemies ) )
            end

            if talent.alpha_wolf.enabled then
                for _, v in pairs( virtual_spirits ) do
                    if v.expires > query_time then
                        v.alpha_expires = min( v.expires, query_time + 8 )
                    end
                end
            end

            removeBuff( "electrostatic_wager" )
        end,
    },

    -- Unleash a devastating storm around yourself, dealing $469270s1 Stormstrike damage every $466772s5 sec to nearby enemies for $466772d.; Increases your chance to activate Windfury Weapon by $466772s1%, and the damage of Windfury Weapon by $466772s2%.;
    doom_winds = {
        id = 384352,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "doom_winds",
        startsCombat = true,

        toggle = "essences",

        handler = function ()
            applyBuff( "doom_winds" )
        end,
    },

    -- Talent: Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.    While this elemental is active, your maximum health is increased by $381755s1%.
    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = 300,
        gcd = "spell",
        school = "nature",

        talent = "earth_elemental",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            summonPet( "greater_earth_elemental", 60 )
            if conduit.vital_accretion.enabled then
                applyBuff( "vital_accretion" )
                health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
            end
        end,
    },

    -- Talent: Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $n charges.    $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return state.spec.enhancement and 0.02 or 0.05 end,
        spendType = "mana",

        talent = "earth_shield",
        startsCombat = false,

        timeToReady = function () return buff.earth_shield.remains - 120 end,

        handler = function ()
            applyBuff( "earth_shield" )
            if talent.elemental_orbit.rank == 0 then removeBuff( "lightning_shield" ) end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Summons a totem at the target location for 20 sec that slows the movement speed of enemies within 10 yards by 50%.
    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = function() return 24 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.005,
        spendType = "mana",

        startsCombat = false,
        texture = 136102,

        handler = function()
            summonTotem( "earthbind_totem" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    earthgrab_totem = {
        id = 51485,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "earthgrab_totem",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthgrab_totem" )
        end,
    },

    -- Talent: Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[    If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_blast = {
        id = 117014,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        flash = { 51505, 117014, 394150 },
        charges = function() if talent.lava_burst.enabled then return 2 end end,
        cooldown = 12,
        recharge = function() if talent.lava_burst.enabled then return 12 end end,
        gcd = "spell",
        school = "elemental",

        spend = function()
            if state.spec.elemental then return 90 end
            return 0.006
        end,

        spendType = function()
            if state.spec.elemental then return "maelstrom" end
            return "mana"
        end,

        talent = "elemental_blast",
        startsCombat = false,

        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        handler = function ()
            consume_maelstrom()

            if talent.totemic_rebound.enabled and buff.whirling_air.up then
                removeBuff( "whirling_air" )
                addStack( "totemic_rebound", nil, 3 )
            end

            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            applyBuff( "elemental_blast" )

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "lava_burst"
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

    -- Talent: Lunge at your enemy as a ghostly wolf, biting them to deal $215802s1 Physical damage.
    feral_lunge = {
        id = 196884,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        school = "physical",

        startsCombat = true,

        min_range = 8,
        max_range = 25,

        handler = function ()
            setDistance( 5 )
        end,
    },

    -- Talent: Summons two $?s262624[Elemental ][]Spirit $?s147783[Raptors][Wolves] that aid you in battle for $228562d. They are immune to movement-impairing effects, and each $?s262624[Elemental ][]Feral Spirit summoned grants you $?s262624[$224125s1%][$392375s1%] increased $?s262624[Fire, Frost, or Nature][Physical] damage dealt by your abilities.    Feral Spirit generates one stack of Maelstrom Weapon immediately, and one stack every $333957t1 sec for $333957d.
    feral_spirit = {
        id = 51533,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 90 - ( talent.elemental_spirits.enabled and 30 or 0 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "feral_spirit",
        startsCombat = false,
        notalent = "flowing_spirits",

        toggle = "cooldowns",

        handler = function ()
            -- instant MW stack?
            applyBuff( "feral_spirit" )

            insert( virtual_spirits, {
                expires = query_time + 15,
                alpha_expires = 0
            } )

            insert( virtual_spirits, {
                expires = query_time + 15,
                alpha_expires = 0
            } )

            if not talent.elemental_spirits.enabled then
                insert( virtual_earthen_weapons, query_time + 15 )
                insert( virtual_earthen_weapons, query_time + 15 )
            end

            if set_bonus.tww1_4pc > 0 then
                insert( virtual_spirits, {
                    expires = query_time + 15,
                    alpha_expires = 0
                } )
                if not talent.elemental_spirits.enabled then
                    insert( virtual_earthen_weapons, query_time + 15 )
                end
            end

            if set_bonus.tier31_4pc > 0 then
                reduceCooldown( "primordial_wave", 14 )
            end

            gain_maelstrom( 1 )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 3, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 6, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 9, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 12, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 15, "AURA_PERIODIC" )
        end
    },

    -- Talent: Erupt a burst of fiery damage from all targets affected by your Flame Shock, dealing $333977s1 Fire damage to up to $333977I targets within $333977A1 yds of your Flame Shock targets.$?s384359[    Each eruption from Fire Nova generates $384359s1 $Lstack:stacks; of Maelstrom Weapon.][]
    fire_nova = {
        id = 333974,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "fire_nova",
        startsCombat = true,

        usable = function() return active_dot.flame_shock > 0, "requires active flame_shock" end,

        handler = function ()
            if buff.whirling_fire.up then
                removeBuff( "whirling_fire" )
                applyBuff( "hot_hand", 8 )
            end

            if talent.swirling_maelstrom.enabled then
                gain_maelstrom( min( 6, active_dot.flame_shock ) + ( buff.maelstrom_of_elements.up and 1 or 0 ) )
            end

            if buff.maelstrom_of_elements.up then removeBuff( "maelstrom_of_elements" ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Sears the target with fire, causing $s1 Fire damage and then an additional $o2 Fire damage over $d.    Flame Shock can be applied to a maximum of $I targets.
    flame_shock = {
        id = 470411,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "fire",

        spend = 0.003,
        spendType = "mana",

        startsCombat = true,
        nobuff = "voltaic_blaze",

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            if buff.whirling_earth.up then
                removeBuff( "whirling_earth" )
                active_dot.flame_shock = min( 6, true_active_enemies, active_dot.flame_shock + 5 )
            end

            if talent.focused_insight.enabled then applyBuff( "focused_insight" ) end
            if talent.primal_lava_actuators.enabled then addStack( "primal_lava_actuators_df" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = { 188389, 470411 },
        bind = "voltaic_blaze"
    },

    -- Sears the target with fire, causing $s1 Fire damage and then an additional $o2 Fire damage over $d.    Flame Shock can be applied to a maximum of $I targets.
    voltaic_blaze = {
        id = 470057,
        known = 470411,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "fire",

        spend = 0.003,
        spendType = "mana",

        startsCombat = true,
        buff = "voltaic_blaze",

        handler = function ()
            removeBuff( "voltaic_blaze" )

            spec.abilities.flame_shock.handler()
            active_dot.flame_shock = min( 6, true_active_enemies, active_dot.flame_shock + 5 )

            if buff.whirling_earth.up then
                removeBuff( "whirling_earth" )
                active_dot.flame_shock = min( true_active_enemies, active_dot.flame_shock + 5 )
            end

            if talent.focused_insight.enabled then applyBuff( "focused_insight" ) end
            if talent.primal_lava_actuators.enabled then addStack( "primal_lava_actuators_df" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "voltaic_blaze"
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
        essential = true,

        usable = function () return off_hand.size > 0, "requires an offhand weapon" end,
        handler = function ()
            applyBuff( "flametongue_weapon" )
        end,
    },

    -- Talent: Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    frost_shock = {
        id = 196840,
        known = 196840,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "frost_shock" )

            if buff.hailstorm.up then
                if talent.swirling_maelstrom.enabled and buff.hailstorm.stack > 1 then gain_maelstrom( 1 + ( buff.maelstrom_of_elements.up and 1 or 0 ) ) end
                removeBuff( "hailstorm" )
            end

            removeBuff( "ice_strike_buff" )
            removeBuff( "maelstrom_of_elements" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = function()
            if talent.ice_strike_passive.enabled then return "ice_strike" end
        end
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
            if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws_sl" ) end
            if talent.thunderous_paws.enabled and query_time - buff.thunderous_paws_df.lastApplied > 20 then
                applyBuff( "thunderous_paws_df" )
                if debuff.snared.up then removeDebuff( "player", "snared" ) end
            end
        end,
    },

    -- Talent: Purges the enemy target, removing $m1 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "nature",

        spend = function() return state.spec.enhancement and 0.024 or 0.021 end,
        spendType = "mana",

        talent = "greater_purge",
        startsCombat = true,
        toggle = "interrupts",
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    -- Talent: A gust of wind hurls you forward.
    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "gust_of_wind",
        startsCombat = false,

        toggle = "interrupts",
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        talent = "healing_stream_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "healing_stream_totem" )
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            if buff.surging_currents.up then return 0 end
            return maelstrom_mod( 1.5 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.natures_swiftness.up or buff.surging_currents.up ) and 0 or maelstrom_mod( state.spec.enhancement and 0.08 or state.spec.elemental and 0.044 or state.spec.restoration and 0.044 ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            consume_maelstrom()

            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" )
            elseif buff.surging_currents.up then removeBuff( "surging_currents" ) end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end
    },

    -- Strike your target with an icy blade, dealing $s1 Frost damage and snaring them by $s2% for $d.; Ice Strike increases the damage of your next Frost Shock by $384357s1%$?s384359[ and generates $384359s1 $Lstack:stacks; of Maelstrom Weapon][].
    ice_strike = {
        id = 470194,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "frost",

        spend = 0.033,
        spendType = "mana",

        talent = "ice_strike",
        notalent = "ice_strike_passive",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "ice_strike" )
            applyBuff( "ice_strike_buff" )

            if talent.swirling_maelstrom.enabled then
                if state.spec.elemental then
                    gain_maelstrom( 1 + ( buff.maelstrom_of_elements.up and 1 or 0 ) )
                    removeBuff( "maelstrom_of_elements" )
                else
                    gain_maelstrom( 2 )
                end
            else
                gain_maelstrom( 1 )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = 342240
    },

    -- Talent: Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[    |cFFFFFFFFGenerates $343725s3 Maelstrom.|r][]
    lava_burst = {
        id = 51505,
        cast = function ()
            if buff.natures_swiftness.up or buff.lava_surge.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 8,
        gcd = "spell",
        school = "fire",

        spend = 0.025,
        spendType = "mana",

        talent = "lava_burst",
        notalent = "elemental_blast",
        startsCombat = false,
        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            if buff.windspeakers_lava_resurgence.up then removeBuff( "windspeakers_lava_resurgence" ) end
            if buff.lava_surge.up then removeBuff( "lava_surge" ) end
            if buff.echoing_shock.up then removeBuff( "echoing_shock" ) end

            consume_maelstrom()

            if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

            if talent.surge_of_power.enabled then
                gainChargeTime( "fire_elemental", 6 )
                removeBuff( "surge_of_power" )
            end

            if buff.primordial_wave.up and state.spec.elemental and ( talent.splintered_elements.enabled or legendary.splintered_elements.enabled ) then
                if buff.splintered_elements.down then stat.haste = stat.haste + 0.1 * active_dot.flame_shock end
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        impact = function () end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.

        -- bind = "elemental_blast",
    },

    -- Talent: Charges your off-hand weapon with lava and burns your target, dealing $s1 Fire damage.    Damage is increased by $s2% if your offhand weapon is imbued with Flametongue Weapon. $?s334033[Lava Lash will spread Flame Shock from your target to $s3 nearby targets.][]$?s334046[    Lava Lash increases the damage of Flame Shock on its target by $334168s1% for $334168d.][]
    lava_lash = {
        id = 60103,
        cast = 0,
        cooldown = function () return ( 18 - 6 * talent.molten_assault.rank ) * ( buff.hot_hand.up and ( 1 - 0.375 * talent.hot_hand.rank ) or 1 ) * haste - ( settings.pad_lava_lash and buff.hot_hand.up and ( latency * 2 ) or 0 ) end,
        gcd = "spell",
        school = "fire",

        spend = 0.008,
        spendType = "mana",

        talent = "lava_lash",
        startsCombat = true,

        cycle = function()
            return talent.lashing_flames.enabled and "lashing_flames" or nil
        end,

        indicator = function()
            if debuff.flame_shock.down and active_dot.flame_shock > 0 and active_enemies > 1 then return "cycle" end
        end,

        handler = function ()
            removeDebuff( "target", "primal_primer" )

            if buff.whirling_fire.up then
                removeBuff( "whirling_fire" )
                applyBuff( "hot_hand", 8 )
            end

            if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

            removeBuff( "primal_lava_actuators" )
            removeBuff( "ashen_catalyst" )

            if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
            if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

            -- This is dumb, but technically you don't know if FS will go to a new target or refresh an old one.  Even your current target.
            if talent.molten_assault.enabled and debuff.flame_shock.up then
                active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 5 )
                removeBuff( "whirling_earth" )
            end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    lightning_bolt = {
        id = 188196,
        cast = function ()
            if buff.natures_swiftness.up or buff.arc_discharge.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        nobuff = "tempest",

        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        handler = function ()
            consume_maelstrom()

            if talent.totemic_rebound.enabled and buff.whirling_air.up then
                removeBuff( "whirling_air" )
                addStack( "totemic_rebound", nil, 3 )
            end

            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            if buff.arc_discharge.up then removeStack( "arc_discharge" ) end

            if buff.primordial_wave.up and state.spec.enhancement and ( talent.splintered_elements.enabled or legendary.splintered_elements.enabled ) then
                if buff.splintered_elements.down then stat.haste = stat.haste + 0.1 * active_dot.flame_shock end
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            ti_mode = buff.primordial_wave.up and active_dot.flame_shock > 1 and "chain_lightning" or "lightning_bolt"

        end,

        bind = "tempest"
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    tempest = {
        id = 452201,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        buff = "tempest",

        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        handler = function ()
            consume_maelstrom()

            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeStack( "tempest" )

            if talent.arc_discharge.enabled then addStack( "arc_discharge" ) end

            if buff.primordial_wave.up and state.spec.enhancement and ( talent.splintered_elements.enabled or legendary.splintered_elements.enabled ) then
                if buff.splintered_elements.down then stat.haste = stat.haste + 0.1 * active_dot.flame_shock end
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            ti_mode = true_active_enemies > 1 and "chain_lightning" or "lightning_bolt"
        end,

        bind = "lightning_bolt",
        copy = { 454009, 454015 },
        flash = 188196
    },

    -- Talent: Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    lightning_lasso = {
        id = 305483,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "lightning_lasso",
        startsCombat = false,
        toggle = "interrupts",

        start = function ()
            removeBuff( "echoing_shock" )
            applyDebuff( "target", "lightning_lasso" )
            if not target.is_boss then interrupt() end

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
        essential = true,
        nobuff = function() if not talent.elemental_orbit.enabled then return "earth_shield" end end,

        timeToReady = function () return buff.lightning_shield.remains - 120 end,

        handler = function ()
            applyBuff( "lightning_shield" )
            if talent.elemental_orbit.rank == 0 then removeBuff( "earth_shield" ) end
        end,
    },

    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        talent = "natures_swiftness",
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
        cooldown = function() return 120 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",
        toggle = "interrupts",

        talent = "poison_cleansing_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "poison_cleaning_totem" )
            removeBuff( "dispellable_poison" )
        end,
    },

    -- An instant weapon strike that causes $sw2 Physical damage.
    primal_strike = {
        id = 73899,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 0.094,
        spendType = "mana",

        notalent = "stormstrike",
        startsCombat = true,

        handler = function ()
        end,
    },
    -- Talent / Covenant (Necrolord): Blast your target with a Primordial Wave, dealing $375984s1 Shadow damage and apply Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_storm = {
        id = 1218090,
        known = 375982,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "flamestrike",
        flash = 375982,

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,

        talent = "primordial_storm",
        buff = "primordial_storm",

        handler = function ()
            removeBuff( "primordial_storm" )
            consume_maelstrom()
        end,

        bind = "primordial_wave"
    },
    -- Talent / Covenant (Necrolord): Blast your target with a Primordial Wave, dealing $375984s1 Shadow damage and apply Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave = {
        id = function() return talent.primordial_wave.enabled and 375982 or 326059 end,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        -- velocity = 25,

        toggle = "essences",

        usable = function()
            if active_dot.flame_shock < 1 then return false, "requires active flame_shock" end
            if buff.maelstrom_weapon.stack < 5 then return true end
            return not ( talent.primal_maelstrom.enabled and settings.burn_before_wave ), "setting requires spending maelstrom_weapon before using with primal_maelstrom"
        end,

        cycle = "flame_shock",

        handler = function ()
            if talent.primal_maelstrom.enabled then gain_maelstrom( 5 ) end
            applyBuff( "primordial_wave" )
            if talent.conductive_energy.enabled then active_dot.lightning_rod = min( active_enemies, max( active_dot.lightning_rod, active_dot.flame_shock ) ) end
            if set_bonus.tier31_2pc > 0 then
                insert( virtual_spirits, {
                    expires = query_time + 15,
                    alpha_expires = 0
                } )
                if not talent.elemental_spirits.enabled then
                    insert( virtual_earthen_weapons, query_time + 15 )
                end
            end
        end,

        copy = { 326059, 375982 }
    },

    -- Talent: Purges the enemy target, removing $m1 beneficial Magic $leffect:effects;.$?(s147762&s51530)  [ Successfully purging a target grants a stack of Maelstrom Weapon.][]
    purge = {
        id = 370,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        icd = function() if settings.purge_icd > 0 then return settings.purge_icd end end,
        school = "nature",

        spend = function() return state.spec.enhancement and 0.016 or 0.14 end,
        spendType = "mana",

        talent = "purge",
        startsCombat = true,
        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },

    -- Harness the fury of the Windlord to grant a target ally $s1% Mastery and empower their auto attacks to have a $h% chance to instantly strike again for $d.; If the target is in your party or raid, all party and raid members will be affected.
    skyfury = {
        id = 462854,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,
        nobuff = "skyfury",
        essential = true,

        handler = function()
            applyBuff( "skyfury" )
        end,
   },

    -- Removes all movement impairing effects and increases your movement speed by $58875s1% for $58875d.
    spirit_walk = {
        id = 58875,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "off",

        talent = "spirit_walk",
        startsCombat = false,

        handler = function()
            applyBuff( "spirit_walk" )
        end,
    },

    -- Talent: Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    spiritwalkers_grace = {
        id = 79206,
        cast = 0,
        cooldown = function () return 120 - 30 * talent.graceful_spirit.rank end,
        gcd = "off",
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

     -- Summons a totem with $s2% of your health at the target location for $d that forms a circuit of electricity that enemies cannot pass through.
     static_field_totem = {
        id = 355580,
        cast = 0.0,
        cooldown = function() return 90.0 - 6 * talent.totemic_surge.rank end,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        pvptalent = "static_field_totem",

        handler = function()
        end,
    },

    -- Summons a totem with ${$m1*$MHP/100} health at the feet of the caster for $d, granting the caster a shield absorbing $114893s1 damage for $114893d, and up to an additional $462844s1 every $114889t1 sec.
    stone_bulwark_totem = {
        id = 108270,
        cast = 0,
        cooldown = function () return 180 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.02,
        spendType = "mana",

        talent = "stone_bulwark_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "stone_bulwark_totem" )
            applyBuff( "stone_bulwark" )
        end,
    },

    -- Talent: Energizes both your weapons with lightning and delivers a massive blow to your target, dealing a total of ${$32175sw1+$32176sw1} Physical damage.$?s210853[    Stormstrike has a $s4% chance to generate $210853m2 $Lstack:stacks; of Maelstrom Weapon.][]
    stormstrike = {
        id = 17364,
        cast = 0,
        charges = function() if talent.stormblast.enabled then return 2 end end,
        cooldown = function() return gcd.execute * 5 end,
        recharge = function() if talent.stormblast.enabled then return gcd.execute * 5 end end,
        gcd = "spell",
        school = "physical",

        rangeSpell = 73899,

        spend = 0.02,
        spendType = "mana",

        -- talent = "stormstrike",
        startsCombat = true,

        bind = "windstrike",
        cycle = function () return azerite.lightning_conduit.enabled and "lightning_conduit" or nil end,
        nobuff = "ascendance",

        handler = function ()
            setCooldown( "windstrike", action.stormstrike.cooldown )

            if buff.stormbringer.up then
                removeBuff( "stormbringer" )
            end

            if buff.stormsurge.up then
                removeStack( "stormsurge" )
            end

            removeBuff( "converging_storms" )
            removeBuff( "strength_of_earth" )
            removeBuff( "legacy_of_the_frost_witch" )

            if talent.elemental_assault.rank > 1 then
                gain_maelstrom( 1 )
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "maelstrom_of_elements" ) end

            if azerite.lightning_conduit.enabled then
                applyDebuff( "target", "lightning_conduit" )
            end
            if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
            if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
            if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Shatters a line of earth in front of you with your main hand weapon, causing $s1 Flamestrike damage and Incapacitating any enemy hit for $d.
    sundering = {
        id = 197214,
        cast = 0,
        cooldown = function() return talent.molten_thunder.enabled and 30 or 40 end,
        gcd = "spell",
        school = "flamestrike",

        spend = 0.06,
        spendType = "mana",

        talent = "sundering",
        startsCombat = true,

        handler = function ()
            if not talent.molten_thunder.enabled then applyDebuff( "target", "sundering" ) end
            -- Todo: Track 11.1 molten thunder reset and whether or not it can be 100%. Currently a serverside script so *shrug*
            if talent.lashing_flames.enabled then
                applyDebuff( "target", "lashing_flames" )
                active_dot.lashing_flames = active_enemies
            end
            if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- [Summons a totem at the target location that creates a Tremor immediately and every $455593t1 sec for $455622s1 Physical damage. Damage reduced beyond $455622s2 targets. Lasts $d.]
    surging_totem = {
        id = 444995,
        cast = 0.0,
        cooldown = function() return 30.0 - 6 * talent.totemic_surge.rank end,
        gcd = "spell",

        spend = 0.086,
        spendType = 'mana',

        talent = "surging_totem",
        startsCombat = false,
        readyTime = function() return totem.surging_totem.remains end,

        texture = 5927655,

        handler = function()
            summonTotem( "surging_totem" )

            if talent.whirling_elements.enabled then
                applyBuff( "whirling_air" )
                applyBuff( "whirling_earth" )
                applyBuff( "whirling_fire" )
            end
        end,

        bind = "surging_totem_projection"
    },

    -- Summons your Surging Totem nearby
    surging_totem_projection = {
        id = 1221348,
        cast = 0,
        cooldown = 6,
        gcd = "off",
        school = "nature",

        talent = "surging_totem",
        startsCombat = false,
        usable = function() return totem.surging_totem.up end,

        texture = 310733,
        essential = false,

        handler = function ()
        end,

        bind = "surging_totem"
    },

    -- Talent: Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    -- TODO: Track Thunderstorm for CDR.
    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "thunderstorm",
        startsCombat = false,
        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "thunderstorm" )
            if not target.is_boss then interrupt() end
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
        essential = false,

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

        toggle = "defensives",

        handler = function ()
            if recall_totem_1 then setCooldown( recall_totem_1, 0 ) end
            if talent.creation_core.enabled and recall_totem_2 then setCooldown( recall_totem_2, 0 ) end
        end,

        copy = "call_of_the_elements"
    },

    -- Talent: Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) - 6 * talent.totemic_surge.rank end,
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

    -- Unleash your Elemental Shield's energy on an enemy target:; $@spellicon192106$@spellname192106: Knocks them away.; $@spellicon974$@spellname974: Roots them in place for $356738d.; $@spellicon52127$@spellname52127: Summons a whirlpool for $356739d, reducing damage and healing by $356824s1% while they stand within it.
    unleash_shield = {
        id = 356736,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        startsCombat = true,
        pvptalent = "unleash_shield",

        buff = function()
            return buff.lightning_shield.up or buff.earth_shield.up or buff.water_shield.up, "requires an elemental shield"
        end,

        handler = function()
        end,
    },

    water_walking = {
        id = 546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135863,

        handler = function ()
            applyBuff( "water_walking" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d, continually granting all allies who pass within $192078s1 yards $192082s% increased movement speed for $192082d.
    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = function () return 120 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.010,
        spendType = 'mana',

        talent = "wind_rush_totem",
        startsCombat = false,
        texture = 538576,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "wind_rush_totem" )
            applyBuff( "wind_rush" )
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
        end,
    },

    -- Talent: Imbue your main-hand weapon with the element of Wind for $319773d. Each main-hand attack has a $319773h% chance to trigger $?s390288[three][two] extra attacks, dealing $25504sw1 Physical damage each.$?s262647[    Windfury causes each successive Windfury attack within $262652d to increase the damage of Windfury by $262652s1%, stacking up to $262652u times.][]
    windfury_weapon = {
        id = 33757,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        talent = "windfury_weapon",
        startsCombat = false,
        essential = true,
        nobuff = "windfury_weapon",

        usable = function() return main_hand.size > 0, "requires a mainhand weapon" end,
        handler = function ()
            applyBuff( "windfury_weapon" )
        end,
    },


    windstrike = {
        id = 115356,
        cast = 0,
        charges = function() if talent.stormblast.enabled then return 2 end end,
        cooldown = function() return gcd.execute * 2 - ( settings.pad_windstrike and latency * 2 or 0 ) end,
        recharge = function() if talent.stormblast.enabled then return gcd.execute * 2 - ( settings.pad_windstrike and latency * 2 or 0 ) end end,
        gcd = "spell",

        texture = 1029585,
        known = 17364,

        buff = "ascendance",
        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        bind = "stormstrike",

        handler = function ()
            setCooldown( "stormstrike", action.stormstrike.cooldown )
            setCooldown( "strike", action.stormstrike.cooldown )

            if buff.stormbringer.up then
                removeBuff( "stormbringer" )
            end

            removeBuff( "converging_storms" )
            removeBuff( "strength_of_earth" )
            removeBuff( "legacy_of_the_frost_witch" )

            if talent.elemental_assault.enabled then
                gain_maelstrom( 1 )
            end

            if talent.thorims_invocation.enabled and buff.maelstrom_weapon.up then
                consume_maelstrom( min( 5, buff.maelstrom_weapon.stack ) )
            end

            if azerite.natural_harmony.enabled then
                if buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },
} )

spec:RegisterRanges( "primal_strike", "lightning_bolt", "flame_shock", "wind_shear" )

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

    package = "Enhancement",
} )

spec:RegisterSetting( "funnel_priority", false, {
    name = "Enhancement Shaman is able to do funnel damage. Head over to |cFFFFD100Toggles|r to learn how to turn the feature on and off. " ..
    "If funnel is enabled, the default priority will recommend spending resources on single target spenders in AoE to deal high priority damage to an important mob.\n\n",
    desc = "",
    type = "description",
    fontSize = "medium",
    width = "full"
})

spec:RegisterStateExpr( "funnel", function()
    return toggle.funnel
end )

spec:RegisterStateTable( "rotation", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if ( k == "simple" or k == "standard" ) and not settings.funnel_priority then return true end
        if k == "funnel" and settings.funnel_priority then return true end
        return false
    end, state )
} ) )

spec:RegisterSetting( "pad_windstrike", true, {
    name = strformat( "Pad %s Cooldown", Hekili:GetSpellLinkWithTexture( spec.abilities.windstrike.id ) ),
    desc = strformat( "If checked, the cooldown of %s will be shortened to help ensure it is recommended as frequently as possible during %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.windstrike.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.ascendance.id ) ),
    type = "toggle",
    width = 1.5
} )

spec:RegisterSetting( "pad_lava_lash", true, {
    name = strformat( "Pad %s Cooldown", Hekili:GetSpellLinkWithTexture( spec.abilities.lava_lash.id ) ),
    desc = strformat( "If checked, the cooldown of %s will be shortened to help ensure that it is recommended as frequently as possible during %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.lava_lash.id ), Hekili:GetSpellLinkWithTexture( spec.auras.hot_hand.id ) ),
    type = "toggle",
    width = 1.5
} )

local elemental = Hekili:GetSpec( 262 )

spec:RegisterSetting( "pwave_targets", 0, {
    name = strformat( "%s: Required Targets", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ) ),
    desc = strformat( "If set above 1, %s will not be recommended unless multiple targets are detected.  This option can be quickly accessed via the icon or addon compartment "
        .. "on your minimap, to quickly change it for different boss encounters.\n\nThis setting is also found in the |cFFFFD100Abilities |cFFFFFFFF>|r "
        .. "Enhancement |cFFFFFFFF>|r |W%s|w|r section.", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ), spec.abilities.primordial_wave.name ),
    type = "range",
    min = 0,
    max = 15,
    step = 1,
    set = function( info, val )
        Hekili.DB.profile.specs[ 263 ].abilities.primordial_wave.targetMin = val
    end,
    get = function()
        return Hekili.DB.profile.specs[ 263 ].abilities.primordial_wave.targetMin or 0
    end,
    width = "full"
} )

spec:RegisterSetting( "pwave_gcds", 4, {
    name = strformat( "%s: GCD Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ) ),
    desc = strformat( "By default, in a multi-target scenario, %s may be recommended with %s active while waiting for you to spread %s to additional targets.\n\n"
        .. "If set above 0, when %s is active and has fewer than this number of GCDs remaining, filler %s casts will be prevented and %s will be recommended despite "
        .. "having enemies without %s active.\n\n"
        .. "Setting this |cffffd100higher|r reduces your risk of having %s fall off during a lucky string of %s procs.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.chain_lightning.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.flame_shock.id ), spec.abilities.primordial_wave.name, spec.abilities.chain_lightning.name, spec.abilities.lightning_bolt.name,
        spec.abilities.flame_shock.name, spec.abilities.primordial_wave.name, Hekili:GetSpellLinkWithTexture( spec.talents.hot_hand[2] ) ),
    type = "range",
    min = 0,
    max = 6,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "hostile_dispel", false, {
    name = strformat( "Use %s or %s", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    desc = strformat( "If checked, %s or %s can be recommended when your target has a dispellable magic effect.\n\n"
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

spec:RegisterSetting( "filler_shock", true, {
    name = strformat( "Filler %s", Hekili:GetSpellLinkWithTexture( spec.abilities.flame_shock.id ) ),
    desc = strformat( "If checked, a filler %s may be recommended when nothing else is currently ready, even if something better will be off cooldown very soon.\n\n"
        .. "This feature matches simulation profile behavior and is a small DPS increase, but has been confusing to some users.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.flame_shock.id ) ),
    type = "toggle",
    width = 1.5
} )

spec:RegisterPack( "Enhancement", 20250417, [[Hekili:S3ZAZnoUr(BXvQrRKNzLLOK94zplN6YE5QANkj3vXBU8nrrlrzXAOe1rszVElx63(ba(aV6gaus0EM5Yx21Jiiq)c9l0O50Ht)1P3TiipC6FZBG3Ldgp8J9hE9LJU86P3L)82WP3Tny(xcEG8hBcwt(V)5nRc2mpCD4MC6ZEoojybDoYs2LoN88v55BZ(PlU4HO8v7UV)8K1xKfTExCqEuYM5PblZP)75xCFCY9xSin4HKnlJJEyv(fHBEiAt4fZJdYY8xNSyxCy2fzZ9ZwfSoyt)5B3o9U73ffN)lBMEpmqFfbo2goN8ZxnIakrlwewm2WS5tVJo2FCW4FC4h)P9Z(1Ncd(YflJ(T9Z(3)V(Z7N9x)N7NrE3nlctZ2)59FUEWxrg8)ilC)SDBjit0Mh2pBBAusAu(Z)B7NLtNM9Z(VtJwNKUikiE)S7YtsxlnfxsMIFz920Khjtt4YLrZJc3m)zPXmQymXmk7(zDZswh2JaBzRc3SF2phKhe)Cg5b)8)XFN8EZEp5rlwqg3IOSG7Jdxqg7U8OycurwIn5PrHzeOlz)SfHld2fNlTydQWjD4E29HltsjpkFf5)C)ULl3pBzqCmz2swU8dKj)rka9eH9MSJap)1GW4S8ucB(Ve(qabPidR8L)pttOq8)mkF(k(YpQy5VlA9ptPPu2i)HE)O311pe8Xu2X)tsCEq089Z(tXb)ozHIia3YDXXKfNqoYJ2mNSSljWebgIjsTKjCvY8Vus3(7HpgLfUae5NVkKmUzekW(z)5cEb9PK1HIjxqeBsYdxtx67(vjWIYI)7HzpVzEbTPahMExmbEYy7pisoXHK)6VX2YfUHX1M(NkeotJ2s3Fm9U7ydJqadsFiKSKbZP)oxKB)m6mo9UIFF6DZjSg)I)HFXtimJO55(rljBGJO4(n7NnKSBMSg5HPrbs)8(zDiYqe8ojjErYtB6VijzT)trBwK1pnCDq0gcPDY(zd2p7Lxegw2o6gfcScnQZkKB6Vkj3NOSyr)DB3pRxbTWVqlsb1WpHSHBAoz7QcjHdRDlNR1vIz(KnCBtiqqEaLtDlzzhwUUSbUTMP6Nr5PCa8gYqhZqyRZ4Lm4TIgRoLuiEeketW(8O5FHPOOG4seHiYr9dOBL9NxUtUF5lxa6LdryLEk4XqWXqefxrMC)Luj7m(qeay2Ji6njY8uyDSjQRro)T7NnsL1dnoIS0hLHGWuk1ABezPOGWLOGqjwr0MqW9m)OnpMmNzRGJzw5ymjVou6UpZuYgk95EIscoaXayYoJVesbNRqbh2cfZ0K5NS0NOhZFjvngbJjAXysYk7yervZuo4rsODEs0oobMcQFefuxKK3xGt3xrQlniAHpvznrYBbHzfTHbvfRIMKwfqwaYqVlboVcBBbDkOa71MK0qH3sDgUSh4mR7MeaWGS5e75uVvOW2N(6seC4at0QUIOkXTH0LXjprNYAaObWwPcTckOlku)eB09yt98vulrzKDbf4b1CitPB)R5OwyLPs)7Pwkz4NQzoDD6elPBdj8UYvEIYpVo438lFuPE0IhWOb(Zt2r9tsyFg7LdEk4lHmIptvDMWKpQcLCc)5ix5YYqkCdvUmPD42g1mtvQzPajsN7tCKPG0liInKdukczuyd3K0xlcuMfyWntzF(H5w4wDAYmcqQXTF0fY3NoCQKIAlfrFLNkSdONi9wvtQKloEvYzLm7hlCwMsO)DbTP8zZIFffa)IWclJYdQWIHmRno4XaF64yukCZxvueb)je3dqKqMNtT8s0epNyj4HWuXDc1iGddwqrfja0SvCn0mqe3Ofe8vVMSTTmPxrJa8LQq)dxFVv7p72Kgs)dbLxImHk7EXBxf4)us8sPNY)zFsmQ(sELBe99WTdPkiJWJ9W10NfMt20Szxw)8NEYZF825MHfM61Qbij4kUa0rosCKIKALXHRuPKEY1efKLrdugIOVMakKnMqJaXRgmA1LIWD0CYBbc2wCq1IMzZ2zmPzZdF)AH0qquS(8u4HCD8gE47O4bhHgTIh(gfqxANu7tlpO0kVzferQEgl4TbICbvbrzwXOHIJvetvghURb0x(XqFfjfHjnkn0FtYJbS5rsYominFLFTmQ6AIlDt25rvKK1FzuCCyQ2skrZjoPUC3MnHXtbspHHDmfHYuRMAkA4Fs7RZ2L(avMlNMkfvmsCGC)3v3FymI2tM78IwyMNSH400dGowImGAR3yHaCGUNmbd4fCxWvhZU8e5BTNQxacUHz0zj49g8T1KNfUjCnlBMuabB8tkIoLZAvdJu03IJHY2PYx6cNa2ghTHGnHlQ2Kk4LqswgB8lPQw8LCsBOhCG2sd6H5lORSS3vAQSTOX2o33226cCqm3ffmHI5ySrN6XTeuUQz72gMwgOJZBpDNp9yazXitA)WFBlXfrcBk(E)cDDm5B9NppU(5gj74wP4QGAnKtuZKCWIUiMZy9c2)ig13O4tSXKtCWofvXvW2eFJ(E(ID0gEHRacLbl3qDo2GWWIYr1Mz1OutrMSNqi6PiJ655XH(fhbqg1ICUXupifBVHTXYejZ737wN5hgHHseQ)31IEskfyj5xiXrhPqUr1kdL8tqYBdzhfksQq1afYSQYWSyk(0y9xnIq7zrOClMMZjfRzk5FgZwYDc5j6et9zc63VlTKWFGwBSVITVgBBb6F4WUzDP4wkytlq(foJZHfJmP(5DTLnaqR1wYsaGEuDPAnvPO7mUX(odj(1bKAcakxLUnAytf7k0Inrksqd5UWSNMLektUVo2OPlihC7HetOhUU)seMhxUihQsoINNbPW2fs)qEvkvA(IWwb3YlWy5WaR4dY6I9SEwHgC8WL8lOQ2fACIjDiCzAy2k6WRdwQaoQ5rn7SC71kUbb71GH85ysWCeMGOfvOqkS4rySimCB8Z(Pjj5IXlPVdv2oPHecvPNkTmT0OAPiX0cdAQeALqAa0kjN8iHi6vYKHuEJWZq5iPCJGMrq50cX9(uzus7WSKyl89zMen8qengz0BMV18pvjejaxqhz)KnAjV3uGnzh0gDGo5iLmO2ZhSrwCgYrCgWnRX4ol4GrHX4(bWfD1S)HzPJEO)jLv3eqgvbn4ivfy)vIDTO91fbgDIct1lcmqum3LYPY8bM9jUqOIpw9S5GQzvNnwJdGPqZ2bfSCjF(r5MYASDhl6A3UUGTFapd69ANyKrqMlYnL1zxsy84JetoW86YXfGQo6ioSmHJ5x9mloWiDvMv5I56uuFuycPfSL8iFfLJvCeguBUY2Kxi8XQSMNbPRGtcCTmSCr87tcUp3kieOGwDvFQLx0QbxDChnskHRLvohUfNCjysaTxuvM1Sp2wm3APzSASIo6QP40YzTPluIGEQgiWS33eYCTxngl9krRAMLP6HyCebLun6CkqPpDQrjey)iYk6vCQeyHYmenCVI0IIjIkhdtr6iHn4RmYRDkCSsp3YlQYFup4GC8QsvyBA8tnvgMaRTH0dGs4O2fteyldNsoCixQogo8FR(NL9uuklKP6nhNItD6OXwP4GLkWhdNmbUtlVvObGNvoeJRb1udhiyT269mq1Yo49myIWPIlQFtVicTTEd5vWkSkuXc0NaCNxVYMDr4iI)E4aj3PSEleSEPDMAkbgwIe30QJ5ER5Jn2b3tARapn43eB6SxKJ2Q8B7(HwtbONnHEAHMuv5U4g07jQgv4qmmx53oaEvR6tRk1Vs1OPUKYKdJvG1rINyIaMzXhy1uvSXZ4ofdhuBJMAOdhexdBZo0f2VYm5tO7QM8fmijFImgosuS56RhlTfhSA1JWRLwlNIig37MgPqg1DwpPZbalX9h6j8DIKdSF2FihXIXTKgk(6VkeGSFsJos0XPRniwgdhv3j8qEpc3tAqHLdOe1WP4DkxzaDSYhyNPq)kVvYLr)bf43bCxTlVn5SBeF9ThFvyAsvEPi))0qH9MUDLUjQ1eLq4)StoCpP1Us3sHoN30s)gw8x9ovYvYjfFRO79JLILOcOsdVpHGMIYwJeIbavgSO8y44HCknXvZPKDGUwRqrNQFab1nY5dWIlq29Y14z4AtMIqL8gPiuz4YIRjNQIWs3qAJxXF9u9Qneo1BVP7P(R(TTUmUgSlCTXOZTOl3n3vKJG74YoVua)wfxMynYBX4ZHltUQklH)qPTsDTUef3((Zfl2(MFkakeEU2bjhYWYfxownRXD2WTW3mOL7s(Omexgw8LwVsqh)DTPZ(gC15pQyX1Lof4xssNLU)xRYUEuIktKfergKnraBSVrsoajjF18CcucQVnx3udjoGtfpkXjoJJnU6CAeeL2x(obQuAZh3bJlP7dwPdV)AyrPK2b1DajLa5Av7Mrb1JK5eMh4tnPP515TLti1S4BZlMB2V3WZaZwol0tux9kbF3wOSHRrC6todfOf0O8LZgnmkLRMnAcpmE1vB0Lgx6exmEPXX3YyvNOzqaF)XbeDo2cPGmsz)YW9sgxuQWaKR3lzjPel3lzJhmzjTgSVuGfAton0BwFSBQXJJTlKjsHDhAveQj)lRVaND1UdNVJE1yhuCGuJKU6eM9fOJ4aKag4Ha5yRIdQjS)FU(PblLRIFHElvt3TnVO)8nNOjkRV8UEcXMWwNQgk(9q6AP9OXen(knni9JY8RjCLDne6QfXR5ALF9rVQmnO)mr9(up0R)3gg6nkd998tUtnyDbClFfZ9PcN8H8WT4XSy)04vFlG4xIG4Zd2gmpIG2vzL5BqMk2v6ylnCkDJ0rzBdJJPJ2FDWdrZzQKj2td9NVqO1jWEB)iYVzmZagMZk44H0WaYO9lGh1q3VxC3CuwcX8DCyWMSiEMYmSAfVcD5aIFxXbYODRjJF(xiwyd28yuCvtDf9X7Ycj(kU0NqRRkkiSsGliMiOSkGIK)(VtGR7t(nT3VC5ahQKsCWqDKccsttEh0Qbq7ETHOz2wmH15kOaL7l4duFccUV8UfuUw6wmgETOfJPqrwxRnIehhHnmuz3yDH3x9CFYgZNcJslJzR4x7NpS)QGmFkXNspKC9(vWYOayWZa0UuwGCfeaHrqxcF(t50VACLgGzbJJErdw4lfJU51613SCwCsUa7dkBfk8ypl8ypeES3xh8ypR8yVtgpgCTEJ5XEtHY2sfp((WG5e955jSWTVp85KnlW0kcp2wxTOz(8Wll1zDzLklScADDWgI38pKgfUKOxC(km0uFCV1OONkkQMjOkuCvsbkrcVoL2dbGrq1rzk7WtHYKtDiq72umxe5r0vtzqwxmv)yooloNHA0buvOAMzoovHNHQneCpQ9Z24vqVzPRd3hNKSWF5U0NfolOBMa98dxVPP161xRzTkXAWzQ5mD9gWvib4fMspwpeUc)5hpxbATEd5k1GZ06uc2(CLU7r7swCUcnnumHgyMc)XhnpbALE7yj1qZ0CJfi2jLJ40(e6AqI7HmR0AvbMTOmMJM3GUMVDmizqAAUX6OJ(sILT2ewtSvAfLpEWQzPS6FyM855SrTeH0keNPMtYok40gWsDfvLBSO7uHPBfjrjpqMO(vxY82GUfKuq0WpLGMbGNCOtImATXEOdLsGyZHGY3t9sszoH88V1ixvPw5vPW0WXiOIPJ4cocT(exhBA36VADjowrzLcvM64jD1Rrw2PWscV5hzb5CETS5UnP7IFwtlNa5t)WUmEm52kqSHovGytQQqSAlvov0kQfZLd9xnxp1AB4LZ3EPrYIT6NsVTvIYgDGSmwM(DQUDtgpOZwOuhveODPXiqNxdd34fQu68xfQmo5D44bs(wvw7afh4q3AtrMVr5CBSVsTTh02mBzdgUsKW4U3jyphQn(AtHQaFOM3uUr2sb6yPk1SxnUgQHRID)hZx9alFTnacnOIbdxNIvk(SFr44eDxAidSjhR45eTilw8Bh1DbJlGzTxk0HRjhVfJPtpf4maxjStOzlyD)nPyRQll2ZDPM0oIEMYWbVgane9U5F)pQ55VY9NtZ7OLkiiJ1bLXCU96AdtAhU5RSM0v3YAjj38UtnIw4)1vZRn5)y83)1vZRjkpV81q3zRCP(Azy(WVoGLf8yJSl8TJhsn(RvZBsFpwUPNAYKMHVeoNUDOg6yQNiLsMBIQF9i9yvF4X1IMn0etnjwH11Ih5wJcySKIbScxF8q3TBm2CDqBMkuKL1PM6FOsDxitnq0I3Wude1E07ck409QLzmaxOOopRx280ox3jvZnMB1tHCNXMAcQFrY75AA7zKdmYPagRguY170GvkXG)SHwFYoD5MGoYmNWX20aModG(Xf)y5S6jq9NBwxFbx(QvvCuDqT1oJ6yTL(1tZNdBP2whAEgX1c(w5JoqEgTxvn2I6hnX56g0Got2sHgBmolErQi99QDHHRIHZ(xAdZjJ6kBzMa3MvoqwGRgRyEJ1a6J6AAkCRFDR3GAnmCZ0qCtxgjmwsb7X0cmfs0O1BSSrAjnD0xdhstU9m964SEcB5wkZSwF6gTGipMEMQ1EitLwOAfjQ7HKQkLHQQMGY0hIbidPj1SM4x1GVmKx0suwqQgyNg7PlJ3LM(S(wnvz0dp3La(RRbOXbWFARfCP9qsxi4hCfRjM8eei6jlLKtXcev57Rm2NQhRrDFC(JRLfqOXj7Xr56(TWNMhR1zuJcY12xUzKdNItYm)15rivChZhdpj1nkkbmKauZz6MlBdEiCgTHjFnQrpM8ML0qGDTkdtQAIq)A(iTj0CQgmKamtstOFnFW251QMGH3OyiPyoOdXqUQ4gV1uxIPymN6GF48K13hWVj6Isp06AVe1vvwkougqMNS5HDHWJ2IFNzF55IlhqDwYf4YLpS4sZMMSBR)6W10c8wqcUyi0vs6tgf)gEt2OfgVqbQSMauE(JssVpc4tVArJdOyY7l3oweFeDXuz7jBz3nxb)ekRFy6FfVlS(6EqVkkrz9bULPLwbKgM69rcAmi3pwOHcFlUiGAz6SYvVhnuuvvgTbOQNBOQNdOQN7OQxdqvpjuvvjVDuTRSB5sNDETp5xWg0yXIBKfafzdXCcUM5xwS2plzSVh7IKpCaTvoCU96dNm8B)J2Z2a8uIup5Qti0fpgEcb71uI0FKYQNYfuZAJtCHHmiP6g6VkijZ)(0QAU9CWNWEzgEEodnlMIU1JD1oAFPiZFDq6xQMMYwoWQWG48v93opVW6X1dQMhO3TAHKK)yte5FKVJyABDXfPqlxm2r9Ih0xUtd1FrW6GhcLrSsiJpY0KAQd)YSPcwYZHQXX6VE9NJ7L55iVMe5he4GOB6F13yeo1iBCMWP4Zqlq5u9jVCt1i2u7jQua1fYEhozQ(JF3uXUi7H)1FtTVYE6(8VzikfNAXCAPQXENN3KdHFn(XeZs2YCR)PPMVFljkZTjv4Cca8o6GMs5JC6u3L3o1hvniFRoj7x7uGChtbRi4QkqTpEGTzELzU649Gu4EyZOSzl2e7yNCZqYVBypAt(ZWVXVttniedOSkzpVtnR6)K)AuHfqVwVdV11(7CxfV5gjoZT(vlwsv7WnHkpc5O9oIpruyAVDnwvRkNWvKFs06kRi)7aTU4ee7xYHM1qnD5aZGvT5GkAhNuhBnYgzDmoNz7jwU(iooZaA)h5O2F5edbNJsMQVhjrHrh0FZBG3Ldgp8Q(djwGdsPlB207(vQoQO1BtsR0A9dfUl)d7NLg()UlkLkNLLqRrOGD5jRdYP)ajQHnpquBS)Z)LOnKhn6N2p7FSjB3w6erhqbOrMnUxmH)az47)mWkwN1UMTOxrw0FMLoB2J)HQeGGLGjYSNNimo0mrrgy3H)wp3wi182aVkaJY9LajTpWRe(GDFbHsEe8QHmsPL6Jilfw2X0wjdd09fYkFcBuUVeUYNSmy3xqN4tMgP0sDT8sr8TPOTqqcCJ(jp4h621yE(Ex3XN7u2961790mMD(zgYNxVB)JDnKhp5jqp7DsVUEw7KFD9C11RIiAbLV47jugt7CzV9Tz6MhAtwsptgV8c73u6ikL)QKRgKFljlRtxPEGY7E3ObdUzYOb9E5LU44zhtSGogiVCzItpO32qoNTmWgF5mDSRZzqyx5VkHDueah(njEEJ35fUm0xWPhAJ7ShDovy0dVUGCvZr(gaORHzoVyiQjyX2LgGDxLhlPe3WSQ1FgbMAOX0UZVlZCb7DZZMMzOX4kK7687FaZ9HrvA75hDM10iCgExgSdImzNwqf57mHo3mbJrr3iARvwD7etZDRPuUKn9vc997oYlxc3d1fAJ6z1ES8os8z1(os4X0UZVlZSD9GWJXvi315hxp7PMQ02Zp6mBxpRhGEaVwxpW7mHockc8okfbaZDRPiatp7Bd997oYlxcFuBhBbO86WljowF5PlwaOfPAn44643gC17vax9uXvSuqDCXPCDRyv(t24lN(D0VRmgqGw58nt0FwZ2sJp3T2g62lnhFNrOQL68SMvLtpTSMyQ3QQ5et9wIDZiM6ZDRrmBFPUVtiuCPoBrUFK0YUmIjSuNEZ4UMwQ3YVBePuFMBnk5PrKdIm99evIlVzlcMJKqAslhD6Y0BW41KtLNFq0uK1O1iSNgXpdA8(EKO1V8iQwMehN8eRmudiWnre8PWuYVtCmCrH4iR6RQkdHIQY6(D5vJBtc78T2TrA0lwqh8IG8G7dYc)P9FM1vMd28m9OX(L1vf3WWHYZm9yVOvGtYYO46kRoRFDzn8(jxqXdHRF0(pdni9lEe84kVGqFiA5eMiH4fo6LxOVH8Ln6gPlAe8CQE5IGhL41aIU8LSkLBwuhguPDBIGNYkrTpqlC7Qqy55a9dSQ7EcpMd4sb4LxKgH6X4R8yKZExzuqNzEdWbpmCaRCg4lpyPiO8yR4a65(7coGSVVet()rvcGlelTR(qfzA47bVqoNJDzC6Do5v6cF9Box7Q3C7KRh07C0lCJtGU(1jPe2l1VdEVAoNJyQ3jKZXVpi03I9o63FMZf0zju8TNdo8skf(vbPziE9fergXHVxmhkMxIFLxecIi5O37vTfb5wV0ZckU)Z)H)qLzOmc6XChmExw(hk)yPo5QbdQPeKbu8XiMQ1UfC5OTlHbc2UFg43jzruK(s(SVuYI)kN(X(Yi)HYjDYakT4m5pIUD0(a6Q(lp6nzG6Vv5vKWxbxKHCJWqEFvxksawf)shldOLehOV1XD(kdju(Qf)vnbN9v)TElJ(Nx4ANSG(iclorsFgHD(TG)McltX0MO6VQWIZenLOr03Tq9gS3bFq47u4KH4VoG3jYVktnYXM(5xHYUPUUBaXv6hIWAxozcNoCy8T)zX)o(sz4mIakBf3cDZWS3EQVTq99aP(ahrx7FcDVJVugO(ahMDZO(VINrh((COWdAHn6Mo4oCGtnaOxnaZZcGj)rKvhS0bk85s6te7bpvnsr2zWAYSoXw3JEg8MuXjMF(mTLJOLMg(o5qMKOD1NYqBt7((4OsePD1jm)eq6(E)GrePBY539eq8()zz5xnkDA7y9lH(H)gjuHnKPIsIkmeSn5js0drBwUJEF9obuAqZAEdCJAn0RfdLxmsr5MlEbPO46A)bQJ9ZZlSdshdpbktgwVcGFbpDDjQUr4MxQJBLcsmHj3sXeXp9NhlIj85XSrl7XTQLzqZ4ck)ry9ZSm64uRWNNopcYr1LliXbEiefpQwK7LxQKI1BdSktnonLEt)LWpAFZ)MHxQbC80xkaBWT8acpOSxQOmj8TBm9aiDfHxE5mJtFVo69Vz1vQSLw8bPE7xbcw6BTEFRNODOt3cLtWx05jWpRUrtwlJJ1H6PQEmm)3o5t9SoKl70vVd0F7ObckGqKNmDCdKj4Lxm88B(O20ZhK6tuYSnDTry1DQYGSYZVvzBM0P)jmUjxPbwQnmaUfhmk6Wb9kJ3wXsdU2EctYeXKnzyTZ9Aom2aUX7CwsF02el3Jte2gI2fYlpXsSU4(Txrqs2qa6uRkRoddzPKcAtvjGG3D27yIfmWHD0hc27S(rHeUvhDkslNDYvfOIqJOUcjy)UPg6GjIWntU2buUztGutVP5VUchbIVBrv1zWc6ekbF)dslpNSVKVduNdQRTRQvYkyKwtBbzRhMcNXDCtvK2cRi7u5Wbx8qrAK9e5EuUr(M6dR7kgg2hc3NCQDyaXSnwhrtba4nKiHvuRB2wY7L6T4A8mEFU14uXMjPpRHQ8GQ(JsR42I4KaqZRs3Vw))UMEJ07V7Hz(7gfroerZBU6a2eC7KroP9tZGqNk80Ct7UmOnmTNipS2hQMy1d(aMlKwG)04IAtZajbx8hDNPfC4G4AEVIANTSlcDFI825ZW2pdhKesphtCnyrR4i8unwa5NUw8k6tD09gSNJEkvTSAMEDANo2g9rGRb3sGvvBDnRjQwtLMoSEywfowDxWOeqOdMDEFCJbWdn2IAHpLWQmhqh4uWLSoWjO9cKUmsitEXYNwRTYTEqNpLngVJHT9PENyyfeUmKibZqxHoe50mixTOhNsQXWW7XgMMLaXQb4J24txuRpvAAnXx7bOIUva0pDSakiuDkI3COlss2Tnzd(QQip3sPPBDiu51SmTUV3Hu)kMUs)OQKvE1h4)zhtjMzIysUQJzq8PfmuHoizpmyvkJYydswpTT9wceIg70RAPyoz4L)4LvLI5UnP7iESlFGfyRDJsB4WrMtB4Kp2RmGawzZtSbjV9YddkAU9awA8mMItG08vdNJQ49sQu6ye3V0iQnUcZrZZ3OZvlCpvwbSFUD4fygDzjAWdIFMNOHtvyNyogDJQJrCagjNWW81x5CdlaeiX9jmcLMJkt6RYtcdhitxBdHiHYCfiBcnI3Y)(LxKoSXc0HS3OxVEMYyO1JJOgIruAut5kPKKDbOKmPynuvs2a1yw8Q5AC1TLARRNeLK1xr51(o4FI9sSdAFQgJiO4bInpogoWww7hx6vnyooS6yKzHC7QyH1PvChTmQV72sTDNR666rrRAx4braw9GIkyhA8cHsbwlb2Da2Z3HpmFAjmu7yckaAWvobZiI5xclyXtG62Y9gKTGUU3ObzWWLKtlIZhAQLBmo0yF1CIn1ECPtofZrcd2WorhNGz9Ag1ICzlRePHk1AzWbl12VwgB))QURLDBDJyOFlzJrdsrqJJl6naXEtb6pq2NcFBvWvOPUbY21BUF8vwZdnpoKCEif7ISjWsEgoC4WhhYHEwn2Mau6ZqwaZvH80lYp5hE9ebU0BQ(HbXBNaNmGSKqctrgCNt0KwLQfjZXbeogIKNubCmc5AzXnZKLiyYnUHsKz2jdzyESmkxblTm6(tTDV3IkfSpTSwesLoEDY(Ix(a1lp1a1bfK2eAjacvjKpMvCUoW0hgKms0CK(6FILEa5RI9x8hUXQGuDuv(y5uROSgkGJXOMGqNI4niQxvyypxGftOWBgs9YwLvZYPVPvcDwdL4uqV)K5kbTPnXs98lKmD7wy4k2dR8cOeAnHAeUugre8cIllxefFysAWs7OX10U40GnauM4cT1xmdmh(uIcFtsWtLQ9j1YNQw1sLopEH5RIz43uxrfXRJI6QSCx(3ifWqq4)S95JziTb8uNQzODSqllTkZVTYAteqGh0Lhc)UOuMAk9oFOxpBpT9VA2fTCw6EfcSuSvYBOZhnWwRwJrKpa6(FuLzVA4n2)rVVlhA6Cl1u7fU07Qa(86hw(9V3TTT)n)3bq3)Za36r8J8p3lDkaHS)M1RsAVWe34XpA60fnucI2Y8s7nJmUXyTj(z2EhfIHbuG9dZdzBoV6xev8Iv9BqigTNFZfLOHetAoDTA71yyq5TxxXy(pZHrf8eujtBxWHrVtEp4Ip0M2zK5mB4dewWDbUYCHlyCd8yuPmmAvd4z7eAvzqC9Rh78YjRsA1twxn0D9)7q8DkK4vYetmZkwtvfJ)CRoQcsdnbxl5aECKeUVFesIpljjIyVLNki0rozS3N6SZyN7PiSHXfs9rbfZHrZtDz(aooatbDnV11S)BNhMfxf3MPCKy8YwdVg64ILrVK4VstPPuGpWEMBL0cF(d2vrujRHwSSs(CEgjVilD7z5)l9OGXrY5ZYmXKMJX3HOfVy2xXlaYCzkPyv6kK9s752DIyvPBNhv7rznBVtbwI5F5hh)3zSeZvKWDLLZlPCp1B(KFNdriuP)TUsq2(C8fvgsi5uw650nlSZGpythQdRPZxKg)ZTGzmZ8QTGV9K7VQrVXZlfK1eZ0Bi6kT72OgVODAdHeJit7oVki3sh5EP2iLTUHv286yRhza0Ab8F69q)n1VdeGkhq4qSeyIp1B3tBySx(sryBFVxbY9FbqNoaCQgw9h4goL5JCcWRa4kFuWY4tOnUmnn(ethPqrBG2c0dxBBF8Bt8F7jGhIgI48s7yGZ2nBZgzRZCJq9awZzlT9BjVIUZEoF0DrSvMfMFrccE8qFZdXKjtnUFjIm8r0vZWd2Bevk3cc7KJcOjiu8HpB4986lnPTs0SQJ76Ao)pTXrWCGegdkilKKucfusJs33COxsD3X93F40PL)(Qp(dW3JOomrStjQmkMJWaV5dlNWogywrbQv6P0KsB4OZv(UDR2xGWwi5yiIv7cHeWbctlSC0BzJVdYYd8Rf0tLJyfPUF438hReGm7W2W9FR993B6mdmmOfIA3myogIlzDICDtsGtTlu8OwAb3rMdguG)Ixf9ObFQe2MgsR6s8hOmDsNAy89UT4HPKadNVgLGpTHWOY)nYozRuduQ(7qoa5QoLACySJWueqYMWGNGjxmF(MRqLcwoqYKBLPRNvDrUWJGJBLWeIKZs1p6mQ)D2rYXqk3rwimrVxuldWxsfC5jmH)VsFm3S87A(65FianIWpQDqKkSvoIFEqbIBgZYprxkneMiwCIwk0(c(f36ipCvybvHe5nx1Qrp0We44cZl0m3IXMHHEQ1wiCLLJDm2DZ14Db9JVf3oXzBYRSdyCFAfCOpm7P()MEqETwmkXJVGDIm9fCkb(zD0PsnJJOvYNmczS8qEms5(jwA4Qsy1zf273V1f6WOhsVzXQ1njpRhxTxOiZd18AtX1n1TvB7Mb2lHW22U7rX25qbF29LGvShHLWDr(ejhZoUAmVyR087whRQHVrHxveCRSEfeE5wmymdWACZ6iC1Gk4sBrLcvMhZoHGcg)(8XfuN(eMHZVkAylwgjsHZjoAiCCFR8HYXvjdpKoCo)Ya6CEq8uxqq5HiK7xk8Ke91RLhaDA8ZLM(KIgIaWjPxVEKFcgWjYR3RAiC4epgM5ec)cGjYuBYCu(jhNcLgT8GLY7McsW(YbDPegVeS7eTZ96lBpE2RTxF5L2)(xF9q)FV(Fd]] )