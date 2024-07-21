-- ShamanRestoration.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 264 )

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

    -- Restoration Talents
    acid_rain                   = { 81039, 378443, 1 }, -- Deal ${$378597s1*$s1} Nature damage every $378463t1 sec to up to $378597s2 enemies inside of your Healing Rain.
    amplification_core          = { 94874, 445029, 1 }, -- While Surging Totem is active, your damage and healing done is increased by $456369s1%.
    ancestral_awakening         = { 81043, 382309, 2 }, -- When you heal with your Healing Wave, Healing Surge, or Riptide you have a $s2% chance to summon an Ancestral spirit to aid you, instantly healing an injured friendly party or raid target within 40 yards for $s1% of the amount healed. Critical strikes increase this chance to $s3%.
    ancestral_protection_totem  = { 81046, 207399, 1 }, -- Summons a totem at the target location for $d. All allies within $?s382201[${$207495s1*(1+$382201s3/100)}][$207495s1] yards of the totem gain $207498s1% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with $207553s1% health and mana.; Cannot reincarnate an ally who dies to massive damage.
    ancestral_reach             = { 81031, 382732, 1 }, -- Chain Heal bounces an additional time and its healing is increased by $s2%.
    ancestral_swiftness         = { 94894, 443454, 1 }, -- [443454] Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.; If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side.
    ancestral_vigor             = { 103429, 207401, 1 }, -- Targets you heal with Healing Wave, Healing Surge, Chain Heal, or Riptide's initial heal gain $207400s2% increased health for $207400d.
    ancient_fellowship          = { 94862, 443423, 1 }, -- Ancestors have a $s1% chance to call another Ancestor when they expire.
    ascendance                  = { 81055, 114052, 1 }, -- Transform into a Water Ascendant, duplicating all healing you deal at $s4% effectiveness for $114051d and immediately healing for $294020s1. Ascendant healing is distributed evenly among allies within $114083A1 yds.
    call_of_the_ancestors       = { 94888, 443450, 1 }, -- $?a137040[Primordial Wave calls an Ancestor to your side for $445624d. ][Benefiting from Undulation calls an Ancestor to your side for $445624d.; Casting Unleash Life calls an Ancestor to your side for $s1 sec.; ]Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell.
    cloudburst_totem            = { 81048, 157153, 1 }, -- Summons a totem at your feet for $d that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within $157503A1 yards for $157503s2% of all healing done while it was active, divided evenly among targets.; Casting this spell a second time recalls the totem and releases the healing.
    current_control             = { 92675, 404015, 1 }, -- Reduces the cooldown of Healing Tide Totem by ${$s1/-1000} sec.
    deeply_rooted_elements      = { 81051, 378270, 1 }, -- [114052] Transform into a Water Ascendant, duplicating all healing you deal at $s4% effectiveness for $114051d and immediately healing for $294020s1. Ascendant healing is distributed evenly among allies within $114083A1 yds.
    deluge                      = { 103428, 200076, 1 }, -- Healing Wave, Healing Surge, and Chain Heal heal for an additional $s1% on targets affected by your Healing Rain or Riptide.
    downpour                    = { 80976, 462486, 1 }, -- [207778] A burst of water at your Healing Rain's location heals up to $s2 injured allies within $A1 yards for $s1 and increases their maximum health by $s3% for $d.
    earthen_communion           = { 94858, 443441, 1 }, -- Earth Shield has an additional $s1 charges and heals you for $s3% more.
    earthen_harmony             = { 103430, 382020, 1 }, -- Earth Shield reduces damage taken by $s3% and its healing is increased by up to $s1% as its target's health decreases. Maximum benefit is reached below $s2% health.
    earthen_wall_totem          = { 81046, 198838, 1 }, -- Summons a totem at the target location with ${$m2*$MHP/100} health for $d. ${$m3*$SP/100} damage from each attack against allies within $?s382201[${$198839s1*(1+$382201s3/100)}.1][$198839s1] yards of the totem is redirected to the totem.
    earthliving_weapon          = { 81049, 382021, 1 }, -- Imbue your weapon with the element of Earth for $382022d. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a $382022s2% chance to trigger Earthliving on the target, healing for $382024o1 over $382024d.
    earthsurge                  = { 94881, 455590, 1 }, -- $?a137041[Casting Sundering within 40 yards of your Surging Totem causes it to create a Tremor at 200% effectiveness at the target area.][Allies affected by your Earthen Wall Totem, Ancestral Protection Totem, and Earthliving effect receive 10% increased healing from you.]
    echo_of_the_elements        = { 81044, 333919, 1 }, -- $?s137039[Riptide and Lava Burst have][Lava Burst has] an additional charge.
    elemental_reverb            = { 94869, 443418, 1 }, -- Lava Burst gains an additional charge and deals 5% increased damage.$?a137039[; Riptide gains an additional charge and heals for 5% more.][]; 
    final_calling               = { 94875, 443446, 1 }, -- [444490] Surrounds your target in a protective water bubble for $d.; The shield absorbs the next $?a443449[${$s1*(1+$443449s1/100)}][$s1] incoming damage, but the absorb amount decays fully over its duration.
    first_ascendant             = { 103433, 462440, 1 }, -- The cooldown of Ascendance is reduced by ${$s1/-1000} sec.
    flow_of_the_tides           = { 81031, 382039, 1 }, -- Chain Heal bounces an additional time and casting Chain Heal on a target affected by Riptide consumes Riptide, increasing the healing of your Chain Heal by $s1%.; 
    healing_rain                = { 81040, 73920 , 1 }, -- Blanket the target area in healing rains, restoring ${$73921m1*6*2/$t2} health to up to $s4 allies over $d.
    healing_tide_totem          = { 81032, 108280, 1 }, -- Summons a totem at your feet for $d, which pulses every $t2 sec, healing all party or raid members within $114942A1 yards for $114942m1.; Healing reduced beyond $s1 targets.
    healing_wave                = { 81026, 77472 , 1 }, -- An efficient wave of healing energy that restores $s1 of a friendly targetâ€™s health.
    heed_my_call                = { 94884, 443444, 1 }, -- Ancestors last an additional ${$s1/1000} sec.
    high_tide                   = { 81042, 157154, 1 }, -- Every ${$c*$s1} mana you spend brings a High Tide, making your next $288675n Chain Heals heal for an additional $288675s1% and not reduce with each jump.
    imbuement_mastery           = { 94871, 445028, 1 }, -- $?a137041[Increases the chance for Windfury Weapon to trigger by $s1% and increases its damage by $s2%.][Increases the duration of your  Earthliving effect by ${$s3/1000} sec.]; 
    improved_earthliving_weapon = { 81050, 382315, 1 }, -- Earthliving receives $s1% additional benefit from Mastery: Deep Healing.; Healing Surge always triggers Earthliving on its target.
    improved_purify_spirit      = { 81073, 383016, 1 }, -- Purify Spirit additionally removes all Curse effects.
    latent_wisdom               = { 94862, 443449, 1 }, -- Your Ancestors' spells are $s1% more powerful.
    lively_totems               = { 94882, 445034, 1 }, -- $?a137041[Lava Lash has a chance to summon a Searing Totem to hurl Searing Bolts that deal $3606s1 Fire damage to a nearby enemy. Lasts $458101d.][Your Healing Tide Totem, Healing Stream Totem, Cloudburst Totem, Mana Tide Totem, and Spirit Link Totem cast a free, instant Chain Heal at $458221s2% effectiveness when you summon them.]
    living_stream               = { 81048, 382482, 1 }, -- Healing Stream Totem heals for $s1% more, decaying over its duration.
    maelstrom_supremacy         = { 94883, 443447, 1 }, -- $?a137040[Increases the damage of Earth Shock, Elemental Blast, and Earthquake by $s1% and the healing of Healing Surge by $s2%.][Increases the healing done by Healing Wave, Healing Surge, Wellspring, Downpour, and Chain Heal by $s2%.]
    mana_tide_totem             = { 81045, 16191 , 1 }, -- Summons a totem at your feet for $d, granting $320763s1% increased mana regeneration to allies within $<radius> yards.
    master_of_the_elements      = { 81019, 462375, 1 }, -- Casting Lava Burst increases the healing of your next Healing Surge by $462377s1%, stacking up to $462377u times.; Healing Surge applies Flame Shock to a nearby enemy when empowered by Master of the Elements.
    natural_harmony             = { 94858, 443442, 1 }, -- Reduces the cooldown of Nature's Guardian by ${$s1/-1000} sec and causes it to heal for an additional $s2% of your maximum health.
    offering_from_beyond        = { 94887, 443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of $?a137040[Fire Elemental and Storm Elemental by ${$s1/-1000} sec.][Riptide by ${$s2/-1000} sec.]
    overflowing_shores          = { 92677, 383222, 1 }, -- $?a455630[Surging Totem][Healing Rain] instantly restores $383223s1 health to $s3 allies within its area, and its radius is increased by $s1 $Lyard:yards;.
    oversized_totems            = { 94859, 445026, 1 }, -- Increases the size and radius of your totems by $458016s2%, and the health of your totems by $458016s1%.
    oversurge                   = { 94874, 445030, 1 }, -- While Ascendance is active, Surging Totem is $s1% more effective.
    preeminence                 = { 103433, 462443, 1 }, -- Your haste is increased by $s2% while Ascendance is active and its duration is increased by ${$s1/1000} sec.
    primal_tide_core            = { 103436, 382045, 1 }, -- Every $s1 casts of Riptide also applies Riptide to another friendly target near your Riptide target.
    primordial_capacity         = { 94860, 443448, 1 }, -- Increases your maximum $?a137040[Maelstrom by $s1.][mana by $s2%.; Tidal Waves can now stack up to ${$s3+$s4} times.]
    primordial_wave             = { 81036, 428332, 1 }, -- Blast your target with a Primordial Wave, healing them for $375985s1 and applying Riptide to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    pulse_capacitor             = { 94866, 445032, 1 }, -- $?a137041[Increases the damage of Surging Totem by $s1%.][Increases the healing done by Surging Totem by $s2%.]
    reactive_warding            = { 103435, 462454, 1 }, -- When refreshing Earth Shield, your target is healed for $462477s1 for each stack of Earth Shield they are missing.; When refreshing Water Shield, you are refunded $462479s1 mana for each stack of Water Shield missing.
    reactivity                  = { 94872, 445035, 1 }, -- $?a137041[Frost Shocks empowered by Hailstorm, Lava Lash, and Fire Nova cause your Searing totems to shoot a Searing Volley at up to $s1 nearby enemies for $458147s1 Fire damage.][Your Healing Stream Totems now also heals a second ally at $s3% effectiveness. ; Cloudburst Totem stores $s2% additional healing.]
    resurgence                  = { 81024, 16196 , 1 }, -- Your direct heal criticals refund a percentage of your maximum mana: $<healingwave>% from Healing Wave, $<healingsurge>% from Healing Surge$?s73685[, Unleash Life,][] or Riptide, and $<chainheal>% from Chain Heal.
    riptide                     = { 81027, 61295 , 1 }, -- Restorative waters wash over a friendly target, healing them for $s1 and an additional $o2 over $d.
    routine_communication       = { 94884, 443445, 1 }, -- $?a137040[Lava Burst casts have a $s2][Riptide has a $s1]% chance to call an Ancestor.
    spirit_link_totem           = { 81033, 98008 , 1 }, -- Summons a totem at the target location for $d, which reduces damage taken by all party and raid members within $98007a1 yards by $98007s1%. Immediately and every $98017t1 sec, the health of all affected players is redistributed evenly.
    spiritwalkers_momentum      = { 94861, 443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by ${$s1/1000} sec, up to a maximum of ${$s2/1000} sec.
    spiritwalkers_tidal_totem   = { 92681, 404522, 1 }, -- After using Mana Tide Totem, the cast time of your next $404523u Healing Surges within $404523d is reduced by $404523s1% and their mana cost is reduced by $404523s2%.
    spouting_spirits            = { 103432, 462383, 1 }, -- Spirit Link Totem reduces damage taken by an additional $s1%, and it restores $462384s1 health to all nearby allies $m2 $Lsecond:seconds; after it is dropped. Healing reduced beyond $s3 targets.; 
    supportive_imbuements       = { 94866, 445033, 1 }, -- [457481] Imbue your shield with the element of Water for $457496d. Your healing done is increased by $457496s2% and the duration of your Healing Stream Totem and Cloudburst Totem is increased by ${$457496s1/1000} sec.
    surging_totem               = { 94877, 444995, 1 }, -- Description not found.
    swift_recall                = { 94859, 445027, 1 }, -- Successfully removing a harmful effect with Tremor Totem or Poison Cleansing Totem, or controlling an enemy with Capacitor Totem or Earthgrab Totem reduces the cooldown of the totem used by $/1000;s1 sec.; Cannot occur more than once every $457676d per totem.
    tidal_waves                 = { 81021, 51564 , 1 }, -- Casting Riptide grants 2 stacks of Tidal Waves. Tidal Waves reduces the cast time of your next Healing Wave or Chain Heal by $53390s1%, or increases the critical effect chance of your next Healing Surge by $53390s2%.
    tide_turner                 = { 92675, 404019, 1 }, -- The lowest health target of Healing Tide Totem is healed for $s1% more and receives $404072s1% increased healing from you for $404072d.
    tidebringer                 = { 81041, 236501, 1 }, -- Every $t4 sec, the cast time of your next Chain Heal is reduced by $236502m1%, and jump distance increased by $236502m2%. Maximum of $m2 charges.; 
    tidewaters                  = { 103434, 462424, 1 }, -- When you cast Healing Rain, each ally with your Riptide on them is healed for $462425s1.
    torrent                     = { 81047, 200072, 1 }, -- Riptide's initial heal is increased $s1% and has a $s2% increased critical strike chance.
    totemic_coordination        = { 94881, 445036, 1 }, -- $?a137041[Increases the critical strike chance of your Searing Totem's attacks by $s1%, and its critical strike damage by $s2%.][Chain Heals from your totems are $s3% more effective.]
    totemic_rebound             = { 94890, 445025, 1 }, -- $?a137041[Stormstrike has a chance to unleash a Surging Bolt at your Surging Totem, increasing the totem's damage by $458269s1%, and then redirecting the bolt to your target for $458267s1 Nature damage. The damage bonus effect can stack.][Chain Heal now jumps to a nearby totem within $458357A3 yards once it reaches its max targets, causing the totem to cast Chain Heal on an injured ally within $458357r yards for $458357s1. Jumps to $s1 nearby targets within $458357A3 yards.]
    undercurrent                = { 81052, 382194, 2 }, -- For each Riptide active on an ally, your heals are ${$s2/10}.1% more effective.
    undulation                  = { 81037, 200071, 1 }, -- Every third Healing Wave or Healing Surge heals for an additional $s1%.
    unleash_life                = { 81037, 73685 , 1 }, -- Unleash elemental forces of Life, healing a friendly target for $s1 and increasing the effect of your next healing spell.; Riptide, Healing Wave, or Healing Surge: $s2% increased healing.; Chain Heal: $s7% increased healing and bounces to $s4 additional $Ltarget:targets;.; $?a455630[][Healing Rain or ]Downpour: Affects $s5 additional targets.; Wellspring: $s6% of overhealing done is converted to an absorb effect.
    water_totem_mastery         = { 81018, 382030, 1 }, -- Consuming Tidal Waves has a chance to reduce the cooldown of your Healing Stream, Cloudburst, Healing Tide, Mana Tide, and Poison Cleansing totems by ${$s1/-1000}.1 sec.
    wavespeakers_blessing       = { 103427, 381946, 2 }, -- Increases the duration of Riptide by ${$s1/1000}.1 sec.
    wellspring                  = { 81051, 197995, 1 }, -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for $197997s1.
    whirling_elements           = { 94879, 445024, 1 }, -- [453409] $?a137041[Your next Stormstrike or Windstrike deals $s2% increased damage and damages $s3 nearby $Lenemy:enemies; at $s4% effectiveness.][The cast time of your next healing spell is reduced by $s1%.]; 
    white_water                 = { 81038, 462587, 1 }, -- Your critical heals have ${$s2+$s1}% effectiveness instead of the usual $s2%.
    wind_barrier                = { 94891, 445031, 1 }, -- If you have a totem active, your totem grants you a shield absorbing ${$mhp*$s1/100} damage for $457387d every $457390d.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5576, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by ${$s3-100}% for $d.; When the effect ends, enemies within $409304A1 yards are knocked in the air and take $<damage> Physical damage.
    counterstrike_totem = 708 , -- (204331) Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker. 
    electrocute         = 714 , -- (206642) When you successfully Purge a beneficial effect, the enemy suffers $206647o1 Nature damage over $206647d.
    grounding_totem     = 715 , -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within $8178A1 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts $d.
    living_tide         = 5388, -- (353115) Healing Tide Totem's cooldown is reduced by ${$s1/-1000} sec and it heals for $s2% more each time it pulses.
    rain_dance          = 3755, -- (290250) Healing Rain is now instant, $s2% more effective, and costs $s3% less mana. 
    static_field_totem  = 5567, -- (355580) Summons a totem with $s2% of your health at the target location for $d that forms a circuit of electricity that enemies cannot pass through.
    totem_of_wrath      = 707 , -- (460697) Primordial Wave summons a totem at your feet for $204330d that increases the critical effect of damage and healing spells of all nearby allies within $<radius> yards by $208963s1% for $208963d.; 
    unleash_shield      = 5437, -- (356736) Unleash your Elemental Shield's energy on an enemy target:; $@spellicon192106$@spellname192106: Knocks them away.; $@spellicon974$@spellname974: Roots them in place for $356738d.; $@spellicon52127$@spellname52127: Summons a whirlpool for $356739d, reducing damage and healing by $356824s1% while they stand within it.
} )

-- Auras
spec:RegisterAuras( {
    -- Damage and healing increased by $w1%.
    amplification_core = {
        id = 456369,
        duration = 20.0,
        max_stack = 1,
    },
    -- A percentage of healing and single target damage dealt is copied as healing to up to $s4 nearby injured party or raid members.
    ancestral_guidance = {
        id = 108281,
        duration = 10.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- restoration_shaman[137039] #29: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Health increased by $s1%.; If you die, the protection of the ancestors will allow you to return to life.
    ancestral_protection = {
        id = 207498,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.
    ancestral_swiftness = {
        id = 443454,
        duration = 3600,
        max_stack = 1,
    },
    -- Maximum health increased by $s1%.
    ancestral_vigor = {
        id = 207400,
        duration = 10.0,
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
        id = 2825,
        duration = 40.0,
        max_stack = 1,
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
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overflowing_shores[383222] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- surging_totem[455630] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- $?$w3!=0[Damage taken reduced by $w3%.; ][]Heals for ${$w2*(1+$w1/100)} upon taking damage.
    earth_shield = {
        id = 974,
        duration = 600.0,
        max_stack = 1,

        -- Affected by:
        -- earthen_communion[443441] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- earthen_communion[443441] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': ADDITIONAL_CHARGES, }
        -- earthen_harmony[382020] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- When a nearby ally takes damage, a portion is redirected to the Totem.
    earthen_wall = {
        id = 198839,
        duration = 3600,
        max_stack = 1,
    },
    -- Rooted.
    earthgrab = {
        id = 64695,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Riptide, Healing Wave, Healing Surge, and Chain Heal healing has a $s2% chance to trigger Earthliving on the target, healing an additional $382024s1 every $382024T for $382024d.
    earthliving_weapon = {
        id = 382022,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    echoing_shock = {
        id = 320125,
        duration = 8.0,
        max_stack = 1,
    },
    -- $w1 Nature damage every $t1 sec.
    electrocute = {
        id = 206647,
        duration = 3.0,
        tick_time = 1.0,
        pandemic = true,
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
    -- Suffering $w2 Volcanic damage every $t2 sec.
    flame_shock = {
        id = 188389,
        duration = 18.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- restoration_shaman[137039] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- supportive_imbuements[445033] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- supportive_imbuements[445033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Movement speed reduced by $s2%.
    frost_shock = {
        id = 196840,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- encasing_cold[462762] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- encasing_cold[462762] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 27.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Increases movement speed by $?s382215[${$382216s1+$w2}][$w2]%.$?$w3!=0[; Less hindered by effects that reduce movement speed.][]
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Healing $/5;s2% every $t1 seconds.
    gift_of_the_naaru = {
        id = 59547,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Will redirect harmful spells to the Grounding Totem.
    grounding_totem = {
        id = 8178,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Your Healing Rain is currently active.; $?$w1!=0[Magic damage taken reduced by $w1%.][]
    healing_rain = {
        id = 73920,
        duration = 10.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- overflowing_shores[383222] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- rain_dance[290250] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- rain_dance[290250] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -45.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- overflowing_shores[278077] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Haste increased by $w1%.
    heroism = {
        id = 32182,
        duration = 40.0,
        max_stack = 1,
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
    -- Chain Heal heals for an additional $s1% and is not reduced with each jump.
    high_tide = {
        id = 288675,
        duration = 25.0,
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
    },
    -- Chance to deal $192109s1 Nature damage when you take melee damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].
    lightning_shield = {
        id = 192106,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- surging_shields[382033] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- surging_shields[382033] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- surging_shields[382033] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Searing Totem is hurling Searing Bolts at nearby enemies.
    lively_totems = {
        id = 461242,
        duration = 8.0,
        max_stack = 1,
    },
    -- Mana generation rate increased by $w1%.
    mana_tide_totem = {
        id = 320763,
        duration = 10.0,
        max_stack = 1,
    },
    -- The healing of your next Healing Surge is increased by $w1%.
    master_of_the_elements = {
        id = 462377,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        max_stack = 1,
    },
    -- Heals $w1 damage.
    overflowing_shores = {
        id = 278095,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Heals $w1 damage every $t1 seconds.
    pack_spirit = {
        id = 280205,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Cleansing all Poison effects from a nearby party or raid member within $a yards every $t1 sec.
    poison_cleansing = {
        id = 403922,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- restoration_shaman[137039] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- elemental_shaman[137040] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Heals $w2 every $t2 seconds.
    riptide = {
        id = 61295,
        duration = 18.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- echo_of_the_elements[333919] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- elemental_reverb[443418] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_reverb[443418] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_reverb[443418] #4: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- torrent[200072] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wavespeakers_blessing[381946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
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
    -- Heals $w1 damage.
    serene_spirit = {
        id = 274416,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Mastery increased by $w1% and auto attacks have a $h% chance to instantly strike again.
    skyfury = {
        id = 462854,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Heal for $w1.
    soothing_waters = {
        id = 273019,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Damage taken reduced by $s1%.; Health periodically normalized among other affected party and raid members.
    spirit_link_totem = {
        id = 98007,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spouting_spirits[462383] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- spouting_spirits[279504] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
    -- Healing Surge's cast time is reduced by $w1% and its mana cost is reduced by $w2%.
    spiritwalkers_tidal_totem = {
        id = 404523,
        duration = 30.0,
        max_stack = 1,
    },
    -- Stunned.
    static_charge = {
        id = 118905,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Absorbing up to $w1 damage.
    stone_bulwark = {
        id = 462844,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Your next Lightning Bolt or Chain Lightning will be instant and deal $w1% additional damage.
    stormkeeper = {
        id = 205495,
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
    },
    -- Receiving $422915s1% of all Riptide healing $@auracaster deals.
    tidal_reservoir = {
        id = 424461,
        duration = 15.0,
        max_stack = 1,
    },
    -- Cast time of next Healing Wave or Chain Heal reduced by $w1%.; Critical effect chance of next Healing Surge increased by $w2%.
    tidal_waves = {
        id = 53390,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- primordial_capacity[443448] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Healing received from $@auracaster increased by $s1%.
    tide_turner = {
        id = 404072,
        duration = 4.0,
        max_stack = 1,
    },
    -- The cast time of your next Chain Heal reduced by $w1% and its jump distance is increased by $w2%.
    tidebringer = {
        id = 236502,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Your healing done is increased by $w2%.; $?a157153[Cloudburst][Healing Stream] Totem lasts an additional ${$w1/1000} sec.
    tidecallers_guard = {
        id = 457496,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- enhanced_imbues[462796] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- enhanced_imbues[462796] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- enhanced_imbues[462796] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Healing and spell critical effect increased by $w1%.
    totem_of_wrath = {
        id = 208963,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next healing spell has increased effectiveness.
    unleash_life = {
        id = 73685,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_fury[381655] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- The cast time of Lightning Bolt and Chain Lightning is reduced by $w1%.
    volcanic_surge = {
        id = 408575,
        duration = 18.0,
        max_stack = 1,

        -- Affected by:
        -- restoration_shaman[137039] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Grants $w2 mana per 5 sec.; Melee attacks against you trigger additional mana restoration.
    water_shield = {
        id = 52127,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Allows walking over water.
    water_walking = {
        id = 546,
        duration = 600.0,
        max_stack = 1,
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

    -- Summons a totem at the target location for $d. All allies within $?s382201[${$207495s1*(1+$382201s3/100)}][$207495s1] yards of the totem gain $207498s1% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with $207553s1% health and mana.; Cannot reincarnate an ally who dies to massive damage.
    ancestral_protection_totem = {
        id = 207399,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        spend = 0.022,
        spendType = 'mana',

        talent = "ancestral_protection_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 10.0, 'value': 104818, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'value1': 3787, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- Returns all dead party members to life with $s1% of maximum health and mana.  Cannot be cast when in combat.
    ancestral_vision = {
        id = 212048,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT_WITH_AURA, 'subtype': NONE, 'points': 35.0, 'radius': 100.0, 'target': TARGET_CORPSE_SRC_AREA_RAID, }
    },

    -- Transform into a Water Ascendant, duplicating all healing you deal at $s4% effectiveness for $114051d and immediately healing for $294020s1. Ascendant healing is distributed evenly among allies within $114083A1 yds.
    ascendance = {
        id = 114052,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "ascendance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 59349, 'schools': ['physical', 'fire', 'frost', 'arcane'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 294020, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 70.0, 'target': TARGET_UNIT_CASTER, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- natures_swiftness[378081] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- ancestral_reach[382732] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- ancestral_reach[382732] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- ancestral_swiftness[443454] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flow_of_the_tides[382039] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unleash_life[73685] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- unleash_life[73685] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidebringer[236502] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- tidebringer[236502] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_DISTANCE, }
        -- elemental_shaman[137040] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- high_tide[288675] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- high_tide[288675] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_20, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidal_waves[53390] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- tidal_waves[53390] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidal_waves[53390] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
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
        -- restoration_shaman[137039] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 235.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- volcanic_surge[408572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- elemental_shaman[137040] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 67.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- volcanic_surge[408575] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- [51886] Removes all Curse effects from a friendly target.
    cleanse_spirit = {
        id = 440012,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a totem at your feet for $d that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within $157503A1 yards for $157503s2% of all healing done while it was active, divided evenly among targets.; Casting this spell a second time recalls the totem and releases the healing.
    cloudburst_totem = {
        id = 157153,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        spend = 0.017,
        spendType = 'mana',

        talent = "cloudburst_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 78001, 'schools': ['physical', 'frost', 'shadow'], 'value1': 3402, 'target': TARGET_DEST_CASTER_BACK_RIGHT, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- tidecallers_guard[457496] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- earthen_harmony[382020] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Summons a totem at the target location with ${$m2*$MHP/100} health for $d. ${$m3*$SP/100} damage from each attack against allies within $?s382201[${$198839s1*(1+$382201s3/100)}.1][$198839s1] yards of the totem is redirected to the totem.
    earthen_wall_totem = {
        id = 198838,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.022,
        spendType = 'mana',

        talent = "earthen_wall_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 60.0, 'value': 100943, 'schools': ['physical', 'holy', 'fire', 'nature', 'arcane'], 'value1': 3737, 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Imbue your weapon with the element of Earth for $382022d. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a $382022s2% chance to trigger Earthliving on the target, healing for $382024o1 over $382024d.
    earthliving_weapon = {
        id = 382021,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "earthliving_weapon",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
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
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
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
        -- restoration_shaman[137039] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- supportive_imbuements[445033] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- supportive_imbuements[445033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- encasing_cold[462762] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- encasing_cold[462762] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 27.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- [28880] Heals the target for $s2% of the caster's total health over $d.
    gift_of_the_naaru = {
        id = 59547,
        color = 'racial',
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
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

    -- Blanket the target area in healing rains, restoring ${$73921m1*6*2/$t2} health to up to $s4 allies over $d.
    healing_rain = {
        id = 73920,
        cast = 2.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 0.043,
        spendType = 'mana',

        talent = "healing_rain",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 11.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'points': 6.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 14.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- overflowing_shores[383222] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- rain_dance[290250] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- rain_dance[290250] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -45.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- overflowing_shores[278077] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- tidecallers_guard[457496] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- unleash_life[73685] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- master_of_the_elements[462377] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spiritwalkers_tidal_totem[404523] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- spiritwalkers_tidal_totem[404523] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- elemental_shaman[137040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidal_waves[53390] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- tidal_waves[53390] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidal_waves[53390] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidal_waves[53390] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Summons a totem at your feet for $d, which pulses every $t2 sec, healing all party or raid members within $114942A1 yards for $114942m1.; Healing reduced beyond $s1 targets.
    healing_tide_totem = {
        id = 108280,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        spend = 0.011,
        spendType = 'mana',

        talent = "healing_tide_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 59764, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'value1': 5204, 'target': TARGET_DEST_CASTER_BACK_RIGHT, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- current_control[404015] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- living_tide[353115] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- An efficient wave of healing energy that restores $s1 of a friendly targetâ€™s health.
    healing_wave = {
        id = 77472,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "healing_wave",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 5.46, 'chain_amp': 0.2, 'pvp_multiplier': 1.2, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_CHAINHEAL_ALLY, }

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unleash_life[73685] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidal_waves[53390] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- tidal_waves[53390] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidal_waves[53390] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidal_waves[53390] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
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
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 128.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- echo_of_the_elements[333919] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- elemental_reverb[443418] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- elemental_reverb[443418] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- volcanic_surge[408572] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 45.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- maelstrom[343725] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 29.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- restoration_shaman[137039] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.75, 'points': 145.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lightning_bolt[318044] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- volcanic_surge[408572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 57.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- volcanic_surge[408575] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
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
        -- surging_shields[382033] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- surging_shields[382033] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- surging_shields[382033] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Summons a totem at your feet for $d, granting $320763s1% increased mana regeneration to allies within $<radius> yards.
    mana_tide_totem = {
        id = 16191,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "mana_tide_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 5.0, 'value': 10467, 'schools': ['physical', 'holy', 'shadow', 'arcane'], 'value1': 4841, 'target': TARGET_DEST_CASTER_BACK_RIGHT, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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

    -- Blast your target with a Primordial Wave, healing them for $375985s1 and applying Riptide to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave = {
        id = 428332,
        color = 'shadowlands',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "primordial_wave",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 375983, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 0.5, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
    },

    -- Blast your target with a Primordial Wave, dealing $375984s1 Elemental damage and applying Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave_375982 = {
        id = 375982,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 375983, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 0.42857, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        from = "pvp_talent_requires",
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

    -- Removes all Magic$?s383016[ and Curse][] effects from a friendly target.
    purify_spirit = {
        id = 77130,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.013,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_TARGET_ALLY, }

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

    -- Restorative waters wash over a friendly target, healing them for $s1 and an additional $o2 over $d.
    riptide = {
        id = 61295,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        talent = "riptide",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 2.652, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 3.0, 'sp_bonus': 0.22, 'pvp_multiplier': 1.21, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- echo_of_the_elements[333919] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- elemental_reverb[443418] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_reverb[443418] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_reverb[443418] #4: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- torrent[200072] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wavespeakers_blessing[381946] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
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

    -- Summons a totem at the target location for $d, which reduces damage taken by all party and raid members within $98007a1 yards by $98007s1%. Immediately and every $98017t1 sec, the health of all affected players is redistributed evenly.
    spirit_link_totem = {
        id = 98008,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.022,
        spendType = 'mana',

        talent = "spirit_link_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 2.0, 'value': 53006, 'schools': ['holy', 'fire', 'nature'], 'value1': 3399, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spouting_spirits[279504] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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

    -- $?a137039[Summons a totem at the target location that maintains Healing Rain for $d. Heals for $455630s3% more than a normal Healing Rain.; Replaces Healing Rain.][Summons a totem at the target location that creates a Tremor immediately and every $455593t1 sec for $455622s1 Physical damage. Damage reduced beyond $455622s2 targets. Lasts $d.]
    surging_totem = {
        id = 444995,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.004,
        spendType = 'mana',

        spend = 0.086,
        spendType = 'mana',

        talent = "surging_totem",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 225409, 'schools': ['physical'], 'value1': 5967, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ancestral_wolf_affinity[382197] #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, }
        -- totemic_surge[381867] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- thundershock[378779] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- traveling_storms[204403] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 204406, 'target': TARGET_UNIT_CASTER, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        from = "from_description",
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

    -- Unleash elemental forces of Life, healing a friendly target for $s1 and increasing the effect of your next healing spell.; Riptide, Healing Wave, or Healing Surge: $s2% increased healing.; Chain Heal: $s7% increased healing and bounces to $s4 additional $Ltarget:targets;.; $?a455630[][Healing Rain or ]Downpour: Affects $s5 additional targets.; Wellspring: $s6% of overhealing done is converted to an absorb effect.
    unleash_life = {
        id = 73685,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        talent = "unleash_life",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.192, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- mastery_deep_healing[77226] #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'sp_bonus': 3.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_fury[381655] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tide_turner[404072] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 15.0, 'target': TARGET_UNIT_TARGET_ALLY, }
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

    -- The caster is surrounded by globes of water, granting $s2 mana per 5 sec. When a melee attack hits the caster, the caster regains $?s382033[${($382033s5/100+1)*$52128s1}][$52128s1]% of their mana. This effect can only occur once every few seconds. ; $?s383010[The Shaman can have up to two Elemental Shields active on them.][Only one of your Elemental Shields can be active on you at once.]
    water_shield = {
        id = 52127,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'sp_bonus': 0.25, 'trigger_spell': 52128, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_POWER_REGEN, 'pvp_multiplier': 1.75, 'coefficient': 0.52631575, 'scaling_class': -1, 'target': TARGET_UNIT_CASTER, }
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

    -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for $197997s1.
    wellspring = {
        id = 197995,
        cast = 1.5,
        cooldown = 20.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "wellspring",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_UNIT_CONE_ALLY, }

        -- Affected by:
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancestral_swiftness[443454] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ancestral_swiftness[443454] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- maelstrom_supremacy[443447] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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