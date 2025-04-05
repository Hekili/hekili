-- DruidRestoration.lua
-- January 2025

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 105 )
local strformat = string.format

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Rage )

-- Talents
spec:RegisterTalents( {
    -- Druid
    aessinas_renewal            = {  82232, 474678, 1 }, -- When a hit deals more than 12% of your maximum health, instantly heal for 10% of your health. This effect cannot occur more than once every 30 seconds.
    aggravate_wounds            = {  94616, 441829, 1 }, -- Every attack with an Energy cost that you cast extends the duration of your Dreadful Wounds by 0.6 sec, up to 8 additional sec.
    astral_influence            = {  82210, 197524, 1 }, -- Increases the range of all of your spells by 5 yards.
    bestial_strength            = {  94611, 441841, 1 }, -- Maul and Raze damage increased by 20%.
    circle_of_the_heavens       = { 104078, 474541, 1 }, -- Magical damage dealt by your spells increased by 25%.
    circle_of_the_wild          = { 104078, 474530, 1 }, -- Physical damage dealt by your abilities increased by 25%.
    claw_rampage                = {  94613, 441835, 1 }, -- During Berserk, Shred, Swipe, and Thrash have a 25% chance to make your next Ferocious Bite become Ravage.
    cyclone                     = {  82229,  33786, 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 5 sec. Only one target can be affected by your Cyclone at a time.
    dreadful_wound              = {  94620, 441809, 1 }, -- Ravage also inflicts a Bleed that causes 7,597 damage over 6 sec and saps its victims' strength, reducing damage they deal to you by 10%. Dreadful Wound is not affected by Circle of Life and Death.
    empowered_shapeshifting     = {  94612, 441689, 1 }, -- Frenzied Regeneration can be cast in Cat Form for 40 Energy. Bear Form reduces magic damage you take by 4%. Shred and Swipe damage increased by 6%. Mangle damage increased by 15%.
    feline_swiftness            = {  82236, 131768, 1 }, -- Increases your movement speed by 15%.
    fluid_form                  = {  82246, 449193, 1 }, -- Shred, Rake, and Skull Bash can be used in any form and shift you into Cat Form, if necessary. Mangle can be used in any form and shifts you into Bear Form. Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                  = {  82243, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by 8% for 6 sec.
    fount_of_strength           = {  94618, 441675, 1 }, -- Your maximum Energy and Rage are increased by 20. Frenzied Regeneration also increases your maximum health by 10%.
    frenzied_regeneration       = {  82220,  22842, 1 }, -- Heals you for 32% health over 3 sec, and increases healing received by 20%.
    gale_winds                  = { 104079, 400142, 1 }, -- Increases Typhoon's radius by 20% and its range by 5 yds.
    grievous_wounds             = {  82239, 474526, 1 }, -- Rake, Rip, and Thrash damage increased by 10%.
    heart_of_the_wild           = {  82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Feral: Gain 1 Combo Point every 2 sec while in Cat Form and Physical damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges.
    hibernate                   = {  82211,   2637, 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin           = { 104085, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_natures_cure       = { 104084, 392378, 1 }, -- Nature's Cure additionally removes all Curse and Poison effects.
    improved_stampeding_roar    = {  82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    incapacitating_roar         = {  82237,     99, 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage may cancel the effect.
    incessant_tempest           = { 104079, 400140, 1 }, -- Reduces the cooldown of Typhoon by 5 sec.
    innervate                   = { 100175,  29166, 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 8 sec.
    instincts_of_the_claw       = { 104081, 449184, 1 }, -- Ferocious Bite and Maul damage increased by 8%.
    ironfur                     = {  82227, 192081, 1 }, -- Increases armor by 13,632 for 7 sec.
    killer_instinct             = {  82225, 108299, 2 }, -- Physical damage and Armor increased by 6%.
    killing_strikes             = {  94619, 441824, 1 }, -- Ravage increases your Agility by 8% and the armor granted by Ironfur by 20% for 8 sec. Your first Mangle after entering combat makes your next Maul become Ravage.
    lingering_healing           = {  82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec. Regrowth's duration is increased by 3 sec when cast on yourself.
    lore_of_the_grove           = { 104080, 449185, 1 }, -- Moonfire and Sunfire damage increased by 10%.
    lycaras_meditation          = {  92229, 474728, 1 }, -- You retain Lycara's Teachings' bonus from your most recent shapeshift form for 5 sec after shifting out of it.
    lycaras_teachings           = {  82233, 378988, 2 }, -- You gain 3% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                        = {  82221,  22570, 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 5,118 damage, 1 sec 2 points: 10,236 damage, 2 sec 3 points: 15,354 damage, 3 sec 4 points: 20,472 damage, 4 sec 5 points: 25,590 damage, 5 sec
    mass_entanglement           = {  82207, 102359, 1 }, -- Roots the target and all enemies within 12 yards in place for 10 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                  = { 100177, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 60,657 damage for 8 sec.
    mighty_bash                 = {  82237,   5211, 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    moonkin_form                = {  82208,  24858, 1 }, -- Shapeshift into Moonkin Form, increasing the damage of your spells by 10% and your armor by 125%, and granting protection from Polymorph effects. The act of shapeshifting frees you from movement impairing effects.
    natural_recovery            = {  82206, 377796, 1 }, -- Healing you receive is increased by 4%.
    natures_vigil               = {  82244, 124974, 1 }, -- For 15 sec, all single-target healing also damages a nearby enemy target for 20% of the healing done.
    nurturing_instinct          = {  82214,  33873, 2 }, -- Magical damage and healing increased by 6%.
    oakskin                     = { 100176, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional 10%.
    packs_endurance             = {  94615, 441844, 1 }, -- Stampeding Roar's duration is increased by 25%.
    perfectlyhoned_instincts    = { 104082, 1213597, 1 }, -- Well-Honed Instincts can trigger up to once every 60 sec.
    primal_fury                 = {  82224, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect. Mangle critical strike damage increased by 20%.
    rake                        = {  82199,   1822, 1 }, -- Rake the target for 8,415 Bleed damage and an additional 58,726 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    ravage                      = {  94609, 441583, 1 }, -- Your auto-attacks have a chance to make your next Ferocious Bite become Ravage. Ravage
    rejuvenation                = {  82217,    774, 1 }, -- Heals the target for 87,702 over 15 sec. Tree of Life: Healing increased by 40% and Mana cost reduced by 30%.
    renewal                     = {  82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rip                         = {  82222,   1079, 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 90,849 over 8 sec 2 points: 136,273 over 12 sec 3 points: 181,698 over 16 sec 4 points: 227,122 over 20 sec 5 points: 272,547 over 24 sec
    ruthless_aggression         = {  94619, 441814, 1 }, -- Ravage increases your auto-attack speed by 35% for 6 sec.
    skull_bash                  = {  82242, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                      = {  82229,   2908, 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar             = {  82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                    = {  91044, 197628, 1 }, -- Call down a burst of energy, causing 54,194 Arcane damage to the target, and 18,493 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starlight_conduit           = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by 5%. Starsurge's cooldown is reduced by 4 sec and its mana cost is reduced by 50%.
    starsurge                   = {  82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 68,334 Astral damage.
    strike_for_the_heart        = {  94614, 441845, 1 }, -- Shred, Swipe, and Mangle's critical strike chance and critical strike damage are increased by 15%.
    sunfire                     = {  93714,  93402, 1 }, -- A quick beam of solar light burns the enemy for 3,390 Nature damage and then an additional 31,320 Nature damage over 18 sec.
    symbiotic_relationship      = { 100173, 474750, 1 }, -- Form a bond with an ally. Your self-healing also heals your bonded ally for 10% of the amount healed. Your healing to your bonded ally also heals you for 8% of the amount healed.
    tear_down_the_mighty        = {  94614, 441846, 1 }, -- The cooldown of Pulverize is reduced by 10 sec.
    thick_hide                  = {  82228,  16931, 1 }, -- Reduces all damage taken by 4%.
    thrash                      = {  82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                  = {  82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    typhoon                     = {  82209, 132469, 1 }, -- Blasts targets within 20 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                = { 100174, 377842, 1 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 15%.
    ursocs_spirit               = {  82219, 449182, 1 }, -- Stamina increased by 4%. Stamina in Bear Form is increased by an additional 5%.
    ursols_vortex               = {  82207, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart               = {  82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts         = {  82235, 377847, 1 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 90 sec.
    wild_charge                 = {  82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                 = {  82205,  48438, 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 39,247 over 7 sec. Healing starts high and declines over the duration. Tree of Life: Affects 2 additional targets.
    wildpower_surge             = {  94612, 441691, 1 }, -- Mangle grants Feline Potential. When you have 6 stacks, the next time you transform into Cat Form, gain 5 combo points and your next Ferocious Bite or Rip deals 225% increased damage for its full duration.
    wildshape_mastery           = {  94610, 441678, 1 }, -- Ironfur and Frenzied Regeneration persist in Cat Form. When transforming from Bear to Cat Form, you retain 80% of your Bear Form armor and health for 6 sec. For 6 sec after entering Bear Form, you heal for 10% of damage taken over 8 sec.

    -- Restoration
    abundance                   = {  82052, 207383, 1 }, -- For each Rejuvenation you have active, Regrowth's cost is reduced by 8% and critical effect chance is increased by 8%, up to a maximum of 96%.
    budding_leaves              = {  82072, 392167, 2 }, -- Lifebloom's healing is increased by 5.0% each time it heals, up to 75%. Also increases Lifebloom's final bloom amount by 10%.
    call_of_the_elder_druid     = {  82067, 426784, 1 }, -- When you cast Starsurge, Rake, Shred, or Frenzied Regeneration you gain Heart of the Wild for 15 sec, once every 1 min.  Heart of the Wild Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Feral: Gain 1 Combo Point every 2 sec while in Cat Form and Physical damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges.
    cenarion_ward               = {  82052, 102351, 1 }, -- Protects a friendly target for 32 sec. Any damage taken will consume the ward and heal the target for 214,208 over 10 sec.
    cenarius_guidance           = {  82063, 393371, 1 }, --  Incarnation: Tree of Life During Incarnation: Tree of Life, you summon a Grove Guardian every 10 sec. The cooldown of Incarnation: Tree of Life is reduced by 5.0 sec when Grove Guardians fade.  Convoke the Spirits Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    convoke_the_spirits         = {  82064, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of 12 Druid spells and abilities over 3 sec. You will cast Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cultivation                 = {  82056, 200390, 1 }, -- When Rejuvenation heals a target below 60% health, it applies Cultivation to the target, healing them for 5,167 over 6 sec.
    dream_of_cenarius           = {  82066, 158504, 1 }, -- Wrath and Shred transfer 100% of their damage and Starfire and Swipe transfer 50% of their damage into healing onto a nearby ally. This effect is increased by 200% while Heart of the Wild is active.
    dreamstate                  = {  82053, 392162, 1 }, -- While channeling Tranquility, your other Druid spell cooldowns are reduced by up to 20 seconds.
    efflorescence               = {  82057, 145205, 1 }, -- Grows a healing blossom at the target location, restoring 5,439 health to three injured allies within 10 yards every 1.7 sec for 30 sec. Limit 1.
    embrace_of_the_dream        = {  82070, 392124, 1 }, -- Wild Growth momentarily shifts your mind into the Emerald Dream, instantly healing all allies affected by your Rejuvenation or Regrowth for 16,545.
    flash_of_clarity            = {  82083, 392220, 1 }, -- Clearcast Regrowths heal for an additional 30%.
    flourish                    = {  82073, 197721, 1 }, -- Extends the duration of all of your heal over time effects on friendly targets within 60 yards by 6 sec, and increases the rate of your heal over time effects by 25% for 8 sec. Affected allies are healed for 261,296, split evenly among them.
    forests_flow                = { 103873, 470581, 1 }, -- Consuming Clearcasting now causes your Regrowth to also cast Nourish onto a nearby injured ally at 60% effectiveness, preferring those with your heal over time effects.  Nourish: Heals a friendly target for 104,118. Receives 300% bonus from Mastery: Harmony.
    germination                 = {  82071, 155675, 1 }, -- You can apply Rejuvenation twice to the same target. Rejuvenation's duration is increased by 2 sec.
    grove_guardians             = {  82043, 102693, 1 }, -- Summons a Treant which will immediately cast Swiftmend on your current target, healing for 27,859. The Treant will cast Nourish on that target or a nearby ally periodically, healing for 8,706. Lasts 15 sec.
    grove_tending               = {  82047, 383192, 1 }, -- Swiftmend heals the target for 37,681 over 9 sec.
    harmonious_blooming         = {  82065, 392256, 1 }, -- Lifebloom counts for 3 stacks of Mastery: Harmony.
    improved_ironbark           = {  82081, 382552, 1 }, -- Ironbark's cooldown is reduced by 20 sec.
    improved_regrowth           = {  82055, 231032, 1 }, -- Regrowth's initial heal has a 40% increased chance for a critical effect if the target is already affected by Regrowth.
    improved_wild_growth        = {  82045, 328025, 1 }, -- Wild Growth heals 1 additional target.
    incarnation                 = {  82064,  33891, 1 }, -- Shapeshift into the Tree of Life, increasing healing done by 10%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    incarnation_tree_of_life    = {  82064,  33891, 1 }, -- Shapeshift into the Tree of Life, increasing healing done by 10%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    inner_peace                 = {  82053, 197073, 1 }, -- Reduces the cooldown of Tranquility by 30 sec. While channeling Tranquility, you take 20% reduced damage and are immune to knockbacks.
    invigorate                  = {  82070, 392160, 1 }, -- Refreshes the duration of your active Lifebloom and Rejuvenation effects on the target and causes them to complete 200% faster.
    ironbark                    = {  82082, 102342, 1 }, -- The target's skin becomes as tough as Ironwood, reducing damage taken by 20% for 16 sec. Allies protected by your Ironbark also receive 75% of the healing from each of your active Rejuvenations.
    lifebloom                   = {  82049,  33763, 1 }, -- Heals the target for 59,008 over 15 sec. When Lifebloom expires or is dispelled, the target is instantly healed for 40,331. May be active on one target at a time.
    liveliness                  = {  82074, 426702, 1 }, -- Your damage over time effects deal their damage 25% faster, and your healing over time effects heal 5% faster.
    master_shapeshifter         = {  82074, 289237, 1 }, -- Your abilities are amplified based on your current shapeshift form, granting an additional effect. Wrath, Starfire, and Starsurge deal 30% additional damage and generate 16,666 Mana. Bear Form Ironfur grants 30% additional armor and generates 16,666 Mana.  Cat Form Rip, Ferocious Bite, and Maim deal 60% additional damage and generate 66,666 Mana when cast with 5 combo points.
    natures_splendor            = {  82051, 392288, 1 }, -- The healing bonus to Regrowth from Nature's Swiftness is increased by 35%.
    natures_swiftness           = {  82050, 132158, 1 }, -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional 200%.
    nourish                     = {  82043,  50464, 1 }, -- Heals a friendly target for 104,118. Receives 300% bonus from Mastery: Harmony.
    nurturing_dormancy          = {  82076, 392099, 1 }, -- When your Rejuvenation heals a full health target, its duration is increased by 2 sec, up to a maximum total increase of 4 sec per cast.
    overgrowth                  = {  82061, 203651, 1 }, -- Apply Lifebloom, Rejuvenation, Wild Growth, and Regrowth's heal over time effect to an ally.
    passing_seasons             = {  82051, 382550, 1 }, -- Nature's Swiftness's cooldown is reduced by 12 sec.
    photosynthesis              = {  82073, 274902, 1 }, -- While your Lifebloom is on yourself, your periodic heals heal 10% faster. While your Lifebloom is on an ally, your periodic heals on them have a 4% chance to cause it to bloom.
    power_of_the_archdruid      = {  82077, 392302, 1 }, -- Wild Growth has a 60% chance to cause your next Rejuvenation or Regrowth to apply to 2 additional allies within 20 yards of the target.
    prosperity                  = {  82079, 200383, 1 }, -- Swiftmend now has 2 charges.
    rampant_growth              = {  82058, 404521, 1 }, -- Regrowth's healing over time is increased by 50%, and it also applies to the target of your Lifebloom.
    reforestation               = {  82069, 392356, 1 }, -- Every 4 casts of Swiftmend grants you Incarnation: Tree of Life for 13 sec.
    regenerative_heartwood      = {  82075, 392116, 1 }, -- Allies protected by your Ironbark also receive 75% of the healing from each of your active Rejuvenations and Ironbark's duration is increased by 4 sec.
    regenesis                   = {  82062, 383191, 2 }, -- Rejuvenation healing is increased by up to 10%, and Tranquility healing is increased by up to 20%, healing for more on low-health targets.
    renewing_surge              = { 103874, 470562, 1 }, -- The cooldown of Swiftmend is reduced by up to 40%, based on the current health of the target. Cooldown is reduced more when cast on a lower health target.
    soul_of_the_forest          = {  82059, 158478, 1 }, -- Swiftmend increases the healing of your next Regrowth or Rejuvenation by 150%, or your next Wild Growth by 50%.
    spring_blossoms             = {  82061, 207385, 1 }, -- Each target healed by Efflorescence is healed for an additional 3,781 over 6 sec.
    stonebark                   = {  82081, 197061, 1 }, -- Ironbark increases healing from your heal over time effects by 20%.
    thriving_vegetation         = {  82068, 447131, 2 }, -- Rejuvenation instantly heals your target for 20% of its total periodic effect and Regrowth's duration is increased by 3 sec.
    tranquil_mind               = {  92674, 403521, 1 }, -- Increases Omen of Clarity's chance to activate Clearcasting to 5% and Clearcasting can stack 1 additional time.
    tranquility                 = {  82054,    740, 1 }, -- Heals all allies within 40 yards for 316,790 over 4.2 sec. Each heal heals the target for another 1,847 over 8 sec, stacking. Healing decreased beyond 5 targets.
    twinleaf                    = { 103875, 470540, 1 }, -- Nature's Swiftness now has 2 charges.
    undergrowth                 = {  82077, 392301, 1 }, -- You may Lifebloom two targets at once, but Lifebloom's healing is reduced by 10%.
    unstoppable_growth          = {  82080, 382559, 2 }, -- Wild Growth's healing falls off 40% less over time.
    verdancy                    = {  82060, 392325, 1 }, -- When Lifebloom blooms, up to 3 targets within your Efflorescence are healed for 18,153.
    verdant_infusion            = {  82079, 392410, 1 }, -- Swiftmend no longer consumes a heal over time effect, and extends the duration of your heal over time effects on the target by 8 sec.
    waking_dream                = {  82046, 392221, 1 }, -- Ysera's Gift now heals every 4 sec and its healing is increased by 8% for each of your active Rejuvenations.
    wild_synthesis              = {  94535, 400533, 1 }, --  Nourish Regrowth decreases the cast time of your next Nourish by 33% and causes it to receive an additional 33% bonus from Mastery: Harmony. Stacks up to 3 times. Grove Guardians Treants from Grove Guardians also cast Wild Growth immediately when summoned, healing 5 allies within 40 yds for 9,457 over 7 sec.
    wildwood_roots              = { 103876, 470549, 1 }, -- Abundance now also reduces the cast time of Regrowth by 5% per stack. Cenarion Ward's cooldown is reduced by 10 sec and its duration is increased by 2 sec.
    yseras_gift                 = {  82048, 145108, 1 }, -- Heals you for 3% of your maximum health every 5 sec. If you are at full health, an injured party or raid member will be healed instead.

    -- Keeper of the Grove
    blooming_infusion           = {  94601, 429433, 1 }, -- Every 5 Regrowths you cast makes your next Wrath, Starfire, or Entangling Roots instant and increases damage it deals by 100%. Every 5 Starsurges you cast makes your next Regrowth or Entangling roots instant.
    bounteous_bloom             = {  94591, 429215, 1 }, -- Your Grove Guardians' healing is increased by 30%.
    cenarius_might              = {  94604, 455797, 1 }, -- Casting Swiftmend increases your Haste by 10% for 6 sec.
    control_of_the_dream        = {  94592, 434249, 1 }, -- Time elapsed while your major abilities are available to be used or at maximum charges is subtracted from that ability's cooldown after the next time you use it, up to 15 seconds. Affects Nature's Swiftness, Incarnation: Tree of Life, and Convoke the Spirits.
    dream_surge                 = {  94600, 433831, 1, "keeper_of_the_grove" }, -- Grove Guardians causes your next targeted heal to create 2 Dream Petals near the target, healing up to 3 nearby allies for 19,394. Stacks up to 3 charges.
    durability_of_nature        = {  94605, 429227, 1 }, -- Your Grove Guardians' Nourish and Swiftmend spells also apply a Minor Cenarion Ward that heals the target for 64,559 over 10 sec the next time they take damage.
    early_spring                = {  94591, 428937, 1 }, -- Grove Guardians cooldown reduced by 3 sec.
    expansiveness               = {  94602, 429399, 1 }, -- Your maximum mana is increased by 5%.
    groves_inspiration          = {  94595, 429402, 1 }, -- Wrath and Starfire damage increased by 10%. Regrowth, Wild Growth, and Swiftmend healing increased by 9%.
    harmony_of_the_grove        = {  94606, 428731, 1 }, -- Each of your Grove Guardians increases your healing done by 5% while active.
    potent_enchantments         = {  94595, 429420, 1 }, -- Reforestation grants Tree of Life for 3 additional sec.
    power_of_nature             = {  94605, 428859, 1 }, -- Your Grove Guardians increase the healing of your Rejuvenation, Efflorescence, and Lifebloom by 10% while active.
    power_of_the_dream          = {  94592, 434220, 1 }, -- Healing spells cast with Dream Surge generate an additional Dream Petal.
    protective_growth           = {  94593, 433748, 1 }, -- Your Regrowth protects you, reducing damage you take by 8% while your Regrowth is on you.
    treants_of_the_moon         = {  94599, 428544, 1 }, -- Your Grove Guardians cast Moonfire on nearby targets about once every 6 sec.

    -- Wildstalker
    bond_with_nature            = {  94625, 439929, 1 }, -- Healing you receive is increased by 4%.
    bursting_growth             = {  94630, 440120, 1 }, -- When Bloodseeker Vines expire or you use Ferocious Bite on their target they explode in thorns, dealing 19,992 physical damage to nearby enemies. Damage reduced above 5 targets. When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to 3 nearby allies for 4,669.
    entangling_vortex           = {  94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for 3 sec. Damage may cancel the effect.
    flower_walk                 = {  94622, 439901, 1 }, -- During Barkskin your movement speed is increased by 10% and every second flowers grow beneath your feet that heal up to 3 nearby injured allies for 3,732.
    harmonious_constitution     = {  94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by 35%.
    hunt_beneath_the_open_skies = {  94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by 3%. Moonfire and Sunfire damage increased by 10%.
    implant                     = {  94628, 440118, 1 }, -- Your Swiftmend causes a Symbiotic Bloom to grow on the target for 6 sec.
    lethal_preservation         = {  94624, 455461, 1 }, -- When you remove an effect with Soothe or Nature's Cure, gain a combo point and heal for 4% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    resilient_flourishing       = {  94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last 2 additional sec. When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    root_network                = {  94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%. Each active Symbiotic Bloom increases the healing of your spells by 2%.
    strategic_infusion          = {  94623, 439890, 1 }, -- Attacking from Prowl increases the chance for Shred, Rake, and Swipe to critically strike by 8% for 6 sec. Casting Regrowth increases the chance for your periodic heals to critically heal by 8% for 10 sec.
    thriving_growth             = {  94626, 439528, 1, "wildstalker" }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing 17,507 Bleed damage over 6 sec. Wild Growth, Regrowth, and Efflorescence healing has a chance to cause Symbiotic Blooms to grow on the target, healing for 17,131 over 6 sec. Multiple instances of these can overlap.
    twin_sprouts                = {  94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a 20% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    vigorous_creepers           = {  94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by 5%. Symbiotic Blooms increase the healing your spells do to affected targets by 20%.
    wildstalkers_power          = {  94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by 5%. Rejuvenation, Efflorescence, and Lifebloom healing increased by 10%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    ancient_of_lore    = 5668, -- (473909) Shapeshift into an Ancient of Lore, preventing all crowd control effects, reducing damage taken by 20%, and granting you access to Blossom Burst and Mass Blooming. Reduces movement speed. Lasts 12 sec.  Blossom Burst:  Mass Blooming:
    deep_roots         =  700, -- (233755)
    disentanglement    =   59, -- (233673)
    early_spring       = 1215, -- (203624)
    entangling_bark    =  692, -- (247543) Ironbark now also grants the target Nature's Grasp, rooting the first 3 melee attackers for 6 sec.
    forest_guardian    = 5687, -- (1217474)
    high_winds         =  838, -- (200931) Increases the range of Cyclone, Typhoon, and Entangling Roots by 5 yds.
    malornes_swiftness = 5514, -- (236147)
    thorns             =  697, -- (1217017)
    tireless_pursuit   = 5649, -- (377801)
} )

local mod_liveliness_hot = setfenv( function( dur )
    if not talent.liveliness.enabled then return dur end
    return dur * 0.95
end, state )

local mod_liveliness_dot = setfenv( function( dur )
    if not talent.liveliness.enabled then return dur end
    return dur * 0.75
end, state )


-- Auras
spec:RegisterAuras( {
    abundance = {
        id = 207640,
        duration = 3600,
        max_stack = 12
    },
    call_of_the_elder_druid = {
        id = 426790,
        duration = 60,
        max_stack = 1,
        copy = "oath_of_the_elder_druid"
    },
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
    cenarion_ward_hot = {
        id = 102352,
        duration = 8,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
        dot = "buff",
        friendly = true,
        max_stack = 1
    },
    -- [393381] During Incarnation: Tree of Life, you summon a Grove Guardian every $393418t sec. The cooldown of Incarnation: Tree of Life is reduced by ${$s1/-1000}.1 sec when Grove Guardians fade.
    cenarius_guidance = {
        id = 393418,
        duration = 30,
        tick_time = 10,
        max_stack = 1,
    },
    clearcasting = {
        id = 16870,
        duration = 15,
        max_stack = 1
    },
    cultivation = {
        id = 200389,
        duration = 6,
        dot = "buff",
        friendly = true,
        max_stack = 1
    },
    efflorescence = {
        id = 145205,
        duration = 30,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
        max_stack = 1,
    },
    flourish = {
        id = 197721,
        duration = 8,
        max_stack = 1
    },
    grove_guardians = {
        id = 102693,
        duration = 15,
        max_stack = 5,
        generate = function( t )
            local expires = action.grove_guardians.lastCast + 15

            if expires > query_time then
                t.name = action.grove_guardians.name
                t.count = 1
                t.expires = expires
                t.applied = expires - 15
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    grove_tending = {
        id = 383193,
        duration = 9,
        max_stack = 1,
        copy = 279793 -- Azerite.
    },
    harmony_of_the_grove = {
        id = 428737,
        duration = 15,
        max_stack = 3
    },
    -- The actual incarn buff
    incarnation = {
        id = 117679,
        duration = 30,
        max_stack = 1
    },
    -- This is the form
    incarnation_tree_of_life = {
        id = 33891,
        duration = 3600,
        max_stack = 1,
        copy = "tree_of_life_form"
    },
    ironbark = {
        id = 102342,
        duration = function() return talent.regenerative_heartwood.enabled and 16 or 12 end,
        max_stack = 1
    },
    -- talent = double lifebloom. Both spellID and actual buff spellID change.
    lifebloom = {
        id = 33763,
        duration = 15,
        tick_time = function() return haste * mod_liveliness_hot( 1 ) end,
        max_stack = 1,
        dot = "buff",
        friendly = true,
    },
    lifebloom_2 = {
        id = 188550,
        duration = 15,
        tick_time = function() return haste * mod_liveliness_hot( 1 ) end,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        copy = "lifebloom"
    },
    natures_swiftness = {
        id = 132158,
        duration = 3600,
        max_stack = 1,
        onRemove = function()
            setCooldown( "natures_swiftness", spec.abilities.natures_swiftness.cooldown )
        end,
    },
    natures_vigil = {
        id = 124974,
        duration = 15,
        max_stack = 1,
    },
    -- You have recently gained Heart of the Wild from Oath of the Elder Druid.
    oath_of_the_elder_druid = {
        id = 338643,
        duration = 60,
        max_stack = 1,
    },
    reforestation = {
        id = 392360,
        duration = 3600,
        max_stack = 3,
    },
    regrowth = {
        id = 8936,
        duration = function() return 12 + 3 * talent.thriving_vegetation.rank end,
        tick_time = function() return haste * mod_liveliness_hot( 2 ) end,
        dot = "buff",
        friendly = true,
        max_stack = 1
    },
    rejuvenation = {
        id = 774,
        duration = function() return 12 + 3 * talent.improved_rejuvenation.rank end,
        tick_time = function() return haste * mod_liveliness_hot( 3 ) end,
        dot = "buff",
        friendly = true,
        max_stack = 1
    },
    rejuvenation_germination = {
        id = 155777,
        duration = function () return spec.auras.rejuvenation.duration end,
        tick_time = function() return haste * mod_liveliness_hot( 3 ) end,
        dot = "buff",
        friendly = true,
        max_stack = 1
    },
    renewing_bloom = {
        id = 364686,
        duration = 8,
        tick_time = function() return mod_liveliness_hot( 1 ) end,
        max_stack = 1
    },
    soul_of_the_forest = {
        id = 114108,
        duration = 15,
        max_stack = 1,
    },
    symbiotic_relationship = {
        id = 474754,
        duration = 3600,
        dot = "buff",
        friendly = true,
        max_stack = 1,
    },
    spring_blossoms = {
        id = 207386,
        duration = 6,
        dot = "buff",
        friendly = true,
        max_stack = 1,
    },
    tranquility = {
        id = 740,
        duration = function() return 5 * haste end,
        generate = function( t )
            if buff.casting.up and buff.casting.v1 == 740 then
                t.applied  = buff.casting.applied
                t.duration = buff.casting.duration
                t.expires  = buff.casting.expires
                t.stack    = 1
                t.caster   = "player"
                return
            end

            t.applied  = 0
            t.duration = spec.auras.tranquility.duration
            t.expires  = 0
            t.stack    = 0
            t.caster   = "nobody"
        end,
        tick_time = function() return haste end,  -- Interval between each tick based on haste
        max_stack = 1
    },
    tranquility_hot = {
        id = 157982,
        duration = 8,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
        max_stack = 5
    },
    wild_growth = {
        id = 48438,
        duration = 7,
        tick_time = function() return mod_liveliness_hot( 1 ) end,
        dot = "buff",
        friendly = true,
        max_stack = 1
    },
    wild_synthesis = {
        id = 400534,
        duration = 3600,
        max_stack = 3
    },
} )

spec:RegisterPet( "treants",
    54983,
    "grove_guardians",
    15,
    54983 )

spec:RegisterTotem( "treants", 54983 )

spec:RegisterStateFunction( "break_stealth", function ()
    removeBuff( "shadowmeld" )
    if buff.prowl.up then
        setCooldown( "prowl", 6 )
        removeBuff( "prowl" )
    end
end )

-- Function to remove any form currently active.
spec:RegisterStateFunction( "unshift", function()
    if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    removeBuff( "tree_of_life_form" )
    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )
end )

-- Function to apply form that is passed into it via string.
spec:RegisterStateFunction( "shift", function( form )
    if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

    removeBuff( "tree_of_life_form" )
    removeBuff( "cat_form" )
    removeBuff( "bear_form" )
    removeBuff( "travel_form" )
    removeBuff( "moonkin_form" )
    removeBuff( "travel_form" )
    removeBuff( "aquatic_form" )
    removeBuff( "stag_form" )
    applyBuff( form )

    if form == "bear_form" and pvptalent.celestial_guardian.enabled then
        applyBuff( "celestial_guardian" )
    end

    if form == "bear_form" or form == "cat_form" and talent.call_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid.down then
        applyBuff( "heart_of_the_wild", 15 )
        applyDebuff( "player", "oath_of_the_elder_druid" )
    end
end )

spec:RegisterHook( "runHandler", function( ability )
    local a = class.abilities[ ability ]

    if not a or a.startsCombat then
        break_stealth()
    end

    if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
        stat.haste = stat.haste + 0.01
        addStack( "ravenous_frenzy", nil, 1 )
    end
end )

-- The War Within
spec:RegisterGear( "tww2", 229310, 229308, 229306, 229307, 229305  )

-- Tier 30
spec:RegisterGear( "tier30", 202518, 202516, 202515, 202514, 202513 )
-- 2 pieces (Restoration) : Rejuvenation and Lifebloom healing increased by 12%. Regrowth healing over time increased by 50%.
-- 4 pieces (Restoration) : Flourish increases the rate of your heal over time effects by 30% for an additional 16 sec after it ends. Verdant Infusion causes your Swiftmend target to gain 15% increased healing from you for 6 sec.

spec:RegisterGear( "tier31", 207252, 207253, 207254, 207255, 207257, 217193, 217195, 217191, 217192, 217194 )
-- (2) You and your Grove Guardian's Nourishes now heal $s1 additional allies within $423618r yds at $s2% effectiveness.
-- (4) Consuming Clearcasting now causes your Regrowth to also cast Nourish onto a nearby injured ally at $s1% effectiveness, preferring those with your heal over time effects.

local TranquilityTickHandler = setfenv( function()

    addStack( "tranquility_hot" )
    if talent.dreamstate.enabled then
        for ability, _ in pairs( class.abilities ) do
            reduceCooldown( ability, 4 )
        end
    end

end, state )

local ComboPointPeriodic = setfenv( function()
    gain( 1, "combo_points" )
end, state )

local TreantSpawnPeriodic = setfenv( function()
    summonPet( "treants", 15 )
    addStack( "grove_guardians" ) -- Just for tracking.
    if talent.harmony_of_the_grove.enabled then addStack( "harmony_of_the_grove" ) end
end, state )


spec:RegisterHook( "reset_precast", function ()

    if buff.casting.up and buff.casting.v1 == 740 then

        local tickInterval = spec.auras.tranquility.tick_time
        local tick, expires = buff.casting.applied, buff.casting.expires

        for i = 1, 4 do
            tick = tick + tickInterval
            if tick > query_time and tick < expires then
                state:QueueAuraEvent( "tranquility_tick", TranquilityTickHandler, tick, "AURA_TICK" )
            end
        end

    end

    if buff.heart_of_the_wild.up then
        local tick, expires = buff.heart_of_the_wild.applied, buff.heart_of_the_wild.expires
        for i = 2, expires - query_time, 2 do
            tick = query_time + i
            if tick < expires then
                state:QueueAuraEvent( "incarnation_combo_point_perodic", ComboPointPeriodic, tick, "AURA_TICK" )
            end
        end
    end

    if buff.incarnation.up then
        local tick, expires = buff.incarnation.applied, buff.incarnation.expires
        for i = 10, expires - query_time, 10 do
            tick = query_time + i
            if tick < expires then
                state:QueueAuraEvent( "tree_of_life_treant_spawn", TreantSpawnPeriodic, tick, "AURA_TICK" )
            end
        end
    end



end )

-- Abilities
spec:RegisterAbilities( {
    -- Protects a friendly target for 30 sec. Any damage taken will consume the ward and heal the target for 11,054 over 8 sec.
    cenarion_ward = {
        id = 102351,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "cenarion_ward",
        startsCombat = false,
        texture = 132137,

        handler = function ()
            active_dot.cenarion_ward = active_dot.cenarion_ward + 1
        end,
    },

    -- Grows a healing blossom at the target location, restoring 676 health to three injured allies within 10 yards every 1.7 sec for 30 sec. Limit 1.
    efflorescence = {
        id = 145205,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        talent = "efflorescence",
        startsCombat = false,
        texture = 134222,

        handler = function ()
            applyBuff( "efflorescence" )
        end,
    },

    -- Extends the duration of all of your heal over time effects on friendly targets within 60 yards by 8 sec, and increases the rate of your heal over time effects by 100% for 8 sec.
    flourish = {
        id = 197721,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "flourish",
        startsCombat = false,
        texture = 538743,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "flourish" )
            if buff.cenarion_ward.up then buff.cenarion_ward.expires = buff.cenarion_ward.expires + 8 end
            if buff.grove_tending.up then buff.grove_tending.expires = buff.grove_tending.expires + 8 end
            if buff.lifebloom_2.up then buff.lifebloom_2.expires = buff.lifebloom_2.expires + 8 end
            if buff.lifebloom.up then buff.lifebloom.expires = buff.lifebloom.expires + 8 end
            if buff.regrowth.up then buff.regrowth.expires = buff.regrowth.expires + 8 end
            if buff.rejuvenation_germination.up then buff.rejuvenation_germination.expires = buff.rejuvenation_germination.expires + 8 end
            if buff.rejuvenation.up then buff.rejuvenation.expires = buff.rejuvenation.expires + 8 end
            if buff.renewing_bloom.up then buff.renewing_bloom.expires = buff.renewing_bloom.expires + 8 end
            if buff.tranquility_hot.up then buff.tranquility_hot.expires = buff.tranquility_hot.expires + 8 end
            if buff.wild_growth.up then buff.wild_growth.expires = buff.wild_growth.expires + 8 end
        end,
    },

    -- Summons a Treant which will immediately cast Swiftmend on your current target, healing for ${$422094m1}.  The Treant will cast Nourish on that target or a nearby ally periodically, healing for ${$422090m1}. Lasts $d.
    grove_guardians = {
        id = 102693,
        cast = 0.0,
        cooldown = function () return 20 - 3 * talent.early_spring.rank end,
        recharge = 20,
        charges = 3,
        icd = 0.5,
        gcd = "off",

        spend = 0.012,
        spendType = 'mana',

        talent = "grove_guardians",
        startsCombat = false,

        handler = function()
            summonPet( "treants", 15 )
            addStack( "grove_guardians" ) -- Just for tracking.
            if talent.harmony_of_the_grove.enabled then addStack( "harmony_of_the_grove" ) end
        end,
    },

    -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, and Entangling Roots is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    incarnation = {
        id = 33891,
        cast = 0,
        cooldown = function() return buff.tree_of_life_form.up and 0 or 180 end,
        gcd = "spell",

        talent = "incarnation",
        startsCombat = false,
        texture = 236157,

        toggle = "cooldowns",

        handler = function ()
            if buff.incarnation.down then
                applyBuff( "incarnation" )
                if talent.cenarius_guidance.enabled then for i = 10, 30, 10 do
                        state:QueueAuraEvent( "tree_of_life_treant_spawn", TreantSpawnPeriodic, queryTime + i , "AURA_TICK" )
                    end
                end
            end
            shift( "incarnation_tree_of_life" )
        end,

        copy = "incarnation_tree_of_life"
    },

    -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 10 sec.
    innervate = {
        id = 29166,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "innervate",
        startsCombat = false,
        texture = 136048,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "innervate" )
        end,
    },

    -- Refreshes the duration of your active Lifebloom and Rejuvenation effects on the target and causes them to complete 200% faster.
    invigorate = {
        id = 392160,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "invigorate",
        startsCombat = false,
        texture = 136073,

        handler = function ()
            if buff.lifebloom_2.up then buff.lifebloom_2.expires = query_time + buff.lifebloom_2.duration end
            if buff.lifebloom.up then buff.lifebloom.expires = query_time + buff.lifebloom.duration end
            if buff.rejuvenation_germination.up then buff.rejuvenation_germination.expires = query_time + buff.rejuvenation_germination.duration end
            if buff.rejuvenation.up then buff.rejuvenation.expires = query_time + buff.rejuvenation.duration end
        end,
    },

    -- The target's skin becomes as tough as Ironwood, reducing damage taken by 20% for 12 sec.
    ironbark = {
        id = 102342,
        cast = 0,
        cooldown = function() return 90 - ( talent.improved_ironbark.enabled and 20 or 0 ) end,
        gcd = "off",

        talent = "ironbark",
        startsCombat = false,
        texture = 572025,

        toggle = "defensives",

        handler = function ()
            applyBuff( "ironbark" )
        end,
    },

    -- Heals the target for 7,866 over 15 sec. When Lifebloom expires or is dispelled, the target is instantly healed for 4,004. May be active on one target at a time. Lifebloom counts for 2 stacks of Mastery: Harmony.
    lifebloom = {
        id = function() return talent.undergrowth.enabled and 188550 or 33763 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "lifebloom",
        startsCombat = false,
        texture = 134206,

        handler = function ()
            active_dot.lifebloom = min( active_dot.lifebloom + 1, 1 + ( 1 * talent.undergrowth.rank ) )
        end,

        copy = { 188550, 33763 }
    },

    -- Cures harmful effects on the friendly target, removing all Magic, Curse, and Poison effects.
    natures_cure = {
        id = 88423,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236288,

        buff = function()
            return buff.dispellable_magic.up and "dispellable_magic" or
                buff.dispellable_curse.up and "dispellable_curse" or
                buff.dispellable_poison.up and "dispellable_poison" or "dispellable_magic"
        end,

        handler = function ()
            removeBuff( "dispellable_magic" )
            removeBuff( "dispellable_curse" )
            removeBuff( "dispellable_poison" )
        end,
    },

    -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional 135%.
    natures_swiftness = {
        id = 132158,
        cast = 0,
        charges = function() if talent.twinleaf.enabled then return 2 end end,
        cooldown = function() return 60 - 12 * talent.passing_seasons.rank end,
        recharge = function() if talent.twinleaf.enabled then return 60 end end,
        gcd = "off",

        talent = "natures_swiftness",
        startsCombat = false,
        texture = 136076,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "natures_swiftness" )
        end,
    },

    -- Heals a friendly target for 6,471. Receives triple bonus from Mastery: Harmony.
    nourish = {
        id = 50464,
        cast = function() return 2 * haste * ( talent.wild_synthesis.enabled and ( 1 - 0.34 * buff.wild_synthesis.stack ) or 1 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "nourish",
        startsCombat = false,
        texture = 236162,

        handler = function ()
            removeBuff( "wild_synthesis" )
        end,
    },

    -- Apply Lifebloom, Rejuvenation, Wild Growth, and Regrowth's heal over time effect to an ally.
    overgrowth = {
        id = 203651,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "overgrowth",
        startsCombat = false,
        texture = 1408836,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "lifebloom" )
            applyBuff( "rejuvenation" )
            applyBuff( "wild_growth" )
            applyBuff( "regrowth" )
        end,
    },

    -- Heals a friendly target for 4,267 and another 1,284 over 12 sec. Tree of Life: Instant cast.
    regrowth = {
        id = 8936,
        cast = function() return ( buff.tree_of_life_form or buff.blooming_infusion_regrowth.up ) and 0 or 1.5 * ( talent.wildwood_roots.enabled and ( 1 - 0.05 * buff.abundance.stack ) or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.10 * ( talent.abundance.enabled and ( 1 - 0.08 * buff.abundance.stack ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136085,

        handler = function ()
            removeBuff( "natures_swiftness" )
            removeBuff( "clearcasting" )
            active_dot.regrowth = active_dot.regrowth + 1 + ( talent.power_of_the_archdruid.enabled and buff.power_of_the_archdruid.up and 2 or 0 )
            if talent.soul_of_the_forest.enabled then removeBuff( "soul_of_the_forest" ) end
            if talent.forestwalk.enabled then applyBuff( "forestwalk" ) end
            if talent.wild_synthesis.enabled then addStack( "wild_synthesis" ) end
            if talent.blooming_infusion.enabled then removeBuff( "blooming_infusion_regrowth" ) end
        end,
    },

    -- Heals the target for 4,624 over 15 sec. Tree of Life: Healing increased by 50% and Mana cost reduced by 30%.
    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.tree_of_life_form.up and 0.7 or 1 ) * 0.021 end,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,
        texture = 136081,

        handler = function ()
            -- Main Rejuv buff
            if talent.germination.enabled then
                if buff.rejuvenation.down or buff.rejuvenation.remains < buff.rejuvenation_germination.remains then
                    applyBuff( "rejuvenation" )

                elseif buff.germination.remains < buff.rejuvenation.remains then applyBuff( "rejuvenation_germination" )
                end
            else applyBuff( "rejuvenation" )
            end

            if talent.soul_of_the_forest.enabled then removeBuff( "soul_of_the_forest" ) end
            active_dot.rejuvenation = active_dot.rejuvenation + 1 + ( talent.power_of_the_archdruid.enabled and buff.power_of_the_archdruid.up and 2 or 0 )
        end,
    },

    -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    renewal = {
        id = 108238,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "renewal",
        startsCombat = false,
        texture = 136059,

        toggle = "defensives",

        handler = function ()
            gain( 0.3 * health.max, "health" )
        end,
    },

    skull_bash = {
        id = 106839,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "skull_bash",
        startsCombat = true,
        form = function ()
            if talent.fluid_form.enabled then return end
            return buff.bear_form.up and "bear_form" or "cat_form" end,
        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if talent.fluid_form.enabled and buff.bear_form.down and buff.cat_form.down then shift( "cat_form" ) end
            interrupt()
        end,
    },

    starfire = {
        id = 197628,
        cast = function ()
            if buff.blooming_infusion.up then return 0 end
            return haste * 2.25
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135753,
        talent = "starfire",


        handler = function ()
            if buff.moonkin_form.down and buff.treant_form.down and buff.tree_of_life_form.down then
                if talent.fluid_form.enabled and not buff.moonkin_form.up then unshift() end
            end

            if talent.blooming_infusion.enabled then removeBuff( "blooming_infusion" ) end

            if talent.master_shapeshifter.enabled then gain( 43750, "mana" ) end
        end,

        finish = function ()
            if talent.fluid_form.enabled and buff.moonkin_form.down then shift( "moonkin_form" ) end
        end,

    },

    starsurge = {
        id = 197626,
        cast = 0,
        cooldown = function() return 10 - ( 4 * talent.starlight_conduit.rank ) end,
        gcd = "spell",

        spend = function () return ( talent.starlight_conduit.enabled and 0.003 or 0.006 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135730,
        talent = "starsurge",

        handler = function ()
            gain( 0.3 * health.max, "health" )
            if talent.master_shapeshifter.enabled then gain( 43750, "mana" ) end
            if talent.call_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid.down then
                applyBuff( "heart_of_the_wild", 15 )
                applyDebuff( "player", "oath_of_the_elder_druid" )
            end
        end,
    },

    -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 10,011. Swiftmend heals the target for 3,672 over 9 sec.
    swiftmend = {
        id = 18562,
        cast = 0,
        charges = function() if talent.prosperity.enabled then return 2 end end,
        cooldown = 15,
        recharge = function() if talent.prosperity.enabled then return 15 end end,
        gcd = "spell",

        spend = 0.10,
        spendType = "mana",

        talent = "swiftmend",
        startsCombat = false,
        texture = 134914,

        buff = function()
            return buff.regrowth.up and "regrowth" or
                buff.wild_growth.up and "wild_growth" or
                buff.renewing_bloom.up and "renewing_bloom" or
                "rejuvenation"
        end,

        handler = function ()
            if talent.verdant_infusion.enabled then
                if buff.regrowth.up then buff.regrowth.expires = buff.regrowth.expires + 8 end
                if buff.wild_growth.up then buff.wild_growth.expires = buff.wild_growth.expires + 8 end
                if buff.renewing_bloom.up then buff.renewing_bloom.expires = buff.renewing_bloom.expires + 8 end
                if buff.rejuvenation.up then buff.rejuvenation.expires = buff.rejuvenation.expires + 8 end
            else
                if buff.regrowth.up then removeBuff( "regrowth" )
                elseif buff.wild_growth.up then removeBuff( "wild_growth" )
                elseif buff.renewing_bloom.up then removeBuff( "renewing_bloom" )
                else removeBuff( "rejuvenation" ) end
            end

            if talent.reforestation.enabled then
                if buff.reforestation.stack == 3 then
                    removeBuff( "reforestation" )
                    applyBuff( "incarnation", ( 10 + 3 * talent.potent_enchantments.rank ) )
                    shift( "tree_of_life_form" )
                else addStack( "reforestation" )
                end
            end

            if talent.soul_of_the_forest.enabled then applyBuff( "soul_of_the_forest" ) end
        end,
    },

    --[[ Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form.
    swipe = {
        id = function() return buff.cat_form.up and 106785 or
            buff.bear_form.up and 213771
            or 213764 end,
        known = 213764,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        startsCombat = false,
        texture = 134296,

        handler = function ()
            if buff.cat_form.up then gain( 1, "combo_points" ) end
        end,

        copy = { 106785, 213771, 213764 },
    }, ]]

    -- Form a bond with an ally. Your self-healing also heals your bonded ally for 10% of the amount healed. Your healing to your bonded ally also heals you for 8% of the amount healed.
    symbiotic_relationship = {
        id = 474750,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "symbiotic_relationship",
        startsCombat = false,
        texture = 1408837,

        handler = function ()
            applyBuff( "symbiotic_relationship" )
        end,
    },

    -- Heals all allies within 40 yards for 8,560 over 6.6 sec. Each heal heals the target for another 199 over 8 sec, stacking. Healing increased by 100% when not in a raid.
    tranquility = {
        id = 740,
        cast = 5,
        channeled = true,
        cooldown = 180,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "tranquility",
        startsCombat = false,
        texture = 136107,

        toggle = "defensives",

        start = function()
            TranquilityTickHandler()

            local tickTime = query_time
            -- Schedule the next 4 ticks of Tranquility.
            for i = 1, 4 do
                tickTime = tickTime + spec.auras.tranquility.tick_time
                if tickTime <= query_time + spec.auras.tranquility.duration then
                    state:QueueAuraEvent( "tranquility_tick", TranquilityTickHandler, tickTime, "AURA_TICK" )
                end
            end
        end,
    },

    -- Heals up to 5 injured allies within 30 yards of the target for 3,426 over 7 sec. Healing starts high and declines over the duration. Tree of Life: Affects 2 additional targets.
    wild_growth = {
        id = 48438,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "wild_growth",
        startsCombat = false,
        texture = 236153,

        handler = function ()
            if talent.soul_of_the_forest.enabled then removeBuff( "soul_of_the_forest" ) end
            active_dot.wild_growth = active_dot.wild_growth + 5 + ( talent.improved_wild_growth.enabled and 1 or 0 ) + ( buff.tree_of_life_form.up and 2 or 0 )

        end,
    },

    wrath = {
        id = 5176,
        cast = function ()
            if buff.blooming_infusion.up or buff.tree_of_life_form.up then return 0 end
            return haste * 1.5
        end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.002,
        spendType = "mana",

        startsCombat = true,
        texture = 535045,

        velocity = 20,

        energize_amount = function() return action.wrath.spend * -1 end,

        handler = function ()

            if buff.moonkin_form.down and buff.treant_form.down and buff.tree_of_life_form.down then
                if talent.fluid_form.enabled and not buff.moonkin_form.up then unshift() end
            end

            if talent.blooming_infusion.enabled then removeBuff( "blooming_infusion" ) end
            removeBuff( "gathering_starstuff" )

            removeBuff( "dawning_sun" )
            if talent.master_shapeshifter.enabled then gain( 43750, "mana" ) end
        end,

        finish = function ()
            if talent.fluid_form.enabled and buff.moonkin_form.down then shift( "moonkin_form" ) end
        end,

        copy = { "solar_wrath", 5176 }
    },
} )



spec:RegisterRanges( "rake", "shred", "skull_bash", "growl", "moonfire" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,

    rangeFilter = false,
    healing_mode = false,
    damage = true,
    damageDots = true,
    damageExpiration = 6,

    package = "Restoration Druid",
} )

spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = strformat( "Restoration Druid supports healing maintenance by recommending key abilities. It will suggest maintaining %s, keeping at least one %s active, maintaining %s, using %s after a %s, and alerting you when %s can activate %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.lifebloom.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.rejuvenation.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.efflorescence.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.wild_growth.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.swiftmend.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.swiftmend.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.incarnation.id ) ),
    width = "full",
    fontSize = "medium"
} )

spec:RegisterSetting( "healing_mode", false, {
    name = "Healing Helper Mode",
    desc = "If checked, healing abilities may be recommended using the default priority package.",
    type = "toggle",
    width = "full",
} )


spec:RegisterPack( "Restoration Druid", 20250402, [[Hekili:TR1EVTnos8plbfqWUP1X2X2jzHTb27bWTb327W57(RdNLKLOI5zzjbkQKnag6Z(oK6fjfPSJBArxad0MejsoCEp)4iUE06)96v(Uu06VmE44PdNm82bdVD69tEy9k6RjO1RsC925(e8hrU7HF(VqP0yIlfhhL78xizyF2uEnm21NrQ04mIhmT1R2KHdP)s06nk0FmmPeK36VmA401R2I99rftcL6bptPjP)0n38eMUnBZaV493KI3NfY3qpIBaL9S3nBcJ3CdDl6fxYlWuXr38ZESP8pj4ycM(6FhNstVXNXF2KgwEaBX5p(FsYDOX5omgl3HrGCNv49)5Fk35xDjEWt3N7W43CNpN745T5oV7Ei)X8hbLqs62yAUdXf7N7Sjliab)oL6stHhrbXeGIaBVXLYE(jCe8E3iyoje0NtIPuC0t5oy4T(XrOb5p6Yz80bW4fR76f3S3LSZooWgKq7xWH(6N1wKlHE8PLqIFj8t4Gfu3queDaXDhAakYDtiYWk8CP2GKS34IQxgm50DzHH2BCt3k(2niskISJjScVnYLMbMd7NXpH5S0vmn4aohoilXQ4X0TU(XVShf6dVtC5EUWov8ODiyH)eZNCbOgcH9HrUuex)MoO8D27J9rIuOLk7TZezPiBmfTp9TVuW8d)1BFDKSO2InyK(ukLG9OlgzWqD4aNUvMZwAZJyLfMAC0ZX7qCTwAcgIW4sFpo5BPtH95WbV44qqAI0mmbT3fIlwoB4NVD4hl3ApyBj4Su7NGyw3ipbH4QYP0MsLtPVK)ywuaMG(K3REHah7sEcrtlureua49TLTgRIbgqX7HjfB7JrlNAvUr49GL5zKVDjT0Ps2hhFA7JWgmASeJcRjndwgBjSx)mYgfH2JrPZV)9rIUZsHU3PYaCcZICsqqSvjThunYYrLUq6SXIK6fi)6wH8cmFoMJl4pXOEB37s6wfbu(yAgRCGT7(nzPBf3Is6Pn8TxTRMg30kNT5tg24iPBEvUsaNeNMAfGFAl1UEXZu5enbpDqvREk2HfZ6B17k1OtRtssw8KN)G9U)M1pmHF9BPD6kFHGa3)hhzOLRlorxaxVEcHChoa2tYtVU8HHw1wNrdbPIvkn2ojghblCQusGYjE94jho0R6bX5)XjZfMFfHVEIYKwkmP(9zIi2JvV1sCAlhFTsK9l4eKniIFCClrob03m0sCmCFcmr2rOFdQUOop6wcuTNrKZiL0ulzgQHylNOUrDK4R3X2M(wxbqAE2MfSmQ2NtBcQJie9eP79wv6zqLxfv7hxu6C(OQkije8E3q7GmYR15akhAVBkfrSbINa7aoaEOEkgSvlNa2Q)7FdTdhI)Fag1yFCaMH70nLb2SjkjKdUKd3KJ9TqLaunY3Uzyge1igi20SKKycf5pOR0BTttv61pBOvvCvqidPnF8willOyx1l7zUGzT6g02c2ZspJ6Oo)Sca(FC4G7v1IftDXO(6DjmP0NB0De4yb6ujyA5LwKqOKBVtWHONH6YSChgZCQkrvlAklnXBFz31o)EhqxwmQjUOgnJvlFO2LmofpUPVfpUtnDwaIe7HJH6gBaC9A9pLsPERM8nZVLPAvY6xY0laUMNHaNux3IvK4K97(wLVD85Knuk8CiaIXCgVMYUD4IdtQRSEk(DvJ12VB5yPcFZN2HwSyRSpbL356tLULG4GtBsv2n31P7pdy9)ik3bcwHF4gTRz1Lz1zgp0)p7zqPYEVG6H75jm08rf0YL9)WWx1rQqCaAtyCmNBelYvpW8rkL)AgzSfN9RFbl8T0nilYh0gaKF6wbCxmU5vqHMIcdotUP1EYki29U(RqCif(FUZFniimw3gJydagBaxPxZXyKElFJYFKsCJs54lCaQgdgjccPJKGdCaDpuowvwiOco8AH3XYlB3(1IwZ(lRHCq4nFI1jk491fq4SS8qWV92T428h)5WxCFnL1aSqaWqXgbofSOtaBqfNQtme4SQQHSIYvlz9kwBks59wef4MfsH)8l8EnwqR1RA6A06vL866)0A66VmwCwnDrszw3YMvZBw5bhXarWURxDvrx5QpzzUJvUt1lLocAZ2i1wkg5NyK8A7WudLu7qvHMWUO3PLlHTbtFx5)wvZzBXS31TOURxmsF37kPl6kgJU3BKU66pLZHdLewivjyH49eJ5UvVdk9ptYOaRLT1p8w2Ar7DXoZiXOHgPrVsgvBBu4YXXpRBUZYCNzd5TK(w4xFKvkO7Z9wq6RQNOXt)M70xqMAF4DU4nsr8QdLlGflkVcLv5EaTlTYLMPLd2zt3a6kIiHzyzCZydCtfC8ozhf(aiM(nXCAgzWh5oZZDUxqLuHpMtf1SjF9kU74dQHhUZGGyoFJEq)fQfHqmDEUYYlxuy71mXm48gdkN8M2KjSQQGaNX(oqas5Ivlb6rJ6xTCixhig4lmwDXLU2SkurkbV6aDuSxqKtHwQRznMBUAbls07xdifPGY61PR6xlXOco1PkgAzqo0MZLfv95LyrfSxICPbiwn7I0y6kLkTtAbMzwRuHcl35AP3lG3rDiz3V(vbonQnT4YA03AWML7SasXleDvJRstzDjX90q0jk)THUvh52iZfbTSkLAcyvSDYFeRMeinicQFLA3(fIBHIT6IxLSBNsZY5E3tgQwiSJw1xhqZ(maCZK0NcOGGZoc2lZ1nofgWsmBst2DWPygN7kg)Q2GF4dDIQfGALFhHkc(JocfzqkcaVmJwVNoDu))OiWhfsMAQV6WhCIIwa(Ne0cgtu0AcUm8WqUorY7y0qbvLyZl4PNMQfivnbGCKJNuxyu81Yuc0yt4HusuYsEjtmUWLklSFD0ltdx044YGcXfVKxXdOPHopXj)yUfqhAk1uWvTbs6mhsDks3HMQMytFPodGGfMbtD4JpLj6fc1ZA1bOuvNNozN(vh5ttR21ZjQh9sQiqhQKET9)UVAZRT9ArNXOCf8TMc1A6GP4WD0dtngbbFPLCxvd(sTo0Ou98VPFZN1Ao3UAXeHCeZgwRCn1bEdNl20bh1DunD(AToTwlRCPjU9hisjTgOIYQU8Aqio7d0OX0vT0fv477YNUBB)CJXFToaRmMmLpU0rLJ2bWDF(1ENSFDVwIN4zeBsY3r102AirsmvmV9xdHUtfKG0XsnJsqfP1I6J(QdgMqwgnylm1dGJ3WVoc9ME2HENxPQrMQvj)PYAHhxPg7TglvmNpyJj3a8IAvWIADGYhsRiHqnsLZjo0uHWV11Ln1ZPZTCyR0KdRcFVQ7sCYas7mDq5upVsDJn3Fu1GSLvTKq2XaSItLowCX(YjU5JLEQMmTMEgPvZuFAbrJnN8TDv1oLt23sKtrZPW0KerBgbkV6sXf99ODF79)2olu7x5goxFAFZNRwGppLJyF8g2BwD2jj4DYGRlbT5Zisk7TcxV9xCjrSpr06v)Y(cOw8OIILN7W)0ydYFKtOaCieu)HpK7895MVZ2PZ(2VdR993LO5ZlE5cWF0lc(Lla)Lla)Lla)BqIUCb4VCb4)oe(D5cWF5cWFQPKUCb4pZlapa)8BA)q7kd3L7aVIhj(YDG3m6Ll3b(l3b(wvEVCh4)QVd8qfG3ZRbFj5(X5MWxYqF)Vm8FG16N3X7d)hyx0Q)iEL4bg)0Udv6KebMRQ(OYvRkJUnMWU)B7C3I3H5TqC9Vd]] )