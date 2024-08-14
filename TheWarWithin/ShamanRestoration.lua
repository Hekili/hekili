-- ShamanRestoration.lua
-- July 2024

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 264 )

local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Shaman
    ancestral_guidance          = { 103810, 108281, 1 }, -- For the next 10 sec, 10% of your healing done and 25% of your damage done is converted to healing on up to 3 nearby injured party or raid members, up to 181,592 healing to each target per second.
    ancestral_wolf_affinity     = { 103610, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    arctic_snowstorm            = { 103619, 462764, 1 }, -- Enemies within 10 yds of your Frost Shock are snared by 30%.
    ascending_air               = { 103607, 462791, 1 }, -- Wind Rush Totem's cooldown is reduced by 30 sec and its movement speed effect lasts an additional 2 sec.
    astral_bulwark              = { 103611, 377933, 1 }, -- Astral Shift reduces damage taken by an additional 20%.
    astral_shift                = { 103616, 108271, 1 }, -- Shift partially into the elemental planes, taking 40% less damage for 12 sec.
    brimming_with_life          = { 103582, 381689, 1 }, -- Maximum health increased by 10%, and while you are at full health, Reincarnation cools down 75% faster.
    call_of_the_elements        = { 103592, 383011, 1 }, -- Reduces the cooldown of Totemic Recall by 60 sec.
    capacitor_totem             = { 103579, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after 2 sec, stunning all enemies within 8 yards for 3 sec.
    chain_heal                  = { 103588,   1064, 1 }, -- Heals the friendly target for 51,719, then jumps up to 15 yards to heal the 4 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_lightning             = { 103583, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing 53,900 Nature damage and then jumping to additional nearby enemies. Affects 3 total targets.
    creation_core               = { 103592, 383012, 1 }, -- Totemic Recall affects an additional totem.
    earth_elemental             = { 103585, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for 1 min. While this elemental is active, your maximum health is increased by 15%.
    earth_shield                = { 103596,    974, 1 }, -- Protects the target with an earthen shield, increasing your healing on them by 20% and healing them for 15,133 when they take damage. This heal can only occur once every few seconds. Maximum 9 charges. Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.
    earthgrab_totem             = { 103617,  51485, 1 }, -- Summons a totem at the target location for 20 sec. The totem pulses every 2 sec, rooting all enemies within 8 yards for 8 sec. Enemies previously rooted by the totem instead suffer 50% movement speed reduction.
    elemental_orbit             = { 103602, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1. You can have Earth Shield on yourself and one ally at the same time.
    elemental_resistance        = { 103601, 462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by 6% for 3 sec. Healing from Cloudburst Totem reduces Fire, Frost, and Nature damage taken by 3% for 3 sec.
    elemental_warding           = { 103597, 381650, 1 }, -- Reduces all magic damage taken by 6%.
    encasing_cold               = { 103619, 462762, 1 }, -- Frost Shock snares its targets by an additional 10% and its duration is increased by 2 sec.
    enhanced_imbues             = { 103606, 462796, 1 }, -- The effects of your weapon imbues are increased by 20%.
    fire_and_ice                = { 103605, 382886, 1 }, -- Increases all Fire and Frost damage you deal by 3%.
    frost_shock                 = { 103604, 196840, 1 }, -- Chills the target with frost, causing 15,962 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    graceful_spirit             = { 103626, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by 30 sec and increases your movement speed by 20% while it is active.
    greater_purge               = { 103624, 378773, 1 }, -- Purges the enemy target, removing 2 beneficial Magic effects.
    guardians_cudgel            = { 103618, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind                = { 103591, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem        = { 103590,   5394, 1 }, -- Summons a totem at your feet for 15 sec that heals an injured party or raid member within 40 yards for 13,095 every 1.6 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    hex                         = { 103623,  51514, 1 }, -- Transforms the enemy into a frog for 1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    improved_purify_spirit      = {  81073, 383016, 1 }, -- Purify Spirit additionally removes all Curse effects.
    jet_stream                  = { 103607, 462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by 10% and now removes snares.
    lava_burst                  = { 103598,  51505, 1 }, -- Hurls molten lava at the target, dealing 56,153 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.
    lightning_lasso             = { 103589, 305483, 1 }, -- Grips the target in lightning, stunning and dealing 115,172 Nature damage over 5 sec while the target is lassoed. Can move while channeling.
    mana_spring                 = { 103587, 381930, 1 }, -- Your Lava Burst and Riptide casts restore 150 mana to you and 4 allies nearest to you within 40 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury                = { 103622, 381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by 4%.
    natures_guardian            = { 103613,  30884, 1 }, -- When your health is brought below 35%, you instantly heal for 27% of your maximum health. Cannot occur more than once every 45 sec.
    natures_swiftness           = { 103620, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    planes_traveler             = { 103611, 381647, 1 }, -- Reduces the cooldown of Astral Shift by 30 sec.
    poison_cleansing_totem      = { 103609, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within 30 yards every 1.5 sec for 6 sec.
    primordial_bond             = { 103612, 381764, 1 }, --
    purge                       = { 103624,    370, 1 }, -- Purges the enemy target, removing 1 beneficial Magic effect.
    refreshing_waters           = { 103594, 378211, 1 }, -- Your Healing Surge is 25% more effective on yourself.
    seasoned_winds              = { 103628, 355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by 15% for 18 sec. Stacks up to 2 times.
    spirit_walk                 = { 103591,  58875, 1 }, -- Removes all movement impairing effects and increases your movement speed by 60% for 8 sec.
    spirit_wolf                 = { 103581, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain 5% increased movement speed and 5% damage reduction every 1 sec, stacking up to 4 times.
    spiritwalkers_aegis         = { 103626, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for 5 sec.
    spiritwalkers_grace         = { 103584,  79206, 1 }, -- Calls upon the guidance of the spirits for 15 sec, permitting movement while casting Shaman spells. Castable while casting.
    static_charge               = { 103618, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by 5 sec for each enemy it stuns, up to a maximum reduction of 20 sec.
    stone_bulwark_totem         = { 103629, 108270, 1 }, -- Summons a totem with 45,398 health at the feet of the caster for 30 sec, granting the caster a shield absorbing 230,342 damage for 10 sec, and up to an additional 23,034 every 5 sec.
    thunderous_paws             = { 103581, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional 25% for the first 3 sec. May only occur once every 20 sec.
    thundershock                = { 103621, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by 5 sec.
    thunderstorm                = { 103603,  51490, 1 }, -- Calls down a bolt of lightning, dealing 2,647 Nature damage to all enemies within 10 yards, reducing their movement speed by 40% for 5 sec, and knocking them away from the Shaman. Usable while stunned.
    totemic_focus               = { 103625, 382201, 1 }, -- Increases the radius of your totem effects by 15%. Increases the duration of your Earthbind and Earthgrab Totems by 10 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, Ancestral Protection, Earthen Wall, and Wind Rush Totems by 3.0 sec.
    totemic_projection          = { 103586, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall              = { 103595, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge               = { 103599, 381867, 1 }, -- Reduces the cooldown of your totems by 6 sec.
    traveling_storms            = { 103621, 204403, 1 }, -- Thunderstorm now can be cast on allies within 40 yards, reduces enemies movement speed by 60%, and knocks enemies 25% further.
    tremor_totem                = { 103593,   8143, 1 }, -- Summons a totem at your feet that shakes the ground around it for 10 sec, removing Fear, Charm and Sleep effects from party and raid members within 30 yards.
    voodoo_mastery              = { 103600, 204268, 1 }, -- Your Hex target is slowed by 70% during Hex and for 6 sec after it ends. Reduces the cooldown of Hex by 15 sec.
    wind_rush_totem             = { 103627, 192077, 1 }, -- Summons a totem at the target location for 15 sec, continually granting all allies who pass within 10 yards 40% increased movement speed for 5 sec.
    wind_shear                  = { 103615,  57994, 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for 2 sec.
    winds_of_alakir             = { 103614, 382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by 10%. When you have 3 or more totems active, your movement speed is increased by 15%.

    -- Restoration
    acid_rain                   = {  81039, 378443, 1 }, -- Deal 11,070 Nature damage every 1 sec to up to 5 enemies inside of your Healing Rain.
    ancestral_awakening         = {  81043, 382309, 2 }, -- When you heal with your Healing Wave, Healing Surge, or Riptide you have a 20% chance to summon an Ancestral spirit to aid you, instantly healing an injured friendly party or raid target within 40 yards for 15% of the amount healed. Critical strikes increase this chance to 40%.
    ancestral_protection_totem  = {  81046, 207399, 1 }, -- Summons a totem at the target location for 30 sec. All allies within 20 yards of the totem gain 10% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with 20% health and mana. Cannot reincarnate an ally who dies to massive damage.
    ancestral_reach             = {  81031, 382732, 1 }, -- Chain Heal bounces an additional time and its healing is increased by 8%.
    ancestral_vigor             = { 103429, 207401, 1 }, -- Targets you heal with Healing Wave, Healing Surge, Chain Heal, or Riptide's initial heal gain 10% increased health for 10 sec.
    ascendance                  = {  81055, 114052, 1 }, -- Transform into a Water Ascendant, duplicating all healing you deal at 70% effectiveness for 15 sec and immediately healing for 151,335. Ascendant healing is distributed evenly among allies within 40 yds.
    cloudburst_totem            = {  81048, 157153, 1 }, -- Summons a totem at your feet for 15 sec that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within 40 yards for 24% of all healing done while it was active, divided evenly among targets. Casting this spell a second time recalls the totem and releases the healing.
    current_control             = {  92675, 404015, 1 }, -- Reduces the cooldown of Healing Tide Totem by 45 sec.
    deeply_rooted_elements      = {  81051, 378270, 1 }, -- Casting Riptide has a 7% chance to activate Ascendance for 6.0 sec.  Ascendance Transform into a Water Ascendant, duplicating all healing you deal at 70% effectiveness for 15 sec and immediately healing for 151,335. Ascendant healing is distributed evenly among allies within 40 yds.
    deluge                      = { 103428, 200076, 1 }, -- Healing Wave, Healing Surge, and Chain Heal heal for an additional 15% on targets affected by your Healing Rain or Riptide.
    downpour                    = {  80976, 462486, 1 }, -- Casting Healing Rain has a 100% chance to activate Downpour, allowing you to cast Downpour within 6 sec.  Downpour A burst of water at your Healing Rain's location heals up to 5 injured allies within 12 yards for 51,827 and increases their maximum health by 10% for 6 sec.
    earthen_harmony             = { 103430, 382020, 1 }, -- Earth Shield reduces damage taken by 5% and its healing is increased by up to 150% as its target's health decreases. Maximum benefit is reached below 50% health.
    earthen_wall_totem          = {  81046, 198838, 1 }, -- Summons a totem at the target location with 544,776 health for 15 sec. 4,862 damage from each attack against allies within 10 yards of the totem is redirected to the totem.
    earthliving_weapon          = {  81049, 382021, 1 }, -- Imbue your weapon with the element of Earth for 1 |4hour:hrs;. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a 20% chance to trigger Earthliving on the target, healing for 15,381 over 12 sec.
    echo_of_the_elements        = {  81044, 333919, 1 }, -- Riptide and Lava Burst have an additional charge.
    first_ascendant             = { 103433, 462440, 1 }, -- The cooldown of Ascendance is reduced by 60 sec.
    flow_of_the_tides           = {  81031, 382039, 1 }, -- Chain Heal bounces an additional time and casting Chain Heal on a target affected by Riptide consumes Riptide, increasing the healing of your Chain Heal by 30%.
    healing_rain                = {  81040,  73920, 1 }, -- Blanket the target area in healing rains, restoring 42,637 health to up to 5 allies over 10 sec.
    healing_stream_totem        = {  81022,   5394, 1 }, -- Summons a totem at your feet for 15 sec that heals an injured party or raid member within 40 yards for 13,095 every 1.6 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    healing_tide_totem          = {  81032, 108280, 1 }, -- Summons a totem at your feet for 10 sec, which pulses every 1.6 sec, healing all party or raid members within 40 yards for 29476.6. Healing reduced beyond 5 targets.
    healing_wave                = {  81026,  77472, 1 }, -- An efficient wave of healing energy that restores 78,604 of a friendly target’s health.
    high_tide                   = {  81042, 157154, 1 }, -- Every 100,000 mana you spend brings a High Tide, making your next 2 Chain Heals heal for an additional 10% and not reduce with each jump.
    improved_earthliving_weapon = {  81050, 382315, 1 }, -- Earthliving receives 150% additional benefit from Mastery: Deep Healing. Healing Surge always triggers Earthliving on its target.
    living_stream               = {  81048, 382482, 1 }, -- Healing Stream Totem heals for 100% more, decaying over its duration.
    mana_tide_totem             = {  81045,  16191, 1 }, -- Summons a totem at your feet for 8 sec, granting 80% increased mana regeneration to allies within 40 yards.
    master_of_the_elements      = {  81019, 462375, 1 }, -- Casting Lava Burst increases the healing of your next Healing Surge by 30%, stacking up to 2 times. Healing Surge applies Flame Shock to a nearby enemy when empowered by Master of the Elements.
    overflowing_shores          = {  92677, 383222, 1 }, -- Healing Rain instantly restores 8,893 health to 5 allies within its area, and its radius is increased by 2 yards.
    preeminence                 = { 103433, 462443, 1 }, -- Your haste is increased by 25% while Ascendance is active and its duration is increased by 3 sec.
    primal_tide_core            = { 103436, 382045, 1 }, -- Every 4 casts of Riptide also applies Riptide to another friendly target near your Riptide target.
    primordial_wave             = {  81036, 428332, 1 }, -- Blast your target with a Primordial Wave, healing them for 11,229 and applying Riptide to them. Your next Healing Wave will also hit all targets affected by your Riptide for 40% of normal healing.
    reactive_warding            = { 103435, 462454, 1 }, -- When refreshing Earth Shield, your target is healed for 14,684 for each stack of Earth Shield they are missing. When refreshing Water Shield, you are refunded 285 mana for each stack of Water Shield missing.
    resurgence                  = {  81024,  16196, 1 }, -- Your direct heal criticals refund a percentage of your maximum mana: 0.80% from Healing Wave, 0.48% from Healing Surge or Riptide, and 0.20% from Chain Heal.
    riptide                     = {  81027,  61295, 1 }, -- Restorative waters wash over a friendly target, healing them for 47,724 and an additional 35,249 over 18 sec.
    spirit_link_totem           = {  81033,  98008, 1 }, -- Summons a totem at the target location for 6 sec, which reduces damage taken by all party and raid members within 10 yards by 10%. Immediately and every 1 sec, the health of all affected players is redistributed evenly.
    spiritwalkers_tidal_totem   = {  92681, 404522, 1 }, -- After using Mana Tide Totem, the cast time of your next 3 Healing Surges within 30 sec is reduced by 100% and their mana cost is reduced by 50%.
    spouting_spirits            = { 103432, 462383, 1 }, -- Spirit Link Totem reduces damage taken by an additional 5%, and it restores 207,307 health to all nearby allies 1 second after it is dropped. Healing reduced beyond 5 targets.
    tidal_waves                 = {  81021,  51564, 1 }, -- Casting Riptide grants 2 stacks of Tidal Waves. Tidal Waves reduces the cast time of your next Healing Wave or Chain Heal by 20%, or increases the critical effect chance of your next Healing Surge by 30%.
    tide_turner                 = {  92675, 404019, 1 }, -- The lowest health target of Healing Tide Totem is healed for 30% more and receives 15% increased healing from you for 4 sec.
    tidebringer                 = {  81041, 236501, 1 }, -- Every 8 sec, the cast time of your next Chain Heal is reduced by 50%, and jump distance increased by 100%. Maximum of 2 charges.
    tidewaters                  = { 103434, 462424, 1 }, -- When you cast Healing Rain, each ally with your Riptide on them is healed for 38,006.
    torrent                     = {  81047, 200072, 1 }, -- Riptide's initial heal is increased 20% and has a 10% increased critical strike chance.
    undercurrent                = {  81052, 382194, 2 }, -- For each Riptide active on an ally, your heals are 0.5% more effective.
    undulation                  = {  81037, 200071, 1 }, -- Every third Healing Wave or Healing Surge heals for an additional 50%.
    unleash_life                = {  81037,  73685, 1 }, -- Unleash elemental forces of Life, healing a friendly target for 45,953 and increasing the effect of your next healing spell. Riptide, Healing Wave, or Healing Surge: 35% increased healing. Chain Heal: 15% increased healing and bounces to 1 additional target. Healing Rain or Downpour: Affects 2 additional targets. Wellspring: 40% of overhealing done is converted to an absorb effect.
    water_totem_mastery         = {  81018, 382030, 1 }, -- Consuming Tidal Waves has a chance to reduce the cooldown of your Healing Stream, Cloudburst, Healing Tide, Mana Tide, and Poison Cleansing totems by 3.0 sec.
    wavespeakers_blessing       = { 103427, 381946, 2 }, -- Increases the duration of Riptide by 6.0 sec.
    wellspring                  = {  81051, 197995, 1 }, -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for 34,551.
    white_water                 = {  81038, 462587, 1 }, -- Your critical heals have 215% effectiveness instead of the usual 200%.

    -- Totemic
    amplification_core          = {  94874, 445029, 1 }, -- While Surging Totem is active, your damage and healing done is increased by 3%.
    earthsurge                  = {  94881, 455590, 1 }, -- Allies affected by your Earthen Wall Totem, Ancestral Protection Totem, and Earthliving effect receive 10% increased healing from you.
    imbuement_mastery           = {  94871, 445028, 1 }, -- Increases the duration of your Earthliving effect by 6 sec.
    lively_totems               = {  94882, 445034, 1 }, -- Your Healing Tide Totem, Healing Stream Totem, Cloudburst Totem, Mana Tide Totem, and Spirit Link Totem cast a free, instant Chain Heal at 100% effectiveness when you summon them.
    oversized_totems            = {  94859, 445026, 1 }, -- Increases the size and radius of your totems by 15%, and the health of your totems by 30%.
    oversurge                   = {  94874, 445030, 1 }, -- While Ascendance is active, Surging Totem is 150% more effective.
    pulse_capacitor             = {  94866, 445032, 1 }, -- Increases the healing done by Surging Totem by 25%.
    reactivity                  = {  94872, 445035, 1 }, -- Your Healing Stream Totems now also heals a second ally at 50% effectiveness. Cloudburst Totem stores 25% additional healing.
    supportive_imbuements       = {  94866, 445033, 1 }, -- Learn a new weapon imbue, Tidecaller's Guard.  Tidecaller's Guard Imbue your shield with the element of Water for 1 |4hour:hrs;. Your healing done is increased by 2% and the duration of your Healing Stream Totem and Cloudburst Totem is increased by 3 sec.
    surging_totem               = {  94877, 444995, 1, "totemic" }, -- Summons a totem at the target location that maintains Healing Rain for 24 sec. Heals for 30% more than a normal Healing Rain. Replaces Healing Rain.
    swift_recall                = {  94859, 445027, 1 }, -- Successfully removing a harmful effect with Tremor Totem or Poison Cleansing Totem, or controlling an enemy with Capacitor Totem or Earthgrab Totem reduces the cooldown of the totem used by 5 sec. Cannot occur more than once every 20 sec per totem.
    totemic_coordination        = {  94881, 445036, 1 }, -- Chain Heals from your totems are 25% more effective.
    totemic_rebound             = {  94890, 445025, 1 }, -- Chain Heal now jumps to a nearby totem within 20 yards once it reaches its max targets, causing the totem to cast Chain Heal on an injured ally within 30 yards for 25,913. Jumps to 2 nearby targets within 20 yards.
    whirling_elements           = {  94879, 445024, 1 }, -- Elemental motes orbit around your Surging Totem. Your abilities consume the motes for enhanced effects. Water: Air: Earth:
    wind_barrier                = {  94891, 445031, 1 }, -- If you have a totem active, your totem grants you a shield absorbing 54,477 damage for 30 sec every 30 sec.

    -- Farseer
    ancestral_swiftness         = {  94894, 443454, 1 }, -- Your next healing or damaging spell is instant, costs no mana, and deals 10% increased damage and healing. If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side.
    ancient_fellowship          = {  94862, 443423, 1 }, -- Ancestors have a 15% chance to call another Ancestor when they expire.
    call_of_the_ancestors       = {  94888, 443450, 1, "farseer" }, -- Triggering Undulation or casting Unleash Life calls an Ancestor to your side for 6 sec. Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell.
    earthen_communion           = {  94858, 443441, 1 }, -- Earth Shield has an additional 3 charges and heals you for 25% more.
    elemental_reverb            = {  94869, 443418, 1 }, -- Lava Burst gains an additional charge and deals 5% increased damage. Riptide gains an additional charge and heals for 5% more.
    final_calling               = {  94875, 443446, 1 }, -- When an Ancestor expires, they cast Hydrobubble on a nearby injured ally.  Hydrobubble
    heed_my_call                = {  94884, 443444, 1 }, -- Ancestors last an additional 2 sec.
    latent_wisdom               = {  94862, 443449, 1 }, -- Your Ancestors' spells are 20% more powerful.
    maelstrom_supremacy         = {  94883, 443447, 1 }, -- Increases the healing done by Healing Wave, Healing Surge, Wellspring, Downpour, and Chain Heal by 8%.
    natural_harmony             = {  94858, 443442, 1 }, -- Reduces the cooldown of Nature's Guardian by 10 sec and causes it to heal for an additional 5% of your maximum health.
    offering_from_beyond        = {  94887, 443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of Riptide by 2 sec.
    primordial_capacity         = {  94860, 443448, 1 }, -- Increases your maximum mana by 5%. Tidal Waves can now stack up to 4 times.
    routine_communication       = {  94884, 443445, 1 }, -- Riptide has a 15% chance to call an Ancestor.
    spiritwalkers_momentum      = {  94861, 443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by 1 sec, up to a maximum of 4 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5576, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by 50% for 5 sec. When the effect ends, enemies within 6 yards are knocked in the air and take 108,591 Physical damage.
    counterstrike_totem =  708, -- (204331) Summons a totem at your feet for 15 sec. Whenever enemies within 20 yards of the totem deal direct damage, the totem will deal 100% of the damage dealt back to attacker.
    electrocute         =  714, -- (206642)
    grounding_totem     =  715, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within 30 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    living_tide         = 5388, -- (353115)
    rain_dance          = 3755, -- (290250)
    static_field_totem  = 5567, -- (355580) Summons a totem with 4% of your health at the target location for 6 sec that forms a circuit of electricity that enemies cannot pass through.
    totem_of_wrath      =  707, -- (460697) Primordial Wave summons a totem at your feet for 15 sec that increases the critical effect of damage and healing spells of all nearby allies within 40 yards by 20% for 15 sec.
    unleash_shield      = 5437, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
} )


-- Auras
spec:RegisterAuras( {
    ascendance = {
        id = 114052,
        duration = function() return talent.preeminence.enabled and 18 or 15 end,
        max_stack = 1,
    },
    downpour = {
        id = 462488,
        duration = 10,
        max_stack = 1
    },
    downpour_hot = {
        id = 207778,
        duration = 6,
        max_stack = 1
    },
    earthliving_weapon = {
        id = 382021,
        duration = 3600,
        max_stack = 1
    },
    earthliving_weapon_hot = {
        id = 382024,
        duration = 6,
        max_stack = 1
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/beta/spell=73920
    healing_rain = {
        id = 73920,
        duration = 10,
        max_stack = 1
    },
    master_of_the_elements = {
        id = 462377,
        duration = 15,
        max_stack = 2
    },
    spiritwalkers_tidal_totem = {
        id = 404523,
        duration = 10,
        max_stack = 3
    },
    -- Receiving $422915s1% of all Riptide healing $@auracaster deals.
    tidal_reservoir = {
        id = 424461,
        duration = 15,
        max_stack = 1,
    },
    tidal_waves = {
        id = 53390,
        duration = 15,
        max_stack = 2,
    },
    tide_turner = {
        id = 404072,
        duration = 4,
        max_stack = 1
    },
    tidebringer = {
        id = 236502,
        duration = 3600,
        max_stack = 2
    },
    unleash_life = {
        id = 73685,
        duration = 10,
        max_stack = 1
    },
    water_shield = {
        id = 52127,
        duration = 1800,
        max_stack = 9,
        shared = "player",
        dot = "buff"
    },
    high_tide = {
        id = 288675,
        duration = 25,
        max_stack = 2
    },
    cloudburst_totem = {
        id = 157504,
        duration = 18,
        max_stack = 1
    },
} )

-- Tier 29
spec:RegisterGear( "tier29", 200399, 200401, 200396, 200398, 200400, 217238, 217240, 217236, 217237, 217239 )

-- Tier 30
spec:RegisterGear( "tier30", 202473, 202471, 202470, 202469, 202468 )
spec:RegisterAuras( {
    rainstorm = {
        id = 409386,
        duration = 6,
        max_stack = 40 -- IDK.
    },
    swelling_rain = {
        id = 409391,
        duration = 15,
        max_stack = 40 -- IDK.
    }
} )

spec:RegisterGear( "tier31", 207207, 207208, 207209, 207210, 207212 )

local recall_totems = {
    capacitor_totem = 1,
    earthbind_totem = 1,
    earthgrab_totem = 1,
    grounding_totem = 1,
    healing_stream_totem = 1,
    cloudburst_totem = 1,
    earthen_wall_totem = 1,
    poison_cleansing_totem = 1,
    skyfury_totem = 1,
    stoneskin_totem = 1,
    tranquil_air_totem = 1,
    tremor_totem = 1,
    wind_rush_totem = 1,
}

local recallTotem1
local recallTotem2

spec:RegisterTotem( "tremor_totem", 136108 )
spec:RegisterTotem( "wind_rush_totem", 538576 )
spec:RegisterTotem( "healing_stream_totem", 135127 )
spec:RegisterTotem( "cloudburst_totem", 971076 )
spec:RegisterTotem( "earthen_wall_totem", 136098 )
spec:RegisterTotem( "poison_cleansing_totem", 136070 )
spec:RegisterTotem( "stoneskin_totem", 4667425 )

spec:RegisterStateExpr( "recall_totem_1", function()
    return recallTotem1
end )

spec:RegisterStateExpr( "recall_totem_2", function()
    return recallTotem2
end )

spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 6498 then applyBuff( "earthliving_weapon" ) end
    if buff.earthliving_weapon.down and ( now - action.earthliving_weapon.lastCast < 1 ) then applyBuff( "earthliving_weapon" ) end

    recall_totem_1 = nil
    recall_totem_2 = nil
end )

spec:RegisterHook( "runHandler", function( action )
    if talent.totemic_recall.enabled and recall_totems[ action ] then
        recall_totem_2 = recall_totem_1
        recall_totem_1 = action
    end
end )

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, school )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]
            local key = ability and ability.key

            if key and recall_totems[ key ] then
                recallTotem2 = recallTotem1
                recallTotem1 = key
            end
        end
    end
end )

-- Abilities
spec:RegisterAbilities( {
    -- Summons a totem at the target location for 30 sec. All allies within 20 yards of the totem gain 10% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with 20% health and mana. Cannot reincarnate an ally who dies to massive damage.
    ancestral_protection_totem = {
        id = 207399,
        cast = 0,
        cooldown = 300,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136080,

        toggle = "defensives",

        handler = function ()
            summonTotem( "ancestral_protection_totem" )
            applyBuff( "ancestral_protection_totem" )
        end,
    },

    -- Transform into a Water Ascendant, duplicating all healing you deal for 15 sec and immediately healing for 58,058. Ascendant healing is distributed evenly among allies within 20 yds.
    ascendance = {
        id = 114052,
        cast = 0,
        cooldown = function() return talent.first_ascendant.enabled and 120 or 180 end,
        gcd = "spell",

        startsCombat = false,
        texture = 135791,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ascendance" )
            if talent.preeminence.enabled then stat.haste = stat.haste + 0.25 end
        end,
    },

    -- Heals the friendly target for 13,918, then jumps to heal the 3 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_heal = {
        id = 1064,
        cast = function() return 2.5 * ( buff.tidebringer.up and 0.5 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.056,
        spendType = "mana",

        startsCombat = false,
        texture = 136042,

        handler = function ()
            if buff.tidebringer.up and buff.natures_swiftness.down and buff.ancestral_swiftness.down then removeStack( "tidebringer" ) end
            removeStack( "tidal_waves" )
            removeBuff( "swelling_rain" ) -- T30
            removeStack( "natures_swiftness" )
            removeStack( "ancestral_swiftness" )

            if set_bonus.tier31_2pc > 0 then applyDebuff( "target", "tidal_reservoir" ) end
        end,
    },

    -- Hurls a lightning bolt at the enemy, dealing 9,800 Nature damage and then jumping to additional nearby enemies. Affects 3 total targets.
    chain_lightning = {
        id = 188443,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,
        texture = 136015,

        handler = function ()
            removeBuff( "natures_swiftness" )
        end,
    },

    -- Summons a totem at your feet for 15 sec that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within 40 yards for 20% of all healing done while it was active, divided evenly among targets. Casting this spell a second time recalls the totem and releases the healing.
    cloudburst_totem = {
        id = 157153,
        cast = 0,
        charges = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 2 end
        end,
        cooldown = 45,
        recharge = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 45 end
        end,
        hasteCD = true,
        gcd = "totem",
        icd = 1,

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 971076,

        handler = function ()
            summonTotem( "cloudburst_totem" )
            applyBuff( "cloudburst_totem" )
        end,
    },

    -- A burst of water at your Healing Rain's location heals up to 5 injured allies within 12 yards for (275% of Spell power) and increases their maximum health by 10% for 6 sec.
    downpour = {
        id = 462603,
        known = function() return talent.downpour.enabled and 73920 or nil end,
        cast = 0,
        cooldown = 10, -- ???
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 1698701,
        buff = "downpour",

        handler = function ()
            removeBuff( "downpour" )
            applyBuff( "downpour_hot" )
        end,

        bind = "healing_rain"
    },

    -- Summons a totem at the target location with 309,139 health for 15 sec. 2,164 damage from each attack against allies within 10 yards of the totem is redirected to the totem.
    earthen_wall_totem = {
        id = 198838,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136098,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "earthen_wall_totem" )
            applyBuff( "earthen_wall_totem" )
        end,
    },

    -- Imbue your weapon with the element of Earth for 1 |4hour:hrs;. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a 20% chance to trigger Earthliving on the target, healing for 7,447 over 12 sec.
    earthliving_weapon = {
        id = 382021,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        startsCombat = false,
        texture = 237578,
        essential = true,
        nobuff = "earthliving_weapon",

        handler = function ()
            applyBuff( "earthliving_weapon" )
        end,
    },

    -- Sears the target with fire, causing 3,099 Fire damage and then an additional 19,919 Fire damage over 18 sec. Flame Shock can be applied to a maximum of 6 targets.
    flame_shock = {
        id = 188389,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135813,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
        end,
    },

    -- Imbue your weapon with the element of Fire for 1 |4hour:hrs;, causing each of your attacks to deal 71 additional Fire damage.
    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135814,

        handler = function ()
            applyBuff( "flametongue_weapon" )
        end,
    },

    -- Chills the target with frost, causing 5,788 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = false,
        texture = 135849,

        handler = function ()
            applyDebuff( "frost_shock" )
        end,
    },

    -- Purges the enemy target, removing 2 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 451166,
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    -- Summons a totem at your feet that will redirect all harmful spells cast within 30 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        pvptalent = "grounding_totem",
        startsCombat = false,
        texture = 136039,

        handler = function ()
            summonTotem( "grounding_totem" )
        end,
    },

    -- Blanket the target area in healing rains, restoring 12,334 health to up to 6 allies over 10 sec.
    healing_rain = {
        id = 73920,
        cast = 2,
        cooldown = 10,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 136037,
        nobuff = "downpour",

        handler = function ()
            applyBuff( "healing_rain" )

            if talent.downpour.enabled then applyBuff( "downpour" ) end

            if set_bonus.tier30_4pc > 0 and active_dot.riptide > 0 then
                applyBuff( "rainstorm", nil, active_dot.riptide )
                applyBuff( "swelling_rain", nil, active_dot.riptide )
            end
        end,

        bind = "downpour"
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 2 end
        end,
        cooldown = 30,
        recharge = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 30 end
        end,
        gcd = "totem",

        spend = 0.09,
        spendType = "mana",

        notalent = "cloudburst_totem",
        startsCombat = false,
        texture = 135127,

        handler = function ()
            summonTotem( "healing_stream_totem" )
        end,
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = function() return buff.spiritwalkers_tidal_totem.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.044 * ( buff.spiritwalkers_tidal_totem.up and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136044,

        handler = function ()
            removeStack( "tidal_waves" )
            removeBuff( "swelling_rain" ) -- T30
            removeStack( "natures_swiftness" )
            removeStack( "spiritwalkers_tidal_totem" )

            if buff.master_of_the_elements.up then
                active_dot.flame_shock = min( true_active_enemies, active_dot.flame_shock + 1 )
                removeBuff( "master_of_the_elements" )
            end

            if talent.earthen_harmony.enabled then
                addStack( "earth_shield", nil, 1 )
            end

            if talent.improved_earthliving_weapon.enabled and buff.earthliving_weapon.up then
                applyBuff( "earthliving_weapon_hot" )
            end

            if set_bonus.tier31_2pc > 0 then applyDebuff( "target", "tidal_reservoir" ) end
        end,
    },

    -- Summons a totem at your feet for 10 sec, which pulses every 1.7 sec, healing all party or raid members within 40 yards for 2827.1. Healing increased by 100% when not in a raid.
    healing_tide_totem = {
        id = 108280,
        cast = 0,
        cooldown = function() return talent.current_control.enabled and 135 or 180 end,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 538569,

        toggle = "defensives",

        handler = function ()
            summonTotem( "healing_tide_totem" )
        end,
    },

    -- An efficient wave of healing energy that restores 21,075 of a friendly target’s health.
    healing_wave = {
        id = 77472,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 136043,

        handler = function ()
            removeStack( "tidal_waves" )
            removeBuff( "swelling_rain" ) -- T30
            removeBuff( "primordial_wave" )
            removeStack( "natures_swiftness" )

            if talent.earthen_harmony.enabled then
                addStack( "earth_shield", nil, 1 )
            end

            if set_bonus.tier31_2pc > 0 then applyDebuff( "target", "tidal_reservoir" ) end
        end,
    },

    -- Hurls molten lava at the target, dealing 16,967 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.
    lava_burst = {
        id = 51505,
        cast = function() return buff.lava_surge.up and 0 or ( 2 * haste ) end,
        charges = function()
            if talent.echo_of_the_elements.enabled then return 2 end
        end,
        cooldown = 8,
        recharge = function()
            if talent.echo_of_the_elements.enabled then return 8 end
        end,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 237582,
        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeBuff( "lava_surge" )
            if talent.master_of_the_elements.enabled then addStack( "master_of_the_elements" ) end
        end,
    },

    -- Hurls a bolt of lightning at the target, dealing 10,473 Nature damage.
    lightning_bolt = {
        id = 188196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
            removeBuff( "natures_swiftness" )
        end,
    },

    -- Summons a totem at your feet for 8 sec, granting 100% increased mana regeneration to allies within 20 yards.
    mana_tide_totem = {
        id = 16191,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        startsCombat = false,
        texture = 4667424,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "mana_tide_totem" )
            if talent.spiritwalkers_tidal_totem.enabled then applyBuff( "spiritwalkers_tidal_totem", nil, 3 ) end
        end,
    },

    -- Talent: Summons a totem at your feet that removes $383015s1 poison effect from a nearby party or raid member within $383015a yards every $383014t1 sec for $d.
    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = function () return 45 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136070,

        handler = function ()
            summonTotem( "poison_cleansing_totem" )
        end,
    },

    -- Blast your target with a Primordial Wave, dealing 4,265 Shadow damage and apply Flame Shock to an enemy, or heal an ally for 4,308 and apply Riptide to them. Your next Healing Wave will also hit all targets affected by your Riptide for 60% of normal healing.
    primordial_wave = {
        id = 428332,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 3578231,

        handler = function ()
            applyBuff( "riptide")
            applyDebuff( "target", "flame_shock" )
        end,

        copy = 428332,
    },

    -- Restorative waters wash over a friendly target, healing them for 13,520 and an additional 10,502 over 18 sec.
    riptide = {
        id = 61295,
        cast = 0,
        charges = 2,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 252995,

        handler = function ()
            applyBuff( "riptide" )
            if talent.tidal_waves.enabled then
                addStack( "tidal_waves", nil, 2 )
            end
        end,
    },

    -- Summons a totem at the target location for 6 sec, which reduces damage taken by all party and raid members within 10 yards by 10%. Immediately and every 1 sec, the health of all affected players is redistributed evenly.
    spirit_link_totem = {
        id = 98008,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 237586,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "spirit_link_totem" )
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
	
    -- Unleash elemental forces of Life, healing a friendly target for 12,592 and increasing the effect of your next healing spell. Riptide, Healing Wave, or Healing Surge: 35% increased healing. Chain Heal: 15% increased healing and bounces to 1 additional target. Healing Rain or Downpour: 2 additional allies healed. Wellspring: 25% of overhealing done is converted to an absorb effect.
    unleash_life = {
        id = 73685,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 462328,

        handler = function ()
            applyBuff( "unleash_life" )
        end,
    },

    -- Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
    unleash_shield = {
        id = 356736,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 538567,

        handler = function ()
        end,
    },

    -- The caster is surrounded by globes of water, granting 238 mana per 5 sec. When a melee attack hits the caster, the caster regains 2% of their mana. This effect can only occur once every few seconds. Only one of your Elemental Shields can be active on you at once.
    water_shield = {
        id = 52127,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132315,
        essential = true,
        nobuff = "water_shield",

        handler = function ()
            applyBuff( "water_shield" )
        end,
    },

    -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for 12,592.
    wellspring = {
        id = 197995,
        cast = 1.5,
        cooldown = 20,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,
        texture = 893778,

        handler = function ()
            removeBuff( "natures_swiftness" )
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterRanges( "lightning_bolt", "flame_shock", "wind_shear", "primal_strike" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Restoration Shaman",
} )


spec:RegisterPack( "Restoration Shaman", 20240730, [[Hekili:nBvWUnUnq0VLGc4KGKv1Y2BY2I4CO9stqXEOAb6njrlnYMWuIQKu2nag8BVdPSLOOLZwSx29sIWmp)Mhho8rghg)L4OCIcI)8SPZwm9X5tdM(PPZdNhhPERgIJQjzBjRXpQiL4F)lqQ4cIIYR0PrBiLKkdM3yCsUHljVrKH4IJw1qzQxQIxnEbMHyRHmm8dlIJ2qZZHwSGmloYG9dtF8dZN(R60VSb0P)nrG)HQ2qnfuWlOmSmKmJsKb1ciJxUIOUB5pdeHAdJUJwTozpqQrL(6y42JQsKi3qbw(90ILRAkkcCdg0uFNnOLr)Gm66nQktr6s8u4DkcdQubadkX)tyjCXkQkqqQ2oUk8P57NsC5(7Tk6WpoOAUDa81USymznvqv7jSTGqMSwqYG7l5MPGLHMLd(TLZGCQurQYGNFq)6pPtFPcxHIMALoLxOtZisLmWL490QCCnHcZn6jj0hPrcjufukDdUIX55jfnI3gefLii2IAZnAbvaw8UbnkvQeyNlJWydiHSoHxKOe0STdQjkvMzFqqOvMv(vTTHjh3liz0CBUb1MHhVXvjpB79zVLXGefrSguY2MNb4oibQGskiFA(ebuia5gYkgy7IongbTKlYPOI3t2bUfHr2rsw1iKkdN3mK0LHho4fz2K2jlZpt2GYbNPUDsoxf4i3abuIlg5ZMDUefTeMKX5SC((QebGm6QGlnDn4G4koZkq0FIXo1hcY2GvjPd1tZoC4QJDuVuUS6L6Rs7ZHxAx50S8G8coUMhMpoAhoDHao54gI(R7jcd7Y4iRzkTSMlWb(coAQEDouqAyQR1Pc4FAWHWCDQKxI4inkEj6aGbqDwTgmNm(tAfMk04m)78kSy28x7pDH0P4JepaQmtn5y(Bc)3B7jCX4e61G8O1l75KRF9f7I1q5StZP6ugT9yECK9l71GTTb8ZpBVw8ivX)2PptABXMazOvdiOK4OZSv0PpRtF40vtMB5oZxY(RmmHfsHBtEvZCfOGw3(Zh1EQN9EZjdtZnmDkvRdLlZiIfUi6CS8a9rxq9oyEOEyaQohnpup6IQZHZd0NCbn0XZd5VmOOUoGEadN61v73YUsN22)1PtWPPlmF2xgx)ul1(JhDlV(JRU1BORMo9jD6CBPDmrr8UUUhNmc9hnovPENuVXLJEdbhhMp3p2vy30EEWvBlXdI60dhgnZmRQp3twNERnZfCMTNi6CNTih6qBxQdMD98P93BxCX9231C126N1U8UQBN)cwion7b3myfWh)wfa2jc7z2lTLA7XQE)HZ9EgDABy)5X)3C0FbYqouMhzF8bxDoId2Dg8cBpb4p223Eg7rL607oov59WY(eJ84s7MzOfY78ithNsNI25v(dMg9POZX(hmD6Y9zxy8(NDF4RDfLD2dF4XgUio6pGTug1gl()c]] )