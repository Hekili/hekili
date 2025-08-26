-- ShamanRestoration.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 264 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {

    -- Shaman
    ancestral_wolf_affinity        = { 103610,  382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf
    arctic_snowstorm               = { 103619,  462764, 1 }, -- Enemies within $s1 yds of your Frost Shock are snared by $s2%
    ascending_air                  = { 103607,  462791, 1 }, -- Wind Rush Totem's cooldown is reduced by $s1 sec and its movement speed effect lasts an additional $s2 sec
    astral_bulwark                 = { 103611,  377933, 1 }, -- Astral Shift reduces damage taken by an additional $s1%
    astral_shift                   = { 103616,  108271, 1 }, -- Shift partially into the elemental planes, taking $s1% less damage for $s2 sec
    brimming_with_life             = { 103582,  381689, 1 }, -- Maximum health increased by $s1%, and while you are at full health, Reincarnation cools down $s2% faster
    call_of_the_elements           = { 103592,  383011, 1 }, -- Reduces the cooldown of Totemic Recall by $s1 sec
    capacitor_totem                = { 103579,  192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s1 sec, stunning all enemies within $s2 yards for $s3 sec
    chain_heal                     = { 103588,    1064, 1 }, -- Heals the friendly target for $s1, then jumps up to $s2 yards to heal the $s3 most injured nearby allies. Healing is reduced by $s4% with each jump
    chain_lightning                = { 103583,  188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing $s$s2 Nature damage and then jumping to additional nearby enemies. Affects $s3 total targets
    creation_core                  = { 103592,  383012, 1 }, -- Totemic Recall affects an additional totem
    earth_elemental                = { 103585,  198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for $s1 min. While this elemental is active, your maximum health is increased by $s2%
    earth_shield                   = { 103596,     974, 1 }, -- Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for $s2 when they take damage. This heal can only occur once every $s3 sec. Maximum $s4 charges. Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them
    earthgrab_totem                = { 103617,   51485, 1 }, -- Summons a totem at the target location for $s1 sec. The totem pulses every $s2 sec, rooting all enemies within $s3 yards for $s4 sec. Enemies previously rooted by the totem instead suffer $s5% movement speed reduction
    elemental_orbit                = { 103602,  383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by $s1. You can have Earth Shield on yourself and one ally at the same time
    elemental_resistance           = { 103601,  462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by $s1% for $s2 sec. Healing from Cloudburst Totem reduces Fire, Frost, and Nature damage taken by $s3% for $s4 sec
    elemental_warding              = { 103597,  381650, 1 }, -- Reduces all magic damage taken by $s1%
    encasing_cold                  = { 103619,  462762, 1 }, -- Frost Shock snares its targets by an additional $s1% and its duration is increased by $s2 sec
    enhanced_imbues                = { 103606,  462796, 1 }, -- The effects of your weapon and shield imbues are increased by $s1%
    fire_and_ice                   = { 103605,  382886, 1 }, -- Increases all Fire and Frost damage you deal by $s1%
    frost_shock                    = { 103604,  196840, 1 }, -- Chills the target with frost, causing $s$s2 Frost damage and reducing the target's movement speed by $s3% for $s4 sec
    graceful_spirit                = { 103626,  192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by $s1 sec and increases your movement speed by $s2% while it is active
    greater_purge                  = { 103624,  378773, 1 }, -- Purges the enemy target, removing $s1 beneficial Magic effects
    guardians_cudgel               = { 103618,  381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place
    gust_of_wind                   = { 103591,  192063, 1 }, -- A gust of wind hurls you forward
    healing_stream_totem           = { 103590,    5394, 1 }, -- Summons a totem at your feet for $s1 sec that heals an injured party or raid member within $s2 yards for $s3 every $s4 sec. If you already know Healing Stream Totem, instead gain $s5 additional charge of Healing Stream Totem
    hex                            = { 103623,   51514, 1 }, -- Transforms the enemy into a frog for $s1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit $s2. Only works on Humanoids and Beasts
    improved_purify_spirit         = {  81073,  383016, 1 }, -- Purify Spirit additionally removes all Curse effects
    jet_stream                     = { 103607,  462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by $s1% and now removes snares
    lava_burst                     = { 103598,   51505, 1 }, -- Hurls molten lava at the target, dealing $s$s2 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock
    lightning_lasso                = { 103589,  305483, 1 }, -- Grips the target in lightning, stunning and dealing $s$s2 Nature damage over $s3 sec while the target is lassoed. Can move while channeling
    mana_spring                    = { 103587,  381930, 1 }, -- Your Lava Burst and Riptide casts restore $s1 mana to you and $s2 allies nearest to you within $s3 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers
    natures_fury                   = { 103622,  381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by $s1%
    natures_guardian               = { 103613,   30884, 1 }, -- When your health is brought below $s1%, you instantly heal for $s2% of your maximum health. Cannot occur more than once every $s3 sec
    natures_swiftness              = { 103620,  378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana
    planes_traveler                = { 103611,  381647, 1 }, -- Reduces the cooldown of Astral Shift by $s1 sec
    poison_cleansing_totem         = { 103609,  383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within $s1 yards every $s2 sec for $s3 sec
    primordial_bond                = { 103612,  381764, 1 }, -- While you have an elemental active, your damage taken is reduced by $s1%
    purge                          = { 103624,     370, 1 }, -- Purges the enemy target, removing $s1 beneficial Magic effect
    refreshing_waters              = { 103594,  378211, 1 }, -- Your Healing Surge is $s1% more effective on yourself
    seasoned_winds                 = { 103628,  355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by $s1% for $s2 sec. Stacks up to $s3 times
    spirit_walk                    = { 103591,   58875, 1 }, -- Removes all movement impairing effects and increases your movement speed by $s1% for $s2 sec
    spirit_wolf                    = { 103581,  260878, 1 }, -- While transformed into a Ghost Wolf, you gain $s1% increased movement speed and $s2% damage reduction every $s3 sec, stacking up to $s4 times
    spiritwalkers_aegis            = { 103626,  378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for $s1 sec
    spiritwalkers_grace            = { 103584,   79206, 1 }, -- Calls upon the guidance of the spirits for $s1 sec, permitting movement while casting Shaman spells. Castable while casting. Increases movement speed by $s2%
    static_charge                  = { 103618,  265046, 1 }, -- Reduces the cooldown of Capacitor Totem by $s1 sec for each enemy it stuns, up to a maximum reduction of $s2 sec
    stone_bulwark_totem            = { 103629,  108270, 1 }, -- Summons a totem at your feet that grants you an absorb shield preventing $s$s2 million damage for $s3 sec, and an additional $s4 every $s5 sec for $s6 sec
    thunderous_paws                = { 103581,  378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional $s1% for the first $s2 sec. May only occur once every $s3 sec
    thundershock                   = { 103621,  378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by $s1 sec
    thunderstorm                   = { 103603,   51490, 1 }, -- Calls down a bolt of lightning, dealing $s$s2 Nature damage to all enemies within $s3 yards, reducing their movement speed by $s4% for $s5 sec, and knocking them away from the Shaman. Usable while stunned
    totemic_focus                  = { 103625,  382201, 1 }, -- Increases the radius of your totem effects by $s1%. Increases the duration of your Earthbind and Earthgrab Totems by $s2 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, Ancestral Protection, Earthen Wall, and Wind Rush Totems by $s3 sec
    totemic_projection             = { 103586,  108287, 1 }, -- Relocates your active totems to the specified location
    totemic_recall                 = { 103595,  108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than $s1 minutes
    totemic_surge                  = { 103599,  381867, 1 }, -- Reduces the cooldown of your totems by $s1 sec
    traveling_storms               = { 103621,  204403, 1 }, -- Thunderstorm now can be cast on allies within $s1 yards, reduces enemies movement speed by $s2%, and knocks enemies $s3% further
    tremor_totem                   = { 103593,    8143, 1 }, -- Summons a totem at your feet that shakes the ground around it for $s1 sec, removing Fear, Charm and Sleep effects from party and raid members within $s2 yards
    voodoo_mastery                 = { 103600,  204268, 1 }, -- Your Hex target is slowed by $s1% during Hex and for $s2 sec after it ends. Reduces the cooldown of Hex by $s3 sec
    wind_rush_totem                = { 103627,  192077, 1 }, -- Summons a totem at the target location for $s1 sec, continually granting all allies who pass within $s2 yards $s3% increased movement speed for $s4 sec
    wind_shear                     = { 103615,   57994, 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $s1 sec
    winds_of_alakir                = { 103614,  382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by $s1%. When you have $s2 or more totems active, your movement speed is increased by $s3%

    -- Restoration
    acid_rain                      = {  81039,  378443, 1 }, -- Deal $s$s2 Nature damage every $s3 sec to up to $s4 enemies inside of your Healing Rain
    ancestral_awakening            = {  81043,  382309, 2 }, -- When you heal with your Healing Wave, Healing Surge, or Riptide you have a $s1% chance to summon an Ancestral spirit to aid you, instantly healing an injured friendly party or raid target within $s2 yards for $s3% of the amount healed. Critical strikes increase this chance to $s4%
    ancestral_protection_totem     = {  81046,  207399, 1 }, -- Summons a totem at the target location for $s1 sec. All allies within $s2 yards of the totem gain $s3% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with $s4% health and mana. Cannot reincarnate an ally who dies to massive damage
    ancestral_reach                = {  81031,  382732, 1 }, -- Chain Heal bounces an additional time and its healing is increased by $s1%
    ancestral_vigor                = { 103429,  207401, 2 }, -- Targets you heal with Healing Wave, Healing Surge, Chain Heal, or Riptide's initial heal gain $s1% increased health for $s2 sec
    ascendance                     = {  81055,  114052, 1 }, -- Transform into a Water Ascendant, duplicating all healing you deal at $s1% effectiveness for $s2 sec and immediately healing for $s3. Ascendant healing is distributed evenly among allies within $s4 yds
    cloudburst_totem               = {  81048,  157153, 1 }, -- Summons a totem at your feet for $s1 sec that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within $s2 yards for $s3% of all healing done while it was active, divided evenly among targets. Casting this spell a second time recalls the totem and releases the healing
    coalescing_water               = { 103915,  470076, 1 }, -- Chain Heal's mana cost is reduced by $s1% and Chain Heal increases the initial healing of your next Riptide by $s2%, stacking up to $s3 times
    current_control                = {  92675,  404015, 1 }, -- Reduces the cooldown of Healing Tide Totem by $s1 sec
    deeply_rooted_elements         = {  81051,  378270, 1 }, -- Casting Riptide has a $s1% chance to activate Ascendance for $s2 sec.  Ascendance Transform into a Water Ascendant, duplicating all healing you deal at $s5% effectiveness for $s6 sec and immediately healing for $s7. Ascendant healing is distributed evenly among allies within $s8 yds
    deluge                         = { 103428,  200076, 1 }, -- Healing Wave, Healing Surge, and Chain Heal heal for an additional $s1% on targets affected by your Healing Rain or Riptide
    downpour                       = {  80976,  462486, 1 }, -- Casting Healing Rain has a $s1% chance to activate Downpour, allowing you to cast Downpour within $s2 sec.  Downpour A burst of water at your Healing Rain's location heals up to $s5 injured allies within $s6 yards for $s7 and increases their maximum health by $s8% for $s9 sec
    earthen_harmony                = { 103430,  382020, 1 }, -- Earth Shield reduces damage taken by $s1% and its healing is increased by up to $s2% as its target's health decreases. Maximum benefit is reached below $s3% health
    earthen_wall_totem             = {  81046,  198838, 1 }, -- Summons a totem at the target location with $s1 million health for $s2 sec. $s3 damage from each attack against allies within $s4 yards of the totem is redirected to the totem
    earthliving_weapon             = {  81049,  382021, 1 }, -- Imbue your weapon with the element of Earth for $s1 |$s2hour:hrs;. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a $s3% chance to trigger Earthliving on the target, healing for $s4 over $s5 sec
    echo_of_the_elements           = {  81044,  333919, 1 }, -- Riptide and Lava Burst have an additional charge
    first_ascendant                = { 103433,  462440, 1 }, -- The cooldown of Ascendance is reduced by $s1 sec
    flow_of_the_tides              = {  81031,  382039, 1 }, -- Chain Heal bounces an additional time and casting Chain Heal on a target affected by Riptide consumes Riptide, increasing the healing of your Chain Heal by $s1%
    healing_rain                   = {  81040,   73920, 1 }, -- Blanket the target area in healing rains, restoring $s1 health to up to $s2 allies over $s3 sec
    healing_tide_totem             = {  81032,  108280, 1 }, -- Summons a totem at your feet for $s1 sec, which pulses every $s2 sec, healing all party or raid members within $s3 yards for $s4. Healing reduced beyond $s5 targets
    healing_stream_totem_2         = {  81022,    5394, 1 }, -- Summons a totem at your feet for $s1 sec that heals an injured party or raid member within $s2 yards for $s3 every $s4 sec. If you already know Healing Stream Totem, instead gain $s5 additional charge of Healing Stream Totem
    high_tide                      = {  81042,  157154, 1 }, -- Every $s1 million mana you spend brings a High Tide, making your next $s2 Chain Heals heal for an additional $s3% and not reduce with each jump
    improved_earthliving_weapon    = {  81050,  382315, 1 }, -- Earthliving receives $s1% additional benefit from Mastery: Deep Healing. Healing Surge always triggers Earthliving on its target
    living_stream                  = {  81048,  382482, 1 }, -- Healing Stream Totem heals for $s1% more, decaying over its duration
    mana_tide                      = {  81045, 1217525, 1 }, -- Healing Tide Totem now additionally grants $s1% increased mana regeneration to allies
    master_of_the_elements         = {  81019,  462375, 1 }, -- Casting Lava Burst increases the healing of your next Healing Surge by $s1%, stacking up to $s2 times. Healing Surge applies Flame Shock to a nearby enemy when empowered by Master of the Elements
    overflowing_shores             = {  92677,  383222, 1 }, -- Healing Rain instantly restores $s1 health to $s2 allies within its area, and its radius is increased by $s3 yards
    preeminence                    = { 103433,  462443, 1 }, -- Your haste is increased by $s1% while Ascendance is active and its duration is increased by $s2 sec
    primal_tide_core               = { 103436,  382045, 1 }, -- Every $s1 casts of Riptide also applies Riptide to another friendly target near your Riptide target
    reactive_warding               = { 103435,  462454, 1 }, -- When refreshing Earth Shield, your target is healed for $s1 for each stack of Earth Shield they are missing. When refreshing Water Shield, you are refunded $s2 mana for each stack of Water Shield missing. Additionally, Earth Shield and Water Shield can consume charges $s3 sec faster
    resurgence                     = {  81024,   16196, 1 }, -- Your direct heal criticals refund a percentage of your maximum mana: $s1% from Healing Wave, $s2% from Healing Surge, Unleash Life, or Riptide, and $s3% from Chain Heal
    riptide                        = {  81027,   61295, 1 }, -- Restorative waters wash over a friendly target, healing them for $s1 and an additional $s2 over $s3 sec
    spirit_link_totem              = {  81033,   98008, 1 }, -- Summons a totem at the target location for $s1 sec, which reduces damage taken by all party and raid members within $s2 yards by $s3%. Immediately and every $s4 sec, the health of all affected players is redistributed evenly
    spiritwalkers_tidal_totem      = {  81045,  404522, 1 }, -- After using Healing Tide Totem, the cast time of your next $s1 Healing Surges within $s2 sec is reduced by $s3% and their mana cost is reduced by $s4%
    spouting_spirits               = { 103432,  462383, 1 }, -- Spirit Link Totem reduces damage taken by an additional $s1%, and it restores $s2 health to all nearby allies $s3 second after it is dropped. Healing reduced beyond $s4 targets
    therazanes_resilience          = { 103435, 1217622, 1 }, -- Earth Shield and Water Shield no longer lose charges and are $s1% effective
    tidal_waves                    = {  81021,   51564, 1 }, -- Casting Riptide grants $s1 stacks of Tidal Waves. Tidal Waves reduces the cast time of your next Healing Wave or Chain Heal by $s2%, or increases the critical effect chance of your next Healing Surge by $s3%
    tide_turner                    = {  92675,  404019, 1 }, -- The lowest health target of Healing Tide Totem is healed for $s1% more and receives $s2% increased healing from you for $s3 sec
    tidebringer                    = {  81041,  236501, 1 }, -- Every $s1 sec, the cast time of your next Chain Heal is reduced by $s2%, and jump distance increased by $s3%. Maximum of $s4 charges
    tidewaters                     = { 103434,  462424, 1 }, -- When you cast Healing Rain, each ally with your Riptide on them is healed for $s1
    torrent                        = {  81047,  200072, 1 }, -- Riptide's initial heal is increased $s1% and has a $s2% increased critical strike chance
    undercurrent                   = {  81052,  382194, 2 }, -- For each Riptide active on an ally, your heals are $s1% more effective
    undulation                     = {  81037,  200071, 1 }, -- Every third Healing Wave or Healing Surge heals for an additional $s1%
    unleash_life                   = {  81037,   73685, 1 }, -- Unleash elemental forces of Life, healing a friendly target for $s1 and increasing the effect of your next healing spell. Riptide, Healing Wave, or Healing Surge: $s2% increased healing. Chain Heal: $s3% increased healing and bounces to $s4 additional target. Healing Rain or Downpour: Affects $s5 additional targets. Wellspring: $s6% of overhealing done is converted to an absorb effect
    water_totem_mastery            = {  81018,  382030, 1 }, -- Consuming Tidal Waves has a chance to reduce the cooldown of your Healing Stream, Cloudburst, Healing Tide, and Poison Cleansing totems by $s1 sec
    wavespeakers_blessing          = { 103427,  381946, 2 }, -- Increases Riptide's duration by $s1 sec and its healing over time by $s2%
    wellspring                     = {  81051,  197995, 1 }, -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for $s1
    whispering_waves               = { 104124, 1217598, 1 }, -- $s1% of Healing Wave's healing from you and your ancestors is duplicated onto each of your targets with Riptide
    white_water                    = {  81038,  462587, 1 }, -- Your critical heals have $s1% effectiveness instead of the usual $s2%

    -- Farseer
    ancestral_swiftness            = {  94894,  443454, 1 }, -- Your next healing or damaging spell is instant, costs no mana, and deals $s1% increased damage and healing. If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side for $s2 sec
    ancient_fellowship             = {  94862,  443423, 1 }, -- Ancestors have a $s1% chance to call another Ancestor for $s2 sec when they depart
    call_of_the_ancestors          = {  94888,  443450, 1 }, -- Benefiting from Undulation calls an Ancestor to your side for $s1 sec. Casting Unleash Life calls an Ancestor to your side for $s2 sec. Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell
    earthen_communion              = {  94858,  443441, 1 }, -- Earth Shield has an additional $s1 charges and heals you for $s2% more
    elemental_reverb               = {  94869,  443418, 1 }, -- Lava Burst gains an additional charge and deals $s1% increased damage. Riptide gains an additional charge and heals for $s2% more
    final_calling                  = {  94875,  443446, 1 }, -- When an Ancestor departs, they cast Hydrobubble on a nearby injured ally.  Hydrobubble Surrounds your target in a protective water bubble for $s4 sec. The shield absorbs the next $s$s5 incoming damage, but the absorb amount decays fully over its duration
    heed_my_call                   = {  94884,  443444, 1 }, -- Ancestors last an additional $s1 sec
    latent_wisdom                  = {  94862,  443449, 1 }, -- Your Ancestors' spells are $s1% more powerful
    maelstrom_supremacy            = {  94883,  443447, 1 }, -- Increases the healing done by Healing Wave, Healing Surge, Wellspring, Downpour, and Chain Heal by $s1%
    natural_harmony                = {  94858,  443442, 1 }, -- Reduces the cooldown of Nature's Guardian by $s1 sec and causes it to heal for an additional $s2% of your maximum health
    offering_from_beyond           = {  94887,  443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of Riptide by $s1 sec
    primordial_capacity            = {  94860,  443448, 1 }, -- Increases your maximum mana by $s1%. Tidal Waves can now stack up to $s2 times
    routine_communication          = {  94884,  443445, 1 }, -- Riptide has a $s1% chance to call an Ancestor to your side for $s2 sec
    spiritwalkers_momentum         = {  94861,  443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by $s1 sec, up to a maximum of $s2 sec

    -- Totemic
    amplification_core             = {  94874,  445029, 1 }, -- While Surging Totem is active, your damage and healing done is increased by $s1%
    earthsurge                     = {  94881,  455590, 1 }, -- Allies affected by your Earthen Wall Totem, Ancestral Protection Totem, and Earthliving effect receive $s1% increased healing from you
    imbuement_mastery              = {  94871,  445028, 1 }, -- Increases the duration of your Earthliving effect by $s1 sec
    lively_totems                  = {  94882,  445034, 1 }, -- When you summon a Healing Tide Totem, Healing Stream Totem, Cloudburst Totem, or Spirit Link Totem you cast a free instant Chain Heal at $s1% effectiveness
    oversized_totems               = {  94859,  445026, 1 }, -- Increases the size and radius of your totems by $s1%, and the health of your totems by $s2%
    oversurge                      = {  94874,  445030, 1 }, -- Surging Totem heals for $s1% more during Ascendance
    pulse_capacitor                = {  94866,  445032, 1 }, -- Increases the healing done by Surging Totem by $s1%
    reactivity                     = {  94872,  445035, 1 }, -- Your Healing Stream Totems now also heals a second ally at $s1% effectiveness. Cloudburst Totem stores $s2% additional healing
    supportive_imbuements          = {  94866,  445033, 1 }, -- Learn a new weapon imbue, Tidecaller's Guard.  Tidecaller's Guard Imbue your shield with the element of Water for $s3 |$s4hour:hrs;. Your healing done is increased by $s5% and the duration of your Healing Stream Totem and Cloudburst Totem is increased by $s6 sec
    surging_totem                  = {  94877,  444995, 1 }, -- Summons a totem at the target location that maintains Healing Rain with $s1% increased effectiveness for $s2 sec. Replaces Healing Rain
    swift_recall                   = {  94859,  445027, 1 }, -- Successfully removing a harmful effect with Tremor Totem or Poison Cleansing Totem, or controlling an enemy with Capacitor Totem or Earthgrab Totem reduces the cooldown of the totem used by $s1 sec. Cannot occur more than once every $s2 sec per totem
    totemic_coordination           = {  94881,  445036, 1 }, -- Chain Heals from Lively Totem and Totemic Rebound are $s1% more effective
    totemic_rebound                = {  94890,  445025, 1 }, -- Chain Heal now jumps to a nearby totem within $s1 yards once it reaches its last target, causing the totem to cast Chain Heal on an injured ally within $s2 yards for $s3. Jumps to $s4 nearby targets within $s5 yards
    whirling_elements              = {  94879,  445024, 1 }, -- Elemental motes orbit around your Surging Totem. Your abilities consume the motes for enhanced effects. Water: Your next Healing Wave or Healing Surge also heals an ally inside of your Healing Rain at $s1% effectiveness. Air: The cast time of your next healing spell is reduced by $s2%. Earth: Your next Chain Heal applies Earthliving at $s3% effectiveness to all targets hit
    wind_barrier                   = {  94891,  445031, 1 }, -- If you have a totem active, your totem grants you a shield absorbing $s1 damage for $s2 sec every $s3 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    burrow                         = 5576, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by $s2% for $s3 sec. When the effect ends, enemies within $s4 yards are knocked in the air and take $s$s5 Physical damage
    counterstrike_totem            =  708, -- (204331) Summons a totem at your feet for $s1 sec. Whenever enemies within $s2 yards of the totem deal direct damage, the totem will deal $s3% of the damage dealt back to attacker
    electrocute                    =  714, -- (206642) When you successfully Purge a beneficial effect, the enemy suffers $s$s2 Nature damage over $s3 sec
    grounding_totem                =  715, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within $s1 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts $s2 sec
    living_tide                    = 5388, -- (353115) Healing Tide Totem's cooldown is reduced by $s1 sec and it heals for $s2% more each time it pulses
    rain_dance                     = 3755, -- (290250) Healing Rain is now instant, $s1% more effective, and costs $s2% less mana
    static_field_totem             = 5567, -- (355580) Summons a totem with $s1% of your health at the target location for $s2 sec that forms a circuit of electricity that enemies cannot pass through
    storm_conduit                  = 5704, -- (1217092) Casting Lightning Bolt or Chain Lightning reduces the cooldown of Astral Shift, Gust of Wind, Wind Shear, and Nature Totems by $s1 sec. Interrupt duration reduced by $s2% on Lightning Bolt and Chain Lightning casts
    totem_of_wrath                 = 5705, -- (460697) Nature's Swiftness summons a totem at your feet for $s1 sec that increases the critical effect of damage and healing spells of all nearby allies within $s2 yards by $s3% for $s4 sec
    unleash_shield                 = 5437, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for $s5 sec. Water Shield: Summons a whirlpool for $s8 sec, reducing damage and healing by $s9% while they stand within it
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
        duration = function() return talent.surging_totem.enabled and 22 or 8 end,
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
    -- Talent: Heals for ${$w2*(1+$w1/100)} upon taking damage.
    -- https://wowhead.com/beta/spell=974
    earth_shield = {
        id = function () return talent.elemental_orbit.enabled and 383648 or 974 end,
        duration = 3600,
        type = "Magic",
        max_stack = function() if talent.therazanes_resilience.enabled then return 1 end
            return 9 + 3 * talent.earthen_communion.rank
        end,
        dot = "buff",
        friendly = true,
        shared = "player",
        copy = { 383648, 974 }
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/beta/spell=73920
    healing_rain = {
        id = 73920,
        duration = function () return 24 and talent.surging_totem.enabled or 10 end,
        max_stack = 1
    },
    master_of_the_elements = {
        id = 462377,
        duration = 30,
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
    tidecallers_guard = {
        id = 457493,
        duration = 3600,
        max_stack = 1,
        copy = 457496
    },
    unleash_life = {
        id = 73685,
        duration = 10,
        max_stack = 1
    },
    water_shield = {
        id = 52127,
        duration = 3600,
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237640, 237536, 237637, 237636, 237638 },
        auras = {
            -- Totemic both specs
            elemental_overflow = {
                id = 1239170,
                duration = 20,
                max_stack = 1
            },
            -- Farseer both specs
            ancestral_wisdom = {
                id = 1238279,
                duration = 8,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229260, 229261, 229262, 229263, 229265 }
    },
    tww1 = {
        items = { 212014, 212012, 212011, 212010, 212009 },
    },
    -- Dragonflight
    tier31 = {
        items = { 207207, 207208, 207209, 207210, 207212 }
    },
    tier30 = {
        items = { 202473, 202471, 202470, 202469, 202468 },
        auras = {
            rainstorm = {
                id = 409386,
                duration = 6,
                max_stack = 40
            },
            swelling_rain = {
                id = 409391,
                duration = 15,
                max_stack = 40
            }
        }
    },
    tier29 = {
        items = { 200399, 200401, 200396, 200398, 200400, 217238, 217240, 217236, 217237, 217239 }
    },
} )

local recall_totems = {
    capacitor_totem = 1,
    earthbind_totem = 1,
    earthgrab_totem = 1,
    grounding_totem = 1,
    healing_stream_totem = 1,
    cloudburst_totem = 1,
    earthen_wall_totem = 1,
    recall_cloudburst_totem = 1,
    poison_cleansing_totem = 1,
    skyfury_totem = 1,
    stoneskin_totem = 1,
    tranquil_air_totem = 1,
    tremor_totem = 1,
    wind_rush_totem = 1,
}

local recallTotem1
local recallTotem2

spec:RegisterTotems( {
    tremor_totem = {
        id = 136108
    },
    wind_rush_totem = {
        id = 538576
    },
    healing_stream_totem = {
        id = 135127
    },
    cloudburst_totem = {
        id = 971076
    },
    earthen_wall_totem = {
        id = 136098
    },
    poison_cleansing_totem = {
        id = 136070
    },
    stoneskin_totem = {
        id = 4667425
    },
    surging_totem = {
        id = 5927655
    },
} )

spec:RegisterStateExpr( "recall_totem_1", function()
    return recallTotem1
end )

spec:RegisterStateExpr( "recall_totem_2", function()
    return recallTotem2
end )

spec:RegisterStateExpr( "earth_shield", function()
    return "earth_shield"
end )

spec:RegisterStateExpr( "lightning_shield", function()
    return "lightning_shield"
end )

spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 6498 then applyBuff( "earthliving_weapon" ) end
    if buff.earthliving_weapon.down and ( now - action.earthliving_weapon.lastCast < 1 ) then applyBuff( "earthliving_weapon" ) end

    if oh and oh_enchant == 7528 then applyBuff( "tidecallers_guard" ) end
    if buff.tidecallers_guard.down and action.tidecallers_guard.time_since < 1 then applyBuff( "tidecallers_guard" ) end

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
            removeStack( "high_tide" )

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
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
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
        bind = "recall_cloudburst_totem"
    },

    -- Recall your Cloudburst Totem, triggering it to release its stored healing energy.
    recall_cloudburst_totem = {
        id = 201764,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 971076,

        usable = function() return totem.cloudburst_totem.up end,

        handler = function ()
            if totem.cloudburst_totem.up then
                totem.cloudburst_totem.expires = query_time
            end
        end,
        bind = "cloudburst_totem"
    },

    -- A burst of water at your Healing Rain's location heals up to 5 injured allies within 12 yards for (275% of Spell power) and increases their maximum health by 10% for 6 sec.
    downpour = {
        id = 462603,
        known = 73920,
        cast = 0,
        cooldown = function() return talent.surging_totem.enabled and 24 or 10 end,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 1698701,
        buff = "downpour",
        talent = "downpour",

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
        id = 470411,
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
        notalent = "surging_totem",

        handler = function ()

            applyBuff( "healing_rain" )

            if talent.downpour.enabled then
                applyBuff( "downpour" )
                setCooldown( "downpour", 0 )
            end
            if set_bonus.tier30_4pc > 0 and active_dot.riptide > 0 then
                applyBuff( "rainstorm", nil, active_dot.riptide )
                applyBuff( "swelling_rain", nil, active_dot.riptide )
            end
        end,

        bind = { "downpour", "surging_totem" }
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 2 end
        end,
        cooldown = function () return 30 - ( talent.totemic_surge.enabled and 6 or 0 ) end,
        recharge = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return ( 30 - (talent.totemic_surge.enabled and 6 or 0 ))
            else return nil end
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

    -- Remove Curse effects from a friendly target.
    purify_spirit = {
        id = 77130,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236288,

        toggle = "interrupts",
        usable = function() return debuff.dispellable_magic.up or ( talent.improved_purify_spirit.enabled and debuff.dispellable_curse.up ), "requires a dispellable effect" end,

        handler = function ()
            removeDebuff( "player", "dispellable_magic" )
            if talent.improved_purify_spirit.enabled then
                removeDebuff( "player", "dispellable_curse" )
            end
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
            if talent.spiritwalkers_tidal_totem.enabled then applyBuff( "spiritwalkers_tidal_totem", nil, 3 ) end
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
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
        end,
    },

    -- Summons a totem at your feet for 8 sec, granting 100% increased mana regeneration to allies within 20 yards.
    --[[mana_tide_totem = {
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
    },--]]

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
    --[[primordial_wave = {
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
    },--]]

    -- Restorative waters wash over a friendly target, healing them for 13,520 and an additional 10,502 over 18 sec.
    riptide = {
        id = 61295,
        cast = 0,
        charges = function () return 2 + ( talent.elemental_reverb.enabled and 1 or 0 ) end,
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

    surging_totem = {
        id = 444995,
        cast = 0,
        cooldown = 24,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",
        talent = "surging_totem",
        startsCombat = false,
        texture = 5927655,

        handler = function ()
            summonTotem( "surging_totem" )

            if talent.downpour.enabled then
                setCooldown( "downpour", 0 )
                applyBuff( "downpour" )
            end
        end,

        bind = { "healing_rain", "downpour" }
    },

    tidecallers_guard = {
        id = 457481,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        talent = "supportive_imbuements",
        nobuff = "tidecallers_guard",
        equipped = "shield",

        handler = function ()
            applyBuff( "tidecallers_guard" )
        end,
    },

	-- Talent: Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_recall = {
        id = 108285,
        cast = 0,
        cooldown = function() return talent.call_of_the_elements.enabled and 120 or 180 end,
        gcd = "spell",
        school = "nature",
        toggle = function() if settings.healing_mode then return "cooldowns" end end,
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
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
        end,
    },
} )

--[[spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )--]]

spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = strformat( "%s %s supports a healing maintenance with the Totemic %s build.  It will recommend using %s and %s, keep %s / %s recharging, and use %s with to enhance particular spells.  Your %s will also be maintained.",
        select( 7, GetSpecializationInfoByID( spec.id ) ), ( UnitClass( "player" ) ), Hekili:GetSpellLinkWithTexture( spec.abilities.chain_heal.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.healing_rain.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.surging_totem.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.riptide.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.healing_stream_totem.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.unleash_life.id ), Hekili:GetSpellLinkWithTexture( spec.talents.earth_shield[2] ) ),
    width = "full",
} )

spec:RegisterSetting( "healing_mode", false, {
    name = "Healing Helper Mode",
    desc = "If checked, healing abilities may be recommended using the default priority package.",
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "second_shield", "earth_shield", {
    name = strformat( "|T236224:0|t Preferred Second %s", _G.SHIELDSLOT ),
    desc = strformat( "Specify which %s spell to use after %s when %s is talented.", _G.SHIELDSLOT, Hekili:GetSpellLinkWithTexture( spec.abilities.water_shield.id ),
        Hekili:GetSpellLinkWithTexture( spec.talents.elemental_orbit[2] ) ),
    type = "select",
    values = function()
        return {
            earth_shield = class.abilityList.earth_shield,
            lightning_shield = class.abilityList.lightning_shield,
        }
    end,
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

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Restoration Shaman",
} )

spec:RegisterPack( "Restoration Shaman", 20241020, [[Hekili:vJ1xVTTnq8plgdWnbjvZYojTDiopS9YAXqFyUa7njrlrBtejrpkQ4gad9zF3r9pskkn3HvmSxsKjpE)J397oEb(bFjytcrsd(8YflVZFXYfElxTWF1YGnYxpsd2CKe)mzp8rojd(7VtlKCbrY45vrBoqYi5inVMYjjiVk4LIyGUGnBlzPYpMhS1Paw(aq7rAmS8d3fS5aljHwtlTioyds7Bx8U3UAXpvf9Ld0QO)GiG)WKhyOaf8DSuqmKyutk8okOX8STe5nR)rkripKYEHLVp8eLCe00p5IojlHgtstPIIW9LerIBYobkViS4aJMMClB36TL725PVOx5XBulQeS9IPS9hK5OU0TXJ(3ijP0CPhnLMb)NKgYfBzspbj)5ZNVAMlzmVGkLaFk8oqjPidZ4j0RDR02sfv8R(ER5x3RIfGQKN0CW12CYToRRe)3QV6SFkDTJPUj6ixLM8PUDH1koYem5js6ZQWobjMEBghJvx7Jgn8TINEjScjjpM(0dvF6hQI(yo4geLhLvr8DvrXKczHNoJpXu6pOy6RIX3H1)mmf44Tyw86MaOBlKcwSSwWoJU0zvR10VszbnKjPzf6lUnLZtc3vkE1yvWAPINb(QV6oMGQOxFr0ObfdUPqL3GjK9H8DHOs)SHmlkf7rvwYbTbnMMlDsmljuqygADR9HRJ0oR29pFQZSlfCBG3Lh)8TXVgNsdLeXEQSO23He(cnKMtZy0Ihxnxq3jOfhiBtPQBpnVOGLXfjmW8orEXWbNsEHeUTua3sy0Vjtx7F(S1klNxh2Jhd9auiG)65jCPNM66jOzGXu8egXekzz05XCEAc)uEOGcCuxdglQ2aqzlpvPGa6neB14h8IpasjSJQhxE(8SgpQ1wgHNMB93Y2N8h7wPnhYyFbhSz797ZvBIeakr3XrOYvh(EzEkLuCaK8o0TE(SA1wYq0yZfA8YpU0f3HAKKqSAtFakUK3Xy5JV)ExNqrhlgUHWCa8aaUYlH7JtQH(O5q0d6Mq6CXGlJQAVl(7od)a4Qv6kyJopInGshgIczPXVnMF0fhnsEDrGEc7O2QwDJM0emrqFRPRfm3vDLlrAnfRTo5Luzz(iQdnhXnsUEkFb41PKmnap8dpdxjQfZQ)Y1PgX8eSJ4TpYZwCcVM1WKriRSy0ncZiF1fp1dc0qNvHsiE(bAynOpxu0A9Np3jLtaGqbGBMVVpndAsQBFtRULKvxAo7tRC6P7LQoKrJPObz4Ap9ZoC3gVwWMxGIIWE1DgV4d(qlXNiceNRiyJQPxw2rUak5VJdn)(Me6oszQ8nvrc6Fwc1otQIk4zaDKsjpdAucwaUlYH7cO3GFJLdB57dDq)l8CqyQ9FJDDoGDsUJ1BVjG9VY)Rx3ZWL)BZWhCZqlSFl2AT7qMx9PpQ8EilVRTeCvecAHENGnQVW3S01Zg8JpRErunXbBg(ucyTAbf8Zbs4MtN6bpOWI4viX9RSjg6eKkye8Tsd70Tk6MQiNOsDB4OJ3QOhbpQIKjq7QIoFgCuvrZA40azphcTC2ry019gS(Pqd8UrnWRgtoFpTXRnnddK4QO1ySGjV7TSb7aw39)pZ60fQviTMv9WG49(gaTIFFNoP1phWKcj8q(6yLUmPXd3TBnqfsAdzRSrNW2k30YE9PD)USsNsUTVl1PF)99h3QhTPtxNOzmn0aJE46spmC1wh1WBpE42Gg165AFhDD3Tx8nqWM6E5WBUEgA1VxnSzy9WGAyWGydJkYwM171juV1ol6(WO6(i93DP5nZDNtoEgI)IPs8Nnwk(LNCQOD6MbnGDhOGJNP5UVqLaNH1tNO7WH3s6eOK745zJ1IOY2NQ)XEP22MekOXtfVKEjRHwMOFYASKUIIt3zPI4vF7WvpPoL21OE6NYknWh61YbySn9b6cJT(ZW6x7Ab9zpzjLk9Gww7WrtPofYjqqoWvXz1QUMWJ7CcvA2t38PMgB1zxhF7qtT1HSHDDv2QgQT7APDQwwezuOSFkxtvJSFQxtbc2nfmxiGTezovmlkRrO6KQ(yYSPCcOIrAxFmy9Pbaa0L6qhDWTj4TrLaxP8DER(H(4OOqZSXAZrNJpvQBuCa96ZURjO23UR1wj1ppoRi9Ack8AYdhovpRse262AvDke)WXol7XqmMSxBdFJmFpvYC3m(uuAoNpLPE)L3SN)4npm5i60XsN1DZpYR10C2gZxuPaV7FQcaEcF7wI62wXAv(xp02qytNrBM(NpCX8OFmKdGYB7GY(HNDDZAk0LxsfIAWv7YOwsgKnPuEGds4xPpZszQ1c(R)]] )