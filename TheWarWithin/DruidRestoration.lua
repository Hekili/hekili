-- DruidRestoration.lua
-- July 2024

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 105 )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Rage )

-- Talents
spec:RegisterTalents( {
    -- Druid
    astral_influence            = {  82210, 197524, 1 }, -- Increases the range of all of your spells by 5 yards.
    cyclone                     = {  82213,  33786, 1 }, -- Tosses the enemy target into the air, disorienting them but making them invulnerable for up to 6 sec. Only one target can be affected by your Cyclone at a time.
    feline_swiftness            = {  82239, 131768, 1 }, -- Increases your movement speed by 15%.
    fluid_form                  = {  92229, 449193, 1 }, -- Shred and Rake can be used in any form and shift you into Cat Form. Mangle can be used in any form and shifts you into Bear Form. Wrath and Starfire shift you into Moonkin Form, if known.
    forestwalk                  = { 100173, 400129, 1 }, -- Casting Regrowth increases your movement speed and healing received by 8% for 6 sec.
    frenzied_regeneration       = {  82220,  22842, 1 }, -- Heals you for 30% health over 3 sec.
    heart_of_the_wild           = {  82231, 319454, 1 }, -- Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Feral: Gain 1 Combo Point every 2 sec while in Cat Form and Physical damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges.
    hibernate                   = {  82211,   2637, 1 }, -- Forces the enemy target to sleep for up to 40 sec. Any damage will awaken the target. Only one target can be forced to hibernate at a time. Only works on Beasts and Dragonkin.
    improved_barkskin           = {  82219, 327993, 1 }, -- Barkskin's duration is increased by 4 sec.
    improved_natures_cure       = {  82203, 392378, 1 }, -- Nature's Cure additionally removes all Curse and Poison effects.
    improved_rejuvenation       = {  82240, 231040, 1 }, -- Rejuvenation's duration is increased by 3 sec.
    improved_stampeding_roar    = {  82230, 288826, 1 }, -- Cooldown reduced by 60 sec.
    improved_sunfire            = {  93714, 231050, 1 }, -- Sunfire now applies its damage over time effect to all enemies within 8 yards.
    incapacitating_roar         = {  82237,     99, 1 }, -- Shift into Bear Form and invoke the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 10 yards for 3 sec. Damage will cancel the effect.
    innervate                   = {  82243,  29166, 1 }, -- Infuse a friendly healer with energy, allowing them to cast spells without spending mana for 8 sec.
    instincts_of_the_claw       = { 100176, 449184, 2 }, -- Shred, Swipe, Rake, Mangle, and Thrash damage increased by 5%.
    ironfur                     = {  82227, 192081, 1 }, -- Increases armor by 2,509 for 7 sec.
    killer_instinct             = {  82225, 108299, 2 }, -- Physical damage and Armor increased by 6%.
    lore_of_the_grove           = { 100175, 449185, 2 }, -- Moonfire and Sunfire damage increased by 10%. Rejuvenation and Wild Growth healing increased by 5%.
    lycaras_teachings           = {  82233, 378988, 2 }, -- You gain 3% of a stat while in each form: No Form: Haste Cat Form: Critical Strike Bear Form: Versatility Moonkin Form: Mastery
    maim                        = {  82221,  22570, 1 }, -- Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point: 1 point : 2,075 damage, 1 sec 2 points: 4,150 damage, 2 sec 3 points: 6,225 damage, 3 sec 4 points: 8,300 damage, 4 sec 5 points: 10,375 damage, 5 sec
    mass_entanglement           = {  82242, 102359, 1 }, -- Roots the target and all enemies within 12 yards in place for 10 sec. Damage may interrupt the effect. Usable in all shapeshift forms.
    matted_fur                  = {  82236, 385786, 1 }, -- When you use Barkskin or Survival Instincts, absorb 39,347 damage for 8 sec.
    mighty_bash                 = {  82237,   5211, 1 }, -- Invokes the spirit of Ursoc to stun the target for 4 sec. Usable in all shapeshift forms.
    natural_recovery            = {  82206, 377796, 1 }, -- Healing you receive is increased by 4%.
    natures_vigil               = {  82244, 124974, 1 }, -- For 15 sec, all single-target healing also damages a nearby enemy target for 20% of the healing done.
    nurturing_instinct          = {  82214,  33873, 2 }, -- Magical damage and healing increased by 6%.
    oakskin                     = { 100174, 449191, 1 }, -- Survival Instincts and Barkskin reduce damage taken by an additional 10%.
    primal_fury                 = {  82238, 159286, 1 }, -- While in Cat Form, when you critically strike with an attack that generates a combo point, you gain an additional combo point. Damage over time cannot trigger this effect. Mangle critical strike damage increased by 20%.
    rake                        = {  82199,   1822, 1 }, -- Rake the target for 6,883 Bleed damage and an additional 70,958 Bleed damage over 15 sec. While stealthed, Rake will also stun the target for 4 sec and deal 60% increased damage. Awards 1 combo point.
    rejuvenation                = {  82217,    774, 1 }, -- Heals the target for 70,573 over 17 sec. You can apply Rejuvenation twice to the same target. Tree of Life: Healing increased by 50% and Mana cost reduced by 30%.
    renewal                     = {  82232, 108238, 1 }, -- Instantly heals you for 30% of maximum health. Usable in all shapeshift forms.
    rip                         = {  82222,   1079, 1 }, -- Finishing move that causes Bleed damage over time. Lasts longer per combo point. 1 point : 58,573 over 8 sec 2 points: 87,859 over 12 sec 3 points: 117,146 over 16 sec 4 points: 146,432 over 20 sec 5 points: 175,719 over 24 sec
    rising_light_falling_night  = {  82207, 417712, 1 }, -- Increases your damage and healing by 3% during the day. Increases your Versatility by 2% during the night.
    skull_bash                  = {  82224, 106839, 1 }, -- You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    soothe                      = {  82229,   2908, 1 }, -- Soothes the target, dispelling all enrage effects.
    stampeding_roar             = {  82234, 106898, 1 }, -- Shift into Bear Form and let loose a wild roar, increasing the movement speed of all friendly players within 15 yards by 60% for 8 sec.
    starfire                    = {  91040, 197628, 1 }, -- Call down a burst of energy, causing 37,579 Arcane damage to the target, and 12,823 Arcane damage to all other enemies within 5 yards. Deals reduced damage beyond 8 targets.
    starlight_conduit           = { 100223, 451211, 1 }, -- Wrath, Starsurge, and Starfire damage increased by 5%. Starsurge's cooldown is reduced by 4 sec and its mana cost is reduced by 50%.
    starsurge                   = {  82200, 197626, 1 }, -- Launch a surge of stellar energies at the target, dealing 40,008 Astral damage.
    sunfire                     = {  82208,  93402, 1 }, -- A quick beam of solar light burns the enemy for 3,637 Nature damage and then an additional 40,586 Nature damage over 18 sec to the primary target and all enemies within 8 yards.
    thick_hide                  = {  82228,  16931, 1 }, -- Reduces all damage taken by 4%.
    thrash                      = {  82223, 106832, 1 }, -- Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form.
    tiger_dash                  = {  82198, 252216, 1 }, -- Shift into Cat Form and increase your movement speed by 200%, reducing gradually over 5 sec.
    typhoon                     = {  82209, 132469, 1 }, -- Blasts targets within 20 yards in front of you with a violent Typhoon, knocking them back and reducing their movement speed by 50% for 6 sec. Usable in all shapeshift forms.
    ursine_vigor                = {  82235, 377842, 1 }, -- For 4 sec after shifting into Bear Form, your health and armor are increased by 15%.
    ursocs_spirit               = { 100177, 449182, 1 }, -- Stamina in Bear Form is increased by 10%.
    ursols_vortex               = {  82242, 102793, 1 }, -- Conjures a vortex of wind for 10 sec at the destination, reducing the movement speed of all enemies within 8 yards by 50%. The first time an enemy attempts to leave the vortex, winds will pull that enemy back to its center. Usable in all shapeshift forms.
    verdant_heart               = {  82218, 301768, 1 }, -- Frenzied Regeneration and Barkskin increase all healing received by 20%.
    wellhoned_instincts         = {  82246, 377847, 1 }, -- When you fall below 40% health, you cast Frenzied Regeneration, up to once every 120 sec.
    wild_charge                 = {  82198, 102401, 1 }, -- Fly to a nearby ally's position.
    wild_growth                 = {  82241,  48438, 1 }, -- Heals up to 5 injured allies within 30 yards of the target for 29,010 over 7 sec. Healing starts high and declines over the duration. Tree of Life: Affects 2 additional targets.

    -- Restoration
    abundance                   = {  82052, 207383, 1 }, -- For each Rejuvenation you have active, Regrowth's cost is reduced by 8% and critical effect chance is increased by 8%, up to a maximum of 96%.
    budding_leaves              = {  82072, 392167, 2 }, -- Lifebloom's healing is increased by 5.0% each time it heals, up to 75%. Also increases Lifebloom's final bloom amount by 10%.
    call_of_the_elder_druid     = {  82067, 426784, 1 }, -- When you shift into a combat shapeshift form or cast Starsurge, you gain Heart of the Wild for 10 sec, once every 1 min.  Heart of the Wild Abilities not associated with your specialization are substantially empowered for 45 sec. Balance: Cast time of Balance spells reduced by 30% and damage increased by 20%. Feral: Gain 1 Combo Point every 2 sec while in Cat Form and Physical damage increased by 20%. Guardian: Bear Form gives an additional 20% Stamina, multiple uses of Ironfur may overlap, and Frenzied Regeneration has 2 charges.
    cenarion_ward               = {  82052, 102351, 1 }, -- Protects a friendly target for 30 sec. Any damage taken will consume the ward and heal the target for 75,723 over 8 sec.
    cenarius_guidance           = {  82063, 393371, 1 }, --  Incarnation: Tree of Life During Incarnation: Tree of Life, you summon a Grove Guardian every 10 sec. The cooldown of Incarnation: Tree of Life is reduced by 5.0 sec when Grove Guardians fade.  Convoke the Spirits Convoke the Spirits' cooldown is reduced by 50% and its duration and number of spells cast is reduced by 25%. Convoke the Spirits has an increased chance to use an exceptional spell or ability.
    convoke_the_spirits         = {  82064, 391528, 1 }, -- Call upon the spirits for an eruption of energy, channeling a rapid flurry of 9 Druid spells and abilities over 3 sec. You will cast Wild Growth, Swiftmend, Moonfire, Wrath, Regrowth, Rejuvenation, Rake, and Thrash on appropriate nearby targets, favoring your current shapeshift form.
    cultivation                 = {  82056, 200390, 1 }, -- When Rejuvenation heals a target below 60% health, it applies Cultivation to the target, healing them for 3,817 over 6 sec.
    dream_of_cenarius           = {  82066, 158504, 1 }, -- While Heart of the Wild is active, Wrath and Shred transfer 150% of their damage and Starfire and Swipe transfer 100% of their damage into healing onto a nearby ally.
    dreamstate                  = {  82053, 392162, 1 }, -- While channeling Tranquility, your other Druid spell cooldowns are reduced by up to 20 seconds.
    efflorescence               = {  82057, 145205, 1 }, -- Grows a healing blossom at the target location, restoring 3,326 health to three injured allies within 10 yards every 1.4 sec for 30 sec. Limit 1.
    embrace_of_the_dream        = {  82070, 392124, 1 }, -- Wild Growth momentarily shifts your mind into the Emerald Dream, instantly healing all allies affected by your Rejuvenation or Regrowth for 6,745.
    flash_of_clarity            = {  82083, 392220, 1 }, -- Clearcast Regrowths heal for an additional 30%.
    flourish                    = {  82073, 197721, 1 }, -- Extends the duration of all of your heal over time effects on friendly targets within 60 yards by 6 sec, and increases the rate of your heal over time effects by 25% for 6 sec.
    germination                 = {  82071, 155675, 1 }, -- You can apply Rejuvenation twice to the same target. Rejuvenation's duration is increased by 2 sec.
    grove_guardians             = {  82043, 102693, 1 }, -- Summons a Treant which will immediately cast Swiftmend on your current target, healing for 18,929. The Treant will cast Nourish on that target or a nearby ally periodically, healing for 5,915. Lasts 15 sec.
    grove_tending               = {  82047, 383192, 1 }, -- Swiftmend heals the target for 27,837 over 9 sec.
    harmonious_blooming         = {  82065, 392256, 2 }, -- Lifebloom counts for 2 stacks of Mastery: Harmony.
    improved_ironbark           = {  82081, 382552, 1 }, -- Ironbark's cooldown is reduced by 20 sec.
    improved_regrowth           = {  82055, 231032, 1 }, -- Regrowth's initial heal has a 40% increased chance for a critical effect if the target is already affected by Regrowth.
    improved_wild_growth        = {  82045, 328025, 1 }, -- Wild Growth heals 1 additional target.
    incarnation                 = {  82064,  33891, 1 }, -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    incarnation_tree_of_life    = {  82064,  33891, 1 }, -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, Entangling Roots, and Wrath is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    inner_peace                 = {  82053, 197073, 1 }, -- Reduces the cooldown of Tranquility by 30 sec. While channeling Tranquility, you take 20% reduced damage and are immune to knockbacks.
    invigorate                  = {  82070, 392160, 1 }, -- Refreshes the duration of your active Lifebloom and Rejuvenation effects on the target and causes them to complete 200% faster.
    ironbark                    = {  82082, 102342, 1 }, -- The target's skin becomes as tough as Ironwood, reducing damage taken by 20% for 12 sec.
    lifebloom                   = {  82049,  33763, 1 }, -- Heals the target for 45,886 over 15 sec. When Lifebloom expires or is dispelled, the target is instantly healed for 19,701. May be active on one target at a time.
    liveliness                  = {  82074, 426702, 1 }, -- Your damage over time effects deal their damage 25% faster, and your healing over time effects heal 5% faster.
    master_shapeshifter         = {  82074, 289237, 1 }, -- Your abilities are amplified based on your current shapeshift form, granting an additional effect. Wrath, Starfire, and Starsurge deal 30% additional damage and generate 2,500 Mana. Bear Form Ironfur grants 30% additional armor and generates 2,500 Mana.  Cat Form Rip, Ferocious Bite, and Maim deal 60% additional damage and generate 10,000 Mana when cast with 5 combo points.
    natures_splendor            = {  82051, 392288, 1 }, -- The healing bonus to Regrowth from Nature's Swiftness is increased by 35%.
    natures_swiftness           = {  82050, 132158, 1 }, -- Your next Regrowth, Rebirth, or Entangling Roots is instant, free, castable in all forms, and heals for an additional 135%.
    nourish                     = {  82043,  50464, 1 }, -- Heals a friendly target for 31,835. Receives 300% bonus from Mastery: Harmony.
    nurturing_dormancy          = {  82076, 392099, 1 }, -- When your Rejuvenation heals a full health target, its duration is increased by 2 sec, up to a maximum total increase of 4 sec per cast.
    omen_of_clarity             = {  82084, 113043, 1 }, -- Your healing over time from Lifebloom has a 4% chance to cause a Clearcasting state, making your next Regrowth cost no mana.
    overgrowth                  = {  82061, 203651, 1 }, -- Apply Lifebloom, Rejuvenation, Wild Growth, and Regrowth's heal over time effect to an ally.
    passing_seasons             = {  82051, 382550, 1 }, -- Nature's Swiftness's cooldown is reduced by 12 sec.
    photosynthesis              = {  82073, 274902, 1 }, -- While your Lifebloom is on yourself, your periodic heals heal 10% faster. While your Lifebloom is on an ally, your periodic heals on them have a 4% chance to cause it to bloom.
    power_of_the_archdruid      = {  82077, 392302, 1 }, -- Wild Growth has a 40% chance to cause your next Rejuvenation or Regrowth to apply to 2 additional allies within 20 yards of the target.
    prosperity                  = {  82079, 200383, 1 }, -- Swiftmend now has 2 charges.
    rampant_growth              = {  82058, 404521, 1 }, -- Regrowth's healing over time is increased by 50%, and it also applies to the target of your Lifebloom.
    reforestation               = {  82069, 392356, 1 }, -- Every 3 casts of Swiftmend grants you Incarnation: Tree of Life for 10 sec.
    regenerative_heartwood      = {  82075, 392116, 1 }, -- Allies protected by your Ironbark also receive 75% of the healing from each of your active Rejuvenations and Ironbark's duration is increased by 4 sec.
    regenesis                   = {  82062, 383191, 2 }, -- Rejuvenation healing is increased by up to 10%, and Tranquility healing is increased by up to 20%, healing for more on low-health targets.
    soul_of_the_forest          = {  82059, 158478, 1 }, -- Swiftmend increases the healing of your next Regrowth or Rejuvenation by 150%, or your next Wild Growth by 50%.
    spring_blossoms             = {  82061, 207385, 1 }, -- Each target healed by Efflorescence is healed for an additional 2,312 over 6 sec.
    stonebark                   = {  82081, 197061, 1 }, -- Ironbark increases healing from your heal over time effects by 20%.
    thriving_vegetation         = {  82068, 447131, 2 }, -- Rejuvenation instantly heals your target for 20% of its total periodic effect and Regrowth's duration is increased by 3 sec.
    tranquil_mind               = {  92674, 403521, 1 }, -- Increases Omen of Clarity's chance to activate Clearcasting to 5% and Clearcasting can stack 1 additional time.
    tranquility                 = {  82054,    740, 1 }, -- Heals all allies within 45 yards for 168,455 over 5.6 sec. Each heal heals the target for another 982 over 8 sec, stacking. Healing decreased beyond 5 targets.
    undergrowth                 = {  82077, 392301, 1 }, -- You may Lifebloom two targets at once, but Lifebloom's healing is reduced by 10%.
    unstoppable_growth          = {  82080, 382559, 2 }, -- Wild Growth's healing falls off 40% less over time.
    verdancy                    = {  82060, 392325, 1 }, -- When Lifebloom blooms, up to 3 targets within your Efflorescence are healed for 13,876.
    verdant_infusion            = {  82079, 392410, 1 }, -- Swiftmend no longer consumes a heal over time effect, and extends the duration of your heal over time effects on the target by 8 sec.
    waking_dream                = {  82046, 392221, 1 }, -- Ysera's Gift now heals every 4 sec and its healing is increased by 8% for each of your active Rejuvenations.
    wild_synthesis              = {  94535, 400533, 1 }, --  Nourish Regrowth decreases the cast time of your next Nourish by 33% and causes it to receive an additional 33% bonus from Mastery: Harmony. Stacks up to 3 times. Grove Guardians Treants from Grove Guardians also cast Wild Growth immediately when summoned, healing 5 allies within 40 yds for 9,707 over 7 sec.
    yseras_gift                 = {  82048, 145108, 1 }, -- Heals you for 3% of your maximum health every 5 sec. If you are at full health, an injured party or raid member will be healed instead.

    -- Keeper of the Grove
    blooming_infusion           = {  94601, 429433, 1 }, -- Every 5 Regrowths you cast makes your next Wrath, Starfire, or Entangling Roots instant and increases damage it deals by 100%. Every 5 Starsurges you cast makes your next Regrowth or Entangling roots instant.
    bounteous_bloom             = {  94591, 429215, 1 }, -- Your Grove Guardians' healing is increased by 20%.
    cenarius_might              = {  94604, 455797, 1 }, -- Casting Swiftmend increases your Haste by 10% for 6 sec.
    control_of_the_dream        = {  94592, 434249, 1 }, -- Time elapsed while your major abilities are available to be used is subtracted from that ability's cooldown after the next time you use it, up to 15 seconds. Affects Nature's Swiftness, Incarnation: Tree of Life, and Convoke the Spirits.
    dream_surge                 = {  94600, 433831, 1, "keeper_of_the_grove" }, -- Grove Guardians causes your next targeted heal to create 2 Dream Petals near the target, healing up to 3 nearby allies for 14,275. Stacks up to 3 charges.
    durability_of_nature        = {  94605, 429227, 1 }, -- Your Grove Guardians' Nourish and Swiftmend spells also apply a Minor Cenarion Ward that heals the target for 19,170 over 8 sec the next time they take damage.
    early_spring                = {  94591, 428937, 1 }, -- Grove Guardians cooldown reduced by 3 sec.
    expansiveness               = {  94602, 429399, 1 }, -- Your maximum mana is increased by 5%.
    groves_inspiration          = {  94595, 429402, 1 }, -- Wrath and Starfire damage increased by 10%. Regrowth, Wild Growth, and Swiftmend healing increased by 6%.
    harmony_of_the_grove        = {  94606, 428731, 1 }, -- Each of your Grove Guardians increases your healing done by 3% while active.
    potent_enchantments         = {  94595, 429420, 1 }, -- Reforestation grants Tree of Life for 2 additional sec.
    power_of_nature             = {  94605, 428859, 1 }, -- Your Grove Guardians increase the healing of your Rejuvenation, Efflorescence, and Lifebloom by 5% while active.
    power_of_the_dream          = {  94592, 434220, 1 }, -- Healing spells cast with Dream Surge generate an additional Dream Petal.
    protective_growth           = {  94593, 433748, 1 }, -- Your Regrowth protects you, reducing damage you take by 8% while your Regrowth is on you.
    treants_of_the_moon         = {  94599, 428544, 1 }, -- Your Grove Guardians cast Moonfire on nearby targets about once every 6 sec.

    -- Wildstalker
    bond_with_nature            = {  94625, 439929, 1 }, -- Healing you receive is increased by 10%.
    bursting_growth             = {  94630, 440120, 1 }, -- When Bloodseeker Thorns expire or you use Ferocious Bite on their target they explode in thorns, dealing 9,078 physical damage to nearby enemies. Damage reduced above 5 targets. When Symbiotic Blooms expire or you cast Rejuvenation on their target flowers grow around their target, healing them and up to 3 nearby allies for 1,427.
    entangling_vortex           = {  94622, 439895, 1 }, -- Enemies pulled into Ursol's Vortex are rooted in place for 3 sec. Damage may cancel the effect.
    flower_walk                 = {  94622, 439901, 1 }, -- During Barkskin your movement speed is increased by 10% and every second flowers grow beneath your feet that heal up to 3 nearby injured allies for 2,421.
    harmonious_constitution     = {  94625, 440116, 1 }, -- Your Regrowth's healing to yourself is increased by 50%.
    hunt_beneath_the_open_skies = {  94629, 439868, 1 }, -- Damage and healing while in Cat Form increased by 3%. Moonfire and Sunfire damage increased by 10%.
    implant                     = {  94628, 440118, 1 }, -- Your Swiftmend causes a Symbiotic Bloom to grow on the target for 4 sec.
    lethal_preservation         = {  94624, 455461, 1 }, -- When you remove an effect with Soothe or Nature's Cure, gain a combo point and heal for 4% of your maximum health. If you are at full health an injured party or raid member will be healed instead.
    resilient_flourishing       = {  94631, 439880, 1 }, -- Bloodseeker Vines and Symbiotic Blooms last 2 additional sec. When a target afflicted by Bloodseeker Vines dies, the vines jump to a valid nearby target for their remaining duration.
    root_network                = {  94631, 439882, 1 }, -- Each active Bloodseeker Vine increases the damage your abilities deal by 2%. Each active Symbiotic Bloom increases the healing of your spells by 2%.
    strategic_infusion          = {  94623, 439890, 1 }, -- Attacking from Prowl increases the chance for Shred, Rake, and Swipe to critically strike by 8% for 6 sec. Casting Regrowth increases the chance for your periodic heals to critically heal by 8% for 10 sec.
    thriving_growth             = {  94626, 439528, 1, "wildstalker" }, -- Rip and Rake damage has a chance to cause Bloodseeker Vines to grow on the victim, dealing 17,507 Bleed damage over 6 sec. Wild Growth, Regrowth, and Efflorescence healing has a chance to cause Symbiotic Blooms to grow on the target, healing for 17,131 over 6 sec. Multiple instances of these can overlap.
    twin_sprouts                = {  94628, 440117, 1 }, -- When Bloodseeker Vines or Symbiotic Blooms grow, they have a 20% chance to cause another growth of the same type to immediately grow on a valid nearby target.
    vigorous_creepers           = {  94627, 440119, 1 }, -- Bloodseeker Vines increase the damage your abilities deal to affected enemies by 5%. Symbiotic Blooms increase the healing your spells do to affected targets by 6%.
    wildstalkers_power          = {  94621, 439926, 1 }, -- Rip and Ferocious Bite damage increased by 5%. Rejuvenation, Efflorescence, and Lifebloom healing increased by 10%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    deep_roots         =  700, -- (233755)
    disentanglement    =   59, -- (233673)
    early_spring       = 1215, -- (203624)
    entangling_bark    =  692, -- (247543)
    focused_growth     =  835, -- (203553)
    high_winds         =  838, -- (200931)
    malornes_swiftness = 5514, -- (236147)
    preserve_nature    = 5387, -- (353114)
    reactive_resin     =  691, -- (409785)
    thorns             =  697, -- (305497) Sprout thorns for 12 sec on the friendly target. When victim to melee attacks, thorns deals 15,862 Nature damage back to the attacker. Attackers also have their movement speed reduced by 50% for 4 sec.
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
        id = 338643,
        duration = 60,
        max_stack = 1,
        copy = "oath_of_the_elder_druid"
    },
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1
    },
    cenarion_ward_hot = {
        id = 102352,
        duration = 8,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
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
    efflorescence = {
        id = 81262,
        duration = 30,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- disentanglement[233673] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    flourish = {
        id = 197721,
        duration = 8,
        max_stack = 1
    },
    grove_guardians = {
        id = 102693,
        duration = 15,
        max_stack = 3,
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
    incarnation_tree_of_life = {
        id = 33891,
        duration = 30,
        max_stack = 1,
        copy = "incarnation"
    },
    ironbark = {
        id = 102342,
        duration = function() return talent.regenerative_heartwood.enabled and 16 or 12 end,
        max_stack = 1
    },
    lifebloom = {
        id = 33763,
        duration = 15,
        tick_time = function() return mod_liveliness_hot( 1 ) end,
        max_stack = 1,
        dot = "buff",
        copy = 290754
    },
    lifebloom_2 = {
        id = 188550,
        duration = 15,
        tick_time = function() return mod_liveliness_hot( 1 ) end,
        max_stack = 1,
        dot = "buff"
    },
    natures_swiftness = {
        id = 132158,
        duration = 3600,
        max_stack = 1,
        onRemove = function()
            setCooldown( "natures_swiftness", 60 )
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
    regrowth = {
        id = 8936,
        duration = function() return 12 + 3 * talent.thriving_vegetation.rank end,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
        max_stack = 1
    },
    rejuvenation = {
        id = 774,
        duration = 12,
        tick_time = function() return mod_liveliness_hot( 3 ) end,
        max_stack = 1
    },
    rejuvenation_germination = {
        id = 155777,
        duration = 12,
        tick_time = function() return mod_liveliness_hot( 3 ) end,
        max_stack = 1
    },
    renewing_bloom = {
        id = 364686,
        duration = 8,
        tick_time = function() return mod_liveliness_hot( 1 ) end,
        max_stack = 1
    },
    tranquility = {
        id = 740,
        duration = function() return 8 * haste end,
        max_stack = 1,
    },
    tranquility_hot = {
        id = 157982,
        duration = 8,
        tick_time = function() return mod_liveliness_hot( 2 ) end,
        max_stack = 1
    },
    wild_growth = {
        id = 48438,
        duration = 7,
        tick_time = function() return mod_liveliness_hot( 1 ) end,
        max_stack = 1
    },
} )


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

    if talent.call_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid.down then
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

spec:RegisterStateExpr( "lunar_eclipse", function ()
    return eclipse.wrath_counter
end )

spec:RegisterStateExpr( "solar_eclipse", function ()
    return eclipse.starfire_counter
end )


-- Tier 30
spec:RegisterGear( "tier30", 202518, 202516, 202515, 202514, 202513 )
-- 2 pieces (Restoration) : Rejuvenation and Lifebloom healing increased by 12%. Regrowth healing over time increased by 50%.
-- 4 pieces (Restoration) : Flourish increases the rate of your heal over time effects by 30% for an additional 16 sec after it ends. Verdant Infusion causes your Swiftmend target to gain 15% increased healing from you for 6 sec.

spec:RegisterGear( "tier31", 207252, 207253, 207254, 207255, 207257, 217193, 217195, 217191, 217192, 217194 )
-- (2) You and your Grove Guardian's Nourishes now heal $s1 additional allies within $423618r yds at $s2% effectiveness.
-- (4) Consuming Clearcasting now causes your Regrowth to also cast Nourish onto a nearby injured ally at $s1% effectiveness, preferring those with your heal over time effects.


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
            applyBuff( "cenarion_ward" )
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
        cooldown = 20,
        recharge = 20,
        charges = 3,
        icd = 0.5,
        gcd = "off",

        spend = 0.012,
        spendType = 'mana',

        talent = "grove_guardians",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 54983, 'schools': ['physical', 'holy', 'fire', 'arcane'], 'value1': 5734, 'target': TARGET_DEST_CASTER, }

        handler = function()
            class.abilities.swiftmend.handler()
            if talent.wild_synthesis.enabled then class.abilities.wild_growth.handler() end
            applyBuff( "grove_guardians" ) -- Just for tracking.
        end,
    },

    -- Shapeshift into the Tree of Life, increasing healing done by 15%, increasing armor by 120%, and granting protection from Polymorph effects. Functionality of Rejuvenation, Wild Growth, Regrowth, and Entangling Roots is enhanced. Lasts 30 sec. You may shapeshift in and out of this form for its duration.
    incarnation = {
        id = 33891,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "incarnation",
        startsCombat = false,
        texture = 236157,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "incarnation_tree_of_life" )
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
        cooldown = 90,
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
        id = 33763,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "lifebloom",
        startsCombat = false,
        texture = 134206,

        handler = function ()
            if active_dot.lifebloom_2 > 0 then applyBuff( "lifebloom" )
            elseif active_dot.lifebloom > 0 then applyBuff( "lifebloom_2" ) end
        end,
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
        cooldown = 60,
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
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "nourish",
        startsCombat = false,
        texture = 236162,

        handler = function ()
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
        cast = function() return buff.incarnation.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.10,
        spendType = "mana",

        startsCombat = false,
        texture = 136085,

        handler = function ()
            applyBuff( "regrowth" )
        end,
    },

    -- Heals the target for 4,624 over 15 sec. Tree of Life: Healing increased by 50% and Mana cost reduced by 30%.
    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.incarnation.up and 0.7 or 1 ) * 0.021 end,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,
        texture = 136081,

        handler = function ()
            applyBuff( "rejuvenation" )
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

    -- Consumes a Regrowth, Wild Growth, or Rejuvenation effect to instantly heal an ally for 10,011. Swiftmend heals the target for 3,672 over 9 sec.
    swiftmend = {
        id = 18562,
        cast = 0,
        charges = function() return talent.prosperity.enabled and 2 or nil end,
        cooldown = 15,
        recharge = function() return talent.prosperity.enabled and 15 or nil end,
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

    -- Heals all allies within 40 yards for 8,560 over 6.6 sec. Each heal heals the target for another 199 over 8 sec, stacking. Healing increased by 100% when not in a raid.
    tranquility = {
        id = 740,
        cast = function() return 8 * haste end,
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
            applyBuff( "tranquility" )
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
            applyBuff( "wild_growth" )
        end,
    },
} )



