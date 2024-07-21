-- ShamanEnhancement.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 263 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Maelstrom )

spec:RegisterTalents( {
    -- Shaman Talents
    ancestral_guidance        = { 103810, 108281, 1 }, -- For the next $d, $s1% of your healing done and $s2% of your damage done is converted to healing on up to $s4 nearby injured party or raid members, up to ${$MHP*$s3/100} healing to each target per second.
    ancestral_wolf_affinity   = { 103610, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    arctic_snowstorm          = { 103619, 462764, 1 }, -- Enemies within $s1 yds of your Frost Shock are snared by $462765s1%.
    ascending_air             = { 103607, 462791, 1 }, -- Wind Rush Totem's cooldown is reduced by ${$s1/-1000} sec and its movement speed effect lasts an additional ${$s2/1000} sec.
    astral_bulwark            = { 103611, 377933, 1 }, -- Astral Shift reduces damage taken by an additional $s1%.
    astral_shift              = { 103616, 108271, 1 }, -- Shift partially into the elemental planes, taking $s1% less damage for $d.
    brimming_with_life        = { 103582, 381689, 1 }, -- Maximum health increased by $s1%, and while you are at full health, Reincarnation cools down $381684s1% faster.; 
    call_of_the_elements      = { 103592, 383011, 1 }, -- Reduces the cooldown of $@spellname108285 by ${$s1/-1000} sec.
    capacitor_totem           = { 103579, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    chain_heal                = { 103588, 1064  , 1 }, -- Heals the friendly target for $s1, then jumps up to $?a236502[${$s3*(($236502s2/100)+1)}][$s3] yards to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_lightning           = { 103583, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing $s1 Nature damage and then jumping to additional nearby enemies. Affects $x1 total targets.$?s187874[; If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by $333964s1%.][]$?s187874[; Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by ${$s3/1000}.1 sec.][]$?a343725[; Generates $343725s5 Maelstrom per target hit.][]
    creation_core             = { 103592, 383012, 1 }, -- $@spellname108285 affects an additional totem.
    earth_elemental           = { 103585, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.; While this elemental is active, your maximum health is increased by $381755s1%.
    earth_shield              = { 103596, 974   , 1 }, -- Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $u charges.; $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earthgrab_totem           = { 103617, 51485 , 1 }, -- Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    elemental_orbit           = { 103602, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1.; You can have Earth Shield on yourself and one ally at the same time.
    elemental_resistance      = { 103601, 462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by $462568s1% for $462568d.$?c3[; Healing from Cloudburst Totem reduces Fire, Frost, and Nature damage taken by $462369s1% for $462369d.][]
    elemental_warding         = { 103597, 381650, 1 }, -- Reduces all magic damage taken by $s1%.
    encasing_cold             = { 103619, 462762, 1 }, -- Frost Shock snares its targets by an additional $s1% and its duration is increased by ${$s2/1000} sec.
    enhanced_imbues           = { 103606, 462796, 1 }, -- The effects of your weapon imbues are increased by $?c1[$s1]?c2[$s2]?c3[$s3][]%.
    fire_and_ice              = { 103605, 382886, 1 }, -- Increases all Fire and Frost damage you deal by $s1%.
    frost_shock               = { 103604, 196840, 1 }, -- Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    graceful_spirit           = { 103626, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by ${$m1/-1000} sec and increases your movement speed by $s2% while it is active.
    greater_purge             = { 103624, 378773, 1 }, -- Purges the enemy target, removing $m1 beneficial Magic effects.
    guardians_cudgel          = { 103618, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind              = { 103591, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem      = { 103590, 5394  , 1 }, -- $@spelltooltip5394
    hex                       = { 103623, 51514 , 1 }, -- Transforms the enemy into a frog for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    jet_stream                = { 103607, 462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by $s1% and now removes snares.
    lava_burst                = { 103598, 51505 , 1 }, -- Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[; Generates $343725s3 Maelstrom.][]
    lightning_lasso           = { 103589, 305483, 1 }, -- Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    mana_spring               = { 103587, 381930, 1 }, -- Your $?!s137041[Lava Burst][]$?s137039[ and Riptide][]$?s137041[Stormstrike][] casts restore $?a137040[$381931s1]?a137041[$404550s1][$404551s1] mana to you and $s1 allies nearest to you within $395192a1 yards.; Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury              = { 103622, 381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by $s1%.
    natures_guardian          = { 103613, 30884 , 1 }, -- When your health is brought below $s1%, you instantly heal for ${$31616s1*(1+$s2/100)}% of your maximum health. Cannot occur more than once every $445698d.
    natures_swiftness         = { 103620, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    planes_traveler           = { 103611, 381647, 1 }, -- Reduces the cooldown of Astral Shift by ${$s1/-1000} sec.
    poison_cleansing_totem    = { 103609, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within $403922a yards every $383014t1 sec for $d.
    primordial_bond           = { 103612, 381764, 1 }, -- [381761] While you have an elemental active, your damage taken is reduced by $s1%.
    purge                     = { 103624, 370   , 1 }, -- Purges the enemy target, removing $m1 beneficial Magic $leffect:effects;.$?(s147762&s51530); [ Successfully purging a target grants a stack of Maelstrom Weapon.][]
    refreshing_waters         = { 103594, 378211, 1 }, -- Your Healing Surge is $s1% more effective on yourself.; 
    seasoned_winds            = { 103628, 355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by $s1% for $355634d. Stacks up to $355634U times.
    spirit_walk               = { 103591, 58875 , 1 }, -- Removes all movement impairing effects and increases your movement speed by $58875s1% for $58875d.
    spirit_wolf               = { 103581, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain $260881s1% increased movement speed and $260881s2% damage reduction every $260882t1 sec, stacking up to $260881u times.
    spiritwalkers_aegis       = { 103626, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for $378078d.
    spiritwalkers_grace       = { 103584, 79206 , 1 }, -- Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    static_charge             = { 103618, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by $s1 sec for each enemy it stuns, up to a maximum reduction of $s2 sec.
    stone_bulwark_totem       = { 103629, 108270, 1 }, -- Summons a totem with ${$m1*$MHP/100} health at the feet of the caster for $d, granting the caster a shield absorbing $114893s1 damage for $114893d, and up to an additional $462844s1 every $114889t1 sec.
    thunderous_paws           = { 103581, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional $s1% for the first $338036d. May only occur once every $proccooldown sec.
    thundershock              = { 103621, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by ${$s1/-1000} sec.
    thunderstorm              = { 103603, 51490 , 1 }, -- Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    totemic_focus             = { 103625, 382201, 1 }, -- Increases the radius of your totem effects by $s3%.; Increases the duration of your Earthbind and Earthgrab Totems by ${$s1/1000} sec.; Increases the duration of your $?s157153[Cloudburst][Healing Stream], Tremor, Poison Cleansing, $?s137039[Ancestral Protection, Earthen Wall, ][]and Wind Rush Totems by ${$s2/1000}.1 sec.
    totemic_projection        = { 103586, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall            = { 103595, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge             = { 103599, 381867, 1 }, -- Reduces the cooldown of your totems by ${$s1/-1000} sec.
    traveling_storms          = { 103621, 204403, 1 }, -- Thunderstorm now can be cast on allies within $204406r yards, reduces enemies movement speed by $204408s3%, and knocks enemies $s2% further.
    tremor_totem              = { 103593, 8143  , 1 }, -- Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    voodoo_mastery            = { 103600, 204268, 1 }, -- Your Hex target is slowed by $378080s1% during Hex and for $378080d after it ends.; Reduces the cooldown of Hex by ${($m1/1000)*-1} sec.
    wind_rush_totem           = { 103627, 192077, 1 }, -- Summons a totem at the target location for $d, continually granting all allies who pass within $a1 yards $192082s1% increased movement speed for $192082d.
    wind_shear                = { 103615, 57994 , 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    winds_of_alakir           = { 103614, 382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by $s3%.; When you have $s4 or more totems active, your movement speed is increased by $s2%.

    -- Enhancement Talents
    alpha_wolf                = { 80970, 198434, 1 }, -- While Feral Spirits are active, Chain Lightning and Crash Lightning causes your wolves to attack all nearby enemies for $<damage> Physical damage every $198486t1 sec for the next $198486d.
    amplification_core        = { 94874, 445029, 1 }, -- While Surging Totem is active, your damage and healing done is increased by $456369s1%.
    arc_discharge             = { 94885, 455096, 1 }, -- When Tempest strikes more than one target, your next $455097u Chain Lightning spells are instant cast and deal $455097s2% increased damage.
    ascendance                = { 92219, 114051, 1 }, -- Transform into an Air Ascendant for $114051d, immediately dealing $344548s1 Nature damage to any enemy within $344548A1 yds, reducing the cooldown and cost of Stormstrike by $s4%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a $114089r yd range.$?s384411[; While Ascendance is active, generate $s1 Maelstrom Weapon $lstack:stacks; every $384437t1 sec.][]
    ashen_catalyst            = { 80947, 390370, 1 }, -- Each time Flame Shock deals periodic damage, increase the damage of your next Lava Lash by $390371s1% and reduce the cooldown of Lava Lash by ${$m1/10}.1 sec.
    awakening_storms          = { 94867, 455129, 1 }, -- $?s137041[Stormstrike, ][]Lightning Bolt$?s137041[,][] and Chain Lightning have a chance to strike your target for $455130s1 Nature damage. Every $s2 times this occurs, your next Lightning Bolt is replaced by Tempest.
    cleanse_spirit            = { 103608, 51886 , 1 }, -- Removes all Curse effects from a friendly target.
    conductive_energy         = { 94868, 455123, 1 }, -- [210689] $?s454009[Tempest, ][]$?s137040[Earth Shock, Elemental Blast, and Earthquake][Lightning Bolt, Elemental Blast, and Chain Lightning] make your target a Lightning Rod for $197209d. Lightning Rods take $s2% of all damage you deal with Lightning Bolt and Chain Lightning.
    converging_storms         = { 80973, 384363, 1 }, -- Each target hit by Crash Lightning increases the damage of your next Stormstrike by $198300s1%, up to a maximum of $198300u stacks.
    crash_lightning           = { 80974, 187874, 1 }, -- Electrocutes all enemies in front of you, dealing ${$s1*$<CAP>/$AP} Nature damage. Hitting 2 or more targets enhances your weapons for $187878d, causing Stormstrike, Ice Strike, and Lava Lash to also deal ${$195592s1*$<CAP>/$AP} Nature damage to all targets in front of you. Damage reduced beyond $s2 targets.$?s384363[; Each target hit by Crash Lightning increases the damage of your next Stormstrike by $198300s1%, up to a maximum of $198300u stacks.][]
    crashing_storms           = { 80953, 334308, 1 }, -- Crash Lightning damage increased by $s1%.; Chain Lightning now jumps to $s2 extra targets.
    deeply_rooted_elements    = { 92219, 378270, 1 }, -- [114052] Transform into a Water Ascendant, duplicating all healing you deal at $s4% effectiveness for $114051d and immediately healing for $294020s1. Ascendant healing is distributed evenly among allies within $114083A1 yds.
    doom_winds                = { 80959, 384352, 1 }, -- Strike your target for $s3 Physical damage, increase your chance to activate Windfury Weapon by $s1%, and increases damage dealt by Windfury Weapon by $s2% for $d.; 
    earthsurge                = { 94881, 455590, 1 }, -- $?a137041[Casting Sundering within 40 yards of your Surging Totem causes it to create a Tremor at 200% effectiveness at the target area.][Allies affected by your Earthen Wall Totem, Ancestral Protection Totem, and Earthliving effect receive 10% increased healing from you.]
    elemental_assault         = { 80962, 210853, 2 }, -- Stormstrike damage is increased by $s1%, and Stormstrike, Lava Lash, and Ice Strike have a $m3% chance to generate $m2 $Lstack:stacks; of Maelstrom Weapon.
    elemental_blast           = { 80966, 117014, 1 }, -- [117014] Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[; If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_spirits         = { 80970, 262624, 1 }, -- Your Feral Spirits are now imbued with Fire, Frost, or Lightning, increasing your damage dealt with that element by $224127s1%.
    elemental_weapons         = { 80961, 384355, 2 }, -- Each active weapon imbue Increases all Fire, Frost, and Nature damage dealt by ${$s1/10}.1%.
    feral_spirit              = { 80972, 51533 , 1 }, -- Summons two $?s262624[Elemental ][]Spirit $?s147783[Raptors][Wolves] that aid you in battle for $228562d. They are immune to movement-impairing effects, and each $?s262624[Elemental ][]Feral Spirit summoned grants you $?s262624[$224125s1%][$392375s1%] increased $?s262624[Fire, Frost, or Nature][Physical] damage dealt by your abilities.; Feral Spirit generates one stack of Maelstrom Weapon immediately, and one stack every $333957t1 sec for $333957d.
    fire_nova                 = { 80944, 333974, 1 }, -- Erupt a burst of fiery damage from all targets affected by your Flame Shock, dealing $333977s1 Flamestrike damage to up to $333977I targets within $333977A1 yds of your Flame Shock targets.$?s384359[; Each eruption from Fire Nova generates $384359s1 $Lstack:stacks; of Maelstrom Weapon.][]
    flurry                    = { 103642, 382888, 1 }, -- Increases your attack speed by $382889s1% for your next $382889n melee swings after dealing a critical strike with a spell or ability.
    forceful_winds            = { 80969, 262647, 1 }, -- Windfury causes each successive Windfury attack within $262652d to increase the damage of Windfury by $262652s1%, stacking up to $262652u times.
    hailstorm                 = { 80944, 334195, 1 }, -- Each stack of Maelstrom Weapon consumed increases the damage of your next Frost Shock by $334196s1%, and causes your next Frost Shock to hit $334196m2 additional target per Maelstrom Weapon stack consumed, up to $s1.$?s384359[; Consuming at least $384359s2 $Lstack:stacks; of Hailstorm generates $384359s1 $Lstack:stacks; of Maelstrom Weapon.][]
    hot_hand                  = { 80945, 201900, 2 }, -- Melee auto-attacks with Flametongue Weapon active have a $h% chance to reduce the cooldown of Lava Lash by ${100*(1-(100/(100+$m2)))}% and increase the damage of Lava Lash by $s3% for $215785d.
    ice_strike                = { 80956, 342240, 1 }, -- Strike your target with an icy blade, dealing $s1 Frost damage and snaring them by $s2% for $d.; Ice Strike increases the damage of your next Frost Shock by $384357s1%$?s384359[ and generates $384359s1 $Lstack:stacks; of Maelstrom Weapon][].
    imbuement_mastery         = { 94871, 445028, 1 }, -- $?a137041[Increases the chance for Windfury Weapon to trigger by $s1% and increases its damage by $s2%.][Increases the duration of your  Earthliving effect by ${$s3/1000} sec.]; 
    improved_maelstrom_weapon = { 80957, 383303, 1 }, -- Maelstrom Weapon now increases the damage of spells it affects by $s1% per stack and the healing of spells it affects by $s2% per stack.
    lashing_flames            = { 80948, 334046, 1 }, -- Lava Lash increases the damage of Flame Shock on its target by $334168s1% for $334168d.
    lava_lash                 = { 80942, 60103 , 1 }, -- Charges your off-hand weapon with lava and burns your target, dealing $s1 Fire damage.; Damage is increased by $s2% if your offhand weapon is imbued with Flametongue Weapon. $?s334033[Lava Lash will spread Flame Shock from your target to $s3 nearby targets.][]$?s334046[; Lava Lash increases the damage of Flame Shock on its target by $334168s1% for $334168d.][]
    legacy_of_the_frost_witch = { 80951, 384450, 2 }, -- Consuming $s2 stacks of Maelstrom Weapon will reset the cooldown of Stormstrike and increases the damage of your Physical and Frost abilities by $s1% for $384451d.
    lively_totems             = { 94882, 445034, 1 }, -- $?a137041[Lava Lash has a chance to summon a Searing Totem to hurl Searing Bolts that deal $3606s1 Fire damage to a nearby enemy. Lasts $458101d.][Your Healing Tide Totem, Healing Stream Totem, Cloudburst Totem, Mana Tide Totem, and Spirit Link Totem cast a free, instant Chain Heal at $458221s2% effectiveness when you summon them.]
    molten_assault            = { 80943, 334033, 1 }, -- Lava Lash cooldown reduced by ${$m1/-1000}.1 sec, and if Lava Lash is used against a target affected by your Flame Shock, Flame Shock will be spread to up to $s2 enemies near the target.
    natures_protection        = { 94880, 454027, 1 }, -- Targets struck by your Tempest deal $454029s1% less damage to you for $454029d.
    overflowing_maelstrom     = { 80938, 384149, 1 }, -- Your damage or healing spells will now consume up to $s1 Maelstrom Weapon stacks. 
    oversized_totems          = { 94859, 445026, 1 }, -- Increases the size and radius of your totems by $458016s2%, and the health of your totems by $458016s1%.
    oversurge                 = { 94874, 445030, 1 }, -- While Ascendance is active, Surging Totem is $s1% more effective.
    primal_maelstrom          = { 80964, 384405, 2 }, -- Primordial Wave generates $s1 stacks of Maelstrom Weapon.
    primordial_wave           = { 80965, 375982, 1 }, -- Blast your target with a Primordial Wave, dealing $375984s1 Elemental damage and applying Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    pulse_capacitor           = { 94866, 445032, 1 }, -- $?a137041[Increases the damage of Surging Totem by $s1%.][Increases the healing done by Surging Totem by $s2%.]
    raging_maelstrom          = { 80939, 384143, 1 }, -- Maelstrom Weapon can now stack $s1 additional times, and Maelstrom Weapon now increases the damage of spells it affects by an additional $s2% per stack and the healing of spells it affects by an additional $s3% per stack.
    reactivity                = { 94872, 445035, 1 }, -- $?a137041[Frost Shocks empowered by Hailstorm, Lava Lash, and Fire Nova cause your Searing totems to shoot a Searing Volley at up to $s1 nearby enemies for $458147s1 Fire damage.][Your Healing Stream Totems now also heals a second ally at $s3% effectiveness. ; Cloudburst Totem stores $s2% additional healing.]
    rolling_thunder           = { 94889, 454026, 1 }, -- $?s137040[Gain one stack of Stormkeeper every $s1 sec][Tempest summons a Nature Feral Spirit for $426516d].
    shocking_grasp            = { 94863, 454022, 1 }, -- Your Nature damage critical strikes reduce the target's movement speed by $454025s1% for $454025d.
    splintered_elements       = { 80963, 382042, 1 }, -- Primordial Wave grants you $s1% Haste plus $s2% for each additional $?a137039[Healing Wave]?a137040[Lava Burst][Lightning Bolt] generated by Primordial Wave for $382043d.
    static_accumulation       = { 80950, 384411, 2 }, -- $s2% chance to refund Maelstrom Weapon stacks spent on Lightning Bolt or Chain Lightning.; While Ascendance is active, generate $s1 Maelstrom Weapon $lstack:stacks; every $384437t1 sec.
    storm_swell               = { 94885, 455088, 1 }, -- When Tempest only strikes a single target, gain $?s137040[$455089s1 Maelstrom][$s1 stacks of Maelstrom Weapon].
    stormblast                = { 80960, 319930, 1 }, -- Stormbringer now also causes your next Stormstrike to deal $s1% additional damage as Nature damage.
    stormcaller               = { 94893, 454021, 1 }, -- Increases the critical strike chance of your Nature damage spells by $s1% and the critical strike damage of your Nature spells by $s2%.
    stormflurry               = { 80954, 344357, 1 }, -- Stormstrike has a $s1% chance to strike the target an additional time for $s2% of normal damage. This effect can chain off of itself.
    storms_wrath              = { 80967, 392352, 1 }, -- Increase the chance for Mastery: Enhanced Elements to trigger Windfury and Stormbringer by $s1%. 
    stormstrike               = { 80941, 17364 , 1 }, -- Energizes both your weapons with lightning and delivers a massive blow to your target, dealing a total of ${$32175sw1+$32176sw1} Physical damage.$?s210853[; Stormstrike has a $s4% chance to generate $210853m2 $Lstack:stacks; of Maelstrom Weapon.][]
    sundering                 = { 80975, 197214, 1 }, -- Shatters a line of earth in front of you with your main hand weapon, causing $s1 Flamestrike damage and Incapacitating any enemy hit for $d.
    supercharge               = { 94873, 455110, 1 }, -- $?s137040[Lightning Bolt and Chain Lightning Elemental Overloads have a $s1% chance to cause an additional Elemental Overload.][Lightning Bolt and Chain Lightning have a $s2% chance to refund $s3 Maelstrom Weapon stacks.]
    supportive_imbuements     = { 94866, 445033, 1 }, -- [457481] Imbue your shield with the element of Water for $457496d. Your healing done is increased by $457496s2% and the duration of your Healing Stream Totem and Cloudburst Totem is increased by ${$457496s1/1000} sec.
    surging_currents          = { 94880, 454372, 1 }, -- After using Tempest, your next Chain Heal, or Healing Surge will be instant cast and consume no Mana.
    surging_totem             = { 94877, 444995, 1 }, -- Description not found.
    swift_recall              = { 94859, 445027, 1 }, -- Successfully removing a harmful effect with Tremor Totem or Poison Cleansing Totem, or controlling an enemy with Capacitor Totem or Earthgrab Totem reduces the cooldown of the totem used by $/1000;s1 sec.; Cannot occur more than once every $457676d per totem.
    swirling_maelstrom        = { 80955, 384359, 1 }, -- Consuming at least $s2 $Lstack:stacks; of Hailstorm, using Ice Strike, and each explosion from Fire Nova now also grants you $s1 $lstack:stacks; of Maelstrom Weapon.
    tempest                   = { 94892, 454009, 1 }, -- Every $?s137040[$s1][$s2] $?s137040[Maelstrom][Maelstrom Weapon stacks] spent replaces your next Lightning Bolt with Tempest.; $@spelltooltip452201
    tempest_strikes           = { 80966, 428071, 1 }, -- Stormstrike, Ice Strike, and Lava Lash have a $h% chance to discharge electricity at your target, dealing $428078s1 Nature damage.
    thorims_invocation        = { 80949, 384444, 1 }, -- Lightning Bolt and Chain Lightning damage increased by $s2%.; While Ascendance is active, Windstrike automatically consumes up to $s1 Maelstrom Weapon stacks to discharge a Lightning Bolt or Chain Lightning at $s3% effectiveness at your enemy, whichever you most recently used.
    totemic_coordination      = { 94881, 445036, 1 }, -- $?a137041[Increases the critical strike chance of your Searing Totem's attacks by $s1%, and its critical strike damage by $s2%.][Chain Heals from your totems are $s3% more effective.]
    totemic_rebound           = { 94890, 445025, 1 }, -- $?a137041[Stormstrike has a chance to unleash a Surging Bolt at your Surging Totem, increasing the totem's damage by $458269s1%, and then redirecting the bolt to your target for $458267s1 Nature damage. The damage bonus effect can stack.][Chain Heal now jumps to a nearby totem within $458357A3 yards once it reaches its max targets, causing the totem to cast Chain Heal on an injured ally within $458357r yards for $458357s1. Jumps to $s1 nearby targets within $458357A3 yards.]
    unlimited_power           = { 94886, 454391, 1 }, -- Spending $?s137040[Maelstrom][Maelstrom Weapon stacks] grants you $454394s1% haste for $454394d, stacking. Gaining a new stack does not refresh the duration.
    unruly_winds              = { 80968, 390288, 1 }, -- Windfury Weapon has a $s1% chance to trigger a third attack.
    voltaic_surge             = { 94870, 454919, 1 }, -- Crash Lightning, Chain Lightning, and Earthquake damage increased by $s1%.
    whirling_elements         = { 94879, 445024, 1 }, -- [453409] $?a137041[Your next Stormstrike or Windstrike deals $s2% increased damage and damages $s3 nearby $Lenemy:enemies; at $s4% effectiveness.][The cast time of your next healing spell is reduced by $s1%.]; 
    wind_barrier              = { 94891, 445031, 1 }, -- If you have a totem active, your totem grants you a shield absorbing ${$mhp*$s1/100} damage for $457387d every $457390d.
    windfury_weapon           = { 80958, 33757 , 1 }, -- Imbue your main-hand weapon with the element of Wind for $319773d. Each main-hand attack has a $319773h% chance to trigger $?s390288[three][two] extra attacks, dealing $25504sw1 Physical damage each.$?s262647[; Windfury causes each successive Windfury attack within $262652d to increase the damage of Windfury by $262652s1%, stacking up to $262652u times.][]
    witch_doctors_ancestry    = { 80971, 384447, 1 }, -- Increases the chance to gain a stack of Maelstrom Weapon by $s1%, and whenever you gain a stack of Maelstrom Weapon, the cooldown of Feral Spirits is reduced by ${$m2/1000}.1 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5575, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by ${$s3-100}% for $d.; When the effect ends, enemies within $409304A1 yards are knocked in the air and take $<damage> Physical damage.
    counterstrike_totem = 3489, -- (204331) Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker. 
    electrocute         = 5658, -- (206642) When you successfully Purge a beneficial effect, the enemy suffers $206647o1 Nature damage over $206647d.
    grounding_totem     = 3622, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within $8178A1 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts $d.
    ride_the_lightning  = 721 , -- (289874) If there are more than $m2 $lenemy:enemies; within $m1 yards when you cast Stormstrike, you also cast a Chain Lightning on the target, dealing $211094s2 Nature damage.; Otherwise, you conjure bolts of lightning to up to $m3 furthest $lenemy:enemies; within $204350A1 yards dealing $204350s1 Nature damage.
    shamanism           = 722 , -- (193876) Your $?FAC[Bloodlust][Heroism] spell now has a $m1 sec. cooldown, but increases Haste by $204361s1%, and only affects you and your friendly target when cast for $204361d.; In addition, $?FAC[Bloodlust][Heroism] is no longer affected by $?FAC[Sated][Exhaustion].
    static_field_totem  = 5438, -- (355580) Summons a totem with $s2% of your health at the target location for $d that forms a circuit of electricity that enemies cannot pass through.
    stormweaver         = 5596, -- (410673) Maelstrom Weapon no longer benefits Healing Surge or Chain Heal. Instead, consuming Maelstrom Weapon on a damage spell causes your next Healing Surge or Chain Heal to gain $s1% of the benefits of Maelstrom Weapon based on the stacks consumed. 
    totem_of_wrath      = 3487, -- (460697) Primordial Wave summons a totem at your feet for $204330d that increases the critical effect of damage and healing spells of all nearby allies within $<radius> yards by $208963s1% for $208963d.; 
    unleash_shield      = 3492, -- (356736) Unleash your Elemental Shield's energy on an enemy target:; $@spellicon192106$@spellname192106: Knocks them away.; $@spellicon974$@spellname974: Roots them in place for $356738d.; $@spellicon52127$@spellname52127: Summons a whirlpool for $356739d, reducing damage and healing by $356824s1% while they stand within it.
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
        -- static_accumulation[384411] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Damage of your next Lava Lash increased by $s1%.
    ashen_catalyst = {
        id = 390371,
        duration = 15.0,
        max_stack = 1,
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
    -- Damage of Stormstrike increased by $w1%.
    converging_storms = {
        id = 198300,
        duration = 12.0,
        max_stack = 1,
    },
    -- When you deal damage, $w1% is dealt to your lowest health ally within $204331m2 yards.
    counterstrike_totem = {
        id = 208997,
        duration = 15.0,
        max_stack = 1,
    },
    -- Increases Nature damage dealt from your abilities by $s1%.
    crackling_surge = {
        id = 224127,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- elemental_spirits[262624] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Stormstrike, Ice Strike, and Lava Lash deal an additional $195592s1 damage to all targets in front of you.
    crash_lightning = {
        id = 187878,
        duration = 12.0,
        max_stack = 1,
    },
    -- Chance to activate Windfury Weapon increased to ${$319773h}.1%.; Damage dealt by Windfury Weapon increased by $s2%.
    doom_winds = {
        id = 384352,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?$w3!=0[Damage taken reduced by $w3%.; ][]Heals for ${$w2*(1+$w1/100)} upon taking damage.
    earth_shield = {
        id = 974,
        duration = 600.0,
        max_stack = 1,
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
    -- Rooted.
    earthgrab = {
        id = 64695,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    echoing_shock = {
        id = 320125,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- lashing_flames[334168] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- restoration_shaman[137039] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Attack speed increased by $w1%.
    flurry = {
        id = 382889,
        duration = 15.0,
        max_stack = 1,
    },
    -- Windfury attack damage increased by $s1%.
    forceful_winds = {
        id = 262652,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.
    frost_shock = {
        id = 196840,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- encasing_cold[462762] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- encasing_cold[462762] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ice_strike[384357] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hailstorm[334196] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 27.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Your next Frost Shock will deal $s1% additional damage, and hit up to ${$334195s1/$s2} additional $Ltarget:targets;.
    hailstorm = {
        id = 334196,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overflowing_maelstrom[384149] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
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
    -- Lava Lash damage increased by $s1% and cooldown reduced by ${100*(1-(100/(100+$m2)))}%.
    hot_hand = {
        id = 215785,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- hot_hand[201900] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 61.0, 'modifies': EFFECT_2_VALUE, }
        -- hot_hand[201900] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 50.0, 'modifies': EFFECT_1_VALUE, }
    },
    -- Damage of your next Frost Shock increased by $s1%.
    ice_strike = {
        id = 384357,
        duration = 12.0,
        max_stack = 1,
    },
    -- Damage taken from the Shaman's Flame Shock increased by $s1%.
    lashing_flames = {
        id = 334168,
        duration = 20.0,
        max_stack = 1,
    },
    -- Stormstrike damage increased by $s1%.
    legacy_of_the_frost_witch = {
        id = 335901,
        duration = 10.0,
        max_stack = 1,
    },
    -- You will take extra Nature damage when the Shaman uses Stormstrike.
    lightning_conduit = {
        id = 275391,
        duration = 60.0,
        max_stack = 1,
    },
    -- Stunned. Suffering $w1 Nature damage every $t1 sec.
    lightning_lasso = {
        id = 305485,
        duration = 5.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- natures_fury[381655] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Searing Totem is hurling Searing Bolts at nearby enemies.
    lively_totems = {
        id = 461242,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your next damage$?a410673[][ or healing] spell has its cast time reduced by ${$max($187881s1, -100)*-1}%$?a410673&?s383303[ and its damage increased by]?s383303&!a410673[, damage increased by][]$?s383303&!s384149[ $187881w2%]?s383303&s384149[ $187881w2%][]$?s383303&!a410673[, and healing increased by][]$?a410673[]?s383303&!s384149[ $187881w3%]?s383303&s384149[ $187881w3%][].
    maelstrom_weapon = {
        id = 344179,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- raging_maelstrom[384143] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
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
        -- enhancement_shaman[137041] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- totemic_focus[382201] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- oversized_totems[445026] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- restoration_shaman[137039] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Cannot benefit from Bloodlust or other similar effects.
    sated = {
        id = 57724,
        duration = 600.0,
        max_stack = 1,
    },
    -- Suffering $s1 Fire damage every $t1 sec.
    searing_assault = {
        id = 268429,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Generating $384411s1 $lstack:stacks; of Maelstrom Weapon every $t1 sec.
    static_accumulation = {
        id = 384437,
        duration = 15.0,
        tick_time = 1.0,
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
        id = 114893,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- restoration_shaman[137039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Stormstrike cooldown has been reset$?$?a319930[ and will deal $319930w1% additional damage as Nature][].
    stormbringer = {
        id = 201846,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_enhanced_elements[77223] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.08, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },
    -- Your next Lightning Bolt or Chain Lightning will be instant and deal $w1% additional damage.
    stormkeeper = {
        id = 205495,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next melee ability will deal additional Nature damage.
    strength_of_earth = {
        id = 273465,
        duration = 10.0,
        max_stack = 1,
    },
    -- Incapacitated.
    sundering = {
        id = 197214,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Haste increased by $s1%.
    unlimited_power = {
        id = 454394,
        duration = 15.0,
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

    -- Transform into an Air Ascendant for $114051d, immediately dealing $344548s1 Nature damage to any enemy within $344548A1 yds, reducing the cooldown and cost of Stormstrike by $s4%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a $114089r yd range.$?s384411[; While Ascendance is active, generate $s1 Maelstrom Weapon $lstack:stacks; every $384437t1 sec.][]
    ascendance = {
        id = 114051,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "ascendance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 59347, 'schools': ['physical', 'holy', 'frost', 'arcane'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_AUTOATTACK_WITH_RANGED_SPELL, 'trigger_spell': 114089, 'triggers': windlash, 'value': 114093, 'schools': ['physical', 'fire', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 115356, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #5: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 344548, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- static_accumulation[384411] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- enhancement_shaman[137041] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- natures_swiftness[378081] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
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
        -- elemental_shaman[137040] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- crashing_storms[334308] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- thorims_invocation[384444] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voltaic_surge[454919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 235.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- elemental_shaman[137040] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 67.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arc_discharge[455097] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- arc_discharge[455097] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Summons a totem at your feet for $d that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within $157503A1 yards for $157503s2% of all healing done while it was active, divided evenly among targets.; Casting this spell a second time recalls the totem and releases the healing.
    cloudburst_totem = {
        id = 157153,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        spend = 0.017,
        spendType = 'mana',

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

    -- Electrocutes all enemies in front of you, dealing ${$s1*$<CAP>/$AP} Nature damage. Hitting 2 or more targets enhances your weapons for $187878d, causing Stormstrike, Ice Strike, and Lava Lash to also deal ${$195592s1*$<CAP>/$AP} Nature damage to all targets in front of you. Damage reduced beyond $s2 targets.$?s384363[; Each target hit by Crash Lightning increases the damage of your next Stormstrike by $198300s1%, up to a maximum of $198300u stacks.][]
    crash_lightning = {
        id = 187874,
        cast = 0.0,
        cooldown = 12.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        talent = "crash_lightning",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 0.264, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- crashing_storms[334308] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- voltaic_surge[454919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crash_lightning[333964] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Strike your target for $s3 Physical damage, increase your chance to activate Windfury Weapon by $s1%, and increases damage dealt by Windfury Weapon by $s2% for $d.; 
    doom_winds = {
        id = 384352,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "doom_winds",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.65, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 3.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }

        -- Affected by:
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- enhancement_shaman[137041] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 164.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Lunge at your enemy as a ghostly wolf, biting them to deal $215802s1 Physical damage.
    feral_lunge = {
        id = 196884,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': JUMP_DEST, 'subtype': NONE, 'amplitude': 2.0, 'trigger_spell': 196881, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'value1': 1, 'radius': 2.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNK_148, }

        -- Affected by:
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons two $?s262624[Elemental ][]Spirit $?s147783[Raptors][Wolves] that aid you in battle for $228562d. They are immune to movement-impairing effects, and each $?s262624[Elemental ][]Feral Spirit summoned grants you $?s262624[$224125s1%][$392375s1%] increased $?s262624[Fire, Frost, or Nature][Physical] damage dealt by your abilities.; Feral Spirit generates one stack of Maelstrom Weapon immediately, and one stack every $333957t1 sec for $333957d.
    feral_spirit = {
        id = 51533,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "feral_spirit",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- elemental_spirits[262624] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Erupt a burst of fiery damage from all targets affected by your Flame Shock, dealing $333977s1 Flamestrike damage to up to $333977I targets within $333977A1 yds of your Flame Shock targets.$?s384359[; Each eruption from Fire Nova generates $384359s1 $Lstack:stacks; of Maelstrom Weapon.][]
    fire_nova = {
        id = 333974,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        talent = "fire_nova",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- lashing_flames[334168] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- restoration_shaman[137039] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 108.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 51.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Windfury causes each successive Windfury attack within $262652d to increase the damage of Windfury by $262652s1%, stacking up to $262652u times.
    forceful_winds = {
        id = 262647,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "forceful_winds",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- enhancement_shaman[137041] #7: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- enhancement_shaman[137041] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- encasing_cold[462762] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- encasing_cold[462762] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ice_strike[384357] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hailstorm[334196] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 27.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- enhancement_shaman[137041] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- earth_shield[974] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- natures_swiftness[378081] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- refreshing_waters[378211] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
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
        -- elemental_shaman[137040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tidecallers_guard[457496] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Strike your target with an icy blade, dealing $s1 Frost damage and snaring them by $s2% for $d.; Ice Strike increases the damage of your next Frost Shock by $384357s1%$?s384359[ and generates $384359s1 $Lstack:stacks; of Maelstrom Weapon][].
    ice_strike = {
        id = 342240,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.007,
        spendType = 'mana',

        talent = "ice_strike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.242, 'pvp_multiplier': 1.45, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 384357, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- maelstrom[343725] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- restoration_shaman[137039] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 128.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 29.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Charges your off-hand weapon with lava and burns your target, dealing $s1 Fire damage.; Damage is increased by $s2% if your offhand weapon is imbued with Flametongue Weapon. $?s334033[Lava Lash will spread Flame Shock from your target to $s3 nearby targets.][]$?s334046[; Lava Lash increases the damage of Flame Shock on its target by $334168s1% for $334168d.][]
    lava_lash = {
        id = 60103,
        cast = 0.0,
        cooldown = 18.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        talent = "lava_lash",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.308, 'pvp_multiplier': 1.25, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- molten_assault[334033] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- molten_assault[334033] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- ashen_catalyst[390371] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.33333, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hot_hand[215785] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hot_hand[215785] #1: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- stormkeeper[205495] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- stormkeeper[205495] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lightning_bolt[318044] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- natures_swiftness[378081] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- thorims_invocation[384444] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.75, 'points': 145.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 57.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- $?s454009[Tempest, ][]$?s137040[Earth Shock, Elemental Blast, and Earthquake][Lightning Bolt, Elemental Blast, and Chain Lightning] make your target a Lightning Rod for $197209d. Lightning Rods take $s2% of all damage you deal with Lightning Bolt and Chain Lightning.
    lightning_rod = {
        id = 210689,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

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
        -- primal_maelstrom[384405] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
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

    -- Energizes both your weapons with lightning and delivers a massive blow to your target, dealing a total of ${$32175sw1+$32176sw1} Physical damage.$?s210853[; Stormstrike has a $s4% chance to generate $210853m2 $Lstack:stacks; of Maelstrom Weapon.][]
    stormstrike = {
        id = 17364,
        cast = 0.0,
        cooldown = 7.5,
        gcd = "global",

        spend = 0.004,
        spendType = 'mana',

        talent = "stormstrike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 32175, 'triggers': stormstrike, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 32176, 'triggers': stormstrike_offhand, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 195573, 'value': 400, 'schools': ['frost'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- shaman[137038] #1: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- ascendance[114051] #2: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 115356, 'target': TARGET_UNIT_CASTER, }
        -- ascendance[114051] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ascendance[114051] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- elemental_assault[210853] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- stormbringer[201846] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Shatters a line of earth in front of you with your main hand weapon, causing $s1 Flamestrike damage and Incapacitating any enemy hit for $d.
    sundering = {
        id = 197214,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "sundering",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 1.84, 'variance': 0.05, 'radius': 11.0, 'target': TARGET_UNIT_RECT_CASTER_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 11.0, 'target': TARGET_UNIT_RECT_CASTER_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 1.0, 'target': TARGET_DEST_CASTER_FRONT, 'target2': TARGET_DEST_NEARBY_ENTRY_2, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'mechanic': incapacitated, 'radius': 11.0, 'target': TARGET_UNIT_RECT_CASTER_ENEMY, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shaman[137038] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- fire_and_ice[382886] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- legacy_of_the_frost_witch[384451] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Deal $s1 Nature damage to your target, and ${$m1*$m2/100} Nature damage to other enemy targets within $A1 yds of your target.
    tempest = {
        id = 452201,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.002,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.7, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- astral_bulwark[377933] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- natures_swiftness[378081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- natures_swiftness[378081] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- planes_traveler[381647] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- thorims_invocation[384444] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Deal $s1 Nature damage to your target, and ${$m1*$m2/100} Nature damage to other enemy targets within $A1 yds of your target.
    tempest_overload = {
        id = 463351,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.7, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_enhanced_elements[77223] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- enhancement_shaman[137041] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enhancement_shaman[137041] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- natures_fury[381655] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spiritwalkers_grace[79206] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- thundershock[378779] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- traveling_storms[204403] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 204406, 'target': TARGET_UNIT_CASTER, }
        -- stormcaller[454021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- stormcaller[454021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- restoration_shaman[137039] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- restoration_shaman[137039] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 54.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 39.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- elemental_shaman[137040] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_shaman[137040] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- amplification_core[456369] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- amplification_core[456369] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crackling_surge[224127] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': DAMAGE_HEALING, }
        -- crackling_surge[224127] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Imbue your main-hand weapon with the element of Wind for $319773d. Each main-hand attack has a $319773h% chance to trigger $?s390288[three][two] extra attacks, dealing $25504sw1 Physical damage each.$?s262647[; Windfury causes each successive Windfury attack within $262652d to increase the damage of Windfury by $262652s1%, stacking up to $262652u times.][]
    windfury_weapon = {
        id = 33757,
        color = 'weapon_imbue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "windfury_weapon",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.08, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- doom_winds[384352] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- imbuement_mastery[445028] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },

    -- Imbue your weapon with the element of Wind. Each hit has a $319773h% chance to trigger two extra attacks, dealing $25504sw1 Physical damage each.
    windfury_weapon_334302 = {
        id = 334302,
        color = 'weapon_imbue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': ENCHANT_ITEM_TEMPORARY, 'subtype': NONE, 'value': 5401, 'schools': ['physical', 'nature', 'frost'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_enhanced_elements[77223] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.08, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- doom_winds[384352] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- imbuement_mastery[445028] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        from = "affected_by_mastery",
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
        -- stormbringer[201846] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

} )