spec:RegisterRanges( "rake", "shred", "skull_bash", "growl", "moonfire" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageDots = true,
    damageExpiration = 6,

    package = "Restoration Druid",
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterPack( "Restoration Druid", 20240811, [[Hekili:1I12UnUnq0VLGfqWoxuL8TKTW2pu0h6gGUOOEb6B6ILOTjSSKkLusdGH(27qkrjkkslN0uGfBsShoCUCMZmCCSD(HZMq)CKZ3NynzM1t22MwpnDY0PoBYFlf5Sj1p4O)E4xI9pb))FIYYti(54K4sVFLuGdPI8wuIFivvzjfKaqmNnBlWr5Fl2zRA9pbKnff48DBR5oBoGddrvYIYcC28Bi)ieP0lLGti4CmkR0ZNGGB8p28WUKGImuyPxsC0BMLpx(mv1py94dtT(5sVFCaK7V8Ht)x48d4yNnr4S8mMJI25xeLd)63zoUFa1pal5yruK7w)SdoBqX(BJqHo)ItoyZIsTfrYqKJ449ssnLkv7NSjamzeb77S5MsVTf72zMssEnYSiT0ZO0J)Hzh8dtE9ekke(M2Rj2pVGGYCFbVhhrv)Spv1Fa5tYDt25MFa5(kokKEfZ)uVci74cN)ugv1l(uvDAc7NGEFuREZbStCUjX)iYKlWMSCcoiNM3B0fPi2T63DPiKkCIBfmpWpNEjp9(UeUMHt7UlHCIQIVQvfJQD1EzewS485sVGKKiikeRqec6Kpogklwx6TWQ07HsVPWpUT0R2YcG7KGlYC3d1O(XbnMzLQVPrW(6UrWXcUus8ljhrmHYsXGtWYU2wsUxtjvr8ombj6Ve0oaxFGkklvN7t2JYnZXNa1M4gIrmVzE9xYmo8jaD8ck0TwFTX6G3cIGZX0rgnVsTgBnwZPKKHnhj7WEIMlzI2mk96Eb5IIrNyuwll9EsiKa6jRauftlYKg)3dCpY(sf2WJACe9ela1mqiwlUj1WP2uvyPc)Of521FzUc9UMlYK(k0arIQnVQMJZmR0Q6tmiylTSinFuwbTRIR)PTfzh6yA0Y2g(DDfNnvFkW(T1Fq8DMLCnLQt0wvvj9o8(d5UD0ZIbOP1Hzi4ujBh(xhud9cbibz)BSK4xTyyL2lFfKyTyMMb7WbjN2M4MMGJZHVEvtvPeKRrb3v6nzw11mQ7h3vta)0mMV2rtgDpYmThCT0bh3enPXECaT5mtDDpmCSjmDkHRFfNICbyht9ty8DQkuKRtaQD3y0)0TBskGwGSz9aqk6PYfm)abg0GETF4A8UUrRcR8u1oHCF4lW3idEUix9yEB7uc6f39bHM2M8(FC0KmN0QgAKbO51MsK7(3PW(9qYBPiGkGlwsfrTjOF2a(mm8WaF2gHcW5w8ytys9ueYM6ftYthqKLCOsDaU67u3z)cdRCP(NQqj9AHYbhn1M1mecGL6uUeHeeyk4pZakoTmFsvIIF0ka14RanEPm9cn9jLNXPngiCl8q0G(r)spvtUOFOI2Ihfvw0jo6mhDhm4yDdJOVp4vHLvdM6nIZ1XB2BSeUK7qKKaCcms7wW661SwIWFQwERLSVCCtmutVUgpCvt5kRwfN2z4722MxcAntd06)LMel4ClxKcPldCeaJIWXOSSb5ET1)Koz4ytEOBmEP2P8PbT(VNQjwYUEDC)F8jNRmgvto3WF9HEoIClIRSaq)tgfQ6wyPjWkeqoqqHvZwdevujvpHnDNlaSU6qBI9tZoKayeIpoSQ6Ncgacd6nSfbobQ6EPaPTO9Skb)4qgP7dWl0Zzm94mAbtmYuOnIp5O8mTDwXs)PE78iHlSPLR(946F0Zfvb75fSyjenFbrYOFA9oTOBW6vFsm42zoB(2P0esonKnTctrP(zRGYS8zMI2HJau6xk9(8J1LpxDJzMnz87w9tYXD1s1l4RwmEW8E8UvkczQpel8P9enNbKSDxCIFA7U3e)0oRkJQ9B68uqJBu8IXN)Yx4PfQkKwc0901)ScIeax4(RtJgH0TGwXPaeUXHU8Jt5tDdcxnXs0O7fMVURrufnly79F0QfO9(pNY4eafUVAXARShco8oqour7)aA6PgPDTdNpp8YYwVW6HPw3o0cYoF(MHwn24oi2QEb33PfqvarO)Jr)EpRNBm07FeUg(aMdEpcxamaUOHYN5JEKUD7w(0NJh9OHKEFu2aykguK6vmT2(8z9lfvqvSvijWCqhqLctb8ev79bZ16LJ3R)t5vejRpLfRJUMndTCMvlq6c7dA85ZD2e0Yzl65u4uvPIrJesgNpxnBW6VAzW10kBRXgJeNqy18oWJAbVBYSZNhX)dr5VD2sb55k(UzscTwqOXJPUD1Z9mefB9K70mH8Ttgl7YDgk6E(CtRSLLRDM2peyv3aYRNiFrxOKy0qv5JnUrXZrng1Tuzfa9hGoOxyIb3hYXf5dSm0KdwABjRCr66BKFeOrnCBULXivRWqFODQ2VA5Jgkxxrp3(suHJ0ZfAWXLaAV)ciAkB4py)w4X6YHRkrxzpwtovx0TxnnhpbwSILiO0w6Pc905uS0izgEJEjXEb2RmL)rRw7(cELzVomgtvuoTCkqWitQvBzRa0O0B0xt5a1LvM9PsNSWyKwqFBTD)hA3ll0yG9tSqir01xQyccXNq)oyXgIeRxJDJBU2HxENOe2ZwPMuDwDHLKptB7lmfVz982Ssc6WOUzO)Uabt01onpbThA8djen)eEOxr(HeIZMF3)O)b8rm7LEo)7d]] )